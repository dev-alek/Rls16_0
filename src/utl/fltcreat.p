block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fltcreat.p $
$Archive: utl/fltcreat.p $

Утилита для автоматического создания кода процедуры init-flt

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter fld as character no-undo .
define input parameter lab as character no-undo .
define input parameter spr as character no-undo .
define input parameter dim as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fltcreat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fltcreat.p $":U .
define variable vss-description as character no-undo init "Утилита для автоматического создания кода процедуры init-flt".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }


define stream ff .

define variable for-file as character no-undo .
define variable v-ind    as integer   no-undo .
define variable for-fld  as character no-undo .
define variable for-lab  as character no-undo .
define variable for-spr  as character no-undo .


run gbl/d-prompt.w (
    'title=':u + "Имя файла" + '\':u
  + 'text1=':u + "Введите имя файла для вывода " + '\':u
  + 'text2=':u + "кода инициализации фильтра" + '\':u
  + 'format=' + 'x(256)':u + '\':u
  + 'type=char\':u
  + 'boxprog=getfile.p\':u
  ,input-output for-file
  ).
if return-value = 'false':u then do:
  return .
end.

if num-entries(fld) <> dim then do:
    message "Неверный входной параметр 1" skip
    "fld=" num-entries(fld) "dim=" dim
    view-as alert-box ERROR.
    return.
end.
if num-entries(spr) <> dim then do:
    message "Неверный входной параметр 3" skip
    "spr=" num-entries(spr) "dim=" dim
    view-as alert-box ERROR.
    return.
end.
if num-entries(lab) <> dim then do:
    message "Неверный входной параметр 2" skip
    "lab=" num-entries(lab) "dim=" dim
    view-as alert-box ERROR.
    return.
end.


output stream ff to value(for-file).

do v-ind = 1 to dim:

  assign
  for-fld = entry(v-ind, fld)
  for-lab = entry(v-ind, lab)
  for-spr = entry(v-ind, spr)
  no-error.

  PUT STREAM ff unformatted
  "run fltfield-add in this-procedure("
  ( {&single-quote} + for-fld + {&single-quote})
  ", ":u
  ( {&single-quote} + for-lab + {&single-quote})
  ", ":U
  ( {&single-quote} + for-spr + {&single-quote})
  ", ":U skip
  "input-output fld, input-output lab, input-output spr, input-output dim)  no-error."
  skip.
end.

output stream ff close.