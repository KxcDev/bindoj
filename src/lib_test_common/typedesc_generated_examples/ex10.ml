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
include Bindoj_gen_test_gen_output.Ex10_gen
open Bindoj_base

type t = xy_opt = { x_opt : int option; y_opt : int option } [@@deriving show]
let decl = Bindoj_test_common_typedesc_examples.Ex10.decl
let reflect = xy_opt_reflect

let to_json = xy_opt_to_json
let of_json = xy_opt_of_json
let env =
  empty_tdenv
  |> Bindoj_std.Tdenv_wrappers.json

let t : t Alcotest.testable = Alcotest.of_pp pp

let sample_value01 : t Sample_value.t = {
  orig = {
    x_opt = None;
    y_opt = None;
  };
  jv = `obj [
    "x_opt", `null;
    "y_opt", `null;
  ]
}

let sample_value02 : t Sample_value.t = {
  orig = {
    x_opt = None;
    y_opt = Some 42;
  };
  jv = `obj [
    "x_opt", `null;
    "y_opt", `num 42.;
  ]
}

let sample_value03 : t Sample_value.t = {
  orig = {
    x_opt = Some (-25);
    y_opt = None;
  };
  jv = `obj [
    "x_opt", `num (-25.);
    "y_opt", `null;
  ]
}

let sample_value04 : t Sample_value.t = {
  orig = {
    x_opt = Some 512;
    y_opt = Some (-119);
  };
  jv = `obj [
    "x_opt", `num 512.;
    "y_opt", `num (-119.);
  ]
}

let sample_values = [
  sample_value01;
  sample_value02;
  sample_value03;
  sample_value04;
]