/*

$Revision$
$Author$
$Date$
$Workfile: $
$Archive$

Таблица режимов кассы IBS TH

Автор: Белоусов Илья Александрович
Дата создания: 07/23/08
Author: Ilia Belousov
Creation date: 07/23/08

Required:

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define md "substitute( '&1.&2' , p-cd-mode, p-cd-submode)"
&glob g-ed-msgs  38
&glob g-fr-width-0  20
&glob g-fr-width-1  36
&glob g-fr-width-2  48
&glob g-fr-width-3  40

&glob g-fr-width-00  26
&glob g-fr-width-10  18
&glob g-fr-width-20  24
&glob g-fr-width-30  28

/*препроцессор для стандартного ввода линий чека*/
&glob g-buf_tt_line_update    buf_tt-line.qnty           = ABSOLUTE(v-src-qnty)  ~
                            buf_tt-line.qnty-str         = STRING(ABSOLUTE(v-src-qnty), "->>,>>>,>>9.999":U)  ~
                            buf_tt-line.price            = ABS(v-src-price)  ~
                            buf_tt-line.price-rub        = ABS(v-src-price-rub)  ~
                            buf_tt-line.price-STR        = STRING(ABSOLUTE(v-src-price-rub), "->>,>>>,>>9.99":U) ~
                            buf_tt-line.summ-netto       = ABSOLUTE(v-src-sum-netto)                          ~
                            buf_tt-line.summ-netto-rub   = ABSOLUTE(v-src-sum-netto-rub)                          ~
                            buf_tt-line.summ-brutto      = ABSOLUTE(v-src-sum)                                 ~
                            buf_tt-line.summ-brutto-rub  = ABSOLUTE(v-src-sum-rub)                                 ~
                            buf_tt-line.unit-base        = v-unit-base ~
                            buf_tt-line.summ-discont     = ABSOLUTE(v-src-discnt) ~
                            buf_tt-line.summ-discont-rub = ABSOLUTE(v-src-discnt-rub)

/* Препроцессор для стандартного вида сообщения  на экране при изменении товарной линии   */
&glob g-p-message-gds_set  substitute  ( "&1 &2x&3"  ~
                                    , substring(buf_tt-line.line-name + fill(' ':U,{&g-ed-msgs}),~
                                                1, {&g-ed-msgs} - 1 - length(trim(string(buf_tt-line.qnty,"->>>,>>>,>>9.<<<")) + 'X' + trim(string(buf_tt-line.price,"->>>,>>>,>>9.99")))  )~
                                    , trim(string(buf_tt-line.qnty,"->>>,>>>,>>9.<<<"))~
                                    , trim(string(buf_tt-line.price,"->>>,>>>,>>9.99"))           )


/* список режимов АРМ Касса */
define temp-table tt-cdm no-undo
   field cd-mode       as character
   field cdm-name       as character
   field cdm-next-modes as character
   field cdm-btns       as character

   index pi is primary unique
      cd-mode
.

/* Связка режимов и подрежимов кассы с функциями */
define temp-table tt-func-key no-undo
   field cd-mode     as character
   field cd-submode  as character
   field key-name    as character
   field key_label   as character
   field key_func    as character
   field cng-context as logical
   field func-param  as character

   index pi is primary unique
      cd-mode
      cd-submode
      key-name
.

/* заголовок чека */
define temp-table tt-head-check no-undo
    field doc-code      as character
    field chk-type      as INTEGER
    field exch-rate     as decimal
    field exch-scales   as decimal
    field cash-rate     as decimal
    field cash-scales   as integer
    field chk-seller-name    as character
    field chk-seller-code    as integer
    field d-card        as character
    field cli-type      as character
    field cli-code      as integer
    field obj-name      as character
    field hand-discounted as character

    index pi as primary unique
          doc-code
.

/* строка чека в браузере */
define temp-table tt-line no-undo
    field type             as integer /* 0 - goods, 1 - pays */
    field num              as integer
    field line-code        as integer
    field curr-code        as integer
    field fr-pay-code      as integer
    field line-name        as character
    field line-name-2      as character
    field qnty             as decimal
    field price            as decimal
    field price-rub        as decimal
    field summ-brutto      as decimal
    field summ-brutto-rub  as decimal
    field qnty-str         as character /* только для показа */
    field price-str        as character /* только для показа */
    field summ-netto       as decimal
    field summ-netto-rub   as decimal
    field summ-discont     as decimal
    field summ-discont-rub as decimal
    field src              as character
    field pass             as integer
    field ord-chk-num      as character
    field ord-line-num     as integer
    field slip             as character
    field pay-card         as character
    field line-seller-name as character
    field line-seller-code as integer
    field printed          as logical     /* строка уже ушла на ФР */
    field hand-discounted  as character   /* тип ручной скидки на строке */
    field unit-base        as character

    index pi as primary unique
          type
          num
    index by-src
          src
    index by-ord
          ord-chk-num
          ord-line-num
    index by-hand
          hand-discounted
.

/* список подрежимов
define temp-table tt-pay no-undo
    field num           as integer
    field cdpay-code    as integer
    field summ-pay      as decimal
    field src           as character
    index pi as primary unique
          num
.
*/

/* список чеков закачиваемых в продажу или возврат */
define temp-table tt-open-check no-undo
    field doc-code      as character
    field chk-type      as INTEGER

    index pi as primary unique
          doc-code
.
define buffer bufbr_tt-line for tt-line .



{ gbl/fr-lib.i }
{ gbl/sb-lib.i }
{ gbl/disp-lib.i }
{ gbl/eventlib.i }
{ str/libthpos.i }
{ str/libthpos_def.i }
{ gbl/getcntxt.i def }
{ gbl/cd-mode1.i }
{ gbl/gbclcode.i }
{ gbl/cur-time.i } /* 21/I-2019 - cur-time.i убрано из gbclcode.i */

{ str/prep-lay.i def-tt }
{ str/libthpos_bh-def.i }


define variable v-serial-code       as char              no-undo .
define variable v-r-b               as character         no-undo .
define variable v-base-code         as integer           no-undo .
define variable v-src               as character         no-undo .
define variable v-src-qnty          as decimal           no-undo .
define variable v-src-price         as decimal           no-undo .
define variable v-src-price-rub     as decimal           no-undo .
define variable v-src-discnt        as decimal           no-undo .
define variable v-src-discnt-rub    as decimal           no-undo .
define variable v-src-sum           as decimal no-undo .
define variable v-src-sum-rub       as decimal no-undo .
define variable v-src-sum-netto     as decimal no-undo .
define variable v-src-sum-netto-rub as decimal no-undo .
define variable v-for-discnt-doc    as decimal no-undo .
define variable v-for-discnt-rubl   as decimal no-undo .
define variable v-for-discnt-r-b    as decimal no-undo .
define variable v-unit-base         as character no-undo .   /* 12345 */

define variable v-pay-type          as integer  INIT ?   no-undo .
define variable v-curr-num-0        as integer           no-undo .
define variable v-curr-type-0       as integer           no-undo .
define variable v-2-tot-sum         as decimal           no-undo .
define variable v-fr-shift-open     as integer           no-undo .
define variable v-null-summ         as decimal           no-undo .
define variable v-fr-last-shift-num as integer           no-undo .
/*
define variable v-reopen-chk        as character         no-undo .
*/
define variable v-fr-width          as integer           no-undo .   /* ширина ленты ФР в символах */
define variable v-fr-width-bold     as integer           no-undo .   /* ширина ленты ФР в ЖИРНЫХ символах */
define variable v-emul-mode         as logical           no-undo .
define variable v-curr-base-code    as integer           no-undo .
define variable v-cd-base-code      as integer           no-undo .
define variable v-cd-base-name      as character         no-undo .
define variable v-discnt-chk        as decimal           no-undo .

define variable v-fix-summ-pay      as decimal           no-undo .

define variable v-exch-rate         as decimal           no-undo .
define variable v-exch-scales       as decimal           no-undo .
define variable v-cash-rate         as decimal           no-undo .
define variable v-cash-scales       as integer           no-undo .

define variable v-input-time        as integer           no-undo .  /* длительность ввода штрихкода    */
define variable v-time-close        as integer           no-undo .  /* момент закрытия последнего чека */

define variable v-cashier           as integer           no-undo .  /* кассир */
define variable v-cashier-psn-code  as integer           no-undo .  /* код кассира */

define variable v-context-serial    as char           no-undo .   /* номер ФР, приписанного к кассе */

/* предыдущий режим перед автоматической блокировкой */
define variable v-cd-mode-pre       as character INIT "0"   no-undo .
define variable v-cd-submode-pre    as character INIT "0"   no-undo .

/* предыдущий режим перед ручной блокировкой */
define variable v-cd-mode-user-pre       as character INIT "0"   no-undo .
define variable v-cd-submode-user-pre    as character    no-undo .

/* режим пересчета чека */
define variable v-recalc    as logical      no-undo.

/* параметры дисконтной карты */
define variable v-d-card            as character no-undo .
define variable v-cli-type          as character no-undo .
define variable v-cli-code          as integer no-undo .
define variable v-obj-name          as character no-undo .

/*доп инфо*/
define variable v-aux-mess          as character no-undo .

/* суммы по чеку */
define variable v-summ-netto        as decimal      no-undo .
define variable v-summ-brutto       as decimal      no-undo .
define variable v-summ-discont      as decimal      no-undo .
define variable v-summ-pay          as decimal      no-undo .
define variable v-summ-netto-rub    as decimal      no-undo .
define variable v-summ-brutto-rub   as decimal      no-undo .
define variable v-summ-discont-rub  as decimal      no-undo .
define variable v-summ-pay-rub      as decimal      no-undo .
define variable v-summ-fr           as decimal      no-undo .
define variable v-sum-for-pay       as decimal      no-undo .

/* параметры ТРК по необходимости перенести во входные параметры */
define variable v-pump           as integer no-undo .
define variable v-nozzle-code    as integer no-undo .
define variable v-pl-code        as integer no-undo .
define variable v-pass-gds       as integer no-undo .
define variable v-fbr-depart     as integer no-undo .
define variable v-write-off-code as integer no-undo .
define variable v-num            as integer      no-undo.

/* привязка к другому чеку, отложенному или продажному */
define variable v-ord-chk-num    as character no-undo .
define variable v-ord-line-num   as integer no-undo .

define variable v-disc-type    as character /* INIT {&discnt-v-pcnt} */  no-undo. /* per - процентная, abs - абсолютная */

define variable v-rmethod-coeff    as decimal      no-undo.
define variable v-rmethod-type    as character    no-undo.
define variable v-nalc    as integer      no-undo.
define variable v-manual-discnt    as logical      no-undo.
define variable v-salesman-mandatory    as logical      no-undo.
define variable v-customer-display-adv    as character /* EXTENT 2 */   no-undo.
define variable v-cash-drawer-limit    as decimal      no-undo.
define variable v-cashless-system    as character    no-undo.
define variable v-cash-drawer-open    as logical      no-undo.
define variable v-cash-shift    as logical      no-undo.
define variable v-max-netto    as decimal      no-undo.
define variable v-print-good-code    as logical      no-undo.
define variable v-cliche-lines    as character /* extent 6 */ no-undo.
define variable v-advert-text    as character  /* EXTENT 3 */ no-undo.
define variable v-cash-drawer-level    as integer      no-undo.
define variable v-customer-display-plug    as logical      no-undo.
define variable v-card-reader-plug    as logical      no-undo.
define variable v-cutter    as logical      no-undo.
define variable v-cash-drawer-plug-port    as integer      no-undo.
define variable v-cash-drawer-plug    as logical      no-undo.
define variable v-cash-drawer-plug-imp    as integer      no-undo.
define variable v-keyboard-type    as character      no-undo.
define variable v-close-good-chk    as logical      no-undo.
define variable v-cp-lst    as character    no-undo.

define variable v-cash-drawer-plug-type   as integer   no-undo .
define variable v-keyboard-layout-id      as character no-undo .
define variable v-customer-display-type   as character no-undo .
define variable v-customer-display-port   as character no-undo .
define variable v-log-level               as integer   INIT -1 no-undo .
define variable v-clear-cash-counter      as LOGICAL   no-undo .
define variable v-qnty-change             as LOGICAL   no-undo .
define variable v-screen-type             as character no-undo .
define variable v-screen-layout-id        as character no-undo .
define variable v-with-context            as LOGICAL   INIT TRUE no-undo . /* YES - реальный чек, NO - копия мимо ФР и TH */
define variable v-chk-name        as character no-undo .
define variable v-gds-code        as integer no-undo .
define variable v-frpay-code as integer no-undo .


define variable v-pay-names    as character /* extent 4 */ no-undo.
/*
define variable v-card-n    as character    no-undo.
define variable v-card-cl   as character    no-undo.
*/
define variable v-cashier-name    as character    no-undo.

define variable v-disp-msg-1    as character    no-undo.
define variable v-disp-msg-2    as character    no-undo.
define variable v-found-num     as integer      no-undo.
define variable v-found-str     as character      no-undo.

define buffer buf_temp-layout-elem-rule      for temp-layout-elem-rule .
/*Разрешена работа с признаками*/
define variable v-doc-prt        as logical     no-undo.

/*==========================================================================*/
procedure fill-tt :
do
on error undo, return error
:
   run add-cdm in this-procedure ( {&cd-mode-ready}      , ""                    , "1,2,3,4,5,6", "" ) .
   run add-cdm in this-procedure ( {&cd-mode-sale}       , "Продажа"             , "0,3,4"      , "" ) .
   run add-cdm in this-procedure ( {&cd-mode-ret}        , "Возврат"             , "0,3,4"      , "" ) .
   run add-cdm in this-procedure ( {&cd-mode-block}      , "Блокировка"          , "0,6"        , "" ) .
   run add-cdm in this-procedure ( {&cd-mode-func}       , "Доп. функция"        , "0"          , "" ) .
   run add-cdm in this-procedure ( {&cd-mode-close-shift}, "Смена закрыта"       , "0"          , "" ) .
   run add-cdm in this-procedure ( {&cd-mode-inv}        , "Инвентаризация"      , "0,3"        , "" ) .
   run add-cdm in this-procedure ( {&cd-mode-wth}        , "Чеки МЦ"             , "0,3"        , "" ) .
   run add-cdm in this-procedure ( {&cd-mode-user-block} , "Блокировка"          , "0,6"        , "" ) .

   /*
   run add-cdsm in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}      , "Товар"               , "" ) .
   run add-cdsm in this-procedure ( {&cd-mode-sale}, {&cd-submode-qnty}       , "Количество"          , "" ) .
   run add-cdsm in this-procedure ( {&cd-mode-sale}, {&cd-submode-pay}        , "Платеж"              , "" ) .
   run add-cdsm in this-procedure ( {&cd-mode-sale}, {&cd-submode-card-chk}   , "Карта"               , "" ) .
   run add-cdsm in this-procedure ( {&cd-mode-sale}, {&cd-submode-seller}     , "Продавец"            , "" ) .

   run add-cdsm in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}      , "Товар"               , "" ) .
   run add-cdsm in this-procedure ( {&cd-mode-ret}, {&cd-submode-qnty}       , "Количество"          , "" ) .
   run add-cdsm in this-procedure ( {&cd-mode-ret}, {&cd-submode-pay}        , "Платеж"              , "" ) .
   run add-cdsm in this-procedure ( {&cd-mode-ret}, {&cd-submode-card-chk}   , "Карта"               , "" ) .
   run add-cdsm in this-procedure ( {&cd-mode-ret}, {&cd-submode-seller}     , "Продавец"            , "" ) .
   */

   /* 0, "Готовность" */
     run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}   , "F1"            , "Товар (F1)"         , "1978"           , YES , "" ) .
     run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}   , "CTRL-S"        , "Выгрузка в XML"       , "export-chk-to-xml"     , NO  , "" ) .
/*     run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}   , "F7"            , "Продажа"       , "chk-sale-open"    , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}   , "F3"            , "Возврат"       , "1987"           , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}   , "F5"            , "Наличн."       , "1995"           , yes  , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}   , "F6"            , "Х-отчет"       , "1990"           , yes  , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}   , "F7"            , "Инвент."       , "chk-inv-open"     , YES , "" ) .   */
/*   run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}   , "F7"            , "БК итоги"      , "2001"           , YES  , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}   , "F8"            , "Чеки МЦ"       , "1999"           , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}   , "F9"            , "Инф. о т."     , "2003"           , YES  , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}   , "F10"           , "Д.ящик"        , "1988"          , YES  , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}   , "F11"           , "Блок"          , "1993"         , YES , "" ) .*/
/*     run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}   , "+"           , "Z-отчет"       , "1989"      , YES , "" ) .*/
     run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}, "-"         , "Дата"          , "set-date"         , YES  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}   , "v-src-input"   , "Код товара"    , "add-sale"         , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}   , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ready}, {&cd-submode-goods}   , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .

   /* 1, "Продажа" бар-код*/
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "del"           , "Удалить"       , "del-gds-line"     , YES  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "F1"            , "Товар (F1)"         , "1978"       , YES , "" ) .
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "F9"            , "Аннул-я"       , "1979"          , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "F3"            , "Оплата"        , "1983"          , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "F4"            , "Продавец"      , "1997"           , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "F5"            , "ДК"            , "1998"             , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "F6"            , "Печать"        , "1982"   , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "F7"            , "Поиск"         , "1994"         , YES , "" ) .*/
   /*
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "F8"            , "Ск. стр"       , "1980"     , YES , "" ) .
   */
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "F2"            , "Ск. чек"       , "1981"      , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "F10"           , "Открыть"       , "1985"       , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "F11"           , "Блок"          , "1993"         , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "F12"           , "Отложить"      , "1984"          , YES , "" ) .*/
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "v-src-input"   , "Код товара"    , "add-gds-line"     , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "*"             , "Коррекция"     , "2010"     , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-goods}    , "CTRL-S"        , "Выгрузка в XML"       , "export-chk-to-xml"     , NO  , "" ) .

   /* 1, "Прод
   ажа" изменение количества */
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-qnty}  , "b-exit"        , "Выход"         , "pr-esc"           , YES  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-qnty}  , "v-src-input"   , "Количество"    , "upd-line"         , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-qnty}  , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .

   /* 1, "Продажа" карта*/
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-card-chk} , "b-exit"        , "Выход"         , "pr-esc"           , YES  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-card-chk} , "v-src-input"   , "Номер карты"   , "input-card"       , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-card-chk} , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-card-chk} , "F1"            , "Карта (F1)"         , "card-select"      , YES , "" ) .

   /* 1, "Продажа" оплата*/
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-pay}      , "del"           , "Удалить"       , "del-gds-line"     , YES  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-pay}      , "b-exit"        , "Выход"         , "pr-esc"           , YES  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-pay}      , "F1"            , "Тип опл. (F1)"         , "pay-select"       , no   , "" ) .
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-pay}    , "F2"            , "Нал."          , "pay-nal"          , NO  , "" ) .*/
   /*
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-pay}      , "F3"            , "Карта 1"       , "pay-1"            , NO  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-pay}      , "F4"            , "Карта 2"       , "pay-2"            , NO  , "" ) .
   */
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-pay}      , "F5"            , "VISA"          , "pay-3"            , NO  , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-pay}      , "F9"            , {&summ100}      , "pay-fix-summ"     , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-pay}      , "F10"           , {&summ1000}     , "pay-fix-summ"     , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-pay}      , "F11"           , "Блок"          , "1993"         , YES , "" ) .*/
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-pay}      , "v-src-input"   , "Сумма оплаты"  , "input-pay-sale"   , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-pay}      , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .

   /* 1, "Регистрация продавца" */
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-seller}   , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-seller}   , "F11"           , "Блок"          , "1993"         , YES , "" ) .*/
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-seller}   , "v-src-input"   , "Код продавца"  , "input-saller"     , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-seller}   , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-seller}   , "F1"            , "Продавец(F1)"         , "saller-select"    , YES , "" ) .

   /* 1, "Продажа" поиск*/
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-find-gds} , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-find-gds} , "v-src-input"   , "Код товара"    , "input-find-str"   , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-find-gds} , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .

   /* 1, "Продажа" скидка на чек*/
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-tot-dsc}    , "b-exit"        , "Выход"         , "pr-esc"             , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-tot-dsc}    , "v-src-input"   , "   "       , "input-discont"      , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-tot-dsc}    , "F1"             , "Тип скидки (F1)"         , "disc-type-select"       , NO  , "" ) .
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-tot-dsc}  , "F2"            , "Абсол."        , "discont-abs"        , NO  , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-tot-dsc}  , "F3"            , "Проц."         , "discont-per"        , NO  , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-tot-dsc}  , "F4"            , "5%"            , "discont-fix"        , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-tot-dsc}  , "F5"            , "100"           , "discont-fix"        , YES , "" ) .*/
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-tot-dsc}  , "ESC"           , "Выход"         , "pr-esc"             , YES , "" ) .

   /* 1, "Продажа" скидка на линию*/
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-line-dsc}  , "b-exit"          , "Выход"        , "pr-esc"             , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-line-dsc}  , "v-src-input"     , "   "      , "input-discont"      , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-line-dsc}          , "F1"             , "Тип скидки (F1)"         , "disc-type-select"       , NO  , "" ) .
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-line-dsc}  , "F2"            , "Абсол."       , "discont-abs"        , NO  , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-line-dsc}  , "F3"            , "Проц."        , "discont-per"        , NO  , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-line-dsc}  , "F4"            , "5%"           , "discont-fix"        , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-line-dsc}  , "F5"            , "1"            , "discont-fix"        , YES , "" ) .*/
   run add-key-func  in this-procedure ( {&cd-mode-sale}, {&cd-submode-line-dsc}  , "ESC"             , "Выход"        , "pr-esc"             , YES , "" ) .

   /* 2, "Возврат" бар-код*/
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "F1"            , "Товар (F1)"         , "1978"       , YES , "" ) .
/*   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "F9"            , "Аннуляция"     , "1979"          , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "F3"            , "Цена"          , "2004"        , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "F4"            , "Оплата"        , "1983"          , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "F5"            , "Карта"         , "1998"             , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "F6"            , "Печать"        , "1982"   , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "F7"            , "Поиск"         , "1994"         , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "F8"            , "По прод."      , "1986"      , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "F2"            , "Выход"         , "1985"       , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "F11"           , "Блок"          , "1993"         , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "F12"           , "Отложить"      , "1984"          , YES , "" ) .*/
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "v-src-input"   , "Код товара"    , "add-gds-line"     , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "*"             , "Коррекция"     , "2010"     , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "del"           , "Удалить"       , "del-gds-line"     , YES  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-goods}     , "CTRL-S"        , "Выгрузка в XML"       , "export-chk-to-xml"     , NO  , "" ) .

   /* 1, "Возврат" изменение количества */
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-qnty}   , "v-src-input"   , "Количество" , "upd-line"            , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-qnty}   , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-qnty}   , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .

   /* 2, "Возврат" цена */
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-price}     , "v-src-input"   , "Цена"          , "input-price"      , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-price}     , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-price}     , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .

   /* 2, "Возврат" оплата*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-pay}       , "F2"            , "Нал."          , "pay-nal"          , NO  , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-pay}       , "F11"           , "Блок"          , "1993"         , YES , "" ) .*/
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-pay}       , "v-src-input"   , "Сумма оплаты"  , "input-pay-sale"   , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-pay}       , "F1"            , "Тип платежа(F1)"         , "pay-select"       , no  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-pay}       , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-pay}       , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .

   /* 1, "Возврат" поиск*/
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-find-gds}  , "v-src-input"   , "Код товара"    , "input-find-str"   , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-find-gds}  , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-find-gds}  , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .

   /* 1, "Возврат" карта*/
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-card-chk} , "b-exit"        , "Выход"         , "pr-esc"           , YES  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-card-chk} , "v-src-input"   , "Номер карты"   , "input-card"       , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-card-chk} , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-card-chk} , "F1"            , "Карта (F1)"         , "card-select"      , YES , "" ) .

   /* 1, "Возврат Регистрация продавца" */
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-seller}   , "b-exit"        , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-seller}   , "v-src-input"   , "Код продавца"  , "input-saller"     , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-seller}   , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-ret}, {&cd-submode-seller}   , "F1"            , "Продавец(F1)"         , "saller-select"    , YES , "" ) .

   /*9, "Блокировка пользователем" */
/*   run add-key-func  in this-procedure ( {&cd-mode-user-block}, {&cd-submode-goods}   , "F11"      , "Разблок"       , "cd-unblock"       , yes , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-user-block}, {&cd-submode-goods}   , "F12"      , "Z-отчет"       , "1989"      , yes , "" ) . */
   run add-key-func  in this-procedure ( {&cd-mode-user-block}, {&cd-submode-goods}   , "b-exit"   , "Выход"         , "pr-esc"         , YES  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-user-block}, {&cd-submode-goods}   , "ESC"      , "Выход"         , "pr-esc"           , YES , "" ) .

   /*4, "Блокировка" */
/*   run add-key-func  in this-procedure ( {&cd-mode-block}, {&cd-submode-goods}   , "F12"           , "Z-отчет"       , "1989"      , yes  , "hour24" ) . */
   run add-key-func  in this-procedure ( {&cd-mode-block}, {&cd-submode-goods}   , "F12"           , "Дата"          , "set-date"         , YES   , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-block}, {&cd-submode-goods}   , "b-exit"        , "Выход"         , "pr-esc"           , YES  , "sht-cls" ) .
   run add-key-func  in this-procedure ( {&cd-mode-block}, {&cd-submode-goods}   , "ESC"           , "Выход"         , "pr-esc"           , YES  , "sht-cls" ) .

   /* 5, "Доп. функция" */
   run add-key-func  in this-procedure ( {&cd-mode-func}, {&cd-submode-goods}    , "b-exit"        , "Выход"         , "pr-esc"         , YES  , "" ) .
/*   run add-key-func  in this-procedure ( {&cd-mode-func}, {&cd-submode-goods}    , "F11"           , "Блок"          , "1993"         , YES , "" ) .*/
   run add-key-func  in this-procedure ( {&cd-mode-func}, {&cd-submode-goods}    , "v-src-input"   , "Ввод"          , "input-adv"        , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-func}, {&cd-submode-goods}     , "ESC"          , "Выход"         , "pr-esc"           , YES , "" ) .

   /* 6, "Смена закрыта" */
/*   run add-key-func  in this-procedure ( {&cd-mode-close-shift}, {&cd-submode-goods}, "F2"         , "Продажа"       , "chk-sale-open"    , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-close-shift}, {&cd-submode-goods}, "F3"         , "Возврат"       , "1987"     , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-close-shift}, {&cd-submode-goods}, "F5"         , "Дата"          , "set-date"         , YES  , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-close-shift}, {&cd-submode-goods}, "F8"         , "Чеки МЦ"       , "1999"          , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-close-shift}, {&cd-submode-goods}, "F11"        , "Блок"          , "1993"         , YES , "" ) .*/
/* run add-key-func  in this-procedure ( {&cd-mode-close-shift}, {&cd-submode-goods}, "F12"        , "Откр.См."      , "shift-open"       , NO  , "" ) . */
   run add-key-func  in this-procedure ( {&cd-mode-close-shift}, {&cd-submode-goods}, "v-src-input", "Код товара"    , "add-sale"         , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-close-shift}, {&cd-submode-goods}, "ESC"        , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-close-shift}, {&cd-submode-goods}, "b-exit"     , "Выход"         , "pr-esc"         , YES  , "" ) .

   /* Чеки МЦ готовность */
   run add-key-func  in this-procedure ( {&cd-mode-wth}, {&cd-submode-goods}          , "F1"            , "Тип чека (F1)"         , "wth-type-select"       , YES  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-wth}, {&cd-submode-goods}          , "v-src-input"   , "   "         , "wait-wth-type"       , NO , "" ) .
/*   run add-key-func  in this-procedure ( {&cd-mode-wth}, {&cd-submode-goods}        , "F2"            , "Инкасс."       , "chk-inc-open"     , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-wth}, {&cd-submode-goods}        , "F3"            , "Внос"          , "chk-fnd-open"     , YES , "" ) .*/
   run add-key-func  in this-procedure ( {&cd-mode-wth}, {&cd-submode-goods}          , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-wth}, {&cd-submode-goods}          , "b-exit"        , "Выход"         , "pr-esc"         , YES  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-wth}, {&cd-submode-goods}          , "del"           , "Удалить"       , "del-gds-line"     , YES  , "" ) .
/*   run add-key-func  in this-procedure ( {&cd-mode-wth}, {&cd-submode-goods}        , "F9"            , "Аннул-я"       , "1979"          , YES , "" ) .*/

   /* Чеки МЦ оплата*/
/* run add-key-func  in this-procedure ( {&cd-mode-wth}, {&cd-submode-pay}       , "F10"           , "Д.ящик"        , "1988"          , YES  , "" ) . */
   run add-key-func  in this-procedure ( {&cd-mode-wth}, {&cd-submode-pay}       , "v-src-input"   , "Сумма"         , "input-summ"       , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-wth}, {&cd-submode-pay}       , "ESC"           , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-wth}, {&cd-submode-pay}       , "b-exit"        , "Выход"         , "pr-esc"         , YES  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-wth}, {&cd-submode-pay}       , "del"           , "Удалить"       , "del-gds-line"     , YES  , "" ) .
   /*run add-key-func  in this-procedure ( {&cd-mode-wth}, {&cd-submode-pay}       , "F9"            , "Аннул-я"       , "1979"          , YES , "" ) .*/

   /* Инвентаризация бар-код*/
   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-goods}    , "F1"             , "Товар (F1)"         , "1978"       , YES  , "" ) .
/*   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-goods}    , "F9"             , "Аннул-я"       , "1979"          , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-goods}    , "F6"             , "Печать"        , "1982"   , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-goods}    , "F7"             , "Поиск"         , "1994"         , YES , "" ) .*/
/*   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-goods}    , "F11"            , "Блок"          , "1993"         , YES , "" ) .*/
   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-goods}    , "*"              , "Коррекция"     , "2010"     , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-goods}    , "CURSOR-UP"      , "Вверх"         , "cr-down"          , NO  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-goods}    , "CURSOR-DOWN"    , "Вниз"          , "cr-up"            , NO  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-goods}    , "v-src-input"    , "Код товара"    , "add-gds-line"     , YES  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-goods}    , "del"            , "Удалить"       , "del-gds-line"     , yes  , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-goods}    , "ESC"            , "Выход"         , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-goods}    , "b-exit"         , "Выход"         , "pr-esc"         , YES  , "" ) .

   /* Инвентаризаци изменение количества */
   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-qnty}  , "v-src-input"   , "Изменение количества" , "upd-line"   , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-qnty}  , "ESC"           , "Выход"          , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-qnty}  , "b-exit"        , "Выход"          , "pr-esc"         , YES  , "" ) .

   /* 1, "Инв" поиск*/
   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-find-gds} , "v-src-input"   , "Код товара"     , "input-find-str"   , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-find-gds} , "ESC"           , "Выход"          , "pr-esc"           , YES , "" ) .
   run add-key-func  in this-procedure ( {&cd-mode-inv}, {&cd-submode-find-gds} , "b-exit"        , "Выход"          , "pr-esc"         , YES  , "" ) .

end. /* do on error */
end procedure. /* fill-tt */




/*==========================================================================*/
procedure add-cdm :
define input parameter p-cd-mode as character          no-undo.
define input parameter p-name as character        no-undo.
define input parameter p-next as character        no-undo.
define input parameter p-btns as character        no-undo.

do
on error undo, return error
:
   create tt-cdm.
   assign
      tt-cdm.cd-mode       = p-cd-mode
      tt-cdm.cdm-name       = p-name
      tt-cdm.cdm-next-modes = p-next
      tt-cdm.cdm-btns       = p-btns
   .
end. /* do on error */
end procedure. /* add-cdm */



/*==========================================================================*/
procedure add-key-func :
define input parameter p-cdm         as character        no-undo .
define input parameter p-cdsm        as character        no-undo .
define input parameter p-name        as character        no-undo .
define input parameter p-label       as character        no-undo .
define input parameter p-func        as character        no-undo .
define input parameter p-cng-context as LOGICAL          no-undo .
define input parameter p-func-param  as character        no-undo .

do
on error undo, return error
:
   create tt-func-key.
   assign
      tt-func-key.cd-mode     = p-cdm
      tt-func-key.cd-submode  = p-cdsm
      tt-func-key.key-name    = p-name
      tt-func-key.key_label   = p-label
      tt-func-key.key_func    = p-func
      tt-func-key.cng-context = p-cng-context
      tt-func-key.func-param  = p-func-param
   .
end. /* do on error */
end procedure. /* add-key-func */

/* $Workfile$ e n d */



/*==========================================================================*/
procedure shift-open :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   if not v-emul-mode
      then do:
      { gbl/fr-shtop.i
         p-message
         p-ok
         no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
      end.
   end.
   else do:
      assign
         p-ok = TRUE
      .
   end.


end. /* do on error */
end procedure. /* shift-open */




/*==========================================================================*/
procedure 1989 : /* z-отчет */
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define variable v-chk-fr-num    as character    no-undo.
define variable v-doc-code      as character no-undo .
define variable v-reg-value    as character    no-undo.
define variable v-reg-name     as character    no-undo.
define variable glog as logical no-undo .

do
on error undo, return error
:
   if p-cd-mode = {&cd-mode-ready}
   and p-cd-submode = {&cd-submode-goods}
   then do:
     message
     substitute("Вы действительно хотите сделать Z-отчет?")
     view-as alert-box question buttons yes-no update glog.
     if not glog then return.
   end.
   { gbl/eventlib-event-log.i
      0
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      '':U
      '':U
      '*':U
      '':U
      '':U
      '':U
      TODAY
      78
      TIME
      'U':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      0
      v-cntxt-userid
      no-error
   }

   run adm/chk-pass.w   ( input parparentproc
                        , input v-cntxt-userid
                        , input v-cntxt-db-num
                        , input "actn_ibsthpos-z-rep"
                        , input FALSE
                        , output p-message
                        , output p-ok
                        ) .
   if not p-ok
   then do:
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         '':U
         '':U
         p-message
         '':U
         '':U
         '':U
         TODAY
         80
         TIME
         'E':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }
      return.
   end.


   define variable v-fr-mode            as integer      no-undo.
   define variable v-fr-time            as integer      no-undo.
   define variable v-fr-date            as date         no-undo.
   define variable v-fr-last-shift-date as date         no-undo.
   define variable v-fr-lic             as character    no-undo.
   define variable v-fr-serial          as char    no-undo.

   if not v-emul-mode
   then do:
      { gbl/fr-ctrl.i
         v-cash-drawer-open
         p-message
         p-ok
         v-fr-mode
         v-fr-time
         v-fr-date
         v-fr-last-shift-date
         v-fr-last-shift-num
         v-fr-lic
         v-fr-shift-open
         v-fr-serial
         no-error
      }
/*      message*/
/*         "X"  1*/
/*         skip v-fr-last-shift-num*/
/*      view-as alert-box information.*/
      if v-fr-shift-open = 0
      or  v-fr-mode = 4
      then do:
         assign
            p-message = "Смена закрыта. Отчет снять нельзя."
            p-ok = No
         .
         return .
      end.
   end.



   /* Итоги по БК */
   run 2001 in this-procedure ( input-output p-cd-mode
                              , input-output p-cd-submode
                              , output p-message
                              , output p-ok
                              ) .

   if not p-ok
   then do:
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         '':U
         '':U
         p-message
         '':U
         '':U
         '':U
         TODAY
         80
         TIME
         'E':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }
      return.
   end. /* Итоги по БК */

   /* инкассация */


   if v-clear-cash-counter
   then do:
      if  v-fr-shift-open = 24
      then do:
         message
            'Истекли 24 часа открытой смены. Инкассацию сделать нельзя.'
            skip 'Счетчик наличности будет обнулен без чека инкассации'
         view-as alert-box information.
         { str/libthpos_clear-cash-counter.i  }
      end.
      else do:
         assign
            p-cd-mode    = {&cd-mode-wth}
         .

         run chk-inc-open  ( input-output p-cd-mode
                           , input-output p-cd-submode
                           , output p-message
                           , output p-ok
                           ) .
         if not p-ok
         then do:
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
         { gbl/fr-get-reg.i
         'cash':U
         241
         v-reg-value
         v-reg-name
         p-message
         p-ok
         no-error
         }
         if error-status:error
         then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
         else do:
            assign
               v-src = v-reg-value
            .
         end.
         run input-summ in this-procedure ( input-output p-cd-mode
                                          , input-output p-cd-submode
                                          , output p-message
                                          , output p-ok
                                          ) .
         if not p-ok
         then do:
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
         end.

         { str/libthpos_clear-cash-counter.i  }
      end.
   end. /* инкассация */

   if not v-emul-mode
      then do:

      { gbl/fr-shtcl.i
         p-message
         p-ok
         no-error
      }
      if error-status:error
      OR not p-ok
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
   end.

   { str/libthpos_create-chk-doc.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      INTEGER({&rcpt-z-rep})
      v-cashier
      v-cashier-psn-code
      v-doc-code
      v-exch-rate
      v-exch-scales
      v-cash-rate
      v-cash-scales
      no-error
   }
   if error-status:error
   then do:
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         '':U
         '':U
         p-message
         '':U
         '':U
         '':U
         TODAY
         80
         TIME
         'E':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }
      return.
   end.

   /* сбор информации из регистров ФР */
   if  not v-emul-mode
   then do:

      /* Sales */
      { gbl/fr-get-reg.i
        'cash':U
        0
        v-reg-value
        v-reg-name
        p-message
        p-ok
        no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      else do:
         { str/libthpos_cfr.i
           v-doc-code
           {&cdt-cfreg}
           'Sales':U
           DECIMAL(v-reg-value)
           0
           no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.

      /* !!! ChSales */

      /* SaleDisk */
      { gbl/fr-get-reg.i
        'cash':U
        64
        v-reg-value
        v-reg-name
        p-message
        p-ok
        no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      else do:
         { str/libthpos_cfr.i
           v-doc-code
           {&cdt-cfreg}
           'SaleDisk':U
           DECIMAL(v-reg-value)
           0
           no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.

      /* SaleUpLift */
      { gbl/fr-get-reg.i
        'cash':U
        68
        v-reg-value
        v-reg-name
        p-message
        p-ok
        no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      else do:
         { str/libthpos_cfr.i
           v-doc-code
           {&cdt-cfreg}
           'SaleUpLift':U
           DECIMAL(v-reg-value)
           0
           no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.

      /* !!! SaleCancel */
      /* !!! ChSaleAnnul */

      /* PayCash */
      { gbl/fr-get-reg.i
        'cash':U
        72
        v-reg-value
        v-reg-name
        p-message
        p-ok
        no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      else do:
         { str/libthpos_cfr.i
           v-doc-code
           {&cdt-cfreg}
           'PayCash':U
           DECIMAL(v-reg-value)
           0
           no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.

      /* PayCoup */
      { gbl/fr-get-reg.i
        'cash':U
        76
        v-reg-value
        v-reg-name
        p-message
        p-ok
        no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      else do:
         { str/libthpos_cfr.i
           v-doc-code
           {&cdt-cfreg}
           'PayCoup':U
           DECIMAL(v-reg-value)
           0
           no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.

      /* PayCard */
      { gbl/fr-get-reg.i
        'cash':U
        80
        v-reg-value
        v-reg-name
        p-message
        p-ok
        no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      else do:
         { str/libthpos_cfr.i
           v-doc-code
           {&cdt-cfreg}
           'PayCard':U
           DECIMAL(v-reg-value)
           0
           no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.

      /* PayAux */
      { gbl/fr-get-reg.i
        'cash':U
        84
        v-reg-value
        v-reg-name
        p-message
        p-ok
        no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      else do:
         { str/libthpos_cfr.i
           v-doc-code
           {&cdt-cfreg}
           'PayAux':U
           DECIMAL(v-reg-value)
           0
           no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.

      /* Returns */
      { gbl/fr-get-reg.i
        'cash':U
        2
        v-reg-value
        v-reg-name
        p-message
        p-ok
        no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      else do:
         { str/libthpos_cfr.i
           v-doc-code
           {&cdt-cfreg}
           'Returns':U
           DECIMAL(v-reg-value)
           0
           no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.

      /* !!! ChReturns */


      /* RetDisc */
      { gbl/fr-get-reg.i
        'cash':U
        66
        v-reg-value
        v-reg-name
        p-message
        p-ok
        no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      else do:
         { str/libthpos_cfr.i
           v-doc-code
           {&cdt-cfreg}
           'RetDisc':U
           DECIMAL(v-reg-value)
           0
           no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.

      /* RetUpLift */
      { gbl/fr-get-reg.i
        'cash':U
        70
        v-reg-value
        v-reg-name
        p-message
        p-ok
        no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      else do:
         { str/libthpos_cfr.i
           v-doc-code
           {&cdt-cfreg}
           'RetUpLift':U
           DECIMAL(v-reg-value)
           0
           no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.

      /* !!! RetCancel */
      /* !!! ChRetAnnul */



      /* RetCash */
      { gbl/fr-get-reg.i
        'cash':U
        74
        v-reg-value
        v-reg-name
        p-message
        p-ok
        no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      else do:
         { str/libthpos_cfr.i
           v-doc-code
           {&cdt-cfreg}
           'RetCash':U
           DECIMAL(v-reg-value)
           0
           no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.


      /* RetCoup */
      { gbl/fr-get-reg.i
        'cash':U
        78
        v-reg-value
        v-reg-name
        p-message
        p-ok
        no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      else do:
         { str/libthpos_cfr.i
           v-doc-code
           {&cdt-cfreg}
           'RetCoup':U
           DECIMAL(v-reg-value)
           0
           no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.


      /* RetCard */
      { gbl/fr-get-reg.i
        'cash':U
        82
        v-reg-value
        v-reg-name
        p-message
        p-ok
        no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      else do:
         { str/libthpos_cfr.i
           v-doc-code
           {&cdt-cfreg}
           'RetCard':U
           DECIMAL(v-reg-value)
           0
           no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.


      /* RetAux */
      { gbl/fr-get-reg.i
        'cash':U
        86
        v-reg-value
        v-reg-name
        p-message
        p-ok
        no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      else do:
         { str/libthpos_cfr.i
           v-doc-code
           {&cdt-cfreg}
           'RetAux':U
           DECIMAL(v-reg-value)
           0
           no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.

      /* !!! WithDraw */



      /* InCash */
      { gbl/fr-get-reg.i
        'cash':U
        242
        v-reg-value
        v-reg-name
        p-message
        p-ok
        no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      else do:
         { str/libthpos_cfr.i
           v-doc-code
           {&cdt-cfreg}
           'InCash':U
           DECIMAL(v-reg-value)
           0
           no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.

      /* OutCash */
      { gbl/fr-get-reg.i
        'cash':U
        243
        v-reg-value
        v-reg-name
        p-message
        p-ok
        no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            '':U
            '':U
            p-message
            '':U
            '':U
            '':U
            TODAY
            80
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      else do:
         { str/libthpos_cfr.i
           v-doc-code
           {&cdt-cfreg}
           'OutCash':U
           DECIMAL(v-reg-value)
           0
           no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               '':U
               '':U
               p-message
               '':U
               '':U
               '':U
               TODAY
               80
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.
   end.  /* сбор информации из регистров ФР */
   else do:
      assign
         p-ok = TRUE
      .
   end.

   { str/libthpos_getcheck.i
      v-doc-code
      no
      no-error
   }
   if error-status:error then do:
      assign
         p-message = substitute("gch &1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         '':U
         '':U
         p-message
         '':U
         '':U
         '':U
         TODAY
         80
         TIME
         'E':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }
      return.
   end.

   { str/libthpos_close-check.i
      v-doc-code
      v-fr-last-shift-num
      no-error
   }
   if error-status:error then do:
      assign
         p-message = substitute("clch &1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = TRUE
      .

      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         '':U
         '':U
         p-message
         '':U
         '':U
         '':U
         TODAY
         80
         TIME
         'E':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }

      return.
   end.

   { gbl/eventlib-event-log.i
      0
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      '':U
      '':U
      '*':U
      '':U
      '':U
      '':U
      TODAY
      78
      TIME
      'U':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      0
      v-cntxt-userid
      no-error
   }

   run clear-tt-chk in this-procedure.
   /*  смена режима */
   assign
      p-message    = "Z-отчет снят"
      p-ok         = true
      /*
      p-cd-mode    = {&cd-mode-ready}
      p-cd-submode = {&cd-submode-goods}
      p-cd-mode    = {&cd-mode-close-shift}
      p-cd-submode = {&cd-submode-goods}
      */
   .

end. /* do on error */
end procedure. /* 1989 */




/*==========================================================================*/
procedure chk-sale-open :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   run clear-tt-chk in this-procedure.

   run chk-open   ( input integer({&rcpt-sale})
                  , INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output p-message
                  , output p-ok
                  ) .
   if p-ok
   then do:
      assign
         p-message    = "Чек продажи открыт"
         p-cd-mode    = {&cd-mode-sale}
         p-cd-submode = {&cd-submode-goods}
      .
   end.

end. /* do on error */
end procedure. /* chk-sale-open */


/*==========================================================================*/
procedure chk-open :
define input         parameter p-chk-type    as INTEGER        no-undo.
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define variable v-doc-code      as character no-undo .

do
on error undo, return error
:
   case p-cd-mode:
      WHEN {&cd-mode-ready} OR
      WHEN {&cd-mode-close-shift} /*OR
      WHEN {&cd-mode-inv} */
      then do:
         { str/libthpos_create-chk-doc.i
            v-cntxt-db-num
            v-cntxt-obj-code
            {&cd-type-ibs-th}
            p-cash-num
            p-chk-type
            v-cashier
            v-cashier-psn-code
            v-doc-code
            v-exch-rate
            v-exch-scales
            v-cash-rate
            v-cash-scales
            no-error
         }

         if error-status:error
         then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            return.
         end.
         /* смена режима */
         CREATE tt-head-check.
         assign
            tt-head-check.doc-code    = v-doc-code
            tt-head-check.exch-rate   = v-exch-rate
            tt-head-check.exch-scales = v-exch-scales
            tt-head-check.cash-rate   = if v-r-b = {&r-b-base} then v-cash-rate    else 1
            tt-head-check.cash-scales = if v-r-b = {&r-b-base} then v-cash-scales  else 1
            tt-head-check.chk-type    = p-chk-type
            p-cd-submode = {&cd-submode-goods}
            p-ok = TRUE
         .
         case STRING(p-chk-type):
         WHEN {&rcpt-sale} then do:
            assign
               p-cd-mode    = {&cd-mode-sale}
            .
         end.
         WHEN {&rcpt-return} then do:
            assign
               p-cd-mode    = {&cd-mode-ret}
            .
         end.
         WHEN {&rcpt-inventory} then do:
            assign
               p-cd-mode    = {&cd-mode-inv}
            .
         end.
         OTHERWISE DO:
         end.
         end case.

      end.
      WHEN {&cd-mode-wth}
      then do:
         { str/libthpos_create-chk-title.i
            v-cntxt-db-num
            v-cntxt-obj-code
            {&cd-type-ibs-th}
            p-cash-num
            p-chk-type
            v-cashier
            v-cashier-psn-code
            v-doc-code
            v-exch-rate
            v-exch-scales
            v-cash-rate
            v-cash-scales
            no-error
         }
         if error-status:error
         then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            return.
         end.
         /* смена режима */
         CREATE tt-head-check.
         assign
            tt-head-check.doc-code    = v-doc-code
            tt-head-check.exch-rate   = v-exch-rate
            tt-head-check.exch-scales = v-exch-scales
            tt-head-check.cash-rate   = if v-r-b = {&r-b-base} then v-cash-rate    else 1
            tt-head-check.cash-scales = if v-r-b = {&r-b-base} then v-cash-scales  else 1
            tt-head-check.chk-type    = p-chk-type
            p-ok = TRUE
         .
      end.
      OTHERWISE DO:
      end.
   end case.

end. /* do on error */
end procedure. /* chk-open */

/*==========================================================================*/
procedure 1982 :  /* закрытие чека и печать на ФР */
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define buffer buf_tt-line     for tt-line .

define variable v-chk-fr-num     as character    no-undo .
define variable v-price-rub      as decimal      no-undo .
define variable v-disc-rub       as decimal      no-undo .
define variable v-disc-rub-total as decimal      no-undo .
define variable v-print-line     as character    no-undo .
define variable v-rest-summ      as decimal      no-undo .

define variable v-summ-1  as decimal      no-undo.
define variable v-summ-2  as decimal      no-undo.
define variable v-summ-3  as decimal      no-undo.
define variable v-summ-4  as decimal      no-undo.

/* !!! сумма наличности в ящике */

do
on error undo, return error
:
  define variable v-fr-mode            as integer      no-undo.
  define variable v-fr-time            as integer      no-undo.
  define variable v-fr-date            as date         no-undo.
  define variable v-fr-last-shift-date as date         no-undo.
  define variable v-fr-lic             as character    no-undo.
  define variable v-fr-serial          as char    no-undo.

  { gbl/fr-ctrl.i
    v-cash-drawer-open
    p-message
    p-ok
    v-fr-mode
    v-fr-time
    v-fr-date
    v-fr-last-shift-date
    v-fr-last-shift-num
    v-fr-lic
    v-fr-shift-open
    v-fr-serial
    no-error
  }
/*      message*/
/*         "X"  2*/
/*         skip v-fr-last-shift-num*/
/*      view-as alert-box information.*/
  if  not p-ok
  AND v-fr-shift-open = 24
  then do:
    assign
    p-message = "Истекли 24 часа открытой смены. Чек можно только отложить."
    p-ok = FALSE
    .
    return.
  end.

   /*
   run 2007  ( INPUt-OUTPUT p-cd-mode
                        , input-output p-cd-submode
                        , output p-message
                        , output p-ok
                        ) .
   */
  if  ABS( v-summ-brutto-rub  ) > v-summ-fr
  AND p-cd-mode = {&cd-mode-ret}
  AND not v-emul-mode
  then do:
    assign
    p-message = substitute("Суммы в ДЯ &1 недостаточно для выплаты", v-summ-fr)
    /* ане нужно ли тут p-ok = false*/   /*???*/
    .
    return.
  end.

  find tt-head-check .
  { gbl/eventlib-event-log.i
    0
    v-cntxt-db-num
    '':U
    p-cash-num
    {&md}
    tt-head-check.chk-type
    '':U
    '*':U
    '':U
    tt-head-check.doc-code
    '':U
    TODAY
    63
    TIME
    'U':U
    0
    v-cntxt-obj-type
    v-cntxt-obj-code
    '':U
    {&cd-type-ibs-th}
    0
    ?
    '':U
    0
    '':U
    v-summ-netto-rub
    v-cntxt-userid
    no-error
  }
  assign
  v-disc-rub-total = 0
  .
  assign
  v-rest-summ = ?
  .

  define variable v-first-line    as character    no-undo.
  define variable v-chk-num    as character    no-undo.
  /*
  if not v-emul-mode
  AND tt-head-check.d-card <> "":U
  then do:
    case tt-head-check.chk-type:
        WHEN integer({&rcpt-sale})
        then do:
          { gbl/fr-open-chk.i
            0
            v-chk-num
            p-message
            p-ok
            no-error
          }
        end.
        WHEN integer({&rcpt-return})
        then do:
          { gbl/fr-open-chk.i
            2
            v-chk-num
            p-message
            p-ok
            no-error
          }
        end.
        OTHERWISE DO:
        end.
    end case.
    assign
        v-first-line = substitute("Карта &1", tt-head-check.d-card)
    .
    { gbl/fr-print-str.i
        v-first-line
        p-message
        p-ok
    no-error
    }
    if error-status:error then do:
        assign
          p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
          p-ok = FALSE
        .
        { gbl/eventlib-event-log.i
          0
          v-cntxt-db-num
          '':U
          0
          '':U
          tt-head-check.chk-type
          '':U
          p-message
          '':U
          tt-head-check.doc-code
          '':U
          TODAY
          67
          TIME
          'E':U
          0
          v-cntxt-obj-type
          v-cntxt-obj-code
          '':U
          {&cd-type-ibs-th}
          0
          ?
          '':U
          0
          '':U
          0
          v-cntxt-userid
          no-error
        }
        return.
    end.

    assign
        v-first-line = "":U
    .
    { gbl/fr-print-str.i
        tt-head-check.obj-name
        p-message
        p-ok
    no-error
    }
    if error-status:error then do:
        assign
          p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
          p-ok = FALSE
        .
        { gbl/eventlib-event-log.i
          0
          v-cntxt-db-num
          '':U
          0
          '':U
          tt-head-check.chk-type
          '':U
          p-message
          '':U
          tt-head-check.doc-code
          '':U
          TODAY
          67
          TIME
          'E':U
          0
          v-cntxt-obj-type
          v-cntxt-obj-code
          '':U
          {&cd-type-ibs-th}
          0
          ?
          '':U
          0
          '':U
          0
          v-cntxt-userid
          no-error
        }
        return.
    end.
  end.
  */

  assign
  v-summ-1 = 0
  v-summ-2 = 0
  v-summ-3 = 0
  v-summ-4 = 0
   .

  for each  buf_tt-line
      where buf_tt-line.type = 1
      :
    case buf_tt-line.fr-pay-code :
      WHEN 1 then do:
        assign
        v-summ-1 = v-summ-1 + if p-cd-mode = {&cd-mode-ret} then - buf_tt-line.summ-netto else buf_tt-line.summ-netto
        .
      end.
      WHEN 2 then do:
        assign
        v-summ-2 = v-summ-2 + if p-cd-mode = {&cd-mode-ret} then - buf_tt-line.summ-netto else buf_tt-line.summ-netto
        .
      end.
      WHEN 3 then do:
        assign
        v-summ-3 = v-summ-3 + if p-cd-mode = {&cd-mode-ret} then - buf_tt-line.summ-netto else buf_tt-line.summ-netto
        .
      end.
      WHEN 4 then do:
        assign
        v-summ-4 = v-summ-4 + if p-cd-mode = {&cd-mode-ret} then - buf_tt-line.summ-netto else buf_tt-line.summ-netto
        .
      end.
      OTHERWISE DO:
      end.
    end case.
  end.
  if  v-summ-netto-rub < v-summ-pay-rub
  AND ((v-summ-pay-rub - v-summ-netto-rub) > v-summ-1)
  then do:
    if (tt-head-check.chk-type = integer({&rcpt-return}))
    then do:
      assign
      p-message = "В возврате запрещена сдача"
      p-ok      = FALSE
      .
      return.
    end.

    assign
    p-message = substitute("Сумма сдачи (&1) в чеке превышает сумму платежей (&2) с кодом в ФР=1, на которые сдача разрешена"
                          , (v-summ-pay-rub - v-summ-netto-rub)
                          , v-summ-1
                          )
    p-ok      = TRUE
    .
    return.
  end.

  run rest-back in this-procedure ( INPUT-output v-rest-summ, output p-message, output p-ok) .
  if not p-ok
  then do:
    return.
  end.

  /* Общая скидка на чек */
  define variable v-st-r-b as decimal no-undo .
  define variable v-st-rubl as decimal no-undo .
  define variable v-st-base as decimal no-undo .
  define variable v-tot-doc as decimal no-undo .
  define variable v-netto as decimal no-undo .
  define variable v-netto-rubl as decimal no-undo .
  define variable v-netto-base as decimal no-undo .
  define variable v-all-discnt as decimal no-undo .
  define variable v-all-discnt-rubl as decimal no-undo .
  define variable v-all-discnt-base as decimal no-undo .
  define variable v-pay-disc    as decimal      no-undo.
  define variable v-tot-disc    as decimal      no-undo.
  define variable v-err-disc    as decimal      no-undo.


  { str/libthpos_sub-total.i
    tt-head-check.doc-code
    ''
    p-ok
    v-st-r-b
    v-st-rubl
    v-st-base
    v-tot-doc
    v-discnt-chk
    v-netto
    v-netto-rubl
    v-netto-base
    v-all-discnt
    v-all-discnt-rubl
    v-all-discnt-base
    no-error
  }

  assign
  v-summ-discont-rub = v-all-discnt-rubl
  v-summ-netto-rub   = ABS(v-netto-rubl)
  .

  define variable v-integer   as integer      no-undo.
  define variable v-character as character    no-undo.
  define variable v-decimal   as decimal      no-undo.
  define variable v-logical   as logical      no-undo.
  define variable v-date    as date         no-undo.
  define variable v-handle    as handle       no-undo.
  define variable v-cont    as integer    no-undo.
  define variable v-data-type    as character    no-undo.

  { str/libthpos_get-context-property.i
    {&chk-context}
    'pay-discnt-rubl'
    v-character
    v-date
    v-pay-disc
    v-integer
    v-logical
    v-handle
    v-data-type
    p-ok
    no-error
  }
  if error-status:error
  OR not p-ok
  then do:
    assign
    p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
    p-ok = FALSE
    .
    return .
  end.
  { str/libthpos_get-context-property.i
    {&chk-context}
    'tot-discnt'
    v-character
    v-date
    v-tot-disc
    v-integer
    v-logical
    v-handle
    v-data-type
    p-ok
    no-error
  }
  if error-status:error
  OR not p-ok
  then do:
    assign
    p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
    p-ok = FALSE
    .
    return .
  end.


  { str/libthpos_getcheck.i
    tt-head-check.doc-code
    no
    no-error
  }
  if error-status:error then do:
    if v-rest-summ > 0
    then do:
      run del-rest (output p-message, output p-ok) .
    end.

    assign
    p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
    p-ok = FALSE
    .
    { gbl/eventlib-event-log.i
        0
        v-cntxt-db-num
        '':U
        p-cash-num
        {&md}
        tt-head-check.chk-type
        '':U
        p-message
        '':U
        tt-head-check.doc-code
        '':U
        TODAY
        65
        TIME
        'E':U
        0
        v-cntxt-obj-type
        v-cntxt-obj-code
        '':U
        {&cd-type-ibs-th}
        0
        ?
        '':U
        0
        '':U
        v-summ-netto-rub
        v-cntxt-userid
        no-error
    }
    return.
  end.


  /* печать на ФР */

  for each  buf_tt-line
      where buf_tt-line.type = 0
        AND buf_tt-line.printed = FALSE
      :

    case tt-head-check.chk-type:
      WHEN integer({&rcpt-sale})
      then do:
        if not v-emul-mode
        then do:
          assign
          v-price-rub = buf_tt-line.price-rub
          v-disc-rub  = - buf_tt-line.summ-discont-rub
          v-disc-rub-total = v-disc-rub-total - v-disc-rub
          .
          run str-fix-width ( input (if v-print-good-code then STRING(buf_tt-line.src) + " " else "":U) + buf_tt-line.line-name
                            , input "":U
                            , input v-fr-width
                            , YES
                            , output v-print-line
                            , output p-message
                            , output p-ok
                            ) .
          { gbl/fr-add-sale.i
              '':U
              v-print-line
              v-price-rub
              buf_tt-line.qnty
              buf_tt-line.unit-base
              v-d-card
              v-disc-rub
              p-message
              p-ok
              no-error
          }
          if error-status:error
          then do:
            if v-rest-summ > 0
            then do:
              run del-rest (output p-message, output p-ok) .
            end.
            assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
              0
              v-cntxt-db-num
              '':U
              p-cash-num
              {&md}
              tt-head-check.chk-type
              '':U
              p-message
              '':U
              tt-head-check.doc-code
              '':U
              TODAY
              65
              TIME
              'E':U
              0
              v-cntxt-obj-type
              v-cntxt-obj-code
              '':U
              {&cd-type-ibs-th}
              0
              ?
              '':U
              0
              '':U
              v-summ-netto-rub
              v-cntxt-userid
              no-error
            }
            return.
          end.
        end.
        else do:
          assign
          p-ok = TRUE
                .
        end.
      end. /*WHEN integer({&rcpt-sale})*/
      WHEN integer({&rcpt-return})
      then do:
        if not v-emul-mode
        then do:
          assign
          v-price-rub      =  buf_tt-line.price-rub
          v-disc-rub       = - buf_tt-line.summ-discont-rub
          v-disc-rub-total = v-disc-rub-total - v-disc-rub
          .
          run str-fix-width ( input (if v-print-good-code then STRING(buf_tt-line.src) + " " else "":U) + buf_tt-line.line-name
                            , input "":U
                            , input v-fr-width
                            , YES
                            , output v-print-line
                            , output p-message
                            , output p-ok
                            ) .
          { gbl/fr-add-ret.i
              '':U
              v-print-line
              v-price-rub
              buf_tt-line.qnty
              buf_tt-line.unit-base
              v-d-card
              v-disc-rub
              p-message
              p-ok
              no-error
          }
          if error-status:error
          then do:
            if v-rest-summ > 0
            then do:
              run del-rest (output p-message, output p-ok) .
            end.
            assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
              0
              v-cntxt-db-num
              '':U
              p-cash-num
              {&md}
              tt-head-check.chk-type
              '':U
              p-message
              '':U
              tt-head-check.doc-code
              '':U
              TODAY
              65
              TIME
              'E':U
              0
              v-cntxt-obj-type
              v-cntxt-obj-code
              '':U
              {&cd-type-ibs-th}
              0
              ?
              '':U
              0
              '':U
              v-summ-netto-rub
              v-cntxt-userid
              no-error
            }
            return .
          end.
        end.
        else do:
          assign
          p-ok = TRUE
          .
        end.
      end. /*WHEN integer({&rcpt-return})*/
      /*
      WHEN integer({&encashment})
      then do:
      end.
      WHEN integer({&cd-fund})
      then do:
      end.
      */
      OTHERWISE DO:
      end.
    end case. /*case tt-head-check.chk-type:*/
    assign
    buf_tt-line.printed = TRUE
    .
  end. /*  for each  buf_tt-line*/

  if not v-emul-mode
  then do:
    /* ! На все платежи сразу */
    define variable v-dsk-tot-name    as character    no-undo.
    assign
    v-dsk-tot-name       = "Скидки на тип платежа"
    .
    if v-pay-disc <> 0
    then do:
      { gbl/fr-discount.i
      v-pay-disc
      v-dsk-tot-name
      p-message
      p-ok
      }
    end.
  end.

  /*
  assign
    v-summ-1 = 0
    v-summ-2 = 0
    v-summ-3 = 0
    v-summ-4 = 0
  .

  for each  buf_tt-line
      where buf_tt-line.type = 1
    :
    case buf_tt-line.fr-pay-code :
        WHEN 1 then do:
          assign
              v-summ-1 = v-summ-1 + if p-cd-mode = {&cd-mode-ret} then - buf_tt-line.summ-discont-rub else buf_tt-line.summ-discont-rub
          .
        end.
        WHEN 2 then do:
          assign
              v-summ-2 = v-summ-2 + if p-cd-mode = {&cd-mode-ret} then - buf_tt-line.summ-discont-rub else buf_tt-line.summ-discont-rub
          .
        end.
        WHEN 3 then do:
          assign
              v-summ-3 = v-summ-3 + if p-cd-mode = {&cd-mode-ret} then - buf_tt-line.summ-discont-rub else buf_tt-line.summ-discont-rub
          .
        end.
        WHEN 4 then do:
          assign
              v-summ-4 = v-summ-4 + if p-cd-mode = {&cd-mode-ret} then - buf_tt-line.summ-discont-rub else buf_tt-line.summ-discont-rub
          .
        end.
        OTHERWISE DO:
        end.
    end case.
  end.
  define variable v-dsk-tot-name    as character    no-undo.
  assign
    v-dsk-tot-name =
  .
  if v-summ-1 <> 0
  then do:
    { gbl/fr-discount.i
      v-summ-1
      v-dsk-tot-name
      p-message
      p-ok
    }
  end.
  */

  if not v-emul-mode
  then do:
    assign
    v-dsk-tot-name       = "Скидка на итог"
    .
    if v-tot-disc <> 0
    then do:
      { gbl/fr-discount.i
      v-tot-disc
      v-dsk-tot-name
      p-message
      p-ok
      }
    end.

    /* Берем итоги из ФР и сравниваем их с нашими платежами */
    define variable v-fr-summ    as decimal      no-undo.
    /*нельзя вывзывать эту функцию для всех чеков подряд!!! регистратор выдает ошибку!!!!*/
    if lookup(string(tt-head-check.chk-type), {&no-discnt-receipt-codes}) = 0 then do:
      { gbl/fr-subtotal-without-print.i
        v-fr-summ
        p-message
        p-ok
        no-error
      }
      if error-status:error
      or not p-ok
      then do:
        if v-rest-summ > 0
        then do:
          run del-rest (output p-message, output p-ok) .
        end.
        assign
        p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
        p-ok = FALSE
        .
        { gbl/eventlib-event-log.i
          0
          v-cntxt-db-num
          '':U
          p-cash-num
          {&md}
          tt-head-check.chk-type
          '':U
          p-message
          '':U
          tt-head-check.doc-code
          '':U
          TODAY
          65
          TIME
          'E':U
          0
          v-cntxt-obj-type
          v-cntxt-obj-code
          '':U
          {&cd-type-ibs-th}
          0
          ?
          '':U
          0
          '':U
          v-summ-netto-rub
          v-cntxt-userid
          no-error
        }
        return .
      end. /*if error-status:error*/
    end.
  end. /*if not v-emul-mode*/

  assign
  v-rest-summ = if v-rest-summ = ? then 0 else v-rest-summ
  v-err-disc = (v-fr-summ + v-rest-summ - ABS( v-summ-1 + v-summ-2 + v-summ-3 + v-summ-4 ))
  .

   if not v-emul-mode
   then do:
    if lookup(string(tt-head-check.chk-type), {&no-discnt-receipt-codes}) = 0 then do:
      if v-err-disc > 0
      then do:

        assign
        v-dsk-tot-name       = "Скидка на округление"
        .
        { gbl/fr-discount.i
        v-err-disc
        v-dsk-tot-name
        p-message
        p-ok
        }
      end.
      else do:
        if v-err-disc < 0
        then do:
          assign
          v-dsk-tot-name       = "Надбавка на округление"
          .
          { gbl/fr-discount.i
              v-err-disc
              v-dsk-tot-name
              p-message
              p-ok
          }
        end.
      end.
    end. /*if lookup(string(tt-head-check.chk-type), {&no-discnt-receipt-codes}) = 0 then do:*/
  end. /*if not v-emul-mode*/

  if not v-emul-mode
  AND tt-head-check.d-card <> "":U
  then do:
    assign
    v-first-line = substitute("Карта &1", tt-head-check.d-card)
    .
    { gbl/fr-print-str.i
        v-first-line
        p-message
        p-ok
    no-error
    }
    if error-status:error then do:
      if v-rest-summ > 0
      then do:
        run del-rest (output p-message, output p-ok) .
      end.
      assign
      p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
      p-ok = FALSE
      .
      { gbl/eventlib-event-log.i
        0
        v-cntxt-db-num
        '':U
        0
        '':U
        tt-head-check.chk-type
        '':U
        p-message
        '':U
        tt-head-check.doc-code
        '':U
        TODAY
        67
        TIME
        'E':U
        0
        v-cntxt-obj-type
        v-cntxt-obj-code
        '':U
        {&cd-type-ibs-th}
        0
        ?
        '':U
        0
        '':U
        0
        v-cntxt-userid
        no-error
      }
      return.
    end.

    assign
    v-first-line = "":U
    .

    { gbl/fr-print-str.i
        tt-head-check.obj-name
        p-message
        p-ok
    no-error
    }
    if error-status:error then do:
      if v-rest-summ > 0
      then do:
        run del-rest (output p-message, output p-ok) .
      end.
      assign
      p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
      p-ok = FALSE
      .
      { gbl/eventlib-event-log.i
        0
        v-cntxt-db-num
        '':U
        0
        '':U
        tt-head-check.chk-type
        '':U
        p-message
        '':U
        tt-head-check.doc-code
        '':U
        TODAY
        67
        TIME
        'E':U
        0
        v-cntxt-obj-type
        v-cntxt-obj-code
        '':U
        {&cd-type-ibs-th}
        0
        ?
        '':U
        0
        '':U
        0
        v-cntxt-userid
        no-error
      }
      return.
    end.
  end. /*
  if not v-emul-mode
  AND tt-head-check.d-card <> "":U

  */

  if not v-emul-mode
  then do:
    define variable v-card    as character    no-undo. /* !!! */
    define variable v-rest-summ-2    as decimal      no-undo.
    case tt-head-check.chk-type:
      WHEN integer({&rcpt-sale}) OR
      WHEN integer({&rcpt-return})
      then do:
        { gbl/fr-chkcl.i
            v-summ-1
            v-summ-2
            v-summ-3
            v-summ-4
            tt-head-check.d-card
            v-chk-fr-num
            v-rest-summ-2
            p-message
            p-ok
            no-error
        }
        if error-status:error
        OR not p-ok
        then do:
          if v-rest-summ > 0
          then do:
            run del-rest (output p-message, output p-ok) .
          end.
          assign
          p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
          p-ok = FALSE
          .
          { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            tt-head-check.chk-type
            '':U
            p-message
            '':U
            tt-head-check.doc-code
            '':U
            TODAY
            65
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            v-summ-netto-rub
            v-cntxt-userid
            no-error
          }
          return .
        end.
      end.
      WHEN integer({&encashment})
      then do:
        /*вообщем инкассацию НЕНАЛИЧНЫХ сделать невоможно -v-summ-1 везде берется*/
        { gbl/fr-cashout.i
          v-summ-1
          p-message
          p-ok
          no-error
        }
        if error-status:error
        OR not p-ok
        then do:
          assign
          p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
          p-ok = FALSE
          .
          { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            tt-head-check.chk-type
            '':U
            p-message
            '':U
            tt-head-check.doc-code
            '':U
            TODAY
            65
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            v-summ-netto-rub
            v-cntxt-userid
            no-error
          }
          return .
        end.
      end. /*WHEN integer({&encashment})*/
      WHEN integer({&cd-fund})
      then do:
        /*вообщем внесение НЕНАЛИЧНЫХ сделать невоможно - v-summ-1 везде берется*/
        { gbl/fr-cashin.i
            v-summ-1
            p-message
            p-ok
            no-error
        }
        if error-status:error
        OR not p-ok
        then do:
          assign
          p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
          p-ok = FALSE
          .
          { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            tt-head-check.chk-type
            '':U
            p-message
            '':U
            tt-head-check.doc-code
            '':U
            TODAY
            65
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            v-summ-netto-rub
            v-cntxt-userid
            no-error
          }
          return .
        end.
      end. /*WHEN integer({&cd-fund})*/
      OTHERWISE DO:
      end.
   end case. /*case tt-head-check.chk-type:*/
      /*
      run 1988 in this-procedure ( INPUt-OUTPUT p-cd-mode
                                 , INPUt-output p-cd-submode
                                 , output p-message
                                 , output p-ok
                                 ) .
      */
  end.
  else do:
    assign
    v-rest-summ = ?
    p-ok = TRUE
    .
  end.

   /*
   if v-rest-summ-2 <> 0 then do:
      run rest-back in this-procedure ( INPUT-output v-rest-summ-2, output p-message, output p-ok) .
   end.
   */

   if error-status:error
   OR not p-ok
   then do:
      assign
      p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
      p-ok = FALSE
      .
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         tt-head-check.chk-type
         '':U
         p-message
         '':U
         tt-head-check.doc-code
         '':U
         TODAY
         65
         TIME
         'E':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         v-summ-netto-rub
         v-cntxt-userid
         no-error
      }
      return .
   end.


  { str/libthpos_close-check.i
    tt-head-check.doc-code
    v-chk-fr-num
    no-error
  }


  if error-status:error then do:
    if v-rest-summ > 0
    then do:
      run del-rest (output p-message, output p-ok) .
    end.
    assign
    p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
    p-ok = FALSE
    .
    { gbl/eventlib-event-log.i
        0
        v-cntxt-db-num
        '':U
        p-cash-num
        {&md}
        tt-head-check.chk-type
        '':U
        p-message
        '':U
        tt-head-check.doc-code
        '':U
        TODAY
        65
        TIME
        'E':U
        0
        v-cntxt-obj-type
        v-cntxt-obj-code
        '':U
        {&cd-type-ibs-th}
        0
        ?
        '':U
        0
        '':U
        v-summ-netto-rub
        v-cntxt-userid
        no-error
    }
    return.
  end.


  /* погасить отложенный чек */
  define buffer buf_tt-open-check     for tt-open-check .
  /* if v-reopen-chk <> "":U */
  if CAN-find(first buf_tt-open-check)
  then do:
    for each  buf_tt-open-check
        where buf_tt-open-check.chk-type = integer({&rcpt-ord-sale})
          OR  buf_tt-open-check.chk-type = integer({&rcpt-ord-return})
            :
      { str/libthpos_close-postpone.i
        tt-head-check.doc-code
        buf_tt-open-check.doc-code
        1
        no-error
      }
      if error-status:error
      then do:
        assign
        p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
        p-ok = FALSE
        .
        { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            tt-head-check.chk-type
            '':U
            p-message
            '':U
            tt-head-check.doc-code
            '':U
            TODAY
            65
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            v-summ-netto-rub
            v-cntxt-userid
            no-error
        }
        return.
      end.
    end.
  end.

  { gbl/eventlib-event-log.i
    0
    v-cntxt-db-num
    '':U
    p-cash-num
    {&md}
    tt-head-check.chk-type
    '':U
    '*':U
    '':U
    tt-head-check.doc-code
    '':U
    TODAY
    64
    TIME
    'S':U
    0
    v-cntxt-obj-type
    v-cntxt-obj-code
    '':U
    {&cd-type-ibs-th}
    0
    ?
    '':U
    0
    '':U
    v-summ-netto-rub
    v-cntxt-userid
    no-error
  }


  if not v-emul-mode
  AND v-with-context
  AND p-cd-mode = {&cd-mode-sale}
  then do:
    assign
    v-disp-msg-1 = "Сдача" + STRING(ABS( TRUNCATE(v-summ-netto-rub, 2) ) - ABS( TRUNCATE(v-summ-pay-rub,2 )  )) + " " + v-cd-base-name
    v-disp-msg-2 = "":U
    .
    { gbl/disp-str.i
        v-disp-msg-1
        v-disp-msg-2
        v-disp-msg-2
        p-ok
    }
  end.

  run clear-tt-chk in this-procedure.
   /*  смена режима */
  assign
  p-cd-mode         = {&cd-mode-ready}
  p-cd-submode      = {&cd-submode-goods}
  v-time-close      = TIME
  p-ok              = true
  .
end. /* do on error */
end procedure. /* 1982 */



/*==========================================================================*/
procedure 1987 : /* возврат */
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define buffer buf_tt-head-check     for tt-head-check .
do
on error undo, return error
:
   { gbl/eventlib-event-log.i
   0
   v-cntxt-db-num
   '':U
   p-cash-num
   {&md}
   0
   '':U
   '*':U
   '':U
   '':U
   '':U
   TODAY
   69
   TIME
   'U':U
   0
   v-cntxt-obj-type
   v-cntxt-obj-code
   '':U
   {&cd-type-ibs-th}
   0
   ?
   '':U
   0
   '':U
   0
   v-cntxt-userid
   no-error
   }

   run adm/chk-pass.w   ( input parparentproc
                        , input v-cntxt-userid
                        , input v-cntxt-db-num
                        , input "actn_ibsthpos-return"
                        , input FALSE
                        , output p-message
                        , output p-ok
                        ) .
   if not p-ok
   then do:
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         0
         '':U
         p-message
         '':U
         '':U
         '':U
         TODAY
         71
         TIME
         'E':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }
      return.
   end.

   run clear-tt-chk in this-procedure.

   run chk-open   ( input integer({&rcpt-return})
                  , INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output p-message
                  , output p-ok
                  ) .
   if p-ok
   then do:
      find buf_tt-head-check.

      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         buf_tt-head-check.chk-type
         '':U
         '*':U
         '':U
         buf_tt-head-check.doc-code
         '':U
         TODAY
         70
         TIME
         'S':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }
      assign
         p-message    = "Чек возврата открыт"
         p-cd-mode    = {&cd-mode-ret}
         p-cd-submode = {&cd-submode-goods}
      .
   end.
   else do:
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         0
         '':U
         p-message
         '':U
         '':U
         '':U
         TODAY
         71
         TIME
         'E':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }
   end.

end. /* do on error */
end procedure. /* 1987 */



/*==========================================================================*/
procedure 1993 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define buffer buf_tt-head-check     for tt-head-check .
define variable v-doc-code    as character    no-undo.
define variable v-chk-type    as integer      no-undo.

do
on error undo, return error
:
   find first buf_tt-head-check NO-LOCK no-error.
   if available buf_tt-head-check
   then do:
      assign
         v-doc-code = buf_tt-head-check.doc-code
         v-chk-type = buf_tt-head-check.chk-type
      .
   end.

   { gbl/eventlib-event-log.i
      1
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      v-chk-type
      '':U
      '*':U
      '':U
      v-doc-code
      '':U
      TODAY
      52
      TIME
      'U':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      0
      v-cntxt-userid
      no-error
   }

   p-ok = FALSE.
   DO WHILE not p-ok
   :


      run adm/chk-pass.w   ( input parparentproc
                           , input v-cntxt-userid
                           , input v-cntxt-db-num
                           , input "":U
                           , input TRUE
                           , output p-message
                           , output p-ok
                           ) no-error.
      /*
      if p-ok
      then do:
         assign
            p-message    = "Блокировка пользователем"
            v-cd-mode-user-pre    = p-cd-mode
            v-cd-submode-user-pre = p-cd-submode
            p-cd-mode             = {&cd-mode-user-block}
            p-cd-submode          = {&cd-submode-goods}
            p-ok                  = TRUE
         .
      end.
      */
   end.
   { gbl/eventlib-event-log.i
      1
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      v-chk-type
      '':U
      '*':U
      '':U
      v-doc-code
      '':U
      TODAY
      53
      TIME
      'U':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      0
      v-cntxt-userid
      no-error
   }


end. /* do on error */
end procedure. /* 1993 */




/*==========================================================================*/
procedure cd-unblock :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   run adm/chk-pass.w   ( input parparentproc
                        , input v-cntxt-userid
                        , input v-cntxt-db-num
                        , input "actn_ibsthpos-unblock"
                        , input TRUE
                        , output p-message
                        , output p-ok
                        ) .
   if p-ok
   then do:
      assign
         p-cd-mode    = v-cd-mode-user-pre
         p-cd-submode = v-cd-submode-user-pre
      .
   end.

end. /* do on error */
end procedure. /* cd-unblock */



/*==========================================================================*/
procedure key-enable :
define input  parameter p-cd-mode      as character          no-undo.
define input  parameter p-cd-submode   as character        no-undo.
define input  parameter p-name         as character        no-undo.
define output parameter p-ok           as logical          no-undo.
define output parameter p-label        as character        no-undo.
define output parameter p-tooltip      as character        no-undo.

define variable v-md    as character    no-undo.
define variable v-msg   as character    no-undo.

define buffer buf_temp-layout-elem-rule      for temp-layout-elem-rule .

do
on error undo, return error
:
   if p-cd-mode = {&cd-mode-sale}
   OR p-cd-mode = {&cd-mode-ret}
   then do:
      assign
         v-md = substitute("&1.&2", p-cd-mode, p-cd-submode)
      .
   end.
   else do:
      assign
         v-md = p-cd-mode
      .
   end.


   find first buf_temp-layout-elem-rule
        where buf_temp-layout-elem-rule.layout-id  = v-screen-layout-id
          and buf_temp-layout-elem-rule.mode-id    = v-md
          and buf_temp-layout-elem-rule.widget-id  = p-name

          no-error
          .
   if available buf_temp-layout-elem-rule then do:
      assign
         p-label     = buf_temp-layout-elem-rule.elem-label
         p-tooltip   = buf_temp-layout-elem-rule.elem-tooltip
         p-ok        = TRUE
      .
      RELEASE buf_temp-layout-elem-rule.
   end.
   else do:
      find first tt-func-key
           where tt-func-key.cd-mode     = p-cd-mode
             and tt-func-key.cd-submode  = p-cd-submode
             AND tt-func-key.key-name    = p-name
            NO-LOCK
            No-error
            .
      if not available tt-func-key
      then return.
      /*
      if tt-func-key.func-param <>"":U
      then do:
         run func-param in this-procedure (input tt-func-key.func-param, output v-msg, output p-ok).
         if p-ok    = TRUE
         then do:
            assign
               p-label = tt-func-key.key_label
            .
         end.
      end.
      else do:
         assign
            p-label = tt-func-key.key_label
            p-ok    = TRUE
         .
      end.
      */
      assign
         p-label = tt-func-key.key_label
         p-ok    = TRUE
      .

   end.

   return.

end. /* do on error */
end procedure. /* key-enable */




/*==========================================================================*/
procedure key-run :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define input         parameter p-name        as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define variable v-msg    as character    no-undo.

do
on error undo, return error
:

   find first tt-func-key
        where tt-func-key.cd-mode    = p-cd-mode
         AND  tt-func-key.cd-submode = p-cd-submode
         AND  tt-func-key.key-name   = p-name
        NO-LOCK
        No-error
        .
   if not available tt-func-key
   then do:
      /*
      assign
         p-ok = TRUE
      .
      */
      return.
   end.

   assign
      v-fix-summ-pay = DECIMAL(TRIM(tt-func-key.key_label, " %"))
   no-error
   .
   if error-status:error
   then do:
      assign
         v-fix-summ-pay = 0
      no-error .
   end.

   if tt-func-key.cng-context
   then do:
      run VALUE( tt-func-key.key_func )  ( INPUt-OUTPUT p-cd-mode
                                         , INPUt-output p-cd-submode
                                         , output p-message
                                         , output p-ok
                                         ) .
   end.
   else do:
      run VALUE( tt-func-key.key_func ) ( output p-message
                                        , output p-ok
                                        ) .
   end.
   if not p-ok
   then do:
      return.
   end.

   if p-cd-mode <> {&cd-mode-block}
   then do:
      assign
         v-msg            = p-message
         v-cd-mode-pre    = p-cd-mode
         v-cd-submode-pre = p-cd-submode
      .
   end.

   run cd-context ( INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output       p-message
                  , output p-ok
                  ) .
   if not p-ok
   then do:
      return.
   end.

   if p-cd-mode <> {&cd-mode-block}
   then do:
      assign
         p-message        = v-msg
         v-cd-mode-pre    = p-cd-mode
         v-cd-submode-pre = p-cd-submode
      .
   end.

   return.
end. /* do on error */
end procedure. /* key-run */


/*==========================================================================*/
procedure rule-run :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define input         parameter p-name        as character      no-undo .
define input         parameter p-type        as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define variable v-msg    as character    no-undo.
define variable v-md    as character    no-undo.
define buffer b_temp-layout-elem-rule for temp-layout-elem-rule .
define buffer b_tt-func-key for tt-func-key .

do
on error undo, return error
:

   if p-cd-mode = {&cd-mode-sale}
   OR p-cd-mode = {&cd-mode-ret}
   then do:
      assign
         v-md = substitute("&1.&2", p-cd-mode, p-cd-submode)
      .
   end.
   else do:
      assign
         v-md = p-cd-mode
      .
   end.

   case p-type:
      WHEN {&th-pos-keyboard} then do:
         if  v-keyboard-layout-id <> "":U
         AND v-keyboard-layout-id <> ?
         then do:
            find first buf_temp-layout-elem-rule
               where buf_temp-layout-elem-rule.layout-id = v-keyboard-layout-id
            /*      and buf_temp-layout-elem-rule.mode-id   = v-md  */
                  and buf_temp-layout-elem-rule.widget-id = p-name
                  no-error
                  .
            if avail buf_temp-layout-elem-rule then
            do:

               find first b_temp-layout-elem-rule no-lock where
                          b_temp-layout-elem-rule.rule_id =  buf_temp-layout-elem-rule.rule_id
                    and   b_temp-layout-elem-rule.mode-id = v-md
                    no-error
                    .
               if not avail b_temp-layout-elem-rule then
               do:
                  find first b_tt-func-key no-lock where b_tt-func-key.cd-mode = p-cd-mode
                                          and b_tt-func-key.cd-submode = p-cd-submode
                                          and b_tt-func-key.key_func = string(buf_temp-layout-elem-rule.rule_id)
                                          no-error.
                  if not avail b_tt-func-key then
                  do:
                    assign p-ok = no
                           p-message = "В данном режиме клавиша не работает"
                         .
                    return  .

                  end.
               end.

            end.
         end.
         else do:
            find first buf_temp-layout-elem-rule
               where buf_temp-layout-elem-rule.layout-id = v-screen-layout-id
                  and buf_temp-layout-elem-rule.mode-id   = v-md
                  and buf_temp-layout-elem-rule.widget-id = p-name

                  no-error
                  .
         end.
      end.
      WHEN {&th-pos-screen} then do:
         find first buf_temp-layout-elem-rule
              where buf_temp-layout-elem-rule.layout-id = v-screen-layout-id
                and buf_temp-layout-elem-rule.mode-id   = v-md
                and buf_temp-layout-elem-rule.widget-id = p-name

               no-error
               .
      end.
      OTHERWISE DO:
      end.
   end case.

   if available buf_temp-layout-elem-rule then do:
      run value( substitute("&1", string(buf_temp-layout-elem-rule.rule_id, "9999"))) in this-procedure
               ( input-output p-cd-mode
               , input-output p-cd-submode
               , output p-message
               , output p-ok
               ) no-error.

      RELEASE buf_temp-layout-elem-rule.
   end.
   else do:
      run key-run in this-procedure ( input-output p-cd-mode
                                    , input-output p-cd-submode
                                    , input p-name
                                    , output p-message
                                    , output p-ok
                                    ) no-error.
   end.

   if error-status:error
   then do:
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      return.
   end.

   if not p-ok
   then do:
      return.
   end.


   if p-cd-mode <> {&cd-mode-block}
   then do:
      assign
         v-msg            = p-message
         v-cd-mode-pre    = p-cd-mode
         v-cd-submode-pre = p-cd-submode
      .
   end.
   run cd-context ( INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output       p-message
                  , output       p-ok
                  ) .
   if not p-ok
   then do:
      return.
   end.

   if p-cd-mode <> {&cd-mode-block}
   then do:
      assign
         p-message        = v-msg
         v-cd-mode-pre    = p-cd-mode
         v-cd-submode-pre = p-cd-submode
      .
   end.

   return.
end. /* do on error */
end procedure. /* rule-run */



procedure func-param :
define input   parameter p-name        as character      no-undo .
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical        no-undo .

do
on error undo, return error
:
      run VALUE( p-name ) in this-procedure ( output p-message, output p-ok ) no-error.
      if error-status:error
      then do:
         assign
            p-ok = FALSE
            p-message = substitute  ( "&1 &2 &3 &4"
                                    , return-VALUE
                                    , error-status:get-message(1)
                                    , error-status:get-message(2)
                                    , error-status:get-message(3)
                                    )
         .
      end.

end. /* do on error */
end procedure. /* key-run */





/*==========================================================================*/
procedure pr-empty :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define variable v-choice as logical no-undo init yes.

do
on error undo, return error
:
   message
   "Вы действительно хотите  выйти из АРМа  'Кассир' ?"
   view-as alert-box question buttons yes-no update v-choice .
   if v-choice then.
   else return no-apply.
   if not v-emul-mode
   then do:
      { gbl/disp-clear.i
         p-message
         p-ok
         no-error
      }
      { gbl/disp-str.i
         '':U
         '':U
         p-message
         p-ok
         no-error
      }
      { gbl/disp-terminate.i
         p-message
         p-ok
         no-error
      }


   end.
   /* !!! Очистка контекста ??? */
   QUIT.
   /*
   Не нужно если кнопка AUTO-GO или AUTO-end-KEY
   */

end. /* do on error */
end procedure. /* pr-empty */




/*==========================================================================*/
procedure set-date :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   /*
   { gbl/cd-mode-get.i
      v-mode
      v-submode
      v-err-message
      v-ok
      no-error
   }
   if error-status:error
   then do:
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      return.
   end.
   if v-mode = 6
   then do:
   */
      if not v-emul-mode
         then do:
         { gbl/fr-dtset.i
            p-message
            p-ok
            no-error
         }
         if error-status:error
         then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            return .
         end.
         { gbl/fr-tmset.i
            p-message
            p-ok
            no-error
         }
         if error-status:error
         then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            return.
         end.
      end.
      else do:
         assign
            p-cd-mode    = {&cd-mode-ready}
            p-cd-submode = {&cd-submode-goods}
            p-ok = TRUE
         .
      end.
   /*end.*/
end. /* do on error */
end procedure. /* set-date */




/*==========================================================================*/
procedure add-gds-line :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_tt-line     for tt-line .
define buffer prev_tt-line    for tt-line .
define buffer buf_goods       for ub.goods .
define buffer buf_tt-head-check     for tt-head-check .


define variable v-b-code          as integer no-undo .
define variable v-second-name     as character no-undo .
define variable v-next    as character    no-undo.

do
on error undo, return error
:

   find last  prev_tt-line
        where prev_tt-line.type = 0
        NO-LOCK
        no-error
        .


   if ((p-cd-mode = {&cd-mode-sale}
   OR  p-cd-mode = {&cd-mode-ret})
   AND p-cd-submode = {&cd-submode-goods})
   OR  not v-with-context
   then do:
      assign
         v-pump            = 0
         v-nozzle-code     = 0
         v-pl-code         = 0
         v-fbr-depart      = 0
         v-src-price       = if (p-cd-mode = {&cd-mode-sale}) then ? else v-src-price
         v-write-off-code  = 0
         v-num             = if v-num = 0 then (if (not available prev_tt-line) then 1
                                                                             else prev_tt-line.num + 1)
                                          else v-num
      .

      find buf_tt-head-check.


      assign
         v-src-qnty = if v-src-qnty = 0 then 1 else v-src-qnty
      .

      if p-cd-mode = {&cd-mode-ret}
      then do:
         define variable v-curr-qnty   as decimal      no-undo .
         define variable v-old-qnty    as decimal      no-undo .
         define variable v-found       as logical      no-undo .

         run accum-chk-gds ( input  v-src
                           , output v-found
                           , output v-old-qnty
                           ) .

         run accum-curr-chk-gds  ( input  v-src
                                 , output v-curr-qnty
                                 ) .
         if ( ( v-curr-qnty + v-src-qnty ) > v-old-qnty )
         AND v-found
         then do:
            if v-old-qnty = 0
            then do:
               assign
                  p-message = "В исходном чеке продажи не было такого товара"
                  p-ok = FALSE
               .
               return.
            end.
            else do:
               assign
                  p-message = substitute( "По данному чеку продажи можно вернуть только &1 товара с кодом &2"
                                       , v-old-qnty
                                       , v-src
                                       )
                  p-ok = FALSE
               .
               return.
            end.
         end.
         define buffer buf_chk-gds     for ub.chk-gds .
         define buffer buf_tt-open-check     for tt-open-check .

         find first buf_tt-open-check
            where buf_tt-open-check.chk-type = INTEGER({&rcpt-sale})
            no-lock
            no-error
            .
         find first buf_chk-gds
            where buf_chk-gds.doc-code = buf_tt-open-check.doc-code
               AND   buf_chk-gds.src-code = v-src
            NO-LOCK
            no-error
            .
         if available buf_chk-gds
         AND v-src-price = 0
         then do:
            assign
               v-src-price       = buf_chk-gds.price-base - buf_chk-gds.discnt
               v-src-discnt      = buf_chk-gds.discnt
            .
         end.
      end.

      if p-cd-mode = {&cd-mode-ret}
      then do:
         assign
            v-src-qnty = - ABS( v-src-qnty )
         no-error.
      end.
      else do:
         assign
            v-src-qnty = ABS( v-src-qnty )
         no-error.
      end.

      case v-pass-gds :
         WHEN 0
         then do:
            if v-with-context
            then do:
               { gbl/eventlib-event-log.i
                  1
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  '*':U
                  0
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  11
                  TIME
                  'U':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  v-src
                  0
                  v-cntxt-userid
                  no-error
               }
               if error-status:error
               then do:
                  message
                     "Z"  11
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
            end.
         end.
         WHEN 1
         then do:
            if v-with-context
            then do:
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  '*':U
                  0
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  12
                  TIME
                  'U':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  v-src
                  0
                  v-cntxt-userid
                  no-error
               }
               if error-status:error
               then do:
                  message
                     "Z"  12
                     skip error-status:get-message(1)
                     skip return-value
                     skip 1
                     skip v-cntxt-db-num
                     skip '':U
                     skip p-cash-num
                     skip {&md}
                     skip buf_tt-head-check.chk-type
                     skip '':U
                     skip '*':U
                     skip 0
                     skip buf_tt-head-check.doc-code
                     skip '':U
                     skip TODAY
                     skip 11
                     skip TIME
                     skip 'U':U
                     skip 0
                     skip v-cntxt-obj-code
                     skip '':U
                     skip {&cd-type-ibs-th}
                     skip 0
                     skip ?
                     skip '':U
                     skip 0
                     skip v-src
                     skip 0
                     skip v-cntxt-userid
                  view-as alert-box information.
               end.
            end.

         end.
         OTHERWISE DO:
            if v-with-context
            then do:
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  '*':U
                  0
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  13
                  TIME
                  'S':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  v-src
                  0
                  v-cntxt-userid
                  no-error
               }
               if error-status:error
               then do:
                  message
                     "Z"  13
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
            end.
            assign
               v-pass-gds = 0
            .

         end.
      end case.

      if v-with-context
      then do:
         assign
            v-chk-name = "":U
            v-gds-code = 0
         .
         { str/libthpos_gds-line.i
            buf_tt-head-check.doc-code
            v-num
            {&add-def}
            1
            v-src
            v-src-qnty
            v-pump
            v-nozzle-code
            v-pl-code
            v-pass-gds
            v-write-off-code
            v-fbr-depart
            p-ok
            v-next
            v-b-code
            v-gds-code
            v-chk-name
            v-second-name
            v-src-price
            v-src-price-rub
            v-src-discnt
            v-src-discnt-rub
            v-src-sum
            v-src-sum-rub
            v-src-sum-netto
            v-src-sum-netto-rub
            v-unit-base
         no-error
         }


         /*  12345  */
         if error-status:error
         then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .


            { gbl/eventlib-event-log.i
               1
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               buf_tt-head-check.chk-type
               '':U
               p-message
               0
               buf_tt-head-check.doc-code
               '':U
               TODAY
               15
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               v-src
               0
               v-cntxt-userid
               no-error
            }
               if error-status:error
               then do:
                  message
                     "Z"  15
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.

              /* 12345 */
              assign
                v-src = '' .

            return.
         end.
      end.


      if v-with-context
      then do:
         { gbl/eventlib-event-log.i
            1
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            buf_tt-head-check.chk-type
            '':U
            '*':U
            0
            buf_tt-head-check.doc-code
            v-src-qnty
            TODAY
            14
            TIME
            'U':U
            v-gds-code
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            v-src
            v-src-sum-netto
            v-cntxt-userid
            no-error
         }
         if error-status:error
         then do:
            message
               "Z"  14
               skip error-status:get-message(1)
               skip return-value
            view-as alert-box information.
         end.
      end.

      define variable v-str-end    as character    no-undo.
/*      if (LENGTH ( v-chk-name ) > 20)
      then v-chk-name = SUBSTRING(v-chk-name, 1, 20).
      else if (LENGTH ( v-chk-name ) < 20)
           then v-chk-name = v-chk-name + FILL(" ", 20 - LENGTH ( v-chk-name ) ).      */

      define variable v-msg    as character    no-undo.
      CREATE buf_tt-line.
      assign
       /*  p-message                = substitute  ( "&1 &2 x &3"
                                                , if length(v-chk-name) > {&g-ed-msgs}
                                                  then SUBSTRING(v-chk-name, 1, {&g-ed-msgs})
                                                  else v-chk-name + FILL(" ", {&g-ed-msgs} - LENGTH ( v-chk-name ) )
                                                , if p-cd-mode = {&cd-mode-ret} then - v-src-qnty else v-src-qnty
                                                , trim(string(v-src-price,"->>>,>>>,>>9.99"))
                                                )  */
         v-disp-msg-1             = v-chk-name
         v-disp-msg-2             = substitute  ( "&1 x &2 &3"
                                                , if p-cd-mode = {&cd-mode-ret} then - v-src-qnty else v-src-qnty
                                                , v-src-price
                                                , v-cd-base-name
                                                )
         buf_tt-line.type         = 0
         buf_tt-line.num          = v-num
         buf_tt-line.line-code    = v-gds-code
         buf_tt-line.line-name    = v-chk-name
         buf_tt-line.line-name-2  = v-second-name
         {&g-buf_tt_line_update}
/*         buf_tt-line.qnty         = ABSOLUTE(v-src-qnty)*/
/*         buf_tt-line.qnty-str     = STRING(ABSOLUTE(v-src-qnty), "->,>>9.999":U)*/
/*         buf_tt-line.price        = v-src-price*/
/*         buf_tt-line.price-STR    = STRING(ABSOLUTE(v-src-price), "->>,>>9.99":U)*/
/*         buf_tt-line.summ-netto   = ABSOLUTE(v-src-sum-netto)*/
/*         buf_tt-line.summ-brutto  = ABSOLUTE(v-src-sum)*/
/*         buf_tt-line.summ-discont = ABSOLUTE(v-src-discnt)*/
         buf_tt-line.src          = v-src
         buf_tt-line.ord-chk-num  = v-ord-chk-num
         buf_tt-line.ord-line-num = v-ord-line-num
         buf_tt-line.line-seller-code = buf_tt-head-check.chk-seller-code
         buf_tt-line.line-seller-name = buf_tt-head-check.chk-seller-name
         v-curr-num-0             = v-num
         v-curr-type-0            = 0
         v-src                    = ""
         v-src-qnty               = 0.0
         v-src-price              = 0.0

         v-src-price-rub          = 0.0
         v-num                    = 0
         p-ok                     = TRUE

         p-message = {&g-p-message-gds_set}
         v-msg            = p-message
      .

      if not v-emul-mode
      AND v-with-context
      then do:
         { gbl/disp-str.i
            v-disp-msg-1
            v-disp-msg-2
            v-disp-msg-2
            p-ok
         }
      end.

      define variable v-num-str    as integer      no-undo.
      define variable v-gds-yes    as integer      no-undo.
      define variable v-pay-yes    as integer      no-undo.
      define variable v-num-local   as integer      no-undo.
      define variable v-type-local  as integer      no-undo.
      if  v-with-context
      AND INDEX(v-next, "=") > 0
      AND not v-recalc
      then do:
         assign
            v-recalc  = TRUE
            v-next    = TRIM(v-next, "recalc=")
            v-num-str = INTEGER(ENTRY(1, v-next, ","))
            v-gds-yes = INTEGER(ENTRY(2, v-next, ","))
            v-pay-yes = INTEGER(ENTRY(3, v-next, ","))
            v-num-local  = v-curr-num-0
            v-type-local = v-curr-type-0
         .
         run recalc-lines in this-procedure
                        ( input v-num-str
                        , input v-gds-yes
                        , input v-pay-yes
                        , input-output p-cd-mode
                        , INPUt-output p-cd-submode
                        , output p-message
                        , output p-ok
                        ) .
         assign
            v-recalc         = FALSE
            v-src            = ""
            v-src-qnty       = 0.0
            v-src-price      = 0.0
            v-src-price-rub  = 0.0
            v-curr-num-0     = v-num-local
            v-curr-type-0    = v-type-local
         .
      end.
      if  p-cd-mode = {&cd-mode-ret}
      AND v-ord-chk-num  = "":U
      AND v-ord-line-num = 0
      then do:
         assign
            p-cd-submode = {&cd-submode-price}
            p-message    = "Подтвердите цену товара"
            p-ok         = TRUE
            v-src        = STRING(buf_tt-line.price)
            v-src-price  = buf_tt-line.price
            v-src-price-rub  = buf_tt-line.price-rub
         .
         run 2004 ( INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output p-message
                  , output p-ok
                  ) .

      end.
   end.
   assign
      p-message    =  v-msg
      v-src        = ""
      v-src-qnty   = 0.0
      v-src-price  = 0.0
      v-src-price-rub  = 0.0
   .

end. /* do on error */
end procedure. /* add-gds-line */



/*==========================================================================*/
procedure cd-context :
define INPUt-output parameter p-cd-mode    as character        no-undo.
define INPUt-output parameter p-cd-submode as character        no-undo.
define output       parameter p-message    as character        no-undo.
define output       parameter p-ok         as logical          no-undo.

do
on error undo, return error
:
define variable v-fr-mode            as integer      no-undo.
define variable v-fr-time            as integer      no-undo.
define variable v-fr-date            as date         no-undo.
define variable v-fr-last-shift-date as date         no-undo.
define variable v-fr-last-shift-old  as integer      no-undo.
define variable v-fr-lic             as character    no-undo.

define variable v-diff-time            as decimal   no-undo .
define variable v-max-diff-seconds      as integer   no-undo initial 120 .

define variable v-integer   as integer      no-undo.
define variable v-character as character    no-undo.
define variable v-decimal   as decimal      no-undo.
define variable v-logical   as logical      no-undo.
define variable v-date    as date         no-undo.
define variable v-handle    as handle       no-undo.
define variable v-cont    as integer    no-undo.
define variable v-data-type    as character    no-undo.
define variable v-fr-serial          as char    no-undo.


   if not v-emul-mode
      then do:
      assign
         v-fr-last-shift-old = v-fr-last-shift-num
      .

      { gbl/fr-ctrl.i
         v-cash-drawer-open
         p-message
         p-ok
         v-fr-mode
         v-fr-time
         v-fr-date
         v-fr-last-shift-date
         v-fr-last-shift-num
         v-fr-lic
         v-fr-shift-open
         v-fr-serial
         no-error
      }
/*      message*/
/*         "X"  3*/
/*         skip v-fr-last-shift-num*/
/*      view-as alert-box information.*/


      if not p-ok
      then do:
         /* Пока чек открыт кассу не блокируем,
            заблокируем после закрытия чека     */
         if  v-fr-shift-open = 24 then
         do:

          if ( p-cd-mode = {&cd-mode-sale}
          OR   p-cd-mode = {&cd-mode-ret}
             )
          then do:
            assign
               p-ok = TRUE
            .
            return.
          end .
          assign
            p-cd-mode    = {&cd-mode-block}
            p-cd-submode = {&cd-submode-goods}
          .
          return .
         end.

         /* !!! */
         define buffer bf_tt-head-check     for tt-head-check .
         find first bf_tt-head-check no-error.
         define variable vv-chk-type    as integer    no-undo.
         define variable vv-doc-code    as character    no-undo.
         if available bf_tt-head-check
         then do:
            assign
               vv-chk-type = bf_tt-head-check.chk-type
               vv-doc-code = bf_tt-head-check.doc-code
            .
            RELEASE bf_tt-head-check.
         end.


         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            vv-chk-type
            '':U
            p-message
            0
            vv-doc-code
            '':U
            TODAY
            4
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
            if error-status:error
            then do:
               message
                  "Z"  4
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.

         assign
            p-cd-mode    = {&cd-mode-block}
            p-cd-submode = {&cd-submode-goods}
         .
         return.
      end.
      else do:
         if p-cd-mode    = {&cd-mode-block}
         then do:
            assign
               p-message    = " ":U
               p-cd-mode    = v-cd-mode-pre
               p-cd-submode = v-cd-submode-pre
            .
         end.
      end.
      if v-fr-serial <> v-context-serial
      then do:
         assign
            p-message = substitute ( "Серийный номер ФР (&1) отличается от указанного в настройках (&2)"
                                   , v-fr-serial
                                   , v-context-serial
                                   )
            p-cd-mode = {&cd-mode-block}
            p-ok      = FALSE
         .
      end.

      if  v-fr-shift-open = 0
      AND not p-cd-mode <> {&cd-mode-sale}
      AND not p-cd-mode <> {&cd-mode-ret}
      then do:
         assign
            p-cd-mode    = {&cd-mode-close-shift}
            p-cd-submode = {&cd-submode-goods}
         .
         return.
      end.
      assign
         v-diff-time = v-fr-time - time
      .


      if absolute(v-diff-time) > v-max-diff-seconds
      then do:
         assign
            p-message =
            "Неверное время на фискальном регистраторе " +
            string(v-fr-time,"HH:MM:SS") +  " "  + string(time,"HH:MM:SS")  +  " "  +
            string(v-max-diff-seconds)
            /* + "{&new-line}" +
            "" + (if v-diff-time < 0 then "больше" else "меньше" ) + " времени на сервере " + "{&new-line}" +
            "на " + STRING(truncate( abs( v-diff-time ), 0 )) + "секунд(ы)" + "{&new-line}" +
            substitute("Время на ФР и время на сервере не должны различаться более чем на &1 секунд(ы)."
                     ,v-max-diff-seconds
                     )*/ + {&new-line} +
            "Необходимо закрыть смену на кассе и выставить время"
             + {&new-line}
             + STRING(v-diff-time) + "-" + STRING(v-fr-time, "HH:MM:SS") + "-" + STRING( time, "HH:MM:SS")
            /*
            p-cd-mode = {&cd-mode-user-block}
            p-cd-submode = {&cd-submode-goods}
            */
            p-cd-mode = {&cd-mode-block}
            p-ok      = FALSE
         .
      end.
   end.
   else do:
      assign
         p-ok = TRUE
         v-fr-last-shift-num = 99999
      .
   end.
   if v-fr-last-shift-old <> v-fr-last-shift-num
   then do:
/*      message*/
/*         "X"  4*/
/*         skip v-fr-last-shift-num*/
/*         skip v-fr-last-shift-old*/
/*      view-as alert-box information.*/
      assign
         v-fr-last-shift-old = v-fr-last-shift-num
         v-integer = v-fr-last-shift-num
         v-cont    = {&context}
      .
      { str/libthpos_set-context-property.i
         v-cont
         'z-number'
         v-character
         v-date
         v-decimal
         v-integer
         v-logical
         v-handle
         p-ok
      no-error
      }
      if error-status:error
      OR not p-ok
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         return .
      end.
      assign
         v-integer = ?
      .
   end.

   if p-cd-mode = {&cd-mode-ready}
   then do:
      /* Предел наличности */
      { str/libthpos_get-context-property.i
         {&context}
         'cash-counter'
         v-character
         v-date
         v-decimal
         v-integer
         v-logical
         v-handle
         v-data-type
         p-ok
         no-error
      }
      if error-status:error
      OR not p-ok
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         return .
      end.

      if v-decimal > v-cash-drawer-limit
      then do:
         assign
            p-message = substitute( "Наличность в денежном ящике: &1 превысила допустимый предел &2", v-decimal, v-cash-drawer-limit )
            p-ok = FALSE
         .
         return.
      end.
   end.

   assign
      p-ok = TRUE
   .



end. /* do on error */
end procedure. /* cd-context */




/*==========================================================================*/
procedure 1983 :  /* Оплата */
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define variable v-st-r-b as decimal no-undo .
define variable v-st-rubl as decimal no-undo .
define variable v-st-base as decimal no-undo .
define variable v-tot-doc as decimal no-undo .
define variable v-netto as decimal no-undo .
define variable v-netto-rubl as decimal no-undo .
define variable v-netto-base as decimal no-undo .
define variable v-all-discnt as decimal no-undo .
define variable v-all-discnt-rubl as decimal no-undo .
define variable v-all-discnt-base as decimal no-undo .

do
on error undo, return error
:
   if p-cd-mode = {&cd-mode-sale}
   OR p-cd-mode = {&cd-mode-ret}
   then do:

      if p-cd-submode = {&cd-submode-goods}
      then do:
         find tt-head-check.

         { str/libthpos_sub-total.i
            tt-head-check.doc-code
            ''
            p-ok
            v-st-r-b
            v-st-rubl
            v-st-base
            v-tot-doc
            v-discnt-chk
            v-netto
            v-netto-rubl
            v-netto-base
            v-all-discnt
            v-all-discnt-rubl
            v-all-discnt-base
            no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            return.
         end.

         assign
            v-disp-msg-1 = "К оплате"
            v-disp-msg-2 = STRING(ABS( v-netto-rubl )) + " " + v-cd-base-name
         .

         if not v-emul-mode
         then do:
            { gbl/disp-str.i
               v-disp-msg-1
               v-disp-msg-2
               p-message
               p-ok
            }
         end.

         assign
            p-message    = "Наличными"
            p-cd-submode = {&cd-submode-pay}
            p-ok         = TRUE
         .
      end.
      if p-cd-submode =  {&cd-submode-pay}
      then do:

         define buffer buf_rule-call-param   for ub.rule-call-param .
         define buffer buf_cash-pay          for ub.cash-pay .

         define variable v-pay    as logical      no-undo.
         define variable v-sum    as logical      no-undo.

         for each  buf_rule-call-param
               where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
               no-lock
            :
            case buf_rule-call-param.param-name:
               WHEN "p-cash-pay"
               then do:
                  if NUM-ENTRIES ( buf_rule-call-param.param-value-character ) > 1
                  then do:
                     assign
                        v-pay-type        = INTEGER( ENTRY( 1, buf_rule-call-param.param-value-character ) ) /* ENTRY(buf_tt0-rule-call-param.param-num, v-other-params, {&delim-par}) */
                        v-curr-base-code  = INTEGER( ENTRY( 2, buf_rule-call-param.param-value-character ) )
                        v-pay             = TRUE
                     no-error
                     .
                     if error-status:error
                     then do:
                        assign
                           p-message = substitute( "Неправильно настроен тип платежа для данной функции: &1", buf_rule-call-param.param-value-character)
                        .
                        return.
                     end.
                  end.
                  /*
                  else do:
                     assign
                        p-message = substitute( "Неправильно настроен тип платежа для данной функции: &1", buf_rule-call-param.param-value-character)
                     .
                     return.
                  end.
                  */
               end.
               WHEN "p-tot-sum"
               then do:
                  if  buf_rule-call-param.param-value-decimal <> 0
                  AND buf_rule-call-param.param-value-decimal <> ?
                  then
                  assign
                     v-src = STRING(buf_rule-call-param.param-value-decimal)
                     v-sum = if (buf_rule-call-param.param-value-decimal <> 0) then TRUE else FALSE
                  .
               end.
               OTHERWISE DO:
               end.
            end case.
         end.

         if v-pay
         then do:
            if v-sum
            then do:
               run input-pay-sale  ( INPUt-OUTPUT p-cd-mode
                                    , INPUt-output p-cd-submode
                                    , output p-message
                                    , output p-ok
                                    ) .
            end.
            else do:
               find first buf_cash-pay
                    where buf_cash-pay.cdpay-code = v-pay-type
                      AND buf_cash-pay.curr-code  = v-curr-base-code
                    NO-LOCK
                    no-error
                     .
               if not available buf_cash-pay
               then do:
                  assign
                     p-message = substitute( "Не найден тип платежа: &1", buf_rule-call-param.param-value-character)
                  .
                  return.
               end.
               /*
               run summ-for-pay  ( INPUt-OUTPUT p-cd-mode
                                 , INPUt-output p-cd-submode
                                 , output p-message
                                 , output p-ok
                                 ) .
               */
               assign
                  p-message = buf_cash-pay.obj-name
                  p-ok      = TRUE
               .
               RELEASE buf_cash-pay.
            end.
         end.
         else do:
            assign
               p-message = "Не задан тип платежа"
            .
            return.
         end.
      end.
   end.

end. /* do on error */
end procedure. /* 1983 */


/*==========================================================================*/
procedure 2004 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

do
on error undo, return error
:

   if CAN-find( first tt-open-check where tt-open-check.chk-type = INTEGER({&rcpt-sale}))
   then do:
      assign
        p-message = "Чек возврата привязан к чеку продажи, ИЗМЕНИТЬ ЦЕНУ НЕВОЗМОЖНО"
        p-ok      = false
      .
      return.
   end.


   if p-cd-mode = {&cd-mode-ret}
   then do:
      assign
        p-message    = "Подтвердите цену товара"
        p-cd-submode = {&cd-submode-price}
        p-ok         = TRUE
      .
   end.

end. /* do on error */
end procedure. /* 2004 */



/*==========================================================================*/
procedure set-all-summ :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define buffer buf_tt-line     for tt-line .

do
on error undo, return error
:
   assign
      v-summ-netto-rub   = 0.0
      v-summ-brutto-rub  = 0.0
      v-summ-discont-rub = 0.0
      v-summ-pay-rub     = 0.0
   .

   for each  buf_tt-line
       where buf_tt-line.type = 1
   :
      assign
         v-summ-pay-rub = v-summ-pay-rub + ABS(buf_tt-line.summ-netto-rub)
      .
   end.

   define variable v-st-r-b as decimal no-undo .
   define variable v-st-rubl as decimal no-undo .
   define variable v-st-base as decimal no-undo .
   define variable v-tot-doc as decimal no-undo .
   define variable v-netto as decimal no-undo .
   define variable v-netto-rubl as decimal no-undo .
   define variable v-netto-base as decimal no-undo .
   define variable v-all-discnt as decimal no-undo .
   define variable v-all-discnt-rubl as decimal no-undo .
   define variable v-all-discnt-base as decimal no-undo .

   find tt-head-check no-error.
   if not available tt-head-check then return.

   { str/libthpos_sub-total.i
      tt-head-check.doc-code
      ''
      p-ok
      v-st-r-b
      v-st-rubl
      v-st-base
      v-tot-doc
      v-discnt-chk
      v-netto
      v-netto-rubl
      v-netto-base
      v-all-discnt
      v-all-discnt-rubl
      v-all-discnt-base
      no-error
   }
   define variable v-reg-value    as character    no-undo.
   define variable v-reg-name     as character    no-undo.

   { gbl/fr-get-reg.i
      'cash':U
      241
      v-reg-value
      v-reg-name
      p-message
      p-ok
      no-error
   }
   if error-status:error
   then do:
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      /*
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         '':U
         '':U
         p-message
         '':U
         '':U
         '':U
         TODAY
         80
         TIME
         'E':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }
      */
      return.
   end.
   else do:
      assign
         v-summ-fr = DECIMAL(v-reg-value)
      .
   end.
   assign
      v-summ-brutto-rub  = v-st-rubl
      v-summ-discont-rub = v-all-discnt-rubl
      v-summ-netto-rub   = ABS(v-netto-rubl)
      p-ok           = TRUE
   .

end. /* do on error */
end procedure. /* set-all-summ */


/*==========================================================================*/
procedure get-all-summ :
define output parameter p-summ-brutto  as decimal          no-undo.
define output parameter p-summ-netto   as decimal          no-undo.
define output parameter p-summ-discont as decimal          no-undo.
define output parameter p-sum-pay      as decimal          no-undo.
define output parameter p-sum-fr       as decimal          no-undo.
define output parameter p-summ-for-pay as decimal          no-undo.
define output parameter p-disc-pay     as decimal          no-undo.
define output parameter p-message      as character      no-undo .
define output parameter p-ok           as logical          no-undo.

do
on error undo, return error
:
   run set-all-summ  ( output p-message
                     , output p-ok
                     ) .
   if p-ok
   then do:
      assign
         /* Итого = сумма товарных строк с учетом всех скидок на товары и скидками на итог.
         (Предназначено для того, чтобы на экране кассира всегда была сумма чека,
         которую надо оплатить покупателю.)*/
         p-summ-brutto  = ABS( v-summ-brutto-rub  )
         p-summ-netto   = ABS( v-summ-netto-rub   )
         /*Скидка = сумма всех товарных скидок, скидок на итог, и скидок на проведенные платежи. */
         p-summ-discont = ABS( v-summ-discont-rub - (ABS(v-summ-brutto-rub) - ABS(v-summ-netto-rub)))
         /*Оплата = сумме оплат, уже проведенных по чеку.*/
         p-sum-pay      = ABS( v-summ-pay-rub     )
         p-sum-fr       = v-summ-fr
         p-summ-for-pay = v-sum-for-pay
         p-disc-pay     = (ABS(v-summ-brutto-rub) - ABS(v-summ-netto-rub))
      .
   end.

end. /* do on error */
end procedure. /* get-all-summ */







/*==========================================================================*/
procedure 1998 :  /* Регистрация дисконтной карты */
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define buffer buf_rule-call-param   for ub.rule-call-param .

define variable v-card    as logical      no-undo.

do
on error undo, return error
:
   case p-cd-submode:
      WHEN {&cd-submode-goods} OR
      WHEN {&cd-submode-card-chk}
      then do:

         if p-cd-mode = {&cd-mode-ready}
         then do:
            run chk-sale-open ( INPUt-OUTPUT p-cd-mode
                              , INPUt-output p-cd-submode
                              , output p-message
                              , output p-ok
                              ) .
         end.

         for each  buf_rule-call-param
               where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
               no-lock
            :
            case buf_rule-call-param.param-name:
               WHEN "p-d-card"
               then do:
                  if  buf_rule-call-param.param-value-character <> "":U
                  AND buf_rule-call-param.param-value-character <> ?
                  then
                  assign
                     v-src = buf_rule-call-param.param-value-character
                     v-card = TRUE
                  .
               end.
               OTHERWISE DO:
               end.
            end case.
         end.

         if v-card
         then do:
            run input-card ( INPUt-OUTPUT p-cd-mode
                           , INPUt-output p-cd-submode
                           , output p-message
                           , output p-ok
                           ) .
         end.
         else do:
            if p-cd-submode = {&cd-submode-goods}
            then do:
               assign
                  p-message    = "Регистрация дисконтной карты"
                  p-cd-submode = {&cd-submode-card-chk}
                  p-ok         = TRUE
               .
            end.
            else do:
               assign
                  p-message = "Не задан номер карты"
               .
            end.
            return.
         end.
      end.
      OTHERWISE DO:
      end.
   end case.
end. /* do on error */
end procedure. /* 1998 */




/*==========================================================================*/
procedure cr-down :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

do
on error undo, return error
:

end. /* do on error */
end procedure. /* cr-down */




/*==========================================================================*/
procedure cr-up :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

do
on error undo, return error
:

end. /* do on error */
end procedure. /* cr-up */


/*==========================================================================*/
procedure set-src :
define input  parameter p-src as character        no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   assign
      v-src = p-src
      p-ok  = TRUE
   .

end. /* do on error */
end procedure. /* set-src */



/*==========================================================================*/
procedure input-qnty :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   if p-cd-mode = {&cd-mode-sale}
   OR p-cd-mode = {&cd-mode-ret}
   then do:
      assign
         v-src-qnty = DECIMAL( v-src )
      no-error.
      if error-status:error
      then do:
         assign
            p-message = substitute( "Вы ввели не число: &1 Введите количество правильно.", v-src )
            p-ok = FALSE
         .
         return.
      end.
      /*
      if v-src-qnty > 999
      then do:
         assign
            p-message = "Превышено допустимое количество (999)"
            p-ok = FALSE
         .
         return.
      end.
      */
      assign
         p-cd-submode = {&cd-submode-goods}
         p-ok = TRUE
      .
   end.

end. /* do on error */
end procedure. /* input-qnty */




/*==========================================================================*/
procedure input-price :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define buffer buf_tt-line        for tt-line .
define buffer buf_tt-head-check  for tt-head-check .

define variable v-next    as character    no-undo.
define variable v-b-code          as integer no-undo .
define variable v-gds-code        as integer no-undo .
define variable v-chk-name        as character no-undo .
define variable v-second-name     as character no-undo .
define variable v-src-sum         as decimal no-undo .
define variable v-src-sum-netto   as decimal no-undo .

do
on error undo, return error
:
   /*
   if p-cd-mode = {&cd-mode-ret}
   then do:
      assign
         v-src-price = DECIMAL( v-src )
      no-error.
      if error-status:error
      then do:
         assign
            p-message = substitute( "Вы ввели не число: &1 Введите количество правильно.", v-src )
            p-ok = FALSE
         .
         return.
      end.
      assign
         p-message    = substitute("Цена &1", v-src)
         p-cd-submode = {&cd-submode-goods}
         p-ok = TRUE
      .
   end.
   */

   if v-curr-num-0 <> 0
   AND /*(*/ p-cd-mode = {&cd-mode-ret}
   /* когда будет разрешена свободная цена можно открыть и это
   OR p-cd-mode = {&cd-mode-sale})
   */
   then do:
      find first buf_tt-line
           where buf_tt-line.num  = v-curr-num-0
             and buf_tt-line.type = v-curr-type-0
           no-lock
           .
      find buf_tt-head-check.

      /* +++ */
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         buf_tt-head-check.chk-type
         '':U
         '*':U
         '':U
         buf_tt-head-check.doc-code
         '':U
         TODAY
         49
         TIME
         'U':U
         buf_tt-line.line-code
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         buf_tt-line.price
         ?
         '':U
         0
         v-src
         buf_tt-line.summ-netto
         v-cntxt-userid
         no-error
      }

      assign
         v-src-price = DECIMAL( v-src )
      no-error.
      if error-status:error
      then do:
         assign
            p-message = substitute( "Вы ввели не число: &1 Введите количество правильно.", v-src )
            p-ok = FALSE
         .

         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            buf_tt-head-check.chk-type
            '':U
            p-message
            '':U
            buf_tt-head-check.doc-code
            buf_tt-line.qnty
            TODAY
            51
            TIME
            'U':U
            buf_tt-line.line-code
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            buf_tt-line.price
            ?
            '':U
            0
            v-src
            buf_tt-line.summ-netto
            v-cntxt-userid
            no-error
         }

         return.
      end.

      case buf_tt-line.type:
         WHEN 0 then do:
            assign
               v-pump            = 0
               v-nozzle-code     = 0
               v-pl-code         = 0
               v-pass-gds        = 0
               v-fbr-depart      = 0
               v-write-off-code  = 0
               v-src-qnty        = if p-cd-mode = {&cd-mode-ret} then - buf_tt-line.qnty else buf_tt-line.qnty
               v-src             = buf_tt-line.src
            .
            { str/libthpos_gds-line.i
               buf_tt-head-check.doc-code
               v-curr-num-0
               {&update}
               0
               v-src
               v-src-qnty
               v-pump
               v-nozzle-code
               v-pl-code
               v-pass-gds
               v-write-off-code
               v-fbr-depart
               p-ok
               v-next
               v-b-code
               v-gds-code
               v-chk-name
               v-second-name
               v-src-price
               v-src-price-rub
               v-src-discnt
               v-src-discnt-rub
               v-src-sum
               v-src-sum-rub
               v-src-sum-netto
               v-src-sum-netto-rub
               v-unit-base
            no-error
            }
            /* 12345 */
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .

               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  p-message
                  '':U
                  buf_tt-head-check.doc-code
                  buf_tt-line.qnty
                  TODAY
                  51
                  TIME
                  'U':U
                  buf_tt-line.line-code
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  buf_tt-line.price
                  ?
                  '':U
                  0
                  v-src
                  buf_tt-line.summ-netto
                  v-cntxt-userid
                  no-error
               }

               return.
            end.
            define variable v-msg    as character    no-undo.
            assign
               v-msg                = substitute  ( "&1 &2x&3"
                                                      , buf_tt-line.line-name
                                                      , if p-cd-mode = {&cd-mode-ret} then - v-src-qnty else v-src-qnty
                                                      , v-src-price
                                                      )
               v-disp-msg-1             = v-chk-name
               v-disp-msg-2             = substitute  ( "&1 x &2 &3"
                                                      , if p-cd-mode = {&cd-mode-ret} then - v-src-qnty else v-src-qnty
                                                      , v-src-price
                                                      , v-cd-base-name
                                                      )
               {&g-buf_tt_line_update}
               p-message = {&g-p-message-gds_set}
/*               buf_tt-line.qnty         = ABS(v-src-qnty)*/
/*               buf_tt-line.qnty-str     = STRING(ABS(v-src-qnty), "->,>>9.999":U)*/
/*               buf_tt-line.price        = ABS(v-src-price)*/
/*               buf_tt-line.price-str    = STRING(ABS(v-src-price), "->>,>>9.99":U)*/
/*               buf_tt-line.summ-netto   = ABS(v-src-sum-netto)*/
/*               buf_tt-line.summ-brutto  = ABS(v-src-sum)*/
/*               buf_tt-line.summ-discont     = ABS(v-src-discnt)*/
            .
            if not v-emul-mode
            then do:
               { gbl/disp-str.i
                  v-disp-msg-1
                  v-disp-msg-2
                  p-message
                  p-ok
               }
            end.
            else do:
               assign
                  p-ok         = TRUE
               .
            end.
         end.
         WHEN 1 then do:
         end.
         OTHERWISE DO:
         end.
      end case.
   end.
   define variable v-num-str    as integer      no-undo.
   define variable v-gds-yes    as integer      no-undo.
   define variable v-pay-yes    as integer      no-undo.

   { gbl/eventlib-event-log.i
      0
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      buf_tt-head-check.chk-type
      '':U
      '*':U
      '':U
      buf_tt-head-check.doc-code
      buf_tt-line.qnty
      TODAY
      50
      TIME
      'S':U
      buf_tt-line.line-code
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      buf_tt-line.price
      ?
      '':U
      0
      v-src
      v-src-sum-netto
      v-cntxt-userid
      no-error
   }
   assign
      v-msg = p-message
   .
   define variable v-num-local   as integer      no-undo.
   define variable v-type-local  as integer      no-undo.
   if  INDEX(v-next, "=") > 0
   AND not v-recalc
   then do:
      assign
         v-recalc  = TRUE
         v-next    = TRIM(v-next, "recalc=")
         v-num-str = INTEGER(ENTRY(1, v-next, ","))
         v-gds-yes = INTEGER(ENTRY(2, v-next, ","))
         v-pay-yes = INTEGER(ENTRY(3, v-next, ","))
         v-num-local  = v-curr-num-0
         v-type-local = v-curr-type-0
      .
      run recalc-lines in this-procedure
                     ( input v-num-str
                     , input v-gds-yes
                     , input v-pay-yes
                     , input-output p-cd-mode
                     , INPUt-output p-cd-submode
                     , output p-message
                     , output p-ok
                     ) .
      assign
         v-src            = ""
         v-src-qnty       = 0.0
         v-src-price      = 0.0
         v-src-price-rub  = 0.0
         v-recalc  = FALSE
         v-curr-num-0     = v-num-local
         v-curr-type-0    = v-type-local
      .
   end.
   assign
      /*
      p-message = {&g-p-message-gds_set}
      */
      p-message    = v-msg
      v-src        = ""
      v-src-qnty   = 0.0
      v-src-price  = 0.0
      v-src-price-rub  = 0.0
      v-num        = 0
      p-cd-submode = {&cd-submode-goods}
      p-ok         = TRUE
   .

end. /* do on error */
end procedure. /* input-price */



/*==========================================================================*/
procedure input-card :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define buffer buf_tt-head-check     for tt-head-check .
define buffer buf_clients           for ub.clients .

define variable v-num-str    as integer      no-undo.
define variable v-gds-yes    as integer      no-undo.
define variable v-pay-yes    as integer      no-undo.
define variable v-msg    as character    no-undo.

do
on error undo, return error
:
   if p-cd-mode = {&cd-mode-sale}
   OR p-cd-mode = {&cd-mode-ret}
   then do:
      find buf_tt-head-check.
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            buf_tt-head-check.chk-type
            v-d-card
            '*':U
            '':U
            buf_tt-head-check.doc-code
            '':U
            TODAY
            36
            TIME
            'U':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }


      { str/libthpos_set-card.i
         buf_tt-head-check.doc-code
         v-src
         v-d-card
         v-cli-type
         v-cli-code
         v-obj-name
         no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok  = FALSE
            v-src = "":u
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            buf_tt-head-check.chk-type
            v-d-card
            p-message
            '':U
            buf_tt-head-check.doc-code
            '':U
            TODAY
            38
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      find first buf_clients
           where buf_clients.obj-type = v-cli-type
             AND buf_clients.obj-code = v-cli-code
           NO-LOCK
           .
      assign
         v-obj-name   = if v-obj-name = "":U then buf_clients.obj-name else v-obj-name
         p-message    = substitute("Карта &1 клиент &2&3", v-src, buf_clients.obj-name)
         v-msg        = substitute("Карта &1 клиент &2&3", v-src, buf_clients.obj-name)
         p-cd-submode = {&cd-submode-goods}
         p-ok = TRUE
         v-src = "":u
         v-disp-msg-1             = buf_clients.obj-name
         v-disp-msg-2             = "":U
         buf_tt-head-check.d-card   = v-d-card
         buf_tt-head-check.cli-type = v-cli-type
         buf_tt-head-check.cli-code = v-cli-code
         buf_tt-head-check.obj-name = substitute("клиент &2 &3", v-cli-code, buf_clients.obj-name)
      .

      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         buf_tt-head-check.chk-type
         v-d-card
         '*':U
         '':U
         buf_tt-head-check.doc-code
         '':U
         TODAY
         37
         TIME
         'S':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }
      if not v-emul-mode
      then do:
         { gbl/disp-str.i
            v-disp-msg-1
            v-disp-msg-2
            p-message
            p-ok
         }
      end.
      define variable v-num-local   as integer      no-undo.
      define variable v-type-local  as integer      no-undo.
      assign
         v-num-local  = v-curr-num-0
         v-type-local = v-curr-type-0
      .

      /*
      if not v-recalc
      then do:
         assign
            v-recalc  = TRUE
            v-num-str = 1
            v-gds-yes = 1
            v-pay-yes = 1
            v-num-local  = v-curr-num-0
            v-type-local = v-curr-type-0
         .
         run refresh-lines in this-procedure
                        ( input v-num-str
                        , input v-gds-yes
                        , input v-pay-yes
                        , input-output p-cd-mode
                        , INPUt-output p-cd-submode
                        , output p-message
                        , output p-ok
                        ) .
         assign
            v-src            = ""
            v-src-qnty       = 0.0
            v-src-price      = 0.0
            v-src-price-rub  = 0.0
            v-recalc  = FALSE
            v-curr-num-0     = v-num-local
            v-curr-type-0    = v-type-local
         .
         if p-ok
         then do:
            assign
               p-message = v-msg
            .
         end.
      end.
      */
      run refresh-lines in this-procedure
                     ( /*input v-num-str
                     , input v-gds-yes
                     , input v-pay-yes
                     , input-output p-cd-mode
                     , INPUt-output p-cd-submode
                     , */ output p-message
                     , output p-ok
                     ) .
      assign
         v-curr-num-0     = v-num-local
         v-curr-type-0    = v-type-local
         v-src            = ""
         v-src-qnty       = 0.0
         v-src-price      = 0.0
         v-src-price-rub  = 0.0
      .
   end.

end. /* do on error */
end procedure. /* input-card */




/*==========================================================================*/
procedure set-input-time :
define input      parameter p-time as INTEGER        no-undo.
define output     parameter p-message     as character      no-undo .
define output     parameter p-ok          as logical          no-undo.
do
on error undo, return error
:
   assign
      v-input-time = p-time
   .
   if p-time > 500
   then do:
      assign
         v-pass-gds = 1
      .
   end.
   else do:
      if p-time < 0
      then do:
         assign
            v-pass-gds = -1
         .
      end.
      else do:
         assign
            v-pass-gds = 0
         .
      end.
   end.
end. /* do on error */
end procedure. /* set-input-time */




/*==========================================================================*/
procedure clear-tt-chk :
define buffer buf_tt-head-check     for tt-head-check .
define buffer buf_tt-line           for tt-line .
define buffer buf_tt-open-check     for tt-open-check .

do
on error undo, return error
:
   EMPTY TEMP-TABLE buf_tt-head-check.
   EMPTY TEMP-TABLE buf_tt-line.
   EMPTY TEMP-TABLE buf_tt-open-check.

   assign
      v-src                = ""
      v-src-qnty           = 0
      v-curr-num-0         = 0
      v-curr-type-0        = 0
      v-input-time         = 0
      v-pay-type           = ?
      v-curr-base-code     = v-cd-base-code
      /*
      v-reopen-chk         = "":U
      v-cashier            = 0
      v-cashier-psn-code   = 0
      */
      v-d-card             = ""
      v-cli-type           = ""
      v-cli-code           = 0
      v-obj-name           = ""
      v-summ-netto         = 0
      v-summ-brutto        = 0
      v-summ-discont       = 0
      v-summ-netto-rub     = 0
      v-summ-brutto-rub    = 0
      v-summ-discont-rub   = 0
      v-discnt-chk         = 0
      v-summ-pay           = 0
      v-summ-pay-rub       = 0
      v-disc-type          = "":U /* {&discnt-v-pcnt} */
      v-with-context       = TRUE
      v-num                = 0
      v-ord-chk-num        = "":U
      v-ord-line-num       = 0
      v-aux-mess           = ''
   .
end. /* do on error */
end procedure. /* clear-tt-chk */




/*==========================================================================*/
procedure set-cashier :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   { gbl/getcntxt.i get }
   define buffer buf_user-account      for ub.user-account .
   define buffer buf_staff      for ub.staff .
   define buffer buf_clients     for ub.clients .
   define buffer buf_person      for ub.person .

   define variable v-first-name    as character    no-undo.
   define variable v-second-name    as character    no-undo.

   find first buf_user-account
        where buf_user-account.user-id = v-cntxt-userid
        no-lock
        .

   find  first buf_staff
         where buf_staff.role  = {&role-cashier}
      and buf_staff.role-level = {&role-level-db}
      and buf_staff.date-start <= today
      and buf_staff.date-end >= today
      and buf_staff.psn-code = buf_user-account.psn-code
      and buf_staff.db-num     = v-cntxt-db-num
      no-lock
      no-error.
   if not available buf_staff
   then do:
       message
         "Пользователь"
         SKIP "ID:"        buf_user-account.user-id
         SKIP "Фамилия:"   buf_user-account.last-name
         skip "Псевдоним:" buf_user-account.nik
         skip "БД:"        v-cntxt-db-num
         skip "не является кассиром. Работа с кассой невозможна."
       view-as alert-box error.
       return.
   end.
   find first buf_clients
        where buf_clients.obj-type = {&prs}
          AND buf_clients.obj-code = buf_user-account.psn-code
        NO-LOCK
        .
   find first buf_person
        where buf_person.psn-code = buf_user-account.psn-code
        NO-LOCK
        .
   assign
      v-first-name  = SUBSTRING(TRIM(buf_person.name1), 1, 1)
      v-second-name = SUBSTRING(TRIM(buf_person.name2), 1, 1)
   .

   Assign
      v-cashier          = buf_staff.staff-code
      v-cashier-psn-code = buf_user-account.psn-code
      v-cashier-name     = Substitute( "Кассир &1 &2&3 &4&5"
                                     , buf_clients.obj-name
                                     , v-first-name
                                     , if v-first-name <> "":U then "." else "":U
                                     , v-second-name
                                     , if v-second-name <> "":U then "." else "":U
                                     )
      p-ok               = TRUE
   .
end. /* do on error */
end procedure. /* set-cashier */




/*==========================================================================*/
procedure subm-qnty :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   if p-cd-mode = {&cd-mode-sale}
   OR p-cd-mode = {&cd-mode-ret}
   then do:
      assign
         p-cd-submode = {&cd-submode-qnty}
         p-ok         = TRUE
      .
   end.

end. /* do on error */
end procedure. /* subm-qnty */



/*==========================================================================*/
procedure 1997 : /* регистрация продавца */
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define buffer buf_rule-call-param   for ub.rule-call-param .

define variable v-sel    as logical      no-undo.

do
on error undo, return error
:
   case p-cd-mode :
      WHEN {&cd-mode-sale} OR
      WHEN {&cd-mode-ret} then do:
         if p-cd-submode = {&cd-submode-goods}
         then do:
            assign
               p-message    = "Регистрация продавца"
               p-cd-submode = {&cd-submode-seller}
               p-ok         = TRUE
            .
         end.

         if p-cd-submode = {&cd-submode-seller}
         then do:
            for each  buf_rule-call-param
               where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
               no-lock
               :
               case buf_rule-call-param.param-name:
                  WHEN "p-seller"
                  then do:
                     if  buf_rule-call-param.param-value-integer <> 0
                     AND buf_rule-call-param.param-value-integer <> ?
                     then do:
                     assign
                        v-src = STRING(buf_rule-call-param.param-value-integer)
                        v-sel = TRUE
                     .
                     end.
                  end.
                  OTHERWISE DO:
                  end.
               end case.
            end.

            if v-sel
            then do:
               run input-saller  ( INPUt-OUTPUT p-cd-mode
                                 , INPUt-output p-cd-submode
                                 , output p-message
                                 , output p-ok
                                 ) .
            end.
         end.
      end.
      OTHERWISE DO:
      end.
   end case.

end. /* do on error */
end procedure. /* 1997 */



/*==========================================================================*/
procedure get-mode-name :
define input  parameter p-cd-mode     as character          no-undo.
define input  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_tt-head-check     for tt-head-check .
define variable v-type    as integer    no-undo.

do
on error undo, return error
:
   find  first tt-cdm
         where tt-cdm.cd-mode = p-cd-mode
         NO-LOCK
         no-error
         .
   if available tt-cdm
   then do:
      case p-cd-mode:
         WHEN {&cd-mode-wth}
         then do:
            find first buf_tt-head-check no-error.
            if available buf_tt-head-check
            then do:
               assign
                  v-type = buf_tt-head-check.chk-type
               .
            end.
            /*
            case v-type:
               WHEN INTEGER({&encashment})
               then do:
                  assign
                     p-message = "Инкассация"
                     p-ok      = TRUE
                  .
               end.
               WHEN INTEGER({&rcpt-inventory})
               then do:
                  assign
                     p-message = "Внесение денег"
                     p-ok      = TRUE
                  .
               end.
               OTHERWISE DO:
               */
                  assign
                     p-message = "Чеки МЦ"
                     p-ok      = TRUE
                  .
                  /*
               end.
            end case.
            */
         end.
         OTHERWISE DO:
            assign
               p-message = tt-cdm.cdm-name
               p-ok      = TRUE
            .
         end.
      end case.
   end.
   else do:
      assign
         p-message = "   "
      .
   end.

end. /* do on error */
end procedure. /* get-mode-name */



/*==========================================================================*/
procedure get-submode-name :
define input  parameter p-cd-mode     as character          no-undo.
define input  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

do
on error undo, return error
:

   find first tt-func-key
        where tt-func-key.cd-mode    = p-cd-mode
         AND  tt-func-key.cd-submode = p-cd-submode
         AND  tt-func-key.key-name   = "v-src-input"
        NO-LOCK
        No-error
        .
   if available tt-func-key
   then do:
      assign
         p-message = tt-func-key.key_label
         p-ok      = TRUE
      .
   end.
   else do:
      assign
         p-message = "   "
      .
   end.

end. /* do on error */
end procedure. /* get-submode-name */



/*==========================================================================*/
procedure get-chk-num :
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
  find tt-head-check no-error.
  if available tt-head-check
  then do:
     assign
         p-message =  STRING( tt-head-check.doc-code )
     .
  end.
  else do:
     assign
         p-ok = TRUE
     no-error.
  end.

end. /* do on error */
end procedure. /* get-chk-num */




/*==========================================================================*/
procedure input-saller :
define input-OUTPUT parameter p-cd-mode     as character          no-undo.
define input-OUTPUT parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_tt-head-check     for tt-head-check .
define buffer buf_tt-line     for tt-line .
define buffer buf_clients     for ub.clients .
define buffer buf_person      for ub.person .

define variable v-num-line    as integer      no-undo.
define variable v-password    as character    no-undo.
define variable v-seller-code as integer      no-undo.
define variable v-psn-seller-code as integer      no-undo.

do
on error undo, return error
:
   if v-curr-type-0 <> 0
   then do:
      assign
         p-message = "Продавца можно установить только на товарную строку"
         p-ok = FALSE
      .
      return.
   end.

   if p-cd-mode = {&cd-mode-sale}
   OR p-cd-mode = {&cd-mode-ret}
   then do:
      find buf_tt-head-check.

      find last  buf_tt-line
           where buf_tt-line.type = 0
             AND buf_tt-line.num  = v-curr-num-0
           no-error
           .

      { gbl/eventlib-event-log.i
         1
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         buf_tt-head-check.chk-type
         '':U
         v-psn-seller-code
         '':U
         buf_tt-head-check.doc-code
         '':U
         TODAY
         39
         TIME
         'U':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }

      assign
         v-seller-code = INTEGER(v-src)
      no-error.
      if error-status:error
      then do:
         assign
            p-message = substitute("Введенный код &1- не число.", v-seller-code)
            p-ok      = FALSE
         .

         { gbl/eventlib-event-log.i
            1
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            buf_tt-head-check.chk-type
            '':U
            p-message
            '':U
            buf_tt-head-check.doc-code
            '':U
            TODAY
            41
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }

         return .
      end.

      assign
         v-num-line = v-curr-num-0
      .

      v-psn-seller-code = gbclcode-is-this-db-role ( input {&role-seller}
                                                   , input v-cntxt-db-num
                                                   , input v-seller-code
                                                   , input TODAY
                                                   ) .

      if v-psn-seller-code = 0
      then do:
         assign
            p-message = substitute("Не найден продавец с кодом &1", v-seller-code )
            p-ok = FALSE
         .
         return.
      end.

      { str/libthpos_set-salesman.i
         buf_tt-head-check.doc-code
         v-num-line
         v-seller-code
         v-psn-seller-code
         p-ok
         no-error
      }


      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .

         { gbl/eventlib-event-log.i
            1
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            buf_tt-head-check.chk-type
            '':U
            p-message
            '':U
            buf_tt-head-check.doc-code
            '':U
            TODAY
            41
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }

         return.
      end.
      find first buf_clients
           where buf_clients.obj-type = {&prs}
             AND buf_clients.obj-code = v-psn-seller-code
           NO-LOCK
           .
      find first buf_person
           where buf_person.psn-code = v-psn-seller-code
           NO-LOCK
           .

      assign
         p-message    = substitute("Продавец &1 &2&3 &4&5"
                        , buf_clients.obj-name
                        , SUBSTRING( buf_person.name1, 1, 1 )
                        , if buf_person.name1 = "":U then "" else ".":U
                        , SUBSTRING( buf_person.name2, 1, 1 )
                        , if buf_person.name2 = "":U then "" else ".":U
                        )
         v-disp-msg-1 = "Продавец"
         v-disp-msg-2 = substitute("&1 &2&3 &4&5"
                        , buf_clients.obj-name
                        , SUBSTRING( buf_person.name1, 1, 1 )
                        , if buf_person.name1 = "":U then "" else ".":U
                        , SUBSTRING( buf_person.name2, 1, 1 )
                        , if buf_person.name2 = "":U then "" else ".":U
                        )
         p-cd-submode = {&cd-submode-goods}
         p-ok = TRUE
      .
      if not v-emul-mode
      then do:
         { gbl/disp-str.i
            v-disp-msg-1
            v-disp-msg-2
            p-message
            p-ok
         }
      end.
      if v-num-line = 0
      then do:
         assign
            buf_tt-head-check.chk-seller-code = v-seller-code
            buf_tt-head-check.chk-seller-name = buf_clients.obj-name
         .
      end.
      else do:
         assign
            buf_tt-head-check.chk-seller-code = v-seller-code
            buf_tt-head-check.chk-seller-name = buf_clients.obj-name
            buf_tt-line.line-seller-code      = v-seller-code
            buf_tt-line.line-seller-name      = buf_clients.obj-name
         .
      end.

      { gbl/eventlib-event-log.i
         1
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         buf_tt-head-check.chk-type
         '':U
         v-disp-msg-2
         '':U
         buf_tt-head-check.doc-code
         '':U
         TODAY
         40
         TIME
         'S':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }


   end.

end. /* do on error */
end procedure. /* input-saller */




/*==========================================================================*/
procedure get-card-num :
define output parameter p-card     as character      no-undo .
define output parameter p-clients     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   assign
      p-card    = v-d-card
      p-clients = v-obj-name
      p-ok      = TRUE
   .
end. /* do on error */
end procedure. /* get-card-num */

/*==========================================================================*/
procedure get-aux-mess :
define output parameter p-aux-mess  as character     no-undo.
define output parameter p-ok as logical no-undo .

do
on error undo, return error
:
   assign
      p-aux-mess    = v-aux-mess
      p-ok      = TRUE
   .
end. /* do on error */
end procedure. /* get-card-num */





/*==========================================================================*/
procedure input-pay-sale :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .
define buffer buf_cash-pay    for ub.cash-pay .

define variable v-pline-num as integer no-undo .
define variable v-mode as character no-undo .
define variable v-pass-pay as integer no-undo .
define variable v-pay-card as character no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-tot-rubl as decimal no-undo .
define variable v-tot-base as decimal no-undo .
define variable v-par-code as integer   no-undo .
define variable v-src-qnty as decimal no-undo .
define variable v-get-qnty-method as character no-undo .
define variable v-2-cdpay-code as integer no-undo .
define variable v-2-curr-code as integer no-undo .
define variable v-2-tot-base as decimal no-undo .
define variable v-2-tot-rubl as decimal no-undo .
define variable v-2-frpay-code as integer no-undo .

define variable v-slip        as character    no-undo.
define variable v-found-pay   as logical      no-undo .
define variable v-summ-pay-2  as decimal      no-undo .
define variable v-summ-pay-curr  as decimal      no-undo .
define variable v-card-lst    as character    no-undo.
define variable v-card-num    as character    no-undo.
define variable v-card-type   as character    no-undo.
define variable v-src-discnt-local    as decimal      no-undo.
define variable v-src-discnt-local-rub    as decimal      no-undo.
define variable v-for-discnt-local-doc    as decimal no-undo .
define variable v-for-discnt-local-rubl   as decimal no-undo .
define variable v-for-discnt-local-r-b    as decimal no-undo .

do
on error undo, return error
:
   find buf_tt-head-check.
   find last buf_tt-line where buf_tt-line.type = 1 no-error.

   assign
      v-pline-num = if available buf_tt-line then buf_tt-line.num + 1 else 1
      v-mode = {&add-def}
      v-pass-pay  = 0
      v-pay-card  = "0"
      v-tot-sum   = if ((p-cd-mode = {&cd-mode-ret}) OR (buf_tt-head-check.chk-type = INTEGER({&encashment}))) then - DECIMAL(v-src) else DECIMAL(v-src) /* !!! валюта*/
      v-tot-rubl  = if ((p-cd-mode = {&cd-mode-ret}) OR (buf_tt-head-check.chk-type = INTEGER({&encashment}))) then - DECIMAL(v-src) else DECIMAL(v-src) /* !!! валюта*/
      v-tot-base  = ?
   .
   if v-with-context
   then do:
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         buf_tt-head-check.chk-type
         '':U
         '*':U
         0
         buf_tt-head-check.doc-code
         '':U
         TODAY
         19
         TIME
         'U':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         v-src
         v-cntxt-userid
         no-error
      }
      if error-status:error
      then do:
         message
            "Z"  19
            skip error-status:get-message(1)
            skip return-value
         view-as alert-box information.
      end.
   end.

   case p-cd-mode:
      WHEN {&cd-mode-sale}
      then do:
         if v-with-context
         then do:
            assign
               v-frpay-code = ?
            .

            { str/libthpos_pay-line.i
               buf_tt-head-check.doc-code
               v-pline-num
               v-mode
               v-pay-type
               v-curr-base-code
               v-par-code
               v-src-qnty
               v-frpay-code
               v-pass-pay
               v-pay-card
               v-tot-sum
               v-tot-rubl
               v-tot-base
               v-get-qnty-method
               v-2-cdpay-code
               v-2-curr-code
               v-2-frpay-code
               v-2-tot-sum
               v-2-tot-rubl
               v-2-tot-base
               v-src-discnt
               v-src-discnt-rub
               v-for-discnt-doc
               v-for-discnt-rubl
               v-for-discnt-r-b
               p-ok
               no-error
            }
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .

               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  p-message
                  0
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  21
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  v-tot-sum
                  v-cntxt-userid
                  no-error
               }
               if error-status:error
               then do:
                  message
                     "Z"  21
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.

               return.
            end.
         end.
         find first buf_cash-pay
               where buf_cash-pay.cdpay-code = v-pay-type
                  AND buf_cash-pay.curr-code  = v-curr-base-code
               NO-LOCK
               no-error
               .
         /*
         if not available buf_cash-pay
         then do:
            assign
               p-message = substitute( "Не найден тип платежа: &1", buf_rule-call-param.param-value-character)
            .
            return.
         end.
         */

         if buf_cash-pay.atr16
         AND not v-emul-mode
         AND v-with-context
         then do:

            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               buf_tt-head-check.chk-type
               '':U
               '*':U
               '':U
               buf_tt-head-check.doc-code
               '':U
               TODAY
               22
               TIME
               'U':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               v-tot-rubl
               v-cntxt-userid
               no-error
            }


            { gbl/sb-sale.i
               v-tot-rubl
               v-slip
               v-pay-card
               p-message
               p-ok
               no-error
            }
            if error-status:error
            OR not p-ok
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  p-message
                  0
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  21
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  v-tot-rubl
                  v-cntxt-userid
                  no-error
               }

               if error-status:error
               then do:
                  message
                     "Z"  21
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.

               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  p-message
                  '':U
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  24
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  v-pay-card
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  v-tot-rubl
                  v-cntxt-userid
                  no-error
               }

            end.
            else do:
               run print-slip in this-procedure (input v-slip, output p-message, output p-ok) .
               run print-head-chk   ( output p-message
                                    , output p-ok
                                    ) .
            end.

            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               buf_tt-head-check.chk-type
               '':U
               '*':U
               '':U
               buf_tt-head-check.doc-code
               '':U
               TODAY
               23
               TIME
               'S':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               v-pay-card
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               v-tot-rubl
               v-cntxt-userid
               no-error
            }

            /* платеж не прошел удаляем оплату */
            if not p-ok
            then do:
               assign
                  v-mode = {&deletion}
               .
               { str/libthpos_pay-line.i
                  buf_tt-head-check.doc-code
                  v-pline-num
                  v-mode
                  v-pay-type
                  v-curr-base-code
                  v-par-code
                  v-src-qnty
                  v-frpay-code
                  v-pass-pay
                  v-pay-card
                  v-null-summ
                  v-null-summ
                  v-tot-base
                  v-get-qnty-method
                  v-2-cdpay-code
                  v-2-curr-code
                  v-2-frpay-code
                  v-2-tot-sum
                  v-2-tot-rubl
                  v-2-tot-base
                  v-src-discnt-local
                  v-src-discnt-local-rub
                  v-for-discnt-local-doc
                  v-for-discnt-local-rubl
                  v-for-discnt-local-r-b
                  p-ok
                  no-error
               }
               if error-status:error
               then do:
                  assign
                     p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                     p-ok = FALSE
                  .
                  return.
               end.
               return.
            end.
            assign
               v-mode = {&update}
            .
            /* прописываем номер карты */
            { str/libthpos_pay-line.i
               buf_tt-head-check.doc-code
               v-pline-num
               v-mode
               v-pay-type
               v-curr-base-code
               v-par-code
               v-src-qnty
               v-frpay-code
               v-pass-pay
               v-pay-card
               v-tot-sum
               v-tot-rubl
               v-tot-base
               v-get-qnty-method
               v-2-cdpay-code
               v-2-curr-code
               v-2-frpay-code
               v-2-tot-sum
               v-2-tot-rubl
               v-2-tot-base
               v-src-discnt-local
               v-src-discnt-local-rub
               v-for-discnt-local-doc
               v-for-discnt-local-rubl
               v-for-discnt-local-r-b
               p-ok
               no-error
            }
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  p-message
                  0
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  21
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  v-tot-sum
                  v-cntxt-userid
                  no-error
               }
               if error-status:error
               then do:
                  message
                     "Z"  21
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
               return.
            end.
         end.  /*if buf_cash-pay.atr16*/
         /*
         find first buf_cash-pay
              where buf_cash-pay.cdpay-code = v-pay-type
                AND buf_cash-pay.curr-code  = v-curr-base-code
              NO-LOCK
              no-error
              .
         */

         CREATE buf_tt-line.
         assign
            buf_tt-line.type         = 1
            buf_tt-line.num          = v-pline-num
            buf_tt-line.line-name    = substitute("    Оплата &1", buf_cash-pay.obj-name  )
            buf_tt-line.line-code    = v-pay-type
            buf_tt-line.curr-code    = v-curr-base-code
            buf_tt-line.fr-pay-code  = v-frpay-code
            buf_tt-line.summ-netto-rub = ABSOLUTE(v-tot-rubl)
            buf_tt-line.summ-netto   = ABSOLUTE(v-tot-base)
            buf_tt-line.pay-card     = v-pay-card
            buf_tt-line.summ-discont = v-src-discnt
            buf_tt-line.summ-discont-rub = v-src-discnt-rub
            /*
            buf_tt-line.price-str    = STRING(v-cash-scales)
            buf_tt-line.qnty-str     = STRING(v-tot-sum)
            */
            buf_tt-line.qnty         = v-tot-sum
            buf_tt-line.src          = STRING(v-pay-type)
            buf_tt-line.summ-brutto  = v-for-discnt-rubl
            buf_tt-line.line-name-2  = v-src
            buf_tt-line.slip         = v-slip
            v-curr-base-code         = v-cd-base-code
            p-ok                     = TRUE
            v-pay-type               = ?
            v-curr-num-0             = v-pline-num
            v-curr-type-0            = 1

         .

         if v-with-context
         then do:
            run set-all-summ ( output p-message
                           , output p-ok
                           ) no-error.
         end.
         if TRUNCATE(v-summ-netto-rub, 2) <= TRUNCATE(v-summ-pay-rub, 2)
         then do:
            assign
               p-cd-submode       = {&cd-submode-goods}
               /*
               v-sum-for-pay      = 0
               */
            .
         end.
         /*
         if v-summ-netto-rub <= v-summ-pay-rub
         then do:
            assign
               p-cd-submode       = {&cd-submode-goods}
               v-disp-msg-1 = substitute  ( "&1 &2 &3"
                                          , buf_cash-pay.obj-name
                                          , if (p-cd-mode = {&cd-mode-ret}) then - v-tot-rubl else v-tot-rubl
                                          , v-cd-base-name
                                          )

               v-disp-msg-2 = "Сдача" + STRING(ABS( v-summ-brutto ) - ABS( v-summ-pay-rub  )) + " " + v-cd-base-name
            .
         end.
         else do:
         end.
         */
         assign
            v-disp-msg-1             = substitute  ( " Оплата &1"
                                                   , buf_cash-pay.obj-name
                                                   )
            v-disp-msg-2             = substitute  ( "&1 &2"
                                                   , if (p-cd-mode = {&cd-mode-ret}) then - v-tot-rubl else v-tot-rubl
                                                   , v-cd-base-name
                                                   )
         .
         assign
            p-message    = substitute  ( "Оплата &1 &2"
                                       , buf_cash-pay.obj-name
                                       , if (p-cd-mode = {&cd-mode-ret}) then - v-tot-rubl else v-tot-rubl
                                       )
         .
      end.
      WHEN {&cd-mode-ret}
      then do:
         if v-with-context
         then do:
            assign
               v-frpay-code = ?
            .
            { str/libthpos_pay-line.i
               buf_tt-head-check.doc-code
               v-pline-num
               v-mode
               v-pay-type
               v-curr-base-code
               v-par-code
               v-src-qnty
               v-frpay-code
               v-pass-pay
               v-pay-card
               v-tot-sum
               v-tot-rubl
               v-tot-base
               v-get-qnty-method
               v-2-cdpay-code
               v-2-curr-code
               v-2-frpay-code
               v-2-tot-sum
               v-2-tot-rubl
               v-2-tot-base
               v-src-discnt
               v-src-discnt-rub
               v-for-discnt-doc
               v-for-discnt-rubl
               v-for-discnt-r-b
               p-ok
               no-error
            }
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  p-message
                  0
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  21
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  v-tot-sum
                  v-cntxt-userid
                  no-error
               }
               if error-status:error
               then do:
                  message
                     "Z"  21
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
               return.
            end.
         end.

         find first buf_cash-pay
              where buf_cash-pay.cdpay-code = v-pay-type
                AND buf_cash-pay.curr-code  = v-curr-base-code
              NO-LOCK
              no-error
              .
         /*
         if not available buf_cash-pay
         then do:
            assign
               p-message = substitute( "Не найден тип платежа: &1", buf_rule-call-param.param-value-character)
            .
            return.
         end.
         */

         run accum-curr-chk-pay in this-procedure ( input  buf_cash-pay.pay-code
                                             , input  v-curr-base-code
                                             , input  v-card-num
                                             , output v-summ-pay-curr
                                             ) .

         run accum-chk-pay in this-procedure ( input  buf_cash-pay.cdpay-code
                                             , input  v-curr-base-code
                                             , input  v-card-num
                                             , output v-found-pay
                                             , output v-summ-pay-2
                                             ) .

         if  v-summ-pay-2 < (ABS(v-tot-rubl) - v-summ-pay-curr)
         AND v-found-pay
         then do:
            message
            "Максимальная сумма, которую вы можете вернуть" skip
            "этим типом платежа, по этому чеку:" SKIP
            v-summ-pay-2 skip
            view-as alert-box information.

            assign
            v-mode = {&deletion}
            .
            { str/libthpos_pay-line.i
               buf_tt-head-check.doc-code
               v-pline-num
               v-mode
               v-pay-type
               v-curr-base-code
               v-par-code
               v-src-qnty
               v-frpay-code
               v-pass-pay
               v-pay-card
               v-null-summ
               v-null-summ
               v-tot-base
               v-get-qnty-method
               v-2-cdpay-code
               v-2-curr-code
               v-2-frpay-code
               v-2-tot-sum
               v-2-tot-rubl
               v-2-tot-base
               v-src-discnt-local
               v-src-discnt-local-rub
               v-for-discnt-local-doc
               v-for-discnt-local-rubl
               v-for-discnt-local-r-b
               p-ok
               no-error
            }
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  p-message
                  0
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  21
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  v-tot-sum
                  v-cntxt-userid
                  no-error
               }
               if error-status:error
               then do:
                  message
                     "Z"  21
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
               return.
            end.
            /*
            if not v-found-pay
            then do:
               message
                  "В этом чеке нет платажей этой картой"
                  skip "Возврат денег на эту карту запрещен"
               view-as alert-box information.
            end.
            else do:
            end.
            */
            return .
         end.


         if buf_cash-pay.atr16
         AND not v-emul-mode
         and v-with-context
         then do:

            { gbl/sb-cardinfo.i
               v-card-num
               v-card-type
               p-message
               p-ok
               no-error
            }

            if error-status:error
            OR not p-ok
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  p-message
                  0
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  21
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  v-tot-sum
                  v-cntxt-userid
                  no-error
               }
               if error-status:error
               then do:
                  message
                     "Z"  21
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
            end.


            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               buf_tt-head-check.chk-type
               '':U
               '*':U
               '':U
               buf_tt-head-check.doc-code
               '':U
               TODAY
               22
               TIME
               'U':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               v-tot-rubl
               v-cntxt-userid
               no-error
            }

            { gbl/sb-ret.i
               v-tot-rubl
               v-pay-card
               v-slip
               p-message
               p-ok
               no-error
            }
            if error-status:error
            OR not p-ok
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  p-message
                  0
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  21
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  v-tot-rubl
                  v-cntxt-userid
                  no-error
               }

               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  p-message
                  '':U
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  24
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  v-pay-card
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  v-tot-rubl
                  v-cntxt-userid
                  no-error
               }

               if error-status:error
               then do:
                  message
                     "Z"  21
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
            end.
            else do:
               run print-slip in this-procedure (input v-slip, output p-message, output p-ok) .
               run print-head-chk   ( output p-message
                                    , output p-ok
                                    ) .
            end.

            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               buf_tt-head-check.chk-type
               '':U
               '*':U
               '':U
               buf_tt-head-check.doc-code
               '':U
               TODAY
               23
               TIME
               'S':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               v-pay-card
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               v-tot-rubl
               v-cntxt-userid
               no-error
            }

            /* платеж не прошел удаляем оплату */
            if not p-ok
            then do:
               assign
                  v-mode = {&deletion}
               .
               { str/libthpos_pay-line.i
                  buf_tt-head-check.doc-code
                  v-pline-num
                  v-mode
                  v-pay-type
                  v-curr-base-code
                  v-par-code
                  v-src-qnty
                  v-frpay-code
                  v-pass-pay
                  v-pay-card
                  v-null-summ
                  v-null-summ
                  v-tot-base
                  v-get-qnty-method
                  v-2-cdpay-code
                  v-2-curr-code
                  v-2-frpay-code
                  v-2-tot-sum
                  v-2-tot-rubl
                  v-2-tot-base
                  v-src-discnt-local
                  v-src-discnt-local-rub
                  v-for-discnt-local-doc
                  v-for-discnt-local-rubl
                  v-for-discnt-local-r-b
                  p-ok
                  no-error
               }
               if error-status:error
               then do:
                  assign
                     p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                     p-ok = FALSE
                  .
                  return.
               end.
               return.
            end.
            assign
               v-mode = {&update}
            .
            /* прописываем номер карты */
            { str/libthpos_pay-line.i
               buf_tt-head-check.doc-code
               v-pline-num
               v-mode
               v-pay-type
               v-curr-base-code
               v-par-code
               v-src-qnty
               v-frpay-code
               v-pass-pay
               v-pay-card
               v-tot-sum
               v-tot-rubl
               v-tot-base
               v-get-qnty-method
               v-2-cdpay-code
               v-2-curr-code
               v-2-frpay-code
               v-2-tot-sum
               v-2-tot-rubl
               v-2-tot-base
               v-src-discnt-local
               v-src-discnt-local-rub
               v-for-discnt-local-doc
               v-for-discnt-local-rubl
               v-for-discnt-local-r-b
               p-ok
               no-error
            }
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  p-message
                  0
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  21
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  v-tot-sum
                  v-cntxt-userid
                  no-error
               }
            if error-status:error
            then do:
               message
                  "Z"  21
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.
               return.
            end.
         end. /*if buf_cash-pay.atr16*/

         CREATE buf_tt-line.
         assign
            buf_tt-line.type        = 1
            buf_tt-line.num         = v-pline-num
            buf_tt-line.line-name   = substitute("    Оплата &1", buf_cash-pay.obj-name  )
            buf_tt-line.line-code   = v-pay-type
            buf_tt-line.curr-code   = v-curr-base-code
            buf_tt-line.fr-pay-code = v-frpay-code
            buf_tt-line.summ-netto-rub = ABSOLUTE(v-tot-rubl)
            buf_tt-line.summ-netto   = ABSOLUTE(v-tot-base)
            buf_tt-line.pay-card    = v-pay-card
            /*
            buf_tt-line.price-str    = STRING(v-cash-scales)
            buf_tt-line.qnty-str     = STRING(v-tot-sum)
            */
            buf_tt-line.qnty         = v-tot-sum
            buf_tt-line.summ-discont = v-src-discnt
            buf_tt-line.summ-discont-rub = v-src-discnt-rub
            buf_tt-line.src          = STRING(v-pay-type)
            buf_tt-line.summ-brutto  = ABSOLUTE(v-for-discnt-rubl)
            buf_tt-line.line-name-2  = v-src
            buf_tt-line.slip        = v-slip
            v-curr-base-code        = v-cd-base-code
            p-ok                    = TRUE
            v-pay-type              = ?
            v-curr-num-0            = v-pline-num
            v-curr-type-0           = 1
         .
         if v-with-context
         then do:
            run set-all-summ ( output p-message
                           , output p-ok
                           ) no-error.
         end.

         if v-summ-netto-rub <= v-summ-pay-rub
         then do:
            assign
               p-cd-submode       = {&cd-submode-goods}
               /*
               v-sum-for-pay      = 0
               */
            .
         end.
         assign
            p-message    = substitute("Оплата &1 &2"
                                    , buf_cash-pay.obj-name
                                    , if (p-cd-mode = {&cd-mode-ret}) then - v-tot-rubl else v-tot-rubl
                                    )
            v-disp-msg-1             = substitute(" Оплата &1"
                                                  , buf_cash-pay.obj-name
                                                  )
            v-disp-msg-2             = substitute  ( "&1 &2"
                                                   , if (p-cd-mode = {&cd-mode-ret}) then - v-tot-rubl else v-tot-rubl
                                                   , v-cd-base-name
                                                   )
         .
      end.
      WHEN {&cd-mode-wth}
      then do:
         if v-with-context
         then do:
            if buf_tt-head-check.chk-type = integer({&encashment})
            and not v-emul-mode then do:
              define variable v-reg-value    as character    no-undo.
              define variable v-reg-name     as character    no-undo.
              /*проверим сумму*/
              { gbl/fr-get-reg.i
                'cash':U
                241
                v-reg-value
                v-reg-name
                p-message
                p-ok
                no-error
              }
              if error-status:error
              then do:
                assign
                p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                p-ok = FALSE
                .
                return.
              end.
              else do:
                assign
                v-summ-fr = DECIMAL(v-reg-value)
                .
              end.
              if  abs(v-tot-sum) > v-summ-fr
              then do:
                assign
                p-message = substitute("Суммы в ДЯ &1 недостаточно для инкассации", v-summ-fr)
                p-ok = no
                .
                return.
              end.
            end. /*if buf_tt-head-check.chk-type = integer({&encashment})*/

            { str/libthpos_inst-line.i
               buf_tt-head-check.doc-code
               1
               {&add-def}
               v-pay-type
               v-curr-base-code
               v-par-code
               v-src-qnty
               v-frpay-code
               v-pass-pay
               v-pay-card
               v-tot-sum
               v-tot-rubl
               v-tot-base
               v-get-qnty-method
               p-ok
               no-error
            }
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  p-message
                  0
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  21
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  v-tot-sum
                  v-cntxt-userid
                  no-error
               }
               if error-status:error
               then do:
                  message
                     "Z"  21
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.
               return.
            end.
         end.

         find first buf_cash-pay
              where buf_cash-pay.cdpay-code = v-pay-type
                AND buf_cash-pay.curr-code  = v-curr-base-code
              NO-LOCK
              no-error
              .

         CREATE buf_tt-line.
         assign
            v-disp-msg-1            = if buf_tt-head-check.chk-type = INTEGER({&encashment}) then "Инкассация" else "Внесение денег"
            v-disp-msg-2            = substitute("&1 &2"
                                     , buf_cash-pay.obj-name
                                     , if (buf_tt-head-check.chk-type = INTEGER({&encashment})) then - v-tot-rubl else v-tot-rubl
                                     )
            buf_tt-line.type         = 1
            buf_tt-line.num          = v-pline-num
            buf_tt-line.line-name    = substitute("Оплата &1", buf_cash-pay.obj-name  )
            buf_tt-line.line-code    = v-pay-type
            buf_tt-line.curr-code    = v-curr-base-code
            buf_tt-line.pay-card     = v-pay-card
            buf_tt-line.fr-pay-code  = v-frpay-code
            /*
            buf_tt-line.price-str    = STRING(v-cash-scales)
            buf_tt-line.qnty-str     = STRING(v-tot-sum)
            */
            buf_tt-line.qnty         = v-tot-sum
            buf_tt-line.summ-netto-rub = ABSOLUTE(v-tot-rubl)
            buf_tt-line.summ-netto   = ABSOLUTE(v-tot-base)
            /*
            buf_tt-line.price-str    = STRING(v-cash-scales)
            */
            buf_tt-line.summ-brutto  = v-for-discnt-rubl
            buf_tt-line.line-name-2  = v-src
            buf_tt-line.src          = STRING(v-pay-type)
            v-curr-base-code         = v-cd-base-code
            p-ok                     = TRUE
            v-pay-type               = ?
            v-curr-num-0             = v-pline-num
            v-curr-type-0            = 1
         .
      end.
      OTHERWISE DO:
      end.
   end case.

   if v-with-context
   then do:
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         buf_tt-head-check.chk-type
         '':U
         '*':U
         0
         buf_tt-head-check.doc-code
         '':U
         TODAY
         20
         TIME
         'S':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         v-pay-card
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         buf_tt-line.summ-netto
         v-cntxt-userid
         no-error
      }
      if error-status:error
      then do:
         message
            "Z"  20
            skip error-status:get-message(1)
            skip return-value
         view-as alert-box information.
      end.
   end.
   if not v-emul-mode
   and    v-with-context
   then do:
      { gbl/disp-str.i
         v-disp-msg-1
         v-disp-msg-2
         p-message
         p-ok
      }
   end.
   else do:
      assign
         p-ok = TRUE
      .
   end.
   assign
      v-src        = ""
      v-src-qnty   = 0.0
      v-src-price  = 0.0
      v-src-price-rub  = 0.0
      p-message = v-disp-msg-1 + " ":U + v-disp-msg-2
   .
end. /* do on error */
end PROCEDURE. /* input-pay-sale */




/*==========================================================================*/
procedure pr-esc :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

do
on error undo, return error
:

   define buffer bf_tt-head-check     for tt-head-check .
   find first bf_tt-head-check no-error.
   define variable vv-chk-type    as integer    no-undo.
   define variable vv-doc-code    as character    no-undo.
   if available bf_tt-head-check
   then do:
      assign
         vv-chk-type = bf_tt-head-check.chk-type
         vv-doc-code = bf_tt-head-check.doc-code
      .
      RELEASE bf_tt-head-check.
   end.

   { gbl/eventlib-event-log.i
      2
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      vv-chk-type
      '':U
      '*':U
      0
      vv-doc-code
      '':U
      TODAY
      8
      TIME
      'S':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      0
      v-cntxt-userid
      no-error
   }
            if error-status:error
            then do:
               message
                  "Z"  8
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.


   /* режим готовности - выход из программы */
   assign
      v-disc-type = "":U /* {&discnt-v-pcnt} */
      p-message   = {&new-line}
   .
   if p-cd-mode = {&cd-mode-ready}
   then do:
      /* из режима готовности - выход*/
      { gbl/eventlib-event-log.i
         2
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         vv-chk-type
         '':U
         '*':U
         0
         vv-doc-code
         '':U
         TODAY
         9
         TIME
         'S':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }
            if error-status:error
            then do:
               message
                  "Z"  9
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.
      run pr-empty in this-procedure (output p-message, output p-ok) .
   end.
   else do:
      /* из подрежима в основной режим */
      if p-cd-submode <> {&cd-submode-goods}
      AND p-cd-mode <> {&cd-mode-wth}
      then do:
         assign
            v-src = ""
            p-cd-submode = {&cd-submode-goods}
            p-ok         = TRUE
         .
      end.
      else do:
         /* из основного режима ... */
         /* ... чек открыт, никуда не выходим*/
         if p-cd-mode  = {&cd-mode-sale}
         OR p-cd-mode  = {&cd-mode-ret}
         OR p-cd-mode  = {&cd-mode-inv}
         OR (p-cd-mode = {&cd-mode-wth} AND CAN-find(tt-head-check))
         then do:
            assign
               &scop receipt-code string(vv-chk-type)
               p-message = (if p-cd-mode = {&cd-mode-wth}
                            then substitute("Закройте или аннулируйте открытый чек (&1)", {&receipt-name})
                            else "Закройте, отложите или аннулируйте открытый чек."
                            )
               p-ok      = FALSE
            .


            { gbl/eventlib-event-log.i
               2
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               vv-chk-type
               '':U
               p-message
               0
               vv-doc-code
               '':U
               TODAY
               10
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            if error-status:error
            then do:
               message
                  "Z"  10
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.


         end.
         /* ... в режим готовности */
         else do:
            assign
               v-src        = ""
               p-cd-mode    = {&cd-mode-ready}
               p-cd-submode = {&cd-submode-goods}
               p-ok         = TRUE
            .
         end.
      end.
      if p-ok
      then do:

         { gbl/eventlib-event-log.i
            2
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            vv-chk-type
            '':U
            '*':U
            0
            vv-doc-code
            '':U
            TODAY
            9
            TIME
            'S':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
            if error-status:error
            then do:
               message
                  "Z"  9
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.

      end.
   end.
end. /* do on error */
end procedure. /* pr-esc */




/*==========================================================================*/
procedure 1985 : /* Выбор отложенного чека */
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_chk-doc     for ub.chk-doc .
define buffer buf_chk-gds     for ub.chk-gds .
define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .

define variable v-doc-code    as character    no-undo.
define variable v-doc-code-list    as character    no-undo.
define variable v-chk-type    as integer      no-undo.

define variable v-b-code as integer no-undo .
define variable v-chk-name as character no-undo .
define variable v-second-name as character no-undo .
define variable v-setted as logical no-undo .
define variable v-gds-code as integer no-undo .
define variable v-src-sum as decimal no-undo .
define variable v-src-sum-netto as decimal no-undo .
define variable v-rid-list    as character    no-undo.
define variable v-count    as integer      no-undo.

define buffer buf_tt-open-check     for tt-open-check .
define variable v-chk-list-type    as logical      no-undo.

do
on error undo, return error
:

   /*
   assign
      v-cd-mode    = p-cd-mode
      v-cd-submode = p-cd-submode
   .
   run clear-tt-chk in this-procedure .
   */

   case p-cd-mode:
      WHEN {&cd-mode-sale}
      then do:
         run str/chk-docs.w   ( input parparentproc
                              , input "b-sel,b-mark"
                              , input {&cd-type-ibs-th}
                              , input ?
                              , input v-cntxt-obj-type
                              , input v-cntxt-obj-code
                              , input '':U
                              , input '':U
                              , input p-cash-num
                              , input ?
                              , input ?
                              , input integer({&rcpt-ord-sale})
                              , output v-rid-list) no-error.
         assign
            v-chk-type = integer({&rcpt-ord-sale})
         .
      end.
      WHEN {&cd-mode-ret}
      then do:
         run str/chk-docs.w   ( input parparentproc
                              , input "b-sel,b-mark"
                              , input {&cd-type-ibs-th}
                              , input ?
                              , input v-cntxt-obj-type
                              , input v-cntxt-obj-code
                              , input '':U
                              , input '':U
                              , input p-cash-num
                              , input ?
                              , input ?
                              , input integer({&rcpt-ord-return})
                              , output v-rid-list) no-error.
         assign
            v-chk-type = integer({&rcpt-ord-return})
         .
      end.
      WHEN {&cd-mode-ready}
      then do:
         assign
            v-chk-list-type = ?
         .
         message
            "Открыть отложенный чек?"
            SKIP "ДА  - открыть отложенную продажу"
            skip "НЕТ - открыть отложенный возврат"
            SKIP "ОТМЕНА - отказ от выбора"
         view-as alert-box question
         BUTTONS YES-NO-CANCEL
         UPDATE v-chk-list-type
         .
         if v-chk-list-type = ?
         then do:
            assign
               p-message = "Отказ от выбора отложенного чека"
               p-ok = TRUE
            .
            return.
         end.

         if v-chk-list-type
         then do:
            run str/chk-docs.w   ( input parparentproc
                                 , input "b-sel,b-mark"
                                 , input {&cd-type-ibs-th}
                                 , input ?
                                 , input v-cntxt-obj-type
                                 , input v-cntxt-obj-code
                                 , input '':U
                                 , input '':U
                                 , input p-cash-num
                                 , input ?
                                 , input ?
                                 , input integer({&rcpt-ord-sale})
                                 , output v-rid-list) no-error.
            assign
               v-chk-type = integer({&rcpt-ord-sale})
            .
            end.
         else do:
            run str/chk-docs.w   ( input parparentproc
                                 , input "b-sel,b-mark"
                                 , input {&cd-type-ibs-th}
                                 , input ?
                                 , input v-cntxt-obj-type
                                 , input v-cntxt-obj-code
                                 , input '':U
                                 , input '':U
                                 , input p-cash-num
                                 , input ?
                                 , input ?
                                 , input integer({&rcpt-ord-return})
                                 , output v-rid-list) no-error.
            assign
               v-chk-type = integer({&rcpt-ord-return})
            .
         end.
      end.

      OTHERWISE DO:
      end.
   end case.

   if v-rid-list = "":U
   then do:
      return.
   end.

   run set-input-time in this-procedure ( input 0, output p-message, output p-ok ).

   /* проверить уже,что чеки уже открывались
   if CAN-find( first buf_tt-open-check )
   AND not v-chk-list-type
   then do:
      assign
         p-message = "В этот чек возврата уже заргужен отложенный чек или чек продажи"
         p-ok      = TRUE
      .
      return.
   end.
   */

   if p-cd-mode = {&cd-mode-ready}
   then do:
      if v-chk-list-type
      then do:
         run chk-sale-open in this-procedure ( INPUt-OUTPUT p-cd-mode
                                             , input-output p-cd-submode
                                             , output p-message
                                             , output p-ok
                                             ) .
      end.
      else do:
         run 1987 in this-procedure ( INPUt-OUTPUT p-cd-mode
                                    , input-output p-cd-submode
                                    , output p-message
                                    , output p-ok
                                    ) .
      end.
   end.

   _proc-body:
   DO v-count = 1 to NUM-ENTRIES(v-rid-list)
   on error undo, NEXT
   :
      find first buf_chk-doc
         where RECID(buf_chk-doc) = INTEGER(ENTRY(v-count, v-rid-list))
         share-lock
         no-error
         NO-WAIT
         .

      if  not available buf_chk-doc
      and not locked buf_chk-doc
      then do:
         /*
         assign
            p-message = "Нет чека для открытия"
            p-ok = FALSE
         .
         */
         UNDO _proc-body, NEXT _proc-body .
      end.
      if locked buf_chk-doc
      then do:
         /*
         assign
            p-message = "Чек недоступен для открытия (чек занят)"
            p-ok = FALSE
         .
         */
         UNDO _proc-body, NEXT _proc-body .
      end.

      if  buf_chk-doc.chk-type <> integer({&rcpt-ord-sale})
      AND buf_chk-doc.chk-type <> integer({&rcpt-ord-return})
      then do:
         /*
         assign
            p-message = substitute("Для возврата из отложенных исходный чек &1 должен иметь тип &2 или &3, а не &4"
                                             , v-doc-code
                                             , integer({&rcpt-ord-sale})
                                             , integer({&rcpt-ord-return})
                                             , buf_chk-doc.chk-type
                                             )
            p-ok = FALSE
         .
         */
         UNDO _proc-body, NEXT _proc-body .
      end.

      if  buf_chk-doc.src-d-card <> ?
      AND buf_chk-doc.src-d-card <> ''
      then do:
         assign
            v-src = buf_chk-doc.src-d-card
         .
         run input-card in this-procedure ( INPUt-OUTPUT p-cd-mode
                                          , INPUt-output p-cd-submode
                                          , output p-message
                                          , output p-ok
                                          ) .
         if not p-ok then do:
            UNDO _proc-body, LEAVE _proc-body .
         end.
      end.

      assign
         v-pass-gds = 0 /* integer({&gds-pass-copy}) */
         v-doc-code-list = v-doc-code-list + "," + buf_chk-doc.doc-code
      .

      for each buf_chk-gds
         where buf_chk-gds.doc-code = buf_chk-doc.doc-code
         no-lock
      :
         find first buf_tt-line
              where buf_tt-line.ord-chk-num  = buf_chk-gds.doc-code
                AND buf_tt-line.ord-line-num = buf_chk-gds.line-num
              no-lock no-error.
         if available buf_tt-line then NEXT.

         case buf_chk-doc.chk-type:
            when integer({&rcpt-return}) then do:
            assign
            v-write-off-code = 0
            .
            end.
            /*todo*/
         end case.

         assign
            v-src-price    = buf_chk-gds.src-price         /* !!! */
            /*
            v-src-discnt   = buf_chk-gds.src-discnt
            */
            v-src-qnty     = buf_chk-gds.src-qnty
            v-num          = 0
            v-src          = buf_chk-gds.src-code
            v-pump         = buf_chk-gds.pump
            v-nozzle-code  = buf_chk-gds.nozzle-code
            v-pl-code      = buf_chk-gds.pl-code
            v-fbr-depart   = buf_chk-gds.depart-id
            v-ord-chk-num  = buf_chk-gds.doc-code
            v-ord-line-num = buf_chk-gds.line-num
         .
         run add-gds-line in this-procedure  ( INPUt-OUTPUT p-cd-mode
                                             , INPUt-output p-cd-submode
                                             , output p-message
                                             , output p-ok
                                             ) .
         if not p-ok then do:
            UNDO _proc-body, LEAVE _proc-body .
         end.

         if buf_chk-gds.sales-man > 0
         then do:
            find first buf_tt-line
               where buf_tt-line.ord-chk-num  = buf_chk-gds.doc-code
                  AND buf_tt-line.ord-line-num = buf_chk-gds.line-num
               no-lock
               .
            assign
               v-src = STRING(buf_chk-gds.sales-man)
            .
            run input-saller in this-procedure (input-output p-cd-mode, input-output p-cd-submode, output p-message, output p-ok).
         end.
      end.
      if not CAN-find (first buf_tt-open-check
                       where buf_tt-open-check.doc-code = buf_chk-doc.doc-code
                         AND buf_tt-open-check.chk-type = buf_chk-doc.chk-type
                       )
      then do:
         create buf_tt-open-check.
         assign
            buf_tt-open-check.doc-code = buf_chk-doc.doc-code
            buf_tt-open-check.chk-type = buf_chk-doc.chk-type
         .
      end.
   end. /* _proc-body */
   assign
      v-doc-code-list = TRIM( v-doc-code-list , "," )
   .
   { gbl/eventlib-event-log.i
      1
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      v-chk-type
      '':U
      '*':U
      '':U
      v-doc-code-list
      '':U
      TODAY
      60
      TIME
      'U':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      v-rid-list
      v-cntxt-userid
      no-error
   }


   /*
   if p-ok
   then do:
      find first buf_tt-line no-lock no-error.
      if available buf_tt-line
      then do:
         assign
            v-curr-num-0             = buf_tt-line.num
            v-curr-type-0            = buf_tt-line.type
         .
      end.
      case v-chk-type:
         WHEN {&rcpt-sale}
         then do:
            create buf_tt-open-check.
            assign
               buf_tt-open-check.doc-code = buf_chk-doc.doc-code
               buf_tt-open-check.chk-type = buf_chk-doc.chk-type
               p-cd-mode    = {&cd-mode-sale}
               p-cd-submode = {&cd-submode-goods}
            .
         end.
         WHEN {&rcpt-return}
         then do:
            create buf_tt-open-check.
            assign
               buf_tt-open-check.doc-code = buf_chk-doc.doc-code
               buf_tt-open-check.chk-type = buf_chk-doc.chk-type
               p-cd-mode    = {&cd-mode-ret}
               p-cd-submode = {&cd-submode-goods}
            .
         end.
         OTHERWISE DO:
         end.
      end case.
   end.
   else do:
      assign
         p-cd-mode    = v-cd-mode
         p-cd-submode = v-cd-submode
      .

      run clear-tt-chk in this-procedure .
   end.
   */
end. /* do on error */


end procedure. /* 1985 */




/*==========================================================================*/
procedure 1994 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   assign
      /*
      v-src = v-found-str
      */
      p-message = "Поиск товара по чеку"
      p-cd-submode = {&cd-submode-find-gds}
      p-ok              = TRUE
   .

end. /* do on error */
end procedure. /* 1994 */



/*==========================================================================*/
procedure 1981 :  /* скидка на чек */
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_tt-line     for tt-line .

do
on error undo, return error
:
   /*case p-cd-submode:*/
     /* WHEN {&cd-submode-goods}*/
     if p-cd-submode = {&cd-submode-goods}
      then do:
      run adm/chk-pass.w   ( input parparentproc
                              , input v-cntxt-userid
                              , input v-cntxt-db-num
                              , input "actn_ibsthpos-discont"
                              , input FALSE
                              , output p-message
                              , output p-ok
                              ) .
         if CAN-find (first buf_tt-line where buf_tt-line.type = 1 NO-LOCK)
         then do:
            assign
               p-message = "Скидка должна быть задана до принятия платежей"
               p-ok      = FALSE
            .
         end.
         if not p-ok
         then return.

         assign
            p-message   = "Cкидка на итог"
            p-cd-submode = {&cd-submode-tot-dsc}
            p-ok = TRUE
         .
      end.
/*      WHEN {&cd-submode-line-dsc} OR*/
/*      WHEN {&cd-submode-tot-dsc}*/
     if p-cd-submode =  {&cd-submode-tot-dsc}
      then do:
         define buffer buf_rule-call-param   for ub.rule-call-param .
         define buffer buf_cash-pay          for ub.cash-pay .

         define variable v-type    as logical      no-undo.
         define variable v-value    as logical      no-undo.

         for each  buf_rule-call-param
               where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
               no-lock
            :
            case buf_rule-call-param.param-name:
               WHEN "p-discnt-v-type"
               then do:
                  if  buf_rule-call-param.param-value-integer <> 0
                  AND buf_rule-call-param.param-value-integer <> ?
                  then
                  assign
                     v-disc-type       = STRING(buf_rule-call-param.param-value-integer)
                     v-type            = TRUE
                  .
               end.
               WHEN "p-discnt-value"
               then do:
                  if  buf_rule-call-param.param-value-decimal <> 0
                  AND buf_rule-call-param.param-value-decimal <> ?
                  then
                  assign
                     v-src = STRING(buf_rule-call-param.param-value-decimal)
                     v-value = TRUE
                  .
               end.
               OTHERWISE DO:
               end.
            end case.
         end.

         if v-type
         then do:
            if v-value
            then do:
               run input-discont ( INPUt-OUTPUT p-cd-mode
                                 , INPUt-output p-cd-submode
                                 , output p-message
                                 , output p-ok
                                 ) .
            end.
            else do:
               case v-disc-type:
                  WHEN {&discnt-v-sum}
                  then do:
                     assign
                        p-message = "Абсолютная скидка на итог чека"
                        p-ok      = TRUE
                     .
                  end.
                  WHEN {&discnt-v-pcnt}
                  then do:
                     assign
                        p-message = "Процентная скидка на итог чека"
                        p-ok      = TRUE
                     .
                  end.
                  OTHERWISE DO:
                     assign
                        p-message = substitute("Неизвестный тип скидки - &1",v-disc-type)
                     .
                  end.
               end case.
            end.
         end.
         else do:
            assign
               p-message = "Укажите тип скидки на итог чека"
            .
            return.
         end.
      end.
/*      OTHERWISE DO:*/
/*      end.*/
/*   end case.*/
end. /* do on error */
end procedure. /* 1981 */



/*==========================================================================*/
procedure upd-line :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .

define variable v-b-code          as integer no-undo .
define variable v-gds-code        as integer no-undo .
define variable v-chk-name        as character no-undo .
define variable v-second-name     as character no-undo .
define variable v-src-sum         as decimal no-undo .
define variable v-src-sum-netto   as decimal no-undo .
define variable v-next    as character    no-undo.
define variable v-qnty-old    as decimal      no-undo.
define variable v-src-discnt-local    as decimal      no-undo.
define variable v-src-discnt-local-rub    as decimal      no-undo.
define variable v-for-discnt-local-doc    as decimal no-undo .
define variable v-for-discnt-local-rubl   as decimal no-undo .
define variable v-for-discnt-local-r-b    as decimal no-undo .

do
on error undo, return error
:
   if v-curr-num-0 <> 0
   AND (p-cd-mode = {&cd-mode-sale}
   OR   p-cd-mode = {&cd-mode-ret})
   then do:
      find buf_tt-head-check.
      find first buf_tt-line
         where buf_tt-line.num  = v-curr-num-0
           and buf_tt-line.type = v-curr-type-0
         no-lock
         .
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         buf_tt-head-check.chk-type
         '':U
         '*':U
         0
         buf_tt-head-check.doc-code
         v-src
         TODAY
         16
         TIME
         'U':U
         buf_tt-line.line-code
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         v-src
         0
         v-cntxt-userid
         no-error
      }
            if error-status:error
            then do:
               message
                  "Z"  16
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.

      assign
         v-src-qnty = DECIMAL( v-src )
      no-error.
      if error-status:error
      then do:
         assign
            p-message = substitute( "Вы ввели не число: &1 Введите количество правильно.", v-src )
            p-ok = FALSE
         .

         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            buf_tt-head-check.chk-type
            '':U
            p-message
            0
            buf_tt-head-check.doc-code
            v-src
            TODAY
            18
            TIME
            'S':U
            buf_tt-line.line-code
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            v-src
            0
            v-cntxt-userid
            no-error
         }
            if error-status:error
            then do:
               message
                  "Z"  18
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.

         return.
      end.
      if v-src-qnty <= 0
      then do:
         assign
            v-src-qnty = 0
            p-message = "Количество должно быть больше нуля."
            p-ok = FALSE
         .
         return.
      end.

      if p-cd-mode = {&cd-mode-ret}
      then do:
         define variable v-curr-qnty   as decimal      no-undo .
         define variable v-old-qnty    as decimal      no-undo .
         define variable v-found       as logical      no-undo .

         run accum-chk-gds ( input  buf_tt-line.src
                           , output v-found
                           , output v-old-qnty
                           ) .

         run accum-curr-chk-gds  ( input  buf_tt-line.src
                                 , output v-curr-qnty
                                 ) .

         if ( ( v-curr-qnty + v-src-qnty - buf_tt-line.qnty) > v-old-qnty )
         AND v-found
         then do:
            assign
               p-message = substitute( "По данному чеку продажи можно вернуть только &1 товара с кодом &2"
                                    , v-old-qnty
                                    , buf_tt-line.src
                                    )
               p-ok = FALSE
            .
            return.
         end.
      end.


      assign
         v-qnty-old = buf_tt-line.qnty
      .
      if p-cd-mode = {&cd-mode-ret}
      then do:
         assign
            v-src-qnty = - ABS( v-src-qnty )
         no-error.
      end.
      else do:
         assign
            v-src-qnty = ABS( v-src-qnty )
         no-error.
      end.


      case buf_tt-line.type:
         WHEN 0 then do:
            if buf_tt-line.printed = TRUE
            then do:
               assign
                  p-message   = "Отправленную на ФР строку изменять нельзя."
                  p-ok        = FALSE
               .
               return.
            end.
            assign
               v-pump            = 0
               v-nozzle-code     = 0
               v-pl-code         = 0
               v-pass-gds        = 0
               v-fbr-depart      = 0
               v-src-price       = if p-cd-submode = {&cd-submode-price}
                                   AND not v-recalc
                                   then v-src-price
                                   else buf_tt-line.price-rub
               v-write-off-code  = 0
               v-src             = buf_tt-line.src
            .
            { str/libthpos_gds-line.i
               buf_tt-head-check.doc-code
               v-curr-num-0
               {&update}
               0
               v-src
               v-src-qnty
               v-pump
               v-nozzle-code
               v-pl-code
               v-pass-gds
               v-write-off-code
               v-fbr-depart
               p-ok
               v-next
               v-b-code
               v-gds-code
               v-chk-name
               v-second-name
               v-src-price
               v-src-price-rub
               v-src-discnt
               v-src-discnt-rub
               v-src-sum
               v-src-sum-rub
               v-src-sum-netto
               v-src-sum-netto-rub
               v-unit-base
            no-error
            }
            /* 12345 */
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
                  v-src-qnty = 0
               .

               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  p-message
                  0
                  buf_tt-head-check.doc-code
                  v-src-qnty
                  TODAY
                  18
                  TIME
                  'S':U
                  buf_tt-line.line-code
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  v-src
                  0
                  v-cntxt-userid
                  no-error
               }
               if error-status:error
               then do:
                  message
                     "Z"  18
                     skip error-status:get-message(1)
                     skip return-value
                  view-as alert-box information.
               end.

               return.
            end.
            assign
               v-disp-msg-1 = buf_tt-line.line-name
               v-disp-msg-2 = substitute  ( "&1 x &2 &3"
                                          , if p-cd-mode = {&cd-mode-ret} then - v-src-qnty else v-src-qnty
                                          , v-src-price
                                          , v-cd-base-name
                                          )

               {&g-buf_tt_line_update}
/*               buf_tt-line.qnty         = ABS(v-src-qnty)*/
/*               buf_tt-line.qnty-str     = STRING(ABS(v-src-qnty), "->,>>9.999":U)*/
/*               buf_tt-line.price        = ABS(v-src-price)*/
/*               buf_tt-line.price-str    = STRING(ABS(v-src-price), "->>,>>9.99":U)*/
/*               buf_tt-line.summ-netto   = ABS(v-src-sum-netto)*/
/*               buf_tt-line.summ-brutto  = ABS(v-src-sum)*/
/*               buf_tt-line.summ-discont     = ABS(v-src-discnt)*/
               /*p-message    = substitute("Изменено количество с &1 на &2", v-qnty-old, v-src-qnty)*/
            .
            if not v-emul-mode
            then do:
               { gbl/disp-str.i
                  v-disp-msg-1
                  v-disp-msg-2
                  p-message
                  p-ok
               }
            end.

            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               buf_tt-head-check.chk-type
               '':U
               p-message
               0
               buf_tt-head-check.doc-code
               v-src-qnty
               TODAY
               17
               TIME
               'S':U
               buf_tt-line.line-code
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               v-src
               v-src-sum-netto
               v-cntxt-userid
               no-error
            }
            if error-status:error
            then do:
               message
                  "Z"  17
                  skip error-status:get-message(1)
                  skip return-value
               view-as alert-box information.
            end.
            define variable v-num-str    as integer      no-undo.
            define variable v-gds-yes    as integer      no-undo.
            define variable v-pay-yes    as integer      no-undo.
            define variable v-msg    as character    no-undo.
            define variable v-num-local   as integer      no-undo.
            define variable v-type-local  as integer      no-undo.
            if  INDEX(v-next, "=") > 0
            AND not v-recalc
            then do:
               assign
                  v-msg     = p-message
                  v-recalc  = TRUE
                  v-next    = TRIM(v-next, "recalc=")
                  v-num-str = INTEGER(ENTRY(1, v-next, ","))
                  v-gds-yes = INTEGER(ENTRY(2, v-next, ","))
                  v-pay-yes = INTEGER(ENTRY(3, v-next, ","))
                  v-num-local  = v-curr-num-0
                  v-type-local = v-curr-type-0
               .
               run recalc-lines in this-procedure
                              ( input v-num-str
                              , input v-gds-yes
                              , input v-pay-yes
                              , input-output p-cd-mode
                              , INPUt-output p-cd-submode
                              , output p-message
                              , output p-ok
                              ) .
               assign
                  v-recalc  = FALSE
                  p-message    = v-msg
                  v-curr-num-0     = v-num-local
                  v-curr-type-0    = v-type-local
               .
            end.
            assign
               v-src            = ""
               v-src-qnty       = 0.0
               v-src-price      = 0.0
               v-src-price-rub  = 0.0
            .
            assign
            p-message  = {&g-p-message-gds_set}
            v-src-price = if v-recalc then ? else v-src-price
/*                               = substitute  ( "&1 &2x&3"*/
/*                                                      , substring(buf_tt-line.line-name + fill(' ':U,{&g-ed-msgs}),*/
/*                                                                  1, {&g-ed-msgs} - length(trim(string(buf_tt-line.qnty,"->>>,>>>,>>9.<<<")) + 'X' + trim(string(buf_tt-line.price,"->>>,>>>,>>9.99")))  )*/
/*                                                      , trim(string(buf_tt-line.qnty,"->>>,>>>,>>9.<<<"))*/
/*                                                      , trim(string(buf_tt-line.price,"->>>,>>>,>>9.99"))*/
/*                                                      )*/
            .
         end.
         WHEN 1 then do:
            if v-recalc
            then do:
               define buffer buf_cash-pay    for ub.cash-pay .

               define variable v-mode as character no-undo .
               define variable v-pass-pay as integer no-undo .
               define variable v-pay-card as character no-undo .
               define variable v-tot-sum as decimal no-undo .
               define variable v-tot-rubl as decimal no-undo .
               define variable v-tot-base as decimal no-undo .
               define variable v-par-code as integer  no-undo .
               define variable v-get-qnty-method as character no-undo .
               define variable v-2-cdpay-code as integer no-undo .
               define variable v-2-curr-code as integer no-undo .
               define variable v-2-tot-base as decimal no-undo .
               define variable v-2-tot-rubl as decimal no-undo .
               define variable v-2-frpay-code as integer no-undo .
               assign
                  v-mode      = {&update}
                  v-pass-pay  = 0
                  v-pay-card  = ""
                  v-tot-sum   = 0
                  v-tot-rubl  = 0
                  v-tot-base  = 0
                  v-pay-type  = buf_tt-line.line-code
                  /*
                  v-tot-sum   = if ((p-cd-mode = {&cd-mode-ret}) OR (buf_tt-head-check.chk-type = INTEGER({&encashment}))) then - DECIMAL(v-src) else DECIMAL(v-src) /* !!! валюта*/
                  v-tot-rubl  = if ((p-cd-mode = {&cd-mode-ret}) OR (buf_tt-head-check.chk-type = INTEGER({&encashment}))) then - DECIMAL(v-src) else DECIMAL(v-src) /* !!! валюта*/
                  */
                  v-tot-sum   = if ((p-cd-mode = {&cd-mode-ret}) OR (buf_tt-head-check.chk-type = INTEGER({&encashment}))) then - DECIMAL(buf_tt-line.qnty) else DECIMAL(buf_tt-line.qnty) /* !!! валюта*/
                  v-tot-rubl  = if ((p-cd-mode = {&cd-mode-ret}) OR (buf_tt-head-check.chk-type = INTEGER({&encashment}))) then - DECIMAL(buf_tt-line.summ-netto-rub) else DECIMAL(buf_tt-line.summ-netto-rub) /* !!! валюта*/
                  v-tot-base  = if ((p-cd-mode = {&cd-mode-ret}) OR (buf_tt-head-check.chk-type = INTEGER({&encashment}))) then - DECIMAL(buf_tt-line.summ-netto) else DECIMAL(buf_tt-line.summ-netto) /* !!! валюта*/
               .
               assign
                  v-disp-msg-1 = buf_tt-line.line-name
                  v-disp-msg-2 = substitute  ( "&1 &2"
                                             , if (p-cd-mode = {&cd-mode-ret}) then - buf_tt-line.summ-netto else buf_tt-line.summ-netto
                                             , v-cd-base-name
                                             )
               .
               find first buf_cash-pay
                  where buf_cash-pay.cdpay-code = buf_tt-line.line-code
                     AND buf_cash-pay.curr-code  = buf_tt-line.curr-code
                  NO-LOCK
                  no-error
                  .
               if buf_cash-pay.atr16
               then do:
                  message
                     "Нельзя корректировать строку оплаты банковской картой."
                     skip
                  view-as alert-box error.
               end.
               else do:
                  if p-cd-mode = {&cd-mode-wth} then do:
                     { str/libthpos_inst-line.i
                        buf_tt-head-check.doc-code
                        buf_tt-line.num
                        v-mode
                        buf_tt-line.line-code
                        v-curr-base-code
                        v-par-code
                        v-src-qnty
                        v-frpay-code
                        v-pass-pay
                        v-pay-card
                        v-tot-sum
                        v-tot-rubl
                        v-tot-base
                        v-get-qnty-method
                        p-ok
                        no-error
                     }
                     if error-status:error
                     then do:
                        assign
                           p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                           p-ok = FALSE
                        .
                        return.
                     end.
                  end. /*if p-cd-mode = {&cd-mode-wth}*/
                  else do:
                     { str/libthpos_pay-line.i
                        buf_tt-head-check.doc-code
                        buf_tt-line.num
                        v-mode
                        buf_tt-line.line-code
                        buf_tt-line.curr-code
                        v-par-code
                        v-src-qnty
                        v-frpay-code
                        v-pass-pay
                        buf_tt-line.pay-card
                        v-tot-sum
                        v-tot-rubl
                        v-tot-base
                        v-get-qnty-method
                        v-2-cdpay-code
                        v-2-curr-code
                        v-2-frpay-code
                        v-2-tot-sum
                        v-2-tot-rubl
                        v-2-tot-base
                        v-src-discnt-local
                        v-src-discnt-local-rub
                        v-for-discnt-local-doc
                        v-for-discnt-local-rubl
                        v-for-discnt-local-r-b
                        p-ok
                        no-error
                     }
                     if error-status:error
                     then do:
                        assign
                           p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                           p-ok = FALSE
                        .
                        return.
                     end.
                  end. /*else if p-cd-mode = {&cd-mode-wth}*/
                  assign
                     buf_tt-line.summ-netto-rub    = ABSOLUTE(v-tot-rubl)
                     buf_tt-line.summ-netto        = ABSOLUTE(v-tot-base)
                     buf_tt-line.summ-discont      = v-src-discnt-local
                     buf_tt-line.summ-discont-rub  = v-src-discnt-local-rub
                     buf_tt-line.summ-brutto  = (if p-cd-mode <> {&cd-mode-wth}
                                                then v-for-discnt-local-rubl
                                                else buf_tt-line.summ-brutto)

                     /*
                     buf_tt-line.qnty-str          = STRING(v-tot-sum)
                     */
                     p-message                = substitute  ( "&1 &2"
                                                            , buf_tt-line.line-name
                                                            , if p-cd-mode = {&cd-mode-ret} then - v-src-qnty else v-src-qnty
                                                            )
                     v-src        = ""
                     v-src-qnty   = 0.0
                     v-src-price  = 0.0
                     v-src-price-rub  = 0.0
                  .
               end.
               RELEASE buf_cash-pay.
            end.
            else do:
               assign
                  p-message = "Запрещена коррекция строк оплаты. Используйте удаление."
               .
            end.
         end.
         OTHERWISE DO:
         end.
      end case.
   end.
   assign
      v-src            = ""
      v-src-qnty       = 0.0
      v-src-price      = 0.0
      v-src-price-rub  = 0.0
      v-num            = 0
      p-cd-submode     = {&cd-submode-goods}
      p-ok             = TRUE
   .

end. /* do on error */
end procedure. /* upd-line */




/*==========================================================================*/
procedure 2010 :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_tt-line     for tt-line .

do
on error undo, return error
:
   if not v-qnty-change
   then do:
      assign
         p-message   = "Коррекция количества запрещена"
         p-ok        = FALSE
      .
      return.
   end.

   if v-curr-num-0 <> 0
   then do:
      find first buf_tt-line
         where buf_tt-line.num  = v-curr-num-0
           and buf_tt-line.type = v-curr-type-0
         no-lock
         .
      if not available buf_tt-line
      then do:
         assign
            p-message   = "Нет строки чека для коррекции"
            p-ok        = FALSE
         .
         return.
      end.
   end.
   else do:
      assign
         p-message   = "Нет строки чека для коррекции"
         p-ok        = FALSE
      .
      return.
   end.

   if buf_tt-line.type = 1
   then do:
      assign
         p-message   = "Cтроку оплаты корректировать нельзя."
         p-ok        = FALSE
      .
      return.
   end.

   define buffer buf_rule-call-param   for ub.rule-call-param .

   define variable v-qnty    as logical      no-undo.

   for each  buf_rule-call-param
         where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
         no-lock
      :
      case buf_rule-call-param.param-name:
         WHEN "p-gds-qnty"
         then do:
            if  buf_rule-call-param.param-value-decimal <> 0
            AND buf_rule-call-param.param-value-decimal <> ?
            then
            assign
               v-src = STRING(buf_rule-call-param.param-value-decimal)
               v-qnty = if (buf_rule-call-param.param-value-decimal <> 0) then TRUE else FALSE
            .
         end.
         OTHERWISE DO:
         end.
      end case.
   end.

   if v-qnty
   then do:
      run upd-line  ( INPUt-OUTPUT p-cd-mode
                        , INPUt-output p-cd-submode
                        , output p-message
                        , output p-ok
                        ) .
   end.
   else do:
      if p-cd-mode = {&cd-mode-sale}
      OR p-cd-mode = {&cd-mode-ret}
      then do:
         assign
            p-cd-submode = {&cd-submode-qnty}
            p-ok         = TRUE
         .
      end.
   end.


end. /* do on error */
end procedure. /* 2010 */




/*==========================================================================*/
procedure 1984 :  /* отложить */
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .

do
on error undo, return error
:
   find first buf_tt-head-check NO-LOCK no-error.
   if not available buf_tt-head-check
   then do:
      return.
   end.
   { gbl/eventlib-event-log.i
      0
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      buf_tt-head-check.chk-type
      '':U
      '*':U
      '':U
      buf_tt-head-check.doc-code
      '':U
      TODAY
      57
      TIME
      'U':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      v-summ-netto-rub
      v-cntxt-userid
      no-error
   }

   run adm/chk-pass.w   ( input parparentproc
                        , input v-cntxt-userid
                        , input v-cntxt-db-num
                        , input "actn_ibsthpos-ord-chk"
                        , input FALSE
                        , output p-message
                        , output p-ok
                        ) .
   if not p-ok
   then do:
      { gbl/eventlib-event-log.i
         1
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         buf_tt-head-check.chk-type
         '':U
         p-message
         '':U
         buf_tt-head-check.doc-code
         '':U
         TODAY
         59
         TIME
         'E':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         v-summ-netto-rub
         v-cntxt-userid
         no-error
      }
      return.
   end.
   if CAN-find (first buf_tt-line       where buf_tt-line.hand-discounted       <> "":U )
   OR CAN-find (first buf_tt-head-check where buf_tt-head-check.hand-discounted <> "":U )
   then do:
       message
              "В отложенном чеке не будут сохранены ручные скидки."
         skip "Отложить чек?"
       view-as alert-box warning
       buttons yes-no
       update p-ok
       .
       if not p-ok
       then do:
         return.
       end.
       for each buf_tt-line
           where buf_tt-line.hand-discounted       <> "":U
           no-lock
           :
            assign
               v-disc-type = buf_tt-line.hand-discounted
               v-src       = STRING(0.0)
               p-cd-submode = {&cd-submode-line-dsc}
            .
               run input-discont ( INPUt-OUTPUT p-cd-mode
                                 , INPUt-output p-cd-submode
                                 , output p-message
                                 , output p-ok
                                 ) .

       end.
       for each buf_tt-head-check
           where buf_tt-head-check.hand-discounted <> "":U
           no-lock
           :
            assign
               v-disc-type = buf_tt-head-check.hand-discounted
               v-src       = STRING(0.0)
               p-cd-submode = {&cd-submode-tot-dsc}
            .
               run input-discont ( INPUt-OUTPUT p-cd-mode
                                 , INPUt-output p-cd-submode
                                 , output p-message
                                 , output p-ok
                                 ) .

       end.


   end.
   find first buf_tt-head-check NO-LOCK no-error.

   /* !!!

          */

   if CAN-find (first buf_tt-line where buf_tt-line.type = 1 )
   then do:
      assign
         p-message = "Оплаченный чек отложить нельзя."
         p-ok = FALSE
      .
      { gbl/eventlib-event-log.i
         1
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         buf_tt-head-check.chk-type
         '':U
         p-message
         '':U
         buf_tt-head-check.doc-code
         '':U
         TODAY
         59
         TIME
         'E':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         v-summ-netto-rub
         v-cntxt-userid
         no-error
      }
      return.
   end.

   { str/libthpos_postpone.i
      buf_tt-head-check.doc-code
      no-error
   }
   if error-status:error
   then do:
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      { gbl/eventlib-event-log.i
         1
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         buf_tt-head-check.chk-type
         '':U
         p-message
         '':U
         buf_tt-head-check.doc-code
         '':U
         TODAY
         59
         TIME
         'E':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         v-summ-netto-rub
         v-cntxt-userid
         no-error
      }
      return.
   end.

   { gbl/eventlib-event-log.i
      1
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      buf_tt-head-check.chk-type
      '':U
      p-message
      '':U
      buf_tt-head-check.doc-code
      '':U
      TODAY
      58
      TIME
      'S':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      v-summ-netto-rub
      v-cntxt-userid
      no-error
   }
   run clear-tt-chk in this-procedure.
   run reset-summ-for-pay in this-procedure.
   run set-all-summ  ( output p-message
                     , output p-ok
                     ) .

   /*  смена режима */
   assign
      p-cd-mode    = {&cd-mode-ready}
      p-cd-submode = {&cd-submode-goods}
      p-ok         = TRUE
      p-message    = "Чек отложен"
   .
   if not v-emul-mode
   then do:
      { gbl/disp-str.i
         p-message
         '':U
         p-message
         p-ok
      }
   end.

end. /* do on error */
end procedure. /* 1984 */



/*==========================================================================*/
procedure add-sale :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define variable v-local-src    as character    no-undo.
do
on error undo, return error
:
   assign
      v-local-src = v-src
   .

   run clear-tt-chk in this-procedure.

   run chk-open   ( input integer({&rcpt-sale})
                  , INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output p-message
                  , output p-ok
                  ) .
   if not p-ok
   then do:
      return.
   end.
   assign
      p-cd-mode    = {&cd-mode-sale}
      p-cd-submode = {&cd-submode-goods}
   .
   assign
      v-src = v-local-src
   .

   run add-gds-line  ( INPUt-OUTPUT p-cd-mode
                     , INPUt-output p-cd-submode
                     , output p-message
                     , output p-ok
                     ) .


end. /* do on error */
end procedure. /* add-sale */



/*==========================================================================*/
procedure del-gds-line :
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .
define buffer buf_cash-pay    for ub.cash-pay .

define variable v-b-code          as integer no-undo .
define variable v-gds-code        as integer no-undo .
define variable v-chk-name        as character no-undo .
define variable v-second-name     as character no-undo .
define variable v-src-sum         as decimal no-undo .
define variable v-src-sum-netto   as decimal no-undo .

define variable v-pline-num as integer no-undo .
define variable v-mode as character no-undo .
define variable v-pass-pay as integer no-undo .
define variable v-pay-card as character no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-tot-rubl as decimal no-undo .
define variable v-tot-base as decimal no-undo .
define variable v-par-code as integer  no-undo .
define variable v-src-qnty as decimal no-undo .
define variable v-get-qnty-method as character no-undo .
define variable v-2-cdpay-code as integer no-undo .
define variable v-2-curr-code as integer no-undo .
define variable v-2-tot-base as decimal no-undo .
define variable v-2-tot-rubl as decimal no-undo .
define variable v-next    as character    no-undo.
define variable v-frpay-code as integer no-undo .
define variable v-2-frpay-code as integer no-undo .
define variable v-src-discnt-local    as decimal      no-undo.
define variable v-src-discnt-local-rub    as decimal      no-undo.
define variable v-for-discnt-local-doc    as decimal no-undo .
define variable v-for-discnt-local-rubl   as decimal no-undo .
define variable v-for-discnt-local-r-b    as decimal no-undo .

do
on error undo, return error
:

  if v-curr-num-0 <> 0
  then do:

    find buf_tt-head-check.

    find first buf_tt-line
        where buf_tt-line.num  = v-curr-num-0
          AND buf_tt-line.type = v-curr-type-0
        no-lock
        .
    if not available buf_tt-line
    then do:
      assign
      v-src                    = ""
      v-src-qnty               = 0.0
      v-src-price              = 0.0
      v-src-price-rub          = 0.0
      v-num                    = 0
      p-ok                     = TRUE
      .
      return.
    end.
    if buf_tt-line.printed = TRUE
    then do:
      assign
      p-message   = "Отправленную на ФР строку удалять нельзя."
      p-ok        = FALSE
      .
      return.
    end.

    case buf_tt-line.type:
      WHEN 0 then do:
        { gbl/eventlib-event-log.i
        0
        v-cntxt-db-num
        '':U
        p-cash-num
        {&md}
        buf_tt-head-check.chk-type
        '':U
        '*':U
        0
        buf_tt-head-check.doc-code
        buf_tt-line.qnty
        TODAY
        27
        TIME
        'U':U
        buf_tt-line.line-code
        v-cntxt-obj-type
        v-cntxt-obj-code
        '':U
        {&cd-type-ibs-th}
        0
        ?
        '':U
        0
        v-src
        buf_tt-line.summ-netto
        v-cntxt-userid
        no-error
        }
        if error-status:error
        then do:
          message
          "Z"  27
          skip error-status:get-message(1)
          skip return-value
          view-as alert-box information.
        end.
        if p-cd-mode <> {&cd-mode-wth} then do:
          run adm/chk-pass.w   ( input parparentproc
                                , input v-cntxt-userid
                                , input v-cntxt-db-num
                                , input (if p-cd-mode = {&cd-mode-ret}
                                        then "actn_ibsthpos-annul-return"
                                        else "actn_ibsthpos-annul-sale"
                                        )
                                , input FALSE
                                , output p-message
                                , output p-ok
                                ) .
          if not p-ok
          then do:
              { gbl/eventlib-event-log.i
                0
                v-cntxt-db-num
                '':U
                p-cash-num
                {&md}
                buf_tt-head-check.chk-type
                '':U
                p-message
                '':U
                buf_tt-head-check.doc-code
                buf_tt-line.qnty
                TODAY
                29
                TIME
                'E':U
                v-gds-code
                v-cntxt-obj-type
                v-cntxt-obj-code
                '':U
                {&cd-type-ibs-th}
                0
                ?
                '':U
                0
                v-src
                buf_tt-line.summ-netto
                v-cntxt-userid
                no-error
              }
              return.
            end.
          end.

          assign
          v-pump            = 0
          v-nozzle-code     = 0
          v-pl-code         = 0
          v-pass-gds        = 0
          v-fbr-depart      = 0
          v-src-price       = ?
          v-src-price-rub   = ?
          v-write-off-code  = 0
          .

          assign
          v-src-qnty = 0
          v-src      = buf_tt-line.src
          .
          assign
          v-disp-msg-1 = buf_tt-line.line-name
          v-disp-msg-2 = substitute  ( "-&1 x &2 &3"
                                    , if p-cd-mode = {&cd-mode-ret} then - buf_tt-line.qnty else buf_tt-line.qnty
                                    , buf_tt-line.price
                                    , v-cd-base-name
                                    )
          .

          { str/libthpos_gds-line.i
              buf_tt-head-check.doc-code
              v-curr-num-0
              {&deletion}
              0
              v-src
              v-src-qnty
              v-pump
              v-nozzle-code
              v-pl-code
              v-pass-gds
              v-write-off-code
              v-fbr-depart
              p-ok
              v-next
              v-b-code
              v-gds-code
              v-chk-name
              v-second-name
              v-src-price
              v-src-price-rub
              v-src-discnt
              v-src-discnt-rub
              v-src-sum
              v-src-sum-rub
              v-src-sum-netto
              v-src-sum-netto-rub
              v-unit-base
          no-error
          }
          /*12345 */
          if error-status:error
          then do:
            assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
              0
              v-cntxt-db-num
              '':U
              p-cash-num
              {&md}
              buf_tt-head-check.chk-type
              '':U
              p-message
              '':U
              buf_tt-head-check.doc-code
              buf_tt-line.qnty
              TODAY
              29
              TIME
              'E':U
              v-gds-code
              v-cntxt-obj-type
              v-cntxt-obj-code
              '':U
              {&cd-type-ibs-th}
              0
              ?
              '':U
              0
              v-src
              buf_tt-line.summ-netto
              v-cntxt-userid
              no-error
            }
            return.
          end.
          DELETE buf_tt-line.

          { gbl/eventlib-event-log.i
              0
              v-cntxt-db-num
              '':U
              p-cash-num
              {&md}
              buf_tt-head-check.chk-type
              '':U
              '*':U
              0
              buf_tt-head-check.doc-code
              0
              TODAY
              28
              TIME
              'S':U
              v-gds-code
              v-cntxt-obj-type
              v-cntxt-obj-code
              '':U
              {&cd-type-ibs-th}
              0
              ?
              '':U
              0
              v-src
              0
              v-cntxt-userid
              no-error
          }
          if error-status:error
          then do:
            message
            "Z"  28
            skip error-status:get-message(1)
            skip return-value
            view-as alert-box information.
          end.
        end.
        WHEN 1 then do:
          assign
          v-mode  = {&deletion}
          v-pass-pay  = 0
          v-pay-card  = ""
          v-tot-sum   = 0
          v-tot-rubl  = 0
          v-tot-base  = 0
          v-pay-type  = buf_tt-line.line-code
          .
          assign
          v-disp-msg-1 = buf_tt-line.line-name
          v-disp-msg-2 = substitute  ( "&1 &2"
                                    , if (p-cd-mode = {&cd-mode-ret}) then - buf_tt-line.summ-netto else buf_tt-line.summ-netto
                                    , v-cd-base-name
                                    )
          .
          { gbl/eventlib-event-log.i
              0
              v-cntxt-db-num
              '':U
              p-cash-num
              {&md}
              buf_tt-head-check.chk-type
              '':U
              '*':U
              '':U
              buf_tt-head-check.doc-code
              '':U
              TODAY
              30
              TIME
              'U':U
              0
              v-cntxt-obj-type
              v-cntxt-obj-code
              '':U
              {&cd-type-ibs-th}
              0
              ?
              '':U
              0
              '':U
              buf_tt-line.summ-netto
              v-cntxt-userid
              no-error
          }
          find first buf_cash-pay
                where buf_cash-pay.cdpay-code = buf_tt-line.line-code
                  AND buf_cash-pay.curr-code  = buf_tt-line.curr-code
                NO-LOCK
                no-error
                .
          if buf_cash-pay.atr16
          AND not v-emul-mode
          then do:
            { gbl/eventlib-event-log.i
              0
              v-cntxt-db-num
              '':U
              p-cash-num
              {&md}
              buf_tt-head-check.chk-type
              '':U
              '*':U
              '':U
              buf_tt-head-check.doc-code
              '':U
              TODAY
              92
              TIME
              'S':U
              0
              v-cntxt-obj-type
              v-cntxt-obj-code
              v-pay-card
              {&cd-type-ibs-th}
              0
              ?
              '':U
              0
              '':U
              buf_tt-line.summ-netto
              v-cntxt-userid
              no-error
            }
            run adm/chk-pass.w   ( input parparentproc
                                , input v-cntxt-userid
                                , input v-cntxt-db-num
                                , input "actn_ibsthpos-annul-card-pay"
                                , input FALSE
                                , output p-message
                                , output p-ok
                                ) .
            if not p-ok
            then do:
              { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  p-message
                  '':U
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  32
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  buf_tt-line.summ-netto
                  v-cntxt-userid
                  no-error
              }
              { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  p-message
                  '':U
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  26
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  v-pay-card
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  buf_tt-line.summ-netto
                  v-cntxt-userid
                  no-error
              }
              return.
            end.


            define variable v-slip    as character    no-undo.
            { gbl/sb-revert.i
              v-tot-rubl
              v-slip
              v-pay-card
              p-message
              p-ok
            }
            if error-status:error
            OR not p-ok
            then do:
              assign
              p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
              p-ok = FALSE
              .

              { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  p-message
                  '':U
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  26
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  v-pay-card
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  buf_tt-line.summ-netto
                  v-cntxt-userid
                  no-error
              }

            end.
            else do:
              run print-slip in this-procedure (input v-slip, output p-message, output p-ok) .
              run print-head-chk   ( output p-message
                                    , output p-ok
                                    ) .
              { str/libthpos_pay-line.i
                  buf_tt-head-check.doc-code
                  buf_tt-line.num
                  v-mode
                  buf_tt-line.line-code
                  v-curr-base-code
                  v-par-code
                  v-src-qnty
                  v-frpay-code
                  v-pass-pay
                  v-pay-card
                  v-tot-sum
                  v-tot-rubl
                  v-tot-base
                  v-get-qnty-method
                  v-2-cdpay-code
                  v-2-curr-code
                  v-2-frpay-code
                  v-2-tot-sum
                  v-2-tot-rubl
                  v-2-tot-base
                  v-src-discnt-local
                  v-src-discnt-local-rub
                  v-for-discnt-local-doc
                  v-for-discnt-local-rubl
                  v-for-discnt-local-r-b
                  p-ok
                  no-error
              }
              if error-status:error
              then do:
                assign
                p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                p-ok = FALSE
                .
                return.
              end.
              DELETE buf_tt-line.

              { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  p-cash-num
                  {&md}
                  buf_tt-head-check.chk-type
                  '':U
                  '*':U
                  '':U
                  buf_tt-head-check.doc-code
                  '':U
                  TODAY
                  25
                  TIME
                  'S':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  v-pay-card
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  v-tot-rubl
                  v-cntxt-userid
                  no-error
              }
            end.
          end.
          else do:
            if p-cd-mode = {&cd-mode-wth}
            then do:
              { str/libthpos_inst-line.i
                  buf_tt-head-check.doc-code
                  buf_tt-line.num
                  v-mode
                  buf_tt-line.line-code
                  v-curr-base-code
                  v-par-code
                  v-src-qnty
                  v-frpay-code
                  v-pass-pay
                  v-pay-card
                  v-tot-sum
                  v-tot-rubl
                  v-tot-base
                  v-get-qnty-method
                  p-ok
                  no-error
              }
              if error-status:error
              then do:
                assign
                p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                p-ok = FALSE
                  .
                return.
              end.
            end.
            else do:
              { str/libthpos_pay-line.i
                  buf_tt-head-check.doc-code
                  buf_tt-line.num
                  v-mode
                  buf_tt-line.line-code
                  v-curr-base-code
                  v-par-code
                  v-src-qnty
                  v-frpay-code
                  v-pass-pay
                  v-pay-card
                  v-tot-sum
                  v-tot-rubl
                  v-tot-base
                  v-get-qnty-method
                  v-2-cdpay-code
                  v-2-curr-code
                  v-2-frpay-code
                  v-2-tot-sum
                  v-2-tot-rubl
                  v-2-tot-base
                  v-src-discnt-local
                  v-src-discnt-local-rub
                  v-for-discnt-local-doc
                  v-for-discnt-local-rubl
                  v-for-discnt-local-r-b
                  p-ok
                  no-error
              }
              if error-status:error
              then do:
                assign
                p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                p-ok = FALSE
                .
                return.
              end.
            end.
            DELETE buf_tt-line.
          end.
          RELEASE buf_cash-pay.

          { gbl/eventlib-event-log.i
              0
              v-cntxt-db-num
              '':U
              p-cash-num
              {&md}
              buf_tt-head-check.chk-type
              '':U
              '*':U
              '':U
              buf_tt-head-check.doc-code
              '':U
              TODAY
              31
              TIME
              'S':U
              0
              v-cntxt-obj-type
              v-cntxt-obj-code
              '':U
              {&cd-type-ibs-th}
              0
              ?
              '':U
              0
              '':U
              v-tot-rubl
              v-cntxt-userid
              no-error
          }
        end. /*WHEN 1 then do:*/
        OTHERWISE DO:
        end.
    end case. /*case buf_tt-line.type:*/
    if CAN-find(buf_tt-line where buf_tt-line.num  = v-curr-num-0 + 1
                                AND buf_tt-line.type = v-curr-type-0 ) then do:
      assign
      v-curr-num-0             = v-curr-num-0 + 1
      .
    end.
    else do:
      find first buf_tt-line no-lock no-error.
      if available buf_tt-line
      then do:
        assign
        v-curr-num-0             = buf_tt-line.num
        v-curr-type-0            = buf_tt-line.type
        .
      end.
      else do:
        assign
        v-curr-num-0             = 0
        v-curr-type-0            = 0
        .
      end.
    end.
    define variable v-num-str     as integer      no-undo.
    define variable v-gds-yes     as integer      no-undo.
    define variable v-pay-yes     as integer      no-undo.
    define variable v-msg         as character    no-undo.
    define variable v-num-local   as integer      no-undo.
    define variable v-type-local  as integer      no-undo.
    if INDEX(v-next, "=") > 0
    AND not v-recalc
    then do:
      assign
      v-recalc  = TRUE
      v-msg     = p-message
      v-next    = TRIM(v-next, "recalc=")
      v-num-str = INTEGER(ENTRY(1, v-next, ","))
      v-gds-yes = INTEGER(ENTRY(2, v-next, ","))
      v-pay-yes = INTEGER(ENTRY(3, v-next, ","))
      v-num-local  = v-curr-num-0
      v-type-local = v-curr-type-0
      .
      run recalc-lines in this-procedure
                    ( input v-num-str
                    , input v-gds-yes
                    , input v-pay-yes
                    , input-output p-cd-mode
                    , INPUt-output p-cd-submode
                    , output p-message
                    , output p-ok
                    ) .
      assign
      v-src            = ""
      v-src-qnty       = 0.0
      v-src-price      = 0.0
      v-src-price-rub  = 0.0
      v-recalc  = FALSE
      p-message = v-msg
      v-curr-num-0     = v-num-local
      v-curr-type-0    = v-type-local
      .
    end. /*if INDEX(v-next, "=") > 0*/

    if not v-emul-mode
    then do:
      { gbl/disp-str.i
        v-disp-msg-1
        v-disp-msg-2
        p-message
        p-ok
      }
    end.

    assign
    v-src                    = ""
    v-src-qnty               = 0.0
    v-src-price              = 0.0
    v-src-price-rub          = 0.0
    v-num                    = 0
    p-ok                     = TRUE
    .
  end.
end. /* do on error */
end procedure. /* del-gds-line */



/*==========================================================================*/
procedure set-curr-num :
define input parameter p-type       as integer        no-undo.
define input parameter p-num        as integer        no-undo.
define output parameter p-message   as character      no-undo .
define output parameter p-ok        as logical        no-undo.

do
on error undo, return error
:
   assign
      v-curr-num-0 = p-num
      v-curr-type-0 = p-type
      p-ok  = TRUE
   .
end. /* do on error */
end procedure. /* set-curr-num */



/*==========================================================================*/
procedure get-curr-num :
define output parameter p-type as integer          no-undo.
define output parameter p-num as integer          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   assign
      p-num  = v-curr-num-0
      p-type = v-curr-type-0
      p-ok   = TRUE
   .
end. /* do on error */
end procedure. /* get-curr-num */



/*==========================================================================*/
procedure rest-back :
define input-output  parameter p-rest-summ   as decimal          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define variable v-pline-num as integer no-undo .
define variable v-mode as character no-undo .
define variable v-pass-pay as integer no-undo .
define variable v-pay-card as character no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-tot-rubl as decimal no-undo .
define variable v-tot-base as decimal no-undo .
define variable v-par-code as integer no-undo .
define variable v-src-qnty as decimal no-undo .
define variable v-get-qnty-method as character no-undo .
define variable v-2-cdpay-code as integer no-undo .
define variable v-2-curr-code as integer no-undo .
define variable v-2-tot-base as decimal no-undo .
define variable v-2-tot-rubl as decimal no-undo .
define variable v-frpay-code as integer no-undo .
define variable v-2-frpay-code as integer no-undo .
define variable v-src-discnt-local    as decimal      no-undo.
define variable v-src-discnt-local-rub    as decimal      no-undo.
define variable v-for-discnt-local-doc    as decimal no-undo .
define variable v-for-discnt-local-rubl   as decimal no-undo .
define variable v-for-discnt-local-r-b    as decimal no-undo .

define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .

do
on error undo, return error
:

   if v-summ-netto-rub < v-summ-pay-rub
   then do:
      find buf_tt-head-check.

      find last buf_tt-line where buf_tt-line.type = 1 no-lock.
      if not available buf_tt-line
      then do:
         assign
            p-message = "В чеке нет оплат"
            p-ok      = FALSE
         .
         return.
      end.

      if p-rest-summ = ?
      then do:
         assign
            v-pline-num = buf_tt-line.num + 1
            v-mode      = {&add-def}
            v-pass-pay  = 0
            v-pay-card  = ""
            v-tot-base  = ?
            /*!!!*/
            v-tot-sum   = if (buf_tt-head-check.chk-type = integer({&rcpt-return})) then - (v-summ-netto-rub - v-summ-pay-rub) else v-summ-netto-rub - v-summ-pay-rub
            v-tot-rubl  = if (buf_tt-head-check.chk-type = integer({&rcpt-return})) then - (v-summ-netto-rub - v-summ-pay-rub) else v-summ-netto-rub - v-summ-pay-rub
            v-tot-base  = if (buf_tt-head-check.chk-type = integer({&rcpt-return})) then - (v-summ-netto - v-summ-pay) else v-summ-netto - v-summ-pay
            v-pay-type  = ?
         .
      end.
      else do:
         assign
            v-pline-num = buf_tt-line.num + 1
            v-mode      = {&add-def}
            v-pass-pay  = 0
            v-pay-card  = ""
            v-tot-base  = ?
            /*!!!*/
            v-tot-sum   = if (buf_tt-head-check.chk-type = integer({&rcpt-return})) then p-rest-summ else - p-rest-summ
            v-tot-rubl  = if (buf_tt-head-check.chk-type = integer({&rcpt-return})) then p-rest-summ else - p-rest-summ
            v-tot-base  = if (buf_tt-head-check.chk-type = integer({&rcpt-return})) then p-rest-summ else - p-rest-summ
            v-pay-type  = ?
         .
      end.

      { str/libthpos_pay-line.i
         buf_tt-head-check.doc-code
         v-pline-num
         v-mode
         v-pay-type
         v-curr-base-code
         v-par-code
         v-src-qnty
         v-frpay-code
         v-pass-pay
         v-pay-card
         v-tot-sum
         v-tot-rubl
         v-tot-base
         v-get-qnty-method
         v-2-cdpay-code
         v-2-curr-code
         v-2-frpay-code
         v-2-tot-sum
         v-2-tot-rubl
         v-2-tot-base
         v-src-discnt-local
         v-src-discnt-local-rub
         v-for-discnt-local-doc
         v-for-discnt-local-rubl
         v-for-discnt-local-r-b
         p-ok
         no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         return.
      end.
      assign
         p-rest-summ = ABS(v-tot-rubl)
      .

      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         0
         '':U
         buf_tt-head-check.chk-type
         '':U
         '*':U
         '':U
         buf_tt-head-check.doc-code
         '':U
         TODAY
         68
         TIME
         'S':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         v-tot-rubl
         v-cntxt-userid
         no-error
      }

   end.
   else do:
      if TRUNCATE(v-summ-netto-rub, 2) > TRUNCATE(v-summ-pay-rub, 2)
      then do:
         assign
            p-message = "Чек оплачен не полностью"
            p-ok      = FALSE
         .
         return.
      end.
      else do:
         assign
            p-ok = TRUE
         .
      end.
   end.
end. /* do on error */
end procedure. /* rest-back */




/*==========================================================================*/
procedure del-rest:
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define variable v-pline-num as integer no-undo .
define variable v-mode as character no-undo .
define variable v-pass-pay as integer no-undo .
define variable v-pay-card as character no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-tot-rubl as decimal no-undo .
define variable v-tot-base as decimal no-undo .
define variable v-par-code as integer no-undo .
define variable v-src-qnty as decimal no-undo .
define variable v-get-qnty-method as character no-undo .
define variable v-2-cdpay-code as integer no-undo .
define variable v-2-curr-code as integer no-undo .
define variable v-2-tot-base as decimal no-undo .
define variable v-2-tot-rubl as decimal no-undo .
define variable v-frpay-code as integer no-undo .
define variable v-2-frpay-code as integer no-undo .
define variable v-src-discnt-local    as decimal      no-undo.
define variable v-src-discnt-local-rub    as decimal      no-undo.
define variable v-for-discnt-local-doc    as decimal no-undo .
define variable v-for-discnt-local-rubl   as decimal no-undo .
define variable v-for-discnt-local-r-b    as decimal no-undo .

define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .

do
on error undo, return error
:
   find buf_tt-head-check.

   if (buf_tt-head-check.chk-type = integer({&rcpt-return}))
   then do:
      assign
         p-message = "В возврате запрещена сдача"
         p-ok      = FALSE
      .
      return.
   end.

   find last buf_tt-line where buf_tt-line.type = 1 no-lock.
   if not available buf_tt-line
   then do:
      assign
         p-message = "В чеке нет оплат"
         p-ok      = FALSE
      .
      return.
   end.

   assign
      v-pline-num = buf_tt-line.num + 1
      v-mode      = {&deletion}
      v-pass-pay  = 0
      v-pay-card  = ""
      v-tot-base  = 0
      v-tot-sum   = 0
      v-tot-rubl  = 0
      v-tot-base  = 0
      v-pay-type  = 1
   .

   { str/libthpos_pay-line.i
      buf_tt-head-check.doc-code
      v-pline-num
      v-mode
      v-pay-type
      v-curr-base-code
      v-par-code
      v-src-qnty
      v-frpay-code
      v-pass-pay
      v-pay-card
      v-tot-sum
      v-tot-rubl
      v-tot-base
      v-get-qnty-method
      v-2-cdpay-code
      v-2-curr-code
      v-2-frpay-code
      v-2-tot-sum
      v-2-tot-rubl
      v-2-tot-base
      v-src-discnt-local
      v-src-discnt-local-rub
      v-for-discnt-local-doc
      v-for-discnt-local-rubl
      v-for-discnt-local-r-b
      p-ok
      no-error
   }
   if error-status:error
   then do:
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      return.
   end.
end. /* do on error */
end procedure. /* del-rest */




/*==========================================================================*/
procedure 1979 : /* Анулляция */
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_tt-head-check     for tt-head-check .
define buffer buf_tt-line           for tt-line .

define variable v-chk-fr-num    as character    no-undo.

do
on error undo, return error
:
  define variable v-fr-mode            as integer      no-undo.
  define variable v-fr-time            as integer      no-undo.
  define variable v-fr-date            as date         no-undo.
  define variable v-fr-last-shift-date as date         no-undo.
  define variable v-fr-lic             as character    no-undo.
  define variable v-fr-serial          as char    no-undo.
  define variable loc-log              as logical no-undo .
define variable v-price-rub      as decimal      no-undo .
define variable v-disc-rub       as decimal      no-undo .
define variable v-disc-rub-total as decimal      no-undo .
define variable v-print-line     as character    no-undo .
define variable v-rest-summ      as decimal      no-undo .

   { gbl/fr-ctrl.i
      v-cash-drawer-open
      p-message
      p-ok
      v-fr-mode
      v-fr-time
      v-fr-date
      v-fr-last-shift-date
      v-fr-last-shift-num
      v-fr-lic
      v-fr-shift-open
      v-fr-serial
      no-error
   }
/*      message*/
/*         "X"  5*/
/*         skip v-fr-last-shift-num*/
/*      view-as alert-box information.*/
  if  not p-ok
  AND v-fr-shift-open = 24
  then do:
    assign
    p-message = "Истекли 24 часа открытой смены. Чек можно только отложить."
    p-ok = FALSE
    .
    return.
  end.

  find first buf_tt-head-check no-error.
  if not available buf_tt-head-check
  then return.
  message
  "Вы действительно хотите аннулировать чек?"
  view-as alert-box question buttons yes-no update loc-log.
  if not loc-log then do:
    assign
    p-ok = FALSE
    .
    return.
  end.
  { gbl/eventlib-event-log.i
    0
    v-cntxt-db-num
    '':U
    p-cash-num
    {&md}
    buf_tt-head-check.chk-type
    '':U
    '*':U
    '':U
    buf_tt-head-check.doc-code
    '':U
    TODAY
    54
    TIME
    'U':U
    0
    v-cntxt-obj-type
    v-cntxt-obj-code
    '':U
    {&cd-type-ibs-th}
    0
    ?
    '':U
    0
    '':U
    v-summ-netto-rub
    v-cntxt-userid
    no-error
  }
  if p-cd-mode <> {&cd-mode-wth}  then do:
    run adm/chk-pass.w   ( input parparentproc
                        , input v-cntxt-userid
                        , input v-cntxt-db-num
                        , input (if p-cd-mode = {&cd-mode-ret}
                                then "actn_ibsthpos-annul-return"
                                else "actn_ibsthpos-annul-sale"
                                )
                        , input FALSE
                        , output p-message
                        , output p-ok
                        ) .
    if not p-ok then do:
      { gbl/eventlib-event-log.i
          0
          v-cntxt-db-num
          '':U
          p-cash-num
          {&md}
          buf_tt-head-check.chk-type
          '':U
          p-message
          '':U
          buf_tt-head-check.doc-code
          '':U
          TODAY
          56
          TIME
          'E':U
          0
          v-cntxt-obj-type
          v-cntxt-obj-code
          '':U
          {&cd-type-ibs-th}
          0
          ?
          '':U
          0
          '':U
          v-summ-netto-rub
          v-cntxt-userid
          no-error
      }
      return.
    end.
  end.

  if p-cd-mode = {&cd-mode-sale}
  OR p-cd-mode = {&cd-mode-ret}
  OR p-cd-mode = {&cd-mode-wth}
  then do:
    if not v-emul-mode then do:
      if CAN-find ( first buf_tt-line
                    where buf_tt-line.type = 1
                        NO-LOCK )
      then do:
        assign
        p-message = "Чек нельзя аннулировать - в чеке есть линии оплаты."
        p-ok      = FALSE
        .
        { gbl/eventlib-event-log.i
          0
          v-cntxt-db-num
          '':U
          p-cash-num
          {&md}
          buf_tt-head-check.chk-type
          '':U
          p-message
          '':U
          buf_tt-head-check.doc-code
          '':U
          TODAY
          56
          TIME
          'E':U
          0
          v-cntxt-obj-type
          v-cntxt-obj-code
          '':U
          {&cd-type-ibs-th}
          0
          ?
          '':U
          0
          '':U
          v-summ-netto-rub
          v-cntxt-userid
          no-error
        }
        return.
      end.
      if p-cd-mode <> {&cd-mode-wth}
      then do:

        { gbl/fr-ctrl.i
            v-cash-drawer-open
            p-message
            p-ok
            v-fr-mode
            v-fr-time
            v-fr-date
            v-fr-last-shift-date
            v-fr-last-shift-num
            v-fr-lic
            v-fr-shift-open
            v-fr-serial
            no-error
        }
/*      message*/
/*         "X"  6*/
/*         skip v-fr-last-shift-num*/
/*      view-as alert-box information.*/

        if v-fr-mode <> 8 then do:
          define variable v-num-ch    as integer      no-undo.
          case buf_tt-head-check.chk-type:
            WHEN integer({&rcpt-sale}) then do:
              { gbl/fr-open-chk.i
              0
              v-num-ch
              p-message
              p-ok
              no-error
              }
            end.
            WHEN integer({&rcpt-return}) then do:
              { gbl/fr-open-chk.i
              2
              v-num-ch
              p-message
              p-ok
              no-error
              }
            end.
            OTHERWISE DO:
            end.
          end case.


          if error-status:error
          OR not p-ok
          then do:
            assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
                0
                v-cntxt-db-num
                '':U
                p-cash-num
                {&md}
                buf_tt-head-check.chk-type
                '':U
                p-message
                '':U
                buf_tt-head-check.doc-code
                '':U
                TODAY
                56
                TIME
                'E':U
                0
                v-cntxt-obj-type
                v-cntxt-obj-code
                '':U
                {&cd-type-ibs-th}
                0
                ?
                '':U
                0
                '':U
                v-summ-netto-rub
                v-cntxt-userid
                no-error
            }
            return .
          end.
         end.
          /*                    */

  for each  buf_tt-line
      where buf_tt-line.type = 0
        AND buf_tt-line.printed = FALSE
      :

    case tt-head-check.chk-type:
      WHEN integer({&rcpt-sale})
      then do:
        if not v-emul-mode
        then do:
          assign
          v-price-rub = buf_tt-line.price-rub
          v-disc-rub  = - buf_tt-line.summ-discont-rub
          v-disc-rub-total = v-disc-rub-total - v-disc-rub
          .
          run str-fix-width ( input (if v-print-good-code then STRING(buf_tt-line.src) + " " else "":U) + buf_tt-line.line-name
                            , input "":U
                            , input v-fr-width
                            , YES
                            , output v-print-line
                            , output p-message
                            , output p-ok
                            ) .
          { gbl/fr-add-sale.i
              '':U
              v-print-line
              v-price-rub
              buf_tt-line.qnty
              buf_tt-line.unit-base
              v-d-card
              v-disc-rub
              p-message
              p-ok
              no-error
          }
          if error-status:error
          then do:
            if v-rest-summ > 0
            then do:
              run del-rest (output p-message, output p-ok) .
            end.
            assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
              0
              v-cntxt-db-num
              '':U
              p-cash-num
              {&md}
              tt-head-check.chk-type
              '':U
              p-message
              '':U
              tt-head-check.doc-code
              '':U
              TODAY
              65
              TIME
              'E':U
              0
              v-cntxt-obj-type
              v-cntxt-obj-code
              '':U
              {&cd-type-ibs-th}
              0
              ?
              '':U
              0
              '':U
              v-summ-netto-rub
              v-cntxt-userid
              no-error
            }
            return.
          end.
        end.
        else do:
          assign
          p-ok = TRUE
                .
        end.
      end. /*WHEN integer({&rcpt-sale})*/
      WHEN integer({&rcpt-return})
      then do:
        if not v-emul-mode
        then do:
          assign
          v-price-rub      =  buf_tt-line.price-rub
          v-disc-rub       = - buf_tt-line.summ-discont-rub
          v-disc-rub-total = v-disc-rub-total - v-disc-rub
          .
          run str-fix-width ( input (if v-print-good-code then STRING(buf_tt-line.src) + " " else "":U) + buf_tt-line.line-name
                            , input "":U
                            , input v-fr-width
                            , YES
                            , output v-print-line
                            , output p-message
                            , output p-ok
                            ) .
          { gbl/fr-add-ret.i
              '':U
              v-print-line
              v-price-rub
              buf_tt-line.qnty
              buf_tt-line.unit-base
              v-d-card
              v-disc-rub
              p-message
              p-ok
              no-error
          }
          if error-status:error
          then do:
            if v-rest-summ > 0
            then do:
              run del-rest (output p-message, output p-ok) .
            end.
            assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
              0
              v-cntxt-db-num
              '':U
              p-cash-num
              {&md}
              tt-head-check.chk-type
              '':U
              p-message
              '':U
              tt-head-check.doc-code
              '':U
              TODAY
              65
              TIME
              'E':U
              0
              v-cntxt-obj-type
              v-cntxt-obj-code
              '':U
              {&cd-type-ibs-th}
              0
              ?
              '':U
              0
              '':U
              v-summ-netto-rub
              v-cntxt-userid
              no-error
            }
            return .
          end.
        end.
        else do:
          assign
          p-ok = TRUE
          .
        end.
      end. /*WHEN integer({&rcpt-return})*/
      /*
      WHEN integer({&encashment})
      then do:
      end.
      WHEN integer({&cd-fund})
      then do:
      end.
      */
      OTHERWISE DO:
      end.
    end case. /*case tt-head-check.chk-type:*/
    assign
    buf_tt-line.printed = TRUE
    .
  end. /*  for each  buf_tt-line*/

          /*                    */
          { gbl/fr-chk-annul.i
              v-chk-fr-num
              p-message
              p-ok
              no-error
          }
          if error-status:error
          OR not p-ok
          then do:
            assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
              0
              v-cntxt-db-num
              '':U
              p-cash-num
              {&md}
              buf_tt-head-check.chk-type
              '':U
              p-message
              '':U
              buf_tt-head-check.doc-code
              '':U
              TODAY
              56
              TIME
              'E':U
              0
              v-cntxt-obj-type
              v-cntxt-obj-code
              '':U
              {&cd-type-ibs-th}
              0
              ?
              '':U
              0
              '':U
              v-summ-netto-rub
              v-cntxt-userid
              no-error
            }
            return .
          end.
       end. /* p-cd-mode <> {&cd-mode-wth} */
    end. /* not v-emul-mode */
    else do:
      assign
      p-ok = TRUE
      .
    end.
    { str/libthpos_annulate.i
        buf_tt-head-check.doc-code
        0
        no-error
    }
    if error-status:error
    then do:
      assign
      p-message = substitute("libthpos_annulate &1 &2 &3", error-status:get-message(1), return-value, p-message)
      p-ok = FALSE
      .
      { gbl/eventlib-event-log.i
        0
        v-cntxt-db-num
        '':U
        p-cash-num
        {&md}
        buf_tt-head-check.chk-type
        '':U
        p-message
        '':U
        buf_tt-head-check.doc-code
        '':U
        TODAY
        56
        TIME
        'E':U
        0
        v-cntxt-obj-type
        v-cntxt-obj-code
        '':U
        {&cd-type-ibs-th}
        0
        ?
        '':U
        0
        '':U
        v-summ-netto-rub
        v-cntxt-userid
        no-error
      }
      return.
    end.
    { gbl/eventlib-event-log.i
        0
        v-cntxt-db-num
        '':U
        p-cash-num
        {&md}
        buf_tt-head-check.chk-type
        '':U
        '*':U
        '':U
        buf_tt-head-check.doc-code
        '':U
        TODAY
        55
        TIME
        'S':U
        0
        v-cntxt-obj-type
        v-cntxt-obj-code
        '':U
        {&cd-type-ibs-th}
        0
        ?
        '':U
        0
        '':U
        v-summ-netto-rub
        v-cntxt-userid
        no-error
    }
    run clear-tt-chk in this-procedure.
    run reset-summ-for-pay in this-procedure.
    run set-all-summ ( output p-message
                      , output p-ok
                      ) .

    assign
    p-message    = "Чек аннулирован"
    p-cd-mode    = {&cd-mode-ready}
    p-cd-submode = {&cd-submode-goods}
    p-ok         = TRUE
    .
    if not v-emul-mode
    then do:
      { gbl/disp-str.i
        p-message
        '':U
        p-message
        p-ok
      }
    end.
    else do:
      assign
      p-ok = TRUE
    .
    end.
  end.
end. /* do on error */
end procedure. /* 1979 */



/* выбор товара из справочника */
/*==========================================================================*/
procedure 1978 :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_goods    for ub.goods .
define variable v-ref-list    as character    no-undo.
define variable v-count      as integer      no-undo.

define buffer buf_tt-head-check     for tt-head-check .
DEFINE buffer loc_bar-code for ub.bar-code.
DEFINE buffer root_bar-code for ub.bar-code.
define buffer loc_gds-prt for ub.gds-prt.


do
on error undo, return error
:
define buffer buf_rule-call-param   for ub.rule-call-param .

define variable v-gds    as logical      no-undo.

for each  buf_rule-call-param
    where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
    no-lock
:
  case buf_rule-call-param.param-name:
    WHEN "p-gds-code"  then do:
      if  buf_rule-call-param.param-value-integer <> 0
      AND buf_rule-call-param.param-value-integer <> ?
      then
      assign
      v-src = STRING(buf_rule-call-param.param-value-integer)
      v-gds = TRUE
      .
    end.
    OTHERWISE DO:
    end.
   end case.
 end. /*for each  buf_rule-call-param*/

if v-src <> '' then
do:

  assign
   v-gds = yes .
end.

if v-gds then do:
  if not CAN-find ( buf_tt-head-check )
   then do:
         run clear-tt-chk in this-procedure.

         run chk-sale-open   ( INPUt-OUTPUT p-cd-mode
                           , INPUt-output p-cd-submode
                           , output p-message
                           , output p-ok
                           ) .
         if not p-ok
         then do:
            return.
         end.
   end. /*F not CAN-find ( buf_tt-head-check )*/
   run set-input-time in this-procedure ( input -1, output p-message, output p-ok ).

   run add-gds-line in this-procedure (input-output p-cd-mode, input-output p-cd-submode, output p-message, output p-ok).

end. /*if v-gds then do:*/
else do:
  run ref/gds-ref.p
      ( parParentProc
      , "b-sel"
      , {&all}
      , {&all}
      , {&fact}
      , ?
      , ?
      , ?
      , ?
      , v-cntxt-obj-type
      , v-cntxt-obj-code
      , ?
      , output v-ref-list).
  if v-ref-list = ""
  then do:
      return.
  end.
  if not CAN-find ( buf_tt-head-check )
  then do:
    run clear-tt-chk in this-procedure.

    run chk-sale-open   ( INPUt-OUTPUT p-cd-mode
                      , INPUt-output p-cd-submode
                      , output p-message
                      , output p-ok
                      ) .
    if not p-ok
    then do:
       return.
     end.
  end.

  DO v-count = 1 TO NUM-ENTRIES(v-ref-list)
  on error undo, next
  :
    find first buf_goods
      where recid( buf_goods ) = INTEGER(ENTRY(v-count, v-ref-list))
      NO-LOCK
      no-error.
    if available buf_goods then do:
      if v-doc-prt then do:      /*Если разрешена работа с признаками определяем непустая ли шкала и вызываем справочник признаков*/
        find first ub.gds-prt where
                ub.gds-prt.upper-code = buf_goods.prt-root NO-LOCK .

        if v-doc-prt and  gds-prt.node-name <> {&empty-scale} then do:
          define variable v-sel-node-code as integer   no-undo .
          run str/prt-ref.w
            (input parparentproc
            ,input  buf_goods.gds-code /* p-gds-code      */
            ,input  {&choose}          /* p-mode          */
            ,input  v-cntxt-obj-type         /* p-obj-type      */
            ,input  v-cntxt-obj-code         /* p-obj-code      */
            ,input  ""                 /* p-doc-code      */
            ,input  ""                 /* p-search-code   */
            ,output v-sel-node-code    /* p-sel-node-code */
            ) .
          if v-sel-node-code <> ? then do:
            find first loc_gds-prt No-LOCK
              where loc_gds-prt.node-code = v-sel-node-code
              No-error.
            if not avail loc_gds-prt then return error.
              if not loc_gds-prt.is-term then do:
                message
                "Признак" loc_gds-prt.f-name "нетерминальный" skip
                view-as alert-box Warning.
              end.

            find first loc_bar-code where
                  loc_bar-code.node-code = ub.gds-prt.node-code AND
                  loc_bar-code.gds-code = buf_goods.gds-code AND
                  loc_bar-code.in-code = "" AND
                  loc_bar-code.part-code = ""  AND
                  loc_bar-code.unit-cli = buf_goods.unit-base NO-LOCK .
            find first root_bar-code No-LOCK where
                    root_bar-code.gds-code = loc_bar-code.gds-code AND
                    root_bar-code.unit-cli = loc_bar-code.unit-cli AND
                    root_bar-code.in-code   = "" AND
                    root_bar-code.part-code = "" AND
                    root_bar-code.node-code  = loc_gds-prt.node-code no-error.
            if AVAIl root_bar-code then do:
                v-src = string(root_bar-code.b-code).
            end.
            else do:
              message
              "Отсутствует бар-код для признака" loc_gds-prt.f-name
              view-as alert-box WARNING.
              return.
            end.
          end.  /* end sel-node <> ?*/
          else return.   /*Если ничего не выбрали выходим из процедуры*/
        end.  /*  end gds-prt.node-name <> {&empty-scale}*/
        else do:
          assign
          v-src = STRING(buf_goods.gds-code)
          .
        end.
      end.  /* end v-doc-prt*/
      else do:
        assign
        v-src = STRING(buf_goods.gds-code)
        .
      end.
      case p-cd-mode:
        when {&cd-mode-sale}
        or
        when {&cd-mode-ret}
        or
        when {&cd-mode-inv}
        then do:
          case p-cd-submode:
            when {&cd-submode-find-gds} then do:
              run input-find-str in this-procedure (
                                                    input-output p-cd-mode
                                                   ,input-output p-cd-submode
                                                   ,output p-message
                                                   ,output p-ok
                                                   ).
            end.
            otherwise do:
              run set-input-time in this-procedure ( input -1, output p-message, output p-ok ).

              run add-gds-line in this-procedure (input-output p-cd-mode, input-output p-cd-submode, output p-message, output p-ok).
            end.
          end  case. /*case p-cd-submode:*/
        end. /*when {&cd-mode-sale}*/
        otherwise do:
          /*todo*/
        end.
      end case. /*      case p-cd-mode:*/
    end. /*if available buf_goods then do:*/
  end. /*  DO v-count = 1 TO NUM-ENTRIES(v-ref-list)*/
end. /*else if v-gds then do:*/

end. /* do on error */
end procedure. /* 1978 */



/*==========================================================================*/
procedure card-select :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_dis-card    for ub.dis-card .
define variable v-ref-list    as character    no-undo.
define variable v-count      as integer      no-undo.

do
on error undo, return error
:
   run ref/discards.w
      ( parParentProc
      , "b-sel"
      , {&all}
      , v-cntxt-host-code-obj
      , v-cntxt-obj-type
      , v-cntxt-obj-code
      , ?
      , ?
      , output v-ref-list
      ) .


   if v-ref-list = ""
   then do:
      return.
   end.

   DO v-count = 1 TO NUM-ENTRIES(v-ref-list)
   on error undo, next
   :
      find first buf_dis-card
         where recid( buf_dis-card ) = INTEGER(ENTRY(v-count, v-ref-list))
         NO-LOCK
         no-error.
      if available buf_dis-card then do:
         assign
            v-src = STRING(buf_dis-card.d-card)
         .
         run input-card in this-procedure (input-output p-cd-mode, input-output p-cd-submode, output p-message, output p-ok).
      end.
   end.


end. /* do on error */
end procedure. /* card-select */




/*==========================================================================*/
procedure saller-select :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_staff    for ub.staff .
define variable v-ref-list    as character    no-undo.
define variable v-count      as integer      no-undo.

do
on error undo, return error
:
   run ref/staffs.w
      ( parParentProc
      , "b-sel"
      , {&role-seller}
      , v-cntxt-db-num
      , 0
      , output v-ref-list
      ) .


   if v-ref-list = ""
   then do:
      return.
   end.

   DO v-count = 1 TO NUM-ENTRIES(v-ref-list)
   on error undo, next
   :
      find first buf_staff
         where recid( buf_staff ) = INTEGER(ENTRY(v-count, v-ref-list))
         NO-LOCK
         no-error.
      if available buf_staff then do:
         assign
            v-src = STRING(buf_staff.staff-code)
         .
         run input-saller in this-procedure (input-output p-cd-mode, input-output p-cd-submode, output p-message, output p-ok).
      end.
   end.


end. /* do on error */
end procedure. /* saller-select */




/*==========================================================================*/
procedure 1986 : /* Возврат по продаже */
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_chk-doc        for ub.chk-doc .
define buffer buf_chk-gds        for ub.chk-gds .
define buffer buf_tt-line        for tt-line .
define buffer buf_tt-open-check  for tt-open-check .

define variable v-doc-code-list    as character    no-undo.
define variable v-rid-list    as character    no-undo.

define variable v-b-code        as integer no-undo .
define variable v-chk-name      as character no-undo .
define variable v-second-name   as character no-undo .
define variable v-setted        as logical no-undo .
define variable v-gds-code      as integer no-undo .
define variable v-src-sum       as decimal no-undo .
define variable v-src-sum-netto as decimal no-undo .
define variable v-chk-type      as character    no-undo.
define variable v-chk-list-type    as logical      no-undo.

define variable v-count         as integer      no-undo.
do
on error undo, return error
:
   /* проверить уже,что чеки уже открывались */
   if CAN-find( first buf_tt-open-check where buf_tt-open-check.chk-type = INTEGER({&rcpt-sale}))
   then do:
      assign
         p-message = "Чек возврата уже привязан к чеку продажи"
         p-ok      = TRUE
      .
      return.
   end.
   if CAN-find( first tt-line )
   then do:
      assign
         p-message = "В текущем чеке есть строки, выбрать чек возврата НЕВОЗМОЖНО"
         p-ok      = no
      .
      return.
   end.


   run str/chk-docs.w   ( input parparentproc
                        , input "b-sel"
                        , input {&cd-type-ibs-th}
                        , input ?
                        , input v-cntxt-obj-type
                        , input v-cntxt-obj-code
                        , input '':U
                        , input '':U
                        , input p-cash-num
                        , input ?
                        , input ?
                        , input integer({&rcpt-sale})
                        , output v-rid-list) no-error.

   if v-rid-list = "":U
   then do:
      assign
         p-message = "Отказ от выбора чека"
         p-ok      = TRUE
      .
      return.
   end.

   if p-cd-mode = {&cd-mode-ready}
   then do:
      run 1987 in this-procedure ( INPUt-OUTPUT p-cd-mode
                                 , input-output p-cd-submode
                                 , output p-message
                                 , output p-ok
                                 ) .
   end.

   define buffer buf_rule-call-param   for ub.rule-call-param .

   define variable v-dont-load-lines    as logical      no-undo.

   for each  buf_rule-call-param
         where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
         no-lock
      :
      case buf_rule-call-param.param-name:
         WHEN "p-dont-load-lines"
         then do:
            if buf_rule-call-param.param-value-logical <> ?
            then
            assign
               v-dont-load-lines        = buf_rule-call-param.param-value-logical
            .
         end.
         OTHERWISE DO:
         end.
      end case.
   end.

   /* !!!! */
   if v-dont-load-lines = FALSE then
   _proc-body:
   DO v-count = 1 TO 1 /*NUM-ENTRIES(v-rid-list)*/
   on error undo, NEXT
   :
      find first buf_chk-doc
         where RECID(buf_chk-doc) = INTEGER(ENTRY(v-count, v-rid-list))
         no-lock
         no-error
         no-wait
         .
      /*
      if  not available buf_chk-doc
      and not locked buf_chk-doc
      then do:
         UNDO _proc-body, NEXT _proc-body .
      end.
      if locked buf_chk-doc
      then do:
         UNDO _proc-body, NEXT _proc-body .
      end.
      */

      if  buf_chk-doc.chk-type <> integer({&rcpt-sale})
      then do:
         UNDO _proc-body, NEXT _proc-body .
      end.

      assign
         v-chk-type = {&rcpt-return}
         v-doc-code-list = v-doc-code-list + "," + buf_chk-doc.doc-code
      .

      /*
      if  buf_chk-doc.src-d-card <> ?
      AND buf_chk-doc.src-d-card <> ''
      then do:
         assign
            v-src = buf_chk-doc.src-d-card
         .
         run input-card in this-procedure ( INPUt-OUTPUT p-cd-mode
                                          , INPUt-output p-cd-submode
                                          , output p-message
                                          , output p-ok
                                          ) .
         if not p-ok then do:
            UNDO _proc-body, NEXT _proc-body .
         end.
      end.
      */

      assign
         v-pass-gds = 0 /* integer({&gds-pass-copy}) */
      .

      for each buf_chk-gds
         where buf_chk-gds.doc-code = buf_chk-doc.doc-code
         no-lock
      :
         find first buf_tt-line
              where buf_tt-line.ord-chk-num  = buf_chk-gds.doc-code
                AND buf_tt-line.ord-line-num = buf_chk-gds.line-num
              no-lock no-error.
         if available buf_tt-line then NEXT.

         assign
            v-write-off-code  = 0
            v-src-price       = (buf_chk-gds.price-base - buf_chk-gds.discnt) * ( buf_chk-gds.doc-qnty / buf_chk-gds.src-qnty)
            v-src-discnt      = buf_chk-gds.discnt
            v-src-qnty        = buf_chk-gds.src-qnty
            v-num             = 0
            v-src             = buf_chk-gds.src-code
            v-pump            = buf_chk-gds.pump
            v-nozzle-code     = buf_chk-gds.nozzle-code
            v-pl-code         = buf_chk-gds.pl-code
            v-fbr-depart      = buf_chk-gds.depart-id
            v-ord-chk-num     = buf_chk-gds.doc-code
            v-ord-line-num    = buf_chk-gds.line-num
         .
         run add-gds-line in this-procedure  ( INPUt-OUTPUT p-cd-mode
                                             , INPUt-output p-cd-submode
                                             , output p-message
                                             , output p-ok
                                             ) .
         assign
            v-write-off-code  = 0
            v-src-price       = 0
            v-src-qnty        = 0
            v-num             = 0
            v-src             = "":U
         .
         if not p-ok then do:
            UNDO _proc-body, LEAVE _proc-body .
         end.
         if buf_chk-gds.sales-man > 0
         then do:
            find first buf_tt-line
               where buf_tt-line.ord-chk-num  = buf_chk-gds.doc-code
                  AND buf_tt-line.ord-line-num = buf_chk-gds.line-num
               no-lock
               .
            assign
               v-src = STRING(buf_chk-gds.sales-man)
            .
            run input-saller in this-procedure (input-output p-cd-mode, input-output p-cd-submode, output p-message, output p-ok).
         end.
      end. /* each buf_chk-gds */
      if not CAN-find (first buf_tt-open-check
                       where buf_tt-open-check.doc-code = buf_chk-doc.doc-code
                         AND buf_tt-open-check.chk-type = buf_chk-doc.chk-type
                       )
      then do:
         create buf_tt-open-check.
         assign
            buf_tt-open-check.doc-code = buf_chk-doc.doc-code
            buf_tt-open-check.chk-type = buf_chk-doc.chk-type
         .
         v-aux-mess = substitute("Возврат по чеку: &1", buf_chk-doc.doc-code).
      end.
   end. /* do on error */
   assign
      v-doc-code-list = TRIM( v-doc-code-list , "," )
   .
   { gbl/eventlib-event-log.i
      1
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      v-chk-type
      '':U
      '*':U
      '':U
      v-doc-code-list
      '':U
      TODAY
      61
      TIME
      'U':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      v-rid-list
      v-cntxt-userid
      no-error
   }

   if p-ok
   then do:
      find first buf_tt-line no-lock no-error.
      if available buf_tt-line
      then do:
         assign
            v-curr-num-0  = buf_tt-line.num
            v-curr-type-0 = buf_tt-line.type
         .
      end.
   end.
   else do:
      for each buf_tt-open-check
         :
         DELETE buf_tt-open-check.
      end.
   end.

end. /* do on error */
end procedure. /* 1986 */




/*==========================================================================*/
procedure 1990 :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define variable v-chk-fr-num    as character    no-undo.
define variable v-doc-code      as character no-undo .

do
on error undo, return error
:
   run adm/chk-pass.w   ( input parparentproc
                        , input v-cntxt-userid
                        , input v-cntxt-db-num
                        , input "actn_ibsthpos-add-rep"
                        , input FALSE
                        , output p-message
                        , output p-ok
                        ) .
   if not p-ok
   then return.

   if not v-emul-mode
      then do:
      { gbl/fr-x-rep.i
         p-message
         p-ok
         no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         return.
      end.
   end.
   else do:
      assign
         p-ok = TRUE
      .
   end.
   { gbl/eventlib-event-log.i
      1
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      '':U
      '':U
      '*':U
      '':U
      '':U
      '':U
      TODAY
      77
      TIME
      'U':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      0
      v-cntxt-userid
      no-error
   }

end. /* do on error */
end procedure. /* 1990 */


/*==========================================================================*/
procedure set-emul-mode :
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   assign
      v-emul-mode = TRUE
      p-ok        = TRUE
   .

end. /* do on error */
end procedure. /* set-emul-mode */





/*==========================================================================*/
procedure pay-select :
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define variable v-ref-list    as character    no-undo.

define buffer buf_cash-pay    for ub.cash-pay .

do
on error undo, return error
:
   run ref/cashpays.w   ( input parparentproc
                        , input "b-sel":U
                        , input {&all}
                        , input v-cntxt-host-code-obj
                        , input v-cntxt-obj-type
                        , input v-cntxt-obj-code
                        , output v-ref-list
                        ) .

   if v-ref-list = ""
   then do:
      return.
   end.

   find first buf_cash-pay
        where recid( buf_cash-pay ) = INTEGER(ENTRY(1, v-ref-list))
        NO-LOCK
        no-error
        .
   if available buf_cash-pay then do:
      assign
         v-pay-type        = buf_cash-pay.cdpay-code
         v-curr-base-code  = buf_cash-pay.curr-code
         p-message         = buf_cash-pay.obj-name
         p-ok              = TRUE
      .
      /*
      run summ-for-pay  ( INPUt-OUTPUT p-cd-mode
                        , INPUt-output p-cd-submode
                        , output p-message
                        , output p-ok
                        ) .
      */
   end.

end. /* do on error */
end procedure. /* pay-select */



/*==========================================================================*/
procedure set-cd-base-code :
define input parameter p-base-code as integer          no-undo.
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_currency    for ub.currency .

do
on error undo, return error
:
   find first buf_currency
         where buf_currency.curr-code = p-base-code
         no-lock
         no-error
         .
   if not available buf_currency
   then do:
      assign
         p-ok             = TRUE
         p-message = substitute("Не найдена базовая валюта &1", p-base-code)
      .
      return.
   end.

   assign
      v-cd-base-name   = buf_currency.curr-abbr
      v-cd-base-code   = p-base-code
      v-curr-base-code = p-base-code
      p-ok             = TRUE
   .

end. /* do on error */
end procedure. /* set-curr-base-code */




/*==========================================================================*/
procedure input-find-str :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .
define variable v-search-code    as integer      no-undo.

do
on error undo, return error
:
   /*
   assign
      v-search-code = INTEGER(v-src)
      no-error
   .
   if error-status:error
   then do:
      assign
         p-message = substitute("Код для поиска должен быть числом.")
         p-ok = FALSE
      .
      return.
   end.
   */
   find first buf_tt-head-check.
   { gbl/eventlib-event-log.i
      2
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      buf_tt-head-check.chk-type
      '':U
      v-src
      '':U
      buf_tt-head-check.doc-code
      '':U
      TODAY
      48
      TIME
      'U':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      v-src
      0
      v-cntxt-userid
      no-error
   }

   if v-found-str <> v-src
   then do:
      assign
         v-found-num  = 0
      .
   end.

   assign
      v-found-str = v-src
   .

   find first buf_tt-line
        where buf_tt-line.type = 0
          AND buf_tt-line.src  = v-found-str
          AND buf_tt-line.num  > v-found-num
        NO-LOCK
        no-error
        .

   if not available buf_tt-line
   then do:
      if v-found-num > 0
      then do:
         assign
            v-found-num  = 0
         .
         find first buf_tt-line
            where buf_tt-line.type = 0
               AND buf_tt-line.src  = v-found-str
               AND buf_tt-line.num  > v-found-num
            NO-LOCK
            no-error
            .
      end.
      else do:
         assign
            p-message    = "По запросу ничего не найдено."
            p-cd-submode = {&cd-submode-goods}
            v-found-num  = 0
            p-ok         = FALSE
         .
         return.
      end.
   end.



   assign
      v-curr-num-0   = buf_tt-line.num
      v-found-num    = buf_tt-line.num
      v-curr-type-0  = 0
      p-cd-submode = {&cd-submode-goods}
      p-ok         = TRUE
   .

end. /* do on error */
end procedure. /* input-find-str */




/*==========================================================================*/
procedure chk-inv-open :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   run clear-tt-chk in this-procedure.

   run chk-open   ( input integer({&rcpt-inventory})
                  , INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output p-message
                  , output p-ok
                  ) .
   if p-ok
   then do:
      assign
         p-message    = "Инвентаризация"
         p-cd-mode    = {&cd-mode-sale}
         p-cd-submode = {&cd-submode-goods}
      .
   end.

end. /* do on error */
end procedure. /* chk-inv-open */




/*==========================================================================*/
procedure chk-inc-open :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   { gbl/eventlib-event-log.i
      0
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      '':U
      '':U
      '*':U
      '':U
      '':U
      '':U
      TODAY
      84
      TIME
      'U':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      0
      v-cntxt-userid
      no-error
   }

   run clear-tt-chk in this-procedure.

   run chk-open   ( input integer({&encashment})
                  , INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output p-message
                  , output p-ok
                  ) .
   if p-ok
   then do:
        &scop receipt-code {&encashment}
        v-aux-mess =  {&receipt-name}.

      assign
         p-message    = "Инкассация"
         p-cd-mode    = {&cd-mode-wth}
         p-cd-submode = {&cd-submode-pay}
      .
   end.

end. /* do on error */
end procedure. /* chk-inc-open */




/*==========================================================================*/
procedure chk-fnd-open :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   { gbl/eventlib-event-log.i
      0
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      '':U
      '':U
      '*':U
      '':U
      '':U
      '':U
      TODAY
      87
      TIME
      'U':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      0
      v-cntxt-userid
      no-error
   }

   run clear-tt-chk in this-procedure.

   run chk-open   ( input integer({&cd-fund})
                  , INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output p-message
                  , output p-ok
                  ) .
   if p-ok
   then do:
        &scop receipt-code {&cd-fund}
        v-aux-mess =  {&receipt-name}.

      assign
         p-message    = "Кассовый фонд"
         p-cd-mode    = {&cd-mode-wth}
         p-cd-submode = {&cd-submode-pay}
      .
   end.

end. /* do on error */
end procedure. /* chk-fnd-open */



/*==========================================================================*/
procedure 1999 :  /* Чеки МЦ */
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   assign
      p-cd-mode     = {&cd-mode-wth}
      p-cd-submode  = {&cd-submode-goods}
      p-ok          = TRUE
   .
   case p-cd-mode:
      WHEN {&cd-mode-ready}
      /*
      then do:
         assign
            p-cd-mode     = {&cd-mode-wth}
            p-cd-submode  = {&cd-submode-goods}
            p-ok          = TRUE
         .
      end.
      */ OR
      WHEN {&cd-mode-wth}
      then do:
         define buffer buf_rule-call-param   for ub.rule-call-param .

         define variable v-type     as logical      no-undo.
         define variable v-chk-type as integer      no-undo.


         for each  buf_rule-call-param
               where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
               no-lock
            :
            case buf_rule-call-param.param-name:
               WHEN "p-chk-type"
               then do:
                  if  buf_rule-call-param.param-value-integer <> 0
                  AND buf_rule-call-param.param-value-integer <> ?
                  then
                  assign
                     v-chk-type  = buf_rule-call-param.param-value-integer
                     v-type      = TRUE
                  .
               end.
               OTHERWISE DO:
               end.
            end case.
         end.
         if v-type
         then do:

            if v-cash-drawer-plug
            then do:
               run 1988 in this-procedure ( INPUt-OUTPUT p-cd-mode
                                          , INPUt-output p-cd-submode
                                          , output p-message
                                          , output p-ok
                                          ) .
            end.
            case v-chk-type:
               WHEN INTEGER({&cd-fund})
               then do:
                  run chk-fnd-open  ( INPUt-OUTPUT p-cd-mode
                                    , INPUt-output p-cd-submode
                                    , output p-message
                                    , output p-ok
                                    ) .
               end.
               WHEN INTEGER({&encashment})
               then do:
                  run chk-inc-open  ( INPUt-OUTPUT p-cd-mode
                                    , INPUt-output p-cd-submode
                                    , output p-message
                                    , output p-ok
                                    ) .
               end.
               OTHERWISE DO:
                 &scop receipt-code string(v-chk-type)
                 message
                 substitute("К сожалению, в настоящий момент работа с чеком типа &1 НЕ РЕАЛИЗОВАНА", {&receipt-name})
                 view-as alert-box error .
               end.
            end case.
         end.
         else do:
            assign
               p-message = "Укажите тип чека МЦ"
            .
            return.
         end.
      end.
      OTHERWISE DO:
      end.
   end case.
end. /* do on error */
end procedure. /* 1999 */



/*==========================================================================*/
procedure input-summ :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_tt-head-check     for tt-head-check .

define variable v-pline-num as integer no-undo .
define variable v-pass-pay as integer no-undo .
define variable v-pay-card as character no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-tot-rubl as decimal no-undo .
define variable v-tot-base as decimal no-undo .
define variable v-2-cdpay-code as integer no-undo .
define variable v-2-curr-code as integer no-undo .
define variable v-2-tot-base as decimal no-undo .
define variable v-2-tot-rubl as decimal no-undo .
define variable v-frpay-code as integer no-undo .
define variable v-2-frpay-code as integer no-undo .
define variable v-msg    as character    no-undo.

do
on error undo, return error
:
   if DECIMAL(v-src) < 0
   then do:
      assign
         p-message = "Сумма должна быть не меньше нуля"
         p-ok      = FALSE
      .
      return.
   end.

   run input-pay-sale in this-procedure ( input-output p-cd-mode
                                       , input-output p-cd-submode
                                       , output p-message
                                       , output p-ok
                                       ) no-error.
   if error-status:error
   OR not p-ok
   then do:
      assign
         p-message = substitute("pay &1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      return.
   end.

   assign
      v-msg = p-message
   .

   run 1982 in this-procedure ( input-output p-cd-mode
                              , input-output p-cd-submode
                              , output p-message
                              , output p-ok
                              ) no-error.
   if error-status:error
   OR not p-ok
   then do:
      assign
         p-message = substitute("cl &1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      return.
   end.

   assign
      p-message     = v-msg
      p-cd-mode     = {&cd-mode-ready}
      p-cd-submode  = {&cd-submode-goods}
      /*
      p-message     = chr(10)
      */
      p-ok          = TRUE
   .

end. /* do on error */
end procedure. /* input-summ */


/*==========================================================================*/
procedure 1988 : /* открыть ДЯ */
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_tt-head-check     for tt-head-check .
define variable v-doc-code      as character no-undo .
define variable v-chk-type    as integer      no-undo.

do
on error undo, return error
:
   if not v-emul-mode
   then do:
      { gbl/fr-draop.i
         p-message
         p-ok
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         return.
      end.

      find first buf_tt-head-check no-error.
      if available buf_tt-head-check
      then do:
         assign
            v-doc-code = buf_tt-head-check.doc-code
            v-chk-type = buf_tt-head-check.chk-type
         .
      end.
      { gbl/eventlib-event-log.i
         1
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         v-chk-type
         '':U
         '*':U
         '':U
         v-doc-code
         '':U
         TODAY
         62
         TIME
         'U':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }

   end.
   else do:
      assign
         p-ok = TRUE
      .
   end.
end. /* do on error */
end procedure. /* 1988 */




/*==========================================================================*/
procedure 2003 :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

do
on error undo, return
:
   { gbl/eventlib-event-log.i
      2
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      0
      '':U
      '*':U
      '':U
      '':U
      '':U
      TODAY
      76
      TIME
      'U':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      v-src
      0
      v-cntxt-userid
      no-error
   }

   run str/stockscr.w ( v-cntxt-userid ) no-error.

   assign
      p-ok = TRUE
   .
end. /* do on error */
end procedure. /* 2003 */


/*==========================================================================*/
procedure pay-fix-summ :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   assign
      v-src = STRING(v-fix-summ-pay)
   .
   run input-pay-sale  ( INPUt-OUTPUT p-cd-mode
                     , INPUt-output p-cd-submode
                     , output p-message
                     , output p-ok
                     ) .

end. /* do on error */
end procedure. /* pay-fix-summ */


/*==========================================================================*/
procedure 1995 : /* наличность в ДЯ */
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define variable v-integer   as integer      no-undo.
define variable v-character as character    no-undo.
define variable v-decimal   as decimal      no-undo.
define variable v-logical   as logical      no-undo.
define variable v-handle as handle no-undo .
define variable v-date    as date         no-undo.
define variable v-data-type    as character    no-undo.
define variable v-setted as logical   no-undo .

do
on error undo, return error
:

   { str/libthpos_get-context-property.i
      {&context}
      'cash-counter'
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-handle
      v-data-type
      v-setted
      no-error
   }
   { gbl/eventlib-event-log.i
      1
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      '':U
      '':U
      '*':U
      '':U
      '':U
      '':U
      TODAY
      75
      TIME
      'U':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      v-decimal
      v-cntxt-userid
      no-error
   }

   message
      "Наличность в денежном ящике:"
      skip v-decimal
      skip "Предел наличности в денежном ящике:"
      skip v-cash-drawer-limit
   view-as alert-box information.
   assign
      p-ok = TRUE
   .

end. /* do on error */
end procedure. /* 1995 */




/*==========================================================================*/
procedure input-discont :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define buffer buf_tt-head-check     for tt-head-check .
define variable v-next    as character    no-undo.

define variable v-st-r-b as decimal no-undo .
define variable v-st-rubl as decimal no-undo .
define variable v-st-base as decimal no-undo .
define variable v-tot-doc as decimal no-undo .
define variable v-netto as decimal no-undo .
define variable v-netto-rubl as decimal no-undo .
define variable v-netto-base as decimal no-undo .
define variable v-all-discnt as decimal no-undo .
define variable v-all-discnt-rubl as decimal no-undo .
define variable v-all-discnt-base as decimal no-undo .


define variable v-type-name    as character    no-undo.
define variable v-obj-name     as character    no-undo.
define variable v-end          as character    no-undo.
define variable v-local-src    as character    no-undo.
define variable v-dsk    as character    no-undo.

do
on error undo, return error
:
   case v-disc-type:
      WHEN {&discnt-v-sum}
      then do:
         assign
            v-type-name = "Абсолютная"
            v-end       = "":U
         .
      end.
      WHEN {&discnt-v-pcnt}
      then do:
         assign
            v-type-name = "Процентная"
            v-end       = "%":U
         .
      end.
      OTHERWISE DO:
      end.
   end case.
   assign
      v-local-src = v-src
      v-dsk       = v-disc-type + " " + v-src
   .

   find buf_tt-head-check.

   case p-cd-submode:
      WHEN {&cd-submode-tot-dsc}
      then do:
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            buf_tt-head-check.chk-type
            '':U
            '*':U
            v-dsk
            buf_tt-head-check.doc-code
            '':U
            TODAY
            45
            TIME
            'U':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }

         { str/libthpos_sub-total.i
            buf_tt-head-check.doc-code
            ''
            p-ok
            v-st-r-b
            v-st-rubl
            v-st-base
            v-tot-doc
            v-discnt-chk
            v-netto
            v-netto-rubl
            v-netto-base
            v-all-discnt
            v-all-discnt-rubl
            v-all-discnt-base
            no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               buf_tt-head-check.chk-type
               '':U
               p-message
               v-dsk
               buf_tt-head-check.doc-code
               '':U
               TODAY
               47
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }

            return.
         end.

         { str/libthpos_set-subtotal-manual-discnt.i
            buf_tt-head-check.doc-code
            INTEGER(v-disc-type)
            DECIMAL(v-src)
            p-ok
            v-next
            v-st-r-b
            v-st-rubl
            v-st-base
            v-tot-doc
            v-discnt-chk
         no-error
         }
         if error-status:error
         then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               buf_tt-head-check.chk-type
               '':U
               p-message
               v-dsk
               buf_tt-head-check.doc-code
               '':U
               TODAY
               47
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            buf_tt-head-check.chk-type
            '':U
            '*':U
            v-dsk
            buf_tt-head-check.doc-code
            '':U
            TODAY
            46
            TIME
            'S':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            v-discnt-chk
            v-cntxt-userid
            no-error
         }

         assign
            v-obj-name = "на итог"
            buf_tt-head-check.hand-discounted = v-disc-type
         .
      end.
      WHEN {&cd-submode-line-dsc}
      then do:
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            p-cash-num
            {&md}
            buf_tt-head-check.chk-type
            '':U
            '*':U
            v-dsk
            buf_tt-head-check.doc-code
            bufbr_tt-line.qnty
            TODAY
            42
            TIME
            'U':U
            bufbr_tt-line.line-code
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            v-src
            bufbr_tt-line.summ-netto
            v-cntxt-userid
            no-error
         }

         if not available bufbr_tt-line
         then do:
            assign
               p-message = "Чек пуст"
               p-ok      = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               buf_tt-head-check.chk-type
               '':U
               p-message
               v-dsk
               buf_tt-head-check.doc-code
               0
               TODAY
               43
               TIME
               'S':U
               '':U
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               v-src
               0
               v-cntxt-userid
               no-error
            }
           return .
         end.
         if bufbr_tt-line.type <> 0
         then do:
            assign
               p-message = "Скидка устанавливается только на товарную строку"
               p-ok      = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               buf_tt-head-check.chk-type
               '':U
               p-message
               v-dsk
               buf_tt-head-check.doc-code
               0
               TODAY
               43
               TIME
               'S':U
               '':U
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               v-src
               0
               v-cntxt-userid
               no-error
            }
            return .
         end.

         { str/libthpos_set-gds-manual-discnt.i
            buf_tt-head-check.doc-code
            bufbr_tt-line.num
            INTEGER(v-disc-type)
            DECIMAL(v-src)
            p-ok
            v-next
            bufbr_tt-line.summ-discont
            bufbr_tt-line.summ-brutto
            bufbr_tt-line.summ-netto
            no-error
         }
         if error-status:error
         then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               p-cash-num
               {&md}
               buf_tt-head-check.chk-type
               '':U
               p-message
               v-dsk
               buf_tt-head-check.doc-code
               bufbr_tt-line.qnty
               TODAY
               43
               TIME
               'S':U
               bufbr_tt-line.line-code
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               v-src
               bufbr_tt-line.summ-netto
               v-cntxt-userid
               no-error
            }
            return.
         end.
         assign
            v-obj-name = "на строку"
            bufbr_tt-line.hand-discounted = v-disc-type
         .
      end.
      OTHERWISE DO:
      end.
   end case.
   { gbl/eventlib-event-log.i
      0
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      buf_tt-head-check.chk-type
      '':U
      p-message
      v-dsk
      buf_tt-head-check.doc-code
      bufbr_tt-line.qnty
      TODAY
      44
      TIME
      'E':U
      bufbr_tt-line.line-code
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      v-src
      bufbr_tt-line.summ-netto
      v-cntxt-userid
      no-error
   }


   /*
   define variable v-num-str    as integer      no-undo.
   define variable v-gds-yes    as integer      no-undo.
   define variable v-pay-yes    as integer      no-undo.
   define variable v-msg    as character    no-undo.
   define variable v-num-local   as integer      no-undo.
   define variable v-type-local  as integer      no-undo.
   if INDEX(v-next, "=") > 0
   AND not v-recalc
   then do:
      assign
         v-recalc  = TRUE
         v-msg     = p-message
         v-next    = TRIM(v-next, "recalc=")
         v-num-str = INTEGER(ENTRY(1, v-next, ","))
         v-gds-yes = INTEGER(ENTRY(2, v-next, ","))
         v-pay-yes = INTEGER(ENTRY(3, v-next, ","))
         v-num-local  = v-curr-num-0
         v-type-local = v-curr-type-0
      .
      run recalc-lines in this-procedure
                     ( input v-num-str
                     , input v-gds-yes
                     , input v-pay-yes
                     , input-output p-cd-mode
                     , INPUt-output p-cd-submode
                     , output p-message
                     , output p-ok
                     ) .
      assign
         v-src            = ""
         v-src-qnty       = 0.0
         v-src-price      = 0.0
         v-src-price-rub  = 0.0
         v-recalc  = FALSE
         p-message = v-msg
         v-curr-num-0     = v-num-local
         v-curr-type-0    = v-type-local
      .
   end.
   */
   define variable v-num-local   as integer      no-undo.
   define variable v-type-local  as integer      no-undo.
   assign
      v-num-local  = v-curr-num-0
      v-type-local = v-curr-type-0
   .

   run refresh-lines in this-procedure
                  ( output p-message
                  , output p-ok
                  ) .
   assign
      v-curr-num-0     = v-num-local
      v-curr-type-0    = v-type-local
      v-src-qnty  = 0
   .

   if p-ok
   then do:
      assign
         p-message = substitute  ( "&1 скидка &2 &3&4"
                                 , v-type-name
                                 , v-obj-name
                                 , v-local-src
                                 , v-end
                                 )
         p-cd-submode = {&cd-submode-goods}
         v-disc-type  = "":U /* {&discnt-v-pcnt} */
      .
   end.

end. /* do on error */
end procedure. /* input-discont */




/*==========================================================================*/
procedure discont-abs :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   assign
      p-message   = "Абсолютная скидка"
      v-disc-type = {&discnt-v-sum}
      p-ok        = TRUE
   .

end. /* do on error */
end procedure. /* discont-abs */




/*==========================================================================*/
procedure discont-per :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

   assign
      p-message   = "Процентная скидка"
      v-disc-type = {&discnt-v-pcnt}
      p-ok        = TRUE
   .

do
on error undo, return error
:

end. /* do on error */
end procedure. /* discont-per */




/*==========================================================================*/
procedure discont-fix :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   assign
      v-src = STRING(v-fix-summ-pay)
   .
   run input-discont  ( input-output p-cd-mode
                     , INPUt-output p-cd-submode
                     , output p-message
                     , output p-ok
                     ) .

end. /* do on error */
end procedure. /* discont-fix-abs */




/*==========================================================================*/
procedure 1980 : /* Скидка на строку */
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define buffer buf_tt-line     for tt-line .

do
on error undo, return error
:
/*   case p-cd-submode:*/
/*      WHEN {&cd-submode-goods}*/
      if  p-cd-submode = {&cd-submode-goods}
      then do:
         if not available bufbr_tt-line
         then do:
            assign
               p-message = "Чек пуст"
               p-ok      = FALSE
            .
            return .
         end.
         if bufbr_tt-line.type <> 0
         then do:
            assign
               p-message = "Скидка устанавливается только на товарную строку"
               p-ok      = FALSE
            .
            return .
         end.

         run adm/chk-pass.w   ( input parparentproc
                              , input v-cntxt-userid
                              , input v-cntxt-db-num
                              , input "actn_ibsthpos-discont"
                              , input FALSE
                              , output p-message
                              , output p-ok
                              ) .
         if CAN-find (first buf_tt-line where buf_tt-line.type = 1 NO-LOCK)
         then do:
            assign
               p-message = "Скидка должна быть задана до принятия платежей"
               p-ok      = FALSE
            .
         end.

         if not p-ok
         then return.
         assign
            p-message   = "Cкидка на товарную строку чека"
            p-cd-submode = {&cd-submode-line-dsc}
            p-ok = TRUE
         .
      end.
      /*WHEN {&cd-submode-line-dsc}*/
      if  p-cd-submode = {&cd-submode-line-dsc}
      then do:
         define buffer buf_rule-call-param   for ub.rule-call-param .
         define buffer buf_cash-pay          for ub.cash-pay .

         define variable v-type    as logical      no-undo.
         define variable v-value    as logical      no-undo.

         for each  buf_rule-call-param
               where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
               no-lock
            :
            case buf_rule-call-param.param-name:
               WHEN "p-discnt-v-type"
               then do:
                  if  buf_rule-call-param.param-value-integer <> 0
                  AND buf_rule-call-param.param-value-integer <> ?
                  then
                  assign
                     v-disc-type       = STRING(buf_rule-call-param.param-value-integer)
                     v-type            = TRUE
                  .
               end.
               WHEN "p-discnt-value"
               then do:
                  if  buf_rule-call-param.param-value-decimal <> 0
                  AND buf_rule-call-param.param-value-decimal <> ?
                  then
                  assign
                     v-src = STRING(buf_rule-call-param.param-value-decimal)
                     v-value = TRUE
                  .
               end.
               OTHERWISE DO:
               end.
            end case.
         end.

         if v-type
         then do:
            if v-value
            then do:
               run input-discont ( INPUt-OUTPUT p-cd-mode
                                 , INPUt-output p-cd-submode
                                 , output p-message
                                 , output p-ok
                                 ) .
            end.
            else do:
               case v-disc-type:
                  WHEN {&discnt-v-sum}
                  then do:
                     assign
                        p-message = "Абсолютная скидка на товарную строку"
                        p-ok      = TRUE
                     .
                  end.
                  WHEN {&discnt-v-pcnt}
                  then do:
                     assign
                        p-message = "Процентная скидка на товарную строку"
                        p-ok      = TRUE
                     .
                  end.
                  OTHERWISE DO:
                     assign
                        p-message = substitute("Неизвестный тип скидки - &1",v-disc-type)
                     .
                  end.
               end case.
            end.
         end.
         else do:
            assign
               p-message = "Укажите тип скидки на товарную строку чека"
            .
            return.
         end.
      end.
/*      OTHERWISE DO:*/
/*      end.*/
/*   end case.*/
end. /* do on error */
end procedure. /* 1980 */



/*==========================================================================*/
procedure recalc-lines :
define input         parameter p-start-line as integer          no-undo.
define input         parameter p-st as integer          no-undo.
define input         parameter p-pay as integer          no-undo.
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.

define buffer buf_tt-line     for tt-line .

do
on error undo, return error
:
   for each  buf_tt-line
       where buf_tt-line.type =  0
         AND buf_tt-line.num  >= p-start-line
       NO-LOCK
       :
       assign
         v-src = STRING(buf_tt-line.qnty)
         v-curr-num-0  = buf_tt-line.num
         v-curr-type-0 = buf_tt-line.type
       .
       run upd-line in this-procedure
                     ( input-output p-cd-mode
                     , INPUt-output p-cd-submode
                     , output p-message
                     , output p-ok
                     ) .

   end.
   run set-all-summ ( output p-message
                      , output p-ok
                      ) .

   if p-pay > 0
   then do:
      for each  buf_tt-line
         where buf_tt-line.type =  1
         NO-LOCK
         :
         assign
            v-src         = STRING(buf_tt-line.line-name-2)
            v-curr-num-0  = buf_tt-line.num
            v-curr-type-0 = buf_tt-line.type
         .
         run upd-line in this-procedure
                        ( input-output p-cd-mode
                        , INPUt-output p-cd-submode
                        , output p-message
                        , output p-ok
                        ) .
         assign
            v-src         = ""
         .
      end.
   end.
   if p-st > 0
   then do:
      run set-all-summ ( output p-message
                       , output p-ok
                       ) .
   end.




end. /* do on error */
end procedure. /* recalc-line */


/*==========================================================================*/
procedure refresh-lines :
/*
define input         parameter p-start-line as integer          no-undo.
define input         parameter p-st as integer          no-undo.
define input         parameter p-pay as integer          no-undo.
define input-output  parameter p-cd-mode     as character          no-undo.
define input-output  parameter p-cd-submode  as character          no-undo.
*/
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.

define buffer buf_tt-line     for tt-line .

do
on error undo, return error
:
   for each  buf_tt-line
       where buf_tt-line.type =  0
         /*
         AND buf_tt-line.num  >= p-start-line
         */
       NO-LOCK
       :
       assign
         v-curr-num-0  = buf_tt-line.num
         v-curr-type-0 = buf_tt-line.type
       .
       run refresh-gds-line in this-procedure ( output p-message
                                              , output p-ok
                                              ) .

   end.

   /* !!!
   if p-pay > 0
   then do:
      for each  buf_tt-line
         where buf_tt-line.type =  1
         NO-LOCK
         :
         assign
            v-src         = STRING(buf_tt-line.line-name-2)
            v-curr-num-0  = buf_tt-line.num
            v-curr-type-0 = buf_tt-line.type
         .
         run upd-line in this-procedure
                        ( input-output p-cd-mode
                        , INPUt-output p-cd-submode
                        , output p-message
                        , output p-ok
                        ) .
         assign
            v-src         = ""
         .
      end.
   end.

   if p-st > 0
   then do:
   end.
   */
      run set-all-summ ( output p-message
                       , output p-ok
                       ) .

end. /* do on error */
end procedure. /* refresh-lines */


/*==========================================================================*/
procedure refresh-gds-line :
define output        parameter p-message     as character      no-undo .
define output        parameter p-ok          as logical          no-undo.

define buffer buf_tt-line     for tt-line .
define buffer buf_tt-head-check     for tt-head-check .

define variable v-b-code          as integer no-undo .
define variable v-gds-code        as integer no-undo .
define variable v-chk-name        as character no-undo .
define variable v-second-name     as character no-undo .
define variable v-src-sum         as decimal no-undo .
define variable v-src-sum-netto   as decimal no-undo .
define variable v-next    as character    no-undo.
define variable v-qnty-old    as decimal      no-undo.
define variable v-src-discnt-local    as decimal      no-undo.
define variable v-src-discnt-local-rub    as decimal      no-undo.
define variable v-for-discnt-local-doc    as decimal no-undo .
define variable v-for-discnt-local-rubl   as decimal no-undo .
define variable v-for-discnt-local-r-b    as decimal no-undo .

do
on error undo, return error
:
   if  v-curr-num-0 <> 0
   then do:
      find buf_tt-head-check.
      find first buf_tt-line
         where buf_tt-line.num  = v-curr-num-0
           and buf_tt-line.type = v-curr-type-0
         no-lock
         .

      case buf_tt-line.type:
         WHEN 0 then do:
            define variable v-qqq    as decimal      no-undo.
            assign
               v-pump            = 0
               v-nozzle-code     = 0
               v-pl-code         = 0
               v-pass-gds        = 0
               v-fbr-depart      = 0
               v-src-price       = buf_tt-line.price-rub
               v-src-qnty        = if buf_tt-head-check.chk-type = INTEGER({&rcpt-return}) then - buf_tt-line.qnty else buf_tt-line.qnty
               v-write-off-code  = 0
               v-src             = buf_tt-line.src
            .
            { str/libthpos_gds-line.i
               buf_tt-head-check.doc-code
               v-curr-num-0
               {&lookup}
               0
               buf_tt-line.src
               v-src-qnty
               v-pump
               v-nozzle-code
               v-pl-code
               v-pass-gds
               v-write-off-code
               v-fbr-depart
               p-ok
               v-next
               v-b-code
               v-gds-code
               v-chk-name
               v-second-name
               v-src-price
               v-src-price-rub
               v-src-discnt
               v-src-discnt-rub
               v-src-sum
               v-src-sum-rub
               v-src-sum-netto
               v-src-sum-netto-rub
               v-unit-base
            no-error
            }
            /* 12345 */
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               return.
            end.
            assign
               {&g-buf_tt_line_update}
            .
         end.
         WHEN 1 then do:
            /*
            if v-recalc
            then do:
               define buffer buf_cash-pay    for ub.cash-pay .

               define variable v-mode as character no-undo .
               define variable v-pass-pay as integer no-undo .
               define variable v-pay-card as character no-undo .
               define variable v-tot-sum as decimal no-undo .
               define variable v-tot-rubl as decimal no-undo .
               define variable v-tot-base as decimal no-undo .
               define variable v-par-code as integer  no-undo .
               define variable v-get-qnty-method as character no-undo .
               define variable v-2-cdpay-code as integer no-undo .
               define variable v-2-curr-code as integer no-undo .
               define variable v-2-tot-base as decimal no-undo .
               define variable v-2-tot-rubl as decimal no-undo .
               define variable v-2-frpay-code as integer no-undo .
               assign
                  v-mode      = {&update}
                  v-pass-pay  = 0
                  v-pay-card  = ""
                  v-tot-sum   = 0
                  v-tot-rubl  = 0
                  v-tot-base  = 0
                  v-pay-type  = buf_tt-line.line-code
                  /*
                  v-tot-sum   = if ((p-cd-mode = {&cd-mode-ret}) OR (buf_tt-head-check.chk-type = INTEGER({&encashment}))) then - DECIMAL(v-src) else DECIMAL(v-src) /* !!! валюта*/
                  v-tot-rubl  = if ((p-cd-mode = {&cd-mode-ret}) OR (buf_tt-head-check.chk-type = INTEGER({&encashment}))) then - DECIMAL(v-src) else DECIMAL(v-src) /* !!! валюта*/
                  */
                  v-tot-sum   = if ((p-cd-mode = {&cd-mode-ret}) OR (buf_tt-head-check.chk-type = INTEGER({&encashment}))) then - DECIMAL(buf_tt-line.qnty) else DECIMAL(buf_tt-line.qnty) /* !!! валюта*/
                  v-tot-rubl  = if ((p-cd-mode = {&cd-mode-ret}) OR (buf_tt-head-check.chk-type = INTEGER({&encashment}))) then - DECIMAL(buf_tt-line.summ-netto-rub) else DECIMAL(buf_tt-line.summ-netto-rub) /* !!! валюта*/
                  v-tot-base  = if ((p-cd-mode = {&cd-mode-ret}) OR (buf_tt-head-check.chk-type = INTEGER({&encashment}))) then - DECIMAL(buf_tt-line.summ-netto) else DECIMAL(buf_tt-line.summ-netto) /* !!! валюта*/
               .
               assign
                  v-disp-msg-1 = buf_tt-line.line-name
                  v-disp-msg-2 = substitute  ( "&1 &2"
                                             , if (p-cd-mode = {&cd-mode-ret}) then - buf_tt-line.summ-netto else buf_tt-line.summ-netto
                                             , v-cd-base-name
                                             )
               .
               find first buf_cash-pay
                  where buf_cash-pay.cdpay-code = buf_tt-line.line-code
                     AND buf_cash-pay.curr-code  = buf_tt-line.curr-code
                  NO-LOCK
                  no-error
                  .
               if buf_cash-pay.atr16
               then do:
                  message
                     "Нельзя корректировать строку оплаты банковской картой."
                     skip
                  view-as alert-box error.
               end.
               else do:
                  if p-cd-mode = {&cd-mode-wth}
                  then do:
                     { str/libthpos_inst-line.i
                        buf_tt-head-check.doc-code
                        buf_tt-line.num
                        v-mode
                        buf_tt-line.line-code
                        v-curr-base-code
                        v-par-code
                        v-src-qnty
                        v-frpay-code
                        v-pass-pay
                        v-pay-card
                        v-tot-sum
                        v-tot-rubl
                        v-tot-base
                        v-get-qnty-method
                        p-ok
                        no-error
                     }
                     if error-status:error
                     then do:
                        assign
                           p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                           p-ok = FALSE
                        .
                        return.
                     end.
                  end.
                  else do:
                     { str/libthpos_pay-line.i
                        buf_tt-head-check.doc-code
                        buf_tt-line.num
                        v-mode
                        buf_tt-line.line-code
                        buf_tt-line.curr-code
                        v-par-code
                        v-src-qnty
                        v-frpay-code
                        v-pass-pay
                        buf_tt-line.pay-card
                        v-tot-sum
                        v-tot-rubl
                        v-tot-base
                        v-get-qnty-method
                        v-2-cdpay-code
                        v-2-curr-code
                        v-2-frpay-code
                        v-2-tot-sum
                        v-2-tot-rubl
                        v-2-tot-base
                        v-src-discnt-local
                        v-src-discnt-local-rub
                        v-for-discnt-local-doc
                        v-for-discnt-local-rubl
                        v-for-discnt-local-r-b
                        p-ok
                        no-error
                     }
                     if error-status:error
                     then do:
                        assign
                           p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                           p-ok = FALSE
                        .
                        return.
                     end.
                  end.
                  assign
                     buf_tt-line.summ-netto-rub    = ABSOLUTE(v-tot-rubl)
                     buf_tt-line.summ-netto        = ABSOLUTE(v-tot-base)
                     buf_tt-line.summ-discont      = v-src-discnt-local
                     buf_tt-line.summ-discont-rub  = v-src-discnt-local-rub
                     /*
                     buf_tt-line.qnty-str          = STRING(v-tot-sum)
                     */
                     p-message                = substitute  ( "&1 &2"
                                                            , buf_tt-line.line-name
                                                            , if p-cd-mode = {&cd-mode-ret} then - v-src-qnty else v-src-qnty
                                                            )
                     v-src        = ""
                     v-src-qnty   = 0.0
                     v-src-price  = 0.0
                     v-src-price-rub  = 0.0
                  .
               end.
               RELEASE buf_cash-pay.
            end.
            else do:
               assign
                  p-message = "Запрещена коррекция строк оплаты. Используйте удаление."
               .
            end.
            */
         end.
         OTHERWISE DO:
         end.
      end case.
   end.
   assign
      p-ok         = TRUE
   .

end. /* do on error */
end procedure. /* refresh-gds-line */


{ str/prep-lay.i 0 def-proc }

/*==========================================================================*/
procedure set-cd-prop :
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.

define variable v-character   as character no-undo .
define variable v-date        as date no-undo .
define variable v-decimal     as decimal no-undo .
define variable v-integer     as integer no-undo .
define variable v-logical     as logical no-undo .
define variable v-data-type   as character no-undo .
define variable v-code        as character    no-undo.
define variable v-upper-code  as character    no-undo.
define variable v-count    as integer      no-undo.
define variable v-no-error    as logical      no-undo.
define variable v-handle as handle no-undo .

do
on error undo, return error
:

   /****************** Параметры настройки устройств **************************/
   assign
      v-upper-code = {&cda-ibs-th_devices}
   .


   /* Подключать денежный ящик */
   assign
      v-code       = {&cda-ibs-th_devices_cash-drawer-plug}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-cash-drawer-plug = logical(v-integer)
   .

   assign
      v-code       = {&cda-ibs-th_devices_cash-drawer-plug-type}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-cash-drawer-plug-type = v-integer
   .

   /* Порт подключения ДЯ */
   assign
      v-code       = {&cda-ibs-th_devices_cash-drawer-plug-port}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-cash-drawer-plug-port = v-integer
   .

   /* Количество импульсов включения денежного ящика */
   assign
      v-code       = {&cda-ibs-th_devices_cash-drawer-plug-imp}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-cash-drawer-plug-imp = v-integer
   .

   /* Разрешить работать с открытым ДЯ */
   assign
      v-code       = {&cda-ibs-th_devices_cash-drawer-open}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-cash-drawer-open = logical(v-integer)
   .

   /* Предел наличности ДЯ */
   assign
      v-code       = {&cda-ibs-th_devices_cash-drawer-limit}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-cash-drawer-limit = v-decimal
   .

   /* Система безнал.платежей */
   assign
      v-code       = {&cda-ibs-th_devices_cashless-system}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-cashless-system = v-character
   .


   /* Подключать считыватель магнитных карт */
   assign
      v-code       = {&cda-ibs-th_devices_card-reader-plug}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-card-reader-plug = logical(v-integer)
   .

   /* Подключать дисплей покупател */
   assign
      v-code       = {&cda-ibs-th_devices_customer-display-plug}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-customer-display-plug = logical(v-integer)
   .

   /* Текст рекламы на дисплее покупателЯ */
   assign
      v-code       = {&cda-ibs-th_devices_customer-display-adv}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }

   assign
      v-customer-display-adv = v-character
   .
   /*
   DO v-count = 1 TO NUM-ENTRIES(v-character, {&delim-par}) :
      assign
         v-customer-display-adv[v-count] = entry(v-count, v-character, {&delim-par})
      .
   end.
   */

   /* Тип клавиатуры */
   assign
      v-code       = {&cda-ibs-th_devices_keyboard-type}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-keyboard-type = v-character
   .

   assign
      v-code       = {&cda-ibs-th_devices_keyboard-layout-id}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-keyboard-layout-id = v-character
   .


   /* Тип дисплея покупател  */
   assign
      v-code       = {&cda-ibs-th_devices_customer-display-type}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-customer-display-type = v-character
   .

   /* Порт дисплея покупател  */
   assign
      v-code       = {&cda-ibs-th_devices_customer-display-port}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-customer-display-port = v-character
   .




   /****************** Настройки Штрих-ФР **************************/
   assign
      v-upper-code = {&cda-ibs-th_fisreg}
   .
   /* Логический уровень датчика ДЯ в открытом состоянии */
   assign
      v-code       = {&cda-ibs-th_fisreg_cash-drawer-level}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-cash-drawer-level = v-integer
   .

   /* Таблица соответствия кодов оплаты ФР и типов кассовых платежей ТН */
   assign
      v-code       = {&cda-ibs-th_fisreg_cash-pay-list}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-cp-lst
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   /*
   DO v-ii = 1 TO num-entries(p-cp-list, {&delim-par}):
      v-dop1 = ENTRY(v-ii, p-cp-list, {&delim-par}).
      assign
      v-fr-code = INTEGER(ENTRY(1, v-dop1, "="))
      v-cp-list = ENTRY(2, v-dop1, "=")
      no-error.
      if v-fr-code >= 2
      AND v-fr-code <= 4 then do:
         DO v-jj = 1 TO num-entries(v-cp-list, ";"):
         find first buf_temp-cash-pay-list where
                     buf_temp-cash-pay-list.cdpay-code = integer(ENTRY(1, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
               AND buf_temp-cash-pay-list.cdpay-code = integer(ENTRY(2, ENTRY(v-jj, v-cp-list, ";"), chr(58))) no-error.
         if not available buf_temp-cash-pay-list then do:
            CREATE buf_temp-cash-pay-list.
            assign
            buf_temp-cash-pay-list.cdpay-code = integer(ENTRY(1, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
            buf_temp-cash-pay-list.curr-code = integer(ENTRY(2, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
            buf_temp-cash-pay-list.frpay-code = v-fr-code
            .
         end. /*if not available buf_temp-cash-pay-list then do:*/
         end. /*DO v-jj = 1 TO num-entries(v-cp-list, ";"):*/
      end. /*if v-fr-code >= 2*/
   end. /**do v-ii*/
   */

   /* Наименование типов оплаты */
   assign
      v-code       = {&cda-ibs-th_fisreg_pay-names}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }

   assign
      v-pay-names = v-character
   .
   /*
   DO v-ii = 1 TO num-entries(p-pay-names-list, {&delim-par}):
      assign
         v-fr-code = v-ii + 1
         v-name = ENTRY(v-ii, p-pay-names-list, {&delim-par})
      no-error.
      if  v-fr-code >= 2
      AND v-fr-code <= 4 then do:
         find first buf_temp-pay-names
              where buf_temp-pay-names.frpay-code = v-fr-code
              no-error
              .
         if not available buf_temp-pay-names then do:
         CREATE buf_temp-pay-names.
         assign
         buf_temp-pay-names.frpay-code = v-fr-code
         buf_temp-pay-names.frpay-name = v-name
         .

         end. /*if not available buf_temp-pay-names then do:*/
      end.
   end.
   */

   /* Отрезание чеков */
   assign
      v-code       = {&cda-ibs-th_fisreg_cutter}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-cutter = logical(v-integer)
   .
   /*Устанволение параметра разрешена работа по признакам*/
      { str/libthpos_get-context-property.i
         {&context}
         'doc-prt'
         v-character
         v-date
         v-decimal
         v-integer
         v-logical
         v-handle
         v-data-type
         p-ok
         no-error
      }
      if error-status:error
      OR not p-ok
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         return .
      end.
      assign v-doc-prt =  v-logical.



   /****************** Настройка чеков **************************/
   assign
      v-upper-code = {&cda-ibs-th_rec-print}
   .

   /* Максимальная сумма чека */
   assign
      v-code       = {&cda-ibs-th_rec-print_max-netto}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-max-netto = v-decimal
   .

   /* Рекламный текст */
   assign
      v-code       = {&cda-ibs-th_rec-print_advert-text}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-advert-text = v-character
   .
   /*
   DO v-count = 1 TO NUM-ENTRIES(v-character, {&delim-par}) :
      assign
         v-advert-text[v-count] = ENTRY(v-count, v-character, {&delim-par})
      .
   end.
   */

   /* Строки клише */
   assign
      v-code       = {&cda-ibs-th_rec-print_cliche-lines}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-cliche-lines = v-character
   .
   /*
   DO v-count = 1 TO NUM-ENTRIES(v-character) :
      assign
         v-cliche-lines[v-count] = ENTRY(v-count, v-character, {&delim-par})
      .
   end.
   */

   /* Печатать код товара в чеке */
   assign
      v-code       =  {&cda-ibs-th_rec-print_print-good-code}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-print-good-code = logical(v-integer)
   .

   /* Метод округления  */
   assign
      v-code       = {&cda-ibs-th_rec-print_rmethod-type}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-rmethod-type = v-character
   .

   /* Коэффициент округления  */
   assign
      v-code       =  {&cda-ibs-th_rec-print_rmethod-coeff}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-rmethod-coeff = v-decimal
   .



   /****************** Базовые настройки **************************/
   assign
      v-upper-code = {&cda-ibs-th_main}
   .

   /* Работа с логическими сменами */
   assign
      v-code       = {&cda-ibs-th_main_cash-shift}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-cash-shift = logical(v-integer)
   .

   /* Уровень логирования */
   assign
      v-code       = {&cda-ibs-th_main_log-level}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-log-level = v-integer
   .

   { gbl/eventlib-log-level.i
     v-log-level
     p-ok
     no-error
   }


   /* код валюты платежей  */
   assign
      v-code       = {&cda-ibs-th_main_nalc}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-nalc = v-integer
   .

   /* Обязательное наличие продавца в чеке */
   assign
      v-code       = {&cda-ibs-th_main_salesman-mandatory}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-salesman-mandatory = logical(v-integer)
   .

   /* разрешение ручной скидки  */
   assign
      v-code       = {&cda-ibs-th_main_manual-discnt}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-manual-discnt = logical(v-integer)
   .

   /* Уровень логирования событий */
   assign
      v-code       = {&cda-ibs-th_main_log-level}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-log-level = v-integer
   .

   /* Обнулять счетчик наличности при снятии Z-отчета */
   assign
      v-code       = {&cda-ibs-th_main_clear-cash-counter}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-clear-cash-counter = LOGICAL(v-integer)
   .

   /* Разрешена коррекция количества */
   assign
      v-code       = {&cda-ibs-th_main_qnty-change}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-qnty-change = LOGICAL(v-integer)
   .


   /******************  **************************/
   assign
      v-upper-code = {&cda-ibs-th_interface}
   .

   /*   */
   assign
      v-code       = {&cda-ibs-th_interface_screen-type}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-screen-type = v-character
   .

   assign
      v-code       = {&cda-ibs-th_interface_screen-layout-id}
   .
   { str/libthpos_get-cda.i
      v-cntxt-db-num
      v-cntxt-obj-code
      {&cd-type-ibs-th}
      p-cash-num
      v-upper-code
      v-code
      v-character
      v-date
      v-decimal
      v-integer
      v-logical
      v-data-type
      no-error
   }
   assign
      v-screen-layout-id = v-character
   .


   /****************** Параметры кассы **************************/
   /*
   assign
      v-upper-code =
   .

   Номер кассы
   Номер магазина (объекта ТН)
   Адрес/Путь
   Тип POS
   Тип ОС
   Тип ФР
   Регистрационный номер
   Серийный номер
   */
   if not v-emul-mode
   then do:
      assign
         p-ok = TRUE
      no-error .
      { gbl/fr-set.i
         v-pay-names
         v-clear-cash-counter
         v-cashier-name
         v-cash-drawer-plug
         v-cash-drawer-plug-imp
         v-cutter
         v-cash-drawer-level
         v-advert-text
         v-cliche-lines
         v-print-good-code
         v-max-netto
         v-cash-shift
         v-cash-drawer-open
         v-cash-drawer-limit
         v-clear-cash-counter
         p-message
         p-ok
         no-error
      }
      if error-status:error
      OR not p-ok
      then do:
          if   p-message = "":U
          then p-message = "Нет связи с фискальным регистратором".
          return.
      end.
   end.
   assign
      p-ok = TRUE
   no-error .

   run prep-lay_get-layout in this-procedure ( input {&th-pos-screen}
                           , input v-screen-type
                           , input v-screen-layout-id ) no-error.

   if error-status:error then do:
      message
                         substitute("Нельзя работать с POS IBS TH:&1&2&1&3"
                               , {&new-line}
                               , error-status:get-message(1)
                               , return-value )
      view-as alert-box error.
      return error .
   end.

   if  v-keyboard-layout-id <> "":U
   AND v-keyboard-layout-id <> ?
   then do:
      run prep-lay_get-layout in this-procedure ( input {&th-pos-keyboard}
                              , input v-keyboard-type
                              , input v-keyboard-layout-id ) no-error.

      if error-status:error then do:
         message
                           substitute("Нельзя работать с POS IBS TH:&1&2&1&3"
                                 , {&new-line}
                                 , error-status:get-message(1)
                                 , return-value )
         view-as alert-box error.
         return error .
      end.
   end.

end. /* do on error */
end procedure. /* set-cd-prop */



/*==========================================================================*/
procedure set-context-serial :
define input   parameter p-serial      as char          no-undo.
define input   parameter p-model       as integer          no-undo.
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   assign
      v-context-serial = p-serial
   .
   case p-model:
      WHEN 4
      then do:
         assign
            v-fr-width        = {&g-fr-width-1}
            v-fr-width-bold   = {&g-fr-width-10}
         .
      end.
      WHEN 9
      then do:
         assign
            v-fr-width = {&g-fr-width-2}
            v-fr-width-bold   = {&g-fr-width-20}
         .
      end.
      WHEN 8
      then do:
         assign
            v-fr-width = {&g-fr-width-3}
            v-fr-width-bold   = {&g-fr-width-30}
         .
      end.

      OTHERWISE DO:
         assign
            v-fr-width = {&g-fr-width-0}
            v-fr-width-bold   = {&g-fr-width-00}
         .
      end.
   end case.
end. /* do on error */
end procedure. /* set-context-serial */




/*==========================================================================*/
procedure get-disc-type :
define output   parameter p-disc-type  as character          no-undo.
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   assign
      p-disc-type = v-disc-type
   .

end. /* do on error */
end procedure. /* get-disc-type */




/*==========================================================================*/
procedure hour24 :
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.

do
on error undo, return error
:

   if v-fr-shift-open = 24
   then do:
      assign
         p-ok = TRUE
      .
   end.
   else do:
      assign
         p-ok = FALSE
      .
   end.

end. /* do on error */
end procedure. /* hour24 */




/*==========================================================================*/
procedure sht-cls :
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   if v-fr-shift-open = 0
   then do:
      assign
         p-ok = TRUE
      .
   end.
   else do:
      assign
         p-ok = FALSE
      .
   end.

end. /* do on error */

end procedure. /* sht-cls */




/*==========================================================================*/
procedure get-display-adv :
define output  parameter p-disp-message-1  as character          no-undo.
define output  parameter p-disp-message-2  as character          no-undo.
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   if num-entries(v-customer-display-adv, {&delim-par}) >= 2
   then do:
      assign
         p-disp-message-1 = entry(1, v-customer-display-adv, {&delim-par})
         p-disp-message-2 = entry(2, v-customer-display-adv, {&delim-par})
      .
   end.
   else do:
      assign
         p-disp-message-1 = v-customer-display-adv
         p-ok   = TRUE
      .
   end.
end. /* do on error */
end procedure. /* get-display-adv */




/*==========================================================================*/
procedure 2001 :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output  parameter p-message     as character      no-undo .
define output  parameter p-ok          as logical          no-undo.

do
on error undo, return error
:
   { gbl/eventlib-event-log.i
      0
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      '':U
      '':U
      '*':U
      '':U
      '':U
      '':U
      TODAY
      81
      TIME
      'U':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      0
      v-cntxt-userid
      no-error
   }
   run adm/chk-pass.w   ( input parparentproc
                        , input v-cntxt-userid
                        , input v-cntxt-db-num
                        , input "actn_ibsthpos-bank-day"
                        , input FALSE
                        , output p-message
                        , output p-ok
                        ) .
   if not p-ok
   then do:
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         '':U
         '':U
         p-message
         '':U
         '':U
         '':U
         TODAY
         83
         TIME
         'E':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }
      return.
   end.

   if not v-emul-mode
   then do:
      { gbl/sb-day.i
         p-message
         p-ok
         no-error
      }
   end.
   if error-status:error
   then do:
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         p-cash-num
         {&md}
         '':U
         '':U
         p-message
         '':U
         '':U
         '':U
         TODAY
         83
         TIME
         'E':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }
   end.
   { gbl/eventlib-event-log.i
      0
      v-cntxt-db-num
      '':U
      p-cash-num
      {&md}
      '':U
      '':U
      '*':U
      '':U
      '':U
      '':U
      TODAY
      82
      TIME
      'S':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      0
      v-cntxt-userid
      no-error
   }


end. /* do on error */
end procedure. /* 2001 */




/*==========================================================================*/
procedure print-slip :
define input   parameter p-slip     as character no-undo .
define output  parameter p-message  as character no-undo .
define output  parameter p-ok       as logical   no-undo .

define variable v-iii    as integer      no-undo .
define variable v-ccc    as character    no-undo .

do
on error undo, return error
:
   /*
   output stream slip-out to "d:\slip.txt".
   EXport stream slip-out p-slip.
   output stream slip-out close.
   */

   /* !!!
   { gbl/fr-doctitle.i
      v-num
      v-name
      p-message
      p-ok
      no-error
   }

   if error-status:error then do:
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      return.
   end.
   */


   DO v-iii = 1 TO NUM-ENTRIES(p-slip, {&new-line})
   :
      v-ccc = ENTRY(v-iii, p-slip, {&new-line}).
      if INDEX(v-ccc, chr(01)) > 0
      then do:
         if v-cutter
         then do:
            { gbl/fr-cut.i
               FALSE
               p-message
               p-ok
            no-error
            }
         end.
      end.
      v-ccc = REPLACE(v-ccc,chr(01) , "":U).

      { gbl/fr-print-str.i
         v-ccc
         p-message
         p-ok
      no-error
      }
   end.
   assign
      p-ok     = TRUE
   .

end. /* do on error */
end procedure. /* print-slip */




/*==========================================================================*/
procedure accum-chk-pay :
define input   parameter p-pay-code  as integer   no-undo .
define input   parameter p-curr-code as integer   no-undo .
define input   parameter p-card-num  as character no-undo .
define output  parameter p-found-pay as logical   no-undo .
define output  parameter p-summ-pay  as decimal   no-undo .

define buffer buf_chk-pay        for ub.chk-pay .
define buffer buf_tt-open-check  for tt-open-check .
define buffer buf_tt-line        for tt-line .

do
on error undo, return error
:
   if p-pay-code = 0
   then do:
      for each  buf_tt-line
         where buf_tt-line.ord-chk-num <> "":U
         no-lock
         BREAK BY buf_tt-line.ord-chk-num
         :
         if first-OF(buf_tt-line.ord-chk-num)
         then do:
            if CAN-find (first buf_tt-open-check
                         where buf_tt-open-check.doc-code = buf_tt-line.ord-chk-num
                           AND buf_tt-open-check.chk-type = INTEGER({&rcpt-sale}))
            then do:
               assign
                     p-found-pay = TRUE
               .
               for each  buf_chk-pay
                     where buf_chk-pay.doc-code  = buf_tt-line.ord-chk-num
                     NO-LOCK
                     :
                     assign
                        p-summ-pay = p-summ-pay + buf_chk-pay.tot-sum
                     .
               end.
            end.
         end.
         else do:
            NEXT.
         end.
      end.
   end.
   else do:
      for each  buf_tt-line
         where buf_tt-line.ord-chk-num <> "":U
         no-lock
         BREAK BY buf_tt-line.ord-chk-num
         :
         if first-OF(buf_tt-line.ord-chk-num)
         then do:
            if CAN-find (first buf_tt-open-check
                         where buf_tt-open-check.doc-code = buf_tt-line.ord-chk-num
                           AND buf_tt-open-check.chk-type = INTEGER({&rcpt-sale}))
            then do:
               assign
                     p-found-pay = TRUE
               .

               for each  buf_chk-pay
                     where buf_chk-pay.doc-code    = buf_tt-line.ord-chk-num
                     AND buf_chk-pay.pay-code    = p-pay-code
                     AND buf_chk-pay.curr-code   = p-curr-code
                     AND buf_chk-pay.pay-card    = p-card-num
                     NO-LOCK
                     :
                     assign
                        p-summ-pay = p-summ-pay + buf_chk-pay.tot-rubl
                     .
               end.
            end.
         end.
         else do:
            NEXT.
         end.
      end.
   end.
   assign
      p-summ-pay = ABS( p-summ-pay )
   .
end. /* do on error */
end procedure. /* accum-chk-pay */



/*==========================================================================*/
procedure accum-curr-chk-pay :
define input   parameter p-pay-code  as integer   no-undo .
define input   parameter p-curr-code as integer   no-undo .
define input   parameter p-card-num  as character no-undo .
define output  parameter p-summ-pay  as decimal   no-undo .

define buffer buf_tt-line     for tt-line .

do
on error undo, return error
:
   if p-pay-code = 0
   then do:
      for each  buf_tt-line
         where buf_tt-line.type = 1
         :
         assign
            p-summ-pay = p-summ-pay + buf_tt-line.summ-netto-rub
         .
      end.
   end.
   else do:
      for each buf_tt-line
         where buf_tt-line.type        = 1
           AND buf_tt-line.line-code   = p-pay-code
           AND buf_tt-line.curr-code   = p-curr-code
           AND buf_tt-line.pay-card    = p-card-num
         :
         assign
            p-summ-pay = p-summ-pay + buf_tt-line.summ-netto-rub
         .
      end.
   end.
end. /* do on error */
end procedure. /* accum-curr-chk-pay */



&ANALYZE-SUSPend _UIB-CODE-BLOCK _PROCEDURE annul-lost-chk C-Win
PROCEDURE annul-lost-chk :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output  parameter p-message   as character no-undo .
define output  parameter p-ok        as logical   no-undo .

define buffer buf_chk-doc     for ub.chk-doc .
do
on error undo, return error
:
  find last  buf_chk-doc
      where buf_chk-doc.obj-type = v-cntxt-obj-type
        AND buf_chk-doc.obj-code = v-cntxt-obj-code
        AND buf_chk-doc.pay-desk = p-cash-num
        AND buf_chk-doc.office   = ?
        /*
        AND buf_chk-doc.z-number
        */
      NO-LOCK
      no-error
      .

  if available buf_chk-doc
  then do:
    { str/libthpos_annu-lost-check.i
      buf_chk-doc.doc-code
      no-error
    }
    if error-status:error
    then do:
      assign
      p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
      p-ok = FALSE
      .
    end.
    else do:
      message
      substitute("Найден и аннулирован незавершенный чек &1", buf_chk-doc.doc-code )
      view-as alert-box warning.
    end.
  end.

  assign
  p-ok = TRUE
  .

end.
end PROCEDURE.  /* annul-lost-chk */

/* _UIB-CODE-BLOCK-end */
&ANALYZE-RESUME





&ANALYZE-SUSPend _UIB-CODE-BLOCK _PROCEDURE non-fisk-doc C-Win
PROCEDURE non-fisk-doc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input-output  parameter p-cd-mode     as character no-undo .
define input-output  parameter p-cd-submode  as character no-undo .
define input parameter p-title as character        no-undo.
define output  parameter p-message   as character no-undo .
define output  parameter p-ok        as logical   no-undo .

define buffer buf_tt-line     for tt-line .
define variable v-chk-fr-num    as character    no-undo.
define variable v-price-rub    as decimal      no-undo.
define variable v-disc-rub-total    as decimal      no-undo.
define variable v-print-line    as character    no-undo.
define variable v-rest-summ      as decimal      no-undo .

do
on error undo, return error
:
   if v-emul-mode then return.

   find tt-head-check .
   /* Сдача */
   if  v-close-good-chk
   AND v-with-context
   AND p-title begins ('ТОВАРНЫЙ ЧЕК' + {&space-char})
   then do:
      assign
         v-rest-summ = ?
      .
      run rest-back in this-procedure ( input-output v-rest-summ, output p-message, output p-ok) .
      if error-status:error
      OR not p-ok
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         return .
      end.
   end.

   /* Итоги по чеку */
   if  v-close-good-chk
   AND v-with-context
   then do:
      { str/libthpos_getcheck.i
         tt-head-check.doc-code
         no
         no-error
      }
      if error-status:error then do:
         if v-rest-summ > 0
         AND v-close-good-chk
         then do:
            run del-rest (output p-message, output p-ok) .
         end.
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            0
            '':U
            tt-head-check.chk-type
            '':U
            p-message
            '':U
            tt-head-check.doc-code
            '':U
            TODAY
            67
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.

      end.
   end.

   /* Заголовок */
   define variable v-num    as character    no-undo.
   define variable v-name    as character    no-undo.
   if v-with-context
   then do:
      assign
         v-num  = '0000'
         v-name = p-title
      .
   end.
   else do:
      assign
         v-num  = '0000'
         v-name = p-title
      .
   end.

   { gbl/fr-doctitle.i
      v-num
      v-name
      p-message
      p-ok
      no-error
   }

   if error-status:error then do:
      if v-rest-summ > 0
      AND v-close-good-chk
      then do:
         run del-rest (output p-message, output p-ok) .
      end.
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      { gbl/eventlib-event-log.i
         0
         v-cntxt-db-num
         '':U
         0
         '':U
         tt-head-check.chk-type
         '':U
         p-message
         '':U
         tt-head-check.doc-code
         '':U
         TODAY
         67
         TIME
         'E':U
         0
         v-cntxt-obj-type
         v-cntxt-obj-code
         '':U
         {&cd-type-ibs-th}
         0
         ?
         '':U
         0
         '':U
         0
         v-cntxt-userid
         no-error
      }
      return.
   end.

   /* товарные строки */
   for each  buf_tt-line
       where buf_tt-line.type = 0
      :
      /* Строка 1. Код и имя */
      run str-fix-width ( input (if v-print-good-code then STRING(buf_tt-line.src) + " " else "":U) + buf_tt-line.line-name
                        , input "":U
                        , input v-fr-width
                        , YES
                        , output v-print-line
                        , output p-message
                        , output p-ok
                        ) .

      { gbl/fr-print-str.i
         v-print-line
         p-message
         p-ok
      no-error
      }
      if error-status:error then do:
         if v-rest-summ > 0
         AND v-close-good-chk
         then do:
            run del-rest (output p-message, output p-ok) .
         end.
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            0
            '':U
            tt-head-check.chk-type
            '':U
            p-message
            '':U
            tt-head-check.doc-code
            '':U
            TODAY
            67
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.
      /* Строка 2. Цена Х количество */
      if buf_tt-line.qnty > 1
      then do:
         run str-fix-width ( input ""
                           , input (TRIM(STRING(buf_tt-line.qnty)) + " X " + TRIM(STRING(buf_tt-line.price-rub, ">>>,>>9.99")))
                           , input v-fr-width
                           , YES
                           , output v-print-line
                           , output p-message
                           , output p-ok
                           ) .
         { gbl/fr-print-str.i
            v-print-line
            p-message
            p-ok
         no-error
         }
         if error-status:error then do:
            if v-rest-summ > 0
            AND v-close-good-chk
            then do:
               run del-rest (output p-message, output p-ok) .
            end.
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               0
               '':U
               tt-head-check.chk-type
               '':U
               p-message
               '':U
               tt-head-check.doc-code
               '':U
               TODAY
               67
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
      end.
      /* Строка 2.5 Сумма */

      run str-fix-width ( input ""
                        , input ("=" + TRIM(STRING((buf_tt-line.price-rub * buf_tt-line.qnty), "->>>,>>9.99")))
                        , input v-fr-width
                        , YES
                        , output v-print-line
                        , output p-message
                        , output p-ok
                        ) .
      { gbl/fr-print-str.i
         v-print-line
         p-message
         p-ok
      no-error
      }
      if error-status:error then do:
         if v-rest-summ > 0
         AND v-close-good-chk
         then do:
            run del-rest (output p-message, output p-ok) .
         end.
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         { gbl/eventlib-event-log.i
            0
            v-cntxt-db-num
            '':U
            0
            '':U
            tt-head-check.chk-type
            '':U
            p-message
            '':U
            tt-head-check.doc-code
            '':U
            TODAY
            67
            TIME
            'E':U
            0
            v-cntxt-obj-type
            v-cntxt-obj-code
            '':U
            {&cd-type-ibs-th}
            0
            ?
            '':U
            0
            '':U
            0
            v-cntxt-userid
            no-error
         }
         return.
      end.

      /* Строка 3. Скидка
      if v-with-context
      then do:
      */
         assign
            v-disc-rub-total = v-disc-rub-total + buf_tt-line.summ-discont-rub
         .
         run str-fix-width ( input "СКИДКА"
                           , input ("=" + TRIM(STRING(buf_tt-line.summ-discont-rub, ">>>,>>9.99")))
                           , input v-fr-width
                           , YES
                           , output v-print-line
                           , output p-message
                           , output p-ok
                           ) .
         if buf_tt-line.summ-discont-rub > 0
         then do:
            { gbl/fr-print-str.i
               v-print-line
               p-message
               p-ok
            no-error
            }
            if error-status:error then do:
               if v-rest-summ > 0
               AND v-close-good-chk
               then do:
                  run del-rest (output p-message, output p-ok) .
               end.
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  0
                  '':U
                  tt-head-check.chk-type
                  '':U
                  p-message
                  '':U
                  tt-head-check.doc-code
                  '':U
                  TODAY
                  67
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  0
                  v-cntxt-userid
                  no-error
               }
               return.
            end.
         end.
     /* end.*/
   end.

   define variable v-summ-1  as decimal      no-undo.
   define variable v-summ-2  as decimal      no-undo.
   define variable v-summ-3  as decimal      no-undo.
   define variable v-summ-4  as decimal      no-undo.
   assign
      v-summ-1 = 0
      v-summ-2 = 0
      v-summ-3 = 0
      v-summ-4 = 0
   .
   for each  buf_tt-line
      where buf_tt-line.type = 1
   :
      case buf_tt-line.fr-pay-code :
         WHEN 1 then do:
            assign
               v-summ-1 = v-summ-1 + if p-cd-mode = {&cd-mode-ret} then - buf_tt-line.summ-netto-rub else buf_tt-line.summ-netto-rub
            .
         end.
         WHEN 2 then do:
            assign
               v-summ-2 = v-summ-2 + if p-cd-mode = {&cd-mode-ret} then - buf_tt-line.summ-netto-rub else buf_tt-line.summ-netto-rub
            .
         end.
         WHEN 3 then do:
            assign
               v-summ-3 = v-summ-3 + if p-cd-mode = {&cd-mode-ret} then - buf_tt-line.summ-netto-rub else buf_tt-line.summ-netto-rub
            .
         end.
         WHEN 4 then do:
            assign
               v-summ-4 = v-summ-4 + if p-cd-mode = {&cd-mode-ret} then - buf_tt-line.summ-netto-rub else buf_tt-line.summ-netto-rub
            .
         end.
         OTHERWISE DO:
         end.
      end case.
   end.
   if not v-with-context
   then do:
      assign
         v-summ-pay-rub = v-summ-1 + v-summ-2 + v-summ-3 + v-summ-4
      .
   end.


   /* подвал */
   define variable v-card    as character    no-undo.
   case tt-head-check.chk-type:
      WHEN integer({&rcpt-sale})
      then do:
         /* Строка 1. Скидки */
         assign
            v-summ-discont-rub   = (v-summ-discont-rub - v-disc-rub-total)
         .
         if v-summ-discont-rub <> 0
         then do:
            /*
            assign
               v-print-line = "-------------------------------------"  /*!!!*/
            .
            { gbl/fr-print-str.i
               v-print-line
               p-message
               p-ok
            no-error
            }
            */
            run str-fix-width ( input "СКИДКА"
                              , input ("=" + TRIM(STRING(v-summ-discont-rub, ">>>,>>9.99")))
                              , input v-fr-width
                              , YES
                              , output v-print-line
                              , output p-message
                              , output p-ok
                              ) .
            { gbl/fr-print-str.i
               v-print-line
               p-message
               p-ok
            no-error
            }
         end.
         if tt-head-check.d-card <> "":U
         then do:
            assign
               v-print-line = substitute("Карта &1", tt-head-check.d-card)
            .

            { gbl/fr-print-str.i
               v-print-line
               p-message
               p-ok
            no-error
            }
            if error-status:error then do:
               if v-rest-summ > 0
               AND v-close-good-chk
               then do:
                  run del-rest (output p-message, output p-ok) .
               end.
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  0
                  '':U
                  tt-head-check.chk-type
                  '':U
                  p-message
                  '':U
                  tt-head-check.doc-code
                  '':U
                  TODAY
                  67
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  0
                  v-cntxt-userid
                  no-error
               }
               return.
            end.
            /*
            assign
               v-print-line = "":U
            .

            { gbl/fr-print-str.i
               tt-head-check.obj-name
               p-message
               p-ok
            no-error
            }
            if error-status:error then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  0
                  '':U
                  tt-head-check.chk-type
                  '':U
                  p-message
                  '':U
                  tt-head-check.doc-code
                  '':U
                  TODAY
                  67
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  0
                  v-cntxt-userid
                  no-error
               }
               return.
            end.
            */
         end.
         assign
            v-print-line = "-------------------------------------" /*!!!*/
         .
         { gbl/fr-print-str.i
            v-print-line
            p-message
            p-ok
         no-error
         }

         /* Строка 2. К оплате */
         run str-fix-width ( input "ИТОГ"
                           , input ("=" + TRIM(STRING(v-summ-netto-rub, ">>>,>>9.99")))
                           , input v-fr-width-bold
                           , YES
                           , output v-print-line
                           , output p-message
                           , output p-ok
                           ) .
         { gbl/fr-wide-print-str.i
            v-print-line
            p-message
            p-ok
         no-error
         }
         if error-status:error then do:
            if v-rest-summ > 0
            AND v-close-good-chk
            then do:
               run del-rest (output p-message, output p-ok) .
            end.
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               0
               '':U
               tt-head-check.chk-type
               '':U
               p-message
               '':U
               tt-head-check.doc-code
               '':U
               TODAY
               67
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.

         /* Строка 3. Сумма оплаты 1 */
         if v-summ-1 > 0
         then do:
            run str-fix-width ( input " НАЛИЧНЫМИ"
                              , input ("=" + TRIM(STRING(v-summ-1, ">>>,>>9.99")))
                              , input v-fr-width
                              , YES
                              , output v-print-line
                              , output p-message
                              , output p-ok
                              ) .
            { gbl/fr-print-str.i
               v-print-line
               p-message
               p-ok
            no-error
            }
            if error-status:error then do:
               if v-rest-summ > 0
               AND v-close-good-chk
               then do:
                  run del-rest (output p-message, output p-ok) .
               end.
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  0
                  '':U
                  tt-head-check.chk-type
                  '':U
                  p-message
                  '':U
                  tt-head-check.doc-code
                  '':U
                  TODAY
                  67
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  0
                  v-cntxt-userid
                  no-error
               }
               return.
            end.
         end.
         /* Строка 4. Сумма оплаты 2 */
         if v-summ-2 > 0
         then do:
            run str-fix-width ( input ENTRY(1, v-pay-names, {&delim-par})
                              , input ("=" + TRIM(STRING(v-summ-2, ">>>,>>9.99")))
                              , input v-fr-width
                              , YES
                              , output v-print-line
                              , output p-message
                              , output p-ok
                              ) .
            { gbl/fr-print-str.i
               v-print-line
               p-message
               p-ok
            no-error
            }
            if error-status:error then do:
               if v-rest-summ > 0
               AND v-close-good-chk
               then do:
                  run del-rest (output p-message, output p-ok) .
               end.
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  0
                  '':U
                  tt-head-check.chk-type
                  '':U
                  p-message
                  '':U
                  tt-head-check.doc-code
                  '':U
                  TODAY
                  67
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  0
                  v-cntxt-userid
                  no-error
               }
               return.
            end.
         end.
         /* Строка 5. Сумма оплаты 3 */
         if v-summ-3 > 0
         then do:
            run str-fix-width ( input ENTRY(2, v-pay-names, {&delim-par})
                              , input ("=" + TRIM(STRING(v-summ-3, ">>>,>>9.99")))
                              , input v-fr-width
                              , YES
                              , output v-print-line
                              , output p-message
                              , output p-ok
                              ) .
            { gbl/fr-print-str.i
               v-print-line
               p-message
               p-ok
            no-error
            }
            if error-status:error then do:
               if v-rest-summ > 0
               AND v-close-good-chk
               then do:
                  run del-rest (output p-message, output p-ok) .
               end.
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  0
                  '':U
                  tt-head-check.chk-type
                  '':U
                  p-message
                  '':U
                  tt-head-check.doc-code
                  '':U
                  TODAY
                  67
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  0
                  v-cntxt-userid
                  no-error
               }
               return.
            end.
         end.
         /* Строка 6. Сумма оплаты 4 */
         if v-summ-4 > 0
         then do:
            run str-fix-width ( input ENTRY(3, v-pay-names, {&delim-par})
                              , input ("=" + TRIM(STRING(v-summ-4, ">>>,>>9.99")))
                              , input v-fr-width
                              , YES
                              , output v-print-line
                              , output p-message
                              , output p-ok
                              ) .
            { gbl/fr-print-str.i
               v-print-line
               p-message
               p-ok
            no-error
            }
            if error-status:error then do:
               if v-rest-summ > 0
               AND v-close-good-chk
               then do:
                  run del-rest (output p-message, output p-ok) .
               end.
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  0
                  '':U
                  tt-head-check.chk-type
                  '':U
                  p-message
                  '':U
                  tt-head-check.doc-code
                  '':U
                  TODAY
                  67
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  0
                  v-cntxt-userid
                  no-error
               }
               return.
            end.
         end.

         /* Строка 7. Сдача */
         if ( v-summ-pay-rub - v-summ-netto-rub ) > 0
         then do:
            run str-fix-width ( input "СДАЧА"
                              , input ("=" + TRIM(STRING(( v-summ-pay-rub - v-summ-netto-rub ), ">>>,>>9.99")))
                              , input v-fr-width
                              , YES
                              , output v-print-line
                              , output p-message
                              , output p-ok
                              ) .
            { gbl/fr-print-str.i
               v-print-line
               p-message
               p-ok
               no-error
            }
            if error-status:error then do:
               if v-rest-summ > 0
               AND v-close-good-chk
               then do:
                  run del-rest (output p-message, output p-ok) .
               end.
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  0
                  '':U
                  tt-head-check.chk-type
                  '':U
                  p-message
                  '':U
                  tt-head-check.doc-code
                  '':U
                  TODAY
                  67
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  0
                  v-cntxt-userid
                  no-error
               }
               return.
            end.
         end.

         /*
         { gbl/fr-outputrec.i
            p-message
            p-ok
            no-error
         }
         if error-status:error then do:
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            return.
         end.
         */
         { gbl/fr-feeddoc.i
            6
            p-message
            p-ok
            no-error
         }
         if error-status:error then do:
            if v-rest-summ > 0
            AND v-close-good-chk
            then do:
               run del-rest (output p-message, output p-ok) .
            end.
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               0
               '':U
               tt-head-check.chk-type
               '':U
               p-message
               '':U
               tt-head-check.doc-code
               '':U
               TODAY
               67
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.

         if v-cutter
         then do:
            { gbl/fr-cut.i
               FALSE
               p-message
               p-ok
               no-error
            }
         end.
         if error-status:error then do:
            if v-rest-summ > 0
            AND v-close-good-chk
            then do:
               run del-rest (output p-message, output p-ok) .
            end.
            assign
               p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
               p-ok = FALSE
            .
            { gbl/eventlib-event-log.i
               0
               v-cntxt-db-num
               '':U
               0
               '':U
               tt-head-check.chk-type
               '':U
               p-message
               '':U
               tt-head-check.doc-code
               '':U
               TODAY
               67
               TIME
               'E':U
               0
               v-cntxt-obj-type
               v-cntxt-obj-code
               '':U
               {&cd-type-ibs-th}
               0
               ?
               '':U
               0
               '':U
               0
               v-cntxt-userid
               no-error
            }
            return.
         end.
         /*
         { gbl/fr-chkcl.i
            v-summ-1
            v-summ-2
            v-summ-3
            v-summ-4
            v-card
            v-chk-fr-num
            p-message
            p-ok
            no-error
         }
         if error-status:error
         then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
            return .
         end.
         */
      end.
      OTHERWISE DO:
      end.
   end case.

   /*
   run print-head-chk   ( output p-message
                        , output p-ok
                        ) .
   */

   { gbl/eventlib-event-log.i
      0
      v-cntxt-db-num
      '':U
      0
      '':U
      tt-head-check.chk-type
      '':U
      '*':U
      '':U
      tt-head-check.doc-code
      '':U
      TODAY
      66
      TIME
      'U':U
      0
      v-cntxt-obj-type
      v-cntxt-obj-code
      '':U
      {&cd-type-ibs-th}
      0
      ?
      '':U
      0
      '':U
      0
      v-cntxt-userid
      no-error
   }

   /* проверить параметр и, если нужно, закрыть чек */
   if  v-close-good-chk
   AND v-with-context
   AND p-title begins ('ТОВАРНЫЙ ЧЕК' + {&space-char})
   then do:
      /* открыть денежный ящик */
      run 1988 in this-procedure ( INPUt-OUTPUT p-cd-mode
                                 , INPUt-output p-cd-submode
                                 , output p-message
                                 , output p-ok
                                 ) .

      /* погасить отложенные чеки */
      define buffer buf_tt-open-check     for tt-open-check .
      /* if v-reopen-chk <> "":U */
      if CAN-find(first buf_tt-open-check)
      then do:
         for each buf_tt-open-check:
            { str/libthpos_close-postpone.i
               tt-head-check.doc-code
               buf_tt-open-check.doc-code
               1
               no-error
            }
            if error-status:error
            then do:
               assign
                  p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
                  p-ok = FALSE
               .
               { gbl/eventlib-event-log.i
                  0
                  v-cntxt-db-num
                  '':U
                  0
                  '':U
                  tt-head-check.chk-type
                  '':U
                  p-message
                  '':U
                  tt-head-check.doc-code
                  '':U
                  TODAY
                  67
                  TIME
                  'E':U
                  0
                  v-cntxt-obj-type
                  v-cntxt-obj-code
                  '':U
                  {&cd-type-ibs-th}
                  0
                  ?
                  '':U
                  0
                  '':U
                  0
                  v-cntxt-userid
                  no-error
               }
               return.
            end.
         end.
      end.

      { str/libthpos_close-check.i
         tt-head-check.doc-code
         v-chk-fr-num
         no-error
      }
      if error-status:error then do:
         if v-rest-summ > 0
         AND v-close-good-chk
         then do:
            run del-rest (output p-message, output p-ok) .
         end.
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
         .
         return.
      end.
      /*  смена режима */
      run clear-tt-chk in this-procedure.
      assign
         p-cd-mode    = {&cd-mode-ready}
         p-cd-submode = {&cd-submode-goods}
         p-message    = "Чек закрыт"
      .

   end.

   assign
      p-ok         = true
   .

end.
end PROCEDURE.  /* non-fisk-doc */

/* _UIB-CODE-BLOCK-end */
&ANALYZE-RESUME




&ANALYZE-SUSPend _UIB-CODE-BLOCK _PROCEDURE str-fix-width C-Win
PROCEDURE str-fix-width :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input  parameter p-left-str  as character no-undo .
define input  parameter p-right-str as character no-undo .
define input  parameter p-width     as integer   no-undo .
define input  parameter p-cut       as logical   no-undo.
define output parameter p-fix-str   as character no-undo .
define output parameter p-message   as character no-undo .
define output parameter p-ok        as logical   no-undo .

define variable v-left-width    as integer       no-undo.
define variable v-right-width    as integer      no-undo.

do
on error undo, return error
:
   assign
      v-left-width  = LENGTH( p-left-str )
      v-right-width = LENGTH( p-right-str )
   .

   /* справа обычно цифры,
      если они не влазят,
      то дальше бессмысленно
   */
   if v-right-width > p-width
   then do:
      return error "правая часть больше ширины строки".
   end.

   if (v-right-width + v-left-width) > p-width + 1
   then do:
      if not p-cut
      then do:
         return error "суммарная длина больше ширины строки".
      end.

      assign
         p-left-str = SUBSTRING(p-left-str, 1, (p-width - v-right-width - 1) ) + " "
      .
   end.
   else do:
      assign
         p-left-str = p-left-str + FILL( " ", (p-width - v-right-width - v-left-width) )
      .
   end.

   assign
      p-fix-str = p-left-str + p-right-str
      p-ok      = true
   .

end.
end PROCEDURE.  /* str-fix-width */

/* _UIB-CODE-BLOCK-end */
&ANALYZE-RESUME




&ANALYZE-SUSPend _UIB-CODE-BLOCK _PROCEDURE print-head-chk C-Win
PROCEDURE print-head-chk :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-message   as character no-undo .
define output parameter p-ok        as logical   no-undo .

define variable  v-count     as integer   no-undo .
define variable v-line    as character      no-undo.

do
on error undo, return error
:

   DO v-count = 1 TO NUM-ENTRIES(v-cliche-lines, {&delim-par}):
      assign
         v-line = ENTRY(v-count, v-cliche-lines, {&delim-par})
      .
      if v-line = "":U
      then do:
         NEXT.
      end.
      { gbl/fr-print-str.i
         v-line
         p-message
         p-ok
      no-error
      }
   end.

   assign
      p-ok      = true
   .

end.
end PROCEDURE.  /* print-head-chk */

/* _UIB-CODE-BLOCK-end */
&ANALYZE-RESUME

&ANALYZE-SUSPend _UIB-CODE-BLOCK _PROCEDURE 1991 {&FRAME-NAME}
PROCEDURE 1991 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input-output  parameter p-cd-mode     as character no-undo .
define input-output  parameter p-cd-submode  as character no-undo .
define output  parameter p-message   as character no-undo .
define output  parameter p-ok        as logical   no-undo .

define variable v-rid-list    as character    no-undo.
define variable v-md    as character    no-undo.
define variable v-msg    as character    no-undo.

define buffer buf_wi-mode     for ub.wi-mode .
define buffer buf_rule-by-set for ub.rule-by-set .

do
on error undo, return error
:

   if p-cd-mode = {&cd-mode-sale}
   OR p-cd-mode = {&cd-mode-ret}
   then do:
      assign
         v-md = substitute("&1.&2", p-cd-mode, p-cd-submode)
      .
   end.
   else do:
      assign
         v-md = p-cd-mode
      .
   end.
   find first  buf_wi-mode
       where buf_wi-mode.mode-type  = {&wi-mode-ibs-th-pos}
         AND buf_wi-mode.mode-id    = v-md
       NO-LOCK
       no-error
       .
   if not available buf_wi-mode
   then do:
      assign
         p-message    = substitute( "Недоступен список функций для режима &1", v-md )
         p-ok         = true
      .
      return .
   end.

   run rul/rule-by-set-s.w ( input parparentproc
                           , input "b-sel":U /*bttns*/
                           , input "wi-mode"
                           , input buf_wi-mode.codex_id
                           , input buf_wi-mode.ruleset_id
                           , input 0 /*p-rule-id*/
                           , input-output v-rid-list
                           ) .

   if v-rid-list = "":U
   OR v-rid-list = ?
   then do:
      assign
         p-message = "Отказ от выбора функции"
         p-ok      = TRUE
      .
      return.
   end.

   find first buf_rule-by-set
      where RECID(buf_rule-by-set) = INTEGER(ENTRY(1, v-rid-list))
      no-lock
      no-error
      .
   if not available buf_rule-by-set
   then do:
      assign
         p-message = "Не найдена выбранная функция"
         p-ok      = TRUE
      .
      return.
   end.

   run value( substitute("&1", string(buf_rule-by-set.rule_id, "9999"))) in this-procedure
            ( input-output p-cd-mode
            , input-output p-cd-submode
            , output p-message
            , output p-ok
            ) no-error.

   if error-status:error
   then do:
      assign
         p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
         p-ok = FALSE
      .
      return.
   end.

   if not p-ok
   then do:
      return.
   end.


   if p-cd-mode <> {&cd-mode-block}
   then do:
      assign
         v-msg            = p-message
         v-cd-mode-pre    = p-cd-mode
         v-cd-submode-pre = p-cd-submode
      .
   end.
   run cd-context ( INPUt-OUTPUT p-cd-mode
                  , INPUt-output p-cd-submode
                  , output       p-message
                  , output       p-ok
                  ) .
   if not p-ok
   then do:
      message
         SKIP return-VALUE
         SKIP trim(error-status :get-message(1))
         SKIP trim(error-status :get-message(2))
         SKIP trim(error-status :get-message(3))
         sKIP p-message
      view-as alert-box information.
      return.
   end.

   if p-cd-mode <> {&cd-mode-block}
   then do:
      assign
         p-message        = v-msg
         v-cd-mode-pre    = p-cd-mode
         v-cd-submode-pre = p-cd-submode
      .
   end.

   return.

end.  /* do on error */
end PROCEDURE. /* 1991 */

/* _UIB-CODE-BLOCK-end */
&ANALYZE-RESUME



&ANALYZE-SUSPend _UIB-CODE-BLOCK _PROCEDURE 2000 {&FRAME-NAME}
PROCEDURE 2000 :  /* Повторная печать чека */
/*------------------------------------------------------------------------------
  Purpose:     Повторная печать чека
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input-output  parameter p-cd-mode     as character no-undo .
define input-output  parameter p-cd-submode  as character no-undo .
define output  parameter p-message   as character no-undo .
define output  parameter p-ok        as logical   no-undo .

define variable v-rid-list    as character    no-undo.
define variable v-md    as character    no-undo.
define variable v-msg    as character    no-undo.
define variable  v-count     as integer   no-undo .
define variable v-cd-mode-local    as character    no-undo.
define variable v-fr-num    as integer    no-undo.

define buffer buf_chk-doc     for ub.chk-doc .
define buffer buf_chk-gds     for ub.chk-gds .
define buffer buf_tt-line     for tt-line .
define buffer buf_goods       for ub.goods  .
define buffer buf_bar-code    for ub.bar-code .
define buffer buf_chk-pay     for ub.chk-pay .
define buffer buf_cash-pay    for ub.cash-pay .

do
on error undo, return error
:
   if p-cd-mode <> {&cd-mode-ready}
   then do:
      return.
   end.

   run str/chk-docs.w   ( input parparentproc
                        , input "b-sel"
                        , input {&cd-type-ibs-th}
                        , input ?
                        , input v-cntxt-obj-type
                        , input v-cntxt-obj-code
                        , input '':U
                        , input '':U
                        , input p-cash-num
                        , input ?
                        , input ?
                        , input integer({&rcpt-sale})
                        , output v-rid-list) no-error.

   if v-rid-list = "":U
   then do:
      assign
         p-message = "Отказ от выбора чека"
         p-ok      = TRUE
      .
      return.
   end.

   assign
      v-with-context = FALSE
      v-count = 1
   .

   _proc-body:
   DO
   on error undo, return
   :
      assign
         v-cd-mode-local = {&cd-mode-sale}
      .

      find first buf_chk-doc
         where RECID(buf_chk-doc) = INTEGER(ENTRY(v-count, v-rid-list))
         NO-lock
         no-error
         .

      if  not available buf_chk-doc
      then do:
         UNDO _proc-body, LEAVE _proc-body .
      end.

      if  buf_chk-doc.chk-type <> integer({&rcpt-sale})
      AND buf_chk-doc.chk-type <> integer({&rcpt-return})
      then do:
         UNDO _proc-body, LEAVE _proc-body .
      end.

      CREATE tt-head-check.
      assign
         tt-head-check.doc-code    = buf_chk-doc.doc-code
         v-fr-num                  = buf_chk-doc.chk-num
         tt-head-check.chk-type    = buf_chk-doc.chk-type
         /*
         tt-head-check.exch-rate   = buf_chk-doc.
         tt-head-check.exch-scales = buf_chk-doc.exch-scales
         */
         tt-head-check.cash-rate   = if v-r-b = {&r-b-base} then v-cash-rate    else 1
         tt-head-check.cash-scales = if v-r-b = {&r-b-base} then v-cash-scales  else 1
      .

      if  buf_chk-doc.src-d-card <> ?
      AND buf_chk-doc.src-d-card <> ''
      then do:
         if v-with-context
         then do:
            assign
               v-src = buf_chk-doc.src-d-card
            .
            run input-card in this-procedure ( INPUt-OUTPUT p-cd-mode
                                             , INPUt-output p-cd-submode
                                             , output p-message
                                             , output p-ok
                                             ) .
            if not p-ok then do:
               UNDO _proc-body, LEAVE _proc-body .
            end.
         end.
         else do:
            assign
               tt-head-check.d-card = buf_chk-doc.src-d-card
            .
         end.
      end.

      assign
         v-pass-gds = 0 /* integer({&gds-pass-copy}) */
      .

      for each buf_chk-gds
         where buf_chk-gds.doc-code = buf_chk-doc.doc-code
         no-lock
         ,
         first buf_bar-code
         where buf_bar-code.b-code = buf_chk-gds.b-code
         No-LOCK
         ,
         first buf_goods
         where buf_goods.gds-code = buf_bar-code.gds-code
         No-LOCK
         by buf_chk-gds.line-num
      :
         find first buf_tt-line
              where buf_tt-line.ord-chk-num  = buf_chk-gds.doc-code
                AND buf_tt-line.ord-line-num = buf_chk-gds.line-num
              no-lock no-error.
         if available buf_tt-line then NEXT.

         case buf_chk-doc.chk-type:
            when integer({&rcpt-return}) then do:
            assign
            v-write-off-code = 0
            .
            end.
            /*todo*/
         end case.

         assign
            v-src-price          = buf_chk-gds.src-price
            v-src-price-rub      = buf_chk-gds.src-price * tt-head-check.cash-scales

            v-src-discnt         = buf_chk-gds.src-discnt
            v-src-discnt-rub     = buf_chk-gds.src-discnt * tt-head-check.cash-scales

            v-src-qnty           = buf_chk-gds.src-qnty
            v-num                = 0
            v-src                = buf_chk-gds.src-code
            v-pump               = buf_chk-gds.pump
            v-nozzle-code        = buf_chk-gds.nozzle-code
            v-pl-code            = buf_chk-gds.pl-code
            v-fbr-depart         = buf_chk-gds.depart-id
            /*
            v-ord-chk-num        = buf_chk-gds.doc-code
            v-ord-line-num       = buf_chk-gds.line-num
            */
            v-chk-name           = buf_goods.chk-name
            v-gds-code           = buf_goods.gds-code
            v-src-sum-netto      = buf_chk-gds.src-price * buf_chk-gds.src-qnty
            v-src-sum-netto-rub  = buf_chk-gds.src-price * buf_chk-gds.src-qnty * tt-head-check.cash-scales
            /*
            v-src-sum            =
            v-src-sum-rub        =
            */
            v-summ-netto-rub     = v-summ-netto-rub + buf_chk-gds.src-price * buf_chk-gds.src-qnty * tt-head-check.cash-scales
         .
         run add-gds-line in this-procedure  ( INPUt-OUTPUT p-cd-mode
                                             , INPUt-output p-cd-submode
                                             , output p-message
                                             , output p-ok
                                             ) .
         if not p-ok then do:
            UNDO _proc-body, LEAVE _proc-body .
         end.
      end. /* each buf_chk-gds */

      define variable v-ii as integer no-undo .
      define variable v-jj as integer no-undo .
      define variable v-dop1 as character no-undo .
      define variable v-fr-code as integer no-undo .
      define variable v-cp-list as character no-undo .

      for each  buf_chk-pay
          where buf_chk-pay.doc-code = buf_chk-doc.doc-code
            AND buf_chk-pay.tot-rubl > 0
          no-lock
          :

         if buf_chk-pay.tot-rubl <= 0 then NEXT.

         assign
            v-src             = STRING(buf_chk-pay.tot-rubl)
            v-pay-type        = buf_chk-pay.pay-code
            v-curr-base-code  = buf_chk-pay.curr-code
         .


         if buf_chk-pay.pay-code = 1
         then do:
            assign
               v-frpay-code = 1
            .
         end.
         else
         _pay:
         DO v-ii = 1 TO num-entries(v-cp-lst, {&delim-par}):

            v-dop1 = ENTRY(v-ii, v-cp-lst, {&delim-par}).

            assign
               v-fr-code = INTEGER(ENTRY(1, v-dop1, "="))
               v-cp-list = ENTRY(2, v-dop1, "=")
            no-error.

            if v-fr-code >= 2
            AND v-fr-code <= 4 then do:

               DO v-jj = 1 TO num-entries(v-cp-list, ";"):

                  if  buf_chk-pay.pay-code   = integer(ENTRY(1, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
                  AND buf_chk-pay.curr-code  = integer(ENTRY(2, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
                  then do:
                     assign
                        /*
                        buf_temp-cash-pay-list.cdpay-code = integer(ENTRY(1, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
                        buf_temp-cash-pay-list.curr-code  = integer(ENTRY(2, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
                        buf_temp-cash-pay-list.frpay-code = v-fr-code
                        */
                        v-frpay-code = v-fr-code
                     .
                     LEAVE _pay.
                  end.
               end. /*DO v-jj = 1 TO num-entries(v-cp-list, ";"):*/

            end. /*if v-fr-code >= 2*/
         end. /**do v-ii*/
         run input-pay-sale in this-procedure ( INPUt-OUTPUT v-cd-mode-local
                                              , INPUt-output p-cd-submode
                                              , output p-message
                                              , output p-ok
                                              ) .

         if not p-ok then do:
            UNDO _proc-body, LEAVE _proc-body .
         end.

      end.

      if v-with-context
      then do:
         run set-all-summ ( output p-message
                        , output p-ok
                        ) no-error .
      end.
      assign
         v-summ-discont-rub = v-summ-netto-rub - buf_chk-doc.netto * tt-head-check.cash-scales
         v-summ-netto-rub = buf_chk-doc.netto * tt-head-check.cash-scales
      .

      run non-fisk-doc in this-procedure ( INPUt-OUTPUT v-cd-mode-local
                                         , input-output p-cd-submode
                                         , input substitute('КОПИЯ ЧЕКА &1 (&2)', v-fr-num, tt-head-check.doc-code)
                                         , output p-message
                                         , output p-ok
                                         ) .
   end. /* _proc-body */

   run clear-tt-chk in this-procedure.

   return.
end.  /* do on error */
end PROCEDURE. /* 2000  Повторная печать чека */



&ANALYZE-SUSPend _UIB-CODE-BLOCK _PROCEDURE 2007 {&FRAME-NAME}
PROCEDURE 2007 : /* товарный чек */
/*------------------------------------------------------------------------------
  Purpose:     товарный чек
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input-output  parameter p-cd-mode     as character no-undo .
define input-output  parameter p-cd-submode  as character no-undo .
define output  parameter p-message   as character no-undo .
define output  parameter p-ok        as logical   no-undo .

define variable v-rid-list    as character    no-undo.
define variable v-md    as character    no-undo.
define variable v-msg    as character    no-undo.
define variable  v-count     as integer   no-undo .
define variable v-cd-mode-local    as character    no-undo.

define buffer buf_chk-doc     for ub.chk-doc .
define buffer buf_chk-gds     for ub.chk-gds .
define buffer buf_tt-line     for tt-line .
define buffer buf_goods       for ub.goods  .
define buffer buf_bar-code    for ub.bar-code .
define buffer buf_chk-pay     for ub.chk-pay .
define buffer buf_cash-pay    for ub.cash-pay .

do
on error undo, return error
:
   if p-cd-mode = {&cd-mode-ready}
   then do:

      run str/chk-docs.w   ( input parparentproc
                           , input "b-sel"
                           , input {&cd-type-ibs-th}
                           , input ?
                           , input v-cntxt-obj-type
                           , input v-cntxt-obj-code
                           , input '':U
                           , input '':U
                           , input p-cash-num
                           , input ?
                           , input ?
                           , input integer({&rcpt-sale})
                           , output v-rid-list
                           ) no-error.

      if v-rid-list = "":U
      then do:
         assign
            p-message = "Отказ от выбора чека"
            p-ok      = TRUE
         .
         return.
      end.


      assign
         v-with-context = FALSE
         v-count = 1
      .

      _proc-body:
      DO
      on error undo, return
      :
         assign
            v-cd-mode-local = {&cd-mode-sale}
         .

         find first buf_chk-doc
            where RECID(buf_chk-doc) = INTEGER(ENTRY(v-count, v-rid-list))
            NO-lock
            no-error
            .

         if  not available buf_chk-doc
         then do:
            UNDO _proc-body, LEAVE _proc-body .
         end.

         if  buf_chk-doc.chk-type <> integer({&rcpt-sale})
         AND buf_chk-doc.chk-type <> integer({&rcpt-return})
         then do:
            UNDO _proc-body, LEAVE _proc-body .
         end.

         CREATE tt-head-check.
         assign
            tt-head-check.doc-code    = buf_chk-doc.doc-code
            tt-head-check.chk-type    = buf_chk-doc.chk-type
            /*
            tt-head-check.exch-rate   = buf_chk-doc.
            tt-head-check.exch-scales = buf_chk-doc.exch-scales
            */
            tt-head-check.cash-rate   = if v-r-b = {&r-b-base} then v-cash-rate    else 1
            tt-head-check.cash-scales = if v-r-b = {&r-b-base} then v-cash-scales  else 1
         .

         if  buf_chk-doc.src-d-card <> ?
         AND buf_chk-doc.src-d-card <> ''
         then do:
            if v-with-context
            then do:
               assign
                  v-src = buf_chk-doc.src-d-card
               .
               run input-card in this-procedure ( INPUt-OUTPUT p-cd-mode
                                                , INPUt-output p-cd-submode
                                                , output p-message
                                                , output p-ok
                                                ) .
               if not p-ok then do:
                  UNDO _proc-body, LEAVE _proc-body .
               end.
            end.
            else do:
               assign
                  tt-head-check.d-card = buf_chk-doc.src-d-card
               .
            end.
         end.

         assign
            v-pass-gds = 0 /* integer({&gds-pass-copy}) */
         .

         for each buf_chk-gds
            where buf_chk-gds.doc-code = buf_chk-doc.doc-code
            no-lock
            ,
            first buf_bar-code
            where buf_bar-code.b-code = buf_chk-gds.b-code
            No-LOCK
            ,
            first buf_goods
            where buf_goods.gds-code = buf_bar-code.gds-code
            No-LOCK
            by buf_chk-gds.line-num
         :
            find first buf_tt-line
               where buf_tt-line.ord-chk-num  = buf_chk-gds.doc-code
                  AND buf_tt-line.ord-line-num = buf_chk-gds.line-num
               no-lock no-error.
            if available buf_tt-line then NEXT.

            case buf_chk-doc.chk-type:
               when integer({&rcpt-return}) then do:
               assign
               v-write-off-code = 0
               .
               end.
               /*todo*/
            end case.

            assign
               v-src-price          = buf_chk-gds.src-price
               v-src-price-rub      = buf_chk-gds.src-price * tt-head-check.cash-scales

               v-src-discnt         = buf_chk-gds.src-discnt
               v-src-discnt-rub     = buf_chk-gds.src-discnt * tt-head-check.cash-scales

               v-src-qnty           = buf_chk-gds.src-qnty
               v-num                = 0
               v-src                = buf_chk-gds.src-code
               v-pump               = buf_chk-gds.pump
               v-nozzle-code        = buf_chk-gds.nozzle-code
               v-pl-code            = buf_chk-gds.pl-code
               v-fbr-depart         = buf_chk-gds.depart-id
               /*
               v-ord-chk-num        = buf_chk-gds.doc-code
               v-ord-line-num       = buf_chk-gds.line-num
               */
               v-chk-name           = buf_goods.chk-name
               v-gds-code           = buf_goods.gds-code
               v-src-sum-netto      = buf_chk-gds.src-price * buf_chk-gds.src-qnty
               v-src-sum-netto-rub  = buf_chk-gds.src-price * buf_chk-gds.src-qnty * tt-head-check.cash-scales
               /*
               v-src-sum            =
               v-src-sum-rub        =
               */
               v-summ-netto-rub     = v-summ-netto-rub + buf_chk-gds.src-price * buf_chk-gds.src-qnty * tt-head-check.cash-scales
            .
            run add-gds-line in this-procedure  ( INPUt-OUTPUT p-cd-mode
                                                , INPUt-output p-cd-submode
                                                , output p-message
                                                , output p-ok
                                                ) .
            if not p-ok then do:
               UNDO _proc-body, LEAVE _proc-body .
            end.
         end. /* each buf_chk-gds */

         define variable v-ii as integer no-undo .
         define variable v-jj as integer no-undo .
         define variable v-dop1 as character no-undo .
         define variable v-fr-code as integer no-undo .
         define variable v-cp-list as character no-undo .

         for each  buf_chk-pay
            where buf_chk-pay.doc-code = buf_chk-doc.doc-code
            no-lock
            :

            if buf_chk-pay.tot-rubl <= 0 then NEXT.

            assign
               v-src             = STRING(buf_chk-pay.tot-rubl)
               v-pay-type        = buf_chk-pay.pay-code
               v-curr-base-code  = buf_chk-pay.curr-code
            .


            if buf_chk-pay.pay-code = 1
            then do:
               assign
                  v-frpay-code = 1
               .
            end.
            else
            _pay:
            DO v-ii = 1 TO num-entries(v-cp-lst, {&delim-par}):

               v-dop1 = ENTRY(v-ii, v-cp-lst, {&delim-par}).

               assign
                  v-fr-code = INTEGER(ENTRY(1, v-dop1, "="))
                  v-cp-list = ENTRY(2, v-dop1, "=")
               no-error.

               if v-fr-code >= 2
               AND v-fr-code <= 4 then do:

                  DO v-jj = 1 TO num-entries(v-cp-list, ";"):

                     if  buf_chk-pay.pay-code = integer(ENTRY(1, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
                     AND buf_chk-pay.curr-code  = integer(ENTRY(2, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
                     then do:
                        assign
                           /*
                           buf_temp-cash-pay-list.cdpay-code = integer(ENTRY(1, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
                           buf_temp-cash-pay-list.curr-code  = integer(ENTRY(2, ENTRY(v-jj, v-cp-list, ";"), chr(58)))
                           buf_temp-cash-pay-list.frpay-code = v-fr-code
                           */
                           v-frpay-code = v-fr-code
                        .
                        LEAVE _pay.
                     end.
                  end. /*DO v-jj = 1 TO num-entries(v-cp-list, ";"):*/

               end. /*if v-fr-code >= 2*/
            end. /**do v-ii*/
            run input-pay-sale in this-procedure ( INPUt-OUTPUT v-cd-mode-local
                                                , INPUt-output p-cd-submode
                                                , output p-message
                                                , output p-ok
                                                ) .

            if not p-ok then do:
               UNDO _proc-body, LEAVE _proc-body .
            end.

         end.

         if v-with-context
         then do:
            run set-all-summ ( output p-message
                           , output p-ok
                           ) no-error .
         end.
         assign
            v-summ-discont-rub = v-summ-netto-rub - buf_chk-doc.netto * tt-head-check.cash-scales
            v-summ-netto-rub = buf_chk-doc.netto * tt-head-check.cash-scales
         .

         run non-fisk-doc in this-procedure ( INPUt-OUTPUT v-cd-mode-local
                                          , input-output p-cd-submode
                                          , input substitute('ТОВАРНЫЙ ЧЕК &1 (&2)', buf_chk-doc.chk-num, buf_chk-doc.doc-code)
                                          , output p-message
                                          , output p-ok
                                          ) .

      end. /* _proc-body */

      run clear-tt-chk in this-procedure.
   end.
   else do:
      define buffer buf_rule-call-param   for ub.rule-call-param .

      for each  buf_rule-call-param
            where buf_rule-call-param.call_id = buf_temp-layout-elem-rule.uniq-key-rec
            no-lock
         :
         case buf_rule-call-param.param-name:
            WHEN "p-close"
            then do:
               if  buf_rule-call-param.param-value-logical <> ?
               then
                  assign
                     v-close-good-chk = buf_rule-call-param.param-value-logical
                  .
            end.
            OTHERWISE DO:
            end.
         end case.
      end.

      run non-fisk-doc in this-procedure ( INPUt-OUTPUT p-cd-mode
                                         , input-output p-cd-submode
                                         , input 'ТОВАРНЫЙ ЧЕК'
                                         , output p-message
                                         , output p-ok
                                         ) .
      assign
         v-close-good-chk = FALSE
      .
   end.

   return.
end.  /* do on error */
end PROCEDURE. /* 2007 товарный чек */


/* _UIB-CODE-BLOCK-end */
&ANALYZE-RESUME


&ANALYZE-SUSPend _UIB-CODE-BLOCK _PROCEDURE get-time-close {&FRAME-NAME}
PROCEDURE get-time-close :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define output parameter p-time as integer          no-undo.
do
on error undo, return error
:
   if v-time-close <> 0
   then do:
      assign
         p-time = TIME - v-time-close
      .
   end.
end.  /* do on error */
end PROCEDURE. /* get-time-close */

/* _UIB-CODE-BLOCK-end */
&ANALYZE-RESUME



&ANALYZE-SUSPend _UIB-CODE-BLOCK _PROCEDURE reset-time-close {&FRAME-NAME}
PROCEDURE reset-time-close :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
   assign
      v-time-close = 0
   .
end.  /* do on error */
end PROCEDURE. /* reset-time-close */

/* _UIB-CODE-BLOCK-end */
&ANALYZE-RESUME








/*==========================================================================*/
procedure accum-chk-gds :
define input   parameter p-code     as character   no-undo .
define output  parameter p-found    as logical   no-undo .
define output  parameter p-gds-qnty as decimal   no-undo .

define buffer buf_chk-gds        for ub.chk-gds .
define buffer buf_tt-open-check  for tt-open-check .
define buffer buf_tt-line        for tt-line .

do
on error undo, return error
:
   for each buf_tt-open-check
      where buf_tt-open-check.chk-type = INTEGER({&rcpt-sale})
      no-lock
      :
         assign
            p-found    = TRUE
         .
         for each buf_chk-gds
            where buf_chk-gds.doc-code = buf_tt-open-check.doc-code
            AND   buf_chk-gds.src-code = p-code
            NO-LOCK
            :
            assign
               p-gds-qnty = p-gds-qnty + ABS(buf_chk-gds.src-qnty)
            .
         end.
   end.
end. /* do on error */
end procedure. /* accum-chk-gds */



/*==========================================================================*/
procedure accum-curr-chk-gds :
define input   parameter p-gds-code  as character   no-undo .
define output  parameter p-gds-qnty  as decimal   no-undo .

define buffer buf_tt-line     for tt-line .

do
on error undo, return error
:
   for each buf_tt-line
      where buf_tt-line.type = 0
        AND buf_tt-line.src  = p-gds-code
      :
      assign
         p-gds-qnty = p-gds-qnty + ABS(buf_tt-line.qnty)
      .
   end.
end. /* do on error */
end procedure. /* accum-curr-chk-gds */





/*==========================================================================*/
procedure summ-for-pay :
define input-output  parameter p-cd-mode     as character        no-undo .
define input-output  parameter p-cd-submode  as character      no-undo .
define output parameter p-message     as character      no-undo .
define output parameter p-ok          as logical          no-undo.

define buffer buf_tt-head-check  for tt-head-check .
define buffer buf_tt-line        for tt-line .

define variable v-pline-num as integer no-undo .
define variable v-mode as character no-undo .
define variable v-pass-pay as integer no-undo .
define variable v-pay-card as character no-undo .
define variable v-tot-sum as decimal no-undo .
define variable v-tot-rubl as decimal no-undo .
define variable v-tot-base as decimal no-undo .
define variable v-par-code as integer   no-undo .
define variable v-src-qnty as decimal no-undo .
define variable v-get-qnty-method as character no-undo .
define variable v-2-cdpay-code as integer no-undo .
define variable v-2-curr-code as integer no-undo .
define variable v-2-tot-base as decimal no-undo .
define variable v-2-tot-rubl as decimal no-undo .
define variable v-2-frpay-code as integer no-undo .

define variable v-src-discnt-local    as decimal      no-undo.
define variable v-src-discnt-local-rub    as decimal      no-undo.
define variable v-for-discnt-local-doc    as decimal no-undo .
define variable v-for-discnt-local-rubl   as decimal no-undo .
define variable v-for-discnt-local-r-b    as decimal no-undo .

do
on error undo, return error
:
   find buf_tt-head-check.
   find last buf_tt-line where buf_tt-line.type = 1 no-error.
   if not available buf_tt-head-check
   then do:
      assign
         v-sum-for-pay = 0
      .
   end.
   if p-cd-submode = {&cd-submode-pay}
   then do:
      assign
         v-pline-num = if available buf_tt-line then buf_tt-line.num + 1 else 1
         v-mode = 'check'
         v-pass-pay  = 0
         v-pay-card  = "0"
         v-tot-sum   = ?
         v-tot-rubl  = ?
         v-tot-base  = ?
      .

      assign
         v-frpay-code = ?
      .

      { str/libthpos_pay-line.i
         buf_tt-head-check.doc-code
         v-pline-num
         v-mode
         v-pay-type
         v-curr-base-code
         v-par-code
         v-src-qnty
         v-frpay-code
         v-pass-pay
         v-pay-card
         v-tot-sum
         v-sum-for-pay
         v-tot-base
         v-get-qnty-method
         v-2-cdpay-code
         v-2-curr-code
         v-2-frpay-code
         v-2-tot-sum
         v-2-tot-rubl
         v-2-tot-base
         v-src-discnt
         v-src-discnt-rub
         v-for-discnt-doc
         v-for-discnt-rubl
         v-for-discnt-r-b
         p-ok
         no-error
      }
      if error-status:error
      then do:
         assign
            p-message = substitute("&1 &2 &3", error-status:get-message(1), return-value, p-message)
            p-ok = FALSE
            v-sum-for-pay = 0
         .
         return.
      end.
      return.
   end.
   else do:
      assign
         v-sum-for-pay = 0
         p-ok = FALSE
      .
      return.
   end.

   /*
   if not v-emul-mode
   and    v-with-context
   then do:
      { gbl/disp-str.i
         v-disp-msg-1
         v-disp-msg-2
         p-message
         p-ok
      }
   end.
   else do:
      assign
         p-ok = TRUE
      .
   end.
   assign
      p-message = v-disp-msg-1 + " ":U + v-disp-msg-2
   .
   */

end. /* do on error */
end PROCEDURE. /* summ-for-pay */




/*==========================================================================*/
procedure wth-type-select:
define input-output  parameter p-cd-mode     as character no-undo .
define input-output  parameter p-cd-submode  as character no-undo .
define output        parameter p-message     as character no-undo .
define output        parameter p-ok          as logical   no-undo .

define variable v-chk-type    as character    no-undo.

do
on error undo, return error
:

   run gbl/d-list.w  ( input "b-sel":U
                     , input "Выберите тип чека МЦ"
                     , input {&comma-char} + {&cd-fund} + {&comma-char} + {&encashment}
                     , input "Тип чека МЦ не задан" + {&comma-char} + "Кассовый фонд" + {&comma-char} + {&encashment-full}
                     , input {&comma-char}
                     , input "":U
                     , output v-chk-type
                     ) .
   if v-chk-type = "":u then do:
      assign
         p-message = "Не выбран тип чека МЦ"
      .
      return.
   end.
   case v-chk-type:
      WHEN {&cd-fund}
      then do:
         run chk-fnd-open  ( INPUt-OUTPUT p-cd-mode
                           , INPUt-output p-cd-submode
                           , output p-message
                           , output p-ok
                           ) .
      end.
      WHEN {&encashment}
      then do:
         run chk-inc-open  ( INPUt-OUTPUT p-cd-mode
                           , INPUt-output p-cd-submode
                           , output p-message
                           , output p-ok
                           ) .
      end.
      OTHERWISE DO:
      end.
   end case.

end. /* do on error */
end procedure.  /* wth-type-select */




/*==========================================================================*/
procedure reset-summ-for-pay :

do
on error undo, return error
:
   assign
      v-sum-for-pay  = 0
   .
   return.

end. /* do on error */
end PROCEDURE. /* summ-for-pay */




/*==========================================================================*/
procedure disc-type-select:
define output        parameter p-message     as character no-undo .
define output        parameter p-ok          as logical   no-undo .

define variable v-chk-type    as character    no-undo.

do
on error undo, return error
:

   run gbl/d-list.w  ( input "b-sel":U
                     , input "Выберите тип скидки"
                     , input {&comma-char} + {&discnt-v-sum} + {&comma-char} + {&discnt-v-pcnt}
                     , input "Тип чека МЦ не задан" + {&comma-char} + "Абсолютная скидка" + {&comma-char} + "Процентная скидка"
                     , input {&comma-char}
                     , input "":U
                     , output v-disc-type
                     ) .
   if v-disc-type = "":u then do:
      assign
         p-message = "Не выбран тип скидки"
      .
      return.
   end.
   case v-disc-type:
      WHEN {&discnt-v-sum}
      then do:
         assign
            p-message = "Абсолютная скидка на товарную строку"
            p-ok      = TRUE
         .
      end.
      WHEN {&discnt-v-pcnt}
      then do:
         assign
            p-message = "Процентная скидка на товарную строку"
            p-ok      = TRUE
         .
      end.
      OTHERWISE DO:
         assign
            p-message = substitute("Неизвестный тип скидки - &1",v-disc-type)
         .
      end.
   end case.

end. /* do on error */
end procedure.  /* disc-type-select */



/*==========================================================================*/
procedure wait-wth-type :
define output        parameter p-message     as character no-undo .
define output        parameter p-ok          as logical   no-undo .

do
on error undo, return error
:
   assign
      p-message = "Выберите тип чека МЦ"
      p-ok      = FALSE
   .
   return.
end. /* do on error */
end procedure. /* wait-wth-type */


/*==========================================================================*/
procedure export-chk-to-xml :
define output        parameter p-message     as character no-undo .
define output        parameter p-ok          as logical   no-undo .

do
on error undo, return error
:
  { str/libthpos_print-dataset.i yes no-error }

end. /* do on error */
end procedure. /* export-chk-to-xml */
