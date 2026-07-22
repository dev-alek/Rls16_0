/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прием куста относщегося к истории смен на объекте

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/20/06
Author: Bakhtadze Natalya
Creation date: 03/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :

  { nws/imps-nws.i rec-full }

  assign
    rec-name = entry( 1, rec-full, {&delim-nws} )
    .

  {&test-count}

  CASE rec-name :
    when "shift-cash" then do:
      create locb2-shift-cash.
      { nws/impl-nws.i "shift-cash" "locb2-" }
    end.
    when "c-shift-staff" then do:
      create locb2-c-shift-staff.
      { nws/impl-nws.i "c-shift-staff" "locb2-" }
    end.
    when "c-sht-hist" then do:
      create locb2-c-sht-hist.
      { nws/impl-nws.i "c-sht-hist" "locb2-" }
    end.
    when "c-shift-obj" then do:
      create locb2-c-shift-obj.
      { nws/impl-nws.i "c-shift-obj" "locb2-" }
    end.

    otherwise do:
      message "Не предусмотрен прием таблицы " rec-name skip
              "в составе смен на объекте."
              view-as alert-box error.
      return error.
    end.
  END CASE.
end.

/*отправляем имеющиеся смены кассы  */

for each buf_shift-cash where buf_shift-cash.obj-type   = wt-c-shift-obj.obj-type
                           and buf_shift-cash.obj-code   = wt-c-shift-obj.obj-code
                           and buf_shift-cash.shift-date = wt-c-shift-obj.shift-date
                           and buf_shift-cash.shift-num  = wt-c-shift-obj.shift-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_shift-cash.
end.
for each locb2-shift-cash where locb2-shift-cash.obj-type   = wt-c-shift-obj.obj-type
                            and locb2-shift-cash.obj-code   = wt-c-shift-obj.obj-code
                            and locb2-shift-cash.shift-date = wt-c-shift-obj.shift-date
                            and locb2-shift-cash.shift-num  = wt-c-shift-obj.shift-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_shift-cash.
  buffer-copy locb2-shift-cash to buf_shift-cash.
end.

_buf_c-sht-hist:
for each buf_c-sht-hist where buf_c-sht-hist.obj-type   = wt-c-shift-obj.obj-type
                           and buf_c-sht-hist.obj-code   = wt-c-shift-obj.obj-code
                           and buf_c-sht-hist.shift-date = wt-c-shift-obj.shift-date
                           and buf_c-sht-hist.shift-num  = wt-c-shift-obj.shift-num
                           and buf_c-sht-hist.corr-user-db-num  = wt-c-shift-obj.corr-user-db-num
                           and buf_c-sht-hist.chip-num  <= wt-c-shift-obj.chip-num
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
   CASE buf_c-sht-hist.subject:
    when {&table_c-shift-staff} then do:
      find first buf_c-shift-staff where buf_c-shift-staff.obj-type      = buf_c-sht-hist.obj-type
                              and buf_c-shift-staff.obj-code         = buf_c-sht-hist.obj-code
                              and buf_c-shift-staff.shift-date       = buf_c-sht-hist.shift-date
                              and buf_c-shift-staff.shift-num        = buf_c-sht-hist.shift-num
                              and buf_c-shift-staff.corr-user-db-num = buf_c-sht-hist.corr-user-db-num
                              and buf_c-shift-staff.chip-num         = buf_c-sht-hist.chip-num exclusive-lock no-wait no-error .
      if locked(buf_c-shift-staff) then do:
        undo, return error.
      end.
      delete buf_c-shift-staff.
    end.
    when {&table_c-shift-obj} then do:
      if buf_c-sht-hist.chip-num  = wt-c-shift-obj.chip-num then NEXT _buf_c-sht-hist.
      find first buf_c-shift-obj where buf_c-shift-obj.obj-type      = buf_c-sht-hist.obj-type
                              and buf_c-shift-obj.obj-code         = buf_c-sht-hist.obj-code
                              and buf_c-shift-obj.shift-date       = buf_c-sht-hist.shift-date
                              and buf_c-shift-obj.shift-num        = buf_c-sht-hist.shift-num
                              and buf_c-shift-obj.corr-user-db-num = buf_c-sht-hist.corr-user-db-num
                              and buf_c-shift-obj.chip-num         = buf_c-sht-hist.chip-num exclusive-lock no-wait no-error .
      if locked(buf_c-shift-obj) then do:
        undo, return error.
      end.
      delete buf_c-shift-obj.
    end.
  END CASE.
  delete buf_c-sht-hist.
end.

_locb2-c-sht-hist:
for each locb2-c-sht-hist where locb2-c-sht-hist.obj-type   = wt-c-shift-obj.obj-type
                            and locb2-c-sht-hist.obj-code   = wt-c-shift-obj.obj-code
                            and locb2-c-sht-hist.shift-date = wt-c-shift-obj.shift-date
                            and locb2-c-sht-hist.shift-num  = wt-c-shift-obj.shift-num
                            and locb2-c-sht-hist.corr-user-db-num  = wt-c-shift-obj.corr-user-db-num
                            and locb2-c-sht-hist.chip-num  <= wt-c-shift-obj.chip-num
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  CASE locb2-c-sht-hist.subject:
    when {&table_shift-staff} then dO:
      find first locb2-c-shift-staff where locb2-c-shift-staff.obj-type = locb2-c-sht-hist.obj-type
                              and locb2-c-shift-staff.obj-code         = locb2-c-sht-hist.obj-code
                              and locb2-c-shift-staff.shift-date       = locb2-c-sht-hist.shift-date
                              and locb2-c-shift-staff.shift-num        = locb2-c-sht-hist.shift-num
                              and locb2-c-shift-staff.corr-user-db-num = locb2-c-sht-hist.corr-user-db-num
                              and locb2-c-shift-staff.chip-num         = locb2-c-sht-hist.chip-num
                        no-lock no-error .
      if available locb2-c-shift-staff then do:
        create buf_c-shift-staff.
        buffer-copy locb2-c-shift-staff to buf_c-shift-staff.
      end.
    end.
    when {&table_shift-obj} then dO:
      if locb2-c-sht-hist.chip-num = wt-c-shift-obj.chip-num then NEXT _locb2-c-sht-hist.
      find first locb2-c-shift-obj where locb2-c-shift-obj.obj-type = locb2-c-sht-hist.obj-type
                              and locb2-c-shift-obj.obj-code         = locb2-c-sht-hist.obj-code
                              and locb2-c-shift-obj.shift-date       = locb2-c-sht-hist.shift-date
                              and locb2-c-shift-obj.shift-num        = locb2-c-sht-hist.shift-num
                              and locb2-c-shift-obj.corr-user-db-num = locb2-c-sht-hist.corr-user-db-num
                              and locb2-c-shift-obj.chip-num         = locb2-c-sht-hist.chip-num
                        no-lock no-error .
      if available locb2-c-shift-obj then do:
        create buf_c-shift-obj.
        buffer-copy locb2-c-shift-obj to buf_c-shift-obj.
      end.
    end.
  END CASE.
  create buf_c-sht-hist.
  buffer-copy locb2-c-sht-hist to buf_c-sht-hist.
end.










if not available tb-c-shift-obj then do:
  create tb-c-shift-obj.
end.
buffer-copy wt-c-shift-obj to tb-c-shift-obj.

/* -------------------- почистим за собой ------------------------ */
for each locb2-shift-cash
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-shift-cash.
end.

for each locb2-c-shift-staff
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-c-shift-staff.
end.

for each locb2-c-sht-hist
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-c-sht-hist.
end.

for each locb2-c-shift-obj
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb2-c-shift-obj.
end.


/* $Workfile$ e n d */