/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ищем рецепт типа топливо

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


FOR EACH recipe No-LOCK WHERE
         recipe.recipe-type = {&petrolium-manufacturing},
    FIRST recipe-gds NO-LOCK WHERE
          recipe-gds.artic = {1}.artic AND
          recipe-gds.prod-type = {1}.prod-type AND
          recipe-gds.prod-code = {1}.prod-code AND
          recipe.recipe-code = recipe-gds.recipe-code,
    EACH {3} NO-LOCK WHERE
         {3}.doc-code = {2}.doc-code AND
         {3}.line-num = ({2}.line-num - 1),
    FIRST {4} No-LOCK WHERE
          {4}.artic = recipe.artic AND
          {4}.prod-type  = recipe.prod-type AND
          {4}.prod-code = recipe.prod-code:

        /*строго предполагается что количество компоненты товара и основного товара совпадает!!*/
        assign
        {3}.price-base = {3}.price-base - ({2}.price-base - {2}.discnt)
        {3}.price-service = ({2}.price-base - {2}.discnt)
        {5} = yes
        {2}.price-service = 0
        .
  LEAVE.
END.
IF  NOT {5} then do:
    run write-log-and-file in {7} (
          input 1
        , input log-file-name
        , input 1
        , input substitute(
                            "!!!Чек &1 - ошибочный. &2Не найден основной товар для товара-составляющей &3 &4&5"
                            , {6}.doc-code
                            , {&new-line}
                            , {1}.artic
                            , {1}.prod-type
                            , {1}.prod-code
                          )
                                          ).

    assign
    for-chk-type = for-chk-type + {&comma-char} + {&goods-err}
    {6}.correct = no
    p-view-log = yes
    .
end.

/* $Workfile$ e n d */