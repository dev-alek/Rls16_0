/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение и заполнение списка групп товаров

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/18/08
Author: Bakhtadze Natalya
Creation date: 06/18/08


Параметры:

  {1} - имя таблицы.

  {2} - def      - если необходимо определение таблицы
        assign   - поиск и присвоение полей таблицы

  {3} - необязательный параметр
        параметры определения.
  {4} - buffer gds-grp

  {5} - параметр отмены таблицы истории заполнения списка
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


&if "{4}" = "" &then
  &scop buffer-gds-grp gds-grp
&else
  &scop buffer-gds-grp {4}
&endif


&if "{2}" = "def" &then

&if defined(ggrplist_i_def) = 0 &then

&glob ggrplist_i_def


define {3} temp-table {1} no-undo like ub.gds-grp
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field full-name as character
  index pi  is primary unique node-code
  index ifn full-name
  index is-term
  is-term
  node-name
  index level
  upper-code
  node-name
  index level-num
  lvl-num
  upper-code
  node-name
  index oi order-num
  index isel to-sel
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

&endif

/* $Workfile$ e n d */