/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Внутренние процедуры для работы с библиотекой работы с финансовыми архивами по финдокументам (объектная часть)

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/
&if defined (include_libfarpo) = 0 &then
&glob include_libfarpo yes
define new global shared variable g#libfarpo as handle no-undo .

&glob check_libfarpo if (valid-handle(g#libfarpo) <> true) then do: ~
  run str/libfarpo.p persistent no-error . ~
  if error-status :error or (valid-handle(g#libfarpo) <> true) then do: ~
    message ~
      "Error starting libfarpo.p" skip ~
      g#libfarpo skip ~
      g#libfarpo :type skip ~
      g#libfarpo :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_libfarpo {&check_libfarpo} ~
run ~{&proc-name~} in g#libfarpo

&endif
/* $Workfile$ e n d */