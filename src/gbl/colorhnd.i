/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

раскрашивание widget-ов по списку имен через handle

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/30/03
Author: Bakhtadze Natalya
Creation date: 11/30/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure proc-color-widgets :
define input parameter p-list as character no-undo .
/*список имен widget-ов*/
define input parameter p-fg as logical no-undo .
/*раскрашивать foreground*/
define input parameter p-bg as logical no-undo .
/*раскрашивать background*/
define input parameter p-fgc as integer no-undo .
/*краска для fg*/
define input parameter p-bgc as integer no-undo .
/*краска для bg*/

define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .

  do
  on error undo, return error
  :
    assign
    fh = frame {&frame-name}:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if LOOKUP(hh:name, p-list) > 0  then do:
        assign
        hh:fgcolor = (if p-fg then p-fgc else hh:fgcolor)
        hh:bgcolor = (if p-bg then p-bgc else hh:bgcolor)
        .
      end.
      hh = hh:next-sibling.
    end. /*do while*/
  end. /*doe*/

end procedure. /* proc-color-widgets */

/* $Workfile$ e n d */