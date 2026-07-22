/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инициализация динамических полей для оборотки по топливным товарам

Автор: Уханов Дмитрий Юрьевич
Дата создания: 06/30/05
Author: Dmitry Ukhanov
Creation date: 06/30/05

*/

&if "{1}" <> "CHARACTER" and "{3}" = "?" &then
  &message Неверные параметры поля {5} "{6}": тип - {1}, формат - x({2}).
&else
  assign l-col-type   = "{1}"
         l-col-len    =  {2}
         l-col-format = &if "{3}" = "?" &then "x({2})":U &else "{3}":U &endif
         l-col-lable  = "{4}" .
  { rep/r-ob1cr.i cr2 {5} {6} }
&endif

/* $Workfile$   E n d */

