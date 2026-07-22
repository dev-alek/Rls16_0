block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dctypei3.p $
$Archive: ref/dctypei3.p $

Удаление типа ДК

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/29/07
Author: Bakhtadze Natalya
Creation date: 04/29/07

*/

define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dctypei3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dctypei3.p $":U .
define variable vss-description as character no-undo init "Удаление типа ДК".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-mess as character no-undo .
define variable v-cmd-code as integer no-undo .
define variable v-cmd-proc-handle as handle no-undo .
define variable v-command as character no-undo .
define variable v-rec-ord as integer no-undo .


define buffer buf_dis-card-type  for ub.dis-card-type.
define buffer buf_hist-nws-option for ub.hist-nws-option.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_rp-by-call for ub.rp-by-call.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer term_Dis-card-type for ub.dis-card-type.
define buffer buf_dis-card-type-attr for ub.dis-card-type-attr.
define buffer buf_dis-dct-rule for ub.dis-dct-rule.
define buffer buf_prop-ref-call for ub.prop-ref-call.
define buffer buf_dis-card for ub.dis-card.


define temp-table tt0-rp-by-call no-undo like ub.rp-by-call.
define temp-table tt0-rule-by-call no-undo like ub.rule-by-call.
define temp-table tt0-rule-call-param no-undo like ub.rule-call-param.

&glob add-dump ~
run add-dump in v-cmd-proc-handle                                                                            ~
  (input v-cmd-code                                                                                          ~
  ,input ~{&table__~}                                                                                        ~
  ,input ~{&action__~}                                                                                       ~
  ,input ~{&buffer-handle~}                                                                                  ~
  ,input '':U                                                                                                ~
  ,output v-rec-ord                                                                                          ~
  ) no-error .                                                                                               ~
if error-status :error                                                                                       ~
then do:                                                                                                     ~
delete procedure v-cmd-proc-handle .                                                                         ~
  undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4" ~
                                      ,vss-workfile                                                          ~
                                      ,vss-revision                                                          ~
                                      ,vss-description                                                       ~
                                      ,~{&new-line~}                                                         ~
                                      ,~{&table__~}                                                          ~
                                      ,v-cmd-code                                                            ~
                                      ,error-status:get-message(1)                                           ~
                                      ,return-value                                                          ~
                                      ) .                                                                    ~
end



main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  if g#db-num > 0  then do:
    message  vss-workfile vss-revision vss-description skip
            "Вызов процедуры в УБД запрещен"
    view-as alert-box ERROR.
    undo main-block, return error '':u.
  end.

  find first buf_dis-card-type exclusive-lock where recid(buf_Dis-card-type) = p-rec.

  find first buf_dis-card no-lock where
            buf_Dis-card.type = buf_dis-card-type.type
        and buf_Dis-card.emitent-host-code = buf_dis-card-type.emitent-host-code no-error.
   if available buf_dis-card then do:
    v-mess = substitute("Имеются ДК данного типа&1удаление невозможно"
                         , {&new-line}
                         , return-value ).
    run err-mess in this-procedure ( input-output v-mess) .
    undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  if not valid-handle(v-cmd-proc-handle ) then dO:
    /* инициализируем библиотеку формирования команды */
    run nws/cmd-bush.p persistent set v-cmd-proc-handle no-error .
    if error-status :error
    then do:
      delete procedure v-cmd-proc-handle .
      undo main-block, return error substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                          "&5&4&6"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          ,error-status:get-message(1)
                                          ,return-value ).
    end.
  end.
 /* начало формирования команды */
  assign
  v-command =  substitute("&2&1&3&1&4"
                         , {&delim-cmd}
                         , {&cmd-dct-send}
                         , buf_dis-card-type.emitent-host-code
                         , buf_dis-card-type.type
                         ).

  run begin-create-command in v-cmd-proc-handle
    (input v-command /* p-command-name */
    ,input "":U                /* p-db-list      */
    ,output v-cmd-code        /* p-command-code */
    ) no-error.
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при создании команды &1", {&cmd-dct-send} ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    delete procedure v-cmd-proc-handle .
    undo main-block, return error return-value .
  end.
  run rul/ruprcall.p (
                       input {&table_dis-card-type}
                      ,input buf_dis-card-type.uniq-key-rec
                      ,input ({&table_rp-by-call} + {&comma-char} + {&table_rule-by-call} + {&comma-char} + {&table_rule-call-param})
                      ,input v-cmd-proc-handle
                      ,input v-cmd-code
                      ,INPUT TABLE tt0-rp-by-call
                      ,INPUT TABLE tt0-rule-by-call
                      ,INPUT TABLE tt0-rule-call-param) no-error .
  if error-status:error then do:
    delete procedure v-cmd-proc-handle .
    message
    "Ошибка при удалении привязок профайлов и/правил для записи ТИП ДИСКОНТНОЙ КАРТЫ" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    undo main-block, return error .
  end.
  for each buf_hist-nws-option share-lock where
              buf_hist-nws-option.table-name = {&table_dis-card-type}
        and buf_hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
        AND buf_hist-nws-option.charkey_one = buf_dis-card-type.type
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
&scop table__  ~{&table_hist-nws-option~}
&scop action__ '+delete'
&scop buffer-handle buffer buf_hist-nws-option:handle
    {&add-dump}.
    delete buf_hist-nws-option.
  end.
  for each term_dis-card-type share-lock where
              term_dis-card-type.emitent-host-code = buf_dis-card-type.emitent-host-code
           and term_dis-card-type.type = buf_dis-card-type.type
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if recid(term_dis-card-type) = recid(buf_Dis-card-type) then next.

&scop table__  ~{&table_dis-card-type~}
&scop action__ '+delete'
&scop buffer-handle buffer term_dis-card-type:handle
    {&add-dump}.
    delete term_dis-card-type.
  end.
  for each buf_dis-card-type-attr share-lock where
              buf_dis-card-type-attr.emitent-host-code = buf_dis-card-type.emitent-host-code
           and buf_dis-card-type-attr.type = buf_dis-card-type.type
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
&scop table__  ~{&table_dis-card-type-attr~}
&scop action__ '+delete'
&scop buffer-handle buffer buf_dis-card-type-attr:handle
    {&add-dump}.

    delete buf_dis-card-type.
  end.
  for each buf_Dis-dct-rule share-lock where
          buf_dis-dct-rule.type = buf_dis-card-type.type
      and buf_dis-dct-rule.emitent-host-code = buf_dis-card-type.emitent-host-code
      and buf_dis-dct-rule.host-code = buf_dis-card-type.host-code
      and buf_dis-dct-rule.obj-type  = buf_dis-card-type.obj-type
      and buf_dis-dct-rule.obj-code  = buf_dis-card-type.obj-code
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if not (
            buf_dis-dct-rule.discnt-role = {&ddctr-def-pcnt}
            or
            buf_dis-dct-rule.discnt-role = {&ddctr-def-cash-pcnt}
            or
            buf_dis-dct-rule.discnt-role = {&ddctr-def-categ}
            ) then next.

&scop table__  ~{&table_dis-dct-rule~}
&scop action__ '+delete'
&scop buffer-handle buffer buf_dis-dct-rule:handle
    {&add-dump}.

    delete buf_Dis-dct-rule.
  end.

&scop table__  ~{&table_dis-card-type~}
&scop action__ '+delete'
&scop buffer-handle buffer buf_dis-card-type:handle

  {&add-dump}.
  delete buf_dis-card-type no-error.
  if error-status:error then do:
    v-mess = substitute("Ошибка при удалении: &1&2&3"
                         , error-status:get-message(1)
                         , {&new-line}
                         , return-value ).
   run err-mess in this-procedure ( input-output v-mess) .
   undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  define variable v-db-list as character no-undo .
  define buffer buf_db for ub.db.
  for each buf_db no-lock
  where buf_db.db-num > 0
  :
    assign
    v-db-list = v-db-list + {&delim-nws} + string(buf_db.db-num).
  end.
  v-db-list = trim(v-db-list, {&delim-nws}).
  run send-command in v-cmd-proc-handle
    ( input v-cmd-code  /* p-command-code */
      ,input v-db-list
      ) no-error .
  if error-status:error then do:
    delete procedure v-cmd-proc-handle .
    message
    vss-workfile vss-revision vss-description skip
    substitute( "Ошибка при отсылке команды &1", {&cmd-dct-send} ) skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
    undo main-block, return error .
  end.
  delete procedure v-cmd-proc-handle .
end.


PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Тип ДК &1 эмитент &2&3&4"
                         , buf_dis-card-type.type
                         , buf_dis-card-type.emitent-host-code
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