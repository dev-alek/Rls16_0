/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Текущее системное время сервера БД

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Используется при печати отчетов, при логировании процедур

Гарантируется, что количество секунд от начала дн
соответствует возвращаемой дате.

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if defined(cur-time_i) = 0 &then

&glob cur-time_i yes
{ cmp/str-glbl.i} /* объявим на всякий случай для классов его всегда можно переопределить раньше */
{&CommentStartNoClass}
method private logical cur-time (output p-today as date,
                                 output p-time  as integer ):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
{utl\comment.i} */
   
  do
  on error undo, return error
  :
    
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .

    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .

    if v-date1 <> v-date2
    then do:
      /* если вызов функции происходил в момент смены даты, */
      /* то необходимо сделать повторный запрос */
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.

    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.

end. /* cur-time */

{&CommentStartNoClass}
method private character  cur-time-date () 
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function cur-time-date returns character
{utl\comment.i} */
:
  /* возвращает текущую дату */
  /* длина строки 10 символов */

  return string(today, '99/99/9999':U) .

end.

{&CommentStartNoClass}
method private decimal cur-time-mjd () 
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function cur-time-mjd returns decimal
{utl\comment.i} */
:
  /* return modified julian day number for specified date */
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  {&CommentStartNoClass}
  cur-time
  {utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
  run cur-time in this-procedure
  {utl\comment.i} */
    (output v-date
    ,output v-time
    ) .

  return integer(v-date) - 2400002 + (v-time / 86400) .

end.

{&CommentStartNoClass}
method private integer cur-time-get-ending-index 
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function cur-time-get-ending-index returns integer
{utl\comment.i} */
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.

  define variable v-rest as integer   no-undo .

  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.

  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .

end.

{&CommentStartNoClass}
method private character cur-time-mjd-to-date( 
  input  i-mjd-diff as decimal
,output  o-Date     as date
,output  o-Time     as integer):
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
{utl\comment.i} */
   
   define variable v-day-number as integer   no-undo .
  
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.

   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.

{&CommentStartNoClass}
method private character cur-time-mjd-to-string 
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function cur-time-mjd-to-string returns character
{utl\comment.i} */
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
                                                                      /*   много,      один,      два  */
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
                                                                      /*   много,      одна,      две  */
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .

  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.

  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.

  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .

  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .

end.

{&CommentStartNoClass}
method private character cur-time-string ()
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function cur-time-string returns character
{utl\comment.i} */
:
  /* возвращает текущую дату и время, разделенные пробелом */
  /* длина строки 16 */
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .

  {&CommentStartNoClass}
  cur-time
  {utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
  run cur-time in this-procedure
  {utl\comment.i} */
    (output v-date
    ,output v-time
    ) .

  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.

{&CommentStartNoClass}
method private character cur-time-string-sec ()
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function cur-time-string-sec returns character
{utl\comment.i} */
:
  /* возвращает текущую дату и время с точностью до секунды, разделенные пробелом */
  /* длина строки 19 */
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .

  {&CommentStartNoClass}
  cur-time
  {utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
  run cur-time in this-procedure
  {utl\comment.i} */
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .

end.

{&CommentStartNoClass}
method private character cur-time-custom 
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function cur-time-custom  returns character
{utl\comment.i} */
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  /* возвращает текущую дату и время */
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .

  {&CommentStartNoClass}
  cur-time
  {utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
  run cur-time in this-procedure
  {utl\comment.i} */
    (output v-date
    ,output v-time
    ) .

  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .

end.

{&CommentStartNoClass}
method private character cur-time-print ()
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function cur-time-print  returns character
{utl\comment.i} */
:
  /* возвращает текущую дату и время печати */
  /* длина строки 33 символа */

  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .

  {&CommentStartNoClass}
  cur-time
  {utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
  run cur-time in this-procedure
  {utl\comment.i} */
    (output v-date
    ,output v-time
    ) .

  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .

end.

{&CommentStartNoClass}
method private datetime cur-time-datetime ()
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function cur-time-datetime returns datetime
{utl\comment.i} */
:

  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.



end.

{&CommentStartNoClass}
method private character cur-time-string-msec ()
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function cur-time-string-msec returns character
{utl\comment.i} */
:
  /* возвращает текущую дату и время с точностью до милисекунды */  
  define variable v-date as datetime  no-undo .  

  v-date = now.
  
  return string(v-date) .

end.

&endif

/* $Workfile$ */