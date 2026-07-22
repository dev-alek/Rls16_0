block-level on error undo, throw.
/*

$Revision: 2d6430604525, 1301, rls $
$Author: EShklyar $
$Date: Tue Apr 10 12:04:11 2018 +0300 $
$Workfile: setbgefd.p $
$Archive: bge/setbgefd.p $

Устанавливает дату выгрузки в атрибут платежа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/09/04
Author: Bakhtadze Natalya
Creation date: 12/09/04

Input:
    p-table-name as character  - имя таблицы, fin-doc или c-fin-doc
    p-fin-doc-code   as integer  - номер документа
    p-cur-date   as date       - дата, которую надо прописать в атрибут bge-date
*/

define input parameter p-table-name        as character    no-undo.
define input parameter p-host-code         as integer   no-undo.
define input parameter p-fin-doc-code      as integer    no-undo.
define input parameter p-corr-user-db-num  as integer no-undo .
define input parameter p-chip-num          as integer no-undo .
define input parameter p-cur-date          as date       no-undo.

define variable vss-revision    as character no-undo init "$Revision: 2d6430604525, 1301, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Apr 10 12:04:11 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: setbgefd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/setbgefd.p $":U .
define variable vss-description as character no-undo init "Устанавливает дату выгрузки в атрибут платежа".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6':u, p-table-name, p-host-code, p-fin-doc-code, p-corr-user-db-num, p-chip-num, p-cur-date)" }
{ cmp/trg-def.i }

do
on error undo, return error
:

define buffer buf_fin-doc  for ub.fin-doc.
define buffer buf_c-fin-doc     for ub.c-fin-doc.

case p-table-name:
  when "fin-doc":U  then do:
    find first buf_fin-doc exclusive-lock where
             buf_fin-doc.host-code = p-host-code
        AND  buf_fin-doc.fin-doc-code = p-fin-doc-code no-error .
      if available buf_fin-doc then assign
          buf_fin-doc.bge-date = p-cur-date
      .
   end.        /* when "trn-doc":U */
   when "c-fin-doc":U then do:
    find first buf_c-fin-doc exclusive-lock where
             buf_c-fin-doc.host-code = p-host-code
        AND  buf_c-fin-doc.fin-doc-code = p-fin-doc-code
        AND  buf_c-fin-doc.corr-user-db-num = p-corr-user-db-num
        AND  buf_c-fin-doc.chip-num       = p-chip-num no-error.
      if available buf_c-fin-doc then assign
          buf_c-fin-doc.bge-date = p-cur-date
      .

   end.        /* when "trn-doc":U */
  end case.       /* case p-table-name */
  if error-status:error then do:
    return error (vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description + {&space-char}  +  return-value ).
  end.
end.