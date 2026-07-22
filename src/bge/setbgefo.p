block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: setbgefo.p $
$Archive: bge/setbgefo.p $

Устанавливает дату выгрузки в атрибут ФО

Автор: Хныкин Павел Андреевич
Дата создания: 03/03/06
Author: Pavel Khnykin
Creation date: 03/03/06

Дата создания: 12/14/04

Input:
    p-table-name as character  - имя таблицы, fin-ob
    p-doc-code   as integer  - номер документа
    p-cur-date   as date       - дата, которую надо прописать в атрибут bge-date
*/

on write of ub.fin-ob-attr override do: end.

define input parameter p-table-name        as character    no-undo.
define input parameter p-host-code         as integer   no-undo.
define input parameter p-doc-code          as character no-undo .
define input parameter p-corr-user-db-num  as integer no-undo .
define input parameter p-chip-num          as integer no-undo .
define input parameter p-cur-date          as date       no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: setbgefo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/setbgefo.p $":U .
define variable vss-description as character no-undo init "Устанавливает дату выгрузки в атрибут ФО".
{ cmp/vssrevis.i "substitute('&1|&2|&3|&4|&5|&6':u, p-table-name, p-host-code, p-doc-code, p-corr-user-db-num, p-chip-num, p-cur-date)" }
{ cmp/trg-def.i }
{ str/fo-attr.i }

do
on error undo, return error
:

define buffer buf_fin-ob-attr  for ub.fin-ob-attr.

case p-table-name:
  when "fin-ob":U  then do:
    run create-fin-ob-attr  in this-procedure (
                                                 input p-host-code
                                                ,input p-doc-code
                                                ,input {&fo-bge-date}
                                                ,input string(p-cur-date, "99/99/9999")
                                              ) no-error .
   end.
  end case.       /* case p-table-name */
  if error-status:error then do:
    return error (vss-workfile + {&space-char} + vss-revision + {&space-char} + vss-description + {&space-char}  +  return-value ).
  end.
end.