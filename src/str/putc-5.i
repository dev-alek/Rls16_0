/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отсылка оплат на кассу - вывод

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/19/06
Author: Bakhtadze Natalya
Creation date: 02/19/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE par-pos-type:
  when {&cd-type-ibm}
  then do:
    /*наличные посылаются только один раз */
    IF {&prefix}cash-pay.is-cash = YES and
        (({&prefix}cash-pay.cdpay-code = 1 and NOT {&prefix}cash-pay.curr-code = ibmnalc ) /*OR
          {&prefix}cash-pay.pay-code > 1*/ ) then NEXT.
    if {&prefix}cash-pay.status_ <> {&current-status} and action = 'U' and selective = 0 then NEXT.
    if {&prefix}cash-pay.cdpay-code > 99 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Тип кассового платежа &1 (код &2 код валюты &3)&4не может быть отправлен на кассу типа &5" +
                              "Для данного типа касс код платежа должен быть < 100"
                             ,{&prefix}cash-pay.obj-name
                             ,{&prefix}cash-pay.cdpay-code
                             ,{&prefix}cash-pay.curr-code
                             ,{&new-line}
                             ,par-pos-type
                            )                 ).

      assign
      v-view-log = yes
      .
      NEXT.
    end.

    dopi = 15 - MIN(length(TRIM({&prefix}cash-pay.obj-name)), 15).
    if dopi modulo 2 = 0 then
    dopi = dopi / 2.
    else
    assign dopi = TRUNCATE(dopi / 2, 0).
    assign
    v-version-dec = decimal(p-pos-version)
    no-error .
    release buf_dis-rule.
    if v-version-dec >= 4.55 then do:
      if action <> 'D':U  then do:
        /*найдем значение атрибута*/
        find first buf_dis-cp-rule no-lock where
              buf_dis-cp-rule.cdpay-code = {&prefix}cash-pay.cdpay-code
          and buf_dis-cp-rule.curr-code = {&prefix}cash-pay.curr-code
          and buf_dis-cp-rule.host-code = v-host-code
          and buf_dis-cp-rule.obj-type = {&shop}
          and buf_dis-cp-rule.obj-code = i-obj-code
          and buf_dis-cp-rule.discnt-role =  {&dcpr-simple-pay}
          and buf_dis-cp-rule.pos-type =  {&cd-type-ibm} no-error.
        if available buf_dis-cp-rule then do:
          find first buf_dis-rule no-lock where
                    buf_dis-rule.obj-type = {&shop}
                AND buf_dis-rule.obj-code = i-obj-code
                AND buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                AND buf_dis-rule.sts = integer({&current-status-int}) no-error .
          if available buf_dis-rule then do:

          end.
        end. /**/
        else do:
          find first buf_dis-cp-rule no-lock where
                buf_dis-cp-rule.cdpay-code = {&prefix}cash-pay.cdpay-code
            and buf_dis-cp-rule.curr-code = {&prefix}cash-pay.curr-code
            and buf_dis-cp-rule.host-code = 0
            and buf_dis-cp-rule.obj-type = '':U
            and buf_dis-cp-rule.obj-code = 0
            and buf_dis-cp-rule.discnt-role =  {&dcpr-simple-pay}
            and buf_dis-cp-rule.pos-type =  {&cd-type-ibm} no-error.
          if available buf_dis-cp-rule then do:
            find first buf_dis-rule no-lock where
                      buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                  AND buf_dis-rule.sts = integer({&current-status-int}) no-error .
            if available buf_dis-rule then do:

            end.
          end. /**/
        end.
      end. /* if action <> 'D':U  then do:*/
    end. /*if v-version >= 4.55 then do:*/

    PUT stream IBMStream unformatted
    '5 "' string( Action, "x(1)" ) '" '
    string( {&prefix}cash-pay.cdpay-code, ">9" )
    ' "'
    string(
            fill(" ", int(dopi)) +
            TRIM(replace(replace({&prefix}cash-pay.obj-name, {&double-quote}, '':U), {&single-quote}, '':U)) +
            fill(" ", int(dopi)), "x(13)"
          )

    '" '
    string( if multicurr
            then 0
            else (if {&prefix}cash-pay.curr-code = 0
                  then kassa-rub-code
                  else {&prefix}cash-pay.curr-code ), ">9" )
    " " string( {&prefix}cash-pay.pay-limit, "->>>>>9.99" )
    " "
    string( int( {&prefix}cash-pay.atr1 ) + int( {&prefix}cash-pay.atr2 ) * 2 + int( {&prefix}cash-pay.atr4 ) * 4 +
            int( {&prefix}cash-pay.atr8 ) * 8 + int( {&prefix}cash-pay.atr16 ) * 16 + int( {&prefix}cash-pay.atr32 ) * 32 +
            int( {&prefix}cash-pay.atr64 ) * 64 + int({&prefix}cash-pay.atr128) * 128 +
            (if v-version-dec >= 4.4
            then ( int( {&prefix}cash-pay.is-service-pay ) * 256 +
                    int( {&prefix}cash-pay.is-goods-pay ) * 512)
             else 0)
            , "999" )
    space(1)
    ( if Cash-OS2 then
    string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
    else "" )
    .
    if v-version-dec >= 4.55
      then do:
        put stream IBMStream unformatted
        {&space-char}
        {&double-quote} string({&prefix}cash-pay.slip-file-name, "X(15)")  /*название файла слипа*/  {&double-quote}
        {&space-char}
        string(if available buf_Dis-rule
                then (if buf_dis-rule.value-type = integer({&discnt-v-pcnt})
                      then 2
                      else 1)
                else 0)
        {&space-char}
        (if available buf_Dis-rule
        then
        (if buf_dis-rule.value-type = integer({&discnt-v-pcnt})
          then string(- buf_dis-rule.discnt-value, "->>9.99")
          else string(- buf_dis-rule.discnt-value, ">>>>>>>>9.99")
          )
        else string(0)
        )
        .
    end.

    PUT stream IBMStream unformatted
    skip .
  end. /*when ibm*/
  when {&cd-type-ibm-xml} then do:
   assign
    v-version-dec = decimal(p-pos-version)
    no-error .

    release buf_dis-rule.
    IF {&prefix}cash-pay.is-cash = YES and
        (({&prefix}cash-pay.cdpay-code = 1 and NOT {&prefix}cash-pay.curr-code = ibmnalc ) /*OR
          {&prefix}cash-pay.pay-code > 1*/ ) then NEXT.
    run bgelib-tag-open in this-procedure ( input 2, input "Payment"
                                          , input substitute("ctrl='&1' tms='&2' code='&3'", (if action = "U"
                                                                                              then if {&prefix}cash-pay.status_ eq {&current-status}  then "ADD":U else "DEL":U
                                                                                              else "DEL":U),
                                                              OS2-time, &if defined (prefix) eq 0
                                                                        &then cash-pay.cdpay-code
                                                                        &else
                                                                              if {&prefix}cash-pay.cdpay-code eq ?
                                                                              then "*"
                                                                              else string({&prefix}cash-pay.cdpay-code)
                                                                        &endif )).

    run bgelib-tag-put in this-procedure ( input 3, input "PaymentLock":U
                                          , input string(if {&prefix}cash-pay.status_ = {&current-status} then 0 else 1), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentName":U
                                          , input substr({&prefix}cash-pay.obj-name, 1, (if v-version-dec >= 1.08 then 35 else 15)), input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentCur":U
                                          , input string(if multicurr
                                                         then 0
                                                         else (if {&prefix}cash-pay.curr-code = 0
                                                                then kassa-rub-code
                                                                else cash-pay.curr-code)
                                                         )
                                          , input 1 ).
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentSlip":U
                                          , input string({&prefix}cash-pay.slip-file-name), input 1 ).
    /*
    должно быть int - НЕ ПЕРЕСЫЛАЕМ ПОКА

    run bgelib-tag-put in this-procedure ( input 3, input "PaymentRule":U
                                          , input string({&prefix}cash-pay.rule-file-name), input 1 ).
    */
    if v-version-dec >= 1.07 then do:
      if action <> 'D':U  then do:
        /*найдем значение атрибута*/
        find first buf_dis-cp-rule no-lock where
              buf_dis-cp-rule.cdpay-code = {&prefix}cash-pay.cdpay-code
          and buf_dis-cp-rule.curr-code = {&prefix}cash-pay.curr-code
          and buf_dis-cp-rule.host-code = v-host-code
          and buf_dis-cp-rule.obj-type = {&shop}
          and buf_dis-cp-rule.obj-code = i-obj-code
          and buf_dis-cp-rule.discnt-role =  {&dcpr-simple-pay}
          and buf_dis-cp-rule.pos-type =  {&cd-type-ibm-xml} no-error.
        if available buf_dis-cp-rule then do:
          find first buf_dis-rule no-lock where
                    buf_dis-rule.obj-type = {&shop}
                AND buf_dis-rule.obj-code = i-obj-code
                AND buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                AND buf_dis-rule.sts = integer({&current-status-int}) no-error .
          if available buf_dis-rule then do:

          end.
        end. /**/
        else do:
          find first buf_dis-cp-rule no-lock where
                buf_dis-cp-rule.cdpay-code = {&prefix}cash-pay.cdpay-code
            and buf_dis-cp-rule.curr-code = {&prefix}cash-pay.curr-code
            and buf_dis-cp-rule.host-code = 0
            and buf_dis-cp-rule.obj-type = '':U
            and buf_dis-cp-rule.obj-code = 0
            and buf_dis-cp-rule.discnt-role =  {&dcpr-simple-pay}
            and buf_dis-cp-rule.pos-type =  {&cd-type-ibm-xml} no-error.
          if available buf_dis-cp-rule then do:
            find first buf_dis-rule no-lock where
                      buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                  AND buf_dis-rule.sts = integer({&current-status-int}) no-error .
            if available buf_dis-rule then do:

            end.
          end.
        end.
      end. /* if action <> 'D':U  then do:*/
    end.
    if v-version-dec >= 1.12 then do:
      if action <> 'D':U  then do:
        /*найдем значение атрибута*/
         find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = {&prefix}cash-pay.cdpay-code
                                 and buf_cash-pay-attr.curr-code = {&prefix}cash-pay.curr-code
                                 and buf_cash-pay-attr.attr-code = "cash-prop" no-error .
      end. /* if action <> 'D':U  then do:*/
    end.
    if AVAILABLE buf_cash-pay-attr then do:
        run bgelib-tag-put in this-procedure ( input 3, input "PaymentType":U
                                             ,input (buf_cash-pay-attr.attr-value)
                                            ,input 1
                                                     ).
    end.    
    if available buf_dis-rule
    then do:
      run bgelib-tag-put in this-procedure ( input 3, input "PaymentDType":U
                                             ,input (if buf_dis-rule.value-type = integer({&discnt-v-pcnt})
                                                     then 2
                                                     else 1)
                                            ,input 1
                                                     ).
      run bgelib-tag-put in this-procedure ( input 3, input "PaymentDisc":U
                                            , input (- buf_dis-rule.discnt-value)

                                          , input 1 ).

    end.
    else do:
      run bgelib-tag-put in this-procedure ( input 3
                                            ,input "PaymentDType":U
                                            ,input 0
                                            ,input 1
                                           ).
      run bgelib-tag-put in this-procedure ( input 3
                                            ,input "PaymentDisc":U
                                            ,input string(0)
                                            ,input 1 ).
    end.
    v-paymentetc = "" .
        find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = {&prefix}cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = {&prefix}cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = {&cp-attr-max_proc_sum} no-error .
    if AVAILABLE buf_cash-pay-attr then 
    do:
        v-paymentetc = "MaxLimit" + ":" + string(decimal(buf_cash-pay-attr.attr-value) * 100).   
    end.    
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = {&prefix}cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = {&prefix}cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = {&cp-attr-mask_card_kup} no-error .
    if AVAILABLE buf_cash-pay-attr then 
    do:
        v-paymentetc = v-paymentetc + "," + "Mask" + ":" + buf_cash-pay-attr.attr-value .   
    end.
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = {&prefix}cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = {&prefix}cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "cash-card-type" no-error .
        if AVAILABLE buf_cash-pay-attr then do:
          v-paymentetc = v-paymentetc + "," + "FuelCard" + ":" + buf_cash-pay-attr.attr-value . 
        end.    
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = {&prefix}cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = {&prefix}cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "cash-card-type-bank" no-error .
        if AVAILABLE buf_cash-pay-attr then do:
          v-paymentetc = v-paymentetc + "," + "BankCard" + ":" + buf_cash-pay-attr.attr-value . 
        end.        
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = {&prefix}cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = {&prefix}cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "qr-mir" 
        and buf_cash-pay-attr.attr-value = string(yes) no-error .
        if AVAILABLE buf_cash-pay-attr then do:
          v-paymentetc = v-paymentetc + "," + "Ext" + ":" + "peace-qr" . 
        end.    
              
    run bgelib-tag-put in this-procedure ( input 3, input "PaymentEtc":U
                                             ,input (trim(v-paymentetc,","))
                                            ,input 1
                                                     ).
    find first buf_cash-pay-attr no-lock where buf_cash-pay-attr.cdpay-code = {&prefix}cash-pay.cdpay-code
        and buf_cash-pay-attr.curr-code = {&prefix}cash-pay.curr-code
        and buf_cash-pay-attr.attr-code = "cash-type-pay-fr" no-error .
    if AVAILABLE buf_cash-pay-attr then do:
       run bgelib-tag-put in this-procedure ( input 3, input "PaymentFRType":U
                                             ,input buf_cash-pay-attr.attr-value
                                            ,input 1
                                                     ).  
    end.
              
    run bgelib-tag-open in this-procedure ( input 3, input "PaymentStatus"
                                          , input "":U).
    run bgelib-tag-put in this-procedure ( input 4, input "PSCash":U
                                          , input string(if {&prefix}cash-pay.is-cash then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSReturn":U
                                          , input string(if {&prefix}cash-pay.atr1 or {&prefix}cash-pay.has-return > 0 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSTransfer":U
                                          , input string(if {&prefix}cash-pay.atr2 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSPrintSlip":U
                                          , input string(if {&prefix}cash-pay.atr4 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSPrintFact":U
                                          , input string(if {&prefix}cash-pay.atr8 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSAuthorize":U
                                          , input string(if {&prefix}cash-pay.atr16
                                                        then 1
                                                        else 0), input 0 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSFuelPay":U
                                          , input string(if {&prefix}cash-pay.atr64 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSServicePay":U
                                          , input string(if {&prefix}cash-pay.is-service-pay then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSUnitPay":U
                                          , input string(if {&prefix}cash-pay.is-goods-pay then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSAllPay":U
                                          , input string(if {&prefix}cash-pay.is-all-pay then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSChipCard":U
                                          , input string(if {&prefix}cash-pay.atr128 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSRequestPin":U
                                          , input string(if {&prefix}cash-pay.atr32 then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSBarRead":U
                                          , input string(if {&prefix}cash-pay.is-bar-read then 1 else 0), input 1 ).
    run bgelib-tag-put in this-procedure ( input 4, input "PSCardSwap":U
                                          , input string(if {&prefix}cash-pay.is-card-swap then 1 else 0), input 1 ).
    run bgelib-tag-close in this-procedure ( input 3, input "PaymentStatus").


    run bgelib-tag-close in this-procedure ( input 2, input "Payment").
  end. /*when ibm-xml*/
  when {&cd-type-maria} then do:
    v-found-maria-discnt = no.
    assign
    v-index = index((mariapayp + ";")
                    ,({&slash-char} + string({&prefix}cash-pay.cdpay-code) + {&comma-char} + string({&prefix}cash-pay.curr-code) + ';')
                     ).
    if v-index > 0
    then do:
      do v-ii = 1 to num-entries(mariapayp, ';'):
        assign
        v-dop = entry(v-ii, mariapayp, ';')
        v-dop2 = entry(2, v-dop, {&slash-char})
        v-dop =  entry(1, v-dop, {&slash-char})
        v-plu = entry(2, v-dop)
        v-dop = entry(1, v-dop)
        .
        if entry(1,  v-dop2) = string({&prefix}cash-pay.cdpay-code)
        and entry(2, v-dop2) = string({&prefix}cash-pay.curr-code) then do:
          if  v-dop <> string(1)  /*не наличные*/
          and v-plu <> string(0) /*не тип кассового платежа для ведомостей*/
          then do:
            run maria-put in this-procedure (
                                            buffer buf_cash-desk
                                          , input out
                                          , input fname
                                          , input yes
                                          , input 0
                                          , input no
                                          , input integer(entry(1, entry(1, v-dop, {&slash-char})))
                                          , input 20
                                          , input v-plu
                                          , input (if action = 'D' then '':U else string({&prefix}cash-pay.obj-name, "X(18)"))).
          end.
          v-maria-discnt-value = string(0, '999').
          /*перешлем скидки*/
          if action <> 'D':U  then do:
            /*найдем значение атрибута*/
             find first buf_dis-cp-rule no-lock where
                    buf_dis-cp-rule.cdpay-code = {&prefix}cash-pay.cdpay-code
                and buf_dis-cp-rule.curr-code = {&prefix}cash-pay.curr-code
                and buf_dis-cp-rule.host-code = v-host-code
                and buf_dis-cp-rule.obj-type = {&shop}
                and buf_dis-cp-rule.obj-code = i-obj-code
                and buf_dis-cp-rule.discnt-role =  {&dcpr-simple-pay}
                and buf_dis-cp-rule.pos-type =  {&cd-type-maria} no-error.
            if available buf_dis-cp-rule then do:
              find first buf_dis-rule no-lock where
                        buf_dis-rule.obj-type = {&shop}
                    AND buf_dis-rule.obj-code = i-obj-code
                    AND buf_dis-rule.rule-num = buf_dis-cp-rule.rule-num
                    AND buf_dis-rule.sts = integer({&current-status-int}) no-error .
             if available buf_dis-rule then do:
              /*найдем код правила скидки на кассе МАРИЯ*/
                if index(dr-list, string(buf_dis-rule.rule-num) + '-') > 0 then do:
                  assign
                  v-dop2 = substring(dr-list, index(dr-list, string(buf_dis-rule.rule-num) + '-':U))
                  v-dop2 = substring(v-dop2, 1, index(v-dop2, {&comma-char}) - 1)
                  v-maria-rule-num = integer(entry(2, v-dop2, '-':U)) - 1
                  v-maria-discnt-value = string(v-maria-rule-num * 8 + 2, '999')
                  .
                end.
              end.
            end. /**/
          end. /* if action <> 'D':U  then do:*/
          v-found-maria-discnt = yes.
          if v-dop = string(1) then do:
            /*наличные*/
            entry(1 , v-record, {&delim-par} ) = v-maria-discnt-value.
          end.
          if v-dop <> string(1)
          and v-plu <> string(0) then do:
            entry( ((integer(v-dop) - 2) * 20 + integer(v-plu) + 414 - 9), v-record, {&delim-par}) =  v-maria-discnt-value.
          end.
        end.
      end.
    end.
    else do:
      if selective > 0 then
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Тип кассового платежа &1 (код &2 код валюты &3)&4не может быть отправлен на кассу типа &5&4" +
                              "Для данного типа касс типу кассового платежа должен быть задан КОД ОПЛАТЫ ТОПЛИВА НА кассе"
                             ,{&prefix}cash-pay.obj-name
                             ,{&prefix}cash-pay.cdpay-code
                             ,{&prefix}cash-pay.curr-code
                             ,{&new-line}
                             ,par-pos-type
                            )                 ).



    end.
  end.
END CASE.

/* $Workfile$ e n d */