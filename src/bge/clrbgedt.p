block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: clrbgedt.p $
$Archive: bge/clrbgedt.p $

Устанавливает дату trn-doc.bge-date

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:
    p-table-name as character  - имя таблицы, trn-doc или c-trn-doc
    p-doc-code   as character  - номер документа

Output:

*/

define input parameter p-table-name as character    no-undo.
define input parameter p-doc-code   as character    no-undo.

on write of ub.trn-doc override do: end.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clrbgedt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/clrbgedt.p $":U .
define variable vss-description as character no-undo init "Устанавливает дату trn-doc.bge-date".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error undo, return error
:

    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_c-trn-doc     for ub.c-trn-doc.
    define buffer buf_price-doc     for ub.price-doc.
    define buffer buf_ord-doc       for ub.ord-doc.

    case p-table-name
    :
        when {&table_trn-doc}
        then do:
            find first buf_trn-doc exclusive-lock
                 where buf_trn-doc.doc-code = p-doc-code
      no-error .
      if available buf_trn-doc
      then do:
            assign
                buf_trn-doc.bge-date = ?
            .
      end.
        end.        /* when "trn-doc":U */
        when {&table_c-trn-doc}
        then do:
            for each buf_c-trn-doc exclusive-lock
               where buf_c-trn-doc.doc-code = p-doc-code
            :
                assign
                    buf_c-trn-doc.bge-date = ?
                .
            end.
        end.        /* when "c-trn-doc":U */
    when {&table_price-doc}
    then do:
      on write of ub.price-doc override do: end.
      find first buf_price-doc exclusive-lock
        where buf_price-doc.doc-num = p-doc-code
      no-error .
      if available buf_price-doc
      then do:
        assign
          buf_price-doc.bge-date = ?
        .
      end.
    end. /* when {&table_price-doc} */
    when {&table_ord-doc}
    then do:
      on write of ub.ord-doc override do: end.
      find first buf_ord-doc exclusive-lock
        where buf_ord-doc.doc-code = p-doc-code
      no-error .
      if available buf_ord-doc
      then do:
        assign
          buf_ord-doc.bge-date = ?
        .
      end.
    end. /* when {&table_ord-doc} */
    end case.       /* case p-table-name */
end.