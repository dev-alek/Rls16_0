/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях праивл скидок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-ok as logical no-undo .
define buffer buf_dis-rule  for ub.dis-rule .
define buffer template_dis-rule for ub.dis-rule.
define variable h_wt-dis-rule as handle no-undo .
define variable h_buf_dis-rule as handle no-undo .
define variable jj as integer no-undo .
define variable v-uniq-field as character no-undo .
define variable v-curr-field as character no-undo .
define buffer buf1_dis-rule         for ub.dis-rule.
define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
define buffer buf_dis-cfg-rule for ub.dis-cfg-rule.
define variable v-gds-send as logical no-undo .
define variable v-dc-send as logical no-undo .
define buffer buf_Dis-card for ub.dis-card.
define buffer buf_goods for ub.goods.
define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_dis-dc-rule for ub.dis-dc-rule.

for each locb1-dis-rule
on error undo, return error error-status :get-message (1)
:
  delete locb1-dis-rule.
end.

/* $Workfile$ e n d */