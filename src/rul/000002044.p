/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 11, набор 6,7

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/07/09
Author: Bakhtadze Natalya
Creation date: 10/07/09

---------------------------&start-codex_id=11;ruleset_id=6;-------------------------------
---------------------------&start-codex_id=11;ruleset_id=7;-------------------------------
---------------------------&end-codex_id=11;ruleset_id=6;-------------------------------
---------------------------&end-codex_id=11;ruleset_id=7;-------------------------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 11, набор 6,7".
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
{ rul/dtlpbcod.i }

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
define variable log-file-name                as character      no-undo init "process-gds.txt".
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
{ gbl/gaterout.i
  parparentproc
  p-parent-handle
  p-log-handle
  this-procedure:handle
  ExpData1
}

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
:

define variable v-err as logical no-undo .
define variable v-gds-code as integer no-undo .
define variable v-b-code as integer no-undo .
define variable v-unit-cli as character no-undo .
define variable v-cli-base-rate as decimal no-undo .
define variable v-gds-name as character no-undo .
define variable v-alpha1 as character no-undo .
define variable v-b-str as character no-undo .
define variable v-bc-on-type as character no-undo .
define variable varscales-pref as character no-undo .
define variable varpgscales-pref as character no-undo .
define variable v-ii as integer no-undo .
define variable v-b-str-list as character no-undo .
define variable v-in-code as character no-undo .
define variable v-node-code as integer no-undo .
define variable v-nodename as character no-undo .
define variable v-need-part-b-code as logical no-undo .

define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_gds-prt for ub.gds-prt.


/* ------------------------- &end-hn-option& -----------------------------------*/
  /* ------------------------- &start-rule& -----------------------------------*/
  IF  ExpData1:route-data_push-xmlschema( INPUT p-xsd-file ) = false  THEN do:
    undo _main, return error v-last-error-message .
  end.
  case p-ruleset-id:
    when {&goods-proc_11_lcode_6} then do:
      assign
      v-gds-code = (if v-has-newbh
                    then v-newbh:buffer-field("gds-code"):buffer-value
                    else v-oldbh:buffer-field("gds-code"):buffer-value
                    )
      v-b-code = (if v-has-newbh
                  then v-newbh:buffer-field("b-code"):buffer-value
                  else v-oldbh:buffer-field("b-code"):buffer-value
                  )
      v-cli-base-rate = (if v-has-newbh
                  then v-newbh:buffer-field("cli-base-rate"):buffer-value
                  else v-oldbh:buffer-field("cli-base-rate"):buffer-value
                  )
      v-unit-cli = (if v-has-newbh
                  then v-newbh:buffer-field("unit-cli"):buffer-value
                  else v-oldbh:buffer-field("unit-cli"):buffer-value
                  )
      v-in-code = (if v-has-newbh
                  then v-newbh:buffer-field("in-code"):buffer-value
                  else v-oldbh:buffer-field("in-code"):buffer-value
                  )
      v-node-code = (if v-has-newbh
                  then v-newbh:buffer-field("node-code"):buffer-value
                  else v-oldbh:buffer-field("node-code"):buffer-value
                  )
      .
      if v-in-code <> '' then do:
        /*надо выяснить нужен ли партионный баркод - для этого по всем объектам для который епсть привязка надо найти признак продажи по партиям*/
        run dtlpbcod_need-part-b-code in this-procedure ( input v-gds-code
                                               , input v-esys-id-list
                                               , output v-need-part-b-code
                                             ) no-error.
        if v-need-part-b-code = no then return ''.
      end.
      find first buf_gds-prt no-lock where
                buf_gds-prt.node-code = v-node-code no-error.
      if error-status:error then do:
        v-err-mess = substitute("Неизвестный код признака &1 у баркода &1 товар &3"
                                , v-node-code
                                , v-b-code
                                , v-gds-code
                                ).
        undo _main, return error v-err-mess .
      end.
      if not (buf_gds-prt.root = yes
         or buf_gds-prt.is-term = yes) then do:
        return ''.
      end.
      assign
      v-nodename = buf_gds-prt.f-name.
      IF  context_begin-esys-command( input v-esys-id-list
                                    , input-output v-esys-cmd-proc-handle
                                    , output v-esys-cmd-code) = false  THEN do:
        undo _main, return error v-last-error-message .
      end.
      ExpData1:route-data_create-record( INPUT "barcodes") .
      IF ExpData1:esys-add-dump( INPUT "barcodes", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи по товару с кодом  &1:&2&3"
                                , v-gds-code
                                , {&new-line}
                                , v-last-error-message
                                ).
        undo _main, return error v-last-error-message .
      end.
      ExpData1:route-data_copy-field-character( INPUT "barcodes", "BC", INPUT  string(v-b-code) ) .
      /*у нас один баркод - один товар!!!*/
      ExpData1:route-data_copy-field-integer( INPUT "barcodes", "GoodsID", INPUT  v-gds-code ) .
      ExpData1:route-data_copy-field-decimal( INPUT "barcodes", "Price", INPUT  0 ) .
      ExpData1:route-data_copy-field-character( INPUT "barcodes", "Unit", INPUT  v-unit-cli ) .
      ExpData1:route-data_copy-field-decimal( INPUT "barcodes", "CUnit", INPUT  v-cli-base-rate ) .
      ExpData1:route-data_copy-field-character( INPUT "barcodes", "Action", INPUT  v-action ) .
      ExpData1:route-data_copy-field-character( INPUT "barcodes", "NodeName", INPUT  v-nodename ) .
      IF ExpData1:esys-add-dump( INPUT "barcodes", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
        v-err-mess = substitute("Ошибка при маршрутизации записи баркода/ДопБК с кодом &1:&2&3"
                                , v-newbh::b-code
                                , {&new-line}
                                , v-last-error-message
                                ).
        undo _main, return error v-last-error-message .
      end.
      IF  context_send-esys-command( input v-esys-id-list
                                  , input v-esys-cmd-proc-handle
                                  , input v-esys-cmd-code
                                  , input g#userid) = false  THEN do:
        undo _main, return error v-last-error-message .
      end.
      &scop release_1 clear-data ( )
      ExpData1:Route-data_{&release_1} .
    end.
    when {&goods-proc_11_prcode_7} then do:
      assign
      v-b-code = (if v-has-newbh
                  then v-newbh:buffer-field("b-code"):buffer-value
                  else v-oldbh:buffer-field("b-code"):buffer-value
                  )
      v-b-str = (if v-has-newbh
                  then v-newbh:buffer-field("b-str"):buffer-value
                  else v-oldbh:buffer-field("b-str"):buffer-value
                  )
      v-bc-on-type = (if v-has-newbh
                      then v-newbh:buffer-field("bc-on-type"):buffer-value
                      else v-oldbh:buffer-field("bc-on-type"):buffer-value
                      )
      .

      find first buf_bar-code no-lock where
                buf_bar-code.b-code = v-b-code no-error.
      if not available buf_bar-code then do:
        v-err-mess = substitute("Неизвестный баркод &1 для ДопБК &2"
                                , v-b-code
                                , v-b-str
                                ).
        undo _main, return error v-err-mess .
      end.
      find first buf_gds-prt no-lock where
                buf_gds-prt.node-code = buf_bar-code.node-code no-error.
      if error-status:error then do:
        v-err-mess = substitute("Неизвестный код признака &1 у баркода &1 товар &3"
                                , v-node-code
                                , v-b-code
                                , v-gds-code
                                ).
        undo _main, return error v-err-mess .
      end.
      if not (buf_gds-prt.root = yes
         or buf_gds-prt.is-term = yes) then do:
        return ''.
      end.
      assign
      v-nodename = buf_gds-prt.f-name.
      assign
      v-unit-cli = buf_bar-code.unit-cli
      v-gds-code = buf_bar-code.gds-code
      v-cli-base-rate = buf_bar-code.cli-base-rate

      .
      if v-bc-on-type = {&loc-sc-code}
      or v-bc-on-type = {&gbl-sc-code}
      or v-bc-on-type = {&loc-pg-code} then do:
        /*надо найти префикс весового кода*/
        { str/sclspref.i varscales-pref varpgscales-pref }
        case v-bc-on-type:
          /*здесь спокойно можно првоерять это поле - оно будет заполнено для всех вновь рождаемых prod-bc -
          а старые в этом месте обрабатываться не могут*/
          when {&loc-sc-code}
          or
          when {&gbl-sc-code} then do:
            do v-ii = 1 to num-entries(varscales-pref):
               assign
               v-b-str-list = v-b-str-list +
                             (if v-b-str-list = '' then '' else {&comma-char}) +
                             entry(v-ii, varscales-pref) + v-b-str.

            end.
          end.
          when {&loc-pg-code} then do:
            /*не могут штучные принять*/
            return ''.
          end.
          otherwise do:
            v-b-str-list = v-b-str.
          end.
        end case.
      end.
      else do:
        v-b-str-list = v-b-str.
      end.
      IF  context_begin-esys-command( input v-esys-id-list
                                    , input-output v-esys-cmd-proc-handle
                                    , output v-esys-cmd-code) = false  THEN do:
        undo _main, return error v-last-error-message .
      end.
      /*баркоды партий не берем пока!!! - это уже отсеено*/
      do v-ii = 1 to num-entries(v-b-str-list):
        ExpData1:route-data_create-record( INPUT "barcodes") .
        IF ExpData1:esys-add-dump( INPUT "barcodes", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '_dump-order=Rec_ID') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи ДопБК &1 (баркод &2):&3&4"
                                  , v-b-str
                                  , v-b-code
                                  , {&new-line}
                                  , v-last-error-message
                                  ).
          undo _main, return error v-last-error-message .
        end.
        ExpData1:route-data_copy-field-character( INPUT "barcodes", "BC", INPUT  entry(v-ii, v-b-str-list) ) .
        /*у нас один баркод - один товар!!!*/
        ExpData1:route-data_copy-field-integer( INPUT "barcodes", "GoodsID", INPUT  v-gds-code ) .
        ExpData1:route-data_copy-field-decimal( INPUT "barcodes", "Price", INPUT  0 ) .
        ExpData1:route-data_copy-field-character( INPUT "barcodes", "Unit", INPUT  v-unit-cli ) .
        ExpData1:route-data_copy-field-decimal( INPUT "barcodes", "CUnit", INPUT  v-cli-base-rate) .
        ExpData1:route-data_copy-field-character( INPUT "barcodes", "Action", INPUT  v-action ) .
        ExpData1:route-data_copy-field-character( INPUT "barcodes", "NodeName", INPUT  v-nodename ) .
        IF ExpData1:esys-add-dump( INPUT "barcodes", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
          v-err-mess = substitute("Ошибка при маршрутизации записи ДопБК &1 (баркод &2):&3&4"
                                  , v-b-str
                                  , v-b-code
                                  , {&new-line}
                                  , v-last-error-message
                                  ).
          undo _main, return error v-last-error-message .
        end.
      end.
      IF  context_send-esys-command( input v-esys-id-list
                                  , input v-esys-cmd-proc-handle
                                  , input v-esys-cmd-code
                                  , input g#userid) = false  THEN do:
        undo _main, return error v-last-error-message .
      end.
    end.
  end case.
  &scop release_1 clear-data ( )
  ExpData1:Route-data_{&release_1} .


  /* ------------------------- &end-rule& -------------------------------------*/

  /* ------------------------- &start-release-obj& -----------------------------------*/


  /* ------------------------- &end-release-obj& -------------------------------------*/

  /*нет удаления схемы!!!!!*/
  /*ExpData1:route-data_clear-xmlschema ( ).*/
end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define variable v-flag as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-changes-list2 as character no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_ext-system for ub.ext-system.

do
on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo , return error substitute( "&1. stop", vss-workfile )
on endkey undo , return error substitute( "&1. endkey", vss-workfile )
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
    when {&goods-proc_11_lcode_6} then do:
      if v-has-newbh
      and v-newbh:table <> {&table_bar-code}
      and v-newbh:table <> "temp-" + {&table_bar-code}
      then do:
        undo, return error substitute("Передан неверный буфер вместо буфера для &1",  {&table_bar-code}).
      end.
      if v-changes-list = ''
      and v-has-newbh
      and v-has-oldbh
      then do:
        v-changes-list2 = "b-code,cli-base-rate".
        do v-ii = 1 to num-entries(v-changes-list2 ):
          if v-oldbh:buffer-field(entry(v-ii, v-changes-list2)):buffer-value <> v-newbh:buffer-field(entry(v-ii, v-changes-list2)):buffer-value then do:
            v-flag = yes.
            leave.
          end.
        end.
        if not v-flag then return "return".
      end.
      else do:
        if v-has-newbh then do:
          if lookup("b-code", v-changes-list) = 0
          and lookup("cli-base-rate", v-changes-list) = 0
          and not(v-newbh:new) then do:
            return 'return'.
          end.
        end.
      end.
      if not v-has-newbh then do:
        v-action = {&gen-line-delete}.
      end.
      else do:
        v-action = {&gen-line-update}.
      end.
    end.
    when {&goods-proc_11_prcode_7} then do:
      if v-has-newbh
      and v-newbh:table <> {&table_prod-bc}
      and v-newbh:table <> "temp-" + {&table_prod-bc}
      then do:
        undo, return error substitute("Передан неверный буфер вместо буфера для &1",  {&table_prod-bc}).
      end.
      if v-changes-list = ''
      and v-has-newbh
      and v-has-oldbh
      then do:
        v-changes-list2 = "b-code,b-str,bc-on".
        do v-ii = 1 to num-entries(v-changes-list2 ):
          if v-oldbh:buffer-field(entry(v-ii, v-changes-list2)):buffer-value <> v-newbh:buffer-field(entry(v-ii, v-changes-list2)):buffer-value then do:
            v-flag = yes.
            leave.
          end.
        end.
        if not v-flag then return "return".
      end.
      else do:
        if v-has-newbh then do:
          if lookup("b-code", v-changes-list) = 0
          and lookup("b-str", v-changes-list) = 0
          and lookup("bc-on", v-changes-list) = 0
          and not(v-newbh:new) then do:
            return 'return'.
          end.
        end.
      end.
      if not v-has-newbh
      or (v-has-newbh
          and v-has-oldbh
          and v-newbh::bc-on = no
          and v-oldbh::bc-on = yes)
      then do:
        v-action = {&gen-line-delete}.
      end.
      else do:
        v-action = {&gen-line-update}.
      end.
    end.
    otherwise do:
      undo, return error substitute("Неверный вызов &1 для набора правил &2", vss-workfile , p-ruleset-id).
    end.
  end case.
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
    v-esys-id-list = v-esys-id-list + (if v-esys-id-list = '' then '' else {&delim-nws}) + string(buf_ext-system.esys-id).
  end.
  if v-esys-id-list = '' then return "return".

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