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
include Bindoj_gen_test_gen_output.Ex16_gen
open Bindoj_base

type t = nested_record =
  { unit: Ex11.t;
    student: Ex01.t;
    int53p: Ex09.t;
    person1: Ex02_no_mangling.t;
    person2: Ex02_no_mangling.t; }
[@@deriving show]

let decl = Bindoj_test_common_typedesc_examples.Ex16.decl
let reflect = nested_record_reflect

let json_shape_explanation = nested_record_json_shape_explanation
let to_json = nested_record_to_json
let of_json' = nested_record_of_json'

let env =
  let open Bindoj_typedesc.Typed_type_desc in
  { Type_decl_environment.empty with
    alias_ident_typemap =
      StringMap.of_list [
        "unit",
        (Boxed (Typed.mk Ex11.decl Ex11.reflect));
        "student",
        (Boxed (Typed.mk Ex01.decl Ex01.reflect));
        "with_int53p",
        (Boxed (Typed.mk Ex09.decl Ex09.reflect));
        "person",
        (Boxed (Typed.mk Ex02_no_mangling.decl Ex02_no_mangling.reflect));
      ] }

let t : t Alcotest.testable = Alcotest.of_pp pp

open struct
  let sample_student: Ex01.t =
    { admission_year = 1984;
      name = "William Gibson";
    }
  let sample_student_jv_fields =
    [ ("admissionYear", `num 1984.);
      ("name", `str "William Gibson")
    ]

  let sample_int53p: Ex09.t =
    { value = (Kxclib.Int53p.of_int 102) }
  let sample_int53p_jv_fields = [
    "value", `num 102.
  ]

  let sample_persons = Ex02_no_mangling.[
    Anonymous, [
      "kind", `str "Anonymous"
    ];
    With_id 1619, [
      ("kind", `str "With_id");
      ("arg", `num 1619.);
    ];
    Student {
      student_id = 451;
      name = "Ray Bradbury"
    }, [
        ("kind", `str "Student");
        ("student_id", `num 451.);
        ("name", `str "Ray Bradbury");
      ];
    Teacher {
      faculty_id = 2001;
      name = "Arthur C. Clark";
      department = "Space";
    }, [
      ("kind", `str "Teacher");
      ("faculty_id", `num 2001.);
      ("name", `str "Arthur C. Clark");
      ("department", `str "Space");
    ]
  ]
end

let sample_values : t Sample_value.t list =
  sample_persons |> List.map (fun (person, person_fields) ->
    { Sample_value.orig =
        { unit = ();
          student = sample_student;
          int53p = sample_int53p;
          person1 = person;
          person2 = person;
        };
      jv = `obj (
        [ ("unit", `num 1.); ("student", `obj sample_student_jv_fields) ]
        @ sample_int53p_jv_fields
        @ [ ("person1", `obj person_fields) ]
        @ person_fields)
    })
