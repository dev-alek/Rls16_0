/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку ассортиментных матриц

Автор: Чернова Светлана Александровна
Дата создания: 01/22/09
Author: Svetlana Chernova
Creation date: 01/22/09

*/

&if defined (include_lib-Matrix) = 0 &then
&glob include_lib-Matrix yes
define new global shared variable g#lib-Matrix  as handle no-undo .

&glob check_lib-Matrix if (valid-handle(g#lib-Matrix) <> true) then do: ~
  run ref/gds-mat1.p persistent no-error . ~
  if error-status :error or (valid-handle(g#lib-Matrix) <> true) then do: ~
    message ~
      "Error starting library.p" skip ~
      g#lib-Matrix skip ~
      g#lib-Matrix :type skip ~
      g#lib-Matrix :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_lib-Matrix {&check_lib-Matrix} ~
run ~{&proc-name~} in g#lib-Matrix
&endif