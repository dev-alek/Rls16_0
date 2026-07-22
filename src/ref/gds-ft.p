block-level on error undo, throw.
/*
$Revision: e455fc319afd, 3602, rls $
$Author: ARostovtsev $
$Date: 2023/12/28 12:56:37 $
$Workfile: gds-ft.p $
$Archive: ref/gds-ft.p $

Âûáîğ òèïà òîïëèâà, àòğèáóò òîâàğà

Àâòîğ: Ãğèä÷èíà Ïîëèíà Äìèòğèåâíà
Äàòà ñîçäàíèÿ: 14/08/04
Author: Gridchina Polina
Creation date: 14/08/04
*/

define input parameter p-mode as character no-undo .
DEFINE INPUT PARAMETER p-gds-code AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER p-spr-param AS character NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-attr-value AS character NO-UNDO.
DEFINE OUTPUT PARAMETER p-setted AS LOGICAL NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision: e455fc319afd, 3602, rls $":U .
define variable vss-author      as character no-undo init "$Author: ARostovtsev $":U .
define variable vss-date        as character no-undo init "$Date: 2023/12/28 12:56:37 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gds-ft.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gds-ft.p $":U .
define variable vss-description as character no-undo init "Âûáîğ òèïà òîïëèâà, àòğèáóò òîâàğà".

{ cmp/vssrevis.i }
{ gbl/waitfram.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ rep/frmlib.i }

def var v-choose as char no-undo.

  run gbl/d-list.w (
              INPUT "b-sel":U
              ,INPUT "Âûáåğèòå òèï òîïëèâà"
              ,INPUT "petrol,diesel,diesel-sum,diesel-wint,metan,propan,lgas,arctic,megsesson"
              ,INPUT "Áåíçèí,ÄÒ,ÄÒ ëåòíåå,ÄÒ çèìíåå,Ìåòàí,Ïğîïàí,ÑÓÃ,ÄÒ Àğêòè÷åñêîå,ÄÒ Ìåæñåçîííîå"
              ,INPUT {&comma-char}
              ,INPUT  p-attr-value
              ,output v-choose).

p-attr-value = v-choose.
if p-attr-value > '' then p-setted = yes.
