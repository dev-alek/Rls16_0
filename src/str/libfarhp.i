/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Внутренние процедуры для работы с библиотекой работы с финансовыми архивами по финдокументам

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/
&if defined (include_libfarhp) = 0 &then
&glob include_libfarhp yes
define new global shared variable g#libfarhp as handle no-undo .

&glob check_libfarhp if (valid-handle(g#libfarhp) <> true) then do: ~
  run str/libfarhp.p persistent no-error . ~
  if error-status :error or (valid-handle(g#libfarhp) <> true) then do: ~
    message ~
      "Error starting libfarhp.p" skip ~
      g#libfarhp skip ~
      g#libfarhp :type skip ~
      g#libfarhp :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_libfarhp {&check_libfarhp} ~
run ~{&proc-name~} in g#libfarhp

&endif
/* $Workfile$ e n d */