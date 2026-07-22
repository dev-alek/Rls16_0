/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура подсчета суммы текущих продажных цен на момент закрытия документа для строки документа.

Автор: Демин Алексей Сергеевич
Дата создания: 09/15/05
Author: Alexey Demin
Creation date: 09/15/05

Required:

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$".

/*
    Input:
        doc-code
        artic
        prod-type
        prod-code
    Output:
        fact-qnty
        vat-pc
        slt-pc
        sum-r-b     - сумма в текущих продажных ценах
*/
procedure r-c-sale :
do
on error undo, return error
:

{ str/out-vatp.i def }

define input parameter p-doc-code           like doc-line.doc-code          no-undo .
define input parameter p-artic              like doc-line.artic             no-undo .
define input parameter p-prod-type          like doc-line.prod-type         no-undo .
define input parameter p-prod-code          like doc-line.prod-code         no-undo .

define output parameter p-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
define output parameter p-vat-pc            like ub.doc-line.vat-pc         no-undo .
define output parameter p-slt-pc            like ub.doc-line.slt-pc         no-undo .
define output parameter p-sum-r-b           like ub.ot-line.sum-base        no-undo .

def var v-gds-dtl-fact-qnty                 as decimal                      no-undo .

define buffer buf_gds-dtl  for ub.gds-dtl.
define buffer buf_goods    for ub.goods.
define buffer buf_trn-doc  for ub.trn-doc.
define buffer buf_doc-line for ub.doc-line.

find first buf_doc-line no-lock
     where buf_doc-line.doc-code  = p-doc-code
       and buf_doc-line.artic     = p-artic
       and buf_doc-line.prod-type = p-prod-type
       and buf_doc-line.prod-code = p-prod-code
no-error .
if not available buf_doc-line then do:
    message "r-c-sale: Ошибка передачи параметров строки документа"
    view-as alert-box.
    undo, return error .
end.
find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_doc-line.doc-code
no-error .
if not available buf_trn-doc then do:
    message "r-c-sale: Нет trn-doc для строки документа " string(buf_doc-line.doc-code)
    view-as alert-box.
    undo, return error .
end.
/* расчет продажной цены документа с учетом скидок (ндс и нсп документа) */
for each buf_gds-dtl no-lock
   where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
     and buf_gds-dtl.artic     = buf_doc-line.artic
     and buf_gds-dtl.prod-type = buf_doc-line.prod-type
     and buf_gds-dtl.prod-code = buf_doc-line.prod-code
on error undo, return error
:
    if buf_trn-doc.doc-type <> {&inventory}
    then do:
        if buf_trn-doc.doc-type = {&income}
        or buf_trn-doc.doc-type = {&return}
        then do:
            assign
                v-gds-dtl-fact-qnty = buf_gds-dtl.fact-qnty
            .
        end.
        else do:
            assign
                v-gds-dtl-fact-qnty = - buf_gds-dtl.fact-qnty
            .
        end.
    end.
    else do:
        assign
            v-gds-dtl-fact-qnty = buf_gds-dtl.doc-qnty
        .
    end.

    if v-gds-dtl-fact-qnty <> 0
    then do:
        ASSIGN
            p-fact-qnty           = p-fact-qnty     + v-gds-dtl-fact-qnty
            p-sum-r-b             = p-sum-r-b       + buf_gds-dtl.cur-base  * v-gds-dtl-fact-qnty
        .
    end.
end.
assign
    p-vat-pc              = buf_doc-line.vat-pc
    p-slt-pc              = buf_doc-line.slt-pc
.

end.
end procedure.

/* $Workfile$ e n d */