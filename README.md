## opam-tagger

Add and remove values from the `tags` field in [`opam`](https://opam.ocaml.org) files.  This is useful to do large-scale updates of meta-data within the [opam-repository](https://github.com/ocaml/opam-repository), or in project-specific remotes such as the [one](https://github.com/mirage/mirage-dev) used by [MirageOS](https://mirage.io).

### Installation

There is no public release until a new version of OPAM2 is released due to the `file-format` library. You can pin the right library until then though.

#### Via Source

Use the [OPAM](https://opam.ocaml.org) package manager.

```
$ opam pin add file-format --dev
$ opam pin add -n opam-tagger https://github.com/avsm/opam-tagger.git
$ opam depext -uivy opam-tagger
```

### Usage

See help on the command line via:

```
$ opam-tagger --help
```

To set a tag:

```
$ opam-tagger -s "org:mirage" opam
```

To delete a tag:

```
$ opam-tagger -d "org:mirage" opam
```

The `opam` file will only be written to if the contents of any field change.

