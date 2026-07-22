/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверки валиднтси платежа, общие для прихожда и расхода НАЛ

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
    if p-naznach-plat = "":U
    and p-CashBookId = 0
    then do:
      assign
      p-err-mess = "Не заполнено основание платежа"
      .
      return "naznach-plat":u.
    end.
    if p-receiver-passport = "":U then do:
      p-err-mess = "Нет данных о документе, удостоверяющем личность ПОЛУЧАТЕЛЯ"
      .
    end.
  end.
  if p-status_ = {&fin-fact} then do:
    if p-prn-doc-code = "":U then do:
      assign
      p-err-mess = "Не заполнен номер платежа"
      .
      return "prn-doc-code":U.
    end.
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
  end.
  if p-status_ = {&fin-fact} then do:
    if buf_sysconf.is-cassa-acc
    and (p-cor-acc1 = ? or p-cor-acc1 = 0) then do:
      if p-fin-doc-type = {&income-cash} then
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
      if p-fin-doc-type = {&income-cash} then
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

    /*   по требованию ФИлипповой проверка снята */
    /*проверим правильность выбора дебет-кредит*/
    /*

    find first buf_fin-code-cor-acc no-lock where
              buf_fin-code-cor-acc.host-code = p-host-code
          AND buf_fin-code-cor-acc.fin-code = p-cor-acc1 no-error .

    if NOT (string(buf_fin-code-cor-acc.acc-type) = {&fin-acc-passive-code}
            or
            string(buf_fin-code-cor-acc.acc-type) = {&fin-acc-actpass-code}
            ) then do:
      if p-fin-doc-type = {&income-cash} then
      assign
      p-err-mess = "Неверный тип счета/субсчета по дебету"
      .
      else
      assign
      p-err-mess = "Неверный тип счета/субсчета по кредиту"
      .
      return .
    end.
    find first buf_fin-code-cor-acc no-lock where
              buf_fin-code-cor-acc.host-code = p-host-code
          AND buf_fin-code-cor-acc.fin-code = p-cor-acc.

    if NOT (string(buf_fin-code-cor-acc.acc-type) = {&fin-acc-active-code}
            or
            string(buf_fin-code-cor-acc.acc-type) = {&fin-acc-actpass-code}
            ) then do:
      if p-fin-doc-type = {&income-cash} then
      assign
      p-err-mess = "Неверный тип счета/субсчета по кредиту"
      .
      else
      assign
      p-err-mess = "Неверный тип счета/субсчета по дебету"
      .
      return .
    end.
    */
  end.
  assign
  p-correct = yes
  .
end.

end procedure. /* income-expense-gen */

&endif
/*проверим что все заполнено*/