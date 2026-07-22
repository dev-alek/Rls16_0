block-level on error undo, throw.
/*

$Revision: 9b2d0772002d, 3091, rls $
$Author: EShklyar $
$Date: Пт авг 05 19:16:27 2022 +0300 $
$Workfile: r-new-shift2.p $
$Archive: rep/r-new-shift2.p $

печать сменного отчета лист 2

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/06/07
Author: Dmitry Ukhanov
Creation date: 08/06/07

Автор: Булгаков Андрей Николаевич
Дата создания: 04/12/06
Author: Andrew Bulgakoff
Creation date: 04/12/06

*/

define input parameter parparentproc            as widget-handle           no-undo .
define input parameter p-parent-handle          as handle                  no-undo .
define input parameter p-log-handle             as handle                  no-undo .
define input parameter p-cont-handle            as handle                  no-undo .
define input parameter p-rebh                   as handle                  no-undo .
define input parameter v-report-name-html       as character               no-undo .
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
define variable vss-revision    as character no-undo initial "$Revision: 9b2d0772002d, 3091, rls $":U.
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U.
define variable vss-date        as character no-undo initial "$Date: Пт авг 05 19:16:27 2022 +0300 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: r-new-shift2.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/r-new-shift2.p $":U.
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
{ gbl/prn-lib.i     }
{ rep/html-conv.i }


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
define variable pol9_1 as decimal   no-undo. /*Масса ЕУ*/
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
define variable v-delta          as integer no-undo .
define buffer buf_shift-pgds     for shift-pgdst.
define buffer buf_shift-pgds-in  for shift-pgds-int.
define buffer buf_shift-pgds-out for shift-pgds-outt.
define buffer buf_cash-pay       for ub.cash-pay.
/*переменные для вывода отчета в HTML*/
define stream Out-Stream.
define stream OutStr-html.
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
/*шапка таблицы HTML*/

    output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted                                                              
            substitute (                                                                                
          '<tbody> <!-- Здесь начинается таблица отчета -->                                             
            <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->                                 
                <th text_wrap="true" colspan="4" style="text-align: center;">Информация о продукте</th>                  
                <th text_wrap="true" colspan="7" style="text-align: center;">Расшифровка поступления</th>                
                <th text_wrap="true" colspan="4" style="text-align: center;">Расшифровка реализации</th>                 
                <th text_wrap="true" rowspan="3" style="text-align: center;">Остаток на конец кг, л</th>                       
            </tr>                                                                                       
            <tr>                                                                                        
                <th text_wrap="true" rowspan="2" style="text-align: center;">Наименование продукта</th>                  
                <th text_wrap="true" rowspan="2" style="text-align: center;">Код товара</th>                             
                <th text_wrap="true" rowspan="2" style="text-align: center;">Цена розничная на конец смены</th>          
                <th text_wrap="true" rowspan="2" style="text-align: center;">Остаток на начало кг, л</th>                      
                <th text_wrap="true" colspan="2" style="text-align: center;">Поставщик</th>                              
                <th text_wrap="true" rowspan="2" style="text-align: center;">Номер документа прихода (ТТН)</th>          
                <th text_wrap="true" rowspan="2" style="text-align: center;">Количество кг, л</th>
                <th text_wrap="true" rowspan="2" style="text-align: center;">Плотность кг/м3</th>
                <th text_wrap="true" rowspan="2" style="text-align: center;">ЕУ кг</th>                                              
                <th text_wrap="true" rowspan="2" style="text-align: center;">Т в гр.°С</th>         
                <th text_wrap="true" rowspan="2" style="text-align: center;">Тип расхода (тип платежа)</th>              
                <th text_wrap="true" rowspan="2" style="text-align: center;">Кол-во в литрах</th>                        
                <th text_wrap="true" rowspan="2" style="text-align: center;">Кол-во в кг</th>                    
                <th text_wrap="true" rowspan="2" style="text-align: center;">Сумма</th>                                  

            </tr>                                                                                       
            <tr>                                                                                        
                <th text_wrap="true" style="text-align: center;">Наименование</th>                                       
                <th style="text-align: center;">Код</th>                                                
            </tr>                                                                                       
            <tr>                                                                                        
                <th style="text-align: center;">2.1</th>                                                  
                <th style="text-align: center;">2.2</th>                                                  
                <th style="text-align: center;">2.3</th>                                                  
                <th style="text-align: center;">2.4</th>                                                  
                <th style="text-align: center;">2.5</th>                                                  
                <th style="text-align: center;">2.6</th>                                                  
                <th style="text-align: center;">2.7</th>                                                  
                <th style="text-align: center;">2.8</th>                                                  
                <th style="text-align: center;">2.9</th>                                                  
                <th style="text-align: center;">2.10</th>                                                 
                <th style="text-align: center;">2.11</th>                                                 
                <th style="text-align: center;">2.12</th>                                                 
                <th style="text-align: center;">2.13</th>                                                 
                <th style="text-align: center;">2.14</th>                                                 
                <th style="text-align: center;">2.15</th>                                                 
                <th style="text-align: center;">2.16</th>                                                 
            </tr>'                                                                                      
                                                                                                        
            , chr(123), chr(125)                                                                        
        ).                                                                                              


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
/*      /* номер документа из атрибутов */*/
/*      { str/tdat-val.i                  */
/*        tincome-2.doc-code              */
/*        {&trdcattr-nids}                */
/*        v-attr-value                    */
/*        v-attr-type                     */
/*        }                               */
      assign
          pol8 = tincome-2.doc-code

/*        pol8 = if v-attr-value = "" or v-attr-value = ?      */
/*               then tincome-2.doc-code                       */
/*               else v-attr-value                             */
/*        pol8-excel = if v-attr-value = "" or v-attr-value = ?*/
/*               then tincome-2.doc-code                       */
/*               else '="' + v-attr-value + '"'                */
      .

      ASSIGN pol6      = tincome-2.supp-name
             pol7      = tincome-2.supp-code
             pol9      = tincome-2.qnty1
             pol10     = tincome-2.density
             pol9_1    = tincome-2.naturalloss
             pol11     = tincome-2.qnty2
             pol12     = tincome-2.temperature
             supp-line = yes.
     if p-batch > 0
     and tincome-2.supp-code > 0
     and tincome-2.gds-code > 0
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
      if not available treal-2 then do:
        put stream OutStr-html unformatted
            '<tr>' skip
                    '<td text_wrap="true" rowspan="2">' + pol1 + '</td>' skip
                    '<td text_wrap="true" rowspan="2" style="text-align: right;">' + if main-line <> no or string(pol2) <> ? then string(pol2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol3,"->>>>>>>>>>>9.99",2) + '" rowspan="2" style="text-align: right;">' + if main-line <> no or string(pol3) <> ? then fnc-convert-dot-to-colon(pol3,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if main-line <> no or string(pol4) <> ? then fnc-convert-dot-to-colon(pol4,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" rowspan="2">' + if supp-line <> no or pol6 <> ? then pol6 + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" rowspan="2" style="text-align: right;">' + if pol7 <> 0 then string(pol7) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" rowspan="2">' + if pol8 <> "" then string(pol8) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol9,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if supp-line <> no or string(pol9) <> ? then fnc-convert-dot-to-colon(pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.0000" val="' + fnc-convert-dot-to-colon(pol10,"->>>>>>>>>>>9.9999",4) + '" rowspan="2" style="text-align: right;">' + if supp-line <> no or string(pol10) <> ? then fnc-convert-dot-to-colon(pol10,"->>>>>>>>>>>9.9999",4) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(pol9_1,"->>>>>>>>>>>9.999",3) + '" rowspan="2" style="text-align: right;">' + if supp-line <> no or string(pol9_1) <> ? then fnc-convert-dot-to-colon(pol9_1,"->>>>>>>>>>>9.999",3) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0" val="' + fnc-convert-dot-to-colon(pol12,"->>>>>>>>>>>9",0) + '" rowspan="2" style="text-align: right;">' + if supp-line <> no or string(pol12) <> ? then fnc-convert-dot-to-colon(pol12,"->>>>>>>>>>>9",0) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" rowspan="2">' + if pay-line <> no or pol13 <> "" then pol13 + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol14,"->>>>>>>>>>>9.99",2) + '" rowspan="2" style="text-align: right;">' + if pay-line <> no or string(pol14) <> ? then fnc-convert-dot-to-colon(pol14,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol15,"->>>>>>>>>>>9.99",2) + '" rowspan="2" style="text-align: right;">' + if pay-line <> no or string(pol15) <> ? then fnc-convert-dot-to-colon(pol15,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol16,"->>>>>>>>>>>9.99",2) + '" rowspan="2" style="text-align: right;">' + if pay-line <> no or string(pol16) <> ? then fnc-convert-dot-to-colon(pol16,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol17,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if main-line <> no or string(pol17) <> ? then fnc-convert-dot-to-colon(pol17,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
             '</tr>'
            '<tr>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if main-line <> no or string(pol5) <> ? then fnc-convert-dot-to-colon(pol5,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol11,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if supp-line <> no or string(pol11) <> ? then fnc-convert-dot-to-colon(pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol18,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if main-line <> no or string(pol18) <> ? then fnc-convert-dot-to-colon(pol18,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
             '</tr>' skip  
             .         
          leave _not-empty-group.
      end.
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
/*              release buf_shift-pgds-out.*/
              .

            end. /*if not available buf_shift-pgds-out then do:*/

          end. /*if p-batch > 0 */

        put stream OutStr-html unformatted
             '<tr>' skip
                    '<td text_wrap="true" rowspan="2">' + pol1 + '</td>' skip
                    '<td text_wrap="true" rowspan="2" style="text-align: right;">' + if main-line <> no or string(pol2) <> ? then string(pol2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol3,"->>>>>>>>>>>9.99",2) + '" rowspan="2" style="text-align: right;">' + if main-line <> no or string(pol3) <> ? then fnc-convert-dot-to-colon(pol3,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if main-line <> no or string(pol4) <> ? then fnc-convert-dot-to-colon(pol4,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" rowspan="2">' + if supp-line <> no or pol6 <> ? then pol6 + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" rowspan="2" style="text-align: right;">' + if pol7 <> 0 then string(pol7) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" rowspan="2">' + if pol8 <> "" then string(pol8) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol9,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if supp-line <> no or string(pol9) <> ? then fnc-convert-dot-to-colon(pol9,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.0000" val="' + fnc-convert-dot-to-colon(pol10,"->>>>>>>>>>>9.9999",4) + '" rowspan="2" style="text-align: right;">' + if supp-line <> no or string(pol10) <> ? then fnc-convert-dot-to-colon(pol10,"->>>>>>>>>>>9.9999",4) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.000" val="' + fnc-convert-dot-to-colon(pol9_1,"->>>>>>>>>>>9.999",3) + '" rowspan="2" style="text-align: right;">' + if supp-line <> no or string(pol9_1) <> ? then fnc-convert-dot-to-colon(pol9_1,"->>>>>>>>>>>9.999",3) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0" val="' + fnc-convert-dot-to-colon(pol12,"->>>>>>>>>>>9",0) + '" rowspan="2" style="text-align: right;">' + if supp-line <> no or string(pol12) <> ? then fnc-convert-dot-to-colon(pol12,"->>>>>>>>>>>9",0) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" rowspan="2">' + if pay-line <> no or pol13 <> "" then pol13 + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol14,"->>>>>>>>>>>9.99",2) + '" rowspan="2" style="text-align: right;">' + if pay-line <> no or string(pol14) <> ? then fnc-convert-dot-to-colon(pol14,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol15,"->>>>>>>>>>>9.99",2) + '" rowspan="2" style="text-align: right;">' + if pay-line <> no or string(pol15) <> ? then fnc-convert-dot-to-colon(pol15,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol16,"->>>>>>>>>>>9.99",2) + '" rowspan="2" style="text-align: right;">' + if pay-line <> no or string(pol16) <> ? then fnc-convert-dot-to-colon(pol16,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol17,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if main-line <> no or string(pol17) <> ? then fnc-convert-dot-to-colon(pol17,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
             '</tr>'
            '<tr>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if main-line <> no or string(pol5) <> ? then fnc-convert-dot-to-colon(pol5,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol11,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if supp-line <> no or string(pol11) <> ? then fnc-convert-dot-to-colon(pol11,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol18,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + if main-line <> no or string(pol18) <> ? then fnc-convert-dot-to-colon(pol18,"->>>>>>>>>>>9.99",2) + '</td>' else "" + '</td>' skip
             '</tr>' skip  
             .
          leave _not-empty-group.
        end.
      end.
    end. /*do whiel true*/

    if jj <= t-2.lines then 
      if main-line = yes then do:
        assign accum-4  = accum-4  + pol4
               accum-5  = accum-5  + pol5
               accum-17 = accum-17 + pol17
               accum-18 = accum-18 + pol18.
      end.

      if supp-line = yes then do:
        if tincome-2.is-fact = yes then do:
          assign accum-9  = accum-9  + pol9
                 accum-11 = accum-11 + pol11.
        end.
      end.
      if pay-line = yes then do:
          if treal-2.cpay-code <> 0
          and treal-2.curr-code <>  - 1
          then do:
          assign accum-14 = accum-14 + pol14
                 accum-15 = accum-15 + pol15
                 accum-16 = accum-16 + pol16.
          end.
      end.
  END. /* DO jj = 1 TO t-2.lines */

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

        put stream OutStr-html unformatted
            '<tr>' skip
                    '<td text_wrap="true" rowspan="2">' + pol1 + '</td>' skip
                    '<td text_wrap="true" rowspan="2" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" rowspan="2" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol4,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(pol4,"->>>>>>>>>>>9.99",2) + '</td>' skip
                    '<td text_wrap="true" rowspan="2"></td>' skip
                    '<td text_wrap="true" rowspan="2" style="text-align: right;"></td>' skip
                    '<td text_wrap="true" rowspan="2"></td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol9,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(pol9,"->>>>>>>>>>>9.99",2) + '</td>' skip
                    '<td text_wrap="true" rowspan="2"></td>' skip
                    '<td text_wrap="true" rowspan="2"></td>' skip
                    '<td text_wrap="true" rowspan="2"></td>' skip
                    '<td text_wrap="true" rowspan="2">' + pol13 + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol14,"->>>>>>>>>>>9.99",2) + '" rowspan="2" style="text-align: right;">' + fnc-convert-dot-to-colon(pol14,"->>>>>>>>>>>9.99",2) + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol15,"->>>>>>>>>>>9.99",2) + '" rowspan="2" style="text-align: right;">' + fnc-convert-dot-to-colon(pol15,"->>>>>>>>>>>9.99",2) + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol16,"->>>>>>>>>>>9.99",2) + '" rowspan="2" style="text-align: right;">' + fnc-convert-dot-to-colon(pol16,"->>>>>>>>>>>9.99",2) + '</td>' skip
                    '<td text_wrap="true" rowspan="2"></td>' skip
             '</tr>'
            '<tr>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol5,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(pol5,"->>>>>>>>>>>9.99",2) + '</td>' skip
                    '<td text_wrap="true" num="0.00" val="' + fnc-convert-dot-to-colon(pol11,"->>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(pol11,"->>>>>>>>>>>9.99",2) + '</td>' skip
             '</tr>' skip  
             .  

    /* печатаем подитоги по всем расходам по всем топливам */
    if can-find( first actreal-2 no-lock ) then do:
      assign pol13 = "     в том числе:".
        put stream OutStr-html unformatted
            substitute (
            '  <tr>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th text_wrap="true" style="text-align: left;">&1</th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                </tr>'
            ,
            pol13
            ).



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
        put stream OutStr-html unformatted
            substitute (
            '  <tr>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th text_wrap="true" style="text-align: left;">&1</th>
                    <th text_wrap="true" style="text-align: right;">&2</th>
                    <th text_wrap="true" style="text-align: right;">&3</th>
                    <th text_wrap="true" style="text-align: right;">&4</th>
                    <th text_wrap="true" style="text-align: right;"></th>
               </tr>'
            ,
            pol13,
            string(pol14,"->>>>>>>>>>>9.99"),
            string(pol15,"->>>>>>>>>>>9.99"),
            string(pol16,"->>>>>>>>>>>9.99")
            ).

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

        put stream OutStr-html unformatted
            substitute (
            '  <tr>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th text_wrap="true" style="text-align: left;">&1</th>
                    <th text_wrap="true" style="text-align: right;">&2</th>
                    <th text_wrap="true" style="text-align: right;">&3</th>
                    <th text_wrap="true" style="text-align: right;">&4</th>
                    <th></th>
               </tr>'
            ,
            pol13,
            string(pol14,"->>>>>>>>>>>9.99"),
            string(pol15,"->>>>>>>>>>>9.99"),
            string(pol16,"->>>>>>>>>>>9.99")
            ).


        end. /* last-of( ctreal-2.is-pay ) and is-pay <> ? */
      END. /* for each actreal-2 */
    END. /* if can-find first actreal */
output stream OutStr-html close. 
  END. /* IF LAST t-2.main-code */
END. /* FOR EACH t-2 */

     output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
     put stream OutStr-html unformatted                                                                     
        substitute (
        '
        </tbody>
        '                                                                                      
            , chr(123), chr(125)                                                                                                 
       ).                                                                                                    
      output stream OutStr-html close.

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