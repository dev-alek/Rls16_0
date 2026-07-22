/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку работы с документами

Автор: Чернова Светлана Александровна
Дата создания: 10/09/06
Author: Svetlana Chernova
Creation date: 10/09/06

create : Суслов Алексей Юрьевич

*/
&if defined (include_lib-trn) = 0 &then
&glob include_lib-trn yes

&glob check_lib-trn if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do: ~
  run str/lib-trn.p persistent no-error . ~
  if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do: ~
    message ~
      "Error starting lib-trn.p" skip ~
      ibs.th.gbl.gbl-hndllib:g#lib-trn skip ~
      ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip ~
      ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob check_lib-trn2 if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do: ~
  run str/lib-trn2.p persistent no-error . ~
  if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do: ~
    message ~
      "Error starting lib-trn2.p" skip ~
      ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip ~
      ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip ~
      ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob check_lib-trn3 if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do: ~
  run str/lib-trn3.p persistent no-error . ~
  if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do: ~
    message ~
      "Error starting lib-trn3.p" skip ~
      ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip ~
      ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip ~
      ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob check_lib-trn4 if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do: ~
  run str/lib-trn4.p persistent no-error . ~
  if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do: ~
    message ~
      "Error starting lib-trn4.p" skip ~
      ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip ~
      ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip ~
      ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&if "{1}" = "class" &then
&else
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
&endif

&if "{1}" = "class" &then

&glob run_proc_lib-trn {&check_lib-trn} ~
run ~{&proc-name~} in ibs.th.gbl.gbl-hndllib:g#lib-trn

&glob run_proc_lib-trn2 {&check_lib-trn2} ~ ~
run ~{&proc-name~} in ibs.th.gbl.gbl-hndllib:g#lib-trn2

&glob run_proc_lib-trn3 {&check_lib-trn3} ~
run ~{&proc-name~} in ibs.th.gbl.gbl-hndllib:g#lib-trn3

&glob run_proc_lib-trn4 {&check_lib-trn4} ~
run ~{&proc-name~} in ibs.th.gbl.gbl-hndllib:g#lib-trn4

&else


&glob run_proc_lib-trn {&check_lib-trn} ~
run ~{&proc-name~} in g#lib-trn

&glob run_proc_lib-trn2 {&check_lib-trn2} ~
run ~{&proc-name~} in g#lib-trn2

&glob run_proc_lib-trn3 {&check_lib-trn3} ~
run ~{&proc-name~} in g#lib-trn3

&glob run_proc_lib-trn4 {&check_lib-trn4} ~
run ~{&proc-name~} in g#lib-trn4

&endif
&endif
/* $Workfile$ e n d */