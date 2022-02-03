open Ast


(* Print prog_def *)
let rec printProg prog = 
  List.iter printClass prog.classes;
  printBloc prog.program;
  print_newline(); 

  (* Print de class_def *)
and  printClass c =
  print_string "class "; print_string c.name_class; print_string " ("; List.iter printVariable c.params_class;
  print_string ")";
  (match c.superclass with 
   | None -> print_string " "
   | Some s -> print_string " extends "; print_string s);
  print_string " is ";
  print_string " { ";
  print_newline();
  List.iter printVariable2 c.attributes;
  printConstructor c.constructor;
  List.iter printMethod c.methods;
  print_string "} ";
  print_newline(); print_newline(); 
  (**
     ____________________________________________
     /                    ------------°°°°------------                      \
     |                    TYPES POUR L'AST
     \ ___________________________________________ /
   **)

  (* Print de block_t*)
and printBloc b =       
  List.iter printVariable2 b.declarations; 
  print_newline();
  List.iter printInstr b.instructions; print_newline();

  (* Print de constructor_def*)
and  printConstructor cons = 
  print_newline();
  print_string " [def] ";
  print_string cons.name_constructor;
  print_string "(";
  List.iter printVariable cons.param_constructor;
  print_string ") "; 
  (match cons.super_call with
   | None -> print_string ""
   | Some s -> print_string " : ";  printSuperConstructor s;);
  print_string " is ";
  print_string " {"; 
  print_newline();
  printBloc cons.body_constructor;
  print_string " }"; 
  print_newline(); 

  (* Print de superconstructor_call *)
and  printSuperConstructor cons = 
  print_string cons.superclass_constructor; print_string "(";
  List.iter printExpr cons.arguments; print_string ")";


  (* Print de methode_def *)
and  printMethod m =
  print_newline(); print_newline();
  print_string " [def] ";
  (match m.is_static_method with 
   | false -> print_string "" 
   | true -> print_string "[static] ");
  (match m.is_override with 
   | false -> print_string " " 
   | true -> print_string " [override] ");
  print_string m.name_method;
  print_string "(";
  List.iter printVariable m.param_method;
  print_string ")"; 
  (match m.return_type with 
   | None -> print_string " is {";  printBloc m.body_method; print_string " }"; 
   | Some s -> print_string " : ";  
     print_string  s; 
     print_string " := ";
     printBloc m.body_method;);


  (* Print de variable_def *)
and  printVariable d =
  let rec printVarRec d =
    (match d.is_var with 
     | false -> print_string ""
     | true -> print_string " [var] ");
    (match d.is_static with 
     | false  ->  print_string ""
     | true -> print_string " [static] "); 
    print_string d.name; 
    print_string " : "; 
    print_string d.typ ; print_string " " ;

  in printVarRec d;


and  printVariable2 d =
  let rec printVarRec d =

    (match d.is_var with 
     | false -> print_string ""
     | true -> print_string " [var] ");
    (match d.is_static with 
     | false  ->  print_string ""
     | true -> print_string "[static] "); 

    print_string d.name; 
    print_string " : "; 
    print_string d.typ;
    print_newline();
  in printVarRec d;


  (* Print d'instruction_t*) 
and printInstr ins =
  let rec printInstrec ins = 
    match ins with
    | Exp e -> printExpr e; print_newline(); 
    | Block b -> printBloc b; print_newline(); 
    | Return -> () ; 
    | Ite (si, alors, sinon) ->
      print_newline(); print_string "  if "; printExpr si; 
      print_newline(); print_string "  then "; printInstrec alors;
      print_newline(); print_string "  else "; printInstrec sinon; 
    | Affectation (g, d) -> print_string " ";  printContainer g; print_string " := ";  printExpr d; print_newline();
  in printInstrec ins;

  (* Print container_t*) 
and  printContainer c = 
  (match c with 
   | Select a -> printAttributeCall a;
   | LocalVar n -> print_string n;  
   | This -> print_string " [this]";  
   | Super -> print_string " [super]"; );


  (* Print attribute_call*) 
and  printAttributeCall a = 
  printCallBeginning a.beginning;
  List.iter printCallEnd a.selections_to_attrs;

  (* Print method_call*) 
and  printMethodCall a = 
  printCallBeginning a.beginning_call;
  List.iter printCallEnd a.selections_to_meths;

  (* selection_beg_t *)
and  printCallBeginning a =
  match a with 
  | ExpSelect e -> printExpr e; 
  | ClassSelect s -> print_string s;   

    (* selection_end_t *)
and  printCallEnd a =
  match a with 
  | AttrSelect s ->  print_string " ["; print_string s; print_string "] "; 
  | MethSelect (s,le) -> print_string " ["; print_string s;  print_string "(" ; List.iter printExpr le; print_string ")";  print_string "] ";

    (* print de expression_t*)
and  printExpr e =
  let rec printExprec e = 
    match e with
    | IntLiteral i -> print_string "["; print_int i; print_string "]";
    | StringLiteral s -> print_string " ''";  print_string s; print_string "''";
    | Container cont -> printContainer cont
    | Method meth ->  printMethodCall meth ;
    | Binary (op,g,d) ->  printExprec g;  printBinary op; printExprec d; print_string " ";
    | Unary (op,e) -> printUnary op; printExprec e
    | Cast (s,e) -> print_string s; printExprec e
    | NewClass (s,le) -> print_string " new "; print_string s; print_string "("; List.iter printExprec le; print_string ")"
  in printExprec e;



  (* print de unary_operator_t*)
and  printUnary u =
  match u with 
  | UMINUS -> print_string " - " ;
    (* binary_operator_t *)
and   printBinary b = 
  match b with 
  | IntBinOp i -> printIntBinary i
  | StringConcat -> print_string " & ";

    (* and int_binary_operator_t *)
and  printIntBinary op  =
  match op with
    EQ -> print_string " = "
  | NEQ -> print_string " <> "
  | LT -> print_string " < "
  | LE -> print_string " <= "
  | GT -> print_string " > "
  | GE -> print_string " >= "
  | PLUS -> print_string " + "
  | MINUS -> print_string " - "
  | TIMES -> print_string " * "
  | DIV -> print_string " / "