/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Поиск Поставок с code39

Автор: Чернова Светлана Александровна
Дата создания: 07/22/09
Author: Svetlana Chernova
Creation date: 07/22/09

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/* Пока такой вариант */
procedure find-rcv-code39 :
define input  parameter p-code39   as character no-undo .
define output parameter p-rcv-code as character no-undo .

define buffer buf_ord-doc-rcv for ub.ord-doc-rcv  .
define buffer buf_ord-line-rcv for ub.ord-line-rcv  .
define buffer buf_ord-doc for ub.ord-doc  .


  do
  on error undo, return error return-value
  :
    for each buf_ord-doc no-lock where
             buf_ord-doc.status_   = {&ord-rcv}  and
           ( buf_ord-doc.ord-int1  = integer({&edoc-pst-ok})  or
             buf_ord-doc.ord-int1  = integer({&edoc-pst}) )
             :
        for each buf_ord-doc-rcv no-lock where
                 buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code :
        for each buf_ord-line-rcv no-lock where
                 buf_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code  and
                 buf_ord-line-rcv.rcv-code  = buf_ord-doc-rcv.rcv-code  and
                 buf_ord-line-rcv.sub-par   = p-code39
                 :
                p-rcv-code = buf_ord-line-rcv.rcv-code.

        end.
        end.

    end.
  end.

end procedure. /* find-rcv-code39 */
