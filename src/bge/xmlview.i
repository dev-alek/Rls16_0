
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для просмотра выгруженных файлов XML

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Required:
    { cmp/str-glbl.i }
    { gbl/xmlparse.i }
    { gbl/xmlvalid.i }
    для построения временных таблиц по типам файлов экспорта (документам, остаткам,...)
    должны быть включены соответствующие инклуды:

    'DOC':U - { bge/xmlvdoc.i }


*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

define temp-table temp_xmlview no-undo
    field record-id     as integer
    field filename      as character
    field doc-code      as character
    field ext-doc-type  as character
    field fact-date     as date
    field doc-date      as date
    field doc-sum       as decimal
    field ps            as character

    index pi is primary unique record-id
    index dc doc-code
    index et ext-doc-type
.

define variable v-xmlview-format-type   as character    no-undo.
define variable v-xmlview-export-type   as character    no-undo.

/*==========================================================================*/
procedure xmlview-clear-temp_xmlview :

    define buffer buf_temp_xmlview      for temp_xmlview.
do
for buf_temp_xmlview
on error undo, return error
:
    for each buf_temp_xmlview
    :
        delete buf_temp_xmlview.
    end.
end.
end procedure. /* xmlview-clear-temp_xmlview */

/* $Workfile$ e n d */