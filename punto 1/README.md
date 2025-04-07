# Mini Intérprete en Lex y Yacc

Este proyecto es un intérprete básico implementado en **Lex** (`calc1.l`) y **Yacc** (`calc1.y`) que permite analizar y ejecutar un subconjunto muy simple de instrucciones, incluyendo asignaciones y estructuras condicionales (`if` ... `fi`).

## 📂 Archivos

- `calc1.l`: archivo de especificaciones léxicas (Lex/Flex).
- `calc1.y`: archivo de reglas gramaticales (Yacc/Bison).
- `entrada.txt`: archivo de entrada con código de prueba a interpretar.

## ✅ Requisitos

Necesitas tener instaladas las siguientes herramientas:

- `flex`
- `bison`
- `gcc`

Puedes instalarlas en sistemas basados en Debian (como Ubuntu) con:

---bash
sudo apt update
sudo apt install flex bison gcc

## compilación

bison -d calc1.y
flex calc1.l
gcc calc1.tab.c lex.yy.c -o calc1

bison -d calc1.y
flex calc1.l
gcc calc1.tab.c lex.yy.c -o calc1


## uso

./calc1 < entrada.txt
Donde entrada.txt contiene el código fuente del lenguaje.
