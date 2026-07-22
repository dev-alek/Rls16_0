/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение пункта меню

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/06/09
Author: Dmitry Ukhanov
Creation date: 10/06/09

Автор2: Белоусов Илья Александрович
Дата создания2: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop seq {&sequence}
procedure {1}%cr{&seq} :
  define output parameter p-call-point      as character no-undo .
  define output parameter p-proc-name       as character no-undo .
  define output parameter p-proc-file       as character no-undo .
  define output parameter p-install         as logical   no-undo .
  define output parameter p-mainmenu-handle as logical   no-undo .
  define output parameter p-db-ver          as character no-undo .
  define output parameter p-run-order       as character no-undo .
  define output parameter p-client          as character no-undo initial "":U .
  define variable conf-par  as character no-undo .             /* для чтения параметра конфигурации */
  define variable par-type  as character no-undo .            /* тип параметра конфигурации */
  assign p-call-point      = "{1}":u p-proc-name = {2}  p-proc-file = {3}  p-install = lookup ( "{4}", "true,yes") > 0  p-mainmenu-handle = lookup ( "{8}", "true,yes") > 0 .
  &if "{5}" <> "" &then
    assign p-db-ver = {5}  p-run-order = {6} .
  &endif
  &if "{7}" <> "" and "{7}" <> "all" &then
    assign p-client = {7} .
  &endif
  &if "{9}" <> "" &then
      run gbl/conf-rd.p ( {9}, "", "", 0, "", "", "", yes, output conf-par, output par-type) no-error.
      if error-status:error or par-type <> "l" or conf-par <> "yes" then do:  return error. end.
  &endif
end procedure .
/* $Workfile$ e n d */