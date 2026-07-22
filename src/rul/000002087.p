/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 18
выгрузка возврата поставщику как retann

Автор: Харитонов Владимир Александрович
Дата создания: 03/04/2013
Author: Kharitonov Vladimir
Creation date: 03/04/2013

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
{ cus/str-edi.i }
{ str/bc-gnrt.i new bc }
{ cus/ordlnatt.i }
{ str/statq.i }
{ cus/cr-edist.i }
{ str/trdcalib.i }
{ cus/exiteedi-retann.i }

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-doc-code as character no-undo .
define variable v-newbh as handle no-undo .
define variable v-oldbh as handle no-undo .
define variable v-has-newbh as logical no-undo .
define variable v-has-oldbh as logical no-undo .
define variable v-doc-date as date no-undo .
define variable v-fact-date as date no-undo .
define variable v-fact-qnty as decimal no-undo .
define variable v-ps as character no-undo .
define variable v-changes-list as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer   no-undo .
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
define variable v-dm-edi    as integer   no-undo .
define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.

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
define variable v-b-code as character no-undo .
define variable v-b-str as character no-undo .
define variable l-prod-bc-weight as logical no-undo .
define variable l-prod-bc-pgweight as logical no-undo .
define variable l-is-petrol-code as logical no-undo .
define variable l-is-scaleable as logical no-undo .
define variable v-jj as integer   no-undo .
define variable v-cli-base-rate as decimal no-undo .
define variable v-dump-ord-int64 as int64 no-undo .
define variable v-EDIINTERCHANGEID as character no-undo .
define variable v-edist-mess as character no-undo .
define variable v-deliverynotenumber as character no-undo .
define variable v-deliverynotedate as date no-undo .
define variable v-deliverynotedate-chr as character no-undo .
define variable v-attr-type as character no-undo .
define variable v-date-status as date no-undo .
define variable v-time-status as integer no-undo .
define variable v-date-chr as character no-undo .
define buffer buf_ext-system for ub.ext-system.
define buffer buf_ord-line for ub.ord-line.
define buffer buf_object for ub.clients.
define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
define buffer esys_ext-classif for ub.ext-classif.
define buffer buf_goods for ub.goods.
define buffer buf_currency for ub.currency.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_ext-artic for ub.ext-artic.

/* ------------------------- &end-hn-option& -----------------------------------*/

_main:
do
on error undo _main, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

 dataset RETANN_:handle:empty-dataset() .
 if retry then do:
    &scop my-message substitute("Ошибка при обработке накладной &1&2:&3&4" ~
                                   ,v-current-doc-code ~
                                   , ~{&new-line~}, v-mess)
    {&display-message}.
    undo _main, return error.
  end.
  else do:

    assign
    v-mess = ''
    .
    
    /* ------------------------- &start-rule& -----------------------------------*/
    IF  ExpData1:route-data_read-xmlschema( INPUT p-xsd-file) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    find first buf_clients no-lock where
              buf_clients.obj-type = v-cli-type
          and buf_clients.obj-code = v-cli-code no-error.
    if not available buf_clients then do:
      v-mess =  substitute("Не найден контрагент &1&2", v-cli-type, v-cli-code).
      v-err = yes.
      undo _main, retry _main.
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

      /*найдем првязку к EXITE*/
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
    v-custom-pack-name = substitute("RETANN_&1_&&pack-num.xml"
                                  ,v-obj-gln). /*действительно надо RECADV*/
    
    /* приводим факт дату к нужному формату */
    v-date-chr = subst(
        "&1-&2-&3",
        string(year(v-fact-date), "9999"),
        string(month(v-fact-date), "99"),
        string(day(v-fact-date), "99")).
    
    /* главный тег */
    create tt-RETANN.
    assign
        tt-RETANN.NUMBER = v-current-doc-code
        tt-RETANN.DATE = v-date-chr
        tt-RETANN.INFO = v-ps
    .

    ExpData1:route-data_create-record("tt-RETANN") .
    ExpData1:route-data_copy-record("tt-RETANN", buffer tt-RETANN:handle) .
    IF ExpData1:esys-add-dump("tt-RETANN", v-esys-cmd-proc-handle, v-esys-cmd-code, '+update') = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    
    /* шапка */
    create tt-HEAD.
    assign
        tt-HEAD.NUMBER = v-current-doc-code
        tt-HEAD.SUPPLIER = v-cli-gln
        tt-HEAD.BUYER = v-frm-gln
        tt-HEAD.DELIVERYPLACE = v-cli-gln
        tt-HEAD.SENDER = v-obj-gln
        tt-HEAD.RECIPIENT = v-cli-gln
    .

    ExpData1:route-data_create-record("tt-HEAD") .
    ExpData1:route-data_copy-record("tt-HEAD", buffer tt-HEAD:handle) .
    IF ExpData1:esys-add-dump("tt-HEAD", v-esys-cmd-proc-handle, v-esys-cmd-code, '+update') = false  THEN do:
      undo _main, return error v-last-error-message .
    end.

    /* по строкам накладной */
    for each buf_doc-line no-lock where
              buf_doc-line.doc-code = v-current-doc-code
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
        
      find first buf_goods
        where buf_goods.artic = buf_doc-line.artic
        and buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
        no-lock no-error.
      if not avail buf_goods then
        return error subst(
            "Не найден товар Артик: &1, Производитель: &2&3",
            buf_doc-line.artic,
            buf_doc-line.prod-type,
            buf_doc-line.prod-code
        ).      
      
      find first buf_ext-artic
        where buf_ext-artic.cli-type = v-cli-type
        and buf_ext-artic.cli-code = v-cli-code
        and buf_ext-artic.gds-code = buf_goods.gds-code
        and buf_ext-artic.status_ = {&current-status}
        no-lock no-error.
      
      run find-bcod(buf_goods.gds-code, output v-b-code).
      
      create tt-POSITION.
      assign
        tt-POSITION.NUMBER = v-current-doc-code
        tt-POSITION.POSITIONNUMBER = buf_doc-line.line-num
        tt-POSITION.PRODUCT = v-b-code
        tt-POSITION.PRODUCTIDSUPPLIER = if avail buf_ext-artic then buf_ext-artic.ext-artic else ""
        tt-POSITION.PRODUCTIDBUYER = string(buf_goods.gds-code)
        tt-POSITION.RETURNQUANTITY = v-fact-qnty
        tt-POSITION.RETURNQUANTITYUNIT = buf_goods.unit-cli
        tt-POSITION.PRICE = buf_doc-line.price-base
        tt-POSITION.AMOUNT = tt-POSITION.PRICE * tt-POSITION.RETURNQUANTITY
      .

      ExpData1:route-data_create-record("tt-POSITION") .
      ExpData1:route-data_copy-record("tt-POSITION", buffer tt-POSITION:handle) .
      IF  ExpData1:esys-add-dump("tt-POSITION", v-esys-cmd-proc-handle, v-esys-cmd-code, '+update') = false  THEN do:
        undo _main, return error v-last-error-message .
      end.
    end.

    /* формируем пакет */
    IF  context_set-custom-esys-pck-name(  input v-esys-cmd-proc-handle, input v-esys-cmd-code, input v-custom-pack-name) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    v-dump-ord-int64 = context_send-esys-command( input string(buf_ext-system.esys-id), input v-esys-cmd-proc-handle, input v-esys-cmd-code, input g#userid).
    if v-dump-ord-int64 = 0 THEN do:
      undo _main, return error v-last-error-message .
    end.

    &scop release_1 clear-data ( )
    ExpData1:Route-data_{&release_1} .
  /*else if retry*/
  end.
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
  if g#news then
    return "return".
    
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
  assign
      v-current-doc-code = v-newbh::doc-code /*trn-doc.doc-code*/
      v-doc-date = v-newbh::doc-date /*trn-doc.doc-date*/
      v-fact-date = v-newbh::fact-date   /*trn-doc.fact-date*/
      v-ps = v-newbh::ps   /*trn-doc.ps*/
      v-ext-doc-type = v-newbh::ext-doc-type
      v-fact-qnty = v-newbh::fact-qnty
  .
  
  if v-ext-doc-type <> {&TDEDT_Ras_Vnesh_VP} then do:
    return "return".
  end.

  if not v-has-newbh then return "return".
  
  v-current-obj-type = v-newbh::obj-type.
  v-current-obj-code = v-newbh::obj-code.
  v-cli-type = v-newbh::cli-type.
  v-cli-code = v-newbh::cli-code.
  v-current-host-code = v-newbh::host-code.

  if not status-is-edi(
      true,
      v-cli-type,
      v-cli-code,
      v-current-obj-type,
      v-current-obj-code,
      output v-dm-edi
  ) then return "return".
    
/*---------------------------&start-process-rule-call-param&-------------------------------*/

  find first buf_rule-call-param no-lock
    where buf_rule-call-param.codex_id = p-codex-id
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

/* ищем баркод */
procedure find-bcod:
    define input  parameter p-gds-code    as integer   no-undo.
    define output parameter p-bcod        as character no-undo.

    define variable v-is-new as logical no-undo.
    define variable v-flag   as logical no-undo.
    define variable v-bcod   as integer no-undo.
    define variable v-rec1   as recid   no-undo init 0.
        
    define buffer lc_goods      for ub.goods.
    define buffer lc_gds-prt    for ub.gds-prt.
    define buffer lc_bar-code   for ub.bar-code.
    define buffer lc_prod-bc    for ub.prod-bc.
    
    find first lc_goods no-lock
        where lc_goods.gds-code = p-gds-code.
    
    find first lc_gds-prt
        where lc_gds-prt.upper-code = lc_goods.prt-root
        no-lock.
    
    { gbl/gdsbcode.i
      lc_goods.gds-code
      ?
      v-bcod
      no-error
    }
    
    if error-status:ERROR then
        return error subst("Не удалось получить корневой БК для &1", lc_goods.gds-code).
    
    for each lc_prod-bc no-lock
        where lc_prod-bc.b-code = v-bcod
        and lc_prod-bc.bc-on = true
        :
            if not (length(lc_prod-bc.b-str) = 8
                or
                (length(lc_prod-bc.b-str) >= 11
                and
                length(lc_prod-bc.b-str) <= 14)
                )
                then next.
            
            { gbl/prodbcat.i lc_prod-bc "'petrolium=request':u" v-flag no-error }
            
            if error-status:error then
                return error subst("Не удалось определить свойство для БК &1", lc_goods.gds-code).
                
            if v-flag then next.            

            { gbl/prodbcat.i lc_prod-bc "'pgweight=request':u" v-flag no-error }
            
            if error-status:error then
                return error subst("Не удалось определить свойство для БК &1", lc_goods.gds-code).
                
            if v-flag then next.
            
            { gbl/prodbcat.i lc_prod-bc     "'pgweight=request':u" v-flag  no-error }
            
            if error-status:error then
                return error subst("Не удалось определить свойство для БК &1", lc_goods.gds-code).
                
            if v-flag then next.
            
            v-rec1 = recid(lc_prod-bc).
    end.
    
    if v-rec1 <> 0 then do:
        
        find first lc_prod-bc no-lock
            where recid(lc_prod-bc) = v-rec1.
                        
        p-bcod = lc_prod-bc.b-str.
    end.
    else do:
        run gen-bc(v-bcod, output p-bcod).
    end.
    
end.

/*не удалять!!!!*/