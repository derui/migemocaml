
module type S = sig
  (** Convert [string] to new string with dictionary tree *)
  val convert: string:string -> Dict_tree.t -> string
end
