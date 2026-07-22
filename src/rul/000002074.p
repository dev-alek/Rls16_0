block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 18 набор правил 4

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/08/06
Author: Bakhtadze Natalya
Creation date: 10/08/06


---------------------------&start-codex_id=18;ruleset_id=4;-----------------
Импорт данных по заказам

---------------------------&end-codex_id=18;ruleset_id=4;-----------------

*/

/*---------------------------&start-using-class&-------------------------------*/


/*---------------------------&end-using-class&---------------------------------*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-doc-code as character no-undo .
define input parameter p-process-file-name as character no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18 набор правил 4".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ str/ord-list.i ord-list def "shared" }
{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code

{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }
{ rul/library-cls.i "non-class-part" }
{ gbl/key-rec.i }
{ rul/tempcxml.i "shared" }
{ gbl/gate-clb.i }
{ rul/ruleset_.i }
{ cus/exiteedi-status.i -t }
{ cus/edocsord.i edi }
{ ref/extclass.i }
{ cus/cr-edist.i }
&undefine cr-edist_i
{ cus/cr-edist.i  tt }
{ cus/str-edi.i }

/*переменные контекста*/
/*это у нас объект 0*/

define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-doc-code as character no-undo .
define variable v-current-doc-date as date no-undo .
define variable v-current-doc-type as character no-undo .
define variable v-current-doc-time as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-current-date as date no-undo .
/*****************************/
define variable v-sign as integer no-undo .
define variable file-name as char.
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable v-last-error-message as character no-undo .
define variable v-retry-action as integer no-undo .
define variable v_dataseth as handle no-undo .
define variable v-xmlh as handle no-undo .
define variable glog as logical no-undo .
define variable v-esys-id as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-pack-num-chr as character no-undo .
define variable v-dm-edi    as integer   no-undo .

{ rul/seterror.i }
define buffer buf_temp-cmd for temp-cmd.
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.

define buffer buf_temp-xml-tables for temp-xml-tables.


define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .


function 00180004_get-error-message returns character :
define variable v-ii as integer no-undo .
define variable v-mess as character no-undo .
DO v-ii = 1 TO ERROR-STATUS:NUM-MESSAGES:
    v-mess = substitute("&1&2ош &3"
                        ,v-mess
                        ,{&new-line}
                        ,ERROR-STATUS:GET-MESSAGE(v-ii)).
END.
end function.




&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~).            ~
          assign v-view-log = yes



/*---------------------------&start-rule-call-param&-------------------------------*/
  define variable p-xsd-file as character no-undo.


/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/





/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run delete-procedure in this-procedure .
end.


&scop sign v-sign *

run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error .
if error-status:error
or return-value = "return" then return.

/* ------------------------- &start-def-vars& -----------------------------------*/

/* ------------------------- &end-def-vars& -----------------------------------*/


if not this-procedure:persistent then do:
  run proc-main in this-procedure  no-error .
  if error-status:error then do:
      run delete-procedure in this-procedure .
      &scop my-message substitute( "&1. &2&3&4", vss-workfile, v-rv, ~{&new-line~}, v-esm)
      {&display-message}.
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  run delete-procedure in this-procedure .
end.

procedure proc-main :
define variable v-ii as integer   no-undo .
define variable v-crc-pack as character no-undo .
define variable v-mess as character no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-dump-ord-int64 as int64 no-undo .
define variable v-trn-code as character no-undo .
define variable v-doc-code as character no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer no-undo .
define variable v-ord-int1 as integer no-undo .
define variable v-ps as character no-undo .
define variable v-new-st as integer no-undo .
define variable v-edist-mess as character no-undo .
define variable v-date-status as date no-undo .
define variable v-time-status as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-execute as logical no-undo .


define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_ord-chain for ub.ord-chain.
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define buffer buf_esys-route for ub.esys-route.
define buffer buf_edi-status for ub.edi-status.
define buffer buf_clients for ub.clients.

/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option -----------------------------------*/


  /* ------------------------- &start-rule& -----------------------------------*/
_status:
do transaction
on error  undo _status, retry _status
on stop   undo _status, retry _status
on endkey undo _status, retry _status
:
  if retry then do:
    &scop my-message substitute("Ошибка:&1&2&1&3&1&4", ~{&new-line~}, error-status:get-message(1) , return-value, v-mess)
    {&display-message}.
    assign
    v-view-log = yes.
    undo _status, return error {&my-message}.
  end.
  else do:
    run write-log  in p-log-handle (
                                    input 0
                                  , "&DLine").
    &scop my-message substitute(".............Импорт подтверждений из ВС")
      {&display-message}.
    find first status_-t.
    num-rec = num-rec + 1.
    if status_-t.status_ = 0 then do:
      /*доставлен на платформу EXITE - надо найти пакет и создать запись во временной таблице temp-esys-pck-rcvd
      тогда маршрутизация удалится            */
      case status_-t.messageclass:
        when "ORDERS" then do:
            for each buf_edi-status no-lock where
                    buf_edi-status.tbl-name = {&table_ord-doc}
                and buf_edi-status.doc-code = status_-t.customericid
            by buf_edi-status.tbl-name
            by buf_edi-status.doc-code
            by buf_edi-status.date-status
            by buf_edi-status.time-status
            :
              if buf_edi-status.state = {&edi-orders} then do:
                v-dump-ord-int64 = int64(cr-edist_get-mess-key-value(buf_edi-status.mess-id, {&edist_route})).
                leave.
              end.
            end.
        end. /*when "ORDERS" then do:*/
        /*  уже читаем*/
        when "ORDRSP" then do:
            for each buf_edi-status no-lock where
                    buf_edi-status.tbl-name = {&table_ord-doc}
                and buf_edi-status.doc-code = status_-t.customericid
            by buf_edi-status.tbl-name
            by buf_edi-status.doc-code
            by buf_edi-status.date-status
            by buf_edi-status.time-status
            :
              if buf_edi-status.state = {&edi-ordrsp-no}
              or buf_edi-status.state = {&edi-ordrsp-yes}
              then do:
                v-dump-ord-int64 = int64(cr-edist_get-mess-key-value(buf_edi-status.mess-id, {&edist_route})).
                leave.
              end.
            end.
        end. /*when "ORDRSP" then do:*/
        when "RECADV" then do:
            for each buf_edi-status no-lock where
                    buf_edi-status.tbl-name = {&table_trn-doc}
                and buf_edi-status.doc-code = status_-t.customericid
            by buf_edi-status.tbl-name
            by buf_edi-status.doc-code
            by buf_edi-status.date-status
            by buf_edi-status.time-status
            :
              if buf_edi-status.state = {&edi-recadv} then do:
                v-dump-ord-int64 = int64(cr-edist_get-mess-key-value(buf_edi-status.mess-id, {&edist_route})).
                leave.
              end.
            end.
        end. /*when "RECADV" then do:*/
        otherwise do:
          v-mess = substitute("Получено непредусмотренное подтверждение на документ типа &1", status_-t.messageclass).
          undo _status, retry _status.
        end.
      end case. /*case status_-t.messageclass:*/
      find first buf_esys-route no-lock where
          buf_esys-route.esr-dump-ord   = v-dump-ord-int64
      and buf_esys-route.esys-id   = v-esys-id
      and buf_esys-route.db-num   = 0 /*для спец систем всегда 0*/ no-error.
      if available buf_esys-route then do:
        /*заменим номер рута на номер пакета*/
        v-edist-mess = ''.
        v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, {&edist_pack-num}, string(buf_esys-route.esr-last-pack) + "->").

        run update-edi-state-light in this-procedure ( input buf_edi-status.tbl-name
                                                      ,input buf_edi-status.doc-code
                                                      ,input buf_edi-status.date-status
                                                      ,input buf_edi-status.time-status
                                                      ,input buf_edi-status.state
                                                      ,input buf_edi-status.err-code
                                                      ,input buf_edi-status.des-err
                                                      ,input v-edist-mess
                                                      )
                                                      .
        run get-xcnf_create-temp-esys-pck-rcvd in p-cont-handle (
                                                                  input v-esys-id
                                                                ,input buf_esys-route.esr-last-pack
                                                                ,input v-crc-pack
                                                                ,input yes /*p-rcvd*/
                                                                ,input 1 /*p-rcvd-recs*/
                                                                ,input 1 /*p-total-recs*/
                                                                ,input status_-t.datein
                                                                ,input integer(entry(1, status_-t.timein, ":")) * 3600 +
                                                                        integer(entry(2, status_-t.timein, ":")) * 60
                                                                ,input status_-t.timein
                                                                ) .
        run cur-time in this-procedure ( output v-today, output v-time).
        run get-xcnf_create-temp-esys-pck-sent in p-cont-handle (
                                                                  input v-esys-id
                                                                ,input integer(v-pack-num-chr)
                                                                ,input v-crc-pack
                                                                ,input yes /*p-rcvd*/
                                                                ,input 1 /*p-rcvd-recs*/
                                                                ,input 1 /*p-total-recs*/
                                                                ,input v-today
                                                                ,input v-time
                                                                ,input string(v-time, "HH:MM:SS")
                                                                ) .
      end.
    end. /*if status_-t.status_ = 0 then do:*/
    else do:
      v-execute = yes.
      case status_-t.messageclass:
        when "ORDERS" then do:
          find first buf_ord-doc no-lock where
                    buf_ord-doc.doc-code = status_-t.customericid no-error.
          if not available buf_ord-doc then do:
            v-mess = substitute("Не найден заказ поставщику с номером &1", status_-t.customericid).
            undo _status, retry _status.
          end.
          assign
          v-tbl-name = {&table_ord-doc}
          v-doc-code = buf_ord-doc.doc-code
          v-trn-code = ''
          v-ord-int1 = integer({&edi-orders-sts})
          .
        end. /*when "ORDERS" then do:*/
        when "ORDRSP" then do:
          /*непонятно будет или нет*/
          /*сначала ищем контрагента по GLN*/
          find first buf_ext-classif no-lock where
                    buf_ext-classif.classif-subject = {&table_clients}
                and buf_ext-classif.classif-name = {&extclass_clients_GLN}
                and buf_ext-classif.charkey_one = status_-t.to_  no-error.
          if not available buf_ext-classif then do:
            v-mess = substitute("Не найден контрагент с кодом GLN &1", status_-t.from_).
            undo _status, retry _status.
          end.
          /*найдем клиента*/
          run gen-row-keyr in this-procedure ( input buf_ext-classif.uniq-key-rec
                                              ,input  ? /*p-key-handle  буфер записи которую будем искать. если ищем по key-rec то ? */
                                              ,input "ub"
                                              ,input ? /*p-tt-handle  буфер таблицы - если надо найти во временной таблице. если ищем в БД то ? */
                                              ,input no-lock
                                              ,output v-tbl-row
                                              ,output v-tbl-name) no-error.
          if error-status:error then do:
            v-mess = substitute("Ошибка при поиске клиента по uniq-key-rec &1&2&3&2&4"
                              , v-tbl-row
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value
                              ).
            undo _status, retry _status.
          end.
          find first buf_clients no-lock where
                    rowid(buf_clients) = v-tbl-row no-error.
          if not available buf_clients then do:
            v-mess = substitute("Не найден клиент с rowid &1"
                              , v-tbl-row
                              ).
            undo _status, retry _status.
          end.
          find first buf_ord-doc no-lock where
                  buf_ord-doc.cli-type =  buf_clients.obj-type
              and buf_ord-doc.cli-code =  buf_clients.obj-code
              and entry(1, buf_ord-doc.cli-out-doc, {&delim-par}) = status_-t.customericid no-error.
          if not available buf_ord-doc then do:
            v-mess = substitute("Не найден заказ поставщику &1&2 (GLN &3), с номером подтверждения заказа &1"
                                 , buf_clients.obj-type
                                 , buf_clients.obj-code
                                 , status_-t.customericid).
            undo _status, retry _status.
          end.
          assign
          v-tbl-name = {&table_ord-doc}
          v-doc-code = buf_ord-doc.doc-code
          /*  так нельзя писать - статус переводится может только документом ordrsp!!!
          v-ord-int1 = integer({&edi-ordrsp-sts})

          */
          v-ord-int1 = buf_ord-doc.ord-int1
          v-trn-code = ''
          v-execute = no
          .
        end. /*when "ORDRSP" then do:*/
        when "RECADV" then do:
          find first buf_trn-doc no-lock where
                    buf_trn-doc.doc-code = status_-t.customericid no-error.
          if not available buf_trn-doc then do:
            v-mess = substitute("Не найдена приходная накладная с номером &1, на которую пришло подтверждение", status_-t.customericid).
            undo _status, retry _status.
          end.
          /*надо найти заказ*/
          find first buf_ord-chain   no-lock where
                    buf_ord-chain.rel-doc-code = buf_trn-doc.doc-code
                and buf_ord-chain.rel-doc-type = "trn"
                and buf_ord-chain.doc-type = "rcv" no-error .
          if not available buf_ord-chain then do:
            v-mess = substitute("Не найдена цепочка поставок к заказу для накладной прихода с номером &1", status_-t.customericid).
            undo _status, retry _status.
          end.
          find first buf_ord-doc-rcv no-lock where
                    buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code no-error .
          if not available buf_ord-doc-rcv then do:
            v-mess = substitute("Не найдена поставка для приходной накладной с номером &1", status_-t.customericid).
            undo _status, retry _status.
          end.
          find first buf_ord-doc no-lock where
                    buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code no-error .
          if not available buf_ord-doc then do:
            v-mess = substitute("Не найден заказ по которому была приходная накладная с номером &1", status_-t.customericid).
            undo _status, retry _status.
          end.
          assign
          v-tbl-name = {&table_trn-doc}
          v-doc-code = buf_trn-doc.doc-code
          v-trn-code = entry(1, buf_ord-doc-rcv.sub-par, {&delim-par}). /*номер накладной поставщика*/
          v-ord-int1 = integer({&edi-recadv-sts})
          .
        end. /*when "RECADV" then do:*/
        otherwise do:
          v-mess = substitute("Получено непредусмотренное подтверждение на документ типа &1", status_-t.messageclass).
          undo _status, retry _status.
        end.
      end case. /*case status_-t.messageclass:*/
      assign
      v-cli-type = buf_ord-doc.cli-type
      v-cli-code = buf_ord-doc.cli-code
      v-ps = buf_ord-doc.ps
      .
      /*проверим работает ли по exite*/
      assign
      glog = status-is-edi ( input yes  /*p-ies-edi*/
                          , input buf_ord-doc.cli-type
                          , input buf_ord-doc.cli-code
                          , input buf_ord-doc.obj-type
                          , input buf_ord-doc.obj-code
                          , output v-dm-edi
                          ) no-error.
      if not glog = yes then do:
        v-mess = substitute("Нет обмена Документами по EXITE-EDI для поставщика &1&2 и &3&4 в БД &5)"
                          , buf_ord-doc.cli-type
                          , buf_ord-doc.cli-code
                          , buf_ord-doc.obj-type
                          , buf_ord-doc.obj-code
                          , g#db-num).
        undo _status, retry _status.
      end.
      if v-execute then do:
      run edocsord_edi-import in this-procedure (
                                              buffer buf_ord-doc
                                            ,input entry(1, buf_ord-doc.cli-out-doc, {&delim-par})
                                            ,input v-trn-code
                                            ,input v-ord-int1
                                            ,input buf_ord-doc.ship-date
                                            ,input buf_ord-doc.ps
                                            ,input v-pack-num-chr
                                            ,input status_-t.exiteicid
                                            ,output v-ps
                                            ,output v-new-st
                                            ) no-error.
      if error-status:error then do:
        if return-value <> '' then do:
          v-mess = substitute("Ошибка при изменении статуса заказа при приеме данных:&1&2", {&new-line}, return-value ).
          undo _status, retry _status.
        end.
      end.
      end.
      if not error-status:error
      or not v-execute then do:
        v-edist-mess = ''.
        v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, {&edist_pack-num}, "->" + v-pack-num-chr).
        v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, {&edist_ediinterchangeid}, status_-t.EXiteICID).
        v-date-status = ?.
        run create-edi-state in this-procedure (
                                                input v-tbl-name                   /* p-tbl-name */
                                              , input v-doc-code                   /* p-doc-code */
                                              , input v-cli-type                   /* p-cli-type */
                                              , input v-cli-code                   /* p-cli-code */
                                              , input {&update}                    /* p-act      */
                                              , input v-ord-int1                   /* p-state    */
                                              , input integer({&severity-no-error}) /* p-err      */
                                              , input v-PS                         /* p-des      */
                                              , input v-edist-mess                 /* p-mess     */
                                              , input integer({&doc-dm-edi})
                                              , input-output v-date-status
                                              , input-output v-time-status
                                              ).
        run cur-time in this-procedure ( output v-today, output v-time).
        run get-xcnf_create-temp-esys-pck-sent in p-cont-handle (
                                                                  input v-esys-id
                                                                ,input integer(v-pack-num-chr)
                                                                ,input v-crc-pack
                                                                ,input yes /*p-rcvd*/
                                                                ,input 1 /*p-rcvd-recs*/
                                                                ,input 1 /*p-total-recs*/
                                                                ,input v-today
                                                                ,input v-time
                                                                ,input string(v-time, "HH:MM:SS")
                                                                ) .
      end. /*if not error-status:error */
    end. /*else if status_-t.status_ = 0 then do:*/
    /*записываем в контейнер подтверждение принятия входного пакета - ОНО ЛЕЖИТ В temp-esys-pck-sent!!!! - ЭТО НЕ ПУТАНИЦА ТАК НАДО*/

    /* ------------------------- &end-rule -------------------------------------*/
    /* ------------------------- &start-release-obj& -----------------------------------*/

    /* ------------------------- &end-release-obj& -------------------------------------*/
    if v-new-st <> ? then do:
      num-rec-ok = num-rec-ok + 1.
    end.
  end. /*esle if retry*/

  run write-counter in p-log-handle ( input substitute("Прочитано записей: &1, из них удачно: &2", num-rec, num-rec-ok)).
end. /*do on error*/
&scop my-message  substitute("Прочитано записей: &1, из них удачно обработано: &2", num-rec, num-rec-ok)
{&display-message}.

end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define variable glog as logical no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_esys-pck-keys for ub.esys-pck-keys.
define buffer buf_ext-system for ub.ext-system.

  do
  on error undo, return error
  :

/*---------------------------&start-process-rule-call-param&-------------------------------*/

 find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-xsd-file"
 no-error.
if available buf_rule-call-param then do:
assign p-xsd-file = buf_rule-call-param.param-value-character.
end.



/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when {&edoc-proc_18_xml-esys-import_order_4} then do:
        assign
        v-sign = 1
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-doc-code = p-doc-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        file-name  = entry(1, p-process-file-name, {&delim-par})
        v_dataseth = handle(entry(2, p-process-file-name, {&delim-par}))
        v-xmlh = buffer buf_temp-xml-tables:handle
        v-esys-id = integer(p-doc-code)
        v-pack-num-chr = entry(3, p-process-file-name, {&delim-par})
        no-error
       .
        find first buf_ext-system no-lock where
                  buf_ext-system.esys-id = v-esys-id
              and buf_ext-system.db-num = 0 no-error .
        if not available buf_ext-system
        or buf_ext-system.esys-type <> integer({&openxml-type-exite-edi})
        then do:
          &scop my-message substitute("Не найдена ВС &1&2пропускаем ..." ~
                                        , v-esys-id ~
                                        , ~{&new-line~} ~
                                        )
          {&display-message}.
          undo, return error {&my-message}.
        end.
        /*скопируем в статическую таблицу*/
        glog = dataset status__-t:handle:copy-dataset(v_dataseth
                                           , no /*append-mode*/
                                           , yes /* replace-mode */
                                           , no /*loose-copy-mode*/
                                           , "" /*pairs-list */
                                           , no /*current-only*/
                                           ) no-error.
        if error-status:error
        or not glog then do:
          &scop my-message substitute("Ошибка копирования импортируемых данных для дальнейшей обработки&1&2" ~
                                        , ~{&new-line~} ~
                                        , error-status:get-message(1) ~
                                        )
          {&display-message}.
          undo, return error {&my-message}.
        end.
      end.
      otherwise do:
        undo, return error "Неправильный вызов".
      end.
    end case.
  end. /*doe*/

end procedure. /* load-ruleset-context */


procedure delete-procedure :

  do
  on error undo, return error
  :
      run garbcoll_clear in this-procedure .

  end.

end procedure. /* delete-procedure */

procedure delete-ord-list :
define input parameter p-doc-code as character no-undo .
define input parameter p-cli-out-doc as character no-undo .
define input parameter p-trn-doc as character no-undo .
define input parameter p-is-trn as logical no-undo .
define buffer buf_ord-list for ord-list.

find first buf_ord-list where
          buf_ord-list.doc-code = p-doc-code
      and buf_ord-list.trn-doc = p-trn-doc
         no-error .
if available buf_ord-list then delete buf_ord-list.

end procedure. /* delete-ord-list */