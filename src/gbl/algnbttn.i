/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура выравнивания кнопок и упрятывания ненужных

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/30/05
Author: Bakhtadze Natalya
Creation date: 11/30/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure align-buttons :
define input parameter p-frh as handle no-undo . /*handle frame*/
define input parameter p-button-order as character no-undo .
define input parameter p-row as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable bn as character no-undo .
define variable v-col as integer no-undo init 1.
define variable ii as integer no-undo .

  do
  on error undo, return error
  :
  _ii:
    do ii = 1 to num-entries(p-button-order):
      assign
      bn = entry(ii, p-button-order).
      assign
      fh = p-frh:first-child
      hh = fh:first-child
      .
      do while valid-handle(hh):
        if hh:type <> 'button' then do:
          hh = hh:next-sibling.
          next.
        end.
        if hh:row <> p-row then do:
          hh = hh:next-sibling.
          next.
        end.
        if index(p-button-order, hh:name) = 0 then do:
          hh:hidden = yes.
        end.
        else do:
          if bn = hh:name then do:
            assign
            hh:col = v-col
            v-col = v-col + hh:width-chars
            .
          end.
        end.
        hh = hh:next-sibling.
      end. /*do while*/
    end. /*ii*/
  end. /*doe*/

end procedure. /* align-buttons */


/* $Workfile$ e n d */