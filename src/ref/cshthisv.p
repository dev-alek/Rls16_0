block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cshthisv.p $
$Archive: ref/cshthisv.p $

Заполнение временной таблицы для показа изменений по таблицам истории смены

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/10/05
Author: Bakhtadze Natalya
Creation date: 08/10/05

*/

define input parameter p-obj-type like ub.c-sht-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-sht-hist.obj-code no-undo .
define input parameter p-shift-date like ub.c-sht-hist.shift-date no-undo .
define input parameter p-shift-num like ub.c-sht-hist.shift-num no-undo .
define input parameter p-chip-num like ub.c-sht-hist.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-sht-hist.corr-user-db-num no-undo .
define input parameter p-subject like ub.c-sht-hist.subject no-undo .
define input parameter p-action   like ub.c-sht-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cshthisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cshthisv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории смены".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }

define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .

define buffer buf_c-sht-hist for ub.c-sht-hist.

{ ref/tmpchgs.i "SHARED" " " "with-action" }


find first buf_c-sht-hist no-lock where
          buf_c-sht-hist.obj-type = p-obj-type
      AND buf_c-sht-hist.obj-code = p-obj-code
      AND buf_c-sht-hist.shift-date = p-shift-date
      AND buf_c-sht-hist.shift-num = p-shift-num
      AND buf_c-sht-hist.chip-num = p-chip-num
      AND buf_c-sht-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-sht-hist.subject  = p-subject no-error .
if not available buf_c-sht-hist then do:
  return error .
end.
CASE p-subject:
  when {&table_shift-obj} then do:
    run shift-obj-proc in this-procedure(output p-description) no-error  .
  end.
  when {&table_shift-staff} then do:
    run shift-staff-proc in this-procedure(output p-description) no-error  .
  end.

END CASE.
if error-status:error then do:
  return error .
end.

function display-time returns character(input p-time-int as character):
if p-time-int = "":U then do:
  return "":U.
end.
else do:
  return string( integer( p-time-int ), "HH:MM:SS").
end.
END FUNCTION.

procedure shift-obj-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-shift-obj for ub.c-shift-obj  .


  do
  on error undo, return error
  :
    find first curr_c-shift-obj no-lock where
               curr_c-shift-obj.obj-type = p-obj-type
           AND curr_c-shift-obj.obj-code = p-obj-code
           AND curr_c-shift-obj.shift-date = buf_c-sht-hist.shift-date
           AND curr_c-shift-obj.shift-num = buf_c-sht-hist.shift-num
           AND curr_c-shift-obj.chip-num = p-chip-num
           AND curr_c-shift-obj.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail curr_c-shift-obj then do:
       v-mess = "Неверная ссылка на c-shift-obj в таблице c-sht-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.

&scop fields-function-list ",,,,,,,,,,,,,,,,"

&scop fields-name-list   "close-date,close-id,close-sys-date,close-sys-time,close-time,fact-order,host-code,obj-code,obj-type," + ~
"open-date,open-id,open-sys-date,open-sys-time,open-time,shift-date,shift-num,shift-name,status_"

define variable v-label-param as character no-undo .

v-label-param =
  "close-date" + {&delim-par} + "Дата закрытия на объекте" + {&delim-par} + "" + {&delim-flf}
 + "close-id" + {&delim-par} + "Закрыл" + {&delim-par} + "" + {&delim-flf}
 + "close-sys-date" + {&delim-par} + "Системная дата закрытия" + {&delim-par} + "" + {&delim-flf}
 + "close-sys-time" + {&delim-par} + "Системное время закрытия" + {&delim-par} + "display-time" + {&delim-flf}
 + "close-time" + {&delim-par} + "Время закрытия на объекте" + {&delim-par} + "display-time" + {&delim-flf}
 + "fact-order" + {&delim-par} + "?" + {&delim-par} + "" + {&delim-flf}
 + "host-code" + {&delim-par} + "Код Фирмы" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "open-date" + {&delim-par} + "Дата открытия на объекте" + {&delim-par} + "" + {&delim-flf}
 + "open-id" + {&delim-par} + "Открыл" + {&delim-par} + "" + {&delim-flf}
 + "open-sys-date" + {&delim-par} + "Системная дата открытия" + {&delim-par} + "" + {&delim-flf}
 + "open-sys-time" + {&delim-par} + "Системное время открытия" + {&delim-par} + "display-time" + {&delim-flf}
 + "open-time" + {&delim-par} + "Время открытия на объекте" + {&delim-par} + "display-time" + {&delim-flf}
 + "shift-date" + {&delim-par} + "Дата смены" + {&delim-par} + "" + {&delim-flf}
 + "shift-num" + {&delim-par} + "Порядок смены" + {&delim-par} + "" + {&delim-flf}
 + "shift-name" + {&delim-par} + "Номер смены" + {&delim-par} + "" + {&delim-flf}
 + "status_" + {&delim-par} + "Статус" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-sht-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-sht-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-shift-obj:handle
                                            ,input  {&table_shift-obj}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).

end.

end procedure. /* shift-obj-proc */



procedure shift-staff-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-shift-staff for ub.c-shift-staff  .


  do
  on error undo, return error
  :
    find first curr_c-shift-staff no-lock where
               curr_c-shift-staff.obj-type = p-obj-type
           AND curr_c-shift-staff.obj-code = p-obj-code
           AND curr_c-shift-staff.shift-date = p-shift-date
           AND curr_c-shift-staff.shift-num = p-shift-num
           AND curr_c-shift-staff.chip-num = p-chip-num
           AND curr_c-shift-staff.corr-user-db-num = p-corr-user-db-num  no-error .
    if not avail curr_c-shift-staff then do:
      v-mess = "Неверная ссылка на c-shift-staff в таблице c-sht-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.

&scop fields-name-list   "cashier,name,next-shift,obj-code,obj-type,osn-code,psn-num,shift-date,shift-num,shift-name,staff-role"

define variable v-label-param as character no-undo .

v-label-param =
  "cashier" + {&delim-par} + "Код кассира" + {&delim-par} + "" + {&delim-flf}
 + "name" + {&delim-par} + "ФИО" + {&delim-par} + "" + {&delim-flf}
 + "next-shift" + {&delim-par} + "№ след.смены" + {&delim-par} + "" + {&delim-flf}
 + "obj-code" + {&delim-par} + "Код объекта" + {&delim-par} + "" + {&delim-flf}
 + "obj-type" + {&delim-par} + "Тип объекта" + {&delim-par} + "" + {&delim-flf}
 + "osn-code" + {&delim-par} + "Код человека" + {&delim-par} + "" + {&delim-flf}
 + "psn-num" + {&delim-par} + "psn-num" + {&delim-par} + "" + {&delim-flf}
 + "shift-date" + {&delim-par} + "Дата смены" + {&delim-par} + "" + {&delim-flf}
 + "shift-num" + {&delim-par} + "Пор. смены" + {&delim-par} + "" + {&delim-flf}
 + "shift-name" + {&delim-par} + "№ смены" + {&delim-par} + "" + {&delim-flf}
 + "staff-role" + {&delim-par} + "staff-role" + {&delim-par} + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-sht-hist.action = integer({&hn-create}))
                                            ,input  (buf_c-sht-hist.action = integer({&hn-delete}))
                                            ,input  buffer curr_c-shift-staff:handle
                                            ,input  {&table_shift-staff}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



end.

end procedure. /* shift-staff-proc */

PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =
      substitute("История смены на &1&2&3пор. смены &4 от &5: щепка &6 БД:&7  Предмет изменений &8"
                  ,p-obj-type
                  ,p-obj-code
                  ,{&new-line}
                  ,p-shift-num
                  ,p-shift-date
                  ,string(p-shift-date, "99/99/9999")
                  ,p-corr-user-db-num
                  ,p-subject) + {&new-line} + p-mess.
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.