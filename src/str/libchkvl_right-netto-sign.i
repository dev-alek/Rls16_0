/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Инклюд для определения внешней функции libchkvl_right-netto-sign

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/05/08
Author: Bakhtadze Natalya
Creation date: 08/05/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{&func_libchkvl}
  {1} = libchkvl_right-netto-sign (
                                  input  {2} /* p-chk-type */
                                  ) {3}
 .


/* $Workfile$ e n d */