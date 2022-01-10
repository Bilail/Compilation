# 1 "Lex.mll"
 
open Ast
open Parse
open Lexing
exception Eof

(* gere les positions numero de ligne + decalage dans la ligne *)
let next_line lexbuf = Lexing.new_line lexbuf

(* cree une table de hachage qu'on remplit avec le token associe
 * a chaque mot-clef
 *)
let keyword_table = Hashtbl.create 16
let _ =
  List.iter
    (fun (kwd, tok) -> Hashtbl.add keyword_table kwd tok)
    [ "if", IF;
      "then", THEN;
      "else", ELSE;
      "class" , CLASSE;
      "super" , SUPER;
      "this" , THIS;
      "result", RESULT;
      "new", NEW;
      "var", VAR;
      "def", DEF;
      "is", IS;
      "static", STATIC;
      "override", OVERRIDE
    ]

# 34 "Lex.ml"
let __ocaml_lex_tables = {
  Lexing.lex_base =
   "\000\000\252\255\253\255\254\255\000\000\255\255\008\000\229\255\
    \230\255\232\255\010\000\038\000\238\255\239\255\011\000\241\255\
    \242\255\243\255\244\255\245\255\247\255\248\255\249\255\001\000\
    \086\000\252\255\000\000\096\000\217\000\250\255\237\255\231\255\
    \235\255\233\255";
  Lexing.lex_backtrk =
   "\255\255\255\255\255\255\255\255\003\000\255\255\255\255\255\255\
    \255\255\255\255\021\000\019\000\255\255\255\255\015\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\009\000\
    \004\000\255\255\002\000\001\000\000\000\255\255\255\255\255\255\
    \255\255\255\255";
  Lexing.lex_default =
   "\001\000\000\000\000\000\000\000\255\255\000\000\007\000\000\000\
    \000\000\000\000\255\255\255\255\000\000\000\000\255\255\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\255\255\
    \255\255\000\000\255\255\255\255\255\255\000\000\000\000\000\000\
    \000\000\000\000";
  Lexing.lex_trans =
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\026\000\003\000\000\000\000\000\026\000\000\000\000\000\
    \000\000\026\000\025\000\000\000\000\000\026\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \026\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \026\000\000\000\004\000\029\000\000\000\000\000\000\000\005\000\
    \019\000\018\000\020\000\022\000\013\000\021\000\012\000\023\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \024\000\024\000\014\000\015\000\011\000\009\000\010\000\033\000\
    \030\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\032\000\031\000\000\000\000\000\000\000\
    \000\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\017\000\000\000\016\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \002\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \008\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000";
  Lexing.lex_check =
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\026\000\000\000\255\255\255\255\026\000\255\255\255\255\
    \255\255\006\000\006\000\255\255\255\255\006\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \026\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \006\000\255\255\000\000\023\000\255\255\255\255\255\255\004\000\
    \006\000\006\000\006\000\006\000\006\000\006\000\006\000\006\000\
    \006\000\006\000\006\000\006\000\006\000\006\000\006\000\006\000\
    \006\000\006\000\006\000\006\000\006\000\006\000\006\000\010\000\
    \014\000\006\000\006\000\006\000\006\000\006\000\006\000\006\000\
    \006\000\006\000\006\000\006\000\006\000\006\000\006\000\006\000\
    \006\000\006\000\006\000\006\000\006\000\006\000\006\000\006\000\
    \006\000\006\000\006\000\011\000\011\000\255\255\255\255\255\255\
    \255\255\006\000\006\000\006\000\006\000\006\000\006\000\006\000\
    \006\000\006\000\006\000\006\000\006\000\006\000\006\000\006\000\
    \006\000\006\000\006\000\006\000\006\000\006\000\006\000\006\000\
    \006\000\006\000\006\000\006\000\255\255\006\000\024\000\024\000\
    \024\000\024\000\024\000\024\000\024\000\024\000\024\000\024\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\027\000\027\000\027\000\027\000\027\000\
    \027\000\027\000\027\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \006\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\028\000\028\000\028\000\028\000\
    \028\000\028\000\028\000\028\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255";
  Lexing.lex_base_code =
   "";
  Lexing.lex_backtrk_code =
   "";
  Lexing.lex_default_code =
   "";
  Lexing.lex_trans_code =
   "";
  Lexing.lex_check_code =
   "";
  Lexing.lex_code =
   "";
}

let rec comment lexbuf =
   __ocaml_lex_comment_rec lexbuf 0
and __ocaml_lex_comment_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 40 "Lex.mll"
                  ( (* fin de commentaire trouvee. Le commentaire ne doit pas
                     * etre transmis. On renvoie donc ce que nous renverra un
                     * nouvel appel a l'analyseur lexical
                     *)
                    token lexbuf
                  )
# 202 "Lex.ml"

  | 1 ->
# 46 "Lex.mll"
                   ( (* incremente le compteur de ligne et poursuit la
                      * reconnaissance du commentaire en cours
                      *)
                     new_line lexbuf; comment lexbuf
                   )
# 211 "Lex.ml"

  | 2 ->
# 51 "Lex.mll"
                   ( (* detecte les commentaires non fermes pour pouvoir
                      * faire un message d'erreur clair.
                      * On pourrait stocker la position du dernier commentaire
                      * encore ouvert pour ameliorer le dioagnostic
                      *)
                     raise (MISC_Error "unclosed comment")
                   )
# 222 "Lex.ml"

  | 3 ->
# 58 "Lex.mll"
                   ( (* rien a faire de special pour ce caractere, donc on
                      * poursuit la reconnaissance du commentaire en cours
                      *)
                     comment lexbuf
                   )
# 231 "Lex.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_comment_rec lexbuf __ocaml_lex_state

and token lexbuf =
   __ocaml_lex_token_rec lexbuf 6
and __ocaml_lex_token_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
let
# 65 "Lex.mll"
                 classe_name
# 244 "Lex.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 65 "Lex.mll"
                             ( CLASSNAME classe_name )
# 248 "Lex.ml"

  | 1 ->
let
# 66 "Lex.mll"
                     id
# 254 "Lex.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 67 "Lex.mll"
      ( (* id contient le texte reconnu. On verifie s'il s'agit d'un mot-clef
         * auquel cas on renvoie le token associe. Sinon on renvoie Id avec le
         * texte reconnu en valeur 
         *)
        try
          Hashtbl.find keyword_table id
        with Not_found -> ID id
      )
# 265 "Lex.ml"

  | 2 ->
# 76 "Lex.mll"
                    ( (* consommer les delimiteurs, ne pas les transmettre
                       * et renvoyer ce que renverra un nouvel appel a
                       *  l'analyseur lexical
                       *)
                       token lexbuf
                    )
# 275 "Lex.ml"

  | 3 ->
# 82 "Lex.mll"
                   ( next_line lexbuf; token lexbuf)
# 280 "Lex.ml"

  | 4 ->
let
# 83 "Lex.mll"
                lxm
# 286 "Lex.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 83 "Lex.mll"
                    ( CSTE(int_of_string lxm) )
# 290 "Lex.ml"

  | 5 ->
# 84 "Lex.mll"
                   ( comment lexbuf )
# 295 "Lex.ml"

  | 6 ->
# 85 "Lex.mll"
                   ( PLUS )
# 300 "Lex.ml"

  | 7 ->
# 86 "Lex.mll"
                   ( MINUS )
# 305 "Lex.ml"

  | 8 ->
# 87 "Lex.mll"
                   ( TIMES )
# 310 "Lex.ml"

  | 9 ->
# 88 "Lex.mll"
                   ( DIV )
# 315 "Lex.ml"

  | 10 ->
# 89 "Lex.mll"
                   ( LPAREN )
# 320 "Lex.ml"

  | 11 ->
# 90 "Lex.mll"
                   ( RPAREN )
# 325 "Lex.ml"

  | 12 ->
# 91 "Lex.mll"
                   ( LBRACKET )
# 330 "Lex.ml"

  | 13 ->
# 92 "Lex.mll"
                   ( RBRACKET )
# 335 "Lex.ml"

  | 14 ->
# 93 "Lex.mll"
                   ( SEMICOLON )
# 340 "Lex.ml"

  | 15 ->
# 94 "Lex.mll"
                   ( COLON )
# 345 "Lex.ml"

  | 16 ->
# 95 "Lex.mll"
                   ( COMMA )
# 350 "Lex.ml"

  | 17 ->
# 96 "Lex.mll"
                   ( SELECTION )
# 355 "Lex.ml"

  | 18 ->
# 97 "Lex.mll"
                   ( ASSIGN )
# 360 "Lex.ml"

  | 19 ->
# 98 "Lex.mll"
                  ( RELOP (Ast.LT) )
# 365 "Lex.ml"

  | 20 ->
# 99 "Lex.mll"
                   ( RELOP (Ast.LE) )
# 370 "Lex.ml"

  | 21 ->
# 100 "Lex.mll"
                   ( RELOP (Ast.GT) )
# 375 "Lex.ml"

  | 22 ->
# 101 "Lex.mll"
                   ( RELOP (Ast.GE) )
# 380 "Lex.ml"

  | 23 ->
# 102 "Lex.mll"
                   ( RELOP (Ast.EQ) )
# 385 "Lex.ml"

  | 24 ->
# 103 "Lex.mll"
                   ( RELOP (Ast.NEQ) )
# 390 "Lex.ml"

  | 25 ->
# 104 "Lex.mll"
                   ( EOF )
# 395 "Lex.ml"

  | 26 ->
let
# 105 "Lex.mll"
         lxm
# 401 "Lex.ml"
= Lexing.sub_lexeme_char lexbuf lexbuf.Lexing.lex_start_pos in
# 105 "Lex.mll"
                   ( (* action par défaut: filtre un unique caractere, different
                      * de ceux qui precedent. Il s'agit d'un caratere errone:
                      * on le signale et on poursuit quand meme l'analyse.
                      * On aurait pu décider de lever une exception et
                      * arreter l'analyse.
                      *)
                     print_endline
                       ("undefined character: " ^ (String.make 1 lxm));
                     token lexbuf
                   )
# 414 "Lex.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_token_rec lexbuf __ocaml_lex_state

;;

