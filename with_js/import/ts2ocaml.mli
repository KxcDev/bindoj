[@@@ocaml.warning "-7-11-32-33-39"]
[@@@js.implem
  [@@@ocaml.warning "-7-11-32-33-39"]
]

type never = private Ojs.t
val never_to_js: never -> Ojs.t
val never_of_js: Ojs.t -> never
module Never: sig
  type t = never
  val t_to_js: t -> Ojs.t
  val t_of_js: Ojs.t -> t
  val absurd: t -> 'a
  [@@js.custom
    exception Ts2ocaml_Never
    let absurd _ = raise Ts2ocaml_Never
  ]
end

type any = Ojs.t
val any_to_js: any -> Ojs.t
val any_of_js: Ojs.t -> any
module Any: sig
  type t = any
  val t_to_js: t -> Ojs.t
  val t_of_js: Ojs.t -> t
  val cast_from: 't -> t [@@js.custom let cast_from x = Obj.magic x]
  val cast_from': ('t -> Ojs.t) -> 't -> t [@@js.custom let cast_from' f x = f x]
  val unsafe_cast: t -> 't [@@js.custom let unsafe_cast x = Obj.magic x]
  val unsafe_cast': (Ojs.t -> 't) -> t -> 't [@@js.custom let unsafe_cast' f x = f x]
end

type unknown = private Ojs.t
val unknown_to_js: unknown -> Ojs.t
val unknown_of_js: Ojs.t -> unknown
module Unknown: sig
  type t = unknown
  val t_to_js: t -> Ojs.t
  val t_of_js: Ojs.t -> t
  val unsafe_cast: t -> 't [@@js.custom let unsafe_cast x = Obj.magic x]
  val unsafe_cast': (Ojs.t -> 't) -> t -> 't [@@js.custom let unsafe_cast' f x = f x]
end

type null = private Ojs.t
val null_of_js: Ojs.t -> null
val null_to_js: null -> Ojs.t
val null: null [@@js.custom let null = Ojs.null]
module Null : sig
  type t = null
  val t_of_js: Ojs.t -> t
  val t_to_js: t -> Ojs.t
  val value: t [@@js.custom let value = Ojs.null]
  val unsafe_cast: t -> 't [@@js.custom let unsafe_cast x = Obj.magic x]
  val unsafe_cast': (Ojs.t -> 't) -> t -> 't [@@js.custom let unsafe_cast' f x = f x]
end

type undefined = private Ojs.t
val undefined_of_js: Ojs.t -> undefined
val undefined_to_js: undefined -> Ojs.t
val undefined: undefined [@@js.custom let undefined = Ojs.unit_to_js ()]
module Undefined : sig
  type t = undefined
  val t_of_js: Ojs.t -> t
  val t_to_js: t -> Ojs.t
  val value: t [@@js.custom let value = Ojs.unit_to_js ()]
  val unsafe_cast: t -> 't [@@js.custom let unsafe_cast x = Obj.magic x]
  val unsafe_cast': (Ojs.t -> 't) -> t -> 't [@@js.custom let unsafe_cast' f x = f x]
end

[@@@js.stop]
type -'tags intf = private Ojs.t
val intf_to_js: ('tags -> Ojs.t) -> 'tags intf -> Ojs.t
val intf_of_js: (Ojs.t -> 'tags) -> Ojs.t -> 'tags intf
[@@@js.start]
[@@@js.implem
  type -'tags intf = Ojs.t
  let intf_to_js _ x : Ojs.t = x
  let intf_of_js _ x : _ intf = x
]
module Intf : sig
  type 'tags t = 'tags intf
  val t_to_js: ('tags -> Ojs.t) -> 'tags t -> Ojs.t
  val t_of_js: (Ojs.t -> 'tags) -> Ojs.t -> 'tags t
end

type untyped_object = [`Object] intf [@@js.custom { of_js=Obj.magic; to_js=Obj.magic }]
val untyped_object_of_js: Ojs.t -> untyped_object
val untyped_object_to_js: untyped_object -> Ojs.t
(* module will be generated in ts2ocaml_es.mli *)

type untyped_function = [`Function] intf [@@js.custom { of_js=Obj.magic; to_js=Obj.magic }]
val untyped_function_of_js: Ojs.t -> untyped_function
val untyped_function_to_js: untyped_function -> Ojs.t
(* module will be generated in ts2ocaml_es.mli *)

type js_bool = [`Boolean] intf [@@js.custom { of_js=Obj.magic; to_js=Obj.magic }]
val js_bool_of_js: Ojs.t -> js_bool
val js_bool_to_js: js_bool -> Ojs.t
(* module will be generated in ts2ocaml_es.mli *)

type symbol = [`Symbol] intf [@@js.custom { of_js=Obj.magic; to_js=Obj.magic }]
val symbol_of_js: Ojs.t -> symbol
val symbol_to_js: symbol -> Ojs.t
(* module will be generated in ts2ocaml_es.mli *)

type regexp = [`RegExp] intf [@@js.custom { of_js=Obj.magic; to_js=Obj.magic }]
val regexp_of_js: Ojs.t -> regexp
val regexp_to_js: regexp -> Ojs.t
(* module will be generated in ts2ocaml_es.mli *)

type bigint = [`BigInt] intf [@@js.custom { of_js=Obj.magic; to_js=Obj.magic }]
val bigint_of_js: Ojs.t -> bigint
val bigint_to_js: bigint -> Ojs.t
(* module will be generated in ts2ocaml_es.mli *)

type js_string = [`String | `ArrayLike of js_string | `IterableIterator of js_string | `Iterator of (js_string * any * undefined)] intf [@@js.custom { of_js=Obj.magic; to_js=Obj.magic }]
val js_string_of_js: Ojs.t -> js_string
val js_string_to_js: js_string -> Ojs.t
(* module will be generated in ts2ocaml_es.mli *)

module Intersection : sig
  [@@@js.stop]
  type -'cases t = private Ojs.t
  val t_to_js: ('cases -> Ojs.t) -> 'cases t -> Ojs.t
  val t_of_js: (Ojs.t -> 'cases) -> Ojs.t -> 'cases t
  [@@@js.start]
  [@@@js.implem
  type -'cases t = Ojs.t
  let t_to_js _ x : Ojs.t = x
  let t_of_js _ x : _ t = x
  ]

  val get_1: [> `I1 of 't1] t -> 't1 [@@js.custom let get_1 x = Obj.magic x]
  val get_2: [> `I2 of 't2] t -> 't2 [@@js.custom let get_2 x = Obj.magic x]
  val get_3: [> `I3 of 't3] t -> 't3 [@@js.custom let get_3 x = Obj.magic x]
  val get_4: [> `I4 of 't4] t -> 't4 [@@js.custom let get_4 x = Obj.magic x]
  val get_5: [> `I5 of 't5] t -> 't5 [@@js.custom let get_5 x = Obj.magic x]
  val get_6: [> `I6 of 't6] t -> 't6 [@@js.custom let get_6 x = Obj.magic x]
  val get_7: [> `I7 of 't7] t -> 't7 [@@js.custom let get_7 x = Obj.magic x]
  val get_8: [> `I8 of 't8] t -> 't8 [@@js.custom let get_8 x = Obj.magic x]
  val get_1': (Ojs.t -> 't1) -> [> `I1 of 't1] t -> 't1 [@@js.custom let get_1' f x = f (x :> Ojs.t)]
  val get_2': (Ojs.t -> 't2) -> [> `I2 of 't2] t -> 't2 [@@js.custom let get_2' f x = f (x :> Ojs.t)]
  val get_3': (Ojs.t -> 't3) -> [> `I3 of 't3] t -> 't3 [@@js.custom let get_3' f x = f (x :> Ojs.t)]
  val get_4': (Ojs.t -> 't4) -> [> `I4 of 't4] t -> 't4 [@@js.custom let get_4' f x = f (x :> Ojs.t)]
  val get_5': (Ojs.t -> 't5) -> [> `I5 of 't5] t -> 't5 [@@js.custom let get_5' f x = f (x :> Ojs.t)]
  val get_6': (Ojs.t -> 't6) -> [> `I6 of 't6] t -> 't6 [@@js.custom let get_6' f x = f (x :> Ojs.t)]
  val get_7': (Ojs.t -> 't7) -> [> `I7 of 't7] t -> 't7 [@@js.custom let get_7' f x = f (x :> Ojs.t)]
  val get_8': (Ojs.t -> 't8) -> [> `I8 of 't8] t -> 't8 [@@js.custom let get_8' f x = f (x :> Ojs.t)]
end

type ('t1, 't2) intersection2 = [`I1 of 't1 | `I2 of 't2] Intersection.t [@@js.custom {of_js=(fun _ _ -> Obj.magic);to_js = (fun _ _ -> Obj.magic)}]
type ('t1, 't2, 't3) intersection3 = [`I1 of 't1 | `I2 of 't2 | `I3 of 't3] Intersection.t [@@js.custom {of_js=(fun _ _ _ -> Obj.magic);to_js = (fun _ _ _ -> Obj.magic)}]
type ('t1, 't2, 't3, 't4) intersection4 = [`I1 of 't1 | `I2 of 't2 | `I3 of 't3 | `I4 of 't4] Intersection.t [@@js.custom {of_js=(fun _ _ _ _ -> Obj.magic);to_js = (fun _ _ _ _ -> Obj.magic)}]
type ('t1, 't2, 't3, 't4, 't5) intersection5 = [`I1 of 't1 | `I2 of 't2 | `I3 of 't3 | `I4 of 't4 | `I5 of 't5] Intersection.t [@@js.custom {of_js=(fun _ _ _ _ _ -> Obj.magic);to_js = (fun _ _ _ _ _ -> Obj.magic)}]
type ('t1, 't2, 't3, 't4, 't5, 't6) intersection6 = [`I1 of 't1 | `I2 of 't2 | `I3 of 't3 | `I4 of 't4 | `I5 of 't5 | `I6 of 't6] Intersection.t [@@js.custom {of_js=(fun _ _ _ _ _ _ -> Obj.magic);to_js = (fun _ _ _ _ _ _ -> Obj.magic)}]
type ('t1, 't2, 't3, 't4, 't5, 't6, 't7) intersection7 = [`I1 of 't1 | `I2 of 't2 | `I3 of 't3 | `I4 of 't4 | `I5 of 't5 | `I6 of 't6 | `I7 of 't7] Intersection.t [@@js.custom {of_js=(fun _ _ _ _ _ _ _ -> Obj.magic);to_js = (fun _ _ _ _ _ _ _-> Obj.magic)}]
type ('t1, 't2, 't3, 't4, 't5, 't6, 't7, 't8) intersection8 = [`I1 of 't1 | `I2 of 't2 | `I3 of 't3 | `I4 of 't4 | `I5 of 't5 | `I6 of 't6 | `I7 of 't7 | `I8 of 't8] Intersection.t [@@js.custom {of_js=(fun _ _ _ _ _ _ _ _ -> Obj.magic);to_js = (fun _ _ _ _ _ _ _ _ -> Obj.magic)}]

val intersection2_to_js: ('a -> Ojs.t) -> ('b -> Ojs.t) -> ('a, 'b) intersection2 -> Ojs.t
val intersection2_of_js: (Ojs.t -> 'a) -> (Ojs.t -> 'b) -> Ojs.t -> ('a, 'b) intersection2
val intersection3_to_js: ('a -> Ojs.t) -> ('b -> Ojs.t) -> ('c -> Ojs.t) -> ('a, 'b, 'c) intersection3 -> Ojs.t
val intersection3_of_js: (Ojs.t -> 'a) -> (Ojs.t -> 'b) -> (Ojs.t -> 'c) -> Ojs.t -> ('a, 'b, 'c) intersection3
val intersection4_to_js: ('a -> Ojs.t) -> ('b -> Ojs.t) -> ('c -> Ojs.t) -> ('d -> Ojs.t) -> ('a, 'b, 'c, 'd) intersection4 -> Ojs.t
val intersection4_of_js: (Ojs.t -> 'a) -> (Ojs.t -> 'b) -> (Ojs.t -> 'c) -> (Ojs.t -> 'd) -> Ojs.t -> ('a, 'b, 'c, 'd) intersection4
val intersection5_to_js: ('a -> Ojs.t) -> ('b -> Ojs.t) -> ('c -> Ojs.t) -> ('d -> Ojs.t) -> ('e -> Ojs.t) -> ('a, 'b, 'c, 'd, 'e) intersection5 -> Ojs.t
val intersection5_of_js: (Ojs.t -> 'a) -> (Ojs.t -> 'b) -> (Ojs.t -> 'c) -> (Ojs.t -> 'd) -> (Ojs.t -> 'e) -> Ojs.t -> ('a, 'b, 'c, 'd, 'e) intersection5
val intersection6_to_js: ('a -> Ojs.t) -> ('b -> Ojs.t) -> ('c -> Ojs.t) -> ('d -> Ojs.t) -> ('e -> Ojs.t) -> ('f -> Ojs.t) -> ('a, 'b, 'c, 'd, 'e, 'f) intersection6 -> Ojs.t
val intersection6_of_js: (Ojs.t -> 'a) -> (Ojs.t -> 'b) -> (Ojs.t -> 'c) -> (Ojs.t -> 'd) -> (Ojs.t -> 'e) -> (Ojs.t -> 'f) -> Ojs.t -> ('a, 'b, 'c, 'd, 'e, 'f) intersection6
val intersection7_to_js: ('a -> Ojs.t) -> ('b -> Ojs.t) -> ('c -> Ojs.t) -> ('d -> Ojs.t) -> ('e -> Ojs.t) -> ('f -> Ojs.t) -> ('g -> Ojs.t) -> ('a, 'b, 'c, 'd, 'e, 'f, 'g) intersection7 -> Ojs.t
val intersection7_of_js: (Ojs.t -> 'a) -> (Ojs.t -> 'b) -> (Ojs.t -> 'c) -> (Ojs.t -> 'd) -> (Ojs.t -> 'e) -> (Ojs.t -> 'f) -> (Ojs.t -> 'g) -> Ojs.t -> ('a, 'b, 'c, 'd, 'e, 'f, 'g) intersection7
val intersection8_to_js: ('a -> Ojs.t) -> ('b -> Ojs.t) -> ('c -> Ojs.t) -> ('d -> Ojs.t) -> ('e -> Ojs.t) -> ('f -> Ojs.t) -> ('g -> Ojs.t) -> ('h -> Ojs.t) -> ('a, 'b, 'c, 'd, 'e, 'f, 'g, 'h) intersection8 -> Ojs.t
val intersection8_of_js: (Ojs.t -> 'a) -> (Ojs.t -> 'b) -> (Ojs.t -> 'c) -> (Ojs.t -> 'd) -> (Ojs.t -> 'e) -> (Ojs.t -> 'f) -> (Ojs.t -> 'g) -> (Ojs.t -> 'h) -> Ojs.t -> ('a, 'b, 'c, 'd, 'e, 'f, 'g, 'h) intersection8

module Union : sig
  [@@@js.stop]
  type +'cases t = private Ojs.t
  val t_to_js: ('cases -> Ojs.t) -> 'cases t -> Ojs.t
  val t_of_js: (Ojs.t -> 'cases) -> Ojs.t -> 'cases t
  [@@@js.start]
  [@@@js.implem
  type +'cases t = Ojs.t
  let t_to_js _ x : Ojs.t = x
  let t_of_js _ x : _ t = x
  ]

  val inject_1: 't1 -> [> `U1 of 't1] t [@@js.custom let inject_1 x = Obj.magic x]
  val inject_2: 't2 -> [> `U2 of 't2] t [@@js.custom let inject_2 x = Obj.magic x]
  val inject_3: 't3 -> [> `U3 of 't3] t [@@js.custom let inject_3 x = Obj.magic x]
  val inject_4: 't4 -> [> `U4 of 't4] t [@@js.custom let inject_4 x = Obj.magic x]
  val inject_5: 't5 -> [> `U5 of 't5] t [@@js.custom let inject_5 x = Obj.magic x]
  val inject_6: 't6 -> [> `U6 of 't6] t [@@js.custom let inject_6 x = Obj.magic x]
  val inject_7: 't7 -> [> `U7 of 't7] t [@@js.custom let inject_7 x = Obj.magic x]
  val inject_8: 't8 -> [> `U8 of 't8] t [@@js.custom let inject_8 x = Obj.magic x]
  val inject_1': ('t1 -> Ojs.t) -> 't1 -> [> `U1 of 't1] t [@@js.custom let inject_1' f x = Obj.magic (f x)]
  val inject_2': ('t2 -> Ojs.t) -> 't2 -> [> `U2 of 't2] t [@@js.custom let inject_2' f x = Obj.magic (f x)]
  val inject_3': ('t3 -> Ojs.t) -> 't3 -> [> `U3 of 't3] t [@@js.custom let inject_3' f x = Obj.magic (f x)]
  val inject_4': ('t4 -> Ojs.t) -> 't4 -> [> `U4 of 't4] t [@@js.custom let inject_4' f x = Obj.magic (f x)]
  val inject_5': ('t5 -> Ojs.t) -> 't5 -> [> `U5 of 't5] t [@@js.custom let inject_5' f x = Obj.magic (f x)]
  val inject_6': ('t6 -> Ojs.t) -> 't6 -> [> `U6 of 't6] t [@@js.custom let inject_6' f x = Obj.magic (f x)]
  val inject_7': ('t7 -> Ojs.t) -> 't7 -> [> `U7 of 't7] t [@@js.custom let inject_7' f x = Obj.magic (f x)]
  val inject_8': ('t8 -> Ojs.t) -> 't8 -> [> `U8 of 't8] t [@@js.custom let inject_8' f x = Obj.magic (f x)]

  val unsafe_get_1: [> `U1 of 't1] t -> 't1 [@@js.custom let unsafe_get_1 x = Obj.magic x]
  val unsafe_get_2: [> `U2 of 't2] t -> 't2 [@@js.custom let unsafe_get_2 x = Obj.magic x]
  val unsafe_get_3: [> `U3 of 't3] t -> 't3 [@@js.custom let unsafe_get_3 x = Obj.magic x]
  val unsafe_get_4: [> `U4 of 't4] t -> 't4 [@@js.custom let unsafe_get_4 x = Obj.magic x]
  val unsafe_get_5: [> `U5 of 't5] t -> 't5 [@@js.custom let unsafe_get_5 x = Obj.magic x]
  val unsafe_get_6: [> `U6 of 't6] t -> 't6 [@@js.custom let unsafe_get_6 x = Obj.magic x]
  val unsafe_get_7: [> `U7 of 't7] t -> 't7 [@@js.custom let unsafe_get_7 x = Obj.magic x]
  val unsafe_get_8: [> `U8 of 't8] t -> 't8 [@@js.custom let unsafe_get_8 x = Obj.magic x]
  val unsafe_get_1': (Ojs.t -> 't1) -> [> `U1 of 't1] t -> 't1 [@@js.custom let unsafe_get_1' f x = f (x :> Ojs.t)]
  val unsafe_get_2': (Ojs.t -> 't2) -> [> `U2 of 't2] t -> 't2 [@@js.custom let unsafe_get_2' f x = f (x :> Ojs.t)]
  val unsafe_get_3': (Ojs.t -> 't3) -> [> `U3 of 't3] t -> 't3 [@@js.custom let unsafe_get_3' f x = f (x :> Ojs.t)]
  val unsafe_get_4': (Ojs.t -> 't4) -> [> `U4 of 't4] t -> 't4 [@@js.custom let unsafe_get_4' f x = f (x :> Ojs.t)]
  val unsafe_get_5': (Ojs.t -> 't5) -> [> `U5 of 't5] t -> 't5 [@@js.custom let unsafe_get_5' f x = f (x :> Ojs.t)]
  val unsafe_get_6': (Ojs.t -> 't6) -> [> `U6 of 't6] t -> 't6 [@@js.custom let unsafe_get_6' f x = f (x :> Ojs.t)]
  val unsafe_get_7': (Ojs.t -> 't7) -> [> `U7 of 't7] t -> 't7 [@@js.custom let unsafe_get_7' f x = f (x :> Ojs.t)]
  val unsafe_get_8': (Ojs.t -> 't8) -> [> `U8 of 't8] t -> 't8 [@@js.custom let unsafe_get_8' f x = f (x :> Ojs.t)]
end

type ('t1, 't2) union2 = [`U1 of 't1 | `U2 of 't2] Union.t [@@js.custom {of_js=(fun _ _ -> Obj.magic);to_js = (fun _ _ -> Obj.magic)}]
type ('t1, 't2, 't3) union3 = [`U1 of 't1 | `U2 of 't2 | `U3 of 't3] Union.t [@@js.custom {of_js=(fun _ _ _ -> Obj.magic);to_js = (fun _ _ _ -> Obj.magic)}]
type ('t1, 't2, 't3, 't4) union4 = [`U1 of 't1 | `U2 of 't2 | `U3 of 't3 | `U4 of 't4] Union.t [@@js.custom {of_js=(fun _ _ _ _ -> Obj.magic);to_js = (fun _ _ _ _ -> Obj.magic)}]
type ('t1, 't2, 't3, 't4, 't5) union5 = [`U1 of 't1 | `U2 of 't2 | `U3 of 't3 | `U4 of 't4 | `U5 of 't5] Union.t [@@js.custom {of_js=(fun _ _ _ _ _ -> Obj.magic);to_js = (fun _ _ _ _ _ -> Obj.magic)}]
type ('t1, 't2, 't3, 't4, 't5, 't6) union6 = [`U1 of 't1 | `U2 of 't2 | `U3 of 't3 | `U4 of 't4 | `U5 of 't5 | `U6 of 't6] Union.t [@@js.custom {of_js=(fun _ _ _ _ _ _ -> Obj.magic);to_js = (fun _ _ _ _ _ _ -> Obj.magic)}]
type ('t1, 't2, 't3, 't4, 't5, 't6, 't7) union7 = [`U1 of 't1 | `U2 of 't2 | `U3 of 't3 | `U4 of 't4 | `U5 of 't5 | `U6 of 't6 | `U7 of 't7] Union.t [@@js.custom {of_js=(fun _ _ _ _ _ _ _ -> Obj.magic);to_js = (fun _ _ _ _ _ _ _-> Obj.magic)}]
type ('t1, 't2, 't3, 't4, 't5, 't6, 't7, 't8) union8 = [`U1 of 't1 | `U2 of 't2 | `U3 of 't3 | `U4 of 't4 | `U5 of 't5 | `U6 of 't6 | `U7 of 't7 | `U8 of 't8] Union.t [@@js.custom {of_js=(fun _ _ _ _ _ _ _ _ -> Obj.magic);to_js = (fun _ _ _ _ _ _ _ _ -> Obj.magic)}]

val union2_to_js: ('a -> Ojs.t) -> ('b -> Ojs.t) -> ('a, 'b) union2 -> Ojs.t
val union2_of_js: (Ojs.t -> 'a) -> (Ojs.t -> 'b) -> Ojs.t -> ('a, 'b) union2
val union3_to_js: ('a -> Ojs.t) -> ('b -> Ojs.t) -> ('c -> Ojs.t) -> ('a, 'b, 'c) union3 -> Ojs.t
val union3_of_js: (Ojs.t -> 'a) -> (Ojs.t -> 'b) -> (Ojs.t -> 'c) -> Ojs.t -> ('a, 'b, 'c) union3
val union4_to_js: ('a -> Ojs.t) -> ('b -> Ojs.t) -> ('c -> Ojs.t) -> ('d -> Ojs.t) -> ('a, 'b, 'c, 'd) union4 -> Ojs.t
val union4_of_js: (Ojs.t -> 'a) -> (Ojs.t -> 'b) -> (Ojs.t -> 'c) -> (Ojs.t -> 'd) -> Ojs.t -> ('a, 'b, 'c, 'd) union4
val union5_to_js: ('a -> Ojs.t) -> ('b -> Ojs.t) -> ('c -> Ojs.t) -> ('d -> Ojs.t) -> ('e -> Ojs.t) -> ('a, 'b, 'c, 'd, 'e) union5 -> Ojs.t
val union5_of_js: (Ojs.t -> 'a) -> (Ojs.t -> 'b) -> (Ojs.t -> 'c) -> (Ojs.t -> 'd) -> (Ojs.t -> 'e) -> Ojs.t -> ('a, 'b, 'c, 'd, 'e) union5
val union6_to_js: ('a -> Ojs.t) -> ('b -> Ojs.t) -> ('c -> Ojs.t) -> ('d -> Ojs.t) -> ('e -> Ojs.t) -> ('f -> Ojs.t) -> ('a, 'b, 'c, 'd, 'e, 'f) union6 -> Ojs.t
val union6_of_js: (Ojs.t -> 'a) -> (Ojs.t -> 'b) -> (Ojs.t -> 'c) -> (Ojs.t -> 'd) -> (Ojs.t -> 'e) -> (Ojs.t -> 'f) -> Ojs.t -> ('a, 'b, 'c, 'd, 'e, 'f) union6
val union7_to_js: ('a -> Ojs.t) -> ('b -> Ojs.t) -> ('c -> Ojs.t) -> ('d -> Ojs.t) -> ('e -> Ojs.t) -> ('f -> Ojs.t) -> ('g -> Ojs.t) -> ('a, 'b, 'c, 'd, 'e, 'f, 'g) union7 -> Ojs.t
val union7_of_js: (Ojs.t -> 'a) -> (Ojs.t -> 'b) -> (Ojs.t -> 'c) -> (Ojs.t -> 'd) -> (Ojs.t -> 'e) -> (Ojs.t -> 'f) -> (Ojs.t -> 'g) -> Ojs.t -> ('a, 'b, 'c, 'd, 'e, 'f, 'g) union7
val union8_to_js: ('a -> Ojs.t) -> ('b -> Ojs.t) -> ('c -> Ojs.t) -> ('d -> Ojs.t) -> ('e -> Ojs.t) -> ('f -> Ojs.t) -> ('g -> Ojs.t) -> ('h -> Ojs.t) -> ('a, 'b, 'c, 'd, 'e, 'f, 'g, 'h) union8 -> Ojs.t
val union8_of_js: (Ojs.t -> 'a) -> (Ojs.t -> 'b) -> (Ojs.t -> 'c) -> (Ojs.t -> 'd) -> (Ojs.t -> 'e) -> (Ojs.t -> 'f) -> (Ojs.t -> 'g) -> (Ojs.t -> 'h) -> Ojs.t -> ('a, 'b, 'c, 'd, 'e, 'f, 'g, 'h) union8

module Primitive : sig
  [@@@js.stop]
  type +'cases t = private Ojs.t
  val t_to_js: ('cases -> Ojs.t) -> 'cases t -> Ojs.t
  val t_of_js: (Ojs.t -> 'cases) -> Ojs.t -> 'cases t
  type 'other cases = [
    | `String of string
    | `Number of float
    | `Boolean of bool
    | `Symbol of symbol
    | `BigInt of bigint
    | `Null
    | `Undefined
    | `Other of 'other
  ]
  val inject: ([< 'other cases] as 'u) -> 'u t
  val inject': ('other -> Ojs.t) -> ([< 'other cases] as 'u) -> 'u t
  val classify: ([< 'other cases] as 'u) t -> 'u
  val classify': (Ojs.t -> 'other) -> ([< 'other cases] as 'u) t -> 'u
  [@@@js.start]
  [@@@js.implem
  type +'cases t = Ojs.t
  let t_to_js _ x : Ojs.t = x
  let t_of_js _ x : _ t = x
  type 'other cases = [
    | `String of string
    | `Number of float
    | `Boolean of bool
    | `Symbol of symbol
    | `BigInt of bigint
    | `Null
    | `Undefined
    | `Other of 'other
  ]
  let inject' other_to_js (c: ([< 'other cases] as 'u)) =
    match c with
    | `String s -> Obj.magic (Ojs.string_to_js s)
    | `Number f -> Obj.magic (Ojs.float_to_js f)
    | `Boolean b -> Obj.magic (Ojs.bool_to_js b)
    | `Symbol s -> Obj.magic (symbol_to_js s)
    | `BigInt i -> Obj.magic (bigint_to_js i)
    | `Null -> Obj.magic Ojs.null
    | `Undefined -> Obj.magic (Ojs.unit_to_js ())
    | `Other o -> Obj.magic (other_to_js o)
  let inject c = inject' Obj.magic c
  let classify' other_of_js (u: ([< 'other cases] as 'u) t) =
    match Ojs.type_of u with
    | "string" -> Obj.magic (`String (Ojs.string_of_js u))
    | "number" -> Obj.magic (`Number (Ojs.float_of_js u))
    | "boolean" -> Obj.magic (`Boolean (Ojs.bool_of_js u))
    | "symbol" -> Obj.magic (`Symbol (symbol_of_js u))
    | "bigint" -> Obj.magic (`BigInt (bigint_of_js u))
    | "undefined" -> Obj.magic `Undefined
    | _ ->
      if Ojs.is_null u then Obj.magic `Null
      else Obj.magic (`Other (other_of_js u))
  let classify c = classify' Obj.magic c
  ]
end

module[@js.scope "Promise"] Promise : sig
  type 'T t = private Ojs.t
  val t_to_js: ('T -> Ojs.t) -> 'T t -> Ojs.t
  val t_of_js: (Ojs.t -> 'T) -> Ojs.t -> 'T t

  type error = private Ojs.t
  val error_to_js: error -> Ojs.t
  val error_of_js: Ojs.t -> error

  (**
    language version: ES2018
    Attaches a callback that is invoked when the Promise is settled (fulfilled or rejected). The
    resolved value cannot be modified from the callback.
    @param onfinally The callback to execute when the Promise is settled (fulfilled or rejected).
    @return A Promise for the completion of the callback.
  *)
  val finally: 'T t -> ?onfinally:(unit -> unit) -> unit -> 'T t [@@js.call "finally"]
  (* [Symbol.toStringTag]: unit -> string *)

  (**
    Attaches callbacks for the resolution and/or rejection of the Promise.
    @param onfulfilled The callback to execute when the Promise is resolved.
    @param onrejected The callback to execute when the Promise is rejected.
    @return A Promise for the completion of which ever callback is executed.
  *)
  val then_: 'T t -> ?onfulfilled:('T -> ([`U1 of 'TResult1 | `U2 of 'TResult1 t] [@js.union])) -> ?onrejected:(error -> ([`U1 of 'TResult2 | `U2 of 'TResult2 t] [@js.union])) -> unit -> ('TResult1, 'TResult2) union2 t [@@js.call "then"]

  (**
    Attaches a callback for only the rejection of the Promise.
    @param onrejected The callback to execute when the Promise is rejected.
    @return A Promise for the completion of the callback.
  *)
  val catch: 'T t -> ?onrejected:(error -> ([`U1 of 'TResult | `U2 of 'TResult t] [@js.union])) -> unit -> ('T, 'TResult) union2 t [@@js.call "catch"]

  (**
    Creates a new Promise.
    @param executor A callback used to initialize the promise. This callback is passed two arguments:
    a resolve callback used to resolve the promise with a value or the result of another promise,
    and a reject callback used to reject the promise with a provided reason or error.
  *)
  val create: (resolve:(([`U1 of 'T | `U2 of 'T t] [@js.union]) -> unit) -> reject:(?reason:error -> unit -> unit) -> unit) -> 'T t [@@js.create]
end
