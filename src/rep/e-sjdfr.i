/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

фреймы для журнала продаж

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/10/06
Author: Bakhtadze Natalya
Creation date: 01/10/06

*/

/*тип фремйа base или агдд - одна или две валюты*/
/*со скидкой или без*/
/*обычный или в двух единицах*/
/*4 - имя фрейма*/
/*5 - формат поля производ*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&global-define line-format "X(~{&line-length~})"

DEFINE FRAME {4}
        sj-goods.b-code column-label "Код ! " format ">>>>>>>>9"
        sj-goods.artic column-label "Артикул   ! " format "x(16)"
        sj-goods.name column-label "Наименование  ! " format "x(18)"
        sj-goods.prod-name column-label "Производитель! " format "{5}"
&if "{3}" = "twounit" &then
        sj-adv.qnty column-label "Количество !учет.ед.изм" format "->>>>>>>9.<<<"
        sj-adv.qnty-2 column-label "Количество !штуки" format "->>>>>>>9.<<<"
        sj-adv.qnty-3 column-label "Количество !вес" format "->>>>>>>9.<<<"
&else
        sj-adv.qnty column-label "Количество !" format "->>>>>>>9.<<<"
&endif
        sj-adv.price column-label  "Цена!(вал.продаж)"   format ">>>>>>>9.99"
        sj-adv.brutto-sum column-label  "Сумма!(вал.продаж)"  format "->>>>>>>>>9.99"
&if "{1}" = "full" &then
        sj-adv.brutto-sum-r
            column-label "Сумма!(в {&abbr_rublyah})" format "->>>,>>>,>>>,>>9.99"
&endif
&if "{2}" = "discount" &then
        sj-adv.discnt column-label  "Скидка!(вал.продаж)"   format "->>>>>>>9.99"
&endif
        sj-adv.discnt-sum column-label "Сумма скидки!(вал.продаж)" format "->>>>>>>9.99"
        pcnt column-label "%!скидки" format "->>9.9%"
        sj-adv.netto-sum column-label  "Выручка!(вал.продаж)"  format "->>>>>>>9.99" space(0)
&if "{1}" = "full" &then
        sj-adv.netto-sum-r column-label "Выручка!(в {&abbr_rublyah})"
                format "->>>,>>>,>>>,>>9.99" space(0)
&endif
    HEADER  date_string format "X(50)" AT 5
    v-header-sale-curr        format "X(30)"
&if "{1}" = "full" &then
                        string( "Страница " ) AT 165 PAGE-NUMBER(PrnLibStream) AT 175 FORMAT ">>>9" SKIP
  &if "{2}" = "normal" &then
    &if "{3}" = "twounit" &then
&scoped-define line-length 230
      Line format {&line-format}     /*210*/
      AT 1 with width  {&DOS_CW_2} down stream-io use-text no-box.
    &else
&scoped-define line-length 196
      Line format {&line-format}
      AT 1 with width  {&A4_LS} down stream-io use-text no-box.
    &endif


    &else
    &if "{3}" = "twounit" &then
&scoped-define line-length 230
      Line format {&line-format}   /*228*/
      AT 1 with width  {&DOS_CW_2} down stream-io use-text  no-box.
    &else
&scoped-define line-length 196
      Line format {&line-format} /*232*/
      AT 1 with width  {&DOS_CW_2} down stream-io use-text  no-box.
    &endif
  &endif

&else

  "Страница " AT 115 PAGE-NUMBER(PrnLibStream) AT 125 FORMAT ">>>9" SKIP
  &if "{2}" = "normal" &then
    &if "{3}" = "twounit" &then
&scoped-define line-length 196
      Line format {&line-format}
      AT 1  with width  {&A4_LS} down stream-io use-text no-box.
    &else
&scoped-define line-length 136
      Line format {&line-format}
      AT 1  with width  {&A4_CW0} down stream-io use-text no-box.
    &endif

  &else
    &if "{3}" = "twounit" &then
&scoped-define line-length 196
      Line format {&line-format}
      AT 1  with width  {&A4_LS} down stream-io use-text  no-box.
    &else
&scoped-define line-length 196
      Line format {&line-format}
      AT 1  with width  {&A4_LS} down stream-io use-text no-box.
    &endif
  &endif
&endif

&global-define line-put-format ("X(" + string(~{&line-length~}) + ")")
&global-define line-format-base format "X(~{&line-length-base~})"
&global-define line-format-full format "X(~{&line-length-full~})"
&global-define line-put-format-base format ("X(" + string(~{&put-line-length-base~}) + ")")
&global-define line-put-format-rubl format ("X(" + string(~{&put-line-length-rubl~}) + ")")


/* $Workfile$ e n d */