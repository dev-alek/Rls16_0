block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление раскладки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08

*/

TRIGGER PROCEDURE FOR DELETE OF ub.layout.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Триггер на удаление раскладки".
{ cmp/vssrevis.i "substitute('&1'
                         , ub.layout.layout-id
                                                  ) " }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-cmp as logical no-undo .
define buffer buf_c-layout for ub.c-layout.
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_rule-by-call for ub.rule-by-call.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  /*запись в историю надо осуществлять в редакторе раскладки*/
  if ub.layout.is-default = integer({&layout-default})
  and g#db-num > 0
  and not g#news
  then do:
    undo main-block, return error substitute("&1. Нельзя удалять эталонную раскладку в УБД", vss-workfile ).
  end.
  for each buf_layout-elem-rule share-lock where
          buf_layout-elem-rule.layout-id = ub.layout.layout-id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    delete buf_layout-elem-rule.
    for each buf_rule-by-call share-lock where
            buf_rule-by-call.call_id = buf_layout-elem-rule.uniq-key-rec
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
       delete buf_rule-by-call.
    end.
    for each buf_rule-call-param share-lock where
            buf_rule-call-param.call_id = buf_layout-elem-rule.uniq-key-rec
    on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
    on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
    :
       delete buf_rule-call-param.
    end.
  end.
  if not g#news
  or g#db-num = 0  then do:
    run nws/cmd-del.p
      ( input {&table_layout}
      ,input (buffer ub.layout:handle)
      ,input ''
      ) no-error .
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
    run cur-time in this-procedure ( output v-today, output v-time).
    create buf_c-layout.
    buffer-copy ub.layout except layout-id to buf_c-layout
    assign
    buf_c-layout.subject = {&table_layout}
    buf_c-layout.action = integer({&hn-delete})
    buf_c-layout.chip-num = next-value(s-ref-corr-chip, {&db-name_schema})
    buf_c-layout.corr-user-db-num = g#db-num
    buf_c-layout.corr-user-name = g#userid
    buf_c-layout.corr-date = v-today
    buf_c-layout.corr-time = v-time
    .
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_layout}
        , input ( buffer ub.layout:handle )
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
end. /*doe*/