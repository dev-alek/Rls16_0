/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форматирование файла товаров для кассы NCR-MG

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/27/05
Author: Bakhtadze Natalya
Creation date: 10/27/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable ncr-disc-string as character no-undo .


if nam-artc then
chk_name = string( cash-gds.artic ) + " " + cash-gds.f-name.
else  do:
  chk_name = "" .
  DO ff = 1 TO num-entries( cash-gds.gds-name, '"' ) :
    chk_name = chk_name + entry( ff, cash-gds.gds-name, '"' ) .
  END .
  if chk_name = "" then
  chk_name = cash-gds.gds-name .
  chk_name = chk_name + cash-gds.f-name .
end.
if (cash-gds.unit-base <> cash-gds.unit-cli) and
   cash-gds.cli-base-rate <> 1 then
assign
chk_name = string(substr(chk_name, 1, 19 - length(string(cash-gds.cli-base-rate))) + "*" + string( cash-gds.cli-base-rate ), "x(20)" ).
else
chk_name = string(chk_name, "X(20)").
assign
ncrdsc = "0":U
conf-par = "":U
par-type ="":U
.
if std-disc-dec <> 0
or pos-type = {&cd-type-ncr-as-r}
then do:
  do ff = 1 to num-entries(ncrgmdsc, ";":U):
    assign
    par-type = entry(ff, ncrgmdsc , ";":U)
    conf-par = entry(2, par-type, "=":U)
    no-error
    .
    if error-status:error then do:
      LEAVE.
    end.
    if conf-par  = string( - std-disc-dec) then do:
      ncrdsc =  entry(1, par-type, "=").
      LEAVE.
    end.
  end.
end.
assign
IBM-good-code = "":U
is-sc = no
.
run ncr-gdsc in this-procedure (output IBM-good-code
                              , output IBM-good-code-2
                              , output is-sc
                              , output taracode-bc
                              ) no-error .
if IBM-good-code = "":U then
assign
IBM-good-code= IBM-good-code-2
.
assign
conf-par =  ncr-d-rank(ncrdrank, cash-gds.qnty-discnt-rule,  cash-gds.temp-discnt-rule, cash-gds.date-discnt-rule )
.

do2:
do while IBm-good-code <> "":U:
  if action = "D":U then do:
    put stream IBMStream unformatted
    fill({&space-char}, 3) /*filler*/
    IBM-good-code
    "-":U
    fill({&space-char}, 61)
    {&new-line}
    .
  end.
  else do:
    if conf-par = "T":U then do:
      ncr-disc-string = ncr-temp-disc(cash-gds.temp-discnt-rule, cash-gds.price-sale, temp-disc-dec).
    end. /*time-chain*/
    if conf-par = "D":U then do:
      ncr-disc-string = ncr-date-disc(cash-gds.date-discnt-rule, cash-gds.price-sale).
    end. /*date-chain*/
    if conf-par = "X":U then do:
       ncr-disc-string = ncr-amnt-disc(cash-gds.qnty-discnt-rule, cash-gds.price-sale).
    end. /*quantity-chain*/
    if ncr-disc-string = '':U then
    conf-par = {&space-char} .
    put stream IBMStream unformatted
    fill({&space-char}, 3) /*filler*/
    IBM-good-code
    string(if cash-gds.grp-code = 0 then 1 else cash-gds.grp-code , "9999":U) /*department*/
    (if LOOKUP( {&weight}, cash-gds.unit-cli-type ) > 0
    or (is-sc
    AND LOOKUP( {&weight}, cash-gds.unit-type ) > 0
    AND LOOKUP({&divisional}, cash-gds.unit-cli-type) > 0)
    then "2":U
    else "0":U) /*code1*/   /*!!!!*/
    (if LOOKUP({&divisional}, cash-gds.unit-cli-type) > 0
     or LOOKUP({&weight}, cash-gds.unit-cli-type) > 0
     or is-sc
     then "1":U
     else "0":U)  /*code2*/
      (if pos-type = {&cd-type-ncr-gm} or
      wd-option = 0
      then   ncrdsc /* discount code*/
      else '0':U)
     (if cash-gds.vat-code = ? or
     cash-gds.vat-code > 7 then
     "0"
     else string(cash-gds.vat-code, "9")) /* VAT code*/
    (if (LOOKUP( {&weight}, cash-gds.unit-cli-type ) > 0
    or (is-sc
    AND LOOKUP( {&weight}, cash-gds.unit-type ) > 0
    AND LOOKUP({&divisional}, cash-gds.unit-cli-type) > 0))
    and  (cash-gds.taracode  <> '':u
         or taracode-bc <> '')
    then (if taracode-bc <> ''
          then taracode-bc
          else cash-gds.taracode)
    else '00'
    ) /*tare mix/match code3*/
    (if cash-gds.unit-cli begins "№"
     then substring(cash-gds.unit-cli, 2, 2)
     else substring(cash-gds.unit-cli, 1, 2))  format "X(2)" /*pack-type*/
    "0010":U /*packin unit*/
    "0000":U /*deposit link*/
    chk_name
    fill({&space-char}, 4)
    (if pos-type = {&cd-type-ncr-gm} and wd-option > 0 then "1":U else {&space-char})
    fill({&space-char}, 8)
    conf-par
    replace(string( cash-gds.price-sale, "999999.99")
                    /*else (cash-gds.price-sale + std-disc-dec * 100)*/
           , ".":U, "":U
           )
    {&new-line}
    .
    if pos-type = {&cd-type-ncr-as-r}
    and ncrdsc <> '0':U
    and wd-option > 0
    and cash-gds.std-discnt-rule > 0
    then do:
      run create-ncr-kat-discnt in this-procedure (
                                                  input string(cash-gds.gds-code)
                                                  ,input (fill({&space-char}, 2) + {&space-char} + IBM-good-code)
                                                  ,input chk_name
                                                  ,input (if action = 'D':U then 0 else cash-gds.std-discnt-rule)
                                                  ,input ?
                                                  ,input 'time-rule-num':U
                                                  ,input ?
                                                  ) no-error .
    end.
    ncr-disc-string = '':U.
    if conf-par = "T":U then do:
      ncr-disc-string = ncr-temp-disc(cash-gds.temp-discnt-rule, cash-gds.price-sale, temp-disc-dec).
      if ncr-disc-string <> '':U then
      PUT stream IBMstream unformatted
      {&space-char} /*filler*/
      "T":U /*Time-chain*/
      {&space-char} /*filler*/
      IBM-good-code  /*plu*/
      {&space-char} /*code*/
      {&space-char} /*filler*/
      ncr-disc-string
      {&new-line}
      .
    end. /*time-chain*/
    if conf-par = "D":U then do:
      ncr-disc-string = ncr-date-disc(cash-gds.date-discnt-rule, cash-gds.price-sale).
      if ncr-disc-string <> '':U then
      PUT stream IBMstream unformatted
      {&space-char} /*filler*/
      "D":U /*Time-chain*/
      {&space-char} /*filler*/
      IBM-good-code  /*plu*/
      {&space-char} /*code*/
      {&space-char} /*filler*/
      ncr-disc-string
      {&new-line}
      .
    end. /*date-chain*/
    if conf-par = "X":U then do:
      /*здесь придется из IBM вида атрибута преобразовать в NCR-ский вид*/
      /*берем три первые вхождения для атрибута*/
      ncr-disc-string = ncr-amnt-disc(cash-gds.qnty-discnt-rule, cash-gds.price-sale).
      if ncr-disc-string <> '':U then
      PUT stream IBMstream unformatted
      {&space-char} /*filler*/
      "X":U /*Quantity-chain*/
      {&space-char} /*filler*/
      IBm-good-code  /*plu*/
      {&space-char} /*code*/
      {&space-char} /*filler*/
      ncr-disc-string
      {&new-line}
      .
    end. /*quantity-chain*/
  end. /*not D*/
  /*категорийные скидки*/
  if pos-type = {&cd-type-ncr-AS-R}
  and cash-gds.kat-discnt-rule <> 0
  then do:
    case how-pcnt-kat :
      when {&dthbjr-pcnt-kat-pdf} then do:
        /*пока ставим цену внутри еще находим*/
          v-kat-discnt = cash-gds.price-sale.
        end.
      otherwise do:
        /*внутри увидим*/
        v-kat-discnt = ?.
      end.
    end case.
    run create-ncr-kat-discnt in this-procedure (
                                                 input string(cash-gds.gds-code)
                                                ,input (fill({&space-char}, 2) + {&space-char} + IBM-good-code)
                                                ,input chk_name
                                                ,input (if action = 'D':U then 0 else cash-gds.kat-discnt-rule)
                                                ,input (if how-pcnt-kat = {&dthbjr-pcnt-kat-pdf} then 89 else 33)
                                                ,input 'time-rule-num':U
                                                ,input v-kat-discnt
                                                ) no-error .
    if error-status:error then do:
    end.
  end.

  if IBM-good-code = IBM-good-code-2 then leave do2.
  assign
  IBM-good-code = IBM-good-code-2
  .
end. /*do while*/

/* $Workfile$ e n d */