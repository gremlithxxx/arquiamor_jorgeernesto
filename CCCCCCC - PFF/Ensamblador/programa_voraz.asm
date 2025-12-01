# ============================================================
# ALGORITMO VORAZ: Problema del Cambio de Monedas
# ============================================================
# 
# DESCRIPCIÓN:
#   Dado un monto en centavos, calcula el MÍNIMO número de
#   monedas necesarias usando denominaciones [25, 10, 5, 1]
#
# ESTRATEGIA VORAZ (GREEDY):
#   En cada paso, elegir la moneda MÁS GRANDE posible.
#   Esta es la decisión "voraz" - siempre toma lo máximo
#   sin considerar el futuro.
#
# EJEMPLO:
#   Entrada: 47 centavos
#   Proceso voraz:
#     - 47 >= 25? Sí → usa 1 moneda de 25, quedan 22
#     - 22 >= 25? No
#     - 22 >= 10? Sí → usa 1 moneda de 10, quedan 12
#     - 12 >= 10? Sí → usa 1 moneda de 10, quedan 2
#     - 2 >= 10? No
#     - 2 >= 5? No
#     - 2 >= 1? Sí → usa 1 moneda de 1, queda 1
#     - 1 >= 1? Sí → usa 1 moneda de 1, queda 0
#   Salida: 5 monedas (1×25 + 2×10 + 0×5 + 2×1)
#
# REGISTROS:
#   $t0 - Monto restante (inicialmente 47)
#   $t1 - Contador total de monedas usadas
#   $t2 - Valor de moneda actual (25, 10, 5, 1)
#   $t3 - Contador de monedas de denominación actual
#   $t4 - Temporal para comparaciones
#   $t5 - Dirección en memoria para guardar resultados
#
# MEMORIA DE DATOS:
#   mem[0]  = 47  (monto a cambiar)
#   mem[4]  = 25  (denominación 1: quarters)
#   mem[8]  = 10  (denominación 2: dimes)
#   mem[12] = 5   (denominación 3: nickels)
#   mem[16] = 1   (denominación 4: pennies)
#   mem[20] = resultado: monedas de 25
#   mem[24] = resultado: monedas de 10
#   mem[28] = resultado: monedas de 5
#   mem[32] = resultado: monedas de 1
#   mem[36] = resultado: total de monedas
#
# CUMPLE REQUISITOS:
#   ✓ Algoritmo VORAZ (greedy) - siempre elige moneda más grande
#   ✓ NO recursivo - usa bucles iterativos
#   ✓ Usa instrucción J (j loop_moneda, j siguiente_denom, j halt)
#
# ============================================================

main:
    # Inicialización
    addi $t5, $zero, 0      # $t5 = 0 (dirección base)
    lw   $t0, 0($t5)        # $t0 = mem[0] = 47 (monto a cambiar)
    addi $t1, $zero, 0      # $t1 = 0 (contador total de monedas)
    addi $t6, $zero, 4      # $t6 = 4 (offset para denominaciones)
    
# ============================================================
# VORAZ: Procesar monedas de 25 (quarters)
# ============================================================
proceso_25:
    lw   $t2, 4($t5)        # $t2 = 25 (valor de quarter)
    addi $t3, $zero, 0      # $t3 = 0 (contador de quarters)

loop_25:
    slt  $t4, $t0, $t2      # $t4 = 1 si monto < 25
    bne  $t4, $zero, fin_25 # si monto < 25, terminar con quarters
    
    # DECISIÓN VORAZ: usar una moneda de 25
    sub  $t0, $t0, $t2      # monto = monto - 25
    addi $t3, $t3, 1        # contador_25++
    addi $t1, $t1, 1        # total_monedas++
    j    loop_25            # repetir (INSTRUCCIÓN J)

fin_25:
    sw   $t3, 20($t5)       # guardar cantidad de quarters en mem[20]

# ============================================================
# VORAZ: Procesar monedas de 10 (dimes)
# ============================================================
proceso_10:
    lw   $t2, 8($t5)        # $t2 = 10 (valor de dime)
    addi $t3, $zero, 0      # $t3 = 0 (contador de dimes)

loop_10:
    slt  $t4, $t0, $t2      # $t4 = 1 si monto < 10
    bne  $t4, $zero, fin_10 # si monto < 10, terminar con dimes
    
    # DECISIÓN VORAZ: usar una moneda de 10
    sub  $t0, $t0, $t2      # monto = monto - 10
    addi $t3, $t3, 1        # contador_10++
    addi $t1, $t1, 1        # total_monedas++
    j    loop_10            # repetir (INSTRUCCIÓN J)

fin_10:
    sw   $t3, 24($t5)       # guardar cantidad de dimes en mem[24]

# ============================================================
# VORAZ: Procesar monedas de 5 (nickels)
# ============================================================
proceso_5:
    lw   $t2, 12($t5)       # $t2 = 5 (valor de nickel)
    addi $t3, $zero, 0      # $t3 = 0 (contador de nickels)

loop_5:
    slt  $t4, $t0, $t2      # $t4 = 1 si monto < 5
    bne  $t4, $zero, fin_5  # si monto < 5, terminar con nickels
    
    # DECISIÓN VORAZ: usar una moneda de 5
    sub  $t0, $t0, $t2      # monto = monto - 5
    addi $t3, $t3, 1        # contador_5++
    addi $t1, $t1, 1        # total_monedas++
    j    loop_5             # repetir (INSTRUCCIÓN J)

fin_5:
    sw   $t3, 28($t5)       # guardar cantidad de nickels en mem[28]

# ============================================================
# VORAZ: Procesar monedas de 1 (pennies)
# ============================================================
proceso_1:
    lw   $t2, 16($t5)       # $t2 = 1 (valor de penny)
    addi $t3, $zero, 0      # $t3 = 0 (contador de pennies)

loop_1:
    slt  $t4, $t0, $t2      # $t4 = 1 si monto < 1
    bne  $t4, $zero, fin_1  # si monto < 1, terminar
    
    # DECISIÓN VORAZ: usar una moneda de 1
    sub  $t0, $t0, $t2      # monto = monto - 1
    addi $t3, $t3, 1        # contador_1++
    addi $t1, $t1, 1        # total_monedas++
    j    loop_1             # repetir (INSTRUCCIÓN J)

fin_1:
    sw   $t3, 32($t5)       # guardar cantidad de pennies en mem[32]

# ============================================================
# Guardar resultado final
# ============================================================
guardar_total:
    sw   $t1, 36($t5)       # guardar total de monedas en mem[36]

# ============================================================
# Fin del programa
# ============================================================
halt:
    j    halt               # loop infinito - fin (INSTRUCCIÓN J)
