/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотекка процедур создания истории МХ МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/13/04
Author: Bakhtadze Natalya
Creation date: 02/13/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "trig" &then

procedure wth-placeh_write-wth-place-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-action     as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-wth-place for ub.c-wth-place.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-wth-place.
    buffer-copy {2} to buf_c-wth-place
    assign
    buf_c-wth-place.host-code           = (if p-new-record then {3}.host-code else {2}.host-code)
    buf_c-wth-place.obj-type           = (if p-new-record then {3}.obj-type else {2}.obj-type)
    buf_c-wth-place.obj-code           = (if p-new-record then {3}.obj-code else {2}.obj-code)
    buf_c-wth-place.w-p-code           = (if p-new-record then {3}.w-p-code else {2}.w-p-code)
    buf_c-wth-place.chip-num           = next-value (s-wth-chip, {&db-name_schema})
    buf_c-wth-place.corr-time          = v-time
    buf_c-wth-place.corr-user-db-num   = g#db-num
    buf_c-wth-place.corr-user-name     = (if g#news then {&nts-user} else g#userid)
    buf_c-wth-place.corr-date          = v-date
    .
  end.

end procedure. /* write-wth-place-hist */


&endif

procedure wth-placeh_write-wth-place-proc  :
define parameter buffer buf_wth-place for ub.wth-place .
define input parameter p-action as integer no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-wth-place for ub.c-wth-place.


  do
  on error undo, return error
  :
    if not available buf_wth-place then do:
      undo, return error (vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description  + {&new-line} +
                    "Ошибка задания входных параметров:Не определено МХ МЦ" ).
    end.
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-wth-place.
    buffer-copy buf_wth-place to buf_c-wth-place
    assign
    buf_c-wth-place.host-code             = buf_wth-place.host-code
    buf_c-wth-place.obj-type             = buf_wth-place.obj-type
    buf_c-wth-place.obj-code             = buf_wth-place.obj-code
    buf_c-wth-place.w-p-code             = buf_wth-place.w-p-code
    buf_c-wth-place.chip-num           = next-value (s-wth-chip, {&db-name_schema})
    buf_c-wth-place.corr-time          = v-time
    buf_c-wth-place.corr-user-db-num   = g#db-num
    buf_c-wth-place.corr-user-name     = (if g#news then {&nts-user} else g#userid)
    buf_c-wth-place.corr-date          = v-date
    .
  end.

end procedure. /* write-clients-hist */


/* $Workfile$ e n d */