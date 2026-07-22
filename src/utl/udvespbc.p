block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: udvespbc.p $
$Archive: utl/udvespbc.p $

Утилита отлова выключенных весовых кодов для всех весовых товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: udvespbc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/udvespbc.p $":U .
define variable vss-description as character no-undo init "Утилита отлова выключенных весовых кодов для всех весовых товаров".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }


define variable kk as integer no-undo.
define variable r-bar-code like ub.bar-code.b-code no-undo.
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
{ cmp/gds-list.i gds-list def "new shared" }

run waitfram-show in this-procedure ("Ждите...").
for each ub.goods no-lock,
      first ub.units no-lock where ub.units.unit-name = ub.goods.unit-base and
             LOOKUP({&weight}, ub.units.type) > 0,
      FIRST ub.gds-prt WHERE ub.gds-prt.upper-code = ub.goods.prt-root NO-LOCK       :
      kk  =  kk  +  1.
      if kk modulo 50  = 0 then do:
         run waitfram-show in this-procedure ("Обработано " + string(kk) + " товаров...").
      end.
      { gbl/gdsbcode.i ub.goods.gds-code ? r-bar-code no-error}
      if error-status:error then NEXT .
      _prod-bc:
      FOR EACH ub.prod-bc where ub.prod-bc.b-code = r-bar-code
      no-lock:

        if avail ub.prod-bc and not ub.prod-bc.bc-on  then do:
          { cmp/gds-list.i gds-list assign }
          LEAVE _prod-bc.
       end.
     END.
end.
run waitfram-hide in this-procedure .
{ gbl/getcntxt.i get }
run str/gds-list.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code) .