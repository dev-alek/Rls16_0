/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Заполнение временной таблицы по чекам для отчета о выручке

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter cas-num as integer no-undo .
define input parameter t-time as logical no-undo .
define input parameter v-curr-r-b as character no-undo .
define output parameter AllDay-BaseSum as decimal no-undo .
define output parameter AllDay-RublSum as decimal no-undo .
define output parameter ObjAmount    as      integer no-undo.
define output parameter ChkAmount    as      integer no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы по чекам для отчета о выручке".

{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i }
{ rep/r-bentt.i shared }
{ rep/rep-bt.i }
{ gbl/waitfram.i }


&if "{1}" = "time" &then
{ rep/r-benttm.i shared }
&endif

/* --------------------------------------------------------------------- */
procedure CreateBenefits private :
define input parameter p-obj-type  as character no-undo .
define input parameter p-obj-code  as integer no-undo .
define input parameter p-pay-code  as integer no-undo .
define input parameter p-curr-code as integer no-undo .
define input parameter p-date      as date no-undo .
define input parameter p-sum       as decimal no-undo .
define input parameter p-base      as decimal no-undo .
define input parameter p-rubl      as decimal no-undo .
define buffer buf_benefits for benefits .
define buffer buf_cash-pay for ub.cash-pay .
define buffer buf_currency for ub.currency .

  find first buf_benefits
       where buf_benefits.obj-type  = p-obj-type
         and buf_benefits.obj-code  = p-obj-code
         and buf_benefits.pay-code  = p-pay-code
         and buf_benefits.curr-code = p-curr-code
         and buf_benefits.date_     = p-date no-error .
  if not available buf_benefits then do:
    FIND FIRST buf_cash-pay NO-LOCK
         WHERE buf_cash-pay.cdpay-code = p-pay-code
           AND buf_cash-pay.curr-code  = p-curr-code NO-ERROR.
    FIND FIRST buf_currency NO-LOCK
         WHERE buf_currency.curr-code = p-curr-code NO-ERROR.
    create buf_benefits.
    assign
      buf_benefits.date_     = p-date
      buf_benefits.obj-type  = p-obj-type
      buf_benefits.obj-code  = p-obj-code
      buf_benefits.pay-code  = p-pay-code
      buf_benefits.pay-name  = if available buf_cash-pay then buf_cash-pay.obj-name  else "Неопознанная оплата"
      buf_benefits.curr-code = p-curr-code
      buf_benefits.curr-name = if available buf_currency then buf_currency.curr-name else "Неопознанная валюта"
    .
  end .
  assign
    buf_benefits.tot-sum  = buf_benefits.tot-sum  + p-sum
    buf_benefits.tot-base = buf_benefits.tot-base + p-base
    buf_benefits.tot-rubl = buf_benefits.tot-rubl + p-rubl
    buf_benefits.tot-r-b  = (if v-curr-r-b = {&r-b-base} then buf_benefits.tot-base else buf_benefits.tot-rubl)
  .
  
end procedure . /* end_of CreateBenefits */  
/* ----------------------------------------------------------------------*/
procedure CreateDaySum private :
define input parameter p-obj-type  as character no-undo .
define input parameter p-obj-code  as integer no-undo .
define input parameter p-date      as date no-undo .
define input parameter p-cnt-all   as integer no-undo .
define input parameter p-cnt-nf    as integer no-undo .
define input parameter p-acc-rubl  as decimal no-undo .
define input parameter p-acc-base  as decimal no-undo .
define buffer buf_day_sum for day_sum .
  create buf_day_sum.
  assign
    buf_day_sum.obj-type = p-obj-type
    buf_day_sum.obj-code = p-obj-code
    buf_day_sum.date     = p-date
    buf_day_sum.chk-cnt-all = p-cnt-all
    buf_day_sum.chk-cnt-nf  = p-cnt-nf
    buf_day_sum.tot-rubl    = p-acc-rubl
    buf_day_sum.tot-base    = p-acc-base
  .
end procedure . /* end_of CreateDaySumm */    
/* ----------------------------------------------------------------------*/

define variable acc-curr-sum as decimal no-undo.
define variable acc-curr-base as decimal no-undo.
define variable acc-curr-rubl as decimal no-undo.
define variable acc-sub-curr-sum as decimal no-undo.
define variable acc-sub-curr-base as decimal no-undo.
define variable acc-sub-curr-rubl as decimal no-undo.
/*define variable acc-base as decimal no-undo. 09/IV-2019 не используется */
/*define variable acc-rubl as decimal no-undo. 09/IV-2019 не используется */
define variable acc-count-ln as integer no-undo. /* кол-во линий оплат для отображения в хронометраже */
define variable acc-count-step as integer no-undo . /* шаг хронометража */
define variable acc-date-base as decimal no-undo.
define variable acc-date-rubl as decimal no-undo.
define variable acc-date-count as integer no-undo. /* кол-во чеков за день всего */
define variable acc-sub-date-base as decimal no-undo.
define variable acc-sub-date-rubl as decimal no-undo.
define variable acc-sub-date-count as integer no-undo.  /* кол-во чеков за день нефискальных */
define variable acc-day-rubl as decimal no-undo .
define variable acc-day-base as decimal no-undo .
define variable acc-day-cnt as integer no-undo . /* кол-во чеков за все дни */
define variable acc-day-nf  as integer no-undo . /* кол-во чеков за все дни нефискальных */
define variable v-skip-line    as logical no-undo . /* true: ghj */
define variable v-is-sub-count as logical no-undo . /* true: вычесть чек из общего количества как нефискальный */
define variable found as logical no-undo .
/*define variable v-is-sub-pay   as logical no-undo. true: вычесть оплату чека как нефискального 15/IV-2019 вычитается через sub-count */

  acc-count-ln = 0 .
  acc-count-step = 0 .

/* @FUTU: если выбраны "Все магазины", то делать суммирование по всем,
          т.е. без for each obj-list и без where chk-doc.obj-type = ... */  
FOR EACH obj-list WHERE
         obj-list.obj-type = {&shop} NO-LOCK :
  /* X-radio-task =
    "Календарные даты", 1,
    "Сменные сутки", 2,
    "Сменные сутки и порядок", 3,
    "По сменам", 4  
  */
  CASE X-radio-task > 1:
    WHEN YES THEN DO:
      _chk-doc3:
      FOR EACH chk-doc NO-LOCK WHERE
                chk-doc.obj-type = obj-list.obj-type
            AND chk-doc.obj-code = obj-list.obj-code
            AND chk-doc.shift-date >= x-date-start
            AND chk-doc.shift-date <= x-date-end
            AND (IF cas-num > 0 then chk-doc.pay-desk = cas-num else TRUE)
      BREAK
      BY chk-doc.obj-type
      BY chk-doc.obj-code
      BY chk-doc.shift-date :
        if first-of( chk-doc.shift-date ) then do:
          assign
          acc-date-rubl = 0
          acc-date-base = 0
          acc-date-count = 0
          acc-sub-date-rubl = 0
          acc-sub-date-base = 0
          acc-sub-date-count = 0
          .
        end.
        v-skip-line = 
        (
             X-Radio-task = 3 AND
             ((chk-doc.shift-date = x-date-start AND chk-doc.shift-num < X-shift-start) OR
              (chk-doc.shift-date = x-date-end   AND chk-doc.shift-num > X-shift-end))
        ) OR (
             X-radio-task = 4 AND
             chk-doc.shift-num <> X-Shift-Alone
&if "{1}" = "time" &then
        ) OR (
             T-time AND
             NOT can-find (FIRST times WHERE times.time1 <= chk-doc.chk-time
                                         AND times.time2 >= chk-doc.chk-time)
&endif
        ) .
        if not v-skip-line then do :
          v-is-sub-count = (  lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0  ).
          found = false .
          if v-is-sub-count then do :
            for first chk-pay No-LOCK
               WHERE chk-pay.doc-code = chk-doc.doc-code
                 and chk-pay.tot-sum <> 0 :
              found = true .
              leave .
            end .
          end .
          else do :
            for EACH chk-pay No-LOCK
               WHERE chk-pay.doc-code = chk-doc.doc-code
                 and chk-pay.tot-sum <> 0
            break BY chk-pay.pay-code
                  BY chk-pay.curr-code :
              found = true .
              { rep/e-bcrben.i chk-doc.shift-date }
            end .
          end .
          if found then assign
            acc-date-count     = acc-date-count     + 1
            acc-sub-date-count = acc-sub-date-count + 1 when (v-is-sub-count)
          .
        end .
        if last-of( chk-doc.shift-date ) then do:
          run CreateDaySum in this-procedure
          ( obj-list.obj-type
          , obj-list.obj-code
          , chk-doc.shift-date
          , acc-date-count
          , acc-sub-date-count
          , acc-date-rubl - acc-sub-date-rubl
          , acc-date-base - acc-sub-date-base
          ) .
        end.
      END. /*FOR EACH chk-doc*/
    END. /*WHEN YES*/
    WHEN NO THEN DO:
      _chk-doc4:
      FOR EACH chk-pay No-LOCK WHERE
              chk-pay.obj-type = obj-list.obj-type AND
              chk-pay.obj-code = obj-list.obj-code AND
              chk-pay.chk-date >= x-date-start AND
              chk-pay.chk-date <= x-date-end AND
              chk-pay.tot-sum <> 0
               /* 15/IV-2019  перенесено внутрь first-of chk-pay.doc-code
              , FIRST chk-doc NO-LOCK WHERE
                    chk-pay.doc-code = chk-doc.doc-code  AND
                    (IF cas-num > 0 then chk-doc.pay-desk = cas-num else TRUE) */
      BREAK
      BY chk-pay.obj-type
      BY chk-pay.obj-code
      BY chk-pay.chk-date
      BY chk-pay.doc-code
      BY chk-pay.pay-code
      BY chk-pay.curr-code :
        if first-of( chk-pay.chk-date ) then do:
          assign
          acc-date-rubl = 0
          acc-date-base = 0
          acc-date-count = 0
          acc-sub-date-rubl = 0
          acc-sub-date-base = 0
          acc-sub-date-count = 0
          .
        end.
        if first-of( chk-pay.doc-code ) then do:
          IF cas-num > 0 then
          find FIRST chk-doc NO-LOCK
               WHERE chk-doc.doc-code = chk-pay.doc-code
                 AND chk-doc.pay-desk = cas-num no-error .
          else 
          find FIRST chk-doc NO-LOCK
               WHERE chk-doc.doc-code = chk-pay.doc-code no-error .
          if available chk-doc then do :
          
&if "{1}" = "time" &then
          v-skip-line = 
          (
             T-time AND
             NOT can-find (FIRST times WHERE times.time1 <= chk-doc.chk-time
                                         AND times.time2 >= chk-doc.chk-time)
          ) .
&else 
          v-skip-line = false . 
&endif
          end .
          else v-skip-line = true . 

          if not v-skip-line then do :
          v-is-sub-count = (  lookup(string(chk-doc.chk-type), {&no-sale-receipt-codes}) > 0  ).
          assign
            acc-date-count     = acc-date-count     + 1
            acc-sub-date-count = acc-sub-date-count + 1 when (v-is-sub-count)
          .
          end .
        end.
        if not v-skip-line then do :
        { rep/e-bcrben.i chk-pay.chk-date  }
        end .
        if last-of( chk-pay.chk-date ) then do:
          run CreateDaySum in this-procedure
          ( obj-list.obj-type
          , obj-list.obj-code
          , chk-pay.chk-date
          , acc-date-count
          , acc-sub-date-count
          , acc-date-rubl - acc-sub-date-rubl
          , acc-date-base - acc-sub-date-base
          ) .
        end.
      END. /*FOR EACH chk-doc*/
    END. /*WHEN NO*/
  END CASE.
END. /*FOR EACH obj-list*/

  assign
    AllDay-BaseSum = 0.0
    AllDay-RublSum = 0.0
    ObjAmount = 0
    ChkAmount = 0
  .
  for each day_sum break by day_sum.obj-code :
    if first-of (day_sum.obj-code) then do :
      assign
        acc-day-base = 0
        acc-day-rubl = 0
        acc-day-cnt  = 0
        acc-day-nf   = 0
      .
    end .
    assign
      day_sum.tot-r-b  = (if v-curr-r-b = {&r-b-base} then day_sum.tot-base else day_sum.tot-rubl)
      acc-day-rubl = acc-day-rubl + day_sum.tot-rubl
      acc-day-base = acc-day-base + day_sum.tot-base
      acc-day-cnt  = acc-day-cnt  + day_sum.chk-cnt-all
      acc-day-nf   = acc-day-nf   + day_sum.chk-cnt-nf  
    .
    if last-of (day_sum.obj-code) then do :
      create all-days_sum .
      assign
        all-days_sum.obj-type = day_sum.obj-type
        all-days_sum.obj-code = day_sum.obj-code
        all-days_sum.tot-base = acc-day-base
        all-days_sum.tot-rubl = acc-day-rubl
        all-days_sum.tot-r-b  = (if v-curr-r-b = {&r-b-base} then acc-day-base else acc-day-rubl)
        all-days_sum.chk-cnt-all = acc-day-cnt
        all-days_sum.chk-cnt-nf  = acc-day-nf
        AllDay-BaseSum = AllDay-BaseSum + all-days_sum.tot-r-b
        AllDay-rublSum = AllDay-RublSum + acc-day-rubl
        ObjAmount      = ObjAmount + 1
        ChkAmount      = ChkAmount + (all-days_sum.chk-cnt-all - all-days_sum.chk-cnt-nf)
      .
    end .
  end . /* end_of for_each day_sum */
  
/* $Workfile$ e n d */