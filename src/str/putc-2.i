/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вывод в поток для разных типов касс - пересылка дис карт

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/07/05
Author: Bakhtadze Natalya
Creation date: 10/07/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE putc-2.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter pos-type   as character no-undo.
define input parameter p-version  as character no-undo .
define input parameter p-send-cli as logical no-undo .

define variable v-magia-card-operation as integer no-undo .
define variable v-magia-curr-code as integer no-undo .
define variable v-r-b-code like ub.currency.curr-code.
define variable v-version-dec as decimal no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-full-number like ub.dis-card.d-card no-undo .
define variable v-cli-mask like ub.dis-card-mask.cli-mask no-undo .
define variable v-versiond as decimal no-undo .
define variable v-clu as integer no-undo .
define variable v-marketer-action as character no-undo .
define variable v-maria-discnt-value as character no-undo .
define variable v-ii as integer no-undo .
define variable v-dop as character no-undo .
define variable v-dc-rule-num as integer no-undo .
define variable v-maria-rule-num as integer no-undo .
define variable v-magia-kat-pcnt as integer no-undo .

define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_currency for ub.currency.
define buffer buf_cd-clu for ub.cd-clu.
define buffer buf_dis-rule for ub.dis-rule.
define buffer root_cash-dis-rule for cash-dis-rule.

if cash-cli.d-pcnt >= 100  then do:
  return error
  substitute("Карта &1:неверный процент скидки по карте &2"
              ,  cash-cli.d-card
              , cash-cli.d-pcnt
              ).

end.
if cash-cli.d-pcnt-byshop then do:
  v-d-pcnt = decimal(trim(get-dpcn ( input cash-cli.d-card
                     , input cash-cli.emitent-host-code
                     , input cash-cli.type
                     , input ub.sysconf.host-code
                     , input {&shop}
                     , input (if g#news
                              or g#esys
                              then buf_cash-desk.obj-code
                              else i-obj-code)
                     , input {&dc_prop_discount_d-pcnt}
                     , input cash-cli.d-pcnt
                     , input cash-cli.cash-d-pcnt
                     , input cash-cli.kat-pcnt), "%)(i ")).
  v-cash-d-pcnt = decimal(trim(get-dpcn ( input cash-cli.d-card
                     , input cash-cli.emitent-host-code
                     , input cash-cli.type
                     , input ub.sysconf.host-code
                     , input {&shop}
                     , input (if g#news
                              or g#esys
                              then buf_cash-desk.obj-code
                              else i-obj-code)
                     , input {&dc_prop_discount_d-pcnt}
                     , input cash-cli.d-pcnt
                     , input cash-cli.cash-d-pcnt
                     , input cash-cli.kat-pcnt), "%)(i ")).
  v-categ = integer(trim(get-dpcn ( input cash-cli.d-card
                     , input cash-cli.emitent-host-code
                     , input cash-cli.type
                     , input ub.sysconf.host-code
                     , input {&shop}
                     , input (if g#news
                              or g#esys
                              then buf_cash-desk.obj-code
                              else i-obj-code)
                     , input {&dc_prop_discount_d-pcnt}
                     , input cash-cli.d-pcnt
                     , input cash-cli.cash-d-pcnt
                     , input cash-cli.kat-pcnt), "%)(i ")).
end.
CASE pos-type:
  when {&cd-type-ibm}
  or
  when {&cd-type-nkt-ibm}
  then do:
    if pos-type = {&cd-type-nkt-ibm} then
    v-version-dec = 0.
    else
    assign
    v-version-dec = decimal(p-version) no-error .
    if v-version-dec >= 4.4
    then do:
      /*вот теперь это действительно клиент а не карта как было раньше*/
      PUT stream IBMstream unformatted
      '19' {&space-char}
      '"'  (if g#news or g#esys or run-from = "O":U or run-from = "E":U
              then
              (if cash-cli.cli-status_  = 0 then "U":U
              else "D":U)
              else string( action, "x(1)" )
              ) '"' {&space-char}
      {&double-quote}
      string( fill( {&space-char} , 16 - length( trim(string((if cash-cli.cli-type = {&cmp} then 1 else 0) * 1000000000 + cash-cli.cli-code ) ) ) )
            + string((if cash-cli.cli-type = {&cmp} then 1 else 0) * 1000000000 + cash-cli.cli-code)
            )
      {&double-quote}
      {&space-char}
      {&double-quote} caps( string( entry(1, cash-cli.cli-name, {&delim-par}), "x(40)" ) )   {&double-quote}   {&space-char}
      {&double-quote} caps( string( cash-cli.cli-city , "x(20)" ) )   {&double-quote}  {&space-char}
      {&double-quote} caps( string( cash-cli.cli-adr , "x(40)" ) ) {&double-quote} {&space-char}
       string( cash-cli.kat-pcnt, ">>>9" ) {&space-char}  /*категория сикдки*/
      {&double-quote} string(cash-cli.cli-inn, "X(20)") {&double-quote} {&space-char}  /* И Н Н*/
      {&double-quote} string(cash-cli.kpp, "X(25)") {&double-quote} {&space-char}  /* К П П  */
      string(cash-cli.h-ka, ">>>>>9") {&space-char}  /* индекс доставки теперь характеристика клиента*/
      (if  cash-cli.mask-card
      then string( cash-cli.lim-kr, ">>>>>>>>9.99" )
      else string( 0, ">>>>>>>>9.99" )
      ) {&space-char}
    /*для КАРАВАНА */
     (if  cash-cli.mask-card
      then string(cash-cli.current-saldo, "->>>>>>>>9.99" )
      else string( 0 , "->>>>>>>>9.99" )
      ) {&space-char}
      (if cash-cli.mask-card
      then string( if cash-cli.d-pcnt-byshop
                  then (- v-d-pcnt)
                  else ( - cash-cli.d-pcnt ) , "->>9.99" )
      else string( 0 , "->>9.99" )
      )
      {&space-char}
      Os2-time
      {&new-line}.

      /*с версии протокола 4.4 появилась КАРТА!!!*/
      if not cash-cli.mask-card then do:
        PUT stream IBMstream unformatted
        '21' {&space-char}
        '"'  (if g#news or g#esys or run-from = "O":U or run-from = "E":U
                then
                (if lookup({&current-status}, cash-cli.status_ ) > 0 then "U":U
                else "D":U)
                else string( action, "x(1)" )
                ) '"' {&space-char}
        {&double-quote}
        string( fill( " ", 19 - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ) )
        {&double-quote}
        {&space-char}  /*номер карты*/
        {&double-quote}
        string( fill( {&space-char} , 16 - length( trim(string((if cash-cli.cli-type = {&cmp} then 1 else 0) * 1000000000 + cash-cli.cli-code ) ) ) )
              + string((if cash-cli.cli-type = {&cmp} then 1 else 0) * 1000000000 + cash-cli.cli-code)
             )
        {&double-quote}
        {&space-char} /*код клиента*/
        string( if cash-cli.d-pcnt-byshop
                then (- v-d-pcnt)
                else ( - cash-cli.d-pcnt ) , "->>9.99" ) {&space-char}  /*скидка*/
        string( cash-cli.kat-pcnt, ">>>9" ) {&space-char}  /*категория сикдки*/
        string( cash-cli.lim-kr, ">>>>>>>>9.99" ) {&space-char}
        (if cash-cli.property-value-chr[1] <> '':U
          then cash-cli.property-value-chr[1]
          else string( cash-cli.current-saldo , "->>>>>>>>9.99" )
        )
        {&space-char}
        Os2-time
        {&new-line}.
      end.
    end.
    else do:
      if not cash-cli.mask-card then do:
        PUT stream IBMstream unformatted
        '2 "' (if g#news or g#esys or run-from = "O":U or run-from = "E":U then
                (if lookup({&current-status}, cash-cli.status_ ) > 0 then "U":U
                else "D":U)
                else string( action, "x(1)" )
                ) '" '
        string( fill( {&space-char}, 16 - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ) ) ' "'
        caps( string( entry(1, cash-cli.cli-name, {&delim-par}), "x(40)" ) ) '" "'
        caps( string( cash-cli.cli-city , "x(20)" ) )  '" "'
        caps( string( cash-cli.cli-adr , "x(40)" ) )  '" '
        string( cash-cli.kat-pcnt, ">>>>>9" ) ' "'   /*категория сикдки*/
        string(cash-cli.cli-inn, "X(20)")   '" "'   /* город доставки теперь И Н Н*/
        string(cash-cli.kpp, "X(25)")  '" ' /* К П П ранее адрес доставки */
        string(cash-cli.h-ka, ">>>>>9") " " /* индекс доставки теперь характеристика клиента*/
        string( cash-cli.lim-kr, ">>>>>>>>9.99" ) " "
      /*для КАРАВАНА */
       (if cash-cli.property-value-chr[1] <> '':U
        then cash-cli.property-value-chr[1]
        else string( cash-cli.current-saldo , "->>>>>>>>9.99" )
       )
        {&space-char}
        string( if cash-cli.d-pcnt-byshop
                then (- v-d-pcnt)
                else ( - cash-cli.d-pcnt ) , "->>9.99" )
        " "
        Os2-time
        {&new-line}.
      end.
    end.
  end.
  when {&cd-type-IBM-XML}
  then do:
    /*todo*/
    assign
    v-version-dec = decimal(p-version)
    no-error .
    { str/putc2xml.i }
  end.
  when {&cd-type-MAGIA-XML} then do:
    if not cash-cli.mask-card then do:
      run ref/dcard05.p (
                       input cash-cli.d-card
                      ,input cash-cli.type
                      ,input cash-cli.emitent-host-code
                      ,input i-obj-code
                      ,output v-cli-mask
                      ,output v-full-number
                      ) no-error .
      if error-status:error
      or
      v-full-number = '':U
      then do:
        return error
        substitute("&1&2&3"
                    , error-status:get-message(1)
                    , {&new-line}
                    , return-value
                    ).
      end.
      v-magia-kat-pcnt = cash-cli.kat-pcnt.
      find first root_cash-dis-rule where
               root_cash-dis-rule.rule-num = v-magia-kat-codes-rule no-error.
      if available root_cash-dis-rule then do:
        case root_cash-dis-rule.templ-rl-root:
          when 79 then do:
      find first cash-dis-rule where
                      cash-dis-rule.templ-rl-root = root_cash-dis-rule.templ-rl-root
                  and cash-dis-rule.rl-root = root_cash-dis-rule.rule-num
            and cash-dis-rule.dis-kat = cash-cli.kat-pcnt no-error.
      if available cash-dis-rule then do:
         v-magia-kat-pcnt = cash-dis-rule.key#_one.
      end.
          end.
          when 80 then do:
            for each cash-dis-rule where
                      cash-dis-rule.templ-rl-root = root_cash-dis-rule.templ-rl-root
                  and cash-dis-rule.rl-root = root_cash-dis-rule.rule-num
            by cash-dis-rule.discnt-value descending:
              if cash-dis-rule.discnt-value <= cash-cli.d-pcnt then do:
                v-magia-kat-pcnt = cash-dis-rule.dis-kat.
                leave.
              end.
            end.
          end.
        end case.
      end.
      else do:
         v-magia-kat-pcnt = cash-cli.kat-pcnt.
      end.
      if v-magia-kat-pcnt > 15 then do:
        return error
        substitute("Нельзя переслать на кассу &1 карту с категорией MAGIA > 15:&2Карта &3 категория IBS TH &4, категория MAGIA &5"
                   , {&cd-type-MAGIA-XML}
                   , {&new-line}
                   , cash-cli.d-card
                   , cash-cli.kat-pcnt
                   , v-magia-kat-pcnt).

      end.
      run bgelib-tag-open in this-procedure ( input 2, input "Card",
                                            input substitute("ctrl='&1' tms='&2'"
                                          , (if g#news or g#esys or run-from = "O":U or run-from = "E":U
                                              then
                                                (if lookup({&current-status}, cash-cli.status_ ) > 0
                                                then "ADD":U
                                                else "DEL":U
                                                )
                                              else (if action = "U"
                                                    then 'ADD':U
                                                    else "DEL":U
                                                    )
                                            )
                                          , OS2-time
                                          )).
     /*после разговора с Михеевым */

      /*if p-send-cli then do:*/
      /*остлыаемы данные по клиентам всегда - иначе машия ругается*/
        run bgelib-tag-put in this-procedure ( input 3, input "ClientName"       , input entry(1, cash-cli.cli-name, {&delim-par})
                                              , input 1 ).
        if cash-cli.cli-name2 <> "":u then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientName2"       , input  cash-cli.cli-name2, input 1 ).
        if cash-cli.cli-name3 <> "":u then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientName3"       , input  cash-cli.cli-name3, input 1 ).
        if cash-cli.cli-city <> "":u then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientCity"       , input cash-cli.cli-city, input 1 ).
        if cash-cli.cli-adr <> "":u then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientAddress"    , input cash-cli.cli-adr, input 1 ).
        if string(cash-cli.cli-ind) <> "":u then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientIndex"      , input string(cash-cli.cli-ind), input 1 ).
        if cash-cli.cli-phone <> "":u then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientPhone"      , input cash-cli.cli-phone, input 1 ).
        if cash-cli.cli-INN <> "":u then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientINN"        , input cash-cli.cli-inn, input 1 ).
        run bgelib-tag-put in this-procedure ( input 3, input "ClientJustFace"   , input string(cash-cli.justface), input 1 ).
        if cash-cli.passport <> "":u
        and cash-cli.passport <> {&delim-par}
        then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientPassport"    ,
                                                        input replace(cash-cli.passport, {&delim-par}, {&space-char}) , input 1 ).
        if cash-cli.given-by <> "":u then
        run bgelib-tag-put in this-procedure ( input 3, input "ClientPassportPlace" , input cash-cli.given-by, input 1 ).
      /*end.*/
      /*определим код r-b для данного эмитента карты*/
      if cash-cli.emitent-host-code = 0 then  do:
        assign
        v-r-b-code = 0
        no-error
        .
      end.
      else do:
      { gbl/r-b-curr.i ub.shop.host-code v-r-b-code }
      end.
      if error-status:error then do:
        return error
        substitute("Карта &1:не удалось определить код валюты продажи для типа карт &2: код эмитента &3"
                  ,  cash-cli.d-card
                  , cash-cli.type
                  ,  cash-cli.emitent-host-code
                  ).

      end.
      else do:
        if cash-cli.pay-code <> 0 then do:
          find first buf_cash-pay no-lock where
                    buf_cash-pay.cdpay-code = cash-cli.pay-code
                AND buf_cash-pay.curr-code = v-r-b-code no-error .
          if error-status:error then do:
            return error
            substitute("Карта &1:не найден тип кассового платежа для типа карт &2: код платежа &3, код валюты &4"
                      ,  cash-cli.d-card
                      , cash-cli.type
                      ,  cash-cli.pay-code
                      , v-r-b-code).
          end.
          find first buf_currency no-lock where
                    buf_Currency.curr-code = v-r-b-code no-error .
          if error-status:error then do:
            return error
          substitute("Карта &1:не найдена валюта для типа кассового платежа для типа карт &2: код платежа &3, код валюты &4"
                    ,  cash-cli.d-card
                    , cash-cli.type
                    ,  cash-cli.pay-code
                    , v-r-b-code).
          end.
        end.
      end.
      assign
      v-magia-card-operation = if cash-cli.credit-card then 1
                                else (if cash-cli.staff-card
                                      then 3
                                      else ( if cash-cli.debet-card
                                            then 2
                                            else 0
                                            )
                                    )

      v-magia-curr-code = (if available buf_cash-pay
                          then (if buf_cash-pay.is-cash
                                  then (if buf_currency.curr-code = 0 then 1 else buf_currency.okv-code)
                                  else (10000 + cash-cli.pay-code)
                                  )
                          else ?)
      .

      run bgelib-tag-put in this-procedure ( input 3, input "ClientCode"       , input string(cash-cli.cli-code + 1000000000 * cash-cli.justface), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CardDisCat"       , input string(v-magia-kat-pcnt), input 1 ).
      /*
      ПОЧЕМУ-ТО МАГИЯ НЕ ПРИНИМАЕТ!!!!

      run bgelib-tag-put in this-procedure ( input 3, input "CardDisc"       ,
                                            input   string( if cash-cli.d-pcnt-byshop
                                                    then (- v-d-pcnt)
                                                    else ( - cash-cli.d-pcnt ) , "->>9.99" ) , input 0 ).
      */
      run bgelib-tag-put in this-procedure ( input 3, input "CardType"        , input string(cash-cli.card-media), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CardOperation"   , input string(v-magia-card-operation), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CardNumber"      , input v-full-number, input 1 ).
      if cash-cli.cli-message <> ?
      then
      run bgelib-tag-put in this-procedure ( input 3, input "CardMessage"     , input string(cash-cli.cli-message), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CardFiscal"      ,  input string(if cash-cli.fiscal-pay then 1 else 0), input 1 ).
      if v-magia-curr-code <> ? then
      run bgelib-tag-put in this-procedure ( input 3, input "CardCurrCode"    ,  input string(v-magia-curr-code), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CardMixedPay"    ,  input string(if cash-cli.mixed-pay then 1 else 0), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CardSaldo"        , input string(cash-cli.current-saldo), input 1 ).

      run bgelib-tag-put in this-procedure ( input 3, input "CardLimit"        , input string(- cash-cli.lim-kr), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CardLock"         ,
                                          input string(if lookup({&current-status}, cash-cli.status_ ) > 0
                                                              then 0
                                                              else 1
                                                      )
                                                      , input 1 ).
      run bgelib-tag-close in this-procedure ( input 2, input "Card").
    end.
  end.
  when {&cd-type-ipc-servispl} then  do:
    FIND FIRST ub.dis-card-type No-LOCK WHERE
                ub.dis-card-type.type = cash-cli.type AND
                ub.dis-card-type.emitent-host-code = cash-cli.emitent-host-code AND
                ub.dis-card-type.host-code = 0 AND
                ub.dis-card-type.obj-type = "":U AND
                ub.dis-card-type.obj-code = 0 No-ERROR.
    if not cash-cli.mask-card then do:
      PUT UNFORMATTED
      (ub.dis-card-type.dc-pfx + cash-cli.d-card) ","
      '"' caps( string( entry(1, cash-cli.cli-name, {&delim-par}), "x(20)")) '"' ","
      string( if cash-cli.d-pcnt-byshop
            then (v-d-pcnt)
            else ( cash-cli.d-pcnt ) , "->>9.99" ) ","
      string(/*dis-card.cli-code*/ 0, ">>>>>>>>9")
      SKIP.
    end.
  end.  /*ipc-servis+*/
  when {&cd-type-omron} then do:
    if not cash-cli.mask-card then do:
      PUT unformatted
      string( fill( " ", 12 - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ))
      "000000000000" /*номер счета*/
      caps( string( entry(1, cash-cli.cli-name, {&delim-par}), "x(20)" ) )
      fill( " ", 20) /*магазин*/
      caps( string( cash-cli.cli-adr , "x(25)" ) )
      caps( string( cash-cli.cli-city , "x(20)" ) )
      string( cash-cli.cli-ind, ">>>>>9" )
      fill(" ", 14) /*телефон*/
      fill(" ", 14) /*факс*/
      string(today, "999999") /*дата*/
      (if g#news or g#esys or run-from = "O":U or run-from = "E":U then
              (if lookup({&current-status}, cash-cli.status_ ) > 0 then "U":U
              else "D":U)
              else string( action, "x(1)" )
              )
      string( if cash-cli.d-pcnt-byshop
              then ( round(v-d-pcnt, 2) * 100 )
              else ( round(cash-cli.d-pcnt, 2) * 100 )
            , "9999" )
      SKIP
      .
    end.
  end.
  when {&cd-type-omron-new} then  do:
    if not cash-cli.mask-card then do:
      assign
      v-versiond = decimal(p-version)
      no-error .
      if v-versiond >= 33.0 then do:
        PUT unformatted
        string( fill( "0", 12 - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ))
        "000000000000" /*номер счета*/
        caps( string( entry(1, cash-cli.cli-name, {&delim-par}), "x(20)" ) )
        fill( " ", 20) /*магазин*/
        caps( string( cash-cli.cli-adr , "x(25)" ) )
        caps( string( cash-cli.cli-city , "x(20)" ) )
        string( cash-cli.cli-ind, ">>>>>9" )
        fill(" ", 14) /*телефон*/
        fill(" ", 14) /*факс*/
        string(today, "999999") /*дата*/
        (if g#news or g#esys or run-from = "O":U or run-from = "E":U then
                (if lookup({&current-status}, cash-cli.status_ ) > 0 then "U":U
                else "D":U)
                else string( action, "x(1)" )
                )
        string( if cash-cli.d-pcnt-byshop
                then ( round(v-d-pcnt, 2) * 100 )
                else ( round(cash-cli.d-pcnt, 2) * 100 )
              , "9999" )
        replace(string(today, "99/99/9999"), {&slash-char}, "":U) /*дата новое представление */
        '00':U /*код прайса*/
        '000':U /*код товарной группы*/
        fill( {&space-char} , 31) /*заполнитель*/
        SKIP.
      end.
      else do:
        PUT unformatted
        string( fill( " ", 12 - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ))
        "000000000000" /*номер счета*/
        caps( string( entry(1, cash-cli.cli-name, {&delim-par}), "x(20)" ) )
        fill( " ", 20) /*магазин*/
        caps( string( cash-cli.cli-adr , "x(25)" ) )
        caps( string( cash-cli.cli-city , "x(20)" ) )
        string( cash-cli.cli-ind, ">>>>>9" )
        fill(" ", 14) /*телефон*/
        fill(" ", 14) /*факс*/
        string(today, "999999") /*дата*/
        (if g#news or g#esys or run-from = "O":U or run-from = "E":U then
                (if lookup({&current-status}, cash-cli.status_ ) > 0 then "U":U
                else "D":U)
                else string( action, "x(1)" )
                )
        string( if cash-cli.d-pcnt-byshop
                then ( round(v-d-pcnt, 2) * 100 )
                else ( round(cash-cli.d-pcnt, 2) * 100 )
              , "9999" )
        SKIP
        .
      end.
    end.
  end. /*omron omron-new*/
  when {&cd-type-ncr-gm}
  or when {&cd-type-ncr-AS-R}
  then do:
    if length(cash-cli.d-card) > (if pos-type = {&cd-type-ncr-gm} then 10 else 12) then do:
      if not (g#news or g#esys) then  do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("!Ошибка при пересылке на кассу: Данные по дисконтной карте &1 не могут быть переданы на кассу NCR"
                   , cash-cli.d-card )
                                              ).
      end.
      return .
    end.
    if cash-cli.kat-pcnt <> 0
    AND (cash-cli.kat-pcnt < 10
    or cash-cli.kat-pcnt > 99)
    then do:
      if not (g#news or g#esys) then  do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("!Ошибка при пересылке на кассу:&2Данные по дисконтной карте &1 не могут быть переданы на кассу NCR&2" +
                               "Неверное значение категории карты: &3"
                               , cash-cli.d-card
                               , {&new-line}
                               , cash-cli.kat-pcnt
                               )
                                              ).
      end.
      return .
    end.
    if not cash-cli.mask-card then do:
      /*удаление*/
      if (g#news or g#esys or run-from = "O":U or run-from = "E":U ) and
          lookup({&current-status}, cash-cli.status_ ) = 0  or
          action = "D":U then do:
        PUT stream IBMstream unformatted
        "C1":U /*1st subrecord*/
        fill({&space-char}, (if pos-type = {&cd-type-ncr-gm} then 4 else 2)) /*filler*/
        string( fill( {&space-char}, (if pos-type = {&cd-type-ncr-gm} then 10 else 12) - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ) )  /*customer N*/
        "-":U
        fill("-":U, 61)
        {&new-line}
        "C2":U /*2nd subrecord*/
        fill({&space-char}, (if pos-type = {&cd-type-ncr-gm} then 4 else 2)) /*filler*/
        string( fill( {&space-char}, (if pos-type = {&cd-type-ncr-gm} then 10 else 12) - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ) )  /*customer N*/
        "-":U
        fill("-":U, 61)
        {&new-line}
        .
      end.
      else do:
        /*добавление*/
        PUT stream IBMstream unformatted
        "C1":U /*1st subrecord*/
        fill({&space-char}, (if pos-type = {&cd-type-ncr-gm} then 4 else 2)) /*filler*/
        string( fill( {&space-char}, (if pos-type = {&cd-type-ncr-gm} then 10 else 12) - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ) )  /*customer N*/
        "00":U /*tender control*/
        string(cash-cli.kat-pcnt, "99") /*lock control or branch*/
        replace(string((if cash-cli.d-pcnt-method = integer({&dc-d-pcnt-good})
                      or cash-cli.d-pcnt-method = integer({&dc-d-pcnt-both})
                      then cash-cli.d-pcnt
                      else 0), "999.9":U ), ".":U, "") /*discount*/
        replace(string((if cash-cli.d-pcnt-method = integer({&dc-d-pcnt-cash})
                      or cash-cli.d-pcnt-method = integer({&dc-d-pcnt-both})
                      then cash-cli.cash-d-pcnt
                      else 0), "999.9":U ), ".":U, "") /*dash discount*/
        "0000":U /*percent surcharge*/
        "00000000":U /*cheque limit*/
        replace(string(cash-cli.lim-kr, "999999.99":U ), ".":U, "":U) /*charge limit*/
        caps( string( entry(1, cash-cli.cli-name, {&delim-par}), "x(30)" ) )
        {&new-line}
        "C2":U /*2nd subrecord*/
        fill({&space-char}, (if pos-type = {&cd-type-ncr-gm} then 4 else 2)) /*filler*/
        string( fill( {&space-char}, (if pos-type = {&cd-type-ncr-gm} then 10 else 12) - length( trim( cash-cli.d-card ) ) ) + trim( cash-cli.d-card ) )  /*customer N*/
        fill({&space-char}, 2) /*filler*/
        caps( string( cash-cli.cli-adr , "x(30)" ) )
        (if cash-cli.property-value-chr[1] <> '':U
        then (cash-cli.property-value-chr[1] + {&space-char} + cash-cli.property-value-chr[2])
        else
        (string( cash-cli.cli-ind, ">>>>>9" ) + {&space-char} + caps( string( cash-cli.cli-city , "x(23)" ) ))
        )
        {&new-line}
        .
      end.
    end. /*не маска*/
  end.
  when {&cd-type-r-keeper} then do:
    if g#news
    or g#esys
    or action <> "D"
    and not cash-cli.mask-card
    then do:
      if length(cash-cli.d-card) > 9 then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("!Невозможно переслать на кассу типа &1 карту &2: слишком длинный номер карты"
                              , cash-cli.d-card
                              , {&cd-type-r-keeper}
                              )
                                              ).
      end.
      put stream IBMStream unformatted
      cash-cli.d-card {&comma-char}
      windows-date-format(if cash-cli.valid-date = {&end-of-age}
             then (today + 36500)
             else cash-cli.valid-date, v-date-format) {&comma-char}
      {&comma-char} /*номер скидки можно не указывать*/
      {&comma-char} /*номер бонуса можно не указывать */
      {&comma-char} /*день рождения  не указывать */
      entry(1, cash-cli.cli-name, {&delim-par}) {&comma-char}
      (if not cash-cli.credit-card
      then 0
      else 4
      )  {&comma-char}
      /*
      Тип карты (можно не указывать, по умолчанию 0):
      0 - дебетовая (сколько внесли денег, столько можно потратить)
      1 - без ограничений (трать сколько угодно)
      2 - лимит оплат на один день
      3 - лимит оплат на неделю
      4 - лимит оплат на месяц
    */
    cash-cli.lim-kr
    /*
    Сумма лимита для карт типа 2..4, сумма овердрафта для карт типа 0.
    (можно не указывать)
    */
      skip.
    end.
  end.
  when {&cd-type-maria} then do:
    if p-send-cli then do:
      find first buf_cd-clu EXCLUSIVE-LOCK where
                buf_cd-clu.obj-type = {&shop}
            and buf_cd-clu.obj-code = abs((if g#news or g#esys then buf_cash-desk.obj-code else i-obj-code))
            and buf_cd-clu.pos-type = {&cd-type-maria}
            and buf_cd-clu.clu-type = '':U
            AND buf_cd-clu.cli-type = cash-cli.cli-type
            AND buf_cd-clu.cli-code = cash-cli.cli-code  NO-ERROR.
      if not available buf_cd-clu then do:
        if v-del-mrkt-cli = no then do:
          /*если посылка идет из справочника клиенто то не ругаемся!!!*/
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Клиент &1&2 &3 не включен в число КЛИЕНТОВ НА КАССЕ &4 &5&6&7" +
                                  "пропускается...."
                                  , cash-cli.cli-type
                                  , cash-cli.cli-code
                                  , cash-cli.obj-name
                                  , pos-type
                                  , 'маг':U
                                  , (if g#news or g#esys then buf_cash-desk.obj-code else i-obj-code)
                                  , chr(10)
                                  )
                                    ).
        end.
      end.  /*if not available buf_cd-clu then do:*/
      assign
      v-clu = buf_cd-clu.clu-code.
      if (buf_cd-clu.to-del and v-del-mrkt-cli)
      or action = "D" then do:
        assign
        v-marketer-action = "D":U.
        if v-del-mrkt-cli then do:
          create temp-cd-clu.
          buffer-copy buf_cd-clu
          to temp-cd-clu
          assign
          buf_cd-clu.charkey_one = v-cd-list-delete
          .
        end.
        else do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Клиент &1&2 &3 может быть удален с кассы типа &4 ТОЛЬКО при удалении из числа КЛИЕНТОВ НА КАССЕ &4 &5&6&7" +
                                  "пропускается...."
                                  , cash-cli.cli-type
                                  , cash-cli.cli-code
                                  , cash-cli.obj-name
                                  , pos-type
                                  , 'маг':U
                                  , (if g#news or g#esys then buf_cash-desk.obj-code else i-obj-code)
                                  , chr(10)
                                  )
                                    ).
          v-view-log = yes.
        end. /*не из справочника клиентов на кассе*/
      end. /*if (buf_cd-clu.to-del and v-del-mrkt-cli)*/
      else do:
        assign
        v-marketer-action = action.
        if buf_cd-clu.to-send then do:
          create temp-cd-clu.
          buffer-copy buf_cd-clu
          to temp-cd-clu
          assign
          temp-cd-clu.charkey_two = ""
          temp-cd-clu.to-send = no
          .
        end. /*          if buf_cd-clu.to-send then do:*/
      end.
      /*клиенты*/
      run maria-put in this-procedure (
                                      buffer buf_cash-desk
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input {&tekka-obj-clients}
                                    , input 200
                                    , input string(v-clu)
                                    , input (if v-marketer-action = 'd' then '':U else string(cash-cli.obj-name, "X(18)"))).

      /*запишем правила скидок для постоянных клиентов*/
      v-maria-discnt-value = string(0, '999').
      if action <> 'D':U  then do:
        _do:
        do v-ii = 1 to 2:
          if v-ii = 1 then
          assign
          v-dc-rule-num = buffer cash-cli:buffer-field("dcr-debet-pay"):buffer-value.
          if v-ii = 2 then
          assign
          v-dc-rule-num = buffer cash-cli:buffer-field("dcr-credit-pay"):buffer-value.
          find first buf_dis-rule no-lock where
            buf_dis-rule.obj-type = {&shop}
                AND buf_dis-rule.obj-code = i-obj-code
                AND buf_dis-rule.rule-num = v-dc-rule-num
                AND buf_dis-rule.sts = integer({&current-status-int}) no-error .
          if available buf_dis-rule then do:
            /*найдем код правила на кассе МАРИЯ*/
            if buf_dis-rule.discnt-type = integer({&discnt-t-manual}) then do:
              assign
              v-maria-discnt-value = string('003')
              .
            end.
            else do:
              if index(dr-list, string(buf_dis-rule.rule-num) + '-') > 0 then do:
                assign
                v-dop = substring(dr-list, index(dr-list, string(buf_dis-rule.rule-num) + '-':U))
                v-dop = substring(v-dop, 1, index(v-dop, {&comma-char}) - 1)
                v-maria-rule-num = integer(entry(2, v-dop, '-':U)) - 1
                v-maria-discnt-value = string(v-maria-rule-num * 8 + 2, '999')
                .
              end.
            end.
          end.
          else do:
          end.
          entry(v-clu + (v-ii - 1) * 200, v-record, {&delim-par}) = v-maria-discnt-value.
        end. /*do v-ii = 1*/
      end. /*не D*/
      else do:
        do v-ii = 1 to 2:
          entry(v-clu + (v-ii - 1) * 200, v-record, {&delim-par}) = v-maria-discnt-value.
        end.
      end.
    end. /*if p-send-cli*/
  end. /*cd-type-maria*/
END CASE .
END PROCEDURE .


/* $Workfile$ e n d */