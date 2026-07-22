/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры работающие с таблицами temp-changes и temp-labels

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/21/06
Author: Bakhtadze Natalya
Creation date: 02/21/06

реализация сравнений и обновлений таблиц

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure tempchgs-check-child-label-record :
define buffer buf_temp-changes for temp-changes.
define buffer buf_child_temp-changes for temp-changes.
define buffer buf_temp-labels for temp-labels.

  do
  on error undo, return error
  :
    for each buf_child_temp-changes
    break
    by buf_child_temp-changes.f_parent:
      if buf_child_temp-changes.f_parent = '':u then next.
      find first buf_temp-changes where
                buf_temp-changes.f_name = buf_child_temp-changes.f_parent no-error.
      if available buf_temp-changes then do:
        assign
        buf_child_temp-changes.f_can_update = no
        buf_child_temp-changes.l_name = fill( {&space-char}, 3) + buf_child_temp-changes.l_name
        .
        find first buf_temp-labels where
                  buf_temp-labels.f_name = buf_child_temp-changes.f_name.
        assign
        buf_temp-labels.f_update = no.
      end.
    end.
  end.

end procedure. /* tempchgs-create-lable-record */



/* $Workfile$ e n d */