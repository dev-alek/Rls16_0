/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

пересылка скидок по категории и кол-ву

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/11/05
Author: Bakhtadze Natalya
Creation date: 04/11/05

*/

/*скидки по количеству*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$".

&scop disc-rule-num cash-gds.qnty-discnt-rule


if (v-version-dec >= 4.4 or amntdisc = 1 )
then do:
  PUT stream IBMstream unformatted
  '7' {&space-char}
  (if {&disc-rule-num} = 0
   then '"D"':U
   else {1})
   {&space-char}
  IBM-good-code
  {&space-char}
  .
  if {&disc-rule-num} <> 0 then do:
    for each cash-dis-rule no-lock where
            cash-dis-rule.upper-rule-num = {&disc-rule-num}
    by cash-dis-rule.doc-qnty   :
      PUT stream IBMstream unformatted
      cash-dis-rule.doc-qnty / cash-gds.cli-base-rate {&space-char}
      ( - cash-dis-rule.discnt-value ) {&space-char}
      .
    end.
  end.
  PUT stream IBMstream unformatted
  SKIP.
end.

&scop disc-rule-num cash-gds.kat-discnt-rule

  if (v-version-dec < 4.4 and amntdisc = 0)  then do:
    PUT stream IBMstream unformatted
    '7' {&space-char}
    (if {&disc-rule-num} = 0
    then '"D"':U
    else {1})
    {&space-char}
    IBM-good-code
    {&space-char}
    .
    if {&disc-rule-num} <> 0 then do:
      for each cash-dis-rule no-lock where
              cash-dis-rule.upper-rule-num = {&disc-rule-num}
       :
        case cash-dis-rule.value-type:
          when integer({&discnt-v-pcnt}) then do:
            assign
            v-kat-discnt  = - cash-dis-rule.discnt-value
            .
          end.
          when integer({&discnt-v-abs}) then do:
            assign
            v-kat-discnt  = - cash-dis-rule.discnt-value
            .
          end.
          when integer({&discnt-v-pdf-pcnt}) then do:
            find first cash-gds-discnt where
                      cash-gds-discnt.b-code = cash-gds.b-code
                 and  cash-gds-discnt.rule-num = cash-dis-rule.rule-num
                and cash-gds-discnt.obj-type = {&shop}
                and cash-gds-discnt.obj-code = i-obj-code
                 no-error.
            if available cash-gds-discnt then do:
              assign
              v-kat-discnt = - (cash-gds.price-sale - cash-gds-discnt.discnt-value) / cash-gds.price-sale * 100
              .
            end.
            else do:
            assign
              v-kat-discnt = 0
            .
            end.
          end.
          otherwise do:
            v-kat-discnt  = 0.
          end.
        end case.
        PUT stream IBMstream unformatted
        cash-dis-rule.dis-kat {&space-char}
        (if cash-dis-rule.value-type = integer({&discnt-v-abs})
        then ( v-kat-discnt  * cash-gds.cli-base-rate)
        else ( v-kat-discnt ) )
        {&space-char}
        .
      end.
    end.
    PUT stream IBMstream unformatted
    SKIP.
  end.

if v-version-dec >= 4.4 then do:
  if {&disc-rule-num} = 0 then do:
      PUT stream IBMstream unformatted
      '18' {&space-char}
      '"D"'{&space-char}
      IBM-good-code
      skip.
  end.
  else do:
    for each cash-dis-rule where
            cash-dis-rule.upper-rule-num = {&disc-rule-num} :
      if cash-dis-rule.templ-rl-root = 34
      and v-version-dec < 4.48 then do:
        NEXT.
      end.
      case cash-dis-rule.value-type:
        when integer({&discnt-v-pcnt}) then do:
          assign
          v-kat-discnt  = - cash-dis-rule.discnt-value
          .
        end.
        when integer({&discnt-v-abs}) then do:
          assign
          v-kat-discnt  = - cash-dis-rule.discnt-value
          .
        end.
        when integer({&discnt-v-pdf-pcnt}) then do:
          find first cash-gds-discnt where
                    cash-gds-discnt.b-code = cash-gds.b-code
                and  cash-gds-discnt.rule-num = cash-dis-rule.rule-num
                and cash-gds-discnt.obj-type = {&shop}
                and cash-gds-discnt.obj-code = i-obj-code
                no-error.
          if available cash-gds-discnt then do:
            assign
            v-kat-discnt = - (cash-gds.price-sale - cash-gds-discnt.discnt-value) / cash-gds.price-sale * 100
            .
          end.
          else do:
          assign
            v-kat-discnt = 0
          .
          end.
        end.
        otherwise do:
          v-kat-discnt  = 0.
        end.
      end case.
      PUT stream IBMstream unformatted
      '18' {&space-char}
      {&double-quote}
      {1}
      {&double-quote} {&space-char}
      IBM-good-code {&space-char}
      cash-dis-rule.dis-kat {&space-char}
      string(if cash-dis-rule.templ-rl-root = 34
            then 5
            else (if cash-dis-rule.value-type = integer({&discnt-v-abs})
                  or cash-dis-rule.value-type = integer({&discnt-v-pdf-abs})
                  then 2
                  else 1), "9":U) /*тип категорийной скидки использовать размер в процентах*/ {&space-char}
      string(0 , "9":U) {&space-char} /*номер набора скидки - нас не касается у нас по проценту*/
      (if cash-dis-rule.value-type <> integer({&discnt-v-abs})
       and cash-dis-rule.value-type <> integer({&discnt-v-pdf-abs})
      then string(v-kat-discnt , "->9.99":U) /*размер скидик в процентах*/
      else string(0, "->9.99":U)) {&space-char} /*размер скидик в процентах*/
      (if cash-dis-rule.value-type = integer({&discnt-v-abs})
       or cash-dis-rule.value-type = integer({&discnt-v-pdf-abs})
      then string(v-kat-discnt * cash-gds.cli-base-rate , "->>>>>>>9.99":U)
      else string(0, "->>>>>>>9.99":U)) {&space-char} /*размер скидик в баз вал*/
      string(0 , ">>>>>>>9.99":U) {&space-char} /*цена со скидкой  в баз вал*/
      (if cash-dis-rule.templ-rl-root = 34
      then (string(cash-dis-rule.tot-sum, ">>>>>>>9.99":U) + {&space-char})  /*поправочный коэффициент*/
      else ('0' + {&space-char}) )
      OS2-time
      {&new-line}
      .
    end.
  end. /*ненулевая скидка*/
end. /*if v-version-dec >= 4.4*/


/* $Workfile$ e n d */