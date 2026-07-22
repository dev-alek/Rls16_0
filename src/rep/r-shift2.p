block-level on error undo, throw.
/*

$Revision: 5c165f2bb314, 1940, rls $
$Author: druban $
$Date: Fri Jul 12 15:14:08 2019 +0300 $
$Workfile: r-shift2.p $
$Archive: rep/r-shift2.p $

печать сменного отчета (ЮКОС лист 2)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/06/07
Author: Dmitry Ukhanov
Creation date: 08/06/07

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/12/06
Author: Dmitry Ukhanov
Creation date: 04/12/06

*/

define input parameter parparentproc            as widget-handle           no-undo .
define input parameter p-parent-handle          as handle                  no-undo .
define input parameter p-log-handle             as handle                  no-undo .
define input parameter p-cont-handle            as handle                  no-undo .
define input parameter p-rebh                   as handle                  no-undo .
define input parameter p-report-id              as character               no-undo .
define input parameter p-xsd-file               as character               no-undo .
define input parameter p-log-file-name          as character               no-undo .
define input parameter p-batch                  as integer                 no-undo .
define input parameter p-codex-id               as integer                 no-undo .
define input parameter p-ruleset-id             as integer                 no-undo .
define input parameter p-obj-type               like ub.clients.obj-type   no-undo .
define input parameter p-obj-code               like ub.clients.obj-code   no-undo .
define input parameter p-z-number-list          as character               no-undo .
define input parameter p-previous-shift-date    as date                    no-undo .
define input parameter p-with-cp-grouping       as logical                 no-undo .

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision: 5c165f2bb314, 1940, rls $":U.
define variable vss-author      as character no-undo initial "$Author: druban $":U.
define variable vss-date        as character no-undo initial "$Date: Fri Jul 12 15:14:08 2019 +0300 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: r-shift2.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/r-shift2.p $":U.
define variable vss-description as character no-undo initial "Печать сменного отчета - лист 2 ":U.

{ cmp/vssrevis.i                }
{ cmp/str-glbl.i                }
{ cmp/library.i                 }
{ cmp/r-page1.i                 }
{ cmp/r-pril.i                  }
{ rep/r-sym.i                   }
{ rep/real-2df.i SHARED treal-2 }
{ rep/real-2df.i " " actreal-2  }
{ rep/icm-2df.i  "NEW SHARED"   }
{ rep/real-2cr.i treal-2        }
{ rep/real-2cr.i actreal-2      }
{ ref/cp-attr.i }
define buffer grptreal-2 for treal-2.
{ rep/real-2cr.i grptreal-2     }
{ rep/rshiftd1.i t "shared"}
{ str/trdcalib.i }


define shared stream PrnLibstream.

define variable pol1  as character no-undo.
define variable pol2  as integer   no-undo.
define variable pol3  as decimal   no-undo.
define variable pol4  as decimal   no-undo.
define variable pol5  as decimal   no-undo.
define variable pol6  as character no-undo.
define variable pol7  as integer   no-undo.
define variable pol8  as character no-undo.
define variable pol9  as decimal   no-undo.
define variable pol10 as decimal   no-undo.
define variable pol11 as decimal   no-undo.
define variable pol12 as decimal   no-undo.
define variable pol13 as character no-undo.
define variable pol14 as decimal   no-undo.
define variable pol15 as decimal   no-undo.
define variable pol16 as decimal   no-undo.
define variable pol17 as decimal   no-undo.
define variable pol18 as decimal   no-undo.
define variable line  as character no-undo.
define variable pol8-excel as character no-undo.

define variable areal-is-pay-qnty1 as decimal   no-undo.
define variable areal-is-pay-qnty2 as decimal   no-undo.
define variable areal-is-pay-netto as decimal   no-undo.
define variable areal-no-pay-qnty1 as decimal   no-undo.
define variable areal-no-pay-qnty2 as decimal   no-undo.
define variable areal-no-pay-netto as decimal   no-undo.
define variable areal-qnty1        as decimal   no-undo.
define variable areal-qnty2        as decimal   no-undo.
define variable areal-netto        as decimal   no-undo.
define variable aincome-qnty1      as decimal   no-undo.
define variable aincome-qnty2      as decimal   no-undo.
define variable loc-real-ii        as integer   no-undo.
define variable curr-real-ii       as integer   no-undo.
define variable loc-income-ii      as integer   no-undo.
define variable jj                 as integer   no-undo.
define variable loc-jj             as integer   no-undo.
define variable main-line          as logical   no-undo.
define variable supp-line          as logical   no-undo.
define variable pay-line           as logical   no-undo.
/* define variable density            as decimal   no-undo. */
define variable rc                 as recid     no-undo.
define variable accum-4            as decimal   no-undo.
define variable accum-5            as decimal   no-undo.
define variable accum-9            as decimal   no-undo.
define variable accum-11           as decimal   no-undo.
define variable accum-13           as decimal   no-undo.
define variable accum-14           as decimal   no-undo.
define variable accum-15           as decimal   no-undo.
define variable accum-16           as decimal   no-undo.
define variable accum-17           as decimal   no-undo.
define variable accum-18           as decimal   no-undo.
define variable acii               as integer   no-undo.
define variable v-grp-name         as character no-undo.
define variable v-grp-code         as integer   no-undo.
define variable v-step             as integer   no-undo.
define variable v-is-pay           as logical   no-undo.
define variable loc-grpii          as integer   no-undo.
define variable v-attr-value       as character no-undo.
define variable v-attr-type        as character no-undo.

/* количество записей итогов по группе платежей по товару в которых количество типов платежей > 1*/
define variable loc-grp-only-not-single as integer no-undo .
/*количестов записей итогов по группам в которых количество типов платежей = 1 - их мы не выводим*/
/*на это количество будет смещено соответствие tincome-2.ii и treal-2.ii в одной строчке*/
define variable v-delta            as integer no-undo .
define buffer buf_shift-pgds for shift-pgdst.
define buffer buf_shift-pgds-in for shift-pgds-int.
define buffer buf_shift-pgds-out for shift-pgds-outt.
define buffer buf_cash-pay for ub.cash-pay.

{ rep/r-shfth.i proc-def }
{ rep/r-shfth.i r-shift2 }

/*получение кода группы кассового платежа*/
FUNCTION get-grp-name-code RETURNS INTEGER
  ( INPUT p-cdpay-code AS integer, INPUT p-curr-code AS INTEGER, output p-grp-name as character ) :
DEFINE VARIABLE v-dopi AS INTEGER NO-UNDO INIT ?.
DEFINE VARIABLE v-value AS character NO-UNDO.
DEFINE VARIABLE v-type AS character NO-UNDO.
  RUN cp-attr-value  IN THIS-PROCEDURE(
     input p-cdpay-code
    ,input p-curr-code
    ,input 0 /*p-host-code    */
    ,input '':U /*p-obj-type     */
    ,input 0 /* p-obj-code     */
    ,INPUT {&cp-attr-grp-code}
    ,output v-value
    ,OUTPUT v-type) NO-ERROR.

  IF NOT ERROR-STATUS:ERROR THEN DO:
      ASSIGN
      v-dopi = INTEGER(entry(2, v-value, {&delim-par}))
      p-grp-name = entry(1, v-value, {&delim-par} )
      NO-ERROR.
  END.
  RETURN v-dopi.

END FUNCTION.


&scop All-sym17   sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17
&scop all-sym-pol ~{&All-sym17} pol1 pol2 pol3 pol4 pol5 pol6 pol7 pol8 pol9 pol10 pol11 pol12 pol13 pol14 pol15 pol16 pol17 pol18

DEFINE FRAME FRAME-2
  pol1  COLUMN-LABEL "2.1":C12  FORMAT "x(12)":U        SPACE( 0 )   sym1  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol2  COLUMN-LABEL "2.2":C10  FORMAT  ">>>>>>>>>9":U  SPACE( 0 )   sym2  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol3  COLUMN-LABEL "2.3":C8   FORMAT  ">>>>9.99":U    SPACE( 0 )   sym3  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol4  COLUMN-LABEL "2.4":C9   FORMAT "->>>>9.99":U    SPACE( 0 )   sym4  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol5  COLUMN-LABEL "2.5":C9   FORMAT "->>>>>.99":U    SPACE( 0 )   sym5  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol6  COLUMN-LABEL "2.6":C18  FORMAT "x(18)":U        SPACE( 0 )   sym6  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol7  COLUMN-LABEL "2.7":C9   FORMAT ">>>>>>>>9":U    SPACE( 0 )   sym7  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol8  COLUMN-LABEL "2.8":C14  FORMAT "x(14)":U        SPACE( 0 )   sym8  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol9  COLUMN-LABEL "2.9":C8   FORMAT ">>>>9.99":U     SPACE( 0 )   sym9  COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol10 COLUMN-LABEL "2.10":C5  FORMAT "9.9999":U        SPACE( 0 )   sym10 COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol11 COLUMN-LABEL "2.11":C8  FORMAT ">>>>9.99":U     SPACE( 0 )   sym11 COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol12 COLUMN-LABEL "2.12":C6  FORMAT "->9.99":U       SPACE( 0 )   sym12 COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol13 COLUMN-LABEL "2.13":C18 FORMAT "x(18)":U        SPACE( 0 )   sym13 COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol14 COLUMN-LABEL "2.14":C9  FORMAT "->>>>9.99":U    SPACE( 0 )   sym14 COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol15 COLUMN-LABEL "2.15":C9  FORMAT "->>>>9.99":U    SPACE( 0 )   sym15 COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol16 COLUMN-LABEL "2.16":C12 FORMAT "->>>>>>>9.99":U SPACE( 0 )   sym16 COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol17 COLUMN-LABEL "2.17":C9  FORMAT "->>>>9.99":U    SPACE( 0 )   sym17 COLUMN-LABEL ":" FORMAT "x(1)":U SPACE( 0 )
  pol18 COLUMN-LABEL "2.18":C9  FORMAT "->>>>9.99":U    SPACE( 0 )
WITH WIDTH {&DOS_CW_2} DOWN STREAM-IO USE-TEXT NO-BOX.

/* к этому моменту должна быть уже заполнена таблица treal-2 - все записи с is-pay = yes - оплаченный расход */
/* заполним таблицу tincom-2 и treal-2 - в части прочих расходов */
/* соглашения по умолчанию */
/* out-name = "Инвентаризации"       cpay-code = -4 ii = ? is-pay = no */
/* out-name = "Отпуск без ККМ"       cpay-code = -3 ii = ? is-pay = no */
/* out-name = "Технолог.проливы"     cpay-code = -2 ii = ? is-pay = no */
/* out-name = "Прочий докум.расход"  cpay-code = -1 ii = ? is-pay = no */

run rep/r-shft2r.p ( input p-obj-type
                    ,input p-obj-code
                    ,input X-date-Start
                    ,input X-Shift-Start
                    ,input X-date-End
                    ,input X-Shift-End
                    ,input p-previous-shift-date
                    ,input p-batch
                    ,input p-codex-id
                    ,input p-ruleset-id
                    ) no-error.
if error-status:error then do:
  return error substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"
                          ,vss-workfile
                          ,vss-revision
                          ,vss-description
                          ,{&new-line}
                          , error-status:get-message(1)
                          , return-value ).
end.

FORM HEADER
  {&Header-Text2}
WITH FRAME TopFrame WIDTH {&DOS_CW_2} PAGE-TOP NO-LABELS NO-BOX.

VIEW STREAM PrnLibstream FRAME TOpFrame.
for each actreal-2 :
  delete actreal-2 .
end.

/* ЦИКЛ по товарам-топливам */
FOR EACH t-2 USE-INDEX pi :
  assign areal-is-pay-qnty1 = 0
         areal-is-pay-qnty2 = 0
         areal-is-pay-netto = 0
         areal-no-pay-qnty1 = 0
         areal-no-pay-qnty2 = 0
         areal-no-pay-netto = 0
         areal-qnty1        = 0
         areal-qnty2        = 0
         areal-netto        = 0
         aincome-qnty1      = 0
         aincome-qnty2      = 0
         loc-real-ii        = 1
         loc-grpii          = 0
         loc-grp-only-not-single = 0
         loc-income-ii      = 0
  /*     density                 = ? */
         curr-real-ii       = 1.
  /* чтобы прописать ii для тех у кого ii = ? */
  FIND LAST treal-2 NO-LOCK WHERE
            treal-2.gds-code = t-2.gds-code AND
            treal-2.is-pay   = YES          USE-INDEX vi NO-ERROR.
  if available treal-2 then do:
    assign loc-real-ii  = treal-2.ii + 1
           curr-real-ii = treal-2.ii + 1.
  end.
  /* родим записи таблицы treal-2 - подитоги */
  IF CAN-FIND( FIRST treal-2 WHERE
                     treal-2.gds-code = t-2.gds-code ) THEN DO:
    /* если есть вообще оплаченный расход */
    do v-step = 1 to 2:
      if v-step = 1 then assign v-is-pay = yes.
      if v-step = 2 then assign v-is-pay = no .
      FOR EACH treal-2 WHERE treal-2.is-pay = v-is-pay AND treal-2.gds-code = t-2.gds-code and treal-2.curr-code >= 0 USE-INDEX pi :
        assign
          areal-qnty1 = areal-qnty1 + treal-2.qnty1
          areal-qnty2 = areal-qnty2 + treal-2.qnty2
          areal-netto = areal-netto + treal-2.netto
        .
        if treal-2.is-pay = yes then do:
          assign
          areal-is-pay-qnty1 = areal-is-pay-qnty1 + treal-2.qnty1
          areal-is-pay-qnty2 = areal-is-pay-qnty2 + treal-2.qnty2
          areal-is-pay-netto = areal-is-pay-netto + treal-2.netto.

          if p-with-cp-grouping = yes then do:
            /*найдем итоги по группе типов кассовых платежей - если включена галка*/
            assign
            v-grp-code = ?
            v-grp-code = get-grp-name-code(treal-2.cpay-code, treal-2.curr-code, output v-grp-name)
            v-grp-code = (if v-grp-code = ? then 10000 else v-grp-code)
            v-grp-name = (if v-grp-code = 10000
                          then "(По остальным)"
                          else substitute("(По гр. &1)", string(v-grp-name, "X(9)"))
                          )
            .
            FIND FIRST grptreal-2 WHERE
                        grptreal-2.gds-code = treal-2.gds-code AND
                        grptreal-2.cpay-code = - v-grp-code AND
                        grptreal-2.curr-code = - 1 AND
                        grptreal-2.is-pay = treal-2.is-pay NO-ERROR.
            if not available grptreal-2 then do:
              /*увеличим кол-во записей расхода всего и кол-во записей оплаченного расхода*/
              run create-treal-2 in this-procedure ( input treal-2.gds-code,
                                                        input - v-grp-code,
                                                        input - 1 ,
                                                        input treal-2.qnty1,
                                                        input treal-2.qnty2,
                                                        input treal-2.netto,
                                                        input  {&delim-par} + v-grp-name, /*создаем с странным именем - имя прописываем только если платежей в группе больше двух*/
                                                        input treal-2.is-pay,
                                                        input loc-real-ii ) no-error.
              assign
              curr-real-ii = curr-real-ii + 1
              loc-grp-only-not-single = loc-grp-only-not-single + 1
              loc-real-ii = loc-real-ii + 1
              loc-grpii       = loc-grpii + 1
              .
            end.
            else do:
              assign
              loc-grp-only-not-single = (if grptreal-2.out-name  begins {&delim-par}
                                     then (loc-grp-only-not-single - 1)
                                     else loc-grp-only-not-single)
              grptreal-2.out-name = v-grp-name
              grptreal-2.qnty1 = grptreal-2.qnty1 + treal-2.qnty1
              grptreal-2.qnty2 = grptreal-2.qnty2 + treal-2.qnty2
              grptreal-2.netto = grptreal-2.netto + treal-2.netto
              .
            end.
            /*в ii пишем кол-во записей по данной группе*/
            /*идем по pi поэтому сначала обработаются те где is-pay = no*/
          end.  /*if p-with-cp-grouping then do:*/
        end.
        else do:
          assign /* treal-2.qnty2 = ( if treal-2.cpay-code = -3 then treal-2.qnty2 else treal-2.qnty1 * density ) */
                rc            = recid( treal-2 )
          curr-real-ii         = ( if (curr-real-ii = loc-real-ii)
                                   AND /* первый проход */
                                    ( (loc-real-ii - loc-grp-only-not-single) > 1 /* оплаченные были и есть неоплач раз мы здесь */
                                    OR
                                    can-find( first treal-2 no-lock where
                                                    treal-2.gds-code =  t-2.gds-code and
                                                    treal-2.is-pay   =  no           and
                                                    recid( treal-2 ) <> rc ) )
                                  then ( curr-real-ii + 1 )
                                  else   curr-real-ii )
          treal-2.ii           = curr-real-ii
          curr-real-ii         = curr-real-ii + 1.
          if treal-2.cpay-code <> -4 then do: /* инвентаризацию не включаем */
            assign areal-no-pay-qnty1 = areal-no-pay-qnty1 + treal-2.qnty1
                  areal-no-pay-qnty2 = areal-no-pay-qnty2 + treal-2.qnty2
                  areal-no-pay-netto = areal-no-pay-netto + treal-2.netto.
          end.
        end.
      end. /* for each treal-2 */
    END.
    if curr-real-ii - loc-grp-only-not-single > 2 then do:
      /* treal-2 большей одной */
      /* рожаем запись ИТОГО ОПЛАЧ.РАСХОД */
      run create-treal-2 in this-procedure ( input t-2.gds-code,
                                             input 0,
                                             input 0,
                                             input areal-is-pay-qnty1,
                                             input areal-is-pay-qnty2,
                                             input areal-is-pay-netto,
                                             input "ИТОГО ОПЛАЧ.РАСХОД",
                                             input yes,
                                             input loc-real-ii           ) no-error.
      /* рожаем запись ИТОГО ПРОЧ.РАСХОДОВ */
      /* если не было прочих расходов - переведем счетчик */
      if loc-real-ii = curr-real-ii then do:
        assign curr-real-ii = curr-real-ii + 1.
      end.
      run create-treal-2 in this-procedure ( input t-2.gds-code,
                                             input 0,
                                             input 0,
                                             input areal-no-pay-qnty1,
                                             input areal-no-pay-qnty2,
                                             input areal-no-pay-netto,
                                             input "ИТОГО ПРОЧ.РАСХОД",
                                             input no,
                                             input curr-real-ii         ) no-error.
      assign curr-real-ii = curr-real-ii + 1.
      run create-treal-2 in this-procedure ( input t-2.gds-code,
                                             input 0,
                                             input 0,
                                             input areal-qnty1,
                                             input areal-qnty2,
                                             input areal-netto,
                                             input "ВСЕГО РАСХОД ",
                                             input ?,
                                             input curr-real-ii     ) no-error.
    end. /* if curr-real-ii > 2 */
  END. /* IF CAN-FIND FIRST treal-2 */
  /* родим записи таблицы tincome-2 - итоги */
  /* если есть вообще оплаченный расход */
  FOR EACH tincome-2 WHERE
           tincome-2.gds-code = t-2.gds-code
           USE-INDEX vi
           :
    if tincome-2.supp-name = "Итого по поставщику" then do:
      assign loc-income-ii = tincome-2.ii .
      next.
    end.
    assign aincome-qnty1 = aincome-qnty1 + tincome-2.qnty1
           aincome-qnty2 = aincome-qnty2 + tincome-2.qnty2
           loc-income-ii = tincome-2.ii
           .
  END.
  if loc-income-ii > 1 then do:
    /* tincome-2 большей одной */
    /* рожаем запись ИТОГО ОПЛАЧ.РАСХОД */
    run create-tincome-2 in this-procedure ( input t-2.gds-code,
                                             input "",
                                             input aincome-qnty1,
                                             input aincome-qnty2,
                                             input "ИТОГО ПОСТУПЛЕНИЙ",
                                             input 0,
                                             input no,
                                             input ( loc-income-ii + 1 ) ) no-error.
    assign loc-income-ii = loc-income-ii + 1.
  end.
  assign t-2.lines = MAX( curr-real-ii - loc-grp-only-not-single
        /*исключим из счетчика записи по группам типов платежей с пустым названием - это означает - что
         платежей в группе = 1 и итоги по группе выводить не надо
          */
                        , loc-income-ii, 1 ).
END. /* FOR EACH t-2 */
{&PutExcel} skip.

/* непосредственно печать */
FOR EACH t-2 NO-LOCK
    BREAK
      BY t-2.main-code :
  v-delta = 0.
  DO jj = 1 TO t-2.lines :
    assign pol1      = "":U
           pol2      = 0
           pol3      = 0
           pol4      = 0
           pol5      = 0
           pol6      = "":U
           pol7      = 0
           pol8      = "":U
           pol9      = 0
           pol10     = 0
           pol11     = 0
           pol12     = ?
           pol13     = "":U
           pol14     = 0
           pol15     = 0
           pol16     = 0
           pol17     = 0
           pol18     = 0
           main-line = no
           supp-line = no
           pay-line  = no.
    IF jj = 1 then do:
      assign pol1      = t-2.gds-name
             pol2      = t-2.main-code
             pol3      = t-2.last-price
             pol4      = t-2.qnty1-before
             pol5      = t-2.qnty2-before
             pol17     = t-2.qnty1-after
             pol18     = t-2.qnty2-after
             main-line = yes.
      if p-batch > 0
      and p-report-id  = "53/2040"
      then do:
        find first buf_shift-pgds where
                buf_shift-pgds.obj-type = p-obj-type
            and buf_shift-pgds.obj-code = p-obj-code
            and buf_shift-pgds.shift-date = X-date-end
            and buf_shift-pgds.shift-num = X-shift-end
            and buf_shift-pgds.gds-code = t-2.gds-code no-error.
        if available buf_shift-pgds then do:
          assign
          buf_shift-pgds.end-price-sale = t-2.last-price
          .
          release buf_shift-pgds.
        end.
      end.
    END.
    FIND FIRST tincome-2 NO-LOCK WHERE
               tincome-2.gds-code = t-2.gds-code AND
               tincome-2.ii       = jj           NO-ERROR.
    IF AVAIlABLE tincome-2 THEN DO:
      /* номер документа из атрибутов */
      { str/tdat-val.i
        tincome-2.doc-code
        {&trdcattr-nids}
        v-attr-value
        v-attr-type
        }
      assign
        pol8 = if v-attr-value = "" or v-attr-value = ?
               then tincome-2.doc-code
               else v-attr-value
        pol8-excel = if v-attr-value = "" or v-attr-value = ?
               then tincome-2.doc-code
               else '="' + v-attr-value + '"'
      .

      ASSIGN pol6      = tincome-2.supp-name
             pol7      = tincome-2.supp-code
             pol9      = tincome-2.qnty1
             pol10     = tincome-2.density
             pol11     = tincome-2.qnty2
             pol12     = tincome-2.temperature
             supp-line = yes.
     if p-batch > 0
     and tincome-2.supp-code > 0
     and tincome-2.gds-code > 0
     and p-report-id  = "53/2040"
     then do:
      find first buf_shift-pgds-in where
                buf_shift-pgds-in.obj-type = p-obj-type
            and buf_shift-pgds-in.obj-code = p-obj-code
            and buf_shift-pgds-in.shift-date = X-date-end
            and buf_shift-pgds-in.shift-num = X-shift-end
            and buf_shift-pgds-in.gds-code = t-2.gds-code
            and buf_shift-pgds-in.doc-code = tincome-2.doc-code no-error.
        if not available buf_shift-pgds-in then do:
          create buf_shift-pgds-in.
          assign
          buf_shift-pgds-in.obj-type = p-obj-type
          buf_shift-pgds-in.obj-code = p-obj-code
          buf_shift-pgds-in.shift-date = X-date-end
          buf_shift-pgds-in.shift-num = X-shift-end
          buf_shift-pgds-in.gds-code = t-2.gds-code
          buf_shift-pgds-in.doc-code = tincome-2.doc-code
          buf_shift-pgds-in.cli-type-code = substitute("&1&2", tincome-2.supp-type, tincome-2.supp-code)
          buf_shift-pgds-in.cli-name = tincome-2.supp-name
          buf_shift-pgds-in.fact-qnty = tincome-2.qnty1
          buf_shift-pgds-in.fact-qnty-2 = tincome-2.qnty2
          .
          release buf_shift-pgds-in.
        end.
      end.
    END.
   _not-empty-group:
    do while true :
      FIND FIRST treal-2 NO-LOCK WHERE
                treal-2.gds-code = t-2.gds-code AND
                treal-2.ii       = jj + v-delta          NO-ERROR.
      if not available treal-2  then leave _not-empty-group.
      if available treal-2 then do:
        if treal-2.cpay-code <> 0
        or treal-2.curr-code= - 1
        then do:
          FIND FIRST actreal-2 WHERE
                    actreal-2.gds-code = 0 AND
                    actreal-2.cpay-code = treal-2.cpay-code AND
                    actreal-2.curr-code = treal-2.curr-code AND
                    actreal-2.is-pay = treal-2.is-pay NO-ERROR.
          if not available actreal-2 then do:
            assign acii = acii + 1.
            run create-actreal-2 in this-procedure ( input 0,
                                                    input treal-2.cpay-code,
                                                    input treal-2.curr-code,
                                                    input treal-2.qnty1,
                                                    input treal-2.qnty2,
                                                    input treal-2.netto,
                                                    input trim(treal-2.out-name, {&delim-par}),
                                                    input treal-2.is-pay,
                                                    input acii               ) no-error.
          end.
          else do:
            assign actreal-2.qnty1 = actreal-2.qnty1 + treal-2.qnty1
                  actreal-2.qnty2 = actreal-2.qnty2 + treal-2.qnty2
                  actreal-2.netto = actreal-2.netto + treal-2.netto.
          end.
        end.
        /*итоги по платежу*/
        if treal-2.is-pay = yes
        and treal-2.curr-code < 0
        and treal-2.out-name begins {&delim-par} then do:
          assign
          v-delta = v-delta + 1
          .
          next _not-empty-group.
        end.
        else do:
          assign
          pol13    = treal-2.out-name
          pol14    = treal-2.qnty1
          pol15    = treal-2.qnty2
          pol16    = treal-2.netto
          pay-line = yes
          .
          if p-batch > 0
        and (treal-2.curr-code > 0
        or not (treal-2.curr-code = 0 and treal-2.cpay-code = 0)
        )
        and treal-2.gds-code > 0
          and p-report-id  = "53/2040"
        then do:
          find first buf_shift-pgds-out where
                buf_shift-pgds-out.obj-type = p-obj-type
            and buf_shift-pgds-out.obj-code = p-obj-code
            and buf_shift-pgds-out.shift-date = X-date-end
            and buf_shift-pgds-out.shift-num = X-shift-end
            and buf_shift-pgds-out.gds-code = treal-2.gds-code
              and buf_shift-pgds-out.pay-code = treal-2.cpay-code
              and buf_shift-pgds-out.curr-code = treal-2.curr-code
              no-error.
          if not available buf_shift-pgds-out then do:
              find first buf_cash-pay no-lock where
                        buf_cash-pay.cdpay-code = treal-2.cpay-code
                  and  buf_cash-pay.curr-code = treal-2.curr-code no-error.
              create buf_shift-pgds-out.
            assign
            buf_shift-pgds-out.obj-type = p-obj-type
            buf_shift-pgds-out.obj-code = p-obj-code
            buf_shift-pgds-out.shift-date = X-date-end
            buf_shift-pgds-out.shift-num = X-shift-end
            buf_shift-pgds-out.gds-code = treal-2.gds-code
            buf_shift-pgds-out.pay-code = treal-2.cpay-code
              buf_shift-pgds-out.curr-code = treal-2.curr-code
            buf_shift-pgds-out.out-name = treal-2.out-name
              buf_shift-pgds-out.cp-type = (if available buf_cash-pay
                                            and buf_cash-pay.is-cash
                                            then 1
                                            else 2)
            buf_shift-pgds-out.fact-qnty = treal-2.qnty1
            buf_shift-pgds-out.fact-qnty-2 = treal-2.qnty2
            buf_shift-pgds-out.fact-sum = treal-2.netto
            .
            release buf_shift-pgds-out.
              .
            end. /*if not available buf_shift-pgds-out then do:*/
          end. /*if p-batch > 0 */
          leave _not-empty-group.
          end.
        end.
    end. /*do whiel true*/
    DISPLAY STREAM PrnLibstream pol1
                             pol2  WHEN main-line = yes
                             pol3  WHEN main-line = yes
                             pol4  WHEN main-line = yes
                             pol5  WHEN main-line = yes
                             pol6
                             pol7  WHEN pol7 <> 0
                             pol8  WHEN pol8 <> ""
                             pol9  WHEN supp-line = yes
                             pol10 when supp-line = yes and pol10 <> ? and pol10 > 0
                             pol11 WHEN supp-line = yes
                             pol12 WHEN pol7 <> 0 and pol12 <> ?
                             pol13
                             pol14 WHEN pay-line  = yes
                             pol15 WHEN pay-line  = yes
                             pol16 WHEN pay-line  = yes
                             pol17 WHEN main-line = yes
                             pol18 WHEN main-line = yes
                             {&All-sym17}
    WITH FRAME FRAME-2.
    if jj < t-2.lines then do: down stream PrnLibstream with frame FRAME-2. end.
    if main-line = yes then do:
      assign accum-4  = accum-4  + pol4
             accum-5  = accum-5  + pol5
             accum-17 = accum-17 + pol17
             accum-18 = accum-18 + pol18.
      {&PutExcel} pol1 {&tabulation}
                  pol2 {&tabulation}
                  pol3 {&tabulation}
                  pol4 {&tabulation}
                  pol5 {&tabulation}.
    end.
    else do:
      {&PutExcel} {&tabulation}
                  {&tabulation}
                  {&tabulation}
                  {&tabulation}
                  {&tabulation}.
    end.
    if supp-line = yes then do:
      if tincome-2.is-fact = yes then do:
        assign accum-9  = accum-9  + pol9
               accum-11 = accum-11 + pol11.
      end.
      {&PutExcel} pol6                                                           {&tabulation}
                  ( if pol7 <> 0 then string( pol7  ) else "":U )                {&tabulation}
                  ( if pol8-excel <> "" then pol8-excel else "":U)               {&tabulation}
                  pol9                                                           {&tabulation}
                  ( if pol7 <> 0 and pol10 <> ? then string( pol10 ) else "":U ) {&tabulation}
                  pol11                                                          {&tabulation}
                  ( if pol7 <> 0 and pol12 <> ? then string( pol12 ) else "":U ) {&tabulation}.
    end.
    else do:
      {&PutExcel} {&tabulation}
                  {&tabulation}
                  {&tabulation}
                  {&tabulation}
                  {&tabulation}
                  {&tabulation}
                  {&tabulation}.
    end.
    if pay-line = yes then do:
      if treal-2.cpay-code <> 0
      and treal-2.curr-code <>  - 1
      then do:
      assign accum-14 = accum-14 + pol14
             accum-15 = accum-15 + pol15
             accum-16 = accum-16 + pol16.
      end.
      {&PutExcel} pol13 {&tabulation}
                  pol14 {&tabulation}
                  pol15 {&tabulation}
                  pol16 {&tabulation}.
    end.
    else do:
      {&PutExcel} {&tabulation}
                  {&tabulation}
                  {&tabulation}
                  {&tabulation}.
    end.
    if main-line = yes then do:
      {&PutExcel} pol17 {&tabulation}
                  pol18 skip.
    end.
    else do:
      {&PutExcel} {&tabulation} skip.
    end.
  END. /* DO jj = 1 TO t-2.lines */
  DOWN 1 STREAM PrnLibstream WITH FRAME FRAME-2.
  {&PutExcel} FILL( {&tabulation}, 17 ) skip.
  IF LAST( t-2.main-code ) THEN DO:
    /* печатаем итоги */
    assign pol1  = "ИТОГО"
           pol4  = accum-4
           pol5  = accum-5
           pol9  = accum-9
           pol11 = accum-11
           POL13 = "ИТОГО РАСХОД"
           pol14 = accum-14
           pol15 = accum-15
           pol16 = accum-16
           pol17 = accum-17
           pol18 = accum-18.
    &scop on-same-page_param {&bottom-height} + 2 + acii + ( if acii = 0 then 0 else 1 ) + ~
                             ( if can-find( first actreal-2 where actreal-2.is-pay = yes ) then 1 else 0 ) + ~
                             ( if can-find( first actreal-2 where actreal-2.is-pay = no  ) then 1 else 0 )
    run on-same-page in this-procedure ( input {&on-same-page_param} ) .
    UNDERLINE STREAM PrnLibstream {&ALL-sym-pol} WITH FRAME FRAME-2.
    DISPLAY STREAM PrnLibstream pol1
                             pol4
                             pol5
                             pol9
                             pol11
                             pol13
                             pol14
                             pol15
                             pol16
                             pol17
                             pol18
                             {&All-sym17}
    WITH FRAME FRAME-2.
    {&PutExcel} pol1  {&tabulation}
                      {&tabulation}
                      {&tabulation}
                pol4  {&tabulation}
                pol5  {&tabulation}
                      {&tabulation}
                      {&tabulation}
                      {&tabulation}
                pol9  {&tabulation}
                      {&tabulation}
                pol11 {&tabulation}
                      {&tabulation}
                pol13 {&tabulation}
                pol14 {&tabulation}
                pol15 {&tabulation}
                pol16 {&tabulation}
                pol17 {&tabulation}
                pol18 skip.
    DOWN 1 STREAM PrnLibstream WITH FRAME FRAME-2.
    /* печатаем подитоги по всем расходам по всем топливам */
    if can-find( first actreal-2 no-lock ) then do:
      assign pol13 = "     в том числе:".
      DISPLAY STREAM PrnLibstream pol13 {&All-sym17} WITH FRAME FRAME-2.
      {&PutExcel}       {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                  pol13 {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation}
                        {&tabulation} skip.
      DOWN 1 STREAM PrnLibstream WITH FRAME FRAME-2.
      assign areal-is-pay-qnty1 = 0
             areal-is-pay-qnty2 = 0
             areal-is-pay-netto = 0
             areal-no-pay-qnty1 = 0
             areal-no-pay-qnty2 = 0
             areal-no-pay-netto = 0.
      FOR EACH actreal-2 NO-LOCK
          BREAK
            BY actreal-2.gds-code
            By actreal-2.is-pay    DESCENDING
            BY actreal-2.cpay-code DESCENDING
            BY actreal-2.curr-code :
        if actreal-2.is-pay = yes then do:
          if actreal-2.curr-code >= 0 then
          assign areal-is-pay-qnty1 = areal-is-pay-qnty1 + actreal-2.qnty1
                 areal-is-pay-qnty2 = areal-is-pay-qnty2 + actreal-2.qnty2
                 areal-is-pay-netto = areal-is-pay-netto + actreal-2.netto.
        end.
        else do:
          assign areal-no-pay-qnty1 = areal-no-pay-qnty1 + actreal-2.qnty1
                 areal-no-pay-qnty2 = areal-no-pay-qnty2 + actreal-2.qnty2
                 areal-no-pay-netto = areal-no-pay-netto + actreal-2.netto .
        end.
        assign pol13 = actreal-2.out-name
               pol14 = actreal-2.qnty1
               pol15 = actreal-2.qnty2
               pol16 = actreal-2.netto.
        DISPLAY STREAM PrnLibstream pol13
                                 pol14
                                 pol15
                                 pol16
                                 {&All-sym17}
        WITH FRAME FRAME-2.
        {&PutExcel}       {&tabulation}
                          {&tabulation}
                          {&tabulation}
                          {&tabulation}
                          {&tabulation}
                          {&tabulation}
                          {&tabulation}
                          {&tabulation}
                          {&tabulation}
                          {&tabulation}
                          {&tabulation}
                          {&tabulation}
                    pol13 {&tabulation}
                    pol14 {&tabulation}
                    pol15 {&tabulation}
                    pol16 {&tabulation}
                          {&tabulation} skip.
        DOWN 1 STREAM PrnLibstream WITH FRAME FRAME-2.
        if last-of( actreal-2.is-pay ) /* and actreal-2.is-pay <> ? */ then do:
          if actreal-2.is-pay = yes then do:
            assign pol13 = "ИТОГО ОПЛАЧ.РАСХОД"
                   pol14 = areal-is-pay-qnty1
                   pol15 = areal-is-pay-qnty2
                   pol16 = areal-is-pay-netto.
          end.
          else do:
            assign pol13 = "ИТОГО ПРОЧ.РАСХОД"
                   pol14 = areal-no-pay-qnty1
                   pol15 = areal-no-pay-qnty2
                   pol16 = areal-no-pay-netto.
          end.
          DISPLAY STREAM PrnLibstream pol13
                                   pol14
                                   pol15
                                   pol16
                                   {&All-sym17}
          WITH FRAME FRAME-2.
          {&PutExcel}       {&tabulation}
                            {&tabulation}
                            {&tabulation}
                            {&tabulation}
                            {&tabulation}
                            {&tabulation}
                            {&tabulation}
                            {&tabulation}
                            {&tabulation}
                            {&tabulation}
                            {&tabulation}
                            {&tabulation}
                      pol13 {&tabulation}
                      pol14 {&tabulation}
                      pol15 {&tabulation}
                      pol16 {&tabulation}
                            {&tabulation} skip.
          DOWN 1 STREAM PrnLibstream WITH FRAME FRAME-2.
        end. /* last-of( ctreal-2.is-pay ) and is-pay <> ? */
      END. /* for each actreal-2 */
    END. /* if can-find first actreal */
    UNDERLINE STREAM PrnLibstream {&ALL-sym-pol} WITH FRAME FRAME-2.
  END. /* IF LAST t-2.main-code */
END. /* FOR EACH t-2 */

PROCEDURE create-tincome-2 :
  define input parameter p-gds-code  like ub.goods.gds-code   no-undo.
  define input parameter p-doc-code  like ub.trn-doc.doc-code no-undo.
  define input parameter p-qnty1     as   decimal             no-undo.
  define input parameter p-qnty2     as   decimal             no-undo.
  define input parameter p-supp-name as   character           no-undo.
  define input parameter p-supp-code like ub.clients.obj-code no-undo.
  define input parameter p-is-fact   as   logical             no-undo.
  define input parameter p-ii        as   integer             no-undo.

  _main:
  DO ON ERROR UNDO _main, RETURN ERROR :
    CREATE tincome-2.
    assign tincome-2.gds-code    = p-gds-code
           tincome-2.doc-code    = p-doc-code
           tincome-2.qnty1       = p-qnty1
           tincome-2.qnty2       = p-qnty2
           tincome-2.supp-code   = p-supp-code
           tincome-2.supp-name   = p-supp-name
           tincome-2.is-fact     = p-is-fact
           tincome-2.temperature = ?
           tincome-2.ii          = p-ii        no-error.
    IF ERROR-STATUS :ERROR THEN DO: UNDO _main, RETURN ERROR. END.
  END. /* on error */
END PROCEDURE. /* create-tincome-2 */

