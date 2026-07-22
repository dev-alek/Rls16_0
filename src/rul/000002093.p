block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 18 набор правил 4



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

{ rul/seterror.i }
define buffer buf_temp-cmd for temp-cmd.
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.

define buffer buf_temp-xml-tables for temp-xml-tables.


define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .

define temp-table statusReport no-undo
field reportDateTime as character
field reportRecipient as character
field messageId as character
field messageSender as character
field messageRecepient as character
field documentType as character
field documentNumber as character
field documentDate as character
field v-date as character
field v-time as character
field stage as character
field state as character
.

DEFINE VARIABLE hDoc AS HANDLE NO-UNDO.
DEFINE VARIABLE hRoot AS HANDLE NO-UNDO.
DEFINE VARIABLE good AS LOGICAL NO-UNDO. 

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
define variable v-dm-edi as integer no-undo .


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
    find first statusReport.
    num-rec = num-rec + 1.
    v-execute = yes.
    case statusReport.documentType:
        when "ORDERS" then do:
            for each buf_edi-status no-lock where
                    buf_edi-status.tbl-name = {&table_ord-doc}
                and buf_edi-status.doc-code = statusReport.documentNumber
            by buf_edi-status.tbl-name
            by buf_edi-status.doc-code
            by buf_edi-status.date-status
            by buf_edi-status.time-status
            :
              if buf_edi-status.state = {&edi-orders} or buf_edi-status.state = {&edi-orders-deliv} then do:                            
                v-dump-ord-int64 = int64(cr-edist_get-mess-key-value(buf_edi-status.mess-id, {&edist_route})).
                leave.
              end.
            end.
            if statusReport.state = "fail" then do :
                find first buf_ord-doc no-lock where
                          buf_ord-doc.doc-code = statusReport.documentNumber no-error.
                if not available buf_ord-doc then do:
                  v-mess = substitute("Не найден заказ поставщику с номером &1", statusReport.documentNumber).
                  undo _status, retry _status.
                end.
                assign
                v-tbl-name = {&table_ord-doc}
                v-doc-code = buf_ord-doc.doc-code
                v-trn-code = ''
                v-ord-int1 = integer({&edi-crit-err})
                .    
            end.
            else do :             
                case statusReport.stage :
                    when "processing" then do :
                        v-execute = no.
                        /*доставлен на платформу EDI - надо найти пакет и создать запись во временной таблице temp-esys-pck-rcvd
                            тогда маршрутизация удалится            */
                        
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
                                                                                    ,input today /*statusReport.v-date*/
                                                                                    ,input integer(entry(1, statusReport.v-time, ":")) * 3600 +
                                                                                            integer(entry(2, statusReport.v-time, ":")) * 60
                                                                                    ,input statusReport.v-time
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
                    end. 
                    when "delivery" then do : 
                        find first buf_ord-doc no-lock where
                                  buf_ord-doc.doc-code = statusReport.documentNumber no-error.
                        if not available buf_ord-doc then do:
                          v-mess = substitute("Не найден заказ поставщику с номером &1", statusReport.documentNumber).
                          undo _status, retry _status.
                        end.
                        assign
                        v-tbl-name = {&table_ord-doc}
                        v-doc-code = buf_ord-doc.doc-code
                        v-trn-code = ''
                        v-ord-int1 = integer({&edi-orders-deliv})
                        .  
                    end.
                    when "read" then do :
                        find first buf_ord-doc no-lock where
                                  buf_ord-doc.doc-code = statusReport.documentNumber no-error.
                        if not available buf_ord-doc then do:
                          v-mess = substitute("Не найден заказ поставщику с номером &1", statusReport.documentNumber).
                          undo _status, retry _status.
                        end.
                        assign
                        v-tbl-name = {&table_ord-doc}
                        v-doc-code = buf_ord-doc.doc-code
                        v-trn-code = ''
                        v-ord-int1 = integer({&edi-orders-sts})
                        .
                    end. 
                    otherwise do :
                       v-mess = substitute("Получено непредусмотренное подтверждение. stage = &1", statusReport.stage).
                       undo _status, retry _status. 
                    end.              
                end case.    
            end.
        end. 
        when "RECADV" then do:
            for each buf_edi-status no-lock where
                    buf_edi-status.tbl-name = {&table_trn-doc}
                and buf_edi-status.doc-code = statusReport.documentNumber
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
            find first buf_trn-doc no-lock where
                       buf_trn-doc.doc-code = statusReport.documentNumber no-error.
            if not available buf_trn-doc then do:
              v-mess = substitute("Не найдена приходная накладная с номером &1, на которую пришло подтверждение", statusReport.documentNumber).
              undo _status, retry _status.
            end.
            /*надо найти заказ*/
            find first buf_ord-chain   no-lock where
                       buf_ord-chain.rel-doc-code = buf_trn-doc.doc-code
                   and buf_ord-chain.rel-doc-type = "trn"
                   and buf_ord-chain.doc-type = "rcv" no-error .
            if not available buf_ord-chain then do:
              v-mess = substitute("Не найдена цепочка поставок к заказу для накладной прихода с номером &1", statusReport.documentNumber).
              undo _status, retry _status.
            end.
            find first buf_ord-doc-rcv no-lock where
                      buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code no-error .
            if not available buf_ord-doc-rcv then do:
              v-mess = substitute("Не найдена поставка для приходной накладной с номером &1", statusReport.documentNumber).
              undo _status, retry _status.
            end.
            find first buf_ord-doc no-lock where
                      buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code no-error .
            if not available buf_ord-doc then do:
              v-mess = substitute("Не найден заказ по которому была приходная накладная с номером &1", statusReport.documentNumber).
              undo _status, retry _status.
            end.
            assign
            v-tbl-name = {&table_trn-doc}
            v-doc-code = buf_trn-doc.doc-code
            v-trn-code = entry(1, buf_ord-doc-rcv.sub-par, {&delim-par}). /*номер накладной поставщика*/
            v-ord-int1 = (if statusReport.state = "ok" then integer({&edi-recadv-sts}) else integer({&edi-crit-err}))
            .
        end.
        otherwise do:
          v-mess = substitute("Получено непредусмотренное подтверждение на документ типа &1", statusReport.documentType).
          undo _status, retry _status.
        end.
    end case .    
               
    if statusReport.stage <> "processing" then do :
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
        v-mess = substitute("Нет обмена Документами по EDI для поставщика &1&2 и &3&4 в БД &5)"
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
                                              ,input statusReport.messageId
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
        v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, {&edist_ediinterchangeid}, statusReport.messageId).
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
        find first buf_esys-route no-lock where
                  buf_esys-route.esr-dump-ord   = v-dump-ord-int64
              and buf_esys-route.esys-id   = v-esys-id
              and buf_esys-route.db-num   = 0 /*для спец систем всегда 0*/ no-error.
        if available buf_esys-route then do:                      
                                                              
                run get-xcnf_create-temp-esys-pck-rcvd in p-cont-handle (
                                                                          input v-esys-id
                                                                        ,input buf_esys-route.esr-last-pack
                                                                        ,input v-crc-pack
                                                                        ,input yes /*p-rcvd*/
                                                                        ,input 1 /*p-rcvd-recs*/
                                                                        ,input 1 /*p-total-recs*/
                                                                        ,input today /*statusReport.v-date*/
                                                                        ,input integer(entry(1, statusReport.v-time, ":")) * 3600 +
                                                                                integer(entry(2, statusReport.v-time, ":")) * 60
                                                                        ,input statusReport.v-time
                                                                        ) no-error. 
        end.                                                                                                                                 
      end. /*if not error-status:error */
    end.
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

PROCEDURE GetChildren:
DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.

DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
DEFINE VARIABLE hText AS HANDLE NO-UNDO.

CREATE X-NODEREF hNoderef.
CREATE X-NODEREF hText .

REPEAT i = 1 TO hParent:NUM-CHILDREN:
    good = hParent:GET-CHILD(hNoderef,i).
    IF NOT good THEN 
        LEAVE.
    IF hNoderef:SUBTYPE <> "element" THEN
        NEXT.
    
    hNoderef:GET-CHILD(hText, 1) .    
    
    IF hNoderef:NAME = "reportDateTime" THEN
        assign statusReport.reportDateTime = hText:node-value .       
    IF hNoderef:NAME = "reportRecipient" THEN
        assign statusReport.reportRecipient = hText:node-value .
    IF hNoderef:NAME = "messageId" THEN
        assign statusReport.messageId = hText:node-value .
    IF hNoderef:NAME = "messageSender" THEN
        assign statusReport.messageSender = hText:node-value .
    IF hNoderef:NAME = "messageRecepient" THEN
        assign statusReport.messageRecepient = hText:node-value .
    IF hNoderef:NAME = "documentType" THEN
        assign statusReport.documentType = hText:node-value .
    IF hNoderef:NAME = "documentNumber" THEN
        assign statusReport.documentNumber = hText:node-value .
    IF hNoderef:NAME = "documentDate" THEN
        assign statusReport.documentDate = (hText:node-value) .
    IF hNoderef:NAME = "dateTime" THEN
        assign
            statusReport.v-date = (substring(hText:node-value, 1, 10)) 
            statusReport.v-time = substring(hText:node-value, 12, 8)
        .
    IF hNoderef:NAME = "stage" THEN
        assign statusReport.stage = hText:node-value .
    IF hNoderef:NAME = "state" THEN
        assign statusReport.state = hText:node-value .
        
           
    RUN GetChildren(hNoderef, (level + 1)).
END.

DELETE OBJECT hNoderef.
DELETE OBJECT hText.
END PROCEDURE.

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
        v-esys-id = integer(trim(p-doc-code))
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
        
        empty temp-table statusReport .
        
        CREATE X-DOCUMENT hDoc.
        CREATE X-NODEREF hRoot.
       
        hDoc:LOAD("file",file-name,FALSE).
       
        hDoc:GET-DOCUMENT-ELEMENT(hRoot).
        
        create statusReport .
        RUN GetChildren(hRoot, 1).

        DELETE OBJECT hDoc.
        DELETE OBJECT hRoot.

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