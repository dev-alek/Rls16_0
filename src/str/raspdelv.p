block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: raspdelv.p $
$Archive: str/raspdelv.p $

Размазывание наценки за срочность и работу, стоимость доставки по строкам накладной. flora

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 01/21/05


*/

define input parameter parparentproc AS WIDGET-HANDLE        NO-UNDO.
define input parameter pardoc-code   like trn-doc.doc-code   no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: raspdelv.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/raspdelv.p $":U .
define variable vss-description as character no-undo initial "Размазывание наценки за срочность и работу, стоимость доставки по строкам накладной":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/trdcalib.i }

define variable varhost-code  like trn-doc.obj-code no-undo.
define variable v-deliv-rubl  like gds-dtl.price-rubl  no-undo .
define variable v-deliv-base  like gds-dtl.price-rubl no-undo .
define variable v-nac-rubl  like gds-dtl.price-rubl  no-undo .
define variable v-nac-base  like gds-dtl.price-rubl no-undo .

define variable par-sum_deliv like gds-dtl.price-rubl  no-undo .
define variable v-deliv      as character no-undo .
define variable v-sumwrk     as character no-undo .
define variable v-sumsrk     as character no-undo .
define variable v-stop       as character no-undo .
define variable v-type       as character no-undo .

define buffer ready_trn-doc for trn-doc.

find trn-doc where trn-doc.doc-code = pardoc-code no-lock no-error.
find first ready_trn-doc no-lock where ready_trn-doc.doc-code = trn-doc.out-code and
                                       ready_trn-doc.status_ = {&ready} no-error .
if error-status :error then return.
if trn-doc.status_ <> {&permitted} then return .



&scop attr-temp-full-code ~{&v-code~} = "" . ~
~{ str/tdat-val.i ~
     trn-doc.doc-code  ~
     ~{&attr-code~}    ~
     ~{&v-code~}    ~
     v-type ~
~}

&scop attr-code {&trdcattr-deliv}
&scop v-code    v-deliv
{&attr-temp-full-code}
&scop attr-code {&trdcattr-sumwrk}
&scop v-code    v-sumwrk
{&attr-temp-full-code}
&scop attr-code {&trdcattr-sumsrk}
&scop v-code    v-sumsrk
{&attr-temp-full-code}
define variable v-sum  like gds-dtl.price-rubl    no-undo .
define variable v-sss as decimal   no-undo .

define variable v-sum-new-rubl as character no-undo .
define variable i-sum-rubl as decimal   no-undo .


  { str/tdat-val.i
      trn-doc.doc-code
      {&trdcattr-discnt-stop}
      v-sum-new-rubl
      v-type
  }
      i-sum-rubl = dec (v-sum-new-rubl) .
   if i-sum-rubl = 0 then return error .


   v-sss = decimal (v-deliv) .

if par-sum_deliv = ? then par-sum_deliv = 0.

define variable v-sum-rm as decimal   no-undo .


v-sum-rm =  ( (i-sum-rubl -  v-sss )  * 100 / ( 100 - trn-doc.discnt-pc )) - trn-doc.tot-sale .


{ gbl/hostcode.i trn-doc.obj-type trn-doc.obj-code varhost-code }


if not available trn-doc then do:
   message "Не найден документ с кодом: " pardoc-code
   view-as alert-box.
   return error.
end.

tr:
do transaction
   ON ERROR   UNDO tr, LEAVE
   ON END-KEY UNDO tr, LEAVE
   ON STOP    UNDO tr , LEAVE :

   for each gds-dtl exclusive-lock where gds-dtl.doc-code = pardoc-code:
      v-deliv-rubl = 0 .
      v-deliv-base = 0 .
      v-nac-rubl = 0 .
      v-nac-base = 0 .

      /*message "цена gds-dtl " gds-dtl.price-rubl skip  "наценка gds-dtl" gds-dtl.discnt-rubl skip par-sum_deliv.*/
       assign
             v-nac-base = gds-dtl.price-base  * v-sum-rm / ( trn-doc.tot-sale  )
             v-nac-rubl = gds-dtl.price-rubl  * v-sum-rm / ( trn-doc.tot-sale  )

             v-deliv-rubl = gds-dtl.price-rubl  *  gds-dtl.fact-qnty  * v-sss /  trn-doc.tot-sale
             v-deliv-base = v-deliv-rubl  * trn-doc.base-scale / trn-doc.base-rate

             gds-dtl.ov = true
             gds-dtl.price-rubl = gds-dtl.price-rubl + v-nac-rubl
             gds-dtl.price-base = gds-dtl.price-base + v-nac-base
             .
              find first doc-line exclusive-lock where
                         doc-line.doc-code = gds-dtl.doc-code  and
                         doc-line.artic    = gds-dtl.artic     and
                         doc-line.prod-type = gds-dtl.prod-type and
                         doc-line.prod-code = gds-dtl.prod-code no-error .
             if available doc-line then do:
             doc-line.transport-rubl = ( if doc-line.transport-rubl = ? then 0 else doc-line.transport-rubl ) + v-deliv-rubl .
             doc-line.transport-base = ( if doc-line.transport-base = ? then 0 else doc-line.transport-base ) + v-deliv-base .
           /*  message doc-line.transport-rubl   skip
                     v-deliv-rubl .
                     */
             end.

             else do:
             message error-status :get-message(1) "error" .
             return error .
             end.
              /* message "цена gds2-dtl " gds-dtl.price-rubl skip  "наценка gds-dtl" gds-dtl.discnt-rubl skip par-sum_deliv. */
                /* return error . */

   end.
   assign
      trn-doc.tot-transp = v-deliv-rubl
      no-error .
   if error-status :error then return error .
 end.