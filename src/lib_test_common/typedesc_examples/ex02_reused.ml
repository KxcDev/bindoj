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
open Bindoj_base.Type_desc
open Bindoj_gen_ts.Typescript_datatype
open Bindoj_codec.Json

let example_module_path = "Bindoj_test_common_typedesc_examples.Ex02_reused"

let discriminator = "kind"

let cty_int = Coretype.mk_prim `int
let cty_string = Coretype.mk_prim `string

let teacher_decl : type_decl =
  record_decl "teacher" [
    record_field "faculty_id" cty_int;
    record_field "name" cty_string;
    record_field "department" cty_string;
  ]

let teacher_decl_with_docstr : type_decl =
  record_decl "teacher" [
    record_field "faculty_id" cty_int
      ~doc:(`docstr "faculty_id field in Teacher constructor");
    record_field "name" cty_string
      ~doc:(`docstr "name field in Teacher constructor");
    record_field "department" cty_string
      ~doc:(`docstr "dapartment field in Teacher constructor");
  ] ~doc:(`docstr "definition of teacher type")

let json_name = "person_reused"
let json_name_mangled = "PersonReused"
let configs : [`type_decl] configs = Json_config.[ name json_name ]

let decl : type_decl =
  variant_decl "person" [
    variant_constructor "Anonymous" `no_param;
    variant_constructor "With_id" (`tuple_like [variant_argument cty_int]);
    variant_constructor "Student" (`inline_record [
      record_field "student_id" cty_int;
      record_field "name" cty_string;
    ]);
    variant_constructor "Teacher" (`reused_inline_record teacher_decl)
      ~configs: [ Ts_config.reused_variant_inline_record_style `intersection_type ]
  ] ~configs

let decl_with_docstr : type_decl =
  variant_decl "person" [
    variant_constructor "Anonymous" `no_param
      ~doc:(`docstr "Anonymous constructor");

    variant_constructor "With_id" (`tuple_like [variant_argument cty_int])
      ~doc:(`docstr "With_id constructor");

    variant_constructor "Student" (`inline_record [
      record_field "student_id" cty_int
        ~doc:(`docstr "student_id field in Student constructor");
      record_field "name" cty_string
        ~doc:(`docstr "name field in Student constructor");
    ]) ~doc:(`docstr "Student constructor");

    variant_constructor "Teacher" (`reused_inline_record teacher_decl_with_docstr)
      ~doc:(`docstr "Teacher constructor")
      ~configs: [ Ts_config.reused_variant_inline_record_style `intersection_type ]

  ] ~configs ~doc:(`docstr "definition of person type")

let fwrt : (unit, unit, unit) ts_fwrt_decl =
  let parent = "person" in
  "person", Util.FwrtTypeEnv.(
    init
    |> bind_object "person" [] ~configs
    |> bind_constructor ~parent "Anonymous"
    |> bind_constructor ~parent "With_id" ~args:[variant_argument cty_int]
    |> bind_constructor ~parent "Student" ~fields:[
      field "student_id" cty_int;
      field "name" cty_string]
    |> bind_constructor ~parent
      ~annot_kc:(Some (Tfcki_reused_variant_inline_record teacher_decl))
      "Teacher" ~fields:[
      field "faculty_id" cty_int;
      field "name" cty_string;
      field "department" cty_string]
      ~configs: [ Ts_config.reused_variant_inline_record_style `intersection_type ]
  )

let ts_ast : ts_ast option =
  let discriminator = "kind" in
  let arg_fname = "arg" in
  let discriminator_value kind =
    Util.Ts_ast.property discriminator (`literal_type (`string_literal kind))
  in
  let anonymous =
    `type_literal
      [ discriminator_value "anonymous"; ] in
  let with_id =
    `type_literal
      [ discriminator_value "with-id";
        Util.Ts_ast.property arg_fname (`type_reference "number") ] in
  let student =
    `type_literal
      Util.Ts_ast.[
        discriminator_value "student";
        property "studentId" (`type_reference "number");
        property "name" (`type_reference "string") ] in
  let teacher =
    `intersection
      [`type_literal [ discriminator_value "teacher" ];
        `type_reference "Teacher" ] in
  let person = [
    "With_id", with_id;
    "Teacher", teacher;
    "Student", student;
    "Anonymous", anonymous;
  ] in
  let options : Util.Ts_ast.options =
    { discriminator;
      var_v = "__bindoj_v";
      var_x = "__bindoj_x";
      var_fns = "__bindoj_fns";
      ret = "__bindoj_ret" } in
  Some
    [ `type_alias_declaration
        { tsa_modifiers = [`export];
          tsa_name = json_name_mangled;
          tsa_type_parameters = [];
          tsa_type_desc = `union (List.map snd person); };
      Util.Ts_ast.case_analyzer json_name_mangled ("analyze"^json_name_mangled) options person; ]

let expected_json_shape_explanation = None

open Bindoj_openapi.V3

let schema_object : Schema_object.t option =
  Util.Schema_object.variant json_name_mangled
    Schema_object.[
      "anonymous", [];
      "with-id", [ "arg", integer () ];
      "student", [
        "studentId", integer ();
        "name", string ();
      ];
      "teacher", [
        "facultyId", integer ();
        "name", string ();
        "department", string ();
      ]; ]
  |> Option.some
