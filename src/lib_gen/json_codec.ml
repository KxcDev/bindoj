(* Copyright 2022 Kotoi-Xie Consultancy, Inc. This file is a part of the

==== Bindoj (https://kxc.dev/bindoj) ====

software project that is developed, maintained, and distributed by
Kotoi-Xie Consultancy, Inc. (https://kxc.inc) which is also known as KXC.

Licensed under the Apache License, Version 2.0 (the "License"); you may not
use this file except in compliance with the License. You may obtain a copy
of the License at http://www.apache.org/licenses/LICENSE-2.0. Unless required
by applicable law or agreed to in writing, software distributed under the
License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS
OF ANY KIND, either express or implied. See the License for the specific
language governing permissions and limitations under the License.
                                                                              *)
(* Acknowledgements  --- AnchorZ Inc. ---  The current/initial version or a
significant portion of this file is developed under the funding provided by
AnchorZ Inc. to satisfy its needs in its product development workflow.
                                                                              *)
open Ppxlib
open Ast_builder.Default
open Ast_helper
open Utils
open Bindoj_runtime
open Bindoj_base
open Bindoj_base.Type_desc

include Bindoj_codec.Json.Config

type json_schema
type ('tag, 'datatype_expr) foreign_language +=
  | Foreign_language_JSON_Schema :
    (json_schema, Bindoj_openapi.V3.Schema_object.t) foreign_language
let json_schema = Foreign_language_JSON_Schema

module Json_config = struct
  include Bindoj_codec.Json.Config.Json_config

  let custom_json_schema schema =
    Configs.Config_foreign_type_expression (json_schema, schema)
end

let get_encoder_name type_name = function
  | `default -> type_name^"_to_json"
  (* | `codec_val v -> v *)
  | `in_module m -> m^".to_json"
let get_decoder_name type_name = function
  | `default -> type_name^"_of_json"
  (* | `codec_val v -> v *)
  | `in_module m -> m^".of_json"

type builtin_codec = {
  encoder: expression;
  decoder: expression;
  (* validator stuffs are meant to go here *)
}

module Builtin_codecs = struct
  open struct let loc = Location.none end

  let unit = {
      encoder = [%expr fun () -> (`num 1. : Kxclib.Json.jv)];
      decoder = [%expr function
                      (`bool _ | `num _ | `str _ | `arr [] | `obj []) -> Some () | _ -> None];
    }
  let bool = {
      encoder = [%expr fun (x : bool) -> (`bool x : Kxclib.Json.jv)];
      decoder = [%expr function
        | (`bool x : Kxclib.Json.jv) -> Some x
        | (_ : Kxclib.Json.jv) -> None
      ];
    }
  let int = {
      encoder = [%expr fun (x : int) -> (`num (float_of_int x) : Kxclib.Json.jv)];
      decoder = [%expr function
        | (`num x : Kxclib.Json.jv) -> Some (int_of_float x)
        | (_ : Kxclib.Json.jv) -> None
      ];
    }
  let int53p = {
      encoder = [%expr fun (x : Kxclib.int53p) -> (`num (Kxclib.Int53p.to_float x) : Kxclib.Json.jv)];
      decoder = [%expr function
        | (`num x : Kxclib.Json.jv) -> Some (Kxclib.Int53p.of_float x)
        | (_ : Kxclib.Json.jv) -> None
      ];
    }
  let float = {
      encoder = [%expr fun (x : float) -> (`num x : Kxclib.Json.jv)];
      decoder = [%expr function
        | (`num x : Kxclib.Json.jv) -> Some x
        | _ -> None
      ];
    }
  let string = {
      encoder = [%expr fun (x : string) -> (`str x : Kxclib.Json.jv)];
      decoder = [%expr function
        | (`str x : Kxclib.Json.jv) -> Some x
        | _ -> None
      ];
    }
  let uchar = {
      encoder = [%expr fun (x: Uchar.t) -> (`str (String.of_seq (List.to_seq [Uchar.to_char x])) : Kxclib.Json.jv)];
      decoder = [%expr function
        | (`str x : Kxclib.Json.jv) ->
            if String.length x = 1 then Some (Uchar.of_char (String.get x 0)) else None
        | _ -> None
      ];
    }
  let byte = {
      encoder = [%expr fun (x: char) -> (`num (float_of_int (int_of_char x)) : Kxclib.Json.jv)];
      decoder = [%expr function
        | (`num x : Kxclib.Json.jv) ->
            let x = int_of_float x in
            if 0 <= x && x <= 255 then Some (char_of_int x) else None
        | (_ : Kxclib.Json.jv) -> None
      ];
    }
  let bytes = {
      encoder = [%expr fun (x : Bytes.t) -> (`str (Kxclib.Base64.encode x) : Kxclib.Json.jv)];
      decoder = [%expr function
        | (`str x : Kxclib.Json.jv) ->
          (try Some (Kxclib.Base64.decode x) with Invalid_argument _msg -> None)
        | _ -> None
      ];
    }
  let option = {
      encoder = [%expr fun t_to_json -> function
        | Some x -> t_to_json x
        | None -> (`null : Kxclib.Json.jv)
      ];
      decoder = [%expr fun t_of_json -> function
        | `null -> Some None
        | x ->
          match t_of_json x with
          | Some x -> Some (Some x)
          | None -> None
      ];
    }
  let list = {
      encoder = [%expr fun t_to_json xs -> (`arr (List.map t_to_json xs) : Kxclib.Json.jv)];
      decoder = [%expr fun t_of_json -> function
        | (`arr xs : Kxclib.Json.jv) ->
          let result = List.filter_map t_of_json xs in
          if List.length xs = List.length result then
            Some result
          else
            None
        | _ -> None
      ];
    }
  let uninhabitable = {
      encoder = [%expr fun () -> (`null : Kxclib.Json.jv)];
      decoder = [%expr function `null -> Some () | _ -> None];
    }
  let map = {
      encoder = [%expr fun key_to_string v_to_json fields ->
        let fields =
          fields |> List.map (fun (k, v) -> key_to_string k, v_to_json v)
        in
        (`obj fields : Kxclib.Json.jv)
      ];
      decoder = [%expr fun key_of_string v_of_json -> function
        | `obj fields ->
          let result =
            List.filter_map (fun (k, v) ->
                match key_of_string k, v_of_json v with
                | Some k, Some v -> Some (k, v)
                | _, _ -> None
              ) fields
          in
          if List.length fields = List.length result then
            Some result
          else
            None
        | _ -> None
      ];
    }

  let all = [
      "unit", unit;
      "bool", bool;
      "int", int;
      "int53p", int53p;
      "float", float;
      "string", string;
      "uchar", uchar;
      "byte", byte;
      "bytes", bytes;
      "option", option;
      "list", list;
      "uninhabitable", uninhabitable;
      "map", map;
    ]
end

let builtin_codecs = Builtin_codecs.all

let builtin_codecs_map =
  builtin_codecs |> List.to_seq |> StringMap.of_seq

let codec_of_coretype ~get_custom_codec ~get_name ~map_key_converter ~tuple_case ~string_enum_case self_ename (ct: coretype) =
  let open Coretype in
  let loc = Location.none in
  match get_custom_codec ct.ct_configs with
  | Some coder -> evar coder
  | None ->
    let evar_name ?(codec = `default) name =
      get_name name codec |> evar
    in
    let rec go = function
      | Prim p -> evar_name (Coretype.string_of_prim p)
      | Uninhabitable -> evar_name "uninhabitable"
      | Ident i -> evar_name ~codec:i.id_codec i.id_name
      | Option t -> [%expr [%e evar_name "option"] [%e go t]] (* option_of_json t_of_json *)
      | List t -> [%expr [%e evar_name "list"] [%e go t]] (* list_of_json t_of_json *)
      | Map (k, v) -> [%expr [%e evar_name "map"] [%e map_key_converter k] [%e go v]] (* map_of_json key_of_string t_of_json *)
      | Tuple ts -> tuple_case ct.ct_configs go ts
      | StringEnum cs -> string_enum_case cs
      | Self -> self_ename
    in
    go ct.ct_desc

let collect_builtin_codecs (td: type_decl) =
  let folder state (ct: coretype) =
    Coretype.fold (fun state ->
      let add name = state |> StringMap.add name (builtin_codecs_map |> StringMap.find name) in
      function
      | Prim p -> add (Coretype.string_of_prim p)
      | Uninhabitable -> add "uninhabitable"
      | Option _ -> add "option"
      | List _ -> add "list"
      | Map _ -> add "map"
      | Ident _ | Self | Tuple _ | StringEnum _ -> state
    ) state ct.ct_desc
  in
  fold_coretypes folder StringMap.empty td

let encoder_of_coretype =
  let open Coretype in
  let vari i = "x"^string_of_int i in
  let loc = Location.none in
  let evari i = evar (vari i) in
  let pvari i = pvar (vari i) in
  let tuple_case (configs: [`coretype] configs) (go: desc -> expression) (ts: desc list) =
    let args =
      ts |> List.mapi (fun i _ -> pvari i)
         |> Pat.tuple
    in
    let rec mk_list acc = function
      | [] -> acc
      | x :: xs -> mk_list [%expr [%e x] :: [%e acc]] xs
    in
    let ret =
      let style = Json_config.get_tuple_style configs in
      ts
      |> List.mapi (fun i t ->
        match style with
        | `obj `default ->
          let label = estring ~loc (tuple_index_to_field_name i) in
          [%expr ([%e label], [%e go t] [%e evari i])]
        | `arr -> [%expr [%e go t] [%e evari i]])
      |> List.rev |> mk_list [%expr []]
      |> (fun ret ->
        match style with
        | `obj `default -> [%expr `obj [%e ret]]
        | `arr -> [%expr `arr [%e ret]])
    in
    [%expr fun [%p args] -> ([%e ret] : Kxclib.Json.jv)]
  in
  let map_key_converter (k: map_key) = (* key_to_string *)
    match k with
    | `string -> [%expr fun (k: string) -> k]
  in
  let string_enum_case (cs: string list) =
    let cases =
      cs |> List.map (fun c ->
        let pat = Pat.variant (Utils.escape_as_constructor_name c) None in
        let expr = [%expr `str [%e Exp.constant (Const.string c)]] in
        Exp.case pat expr
      )
    in
    Exp.function_ cases
  in
  codec_of_coretype
    ~get_custom_codec:Json_config.get_custom_encoder
    ~get_name:get_encoder_name
    ~tuple_case ~map_key_converter ~string_enum_case

let decoder_of_coretype =
  let open Coretype in
  let vari i = "x"^string_of_int i in
  let loc = Location.none in
  let evari i = evar (vari i) in
  let pvari i = pvar (vari i) in
  let tuple_case (configs: [`coretype] configs) (go: desc -> expression) (ts: desc list) =
    let rec mk_list acc = function
      | [] -> acc
      | x :: xs -> mk_list [%pat? [%p x] :: [%p acc]] xs
    in
    let ret =
      let tmp, args, ret =
        ts |> List.mapi (fun i t -> [%expr [%e go t] [%e evari i]]) |> Exp.tuple,
        ts |> List.mapi (fun i _ -> [%pat? Some [%p pvari i]]) |> Pat.tuple,
        ts |> List.mapi (fun i _ -> [%expr [%e evari i]]) |> Exp.tuple
      in
      [%expr match [%e tmp] with [%p args] -> Some [%e ret] | _ -> None]
    in
    match Json_config.get_tuple_style configs with
    | `arr ->
      let args =
        ts |> List.mapi (fun i _ -> pvari i)
           |> List.rev |> mk_list [%pat? []]
      in
      [%expr function
        | (`arr [%p args] : Kxclib.Json.jv) -> [%e ret]
        | _ -> None]
    | `obj `default ->
      let body =
        ts
        |> List.mapi (fun i _ -> i)
        |> List.foldr (fun i ret ->
          let label = estring ~loc (tuple_index_to_field_name i) in
          [%expr
            Bindoj_runtime.StringMap.find_opt [%e label] fields
            >>= fun [%p pvari i] -> [%e ret]]) ret
      in
      [%expr function
        | (`obj fields : Kxclib.Json.jv) ->
          let fields = Bindoj_runtime.StringMap.of_list fields in
          [%e body]
        | _ -> None]
  in
  let map_key_converter (k: map_key) = (* key_of_string *)
    match k with
    | `string -> [%expr fun (s: string) -> Some s]
  in
  let string_enum_case (cs: string list) =
    let cases =
      cs |> List.map (fun c ->
        let pat = Pat.constant (Const.string c) in
        let expr = Exp.variant (Utils.escape_as_constructor_name c) None in
        Exp.case pat [%expr Some [%e expr]]
      ) |> fun cases ->
        cases @ [
          Exp.case (Pat.any ()) [%expr None]
        ]
    in
    [%expr function
      | `str s -> [%e Exp.function_ cases] s
      | _ -> None
    ]
  in
  codec_of_coretype
    ~get_custom_codec:Json_config.get_custom_decoder
    ~get_name:get_decoder_name
    ~tuple_case ~map_key_converter ~string_enum_case

let gen_builtin_codecs ?attrs ~get_name ~get_codec (td: type_decl) =
  let loc = Location.none in
  let coders = collect_builtin_codecs td in
  let bind str expr = Vb.mk ~loc ?attrs (Pat.var (strloc str)) expr in
  StringMap.fold (fun label coder state ->
    bind (get_name label `default) (get_codec coder) :: state
  ) coders []

let gen_builtin_encoders : ?attrs:attrs -> type_decl -> value_binding list =
  gen_builtin_codecs ~get_name:get_encoder_name ~get_codec:(fun x -> x.encoder)

let gen_builtin_decoders : ?attrs:attrs -> type_decl -> value_binding list =
  gen_builtin_codecs ~get_name:get_decoder_name ~get_codec:(fun x -> x.decoder)

let gen_json_encoder :
      ?self_contained:bool
      -> ?codec:Coretype.codec
      -> type_decl
      -> value_binding =
  fun ?(self_contained=false) ?(codec=`default) td ->
  let { td_name; td_kind=kind; td_configs; _ } = td in
  let loc = Location.none in
  let self_name =
    match codec with
    | `default -> td_name ^ "_to_json"
    | `in_module _ -> "to_json"
  in
  let self_pname = pvar self_name in
  let self_ename = evar self_name in
  let vari i = "x"^string_of_int i in
  let evari i = evar ~loc (vari i) in
  let pvari i = pvar ~loc (vari i) in
  let wrap_self_contained e =
    if self_contained then
      match gen_builtin_encoders td with
      | [] -> e
      | es ->
         pexp_let ~loc Nonrecursive
           es e
    else e
  in
  let record_params : record_field list -> pattern = fun fields ->
    ppat_record ~loc
      (List.mapi (fun i { rf_name; _; } ->
           (lidloc ~loc rf_name, pvari i))
         fields)
      Closed
  in
  let member_of_field : int -> record_field -> expression =
    fun i { rf_name; rf_type; rf_configs; _ } ->
    let json_field_name = Json_config.get_name_opt rf_configs |? rf_name in
    [%expr ([%e estring ~loc json_field_name],
            [%e encoder_of_coretype self_ename rf_type] [%e evari i])]
  in
  let record_body : record_field list -> expression = fun fields ->
    let members = List.mapi member_of_field fields in
    [%expr `obj [%e elist ~loc members]]
  in
  let variant_params : variant_constructor list -> pattern list = fun constrs ->
    constrs |&> fun { vc_name; vc_param; _ } ->
      let of_record_fields ~label fields =
        match Caml_config.get_variant_type td_configs with
        | `regular ->
          ppat_construct ~loc
            (lidloc ~loc vc_name)
            (Some (record_params fields))
        | `polymorphic ->
          failwith' "case '%s' with an %s cannot be used in a polymorphic variant" vc_name label
      in
      match vc_param with
      | `no_param ->
        begin match Caml_config.get_variant_type td_configs with
        | `regular -> Pat.construct (lidloc vc_name) None
        | `polymorphic -> Pat.variant vc_name None
      end
      | `tuple_like args ->
        let inner = Some (Pat.tuple (List.mapi (fun i _ -> pvari i) args)) in
        begin match Caml_config.get_variant_type td_configs with
        | `regular -> Pat.construct (lidloc vc_name) inner
        | `polymorphic -> Pat.variant vc_name inner
        end
      | `inline_record fields -> of_record_fields ~label:"inline record" fields
      | `reused_inline_record decl ->
        let fields = decl.td_kind |> function
          | Record_decl fields -> fields
          | _ -> failwith' "panic - type decl of reused inline record '%s' muts be record decl." vc_name
        in
        of_record_fields ~label:"reused inline record" fields
  in
  let variant_body : variant_constructor list -> expression list = fun cnstrs ->
    cnstrs |&> fun { vc_name; vc_param; vc_configs; _ } ->
      let discriminator_fname = Json_config.get_variant_discriminator td_configs in
      let discriminator_value = Json_config.get_name_opt vc_configs |? vc_name in
      let arg_fname = Json_config.(get_name_of_variant_arg default_name_of_variant_arg vc_configs) in
      let of_record_fields fields =
        let discriminator_fname = estring ~loc discriminator_fname in
          let cstr = [%expr ([%e discriminator_fname], `str [%e estring ~loc discriminator_value])] in
          let args = List.mapi (fun i field -> member_of_field i field) fields in
          [%expr `obj [%e elist ~loc (cstr :: args)]]
      in
      match Json_config.get_variant_style vc_configs with
      | `flatten -> begin
        match vc_param with
        | `no_param ->
          let cstr = [%expr ([%e estring ~loc discriminator_fname], `str [%e estring ~loc discriminator_value])] in
          [%expr `obj [[%e cstr]]]
        | `tuple_like args ->
          let discriminator_fname = estring ~loc discriminator_fname in
          let arg_fname = estring ~loc arg_fname in
          let cstr = [%expr ([%e discriminator_fname], `str [%e estring ~loc discriminator_value])] in
          let args =
            List.mapi (fun i typ ->
                [%expr [%e encoder_of_coretype self_ename typ] [%e evari i]])
              args in
          begin match args, Json_config.get_tuple_style vc_configs with
          | [], _ -> [%expr `obj [[%e cstr]]]
          | [arg], _ -> [%expr `obj [[%e cstr]; ([%e arg_fname], [%e arg])]]
          | _, `arr -> [%expr `obj [[%e cstr]; ([%e arg_fname], `arr [%e elist ~loc args])]]
          | _, `obj `default ->
            let fields =
              args |> List.mapi (fun i arg ->
                let label = estring ~loc (tuple_index_to_field_name i) in
                [%expr ([%e label], [%e arg])])
            in
            [%expr `obj ([%e cstr] :: [%e elist ~loc fields])]
          end
        | `inline_record fields -> of_record_fields fields
        | `reused_inline_record decl ->
          let fields = decl.td_kind |> function
            | Record_decl fields -> fields
            | _ -> failwith' "panic - type decl of reused inline record '%s' muts be record decl." vc_name
          in
          of_record_fields fields
      end
  in
  match kind with
  | Alias_decl cty ->
    Vb.mk
      ~attrs:(warning_attribute "-39") (* suppress 'unused rec' warning *)
      self_pname
      (pexp_constraint ~loc
         (wrap_self_contained (encoder_of_coretype self_ename cty))
         [%type: [%t typcons ~loc td_name] -> Kxclib.Json.jv])
  | Record_decl fields ->
    let params = record_params fields in
    let body = record_body fields in
    Vb.mk
      ~attrs:(warning_attribute "-39") (* suppress 'unused rec' warning *)
      self_pname
      (pexp_constraint ~loc
        (wrap_self_contained [%expr fun [%p params] -> [%e body]])
        [%type: [%t typcons ~loc td_name] -> Kxclib.Json.jv])
  | Variant_decl ctors ->
    let params = variant_params ctors in
    let body = variant_body ctors in
    let cases =
      List.map2
        (fun p b -> case ~lhs:p ~rhs:b ~guard:None)
        params body
    in
    Vb.mk
      ~attrs:(warning_attribute "-39") (* suppress 'unused rec' warning *)
      self_pname
      (pexp_constraint ~loc
        (wrap_self_contained (pexp_function ~loc cases))
        [%type: [%t typcons ~loc td_name] -> Kxclib.Json.jv])

let gen_json_decoder :
      ?self_contained:bool
      -> ?codec:Coretype.codec
      -> type_decl
      -> value_binding =
  fun ?(self_contained=false) ?(codec=`default) td ->
  let { td_name; td_kind=kind; td_configs; _ } = td in
  let loc = Location.none in
  let self_name =
    match codec with
    | `default -> td_name ^ "_of_json"
    | `in_module _ -> "of_json"
  in
  let self_pname = pvar self_name in
  let self_ename = evar self_name in
  let vari i = "x"^string_of_int i in
  let evari i = evar ~loc (vari i) in
  let pvari i = pvar ~loc (vari i) in
  let param_e = evar ~loc "param" in
  let param_p = pvar ~loc "param" in
  let wrap_self_contained e =
    if self_contained then
      match gen_builtin_decoders td with
      | [] -> e
      | es ->
         pexp_let ~loc Nonrecursive
           es e
    else e
  in
  let bind_options : (pattern * expression) list -> expression -> expression = fun bindings body ->
    [%expr
     let (>>=) = Option.bind in
         [%e List.fold_right (fun (p, e) body ->
               [%expr [%e e] >>= (fun [%p p] -> [%e body])])
             bindings body]]
  in
  let record_bindings : record_field list -> (pattern * expression) list = fun fields ->
    List.mapi (fun i { rf_name; rf_type; rf_configs; _; } ->
        let json_field_name = Json_config.get_name_opt rf_configs |? rf_name in
        let expr =
          if Coretype.is_option rf_type then
            [%expr
              List.assoc_opt [%e estring ~loc json_field_name] [%e param_e]
              |> Option.value ~default:`null
              |> [%e decoder_of_coretype self_ename rf_type]]
          else
            [%expr
              List.assoc_opt [%e estring ~loc json_field_name] [%e param_e]
              >>= [%e decoder_of_coretype self_ename rf_type]]
          in
        pvari i, expr)
      fields
  in
  let record_body : record_field list -> expression = fun fields ->
    pexp_record ~loc
      (List.mapi (fun i { rf_name; _; } ->
          (lidloc ~loc rf_name, [%expr [%e evari i]]))
         fields)
      None
  in
  let variant_params : variant_constructor list -> pattern list = fun cstrs ->
    cstrs |&> fun { vc_name; vc_param; vc_configs; _ } ->
      let discriminator_fname = Json_config.get_variant_discriminator td_configs in
      let discriminator_value = Json_config.get_name_opt vc_configs |? vc_name in
      let arg_fname = Json_config.(get_name_of_variant_arg default_name_of_variant_arg vc_configs) in
      match Json_config.get_variant_style vc_configs with
      | `flatten -> begin
        match vc_param with
        | `no_param ->
          let discriminator_fname = pstring ~loc discriminator_fname in
          let cstr = [%pat? ([%p discriminator_fname], `str [%p pstring ~loc discriminator_value])] in
          [%pat? `obj [[%p cstr]]]
        | `tuple_like args ->
          let discriminator_fname = pstring ~loc discriminator_fname in
          let arg_fname = pstring ~loc arg_fname in
          let cstr = [%pat? ([%p discriminator_fname], `str [%p pstring ~loc discriminator_value])] in
          let args = List.mapi (fun i _ -> pvari i) args in
          begin match args, Json_config.get_tuple_style vc_configs with
          | [], _ -> [%pat? `obj [[%p cstr]]]
          | [arg], _ -> [%pat? `obj [[%p cstr]; ([%p arg_fname], [%p arg])]]
          | _, `arr -> [%pat? `obj [[%p cstr]; ([%p arg_fname], `arr [%p plist ~loc args])]]
          | _, `obj `default -> [%pat? `obj ([%p cstr] :: fields)]
          end
        | `inline_record _
        | `reused_inline_record _ ->
          let discriminator_fname = pstring ~loc discriminator_fname in
          let cstr = [%pat? ([%p discriminator_fname], `str [%p pstring ~loc discriminator_value])] in
          [%pat? `obj ([%p cstr] :: [%p param_p])]
      end
  in
  let variant_body : variant_constructor list -> expression list = fun cstrs ->
    let construct name args =
      match Caml_config.get_variant_type td_configs with
      | `regular -> Exp.construct (lidloc name) args
      | `polymorphic -> Exp.variant name args
    in
    cstrs |&> fun { vc_name; vc_param; vc_configs; _ } ->
      let of_record_fields ~label fields =
        begin match fields with
        | [] -> construct vc_name None
        | _ ->
          let bindings = record_bindings fields in
          let body =
            match Caml_config.get_variant_type td_configs with
            | `regular -> record_body fields
            | `polymorphic -> failwith' "case '%s' with an %s cannot be used in a polymorphic variant" vc_name label
          in
          bind_options bindings [%expr Some [%e (construct vc_name (Some body))]]
        end
      in
      match vc_param with
      | `no_param -> [%expr Some [%e construct vc_name None]]
      | `tuple_like args ->
        let style = Json_config.get_tuple_style vc_configs in
        begin match args with
        | [] -> [%expr Some [%e construct vc_name None]]
        | _ ->
          let len = List.length args in
          let bindings : (pattern * expression) list =
            List.mapi (fun i arg ->
              match style with
              | `obj `default when len > 1 -> (
                let label = estring ~loc (tuple_index_to_field_name i) in
                pvari i, [%expr
                  Bindoj_runtime.StringMap.find_opt [%e label] fields >>= [%e decoder_of_coretype self_ename arg]
                ])
              | _ -> (pvari i, [%expr [%e decoder_of_coretype self_ename arg] [%e evari i]])
            ) args in
          let body : expression =
            [%expr Some
                [%e construct
                    vc_name
                    (Some (pexp_tuple ~loc (List.mapi (fun i _ -> evari i) args)))]] in
          match style with
          | `obj `default when len > 1 ->
            [%expr let fields = Bindoj_runtime.StringMap.of_list fields in [%e bind_options bindings body]]
          | _ -> bind_options bindings body
        end
      | `inline_record fields ->
        of_record_fields ~label:"inline record" fields
      | `reused_inline_record decl ->
        let fields =
          decl.td_kind |> function
          | Record_decl fields -> fields
          | _ -> failwith' "panic - type decl of reused inline record '%s' muts be record decl." vc_name
        in
        of_record_fields ~label:"reused inline record" fields

  in
  begin match kind with
  | Alias_decl cty ->
    Vb.mk
      ~attrs:(warning_attribute "-39") (* suppress 'unused rec' warning *)
      self_pname
      (pexp_constraint ~loc
         (wrap_self_contained (decoder_of_coretype self_ename cty))
         [%type: Kxclib.Json.jv -> [%t typcons ~loc td_name] option])
  | Record_decl fields ->
    let bindings = record_bindings fields in
    let body = record_body fields in
    Vb.mk
      ~attrs:(warning_attribute "-39") (* suppress 'unused rec' warning *)
      self_pname
      (pexp_constraint ~loc
        (wrap_self_contained
            [%expr function
                | `obj [%p param_p] -> [%e bind_options bindings [%expr Some [%e body]]]
                | _ -> None])
        [%type: Kxclib.Json.jv -> [%t typcons ~loc td_name] option])
  | Variant_decl ctors ->
    let params = variant_params ctors in
    let body = variant_body ctors in
    let discriminator = Json_config.get_variant_discriminator td_configs in
    let cases =
      List.map2
        (fun p b -> case ~lhs:p ~rhs:b ~guard:None)
        params body
      @ [(case ~lhs:(ppat_any ~loc) ~rhs:[%expr None] ~guard:None)] in
    Vb.mk
      ~attrs:(warning_attribute "-39") (* suppress 'unused rec' warning *)
      self_pname
      (pexp_constraint ~loc
        [%expr fun __bindoj_orig ->
            Kxclib.Jv.pump_field [%e estring ~loc discriminator ] __bindoj_orig
            |> [%e (wrap_self_contained (pexp_function ~loc cases))]]
        [%type: Kxclib.Json.jv -> [%t typcons ~loc td_name] option])
  end

let gen_json_codec ?self_contained ?codec td =
  let rec_flag = match td.td_kind with
    | Alias_decl _ -> Nonrecursive
    | Record_decl _ | Variant_decl _ -> Recursive
  in
  [Str.value rec_flag [
       gen_json_encoder ?self_contained ?codec td;
       gen_json_decoder ?self_contained ?codec td;
  ]]

open Bindoj_openapi.V3

exception Incompatible_with_openapi_v3 of string

let base64_regex = {|^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/][AQgw]==|[A-Za-z0-9+\/]{2}[AEIMQUYcgkosw048]=)?$|}

let gen_json_schema : ?openapi:bool -> type_decl -> Schema_object.t =
  fun ?(openapi=false) ->

  let docopt = function `docstr s -> Some s | `nodoc -> None in

  let convert_coretype ~self_name ?description (ct: coretype) =
    let tuple_style = Json_config.get_tuple_style ct.ct_configs in
    let rec go =
      let open Coretype in
      function
      | Prim `unit -> Schema_object.integer ~minimum:1 ~maximum:1 ?description ()
      | Prim `bool -> Schema_object.boolean ?description ()
      | Prim `int -> Schema_object.integer ?description ()
      | Prim `int53p -> Schema_object.integer ?description ()
      | Prim `float -> Schema_object.number ?description ()
      | Prim `string -> Schema_object.string ?description ()
      | Prim `uchar -> Schema_object.string ~minLength:1 ~maxLength:1 ?description ()
      | Prim `byte -> Schema_object.integer ~minimum:0 ~maximum:255 ?description ()
      | Prim `bytes -> Schema_object.string ~format:`byte ~pattern:base64_regex ?description ()
      | Uninhabitable -> Schema_object.null ?description ()
      | Ident id ->
        if openapi then (* in OpenAPI, types live in #/components/schemas/ *)
          Schema_object.ref ("#/components/schemas/" ^ id.id_name)
        else
          Schema_object.ref ("#" ^ id.id_name)
      | Option t ->
        Schema_object.option (go t)
      | Tuple ts ->
        begin match tuple_style with
        | `arr ->
          if openapi then
            raise (Incompatible_with_openapi_v3 (
              sprintf "OpenAPI v3 does not support tuple validation (in type '%s')" self_name))
          else
            Schema_object.tuple ?description (ts |> List.map go)
        | `obj `default ->
          Schema_object.record ?description (ts |> List.mapi (fun i x ->
            tuple_index_to_field_name i, go x
          ))
        end
      | List t ->
        Schema_object.array ?description ~items:(`T (go t)) ()
      | Map (`string, t) ->
        Schema_object.obj ?description ~additionalProperties:(`T (go t)) ()
      | StringEnum cases ->
        let enum = cases |> List.map (fun case -> `str case) in
        Schema_object.string ~enum ()
      | Self ->
        if openapi then (* in OpenAPI, types live in #/components/schemas/ *)
          Schema_object.ref ("#/components/schemas/" ^ self_name)
        else
          Schema_object.ref ("#" ^ self_name)
    in
    match ct.ct_configs |> Configs.find_foreign_type_expr json_schema with
    | Some schema -> schema
    | None -> go ct.ct_desc
  in

  let record_to_t ?schema ?id ?(additional_fields = []) ~name ~self_name ~doc fields =
    let field_to_t field =
      let json_field_name =
        Json_config.get_name_opt field.rf_configs |? field.rf_name
      in
      json_field_name,
      convert_coretype ~self_name ?description:(docopt field.rf_doc) field.rf_type
    in
    let fields = fields |> List.map field_to_t in
    Schema_object.record
      ?schema
      ~title:name
      ?description:(docopt doc)
      ?id
      (fields @ additional_fields)
  in

  fun { td_name = name; td_kind; td_doc = doc; td_configs } ->
    let self_name = name in

    let schema =
      if openapi then None (* OpenAPI v3 does not support `$schema` *)
      else Some Schema_object.schema in

    let id =
      if openapi then None (* OpenAPI v3 does not support `id` *)
      else Some ("#" ^ name) in

    match td_kind with
    | Record_decl fields ->
      record_to_t ?schema ?id ~name ~self_name ~doc fields
    | Variant_decl ctors ->
      let discriminator_fname = Json_config.get_variant_discriminator td_configs in
      let ctor_to_t { vc_name; vc_param; vc_doc = doc; vc_configs } =
        let discriminator_value = Json_config.get_name_opt vc_configs |? vc_name in
        let discriminator_field =
          let enum = [`str discriminator_value] in
          [discriminator_fname, Schema_object.string ~enum ()]
        in
        match Json_config.get_variant_style vc_configs with
        | `flatten ->
          begin match vc_param with
            | `no_param | `tuple_like [] ->
              Schema_object.record ?description:(docopt doc) ~title:discriminator_value discriminator_field
            | `tuple_like (t :: ts) ->
              let arg_name = Json_config.(get_name_of_variant_arg default_name_of_variant_arg vc_configs) in
              let arg_field =
                match ts, Json_config.get_tuple_style vc_configs with
                | [], _ -> [arg_name, convert_coretype ~self_name t]
                | _, `arr ->
                  if openapi then
                    raise (Incompatible_with_openapi_v3 (
                      sprintf "OpenAPI v3 does not support tuple validation (in type '%s')" self_name))
                  else
                    let ts = t :: ts |> List.map (convert_coretype ~self_name) in
                    [arg_name, Schema_object.tuple ts]
                | _, `obj `default ->
                  t :: ts |> List.mapi (fun i t ->
                    tuple_index_to_field_name i, convert_coretype ~self_name t
                  )
              in
              let fields = discriminator_field @ arg_field in
              Schema_object.record ?description:(docopt doc) ~title:discriminator_value fields
            | `inline_record fields ->
              record_to_t ~additional_fields:discriminator_field ~name:discriminator_value ~self_name ~doc fields
            | `reused_inline_record decl ->
              let fields = decl.td_kind |> function
                | Record_decl fields -> fields
                | _ -> failwith' "panic - type decl of reused inline record '%s' muts be record decl." vc_name
              in
              record_to_t ~additional_fields:discriminator_field ~name:discriminator_value ~self_name ~doc fields

          end
      in
      Schema_object.oneOf
        ?schema
        ~title:name
        ?description:(docopt doc)
        ?id
        (ctors |> List.map ctor_to_t)
    | Alias_decl cty ->
      convert_coretype ~self_name ?description:(docopt doc) cty

let gen_openapi_schema : type_decl -> Schema_object.t = gen_json_schema ~openapi:true
