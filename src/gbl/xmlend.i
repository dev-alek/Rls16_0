/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Завершить создание xml файла

Автор: Перваков Михаил Сергеевич
Дата создания: 04/06/06
Author: Mikhail Pervakov
Creation date: 04/06/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name xmlend
{&run_proc_library}
  (input  {1} /* p-file-name */
  ) {2} .
/* $Workfile$ e n d */