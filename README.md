# Migemo for OCaml #
This library is an implementation of [http://0xcc.net/migemo/](Migemo) for OCaml use.


## Motivation ##
Already exists library [https://www.kaoriya.net/software/cmigemo/](C/Migemo) as C library to be able to use from OCaml with FFI.

This library motivations are:

- Implemented by OCaml for portability
  - needless dll/so for migemo for all platform.
- More simple implementation
  - This library drops support for some encodings such as **euc-jp** and **cp932** .

Thanks to original implementation [http://0xcc.net/migemo/](Migemo), [https://www.kaoriya.net/software/cmigemo/](C/Migemo) as very helpful implementation reference.

# Development #

## Build ##

```shell
$ jbuilder build
```

## Test ##

```shell
$ jbuilder runtest
```

# License #

MIT License

# Reference #

[http://0xcc.net/migemo/](Migemo) : original implementation
[https://www.kaoriya.net/software/cmigemo/](C/Migemo) : C porting
