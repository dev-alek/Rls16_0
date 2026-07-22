/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 18

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/26/08
Author: Bakhtadze Natalya
Creation date: 05/26/08

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18, набор 1".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code
{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }
{ gbl/gate-clb.i }
{ str/ord-list.i ord-list def "shared" }
{ rul/rum-fn.i }
{ rul/context_f.i get-thobj-es }
{ gbl/key-rec.i }
{ bge/esysattr.i }
{ bge/tmpcxmlh.i }
{ rul/ruleset_.i }
{ cus/exiteedi-order.i -t }
{ cus/edocsord.i edi }
{ cus/str-edi.i }
{ str/bc-gnrt.i new bc }
{ cus/ordlnatt.i }
{ cus/cr-edist.i }

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-doc-code as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-last-error-message as character no-undo .
/*****************************/
define variable file-name as char.
define variable v-sign as integer no-undo .
define variable v-gate-rec as character no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable v-type as character no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .

{ str/dia2auto.i }
{ rul/seterror.i }

define buffer buf_temp-cmd for temp-cmd.

&scop display-message ~
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

/* ------------------------- &start-def-vars& -----------------------------------*/

define variable ExpData1 as class Route-data_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle)
ExpData1 = new Route-data_{&constructor_1} .

/* ------------------------- &end-def-vars& -----------------------------------*/

if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
    v-esm = error-status :get-message (1).
    v-es = error-status:error .
    v-rv = return-value .
  end.
  { str/cdviewlg.i  "'!!!При маршрутизации произошли ошибки!!!'"   log-file-name not-delete }
  if v-es then do:
      &scop my-message substitute( "&1. &2&3&4", vss-workfile, v-rv, ~{&new-line~}, v-esm)
      {&display-message}.
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, {&new-line}, v-esm).
  end.
  run garbcoll_clear in this-procedure .
end.

procedure proc-main :

_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:

  define variable v-ii as integer no-undo .
  define variable v-uniq-key-rec as character no-undo .
  define variable v-cli-uniq-key-rec as character no-undo .
  define variable v-err as logical no-undo .
  define variable v-custom-pack-name as character no-undo .
  define variable v-success as logical   no-undo .
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .
  define variable v-ord-int1 as integer no-undo .
  define variable v-obj-gln as character no-undo .
  define variable v-cli-gln as character no-undo .
  define variable v-frm-gln as character no-undo .
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
  define variable v-edist-mess as character no-undo .
  define variable v-date-status as date no-undo .
  define variable v-time-status as integer no-undo .

  define buffer buf_ext-system for ub.ext-system.
  define buffer buf_ord-doc for ub.ord-doc.
  define buffer buf_ord-line for ub.ord-line.
  define buffer buf_object for ub.clients.
  define buffer buf_clients for ub.clients.
  define buffer buf_ext-classif for ub.ext-classif.
  define buffer esys_ext-classif for ub.ext-classif.
  define buffer buf_goods for ub.goods.
  define buffer buf_esys-pck-sent for ub.esys-pck-sent.
  define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
  define buffer buf_currency for ub.currency.
  define buffer buf_ord-list for ord-list.
  define buffer buf_gds-prt for ub.gds-prt.
  define buffer buf_bar-code for ub.bar-code.
  define buffer buf_prod-bc for ub.prod-bc.


/* ------------------------- &end-hn-option& -----------------------------------*/
  dataset order_-t:handle:empty-dataset() .
  run write-log  in p-log-handle (
                                      input 0
                                    , "&DLine").
  find first ord-list no-error .
  if not available ord-list then return "return".
  _stroka:
  for each ord-list
  break
  by ord-list.host-code
  by ord-list.obj-type
  by ord-list.obj-code
  by ord-list.cli-type
  by ord-list.cli-code
  by ord-list.doc-code
  by ord-list.trn-doc
  On error undo _stroka, retry _stroka
  :
    if retry then do:
      &scop my-message substitute("Ошибка при обработке заказа &1:&2&3",ord-list.doc-code, ~{&new-line~}, v-mess)
      {&display-message}.
      if available ord-list then delete ord-list.
      next _stroka.
    end.
    else do:
      if ord-list.dm <> integer({&doc-dm-edi}) then do:
        next _stroka.
      end.
      if ord-list.is-trn-doc then do:
        next _stroka.
      end.
      assign
      v-mess = ''
      v-current-doc-code = ord-list.doc-code
      num-rec = num-rec + 1
      .
      &scop my-message substitute("Обработка заказа &1 &2", ord-list.doc-code , ord-list.trn-doc)
      {&display-message}.
      if v-err then next.
      /* ------------------------- &start-rule& -----------------------------------*/
      IF num-rec = 1
      THEN do:
        IF  ExpData1:route-data_read-xmlschema( INPUT p-xsd-file) = false  THEN do:
          undo _main, return error v-last-error-message .
        end.
      end.
      dataset order_-t:handle:empty-dataset() .
      if ord-list.is-trn-doc = no
      and ord-list.sel-order = 0
      then do:
        if ord-list.ord-int1 =  integer({&edi-ordrsp-no})
        or ord-list.ord-int1 =  integer({&edi-ordrsp-yes})
        then do:
          /*здесь только отправка ORDER*/
          assign
          num-rec = num-rec - 1.
          next _stroka.
        end.
        IF num-rec = 1 then do:
          &scop my-message substitute(".............Маршрутизация заказов поставщику")
          {&display-message}.
        end.
        if ord-list.ord-int1 = integer({&edi-orders-sts})
        or ord-list.ord-int1 = integer({&edi-ordrsp-sts})
        or ord-list.ord-int1 =  integer({&edi-ordrsp})
        or ord-list.ord-int1 = integer({&edi-err})
        or ord-list.ord-int1 =  integer({&edi-desadv})
        or ord-list.ord-int1 =  integer({&edi-desadv-sts})
        or ord-list.ord-int1 =  integer({&edi-recadv-sts})
        or ord-list.ord-int1 =  integer({&edi-recadv})
        then do:
          &scop order-stts-int1 string(ord-list.ord-int1)
          v-mess = substitute("Нельзя отправить Заказ в статусе <&1>!", {&edi-stts-name} ).
          assign v-view-log = yes.
          v-err = yes.
          undo _stroka, retry _stroka.
        end.
        if ord-list.doc-type = {&O-P}
        and ord-list.status_  = {&g___new}
        and ord-list.ord-int1 = integer({&edi-empty}) then do:
          assign
          v-ord-int1 = integer({&edi-orders}).
        end.
        if ord-list.status_ <> {&g___new}
        or ord-list.ord-int1 = int({&edi-orders})
        then do:
          v-mess =  substitute("Заказ НЕ НОВЫЙ. Отправить можно только НОВЫЙ заказ!").
          assign v-view-log = yes.
          v-err = yes.
          undo _stroka, retry _stroka.
        end.
        if ord-list.ord-int1 <> integer({&edi-empty}) then do:
          v-mess = substitute("Заказ уже был отправлен. Отправить можно только НОВЫЙ заказ (желтый)!").
          assign v-view-log = yes.
          v-err = yes.
          undo _stroka, retry _stroka.
        end.
        if not ( ord-list.doc-type = {&O-P} )   then do:
          v-mess = substitute("Нельзя отправить заказ, отправить можно только заказ ОП !").
          assign v-view-log = yes.
          v-err = yes.
          undo _stroka, retry _stroka.
        end.
        if v-ord-int1 = integer({&edi-orders}) then do:
          if not can-find (first ub.ord-line no-lock where ub.ord-line.doc-code =  ord-list.doc-code ) or
          can-find (first ub.ord-line no-lock where  ub.ord-line.doc-code =  ord-list.doc-code and ub.ord-line.qnty = 0 ) or
          can-find (first ub.ord-line no-lock where  ub.ord-line.doc-code =  ord-list.doc-code and ub.ord-line.price-cli = 0 ) or
          can-find (first ub.ord-line no-lock where  ub.ord-line.doc-code =  ord-list.doc-code and ub.ord-line.cli-art = "" )
        then do:
            v-mess = substitute("Заказ полностью не создан. Проверьте наличие строк, количеств, цены и артикула поставщика !").
            v-err = yes.
            assign v-view-log = yes.
            undo _stroka, retry _stroka.
          end.
        end.
        if ord-list.doc-type = {&O-P}
        and ord-list.status_  = {&g___new}
        and ord-list.ord-int1 = integer({&edi-empty}) then do:
          assign
          ord-list.ord-int1 = integer({&edi-orders}).
        end.
      end. /*if ord-list.is-trn-doc = no then do:*/
      if first-of(ord-list.cli-code) then do:
        v-err = no.
        find first buf_clients no-lock where
                  buf_clients.obj-type = ord-list.cli-type
              and buf_clients.obj-code = ord-list.cli-code no-error.
        if not available buf_clients then do:
          v-mess =  substitute("Не найден контрагент &1&2", ord-list.cli-typ, ord-list.cli-code).
          assign v-view-log = yes.
          v-err = yes.
          undo _stroka, retry _stroka.
        end.
        run gen-key-rec in this-procedure ( input {&table_clients}
                                          ,input (buffer buf_clients:handle)
                                          ,output v-cli-uniq-key-rec) no-error .
        if error-status:error then do:
          v-mess = substitute("gen-key-rec: &1&2&3&2(&4&5)"
                                    , error-status:get-message(1)
                                    , return-value
                                    , {&new-line}
                                    , ord-list.cli-type
                                    , ord-list.cli-code).
          assign v-view-log = yes.
          v-err = yes.
          undo _stroka, retry _stroka.
        end.
        find first esys_ext-classif no-lock where
            esys_ext-classif.classif-name = {&extclass_clients_exite-edi}
        and esys_ext-classif.classif-subject = {&table_clients}
        and esys_ext-classif.db-num = -1
        and esys_Ext-classif.uniq-key-rec = v-cli-uniq-key-rec no-error .
        if not available esys_ext-classif then do:
          v-mess = substitute("Поставщик &1&2 заказа НЕ РАБОТАЕТ ПО СИСТЕМЕ EDI", ord-list.cli-type, ord-list.cli-code).
          assign v-view-log = yes.
          v-err = yes.
          undo _stroka, retry _stroka.
        end.
        find first buf_object no-lock where
                  buf_object.obj-type = ord-list.obj-type
              and buf_object.obj-code = ord-list.obj-code no-error.
        if not available buf_object then do:
          v-mess =  substitute("Не найден объект &1&2", ord-list.obj-type, ord-list.obj-code).
          assign v-view-log = yes.
          v-err = yes.
          undo _stroka, retry _stroka.
        end.
        if buf_object.db-num <> g#db-num then do:
          v-mess = substitute("Объект &1&2 принадлежит другой БД", ord-list.obj-type, ord-list.obj-code).
          assign v-view-log = yes.
          v-err = yes.
          undo _stroka, retry _stroka.
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
          assign v-view-log = yes.
          v-err = yes.
          undo _stroka, retry _stroka.
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
          assign v-view-log = yes.
          v-err = yes.
          undo _stroka, retry _stroka.
        end.
        v-cli-gln = get-gln( input ord-list.cli-type
                            ,input ord-list.cli-code) no-error.
        if error-status:error
        or v-cli-gln = {&question-mark}
        or v-cli-gln = '' then do:
          v-mess =  substitute("Не определен GLN для &1&2"
                                    , buf_object.obj-type
                                    , buf_object.obj-code) .
          assign v-view-log = yes.
          v-err = yes.
          undo _stroka, retry _stroka.
        end.
        /* в предыдущей реализации EDI байером была фирма!!! оставим так*/
        v-frm-gln = get-gln( input {&cmp}
                            ,input ord-list.host-code) no-error.
        if error-status:error
        or v-frm-gln = {&question-mark}
        or v-frm-gln = '' then do:
          v-mess =  substitute("Не определен GLN для &1&2"
                                    , {&cmp}
                                    , ord-list.host-code) .
          assign v-view-log = yes.
          v-err = yes.
          undo _stroka, retry _stroka.
        end.
        /*найдем привязки объекта и поставщика к exite*/
        _esys:
        for each esys_ext-classif no-lock where
            esys_ext-classif.classif-name = {&extclass_clients_exite-edi}
        and esys_ext-classif.classif-subject = {&table_clients}
        and esys_ext-classif.db-num = -1
        and esys_Ext-classif.uniq-key-rec = v-cli-uniq-key-rec,
          first buf_ext-system no-lock where
                    buf_ext-system.esys-id = esys_ext-classif.key#_one
                and buf_ext-system.db-num = 0
/*                and buf_ext-system.esys-db-num-exp = g#db-num*/
                and buf_ext-system.esys-have-export = yes,
          first buf_ext-classif no-lock where
            buf_ext-classif.classif-name = {&extclass_clients_exite-edi}
        and buf_ext-classif.classif-subject = {&table_clients}
        and buf_ext-classif.db-num = -1
        and buf_Ext-classif.uniq-key-rec = v-uniq-key-rec
        and buf_Ext-classif.key#_one = esys_ext-classif.key#_one:
          leave  _esys.
        end.
        if not available buf_ext-system then do:
          v-mess = substitute("Для поставщика &1&2 не найдена ВС, у которой есть экспорт в текущей БД", ord-list.cli-type, ord-list.cli-code).
          assign v-view-log = yes.
          v-err = yes.
          undo _stroka, retry _stroka.
        end.
      end. /*if first-of(ord-list.cli-code) then do:*/
      if p-save >= 0 then do:
        find first buf_ord-doc exclusive-lock where
                  buf_ord-doc.doc-code = ord-list.doc-code
              no-error.
      end.
      else do:
        find first buf_ord-doc no-lock where
                  buf_ord-doc.doc-code = ord-list.doc-code
              no-error.
      end.
      if not available buf_ord-doc then do:
        v-mess = substitute("Не найден содержащийся в списке заказ &1", ord-list.doc-code).
        assign v-view-log = yes.
        v-err = yes.
        undo _stroka, retry _stroka.
      end.

      IF  context_begin-esys-command( input string(buf_ext-system.esys-id), input-output v-esys-cmd-proc-handle, output v-esys-cmd-code) = false  THEN do:
        undo _main, return error v-last-error-message .
      end.
      find first buf_currency no-lock where
                buf_currency.curr-code = buf_ord-doc.exch-code no-error.
      if not available buf_currency then do:
        v-mess = substitute("Не найдена валюта с кодом &1", buf_ord-doc.exch-code).
        assign v-view-log = yes.
        v-err = yes.
        undo _stroka, retry _stroka.
      end.
      if num-entries(buf_currency.curr-eng-name, {&delim-par}) < 2
      or lookup(entry(2, buf_currency.curr-eng-name, {&delim-par}), "ATS,CHF,DEM,EUR,ITL,UAH,RUB,USD,BYR,MDL") = 0
      then do:
        v-mess = substitute("Код ОКВ валюты &1 не найден в списке разрешенных для EXITE-EDI валют (&2)"
                            , buf_ord-doc.exch-code
                            ,"ATS,CHF,DEM,EUR,ITL,UAH,RUB,USD,BYR,MDL").
        assign v-view-log = yes.
        v-err = yes.
        undo _stroka, retry _stroka.
      end.

      /*создадим имя custom имя файла*/
      v-custom-pack-name = substitute("ORDER_&1_&&pack-num.xml"
                                    ,v-obj-gln).

      /*TODO создание и заполнение записи order-t*/
      create order-t.
      assign
        order-t.DOCUMENTNAME   = "220"
        order-t.NUMBER         = buf_ord-doc.doc-code
        order-t.DATE           = buf_ord-doc.doc-date /*даты в Exite EDI в формате YYYY-MM-DD ???*/
        order-t.DELIVERYDATE   = buf_ord-doc.ship-date
        order-t.DELIVERYTIME   = string(buf_ord-doc.ship-time, "HH:MM")
        order-t.CAMPAIGNNUMBER = ""
        order-t.CURRENCY       = string(entry(2, buf_currency.curr-eng-name, {&delim-par}) , "X(3)")
        order-t.INFO           = substring(buf_ord-doc.ps, 1, 70)
      .

      ExpData1:route-data_create-record( INPUT "order") .
      ExpData1:route-data_copy-record( INPUT "order", INPUT  (buffer order-t:handle) ) .
      IF ExpData1:esys-add-dump( INPUT "order", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        undo _main, return error v-last-error-message .
      end.

      /*TODO создание и заполнение записи head-t*/

      create head-t.
      assign
        head-t.NUMBER         = buf_ord-doc.doc-code
        head-t.SUPPLIER       = v-cli-gln
        head-t.BUYER          = v-frm-gln
        head-t.DELIVERYPLACE  = v-obj-gln
        head-t.INVOICEPARTNER = v-frm-gln /*в предыдущей реализации  было так!!!*/
        head-t.SENDER         = v-obj-gln
        head-t.RECIPIENT      = v-cli-gln
        head-t.EDIINTERCHANGEID = ""
      .

      ExpData1:route-data_create-record( INPUT "head") .
      ExpData1:route-data_copy-record( INPUT "head", INPUT  (buffer head-t:handle) ) .
      IF ExpData1:esys-add-dump( INPUT "head", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        undo _main, return error v-last-error-message .
      end.

      /* по строкам заказа */
      for each buf_ord-line no-lock where
              buf_ord-line.doc-code = ord-list.doc-code
              by buf_ord-line.line-num
      on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
      :
        find first buf_goods no-lock where
                  buf_goods.gds-code = buf_ord-line.gds-code no-error.
        if not available buf_goods then do:
          undo _main, return error substitute("Не найден товар с кодом &1", buf_ord-line.gds-code).
        end.
        find first position-t where
                  position-t.number = buf_ord-doc.doc-code
              and position-t.productidsupplier = buf_ord-line.cli-art no-error .
        if available position-t then do:
          v-mess =  substitute("В заказе две строки с одинаковым артикулом поставщика &1: пропускаем этот заказ..."
                                      , ord-list.doc-code
                                      , buf_ord-line.cli-art
                                      ).
          assign v-view-log = yes.
          IF  context_delete-command( input v-esys-cmd-proc-handle, input v-esys-cmd-code) = false  THEN do:
            undo _main, return error v-last-error-message .
          end.
          &scop release_1 clear-data ( )
          ExpData1:Route-data_{&release_1} .
          undo _stroka, retry  _stroka.
        end. /*if available order-line then do:*/
        else do:
          /*правильный путь!!!!!*/
          _jj: /* логика такова - идентификатором товара является значение тэга PRODUCT -
          поэтому логично будет в тэге QUANTITYOFCUINTU держать коэфф по отношению к тому что написано в PRODUCT
          сначала поищем ШТРИХКОД (допбк) для единицы измерения buf_ord-line.unit-cli - если найдем в QUANTITYOFCINTU положим 1
          а если не найдем  то поищем ШТРИХКОД для основной ед изм  если найдем в QUANTITYOFCINTU положим buf_ord-line.cli-base-rate
          */
          do v-jj = 1 to 2:
            /*если едизм заказа совпадает с основным едизмом переходим к v-jj = 2*/
            if buf_ord-line.unit-cli = buf_goods.unit-base
            and v-jj = 1 /*клиентский едизм и так основной*/
            then do:
              next _jj.
            end.
            if v-jj = 1 then do:
              /*сначала ищем баркод для едизма unit-cli*/
              find first buf_gds-prt no-lock where
                        buf_gds-prt.upper-code = buf_goods.prt-root no-error.
              if not available buf_gds-prt then do:
                undo _main, return error substitute("Не найдена шкала для товара с кодом &1", buf_goods.gds-code).
              end.
              define variable v-is-new as logical no-undo .
              /*ищем баркод для ед изм поставщика*/
              { gbl/barcodcr.i
                buf_goods.gds-code
                buf_gds-prt.node-code
                "'':U"
                "'':U"
                buf_ord-line.unit-cli
                1
                v-is-new
                buf_bar-code
                no-error
              }
              if error-status :error
              then do:
                undo _main, return error substitute("Для товара с кодом &1 не найден баркод с ед.изм &2"
                                                  , buf_goods.gds-code
                                                  , buf_ord-line.unit-cli
                                                  ).
              end.
              v-b-code = buf_bar-code.b-code.
            end. /*if v-jj = 1 then do:*/
            if v-jj = 2 then do:
              /*во втором шаге если до него дело дошло  ищем корневой баркод*/
              { gbl/gdsbcode.i
                buf_goods.gds-code
                ?
                v-b-code
                }
            end.
            v-b-str = ''.
            /*на случай ошибки подговтоим сообщение!!! для retry */
            v-mess =  substitute("Ошибка при поиске первого включенного ДопБК для товара с кодом &1 с ед.изм &2"
                                                    , buf_goods.gds-code
                                                    , buf_ord-line.unit-cli).

            _prod-bc:
            for each buf_prod-bc no-lock where
                      buf_prod-bc.b-code = v-b-code
                  and buf_prod-bc.bc-on = yes
            on error  undo _stroka, retry _stroka
            on stop   undo _stroka, retry _stroka
            on endkey undo _stroka, retry _stroka
            :
              /*согласно схеме отсеиваем сразу не удовляетворяющие по длине !!!!*/

              if not (length(buf_prod-bc.b-str) = 8
                      or
                      (length(buf_prod-bc.b-str) >= 11
                      and
                      length(buf_prod-bc.b-str) <= 14)
                      )
              or trim(buf_prod-bc.b-str, "01234567890") <> "" then next _prod-bc.
              /*ПРОВЕРКА В prodbcat проводится над БУФЕРОМ - ЕСЛИ БУФЕРА НЕТ - ТО ВСЕ УПАДЕТ!!*/
              /*сначала обнулим переменные*/
              assign
              l-prod-bc-pgweight = no
              l-prod-bc-weight = no
              l-is-petrol-code = no
              l-is-scaleable = no
              .
              /*все проверки можно ограничить для случая когда работаем с основной ед измерени
              только для нее бывают топливыне весовые и штучные коды для весов!!!  */
              if v-jj = 2 then do:
                { gbl/prodbcat.i buf_prod-bc "'petrolium=request':u" l-is-petrol-code no-error }
                if error-status:error then do:
                  v-mess =  substitute("Ошибка при определении свойства ТОПЛИВНЫЙ доп.БК &1, для товара с кодом &2 и ед.изм &3"
                                                    , buf_prod-bc.b-str
                                                    , buf_goods.gds-code
                                                    , buf_ord-line.unit-cli).
                  assign v-view-log = yes.
                  v-err = yes.
                  undo _stroka, retry _stroka.
                end.
                { gbl/prodbcat.i buf_prod-bc "'weight=request':u"    l-prod-bc-weight no-error }
                if error-status:error then do:
                  v-mess =  substitute("Ошибка при определении свойства ВЕСОВОЙ доп.БК &1, для товара с кодом &2 и ед.изм &3"
                                                    , buf_prod-bc.b-str
                                                    , buf_goods.gds-code
                                                    , buf_ord-line.unit-cli).
                  assign v-view-log = yes.
                  v-err = yes.
                  undo _stroka, retry _stroka.
                end.
                { gbl/prodbcat.i buf_prod-bc     "'pgweight=request':u"  l-prod-bc-pgweight  no-error }

                if error-status:error then do:
                  v-mess =  substitute("Ошибка при определении свойства ШТУЧНЫЙ КОД ДЛЯ ВЕСОВ доп.БК &1, для товара с кодом &2 и ед.изм &3"
                                                    , buf_prod-bc.b-str
                                                    , buf_goods.gds-code
                                                    , buf_ord-line.unit-cli).
                  assign v-view-log = yes.
                  v-err = yes.
                  undo _stroka, retry _stroka.
                end.
              end. /*if buf_ord-line.unit-cli = buf_goods.unit-base then do:*/
              else do:
                /*если ед изм поставщика <> основной - есть другая опасность!!!! ВЗВЕШИВАЕМЫЙ КОД*/
                /*раз пошла такая история и на него тоже проверим*/
                { gbl/prodbcat.i buf_prod-bc     "'scaleable=request':u"  l-is-scaleable  no-error }

                if error-status:error then do:
                  v-mess =  substitute("Ошибка при определении свойства ВЗВЕШИВАЕМЫЙ доп.БК &1, для товара с кодом &2 и ед.изм &3"
                                                    , buf_prod-bc.b-str
                                                    , buf_goods.gds-code
                                                    , buf_ord-line.unit-cli).
                  assign v-view-log = yes.
                  v-err = yes.
                  undo _stroka, retry _stroka.
                end.
              end. /*else f buf_ord-line.unit-cli = buf_goods.unit-base then do:*/
              if not l-prod-bc-pgweight
              and not l-prod-bc-weight
              and not l-is-petrol-code
              and not l-is-scaleable
              then do:
                leave _prod-bc.
                /*когда делается leave мы выходим из цикла имея в буфере запись!!!!*/
              end.
              end. /*for each buf_prod-bc no-lock where*/
            if available buf_prod-bc then do:
              v-b-str = buf_prod-bc.b-str.
            end.
            else do:
              if v-jj = 1 then do:
                /*если находимся в шаге который связан с НЕОСНОВНМЫ ЕДИЗМОМ - ТО ЛУЧШЕ ПЕРЕЙТИ К ОСНОВНОМУ -
                ТАМ ВЕРОЯТНОСТЬ НАЛИЧИЯ реального ДопБК БОЛЬШЕ!!*/
                next _jj.
              end.
              if v-jj = 2 then do:
                /*находимся в шаге ОСНОВНОГО ЕДИЗМА - единственный выход - сгенерить EAN из локального*/
                RUN gen-bc in this-procedure ( input v-b-code, output v-b-str ).
              end.
            end.
            if v-b-str <> "" then do:
              if v-jj = 1 /*ДопБК нашелся для unit-cli едизма*/
              or (v-jj = 2 and buf_ord-line.unit-cli = buf_goods.unit-base) then do:
                v-cli-base-rate = 1.
              end.
              else do:
                v-cli-base-rate = buf_ord-line.cli-base-rate.
              end.
              leave _jj.
            end.
          end. /*do v-jj = 1 to 2:*/
          if v-b-str = '' then do:
              /*вообще ничего не нашли каким-то образом - отваливаемся*/
            v-mess =  substitute("Не удалось найти/сгенерировать ШТРИХКОД для товара с кодом &2"
                                              , buf_goods.gds-code
                                              ).
            assign v-view-log = yes.
            v-err = yes.
            undo _stroka, retry _stroka.
          end.
          /*для того, чтобы в дальнейшем ссылаться на ЭТОТ ЖЕ САМЫЙ допбК надо его запомнить!!! - так было в прошлой реализации*/
          run ordlineattr-write in this-procedure (
                                                    input buf_ord-doc.doc-code
                                                    ,input buf_goods.gds-code
                                                    ,input {&attr-order-ean13}
                                                    ,input v-b-str
                                                    ).

          /*TODO создание и заполнение записи position-t  */
          create position-t.
          assign
          position-t.NUMBER            = buf_ord-doc.doc-code
          position-t.POSITIONNUMBER    = buf_ord-line.line-num
          position-t.PRODUCT           = v-b-str
          position-t.PRODUCTIDSUPPLIER = buf_ord-line.cli-art
          position-t.PRODUCTIDBUYER    = string(buf_ord-line.gds-code)
          position-t.ORDEREDQUANTITY   = buf_ord-line.cli-qnty
          position-t.QUANTITYOFCUINTU  = v-cli-base-rate
          position-t.ORDERUNIT         = buf_ord-line.unit-cli
          position-t.ORDERPRICE        = buf_ord-line.price-cli
          position-t.vat               = buf_ord-line.vat-pc
          .
          ExpData1:route-data_create-record( INPUT "position") .
          ExpData1:route-data_copy-record( INPUT "position", INPUT  (buffer position-t:handle) ) .
          IF  ExpData1:esys-add-dump( INPUT "position", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            undo _main, return error v-last-error-message .
          end.
          /*TODO создание и заполнение записи characteristic-t */
          create characteristic-t.
          assign
          characteristic-t.NUMBER               = buf_ord-doc.doc-code
          characteristic-t.POSITIONNUMBER       = buf_ord-line.line-num
          characteristic-t.CHARACTERISTICNUMBER = 1 /*здесь пока ставим единицу - может придтся потом содатвать более чем одну запись characteristic!!*/
          characteristic-t.DESCRIPTION          = substring(buf_goods.gds-name, 1, 70)
          .
          ExpData1:route-data_create-record( INPUT "characteristic") .
          ExpData1:route-data_copy-record( INPUT "characteristic", INPUT  (buffer characteristic-t:handle) ) .
          IF  ExpData1:esys-add-dump( INPUT "characteristic", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
            undo _main, return error v-last-error-message .
          end.
          release position-t.
          release characteristic-t.

        end. /*else if available order-line then do:*/
      end. /*      for each buf_ord-line no-lock where*/
      empty temp-table position-t.
      empty temp-table characteristic-t.
      empty temp-table head-t.
      run edocsord_export in this-procedure ( buffer buf_ord-doc
                                          ,input ord-list.trn-doc
                                          ,input ord-list.ord-int1
                                          ) no-error.
      if error-status:error then do:
        v-mess = substitute("Ошибка при переводе статуса маршрутизированного заказа:&1&2&1&3"
                            , {&new-line}
                            , error-status:get-message(1)
                            , return-value ).
        undo _stroka, retry _stroka.
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
                                              input {&table_ord-doc}                    /* p-tbl-name */
                                            , input buf_ord-doc.doc-code                /* p-doc-code */
                                            , input buf_ord-doc.cli-type                /* p-cli-type */
                                            , input buf_ord-doc.cli-code                /* p-cli-code */
                                            , input {&update}                           /* p-act      */
                                            , input ord-list.ord-int1                   /* p-state    */
                                            , input integer({&severity-no-error})       /* p-err      */
                                            , input buf_ord-doc.PS                      /* p-des      */
                                            , input v-edist-mess                         /* p-mess     */
                                            , input integer({&doc-dm-edi})
                                            , input-output v-date-status
                                            , input-output v-time-status
                                            ).
      &scop release_1 clear-data ( )
      ExpData1:Route-data_{&release_1} .

      /* ------------------------- &end-rule& -------------------------------------*/

      /* ------------------------- &start-release-obj& -----------------------------------*/


      /* ------------------------- &end-release-obj& -------------------------------------*/

      num-rec-ok = num-rec-ok + 1.
      run write-counter in p-log-handle ( input substitute("Обработано заказов списка экспорта: &1, из них удачно: &2", num-rec, num-rec-ok)).
      run get-stop-state in p-log-handle ( output v-stop) no-error .
      if v-stop then do:
        &scop my-message substitute("Процесс прерван пользователем")
        {&display-message}.
        leave _stroka.
      end. /*if v-stop*/
    end. /*else if retry*/
    delete ord-list. /*не надо нам чтобы сваливалось еще в другой цикл!!!!*/
  end. /*for each ord-list where*/
  ExpData1:route-data_clear-xmlschema ( ).
  &scop my-message substitute("Обработано заказов списка экспорта: &1, из них удачно: &2", num-rec, num-rec-ok)
  {&display-message}.
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.

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
      when {&edoc-proc_18_batchwork-routing_order_2}
      then do:
        assign
        v-sign = 2
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        file-name  = p-process-file-name
        .
      end.
    end case.
  end. /*doe*/

end procedure. /* load-ruleset-context */

/*не удалять!!!!*/