block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 18 набор правил 8

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/04/10
Author: Bakhtadze Natalya
Creation date: 08/04/10


---------------------------&start-codex_id=18;ruleset_id=8;-----------------
Импорт данных по заказам

---------------------------&end-codex_id=18;ruleset_id=8;-----------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 18 набор правил 8".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
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
{ cus/exiteedi-desadv.i -t }
{ cus/cr-edist.i }
&undefine cr-edist_i
{ cus/cr-edist.i  tt }
{ cus/edocsord.i edi position-t proc-edi-gen-rcv }
{ ref/extclass.i }
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
define variable v-dm-edi    as integer   no-undo .


{ rul/seterror.i }
define buffer buf_temp-cmd for temp-cmd.
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.

define buffer buf_temp-xml-tables for temp-xml-tables.


define variable log-file-name                as character      no-undo init "process-edoc.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .


function 00180008_get-error-message returns character :
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
define variable v-doc-uniq-key-rec as character no-undo .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-trn-code as character no-undo .
define variable v-dump-ord-int64 as int64 no-undo .
define variable v-trn-doc as character no-undo .
define variable v-new-ps as character no-undo .
define variable v-new-st as integer no-undo .
define variable v-cli-out-doc as character no-undo .
define variable v-edist-mess as character no-undo .
define variable v-cli-type as character no-undo .
define variable v-cli-code as integer no-undo .
define variable v-date-status as date no-undo .
define variable v-time-status as integer no-undo .
define variable v-transport-cli-type as character no-undo .
define variable v-transport-cli-code as integer no-undo .
define variable v-transport-type-code as logical no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-crc-pack as character no-undo .

define buffer buf_clients for ub.clients.
define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_ext-classif for ub.ext-classif.

&scop full-trans   transaction
&scop single-trans



/* ------------------------- &start-hn-option& -----------------------------------*/





/* ------------------------- &end-hn-option -----------------------------------*/

/* ------------------------- &start-rule& -----------------------------------*/
_desadv:
do transaction
on error  undo _desadv, retry _desadv
on stop   undo _desadv, retry _desadv
on endkey undo _desadv, retry _desadv
:
  if retry then do:
    &scop my-message substitute("Ошибка при импорте поставок по  заказу &1 из ВС &2&3&4" ~
                                ,v-current-doc-code ~
                                , v-esys-id  ~
                                , ~{&new-line~} ~
                                , v-mess)

    {&display-message}.
    assign
    v-view-log = yes.
    undo _desadv, return error.
  end.
  else do:

run write-log  in p-log-handle (
                                 input 0
                               , "&DLine").
&scop my-message substitute(".............Импорт поставок из ВС")
  {&display-message}.
    find first desadv-t.
    num-rec = num-rec + 1.
    find first buf_ord-doc exclusive-lock where
              buf_ord-doc.doc-code = desadv-t.ordernumber no-error.
    if not available buf_ord-doc then do:
      v-mess =  substitute("Не найден заказ поставщику с номером &1", desadv-t.ordernumber).
      assign v-view-log = yes.
      undo _desadv, retry _desadv.
    end.
    assign
    v-current-doc-code = buf_ord-doc.doc-code
    v-cli-type = buf_ord-doc.cli-type
    v-cli-code = buf_ord-doc.cli-code
    .
    find first head-t where
              head-t.number = desadv-t.number no-error.
    v-ediinterchangeid = (if available head-t then head-t.EDIINTERCHANGEID else '').
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
      undo _desadv, retry _desadv.
    end.
    assign
    v-transport-type-code = get-type-code-from-gln ( input head-t.logisticpartner
                                                    , output v-transport-cli-type
                                                    , output v-transport-cli-code
                                                    ) no-error.
    /*TODO проверить что не изменились те поля шапки которые мы отсылали  -иначе retry*/
    run edocsord_edi-import in this-procedure (
                                            buffer buf_ord-doc
                                          ,input buf_ord-doc.cli-out-doc /*p-cli-out-doc*/
                                          ,input desadv-t.number + {&delim-par} +   /*p-trn-doc*/
                                                  string(desadv-t.date, "99/99/9999") +
                                                  (if v-transport-type-code then ({&delim-par} + substitute("&1&2", v-transport-cli-type,
                                                                                                                    v-transport-cli-code ))
                                                                          else "" )
                                          ,input integer({&edi-desadv})
                                          ,input (if desadv-t.deliverydate = ?
                                                  then buf_ord-doc.ship-date
                                                  else desadv-t.deliverydate)
                                          ,input buf_ord-doc.ps
                                          ,input v-pack-num-chr
                                          ,input v-ediinterchangeid
                                          ,output v-new-ps
                                          ,output v-new-st
                                          ) no-error.
    if error-status:error then do:
      if return-value <> '' then do:
        v-mess = substitute("Ошибка при изменении статуса заказа при приеме данных:&1&2", {&new-line}, return-value ).
        undo _desadv, retry _desadv.
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
      v-rv = return-value .
      v-edist-mess = ''.
      v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, {&edist_pack-num}, "->" + v-pack-num-chr ).
      v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, {&edist_ediinterchangeid}, (if available head-t then head-t.EDIINTERCHANGEID else '') ).
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
                                                     else integer({&severity-no-error}))    /* p-err      */
                                            , input buf_ord-doc.PS                      /* p-des      */
                                            , input v-edist-mess                        /* p-mess     */
                                            , input integer({&doc-dm-edi})
                                            , input-output v-date-status
                                            , input-output v-time-status
                                            ).
      if v-new-st = ? then do:
        &scop my-message v-rv
        {&display-message}.
      end.
      _edist:
      for each temp-edi-status
      on error  undo _edist, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo _edist, return error substitute( "&1. stop", vss-workfile )
      on endkey undo _edist, return error substitute( "&1. endkey", vss-workfile )
      :
        v-edist-mess = temp-edi-status.mess.
        v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, {&edist_pack-num}, "->" + v-pack-num-chr ).
        v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, {&edist_ediinterchangeid}, (if available head-t then head-t.EDIINTERCHANGEID else '') ).
        run create-edi-state in this-procedure (
                                                input temp-edi-status.tbl-name            /* p-tbl-name */
                                              , input (if temp-edi-status.tbl-name = {&table_ord-line-rcv}
                                                      then v-new-ps /*там лежи код поставки rcv-code*/
                                                      else temp-edi-status.doc-code)           /* p-doc-code */
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
end. /*for each desadv-t*/
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
      when {&edoc-proc_18_xml-esys-import_rcv_8} then do:
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
        glog = dataset desadv_-t:handle:copy-dataset(v_dataseth
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