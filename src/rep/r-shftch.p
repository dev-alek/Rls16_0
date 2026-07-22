block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-shftch.p $
$Archive: rep/r-shftch.p $

сменный отчет - разброс чеков ЮКОС лист 2-4

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

DEFINE INPUT PARAMETER pobj-type like ub.shift-obj.obj-type no-undo.
DEFINE INPUT PARAMETER pobj-code like ub.shift-obj.obj-code no-undo.
DEFINE INPUT PARAMETER pshift-date like ub.shift-obj.shift-date no-undo.
DEFINE INPUT PARAMETER pshift-num like ub.shift-obj.shift-num no-undo.
DEFINE INPUT PARAMETER pshift-date1 like ub.shift-obj.shift-date no-undo.
DEFINE INPUT PARAMETER pshift-num1 like ub.shift-obj.shift-num no-undo.
DEFINE INPUT PARAMETER SHEETS as integer no-undo.
/*закодировано какие листы печатаем в отчете*/
DEFINE INPUT PARAMETER SHEET2 as logical no-undo.
DEFINE INPUT PARAMETER SHEET3 as logical no-undo.
DEFINE INPUT PARAMETER SHEET4 as logical no-undo.
DEFINE INPUT PARAMETER SHEET8 as logical no-undo.
define input parameter pclassify as logical no-undo .
define input parameter pselectgood as logical no-undo .

define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author: expertek $":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: r-shftch.p $":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive: rep/r-shftch.p $":U.
define variable vss-description AS CHAR NO-UNDO INIT "Сменный отчет - алгоритм разброса чеков - лист 2-4":U.

{ cmp/vssrevis.i                }
{ cmp/str-glbl.i                }
{ cmp/library.i                 }
{ str/lib-trn.i                 }
{ rep/real-2df.i SHARED treal-2 }
{ rep/real-3df.i SHARED treal-3 }
{ rep/real3tmp.i                }
{ rep/real-4df.i SHARED treal-4 }
{ rep/real-8df.i SHARED treal-8 }
{ rep/icm-3df.i  SHARED         }
{ rep/real-2cr.i        treal-2 }
{ rep/real-3cr.i        treal-3 }
{ rep/real-4cr.i        treal-4 }
{ str/valddnst.i def            }
{ rep/r-paychk.i def            }
{ rep/r-paychk.i defvar         }

define variable v-curr-r-b as character no-undo .

{ gbl/curr-r-b.i
  v-curr-r-b
}
{ gbl/hostcode.i pobj-type pobj-code v-host-code }
{ gbl/basecode.i v-host-code v-base-code }
if v-curr-r-b = {&r-b-base} or
v-base-code = 0 then pychk_NO-exch = yes.
else pychk_No-exch = no.
if v-curr-r-b = {&r-b-rubl} or
v-base-code = 0 then pychk_NO-exch-rubl = yes.
else pychk_No-exch-rubl = no.

if pclassify then do:
  FIND FIRST t-3 where t-3.grp-code = 0 No-ERROR.
end.
assign
pychk_classify = pclassify
pychk_selectgood = pselectgood
pychk_sheet2 = sheet2
pychk_sheet3 = sheet3
pychk_sheet4 = sheet4
pychk_sheet8 = sheet8
.


for each temp-chk-gds:
  delete temp-chk-gds.
end.

_chk-doc:
FOR EACH ub.chk-doc No-LOCK WHERE
         ub.chk-doc.obj-type = pobj-type AND
         ub.chk-doc.obj-code = pobj-code AND
         ub.chk-doc.shift-date >= pshift-date AND
         ub.chk-doc.shift-date <= pshift-date1 AND
     ub.chk-doc.out-code <> ?,
   EACH ub.chk-pay NO-LOCK WHERE
          ub.chk-pay.doc-code = ub.chk-doc.doc-code
    BREAK
    BY CHK-pay.DOC-CODE
    BY CHK-pay.LINE-NUM:
    if ub.chk-doc.shift-date = pshift-date  and ub.chk-doc.shift-num < pshift-num  then next .
    if ub.chk-doc.shift-date = pshift-date1 and ub.chk-doc.shift-num > pshift-num1 then next .

    if lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next _chk-doc.
    { rep/r-paychk.i }
END.