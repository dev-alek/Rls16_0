/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обновить информацию в браузере

Автор: Перваков Михаил Сергеевич
Дата создания: 03/09/05
Author: Mikhail Pervakov
Creation date: 03/09/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

on f5 of frame {&frame-name} anywhere
do:
  &if "{1}" = "" &then
  {&OPEN-QUERY-{&browse-name}}
  &else
  {1}
  &endif
  &if defined(browse-name) &then
    apply "VALUE-CHANGED" to {&browse-name}.
  &endif
end.

/* $Workfile$ e n d */