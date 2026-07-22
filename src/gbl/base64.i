/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Преобразование в кодировку base64

Автор: Перваков Михаил Сергеевич
Дата создания: 05/20/03
Author: Mikhail Pervakov
Creation date: 05/20/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure base64-encode :

  define input  parameter v-string        as character no-undo .
  define output parameter v-base64-encode as character no-undo .


  do
  on error undo, return error return-value
  :
    define variable v-raw     as raw       no-undo .
    define variable v-raw-str as character no-undo .

    if v-string = ?
    then do:
      undo, return error "base64-encode: строка имеет неопределенное значение" .
    end.

    assign
      length(v-raw) = length(v-string) + 1
    .
    assign
      put-string(v-raw, 1) = v-string
    .
    assign
      v-raw-str = string(v-raw)
    .
    assign
      length(v-raw) = 0
    .
    assign
      v-base64-encode = substring(v-raw-str, 7)
    .
  end.
end.

/* $Workfile$ e n d */