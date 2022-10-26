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
open Kxclib
open Kxclib.Json
open Bindoj_apidir_shared

module TupleJsonResponse : (Apidir_base.JsonResponse with type t = int * jv) = struct
  type t = int * jv
  let status (s, _) = s
  let body (_, b) = b
end

module type T = sig
  type 'resp io

  val register_get_handler :
    (unit, 'respty) invocation_point_info -> (unit -> (int * 'respty) io) -> unit
  val register_post_handler :
    ('reqty, 'respty) invocation_point_info -> ('reqty -> (int * 'respty) io) -> unit

  val handle_json_get : untyped_invocation_point_info -> TupleJsonResponse.t io
  val handle_json_post : untyped_invocation_point_info -> Json.jv -> TupleJsonResponse.t io

  val handle_path_json_get : string -> TupleJsonResponse.t io
  val handle_path_json_post : string -> Json.jv -> TupleJsonResponse.t io
end

(* TODO.future - make it take a Configurator, or make it generative #220 *)
module Make (Dir : ApiDirManifest) (IoStyle : Monadic) = struct
  include Apidir_base.Make(Dir)(IoStyle)
  open IoOps

  type ('reqty, 'respty) invp = ('reqty, 'respty) invocation_point_info
  type invp' = untyped_invocation_point_info

  type handler =
    | Handler : ('reqty, 'respty) invp * ('reqty -> (int * 'respty) io) -> handler

  let handler_registry_post : (invp', handler) Hashtbl.t = Hashtbl.create 0
  let handler_registry_get : (invp', handler) Hashtbl.t = Hashtbl.create 0

  let register_post_handler (type reqty) (type respty) :
     (reqty, respty) invp ->
     (reqty -> (int * respty) io) -> unit =
    fun invp func ->
    Hashtbl.replace handler_registry_post
      (Invp invp)
      (Handler (invp, func))

  let register_get_handler (type respty) :
     (unit, respty) invp ->
     (unit -> (int * respty) io) -> unit =
    fun invp func ->
    Hashtbl.replace handler_registry_get
      (Invp invp)
      (Handler (invp, func))

  let create_response : 'respty response_case list -> (int * 'respty) -> TupleJsonResponse.t =
    fun responses (resp_status, packed) ->
    let case =
      responses |> List.find_opt (function Response_case { status; _ } ->
        match status with
        | `default -> true
        | `status_code status when status = resp_status -> true
        | `status_range `_1XX when 100 <= resp_status && resp_status < 200 -> true
        | `status_range `_2XX when 200 <= resp_status && resp_status < 300 -> true
        | `status_range `_3XX when 300 <= resp_status && resp_status < 400 -> true
        | `status_range `_4XX when 400 <= resp_status && resp_status < 500 -> true
        | `status_range `_5XX when 500 <= resp_status && resp_status < 600 -> true
        | _ -> false
      )
    in
    match case with
    | None -> invalid_arg' "status code %d is not supported for the requested invocation point" resp_status
    | Some (Response_case { status; response; unpack; _ }) ->
      match unpack packed with
      | None ->
        invalid_arg' "status code mismatch: expected %s, received %d"
          (string_of_http_status status) resp_status
      | Some unpacked ->
        let ttd = Utils.ttd_of_media_type response.rs_media_type in
        let jv = Bindoj_codec.Json.to_json ~env:tdenv ttd unpacked in
        (resp_status, jv)

  let handle_json_post : invp' -> jv -> TupleJsonResponse.t io =
    fun invp reqbody ->
    match Hashtbl.find_opt handler_registry_post invp with
    | None ->
       invalid_arg
         "no handler registered for the requested api"
    | Some (Handler (invp, handler)) ->
       let req = match invp.ip_method, invp.ip_request_body with
         | `get, _ -> invalid_arg' "handle_json_post got GET invp: %s" invp.ip_name
         | `post, None -> invalid_arg' "POST method must have a request body definition: %s" invp.ip_name
         | `post, Some desc ->
            let ttd = Utils.ttd_of_media_type desc.rq_media_type in
            (match reqbody |> Bindoj_codec.Json.of_json ~env:tdenv ttd with
             | None -> Utils.bad_request "invalid json format for type %s: %a"
                         (Utils.ttd_name ttd) Utils.pp_jv reqbody
             | Some req -> req) in
       handler req >|= create_response invp.ip_responses

  let handle_json_get : invp' -> TupleJsonResponse.t io =
    fun invp ->
    match Hashtbl.find_opt handler_registry_get invp with
    | None ->
       invalid_arg
         "no handler registered for the requested api"
    | Some (Handler (invp, handler)) ->
       (match invp.ip_method with
        | `post -> invalid_arg' "handle_json_get got Post invp: %s" invp.ip_name
        | `get -> ()
        | _ -> .);
       handler (() |> Obj.magic) >|= create_response invp.ip_responses

  let handle_path_json_post : string -> jv -> TupleJsonResponse.t io =
    fun path reqbody ->
    match Hashtbl.find_opt index_post path with
    | None -> raise (Utils.Exceptions.Unrecognized_route path)
    | Some invp -> handle_json_post invp reqbody

  let handle_path_json_get : string -> TupleJsonResponse.t io =
    fun path ->
    match Hashtbl.find_opt index_get path with
    | None -> raise (Utils.Exceptions.Unrecognized_route path)
    | Some invp -> handle_json_get invp

  (* TODO.future - add method to check completeness of handles #219 *)
end
