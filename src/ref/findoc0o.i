/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверки валиднтси платежа, общие для прихожда и расхода АПЗ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/03/03
Author: Bakhtadze Natalya
Creation date: 12/03/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then

define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc.
define buffer buf_fin-doc for ub.fin-doc.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_fin-connect for ub.fin-connect.

procedure income-expense-gen :
define input parameter p-close-mode as character no-undo .
define output parameter p-correct as logical no-undo .


do
on error undo, return error
:
  find first buf_sysconf no-lock where
            buf_sysconf.host-code = p-host-code .
  if p-status_ = {&fin-permitted} then do:
    if p-naznach-plat = "":U then do:
      assign
      p-err-mess = "Не заполнено основание платежа"
      .
      return "naznach-plat":u.
    end.
  end.
  if p-status_ = {&fin-fact} then do:
    find first buf_fin-connect no-lock where
            buf_fin-connect.host-code      = p-host-code
        AND buf_fin-connect.fin-doc-code   = p-fin-doc-code no-error.
    if not available buf_fin-connect then do:
      if buf_sysconf.fin-calc = {&fin-calc-obj}
      and p-obj-type = "":U and p-obj-code = 0
      then do:
        p-err-mess = substitute("Финансовый учет на фирме ведется пообъектно, а объект не задан")
        .
        return error "obj-code":U.
      end.
    end.
    if p-prn-doc-code = "":U then do:
      assign
      p-err-mess = "Не заполнен номер платежа"
      .
      return "prn-doc-code":U.
    end.
  end.


  if p-status_ = {&fin-fact} then do:
    if buf_sysconf.is-cassa-acc
    and (p-cor-acc1 = ? or p-cor-acc1 = 0) then do:
      if p-fin-doc-type = {&income-payoff} then
      assign
      p-err-mess = "Не заполнен счет/субсчет по дебету"
      .
      else
      assign
      p-err-mess = "Не заполнен счет/субсчет по кредиту"
      .
      return "cor-acc1":U.
    end.

    if buf_sysconf.is-corr-acc
    and (p-cor-acc = ? or p-cor-acc = 0) then do:
      if p-fin-doc-type = {&income-payoff} then
      assign
      p-err-mess = "Не заполнен счет/субсчет по кредиту"
      .
      else
      assign
      p-err-mess = "Не заполнен счет/субсчет по дебету"
      .
      return "cor-acc":U.
    end.

    if buf_sysconf.is-code-cel-nazn
    and (p-cel-nazn-code = ? or p-cel-nazn-code = 0) then do:
      assign
      p-err-mess = "Не заполнен код целевого назначения"
      .
      return "cel-nazn-code":U.
    end.

    if buf_sysconf.is-an-uchet
    and (p-an-uchet-code = ? or p-an-uchet-code = 0) then do:
      assign
      p-err-mess = "Не заполнен код аналитического учета"
      .
      return  "an-uchet-code":U.
    end.

  end.
 if p-close-mode = {&close-doc}
  then do:
    if (p-perm-date <> ? and p-doc-date > p-perm-date )
    or (p-status-date <> ? and p-doc-date > p-status-date and p-status_ = {&fin-permitted})
    then do:
      assign
      p-err-mess = "Дата разр не может быть меньше даты док"
      .
      return "perm-date":U.
    end.
    if (p-pay-date <> ? and p-perm-date > p-pay-date)
    or (p-status-date <> ? and p-perm-date > p-status-date and p-status_ = {&fin-bank} )  then do:
      assign
      p-err-mess = "Дата оплаты не может быть меньше даты разр"
      .
      return "pay-date":U.
    end.
    if (p-fact-date <> ? and p-pay-date > p-fact-date)
    or (p-status-date <> ? and p-pay-date > p-status-date and (p-status_ = {&fin-fact} or p-status_ = {&fin-rejected}))
      then do:
      assign
      p-err-mess = "Дата факт (или дата отказ) не может быть меньше даты платежа".
      return "fact-date":U.
    end.
  end.
  assign
  p-correct = yes
  .
end.

end procedure. /* income-expense-gen */

&endif
/*проверим что все заполнено*/