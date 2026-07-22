block-level on error undo, throw.
/*

$Revision: f0ee8d6aeba2, 1543, rls $
$Author: obrezanova $
$Date: Tue Oct 09 17:22:13 2018 +0300 $
$Workfile: dict-atd-exp-run.p $
$Archive: utl/dict-atd-exp-run.p $

Экспорт справочных данных для АТД клиента

Автор: Курбет Антон
Дата создания: 23/07/18
Author: Kurbet Anton
Creation date: 23/07/18

*/
using ibs.th.bge.atd.*.

define input parameter parparentproc    as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: f0ee8d6aeba2, 1543, rls $":U .
define variable vss-author      as character no-undo init "$Author: obrezanova $":U .
define variable vss-date        as character no-undo init "$Date: Tue Oct 09 17:22:13 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dict-atd-exp-run.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/dict-atd-exp-run.p $":U .
define variable vss-description as character no-undo init "Экспорт справочных данных для АТД клиента".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

define variable vExp       as class dict-atd-exp no-undo.
define variable vDir       as character no-undo.
define variable vInitDir   as character no-undo.

do on error undo, return error return-value:
   
   vInitDir = os-getenv("userprofile").
   system-dialog get-dir vDir initial-dir vInitDir title "Папка для экспорта".
   if vDir > "" then do:
      vExp = new dict-atd-exp(vDir,
                              v-cntxt-db-num,
                              v-cntxt-obj-type,
                              v-cntxt-obj-code).
      vExp:RunFileTask().
      delete object vExp. 
   end.
end. 