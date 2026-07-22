block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rcs-oper.p $
$Archive: rcs/rcs-oper.p $

Экспорт документов по архивам

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 09/15/05
Author: Victor Guntner
Creation date: 09/15/05

Input:
    v-oper-num  - номер операции (неверный номер - запись в лог).
    dFrom       - начальная дата.
    dTo         - конечная дата.
    sOutFile    - имя файла .xm1 для вывода (вызывающая программа создает и по завершении
                    экспорта переименовывает этот файл в .xml. Сделано для синхронизации с
                    блоком импорта во внешней бухгалтерии.
    sLogFile    - полное имя файла для записи событий.

Output:

*/
define input parameter p-host-code       as character               no-undo.
define input parameter p-obj-type        as character               no-undo.
define input parameter p-obj-code        as integer                 no-undo.
define input parameter p-ext-doc-type    as character               no-undo.
define input parameter p-oper-name       as character               no-undo.
define input parameter p-rcs-doc-type    as character               no-undo.
define input parameter p-fact-order-from like stk-tot.fact-order    no-undo.
define input parameter p-fact-order-to   like stk-tot.fact-order    no-undo.
define input parameter p-pay-code        as logical                 no-undo.
define input parameter p-cst             as logical                 no-undo.
define input parameter p-head-file       as character               no-undo.
define input parameter p-body-file       as character               no-undo.
define input parameter sLogFile          as character               no-undo.
define input parameter hEDT              as handle                  no-undo.
define input parameter hCNT              as handle                  no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcs-oper.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rcs/rcs-oper.p $":U .
define variable vss-description as character no-undo init "Экспорт документов по архивам".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ rcs/rcs-xml.i  }

    define variable l-exist-operation   as logical  no-undo.
    define variable v-qnty              like ot-tot.fact-qnty   no-undo.
    define variable v-doc-date          like trn-doc.doc-date   no-undo.
    define variable v-fact-date         like trn-doc.fact-date  no-undo.
    define variable v-pay-code          like trn-doc.fact-date  no-undo.
    define variable v-doc-PS            like trn-doc.PS         no-undo.
    define variable v-parts-cst-code    like parts.cst-code     no-undo.
    define variable v-rcs-doc-id        as character            no-undo.

    define temp-table temp_inkas-pay no-undo
        field pay-code  like inkas-pay.pay-code
        field tot-base  like inkas-pay.tot-base
        field tot-rubl  like inkas-pay.tot-rubl
        field tot-sum   like inkas-pay.tot-sum
    index pi is primary unique pay-code
    .

    define buffer buf_ot-tot-sale           for ot-tot.
    define buffer buf_ot-tot-cost           for ot-tot.
    define buffer buf_ot-tot-crsa           for ot-tot.
    define buffer buf_ot-line-sale          for ot-line.
    define buffer buf_ot-line-cost          for ot-line.
    define buffer buf_ot-line-crsa          for ot-line.
    define buffer buf_doc-line              for doc-line.
    define buffer buf_rcs-shops             for rcs-shops.
    define buffer buf_rcs-retail1subject    for rcs-retail1subject.
    define buffer buf_rcs-retail1product    for rcs-retail1product.
    define buffer buf_rcs-retail1bill       for rcs-retail1bill.
    define buffer buf_rcs-retail1price      for rcs-retail1price.
do
for buf_ot-tot-sale
  , buf_ot-tot-cost
  , buf_ot-tot-crsa
  , buf_ot-line-sale
  , buf_ot-line-cost
  , buf_ot-line-crsa
  , buf_doc-line
  , buf_rcs-shops
  , buf_rcs-retail1subject
  , buf_rcs-retail1product
  , buf_rcs-retail1bill
  , buf_rcs-retail1price
on error undo, return error
:
    assign
    l-exist-operation = no
    .
    output stream stmXMLHead to value( p-head-file + ".xm1") convert target "1251" append .
    output stream stmXMLBody to value( p-body-file + ".xm1") convert target "1251" append .
    run wp-XMLWriteCNT( input hCNT, input "":U ).
    if p-ext-doc-type = {&TDEDT_Overturn}
    then do:
        { rcs/rcs-oper.i Overturn }
    end.
    else do:
        { rcs/rcs-oper.i }
    end.
    output stream stmxmlhead close.
    output stream stmxmlbody close.
end.