block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: bge-head.p $
$Archive: bge/bge-head.p $

Определение полного имени файла и вывод заголовка файла XML

Автор: Хныкин Павел Андреевич
Дата создания: 04/05/06
Author: Pavel Khnykin
Creation date: 04/05/06

Input:

Output:

*/

define input parameter p-subdir             as character    no-undo.
define input parameter p-file-name          as character    no-undo.
define input parameter p-message-to-log     as character    no-undo.
define input parameter p-shedule            as logical      no-undo.
define output parameter p-xml-file-name     as character    no-undo.    /* возвращается полное имя с точкой, без расш.*/
define output parameter p-log-file-name     as character    no-undo.    /* возвращается полное имя с расширением */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bge-head.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bge-head.p $":U .
define variable vss-description as character no-undo init "Определение полного имени файла и вывод заголовка файла XML".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ bge/bge-xml.i      }
{ cmp/library.i      }
{ gbl/getcntxt.i def }

&scoped-define SubDir exp-acc

    define variable v-permission     as logical           no-undo.
    define variable v-home-dir       as character         no-undo.
    define variable v-error-num      as integer           no-undo.
    define variable v-locked         as logical           no-undo.
    define variable v-counter        as integer           no-undo.
do
on error undo, return error
:
/*---start--------- Найти в ini-файле каталог экспорта и определить полное имя файла ---------------------*/
run bge/bge-ini.p ( "bge", output v-home-dir ).
if return-value <> "OK" then return error.
assign
    v-home-dir = v-home-dir + "/" + p-subdir
.
/* удостовериться, что директория $FRG-ACC/{&SubDir} создана и доступна */
run bge/dir_cd.p ( v-home-dir, "CA" ).
if return-value = "ERROR" then return error.
assign
    p-xml-file-name = v-home-dir + "/" + p-file-name + "."
.
/*---end----------- Найти в ini-файле каталог экспорта и определить полное имя файла ---------------------*/
/* найти исходный файл */
assign
    v-locked = ( search ( p-xml-file-name + "xml" ) <> ? ).
.
/* найти файл блокировки */
DO v-counter = 1 TO 3 while v-locked:
    assign
        v-locked = ( search ( p-xml-file-name + "lk" ) <> ? )
    .
    if v-locked then readkey pause 1.
end.
/* читают/обновляют в приложении - запись невозможна */
if v-locked
then do:
    return error "LOCKED".
end.
/* удалить старый файл */
run bge/os_copy.p ( "D", p-xml-file-name + "xml", "", output v-error-num ).
if v-error-num > 0 then return error string( v-error-num ).
assign
    p-log-file-name = v-home-dir + "/" + "actions.log"
.

run wp-XMLWriteLog( p-log-file-name, 0, "&DLine" ).
run wp-XMLWriteLog( p-log-file-name, 1, p-message-to-log ).

end.