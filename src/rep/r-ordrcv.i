/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

График поставок (заполение temp-table)

Автор: Комаров Иван Сергеевич
Дата создания: 10/08/10
Author: Ivan Komarov
Creation date: 10/08/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

  create temp-ord-rcv.
  assign
      temp-ord-rcv.doc-code  = buf_ord-doc.doc-code
      temp-ord-rcv.post-code = buf_ord-doc.cli-code
      temp-ord-rcv.post-name = buf_ord-doc.cli-name
      temp-ord-rcv.ship-date = buf_ord-doc.real-date
  .

  if p-det-rcv then do :
    find first buf_ord-doc-rcv no-lock
        where buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
          and buf_ord-doc-rcv.obj-code = obj-list.obj-code
          and buf_ord-doc-rcv.obj-type = obj-list.obj-type
          no-error.
          if available buf_ord-doc-rcv then do:
              assign
                temp-ord-rcv.rcv-code   = buf_ord-doc-rcv.rcv-code
                temp-ord-rcv.rcv-status = buf_ord-doc-rcv.status_
              .
          end.
  end.

/* $Workfile$   E n d */
