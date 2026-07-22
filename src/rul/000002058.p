block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 11, набор 10

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/12/09
Author: Bakhtadze Natalya
Creation date: 10/12/09

---------------------------&start-codex_id=11;ruleset_id=10;-------------------------------
Операции с товарами
Операции с товарами в автоматическом режиме
---------------------------&end-codex_id=11;ruleset_id=10;-------------------------------

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
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 11, набор 10".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }
{ gbl/key-rec.i }
{ cmp/obj-list.i new }
{ str/runanlst.i }
{ cmp/pbc-list.i pbc-list def  "new" }
{ cmp/bc-list.i bc-list def  "new" }


/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-gds-code as integer no-undo .
define variable v-current-artic as character no-undo .
define variable v-current-prod-type as character no-undo .
define variable v-current-prod-code as integer no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-doc-code as character no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .
define variable log-file-name                as character      no-undo init "shd-free.log".
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
define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define stream ext-file.

{ str/dia2auto.i }
{ rul/seterror.i }

&scop display-message ~
          if valid-handle(p-log-handle) then ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)


&scop send-message ~
          if valid-handle(p-log-handle) then ~
          run send-msg-to-email in p-log-handle ( ~
                input substitute( "ТН БД &1. Операции с товарами в автоматическом режиме - пересылка/удаление на кассу/с укассы" ~
                                        , g#db-num) ~
              , input ~{&my-message} ~
              , input ~{&attach-file-list}~)



/*---------------------------&start-rule-call-param&-------------------------------*/

  define variable p-keep-days as integer no-undo.
  define variable p-luft-days as integer no-undo.

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

define variable v-err as logical no-undo .
define variable v-action as character no-undo .
define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define variable v-ii as integer no-undo .
define variable v-host-code as integer no-undo .
define buffer buf_goods for ub.goods.
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-start-date as date no-undo .
define variable v-end-date as date no-undo .
define variable v-start-date-str as character no-undo .
define variable v-end-date-str as character no-undo .
define buffer buf_parts-obj-attr for ub.parts-obj-attr.



/* ------------------------- &end-hn-option& -----------------------------------*/
/* ------------------------- &start-rule& -----------------------------------*/

v-action = "D".

for each obj-list where obj-list.obj-type = {&shop} /*на всякйи пожарный*/
break
by obj-list.obj-type
by obj-list.obj-code
:

  for each bc-list:
    delete bc-list.
  end.
  for each pbc-list:
    delete pbc-list.
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  v-end-date = v-today - p-keep-days.
  v-start-date = v-end-date - p-luft-days.
  v-start-date-str = substitute("&1-&2-&3", string(year(v-start-date), "9999")
                                           , string(month(v-start-date), "99")
                                           , string(day(v-start-date), "99")).
  v-end-date-str = substitute("&1-&2-&3", string(year(v-end-date), "9999")
                                         ,string(month(v-end-date), "99")
                                         ,string(day(v-end-date), "99")).

  for each buf_parts-obj-attr no-lock where
               buf_parts-obj-attr.obj-type  = obj-list.obj-type
           and buf_parts-obj-attr.obj-code  = obj-list.obj-code
           and buf_parts-obj-attr.attr-code = {&partoatr-parts-end}
           and buf_parts-obj-attr.attr-value >= v-start-date-str
           and buf_parts-obj-attr.attr-value < v-start-date-str:
    run create-bc-list in this-procedure ( input buf_parts-obj-attr.gds-code
                                          ,buffer buf_parts-obj-attr) no-error.
  end.
  if can-find(first bc-list no-lock) then do:
      run str/diallog.w ( input parparentproc
                    , input this-procedure
                    , input 'str/send-bcn.p':U
                    , input (string(obj-list.obj-code) + {&delim-par} + v-action)
                    , input yes /*p-auto-go*/
                    , input ''
                    , input (if v-action = "U"
                            then 'Отсылка баркодов на кассу'
                            else 'Удаление баркодов с кассы'
                            )) no-error .
      if error-status:error
      or v-view-log
      then do:
        &scop my-message  substitute( " Ошибка отсылки/удаления на кассу/с кассы кодов закончившихся партий по расписанию: Ошибка в процессе отсылки на кассы маг&1"  ~
                                        , obj-list.obj-code )
        v-full-path = ''.
        run gbl/filename.p (
                      input "send-cd.txt"
                      ,output v-full-path
                      ,output v-path
                      ,output v-file-name
                      ,output v-file-name-no-ext
                      ,output v-file-name-ext
                      ) no-error .

        &scop attach-file-list v-full-path
        {&display-message}.
        {&send-message}.
        OS-DELETE value(v-full-path).
      end.
      if can-find(first pbc-list no-lock) then do:
        run str/diallog.w ( input parparentproc
                      , input this-procedure
                      , input 'str/s-prdbcn.p':U
                      , input (string(obj-list.obj-code) + {&delim-par} + v-action)
                      , input yes /*p-auto-go*/
                      , input ''
                      , input (if v-action = "U"
                              then 'Отсылка ДопБК на кассу'
                              else 'Удаление ДопБК с кассы'
                              )) no-error .
        if error-status:error
        or v-view-log
        then do:
          &scop my-message  substitute( " Ошибка отсылки/удаления на кассу/с кассы ДопБК кодов закончившихся партий по расписанию: Ошибка в процессе отсылки на кассы маг&1"  ~
                                          , obj-list.obj-code )
          v-full-path = ''.
          run gbl/filename.p (
                        input "send-cd.txt"
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .

          &scop attach-file-list v-full-path
          {&display-message}.
          {&send-message}.
          OS-DELETE value(v-full-path).
        end.
      end.
  end. /*if can-find(first bc-list no-lock) then do:*/
  else do:
    &scop my-message substitute(" При отсылке/удалении на кассу/с кассы кодов закончившихся партий по расписанию не было обнаружено кодов партий для удаления для маг&1", obj-list.obj-code)
    {&display-message}.
  end.
end. /*for each obj-list:*/


    /* ------------------------- &end-rule& -------------------------------------*/

    /* ------------------------- &start-release-obj& -----------------------------------*/

    /* ------------------------- &end-release-obj& -------------------------------------*/

end. /*doe _main*/
end procedure. /* proc-main */

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_clients for ub.clients.

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
and buf_rule-call-param.param-name = "p-keep-days"
 no-error.
if available buf_rule-call-param then do:
  assign p-keep-days = buf_rule-call-param.param-value-integer.
end.

  find first buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-luft-days"
 no-error.
if available buf_rule-call-param then do:
  assign p-luft-days = buf_rule-call-param.param-value-integer.
end.



for each buf_rule-call-param no-lock where
buf_rule-call-param.codex_id = p-codex-id
and buf_rule-call-param.ruleset_id = p-ruleset-id
and buf_rule-call-param.call_id = p-call-id
and buf_rule-call-param.order_id = p-order-id
and buf_rule-call-param.rule_id = p-rule-id
and buf_rule-call-param.param-name = "p-shops"
and buf_rule-call-param.p-index > 0:
  create buf_temp-rule-call-param.
  buffer-copy buf_rule-call-param to buf_temp-rule-call-param.
  release buf_temp-rule-call-param.
end.


  for each buf_temp-rule-call-param where
        buf_temp-rule-call-param.param-name = "p-shops":
    find first buf_clients no-lock
      where buf_clients.obj-type  = {&shop}
        and buf_clients.obj-code = buf_temp-rule-call-param.param-value-integer
    no-error.
    if not available buf_clients
    then do:
        &scop my-message  substitute( " Ошибка отсылки/удаления на кассу/с кассы списка товаров по расписанию&3: Не найден заданный объект &1&2"  ~
                                        , ~{&shop~} ~
                                        , buf_temp-rule-call-param.param-value-integer ~
                                        , ~{&new-line~})
        &scop attach-file-list ''
        {&display-message}.
        {&send-message}.
        undo, return error .
    end.
    else do:
      if buf_clients.db-num = g#db-num
      and buf_clients.obj-type = {&shop}
      then do:
        run create_obj-list in this-procedure ( input buf_clients.obj-type
                                                ,input buf_clients.obj-code).
      end.
    end.
  end.

/*---------------------------&end-process-rule-call-param&-------------------------------*/

    case p-ruleset-id:
      when 10 then do:
      end.
      otherwise do:
        undo, return error substitute("Вызов процедуры &1 в неверном контексте", p-rule-id).
      end.
    end case.


end. /*doe*/

end procedure. /* load-ruleset-context */


procedure cb_set-view-log :
define input parameter p-view-log as logical no-undo .

v-view-log = yes.
end procedure. /* cb_set-view-log */


procedure create-bc-list :
define input parameter p-gds-code as integer no-undo .
define parameter buffer buf_parts-obj-attr for ub.parts-obj-attr.
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define buffer buf_bar-code for ub.bar-code.
define buffer buf_prod-bc for ub.prod-bc.
define buffer buf_goods for ub.goods.

find first buf_goods no-lock where
          buf_goods.gds-code = p-gds-code no-error.
if not available buf_goods then do:
end.

find first buf_bar-code no-lock where
          buf_bar-code.gds-code = p-gds-code
      and buf_bar-code.in-code = buf_parts-obj-attr.in-code
      and buf_bar-code.part-code = buf_parts-obj-attr.part-code
      and buf_bar-code.unit-cli = buf_goods.unit-base
      /*and buf_bar-code.node-code = buf_parts-obj-attr.prt-code*/
            no-error.
if not available buf_bar-code then do:

end.
create bc-list.
buffer-copy buf_bar-code to bc-list
assign
bc-list.del = yes
.
for each buf_prod-bc no-lock where
        buf_prod-bc.b-code = buf_bar-code.b-code
    and buf_prod-bc.bc-on = yes:
  create pbc-list.
  buffer-copy buf_prod-bc to pbc-list
  assign
  pbc-list.del = yes
  .
  release pbc-list.
end.
release bc-list.


end procedure. /* create-bc-list */