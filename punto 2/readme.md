# Calculadora Aritmética con Lex y Yacc

Este proyecto implementa una calculadora básica de expresiones aritméticas usando **Lex** (`calc2.l`) y **Yacc** (`calc2.y`). Es capaz de analizar y evaluar expresiones como sumas, restas, multiplicaciones, divisiones y uso de paréntesis.

## 📂 Archivos

- `calc2.l`: archivo con reglas léxicas para identificar números y operadores.
- `calc2.y`: archivo con reglas gramaticales para evaluar expresiones.
- `entrada.txt`: archivo de entrada con expresiones matemáticas a evaluar.

## ✅ Requisitos

Asegúrate de tener instalados:

- `flex`
- `bison`
- `gcc`

Instalación rápida en distribuciones basadas en Debian:

```bash
sudo apt update
sudo apt install flex bison gcc

⚙️ Compilación

bison -d calc2.y
flex calc2.l
gcc calc2.tab.c lex.yy.c -o calc2


▶️ Ejecución

./calc2 < entrada.txt
