block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fltransp.p $
$Archive: str/fltransp.p $

Изменить цены на величину транспортных расходов без пересчета скидки. flora

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06
*/

define input parameter parparentproc AS WIDGET-HANDLE        NO-UNDO.
define input parameter pardoc-code   like ub.trn-doc.doc-code   no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: fltransp.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/fltransp.p $":U .
define variable vss-description as character no-undo initial "Размазывание наценки за срочность и работу, стоимость доставки по строкам накладной":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/trdcalib.i }


define variable varhost-code  like ub.trn-doc.obj-code no-undo.
define variable v-deliv-rubl  like ub.gds-dtl.price-rubl  no-undo .
define variable v-deliv-base  like ub.gds-dtl.price-rubl no-undo .
define variable v-nac-rubl  like ub.gds-dtl.price-rubl  no-undo .
define variable v-nac-base  like ub.gds-dtl.price-rubl no-undo .

define variable par-sum_deliv like ub.gds-dtl.price-rubl  no-undo .
define variable v-deliv      as character no-undo .
define variable v-sumwrk     as character no-undo .
define variable v-sumsrk     as character no-undo .
define variable v-stop       as character no-undo .
define variable v-type       as character no-undo .

define buffer ready_trn-doc for ub.trn-doc.

find ub.trn-doc where ub.trn-doc.doc-code = pardoc-code no-lock no-error.
if not available ub.trn-doc then do:
   message "Не найден документ с кодом: " pardoc-code
   view-as alert-box.
   return error.
end.

find first ready_trn-doc no-lock where ready_trn-doc.doc-code = ub.trn-doc.out-code and
                                       ready_trn-doc.status_ = {&ready} no-error .
if error-status :error then return.
if ub.trn-doc.status_ <> {&permitted} then return .



&scop attr-temp-full-code ~{&v-code~} = "" . ~
run attr-read in this-procedure (  input ub.trn-doc.doc-code ~
                                ,  input ~{&attr-code~} ~
                                , output ~{&v-code~} ~
                                , output v-type ).

&scop attr-code {&trdcattr-deliv}
&scop v-code    v-deliv
{&attr-temp-full-code}


define variable v-sss      as decimal   no-undo .
define variable v-sss-base as decimal   no-undo .
v-sss = decimal (v-deliv) .
if v-sss = 0 then return .



tr:
do transaction
   ON ERROR   UNDO tr, LEAVE
   ON END-KEY UNDO tr, LEAVE
   ON STOP    UNDO tr , LEAVE :

   { str/tdat-wrt.i
       ub.trn-doc.doc-code
       {&trdcattr-discnt-other}
       "'yes':U"
   }

   for each ub.gds-dtl exclusive-lock   where ub.gds-dtl.doc-code = pardoc-code:
      v-deliv-rubl = 0 .
      v-deliv-base = 0 .
      /*message "цена gds-dtl " gds-dtl.price-rubl skip  "наценка gds-dtl" gds-dtl.discnt-rubl skip par-sum_deliv.*/
       assign

             v-deliv-rubl =  ub.gds-dtl.fact-qnty  * v-sss  /  ub.trn-doc.fact-qnty
             v-deliv-base = v-deliv-rubl  * ub.trn-doc.base-scale / ub.trn-doc.base-rate

             ub.gds-dtl.ov = true
             ub.gds-dtl.price-rubl = ub.gds-dtl.price-rubl + ( v-deliv-rubl / ub.gds-dtl.fact-qnty)
             ub.gds-dtl.price-base = ub.gds-dtl.price-base + ( v-deliv-base / ub.gds-dtl.fact-qnty)
             .
              /* message "цена gds2-dtl " gds-dtl.price-rubl skip  "наценка gds-dtl" gds-dtl.discnt-rubl skip v-deliv-rubl.*/
                /* return error . */

   end.
   assign
      ub.trn-doc.tot-transp = v-sss
      no-error .
   if error-status :error then return error .

 end.

 run gbl/calc-trn.p
     (input parparentproc, input recid(ub.trn-doc)) no-error.
 if error-status :error then return error return-value  .

procedure attr-read :
  define  input parameter p-doc-code like ub.doc-attr.doc-code   no-undo.
  define  input parameter p-code     like ub.doc-attr.attr-code  no-undo.
  define output parameter p-value    like ub.doc-attr.attr-value no-undo.
  define output parameter p-type     as   character              no-undo.

  do on error undo, return error return-value :
    { str/tdat-val.i
        p-doc-code
        p-code
        p-value
        p-type
    }
  end. /* on error */
end procedure. /* attr-read */