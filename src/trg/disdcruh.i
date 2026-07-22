/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры записи истории для dis-dc-rule

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/29/04
Author: Bakhtadze Natalya
Creation date: 01/29/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "trig" &then
procedure disdcruh_write-dis-dc-rule-trigger :
define input parameter p-new-record as logical no-undo .
define input parameter p-source-type like ub.c-dc-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-dc-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-dc-rule for ub.c-dis-dc-rule.


  do
  on error undo, return error
  :

    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-dis-dc-rule.
    buffer-copy {2} to buf_c-dis-dc-rule
    assign
    buf_c-dis-dc-rule.d-card             = {3}.d-card
    buf_c-dis-dc-rule.card-num           = {3}.card-num
    buf_c-dis-dc-rule.obj-type           = {3}.obj-type
    buf_c-dis-dc-rule.obj-code           = {3}.obj-code
    buf_c-dis-dc-rule.host-code          = {3}.host-code
    buf_c-dis-dc-rule.pos-type           = {3}.pos-type
    buf_c-dis-dc-rule.discnt-role        = {3}.discnt-role
    buf_c-dis-dc-rule.nonunique          = {3}.nonunique
    buf_c-dis-dc-rule.chip-num           = next-value (s-dc-chip, {&db-name_schema})
    buf_c-dis-dc-rule.corr-time          = v-time
    buf_c-dis-dc-rule.corr-user-db-num   = g#db-num
    buf_c-dis-dc-rule.corr-user-name     = (if g#news
                                            then {&nts-user}
                                            else (if g#esys
                                                 then {&esys-user}
                                                 else g#userid
                                                 )
                                            )
    buf_c-dis-dc-rule.corr-date          = v-date
    .
    create buf_c-dc-hist.
    buffer-copy buf_c-dis-dc-rule to buf_c-dc-hist
    assign
    buf_c-dc-hist.action = (if p-new-record then integer({&hn-create}) else integer({&hn-update}))
    buf_c-dc-hist.subject = {&table_dis-dc-rule}
    buf_c-dc-hist.is-news  = g#news
    buf_c-dc-hist.source-type = p-source-type
    buf_c-dc-hist.source-ref =  p-source-ref
    .
  end.
end procedure. /* write-dis-dc-rule-hist */
&endif

procedure disdcruh_write-dis-dc-rule-proc :
define input parameter p-d-card      like ub.c-dis-dc-rule.d-card no-undo .
define input parameter p-card-num    like ub.c-dis-dc-rule.card-num no-undo .
define input parameter p-host-code   like ub.c-dis-dc-rule.host-code no-undo .
define input parameter p-obj-type    like ub.c-dis-dc-rule.obj-type  no-undo .
define input parameter p-obj-code    like ub.c-dis-dc-rule.obj-code  no-undo .
define input parameter p-pos-type    like ub.c-dis-dc-rule.pos-type  no-undo .
define input parameter p-discnt-role  like ub.c-dis-dc-rule.discnt-role no-undo .
define input parameter p-nonunique   like ub.c-dis-dc-rule.nonunique no-undo .
define input parameter p-action      as integer no-undo .
define input parameter p-source-type like ub.c-dc-hist.source-type no-undo .
define input parameter p-source-ref  like ub.c-dc-hist.source-ref no-undo .

define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define buffer buf_c-dc-hist for ub.c-dc-hist.
define buffer buf_c-dis-dc-rule for ub.c-dis-dc-rule.


  do
  on error undo, return error
  :
    run cur-time in this-procedure(output v-date, output v-time).
    create buf_c-dis-dc-rule.
    assign
    buf_c-dis-dc-rule.d-card             = p-d-card
    buf_c-dis-dc-rule.card-num           = p-card-num
    buf_c-dis-dc-rule.obj-type           = p-obj-type
    buf_c-dis-dc-rule.obj-code           = p-obj-code
    buf_c-dis-dc-rule.host-code          = p-host-code
    buf_c-dis-dc-rule.pos-type           = p-pos-type
    buf_c-dis-dc-rule.discnt-role        = p-discnt-role
    buf_c-dis-dc-rule.nonunique          = p-nonunique
    buf_c-dis-dc-rule.chip-num           = next-value (s-dc-chip, {&db-name_schema})
    buf_c-dis-dc-rule.corr-time          = v-time
    buf_c-dis-dc-rule.corr-user-db-num   = g#db-num
    buf_c-dis-dc-rule.corr-user-name     = (if g#news
                                            then {&nts-user}
                                            else (if g#esys
                                                 then {&esys-user}
                                                 else g#userid
                                                 )
                                            )
    buf_c-dis-dc-rule.corr-date          = v-date
    .
    create buf_c-dc-hist.
    buffer-copy buf_c-dis-dc-rule to buf_c-dc-hist
    assign
    buf_c-dc-hist.action = p-action
    buf_c-dc-hist.subject = {&table_dis-dc-rule}
    buf_c-dc-hist.is-news  = g#news
    buf_c-dc-hist.source-type = p-source-type
    buf_c-dc-hist.source-ref =  p-source-ref
    .
  end. /*doe*/

end procedure. /* dc-attrh_write-dis-dc-rule-proc */

/* $Workfile$ e n d */