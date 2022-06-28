(* Copyright 2022 Kotoi-Xie Consultancy

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. *)

include Bindoj_gen_test_gen_output.Ex01_gen

type t = student = { admission_year: int; name: string } [@@deriving show]

let to_json = student_to_json
let of_json = student_of_json
let t : t Alcotest.testable = Alcotest.of_pp pp

let sample_value01 : t Sample_value.t = {
  orig = {
    admission_year = 1984;
    name = "William Gibson";
  };
  jv = `obj [
    ("admission_year", `num 1984.);
    ("name", `str "William Gibson")
  ];
}

let sample_values = [
  sample_value01;
]