block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 17 июля 2019 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 17 июля 2019 г.

*/
&glob doc-code idoc-code

define input parameter parparentproc as widget-handle no-undo .
define input parameter idoc-code     as character no-undo.

define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
define variable v-curr-r-b as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
{ cmp/vssrevis.i }
{ cmp/library.i  }
{ cmp/str-glbl.i } 
{ rep/real3tm.i }
{ gbl/getcntxt.i def }
{ rep/r-pychk0.i defalgo }
{ rep/r-pychk0.i def }
define variable g#auto as logical no-undo.
{ gbl/curr-r-b.i
  v-curr-r-b
}
define variable v-host-code      as integer no-undo .
{ gbl/getcntxt.i get }
 { gbl/hostcode.i v-cntxt-obj-type v-cntxt-obj-code v-host-code }

{ gbl/basecode.i v-host-code v-base-code }
  if v-curr-r-b = {&r-b-base} or
  v-base-code = 0 then pychk_NO-exch = yes.
  else pychk_No-exch = no.
  if v-curr-r-b = {&r-b-rubl} or
  v-base-code = 0 then pychk_NO-exch-rubl = yes.
  else pychk_No-exch-rubl = no.


_chk-doc:
 for each ub.chk-doc  where
         chk-doc.doc-code eq {&doc-code} 
         no-lock ,
     each ub.chk-pay no-lock where
           ub.chk-pay.doc-code = ub.chk-doc.doc-code
   break
   by ub.CHK-pay.doc-code
   by ub.CHK-pay.line-num:
   { rep/r-pychk0.i }
 end.