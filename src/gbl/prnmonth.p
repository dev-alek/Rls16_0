block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prnmonth.p $
$Archive: gbl/prnmonth.p $

Печать календаря на один месяц

Автор: Перваков Михаил Сергеевич
Дата создания: 06/17/04
Author: Mikhail Pervakov
Creation date: 06/17/04

*/

define input  parameter p-month as integer   no-undo .
define input  parameter p-year  as integer   no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: prnmonth.p $":U .
def var vss-archive     as character no-undo init "$Archive: gbl/prnmonth.p $":U .
def var vss-description as character no-undo init "Печать календаря на один месяц".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/r-pril.i   new }

define variable v-month-name   as character no-undo .
define variable v-month-offset as integer   no-undo .

define variable v-ind       as integer   no-undo .
define variable v-row       as integer   no-undo .
define variable v-last-day  as integer   no-undo .
define variable v-day-label as integer   no-undo extent 42 .
define variable v-day-row   as integer   no-undo .
define variable v-day-col   as integer   no-undo .

define stream PrnLibStream .

do
on error undo, return error return-value
:
  run gbl/monthnam.p
    (input  p-month      /* p-month      */
    ,output v-month-name /* p-month-name */
    ).
  run gbl/lastday.p
    (input  date(p-month, 1, p-year)
    ,output v-last-day
    ).
  assign
    v-month-offset = (weekday(date(p-month, 1, p-year)) + 5) mod 7
  .

  do v-ind = 1 to v-last-day
  :
    assign
      v-day-label[v-ind + v-month-offset] = v-ind
    .
  end.

  output stream PrnLibStream to value('prnmonth.txt':u) .

  put stream PrnLibStream unformatted
    substitute("Календарь на &1 &2 года", v-month-name, p-year)
    {&new-line} .

  put stream PrnLibStream unformatted
    ":-------------------------:-------------------------:-------------------------:-------------------------:-------------------------:-------------------------:-------------------------:"
    {&new-line} .
  put stream PrnLibStream unformatted
    ": Понедельник             : Вторник                 : Среда                   : Четверг                 : Пятница                 : Суббота                 : Воскресенье             :"
    {&new-line} .
  put stream PrnLibStream unformatted
    ":-------------------------:-------------------------:-------------------------:-------------------------:-------------------------:-------------------------:-------------------------:"
    {&new-line} .




  do v-day-row = 0 to 5
  :
    do v-row = 1 to 7
    :
      do v-day-col = 1 to 7
      :
        assign
          v-ind = v-day-row * 7 + v-day-col
        .
        if v-day-label[v-ind] <> 0
        then do:
          case v-row
          :
            when 1
            then do:
              put stream PrnLibStream unformatted
                ": " + substring(string(v-day-label[v-ind], ">9") + fill(" ", 24), 1, 24)
                .
            end.
            when 7
            then do:
              put stream PrnLibStream unformatted
                ":" + fill("-", 25)
                .
            end.
            otherwise do:
              put stream PrnLibStream unformatted
                ":" + fill(" ", 25)
                .
            end.
          end.
        end.
        else do:
          if  v-row = 7
          and v-ind + 7 <= 42
          and v-day-label[v-ind + 7] <> 0
          then do:
            put stream PrnLibStream unformatted
              ":" + fill("-", 25)
              .
          end.
          else do:
            put stream PrnLibStream unformatted
              fill(" ", 26)
              .
          end.
        end.

        if (v-ind modulo 7 = 0
        and v-day-label[v-ind] <> 0
          )
        or (v-ind modulo 7 <> 0
        and v-day-label[v-ind] <> 0
        and v-ind + 1 <= 42
        and v-day-label[v-ind + 1] = 0
          )
        then do:
          put stream PrnLibStream unformatted
            ":"
            .
        end.

        if v-ind modulo 7 = 0
        then do:
          if  v-ind = 42
          and v-row = 7
          then do:
            /* не печатаем последний знак новой строки */
          end.
          else do:
            put stream PrnLibStream unformatted
              {&new-line} .
          end.
        end.
      end.
    end.
  end.

  output stream PrnLibStream close .

  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .

  run gbl/prnfilen.w
    (input  substitute("Календарь на &1 &2 года"
                      ,v-month-name
                      ,p-year
                      )
    ,input  8
    ,input  'prnmonth.txt':u
    ,input  7
    ,output v-user-action
    ,output v-printed
    ) .


end.