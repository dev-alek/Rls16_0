/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Переменные для вызов шаблона печати

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/08/03
Author: Bakhtadze Natalya
Creation date: 07/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable {1}c-point  as character no-undo .
define variable {1}tbl      as character no-undo .
define variable {1}join-tbl as character no-undo .
define variable {1}fld      as character no-undo .
define variable {1}lab      as character no-undo .
define variable {1}spr      as character no-undo .
define variable {1}v-size   as character no-undo .
define variable {1}v-size-min  as character no-undo .
define variable {1}v-format as character no-undo .
define variable {1}dim      as character no-undo .

procedure prnfield-clear :

  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  define output parameter loc-size as character no-undo .
  define output parameter loc-size-min as character no-undo .
  define output parameter loc-format as character no-undo .
  define output parameter loc-type as character no-undo .

  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
    loc-size = "":U
    loc-size-min = "":U
    loc-format = "":U
    loc-type = "":U
  .

end procedure .

procedure prnfield-add :

  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input        parameter par-size as integer no-undo .
  define input        parameter par-size-min as integer no-undo .
  define input        parameter par-format as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-size as character no-undo .
  define input-output parameter loc-size-min as character no-undo .
  define input-output parameter loc-format as character no-undo .
  define input-output parameter loc-dim as character no-undo .


  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + {&comma-char} + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + {&comma-char} + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + {&comma-char} + par-spr)
    loc-size = if loc-dim = '0'
              then string(par-size)
              else (loc-size + {&comma-char} + string(par-size))
    loc-size-min = if loc-dim = '0'
              then string(par-size-min)
              else (loc-size-min + {&comma-char} + string(par-size-min))
    loc-format = if loc-dim = '0'
              then par-format
              else (loc-format + {&delim-par} + string(par-format))
    no-error
    .
    assign
    entry(num-entries(loc-dim), loc-dim) = string(integer(entry(num-entries(loc-dim), loc-dim)) + 1)
    no-error
    .
  end.

end procedure. /* add-filter-field */



/* $Workfile$ e n d */