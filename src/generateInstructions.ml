open Registers
open IO
open ProcessInstructions
open Utilities

let acc = ref []

let rec gen_rtype op n =
  if n mod 15 = 0 then ()
  else
    let rd = gen_register n in
    let rs1 = gen_register (n + 1) in
    let rs2 = gen_register (n + 2) in
    acc := (op ^ " " ^ rd ^ ", " ^ rs1 ^ ", " ^ rs2) :: !acc;
    gen_rtype op (n + 1)

let rec gen_itype op n =
  if n mod 15 = 0 then ()
  else
    let rd = gen_register n in
    let rs1 = gen_register (n + 1) in
    let imm = gen_imm min_i max_i in
    acc := (op ^ " " ^ rd ^ ", " ^ rs1 ^ ", " ^ Int32.to_string imm) :: !acc;
    gen_itype op (n + 1)

let rec gen_swtype op n =
  if n mod 15 = 0 then ()
  else
    let rd = gen_register n in
    let rs1 = "x0" in
    let imm = Int32.mul (gen_imm 0l 7l) 4l in
    acc :=
      (op ^ " " ^ rd ^ ", " ^ Int32.to_string imm ^ "(" ^ rs1 ^ ")") :: !acc;
    gen_swtype op (n + 1)

let rec gen_sbtype op n =
  if n mod 15 = 0 then ()
  else
    let rd = gen_register n in
    let rs1 = "x0" in
    let imm = gen_imm 0l 31l in
    acc :=
      (op ^ " " ^ rd ^ ", " ^ Int32.to_string imm ^ "(" ^ rs1 ^ ")") :: !acc;
    gen_swtype op (n + 1)

let rec gen_utype op n =
  if n mod 15 = 0 then ()
  else
    let rd = gen_register n in
    let imm = gen_imm (Int32.of_int ~-2048) 2047l in
    acc := (op ^ " " ^ rd ^ ", " ^ Int32.to_string imm) :: !acc;
    gen_utype op (n + 1)

let gen_specific_insns ops =
  let rec helper ops =
    match ops with
    | [] -> ()
    | h :: t ->
        (match h with
        | "1" | "addi" -> gen_itype "addi" 1
        | "2" | "andi" -> gen_itype "andi" 1
        | "3" | "ori" -> gen_itype "ori" 1
        | "4" | "xori" -> gen_itype "xori" 1
        | "5" | "slli" -> gen_itype "slli" 1
        | "6" | "slri" -> gen_itype "slri" 1
        | "7" | "slti" -> gen_rtype "slti" 1
        | "8" | "sltiu" -> gen_rtype "sltiu" 1
        | "9" | "add" -> gen_rtype "add" 1
        | "10" | "and" -> gen_rtype "and" 1
        | "11" | "or" -> gen_rtype "or" 1
        | "12" | "xor" -> gen_rtype "xor" 1
        | "13" | "sll" -> gen_rtype "sll" 1
        | "14" | "srl" -> gen_rtype "srl" 1
        | "15" | "slt" -> gen_rtype "slt" 1
        | "16" | "sltu" -> gen_rtype "sltu" 1
        | "17" | "lui" -> gen_utype "lui" 1
        | "18" | "sw" -> gen_swtype "sw" 1
        | "19" | "sb" -> gen_swtype "sb" 1
        | "20" | "lw" -> gen_sbtype "lw" 1
        | "21" | "lb" -> gen_sbtype "lb" 1
        | _ -> ());

        helper t
  in
  helper ops;
  gen_itype "addi" 1;
  list_to_file !acc;
  acc := []

let rec gen_insns () =
  ignore (List.map (fun op -> gen_itype op 1) rtype);
  ignore (List.map (fun op -> gen_rtype op 1) rtype);
  ignore (List.map (fun op -> gen_swtype op 1) rtype);
  ignore (List.map (fun op -> gen_sbtype op 1) rtype);
  ignore (List.map (fun op -> gen_utype op 1) rtype);
  list_to_file (List.rev !acc);
  acc := []
