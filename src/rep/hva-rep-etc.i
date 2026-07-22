
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Прочее для меня

Автор: Харитонов Владимир Александрович
Дата создания: 14/08/13
Author: Kharitonov Vladimir
Creation date: 14/08/13

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ rep/ostatok.i }

/* для проверок при вызове процедуры */
&glob check-no-error no-error. if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).
&glob check-error if error-status:ERROR then return error subst("&1 &2 &3", return-value, ERROR-STATUS:get-message(1), ERROR-STATUS:get-message(2)).

/* тип даты фактордера */
&glob factord-start 1
&glob factord-end   2

/* ищем фактордера ( от и до ) вне зависимости - смена или дата */
procedure get-factord:
    define input parameter  p-obj-type       as character no-undo.
    define input parameter  p-obj-code       as integer   no-undo. 
    define input parameter  p-shift-date     as date    format "99/99/9999" no-undo.
    define input parameter  p-shift-num      as integer   no-undo.
    define input parameter  p-type           as integer   no-undo.
    define output parameter p-factord        as decimal   no-undo.
    
    define variable tmp as decimal no-undo.
        
    /* 
         p-type:
    {&factord-start} - начало смены
    {&factord-end}   - конец смены
    
    */

    if p-type = {&factord-start} and p-shift-num > 0 then do:
        run ostatok(
            p-obj-code,
            p-obj-type,
            true,
            p-shift-date - 1,
            date(''),
            p-shift-num,
            p-shift-num,
            {&arh-cost},
            {&root-cat-id},
            true,
            output tmp,
            output tmp,
            output tmp,
            output tmp,
            output tmp,
            output p-factord
        ).
    end.
    else if p-type = {&factord-end} and p-shift-num > 0 then
        run ostatok(
            p-obj-code,
            p-obj-type,
            true,
            p-shift-date,
            date(''),
            p-shift-num,
            p-shift-num,
            {&arh-cost},
            {&root-cat-id},
            true,
            output tmp,
            output tmp,
            output tmp,
            output tmp,
            output tmp,
            output p-factord
        ).
    else if p-type = {&factord-start} then
        run day-begin-fact-order(p-shift-date, output p-factord).
    else if p-type = {&factord-end} then
        run factord-end-day(p-shift-date, output p-factord).
end.