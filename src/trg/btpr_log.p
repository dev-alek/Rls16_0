block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запись информации в систему о завершении batch процесса

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/20/00

*/

define input parameter p-numprocesscycle as integer no-undo .
define input parameter p-numidlecycle    as integer no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запись информации в систему о завершении batch процесса".
{ cmp/vssrevis.i }
{ gbl/cur-time.i }

define variable s-lastexecinfo as character no-undo .

assign
  s-lastexecinfo = cur-time-string() + ','
/*                + ( if {&curr_station} = ? then "{&curr_station}=?" else {&curr_station} ) + ','*/
/*                + ( if {&curr_user}    = ? then " curr_user=?"    else {&curr_user}    ) + ','*/
                + ( if p-numprocesscycle = ? then "p-numprocesscycle=?" else string(p-numprocesscycle  ))
.