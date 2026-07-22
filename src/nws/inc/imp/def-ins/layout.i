/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определения для приема в новостях раскладки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/26/08
Author: Bakhtadze Natalya
Creation date: 09/26/08

*/
define buffer buf_layout-elem-rule for ub.layout-elem-rule.
define buffer buf_rule-call-param for ub.rule-call-param.
define buffer buf_rule-by-call for ub.rule-by-call.
define buffer buf_layout-elem for ub.layout-elem.
define buffer buf_wi-mode for ub.wi-mode.
define buffer buf2_layout for ub.layout.
define buffer buf2_layout-elem-rule for ub.layout-elem-rule.

define variable counter  as integer   no-undo.
define variable rec-full as character no-undo.
define variable rec-name as character no-undo.
define variable v-chip-num as integer no-undo .
define variable v-cmp as logical   no-undo .