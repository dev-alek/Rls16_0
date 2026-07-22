block-level on error undo, throw.
define input parameter p-silent as logical no-undo .
define input parameter p-rec as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dctypei3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dctypei3.p $":U .
define variable vss-description as character no-undo init "Удаление типа ДК".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
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
                         , chr(10)
                         , return-value ).
    run err-mess in this-procedure ( input-output v-mess) .
    undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  if not valid-handle(v-cmd-proc-handle ) then dO:
    run nws/cmd-bush.p persistent set v-cmd-proc-handle no-error .
    if error-status :error
    then do:
      delete procedure v-cmd-proc-handle .
      undo main-block, return error substitute("&1 &2 &3&4Ошибка при запуске процедуры cmd-bush.p&4" +
                                          "&5&4&6"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,chr(10)
                                          ,error-status:get-message(1)
                                          ,return-value ).
    end.
  end.
  assign
  v-command =  substitute("&2&1&3&1&4"
                         , chr(6)
                         , 'cmd-dct-send':U
                         , buf_dis-card-type.emitent-host-code
                         , buf_dis-card-type.type
                         ).
  run begin-create-command in v-cmd-proc-handle
    (input v-command
    ,input "":U
    ,output v-cmd-code
    ) no-error.
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при создании команды &1", 'cmd-dct-send':U ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    delete procedure v-cmd-proc-handle .
    undo main-block, return error return-value .
  end.
  run rul/ruprcall.p (
                       input 'dis-card-type':U
                      ,input buf_dis-card-type.uniq-key-rec
                      ,input ('rp-by-call':U + chr(44) + 'rule-by-call':U + chr(44) + 'rule-call-param':U)
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
              buf_hist-nws-option.table-name = 'dis-card-type':U
        and buf_hist-nws-option.host-code = buf_dis-card-type.emitent-host-code
        AND buf_hist-nws-option.charkey_one = buf_dis-card-type.type
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'hist-nws-option':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_hist-nws-option:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'hist-nws-option':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    delete buf_hist-nws-option.
  end.
  for each term_dis-card-type share-lock where
              term_dis-card-type.emitent-host-code = buf_dis-card-type.emitent-host-code
           and term_dis-card-type.type = buf_dis-card-type.type
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if recid(term_dis-card-type) = recid(buf_Dis-card-type) then next.
    run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'dis-card-type':U                                                                                          ,input '+delete'                                                                                         ,input buffer term_dis-card-type:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-card-type':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    delete term_dis-card-type.
  end.
  for each buf_dis-card-type-attr share-lock where
              buf_dis-card-type-attr.emitent-host-code = buf_dis-card-type.emitent-host-code
           and buf_dis-card-type-attr.type = buf_dis-card-type.type
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'dis-card-type-attr':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_dis-card-type-attr:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-card-type-attr':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    delete buf_dis-card-type.
  end.
  for each buf_Dis-dct-rule share-lock where
          buf_dis-dct-rule.type = buf_dis-card-type.type
      and buf_dis-dct-rule.emitent-host-code = buf_dis-card-type.emitent-host-code
      and buf_dis-dct-rule.host-code = buf_dis-card-type.host-code
      and buf_dis-dct-rule.obj-type  = buf_dis-card-type.obj-type
      and buf_dis-dct-rule.obj-code  = buf_dis-card-type.obj-code
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if not (
            buf_dis-dct-rule.discnt-role = 'def-pcnt':U
            or
            buf_dis-dct-rule.discnt-role = 'def-cash-pcnt':U
            or
            buf_dis-dct-rule.discnt-role = 'def-categ':U
            ) then next.
    run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'dis-dct-rule':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_dis-dct-rule:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-dct-rule':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
    delete buf_Dis-dct-rule.
  end.
  run add-dump in v-cmd-proc-handle                                                                              (input v-cmd-code                                                                                            ,input 'dis-card-type':U                                                                                          ,input '+delete'                                                                                         ,input buffer buf_dis-card-type:handle                                                                                    ,input '':U                                                                                                  ,output v-rec-ord                                                                                            ) no-error .                                                                                               if error-status :error                                                                                       then do:                                                                                                     delete procedure v-cmd-proc-handle .                                                                           undo main-block, return error substitute("&1 &2 &3&4Ошибка при добавлении записи &5 в команду с кодом &6&4&8&4&9&4"                                       ,vss-workfile                                                                                                ,vss-revision                                                                                                ,vss-description                                                                                             ,chr(10)                                                                                               ,'dis-card-type':U                                                                                                ,v-cmd-code                                                                                                  ,error-status:get-message(1)                                                                                 ,return-value                                                                                                ) .                                                                    end.
  delete buf_dis-card-type no-error.
  if error-status:error then do:
    v-mess = substitute("Ошибка при удалении: &1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
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
    v-db-list = v-db-list + chr(1) + string(buf_db.db-num).
  end.
  v-db-list = trim(v-db-list, chr(1)).
  run send-command in v-cmd-proc-handle
    ( input v-cmd-code
      ,input v-db-list
      ) no-error .
  if error-status:error then do:
    delete procedure v-cmd-proc-handle .
    message
    vss-workfile vss-revision vss-description skip
    substitute( "Ошибка при отсылке команды &1", 'cmd-dct-send':U ) skip
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
                         , chr(10)
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
