module type S = sig
  type +'a t
  type +'a future = 'a t

  val name : string

  val async : (unit -> unit t) -> unit
  val at_exit : (unit -> unit future) -> unit
  val catch : (unit -> 'a t) -> (exn -> 'a t) -> 'a t
  val fail : exn -> 'a t
  val finalize : (unit -> 'a t) -> (unit -> unit t) -> 'a t
  val idle : unit -> 'a t
  val iter_p : ('a -> unit t) -> 'a list -> unit t
  val join : unit t list -> unit t
  val run : 'a future -> 'a
  val with_timeout : float -> 'a t -> [`Timeout | `Result of 'a] t

  module Monad : sig
    val (>>=) : 'a t -> ('a -> 'b t) -> 'b t
    val return : 'a -> 'a t
  end

  module Mutex : sig
    type t

    val create : unit -> t
    val with_lock : t -> (unit -> 'a future) -> 'a future
  end

  module Logger : sig
    type t

    val syslog : t

    val debug : t -> ('a, unit, string, unit future) format4 -> 'a
    val info : t -> ('a, unit, string, unit future) format4 -> 'a
    val error : t -> ('a, unit, string, unit future) format4 -> 'a
  end

  module Unix : sig
    type fd

    type unix = [ `Unix of string ]
    type inet = [ `Inet of Unix.inet_addr * int ]
    type addr = [ unix | inet ]
    type ('state, 'addr) socket
      constraint 'state = [< `Unconnected | `Bound | `Passive | `Active ]
      constraint 'addr  = [< addr]

    val accept : ([`Passive], 'addr) socket
              -> (([`Active], 'addr) socket * Unix.sockaddr) future
    val bind : ([`Unconnected], 'addr) socket -> 'addr
            -> ([`Bound], 'addr) socket future
    val chdir : string -> unit future
    val chroot : string -> unit future
    val close : fd -> unit future
    val dup : fd -> fd future
    val exit : int -> 'a future
    val getpwnam : string -> Unix.passwd_entry future
    val listen : ([`Bound], 'addr) socket -> int -> ([`Passive], 'addr) socket
    val lstat : string -> Unix.stats future
    val on_signal : int -> (int -> unit) -> unit
    val openfile : string -> Unix.open_flag list -> Unix.file_perm -> fd future
    val set_close_on_exec : fd -> unit
    val setsockopt
          : ([< `Unconnected | `Bound | `Passive | `Active], 'addr) socket
         -> Unix.socket_bool_option -> bool -> unit
    val socket_fd
          : ([< `Unconnected | `Bound | `Passive | `Active], 'addr) socket
         -> fd
    val stdin : fd
    val unix_socket : unit -> ([`Unconnected], unix) socket
    val unix_socket_of_fd : fd -> ('state, unix) socket
    val unlink : string -> unit future
    val waitpid : int -> Unix.process_status future
    val wrap_file_descr : Unix.file_descr -> fd
  end

  module Bytes : sig
    type t

    val blit : t -> int -> t -> int -> int -> unit
    val blit_from_bytes : bytes -> int -> t -> int -> int -> unit
    val create : int -> t
    val fill : t -> int -> int -> char -> unit
    val get : t -> int -> char
    val length : t -> int
    val of_string : string -> t
    val proxy : t -> int -> int -> t
    val read : Unix.fd -> t -> int -> int -> int future
    val set : t -> int -> char -> unit
    val to_string : t -> string
    val write : Unix.fd -> t -> int -> int -> int future
  end
end
