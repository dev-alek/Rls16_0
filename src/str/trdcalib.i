/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Ссылка на библиотеку для работы с атрибутами документа

Автор: Чернова Светлана Александровна
Дата создания: 12/13/06
Author: Svetlana Chernova
Creation date: 12/13/06

create: Булгаков Андрей Николаевич
Дата создания: 04/12/05

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if defined( include_trdcalib ) = 0 &then

&glob type-trdcattr-hold-part-code {&type-int}
&glob format-trdcattr-hold-part-code "->>>,>>>,>>9"
&glob fillin_width-trdcattr-hold-part-code 12
&glob fillin_height-trdcattr-hold-part-code 1
&glob label-trdcattr-hold-part-code "Номер партии для документа межфирменного перемещения"
&glob tooltip-trdcattr-hold-part-code "Номер партии для документа межфирменного перемещения"
&glob user-can-edit-trdcattr-hold-part-code false
&glob output-display-trdcattr-hold-part-code false
&glob other-trdcattr-hold-part-code '':u
&glob news-trdcattr-hold-part-code true
&glob sort-trdcattr-hold-part-code 100

/* Доверенность */
&glob fillin_width-trdcattr-dov 70
&glob fillin_height-trdcattr-dov 3
&glob type-trdcattr-dov {&type-char}
&glob format-trdcattr-dov "x(255)"
&glob label-trdcattr-dov "Доверенность"
&glob tooltip-trdcattr-dov "Доверенность"
&glob user-can-edit-trdcattr-dov true
&glob output-display-trdcattr-dov true
&glob other-trdcattr-dov '':u
&glob news-trdcattr-dov true
&glob sort-trdcattr-dov 45

/* Дата приходной накладной поставщика */
&glob fillin_width-trdcattr-dids 11
&glob fillin_height-trdcattr-dids 1
&glob type-trdcattr-dids {&type-date}
&glob format-trdcattr-dids "99/99/9999"
&glob label-trdcattr-dids "Дата приходной накладной поставщика"
&glob tooltip-trdcattr-dids "Дата приходной накладной поставщика"
&glob user-can-edit-trdcattr-dids true
&glob output-display-trdcattr-dids true
&glob other-trdcattr-dids 'nws':u
&glob news-trdcattr-dids true
&glob sort-trdcattr-dids 100

/* Номер приходной накладной поставщика */
&glob fillin_width-trdcattr-nids 71
&glob fillin_height-trdcattr-nids 1
&glob type-trdcattr-nids {&type-char}
&glob format-trdcattr-nids "x(70)"
&glob label-trdcattr-nids "Номер приходной накладной поставщика"
&glob tooltip-trdcattr-nids "Номер приходной накладной поставщика"
&glob user-can-edit-trdcattr-nids true
&glob output-display-trdcattr-nids true
&glob other-trdcattr-nids 'nws':u
&glob news-trdcattr-nids true
&glob sort-trdcattr-nids 100

/* Номер приходной накладной ЕГАИС */
&glob fillin_width-trdcattr-negais 71
&glob fillin_height-trdcattr-negais 1
&glob type-trdcattr-negais {&type-char}
&glob format-trdcattr-negais "x(70)"
&glob label-trdcattr-negais "Идентификаторы накладной ЕГАИС"
&glob tooltip-trdcattr-negais "Идентификаторы накладной ЕГАИС"
&glob user-can-edit-trdcattr-negais true
&glob output-display-trdcattr-negais true
&glob other-trdcattr-negais 'nws':u
&glob news-trdcattr-negais true
&glob sort-trdcattr-negais 100

/* Статус ЕГАИС */
&glob type-trdcattr-egais {&type-char}
&glob format-trdcattr-egais "x(11)"
&glob fillin_width-trdcattr-egais 10
&glob fillin_height-trdcattr-egais 1
&glob label-trdcattr-egais "Статус EGAIS"
&glob tooltip-trdcattr-egais "Статус EGAIS"
&glob user-can-edit-trdcattr-egais  false
&glob output-display-trdcattr-egais false
&glob other-trdcattr-egais '':u
&glob news-trdcattr-egais true
&glob sort-trdcattr-egais 100

/* Счет-фактура поставщика: Дата */
&glob fillin_width-trdcattr-dsf 11
&glob fillin_height-trdcattr-dsf 1
&glob type-trdcattr-dsf {&type-date}
&glob format-trdcattr-dsf "99/99/9999"
&glob label-trdcattr-dsf "Счет-фактура поставщика: Дата"
&glob tooltip-trdcattr-dsf "Счет-фактура поставщика: Дата"
&glob user-can-edit-trdcattr-dsf true
&glob output-display-trdcattr-dsf true
&glob other-trdcattr-dsf 'nws':u
&glob news-trdcattr-dsf true
&glob sort-trdcattr-dsf 70

/* Счет-фактура поставщика: Номер */
&glob fillin_width-trdcattr-nsf 71
&glob fillin_height-trdcattr-nsf 1
&glob type-trdcattr-nsf {&type-char}
&glob format-trdcattr-nsf "x(70)"
&glob label-trdcattr-nsf "Счет-фактура поставщика: Номер"
&glob tooltip-trdcattr-nsf "Счет-фактура поставщика: Номер"
&glob user-can-edit-trdcattr-nsf true
&glob output-display-trdcattr-nsf true
&glob other-trdcattr-nsf 'nws':u
&glob news-trdcattr-nsf true
&glob sort-trdcattr-nsf 75

/* Договор: Дата */
&glob fillin_width-trdcattr-ddog 11
&glob fillin_height-trdcattr-ddog 1
&glob type-trdcattr-ddog {&type-date}
&glob format-trdcattr-ddog "99/99/9999"
&glob label-trdcattr-ddog "Договор: Дата"
&glob tooltip-trdcattr-ddog "Договор: Дата"
&glob user-can-edit-trdcattr-ddog true
&glob output-display-trdcattr-ddog true
&glob other-trdcattr-ddog 'nws':u
&glob news-trdcattr-ddog true
&glob sort-trdcattr-ddog 30

/* Договор: Номер */
&glob fillin_width-trdcattr-ndog 71
&glob fillin_height-trdcattr-ndog 1
&glob type-trdcattr-ndog {&type-char}
&glob format-trdcattr-ndog "x(70)"
&glob label-trdcattr-ndog "Договор: Номер"
&glob tooltip-trdcattr-ndog "Договор: Номер"
&glob user-can-edit-trdcattr-ndog true
&glob output-display-trdcattr-ndog true
&glob other-trdcattr-ndog 'nws':u
&glob news-trdcattr-ndog true
&glob sort-trdcattr-ndog 40

/* Расчетный документ: Дата */
&glob fillin_width-trdcattr-dfindoc 11
&glob fillin_height-trdcattr-dfindoc 1
&glob type-trdcattr-dfindoc {&type-date}
&glob format-trdcattr-dfindoc "99/99/9999"
&glob label-trdcattr-dfindoc "Расчетный документ: Дата"
&glob tooltip-trdcattr-dfindoc "Расчетный документ: Дата"
&glob user-can-edit-trdcattr-dfindoc true
&glob output-display-trdcattr-dfindoc true
&glob other-trdcattr-dfindoc 'nws':u
&glob news-trdcattr-dfindoc true
&glob sort-trdcattr-dfindoc 60

/* Расчетный документ: Номер */
&glob fillin_width-trdcattr-nfindoc 71
&glob fillin_height-trdcattr-nfindoc 1
&glob type-trdcattr-nfindoc {&type-char}
&glob format-trdcattr-nfindoc "x(70)"
&glob label-trdcattr-nfindoc "Расчетный документ: Номер"
&glob tooltip-trdcattr-nfindoc "Расчетный документ: Номер"
&glob user-can-edit-trdcattr-nfindoc true
&glob output-display-trdcattr-nfindoc true
&glob other-trdcattr-nfindoc 'nws':u
&glob news-trdcattr-nfindoc true
&glob sort-trdcattr-nfindoc 65

/* Виды дополнительной информации по документу, содержащейся в таблицах trn-doc-sum, doc-line-sum */
&glob fillin_width-trdcattr-addsum 255
&glob fillin_height-trdcattr-addsum 1
&glob type-trdcattr-addsum {&type-char}
&glob format-trdcattr-addsum "x(70)"
&glob label-trdcattr-addsum "Дополнительные суммы посчитанные по документу"
&glob tooltip-trdcattr-addsum "Дополнительные суммы посчитанные по документу"
&glob user-can-edit-trdcattr-addsum false
&glob output-display-trdcattr-addsum false
&glob other-trdcattr-addsum '':u
&glob news-trdcattr-addsum true
&glob sort-trdcattr-addsum 100

/* On-line расчет дополнительных сумм основных и после документа */
&glob fillin_width-trdcattr-clcasol 3
&glob fillin_height-trdcattr-clcasol 1
&glob type-trdcattr-clcasol {&type-log}
&glob format-trdcattr-clcasol "yes/no"
&glob label-trdcattr-clcasol "On-line расчет дополнительных сумм основных и после документа"
&glob tooltip-trdcattr-clcasol "On-line расчет дополнительных сумм основных и после документа"
&glob user-can-edit-trdcattr-clcasol false
&glob output-display-trdcattr-clcasol false
&glob other-trdcattr-clcasol '':u
&glob news-trdcattr-clcasol true
&glob sort-trdcattr-clcasol 100

/* On-line расчет естественной убыли */
&glob fillin_width-trdcattr-clcaswt 3
&glob fillin_height-trdcattr-clcaswt 1
&glob type-trdcattr-clcaswt {&type-log}
&glob format-trdcattr-clcaswt "yes/no"
&glob label-trdcattr-clcaswt "On-line расчет естественной убыли"
&glob tooltip-trdcattr-clcaswt "On-line расчет естественной убыли"
&glob user-can-edit-trdcattr-clcaswt false
&glob output-display-trdcattr-clcaswt false
&glob other-trdcattr-clcaswt '':u
&glob news-trdcattr-clcaswt true
&glob sort-trdcattr-clcaswt 100

/* Загруженные в документ сканерные файлы */
&glob fillin_width-trdcattr-scanfile 3
&glob fillin_height-trdcattr-scanfile 1
&glob type-trdcattr-scanfile {&type-log}
&glob format-trdcattr-scanfile "yes/no"
&glob label-trdcattr-scanfile "Загруженные в документ сканерные файлы"
&glob tooltip-trdcattr-scanfile "Загруженные в документ сканерные файлы"
&glob user-can-edit-trdcattr-scanfile false
&glob output-display-trdcattr-scanfile true
&glob other-trdcattr-scanfile '':u
&glob news-trdcattr-scanfile true
&glob sort-trdcattr-scanfile 100

/* Заводить внешнюю приходную накладную через суммы */
&glob fillin_width-trdcattr-indoclnsum 3
&glob fillin_height-trdcattr-indoclnsum 1
&glob type-trdcattr-indoclnsum {&type-log}
&glob format-trdcattr-indoclnsum "yes/no"
&glob label-trdcattr-indoclnsum "Заводить внешнюю приходную накладную через суммы"
&glob tooltip-trdcattr-indoclnsum "Заводить внешнюю приходную накладную через суммы"
&glob user-can-edit-trdcattr-indoclnsum false
&glob output-display-trdcattr-indoclnsum false
&glob other-trdcattr-indoclnsum '':u
&glob news-trdcattr-indoclnsum true
&glob sort-trdcattr-indoclnsum 100

/* Ограничение по типам приобретения */
&glob fillin_width-trdcattr-purchlimit 3
&glob fillin_height-trdcattr-purchlimit 1
&glob type-trdcattr-purchlimit {&type-log}
&glob format-trdcattr-purchlimit "yes/no"
&glob label-trdcattr-purchlimit "Есть в документе ограничение по типам кодов приобретения для резервирования"
&glob tooltip-trdcattr-purchlimit "Есть в документе ограничение по типам кодов приобретения для резервирования"
&glob user-can-edit-trdcattr-purchlimit false
&glob output-display-trdcattr-purchlimit false
&glob other-trdcattr-purchlimit '':u
&glob news-trdcattr-purchlimit true
&glob sort-trdcattr-purchlimit 100

/* список кодов типов приобретения по документу */
&glob fillin_width-trdcattr-purchcodelist 3
&glob fillin_height-trdcattr-purchcodelist 1
&glob type-trdcattr-purchcodelist {&type-char}
&glob format-trdcattr-purchcodelist "x(70)"
&glob label-trdcattr-purchcodelist "Список кодов типов приобретения"
&glob tooltip-trdcattr-purchcodelist "Список кодов типов приобретения"
&glob user-can-edit-trdcattr-purchcodelist false
&glob output-display-trdcattr-purchcodelist false
&glob other-trdcattr-purchcodelist '':u
&glob news-trdcattr-purchcodelist true
&glob sort-trdcattr-purchcodelist 100

/* расходы не включаемые в учетную цену */
&glob fillin_width-trdcattr-expense_own 20
&glob fillin_height-trdcattr-expense_own 1
&glob type-trdcattr-expense_own {&type-dec}
&glob format-trdcattr-expense_own "->,>>>,>>>,>>9.999"
&glob label-trdcattr-expense_own "Расходы не включаемые в учетную цену"
&glob tooltip-trdcattr-expense_own "Расходы не включаемые в учетную цену"
&glob user-can-edit-trdcattr-expense_own true
&glob output-display-trdcattr-expense_own true
&glob other-trdcattr-expense_own 'nws':u
&glob news-trdcattr-expense_own true
&glob sort-trdcattr-expense_own 100

/* Внутренний расход по цене приемника */
&glob type-trdcattr-price-target {&type-log}
&glob format-trdcattr-price-target "yes/no"
&glob fillin_width-trdcattr-price-target 4
&glob fillin_height-trdcattr-price-target 1
&glob label-trdcattr-price-target "Внутренний расход по цене приемника"
&glob tooltip-trdcattr-price-target "Внутренний расход по цене приемника"
&glob user-can-edit-trdcattr-price-target false
&glob output-display-trdcattr-price-target false
&glob other-trdcattr-price-target '':u
&glob news-trdcattr-price-target true
&glob sort-trdcattr-price-target 100

/* ЕНВД */
&glob fillin_width-trdcattr-envd   4
&glob fillin_height-trdcattr-envd  1
&glob type-trdcattr-envd           {&type-log}
&glob format-trdcattr-envd         "yes/no"
&glob label-trdcattr-envd          "Единый налог на вмененный доход"
&glob tooltip-trdcattr-envd        "Единый налог на вмененный доход"
&glob user-can-edit-trdcattr-envd  false
&glob output-display-trdcattr-envd true
&glob other-trdcattr-envd          '':u
&glob news-trdcattr-envd           true
&glob sort-trdcattr-envd           100

/* Допустимый % погрешности поставщика */
&glob fillin_width-trdcattr-acc-ship 20
&glob fillin_height-trdcattr-acc-ship 1
&glob type-trdcattr-acc-ship {&type-dec}
&glob format-trdcattr-acc-ship ">>9.99"
&glob label-trdcattr-acc-ship "Допустимый % погрешности поставщика"
&glob tooltip-trdcattr-acc-ship "Допустимый % погрешности поставщика"
&glob user-can-edit-trdcattr-acc-ship true
&glob output-display-trdcattr-acc-ship true
&glob other-trdcattr-acc-ship 'nws':u
&glob news-trdcattr-acc-ship true
&glob sort-trdcattr-acc-ship 100

/* Флористы */
/* Время выполнения заказа */
&glob fillin_width-trdcattr-ord_time 6
&glob fillin_height-trdcattr-ord_time 1
&glob type-trdcattr-ord_time {&type-char}
&glob format-trdcattr-ord_time "99:99"
&glob label-trdcattr-ord_time "Время выполнения заказа"
&glob tooltip-trdcattr-ord_time "Время выполнения заказа"
&glob user-can-edit-trdcattr-ord_time true
&glob output-display-trdcattr-ord_time true
&glob other-trdcattr-ord_time '':u
&glob news-trdcattr-ord_time true
&glob sort-trdcattr-ord_time 100

/* Сумма предоплаты */
&glob fillin_width-trdcattr-befpay 22
&glob fillin_height-trdcattr-befpay 1
&glob type-trdcattr-befpay {&type-dec}
&glob format-trdcattr-befpay "->,>>>,>>>,>>>,>>9.99"
&glob label-trdcattr-befpay "Сумма предоплаты"
&glob tooltip-trdcattr-befpay "Сумма предоплаты"
&glob user-can-edit-trdcattr-befpay true
&glob output-display-trdcattr-befpay true
&glob other-trdcattr-befpay '':u
&glob news-trdcattr-befpay true
&glob sort-trdcattr-befpay 100

/* № чека предоплаты */
&glob fillin_width-trdcattr-ord_Nchek 70
&glob fillin_height-trdcattr-ord_Nchek 1
&glob type-trdcattr-ord_Nchek {&type-char}
&glob format-trdcattr-ord_Nchek "x(70)"
&glob label-trdcattr-ord_Nchek "№ чека предоплаты"
&glob tooltip-trdcattr-ord_Nchek "№ чека предоплаты"
&glob user-can-edit-trdcattr-ord_Nchek true
&glob output-display-trdcattr-ord_Nchek true
&glob other-trdcattr-ord_Nchek '':u
&glob news-trdcattr-ord_Nchek true
&glob sort-trdcattr-ord_Nchek 100


/* Дата чека предоплаты */
&glob fillin_width-trdcattr-dchek 11
&glob fillin_height-trdcattr-dchek 1
&glob type-trdcattr-dchek {&type-date}
&glob format-trdcattr-dchek "99/99/9999"
&glob label-trdcattr-dchek "Дата чека предоплаты"
&glob tooltip-trdcattr-dchek "Дата чека предоплаты"
&glob user-can-edit-trdcattr-dchek true
&glob output-display-trdcattr-dchek true
&glob other-trdcattr-dchek '':u
&glob news-trdcattr-dchek true
&glob sort-trdcattr-dchek 100

/* Стоимость доставки */
&glob fillin_width-trdcattr-deliv 22
&glob fillin_height-trdcattr-deliv 1
&glob type-trdcattr-deliv {&type-dec}
&glob format-trdcattr-deliv "->,>>>,>>>,>>>,>>9.99"
&glob label-trdcattr-deliv "Сумма доставки (баз.вал.)"
&glob tooltip-trdcattr-deliv "Стоимость доставки"
&glob user-can-edit-trdcattr-deliv true
&glob output-display-trdcattr-deliv true
&glob other-trdcattr-deliv '':u
&glob news-trdcattr-deliv true
&glob sort-trdcattr-deliv 100

/* Наценка за работу */
&glob fillin_width-trdcattr-sumwrk 22
&glob fillin_height-trdcattr-sumwrk 1
&glob type-trdcattr-sumwrk {&type-dec}
&glob format-trdcattr-sumwrk "->,>>>,>>>,>>>,>>9.99"
&glob label-trdcattr-sumwrk "Наценка за работу,%"
&glob tooltip-trdcattr-sumwrk "Наценка за работу"
&glob user-can-edit-trdcattr-sumwrk true
&glob output-display-trdcattr-sumwrk true
&glob other-trdcattr-sumwrk '':u
&glob news-trdcattr-sumwrk true
&glob sort-trdcattr-sumwrk 100

/* Наценка за срочность */
&glob fillin_width-trdcattr-sumsrk 22
&glob fillin_height-trdcattr-sumsrk 1
&glob type-trdcattr-sumsrk {&type-dec}
&glob format-trdcattr-sumsrk "->,>>>,>>>,>>>,>>9.99"
&glob label-trdcattr-sumsrk "Наценка за срочность,%"
&glob tooltip-trdcattr-sumsrk "Наценка за срочность"
&glob user-can-edit-trdcattr-sumsrk true
&glob output-display-trdcattr-sumsrk true
&glob other-trdcattr-sumsrk '':u
&glob news-trdcattr-sumsrk true
&glob sort-trdcattr-sumsrk 100

/* Куда */
&glob fillin_width-trdcattr-ord_adr 70
&glob fillin_height-trdcattr-ord_adr 1
&glob type-trdcattr-ord_adr {&type-char}
&glob format-trdcattr-ord_adr "x(255)"
&glob label-trdcattr-ord_adr "Адрес доставки"
&glob tooltip-trdcattr-ord_adr "Почтовый адрес клиента"
&glob user-can-edit-trdcattr-ord_adr true
&glob output-display-trdcattr-ord_adr true
&glob other-trdcattr-ord_adr '':u
&glob news-trdcattr-ord_adr true
&glob sort-trdcattr-ord_adr 100

/* Кому */
&glob fillin_width-trdcattr-ord_hwo 70
&glob fillin_height-trdcattr-ord_hwo 1
&glob type-trdcattr-ord_hwo {&type-char}
&glob format-trdcattr-ord_hwo "x(255)"
&glob label-trdcattr-ord_hwo "Кому"
&glob tooltip-trdcattr-ord_hwo "Название клиента"
&glob user-can-edit-trdcattr-ord_hwo true
&glob output-display-trdcattr-ord_hwo true
&glob other-trdcattr-ord_hwo '':u
&glob news-trdcattr-ord_hwo true
&glob sort-trdcattr-ord_hwo 100


/* Код оператора документа производства */
&glob type-trdcattr-fbroperator {&type-int}
&glob format-trdcattr-fbroperator "->>>>>>>>9"
&glob fillin_width-trdcattr-fbroperator 10
&glob fillin_height-trdcattr-fbroperator 1
&glob label-trdcattr-fbroperator "Код оператора документа производства"
&glob tooltip-trdcattr-fbroperator "Код оператора документа производства"
&glob user-can-edit-trdcattr-fbroperator false
&glob output-display-trdcattr-fbroperator true
&glob other-trdcattr-fbroperator '':u
&glob news-trdcattr-fbroperator true
&glob sort-trdcattr-fbroperator 100

/* Документ создан автоматически (автопроизводство, план-меню, ... ) */
&glob fillin_width-trdcattr-fbrauto   4
&glob fillin_height-trdcattr-fbrauto  1
&glob type-trdcattr-fbrauto           {&type-log}
&glob format-trdcattr-fbrauto         "yes/no"
&glob label-trdcattr-fbrauto          "Документ создан автоматически"
&glob tooltip-trdcattr-fbrauto        "Документ создан автоматически"
&glob user-can-edit-trdcattr-fbrauto  false
&glob output-display-trdcattr-fbrauto true
&glob other-trdcattr-fbrauto          '':u
&glob news-trdcattr-fbrauto           true
&glob sort-trdcattr-fbrauto           100

/* Список документов для предпочтительного резервирования */
&glob type-trdcattr-rsrv-doc-list {&type-char}
&glob format-trdcattr-rsrv-doc-list "X(40)"
&glob fillin_width-trdcattr-rsrv-doc-list 42
&glob fillin_height-trdcattr-rsrv-doc-list 1
&glob label-trdcattr-rsrv-doc-list "Список документов по которым производилось резервирование"
&glob tooltip-trdcattr-rsrv-doc-list "Список документов по которым производилось резервирование"
&glob user-can-edit-trdcattr-rsrv-doc-list false
&glob output-display-trdcattr-rsrv-doc-list true
&glob other-trdcattr-rsrv-doc-list '':u
&glob news-trdcattr-rsrv-doc-list true
&glob sort-trdcattr-rsrv-doc-list 100

/* Сумма доплаты */
&glob fillin_width-trdcattr-postpay 22
&glob fillin_height-trdcattr-postpay 1
&glob type-trdcattr-postpay {&type-dec}
&glob format-trdcattr-postpay "->,>>>,>>>,>>>,>>9.99"
&glob label-trdcattr-postpay "Сумма доплаты"
&glob tooltip-trdcattr-postpay "Сумма доплаты"
&glob user-can-edit-trdcattr-postpay true
&glob output-display-trdcattr-postpay true
&glob other-trdcattr-postpay 'nws':u
&glob news-trdcattr-postpay true
&glob sort-trdcattr-postpay 100

/* № чека доплаты */
&glob fillin_width-trdcattr-postNchek 70
&glob fillin_height-trdcattr-postNchek 1
&glob type-trdcattr-postNchek {&type-char}
&glob format-trdcattr-postNchek "x(70)"
&glob label-trdcattr-postNchek "№ чека доплаты"
&glob tooltip-trdcattr-postNchek "№ чека доплаты"
&glob user-can-edit-trdcattr-postNchek true
&glob output-display-trdcattr-postNchek true
&glob other-trdcattr-postNchek 'nws':u
&glob news-trdcattr-postNchek true
&glob sort-trdcattr-postNchek 100


/* Дата чека доплаты */
&glob fillin_width-trdcattr-postdchek 14
&glob fillin_height-trdcattr-postdchek 1
&glob type-trdcattr-postdchek {&type-date}
&glob format-trdcattr-postdchek "99/99/9999"
&glob label-trdcattr-postdchek "Дата чека доплаты"
&glob tooltip-trdcattr-postdchek "Дата чека доплаты"
&glob user-can-edit-trdcattr-postdchek true
&glob output-display-trdcattr-postdchek true
&glob other-trdcattr-postdchek 'nws,postdchek':u
&glob news-trdcattr-postdchek true
&glob sort-trdcattr-postdchek 100

/* Дата выполнения запроса */
&glob fillin_width-trdcattr-frsrv-date 11
&glob fillin_height-trdcattr-frsrv-date 1
&glob type-trdcattr-frsrv-date {&type-date}
&glob format-trdcattr-frsrv-date "99/99/9999"
&glob label-trdcattr-frsrv-date "Дата выполнения "
&glob tooltip-trdcattr-frsrv-date "Срок выполнения заказа"
&glob user-can-edit-trdcattr-frsrv-date true
&glob output-display-trdcattr-frsrv-date true
&glob other-trdcattr-frsrv-date 'rsrv-date':u
&glob news-trdcattr-frsrv-date true
&glob sort-trdcattr-frsrv-date 100

/* Телефон контактный */
&glob fillin_width-trdcattr-ord_phone 70
&glob fillin_height-trdcattr-ord_phone 1
&glob type-trdcattr-ord_phone {&type-char}
&glob format-trdcattr-ord_phone "x(255)"
&glob label-trdcattr-ord_phone "Контактный телефон"
&glob tooltip-trdcattr-ord_phone "Контактный телефон"
&glob user-can-edit-trdcattr-ord_phone true
&glob output-display-trdcattr-ord_phone true
&glob other-trdcattr-ord_phone '':u
&glob news-trdcattr-ord_phone true
&glob sort-trdcattr-ord_phone 100

/* контактное лицо */
&glob fillin_width-trdcattr-ord_contact 70
&glob fillin_height-trdcattr-ord_contact 1
&glob type-trdcattr-ord_contact {&type-char}
&glob format-trdcattr-ord_contact "x(255)"
&glob label-trdcattr-ord_contact "Контактное лицо"
&glob tooltip-trdcattr-ord_contact "Контактное лицо"
&glob user-can-edit-trdcattr-ord_contact true
&glob output-display-trdcattr-ord_contact true
&glob other-trdcattr-ord_contact '':u
&glob news-trdcattr-ord_contact true
&glob sort-trdcattr-ord_contact 100


/* доставка есть ? */
&glob fillin_width-trdcattr-ord_dl 3
&glob fillin_height-trdcattr-ord_dl 1
&glob type-trdcattr-ord_dl {&type-log}
&glob format-trdcattr-ord_dl "yes/no"
&glob label-trdcattr-ord_dl "Требуется доставка"
&glob tooltip-trdcattr-ord_dl "Нужна ли доставка"
&glob user-can-edit-trdcattr-ord_dl true
&glob output-display-trdcattr-ord_dl true
&glob other-trdcattr-ord_dl '':u
&glob news-trdcattr-ord_dl true
&glob sort-trdcattr-ord_dl 100

&glob fillin_width-trdcattr-m-inc 3
&glob fillin_height-trdcattr-m-inc 1
&glob type-trdcattr-m-inc {&type-int}
&glob format-trdcattr-m-inc "99"
&glob label-trdcattr-m-inc "Метод включения транспортных и пр расходов в ПН"
&glob tooltip-trdcattr-m-inc "Метод включения транспортных и пр расходов в ПН"
&glob user-can-edit-trdcattr-m-inc no
&glob output-display-trdcattr-m-inc no
&glob other-trdcattr-m-inc '':u
&glob news-trdcattr-m-inc true
&glob sort-trdcattr-m-inc 100

/* Количество мест в РН */
&glob fillin_width-trdcattr-qntyplace 9
&glob fillin_height-trdcattr-qntyplace 1
&glob type-trdcattr-qntyplace {&type-int}
&glob format-trdcattr-qntyplace ">>>>>>9"
&glob label-trdcattr-qntyplace "Количество мест"
&glob tooltip-trdcattr-qntyplace "Количество мест"
&glob user-can-edit-trdcattr-qntyplace true
&glob output-display-trdcattr-qntyplace true
&glob other-trdcattr-qntyplace 'nws':u
&glob news-trdcattr-qntyplace true
&glob sort-trdcattr-qntyplace 100

&glob fillin_width-trdcattr-discnt-stop 3
&glob fillin_height-trdcattr-discnt-stop 1
&glob type-trdcattr-discnt-stop {&type-dec}
&glob format-trdcattr-discnt-stop "->>>>>>>>>>>>9.99"
&glob label-trdcattr-discnt-stop   "Сумма итого со скидкой наценкой и доставкой"
&glob tooltip-trdcattr-discnt-stop "Сумма итого со скидкой наценкой и доставкой"
&glob user-can-edit-trdcattr-discnt-stop false
&glob output-display-trdcattr-discnt-stop  false
&glob other-trdcattr-discnt-stop '':u
&glob news-trdcattr-discnt-stop true
&glob sort-trdcattr-discnt-stop 100

&glob fillin_width-trdcattr-discnt-other 3
&glob fillin_height-trdcattr-discnt-other 1
&glob type-trdcattr-discnt-other {&type-log}
&glob format-trdcattr-discnt-other  "yes/no"
&glob label-trdcattr-discnt-other   "Перерассчитывать скидку по документу удалив доставку "
&glob tooltip-trdcattr-discnt-other "Перерассчитывать скидку по документу удалив доставку"
&glob user-can-edit-trdcattr-discnt-other false
&glob output-display-trdcattr-discnt-other  false
&glob other-trdcattr-discnt-other '':u
&glob news-trdcattr-discnt-other true
&glob sort-trdcattr-discnt-other 100

/*Место: Место хранения */
&glob fillin_width-trdcattr-place-storage 70
&glob fillin_height-trdcattr-place-storage 1
&glob type-trdcattr-place-storage {&type-char}
&glob format-trdcattr-place-storage  "x(255)"
&glob label-trdcattr-place-storage   "Место хранения "
&glob tooltip-trdcattr-place-storage "Место хранения "
&glob user-can-edit-trdcattr-place-storage true
&glob output-display-trdcattr-place-storage true
&glob other-trdcattr-place-storage 'nws':u
&glob news-trdcattr-place-storage true
&glob sort-trdcattr-place-storage 100

&glob fillin_width-trdcattr-packer 70
&glob fillin_height-trdcattr-packer 1
&glob type-trdcattr-packer {&type-char}
&glob format-trdcattr-packer  "x(255)"
&glob label-trdcattr-packer   "Упаковщик"
&glob tooltip-trdcattr-packer "Упаковщик"
&glob user-can-edit-trdcattr-packer true
&glob output-display-trdcattr-packer true
&glob other-trdcattr-packer 'nws':u
&glob news-trdcattr-packer true
&glob sort-trdcattr-packer 100

&glob fillin_width-trdcattr-dispath 70
&glob fillin_height-trdcattr-dispath 1
&glob type-trdcattr-dispath {&type-char}
&glob format-trdcattr-dispath  "x(255)"
&glob label-trdcattr-dispath   "Способ отгрузки"
&glob tooltip-trdcattr-dispath "Способ отгрузки"
&glob user-can-edit-trdcattr-dispath true
&glob output-display-trdcattr-dispath true
&glob other-trdcattr-dispath 'nws':u
&glob news-trdcattr-dispath true
&glob sort-trdcattr-dispath 100

/* статус EDI */
&glob type-trdcattr-edi {&type-char}
&glob format-trdcattr-edi "x(11)"
&glob fillin_width-trdcattr-edi 10
&glob fillin_height-trdcattr-edi 1
&glob label-trdcattr-edi "Статус EDI"
&glob tooltip-trdcattr-edi "Статус EDI"
&glob user-can-edit-trdcattr-edi  false
&glob output-display-trdcattr-edi false
&glob other-trdcattr-edi '':u
&glob news-trdcattr-edi true
&glob sort-trdcattr-edi 100

/* Доверенность: Дата  */
&glob fillin_width-trdcattr-ddov 11
&glob fillin_height-trdcattr-ddov 1
&glob type-trdcattr-ddov {&type-date}
&glob format-trdcattr-ddov "99/99/9999"
&glob label-trdcattr-ddov "Доверенность: Дата"
&glob tooltip-trdcattr-ddov "Доверенность: Дата"
&glob user-can-edit-trdcattr-ddov true
&glob output-display-trdcattr-ddov true
&glob other-trdcattr-ddov 'nws':u
&glob news-trdcattr-ddov true
&glob sort-trdcattr-ddov 45

/* Доверенность: Номер */
&glob fillin_width-trdcattr-ndov 71
&glob fillin_height-trdcattr-ndov 1
&glob type-trdcattr-ndov {&type-char}
&glob format-trdcattr-ndov "x(70)"
&glob label-trdcattr-ndov "Доверенность: Номер"
&glob tooltip-trdcattr-ndov "Доверенность: Номер"
&glob user-can-edit-trdcattr-ndov true
&glob output-display-trdcattr-ndov true
&glob other-trdcattr-ndov 'nws':u
&glob news-trdcattr-ndov true
&glob sort-trdcattr-ndov 50

/* ГрузоПолучатель */
&glob fillin_width-trdcattr-recipient 71
&glob fillin_height-trdcattr-recipient 1
&glob proc-trdcattr-recipient "win=str/gp-updtr.w,func=funcgrzp"
&glob type-trdcattr-recipient {&type-char}
&glob format-trdcattr-recipient "x(255)"
&glob label-trdcattr-recipient "Грузополучатель"
&glob tooltip-trdcattr-recipient "Грузополучатель товара"
&glob user-can-edit-trdcattr-recipient true
&glob output-display-trdcattr-recipient true
&glob other-trdcattr-recipient 'nws':u
&glob news-trdcattr-recipient true
&glob sort-trdcattr-recipient 100

/* ГрузоОтправитель */
&glob fillin_width-trdcattr-shipper 71
&glob fillin_height-trdcattr-shipper 1
&glob proc-trdcattr-shipper "win=str/go-updtr.w,func=funcgrzp"
&glob type-trdcattr-shipper {&type-char}
&glob format-trdcattr-shipper "x(255)"
&glob label-trdcattr-shipper "Грузоотправитель"
&glob tooltip-trdcattr-shipper "Грузоотправитель товара"
&glob user-can-edit-trdcattr-shipper true
&glob output-display-trdcattr-shipper true
&glob other-trdcattr-shipper 'nws':u
&glob news-trdcattr-shipper true
&glob sort-trdcattr-shipper 100

/* Автомобиль: Марка, Номер */
&glob fillin_width-trdcattr-auto 71
&glob fillin_height-trdcattr-auto 1
&glob proc-trdcattr-auto "win=str/trdcauto.w,func=funcgrzp"
&glob type-trdcattr-auto {&type-char}
&glob format-trdcattr-auto "x(255)"
&glob label-trdcattr-auto "Автомобиль: Марка, Номер"
&glob tooltip-trdcattr-auto "Автомобиль: Марка, Номер"
&glob user-can-edit-trdcattr-auto true
&glob output-display-trdcattr-auto true
&glob other-trdcattr-auto 'nws':u
&glob news-trdcattr-auto true
&glob sort-trdcattr-auto 10

/* Автомобиль: Водитель */
&glob fillin_width-trdcattr-driver 71
&glob fillin_height-trdcattr-driver 1
&glob type-trdcattr-driver {&type-char}
&glob format-trdcattr-driver "x(255)"
&glob label-trdcattr-driver "Автомобиль: Водитель"
&glob tooltip-trdcattr-driver "Автомобиль: Водитель"
&glob user-can-edit-trdcattr-driver true
&glob output-display-trdcattr-driver true
&glob other-trdcattr-driver 'nws':u
&glob news-trdcattr-driver true
&glob sort-trdcattr-driver 20

/* Номер документа для печати  */
&glob fillin_width-trdcattr-print-num 71
&glob fillin_height-trdcattr-print-num 1
&glob type-trdcattr-print-num {&type-char}
&glob format-trdcattr-print-num "X(70)"
&glob label-trdcattr-print-num "Номер документа для печати"
&glob tooltip-trdcattr-print-num "Номер документа для печати"
&glob user-can-edit-trdcattr-print-num true
&glob output-display-trdcattr-print-num true
&glob other-trdcattr-print-num 'nws':u
&glob news-trdcattr-print-num true
&glob sort-trdcattr-print-num 120   

/* Идентификатор государственного контракта */
&glob fillin_width-trdcattr-idCountryContr 71
&glob fillin_height-trdcattr-idCountryContr 1
&glob type-trdcattr-idCountryContr {&type-char}
&glob format-trdcattr-idCountryContr "X(70)"
&glob label-trdcattr-idCountryContr "Идентификатор государственного контракта"
&glob tooltip-trdcattr-idCountryContr "Идентификатор государственного контракта"
&glob user-can-edit-trdcattr-idCountryContr true
&glob output-display-trdcattr-idCountryContr true
&glob other-trdcattr-idCountryContr 'nws':u
&glob news-trdcattr-idCountryContr true
&glob sort-trdcattr-idCountryContr 120

/* Документ пересортицы делается по тем же контрагентам и договорам */
&glob fillin_width-trdcattr-oldsuppcntr 3
&glob fillin_height-trdcattr-oldsuppcntr 1
&glob type-trdcattr-oldsuppcntr {&type-log}
&glob format-trdcattr-oldsuppcntr  "yes/no"
&glob label-trdcattr-oldsuppcntr   "Документ пересортицы делается по тем же контрагентам и договорам"
&glob tooltip-trdcattr-oldsuppcntr "Документ пересортицы делается по тем же контрагентам и договорам"
&glob user-can-edit-trdcattr-oldsuppcntr false
&glob output-display-trdcattr-oldsuppcntr  false
&glob other-trdcattr-oldsuppcntr '':u
&glob news-trdcattr-oldsuppcntr true
&glob sort-trdcattr-oldsuppcntr 100

/* Время прихода машины */
&glob fillin_width-trdcattr-car-time 71
&glob fillin_height-trdcattr-car-time 1
&glob type-trdcattr-car-time {&type-char}
&glob format-trdcattr-car-time  "X(5)"
&glob label-trdcattr-car-time   "Время прихода машины"
&glob tooltip-trdcattr-car-time "Время прихода машины"
&glob user-can-edit-trdcattr-car-time true
&glob output-display-trdcattr-car-time true
&glob other-trdcattr-car-time 'nws':u
&glob news-trdcattr-car-time true
&glob sort-trdcattr-car-time 100

/* Сдал ФИО */
&glob fillin_width-trdcattr-t_pass-fname 70
&glob fillin_height-trdcattr-t_pass-fname 1
&glob proc-trdcattr-t_pass-fname "''"
&glob type-trdcattr-t_pass-fname {&type-char}
&glob format-trdcattr-t_pass-fname "X(70)"
&glob label-trdcattr-t_pass-fname "Сдал /Расшифровка/"
&glob tooltip-trdcattr-t_pass-fname "Сдал /Расшифровка подписи/"
&glob user-can-edit-trdcattr-t_pass-fname true
&glob output-display-trdcattr-t_pass-fname true
&glob other-trdcattr-t_pass-fname 'nws':u
&glob news-trdcattr-t_pass-fname true
&glob sort-trdcattr-t_pass-fname 92

/* Сдал должность */
&glob fillin_width-trdcattr-t_pass-position 70
&glob fillin_height-trdcattr-t_pass-position 1
&glob proc-trdcattr-t_pass-position "''"
&glob type-trdcattr-t_pass-position {&type-char}
&glob format-trdcattr-t_pass-position "X(70)"
&glob label-trdcattr-t_pass-position "Сдал /Должность/"
&glob tooltip-trdcattr-t_pass-position "Сдал /Должность/"
&glob user-can-edit-trdcattr-t_pass-position true
&glob output-display-trdcattr-t_pass-position true
&glob other-trdcattr-t_pass-position 'nws':u
&glob news-trdcattr-t_pass-position true
&glob sort-trdcattr-t_pass-position 94

/* Принял ФИО */
&glob fillin_width-trdcattr-t_accept-fname 70
&glob fillin_height-trdcattr-t_accept-fname 1
&glob proc-trdcattr-t_accept-fname "''"
&glob type-trdcattr-t_accept-fname {&type-char}
&glob format-trdcattr-t_accept-fname "X(70)"
&glob label-trdcattr-t_accept-fname "Принял /Расшифровка/"
&glob tooltip-trdcattr-t_accept-fname "Принял /Расшифровка подписи/"
&glob user-can-edit-trdcattr-t_accept-fname true
&glob output-display-trdcattr-t_accept-fname true
&glob other-trdcattr-t_accept-fname 'nws':u
&glob news-trdcattr-t_accept-fname true
&glob sort-trdcattr-t_accept-fname 80

/* Принял Должность*/
&glob fillin_width-trdcattr-t_accept-position 70
&glob fillin_height-trdcattr-t_accept-position 1
&glob proc-trdcattr-t_accept-position "''"
&glob type-trdcattr-t_accept-position {&type-char}
&glob format-trdcattr-t_accept-position "X(70)"
&glob label-trdcattr-t_accept-position "Принял /Должность/"
&glob tooltip-trdcattr-t_accept-position "Принял /Должность/"
&glob user-can-edit-trdcattr-t_accept-position true
&glob output-display-trdcattr-t_accept-position true
&glob other-trdcattr-t_accept-position 'nws':u
&glob news-trdcattr-t_accept-position true
&glob sort-trdcattr-t_accept-position 90

/* Доверенность: Кем и кому выдана */
&glob fillin_width-trdcattr-ndovwho 70
&glob fillin_height-trdcattr-ndovwho 1
&glob proc-trdcattr-ndovwho "''"
&glob type-trdcattr-ndovwho {&type-char}
&glob format-trdcattr-ndovwho "X(70)"
&glob label-trdcattr-ndovwho "Доверенность: Кем и кому выдана"
&glob tooltip-trdcattr-ndovwho "Доверенность: Кем и кому выдана"
&glob user-can-edit-trdcattr-ndovwho true
&glob output-display-trdcattr-ndovwho true
&glob other-trdcattr-ndovwho 'nws':u
&glob news-trdcattr-ndovwho true
&glob sort-trdcattr-ndovwho 55

/* Кем и кому выдана доверенность */
&glob fillin_width-trdcattr-nosn 70
&glob fillin_height-trdcattr-nosn 1
&glob proc-trdcattr-nosn "''"
&glob type-trdcattr-nosn {&type-char}
&glob format-trdcattr-nosn "X(70)"
&glob label-trdcattr-nosn "Документ-основание. Наименование"
&glob tooltip-trdcattr-nosn "Документ-основание. Наименование"
&glob user-can-edit-trdcattr-nosn true
&glob output-display-trdcattr-nosn true
&glob other-trdcattr-nosn 'nws':u
&glob news-trdcattr-nosn true
&glob sort-trdcattr-nosn 110

/* для переоценки (первая переоценка,равная цене ПН) */
&glob fillin_width-trdcattr-first-price 3
&glob fillin_height-trdcattr-first-price 1
&glob type-trdcattr-first-price {&type-log}
&glob format-trdcattr-first-price "yes/no"
&glob label-trdcattr-first-price "Первая переоценка"
&glob tooltip-trdcattr-first-price "Переоценка создана равной ценам ПН"
&glob user-can-edit-trdcattr-first-price false
&glob output-display-trdcattr-first-price false
&glob other-trdcattr-first-price '':u
&glob news-trdcattr-first-price true
&glob sort-trdcattr-first-price 100

/* Связка Переоценки с поражденными от нее ДНЦ */
&glob fillin_width-trdcattr-relprpdf 22
&glob fillin_height-trdcattr-relprpdf 1
&glob type-trdcattr-relprpdf     {&type-char}
&glob format-trdcattr-relprpdf  "X(70)"
&glob label-trdcattr-relprpdf   "Связка Переоценки"
&glob tooltip-trdcattr-relprpdf "Связка Переоценки"
&glob user-can-edit-trdcattr-relprpdf  false
&glob output-display-trdcattr-relprpdf false
&glob other-trdcattr-relprpdf 'nws':u
&glob news-trdcattr-relprpdf   true
&glob sort-trdcattr-relprpdf   100

/* Номер выгрузки в Oracle Retail */
&glob fillin_width-trdcattr-ora-exp-seq-num 22
&glob fillin_height-trdcattr-ora-exp-seq-num 1
&glob type-trdcattr-ora-exp-seq-num     {&type-int}
&glob format-trdcattr-ora-exp-seq-num  "999999999"
&glob label-trdcattr-ora-exp-seq-num   "Номер выгрузки в Oracle Retail"
&glob tooltip-trdcattr-ora-exp-seq-num "Номер выгрузки в Oracle Retail"
&glob user-can-edit-trdcattr-ora-exp-seq-num  false
&glob output-display-trdcattr-ora-exp-seq-num false
&glob other-trdcattr-ora-exp-seq-num 'nws':u
&glob news-trdcattr-ora-exp-seq-num   true
&glob sort-trdcattr-ora-exp-seq-num   130


/* расчет данных по ДК еще не произошел*/
&glob fillin_width-trdcattr-need-saledc 3
&glob fillin_height-trdcattr-need-saledc 1
&glob type-trdcattr-need-saledc {&type-int}
&glob format-trdcattr-need-saledc "-9"
&glob label-trdcattr-need-saledc "Требуется расчет данных по ДК"
&glob tooltip-trdcattr-need-saledc "Требуется расчет данных по ДК"
&glob user-can-edit-trdcattr-need-saledc false
&glob output-display-trdcattr-need-saledc true
&glob other-trdcattr-need-saledc '':u
&glob news-trdcattr-need-saledc true
&glob sort-trdcattr-need-saledc 100

/* Дата приходной накладной поставщика */
&glob fillin_width-trdcattr-dateinv 11
&glob fillin_height-trdcattr-dateinv 1
&glob type-trdcattr-dateinv {&type-date}
&glob format-trdcattr-dateinv "99/99/9999"
&glob label-trdcattr-dateinv "Дата планируемого закрытия инвентаризации"
&glob tooltip-trdcattr-dateinv "Дата планируемого закрытия инвентаризации"
&glob user-can-edit-trdcattr-dateinv false
&glob output-display-trdcattr-dateinv false
&glob other-trdcattr-dateinv 'nws':u
&glob news-trdcattr-dateinv true
&glob sort-trdcattr-dateinv 100

/* Серия по фасовочному журналу */
&glob fillin_width-trdcattr-ser_on_pack 70
&glob fillin_height-trdcattr-ser_on_pack 1
&glob proc-trdcattr-ser_on_pack "''"
&glob type-trdcattr-ser_on_pack {&type-char}
&glob format-trdcattr-ser_on_pack "X(70)"
&glob label-trdcattr-ser_on_pack "Серия по фасовочному журналу"
&glob tooltip-trdcattr-ser_on_pack "Серия по фасовочному журналу"
&glob user-can-edit-trdcattr-ser_on_pack true
&glob output-display-trdcattr-ser_on_pack true
&glob other-trdcattr-ser_on_pack 'nws':u
&glob news-trdcattr-ser_on_pack true
&glob sort-trdcattr-ser_on_pack 121

/* Описание груза */
&glob fillin_width-trdcattr-cargo-desc 70
&glob fillin_height-trdcattr-cargo-desc 1
&glob proc-trdcattr-cargo-desc "win=str/trdcdesc.w,func=funcgrzp"
&glob type-trdcattr-cargo-desc {&type-char}
&glob format-trdcattr-cargo-desc "X(255)"
&glob label-trdcattr-cargo-desc "Описание груза"
&glob tooltip-trdcattr-cargo-desc "Описание груза"
&glob user-can-edit-trdcattr-cargo-desc true
&glob output-display-trdcattr-cargo-desc true
&glob other-trdcattr-cargo-desc 'nws':u
&glob news-trdcattr-cargo-desc true
&glob sort-trdcattr-cargo-desc 150

/* Вид перевозки */
&glob fillin_width-trdcattr-carry-type 70
&glob fillin_height-trdcattr-carry-type 1
&glob proc-trdcattr-carry-type "''"
&glob type-trdcattr-carry-type {&type-char}
&glob format-trdcattr-carry-type "X(70)"
&glob label-trdcattr-carry-type "Вид перевозки"
&glob tooltip-trdcattr-carry-type "Вид перевозки"
&glob user-can-edit-trdcattr-carry-type true
&glob output-display-trdcattr-carry-type true
&glob other-trdcattr-carry-type 'nws':u
&glob news-trdcattr-carry-type true
&glob sort-trdcattr-carry-type 130

/* Масса груза, кг */
&glob fillin_width-trdcattr-cargo-mass  70
&glob fillin_height-trdcattr-cargo-mass 1
&glob proc-trdcattr-cargo-mass "win=str/trdcmass.w,func=funcgrzp"
&glob type-trdcattr-cargo-mass {&type-char}
&glob format-trdcattr-cargo-mass "x(70)"
&glob label-trdcattr-cargo-mass   "Масса груза, кг"
&glob tooltip-trdcattr-cargo-mass "Масса груза, кг"
&glob user-can-edit-trdcattr-cargo-mass true
&glob output-display-trdcattr-cargo-mass  true
&glob other-trdcattr-cargo-mass 'nws':u
&glob news-trdcattr-cargo-mass true
&glob sort-trdcattr-cargo-mass 140

/* Складские/транспортные расходы */
&glob fillin_width-trdcattr-exp-trans  18
&glob fillin_height-trdcattr-exp-trans 1
&glob proc-trdcattr-exp-trans "''"
&glob type-trdcattr-exp-trans {&type-dec}
&glob format-trdcattr-exp-trans "->,>>>,>>>,>>9.99"
&glob label-trdcattr-exp-trans   "Складские/транспортные расходы"
&glob tooltip-trdcattr-exp-trans "Складские/транспортные расходы"
&glob user-can-edit-trdcattr-exp-trans true
&glob output-display-trdcattr-exp-trans  true
&glob other-trdcattr-exp-trans 'nws':u
&glob news-trdcattr-exp-trans true
&glob sort-trdcattr-exp-trans 160

/* Номер заказа */
&glob fillin_width-trdcattr-zakaz-number  18
&glob fillin_height-trdcattr-zakaz-number 1
&glob proc-trdcattr-zakaz-number "''"
&glob type-trdcattr-zakaz-number {&type-char}
&glob format-trdcattr-zakaz-number "x(70)"
&glob label-trdcattr-zakaz-number   "Номер заказа"
&glob tooltip-trdcattr-zakaz-number "Номер заказа"
&glob user-can-edit-trdcattr-zakaz-number true
&glob output-display-trdcattr-zakaz-number  true
&glob other-trdcattr-zakaz-number 'nws':u
&glob news-trdcattr-zakaz-number true
&glob sort-trdcattr-zakaz-number 180

/* Дата заказа */
&glob fillin_width-trdcattr-zakaz-date 11
&glob fillin_height-trdcattr-zakaz-date 1
&glob type-trdcattr-zakaz-date {&type-date}
&glob format-trdcattr-zakaz-date "99/99/9999"
&glob label-trdcattr-zakaz-date "Дата заказа"
&glob tooltip-trdcattr-zakaz-date "Дата заказа магазина"
&glob user-can-edit-trdcattr-zakaz-date true
&glob output-display-trdcattr-zakaz-date true
&glob other-trdcattr-zakaz-date 'nws':u
&glob news-trdcattr-zakaz-date true
&glob sort-trdcattr-zakaz-date 100

/* Дата доставки */
&glob fillin_width-trdcattr-delivery-date  11
&glob fillin_height-trdcattr-delivery-date 1
&glob type-trdcattr-delivery-date {&type-date}
&glob format-trdcattr-delivery-date "99/99/9999"
&glob label-trdcattr-delivery-date   "Дата доставки"
&glob tooltip-trdcattr-delivery-date "Дата доставки"
&glob user-can-edit-trdcattr-delivery-date true
&glob output-display-trdcattr-delivery-date  true
&glob other-trdcattr-delivery-date 'nws':u
&glob news-trdcattr-delivery-date true
&glob sort-trdcattr-delivery-date 100

/*время доставки */
&glob fillin_width-trdcattr-delivery-time 14
&glob fillin_height-trdcattr-delivery-time 1
&glob type-trdcattr-delivery-time {&type-char}
&glob format-trdcattr-delivery-time "99:99-99:99"
&glob label-trdcattr-delivery-time "Время доставки (период)"
&glob tooltip-trdcattr-delivery-time "Время доставки (период)"
&glob user-can-edit-trdcattr-delivery-time true
&glob output-display-trdcattr-delivery-time true
&glob other-trdcattr-delivery-time '':u
&glob news-trdcattr-delivery-time true
&glob sort-trdcattr-delivery-time 100

/* Номер документа во Внешней системе */
&glob fillin_width-trdcattr-doc-num-in-ext-sys 20
&glob fillin_height-trdcattr-doc-num-in-ext-sys 1
&glob type-trdcattr-doc-num-in-ext-sys {&type-char}
&glob format-trdcattr-doc-num-in-ext-sys "X(20)"
&glob label-trdcattr-doc-num-in-ext-sys "Номер документа во ВС"
&glob tooltip-trdcattr-doc-num-in-ext-sys "Номер документа во ВС"
&glob user-can-edit-trdcattr-doc-num-in-ext-sys true
&glob output-display-trdcattr-doc-num-in-ext-sys true
&glob other-trdcattr-doc-num-in-ext-sys '':u
&glob news-trdcattr-doc-num-in-ext-sys true
&glob sort-trdcattr-doc-num-in-ext-sys 190

/* Сопроводительные документы */
&glob fillin_width-trdcattr-cargo-doc 20
&glob fillin_height-trdcattr-cargo-doc 1
&glob type-trdcattr-cargo-doc {&type-char}
&glob format-trdcattr-cargo-doc "X(100)"
&glob label-trdcattr-cargo-doc "Сопроводительные документы"
&glob tooltip-trdcattr-cargo-doc "Сопроводительные документы"
&glob user-can-edit-trdcattr-cargo-doc true
&glob output-display-trdcattr-cargo-doc true
&glob other-trdcattr-cargo-doc '':u
&glob news-trdcattr-cargo-doc true
&glob sort-trdcattr-cargo-doc 190

/* Единица измерения */
&glob fillin_width-trdcattr-EI-pack 20
&glob fillin_height-trdcattr-EI-pack 1
&glob type-trdcattr-EI-pack {&type-char}
&glob format-trdcattr-EI-pack "X(30)"
&glob label-trdcattr-EI-pack "Единица измерения"
&glob tooltip-trdcattr-EI-pack "Единица измерения"
&glob user-can-edit-trdcattr-EI-pack true
&glob output-display-trdcattr-EI-pack true
&glob other-trdcattr-EI-pack '':u
&glob news-trdcattr-EI-pack true
&glob sort-trdcattr-EI-pack 190

/* Нефтебаза/ГНС */
&glob fillin_width-trdcattr-ptbobj 20
&glob fillin_height-trdcattr-ptbobj 1
&glob type-trdcattr-ptbobj {&type-char}
&glob format-trdcattr-ptbobj "X(20)"
&glob label-trdcattr-ptbobj "Нефтебаза/ГНС"
&glob tooltip-trdcattr-ptbobj "Нефтебаза/ГНС"
&glob user-can-edit-trdcattr-ptbobj true
&glob output-display-trdcattr-ptbobj true
&glob other-trdcattr-ptbobj '':u
&glob news-trdcattr-ptbobj true
&glob sort-trdcattr-ptbobj 190

/* Примечание к нефтебазе */
&glob fillin_width-trdcattr-ptb-item-pour 20
&glob fillin_height-trdcattr-ptb-item-pour 1
&glob type-trdcattr-ptb-item-pour {&type-char}
&glob format-trdcattr-ptb-item-pour "X(100)"
&glob label-trdcattr-ptb-item-pour "Примечание к нефтебазе"
&glob tooltip-trdcattr-ptb-item-pour "Примечание к нефтебазе"
&glob user-can-edit-trdcattr-ptb-item-pour true
&glob output-display-trdcattr-ptb-item-pour true
&glob other-trdcattr-ptb-item-pour '':u
&glob news-trdcattr-ptb-item-pour true
&glob sort-trdcattr-ptb-item-pour 190

/* Автопредприятие */
&glob fillin_width-trdcattr-autoent 20
&glob fillin_height-trdcattr-autoent 1
&glob type-trdcattr-autoent {&type-char}
&glob format-trdcattr-autoent "X(20)"
&glob label-trdcattr-autoent "Автопредприятие"
&glob tooltip-trdcattr-autoent "Автопредприятие"
&glob user-can-edit-trdcattr-autoent true
&glob output-display-trdcattr-autoent true
&glob other-trdcattr-autoent '':u
&glob news-trdcattr-autoent true
&glob sort-trdcattr-autoent 190

/* Гос. № автоцистерны */
&glob fillin_width-trdcattr-car-num 20
&glob fillin_height-trdcattr-car-num 1
&glob type-trdcattr-car-num {&type-char}
&glob format-trdcattr-car-num "X(20)"
&glob label-trdcattr-car-num "Гос. № автоцистерны"
&glob tooltip-trdcattr-car-num "Гос. № автоцистерны"
&glob user-can-edit-trdcattr-car-num true
&glob output-display-trdcattr-car-num true
&glob other-trdcattr-car-num '':u
&glob news-trdcattr-car-num true
&glob sort-trdcattr-car-num 190

/* Ф.И.О. водителя-экспедитора */
&glob fillin_width-trdcattr-fio-driver 20
&glob fillin_height-trdcattr-fio-driver 1
&glob type-trdcattr-fio-driver {&type-char}
&glob format-trdcattr-fio-driver "X(20)"
&glob label-trdcattr-fio-driver "Ф.И.О. водителя-экспедитора"
&glob tooltip-trdcattr-fio-driver "Ф.И.О. водителя-экспедитора"
&glob user-can-edit-trdcattr-fio-driver true
&glob output-display-trdcattr-fio-driver true
&glob other-trdcattr-fio-driver '':u
&glob news-trdcattr-fio-driver true
&glob sort-trdcattr-fio-driver 190

/* Паспорт качества дата */
&glob fillin_width-trdcattr-date-income 11
&glob fillin_height-trdcattr-date-income 1
&glob type-trdcattr-date-income {&type-date}
&glob format-trdcattr-date-income "99/99/9999"
&glob label-trdcattr-date-income "Дата прибытия на АЗС"
&glob tooltip-trdcattr-date-income "Дата прибытия на АЗС"
&glob user-can-edit-trdcattr-date-income true
&glob output-display-trdcattr-date-income true
&glob other-trdcattr-date-income '':u
&glob news-trdcattr-date-income true
&glob sort-trdcattr-date-income 180

/* Время прибытия на АЗС */
&glob fillin_width-trdcattr-time-income 20
&glob fillin_height-trdcattr-time-income 1
&glob type-trdcattr-time-income {&type-char}
&glob format-trdcattr-time-income "X(20)"
&glob label-trdcattr-time-income "Время прибытия на АЗС"
&glob tooltip-trdcattr-time-income "Время прибытия на АЗС"
&glob user-can-edit-trdcattr-time-income true
&glob output-display-trdcattr-time-income true
&glob other-trdcattr-time-income '':u
&glob news-trdcattr-time-income true
&glob sort-trdcattr-time-income 190

/* Свидетельство о поверке */
&glob fillin_width-trdcattr-inspection-cert 20
&glob fillin_height-trdcattr-inspection-cert 1
&glob type-trdcattr-inspection-cert {&type-char}
&glob format-trdcattr-inspection-cert "X(20)"
&glob label-trdcattr-inspection-cert "Свидетельство о поверке"
&glob tooltip-trdcattr-inspection-cert "Свидетельство о поверке"
&glob user-can-edit-trdcattr-inspection-cert true
&glob output-display-trdcattr-inspection-cert true
&glob other-trdcattr-inspection-cert '':u
&glob news-trdcattr-inspection-cert true
&glob sort-trdcattr-inspection-cert 190

/* Дата свидетельства о поверке */
&glob fillin_width-trdcattr-date-cert 11
&glob fillin_height-trdcattr-date-cert 1
&glob type-trdcattr-date-cert {&type-date}
&glob format-trdcattr-date-cert "99/99/9999"
&glob label-trdcattr-date-cert "Дата свидетельства о поверке"
&glob tooltip-trdcattr-date-cert "Дата свидетельства о поверке"
&glob user-can-edit-trdcattr-date-cert true
&glob output-display-trdcattr-date-cert true
&glob other-trdcattr-date-cert '':u
&glob news-trdcattr-date-cert true
&glob sort-trdcattr-date-cert 100


/* Паспорт качества дата */
&glob fillin_width-trdcattr-date-pasport 11
&glob fillin_height-trdcattr-date-pasport 1
&glob type-trdcattr-date-pasport {&type-date}
&glob format-trdcattr-date-pasport "99/99/9999"
&glob label-trdcattr-date-pasport "Паспорт качества дата"
&glob tooltip-trdcattr-date-pasport "Паспорт качества дата"
&glob user-can-edit-trdcattr-date-pasport true
&glob output-display-trdcattr-date-pasport true
&glob other-trdcattr-date-pasport '':u
&glob news-trdcattr-date-pasport true
&glob sort-trdcattr-date-pasport 100

/* Паспорт качества номер */
&glob fillin_width-trdcattr-num-pasport 20
&glob fillin_height-trdcattr-num-pasport 1
&glob type-trdcattr-num-pasport {&type-char}
&glob format-trdcattr-num-pasport "X(20)"
&glob label-trdcattr-num-pasport "Паспорт качества номер"
&glob tooltip-trdcattr-num-pasport "Паспорт качества номер"
&glob user-can-edit-trdcattr-num-pasport true
&glob output-display-trdcattr-num-pasport true
&glob other-trdcattr-num-pasport '':u
&glob news-trdcattr-num-pasport true
&glob sort-trdcattr-num-pasport 100

/* Техническое состояние */
&glob fillin_width-trdcattr-condition 20
&glob fillin_height-trdcattr-condition 1
&glob type-trdcattr-condition {&type-char}
&glob format-trdcattr-condition "X(20)"
&glob label-trdcattr-condition "Техническое состояние"
&glob tooltip-trdcattr-condition Техническое состояние"
&glob user-can-edit-trdcattr-condition true
&glob output-display-trdcattr-condition true
&glob other-trdcattr-condition '':u
&glob news-trdcattr-condition true
&glob sort-trdcattr-condition 190

/* Пломбы, их состояние */
&glob fillin_width-trdcattr-seals-condition 20
&glob fillin_height-trdcattr-seals-condition 1
&glob type-trdcattr-seals-condition {&type-char}
&glob format-trdcattr-seals-condition "X(20)"
&glob label-trdcattr-seals-condition "Пломбы и их состояние"
&glob tooltip-trdcattr-seals-condition "Пломбы и их состояние"
&glob user-can-edit-trdcattr-seals-condition true
&glob output-display-trdcattr-seals-condition true
&glob other-trdcattr-seals-condition '':u
&glob news-trdcattr-seals-condition true
&glob sort-trdcattr-seals-condition 190

/* Документы НЕ предоставлены */
&glob fillin_width-trdcattr-doc-not 4
&glob fillin_height-trdcattr-doc-not 1
&glob type-trdcattr-doc-not {&type-log}
&glob format-trdcattr-doc-not "yes/no"
&glob label-trdcattr-doc-not "Документы НЕ предоставлены"
&glob tooltip-trdcattr-doc-not "Документы НЕ предоставлены"
&glob user-can-edit-trdcattr-doc-not true
&glob output-display-trdcattr-doc-not true
&glob other-trdcattr-doc-not '':u
&glob news-trdcattr-doc-not true
&glob sort-trdcattr-doc-not 100

/* Произведена зачистка АЦ перед наполнением на ГНС (СУГ) */
&glob fillin_width-trdcattr-clear-ac 4
&glob fillin_height-trdcattr-clear-ac 1
&glob type-trdcattr-clear-ac {&type-log}
&glob format-trdcattr-clear-ac "yes/no"
&glob label-trdcattr-clear-ac "Произведена зачистка АЦ перед наполнением на ГНС"
&glob tooltip-trdcattr-clear-ac "Произведена зачистка АЦ перед наполнением на ГНС"
&glob user-can-edit-trdcattr-clear-ac true
&glob output-display-trdcattr-clear-ac true
&glob other-trdcattr-clear-ac '':u
&glob news-trdcattr-clear-ac true
&glob sort-trdcattr-clear-ac 200

/* Список не предоставленных документов */
&glob fillin_width-trdcattr-spisok-not-doc 20
&glob fillin_height-trdcattr-spisok-not-doc 1
&glob type-trdcattr-spisok-not-doc {&type-char}
&glob format-trdcattr-spisok-not-doc "X(100)"
&glob label-trdcattr-spisok-not-doc "Список не предоставленных документов"
&glob tooltip-trdcattr-spisok-not-doc "Список не предоставленных документов"
&glob user-can-edit-trdcattr-spisok-not-doc true
&glob output-display-trdcattr-spisok-not-doc true
&glob other-trdcattr-spisok-not-doc '':u
&glob news-trdcattr-spisok-not-doc true
&glob sort-trdcattr-spisok-not-doc 190

/* Дата налива */
&glob fillin_width-trdcattr-date-pour 11
&glob fillin_height-trdcattr-date-pour 1
&glob type-trdcattr-date-pour {&type-date}
&glob format-trdcattr-date-pour "99/99/9999"
&glob label-trdcattr-date-pour "Дата налива"
&glob tooltip-trdcattr-date-pour "Дата налива"
&glob user-can-edit-trdcattr-date-pour true
&glob output-display-trdcattr-date-pour true
&glob other-trdcattr-date-pour '':u
&glob news-trdcattr-date-pour true
&glob sort-trdcattr-date-pour 100

/* Время налива */
&glob fillin_width-trdcattr-time-pour 20
&glob fillin_height-trdcattr-time-pour 1
&glob type-trdcattr-time-pour {&type-char}
&glob format-trdcattr-time-pour "X(20)"
&glob label-trdcattr-time-pour "Время налива"
&glob tooltip-trdcattr-time-pour "Время налива"
&glob user-can-edit-trdcattr-time-pour true
&glob output-display-trdcattr-time-pour true
&glob other-trdcattr-time-pour '':u
&glob news-trdcattr-time-pour true
&glob sort-trdcattr-time-pour 190

/* Время начала слива */
&glob fillin_width-trdcattr-time-start 20
&glob fillin_height-trdcattr-time-start 1
&glob type-trdcattr-time-start {&type-char}
&glob format-trdcattr-time-start "X(20)"
&glob label-trdcattr-time-start "Время начала слива"
&glob tooltip-trdcattr-time-start "Время начала слива"
&glob user-can-edit-trdcattr-time-start true
&glob output-display-trdcattr-time-start true
&glob other-trdcattr-time-start '':u
&glob news-trdcattr-time-start true
&glob sort-trdcattr-time-start 190

/* Время конца слива */
&glob fillin_width-trdcattr-time-end 20
&glob fillin_height-trdcattr-time-end 1
&glob type-trdcattr-time-end {&type-char}
&glob format-trdcattr-time-end "X(20)"
&glob label-trdcattr-time-end "Время конца слива"
&glob tooltip-trdcattr-time-end "Время конца слива"
&glob user-can-edit-trdcattr-time-end true
&glob output-display-trdcattr-time-end true
&glob other-trdcattr-time-end '':u
&glob news-trdcattr-time-end true
&glob sort-trdcattr-time-end 190


/* Топливная накладная */
&glob fillin_width-trdcattr-is-fuel 3
&glob fillin_height-trdcattr-is-fuel 1
&glob type-trdcattr-is-fuel {&type-log}
&glob format-trdcattr-is-fuel "yes/no"
&glob label-trdcattr-is-fuel "Признак топливной накладной"
&glob tooltip-trdcattr-is-fuel "Признак топливной накладной"
&glob user-can-edit-trdcattr-is-fuel false
&glob output-display-trdcattr-is-fuel false
&glob other-trdcattr-is-fuel '':u
&glob news-trdcattr-is-fuel true
&glob sort-trdcattr-is-fuel 100

/* Технологический пролив */
&glob fillin_width-trdcattr-techpass 3
&glob fillin_height-trdcattr-techpass 1
&glob type-trdcattr-techpass {&type-log}
&glob format-trdcattr-techpass "yes/no"
&glob label-trdcattr-techpass "Признак топливной накладной"
&glob tooltip-trdcattr-techpass "Признак топливной накладной"
&glob user-can-edit-trdcattr-techpass false
&glob output-display-trdcattr-techpass false
&glob other-trdcattr-techpass '':u
&glob news-trdcattr-techpass true
&glob sort-trdcattr-techpass 100

/* Прочие перемещения НП */
&glob fillin_width-trdcattr-othermoves 3
&glob fillin_height-trdcattr-othermoves 1
&glob type-trdcattr-othermoves {&type-log}
&glob format-trdcattr-othermoves "yes/no"
&glob label-trdcattr-othermoves "Прочие перемещения НП"
&glob tooltip-trdcattr-othermoves "Признак топливной накладной с прочими перемещениями (для ИС Президентский Мониторинг)"
&glob user-can-edit-trdcattr-othermoves true
&glob output-display-trdcattr-othermoves true
&glob other-trdcattr-othermoves '':u
&glob news-trdcattr-othermoves true
&glob sort-trdcattr-othermoves 100

/* Признак накладной сформированной автоматически */
&glob fillin_width-trdcattr-is-auto-trn 3
&glob fillin_height-trdcattr-is-auto-trn 1
&glob type-trdcattr-is-auto-trn {&type-log}
&glob format-trdcattr-is-auto-trn "yes/no"
&glob label-trdcattr-is-auto-trn "Признак накладной сформированной автоматически"
&glob tooltip-trdcattr-is-auto-trn " Признак накладной сформированной автоматически "
&glob user-can-edit-trdcattr-is-auto-trn false
&glob output-display-trdcattr-is-auto-trn false
&glob other-trdcattr-is-auto-trn '':u
&glob news-trdcattr-is-auto-trn true
&glob sort-trdcattr-is-auto-trn 100

/* СУГ */
&glob fillin_width-trdcattr-is-lgas 3
&glob fillin_height-trdcattr-is-lgas 1
&glob type-trdcattr-is-lgas {&type-log}
&glob format-trdcattr-is-lgas "yes/no"
&glob label-trdcattr-is-lgas "Документ прихода СУГ"
&glob tooltip-trdcattr-is-lgas "Документ прихода СУГ"
&glob user-can-edit-trdcattr-is-lgas false
&glob output-display-trdcattr-is-lgas true
&glob other-trdcattr-is-lgas '':u
&glob news-trdcattr-is-lgas true
&glob sort-trdcattr-is-lgas 100

/* Корр. Суг */
&glob fillin_width-trdcattr-is-lgas-corr 3
&glob fillin_height-trdcattr-is-lgas-corr 1
&glob type-trdcattr-is-lgas-corr {&type-log}
&glob format-trdcattr-is-lgas-corr "yes/no"
&glob label-trdcattr-is-lgas-corr "Документ корректировки СУГ"
&glob tooltip-trdcattr-is-lgas-corr "Документ корректировки СУГ"
&glob user-can-edit-trdcattr-is-lgas-corr false
&glob output-display-trdcattr-is-lgas-corr true
&glob other-trdcattr-is-lgas-corr '':u
&glob news-trdcattr-is-lgas-corr true
&glob sort-trdcattr-is-lgas-corr 100

/* Документ источник для корр. СУГ */
&glob fillin_width-trdcattr-trn-lgas-corr 3
&glob fillin_height-trdcattr-trn-lgas-corr 1
&glob type-trdcattr-trn-lgas-corr {&type-char}
&glob format-trdcattr-trn-lgas-corr "X(20)"
&glob label-trdcattr-trn-lgas-corr "Документ источник для корр. СУГ"
&glob tooltip-trdcattr-trn-lgas-corr " Документ источник для корр. СУГ"
&glob user-can-edit-trdcattr-trn-lgas-corr false
&glob output-display-trdcattr-trn-lgas-corr true
&glob other-trdcattr-trn-lgas-corr '':u
&glob news-trdcattr-trn-lgas-corr true
&glob sort-trdcattr-trn-lgas-corr 100

/* Расход внешний как Возврат поставщику */
&glob fillin_width-trdcattr-is-return 3
&glob fillin_height-trdcattr-is-return 1
&glob type-trdcattr-is-return {&type-log}
&glob format-trdcattr-is-return "yes/no"
&glob label-trdcattr-is-return "Расход внешний как Возврат поставщику"
&glob tooltip-trdcattr-is-return "Расход внешний используется для Возврата поставщику"
&glob user-can-edit-trdcattr-is-return false
&glob output-display-trdcattr-is-return true
&glob other-trdcattr-is-return '':u
&glob news-trdcattr-is-return true
&glob sort-trdcattr-is-return 100

/* Расход внешний как Возврат поставщику через ЭДО */
&glob fillin_width-trdcattr-edo-return 3
&glob fillin_height-trdcattr-edo-return 1
&glob type-trdcattr-edo-return {&type-log}
&glob format-trdcattr-edo-return "yes/no"
&glob label-trdcattr-edo-return "Расход внешний как Возврат поставщику через ЭДО"
&glob tooltip-trdcattr-edo-return "Расход внешний используется для Возврата поставщику через ЭДО"
&glob user-can-edit-trdcattr-edo-return false
&glob output-display-trdcattr-edo-return true
&glob other-trdcattr-edo-return '':u
&glob news-trdcattr-edo-return true
&glob sort-trdcattr-edo-return 100

/* Дата начала слива */
&glob fillin_width-trdcattr-date-start 11
&glob fillin_height-trdcattr-date-start 1
&glob type-trdcattr-date-start {&type-date}
&glob format-trdcattr-date-start "99/99/9999"
&glob label-trdcattr-date-start "Дата начала слива"
&glob tooltip-trdcattr-date-start "Дата начала слива"
&glob user-can-edit-trdcattr-date-start true
&glob output-display-trdcattr-date-start true
&glob other-trdcattr-date-start 'nws':u
&glob news-trdcattr-date-start true
&glob sort-trdcattr-date-start 100

/* Дата конца слива */
&glob fillin_width-trdcattr-date-end 11
&glob fillin_height-trdcattr-date-end 1
&glob type-trdcattr-date-end {&type-date}
&glob format-trdcattr-date-end "99/99/9999"
&glob label-trdcattr-date-end "Дата конца слива"
&glob tooltip-trdcattr-date-end "Дата конца слива"
&glob user-can-edit-trdcattr-date-end true
&glob output-display-trdcattr-date-end true
&glob other-trdcattr-date-end 'nws':u
&glob news-trdcattr-date-end true
&glob sort-trdcattr-date-end 100

/* Документ инвентаризации с первоначальным вводом марок */
&glob fillin_width-trdcattr-inv-introduce 11
&glob fillin_height-trdcattr-inv-introduce 1
&glob type-trdcattr-inv-introduce {&type-log}
&glob format-trdcattr-inv-introduce "yes/no"
&glob label-trdcattr-inv-introduce "Документ инвентаризации с первоначальным вводом марок"
&glob tooltip-trdcattr-inv-introduce " Документ инвентаризации с первоначальным вводом марок"
&glob user-can-edit-trdcattr-inv-introduce false
&glob output-display-trdcattr-inv-introduce false
&glob other-trdcattr-inv-introduce '':u
&glob news-trdcattr-inv-introduce false
&glob sort-trdcattr-inv-introduce 100

/* Признак, что документ созан по УТД и должен в новостях обрабатываться на закрытия без учета, что это новости */
&glob fillin_width-trdcattr-is-not-close-fact-news 3
&glob fillin_height-trdcattr-is-not-close-fact-news 1
&glob type-trdcattr-is-not-close-fact-news {&type-log}
&glob format-trdcattr-is-not-close-fact-news "yes/no"
&glob label-trdcattr-is-not-close-fact-news ""
&glob tooltip-trdcattr-is-not-close-fact-news ""
&glob user-can-edit-trdcattr-is-not-close-fact-news false
&glob output-display-trdcattr-is-not-close-fact-news true
&glob other-trdcattr-is-not-close-fact-news '':u
&glob news-trdcattr-is-not-close-fact-news true
&glob sort-trdcattr-is-not-close-fact-news 100

/* Приказ: Номер */
&glob fillin_width-trdcattr-prikaz-number 70
&glob fillin_height-trdcattr-prikaz-number 1
&glob type-trdcattr-prikaz-number {&type-char}
&glob format-trdcattr-prikaz-number "X(70)"
&glob label-trdcattr-prikaz-number "Приказ: Номер"
&glob tooltip-trdcattr-prikaz-number "Приказ: Номер"
&glob user-can-edit-trdcattr-prikaz-number true
&glob output-display-trdcattr-prikaz-number true
&glob other-trdcattr-prikaz-number '':u
&glob news-trdcattr-prikaz-number true
&glob sort-trdcattr-prikaz-number 100

/* Приказ: Дата */
&glob fillin_width-trdcattr-prikaz-date 11
&glob fillin_height-trdcattr-prikaz-date 1
&glob type-trdcattr-prikaz-date {&type-date}
&glob format-trdcattr-prikaz-date "99.99.9999"
&glob label-trdcattr-prikaz-date "Приказ: Дата"
&glob tooltip-trdcattr-prikaz-date "Приказ: Дата"
&glob user-can-edit-trdcattr-prikaz-date true
&glob output-display-trdcattr-prikaz-date true
&glob other-trdcattr-prikaz-date '':u
&glob news-trdcattr-prikaz-date true
&glob sort-trdcattr-prikaz-date 102

/* Инвентаризация: Дата фактического начала */
&glob fillin_width-trdcattr-inv-date 11
&glob fillin_height-trdcattr-inv-date 1
&glob type-trdcattr-inv-date {&type-date}
&glob format-trdcattr-inv-date "99.99.9999"
&glob label-trdcattr-inv-date "Инвентаризация: Дата фактического начала"
&glob tooltip-trdcattr-inv-date "Инвентаризация: Дата фактического начала"
&glob user-can-edit-trdcattr-inv-date true
&glob output-display-trdcattr-inv-date true
&glob other-trdcattr-inv-date '':u
&glob news-trdcattr-inv-date true
&glob sort-trdcattr-inv-date 104

/* ФИО председателя комиссии */
&glob fillin_width-trdcattr-fio-agent 70
&glob fillin_height-trdcattr-fio-agent 1
&glob proc-trdcattr-fio-agent "''"
&glob type-trdcattr-fio-agent {&type-char}
&glob format-trdcattr-fio-agent "X(70)"
&glob label-trdcattr-fio-agent "ФИО председателя комиссии"
&glob tooltip-trdcattr-fio-agent "ФИО председателя комиссии"
&glob user-can-edit-trdcattr-fio-agent true
&glob output-display-trdcattr-fio-agent true
&glob other-trdcattr-fio-agent 'nws':u
&glob news-trdcattr-fio-agent true
&glob sort-trdcattr-fio-agent 106

/* Должность председателя комиссии */
&glob fillin_width-trdcattr-pos-agent 70
&glob fillin_height-trdcattr-pos-agent 1
&glob proc-trdcattr-pos-agent "''"
&glob type-trdcattr-pos-agent {&type-char}
&glob format-trdcattr-pos-agent "X(70)"
&glob label-trdcattr-pos-agent "Должность председателя комиссии"
&glob tooltip-trdcattr-pos-agent "Должность председателя комиссии"
&glob user-can-edit-trdcattr-pos-agent false
&glob output-display-trdcattr-pos-agent false
&glob other-trdcattr-pos-agent 'nws':u
&glob news-trdcattr-pos-agent true
&glob sort-trdcattr-pos-agent 108

/* ФИО участника комиссии1 */
&glob fillin_width-trdcattr-fio-player1 70
&glob fillin_height-trdcattr-fio-player1 1
&glob proc-trdcattr-fio-player1 "''"
&glob type-trdcattr-fio-player1 {&type-char}
&glob format-trdcattr-fio-player1 "X(70)"
&glob label-trdcattr-fio-player1 "ФИО участника комиссии"
&glob tooltip-trdcattr-fio-player1 "ФИО участника комиссии"
&glob user-can-edit-trdcattr-fio-player1 true
&glob output-display-trdcattr-fio-player1 true
&glob other-trdcattr-fio-player1 'nws':u
&glob news-trdcattr-fio-player1 true
&glob sort-trdcattr-fio-player1 110

/* Должность участника комиссии1 */
&glob fillin_width-trdcattr-pos-player1 70
&glob fillin_height-trdcattr-pos-player1 1
&glob proc-trdcattr-pos-player1 "''"
&glob type-trdcattr-pos-player1 {&type-char}
&glob format-trdcattr-pos-player1 "X(70)"
&glob label-trdcattr-pos-player1 "Должность участника комиссии"
&glob tooltip-trdcattr-pos-player1 "Должность участника комиссии"
&glob user-can-edit-trdcattr-pos-player1 false
&glob output-display-trdcattr-pos-player1 false
&glob other-trdcattr-pos-player1 'nws':u
&glob news-trdcattr-pos-player1 true
&glob sort-trdcattr-pos-player1 112

/* ФИО участника комиссии2 */
&glob fillin_width-trdcattr-fio-player2 70
&glob fillin_height-trdcattr-fio-player2 1
&glob proc-trdcattr-fio-player2 "''"
&glob type-trdcattr-fio-player2 {&type-char}
&glob format-trdcattr-fio-player2 "X(70)"
&glob label-trdcattr-fio-player2 "ФИО участника комиссии"
&glob tooltip-trdcattr-fio-player2 "ФИО участника комиссии"
&glob user-can-edit-trdcattr-fio-player2 true
&glob output-display-trdcattr-fio-player2 true
&glob other-trdcattr-fio-player2 'nws':u
&glob news-trdcattr-fio-player2 true
&glob sort-trdcattr-fio-player2 114

/* Должность участника комиссии2 */
&glob fillin_width-trdcattr-pos-player2 70
&glob fillin_height-trdcattr-pos-player2 1
&glob proc-trdcattr-pos-player2 "''"
&glob type-trdcattr-pos-player2 {&type-char}
&glob format-trdcattr-pos-player2 "X(70)"
&glob label-trdcattr-pos-player2 "Должность участника комиссии"
&glob tooltip-trdcattr-pos-player2 "Должность участника комиссии"
&glob user-can-edit-trdcattr-pos-player2 false
&glob output-display-trdcattr-pos-player2 false
&glob other-trdcattr-pos-player2 'nws':u
&glob news-trdcattr-pos-player2 true
&glob sort-trdcattr-pos-player2 116

/* ФИО участника комиссии3 */
&glob fillin_width-trdcattr-fio-player3 70
&glob fillin_height-trdcattr-fio-player3 1
&glob proc-trdcattr-fio-player3 "''"
&glob type-trdcattr-fio-player3 {&type-char}
&glob format-trdcattr-fio-player3 "X(70)"
&glob label-trdcattr-fio-player3 "ФИО участника комиссии"
&glob tooltip-trdcattr-fio-player3 "ФИО участника комиссии"
&glob user-can-edit-trdcattr-fio-player3 true
&glob output-display-trdcattr-fio-player3 true
&glob other-trdcattr-fio-player3 'nws':u
&glob news-trdcattr-fio-player3 true
&glob sort-trdcattr-fio-player3 118

/* Должность участника комиссии3 */
&glob fillin_width-trdcattr-pos-player3 70
&glob fillin_height-trdcattr-pos-player3 1
&glob proc-trdcattr-pos-player3 "''"
&glob type-trdcattr-pos-player3 {&type-char}
&glob format-trdcattr-pos-player3 "X(70)"
&glob label-trdcattr-pos-player3 "Должность участника комиссии"
&glob tooltip-trdcattr-pos-player3 "Должность участника комиссии"
&glob user-can-edit-trdcattr-pos-player3 false
&glob output-display-trdcattr-pos-player3 false
&glob other-trdcattr-pos-player3 'nws':u
&glob news-trdcattr-pos-player3 true
&glob sort-trdcattr-pos-player3 120

/* Масса слитого СУГ на промежуточных станциях АГЗС */
&glob fillin_width-sugtpattr-massa-sug 20
&glob fillin_height-sugtpattr-massa-sug 1
&glob type-sugtpattr-massa-sug {&type-dec}
&glob format-sugtpattr-massa-sug "->,>>>,>>>,>>9.999"
&glob label-sugtpattr-massa-sug "Масса слитого СУГ на промежуточных станциях АГЗС, кг"
&glob tooltip-sugtpattr-massa-sug "Масса слитого СУГ на промежуточных станциях АГЗС"
&glob user-can-edit-sugtpattr-massa-sug true
&glob output-display-sugtpattr-massa-sug true
&glob other-sugtpattr-massa-sug 'nws':u
&glob news-sugtpattr-massa-sug true
&glob sort-sugtpattr-massa-sug 130

/* Технологические потери предыдущих станций */
&glob fillin_width-sugtpattr-teh-loss 20
&glob fillin_height-sugtpattr-teh-loss 1
&glob type-sugtpattr-teh-loss {&type-dec}
&glob format-sugtpattr-teh-loss "->,>>>,>>>,>>9.999"
&glob label-sugtpattr-teh-loss "Технологические потери предыдущих станций, кг"
&glob tooltip-sugtpattr-teh-loss "Технологические потери предыдущих станций"
&glob user-can-edit-sugtpattr-teh-loss true
&glob output-display-sugtpattr-teh-loss true
&glob other-sugtpattr-teh-loss 'nws':u
&glob news-sugtpattr-teh-loss true
&glob sort-sugtpattr-teh-loss 131

/* Допустимые погрешности предыдущих станций */
&glob fillin_width-sugtpattr-err-allow 20
&glob fillin_height-sugtpattr-err-allow 1
&glob type-sugtpattr-err-allow {&type-dec}
&glob format-sugtpattr-err-allow "->,>>>,>>>,>>9.999"
&glob label-sugtpattr-err-allow "Допустимые погрешности предыдущих станций, кг"
&glob tooltip-sugtpattr-err-allow "Допустимые погрешности предыдущих станций"
&glob user-can-edit-sugtpattr-err-allow true
&glob output-display-sugtpattr-err-allow true
&glob other-sugtpattr-err-allow 'nws':u
&glob news-sugtpattr-err-allow true
&glob sort-sugtpattr-err-allow 132


&if "{1}" = "class" &then
&else
define new global shared variable g#trdcalib as handle no-undo.
&endif

&if "{1}" = "class" &then

  &glob run_proc_trdcalib ~
    {&check_trdcalib} ~
  run ~{&proc-name~} in ibs.th.gbl.gbl-hndllib:g#trdcalib

&else
  &glob include_trdcalib yes
  &glob check_trdcalib ~
    if valid-handle( g#trdcalib ) <> yes then do: ~
      run str/trdcalib.p persistent no-error. ~
      if error-status :error or valid-handle( g#trdcalib ) <> yes then do: ~
        message "Error starting trdcalib.p"    skip( 0 ) ~
                g#trdcalib                     skip( 0 ) ~
                g#trdcalib   :type             skip( 0 ) ~
                g#trdcalib   :file-name        skip( 0 ) ~
                error-status :get-message( 1 ) skip( 0 ) ~
                return-value                   skip( 0 ) ~
        view-as alert-box error. ~
        stop. ~
      end. /* error */ ~
    end. /* if not valid-handle( g#trdcalib ) */
  &glob run_proc_trdcalib ~
    {&check_trdcalib} ~
    run ~{&proc-name~} in g#trdcalib
&endif
&endif

/* $Workfile$   E n d */