/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку работы с финансовыми архивами по складским документам

Автор: Чернова Светлана Александровна
Дата создания: 12/29/06
Author: Svetlana Chernova
Creation date: 12/29/06

create: Суслов Алексей Юрьевич
Дата создания: 03/24/06

*/
&if defined (include_libtfarh) = 0 &then
&glob include_libtfarh yes
define new global shared variable g#libtfarh as handle no-undo .

&glob check_libtfarh if (valid-handle(g#libtfarh) <> true) then do: ~
  run str/libtfarh.p persistent no-error . ~
  if error-status :error or (valid-handle(g#libtfarh) <> true) then do: ~
    message ~
      "Error starting libtfarh.p" skip ~
      g#libtfarh skip ~
      g#libtfarh :type skip ~
      g#libtfarh :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_libtfarh {&check_libtfarh} ~
run ~{&proc-name~} in g#libtfarh

&endif
/* $Workfile$ e n d */