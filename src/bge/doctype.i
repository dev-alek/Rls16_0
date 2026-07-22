/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ћассив дл€ работы с типами документов

јвтор: ’ныкин ѕавел јндреевич
ƒата создани€: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

&global-define doctype-extent 54
&global-define doctype-types-amount 18

define variable v-doctype-type-list as character extent {&doctype-extent} init
[
      "приход внешний"                      , {&TDEDT_Pri_Vnesh}          , "ie"
    , "расход внешний"                      , {&TDEDT_Ras_Vnesh}          , "ee"
    , "расход внешний возврат поставщику"   , {&TDEDT_Ras_Vnesh_VP}       , "ep"
    , "расход внешний продажа через кассу"  , {&TDEDT_Ras_Vnesh_Kass}     , "es"
    , "возврат внешний"                     , {&TDEDT_Vozvrat_Vnesh}      , "re"
    , "возврат внешний через кассу"         , {&TDEDT_Vozvrat_Vnesh_Kass} , "rs"
    , "списание внешнее"                    , {&TDEDT_Spi_Vnesh}          , "we"
    , "инвентаризаци€"                      , {&TDEDT_Inv}                , "vt"
    , "приход перемещение"                  , {&TDEDT_Pri_Perem}          , "iv"
    , "расход перемещение"                  , {&TDEDT_Ras_Perem}          , "ev"
    , "возврат перемещение"                 , {&TDEDT_Vozvrat_Perem}      , "rv"
    , "списание производство"               , {&TDEDT_Spi_Prvo}           , "wm"
    , "приход производство"                 , {&TDEDT_Pri_Prvo}           , "im"
    , "документ переоценки"                 , {&TDEDT_Overturn}           , "ot"
    , "коррекци€ учетных цен"               , {&TDEDT_Corr_Acc_Price}     , "ap"
    , "корректировка отрицательных партий"  , {&TDEDT_Corr_Minus_Parts}   , "mp"
    , "смена типа приобретени€"             , {&TDEDT_Chg_Purch_Code}     , "pc"
    , "пересортица"                         , {&TDEDT_Peresort}           , "vp"
] no-undo.

/* $Workfile$ e n d */