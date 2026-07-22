/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$


Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/20/06
Author: Bakhtadze Natalya
Creation date: 01/20/06


Процедура проверки корректности чека МЦ и выставления флажков корректности строк и шапки чека
chk-doc.correct
chk-pay.is-error
Предполагается что в момент ее запуска заполнены все необходимые поля во всех структурах чека

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure check-check-wth :
define input parameter p-mc-prev-code like ub.chk-doc.doc-code no-undo .
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
&if "{1}" = "p-netto" &then
define input parameter p-netto as decimal no-undo .
&endif


define variable v-cashier-psn-code like ub.person.psn-code no-undo .
define variable par-val_ as integer no-undo .
define variable accum-pay as decimal no-undo .
define variable accum-pay-inst as decimal no-undo .
define variable v-pay-code as integer no-undo .
define variable v-wth-code as integer no-undo .
define variable v-is-error as logical no-undo .
define variable v-line-num as integer no-undo .
define variable v-inst-sum as decimal no-undo .
define variable v-curr-code as integer no-undo .

define buffer buf_cash-desk for ub.cash-desk.

  do
  on error undo, return error return-value
  :
    if p-mc-prev-code = "":U then return.
    FIND chk-doc WHERE
         chk-doc.doc-code = p-mc-prev-code NO-ERROR.
    if not avail chk-doc then do:
      return.
    end.
    mc-for-chk-type = '':U.
    /*проверка и дообработка шапки чека*/
    if chk-doc.pay-desk <> 0 then do:
      find first buf_cash-desk no-lock where
                buf_cash-desk.cash-num = chk-doc.pay-desk
          AND buf_cash-desk.obj-code = chk-doc.obj-code
          AND buf_cash-desk.pos-type = p-pos-type no-error .
    end.
    if chk-doc.pay-desk = 0
    or not available buf_cash-desk
    or buf_cash-desk.is-del then do:
      assign
      mc-for-chk-type = mc-for-chk-type + {&pay-err} + {&comma-char}
      p-view-log = yes
      chk-doc.correct = no
      .
      run write-log-and-file in {2} (
            input 1
          , input log-file-name
          , input 1
          , input substitute(
                              "!!!Чек МЦ &1 - ошибочный. &2 Нет сведений о кассе &3 с типом &4"
                              , chk-doc.doc-code
                              , {&new-line}
                              , chk-doc.pay-desk
                              , p-pos-type
                            )
                                            ).
    end.
&if "{1}" <> "shift-change" &then
    assign
    chk-doc.shift-date = if get-chkc_context.t-shft < 0 AND chk-doc.chk-time < abs(t-shft)
                          then (chk-doc.chk-date - 1)
                          else (if chk-doc.src-shift-date = ?
                                then chk-doc.chk-date
                                else
&if "{1}" = "update" &then
                                (if index(chk-doc.ps, "shift!") = 0
                                then chk-doc.src-shift-date
                                else chk-doc.shift-date)
&else
                                chk-doc.src-shift-date
&endif
                                )
    .
    if get-chkc_context.cas-shft then do:
      /*если включены смены на кассах*/
      /*смена объекта в БО соответствующая смене чека уже закрыта или
      в спуле нет смены*/
      if chk-doc.shift-name = '':U
      or trim(chk-doc.shift-name, '0') = '':U
        then /*тогда чек ошибочен*/ do:
        assign
        mc-for-chk-type = mc-for-chk-type + {&shift-err} + {&comma-char}
        chk-doc.shift-date = 01/01/1990
        chk-doc.correct = no
        .
      end.
      else do:
        if v-shft > 0 then do:
          run str/v-shftg.p (
                      buffer chk-doc,
                      input parparentproc,
                      input {2},
                      input shop-code,
                      input shop-type,
                      input v-shft,
                      input t-shft,
                      input {&shift-err},
                      input-output mc-for-chk-type,
                      input-output p-view-log
                      ).

        end. /* if v-shft > 0*/
        if get-chkc_context.shift-on then do:
          /*в поле .shift-num должен положить порядковый номер смены*/
          if
          &if "{1}" = "update" &then
                  index(chk-doc.ps, "shift!") = 0
          &else
                  true
          &endif
                  then do:
            run get-shift-num in this-procedure (input chk-doc.obj-type
                                                ,input chk-doc.obj-code
                                                ,input chk-doc.shift-date
                                                ,input chk-doc.shift-name
                                                ,output chk-doc.shift-num) no-error .
           if error-status:error
           or chk-doc.shift-num = ?
           or chk-doc.shift-num = 0 then do:
            assign
            mc-for-chk-type = mc-for-chk-type + {&shift-err} + {&comma-char}
            chk-doc.shift-num = 0
            chk-doc.correct = no
            .
           end.
          end.
        end. /*if get-chkc_context.shift-on then do:*/
        if
&if "{1}" = "update" &then
         index(chk-doc.ps, "shift!") = 0
&else
        true
&endif
        then do:
          assign
          chk-date_ = chk-doc.chk-date
          chk-time_ = chk-doc.chk-time
          shift-date_ = chk-doc.src-shift-date
&if "{1}" = "update" &then
          shift-name_ = (if par-mode = {&add-def}
                         then chk-doc.shift-name
                         else chk-doc.src-shift-name)
&else
          shift-name_ = chk-doc.src-shift-name
&endif
          pay-desk_ = chk-doc.pay-desk
          .
          if cas-shft then do:
            if current-pay-desk <> pay-desk_
            or NOT (current-cas-shift-name =  shift-name_
                AND current-cas-shift-date = shift-date_)
            OR not avail buf_shift-cash then do:
              { str/libchkvl_get-cash-shift.i
              "buffer get-chkc_context:handle"
              buf_shift-cash
              pay-desk_
              shift-date_
              shift-name_
              ?
              chk-date_
              chk-time_
              shift-open-time_
              no-error
              }
              if available buf_shift-cash then do:
                assign
                current-pay-desk = buf_shift-cash.cash-num
                current-cas-shift-name = buf_shift-cash.shift-name
                current-cas-shift-date = buf_shift-cash.shift-date
                .
              end.
              else do:
                current-pay-desk = -1.
              end.
            end.
          end. /*if cas-shft then do:*/
        end.
      end. /*  if chk-doc.shift-name = 0 */
    end. /* if cas-shft*/
&endif
    assign
    v-cashier-psn-code = gbclcode-is-this-db-role ( input {&role-cashier}, input g#db-num, input chk-doc.cashier, input chk-doc.chk-date)
    no-error
    .
    if v-cashier-psn-code = 0 then do:
      assign
      mc-for-chk-type = mc-for-chk-type + {&staff-err} + {&comma-char}
      chk-doc.correct = no
      p-view-log = yes
      .
      run write-log-and-file in {2} (
            input 1
          , input log-file-name
          , input 1
          , input substitute(
                              "!!!Чек МЦ &1 - ошибочный. &2 Нет сведений о кассире &3"
                              , chk-doc.doc-code
                              , {&new-line}
                              , chk-doc.cashier
                            )
                                            ).
    end.
    else do:
      assign
      chk-doc.cashier-psn-code = v-cashier-psn-code
      .
    end.
    /*проверка и дообработка строк чека*/
    for each chk-pay where
             chk-pay.doc-code = chk-doc.doc-code:
      assign
      chk-pay.is-error = no
      pay_code = chk-pay.pay-code
      curr_code = chk-pay.curr-code
      accum-pay = accum-pay +  chk-pay.sum / chk-pay.cash-rate
      .
      FIND FIRST cash-pay WHERE
                cash-pay.cdpay-code = chk-pay.pay-code AND
                cash-pay.curr-code = chk-pay.curr-code NO-LOCK NO-ERROR.
      if NOT available cash-pay
      or cash-pay.wth-code = 0
      then do:
        run write-log-and-file in {2} (
              input 1
            , input log-file-name
            , input 1
            , input substitute(
                                "!!!Чек МЦ &1 - ошибочный&2" +
                               (if not available cash-pay
                               then "В базе отсутствует тип кассового платежа c кодом &3 и кодом валюты &4"
                               else "Типу кассового платежа с кодом &3 и кодом валюты &4 не соответствует ни одна МЦ")
                                , chk-doc.doc-code
                                , {&new-line}
                                , chk-pay.pay-code
                                , chk-pay.curr-code
                              )
                                              ).
        assign
        mc-for-chk-type = mc-for-chk-type + {&pay-err} + {&comma-char}
        chk-doc.correct = no
        p-view-log = yes
        .
      end.
      else do:
        assign
        chk-pay.wth-code = cash-pay.wth-code
        .
        { str/set-twth.i chk-doc chk-pay }
      end.
      if chk-pay.src-qnty <> 0
      or chk-pay.src-val <> 0 then do:
        FIND FIRST wth-par WHERE
                  wth-par.wth-code = chk-pay.wth-code
            AND wth-par.par-val = chk-pay.src-val
            and (chk-pay.src-qnty = 0
                or wth-par.par-rate = chk-pay.tot-sum / chk-pay.src-qnty) NO-LOCK NO-ERROR.
        if NOT available wth-par then do:
          run write-log-and-file in {2} (
                input 1
              , input log-file-name
              , input 1
              , input substitute(
                                  "!!!Чек МЦ &1 - ошибочный&2" +
                                  "В базе отсутствует номинал МЦ " +
                                  (if chk-pay.wth-code <> 0
                                  then "с кодом &3 и номиналом &4"
                                  else '':U)
                                  , chk-doc.doc-code
                                  , {&new-line}
                                  , chk-pay.wth-code
                                  , chk-pay.src-val
                                )
                                                ).
          assign
          chk-pay.wth-code = 0
          chk-pay.par-code = 0
          mc-for-chk-type = mc-for-chk-type + {&pay-err} + {&comma-char}
          chk-doc.correct = no
          .
        end.
        else do:
          assign
          chk-pay.par-code = wth-par.par-code.
        end.
      end.
    end. /* for each chk-pay */
&if "{1}" = "p-netto" &then
    if  ((p-netto = 0 and accum-pay <> 0)
    or (p-netto <> 0 and  ABS(ABS(p-netto - ACCUM-pay) / p-netto ) > 0.01))
    then do:
      run write-log-and-file in {2} (
            input 1
          , input log-file-name
          , input 1
          , input substitute(
                              "!!!Чек &1 - ошибочный (Номер по кассе: &2 Касса: &3)&4" +
                              "Сумма транзакции не совпадает с суммой оплат по чеку&4" +
                              "Сумма транзакции = &5, сумма оплат по чеку = &6&4" +
                              "Обратитесь к администратору Вашей системы"
                              , chk-doc.doc-code
                              , chk-doc.chk-num
                              , chk-doc.pay-desk
                              , {&new-line}
                              , p-netto
                              , accum-pay
                            )
                                            ).
      assign
      mc-for-chk-type = mc-for-chk-type + {&summa-err} + {&comma-char}
      chk-doc.correct = no
      p-view-log = yes
      .
    end.
&endif
    /*проверка строк чека МЦ на совместность их друг с другом*/
    { str/ibmcrwth.i chk-doc mc-for-chk-type yes {2} }
    assign
    chk-doc.PS = (if index(chk-doc.ps, 'shift!':U) > 0
                    then '!shift!'
                    else (if index(chk-doc.ps, '!':U) > 0 then '!' else '':U)
                    ) + RIGHT-TRIM(mc-for-chk-type, {&comma-char})
    chk-doc.correct = if mc-for-chk-type = '':U then yes else no
    .
    p-mc-prev-code = "" .    /* иной раз помогает */
  end. /*doe*/

end procedure. /* check-check-wth */

/* $Workfile$ e n d */