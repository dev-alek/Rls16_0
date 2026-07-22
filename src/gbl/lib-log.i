/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку работы с log

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/16/09
Author: Bakhtadze Natalya
Creation date: 10/16/09

*/

&if defined (include_lib-log) = 0 &then
&glob include_lib-log yes
define new global shared variable g#lib-log as handle no-undo .

&glob check_lib-log if (valid-handle(g#lib-log) <> true) then do: ~
  run gbl/lib-log.p persistent no-error . ~
  if error-status :error or (valid-handle(g#lib-log) <> true) then do: ~
    message ~
      "Error starting gbl/lib-log.p" skip ~
      g#lib-log skip ~
      g#lib-log :type skip ~
      g#lib-log :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_lib-log {&check_lib-log} ~
run ~{&proc-name~} in g#lib-log

&endif

/* $Workfile$ e n d */