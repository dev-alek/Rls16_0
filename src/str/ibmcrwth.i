/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

послеобработка чеков МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


for each t-wth No-LOCK where
          t-wth.drc = recid({1}):
  if {1}.chk-type <> 0 then do:
    var-sum-r-b = 0.
    if ( (string({1}.chk-type) = {&encashment} or string({1}.chk-type) = {&cd-expense}) AND
      t-wth.sum > 0) OR
      (string({1}.chk-type) = {&cd-fund} AND t-wth.sum < 0)
      then do:
      assign
      {2} = {2} + {&summa-err} + {&comma-char}
      {1}.correct = no
      p-view-log = yes
      .
      if {3} then do:
        run write-log-and-file in {4} (
              input 1
            , input log-file-name
            , input 1
            , input substitute(
                                "!!!Чек МЦ &1 - ошибочный&2Знак суммы по всем строкам МЦ не соответствует типу чека&3" +
                                "Код оплаты МЦ: &4 код валюты МЦ &5"
                                , {1}.doc-code
                                , {&new-line}
                                , {1}.chk-type
                                , t-wth.pay-code
                                , t-wth.curr-code
                              )
                                              ).

      end.
    end. /* ( (string({1}.chk-type) = {&encashment} or string({1}.chk-type) = {&cd-expense}) AND*/
    if string({1}.chk-type) = {&pay-transfer} then do:
      assign
      var-sum-r-b = var-sum-r-b + t-wth.sum-r-b
      .
    end.
  end. /* if {1}.chk-type <> 0:*/
end.
if string({1}.chk-type) = {&pay-transfer} AND ABS(var-sum-r-b) > 0.05 then do:
  assign
  {2} = {2} + {&summa-err} + {&comma-char}
  {1}.correct = no
  p-view-log = yes
  .
  if {3} then do:
    run write-log-and-file in {4} (
          input 1
        , input log-file-name
        , input 1
        , input substitute(
                            "!!!Чек МЦ &1 - ошибочный&2Знак суммы по всем строкам МЦ не соответствует типу чека&3"
                            , {1}.doc-code
                            , {&new-line}
                            , {1}.chk-type
                          )
                                          ).

  end.
end.


/* $Workfile$ e n d */