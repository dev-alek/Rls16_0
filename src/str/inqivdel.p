block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inqivdel.p $
$Archive: str/inqivdel.p $

Удаление обслуженного внутреннего приходного запроса

Автор: Чернова Светлана Александровна
Дата создания: 06/27/08
Author: Svetlana Chernova
Creation date: 06/27/08

Удаление обслуженного внутреннего приходного запроса
При закрытии ПН
Запускать в новостях на ГБД


*/

define input  parameter p-doc-code    as character no-undo . /* № Приходной накладной */


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: inqivdel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/inqivdel.p $":U .
define variable vss-description as character no-undo init "Удаление обслуженного внутреннего приходного запроса".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i  noprocess }

do
on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
define buffer PN_trn-doc for ub.trn-doc  .
define buffer PZ_trn-doc for ub.trn-doc  .
define buffer RN_trn-doc for ub.trn-doc  .
define variable v-mane-code as character no-undo .
define variable v-pz-code as character no-undo .

  find first PN_trn-doc no-lock where
             PN_trn-doc.doc-code  = p-doc-code .
  if PN_trn-doc.ext-doc-type <> {&TDEDT_Pri_Perem} then return .
  v-mane-code = entry(1,p-doc-code , "=") .

  find first PZ_trn-doc no-lock where
             PZ_trn-doc.doc-code  begins  v-mane-code + "-"  and
             Pz_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}  and
             Pz_trn-doc.status_      = {&inquiry} no-error .
  if error-status :error then return .
     v-pz-code = PZ_trn-doc.doc-code .

/* все щепки РасхНакл */
for each RN_trn-doc no-lock where
         RN_trn-doc.doc-code  begins  v-mane-code + "-"  and
         RN_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem}  :
     for each PN_trn-doc no-lock where
              PN_trn-doc.out-code = RN_trn-doc.doc-code :
           if PN_trn-doc.status_ <> {&fact} then return .
     end.
end.
/* Удаляем ПрихЗапрос */
  find first PZ_trn-doc exclusive-lock where
             PZ_trn-doc.doc-code = v-pz-code no-error .
  if available PZ_trn-doc then do:
     delete PZ_trn-doc.
  end.


end.