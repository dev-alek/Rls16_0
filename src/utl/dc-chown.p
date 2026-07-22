block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dc-chown.p $
$Archive: utl/dc-chown.p $

Смена владельца ДК two-commit

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/09/06
Author: Bakhtadze Natalya
Creation date: 05/09/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dc-chown.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/dc-chown.p $":U .
define variable vss-description as character no-undo init "Смена владельца ДК two-commit".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ nws/db-rec.i   }
{ gbl/key-rec.i  }
{ gbl/waitfram.i }
{ cmp/dc-list.i dc-list def "new shared" }
{ cmp/dcp-list.i dcp-list def "new shared" }
{ str/defc-cli.i "NEW SHARED" }

{ gbl/getcntxt.i def }

define variable glog as logical no-undo .
define variable v-is-remote-dbs as logical no-undo .
define variable v-ext-prg-handle  as handle no-undo .
define variable log-file-name as character no-undo init "dc-chown.log".
define variable cli-list as character no-undo .
define buffer buf_clients for ub.clients.

do
on error undo, return error return-value
:

  { gbl/getcntxt.i get }

  if v-cntxt-db-num <> 0 then do:

    message
    "Данную утилиту можно запустить ТОЛЬКО В ГБД"
    view-as alert-box.
    return.
  end.
  if can-find(first ub.db no-lock where ub.db.db-num > 0) then do:
    assign
    v-is-remote-dbs = yes
    .
  end.
  message
  substitute("Отберите ДК, для которых Вы хотите сменить владельца (держателя) карты&1&2&1" +
            "(Владельца карты нельзя сменить, если была продажа или возврат по накладной)&1" +
            "Предварительно данные по ДК будут удалены с касс&1" +
            "Продолжить?"
            , {&new-line}
            , (if v-is-remote-dbs
                then "Смена владельца произойдет после получения подтверждения из всех УБД"
                else '')
            )
  view-as alert-box question buttons YES-NO update glog.
  if not glog then return.


  run str/dc-list.w (
                  input parparentproc
                ,input v-cntxt-host-code-obj
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code) no-error.
  find first dc-list no-error.
  if not available dc-list then do:
    return.
  end.
  /*выберем нового владельца*/
  run ref/cli-all.w (
                   input parparentproc
                  ,input "b-sel"
                  ,input {&all}
                  ,input {&all}
                  ,input {&current}
                  ,input ?
                  ,input ",,,,,,NO,,"
                  ,input ?
                  ,output cli-list ) .
  if cli-list = "" then do:
    return.
  end.
  find first buf_clients no-lock where
            recid(buf_clients) = integer(cli-list) no-error.
  if not available buf_clients then do:
    message
    "Не найден клиент"
    view-as alert-box error .
    return.
  end.
  if buf_clients.obj-type <> {&prs}
  and buf_clients.obj-type <> {&cmp} then do:
    message
    "Дисконтные карты выдаются" skip
    "только внешним контрагентам."
    view-as alert-box ERROR .
     return.
  end.
  message
  substitute("Вы выбрали &1&2 как нового владельца отобранных карт&3" +
             "Продолжить процесс смены владельца отобранных карт?&3"
            , buf_clients.obj-type
            , buf_clients.obj-code
            , {&new-line}
            )
  view-as alert-box question buttons YES-NO update glog.
  if not glog then return.
  run proceed-chown-dc in this-procedure (
                                           input buf_clients.obj-type
                                          ,input buf_clients.obj-code
                                            )no-error.
  if error-status:error then do:
    undo, return error .
  end.
  if not can-find(first dc-list no-lock) then return.
  run hide-counter in p-log-handle.
  run set-title in p-log-handle (
        input 'Отправка информации по клиентским картам на кассу'
                                  ).

  for each dc-list :
    assign
    dc-list.status_ = {&chown-status}.
  end.


  run str/sendclia.p (
                  input parparentproc
                ,input p-parent-handle
                ,input p-log-handle
                ,input(string(g#db-num) + {&delim-par} +  {&delim-par} + "no":U + {&delim-par} + "O":U)
                  ) no-error .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input  substitute( "ошибка при удалении информации по клиентским картам с касс &1&2&1&3"
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value )
                                          ).
  end. /* error-status error*/
end. /*doe*/


procedure proceed-chown-dc :
define input parameter p-cli-type like ub.dis-card.cli-type no-undo .
define input parameter p-cli-code like ub.dis-card.cli-code no-undo .
define variable v-ii as integer no-undo .
define variable v-stop as logical no-undo .
define buffer buf_dis-card for ub.dis-card.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:

  if not v-is-remote-dbs then do:
    run value( "discardt.p":U ) persistent set v-ext-prg-handle .
  end.
  else do:
    assign
    v-is-remote-dbs = yes
    .
  end.
  _dc-list:
  for each dc-list no-lock,
      first buf_dis-card no-lock where
          buf_dis-card.d-card = dc-list.d-card:
    assign
    v-ii = v-ii + 1
    .
    run process-dis-card in this-procedure (
                                             input buf_dis-card.d-card
                                            ,input p-cli-type
                                            ,input p-cli-code) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input return-value  ).
      delete dc-list.
      next _dc-list.
    end.
    dc-list.status_ = {&chown-status}.
    run get-stop-state in p-log-handle ( output v-stop).
    if v-stop then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Процедура  остановлена пользователем"
                              )
                                ).
      leave _dc-list.
    end.
    run show-counter in p-log-handle .
    run write-counter in p-log-handle ( substitute("Обработано: &1."
                                        , v-ii
                                          )) no-error.

  END. /*for each dc-list*/
  if v-is-remote-dbs = no then
  delete procedure v-ext-prg-handle .
  run waitfram-hide in this-procedure .
end.

end procedure. /* proceed-non-used-dc */

procedure process-dis-card :
define input parameter p-d-card like ub.dis-card.d-card no-undo .
define input parameter p-cli-type like ub.dis-card.cli-type no-undo .
define input parameter p-cli-code like ub.dis-card.cli-code no-undo .

define variable v-key-rec as character no-undo .
define variable v-param as character no-undo .
define variable l-is-used as logical no-undo .
define variable v-rec as recid no-undo .
define variable v-d-card as character no-undo .
define variable v-old-status_ as character no-undo .

define buffer buf_dis-card for ub.dis-card.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf2_dis-card for ub.dis-card.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  find first buf_Dis-card no-lock where
            buf_Dis-card.d-card = p-d-card no-error.
  if not available buf_dis-card then do:
    message
    substitute("Нет карты с номером &1", p-d-card)
    view-as alert-box error .
    undo, return error .
  end.
  if buf_dis-card.mask-card then do:
    undo main-block, return error substitute("Запрещена смена клиента для карты-маски &1"
                                             , buf_dis-card.d-card
                                             ).
  end.
  if buf_dis-card.cli-type = p-cli-type
  and buf_dis-card.cli-code = p-cli-code then do:
    undo main-block, return error substitute("Не имеет смысла смена владельца карты &1 на &2&3&4" +
                                             "Карта уже принадлежит &2&3"
                                             , buf_dis-card.d-card
                                             , buf_dis-card.cli-type
                                             , buf_dis-card.cli-code
                                             , {&new-line}).
  end.
  find first buf_dis-card-type no-lock where
          buf_dis-card-type.type = buf_dis-card.type
     and  buf_dis-card-type.emitent-host-code = buf_dis-card.emitent-host-code .
  if buf_dis-card-type.type = {&dct-client}
  and buf_dis-card-type.emitent-host-code = 0 then do:
    undo main-block, return error substitute("Невозможно сменить владельца для карты типа КЛИЕНТ-СЧЕТ &1"
                                             , buf_dis-card.d-card ).

  end.
  for each buf2_dis-card no-lock where
          buf2_dis-card.card-num = buf_dis-card.card-num:
    if buf2_dis-card.d-card = buf_dis-card.d-card then next.
    undo main-block, return error substitute("Смена влад. невозможна: dis-card Перевыпущенная карта &1 для карты &2", buf2_dis-card.d-card, buf_dis-card.d-card).
  end.
  if v-is-remote-dbs then do:
    run gen-key-rec( input {&table_dis-card}
                    ,input (buffer buf_dis-card:handle )
                    ,output v-key-rec
                  ) no-error.
    if error-status :error then do:
      undo main-block, return error substitute("&1 &2 &3&4Ошибка при генерации уникального ключа для ДК&4&5&6&5&7"
                                                ,vss-workfile
                                                ,vss-revision
                                                ,vss-description
                                                , buf_dis-card.d-card
                                                ,{&new-line}
                                                , error-status:get-message(1)
                                                , return-value ).
    end.
    assign
    v-param = string(buf_dis-card.d-card) + {&delim-par} +
              buf_dis-card.status_ + {&delim-par} +
              p-cli-type + {&delim-par} +
              string(p-cli-code) + {&delim-par} +
              buf_dis-card.cli-type + {&delim-par} +
              string(buf_dis-card.cli-code)
    .
    run nws/db-rec.p ( input {&chown-dis-card}
                  ,input v-key-rec
                  ,input v-param
                ) no-error .
  end. /*для системы с удаленками        */
  else do:
    find current buf_dis-card exclusive-lock.
    assign
    buf_dis-card.status_ = {&chown-status}
    v-rec = recid(buf_dis-card)
    v-d-card = buf_dis-card.d-card
    .
    release buf_Dis-card.
    find first buf_dis-card where
              recid(buf_Dis-card) = v-rec.

    run value( "proc-is-used-trn-doc-dis-card" ) in v-ext-prg-handle (
                                                                buffer buf_dis-card
                                                              , input g#db-num
                                                              , output l-is-used) no-error .
    if not error-status:error
    and not l-is-used then do:

      run value ("proc-chown-dis-card") in  v-ext-prg-handle (
                                                                buffer buf_dis-card
                                                              , input p-cli-type
                                                              , input p-cli-code)
                                                              .
      assign
      buf_dis-card.status_ = v-old-status_.
    end.
  end.
  if error-status :error then do:
    run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input  substitute( "&1 &2 &3&4Ошибка при смены владельца ДК&4Карта &5&4&6&4&7"
                                  ,vss-workfile
                                  ,vss-revision
                                  ,vss-description
                                  , {&new-line}
                                  ,buf_dis-card.d-card
                                  ,error-status:get-message(1)
                                  ,return-value )
                                          ).
    undo main-block, return error.
  end.
  else do:
    if v-is-remote-dbs then
    run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input  substitute( "Карта &1: начат процесс смены владельца"
                                   ,buf_dis-card.d-card )
                                          ).
    else
    run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input  substitute( "Карта &1: смена владельца завершена"
                                   ,v-d-card )
                                          ).


  end.
end. /*doe*/

end procedure. /* process-dis-card */