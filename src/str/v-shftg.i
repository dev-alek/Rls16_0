/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Программа обработки виртуальных смен

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/17/06
Author: Bakhtadze Natalya
Creation date: 01/17/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*
виртуальных смен не может выть на объектах, на которых установлены смены НА ОБЪЕКТЕ ( а не только на кассе)
на таких объектах
                           !!!!!!!!!!!!  shift-num = integer(shift-name)    !!!!!!!!!!!!!!!!!!
поэтому все операции с {1}.shift-num где {1} это chk-doc  логичны

*/

FIND FIRST ub.shift-cash NO-LOCK WHERE
          ub.shift-cash.obj-code = shop-code AND
          ub.shift-cash.obj-type = shop-type AND
          ub.shift-cash.cash-num = {1}.pay-desk AND
          ub.shift-cash.shift-num = {1}.shift-num AND
          ub.shift-cash.shift-date = {1}.shift-date NO-ERROR.
IF AVAIL ub.shift-cash then do:
    if ub.shift-cash.sale-date <> {1}.shift-date then
    assign
    {1}.shift-date = ub.shift-cash.sale-date.
    return.
end.
else do:
    if v-shft = 2 then do:
        if t-shft <= 0 then v-shft = 1.
        else do:
            /*интеллектуальное определение даты новой смены*/
            if {1}.chk-date = {1}.shift-date then do:
              if ({1}.chk-time >= t-shft) AND NOT
                  can-find(first for_{1} No-LOCK WHERE
                                for_{1}.obj-type = shop-type AND
                                for_{1}.obj-code = shop-code AND
                                for_{1}.pay-desk = {1}.pay-desk AND
                                for_{1}.shift-date = {1}.shift-date AND
                                for_{1}.shift-num = {1}.shift-num AND
                                for_{1}.chk-time >= t-shft AND
                                for_{1}.chk-date = {1}.chk-date AND
                                recid(for_{1}) <> recid({1})) then do:
                response = 1.
              end.
              if {1}.chk-time < t-shft then response = 0.
            end.
            else do: /*{1}.shift-date < {1}.chk-date*/
              if {1}.chk-time >= t-shft then do:
                response = -1.
              end.
              else response = -1.

            end.
            if response >= 0 then do:
                run str/shftccr.p ( input shop-type
                              ,input shop-code
                              ,input {1}.pay-desk
                              ,input {1}.shift-date
                              ,input {1}.shift-num
                              ,input string({1}.shift-num)
                              ,input string({1}.shift-num)
                              ,input {1}.chk-time
                              ,input 0
                              ,input {&receipt-in}
                              ,output vrecid) no-error.
              if response = 1 then do:
                FIND FIRST shift-cash where recid(shift-cash) = vrecid.
                assign
                shift-cash.sale-date = {1}.shift-date + 1
                {1}.shift-date = shift-cash.sale-date
                .
              end.
            end.
            else v-shft = 1.
        end.  /*t-shft > 0*/
    end. /*if v-shft = 2*/
    if v-shft = 1 then do:
        /*запрос оператору*/
        run gbl/d-askw.w (input "Запрос",
                            input ("В соответствии с настройками системы" + {&new-line} +
                                       "необходимо ввести дату, за которую будут учитываться" + {&new-line} +
                                       "чеки по кассе " + string({1}.pay-desk) + {&comma-char} +
                                       "пробитые за смену " + string({1}.shift-num) +
                                       " - дата " + string({1}.shift-date, "99/99/9999") + {&new-line} +
                                       "(пришел чек N " + string({1}.chk-num) + " от " +
                                       string({1}.chk-date, "99/99/9999") + {&space-char} +
                                       string({1}.chk-time, "HH:MM") + ")"
                                   ),
                             input "|",
                             input (string({1}.shift-date, "99/99/9999") + "|" +
                                       string({1}.shift-date + 1, "99/99/9999") + "|" +
                                       "Ошибка"
                                       ),
                             input "||",
                             input 1,
                             input 3,
                             output choice).
        case choice:
            when 1 then do:
                run str/shftccr.p (
                               input shop-type
                              ,input shop-code
                              ,input {1}.pay-desk
                              ,input {1}.shift-date
                              ,input {1}.shift-num
                              ,input string({1}.shift-num)
                              ,input string({1}.shift-num)
                              ,input {1}.chk-time
                              ,input 0
                              ,input {&receipt-in}
                              ,output vrecid) no-error.
            end.
            when 2 then do:
                run str/shftccr.p (
                               input shop-type
                              ,input shop-code
                              ,input {1}.pay-desk
                              ,input {1}.shift-date
                              ,input {1}.shift-num
                              ,input string({1}.shift-num)
                              ,input string({1}.shift-num)
                              ,input {1}.chk-time
                              ,input 0
                              ,input {&receipt-in}
                              ,output vrecid) no-error.
              if error-status:error then do:
                assign
                p-view-log = yes.
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute( "!!!Не определена дата смены(дата учета) для чеков для кассы &1: смена N&2 за &3"
                                        , {1}.pay-desk
                                        , {1}.shift-num
                                        , string({1}.shift-date, "99/99/9999")
                                      )
                                                      ).
                undo, return.
              end.
                FIND FIRST shift-cash where recid(shift-cash) = vrecid.
                assign
                shift-cash.sale-date = {1}.shift-date + 1
                {1}.shift-date = shift-cash.sale-date
                .
            end.
            when 3 then do:
              assign
              p-view-log = yes.
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute( "!!!Произошла ошибка при попытке создания записи кассовой смены для кассы &1: смена N&2 за &3"
                                        , {1}.pay-desk
                                        , {1}.shift-num
                                        , string({1}.shift-date, "99/99/9999")
                                    )
                                                    ).
                 assign
                  for-chk-type = for-chk-type + shift-err + {&comma-char}
                 {1}.shift-date = 01/01/1990.
                 return.
            end.
        END CASE.
    end. /*v-shft = 1*/
end. /*not avail shift-cash*/


/* $Workfile$ e n d */