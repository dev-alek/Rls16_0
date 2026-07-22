block-level on error undo, throw.
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
{ gbl/key-rec.i }
{ str/statq.i }
{ str/partolib.i }

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
define variable log-file-name                as character      no-undo init "process-thref.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-last-error-message as character no-undo .
/*****************************/
define variable file-name as char.
define variable v-sign as integer no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable l-res as integer no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-err-mess as character no-undo .
define variable v-action as character no-undo .
define variable v-doc-code          as character  no-undo .
define variable v-ext-doc-type      as character  no-undo .
define variable v-trn-doc-obj-type  as character  no-undo .
define variable v-trn-doc-obj-code  as integer    no-undo .
define variable v-trn-doc-cli-type as character no-undo .
define variable v-trn-doc-cli-code as integer no-undo .
define variable v-trn-doc-doc-type as character no-undo .
define variable v-obj-db-num        as integer    no-undo .


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

define variable v-err               as logical    no-undo .
define variable v-rsrv-code as character no-undo .
define variable v-unrv-code as character no-undo .
define variable v-need-rsrv as logical   no-undo .
define variable v-need-unrv as logical   no-undo .
define variable v-rsrv-sign as integer   no-undo .
define variable v-unrv-sign as integer   no-undo .

define variable v-action as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-value as character no-undo .
define variable v-deleted as logical no-undo .
define buffer buf_doc-line for ub.doc-line.
define buffer buf_parts for ub.parts.
define buffer free_parts for ub.parts.
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_goods for ub.goods.



/* ------------------------- &end-hn-option& -----------------------------------*/
  /* ------------------------- &start-rule& -----------------------------------*/

for each buf_doc-line no-lock where
        buf_doc-line.doc-code = v-doc-code,
  first  buf_gds-obj no-lock where
        buf_gds-obj.obj-type = v-trn-doc-obj-type
    and buf_gds-obj.obj-code = v-trn-doc-obj-code
    and buf_gds-obj.artic = buf_doc-line.artic
    and buf_gds-obj.prod-type = buf_doc-line.prod-type
    and buf_gds-obj.prod-code = buf_doc-line.prod-code
    :
  if buf_gds-obj.cash-parts = no then next.
  FOR EACH buf_parts NO-LOCK WHERE
          buf_parts.artic = buf_doc-line.artic AND
          buf_parts.prod-type = buf_doc-line.prod-type AND
          buf_parts.prod-code = buf_doc-line.prod-code AND
          buf_parts.out-code = v-doc-code AND
          buf_parts.obj-type = buf_doc-line.obj-type AND
          buf_parts.obj-code = buf_doc-line.obj-code:
    find first free_parts no-lock where
          free_parts.obj-type = buf_parts.obj-type
        and free_parts.obj-code = buf_parts.obj-code
        and free_parts.artic = buf_parts.artic
        and free_parts.prod-type = buf_parts.prod-type
        and free_parts.prod-code = buf_parts.prod-code
        and free_parts.in-code = buf_parts.in-code
        and free_parts.part-code = buf_parts.part-code
        and free_parts.out-code  = {&free-code}
        and free_parts.status_   = false no-error.
    if available free_parts then do:
       /*удалим атрибут*/
      { str/partodel.i
        buf_parts.obj-type
        buf_parts.obj-code
        buf_gds-obj.gds-code
        buf_parts.prt-code
        buf_parts.in-code
        {&output-code}
        "''"
        {&partoatr-parts-end}
        v-deleted
        }
    end.
    else do:
     if v-action = {&deletion} then do:
        assign
        v-unrv-code = ''
        v-need-unrv = no.

        if buf_parts.fact-qnty <> 0
        then do:
          define variable v-create-part as logical   no-undo .
          define variable v-old-return  as logical   no-undo .
          assign
            v-create-part = false
            v-old-return  = false
          .
          if buf_parts.in-code = v-doc-code
          then do:
            assign
              v-create-part = true
            .
            if buf_parts.supp-type <> { trg/partsprm.i "supp-type" "v-trn-doc-" }
            or buf_parts.supp-code <> { trg/partsprm.i "supp-code" "v-trn-doc-" }
            then do:
              assign
                v-old-return = true
              .
            end.
          end.

          define variable v-is-hold as logical   no-undo .
          { gbl/hold-doc.i
            v-doc-code
            v-is-hold
            no-error
          }
          if error-status :error
          then do:
            &scop my-mess substitute("&1 &2 &3&4Ошибка при определении типа документа hold-doc.i&4" +  ~
                                      "Документ &5 &6&7&4&8&4&9" ~
                                      ,vss-workfile           ~
                                      ,vss-revision           ~
                                      ,vss-description        ~
                                      ,~{&new-line~}  ~
                                      ,v-doc-code     ~
                                      ,v-trn-doc-obj-type ~
                                      ,v-trn-doc-obj-code  ~
                                      , error-status:get-message(1) ~
                                      , return-value )
            undo, return error {&my-mess}.
          end.

          { gbl/partcond.i
            v-ext-doc-type
            v-is-hold
            buf_parts.fact-qnty
            v-create-part
            v-old-return
            v-rsrv-code
            v-unrv-code
            v-need-rsrv
            v-need-unrv
            v-rsrv-sign
            v-unrv-sign
            no-error
          }
          if error-status :error
          then do:
            &scop my-mess substitute("&1 &2 &3&4Ошибка при определении параметров резервирования партии.i&4" +   ~
                              "Документ &5 &6&7&4&8&4&9"  ~
                             , vss-workfile              ~
                             ,vss-revision               ~
                             ,vss-description            ~
                             ,~{&new-line~} ~
                             ,v-doc-code    ~
                             ,v-trn-doc-obj-type ~
                             ,v-trn-doc-obj-code  ~
                             , error-status:get-message(1) ~
                             , return-value )
            undo, return error {&my-mess}.
          end.
        end.
        if v-need-unrv
        and v-unrv-code = {&free-code} then do:
           { str/partodel.i
           buf_parts.obj-type
           buf_parts.obj-code
           buf_gds-obj.gds-code
           buf_parts.prt-code
           buf_parts.in-code
           {&output-code}
           "''"
           {&partoatr-parts-end}
           v-deleted
           }
        end.
      end.
     else do:
        /*добавим атрибут*/
      run cur-time in this-procedure ( output v-today, output v-time).
      v-value = substitute("&1-&2-&3", string(year(v-today),"9999"), string(month(v-today), "99"), string(day(v-today), "99")).
      { str/partowrt.i
        buf_parts.obj-type
        buf_parts.obj-code
        buf_gds-obj.gds-code
        buf_parts.prt-code
        buf_parts.in-code
        buf_parts.out-code
        {&output-code}
        {&partoatr-parts-end}
        v-value
        }
      end.
    end.
  end. /*  FOR EACH buf_parts NO-LOCK WHERE*/
end.

  /* ------------------------- &end-rule& -------------------------------------*/

  /* ------------------------- &start-release-obj& -----------------------------------*/


  /* ------------------------- &end-release-obj& -------------------------------------*/

end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define variable v-flag as logical no-undo .
define variable v-ii as integer no-undo .
define variable v-changes-list2 as character no-undo .
define variable v-obj-db-num as integer no-undo .
define variable v-is-waiting-status as logical no-undo .
define variable v-direction as character no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_clients for ub.clients.
do
on error undo, return error
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
    when 115 then do:
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
  if v-has-newbh then do:
    v-trn-doc-obj-type = v-newbh::obj-type.
    v-trn-doc-obj-code = v-newbh::obj-code.
    v-doc-code = v-newbh:buffer-field("doc-code"):buffer-value.
    v-ext-doc-type = v-newbh:buffer-field("ext-doc-type"):buffer-value.
    assign
    v-trn-doc-doc-type = v-newbh::doc-type
    v-trn-doc-cli-type = v-newbh::cli-type
    v-trn-doc-cli-code = v-newbh::cli-code
    v-trn-doc-doc-type = v-newbh::doc-type
    .
  end.
  else do:
    v-trn-doc-obj-type = v-oldbh::obj-type.
    v-trn-doc-obj-code = v-oldbh::obj-code.
    v-doc-code = v-oldbh:buffer-field("doc-code"):buffer-value.
    v-ext-doc-type = v-oldbh:buffer-field("ext-doc-type"):buffer-value.
    assign
    v-trn-doc-doc-type = v-oldbh::doc-type
    v-trn-doc-cli-type = v-oldbh::cli-type
    v-trn-doc-cli-code = v-oldbh::cli-code
    v-trn-doc-doc-type = v-oldbh::doc-type.
    v-action = {&deletion}.
  end.
  { gbl/objdbnum.i v-trn-doc-obj-type v-trn-doc-obj-code v-obj-db-num }
  if g#db-num <> 0 and v-obj-db-num <> g#db-num then do:
    return 'return'.
  end.



  /*---------------------------&start-process-rule-call-param&-------------------------------*/
  for each buf_rule-call-param no-lock where
  buf_rule-call-param.codex_id = p-codex-id
  and buf_rule-call-param.ruleset_id = p-ruleset-id
  and buf_rule-call-param.call_id = p-call-id
  and buf_rule-call-param.order_id = p-order-id
  and buf_rule-call-param.rule_id = p-rule-id
  and buf_rule-call-param.param-name = "p-objects"
  and buf_rule-call-param.p-index > 0
  :
    if buf_rule-call-param.param-value-character = v-trn-doc-obj-type + string(v-trn-doc-obj-code) then leave.
  end.
  if not available buf_rule-call-param then return "return".
    run statq_has-waiting-stat in this-procedure (
                                                  input v-oldbh
                                                 ,input v-newbh
                                                 ,input v-changes-list
                                                 ,input {&fact}
                                                 ,input ?  /*waiting-flag_*/
                                                 ,input 0 /*p-stati*/
                                                 ,output v-is-waiting-status
                                                 ,output v-direction
                                                 ) no-error.

  if v-is-waiting-status = no then return "return".



/*---------------------------&end-process-rule-call-param&-------------------------------*/

end. /*doe*/

end procedure. /* load-ruleset-context */