/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверки валидности выписки

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/19/06
Author: Bakhtadze Natalya
Creation date: 11/19/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then

define variable v-dopi as integer no-undo .
define variable v-reason as character no-undo .
define variable v-author as character no-undo .
define buffer buf_fin-statement for ub.fin-statement.
define buffer buf_sysconf for ub.sysconf.


/*проверим что все заполнено*/
procedure standard-sttm-gen :
define input parameter p-close-mode as character no-undo .
define output parameter p-correct as logical no-undo .

define variable accum-in-rubl as decimal no-undo .
define variable accum-in-base as decimal no-undo .
define variable accum-in-doc as decimal no-undo .
define variable accum-out-rubl as decimal no-undo .
define variable accum-out-base as decimal no-undo .
define variable accum-out-doc as decimal no-undo .


define buffer buf_fin-statement-line for ub.fin-statement-line.

do
on error undo, return error
:

  find first buf_sysconf no-lock where
            buf_sysconf.host-code = p-host-code .

  if p-status_ = {&fin-fact} then do:
    if p-prn-doc-code = "":U then do:
      assign
      p-err-mess = "Не заполнен номер выписки"
      .
      return "prn-doc-code":U.
    end.
  end.

  if v-author = 'cl-bank':U
  then do:
    if p-bik = "":U then do:
      assign
      p-err-mess = "Не заполнен БИК БАНКА"
      .
          message p-err-mess skip
              "Закрывать выписку ? "
              view-as alert-box question
              buttons yes-no
              title "ВНИМАНИЕ !!!"
              update v-ok3 as logical.

          if not v-ok3 then do:
             return "bik":U.
          end.
    end.
    if p-r-schet = "":U then do:
      assign
      p-err-mess = "Не заполнен р/с БАНКА"
      .
      return "r-schet":U.
    end.
    if p-bank-name = "":U then do:
      assign
      p-err-mess = "Не заполнен банк"
      .
      return "bank-name":U.
    end.
  end.
  if p-close-mode = {&close-doc}
  then do:
    if (p-fact-date <> ? and p-doc-date > p-fact-date)
    or (p-status-date <> ? and p-doc-date > p-status-date and (p-status_ = {&fin-fact}))
      then do:
      assign
      p-err-mess = "Дата факт не может быть меньше даты составления выписки".
      return "fact-date":U.
    end.
    if (p-fact-date <> ? and p-bank-date > p-fact-date)
    or (p-status-date <> ? and p-bank-date > p-status-date and (p-status_ = {&fin-fact}))
      then do:
      assign
      p-err-mess = "Дата факт не может быть меньше даты прохождения выписки в банке".
      return "fact-date":U.
    end.
    if p-bank-date <> ? and (p-end-date > p-bank-date)
    or (p-status-date <> ? and p-end-date > p-status-date and (p-status_ = {&fin-fact}))
    then do:
      assign
      p-err-mess = "Дата прохождения выписка в банке не может быть меньше даты конца выписки".
      return "bank-date":U.
    end.
    if p-fact-date <> ? and (p-end-date > p-fact-date)
    or (p-status-date <> ? and p-end-date > p-status-date and (p-status_ = {&fin-fact}))
    then do:
      assign
      p-err-mess = "Дата факт не может быть меньше даты конца выписки".
      return "fact-date":U.
    end.
  end.
  assign
  p-correct = yes
  .
  for each buf_fin-statement-line no-lock where
          buf_fin-statement-line.host-code = p-host-code
      AND buf_fin-statement-line.sttm-code = p-sttm-code
      AND buf_fin-statement-line.fin-doc-code > 0
      :
    assign
    accum-in-doc  = accum-in-doc    + (if buf_fin-statement-line.fin-ext-doc-type = {&FDEDT_income_cashless}
                                      then buf_fin-statement-line.sum-doc
                                      else 0)
    accum-out-doc  = accum-out-doc  + (if buf_fin-statement-line.fin-ext-doc-type = {&FDEDT_expense_cashless}
                                      then buf_fin-statement-line.sum-doc
                                      else 0)
    .
  end.
  if accum-in-doc > p-in-sum-doc
  then do:
    assign
    p-err-mess = "Сумма по приходным документам выписки в TH больше суммы приходов в выписке по данным банка".
    return "in-sum-doc":U.
  end.
  if accum-out-doc > p-out-sum-doc
  then do:
    p-err-mess = "Сумма по расходным документам выписки в TH больше суммы расходов в выписке по данным банка".
    return "out-sum-doc":U .
  end.
  if p-in-sum-doc - p-out-sum-doc <> p-sum-doc then do:
    p-err-mess = "Суммы приходных и расходных оборотов не равны общей сумме обротов по данным банка".
    return  "":U .
  end.
  if p-start-sum-doc  + p-in-sum-doc - p-out-sum-doc <> p-end-sum-doc then do:
    p-err-mess = "Суммы приходных и расходных оборотов, сложенных с суммой входящего остатка не равны исходящему остатку в выписке по данным банка".
    return "":U .
  end.

  /*
  if p-start-sum-rubl-th + p-in-sum-rubl-th - p-out-sum-rubl-th <> p-end-sum-rubl-th
  or p-start-sum-base-th + p-in-sum-base-th - p-out-sum-base-th <> p-end-sum-base-th
  or p-start-sum-doc-th  + p-in-sum-doc-th - p-out-sum-doc-th <> p-end-sum-doc-th then do:
    p-err-mess = "Суммы приходных и расходных оборот сложенных с суммой входящего остатка не равны исходящему остатку в выписке по документам в TH".
    return "":U.
  end.
  if accum-in-rubl <> p-in-sum-rubl-th
  or accum-in-base <> p-in-sum-base-th
  or accum-in-doc <> p-in-sum-doc-th then do:
    p-err-mess = "Сумма по приходным документам выписки в TH не равна сумме приходов в выписке в шапке выписки".
    return "in-sum-doc-th":U .
  end.
  if accum-out-rubl <> p-out-sum-rubl-th
  or accum-out-base <> p-out-sum-base-th
  or accum-out-doc <> p-out-sum-doc-th then do:
    p-err-mess "Сумма по расходным документам выписки в TH не равна сумме приходов в выписке в шапке выписки".
    return "out-sum-doc-th":U .
  end.
  */


end. /*doe*/

end procedure. /* standard-sttm-gen */

&endif /*&if "{1}" = "def" */

/* $Workfile$ e n d */