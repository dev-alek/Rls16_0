/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение и заполнение списка клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/24/05
Author: Bakhtadze Natalya
Creation date: 12/24/05


Параметры:

  {1} - имя таблицы.

  {2} - необязательный параметр

        def      - если необходимо определение таблицы
                   с индексами: obj  (obj-type, obj-code)
                                cli-name (obj-name)
        assign   - поиск и присвоение полей таблицы

  {3} - необязательный параметр
        параметры определения.
  {4} - необязательный параметр - префикс буфера таблицы clients
  {5} - no-hist без таблицы истории, shared и "new shared" - тип таблицы истории 
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{2}" = "def" &then

&if defined(cli-list_i_def) = 0 &then

&glob cli-list_i_def


def {3} temp-table {1} no-undo like ub.clients
  field to-del as logical
  index obj  is primary unique obj-type obj-code
  index cli-name      obj-name
  .

  /* история заполнения списка */
&if "{5}" <> "no-hist" &then
  &if "{3}" <> ' ' &then
  { cmp/listhist.i {1} "{3}" {5} }
  &else
  { cmp/listhist.i {1} {5} }
  &endif
&endif

&endif

&else
find {1}
  where {1}.obj-type = {4}clients.obj-type
    and {1}.obj-code = {4}clients.obj-code
  no-error .
if available {1} then do:
  assign
    {1}.to-del = no /* ставим отметку, что запись нужна */
  .
end.
else do:
  create {1} .
  buffer-copy {4}clients to {1}
  assign
    {1}.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid ({1})
  .
end.
&endif
/* $Workfile$ e n d */