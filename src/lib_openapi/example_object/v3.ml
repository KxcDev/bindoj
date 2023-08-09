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
open Bindoj_openapi_util.V3

type t = {
  summary : string option [@yojson.option];
  description : string option [@yojson.option];
  value : jv option [@yojson.option];
  externalValue : string option [@yojson.option];
} [@@deriving show, yojson_of]

let mk ?summary ?description ?value ?externalValue () = {
  summary = summary;
  description = description;
  value = value;
  externalValue = externalValue;
}

let to_json : t -> jv = fun t ->
  t |> yojson_of_t |> Json.of_yojson
