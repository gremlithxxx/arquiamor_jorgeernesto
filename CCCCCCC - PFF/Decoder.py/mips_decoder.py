#!/usr/bin/env python3
# ============================================================================
# Decodificador MIPS32 - Ensamblador a Binario
# ============================================================================
# Proyecto Final - Arquitectura de Computadoras
# Universidad de Guadalajara - CUCEI
#
# Convierte código ensamblador MIPS a formato binario de 32 bits
# para precargar en la memoria de instrucciones del procesador.
#
# Instrucciones soportadas:
#   R-TYPE: ADD, SUB, AND, OR, SLT
#   I-TYPE: ADDI, ANDI, ORI, XORI, SLTI, BEQ, LW, SW
#   J-TYPE: J
#   Pseudo: NOP
# ============================================================================

import tkinter as tk
from tkinter import ttk, scrolledtext, filedialog, messagebox
import re
import os

class MIPSDecoder:
    """Clase principal del decodificador MIPS"""
    
    def __init__(self):
        # Tabla de registros MIPS
        self.registers = {
            '$zero': 0, '$0': 0,
            '$at': 1, '$1': 1,
            '$v0': 2, '$v1': 3, '$2': 2, '$3': 3,
            '$a0': 4, '$a1': 5, '$a2': 6, '$a3': 7,
            '$4': 4, '$5': 5, '$6': 6, '$7': 7,
            '$t0': 8, '$t1': 9, '$t2': 10, '$t3': 11,
            '$t4': 12, '$t5': 13, '$t6': 14, '$t7': 15,
            '$8': 8, '$9': 9, '$10': 10, '$11': 11,
            '$12': 12, '$13': 13, '$14': 14, '$15': 15,
            '$s0': 16, '$s1': 17, '$s2': 18, '$s3': 19,
            '$s4': 20, '$s5': 21, '$s6': 22, '$s7': 23,
            '$16': 16, '$17': 17, '$18': 18, '$19': 19,
            '$20': 20, '$21': 21, '$22': 22, '$23': 23,
            '$t8': 24, '$t9': 25,
            '$24': 24, '$25': 25,
            '$k0': 26, '$k1': 27,
            '$26': 26, '$27': 27,
            '$gp': 28, '$28': 28,
            '$sp': 29, '$29': 29,
            '$fp': 30, '$30': 30,
            '$ra': 31, '$31': 31
        }
        
        # Opcodes para instrucciones R-type (opcode = 000000)
        self.r_type_funct = {
            'add':  0b100000,  # 32
            'sub':  0b100010,  # 34
            'and':  0b100100,  # 36
            'or':   0b100101,  # 37
            'slt':  0b101010,  # 42
            'sll':  0b000000,  # 0
            'srl':  0b000010,  # 2
        }
        
        # Opcodes para instrucciones I-type
        self.i_type_opcode = {
            'addi': 0b001000,  # 8
            'andi': 0b001100,  # 12
            'ori':  0b001101,  # 13
            'xori': 0b001110,  # 14
            'slti': 0b001010,  # 10
            'beq':  0b000100,  # 4
            'bne':  0b000101,  # 5
            'lw':   0b100011,  # 35
            'sw':   0b101011,  # 43
            'lui':  0b001111,  # 15
        }
        
        # Opcodes para instrucciones J-type
        self.j_type_opcode = {
            'j':    0b000010,  # 2
            'jal':  0b000011,  # 3
        }
        
        self.labels = {}
        self.errors = []
        
    def parse_register(self, reg_str):
        """Convierte string de registro a número"""
        reg_str = reg_str.strip().lower()
        if reg_str in self.registers:
            return self.registers[reg_str]
        raise ValueError(f"Registro inválido: {reg_str}")
    
    def parse_immediate(self, imm_str):
        """Convierte string de inmediato a número"""
        imm_str = imm_str.strip()
        try:
            if imm_str.startswith('0x') or imm_str.startswith('0X'):
                return int(imm_str, 16)
            elif imm_str.startswith('0b') or imm_str.startswith('0B'):
                return int(imm_str, 2)
            else:
                return int(imm_str)
        except ValueError:
            raise ValueError(f"Inmediato inválido: {imm_str}")
    
    def to_twos_complement(self, value, bits):
        """Convierte a complemento a 2"""
        if value < 0:
            value = (1 << bits) + value
        return value & ((1 << bits) - 1)
    
    def encode_r_type(self, parts, line_num):
        """Codifica instrucción R-type"""
        instr = parts[0].lower()
        
        if instr == 'nop':
            return 0x00000000
        
        if instr in ['sll', 'srl']:
            # Formato: sll rd, rt, shamt
            rd = self.parse_register(parts[1])
            rt = self.parse_register(parts[2])
            shamt = self.parse_immediate(parts[3])
            rs = 0
        else:
            # Formato: add rd, rs, rt
            rd = self.parse_register(parts[1])
            rs = self.parse_register(parts[2])
            rt = self.parse_register(parts[3])
            shamt = 0
        
        funct = self.r_type_funct[instr]
        
        # Formato: opcode(6) | rs(5) | rt(5) | rd(5) | shamt(5) | funct(6)
        instruction = (0 << 26) | (rs << 21) | (rt << 16) | (rd << 11) | (shamt << 6) | funct
        return instruction
    
    def encode_i_type(self, parts, line_num, current_addr):
        """Codifica instrucción I-type"""
        instr = parts[0].lower()
        opcode = self.i_type_opcode[instr]
        
        if instr in ['lw', 'sw']:
            # Formato: lw rt, offset(rs)
            rt = self.parse_register(parts[1])
            # Parsear offset(rs)
            match = re.match(r'(-?\d+)\((\$\w+)\)', parts[2])
            if match:
                offset = self.parse_immediate(match.group(1))
                rs = self.parse_register(match.group(2))
            else:
                raise ValueError(f"Formato inválido para {instr}: {parts[2]}")
            imm = self.to_twos_complement(offset, 16)
            
        elif instr in ['beq', 'bne']:
            # Formato: beq rs, rt, label
            rs = self.parse_register(parts[1])
            rt = self.parse_register(parts[2])
            label = parts[3].strip()
            
            if label in self.labels:
                target_addr = self.labels[label]
                # Offset relativo al PC+4 (en palabras)
                offset = (target_addr - (current_addr + 4)) // 4
                imm = self.to_twos_complement(offset, 16)
            else:
                # Intentar como número
                try:
                    imm = self.to_twos_complement(self.parse_immediate(label), 16)
                except:
                    raise ValueError(f"Etiqueta no encontrada: {label}")
                    
        elif instr == 'lui':
            # Formato: lui rt, imm
            rt = self.parse_register(parts[1])
            rs = 0
            imm = self.to_twos_complement(self.parse_immediate(parts[2]), 16)
            
        else:
            # Formato: addi rt, rs, imm
            rt = self.parse_register(parts[1])
            rs = self.parse_register(parts[2])
            imm = self.to_twos_complement(self.parse_immediate(parts[3]), 16)
        
        # Formato: opcode(6) | rs(5) | rt(5) | immediate(16)
        instruction = (opcode << 26) | (rs << 21) | (rt << 16) | imm
        return instruction
    
    def encode_j_type(self, parts, line_num):
        """Codifica instrucción J-type"""
        instr = parts[0].lower()
        opcode = self.j_type_opcode[instr]
        
        label = parts[1].strip()
        if label in self.labels:
            address = self.labels[label] // 4  # Dirección en palabras
        else:
            try:
                address = self.parse_immediate(label) // 4
            except:
                raise ValueError(f"Etiqueta no encontrada: {label}")
        
        # Formato: opcode(6) | address(26)
        instruction = (opcode << 26) | (address & 0x03FFFFFF)
        return instruction
    
    def first_pass(self, code):
        """Primera pasada: recolectar etiquetas"""
        self.labels = {}
        address = 0
        lines = code.strip().split('\n')
        
        for line in lines:
            # Remover comentarios
            line = re.sub(r'#.*$', '', line).strip()
            if not line:
                continue
            
            # Buscar etiquetas
            if ':' in line:
                parts = line.split(':')
                label = parts[0].strip()
                self.labels[label] = address
                line = ':'.join(parts[1:]).strip()
                
            if line:  # Si hay instrucción después de la etiqueta
                address += 4
    
    def second_pass(self, code):
        """Segunda pasada: codificar instrucciones"""
        instructions = []
        self.errors = []
        address = 0
        lines = code.strip().split('\n')
        
        for line_num, line in enumerate(lines, 1):
            original_line = line
            # Remover comentarios
            line = re.sub(r'#.*$', '', line).strip()
            if not line:
                continue
            
            # Remover etiquetas
            if ':' in line:
                line = line.split(':', 1)[1].strip()
            
            if not line:
                continue
            
            try:
                # Parsear instrucción
                # Separar por espacios y comas
                parts = re.split(r'[,\s]+', line)
                parts = [p.strip() for p in parts if p.strip()]
                
                if not parts:
                    continue
                
                instr = parts[0].lower()
                
                if instr == 'nop':
                    binary = 0x00000000
                elif instr in self.r_type_funct:
                    binary = self.encode_r_type(parts, line_num)
                elif instr in self.i_type_opcode:
                    binary = self.encode_i_type(parts, line_num, address)
                elif instr in self.j_type_opcode:
                    binary = self.encode_j_type(parts, line_num)
                else:
                    raise ValueError(f"Instrucción desconocida: {instr}")
                
                instructions.append({
                    'address': address,
                    'binary': binary,
                    'line': line_num,
                    'source': original_line.strip()
                })
                address += 4
                
            except Exception as e:
                self.errors.append(f"Línea {line_num}: {str(e)}")
        
        return instructions
    
    def assemble(self, code):
        """Ensambla código MIPS"""
        self.first_pass(code)
        return self.second_pass(code)
    
    def format_binary(self, value):
        """Formatea valor como binario de 32 bits"""
        return format(value, '032b')
    
    def format_hex(self, value):
        """Formatea valor como hexadecimal"""
        return format(value, '08x')


class MIPSDecoderGUI:
    """Interfaz gráfica del decodificador MIPS"""
    
    def __init__(self, root):
        self.root = root
        self.root.title("Decodificador MIPS32 - Arquitectura de Computadoras")
        self.root.geometry("1200x800")
        
        self.decoder = MIPSDecoder()
        self.setup_ui()
        self.load_example()
    
    def setup_ui(self):
        """Configura la interfaz de usuario"""
        
        # Frame principal
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Configurar expansión
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(0, weight=1)
        main_frame.columnconfigure(1, weight=1)
        main_frame.rowconfigure(1, weight=1)
        
        # ===== Título =====
        title_label = ttk.Label(main_frame, text="🖥️ Decodificador MIPS32", 
                               font=('Arial', 16, 'bold'))
        title_label.grid(row=0, column=0, columnspan=2, pady=(0, 10))
        
        # ===== Frame izquierdo: Entrada =====
        left_frame = ttk.LabelFrame(main_frame, text="Código Ensamblador MIPS", padding="5")
        left_frame.grid(row=1, column=0, sticky=(tk.W, tk.E, tk.N, tk.S), padx=(0, 5))
        left_frame.columnconfigure(0, weight=1)
        left_frame.rowconfigure(0, weight=1)
        
        self.input_text = scrolledtext.ScrolledText(left_frame, width=50, height=25,
                                                     font=('Consolas', 10))
        self.input_text.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # ===== Frame derecho: Salida =====
        right_frame = ttk.LabelFrame(main_frame, text="Código Binario (32 bits)", padding="5")
        right_frame.grid(row=1, column=1, sticky=(tk.W, tk.E, tk.N, tk.S), padx=(5, 0))
        right_frame.columnconfigure(0, weight=1)
        right_frame.rowconfigure(0, weight=1)
        
        self.output_text = scrolledtext.ScrolledText(right_frame, width=60, height=25,
                                                      font=('Consolas', 10))
        self.output_text.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # ===== Frame de botones =====
        button_frame = ttk.Frame(main_frame, padding="5")
        button_frame.grid(row=2, column=0, columnspan=2, pady=10)
        
        ttk.Button(button_frame, text="▶ Ensamblar", command=self.assemble,
                  width=15).grid(row=0, column=0, padx=5)
        ttk.Button(button_frame, text="📂 Cargar Archivo", command=self.load_file,
                  width=15).grid(row=0, column=1, padx=5)
        ttk.Button(button_frame, text="💾 Guardar TXT", command=self.save_txt,
                  width=15).grid(row=0, column=2, padx=5)
        ttk.Button(button_frame, text="💾 Guardar BIN", command=self.save_bin,
                  width=15).grid(row=0, column=3, padx=5)
        ttk.Button(button_frame, text="🗑️ Limpiar", command=self.clear,
                  width=15).grid(row=0, column=4, padx=5)
        ttk.Button(button_frame, text="📋 Ejemplo", command=self.load_example,
                  width=15).grid(row=0, column=5, padx=5)
        
        # ===== Frame de formato de salida =====
        format_frame = ttk.LabelFrame(main_frame, text="Formato de Salida", padding="5")
        format_frame.grid(row=3, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=5)
        
        self.format_var = tk.StringVar(value="binary")
        ttk.Radiobutton(format_frame, text="Binario", variable=self.format_var,
                       value="binary", command=self.assemble).grid(row=0, column=0, padx=10)
        ttk.Radiobutton(format_frame, text="Hexadecimal", variable=self.format_var,
                       value="hex", command=self.assemble).grid(row=0, column=1, padx=10)
        ttk.Radiobutton(format_frame, text="Ambos", variable=self.format_var,
                       value="both", command=self.assemble).grid(row=0, column=2, padx=10)
        
        # ===== Frame de estado =====
        status_frame = ttk.Frame(main_frame)
        status_frame.grid(row=4, column=0, columnspan=2, sticky=(tk.W, tk.E))
        
        self.status_label = ttk.Label(status_frame, text="Listo", font=('Arial', 10))
        self.status_label.grid(row=0, column=0, sticky=tk.W)
        
        # ===== Información de instrucciones =====
        info_frame = ttk.LabelFrame(main_frame, text="Instrucciones Soportadas", padding="5")
        info_frame.grid(row=5, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=5)
        
        info_text = ("R-TYPE: add, sub, and, or, slt  |  "
                    "I-TYPE: addi, andi, ori, xori, slti, beq, bne, lw, sw, lui  |  "
                    "J-TYPE: j, jal  |  PSEUDO: nop")
        ttk.Label(info_frame, text=info_text, font=('Consolas', 9)).grid(row=0, column=0)
    
    def assemble(self):
        """Ensambla el código y muestra resultado"""
        code = self.input_text.get("1.0", tk.END)
        
        if not code.strip():
            self.status_label.config(text="⚠️ No hay código para ensamblar")
            return
        
        instructions = self.decoder.assemble(code)
        
        self.output_text.delete("1.0", tk.END)
        
        if self.decoder.errors:
            self.output_text.insert(tk.END, "=== ERRORES ===\n")
            for error in self.decoder.errors:
                self.output_text.insert(tk.END, f"❌ {error}\n")
            self.output_text.insert(tk.END, "\n")
            self.status_label.config(text=f"❌ {len(self.decoder.errors)} error(es) encontrado(s)")
        
        if instructions:
            # Encabezado
            format_type = self.format_var.get()
            self.output_text.insert(tk.END, "// Código generado por Decodificador MIPS32\n")
            self.output_text.insert(tk.END, "// Proyecto Final - Arquitectura de Computadoras\n")
            self.output_text.insert(tk.END, f"// Total: {len(instructions)} instrucciones\n")
            self.output_text.insert(tk.END, "// " + "="*60 + "\n\n")
            
            # Solo binario para archivo de memoria
            self.output_text.insert(tk.END, "// === FORMATO PARA MEMORIA (instrucciones.txt) ===\n")
            for instr in instructions:
                self.output_text.insert(tk.END, f"{self.decoder.format_binary(instr['binary'])}\n")
            
            self.output_text.insert(tk.END, "\n// === DETALLE DE INSTRUCCIONES ===\n")
            
            for instr in instructions:
                addr = f"0x{instr['address']:04X}"
                binary = self.decoder.format_binary(instr['binary'])
                hex_val = self.decoder.format_hex(instr['binary'])
                source = instr['source']
                
                if format_type == "binary":
                    self.output_text.insert(tk.END, 
                        f"// {addr}: {source}\n{binary}\n\n")
                elif format_type == "hex":
                    self.output_text.insert(tk.END, 
                        f"// {addr}: {source}\n{hex_val}\n\n")
                else:  # both
                    self.output_text.insert(tk.END, 
                        f"// {addr}: {source}\n// BIN: {binary}\n// HEX: {hex_val}\n\n")
            
            if not self.decoder.errors:
                self.status_label.config(text=f"✅ Ensamblado exitoso: {len(instructions)} instrucciones")
    
    def load_file(self):
        """Carga archivo .asm o .txt"""
        filepath = filedialog.askopenfilename(
            title="Abrir archivo de ensamblador",
            filetypes=[("Archivos ASM", "*.asm"), ("Archivos TXT", "*.txt"), 
                      ("Todos los archivos", "*.*")]
        )
        if filepath:
            try:
                with open(filepath, 'r') as f:
                    content = f.read()
                self.input_text.delete("1.0", tk.END)
                self.input_text.insert("1.0", content)
                self.status_label.config(text=f"📂 Archivo cargado: {os.path.basename(filepath)}")
            except Exception as e:
                messagebox.showerror("Error", f"No se pudo cargar el archivo:\n{str(e)}")
    
    def save_txt(self):
        """Guarda salida en archivo .txt"""
        filepath = filedialog.asksaveasfilename(
            title="Guardar como TXT",
            defaultextension=".txt",
            filetypes=[("Archivos TXT", "*.txt")]
        )
        if filepath:
            try:
                # Obtener solo las líneas binarias
                code = self.input_text.get("1.0", tk.END)
                instructions = self.decoder.assemble(code)
                
                with open(filepath, 'w') as f:
                    for instr in instructions:
                        f.write(f"{self.decoder.format_binary(instr['binary'])}\n")
                
                self.status_label.config(text=f"💾 Guardado: {os.path.basename(filepath)}")
                messagebox.showinfo("Éxito", f"Archivo guardado:\n{filepath}")
            except Exception as e:
                messagebox.showerror("Error", f"No se pudo guardar:\n{str(e)}")
    
    def save_bin(self):
        """Guarda salida en formato binario"""
        filepath = filedialog.asksaveasfilename(
            title="Guardar como BIN",
            defaultextension=".bin",
            filetypes=[("Archivos BIN", "*.bin")]
        )
        if filepath:
            try:
                code = self.input_text.get("1.0", tk.END)
                instructions = self.decoder.assemble(code)
                
                with open(filepath, 'wb') as f:
                    for instr in instructions:
                        # Big endian (MIPS)
                        f.write(instr['binary'].to_bytes(4, byteorder='big'))
                
                self.status_label.config(text=f"💾 Guardado: {os.path.basename(filepath)}")
                messagebox.showinfo("Éxito", f"Archivo binario guardado:\n{filepath}")
            except Exception as e:
                messagebox.showerror("Error", f"No se pudo guardar:\n{str(e)}")
    
    def clear(self):
        """Limpia campos"""
        self.input_text.delete("1.0", tk.END)
        self.output_text.delete("1.0", tk.END)
        self.status_label.config(text="🗑️ Campos limpiados")
    
    def load_example(self):
        """Carga programa de ejemplo"""
        example = """# ============================================
# Programa: Búsqueda del Máximo en un Arreglo
# ============================================
# Busca el valor máximo en un arreglo de 5 elementos
# almacenados en memoria.
#
# Registros utilizados:
#   $t0 - Dirección base del arreglo
#   $t1 - Contador (índice)
#   $t2 - Límite del arreglo
#   $t3 - Valor actual del elemento
#   $t4 - Valor máximo encontrado
#   $t5 - Resultado de comparación
# ============================================

main:
    # Inicializar registros
    addi $t0, $zero, 0      # $t0 = 0 (dirección base)
    addi $t1, $zero, 0      # $t1 = 0 (contador)
    addi $t2, $zero, 5      # $t2 = 5 (tamaño del arreglo)
    
    # Cargar primer elemento como máximo inicial
    lw   $t4, 0($t0)        # $t4 = mem[0] (máximo inicial)
    addi $t1, $t1, 1        # contador++

loop:
    # Verificar si terminamos
    beq  $t1, $t2, end      # if (contador == límite) goto end
    
    # Calcular dirección del elemento actual
    # offset = contador * 4 (simulado con sumas)
    add  $t5, $t1, $t1      # $t5 = contador * 2
    add  $t5, $t5, $t5      # $t5 = contador * 4
    add  $t5, $t0, $t5      # $t5 = base + offset
    
    # Cargar elemento actual
    lw   $t3, 0($t5)        # $t3 = mem[base + offset]
    
    # Comparar con máximo actual
    slt  $t5, $t4, $t3      # $t5 = (máximo < actual) ? 1 : 0
    beq  $t5, $zero, skip   # if (máximo >= actual) skip
    
    # Nuevo máximo encontrado
    add  $t4, $t3, $zero    # máximo = actual

skip:
    addi $t1, $t1, 1        # contador++
    j    loop               # repetir

end:
    # Guardar resultado en memoria
    sw   $t4, 20($t0)       # mem[20] = máximo
    
    # Fin del programa (loop infinito)
done:
    j    done
"""
        self.input_text.delete("1.0", tk.END)
        self.input_text.insert("1.0", example)
        self.status_label.config(text="📋 Programa de ejemplo cargado")


def main_cli():
    """Modo línea de comandos"""
    import sys
    
    if len(sys.argv) < 2:
        print("Uso: python mips_decoder.py <archivo.asm> [archivo_salida.txt]")
        print("     python mips_decoder.py --gui  (para interfaz gráfica)")
        sys.exit(1)
    
    if sys.argv[1] == '--gui':
        main_gui()
        return
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else "instrucciones.txt"
    
    decoder = MIPSDecoder()
    
    try:
        with open(input_file, 'r') as f:
            code = f.read()
        
        instructions = decoder.assemble(code)
        
        if decoder.errors:
            print("Errores encontrados:")
            for error in decoder.errors:
                print(f"  ❌ {error}")
        
        with open(output_file, 'w') as f:
            for instr in instructions:
                f.write(f"{decoder.format_binary(instr['binary'])}\n")
        
        print(f"✅ Archivo generado: {output_file}")
        print(f"   Total de instrucciones: {len(instructions)}")
        
    except FileNotFoundError:
        print(f"❌ Error: No se encontró el archivo '{input_file}'")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        sys.exit(1)


def main_gui():
    """Inicia interfaz gráfica"""
    root = tk.Tk()
    app = MIPSDecoderGUI(root)
    root.mainloop()


if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1 and sys.argv[1] != '--gui':
        main_cli()
    else:
        main_gui()
