/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ѕолучение цены на товар с категорийной скидкой

јвтор: Ѕахтадзе Ќаталь€ ¬икторовна
ƒата создани€: 07/01/08
Author: Bakhtadze Natalya
Creation date: 07/01/08


если вправиле скидки много категорий - возвратитьс€ error

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/str-glbl.i }

procedure dr-katp :
define input parameter p-gds-code as integer no-undo .
define input parameter p-b-code as integer no-undo .
define input parameter p-obj-type as character no-undo .
define input parameter p-obj-code as integer no-undo .
define input parameter p-dflt-cd as character no-undo .
define input parameter p-base-price as decimal no-undo .
define input parameter p-how-kat-disc as character no-undo .
define input parameter p-fact-order as decimal no-undo .
define output parameter p-netto-price as decimal no-undo .

define variable v-d-value as decimal no-undo .
define variable v-type as character no-undo .
define variable v-value-type as integer no-undo .
/*define variable v-time-rule-num as integer no-undo .*/
define variable v-discnt-type as integer no-undo .
define variable v-rule-num as integer no-undo .
define variable v-disc-price-sale as decimal no-undo .
define variable v-pdf-id as integer no-undo .
define variable v-pdf-db-num as integer no-undo .

define buffer buf_dis-gds-rule for ub.dis-gds-rule.
define buffer buf_Dis-rule for ub.dis-rule.
define buffer term_dis-rule for ub.dis-rule.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-include-info{&vssseq} )
on endkey undo main-block, return error substitute( "&1. endkey", vss-include-info{&vssseq} )
:

  if p-base-price = ?
  or p-base-price  <= 0
  then do:
    undo main-block, return error substitute("Ќеверно задана базова€ цена (&1) дл€ товара &2 на &3&4"
                                  , p-base-price
                                  , p-gds-code
                                  , p-obj-type
                                  , p-obj-code).
  end.
  case entry(1, how-pcnt-kat, "="):
    when {&dgr-pcnt-kat} then do:
  find first  buf_dis-gds-rule No-LOCK  where
            buf_dis-gds-rule.gds-code = p-gds-code
        AND  buf_dis-gds-rule.obj-code = p-obj-code
        AND  buf_dis-gds-rule.obj-type = p-obj-type
        and  buf_dis-gds-rule.pos-type = p-dflt-cd
        and  buf_dis-gds-rule.discnt-role = {&dgr-pcnt-kat}
        no-error .
      if available buf_dis-gds-rule
      and buf_dis-gds-rule.nonunique <> ''
      and buf_dis-gds-rule.nonunique <> string(p-b-code) then do:
        find first  buf_dis-gds-rule No-LOCK  where
                  buf_dis-gds-rule.gds-code = p-gds-code
              AND  buf_dis-gds-rule.obj-code = p-obj-code
              AND  buf_dis-gds-rule.obj-type = p-obj-type
              and  buf_dis-gds-rule.pos-type = p-dflt-cd
              and  buf_dis-gds-rule.discnt-role = {&dgr-pcnt-kat}
              and  buf_dis-gds-rule.nonunique = string(p-b-code)
              no-error .
      end.
  if not available buf_Dis-gds-rule then do:
    p-netto-price = p-base-price.
    return.
  end.
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = buf_dis-gds-rule.rule-num no-error.
  if not available buf_dis-rule
  or not (buf_dis-rule.obj-type = p-obj-type
          and
          buf_dis-rule.obj-code = p-obj-code)
  then do:
     undo main-block, return error substitute("Ќе найдено правило категорийной скидки &1 дл€ товара &2 на &3&4 с местом действи€ &5"
                                  , buf_dis-gds-rule.rule-num
                                  , p-gds-code
                                  , p-obj-type
                                  , p-obj-code
                                  , p-dflt-cd
                                                                    ).
  end.
  if buf_dis-rule.templ-rl-root = 34
  then do:
     undo main-block, return error substitute("Ќельз€ найти категорийную скидку - правило категорийной скидки &1 дл€ товара &2 на &3&4 имеет шаблон &5"
                                  , buf_dis-gds-rule.rule-num
                                  , p-gds-code
                                  , p-obj-type
                                  , p-obj-code
                                  , buf_dis-rule.templ-rl-root
                                                                    ).
  end.
  if buf_dis-rule.is-term = no then do:
    find /*не FIRST*/ term_dis-rule no-lock where
                    term_dis-rule.upper-rule-num = buf_dis-rule.rule-num no-error.
    if not available term_dis-rule
    or ambiguous term_dis-rule then do:
     undo main-block, return error substitute("Ќе удаетс€ однозначно определить тип и значение категорийной скидки (правило &1) дл€ товара &2 на &3&4"
                                  , buf_dis-gds-rule.rule-num
                                  , p-gds-code
                                  , p-obj-type
                                  , p-obj-code
                                                                    ).
    end.
    assign
    v-value-type = term_Dis-rule.value-type
    v-d-value = term_dis-rule.discnt-value
/*    v-time-rule-num = term_dis-rule.time-rule-num*/
    v-discnt-type = term_dis-rule.discnt-type
    .
  end.
  else do:
    assign
    v-value-type = buf_Dis-rule.value-type
    v-d-value = buf_dis-rule.discnt-value
/*    v-time-rule-num = buf_dis-rule.time-rule-num*/
    v-discnt-type = buf_Dis-rule.discnt-type
    .
  end.
/*  if v-time-rule-num > 0 then do:*/
    if v-discnt-type <> {&bef-discnt-t-categ} then do:
     undo main-block, return error substitute("Ќельз€ найти категорийную скидку - правило категорийной скидки &1 дл€ товара &2 на &3&4 прив€зано к расписанию"
                                  , buf_dis-gds-rule.rule-num
                                  , p-gds-code
                                  , p-obj-type
                                  , p-obj-code
                                                                    ).

  end.
  case v-value-type:
    when integer({&discnt-v-abs}) then do:
      assign
      p-netto-price = p-base-price - v-d-value
      .
    end.
    when integer({&discnt-v-pcnt}) then do:
      assign
      p-netto-price = p-base-price * (1 - v-d-value / 100)
      .
    end.
    when integer({&discnt-v-fp}) then do:
      assign
      p-netto-price = v-d-value
      .
    end.
  end.
    end. /*when {&dgr-pcnt-kat} then do:*/
    when {&dthbjr-pcnt-kat-pdf} then do:
      if num-entries(how-pcnt-kat, "=") > 1
      and integer(entry(2, how-pcnt-kat, "=")) > 0 then do:
      v-rule-num = integer(entry(2, how-pcnt-kat, "=")).
      for each buf_dis-rule no-lock where
            buf_dis-rule.rule-num = v-rule-num
        or buf_dis-rule.upper-rule-num = v-rule-num  :
        if buf_dis-rule.is-term then do:
          /*получим % из соотношени€ cash-gds.price-sale и цены полученной из прайс-листа типа cash-dis-rule.charkey_one*/
          run mpl-tpl-auto in this-procedure ( input p-b-code
                                              ,input p-obj-type
                                              ,input p-obj-code
                                              ,input integer(entry(1, buf_dis-rule.charkey_one,"-"))
                                              ,input integer(entry(2, buf_dis-rule.charkey_one,"-"))
                                              ,input p-fact-order /*fact-order*/
                                              ,output v-disc-price-sale
                                              ,output v-pdf-id
                                              ,output v-pdf-db-num ) no-error.
          if error-status:error
          or v-disc-price-sale = 0
          or v-disc-price-sale = ?
          then do:
            /*ничего*/
            p-netto-price = p-base-price.
          end.
          else do:
            p-netto-price = v-disc-price-sale.
          end.
          leave.
        end. /*if buf_dis-rule.is-term then do:*/
        end. /*for each cash-dis-rule no-lock where*/
      end. /*and integer(entry(2, how-pcnt-kat, "=")) > 0 then do:*/
    end . /*when {&dthbjr-pcnt-kat-pdf} then do:*/
  end case.
end.
end procedure. /* dr-katp */