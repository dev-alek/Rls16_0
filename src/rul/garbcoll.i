/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

GARBAGE COLLECTOR

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/05/07
Author: Bakhtadze Natalya
Creation date: 02/05/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} variable garbcoll_ii as integer no-undo .

define {1} temp-table temp-gc no-undo
field ii as integer
field obj-r as handle
field cn as character
index pi is unique primary
ii
index icn
cn.


procedure garbcoll_create-gc-entry :
define input parameter p-cn as character no-undo .
define input parameter p-obj-r as handle no-undo .

  do
  on error undo, return error
  :
    create temp-gc.
    assign
    temp-gc.ii = garbcoll_ii
    garbcoll_ii = garbcoll_ii + 1
    temp-gc.cn = p-cn
    temp-gc.obj-r = p-obj-r
    .
  end.

end procedure. /* garbcoll_create-gc-entry */

procedure garbcoll_clear :

  do
  on error undo, return error
  :
    for each temp-gc:
      delete object temp-gc.obj-r.
      delete temp-gc.
    end.
  end.

end procedure. /* garbcoll_clear */






/* $Workfile$ e n d */