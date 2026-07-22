block-level on error undo, throw.
/*

$Revision: fb60a1cec256, 3462, rls $
$Author: VSpiridonov $
$Date: 2023/10/16 15:13:34 $
$Workfile: r-beneq2.p $
$Archive: rep/r-beneq2.p $

Заполнение временной таблицы по выручке по кассам по продажам для отчета о выручке

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/13/05
Author: Bakhtadze Natalya
Creation date: 09/13/05

*/

define input parameter cas-num like ub.cash-desk.cash-num no-undo .
define output parameter AllDay-BaseSum as decimal no-undo .
define output parameter AllDay-RublSum as decimal no-undo .

define variable vss-revision    as character no-undo init "$Revision: fb60a1cec256, 3462, rls $":U .
define variable vss-author      as character no-undo init "$Author: VSpiridonov $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:34 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-beneq2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-beneq2.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы по выручке по кассам по продажам для отчета о выручке".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i }
{ rep/r-bentt.i shared }
define variable v-curr-r-b as character no-undo .
define variable v-host-code as integer no-undo .
define variable acc-day-base as decimal no-undo .
define variable acc-day-rubl as decimal no-undo .
define variable acc-day-cnt as integer no-undo .

{ gbl/curr-r-b.i v-curr-r-b }
CASE  X-Radio-Task > 1:
  WHEN YES THEN DO:
    FOR EACH obj-list WHERE
             obj-list.obj-type = {&shop}:
      v-host-code = 0.
      assign
      acc-day-base = 0
      acc-day-rubl = 0
      acc-day-cnt = 0
      .
      { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code no-error }
      for EACH ub.inkas WHERE
          ub.inkas.host-code = v-host-code AND
          ub.inkas.obj-type = obj-list.obj-type AND
          ub.inkas.obj-code = obj-list.obj-code AND
          ub.inkas.status_ = {&fact} AND
            (
            ub.inkas.shift-date >= x-date-start AND
            ub.inkas.shift-date <= x-date-end) NO-LOCK:
      if can-find(first ub.inkas-pay-desk  NO-LOCK WHERE
                        ub.inkas-pay-desk.inkas-code = ub.inkas.inkas-code) then.
      else do:
        run trg/inkpdcr.p (
                       ub.inkas.inkas-code
                      ,ub.inkas.obj-type
                      ,ub.inkas.obj-code) no-error .
        if error-status:error then do:
          return error .
        end.
      end.
      FOR EACH ub.inkas-pay-desk WHERE
             ub.inkas-pay-desk.inkas-code = ub.inkas.inkas-code AND
      (IF cas-num > 0 then ub.inkas-pay-desk.pay-desk = cas-num else TRUE)

             NO-LOCK:
        IF X-Radio-Task = 3 AND
        ((inkas.shift-date = x-date-start AND ub.inkas.shift-num < X-shift-start) OR
        (inkas.shift-date = x-date-end AND  ub.inkas.shift-num > X-shift-end) ) THEN NEXT.
        IF X-Radio-Task = 4 AND ub.inkas.shift-num <> x-shift-alone then next.
        FIND FIRST inkas-num where inkas-num.inkas-code = inkas.inkas-code No-ERROR.
        if not avail inkas-num then do:
            create inkas-num.
            assign
            inkas-num.inkas-code = ub.inkas.inkas-code
            acc-day-cnt  = acc-day-cnt + inkas.num-chk
            .
        end.
          assign
          acc-day-base = acc-day-base + inkas-pay-desk.tot-base
          acc-day-rubl = acc-day-rubl + inkas-pay-desk.tot-rubl
          .
        ACCUMULATE
        ub.inkas-pay-desk.tot-base ( TOTAL )
        ub.inkas-pay-desk.tot-rubl ( TOTAL ) .
    END .
      end. /*      for EACH inkas WHERE*/
      CREATE all-days_sum .
      assign
      all-days_sum.obj-type = obj-list.obj-type
      all-days_sum.obj-code = obj-list.obj-code
      all-days_sum.tot-base = acc-day-base
      all-days_sum.tot-rubl = acc-day-rubl
      all-days_sum.tot-r-b  = (if v-curr-r-b = {&r-b-base}
                              then all-days_sum.tot-base
                              else all-days_sum.tot-rubl)
      /* all-days_sum.chk-cnt = acc-day-cnt */
      .
      release all-days_sum.
    END . /*    FOR EACH obj-list WHERE*/
  END. /*WHEN YES*/
  WHEN NO THEN DO:
    FOR EACH obj-list WHERE
             obj-list.obj-type = {&shop}:
      assign
      acc-day-base = 0
      acc-day-rubl = 0
      acc-day-cnt = 0
      .

      FOR EACH ub.inkas WHERE
            ub.inkas.obj-type = obj-list.obj-type AND
            ub.inkas.obj-code = obj-list.obj-code AND
            ub.inkas.status_ = {&fact} AND
            ub.inkas.doc-date >= x-date-start AND
            ub.inkas.doc-date <= x-date-end NO-LOCK:
      if can-find(first ub.inkas-pay-desk  NO-LOCK WHERE
                        ub.inkas-pay-desk.inkas-code = ub.inkas.inkas-code) then.
      else do:
        run trg/inkpdcr.p (
                       ub.inkas.inkas-code
                      ,ub.inkas.obj-type
                      ,ub.inkas.obj-code) no-error .
        if error-status:error then do:
          return error .
        end.
      end.
      FOR EACH ub.inkas-pay-desk WHERE
             ub.inkas-pay-desk.inkas-code = ub.inkas.inkas-code AND
        (IF cas-num > 0 then ub.inkas-pay-desk.pay-desk = cas-num else TRUE)
             NO-LOCK:
        FIND FIRST inkas-num where inkas-num.inkas-code = ub.inkas.inkas-code No-ERROR.
        if not avail inkas-num then do:
            create inkas-num.
            assign
            inkas-num.inkas-code = ub.inkas.inkas-code
            acc-day-cnt  = acc-day-cnt + inkas.num-chk
            .
        end.
          assign
          acc-day-base = acc-day-base + inkas-pay-desk.tot-base
          acc-day-rubl = acc-day-rubl + inkas-pay-desk.tot-rubl
          .
        ACCUMULATE
        ub.inkas-pay-desk.tot-base ( TOTAL )
        ub.inkas-pay-desk.tot-rubl ( TOTAL ) .
      END.
      end. /*      FOR EACH inkas WHERE*/
      CREATE all-days_sum .
      assign
      all-days_sum.obj-type = obj-list.obj-type
      all-days_sum.obj-code = obj-list.obj-code
      all-days_sum.tot-base = acc-day-base
      all-days_sum.tot-rubl = acc-day-rubl
      all-days_sum.tot-r-b  = (if v-curr-r-b = {&r-b-base}
                              then all-days_sum.tot-base
                              else all-days_sum.tot-rubl)
   /*   all-days_sum.chk-cnt = acc-day-cnt */
      .
      release all-days_sum.
    END . /*FOR EACH OBJ-list*/
  END. /*WHEN NO*/
END CASE.
assign
AllDay-BaseSum = ACCUM TOTAL ub.inkas-pay-desk.tot-base
AllDay-RublSum = ACCUM TOTAL ub.inkas-pay-desk.tot-rubl .