block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись шкалы товара

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/

TRIGGER PROCEDURE FOR WRITE OF ub.gds-prt OLD oldb.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись шкалы товара".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/gds-prth.i gds-prt-trig oldb ub.gds-prt }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if ub.gds-prt.node-name = {&empty-scale} then do:
    /* это пустая шкала */
    /* других пустых шкал в системе быть не должно */
    if ub.gds-prt.root    <> true
    or ub.gds-prt.is-term <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильные атрибуты пустой шкалы" {&empty-scale} skip
        "ub.gds-prt.upper-code" ub.gds-prt.upper-code skip
        "ub.gds-prt.node-code"  ub.gds-prt.node-code  skip
        "ub.gds-prt.prt-root"   ub.gds-prt.prt-root   skip
        "ub.gds-prt.root"       ub.gds-prt.root       skip
        "ub.gds-prt.is-term"    ub.gds-prt.is-term    skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

  if ub.gds-prt.root = true then do:
    /* Проверка информации в корневой записи шкалы */

    define buffer buf_gds-prt for ub.gds-prt .
    find first buf_gds-prt no-lock
      where buf_gds-prt.root = true
        and buf_gds-prt.node-name = ub.gds-prt.node-name
        and recid(buf_gds-prt) <> recid(ub.gds-prt)
      no-error .
    if available buf_gds-prt then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не уникальное имя шкалы" skip
        "ub.gds-prt.upper-code"  ub.gds-prt.upper-code skip
        "ub.gds-prt.node-code"   ub.gds-prt.node-code  skip
        "ub.gds-prt.prt-root"    ub.gds-prt.prt-root   skip
        "ub.gds-prt.node-name"   ub.gds-prt.node-name  skip
        "Уже существует шкала" skip
        "buf_gds-prt.upper-code" buf_gds-prt.upper-code skip
        "buf_gds-prt.node-code"  buf_gds-prt.node-code  skip
        "buf_gds-prt.prt-root"   buf_gds-prt.prt-root   skip
        "buf_gds-prt.node-name"  buf_gds-prt.node-name  skip
        view-as alert-box error .
      undo, return error .
    end.

    if  ub.gds-prt.is-term = true
    and ub.gds-prt.node-name <> {&empty-scale} then do:
      message
        vss-workfile vss-revision vss-description skip
        "В системе уже должна присутствовать пустая шкала" {&empty-scale} skip
        "Нельзя завести еще одну пустую шкалу" ub.gds-prt.node-name skip
        "ub.gds-prt.upper-code" ub.gds-prt.upper-code skip
        "ub.gds-prt.node-code"  ub.gds-prt.node-code  skip
        "ub.gds-prt.prt-root"   ub.gds-prt.prt-root   skip
        "ub.gds-prt.node-name"  ub.gds-prt.node-name  skip
        view-as alert-box error .
      undo, return error .
    end.

    if ub.gds-prt.prt-root <> ub.gds-prt.upper-code then do:
      message
        vss-workfile vss-revision vss-description skip
        "Противоречивая информация о корне шкалы" skip
        "ub.gds-prt.upper-code" ub.gds-prt.upper-code skip
        "ub.gds-prt.node-code"  ub.gds-prt.node-code  skip
        "ub.gds-prt.prt-root"   ub.gds-prt.prt-root   skip
        "ub.gds-prt.node-name"  ub.gds-prt.node-name  skip
        view-as alert-box error .
      undo, return error .
    end.

    if ub.gds-prt.lvl-num <> 0 then do:
      message
        vss-workfile vss-revision vss-description skip
        "Номер уровня корня шкалы не должен отличаться от 0" skip
        "ub.gds-prt.upper-code" ub.gds-prt.upper-code skip
        "ub.gds-prt.node-code"  ub.gds-prt.node-code  skip
        "ub.gds-prt.prt-root"   ub.gds-prt.prt-root   skip
        "ub.gds-prt.node-name"  ub.gds-prt.node-name  skip
        "ub.gds-prt.lvl-num"    ub.gds-prt.lvl-num    skip
        view-as alert-box error .
      undo, return error .
    end.

    if ub.gds-prt.f-name <> "" then do:
      message
        vss-workfile vss-revision vss-description skip
        "Полное имя корня шкалы не должно отличаться от пустой строки" skip
        "ub.gds-prt.upper-code" ub.gds-prt.upper-code skip
        "ub.gds-prt.node-code"  ub.gds-prt.node-code  skip
        "ub.gds-prt.prt-root"   ub.gds-prt.prt-root   skip
        "ub.gds-prt.node-name"  ub.gds-prt.node-name  skip
        "ub.gds-prt.f-name"     ub.gds-prt.f-name     skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
  /*сначала пишем историю, потом зовем callnews потому что если придет основная записи а истории нет то не взведетс
  флаг обновления справочника
  */
  if not g#news then do:
    define variable v-l as logical no-undo .
    buffer-compare oldb to ub.gds-prt
    case-sensitive
    save result in v-l.
    if not v-l then
    run gds-prth_write-gds-prt-trigger in this-procedure (
                                                            input new(ub.gds-prt)
                                                           ,input (if new(ub.gds-prt)
                                                                   then integer({&hn-create})
                                                                   else integer({&hn-update}))
                                                           ).
  end.
  run str/callnews.p
    (input {&table_gds-prt}
    ,input (buffer ub.gds-prt:handle)
    ).



  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_gds-prt}
        , input ( buffer ub.gds-prt:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке записи в систему OpenXML&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.