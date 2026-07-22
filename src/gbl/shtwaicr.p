block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: shtwaicr.p $
$Archive: gbl/shtwaicr.p $

Создание ожидаемой смены

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/28/09
Author: Dmitry Ukhanov
Creation date: 01/28/09

Автор1: Бахтадзе Наталья Викторовна
Дата создания1: 11/21/07

*/

define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-shift-date as date no-undo .
define input parameter p-shift-num as integer no-undo .
define input parameter p-shift-name as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: shtwaicr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/shtwaicr.p $":U .
define variable vss-description as character no-undo init "Создание ожидаемой смены".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-err-mess as character no-undo .
define variable v-host-code as integer no-undo .
define variable obj-db-num as integer no-undo .
define buffer buf_shift-obj for ub.shift-obj.

if p-mode <> {&add-def}
AND p-mode <> {&update} then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.


main-block:
do
on error undo, return error
:
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  { gbl/objdbnum.i p-obj-type p-obj-code obj-db-num }
  if g#db-num <> obj-db-num then do:
    v-err-mess = substitute("Ожидаемую смену можно создать/изменить только в БД объекта").
    run err-mess in this-procedure ( input-output v-err-mess) .
    undo main-block, return error (if p-silent then v-err-mess else '').
  end.
  if p-shift-date = ? then do:
    v-err-mess = substitute("Не задана дата ожидаемой смены").
    run err-mess in this-procedure ( input-output v-err-mess) .
    undo main-block, return error (if p-silent then v-err-mess else '').
  end.

  if p-mode = {&add-def} then do:

    find first buf_shift-obj no-lock
      where buf_shift-obj.obj-type = p-obj-type
        and buf_shift-obj.obj-code = p-obj-code
        and buf_shift-obj.shift-date = p-shift-date
        and  buf_shift-obj.shift-num = p-shift-num
      no-error .
    if available buf_shift-obj then do:
      v-err-mess = substitute("Уже есть смена за дату: &1&2          порядок: &3"
                          ,string(p-shift-date, "99/99/9999")
                          ,{&new-line}
                          ,p-shift-num).
      run err-mess in this-procedure ( input-output v-err-mess) .
      undo, return error (if p-silent then v-err-mess else '').
    end.
    create buf_shift-obj.
    assign
      buf_shift-obj.host-code  = v-host-code
      buf_shift-obj.obj-type   = p-obj-type
      buf_shift-obj.obj-code   = p-obj-code
      buf_shift-obj.shift-date = p-shift-date
      buf_shift-obj.shift-num  = p-shift-num
      buf_shift-obj.shift-name = p-shift-name
      buf_shift-obj.status_    = {&sht-expected}
      buf_shift-obj.fact-order = 0
      p-rec = recid(buf_shift-obj)
    .
  end.
  if p-mode = {&update} then do:
    find first buf_shift-obj exclusive-lock
      where recid(buf_shift-obj) = p-rec
    .
    if buf_shift-obj.obj-type <> p-obj-type
    or buf_shift-obj.obj-code <> p-obj-code
    or buf_shift-obj.shift-date <> p-shift-date
    or buf_shift-obj.shift-num <> p-shift-num
    then do:
       v-err-mess = "Для уже имеющейся смены нельзя менять дату смены и/или порядок смены".
        run err-mess in this-procedure ( input-output v-err-mess) .
        undo, return error (if p-silent then v-err-mess else '').
    end.
    if buf_shift-obj.status_ <> {&sht-expected} then do:
       v-err-mess = "Можно изменить только ожидаемую смену".
        run err-mess in this-procedure ( input-output v-err-mess) .
        undo, return error (if p-silent then v-err-mess else '').
    end.
    assign
    buf_shift-obj.shift-name = p-shift-name
    .
  end.
  release buf_shift-obj no-error.
  if error-status:error then do:
    v-err-mess = substitute("Ошибка при сохранении :&1&2&1&3"
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value ).
    run err-mess in this-procedure ( input-output v-err-mess) .
    undo main-block, return error (if p-silent then v-err-mess else '').
  end.
end. /*doe*/



PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("(Ожидамемая) Смена на объекте: &1&2 от &3 номер &4 порядок &5:&6&7"
                         , p-obj-type
                         , p-obj-code
                         , string(p-shift-date, "99/99/9999")
                         , p-shift-name
                         , p-shift-num
                         , {&new-line}
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.