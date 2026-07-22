/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку работы с POS IBS TH

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/14/08
Author: Bakhtadze Natalya
Creation date: 07/14/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined (include_libthpos) = 0 &then
&glob include_libthpos yes
define new global shared variable g#libthpos as handle no-undo .

&glob check_libthpos if (valid-handle(g#libthpos) <> true) then do: ~
  run str/libthpos.p persistent no-error . ~
  if error-status :error or (valid-handle(g#libthpos) <> true) then do: ~
    message ~
      "Error starting nws/libthpos.p" skip ~
      g#libthpos skip ~
      g#libthpos :type skip ~
      g#libthpos :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_libthpos {&check_libthpos} ~
run ~{&proc-name~} in g#libthpos

&endif

/* $Workfile$ e n d */