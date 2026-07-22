/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 18, набор 115

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/16/09
Author: Bakhtadze Natalya
Creation date: 10/16/09

---------------------------&start-codex_id=18;ruleset_id=115;-------------------------------

---------------------------&end-codex_id=18;ruleset_id=115;-------------------------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18, набор 14".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ rul/ruleset_.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ gbl/gate-clb.i }
{ gbl/key-rec.i }
{ bge/tmpcxmlh.i }
{ gbl/lib-gate.i }
{ ref/extclass.i }
{ str/statq.i }
{ rul/thdl-prc.i }


/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-doc-code as character no-undo .
define variable v-newbh as handle no-undo .
define variable v-oldbh as handle no-undo .
define variable v-has-newbh as logical no-undo .
define variable v-has-oldbh as logical no-undo .
define variable v-changes-list as character no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-last-error-message as character no-undo .
/*****************************/
define variable file-name as char.
define variable v-sign as integer no-undo .
define variable v-gate-rec as character no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-esys-id-list-start as character no-undo .
define variable v-esys-id-list as character no-undo .
define variable v-err-mess as character no-undo .
define variable v-action as character no-undo .

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
 { rul/context_f.i  send-esys-command }
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
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, {&new-line}, v-esm).
  end.
  run garbcoll_clear in this-procedure .
end.

procedure proc-main :

_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
on stop undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:

define variable v-err               as logical    no-undo .
define variable v-status_           as character  no-undo .
define variable v-flag              as logical    no-undo .
define variable v-doc-code          as character  no-undo .
define variable v-dklink-doc-type   as integer    no-undo .
define variable v-agentid           as integer    no-undo .
define variable v-ext-doc-type      as character  no-undo .
define variable v-trn-doc-obj-type  as character  no-undo .
define variable v-trn-doc-obj-code  as integer    no-undo .
define variable v-obj-db-num        as integer    no-undo .
define variable v-obj-uniq-key-rec  as character  no-undo .
define variable v-b-code            as integer    no-undo .
define variable v-main-b-code       as integer    no-undo .
define variable v-gds-name-full     as character  no-undo .
define variable v-node-name         as character  no-undo .
define variable v-agnt-id           as integer    no-undo .
define variable v-obj-type          as character  no-undo .
define variable v-obj-code          as integer    no-undo .
define variable v-tot-rubl          as decimal    no-undo .
define variable v-ext-num           as character  no-undo .
define variable v-table-name        as character  no-undo .
define variable v-cli-type          as character  no-undo .
define variable v-cli-code          as integer    no-undo .
define variable v-cli-id            as integer    no-undo .
define variable v-obj-id            as integer    no-undo .
define variable v-from-store-id     as integer    no-undo .
define variable v-to-store-id       as integer    no-undo .
define variable v-p-date            as datetime-tz  no-undo .
define variable v-ext-artic         as character  no-undo .

define buffer buf_clients for ub.clients.
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_goods for ub.goods.
define buffer buf_ext-artic for ub.ext-artic.


/* ------------------------- &end-hn-option& -----------------------------------*/
  /* ------------------------- &start-rule& -----------------------------------*/

  if v-has-newbh then do:
    v-trn-doc-obj-type = v-newbh::obj-type.
    v-trn-doc-obj-code = v-newbh::obj-code.
    v-doc-code = v-newbh:buffer-field("doc-code"):buffer-value.
    v-obj-type = v-newbh:buffer-field("obj-type"):buffer-value.
    v-obj-code = v-newbh:buffer-field("obj-code"):buffer-value.
    v-cli-type = v-newbh:buffer-field("cli-type"):buffer-value.
    v-cli-code = v-newbh:buffer-field("cli-code"):buffer-value.
    v-tot-rubl = v-newbh:buffer-field("tot-rubl"):buffer-value.
    v-ext-doc-type = v-newbh:buffer-field("ext-doc-type"):buffer-value.
    v-p-date = v-newbh:buffer-field("doc-date"):buffer-value.
  end.
  else do:
    v-trn-doc-obj-type = v-oldbh::obj-type.
    v-trn-doc-obj-code = v-oldbh::obj-code.
    v-doc-code = v-oldbh:buffer-field("doc-code"):buffer-value.
    v-obj-type = v-oldbh:buffer-field("obj-type"):buffer-value.
    v-obj-code = v-oldbh:buffer-field("obj-code"):buffer-value.
    v-tot-rubl = v-oldbh:buffer-field("tot-rubl"):buffer-value.
    v-ext-doc-type = v-oldbh:buffer-field("ext-doc-type"):buffer-value.
    v-p-date = v-oldbh:buffer-field("doc-date"):buffer-value.
  end.
  { gbl/objdbnum.i v-trn-doc-obj-type v-trn-doc-obj-code v-obj-db-num }
  if v-obj-db-num <> g#db-num then do:
    return 'return'.
  end.
  find first buf_clients no-lock where
            buf_clients.obj-type = v-trn-doc-obj-type
       and  buf_clients.obj-code = v-trn-doc-obj-code.
  run gen-key-rec in this-procedure ( input {&table_clients}
                                     ,input buffer buf_clients:handle
                                     ,output v-obj-uniq-key-rec).
  v-esys-id-list = ''.
  for each buf_ext-classif no-lock where
      buf_ext-classif.classif-name = {&extclass_clients_esys}
  and buf_ext-classif.classif-subject = {&table_clients}
  and buf_ext-classif.db-num = 0
  and buf_Ext-classif.uniq-key-rec = v-obj-uniq-key-rec :
    if lookup(string(buf_ext-classif.key#_one), v-esys-id-list-start, {&delim-nws}) = 0 then next.
    v-esys-id-list = v-esys-id-list + (if v-esys-id-list = '' then '' else {&delim-nws}) + string(buf_ext-classif.key#_one).
  end.
  if v-esys-id-list = '' then return "return". /*нет внешней системы куда отправлять*/

  assign
    v-ext-num = substitute("&1;&2;&3"
                          , v-doc-code
                          , {&table_trn-doc}
                          , v-ext-doc-type
                          )
  .

  if v-action = {&gen-line-update} then do:
    v-status_ = v-newbh:buffer-field("status_"):buffer-value.
    v-flag = v-newbh:buffer-field("flag_"):buffer-value.
    v-agentid = (if v-newbh:buffer-field("cli-type"):buffer-value = {&cmp} then 1000000000 else 0) + v-newbh:buffer-field("cli-code"):buffer-value.

    run thdl-prc_map-obj in this-procedure ( input  v-obj-type
                                           , input  v-obj-code
                                           , output v-obj-id
                                           )  no-error .
    if error-status :error = yes
    then do:
      assign
        v-last-error-message = substitute( "Ошибка преобразования контрагента: &1 &2. &3 &4"
                                         , v-obj-type
                                         , v-obj-code
                                         , return-value
                                         , error-status :get-message(1)
                                         )
      .
      undo _main, return error v-last-error-message .
    end.
    run thdl-prc_map-obj in this-procedure ( input  v-cli-type
                                           , input  v-cli-code
                                           , output v-cli-id
                                           )  no-error .
    if error-status :error = yes
    then do:
      assign
        v-last-error-message = substitute( "Ошибка преобразования контрагента: &1 &2. &3 &4"
                                         , v-cli-type
                                         , v-cli-code
                                         , return-value
                                         , error-status :get-message(1)
                                         )
      .
      undo _main, return error v-last-error-message .
    end.
    assign
      v-from-store-id = ?
      v-to-store-id   = ?
    .
    case v-ext-doc-type:
      when {&TDEDT_Pri_Vnesh} then do:
        assign
          v-dklink-doc-type = 0
          v-to-store-id     = v-obj-id
        .
      end.
      when {&TDEDT_Ras_Vnesh}
      then do:
        assign
          v-dklink-doc-type = 1
          v-from-store-id   = v-obj-id
        .
      end.
      when {&TDEDT_Inv} then do:
        assign
          v-dklink-doc-type = 2
          v-to-store-id     = v-obj-id
        .

      end.
      when {&TDEDT_Pri_Perem}  then do:
        assign
          v-dklink-doc-type = 3
          v-from-store-id   = v-cli-id
          v-to-store-id     = v-obj-id
        .
      end.
      when {&TDEDT_Ras_Perem}
      then do:
        assign
          v-dklink-doc-type = 4
          v-to-store-id     = v-cli-id
          v-from-store-id   = v-obj-id
        .
      end.
      when {&TDEDT_Ras_Vnesh_VP}
      then do:
        assign
          v-dklink-doc-type = 6
          v-from-store-id   = v-obj-id
        .
      end.
      when {&TDEDT_Vozvrat_Vnesh} then do:
        assign
          v-dklink-doc-type = 7
          v-to-store-id     = v-obj-id
        .
      end.
      when {&TDEDT_Ras_Vnesh_Kass}
      or
      when {&TDEDT_Vozvrat_Vnesh_Kass}
      or
      when {&TDEDT_Spi_Vnesh}
      or
      when  {&TDEDT_Peresort}
      or
      when {&TDEDT_Ras_Prvo}
      or
      when {&TDEDT_Spi_Prvo}
      or
      when {&TDEDT_Pri_Prvo}
      or
      when {&TDEDT_Corr_Acc_Price}
      or
      when {&TDEDT_Corr_Minus_Parts}
      or
      when {&TDEDT_Chg_Purch_Code}
      or
      when {&TDEDT_Vozvrat_Perem}
      then  do:
        return "return".
      end.
    end case.
  end.

  if v-cli-type = {&cmp} or
     v-cli-type = {&prs}
  then do:
    assign
      v-agnt-id = v-cli-id
    .
  end.
  else do:
    assign
      v-agnt-id = ?
    .
  end.

  IF  ExpData1:route-data_read-xmlschema( INPUT p-xsd-file) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.
  IF  context_begin-esys-command( input v-esys-id-list
                                , input-output v-esys-cmd-proc-handle
                                , output v-esys-cmd-code) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.
  ExpData1:route-data_create-record( INPUT "doc_header") .
  IF ExpData1:esys-add-dump( INPUT "doc_header", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
    v-err-mess = substitute("Ошибка при маршрутизации накладной &1:&2&3"
                            , v-doc-code
                            , {&new-line}
                            , v-last-error-message
                            ).
    undo _main, return error v-last-error-message .
  end.
  ExpData1:route-data_copy-field-integer( INPUT "doc_header", "ID", INPUT  0 ) .
  ExpData1:route-data_copy-field-character( INPUT "doc_header", "Action", INPUT  v-action ) .
  ExpData1:route-data_copy-field-character( INPUT "doc_header", "ExtNum", INPUT  v-ext-num).
  ExpData1:route-data_copy-field-integer( INPUT "doc_header", "Type", INPUT  v-dklink-doc-type).
  ExpData1:route-data_copy-field-integer( INPUT "doc_header", "AgentID", INPUT v-agnt-id ).
  ExpData1:route-data_copy-field-integer( INPUT "doc_header", "FromStoreID", INPUT v-from-store-id ).
  ExpData1:route-data_copy-field-integer( INPUT "doc_header", "ToStoreID", INPUT v-to-store-id ).
  ExpData1:route-data_copy-field-decimal( INPUT "doc_header", "PPrice", INPUT v-tot-rubl ).
  ExpData1:route-data_copy-field-datetime-tz( INPUT "doc_header", "PDate", INPUT v-p-date ).

  IF ExpData1:esys-add-dump( INPUT "doc_header", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
    v-err-mess = substitute("Ошибка при маршрутизации накладной &1:&2&3"
                            , v-doc-code
                            , {&new-line}
                            , v-last-error-message
                            ).
    undo _main, return error v-last-error-message .
  end.
  if v-ext-doc-type = {&TDEDT_Inv}
  then do:
    for each buf_doc-line no-lock where
            buf_doc-line.doc-code = v-doc-code
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
      find first buf_goods no-lock where
                buf_goods.artic = buf_doc-line.artic
            and buf_goods.prod-type = buf_doc-line.prod-type
            and buf_goods.prod-code = buf_doc-line.prod-code .
      ExpData1:route-data_create-record( INPUT "doc_line") .
      IF ExpData1:esys-add-dump( INPUT "doc_line", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации накладной &1:&2&3"
                                , v-doc-code
                                , {&new-line}
                                , v-last-error-message
                                ).
        undo _main, return error v-last-error-message .
      end.

      { gbl/gdsbcode.i buf_goods.gds-code ? v-main-b-code }

      assign
        v-gds-name-full = buf_goods.gds-name
      .

      ExpData1:route-data_copy-field-integer( INPUT "doc_line", "ID", INPUT  0 ) .
      ExpData1:route-data_copy-field-integer( INPUT "doc_line", "Pos", INPUT  buf_doc-line.line-num ) .
      ExpData1:route-data_copy-field-integer( INPUT "doc_line", "GoodsID", INPUT  buf_goods.gds-code ) .
      ExpData1:route-data_copy-field-integer( INPUT "doc_line", "StoreID", INPUT v-to-store-id ) .
      ExpData1:route-data_copy-field-integer( INPUT "doc_line", "BCID", INPUT  v-main-b-code ) .

      ExpData1:route-data_copy-field-character( INPUT "doc_line", "Name", INPUT  v-gds-name-full ) .
      ExpData1:route-data_copy-field-character( INPUT "doc_line", "Comment", INPUT  "" /*в gds-dtl.ps нету*/ ) .
      /*todo серийные номера в партиях!!!*/
      ExpData1:route-data_copy-field-character( INPUT "doc_line", "SN", INPUT  "" /*в gds-dtl сер номеров нету*/ ) .

      ExpData1:route-data_copy-field-decimal( INPUT "doc_line", "PCount", INPUT  buf_doc-line.doc-qnty  ) .
      ExpData1:route-data_copy-field-decimal( INPUT "doc_line", "FCount", INPUT  buf_doc-line.fact-qnty ) .

      ExpData1:route-data_copy-field-decimal( INPUT "doc_line", "PPrice", INPUT  buf_doc-line.price-cli).
      ExpData1:route-data_copy-field-decimal( INPUT "doc_line", "FPrice", INPUT  0.0).

      IF ExpData1:esys-add-dump( INPUT "doc_line", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации накладной &1:&2&3"
                                , v-doc-code
                                , {&new-line}
                                , v-last-error-message
                                ).
        undo _main, return error v-last-error-message .
      end.
    end.
  end.
  else do:
    for each buf_doc-line no-lock where
            buf_doc-line.doc-code = v-doc-code,
      each buf_gds-dtl no-lock where
            buf_gds-dtl.doc-code = v-doc-code
        and buf_gds-dtl.artic = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
      find first buf_goods no-lock where
                buf_goods.artic = buf_gds-dtl.artic
            and buf_goods.prod-type = buf_gds-dtl.prod-type
            and buf_goods.prod-code = buf_gds-dtl.prod-code .
      ExpData1:route-data_create-record( INPUT "doc_line") .
      IF ExpData1:esys-add-dump( INPUT "doc_line", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации накладной &1:&2&3"
                                , v-doc-code
                                , {&new-line}
                                , v-last-error-message
                                ).
        undo _main, return error v-last-error-message .
      end.
      { gbl/gdsbcode.i buf_goods.gds-code buf_gds-dtl.prt-code v-b-code }
      { gbl/gdsbcode.i buf_goods.gds-code ?                     v-main-b-code      }
      if v-b-code = v-main-b-code then do:
        v-gds-name-full = buf_goods.gds-name.
      end.
      else do:
        find first buf_gds-prt no-lock where
                  buf_gds-prt.node-code = buf_gds-dtl.prt-code no-error.
        v-node-name  = substitute("_&1", buf_gds-prt.f-name).
        assign
        v-gds-name-full = substitute("&1&2", buf_goods.gds-name, v-node-name).
      end.

      assign v-ext-artic = '' .
      if v-dklink-doc-type = 0 then do:
          find first buf_ext-artic no-lock
              where buf_ext-artic.cli-type = v-cli-type
                and buf_ext-artic.cli-code = v-cli-code
                and buf_ext-artic.gds-code = buf_goods.gds-code
                and buf_ext-artic.status_  = {&current-status}
             no-error .
          if available buf_ext-artic then do:
            assign v-ext-artic = buf_ext-artic.ext-artic .
          end.
             end.

      ExpData1:route-data_copy-field-integer( INPUT "doc_line", "ID", INPUT  0 ) .
      ExpData1:route-data_copy-field-integer( INPUT "doc_line", "Pos", INPUT  buf_doc-line.line-num ) .
      ExpData1:route-data_copy-field-integer( INPUT "doc_line", "GoodsID", INPUT  buf_goods.gds-code ) .
      ExpData1:route-data_copy-field-integer( INPUT "doc_line", "StoreID", INPUT v-to-store-id ) .
      ExpData1:route-data_copy-field-integer( INPUT "doc_line", "BCID", INPUT  v-b-code ) .

      ExpData1:route-data_copy-field-character( INPUT "doc_line", "Name", INPUT  v-gds-name-full ) .
      ExpData1:route-data_copy-field-character( INPUT "doc_line", "Comment", INPUT  "" /*в gds-dtl.ps нету*/ ) .
      /*todo серийные номера в партиях!!!*/
      ExpData1:route-data_copy-field-character( INPUT "doc_line", "SN", INPUT  "" /*в gds-dtl сер номеров нету*/ ) .

      ExpData1:route-data_copy-field-decimal( INPUT "doc_line", "PCount", INPUT  buf_gds-dtl.doc-qnty) .
      ExpData1:route-data_copy-field-decimal( INPUT "doc_line", "FCount", INPUT  buf_gds-dtl.fact-qnty) .

      ExpData1:route-data_copy-field-decimal( INPUT "doc_line", "PPrice", INPUT  buf_doc-line.price-cli).
      ExpData1:route-data_copy-field-decimal( INPUT "doc_line", "FPrice", INPUT  0.0).

      ExpData1:route-data_copy-field-character( INPUT "doc_line", "ExtArtic", INPUT v-ext-artic ) .

      IF ExpData1:esys-add-dump( INPUT "doc_line", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации накладной &1:&2&3"
                                , v-doc-code
                                , {&new-line}
                                , v-last-error-message
                                ).
        undo _main, return error v-last-error-message .
      end.
    end.

  end.

  IF  context_send-esys-command( input v-esys-id-list
                              , input v-esys-cmd-proc-handle
                              , input v-esys-cmd-code
                              , input g#userid) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.

  &scop release_1 clear-data ( )
  ExpData1:Route-data_{&release_1} .

  /* ------------------------- &end-rule& -------------------------------------*/

  /* ------------------------- &start-release-obj& -----------------------------------*/


  /* ------------------------- &end-release-obj& -------------------------------------*/

  ExpData1:route-data_clear-xmlschema ( ).
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer    no-undo .

define variable v-flag              as logical    no-undo .
define variable v-ii                as integer    no-undo .
define variable v-changes-list2     as character  no-undo .
define variable v-obj-db-num        as integer    no-undo .
define variable v-is-waiting-status as logical    no-undo .
define variable v-direction         as character  no-undo .
define variable v-direction-2       as character  no-undo .
define variable v-waiting-status    as character  no-undo .
define variable v-ext-doc-type      as character  no-undo .

define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_ext-system for ub.ext-system.
define buffer buf_clients for ub.clients.

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

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
        undo, return error substitute("Передан неверный буфер вместо буфера для &1",  {&table_trn-doc}).
      end.
      if v-has-oldbh
      and v-oldbh:table <> {&table_trn-doc} then do:
        undo, return error substitute("Передан неверный буфер вместо буфера для &1",  {&table_trn-doc}).
      end.
    end.
    otherwise do:
      undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
    end.
  end case.
  assign
    v-ext-doc-type = v-oldbh:buffer-field("ext-doc-type"):buffer-value.
  .
  case v-ext-doc-type
  :
    when {&TDEDT_Ras_Vnesh} or
    when {&TDEDT_Ras_Perem} or
    when {&TDEDT_Inv}
    then do:
      if v-has-newbh then do:
        if  v-newbh::status_  = {&wayb}
        and v-newbh::flag_    = yes
        and v-newbh::rcv-code = "from_tsd" then do:
          /*если перевели в накл+ снимаем признак, что пришел с ТСД, чтобы отправлять потом снова*/
          assign v-newbh::rcv-code = "" .
        end.

        if v-newbh::status_  = {&permitted}
        and v-newbh::flag_    = yes
        and v-newbh::rcv-code = "from_tsd" then do:
          /*если пришли с ТСД - чтобы не отправлялись снова*/
          return "return".
        end.
      end.

      assign
        v-waiting-status = {&permitted}
      .
    end.
    otherwise do:
      if v-has-newbh then do:
        if  v-newbh::status_  = {&wayb}
        and v-newbh::flag_    = no
        and v-newbh::rcv-code = "from_tsd" then do:
          /*если перевели в накл- снимаем признак, что пришел с ТСД, чтобы отправлять потом снова*/
          assign v-newbh::rcv-code = "" .
        end.

        if v-newbh::status_  = {&wayb}
        and v-newbh::flag_    = yes
        and v-newbh::rcv-code = "from_tsd" then do:
          /*если пришли с ТСД - чтобы не отправлялись снова*/
          return "return".
        end.
      end.
      assign
        v-waiting-status = {&wayb}
      .
    end.
  end case.
  run statq_has-waiting-stat in this-procedure (
                                                  input v-oldbh
                                                 ,input v-newbh
                                                 ,input v-changes-list
                                                 ,input v-waiting-status
                                                 ,input yes  /*p-waiting-flag_*/
                                                 ,input 0 /*p-stati*/
                                                 ,output v-is-waiting-status
                                                 ,output v-direction
                                                 ) no-error.
  if v-is-waiting-status = no then return "return".

/*  if entry(1, v-direction, {&delim-par} ) = {&close-doc}*/
/*  and v-newbh::status_ = {&fact} then return "return".*/

    if num-entries(v-direction, {&delim-par}) > 1 then do:
    v-direction-2 = entry(2, v-direction, {&delim-par}).
    v-direction = entry(1, v-direction, {&delim-par}).
    /*если закрытие НЕ ТОЧНО НА НУЖНЫЙ СТАТУС!*/
    if v-direction-2 <> "to"
    and v-direction-2 <> "from" then return "return".
    if v-direction = {&open-doc}
    and v-direction-2 = "to" then return "return".
/*    if v-direction = {&close-doc}*/
/*    and v-direction-2 = "from" then return "return".*/
  end.

  if v-direction = {&open-doc}
  or v-direction = {&deletion}
  or (v-direction = {&close-doc} and v-newbh::status_ = {&fact} )
  then do:
    v-action = {&gen-line-delete}.
  end.
  else do:
    v-action = {&gen-line-update}.
  end.

  for each buf_rule-call-param no-lock where
  buf_rule-call-param.codex_id = p-codex-id
  and buf_rule-call-param.ruleset_id = p-ruleset-id
  and buf_rule-call-param.call_id = p-call-id
  and buf_rule-call-param.order_id = p-order-id
  and buf_rule-call-param.rule_id = p-rule-id
  and buf_rule-call-param.param-name = "p-esys-id-list",
    first buf_ext-system no-lock where
          buf_Ext-system.esys-id = buf_rule-call-param.param-value-integer
      and buf_Ext-system.db-num = 0
      and buf_Ext-system.esys-have-export = yes
      and buf_Ext-system.esys-db-num-exp = g#db-num:
    v-esys-id-list-start = v-esys-id-list-start + (if v-esys-id-list-start = '' then '' else {&delim-nws}) + string(buf_ext-system.esys-id).
  end.
  if v-esys-id-list-start = '' then return "return".

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