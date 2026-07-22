/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение и заполнение списка стран

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/13/09
Author: Bakhtadze Natalya
Creation date: 10/13/09


Параметры:

  {1} - имя таблицы.

  {2} - необязательный параметр

        def      - если необходимо определение таблицы
                   с индексами: obj  (alpha1)
                                iname (short-name)
        assign   - поиск и присвоение полей таблицы

  {3} - необязательный параметр
        параметры определения.
  {4} - необязательный параметр - префикс буфера таблицы country
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{2}" = "def" &then
def {3} temp-table {1} no-undo like ub.country
  field to-del as logical
  index obj  is primary unique alpha1
  index iname      short-name
  .

  /* история заполнения списка */
&if "{5}" <> "no-hist" &then
  &if "{3}" <> ' ' &then
  { cmp/listhist.i {1} "{3}" {5} }
  &else
  { cmp/listhist.i {1} {5} }
  &endif
&endif

&else
find {1}
  where {1}.alpha1 = {4}country.alpha1
  no-error .
if available {1} then do:
  assign
    {1}.to-del = no /* ставим отметку, что запись нужна */
  .
end.
else do:
  create {1} .
  buffer-copy {4}country to {1}
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