open Gen_lib.Datatype_desc

let ex02_docstr : type_decl =
  { td_name = "person";
    td_kind =
      Variant_kind
        [ Cstr_tuple { ct_name = "Anonymous"; ct_args = []; }, `docstr "Anonymous constructor";
          Cstr_tuple { ct_name = "With_id"; ct_args = ["int"]; }, `docstr "With_id constructor";
          Cstr_record {
            cr_name = "Student";
            cr_fields = [
              { rf_name = "student_id"; rf_type = "int"; rf_codec = `default_codec },
              `docstr "student_id field in Student constructor";
              { rf_name = "name"; rf_type = "string"; rf_codec = `default_codec },
              `docstr "name field in Student constructor";
            ]
          },
          `docstr "Student constructor";
          Cstr_record {
            cr_name = "Teacher";
            cr_fields = [
              { rf_name = "faculty_id"; rf_type = "int"; rf_codec = `default_codec },
              `docstr "faculty_id field in Teacher constructor";
              { rf_name = "name"; rf_type = "string"; rf_codec = `default_codec },
              `docstr "name field in Teacher constructor";
              { rf_name = "department"; rf_type = "string"; rf_codec = `default_codec },
              `docstr "dapartment field in Teacher constructor";
            ]
          },
          `docstr "Teacher constructor"],
      `docstr "definition of person type"; }

let () =
  let open Ppxlib in
  let open Ast_builder.Default in
  let loc = Location.none in
  Astlib.Pprintast.structure Format.std_formatter [
    (pstr_type ~loc Recursive [type_declaration_of_type_decl ex02_docstr]);
  ]