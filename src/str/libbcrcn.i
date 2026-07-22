/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку работы с бар-кодами

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/
&if defined (include_libbcrcn) = 0 &then
&glob include_libbcrcn yes
define new global shared variable g#libbcrcn as handle no-undo .

&glob check_libbcrcn if (valid-handle(g#libbcrcn) <> true) then do: ~
  run str/libbcrcn.p persistent no-error . ~
  if error-status :error or (valid-handle(g#libbcrcn) <> true) then do: ~
    message ~
      "Error starting libbcrcn.p" skip ~
      g#libbcrcn skip ~
      g#libbcrcn :type skip ~
      g#libbcrcn :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_libbcrcn {&check_libbcrcn} ~
run ~{&proc-name~} in g#libbcrcn

&endif
/* $Workfile$ e n d */