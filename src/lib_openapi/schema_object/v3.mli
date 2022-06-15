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

(** schema URI. ["https://json-schema.org/draft-04/schema#"] *)
val schema: string

(** OpenAPI Schema Object *)
type t

(** https://spec.openapis.org/oas/v3.0.3.html#discriminator-object *)
type discriminator

(** https://spec.openapis.org/oas/v3.0.3.html#discriminator-object *)
val discriminator :
  ?mapping:(string * string) list -> (* property name *) string -> discriminator

(** https://spec.openapis.org/oas/v3.0.3.html#external-documentation-object *)
type externalDocs

(** https://spec.openapis.org/oas/v3.0.3.html#external-documentation-object *)
val externalDocs : ?description:string -> (* url *) string -> externalDocs

(* シグネチャのコピペ用
  ?schema:string ->
  ?title:string ->
  ?description:string ->
  ?default:Json.jv ->
  ?example:Json.jv ->
  ?enum:Json.jv list ->
  ?nullable:bool ->
  ?deprecated:bool ->
  ?readOnly:bool ->
  ?writeOnly:bool ->
  ?id:string ->
  ?definitions:(string * t) list ->
  ?discriminator:discriminator -> ?externalDocs:externalDocs ->
*)

(** https://json-schema.org/understanding-json-schema/structuring.html#ref *)
val ref :
  string -> t

(** https://json-schema.org/understanding-json-schema/reference/string.html#built-in-formats *)
type string_format = [
  (* dates and times *)
  | `date_time [@name "date-time"]
  (* email addresses *)
  | `email
  (* host names *)
  | `hostname
  (* IP addresses *)
  | `ipv4 | `ipv6
  (* resource identifiers *)
  | `uri
]

(** https://json-schema.org/understanding-json-schema/reference/string.html *)
val string :
  ?schema:string ->
  ?title:string ->
  ?description:string ->
  ?default:Json.jv ->
  ?example:Json.jv ->
  ?enum:Json.jv list ->
  ?nullable:bool ->
  ?deprecated:bool ->
  ?readOnly:bool ->
  ?writeOnly:bool ->
  ?id:string ->
  ?definitions:(string * t) list ->
  ?discriminator:discriminator -> ?externalDocs:externalDocs ->
  ?minLength:int -> ?maxLength:int ->
  ?pattern:string -> ?format:string_format -> unit -> t

(** https://json-schema.org/understanding-json-schema/reference/numeric.html#integer *)
val integer :
  ?schema:string ->
  ?title:string ->
  ?description:string ->
  ?default:Json.jv ->
  ?example:Json.jv ->
  ?enum:Json.jv list ->
  ?nullable:bool ->
  ?deprecated:bool ->
  ?readOnly:bool ->
  ?writeOnly:bool ->
  ?id:string ->
  ?definitions:(string * t) list ->
  ?discriminator:discriminator -> ?externalDocs:externalDocs ->
  ?multipleOf:int ->
  ?minimum:int ->
  ?maximum:int ->
  ?exclusiveMinimum:bool -> ?exclusiveMaximum:bool -> unit -> t

(** https://json-schema.org/understanding-json-schema/reference/numeric.html#number *)
val number :
  ?schema:string ->
  ?title:string ->
  ?description:string ->
  ?default:Json.jv ->
  ?example:Json.jv ->
  ?enum:Json.jv list ->
  ?nullable:bool ->
  ?deprecated:bool ->
  ?readOnly:bool ->
  ?writeOnly:bool ->
  ?id:string ->
  ?definitions:(string * t) list ->
  ?discriminator:discriminator -> ?externalDocs:externalDocs ->
  ?multipleOf:float ->
  ?minimum:float ->
  ?maximum:float ->
  ?exclusiveMinimum:bool -> ?exclusiveMaximum:bool -> unit -> t

(** https://json-schema.org/understanding-json-schema/reference/boolean.html *)
val boolean :
  ?schema:string ->
  ?title:string ->
  ?description:string ->
  ?default:Json.jv ->
  ?example:Json.jv ->
  ?enum:Json.jv list ->
  ?nullable:bool ->
  ?deprecated:bool ->
  ?readOnly:bool ->
  ?writeOnly:bool ->
  ?id:string ->
  ?definitions:(string * t) list ->
  ?discriminator:discriminator -> ?externalDocs:externalDocs ->
  unit -> t

(** https://json-schema.org/understanding-json-schema/reference/null.html *)
val null :
  ?schema:string ->
  ?title:string ->
  ?description:string ->
  ?default:Json.jv ->
  ?example:Json.jv ->
  ?enum:Json.jv list ->
  ?nullable:bool ->
  ?deprecated:bool ->
  ?readOnly:bool ->
  ?writeOnly:bool ->
  ?id:string ->
  ?definitions:(string * t) list ->
  ?discriminator:discriminator -> ?externalDocs:externalDocs ->
  unit -> t

(** https://json-schema.org/understanding-json-schema/reference/array.html *)
val array :
  ?schema:string ->
  ?title:string ->
  ?description:string ->
  ?default:Json.jv ->
  ?example:Json.jv ->
  ?enum:Json.jv list ->
  ?nullable:bool ->
  ?deprecated:bool ->
  ?readOnly:bool ->
  ?writeOnly:bool ->
  ?id:string ->
  ?definitions:(string * t) list ->
  ?discriminator:discriminator -> ?externalDocs:externalDocs ->
  ?items:[`T of t | `TList of t list] ->
  ?additionalItems:t list ->
  ?minItems:int -> ?maxItems:int -> unit -> t

(** https://json-schema.org/understanding-json-schema/reference/object.html *)
val obj :
  ?schema:string ->
  ?title:string ->
  ?description:string ->
  ?default:Json.jv ->
  ?example:Json.jv ->
  ?enum:Json.jv list ->
  ?nullable:bool ->
  ?deprecated:bool ->
  ?readOnly:bool ->
  ?writeOnly:bool ->
  ?id:string ->
  ?definitions:(string * t) list ->
  ?discriminator:discriminator -> ?externalDocs:externalDocs ->
  ?properties:(string * t) list ->
  ?required:string list -> ?additionalProperties:[`T of t | `False] ->
  unit -> t

(** https://json-schema.org/understanding-json-schema/reference/combining.html#allof *)
val allOf :
  ?schema:string ->
  ?title:string ->
  ?description:string ->
  ?default:Json.jv ->
  ?example:Json.jv ->
  ?enum:Json.jv list ->
  ?nullable:bool ->
  ?deprecated:bool ->
  ?readOnly:bool ->
  ?writeOnly:bool ->
  ?id:string ->
  ?definitions:(string * t) list ->
  ?discriminator:discriminator -> ?externalDocs:externalDocs ->
  t list -> t

(** https://json-schema.org/understanding-json-schema/reference/combining.html#anyof *)
val anyOf :
  ?schema:string ->
  ?title:string ->
  ?description:string ->
  ?default:Json.jv ->
  ?example:Json.jv ->
  ?enum:Json.jv list ->
  ?nullable:bool ->
  ?deprecated:bool ->
  ?readOnly:bool ->
  ?writeOnly:bool ->
  ?id:string ->
  ?definitions:(string * t) list ->
  ?discriminator:discriminator -> ?externalDocs:externalDocs ->
  t list -> t

(** https://json-schema.org/understanding-json-schema/reference/combining.html#oneof *)
val oneOf :
  ?schema:string ->
  ?title:string ->
  ?description:string ->
  ?default:Json.jv ->
  ?example:Json.jv ->
  ?enum:Json.jv list ->
  ?nullable:bool ->
  ?deprecated:bool ->
  ?readOnly:bool ->
  ?writeOnly:bool ->
  ?id:string ->
  ?definitions:(string * t) list ->
  ?discriminator:discriminator -> ?externalDocs:externalDocs ->
  t list -> t

(** https://json-schema.org/understanding-json-schema/reference/combining.html#not *)
val not :
  ?schema:string ->
  ?title:string ->
  ?description:string ->
  ?default:Json.jv ->
  ?example:Json.jv ->
  ?enum:Json.jv list ->
  ?nullable:bool ->
  ?deprecated:bool ->
  ?readOnly:bool ->
  ?writeOnly:bool ->
  ?id:string ->
  ?definitions:(string * t) list ->
  ?discriminator:discriminator -> ?externalDocs:externalDocs ->
  t -> t

(** Helper for OCaml: array, fixed length and specific types *)
val tuple :
  ?schema:string ->
  ?title:string ->
  ?description:string ->
  ?default:Json.jv ->
  ?example:Json.jv ->
  ?enum:Json.jv list ->
  ?nullable:bool ->
  ?deprecated:bool ->
  ?readOnly:bool ->
  ?writeOnly:bool ->
  ?id:string ->
  ?definitions:(string * t) list ->
  ?discriminator:discriminator -> ?externalDocs:externalDocs ->
  t list -> t

(** Helper for OCaml: object, all fields are required and additional fields are disallowed *)
val record :
  ?schema:string ->
  ?title:string ->
  ?description:string ->
  ?default:Json.jv ->
  ?example:Json.jv ->
  ?enum:Json.jv list ->
  ?nullable:bool ->
  ?deprecated:bool ->
  ?readOnly:bool ->
  ?writeOnly:bool ->
  ?id:string ->
  ?definitions:(string * t) list ->
  ?discriminator:discriminator -> ?externalDocs:externalDocs ->
  ?additionalProperties:[`T of t | `False] ->
  (string * t) list -> t

(** Replaces all the appearances of [ref s] with [ref (f s)].*)
val map_ref : (string -> string) -> t -> t

val to_json : t -> Json.jv
