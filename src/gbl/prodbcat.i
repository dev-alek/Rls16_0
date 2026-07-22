/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получить атрибут дополнительного бар-кода

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name prodbcat
{&run_proc_library}
  (buffer {1} /* buf_prod-bc        */
  ,input  {2} /* p-action           */
  ,output {3} /* p-return-attribute */
  ) {4} .
/* $Workfile$ */