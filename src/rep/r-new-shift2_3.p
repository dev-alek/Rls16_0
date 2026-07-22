block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

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
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
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
define buffer nottreal-2 for treal-2.
{ rep/real-2cr.i grptreal-2     }
{ rep/rshiftd1.i t "shared"}
{ str/trdcalib.i }
{ rep/html-conv.i }
{ ref/gds-attr.i }
{ str/is-sug.i }

define shared stream PrnLibstream.

define variable pol1               as character no-undo.
define variable pol2               as decimal   no-undo.
define variable pol3               as decimal   no-undo.
define variable pol4               as decimal   no-undo.
define variable pol5               as character no-undo.
define variable pol6               as character no-undo.
define variable pol7               as decimal   no-undo.
define variable pol8               as decimal   no-undo.
define variable pol9               as decimal   no-undo.
define variable pol10              as decimal   no-undo.
define variable pol11              as character no-undo.
define variable pol12              as decimal   no-undo.
define variable pol13              as decimal   no-undo.
define variable pol14              as decimal   no-undo.
define variable pol15              as decimal   no-undo.
define variable pol16              as decimal   no-undo.
define variable pol17              as decimal   no-undo.
define variable pol18              as decimal   no-undo.
define variable pol19              as decimal   no-undo.
define variable line               as character no-undo.
define variable pol8-excel         as character no-undo.

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
define variable aincome-qnty3      as decimal   no-undo.
define variable aincome-sug-qnty1  as decimal   no-undo.
define variable aincome-sug-qnty2  as decimal   no-undo.
define variable aincome-sug-qnty3  as decimal   no-undo.
define variable aincome-density    as decimal   no-undo.
define variable loc-real-ii        as integer   no-undo.
define variable curr-real-ii       as integer   no-undo.
define variable loc-income-ii      as integer   no-undo.
define variable loc-income-sug-ii  as integer   no-undo.
define variable jj                 as integer   no-undo.
define variable kk                 as integer   no-undo.
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
define variable accum-sug-4        as decimal   no-undo.
define variable accum-sug-5        as decimal   no-undo.
define variable accum-sug-9        as decimal   no-undo.
define variable accum-sug-11       as decimal   no-undo.
define variable accum-sug-13       as decimal   no-undo.
define variable accum-sug-14       as decimal   no-undo.
define variable accum-sug-15       as decimal   no-undo.
define variable accum-sug-16       as decimal   no-undo.
define variable accum-sug-17       as decimal   no-undo.
define variable accum-sug-18       as decimal   no-undo.

define variable acii               as integer   no-undo.
define variable v-grp-name         as character no-undo.
define variable v-grp-code         as integer   no-undo.
define variable v-step             as integer   no-undo.
define variable v-is-pay           as logical   no-undo.
define variable loc-grpii          as integer   no-undo.
define variable v-attr-value       as character no-undo.
define variable v-attr-type        as character no-undo.
define temp-table t-2-not-sug like t-2 .
define temp-table t-2-sug like t-2 .

/* количество записей итогов по группе платежей по товару в которых количество типов платежей > 1*/
define variable loc-grp-only-not-single as integer no-undo .
/*количестов записей итогов по группам в которых количество типов платежей = 1 - их мы не выводим*/
/*на это количество будет смещено соответствие tincome-2.ii и treal-2.ii в одной строчке*/
define variable v-delta                 as integer no-undo .
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
  DEFINE VARIABLE v-dopi  AS INTEGER   NO-UNDO INIT ?.
  DEFINE VARIABLE v-value AS character NO-UNDO.
  DEFINE VARIABLE v-type  AS character NO-UNDO.
  RUN cp-attr-value  IN THIS-PROCEDURE(
    input p-cdpay-code
    ,input p-curr-code
    ,input 0 /*p-host-code    */
    ,input '':U /*p-obj-type     */
    ,input 0 /* p-obj-code     */
    ,INPUT {&cp-attr-grp-code}
    ,output v-value
    ,OUTPUT v-type) NO-ERROR.

  IF NOT ERROR-STATUS:ERROR THEN 
  DO:
    ASSIGN
      v-dopi     = INTEGER(entry(2, v-value, {&delim-par}))
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
if error-status:error then 
do:
  return error substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"
    ,vss-workfile
    ,vss-revision
    ,vss-description
    ,{&new-line}
    , error-status:get-message(1)
    , return-value ).
end.

/* ЦИКЛ по товарам-топливам */
FOR EACH t-2 USE-INDEX pi :
  assign 
    areal-is-pay-qnty1      = 0
    areal-is-pay-qnty2      = 0
    areal-is-pay-netto      = 0
    areal-no-pay-qnty1      = 0
    areal-no-pay-qnty2      = 0
    areal-no-pay-netto      = 0
    areal-qnty1             = 0
    areal-qnty2             = 0
    areal-netto             = 0
    aincome-qnty1           = 0
    aincome-qnty2           = 0
    aincome-qnty3           = 0
    aincome-sug-qnty1       = 0
    aincome-sug-qnty2       = 0
    aincome-sug-qnty3       = 0
    loc-real-ii             = 1
    loc-grpii               = 0
    loc-grp-only-not-single = 0
    loc-income-ii           = 0
    loc-income-sug-ii       = 0
    /*     density                 = ? */
    curr-real-ii            = 1.
  /* чтобы прописать ii для тех у кого ii = ? */
  FIND LAST treal-2 NO-LOCK WHERE
    treal-2.gds-code = t-2.gds-code AND
    treal-2.is-pay   = YES          USE-INDEX vi NO-ERROR.
  if available treal-2 then 
  do:
    assign 
      loc-real-ii  = treal-2.ii + 1
      curr-real-ii = treal-2.ii + 1.
  end.

  if not is-sug(t-2.gds-code) then 
  do:
    create t-2-not-sug .
    buffer-copy t-2 to t-2-not-sug .
  end.
  else 
  do:
    create t-2-sug .
    buffer-copy t-2 to t-2-sug .
  end.    
END. /* FOR EACH t-2 */
  
/* родим записи таблицы tincome-2 - итоги */
/* если есть вообще оплаченный расход */

for each t-2-not-sug: 
  assign 
    areal-is-pay-qnty1      = 0
    areal-is-pay-qnty2      = 0
    areal-is-pay-netto      = 0
    areal-no-pay-qnty1      = 0
    areal-no-pay-qnty2      = 0
    areal-no-pay-netto      = 0
    areal-qnty1             = 0
    areal-qnty2             = 0
    areal-netto             = 0
    aincome-qnty1           = 0
    aincome-qnty2           = 0
    aincome-qnty3           = 0
    aincome-sug-qnty1       = 0
    aincome-sug-qnty2       = 0
    aincome-sug-qnty3       = 0
    loc-real-ii             = 1
    loc-grpii               = 0
    loc-grp-only-not-single = 0
    loc-income-ii           = 0
    loc-income-sug-ii       = 0
    /*     density                 = ? */
    curr-real-ii            = 1.

  FIND LAST treal-2 NO-LOCK WHERE
    treal-2.gds-code = t-2-not-sug.gds-code AND
    treal-2.is-pay   = YES          USE-INDEX vi NO-ERROR.
  if available treal-2 then 
  do:
    assign 
      loc-real-ii  = treal-2.ii + 1
      curr-real-ii = treal-2.ii + 1.
  end.

  IF CAN-FIND( FIRST treal-2 WHERE
                     treal-2.gds-code = t-2-not-sug.gds-code ) THEN DO:
    /* если есть вообще оплаченный расход */
    do v-step = 1 to 2:
      if v-step = 1 then assign v-is-pay = yes.
      if v-step = 2 then assign v-is-pay = no .
      FOR EACH treal-2 WHERE treal-2.is-pay = v-is-pay AND treal-2.gds-code = t-2-not-sug.gds-code and treal-2.curr-code >= 0 USE-INDEX pi :
        if treal-2.discnt-type = -99 then do:
        assign
          areal-qnty1 = areal-qnty1 + round(treal-2.qnty1,2)
          areal-qnty2 = areal-qnty2 + round(treal-2.qnty2,2)
          areal-netto = areal-netto + round(treal-2.netto,2)
        .
        end.
        if treal-2.is-pay = yes then do:
          if treal-2.discnt-type = -99 then do:
          assign
          areal-is-pay-qnty1 = areal-is-pay-qnty1 + round(treal-2.qnty1,2)
          areal-is-pay-qnty2 = areal-is-pay-qnty2 + round(treal-2.qnty2,2)
          areal-is-pay-netto = areal-is-pay-netto + round(treal-2.netto,2).
          end.
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

             for first nottreal-2 where nottreal-2.gds-code = treal-2.gds-code and
                nottreal-2.is-pay = treal-2.is-pay and
                nottreal-2.out-name = treal-2.out-name and
                (nottreal-2.discnt-type = -99 or nottreal-2.discnt-type = -98):
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
              grptreal-2.qnty1 = grptreal-2.qnty1 + round(treal-2.qnty1,2)
              grptreal-2.qnty2 = grptreal-2.qnty2 + round(treal-2.qnty2,2)
              grptreal-2.netto = grptreal-2.netto + round(treal-2.netto,2)
              .
            end.
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
                                                    treal-2.gds-code =  t-2-not-sug.gds-code and
                                                    treal-2.is-pay   =  no           and
                                                    recid( treal-2 ) <> rc ) )
                                  then ( curr-real-ii + 1 )
                                  else   curr-real-ii )
          treal-2.ii           = curr-real-ii
          curr-real-ii         = curr-real-ii + 1.
          if treal-2.cpay-code <> -4 and treal-2.discnt-type = -99 then do: /* инвентаризацию не включаем */
            assign areal-no-pay-qnty1 = areal-no-pay-qnty1 + round(treal-2.qnty1,2)
                  areal-no-pay-qnty2 = areal-no-pay-qnty2 + round(treal-2.qnty2,2)
                  areal-no-pay-netto = areal-no-pay-netto + round(treal-2.netto,2).
          end.
        end.
      end. /* for each treal-2 */
    END.
    if curr-real-ii - loc-grp-only-not-single > 2 then 
    do:
      /* treal-2 большей одной */
      /* рожаем запись ИТОГО ОПЛАЧ.РАСХОД */
      run create-treal-2 in this-procedure ( input t-2-not-sug.gds-code,
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
      run create-treal-2 in this-procedure ( input t-2-not-sug.gds-code,
                                             input 0,
                                             input 0,
                                             input areal-no-pay-qnty1,
                                             input areal-no-pay-qnty2,
                                             input areal-no-pay-netto,
                                             input "ИТОГО ПРОЧ.РАСХОД",
                                             input no,
                                             input curr-real-ii         ) no-error.
      assign curr-real-ii = curr-real-ii + 1.
      run create-treal-2 in this-procedure ( input t-2-not-sug.gds-code,
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
  assign
      aincome-qnty1 = 0
      aincome-qnty2 = 0
      aincome-qnty3 = 0
  .  
  for EACH tincome-2 WHERE
    tincome-2.gds-code = t-2-not-sug.gds-code
    USE-INDEX vi
    :
    if tincome-2.supp-name = "Итого по поставщику" then 
    do:
      assign 
        loc-income-ii = tincome-2.ii .
      next.
    end.
    assign 
      aincome-qnty1 = aincome-qnty1 + round(tincome-2.qnty1,2)
      aincome-qnty2 = aincome-qnty2 + round(tincome-2.qnty2,2)
      aincome-qnty3 = aincome-qnty3 + round(tincome-2.qnty3,2)
      loc-income-ii = tincome-2.ii
      .

  END.
  
  if loc-income-ii > 1 then 
  do:
    /* tincome-2 большей одной */
    /* рожаем запись ИТОГО ОПЛАЧ.РАСХОД */

    run create-tincome-2 in this-procedure ( input t-2-not-sug.gds-code,
      input "",
      input aincome-qnty1,
      input aincome-qnty2,
      input aincome-qnty3,
      input "ИТОГО ПОСТУПЛЕНИЙ",
      input 0,
      input no,
      input ( loc-income-ii + 1 ) ) no-error.
    assign 
      loc-income-ii = loc-income-ii + 1.
  end.

  assign 
    t-2-not-sug.lines = MAX( curr-real-ii - loc-grp-only-not-single
        /*исключим из счетчика записи по группам типов платежей с пустым названием - это означает - что
         платежей в группе = 1 и итоги по группе выводить не надо
          */
                        , loc-income-ii, 1 ).

end.
for each t-2-sug: 
  assign 
    areal-is-pay-qnty1      = 0
    areal-is-pay-qnty2      = 0
    areal-is-pay-netto      = 0
    areal-no-pay-qnty1      = 0
    areal-no-pay-qnty2      = 0
    areal-no-pay-netto      = 0
    areal-qnty1             = 0
    areal-qnty2             = 0
    areal-netto             = 0
    aincome-qnty1           = 0
    aincome-qnty2           = 0
    aincome-qnty3           = 0
    aincome-sug-qnty1       = 0
    aincome-sug-qnty2       = 0
    aincome-sug-qnty3       = 0
    loc-real-ii             = 1
    loc-grpii               = 0
    loc-grp-only-not-single = 0
    loc-income-ii           = 0
    loc-income-sug-ii       = 0
    /*     density                 = ? */
    curr-real-ii            = 1.
  FIND LAST treal-2 NO-LOCK WHERE
    treal-2.gds-code = t-2-sug.gds-code AND
    treal-2.is-pay   = YES          USE-INDEX vi NO-ERROR.
  if available treal-2 then 
  do:
    assign 
      loc-real-ii  = treal-2.ii + 1
      curr-real-ii = treal-2.ii + 1.
  end.
  
  
    IF CAN-FIND( FIRST treal-2 WHERE
                     treal-2.gds-code = t-2-sug.gds-code ) THEN DO:
    /* если есть вообще оплаченный расход */
    do v-step = 1 to 2:
      if v-step = 1 then assign v-is-pay = yes.
      if v-step = 2 then assign v-is-pay = no .
      FOR EACH treal-2 WHERE treal-2.is-pay = v-is-pay AND treal-2.gds-code = t-2-sug.gds-code and treal-2.curr-code >= 0 USE-INDEX pi :
        if treal-2.discnt-type = -99 then do:
        assign
          areal-qnty1 = areal-qnty1 + round(treal-2.qnty1,2)
          areal-qnty2 = areal-qnty2 + round(treal-2.qnty2,2)
          areal-netto = areal-netto + round(treal-2.netto,2)
        .
        end.
        if treal-2.is-pay = yes then do:
          if treal-2.discnt-type = -99 then do: 
          assign
          areal-is-pay-qnty1 = areal-is-pay-qnty1 + round(treal-2.qnty1,2)
          areal-is-pay-qnty2 = areal-is-pay-qnty2 + round(treal-2.qnty2,2)
          areal-is-pay-netto = areal-is-pay-netto + round(treal-2.netto,2).
          end.
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
              grptreal-2.qnty1 = grptreal-2.qnty1 + round(treal-2.qnty1,2)
              grptreal-2.qnty2 = grptreal-2.qnty2 + round(treal-2.qnty2,2)
              grptreal-2.netto = grptreal-2.netto + round(treal-2.netto,2)
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
                                                    treal-2.gds-code =  t-2-sug.gds-code and
                                                    treal-2.is-pay   =  no           and
                                                    recid( treal-2 ) <> rc ) )
                                  then ( curr-real-ii + 1 )
                                  else   curr-real-ii )
          treal-2.ii           = curr-real-ii
          curr-real-ii         = curr-real-ii + 1.
          if treal-2.cpay-code <> -4 and treal-2.discnt-type = -99 then do: /* инвентаризацию не включаем */
            assign areal-no-pay-qnty1 = areal-no-pay-qnty1 + round(treal-2.qnty1,2)
                  areal-no-pay-qnty2 = areal-no-pay-qnty2 + round(treal-2.qnty2,2)
                  areal-no-pay-netto = areal-no-pay-netto + round(treal-2.netto,2).
          end.
        end.

      end. /* for each treal-2 */
    END.
    if curr-real-ii - loc-grp-only-not-single > 2 then do:
      /* treal-2 большей одной */
      /* рожаем запись ИТОГО ОПЛАЧ.РАСХОД */
      run create-treal-2 in this-procedure ( input t-2-sug.gds-code,
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
      run create-treal-2 in this-procedure ( input t-2-sug.gds-code,
                                             input 0,
                                             input 0,
                                             input areal-no-pay-qnty1,
                                             input areal-no-pay-qnty2,
                                             input areal-no-pay-netto,
                                             input "ИТОГО ПРОЧ.РАСХОД",
                                             input no,
                                             input curr-real-ii         ) no-error.
      assign curr-real-ii = curr-real-ii + 1.
      run create-treal-2 in this-procedure ( input t-2-sug.gds-code,
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
 
  for EACH tincome-2 WHERE
    tincome-2.gds-code = t-2-sug.gds-code
    USE-INDEX vi
    :
    if tincome-2.supp-name = "Итого по поставщику" then 
    do:
      assign 
        loc-income-sug-ii = tincome-2.ii .
      next.
    end.
    assign 
      aincome-sug-qnty1 = aincome-sug-qnty1 + round(tincome-2.qnty1,2)
      aincome-sug-qnty2 = aincome-sug-qnty2 + round(tincome-2.qnty2,2)
      aincome-sug-qnty3 = aincome-sug-qnty3 + round(tincome-2.qnty3,2)
      loc-income-sug-ii = tincome-2.ii
      .
  END.
  
  if loc-income-sug-ii > 1 then 
  do:
    /* tincome-2 большей одной */
    /* рожаем запись ИТОГО ОПЛАЧ.РАСХОД */

    run create-tincome-2 in this-procedure ( input t-2-sug.gds-code,
      input "",
      input aincome-sug-qnty1,
      input aincome-sug-qnty2,
      input aincome-sug-qnty3,
      input "ИТОГО ПОСТУПЛЕНИЙ",
      input 0,
      input no,
      input ( loc-income-sug-ii + 1 ) ) no-error.
    assign 
      loc-income-sug-ii = loc-income-sug-ii + 1.
  end.

  assign 
    t-2-sug.lines = MAX( curr-real-ii - loc-grp-only-not-single
        /*исключим из счетчика записи по группам типов платежей с пустым названием - это означает - что
         платежей в группе = 1 и итоги по группе выводить не надо
          */
                        , loc-income-sug-ii, 1 ).

end.
/*шапка таблицы HTML*/
run print-total .
run print-sug .

procedure print-total .
  output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
  put stream OutStr-html unformatted                                                              
    substitute (                                                                                
    '<tbody> <!-- Здесь начинается таблица отчета --> 
                <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->                                 
                <th text_wrap="true" colspan="17" style="text-align: center;">Нефтепродукты: бензины и ДТ</th>                  
            </tr>                                                                                       
                                           
                <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->                                 
                <th text_wrap="true" colspan="3" style="text-align: center;">Информация о продукте</th>                  
                <th text_wrap="true" colspan="6" style="text-align: center;">Расшифровка поступления</th>                
                <th text_wrap="true" colspan="7" style="text-align: center;">Расшифровка реализации</th>                 
                <th text_wrap="true" rowspan="3" style="text-align: center;">Остаток на конец кг</th>                       
            </tr>                                                                                       
            <tr>                                                                                        
                <th text_wrap="true" rowspan="2" style="text-align: center;">Наименование продукта</th>                  
                <th text_wrap="true" rowspan="2" style="text-align: center;">Цена розничная на конец смены</th>          
                <th text_wrap="true" rowspan="2" style="text-align: center;">Остаток на начало кг</th>                      
                <th text_wrap="true"             style="text-align: center;">Поставщик</th>                              
                <th text_wrap="true" rowspan="2" style="text-align: center;">Номер документа прихода (ТТН)</th>          
                <th text_wrap="true" rowspan="2" style="text-align: center;">Количество кг/л</th>                             
                <th text_wrap="true" rowspan="2" style="text-align: center;">Плотность кг/м3</th>  
                <th text_wrap="true" rowspan="2" style="text-align: center;">ЕУ кг.</th>                         
                <th text_wrap="true" rowspan="2" style="text-align: center;">Т в гр.°С</th>         
                <th text_wrap="true" rowspan="2" style="text-align: center;">Тип расхода (тип платежа)</th>              
                <th text_wrap="true" rowspan="2" style="text-align: center;">Кол-во в литрах</th>                        
                <th text_wrap="true" rowspan="2" style="text-align: center;">Кол-во в кг</th>                    
                <th text_wrap="true" rowspan="2" style="text-align: center;">Сумма</th>
                <th text_wrap="true" rowspan="2" style="text-align: center;">Сумма скидки</th>                 
                <th text_wrap="true" rowspan="2" style="text-align: center;">Сумма брутто</th>                 
                <th text_wrap="true" rowspan="2" style="text-align: center;">Кол-во чеков</th>                                                   
            </tr>                                                                                       
            <tr>                                                                                        
                <th text_wrap="true" style="text-align: center;">Наименование</th>                                       
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
                <th style="text-align: center;">2.17</th>                                                 
            </tr>'                                                                                      
                                                                                                        
    , chr(123), chr(125)                                                                        
    ).                                                                                              
  for each actreal-2 :
    delete actreal-2 .
  end.
  /* непосредственно печать */
  FOR EACH t-2-not-sug NO-LOCK
    BREAK
    BY t-2-not-sug.main-code:
    /*        if is-sug(t-2.gds-code) then next .*/
    v-delta = 0.
    DO jj = 1 TO t-2-not-sug.lines :
      assign 
        pol1      = "":U
        pol2      = 0
        pol3      = 0
        pol4      = 0
        pol5      = "":U
        pol6      = "":U
        pol7      = 0
        pol8      = 0
        pol9      = 0
        pol10     = ?
        pol11     = "":U
        pol12     = 0
        pol13     = 0
        pol14     = 0
        pol15     = 0
        pol16     = 0
        pol17     = 0
        pol18     = 0
        pol19     = 0
        main-line = no
        supp-line = no
        pay-line  = no.
      IF jj = 1 then 
      do:
        assign 
          pol1      = t-2-not-sug.gds-name
          pol2      = t-2-not-sug.last-price
          pol3      = t-2-not-sug.qnty1-before
          pol4      = t-2-not-sug.qnty2-before
          pol18     = t-2-not-sug.qnty1-after
          pol19     = t-2-not-sug.qnty2-after
          main-line = yes.
        if p-batch > 0
          then 
        do:
          find first buf_shift-pgds where
            buf_shift-pgds.obj-type = p-obj-type
            and buf_shift-pgds.obj-code = p-obj-code
            and buf_shift-pgds.shift-date = X-date-end
            and buf_shift-pgds.shift-num = X-shift-end
            and buf_shift-pgds.gds-code = t-2-not-sug.gds-code no-error.
          if available buf_shift-pgds then 
          do:
            assign
              buf_shift-pgds.end-price-sale = t-2-not-sug.last-price
              .
            release buf_shift-pgds.
          end.
        end.
      END.

      FIND FIRST tincome-2 NO-LOCK WHERE
        tincome-2.gds-code = t-2-not-sug.gds-code AND
        tincome-2.ii       = jj           NO-ERROR.
      IF AVAIlABLE tincome-2 THEN 
      DO:
        /* номер документа из атрибутов */
      { str/tdat-val.i
        tincome-2.doc-code
        {&trdcattr-nids}
        v-attr-value
        v-attr-type
        }
        assign
          pol6       = if v-attr-value = "" or v-attr-value = ?
               then tincome-2.doc-code
               else v-attr-value
          pol8-excel = if v-attr-value = "" or v-attr-value = ?
               then tincome-2.doc-code
               else '="' + v-attr-value + '"'
          .

        ASSIGN 
          pol5      = tincome-2.supp-name
          pol7      = round(tincome-2.qnty1,2)
          pol8      = tincome-2.density
          pol9      = round(tincome-2.qnty2,2)
          pol10     = tincome-2.temperature
          supp-line = yes.
        if p-batch > 0
          and tincome-2.supp-code > 0
          and tincome-2.gds-code > 0
          then 
        do:
          find first buf_shift-pgds-in where
            buf_shift-pgds-in.obj-type = p-obj-type
            and buf_shift-pgds-in.obj-code = p-obj-code
            and buf_shift-pgds-in.shift-date = X-date-end
            and buf_shift-pgds-in.shift-num = X-shift-end
            and buf_shift-pgds-in.gds-code = t-2-not-sug.gds-code
            and buf_shift-pgds-in.doc-code = tincome-2.doc-code no-error.
          if not available buf_shift-pgds-in then 
          do:
            create buf_shift-pgds-in.
            assign
              buf_shift-pgds-in.obj-type      = p-obj-type
              buf_shift-pgds-in.obj-code      = p-obj-code
              buf_shift-pgds-in.shift-date    = X-date-end
              buf_shift-pgds-in.shift-num     = X-shift-end
              buf_shift-pgds-in.gds-code      = t-2-not-sug.gds-code
              buf_shift-pgds-in.doc-code      = tincome-2.doc-code
              buf_shift-pgds-in.cli-type-code = substitute("&1&2", tincome-2.supp-type, tincome-2.supp-code)
              buf_shift-pgds-in.cli-name      = tincome-2.supp-name
              buf_shift-pgds-in.fact-qnty     = tincome-2.qnty1
              buf_shift-pgds-in.fact-qnty-2   = tincome-2.qnty2
              .
            release buf_shift-pgds-in.
          end.
        end.
      END.
      _not-empty-group:
      do while true :
        FIND FIRST treal-2 NO-LOCK WHERE
          treal-2.gds-code = t-2-not-sug.gds-code AND
          treal-2.ii       = jj + v-delta          NO-ERROR.
        if not available treal-2 then 
        do:
          put stream OutStr-html unformatted
            substitute (
            '  
            <tr>
                    <td rowspan="2" text_wrap="true">&1</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&2</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&3</td>
                    <td text_wrap="true" rowspan="2" style="text-align: left;">&5</td>
                    <td text_wrap="true" rowspan="2">&6</td>
                    <td text_wrap="true" style="text-align: right;">&8</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&7</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;"></td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&4</td>'
            ,
            pol1,
            if main-line = no then "" else string(pol2,"->>>>>>>>>>>9.99"),
            if main-line = no then "" else string(pol4,"->>>>>>>>>>>9.99"),
            if pol10 = ? or pol6 = "" then "" else string(pol10,"->>>>>>>>>>>9"),
            if supp-line = no then "" else pol5,
            if pol6 = "" then "" else string(pol6),
            if supp-line = no or pol8 = ? or pol6 = "" then "" else string(pol8,">>>>>>>>>>>9.9999"),
            if supp-line = no then "" else string(pol9,"->>>>>>>>>>>9.99")
            ).
          put stream OutStr-html unformatted
            substitute (
            '
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&1</td>
                    <td text_wrap="true" rowspan="2" >&2</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&3</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&4</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&5</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&6</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&7</td>
                    <td rowspan="2" text_wrap="true" style="text-align: right;">&8</td> 
                    </tr>
               '
            ,
            if pay-line = no then "" else pol11,
            if pay-line = no then "" else string(pol12,"->>>>>>>>>>>9.99"),
            if pay-line = no then "" else string(pol13,"->>>>>>>>>>>9.99"),
            if pay-line = no then "" else string(pol14,"->>>>>>>>>>>9.99"),
            if pay-line = no or pol15 = 0 then "" else string(pol15,"->>>>>>>>>>>9.99"),
            if pay-line = no or pol16 = 0 then "" else string(pol16,"->>>>>>>>>>>9.99"),
            if main-line = no or pol17 = 0 then "" else string(pol17,"->>>>>>>>>>>9.99"),
            if main-line = no then "" else string(pol19,"->>>>>>>>>>>9.99")
            
            ).

          put stream OutStr-html unformatted
            substitute (
            '
                    <tr>
                    
                    <td text_wrap="true" style="text-align: right;">&2</td>
                    
                    </tr>
               '
            ,
            if main-line = no then "" else string(pol3,"->>>>>>>>>>>9.99"),
            if supp-line = no then "" else string(pol7,">>>>>>>>>>>9.99"),
            if main-line = no then "" else string(pol18,"->>>>>>>>>>>9.99")            
            ).


          leave _not-empty-group.
        end.
        if available treal-2 then 
        do:
          if (treal-2.cpay-code <> 0
            or treal-2.curr-code= - 1) and treal-2.discnt-type = -99
            then 
          do:
            FIND FIRST actreal-2 WHERE
              actreal-2.gds-code = 0 AND
              actreal-2.cpay-code = treal-2.cpay-code AND
              actreal-2.curr-code = treal-2.curr-code AND
              actreal-2.is-pay = treal-2.is-pay NO-ERROR.
            if not available actreal-2 then 
            do:
              assign 
                acii = acii + 1.
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
            else 
            do:
              assign 
                actreal-2.qnty1 = actreal-2.qnty1 + round(treal-2.qnty1,2)
                actreal-2.qnty2 = actreal-2.qnty2 + round(treal-2.qnty2,2)
                actreal-2.netto = actreal-2.netto + round(treal-2.netto,2).
            end.
          end.
        
          /*итоги по платежу*/
          if treal-2.is-pay = yes
            and treal-2.curr-code < 0
            and treal-2.out-name begins {&delim-par} then 
          do:
            assign
              v-delta = v-delta + 1
              .
            next _not-empty-group.
          end.
          else 
          do:
            assign
              pol11    = treal-2.out-name
              pol12    = treal-2.qnty1
              pol13    = treal-2.qnty2
              pol14    = treal-2.netto
              pol15    = treal-2.discount-sum
              pol16    = treal-2.brutto
              pol17    = treal-2.chk-qnty
              pay-line = yes
              .
            if p-batch > 0
              and (treal-2.curr-code > 0
              or not (treal-2.curr-code = 0 and treal-2.cpay-code = 0)
              )
              and treal-2.gds-code > 0
              then 
            do:
              find first buf_shift-pgds-out where
                buf_shift-pgds-out.obj-type = p-obj-type
                and buf_shift-pgds-out.obj-code = p-obj-code
                and buf_shift-pgds-out.shift-date = X-date-end
                and buf_shift-pgds-out.shift-num = X-shift-end
                and buf_shift-pgds-out.gds-code = treal-2.gds-code
                and buf_shift-pgds-out.pay-code = treal-2.cpay-code
                and buf_shift-pgds-out.curr-code = treal-2.curr-code
                no-error.
              if not available buf_shift-pgds-out then 
              do:
                find first buf_cash-pay no-lock where
                  buf_cash-pay.cdpay-code = treal-2.cpay-code
                  and  buf_cash-pay.curr-code = treal-2.curr-code no-error.
                create buf_shift-pgds-out.
                assign
                  buf_shift-pgds-out.obj-type    = p-obj-type
                  buf_shift-pgds-out.obj-code    = p-obj-code
                  buf_shift-pgds-out.shift-date  = X-date-end
                  buf_shift-pgds-out.shift-num   = X-shift-end
                  buf_shift-pgds-out.gds-code    = treal-2.gds-code
                  buf_shift-pgds-out.pay-code    = treal-2.cpay-code
                  buf_shift-pgds-out.curr-code   = treal-2.curr-code
                  buf_shift-pgds-out.out-name    = treal-2.out-name
                  buf_shift-pgds-out.cp-type     = (if available buf_cash-pay
                                            and buf_cash-pay.is-cash
                                            then 1
                                            else 2)
                  buf_shift-pgds-out.fact-qnty   = treal-2.qnty1
                  buf_shift-pgds-out.fact-qnty-2 = treal-2.qnty2
                  buf_shift-pgds-out.fact-sum    = treal-2.netto
                  .
                /*              release buf_shift-pgds-out.*/
                .

              end. /*if not available buf_shift-pgds-out then do:*/

            end. /*if p-batch > 0 */
            put stream OutStr-html unformatted
              substitute (
              '  <tr>
                    <td rowspan="2" text_wrap="true">&1</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&2</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&3</td>
                    <td text_wrap="true" rowspan="2" style="text-align: left;">&5</td>
                    <td text_wrap="true" rowspan="2">&6</td>
                    <td text_wrap="true" style="text-align: right;">&8</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&7</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;"></td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&4</td>'
              ,
              pol1,
              if main-line = no then "" else string(pol2,"->>>>>>>>>>>9.99"),
              if main-line = no then "" else string(pol4,"->>>>>>>>>>>9.99"),
              if pol10 = ? or pol6 = "" then "" else string(pol10,"->>>>>>>>>>>9"),
              if supp-line = no then "" else pol5,
              if pol6 = "" then "" else string(pol6),
              if supp-line = no or pol8 = ? or pol6 = "" then "" else string(pol8,">>>>>>>>>>>9.9999"),
              if supp-line = no then "" else string(pol9,"->>>>>>>>>>>9.99")
              ).
            
            put stream OutStr-html unformatted
              substitute (
              '
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&1</td>
                    <td text_wrap="true" rowspan="2" >&2</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&3</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&4</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&5</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&6</td>
                    <td text_wrap="true" rowspan="2" style="text-align: right;">&7</td>
                    <td rowspan="2" text_wrap="true" style="text-align: right;">&8</td>
                    </tr>
               '
              ,
              if pay-line = no then "" else pol11,
              if pay-line = no then "" else string(pol12,"->>>>>>>>>>>9.99"),
              if pay-line = no then "" else string(pol13,"->>>>>>>>>>>9.99"),
              if pay-line = no then "" else string(pol14,"->>>>>>>>>>>9.99"),
              if pay-line = no or pol15 = 0 then "" else string(pol15,"->>>>>>>>>>>9.99"),
              if pay-line = no or pol16 = 0 then "" else string(pol16,"->>>>>>>>>>>9.99"),
              if /*main-line = no or*/ pol17 = 0 then "" else string(pol17,"->>>>>>>>>>>9.99"),
              if main-line = no then "" else string(pol19,"->>>>>>>>>>>9.99")
              ).

            put stream OutStr-html unformatted
              substitute (
              '
                    <tr>
                    
                    <td text_wrap="true" style="text-align: right;">&2</td>
                    
                    </tr>
               '
              ,
              if main-line = no then "" else string(pol3,"->>>>>>>>>>>9.99"),
              if supp-line = no then "" else string(pol7,">>>>>>>>>>>9.99"),
              if main-line = no then "" else string(pol18,"->>>>>>>>>>>9.99")            
              ).
            leave _not-empty-group.
          end.
        end.
      end. /*do whiel true*/

      if jj <= t-2-not-sug.lines then 
        if main-line = yes then 
        do:
          assign 
            accum-4  = accum-4  + round(pol3,2)
            accum-5  = accum-5  + round(pol4,2)
            accum-17 = accum-17 + round(pol18,2)
            accum-18 = accum-18 + round(pol19,2).
        end.

      if supp-line = yes then 
      do:
        if tincome-2.is-fact = yes then 
        do:
          assign 
            accum-9  = accum-9  + round(pol7,2)
            accum-11 = accum-11 + round(pol9,2).
        end.
      end.
      if pay-line = yes then 
      do:
        if treal-2.cpay-code <> 0
          and treal-2.curr-code <>  - 1
          then 
        do:
          if treal-2.discnt-type = -99 or treal-2.cpay-code < 0 then
          do:
            assign 
              accum-14 = accum-14 + round(pol12,2)
              accum-15 = accum-15 + round(pol13,2)
              accum-16 = accum-16 + round(pol14,2).
          end.
        end.
      end.
    END. /* DO jj = 1 TO t-2.lines */

    IF LAST( t-2-not-sug.main-code ) THEN 
    DO:
      /* печатаем итоги */
      assign 
        pol1  = "ИТОГО"
        pol3  = accum-4
        pol4  = accum-5
        pol7  = accum-9
        pol9  = accum-11
        POL11 = "ИТОГО РАСХОД"
        pol12 = accum-14
        pol13 = accum-15
        pol14 = accum-16
        pol18 = accum-17
        pol19 = accum-18.

      put stream OutStr-html unformatted
        substitute (
        '  <tr>
                    <th text_wrap="true" rowspan="2" style="text-align: left; vertical-align: middle;">&1</th>
                    <th text_wrap="true" rowspan="2"></th>
                    <th text_wrap="true" rowspan="2" style="text-align: right; vertical-align: middle;">&2</th>
                    <th text_wrap="true" rowspan="2" style="text-align: left; vertical-align: middle;">&3</th>
                    <th rowspan="2"></th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&4</th>
                    <th rowspan="2"></th>
                    <th rowspan="2"></th>
                    <th rowspan="2"></th>
                    <th text_wrap="true" rowspan="2" style="text-align: right; vertical-align: middle;">&5</th>
                    <th text_wrap="true" rowspan="2" style="vertical-align: middle;">&6</th>
                    <th text_wrap="true" rowspan="2" style="text-align: right; vertical-align: middle;">&7</th>
                    <th text_wrap="true" rowspan="2" style="text-align: right; vertical-align: middle;">&8</th>
                    <th text_wrap="true" rowspan="2" style="text-align: right; vertical-align: middle;"></th>
                    '
        ,
        pol1,
        string(pol4,"->>>>>>>>>>>9.99"),
        pol5,
        string(pol9,"->>>>>>>>>>>9.99"),
        pol11,
        string(pol12,"->>>>>>>>>>>9.99"),
        string(pol13,"->>>>>>>>>>>9.99"),
        string(pol14,"->>>>>>>>>>>9.99"),
        string(pol15,"->>>>>>>>>>>9.99")
        ).
      put stream OutStr-html unformatted
        substitute (
        '
            <th text_wrap="true" rowspan="2" style="text-align: right; vertical-align: middle;"></th>
            <th text_wrap="true" rowspan="2" style="text-align: right; vertical-align: middle;"></th>
            <th rowspan="2" text_wrap="true" style="text-align: right; vertical-align: middle;">&3</th>
            </tr><tr>
            
            <th text_wrap="true" style="text-align: right; vertical-align: middle;">&5</th>
            
               </tr>'
        ,
        string(pol16,"->>>>>>>>>>>9.99"),
        string(pol17,"->>>>>>>>>>>9.99"),
        string(pol19,"->>>>>>>>>>>9.99"),
        string(pol3,"->>>>>>>>>>>9.99"),
        string(pol7,"->>>>>>>>>>>9.99"),
        string(pol18,"->>>>>>>>>>>9.99")
        ).
      /* печатаем подитоги по всем расходам по всем топливам */
      if can-find( first actreal-2 no-lock ) then 
      do:
        assign 
          pol11 = "     в том числе:".
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
                    <th text_wrap="true">&1</th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                </tr>'
          ,
          pol11
          ).



        assign 
          areal-is-pay-qnty1 = 0
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
        
          if actreal-2.is-pay = yes then 
          do:
            
            if actreal-2.curr-code >= 0 then
              assign areal-is-pay-qnty1 = areal-is-pay-qnty1 + round(actreal-2.qnty1,2)
                areal-is-pay-qnty2 = areal-is-pay-qnty2 + round(actreal-2.qnty2,2)
                areal-is-pay-netto = areal-is-pay-netto + round(actreal-2.netto,2).
          end.
          else 
          do:
            assign 
              areal-no-pay-qnty1 = areal-no-pay-qnty1 + round(actreal-2.qnty1,2)
              areal-no-pay-qnty2 = areal-no-pay-qnty2 + round(actreal-2.qnty2,2)
              areal-no-pay-netto = areal-no-pay-netto + round(actreal-2.netto,2) .
          end.

          assign 
            pol11 = actreal-2.out-name
            pol12 = actreal-2.qnty1
            pol13 = actreal-2.qnty2
            pol14 = actreal-2.netto
            pol15 = actreal-2.brutto
            pol16 = actreal-2.discount-sum
            pol17 = actreal-2.chk-qnty.
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
                    <th text_wrap="true">&1</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&2</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&3</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&4</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&5</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&6</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&7</th>
                    <th></th>
               </tr>'
            ,
            pol11,
            string(pol12,"->>>>>>>>>>>9.99"),
            string(pol13,"->>>>>>>>>>>9.99"),
            string(pol14,"->>>>>>>>>>>9.99"),
            if pol15 = 0 then "" else string(pol15,"->>>>>>>>>>>9.99"),
            if pol16 = 0 then "" else string(pol16,"->>>>>>>>>>>9.99"),
            if pol17 = 0 then "" else string(pol17,"->>>>>>>>>>>9.99")
            ).

          if last-of( actreal-2.is-pay ) /* and actreal-2.is-pay <> ? */ then 
          do:
            if actreal-2.discnt-type = -99 or actreal-2.cpay-code < 0 then 
            do:
              if actreal-2.is-pay = yes then 
              do:
                assign 
                  pol11 = "ИТОГО ОПЛАЧ.РАСХОД"
                  pol12 = areal-is-pay-qnty1
                  pol13 = areal-is-pay-qnty2
                  pol14 = areal-is-pay-netto.
              end.
              else 
              do:
                assign 
                  pol11 = "ИТОГО ПРОЧ.РАСХОД"
                  pol12 = areal-no-pay-qnty1
                  pol13 = areal-no-pay-qnty2
                  pol14 = areal-no-pay-netto.
              end.
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
                    <th text_wrap="true">&1</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&2</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&3</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&4</th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
               </tr>'
              ,
              pol11,
              string(pol12,"->>>>>>>>>>>9.99"),
              string(pol13,"->>>>>>>>>>>9.99"),
              string(pol14,"->>>>>>>>>>>9.99")
              ).


          end. /* last-of( ctreal-2.is-pay ) and is-pay <> ? */
        END. /* for each actreal-2 */
      END. /* if can-find first actreal */
    END. /* IF LAST t-2.main-code */
  END. /* FOR EACH t-2 */

  put stream OutStr-html unformatted                                                                     
    substitute (
    '
        </tbody>
        '                                                                                      
    , chr(123), chr(125)                                                                                                 
    ).                                                                                                    
  output stream OutStr-html close.
end procedure .

procedure print-sug .

  if can-find(t-2-sug) then do:
  output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
  put stream OutStr-html unformatted                                                              
    substitute (                                                                                
    '<tbody> <!-- Здесь начинается таблица отчета -->                                             
            <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->                                 
                <th text_wrap="true" colspan="17" style="text-align: center;">СУГ</th>                  
            </tr>                                                                                       
                <tr> <!-- Первые строки – шапка таблицы с тэгами tr -->                                 
                <th text_wrap="true" colspan="3" style="text-align: center;">Информация о продукте</th>                  
                <th text_wrap="true" colspan="6" style="text-align: center;">Расшифровка поступления</th>                
                <th text_wrap="true" colspan="7" style="text-align: center;">Расшифровка реализации</th>                 
                <th text_wrap="true" rowspan="3" style="text-align: center;">Остаток на конец кг</th>                       
            </tr>                                                                                       
            <tr>                                                                                        
                <th text_wrap="true" rowspan="2" style="text-align: center;">Наименование продукта</th>                  
                <th text_wrap="true" rowspan="2" style="text-align: center;">Цена розничная на конец смены</th>          
                <th text_wrap="true" rowspan="2" style="text-align: center;">Остаток на начало кг</th>                      
                <th text_wrap="true" style="text-align: center;">Поставщик</th>                              
                <th text_wrap="true" rowspan="2" style="text-align: center;">Номер документа прихода (ТТН)</th>          
                <th text_wrap="true" colspan="4" style="text-align: center;">Количество</th>                             
                <th text_wrap="true" rowspan="2" style="text-align: center;">Тип расхода (тип платежа)</th>              
                <th text_wrap="true" rowspan="2" style="text-align: center;">Кол-во в литрах</th>                        
                <th text_wrap="true" rowspan="2" style="text-align: center;">Кол-во в кг</th>                    
                <th text_wrap="true" rowspan="2" style="text-align: center;">Сумма</th>
                <th text_wrap="true" rowspan="2" style="text-align: center;">Сумма скидки</th>                 
                <th text_wrap="true" rowspan="2" style="text-align: center;">Сумма брутто</th>                 
                <th text_wrap="true" rowspan="2" style="text-align: center;">Кол-во чеков</th>                                                   
            </tr>                                                                                       
            <tr>                                                                                        
                <th text_wrap="true" style="text-align: center;">Наименование</th>                                       
                <th colspan="2" style="text-align: center;">Масса по ТТН кг.</th>                                           
                <th colspan="2" text_wrap="true" style="text-align: center;">Масса к учету кг.</th>                                    
            </tr>                                                                                       
            <tr>                                                                                        
                <th style="text-align: center;">2.18</th>                                                  
                <th style="text-align: center;">2.19</th>                                                  
                <th style="text-align: center;">2.20</th>                                                  
                <th style="text-align: center;">2.21</th>                                                  
                <th style="text-align: center;">2.22</th>                                                  
                <th colspan="2" style="text-align: center;">2.23</th>                                                  
                <th colspan="2" style="text-align: center;">2.24</th>                                                  
                <th style="text-align: center;">2.25</th>                                                  
                <th style="text-align: center;">2.26</th>                                                 
                <th style="text-align: center;">2.27</th>                                                 
                <th style="text-align: center;">2.28</th>                                                 
                <th style="text-align: center;">2.29</th>                                                 
                <th style="text-align: center;">2.30</th>                                                 
                <th style="text-align: center;">2.31</th>                                                 
                <th style="text-align: center;">2.32</th>                                                 
            </tr>'                                                                                      
                                                                                                        
    , chr(123), chr(125)                                                                        
    ).                                                                                              

  for each actreal-2 :
    delete actreal-2 .
  end.
  /* непосредственно печать */
  
  FOR EACH t-2-sug NO-LOCK
    BREAK
    BY t-2-sug.main-code :
    v-delta = 0.
    DO jj = 1 TO t-2-sug.lines :
      assign 
        pol1      = "":U
        pol2      = 0
        pol3      = 0
        pol4      = 0
        pol5      = "":U
        pol6      = "":U
        pol7      = 0
        pol8      = 0
        pol9      = 0
        pol10     = ?
        pol11     = "":U
        pol12     = 0
        pol13     = 0
        pol14     = 0
        pol15     = 0
        pol16     = 0
        pol17     = 0
        pol18     = 0
        pol19     = 0
        main-line = no
        supp-line = no
        pay-line  = no.
      IF jj = 1 then 
      do:
        assign 
          pol1      = t-2-sug.gds-name
          pol2      = t-2-sug.last-price
          pol3      = t-2-sug.qnty1-before
          pol4      = t-2-sug.qnty2-before
          pol18     = t-2-sug.qnty1-after
          pol19     = t-2-sug.qnty2-after
          main-line = yes.
        if p-batch > 0
          then 
        do:
          find first buf_shift-pgds where
            buf_shift-pgds.obj-type = p-obj-type
            and buf_shift-pgds.obj-code = p-obj-code
            and buf_shift-pgds.shift-date = X-date-end
            and buf_shift-pgds.shift-num = X-shift-end
            and buf_shift-pgds.gds-code = t-2-sug.gds-code no-error.
          if available buf_shift-pgds then 
          do:
            assign
              buf_shift-pgds.end-price-sale = t-2-sug.last-price
              .
            release buf_shift-pgds.
          end.
        end.
      END.

      FIND FIRST tincome-2 NO-LOCK WHERE
        tincome-2.gds-code = t-2-sug.gds-code AND
        tincome-2.ii       = jj           NO-ERROR.
      IF AVAIlABLE tincome-2 THEN 
      DO:
        /* номер документа из атрибутов */
      { str/tdat-val.i
        tincome-2.doc-code
        {&trdcattr-nids}
        v-attr-value
        v-attr-type
        }
        assign
          pol6       = if v-attr-value = "" or v-attr-value = ?
               then tincome-2.doc-code
               else v-attr-value
          pol8-excel = if v-attr-value = "" or v-attr-value = ?
               then tincome-2.doc-code
               else '="' + v-attr-value + '"'
          .

        ASSIGN 
          pol5      = tincome-2.supp-name
          pol7      = round(tincome-2.qnty1,2)
          pol9      = round(tincome-2.qnty3,2)
          supp-line = yes.
        if p-batch > 0
          and tincome-2.supp-code > 0
          and tincome-2.gds-code > 0
          then 
        do:
          find first buf_shift-pgds-in where
            buf_shift-pgds-in.obj-type = p-obj-type
            and buf_shift-pgds-in.obj-code = p-obj-code
            and buf_shift-pgds-in.shift-date = X-date-end
            and buf_shift-pgds-in.shift-num = X-shift-end
            and buf_shift-pgds-in.gds-code = t-2-sug.gds-code
            and buf_shift-pgds-in.doc-code = tincome-2.doc-code no-error.
          if not available buf_shift-pgds-in then 
          do:
            create buf_shift-pgds-in.
            assign
              buf_shift-pgds-in.obj-type      = p-obj-type
              buf_shift-pgds-in.obj-code      = p-obj-code
              buf_shift-pgds-in.shift-date    = X-date-end
              buf_shift-pgds-in.shift-num     = X-shift-end
              buf_shift-pgds-in.gds-code      = t-2-sug.gds-code
              buf_shift-pgds-in.doc-code      = tincome-2.doc-code
              buf_shift-pgds-in.cli-type-code = substitute("&1&2", tincome-2.supp-type, tincome-2.supp-code)
              buf_shift-pgds-in.cli-name      = tincome-2.supp-name
              buf_shift-pgds-in.fact-qnty     = tincome-2.qnty1
              buf_shift-pgds-in.fact-qnty-2   = tincome-2.qnty2
              .
            release buf_shift-pgds-in.
          end.
        end.
      END.
      _not-empty-group:
      do while true :
        FIND FIRST treal-2 NO-LOCK WHERE
          treal-2.gds-code = t-2-sug.gds-code AND
          treal-2.ii       = jj + v-delta          NO-ERROR.
        if not available treal-2 then 
        do:
          put stream OutStr-html unformatted
            substitute (
            '  <tr> 
                              <td  text_wrap="true">&1</td>
                              <td  text_wrap="true" style="text-align: right;">&2</td>
                              <td  text_wrap="true" style="text-align: right;">&3</td>
                              <td  text_wrap="true" style="text-align: right;">&4</td>
                              <td text_wrap="true" >&5</td>
                              <td colspan="2"  text_wrap="true" style="text-align: right;">&6</td>
                              <td colspan="2"  text_wrap="true" style="text-align: right;">&7</td>
                              <td text_wrap="true" >&8</td>
                              <td text_wrap="true"  style="text-align: right;">&9</td>'
            ,
            pol1,
            if main-line = no then "" else string(pol2,"->>>>>>>>>>>9.99"),
            if main-line = no then "" else string(pol4,"->>>>>>>>>>>9.99"),
            if supp-line = no then "" else pol5,
            if pol6 = "" then "" else string(pol6),
            if supp-line = no then "" else string(pol9,"->>>>>>>>>>>9.99"),
            if supp-line = no then "" else string(pol7,">>>>>>>>>>>9.99"),
            if pay-line = no then "" else pol11,
            if pay-line = no then "" else string(pol12,"->>>>>>>>>>>9.99")
            ).

          put stream OutStr-html unformatted
            substitute (
            '
                    <td text_wrap="true"  style="text-align: right;">&1</td>
                    <td text_wrap="true"  style="text-align: right;">&2</td>
                    <td text_wrap="true"  style="text-align: right;">&3</td>
                    <td text_wrap="true"  style="text-align: right;">&4</td>
                    <td text_wrap="true"  style="text-align: right;">&5</td>
                    <td text_wrap="true" style="text-align: right;">&6</td>
                    </tr>
               '
            ,
            if pay-line = no then "" else string(pol13,"->>>>>>>>>>>9.99"),
            if pay-line = no then "" else string(pol14,"->>>>>>>>>>>9.99"),
            if pay-line = no or pol15 = 0 then "" else string(pol15,"->>>>>>>>>>>9.99"),
            if pay-line = no or pol16 = 0 then "" else string(pol16,"->>>>>>>>>>>9.99"),
            if main-line = no or pol17 = 0 then "" else string(pol17,"->>>>>>>>>>>9.99"),
            if main-line = no then "" else string(pol19,"->>>>>>>>>>>9.99"),
            if main-line = no then "" else string(pol3,"->>>>>>>>>>>9.99"),
            if main-line = no then "" else string(pol18,"->>>>>>>>>>>9.99")
            
            ).

          leave _not-empty-group.
        end.
        if available treal-2 then 
        do:
          if (treal-2.cpay-code <> 0
            or treal-2.curr-code= - 1) and treal-2.discnt-type = -99
            then 
          do:
            FIND FIRST actreal-2 WHERE
              actreal-2.gds-code = 0 AND
              actreal-2.cpay-code = treal-2.cpay-code AND
              actreal-2.curr-code = treal-2.curr-code AND
              actreal-2.is-pay = treal-2.is-pay NO-ERROR.
            if not available actreal-2 then 
            do:
              assign 
                acii = acii + 1.
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
            else 
            do:
              assign 
                actreal-2.qnty1 = actreal-2.qnty1 + round(treal-2.qnty1,2)
                actreal-2.qnty2 = actreal-2.qnty2 + round(treal-2.qnty2,2)
                actreal-2.netto = actreal-2.netto + round(treal-2.netto,2).
            end.
          end.
        
          /*итоги по платежу*/
          if treal-2.is-pay = yes
            and treal-2.curr-code < 0
            and treal-2.out-name begins {&delim-par} then 
          do:
            assign
              v-delta = v-delta + 1
              .
            next _not-empty-group.
          end.
          else 
          do:
            assign
              pol11    = treal-2.out-name
              pol12    = treal-2.qnty1
              pol13    = treal-2.qnty2
              pol14    = treal-2.netto
              pol15    = treal-2.discount-sum
              pol16    = treal-2.brutto
              pol17    = treal-2.chk-qnty
              pay-line = yes
              .
            if p-batch > 0
              and (treal-2.curr-code > 0
              or not (treal-2.curr-code = 0 and treal-2.cpay-code = 0)
              )
              and treal-2.gds-code > 0
              then 
            do:
              find first buf_shift-pgds-out where
                buf_shift-pgds-out.obj-type = p-obj-type
                and buf_shift-pgds-out.obj-code = p-obj-code
                and buf_shift-pgds-out.shift-date = X-date-end
                and buf_shift-pgds-out.shift-num = X-shift-end
                and buf_shift-pgds-out.gds-code = treal-2.gds-code
                and buf_shift-pgds-out.pay-code = treal-2.cpay-code
                and buf_shift-pgds-out.curr-code = treal-2.curr-code
                no-error.
              if not available buf_shift-pgds-out then 
              do:
                find first buf_cash-pay no-lock where
                  buf_cash-pay.cdpay-code = treal-2.cpay-code
                  and  buf_cash-pay.curr-code = treal-2.curr-code no-error.
                create buf_shift-pgds-out.
                assign
                  buf_shift-pgds-out.obj-type    = p-obj-type
                  buf_shift-pgds-out.obj-code    = p-obj-code
                  buf_shift-pgds-out.shift-date  = X-date-end
                  buf_shift-pgds-out.shift-num   = X-shift-end
                  buf_shift-pgds-out.gds-code    = treal-2.gds-code
                  buf_shift-pgds-out.pay-code    = treal-2.cpay-code
                  buf_shift-pgds-out.curr-code   = treal-2.curr-code
                  buf_shift-pgds-out.out-name    = treal-2.out-name
                  buf_shift-pgds-out.cp-type     = (if available buf_cash-pay
                                            and buf_cash-pay.is-cash
                                            then 1
                                            else 2)
                  buf_shift-pgds-out.fact-qnty   = treal-2.qnty1
                  buf_shift-pgds-out.fact-qnty-2 = treal-2.qnty2
                  buf_shift-pgds-out.fact-sum    = treal-2.netto
                  .
                /*              release buf_shift-pgds-out.*/
                .

              end. /*if not available buf_shift-pgds-out then do:*/

            end. /*if p-batch > 0 */
            put stream OutStr-html unformatted
              substitute (
              '  <tr>
                    <td text_wrap="true">&1</td>
                    <td text_wrap="true" style="text-align: right;">&2</td>
                    <td text_wrap="true" style="text-align: right;">&3</td>
                    <td text_wrap="true" style="text-align: right;">&4</td>
                    <td text_wrap="true">&5</td>
                    <td colspan="2" text_wrap="true" style="text-align: right;">&6</td>
                    <td colspan="2" text_wrap="true" style="text-align: right;">&7</td>
                    <td text_wrap="true">&8</td>
                    <td text_wrap="true" style="text-align: right;">&9</td>'
              ,
              pol1,
              if main-line = no then "" else string(pol2,"->>>>>>>>>>>9.99"),
              if main-line = no then "" else string(pol4,"->>>>>>>>>>>9.99"),
              if supp-line = no then "" else pol5,
              if pol6 = "" then "" else string(pol6),
              if supp-line = no then "" else string(pol9,"->>>>>>>>>>>9.99"),
              if supp-line = no then "" else string(pol7,">>>>>>>>>>>9.99"),
              if pay-line = no then "" else pol11,
              if pay-line = no then "" else string(pol12,"->>>>>>>>>>>9.99")
              ).
         /* svv */   
            put stream OutStr-html unformatted
              substitute (
              '
                    <td text_wrap="true"  style="text-align: right;">&1</td>
                    <td text_wrap="true"  style="text-align: right;">&2</td>
                    <td text_wrap="true"  style="text-align: right;">&3</td>
                    <td text_wrap="true"  style="text-align: right;">&4</td>
                    <td text_wrap="true"  style="text-align: right;">&5</td>
                    <td text_wrap="true"  style="text-align: right;">&6</td>
                    </tr>
               
                    
               '
              ,
              if pay-line = no then "" else string(pol13,"->>>>>>>>>>>9.99"),
              if pay-line = no then "" else string(pol14,"->>>>>>>>>>>9.99"),
              if pay-line = no or pol15 = 0 then "" else string(pol15,"->>>>>>>>>>>9.99"),
              if pay-line = no or pol16 = 0 then "" else string(pol16,"->>>>>>>>>>>9.99"),
              if main-line = no or pol17 = 0 then "" else string(pol17,"->>>>>>>>>>>9.99"),
              if main-line = no then "" else string(pol19,"->>>>>>>>>>>9.99"),
              if main-line = no then "" else string(pol3,"->>>>>>>>>>>9.99"),
              if main-line = no then "" else string(pol18,"->>>>>>>>>>>9.99")
              
              ).
            leave _not-empty-group.
          end.
        end.
      end. /*do whiel true*/

      if jj <= t-2-sug.lines then 
        if main-line = yes then 
        do:
          assign 
            accum-sug-4  = accum-sug-4  + round(pol3,2)
            accum-sug-5  = accum-sug-5  + round(pol4,2)
            accum-sug-17 = accum-sug-17 + round(pol18,2)
            accum-sug-18 = accum-sug-18 + round(pol19,2).
        end.

      if supp-line = yes then 
      do:
        if tincome-2.is-fact = yes then 
        do:
          assign 
            accum-sug-9  = accum-sug-9  + round(pol7,2)
            accum-sug-11 = accum-sug-11 + round(pol9,2).
        end.
      end.
      if pay-line = yes then 
      do:
        if treal-2.cpay-code <> 0
          and treal-2.curr-code <>  - 1
          then 
        do:
          if treal-2.discnt-type = -99 or treal-2.cpay-code < 0 then
          do:
            assign 
              accum-sug-14 = accum-sug-14 + round(pol12,2)
              accum-sug-15 = accum-sug-15 + round(pol13,2)
              accum-sug-16 = accum-sug-16 + round(pol14,2).
          end.
        end.
      end.
    END. /* DO jj = 1 TO t-2.lines */

    IF LAST( t-2-sug.main-code ) THEN 
    DO:
      /* печатаем итоги */
      assign 
        pol1  = "ИТОГО"
        pol3  = accum-sug-4
        pol4  = accum-sug-5
        pol7  = accum-sug-9
        pol9  = accum-sug-11
        POL11 = "ИТОГО РАСХОД"
        pol12 = accum-sug-14
        pol13 = accum-sug-15
        pol14 = accum-sug-16
        pol18 = accum-sug-17
        pol19 = accum-sug-18.
/* svv */
      put stream OutStr-html unformatted
        substitute (
        '        
        
        <tr>
                    <th text_wrap="true"  style="text-align: left; vertical-align: middle;">&1</th>
                    <th ></th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&2</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&3</th>
                    <th ></th>
                    <th colspan="2"  text_wrap="true" style="text-align: right; vertical-align: middle;">&4</th>
                    <th colspan="2"  text_wrap="true" style="text-align: right; vertical-align: middle;">&5</th>
                    <th  text_wrap="true" style="text-align: right; vertical-align: middle;">&6</th>
                    <th text_wrap="true"  style="vertical-align: middle;">&7</th>
                    <th text_wrap="true"  style="text-align: right; vertical-align: middle;">&8</th>
                    <th text_wrap="true"  style="text-align: right; vertical-align: middle;">&9</th>
                                      
                    
                    '
        ,
        pol1,
        string(pol4,"->>>>>>>>>>>9.99"),
        pol5,
        string(pol9,"->>>>>>>>>>>9.99"),
        string(pol7,"->>>>>>>>>>>9.99"),
        pol11,
        string(pol12,"->>>>>>>>>>>9.99"),
        string(pol13,"->>>>>>>>>>>9.99"),
        string(pol14,"->>>>>>>>>>>9.99")
        ).
      put stream OutStr-html unformatted
        substitute (
        '
            <th text_wrap="true" style="text-align: right; vertical-align: middle;"></th>
            <th text_wrap="true" style="text-align: right; vertical-align: middle;"></th>       
            <th text_wrap="true" style="text-align: right; vertical-align: middle;"></th>
            <th  text_wrap="true" style="text-align: right; vertical-align: middle;">&4</th>
            </tr>
            '
        ,
        string(pol15,"->>>>>>>>>>>9.99"),
        string(pol16,"->>>>>>>>>>>9.99"),
        string(pol17,"->>>>>>>>>>>9.99"),
        string(pol19,"->>>>>>>>>>>9.99"),
        string(pol3,"->>>>>>>>>>>9.99"),
        string(pol18,"->>>>>>>>>>>9.99")
        ).
      /* печатаем подитоги по всем расходам по всем топливам */
      if can-find( first actreal-2 no-lock ) then 
      do:
        assign 
          pol11 = "     в том числе:".
        put stream OutStr-html unformatted
          substitute (
          '  <tr>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th colspan="2"></th>
                    <th colspan="2"></th>
                    <th text_wrap="true">&1</th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                </tr>'
          ,
          pol11
          ).



        assign 
          areal-is-pay-qnty1 = 0
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
        
          if actreal-2.is-pay = yes then 
          do:
            
            if actreal-2.curr-code >= 0 then
              assign areal-is-pay-qnty1 = areal-is-pay-qnty1 + round(actreal-2.qnty1,2)
                areal-is-pay-qnty2 = areal-is-pay-qnty2 + round(actreal-2.qnty2,2)
                areal-is-pay-netto = areal-is-pay-netto + round(actreal-2.netto,2).
          end.
          else 
          do:
            assign 
              areal-no-pay-qnty1 = areal-no-pay-qnty1 + round(actreal-2.qnty1,2)
              areal-no-pay-qnty2 = areal-no-pay-qnty2 + round(actreal-2.qnty2,2)
              areal-no-pay-netto = areal-no-pay-netto + round(actreal-2.netto,2) .
          end.

          assign 
            pol11 = actreal-2.out-name
            pol12 = actreal-2.qnty1
            pol13 = actreal-2.qnty2
            pol14 = actreal-2.netto
            pol15 = actreal-2.brutto
            pol16 = actreal-2.discount-sum
            pol17 = actreal-2.chk-qnty.
          put stream OutStr-html unformatted
            substitute (
            '  <tr>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th colspan="2"></th>
                    <th colspan="2"></th>
                    <th text_wrap="true">&1</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&2</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&3</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&4</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&5</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&6</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&7</th>
                    <th></th>
               </tr>'
            ,
            pol11,
            string(pol12,"->>>>>>>>>>>9.99"),
            string(pol13,"->>>>>>>>>>>9.99"),
            string(pol14,"->>>>>>>>>>>9.99"),
            if pol15 = 0 then "" else string(pol15,"->>>>>>>>>>>9.99"),
            if pol16 = 0 then "" else string(pol16,"->>>>>>>>>>>9.99"),
            if pol17 = 0 then "" else string(pol17,"->>>>>>>>>>>9.99")
            ).

          if last-of( actreal-2.is-pay ) /* and actreal-2.is-pay <> ? */ then 
          do:
            if actreal-2.discnt-type = -99 or actreal-2.cpay-code < 0 then 
            do:
              if actreal-2.is-pay = yes then 
              do:
                assign 
                  pol11 = "ИТОГО ОПЛАЧ.РАСХОД"
                  pol12 = areal-is-pay-qnty1
                  pol13 = areal-is-pay-qnty2
                  pol14 = areal-is-pay-netto.
              end.
              else 
              do:
                assign 
                  pol11 = "ИТОГО ПРОЧ.РАСХОД"
                  pol12 = areal-no-pay-qnty1
                  pol13 = areal-no-pay-qnty2
                  pol14 = areal-no-pay-netto.
              end.
            end.  
            put stream OutStr-html unformatted
              substitute (
              '  <tr>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th colspan="2"></th>
                    <th colspan="2"></th>
                    <th text_wrap="true">&1</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&2</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&3</th>
                    <th text_wrap="true" style="text-align: right; vertical-align: middle;">&4</th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
               </tr>'
              ,
              pol11,
              string(pol12,"->>>>>>>>>>>9.99"),
              string(pol13,"->>>>>>>>>>>9.99"),
              string(pol14,"->>>>>>>>>>>9.99")
              ).


          end. /* last-of( ctreal-2.is-pay ) and is-pay <> ? */
        END. /* for each actreal-2 */
      END. /* if can-find first actreal */
    END. /* IF LAST t-2.main-code */
  END. /* FOR EACH t-2 */

  put stream OutStr-html unformatted                                                                     
    substitute (
    '
        </tbody>
        '                                                                                      
    , chr(123), chr(125)                                                                                                 
    ).                                                                                                    
  output stream OutStr-html close.
end.
end procedure .

PROCEDURE create-tincome-2 :
  define input parameter p-gds-code  like ub.goods.gds-code   no-undo.
  define input parameter p-doc-code  like ub.trn-doc.doc-code no-undo.
  define input parameter p-qnty1     as   decimal             no-undo.
  define input parameter p-qnty2     as   decimal             no-undo.
  define input parameter p-qnty3    as   decimal             no-undo. 
  define input parameter p-supp-name as   character           no-undo.
  define input parameter p-supp-code like ub.clients.obj-code no-undo.
  define input parameter p-is-fact   as   logical             no-undo.
  define input parameter p-ii        as   integer             no-undo.

  _main:
  DO ON ERROR UNDO _main, RETURN ERROR :
    CREATE tincome-2.
    assign 
      tincome-2.gds-code    = p-gds-code
      tincome-2.doc-code    = p-doc-code
      tincome-2.supp-code   = p-supp-code
      tincome-2.supp-name   = p-supp-name
      tincome-2.is-fact     = p-is-fact
      tincome-2.temperature = ?
      tincome-2.ii          = p-ii        
      tincome-2.qnty1       = p-qnty1
      tincome-2.qnty2       = p-qnty2
      tincome-2.qnty3       = p-qnty3
    no-error.

    IF ERROR-STATUS :ERROR THEN 
    DO: 
      UNDO _main, RETURN ERROR. 
    END.
  END. /* on error */
END PROCEDURE. /* create-tincome-2 */