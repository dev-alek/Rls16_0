block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-rid as recid no-undo .
define input parameter p-stts like ub.clients.stts no-undo.
define input parameter p-silent as logical no-undo .
define input parameter p-thbj-included as logical no-undo .
define input parameter p-mode2 as character no-undo .
define input parameter p-source-type as character no-undo .
define input parameter p-source-ref as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 7d2fe421d6dd, 1113, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clients2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/clients2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса клиента".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable ri            as recid no-undo.
define variable v-old-status as integer no-undo .
define variable v-dc-status     as character no-undo .
define variable glog         as logical no-undo .
define variable v-mess as character no-undo .
define variable choice as logical no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_dis-card for ub.dis-card.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run getcurus in g#library2
  (output v-cntxt-db-num
  ,output v-cntxt-userid
  )  .
  FIND first buf_clients exclusive-lock where recid( buf_clients ) = p-rid .
  CASE buf_clients.obj-type:
    when 'орг':U
    then do:
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_client-reference_add-del':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    end.
    when 'чел':U
    then do:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_client-reference-prs_add-del':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output glog
    )  .
end.
    end.
    otherwise do:
      if not p-thbj-included then do:
        if buf_clients.stts <> integer('0':U)  then  do:
          v-mess = substitute("Магазины и склады&1" +
                              "можно восстановить только в АРМ'е <Администратор>.&1" +
                              "Обратитесь к администратору системы."
                              , chr(10)).
          run err-mess in this-procedure ( input-output v-mess).
          undo main-block, return error (if p-silent = yes then v-mess else '':U).
        end.
        else do:
          v-mess = substitute("Магазины и склады&1" +
                              "можно удалять только в АРМ'е <Администратор>.&1" +
                              "Обратитесь к администратору системы."
                              , chr(10)).
          run err-mess in this-procedure ( input-output v-mess).
          undo main-block, return error (if p-silent = yes then v-mess else '':U).
        end.
      end.
      if buf_clients.obj-type = v-cntxt-obj-type
      and buf_clients.obj-code = v-cntxt-obj-code then do:
        v-mess = substitute("Нельзя удалять текущий объект&1"
                            , chr(10)).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
      if v-cntxt-db-num <> 0 then do:
        v-mess = substitute("Нельзя удалять &1 и &2 в ГБД&3"
                            , chr(10)).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
      define variable v-check-db-num as integer no-undo .
      define variable v-check-user-id as character no-undo .
      define variable v-check-administrator as logical no-undo .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run usercred in g#library2
  (input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,output v-check-db-num
  ,output v-check-user-id
  ,output v-check-administrator
  ) no-error .
      if error-status :error
      or v-check-administrator = no then do:
        v-mess = substitute("Пользователь &1 не имеет прав администратора&2"
                            , v-cntxt-userid
                            , chr(10)).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
      else do:
        glog = yes.
      end.
    end.
  END CASE.
  if not glog then do:
    v-mess = substitute("Нет прав на удаление клиентов типа &1", buf_clients.obj-type).
    run err-mess in this-procedure ( input-output v-mess).
    undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  if p-silent = no then do:
    if p-stts = ? then do:
      if buf_clients.stts <> integer('0':U)  then  do:
        message
        substitute("Клиент&1" +
                    "&2&1" +
                    "У Ж Е   У Д А Л Е Н.&1"  +
                    "Восстановить данного клиента?"
                    , chr(10)
                    , buf_clients.obj-name )
        view-as alert-box question buttons yes-no update choice .
        if not choice then do:
          undo main-block, return error '':U.
        end.
        p-stts = integer('0':U).
      end.
      else do:
        message
        substitute("Удалить клиента&1" +
                   "&2?"
                    , chr(10)
                    , buf_clients.obj-name )
        view-as alert-box question buttons yes-no update choice .
        if not choice then do:
          undo main-block, return error '':U.
        end.
        p-stts = integer('1':U).
      end.
    end.
    if buf_clients.obj-type = 'орг':U
    or buf_clients.obj-type = 'чел':U then do:
      glog = no.
      message
      substitute("Внимание!&1" +
                  "Все имеющиеся у данного контрагента ДК будут переведены в статус &2"
                  , chr(10)
                  , 'удал':U)
      view-as alert-box question buttons YEs-no update glog .
      if not glog then undo main-block, return error '':U.
    end.
  end.
  else do:
    if p-stts = ? then do:
      v-mess = substitute("Неопределен статус в который надо перевести клиента&1"
                          , chr(10)).
      run err-mess in this-procedure ( input-output v-mess).
      undo main-block, return error (if p-silent = yes then v-mess else '':U).
    end.
    else do:
      if buf_clients.stts = integer('0':U) and p-stts = integer('0':U)  then do:
        v-mess = substitute("Клиент уже имеет статус = &1&2"
                            , entry (lookup (string(buf_clients.stts), '0,1,50,99':U), 'тек,удал,блок,удаление':U)
                            , chr(10)).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
      if buf_clients.stts = integer('1':U)  and p-stts = integer('1':U)  then do:
        v-mess = substitute("Клиент уже имеет статус = &1&2"
                            , entry (lookup (string(buf_clients.stts), '0,1,50,99':U), 'тек,удал,блок,удаление':U)
                            , chr(10)).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
      if p-stts <> integer('0':U) and p-stts <> integer('1':U) then do:
        v-mess = substitute("Неизвестный статус для клиента = &1&2"
                           ,p-stts
                           ,chr(10)).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
  end.
  assign
  buf_clients.stts = p-stts
  .
  if p-stts = integer('1':U) then do:
    if buf_clients.obj-type = 'орг':U
    or buf_clients.obj-type = 'чел':U then do:
      FOR EACH buf_dis-card no-lock WHERE
            buf_dis-card.cli-type = buf_clients.obj-type
      AND  buf_dis-card.cli-code = buf_clients.obj-code:
        v-dc-status =  'удал':U .
        run ref/dcardi02.p (
                          input parparentproc
                          ,input recid(buf_dis-card)
                          ,input yes
                          ,input no
                          ,input '':U
                          ,input '':U
                          ,input '':U
                          ,input v-cntxt-obj-type
                          ,input v-cntxt-obj-code
                          ,input-output v-dc-status ) no-error .
        if error-status:error then do:
          v-mess = substitute("Ошибка при изменении статуса ДК &1 для клиента &2&3&4" +
                    "&5&4&6"
                    ,buf_dis-card.d-card
                    ,buf_clients.obj-type
                    ,buf_clients.obj-code
                    ,chr(10)
                    , error-status:get-message(1)
                    , return-value ).
          run err-mess in this-procedure ( input-output v-mess).
          undo main-block, return error (if p-silent = yes then v-mess else '':U).
        end.
       END.
     end.
   end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Удаление клиента &1&2&3&4"
                         , buf_clients.obj-type
                         , buf_clients.obj-code
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
