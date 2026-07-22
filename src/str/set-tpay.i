/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание записи во временной таблице  оплат при закачке / создании чеков

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/31/07
Author: Bakhtadze Natalya
Creation date: 10/31/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if crp > 0 then
  find first t-pay WHERE
              t-pay.pay-code = {2}.pay-code
         and (t-pay.curr-code = (if {2}.pay-code = 1
                                then -1
                                else {2}.curr-code)
              or {2}.pay-code <> 1)
        and t-pay.pay-card = (if {2}.pay-card = "0"
                              then "":U
                              else {2}.pay-card)
              NO-ERROR.
  if not avail t-pay
  or crp = 0
  then  do:
    FIND FIRST t-pay where t-pay.crf = crp + 1 use-index crfi No-ERROR.
    if not avail t-pay then
    create t-pay.
    assign
    t-pay.crf = crp + 1
    crp = crp + 1
    t-pay.pay-code = {2}.pay-code
    t-pay.curr-code = (if {2}.pay-code = 1
                       then -1
                       else {2}.curr-code)
    t-pay.is-cash = (if (available buf_cash-pay)
                    then buf_cash-pay.is-cash
                    else no)
    t-pay.pay-card = (if (available buf_cash-pay)
                then (if {2}.pay-card <> '':U
                     and {2}.pay-card <> '0'
                     then {2}.pay-card
                     else "")
                else "")
    t-pay.drc = recid({1})
    t-pay.tot-rubl = 0
    t-pay.tot-base = 0
    t-pay.num-lines = 0
    t-pay.was-return = no
    t-pay.byval = ''
    .
  end.
  assign
  t-pay.tot-base = t-pay.tot-base + {2}.tot-base
  t-pay.tot-rubl = t-pay.tot-rubl + {2}.tot-rubl
  t-pay.num-lines = t-pay.num-lines + 1
  t-pay.was-return = if t-pay.was-return
                      then t-pay.was-return
                      else ({2}.line-sign = no)
  t-pay.byval = (if t-pay.byval = ''
                then (if {2}.src-val = 0
                      then 'nbyval'
                      else 'byval'
                      )
                else (if (t-pay.byval = 'byval'
                      and {2}.src-val = 0)
                      or (t-pay.byval = 'nbyval'
                      and {2}.src-val <> 0)
                      then 'error'
                      else t-pay.byval)
                )
  .



/* $Workfile$ e n d */