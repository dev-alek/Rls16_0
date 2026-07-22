/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение и заполнение списка дис карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/19/05
Author: Bakhtadze Natalya
Creation date: 12/19/05

Параметры:

  {1} - имя таблицы.

  {2} - необязательный параметр

        def      - если необходимо определение таблицы
        assign   - поиск и присвоение полей таблицы

  {3} - необязательный параметр шарености

  {4} префикс буфера dis-card если {2} = assign

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&if "{2}" = "def" &then

&if defined(dc-list_i_def) = 0 &then

&glob dc-list_i_def

define {3} temp-table {1} no-undo like ub.dis-card
  field to-del as logical
  field order-num as integer
  field fdec as decimal
  field fint as integer
  field flog as logical
  field fchar as character
  /*доп поля на все случаи жизни!!!!*/
  index pi  is primary unique d-card
  index cn      card-num
  index cli cli-type cli-code
  index host-dscnt  emitent-host-code status_ d-pcnt
  index host-type  emitent-host-code type d-pcnt
  index oi order-num
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

&if defined(dc-list_i_else) = 0 &then

&glob dc-list_i_else

find {1}
  where {1}.d-card = {4}dis-card.d-card
  no-error .
if available {1} then do:
  assign
    {1}.to-del = no /* ставим отметку, что запись нужна */
  .
end.
else do:
  create {1} .
  buffer-copy {4}dis-card to {1}
  assign
    {1}.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid ({1})
  .
end.

/*endif not deflined*/
&endif

/*endif else*/
&endif

/* $Workfile$ e n d */