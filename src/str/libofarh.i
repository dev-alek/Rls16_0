/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку работы с финансовыми архивами по финобязательствам

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/
&if defined (include_libofarh) = 0 &then
&glob include_libofarh yes
define new global shared variable g#libofarh as handle no-undo .

&glob check_libofarh if (valid-handle(g#libofarh) <> true) then do: ~
  run str/libofarh.p persistent no-error . ~
  if error-status :error or (valid-handle(g#libofarh) <> true) then do: ~
    message ~
      "Error starting libofarh.p" skip ~
      g#libofarh skip ~
      g#libofarh :type skip ~
      g#libofarh :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_libofarh {&check_libofarh} ~
run ~{&proc-name~} in g#libofarh

&endif
/* $Workfile$ e n d */