/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку работы с новостями

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/14/06
Author: Bakhtadze Natalya
Creation date: 07/14/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined (include_lib-nws) = 0 &then
&glob include_lib-nws yes
define new global shared variable g#lib-nws as handle no-undo .

&glob check_lib-nws if (valid-handle(g#lib-nws) <> true) then do: ~
  run nws/lib-nws.p persistent no-error . ~
  if error-status :error or (valid-handle(g#lib-nws) <> true) then do: ~
    message ~
      "Error starting nws/lib-nws.p" skip ~
      g#lib-nws skip ~
      g#lib-nws :type skip ~
      g#lib-nws :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_lib-nws {&check_lib-nws} ~
run ~{&proc-name~} in g#lib-nws

&endif

/* $Workfile$ e n d */