block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: test_ean.p $
$Archive: utl/test_ean.p $

Программа проверки создания штрих-кода

Автор: Перваков Михаил Сергеевич
Дата создания: 10/27/04
Author: Mikhail Pervakov
Creation date: 10/27/04

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: test_ean.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/test_ean.p $":U .
define variable vss-description as character no-undo init "Программа проверки создания штрих-кода".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }


define stream sout .
output stream sout to test_ean.txt .

define variable v-text      as character no-undo .
define variable v-ind       as integer   no-undo .
define variable v-count     as integer   no-undo .
define variable v-b-str     as character no-undo .
define variable v-3of9-code as character no-undo .

for each goods no-lock
:
  assign
    v-count = v-count + 1
  .
  if v-count modulo 10 = 0
  then do:
    run waitfram-show in this-procedure
      (input substitute("Обработано товаров &1", v-count)
      ) .
  end.

  for each bar-code no-lock
    where bar-code.gds-code = goods.gds-code
  :
    for each prod-bc no-lock
      where prod-bc.b-code = bar-code.b-code
    :
      if length(prod-bc.b-str) = 8
      or length(prod-bc.b-str) = 13
      then do:
        assign
          v-b-str = substring(prod-bc.b-str, 1, length(prod-bc.b-str) - 1)
        .
        run str/chk-sum.p
          (input-output v-b-str
          ) no-error.
        if error-status :error
        or v-b-str <> prod-bc.b-str
        then do:
          assign
            v-ind = v-ind + 1
          .
          /* ошибочный бар-код */
          put stream sout unformatted "Код товара:" goods.gds-code skip .
          put stream sout unformatted "Ошибочный штрих код:" prod-bc.b-str skip .
          put stream sout unformatted "Правильный штрих код:" v-b-str skip .
          put stream sout " " skip .

          if v-ind modulo 9 = 0
          then do:
            put stream sout unformatted {&new-page} .
          end.
        end.
        else do:
          if length(prod-bc.b-str) = 8
          then do:
            assign
              v-ind = v-ind + 1
            .
            put stream sout unformatted "Код товара:" goods.gds-code skip .
            put stream sout unformatted "Штрих-код: " prod-bc.b-str skip .
            run gbl/bctotext.p
              (input  {&barcode-ean8}
              ,input  prod-bc.b-str
              ,output v-text
              ) .
            put stream sout unformatted v-text skip .
            put stream sout unformatted v-text skip .
            put stream sout unformatted v-text skip .
            put stream sout unformatted v-text skip .
            put stream sout unformatted " " skip .

            assign
              v-ind = v-ind + 1
            .
            assign
              v-3of9-code = substitute('&1/&2':u
                                      ,goods.gds-code
                                      ,15.55
                                      ) .
            .
            put stream sout unformatted "Контроль цены: " v-3of9-code skip .
            run gbl/bctotext.p
              (input  {&barcode-3of9}
              ,input  v-3of9-code
              ,output v-text
              ) .
            put stream sout unformatted v-text skip .
            put stream sout unformatted v-text skip .
            put stream sout unformatted v-text skip .
            put stream sout unformatted v-text skip .
            put stream sout unformatted " " skip .

            if v-ind modulo 9 = 0
            then do:
              put stream sout unformatted {&new-page} .
            end.
          end.
          else do:
            if length(prod-bc.b-str) = 13
            then do:
              assign
                v-ind = v-ind + 1
              .
              put stream sout unformatted "Код товара:" goods.gds-code skip .
              put stream sout unformatted "Штрих-код: " prod-bc.b-str skip .
              run gbl/bctotext.p
                (input  {&barcode-ean13}
                ,input  prod-bc.b-str
                ,output v-text
                ) .
              put stream sout unformatted v-text skip .
              put stream sout unformatted v-text skip .
              put stream sout unformatted v-text skip .
              put stream sout unformatted v-text skip .
              put stream sout unformatted " " skip .

              assign
                v-ind = v-ind + 1
              .
              assign
                v-3of9-code = substitute('&1/&2':u
                                        ,goods.gds-code
                                        ,15.55
                                        ) .
              .
              put stream sout unformatted "Контроль цены: " v-3of9-code skip .
              run gbl/bctotext.p
                (input  {&barcode-3of9}
                ,input  v-3of9-code
                ,output v-text
                ) .
              put stream sout unformatted v-text skip .
              put stream sout unformatted v-text skip .
              put stream sout unformatted v-text skip .
              put stream sout unformatted v-text skip .
              put stream sout unformatted " " skip .

              if v-ind modulo 9 = 0
              then do:
                put stream sout unformatted {&new-page} .
              end.
            end.
          end.
        end.
      end.
    end.
  end.
end.

output stream sout close .