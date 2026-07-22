/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Радиотерминал. Конвертирование строки с кодом товара

Автор: Хныкин Павел Андреевич
Дата создания: 02/13/08
Author: Pavel Khnykin
Creation date: 02/13/08

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure rt-cnvdc_decode :
  define input  parameter p-encoded-str as character no-undo .
  define output parameter p-decoded-str as character no-undo .

do
on error undo, return error return-value
:
  define variable v-decoded-str as character no-undo .

  assign
    v-decoded-str = replace(p-encoded-str,  'c':u, 'с':u )
    v-decoded-str = replace(v-decoded-str,  'm':u, 'м':u )
    p-decoded-str = v-decoded-str
  .
end.

end procedure. /* rt-cnvdc_decode */

/* $Workfile$ e n d */