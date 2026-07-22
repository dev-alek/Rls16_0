block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
  
Программа генерации файла s t r - g l b l . i . Часть 4

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Инструкции по использованию см в файле s t r - g l b l . p

*/
 
define input  parameter p-file-name    as character no-undo .
define output parameter p-num-lines    as character no-undo .
define output parameter p-vss-revision as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
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

/* Стандартные названия кнопок для любых АРМов системы */
&GLOB Btn_Mark         b-mark
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_Mark {&Btn_Mark}" ).
&GLOB Btn_Help         b-help
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_Help {&Btn_Help}" ).
&GLOB Btn_Select       b-sel
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_Select {&Btn_Select}" ).
&GLOB Btn_Exit         b-exit
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_Exit {&Btn_Exit}" ).
&GLOB Btn_Print        b-print
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_Print {&Btn_Print}" ).
&GLOB Btn_View         b-lkp
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_View {&Btn_View}" ).
&GLOB Btn_Add          b-add
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_Add {&Btn_Add}" ).
&GLOB Btn_Edit         b-chg
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_Edit {&Btn_Edit}" ).
&GLOB Btn_Close        b-close
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_Close {&Btn_Close}" ).
&GLOB Btn_Save         b-save
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_Save {&Btn_Save}" ).
&GLOB Btn_Open         b-open
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_Open {&Btn_Open}" ).
&GLOB Btn_Calc         b-calc
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_Calc {&Btn_Calc}" ).
&GLOB Btn_Unrv         b-unrv
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_Unrv {&Btn_Unrv}" ).
&GLOB Btn_Arch         b-unrv
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_Arch {&Btn_Arch}" ).
&GLOB Btn_Delete       b-del
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_Delete {&Btn_Delete}" ).
&GLOB Btn_Filter       b-sch
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_Filter {&Btn_Filter}" ).
&GLOB Btn_Refresh      b-refresh
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_Refresh {&Btn_Refresh}" ).
&GLOB Btn_History      b-history
run filwrlib_append-new-line in this-procedure ( input "&global-define Btn_History {&Btn_History}" ).


/* Горячие клавиши для любых АРМов */
&GLOB {&Btn_Mark}     INS
run filwrlib_append-new-line in this-procedure ( input "&global-define {&Btn_Mark} {&{&Btn_Mark}}" ).
&GLOB {&Btn_Help}     F1
run filwrlib_append-new-line in this-procedure ( input "&global-define {&Btn_Help} {&{&Btn_Help}}" ).
&GLOB {&Btn_Select}   F2
run filwrlib_append-new-line in this-procedure ( input "&global-define {&Btn_Select} {&{&Btn_Select}}" ).
&GLOB {&Btn_Exit}     F2
run filwrlib_append-new-line in this-procedure ( input "&global-define {&Btn_Exit} {&{&Btn_Exit}}" ).
&GLOB {&Btn_View}     F3
run filwrlib_append-new-line in this-procedure ( input "&global-define {&Btn_View} {&{&Btn_View}}" ).
&GLOB {&Btn_Edit}     F4
run filwrlib_append-new-line in this-procedure ( input "&global-define {&Btn_Edit} {&{&Btn_Edit}}" ).
&GLOB {&Btn_Save}     F7, CTRL-S, CTRL-Ы
run filwrlib_append-new-line in this-procedure ( input "&global-define {&Btn_Save} {&{&Btn_Save}}" ).
&GLOB {&Btn_Close}    CTRL-F7
run filwrlib_append-new-line in this-procedure ( input "&global-define {&Btn_Close} {&{&Btn_Close}}" ).
&GLOB {&Btn_Calc}     ALT-F7
run filwrlib_append-new-line in this-procedure ( input "&global-define {&Btn_Calc} {&{&Btn_Calc}}" ).
&GLOB {&Btn_Delete}   F8
run filwrlib_append-new-line in this-procedure ( input "&global-define {&Btn_Delete} {&{&Btn_Delete}}" ).
&GLOB {&Btn_Open}     CTRL-F8
run filwrlib_append-new-line in this-procedure ( input "&global-define {&Btn_Open} {&{&Btn_Open}}" ).
&GLOB {&Btn_History}  ALT-F8
run filwrlib_append-new-line in this-procedure ( input "&global-define {&Btn_History} {&{&Btn_History}}" ).
&GLOB {&Btn_Unrv}     CTRL-F9
run filwrlib_append-new-line in this-procedure ( input "&global-define {&Btn_Unrv} {&{&Btn_Unrv}}" ).
&GLOB {&Btn_Add}      CTRL-N, CTRL-Т
run filwrlib_append-new-line in this-procedure ( input "&global-define {&Btn_Add} {&{&Btn_Add}}" ).
&GLOB {&Btn_Print}    CTRL-P, CTRL-З
run filwrlib_append-new-line in this-procedure ( input "&global-define {&Btn_Print} {&{&Btn_Print}}" ).



{ cmp/cr-prep.i 1 confuse  "МЕШАЮТ"   " " "CONFUSE" }

{ cmp/cr-prep.i 1 auto-an-supVAT    "ПОСТАВЩИК+НДС"        " " "SUPPLIER+VAT"        }
{ cmp/cr-prep.i 1 auto-an-objcli    "ОБЪЕКТ+КЛИЕНТ"        " " "OBJECT+CLIENT"       }
{ cmp/cr-prep.i 1 auto-an-objsup    "ОБЪЕКТ+ПОСТАВЩИК"     " " "OBJECT+SUPPLIER"     }
{ cmp/cr-prep.i 1 auto-an-objcliVAT "ОБЪЕКТ+КЛИЕНТ+НДС"    " " "OBJECT+CLIENT+VAT"   }
{ cmp/cr-prep.i 1 auto-an-objsupVAT "ОБЪЕКТ+ПОСТАВЩИК+НДС" " " "OBJECT+SUPPLIER+VAT" }



&GLOB fin-calc-firm 0
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-calc-firm {&fin-calc-firm}" ).
&GLOB fin-calc-obj 1
run filwrlib_append-new-line in this-procedure ( input "&global-define fin-calc-obj {&fin-calc-obj}" ).


/************************************** имена атрибутов ub.clients-attr ****************************************************/

/* Дата с которой существуют документы */
{ cmp/cr-prep.i 1 attr-doc-start-date           doc-start                 " " doc-start }

/* Дата начала подробного складского архива по товарам */
{ cmp/cr-prep.i 1 attr-arh-detail-date          arh-detail                " " arh-detail }

/* Дата начала сжатого складского архива по товарам */
{ cmp/cr-prep.i 1 attr-arh-start-date           arh-start                 " " arh-start }

/* Дата начала подробного складского архива по поставщикам */
{ cmp/cr-prep.i 1 attr-ahsp-detail-date         ahsp-detail               " " ahsp-detail }

/* Дата начала сжатого складского архива по поставщикам */
{ cmp/cr-prep.i 1 attr-ahsp-start-date          ahsp-start                " " ahsp-start }

/* Дата начала подробного складского архива по типам приобретения */
{ cmp/cr-prep.i 1 attr-aht-detail-date          aht-detail                " " aht-detail }

/* Дата начала сжатого складского архива по типам приобретения */
{ cmp/cr-prep.i 1 attr-aht-start-date           aht-start                 " " aht-start }

/* Удаление складского архива по товарам прошло с ошибкой */
{ cmp/cr-prep.i 1 attr-arh-del                  arh-del                   " " arh-del }

/* Удаление складского архива по поставщикам прошло с ошибкой */
{ cmp/cr-prep.i 1 attr-ahsp-del                 ahsp-del                  " " ahsp-del }

/* Удаление складского архива по типам приобретения прошло с ошибкой */
{ cmp/cr-prep.i 1 attr-aht-del                  aht-del                   " " aht-del }

/* Расчет складского архива по товарам запрещен */
{ cmp/cr-prep.i 1 attr-arh-disable              arh-disable               " " arh-disable }

/* Расчет складского архива по поставщикам запрещен */
{ cmp/cr-prep.i 1 attr-ahsp-disable             ahsp-disable              " " ahsp-disable }

/* Расчет складского архива по типам приобретения запрещен */
{ cmp/cr-prep.i 1 attr-aht-disable              aht-disable               " " aht-disable }

/* Первоначальный расчет складского архива по товарам */
{ cmp/cr-prep.i 1 attr-arh-calc                 arh-calc                  " " arh-calc }

/* Первоначальный расчет складского архива по поставщикам */
{ cmp/cr-prep.i 1 attr-ahsp-calc                ahsp-calc                 " " ahsp-calc }

/* Первоначальный расчет складского архива по типам приобретени  */
{ cmp/cr-prep.i 1 attr-aht-calc                 aht-calc                  " " aht-calc }

/* Первоначальный расчет складского архива по типам приобретени  */
{ cmp/cr-prep.i 1 attr-arh-rest                 arh-rest                  " " arh-rest }

/* Первоначальный расчет складского архива по типам приобретени  */
{ cmp/cr-prep.i 1 attr-ahsp-rest                ahsp-rest                 " " ahsp-rest }

/* Первоначальный расчет складского архива по типам приобретени  */
{ cmp/cr-prep.i 1 attr-aht-rest                 aht-rest                  " " aht-rest }

/* Дата перерасчёта складского архива по товарам */
{ cmp/cr-prep.i 1 attr-arh-recalc-date          arh-recalc                " " arh-recalc }

/* Дата перерасчёта складского архива по поставщикам */
{ cmp/cr-prep.i 1 attr-ahsp-recalc-date         ahsp-recalc               " " ahsp-recalc }

/* Дата перерасчёта складского архива по типам приобретения */
{ cmp/cr-prep.i 1 attr-aht-recalc-date          aht-recalc                " " aht-recalc }

/* организация инкассатор  */
{ cmp/cr-prep.i 1 attr-is-inkassator            is-inkassator             " " is-inkassator }

/* Вывод РАСХОДОВ отдельной строкой в листе 2 сменного отчета */
{ cmp/cr-prep.i 1 attr-shftrep2                 shftrep2                  " " shftrep2 }

/* супервизор  */
{ cmp/cr-prep.i 1 attr-is-superviser            is-superviser             " " is-superviser }

/* С клиентом работают в текущей БД */
{ cmp/cr-prep.i 1 attr-db                       db                        " " db }

/*Временной интервал возможности доставки (bge-ais)*/
{ cmp/cr-prep.i 1 attr-delivery                 delivery                  " " delivery }

/*Свидетельство о постановке на учет по НДС КАЗАХСТАН*/
{ cmp/cr-prep.i 1 attr-vat-register             vat-register              " " vat-register }

/*Временной интервал, запрещенный к доставке (bge-ais)*/
{ cmp/cr-prep.i 1 attr-notdelivery              notdelivery               " " notdelivery }

/* Тип приобретения по умолчанию в приходной накладной  */
{ cmp/cr-prep.i 1 attr-purch-code               purch-code                " " purch-code }

/* Торговля чужим товаром */
{ cmp/cr-prep.i 1 attr-als-gds                  als-gds                   " " als-gds }

/* Неправильные архивы arh-trn-doc-contract по объекту */
{ cmp/cr-prep.i 1 attr-arh-trn-doc-contract       arh-trn-doc-contract                   " " arh-trn-doc-contract }

/* ЧУЖАЯ фирма - фирма для которой учет ведется в ДРУГОЙ СИСТЕМЕ TH - и которая обменивается информацией с нами через импорт экспорт */
{ cmp/cr-prep.i 1 attr-alien                  alien                   " " alien }

/*ЕНВД*/
{ cmp/cr-prep.i 1 attr-envd                   envd                     " " envd }

/*КПП*/
{ cmp/cr-prep.i 1 attr-kpp                    kpp                      " " kpp  }

/* дата время обновления актуальности информации - при импорте с другой системы */
{ cmp/cr-prep.i 1 attr-cli-upd-date-time      upd-date-time            " " upd-date-time }

/* код фирмы для печати накладных - если для объекта задан параметр outhold */
{ cmp/cr-prep.i 1 attr-holdfirm-code          holdfirm-code            " " holdfirm-code }

/* Расписание (интервал повторения) для алармов на воду и уровень АТД */
{ cmp/cr-prep.i 1 attr-atd-alarm-schedule  atd-alarm-schedule " " atd-alarm-schedule  }

/* Система налогообложения */


/* Дата последней выгруженной смены для объекта */
{ cmp/cr-prep.i 1 attr-bge-incr-last-shift-date bge-incr-last-shift-date " " bge-incr-last-shift-date }
/* Номер последней выгруженной смены для объекта */
{ cmp/cr-prep.i 1 attr-bge-incr-last-shift-num bge-incr-last-shift-num " " bge-incr-last-shift-num }
/* Выгружается ли смена в данный момент */
{ cmp/cr-prep.i 1 attr-bge-incr-cur bge-incr-cur " " bge-incr-cur }
/* Дата и номер последней выгруженной смены в SAP ECC 6.0 ОАО "Сургутнефтегаз" */
{ cmp/cr-prep.i 1 attr-bge-sap-sng-last-shift bge-sap-sng-last-shift " " bge-sap-sng-last-shift }
/* Дата и номер последней выгруженной смены в Малину */
{ cmp/cr-prep.i 1 attr-bge-exp-malina-last-shift bge-exp-malina-last-shift " " bge-exp-malina-last-shift }
/* Дата последней выгруженной смены в систему АТД */
{ cmp/cr-prep.i 1 attr-bge-exp-last-atd bge-exp-last-atd " " bge-exp-last-atd }
/* Дата ЕГРИП */
{ cmp/cr-prep.i 1 attr-egrip-date egrip-date " " egrip-date }
/* Номер ЕГРИП */
{ cmp/cr-prep.i 1 attr-egrip-num egrip-num " " egrip-num }


/* держатель основного счета */
{ cmp/cr-prep.i 1 attr-main-accholder main-accholder " " main-acc-holder }

/*Аптека*/
{ cmp/cr-prep.i 1 attr-pharm  pharm   " " pharm }


/* права для работы с радиотерминалом */
{ cmp/cr-prep.i 1 rt-check-price рт-котроль-цены   " " rt-check-price }
{ cmp/cr-prep.i 1 rt-edit-doc    рт-приемка-товара " " rt-edit-doc    }

/* EDI для прав */
{ cmp/cr-prep.i 1 rh-attr-edi          edi_работа_по_EDI " " edi }
{ cmp/cr-prep.i 1 rh-attr-GLN          edi_код_GLN       " " GLN }

/* Код оплаты для производства */
{ cmp/cr-prep.i 1 attr-fbr-pay-code fbr-pay-code " " fbr-pay-code  }

/* Грузоотправитель */
{ cmp/cr-prep.i 1 attr-cargo-from cargo-from " " cargo-from  }

/* Грузополучатель */
{ cmp/cr-prep.i 1 attr-cargo-to cargo-to " " cargo-to  }

/* Атрибут клиента - местный */
{ cmp/cr-prep.i 1 attr-cli-local cli-local " " cli-local  }

/* Атрибут клиента - производитель алкогольной продукции */
{ cmp/cr-prep.i 1 attr-cli-alc-producer cli-alc-producer " " cli-alc-producer  }

/* код региона */
{ cmp/cr-prep.i 1 attr-region-code region-code " " region-code  }

/* импортный производитель */
{ cmp/cr-prep.i 1 attr-foreign-producer foreign-producer " " foreign-producer  }

/* Обязателен авторасчет заказов ОП.Запрет на корректировку автоматич. рассчитанных заказов */
{ cmp/cr-prep.i 1 attr-not-corr-op not-corr-op " " not-corr-op }

/* Запрет на ручной ввод документов */
{ cmp/cr-prep.i 1 attr-veto-man-doc veto-man-doc " " veto-man-doc }

/* Реквизиты для алкогольной декларации */
{ cmp/cr-prep.i 1 attr-requisite-alc-decl requisite-alc-decl " " requisite-alc-decl }

/* Код подразделения */
{ cmp/cr-prep.i 1 attr-division-code division-code " " division-code }

/* Атрибут клиента - Поставщик НП   */
{ cmp/cr-prep.i 1 attr-supp-np supp-np " " supp-np }

/* Атрибут клиента - Собственный поставщик   */
{ cmp/cr-prep.i 1 attr-own-supp own-supp " " own-supp }

/* Атрибут клиента - является нефтебазой для:*/
{ cmp/cr-prep.i 1 attr-tank-farm-for tank-farm-for " " tank-farm-for }

/* Атрибут клиента - Нефтеперерабатывающий завод (НПЗ)   */
{ cmp/cr-prep.i 1 attr-NPZ NPZ " " NPZ }

/* Атрибут клиента - являестся перевозчиком для:*/
{ cmp/cr-prep.i 1 attr-auto-tank-for auto-tank-for " " auto-tank-for }

/* Атрибут клиента - Список юр.лиц, платежами которых можно закрывать ФО:*/
{ cmp/cr-prep.i 1 attr-cli-for-close-fo cli-for-close-fo " " cli-for-close-fo }

/* Атрибут клиента - Климатическая группа:*/
{ cmp/cr-prep.i 1 attr-cli-clim-grp cli-clim-grp " " cli-clim-grp }

/* Атрибут клиента - Выведен из эксплуатации:*/
{ cmp/cr-prep.i 1 attr-cli-decommissioned cli-decommissioned " " cli-decommissioned }

/* Атрибут клиента - Поставщик СУГ   */
{ cmp/cr-prep.i 1 attr-supp-lgas supp-lgas " " supp-lgas }

/* Атрибут клиента - «Последняя выгруженная для ИС ПМ дата»   */
{ cmp/cr-prep.i 1 attr-exp-isPM-last-date exp-isPM-last-date " " exp-isPM-last-date }

/* Атрибут клиента - Код КСК  */
{ cmp/cr-prep.i 1 attr-code-KSK code-KSK " " code-KSK }

/* Атрибут клиента - Код АИС   */
{ cmp/cr-prep.i 1 attr-code-AIS code-AIS " " code-AIS }

/* Атрибут клиента - Является поставщиком для   */
{ cmp/cr-prep.i 1 attr-owner-code owner-code " " owner-code }

/* сюда добавлять новые названия атрибутов клиентов */

/* список атрибутов клиентов */
&glob clntattr-list '{&bef-attr-doc-start-date}~
,{&bef-attr-arh-detail-date}~
,{&bef-attr-arh-start-date}~
,{&bef-attr-ahsp-detail-date}~
,{&bef-attr-ahsp-start-date}~
,{&bef-attr-aht-detail-date}~
,{&bef-attr-aht-start-date}~
,{&bef-attr-arh-del}~
,{&bef-attr-ahsp-del}~
,{&bef-attr-aht-del}~
,{&bef-attr-arh-calc}~
,{&bef-attr-ahsp-calc}~
,{&bef-attr-aht-calc}~
,{&bef-attr-arh-recalc-date}~
,{&bef-attr-ahsp-recalc-date}~
,{&bef-attr-aht-recalc-date}~
,{&bef-attr-is-inkassator}~
,{&bef-attr-shftrep2}~
,{&bef-attr-db}~
,{&bef-attr-is-superviser}~
,{&bef-attr-purch-code}~
,{&bef-attr-als-gds}~
,{&bef-attr-alien}~
,{&bef-attr-envd}~
,{&bef-attr-kpp}~
,{&bef-attr-pharm}~
,{&bef-attr-cli-upd-date-time}~
,{&bef-attr-holdfirm-code}~
,{&bef-attr-vat-register}~
,{&bef-attr-bge-incr-last-shift-date}~
,{&bef-attr-bge-incr-last-shift-num}~
,{&bef-attr-bge-sap-sng-last-shift}~
,{&bef-attr-egrip-date}~
,{&bef-attr-egrip-num}~
,{&bef-attr-cli-local}~
,{&bef-attr-cli-alc-producer}~
,{&bef-attr-region-code}~
,{&bef-attr-foreign-producer}~
,{&bef-attr-main-accholder}~
,{&bef-attr-not-corr-op}~
,{&bef-attr-veto-man-doc}~
,{&bef-attr-requisite-alc-decl}~
,{&bef-attr-division-code}~
,{&bef-attr-supp-np}~
,{&bef-attr-own-supp}~
,{&bef-attr-supp-lgas}~
,{&bef-attr-tank-farm-for}~
,{&bef-attr-NPZ}~
,{&bef-attr-auto-tank-for}~
,{&bef-attr-code-KSK}~
,{&bef-attr-code-AIS}~
,{&bef-attr-owner-code}~
,{&bef-attr-cli-for-close-fo}~
,{&bef-attr-cli-clim-grp}~
,{&bef-attr-cli-decommissioned}~
,{&bef-attr-exp-isPM-last-date}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define clntattr-list {&clntattr-list}" ).

/* список атрибутов для фильтра по держателям дисконтных карт в механизме списке дисконтных карт */
&glob clntattr-list-to-dc-list '{&bef-attr-db}~
,{&bef-attr-is-superviser}~
':u
run filwrlib_append-new-line in this-procedure ( input "&global-define clntattr-list-to-dc-list {&clntattr-list-to-dc-list}" ).


/* имена атрибутов товаров */

/* Атрибут для блокирования остальных атрибутов в интерфейсе */
{ cmp/cr-prep.i 1 attr-gds-attr-lock    lock                  " " lock                 }

/* Алкогольная продукция */
{ cmp/cr-prep.i 1 attr-alcohol-prod       alcohol-prod       " " alcohol-prod       }

/* Наименование товара в ЕГАИС */
{ cmp/cr-prep.i 1 attr-egais-name         egais-name         " " egais-name         }

/* Природный газ-топливо */
{ cmp/cr-prep.i 1 attr-is-gas             is-gas             " " is-gas             }

/* Топливо - сверка не требуется */
{ cmp/cr-prep.i 1 attr-ptrl-without-rvs   ptrl-without-rvs   " " ptrl-without-rvs   }

/* Тип услуги */
{ cmp/cr-prep.i 1 attr-office-type     office-type     " " office-type     }

/* Тип маркировки */
{ cmp/cr-prep.i 1 attr-mark-type       mark-type     " " mark-type     }

/* Тип ЕМРЦ */
{ cmp/cr-prep.i 1 attr-emrc-type       emrc-type     " " emrc-type     }

/* Признак продажи is18+ */
{ cmp/cr-prep.i 1 attr-IS18Plus           IS18Plus         " " IS18Plus    }

/* Оплата баллами Семейная команда */
{ cmp/cr-prep.i 1 attr-loyalty-gift           loyalty-gift         " " loyalty-gift    }

/* Признак предмета расчета */
{ cmp/cr-prep.i 1 attr-item-matter-mark     item-matter-mark     " " item-matter-mark     }

/* Признак способа расчета */
{ cmp/cr-prep.i 1 attr-type-method-calc     type-method-calc     " " type-method-calc     }

/* cash-book-id */
{ cmp/cr-prep.i 1 attr-cash-book-id     cash-book-id     " " cash-book-id     }

/* oper-serv-id */
{ cmp/cr-prep.i 1 attr-oper-serv-id     oper-serv-idd     " " oper-serv-id     }

/* Правило заполнения графы "Основание" */
{ cmp/cr-prep.i 1 attr-cash-book-rul-basis     cash-book-rul-basis     " " cash-book-rul-basis }

/* Правило заполнения графы "Приложение" */
{ cmp/cr-prep.i 1 attr-cash-book-rul-att       cash-book-rul-att       " " cash-book-rul-att }

/* Отдельный платеж для каждой кассы */
{ cmp/cr-prep.i 1 attr-cash-book-separated       cash-book-separated     " " cash-book-separated }

/* Раздельно НП и ТНП */
{ cmp/cr-prep.i 1 attr-cash-book-partite       cash-book-partite     " " cash-book-partite }

/* маска номера ПКО */
{ cmp/cr-prep.i 1 attr-cash-book-mask-pko       cash-book-mask-pko     " " cash-book-mask-pko }

/* маска номера РКО */
{ cmp/cr-prep.i 1 attr-cash-book-mask-rko       cash-book-mask-rko     " " cash-book-mask-rko }

/* Группа НП */
{ cmp/cr-prep.i 1 attr-group-np         group-np     " " group-np     }

/* Тип топлива */
{ cmp/cr-prep.i 1 attr-fuel-type     fuel-type     " " fuel-type     }

/* Перечисление в систему лояльности */
{ cmp/cr-prep.i 1 attr-is-loyalty-payment is-loyalty-payment " " is-loyalty-payment }

/* Запрет на участие в бонусных программах\участие в скидке на итог */
{ cmp/cr-prep.i 1 attr-ban-bonus ban-bonus " " ban-bonus }

/* Разрешена нулевая цена */
{ cmp/cr-prep.i 1 attr-null-price null-price " " null-price }

/* товар фасуется */
{ cmp/cr-prep.i 1 attr-fasovka            fasovka            " " fasovka       }

/* код номенклатурной классификации */
{ cmp/cr-prep.i 1 attr-gds-CommodityCode  gds-CommodityCode " " gds-CommodityCode }

/* Время приготовления в чеке */
{ cmp/cr-prep.i 1 attr-time-coock            time-coock            " " time-coock       }

/* требуется обязательная маркировка  */
{ cmp/cr-prep.i 1 attr-mark            mark            " " mark       }

/* Группа товаров на кассе */
{ cmp/cr-prep.i 1 attr-sum-grp-gl              sum-grp-gl               " " sum-grp-gl              }

/* Минимальный запас */
{ cmp/cr-prep.i 1 attr-min-zapas              min-zapas               " " min-zapas              }

/* Является подконтрольным ФГИС "Меркурий" */
{ cmp/cr-prep.i 1 attr-mercur_FGIS              mercur_FGIS               " " mercur_FGIS              }

/* Является скоропортящейся продукцией */
{ cmp/cr-prep.i 1 attr-perishable              perishable               " " perishable              }

/* Только производство */
{ cmp/cr-prep.i 1 attr-production-only         production-only          " " production-only         }

/* состав сырья 15x80 */
{ cmp/cr-prep.i 1 attr-15x80              15x80         " " 15x80       }

/* состав сырья 8x50 */
{ cmp/cr-prep.i 1 attr-8x50               8x50         " " 8x50       }

/* состав сырья 6x50 */
{ cmp/cr-prep.i 1 attr-6x50               6x50         " " 6x50       }

/*энергетиечская ценность*/
{ cmp/cr-prep.i 1 attr-calories           calories     " " calories       }

/*Белки*/
{ cmp/cr-prep.i 1 attr-protein            protein      " " protein        }

/*Жир*/
{ cmp/cr-prep.i 1 attr-fat                fat          " " fat            }

/*Углеводы*/
{ cmp/cr-prep.i 1 attr-carbohydrate       carbohydrate " " carbohydrate   }

/*расчет энергетической ценности из рецепта*/
{ cmp/cr-prep.i 1 attr-calc-cal-rec       calc-cal-rec  " " calc-cal-rec   }

/*торгуется по партиям*/
{ cmp/cr-prep.i 1 attr-cash-parts         cash-parts    " " cash-parts   }

/* ТНП продается через ТРК */
{ cmp/cr-prep.i 1 attr-ptrl-as-good        ptrl-as-good  " " ptrl-as-good    }

/* insalepr по умолчанию */
{ cmp/cr-prep.i 1 attr-dflt-insalepr       dflt-insalepr  " " dflt-insalepr    }

/* диапазон плотности топлива */
{ cmp/cr-prep.i 1 attr-gds-ptrl-densities  gds-ptrl-densities " " gds-ptrl-densities }

/*длинна (мм)*/
{ cmp/cr-prep.i 1 attr-length-of  length-of " " length-of }

/*ширина (мм)*/
{ cmp/cr-prep.i 1 attr-width-of  width-of " " width-of }

/*высота (мм)*/
{ cmp/cr-prep.i 1 attr-height-of  height-of " " height-of }

/*количество в коробке*/
{ cmp/cr-prep.i 1 attr-qnty-in-box  qnty-in-box " " qnty-in-box }

/*вес коробки (товар + коробка)*/
{ cmp/cr-prep.i 1 attr-weight-box  weight-box " " weight-box }

/*количество на палете*/
{ cmp/cr-prep.i 1 attr-qnty-on-pallet  qnty-on-pallet " " qnty-on-pallet }

/*вес палеты (товар + палета)*/
{ cmp/cr-prep.i 1 attr-weight-of-pallet  weight-of-pallet " " weight-of-pallet }

/* Изображения */
{ cmp/cr-prep.i 1 attr-image-list       image-list       " " image-list       }

/* Доп. ед. изм. */
{ cmp/cr-prep.i 1 attr-MercUnits       MercUnits       " " MercUnits       }

/* коды АИС*/
{ cmp/cr-prep.i 1 attr-gds-code-AIS  gds-code-AIS " " gds-code-AIS }

/* Признак весового товара */
{ cmp/cr-prep.i 1 attr-weighed-gds  weighed-gds " " weighed-gds }

/* сюда добавлять новые названия атрибутов товаров */

/* список атрибутов товаров */
&glob gds-attr-list '{&bef-attr-alcohol-prod}~
,{&bef-attr-egais-name}~
,{&bef-attr-is-gas}~
,{&bef-attr-ptrl-without-rvs}~
,{&bef-attr-office-type}~
,{&bef-attr-mark-type}~
,{&bef-attr-emrc-type}~
,{&bef-attr-IS18Plus}~
,{&bef-attr-loyalty-gift}~
,{&bef-attr-item-matter-mark}~
,{&bef-attr-type-method-calc}~
,{&bef-attr-group-np}~
,{&bef-attr-fuel-type}~
,{&bef-attr-is-loyalty-payment}~
,{&bef-attr-ban-bonus}~
,{&bef-attr-null-price}~
,{&bef-attr-fasovka}~
,{&bef-attr-time-coock}~
,{&bef-attr-mark}~
,{&bef-attr-sum-grp-gl}~
,{&bef-attr-min-zapas}~
,{&bef-attr-mercur_FGIS}~
,{&bef-attr-perishable}~
,{&bef-attr-production-only}~
,{&bef-attr-15x80}~
,{&bef-attr-8x50}~
,{&bef-attr-6x50}~
,{&bef-attr-calories}~
,{&bef-attr-protein}~
,{&bef-attr-fat}~
,{&bef-attr-carbohydrate}~
,{&bef-attr-calc-cal-rec}~
,{&bef-attr-cash-parts}~
,{&bef-attr-ptrl-as-good}~
,{&bef-attr-dflt-insalepr}~
,{&bef-attr-gds-ptrl-densities}~
,{&bef-attr-gds-CommodityCode}~
,{&bef-attr-gds-code-AIS}~
,{&bef-attr-length-of}~
,{&bef-attr-width-of}~
,{&bef-attr-height-of}~
,{&bef-attr-qnty-in-box}~
,{&bef-attr-weight-box}~
,{&bef-attr-qnty-on-pallet}~
,{&bef-attr-weight-of-pallet}~
,{&bef-attr-image-list}~
,{&bef-attr-MercUnits}~
,{&bef-attr-weighed-gds}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define gds-attr-list {&gds-attr-list}" ).

/* типы услуг */
{ cmp/cr-prepc.i 1 prop-list-attr-office-type
"oss-pay,tso-ret,card-act"
attr-office-type
}

/*"Реализуемый товар кроме подакцизного;
Реализуемый подакцизный товар;
Выполняемая работа;
Оказываемая услуга;
Прием ставок при проведени азартных игр;
Выплата денежных средств при проведени азартных игр;
Прием денежных средств при реализации лотерейных билетов;
Выплата выигрыша при проведении лотерей;
Предоставление прав на использование результатов интеллектуальной деятельности;
Аванс, задаток, предоплата, кредит...;
Вознаграждение пользователя, являющегося платежным агентом"*/
/* Признак предмета расчета */

{ cmp/cr-prepc.i 1 prop-list-attr-item-matter-mark 
"1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19"
attr-item-matter-mark
}

{ cmp/cr-prepc.i 1 prop-list-attr-type-method-calc 
"1,2,3,4,5,6,7"
attr-type-method-calc
}

/* Группы НП */
{ cmp/cr-prepc.i 1 prop-list-attr-group-np
"I,II,III,IV"
attr-group-np
}

/* типы топлива */
{ cmp/cr-prepc.i 1 prop-list-attr-fuel-type
"petrol,diesel-sum,diesel-wint,metan,propan,lgas,diesel,arctic,megsesson"
attr-fuel-type
}

/* tara-code для сканер-весов NCR*/
{ cmp/cr-prep.i 1 attr-taracode-bc             taracode-bc          " " taracode-bc       }

/* сюда добавлять новые названия атрибутов бар-кодов */

/* список атрибутов бар-кодов */
&glob bc-attr-list '{&bef-attr-taracode-bc}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define bc-attr-list {&bc-attr-list}" ).


/* имена атрибутов касс */
/* Оперативные MAGIA-XML*/

{ cmp/cr-prep.i 1 cda-MAGIA-XML_operative                 MAGIA-XML_operative                  " " MAGIA-XML_operative }

/* Дата-время последнего принятого чека */
{ cmp/cr-prepc.i 1 prop-list-cda-MAGIA-XML_operative
"last-check-date-time"
cda-MAGIA-XML_operative
}

/* Оперативные IBM-XML*/
{ cmp/cr-prep.i 1 cda-IBM-XML_operative                 IBM-XML_operative                  " " IBM-XML_operative }

/* Параметры последнего принятого чека */
{ cmp/cr-prepc.i 1 prop-list-cda-IBM-XML_operative
"last-check-params,last-report-params,fo-version,OptVer,device-kind,USE_FFD_VERSION,KKT_FFD_VERSION,KKT_SCHEMA,last-time-polls,last-date-polls,GISMT_FAST_ANSWER,GISMT_TIMEOUT,GISMT_CHECK_TIMEOUT,GISMT_OPENCON_TIMEOUT"
cda-IBM-XML_operative
}

/* Общие настройки IBM-XML*/

{ cmp/cr-prep.i 1 cda-IBM-XML_general                 IBM-XML_general                  " " IBM-XML_general }
/* ИСПОЛЬЗОВАНИЕ КБО */
/* Работа с EasyFuel */
{ cmp/cr-prepc.i 1 prop-list-cda-IBM-XML_general
"use-kbo,easyfuel"
cda-IBM-XML_general
}


/* Оперативные AUTOTANK*/
{ cmp/cr-prep.i 1 cda-AUTOTANK_operative                 AUTOTANK_operative                  " " AUTOTANK_operative }

/* Параметры последнего принятого чека */
{ cmp/cr-prepc.i 1 prop-list-cda-AUTOTANK_operative
"last-check-params,last-report-params,fo-version,OptVer,device-kind"
cda-AUTOTANK_operative
}

 
/* Оперативные MARIA*/

{ cmp/cr-prep.i 1 cda-MARIA_operative                 MARIA_operative                  " " MARIA_operative }

/* Параметры последнего принятого чека */
/* Актуальность данных кассы MARIA */
/* Текущее количество товаров на кассе */
/* Максимальный plu на кассе в данный момент */
/* Признак на кассе есть товары не отправленные на кассу */
/* Текущее количество нефтепродуктов на кассе */
/* Максимальное значение plu топлива, из содержащихся на кассе в данный момент */
/* Признак на кассе есть топлива не отправленные на кассу */
/* Текущее количество клиентов на кассе */
/* Максимальное значение clu из содержащихся на кассе в данный момент */
/* Признак на кассе есть клиентов не отправленные на кассу */
{ cmp/cr-prepc.i 1 prop-list-cda-MARIA_operative
"last-check-maria,data-actuality,tot-gds,max-plu,to-send,tot-petrol,max-petrol-plu,petrol-to-send,tot-cli,max-clu,cli-to-send"
cda-MARIA_operative
}

{ cmp/cr-prep.i 1 cda-MARIA_general                 MARIA_general                  " " MARIA_general }

/* Максимальное количество товаров на кассе */
/* Начало диапазона plu для топлив на кассе */
/* Размер диапазона plu для топлив на кассе */
/* Максимальное количество клиентов на кассе */
{ cmp/cr-prepc.i 1 prop-list-cda-MARIA_general
"max-gds,petrolium-start,petrolium-range,max-cli"
cda-MARIA_general
}

/* Периодические задания кассы MARIA */
{ cmp/cr-prep.i 1   cd-attr-periodic-tasks       periodic-tasks       " " periodic-tasks       }


/* Оперативные INFOKIOSK*/

{ cmp/cr-prep.i 1 cda-INFOKIOSK_operative                 INFOKIOSK_operative                  " " INFOKIOSK_operative }


/* Последнее изменение справочника групп товаров */
/* Последнее изменение справочника шкал */
{ cmp/cr-prepc.i 1 prop-list-cda-INFOKIOSK_operative
"last-grp-change,last-prt-change"
cda-INFOKIOSK_operative
}

/* Общие NCR-GM*/

{ cmp/cr-prep.i 1 cda-NCR-GM_general                 NCR-GM_general                  " " NCR-GM_general }

/* Сообщение на кассе при превышении порогового значения суммы чека */
/* Соответствие кодов тары весам тары для сканер-весов NCR */
{ cmp/cr-prepc.i 1 prop-list-cda-NCR-GM_general
"message-by-lim-sum-check,tara-ref"
cda-NCR-GM_general
}

/* Общие NCR-AS-R*/

{ cmp/cr-prep.i 1 cda-NCR-AS-R_general                 NCR-AS-R_general                  " " NCR-AS-R_general }

/* Сообщение на кассе при превышении порогового значения суммы чека */
/* Соответствие кодов тары весам тары для сканер-весов NCR */
{ cmp/cr-prepc.i 1 prop-list-cda-NCR-AS-R_general
"message-by-lim-sum-check,tara-ref"
cda-NCR-AS-R_general
}

/* Устройства IBS-TH*/

{ cmp/cr-prep.i 1 cda-IBS-TH_devices                   IBS-TH_devices                    " " IBS-TH_devices }

{ cmp/cr-prepc.i 1 prop-list-cda-IBS-TH_devices
"cash-drawer-plug,cash-drawer-plug-type,cash-drawer-plug-port,cash-drawer-plug-imp,cash-drawer-open,cash-drawer-limit,card-reader-plug,customer-display-plug,customer-display-adv,keyboard-type,keyboard-layout-id,cashless-system,customer-display-type,customer-display-port,cctv-system,cctv-system-address"
cda-IBS-TH_devices
}


/* Фиск рег-р IBS-TH*/

{ cmp/cr-prep.i 1 cda-IBS-TH_fisreg                    IBS-TH_fisreg                      " " IBS-TH_fisreg }

{ cmp/cr-prepc.i 1 prop-list-cda-IBS-TH_fisreg
"cash-drawer-level,cash-pay-list,pay-names,cutter,com-port"
cda-IBS-TH_fisreg
}


/* печать чеков IBS-TH*/

{ cmp/cr-prep.i 1 cda-IBS-TH_rec-print                 IBS-TH_rec-print                   " " IBS-TH_rec-print }

{ cmp/cr-prepc.i 1 prop-list-cda-IBS-TH_rec-print
"max-netto,advert-text,cliche-lines,print-good-code,rmethod-type,rmethod-coeff,rcpt-ord-slip-print,rcpt-ord-alt-print"
cda-IBS-TH_rec-print
}

/* ФФД версия */
{ cmp/cr-prep.i 1 cd-attr-ffd-version USE_FFD_VERSION " " USE_FFD_VERSION }

/* базовые IBS-TH*/
/* ККТ версия */
{ cmp/cr-prep.i 1 cd-attr-kkt-version KKT_FFD_VERSION " " KKT_FFD_VERSION }

{ cmp/cr-prep.i 1 cda-IBS-TH_main                      IBS-TH_main                        " " IBS-TH_main }

{ cmp/cr-prepc.i 1 prop-list-cda-IBS-TH_main
"cash-shift,nalc,salesman-mandatory,manual-discnt,log-level,clear-cash-counter,qnty-change"
cda-IBS-TH_main
}


/* Интерфейс IBS-TH*/

{ cmp/cr-prep.i 1 cda-IBS-TH_interface                 IBS-TH_interface                    " " IBS-TH_interface }

{ cmp/cr-prepc.i 1 prop-list-cda-IBS-TH_interface
"screen-type,screen-layout-id"
cda-IBS-TH_interface
}

 /* базовые IBS-TH-MOB*/

{ cmp/cr-prep.i 1 cda-IBS-TH-MOB_main                      IBS-TH-MOB_main                        " " IBS-TH-MOB_main }

{ cmp/cr-prepc.i 1 prop-list-cda-IBS-TH-MOB_main
"salesman-mandatory,pos-type-for-discnt"
cda-IBS-TH-MOB_main
}

/* печать чеков IBS-TH-MOB*/

{ cmp/cr-prep.i 1 cda-IBS-TH-MOB_rec-print                 IBS-TH-MOB_rec-print                   " " IBS-TH_rec-print }

{ cmp/cr-prepc.i 1 prop-list-cda-IBS-TH-MOB_rec-print
"rcpt-ord-slip-print,rcpt-ord-alt-print"
cda-IBS-TH-MOB_rec-print
}



/* сюда добавлять новые названия атрибутов касс */

&glob cd-attr-list '{&bef-cda-MAGIA-XML_operative}~
,{&bef-cda-IBM-XML_operative}~
,{&bef-cda-IBM-XML_general}~
,{&bef-cda-MARIA_operative}~
,{&bef-cda-MARIA_general}~
,{&bef-cda-INFOKIOSK_operative}~
,{&bef-cda-NCR-GM_general}~
,{&bef-cda-NCR-AS-R_general}~
,{&bef-cda-IBS-TH_devices}~
,{&bef-cda-IBS-TH_fisreg}~
,{&bef-cda-IBS-TH_rec-print}~
,{&bef-cda-IBS-TH_main}~
,{&bef-cda-IBS-TH_interface}~
,{&bef-cda-IBS-TH-MOB_main}~
,{&bef-cda-IBS-TH-MOB_rec-print}~
,{&bef-cda-AUTOTANK_operative}~
':u
run filwrlib_append-new-line in this-procedure ( input "&global-define cd-attr-list {&cd-attr-list}" ).

/* имена атрибутов товаров на объекте */

/* Атрибут для блокирования остальных атрибутов в интерфейсе */
{ cmp/cr-prep.i 1 attr-gds-obj-attr-lock-o    lock                  " " lock                 }

/* Весовой код на объекте */
{ cmp/cr-prep.i 1 attr-scales-code-o          scales-code           " " scales-code          }

/* Товар со свободной ценой на кассе */
{ cmp/cr-prep.i 1 attr-free-price-o           free-price            " " free-price           }

/* Группа товаров на кассе */
{ cmp/cr-prep.i 1 attr-sum-grp-o              sum-grp               " " sum-grp              }

/* Наценка на объекте */
{ cmp/cr-prep.i 1 attr-increase-pc-o          increase-pc           " " increase-pc          }

/* Метод округления цены при расчете переоценки */
{ cmp/cr-prep.i 1 attr-round-method-o         round-method          " " round-method         }

/* Товар оплачивается топливным кошельком смарт карты (IBM-POS) */
{ cmp/cr-prep.i 1 attr-petrol-purse-o         petrol-purse          " " petrol-purse         }

/* Минимальный запас */
{ cmp/cr-prep.i 1 attr-min-zapas-o            min-zapas             " " min-zapas            }

/* Товар требует авторизации на кассе (IBM-XML) */
{ cmp/cr-prep.i 1 attr-need-auth-o            need-auth             " " need-auth            }

/* Диапазоны торговой наценки при расчете переоценки */
{ cmp/cr-prep.i 1 attr-gds-margins-o          gds-margins           " " gds-margins          }

/* Принадлежность товара объекту в пределах одной ТПСИ */
{ cmp/cr-prep.i 1 attr-proprietor-o           proprietor            " " proprietor           }

/* Оценочная учетная цена ингредиента для калькуляционной карточки */
{ cmp/cr-prep.i 1 attr-fbr-cost-rubl          fbr-cost-rubl         " " fbr-cost-rubl        }

/* Запрещен внешний приход и заказ объект-поставщик по товару на объекте */
{ cmp/cr-prep.i 1 attr-no-income-goods        no-income-goods       " " no-income-goods      }

/* Код тары для сканер-весов NCR */
{ cmp/cr-prep.i 1 attr-taracode-o             taracode              " " taracode             }

/*энергетиечская ценность*/
{ cmp/cr-prep.i 1 attr-calories-o             calories-o            " " calories-o           }

/*Белки*/
{ cmp/cr-prep.i 1 attr-protein-o              protein-o             " " protein-o            }

/*Жир*/
{ cmp/cr-prep.i 1 attr-fat-o                  fat-o                 " " fat-o                }

/*Углеводы*/
{ cmp/cr-prep.i 1 attr-carbohydrate-o         carbohydrate-o        " " carbohydrate-o       }

/* Способ выбора количества этикеток при печати из документа */
{ cmp/cr-prep.i 1 attr-doc-tickets-o          doc-tickets           " " doc-tickets          }

/* нормы естественной убыли для топлива на объекте */
{ cmp/cr-prep.i 1 attr-normal-wastage-o       normal-wastage-o      " " normal-wastage-o     }

/* Дополнение к альтернативному названию */
{ cmp/cr-prep.i 1 attr-dop-alt-name-o       dop-alt-name-o      " " dop-alt-name-o     }

/* Сезон ДТ */
{ cmp/cr-prep.i 1 attr-dt-seasons       dt-seasons      " " dt-seasons     }

/* Дата/время изменения Сезон ДТ */
{ cmp/cr-prep.i 1 attr-change-dt-seasons       change-dt-seasons      " " change-dt-seasons     }

/* Тип сбора марок */
{ cmp/cr-prep.i 1 attr-mark-collect-type       mark-collect-type      " " mark-collect-type     }
/* сюда добавлять новые названия атрибутов товаров на объекте */


&glob gdsoattr-list '~
{&bef-attr-scales-code-o}~
,{&bef-attr-fbr-cost-rubl}~
,{&bef-attr-gds-margins-o}~
,{&bef-attr-free-price-o}~
,{&bef-attr-sum-grp-o}~
,{&bef-attr-increase-pc-o}~
,{&bef-attr-round-method-o}~
,{&bef-attr-petrol-purse-o}~
,{&bef-attr-min-zapas-o}~
,{&bef-attr-need-auth-o}~
,{&bef-attr-proprietor-o}~
,{&bef-attr-no-income-goods}~
,{&bef-attr-taracode-o}~
,{&bef-attr-calories-o}~
,{&bef-attr-protein-o}~
,{&bef-attr-fat-o}~
,{&bef-attr-carbohydrate-o}~
,{&bef-attr-doc-tickets-o}~
,{&bef-attr-normal-wastage-o}~
,{&bef-attr-dop-alt-name-o}~
,{&bef-attr-dt-seasons}~
,{&bef-attr-change-dt-seasons}~
,{&bef-attr-mark-collect-type}~
':u
run filwrlib_append-new-line in this-procedure ( input "&global-define gdsoattr-list {&gdsoattr-list}" ).


/*имена атрибутов товара на фирме*/

/*Не попадает под действие ЕНВД*/
{ cmp/cr-prep.i 1 attr-no-envd-h                   no-envd                " " no-envd           }

/*Настройки платежа ОСС
04/III-2019 не используется. Атрибуты финансовых документов перенесены в БПА
{ cmp/cr-prep.i 1 attr-oss-props-h                 oss-props              " " oss-props          }
*/

&glob gdshattr-list '{&bef-attr-no-envd-h}~
,{&bef-attr-oss-props-h}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define gdshattr-list {&gdshattr-list}" ).

/* имена атрибутов баз данных */

/* Наличие расписания отправки новостей для БД */
{ cmp/cr-prep.i 1 attr-schedule-nws           schedule-nws          " " schedule-nws         }

/* Наличие расписания расчета архивов для БД */
{ cmp/cr-prep.i 1 attr-schedule-arc           schedule-arc          " " schedule-arc         }

/* Наличие расписания экспорта для БД */
{ cmp/cr-prep.i 1 attr-schedule-exp           schedule-exp          " " schedule-exp         }

/* Наличие расписания OpenXML для БД */
{ cmp/cr-prep.i 1 attr-schedule-oxml          schedule-oxml         " " schedule-oxml        }

/* Необходимость формирования новых пакетов для БД */
{ cmp/cr-prep.i 1 attr-need-gen-new-pack      need-gen-new-pack     " " need-gen-new-pack    }

/* Необходимость формирования новых пакетов для БД */
{ cmp/cr-prep.i 1 attr-last-unload-db-key     last-unload-db-key    " " last-unload-db-key   }

/* Наличие расписания экспорта для БД */
{ cmp/cr-prep.i 1 attr-schedule-cdimp         schedule-cdimp        " " schedule-cdimp       }

/* Наличие расписания приема информации с кассы */
{ cmp/cr-prep.i 1 attr-schedule-getcd         schedule-getcd        " " schedule-getcd       }

/* Наличие расписания обработки документов продаж */
{ cmp/cr-prep.i 1 attr-schedule-sale          schedule-sale         " " schedule-sale        }

/* Наличие расписания запуска отчетов для БД */
{ cmp/cr-prep.i 1 attr-schedule-suz           schedule-suz          " " schedule-suz         }

/* Наличие расписания обмена с ФГИС Меркурий */
{ cmp/cr-prep.i 1 attr-schedule-merc          schedule-merc         " " schedule-merc        }

/* Наличие расписания мониторинга HDD */
{ cmp/cr-prep.i 1 attr-schedule-hdd           schedule-hdd          " " schedule-hdd         }

/* Наличие расписания обмена с ИС МОТП */
{ cmp/cr-prep.i 1 attr-schedule-motp          schedule-motp         " " schedule-motp        }

/* Наличие расписания обмена с ИС Диадок */
{ cmp/cr-prep.i 1 attr-schedule-diadoc        schedule-diadoc       " " schedule-diadoc      }

/* Наличие расписания выгрузки в ИС ПМ */
{ cmp/cr-prep.i 1 attr-schedule-isPM          schedule-isPM         " " schedule-isPM        }

/* Дата по которую усечены документы по БД в ГБД */
{ cmp/cr-prep.i 1 attr-cut-date               cut-date              " " cut-date             }

/* Дата по которую усечены финансовые документы по БД в ГБД */
{ cmp/cr-prep.i 1 attr-cut-fin-date           cut-fin-date          " " cut-fin-date         }

/* БД выгружена после усечения документов по ней в ГБД */
{ cmp/cr-prep.i 1 attr-unload-after-cut       unload-after-cut      " " unload-after-cut     }

 /* Список БД в которых усекаются документы */
{ cmp/cr-prep.i 1 attr-cut-db-list            cut-db-list           " " cut-db-list          }

/* Наличие расписания обработки экспорта импорта в КЛИЕНТ-БАНК */
{ cmp/cr-prep.i 1 attr-schedule-cbnk          schedule-cbnk         " " schedule-cbnk        }

/* Расчет складского архива по товарам запрещен */
{ cmp/cr-prep.i 1 attr-db-arh-disable         arh-disable           " " arh-disable          }

/* Расчет складского архива по поставщикам запрещен */
{ cmp/cr-prep.i 1 attr-db-ahsp-disable        ahsp-disable          " " ahsp-disable         }

/* Расчет складского архива по типам приобретения запрещен */
{ cmp/cr-prep.i 1 attr-db-aht-disable         aht-disable           " " aht-disable          }

/* Наличие расписания обработки произвольных задач */
{ cmp/cr-prep.i 1 attr-schedule-free          schedule-free         " " schedule-free        }

/* Номер последней выгрузки в Oracle Retail */
{ cmp/cr-prep.i 1 attr-ora-exp-seq            ora-exp-seq           " " ora-exp-seq          }

/* Номер MessageID для видеонаблюдения */
{ cmp/cr-prep.i 1 attr-mess-id-video          mess-id-video         " " mess-id-video        }

/* Номер точки интеграции для ERPRN */
{ cmp/cr-prep.i 1 attr-int-point              int-point             " " int-point            }

/* версия code.xml  */
{ cmp/cr-prep.i 1 attr-ver-code               ver-code              " " ver-code             }

/* версия методанных  */
{ cmp/cr-prep.i 1 attr-ver-met                ver-met               " " ver-met              }

/* подмена версии Бд  */
{ cmp/cr-prep.i 1 attr-ver-db                 ver-db                " " ver-db               }

/* Номер MessageID для видеонаблюдения */
{ cmp/cr-prep.i 1 attr-asiip          asiip         " " asiip        }

/* Номер MessageID для видеонаблюдения */
{ cmp/cr-prep.i 1 attr-asitype          asitype         " " asitype        }

/* Номер MessageID для видеонаблюдения */
{ cmp/cr-prep.i 1 attr-asiport          asiport         " " asiport        }

/* Код региона reg-code */
{ cmp/cr-prep.i 1 attr-reg-code         reg-code        " " reg-code        }

/* Время последней синхронизации обмена СПН */
{ cmp/cr-prep.i 1 attr-last-nws-sync         last-nws-sync        " " last-nws-sync        }

/* сюда добавлять новые названия атрибутов баз данных */

&glob db-attr-list '~
{&bef-attr-schedule-nws}~
,{&bef-attr-schedule-arc}~
,{&bef-attr-schedule-exp}~
,{&bef-attr-schedule-oxml}~
,{&bef-attr-need-gen-new-pack}~
,{&bef-attr-last-unload-db-key}~
,{&bef-attr-schedule-cdimp}~
,{&bef-attr-schedule-getcd}~
,{&bef-attr-schedule-sale}~
,{&bef-attr-schedule-suz}~
,{&bef-attr-cut-date}~
,{&bef-attr-cut-fin-date}~
,{&bef-attr-unload-after-cut}~
,{&bef-attr-cut-db-list}~
,{&bef-attr-schedule-cbnk}~
,{&bef-attr-db-arh-disable}~
,{&bef-attr-db-ahsp-disable}~
,{&bef-attr-db-aht-disable}~
,{&bef-attr-schedule-free}~
,{&bef-attr-ora-exp-seq}~
':u
run filwrlib_append-new-line in this-procedure ( input "&global-define db-attr-list {&db-attr-list}" ).



/* Необходимость формирования новых пакетов для ВС */
{ cmp/cr-prep.i 1 attr-need-gen-new-xpack      need-gen-new-xpack   " " need-gen-new-xpack    }
{ cmp/cr-prep.i 1 attr-esys-ftp-ip             FTP                  " " FTP      }
{ cmp/cr-prep.i 1 attr-esys-ftp-login          Login                " " Login    }
{ cmp/cr-prep.i 1 attr-esys-ftp-password       Password             " " Password }
{ cmp/cr-prep.i 1 attr-esys-ftp-path           Path                 " " Path     }
{ cmp/cr-prep.i 1 attr-esys-ftp-path-in        IN-dir               " " IN-dir   }
{ cmp/cr-prep.i 1 attr-esys-ftp-path-out       OUT-dir              " " OUt-dir  }
/* Кол-во дней хранения пакетов после получения подтверждения */
{ cmp/cr-prep.i 1 attr-esys-save-oxml-pck      save-oxml-pck        " " save-oxml-pck         }
{ cmp/cr-prep.i 1 attr-esys-no-sent-ftp        no-sent-ftp          " " no-sent-ftp     }
{ cmp/cr-prep.i 1 attr-esys-gln-net            gln-net              " " gln-net         }
{ cmp/cr-prep.i 1 attr-esys-gln-provider       gln-provider         " " gln-provider    }
{ cmp/cr-prep.i 1 attr-esys-AuthToken          AuthToken            " " AuthToken    }
{ cmp/cr-prep.i 1 attr-esys-AuthTokenDT        AuthTokenDT          " " AuthTokenDT  }
{ cmp/cr-prep.i 1 attr-esys-host-code          host-code            " " host-code    }
{ cmp/cr-prep.i 1 attr-esys-obj                obj                  " " obj          }
{ cmp/cr-prep.i 1 attr-esys-user-id            user-id              " " user-id      }
{ cmp/cr-prep.i 1 attr-esys-server-addr        server-addr          " " server-addr  }
{ cmp/cr-prep.i 1 attr-esys-proxy-addr         proxy-addr           " " proxy-addr   }
{ cmp/cr-prep.i 1 attr-esys-proxy-login        proxy-login          " " proxy-login  }
{ cmp/cr-prep.i 1 attr-esys-proxy-pswd         proxy-pswd           " " proxy-pswd   }
{ cmp/cr-prep.i 1 attr-esys-proxy-ssl          proxy-ssl            " " proxy-ssl    }
{ cmp/cr-prep.i 1 attr-esys-AuthToken-send     AuthToken-send       " " AuthToken-send }
{ cmp/cr-prep.i 1 attr-esys-mail-list          mail-list            " " mail-list    }
{ cmp/cr-prep.i 1 attr-esys-diadoc-user        diadoc-user          " " diadoc-user  }
{ cmp/cr-prep.i 1 attr-esys-diadoc-pwd         diadoc-pwd           " " diadoc-pwd   }
{ cmp/cr-prep.i 1 attr-esys-diadoc-key         diadoc-key           " " diadoc-key   }
{ cmp/cr-prep.i 1 attr-esys-diadoc-lastload    diadoc-lastload      " " diadoc-lastload    }
{ cmp/cr-prep.i 1 attr-esys-diadoc-ssl         diadoc-ssl           " " diadoc-ssl    }
/* Использование цифровой подписи при обмене с ВС */
{ cmp/cr-prep.i 1 attr-esys-cert-sign          cert-sign            " " cert-sign         }
{ cmp/cr-prep.i 1 attr-esys-cert-sign-subject  cert-sign-subject    " " cert-sign-subject }
{ cmp/cr-prep.i 1 attr-esys-cert-sign-issuer   cert-sign-issuer     " " cert-sign-issuer  }
{ cmp/cr-prep.i 1 attr-esys-cert-file-ext      cert-file-ext        " " cert-file-ext     }
{ cmp/cr-prep.i 1 attr-esys-cert-repository    cert-repository      " " cert-repository   }


/* исторический код */
{ cmp/cr-prep.i 1 attr-hist-code               hist-code              " " hist-code            }

/* Историческое наименование */
{ cmp/cr-prep.i 1 attr-hist-name              hist-name               " " hist-name            }

/* сюда добавлять новые названия атрибутов баз данных */

&glob ext-system-attr-list '~
{&bef-attr-need-gen-new-xpack}~
,{&bef-attr-esys-ftp-ip}~
,{&bef-attr-esys-ftp-login}~
,{&bef-attr-esys-ftp-password}~
,{&bef-attr-esys-ftp-path}~
,{&bef-attr-esys-ftp-path-in}~
,{&bef-attr-esys-ftp-path-out}~
,{&bef-attr-esys-save-oxml-pck}~
,{&bef-attr-esys-no-sent-ftp}~
,{&bef-attr-esys-gln-net}~
,{&bef-attr-esys-gln-provider}~
,{&bef-attr-esys-AuthToken}~
,{&bef-attr-esys-AuthTokenDT}~
,{&bef-attr-esys-host-code}~
,{&bef-attr-esys-user-id}~
,{&bef-attr-esys-server-addr}~
,{&bef-attr-esys-proxy-addr}~
,{&bef-attr-esys-proxy-login}~
,{&bef-attr-esys-proxy-pswd}~
,{&bef-attr-esys-proxy-ssl}~
,{&bef-attr-esys-AuthToken-send}~
,{&bef-attr-esys-mail-list}~
,{&bef-attr-esys-diadoc-user}~
,{&bef-attr-esys-diadoc-pwd}~
,{&bef-attr-esys-diadoc-key}~
,{&bef-attr-esys-diadoc-lastload}~
,{&bef-attr-esys-cert-sign}~
,{&bef-attr-esys-cert-sign-subject}~
,{&bef-attr-esys-cert-sign-issuer}~
,{&bef-attr-esys-cert-file-ext}~
':u
run filwrlib_append-new-line in this-procedure ( input "&global-define ext-system-attr-list {&ext-system-attr-list}" ).


/* Номер партии для документа межфирменного перемещения */
{ cmp/cr-prep.i 1 trdcattr-hold-part-code  hold-part-code  " "  hold-part-code}
/*Доверенность*/
{ cmp/cr-prep.i 1 trdcattr-dov dov " " dov }
/*Дата приходной накладной поставщика*/
{ cmp/cr-prep.i 1 trdcattr-dids dids " " dids }
/*Номер приходной накладной поставщика*/
{ cmp/cr-prep.i 1 trdcattr-nids nids " " nids }
/*Дата счета-фактуры поставщика*/
{ cmp/cr-prep.i 1 trdcattr-dsf dsf " " dsf }
/*Номер счета-фактуры поставщика*/
{ cmp/cr-prep.i 1 trdcattr-nsf nsf " " nsf }
/*Дата договора */
{ cmp/cr-prep.i 1 trdcattr-ddog ddog " " ddog }
/*Номер договора */
{ cmp/cr-prep.i 1 trdcattr-ndog ndog " " ndog }
/*Виды дополнительной информации по документу, содержащейся в таблицах trn-doc-sum, doc-line-sum*/
{ cmp/cr-prep.i 1 trdcattr-addsum addsum " " addsum }
/*On-line расчет дополнительных сумм основных и после документа*/
{ cmp/cr-prep.i 1 trdcattr-clcasol clcasol " " clcasol }
/*On-line расчет естественной убыли*/
{ cmp/cr-prep.i 1 trdcattr-clcaswt clcaswt " " clcaswt }
/*Загруженные в документ сканерные файлы*/
{ cmp/cr-prep.i 1 trdcattr-scanfile scanfile " " scanfile }
/*Заводить внешнюю приходную накладную через суммы*/
{ cmp/cr-prep.i 1 trdcattr-indoclnsum indoclnsum " " indoclnsum }
/*Ограничение по типам приобретения*/
{ cmp/cr-prep.i 1 trdcattr-purchlimit purchlimit " " purchlimit }
/*список кодов типов приобретения по документу */
{ cmp/cr-prep.i 1 trdcattr-purchcodelist purchcodelist " " purchcodelist }
/*расходы не включаемые в учетную цену*/
{ cmp/cr-prep.i 1 trdcattr-expense_own expense_own " " expense_own }
/*ЕНВД*/
{ cmp/cr-prep.i 1 trdcattr-envd envd " " envd }
/* Код оператора документа производства */
{ cmp/cr-prep.i 1 trdcattr-fbroperator fbroperator " " fbroperator }
/* Документ создан автоматически (автопроизводство, план-меню, ... ) */
{ cmp/cr-prep.i 1 trdcattr-fbrauto fbrauto " " fbrauto }
/* Список документов для предпочтительного резервирования */
{ cmp/cr-prep.i 1 trdcattr-rsrv-doc-list rsrv-doc-list " " rsrv-doc-list }
/*Цены объекта-приемника*/
{ cmp/cr-prep.i 1 trdcattr-price-target price-target " " price-target }

/* Флористы */
/*Дата выполнения запроса */
{ cmp/cr-prep.i 1 trdcattr-frsrv-date "0rsrv-date"      " "  "0rsrv-date"  }
/*Время выполнения заказа*/
{ cmp/cr-prep.i 1 trdcattr-ord_time   "1ord_time"      " "   "1ord_time"  }
/* контактное лицо */
{ cmp/cr-prep.i 1 trdcattr-ord_phone    "21ord_phone"     " "  "21ord_phone"  }
{ cmp/cr-prep.i 1 trdcattr-ord_contact  "22ord_contact"   " "  "22ord_contact"  }
/*Сумма предоплаты*/
{ cmp/cr-prep.i 1 trdcattr-befpay     "2befpay"        " "   "2befpay"    }
/*№ чека предоплаты*/
{ cmp/cr-prep.i 1 trdcattr-ord_Nchek  "3ord_Nchek"     " "   "3ord_Nchek" }
/*Дата чека предоплаты */
{ cmp/cr-prep.i 1 trdcattr-dchek      "4dchek"         " "   "4dchek"     }
/*Стоимость доставки*/
{ cmp/cr-prep.i 1 trdcattr-ord_dl     "4ord_dl"        " "   "4ord_dl"     }
{ cmp/cr-prep.i 1 trdcattr-deliv      "5deliv"         " "   "5deliv"     }
/*Наценка за работу*/
{ cmp/cr-prep.i 1 trdcattr-sumwrk     "6sumwrk"        " "   "6sumwrk"    }
/*Наценка за срочность*/
{ cmp/cr-prep.i 1 trdcattr-sumsrk     "7sumsrk"        " "   "7sumsrk"    }
/*Куда*/
{ cmp/cr-prep.i 1 trdcattr-ord_adr    "8ord_adr"       " "   "8ord_adr"   }
/*Кому*/
{ cmp/cr-prep.i 1 trdcattr-ord_hwo    "9ord_hwo"       " "   "9ord_hwo"   }
/*Сумма доплаты*/
{ cmp/cr-prep.i 1 trdcattr-postpay     "1postpay"      " "  "1postpay"    }
/*№ чека доплаты*/
{ cmp/cr-prep.i 1 trdcattr-postNchek   "2postNchek"      " "  "2postNchek"  }
/*Дата чека доплаты */
{ cmp/cr-prep.i 1 trdcattr-postdchek   "3postdchek"      " "  "3postdchek"  }
/* Метод включения транспортных и пр. расходов в ПН */
{ cmp/cr-prep.i 1 trdcattr-m-inc       "m_inc"      " "  "m_inc"  }
/* Количество мест в РН */
{ cmp/cr-prep.i 1 trdcattr-qntyplace   "QntyPlace"      " "  "QntyPlace"  }
/* Cумма снаценкой скидкой и доставкой */
{ cmp/cr-prep.i 1 trdcattr-discnt-stop  "discnt-stop"  " "  "discnt-stop" }
/* Пересчитывать скидку иначе */
{ cmp/cr-prep.i 1 trdcattr-discnt-other  "discnt-other"  " "  "discnt-other" }
/* Текстовое поле - место хранения по всей накладной */
{ cmp/cr-prep.i 1 trdcattr-place-storage "PlaceStorage"  " "  "PlaceStorage" }
/* Упаковщик */
{ cmp/cr-prep.i 1 trdcattr-packer        "Packer"         " "  "Packer" }
/* Способ отгрузки */
{ cmp/cr-prep.i 1 trdcattr-dispath       "Dispath"        " "  "Dispath" }
/*Дата расчетного документа*/
{ cmp/cr-prep.i 1 trdcattr-dfindoc DFinDoc " " DFinDoc }
/*Номер приходной накладной поставщика*/
{ cmp/cr-prep.i 1 trdcattr-nfindoc NFinDoc " " NFinDoc }
/* статус EDI */
{ cmp/cr-prep.i 1 trdcattr-edi       "edi"        " "  "edi" }
/* номер EGAIS */
{ cmp/cr-prep.i 1 trdcattr-negais       "negais"        " "  "negais" }
/* статус EGAIS */
{ cmp/cr-prep.i 1 trdcattr-egais       "egais"        " "  "egais" }
/*Дата доверенности */
{ cmp/cr-prep.i 1 trdcattr-ddov ddov " " ddov }
/*Номер доверенности */
{ cmp/cr-prep.i 1 trdcattr-ndov ndov " " ndov }
/* Получатель */
{ cmp/cr-prep.i 1 trdcattr-recipient  "Recipient"   " "   "Recipient" }
/* Отправитель */
{ cmp/cr-prep.i 1 trdcattr-shipper  "Shipper"   " "   "Shipper" }
/* Автомобиль */
{ cmp/cr-prep.i 1 trdcattr-auto   "Auto"      " "  "Auto"  }
/* Водитель */
{ cmp/cr-prep.i 1 trdcattr-driver   "Driver"      " "  "Driver"  }
/*Номер смены*/
{ cmp/cr-prep.i 1 trdcattr-shiftname shn " " shn }
/*Номер документа для печати*/
{ cmp/cr-prep.i 1 trdcattr-print-num "print-num" " " "print-num" }
/*Идентификатор государственного контракта*/
{ cmp/cr-prep.i 1 trdcattr-idCountryContr "idCountryContr" " " "idCountryContr" }
/*Документ пересортицы по тем же контрагентам и договорам*/
{ cmp/cr-prep.i 1 trdcattr-oldsuppcntr "olsuppcntr" " " "oldsuppcntr" }
/* Время прихода машины */
{ cmp/cr-prep.i 1 trdcattr-car-time "car-time" " " "car-time" }
/* Переоценка создана равной ценам ПН */
{ cmp/cr-prep.i 1 trdcattr-first-price "first-price" " " "first-price" }
/*Допустимый % погрешности поставщика*/
{ cmp/cr-prep.i 1 trdcattr-acc-ship acc-ship " " acc-ship }
/* Документы НЕ предоставлены */
{ cmp/cr-prep.i 1 trdcattr-doc-not "doc-not" " " "doc-not" }
/* Список не предоставленных документов */
{ cmp/cr-prep.i 1 trdcattr-spisok-not-doc "spisok-not-doc" " " "spisok-not-doc" }

/*Сдал/Принял*/
{ cmp/cr-prep.i 1 trdcattr-t_pass-fname      "t_pass-fname" " "      "t_pass-fname" }
{ cmp/cr-prep.i 1 trdcattr-t_pass-position   "t_pass-position" " "   "t_pass-position" }
{ cmp/cr-prep.i 1 trdcattr-t_accept-fname    "t_accept-fname" " "    "t_accept-fname" }
{ cmp/cr-prep.i 1 trdcattr-t_accept-position "t_accept-position" " " "t_accept-position" }

{ cmp/cr-prep.i 1 trdcattr-ndovwho "ndovwho" " " "ndovwho" }
/* Основание документа */
{ cmp/cr-prep.i 1 trdcattr-nosn     "nosn" " " "nosn" }

/* Переоценки */
{ cmp/cr-prep.i 1 trdcattr-relprpdf   "relprpdf" " " "relprpdf" }

/* Номер sequence выгрузки в Oracle Retail*/
{ cmp/cr-prep.i 1 trdcattr-ora-exp-seq-num   "ora-exp-seq-num" " " "ora-exp-seq-num" }

/* расчет данных по ДК еще не произошел*/
{ cmp/cr-prep.i 1 trdcattr-need-saledc   "need-saledc" " " "need-saledc" }

/* Предпологаемая дата закрытия инвентаризации */
{ cmp/cr-prep.i 1 trdcattr-dateinv   "dateinv" " " "dateinv" }

/* Серия по фасовочному журналу */
{ cmp/cr-prep.i 1 trdcattr-ser_on_pack      "ser_on_pack" " "      "ser_on_pack" }

/* Описание груза */
{ cmp/cr-prep.i 1 trdcattr-cargo-desc       "cargo-desc"  " "      "cargo-desc" }

/* Вид перевозки */
{ cmp/cr-prep.i 1 trdcattr-carry-type       "carry-type"  " "      "carry-type" }

/* Масса груза */
{ cmp/cr-prep.i 1 trdcattr-cargo-mass       "cargo-mass"  " "      "cargo-mass"  }

/* Складские\транспортные расходы */
{ cmp/cr-prep.i 1 trdcattr-exp-trans        "exp-trans"   " "      "exp-trans"   }

/* Номер заказа */
{ cmp/cr-prep.i 1 trdcattr-zakaz-number     "zakaz-number" " "     "zakaz-number"}

/* Дата доставки */
{ cmp/cr-prep.i 1 trdcattr-delivery-date "delivery-date" " " "delivery-date" }

/* Дата заказа */
{ cmp/cr-prep.i 1 trdcattr-zakaz-date "zakaz-date" " " "zakaz-date" }

/*время доставки */
{ cmp/cr-prep.i 1 trdcattr-delivery-time "delivery-time" " " "delivery-time" }

/* Нефтебаза */
{ cmp/cr-prep.i 1 trdcattr-ptbobj "ptbobj" " " "ptbobj" }

/* Примечание к нефтебазе */
{ cmp/cr-prep.i 1 trdcattr-ptb-item-pour "ptb-item-pour" " " "ptb-item-pour" }

/* Автопредприятие */
{ cmp/cr-prep.i 1 trdcattr-autoent "autoent" " " "autoent" }

/* Гос. № автоцистерны */
{ cmp/cr-prep.i 1 trdcattr-car-num "car-num" " " "car-num" }

/* Ф.И.О. водителя-экспедитора */
{ cmp/cr-prep.i 1 trdcattr-fio-driver "fio-driver" " " "fio-driver" }

/* Дата прибытия на АЗС */
{ cmp/cr-prep.i 1 trdcattr-date-income "date-income" " " "date-income" }

/* Время прибытия на АЗС */
{ cmp/cr-prep.i 1 trdcattr-time-income "time-income" " " "time-income" }

/* Дата налива */
{ cmp/cr-prep.i 1 trdcattr-time-pour "time-pour" " " "time-pour" }

/* Время налива */
{ cmp/cr-prep.i 1 trdcattr-date-pour "date-pour" " " "date-pour" }

/* Время начала слива */
{ cmp/cr-prep.i 1 trdcattr-time-start "time-start" " " "time-start" }

/* Время конца слива */
{ cmp/cr-prep.i 1 trdcattr-time-end "time-end" " " "time-end" }

/* Свидетельство о проверке */
{ cmp/cr-prep.i 1 trdcattr-inspection-cert "inspection-cert" " " "inspection-cert" }

/* Свидетельство о проверке */
{ cmp/cr-prep.i 1 trdcattr-date-cert "date-cert" " " "date-cert" }

/* Паспорт качества дата  */
{ cmp/cr-prep.i 1 trdcattr-date-pasport "date-pasport" " " "date-pasport" }

/* Паспорт качества номер */
{ cmp/cr-prep.i 1 trdcattr-num-pasport "num-pasport" " " "num-pasport" }

/* Техническое состояние */
{ cmp/cr-prep.i 1 trdcattr-condition "condition" " " "condition" }

/* Пломбы, их состояние */
{ cmp/cr-prep.i 1 trdcattr-seals-condition "seals-condition" " " "seals-condition" }

/* Документы НЕ предоставлены */
{ cmp/cr-prep.i 1 trdcattr-doc-not "doc-not" " " "doc-not" }

/* Список не предоставленных документов */
{ cmp/cr-prep.i 1 trdcattr-spisok-not-doc "spisok-not-doc" " " "spisok-not-doc" }

/* Топливная накладная */
{ cmp/cr-prep.i 1 trdcattr-is-fuel "is-fuel" " " "is-fuel" }

/* Приход СУГ */
{ cmp/cr-prep.i 1 trdcattr-is-lgas "is-lgas" " " "is-lgas" }

/* Корр. СУГ */
{ cmp/cr-prep.i 1 trdcattr-is-lgas-corr "is-lgas-corr" " " "is-lgas-corr" }

/* Документ источник для ТПН */
{ cmp/cr-prep.i 1 trdcattr-trn-is-gds "trn-is-gds" " " "trn-is-gds" }

/* Расход внешний как Возврат поставщику */
{ cmp/cr-prep.i 1 trdcattr-is-return "is-return" " " "is-return" }

/* Расход внешний как Возврат поставщику через ЭДО */
{ cmp/cr-prep.i 1 trdcattr-edo-return "edo-return" " " "edo-return" }

/* Документ источник для корр. СУГ */
{ cmp/cr-prep.i 1 trdcattr-trn-lgas-corr "trn-lgas-corr" " " "trn-lgas-corr" }

/* Дата начала слива */
{ cmp/cr-prep.i 1 trdcattr-date-start "trdcattr-date-start" " " "trdcattr-date-start" }

/* Дата конца слива */
{ cmp/cr-prep.i 1 trdcattr-date-end "trdcattr-date-end" " " "trdcattr-date-end" }

/* Признак накладной технологического пролива */
{ cmp/cr-prep.i 1 trdcattr-techpass "techpass" " " "techpass" }

/* Признак топливной накладной с прочими перемещениями (ИС ПМ) */
{ cmp/cr-prep.i 1 trdcattr-othermoves "othermoves" " " "othermoves" }

/* Признак накладной сформированной автоматически */
{ cmp/cr-prep.i 1 trdcattr-is-auto-trn "is-auto-trn" " " "is-auto-trn" }

/* Документ инвентаризации с первоначальным вводом марок */
{ cmp/cr-prep.i 1 trdcattr-inv-introduce "trdcattr-inv-introduce" " " "trdcattr-inv-introduce" }

/* Произведена зачистка АЦ перед наполнением на ГНС */
{ cmp/cr-prep.i 1 trdcattr-clear-ac "clear-ac" " " "clear-ac" }

/* Признак, что документ созан по УТД и должен в новостях обрабатываться на закрытия без учета, что это новости */
{ cmp/cr-prep.i 1 trdcattr-is-not-close-fact-news "trdcattr-is-not-close-fact-news" " " "trdcattr-is-not-close-fact-news" }

/* Номер приказа для документа инвентаризации */
{ cmp/cr-prep.i 1 trdcattr-prikaz-number "trdcattr-prikaz-number" " " "trdcattr-prikaz-number" }

/* Дата приказа для документа инвентаризации */
{ cmp/cr-prep.i 1 trdcattr-prikaz-date "trdcattr-prikaz-date" " " "trdcattr-prikaz-date" }

/* Инвентаризация: Дата фактического начала */
{ cmp/cr-prep.i 1 trdcattr-inv-date "trdcattr-inv-date" " " "trdcattr-inv-date" }

/* ФИО председателя комиссии */
{ cmp/cr-prep.i 1 trdcattr-fio-agent "trdcattr-fio-agent" " " "trdcattr-fio-agent" }

/* Должность председателя комиссии */
{ cmp/cr-prep.i 1 trdcattr-pos-agent "trdcattr-pos-agent" " " "trdcattr-pos-agent" }

/* ФИО участника комиссии */
{ cmp/cr-prep.i 1 trdcattr-fio-player1 "trdcattr-fio-player1" " " "trdcattr-fio-player1" }

/* Должность участника комиссии */
{ cmp/cr-prep.i 1 trdcattr-pos-player1 "trdcattr-pos-player1" " " "trdcattr-pos-player1" }

/* ФИО участника комиссии */
{ cmp/cr-prep.i 1 trdcattr-fio-player2 "trdcattr-fio-player2" " " "trdcattr-fio-player2" }

/* Должность участника комиссии */
{ cmp/cr-prep.i 1 trdcattr-pos-player2 "trdcattr-pos-player2" " " "trdcattr-pos-player2" }

/* ФИО участника комиссии */
{ cmp/cr-prep.i 1 trdcattr-fio-player3 "trdcattr-fio-player3" " " "trdcattr-fio-player3" }

/* Должность участника комиссии */
{ cmp/cr-prep.i 1 trdcattr-pos-player3 "trdcattr-pos-player3" " " "trdcattr-pos-player3" }

/* Масса слитого СУГ на промежуточных станциях АГЗС */
{ cmp/cr-prep.i 1 sugtpattr-massa-sug "sugtpattr-massa-sug" " " "sugtpattr-massa-sug" }

/* Технологические потери предыдущих станций */
{ cmp/cr-prep.i 1 sugtpattr-teh-loss "sugtpattr-teh-loss" " " "sugtpattr-teh-loss" }

/* Допустимые погрешности предыдущих станций */
{ cmp/cr-prep.i 1 sugtpattr-err-allow "sugtpattr-err-allow" " " "err-allow" }


&glob trdcattr-list '~
{&bef-trdcattr-hold-part-code}~
,{&bef-trdcattr-dov}~
,{&bef-trdcattr-dids}~
,{&bef-trdcattr-dateinv}~
,{&bef-trdcattr-nids}~
,{&bef-trdcattr-ddog}~
,{&bef-trdcattr-ndog}~
,{&bef-trdcattr-dsf}~
,{&bef-trdcattr-nsf}~
,{&bef-trdcattr-addsum}~
,{&bef-trdcattr-clcasol}~
,{&bef-trdcattr-clcaswt}~
,{&bef-trdcattr-scanfile}~
,{&bef-trdcattr-indoclnsum}~
,{&bef-trdcattr-purchlimit}~
,{&bef-trdcattr-purchcodelist}~
,{&bef-trdcattr-expense_own}~
,{&bef-trdcattr-envd}~
,{&bef-trdcattr-fbroperator}~
,{&bef-trdcattr-fbrauto}~
,{&bef-trdcattr-frsrv-date}~
,{&bef-trdcattr-ord_time}~
,{&bef-trdcattr-ord_phone}~
,{&bef-trdcattr-ord_contact}~
,{&bef-trdcattr-befpay}~
,{&bef-trdcattr-ord_Nchek}~
,{&bef-trdcattr-dchek}~
,{&bef-trdcattr-first-price}~
,{&bef-trdcattr-ord_dl}~
,{&bef-trdcattr-deliv}~
,{&bef-trdcattr-sumwrk}~
,{&bef-trdcattr-sumsrk}~
,{&bef-trdcattr-ord_adr}~
,{&bef-trdcattr-ord_hwo}~
,{&bef-trdcattr-postpay}~
,{&bef-trdcattr-postNchek}~
,{&bef-trdcattr-postdchek}~
,{&bef-trdcattr-qntyplace}~
,{&bef-trdcattr-discnt-stop}~
,{&bef-trdcattr-discnt-other}~
,{&bef-trdcattr-m-inc}~
,{&bef-trdcattr-dfindoc}~
,{&bef-trdcattr-nfindoc}~
,{&bef-trdcattr-place-storage}~
,{&bef-trdcattr-packer}~
,{&bef-trdcattr-dispath}~
,{&bef-trdcattr-price-target}~
,{&bef-trdcattr-edi}~
,{&bef-trdcattr-negais}~
,{&bef-trdcattr-egais}~
,{&bef-trdcattr-ddov}~
,{&bef-trdcattr-ndov}~
,{&bef-trdcattr-recipient}~
,{&bef-trdcattr-shipper}~
,{&bef-trdcattr-auto}~
,{&bef-trdcattr-driver}~
,{&bef-trdcattr-print-num}~
,{&bef-trdcattr-idCountryContr}~
,{&bef-trdcattr-oldsuppcntr}~
,{&bef-trdcattr-t_pass-fname}~
,{&bef-trdcattr-t_pass-position}~
,{&bef-trdcattr-t_accept-fname}~
,{&bef-trdcattr-t_accept-position}~
,{&bef-trdcattr-ndovwho}~
,{&bef-trdcattr-car-time}~
,{&bef-trdcattr-nosn}~
,{&bef-trdcattr-relprpdf}~
,{&bef-trdcattr-ora-exp-seq-num}~
,{&bef-trdcattr-need-saledc}~
,{&bef-trdcattr-ser_on_pack}~
,{&bef-trdcattr-cargo-desc}~
,{&bef-trdcattr-carry-type}~
,{&bef-trdcattr-cargo-mass}~
,{&bef-trdcattr-exp-trans}~
,{&bef-trdcattr-zakaz-number}~
,{&bef-trdcattr-zakaz-date}~
,{&bef-trdcattr-delivery-date}~
,{&bef-trdcattr-delivery-time}~
,{&bef-trdcattr-ptbocode}~
,{&bef-trdcattr-autoent}~
,{&bef-trdcattr-car-num}~
,{&bef-trdcattr-fio-driver}~
,{&bef-trdcattr-date-income}~
,{&bef-trdcattr-hour-income}~
,{&bef-trdcattr-inspection-cert}~
,{&bef-trdcattr-condition}~
,{&bef-trdcattr-seals-condition}~
,{&bef-trdcattr-doc-not}~
,{&bef-trdcattr-spisok-not-doc}~
,{&bef-trdcattr-is-fuel}~
,{&bef-trdcattr-is-lgas}~
,{&bef-trdcattr-is-lgas-corr}~
,{&bef-trdcattr-othermoves}~
,{&bef-trdcattr-is-return}~
,{&bef-trdcattr-clear-ac}~
,{&bef-trdcattr-edo-return}~
,{&bef-trdcattr-is-not-close-fact-news}~
,{&bef-trdcattr-prikaz-number}~
,{&bef-trdcattr-prikaz-date}~
,{&bef-trdcattr-inv-date}~
,{&bef-trdcattr-fio-agent}~
,{&bef-trdcattr-pos-agent}~
,{&bef-trdcattr-fio-player1}~
,{&bef-trdcattr-pos-player1}~
,{&bef-trdcattr-fio-player2}~
,{&bef-trdcattr-pos-player2}~
,{&bef-trdcattr-fio-player3}~
,{&bef-trdcattr-pos-player3}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define trdcattr-list {&trdcattr-list}" ).

/* Атрибуты строки документа */
{ cmp/cr-prep.i 1 lineattr-flora_ps          "flora_ps"         " "  "flora_ps"        }
{ cmp/cr-prep.i 1 lineattr-flora_gds-code    "fl_gds-code"      " "  "fl_gds-code"     }
{ cmp/cr-prep.i 1 lineattr-country-code      "country-code"     " "  "country-code"    }
{ cmp/cr-prep.i 1 lineattr-old_other-ras     "old_other-ras"    " "  "old_other-ras"   }
{ cmp/cr-prep.i 1 lineattr-new_other-ras     "new_other-ras"    " "  "new_other-ras"   }
{ cmp/cr-prep.i 1 lineattr-add-line-cli      "add-line-cli"     " "  "add-line-cli"    }
{ cmp/cr-prep.i 1 lineattr-corr-price-sale   "corr-price-sale"  " "  "corr-price-sale" }
{ cmp/cr-prep.i 1 lineattr-reason-code       "reason-code"      " "  "reason-code"     }
{ cmp/cr-prep.i 1 lineattr-price-prod        "price-prod"       " "  "price-prod"      }
{ cmp/cr-prep.i 1 lineattr-price-prod-vat    "price-prodvat"    " "  "price-prod-vat"  }
{ cmp/cr-prep.i 1 lineattr-parts_price-sale  "parts_price-sale" " "  "parts_price-sale" }

/****************************** end  of имена атрибутов clients-attr ****************************************************/

{ cmp/cr-prep.i 1 is-flor     "is-flor"      " "  "is-flor"  }

/*атрибуты партий на объекте*/

/* адат исчерпания своб зоны */
{ cmp/cr-prep.i 1 partoatr-parts-end  parts-end  " "  parts-end}


&glob partoatr-list '{&bef-partoatr-parts-end}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define partoatr-list {&partoatr-list}" ).




/* Атрибуты документов МЦ */

/*Дата счета-фактуры поставщика*/
{ cmp/cr-prep.i 1 wthcattr-dsf wthdsf " " wthdsf }
/*Номер счета-фактуры поставщика*/
{ cmp/cr-prep.i 1 wthcattr-nsf wthnsf " " wthnsf }
/*Основание */
{ cmp/cr-prep.i 1 wthcattr-reason  wthreason  " " wthreason }
/*Платежно расч. документы */
{ cmp/cr-prep.i 1 wthcattr-paydoc  wthpaydoc  " " wthpaydoc }
/*Доверенность */
{ cmp/cr-prep.i 1 wthcattr-proxy  wthproxy  " " wthproxy }
/*Получил */
{ cmp/cr-prep.i 1 wthcattr-receiver  wthreceiver  " "  wthreceiver }
 /* Грузополучатель */
{ cmp/cr-prep.i 1 wthcattr-consignee  wthconsignee  " "  wthconsignee }

&glob wthcattr-list  '{&bef-wthcattr-dsf}~
,{&bef-wthcattr-nsf}~
,{&bef-wthcattr-reason}~
,{&bef-wthcattr-paydoc}~
,{&bef-wthcattr-proxy}~
,{&bef-wthcattr-receiver}~
,{&bef-wthcattr-consignee}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define wthcattr-list {&wthcattr-list}" ).


/* имена атрибутов принятых пакетов */

 /* Дата начала разбора пакета */
{ cmp/cr-prep.i 1 attr-beg-imp-date           beg-imp-date          " " beg-imp-date         }
 /* Время начала разбора пакета */
{ cmp/cr-prep.i 1 attr-beg-imp-time           beg-imp-time          " " beg-imp-time         }

/* сюда добавлять новые названия атрибутов принятых пакетов */

&glob pck-attr-list '~
{&bef-attr-beg-imp-date}~
,{&bef-attr-beg-imp-time}~
':u
run filwrlib_append-new-line in this-procedure ( input "&global-define pck-attr-list {&pck-attr-list}" ).


/* Учет топливных товаров */
{ cmp/cr-prep.i 1 calc-petrol-volume      "volume"  " " "volume"  }
{ cmp/cr-prep.i 1 calc-petrol-weight      "weight"  " " "weight"  }
{ cmp/cr-prep.i 1 calc-petrol-volume-plus "volume+" " " "volume+" }
{ cmp/cr-prep.i 1 calc-petrol-weight-plus "weight+" " " "weight+" }

&GLOB bef-calc-petrol-list  {&bef-calc-petrol-volume},{&bef-calc-petrol-weight},{&bef-calc-petrol-volume-plus},{&bef-calc-petrol-weight-plus}
&GLOB     calc-petrol-list '{&bef-calc-petrol-list}':U

run filwrlib_append-new-line in this-procedure ( input "&global-define bef-calc-petrol-list {&bef-calc-petrol-list}" ).
run filwrlib_append-new-line in this-procedure ( input "&global-define calc-petrol-list {&calc-petrol-list}" ).
/* Учет топливных товаров --  E n d */


/* Внешние подсистемы OPEN_XML_IBS_TH */

{ cmp/cr-prep.i 1 openxml-subsystem         "openxml-subsystem"     " "   "openxml-subsystem"   " " }
{ cmp/cr-prep.i 1 openxml-status-working    "1"                     " "   "1"                   " " }
{ cmp/cr-prep.i 1 openxml-status-new        "-1"                    " "   "-1"                  " " }
{ cmp/cr-prep.i 1 openxml-status-stopped    "0"                     " "   "0"                   " " }
{ cmp/cr-prep.i 1 openxml-import            "импорт"                " "   "import"              " " }
{ cmp/cr-prep.i 1 openxml-export            "экспорт"               " "   "export"              " " }
{ cmp/cr-prep.i 1 openxml-exp-conf-no-wait   0                      0      0                    0   }
{ cmp/cr-prep.i 1 openxml-exp-conf-wait      1                      1      1                    1   }
{ cmp/cr-prep.i 1 openxml-imp-conf-no-send   0                      0      0                    0   }
{ cmp/cr-prep.i 1 openxml-imp-conf-send      1                      1      1                    1   }

/*при дописывании этого блока - иметь в виду b g e / e s y s - k e y . p */

{ cmp/cr-prep.i 1 openxml-type-ordinal       0         "НЕспециальная"       0                    "NONspecial"   }
{ cmp/cr-prep.i 1 openxml-type-special       1         "Специальная"         1                    "Special"   }
{ cmp/cr-prep.i 1 openxml-type-ibs-th        2         "IBS TH"              2                    "IBS TH"   }
{ cmp/cr-prep.i 1 openxml-type-oracle-retail 3         "Oracle Retail"       3                    "Oracle Retail"   }
{ cmp/cr-prep.i 1 openxml-type-lantab        4         "Lantab"              4                    "Lantab"   }
{ cmp/cr-prep.i 1 openxml-type-edoc-nn       5         "EDOC-НН"             5                    "EDOC-NN"   }
{ cmp/cr-prep.i 1 openxml-type-com-dashboard 6         "Панель Руководителя" 6                    "Commanders Dashboard"   }
{ cmp/cr-prep.i 1 openxml-type-dklink        7         "ДатаКрат DKLink"     7                    "DataKrat DKLink"   }
{ cmp/cr-prep.i 1 openxml-type-1c            8         "1C"                  8                    "1C"   }
{ cmp/cr-prep.i 1 openxml-type-exite-edi     9         "EDI"                 9                    "EDI"   }
{ cmp/cr-prep.i 1 openxml-type-mercury       10        "Меркурий"            10                   "Mercury"   }
{ cmp/cr-prep.i 1 openxml-type-is_motp       11        "ИС МОТП"             11                   "Is_motp"   }
{ cmp/cr-prep.i 1 openxml-type-is_diadoc     12        "ИС Диадок"           12                   "Is_diadoc"   }

&glob openxml-type-list '~
{&bef-openxml-type-ordinal}~
,{&bef-openxml-type-special}~
,{&bef-openxml-type-ibs-th}~
,{&bef-openxml-type-oracle-retail}~
,{&bef-openxml-type-lantab}~
,{&bef-openxml-type-edoc-nn}~
,{&bef-openxml-type-com-dashboard}~
,{&bef-openxml-type-dklink}~
,{&bef-openxml-type-1c}~
,{&bef-openxml-type-exite-edi}~
,{&bef-openxml-type-mercury}~
,{&bef-openxml-type-is_motp}~
,{&bef-openxml-type-is_diadoc}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define openxml-type-list {&openxml-type-list}" ).

&glob openxml-type-list-full '~
{&bef-openxml-type-ordinal-full}~
,{&bef-openxml-type-special-full}~
,{&bef-openxml-type-ibs-th-full}~
,{&bef-openxml-type-oracle-retail-full}~
,{&bef-openxml-type-lantab-full}~
,{&bef-openxml-type-edoc-nn-full}~
,{&bef-openxml-type-com-dashboard-full}~
,{&bef-openxml-type-dklink-full}~
,{&bef-openxml-type-1c-full}~
,{&bef-openxml-type-exite-edi-full}~
,{&bef-openxml-type-mercury-full}~
,{&bef-openxml-type-is_motp-full}~
,{&bef-openxml-type-is_diadoc-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define openxml-type-list-full {&openxml-type-list-full}" ).

&glob openxml-type-name entry (lookup (~~~~~~~{&openxml-type-code}, {&openxml-type-list}), {&openxml-type-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define openxml-type-name {&openxml-type-name}" ).

/*при дописывании этого блока - иметь в виду b g e / e s y s - k e y . p */

&glob openxml-special-type-list '~
{&bef-openxml-type-special}~
,{&bef-openxml-type-ibs-th}~
,{&bef-openxml-type-oracle-retail}~
,{&bef-openxml-type-lantab}~
,{&bef-openxml-type-edoc-nn}~
,{&bef-openxml-type-com-dashboard}~
,{&bef-openxml-type-dklink}~
,{&bef-openxml-type-1c}~
,{&bef-openxml-type-exite-edi}~
,{&bef-openxml-type-mercury}~
,{&bef-openxml-type-is_motp}~
,{&bef-openxml-type-is_diadoc}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define openxml-special-type-list {&openxml-special-type-list}" ).

/*при дописывании этого блока - иметь в виду b g e / e s y s - k e y . p */


&glob openxml-licensed-type-list '~
{&bef-openxml-type-dklink}~
,{&bef-openxml-type-exite-edi}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define openxml-licensed-type-list {&openxml-licensed-type-list}" ).


run filwrlib_append-new-line in this-procedure ( input substitute("&&global-define max-openxml-type-code &1", num-entries({&openxml-type-list}) - 1 )).




/* Ассортиментная матрица */

{ cmp/cr-prep.i 1 assmatr               "Ассортиментная матрица"         " "  "Assort.Matrix"         " "   }
{ cmp/cr-prep.i 1 type-assmatr-obj      "Объект"         " "  "Object"         " "   }
{ cmp/cr-prep.i 1 type-assmatr-shablon  "Шаблон"         " "  "Pattern"        " "   }

/* Индикаторы жизнедеятельности товара */
{ cmp/cr-prep.i 1 ass-izd-new    "Новинка"                   " "   "Novelty"  " "   }
{ cmp/cr-prep.i 1 ass-izd-com    "Основная группа"           " "   "Common"   " "   }
{ cmp/cr-prep.i 1 ass-izd-del    "На вывод из ассортимента"  " "   "Delete"   " "   }
{ cmp/cr-prep.i 1 ass-izd-empty  "Пусто"                     " "   "Empty"    " "   }
{ cmp/cr-prep.i 1 ass-izd-spec   "Нештатный"                 " "   "Special"  " "   }


&GLOB ass-izd-list '~
{&bef-ass-izd-new}~
,{&bef-ass-izd-com}~
,{&bef-ass-izd-spec}~
,{&bef-ass-izd-del}~
,{&bef-ass-izd-empty}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define ass-izd-list {&ass-izd-list}" ).

/*испосльзуемость масок ДК*/
{ cmp/cr-prep.i 1 dcm-cd-th             0               Касса_и_TH               0   CashDesk_and_TH}
{ cmp/cr-prep.i 1 dcm-only-cd           1               ТОЛЬКО_касса             1   CashDesk_only}
{ cmp/cr-prep.i 1 dcm-only-th           2               ТОЛЬКО_TH                2   TH_Only}


&glob use-on-cd-codes '{&bef-dcm-cd-th},{&bef-dcm-only-cd},{&bef-dcm-only-th}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define use-on-cd-codes {&use-on-cd-codes}" ).
&glob use-on-cd-codes-full  '{&bef-dcm-cd-th-full},{&bef-dcm-only-cd-full},{&bef-dcm-only-th-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define use-on-cd-codes-full {&use-on-cd-codes-full}" ).

&glob use-on-cd-name entry (lookup (~~~~~~~{&use-on-cd-code}, {&use-on-cd-codes}), {&use-on-cd-codes-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define use-on-cd-name {&use-on-cd-name}" ).

{ cmp/cr-prep.i 1 dcm-cc-algo-no         0               Нет_алгоритма            0   No_algo }
{ cmp/cr-prep.i 1 dcm-cc-algo-luhn       1               Алгоритм_Луна            1   Luhn_algo }

&glob dcm-cc-algo-codes  '~
{&bef-dcm-cc-algo-no}~
,{&bef-dcm-cc-algo-luhn}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define dcm-cc-algo-codes {&dcm-cc-algo-codes}" ).

&glob dcm-cc-algo-codes-full  '~
{&bef-dcm-cc-algo-no-full}~
,{&bef-dcm-cc-algo-luhn-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define dcm-cc-algo-codes-full {&dcm-cc-algo-codes-full}" ).

&glob dcm-cc-algo-name entry (lookup (~~~~~~~{&dcm-cc-algo-code}, {&dcm-cc-algo-codes}), {&dcm-cc-algo-codes-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define dcm-cc-algo-name {&dcm-cc-algo-name}" ).


/*испосльзуемость масок ДК - e n d*/

/*спец тип дисконтной карты КЛИЕНТ-СЧЕТ*/
{ cmp/cr-prep.i 1 dct-client            @client         Клиент-Счет                      @client  Client-Account }
{ cmp/cr-prep.i 1 dct-client-prefix     K              "Префикс карты типа Клиент-Счет"  K        "Client-Account Type Cards Prefix" }

&glob dct-client-card-no   ('{&bef-dct-client-prefix}':U + string(if ~~~~~~~{&dct-client-obj-type} = ~~~~~~~{&cmp} then 1 else 0) + ~
string(~~~~~~~{&dct-client-obj-code}, '999999999'))
run filwrlib_append-new-line in this-procedure ( input "&global-define dct-client-card-no {&dct-client-card-no}" ).

/*типы поддерживаемых систем клиент-банк*/

{ cmp/cr-prep.i 1 cl-bank-1s             1s               1С               1s            1С          }

&glob cl-bank-codes '{&bef-cl-bank-1s}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cl-bank-codes {&cl-bank-codes}" ).

&glob cl-bank-codes-full  '{&bef-cl-bank-1s-full}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define cl-bank-codes-full {&cl-bank-codes-full}" ).

&glob cl-bank-name entry (lookup (~~~~~~~{&cl-bank-code}, {&cl-bank-codes}) + 1, ',' + {&cl-bank-codes-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define cl-bank-name {&cl-bank-name}" ).

/*типы поддерживаемых систем клиент-банк - e n d*/

/* Код товара в заказе EAN13 */
{ cmp/cr-prep.i 1 attr-order-EAN13 ord-EAN13 " " ord-EAN13 }


/* способы округления количества в заказах */
{ cmp/cr-prep.i 1 ord-round-integer Без-дробных      " " Integer}
{ cmp/cr-prep.i 1 ord-round-select  Произвольно      " " Optional}
{ cmp/cr-prep.i 1 ord-round-off     Отключено        " " Disabled}
{ cmp/cr-prep.i 1 ord-round-qnty-card Кол-во_в_коробке        " " qnty_card}

&glob ord-rounds '{&bef-ord-round-integer},{&bef-ord-round-select},{&bef-ord-round-off},{&bef-ord-round-qnty-card}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define ord-rounds {&ord-rounds}" ).

&glob ord-rounds-need-coef '{&bef-ord-round-select}':U
run filwrlib_append-new-line in this-procedure ( input "&global-define ord-rounds-need-coef {&ord-rounds-need-coef}" ).

&glob ord-round-name entry (lookup (~~~~~~~{&ord-round-code}, {&ord-rounds})
run filwrlib_append-new-line in this-procedure ( input "&global-define ord-round-name {&ord-round-name}" ).

/*типы документов ТПСИ*/

{ cmp/cr-prep.i 1 tpsi-hold-expense     tpsi-hold-expense       "Межфирм.расход по ТПСИ"   tpsi-hold-expense      "Holding exp.  TPSI" }
{ cmp/cr-prep.i 1 tpsi-internal-expense tpsi-internal-expense   "Внутр.расход по ТПСИ"     tpsi-internal-expense  "Internal exp. TPSI" }
{ cmp/cr-prep.i 1 tpsi-hold-income      tpsi-hold-income        "Межфирм.приход по ТПСИ"   tpsi-hold-income       "Holding inc.  TPSI" }
{ cmp/cr-prep.i 1 tpsi-internal-income  tpsi-internal-income    "Внутр.приход по ТПСИ"     tpsi-internal-income   "Internal inc. TPSI" }


&glob tpsi-doc-kinds '~
{&bef-tpsi-hold-expense}~
,{&bef-tpsi-internal-expense}~
,{&bef-tpsi-hold-income}~
,{&bef-tpsi-internal-income}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define tpsi-doc-kinds {&tpsi-doc-kinds}" ).

&glob tpsi-doc-kinds-full '~
{&bef-tpsi-hold-expense-full}~
,{&bef-tpsi-internal-expense-full}~
,{&bef-tpsi-hold-income-full}~
,{&bef-tpsi-internal-income-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define tpsi-doc-kinds-full {&tpsi-doc-kinds-full}" ).

/*расширенные типы которые имеют документы ТПСИ*/

&glob tpsi-ext-doc-types '~~~~~~~{&bef-TDEDT_Ras_Vnesh},~
~~~~~~~{&bef-TDEDT_Ras_Perem},~
~~~~~~~{&bef-TDEDT_Pri_Vnesh},~
~~~~~~~{&bef-TDEDT_Ras_Vnesh_Kass},~
~~~~~~~{&bef-TDEDT_Pri_Perem}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define tpsi-ext-doc-types {&tpsi-ext-doc-types}" ).

/*определение имени по kind*/
&glob tpsi-doc-name-k entry (lookup (~~~~~~~{&tpsi-doc-kind}, {&tpsi-doc-kinds}), {&tpsi-doc-kinds-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define tpsi-doc-name-k {&tpsi-doc-name-k}" ).

/*определение имени по ext-doc-type*/
&glob tpsi-doc-name-e entry (lookup (~~~~~~~{&tpsi-doc-ext}, {&tpsi-ext-doc-types}), {&tpsi-doc-kinds-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define tpsi-doc-name-e {&tpsi-doc-name-e}" ).


/*типы ДОПОЛНИТЕЛЬНЫХ документов рождаемых по чекам */

{ cmp/cr-prep.i 1 sale-add-tech-refuell      trf          ТехПролив              trf  TechRefuell}
{ cmp/cr-prep.i 1 sale-add-return-write-off  rwo          Списание-по-Возврату   rwo  Write-off-by-Return}
{ cmp/cr-prep.i 1 sale-add-write-off         swo          Списание               swo  Write-off}
{ cmp/cr-prep.i 1 sale-add-nat-gas           ngs          Приход-Природный-Газ   ngs  Natural-Gas}
{ cmp/cr-prep.i 1 sale-add-ret-nat-gas       rgs          Возврат-Природный-Газ  rgs  Return-Natural-Gas}
{ cmp/cr-prep.i 1 sale-add-vir-res           vir          Перемещение-Вирт-Рез   vir  Virtual-Res}


&glob sale-add-kinds '~
{&bef-sale-add-return-write-off}~
,{&bef-sale-add-tech-refuell}~
,{&bef-sale-add-write-off}~
,{&bef-sale-add-nat-gas}~
,{&bef-sale-add-ret-nat-gas}~
,{&bef-sale-add-vir-res}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define sale-add-kinds {&sale-add-kinds}" ).

&glob sale-add-kinds-full '~
{&bef-sale-add-return-write-off-full}~
,{&bef-sale-add-tech-refuell-full}~
,{&bef-sale-add-write-off-full}~
,{&bef-sale-add-nat-gas-full}~
,{&bef-sale-add-ret-nat-gas-full}~
,{&bef-sale-add-vir-res-full}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define sale-add-kinds-full {&sale-add-kinds-full}" ).


/*все типы документов рождаемых по чекам - будет их звать автоматическими*/

&glob sale-all-doc-kinds '~~~~~~~{&bef-TDEDT_Ras_Vnesh_Kass},~
~~~~~~~{&bef-TDEDT_Vozvrat_Vnesh_Kass},~
{&bef-sale-add-return-write-off},~
{&bef-sale-add-tech-refuell},~
{&bef-sale-add-write-off},~
{&bef-sale-add-nat-gas},~
{&bef-sale-add-ret-nat-gas},~
{&bef-sale-add-vir-res}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define sale-all-doc-kinds {&sale-all-doc-kinds}" ).


&glob sale-all-doc-kinds-full '~~~~~~~{&bef-TDEDT_Ras_Vnesh_Kass-full},~
~~~~~~~{&bef-TDEDT_Vozvrat_Vnesh_Kass-full},~
{&bef-sale-add-return-write-off-full},~
{&bef-sale-add-tech-refuell-full},~
{&bef-sale-add-write-off-full},~
{&bef-sale-add-nat-gas-full},~
{&bef-sale-add-ret-nat-gas-full},~
{&bef-sale-add-vir-res-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define sale-all-doc-kinds-full {&sale-all-doc-kinds-full}" ).

/*расширенные типы которые имеют доп автодокументы*/

&glob sale-add-ext-doc-types '~~~~~~~{&bef-TDEDT_Spi_Vnesh},~
~~~~~~~{&bef-TDEDT_Spi_Vnesh},~
~~~~~~~{&bef-TDEDT_Spi_Vnesh},~
~~~~~~~{&bef-TDEDT_Spi_Vnesh},~
~~~~~~~{&bef-TDEDT_Ras_Vnesh}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define sale-add-ext-doc-types {&sale-add-ext-doc-types}" ).

/*это отедльная песня в списки не включать!!! - только в функции определения имени*/
{ cmp/cr-prep.i 1 sale-add2-in-tech-refuell      itr          ПриТехПрол              itrf  InTechRef }

&glob sale-doc-name entry (lookup (~~~~~~~{&sale-doc-kind}, {&sale-all-doc-kinds} + ',' + {&sale-add2-in-tech-refuell}) + 1, ',' + {&sale-all-doc-kinds-full} + ',' + {&sale-add2-in-tech-refuell-full} )
run filwrlib_append-new-line in this-procedure ( input "&global-define sale-doc-name {&sale-doc-name}" ).


&glob sale-doc-kind-born entry (lookup (~~~~~~~{&sale-doc-kind}, {&sale-all-doc-kinds}), 'main,pair,trio-m,quadro,stock-down,quadro,chip')
run filwrlib_append-new-line in this-procedure ( input "&global-define sale-doc-kind-born {&sale-doc-kind-born}" ).

&glob sale-doc-main-receipt-type entry (lookup (~~~~~~~{&sale-doc-kind}, {&sale-all-doc-kinds}) + 1, '~
0,~
~~~~~~~{&bef-rcpt-sale},~
~~~~~~~{&bef-rcpt-return},~
~~~~~~~{&bef-rcpt-return-write-off},~
~~~~~~~{&bef-rcpt-tech-refuell},~
~~~~~~~{&bef-rcpt-write-off},~
~~~~~~~{&bef-rcpt-tech-refuell},~
~~~~~~~{&bef-rcpt-tech-refuell}~
':U)

run filwrlib_append-new-line in this-procedure ( input "&global-define sale-doc-main-receipt-type {&sale-doc-main-receipt-type}" ).

&glob sale-doc-poss-wro-codes entry (lookup (~~~~~~~{&sale-doc-kind}, {&sale-all-doc-kinds}) + 1, '~
0,~
~~~~~~~{&bef-wro-r-modificator},~
~~~~~~~{&bef-wro-v-modificator},~
~~~~~~~{&bef-wro-cancell-item};~
~~~~~~~{&bef-wro-v-modificator-ci};~
~~~~~~~{&bef-wro-cancell-all};~
~~~~~~~{&bef-wro-v-modificator-ca},~
~~~~~~~{&bef-wro-r-tech-refuell},~
~~~~~~~{&bef-wro-without-payment};~
~~~~~~~{&bef-wro-r-modificator-wp}~
':U)

run filwrlib_append-new-line in this-procedure ( input "&global-define sale-doc-poss-wro-codes {&sale-doc-poss-wro-codes}" ).


/*типы документов с резервированием автопроизводства*/

&glob sale-doc-fbrsale '~~~~~~~{&bef-TDEDT_Ras_Vnesh_Kass},~
{&bef-sale-add-write-off}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define sale-doc-fbrsale {&sale-doc-fbrsale}" ).


&glob sale-all-ext-doc-types '~~~~~~~{&bef-TDEDT_Ras_Vnesh_Kass},~
~~~~~~~{&bef-TDEDT_Vozvrat_Vnesh_Kass},~
~~~~~~~{&bef-TDEDT_Spi_Vnesh}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define sale-all-ext-doc-types {&sale-all-ext-doc-types}" ).




/* Типы генерации сч-ф в договорах в финансовом блоке */
{ cmp/cr-prep.i 1 contr-chf-nodef     "Не определено"                    " "  "nodef"         " "  }
{ cmp/cr-prep.i 1 contr-chf-out       "По расходной накладной"           " "  "out-doc"       " "  }
{ cmp/cr-prep.i 1 contr-chf-in        "По приходной накладной"           " "  "in-doc"        " "  }
{ cmp/cr-prep.i 1 contr-chf-type      "По накл. смены типа преобр."      " "  "type-doc"      " "  }
{ cmp/cr-prep.i 1 contr-chf-fo        "По фин. обязательству"            " "  "in-fo"         " "  }
{ cmp/cr-prep.i 1 contr-chf-pay       "По платежу"                       " "  "in-pay"        " "  }

/* права для производства */
{ cmp/cr-prep.i 1 price-sale-comp    "прод.ц.сост"      " " price-sale-comp          }
{ cmp/cr-prep.i 1 price-sale-ingr    "прод.ц.ингр"      " " price-sale-ingr          }

/* обновление реквизитов клиентов в незакрытых платежах из договора */
{ cmp/cr-prep.i 1 updfind    "обнов-рекв-фин-док"   " " updfind  }

/*роли*/
{ cmp/cr-prep.i 1 role-cashier     C    Кассир        С  Cashier }
{ cmp/cr-prep.i 1 role-seller      S    Продавец      S  Seller  }

&glob role-list '{&bef-role-cashier},~
{&bef-role-seller}':U

run filwrlib_append-new-line in this-procedure ( input "&global-define role-list {&role-list}" ).

&glob role-list-full '{&bef-role-cashier-full},~
{&bef-role-seller-full}':U

run filwrlib_append-new-line in this-procedure ( input "&global-define role-list-full {&role-list-full}" ).

&glob role-name entry (lookup (~~~~~~~{&role-code}, {&role-list}) + 1, ',':U + {&role-list-full})

run filwrlib_append-new-line in this-procedure ( input "&global-define role-name {&role-name}" ).


{ cmp/cr-prep.i 1 role-level-global global Глобально global  Global  }
{ cmp/cr-prep.i 1 role-level-db     db     БД        db      DB }
{ cmp/cr-prep.i 1 role-level-firm   firm   Фирма     firm    Company }
{ cmp/cr-prep.i 1 role-level-object object Объект    object  Object  }

&glob role-level-list '~
{&bef-role-level-global}~
,{&bef-role-level-db}~
,{&bef-role-level-firm}~
,{&bef-role-level-object}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define role-level-list {&role-level-list}" ).

&glob role-level-list-full '~
{&bef-role-level-global-full}~
,{&bef-role-level-db-full}~
,{&bef-role-level-firm-full}~
,{&bef-role-level-object-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define role-level-list-full {&role-level-list-full}" ).

&glob role-level-name entry (lookup (~~~~~~~{&role-level-code}, {&role-level-list}) + 1, ',':U + {&role-level-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define role-level-name {&role-level-name}" ).


/* Признак для поиска цены в МПЛ */
{ cmp/cr-prep.i 1 mpl-main    0  "основной код"      0 main_code  }
{ cmp/cr-prep.i 1 mpl-nomain  1  "не основной код"   1 no_main_code  }
{ cmp/cr-prep.i 1 mpl-qnty    2  "кол-во"            2 qnty     }
{ cmp/cr-prep.i 1 mpl-sum     3  "сумма"             3 sum      }
{ cmp/cr-prep.i 1 mpl-tnv     4  "оборот"            4 tnv      }
{ cmp/cr-prep.i 1 mpl-nodiv   5  "без разбивки"      5 nodiv    }


/* Признак работы в МПЛ */
{ cmp/cr-prep.i 1 mpl-date-obj   1  "дате на объекте"                  1 date_object }
{ cmp/cr-prep.i 1 mpl-date-shift 2  "сменной дате и № смены"           2 date_shift  }
{ cmp/cr-prep.i 1 mpl-date-sys   3  "дате и времени сервера"           3 date_system }

/* Признак типа цены в МПЛ */
{ cmp/cr-prep.i 1 mpl-type-main         0  "основной код"              0 main_code  }
{ cmp/cr-prep.i 1 mpl-type-nomain       1  "не основной код"           1 no_main_code  }
{ cmp/cr-prep.i 1 mpl-type-spec         2  "спец на основной код"      2 spec_main_code  }
{ cmp/cr-prep.i 1 mpl-type-specnomain   3  "спец на не основной код"   3 spec_no_main_code  }

{ cmp/cr-prep.i 1 mpl-trn-pay   "Оплата"        " "  "Рay"       " " }
{ cmp/cr-prep.i 1 mpl-cash-pay  "Касс.платеж"   " "  "Сash_pay"  " " }

/* атрибуты глобального ценообразования */
{ cmp/cr-prep.i 1 attr-pal-nws           pal-nws       pal-nws     pal-nws       pal-nws       }
{ cmp/cr-prep.i 1 attr-pal-level-discnt  level-discnt level-discnt level-discnt  level-discnt  }


&GLOB scales-type 'CAS_LP-15,CAS_LP-6,HELMAC_net,HELMAC_model-Z,HELMAC_model-T,CAS_LP-485,BOLET_P-280,BZB-SC515,DIGI_SM-80,CAS_LP-15v1.6,TIGER,MIRA,TIGER2,CAS_LP-16x,DIGI-SM,TIGER-SPCT2,SHTRIH-M,CAS_LP-II,CAS_CL5000J,CAS_CL5000,DIGI_AW-4600_FX,TIGER-SPCT1':U
run filwrlib_append-new-line in this-procedure ( input "&global-define scales-type {&scales-type}" ).
&GLOB scales-pr 'exe/lp15s.exe,exe/lp15s.exe,exe/hcns.exe,exe/hczs.exe,exe/hcts.exe,exe/lp485s.exe,exe/scalex.exe,exe/bzbs.exe,exe/digis.exe,exe/lp16s.exe,exe/metos.exe,exe/miras.exe,exe/meto2s.exe,exe/lp16xs.exe,,,exe/shtrih.exe,exe/lp16s.exe,exe/cl5000js.exe,exe/cl5000s.exe,,':U
run filwrlib_append-new-line in this-procedure ( input "&global-define scales-pr {&scales-pr}" ).

&glob struct-scales-list '~
CAS_lp-16x~
,DIGI-SM~
,CAS_CL5000J~
,CAS_CL5000~
,TIGER-SPCT2~
,TIGER-SPCT1~
,CAS_LP-15~
,SHTRIH-M~
,CAS_LP-15v1.6~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define struct-scales-list {&struct-scales-list}" ).

&glob pg-scales-list '~
DIGI-SM~
,CAS_CL5000J~
,CAS_CL5000~
,TIGER-SPCT1~
,TIGER-SPCT2~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define pg-scales-list {&pg-scales-list}" ).


&glob struct-attr-list '~
{&bef-attr-8x50}~
,{&bef-attr-15x80}~
,{&bef-attr-6x50}~
,{&bef-attr-6x50}~
,{&bef-attr-8x50}~
,{&bef-attr-8x50}~
,{&bef-attr-8x50}~
,{&bef-attr-8x50}~
,{&bef-attr-8x50}~
':U
run filwrlib_append-new-line in this-procedure ( input "&global-define struct-attr-list {&struct-attr-list}" ).

&glob struct-attr-code entry (lookup (~~~~~~~{&this-scales-type}, {&struct-scales-list}), {&struct-attr-list})

run filwrlib_append-new-line in this-procedure ( input "&global-define struct-attr-code {&struct-attr-code}" ).




/* Тип пункта и места доставки-приемки-отгрузки */
{ cmp/cr-prep.i 1 place-in    "приемки "   " "  "inc"  " " }
{ cmp/cr-prep.i 1 place-out   "отгрузки"  " "   "exp"  " " }
{ cmp/cr-prep.i 1 point-in    "доставки"   " "  "inc"  " " }
{ cmp/cr-prep.i 1 point-out   "отгрузки"  " "   "exp"  " " }

{ cmp/cr-prep.i 1 place-io-reference            "справочник мест отгрузки\приемки"     " " place-io-reference            }
{ cmp/cr-prep.i 1 point-io-reference            "справочник пунктов отгрузки\доставки"     " " point-io-reference            }

{ cmp/cr-prep.i 1 income-few-tanks  "приход топлива в несколько резервуаров"    " "   "income to the few tanks" }

/* Условия предост. транспортных услуг */
{ cmp/cr-prep.i 1 transport-include   0  "Доставка включена"                      0 transport-include }
{ cmp/cr-prep.i 1 transport-prc       1  "Доставка за процент стоимости"          1 transport-prc     }
{ cmp/cr-prep.i 1 transport-dist      2  "Сумма доставки зависит от расстояния "  2 transport-dist    }

{ cmp/cr-prep.i 1 auto   "auto"    " " "auto" }
{ cmp/cr-prep.i 1 manual "manual"  " " "manual" }
{ cmp/cr-prep.i 1 query  "query"   " " "query" }
{ cmp/cr-prep.i 1 reply  "reply"   " " "reply" }
{ cmp/cr-prep.i 1 ready-ready  "ready"   " " "ready" }
{ cmp/cr-prep.i 1 error  "error"   " " "error" }

{ cmp/cr-prep.i 1 xml-ntype-element       1  Элемент                          1 ElementNode }
{ cmp/cr-prep.i 1 xml-ntype-text          3  Текст                            3 Text }
{ cmp/cr-prep.i 1 xml-ntype-doc-type      2  ТипДокумента                     2 DocumentType }
{ cmp/cr-prep.i 1 xml-ntype-doc-fragment  4  ЧастьДокумента                   4 DocumentFragment }
{ cmp/cr-prep.i 1 xml-ntype-entity-ref    5  Ссылка                           5 EntityReference }
{ cmp/cr-prep.i 1 xml-ntype-attribute     6  Атрибут                          6 Attribute }
{ cmp/cr-prep.i 1 xml-ntype-cdata         7  CDATA                            7 CDATA }
{ cmp/cr-prep.i 1 xml-ntype-comment       8  Комментарий                      8 Comment }
{ cmp/cr-prep.i 1 xml-ntype-instruction   9 Инструкция                        9 ProcessInstruction }

&glob xml-ntype-list '{&bef-xml-ntype-element},~
{&bef-xml-ntype-text},~
{&bef-xml-ntype-doc-type},~
{&bef-xml-ntype-doc-fragment},~
{&bef-xml-ntype-entity-ref},~
{&bef-xml-ntype-attribute},~
{&bef-xml-ntype-cdata},~
{&bef-xml-ntype-comment},~
{&bef-xml-ntype-instruction}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define xml-ntype-list {&xml-ntype-list}" ).

&glob xml-ntype-list-full '~
{&bef-xml-ntype-element-full}~
,{&bef-xml-ntype-text-full}~
,{&bef-xml-ntype-doc-type-full}~
,{&bef-xml-ntype-doc-fragment-full}~
,{&bef-xml-ntype-entity-ref-full}~
,{&bef-xml-ntype-attribute-full}~
,{&bef-xml-ntype-cdata-full}~
,{&bef-xml-ntype-comment-full}~
,{&bef-xml-ntype-instruction-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define xml-ntype-list-full {&xml-ntype-list-full}" ).

&glob xml-ntype-name entry (lookup (~~~~~~~{&xml-ntype-code}, {&xml-ntype-list}) + 1, ',':U + {&xml-ntype-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define xml-ntype-name {&xml-ntype-name}" ).

&GLOB hist-to-nws   'hist-to-nws'
run filwrlib_append-new-line in this-procedure ( input "&global-define hist-to-nws {&hist-to-nws}" ).
&GLOB nws-to-hist   'nws-to-hist'
run filwrlib_append-new-line in this-procedure ( input "&global-define nws-to-hist {&nws-to-hist}" ).
&GLOB hist-from-prim   'hist-from-prim'
run filwrlib_append-new-line in this-procedure ( input "&global-define hist-from-prim {&hist-from-prim}" ).
&GLOB nws-to-cd   'nws-to-cd'
run filwrlib_append-new-line in this-procedure ( input "&global-define nws-to-cd {&nws-to-cd}" ).
&GLOB smart-nws   'smart-nws'
run filwrlib_append-new-line in this-procedure ( input "&global-define smart-nws {&smart-nws}" ).



{ cmp/cr-prep.i 1 hn-is-on               0   Да                          0  Yes }
{ cmp/cr-prep.i 1 hn-is-smart2           1   Смарт2                      1  Smart2 }
{ cmp/cr-prep.i 1 hn-is-off              -1  Нет                        -1  No }
{ cmp/cr-prep.i 1 hn-is-on-blocked       10  Всегда                     10 ALWAYS }
{ cmp/cr-prep.i 1 hn-is-off-blocked      -10 Никогда                    -10 NEVER }

&glob hn-option-val-codes '{&bef-hn-is-on}~
,{&bef-hn-is-off}~
,{&bef-hn-is-smart2}~
,{&bef-hn-is-on-blocked}~
,{&bef-hn-is-off-blocked}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define hn-option-val-codes {&hn-option-val-codes}" ).

&glob hn-option-val-codes-full '{&bef-hn-is-on-full}~
,{&bef-hn-is-off-full}~
,{&bef-hn-is-smart2-full}~
,{&bef-hn-is-on-blocked-full}~
,{&bef-hn-is-off-blocked-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define hn-option-val-codes-full {&hn-option-val-codes-full}" ).


&glob hn-option-val-codes-to-change-full '{&bef-hn-is-on-full}~
,{&bef-hn-is-off-full}~
,{&bef-hn-is-smart2-full}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define hn-option-val-codes-to-change-full {&hn-option-val-codes-to-change-full}" ).


&glob hn-option-val-name entry (lookup (~~~~~~~{&hn-option-val-code}, {&hn-option-val-codes}) + 1, ',' + {&hn-option-val-codes-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-option-val-name {&hn-option-val-name}" ).


&glob hn-option-radio-buttons '{&bef-hn-is-on-blocked-full},{&bef-hn-is-on-blocked}~
,{&bef-hn-is-on-full},{&bef-hn-is-on}~
,{&bef-hn-is-off-full},{&bef-hn-is-off}~
,{&bef-hn-is-smart2-full},{&bef-hn-is-smart2}~
,{&bef-hn-is-off-blocked-full},{&bef-hn-is-off-blocked}~
':U


run filwrlib_append-new-line in this-procedure ( input "&global-define hn-option-radio-buttons {&hn-option-radio-buttons}" ).


{ cmp/cr-prep.i 1 season      "Справочник сезонов"      " " season        }
{ cmp/cr-prep.i 1 collection  "Справочник коллекций"    " " collection    }
{ cmp/cr-prep.i 1 assort-matr "Ассортиментная матрица"  " " assort-matr   }
{ cmp/cr-prep.i 1 assort-min  "Ассортиментный минимум"  " " assort-min    }
{ cmp/cr-prep.i 1 ABC-XYZ     "Анализ ABC и XYZ"        " " ABC-XYZ       }
{ cmp/cr-prep.i 1 price-type  "Справочник типов прайс-листов"        " " price-type       }
{ cmp/cr-prep.i 1 dfc         "Документ назначения цены"           " " dfc              }

/*subject-group в hist-nws-option */
&glob hn-subject-group-codes '{&bef-table_goods}~
,{&bef-table_clients}~
,{&bef-table_cash-pay}~
,{&bef-table_cash-desk}~
,{&bef-table_ext-classif}~
,{&bef-table_contract-specif}~
':U

run filwrlib_append-new-line in this-procedure ( input "&global-define hn-subject-group-codes {&hn-subject-group-codes}" ).

&glob hn-subject-group-codes-full '{&bef-table_goods-full}~
,{&bef-table_clients-full}~
,{&bef-table_cash-pay-full}~
,{&bef-table_cash-desk-full}~
,{&bef-table_ext-classif-full}~
,{&bef-table_contract-specif-full}~
':U


run filwrlib_append-new-line in this-procedure ( input "&global-define hn-subject-group-codes-full {&hn-subject-group-codes-full}" ).


&glob hn-subject-group-name entry (lookup (~~~~~~~{&hn-subject-group-code}, {&hn-subject-group-codes}) + 1, ',' + {&hn-subject-group-codes-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define hn-subject-group-name {&hn-subject-group-name}" ).


/*скидки на товар*/

/*1=IBM,NCR-GM,IBM-XML,NCR-AS@R,MARIA*/
{ cmp/cr-prep.i 1 dgr-std-disc            std-disc    "Стандартная скидка" std-disc  "Standard discount"   }
/*2=MARIA*/
{ cmp/cr-prep.i 1 dgr-abs-disc            abs-disc    "Абсолютная скидка"  abs-disc  "Absolute discount"   }
/*39=MARIA*/
{ cmp/cr-prep.i 1 dgr-pcnt-tot            pcnt-tot    "% скидка c суммы"   pcnt-tot  "% discount from sum"   }
/*22=IBM;28=IBM-XML;29=NCR-GM,NCR-AS@R*/
{ cmp/cr-prep.i 1 dgr-temp-disc           temp-disc   "Временная скидка"   temp-disc  "Time discount"   }
/*8=IBM,IBM-XML;33=NCR-AS@R;34=IBM,IBM-XML*/
{ cmp/cr-prep.i 1 dgr-pcnt-kat            pcnt-kat    "Категорийная скидка"  pcnt-kat  "Kategory discount"   }
/*5=IBM,IBM-XML;25=NCR-GM,NCR-AS@R*/
{ cmp/cr-prep.i 1 dgr-pcnt-qnty           pcnt-qnty   "Количественная скидка"  pcnt-qnty "Quantuty discount"   }
/*27=NCR-GM,NCR-AS@R*/
{ cmp/cr-prep.i 1 dgr-pcnt-date           pcnt-date   "Скидка по дате"        pcnt-date "Date discount"   }
/*55=NCR-GSM,NCR-AS@R,IBM-XML*/
{ cmp/cr-prep.i 1 dgr-without-disc        without-disc  "Запрет на участие в бонусных программах\участие в скидке на итог" without-disc "Exclude from Subtot Discount" }
/*56=IBM-XML*/
{ cmp/cr-prep.i 1 dgr-without-gds-disc    without-gds-disc  "Запрет скидки на товар" without-gds-disc "Discount prohibition"   }
/*66=*/
{ cmp/cr-prep.i 1 dgr-dis-tot-flag        dis-tot-flag  "Участие в итогах по ДК" dis-tot-flag "DC TOTALs participant"   }
/*68=*/
{ cmp/cr-prep.i 1 dgr-max-disc            max-disc      "Порог max скидки на товар" max-disc "Max discnt value"   }
/*91=NCR-AS@R*/
{ cmp/cr-prep.i 1 dgr-bonus-qnty           bonus-qnty   "Начисление бонусов на кол-во товара"  bonus-qnty "Quantuty bonus"   }



&glob disgdsru-list '{&bef-dgr-std-disc}~
,{&bef-dgr-abs-disc}~
,{&bef-dgr-pcnt-tot}~
,{&bef-dgr-temp-disc}~
,{&bef-dgr-pcnt-kat}~
,{&bef-dgr-pcnt-qnty}~
,{&bef-dgr-pcnt-date}~
,{&bef-dgr-without-disc}~
,{&bef-dgr-without-gds-disc}~
,{&bef-dgr-dis-tot-flag}~
,{&bef-dgr-max-disc}~
,{&bef-dgr-bonus-qnty}~
':u
run filwrlib_append-new-line in this-procedure ( input "&global-define disgdsru-list {&disgdsru-list}" ).
&glob disgdsru-list-full '{&bef-dgr-std-disc-full}~
,{&bef-dgr-abs-disc-full}~
,{&bef-dgr-pcnt-tot-full}~
,{&bef-dgr-temp-disc-full}~
,{&bef-dgr-pcnt-kat-full}~
,{&bef-dgr-pcnt-qnty-full}~
,{&bef-dgr-pcnt-date-full}~
,{&bef-dgr-without-disc-full}~
,{&bef-dgr-without-gds-disc-full}~
,{&bef-dgr-dis-tot-flag-full}~
,{&bef-dgr-max-disc-full}~
,{&bef-dgr-bonus-qnty-full}~
':u
run filwrlib_append-new-line in this-procedure ( input "&global-define disgdsru-list-full {&disgdsru-list-full}" ).


&glob dis-gds-rule-name entry (lookup (~~~~~~~{&dis-gds-rule-code}, {&disgdsru-list}) + 1, ',' + {&disgdsru-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define dis-gds-rule-name {&dis-gds-rule-name}" ).


/*20=IBM,IBM-XML,NCR-AS@R;31=R-KEEPER;35=NCR-AS@R;51=MARIA;53=IBM;54=IBM-XML*/
{ cmp/cr-prep.i 1 dthbjr-pcnt-tot-kateg    pcnt-tot-kateg  "% Скидка на итог" pcnt-tot-kateg  "% Subtotal discount"   }
/*22=IBM;28=IBM-XML;29=NCR-GM,NCR-AS@R*/
{ cmp/cr-prep.i 1 dthbjr-dflt-gds-temp-disc dflt-gds-temp-disc  "Временная скидка на товар по умолчанию" dflt-gds-temp-disc  "Dflt item time discount"   }
/*21=*/
{ cmp/cr-prep.i 1 dthbjr-abs-tot-kateg    abs-tot-kateg    "Abs Скидка на итог" abs-tot-kateg  "Abs Subtotal discount"   }
/*26=NCR-GM,NCR-AS@R*/
{ cmp/cr-prep.i 1 dthbjr-pcnt-codes       pcnt-codes       "Коды % скидок" pcnt-codes  "% Discount Codes"   }
/*79=MAGIA*/
{ cmp/cr-prep.i 1 dthbjr-kateg-codes       kateg-codes       "Коды категорий" kateg-codes  "Category Codes"   }

/*50=MARIA*/
{ cmp/cr-prep.i 1 dthbjr-free-discnt-flag free-discnt-flag "Флаг своб.скидки" free-discnt-flag  "Free Discount Flag"   }
/*52=MARIA*/
{ cmp/cr-prep.i 1 dthbjr-pmnt-discnt-flag pmnt-discnt-flag "Флаг уст. скидки на платеж" pmnt-discnt-flag  "Pmnt Discount Flag"   }

/*37=NCR-AS@R*/
{ cmp/cr-prep.i 1 dthbjr-kat-gds-grp   kat-gds-grp "Ск-ка на группу товаров для кат.клиентов" kat-gds-grp  "Group discnt for Clients"   }

/*81=IBM 83 84*/
{ cmp/cr-prep.i 1 dthbjr-temp-disc-pdf temp-disc-pdf "Временная через ТПЛ" temp-disc-pdf  "Time Discnt from PDF"   }

/*87=IBM*/
{ cmp/cr-prep.i 1 dthbjr-pcnt-kat-pdf pcnt-kat-pdf "Категорийная через ТПЛ" pcnt-kat-pdf  "Cftegory Discnt from PDF"   }
/*90=NCR-AS@R*/
{ cmp/cr-prep.i 1 dthbjr-bonus-tot           bonus-tot   "Начисление бонусов на сумму чека"  bonus-tot "Total bonus"   }
/*92=NCR-AS@R*/
{ cmp/cr-prep.i 1 dthbjr-bonus-all           bonus-all   "Правило-итого бонусов по чеку"  bonus-all "All bonus"   }




&glob dthbjr-list '{&bef-dthbjr-pcnt-tot-kateg}~
,{&bef-dthbjr-dflt-gds-temp-disc}~
,{&bef-dthbjr-abs-tot-kateg}~
,{&bef-dthbjr-pcnt-codes}~
,{&bef-dthbjr-kateg-codes}~
,{&bef-dthbjr-free-discnt-flag}~
,{&bef-dthbjr-pmnt-discnt-flag}~
,{&bef-dthbjr-kat-gds-grp}~
,{&bef-dthbjr-temp-disc-pdf}~
,{&bef-dthbjr-pcnt-kat-pdf}~
,{&bef-dthbjr-bonus-tot}~
,{&bef-dthbjr-bonus-all}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define dthbjr-list {&dthbjr-list}" ).

&glob dthbjr-list-full '{&bef-dthbjr-pcnt-tot-kateg-full}~
,{&bef-dthbjr-dflt-gds-temp-disc-full}~
,{&bef-dthbjr-abs-tot-kateg-full}~
,{&bef-dthbjr-pcnt-codes-full}~
,{&bef-dthbjr-kateg-codes-full}~
,{&bef-dthbjr-free-discnt-flag-full}~
,{&bef-dthbjr-pmnt-discnt-flag-full}~
,{&bef-dthbjr-kat-gds-grp-full}~
,{&bef-dthbjr-temp-disc-pdf-full}~
,{&bef-dthbjr-pcnt-kat-pdf-full}~
,{&bef-dthbjr-bonus-tot-full}~
,{&bef-dthbjr-bonus-all-full}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define dthbjr-list-full {&dthbjr-list-full}" ).

&glob dis-thbj-rule-name entry (lookup (~~~~~~~{&dis-thbj-rule-code}, {&dthbjr-list}) + 1, ',' + {&dthbjr-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define dis-thbj-rule-name {&dis-thbj-rule-name}" ).

/*42=IBM,IBM-XML,MARIA;43=IBM,IBX-XML,MARIA;44=MARIA;45=MARIA;73=IBM-XML;74=IBM-XML*/
{ cmp/cr-prep.i 1 dcpr-simple-pay   simple-pay  "Скидка при оплате" simple-pay  "Pay discount"   }

{ cmp/cr-prep.i 1 dcpr-qnty-pay   qnty-pay  "Скидка на количество при оплате" qnty-pay  "Qnty Pay Discount"   }

&glob dcpr-list '{&bef-dcpr-simple-pay}~
,{&bef-dcpr-qnty-pay}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define dcpr-list {&dcpr-list}" ).

&glob dcpr-list-full '{&bef-dcpr-simple-pay-full}~
,{&bef-dcpr-qnty-pay-full}~
':u

run filwrlib_append-new-line in this-procedure ( input "&global-define dcpr-list-full {&dcpr-list-full}" ).

&glob dis-cp-rule-name entry (lookup (~~~~~~~{&dis-cp-rule-code}, {&dcpr-list}) + 1, ',' + {&dcpr-list-full})
run filwrlib_append-new-line in this-procedure ( input "&global-define dis-cp-rule-name {&dis-cp-rule-name}" ).



/* атрибуты ТПЛ */
{ cmp/cr-prep.i 1 typeprice_ie-gen-marg         ie-gen-marg        " "  ie-gen-marg  }
{ cmp/cr-prep.i 1 typeprice_ie-gen-marg-parts   ie-gen-marg-parts  " "  ie-gen-marg-parts  }
{ cmp/cr-prep.i 1 typeprice_ie-objfirst         ie-objfirst        " "  ie-objfirst  }
{ cmp/cr-prep.i 1 typeprice_ie-objsecond        ie-objsecond       " "  ie-objsecond }
{ cmp/cr-prep.i 1 typeprice_ie-pr-nakl          ie-pr-nakl         " "  ie-pr-nakl   }
{ cmp/cr-prep.i 1 typeprice_iv-gen-marg         iv-gen-marg        " "  iv-gen-marg  }
{ cmp/cr-prep.i 1 typeprice_iv-gen-marg-parts   iv-gen-marg-parts  " "  iv-gen-marg-parts  }
{ cmp/cr-prep.i 1 typeprice_iv-objfirst         iv-objfirst        " "  iv-objfirst  }
{ cmp/cr-prep.i 1 typeprice_iv-objsecond        iv-objsecond       " "  iv-objsecond }
{ cmp/cr-prep.i 1 typeprice_iv-pr-nakl          iv-pr-nakl         " "  iv-pr-nakl   }
{ cmp/cr-prep.i 1 typeprice_im-gen-marg         im-gen-marg        " "  im-gen-marg  }
{ cmp/cr-prep.i 1 typeprice_im-gen-marg-parts   im-gen-marg-parts  " "  im-gen-marg-parts  }
{ cmp/cr-prep.i 1 typeprice_im-objfirst         im-objfirst        " "  im-objfirst  }
{ cmp/cr-prep.i 1 typeprice_im-objsecond        im-objsecond       " "  im-objsecond }
{ cmp/cr-prep.i 1 typeprice_im-pr-nakl          im-pr-nakl         " "  im-pr-nakl   }


{ cmp/cr-prep.i 1 typeprice_no-margin           no-margin          " "  no-margin  }
{ cmp/cr-prep.i 1 typeprice_before-margin       before-margin      " "  before-margin  }
{ cmp/cr-prep.i 1 typeprice_after-margin        after-margin       " "  after-margin  }


run filwrlib_num-lines-get in this-procedure
  (output p-num-lines
  ) .