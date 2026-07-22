/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

проверка и создание каталога для генерации

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/01/06
Author: Dmitry Ukhanov
Creation date: 03/01/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

if trim( {1} ) = "":U then do:
  assign
    {1} = ".":U
  .
end.

assign
  file-info:file-name = {1}
.

if file-info :full-pathname = ""
or file-info :full-pathname = ?  then do:
  message
    vss-workfile vss-revision vss-description skip
    substitute( "Уазанный каталог (&1) не найден!", {1} ) skip
    view-as alert-box error .
  undo, return error .
end.
assign
  {1} = file-info:full-pathname + "/":U
.
&if "{2}":U <> "":U &then
  run gbl/dir-cre.p ( input {1} + "{2}":U ) no-error .
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при создании каталога &1", {1} + "{2}":U ) skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error.
  end.
&endif
/* $Workfile$ e n d */