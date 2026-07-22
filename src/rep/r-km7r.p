block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-km7r.p $
$Archive: rep/r-km7r.p $

Промежуточный вызов отчета по форме КМ-7

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/01/10
Author: Bakhtadze Natalya
Creation date: 06/01/10

нужен чтобы вызвать r - k m . 7 из e - k m 7 . w с параметрами


*/



define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-km7r.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-km7r.p $":U .
define variable vss-description as character no-undo init "Промежуточный вызов отчета по форме КМ-7".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-page1.i  }
define variable v-caller-handle as handle no-undo .
v-caller-handle = this-procedure:instantiating-procedure.

run rep/r-km7.p (
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
