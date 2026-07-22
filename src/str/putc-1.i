/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

вывод в поток для разных типов касс - пересылка курсов валют

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/17/05
Author: Bakhtadze Natalya
Creation date: 10/17/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

PROCEDURE putc-1.
define input parameter p-pos-type as char no-undo.
define input parameter p-version as character no-undo .

define variable v-versiond as decimal no-undo .

CASE p-pos-type:
  when {&cd-type-IBM}
  or
  when {&cd-type-NKT-IBM}
  then do:
    put stream IbmStream unformatted "1 -1":U skip.
    _curr:
    FOR EACH ub.currency NO-LOCK,
        FIRST t-cs WHERE t-cs.curr-code = ub.currency.curr-code NO-LOCK :
      if p-pos-type = {&cd-type-nkt-ibm}
      and ub.currency.curr-code <> 0
      and ub.currency.curr-code <> v-base-code
      then nEXT _curr.
      if v-curr-r-b = {&r-b-rubl} then do:
        if ub.currency.curr-code = 0
        then
        put stream Ibmstream unformatted
        "1 ":U
        string( kassa-rub-code , ">9" )
        ' "':U
        substr( caps( trim( ub.currency.curr-abbr ) ), 1, 3 )
        '" "':U
        string( trim( ub.currency.curr-name ), "x(12)" ) '" ':U
        string( string( 1, "9.999999999" ) + "E+":U + string( 0, "999" ) )
        " ":U string(rnd-znak, "9") " ":U /* кол-во знаков после запятой на чеке */
        string( string( 1, ">>>>9.99" ) + " ":U + string( 1, ">>9" ) )
        space(1)
        ( if Cash-OS2
          then
          string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
          else "":U )  skip .
        else do:
          assign
          ii = 0
          dec-buf = t-cs.exch-rate / t-cs.exch-scale .
          right-curs = ( if dec-buf > 1 then TRUE else FALSE ) .
          if dec-buf > 1 then
          DO WHILE dec-buf >= 10 :
            assign
            dec-buf = dec-buf / 10
            ii = ii + 1 .
          END .
          else
          DO WHILE dec-buf < 1 :
            assign
            dec-buf = dec-buf * 10
            ii = ii + 1 .
          END .
          put stream Ibmstream unformatted
          "1 ":U string( ub.currency.curr-code, ">>9" )
          ' "':U substr( caps( trim( ub.currency.curr-abbr ) ), 1, 3 ) '" "':U
          string( trim( ub.currency.curr-name ), "x(12)" ) '" ':U .
          put stream Ibmstream unformatted
          string( string( dec-buf, "9.999999999" ) + "E":U +
          ( if right-curs then "+" else "-" ) + string( ii, "999" ) )
          " ":U string(rnd-znak, "9") " ":U .  /* кол-во знаков после запятой на чеке */
          if ( t-cs.bexch-rate / t-cs.bexch-scale ) * temp-scale < 100000.00
          then
          put stream IbmStream unformatted
          string( string( t-cs.bexch-rate / t-cs.bexch-scale * temp-scale,
                          ">>>>9.99" ) + " " +
                  string( temp-scale, ">>9" ) )
          space(1)
          ( if Cash-OS2
            then
            string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
            else "" )  skip .
          else
          put stream Ibmstream unformatted
          string( string( t-cs.bexch-rate / t-cs.bexch-scale, ">>>>9.99" ) +
                  " " + string( 1, ">>9" ) )
          space(1)
          ( if Cash-OS2
            then
            string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
            else "" )  skip .
        end.
      end.
      else    /* if v-curr-r-b = {&r-b-rubl} ... */ do:
        put stream Ibmstream unformatted
        "1 "
        string( if ub.currency.curr-code = 0 then kassa-rub-code else currency.curr-code , ">>9" )
        ' "' substr( caps( trim( ub.currency.curr-abbr ) ), 1, 3 ) '" "'
        string( trim( ub.currency.curr-name ), "x(12)" ) '" ' .
        one-val = one-rubl / ( t-cs.exch-rate / t-cs.exch-scale ).
        assign
        ii = 0
        dec-buf = one-val .
        right-curs = ( if dec-buf > 1 then TRUE else FALSE ) .
        if dec-buf > 1 then
        DO WHILE dec-buf >= 10 :
          assign
          dec-buf = dec-buf / 10
          ii = ii + 1 .
        END .
        else
        DO WHILE dec-buf < 1 :
          assign
          dec-buf = dec-buf * 10
          ii = ii + 1 .
        END .
        put stream Ibmstream unformatted
        string( string( dec-buf , "9.999999999" ) + "E" +
                ( if right-curs then "+" else "-" ) + string( ii, "999" ) )
        " ":U string(rnd-znak, "9") " ":U /* кол-во знаков после запятой на чеке */
        .
        if currency.curr-code = 0 then
        put stream Ibmstream unformatted
        string( string( 1, ">>>>9.99" ) + " ":U + string( 1, ">>9" ) )
        space(1)
        ( if Cash-OS2
          then
          string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
          else "":U )  skip .
        else do:
          if ( t-cs.bexch-rate / t-cs.bexch-scale ) * temp-scale < 100000.00 then
          put stream Ibmstream unformatted
          string( string( t-cs.bexch-rate / t-cs.bexch-scale * temp-scale /** one-rubl*/ ,
                          ">>>>9.99" ) + " " +
                  string( temp-scale, ">>9" ) )
          space(1)
          ( if Cash-OS2
            then
            string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
            else "":U )  skip .
          else
          put stream Ibmstream unformatted
          string( string( t-cs.bexch-rate / t-cs.bexch-scale /* * one-rubl*/ , ">>>>9.99" ) +
          " ":U + string( 1, ">>9" ) )
          space(1)
          ( if Cash-OS2
            then
            string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
            else "":U )  skip .
        end.
      end. /* else    /* if v-curr-r-b = {&r-b-rubl} ... */ */
    END . /*each currency*/
    put stream Ibmstream unformatted "1 -2":U skip.
  end.
  when {&cd-type-ibm-xml} then do:
    for each currency no-lock,
        FIRST t-cs WHERE
            t-cs.curr-code = currency.curr-code NO-LOCK :
      run bgelib-tag-open in this-procedure ( input 2, input "Currency", input substitute("ctrl='&1' tms='&2' code='&3'"
                                                                                          , (if action = "U":U
                                                                                             then "ADD":U
                                                                                             else "DEL":U)
                                                                                          , OS2-time
                                                                                          , (if ub.currency.curr-code = 0
                                                                                             then kassa-rub-code
                                                                                             else ub.currency.curr-code))).
      run bgelib-tag-put in this-procedure ( input 3, input "CurrencyShort"       , input ub.currency.curr-abbr, input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CurrencyName"        , input ub.currency.curr-name, input 1 ).

      if v-curr-r-b = {&r-b-rubl}
      or (v-curr-r-b = {&r-b-base}
         and v-base-code = 0
         )
      then do:
        run bgelib-tag-put in this-procedure ( input 3, input "CurrencyRate"        , input string(t-cs.exch-rate / t-cs.exch-scale), input 1 ).
      end.
      else do:
         one-val = one-rubl / ( t-cs.exch-rate / t-cs.exch-scale ).
         run bgelib-tag-put in this-procedure ( input 3, input "CurrencyRate"        , input string(one-val), input 1 ).
      end.
      run bgelib-tag-put in this-procedure ( input 3, input "CurrencyDecimal"     , input string(rnd-znak, "9":U), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CurrencyCBR"         , input string(t-cs.bexch-rate), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CurrencyMCBR"        , input string(t-cs.bexch-scale), input 1 ).
      run bgelib-tag-put in this-procedure ( input 3, input "CurrencyOKV"         , input string(t-cs.okv-code), input 1 ).
      run bgelib-tag-open in this-procedure ( input 3, input "CurrencyStatus", input "":U).
      run bgelib-tag-put in this-procedure ( input 4, input "CSBase"
                                                    , input (if ub.currency.curr-code = v-base-code
                                                             and v-curr-r-b  = {&r-b-base}
                                                             then 1
                                                             else 0), input 1 ).
      run bgelib-tag-put in this-procedure ( input 4, input "CSNational"        , input (if ub.currency.curr-code = 0 then 1 else 0), input 1 ).
      run bgelib-tag-close in this-procedure ( input 2, input "CurrencyStatus").
      run bgelib-tag-close in this-procedure ( input 2, input "Currency").
    end.
  end.
  when {&cd-type-omron} then do:
    if right-curs then
    RUN out-right-curs no-error .
    else
    RUN out-back-curs no-error .
    if error-status:error then return "error".
  end. /*when omron*/
  when {&cd-type-omron-new} then do:
    assign
    v-versiond = decimal(p-version) no-error .
    if v-versiond >= 33.0 then do:
      if right-curs then
      RUN out-right-curs-new-format no-error .
      else
      RUN out-back-curs-new-format no-error .
    end.
    else do:
      if right-curs then
      RUN out-right-curs no-error .
      else
      RUN out-back-curs no-error .
    end.
    if error-status:error then return "error".
  end. /*when OMRON-new*/
  when {&cd-type-ipc-servispl} then do:
      s = string( today, "99/99/9999" ) + ',' +
          trim( string( t-cs.exch-rate / t-cs.exch-scale,">>>>9.99" ) ) + ',' +
          trim( string( t-cs.exch-rate / t-cs.exch-scale,">>>>9.99" ) ) .
      put stream ibmstream unformatted s skip.
  end. /*when ipc-servis+*/
END CASE.
END PROCEDURE .
/* $Workfile$ e n d */