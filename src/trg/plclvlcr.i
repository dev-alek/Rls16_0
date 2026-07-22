/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

триггер на создание записи градуировочной таблицы по резервуару на объекте

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/20/06
Author: Dmitry Ukhanov
Creation date: 01/20/06

*/

/* trigger procedure for create of ub.c-pl-level */

&if "{1}" <> "" and "{2}" <> "" &then
  create {1}.
  assign {1}.obj-type = {2}.obj-type
         {1}.obj-code = {2}.obj-code
         {1}.pl-code  = {2}.pl-code
         {1}.chip-num = next-value( s-corr-chip, {&db-name_schema} ).
&endif

/* $Workfile$   E n d */

