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
open Bindoj_base.Type_desc
open Bindoj_gen_foreign.Foreign_datatype
open Bindoj_gen_ts.Typescript_datatype

let example_module_path = "Bindoj_test_common_typedesc_examples.Ex05_notuple"

let cty_int_opt = Coretype.(mk_option % prim) `int
let cty_int_lst = Coretype.(mk_list % prim) `int
let cty_int_map = Coretype.(mk_map `string % prim) `int

let decl : type_decl =
  record_decl "complex_types" [
    record_field "option" cty_int_opt;

    record_field "list" cty_int_lst;

    record_field "map" cty_int_map;
  ]

let decl_with_docstr : type_decl =
  record_decl "complex_types" [
    record_field "option" cty_int_opt
      ~doc:(`docstr "int option");

    record_field "list" cty_int_lst
      ~doc:(`docstr "int list");

    record_field "map" cty_int_map
      ~doc:(`docstr "map<string, int>");
  ] ~doc:(`docstr "collection of complex types")

let fwrt : (unit, unit) fwrt_decl =
  let annot = () in
  "complex_types", FwrtTypeEnv.(
    init
    |> bind_object ~annot "complex_types" [
      field ~annot "option" cty_int_opt;
      field ~annot "list" cty_int_lst;
      field ~annot "map" cty_int_map;
    ]
  )

let ts_ast : ts_ast option = None