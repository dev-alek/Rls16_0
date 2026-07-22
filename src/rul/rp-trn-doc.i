/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл для кодекса правил 7

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/08/06
Author: Bakhtadze Natalya
Creation date: 10/08/06


*/

/*---------------------------&start-using-class&-------------------------------*/


/*---------------------------&end-using-class&---------------------------------*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-is-dynamic as logical no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-ext-doc-type as character no-undo .
define input parameter p-host-code like ub.trn-doc.host-code no-undo .
define input parameter p-obj-type  like ub.trn-doc.obj-type no-undo .
define input parameter p-obj-code  like ub.trn-doc.obj-code no-undo .
define input parameter p-doc-code  like ub.trn-doc.doc-code no-undo .
define input parameter p-doc-date  like ub.trn-doc.doc-date no-undo .
define input parameter p-save       as integer no-undo .
define input parameter v-curr-r-b   as character no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Библиотека процедур для работы с кодексом 7".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }

{ nws/lib-nws.i }
&glob cmd-proc-handle p-cmd-proc-handle
&glob cmd-code p-cmd-code
{ nws/temp-cmd.i "SHARED" }
{ rul/cl-hist.i "shared" }

{ rul/library-cls.i "non-class-part"  }

/*переменные контекста*/
/*это у нас объект 0*/
define variable v-current-d-card as character no-undo .
define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-cli-type as character no-undo .
define variable v-current-cli-code as integer no-undo .
define variable v-current-print-rubl as logical   no-undo .
define variable v-current-doc-type as character no-undo .
define variable v-current-ext-doc-type as character no-undo .
define variable v-current-artic as character no-undo .
define variable v-current-prod-type as character no-undo .
define variable v-current-prod-code as integer   no-undo .
define variable v-current-node-code as integer   no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-current-doc-code as character no-undo .
define variable v-current-doc-date as date no-undo .
define variable v-current-doc-time as integer no-undo .
define variable v-current-document-code as character no-undo .
define variable v-current-date as date no-undo .
define variable v-last-error-message as character no-undo .
/*****************************/
define variable v-sign as integer no-undo .

{ rul/seterror.i }

define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_temp-cmd for temp-cmd.
define buffer buf_trn-doc for ub.trn-doc.



/* ------------------------- &start-i-script& -----------------------------------*/


/* ------------------------- &end-i-script& -----------------------------------*/

on delete of this-procedure do:
  run garbcoll_clear in this-procedure .
end.



&scop sign v-sign *

run load-ruleset-context in this-procedure ( input p-ruleset-id).

if not this-procedure:persistent then do:
  run proc-main in this-procedure  no-error .
  if error-status:error then do:
      run garbcoll_clear in this-procedure .
      undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
  end.
  run garbcoll_clear in this-procedure .
end.

/*---------------------------&start-rule-block&-------------------------------*/

/*---------------------------&start-codex_id=7;ruleset_id=1& -----------------*/

procedure r_7_1_ :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter v-current-artic as character no-undo .
define input parameter v-current-prod-type as character no-undo .
define input parameter v-current-prod-code as integer no-undo .
define input parameter v-current-node-code as integer no-undo .
define buffer buf_gds-dtl for ub.gds-dtl.

/* ------------------------- &start-def-vars& -----------------------------------*/


/* ------------------------- &end-def-vars& -----------------------------------*/

/*---------------------------&start-rule-call-param&-------------------------------*/


/*---------------------------&end-rule-call-param&-------------------------------*/

/*---------------------------&start-process-rule-call-param&-------------------------------*/


/*---------------------------&end-process-rule-call-param&-------------------------------*/

_main:
do
on error undo, return error return-value
:

  for each buf_gds-dtl no-lock where
          buf_gds-dtl.doc-code = buf_trn-doc.doc-code
    and (buf_gds-dtl.artic = v-current-artic
        and
        buf_gds-dtl.prod-type = v-current-prod-type
        and
        buf_gds-dtl.prod-code = v-current-prod-code
        and
        buf_gds-dtl.prt-code = v-current-node-code)
       )
  on error undo, return error return-value
  :
    /* ------------------------- &start-rule& -----------------------------------*/


    /* ------------------------- &end-rule& -------------------------------------*/

    /* ------------------------- &start-release-obj& -----------------------------------*/


    /* ------------------------- &end-release-obj& -------------------------------------*/
  end.
end. /*doe _main*/
end procedure. /* rule- */


/*---------------------------&end-codex_id=7;ruleset_id=1& -----------------*/


/*---------------------------&start-codex_id=7;ruleset_id=2& -----------------*/

procedure r_7_2_ :
define input parameter p-codex-id as integer no-undo .
define input parameter p-ruleset-id as integer no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define buffer buf_gds-dtl for ub.gds-dtl.

/* ------------------------- &start-def-vars& -----------------------------------*/


/* ------------------------- &end-def-vars& -----------------------------------*/

/*---------------------------&start-rule-call-param&-------------------------------*/


/*---------------------------&end-rule-call-param&-------------------------------*/

/*---------------------------&start-process-rule-call-param&-------------------------------*/


/*---------------------------&end-process-rule-call-param&-------------------------------*/

_main:
do
on error undo, return error return-value
:

  for each buf_gds-dtl no-lock where
          buf_gds-dtl.doc-code = buf_trn-doc.doc-code
  on error undo, return error return-value
  :
    assign
    v-current-artic = buf_gds-dtl.artic
    v-current-prod-type = buf_gds-dtl.prod-type
    v-current-prod-code = buf_gds-dtl.prod-code
    v-current-node-code = buf_gds-dtl.prt-code
    .

    /* ------------------------- &start-rule& -----------------------------------*/


    /* ------------------------- &end-rule& -------------------------------------*/

    /* ------------------------- &start-release-obj& -----------------------------------*/


    /* ------------------------- &end-release-obj& -------------------------------------*/
  end.
end. /*doe _main*/
end procedure. /* rule- */


/*---------------------------&end-codex_id=7;ruleset_id=2& -----------------*/


/*---------------------------&end-rule-block&-------------------------------*/

procedure load-ruleset-context :
define input parameter p-ruleset-id as integer no-undo .
define buffer buf_rule-call-param for ub.rule-call-param.

  do
  on error undo, return error
  :
    find first buf_trn-doc no-lock where
              buf_trn-doc.doc-code = p-doc-code .
    assign
    v-current-host-code = p-host-code
    v-current-obj-type = p-obj-type
    v-current-obj-code = p-obj-code
    v-current-db-num = g#db-num
    v-current-lock = (if p-save >= 0 then exclusive-lock else no-lock)
    v-current-doc-code = p-doc-code
    v-current-doc-date = p-doc-date
    v-current-date = p-doc-date
    v-current-document-code = p-doc-code
    v-current-cli-type = buf_trn-doc.cli-type
    v-current-cli-code = buf_trn-doc.cli-code
    v-current-d-card = buf_trn-doc.d-card
    v-current-print-rubl = buf_trn-doc.print-rubl
    v-current-node-code = p-node-code
    v-sign =(if buf_trn-doc.doc-type = {&expense}
             then 1
             else -1)
    .
  end. /*doe*/

end procedure. /* load-ruleset-context */

/*не удалять!!!!*/