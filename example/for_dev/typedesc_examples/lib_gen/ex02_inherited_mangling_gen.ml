type person =
  | Anonymous
  | With_id of int
  | Student of {
      student_id : int;
      name : string;
      case_value : [ `Case_at0 | `case_at1 ];
    }
  | Teacher of { faculty_id : int; name : string; department : string }

let rec (person_reflect : _ Bindoj_runtime.Refl.t) =
  lazy
    (let open Bindoj_runtime in
     let open Kxclib.Option.Ops_monad in
     let ctor_Anonymous = Refl.NoParam { value = Anonymous } in
     let ctor_With_id =
       Refl.TupleLike
         {
           get =
             (function
             | With_id x -> [ Expr.of_int x ]
             | _ -> invalid_arg "With_id is expected");
           mk =
             (function
             | x :: [] -> Expr.to_int x |> Option.map (fun x -> With_id x)
             | _ -> None);
         }
     in
     let ctor_Student =
       Refl.InlineRecord
         {
           get =
             (function
             | Student { student_id; name; case_value } ->
                 StringMap.of_list
                   [
                     ("student_id", Expr.of_int student_id);
                     ("name", Expr.of_string name);
                     ( "case_value",
                       (function
                         | `Case_at0 -> Expr.StringEnum "Case_at0"
                         | `case_at1 -> Expr.StringEnum "case_at1")
                         case_value );
                   ]
             | _ -> invalid_arg "Student is expected");
           mk =
             (fun xs ->
               xs |> StringMap.find_opt "student_id" >>= Expr.to_int
               >>= fun student_id ->
               xs |> StringMap.find_opt "name" >>= Expr.to_string
               >>= fun name ->
               (xs |> StringMap.find_opt "case_value" >>= function
                | Expr.StringEnum "Case_at0" -> Some `Case_at0
                | Expr.StringEnum "case_at1" -> Some `case_at1
                | _ -> None)
               >>= fun case_value ->
               Some (Student { student_id; name; case_value }));
         }
     in
     let ctor_Teacher =
       Refl.ReusedInlineRecord
         {
           get =
             (function
             | Teacher { faculty_id; name; department } ->
                 StringMap.of_list
                   [
                     ("faculty_id", Expr.of_int faculty_id);
                     ("name", Expr.of_string name);
                     ("department", Expr.of_string department);
                   ]
             | _ -> invalid_arg "Teacher is expected");
           mk =
             (fun xs ->
               xs |> StringMap.find_opt "faculty_id" >>= Expr.to_int
               >>= fun faculty_id ->
               xs |> StringMap.find_opt "name" >>= Expr.to_string
               >>= fun name ->
               xs |> StringMap.find_opt "department" >>= Expr.to_string
               >>= fun department ->
               Some (Teacher { faculty_id; name; department }));
         }
     in
     Refl.Variant
       {
         constructors =
           StringMap.of_list
             [
               ("Anonymous", ctor_Anonymous);
               ("With_id", ctor_With_id);
               ("Student", ctor_Student);
               ("Teacher", ctor_Teacher);
             ];
         classify =
           (function
           | Anonymous -> ("Anonymous", ctor_Anonymous)
           | With_id _ -> ("With_id", ctor_With_id)
           | Student _ -> ("Student", ctor_Student)
           | Teacher _ -> ("Teacher", ctor_Teacher));
       })
[@@warning "-33-39"]

let person_json_discriminator_value =
  (function
   | Anonymous -> "Anonymous"
   | With_id _ -> "With_id"
   | Student _ -> "student"
   | Teacher _ -> "Teacher"
    : person -> string)
[@@warning "-39"]

let person_json_shape_explanation =
  (`with_warning
     ( "not considering any config if exists",
       `named
         ( "person_inherited_mangling",
           `anyone_of
             [
               `object_of
                 [ `mandatory_field ("kind", `exactly (`str "Anonymous")) ];
               `object_of
                 [
                   `mandatory_field ("kind", `exactly (`str "With_id"));
                   `mandatory_field ("arg", `integral);
                 ];
               `object_of
                 [
                   `mandatory_field ("kind", `exactly (`str "student"));
                   `mandatory_field ("student_id", `integral);
                   `mandatory_field ("name", `string);
                   `mandatory_field
                     ("caseValue", `string_enum [ "Case_at0"; "case-at1" ]);
                 ];
               `object_of
                 [
                   `mandatory_field ("kind", `exactly (`str "Teacher"));
                   `mandatory_field ("facultyId", `integral);
                   `mandatory_field ("name", `string);
                   `mandatory_field ("department", `string);
                 ];
             ] ) )
    : Bindoj_runtime.json_shape_explanation)
[@@warning "-39"]

let rec person_to_json =
  (let string_to_json (x : string) : Kxclib.Json.jv = `str x
   and int_to_json (x : int) : Kxclib.Json.jv = `num (float_of_int x) in
   function
   | Anonymous -> `obj [ ("kind", `str "Anonymous") ]
   | With_id x0 -> `obj [ ("kind", `str "With_id"); ("arg", int_to_json x0) ]
   | Student { student_id = x0; name = x1; case_value = x2 } ->
       `obj
         [
           ("kind", `str "student");
           ("student_id", int_to_json x0);
           ("name", string_to_json x1);
           ( "caseValue",
             (function
               | `Case_at0 -> `str "Case_at0" | `case_at1 -> `str "case-at1")
               x2 );
         ]
   | Teacher { faculty_id = x0; name = x1; department = x2 } ->
       `obj
         [
           ("kind", `str "Teacher");
           ("facultyId", int_to_json x0);
           ("name", string_to_json x1);
           ("department", string_to_json x2);
         ]
    : person -> Kxclib.Json.jv)
[@@warning "-39"]

and person_of_json' =
  (fun ?(path = []) x ->
     (let rec of_json_impl =
        let string_of_json' path = function
          | (`str x : Kxclib.Json.jv) -> Ok x
          | jv ->
              Error
                ( Printf.sprintf
                    "expecting type 'string' but the given is of type '%s'"
                    (let open Kxclib.Json in
                     string_of_jv_kind (classify_jv jv)),
                  path )
        and int_of_json' path = function
          | (`num x : Kxclib.Json.jv) ->
              if Float.is_integer x then Ok (int_of_float x)
              else
                Error
                  ( Printf.sprintf "expecting an integer but the given is '%f'" x,
                    path )
          | jv ->
              Error
                ( Printf.sprintf
                    "expecting type 'int' but the given is of type '%s'"
                    (let open Kxclib.Json in
                     string_of_jv_kind (classify_jv jv)),
                  path )
        in
        fun path __bindoj_orig ->
          match Kxclib.Jv.pump_field "kind" __bindoj_orig with
          | `obj (("kind", `str "Anonymous") :: _) -> Ok Anonymous
          | `obj (("kind", `str "With_id") :: param) -> (
              match List.assoc_opt "arg" param with
              | Some arg ->
                  let ( >>= ) = Result.bind in
                  int_of_json' (`f "arg" :: path) arg >>= fun x0 ->
                  Ok (With_id x0)
              | None -> Error ("mandatory field 'arg' does not exist", path))
          | `obj (("kind", `str "student") :: param) ->
              let ( >>= ) = Result.bind in
              List.assoc_opt "student_id" param
              |> Option.to_result
                   ~none:("mandatory field 'student_id' does not exist", path)
              >>= int_of_json' (`f "student_id" :: path)
              >>= fun x0 ->
              List.assoc_opt "name" param
              |> Option.to_result
                   ~none:("mandatory field 'name' does not exist", path)
              >>= string_of_json' (`f "name" :: path)
              >>= fun x1 ->
              List.assoc_opt "caseValue" param
              |> Option.to_result
                   ~none:("mandatory field 'caseValue' does not exist", path)
              >>= (fun path -> function
                    | `str s ->
                        (function
                          | "Case_at0" -> Ok `Case_at0
                          | "case-at1" -> Ok `case_at1
                          | s ->
                              Error
                                ( Printf.sprintf
                                    "given string '%s' is not one of [ \
                                     'Case_at0', 'case-at1' ]"
                                    s,
                                  path ))
                          s
                    | jv ->
                        Error
                          ( Printf.sprintf
                              "expecting type 'string' but the given is of \
                               type '%s'"
                              (let open Kxclib.Json in
                               string_of_jv_kind (classify_jv jv)),
                            path ))
                    (`f "caseValue" :: path)
              >>= fun x2 ->
              Ok (Student { student_id = x0; name = x1; case_value = x2 })
          | `obj (("kind", `str "Teacher") :: param) ->
              let ( >>= ) = Result.bind in
              List.assoc_opt "facultyId" param
              |> Option.to_result
                   ~none:("mandatory field 'facultyId' does not exist", path)
              >>= int_of_json' (`f "facultyId" :: path)
              >>= fun x0 ->
              List.assoc_opt "name" param
              |> Option.to_result
                   ~none:("mandatory field 'name' does not exist", path)
              >>= string_of_json' (`f "name" :: path)
              >>= fun x1 ->
              List.assoc_opt "department" param
              |> Option.to_result
                   ~none:("mandatory field 'department' does not exist", path)
              >>= string_of_json' (`f "department" :: path)
              >>= fun x2 ->
              Ok (Teacher { faculty_id = x0; name = x1; department = x2 })
          | `obj (("kind", `str discriminator_value) :: _) ->
              Error
                ( Printf.sprintf
                    "given discriminator field value '%s' is not one of [ \
                     'Anonymous', 'With_id', 'student', 'Teacher' ]"
                    discriminator_value,
                  `f "kind" :: path )
          | `obj (("kind", jv) :: _) ->
              Error
                ( Printf.sprintf
                    "a string is expected for a variant discriminator, but the \
                     given is of type '%s'"
                    (let open Kxclib.Json in
                     string_of_jv_kind (classify_jv jv)),
                  `f "kind" :: path )
          | `obj _ -> Error ("discriminator field 'kind' does not exist", path)
          | jv ->
              Error
                ( Printf.sprintf
                    "an object is expected for a variant value, but the given \
                     is of type '%s'"
                    (let open Kxclib.Json in
                     string_of_jv_kind (classify_jv jv)),
                  path )
      in
      of_json_impl)
       path x
     |> Result.map_error (fun (msg, path) ->
            (msg, path, person_json_shape_explanation))
    : person Bindoj_runtime.json_full_decoder)
[@@warning "-39"]

and person_of_json =
  (fun x -> person_of_json' x |> Result.to_option
    : Kxclib.Json.jv -> person option)
[@@warning "-39"]

let person_decl =
  Bindoj_test_common_typedesc_examples.Ex02_inherited_mangling.decl

let person_typed_decl =
  Bindoj_runtime.mk_generic_typed_type_decl
    Bindoj_test_common_typedesc_examples.Ex02_inherited_mangling.decl
    person_reflect