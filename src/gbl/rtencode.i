/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Закодировать информацию для экспорта в текстовый файл для радиотерминала

Автор: Хныкин Павел Андреевич
Дата создания: 27/02/07
Author: Pavel Khnykin
Creation date: 27/02/07

create: Перваков Михаил Сергеевич
Дата создания: 10/07/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

function rtencode returns character
  ( p-init-string as character
  ) :

  define variable v-encode-string as character no-undo .

  if p-init-string = ?
  then do:
    assign
      v-encode-string = '?':u
    .
    return v-encode-string .
  end.

  if p-init-string = '?':u
  then do:
    assign
      v-encode-string = '~~077':u
    .
    return v-encode-string .
  end.

  /* обратимое кодирование для того,                */
  /* чтобы в программе обработки запроса можно было */
  /* произвести обратное преобразование             */
  assign
    v-encode-string = replace(p-init-string,   '~~':u,      '~~176':u)
    v-encode-string = replace(v-encode-string, ':':u,       '~~072':u)
    v-encode-string = replace(v-encode-string, {&new-line}, '~~015':u)
  .

  return v-encode-string .

end function .

/* $Workfile$ e n d */