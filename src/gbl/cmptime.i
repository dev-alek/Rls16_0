/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сравнение дат

Автор: Хныкин Павел Андреевич
Дата создания: 04/13/06
Author: Pavel Khnykin
Creation date: 04/13/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*==========================================================================*/
/* Получение разности даты-времени на сервере и на клиенте в минутах
   Input:
        нет
   Output:
        p-difference as decimal

   ВНИМАНИЕ!!! После процедуры необходимо восстановить значение session :time-source

*/
procedure cmptime :
do
on error undo, return error
:
define output parameter p-difference as decimal      no-undo.

define variable v-srv-time      as decimal           no-undo.
define variable v-cli-time      as decimal           no-undo.

assign
    session :time-source = "ub":U
    v-srv-time = integer(today) + ( time / 86400 )        /* Кол-во секунд в сутках 60 * 60 * 24 */
.
assign
    session :time-source = "LOCAL":U
    v-cli-time = integer(today) + ( time / 86400 )        /* Кол-во секунд в сутках */
.
assign
    p-difference = ( v-srv-time - v-cli-time ) * 1440     /* Кол-во минут в дне 24 * 60 */
.
end.
end procedure. /* cmptime */


/*==========================================================================*/
/* Получение разности двух дат (со временем)
   Input:
        p-date1    as date     -  первая дата.
        p-time1    as integer  -  первое время.
        p-date2    as date     -  вторая дата.
        p-time2    as integer  -  второе время.
   Output:
        p-difference as decimal  - разность ( дата2, время2 ) - ( дата1, время1)

*/
procedure cmptime-time-diff :
do
on error undo, return error
:
define input parameter p-date1          as date         no-undo.
define input parameter p-time1          as integer      no-undo.
define input parameter p-date2          as date         no-undo.
define input parameter p-time2          as integer      no-undo.
define output parameter p-difference    as decimal      no-undo.
    assign
        p-difference = ( integer( p-date2 ) - integer( p-date1 ) + ( ( p-time2 - p-time1 ) / 86400 ) ) * 1440
    .
end.
end procedure. /* cmptime-time-diff */

/*==========================================================================*/
/*  Из строки в формате hh:mm:ss или hh:mm получить три целых числа: часы, минуты, секунды.
   Input:
        p-time-string as character   - строка в формате hh:mm:ss или hh:mm
        p-format      as character   - формат строки, "hh:mm:ss" или "hh:mm"
   Output:
        p-hour as integer  - часы
        p-min  as integer  - минуты
        p-sec  as integer  - секунды
*/
procedure cmptime-string-to-hms :
do
on error undo, return error
:
define input parameter p-time-string as character    no-undo.
define input parameter p-format      as character    no-undo.
define output parameter p-hour as integer      no-undo.
define output parameter p-min  as integer      no-undo.
define output parameter p-sec  as integer      no-undo.

if p-format <> "hh:mm" and p-format <> "hh:mm:ss"
then do:
    message
      "cmptime.i: Ошибка преобразования строки даты"
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
assign
    p-hour      = integer ( entry( 1, p-time-string, ":" ) )
    p-min       = integer ( entry( 2, p-time-string, ":" ) )
    p-sec       = ( if p-format = "hh:mm:ss"
                    then integer ( entry( 3, p-time-string, ":" ) )
                    else 0
                  )
.

end.
end procedure. /* cmptime-string-to-hms */

/*==========================================================================*/
/*  Преобразование заданных часа, минуты, секунды в integer
   Input:
        p-hour as integer  - часы
        p-min  as integer  - минуты
        p-sec  as integer  - секунды
   Output:
        p-time  as integer - врем
*/
procedure cmptime-hms-to-integer :
do
on error undo, return error
:
define input parameter p-hour   as integer      no-undo.
define input parameter p-min    as integer      no-undo.
define input parameter p-sec    as integer      no-undo.
define output parameter p-time  as integer      no-undo.
    assign
        p-time = p-hour * 3600 + ( p-min * 60 ) + p-sec
    .
end.
end procedure. /* cmptime-hms-to-integer */