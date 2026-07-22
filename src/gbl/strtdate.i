/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Преобразование строки к дате

Автор: Хныкин Павел Андреевич
Дата создания: 03/06/08
Author: Pavel Khnykin
Creation date: 03/06/08

Если преобразование невозможно то процедура возвращает сообщение об ошибке

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure strtdate :
  define input  parameter p-str         as character no-undo .
  define output parameter p-value       as date      no-undo .
  define output parameter p-data-valid  as logical   no-undo .
  define output parameter p-message     as character no-undo .
do
on error undo, return error return-value
:
  define variable v-value       as date      no-undo .
  define variable v-i           as integer   no-undo .
  define variable v-num         as integer   no-undo .
  define variable v-delim       as character no-undo .
  define variable v-delim-list  as character no-undo .
  define variable v-day         as integer   no-undo .
  define variable v-month       as integer   no-undo .
  define variable v-year        as integer   no-undo .
  define variable v-day-str     as character no-undo .
  define variable v-month-str   as character no-undo .
  define variable v-year-str    as character no-undo .

  assign
    p-value       = ?
    p-data-valid  = false
  .

  if p-str = ?
  then do:
    assign
      p-message = substitute("Ошибка задания входных параметров. Не задана строка для преобразования. " )
    .
    return . /* --->>>--- */
  end.

  if p-str = ""
  then do:
    assign
      p-message = substitute("Ошибка задания входных параметров. Задана пустая строка для преобразования. " )
    .
    return . /* --->>>--- */
  end.

  if length(p-str)  > 10
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверная длина строки. " )
    .
    return . /* --->>>--- */
  end.

  assign
    v-delim-list = '/,-,.':U
  .

  _delim:
  do v-i = 1 to num-entries( v-delim-list )
  :
    assign
      v-delim = entry( v-i , v-delim-list )
      v-num   = num-entries( p-str , v-delim )
    .

    if v-num <> 3
    then do:
      assign
        v-delim = ''
      .
    end.
    else do:
      leave _delim.
    end.
  end.

  if v-delim = ''
  then do:
    assign
      p-message = substitute( "Ошибка при преобразовании к дате. Неправильный разделитель, либо ошибочное количество разделителей. " )
    .
    return . /* --->>>--- */
  end.


  assign
    v-day-str   = entry( 1, p-str , v-delim)
    v-month-str = entry( 2, p-str , v-delim)
    v-year-str  = entry( 3, p-str , v-delim)
  .

  if  length(v-day-str) > 2   or
      length(v-day-str) < 1   or
      length(v-month-str) > 2 or
      length(v-month-str) < 1 or
      (
        length(v-year-str) <> 2 and
        length(v-year-str) <> 4
      )
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неправильное количество символов числа, месяца, либо года. " )
    .
    return . /* --->>>--- */
  end.

  if length( v-year-str ) = 2
  then do:
    assign
      v-year-str = substring( string( year(today) ), 1 , 2 ) + v-year-str
    .
  end.

  assign
    v-day   = integer( v-day-str )
    v-month = integer( v-month-str)
    v-year  = integer( v-year-str)
  no-error .
  if error-status :error
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверный формат символов числа, месяца, либо года. " )
    .
    return . /* --->>>--- */
  end.

  if v-day < 1  or
     v-day > 31 or
     v-month < 1 or
     v-month > 12 or
     v-year < 0   or
     v-year > 5000
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. Неверный диапозон числа, месяца, года. " )
    .
    return . /* --->>>--- */
  end.

  assign
    v-value = date( v-month, v-day, v-year )
  no-error .
  if error-status :error
  then do:
    assign
      p-message = substitute("Ошибка при преобразовании к дате. &1. " , error-status :get-message(1))
    .
    return . /* --->>>--- */
  end.

  assign
    p-value       = v-value
    p-data-valid  = true
  .
end.

end procedure. /* strtdate */
/* $Workfile$ e n d */