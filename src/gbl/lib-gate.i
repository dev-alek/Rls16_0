/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку работы с GATE

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/07/09
Author: Bakhtadze Natalya
Creation date: 10/07/09

*/

&if defined (include_lib-gate) = 0 &then
&glob include_lib-gate yes
define new global shared variable g#lib-gate as handle no-undo .

&glob check_lib-gate if (valid-handle(g#lib-gate) <> true) then do: ~
  run gbl/lib-gate.p persistent no-error . ~
  if error-status :error or (valid-handle(g#lib-gate) <> true) then do: ~
    message ~
      "Error starting gbl/lib-gate.p" skip ~
      g#lib-gate skip ~
      g#lib-gate :type skip ~
      g#lib-gate :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_lib-gate {&check_lib-gate} ~
run ~{&proc-name~} in g#lib-gate

&endif

/* $Workfile$ e n d */