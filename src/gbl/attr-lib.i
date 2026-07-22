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
&if "{1}" = "get" &then
getAttrLib ().
&endif

&if defined (include_attr-lib) = 0 &then
&glob include_attr-lib yes
&if "{1}" = "class" &then

method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.

&else
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
&endif

&if "{1}" = "class" &then
&glob check_attr-lib if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do: ~
    message ~
      "Не загружена библиотека attr-lib" ~
      view-as alert-box error . ~
    stop . ~
end.

&glob run_proc_attr-lib {&check_attr-lib} ~
run ~{&proc-name~} in ibs.th.gbl.gbl-hndllib:g#attr-lib

&else


&glob check_attr-lib if (valid-handle(g#attr-lib) <> true) then do: ~
  run gbl/attr-lib.p persistent no-error . ~
  if error-status :error or (valid-handle(g#attr-lib) <> true) then do: ~
    message ~
      "Error starting attr-lib.p" skip ~
      g#attr-lib skip ~
      g#attr-lib :type skip ~
      g#attr-lib :file-name skip ~
      error-status :get-message(1) skip ~
      return-value skip ~
      view-as alert-box error . ~
    stop . ~
  end. ~
end.

&glob run_proc_attr-lib {&check_attr-lib} ~
run ~{&proc-name~} in g#attr-lib

&glob del_attr-lib if (valid-handle(g#attr-lib) = true) then do: ~
  assign  ~
    v-attr-lib-variable = g#attr-lib ~
  . ~
  apply 'delete':u to g#attr-lib . ~
  delete procedure v-attr-lib-variable . ~
end.

&endif
&endif
/* $Workfile$ e n d */