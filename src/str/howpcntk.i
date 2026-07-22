/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/17/09
Author: Bakhtadze Natalya
Creation date: 11/17/09

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-param-type{&vssseq} as character no-undo .
define variable v-value-date{&vssseq} as date no-undo .
define variable v-value-decimal{&vssseq} as decimal no-undo .
define variable v-value-integer{&vssseq} as INTEGER no-undo .
define variable v-value-logical{&vssseq} AS LOGICAL no-undo .
define variable v-tth{&vssseq} as handle no-undo .
define variable v-host-code{&vssseq} as integer no-undo .
define buffer buf_dis-thbj-rule{&vssseq} for ub.dis-thbj-rule.

{ gbl/dflt-cd.i {1} {2} {4} }
{3} = ''.
run adm/shattri.p (
    input "get":U
    ,input  {1}
    ,input  {2}
    ,input  {&attr-cd-inf-send}
    ,input  {&attr-cd-inf-send_how-pcnt-kat} /*p-param-code*/
    ,output {3}
    ,output v-value-date{&vssseq}
    ,output v-value-decimal{&vssseq}
    ,output v-value-integer{&vssseq}
    ,output v-value-logical{&vssseq}
    ,output v-param-type{&vssseq}
    ,INPUT-OUTPUT table-handle v-tth{&vssseq}
    ) {5} .

delete object v-tth{&vssseq}.
if {3} = {&dthbjr-pcnt-kat-pdf} then do:
  find first  buf_dis-thbj-rule{&vssseq} No-LOCK  where
              buf_dis-thbj-rule{&vssseq}.obj-type = {1}
        AND  buf_dis-thbj-rule{&vssseq}.obj-code = {2}
        and  buf_dis-thbj-rule{&vssseq}.pos-type = {4}
        and  buf_dis-thbj-rule{&vssseq}.discnt-role = {&dthbjr-pcnt-kat-pdf}
        and  buf_dis-thbj-rule{&vssseq}.nonunique = ''
        no-error .
  if not available buf_dis-thbj-rule{&vssseq} then do:
    { gbl/hostcode.i {1} {2} v-host-code{&vssseq} }
    find first  buf_dis-thbj-rule{&vssseq} No-LOCK  where
                buf_dis-thbj-rule{&vssseq}.obj-code = v-host-code{&vssseq}
          AND  buf_dis-thbj-rule{&vssseq}.obj-type = {&cmp}
          and  buf_dis-thbj-rule{&vssseq}.pos-type = {4}
          and  buf_dis-thbj-rule{&vssseq}.discnt-role = {&dthbjr-pcnt-kat-pdf}
          and  buf_dis-thbj-rule{&vssseq}.nonunique = ''
          no-error .
  end.
  if not available buf_dis-thbj-rule{&vssseq} then do:
    find first  buf_dis-thbj-rule{&vssseq} No-LOCK  where
                buf_dis-thbj-rule{&vssseq}.obj-code = 0
          AND  buf_dis-thbj-rule{&vssseq}.obj-type = ''
          and  buf_dis-thbj-rule{&vssseq}.pos-type = {4}
          and  buf_dis-thbj-rule{&vssseq}.discnt-role = {&dthbjr-pcnt-kat-pdf}
          and  buf_dis-thbj-rule{&vssseq}.nonunique = ''
          no-error .
  end.
  if available buf_dis-thbj-rule{&vssseq} then do:
    {3} = {3} + "=" + string(buf_dis-thbj-rule{&vssseq}.rule-num).
  end.
  else do:
    {3} = {3} + "="  + string(0).
  end.
end.

/* $Workfile$ e n d */