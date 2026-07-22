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
using Ibs.Th.Rul.Route-data_.
block-level on error undo, throw.
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

define temp-table ordrsp no-undo
field id as character
field creationDateTime as character
field sender as character
field recipient as character
field documentType as character
field ordrspNumber as character
field ordrspDate as character
field status_ as character
field orderNumber as character
field orderDate as character
field seller_gln as character
field buyer_gln as character
field estimatedDeliveryDateTime as character
field shipFrom_gln as character
field shipTo_gln as character
field currencyISOCode as character
.

define temp-table lineItem no-undo
field NUMBER  as character
field status_ as character
field gtin as character
field description as character
field internalBuyerCode as character
field internalSupplierCode as character
field unitOfMeasure as character
field orderedQuantity as decimal
field confirmedQuantity as decimal
field netPrice as decimal
field netAmount as decimal
field vATAmount as decimal
field netPriceWithVAT as decimal
field amount as decimal
field vATRate as decimal
index pi is primary unique
    internalBuyerCode
.

define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .

{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }
{ rul/library-cls.i "non-class-part" }
{ gbl/key-rec.i }
{ rul/tempcxml.i "shared" }
{ gbl/gate-clb.i }
{ rul/ruleset_.i }
/*{ cus/exiteedi-ordrsp.i -t }*/
{ cus/cr-edist.i }
&undefine cr-edist_i
{ cus/cr-edist.i  tt }
{ cus/edocsord.i edi lineItem  proc-edi-reply-process-contour }
{ ref/extclass.i }
{ cus/str-edi.i }
{ bge/esysattr.i }


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
define variable num-rec-ok2 as integer no-undo .
define variable v-end-new-line     as logical no-undo .
define variable v-last-error-message as character no-undo .
define variable v-retry-action as integer no-undo .
define variable v_dataseth as handle no-undo .
define variable v-xmlh as handle no-undo .
define variable v_qh as handle no-undo .
define variable glog as logical no-undo .
define variable v-esys-id as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-pack-num-chr as character no-undo .
define variable v-ediinterchangeid as character no-undo .




{ rul/seterror.i }
define buffer buf_temp-cmd for temp-cmd.
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.

define buffer buf_temp-xml-tables for temp-xml-tables.




    

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


{ cus/send-stat_contour.i }

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
      v-esm = error-status :get-message (1).
      v-es = error-status:error .
      v-rv = return-value .
      run delete-procedure in this-procedure .
      &scop my-message substitute( "&1. &2&3&4", vss-workfile, v-rv, ~{&new-line~}, v-esm)
      {&display-message}.
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  run delete-procedure in this-procedure .
end.

procedure proc-main :
define variable v-ii as integer   no-undo .
define variable v-mess as character no-undo .
define variable v-trn-code as character no-undo .
define variable v-dump-ord-int64 as int64 no-undo .
define variable v-new-ps as character no-undo .
define variable v-ord-int1 as integer no-undo .
define variable v-ps as character no-undo .
define variable v-new-st as integer no-undo .
define variable v-ship-date as date no-undo .
define variable v-edist-mess as character no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer no-undo .
define variable v-date-status as date no-undo .
define variable v-time-status as integer no-undo .
define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_edi-status for ub.edi-status.
define buffer buf_esys-route for ub.esys-route.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-crc-pack as character no-undo .
define variable v-dm-edi as integer no-undo .

&scop full-trans   transaction
&scop single-trans



/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option -----------------------------------*/



  /* ------------------------- &start-rule& -----------------------------------*/
_ordrsp:
do transaction
on error  undo _ordrsp, retry _ordrsp
on stop   undo _ordrsp, retry _ordrsp
on endkey undo _ordrsp, retry _ordrsp
:
  if retry then do:
    &scop my-message substitute("Ошибка при импорте подтверждений заказа &1 из ВС &2&3&4" ~
                                ,v-current-doc-code ~
                                , v-esys-id  ~
                                , ~{&new-line~} ~
                                , v-mess)
    {&display-message}.
    assign
    v-view-log = yes.
    run delete-ord-list in this-procedure ( input v-cli-out-doc
                                            ).
    undo _ordrsp, return error {&my-message}.
  end.
  else do:
    find first ordrsp.
    run write-log  in p-log-handle (
                                    input 0
                                  , "&DLine").
    &scop my-message substitute(".............Импорт подтверждений заказа из ВС")
      {&display-message}.

    num-rec = num-rec + 1.
    find first buf_ord-doc exclusive-lock where
              buf_ord-doc.doc-code = ordrsp.ordernumber no-error.
    if not available buf_ord-doc then do:
      v-mess =  substitute("Не найден заказ поставщику с номером &1", ordrsp.ordernumber).
      undo _ordrsp, retry _ordrsp.
    end.
    assign
    v-current-doc-code = buf_ord-doc.doc-code
    v-cli-type = buf_ord-doc.cli-type
    v-cli-code = buf_ord-doc.cli-code
    .
    if buf_ord-doc.ord-int1 = integer({&edi-ordrsp})
    or buf_ord-doc.ord-int1 = integer({&edi-ordrsp-sts})
    then do :
/*        Заказ УЖЕ в статусе Подтвержден или ПодтвержденОК*/
        v-edist-mess = ''.
        v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, {&edist_ps}, "Заказ УЖЕ в статусе Подтвержден или ПодтвержденОК" ).
        v-date-status = ?.
        run create-edi-state in this-procedure (
                                              input {&table_ord-doc}                    /* p-tbl-name */
                                            , input buf_ord-doc.doc-code                /* p-doc-code */
                                            , input buf_ord-doc.cli-type                /* p-cli-type */
                                            , input buf_ord-doc.cli-code                /* p-cli-code */
                                            , input {&update}                           /* p-act      */
                                            , input buf_ord-doc.ord-int1                /* p-state    */
                                            , input integer({&severity-no-error})                  /* p-err      */
                                            , input v-edist-mess                      /* p-des      */
                                            , input ""                       /* p-mess     */
                                            , input integer({&doc-dm-edi})              /* p-dm */
                                            , input-output v-date-status
                                            , input-output v-time-status
                                            ).
        run send-stat_contour ( input "ORDRSP"
                               ,input "Ok"
                               ,input "Checking"
                               ,input "Сообщение отклонено на стороне получателя"
                               ,input ordrsp.id) .
        &scop my-message substitute("Ошибка при импорте подтверждений заказа &1 из ВС &2&3Заказ УЖЕ в статусе Подтвержден или ПодтвержденОК" ~
                                ,v-current-doc-code ~
                                , v-esys-id  ~
                                , ~{&new-line~})
        {&display-message}.
        assign
        v-view-log = yes.
        run delete-ord-list in this-procedure ( input v-cli-out-doc
                                                ).
        return {&my-message}.
    end.    
    /*подвтержим пакет убъем маршрутизацию*/
/*    if buf_ord-doc.ord-int2 = integer({&edi-return}) then do: /*такое бывает только если заказ от нас уходил вообще*/             */
/*      _edis:                                                                                                                      */
/*      for each buf_edi-status no-lock where                                                                                       */
/*              buf_edi-status.tbl-name = {&table_ord-doc}                                                                          */
/*          and buf_edi-status.doc-code = ordrsp.ordernumber                                                                        */
/*      by buf_edi-status.tbl-name                                                                                                  */
/*      by buf_edi-status.doc-code                                                                                                  */
/*      by buf_edi-status.date-status                                                                                               */
/*      by buf_edi-status.time-status                                                                                               */
/*      :                                                                                                                           */
/*        if buf_edi-status.state = {&edi-ordrsp-no}                                                                                */
/*        or buf_edi-status.state = {&edi-ordrsp-yes}                                                                               */
/*        then do:                                                                                                                  */
/*          v-dump-ord-int64 = int64(cr-edist_get-mess-key-value(buf_edi-status.mess-id, {&edist_route})).                          */
/*          find first buf_esys-route no-lock where                                                                                 */
/*              buf_esys-route.esr-dump-ord   = v-dump-ord-int64                                                                    */
/*          and buf_esys-route.esys-id   = v-esys-id                                                                                */
/*          and buf_esys-route.db-num   = 0 /*для спец систем всегда 0*/ no-error.                                                  */
/*          if available buf_esys-route then do:                                                                                    */
/*            /*заменим номер рута на номер пакета*/                                                                                */
/*            v-edist-mess = ''.                                                                                                    */
/*            v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, {&edist_pack-num}, string(buf_esys-route.esr-last-pack) + "->").*/
/*                                                                                                                                  */
/*            run update-edi-state-light in this-procedure ( input buf_edi-status.tbl-name                                          */
/*                                                          ,input buf_edi-status.doc-code                                          */
/*                                                          ,input buf_edi-status.date-status                                       */
/*                                                          ,input buf_edi-status.time-status                                       */
/*                                                          ,input buf_edi-status.state                                             */
/*                                                          ,input buf_edi-status.err-code                                          */
/*                                                          ,input buf_edi-status.des-err                                           */
/*                                                          ,input v-edist-mess                                                     */
/*                                                          )                                                                       */
/*                                                          .                                                                       */
/*            DEFINE VARIABLE v-today as date no-undo .                                                                             */
/*            DEFINE VARIABLE v-time as integer no-undo .                                                                           */
/*            run cur-time in this-procedure ( output v-today, output v-time).                                                      */
/*            run get-xcnf_create-temp-esys-pck-rcvd in p-cont-handle (                                                             */
/*                                                                      input v-esys-id                                             */
/*                                                                    ,input buf_esys-route.esr-last-pack                           */
/*                                                                    ,input v-crc-pack                                             */
/*                                                                    ,input yes /*p-rcvd*/                                         */
/*                                                                    ,input 1 /*p-rcvd-recs*/                                      */
/*                                                                    ,input 1 /*p-total-recs*/                                     */
/*                                                                    ,input v-today                                                */
/*                                                                    ,input v-time                                                 */
/*                                                                    ,input string(v-time, "HH:MM:SS")                             */
/*                                                                    ) .                                                           */
/*            leave _edis.                                                                                                          */
/*          end.                                                                                                                    */
/*        end.                                                                                                                      */
/*      end. /*      for each buf_edi-status no-lock where*/                                                                        */
/*    end. /*if buf_ord-doc.ord-int2 = integer({&edi-return}) then do:*/                                                            */
    
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
      undo _ordrsp, retry _ordrsp.
    end.
    /*TODO проверить что не изменились те поля шапки которые мы отсылали  -иначе retry*/
    assign
    v-ps = ""
    v-ord-int1 = (if ordrsp.status_ = "Accepted"
                          then integer({&edi-ordrsp})   /* Даже если Accepted, всё равно нужно делать проверки, поэтому не {&edi-ordrsp-sts} */
                          else (if ordrsp.status_ = "Rejected"
                                then integer({&edi-err})
                                else integer({&edi-ordrsp})
                                )
                          ) /*такой будет новый статус*/
    v-cli-out-doc = ordrsp.ordrspNumber + {&delim-par} + ordrsp.ordrspDate
    v-ship-date = (if ordrsp.estimatedDeliveryDateTime = ? or ordrsp.estimatedDeliveryDateTime = ""
                          then ord-list.ship-date
                          else date(substring(ordrsp.estimatedDeliveryDateTime, 9, 2) + "/" + substring(ordrsp.estimatedDeliveryDateTime, 6, 2) + "/" + substring(ordrsp.estimatedDeliveryDateTime, 1, 4))
                          )
    .
    &scop order-stts-int1 string(ord-list.ord-int1)
    
    v-ediinterchangeid = ordrsp.id.
    run edocsord_edi-import in this-procedure (
                                            buffer buf_ord-doc
                                          ,input v-cli-out-doc
                                          ,input '' /*p-trn-doc*/
                                          ,input v-ord-int1
                                          ,input v-ship-date
                                          ,input v-ps
                                          ,input v-pack-num-chr
                                          ,input v-ediinterchangeid
                                          ,output v-new-ps
                                          ,output v-new-st
                                          ) no-error.
    if error-status:error then do:
      if return-value <> '' then do:
        v-mess = substitute("Ошибка при изменении статуса заказа при приеме данных:&1&2", {&new-line}, return-value ).
        undo _ordrsp, retry _ordrsp.
      end.
    end.
    else do:
      if v-new-st = ? then do:
        /*пошлем письмо
        сделаем временный файл и запишем туда cr-edist_full-mess
        */
        define variable v-tmp-file as character no-undo .
        run gbl/_tmpfile.p ( input "mes":U  , input ".txt":U, output v-tmp-file ).
        COPY-LOB  FROM OBJECT cr-edist_full-mess
        TO FILE v-tmp-file NO-ERROR.
        cr-edist_full-mess = ''.
        run send-msg-to-email in parparentproc
            ( input substitute( "ТН БД &1. Ошибка EDI при импорте пакета &2 из ВС &3"
                                , g#db-num
                                , v-pack-num-chr
                                , v-esys-id )
            ,input substitute("Пакет принят без сохранения данных в БД. См. EDI-информацию по заказу &1&2"
                              , buf_ord-doc.doc-code
                              , {&new-line}
                              )
            ,input v-tmp-file
            ) no-error .
        os-delete value(v-tmp-file).
      end.
      

      v-edist-mess = ''.
      v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, {&edist_pack-num}, "->" + v-pack-num-chr ).
      v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, {&edist_ediinterchangeid}, ordrsp.id ).
      v-date-status = ?.
      run create-edi-state in this-procedure (
                                              input {&table_ord-doc}                    /* p-tbl-name */
                                            , input buf_ord-doc.doc-code                /* p-doc-code */
                                            , input buf_ord-doc.cli-type                /* p-cli-type */
                                            , input buf_ord-doc.cli-code                /* p-cli-code */
                                            , input {&update}                           /* p-act      */
                                            , input (if v-new-st = ? then -1 else buf_ord-doc.ord-int1)                /* p-state    */
                                            , input (if v-new-st = ?
                                                    then  integer({&severity-extreme})
                                                    else integer({&severity-no-error}))                  /* p-err      */
                                            , input buf_ord-doc.PS                      /* p-des      */
                                            , input v-edist-mess                        /* p-mess     */
                                            , input integer({&doc-dm-edi})              /* p-dm */
                                            , input-output v-date-status
                                            , input-output v-time-status
                                            ).
      _edist:
      for each temp-edi-status
      on error  undo _edist, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo _edist, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _edist, return error substitute( "&1. endkey", vss-workfile )
      :
        v-edist-mess = temp-edi-status.mess.
        v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, {&edist_pack-num}, "->" + v-pack-num-chr ).
        run create-edi-state in this-procedure (
                                                input temp-edi-status.tbl-name            /* p-tbl-name */
                                              , input temp-edi-status.doc-code           /* p-doc-code */
                                              , input temp-edi-status.cli-type            /* p-cli-type */
                                              , input temp-edi-status.cli-code            /* p-cli-code */
                                              , input temp-edi-status.act                  /* p-act      */
                                              , input (if v-new-st = ? then -1 else buf_ord-doc.ord-int1)     /* p-state    */
                                              , input temp-edi-status.err-code            /* p-err      */
                                              , input temp-edi-status.des-err              /* p-des      */
                                              , input v-edist-mess                        /* p-mess     */
                                              , input integer({&doc-dm-edi})              /* p-dm */
                                              , input-output v-date-status
                                              , input-output v-time-status
                                              ).
      end.
      if v-new-st <> ? then do:
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
        num-rec-ok = num-rec-ok + 1.
      end.
    end.
    /* ------------------------- &end-rule -------------------------------------*/
  end. /*esle if retry*/
  run write-counter in p-log-handle ( input substitute("Прочитано записей: &1, из них удачно: &2", num-rec, num-rec-ok)).
end. /*for each status-t*/
&scop my-message substitute("Прочитано записей: &1, из них удачно обработано: &2", num-rec, num-rec-ok)
{&display-message}.


end procedure. /* proc-main */


PROCEDURE GetChildren:
DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.

DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
DEFINE VARIABLE hText AS HANDLE NO-UNDO.
define variable client as character no-undo.

CREATE X-NODEREF hNoderef.
CREATE X-NODEREF hText .

if hParent:name = "eDIMessage" then
assign
    ordrsp.id = hParent:get-attribute("id")
    ordrsp.creationDateTime = hParent:get-attribute("creationDateTime")     
.    

REPEAT i = 1 TO hParent:NUM-CHILDREN:
    good = hParent:GET-CHILD(hNoderef,i).
    IF NOT good THEN 
        LEAVE.
    IF hNoderef:SUBTYPE <> "element" THEN
        NEXT.
    
    hNoderef:GET-CHILD(hText, 1) no-error.    
    
    IF hNoderef:NAME = "sender" THEN
        assign ordrsp.sender = hText:node-value .       
    IF hNoderef:NAME = "recipient" THEN
        assign ordrsp.recipient = hText:node-value .
    IF hNoderef:NAME = "orderResponse" THEN
        assign 
            ordrsp.ordrspNumber = hNoderef:get-attribute("number")
            ordrsp.ordrspDate = hNoderef:get-attribute("date")
            ordrsp.status_ = hNoderef:get-attribute("status")
        .
    IF hNoderef:NAME = "originOrder" THEN
        assign 
            ordrsp.orderNumber = hNoderef:get-attribute("number")
            ordrsp.orderDate = hNoderef:get-attribute("date")
        .
    IF hNoderef:NAME = "documentType" THEN
        assign ordrsp.documentType = hText:node-value .
    IF hNoderef:NAME = "seller" THEN
        assign client = "seller".
    IF hNoderef:NAME = "buyer" THEN
        assign client = "buyer". 
    IF hNoderef:NAME = "shipFrom" THEN
        assign client = "shipFrom". 
    IF hNoderef:NAME = "shipTo" THEN
        assign client = "shipTo". 
    IF hNoderef:NAME = "gln" THEN do :
        case client :
            when "seller" then assign ordrsp.seller_gln = hText:node-value .
            when "buyer" then assign ordrsp.buyer_gln = hText:node-value .
            when "shipFrom" then assign ordrsp.shipFrom_gln = hText:node-value .
            when "shipTo" then assign ordrsp.shipTo_gln = hText:node-value .
        end case.    
    end.
    IF hNoderef:NAME = "estimatedDeliveryDateTime" THEN 
        assign ordrsp.estimatedDeliveryDateTime = hText:node-value .
    IF hNoderef:NAME = "currencyISOCode" THEN 
        assign ordrsp.currencyISOCode = hText:node-value .    
    IF hNoderef:NAME = "lineItem" THEN do :                          
        create lineItem .
        assign
            lineItem.status_ = hNoderef:get-attribute("status")
            lineItem.NUMBER  = ordrsp.ordrspNumber
        . 
    end.
    IF hNoderef:NAME = "gtin" THEN 
        assign lineItem.gtin = hText:node-value .
    IF hNoderef:NAME = "description" THEN 
        assign lineItem.description = hText:node-value .    
    IF hNoderef:NAME = "internalBuyerCode" THEN 
        assign lineItem.internalBuyerCode = hText:node-value . 
    IF hNoderef:NAME = "internalSupplierCode" THEN 
        assign lineItem.internalSupplierCode = hText:node-value .
    IF hNoderef:NAME = "orderedQuantity" THEN 
        assign lineItem.orderedQuantity = decimal(hText:node-value) .
    IF hNoderef:NAME = "confirmedQuantity" THEN 
        assign
            lineItem.confirmedQuantity = decimal(hText:node-value)
            lineItem.unitOfMeasure = hNoderef:get-attribute("unitOfMeasure")
        .                   
    IF hNoderef:NAME = "netPrice" THEN 
        assign lineItem.netPrice = decimal(hText:node-value) .
    IF hNoderef:NAME = "netAmount" THEN 
        assign lineItem.netAmount = decimal(hText:node-value) .
    IF hNoderef:NAME = "vATAmount" THEN 
        assign lineItem.vATAmount = decimal(hText:node-value) .
    IF hNoderef:NAME = "netPriceWithVAT" THEN 
        assign lineItem.netPriceWithVAT = decimal(hText:node-value) .
    IF hNoderef:NAME = "amount" THEN 
        assign lineItem.amount = decimal(hText:node-value) .
    IF hNoderef:NAME = "vATRate" THEN 
        assign lineItem.vATRate = decimal(hText:node-value) .
           
    RUN GetChildren(hNoderef, (level + 1)).
END.

DELETE OBJECT hNoderef.
DELETE OBJECT hText.
END PROCEDURE.

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define variable glog as logical no-undo .
define variable v-mess as character no-undo .
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
        
        empty temp-table ordrsp .
        empty temp-table lineItem .
        
        CREATE X-DOCUMENT hDoc.
        CREATE X-NODEREF hRoot.
       
        hDoc:LOAD("file",file-name,FALSE).
       
        hDoc:GET-DOCUMENT-ELEMENT(hRoot).
        
        create ordrsp .
        RUN GetChildren(hRoot, 1).

        DELETE OBJECT hDoc.
        DELETE OBJECT hRoot.
        
        find first ub.ord-doc no-lock where ub.ord-doc.doc-code = ordrsp.orderNumber no-error.
        
        if not available ub.ord-doc then do:
          v-mess =  substitute("Не найден заказ поставщику с номером &1", ordrsp.ordernumber).          
          &scop my-message substitute("Ошибка при импорте поставок по  заказу &1 из ВС &2&3&4" ~
                                ,ordrsp.ordernumber ~
                                , v-esys-id  ~
                                , ~{&new-line~} ~
                                , v-mess)

          {&display-message}.
        end.
        
        if available ub.ord-doc then
        assign
        v-current-doc-code = ub.ord-doc.doc-code
        v-current-obj-type = ub.ord-doc.obj-type
        v-current-obj-code = ub.ord-doc.obj-code
        v-cli-out-doc = ordrsp.ordrspNumber + {&delim-par} + ordrsp.ordrspDate
        .
        
        
        run send-stat_contour ( input "ORDRSP"
                               ,input "Ok"
                               ,input "Read"
                               ,input "сообщение доставлено"
                               ,input ordrsp.id) .
        
/*        /*скопируем в статическую таблицу*/                                                                   */
/*        glog = dataset ordrsp_-t:handle:copy-dataset(v_dataseth                                               */
/*                                           , no /*append-mode*/                                               */
/*                                           , yes /* replace-mode */                                           */
/*                                           , no /*loose-copy-mode*/                                           */
/*                                           , "" /*pairs-list */                                               */
/*                                           , no /*current-only*/                                              */
/*                                           ) no-error.                                                        */
/*        if error-status:error                                                                                 */
/*        or not glog then do:                                                                                  */
/*          &scop my-message substitute("Ошибка копирования импортируемых данных для дальнейшей обработки&1&2" ~*/
/*                                        , ~{&new-line~} ~                                                     */
/*                                        , error-status:get-message(1) ~                                       */
/*                                        )                                                                     */
/*          {&display-message}.                                                                                 */
/*          undo, return error {&my-message}.                                                                   */
/*        end.                                                                                                  */
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
define input parameter p-cli-out-doc as character no-undo .
define buffer buf_ord-list for ord-list.

for each lineItem where
        lineItem.number = p-cli-out-doc:
  delete lineItem.
end.

find first buf_ord-list where
          buf_ord-list.doc-code = p-doc-code
      and buf_ord-list.trn-doc = ''
         no-error .
if available buf_ord-list then delete buf_ord-list.

end procedure. /* delete-ord-list */