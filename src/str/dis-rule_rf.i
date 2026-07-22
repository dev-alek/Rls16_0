/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запуск выполнения правил скидок

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/06/08
Author: Bakhtadze Natalya
Creation date: 08/06/08

*/


&if defined(dis-rule_rf_i) = 0 &then

&glob dis-rule_rf_i



&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/distruls.i def }
{ rul/dis-time-rule_f.i }

&scop time-ok  (buf_Dis-rule.time-templ-rl-root <= ~{&dtr-templates-shift~} or ~
dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - ~{&dtr-templates-shift~}, "99999") ~
                                       , input buf_dis-rule.time-rule-num  ~
                                       , input p-date ~
                                       , input p-time ~))

&scop term-time-ok  (buf_term-Dis-rule.time-templ-rl-root <= ~{&dtr-templates-shift~} or ~
dynamic-function( "dis-time-rule_" + string(buf_term-dis-rule.time-templ-rl-root - ~{&dtr-templates-shift~}, "99999" ) ~
                                       , input buf_term-dis-rule.time-rule-num  ~
                                       , input p-date ~
                                       , input p-time ~))

&endif

FUNCTION dis-rule_rf_00001 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price-netto as decimal
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        , output p-not-found as logical
                                        ):
/*@% скидка на строку товара (для MARIA-только топливо)*/
/*возвращает КУСОК скидки в r-b на ед измерения*/
define buffer buf_dis-rule for ub.dis-rule.
p-value-type = integer({&discnt-v-pcnt}).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok} then do:
  p-discnt-pcnt = buf_dis-rule.discnt-value.
  return p-price-netto * buf_dis-rule.discnt-value / 100.
end.
p-not-found = yes.
return 0.
end function.


FUNCTION dis-rule_rf_00002 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price-base-netto as decimal
                                        , input p-qnty as decimal
                                        , input p-cli-base-rate as decimal
                                        , output p-discnt-sum as decimal
                                        , output p-value-type as integer
                                        , output p-not-found as logical
                                        ):
/*@abs скидка на строку товара (для MARIA-только топливо)*/
/*возвращает КУСОК скидки в r-b на ед измерения*/
define buffer buf_dis-rule for ub.dis-rule.
p-value-type = integer({&discnt-v-abs}).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok} then do:
  /*защита от ухода в 0*/
  if p-price-base-netto - buf_dis-rule.discnt-value <= 0 then do:
    p-discnt-sum  = 0.
    p-not-found = yes.
    return 0.
  end.
  p-discnt-sum = buf_dis-rule.discnt-value * p-qnty * p-cli-base-rate.
  return buf_dis-rule.discnt-value * p-cli-base-rate.
end.
p-not-found = yes.
return 0.
end function.


FUNCTION dis-rule_rf_00003 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-qnty as decimal
                                        , input p-cli-base-rate as decimal
                                        , input-output p-price as decimal
                                        , output p-discnt-sum as decimal
                                        , output p-value-type as integer
                                        , output p-not-found as logical
                                        ):
/*@ФЦ на строку товара */
/*возвращает КУСОК скидки в r-b на ед измерения*/
define variable v-price as decimal no-undo .
define buffer buf_dis-rule for ub.dis-rule.
p-value-type = integer({&discnt-v-abs}).
v-price = p-price.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok} then do:
  /*защита от ухода в 0*/
  if buf_dis-rule.discnt-value <= 0 then do:
    p-discnt-sum  = 0.
    p-not-found = yes.
    return 0.
  end.
  p-price = buf_dis-rule.discnt-value * p-cli-base-rate.
  p-discnt-sum = (v-price - p-price) * p-qnty.
  return (v-price - p-price).
end.
p-not-found = yes.
return 0.
end function.

FUNCTION dis-rule_rf_00005 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price as decimal
                                        , input p-doc-qnty as decimal
                                        , input p-discnt-role as character
                                        , input p-gds-code as integer
                                        , input p-line-num as integer
                                        , input p-chk-gds-table as handle
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        , output p-intended as logical
                                        , input-output p-doc-recalc-gline-num as integer
                                        , input-output p-gline-recalc-line-num as integer
                                        , output p-not-found as logical
                                        ):
/*% скидка на кол-во по строке товара (POS IBM IBM-XML IBS-TH)*/
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
define variable v-delta as decimal no-undo .
define variable v-start as logical no-undo init yes.
define variable v-discnt as decimal no-undo .
define variable v-qnty as decimal no-undo .
define variable glog as logical no-undo .
define variable v-chk-gds-bh as handle no-undo .
define variable v-line-num as integer no-undo init -1.
define variable v-current-line as integer no-undo .
p-value-type = integer({&discnt-v-pcnt}).
v-qnty = p-doc-qnty.
p-intended = yes.
create buffer v-chk-gds-bh for table p-chk-gds-table:default-buffer-handle.
do while true:
 assign
 glog = v-chk-gds-bh:find-first( substitute("where gds-code = &1 and line-num > &2"
                                     , p-gds-code
                                     , v-current-line
                                     )) no-error.
 if not glog
 or error-status:error
 or v-chk-gds-bh:available = no
 then leave.
 assign
  v-current-line = v-chk-gds-bh:buffer-field("line-num"):buffer-value
  v-line-num = (if v-line-num > v-current-line
                or v-line-num = -1
                then v-current-line
                else v-line-num)
 .

 if v-chk-gds-bh:buffer-field("line-num"):buffer-value = p-line-num then do:
 end.
 else do:
  assign
  v-qnty = v-qnty + v-chk-gds-bh:buffer-field("will-doc-qnty"):buffer-value
  .
 end.
end.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.doc-qnty <= v-qnty then do:
      if v-start
      or v-delta  > (v-qnty - buf_term-dis-rule.doc-qnty)
      then do:
        assign
        p-discnt-pcnt = buf_term-dis-rule.discnt-value
        v-start = no
        v-delta = v-qnty - buf_term-dis-rule.doc-qnty
        v-discnt  = p-price * buf_term-dis-rule.discnt-value / 100
        p-intended = no
        .
      end.
    end.
  end.
  if (v-line-num < p-line-num
  or p-doc-recalc-gline-num = 0
  or p-doc-recalc-gline-num > v-line-num)
  and not (p-gline-recalc-line-num = v-line-num
          and
          v-line-num = p-line-num)
  then do:
    p-doc-recalc-gline-num = v-line-num.
  end.
  if p-gline-recalc-line-num = 0
  or p-gline-recalc-line-num > v-line-num then do:
    p-gline-recalc-line-num = v-line-num.
  end.
  delete object v-chk-gds-bh.
  p-not-found = not p-intended.
  return v-discnt.
end.
p-not-found = yes.
return 0.
end function.

FUNCTION dis-rule_rf_00006 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price-base as decimal
                                        , input p-doc-qnty as decimal
                                        , input p-cli-base-rate as decimal
                                        , input p-discnt-role as character
                                        , input p-gds-code as integer
                                        , input p-line-num as integer
                                        , input p-chk-gds-table as handle
                                        , output p-discnt-sum as decimal
                                        , output p-value-type as integer
                                        , output p-intended as logical
                                        , input-output p-doc-recalc-gline-num as integer
                                        , input-output p-gline-recalc-line-num as integer
                                        , output p-not-found as logical
                                        ):
/*abs скидка на кол-во по строке товара (POS IBM IBM-XML IBS-TH)*/
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
define variable v-delta as decimal no-undo .
define variable v-start as logical no-undo init yes.
define variable v-discnt as decimal no-undo .
define variable v-qnty as decimal no-undo .
define variable glog as logical no-undo .
define variable v-chk-gds-bh as handle no-undo .
define variable v-line-num as integer no-undo init -1.
define variable v-current-line as integer no-undo .
p-value-type = integer({&discnt-v-abs}).
v-qnty = p-doc-qnty.
p-intended = yes.
create buffer v-chk-gds-bh for table p-chk-gds-table:default-buffer-handle.
do while true:
 assign
 glog = v-chk-gds-bh:find-first( substitute("where gds-code = &1 and line-num > &2"
                                     , p-gds-code
                                     , v-current-line
                                     )) no-error.
 if not glog
 or error-status:error
 or v-chk-gds-bh:available = no
 then leave.
 assign
  v-current-line = v-chk-gds-bh:buffer-field("line-num"):buffer-value
  v-line-num = (if v-line-num > v-current-line
                or v-line-num = -1
                then v-current-line
                else v-line-num)
 .

 if v-chk-gds-bh:buffer-field("line-num"):buffer-value = p-line-num then do:
 end.
 else do:
  assign
  v-qnty = v-qnty + v-chk-gds-bh:buffer-field("will-doc-qnty"):buffer-value
  .
 end.
end.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.doc-qnty <= v-qnty then do:
      if v-start
      or v-delta  > (v-qnty - buf_term-dis-rule.doc-qnty)
      then do:
        assign
        p-discnt-sum = buf_term-dis-rule.discnt-value * p-doc-qnty
        v-start = no
        v-delta = v-qnty - buf_term-dis-rule.doc-qnty
        v-discnt  = buf_term-dis-rule.discnt-value
        p-intended = no
        .
      end.
    end.
  end.
  /*защита от ухода в 0*/
  if p-price-base - v-discnt <= 0 then do:
    p-discnt-sum  = 0.
    p-not-found = yes.
    return 0.
  end.

  if (v-line-num < p-line-num
  or p-doc-recalc-gline-num = 0
  or p-doc-recalc-gline-num > v-line-num)
  and not (p-gline-recalc-line-num = v-line-num
          and
          v-line-num = p-line-num)
  then do:
    p-doc-recalc-gline-num = v-line-num.
  end.
  if p-gline-recalc-line-num = 0
  or p-gline-recalc-line-num > v-line-num then do:
    p-gline-recalc-line-num = v-line-num.
  end.

  delete object v-chk-gds-bh.
  p-not-found = not p-intended.
  return v-discnt * p-cli-base-rate.
end.
p-not-found = yes.
return 0.
end function.


FUNCTION dis-rule_rf_00008 returns decimal ( input p-rule-num as integer
                                          , input p-date as date
                                          , input p-time as integer
                                          , input p-price-netto as decimal
                                          , input p-dis-kat as integer
                                          , output p-discnt-pcnt as decimal
                                          , output p-value-type as integer
                                          , output p-not-found as logical
                                          ):
/*@% скидка по строке товара для катег. клиентов(POS IBM IBM-XML)*/
define variable v-price as decimal no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
p-value-type = integer({&discnt-v-pcnt}).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num
  and buf_term-dis-rule.dis-kat = p-dis-kat :
    p-discnt-pcnt = buf_term-dis-rule.discnt-value.
    return p-price-netto * buf_term-dis-rule.discnt-value / 100.
  end. /*for each buf_term-dis-rule no-lock where*/
end.
p-not-found = yes.
return 0.0.
end function.


FUNCTION dis-rule_rf_00009 returns decimal ( input p-rule-num as integer
                                          , input p-date as date
                                          , input p-time as integer
                                          , input p-price-netto as decimal
                                          , input p-qnty as decimal
                                          , input p-cli-base-rate as decimal
                                          , input p-dis-kat as integer
                                          , output p-discnt-sum as decimal
                                          , output p-value-type as integer
                                          , output p-not-found as logical
                                          ):
/*@abs скидка по строке товара для катег. клиентов(POS IBM IBM-XML)*/
define variable v-price as decimal no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
p-value-type = integer({&discnt-v-abs}).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num
       and buf_term-dis-rule.dis-kat = p-dis-kat:
    /*защита от ухода в 0*/
    if p-price-netto - buf_term-dis-rule.discnt-value * p-cli-base-rate <= 0 then do:
      p-discnt-sum = 0.
      p-not-found = yes.
      return 0.
    end.
    p-discnt-sum = buf_term-dis-rule.discnt-value * p-qnty * p-cli-base-rate.
    return buf_term-dis-rule.discnt-value * p-cli-base-rate .
  end. /*for each buf_term-dis-rule no-lock where*/
end.
p-not-found = yes.
return 0.0.
end function.


/*@% скидка на итог*/
FUNCTION dis-rule_rf_00020 returns decimal ( input p-rule-num as integer
                                          , input p-date as date
                                          , input p-time as integer
                                          , input p-sum-for-discnt as decimal
                                          , output p-discnt-pcnt as decimal
                                          , output p-value-type as integer
                                          , output p-not-found as logical
                                          ):
define variable v-discnt as decimal no-undo .
define variable v-start as logical no-undo init yes.
define variable v-delta as decimal no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
p-value-type = integer({&discnt-v-pcnt}).
p-not-found = yes.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.tot-sum <= p-sum-for-discnt then do:
      if v-start
      or v-delta  > (p-sum-for-discnt - buf_term-dis-rule.tot-sum)
      then do:
        assign
        p-discnt-pcnt = buf_term-dis-rule.discnt-value
        v-start = no
        v-delta = p-sum-for-discnt - buf_term-dis-rule.tot-sum
        v-discnt = p-sum-for-discnt * buf_term-dis-rule.discnt-value / 100
        p-not-found = no
        .
      end.
    end.
  end.
  return v-discnt.
end.
return 0.0.
end function.


FUNCTION dis-rule_rf_00028 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price-netto as decimal
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        , output p-not-found as logical
                                        ):
/*@% временная скидка на строку товара*/
/*возвращает КУСОК скидки в r-b на ед измерения*/
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
p-value-type = integer({&discnt-v-pcnt}).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if {&term-time-ok} then do:
      p-discnt-pcnt = buf_term-dis-rule.discnt-value.
      return p-price-netto * buf_term-dis-rule.discnt-value / 100.
    end.
  end.
end.
p-not-found = yes.
return 0.
end function.

/*% скидка на группу товара*/
FUNCTION dis-rule_rf_00036 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price-netto as decimal
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        , output p-not-found as logical
                                        ) map to dis-rule_rf_00001 in this-procedure.

/*% скидка на сумму платежа*/
FUNCTION dis-rule_rf_00042 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-payment-sum as decimal
                                        , input p-exch-rate as decimal
                                        , input p-exch-scale as integer
                                        , input p-to-pay-r-b as decimal
                                        , input p-base-rate as decimal
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        , input-output p-object-sum as decimal
                                        , output p-not-found as logical
                                        ):
/*возвращает сумму скидки в r-b */
define buffer buf_dis-rule for ub.dis-rule.
p-value-type = integer({&discnt-v-pcnt}).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok} then do:
  p-discnt-pcnt = buf_dis-rule.discnt-value.
  if p-to-pay-r-b < (p-payment-sum / p-exch-rate * p-exch-scale) / p-base-rate then do:
    p-object-sum = p-to-pay-r-b.
  end.
  return minimum (p-to-pay-r-b, p-payment-sum / p-exch-rate * p-exch-scale / p-base-rate ) * buf_dis-rule.discnt-value / 100 .
end.
p-not-found = yes.
return 0.
end function.

/*% скидка на сумму платежа - инвертированная*/
FUNCTION dis-rule_rf_00042i returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-payment-sum as decimal
                                        , input p-exch-rate as decimal
                                        , input p-exch-scale as integer
                                        , input p-to-pay-r-b as decimal
                                        , input p-base-rate as decimal
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        , input-output p-object-sum as decimal
                                        , output p-not-found  as logical
                                        ) :
/*возвращает сумму скидки в r-b */
define buffer buf_dis-rule for ub.dis-rule.
p-value-type = integer({&discnt-v-pcnt}).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok} then do:
  p-discnt-pcnt = buf_dis-rule.discnt-value.
  if p-to-pay-r-b < (p-payment-sum / p-exch-rate * p-exch-scale) / p-base-rate then do:
    p-object-sum = p-to-pay-r-b.
  end.
  return minimum (p-to-pay-r-b, (p-payment-sum  * 100 / (100 - buf_dis-rule.discnt-value))/ p-exch-rate * p-exch-scale / p-base-rate) * buf_dis-rule.discnt-value / 100 .
end.
p-not-found = yes.
return 0.
end function.


/*% скидка по колву товара группы*/
FUNCTION dis-rule_rf_00048 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price as decimal
                                        , input p-doc-qnty as decimal
                                        , input p-discnt-role as character
                                        , input p-sum-grp-code as integer
                                        , input p-line-num as integer
                                        , input p-chk-gds-table as handle
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        , output p-intended as logical
                                        , input-output p-doc-recalc-gline-num as integer
                                        , input-output p-gline-recalc-line-num as integer
                                        , output p-not-found as logical
                                        ):
define variable v-delta as decimal no-undo .
define variable v-start as logical no-undo init yes.
define variable v-discnt as decimal no-undo .
define variable v-qnty as decimal no-undo .
define variable glog as logical no-undo .
define variable v-chk-gds-bh as handle no-undo .
define variable v-line-num as integer no-undo init -1.
define variable v-current-line as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.

p-value-type = integer({&discnt-v-pcnt}).
v-qnty = p-doc-qnty .
p-intended = yes.
create buffer v-chk-gds-bh for table p-chk-gds-table:default-buffer-handle.
do while true:
 assign
 glog = v-chk-gds-bh:find-first( substitute("where sum-grp-code = &1 and line-num > &2"
                                     , p-sum-grp-code
                                     , v-current-line
                                     )) no-error.
 if not glog
 or error-status:error
 or v-chk-gds-bh:available = no
 then leave.
 assign
  v-current-line = v-chk-gds-bh:buffer-field("line-num"):buffer-value
  v-line-num = (if v-line-num > v-current-line
                or v-line-num = -1
                then v-current-line
                else v-line-num)
 .

 if v-chk-gds-bh:buffer-field("line-num"):buffer-value = p-line-num then do:
 end.
 else do:
  assign
  v-qnty = v-qnty + v-chk-gds-bh:buffer-field("will-doc-qnty"):buffer-value
  .
 end.
end.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.doc-qnty <= v-qnty then do:
      if v-start
      or v-delta  > (v-qnty - buf_term-dis-rule.doc-qnty)
      then do:
        assign
        p-discnt-pcnt= buf_term-dis-rule.discnt-value
        v-start = no
        v-delta = v-qnty - buf_term-dis-rule.doc-qnty
        v-discnt = p-price * buf_term-dis-rule.discnt-value / 100
        p-intended = no
        .
      end.
    end.
  end.
  if (v-line-num < p-line-num
  or p-doc-recalc-gline-num = 0
  or p-doc-recalc-gline-num > v-line-num)
  and not (p-gline-recalc-line-num = v-line-num
          and
          v-line-num = p-line-num)
  then do:
    p-doc-recalc-gline-num = v-line-num.
  end.
  if p-gline-recalc-line-num = 0
  or p-gline-recalc-line-num > v-line-num then do:
    p-gline-recalc-line-num = v-line-num.
  end.
  delete object v-chk-gds-bh.
  p-not-found = not p-intended.
  return v-discnt.
end.
p-not-found = yes.
return 0.0.
end function.



/*% скидка по сумму товара группы*/
FUNCTION dis-rule_rf_00049 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price as decimal
                                        , input p-qnty as decimal
                                        , input p-discnt-role as character
                                        , input p-sum-grp-code as integer
                                        , input p-line-num as integer
                                        , input p-chk-gds-table as handle
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        , output p-intended as logical
                                        , input-output p-doc-recalc-gline-num as integer
                                        , input-output p-gline-recalc-line-num as integer
                                        , output p-not-found as logical
                                        ):
define variable v-delta as decimal no-undo .
define variable v-start as logical no-undo init yes.
define variable v-discnt as decimal no-undo .
define variable v-sum as decimal no-undo .
define variable glog as logical no-undo .
define variable v-chk-gds-bh as handle no-undo .
define variable v-line-num as integer no-undo init -1.
define variable v-current-line as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.

p-value-type = integer({&discnt-v-pcnt}).
v-sum = p-qnty * p-price.
p-intended = yes.
create buffer v-chk-gds-bh for table p-chk-gds-table:default-buffer-handle.
do while true:
 assign
 glog = v-chk-gds-bh:find-first( substitute("where sum-grp-code = &1 and line-num > &2"
                                     , p-sum-grp-code
                                     , v-current-line
                                     )) no-error.
 if not glog
 or error-status:error
 or v-chk-gds-bh:available = no
 then leave.
 assign
  v-current-line = v-chk-gds-bh:buffer-field("line-num"):buffer-value
  v-line-num = (if v-line-num > v-current-line
                or v-line-num = -1
                then v-current-line
                else v-line-num)
 .

 if v-chk-gds-bh:buffer-field("line-num"):buffer-value = p-line-num then do:
 end.
 else do:
  assign
  v-sum = v-sum + v-chk-gds-bh:buffer-field("src-qnty"):buffer-value * v-chk-gds-bh:buffer-field("start-src-price"):buffer-value
  .
 end.
end.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.tot-sum <= v-sum then do:
      if v-start
      or v-delta  > (v-sum - buf_term-dis-rule.tot-sum)
      then do:
        assign
        p-discnt-pcnt= buf_term-dis-rule.discnt-value
        v-start = no
        v-delta = v-sum - buf_term-dis-rule.tot-sum
        v-discnt = p-price * buf_term-dis-rule.discnt-value / 100
        p-intended = no
        .
      end.
    end.
  end.
  if (v-line-num < p-line-num
  or p-doc-recalc-gline-num = 0
  or p-doc-recalc-gline-num > v-line-num)
  and not (p-gline-recalc-line-num = v-line-num
          and
          v-line-num = p-line-num)
  then do:
    p-doc-recalc-gline-num = v-line-num.
  end.
  if p-gline-recalc-line-num = 0
  or p-gline-recalc-line-num > v-line-num then do:
    p-gline-recalc-line-num = v-line-num.
  end.
  delete object v-chk-gds-bh.
  p-not-found = not p-intended.
  return v-discnt.
end.
p-not-found = yes.
return 0.0.
end function.


/*@% категорийная скидка на итог*/
FUNCTION dis-rule_rf_00054 returns decimal ( input p-rule-num as integer
                                          , input p-date as date
                                          , input p-time as integer
                                          , input p-sum-for-discnt as decimal
                                          , input p-dis-kat as integer
                                          , output p-discnt-pcnt as decimal
                                          , output p-value-type as integer
                                          , output p-not-found as logical
                                          ):

define variable v-price as decimal no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
p-value-type = integer({&discnt-v-pcnt}).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and buf_dis-rule.dis-kat = p-dis-kat
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num  :
    p-discnt-pcnt = buf_term-dis-rule.discnt-value.
    return p-sum-for-discnt * buf_term-dis-rule.discnt-value / 100.
  end. /*for each buf_term-dis-rule no-lock where*/
end.
p-not-found = yes.
return 0.0.
end function.



/*запрет на участие в скидке на итог*/
FUNCTION dis-rule_rf_00055 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-qnty as decimal
                                        , input p-price-netto as decimal
                                        , input-output p-without-subtotal-discnt as integer
                                        , input-output p-sum-for-discnt as decimal
                                        , output p-value-type as integer
                                        , output p-not-found as logical
                                        ):
define buffer buf_dis-rule for ub.dis-rule.
p-value-type = integer({&discnt-v-abs}).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok} then do:
  p-without-subtotal-discnt = 1.
  p-sum-for-discnt = p-sum-for-discnt - (p-qnty  * p-price-netto).
  return - (p-qnty  * p-price-netto).
end.
p-not-found = yes.
p-without-subtotal-discnt = 0.
return 0.0.
/*удельную скидку не изменяет*/
end function.



/*запрет на участие в товарной скидке*/
FUNCTION dis-rule_rf_00056 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input-output p-without-gds-discnt as integer
                                        , output p-value-type as integer
                                        , output p-not-found as logical
                                        ):
define buffer buf_dis-rule for ub.dis-rule.
p-value-type = integer({&discnt-v-abs}).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok} then do:
  p-without-gds-discnt = 1.
  return 0.0.
end.
p-not-found = yes.
p-without-gds-discnt = 0.
return 0.0.
/*удельную скидку не изменяет*/
end function.



/*смешанная категорийная скидка*/
FUNCTION dis-rule_rf_00076 returns decimal ( input p-rule-num as integer
                                          , input p-date as date
                                          , input p-time as integer
                                          , input p-price-netto as decimal
                                          , input p-qnty as decimal
                                          , input p-cli-base-rate as decimal
                                          , input p-dis-kat as integer
                                          , input-output p-price as decimal
                                          , output p-discnt-pcnt as decimal
                                          , output p-discnt-sum as decimal
                                          , output p-value-type as integer
                                          , output p-not-found as logical
                                          ):
/*@смешанная скидка по строке товара для катег. клиентов(POS IBM IBM-XML)*/
define variable v-price as decimal no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
p-value-type = integer({&discnt-v-abs}).
v-price = p-price.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num
  and buf_term-dis-rule.dis-kat = p-dis-kat :
    case buf_term-dis-rule.value-type:
      when integer({&discnt-v-pcnt}) then do:
        p-value-type = integer({&discnt-v-pcnt}).
        p-discnt-pcnt = buf_term-dis-rule.discnt-value.
        return p-price-netto * buf_term-dis-rule.discnt-value / 100.
      end.
      when integer({&discnt-v-abs}) then do:
        p-value-type = integer({&discnt-v-abs}).
        /*защита от ухода в 0*/
        if p-price-netto - buf_term-dis-rule.discnt-value * p-cli-base-rate <= 0 then do:
          p-discnt-sum = 0.
          return 0.
        end.
        p-discnt-sum = buf_term-dis-rule.discnt-value * p-qnty * p-cli-base-rate.
        return buf_term-dis-rule.discnt-value * p-cli-base-rate.
      end.
      when integer({&discnt-v-fp}) then do:
        p-value-type = integer({&discnt-v-fp}).
        /*защита от ухода в 0*/
        if buf_term-dis-rule.discnt-value <= 0 then do:
          p-discnt-sum  = 0.
          return 0.
        end.
        p-price = buf_term-dis-rule.discnt-value * p-cli-base-rate.
        p-discnt-sum = (p-price-netto - v-price) * p-qnty.
        return (p-price-netto - v-price).
      end.
    end case.
  end. /*for each buf_term-dis-rule no-lock where*/
end.
p-not-found = yes.
return 0.0.
end function.


FUNCTION dis-rule_rf_00077 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price-netto as decimal
                                        , input p-d-pcnt as decimal
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        ):
/*@% скидка на строку товара по ДК*/

p-value-type = integer({&discnt-v-pcnt}).
assign
p-discnt-pcnt = p-d-pcnt.
return p-price-netto * p-d-pcnt / 100.
end function.

FUNCTION dis-rule_rf_00078 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-sum-for-discnt as decimal
                                        , input p-cash-d-pcnt as decimal
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        ):
/*@% скидка на итог по ДК*/

p-value-type = integer({&discnt-v-pcnt}).
assign
p-discnt-pcnt = p-cash-d-pcnt.
return p-sum-for-discnt * p-cash-d-pcnt / 100.
end function.


FUNCTION dis-rule_rf_00084 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-obj-code as integer
                                        , input p-price-netto as decimal
                                        , input p-qnty as decimal
                                        , input p-b-code as integer
                                        , input-output p-price as decimal
                                        , output p-discnt-sum as decimal
                                        , output p-value-type as integer
                                        , output p-not-found as logical
                                        ): /* 7 6 */
/*@% временная скидка на строку товара*/
/*возвращает цену на ед измерения*/
define variable v-price as decimal no-undo .
define variable v-pdf-id as integer no-undo .
define variable v-pdf-db-num as integer   no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
v-price = p-price.
p-value-type = integer({&discnt-v-abs}).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if {&term-time-ok} then do:
      /*получим цену из прайслиста*/
      run mpl-tpl-auto in this-procedure ( input p-b-code
                                          ,input {&shop}
                                          ,input p-obj-code
                                          ,input integer(entry(1, buf_term-dis-rule.charkey_one,"-"))
                                          ,input integer(entry(2, buf_term-dis-rule.charkey_one,"-"))
                                          ,input ? /*fact-order*/
                                          ,output v-price
                                          ,output v-pdf-id
                                          ,output v-pdf-db-num
                                          ) no-error.
      if error-status :error then do:
         v-price = p-price-netto.
         p-not-found = yes.
         return 0.
      end.
      if v-pdf-id = 0
      or v-pdf-id = ? then do:
        p-not-found = yes.
      end.
      p-value-type = integer({&discnt-v-pdf-fp}).
      p-discnt-sum = (p-price-netto - v-price) * p-qnty.
      return (p-price-netto - v-price).
    end.
  end.
end.
p-not-found = yes.
return 0.
end function.


FUNCTION dis-rule_rf_00085 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-price-netto as decimal
                                        , input p-nonunique as character
                                        , input p-b-code as integer
                                        , output p-not-found as logical
                                        , output p-discnt-pcnt as decimal
                                        , output p-value-type as integer
                                        ):     /* 2 8 */
/*@% временная скидка на БАР-КОД*/
/*возвращает КУСОК скидки в r-b на ед измерения*/
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
p-value-type = integer({&discnt-v-pcnt}).
if p-nonunique <> string(p-b-code) then do:
  /*это не тот бар-код*/
  p-not-found = yes.
  return 0.
end.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if {&term-time-ok} then do:
      p-discnt-pcnt = buf_term-dis-rule.discnt-value.
      return p-price-netto * buf_term-dis-rule.discnt-value / 100.
    end.
  end.
end.
p-not-found = yes.
return 0.
end function.


FUNCTION dis-rule_rf_00088 returns decimal ( input p-rule-num as integer
                                          , input p-date as date
                                          , input p-time as integer
                                          , input p-obj-code as integer
                                          , input p-price-netto as decimal
                                          , input p-dis-kat as integer
                                          , input p-qnty as decimal /*?*/
                                          , input p-b-code as integer
                                          , input-output p-price as decimal
                                          , output p-discnt-sum as decimal
                                          , output p-value-type as integer
                                          , output p-not-found as logical
                                          ):

/*@ЫФЦ  по строке товара для катег. клиентов через ТПЛ*/
define variable v-price as decimal no-undo .
define variable v-pdf-id as integer no-undo .
define variable v-pdf-db-num as integer   no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
v-price = p-price.
p-value-type = integer({&discnt-v-abs}).
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num
  and buf_term-dis-rule.dis-kat = p-dis-kat :
    /*получим цену из прайслиста*/
    run mpl-tpl-auto in this-procedure ( input p-b-code
                                        ,input {&shop}
                                        ,input p-obj-code
                                        ,input integer(entry(1, buf_term-dis-rule.charkey_one,"-"))
                                        ,input integer(entry(2, buf_term-dis-rule.charkey_one,"-"))
                                        ,input ? /*fact-order*/
                                        ,output v-price
                                        ,output v-pdf-id
                                        ,output v-pdf-db-num
                                        ) no-error.
    if error-status :error then do:
        v-price = p-price-netto.
        p-not-found = yes.
        return 0.
    end.
    if v-pdf-id = 0
    or v-pdf-id = ? then do:
      p-not-found = yes.
    end.
    p-value-type = integer({&discnt-v-pdf-fp}).
    p-discnt-sum = (p-price-netto - v-price) * p-qnty.
    return (p-price-netto - v-price).
  end. /*for each buf_term-dis-rule no-lock where*/
end.
p-not-found = yes.
return 0.0.
end function.



/* &if defined(dis-rule_rf_i) = 0 &then */

/* $Workfile$ e n d */