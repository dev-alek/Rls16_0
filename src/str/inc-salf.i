/*

$Revision$
$Author$
$Date$
$Workfile$
$rchive: $

Функция получения типов и количества документов для резервирования по чеку и строке чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/15/05
Author: Bakhtadze Natalya
Creation date: 10/15/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION get-inc-sal returns integer(input p-chk-type as character
                                   , input p-netto as decimal
                                   , input p-chk-doc as logical  /*если yes значит запрашиваем для чека в целом*/
                                   , input p-office as character
                                   , input p-write-off-code  as character
                                   , output p-add as logical
                                   , output p-office-to-reserv as character /*тип товара накладной*/
                                   , output p-kind-to-reserv as character
                                   /*если запрос для строчки чека вернул 0 и пусто
                                   значит резервирование такое же как и для шапки чека
                                   */
                                   , output p-add-nf-amount as integer /*добавлять в к общему nf-кол-ву чеков строк*/
                                   ):
define variable v-docs-to-reserv as integer no-undo.
/*количество документов для резервирования */

/*для мусорных петрольных чеков что для шапки что для строчки все по нулям!!!*/

if lookup(p-chk-type , {&no-docum-receipt-codes}) > 0
then do:
    assign
    v-docS-to-reserv = 0
    p-kind-to-reserv = '':U
    p-add-nf-amount = 1
    .
    return v-docs-to-reserv.
end.
p-add = no.
/*выясним по шапке*/
if p-chk-doc then do:
  if p-chk-type = ? then do:
    if p-netto >= 0 then do:
      assign
      p-chk-type = {&rcpt-sale}.
    end.
    if p-netto < 0 then do:
      assign
      p-chk-type = {&rcpt-return}.
    end.
  end.
  CASE p-chk-type:
    when {&rcpt-sale} then do:
      assign
      p-kind-to-reserv = {&TDEDT_ras_Vnesh_kass}
      v-docs-to-reserv = 1
      .
    end.
    when {&rcpt-return} then do:
      assign
      p-kind-to-reserv = {&TDEDT_Vozvrat_Vnesh_Kass}
      v-docs-to-reserv = 1
      .
    end.
    when {&rcpt-tech-refuell} then do:
      assign
      p-kind-to-reserv = {&sale-add-tech-refuell}
      v-docs-to-reserv = 1
      .
    end.
    when {&rcpt-return-write-off} then do:
      assign
      p-kind-to-reserv = {&TDEDT_Vozvrat_Vnesh_kass} + {&comma-char} + {&sale-add-return-write-off}
      v-docs-to-reserv = 2
      .
    end.
    when {&rcpt-write-off} then do:
      assign
      p-kind-to-reserv = {&sale-add-write-off}
      v-docs-to-reserv = 1
      .
    end.
    otherwise do:
      assign
      p-kind-to-reserv = '':U
      v-docs-to-reserv = 0
      .
    End.
  END CASE.
  ASSIGN
  p-add-nf-amount = 0.
  if p-office = {&gds-goods}
  or p-office = {&gds-office} then do:
    p-office-to-reserv = (if v-docs-to-reserv = 0
                          then '':U
                          else trim(fill((p-office + {&comma-char}), v-docs-to-reserv), {&comma-char})).
  end.
  else do:
    assign
    p-office-to-reserv  = (if v-docs-to-reserv = 0
                           then '':U
                           else (trim(fill(entry(1, p-office) + {&comma-char}, v-docs-to-reserv), {&comma-char}) +
                                {&comma-char} +
                                 trim(fill(entry(2, p-office) + {&comma-char}, v-docs-to-reserv), {&comma-char})))
    v-docs-to-reserv = v-docs-to-reserv * 2
    p-kind-to-reserv = (if p-kind-to-reserv = '':U
                        then  '':U
                        else (p-kind-to-reserv + {&comma-char} + p-kind-to-reserv)) .

  end.

  return v-docs-to-reserv.
end. /*if p-chk-doc - по шапке*/
else do: /*по строчкам*/
  ASSIGN
  P-kind-to-reserv = '':U
  p-add-nf-amount = 0
  p-add = yes
  p-office-to-reserv = '':U
  .
  if p-write-off-code = '0':U
  or p-write-off-code = ? then do:
    /*для старых чеков чеков с вопросом в списании и обычных строчек - все по шапке!!!
    т.е. ничего недобавляем к тем docs-to-reserv что уже есть
    */
    return 0.
  end.
  CASE p-chk-type:
    when {&rcpt-sale}
    then do:
       if p-write-off-code = {&wro-without-payment}
       or p-write-off-code = {&wro-r-modificator-wp}
       then do:
          assign
          p-kind-to-reserv = {&sale-add-write-off}
          v-docs-to-reserv = 1
          p-add = no
          p-office-to-reserv = p-office
          .
       end.
    end.
    when {&rcpt-return} then do:
       if p-write-off-code = {&wro-cancell-item}
       or p-write-off-code = {&wro-v-modificator-ci}
       then do:
          assign
          p-kind-to-reserv = {&sale-add-return-write-off}
          v-docs-to-reserv = 1
          p-add = no
          p-office-to-reserv = p-office
          .
       end.
    end.
  END CASE.
  return v-docs-to-reserv.
end. /*по строчке*/
END FUNCTION.


/* $Workfile$ e n d */