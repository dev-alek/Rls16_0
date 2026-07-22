block-level on error undo, throw.
/*

$Revision: 7d2fe421d6dd, 1113, rls $
$Author: SMMolotkov $
$Date: Thu Dec 14 02:13:53 2017 +0300 $
$Workfile: clients2.p $
$Archive: ref/clients2.p $

Изменение статуса клиента

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/19/07
Author: Bakhtadze Natalya
Creation date: 04/19/07

*/

define input parameter parparentproc as widget-handle no-undo .
/* Параметр parparentproc внутри процедуры не используется.
   Передаётся в ref/dcardi02.p, и далее из str/saledc.p передаётся процедурам машины правил:
     v-proc-name = "rul/" + string(rule-by-call.rule_id, '999999999') + '.p'
     run value(v-proc-name) (input parparentproc, ... )        
*/
define input parameter p-rid as recid no-undo .
define input parameter p-stts like ub.clients.stts no-undo.
define input parameter p-silent as logical no-undo .
define input parameter p-thbj-included as logical no-undo .

/* параметры p-mode2, p-source-type и p-source-ref не используются */
define input parameter p-mode2 as character no-undo .
define input parameter p-source-type as character no-undo .
define input parameter p-source-ref as character no-undo .
/*можно удалять и объекты TH*/

define variable vss-revision    as character no-undo init "$Revision: 7d2fe421d6dd, 1113, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clients2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/clients2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса клиента".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/getcntxt.i def }


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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  { gbl/getcurus.i
    v-cntxt-db-num
    v-cntxt-userid
  }
  FIND first buf_clients exclusive-lock where recid( buf_clients ) = p-rid .
  CASE buf_clients.obj-type:
    when {&cmp}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_client-reference_add-del':U
        {&cntxt-global}
        0
        '':U
        0
        0
        0
        0
        true
        glog
      }
    end.
    when {&prs}
    then do:
      { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_client-reference-prs_add-del':U
        {&cntxt-global}
        0
        '':U
        0
        0
        0
        0
        true
        glog
      }
    end.
    otherwise do:
      if not p-thbj-included then do:
        if buf_clients.stts <> integer({&current-status-int})  then  do:
          v-mess = substitute("Магазины и склады&1" +
                              "можно восстановить только в АРМ'е <Администратор>.&1" +
                              "Обратитесь к администратору системы."
                              , {&new-line}).
          run err-mess in this-procedure ( input-output v-mess).
          undo main-block, return error (if p-silent = yes then v-mess else '':U).
        end.
        else do:
          v-mess = substitute("Магазины и склады&1" +
                              "можно удалять только в АРМ'е <Администратор>.&1" +
                              "Обратитесь к администратору системы."
                              , {&new-line}).
          run err-mess in this-procedure ( input-output v-mess).
          undo main-block, return error (if p-silent = yes then v-mess else '':U).
        end.
      end.
      if buf_clients.obj-type = v-cntxt-obj-type
      and buf_clients.obj-code = v-cntxt-obj-code then do:
        v-mess = substitute("Нельзя удалять текущий объект&1"
                            , {&new-line}).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
      if v-cntxt-db-num <> 0 then do:
        v-mess = substitute("Нельзя удалять &1 и &2 в ГБД&3"
                            , {&new-line}).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
      define variable v-check-db-num as integer no-undo .
      define variable v-check-user-id as character no-undo .
      define variable v-check-administrator as logical no-undo .
      { gbl/usercred.i
        v-cntxt-db-num
        v-cntxt-userid
        v-check-db-num
        v-check-user-id
        v-check-administrator
        no-error
      }
      if error-status :error
      or v-check-administrator = no then do:
        v-mess = substitute("Пользователь &1 не имеет прав администратора&2"
                            , v-cntxt-userid
                            , {&new-line}).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
      else do:
        glog = yes.
      end.
    end. /*otherwise*/
  END CASE.
  if not glog then do:
    v-mess = substitute("Нет прав на удаление клиентов типа &1", buf_clients.obj-type).
    run err-mess in this-procedure ( input-output v-mess).
    undo main-block, return error (if p-silent = yes then v-mess else '':U).
  end.
  if p-silent = no then do:
    if p-stts = ? then do:
      if buf_clients.stts <> integer({&current-status-int})  then  do:
        message
        substitute("Клиент&1" +
                    "&2&1" +
                    "У Ж Е   У Д А Л Е Н.&1"  +
                    "Восстановить данного клиента?"
                    , {&new-line}
                    , buf_clients.obj-name )
        view-as alert-box question buttons yes-no update choice .
        if not choice then do:
          undo main-block, return error '':U.
        end.
        p-stts = integer({&current-status-int}).
      end. /*if buf_clients.stts <> 0 then  do:*/
      else do:
        message
        substitute("Удалить клиента&1" +
                   "&2?"
                    , {&new-line}
                    , buf_clients.obj-name )
        view-as alert-box question buttons yes-no update choice .
        if not choice then do:
          undo main-block, return error '':U.
        end.
        p-stts = integer({&deleted-status-int}).
      end. /*else       if buf_clients.stts <> 0 then  do:*/
    end. /*if p-stts = ? then do:*/
    if buf_clients.obj-type = {&cmp}
    or buf_clients.obj-type = {&prs} then do:
      glog = no.
      message
      substitute("Внимание!&1" +
                  "Все имеющиеся у данного контрагента ДК будут переведены в статус &2"
                  , {&new-line}
                  , {&deleted-status})
      view-as alert-box question buttons YEs-no update glog .
      if not glog then undo main-block, return error '':U.
    end.
  end. /*if p-silent = no then do:*/
  else do:
    if p-stts = ? then do:
      v-mess = substitute("Неопределен статус в который надо перевести клиента&1"
                          , {&new-line}).
      run err-mess in this-procedure ( input-output v-mess).
      undo main-block, return error (if p-silent = yes then v-mess else '':U).
    end.
    else do:
&scop status-code string(buf_clients.stts)
      if buf_clients.stts = integer({&current-status-int}) and p-stts = integer({&current-status-int})  then do:
        v-mess = substitute("Клиент уже имеет статус = &1&2"
                            , {&status-int-name}
                            , {&new-line}).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
      if buf_clients.stts = integer({&deleted-status-int})  and p-stts = integer({&deleted-status-int})  then do:
        v-mess = substitute("Клиент уже имеет статус = &1&2"
                            , {&status-int-name}
                            , {&new-line}).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
      if p-stts <> integer({&current-status-int}) and p-stts <> integer({&deleted-status-int}) then do:
        v-mess = substitute("Неизвестный статус для клиента = &1&2"
                           ,p-stts
                           ,{&new-line}).
        run err-mess in this-procedure ( input-output v-mess).
        undo main-block, return error (if p-silent = yes then v-mess else '':U).
      end.
    end.
  end. /*else if p-silent = no then do:*/
  assign
  buf_clients.stts = p-stts
  .
   /*удалим все карты*/
  if p-stts = integer({&deleted-status-int}) then do:
    if buf_clients.obj-type = {&cmp}
    or buf_clients.obj-type = {&prs} then do:
      FOR EACH buf_dis-card no-lock WHERE
            buf_dis-card.cli-type = buf_clients.obj-type
      AND  buf_dis-card.cli-code = buf_clients.obj-code:
        v-dc-status =  {&deleted-status} .
        run ref/dcardi02.p (
                          input parparentproc
                          ,input recid(buf_dis-card)
                          ,input yes /*p-silent */
                          ,input no  /*p-has-right to-restore*/
                          ,input '':U /*p-mode2*/
                          ,input '':U /*source-type*/
                          ,input '':U /*source-ref*/
                          ,input v-cntxt-obj-type
                          ,input v-cntxt-obj-code
                          ,input-output v-dc-status ) no-error .
        if error-status:error then do:
          v-mess = substitute("Ошибка при изменении статуса ДК &1 для клиента &2&3&4" +
                    "&5&4&6"
                    ,buf_dis-card.d-card
                    ,buf_clients.obj-type
                    ,buf_clients.obj-code
                    ,{&new-line}
                    , error-status:get-message(1)
                    , return-value ).
          run err-mess in this-procedure ( input-output v-mess).
          undo main-block, return error (if p-silent = yes then v-mess else '':U).
        end.
       END. /*FOR EACH buf_dis-card no-lock WHERE*/
     end. /*if buf_clients.obj-type = {&cmp}*/
   end.
end. /*doe*/

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Удаление клиента &1&2&3&4"
                         , buf_clients.obj-type
                         , buf_clients.obj-code
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