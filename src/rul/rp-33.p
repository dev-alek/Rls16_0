block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Вспомогательный файл к кодексам правил 15-16-17

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/03/08
Author: Bakhtadze Natalya
Creation date: 08/03/08

*/

/*---------------------------&start-using-class&-------------------------------*/


/*---------------------------&end-using-class&---------------------------------*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-call-id as character no-undo .
define input parameter p-profile-id as integer no-undo .
define input parameter p-once-more as integer   no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-pos-type-for-discnt as character no-undo .
define input parameter log-file-name as character no-undo .
define input parameter p-dr-flddf as handle no-undo .
define input parameter p-bh as handle no-undo extent 6.
/*
define input parameter p-context-bh as handle no-undo .
define input parameter p-chk-context-bh as handle no-undo .
define input parameter p-chk-doc-bh as handle no-undo .
define input parameter p-chk-gds-bh as handle no-undo .
define input parameter p-chk-pay-bh as handle no-undo .
define input parameter p-chk-discnt-bh as handle no-undo .
*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Вспомогательный файл к кодексам правил 15-16-17".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ rul/library-cls.i "non-class-part"  }
{ str/dis-rule_rf.i }
{ str/cdrdcal1.i deftt }
{ str/libthpos_bh-def.i }
{ gbl/printbuffer.i }
{ str/mpl-auto.i }


/*переменные контекста*/
/*это у нас объект 0*/

define variable v-current-host-code as integer no-undo .
define variable v-current-obj-type as character no-undo .
define variable v-current-obj-code as integer no-undo .
define variable v-current-pos-type as character no-undo .
define variable v-current-pos-type-for-discnt as character no-undo .
define variable v-current-lock as integer no-undo .
define variable v-current-wait as integer no-undo .
define variable v-save as integer no-undo .
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-current-db-num as integer no-undo .
define variable v-last-error-message as character no-undo .
define variable v-codex-id as integer   no-undo .
define variable v-ruleset-id as integer   no-undo .
define variable v-caller as character no-undo .
/*define variable v-bh as handle no-undo extent 6.*/

{ rul/seterror.i }

define temp-table temp-rule-call-param no-undo like ub.rule-call-param.
define temp-table temp-rule-by-call no-undo like ub.rule-by-call.
define temp-table temp-discnt-role no-undo like ub.dis-cfg-rule
field codex_id as integer
field ruleset_id as integer
field order_id as integer
field rule_id as integer
field once-more as integer
index pi is unique
primary
codex_id
ruleset_id
order_id
rule_id
pos-type
discnt-role
subject-type
.

&scop display-message ~
          if valid-handle(p-log-handle)            ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~).            ~
          assign v-view-log = yes


/*---------------------------&start-rule-call-param&-------------------------------*/


/*---------------------------&end-rule-call-param&-------------------------------*/


/* ------------------------- &start-i-script& -----------------------------------*/


/* ------------------------- &end-i-script& -----------------------------------*/


on delete of this-procedure do:
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_temp-rule-by-call for temp-rule-by-call.
define buffer buf_temp-discnt-role for temp-discnt-role.
  for each buf_temp-rule-call-param:
    delete buf_temp-rule-call-param.
  end.
  for each buf_temp-rule-by-call:
    delete buf_temp-rule-by-call.
  end.
  for each buf_temp-discnt-role:
    delete buf_temp-discnt-role.
  end.
  { str/cdrdcal1.i clear }
  run garbcoll_clear in this-procedure .
end.


run load-ruleset-context in this-procedure no-error.
if error-status:error then do:
  undo, return error return-value .
end.


procedure rs_15_1 :
define input parameter p-caller as character no-undo .
define input parameter v-gline-num as integer   no-undo .
define input parameter v-b-code as integer   no-undo .
define input parameter v-gds-code as integer   no-undo .
define input parameter v-sum-grp-code as integer no-undo .
define input parameter v-node-code as integer no-undo .
define input parameter v-src-qnty as decimal no-undo .
define input parameter v-doc-qnty as decimal no-undo .
define input parameter v-start-src-price as decimal no-undo .
define input parameter v-src-price as decimal no-undo .
define input parameter v-start-src-discnt as decimal no-undo .
define input parameter v-src-discnt as decimal no-undo .
define input parameter v-unit-base as character no-undo .
define input parameter v-unit-base-type as character no-undo .
define input parameter v-unit-cli as character no-undo .
define input parameter v-unit-cli-type as character no-undo .
define input parameter v-bh as handle no-undo extent 6.
define output parameter v-new-src-price as decimal no-undo .
define output parameter v-new-src-discnt as decimal no-undo .

define buffer buf_temp-rule-by-call for temp-rule-by-call.
define buffer buf_temp-discnt-role for temp-discnt-role.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  assign
  v-codex-id = 15
  v-ruleset-id = 1
  v-caller = p-caller
  v-new-src-price = v-src-price
  v-new-src-discnt = v-src-discnt
  .

  for each buf_temp-rule-by-call where
            buf_temp-rule-by-call.call_id = p-call-id
        and buf_temp-rule-by-call.codex_id = v-codex-id
        and buf_temp-rule-by-call.ruleset_id = v-ruleset-id
        and buf_temp-rule-by-call.profile_id = p-profile-id
        and buf_temp-rule-by-call.once-more = p-once-more
  by buf_temp-rule-by-call.order
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :

    if not (buf_temp-rule-by-call.can-calc and buf_temp-rule-by-call.can-run) then next.

    run value( substitute("r_15_1_&1", buf_temp-rule-by-call.rule_id)) in this-procedure (
              input buf_temp-rule-by-call.order_id
             ,input buf_temp-rule-by-call.rule_id
             ,input v-gline-num
             ,input v-b-code
             ,input v-gds-code
             ,input v-sum-grp-code
             ,input v-node-code
             ,input v-src-qnty
             ,input v-doc-qnty
             ,input v-start-src-price
             ,input v-src-price
             ,input v-start-src-discnt
             ,input v-src-discnt
             ,input v-unit-base
             ,input v-unit-base-type
             ,input v-unit-cli
             ,input v-unit-cli-type
             ,input v-bh
             ,output v-new-src-price
             ,output v-new-src-discnt
             ) no-error.
    if not error-status :error then do:
      assign
      v-src-price = v-new-src-price
      v-src-discnt = v-new-src-discnt
      .

    end.
  end.
end. /*doe*/
end procedure.


/*---------------------------&start-rule-block&-------------------------------*/

/*---------------------------&start-codex_id=15;ruleset_id=1& -----------------*/
/*---------------------------&start-codex_id=15;ruleset_id=1& -----------------*/
procedure r_15_1_1971:
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter v-gline-num as integer   no-undo .
define input parameter v-b-code as integer   no-undo .
define input parameter v-gds-code as integer   no-undo .
define input parameter v-sum-grp-code as integer no-undo .
define input parameter v-node-code as integer no-undo .
define input parameter v-src-qnty as decimal no-undo .
define input parameter v-doc-qnty as decimal no-undo .
define input parameter v-start-src-price as decimal no-undo .
define input parameter v-src-price as decimal no-undo .
define input parameter v-start-src-discnt as decimal no-undo .
define input parameter v-src-discnt as decimal no-undo .
define input parameter v-unit-base as character no-undo .
define input parameter v-unit-base-type as character no-undo .
define input parameter v-unit-cli as character no-undo .
define input parameter v-unit-cli-type as character no-undo .
define input parameter v-bh as handle no-undo extent 6.
define output parameter v-new-src-price as decimal no-undo .
define output parameter v-new-src-discnt as decimal no-undo .
define buffer buf_temp-rule-call-param for temp-rule-call-param.
/* ------------------------- &start-def-vars& -----------------------------------*/
/* ------------------------- &end-def-vars& -----------------------------------*/
/*---------------------------&start-rule-call-param&-------------------------------*/
 define variable p-discnt-roles as character no-undo.
 define variable p-add-discnts as logical no-undo.
/*---------------------------&end-rule-call-param&-------------------------------*/
/*---------------------------&start-process-rule-call-param&-------------------------------*/

 find first buf_temp-rule-call-param no-lock where
buf_temp-rule-call-param.codex_id = v-codex-id
and buf_temp-rule-call-param.ruleset_id = v-ruleset-id
and buf_temp-rule-call-param.call_id = p-call-id
and buf_temp-rule-call-param.order_id = p-order-id
and buf_temp-rule-call-param.rule_id = p-rule-id
and buf_temp-rule-call-param.param-name = "p-add-discnts"
 no-error.
if available buf_temp-rule-call-param then do:
assign p-add-discnts = buf_temp-rule-call-param.param-value-logical.
end.

/*---------------------------&end-process-rule-call-param&-------------------------------*/
_main:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
    /* ------------------------- &start-rule& -----------------------------------*/
  { rul/000001971.i }
    /* ------------------------- &end-rule& -------------------------------------*/
    /* ------------------------- &start-release-obj& -----------------------------------*/
    /* ------------------------- &end-release-obj& -------------------------------------*/
end. /*doe _main*/
end procedure. /* rule- */




/*---------------------------&start-codex_id=16;ruleset_id=1& -----------------*/
/*---------------------------&start-codex_id=16;ruleset_id=1& -----------------*/
procedure rs_16_1 :
define input parameter p-caller as character no-undo .
define input parameter v-line-nums as integer   no-undo .
define input parameter v-start-sum-brutto-r-b as decimal no-undo .
define input parameter v-sum-brutto-r-b as decimal no-undo .
define input parameter v-sum-for-discnt-r-b as decimal no-undo .
define input parameter v-st-discnt-r-b as decimal no-undo .
define input parameter v-bh as handle no-undo extent 6.
define output parameter v-st-r-b as decimal no-undo .
define output parameter v-new-st-discnt-r-b as decimal no-undo .
define output parameter v-new-sum-for-discnt-r-b as decimal no-undo .
define buffer buf_temp-rule-by-call for temp-rule-by-call.
define buffer buf_temp-discnt-role for temp-discnt-role.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  v-codex-id = 16
  v-ruleset-id = 1
  v-caller = p-caller
  .
  assign
  v-st-r-b  = v-sum-brutto-r-b
  v-new-st-discnt-r-b  = v-st-discnt-r-b
  .
  for each buf_temp-rule-by-call where
            buf_temp-rule-by-call.call_id = p-call-id
        and buf_temp-rule-by-call.codex_id = v-codex-id
        and buf_temp-rule-by-call.ruleset_id = v-ruleset-id
        and buf_temp-rule-by-call.profile_id = p-profile-id
        and buf_temp-rule-by-call.once-more = p-once-more
  by buf_temp-rule-by-call.order
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if not (buf_temp-rule-by-call.can-calc and buf_temp-rule-by-call.can-run) then next.
    run value( substitute("r_16_1_&1", buf_temp-rule-by-call.rule_id)) in this-procedure (
              input buf_temp-rule-by-call.order_id
             ,input buf_temp-rule-by-call.rule_id
             ,input v-line-nums
             ,input v-start-sum-brutto-r-b
             ,input v-sum-brutto-r-b
             ,input v-sum-for-discnt-r-b
             ,input v-st-discnt-r-b
             ,input v-bh
             ,output v-st-r-b
             ,output v-new-st-discnt-r-b
             ,output v-new-sum-for-discnt-r-b
             ) no-error.
    if not error-status :error then do:
      assign
      v-sum-brutto-r-b  = v-st-r-b
      v-st-discnt-r-b  = v-new-st-discnt-r-b
      .
    end.
  end.
end. /*doe*/
end procedure.
procedure r_16_1_1972:
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter v-line-nums as integer   no-undo .
define input parameter v-start-sum-brutto-r-b as decimal no-undo .
define input parameter v-sum-brutto-r-b as decimal no-undo .
define input parameter v-sum-for-discnt-r-b as decimal no-undo .
define input parameter v-st-discnt-r-b as decimal no-undo .
define input parameter v-bh as handle no-undo extent 6.
define output parameter v-st-r-b as decimal no-undo .
define output parameter v-new-st-discnt-r-b as decimal no-undo .
define output parameter v-new-sum-for-discnt-r-b as decimal no-undo .
define buffer buf_temp-rule-call-param for temp-rule-call-param.
/* ------------------------- &start-def-vars& -----------------------------------*/
/* ------------------------- &end-def-vars& -----------------------------------*/
/*---------------------------&start-rule-call-param&-------------------------------*/
 define variable p-discnt-roles as character no-undo.
 define variable p-add-discnts as logical no-undo.
/*---------------------------&end-rule-call-param&-------------------------------*/
/*---------------------------&start-process-rule-call-param&-------------------------------*/

 find first buf_temp-rule-call-param no-lock where
buf_temp-rule-call-param.codex_id = v-codex-id
and buf_temp-rule-call-param.ruleset_id = v-ruleset-id
and buf_temp-rule-call-param.call_id = p-call-id
and buf_temp-rule-call-param.order_id = p-order-id
and buf_temp-rule-call-param.rule_id = p-rule-id
and buf_temp-rule-call-param.param-name = "p-add-discnts"
 no-error.
if available buf_temp-rule-call-param then do:
assign p-add-discnts = buf_temp-rule-call-param.param-value-logical.
end.

/*---------------------------&end-process-rule-call-param&-------------------------------*/
_main:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
    /* ------------------------- &start-rule& -----------------------------------*/
  { rul/000001972.i }
    /* ------------------------- &end-rule& -------------------------------------*/
    /* ------------------------- &start-release-obj& -----------------------------------*/
    /* ------------------------- &end-release-obj& -------------------------------------*/
end. /*doe _main*/
end procedure. /* rule- */





/*---------------------------&start-codex_id=17;ruleset_id=1& -----------------*/
/*---------------------------&start-codex_id=17;ruleset_id=1& -----------------*/
procedure rs_17_1 :
define input parameter p-caller as character no-undo .
define input parameter v-pline-num as integer   no-undo .
define input parameter v-cdpay-code as integer   no-undo .
define input parameter v-curr-code as integer   no-undo .
define input parameter v-pay-card as character no-undo .
define input parameter v-inversed as logical no-undo .
define input parameter v-start-curr-sum as decimal no-undo .
define input parameter v-curr-sum as decimal no-undo .
define input parameter v-start-rubl-sum as decimal no-undo .
define input parameter v-rubl-sum as decimal no-undo .
define input parameter v-start-base-sum as decimal no-undo .
define input parameter v-base-sum as decimal no-undo .
define input parameter v-discnt-curr as decimal no-undo .
define input parameter v-discnt-rubl as decimal no-undo .
define input parameter v-discnt-base as decimal no-undo .
define input parameter v-bh as handle no-undo extent 6.
define output parameter v-new-curr-sum as decimal no-undo .
define output parameter v-new-rubl-sum as decimal no-undo .
define output parameter v-new-base-sum as decimal no-undo .
define output parameter v-new-discnt-curr as decimal no-undo .
define output parameter v-new-discnt-rubl as decimal no-undo .
define output parameter v-new-discnt-base as decimal no-undo .
define buffer buf_temp-rule-by-call for temp-rule-by-call.
define buffer buf_temp-discnt-role for temp-discnt-role.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  v-codex-id = 17
  v-ruleset-id = 1
  v-caller = p-caller
  .
  assign
  v-new-curr-sum      = v-curr-sum
  v-new-rubl-sum      = v-rubl-sum
  v-new-base-sum      = v-base-sum
  v-new-discnt-curr   = v-discnt-curr
  v-new-discnt-rubl   = v-discnt-rubl
  v-new-discnt-base   = v-discnt-base
  .
  for each buf_temp-rule-by-call where
            buf_temp-rule-by-call.call_id = p-call-id
        and buf_temp-rule-by-call.codex_id = v-codex-id
        and buf_temp-rule-by-call.ruleset_id = v-ruleset-id
        and buf_temp-rule-by-call.profile_id = p-profile-id
        and buf_temp-rule-by-call.once-more = p-once-more
  by buf_temp-rule-by-call.order
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if not (buf_temp-rule-by-call.can-calc and buf_temp-rule-by-call.can-run) then next.
    run value( substitute("r_17_1_&1", buf_temp-rule-by-call.rule_id)) in this-procedure (
              input buf_temp-rule-by-call.order_id
             ,input buf_temp-rule-by-call.rule_id
             ,input v-pline-num
             ,input v-cdpay-code
             ,input v-curr-code
             ,input v-pay-card
             ,input v-inversed
             ,input v-start-curr-sum
             ,input v-curr-sum
             ,input v-start-rubl-sum
             ,input v-rubl-sum
             ,input v-start-base-sum
             ,input v-base-sum
             ,input v-discnt-curr
             ,input v-discnt-rubl
             ,input v-discnt-base
             ,input v-bh
             ,output v-new-curr-sum
             ,output v-new-rubl-sum
             ,output v-new-base-sum
             ,output v-new-discnt-curr
             ,output v-new-discnt-rubl
             ,output v-new-discnt-base
             ) no-error.
    if not error-status :error then do:
      assign
      v-curr-sum      = v-new-curr-sum
      v-rubl-sum      = v-new-rubl-sum
      v-base-sum      = v-new-base-sum
      v-discnt-curr   = v-new-discnt-curr
      v-discnt-rubl   = v-new-discnt-rubl
      v-discnt-base   = v-new-discnt-base
      .
    end.
  end.
end. /*doe*/
end procedure.
procedure r_17_1_1973:
define input parameter p-order-id as integer no-undo .
define input parameter p-rule-id as integer no-undo .
define input parameter v-pline-num as integer   no-undo .
define input parameter v-cdpay-code as integer   no-undo .
define input parameter v-curr-code as integer   no-undo .
define input parameter v-pay-card as character no-undo .
define input parameter v-inversed as logical no-undo .
define input parameter v-start-curr-sum as decimal no-undo .
define input parameter v-curr-sum as decimal no-undo .
define input parameter v-start-rubl-sum as decimal no-undo .
define input parameter v-rubl-sum as decimal no-undo .
define input parameter v-start-base-sum as decimal no-undo .
define input parameter v-base-sum as decimal no-undo .
define input parameter v-discnt-curr as decimal no-undo .
define input parameter v-discnt-rubl as decimal no-undo .
define input parameter v-discnt-base as decimal no-undo .
define input parameter v-bh as handle no-undo extent 6.
define output parameter v-new-curr-sum as decimal no-undo .
define output parameter v-new-rubl-sum as decimal no-undo .
define output parameter v-new-base-sum as decimal no-undo .
define output parameter v-new-discnt-curr as decimal no-undo .
define output parameter v-new-discnt-rubl as decimal no-undo .
define output parameter v-new-discnt-base as decimal no-undo .
define buffer buf_temp-rule-call-param for temp-rule-call-param.
/* ------------------------- &start-def-vars& -----------------------------------*/
/* ------------------------- &end-def-vars& -----------------------------------*/
/*---------------------------&start-rule-call-param&-------------------------------*/
 define variable p-discnt-roles as character no-undo.
 define variable p-add-discnts as logical no-undo.
/*---------------------------&end-rule-call-param&-------------------------------*/
/*---------------------------&start-process-rule-call-param&-------------------------------*/

 find first buf_temp-rule-call-param no-lock where
buf_temp-rule-call-param.codex_id = v-codex-id
and buf_temp-rule-call-param.ruleset_id = v-ruleset-id
and buf_temp-rule-call-param.call_id = p-call-id
and buf_temp-rule-call-param.order_id = p-order-id
and buf_temp-rule-call-param.rule_id = p-rule-id
and buf_temp-rule-call-param.param-name = "p-add-discnts"
 no-error.
if available buf_temp-rule-call-param then do:
assign p-add-discnts = buf_temp-rule-call-param.param-value-logical.
end.

/*---------------------------&end-process-rule-call-param&-------------------------------*/
_main:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
    /* ------------------------- &start-rule& -----------------------------------*/
  { rul/000001973.i }
    /* ------------------------- &end-rule& -------------------------------------*/
    /* ------------------------- &start-release-obj& -----------------------------------*/
    /* ------------------------- &end-release-obj& -------------------------------------*/
end. /*doe _main*/
end procedure. /* rule- */



/*---------------------------&end-rule-block&-------------------------------*/


procedure load-ruleset-context :
define variable v-subject-type as integer no-undo .
define variable v-found as logical no-undo .
define variable v-vh as handle no-undo .

define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_temp-rule-call-param for temp-rule-call-param.
define buffer buf_temp-rule-by-call for temp-rule-by-call.
define buffer buf_temp-discnt-role for temp-discnt-role.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define buffer buf2_dis-cfg-rule for ub.dis-cfg-rule.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  for each buf_temp-rule-call-param:
    delete buf_temp-rule-call-param.
  end.
  for each buf_temp-rule-by-call:
    delete buf_temp-rule-by-call.
  end.


  for each buf_rule-call-param no-lock where
          buf_rule-call-param.profile_id = p-profile-id
      and buf_rule-call-param.once-more = p-once-more
      and buf_rule-call-param.call_id = p-call-id
  break
  by buf_rule-call-param.call_id
  by buf_rule-call-param.codex_id
  by buf_rule-call-param.ruleset_id
  by buf_rule-call-param.order_id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if first-of(buf_rule-call-param.order_id)  then do:
      v-found = no.
    end.
    create buf_temp-rule-call-param.
    buffer-copy buf_rule-call-param to buf_temp-rule-call-param.
    if (lookup(buf_temp-rule-call-param.param-3-data-type, "LIST") = 0
    and lookup(buf_temp-rule-call-param.param-3-data-type, "SORTED-LIST") = 0
    )
    or buf_temp-rule-call-param.p-index > 0 then do:
      if lookup(buf_temp-rule-call-param.param-2-data-type, {&calc-point-discnt-role-list}) > 0
      then do:
        case buf_temp-rule-call-param.param-2-data-type:
          when {&gds-discnt-role} then do:
            assign
            v-subject-type = integer({&discnt-gds}).
          end.
          when {&subtotal-discnt-role} then do:
            assign
            v-subject-type = integer({&discnt-sub-total}).
          end.
          when {&pay-discnt-role} then do:
            assign
            v-subject-type = integer({&discnt-payment}).
          end.
        end case.
        for each buf_dis-cfg-rule no-lock where
                    buf_dis-cfg-rule.discnt-role = buf_temp-rule-call-param.param-value-character
                and buf_dis-cfg-rule.pos-type = p-pos-type-for-discnt
             and buf_dis-cfg-rule.subject-type = v-subject-type :
          if buf_dis-cfg-rule.link-prop <> integer({&dr-appl-object})
          and buf_dis-cfg-rule.link-prop <> integer({&dr-no-rule}) then next.
          assign
          v-vh = p-bh[{&context}]:buffer-field("how-" + buf_temp-rule-call-param.param-value-character) no-error.
          if valid-handle(v-vh)
          and buf_dis-cfg-rule.discnt-role <> p-bh[{&context}]:buffer-field("how-" + buf_temp-rule-call-param.param-value-character):buffer-value
          then next.
          find first buf_temp-discnt-role where
                  buf_temp-discnt-role.codex_id = buf_temp-rule-call-param.codex_id
              and buf_temp-discnt-role.ruleset_id = buf_temp-rule-call-param.ruleset_id
              and buf_temp-discnt-role.order_id = buf_temp-rule-call-param.order_id
              and buf_temp-discnt-role.rule_id = buf_temp-rule-call-param.rule_id
              and buf_temp-discnt-role.pos-type = p-pos-type-for-discnt
              and buf_temp-discnt-role.discnt-role = buf_temp-rule-call-param.param-value-character
              and buf_temp-discnt-role.table-name = buf_dis-cfg-rule.table-name
              no-error.
          if not available buf_temp-discnt-role then do:
            create buf_temp-discnt-role.
            assign
            buf_temp-discnt-role.codex_id = buf_temp-rule-call-param.codex_id
            buf_temp-discnt-role.ruleset_id = buf_temp-rule-call-param.ruleset_id
            buf_temp-discnt-role.order_id = buf_temp-rule-call-param.order_id
            buf_temp-discnt-role.rule_id = buf_temp-rule-call-param.rule_id
            buf_temp-discnt-role.once-more = buf_temp-rule-call-param.once-more
            buf_temp-discnt-role.pos-type = p-pos-type-for-discnt
            buf_temp-discnt-role.subject-type = v-subject-type
            buf_temp-discnt-role.discnt-role = buf_temp-rule-call-param.param-value-character
            buf_temp-discnt-role.discnt-type = buf_Dis-cfg-rule.discnt-type
            buf_temp-discnt-role.table-name = buf_Dis-cfg-rule.table-name
            buf_temp-discnt-role.has-glob = buf_Dis-cfg-rule.has-glob
            buf_temp-discnt-role.has-host = buf_Dis-cfg-rule.has-host
            buf_temp-discnt-role.has-obj = buf_Dis-cfg-rule.has-obj
            buf_temp-discnt-role.link-prop = buf_Dis-cfg-rule.link-prop
            buf_temp-discnt-role.templ-rl-root = (if buf_Dis-cfg-rule.link-prop = integer({&dr-no-rule})
                                                  then buf_dis-cfg-rule.templ-rl-root
                                                  else buf_temp-discnt-role.templ-rl-root)
            buf_temp-discnt-role.time-templ-rl-root = (if buf_Dis-cfg-rule.link-prop = integer({&dr-no-rule})
                                                  then buf_dis-cfg-rule.time-templ-rl-root
                                                  else buf_temp-discnt-role.time-templ-rl-root)
            .
            v-found = yes.
            if buf_temp-discnt-role.table-name = {&table_dis-grp-rule} then do:
              assign
              p-bh[{&context}]:buffer-field("is-grp-totals"):buffer-value = yes.
            end.
            /*
            if buf_dis-cfg-rule.link-prop <> integer({&dr-appl-object}) then do:
              for each buf2_dis-cfg-rule no-lock where
                      buf2_dis-cfg-rule.pos-type = p-pos-type-for-discnt
                  and buf2_dis-cfg-rule.discnt-role = buf_dis-cfg-rule.discnt-role
                  and buf2_dis-cfg-rule.templ-rl-root = buf_dis-cfg-rule.templ-rl-root
                  and buf2_dis-cfg-rule.time-templ-rl-root = buf_dis-cfg-rule.time-templ-rl-root
              on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
              on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
              on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
              :
                create buf_temp-discnt-role.
                assign
                buf_temp-discnt-role.codex_id = buf_temp-rule-call-param.codex_id
                buf_temp-discnt-role.ruleset_id = buf_temp-rule-call-param.ruleset_id
                buf_temp-discnt-role.order_id = buf_temp-rule-call-param.order_id
                buf_temp-discnt-role.rule_id = buf_temp-rule-call-param.rule_id
                buf_temp-discnt-role.once-more = buf_temp-rule-call-param.once-more
                buf_temp-discnt-role.pos-type = p-pos-type-for-discnt
                buf_temp-discnt-role.subject-type = buf2_dis-cfg-rule.subject-type
                buf_temp-discnt-role.discnt-role = buf2_dis-cfg-rule.discnt-role
                buf_temp-discnt-role.discnt-type = buf2_Dis-cfg-rule.discnt-type
                buf_temp-discnt-role.table-name = buf2_Dis-cfg-rule.table-name
                buf_temp-discnt-role.has-glob = buf2_Dis-cfg-rule.has-glob
                buf_temp-discnt-role.has-host = buf2_Dis-cfg-rule.has-host
                buf_temp-discnt-role.has-obj = buf2_Dis-cfg-rule.has-obj
                .
              end. /*                for each buf2_dis-cfg-rule no-lock where*/
            end. /*if buf_dis-cfg-rule.link-prop <> integer({&dr-appl-object}) then do:*/
            */
          end. /*if not available buf_temp-discnt-role then do:*/
        end. /*        for each buf_dis-cfg-rule no-lock where*/
      end. /*if lookup(buf_temp-rule-call-param.param-2-data-type, {&calc-point-discnt-role-list}) > 0*/
    end. /*if (lookup(buf_temp-rule-call-param.param-3-data-type, "LIST") = 0*/
    if last-of(buf_rule-call-param.order_id) then do:
      if v-found = no then do:
        create buf_temp-discnt-role.
        assign
        buf_temp-discnt-role.codex_id = buf_temp-rule-call-param.codex_id
        buf_temp-discnt-role.ruleset_id = buf_temp-rule-call-param.ruleset_id
        buf_temp-discnt-role.order_id = buf_temp-rule-call-param.order_id
        buf_temp-discnt-role.rule_id = buf_temp-rule-call-param.rule_id
        buf_temp-discnt-role.once-more = buf_temp-rule-call-param.once-more
        buf_temp-discnt-role.discnt-type = 0
        buf_temp-discnt-role.subject-type = 0
        buf_temp-discnt-role.discnt-role = ''
        .
      end.
    end. /*if last-of(buf_rule-call-param.order-id) = 0 then do:*/
  end. /*for each buf_rule-call-param no-lock where*/
  for each buf_rule-by-call no-lock where
          buf_rule-by-call.profile_id = p-profile-id
      and buf_rule-by-call.once-more = p-once-more
      and buf_rule-by-call.call_id = p-call-id
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    create buf_temp-rule-by-call.
    buffer-copy buf_rule-by-call to buf_temp-rule-by-call.
  end.


  assign
  v-current-host-code = p-host-code
  v-current-obj-type = p-obj-type
  v-current-obj-code = p-obj-code
  v-current-db-num = g#db-num
  v-current-pos-type = p-pos-type
  v-current-pos-type-for-discnt = p-pos-type-for-discnt
  /*
  v-bh[1] = p-context-bh
  v-bh[2] = p-chk-context-bh
  v-bh[3] = p-chk-doc-bh
  v-bh[4] = p-chk-gds-bh
  v-bh[5] = p-chk-pay-bh
  v-bh[6] = p-chk-discnt-bh
  */
  .
end. /*doe*/

end procedure. /* load-ruleset-context */

procedure rp-chk-doc_set-log :
define input parameter p-lock-log-handle as handle no-undo .
main-block:
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
:
  p-log-handle = p-lock-log-handle.
end. /*doe*/
end. /*doe*/