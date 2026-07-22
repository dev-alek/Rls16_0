/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

библиотека для автозаказов

Автор: Мазуров Виталий Александрович
Дата создания: 19/09/11
Author: Vitaliy Mazurov
Creation date: 19/09/11

*/

&scop  start-proc do on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)

define variable v-ii as integer no-undo .

/*создание и заполнение таблицы с датами праздников*/
define buffer buf_sysconf-attr for ub.sysconf-attr .
define temp-table tt-holyday no-undo
field holy-date as date
index pi
holy-date
.
find first buf_sysconf-attr no-lock
     where buf_sysconf-attr.attr-code = "holyday"
       and buf_sysconf-attr.host-code = 0
       and buf_sysconf-attr.attr-value <> "" no-error.
if available buf_sysconf-attr then do :
  do v-ii = 1 to num-entries(buf_sysconf-attr.attr-value,",") :
    if not can-find(first tt-holyday where tt-holyday.holy-date = date(entry(v-ii, buf_sysconf-attr.attr-value, ",")) ) then do :
      create tt-holyday .
      assign
        tt-holyday.holy-date = date(entry(v-ii, buf_sysconf-attr.attr-value, ","))
      .
    end.
  end.
end.

/*возвращает true если номер недели входит в расписание*/
function get-weeks-true returns logical ( input p-from   as date,
                                          input p-repeat as integer,
                                          input p-wday   as integer ):
  define variable v-begin as date    no-undo .
  define variable v-wcnt  as integer no-undo .

  assign
    v-begin = TODAY - p-wday + 1  /*считаем дату понедельника*/
    v-wcnt = 1
  .
  /*считаем номер недели событиja*/
  do while not (TODAY >= v-begin and TODAY <= v-begin + 7) :
      assign
        v-begin = v-begin + 7
        v-wcnt = v-wcnt + 1
      .
  end.

  /*если номер недели не входит в расписание, то false*/
  /*считается каждая p-repeat неделя начиная с первой, т.е. 1...1+p-repeat...*/
  if not (v-wcnt - 1) / p-repeat = round((v-wcnt - 1) / p-repeat, 0) then return false .

  return true .
end function.

/*возвращает true если сегодняшняя дата входит в указанный период и попадает в расписание*/
function get-period-true returns logical (input p-dates  as character,
                                          input p-wdays  as character,
                                          input p-repeat as integer ):
  define variable v-sdate-from as character no-undo .
  define variable v-sdate-to   as character no-undo .
  define variable v-wday       as integer   no-undo .

  assign
    v-sdate-from = substring(entry(1, p-dates, "-"), 1, 2) + "/" +
                   substring(entry(1, p-dates, "-"), 3, 2) + "/" +
                   substring(entry(1, p-dates, "-"), 5, 4)
    v-sdate-to   = substring(entry(2, p-dates, "-"), 1, 2) + "/" +
                   substring(entry(2, p-dates, "-"), 3, 2) + "/" +
                   substring(entry(2, p-dates, "-"), 5, 4)
    v-wday       = ( if weekday(TODAY) = 1 then 7 else weekday(TODAY) - 1 )
  .
  /*если за пределами периода, то возвращаем false*/
  if TODAY < date(v-sdate-from) or TODAY > date(v-sdate-to) then return false .

  /*если номер недели не входит в расписание, то возвращаем false*/
  if p-repeat > 1 and not get-weeks-true(date(v-sdate-from), p-repeat, v-wday) then return false .

  /*если день недели не входит в расписание, то возвращаем false*/
  if entry(v-wday, p-wdays) = "no" then return false .

  return true .
end function.

/*возвращает true если host-code совпадают*/
function get-host-true returns logical (input p-host-code as integer, input p-client as character):
  define variable v-obj-code  as integer   no-undo .
  define variable v-obj-type  as character no-undo .
  define variable v-host-code as integer   no-undo .

  assign
    v-obj-type = substring(p-client, 1, 3)
    v-obj-code = int(substring(p-client, 4))
  .

  { gbl/hostcode.i v-obj-type v-obj-code v-host-code }

  if p-host-code = v-host-code then return true .

  return false .
end function.

/*расчитываем период расчета для метода расчета*/
procedure check-dates-method:
  define input param p-days-do   as integer no-undo .
  define input param p-days-sale as integer no-undo .
  define input-output param p-method as character no-undo .

  define variable v-dbegin as date      no-undo .
  define variable v-from   as date      no-undo .
  define variable v-to     as date      no-undo .
  define variable v-i      as integer   no-undo .
  define variable v-extw   as integer   no-undo .
  define variable v-mth    as character no-undo init "" .

  /*дата начала продаж*/
  v-dbegin = TODAY + p-days-do .

  /*расчет дат периода расчета*/
  assign v-extw = 0 .
  _check_period:
  repeat:
     /*дата начала периода расчета*/
     if p-days-sale / 7 > truncate(p-days-sale / 7, 0)
     then v-from  = v-dbegin - ((truncate(p-days-sale / 7, 0) + 1 + v-extw) * 7) .
     else v-from  = v-dbegin - ((truncate(p-days-sale / 7, 0) + v-extw) * 7) .
     /*дата окончания периода расчета*/
     v-to = v-from + p-days-sale - 1 .

     if TODAY > v-to and  /*окончание периода меньше сегодн */
        not can-find (first tt-holyday  /*в этом периоде нет праздников*/
            where not tt-holyday.holy-date < v-from
              and not tt-holyday.holy-date > v-to )
     then leave _check_period .
     else v-extw = v-extw + 1 .
  end.

  /*сохраняем даты периода расчета*/
  do v-i = 1 to num-entries(p-method) :
      case substring(entry(v-i, p-method, ","), 1, 8):
        when "date-p-1" then v-mth = v-mth + "date-p-1=" + string(v-from, "99/99/9999") + "," .
        when "date-p-2" then v-mth = v-mth + "date-p-2=" + string(v-to, "99/99/9999") + "," .
        otherwise do:
            if not entry(v-i, p-method, ",") = "" then v-mth = v-mth + entry(v-i, p-method, ",") + "," .
        end.
      end.
  end.
  assign p-method = v-mth .

end procedure.


/* $Workfile$ e n d */