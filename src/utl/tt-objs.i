/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

список 'критических' объектов

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/29/01
Author: Dmitry Ukhanov
Creation date: 11/29/01

*/

define {1} shared temp-table tt-objs no-undo
  field obj-type as character
  field obj-code as integer
  index pi is unique primary obj-type obj-code
  .


/* $Workfile$ e n d */