/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/13/06
Author: Bakhtadze Natalya
Creation date: 12/13/06

*/


&if defined(dis-rule_f_i) = 0 &then

&glob dis-rule_f_i



&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ gbl/distruls.i def }
{ rul/dis-time-rule_f.i }

&scop time-ok  (buf_Dis-rule.time-templ-rl-root <= ~{&dtr-templates-shift~} or ~
dynamic-function( "dis-time-rule_" + string(buf_dis-rule.time-templ-rl-root - ~{&dtr-templates-shift~}, "99999") ~
                                       , input buf_dis-rule.time-rule-num  ~
                                       , input p-date ~
                                       , input p-time ~))

&scop term-time-ok  (buf_term-Dis-rule.time-templ-rl-root <= ~{&dtr-templates-shift~} and ~
dynamic-function( "dis-time-rule_" + string(buf_term-dis-rule.time-templ-rl-root - ~{&dtr-templates-shift~}, "99999" ) ~
                                       , input buf_term-dis-rule.time-rule-num  ~
                                       , input p-date ~
                                       , input p-time ~))

&endif

&if ("{1}" = "1"
or "{1}" = "{&dgr-std-disc}"
or "{1}" = "2"
or "{1}" = "{&dgr-abs-disc}"
or "{1}" = "3"
or "{1}" = "4"
or "{1}" = "11"
or "{1}" = "{&ddcr-debet-pay-pcnt-discnt}"
or "{1}" = "12"
or "{1}" = "{&ddcr-debet-pay-abs-discnt}"
or "{1}" = "13"
or "{1}" = "14"
or "{1}" = "{&ddcr-credit-pay-pcnt-discnt}"
or "{1}" = "15"
or "{1}" = "{&ddcr-credit-pay-abs-discnt}"
or "{1}" = "22"
or "{1}" = "{&dgr-temp-disc}"
or "{1}" = "{&dthbjr-dflt-gds-temp-disc}"
or "{1}" = "23"
or "{1}" = "24"
or "{1}" = "31"
or "{1}" = "{&dthbjr-pcnt-tot-kateg}"
or "{1}" = "32"
or "{1}" = "42"
or "{1}" = "43"
or "{1}" = "46"
or "{1}" = "{&dcpr-simple-pay}"
or "{1}" = "{&dggrr-pcnt}"
or "{1}" = "47"
or "{1}" = "68"
or "{1}" = "{&dgr-max-disc}"
or "{1}" = "69"
or "{1}" = "70"
or "{1}" = "{&ddctr-def-pcnt}"
or "{1}" = "{&ddctr-def-cash-pcnt}"
or "{1}" = "72"
or "{1}" = "{&dclgr-pcnt}"
) and defined(dis-rule_00001) = 0
&then
&glob dis-rule_00001
FUNCTION dis-rule_00001 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer):
/*@% скидка на строку товара (для MARIA-только топливо)*/
define buffer buf_dis-rule for ub.dis-rule.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok} then do:
  return buf_dis-rule.discnt-value.
end.
return 0.0.
end function.
&endif

&if ("{1}" = "{&dgr-abs-disc}"
or  "{1}" = "2")
&then
/*@abs скидка на строку товара (MARIA)*/
FUNCTION dis-rule_00002 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer) map to dis-rule_00001 in this-procedure .
&endif

&if "{1}" = "3" &then
/*@фикс сниж цена на товар*/
FUNCTION dis-rule_00003 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer) map to dis-rule_00001 in this-procedure .
&endif

&if "{1}" = "4" &then
/*@%скидка для персонала*/
FUNCTION dis-rule_00004 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer) map to dis-rule_00001 in this-procedure .
&endif

&if ("{1}" = "5"
or "{1}" = "{&dgr-pcnt-qnty}"
or "{1}" = "6"
or "{1}" = "7"
or "{1}" = "{&ddcr-credit-pay-qnty-discnt}"
or "{1}" = "16"
or "{1}" = "25"
or "{1}" = "38"
or "{1}" = "40"
or "{1}" = "{&ddcr-debet-pay-qnty-discnt}"
or "{1}" = "44"
or "{1}" = "{&dcpr-simple-pay}"
or "{1}" = "48")
and defined(dis-rule_00005) = 0
&then
&glob dis-rule_00005
FUNCTION dis-rule_00005 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-doc-qnty as decimal):
/*% скидка на кол-во по строке товара (POS IBM IBM-XML)*/
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
define variable v-delta as decimal no-undo .
define variable v-start as logical no-undo init yes.
define variable v-discnt-value as decimal no-undo .
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.doc-qnty <= p-doc-qnty then do:
      if v-start
      or v-delta  > (p-doc-qnty - buf_term-dis-rule.doc-qnty)
      then do:
        assign
        v-discnt-value = buf_term-dis-rule.discnt-value
        v-start = no
        v-delta = p-doc-qnty - buf_term-dis-rule.doc-qnty
        .
      end.
    end.
  end.
  return v-discnt-value.
end.
return 0.0.
end function.
&endif

&if "{1}" = "6" &then
/*@абс. скидка на кол-во по строке товара*/
FUNCTION dis-rule_00006 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-doc-qnty as decimal) map to dis-rule_00005 in this-procedure .
&endif

&if "{1}" = "7" &then
/*@фиксированная (сниж.) цена на кол-во по строке товара*/
FUNCTION dis-rule_00007 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-doc-qnty as decimal) map to dis-rule_00005 in this-procedure.
&Endif

&if ("{1}" = "8"
or "{1}" = "{&dgr-pcnt-kat}"
or "{1}" = "9"
or "{1}" = "10"
or "{1}" = "33"
or "{1}" = "53"
or "{1}" = "{&dthbjr-pcnt-tot-kateg}"
or "{1}" = "54")
and defined(dis-rule_00008) = 0
&then
&glob dis-rule_00008
FUNCTION dis-rule_00008 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-dis-kat as integer):
/*@% скидка по строке товара для катег. клиентов(POS IBM IBM-XML)*/
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.dis-kat = p-dis-kat then do:
      return buf_term-dis-rule.discnt-value.
    end.
  end.
end.
return 0.0.
end function.
&Endif

&if ("{1}" = "9"
or  "{1}" = "{&dgr-pcnt-kat}")
&then
/*@абс. скидка по строке товара для катег. клиентов*/
FUNCTION dis-rule_00009 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-dis-kat as integer) map to dis-rule_00008 in this-procedure .
&endif


&if "{1}" = "10" &then
/*@фиксированная (сниж.) цена по строке товара для катег. клиентов*/
FUNCTION dis-rule_00010 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-dis-kat as integer) map to dis-rule_00008 in this-procedure .
&endif

&if ("{1}" = "11" or
"{1}" = "{&ddcr-debet-pay-pcnt-discnt}")
&then
/*@% скидка по строке товара для пост. клиента*/
FUNCTION dis-rule_00011 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer   ) map to dis-rule_00001 in this-procedure .
&endif

&if ("{1}" = "12" or
"{1}" = "{&ddcr-debet-pay-abs-discnt}")
&then
/*@абс. скидка по строке товара для пост. клиента*/
FUNCTION dis-rule_00012 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer   ) map to dis-rule_00001 in this-procedure .
&endif

&if "{1}" = "13" &then
/*@фиксированная (сниж.) цена по строке товара для пост. клиента*/
FUNCTION dis-rule_00013 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer   ) map to dis-rule_00001 in this-procedure .
&endif

&if ("{1}" = "14"
or "{1}" = "{&ddcr-credit-pay-pcnt-discnt}")
&then
/*@% скидка по строке товара для пост. клиента*/
FUNCTION dis-rule_00014 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer   ) map to dis-rule_00001 in this-procedure .
&endif

&if ("{1}" = "15"
or "{1}" = "{&ddcr-credit-pay-abs-discnt}")
&then
/*@абс. скидка по строке товара для пост. клиента*/
FUNCTION dis-rule_00015 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer   ) map to dis-rule_00001 in this-procedure .
&endif

&if ("{1}" = "16"
or "{1}" = "{&ddcr-credit-pay-qnty-discnt}")
&then
/*@% скидка на кол-во на топливо (отпуск по ведомости) (MARIA)*/
FUNCTION dis-rule_00016 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-doc-qnty as decimal) map to dis-rule_00005 in this-procedure .
&endif


&if ("{1}" = "17"
or "{1}" = "18"
or "{1}" = "19"
or "{1}" = "27"
or "{1}" = "{&dgr-pcnt-date}"
or "{1}" = "28"
or "{1}" = "{&dgr-temp-disc}"
or "{1}" = "{&dthbjr-dflt-gds-temp-disc}"
or "{1}" = "29")
and defined(dis-rule_00017) = 0
&then
&glob dis-rule_00017
FUNCTION dis-rule_00017 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        ):
/*@сезонная % скидка по строке товара*/
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num
  and {&term-time-ok}:
    return buf_term-dis-rule.discnt-value.
  end.
end.
return 0.0.
end function.
&endif

&if "{1}" = "18" &then
/*@сезонная абс. скидка по строке товара*/
FUNCTION dis-rule_00018 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer   ) map to dis-rule_00017 in this-procedure .
&endif

&if "{1}" = "19" &then
/*@сезонная фиксированная (сниж.) цена по строке товара*/
FUNCTION dis-rule_00019 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer   ) map to dis-rule_00017 in this-procedure .
&endif


&if ("{1}" = "20"
or "{1}" = "{&dthbjr-pcnt-tot-kateg}"
or "{1}" = "21"
or "{1}" = "30"
or "{1}" = "{&ddcr-credit-pay-sum-discnt}"
or "{1}" = "35"
or "{1}" = "39"
or "{1}" = "{&dgr-pcnt-tot}"
or "{1}" = "41"
or "{1}" = "45"
or "{1}" = "49"
or "{1}" = "51"
or "{1}" = "52"
or "{1}" = "57"
or  "{1}" = "58"
or  "{1}" = "60"
or  "{1}" = "61")
and defined(dis-rule_00020) = 0
&then
&glob dis-rule_00020
FUNCTION dis-rule_00020 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal
                                        ):
/*@% скидка на итог чека для всех покупателей(POS IBM, IBM-XML, NCR-AS@R)"*/
define variable v-delta as decimal no-undo .
define variable v-start as logical no-undo init yes.
define variable v-discnt-value as decimal no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.tot-sum <= p-tot-sum then do:
      if v-start
      or v-delta  > (p-tot-sum - buf_term-dis-rule.tot-sum)
      then do:
        assign
        v-discnt-value = buf_term-dis-rule.discnt-value
        v-start = no
        v-delta = p-tot-sum - buf_term-dis-rule.tot-sum
        .
      end.
    end.
  end.
  return v-discnt-value.
end.
return 0.0.
end function.
&endif

&if "{1}" = "21" &then
/*@абс скидка на итог чека для всех покупателей"*/
FUNCTION dis-rule_00021 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal ) map to dis-rule_00020 in this-procedure .
&endif

&if "{1}" = "22" &then
/*@временная по расписанию % скидка по строке товара (POS IBM)*/
FUNCTION dis-rule_00022 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer) map to dis-rule_00001 in this-procedure .
&endif

&if "{1}" = "23" &then
/*@временная по расписанию абс скидка по строке товара */
FUNCTION dis-rule_00023 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer) map to dis-rule_00001 in this-procedure .
&endif

&if "{1}" = "24" &then
/*@временная по расписанию фиксированная (сниж.) цена по строке товара"*/
FUNCTION dis-rule_00024 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer) map to dis-rule_00001 in this-procedure .
&endif

&if "{1}" = "25" &then
/*@% скидка на кол-во по строке товара (POS NCR-GM и AS@R)*/
FUNCTION dis-rule_00025 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-doc-qnty as decimal) map to dis-rule_00005 in this-procedure .
&endif



&if "{1}" = "26" &then
/*@Соответствие % скидки коду скидки (POS NCR-GM и AS@R)*/
FUNCTION dis-rule_00026 returns integer ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-discnt-value as decimal):
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.discnt-value = p-discnt-value then do:
      return buf_term-dis-rule.dis-kat.
    end.
  end.
end.
return 0.
end function.
&endif

&if "{1}" = "27" &then
/*@% скидка по дате по строке товара (POS NCR-GM и AS@R)*/
FUNCTION dis-rule_00027 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer )  map to dis-rule_00017 in this-procedure .
&endif

&if "{1}" = "28" &then
/*@временная по расписанию % скидка по строке товара (POS IBM-XML)*/
FUNCTION dis-rule_00028 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer )  map to dis-rule_00017 in this-procedure .
&endif

&if "{1}" = "29" &then
/*@временная по расписанию % скидка по строке товара (NCR-GM, NCR-AS@R)*/
FUNCTION dis-rule_00029 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer )  map to dis-rule_00017 in this-procedure .
&endif

&if "{1}" = "30" &then
/*@% скидка на сумму на топливо (отпуск поведомости) (MARIA)"*/
FUNCTION dis-rule_00030 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal )  map to dis-rule_00020 in this-procedure .
&endif

&if "{1}" = "31" &then
/*@временная по расписанию % скидка на итог чека (POS R-KEEPER)"*/
FUNCTION dis-rule_00031 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer )  map to dis-rule_00001 in this-procedure .
&endif

&if "{1}" = "32" &then
/*@временная по расписанию % скидка по строке товара (POS R-KEEPER)*/
FUNCTION dis-rule_00032 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer )  map to dis-rule_00001 in this-procedure .
&endif

&if "{1}" = "33" &then
/*@% скидка по строке товара для катег. клиентов(POS NCR-AS@R)*/
FUNCTION dis-rule_00033 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-dis-kat as integer) map to dis-rule_00008 in this-procedure .
&endif

&if "{1}" = "34" &then
/*@% предел скидки и поправ коэфф. по строке товара для катег. клиентов(POS IBM IBM-XML)"*/
FUNCTION dis-rule_00034 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-dis-kat as integer
                                        , input p-d-pcnt as decimal
                                        , input p-d-pcnt-limit as decimal
                                        ):
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.dis-kat = p-dis-kat then do:
      if buf_term-dis-rule.discnt-value = 0 then do:
        if p-d-pcnt = p-d-pcnt-limit then do:
          return p-d-pcnt / buf_term-dis-rule.tot-sum.
        end.
        else do:
          return p-d-pcnt-limit.
        end.
      end.
      else do:
        return minimum ( buf_term-dis-rule.discnt-value , p-d-pcnt).
      end.
    end.
  end.
end.
return p-d-pcnt.
end function.
&endif

&if "{1}" = "35" &then
/*% скидка на итог чека по отдельной категории покупателей(POS NCR-AS@R)*/
FUNCTION dis-rule_00035 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal ) map to dis-rule_00020 in this-procedure .
&endif

&if "{1}" = "36"
or "{1}" = "37"
and defined(dis-rule_00036) = 0
&then
&glob dis-rule_00036
/*@% скидка на группу товаров (POS NCR-AS@R)*/
FUNCTION dis-rule_00036 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-grp-code as integer ) :
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.key#_one = p-grp-code
    and {&term-time-ok}
    then do:
      return buf_term-dis-rule.discnt-value.
    end.
  end.
end.
return 0.0.
end function.
&endif

&if "{1}" = "37" &then
/*@% скидка на группу товаров для катег. клиентов(POS NCR-AS@R)*/
FUNCTION dis-rule_00037 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-grp-code as integer ) map to dis-rule_00036 in this-procedure .
&endif

&if "{1}" = "38" &then
/*@% скидка на кол-во на топливо (MARIA)*/
FUNCTION dis-rule_00038 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-doc-qnty as decimal) map to dis-rule_00005 in this-procedure .
&endif

&if "{1}" = "39" &then
/*@% скидка на сумму на топливо для всех покупателей (MARIA)*/
FUNCTION dis-rule_00039 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal )  map to dis-rule_00020 in this-procedure .
&endif

&if "{1}" = "40" &then
/*@% скидка на кол-во на топливо (отпуск по ведомости) (MARIA)*/
FUNCTION dis-rule_00040 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-doc-qnty as decimal) map to dis-rule_00005 in this-procedure .
&endif

&if "{1}" = "41" &then
/*@% скидка на сумму на топливо (отпуск поведомости) (MARIA)"*/
FUNCTION dis-rule_00041 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal )  map to dis-rule_00020 in this-procedure .
&endif

&if "{1}" = "42" &then
/*@% скидка на тип кассового платежа при оплате отплива (MARIA)*/
FUNCTION dis-rule_00042 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer) map to dis-rule_00001 in this-procedure .
&endif

&if "{1}" = "43" &then
/*@абс. скидка на тип кассового платежа при оплате отплива (MARIA)*/
FUNCTION dis-rule_00043 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer) map to dis-rule_00001 in this-procedure .
&endif

&if "{1}" = "44" &then
/*@% скидка на кол-во на тип кассового платежа при оплате отплива (MARIA)*/
FUNCTION dis-rule_00044 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-doc-qnty as decimal) map to dis-rule_00005 in this-procedure .
&endif

&if "{1}" = "45" &then
/*@% скидка на сумму на тип кассового платежа при оплате отплива (MARIA)*/
FUNCTION dis-rule_00045 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal )  map to dis-rule_00020 in this-procedure .
&endif

&if "{1}" = "46" &then
/*@% скидка по группе товаров (MARIA)*/
FUNCTION dis-rule_00046 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer) map to dis-rule_00001 in this-procedure .
&endif

&if "{1}" = "47" &then
/*@абс. скидка по группе товаров (MARIA)*/
FUNCTION dis-rule_00047 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer) map to dis-rule_00001 in this-procedure .
&endif

&if "{1}" = "48" &then
/*@% скидка на кол-во по группе товара (MARIA)*/
FUNCTION dis-rule_00048 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-doc-qnty as decimal) map to dis-rule_00005 in this-procedure .
&endif

&if "{1}" = "49" &then
/*@% скидка на сумму по группе товара (MARIA)*/
FUNCTION dis-rule_00049 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal )  map to dis-rule_00020 in this-procedure .
&endif

&if "{1}" = "50" &then
/*@Свободный ввод скидки (MARIA)*/
FUNCTION dis-rule_00050 returns integer ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal )  :
  return 1.
end.
&endif

&if "{1}" = "51" &then
/*@% скидка на итог чека для всех покупателей(MARIA)*/
FUNCTION dis-rule_00051 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal )  map to dis-rule_00020 in this-procedure .
&endif

&if "{1}" = "52" &then
/*@Условия установки скидок на топливо в разрезе платежа (MARIA)*/
FUNCTION dis-rule_00052 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal )  map to dis-rule_00020 in this-procedure .
&endif

&if "{1}" = "53" &then
/*@% скидка на итог чека для обычных и катег. покупателей(POS IBM)*/
FUNCTION dis-rule_00053 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-dis-kat as integer) map to dis-rule_00008 in this-procedure .
&endif

&if "{1}" = "54" &then
/*@% скидка на итог чека для катег. клиентов(POS IBM-XML)*/
FUNCTION dis-rule_00054 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-dis-kat as integer) map to dis-rule_00008 in this-procedure .
&endif

&if "{1}" = "55" &then
/*@Запрет на участие в скидке на итог (POS NCR-GM, NCR-AS@R, IBM-XML)*/
FUNCTION dis-rule_00055 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        ):
define buffer buf_dis-rule for ub.dis-rule.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok} then do:
  return 0.0.
end.
return 0.0.
end function.
&endif

&if "{1}" = "56" &then
/*@Запрет на скидку для товара (POS IBM-XML)*/
FUNCTION dis-rule_00056 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        ):
define buffer buf_dis-rule for ub.dis-rule.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok} then do:
  return 0.0.
end.
return 0.0.
end function.
&endif

&if ("{1}" = "57"
or "{1}" = "{&ddctr-calc-d-pcnt}"
)
&then
/*@% скидка по ДК на товар - простой накопительный алгоритм*/
FUNCTION dis-rule_00057 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal ) map to dis-rule_00020 in this-procedure .
&endif

&if ("{1}" = "58"
or "{1}" = "{&ddctr-calc-cash-d-pcnt}"
)
&then
/*@% скидка по ДК на итог - простой накопительный алгоритм*/
FUNCTION dis-rule_00058 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal ) map to dis-rule_00020 in this-procedure .
&endif

&if ("{1}" = "59"
or "{1}" = "62"
or "{1}" = "{&ddctr-calc-categ}"
)
and defined(dis-rule_00059) = 0
&then
&glob dis-rule_00059
/*@Категория ДК - простой накопительный алгоритм*/
FUNCTION dis-rule_00059 returns integer ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal ):
define variable v-delta as decimal no-undo .
define variable v-start as logical no-undo init yes.
define variable v-dis-kat-value as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
    if buf_term-dis-rule.tot-sum <= p-tot-sum then do:
      if v-start
      or v-delta  > (p-tot-sum - buf_term-dis-rule.tot-sum)
      then do:
        assign
        v-dis-kat-value = buf_term-dis-rule.dis-kat
        v-start = no
        v-delta = p-tot-sum - buf_term-dis-rule.tot-sum
        .
      end.
    end.
  end.
  return v-dis-kat-value.
end.
return 0.
end function.
&endif

&if ("{1}" = "60"
or "{1}" = "{&ddctr-calc-d-pcnt}")
&then
/*@% скидка по ДК на товар- интервальный алг-тм с обнулением итогов и пересчетом по предыдущему периоду*/
FUNCTION dis-rule_00060 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal ) map to dis-rule_00020 in this-procedure .
&endif

&if ("{1}" = "61"
or "{1}" = "{&ddctr-calc-cash-d-pcnt}"
)
&then
/*@% скидка по ДК на итог - интервальный алг-тм с обнулением итогов и пересчетом по предыдущему периоду*/
FUNCTION dis-rule_00061 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal ) map to dis-rule_00020 in this-procedure .
&endif

&if ("{1}" = "62"
or "{1}" = "{&ddctr-calc-categ}"
)
&then
/*@Категория ДК  интервальный алг-тм с обнулением итогов и пересчетом по предыдущему периоду*/
FUNCTION dis-rule_00062 returns integer ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal ) map to dis-rule_00059 in this-procedure .
&endif

&if ("{1}" = "63"
or "{1}" = "64"
or "{1}" = "{&ddctr-calc-d-pcnt}"
)
and defined(dis-rule_00063) = 0
&then
&glob dis-rule_00063
/*@% скидка по ДК на товар - интервальный алг-тм с обнул. итогов пересч-м по пред. пер-ду и снижением по 1 ступени*/
FUNCTION dis-rule_00063 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal
                                        , input p-prev-rule-num as integer
                                        , input p-prev-tot-sum as decimal
                                        ) :
define variable v-delta as decimal no-undo .
define variable v-start as logical no-undo init yes.
define variable v-discnt-value as decimal no-undo .
define variable v-step as integer no-undo extent 2.
define variable v-sum-step as decimal no-undo extent 2.
define variable v-string as character no-undo  extent 2.
define variable v-discnt-string as character no-undo  extent 2.
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-rule-num as integer no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-found as logical no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
do v-jj = 1 to 2:
  v-start = yes.
  if v-jj = 1 then do:
    v-rule-num  = p-rule-num.
    v-tot-sum = p-tot-sum.
  end.
  if v-jj = 2 then do:
     v-rule-num = p-prev-rule-num.
     v-tot-sum = p-prev-tot-sum.
  end.
  find first buf_dis-rule no-lock where
          buf_dis-rule.rule-num = v-rule-num no-error.
  if available buf_dis-rule
  and (v-jj = 2 or (buf_dis-rule.sts = integer({&current-status-int})
                and {&time-ok}))
  then do:
    for each buf_term-dis-rule no-lock where
            buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
      v-found = no.
      _v-ii:
      do v-ii = 1 to num-entries(v-string[v-jj], "|":U):
         if buf_term-dis-rule.tot-sum <= decimal(entry(v-ii, v-string[v-jj], "|":U)) then do:
           entry(v-ii, v-string[v-jj], "|":U) = string(buf_term-dis-rule.tot-sum) + "|" +  entry(v-ii, v-string[v-jj], "|":U) .
           entry(v-ii, v-discnt-string[v-jj], "|":U) =  string(buf_term-dis-rule.discnt-value) + "|" +  entry(v-ii, v-discnt-string[v-jj], "|":U) .
           v-found = yes.
           leave _v-ii.
         end.
      end.
      if not v-found then do:
        assign
        v-string[v-jj] = v-string[v-jj]  + (if v-string[v-jj] = '' then '' else "|") +  string(buf_term-dis-rule.tot-sum)
        v-discnt-string[v-jj] = v-discnt-string[v-jj]  + (if v-discnt-string[v-jj] = '' then '' else "|") +  string(buf_term-dis-rule.discnt-value)
        .
      end.
      if buf_term-dis-rule.tot-sum <= p-tot-sum then do:
        if v-start
        or v-delta  > (p-tot-sum - buf_term-dis-rule.tot-sum)
        then do:
          assign
          v-start = no
          v-delta = p-tot-sum - buf_term-dis-rule.tot-sum
          v-sum-step[v-jj] = buf_term-dis-rule.tot-sum
          .
        end.
      end.
    end. /*for each buf_term-dis-rule no-lock where*/
    v-step[v-jj] = lookup(string(v-sum-step[v-jj]), v-string[v-jj], "|").
  end.
end. /*do v-jj*/
if v-step[2] - v-step[1]  >= 0 then do:
  /*набрал сумму столько же или больше - можно вычислять по лестнице ступенька в ступеньку*/
  if v-step[1] > 0 then do:
  v-discnt-value = decimal(entry(v-step[1], v-discnt-string[1], "|")).
end.
end.
else do:
  if v-step[1] > 1 then do:
    v-discnt-value = decimal(entry(v-step[1] - 1, v-discnt-string[1], "|")).
  end.
end.
return v-discnt-value.
end function.
&endif

&if "{1}" = "64"  &then
/*@% скидка по ДК на итогтовар - интервальный алг-тм с обнул. итогов пересч-м по пред. пер-ду и снижением по 1 ступени*/
FUNCTION dis-rule_00064 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal
                                        , input p-prev-rule-num as integer
                                        , input p-prev-tot-sum as decimal ) map to dis-rule_00063 in this-procedure .

&Endif

&if ("{1}" = "65"
or "{1}" = "{&ddctr-calc-categ}")
&then
/*@катгеория  ДК - интервальный алг-тм с обнул. итогов пересч-м по пред. пер-ду и снижением по 1 ступени*/
FUNCTION dis-rule_00065 returns integer ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-tot-sum as decimal
                                        , input p-prev-rule-num as integer
                                        , input p-prev-tot-sum as decimal
                                        ) :
define variable v-delta as decimal no-undo .
define variable v-start as logical no-undo init yes.
define variable v-dis-kat-value as integer no-undo .
define variable v-step as integer no-undo extent 2.
define variable v-sum-step as decimal no-undo extent 2.
define variable v-string as character no-undo  extent 2.
define variable v-dis-kat-string as character no-undo  extent 2.
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-rule-num as integer no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-found as logical no-undo .
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
do v-jj = 1 to 2:
  v-start = yes.
  if v-jj = 1 then do:
    v-rule-num  = p-rule-num.
    v-tot-sum = p-tot-sum.
  end.
  if v-jj = 2 then do:
     v-rule-num = p-prev-rule-num.
     v-tot-sum = p-prev-tot-sum.
  end.
  find first buf_dis-rule no-lock where
          buf_dis-rule.rule-num = v-rule-num no-error.
  if available buf_dis-rule
  and (v-jj = 2 or (buf_dis-rule.sts = integer({&current-status-int})
                and {&time-ok}))
  then do:
    for each buf_term-dis-rule no-lock where
            buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num:
      v-found = no.
      _v-ii:
      do v-ii = 1 to num-entries(v-string[v-jj], "|":U):
         if buf_term-dis-rule.tot-sum <= decimal(entry(v-ii, v-string[v-jj], "|":U)) then do:
           entry(v-ii, v-string[v-jj], "|":U) = string(buf_term-dis-rule.tot-sum) + "|" +  entry(v-ii, v-string[v-jj], "|":U) .
           entry(v-ii, v-dis-kat-string[v-jj], "|":U) =  string(buf_term-dis-rule.dis-kat) + "|" +  entry(v-ii, v-dis-kat-string[v-jj], "|":U) .
           v-found = yes.
           leave _v-ii.
         end.
      end.
      if not v-found then do:
        assign
        v-string[v-jj] = v-string[v-jj]  + (if v-string[v-jj] = '' then '' else "|") +  string(buf_term-dis-rule.tot-sum)
        v-dis-kat-string[v-jj] = v-dis-kat-string[v-jj]  + (if v-dis-kat-string[v-jj] = '' then '' else "|") +  string(buf_term-dis-rule.dis-kat)
        .
      end.
      if buf_term-dis-rule.tot-sum <= p-tot-sum then do:
        if v-start
        or v-delta  > (p-tot-sum - buf_term-dis-rule.tot-sum)
        then do:
          assign
          v-start = no
          v-delta = p-tot-sum - buf_term-dis-rule.tot-sum
          v-sum-step[v-jj] = buf_term-dis-rule.tot-sum
          .
        end.
      end.
    end. /*for each buf_term-dis-rule no-lock where*/
    v-step[v-jj] = lookup(string(v-sum-step[v-jj]), v-string[v-jj], "|").
  end.
end. /*do v-jj*/
if v-step[2] - v-step[1]  >= 0 then do:
  /*набрал сумму столько же или больше - можно вычислять по лестнице ступенька в ступеньку*/
  if v-step[1] > 0 then do:
  v-dis-kat-value = integer(entry(v-step[1], v-dis-kat-string[1], "|")).
end.
end.
else do:
  if v-step[1] > 1 then do:
    v-dis-kat-value = integer(entry(v-step[1] - 1, v-dis-kat-string[1], "|")).
  end.
end.
return v-dis-kat-value.
end function.
&endif


&if ("{1}" = "66"
     or "{1}" = "{&dgr-dis-tot-flag}")
 and defined(dis-rule_00066) = 0
&then
&glob dis-rule_00066
FUNCTION dis-rule_00066 returns logical ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer):
/*@% скидка на строку товара (для MARIA-только топливо)*/
define buffer buf_dis-rule for ub.dis-rule.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok} then do:
  return yes.
end.
return no.
end function.
&endif

&if ("{1}" = "67"
or "{1}" = "{&ddcr-credit-pay-free-discnt}")
&then
/*@Запрет на участие в скидке на итог (POS NCR-GM, NCR-AS@R, IBM-XML)*/
FUNCTION dis-rule_00067 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        ) map to dis-rule_00055 in this-procedure .

&endif

&if ("{1}" = "68"
or "{1}" = "{&dgr-max-disc}")
&then
/*@% макс скидки товар*/
FUNCTION dis-rule_00068 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer) map to dis-rule_00001 in this-procedure .
&endif

&if ("{1}" = "69"
or "{1}" = "{&ddctr-def-pcnt}")
&then
/*@% скидки на товар по умолчанию для типа ДК*/
FUNCTION dis-rule_00069 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer) map to dis-rule_00001 in this-procedure .
&endif

&if ("{1}" = "70"
or "{1}" = "{&ddctr-def-cash-pcnt}")
&then
/*@% скидки на итог по умолчанию для типа ДК*/
FUNCTION dis-rule_00070 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer) map to dis-rule_00001 in this-procedure .
&endif


&if ("{1}" = "71"
or "{1}" = "{&ddctr-def-categ}")
&then
FUNCTION dis-rule_00071 returns integer ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer):
/*@% категория сскидки по умолчанию для типа ДК)*/
define buffer buf_dis-rule for ub.dis-rule.
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok} then do:
  return buf_dis-rule.dis-лфе.
end.
return 0.
end function.
&endif



&if ("{1}" = "72"
or "{1}" = "{&dclgr-pcnt}")
&then
/*@% скидки товар для группы клиентов*/
FUNCTION dis-rule_00072 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer) map to dis-rule_00001 in this-procedure .
&endif

&if ("{1}" = "73"
or "{1}" = "{&dcpr-qnty-pay}")
&then
/*% скидка на кол-во по строке товара по типу касс платежа (POS IBM IBM-XML)*/
FUNCTION dis-rule_00073 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-doc-qnty as decimal
                                        , input p-cdpay-code as integer
                                        , input p-curr-code as integer
                                        ):
define buffer buf_dis-rule for ub.dis-rule.
define buffer buf_term-dis-rule for ub.dis-rule.
define variable v-delta as decimal no-undo .
define variable v-start as logical no-undo init yes.
define variable v-discnt-value as decimal no-undo .
find first buf_dis-rule no-lock where
        buf_dis-rule.rule-num = p-rule-num no-error.
if available buf_dis-rule
and buf_dis-rule.sts = integer({&current-status-int})
and {&time-ok}
then do:
  for each buf_term-dis-rule no-lock where
          buf_term-dis-rule.upper-rule-num = buf_dis-rule.rule-num
      and buf_term-dis-rule.key#_one = p-cdpay-code
      and buf_term-dis-rule.key#_two = p-curr-code
          :
    if buf_term-dis-rule.doc-qnty <= p-doc-qnty then do:
      if v-start
      or v-delta  > (p-doc-qnty - buf_term-dis-rule.doc-qnty)
      then do:
        assign
        v-discnt-value = buf_term-dis-rule.discnt-value
        v-start = no
        v-delta = p-doc-qnty - buf_term-dis-rule.doc-qnty
        .
      end.
    end.
  end.
  return v-discnt-value.
end.
return 0.0.
end function.
&endif

&if ("{1}" = "74"
or "{1}" = "{&dcpr-qnty-pay}")
&then
/*Абс скидка на кол-во по строке товара по типу касс платежа (POS IBM IBM-XML)*/
FUNCTION dis-rule_00074 returns decimal ( input p-rule-num as integer
                                        , input p-date as date
                                        , input p-time as integer
                                        , input p-doc-qnty as decimal
                                        , input p-cdpay-code as integer
                                        , input p-curr-code as integer
                                        ) map to dis-rule_00073 in this-procedure .


&endif



/* &if defined(dis-rule_f_i) = 0 &then */

/* $Workfile$ e n d */