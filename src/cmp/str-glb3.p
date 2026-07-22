block-level on error undo, throw.
/*

$Revision: 8ed7340f1c34, 3424, rls $
$Author: DRuban $
$Date: 2023/10/16 15:13:31 $
$Workfile: str-glb3.p $
$Archive: cmp/str-glb3.p $

Программа генерации файла s t r - g l b l . i . Часть 3

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Инструкции по использованию см в файле s t r - g l b l . p

*/

define input  parameter p-file-name    as character no-undo .
define output parameter p-num-lines    as character no-undo .
define output parameter p-vss-revision as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 8ed7340f1c34, 3424, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:31 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: str-glb3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/str-glb3.p $":U .
define variable vss-description as character no-undo init "Программа генерации файла str-glbl.i".
{ cmp/vssrevis.i }
{ cmp/filwrlib.i }
{ cmp/tbl-name.i }
{ cmp/tblbname.i }
{ cmp/tblfname.i }

&glob language {1}

&glob tilda ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
&glob scop-begin ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~&
&glob scop-end   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

&if "{&language}" = "rus"  &then
  &glob lang-value        3
  &glob lang-description  4
&elseif "{&language}" = "eng" &then
  &glob lang-value        5
  &glob lang-description  6
&else
  message
    "Необходимо задать указать язык используемый для генерации str-glbl.i" skip
    "В качестве параметра компиляции необходимо задать 'rus' или 'eng'" skip
    view-as alert-box .
  return error .
&endif


run filwrlib_set-file-name in this-procedure
  (input p-file-name
  ) .

assign
  p-vss-revision = vss-revision
.

/* расчет налога с продажи и НДС по 1 gds-dtl */

&glob road-tax-cur ub.doc-line.road-tax ~~~~~~~{&rate-calc-rubl-base}
run filwrlib_append-new-line in this-procedure ( input "&global-define road-tax-cur {&road-tax-cur}" ).
&glob SLT-calc (ub.gds-dtl.price-~~~~~~~{&ext-rubl-base} - ub.gds-dtl.discnt-~~~~~~~{&ext-rubl-base} - ~~~~~~~{&road-tax-cur}) ~
                          * ub.doc-line.SLT-pc / (100 + ub.doc-line.SLT-pc)
run filwrlib_append-new-line in this-procedure ( input "&global-define SLT-calc {&SLT-calc}" ).
&glob VAT-calc (ub.gds-dtl.price-~~~~~~~{&ext-rubl-base} - ub.gds-dtl.discnt-~~~~~~~{&ext-rubl-base} - ~~~~~~~{&road-tax-cur} - ~~~~~~~{&SLT-calc}) ~
                          * ub.doc-line.VAT-pc / (100 + ub.doc-line.VAT-pc)
run filwrlib_append-new-line in this-procedure ( input "&global-define VAT-calc {&VAT-calc}" ).
&glob VAT-calc-no-SLT (ub.gds-dtl.price-~~~~~~~{&ext-rubl-base} - ub.gds-dtl.discnt-~~~~~~~{&ext-rubl-base} - ~~~~~~~{&road-tax-cur}) ~
                          * ub.doc-line.VAT-pc / (100 + ub.doc-line.VAT-pc)
run filwrlib_append-new-line in this-procedure ( input "&global-define VAT-calc-no-SLT {&VAT-calc-no-SLT}" ).


/* Коды вида покупки товаров от покупателя*/
{ cmp/cr-prep.i 1 repayment-code             1 "выкуп"                  1  "repayment-code"        }
{ cmp/cr-prep.i 1 consignation-code          2 "консигнация"            2  "consignation-code"     }
{ cmp/cr-prep.i 1 responsible-storage-code   3 "ответственное хранение" 3  "responsible-storage-code" }
{ cmp/cr-prep.i 1 old-consignation-code      4 "старая консигнация"     4  "old-consignation-code" }

&glob purchase-codes '{&bef-repayment-code},{&bef-consignation-code},{&bef-responsible-storage-code},{&bef-old-consignation-code}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define purchase-codes {&purchase-codes}" ).
&glob purchase-codes-full '{&bef-repayment-code-full},{&bef-consignation-code-full},{&bef-responsible-storage-code-full},{&bef-old-consignation-code-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define purchase-codes-full {&purchase-codes-full}" ).
&glob purchase-box-full '{&bef-repayment-code-full}':U,'{&bef-consignation-code-full}':U,'{&bef-responsible-storage-code-full}':U,'{&bef-old-consignation-code-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define purchase-box-full {&purchase-box-full}" ).
&glob purchase-input-box-full '{&bef-repayment-code-full}':U,'{&bef-consignation-code-full}':U,'{&bef-responsible-storage-code-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define purchase-input-box-full {&purchase-input-box-full}" ).
&glob purchase-input-codes '{&bef-repayment-code},{&bef-consignation-code},{&bef-responsible-storage-code}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define purchase-input-codes {&purchase-input-codes}" ).
&glob purchase-input-codes-full '{&bef-repayment-code-full},{&bef-consignation-code-full},{&bef-responsible-storage-code-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define purchase-input-codes-full {&purchase-input-codes-full}" ).
&glob purchase-codes-name entry (lookup (~~~~~~~{&purchase-code}, {&purchase-codes}), {&purchase-codes-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define purchase-codes-name {&purchase-codes-name}" ).
&glob purchase-input-codes-name entry (lookup (~~~~~~~{&purchase-code}, {&purchase-input-codes}), {&purchase-input-codes-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define purchase-input-codes-name {&purchase-input-codes-name}" ).


/*Препроцессинги для библиотек lib-calc*/
{ cmp/cr-prep.i 1 old-consignation-code      4 "старая консигнация"     4  "old-consignation-code" }
{ cmp/cr-prep.i 1 sum-general          "основная_сумма"                             " " "general_summa"                              }
{ cmp/cr-prep.i 1 sum-general-sign     "основная_сумма_со_знаком"                   " " "general_summa_with_sign"                    }
{ cmp/cr-prep.i 1 sum-repayment        "сумма_по_выкупу"                            " " "summa_on_repayment"                         }
{ cmp/cr-prep.i 1 sum-repayment-sign   "сумма_по_выкупу_со_знаком"                  " " "summa_on_repayment_with_sign"               }
{ cmp/cr-prep.i 1 sum-old-cons         "сумма_по_старой_консигнации"                " " "summa_on_old_consignation"                  }
{ cmp/cr-prep.i 1 sum-old-cons-sign    "сумма_по_старой_консигнации_со_знаком"      " " "summa_on_old_consignation_with_sign"        }
{ cmp/cr-prep.i 1 sum-cons_acc         "сумма_по_консигнации_закупка"               " " "summa_on_consignation_purchase"             }
{ cmp/cr-prep.i 1 sum-cons_acc-sign    "сумма_по_консигнации_закупка_со_знаком"     " " "summa_on_consignation_purchase_with_sign"   }
{ cmp/cr-prep.i 1 sum-cons_benf        "сумма_по_консигнации_выгода"                " " "summa_on_consignation_benefit"              }
{ cmp/cr-prep.i 1 sum-cons_benf-sign   "сумма_по_консигнации_выгода_со_знаком"      " " "summa_on_consignation_benefit_with_sign"    }
{ cmp/cr-prep.i 1 sum-resp_stor        "сумма_по_ответственному_хранению"           " " "summa_on_resp_stor"                         }
{ cmp/cr-prep.i 1 sum-resp_stor-sign   "сумма_по_ответственному_хранению_со_знаком" " " "summa_on_resp_stor_with_sign"               }
{ cmp/cr-prep.i 1 sum-office           "сумма_по_услуге"                            " " "summa_on_office"                            }
{ cmp/cr-prep.i 1 sum-office-sign      "сумма_по_услуге_со_знаком"                  " " "summa_on_office_with_sign"                  }






/* Получение типа прохождения скидки на кассе через его числовой код */
{ cmp/cr-prep.i 1 discnt-p-auto               0                Авто                  0   Auto  }
{ cmp/cr-prep.i 1 discnt-p-manual             1                Вручную               1   Manual}
{ cmp/cr-prep.i 1 discnt-p-cdm                2                КМ                    2   CDM}
{ cmp/cr-prep.i 1 discnt-p-cash-desk          3                ККМ                   3   CD}
{ cmp/cr-prep.i 1 discnt-p-TD                 6                ТУ                    6   TD}


&glob pass-discnt-name entry (lookup (~~~~~~~{&pass-discnt-code}, ~
'{&bef-discnt-p-auto}~
,{&bef-discnt-p-manual}~
,{&bef-discnt-p-cdm}~
,{&bef-discnt-p-cash-desk}~
,{&bef-discnt-p-td}~
':U), ~
'{&bef-discnt-p-auto-full}~
,{&bef-discnt-p-manual-full}~
,{&bef-discnt-p-cdm-full}~
,{&bef-discnt-p-cash-desk-full}~
,{&bef-discnt-p-td-full}~
':U)
run filwrlib_append-new-line in this-procedure ( input "&global-define pass-discnt-name {&pass-discnt-name}" ).

/* Получение типа объекта приложения скидки на кассе через его числовой код */
{ cmp/cr-prep.i 1 discnt-unknown            0                Неизв                 0   Unknown }
{ cmp/cr-prep.i 1 discnt-gds                1                Товар                 1   Goods }
{ cmp/cr-prep.i 1 discnt-sub-total          2                Подитог               2   Sub-total }
{ cmp/cr-prep.i 1 discnt-total              3                Итог                  3   Total }
{ cmp/cr-prep.i 1 discnt-receipt            4                Чек                   4   Receipt }
{ cmp/cr-prep.i 1 discnt-payment            5                Оплата                5   Payment }
{ cmp/cr-prep.i 1 discnt-gds-without-discnt 7                Товар_б/итог.скидки   7   Gds-W/Cash-discnt }
{ cmp/cr-prep.i 1 discnt-grp                8                Группа                8   Department }

&glob discnt-target-list  '{&bef-discnt-unknown},{&bef-discnt-gds},{&bef-discnt-sub-total},{&bef-discnt-total},{&bef-discnt-receipt},{&bef-discnt-payment},{&bef-discnt-gds-without-discnt},{&bef-discnt-grp}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define discnt-target-list {&discnt-target-list}" ).

&glob discnt-target-list-full '{&bef-discnt-unknown-full},{&bef-discnt-gds-full},{&bef-discnt-sub-total-full},{&bef-discnt-total-full},{&bef-discnt-receipt-full},{&bef-discnt-payment-full},{&bef-discnt-gds-without-discnt-full},{&bef-discnt-grp-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define discnt-target-list-full {&discnt-target-list-full}" ).

&glob discnt-target-name entry (lookup (~~~~~~~{&discnt-target-code}, ~{&discnt-target-list~}), ~{&discnt-target-list-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define discnt-target-name {&discnt-target-name}" ).

{ cmp/cr-prep.i 1 discnt-v-type-manual     discnt-v-type-manual   "Тип знач.ручн.ск-ки"  discnt-v-type-manual   "Manual Discnt Value Type" }

/* Получение типа значения скидки через его числовой код */
{ cmp/cr-prep.i 1 discnt-v-unknown          0                ?                     0   ? }
{ cmp/cr-prep.i 1 discnt-v-pcnt             1                %                     1   % }
{ cmp/cr-prep.i 1 discnt-v-abs              2                Абс                   2   Abs }
{ cmp/cr-prep.i 1 discnt-v-FP               3                ФЦ                    3   FP  }
{ cmp/cr-prep.i 1 discnt-v-radio-integer    4                опция                 4   option  }
{ cmp/cr-prep.i 1 discnt-v-bonus            5                Бонус                 5   Bonus  }
{ cmp/cr-prep.i 1 discnt-v-dis-kat          6                Категория             6   Category  }
{ cmp/cr-prep.i 1 discnt-v-flag             7                Флаг                  7   Flag  }
{ cmp/cr-prep.i 1 discnt-v-dis-rule         8                Правило               8   Dis-Rule  }
{ cmp/cr-prep.i 1 discnt-v-hybrid1          9                %-Абс-ФЦ              9   %-Abs-FP  }
{ cmp/cr-prep.i 1 discnt-v-sum             10                Сумма                10   Sum }
{ cmp/cr-prep.i 1 discnt-v-pdf-pcnt        11                ТПЛ-%                11   PDF-pcnt  }
{ cmp/cr-prep.i 1 discnt-v-pdf-FP          12                ТПЛ-ФЦ               12   PDF-FP  }
{ cmp/cr-prep.i 1 discnt-v-pdf-abs         13                ТПЛ-абс              13   PDF-abs  }
{ cmp/cr-prep.i 1 discnt-v-gift            14                Подарок              14   Gift  }

&glob discnt-v-list  '{&bef-discnt-v-unknown}~
,{&bef-discnt-v-pcnt}~
,{&bef-discnt-v-abs}~
,{&bef-discnt-v-FP}~
,{&bef-discnt-v-radio-integer}~
,{&bef-discnt-v-bonus}~
,{&bef-discnt-v-dis-kat}~
,{&bef-discnt-v-flag}~
,{&bef-discnt-v-dis-rule}~
,{&bef-discnt-v-hybrid1}~
,{&bef-discnt-v-sum}~
,{&bef-discnt-v-pdf-pcnt}~
,{&bef-discnt-v-pdf-FP}~
,{&bef-discnt-v-pdf-abs}~
,{&bef-discnt-v-gift}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define discnt-v-list {&discnt-v-list}" ).

&glob discnt-v-list-full '{&bef-discnt-v-unknown-full}~
,{&bef-discnt-v-pcnt-full}~
,{&bef-discnt-v-abs-full}~
,{&bef-discnt-v-FP-full}~
,{&bef-discnt-v-radio-integer-full}~
,{&bef-discnt-v-bonus-full}~
,{&bef-discnt-v-dis-kat-full}~
,{&bef-discnt-v-flag-full}~
,{&bef-discnt-v-dis-rule-full}~
,{&bef-discnt-v-hybrid1-full}~
,{&bef-discnt-v-sum-full}~
,{&bef-discnt-v-pdf-pcnt-full}~
,{&bef-discnt-v-pdf-FP-full}~
,{&bef-discnt-v-pdf-abs-full}~
,{&bef-discnt-v-gift-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define discnt-v-list-full {&discnt-v-list-full}" ).

&glob discnt-v-name entry (lookup (~~~~~~~{&discnt-v-code}, ~{&discnt-v-list~}), ~{&discnt-v-list-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define discnt-v-name {&discnt-v-name}" ).

/* Получение типа скидки на кассе через его числовой код */
{ cmp/cr-prep.i 1 discnt-t-unknown          0                ?                     0   ?      }
{ cmp/cr-prep.i 1 discnt-t-d-card           1                Клиент                1   Client }
{ cmp/cr-prep.i 1 discnt-t-std              2                Стандарт              2   Standard }
{ cmp/cr-prep.i 1 discnt-t-time             3                Временная             3   Time }
{ cmp/cr-prep.i 1 discnt-t-qnty             4                Количество            4   Qnty }
{ cmp/cr-prep.i 1 discnt-t-sum              5                Сумма                 5   Sum }
{ cmp/cr-prep.i 1 discnt-t-staff            6                Персонал              6   Staff }
{ cmp/cr-prep.i 1 discnt-t-promo            7                Промо                 7   Promo }
{ cmp/cr-prep.i 1 discnt-t-mark-down        8                Уценка                8   Mark-Down }
{ cmp/cr-prep.i 1 discnt-t-hour             9                Счастл.час            9   Happy-Hour }
{ cmp/cr-prep.i 1 discnt-t-set             10                Комплект             10   Set }
{ cmp/cr-prep.i 1 discnt-t-season          11                Сезонная             11   Season }
{ cmp/cr-prep.i 1 discnt-t-categ           12                Катег                12   Categ }
{ cmp/cr-prep.i 1 discnt-t-manual          13                Ручная               13   Manual }
{ cmp/cr-prep.i 1 discnt-t-d-mask          14                Карта-маска          14   Card-Mask }
{ cmp/cr-prep.i 1 discnt-t-round           15                "Округл. в пользу.клиента"       15   "For Clients Ben-t Round-off" }
{ cmp/cr-prep.i 1 discnt-t-template        16                "Катег с исп шаблона" 16   "Categ. Template Discnt." }
{ cmp/cr-prep.i 1 discnt-t-abs             17                Абсолютная            17   Absolute }
{ cmp/cr-prep.i 1 discnt-t-group           18                Группа                18   Group }
{ cmp/cr-prep.i 1 discnt-t-payment         19                Платеж                19   Payment }
{ cmp/cr-prep.i 1 discnt-t-cashloyal       20                ЛНР                  20   "Cash Loyality" }
{ cmp/cr-prep.i 1 discnt-t-cashround       21                Округление           21   "Cash of Rounding" }
{ cmp/cr-prep.i 1 discnt-t-bonuscard       22                Оплата бонусной картой 23   Payment of bonus card }
{ cmp/cr-prep.i 1 discnt-t-petrolcoupon    23                "Оплата топливным купоном (Ашан)" 17   "Payment of petrol coupon" }
{ cmp/cr-prep.i 1 discnt-t-alt-condition  998                Доп.условие         998   Alt-condition }
{ cmp/cr-prep.i 1 discnt-t-another        999                Другое              999   Another }
{ cmp/cr-prep.i 1 discnt-t-fault         1001                Погрешность         1001  Fault }

&glob discnt-type-list '{&bef-discnt-t-unknown}~
,{&bef-discnt-t-d-card}~
,{&bef-discnt-t-std}~
,{&bef-discnt-t-time}~
,{&bef-discnt-t-qnty}~
,{&bef-discnt-t-sum}~
,{&bef-discnt-t-staff}~
,{&bef-discnt-t-promo}~
,{&bef-discnt-t-mark-down}~
,{&bef-discnt-t-hour}~
,{&bef-discnt-t-set}~
,{&bef-discnt-t-season}~
,{&bef-discnt-t-categ}~
,{&bef-discnt-t-manual}~
,{&bef-discnt-t-d-mask}~
,{&bef-discnt-t-round}~
,{&bef-discnt-t-template}~
,{&bef-discnt-t-petrolcoupon}~
,{&bef-discnt-t-abs}~
,{&bef-discnt-t-group}~
,{&bef-discnt-t-payment}~
,{&bef-discnt-t-cashloyal}~
,{&bef-discnt-t-cashround}~
,{&bef-discnt-t-bonuscard}~
,{&bef-discnt-t-alt-condition}~
,{&bef-discnt-t-another}~
,{&bef-discnt-t-fault}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define discnt-type-list {&discnt-type-list}" ).

&glob discnt-type-list-full '{&bef-discnt-t-unknown-full}~
,{&bef-discnt-t-d-card-full}~
,{&bef-discnt-t-std-full}~
,{&bef-discnt-t-time-full}~
,{&bef-discnt-t-qnty-full}~
,{&bef-discnt-t-sum-full}~
,{&bef-discnt-t-staff-full}~
,{&bef-discnt-t-promo-full}~
,{&bef-discnt-t-mark-down-full}~
,{&bef-discnt-t-hour-full}~
,{&bef-discnt-t-set-full}~
,{&bef-discnt-t-season-full}~
,{&bef-discnt-t-categ-full}~
,{&bef-discnt-t-manual-full}~
,{&bef-discnt-t-d-mask-full}~
,{&bef-discnt-t-round-full}~
,{&bef-discnt-t-template-full}~
,{&bef-discnt-t-petrolcoupon-full}~
,{&bef-discnt-t-abs-full}~
,{&bef-discnt-t-group-full}~
,{&bef-discnt-t-payment-full}~
,{&bef-discnt-t-cashloyal-full}~
,{&bef-discnt-t-cashround-full}~
,{&bef-discnt-t-bonuscard-full}~
,{&bef-discnt-t-alt-condition-full}~
,{&bef-discnt-t-another-full}~
,{&bef-discnt-t-fault-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define discnt-type-list-full {&discnt-type-list-full}" ).

&glob discnt-type-name entry (lookup (~~~~~~~{&discnt-type-code}, ~{&discnt-type-list~}), ~{&discnt-type-list-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define discnt-type-name {&discnt-type-name}" ).


/* Получение типа расписания через его числовой код */
{ cmp/cr-prep.i 1 dtr-t-unknown          0                ?                                    0   ?                  }
{ cmp/cr-prep.i 1 dtr-t-time-period      1                "Период времени"                     1   "Time Period"      }
{ cmp/cr-prep.i 1 dtr-t-date-period      2                "Период дат"                         2   "Date Period"      }
{ cmp/cr-prep.i 1 dtr-t-day-of-week      4                "День недели"                        4   "Day of Week"      }
{ cmp/cr-prep.i 1 dtr-t-date             8                "Дата"                               8   "Date"             }
{ cmp/cr-prep.i 1 dtr-t-day-of-month    16                "День месяца"                       16   "Day of Month"     }

&glob dtr-type-list '~
{&bef-dtr-t-unknown}~
,{&bef-dtr-t-time-period}~
,{&bef-dtr-t-date-period}~
,{&bef-dtr-t-day-of-week}~
,{&bef-dtr-t-date}~
,{&bef-dtr-t-day-of-month}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define dtr-type-list {&dtr-type-list}" ).

&glob dtr-type-list-full '~
{&bef-dtr-t-unknown-full}~
,{&bef-dtr-t-time-period-full}~
,{&bef-dtr-t-date-period-full}~
,{&bef-dtr-t-day-of-week-full}~
,{&bef-dtr-t-date-full}~
,{&bef-dtr-t-day-of-month-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define dtr-type-list-full {&dtr-type-list-full}" ).


&glob dtr-t-name entry (lookup (~~~~~~~{&dtr-t-code}, ~{&dtr-type-list~}), ~{&dtr-type-list-full~})

run filwrlib_append-new-line in this-procedure ( input "&global-define dtr-t-name {&dtr-t-name}" ).


/* Получение типа скидки по дис карте через его числовой код */

{ cmp/cr-prep.i 1 dc-d-pcnt-good             1                Товар                 1   Good      }
{ cmp/cr-prep.i 1 dc-d-pcnt-cash             2                Итог_чека             2   Cash      }
{ cmp/cr-prep.i 1 dc-d-pcnt-both             3                Товары_и_итог_чека    3   Good-Cash }

&glob dc-d-pcnt-name entry (lookup (~~~~~~~{&dc-d-pcnt-code}, ~
'{&bef-dc-d-pcnt-good},{&bef-dc-d-pcnt-cash},{&bef-dc-d-pcnt-both}':U), ~
'{&bef-dc-d-pcnt-good-full},{&bef-dc-d-pcnt-cash-full},{&bef-dc-d-pcnt-both-full}':U)
run filwrlib_append-new-line in this-procedure ( input "&global-define dc-d-pcnt-name {&dc-d-pcnt-name}" ).

/*получение типа носителя карты через его числовой код*/
{ cmp/cr-prep.i 1 dc-cm-magnetic            0                "Карта c магн.полосой"               0  "Magnetic Card"  }
{ cmp/cr-prep.i 1 dc-cm-tm-key              1                "ТМ ключ"                            1  "TM Key"  }
{ cmp/cr-prep.i 1 dc-cm-smart               2                "Смарт карта"                        2  "Smart Card"  }
{ cmp/cr-prep.i 1 dc-cm-radio               3                "Радио карта"                        3  "Radio Card"  }
{ cmp/cr-prep.i 1 dc-cm-barcode             4                "Карта со штрихкодом"                4  "Barcode Card"  }
{ cmp/cr-prep.i 1 dc-cm-ef                  5                "EASY FUEL"                          5  "EASY FUEL"  }
{ cmp/cr-prep.i 1 dc-cm-ef2                 6                "EasyFuel2"                          6  "easyfuel2"  }

&glob dc-cm-types '~
{&bef-dc-cm-magnetic}~
,{&bef-dc-cm-tm-key}~
,{&bef-dc-cm-smart}~
,{&bef-dc-cm-radio}~
,{&bef-dc-cm-barcode}~
,{&bef-dc-cm-ef}~
,{&bef-dc-cm-ef2}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define dc-cm-types {&dc-cm-types}" ).
&glob dc-cm-types-full '~
{&bef-dc-cm-magnetic-full}~
,{&bef-dc-cm-tm-key-full}~
,{&bef-dc-cm-smart-full}~
,{&bef-dc-cm-radio-full}~
,{&bef-dc-cm-barcode-full}~
,{&bef-dc-cm-ef-full}~
,{&bef-dc-cm-ef2-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define dc-cm-types-full {&dc-cm-types-full}" ).
&glob dc-cm-type-name entry (lookup (~~~~~~~{&dc-cm-type-code}, {&dc-cm-types}), {&dc-cm-types-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define dc-cm-type-name {&dc-cm-type-name}" ).

{ cmp/cr-prep.i 1 dc-cn-sent-name       "name"               "ФИО"                                "name"      "Name"     }
{ cmp/cr-prep.i 1 dc-cn-sent-card       "card"               "N карты"                            "card"      "Card No"  }

{ cmp/cr-prep.i 1 cd-type-IBM            IBM                 IBM            IBM             IBM          }
{ cmp/cr-prep.i 1 cd-type-IBM-XML        IBM-XML             IBM-XML        IBM-XML         IBM-XML      }
{ cmp/cr-prep.i 1 cd-type-IPC-Servispl   IPC-Servis+         IPC-Servis+    IPC-Servis+     IPC-Servis+  }
{ cmp/cr-prep.i 1 cd-type-OMRON-NEW      OMRON-NEW           OMRON-NEW      OMRON-NEW       OMRON-NEW    }
{ cmp/cr-prep.i 1 cd-type-OMRON          OMRON               OMRON          OMRON           OMRON        }
{ cmp/cr-prep.i 1 cd-type-NCR-GM         NCR-GM              NCR-GM         NCR-GM          NCR-GM       }
{ cmp/cr-prep.i 1 cd-type-MAGIA-XML      MAGIA-XML           MAGIA-XML      MAGIA-XML       MAGIA-XML    }
{ cmp/cr-prep.i 1 cd-type-NCR-AS-R       NCR-AS@R            NCR-AS@R       NCR-AS@R        NCR-AS@R     }
{ cmp/cr-prep.i 1 cd-type-IBS-TH         IBS-TH              IBS-TH         IBS-TH          IBS-TH       }
{ cmp/cr-prep.i 1 cd-type-IBS-TH-MOB     IBS-TH-MOB          IBS-TH-MOB     IBS-TH-MOB      IBS-TH-MOB   }
{ cmp/cr-prep.i 1 cd-type-r-keeper       r-keeper            R-KEEPER       r-keeper        R-KEEPER     }
{ cmp/cr-prep.i 1 cd-type-infokiosk      InfoKiosk           InfoKiosk      InfoKiosk       InfoKiosk    }
{ cmp/cr-prep.i 1 cd-type-NKT-IBM        Emulator-NKT-IBM    Emulator-NKT-IBM      Emulator-NKT-IBM       Emulator-NKT-IBM    }
{ cmp/cr-prep.i 1 cd-type-MARIA          MARIA               MARIA          MARIA           MARIA         }
{ cmp/cr-prep.i 1 cd-type-pricecheck-Servispl   pricecheck-Servis+   "Прайс-чекер Servis+"     pricecheck-Servis+       "Scantech Shuttle Servis+"    }
{ cmp/cr-prep.i 1 cd-type-no-cd          -                   Накладная      -               Waybill       }
{ cmp/cr-prep.i 1 cd-type-bo             bo                  Бэкофис        bo              BackOffice    }
{ cmp/cr-prep.i 1 cd-type-Autotank       Autotank            Autotank       Autotank        Autotank  }
{ cmp/cr-prep.i 1 cd-type-csm            смена               смена          смена           смена         }

&glob cd-type-codes '{&bef-cd-type-IBM}~
,{&bef-cd-type-IBM-XML}~
,{&bef-cd-type-IPC-Servispl}~
,{&bef-cd-type-OMRON-NEW}~
,{&bef-cd-type-OMRON}~
,{&bef-cd-type-NCR-GM}~
,{&bef-cd-type-MAGIA-XML}~
,{&bef-cd-type-NCR-AS-R}~
,{&bef-cd-type-IBS-TH}~
,{&bef-cd-type-IBS-TH-MOB}~
,{&bef-cd-type-r-keeper}~
,{&bef-cd-type-infokiosk}~
,{&bef-cd-type-pricecheck-Servispl}~
,{&bef-cd-type-NKT-IBM}~
,{&bef-cd-type-MARIA}~
,{&bef-cd-type-no-cd}~
,{&bef-cd-type-bo}~
,{&bef-cd-type-Autotank}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-type-codes {&cd-type-codes}" ).

&glob cd-type-codes-full '{&bef-cd-type-IBM-full}~
,{&bef-cd-type-IBM-XML-full}~
,{&bef-cd-type-IPC-Servispl-full}~
,{&bef-cd-type-OMRON-NEW-full}~
,{&bef-cd-type-OMRON-full}~
,{&bef-cd-type-NCR-GM-full}~
,{&bef-cd-type-MAGIA-XML-full}~
,{&bef-cd-type-NCR-AS-R-full}~
,{&bef-cd-type-IBS-TH-full}~
,{&bef-cd-type-IBS-TH-MOB-full}~
,{&bef-cd-type-r-keeper-full}~
,{&bef-cd-type-infokiosk-full}~
,{&bef-cd-type-pricecheck-Servispl-full}~
,{&bef-cd-type-NKT-IBM-full}~
,{&bef-cd-type-MARIA}~
,{&bef-cd-type-no-cd-full}~
,{&bef-cd-type-bo-full}~
,{&bef-cd-type-Autotank-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-type-codes-full {&cd-type-codes-full}" ).

&glob cd-type-name entry (lookup (~~~~~~~{&cd-type-code}, {&cd-type-codes}), {&cd-type-codes-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-type-name {&cd-type-name}" ).

/*ВНИМАНИЕ ЭТА ПОСЛЕДОВАТЕЛЬНОСТЬ ОПРЕДЕЛЕНИЙ ДОЛЖНА БЫТЬ ТАКОЙ ЖЕ КАК cd-type-codes-for-dflt!!!*/
{ cmp/cr-prep.i 1 cd-type-unknown-int        0                   Неизв            0               Unknown      }
{ cmp/cr-prep.i 1 cd-type-IBM-int            1                   IBM              1               IBM          }
{ cmp/cr-prep.i 1 cd-type-IBM-XML-int        2                   IBM-XML          2               IBM-XML      }
{ cmp/cr-prep.i 1 cd-type-IPC-Servispl-int   3                   IPC-Servis+      3               IPC-Servis+  }
{ cmp/cr-prep.i 1 cd-type-OMRON-NEW-int      4                   OMRON-NEW        4               OMRON-NEW    }
{ cmp/cr-prep.i 1 cd-type-OMRON-int          5                   OMRON            5               OMRON        }
{ cmp/cr-prep.i 1 cd-type-NCR-GM-int         6                   NCR-GM           6               NCR-GM       }
{ cmp/cr-prep.i 1 cd-type-MAGIA-XML-int      7                   MAGIA-XML        7               MAGIA-XML    }
{ cmp/cr-prep.i 1 cd-type-NCR-AS-R-int       8                   NCR-AS@R         8               NCR-AS@R     }
{ cmp/cr-prep.i 1 cd-type-r-keeper-int       9                   R-KEEPER         9               R-KEEPER     }
{ cmp/cr-prep.i 1 cd-type-NKT-IBM-int        11                  Emulator-NKT-IBM 11              Emulator-NKT-IBM    }
{ cmp/cr-prep.i 1 cd-type-MARIA-int          12                  MARIA            12              MARIA         }
{ cmp/cr-prep.i 1 cd-type-Autotank-int       13                  Autotank         13              Autotank  }
{ cmp/cr-prep.i 1 cd-type-IBS-TH-int         14                  IBS-TH           14              IBS-TH       }
{ cmp/cr-prep.i 1 cd-type-IBS-TH-MOB-int     15                  IBS-TH-MOB       15              IBS-TH-MOB   }

&glob cd-type-codes-int '{&bef-cd-type-IBM-XML-int}~
,{&bef-cd-type-Autotank-int}~
,{&bef-cd-type-IBM-int}~
,{&bef-cd-type-IPC-Servispl-int}~
,{&bef-cd-type-OMRON-NEW-int}~
,{&bef-cd-type-OMRON-int}~
,{&bef-cd-type-NCR-GM-int}~
,{&bef-cd-type-MAGIA-XML-int}~
,{&bef-cd-type-NCR-AS-R-int}~
,{&bef-cd-type-r-keeper-int}~
,{&bef-cd-type-NKT-IBM-int}~
,{&bef-cd-type-MARIA-int}~
,{&bef-cd-type-IBS-TH-int}~
,{&bef-cd-type-IBS-TH-MOB-int}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-type-codes-int {&cd-type-codes-int}" ).



&glob cd-type-codes-real '{&bef-cd-type-IBM-XML}~
,{&bef-cd-type-Autotank}~
,{&bef-cd-type-IBM}~
,{&bef-cd-type-IPC-Servispl}~
,{&bef-cd-type-OMRON-NEW}~
,{&bef-cd-type-OMRON}~
,{&bef-cd-type-NCR-GM}~
,{&bef-cd-type-MAGIA-XML}~
,{&bef-cd-type-NCR-AS-R}~
,{&bef-cd-type-IBS-TH}~
,{&bef-cd-type-IBS-TH-MOB}~
,{&bef-cd-type-r-keeper}~
,{&bef-cd-type-infokiosk}~
,{&bef-cd-type-pricecheck-Servispl}~
,{&bef-cd-type-NKT-IBM}~
,{&bef-cd-type-MARIA}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-type-codes-real {&cd-type-codes-real}" ).

&glob cd-type-codes-real-full '{&bef-cd-type-IBM-XML-full}~
,{&bef-cd-type-Autotank-full}~
,{&bef-cd-type-IBM-full}~
,{&bef-cd-type-IPC-Servispl-full}~
,{&bef-cd-type-OMRON-NEW-full}~
,{&bef-cd-type-OMRON-full}~
,{&bef-cd-type-NCR-GM-full}~
,{&bef-cd-type-MAGIA-XML-full}~
,{&bef-cd-type-NCR-AS-R-full}~
,{&bef-cd-type-IBS-TH-full}~
,{&bef-cd-type-IBS-TH-MOB-full}~
,{&bef-cd-type-r-keeper-full}~
,{&bef-cd-type-infokiosk-full}~
,{&bef-cd-type-pricecheck-Servispl-full}~
,{&bef-cd-type-NKT-IBM-full}~
,{&bef-cd-type-MARIA-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-type-codes-real-full {&cd-type-codes-real-full}" ).

/*ВНИМАНИЕ ЭТА ПОСЛЕДОВАТЕЛЬНОСТЬ ОПРЕДЕЛЕНИЙ ДОЛЖНА БЫТЬ ТАКОЙ ЖЕ КАК cd-type-codes-int!!!*/
&glob cd-type-codes-for-dflt '{&bef-cd-type-IBM-XML}~
,{&bef-cd-type-Autotank}~
,{&bef-cd-type-IBM}~
,{&bef-cd-type-IPC-Servispl}~
,{&bef-cd-type-OMRON-NEW}~
,{&bef-cd-type-OMRON}~
,{&bef-cd-type-NCR-GM}~
,{&bef-cd-type-MAGIA-XML}~
,{&bef-cd-type-NCR-AS-R}~
,{&bef-cd-type-r-keeper}~
,{&bef-cd-type-NKT-IBM}~
,{&bef-cd-type-MARIA}~
,{&bef-cd-type-IBS-TH}~
,{&bef-cd-type-IBS-TH-MOB}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-type-codes-for-dflt {&cd-type-codes-for-dflt}" ).


&glob pos-type-int-code integer(entry(lookup(~~~~~~~{&pos-type-char-code}, {&cd-type-codes-for-dflt}), {&cd-type-codes-int}))
run filwrlib_append-new-line in this-procedure ( input "&global-define pos-type-int-code {&pos-type-int-code}" ).


&glob cd-type-codes-for-dflt-full '{&bef-cd-type-IBM-XML-full}~
,{&bef-cd-type-Autotank-full}~
,{&bef-cd-type-IBM-full}~
,{&bef-cd-type-IPC-Servispl-full}~
,{&bef-cd-type-OMRON-NEW-full}~
,{&bef-cd-type-OMRON-full}~
,{&bef-cd-type-NCR-GM-full}~
,{&bef-cd-type-MAGIA-XML-full}~
,{&bef-cd-type-NCR-AS-R-full}~
,{&bef-cd-type-r-keeper-full}~
,{&bef-cd-type-NKT-IBM-full}~
,{&bef-cd-type-MARIA-full}~
,{&bef-cd-type-IBS-TH-full}~
,{&bef-cd-type-IBS-TH-MOB-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-type-codes-for-dflt-full {&cd-type-codes-for-dflt-full}" ).



&glob cd-type-codes-discnt '{&bef-cd-type-IBM-XML}~
,{&bef-cd-type-Autotank}~
,{&bef-cd-type-IBM}~
,{&bef-cd-type-IPC-Servispl}~
,{&bef-cd-type-OMRON-NEW}~
,{&bef-cd-type-OMRON}~
,{&bef-cd-type-NCR-GM}~
,{&bef-cd-type-MAGIA-XML}~
,{&bef-cd-type-NCR-AS-R}~
,{&bef-cd-type-IBS-TH}~
,{&bef-cd-type-IBS-TH-MOB}~
,{&bef-cd-type-r-keeper}~
,{&bef-cd-type-MARIA}~
,{&bef-cd-type-no-cd}~
,{&bef-cd-type-bo}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-type-codes-discnt {&cd-type-codes-discnt}" ).

&glob cd-type-codes-discnt-full '{&bef-cd-type-IBM-XML-full}~
,{&bef-cd-type-Autotank-full}~
,{&bef-cd-type-IBM-full}~
,{&bef-cd-type-IPC-Servispl-full}~
,{&bef-cd-type-OMRON-NEW-full}~
,{&bef-cd-type-OMRON-full}~
,{&bef-cd-type-NCR-GM-full}~
,{&bef-cd-type-MAGIA-XML-full}~
,{&bef-cd-type-NCR-AS-R-full}~
,{&bef-cd-type-IBS-TH-full}~
,{&bef-cd-type-IBS-TH-MOB-full}~
,{&bef-cd-type-r-keeper-full}~
,{&bef-cd-type-MARIA-full}~
,{&bef-cd-type-no-cd-full}~
,{&bef-cd-type-bo-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-type-codes-discnt-full {&cd-type-codes-discnt-full}" ).


&glob codes-discnt-not-pos '~
{&bef-cd-type-bo}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define codes-discnt-not-pos {&codes-discnt-not-pos}" ).

&glob codes-discnt-not-pos-full '~
{&bef-cd-type-bo-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define codes-discnt-not-pos-full {&codes-discnt-not-pos-full}" ).




{ cmp/cr-prep.i 1 cd-self           0                   "Автономная касса"             0           "Autonomous Cash-desk"  }
{ cmp/cr-prep.i 1 cd-slave          1                   "Подчиненная касса"            1           "Slave Cash-desk"       }
{ cmp/cr-prep.i 1 cd-manager        2                   "Кассовый менеджер"            2           "Cash-desk manager"     }

&glob cd-autonomy-codes '{&bef-cd-self-full},{&bef-cd-slave-full},{&bef-cd-manager-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-autonomy-codes {&cd-autonomy-codes}" ).

&glob cd-autonomy-name entry (lookup (~~~~~~~{&autonomy-code}, ~
'{&bef-cd-self},{&bef-cd-slave},{&bef-cd-manager}':U), ~
'{&bef-cd-self-full},{&bef-cd-slave-full},{&bef-cd-manager-full}':U)
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-autonomy-name {&cd-autonomy-name}" ).


{ cmp/cr-prep.i 1 fr-type-shtrih-fr-k-01       shtrih-fr-k-01   "Штрих-ФР-К 01"       shtrih-fr-k-01        "Shtrih-FR-K 01"    }

{ cmp/cr-prep.i 1 fr-type-prim08tk       prim08tk   "ПРИМ08ТК"       prim08tk        "PRIM08TK"    }


&glob fr-type-codes '{&bef-FR-type-shtrih-fr-k-01},{&bef-FR-type-prim08tk}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define fr-type-codes {&fr-type-codes}" ).


&glob fr-type-codes-full '{&bef-FR-type-shtrih-fr-k-01-full},{&bef-FR-type-prim08tk-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define fr-type-codes-full {&fr-type-codes-full}" ).


/*дата корнвой записи для сезонных коэффициентов - выбрана именно такой потому что год високосный и начинается с понед*/
&glob s-coeff-start-date 01/01/1996
run filwrlib_append-new-line in this-procedure ( input "&global-define s-coeff-start-date {&s-coeff-start-date}" ).


/* Типы счетов в финансовом блоке */

{ cmp/cr-prep.i 1 fin-acc-active-code             1 "Активный"               1  "Active"                     }
{ cmp/cr-prep.i 1 fin-acc-passive-code            2 "Пассивный"              2  "Passive"                    }
{ cmp/cr-prep.i 1 fin-acc-actpass-code            3 "Акт-пасс"               3  "Act-Pass"                   }

&glob fin-acc-codes '{&bef-fin-acc-active-code},{&bef-fin-acc-passive-code},{&bef-fin-acc-actpass-code}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-acc-codes {&fin-acc-codes}" ).
&glob fin-acc-codes-radio '{&bef-fin-acc-active-code-full},{&bef-fin-acc-active-code},{&bef-fin-acc-passive-code-full},{&bef-fin-acc-passive-code},{&bef-fin-acc-actpass-code-full},{&bef-fin-acc-actpass-code}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-acc-codes-radio {&fin-acc-codes-radio}" ).
&glob fin-acc-codes-full '{&bef-fin-acc-active-code-full},{&bef-fin-acc-passive-code-full},{&bef-fin-acc-actpass-code-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-acc-codes-full {&fin-acc-codes-full}" ).
&glob fin-acc-codes-box '{&bef-fin-acc-active-code-full}':U,'{&bef-fin-acc-passive-code-full}':U,'{&bef-fin-acc-actpass-code-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-acc-codes-box {&fin-acc-codes-box}" ).
&glob fin-acc-codes-name entry (lookup (~~~~~~~{&fin-acc-code}, {&fin-acc-codes}), {&fin-acc-codes-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-acc-codes-name {&fin-acc-codes-name}" ).

/* Типы договоров в финансовом блоке */
{ cmp/cr-prep.i 1 contr-buy-sale    "Купли-продажи"               " "  "buy-sale"   " "  }
{ cmp/cr-prep.i 1 contr-comiss      "Консигнации"                 " "  "comiss"     " "  }
{ cmp/cr-prep.i 1 contr-resp-store  "Ответственного хранения"     " "  "resp-store" " "  }
{ cmp/cr-prep.i 1 contr-agent       "Агентский договор"           " "  "agent"      " "  }
{ cmp/cr-prep.i 1 contr-free        "Давальческого сырья"         " "  "free"       " "  }
{ cmp/cr-prep.i 1 contr-tpsi        "Продажи через ТПСИ"          " "  "tpsi"       " "  }
{ cmp/cr-prep.i 1 contr-addch       "о Дополнительных расходах"   " "  "add-charges" " "  }
/*{ cmp/cr-prep.i 1 contr-transp      "Транспортный"                " "  "transp"     " "  }*/

&glob contr-purch-repayment    '{&bef-contr-buy-sale},{&bef-contr-agent},{&bef-contr-free},{&bef-contr-tpsi}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define contr-purch-repayment {&contr-purch-repayment}" ).
&glob contr-purch-consignation {&contr-comiss}
run filwrlib_append-new-line in this-procedure ( input "&global-define contr-purch-consignation {&contr-purch-consignation}" ).
&glob contr-purch-resp-store   {&contr-resp-store}
run filwrlib_append-new-line in this-procedure ( input "&global-define contr-purch-resp-store {&contr-purch-resp-store}" ).
&glob contract-type-list    '{&bef-contr-buy-sale},{&bef-contr-comiss},{&bef-contr-resp-store},{&bef-contr-agent},{&bef-contr-free},{&bef-contr-tpsi},{&bef-contr-addch}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define contract-type-list {&contract-type-list}" ).
&glob contract-type-list-short    '{&bef-contr-buy-sale},{&bef-contr-comiss},{&bef-contr-resp-store},{&bef-contr-agent},{&bef-contr-free},{&bef-contr-tpsi}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define contract-type-list-short {&contract-type-list-short}" ).

/* Типы оплат договоров в финансовом блоке */
{ cmp/cr-prep.i 1 contr-pay-nodef          "Не определено"                      " "  "nodef"               " "  }
{ cmp/cr-prep.i 1 contr-pay-order          "По заказу"                          " "  "fact-order"          " "  }
{ cmp/cr-prep.i 1 contr-pay-rcv            "По поставке заказа"                 " "  "fact-rcv"            " "  }
{ cmp/cr-prep.i 1 contr-pay-order-delay    "Отсрочка платежа по заказу"           " "  "fact-order-delay"    " "  }
{ cmp/cr-prep.i 1 contr-pay-rcv-delay      "Отсрочка платежа по поставке заказа"  " "  "fact-rcv-delay"      " "  }
{ cmp/cr-prep.i 1 contr-pay-fact-in        "По факту поставки"                  " "  "fact-in"         " "  }
{ cmp/cr-prep.i 1 contr-pay-fact-out       "По факту реализации"                " "  "fact-out"        " "  }
{ cmp/cr-prep.i 1 contr-pay-fact-in-delay  "Отсрочка платежа (по поставке)"     " "  "fact-in-delay"   " "  }
{ cmp/cr-prep.i 1 contr-pay-fact-out-delay "Отсрочка платежа (по реализации)"   " "  "fact-out-delay"  " "  }
{ cmp/cr-prep.i 1 contr-pay-fact-out-prc   "По реализации части приход. накладной"   " "  "fact-out-prc"    " "  }
/*{ cmp/cr-prep.i 1 contr-pay-fact-in-out        "По факту пост. с возвратом"                " "  "fact-in-out"         " "  }*/
/*{ cmp/cr-prep.i 1 contr-pay-fact-in-out-delay  "Отсрочка платежа (по пост с возвратом)"    " "  "fact-in-out-delay"   " "  }*/
{ cmp/cr-prep.i 1 contr-pay-spec           "По спецификации"                     " "  "fact-spec"          " "  }
{ cmp/cr-prep.i 1 contr-pay-spec-delay     "Отсрочка платежа по спецификации"    " "  "fact-spec-delay"    " "  }
/* по покупателям  */
{ cmp/cr-prep.i 1 contr-buyer-ord       "Предоплата"                    " "  "prepay"          " "  }
{ cmp/cr-prep.i 1 contr-buyer-ord-prc   "Предоплата(%)"                 " "  "prepay_%"        " "  }
{ cmp/cr-prep.i 1 contr-buyer-in        "По факту поставки покупателю"  " "  "delivery"        " "  }
{ cmp/cr-prep.i 1 contr-buyer-in-delay  "Отсрочка платежа по поставке"  " "  "delivery_delay"  " "  }


/*&glob contr-usl-opl-list      '{&bef-contr-pay-nodef},{&bef-contr-pay-order},{&bef-contr-pay-rcv},{&bef-contr-pay-order-delay},{&bef-contr-pay-rcv-delay},{&bef-contr-pay-fact-in},{&bef-contr-pay-fact-out},{&bef-contr-pay-fact-in-delay},{&bef-contr-pay-fact-out-delay},{&bef-contr-pay-fact-out-prc},{&bef-contr-pay-fact-in-out},{&bef-contr-pay-fact-in-out-delay},{&bef-contr-pay-spec},{&bef-contr-pay-spec-delay},{&bef-contr-buyer-ord},{&bef-contr-buyer-ord-prc},{&bef-contr-buyer-in},{&bef-contr-buyer-in-delay}':U*/
&glob contr-usl-opl-list      '{&bef-contr-pay-nodef},{&bef-contr-pay-order},{&bef-contr-pay-rcv},{&bef-contr-pay-order-delay},{&bef-contr-pay-rcv-delay},{&bef-contr-pay-fact-in},{&bef-contr-pay-fact-out},{&bef-contr-pay-fact-in-delay},{&bef-contr-pay-fact-out-delay},{&bef-contr-pay-fact-out-prc},{&bef-contr-pay-spec},{&bef-contr-pay-spec-delay},{&bef-contr-buyer-ord},{&bef-contr-buyer-ord-prc},{&bef-contr-buyer-in},{&bef-contr-buyer-in-delay}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define contr-usl-opl-list {&contr-usl-opl-list}" ).

/*&glob contr-pay-avto-codes      '{&bef-contr-pay-fact-in},{&bef-contr-pay-fact-out},{&bef-contr-pay-fact-in-delay},{&bef-contr-pay-fact-out-delay},{&bef-contr-pay-fact-out-prc},{&bef-contr-pay-fact-in-out},{&bef-contr-pay-fact-in-out-delay}'*/
&glob contr-pay-avto-codes      '{&bef-contr-pay-fact-in},{&bef-contr-pay-fact-out},{&bef-contr-pay-fact-in-delay},{&bef-contr-pay-fact-out-delay},{&bef-contr-pay-fact-out-prc}'
run filwrlib_append-new-line in this-procedure ( input "&global-define contr-pay-avto-codes {&contr-pay-avto-codes}" ).

&glob contr-pay-avto-list      '{&bef-contr-pay-fact-in}':U,'{&bef-contr-pay-fact-out}':U,'{&bef-contr-pay-fact-in-delay}':U,'{&bef-contr-pay-fact-out-delay}':U,'{&bef-contr-pay-fact-out-prc}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define contr-pay-avto-list {&contr-pay-avto-list}" ).

/* установка параметров в складских документах для генерации финансовых обязательств */
&glob o-postavka '{&bef-contr-pay-fact-in},{&bef-contr-pay-fact-in-delay}'
run filwrlib_append-new-line in this-procedure ( input "&global-define o-postavka {&o-postavka}" ) .

&glob o-realiz   '{&bef-contr-pay-fact-out},{&bef-contr-pay-fact-out-prc},{&bef-contr-pay-fact-out-delay}'
run filwrlib_append-new-line in this-procedure ( input "&global-define o-realiz {&o-realiz}" ) .

&glob o-buyer-trn   '{&bef-contr-buyer-in},{&bef-contr-buyer-in-delay}'
run filwrlib_append-new-line in this-procedure ( input "&global-define o-buyer-trn {&o-buyer-trn}" ) .

&glob o-buyer-ord   '{&bef-contr-buyer-ord},{&bef-contr-buyer-ord-prc}'
run filwrlib_append-new-line in this-procedure ( input "&global-define o-buyer-ord {&o-buyer-ord}" ) .


{ cmp/cr-prep.i 1 income-cash        пко  "приходный кассовый ордер"      ic         "income cash"      }
{ cmp/cr-prep.i 1 expense-cash       рко  "расходный кассовый ордер"      ec         "expense cash"     }
{ cmp/cr-prep.i 1 income-cashless    ппп  "приходное платежное поручение" ii         "income invoice"   }
{ cmp/cr-prep.i 1 expense-cashless   рпп  "расходное платежное поручение" ei         "expense invoice"  }
{ cmp/cr-prep.i 1 income-payoff      апп  "приходный АПЗ"                 io         "income payoff"  }
{ cmp/cr-prep.i 1 expense-payoff     апр  "расходный АПЗ"                 eo         "expense payoff" }



&glob fin-doc-types '{&bef-income-cash},{&bef-expense-cash},{&bef-income-cashless},{&bef-expense-cashless},{&bef-income-payoff},{&bef-expense-payoff}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-doc-types {&fin-doc-types}" ).
&glob fin-doc-types-full '{&bef-income-cash-full},{&bef-expense-cash-full},{&bef-income-cashless-full},{&bef-expense-cashless-full},{&bef-income-payoff-full},{&bef-expense-payoff-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-doc-types-full {&fin-doc-types-full}" ).
&glob fin-doc-type-name entry (lookup (~~~~~~~{&fin-doc-type-code}, {&fin-doc-types}) + 1, ',':U + {&fin-doc-types-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-doc-type-name {&fin-doc-type-name}" ).


{ cmp/cr-prep.i 1 FDEDT_Income_Cash        пко  "приходный кассовый ордер"      ic         "income cash"      }
{ cmp/cr-prep.i 1 FDEDT_Expense_Cash       рко  "расходный кассовый ордер"      ec         "expense cash"     }
{ cmp/cr-prep.i 1 FDEDT_Income_Cashless    ппп  "приходное платежное поручение" ii         "income invoice"   }
{ cmp/cr-prep.i 1 FDEDT_Expense_Cashless   рпп  "расходное платежное поручение" ei         "expense invoice"  }
{ cmp/cr-prep.i 1 FDEDT_Income_Payoff      апп  "приходный АПЗ"                 io         "income payoff"  }
{ cmp/cr-prep.i 1 FDEDT_Expense_Payoff     апр  "расходный АПЗ"                 eo         "expense payoff" }


&glob fin-ext-doc-types '{&bef-FDEDT_Income_Cash},{&bef-FDEDT_Expense_Cash},{&bef-FDEDT_Income_Cashless},{&bef-FDEDT_Expense_Cashless},{&bef-FDEDT_Income_Payoff},{&bef-FDEDT_Expense_Payoff},':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-ext-doc-types {&fin-ext-doc-types}" ).
&glob fin-ext-doc-types-full '{&bef-FDEDT_Income_Cash-full},{&bef-FDEDT_Expense_Cash-full},{&bef-FDEDT_Income_Cashless-full},{&bef-FDEDT_Expense_Cashless-full},{&bef-FDEDT_Income_Payoff},{&bef-FDEDT_Expense_Payoff}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-ext-doc-types-full {&fin-ext-doc-types-full}" ).
&glob fin-ext-doc-type-name entry (lookup (~~~~~~~{&fin-ext-doc-type-code}, {&fin-ext-doc-types}), {&fin-ext-doc-types-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-ext-doc-type-name {&fin-ext-doc-type-name}" ).

&glob fin-ext-doc-income-types '{&bef-FDEDT_Income_Cash},{&bef-FDEDT_Income_Cashless},{&bef-FDEDT_Income_Payoff}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-ext-doc-income-types {&fin-ext-doc-income-types}" ).

&glob fin-ext-doc-expense-types '{&bef-FDEDT_Expense_Cash},{&bef-FDEDT_Expense_Cashless},{&bef-FDEDT_Expense_Payoff},':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-ext-doc-expense-types {&fin-ext-doc-expense-types}" ).

&glob fin-ext-doc-cash-types '{&bef-FDEDT_Income_Cash},{&bef-FDEDT_Expense_Cash}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-ext-doc-cash-types {&fin-ext-doc-cash-types}" ).

&glob fin-ext-doc-cashless-types '{&bef-FDEDT_Income_Cashless},{&bef-FDEDT_Expense_Cashless}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-ext-doc-cashless-types {&fin-ext-doc-cashless-types}" ).

&glob fin-ext-doc-payoff-types '{&bef-FDEDT_Income_Payoff},{&bef-FDEDT_Expense_Payoff}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-ext-doc-payoff-types {&fin-ext-doc-payoff-types}" ).

/*фалг сменности*/
{ cmp/cr-prep.i 1 fin-flag-shift    1  Сменный                 1         ByShift }
/*касс книга на объекте*/
{ cmp/cr-prep.i 1 cash-book-firm    0  "Главная БД фирмы"                   0  "Firm DB Cashbook" }
{ cmp/cr-prep.i 1 cash-book-object  1  "Операционная касса в БД объекта"    1  "Operational Cashbook on Object DB" }

&glob cash-book-types '~
{&bef-cash-book-firm}~
,{&bef-cash-book-object}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cash-book-types {&cash-book-types}" ).
&glob cash-book-types-full '~
{&bef-cash-book-firm-full}~
,{&bef-cash-book-object-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cash-book-types-full {&cash-book-types-full}" ).
&glob cash-book-type-name entry (lookup (~~~~~~~{&cash-book-type-code}, {&cash-book-types}), {&cash-book-types-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define cash-book-type-name {&cash-book-type-name}" ).

&glob fin-doc-cash-book-name  (if ~~~~~~~{&fin-doc-obj-code} > 0 then substitute('&1&2', ~~~~~~~{&fin-doc-obj-type}, string(~~~~~~~{&fin-doc-obj-code}, '99999')) else '')
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-doc-cash-book-name {&fin-doc-cash-book-name}" ).



/*типы выписок*/

{ cmp/cr-prep.i 1 standard-sttm        "стд"   "стандартная выписка"                              "std"         "standard statement"      }



&glob fins-doc-types '{&bef-standard-sttm}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fins-doc-types {&fins-doc-types}" ).
&glob fins-doc-types-full '{&bef-standard-sttm-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fins-doc-types-full {&fins-doc-types-full}" ).
&glob fins-doc-type-name entry (lookup (~~~~~~~{&fins-doc-type-code}, {&fins-doc-types}), {&fins-doc-types-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define fins-doc-type-name {&fins-doc-type-name}" ).


{ cmp/cr-prep.i 1 FSEDT_standard-sttm        "стд"   "стандартная выписка"                         "std"         "standard statement"      }


&glob fins-ext-doc-types '{&bef-FSEDT_standard-sttm}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fins-ext-doc-types {&fins-ext-doc-types}" ).
&glob fins-ext-doc-types-full '{&bef-FSEDT_standard-sttm-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fins-ext-doc-types-full {&fins-ext-doc-types-full}" ).
&glob fins-ext-doc-type-name entry (lookup (~~~~~~~{&fins-ext-doc-type-code}, {&fins-ext-doc-types}), {&fins-ext-doc-types-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define fins-ext-doc-type-name {&fins-ext-doc-type-name}" ).


/*Статусы финансовых документов и банковских выписок*/
{ cmp/cr-prep.i 1 fin-new           новый               " " new}
{ cmp/cr-prep.i 1 fin-permitted     разрешен            " " permitted}
{ cmp/cr-prep.i 1 fin-bank          банк                " " bank}
{ cmp/cr-prep.i 1 fin-fact          факт                " " fact}
{ cmp/cr-prep.i 1 fin-rejected      отказ               " " rejected}
&glob fin-status-all '{&bef-fin-new}~
,{&bef-fin-permitted}~
,{&bef-fin-bank}~
,{&bef-fin-fact}~
,{&bef-fin-rejected}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-status-all {&fin-status-all}" ).

/*факт,разрешен*/
{ cmp/cr-prep.i 2 fin-fact      fin-permitted }
{ cmp/cr-prep.i 2 fin-fact      fin-permitted  fin-new }
{ cmp/cr-prep.i 2 fin-fact      fin-bank fin-permitted  fin-new }


/* Виды платежа в плат поручении */

{ cmp/cr-prep.i 1 fin-vp-post        почтой             " " post }
{ cmp/cr-prep.i 1 fin-vp-telegraph   телеграфом         " " telegraph }
{ cmp/cr-prep.i 1 fin-vp-electronic  электронно         " " electronic }
/*запятую в конце следующей строчки после {&bef-fin-vp-electronic} не стирать!!!!*/
&glob fin-vp-codes '{&bef-fin-vp-post},{&bef-fin-vp-telegraph},{&bef-fin-vp-electronic},':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-vp-codes {&fin-vp-codes}" ).

/* Статусы плательщика в плат поручении */

{ cmp/cr-prep.i 1 fin-statpl-1       "01" "налогоплательщик"                           "01"  "tax payer"                         }
{ cmp/cr-prep.i 1 fin-statpl-2       "02" "налоговый агент"                            "02"  "tax agent"                         }
{ cmp/cr-prep.i 1 fin-statpl-3       "03" "сборщик налогов и сборов"                   "03"  "tax collector"                     }
{ cmp/cr-prep.i 1 fin-statpl-4       "04" "налоговый орган"                            "04"  "tax body"                          }
{ cmp/cr-prep.i 1 fin-statpl-5       "05" "служба судебных приставов МинЮста Рф"       "05"  "bailiff service"                   }
{ cmp/cr-prep.i 1 fin-statpl-6       "06" "участник внешнеэкономической деятельности"  "06"  "external-economic activity member" }
{ cmp/cr-prep.i 1 fin-statpl-7       "07" "таможенный орган"                           "07"  "customs body"                      }
{ cmp/cr-prep.i 1 fin-statpl-8       "08" "плательщик иных обязательных платежей"      "08"  "other compulsory payment payer"    }

&glob fin-statpl-codes '{&bef-fin-statpl-1},{&bef-fin-statpl-2},{&bef-fin-statpl-3},{&bef-fin-statpl-4},{&bef-fin-statpl-5},{&bef-fin-statpl-6},{&bef-fin-statpl-7},{&bef-fin-statpl-8}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-statpl-codes {&fin-statpl-codes}" ).
&glob fin-statpl-codes-full '{&bef-fin-statpl-1-full},{&bef-fin-statpl-2-full},{&bef-fin-statpl-3-full},{&bef-fin-statpl-4-full},{&bef-fin-statpl-5-full},{&bef-fin-statpl-6-full},{&bef-fin-statpl-7-full},{&bef-fin-statpl-8-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-statpl-codes-full {&fin-statpl-codes-full}" ).
&glob fin-statpl-codes-name entry (lookup (~~~~~~~{&fin-statpl-code}, {&fin-statpl-codes}), {&fin-statpl-codes-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-statpl-codes-name {&fin-statpl-codes-name}" ).

/*показатель основания платежа в плат поручении  поле f106  */

&glob fin-osnpl-codes    'ТП,ЗД,ТР,РС,ОТ,РТ,ВУ,ПР,АП,АР,0':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-osnpl-codes {&fin-osnpl-codes}" ).

/*показатель типа платежа в плат поручении  поле f110  */

&glob fin-tippl-codes    'НС,АВ,ПЕ,ПЦ,СА,АШ,ИШ,0':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-tippl-codes {&fin-tippl-codes}" ).

/* производство: типы документов */

{ cmp/cr-prep.i 1 plnmenu       план-меню           " " plm }
{ cmp/cr-prep.i 1 billord       счет-заказ          " " brd }
&glob fbr-type '{&bef-plnmenu},{&bef-billord}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fbr-type {&fbr-type}" ).

/*описание action для новой истории*/

{ cmp/cr-prep.i 1 hn-create         1                Создание   1  Create }
{ cmp/cr-prep.i 1 hn-update         2                Изменение  2  Update }
{ cmp/cr-prep.i 1 hn-correction     3                Коррекция  3  Correction }
{ cmp/cr-prep.i 1 hn-restore        4                Восстановление   4  Restore }
{ cmp/cr-prep.i 1 hn-rename         9                Смена_кода 9  Code_rename }
{ cmp/cr-prep.i 1 hn-art-rename     51               Смена_артик 51 Artic_rename }
{ cmp/cr-prep.i 1 hn-switch-off     79               Выключ.    79 Switch_off }
{ cmp/cr-prep.i 1 hn-multi          88               Мульти   88  Multi }
{ cmp/cr-prep.i 1 hn-delete         99               Удаление   99 Delete }



&glob hn-actions '{&bef-hn-delete}~
,{&bef-hn-create}~
,{&bef-hn-update}~
,{&bef-hn-correction}~
,{&bef-hn-restore}~
,{&bef-hn-rename}~
,{&bef-hn-art-rename}~
,{&bef-hn-switch-off}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-actions {&hn-actions}" ).

&glob hn-actions-full '{&bef-hn-delete-full}~
,{&bef-hn-create-full}~
,{&bef-hn-update-full}~
,{&bef-hn-correction-full}~
,{&bef-hn-restore-full}~
,{&bef-hn-rename-full}~
,{&bef-hn-art-rename-full}~
,{&bef-hn-switch-off-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-actions-full {&hn-actions-full}" ).


&glob hn-action-name entry (lookup (~~~~~~~{&hn-action-code}, ~{&hn-actions~}), ~{&hn-actions-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-action-name {&hn-action-name}" ).

/*описание news-user для новой истории*/
{ cmp/cr-prep.i 1 NTS        СПН           " "    NTS}
&glob nts-user  (~~~~~~~{&delim-par} +  ~{&nts})
run filwrlib_append-new-line in this-procedure ( input "&global-define nts-user {&nts-user}" ).

/*описание esys-user для новой истории*/
{ cmp/cr-prep.i 1 ESYS        ВС           " "    ESYS}
&glob esys-user  (~~~~~~~{&delim-par} +  ~{&ESYS})
run filwrlib_append-new-line in this-procedure ( input "&global-define esys-user {&esys-user}" ).

/*
{ cmp/cr-prep.i 1 NTS-user        "chr(2) + 'СПН'"           " "    "chr(2) + 'NTS'"}
*/

/*описание source-type для новой истории*/

{ cmp/cr-prep.i 1 hn-source-db         db              БД           db           DB }
{ cmp/cr-prep.i 1 hn-source-esys       esys            ВС           esys         ES }
{ cmp/cr-prep.i 1 hn-source-trn-doc    trn-doc         Документ     trn-doc      Document }
{ cmp/cr-prep.i 1 hn-source-payment    payment         Платеж       payment      Payment }
{ cmp/cr-prep.i 1 hn-source-fin-doc    fin-doc         Фин.док.     fin-doc      FinDoc }
{ cmp/cr-prep.i 1 hn-source-import     import          Импорт       import       Import }
{ cmp/cr-prep.i 1 hn-source-recalc     recalc          Пересчет     recalc       Recalc }
{ cmp/cr-prep.i 1 hn-source-wth-doc    wth-doc         "Документ МЦ" wth-doc     "Wealth Document" }
{ cmp/cr-prep.i 1 hn-source-ren-gdsc   ren-gdsc        Коллизия     ren-gdsc     Collision }
{ cmp/cr-prep.i 1 hn-source-upgrade    upgrade         Апгрейд      upgrade      Upgrade }
{ cmp/cr-prep.i 1 hn-source-grp-chg    grp-chg         Изм.группы   grp-chg      "Group Change" }
{ cmp/cr-prep.i 1 hn-source-stop-l     stop-list       Стоплист     stop-list    StopList }
{ cmp/cr-prep.i 1 hn-source-dis-card   dis-card        ДК           dis-card     Discard }

&glob hn-sources '~
,{&bef-hn-source-db}~
,{&bef-hn-source-esys}~
,{&bef-hn-source-trn-doc}~
,{&bef-hn-source-payment}~
,{&bef-hn-source-fin-doc}~
,{&bef-hn-source-import}~
,{&bef-hn-source-recalc}~
,{&bef-hn-source-wth-doc}~
,{&bef-hn-source-ren-gdsc}~
,{&bef-hn-source-upgrade}~
,{&bef-hn-source-grp-chg}~
,{&bef-hn-source-stop-l}~
,{&bef-hn-source-dis-card}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-sources {&hn-sources}" ).

&glob hn-sources-full '~
,{&bef-hn-source-db-full}~
,{&bef-hn-source-esys-full}~
,{&bef-hn-source-trn-doc-full}~
,{&bef-hn-source-payment-full}~
,{&bef-hn-source-fin-doc-full}~
,{&bef-hn-source-import-full}~
,{&bef-hn-source-recalc-full}~
,{&bef-hn-source-wth-doc-full}~
,{&bef-hn-source-ren-gdsc-full}~
,{&bef-hn-source-upgrade-full}~
,{&bef-hn-source-grp-chg-full}~
,{&bef-hn-source-stop-l-full}~
,{&bef-hn-source-dis-card-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-sources-full {&hn-sources-full}" ).

&glob hn-source-name entry (lookup (~~~~~~~{&hn-source-code}, ~{&hn-sources~}), ~{&hn-sources-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-source-name {&hn-source-name}" ).



/*описание subject для новой истории*/
/*subject новой истории товара*/
&glob gds-hist-subject '{&bef-table_goods}~
,{&bef-table_goods-attr}~
,{&bef-table_gds-host-attr}~
,{&bef-table_gds-obj-attr}~
,{&bef-table_fbr-gds-obj}~
,{&bef-table_s-coeff}~
,{&bef-table_bar-code}~
,{&bef-table_bar-code-attr}~
,{&bef-table_bar-code-obj-attr}~
,{&bef-table_prod-bc}~
,{&bef-table_varianty-delivery-gds-obj}~
,{&bef-table_gds-season}~
,{&bef-table_tax-rate-gds}~
,{&bef-table_assortment-matrix-goods}~
,{&bef-table_gds-obj-prop}~
,{&bef-table_pl-gds}~
,{&bef-table_pl-gds-pump}~
,{&bef-table_sert-join}~
,{&bef-table_pl-gds-attr}~
,{&bef-table_dis-gds-rule}~
,{&bef-table_ext-artic}~
,{&bef-table_ext-classif}~
,{&bef-table_recipe}~
,{&bef-table_recipe-gds}~
,{&bef-table_gds-obj}~
,{&bef-table_gds-obj-prop-attr}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define gds-hist-subject {&gds-hist-subject}" ).

&glob gds-hist-subject-full '{&bef-table_goods-full}~
,{&bef-table_goods-attr-full}~
,{&bef-table_gds-host-attr-full}~
,{&bef-table_gds-obj-attr-full}~
,{&bef-table_fbr-gds-obj-full}~
,{&bef-table_s-coeff-full}~
,{&bef-table_bar-code-full}~
,{&bef-table_bar-code-attr-full}~
,{&bef-table_bar-code-obj-attr-full}~
,{&bef-table_prod-bc-full}~
,{&bef-table_varianty-delivery-gds-obj-full}~
,{&bef-table_gds-season-full}~
,{&bef-table_tax-rate-gds-full}~
,{&bef-table_assortment-matrix-goods-full}~
,{&bef-table_gds-obj-prop-full}~
,{&bef-table_pl-gds-full}~
,{&bef-table_pl-gds-pump-full}~
,{&bef-table_sert-join-full}~
,{&bef-table_pl-gds-attr-full}~
,{&bef-table_dis-gds-rule-full}~
,{&bef-table_ext-artic-full}~
,{&bef-table_ext-classif-full}~
,{&bef-table_recipe-full}~
,{&bef-table_recipe-gds-full}~
,{&bef-table_gds-obj-full}~
,{&bef-table_gds-obj-prop-attr-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define gds-hist-subject-full {&gds-hist-subject-full}" ).

&glob hn-gds-hist-name entry (lookup (~~~~~~~{&hn-gds-hist-code}, ~{&gds-hist-subject~}), ~{&gds-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-gds-hist-name {&hn-gds-hist-name}" ).

/*subject новой истории клиентов*/

&glob cli-hist-subject '{&bef-table_clients}~
,{&bef-table_clients-attr}~
,{&bef-table_thbj-attr}~
,{&bef-table_sysconf}~
,{&bef-table_firm}~
,{&bef-table_person}~
,{&bef-table_shop}~
,{&bef-table_store}~
,{&bef-table_staff}~
,{&bef-table_dis-thbj-rule}~
,{&bef-table_ext-classif}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cli-hist-subject {&cli-hist-subject}" ).

&glob cli-hist-subject-full '{&bef-table_clients-full}~
,{&bef-table_clients-attr-full}~
,{&bef-table_thbj-attr-full}~
,{&bef-table_sysconf-full}~
,{&bef-table_firm-full}~
,{&bef-table_person-full}~
,{&bef-table_shop-full}~
,{&bef-table_store-full}~
,{&bef-table_staff-full}~
,{&bef-table_dis-thbj-rule-full}~
,{&bef-table_ext-classif-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cli-hist-subject-full {&cli-hist-subject-full}" ).

&glob hn-cli-hist-name entry (lookup (~~~~~~~{&hn-cli-hist-code}, ~{&cli-hist-subject~}), ~{&cli-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-cli-hist-name {&hn-cli-hist-name}" ).

/*subject истории групп клиентов*/

&glob cli-grp-hist-subject  '{&bef-table_cli-grp}~
,{&bef-table_dis-grp-rule}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cli-grp-hist-subject {&cli-grp-hist-subject}" ).

&glob cli-grp-hist-subject-full '{&bef-table_cli-grp-full}~
,{&bef-table_dis-grp-rule-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cli-grp-hist-subject-full {&cli-grp-hist-subject-full}" ).

&glob hn-cli-grp-hist-name entry (lookup (~~~~~~~{&hn-cli-grp-hist-code}, ~{&cli-grp-hist-subject~}), ~{&cli-grp-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-cli-grp-hist-name {&hn-cli-grp-hist-name}" ).


/*subject новой истории дК*/

&glob dc-hist-subject '{&bef-table_dis-card}~
,{&bef-table_dis-card-property}~
,{&bef-table_dis-obj}~
,{&bef-table_dis-host}~
,{&bef-table_dis-dc-rule}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define dc-hist-subject {&dc-hist-subject}" ).

&glob dc-hist-subject-full '{&bef-table_dis-card-full}~
,{&bef-table_dis-card-property-full}~
,{&bef-table_dis-obj-full}~
,{&bef-table_dis-host-full}~
,{&bef-table_dis-dc-rule-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define dc-hist-subject-full {&dc-hist-subject-full}" ).

&glob hn-dc-hist-name entry (lookup (~~~~~~~{&hn-dc-hist-code}, ~{&dc-hist-subject~}), ~{&dc-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-dc-hist-name {&hn-dc-hist-name}" ).

&glob dc-type-hist-subject '{&bef-table_dis-card-type}~
,{&bef-table_dis-card-type-attr}~
,{&bef-table_dis-card-mask}~
,{&bef-table_rp-by-call}~
,{&bef-table_rule-by-call}~
,{&bef-table_rule-call-param}~
,{&bef-table_dis-dct-rule}~
,{&bef-table_hist-nws-option}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define dc-type-hist-subject {&dc-type-hist-subject}" ).

&glob dc-type-hist-subject-full '{&bef-table_dis-card-type-full}~
,{&bef-table_dis-card-type-attr-full}~
,{&bef-table_dis-card-mask-full}~
,{&bef-table_rp-by-call-full}~
,{&bef-table_rule-by-call-full}~
,{&bef-table_rule-call-param-full}~
,{&bef-table_dis-dct-rule-full}~
,{&bef-table_hist-nws-option-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define dc-type-hist-subject-full {&dc-type-hist-subject-full}" ).

&glob hn-dc-type-hist-name entry (lookup (~~~~~~~{&hn-dc-type-hist-code}, ~{&dc-type-hist-subject~}), ~{&dc-type-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-dc-type-hist-name {&hn-dc-type-hist-name}" ).

&glob thbj-attr-hist-subject '{&bef-table_thbj-attr}~
,{&bef-table_rp-by-call}~
,{&bef-table_rule-by-call}~
,{&bef-table_rule-call-param}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define thbj-attr-hist-subject {&thbj-attr-hist-subject}" ).

&glob thbj-attr-hist-subject-full '{&bef-table_thbj-attr-full}~
,{&bef-table_rp-by-call-full}~
,{&bef-table_rule-by-call-full}~
,{&bef-table_rule-call-param-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define thbj-attr-hist-subject-full {&thbj-attr-hist-subject-full}" ).

&glob hn-thbj-attr-hist-name entry (lookup (~~~~~~~{&hn-thbj-attr-hist-code}, ~{&thbj-attr-hist-subject~}), ~{&thbj-attr-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-thbj-attr-hist-name {&hn-thbj-attr-hist-name}" ).




&glob cash-desk-hist-subject '{&bef-table_cash-desk}~
,{&bef-table_cash-desk-attr}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cash-desk-hist-subject {&cash-desk-hist-subject}" ).

&glob cash-desk-hist-subject-full '{&bef-table_cash-desk-full}~
,{&bef-table_cash-desk-attr-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cash-desk-hist-subject-full {&cash-desk-hist-subject-full}" ).


&glob hn-cash-desk-hist-name entry (lookup (~~~~~~~{&hn-cash-desk-hist-code}, ~{&cash-desk-hist-subject~}), ~{&cash-desk-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-cash-desk-hist-name {&hn-cash-desk-hist-name}" ).

&glob cash-pay-hist-subject '{&bef-table_cash-pay}~
,{&bef-table_cash-pay-attr}~
,{&bef-table_dis-cp-rule}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cash-pay-hist-subject {&cash-pay-hist-subject}" ).

&glob cash-pay-hist-subject-full '{&bef-table_cash-pay-full}~
,{&bef-table_cash-pay-attr-full}~
,{&bef-table_dis-cp-rule-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cash-pay-hist-subject-full {&cash-pay-hist-subject-full}" ).


&glob hn-cash-pay-hist-name entry (lookup (~~~~~~~{&hn-cash-pay-hist-code}, ~{&cash-pay-hist-subject~}), ~{&cash-pay-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-cash-pay-hist-name {&hn-cash-pay-hist-name}" ).

&glob tax-hist-subject '{&bef-table_tax}~
,{&bef-table_tax-rate}~
,{&bef-table_tax-rate-value}~
,{&bef-table_tax-units}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define tax-hist-subject {&tax-hist-subject}" ).

&glob tax-hist-subject-full '{&bef-table_tax-full}~
,{&bef-table_tax-rate-full}~
,{&bef-table_tax-rate-value-full}~
,{&bef-table_tax-units-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define tax-hist-subject-full {&tax-hist-subject-full}" ).

&glob hn-tax-hist-name entry (lookup (~~~~~~~{&hn-tax-hist-code}, ~{&tax-hist-subject~}), ~{&tax-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-tax-hist-name {&hn-tax-hist-name}" ).

/*subject истории групп товаров*/

&glob gds-grp-hist-subject  '{&bef-table_gds-grp}~
,{&bef-table_gds-grp-attr}~
,{&bef-table_gds-grp-obj}~
,{&bef-table_tax-rate-gds-grp}~
,{&bef-table_dis-grp-rule}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define gds-grp-hist-subject {&gds-grp-hist-subject}" ).

&glob gds-grp-hist-subject-full '{&bef-table_gds-grp-full}~
,{&bef-table_gds-grp-attr-full}~
,{&bef-table_gds-grp-obj-full}~
,{&bef-table_tax-rate-gds-grp-full}~
,{&bef-table_dis-grp-rule-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define gds-grp-hist-subject-full {&gds-grp-hist-subject-full}" ).

&glob hn-gds-grp-hist-name entry (lookup (~~~~~~~{&hn-gds-grp-hist-code}, ~{&gds-grp-hist-subject~}), ~{&gds-grp-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-gds-grp-hist-name {&hn-gds-grp-hist-name}" ).

&glob sum-grp-hist-subject  '{&bef-table_sum-grp}~
,{&bef-table_dis-grp-rule}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define sum-grp-hist-subject {&sum-grp-hist-subject}" ).

&glob sum-grp-hist-subject-full '{&bef-table_gds-grp-full}~
,{&bef-table_dis-grp-rule-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define sum-grp-hist-subject-full {&sum-grp-hist-subject-full}" ).

&glob hn-sum-grp-hist-name entry (lookup (~~~~~~~{&hn-sum-grp-hist-code}, ~{&sum-grp-hist-subject~}), ~{&sum-grp-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-sum-grp-hist-name {&hn-sum-grp-hist-name}" ).

&glob sum-grp-obj-hist-subject  '{&bef-table_sum-grp-obj}~
,{&bef-table_dis-grp-rule}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define sum-grp-obj-hist-subject {&sum-grp-obj-hist-subject}" ).

&glob sum-grp-obj-hist-subject-full '{&bef-table_sum-grp-obj-full}~
,{&bef-table_dis-grp-rule-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define sum-grp-obj-hist-subject-full {&sum-grp-obj-hist-subject-full}" ).

&glob hn-sum-grp-obj-hist-name entry (lookup (~~~~~~~{&hn-sum-grp-obj-hist-code}, ~{&sum-grp-obj-hist-subject~}), ~{&sum-grp-obj-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-sum-grp-obj-hist-name {&hn-sum-grp-obj-hist-name}" ).


&glob c-gds-obj_close 'close':U
run filwrlib_append-new-line in this-procedure ( input "&global-define c-gds-obj_close {&c-gds-obj_close}" ).
&glob c-gds-obj_delete 'delete':U
run filwrlib_append-new-line in this-procedure ( input "&global-define c-gds-obj_delete {&c-gds-obj_delete}" ).


&glob c-wth-obj_close 'close':U
run filwrlib_append-new-line in this-procedure ( input "&global-define c-wth-obj_close {&c-wth-obj_close}" ).
&glob c-wth-obj_delete 'delete':U
run filwrlib_append-new-line in this-procedure ( input "&global-define c-wth-obj_delete {&c-wth-obj_delete}" ).

/*история МЦ*/

&glob wth-hist-subject '{&bef-table_wealth}~
,{&bef-table_wth-par}~
,{&bef-table_wth-gds}~
,{&bef-table_wth-ser}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define wth-hist-subject {&wth-hist-subject}" ).

&glob wth-hist-subject-full '{&bef-table_wealth-full}~
,{&bef-table_wth-par-full}~
,{&bef-table_wth-gds-full}~
,{&bef-table_wth-ser-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define wth-hist-subject-full {&wth-hist-subject-full}" ).

&glob hn-wth-hist-name entry (lookup (~~~~~~~{&hn-wth-hist-code}, ~{&wth-hist-subject~}), ~{&wth-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-wth-hist-name {&hn-wth-hist-name}" ).

&glob plc-hist-subject '{&bef-table_place}~
,{&bef-table_pl-gds}~
,{&bef-table_pl-gds-pump}~
,{&bef-table_pl-pump}~
,{&bef-table_pl-pump-nozzle}~
,{&bef-table_place-attr}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define plc-hist-subject {&plc-hist-subject}" ).

&glob plc-hist-subject-full '{&bef-table_place-full}~
,{&bef-table_pl-gds-full}~
,{&bef-table_pl-gds-pump-full}~
,{&bef-table_pl-pump-full}~
,{&bef-table_pl-pump-nozzle-full}~
,{&bef-table_place-attr-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define plc-hist-subject-full {&plc-hist-subject-full}" ).

&glob hn-plc-hist-name entry (lookup (~~~~~~~{&hn-plc-hist-code}, ~{&plc-hist-subject~}), ~{&plc-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-plc-hist-name {&hn-plc-hist-name}" ).

&glob pmp-hist-subject '{&bef-table_pl-gds-pump}~
,{&bef-table_pl-pump}~
,{&bef-table_pl-pump-nozzle}~
,{&bef-table_pump-nozzle}~
,{&bef-table_pump}~
,{&bef-table_pump-attr}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define pmp-hist-subject {&pmp-hist-subject}" ).

&glob pmp-hist-subject-full '{&bef-table_pl-gds-pump-full}~
,{&bef-table_pl-pump-full}~
,{&bef-table_pl-pump-nozzle-full}~
,{&bef-table_pump-nozzle-full}~
,{&bef-table_pump-full}~
,{&bef-table_pump-attr-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define pmp-hist-subject-full {&pmp-hist-subject-full}" ).

&glob hn-pmp-hist-name entry (lookup (~~~~~~~{&hn-pmp-hist-code}, ~{&pmp-hist-subject~}), ~{&pmp-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-pmp-hist-name {&hn-pmp-hist-name}" ).

&glob nzl-hist-subject '{&bef-table_nozzle}~
,{&bef-table_pl-pump-nozzle}~
,{&bef-table_pump-nozzle}~
,{&bef-table_nozzle-attr}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define nzl-hist-subject {&nzl-hist-subject}" ).

&glob nzl-hist-subject-full '{&bef-table_nozzle-full}~
,{&bef-table_pl-pump-nozzle-full}~
,{&bef-table_pump-nozzle-full}~
,{&bef-table_nozzle-attr-FULL}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define nzl-hist-subject-full {&nzl-hist-subject-full}" ).

&glob hn-nzl-hist-name entry (lookup (~~~~~~~{&hn-nzl-hist-code}, ~{&nzl-hist-subject~}), ~{&nzl-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-nzl-hist-name {&hn-nzl-hist-name}" ).


/*subject истории групп блюд*/

&glob fbr-gds-grp-hist-subject  '{&bef-table_fbr-gds-grp}~
,{&bef-table_fbr-gds-grp-attr}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fbr-gds-grp-hist-subject {&fbr-gds-grp-hist-subject}" ).

&glob fbr-gds-grp-hist-subject-full '{&bef-table_fbr-gds-grp-full}~
,{&bef-table_fbr-gds-grp-attr-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fbr-gds-grp-hist-subject-full {&fbr-gds-grp-hist-subject-full}" ).

&glob hn-fbr-gds-grp-hist-name entry (lookup (~~~~~~~{&hn-fbr-gds-grp-hist-code}, ~{&fbr-gds-grp-hist-subject~}), ~{&fbr-gds-grp-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-fbr-gds-grp-hist-name {&hn-fbr-gds-grp-hist-name}" ).

/*история смен на объекте*/

&glob sht-hist-subject '{&bef-table_shift-obj}~
,{&bef-table_shift-staff}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define sht-hist-subject {&sht-hist-subject}" ).

&glob sht-hist-subject-full '{&bef-table_shift-obj-full}~
,{&bef-table_shift-staff-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define sht-hist-subject-full {&sht-hist-subject-full}" ).

&glob hn-sht-hist-name entry (lookup (~~~~~~~{&hn-sht-hist-code}, ~{&sht-hist-subject~}), ~{&sht-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-sht-hist-name {&hn-sht-hist-name}" ).


/*история сертификатов*/

&glob sert-hist-subject '{&bef-table_sert}~
,{&bef-table_sert-join}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define sert-hist-subject {&sert-hist-subject}" ).

&glob sert-hist-subject-full '{&bef-table_sert-full}~
,{&bef-table_sert-join-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define sert-hist-subject-full {&sert-hist-subject-full}" ).

&glob hn-sert-hist-name entry (lookup (~~~~~~~{&hn-sert-hist-code}, ~{&sert-hist-subject~}), ~{&sert-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-sert-hist-name {&hn-sert-hist-name}" ).


/*история весов*/
&glob scl-hist-subject '{&bef-table_scales}~
,{&bef-table_scales-grp}~
,{&bef-table_scales-gds}~
,{&bef-table_scales-attr}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define scl-hist-subject {&scl-hist-subject}" ).

&glob scl-hist-subject-full '{&bef-table_scales-full}~
,{&bef-table_scales-grp-full}~
,{&bef-table_scales-gds-full}~
,{&bef-table_scales-attr-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define scl-hist-subject-full {&scl-hist-subject-full}" ).

&glob hn-scl-hist-name entry (lookup (~~~~~~~{&hn-scl-hist-code}, ~{&scl-hist-subject~}), ~{&scl-hist-subject-full~})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-scl-hist-name {&hn-scl-hist-name}" ).




{ cmp/cr-prep.i 1 delivery-storage               "доставка-хранение"                                   " " delivery-storage                }


/* Статусы договоров в финансовом блоке */
{ cmp/cr-prep.i 1 current-contr    "тек"       " "  "cur"   " "  }
{ cmp/cr-prep.i 1 close-contr      "зкр"       " "  "cls"   " "  }

/*Статусы финансовых обязательств */
{ cmp/cr-prep.i 1 fin-gen           авто       " " generate}

&glob fin-ob-status-all '{&bef-fin-new},{&bef-fin-gen},{&bef-fin-fact}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-ob-status-all {&fin-ob-status-all}" ).

/* SFEDT - schet-fact-doc extended doc-type  */
{ cmp/cr-prep.i 1 SFEDT_Fin_Ob          fo "ФО"                     fo "FL"    }
{ cmp/cr-prep.i 1 SFEDT_Fin_Doc         fd "ФД"                     fd "FD"    }
{ cmp/cr-prep.i 1 SFEDT_Trn_doc         td "НК"                     td "TD"    }
{ cmp/cr-prep.i 1 SFEDT_add_doc         ad "ДР"                     ad "AD"    }


run filwrlib_num-lines-get in this-procedure
  (output p-num-lines
  ) .