/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка почасового отчета по покупкам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/05/05
Author: Bakhtadze Natalya
Creation date: 09/05/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

run waitfram-show in this-procedure ("Строю дерево групп ..."). /*пробелы не стирать!!!*/
if rs-option = 3 then do:
  create full-grp.
  assign
  full-grp.grp-code = 0
  full-grp.full-name = "По всем группам товаров".
end.
else do:
  for each ub.gds-grp no-lock:
    find first for-grp where
              for-grp.upper-code = ub.gds-grp.node-code No-LOCK No-ERROR.
    if not avail for-grp then do:
      create full-grp.
      assign full-grp.grp-code = ub.gds-grp.node-code.
      run grplib-get-full-name in this-procedure(input ub.gds-grp.node-code, output full-grp.full-name).
    end.
  end.
end.
run waitfram-hide in this-procedure .

/* $Workfile$ e n d */