# Proyecto-final-Arquitectura-MIPS-Pipeline-Decodificador-en-Python

# Procesador MIPS Pipeline de 5 Etapas

##  Descripción

Implementación completa de un procesador MIPS de 32 bits con pipeline de 5 etapas en Verilog, desarrollado como proyecto final para la materia de Arquitectura de Computadoras.
Elaborado por:
López Hernández Emiliano Juan 
y
Huerta Romo Adolfo 

El proyecto incluye:
- **Procesador MIPS Pipeline** completo en Verilog
- **Decodificador Python** para convertir código ensamblador a binario
- **Programa de prueba** con algoritmo voraz (Greedy)

##  Arquitectura del Pipeline

```
┌─────┐    ┌─────┐    ┌─────┐    ┌─────┐    ┌─────┐
│ IF  │───▶│ ID  │───▶│ EX  │───▶│ MEM │───▶│ WB  │
└─────┘    └─────┘    └─────┘    └─────┘    └─────┘
    │          │          │          │
    ▼          ▼          ▼          ▼
 IF/ID      ID/EX     EX/MEM     MEM/WB
 Buffer     Buffer    Buffer     Buffer
```

### Las 5 Etapas:

| Etapa | Nombre | Función |
|-------|--------|---------|
| **IF** | Instruction Fetch | Busca la instrucción en memoria |
| **ID** | Instruction Decode | Decodifica y lee registros |
| **EX** | Execute | Ejecuta operación en la ALU |
| **MEM** | Memory Access | Accede a memoria de datos |
| **WB** | Write Back | Escribe resultado en registro |

 Estructura del Proyecto

├── Módulos Verilog/
│   ├── MIPS_Pipeline.v        # Módulo TOP
│   ├── PC.v                   # Program Counter
│   ├── MemoriaInstrucciones.v # Memoria ROM
│   ├── MemoriaDatos.v         # Memoria RAM
│   ├── BancoRegistros.v       # 32 registros x 32 bits
│   ├── ALU.v                  # Unidad Aritmético-Lógica
│   ├── ALUControl.v           # Control de la ALU
│   ├── ControlUnit.v          # Unidad de Control
│   ├── SignExtend.v           # Extensor de signo
│   ├── ShiftLeft2.v           # Desplazador
│   ├── Mux.v                  # Multiplexores
│   ├── Adder.v                # Sumador
│   ├── IF_ID_Buffer.v         # Buffer IF/ID
│   ├── ID_EX_Buffer.v         # Buffer ID/EX
│   ├── EX_MEM_Buffer.v        # Buffer EX/MEM
│   └── MEM_WB_Buffer.v        # Buffer MEM/WB
│
├── Testbench/
│   └── tb_MIPS_Pipeline.v     # Testbench del pipeline
│
├── Programa/
│   ├── programa_voraz.asm     # Código ensamblador
│   ├── instrucciones.txt      # Código binario
│   └── datos.txt              # Datos de entrada
│
└── Decodificador/
    ├── mips_decoder.py        # Versión GUI
    ├── mips_decoder_cli.py    # Versión CLI
    └── Decodificador_MIPS.html# Versión Web
```

## Instrucciones Soportadas

### R-Type (opcode = 000000)
| Instrucción | Operación | Funct |
|-------------|-----------|-------|
| `add` | rd = rs + rt | 100000 |
| `sub` | rd = rs - rt | 100010 |
| `and` | rd = rs & rt | 100100 |
| `or` | rd = rs \| rt | 100101 |
| `slt` | rd = (rs < rt) ? 1 : 0 | 101010 |

### I-Type
| Instrucción | Opcode | Operacion |
|-------------|--------|-----------|
| `addi` | 001000 | rt = rs + imm |
| `andi` | 001100 | rt = rs & imm |
| `ori` | 001101 | rt = rs \| imm |
| `slti` | 001010 | rt = (rs < imm) ? 1 : 0 |
| `lw` | 100011 | rt = mem[rs + offset] |
| `sw` | 101011 | mem[rs + offset] = rt |
| `beq` | 000100 | if (rs == rt) branch |

### J-Type
| Instrucción | Opcode | Operación |
|-------------|--------|-----------|
| `j` | 000010 | PC = address |

## 🧪 Programa de Prueba: Algoritmo Voraz

El programa implementa el **Problema del Cambio de Monedas** usando estrategia Greedy:

```assembly
# Entrada: 47 centavos
# Monedas: [25, 10, 5, 1]
# Salida: 5 monedas (1×25 + 2×10 + 0×5 + 2×1)
```

### Características:
- Algoritmo **voraz (greedy)**
- **No recursivo** (usa bucles)
-  Usa instrucciones tipo **J** (jump)

## Cómo Ejecutar

### 1. Compilar en Icarus Verilog
```bash
iverilog -o mips_sim *.v
vvp mips_sim
```

### 2. Ver waveforms en GTKWave
```bash
gtkwave tb_MIPS_Pipeline.vcd
```

### 3. Compilar en ModelSim
```tcl
vlog *.v
vsim -voptargs=+acc work.tb_MIPS_Pipeline
add wave -r /*
run -all
```

## Usar el Decodificador

### Opción 1: GUI (requiere Python + tkinter)
```bash
python mips_decoder.py
```

### Opción 2: Linea de comandos
```bash
python mips_decoder_cli.py programa.asm instrucciones.txt
```

### Opción 3: Versión Web
Abrir `Decodificador_MIPS.html` en cualquier navegador.

El procesador está basado en la arquitectura del libro:
> Patterson, D. A., & Hennessy, J. L. (2014). *Computer Organization and Design: The Hardware/Software Interface* (5th ed.). Morgan Kaufmann. Figura 4.51.

## 📄 Licencia

Este proyecto es de uso académico.
