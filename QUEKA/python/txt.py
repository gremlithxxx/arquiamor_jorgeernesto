import tkinter as tk
from tkinter import ttk, filedialog, messagebox, scrolledtext
import os
import struct
import platform
import subprocess
import datetime

class MIPSDecoder:
    def __init__(self):
        # Tabla de instrucciones para escalabilidad
        self.instruction_table = {
            'ADD': {'type': 'R', 'opcode': 0x00, 'funct': 0x20, 'operand_parser': self.parse_r_type},
            'SUB': {'type': 'R', 'opcode': 0x00, 'funct': 0x22, 'operand_parser': self.parse_r_type},
            'OR':  {'type': 'R', 'opcode': 0x00, 'funct': 0x25, 'operand_parser': self.parse_r_type}
        }
        
        # Mapeo de registros
        self.register_map = {f'${i}': i for i in range(32)}
        
        # Inicializar lista vacía de instrucciones binarias
        self.binary_strings = []
        
        self.setup_gui()
    
    def setup_gui(self):
        """Configura la interfaz gráfica"""
        self.root = tk.Tk()
        self.root.title("Decodificador MIPS32 - Big Endian")
        self.root.geometry("700x600")
        
        # Frame principal
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Título
        title_label = ttk.Label(main_frame, text="Decodificador de Instrucciones MIPS", 
                               font=('Arial', 14, 'bold'))
        title_label.grid(row=0, column=0, columnspan=3, pady=(0, 20))
        
        # Instrucciones soportadas
        info_label = ttk.Label(main_frame, 
                              text="Instrucciones soportadas: ADD, SUB, OR\nFormato: INSTR $rd, $rs, $rt",
                              font=('Arial', 10))
        info_label.grid(row=1, column=0, columnspan=3, pady=(0, 10))
        
        # Entrada manual
        ttk.Label(main_frame, text="Instrucción manual:").grid(row=2, column=0, sticky=tk.W, pady=(10, 5))
        
        self.manual_entry = ttk.Entry(main_frame, width=50)
        self.manual_entry.grid(row=3, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        self.manual_entry.bind('<Return>', lambda e: self.decode_from_text())
        
        ttk.Button(main_frame, text="Decodificar Línea", 
                  command=self.decode_from_text).grid(row=3, column=2, padx=(10, 0))
        
        # Separador
        ttk.Separator(main_frame, orient='horizontal').grid(row=4, column=0, columnspan=3, 
                                                           sticky=(tk.W, tk.E), pady=20)
        
        # Entrada por archivo
        ttk.Label(main_frame, text="Entrada por archivo:").grid(row=5, column=0, sticky=tk.W, pady=(10, 5))
        
        self.file_path = tk.StringVar()
        file_frame = ttk.Frame(main_frame)
        file_frame.grid(row=6, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=(0, 10))
        
        ttk.Entry(file_frame, textvariable=self.file_path, width=40).grid(row=0, column=0, sticky=(tk.W, tk.E))
        ttk.Button(file_frame, text="Buscar Archivo", 
                  command=self.browse_file).grid(row=0, column=1, padx=(10, 0))
        ttk.Button(file_frame, text="Decodificar Archivo", 
                  command=self.decode_from_file).grid(row=0, column=2, padx=(10, 0))
        
        # Botón para guardar
        buttons_frame = ttk.Frame(main_frame)
        buttons_frame.grid(row=7, column=0, columnspan=3, pady=(10, 5))
        
        ttk.Button(buttons_frame, text="Guardar Archivo Binario", 
                  command=self.save_binary_file_dialog).grid(row=0, column=0)
        
        # Área de salida
        ttk.Label(main_frame, text="Resultados y Estado:").grid(row=8, column=0, sticky=tk.W, pady=(20, 5))
        
        self.output_text = scrolledtext.ScrolledText(main_frame, width=80, height=20, wrap=tk.WORD)
        self.output_text.grid(row=9, column=0, columnspan=3, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Barra de estado
        self.status_var = tk.StringVar(value="Listo para decodificar")
        status_bar = ttk.Label(main_frame, textvariable=self.status_var, relief=tk.SUNKEN)
        status_bar.grid(row=10, column=0, columnspan=3, sticky=(tk.W, tk.E), pady=(10, 0))
        
        # Configurar pesos de grid
        main_frame.columnconfigure(0, weight=1)
        main_frame.rowconfigure(9, weight=1)
        file_frame.columnconfigure(0, weight=1)
        
        self.clear_output()
    
    def browse_file(self):
        """Abre diálogo para seleccionar archivo"""
        filename = filedialog.askopenfilename(
            title="Seleccionar archivo de instrucciones",
            filetypes=[("Archivos de texto", "*.txt"), ("Todos los archivos", "*.*")]
        )
        if filename:
            self.file_path.set(filename)
            self.update_status(f"Archivo seleccionado: {os.path.basename(filename)}")
    
    def parse_r_type(self, operands):
        """Parsea operandos para instrucciones tipo R"""
        if len(operands) != 3:
            raise ValueError("Se esperaban 3 operandos para instrucción tipo R")
        
        rd = self.parse_register(operands[0])
        rs = self.parse_register(operands[1])
        rt = self.parse_register(operands[2])
        
        return rs, rt, rd, 0  # shamt = 0
    
    def parse_register(self, reg_str):
        """Convierte string de registro a número"""
        reg_str = reg_str.strip().upper()
        
        # Verificar formato de registro
        if not reg_str.startswith('$'):
            raise ValueError(f"Formato de registro inválido: {reg_str}")
        
        if reg_str in self.register_map:
            return self.register_map[reg_str]
        
        # Intentar parsear números directos (como $10)
        try:
            reg_num = int(reg_str[1:])
            if 0 <= reg_num <= 31:
                return reg_num
            else:
                raise ValueError(f"Número de registro fuera de rango: {reg_str}")
        except ValueError:
            raise ValueError(f"Registro no reconocido: {reg_str}")
    
    def clean_line(self, line):
        """Limpia línea de comentarios y espacios extra"""
        if '#' in line:
            line = line.split('#')[0]
        return line.strip()
    
    def encode_instruction(self, instruction, operands):
        """Codifica instrucción a binario MIPS32"""
        if instruction not in self.instruction_table:
            raise ValueError(f"Instrucción no soportada: {instruction}")
        
        instr_info = self.instruction_table[instruction]
        
        if instr_info['type'] == 'R':
            rs, rt, rd, shamt = instr_info['operand_parser'](operands)
            
            # Construir instrucción de 32 bits
            encoded = (instr_info['opcode'] << 26) | (rs << 21) | (rt << 16) | \
                     (rd << 11) | (shamt << 6) | instr_info['funct']
            
            return encoded
        else:
            raise ValueError(f"Tipo de instrucción no implementado: {instr_info['type']}")
    
    def to_big_endian_bytes(self, instruction_32bit):
        """Convierte instrucción de 32 bits a bytes Big Endian"""
        # Usar struct para empaquetar en Big Endian
        return struct.pack('>I', instruction_32bit)
    
    def decode_single_instruction(self, line, line_num=None):
        """Decodifica una sola instrucción"""
        try:
            line = self.clean_line(line)
            if not line:
                return None, "Línea vacía o comentario"
            
            parts = [part.strip() for part in line.replace(',', ' ').split()]
            if not parts:
                return None, "Línea vacía"
            
            instruction = parts[0].upper()
            operands = parts[1:]
            
            # Verificar si la instrucción existe
            if instruction not in self.instruction_table:
                raise ValueError(f"Instrucción no soportada: {instruction}")
            
            # Codificar instrucción
            encoded = self.encode_instruction(instruction, operands)
            
            # Convertir a bytes Big Endian
            bytes_data = self.to_big_endian_bytes(encoded)
            
            # Formatear resultado
            line_info = f"Línea {line_num}: " if line_num is not None else ""
            result = {
                'original': line,
                'encoded_hex': f"{encoded:08X}",
                'bytes_hex': ' '.join(f"{b:02X}" for b in bytes_data),
                'bytes_bin': ' '.join(f"{b:08b}" for b in bytes_data),
                'bytes_data': bytes_data,
                'binary_string': ''.join(f"{b:08b}" for b in bytes_data)  # Cadena binaria continua
            }
            
            return result, f"{line_info}✓ {line} -> {result['encoded_hex']}"
            
        except Exception as e:
            line_info = f"Línea {line_num}: " if line_num is not None else ""
            return None, f"{line_info}✗ Error: {str(e)}"
    
    def decode_from_text(self):
        """Decodifica instrucción desde campo de texto"""
        line = self.manual_entry.get().strip()
        if not line:
            messagebox.showwarning("Advertencia", "Por favor ingrese una instrucción")
            return
        
        result, message = self.decode_single_instruction(line)
        
        self.output_text.insert(tk.END, message + '\n')
        self.output_text.see(tk.END)
        
        if result:
            # Agregar a la lista de instrucciones binarias
            self.binary_strings.append(result['binary_string'])
            self.show_detailed_result(result)
            self.update_status("Instrucción decodificada exitosamente")
        else:
            self.update_status("Error en decodificación")
    
    def open_file_location(self, filepath):
        """Abre la ubicación del archivo en el explorador del sistema"""
        try:
            if platform.system() == "Windows":
                # Windows: abrir carpeta y seleccionar archivo
                subprocess.run(['explorer', '/select,', os.path.normpath(filepath)])
            elif platform.system() == "Darwin":  # macOS
                # macOS: abrir carpeta en Finder
                subprocess.run(['open', '-R', filepath])
            else:  # Linux y otros Unix
                # Linux: abrir carpeta en el administrador de archivos
                subprocess.run(['xdg-open', os.path.dirname(filepath)])
            return True
        except Exception as e:
            print(f"Error al abrir ubicación: {e}")
            return False
    
    def decode_from_file(self):
        """Decodifica instrucciones desde archivo"""
        filename = self.file_path.get()
        if not filename or not os.path.exists(filename):
            messagebox.showerror("Error", "Por favor seleccione un archivo válido")
            return
        
        try:
            with open(filename, 'r', encoding='utf-8') as file:
                lines = file.readlines()
            
            self.clear_output()
            self.output_text.insert(tk.END, f"Procesando archivo: {os.path.basename(filename)}\n")
            self.output_text.insert(tk.END, "=" * 50 + '\n')
            
            # Reiniciar la lista de instrucciones binarias
            self.binary_strings = []
            success_count = 0
            error_count = 0
            
            for i, line in enumerate(lines, 1):
                result, message = self.decode_single_instruction(line, i)
                self.output_text.insert(tk.END, message + '\n')
                self.output_text.see(tk.END)
                
                if result:
                    self.binary_strings.append(result['binary_string'])
                    success_count += 1
                else:
                    error_count += 1
            
            # Mostrar resultados
            self.output_text.insert(tk.END, "=" * 50 + '\n')
            self.output_text.insert(tk.END, 
                f"Procesamiento completado: {success_count} éxitos, {error_count} errores\n")
            
            if self.binary_strings:
                self.output_text.insert(tk.END, "Use el botón 'Guardar Archivo Binario' para guardar los resultados\n")
                
                # Mostrar ejemplo del contenido del archivo binario
                self.output_text.insert(tk.END, "\nContenido que se guardará:\n")
                for i, binary_str in enumerate(self.binary_strings, 1):
                    self.output_text.insert(tk.END, f"{binary_str}\n")
                
                self.update_status(f"Procesamiento completado: {success_count} instrucciones listas para guardar")
            else:
                self.output_text.insert(tk.END, "No se generaron instrucciones válidas\n")
                self.output_text.insert(tk.END, "Puede guardar un archivo vacío usando el botón 'Guardar Archivo Binario'\n")
                self.update_status("Procesamiento completado sin instrucciones válidas")
            
            self.output_text.see(tk.END)
            
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo procesar el archivo: {str(e)}")
            self.update_status("Error procesando archivo")
    
    def save_binary_file_dialog(self):
        """Abre diálogo para guardar el archivo binario"""
        # Siempre permitir guardar, incluso si no hay instrucciones
        
        # Sugerir nombre por defecto
        default_filename = f"instrucciones_binario_{datetime.datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
        
        filename = filedialog.asksaveasfilename(
            title="Guardar archivo binario",
            defaultextension=".txt",
            filetypes=[("Archivos de texto", "*.txt"), ("Todos los archivos", "*.*")],
            initialfile=default_filename
        )
        
        if filename:
            success = self.save_binary_file(filename, self.binary_strings)
            if success:
                # Limpiar la pantalla después de guardar
                self.clear_output_after_save()
    
    def save_binary_file(self, filename, binary_strings):
        """Guarda SOLO los números binarios en un archivo de texto"""
        try:
            # Guardar SOLO los números binarios, uno por línea
            with open(filename, 'w', encoding='utf-8') as file:
                for binary_str in binary_strings:
                    file.write(binary_str + '\n')  # Solo el número binario, nada más
            
            return True
                
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo guardar el archivo: {str(e)}")
            self.update_status("Error guardando archivo")
            return False
    
    def clear_output_after_save(self):
        """Limpia la pantalla después de guardar el archivo"""
        self.clear_output()
        
        # Mostrar mensaje de confirmación
        self.output_text.insert(tk.END, "✓ Archivo guardado exitosamente\n")
        self.output_text.insert(tk.END, "✓ Pantalla limpiada\n")
        self.output_text.insert(tk.END, "=" * 50 + '\n')
        self.output_text.insert(tk.END, "Listo para nuevas instrucciones...\n")
        
        # Limpiar también la lista de instrucciones binarias
        self.binary_strings = []
        
        # Limpiar el campo de entrada manual
        self.manual_entry.delete(0, tk.END)
        
        # Limpiar la ruta del archivo
        self.file_path.set("")
        
        self.update_status("Archivo guardado y pantalla limpiada - Listo para nuevas instrucciones")
    
    def show_detailed_result(self, result):
        """Muestra resultado detallado en el área de texto"""
        self.output_text.insert(tk.END, "Detalles de codificación:\n")
        self.output_text.insert(tk.END, f"  Original: {result['original']}\n")
        self.output_text.insert(tk.END, f"  Hexadecimal: {result['encoded_hex']}\n")
        self.output_text.insert(tk.END, f"  Bytes (Hex): {result['bytes_hex']}\n")
        self.output_text.insert(tk.END, f"  Bytes (Bin): {result['bytes_bin']}\n")
        self.output_text.insert(tk.END, f"  Binario continuo: {result['binary_string']}\n")
        self.output_text.insert(tk.END, "-" * 40 + '\n')
    
    def clear_output(self):
        """Limpia el área de salida"""
        self.output_text.delete(1.0, tk.END)
        self.output_text.insert(tk.END, "Resultados de decodificación:\n")
        self.output_text.insert(tk.END, "=" * 50 + '\n')
    
    def update_status(self, message):
        """Actualiza la barra de estado"""
        self.status_var.set(message)
        self.root.update_idletasks()
    
    def run(self):
        """Ejecuta la aplicación"""
        self.root.mainloop()

if __name__ == "__main__":
    app = MIPSDecoder()
    app.run()