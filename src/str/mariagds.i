/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Форматирование файла товаров для кассы MARIA

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/05/06
Author: Bakhtadze Natalya
Creation date: 01/05/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*выгрузка
таблиц
6 код группы по признаку 1
6 код группы по признаку 2
8 EAN-коды товаров
9   Цены товаров
10  Особые признаки товаров
12  Глобальные коды товаров.
20 - название и налогообложение
21 - название и налогообложение
*/

assign
v-plu = substring(v-plu, length(v-plu) - 4 + 1)
.
if v-marketer-action <> 'd'
and available cash-gds
and (cash-gds.grp-code > 99
or cash-gds.price-sale * 100 >  999999999.0)
then do:
    if cash-gds.grp-code > 99 then
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Товар &1 не может быть передан на кассу &2 &3&4 - № группы на кассе &5 > 99!&6" +
                            "пропускается...."
                            , cash-gds.gds-code
                            , {&cd-buffer}.pos-type
                            , {&shop}
                            , i-obj-code
                            , cash-gds.grp-code
                            , {&new-line}
                            )
                              ).
    if cash-gds.price-sale * 100 >  999999999.0 then
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("!!!Товар &1 не может быть передан на кассу &2 &3&4 - цена &5 > 999999999!&6" +
                            "пропускается...."
                            , cash-gds.gds-code
                            , {&cd-buffer}.pos-type
                            , {&shop}
                            , i-obj-code
                            , cash-gds.price-sale
                            , {&new-line}
                            )
                              ).


    v-view-log = yes.
end.
else do:
  if (v-marketer-action <> 'd'
  and available cash-gds
  and lookup({&petrolium}, cash-gds.unit-cli-type) > 0)
  or (v-marketer-action = 'd'
      and available temp-cd-plu
      and temp-cd-plu.obj-type = {&shop}
      and temp-cd-plu.obj-code = abs(i-obj-code)
      and temp-cd-plu.pos-type = {&cd-type-maria}
      and temp-cd-plu.plu-type = {&petrolium}
      )
  then do:
    /*описание видов НП*/
   /*  пока не пересылаем

    run maria-put in this-procedure (
                                    buffer {&cd-buffer}
                                  , input out
                                  , input fname
                                  , input yes
                                  , input 0
                                  , input no
                                  , input {&tekka-obj-petrol-name}
                                  , input 7
                                  , input v-plu
                                  , input (chk_name + {&delim-par} +
                                        string(cash-gds.gds-namelong, 'X(36)'))).

    */
  define variable v-plu-pet{&vssseq} as character no-undo .
  define buffer  bufpet_cd-plu{&vssseq} for ub.cd-plu.
  for each bufpet_cd-plu{&vssseq}  where
          bufpet_cd-plu{&vssseq}.obj-type = {&shop}
      and bufpet_cd-plu{&vssseq}.obj-code = abs(i-obj-code)
      and bufpet_cd-plu{&vssseq}.pos-type = {&cd-type-maria}
      and bufpet_cd-plu{&vssseq}.plu-type = {&petrolium}
      AND bufpet_cd-plu{&vssseq}.b-code = (if v-marketer-action = 'd'then temp-cd-plu.b-code else buf_cd-plu.b-code)
      AND bufpet_cd-plu{&vssseq}.b-str  = (if v-marketer-action = 'd'then temp-cd-plu.b-str else buf_cd-plu.b-str):
    assign
    v-plu-pet{&vssseq} = TRIM(string( bufpet_cd-plu{&vssseq}.plu-code, "X(40)":U ))
    v-plu-pet{&vssseq} = substring(v-plu-pet{&vssseq}, length(v-plu-pet{&vssseq}) - 4 + 1)
    .
    run maria-put in this-procedure (
                                          buffer {&cd-buffer}
                                        , input out
                                        , input fname
                                        , input yes
                                        , input 0
                                        , input no
                                        , input {&tekka-obj-petrol-price}
                                        , input 1
                                        , input v-plu-pet{&vssseq}
                                        , input (if v-marketer-action = 'u':U
                                                then string(cash-gds.price-sale * 100, "999999999")
                                                else '000000000')
          ).
   /*скидки*/
    /*запишем правила скидок для постоянных клиентов*/
    v-maria-discnt-value = string(0, '999').
      if action <> 'D':U
      and v-marketer-action <> 'D'
      then do:
      _do:
      do v-ii = 1 to num-entries(drgdsrank):
        assign
        v-gds-rule-num = buffer cash-gds:buffer-field(entry(2, entry(v-ii, drgdsrank), {&slash-char})):buffer-value.
        if v-gds-rule-num = 0 then next _do.
        find first buf_dis-rule no-lock where
          buf_dis-rule.obj-type = {&shop}
              AND buf_dis-rule.obj-code = i-obj-code
              AND buf_dis-rule.rule-num = v-gds-rule-num
              AND buf_dis-rule.sts = integer({&current-status-int}) no-error .
        if not available buf_dis-rule then do:
          next _do.
        end.
        else do:
          /*найдем код правила на кассе МАРИЯ*/
          if index(dr-list, string(buf_dis-rule.rule-num) + '-') > 0 then do:
            assign
            v-dop = substring(dr-list, index(dr-list, string(buf_dis-rule.rule-num) + '-':U))
            v-dop = substring(v-dop, 1, index(v-dop, {&comma-char}) - 1)
            v-maria-rule-num = integer(entry(2, v-dop, '-':U)) - 1
            v-maria-discnt-value = string(v-maria-rule-num * 8 + 2, '999')
            .
          end.
        end.
        LEAVE _do.
      end. /*do v-ii = 1*/
    end. /*не D*/
      /*надо найти код резервуара*/
    assign
    entry(integer(v-plu), v-record, {&delim-par}) = v-maria-discnt-value
    no-error
    .
    end. /*for each bufpet_cd-plu  where*/
  end. /*наливной бензин*/
  else do:
    if v-marketer-action = 'D' then do:
    /*удаление и блокирование сделаем обнулением группы!!!!*/
    /*группа по признаку 1*/
    run maria-put in this-procedure (
                                    buffer {&cd-buffer}
                                  , input out
                                  , input fname
                                  , input 0
                                  , input no
                                  , input yes
                                  , input {&tekka-obj-goods-grp1}
                                  , input 5000
                                  , input v-plu
                                  , input '000').
    end. /*режим удаления*/
    else do:
      /*группа по признаку 2*/
      run maria-put in this-procedure (
                                      buffer {&cd-buffer}
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input {&tekka-obj-goods-grp2}
                                    , input 5000
                                    , input v-plu
                                    , input '001').

      /*EAN*/
      define variable maria-good-code{&vssseq} as character no-undo .
    assign
      maria-good-code{&vssseq} = left-trim(ibm-good-code, '0')
      maria-good-code{&vssseq} = fill('0', 14 - length(maria-good-code{&vssseq})) + maria-good-code{&vssseq}
    .
      run maria-put in this-procedure (
                                      buffer {&cd-buffer}
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input {&tekka-obj-goods-ean}
                                    , input 5000
                                    , input v-plu
                                    , input (if v-marketer-action = "U"
                                              then (substring(maria-good-code{&vssseq}, 1, 5) + {&delim-par} +
                                                    substring(maria-good-code{&vssseq}, 6, 14)
                                                  )
                                              else (fill('0', 5) + {&delim-par} + fill('0', 9)))
                                        ).

      /*ЦЕНЫ*/
      run maria-put in this-procedure (
                                      buffer {&cd-buffer}
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input {&tekka-obj-goods-price}
                                    , input 5000
                                    , input v-plu
                                    , input (if v-marketer-action = 'u':U
                                            then string(cash-gds.price-sale * 100, "999999999")
                                            else '000000000')
      ).

      /*статусы*/
      run maria-put in this-procedure (
                                      buffer {&cd-buffer}
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input {&tekka-obj-goods-prop}
                                    , input 5000
                                    , input v-plu
                                    , input (if v-marketer-action = "U"
                                              then (
                                                  string(cash-gds.gds-stat MODULO 2) +     /*cash-gds.gds-stat нижний бит*/
                                                  string(if cash-gds.fp then 1 else 0) +
                                                  string(cash-gds.office) )
                                              else '000')
                                          ).

      /*основные-коды*/
      run maria-put in this-procedure (
                                      buffer {&cd-buffer}
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input {&tekka-obj-goods-code}
                                    , input 5000
                                    , input v-plu
                                    , input (if v-marketer-action = "U"
                                              then  string(cash-gds.b-code, "999999999")
                                              else "000000000")
                                          ).

      /*наименования и налоги*/
      run maria-put in this-procedure (
                                      buffer {&cd-buffer}
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input (if integer(v-plu) <= v-20-part1
                                            then {&tekka-obj-goods-name-part1}
                                            else {&tekka-obj-goods-name-part2})
                                    , input (if integer(v-plu) <= v-20-part1
                                            then 2621
                                            else 2379)
                                    , input v-plu
                                    , input (if v-marketer-action = 'U':U
                                              then string(convert-maria-tax-code(cash-gds.vat-code, 0 /*cash-gds.slt-code*/ , cdtaxlst), "X(8)")
                                              else '00000000':U) + {&delim-par} + chk_name).
      /*группу в самом конце пошлем - потму как она определяет будет искаться товар или нет*/
      /*группа по признаку 1*/
      run maria-put in this-procedure (
                                      buffer {&cd-buffer}
                                    , input out
                                    , input fname
                                    , input yes
                                    , input 0
                                    , input no
                                    , input {&tekka-obj-goods-grp1}
                                    , input 5000
                                    , input v-plu
                                    , input (if cash-gds.grp-code = 0
                                             then '001'
                                             else string(cash-gds.grp-code, "999"))).

    end. /*v-marketer-action <> 'd'*/
  end. /*обычный товар*/
end.

/* $Workfile$ e n d */