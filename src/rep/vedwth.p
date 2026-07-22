block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: vedwth.p $
$Archive: rep/vedwth.p $

Препроводительная ведомость к сумке с денежной наличностью

Автор: Белоусов Илья Александрович
Дата создания: 04/02/08
Author: Ilia Belousov
Creation date: 04/02/08

Input:

Output:

*/
define input parameter parparentproc    as widget-handle    no-undo.
define input parameter p-doc-code       as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: vedwth.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/vedwth.p $":U .
define variable vss-description as character no-undo init "Препроводительная ведомость к сумке с денежной наличностью".
define variable g#report-num              as integer              no-undo .
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/showinf.i     }
{ cmp/r-pril.i new  }
{ cmp/r-page1.i new }
{ gbl/cur-time.i    }
{ gbl/prn-lib.i     }
{ gbl/paramls.i     }

define buffer buf_wth-doc     for ub.wth-doc .

define stream out-stream.



/* число прописью */
FUNCTION f-wp-qnty returns character ( INPUT p-dec as decimal ) :
  define variable pr as character no-undo .

  run rep/wp-qnty.p ( input p-dec, output Pr ).
  if Pr = '' then do:
     Pr = 'Ноль'.
  end.
  RETURN ( Pr ) .
END FUNCTION. /* f-wp-qnty */


DO
ON ERROR UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
:

   run get-report-num in parparentproc (output g#report-num).
   run get-quest-print in parparentproc ( output g#quest-print ).
   { rep/vedwthxl.i }

   FIND FIRST buf_wth-doc
      WHERE buf_wth-doc.doc-code = p-doc-code
      NO-LOCK
      NO-ERROR
      .
   IF NOT AVAILABLE buf_wth-doc
   THEN DO:
      MESSAGE
         "Не найден документ" p-doc-code
         SKIP
      VIEW-AS ALERT-BOX ERROR.
      RETURN ERROR SUBSTITUTE("Не найден документ &1", p-doc-code).
   END.


   run calc-summ     IN THIS-PROCEDURE ( INPUT p-doc-code ) .

   run open-stream   IN THIS-PROCEDURE .

   run print-header  IN THIS-PROCEDURE .

   run print-body    IN THIS-PROCEDURE .

   run print-footer  IN THIS-PROCEDURE .

   run close-stream  IN THIS-PROCEDURE .

end.




/*==========================================================================*/
procedure calc-summ :
define input parameter p-doc-code       as character        no-undo.

define variable v-curr-name    as character    no-undo.
define variable v-okv-code    as integer      no-undo.
define variable v-curr-num    as integer      no-undo.
define variable v-ok    as logical      no-undo.

define buffer buf_wth-line    for ub.wth-line .
define buffer buf_wth-dtl     for ub.wth-dtl .
define buffer buf_wth-par     for ub.wth-par .
define buffer buf_wealth      for ub.wealth .
define buffer buf_currency    for ub.currency .
define buffer buf_tt-summ     for tt-summ .
define buffer buf_tt-line     for tt-line .

do
on error undo, return error
:

   FOR EACH buf_wth-line
      WHERE buf_wth-line.doc-code   = p-doc-code
      NO-LOCK
      ,
      FIRST buf_wealth
      WHERE buf_wealth.wth-code     = buf_wth-line.wth-code
        AND buf_wealth.is-money     = YES
      NO-LOCK
      BREAK BY buf_wealth.curr-code
      :
      IF FIRST-OF (buf_wealth.curr-code)
      THEN DO:
         FIND FIRST buf_currency
              WHERE buf_currency.curr-code = buf_wealth.curr-code
              NO-LOCK
              NO-ERROR
              .

         CREATE buf_tt-summ.
         ASSIGN
            buf_tt-summ.curr-code = buf_wealth.curr-code
            v-curr-num = v-curr-num + 1
         .
         IF NOT AVAILABLE buf_currency
         THEN DO:
            ASSIGN
               buf_tt-summ.curr-abbr = "???":U
               buf_tt-summ.part-abbr = "???":U
               buf_tt-summ.okv-code  = 0
            .
         END.
         ELSE DO:
            ASSIGN
               buf_tt-summ.curr-abbr = buf_currency.curr-abbr
               buf_tt-summ.part-abbr = buf_currency.part-abbr
               buf_tt-summ.okv-code  = buf_currency.okv-code
            .
         END.

      END. /*FIRST-OF*/

      ASSIGN
         buf_tt-summ.curr-summ = buf_tt-summ.curr-summ + buf_wth-line.fact-sum
      .
   End. /* EACH buf_wth-line */
   IF v-curr-num > 2
   THEN DO:
      message
         "В документе присутствует более двух валют."
         skip "В шапке документа не поместятся все суммы прописью."
         SKIP "Продолжить?"
      view-as alert-box question buttons YES-NO update v-ok.
      IF NOT v-ok
      THEN DO:
         RETURN ERROR "В документе присутствует более двух валют." .
      END.
   END.

   FOR EACH buf_wth-dtl
      WHERE buf_wth-dtl.doc-code = p-doc-code
      NO-LOCK
      ,
      FIRST buf_wth-par
      WHERE buf_wth-par.wth-code = buf_wth-dtl.wth-code
        AND buf_wth-par.par-code = buf_wth-dtl.par-code
      NO-LOCK
      ,
      FIRST buf_wealth
      WHERE buf_wealth.wth-code  = buf_wth-dtl.wth-code
        AND buf_wealth.is-money  = YES
      NO-LOCK
      /*
      BREAK BY buf_wealth.curr-code
      */
      :
      FIND FIRST buf_tt-line
           WHERE buf_tt-line.curr-code = buf_wealth.curr-code
             AND buf_tt-line.wth-code  = buf_wth-dtl.wth-code
             AND buf_tt-line.par-code  = buf_wth-dtl.par-code
           EXCLUSIVE-LOCK
           NO-ERROR
           .
      IF NOT AVAILABLE buf_tt-line
      THEN DO:
         FIND FIRST buf_currency
              WHERE buf_currency.curr-code = buf_wealth.curr-code
              NO-LOCK
              NO-ERROR
              .
         IF NOT AVAILABLE buf_currency
         THEN DO:
            /*
            MESSAGE
               "Не найдена валюта с кодом" buf_wealth.curr-code
               SKIP
            VIEW-AS ALERT-BOX ERROR.
            */
            ASSIGN
               v-curr-name = "Не найдена"
               v-okv-code = 000
            .
         END.
         ELSE DO:
            ASSIGN
               v-curr-name = buf_currency.curr-name
               v-okv-code = buf_currency.okv-code
            .
         END.

         CREATE buf_tt-line.
         ASSIGN
            buf_tt-line.curr-code = buf_wealth.curr-code
            buf_tt-line.okv-code  = v-okv-code
            buf_tt-line.wth-code  = buf_wth-dtl.wth-code
            buf_tt-line.par-code  = buf_wth-dtl.par-code
            buf_tt-line.par-rate  = buf_wth-par.par-rate
            buf_tt-line.par-unit  = buf_wth-par.par-unit
            buf_tt-line.par-val   = buf_wth-par.par-val
            buf_tt-line.curr-name = v-curr-name
         .
      END. /* NOT AVAILABLE */
      ASSIGN
         buf_tt-line.summ = buf_tt-line.summ + buf_wth-dtl.fact-sum
      .
   End. /* EACH buf_wth-dtl */
end. /* do on error */
end procedure. /* calc-summ */




/*==========================================================================*/
procedure open-stream :

do
on error undo, return error
:

    { gbl/working.i }

    { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

    put stream out-stream unformatted
          {&new-line}
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + {&new-line}
    .
    output stream out-stream close.

    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
    output close.

    run vedwthxl-init in this-procedure.

end. /* do on error */
end procedure. /* open-stream */




/*==========================================================================*/
procedure print-header :

do
on error undo, return error
:
    define variable v-object    as character    no-undo.
    define variable v-firm      as character    no-undo.
    define variable v-host-code as integer    no-undo.
    define variable v-client    as character    no-undo.
    define variable v-bank      as character    no-undo.
    define variable v-schet     as character    no-undo.
    define variable v-collect   as character    no-undo.

    define buffer buf_fin-bank      for ub.fin-bank .
    define buffer buf_fin-schet     for ub.fin-schet .
    define buffer buf_fin-bank-attr for ub.fin-bank-attr .
    define buffer buf_clients       for ub.clients .
    define buffer buf_tt-summ       for tt-summ .

    /* объект, он же - отправитель */
    find first buf_clients
         where buf_clients.obj-type = buf_wth-doc.obj-type
           and buf_clients.obj-code = buf_wth-doc.obj-code
         no-lock
         no-error
         .
    IF AVAILABLE buf_clients
    THEN DO:
      /* фирма объектаи ее счета */
      assign
         v-host-code = buf_clients.host-code
         v-object = buf_clients.obj-name
      .
      find first buf_clients
            where buf_clients.obj-type = {&cmp}
            and buf_clients.obj-code   = v-host-code
            no-lock
            no-error
            .
      IF AVAILABLE buf_clients
      THEN DO:
         assign
            v-firm = buf_clients.obj-name
         .
      END.
      /* счет, !!! первый попавшийся, прописать атрибут счета по умолчанию */
      FIND FIRST buf_fin-schet
            WHERE buf_fin-schet.host-code = v-host-code
           no-lock
           no-error
           .
      IF NOT AVAILABLE buf_fin-schet
      THEN DO:
         MESSAGE
            "У организации" v-host-code "не найдено ни одного счета"
            SKIP
         VIEW-AS ALERT-BOX ERROR.
         RETURN ERROR SUBSTITUTE("У организации &1 не найдено ни одного счета", v-host-code).
      END.
      FIND FIRST buf_fin-bank
           WHERE buf_fin-bank.host-code = v-host-code
             and buf_fin-bank.code-bank = buf_fin-schet.code-bank
           no-lock
           no-error
           .
      IF AVAILABLE buf_fin-bank
      THEN DO:
            assign
               v-bank  =  buf_fin-bank.bank-name
               v-schet =  buf_fin-schet.r-schet
            .
      END.
      FIND FIRST buf_fin-bank-attr
           where buf_fin-bank-attr.host-code  = v-host-code
             and buf_fin-bank-attr.code-bank  = buf_fin-schet.code-bank
             and buf_fin-bank-attr.attr-code  = "collect-debt":U  /* !!! ? str-glbl, ?? ????? ?????? */
           no-lock
          no-error
          .
      IF AVAILABLE buf_fin-bank-attr
      THEN DO:
         assign
            v-collect = buf_fin-bank-attr.attr-value
         .

      end.
    END.
    /*
    find first buf_clients
         where buf_clients.obj-type = buf_wth-doc.cli-type
           and buf_clients.obj-code = buf_wth-doc.cli-code
         no-lock
         no-error
         .

    IF AVAILABLE buf_clients
    THEN DO:
      assign
         v-client = "Реализация в банк" /* !!! buf_clients.obj-name */
      .
    END.
    */


    /* первый лист */
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet1-date1}
        , input buf_wth-doc.doc-date
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet1-date2}
        , input buf_wth-doc.doc-date
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet1-from}
        , input v-object
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet1-to}
        , input v-firm
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet1-bank-to}
        , input v-bank
    ).

    /* 1-ая строка */
    FIND FIRST buf_tt-summ NO-ERROR.
    IF AVAILABLE buf_tt-summ
    THEN DO:
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet1-summ_1}
         , input SUBSTITUTE( "&1 &2 &3 &4 (&5)"
                           , f-wp-qnty(TRUNCATE(buf_tt-summ.curr-summ, 0))
                           , buf_tt-summ.curr-abbr
                           , STRING(TRUNCATE((buf_tt-summ.curr-summ - TRUNCATE(buf_tt-summ.curr-summ, 0)) * 100, 0), "99")
                           , buf_tt-summ.part-abbr
                           , buf_tt-summ.okv-code
                           )
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet1-summ_3}
         , input STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet1-summ_5}
         , input STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet1-symb_5}
         , input "02"
      ).
    END.



    /* 2-ая строка */
    FIND NEXT buf_tt-summ no-error.
    IF AVAILABLE buf_tt-summ
    THEN DO:
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet1-summ_2}
         , input SUBSTITUTE( "&1 &2 &3 &4 (&5)"
                           , f-wp-qnty(TRUNCATE(buf_tt-summ.curr-summ, 0))
                           , buf_tt-summ.curr-abbr
                           , STRING(TRUNCATE((buf_tt-summ.curr-summ - TRUNCATE(buf_tt-summ.curr-summ, 0)) * 100, 0), "99")
                           , buf_tt-summ.part-abbr
                           , buf_tt-summ.okv-code
                           )
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet1-summ_4}
         , input  STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet1-summ_6}
         , input  STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet1-symb_6}
         , input "02"
      ).
    END.

    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet1-account_dbt}
        , input v-collect
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet1-account_krd}
        , input v-schet
    ).




    /* второй лист */
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet2-date1}
        , input buf_wth-doc.doc-date
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet2-date2}
        , input buf_wth-doc.doc-date
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet2-from}
        , input v-object
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet2-to}
        , input v-firm
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet2-bank-to}
        , input v-bank
    ).

    /* 1-ая строка */
    FIND FIRST buf_tt-summ no-error.
    IF AVAILABLE buf_tt-summ
    THEN DO:
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet2-summ_1}
         , input SUBSTITUTE( "&1 &2 &3 &4 (&5)"
                           , f-wp-qnty(TRUNCATE(buf_tt-summ.curr-summ, 0))
                           , buf_tt-summ.curr-abbr
                           , STRING(TRUNCATE((buf_tt-summ.curr-summ - TRUNCATE(buf_tt-summ.curr-summ, 0)) * 100, 0), "99")
                           , buf_tt-summ.part-abbr
                           , buf_tt-summ.okv-code
                           )
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet2-summ_3}
         , input STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet2-summ_5}
         , input STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet2-symb_5}
         , input "02"
      ).
    END.



    /* 2-ая строка */
    FIND NEXT buf_tt-summ  no-error.
    IF AVAILABLE buf_tt-summ
    THEN DO:
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet2-summ_2}
         , input SUBSTITUTE( "&1 &2 &3 &4 (&5)"
                           , f-wp-qnty(TRUNCATE(buf_tt-summ.curr-summ, 0))
                           , buf_tt-summ.curr-abbr
                           , STRING(TRUNCATE((buf_tt-summ.curr-summ - TRUNCATE(buf_tt-summ.curr-summ, 0)) * 100, 0), "99")
                           , buf_tt-summ.part-abbr
                           , buf_tt-summ.okv-code
                           )
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet2-summ_4}
         , input  STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet2-summ_6}
         , input  STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet2-symb_6}
         , input "02"
      ).
    END.

    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet2-account_dbt}
        , input v-collect
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet2-account_krd}
        , input v-schet
    ).



    /* третий лист */
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet3-date1}
        , input buf_wth-doc.doc-date
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet3-from}
        , input v-object
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet3-to}
        , input v-firm
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet3-bank-to}
        , input v-bank
    ).

    /* 1-ая строка */
    FIND FIRST buf_tt-summ no-error.
    IF AVAILABLE buf_tt-summ
    THEN DO:
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet3-summ_1}
         , input SUBSTITUTE( "&1 &2 &3 &4 (&5)"
                           , f-wp-qnty(TRUNCATE(buf_tt-summ.curr-summ, 0))
                           , buf_tt-summ.curr-abbr
                           , STRING(TRUNCATE((buf_tt-summ.curr-summ - TRUNCATE(buf_tt-summ.curr-summ, 0)) * 100, 0), "99")
                           , buf_tt-summ.part-abbr
                           , buf_tt-summ.okv-code
                           )
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet3-summ_3}
         , input STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet3-summ_5}
         , input STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet3-symb_5}
         , input "02"
      ).
    END.



    /* 2-ая строка */
    FIND NEXT buf_tt-summ  no-error.
    IF AVAILABLE buf_tt-summ
    THEN DO:
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet3-summ_2}
         , input SUBSTITUTE( "&1 &2 &3 &4 (&5)"
                           , f-wp-qnty(TRUNCATE(buf_tt-summ.curr-summ, 0))
                           , buf_tt-summ.curr-abbr
                           , STRING(TRUNCATE((buf_tt-summ.curr-summ - TRUNCATE(buf_tt-summ.curr-summ, 0)) * 100, 0), "99")
                           , buf_tt-summ.part-abbr
                           , buf_tt-summ.okv-code
                           )
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet3-summ_4}
         , input  STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet3-summ_6}
         , input  STRING(buf_tt-summ.curr-summ, ">>>,>>9.99")
      ).
      run vedwthxl-write-cell-data in this-procedure (
            input {&vedwthxl-sheet3-symb_6}
         , input "02"
      ).
    END.

    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet3-account_dbt}
        , input v-collect
    ).
    run vedwthxl-write-cell-data in this-procedure (
          input {&vedwthxl-sheet3-account_krd}
        , input v-schet
    ).


end. /* do on error */
end procedure. /* print-header */




/*==========================================================================*/
procedure print-body :

do
on error undo, return error
:
   run vedwthxl-sheet1-write-line-data in this-procedure.

   run vedwthxl-sheet2-write-line-data in this-procedure.

end. /* do on error */
end procedure. /* print-body */




/*==========================================================================*/
procedure print-footer :

do
on error undo, return error
:

end. /* do on error */
end procedure. /* print-footer */




/*==========================================================================*/
procedure close-stream :

do
on error undo, return error
:
    { gbl/stopwork.i }
    run vedwthxl-close in this-procedure .
    /*
    os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
    os-rename
        value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
        value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
    .
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical   no-undo .
    define variable DisabledOptions as integer   no-undo .
    define variable v-orient-page as character no-undo .
    run gbl/prnfilen.w (
          input "":U
        , input 8
        , input string(session :temp-directory) + {&DF_Name} + string( g#report-num )
        , input ReportFontNum
        , output v-user-action
        , output v-printed
    ).
    os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
    */
    /* печатаем */
    { rep/q-print.i 4}

end. /* do on error */
end procedure. /* close-stream */