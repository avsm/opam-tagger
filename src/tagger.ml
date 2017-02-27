(*---------------------------------------------------------------------------
   Copyright (c) 2017 Anil Madhavapeddy. All rights reserved.
   Distributed under the ISC license, see terms at the end of the file.
   %%NAME%% %%VERSION%%
  ---------------------------------------------------------------------------*)

module OF = OpamFile.OPAM

let add_tag ({OF.tags;_} as t) tag =
  if List.mem tag tags then t else
  OF.with_tags (tag::tags) t

let del_tag ({OF.tags;_} as t) tag =
  OF.with_tags (List.filter ((<>) tag) tags) t

let parse_filtered_constraints str =
  let lexbuf = Lexing.from_string str in
  let value = OpamBaseParser.value OpamLexer.token lexbuf in
  let filtered_constraints =
    let open OpamFormat.V in
    (package_formula `Conj (filtered_constraints ext_version)) in
  let pos = ("", 0, 0) in
  filtered_constraints.OpamPp.parse ~pos value

let add_dep ({OF.depends; _} as t) new_deps =
  let new_deps = parse_filtered_constraints new_deps in
  OF.with_depends (OpamFormula.And (depends, new_deps)) t

let handle_file ~atags ~xtags ~deps file =
  OpamFile.make (OpamFilename.of_string file) |> fun f ->
  OF.read f |> fun t ->
  let t0 = t in
  List.fold_left add_tag t atags |> fun t ->
  List.fold_left del_tag t xtags |> fun t ->
  List.fold_left add_dep t deps  |> fun t ->
  if t <> t0 then OF.write_with_preserved_format f t

let main ~atags ~xtags ~deps files =
  List.iter (handle_file ~atags ~xtags ~deps) files

open Cmdliner

let files =
  let doc = "The opam file(s) to modify tags" in
  Arg.(value & pos_all file ["opam"] & info [] ~docv:"FILE" ~doc)

let set =
  let doc = "Set this tag within the opam file. Can be specified multiple times for more than one tag." in
  Arg.(value & opt_all string [] & info ["s"; "set-tag"] ~doc ~docv:"TAG")

let rm =
  let doc = "Remove this tag within the opam file. Can be specified multiple times for more than one tag." in
  Arg.(value & opt_all string [] & info ["d"; "del-tag"] ~doc ~docv:"TAG")

let deps =
  let doc = {|Add this dependency to the opam file, for example
              $(b,"foo" {build & >= "1.0"}).|} in
  Arg.(value & opt_all string [] & info ["add-dep"] ~doc ~docv:"DEP")

let info =
  let doc = "manipulate tags within OPAM package description files." in
  let man = [ `S "BUGS"; `P "Please email $(i,mirageos-devel@lists.xenproject.org) or file an issue at $(i,https://github.com/avsm/opam-tagger/issues)" ] in
  Term.info "opam-tagger" ~version:"1.0" ~doc ~man

let () =
  let main atags xtags deps = main ~atags ~xtags ~deps in
  let t = Term.(const main $ set $ rm $ deps $ files) in
  match Term.eval (t, info) with `Ok () -> () | _ -> exit 1

(*---------------------------------------------------------------------------
   Copyright (c) 2017 Anil Madhavapeddy

   Permission to use, copy, modify, and/or distribute this software for any
   purpose with or without fee is hereby granted, provided that the above
   copyright notice and this permission notice appear in all copies.

   THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
   WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
   MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
   ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
   WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
   ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
   OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  ---------------------------------------------------------------------------*)
