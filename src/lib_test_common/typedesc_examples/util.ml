(* Copyright 2022-2023 Kotoi-Xie Consultancy, Inc. This file is a part of the

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
open Bindoj_gen_ts.Typescript_datatype
open Bindoj_gen_foreign.Foreign_datatype

module Ts_ast = struct
  type options =
    { discriminator : string;
      var_x : string;
      var_v : string;
      var_fns : string;
      ret : string; }

  let rec find_prop_opt f = function
    | `type_literal ps -> List.find_opt f ps
    | `intersection tds ->
      List.fold_left
        (fun s td -> s |> Option.otherwise' (fun () -> find_prop_opt f td))
        None tds
    | _ -> None

  type literal = (string * ts_type_desc)
  let compare_literal (xname, (_: ts_type_desc)) (yname, (_: ts_type_desc)) = String.compare xname yname

  let case_analyzer_parameters :
    options -> literal list -> ts_parameter list =
    fun options cstrs ->
    [ { tsp_name = options.var_fns;
        tsp_type_desc =
          `type_literal
            (cstrs |&> fun (_, desc) ->
                desc
                |> find_prop_opt (fun { tsps_name; _; } -> tsps_name = options.discriminator)
                |> function
                | Some { tsps_type_desc = `literal_type (`string_literal kind); _; } ->
                  { tsps_modifiers = [];
                    tsps_name = kind;
                    tsps_type_desc =
                      `func_type
                        { tsft_parameters =
                            [ { tsp_name = options.var_v;
                                tsp_type_desc = desc; } ];
                          tsft_type_desc = `type_reference options.ret; }; }
                | _ -> failwith "impossible case"); } ]


  let case_analyzer_body :
    string -> string -> options -> literal list -> ts_ast =
    fun name func_name options cstrs ->
    [ `return_statement
        (`arrow_function
           { tsaf_parameters =
               [ { tsp_name = options.var_x;
                   tsp_type_desc = `type_reference name; } ];
             tsaf_body =
               [ cstrs |> List.sort compare_literal |> List.rev |@>
                 (`throw_statement
                    (`new_expression
                       { tsne_expression = `identifier "TypeError";
                         tsne_arguments =
                           [ `binary_expression
                               { tsbe_left =
                                   `literal_expression
                                     (`string_literal ("panic @" ^ func_name ^ " - unrecognized: "));
                                 tsbe_operator_token = "+";
                                 tsbe_right = `identifier options.var_x; } ]; }),
                  fun (statement, (_, desc)) ->
                    desc
                    |> find_prop_opt (fun { tsps_name; _; } -> tsps_name = options.discriminator)
                    |> function
                    | Some { tsps_type_desc = `literal_type (`string_literal kind); _; } ->
                      `if_statement
                        ((`binary_expression
                            { tsbe_left =
                                `property_access_expression
                                  { tspa_expression = `identifier options.var_x;
                                    tspa_name = options.discriminator; };
                              tsbe_operator_token = "===";
                              tsbe_right = `literal_expression (`string_literal kind); }),
                         (`return_statement
                            (`call_expression
                               { tsce_expression =
                                   `element_access_expression
                                     { tsea_expression = (`identifier options.var_fns);
                                       tsea_argument =
                                         `property_access_expression
                                           { tspa_expression = `identifier options.var_x;
                                             tspa_name = options.discriminator; }; };
                                 tsce_arguments = [ `identifier options.var_x ]; })),
                         statement)
                    | _ -> failwith "impossible case in test") ]; } ) ]

  let case_analyzer :
    string -> string -> options -> literal list -> ts_statement =
    fun name func_name options cstrs ->
    `function_declaration
      { tsf_modifiers = [`export];
        tsf_name = func_name;
        tsf_type_parameters = [options.ret];
        tsf_parameters = case_analyzer_parameters options cstrs;
        tsf_type_desc =
          `func_type
            { tsft_parameters =
                [ { tsp_name = options.var_x;
                    tsp_type_desc = `type_reference name; } ];
              tsft_type_desc = `type_reference options.ret; };
        tsf_body =
          case_analyzer_body name func_name options cstrs; }
end

module FwrtTypeEnv =
  FwrtTypeEnv'(struct
    type annot_d = unit
    type annot_f = unit
    type annot_va = unit
    type annot_ko = unit
    type annot_ka = unit
    type annot_kc = ts_fwrt_constructor_kind_annot
    let default_annot_d = ()
    let default_annot_f = ()
    let default_annot_va = ()
    let default_annot_ko = ()
    let default_annot_ka = ()
    let default_annot_kc = None
    let default_annot_d_f = constant ()
  end)

module Schema_object = struct
  open Bindoj_openapi.V3.Schema_object
  let variant ?(discriminator_fname = "kind") name ctors =
    ctors
    |&> (fun (title, fields) ->
      fields @ [ discriminator_fname, string () ~enum:[`str title] ]
      |> record ~title)
    |> oneOf ~schema ~title:name ~id:("#"^name)
end
