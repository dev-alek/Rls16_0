/*

$Revision: 06dcfe20b136, 752, rls $
$Author: SSlivenko $
$Date: Wed Aug 17 15:45:44 2016 +0300 $
$Workfile: prtmpldf.i $
$Archive: gbl/prtmpldf.i $

Переменные для вызов шаблона печати

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/08/03
Author: Bakhtadze Natalya
Creation date: 07/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: prtmpldf.i $ $Revision: 06dcfe20b136, 752, rls $".

define variable {1}c-point  as character no-undo .
define variable {1}tbl      as character no-undo .
define variable {1}join-tbl as character no-undo .
define variable {1}fld      as character no-undo .
define variable {1}lab      as character no-undo .
define variable {1}spr      as character no-undo .
define variable {1}v-size   as character no-undo .
define variable {1}v-format as character no-undo .
define variable {1}dim      as character no-undo .

procedure prnfield-clear :

  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  define output parameter loc-size as character no-undo .
  define output parameter loc-format as character no-undo .
  define output parameter loc-type as character no-undo .

  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
    loc-size = "":U
    loc-format = "":U
    loc-type = "":U
  .

end procedure .

procedure prnfield-add :

  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input        parameter par-size as integer no-undo .
  define input        parameter par-format as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-size as character no-undo .
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

FUNCTION prnfield_get-fsize returns integer(
input p-type as character,
input p-format as character,
input p-label as character
):
define variable ii as integer no-undo .
define variable v-max as integer no-undo .
  do
  on error undo, return error
  :

    do ii = 1 to num-entries(p-label, {&space-char}):
      assign
      v-max = maximum(v-max, length(entry(ii, p-label, {&space-char})))
      .
    end.
    if p-format = "99:99" then return MAXIMUM(v-max,8).
    CASE p-type:
       when {&type-char} or when {&abl-datatype-character} then do:
        if p-format = "99:99" or p-format = "99:99-99:99" then return maximum(v-max, 8).
        else
        return maximum(v-max, integer(left-trim(right-trim(left-trim(left-trim(p-format, "X":U), "(":U), ")":U),">") )).
      end.
      when {&type-int} or when {&type-dec} or when {&type-date} or
      when {&abl-datatype-integer} or when {&abl-datatype-decimal} or when {&abl-datatype-date}
      then do:
        return maximum(v-max,length(p-format)).
      end.
      when {&type-log} or when {&abl-datatype-logical} then do:
        return MAXIMUM(v-max, length(entry(1, p-format, {&slash-char})), length(entry(2, p-format, {&slash-char}))).
      end.
    END CASE.
  end.

end FUNCTION. /* get-fsize */

function prnfield_get-fformat returns character ( input p-data-type as character
                                        ,input p-format as character ):
define variable v-excel-format as character no-undo .
case p-data-type:
  when {&abl-datatype-character} then do:
    v-excel-format = "@".
  end.
  when {&abl-datatype-integer} then do:
    v-excel-format = "0".
  end.
  when {&abl-datatype-decimal} then do:
    v-excel-format = substitute("0.&1", fill("0", length(entry(2, p-format, ".")))) no-error.
  end.
  when {&abl-datatype-date} then do:
    v-excel-format = "d/m/yyyy".
  end.
  otherwise do:
    v-excel-format = "@".
  end.
end.
if v-excel-format = '' then
v-excel-format = "@".
return v-excel-format .
end function.


/* $Workfile: prtmpldf.i $ e n d */