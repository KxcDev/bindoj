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

open Bindoj_test_common.Typedesc_generated_examples

let print_json (module Ex : T) =
  Ex.sample_values
  |> List.map Sample_value.orig
  |> List.map Ex.to_json
  |> (fun x -> `arr x)
  |> Json.to_yojson
  |> Yojson.Safe.to_string
  |> print_endline

let mapping =
  all |> List.map (fun (s, m) -> sprintf "%s_examples.json" s, m)

let () =
  match Array.to_list Sys.argv |> List.tl with
  | [] | _ :: _ :: _ ->
    failwith "usage: gen <filename>"
  | [name] ->
    match List.assoc_opt name mapping with
    | None -> failwith (sprintf "unknown example %s" name)
    | Some m -> print_json m