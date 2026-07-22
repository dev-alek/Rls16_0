block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление свойства ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/15/06
Author: Bakhtadze Natalya
Creation date: 08/15/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.dis-card-property.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление свойства ДК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/disproph.i trigger ub.dis-card-property ub.dis-card-property delete }
{ ref/discprop.i }

define variable v-trg-param as character no-undo .
define variable v-run-hist as logical no-undo .
v-trg-param = ub.dis-card-property.trg-param.
ub.dis-card-property.trg-param = '':U.

define buffer locked_dis-card-property for ub.dis-card-property.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if ub.dis-card-property.dtm-code > 0
  and discprop-usercanedit ( input ub.dis-card-property.dtm-code, input g#db-num) = yes
  then do:
    Find first locked_dis-card-property exclusive-lock  where
              locked_dis-card-property.d-card    = ub.dis-card-property.d-card
          AND locked_dis-card-property.dtm-code  = 0
          no-error no-wait.
    if locked locked_dis-card-property then do:
      undo main-block, return error substitute("Свойство &1 для ДК &2 занято"
                                                , ub.dis-card-property.dtm-code
                                                , ub.dis-card-property.d-card
                                                ).
    end.
  end.


  if lookup({&trg-param-no-hist}, v-trg-param) = 0
  and ub.dis-card-property.dtm-code > 0
  then do:
      assign
      v-run-hist = yes
      .
  end.
  if v-run-hist then do:
    run disproph_write-dcp-trigger  in this-procedure  (
                                         input no
                                          ,input (if g#news
                                                  then {&hn-source-db}
                                                  else (if g#esys
                                                        then {&hn-source-esys}
                                                        else "":U)
                                                  )
                                          ,input  (if g#news
                                                    then string(g#news-source-db)
                                                    else (if g#esys
                                                          then string(g#esys-source-esys)
                                                          else "":U)
                                                    )
                                      ) .
  end.
  if lookup({&trg-param-no-callnews}, v-trg-param) = 0
  and ub.dis-card-property.dtm-code > 0
  then do:
    run nws/cmd-del.p
      ( input {&table_dis-card-property}
      ,input (buffer ub.dis-card-property:handle)
      ,input '':U
      ) no-error .
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.

  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_dis-card-property}
        , input ( buffer ub.dis-card-property:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.