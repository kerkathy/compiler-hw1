%{
#include <stdint.h>
#include <string.h>

#define LIST                concatenateString(yytext)
#define TOKEN(t)            { LIST; if (opt_tok) printf("<%s>\n", #t); }
#define TOKEN_CHAR(t)       { LIST; if (opt_tok) printf("<%c>\n", (t)); }
#define TOKEN_STRING(t, s)  { LIST; if (opt_tok) printf("<%s: %s>\n", #t, (s)); }
#define MAX_LINE_LENG       512

uint32_t line_num = 1;
uint32_t str_len = 1;
static char buffer[MAX_LINE_LENG];
static char strbuffer[MAX_LINE_LENG];

static uint32_t opt_src = 1;	// listing option
static uint32_t opt_tok = 1;	// token option
static char *buffer_ptr = buffer;

static void concatenateString(const char *yytext_ptr);

%}

digit	[0-9]
digits  {digit}+
letter	[a-zA-Z]
nonzeroDecInt [1-9][0-9]*
nonZeroDec 0\.0|0\.{digit}*[1-9]|[1-9]{digit}*(\.{digits}[1-9])? 
nonZeroOctInt 0+[1-7][0-7]*  

%Start STRMODE STRQUOTE STREND LONGCOMMENT SHORTCOMMENT

%%

    /* Delimiter */
<INITIAL>"," { TOKEN_CHAR(','); }
<INITIAL>";" { TOKEN_CHAR(';'); }
<INITIAL>":" { TOKEN_CHAR(':'); }
<INITIAL>"(" { TOKEN_CHAR('('); }
<INITIAL>")" { TOKEN_CHAR(')'); }
<INITIAL>"[" { TOKEN_CHAR('['); }
<INITIAL>"]" { TOKEN_CHAR(']'); }

    /* Arithmetic, Relational, and Logical Operators */
<INITIAL>"+" { TOKEN_CHAR('+'); }
<INITIAL>"-" { TOKEN_CHAR('-'); }
<INITIAL>"*" { TOKEN_CHAR('*'); }
<INITIAL>"/" { TOKEN_CHAR('/'); }
<INITIAL>"mod" { TOKEN(mod); }
<INITIAL>":=" { TOKEN(:=); }
<INITIAL>"<" { TOKEN_CHAR('<'); }
<INITIAL>"<=" { TOKEN(<=); }
<INITIAL>"<>" { TOKEN(<>); }
<INITIAL>">=" { TOKEN(>=); }
<INITIAL>">" { TOKEN_CHAR('>'); }
<INITIAL>"=" { TOKEN_CHAR('='); }
<INITIAL>"and" { TOKEN(and); }
<INITIAL>"or" { TOKEN(or); }
<INITIAL>"not" { TOKEN(not); }
 
    /* Reserved Words */
<INITIAL>"var" { TOKEN(KWvar); }
<INITIAL>"def" { TOKEN(KWdef); }
<INITIAL>"array" { TOKEN(KWarray); }
<INITIAL>"of" { TOKEN(KWof); }
<INITIAL>"boolean" { TOKEN(KWboolean); }
<INITIAL>"integer" { TOKEN(KWinteger); }
<INITIAL>"real" { TOKEN(KWreal); }
<INITIAL>"string" { TOKEN(KWstring); }
<INITIAL>"true" { TOKEN(KWtrue); }
<INITIAL>"false" { TOKEN(KWfalse); }
<INITIAL>"while" { TOKEN(KWwhile); }
<INITIAL>"do" { TOKEN(KWdo); }
<INITIAL>"if" { TOKEN(KWif); }
<INITIAL>"then" { TOKEN(KWthen); }
<INITIAL>"else" { TOKEN(KWelse); }
<INITIAL>"for" { TOKEN(KWfor); }
<INITIAL>"to" { TOKEN(KWto); }
<INITIAL>"begin" { TOKEN(KWbegin); }
<INITIAL>"end" { TOKEN(KWend); }
<INITIAL>"print" { TOKEN(KWprint); }
<INITIAL>"read" { TOKEN(KWread); }
<INITIAL>"return" { TOKEN(KWreturn); }

    /* Integer Constants */
<INITIAL>0[0-7]+ { TOKEN_STRING(oct_integer, yytext); }
<INITIAL>0|[1-9]{digit}* { TOKEN_STRING(integer, yytext); }

    /* Floating-Point Constants */
<INITIAL>(0|[1-9]{digit}*)\.(0?|{digit}*[1-9]) { TOKEN_STRING(float, yytext); }

    /* Scientific Notations */
    /* base: nonzero oct/dec int OR nonzero dec float */
    /* exponent: dec int w/ optional sign */
    /* nonzero octal: 0+[0-7]*[1-7][0-7]* */
    /* nonzero dec int/float: 0\.0|0\.{digit}*[1-9]|[1-9]{digit}*(\.{digits}[1-9])? */
    /* exponent: dec int w/ optional sign */
<INITIAL>({nonZeroDec}|((0|[1-9]{digit}*)\.(0?|{digit}*[1-9])))[Ee][\+-]?(0|[1-9][0-9]*) { TOKEN_STRING(scientific, yytext); }


    /* String Constants */
    /* 1. When encounter a " followed by some words and a second ", then go into STRMODE */
	/* 2. In STRMODE, detect double quote and deal with it in STRQUOTE */
<STREND>["] { 
	TOKEN_STRING(string, strbuffer); 
	strbuffer[0] = '\0'; 
	BEGIN 0; 
}
<STRMODE>[^"\n]*/["] { 
	LIST;
	strncat(strbuffer, yytext, MAX_LINE_LENG - strlen(strbuffer)); 
	BEGIN STREND; 
}
<STRMODE>[^"\n]*/["]{2} { 
	LIST;
	strncat(strbuffer, yytext, MAX_LINE_LENG - strlen(strbuffer)); 
	BEGIN STRQUOTE; 
}
<STRQUOTE>["]{2} { 
	LIST;
	strncat(strbuffer, "\"", 1); 
	BEGIN STRMODE; 
}
<INITIAL>["]/[^\n]*["] { 
	LIST; 
	BEGIN STRMODE; 
}

	/* Whitespace */
[ \t]+ { LIST; }

    /* Pseudocomments */
<INITIAL>"//"&[ST][+-] { 
    if (yytext[3] == 'S' && yytext[4] == '+' ) {
    	opt_src = 1;	    
    } 
    if (yytext[3] == 'S' && yytext[4] == '-' ) {
 		opt_src = 0;   
    } 
    if (yytext[3] == 'T' && yytext[4] == '+' ) {
    	opt_tok = 1;
    } 
    if (yytext[3] == 'T' && yytext[4] == '-' ) {
    	opt_tok = 0;
    }
	LIST;
	BEGIN SHORTCOMMENT;	
}

    /* Comments */
<INITIAL>"//" { LIST; BEGIN SHORTCOMMENT; }
<INITIAL>"/*" { LIST; BEGIN LONGCOMMENT; }
<LONGCOMMENT>"*/" { LIST; BEGIN 0; }
<LONGCOMMENT>. { LIST; }
<SHORTCOMMENT>.*/\r?\n { LIST; BEGIN 0; }

    /* Newline */
\n {
    if (opt_src) {
        printf("%d: %s\n", line_num, buffer);
    }
    ++line_num;
    buffer[0] = '\0';
    buffer_ptr = buffer;
}

    /* Identifiers */
<INITIAL>{letter}({letter}|{digit})* { TOKEN_STRING(id, yytext); }

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
