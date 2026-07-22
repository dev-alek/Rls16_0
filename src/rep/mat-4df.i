/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение временной таблицы со всей нужной информацией по матценностям (ЮКОС лист 4)

Автор: Булгаков Андрей Николаевич
Дата создания: 04/13/06
Author: Andrew Bulgakoff
Creation date: 04/13/06

*/

define {1} temp-table tmat-4 no-undo
  field netto-before as decimal   format "-999,999,999.99":U
  field netto-after  as decimal   format "-999,999,999.99":U
  field in-benefit   as decimal   format "999,999,999.99":U
  field in-other     as decimal   format "999,999,999.99":U
  field out-bank     as decimal   format "999,999,999.99":U
  field out-other    as decimal   format "999,999,999.99":U
  field out-name     as character format "x(16)":U
  field gg           as integer
  index igg          is primary   unique gg
.

/* $Workfile$   E n d */

