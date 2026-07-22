/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку работы с документами

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 09/19/05


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined (include_lib-calc) = 0 &then
&glob include_lib-calc yes
define new global shared variable g#lib-calc as handle no-undo .

&glob check_lib-calc if (valid-handle(g#lib-calc) <> true) then do: ~
  run str/lib-calc.p persistent no-error . ~
  if error-status :error or (valid-handle(g#lib-calc) <> true) then do: ~
    message ~
      "Error starting lib-calc.p" skip ~
      g#lib-calc skip ~
      g#lib-calc :type skip ~
      g#lib-calc :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_lib-calc {&check_lib-calc} ~
run ~{&proc-name~} in g#lib-calc

&endif
/* $Workfile$ e n d */