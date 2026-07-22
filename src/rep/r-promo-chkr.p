block-level on error undo, throw.
/*

$Revision: 7d43b3c6e049, 1489, rls $
$Author: EShklyar $
$Date: Thu Aug 30 10:41:45 2018 +0300 $
$Workfile: r-promo-chkr.p $
$Archive: rep/r-promo-chkr.p $

Промежуточный вызов отчета по реализации промо-акций.

Автор: Шкляр Елена
Дата создания: 04/29/10
Author: Elena Shklyar
Creation date: 04/29/10
*/

define variable vss-revision    as character no-undo init "$Revision: 7d43b3c6e049, 1489, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Thu Aug 30 10:41:45 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-promo-chkr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-promo-chkr.p $":U .
define variable vss-description as character no-undo init "Промежуточный вызов отчета по реализации промо-акций".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-page1.i  }
define variable v-caller-handle as handle no-undo .
v-caller-handle = this-procedure:instantiating-procedure.

run rep/r-promo-chk.p (
                   input my-handle
                  ,input v-caller-handle /*p-parent-handle*/
                  ,input v-caller-handle /*      p-log-handle*/
                  ,input v-caller-handle /*   p-cont-handle*/
                  ,input v-caller-handle /*p-call-handle*/
                  ,input ? /*p-rebh*/
                  ,input ? /*p-redbh*/
                  ,input '' /*p-report-id*/
                  ,input integer({&repcalc-type-operator}) /*p-batch*/
                  ,input 0 /*p-codex-id*/
                  ,input 0 /*p-ruleset-id*/
                  ,input "" /*p-log-file-name*/
                  ,input yes /*t-text*/
                  ,input yes /*t-excel*/
                  ,input '' /*p-dir-name*/
                ) .
