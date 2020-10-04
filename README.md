# Migemo for OCaml #
This library is an implementation of [http://0xcc.net/migemo/](Ruby/Migemo) for using in OCaml.


## Motivation ##
Already exists library [https://www.kaoriya.net/software/cmigemo/](C/Migemo) as C library to be able to use from OCaml with FFI.

This library motivations are:

- Implemented by OCaml for portability
  - needless dll/so for migemo for all platform.
- More simple implementation
  - This library drops support for some encodings such as **euc-jp** and **cp932** .

Thanks to original implementation [http://0xcc.net/migemo/](Ruby/Migemo), [https://www.kaoriya.net/software/cmigemo/](C/Migemo) as very helpful implementation reference.

# Usage #
If you want to use `migemo.el` of Emacs, put above configuration to your init.el.

```lisp
(require 'migemo)

(setq migemo-command "~/.opam/4.09.1/bin/migemocaml") ; find migemocaml in ~/.opam directory.
;; Same option when use with cmigemo.
(setq migemo-options '("-q" "--emacs"))
;; DO NOT pass migemo-dict in directory as migemo-directory.
;; The migemocaml get dictionaries automatically.
(setq migemo-dictionary "/usr/local/share/migemo/utf-8")
```

## Make migemo dictionary ##
If you have not installed cmigemo before, you must make dictionary for migemo. This repository includes tools to make it, so you type below command in top of this repository on terminal.

```shell
$ make dict
```

Result of above command creates `dict` directory and dictionary and dat files for UTF-8 encoding. You can use it with migemocaml `-d` option.

# Development #

## Build ##

```shell
$ dune build
```

## Test ##

```shell
$ dune runtest
```

# License #

MIT License

# Reference #

- [http://0xcc.net/migemo/](Ruby/Migemo) : original implementation
- [https://www.kaoriya.net/software/cmigemo/](C/Migemo) : C porting
