/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку работы с финансовыми архивами

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/
&if defined (include_lib-farh) = 0 &then
&glob include_lib-farh yes
define new global shared variable g#lib-farh as handle no-undo .

&glob check_lib-farh if (valid-handle(g#lib-farh) <> true) then do: ~
  run str/lib-farh.p persistent no-error . ~
  if error-status :error or (valid-handle(g#lib-farh) <> true) then do: ~
    message ~
      "Error starting lib-farh.p" skip ~
      g#lib-farh skip ~
      g#lib-farh :type skip ~
      g#lib-farh :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_lib-farh {&check_lib-farh} ~
run ~{&proc-name~} in g#lib-farh

&endif
/* $Workfile$ e n d */