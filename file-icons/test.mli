(** A simple key-value store with expiration support. *)

type 'a t
(** The type of a cache mapping string keys to values of type ['a]. *)

val create : capacity:int -> 'a t
(** [create ~capacity] returns a new empty cache that holds at most [capacity] entries. *)

val get : 'a t -> string -> 'a option
(** [get cache key] returns [Some v] if [key] is present and not expired,
    or [None] otherwise. *)

val set : 'a t -> string -> 'a -> ttl:float -> unit
(** [set cache key value ~ttl] inserts or updates [key] with [value].
    The entry expires after [ttl] seconds. *)

val remove : 'a t -> string -> unit
(** [remove cache key] deletes [key] from the cache if present. *)

val size : 'a t -> int
(** [size cache] returns the number of non-expired entries. *)
