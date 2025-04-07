%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);
extern FILE *yyin;

// Array para almacenar los valores de las variables (a-z)
double vars[26];

// Estructura para las instrucciones
typedef struct {
    char var;
    double val;
} Assignment;

// Lista enlazada para bloques de código
typedef struct BlockNode {
    struct BlockNode *next;
    int type;  // 1 = asignación, 2 = impresión, etc.
    void *data;
} BlockNode;

// Prototipos de funciones
BlockNode* create_assignment(char var, double val);
BlockNode* append_block(BlockNode *head, BlockNode *node);
void execute_block(BlockNode *block);

// NUEVA FUNCIÓN: Actualizar una variable inmediatamente
void update_var(char var, double val) {
    vars[var - 'a'] = val;
    printf("DEBUG: Variable %c actualizada a %g\n", var, val);
}
%}

%union {
    double val;
    char s;
    struct BlockNode *block;
}

%token <val> NUM
%token <s> VAR

%token IF THEN ELSE FI WHILE DO DONE

%type <val> expr
%type <block> stmt stmts

%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%%

program:
    | program line
    ;

line:
    stmt '\n'          { 
                          printf("DEBUG: Ejecutando línea\n"); 
                          if ($1) execute_block($1); 
                        }
    | '\n'
    ;

stmts:
    /* empty */        { $$ = NULL; }
    | stmts stmt '\n'  { 
                          printf("DEBUG: Agregando instrucción al bloque\n");
                          $$ = append_block($1, $2); 
                        }
    ;

stmt:
    expr                     { 
                               printf("DEBUG: Expresión evaluada a: %g\n", $1); 
                               $$ = NULL; 
                             }
    | VAR '=' expr           { 
                               printf("DEBUG: Asignación %c = %g (valor actual: %g)\n", 
                                     $1, $3, vars[$1 - 'a']);
                               
                               // CAMBIO: Actualizamos la variable inmediatamente para
                               // que esté disponible en los siguientes cálculos
                               update_var($1, $3);
                               
                               $$ = create_assignment($1, $3); 
                             }
    | IF expr THEN '\n' 
      stmts
      FI                     {
                               printf("DEBUG: Evaluando IF con condición: %g\n", $2);
                               if ($2 != 0) {
                                   printf("DEBUG: Condición verdadera, ejecutando bloque\n");
                                   $$ = $5;
                               } else {
                                   printf("DEBUG: Condición falsa, saltando bloque\n");
                                   $$ = NULL;
                               }
                             }
    | WHILE expr DO '\n' 
      stmts
      DONE                   { 
                               printf("DEBUG: Evaluando WHILE con condición: %g\n", $2);
                               // Implementación simple, solo ejecuta una vez si la condición es verdadera
                               if ($2 != 0) {
                                   printf("DEBUG: Condición verdadera, ejecutando bloque\n");
                                   $$ = $5;
                               } else {
                                   printf("DEBUG: Condición falsa, saltando bloque\n");
                                   $$ = NULL;
                               }
                             }
    ;

expr:
    NUM                { 
                         printf("DEBUG: Número: %g\n", $1);
                         $$ = $1; 
                       }
    | VAR              { 
                         // IMPORTANTE: Obtenemos el valor actual de la variable
                         // de inmediato y lo usamos para la expresión
                         $$ = vars[$1 - 'a'];
                         printf("DEBUG: Variable %c = %g\n", $1, $$);
                       }
    | expr '+' expr    { 
                         printf("DEBUG: Suma: %g + %g = %g\n", $1, $3, $1 + $3);
                         $$ = $1 + $3; 
                       }
    | expr '-' expr    { 
                         printf("DEBUG: Resta: %g - %g = %g\n", $1, $3, $1 - $3);
                         $$ = $1 - $3; 
                       }
    | expr '*' expr    { 
                         printf("DEBUG: Multiplicación: %g * %g = %g\n", $1, $3, $1 * $3);
                         $$ = $1 * $3; 
                       }
    | expr '/' expr    { 
                         if ($3 == 0) {
                           yyerror("División por cero");
                           $$ = 0;
                         } else {
                           printf("DEBUG: División: %g / %g = %g\n", $1, $3, $1 / $3);
                           $$ = $1 / $3;
                         }
                       }
    | '-' expr %prec UMINUS { 
                             printf("DEBUG: Negación: -%g = %g\n", $2, -$2);
                             $$ = -$2; 
                           }
    | '(' expr ')'     { 
                         printf("DEBUG: Paréntesis: (%g) = %g\n", $2, $2);
                         $$ = $2; 
                       }
    ;

%%

// Función para crear un nodo de asignación
BlockNode* create_assignment(char var, double val) {
    BlockNode *node = malloc(sizeof(BlockNode));
    Assignment *assign = malloc(sizeof(Assignment));
    
    assign->var = var;
    assign->val = val;
    
    node->type = 1;  // Tipo 1 = asignación
    node->data = assign;
    node->next = NULL;
    
    printf("DEBUG: Creado nodo de asignación: %c = %g\n", var, val);
    return node;
}

// Función para unir bloques de código
BlockNode* append_block(BlockNode *head, BlockNode *node) {
    if (!node) return head;
    if (!head) return node;
    
    BlockNode *current = head;
    while (current->next) {
        current = current->next;
    }
    current->next = node;
    printf("DEBUG: Bloque adjuntado a la lista\n");
    return head;
}

// Función para ejecutar un bloque de código
void execute_block(BlockNode *block) {
    printf("DEBUG: Iniciando ejecución de bloque\n");
    BlockNode *current = block;
    int instrucciones_ejecutadas = 0;
    
    while (current) {
        // Ejecutar según el tipo de instrucción
        if (current->type == 1) {  // Asignación
            Assignment *assign = (Assignment *)current->data;
            printf("DEBUG: Ejecutando asignación: %c = %g\n", assign->var, assign->val);
            
            // Actualizamos las variables - esto ahora es más para el output formal
            // que para la funcionalidad, ya que las variables se actualizan
            // durante el análisis sintáctico
            vars[assign->var - 'a'] = assign->val;
            printf("Let %c = %g\n", assign->var, assign->val);
            instrucciones_ejecutadas++;
        }
        
        BlockNode *temp = current;
        current = current->next;
        
        // Liberar memoria
        if (temp->data) free(temp->data);
        free(temp);
    }
    
    printf("DEBUG: Fin de ejecución de bloque. Instrucciones ejecutadas: %d\n", 
           instrucciones_ejecutadas);
}

// Modificar la función main para ejecutar instrucciones de bloques if/while
// de forma inmediata para evitar problemas con la evaluación retrasada
int main() {
    // Inicializar variables a 0
    for (int i = 0; i < 26; i++) {
        vars[i] = 0.0;
    }

    printf("DEBUG: Variables inicializadas\n");

    FILE *archivo = fopen("entrada.txt", "r");
    if (!archivo) {
        perror("No se pudo abrir el archivo");
        exit(1);
    }

    yyin = archivo;
    printf("Leyendo desde entrada.txt...\n");
    yyparse();
    fclose(archivo);
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
