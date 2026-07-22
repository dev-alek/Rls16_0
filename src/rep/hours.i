/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Кусок почасовых отчетов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

assign
WH-Start = "24"
WH-End = "0"
.

_hours:
for each obj-list No-LOCK:
    FIND FIRST ub.SHop NO-LOCK WHERE ub.shop.obj-code = obj-list.obj-code No-ERROR.
    if not avail ub.shop then NEXT.
    if ub.shop.work-hours = "" then do:
        message "Не определены часы работы" skip
                        "магазина с кодом " ub.shop.obj-code
        view-as alert-box ERROR .
   end.
   else do:
      if entry( 1, entry( 1, ub.shop.work-hours ), "." ) = entry( 1, entry( 2, ub.shop.work-hours ), "." )
      then do:
          assign
          WH-Start = "0"
          WH-End = "0"
          .
          LEAVE _hours.
      end.
      else
      assign
      WH-Start = string(MIN(integer(entry( 1, entry( 1, ub.shop.work-hours ), "." ) ), integer(WH-start)))
      WH-End = string(MAX(integer(entry( 1, entry( 2, ub.shop.work-hours ), "." ) ), integer(WH-end)))
      .
   end.
END.
if WH-Start = "24" AND WH-End = "0"
then do:
    message "Не определены часы работы" skip
                    "ни одного из магазинов"
                    "данной базы."
    view-as alert-box ERROR .
    DISABLE
    H-0 H-1 H-2 H-3 H-4 H-5 H-6 H-7 H-8 H-9
    H-10 H-11 H-12 H-13 H-14 H-15 H-16 H-17 H-18 H-19
    H-20 H-21 H-22 H-23
    WITH FRAME {&FRAME-NAME}.
end.
else do:
   if WH-Start = "0" AND WH-End = "0" then  do:
        assign
        H-0 = TRUE
        H-1 = TRUE
        H-2 = TRUE
        H-3 = TRUE
        H-4 = TRUE
        H-5 = TRUE
        H-6 = TRUE
        H-7 = TRUE
        H-8 = TRUE
        H-9 = TRUE
        H-10 = TRUE
        H-11 = TRUE
        H-12 = TRUE
        H-13 = TRUE
        H-14 = TRUE
        H-15 = TRUE
        H-16 = TRUE
        H-17 = TRUE
        H-18 = TRUE
        H-19 = TRUE
        H-20 = TRUE
        H-21 = TRUE
        H-22 = TRUE
        H-23 = TRUE
        .
        DISPLAY
        H-0 H-1 H-2 H-3 H-4 H-5 H-6 H-7 H-8 H-9
        H-10 H-11 H-12 H-13 H-14 H-15 H-16 H-17 H-18 H-19
        H-20 H-21 H-22 H-23
        WITH FRAME {&FRAME-NAME}.
    end. /*if WH-Start = "0" AND WH-End = "0"*/
    else do:
        assign
        H-0 = FALSE
        H-1 = FALSE
        H-2 = FALSE
        H-3 = FALSE
        H-4 = FALSE
        H-5 = FALSE
        H-6 = FALSE
        H-7 = FALSE
        H-8 = FALSE
        H-9 = FALSE
        H-10 = FALSE
        H-11 = FALSE
        H-12 = FALSE
        H-13 = FALSE
        H-14 = FALSE
        H-15 = FALSE
        H-16 = FALSE
        H-17 = FALSE
        H-18 = FALSE
        H-19 = FALSE
        H-20 = FALSE
        H-21 = FALSE
        H-22 = FALSE
        H-23 = FALSE
        .
        DISPLAY
        H-0 H-1 H-2 H-3 H-4 H-5 H-6 H-7 H-8 H-9
        H-10 H-11 H-12 H-13 H-14 H-15 H-16 H-17 H-18 H-19
        H-20 H-21 H-22 H-23
        WITH FRAME {&FRAME-NAME}.
        DO kk = integer( WH-Start ) TO ( integer( WH-End ) - 1 ) :
            CASE kk :
                when 0 then do:
                    H-0 = TRUE .
                end.
                when 1 then do:
                    H-1 = TRUE .
                end.
                when 2 then do:
                    H-2 = TRUE .
                end.
                when 3 then do:
                    H-3 = TRUE .
               end.
               when 4 then do:
                    H-4 = TRUE .
               end.
               when 5 then do:
                    H-5 = TRUE .
               end.
               when 6 then do:
                    H-6 = TRUE .
               end.
               when 7 then do:
                    H-7 = TRUE .
               end.
               when 8 then do:
                    H-8 = TRUE .
               end.
               when 9 then do:
                    H-9 = TRUE .
               end.
               when 10 then do:
                    H-10 = TRUE .
               end.
               when 11 then do:
                    H-11 = TRUE .
               end.
               when 12 then do:
                    H-12 = TRUE .
               end.
               when 13 then do:
                    H-13 = TRUE .
               end.
               when 14 then do:
                    H-14 = TRUE .
               end.
               when 15 then do:
                    H-15 = TRUE .
               end.
               when 16 then do:
                    H-16 = TRUE .
               end.
               when 17 then do:
                    H-17 = TRUE .
               end.
               when 18 then do:
                    H-18 = TRUE .
               end.
               when 19 then do:
                    H-19 = TRUE .
               end.
               when 20 then do:
                    H-20 = TRUE .
               end.
               when 21 then do:
                    H-21 = TRUE .
               end.
               when 22 then do:
                    H-22 = TRUE .
               end.
               when 23 then do:
                    H-23 = TRUE .
               end.
            END CASE .
        END . /*DO kk*/
        DISPLAY
        H-0 H-1 H-2 H-3 H-4 H-5 H-6 H-7 H-8 H-9
        H-10 H-11 H-12 H-13 H-14 H-15 H-16 H-17 H-18 H-19
        H-20 H-21 H-22 H-23
        WITH FRAME {&FRAME-NAME}.
    end. /*NOT if WH-Start = "0" AND WH-End = "0"*/
end. /*зоть какие то часы определены*/


/* $Workfile$ e n d */