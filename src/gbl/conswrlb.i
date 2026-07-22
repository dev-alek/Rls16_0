/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку записи в консольное окно

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

define new global shared variable g#conswrlb as handle no-undo .

&glob check_conswrlb if (valid-handle(g#conswrlb) <> true) then do: ~
  run gbl/conswrlb.p persistent no-error . ~
  if error-status :error or (valid-handle(g#conswrlb) <> true) then do: ~
    message ~
      "Error starting conswrlb.p" skip ~
      g#conswrlb skip ~
      g#conswrlb :type skip ~
      g#conswrlb :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_conswrlb {&check_conswrlb} ~
run ~{&proc-name~} in g#conswrlb
/* $Workfile$ e n d */