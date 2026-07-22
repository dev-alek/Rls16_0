block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cbnkrune.p $
$Archive: bge/cbnkrune.p $

ЭКСПОРТ в систему КЛИЕНТ-БАНК - запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/19/05
Author: Bakhtadze Natalya
Creation date: 07/19/05

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cbnkrune.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/cbnkrune.p $":U .
define variable vss-description as character no-undo init "ЭКСПОРТ в систему КЛИЕНТ-БАНК -запуск ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/getcntxt.i def }

define variable v-cancel        as logical no-undo .
define variable v-params        as character    no-undo.
define variable v-host-list        as character    no-undo.
define variable v-doc-type-list      as character    no-undo.
define variable v-hsch-list          as character    no-undo.
define variable v-csch-list          as character    no-undo.
define variable v-date-list          as character    no-undo.
define variable v-counter       as integer       no-undo.

{ bge/clbnkd.i "NEW SHARED" }
{ gbl/getcntxt.i get }

run bge/clb-shdp.w (
                 input parparentproc
                ,input v-cntxt-host-code-obj
                ,input 'run':U
                ,input '':U /*p-task-type*/
                ,input ?
                ,input -1
                ,input 'exp':U
                ,output v-cancel
                ,output v-params
                ,output v-host-list
                ,output v-doc-type-list
                ,output v-date-list
                ,output v-hsch-list
                ,output v-csch-list
              ) no-error.

if error-status:error then undo, return error .
if v-cancel then return.

do
on error undo, return error
:

  /*разберем параметры и прдставим их в виде врем таблиц*/


  run init-host-list in this-procedure (input v-host-list).
  run fill-hfin-schet in this-procedure (input v-hsch-list).
  run fill-cfin-schet in this-procedure (input v-csch-list).

  run str/diallog.w ( parparentproc
              , this-procedure
              , 'bge/clbnke.p':U
              , '0' + {&delim-par} + v-params + {&delim-par} + v-date-list + {&delim-par} + v-doc-type-list
              , no /*p-auto-go*/
              , '':U
              , 'Экспорт данных в систему КЛИЕНТ-БАНК') no-error .


end. /*doe*/