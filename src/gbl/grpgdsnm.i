/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получить полное имя группы товаров для поиска и сортировки

Автор: Перваков Михаил Сергеевич
Дата создания: 04/12/06
Author: Mikhail Pervakov
Creation date: 04/12/06

Возвращенное полное имя совместимо с оператором begins
Всегда заканчивается знаком {&delim-grp}

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name grpgdsnm
{&run_proc_library}
  (input  {1} /* p-obj-type */
  ,output {2} /* p-db-num   */
  ) {3} .
/* $Workfile$ */