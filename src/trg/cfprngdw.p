block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на запись истории товаров на принтерах кухни

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/11/05
Author: Bakhtadze Natalya
Creation date: 08/11/05

*/

TRIGGER PROCEDURE FOR WRITE OF ub.c-fbr-prn-gds.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на запись истории товаров на принтерах кухни".

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6|&7'
                           , ub.c-fbr-prn-gds.db-num
                           , ub.c-fbr-prn-gds.prn-num
                           , ub.c-fbr-prn-gds.obj-type
                           , ub.c-fbr-prn-gds.obj-code
                           , ub.c-fbr-prn-gds.gds-code
                           , ub.c-fbr-prn-gds.corr-user-db-num
                           , ub.c-fbr-prn-gds.chip-num
                           ) " }
{ cmp/trg-def.i }

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if not g#news and ub.c-fbr-prn-gds.db-num <> g#db-num then do:
    if ( g#db-num > 0 ) then do:
      message
      vss-workfile vss-revision vss-description skip
      "Нельзя создавать записи истории товаров на ПРИНТЕРАХ КУХНИ в чужой БД" skip
      "ПРИНТЕР КУХНИ установлен в БД" ub.c-fbr-prn-gds.db-num skip
      "Текущая БД" g#db-num
      view-as alert-box error .
      undo main-block, return error.
    end.
  end.
  if not g#news then do:
    run str/callnews.p
      (input "c-fbr-prn-gds"
      ,input (buffer ub.c-fbr-prn-gds:handle)
      ).
  end.
    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_update}
        , input {&table_c-fbr-prn-gds}
        , input ( buffer ub.c-fbr-prn-gds:handle )
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