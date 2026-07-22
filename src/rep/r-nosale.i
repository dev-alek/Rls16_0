/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Кусок отчета зависшие товары

Автор: Чернова Светлана Александровна
Дата создания: 06/12/00
Author: Svetlana Chernova
Creation date: 06/12/00

*/
case xClassify :
    when "no-classify":U  then  DO:
        for each tmp#bs no-lock by tmp#bs.percent#1 descending by {1}  :
            run display-str.
            accumulate tmp#bs.qnty    (total ).
            accumulate tmp#bs.sumcost (total ).
            accumulate tmp#bs.sumcrsa (total ).
        end.
        q1 = ACCUM TOTAL  Tmp#bs.Qnty    .
        q2 = ACCUM TOTAL  Tmp#bs.SumCost .
        q3 = ACCUM TOTAL  Tmp#bs.SumCrsa .
        run print-sub-itog in this-procedure ( "" , "" , q1 , q2, q3 ).
    end.
    when "prod":U then DO:
          for each TMP#bs no-lock Break by tmp#bs.percent#1 descending
              by Tmp#bs.prod-type by Tmp#bs.prod-code By {1}
              :
              if first-of(Tmp#bs.prod-code) Then DO:
                  Find first clients where
                            clients.obj-code = Tmp#bs.prod-code and
                            clients.obj-type  = Tmp#bs.prod-type no-lock no-error.
                  run print-sub-head in this-procedure ({&prod-cmp},clients.obj-name).
              end.
              run display-str in this-procedure .
              accumulate Tmp#bs.Qnty        (TOTAL BY Tmp#bs.prod-code).
              accumulate Tmp#bs.SumCost     (TOTAL BY Tmp#bs.prod-code).
              accumulate Tmp#bs.SumCrsa     (TOTAL BY Tmp#bs.prod-code).

              if last-of(tmp#bs.prod-code) then do:
                  q1 = accum total by tmp#bs.prod-code tmp#bs.qnty   .
                  q2 = accum total by tmp#bs.prod-code tmp#bs.sumcost .
                  q3 = accum total by tmp#bs.prod-code tmp#bs.sumcrsa .
                  run print-sub-itog in this-procedure ({&prod-cmp},clients.obj-name,q1,q2,q3).
              end.
          end.
    end.
    when "grp-goods":U then DO:
        For each TMP#bs no-lock Break
            by tmp#bs.percent#1 descending
            by Tmp#bs.grp-name
            By {1}  :
            if first-of(Tmp#bs.grp-name) Then do:
              run print-sub-head in this-procedure ("Группа",tmp#bs.grp-name).
            end.
            run display-str in this-procedure .
            accumulate Tmp#bs.Qnty        (TOTAL BY Tmp#bs.grp-name).
            accumulate Tmp#bs.SumCost     (TOTAL BY Tmp#bs.grp-name).
            accumulate Tmp#bs.SumCrsa     (TOTAL BY Tmp#bs.grp-name).
            if last-of(tmp#bs.grp-name) then do:
                q1 = ACCUM TOTAL BY Tmp#bs.grp-name Tmp#bs.Qnty   .
                q2 = ACCUM TOTAL BY Tmp#bs.grp-name Tmp#bs.SumCost .
                q3 = ACCUM TOTAL BY Tmp#bs.grp-name Tmp#bs.SumCrsa .
                run print-sub-itog in this-procedure ("Группа",tmp#bs.grp-name,q1,q2,q3).
            End.
        End.
 End.
end case.
/* $Workfile$ e n d */