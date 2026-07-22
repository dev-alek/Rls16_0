/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 18


---------------------------&start-codex_id=18;ruleset_id=2;-------------------------------
Операции над списком заказов
Маршрутизация во ВС
---------------------------&end-codex_id=18;ruleset_id=2;-------------------------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18, набор 115".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code
{ gbl/gate-clb.i }
{ gbl/key-rec.i }
{ bge/esysattr.i }
{ bge/tmpcxmlh.i }
{ gbl/lib-gate.i }
{ rul/ruleset_.i }
{ cus/edocsord.i edi }
{ cus/str-edi.i }
{ cus/ordlnatt.i }
{ str/statq.i }
{ cus/cr-edist.i }
{ str/trdcalib.i }

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-doc-code as character no-undo .
define variable v-newbh as handle no-undo .
define variable v-oldbh as handle no-undo .
define variable v-has-newbh as logical no-undo .
define variable v-has-oldbh as logical no-undo .
define variable v-doc-date as date no-undo .
define variable v-fact-date as date no-undo .
define variable v-ps as character no-undo .
define variable v-changes-list as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-current-db-num as integer no-undo .
define variable v-last-error-message as character no-undo .
/*****************************/
define variable file-name as char.
define variable v-sign as integer no-undo .
define variable v-gate-rec as character no-undo .
define variable v-type as character no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.

define temp-table lineItem no-undo
field gtin as character
field internalBuyerCode as character
field internalSupplierCode as character
index pi is unique primary internalBuyerCode
.

{ str/dia2auto.i }
{ rul/seterror.i }

&scop display-message ~
          if valid-handle(p-log-handle) then ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)




/*---------------------------&start-rule-call-param&-------------------------------*/

  define variable p-xsd-file as character no-undo.

/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/

 { rul/context_f.i  begin-esys-command }
 { rul/context_f.i  send-esys-command-ext }
 { rul/context_f.i  set-custom-esys-pck-name }
 { rul/context_f.i  delete-command }



/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.

run load-ruleset-context in this-procedure ( input p-ruleset-id) no-error.
if error-status:error then do:
  undo, return error return-value .
end.
if return-value = "return" then return ''.

/* ------------------------- &start-def-vars& -----------------------------------*/

define variable ExpData1 as class Route-data_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle)
ExpData1 = new Route-data_{&constructor_1} .

define variable v-DATA as memptr no-undo.

/* ------------------------- &end-def-vars& -----------------------------------*/

if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
    v-esm = error-status :get-message (1).
    v-es = error-status:error .
    v-rv = return-value .
  end.
  if v-es then do:
      run garbcoll_clear in this-procedure .
      &scop my-message substitute( "&1. &2&3&4", vss-workfile, return-value, ~{&new-line~}, error-status :get-message (1))
      {&display-message}.
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, {&new-line}, v-esm).
  end.
  run garbcoll_clear in this-procedure .
end.

procedure proc-main :
define variable v-ii as integer no-undo .
define variable v-uniq-key-rec as character no-undo .
define variable v-cli-uniq-key-rec as character no-undo .
define variable v-err as logical no-undo .
define variable v-custom-pack-name as character no-undo .
define variable v-success as logical   no-undo .
DEFINE VARIABLE v-date as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-ord-int1 as integer no-undo .
define variable v-obj-gln as character no-undo .
define variable v-cli-gln as character no-undo .
define variable v-frm-gln as character no-undo .
define variable v-transport-gln as character no-undo .
define variable v-mess as character no-undo .
define variable v-b-code as integer no-undo .
define variable v-b-str as character no-undo .
define variable l-prod-bc-weight as logical no-undo .
define variable l-prod-bc-pgweight as logical no-undo .
define variable l-is-petrol-code as logical no-undo .
define variable l-is-scaleable as logical no-undo .
define variable v-jj as integer   no-undo .
define variable v-cli-base-rate as decimal no-undo .
define variable v-dump-ord-int64 as int64 no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer   no-undo .
define variable v-EDIINTERCHANGEID as character no-undo .
define variable v-edist-mess as character no-undo .
define variable v-deliverynotenumber as character no-undo .
define variable v-deliverynotedate as date no-undo .
define variable v-deliverynotedate-chr as character no-undo .
define variable v-attr-type as character no-undo .
define variable v-date-status as date no-undo .
define variable v-time-status as integer no-undo .
define variable v-date-chr as character no-undo .
define variable sw as handle no-undo .
define variable swa as handle no-undo .
  
define buffer buf_ext-system for ub.ext-system.
define buffer buf_ord-line for ub.ord-line.
define buffer buf_object for ub.clients.
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
define buffer esys_ext-classif for ub.ext-classif.
define buffer buf_goods for ub.goods.
define buffer buf_currency for ub.currency.
define buffer buf_doc-line for ub.doc-line.

/* ------------------------- &end-hn-option& -----------------------------------*/

_main:
do
on error undo _main, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:


 if retry then do:
    &scop my-message substitute("Ошибка при обработке накладной &1&2:&3&4" ~
                                   ,v-current-doc-code ~
                                   , ~{&new-line~}, v-mess)
    {&display-message}.
    undo _main, return error.
  end.
  else do:
    if v-has-newbh then do:
      v-current-obj-type = v-newbh::obj-type.
      v-current-obj-code = v-newbh::obj-code.
      v-cli-type = v-newbh::cli-type.
      v-cli-code = v-newbh::cli-code.
      v-current-host-code = v-newbh::host-code.
    end.
    assign
    v-mess = ''
    .
    /* ------------------------- &start-rule& -----------------------------------*/

    find first buf_clients no-lock where
              buf_clients.obj-type = v-cli-type
          and buf_clients.obj-code = v-cli-code no-error.
    if not available buf_clients then do:
      v-mess =  substitute("Не найден контрагент &1&2", v-cli-type, v-cli-code).
      v-err = yes.
      undo _main, retry _main.
    end.

    if buf_ord-doc.doc-type = {&O-P}
    and (buf_ord-doc.status_  = {&fact} or buf_ord-doc.status_ = {&ord-rcv})
    and (buf_ord-doc.ord-int1 = integer({&edi-desadv})
    or buf_ord-doc.ord-int1 = integer({&edi-desadv-sts})
    or buf_ord-doc.ord-int1 = integer({&edi-recadv})
    or buf_ord-doc.ord-int1 = integer({&edi-recadv-sts})
    )
    and buf_ord-doc.whole-send-news = integer({&doc-dm-edi})
    then do:
      assign
      v-ord-int1 = integer({&edi-recadv}).
    end.
    else do:
      return "проверка заказа не пройдена!".
    end.
    run gen-key-rec in this-procedure ( input {&table_clients}
                                      ,input (buffer buf_clients:handle)
                                      ,output v-cli-uniq-key-rec) no-error .
    if error-status:error then do:
      v-mess = substitute("gen-key-rec: &1&2&3&2(&4&5)"
                                , error-status:get-message(1)
                                , return-value
                                , {&new-line}
                                , v-cli-type
                                , v-cli-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    find first esys_ext-classif no-lock where
        esys_ext-classif.classif-name = {&extclass_clients_exite-edi}
    and esys_ext-classif.classif-subject = {&table_clients}
    and esys_ext-classif.db-num = -1
    and esys_Ext-classif.uniq-key-rec = v-cli-uniq-key-rec no-error .
    if not available esys_ext-classif then do:
      v-mess = substitute("Поставщик &1&2 заказа НЕ РАБОТАЕТ ПО СИСТЕМЕ EDI", v-cli-type, v-cli-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    find first buf_object no-lock where
              buf_object.obj-type = v-current-obj-type
          and buf_object.obj-code = v-current-obj-code no-error.
    if not available buf_object then do:
      v-mess =  substitute("Не найден объект &1&2", v-current-obj-type, v-current-obj-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    if buf_object.db-num <> g#db-num then do:
      v-mess = substitute("Объект &1&2 принадлежит другой БД", v-current-obj-type, v-current-obj-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    run gen-key-rec in this-procedure ( input {&table_clients}
                                      ,input (buffer buf_object:handle)
                                      ,output v-uniq-key-rec) no-error .
    if error-status:error then do:
      v-mess =  substitute("gen-key-rec: &1&2&3&2(&4&5)"
                                , error-status:get-message(1)
                                , return-value
                                , {&new-line}
                                , buf_object.obj-type
                                , buf_object.obj-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    assign
    v-obj-gln = get-gln( input buf_object.obj-type
                    ,input buf_object.obj-code) no-error.
    if error-status:error
    or v-obj-gln = {&question-mark}
    or v-obj-gln = '' then do:
      v-mess =  substitute("Не определен GLN для &1&2"
                                , buf_object.obj-type
                                , buf_object.obj-code) .
      v-err = yes.
      undo _main, retry _main.
    end.
    v-cli-gln = get-gln( input v-cli-type
                        ,input v-cli-code) no-error.
    if error-status:error
    or v-cli-gln = {&question-mark}
    or v-cli-gln = '' then do:
      v-mess =  substitute("Не определен GLN для &1&2"
                                , buf_object.obj-type
                                , buf_object.obj-code) .
      v-err = yes.
      undo _main, retry _main.
    end.
    assign
    v-frm-gln = get-gln( input {&cmp}
                        ,input v-current-host-code) no-error.
    if error-status:error
    or v-frm-gln = {&question-mark}
    or v-frm-gln = '' then do:
      v-mess =  substitute("Не определен GLN для &1&2"
                                , {&cmp}
                                , v-current-host-code) .
      v-err = yes.
      undo _main, retry _main.
    end.

    assign
    v-transport-gln = get-gln( input buf_ord-doc-rcv.transport-cli-type
                              ,input buf_ord-doc-rcv.transport-cli-code) no-error.
    /*ошибку игнорируем - может не быть его там*/


      /*найдем првязку к EDI*/
    for each esys_ext-classif no-lock where
        esys_ext-classif.classif-name = {&extclass_clients_exite-edi}
    and esys_ext-classif.classif-subject = {&table_clients}
    and esys_ext-classif.db-num = -1
    and esys_Ext-classif.uniq-key-rec = v-cli-uniq-key-rec,
      first buf_ext-system no-lock where
                buf_ext-system.esys-id = esys_ext-classif.key#_one
            and buf_ext-system.db-num = 0
/*            and buf_ext-system.esys-db-num-exp = g#db-num*/
            and buf_ext-system.esys-have-export = yes,
      first buf_ext-classif no-lock where
        buf_ext-classif.classif-name = {&extclass_clients_exite-edi}
    and buf_ext-classif.classif-subject = {&table_clients}
    and buf_ext-classif.db-num = -1
    and buf_Ext-classif.uniq-key-rec = v-uniq-key-rec
    and buf_Ext-classif.key#_one = esys_ext-classif.key#_one:
      leave.
    end.
    if not available buf_ext-system then do:
      v-mess = substitute("Для поставщика &1&2 не найдена ВС, у которой есть экспорт в текущей БД").
      v-err = yes.
      undo _main, retry _main.
    end.

    IF  context_begin-esys-command( input string(buf_ext-system.esys-id), input-output v-esys-cmd-proc-handle, output v-esys-cmd-code) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    /*создадим имя custom имя файла*/
    v-custom-pack-name = "RECADV_&pack-num.xml". /*действительно надо RECADV*/

    /*найдем дату и номер прих накладной поставщика из атрибутов документа trn-doc*/
    { str/tdat-val.i
    v-current-doc-code
    {&trdcattr-nids}
    v-DELIVERYNOTENUMBER
    v-attr-type
    no-error
    }

    { str/tdat-val.i
    v-current-doc-code
    {&trdcattr-dids}
    v-DELIVERYNOTEDATE-chr
    v-attr-type
    no-error
    }
    if not error-status:error then do:
      v-DELIVERYNOTEDATE = date(v-DELIVERYNOTEDATE-chr).
    end.
    if num-entries(buf_ord-doc.cli-out-doc, {&delim-par}) > 1 then do:
      assign
      v-date-chr = entry(2, buf_ord-doc.cli-out-doc, {&delim-par})
      v-date = date (integer(entry(2, v-date-chr, "-"))
                     ,integer(entry(3, v-date-chr, "-"))
                     ,integer(entry(1, v-date-chr, "-"))
                     ) no-error.
      if error-status:error then do:
        run cur-time in this-procedure ( output v-date, output v-time).
      end.
    end.
    else do:
      run cur-time in this-procedure ( output v-date, output v-time).
    end.
    
    
    create sax-writer sw .
    create sax-attributes swa .
    swa:insert-attribute ("unitOfMeasure", "") .
    sw:formatted = true.
    sw:set-output-destination ("memptr", v-DATA).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("eDIMessage") .
    sw:insert-attribute ("id", (v-current-doc-code + "_" + string(TODAY) + string(TIME))) .
        sw:start-element ("interchangeHeader") .
            sw:write-data-element ("sender", v-frm-gln) .
            sw:write-data-element ("recipient", v-cli-gln) .
            sw:write-data-element ("documentType", "RECADV") .
/*            sw:write-data-element ("isTest", "1") .*/
            sw:write-data-element ("creationDateTime", substring(iso-date(NOW), 1, 23) + "Z")  .
        sw:end-element ("interchangeHeader") .
        sw:start-element ("receivingAdvice") .
        sw:insert-attribute ("number", v-current-doc-code) .
        sw:insert-attribute ("date", iso-date(v-fact-date)) .
            sw:write-empty-element ("originOrder") .
            sw:insert-attribute ("number", string(buf_ord-doc.doc-code)) .
            sw:insert-attribute ("date", iso-date(buf_ord-doc.doc-date)) .
            sw:write-empty-element ("despatchIdentificator") .
            sw:insert-attribute ("number", entry(1, buf_ord-doc-rcv.sub-par, {&delim-par})) .
            sw:insert-attribute ("date", iso-date(buf_ord-doc-rcv.doc-date)) .
            sw:start-element ("seller") .
                sw:write-data-element ("gln", v-cli-gln) .
                find first ub.firm no-lock where ub.firm.firm-code = buf_clients.obj-code no-error .
                sw:start-element ("organization") .
                    sw:write-data-element ("name", buf_clients.obj-name) .
                    sw:write-data-element ("inn", ub.firm.inn) .
                    sw:write-data-element ("kpp", ub.firm.kpp) .
                sw:end-element ("organization") .
            sw:end-element ("seller") .
            sw:start-element ("buyer") .
                sw:write-data-element ("gln", v-frm-gln) .
                find first ub.firm no-lock where ub.firm.firm-code = buf_object.host-code no-error .
                sw:start-element ("organization") .
                    sw:write-data-element ("name", buf_object.obj-name) .
                    sw:write-data-element ("inn", ub.firm.inn) .
                    sw:write-data-element ("kpp", ub.firm.kpp) .
                sw:end-element ("organization") .
            sw:end-element ("buyer") .
            sw:start-element ("deliveryInfo") .
                sw:write-data-element ("receptionDateTime", (iso-date(v-fact-date) + "T00:00:00.000Z")) .
                sw:start-element ("shipFrom") .
                    sw:write-data-element ("gln", v-transport-gln) .
/*                    find first ub.firm no-lock where ub.firm.firm-code = buf_clients.obj-code no-error .*/
/*                    sw:start-element ("organization") .                                                 */
/*                        sw:write-data-element ("name", buf_clients.obj-name) .                          */
/*                        sw:write-data-element ("inn", ub.firm.inn) .                                    */
/*                        sw:write-data-element ("kpp", ub.firm.kpp) .                                    */
/*                    sw:end-element ("organization") .                                                   */
                sw:end-element ("shipFrom") .
                sw:start-element ("shipTo") .
                    sw:write-data-element ("gln", v-obj-gln) .
                    find first ub.firm no-lock where ub.firm.firm-code = buf_object.host-code no-error .
                    sw:start-element ("organization") .
                        sw:write-data-element ("name", buf_object.obj-name) .
                        sw:write-data-element ("inn", ub.firm.inn) .
                        sw:write-data-element ("kpp", ub.firm.kpp) .
                    sw:end-element ("organization") .
                sw:end-element ("shipTo") .
            sw:end-element ("deliveryInfo") .
            sw:start-element ("lineItems") .
    
   

    /* по строкам накладной и заказа заполнение position-t*/
    for each buf_doc-line no-lock where
              buf_doc-line.doc-code = v-current-doc-code
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
      find first buf_ord-line no-lock where
                buf_ord-line.doc-code = buf_ord-doc.doc-code
            and buf_ord-line.artic     = buf_doc-line.artic
            and buf_ord-line.prod-type = buf_doc-line.prod-type
            and buf_ord-line.prod-code = buf_doc-line.prod-code no-error.
      if not available buf_ord-line then do:
        undo _main, return error substitute("Не найден строка заказа с товаром &1 &273"
                                            , buf_doc-line.artic
                                            , buf_doc-line.prod-type
                                            , buf_doc-line.prod-code
                                            ).
      end.
      find first buf_goods no-lock where
                buf_goods.gds-code = buf_ord-line.gds-code no-error.
      if not available buf_goods then do:
        undo _main, return error substitute("Не найден товар с кодом &1", buf_ord-line.gds-code).
      end.
      find first lineItem where lineItem.internalSupplierCode = buf_ord-line.cli-art no-error .
      if available lineItem then do:
        v-mess =  substitute("В заказе две строки с одинаковым артикулом поставщика &1"
                                    , v-current-doc-code
                                    , buf_ord-line.cli-art
                                    ).
        IF  context_delete-command( input v-esys-cmd-proc-handle, input v-esys-cmd-code) = false  THEN do:
          undo _main, return error v-last-error-message .
        end.
      end. /*if available order-line then do:*/
      else do:
        RUN ordlineattr-value  IN THIS-PROCEDURE ( input  buf_ord-line.doc-code
                                                  ,input  buf_ord-line.gds-code
                                                  ,input  {&attr-order-ean13}
                                                  ,output v-b-str
                                                  ,output v-type
                                                  ) NO-ERROR.
                                                  
                                                  
                sw:start-element ("lineItem") .
                    sw:write-data-element ("gtin", v-b-str) .
                    sw:write-data-element ("internalBuyerCode", string(buf_ord-line.gds-code)) .
                    sw:write-data-element ("internalSupplierCode", buf_ord-line.cli-art) .
                    sw:write-data-element ("lineNumber", string(buf_ord-line.line-num)) .
                    sw:write-data-element ("description", buf_goods.gds-name) .
                    find first ub.units no-lock where ub.units.unit-name = buf_goods.unit-base.
                    if  buf_doc-line.fact-qnty > buf_doc-line.cli-qnty then do :
                        swa:update-attribute ("unitOfMeasure", "PA") .
                    end.
                    else do :    
                        swa:update-attribute ("unitOfMeasure", (if ub.units.type = {&pieces} then "PCE" else "KGM")) .  
                    end.                    
                    sw:write-data-element ("despatchedQuantity", trim(string((buf_doc-line.doc-qnty  / buf_ord-line.cli-base-rate), "->>>>>>>>9.999")), "", swa) .
                    sw:write-data-element ("acceptedQuantity", trim(string((buf_doc-line.fact-qnty / buf_ord-line.cli-base-rate), "->>>>>>>>9.999")), "", swa) .
                    if  buf_doc-line.fact-qnty <> buf_doc-line.cli-qnty then do :
                        swa:update-attribute ("unitOfMeasure", (if ub.units.type = {&pieces} then "PCE" else "KGM")) .
                        sw:write-data-element ("onePlaceQuantity", trim(string((buf_doc-line.fact-qnty / buf_doc-line.cli-qnty), "->>>>>>>>9.999")), "", swa) .    
                    end.    
                    sw:write-data-element ("netPriceWithVAT", trim(string(buf_doc-line.price-cli, "->>>>>>>>9.9999"))) .
                    sw:write-data-element ("vATRate", trim(string(integer(buf_doc-line.vat-pc)))) .
                    sw:write-data-element ("amount", trim(string((buf_doc-line.fact-qnty * buf_doc-line.price-cli / buf_ord-line.cli-base-rate), "->>>>>>>>9.9999"))) .
                sw:end-element ("lineItem") .    
          
/*          assign                                     */
/*            v-totalSumExlTaxes = v-totalSumExlTaxes +*/
/*            v-totalVATAmount   = v-totalVATAmount +  */
/*            v-totalAmount      = totalAmount +       */
/*          .                                          */
          
          create lineItem .
          assign
            lineItem.gtin               = v-b-str
            lineItem.internalBuyerCode  = string(buf_ord-line.gds-code)
            lineItem.internalSupplierCode = buf_ord-line.cli-art
          .
                                                  

        
      end. /*else if available order-line then do:*/
    end. /*      for each buf_ord-line no-lock where*/
    empty temp-table lineItem.
    
                sw:end-element ("lineItems") .
            sw:end-element ("receivingAdvice") .
        sw:end-element ("eDIMessage") .
        sw:end-document () .
        delete object sw.
        delete object swa. 
    
    IF ExpData1:esys-add-dump-data ( INPUT v-DATA, INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        undo _main, return error v-last-error-message .
    end.

    run edocsord_export in this-procedure ( buffer buf_ord-doc
                                        ,input entry(1, buf_ord-doc-rcv.sub-par, {&delim-par})
                                        ,input {&edi-recadv}
                                        ) no-error.
    if error-status:error then do:
      v-mess = substitute("Ошибка при переводе статуса маршрутизированного заказа:&1&2&1&3"
                          , {&new-line}
                          , error-status:get-message(1)
                          , return-value ).
      undo _main, retry _main.
    end.
    IF  context_set-custom-esys-pck-name(  input v-esys-cmd-proc-handle, input v-esys-cmd-code, input v-custom-pack-name) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    v-dump-ord-int64 = context_send-esys-command( input string(buf_ext-system.esys-id), input v-esys-cmd-proc-handle, input v-esys-cmd-code, input g#userid).
    if v-dump-ord-int64 = 0 THEN do:
      undo _main, return error v-last-error-message .
    end.
    /*надо записать в статусы */
    v-edist-mess = ''.
    v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, {&edist_route}, string(v-dump-ord-int64)).
    v-date-status = ?.
    run create-edi-state in this-procedure (
                                            input {&table_trn-doc}                    /* p-tbl-name */
                                          , input v-current-doc-code                  /* p-doc-code */
                                          , input v-cli-type                          /* p-cli-type */
                                          , input v-cli-code                          /* p-cli-code */
                                          , input {&update}                           /* p-act      */
                                          , input buf_ord-doc.ord-int1                /* p-state    */
                                          , input integer({&severity-no-error})       /* p-err      */
                                          , input v-PS                                /* p-des      */
                                          , input v-edist-mess                        /* p-mess     */
                                          , input integer({&doc-dm-edi})
                                          , input-output v-date-status
                                          , input-output v-time-status
                                          ).

    &scop release_1 clear-data ( )
    ExpData1:Route-data_{&release_1} .
  end. /*else if retry*/
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .

define variable v-is-waiting-status as logical   no-undo .
define variable v-direction as character no-undo .
define variable v-dm as integer no-undo .
define variable v-ext-doc-type as character no-undo .

define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_ord-chain  for ub.ord-chain.

do
on error undo, return error
:

  if g#news then  return "return".  
  assign
  v-oldbh = widget-handle (entry(2, p-doc-code, {&delim-par}))
  v-newbh = widget-handle (entry(3, p-doc-code, {&delim-par}))
  v-changes-list = entry(4, p-doc-code, {&delim-par})
  file-name  = p-process-file-name
  v-has-oldbh = valid-handle(v-oldbh) and v-oldbh:available
  v-has-newbh = valid-handle(v-newbh) and v-newbh:available
  .
  if not v-has-newbh
  and not v-has-oldbh then do:
    undo, return error substitute("Не определено ни одного буфера - ни старый, ни новый").
  end.
  if not v-has-oldbh
  and v-changes-list  = '' then do:
     undo, return error substitute("Не определен старый буфер и список изменений").
  end.
  case p-ruleset-id:
  when {&edoc-proc_18_event_trn-doc_115} then do:
    if v-has-newbh
    and v-newbh:table <> {&table_trn-doc} then do:
      undo, return error substitute("Передан неверный буфер вместо буфера для &1",  {&table_ord-doc-rcv}).
    end.
  end.
  otherwise do:
    undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
  end.
  end case.
  run statq_has-waiting-stat in this-procedure (
                                                  input v-oldbh
                                                 ,input v-newbh
                                                 ,input v-changes-list
                                                 ,input {&fact}
                                                 ,input ?  /*p-waiting-flag_*/
                                                 ,input 0 /*p-stati*/
                                                 ,output v-is-waiting-status
                                                 ,output v-direction
                                                 ) no-error.
  if v-is-waiting-status = no
  or entry(1, v-direction, {&delim-par}) = {&deletion}
  then do:
    return "return".
  end.
  v-dm = v-newbh:Buffer-field("whole-send-news"):buffer-value.
  v-current-doc-code = v-newbh:buffer-field("doc-code"):buffer-value. /*trn-doc.doc-code*/
  v-doc-date = v-newbh:buffer-field("doc-date"):buffer-value. /*trn-doc.doc-date*/
  v-fact-date = v-newbh:buffer-field("fact-date"):buffer-value.   /*trn-doc.fact-date*/
  v-ps = v-newbh:buffer-field("ps"):buffer-value.   /*trn-doc.ps*/
  v-ext-doc-type = v-newbh:buffer-field("ext-doc-type"):buffer-value.
  if v-dm <> integer({&doc-dm-edi}) then do:
    return "return".
  end.
  if v-ext-doc-type <> {&tdedt_pri_vnesh} then do:
    return "return".
  end.

  find first buf_ord-chain   no-lock where
          buf_ord-chain.rel-doc-code = v-current-doc-code
     and  buf_ord-chain.rel-doc-type = "trn"
     and buf_ord-chain.doc-type = "rcv" no-error .
  if not available buf_ord-chain then return "return".
  find first buf_ord-doc-rcv no-lock where
            buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code no-error .
  if not available buf_ord-doc-rcv then do:
    /*ошибка??*/
    return "return".
  end.
  find first buf_ord-doc exclusive-lock where
            buf_ord-doc.doc-code = buf_ord-doc-rcv.doc-code no-error .
  if not available buf_ord-doc
  or buf_ord-doc.doc-type <> {&o-p}
  then do:
    return "return".
  end.



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
end. /*doe*/

end procedure. /* load-ruleset-context */

/*не удалять!!!!*/