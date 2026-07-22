block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: flornakl.p $
$Archive: str/flornakl.p $

Выбор букета или композиции , в котор входит товар если нужно

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06


*/
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-mode as character no-undo .
define input  parameter p-doc-code as character no-undo .
define output parameter p-exist as logical   no-undo .
define output parameter p-buket-gds-code as integer   no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: flornakl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/flornakl.p $":U .
define variable vss-description as character no-undo init "Выбор букета".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define variable g#host-name  as character no-undo .
define variable g#host-code  as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .

{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }

define buffer buf_trn-doc for trn-doc .
define buffer buf_doc-line for doc-line .
define buffer buf_goods for goods.
define variable v-ok as logical   no-undo .
define variable v-ok-nabor as logical   no-undo .

DEFINE VARIABLE v-codes as character no-undo .
DEFINE VARIABLE v-labels as character no-undo .
DEFINE VARIABLE v-options as character no-undo .
p-exist = false .
p-buket-gds-code = ? .
if p-mode = "" then do:
   /* накл */
    { str/flornakl.i p-doc-code v-ok}
    if  v-ok  = false then return .
    define buffer got_trn-doc for trn-doc .
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code and
                                        buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} and
                                        buf_trn-doc.status_ = {&wayb} and
                                        buf_trn-doc.flag_ = false no-error .
    if not available buf_trn-doc then return .
end.
else do:
 /* готов */
 find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code no-error .
end.

for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.out-code :
    find  first buf_goods where
                buf_goods.artic     = buf_doc-line.artic and
                buf_goods.prod-type = buf_doc-line.prod-type and
                buf_goods.prod-code = buf_doc-line.prod-code no-lock no-error .

    { str/grpnabor.i buf_goods.gds-code v-ok-nabor}
    if v-ok-nabor = true then do:
        v-codes  = v-codes   + string(buf_goods.gds-code)  +  {&comma-char} .
        v-labels = v-labels  + string(buf_goods.artic, "x(16)") + " " + string(buf_goods.gds-name)  +  {&comma-char} .
        p-exist = true .
    end.
end.

run gbl/d-list.w
 ( "b-sel":U,
  "Выберите нетоварную позицию, в которую входит товар" ,
  v-codes ,
  v-labels ,
  {&comma-char} ,
  "":U ,
  output v-options) .

p-buket-gds-code = integer ( v-options ) .