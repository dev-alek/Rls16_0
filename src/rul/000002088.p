block-level on error undo, throw.
/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 23

Автор: Мазуров Виталий Александрович
Дата создания: 08/01/11
Author: Mazurov Vitaliy
Creation date: 08/01/11

---------------------------&start-codex_id=23;ruleset_id=1;-------------------------------
Автоматический расчет заказов
---------------------------&end-codex_id=23;ruleset_id=1;-------------------------------
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
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 23, набор 1".

{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ rul/cl-hist.i "shared" }
{ gbl/key-rec.i }

{ cmp/str-glbl.i }
{ cus/df-zakaz.i new }
{ cmp/r-page1.i new }
{ cmp/r-pril.i  new  }
{ rep/repfrm.i def   }

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-doc-code as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable log-file-name                as character      no-undo init "calc-ord.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-last-error-message as character no-undo .
/*****************************/
define variable file-name as char.
define variable v-sign as integer no-undo .
define variable num-rec as integer no-undo .
define variable num-rec-ok as integer no-undo .
define variable v-type as character no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-clients as character no-undo init ''.

{ str/dia2auto.i }
{ rul/seterror.i }

/*библиотека для автозаказов*/
{ rul/auto-ordf.i }

/*---------------------------&start-rule-call-param&-------------------------------*/
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

/* ------------------------- &start-def-vars& -----------------------------------*/
/* ------------------------- &end-def-vars& -----------------------------------*/
if not this-procedure:persistent then do:
  run proc-main in this-procedure no-error .
  if error-status:error then do:
    v-esm = error-status :get-message (1).
    v-es = error-status:error .
    v-rv = return-value .
  end.
  if p-ruleset-id = 1
  then do:
    { str/cdviewlg.i  "'!!!При работе произошли ошибки!!!'"   log-file-name not-delete }
  end.
  if v-es then do:
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, v-rv, {&new-line}, v-esm).
  end.
  run garbcoll_clear in this-procedure .
end.

/********************************************************************/
procedure proc-main :
define variable v-i      as integer   no-undo .
define variable v-method as character no-undo .

define buffer buf_dis-some-rule for ub.dis-some-rule .

_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:
    /*перебираем всех клиентов для создания автозаказов*/
    do v-i = 1 to num-entries(v-clients, {&delim-par}) :
        { rul/auto-ord.i 1 {&O-P} }
    end. /*do*/
end. /*doe _main*/
end procedure. /* proc-main */
/********************************************************************/

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .

define buffer buf_rule-call-param for ub.rule-call-param .

do
on error undo, return error
:
/*---------------------------&start-process-rule-call-param&-------------------------------*/

 for each buf_rule-call-param no-lock
  where buf_rule-call-param.codex_id = p-codex-id
    and buf_rule-call-param.ruleset_id = p-ruleset-id
    and buf_rule-call-param.call_id = p-call-id
    and buf_rule-call-param.order_id = p-order-id
    and buf_rule-call-param.rule_id = p-rule-id
    and buf_rule-call-param.param-name = "p-client"
    and buf_rule-call-param.p-index > 0
 :
    if v-clients = '' then v-clients = v-clients + buf_rule-call-param.param-value-character .
    else v-clients = v-clients + {&delim-par} + buf_rule-call-param.param-value-character .
 end.

/*---------------------------&end-process-rule-call-param&-------------------------------*/
    case p-ruleset-id:
      when 1
      then do:
        assign
        v-sign = 2
        v-current-host-code = p-host-code
        v-current-obj-type = p-obj-type
        v-current-obj-code = p-obj-code
        v-current-db-num = g#db-num
        v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
        .
      end.
   end case.
end. /*doe*/

end procedure. /* load-ruleset-context */


/*не удалять!!!!*/