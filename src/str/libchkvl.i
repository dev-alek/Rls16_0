/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку проверки валидности чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/14/08
Author: Bakhtadze Natalya
Creation date: 07/14/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined (include_libchkvl) = 0 &then
&glob include_libchkvl yes
define new global shared variable g#libchkvl as handle no-undo .
function libchkvl_right-netto-sign returns integer ( input p-chk-type as integer) in G#libchkvl.


&glob check_libchkvl if (valid-handle(g#libchkvl) <> true) then do: ~
  run str/libchkvl.p persistent no-error . ~
  if error-status :error or (valid-handle(g#libchkvl) <> true) then do: ~
    message ~
      "Error starting nws/libchkvl.p" skip ~
      g#libchkvl skip ~
      g#libchkvl :type skip ~
      g#libchkvl :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_libchkvl {&check_libchkvl} ~
run ~{&proc-name~} in g#libchkvl

&glob func_libchkvl {&check_libchkvl}


&endif


/* $Workfile$ e n d */