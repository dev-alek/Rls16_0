/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

часть послеобработки чека

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*проверим суммы из воздуха*/

FOR EACH t-gds No-LOCK WHERE
          t-gds.drc = recid({1}):
  if t-gds.doc-qnty <> 0 or abs(t-gds.price-sum - t-gds.discnt-sum) > 0.0005 then do:
    IF  NOT (t-gds.doc-qnty > 0) = (t-gds.price-sum - t-gds.discnt-sum > 0) OR
        NOT (t-gds.doc-qnty < 0) = (t-gds.price-sum - t-gds.discnt-sum < 0) OR
            ((t-gds.doc-qnty < 0) AND ({1}.netto > 0)) OR
            ((t-gds.doc-qnty > 0) AND ({1}.netto < 0))  then do:
      if (abs(t-gds.price-sum - t-gds.discnt-sum) = 0
      AND
      (
      (
        (t-gds.doc-qnty <> 0
        AND t-gds.is-modificator)
        or
        (t-gds.is-null-price and t-gds.b-code <> ?)
      )
      or (t-gds.doc-qnty <> 0
         and
         (is-100-discnt AND ACCUM-PAY-COUNT > 0)
         )
         )
      )
      or (abs(abs(t-gds.price-sum) - abs(t-gds.discnt-sum)) < 0.2
          and
          is-100-discnt)
      then do:
        /*для модификаторов это разрешено и режим 100 скидки нам все ухайдакает*/
      end.
      else do:
        assign
        for-chk-type = for-chk-type + {&summa-err} + {&comma-char}
        {1}.correct = no
        .
        run write-log-and-file in {2} (
              input 1
            , input log-file-name
            , input 1
            , input substitute(
                                "!!!Чек &1 - ошибочный&2" +
                                "По товару с бар-кодом &3, проданном &4 строками чека, имеются несоответствия количества и суммы" +
                                "&5 либо имеются несоответствия типа чека (продажа/возврат) знаку товарной суммы"
                                , chk-doc.doc-code
                                , {&new-line}
                                , t-gds.b-code
                                , t-gds.num-lines
                                , {&new-line}
                              )
                                              ).

    &if "{2}" = "LEAVE" &then
        LEAVE.
    &endif
      end.
    END.
  END.
END.

/* $Workfile$ e n d */