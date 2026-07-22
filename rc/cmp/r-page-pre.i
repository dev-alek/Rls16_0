
&glob o-firm     1
&glob o-currency 2
&glob o-choice   3
&glob o-all      4

&glob bef-obj-currency  currency
&glob bef-obj-choice    choice
&glob bef-obj-firm      firm
&glob bef-obj-all       all
&glob obj-currency  "{&bef-obj-currency}":U
&glob obj-choice    "{&bef-obj-choice}":U
&glob obj-firm      "{&bef-obj-firm}":U
&glob obj-all       "{&bef-obj-all}":U

&glob schet-all-firm   1
&glob schet-firm       2
&glob schet-choice     3
&glob schet-one        4
&glob schet-rubl       5
&glob schet-no-rubl    6
&glob schet-choice-val 7

/*  это все в одном параметре в 8 param-UNIVERSAL */

&glob Excel-yes     1       /* Есть галка и експорт в текстовый файл с разделителем таб  */
&glob Arc-ot-yes    2       /* Есть проверка расчета архива оборотов      */
&glob Arc-stk-yes   3       /* Есть проверка расчета архива остатков      */
&glob send-check    4       /* Есть проверка хождения чеков на базу       */
&glob Show-Crsa     5       /* Есть чекбокс по продажныи ценам            */
&glob Show-Cost     6       /* Есть чекбокс по учетным ценам              */
&glob Show-Sale     7       /* Есть чекбокс по цена документов            */
&glob Arc-supp-yes  8       /* Есть проверка расчета архива поставщиков   */
&glob Excel-yes-com 9       /* Есть галка и експорт через com             */
&glob format-folder 10      /* Есть страница с закладкой ФОРМАТ           */
&glob Arc-hold-yes  11      /* Есть проверка расчета межфирменных архивов */
&glob Arc-aht-yes   12      /* Есть проверка расчета архива по типу приобретения */
&glob Customer-yes  13      /* Есть блок ВЫБОР КОНТРАГЕНТА                */
&glob Schet-yes     14      /* Есть блок ВЫБОР СЧЕТА                      */

&glob hide-schet-all-firm   15
&glob hide-schet-firm       16
&glob hide-schet-choice     17
&glob hide-schet-one        18
&glob hide-schet-rubl       19
&glob hide-schet-no-rubl    20
&glob hide-schet-choice-val 21

&glob Print-List-Hist-yes   22  /* Есть печать истории формирования списков           */
&glob Arc-fin-yes           23  /* Есть проверка расчета фин архива                   */
&glob Arc-strong-yes        24  /* Есть Проверка архива жесткая, строго присутствует  */

/* Для Excel */
&glob xlMaxCols   256



&glob xlMaxRows   64000
&glob xlGeneral   1
&glob xlCenter   -4108
&glob xlNone     -4142
&glob xlRight    -4152
&glob xlLeft     -4131
&glob xlTop      -4160
&glob xlJustify  -4130
&glob xlCenter   -4108
&glob xlContinuous  1
&glob xlThin        2
&glob xlAutomatic  -4105
&glob xlFill        5

&glob g-all 1
&glob g-grp 2
&glob g-prod 3
&glob g-choice 4
&glob g-one 5
&glob g-spis 6
&glob g-grp-prod 7

&glob max-len-str 6000