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

/* trigger procedure for create of ub.pl-level */

&if "{1}" <> "" and "{2}" <> "" &then
  create {1}.
  assign {1}.obj-type = {2}.obj-type
         {1}.obj-code = {2}.obj-code
         {1}.pl-code  = {2}.pl-code.
&endif

/* $Workfile$   E n d */

