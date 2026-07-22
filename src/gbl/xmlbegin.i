/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Начать создание xml файла

Автор: Перваков Михаил Сергеевич
Дата создания: 04/06/06
Author: Mikhail Pervakov
Creation date: 04/06/06

Если файл с таким именем существовал, то он перезаписываетс

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name xmlbegin
{&run_proc_library}
  (input  {1} /* p-file-name     */
  ,input  {2} /* p-option-string */
  ) {3} .
/* $Workfile$ e n d */