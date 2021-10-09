%{
#include <stdint.h>

#define LIST                concatenateString(yytext)
#define TOKEN(t)            { LIST; if (opt_tok) printf("<%s>\n", #t); }
#define TOKEN_CHAR(t)       { LIST; if (opt_tok) printf("<%c>\n", (t)); }
#define TOKEN_STRING(t, s)  { LIST; if (opt_tok) printf("<%s: %s>\n", #t, (s)); }
#define MAX_LINE_LENG       512

uint32_t line_num = 1;
static char buffer[MAX_LINE_LENG];

static uint32_t opt_src = 1;	// listing option
static uint32_t opt_tok = 1;	// token option
static char *buffer_ptr = buffer;

static void concatenateString(const char *yytext_ptr);

%}

digit	[0-9]
digits  digit+
letter	[a-zA-Z_]
nonzeroDecInt [1-9][0-9]*
nonZeroDec 0\.0|0\.{digit}*[1-9]|[1-9]{digit}*(\.{digits}[1-9])? 
nonZeroOctInt 0+[0-7]*[1-7][0-7]*  

%Start VARNAME STRMODE STRQUOTE STREND STROUT COMMENT 

%%

    /* Delimiter */
"," { TOKEN_CHAR('('); }
";" { TOKEN_CHAR(';'); }
":" { TOKEN_CHAR(':'); }
"(" { TOKEN_CHAR('('); }
")" { TOKEN_CHAR(')'); }
"[" { TOKEN_CHAR('['); }
"]" { TOKEN_CHAR(']'); }

    /* Arithmetic, Relational, and Logical Operators */
"+" { TOKEN_CHAR('+'); }
"-" { TOKEN_CHAR('-'); }
"*" { TOKEN_CHAR('*'); }
"/" { TOKEN_CHAR('/'); }
"mod" { TOKEN(mod); }
":=" { TOKEN(:=); }
"<" { TOKEN_CHAR('<'); }
"<=" { TOKEN(<=); }
"<>" { TOKEN(<>); }
">=" { TOKEN(>=); }
">" { TOKEN_CHAR('>'); }
"=" { TOKEN_CHAR('='); }
"and" { TOKEN(and); }
"or" { TOKEN(or); }
"not" { TOKEN(not); }
 
    /* Reserved Words */
"var" { TOKEN(KWvar); }
"def" { TOKEN(def); }
"array" { TOKEN(KWarray); }
"of" { TOKEN(KWof); }
"boolean" { TOKEN(KWboolean); }
"integer" { TOKEN(KWinteger); }
"real" { TOKEN(KWreal); }
"string" { TOKEN(KWstring); }
"true" { TOKEN(KWtrue); }
"false" { TOKEN(KWfalse); }
"while" { TOKEN(KWwhile); }
"do" { TOKEN(KWdo); }
"if" { TOKEN(KWif); }
"then" { TOKEN(KWthen); }
"else" { TOKEN(KWelse); }
"for" { TOKEN(KWfor); }
"to" { TOKEN(KWto); }
"begin" { TOKEN(KWbegin); }
"end" { TOKEN(KWend); }
"print" { TOKEN(KWprint); }
"read" { TOKEN(KWread); }
"return" { TOKEN(KWreturn); }

    /* Identifiers */
<VARNAME>{letter}([{letter}{digit}])* { TOKEN_STRING(id, yytext); BEGIN 0; }

    /* Integer Constants */
0+[0-7]+ { TOKEN_STRING(oct_integer, yytext); }
{digits} { TOKEN_STRING(integer, yytext); }

    /* Floating-Point Consants */
{digits}\.(0?|{digits}[1-9]/[^0]/) { TOKEN_STRING(float, yytext); } 

    /* Scientific Notations */
    /* base: nonzero oct/dec int OR nonzero dec float */
    /* exponent: dec int w/ optional sign */
    /* nonzero octal: 0+[0-7]*[1-7][0-7]* */
    /* nonzero dec int/float: 0\.0|0\.{digit}*[1-9]|[1-9]{digit}*(\.{digits}[1-9])? */
    /* exponent: dec int w/ optional sign */
({nonZeroDec}|{nonZeroOct})[Ee][\+-]?(0|[1-9][0-9]*) { TOKEN_STRING(scientific, yytext); }


    /* String Constants */
    /* TODO !! */
<STROUT>\" { TOKEN_STRING(string, yytext); BEGIN 0; }
<STREND>\" { BEGIN STROUT; }
<STRMODE>[^\n]*/\" { yymore(); BEGIN STREND; }
<STRMODE>[^\n]*/\"{2} { yymore(); BEGIN STRQUOTE; }
<STRQUOTE>\"/\" { ; }
<STRQUOTE>\"/[^\"] { yymore(); BEGIN STRMODE; }
\"/[^\n]*\" { BEGIN STRMODE; }

    /* Pseudocomments */
"//"&[ST][+-][^\n]* { 
    if (yytext[2] == 'S' && yytext[3] == '+' ) {
    	opt_src = 1;	    
    } 
    if (yytext[2] == 'S' && yytext[3] == '-' ) {
 	opt_src = 0;   
    } 
    if (yytext[2] == 'T' && yytext[3] == '+' ) {
    	opt_tok = 1;
    } 
    if (yytext[2] == 'T' && yytext[3] == '-' ) {
    	opt_tok = 0;
    } 
}

    /* Comments */
"//"[^\n]* { ; }
"/*" { BEGIN COMMENT; }
<COMMENT>"*/" { BEGIN 0; }
<COMMENT>. { ; }

    /* Newline */
\n {
    if (opt_src) {
        printf("%d: %s\n", line_num, buffer);
    }
    ++line_num;
    buffer[0] = '\0';
    buffer_ptr = buffer;
}
    /* Catch the character which is not accepted by rules above */
. {
    printf("Error at line %d: bad character \"%s\"\n", line_num, yytext);
    exit(-1);
}

%%

/* Put string in buffer */
static void concatenateString(const char *yytext_ptr) {
    while (*yytext_ptr) {
        *buffer_ptr = *yytext_ptr;
        ++buffer_ptr;
        ++yytext_ptr;
    }
    *buffer_ptr = '\0';
}

int main(int argc, const char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: ./scanner [filename]\n");
        exit(-1);
    }

    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        fprintf(stderr, "Open file error\n");
        exit(-1);
    }

    yylex();

    return 0;
}
