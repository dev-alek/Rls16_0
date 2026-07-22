/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверки валидности платежа, общие для прихожда и расхода безнал

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/03/03
Author: Bakhtadze Natalya
Creation date: 12/03/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "def" &then

define variable v-is-an-uchet as logical no-undo .
define variable v-dopi as integer no-undo .
define variable v-reason as character no-undo .
define variable v-author as character no-undo .
define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc.
define buffer buf_fin-doc for ub.fin-doc.
define buffer buf_sysconf for ub.sysconf.
define buffer buf_fin-connect for ub.fin-connect.

&scop fin-f107-codes "Д1,Д2,Д3,МС,КВ,ПЛ,ГД":U

FUNCTION check-f107 RETURNS LOGICAL(input  p-f107 as character,
                                    output p-reason as character):

define variable v-dopi as integer no-undo .
define variable v-dopdate as date no-undo .
if length(p-f107) <> 10 then do:
  assign
  p-reason = "длина должна быть 10 знаков"
  .
  return no.
end.
if substr(p-f107, 3, 1) <> ".":U
or substr(p-f107, 6, 1) <> ".":U then do:
  assign
  p-reason = "3-й и 6-й знаки должны быть точками".
  .
  return no.
end.
assign
v-dopi = integer(substr(p-f107, 1, 2))
no-error .
if not error-status:error then do:
  /*может быть конекретная дата*/
  assign
  v-dopdate = date(
                   integer(substr(p-f107, 4, 2))
                  , integer(substr(p-f107, 1, 2))
                  , integer(substr(p-f107, 7, 4))
                 )
  no-error .
  if error-status:error then do:
    assign
    p-reason = "не соответствует никакой дате"
    .
    return no.
  end.
end.
if LOOKUP(substr(p-f107, 1, 2), {&fin-f107-codes}) = 0 then do:
  assign
  p-reason = substitute("первые два знака должно быть одни из &1", {&fin-f107-codes}).
  .
  return no.
end.
assign
v-dopi = integer(substr(p-f107, 4, 2))
no-error .
CASE substr(p-f107, 1, 2):
  when "Д1":U
  or
  when "Д2":U
  or
  when "Д3":U
  or
  when "МС":U then do:
    if error-status:error
    or v-dopi < 1
    or v-dopi > 12 then do:
      assign
      p-reason = "4 и 5 знак должны быть равны номеру месяца -от 01 до 12".
      .
      return no.
    end.
  end.
  when "КВ":U then do:
    if error-status:error
    or v-dopi < 1
    or v-dopi > 4 then do:
      assign
      p-reason = "4 и 5 знак должны быть равны номеру квартала -от 01 до 04".
      .
      return no.
    end.
  end.
  when "ПЛ":U then do:
    if error-status:error
    or v-dopi < 1
    or v-dopi > 2 then do:
      assign
      p-reason = "4 и 5 знак должны быть равны номеру полугодия -от 01 до 02".
      .
      return no.
    end.
  end.
  when "ГД":U then do:
    if error-status:error
    or v-dopi <> 0 then do:
      assign
      p-reason = "4 и 5 знак должны быть равны 00".
      .
      return no.
    end.
  end.
END CASE.

assign
p-reason = "":U.
RETURN yes.
END FUNCTION.


FUNCTION check-f109 RETURNS LOGICAL(input  p-f109 as character,
                                    output p-reason as character):

define variable v-dopdate as date no-undo .
if length(p-f109) <> 10 then do:
  assign
  p-reason = "длина должна быть 10 знаков"
  .
  return no.
end.
if substr(p-f109, 3, 1) <> ".":U
or substr(p-f109, 6, 1) <> ".":U then do:
  assign
  p-reason = "3-й и 6-й знаки должны быть точками".
  .
  return no.
end.
/*должна быть конекретная дата*/
assign
v-dopdate = date(
                  integer(substr(p-f109, 4, 2))
                , integer(substr(p-f109, 1, 2))
                , integer(substr(p-f109, 7, 4))
                )
no-error .
if error-status:error then do:
  assign
  p-reason = "не соответствует никакой дате"
  .
  return no.
end.
assign
p-reason = "":U.
RETURN yes.
END FUNCTION.



/*проверим что все заполнено*/
procedure income-expense-gen :
define input parameter p-close-mode as character no-undo .
define output parameter p-correct as logical no-undo .

define buffer buf_firm for ub.firm.
define buffer buf_person for ub.person.

do
on error undo, return error
:

  find first buf_sysconf no-lock where
            buf_sysconf.host-code = p-host-code .

  if p-status_ = {&fin-permitted}
  or v-author = 'cl-bank':U
  then do:
    if p-naznach-plat = "":U then do:
      assign
      p-err-mess = "Не заполнено основание платежа"
      .
      return "naznach-plat":u.
    end.
    if p-vid-opl <> '01':U then do:
      assign
      p-err-mess = "Неверное значение поля <Вид оп.>"
      .
      return "vid-opl":u.

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
    if buf_sysconf.is-corr-acc
    and (p-cor-acc = ? or p-cor-acc = 0) then do:
      assign
      p-err-mess = "Не заполнен корр. счет/субсчет"
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
          AND buf_fin-code-cor-acc.fin-code = p-cor-acc.

    if NOT (string(buf_fin-code-cor-acc.acc-type) = {&fin-acc-active-code}
            or
            string(buf_fin-code-cor-acc.acc-type) = {&fin-acc-actpass-code}
            ) then do:
      if p-fin-doc-type = {&income-cashless} then
      assign
      p-err-mess = "Неверный тип счета/субсчета по кредиту"
      .
      else
      assign
      p-err-mess = "Неверный тип счета/субсчета по дебету"
      .
      return "cor-acc":U.
    end.
    */
  end.
  /*вид платежа*/
  if LOOKUP(p-vid-plat , {&fin-vp-codes}) = 0 then do:
    assign
    p-err-mess = "Неверный тип платежа -должен быть один из" + {&space-char} + {&fin-vp-codes}
    .
    return "vid-plat":U.
  end.
  if p-status_ = {&fin-permitted}
  or v-author = 'cl-bank':U
  then do:
    if p-payer-inn = "":U then do:
      assign
      p-err-mess = "Не заполнен {&abbr_inn_allshift} ПЛАТЕЛЬЩИКА"
      .
      return "payer-inn":U.
    end.
    if p-payer-kpp = "":U
    then do:
      CASE p-payer-type:
        when {&cmp} then do:
          find first buf_firm no-lock where
                    buf_firm.firm-code = p-payer-code .
        end.
        when {&prs} then do:
          find first buf_person no-lock where
                    buf_person.psn-code = p-payer-code .
        end.
      END CASE.
/*      if (p-payer-type = {&cmp} and not buf_firm.is-pboul)         */
/*      then do:                                                     */
/*        assign                                                     */
/*        p-err-mess = "Не заполнен {&abbr_kpp_allshift} ПЛАТЕЛЬЩИКА"*/
/*        .                                                          */
/*        return "payer-kpp":U.                                      */
/*      end.                                                         */
    end.
    if p-payer-bik = "":U then do:
      assign
      p-err-mess = "Не заполнен БИК ПЛАТЕЛЬЩИКА"
      .
          message p-err-mess skip
              "Закрывать документ ? "
              view-as alert-box question
              buttons yes-no
              title "ВНИМАНИЕ !!!"
              update v-ok3 as logical.

          if not v-ok3 then do:
             return "payer-bik":U.
          end.



    end.
    if p-payer-r-schet = "":U then do:
      assign
      p-err-mess = "Не заполнен р/с ПЛАТЕЛЬЩИКА"
      .
      return "payer-r-schet":U.
    end.
    if p-payer-bank-name = "":U then do:
      assign
      p-err-mess = "Не заполнен банк ПЛАТЕЛЬЩИКА"
      .
      return "payer-bank-name":U.
    end.
    if p-payer-c-schet = "":U then do:
      if not (
              (substring(p-payer-bik, 7, 9) = '000'
              or
              substring(p-payer-bik, 7, 9) = '001'
              or
              substring(p-payer-bik, 7, 9) = '002'
              )
              and not
              ( "{&abbr_rub}" = "тг."
                or "{&abbr_rub}" = "грн"
                or "{&abbr_rub}" = "дрм"
                or "{&abbr_rub}" = "lei")
             )
      then do:
        assign
        p-err-mess = "Не заполнен к/с ПЛАТЕЛЬЩИКА"
        .
        define variable v-nocoracc as character no-undo .
        define variable v-conf-type as character no-undo .
        { gbl/conf-rd.i  "'nocoracc'"  0  "''":U  0  "''":U  "''":U  "''":U  NO v-nocoracc v-conf-type NO-ERROR }
        IF ERROR-STATUS:ERROR OR v-conf-type <> {&type-log} THEN v-nocoracc = "no".
        if v-nocoracc = "no" then   return "payer-c-schet":U.
      end.
    end.
    if p-receiver-inn = "":U then do:
      assign
      p-err-mess = "Не заполнен {&abbr_inn_allshift} ПОЛУЧАТЕЛЯ"
      .
      return "receiver-inn":U.
    end.
    if p-receiver-kpp = "":U then do:
      CASE p-receiver-type:
        when {&cmp} then do:
          find first buf_firm no-lock where
                    buf_firm.firm-code = p-receiver-code .
        end.
        when {&prs} then do:
          find first buf_person no-lock where
                    buf_person.psn-code = p-receiver-code .
        end.
      END CASE.
/*      if (p-receiver-type = {&cmp} and not buf_firm.is-pboul)     */
/*      then do:                                                    */
/*        assign                                                    */
/*        p-err-mess = "Не заполнен {&abbr_kpp_allshift} ПОЛУЧАТЕЛЯ"*/
/*        .                                                         */
/*        return "receiver-kpp":U.                                  */
/*      end.                                                        */
    end.
    if p-receiver-bik = "":U then do:
      assign
      p-err-mess = "Не заполнен БИК ПОЛУЧАТЕЛЯ"
      .
          message p-err-mess skip
              "Закрывать документ ? "
              view-as alert-box question
              buttons yes-no
              title "ВНИМАНИЕ !!!"
              update v-ok4 as logical.

          if not v-ok4 then do:
             return "receiver-bik":U.
          end.


    end.
    if p-receiver-r-schet = "":U then do:
      assign
      p-err-mess = "Не заполнен р/с ПОЛУЧАТЕЛЯ"
      .
      return "receiver-r-schet":U.
    end.
    if p-receiver-bank-name = "":U then do:
      assign
      p-err-mess = "Не заполнен банк ПОЛУЧАТЕЛЯ"
      .
      return "receiver-bank-name":U.
    end.
    if p-receiver-c-schet = "":U then do:
      if not (
             (substring(p-receiver-bik, 7, 9) = '000'
              or
              substring(p-receiver-bik, 7, 9) = '001'
              or
              substring(p-receiver-bik, 7, 9) = '002'
              )
              and not
              ( "{&abbr_rub}" = "тг."
                or "{&abbr_rub}" = "грн"
                or "{&abbr_rub}" = "дрм"
                or "{&abbr_rub}" = "lei")
             )
       then do:
        assign
        p-err-mess = "Не заполнен к/с ПОЛУЧАТЕЛЯ"
        .
        { gbl/conf-rd.i  "'nocoracc'"  0  "''":U  0  "''":U  "''":U  "''":U  NO v-nocoracc v-conf-type NO-ERROR }
        IF ERROR-STATUS:ERROR OR v-conf-type <> {&type-log} THEN v-nocoracc = "no".
        if v-nocoracc = "no" then   return "payer-c-schet":U.
      end.
    end.
    assign
    v-dopi =  integer(p-ocher-pl)
    no-error .
    if error-status:error
    or v-dopi < 1 or v-dopi > 6 then do:
      assign
      p-err-mess = "Неверно заполнено поле очередность платежа"
      .
      return "ocher-pl":U.
    end.
    /*
    все остальные случаи относятся к платежам в налоги бюджет и пр
    */
    if p-stat-pl <> "":U then do:
      if lookup(p-stat-pl, {&fin-statpl-codes}) = 0 then do:
        assign
        p-err-mess = "Неверно заполнено поле статус плательщика"
        .
        return "stat-pl":U.
      end.
      if p-f104 = "":U then do:
        assign
        p-err-mess = "Не заполнено поле показателя Кода Бюджетной Классификации"
        .
        return "f-104":U.
      end.
      if p-f105 = "":U then do:
        assign
        p-err-mess = "Не заполнено поле кода ОКАТО"
        .
        return "f-105":U.
      end.
      if p-f106 = "":U
      or lookup(p-f106, {&fin-osnpl-codes}) = 0
      then do:
        assign
        p-err-mess = "Не заполнено или неверно заполнено поле показателя основания платежа"
        .
        return "f-106":U.
      end.
      if p-f107 = "":U
      or check-f107(p-f107, output v-reason) = no
      then do:
        assign
        p-err-mess = substitute("Не заполнено или неверно заполнено поле показателя налового периода: &1", v-reason)
        .
        return "f-107":U.
      end.
      if (p-f106 = "ТП":U
      or p-f106 = "ЗД":U )
      and p-f108 <> "0":U then do:
        assign
        p-err-mess = substitute("Неверно заполнено поле показателя номера документа: если показатель основания платежа = &1, то там должно стоять <0>", p-f106)
        .
        return "f-108":U.
      end.
      if p-f109 = "":U
      or check-f109(p-f109, output v-reason) = no
      then do:
        assign
        p-err-mess = substitute("Не заполнено или неверно заполнено поле показателя даты документа: &1", v-reason)
        .
        return "f-109":U.
      end.
      if p-f110 = "":U
      or lookup(p-f110, {&fin-tippl-codes}) = 0
      then do:
        assign
        p-err-mess = "Не заполнено или неверно заполнено поле показателя типа платежа"
        .
        return "f-110":U.
      end.
    end.
  end.
  if p-close-mode = {&close-doc}
  or p-close-mode = {&reject-doc}
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

end. /*doe*/

end procedure. /* income-expense-gen */

&endif /*&if "{1}" = "def" */

/* $Workfile$ e n d */