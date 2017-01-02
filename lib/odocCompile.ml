(*
 * Copyright (c) 2014 Leo White <leo@lpw25.net>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open DocOck

module Fs = OdocFs
module Env = OdocEnv
module Root = OdocRoot
module Unit = OdocUnit

let it's_all_the_same ~env ~output input reader =
  let fn = Fs.File.to_string input in
  match reader fn with
  | Not_an_interface  -> failwith "Not_an_interface"
  | Wrong_version  -> failwith "Wrong_version"
  | Corrupted  -> failwith "Corrupted"
  | Not_a_typedtree  -> failwith "Not_a_typedtree"
  | Not_an_implementation  -> failwith "Not_an_implementation"
  | Ok unit ->
    if not unit.Types.Unit.interface then (
      Printf.eprintf "WARNING: not processing the \"interface\" file.%s\n%!"
        (if not (Filename.check_suffix fn "cmt") then "" (* ? *)
         else Printf.sprintf " Using %S while you should use the .cmti file" fn)
    );
    let env = Env.build env unit in
    resolve (Env.resolver env) unit
    |> expand (Env.expander env)
    |> Unit.save output

let root_of_unit ~package unit_name digest =
  let unit = Root.Unit.create unit_name in
  Root.create ~package ~unit ~digest

let cmti ~env ~package ~output input =
  it's_all_the_same ~env ~output input (read_cmti @@ root_of_unit ~package)

let cmt ~env ~package ~output input =
  it's_all_the_same ~env ~output input (read_cmt @@ root_of_unit ~package)

let cmi ~env ~package ~output input =
  it's_all_the_same ~env ~output input (read_cmi @@ root_of_unit ~package)
