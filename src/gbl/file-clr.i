/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создать файл нулевой длины

Автор: Перваков Михаил Сергеевич
Дата создания: 05/21/03
Author: Mikhail Pervakov
Creation date: 05/21/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name file-clr
{&run_proc_library}
  (input {1} /* p-file-name */
  ) {2} .
/* $Workfile$ */