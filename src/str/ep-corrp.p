block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ep-corrp.p $
$Archive: str/ep-corrp.p $

Лечение возврата поставщику. Цены документа выставляются в средние учетные

Автор: Чернова Светлана Александровна
Дата создания: 12/04/07
Author: Svetlana Chernova
Creation date: 12/04/07


*/
define input  parameter parparentproc as handle no-undo .
define input  parameter p-doc-code    as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ep-corrp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/ep-corrp.p $":U .
define variable vss-description as character no-undo init "Лечение возврата поставщику. Цены документа выставляются в средние учетные".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/clcprtsl.i }

define buffer buf_doc-line for ub.doc-line  .
define buffer buf_trn-doc for ub.trn-doc    .
define buffer buf_gds-dtl for ub.gds-dtl    .
define buffer buf_parts for ub.parts  .

do
on error undo, return error return-value
:

find first buf_trn-doc exclusive-lock where
           buf_trn-doc.doc-code = p-doc-code
           no-error .

  if  buf_trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_VP} then do:
    message "Это не ВОЗВРАТ ПОСТАВЩИКУ!"  view-as alert-box .
    return .
  end.


 for each buf_doc-line exclusive-lock
    where buf_doc-line.doc-code = p-doc-code
 :
    find first buf_parts no-lock where
               buf_parts.out-code  = p-doc-code and
               buf_parts.obj-type  = buf_trn-doc.obj-type and
               buf_parts.obj-code  = buf_trn-doc.obj-code and
               buf_parts.artic     = buf_doc-line.artic and
               buf_parts.prod-type = buf_doc-line.prod-type and
               buf_parts.prod-code = buf_doc-line.prod-code no-error .
    if not available buf_parts then next .

    buf_doc-line.vat-pc =  buf_parts.vat-pc.
    buf_doc-line.slt-pc =  buf_parts.slt-pc.

    empty temp-table tt-allsum-line.

    run clcprtsl_calc-line in this-procedure (
        input recid( buf_doc-line )
    ).
    find first tt-allsum-line
         where tt-allsum-line.sum-type = {&sum-general}
         no-error.
         assign
           buf_doc-line.price-base = tt-allsum-line.sum-dsc-base-acc / buf_doc-line.fact-qnty
           buf_doc-line.price-rubl = tt-allsum-line.sum-dsc-rubl-acc / buf_doc-line.fact-qnty
           buf_doc-line.vat-pc = 100 / ( ( tt-allsum-line.sum-dsc-base-doc / vat-base-doc ) - 1  )
         .
         if buf_doc-line.vat-pc = ? then  buf_doc-line.vat-pc =  0 .

    for each buf_gds-dtl exclusive-lock where
            buf_gds-dtl.doc-code  = buf_doc-line.doc-code  and
            buf_gds-dtl.artic     = buf_doc-line.artic     and
            buf_gds-dtl.prod-type = buf_doc-line.prod-type and
            buf_gds-dtl.prod-code = buf_doc-line.prod-code  :
         assign
           buf_gds-dtl.price-base = tt-allsum-line.sum-dsc-base-acc / buf_gds-dtl.fact-qnty
           buf_gds-dtl.price-rubl = tt-allsum-line.sum-dsc-rubl-acc / buf_gds-dtl.fact-qnty
         .
    end.
end.

release buf_trn-doc.
find first buf_trn-doc exclusive-lock where
           buf_trn-doc.doc-code = p-doc-code
           no-error .

run gbl/calc-trn.p (input parparentproc, input recid(buf_trn-doc)) no-error.
end.