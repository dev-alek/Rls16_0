/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&if defined (include_library) = 0 &then
&glob include_library yes

&if "{1}" = "class" &then
&else
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
&endif

&if "{1}" = "class" &then

&glob run_proc_library {&check_library} ~
run ~{&proc-name~} in ibs.th.gbl.gbl-hndllib:g#library

&glob run_proc_library2 {&check_library2} ~
run ~{&proc-name~} in ibs.th.gbl.gbl-hndllib:g#library2

&else

&glob check_library if (valid-handle(g#library) <> true) then do: ~
  run gbl/library.p persistent no-error . ~
  if error-status :error or (valid-handle(g#library) <> true) then do: ~
    message ~
      "Error starting library.p" skip ~
      g#library skip ~
      g#library :type skip ~
      g#library :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_library {&check_library} ~
run ~{&proc-name~} in g#library

&glob check_library2 if (valid-handle(g#library2) <> true) then do: ~
  run gbl/library2.p persistent no-error . ~
  if error-status :error or (valid-handle(g#library2) <> true) then do: ~
    message ~
      "Error starting library2.p" skip ~
      g#library2 skip ~
      g#library2 :type skip ~
      g#library2 :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_library2 {&check_library2} ~
run ~{&proc-name~} in g#library2
&endif
&endif

/* $Workfile$ e n d */