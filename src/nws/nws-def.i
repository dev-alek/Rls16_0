/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

определение глобальных переменных для системы передачи новостей

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/
/*
  В ЭТОМ ФАЙЛЕ НЕДОПУСТИМО ИСПОЛЬЗОВАТЬ ССЫЛКИ НА КАКУЮ-ЛИБО БАЗУ ДАННЫХ
*/
{ adm/auto-def.i {1} }

&glob pck-end  **END OF PACKET**

define {1} shared variable nws-exch-dir as character no-undo .
define {1} shared variable nws-heap-dir as character no-undo .

define variable err-mess as character no-undo .

define temp-table t-pck-conf no-undo
  field db-num-dst      as integer
  field db-num-src      as integer
  field pack-num        as integer
  field total-recs      as integer
  field sys-key         as character
  field src_db-key      as character
  field dst_db-key      as character
  field ver-num         as character
  field prev-crc        as character
  field actual-date     as date
  field actual-time-int as integer
.

/* $Workfile$ end */