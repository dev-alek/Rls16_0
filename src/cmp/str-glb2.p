block-level on error undo, throw.
/*

$Revision: 79dbeab10a26, 2672, rls $
$Author: Ostroukhov $
$Date: Вт ноя 17 10:53:20 2020 +0300 $
$Workfile: str-glb2.p $
$Archive: cmp/str-glb2.p $

Программа генерации файла s t r - g l b l . i . Часть 2

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Инструкции по использованию см в файле s t r - g l b l . p

*/

define input  parameter p-file-name    as character no-undo .
define output parameter p-num-lines    as character no-undo .
define output parameter p-vss-revision as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 79dbeab10a26, 2672, rls $":U .
define variable vss-author      as character no-undo init "$Author: Ostroukhov $":U .
define variable vss-date        as character no-undo init "$Date: Вт ноя 17 10:53:20 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: str-glb2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/str-glb2.p $":U .
define variable vss-description as character no-undo init "Программа генерации файла str-glbl.i".
{ cmp/vssrevis.i }
{ cmp/filwrlib.i }

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

/* Налоги */
{ cmp/cr-prep.i 1 vat-tax-code               1                                           " " 1                          }
{ cmp/cr-prep.i 1 slt-tax-code               2                                           " " 2                          }
{ cmp/cr-prep.i 1 road-tax-code              3                                           " " 3                          }
{ cmp/cr-prep.i 1 excise-tax-code            4                                           " " 4                          }
{ cmp/cr-prep.i 1 vat-tax                    vat                                         " " vat                        }
{ cmp/cr-prep.i 1 slt-tax                    slt                                         " " slt                        }
{ cmp/cr-prep.i 1 road-tax                   rdt                                         " " rdt                        }
{ cmp/cr-prep.i 1 excise-tax                 exc                                         " " exc                        }

/*Принадлежность бар-кода*/
{ cmp/cr-prep.i 1 goods                      "ТОВАР"                                     " " GOODS                      }
{ cmp/cr-prep.i 1 part                       "ПАРТИЯ"                                    " " PART                       }
{ cmp/cr-prep.i 1 property                   "ПРИЗНАК"                                   " " PROPERTY                   }
{ cmp/cr-prep.i 1 stock-place                "СКЛАДСКОЕ МЕСТО"                           " " "STOCK PLACE"              }

/* Типы заказов */
{ cmp/cr-prep.i 1 o-f                        "ОФ"  "Объект-Фирма    "  OF   Object-Firm         }
{ cmp/cr-prep.i 1 f-p                        "ФП"  "Фирма-Поставщик "  FS   Firm-Supp           }
{ cmp/cr-prep.i 1 o-p                        "ОП"  "Объект-Поставщик"  OS   Object-Supp         }
{ cmp/cr-prep.i 1 o-o                        "ОО"  "Объект-Объект"     OO   Object-Object       }
{ cmp/cr-prep.i 1 o-r                        "ОР"  "Объект-РЦ"         OR   Object-Center       }
{ cmp/cr-prep.i 1 p-o                        "ПО"  "Покупатель-Объект" BO   Buyer-Object        }
&glob  order-type-all  '{&bef-o-f},{&bef-f-p},{&bef-o-p},{&bef-o-o},{&bef-o-r},{&bef-p-o}'
run filwrlib_append-new-line in this-procedure ( input "&global-define order-type-all {&order-type-all}" ).


{ cmp/cr-prep.i 1 menuload_adm_version        version            " " version            }
{ cmp/cr-prep.i 1 menuload_adm_function       function           " " function           }
{ cmp/cr-prep.i 1 menuload_adm_check          check              " " check              }
{ cmp/cr-prep.i 1 menuload_adm_archive        archive            " " archive            }
{ cmp/cr-prep.i 1 menuload_adm_impexp         impexp             " " impexp             }
{ cmp/cr-prep.i 1 menuload_service_customs    service_customs    " " service_customs    }
{ cmp/cr-prep.i 1 menuload_service_utility    service_utility    " " service_utility    }
{ cmp/cr-prep.i 1 menuload_service_check      service_check      " " service_check      }
{ cmp/cr-prep.i 1 menuload_service_impexp     service_impexp     " " service_impexp     }
{ cmp/cr-prep.i 1 menuload_service_fin_impexp service_fin_impexp " " service_fin_impexp }

/* Получение типа товарного чека через его числовой код */
{ cmp/cr-prep.i 1 rcpt-sale             1                Продажа               1   Sale}
{ cmp/cr-prep.i 1 rcpt-return           6                Возврат               6   Return}
{ cmp/cr-prep.i 1 rcpt-annu             8                Аннуляция             8   Annul.}
{ cmp/cr-prep.i 1 rcpt-inventory        11               Инвентаризация        11  Invent.}
{ cmp/cr-prep.i 1 rcpt-z-rep            12               Z-отчет               12  Z-report}
{ cmp/cr-prep.i 1 rcpt-shft-close       13               Закрытие_смены        13  ShiftClose }
{ cmp/cr-prep.i 1 rcpt-shft-Open        40               Открытие_смены        40  ShiftOpen }
{ cmp/cr-prep.i 1 rcpt-write-off        69               Списание              69  WriteOff}
{ cmp/cr-prep.i 1 rcpt-return-write-off 96               ВзврСпис              96  RtrnWrtoff}
{ cmp/cr-prep.i 1 rcpt-trans-cancell    14               СбросТрнзкц           14  TrnsctCncll}
{ cmp/cr-prep.i 1 rcpt-overflow         15               Перелив               15  Overflow}
{ cmp/cr-prep.i 1 rcpt-trans-transfer   16               ПеревТрнзкц           16  TrnsctTrnsfr}
{ cmp/cr-prep.i 1 rcpt-tech-refuell     17               ТехПролив             17  TechRefuell}
{ cmp/cr-prep.i 1 rcpt-unlock-trans     36               РазблТрнзкц           36  UnlockTrans}
{ cmp/cr-prep.i 1 rcpt-pre-sale             101          _Продажа              101  _Sale }
{ cmp/cr-prep.i 1 rcpt-pre-return           106          _Возврат              106  _Return }
{ cmp/cr-prep.i 1 rcpt-pre-annu             108          _Аннуляция            108  _Annul. }
{ cmp/cr-prep.i 1 rcpt-pre-inventory        111          _Инвентаризация       111  _Invent.}
{ cmp/cr-prep.i 1 rcpt-pre-z-rep            112          _Z-отчет              112  _Z-report}
{ cmp/cr-prep.i 1 rcpt-pre-shft-close       113          _Закрытие_смены       113  _ShiftClose }
{ cmp/cr-prep.i 1 rcpt-pre-write-off        169          _Списание             169  _WriteOff }
{ cmp/cr-prep.i 1 rcpt-pre-return-write-off 196          _ВзврСпис             196  _RtrnWrtoff }
{ cmp/cr-prep.i 1 rcpt-pre-trans-cancell    114          _СбросТрнзкц          114  _TrnsctCncll }
{ cmp/cr-prep.i 1 rcpt-pre-overflow         115          _Перелив              115  _Overflow }
{ cmp/cr-prep.i 1 rcpt-pre-trans-transfer   116          _ПеревТрнзкц          116  _TrnsctTrnsfr }
{ cmp/cr-prep.i 1 rcpt-pre-tech-refuell     117          _ТехПролив            117  _TechRefuell }
{ cmp/cr-prep.i 1 rcpt-pre-unlock-trans     136          _РазблТрнзкц          136  _UnlockTrans }
{ cmp/cr-prep.i 1 rcpt-ord-sale             201          >Продажа              201  >Sale }
{ cmp/cr-prep.i 1 rcpt-ord-return           206          >Возврат              206  >Return }
{ cmp/cr-prep.i 1 rcpt-ord-annu             208          >Аннуляция            208  >Annul. }
{ cmp/cr-prep.i 1 rcpt-ord-sale-closed      301          >>Продажа             301  >>Sale  }
{ cmp/cr-prep.i 1 rcpt-ord-return-closed    306          >>Возврат             306  >>Return }
{ cmp/cr-prep.i 1 encashment       2                Инкассация            2   Encashment}
{ cmp/cr-prep.i 1 cd-fund          3                Касс_фонд             3   CR_fund}
{ cmp/cr-prep.i 1 pay-transfer     4                Перевод_опл           4   Pay_transfer}
{ cmp/cr-prep.i 1 cd-expense       5                Расход_кассы          5   CR_expense}
{ cmp/cr-prep.i 1 cd-drawer        7                Декл_ден_ящ           7   Cash_drawer}
{ cmp/cr-prep.i 1 income-corr           43                Приход_Корр           43   Income_Corr}
{ cmp/cr-prep.i 1 expense-corr          44                Расход_Корр           44   Expense_Corr}



&glob receipt-codes-combo '{&bef-rcpt-sale-full},{&bef-rcpt-sale},~
{&bef-rcpt-return-full},{&bef-rcpt-return},~
{&bef-rcpt-return-write-off-full},{&bef-rcpt-return-write-off},~
{&bef-rcpt-trans-cancell-full},{&bef-rcpt-trans-cancell},~
{&bef-rcpt-overflow-full},{&bef-rcpt-overflow},~
{&bef-rcpt-trans-transfer-full},{&bef-rcpt-trans-transfer},~
{&bef-rcpt-unlock-trans-full},{&bef-rcpt-unlock-trans},~
{&bef-rcpt-tech-refuell-full},{&bef-rcpt-tech-refuell},~
{&bef-rcpt-write-off-full},{&bef-rcpt-write-off},~
{&bef-rcpt-annu-full},{&bef-rcpt-annu},~
{&bef-rcpt-inventory-full},{&bef-rcpt-inventory},~
{&bef-rcpt-shft-close-full},{&bef-rcpt-shft-close},~
{&bef-rcpt-shft-Open-full},{&bef-rcpt-shft-open},~
{&bef-rcpt-Z-rep-full},{&bef-rcpt-z-rep},~
{&bef-rcpt-pre-sale-full},{&bef-rcpt-pre-sale},~
{&bef-rcpt-pre-return-full},{&bef-rcpt-pre-return},~
{&bef-rcpt-pre-return-write-off-full},{&bef-rcpt-pre-return-write-off},~
{&bef-rcpt-pre-trans-cancell-full},{&bef-rcpt-pre-trans-cancell},~
{&bef-rcpt-pre-overflow-full},{&bef-rcpt-pre-overflow},~
{&bef-rcpt-pre-trans-transfer-full},{&bef-rcpt-pre-trans-transfer},~
{&bef-rcpt-pre-tech-refuell-full},{&bef-rcpt-pre-tech-refuell},~
{&bef-rcpt-pre-write-off-full},{&bef-rcpt-pre-write-off},~
{&bef-rcpt-pre-annu-full},{&bef-rcpt-pre-annu},~
{&bef-rcpt-pre-inventory-full},{&bef-rcpt-pre-inventory},~
{&bef-rcpt-pre-Z-rep-full},{&bef-rcpt-pre-z-rep},~
{&bef-rcpt-pre-trans-cancell-full},{&bef-rcpt-pre-trans-cancell},~
{&bef-rcpt-pre-unlock-trans-full},{&bef-rcpt-pre-unlock-trans},~
{&bef-rcpt-pre-shft-close-full},{&bef-rcpt-pre-shft-close},~
{&bef-rcpt-ord-sale-full},{&bef-rcpt-ord-sale},~
{&bef-rcpt-ord-return-full},{&bef-rcpt-ord-return},~
{&bef-rcpt-ord-annu-full},{&bef-rcpt-ord-annu},~
{&bef-rcpt-ord-sale-closed-full},{&bef-rcpt-ord-sale-closed},~
{&bef-rcpt-ord-return-closed-full},{&bef-rcpt-ord-return-closed},~
{&bef-encashment-full},{&bef-encashment},~
{&bef-cd-fund-full},{&bef-cd-fund},~
{&bef-pay-transfer-full},{&bef-pay-transfer},~
{&bef-cd-expense-full},{&bef-cd-expense},~
{&bef-cd-drawer-full},{&bef-cd-drawer},~
{&bef-income-corr-full},{&bef-income-corr},~
{&bef-expense-corr-full},{&bef-expense-corr}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define receipt-codes-combo {&receipt-codes-combo}" ).


&glob receipt-codes-combo-only-gds '{&bef-rcpt-sale-full},{&bef-rcpt-sale},~
{&bef-rcpt-return-full},{&bef-rcpt-return},~
{&bef-rcpt-return-write-off-full},{&bef-rcpt-return-write-off},~
{&bef-rcpt-trans-cancell-full},{&bef-rcpt-trans-cancell},~
{&bef-rcpt-overflow-full},{&bef-rcpt-overflow},~
{&bef-rcpt-trans-transfer-full},{&bef-rcpt-trans-transfer},~
{&bef-rcpt-unlock-trans-full},{&bef-rcpt-unlock-trans},~
{&bef-rcpt-tech-refuell-full},{&bef-rcpt-tech-refuell},~
{&bef-rcpt-write-off-full},{&bef-rcpt-write-off},~
{&bef-rcpt-annu-full},{&bef-rcpt-annu},~
{&bef-rcpt-inventory-full},{&bef-rcpt-inventory},~
{&bef-rcpt-Z-rep-full},{&bef-rcpt-z-rep},~
{&bef-rcpt-pre-sale-full},{&bef-rcpt-pre-sale},~
{&bef-rcpt-pre-return-full},{&bef-rcpt-pre-return},~
{&bef-rcpt-pre-return-write-off-full},{&bef-rcpt-pre-return-write-off},~
{&bef-rcpt-pre-trans-cancell-full},{&bef-rcpt-pre-trans-cancell},~
{&bef-rcpt-pre-overflow-full},{&bef-rcpt-pre-overflow},~
{&bef-rcpt-pre-trans-transfer-full},{&bef-rcpt-pre-trans-transfer},~
{&bef-rcpt-pre-tech-refuell-full},{&bef-rcpt-pre-tech-refuell},~
{&bef-rcpt-pre-write-off-full},{&bef-rcpt-pre-write-off},~
{&bef-rcpt-pre-annu-full},{&bef-rcpt-pre-annu},~
{&bef-rcpt-pre-inventory-full},{&bef-rcpt-pre-inventory},~
{&bef-rcpt-pre-Z-rep-full},{&bef-rcpt-pre-z-rep},~
{&bef-rcpt-pre-trans-cancell-full},{&bef-rcpt-pre-trans-cancell},~
{&bef-rcpt-pre-unlock-trans-full},{&bef-rcpt-pre-unlock-trans},~
{&bef-rcpt-ord-sale-full},{&bef-rcpt-ord-sale},~
{&bef-rcpt-ord-return-full},{&bef-rcpt-ord-return},~
{&bef-rcpt-ord-annu-full},{&bef-rcpt-ord-annu},~
{&bef-rcpt-ord-sale-closed-full},{&bef-rcpt-ord-sale-closed},~
{&bef-rcpt-ord-return-closed-full},{&bef-rcpt-ord-return-closed}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define receipt-codes-combo-only-gds {&receipt-codes-combo-only-gds}" ).


&glob receipt-codes '{&bef-rcpt-sale},~
{&bef-rcpt-return},~
{&bef-rcpt-annu},~
{&bef-rcpt-write-off},~
{&bef-rcpt-return-write-off},~
{&bef-rcpt-trans-cancell},~
{&bef-rcpt-overflow},~
{&bef-rcpt-trans-transfer},~
{&bef-rcpt-unlock-trans},~
{&bef-rcpt-tech-refuell},~
{&bef-rcpt-inventory},~
{&bef-rcpt-z-rep},~
{&bef-rcpt-shft-close},~
{&bef-rcpt-shft-open},~
{&bef-rcpt-pre-sale},~
{&bef-rcpt-pre-return},~
{&bef-rcpt-pre-annu},~
{&bef-rcpt-pre-write-off},~
{&bef-rcpt-pre-return-write-off},~
{&bef-rcpt-pre-trans-cancell},~
{&bef-rcpt-pre-overflow},~
{&bef-rcpt-pre-trans-transfer},~
{&bef-rcpt-pre-tech-refuell},~
{&bef-rcpt-pre-inventory},~
{&bef-rcpt-pre-z-rep},~
{&bef-rcpt-pre-unlock-trans},~
{&bef-rcpt-pre-shft-close},~
{&bef-rcpt-ord-sale},~
{&bef-rcpt-ord-return},~
{&bef-rcpt-ord-annu},~
{&bef-rcpt-ord-sale-closed},~
{&bef-rcpt-ord-return-closed},~
{&bef-income-corr},~
{&bef-expense-corr}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define receipt-codes {&receipt-codes}" ).

&glob receipt-codes-full '{&bef-rcpt-sale-full},~
{&bef-rcpt-return-full},~
{&bef-rcpt-annu-full},~
{&bef-rcpt-write-off-full},~
{&bef-rcpt-return-write-off-full},~
{&bef-rcpt-trans-cancell-full},~
{&bef-rcpt-overflow-full},~
{&bef-rcpt-trans-transfer-full},~
{&bef-rcpt-unlock-trans-full},~
{&bef-rcpt-tech-refuell-full},~
{&bef-rcpt-inventory-full},~
{&bef-rcpt-z-rep-full},~
{&bef-rcpt-shft-close-full},~
{&bef-rcpt-shft-open-full},~
{&bef-rcpt-pre-sale-full},~
{&bef-rcpt-pre-return-full},~
{&bef-rcpt-pre-annu-full},~
{&bef-rcpt-pre-write-off-full},~
{&bef-rcpt-pre-return-write-off-full},~
{&bef-rcpt-pre-trans-cancell-full},~
{&bef-rcpt-pre-overflow-full},~
{&bef-rcpt-pre-trans-transfer-full},~
{&bef-rcpt-pre-tech-refuell-full},~
{&bef-rcpt-pre-inventory-full},~
{&bef-rcpt-pre-z-rep-full},~
{&bef-rcpt-pre-unlock-trans-full},~
{&bef-rcpt-pre-shft-close-full},~
{&bef-rcpt-ord-sale-full},~
{&bef-rcpt-ord-return-full},~
{&bef-rcpt-ord-annu-full},~
{&bef-rcpt-ord-sale-closed-full},~
{&bef-rcpt-ord-return-closed-full},~
{&bef-income-corr-full},~
{&bef-expense-corr-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define receipt-codes-full {&receipt-codes-full}" ).


&glob receipt-codes-all '{&bef-rcpt-sale},~
{&bef-rcpt-return},~
{&bef-rcpt-annu},~
{&bef-rcpt-write-off},~
{&bef-rcpt-return-write-off},~
{&bef-rcpt-trans-cancell},~
{&bef-rcpt-overflow},~
{&bef-rcpt-trans-transfer},~
{&bef-rcpt-unlock-trans},~
{&bef-rcpt-tech-refuell},~
{&bef-rcpt-inventory},~
{&bef-rcpt-z-rep},~
{&bef-rcpt-shft-close},~
{&bef-rcpt-shft-open},~
{&bef-rcpt-pre-sale},~
{&bef-rcpt-pre-return},~
{&bef-rcpt-pre-annu},~
{&bef-rcpt-pre-write-off},~
{&bef-rcpt-pre-return-write-off},~
{&bef-rcpt-pre-trans-cancell},~
{&bef-rcpt-pre-overflow},~
{&bef-rcpt-pre-trans-transfer},~
{&bef-rcpt-pre-tech-refuell},~
{&bef-rcpt-pre-inventory},~
{&bef-rcpt-pre-z-rep},~
{&bef-rcpt-pre-unlock-trans},~
{&bef-rcpt-pre-shft-close},~
{&bef-rcpt-ord-sale},~
{&bef-rcpt-ord-return},~
{&bef-rcpt-ord-annu},~
{&bef-rcpt-ord-sale-closed},~
{&bef-rcpt-ord-return-closed},~
{&bef-encashment},~
{&bef-cd-fund},~
{&bef-pay-transfer},~
{&bef-cd-expense},~
{&bef-cd-drawer},~
{&bef-income-corr},~
{&bef-expense-corr}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define receipt-codes-all {&receipt-codes-all}" ).

&glob receipt-codes-all-full '{&bef-rcpt-sale-full},~
{&bef-rcpt-return-full},~
{&bef-rcpt-annu-full},~
{&bef-rcpt-write-off-full},~
{&bef-rcpt-return-write-off-full},~
{&bef-rcpt-trans-cancell-full},~
{&bef-rcpt-overflow-full},~
{&bef-rcpt-trans-transfer-full},~
{&bef-rcpt-unlock-trans-full},~
{&bef-rcpt-tech-refuell-full},~
{&bef-rcpt-inventory-full},~
{&bef-rcpt-z-rep-full},~
{&bef-rcpt-shft-close-full},~
{&bef-rcpt-shft-open-full},~
{&bef-rcpt-pre-sale-full},~
{&bef-rcpt-pre-return-full},~
{&bef-rcpt-pre-annu-full},~
{&bef-rcpt-pre-write-off-full},~
{&bef-rcpt-pre-return-write-off-full},~
{&bef-rcpt-pre-trans-cancell-full},~
{&bef-rcpt-pre-overflow-full},~
{&bef-rcpt-pre-trans-transfer-full},~
{&bef-rcpt-pre-tech-refuell-full},~
{&bef-rcpt-pre-inventory-full},~
{&bef-rcpt-pre-z-rep-full},~
{&bef-rcpt-pre-unlock-trans-full},~
{&bef-rcpt-pre-shft-close-full},~
{&bef-rcpt-ord-sale-full},~
{&bef-rcpt-ord-return-full},~
{&bef-rcpt-ord-annu-full},~
{&bef-rcpt-ord-sale-closed-full},~
{&bef-rcpt-ord-return-closed-full},~
{&bef-encashment-full},~
{&bef-cd-fund-full},~
{&bef-pay-transfer-full},~
{&bef-cd-expense-full},~
{&bef-cd-drawer-full},~
{&bef-income-corr-full},~
{&bef-expense-corr-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define receipt-codes-all-full {&receipt-codes-all-full}" ).


&glob receipt-name entry (lookup (~~~~~~~{&receipt-code}, {&receipt-codes-all}) + 1, ',' + {&receipt-codes-all-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define receipt-name {&receipt-name}" ).


&glob petrol-receipt-codes '{&bef-rcpt-trans-cancell},~
{&bef-rcpt-overflow},~
{&bef-rcpt-trans-transfer},~
{&bef-rcpt-tech-refuell},~
{&bef-rcpt-unlock-trans}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define petrol-receipt-codes {&petrol-receipt-codes}" ).

&glob no-docum-receipt-codes '{&bef-rcpt-trans-cancell},~
{&bef-rcpt-overflow},~
{&bef-rcpt-trans-transfer},~
{&bef-rcpt-unlock-trans},~
{&bef-rcpt-annu},~
{&bef-rcpt-pre-sale},~
{&bef-rcpt-pre-return},~
{&bef-rcpt-pre-annu},~
{&bef-rcpt-inventory},~
{&bef-rcpt-z-rep},~
{&bef-rcpt-shft-close},~
{&bef-rcpt-shft-open},~
{&bef-rcpt-pre-write-off},~
{&bef-rcpt-pre-return-write-off},~
{&bef-rcpt-pre-trans-cancell},~
{&bef-rcpt-pre-overflow},~
{&bef-rcpt-pre-trans-transfer},~
{&bef-rcpt-pre-tech-refuell},~
{&bef-rcpt-pre-inventory},~
{&bef-rcpt-pre-z-rep},~
{&bef-rcpt-pre-unlock-trans},~
{&bef-rcpt-pre-shft-close},~
{&bef-rcpt-ord-sale},~
{&bef-rcpt-ord-return},~
{&bef-rcpt-ord-annu},~
{&bef-rcpt-ord-sale-closed},~
{&bef-rcpt-ord-return-closed},~
{&bef-encashment},~
{&bef-cd-fund},~
{&bef-pay-transfer},~
{&bef-cd-expense},~
{&bef-cd-drawer},~
{&bef-income-corr},~
{&bef-expense-corr}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define no-docum-receipt-codes {&no-docum-receipt-codes}" ).


&glob no-sale-receipt-codes '{&bef-rcpt-trans-cancell},~
{&bef-rcpt-overflow},~
{&bef-rcpt-trans-transfer},~
{&bef-rcpt-unlock-trans},~
{&bef-rcpt-tech-refuell},~
{&bef-rcpt-annu},~
{&bef-rcpt-inventory},~
{&bef-rcpt-z-rep},~
{&bef-rcpt-shft-close},~
{&bef-rcpt-shft-open},~
{&bef-rcpt-pre-sale},~
{&bef-rcpt-pre-return},~
{&bef-rcpt-pre-annu},~
{&bef-rcpt-pre-write-off},~
{&bef-rcpt-pre-return-write-off},~
{&bef-rcpt-pre-trans-cancell},~
{&bef-rcpt-pre-overflow},~
{&bef-rcpt-pre-trans-transfer},~
{&bef-rcpt-pre-tech-refuell},~
{&bef-rcpt-pre-inventory},~
{&bef-rcpt-pre-z-rep},~
{&bef-rcpt-pre-unlock-trans},~
{&bef-rcpt-pre-shft-close},~
{&bef-rcpt-ord-sale},~
{&bef-rcpt-ord-return},~
{&bef-rcpt-ord-annu},~
{&bef-rcpt-ord-sale-closed},~
{&bef-rcpt-ord-return-closed},~
{&bef-encashment},~
{&bef-cd-fund},~
{&bef-pay-transfer},~
{&bef-cd-expense},~
{&bef-cd-drawer},~
{&bef-income-corr},~
{&bef-expense-corr}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define no-sale-receipt-codes {&no-sale-receipt-codes}" ).


&glob no-d-card-receipt-codes '{&bef-rcpt-trans-cancell},~
{&bef-rcpt-overflow},~
{&bef-rcpt-trans-transfer},~
{&bef-rcpt-unlock-trans},~
{&bef-rcpt-tech-refuell},~
{&bef-rcpt-annu},~
{&bef-rcpt-inventory},~
{&bef-rcpt-z-rep},~
{&bef-rcpt-shft-close},~
{&bef-rcpt-shft-open},~
{&bef-rcpt-write-off},~
{&bef-rcpt-pre-sale},~
{&bef-rcpt-pre-return},~
{&bef-rcpt-pre-annu},~
{&bef-rcpt-pre-write-off},~
{&bef-rcpt-pre-return-write-off},~
{&bef-rcpt-pre-trans-cancell},~
{&bef-rcpt-pre-overflow},~
{&bef-rcpt-pre-trans-transfer},~
{&bef-rcpt-pre-tech-refuell},~
{&bef-rcpt-pre-inventory},~
{&bef-rcpt-pre-z-rep},~
{&bef-rcpt-pre-unlock-trans},~
{&bef-rcpt-pre-shft-close},~
{&bef-rcpt-pre-sale},~
{&bef-rcpt-pre-return},~
{&bef-rcpt-pre-annu},~
{&bef-rcpt-ord-annu},~
{&bef-encashment},~
{&bef-cd-fund},~
{&bef-pay-transfer},~
{&bef-cd-expense},~
{&bef-cd-drawer},~
{&bef-income-corr},~
{&bef-expense-corr}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define no-d-card-receipt-codes {&no-d-card-receipt-codes}" ).

&glob sale-out-receipt-codes '{&bef-rcpt-sale},~
{&bef-rcpt-write-off},~
{&bef-rcpt-trans-cancell},~
{&bef-rcpt-overflow},~
{&bef-rcpt-trans-transfer},~
{&bef-rcpt-unlock-trans}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define sale-out-receipt-codes {&sale-out-receipt-codes}" ).

&glob sale-in-receipt-codes '{&bef-rcpt-return},~
{&bef-rcpt-return-write-off}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define sale-in-receipt-codes {&sale-in-receipt-codes}" ).

&glob pre-receipt-codes '{&bef-rcpt-pre-sale},~
{&bef-rcpt-pre-return},~
{&bef-rcpt-pre-annu},~
{&bef-rcpt-pre-write-off},~
{&bef-rcpt-pre-return-write-off},~
{&bef-rcpt-pre-trans-cancell},~
{&bef-rcpt-pre-overflow},~
{&bef-rcpt-pre-trans-transfer},~
{&bef-rcpt-pre-unlock-trans},~
{&bef-rcpt-pre-tech-refuell},~
{&bef-rcpt-pre-inventory},~
{&bef-rcpt-pre-z-rep},~
{&bef-rcpt-pre-shft-close}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define pre-receipt-codes {&pre-receipt-codes}" ).


&glob ord-receipt-codes '{&bef-rcpt-ord-sale}~
,{&bef-rcpt-ord-return}~
,{&bef-rcpt-ord-annu}~
,{&bef-rcpt-ord-sale-closed}~
,{&bef-rcpt-ord-return-closed}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define ord-receipt-codes {&ord-receipt-codes}" ).


&glob no-inkas-receipt-codes '{&bef-rcpt-inventory}~
,{&bef-rcpt-pre-inventory}~
,{&bef-rcpt-ord-sale}~
,{&bef-rcpt-ord-return}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define no-inkas-receipt-codes {&no-inkas-receipt-codes}" ).

&glob inventory-receipt-codes '{&bef-rcpt-inventory}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define inventory-receipt-codes {&inventory-receipt-codes}" ).


&glob no-gds-receipt-codes '~
{&bef-rcpt-z-rep}~
,{&bef-rcpt-shft-close}~
,{&bef-rcpt-shft-open}~
,{&bef-rcpt-pre-z-rep}~
,{&bef-rcpt-pre-shft-close}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define no-gds-receipt-codes {&no-gds-receipt-codes}" ).


&glob no-pay-receipt-codes '~
{&bef-rcpt-trans-cancell}~
,{&bef-rcpt-overflow}~
,{&bef-rcpt-trans-transfer}~
,{&bef-rcpt-tech-refuell}~
,{&bef-rcpt-inventory}~
,{&bef-rcpt-shft-close}~
,{&bef-rcpt-shft-open}~
,{&bef-rcpt-pre-trans-cancell}~
,{&bef-rcpt-pre-overflow}~
,{&bef-rcpt-pre-trans-transfer}~
,{&bef-rcpt-pre-unlock-trans},~
,{&bef-rcpt-pre-tech-refuell}~
,{&bef-rcpt-pre-inventory}~
,{&bef-rcpt-pre-shft-close}~
,{&bef-rcpt-ord-sale}~
,{&bef-rcpt-ord-return}~
,{&bef-rcpt-ord-annu}~
,{&bef-rcpt-ord-sale-closed}~
,{&bef-rcpt-ord-return-closed}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define no-pay-receipt-codes {&no-pay-receipt-codes}" ).

&glob no-discnt-receipt-codes '~
{&bef-rcpt-trans-cancell}~
,{&bef-rcpt-overflow}~
,{&bef-rcpt-trans-transfer}~
,{&bef-rcpt-unlock-trans},~
,{&bef-rcpt-tech-refuell}~
,{&bef-rcpt-inventory}~
,{&bef-rcpt-z-rep}~
,{&bef-rcpt-shft-close}~
,{&bef-rcpt-shft-open}~
,{&bef-rcpt-pre-trans-cancell}~
,{&bef-rcpt-pre-overflow}~
,{&bef-rcpt-pre-trans-transfer}~
,{&bef-rcpt-pre-tech-refuell}~
,{&bef-rcpt-pre-inventory}~
,{&bef-rcpt-pre-z-rep}~
,{&bef-rcpt-pre-unlock-trans},~
,{&bef-rcpt-pre-shft-close}~
,{&bef-rcpt-annu}~
,{&bef-rcpt-pre-annu}~
,{&bef-rcpt-ord-annu}~
,{&bef-encashment}~
,{&bef-cd-fund}~
,{&bef-pay-transfer}~
,{&bef-cd-expense}~
,{&bef-cd-drawer}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define no-discnt-receipt-codes {&no-discnt-receipt-codes}" ).


&glob no-calc-discnt-receipt-codes '~
{&bef-rcpt-return}~
,{&bef-rcpt-write-off}~
,{&bef-rcpt-return-write-off}~
,{&bef-rcpt-pre-return}~
,{&bef-rcpt-pre-write-off}~
,{&bef-rcpt-pre-return-write-off}~
,{&bef-rcpt-ord-return}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define no-calc-discnt-receipt-codes {&no-calc-discnt-receipt-codes}" ).





&glob annu-receipt-codes '~
{&bef-rcpt-annu}~
,{&bef-rcpt-pre-annu}~
,{&bef-rcpt-ord-annu}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define annu-receipt-codes {&annu-receipt-codes}" ).




/* Получение типа списания товара через числовой код списания*/
/*для чека расхода*/
{ cmp/cr-prep.i 1 wro-without-payment     1               Без_оплаты            1       Without_Payment}

/*модификатор на расходе*/
{ cmp/cr-prep.i 1 wro-r-modificator       2               Модификатор           2       Modificator }

/*модификатор на расходе без оплаты*/
{ cmp/cr-prep.i 1 wro-r-modificator-wp    3               Модификатор(+спис)    3       Modificator(+wr-off) }

/*товар техпролива*/
{ cmp/cr-prep.i 1 wro-r-tech-refuell     17               Техпролив             17      TechRefuell}


/*для чека возврата*/
{ cmp/cr-prep.i 1 wro-cancell-item    "-6"               Отмена_позиции        "-6"   Cancell_Item}

/*для чека возврат-списание*/
{ cmp/cr-prep.i 1 wro-cancell-all     "-9"               Полн_Отмена           "-9"   Cancell_All}

/*модификатор на возврате*/
{ cmp/cr-prep.i 1 wro-v-modificator   "-2"               Модификатор           "-2"   Modificator}

/*модификатор на возврате в отмене позиции*/
{ cmp/cr-prep.i 1 wro-v-modificator-ci   "-3"             Модификатор(-спис)   "-3"   Modificator(-wr-off) }

/*модификатор на возврате в чекек возврат списание*/
{ cmp/cr-prep.i 1 wro-v-modificator-ca   "-4"             Модификатор(-спис)   "-4"   Modificator(-wr-off) }



&glob wro-codes '?,0,{&bef-wro-without-payment},~
{&bef-wro-cancell-item},~
{&bef-wro-cancell-all},~
{&bef-wro-r-modificator},~
{&bef-wro-v-modificator},~
{&bef-wro-r-modificator-wp},~
{&bef-wro-v-modificator-ci},~
{&bef-wro-v-modificator-ca},~
{&bef-wro-r-tech-refuell}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define wro-codes {&wro-codes}" ).

&glob wro-modificator-codes '{&bef-wro-r-modificator},~
{&bef-wro-v-modificator},~
{&bef-wro-r-modificator-wp},~
{&bef-wro-v-modificator-ci},~
{&bef-wro-v-modificator-ca}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define wro-modificator-codes {&wro-modificator-codes}" ).


&glob wro-codes-full ',,{&bef-wro-without-payment-full},~
{&bef-wro-cancell-item-full},~
{&bef-wro-cancell-all-full},~
{&bef-wro-r-modificator-full},~
{&bef-wro-v-modificator-full},~
{&bef-wro-r-modificator-wp-full},~
{&bef-wro-v-modificator-ci-full},~
{&bef-wro-v-modificator-ca-full},~
{&bef-wro-r-tech-refuell-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define wro-codes-full {&wro-codes-full}" ).


&glob wro-name entry (lookup (~~~~~~~{&wro-code},  {&wro-codes}), {&wro-codes-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define wro-name {&wro-name}" ).


&glob wro-is-modificator  (lookup (~~~~~~~{&wro-code},  {&wro-modificator-codes}) > 0)
run filwrlib_append-new-line in this-procedure ( input "&global-define wro-is-modificator {&wro-is-modificator}" ).







/* Получение типа чека МЦ через его числовой код */

&glob wth-receipt-codes '{&bef-encashment},{&bef-cd-fund},{&bef-pay-transfer},{&bef-cd-expense},{&bef-cd-drawer}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define wth-receipt-codes {&wth-receipt-codes}" ).
&glob wth-receipt-codes-full '{&bef-encashment-full},{&bef-cd-fund-full},{&bef-pay-transfer-full},{&bef-cd-expense-full},{&bef-cd-drawer-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define wth-receipt-codes-full {&wth-receipt-codes-full}" ).


&glob wth-receipt-name entry (lookup (~~~~~~~{&wth-receipt-code},  {&wth-receipt-codes}) + 1, ',' + {&wth-receipt-codes-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define wth-receipt-name {&wth-receipt-name}" ).


/* Получение типа набора кода товара на кассе через его числовой код */
{ cmp/cr-prep.i 1 gds-scaner             0                Сканер                0   Scaner}
{ cmp/cr-prep.i 1 gds-manual             1                Вручную               1   Manual}
{ cmp/cr-prep.i 1 gds-pass-copy          2                Копирование           2   Coping}

&glob pass-gds-name entry (lookup (~~~~~~~{&pass-gds-code}, ~
'{&bef-gds-scaner},{&bef-gds-manual},{&bef-gds-pass-copy}':U), ~
'{&bef-gds-scaner-full},{&bef-gds-manual-full},{&bef-gds-pass-copy-full}':U)
run filwrlib_append-new-line in this-procedure ( input "&global-define pass-gds-name {&pass-gds-name}" ).

/* Получение типа прохождения платежа на кассе через его числовой код */
{ cmp/cr-prep.i 1 pay-card               0                Карта                 0   Card  }
{ cmp/cr-prep.i 1 pay-manual             1                Вручную               1   Manual}

&glob pass-pay-name entry (lookup (~~~~~~~{&pass-pay-code}, ~
'{&bef-pay-card},{&bef-pay-manual}':U), ~
'{&bef-pay-card-full},{&bef-pay-manual-full}':U)
run filwrlib_append-new-line in this-procedure ( input "&global-define pass-pay-name {&pass-pay-name}" ).

{ cmp/cr-prep.i 1 harh-type-month               "мес"        " "   mo.}

/* ------------------------------------------------------------------------------------------ */
/* окончательные для Init-rht.p */
/* ------------------------------------------------------------------------------------------ */

&glob right-type-global 'global':U
run filwrlib_append-new-line in this-procedure ( input "&global-define right-type-global {&right-type-global}" ).
&glob right-type-firm 'firm':U
run filwrlib_append-new-line in this-procedure ( input "&global-define right-type-firm {&right-type-firm}" ).
&glob right-type-object 'object':U
run filwrlib_append-new-line in this-procedure ( input "&global-define right-type-object {&right-type-object}" ).

{ cmp/cr-prep.i 1 obj                        "объ"                              " " object             }
{ cmp/cr-prep.i 1 archive                    "архив"                            " " archive            }
{ cmp/cr-prep.i 1 archive-prc                "архив-переоценка"                 " " archive-prc        }
{ cmp/cr-prep.i 1 archive-arh                "архив-товар"                      " " archive-arh        }
{ cmp/cr-prep.i 1 archive-ahsp               "архив-поставщик"                  " " archive-ahsp       }
{ cmp/cr-prep.i 1 archive-aht                "архив-приобретение"               " " archive-aht        }
{ cmp/cr-prep.i 1 archive-ahcl               "архив-контрагент"                 " " archive-client     }
{ cmp/cr-prep.i 1 archive-hold               "архив-межфирм"                    " " archive-multyfirm  }
{ cmp/cr-prep.i 1 update-closed              "коррекция_закрытых"               " " update-closed      }
{ cmp/cr-prep.i 1 update-last-date           "коррекция_сроки_годности"         " " update-last-date   }
{ cmp/cr-prep.i 1 cost                       "учет"                             " " cost               }
{ cmp/cr-prep.i 1 period                     "срок"                             " " period             }
{ cmp/cr-prep.i 1 reserves                   "резервы"                          " " reserve            }
{ cmp/cr-prep.i 1 inquires                   "запросы"                          " " inquiry            }
{ cmp/cr-prep.i 1 sale                       "продажа"                          " " sale               }
{ cmp/cr-prep.i 1 cashdesk_goods             "касса/товары"                     " " POS/goods          }
{ cmp/cr-prep.i 1 cashdesk_discnt_total      "касса/скидки_на_итог"             " " POS/total-discount }
{ cmp/cr-prep.i 1 cashdesk_taxn              "касса/категории_и_ставки_налогов" " " POS/taxes-value    }
{ cmp/cr-prep.i 1 cashdesk_taxg              "касса/налоги_на_товар"            " " POS/taxes-goods    }
{ cmp/cr-prep.i 1 deletion                   "удаление"                         " " deletion           }
{ cmp/cr-prep.i 1 cashdesk_clients           "касса/клиенты"                    " " POS/client         }
{ cmp/cr-prep.i 1 cashdesk_rates             "касса/курсы"                      " " POS/curr-rate      }
{ cmp/cr-prep.i 1 cashdesk_payments          "касса/платежи"                    " " POS/payment        }
{ cmp/cr-prep.i 1 cashdesk_goods-groups      "касса/группы товаров"             " " POS/goods-group    }
{ cmp/cr-prep.i 1 cashdesk_cashiers          "касса/кассиры"                    " " POS/cashier        }
{ cmp/cr-prep.i 1 cashdesk_sellers           "касса/продавцы"                   " " POS/seller         }
{ cmp/cr-prep.i 1 cashdesk_restaurant        "касса/ресторан"                   " " POS/restaurant     }
{ cmp/cr-prep.i 1 scales                     "весы"                             " " scales             }
{ cmp/cr-prep.i 1 sending                    "отправка"                         " " POS/send           }
{ cmp/cr-prep.i 1 receipt                    "создание-чека"                    " " cre-receipt        }
{ cmp/cr-prep.i 1 wth-receipt                "чек-МЦ"                           " " wth-receipt        }
{ cmp/cr-prep.i 1 input                      "ввод"                             " " input              }
{ cmp/cr-prep.i 1 opening                    "открытие"                         " " open               }
{ cmp/cr-prep.i 1 opening-inquiry            "открытие-запроса"                 " " open-inquiry       }
{ cmp/cr-prep.i 1 print                      "печать"                           " " print              }
{ cmp/cr-prep.i 1 info                       "инфо"                             " " info               }
{ cmp/cr-prep.i 1 preparation                "подготовка"                       " " preparation        }
{ cmp/cr-prep.i 1 prepownfirmhold            "подготовка-по-собств-фирме"       " " prepownfirmhold    }
{ cmp/cr-prep.i 1 cr-revision                "создание-сверки"                  " " cr-revision        }
{ cmp/cr-prep.i 1 upd-revision               "изменение-сверки"                 " " upd-revision       }
{ cmp/cr-prep.i 1 permission                 "разрешение"                       " " permission         }
{ cmp/cr-prep.i 1 perm-cancellation          "отмена-разр"                      " " perm-cancellation  }
{ cmp/cr-prep.i 1 price                      "цена"                             " " price              }
{ cmp/cr-prep.i 1 shipping                   "отгрузка"                         " " shipping           }
{ cmp/cr-prep.i 1 fact-edit                  "редакт-факт"                      " " fact-edit          }
{ cmp/cr-prep.i 1 overvalue                  "переоценка"                       " " overvalue          }
{ cmp/cr-prep.i 1 travel-sheet               "путевой-лист"                     " " travel-sheet       }
{ cmp/cr-prep.i 1 properties                 "признаки"                         " " properties         }
{ cmp/cr-prep.i 1 manufacturing              "производство"                     " " manufacturing      }
{ cmp/cr-prep.i 1 gathering                  "комплектация"                     " " gathering          }
{ cmp/cr-prep.i 1 dressing                   "разделка"                         " " dressing           }
{ cmp/cr-prep.i 1 alternative                "альтернатива"                     " " alternative        }
{ cmp/cr-prep.i 1 petrolium-manufacturing    "топливо"                          " " petroleum-manufact }
{ cmp/cr-prep.i 1 split-fuse                 "разбиение-слияние"                " " split-fuse         }
{ cmp/cr-prep.i 1 lookup-crsa                "продажные_цены"                   " " lookup-price-crsa  }
{ cmp/cr-prep.i 1 lookup-sale                "цены_документа"                   " " lookup-price-sale  }
{ cmp/cr-prep.i 1 lookup-cost                "учетные_цены"                     " " lookup-price-cost  }
{ cmp/cr-prep.i 1 lookup-medi                "цены_посредника"                  " " lookup-price-mediatr  }
{ cmp/cr-prep.i 1 object-date                "дата_на_объекте"                  " " object-date           }
{ cmp/cr-prep.i 1 object-weight-code         "весовой-код-на-объекте"           " " weight-code-on-object }
{ cmp/cr-prep.i 1 rights                     "назначение-прав"                  " " right-assignment      }
{ cmp/cr-prep.i 1 groups                     "группы"                                    " " "groups"                   }
{ cmp/cr-prep.i 1 invoice                    "счет-фактура"                              " " invoice                    }
{ cmp/cr-prep.i 1 client-cards               "карты-клиента"                             " " client-card                }
{ cmp/cr-prep.i 1 payment-input              "ввод-платежа"                              " " payment-input              }
{ cmp/cr-prep.i 1 payment-deletion           "удаление-платежа"                          " " payment-deletion           }
{ cmp/cr-prep.i 1 unit                       "ед.измерения"                              " " unit                       }
{ cmp/cr-prep.i 1 tax-kinds                  "виды-налогов"                              " " tax-kinds                  }
{ cmp/cr-prep.i 1 tax-rates                  "коды-ставок-налогов"                       " " tax-rate-codes             }
{ cmp/cr-prep.i 1 tax-rate-values            "значения-ставок-налогов"                   " " tax-rate-values            }
{ cmp/cr-prep.i 1 scale                      "шкалы"                                     " " scale                      }
{ cmp/cr-prep.i 1 payments                   "оплаты"                                    " " payment                    }
{ cmp/cr-prep.i 1 reference                  "справочник"                                " " reference                  }
{ cmp/cr-prep.i 1 groups-edit                "изменение-групп"                           " " group-edit                 }
{ cmp/cr-prep.i 1 clients-group              "группа-клиентов"                           " " client-group               }
{ cmp/cr-prep.i 1 discount                   "скидка"                                    " " discount                   }
{ cmp/cr-prep.i 1 calc-increase              "исходная-наценка"                          " " price-calc-param           }
{ cmp/cr-prep.i 1 cur-obj-proceeds           "чеки-и-выручка"                            " " receipts-and-revenue       }
{ cmp/cr-prep.i 1 sales-book                 "книга-продаж"                              " " sale-book                  }
{ cmp/cr-prep.i 1 purchase-book              "книга-покупок"                             " " purchase-book              }
{ cmp/cr-prep.i 1 currency-reference         "справочник-валют"                          " " currency-reference         }
{ cmp/cr-prep.i 1 reports                    "отчеты"                                    " " report                     }
{ cmp/cr-prep.i 1 payments-types             "типы-платежей"                             " " payment-type               }
{ cmp/cr-prep.i 1 input_deletion_updating    "ввод,удал,изм"                             " " preparation                }
{ cmp/cr-prep.i 1 tax-settlement             "расчет-налогов"                            " " tax-settlement             }
{ cmp/cr-prep.i 1 cuontry-reference          "справочник-стран"                          " " country-reference          }
{ cmp/cr-prep.i 1 pump-reference             "справочник-ТРК"                            " " pump-reference             }
{ cmp/cr-prep.i 1 place-reference            "справочник-складские-места"                " " place-reference            }
{ cmp/cr-prep.i 1 wth-place-reference        "справочник-места-хранения-МЦ"              " " wth-place-reference        }
{ cmp/cr-prep.i 1 exmark-reference           "справочник-акцизные-марки"                 " " exmark-reference           }
{ cmp/cr-prep.i 1 payments-expected          "платежи-ожидаемые"                         " " payments-expected          }
{ cmp/cr-prep.i 1 payments-reference         "список-платежей"                           " " payments-reference         }
{ cmp/cr-prep.i 1 receipts                   "чеки"                                      " " receipt                    }
{ cmp/cr-prep.i 1 wth-receipts               "чеки-МЦ"                                   " " wth-receipt                }
{ cmp/cr-prep.i 1 cashiers                   "кассиры"                                   " " cashier                    }
{ cmp/cr-prep.i 1 scales_goods-groups        "весы/группы-товаров"                       " " scales/goods-group         }
{ cmp/cr-prep.i 1 adding_deletion            "добавление,удаление"                       " " add-delete                 }
{ cmp/cr-prep.i 1 cashdesk-reference         "справочник_касс"                           " " POS-reference              }
{ cmp/cr-prep.i 1 on_off                     "вкл./выкл."                                " " on-off                     }
{ cmp/cr-prep.i 1 composition-print          "печать-в-набор"                            " " composition-print          }
{ cmp/cr-prep.i 1 composition-reprint        "печать-в-набор,-повторно"                  " " composition-reprint        }
{ cmp/cr-prep.i 1 waybill                    "накладная"                                 " " waybill                    }
{ cmp/cr-prep.i 1 references                 "справочники"                               " " reference                  }
{ cmp/cr-prep.i 1 export                     "экспорт"                                   " " export                     }
{ cmp/cr-prep.i 1 documents                  "документы"                                 " " document                   }
{ cmp/cr-prep.i 1 c-documents                "удал_документы"                            " " del_document               }
{ cmp/cr-prep.i 1 acc-service                "буг_сервис"                                " " account-service            }
{ cmp/cr-prep.i 1 trans-generation           "генер-пров"                                " " transaction-generation     }
{ cmp/cr-prep.i 1 acc-functions              "буг_функции"                               " " account-function           }
{ cmp/cr-prep.i 1 main-book                  "главная-книга"                             " " main-book                  }
{ cmp/cr-prep.i 1 balance                    "баланс"                                    " " balance                    }
{ cmp/cr-prep.i 1 multibalance               "мультибаланс"                              " " multibalance               }
{ cmp/cr-prep.i 1 close                      "закрыть"                                   " " close                      }
{ cmp/cr-prep.i 1 open                       "открыть"                                   " " open                       }
{ cmp/cr-prep.i 1 transless-waybill          "накл-без-пров"                             " " waybill-without-trans      }
{ cmp/cr-prep.i 1 transactions               "проводки"                                  " " transaction                }
{ cmp/cr-prep.i 1 base-curr-amount           "сумма-бв"                                  " " base-curr-amount           }
{ cmp/cr-prep.i 1 upd-status                 "изм_статус"                                " " update-status              }
{ cmp/cr-prep.i 1 upd-comlete-trans          "изм_сгенер_пров"                           " " update-complete-transaction}
{ cmp/cr-prep.i 1 upd-group                  "изм_группы"                                " " update-group               }
{ cmp/cr-prep.i 1 upd-nat-loss-rate          "изм_нормы_естеств.убыли"                   " " update-natural-loss-rate   }
{ cmp/cr-prep.i 1 upd-gds-tax                "изм_налогов_на_товар"                      " " update-goods-tax           }
{ cmp/cr-prep.i 1 analitic                   "аналитика"                                 " " analitic                   }
{ cmp/cr-prep.i 1 add-nodes                  "добавить-узлы"                             " " add-node                   }
{ cmp/cr-prep.i 1 upd-nodes                  "изменить-узлы"                             " " update-node                }
{ cmp/cr-prep.i 1 del-nodes                  "удалить-узлы"                              " " delete-node                }
{ cmp/cr-prep.i 1 add-acc-item               "добавить-статьи"                           " " add-acc-item               }
{ cmp/cr-prep.i 1 upd-acc-item               "изменить-статьи"                           " " update-acc-item            }
{ cmp/cr-prep.i 1 del-acc-item               "удалить-статьи"                            " " delete-acc-item            }
{ cmp/cr-prep.i 1 del-archive                "удалить-архив"                             " " delete-archive             }
{ cmp/cr-prep.i 1 functions                  "функции"                                   " " function                   }
{ cmp/cr-prep.i 1 cash-book                  "кас-книга"                                 " " cash-book                  }
{ cmp/cr-prep.i 1 jobber-turn                "курс-разница"                              " " jobber-turn                }
{ cmp/cr-prep.i 1 jobber-turn-base-curr      "курс-разн-бв"                              " " jobber-turn-base-curr      }
{ cmp/cr-prep.i 1 jobber-turn-roubles        "курс-разн-{&scop-begin}abbr_rub{&scop-end}" " " jobber-turn-roubles       }
{ cmp/cr-prep.i 1 acc-options                "буг_настройки"                             " " account-options            }
{ cmp/cr-prep.i 1 external-auto-transaction  "внешн-авт-пров"                            " " external-transaction       }
{ cmp/cr-prep.i 1 typical-oper-add           "тип_опер_ввод"                             " " typical-oper-add           }
{ cmp/cr-prep.i 1 typical-oper-upd           "тип_опер_изм"                              " " typical-oper-update        }
{ cmp/cr-prep.i 1 typical-oper-del           "тип_опер_удал"                             " " typical-oper-delete        }
{ cmp/cr-prep.i 1 form-add                   "формы_ввод"                                " " form-add                   }
{ cmp/cr-prep.i 1 form-upd                   "формы_изм"                                 " " form-update                }
{ cmp/cr-prep.i 1 form-del                   "формы_удал"                                " " form-delete                }
{ cmp/cr-prep.i 1 oper-sum-add               "суммы_ввод"                                " " oper-sum-add               }
{ cmp/cr-prep.i 1 oper-sum-upd               "суммы_изм"                                 " " oper-sum-update            }
{ cmp/cr-prep.i 1 oper-sum-del               "суммы_удал"                                " " oper-sum-delete            }
{ cmp/cr-prep.i 1 utilities                  "утилиты"                                   " " utilities                  }
{ cmp/cr-prep.i 1 depreciation-rate          "нормы-амортизации"                         " " depreciation-rate          }
{ cmp/cr-prep.i 1 fixed-assets-groups        "группы-ОС"                                 " " fixed-assets-group         }
{ cmp/cr-prep.i 1 fixed-assets-cards         "карточки-ОС"                               " " fixed-assets-card          }
{ cmp/cr-prep.i 1 disposition_reconstruction "ликв/вост"                                 " " disposition-reconstruction }
{ cmp/cr-prep.i 1 displacement               "перемещение"                               " " displacement               }
{ cmp/cr-prep.i 1 modernization              "модернизаци~377"                           " " "modernization"            }
{ cmp/cr-prep.i 1 card-print                 "печать-карточки"                           " " card-print                 }
{ cmp/cr-prep.i 1 supplies-cards             "карточки-МБП"                              " " supplies-cards             }
{ cmp/cr-prep.i 1 row-cards                  "карточки-Материалов"                       " " row-cards                  }
{ cmp/cr-prep.i 1 os-oper-type               "тип операций ОС"                           " " "assets operation type"    }
{ cmp/cr-prep.i 1 os-oper-var                "вариант операций ОС"                       " " "assets operation variant" }
{ cmp/cr-prep.i 1 os-src-docs                "первичный документ ОС"                     " " "assets source documents"  }
{ cmp/cr-prep.i 1 os-frm-docs                "печатная форма ОС"                         " " "assets print form"        }
{ cmp/cr-prep.i 1 os-form-pdoc               "печатная форма первичного документа ОС"    " " "assets print form of a source document" }
{ cmp/cr-prep.i 1 os-act-kind                "вид деятельности"                          " " "assets kind of activity"  }
{ cmp/cr-prep.i 1 os-group-tax               "группа налогового учета"                   " " "assets tax group"         }
{ cmp/cr-prep.i 1 alt-barcode                "доп-БК"                                    " " alt-barcode                }
{ cmp/cr-prep.i 1 turn-on                    "включение"                                 " " turn-on                    }
{ cmp/cr-prep.i 1 main-barcode               "соб-БК"                                    " " main-barcode               }
{ cmp/cr-prep.i 1 reference-lists            "списки-из-справочников"                    " " reference-list             }
{ cmp/cr-prep.i 1 waybills-to-file           "вывод-накладных-в-файл"                    " " waybills-to-file           }
{ cmp/cr-prep.i 1 overvalue-cast             "переоценка,-учетные-цены"                  " " overvalue-cast             }
{ cmp/cr-prep.i 1 price-list                 "прайс-лист"                                " " price-list                 }
{ cmp/cr-prep.i 1 document-reports-sale      "отчеты-по-док-там,-продажные-цены"         " " document-reports-sale      }
{ cmp/cr-prep.i 1 document-reports-cost      "отчеты-по-док-там,-учетные-цены"           " " document-reports-cost      }
{ cmp/cr-prep.i 1 proceeds-monthly           "помесячная-выручка-по-магазинам"           " " proceeds-monthly           }
{ cmp/cr-prep.i 1 prod-monthly               "помесячные-обороты-по-производителям"      " " prod-monthly               }
{ cmp/cr-prep.i 1 prod-classifier-monthly    "помесячный-оборот-по-производителю-и-классификатору" " " prod-classifier-monthly}
{ cmp/cr-prep.i 1 sale-report                "отчет-по-реализации"                       " " sale-report                }
{ cmp/cr-prep.i 1 permanent-client-sale      "отчет-по-продажам-постоянным-клиентам"     " " permanent-client-sale      }
{ cmp/cr-prep.i 1 discount-cards-totals      "итоги-по-дисконтным-картам"                " " discount-cards-totals      }
{ cmp/cr-prep.i 1 price-list-to-file         "прайс-лист,вывод-в-файл"                   " " price-list-to-file         }
{ cmp/cr-prep.i 1 PS-fact                    "примечание-(факт)"                         " " PS-fact                    }
{ cmp/cr-prep.i 1 CB-rate                    "курс-ЦБ"                                   " " CB-rate                    }
{ cmp/cr-prep.i 1 MICEX-rate                 "курс-ММВБ"                                 " " MICEX-rate                 }
{ cmp/cr-prep.i 1 shop-rate                  "курс-магазин"                              " " shop-rate                  }
{ cmp/cr-prep.i 1 obj-date-change            "дата-объекта"                              " " obj-date                   }
{ cmp/cr-prep.i 1 client-reference           "справочник-кли"                            " " client-reference           }
{ cmp/cr-prep.i 1 client-reference-prs       "справочник-кли-чел"                        " " client-reference-prs       }
{ cmp/cr-prep.i 1 add-del                    "ввод,удал"                                 " " add-del                    }
{ cmp/cr-prep.i 1 reference-dc-type          "справочник-типов-дис"                      " " reference-dc-type          }
{ cmp/cr-prep.i 1 refernse-dis               "справочник-дис"                            " " refernse-dis               }
{ cmp/cr-prep.i 1 recipe-reference           "спр-к_рецептов"                            " " recipe-reference           }
{ cmp/cr-prep.i 1 client-requisite           "реквизиты-клиента"                         " " client-requisite           }
{ cmp/cr-prep.i 1 ren-art                    "артикул_и_производитель"                   " " ren-art                    }
{ cmp/cr-prep.i 1 add-upd                    "ввод,изменение"                            " " add-upd                    }
{ cmp/cr-prep.i 1 all                        "все"                                       " " all                        }
{ cmp/cr-prep.i 1 c-all                      "уд_все"                                    " " c-all                      }
{ cmp/cr-prep.i 1 current                    "текущие"                                   " " current                    }
{ cmp/cr-prep.i 1 deleted                    "удаленные"                                 " " deleted                    }
{ cmp/cr-prep.i 1 by_all                     "всем"                                      " " by_all                     }
{ cmp/cr-prep.i 1 shop                       "маг"                                       " " shp                        }
{ cmp/cr-prep.i 1 stock                      "скл"                                       " " str                        }
{ cmp/cr-prep.i 1 cmp                        "орг"                                       " " cmp                        }
{ cmp/cr-prep.i 1 prs                        "чел"                                       " " prs                        }
{ cmp/cr-prep.i 1 db                         "БД"                                        " " DB                         }
{ cmp/cr-prep.i 1 region                     "регион"                                    " " region                     }
{ cmp/cr-prep.i 1 current-status             "тек"                                       " " actual                     }
{ cmp/cr-prep.i 1 deleted-status             "удал"                                      " " deleted                    }
{ cmp/cr-prep.i 1 blocked-status             "блок"                                      " " blocked                    }
{ cmp/cr-prep.i 1 nonused-status             "неисп"                                     " " non-used                   }
{ cmp/cr-prep.i 1 chown-status               "смкли"                                     " " chown                      }
{ cmp/cr-prep.i 1 current-status-int         0      тек                                  0   actual                     }
{ cmp/cr-prep.i 1 deleted-status-int         1      удал                                 1   deleted                    }
{ cmp/cr-prep.i 1 blocked-status-int         50     блок                                 50   blocked                   }
{ cmp/cr-prep.i 1 new-status-int             -10    нов                                  -10  new                       }
{ cmp/cr-prep.i 1 ready-status-int           -1     готов                                -1   ready                     }


{ cmp/cr-prep.i 1 used-status-int            0      исп                                  0   used                       }
{ cmp/cr-prep.i 1 non-used-status-int        1      не-исп                               1   non-used                   }
{ cmp/cr-prep.i 1 non-root-status-int        2      детализ                              2   detailed                   }
{ cmp/cr-prep.i 1 req-to-del-int             98     запр.удал                            98  req-del                    }
{ cmp/cr-prep.i 1 to-delete-status-int       99     удаление                             99  deleting                   }

{ cmp/cr-prep.i 1 user-status-normal    0      текущий                  0   current         }
{ cmp/cr-prep.i 1 user-status-deleted   1      удаленный                1   deleted         }

{ cmp/cr-prep.i 1 befor-artic-change-int    50      "блок.для.смены.арт."                50  befor-artic-change         }
{ cmp/cr-prep.i 1 artic-change-int          51      "смена.арт."                         51  artic-change               }

&glob gds-stats-block '{&bef-befor-artic-change-int},{&bef-artic-change-int}'
run filwrlib_append-new-line in this-procedure ( input "&global-define gds-stats-block {&gds-stats-block}" ).

&glob status-int-name entry (lookup (~~~~~~~{&status-code}, ~
'{&bef-current-status-int},{&bef-deleted-status-int},{&bef-blocked-status-int},{&bef-to-delete-status-int}':U), ~
'{&bef-current-status-int-full},{&bef-deleted-status-int-full},{&bef-blocked-status-int-full},{&bef-to-delete-status-int-full}':U)
run filwrlib_append-new-line in this-procedure ( input "&global-define status-int-name {&status-int-name}" ).

&glob used-status-int-name entry (lookup (~~~~~~~{&used-status-code}, ~
'{&bef-used-status-int},{&bef-non-used-status-int},{&bef-non-root-status-int},{&bef-to-delete-status-int},{&bef-req-to-del-int}':U), ~
'{&bef-used-status-int-full},{&bef-non-used-status-int-full},{&bef-non-root-status-int-full},{&bef-to-delete-status-int-full},{&bef-req-to-del-int-full}':U)
run filwrlib_append-new-line in this-procedure ( input "&global-define used-status-int-name {&used-status-int-name}" ).

&glob gds-status-int-name entry (lookup (~~~~~~~{&status-code}, ~
'{&bef-current-status-int},{&bef-deleted-status-int},{&bef-befor-artic-change-int},{&bef-artic-change-int}':U), ~
'{&bef-current-status-int-full},{&bef-deleted-status-int-full},{&bef-befor-artic-change-int-full},{&bef-artic-change-int-full}':U)
run filwrlib_append-new-line in this-procedure ( input "&global-define gds-status-int-name {&gds-status-int-name}" ).

&glob rule-status-int-name entry (lookup (~~~~~~~{&status-code}, ~
'{&bef-ready-status-int}~
,{&bef-new-status-int}~
,{&bef-used-status-int}~
,{&bef-deleted-status-int}~
,{&bef-to-delete-status-int}~
,{&bef-req-to-del-int}~
':U), ~
'{&bef-ready-status-int-full}~
,{&bef-new-status-int-full}~
,{&bef-used-status-int-full}~
,{&bef-deleted-status-int-full}~
,{&bef-to-delete-status-int-full}~
,{&bef-req-to-del-int-full}~
':U)
run filwrlib_append-new-line in this-procedure ( input "&global-define rule-status-int-name {&rule-status-int-name}" ).


{ cmp/cr-prep.i 1 pro                        "про"                                       " " pro                        }
{ cmp/cr-prep.i 1 name                       "название"                                  " " name                       }
{ cmp/cr-prep.i 1 g___code                   "код"                                       " " g___code                   }
{ cmp/cr-prep.i 1 status                     "статус"                                    " " status                     }
{ cmp/cr-prep.i 1 pump                       "ТРК"                                       " " pump                       }
{ cmp/cr-prep.i 1 place                      "склд.место"                                " " place                      }
{ cmp/cr-prep.i 1 wealth                     "МЦ"                                        " " wealth                     }
{ cmp/cr-prep.i 1 wth-par                    "Номинал МЦ"                                " " wth-par                    }
{ cmp/cr-prep.i 1 wth-ser                    "Серии МЦ"                                " " wth-ser                    }
{ cmp/cr-prep.i 1 wth-place                  "Место хранения МЦ"                         " " wth-place                  }
{ cmp/cr-prep.i 1 wth-doc                    "Документ перемещения МЦ"                   " " "wealth moving document"   }
{ cmp/cr-prep.i 1 fbr-prn                    "принтер кухни"                             " " "kitchen printer"          }
{ cmp/cr-prep.i 1 fbr-prn_goods              "принтер кухни/товары"                      " " "kitchen printer/goods"    }

{ cmp/cr-prep.i 1 choose                     "выбор"                                     " " choose                     }
{ cmp/cr-prep.i 1 obj-month                  "объект-мес"                                " " obj-month                  }
{ cmp/cr-prep.i 1 c-obj-month                "уд_объект-мес"                             " " с-obj-month                }
{ cmp/cr-prep.i 1 company                    "фирма"                                     " " company                    }
{ cmp/cr-prep.i 1 c-company                  "уд_фирма"                                  " " c-company                  }
{ cmp/cr-prep.i 1 g___object                 "объект"                                    " " g___object                 }
{ cmp/cr-prep.i 1 c-g___object               "уд_объект"                                 " " c-g___object               }
{ cmp/cr-prep.i 2 all g___object}

{ cmp/cr-prep.i 1 client-cmp                 "Контрагент"                                " " client                     }
{ cmp/cr-prep.i 1 payer                      "Плательщик"                                " " payer                      }
{ cmp/cr-prep.i 1 balance-cmp                "Обороты"                                   " " balance                    }
{ cmp/cr-prep.i 1 stock-cmp                  "Остатки"                                   " " stock                      }
{ cmp/cr-prep.i 1 goods-cmp                  "Товар"                                     " " goods                      }
{ cmp/cr-prep.i 1 prod-cmp                   "Производитель"                             " " prod                       }
{ cmp/cr-prep.i 2 client-cmp balance-cmp}
{ cmp/cr-prep.i 2 client-cmp stock-cmp}
{ cmp/cr-prep.i 2 prod-cmp   balance-cmp}
{ cmp/cr-prep.i 2 prod-cmp   stock-cmp}
{ cmp/cr-prep.i 2 goods-cmp  balance-cmp}
{ cmp/cr-prep.i 2 goods-cmp  stock-cmp}

{ cmp/cr-prep.i 1 Article                    "Артикул"                                   " " Article                    }
{ cmp/cr-prep.i 1 Quantity                   "Количество"                                " " Quantity                   }
{ cmp/cr-prep.i 1 Producer                   "Производитель"                             " " Producer                   }
{ cmp/cr-prep.i 1 Parts                      "партии"                                    " " Parts                      }
{ cmp/cr-prep.i 1 CreateNeg                  "порождение"                                " " CreateNeg                  }
{ cmp/cr-prep.i 1 group-goods-cash-desk      "группы-товаров-на-кассах"                  " " group-goods-cash-desk      }
{ cmp/cr-prep.i 1 plgdspm-sts                "статус-скл_места-трк_товар"                " " plgdspm-sts                }
{ cmp/cr-prep.i 1 reference-petrolium        "справочник-топливо"                        " " reference-petrolium        }
{ cmp/cr-prep.i 1 reference-services         "справочник-услуги"                         " " reference-services         }
{ cmp/cr-prep.i 1 stat-on-cashiers           "статистика-по-кассирам"                    " " stat-on-cashiers           }
{ cmp/cr-prep.i 1 waybill-clear-list         "убр-накл-из-списка"                        " " waybill-clear-list         }

{ cmp/cr-prep.i 1 cash                       "Наличный"                                  " " cash                       }
{ cmp/cr-prep.i 1 electronic                 "Электронный"                               " " electronic                 }
{ cmp/cr-prep.i 1 prepayment                 "Аванс"                                     " " prepayment                 }
{ cmp/cr-prep.i 1 credit                     "Кредит"                                    " " credit                     }
{ cmp/cr-prep.i 1 counter_presentation       "Встречное представление"                   " " counter_presentation       }
{ cmp/cr-prep.i 1 non-fiscal_payment         "Нефискальный платеж"                       " " non-fiscal_payment         }

{ cmp/cr-prep.i 1 shift                      "смена"                                     " " shift                      }
{ cmp/cr-prep.i 1 regular                    "штатный-режим"                             " " regular-mode               }
{ cmp/cr-prep.i 1 super                      "режим-менеджера"                           " " supervisor                 }

{ cmp/cr-prep.i 1 upd-el-cnt                 "изм-эл-сч"                                 " " upd-el-cnt                 }
{ cmp/cr-prep.i 1 fin-reference              "фин_справочник"                            " " fin-reference              }
{ cmp/cr-prep.i 1 fin-contract               "фин_договор"                               " " fin-contract               }
{ cmp/cr-prep.i 1 fin-bank-accounts          "банки_и_счета"                             " " fin-bank-accounts          }
{ cmp/cr-prep.i 1 fin-doc                    "платежи"                                   " " fin-doc                    }
{ cmp/cr-prep.i 1 fin-statement              "выписки"                                   " " fin-statement              }
{ cmp/cr-prep.i 1 fin-liability              "фин_обязательства"                         " " fin-liability              }
{ cmp/cr-prep.i 1 schet-fact-doc             "счета-фактуры"                             " " schet-fact-doc             }

{ cmp/cr-prep.i 1 res-reference              "рес_справочник"                            " " res-reference              }
{ cmp/cr-prep.i 1 res-pln-menu               "рес_план-меню"                             " " res-pln-menu               }
{ cmp/cr-prep.i 1 res-autofbr                "рес_автопроизводство"                      " " res-autofbr                }
{ cmp/cr-prep.i 1 res-print                  "рес_печать"                                " " res-print                  }
/*Виды дополнительных сумм по документу*/
{ cmp/cr-prep.i 1 sum-before-doc              bd                                         Сумма_до_документа                   bd   sum-before-doc       }
{ cmp/cr-prep.i 1 sum-general-doc             gen                                        Сумма_по_документу                   gen  sum-general-doc      }
{ cmp/cr-prep.i 1 sum-expense-parts           exp                                        Сумма_по_израсх_партиям              exp  sum-expense-parts    }
{ cmp/cr-prep.i 1 sum-income-parts            inp                                        Сумма_по_созд_партиям                inp  sum-income-parts     }
{ cmp/cr-prep.i 1 sum-extra-doc               ext                                        Сумма_излиш_по_документу             ext  sum-extra-doc        }
{ cmp/cr-prep.i 1 sum-miss-doc                mis                                        Сумма_недост_по_документу            mis  sum-miss-doc         }
{ cmp/cr-prep.i 1 sum-after-doc               ad                                         Сумма_после_документа                ad   sum-after-doc        }
{ cmp/cr-prep.i 1 sum-before-cli-doc          bcd                                        Сумма_до_док_ед_пост                 bcd  sum-before-cli-doc   }
{ cmp/cr-prep.i 1 sum-extra-cli-doc           extc                                       Сумма_излиш_по_док_ед_пост           extс sum-extra-cli-doc    }
{ cmp/cr-prep.i 1 sum-miss-cli-doc            misc                                       Сумма_недост_по_док_ед_пост          misс sum-miss-cli-doc     }
{ cmp/cr-prep.i 1 sum-general-cli-doc         genc                                       Сумма_по_док_ед_пост                 genс sum-general-cli-doc  }
{ cmp/cr-prep.i 1 sum-after-cli-doc           acd                                        Сумма_после_док_ед_пост              adс  sum-after-cli-doc    }
{ cmp/cr-prep.i 1 sum-wastage-doc             wst                                        Сумма_естеств_убыли                  wst  sum-wastage-doc      }
{ cmp/cr-prep.i 1 sum-wastage-cli-doc         wstc                                       Сумма_естеств_убыли_ед_пост          wstc sum-wastage-cli-doc  }

&glob sum-types '{&bef-sum-before-doc},{&bef-sum-before-cli-doc},{&bef-sum-general-doc},{&bef-sum-general-cli-doc},{&bef-sum-after-doc},{&bef-sum-after-cli-doc},{&bef-sum-wastage-doc},{&bef-sum-wastage-cli-doc},{&bef-sum-extra-doc},{&bef-sum-extra-cli-doc},{&bef-sum-miss-doc},{&bef-sum-miss-cli-doc},{&bef-sum-expense-parts},{&bef-sum-income-parts}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define sum-types {&sum-types}" ).
&glob sum-types-full '{&bef-sum-before-doc-full},{&bef-sum-before-cli-doc-full},{&bef-sum-general-doc-full},{&bef-sum-general-cli-doc-full},{&bef-sum-after-doc-full},{&bef-sum-after-cli-doc-full},{&bef-sum-wastage-doc-full},{&bef-sum-wastage-cli-doc-full},{&bef-sum-extra-doc-full},{&bef-sum-extra-cli-doc-full},{&bef-sum-miss-doc-full},{&bef-sum-miss-cli-doc-full},{&bef-sum-expense-parts-full},{&bef-sum-income-parts-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define sum-types-full {&sum-types-full}" ).
&glob sum-name entry (lookup (~~~~~~~{&sum-type}, {&sum-types} ), {&sum-types-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define sum-name {&sum-name}" ).

{ cmp/cr-prep.i 1 bgh-scf-pay                "платежи"                          " " "payments"           }

{ cmp/cr-prep.i 1 report-benet1              "отчет_benet1"                     " " report-benet1        }
{ cmp/cr-prep.i 1 report-benet2              "отчет_benet2"                     " " report-benet2        }
{ cmp/cr-prep.i 1 report-benet3              "отчет_benet3"                     " " report-benet3        }
{ cmp/cr-prep.i 1 report-benet4              "отчет_benet4"                     " " report-benet4        }
{ cmp/cr-prep.i 1 report-benet5              "отчет_benet5"                     " " report-benet5        }
{ cmp/cr-prep.i 1 report-benet6              "отчет_g-ben-dt"                   " " report-benet6        }


run filwrlib_num-lines-get in this-procedure
  (output p-num-lines
  ) .