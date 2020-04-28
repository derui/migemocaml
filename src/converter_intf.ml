module type S = sig
  val convert : string:string -> Dict_tree.t -> string
  (** Convert [string] to new string with dictionary tree *)
end
