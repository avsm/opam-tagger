#!/usr/bin/env ocaml
#use "topfind"
#require "topkg"
open Topkg

let () =
  Pkg.describe ~metas:[] "opam-tagger" @@ fun c ->
  Ok [ Pkg.bin ~dst:"opam-tagger" "src/tagger" ]
