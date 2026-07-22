/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры по обработке временных таблиц для выгрузки складских документов

Автор: Чернова Светлана Александровна
Дата создания: 11/20/06
Author: Svetlana Chernova
Creation date: 11/20/06

create: Суслов Алексей Юрьевич
Дата создания: 10/04/05


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define temp-table tt-trn-doc no-undo
field DocCode                like ub.trn-doc.doc-code     /*Номер документа*/
field ExtDocType             like ub.trn-doc.ext-doc-type /*Расширенный тип документа*/
field ExtDocTypeName         as   character               /*Название расширенного типа*/
field DocType                like ub.trn-doc.doc-type     /*Тип документа*/
field Internal               like ub.trn-doc.internal     /*Флаг внутренний-внешний*/
field Sts                    like ub.trn-doc.status_      /*Статус*/
field Flag                   like ub.trn-doc.flag_        /*Расширение статуса. Также: закрыт без коррекции - yes, с коррекцией - no*/
field DocDate                like ub.trn-doc.doc-date     /*Дата оформления документа*/
field ContractId             like ub.trn-doc.contract-code  /*Внутренний код Договора*/
field ContractNum            like ub.contract.contract-prn-code  /*Номер Договора*/
field ContractDate           like ub.contract.contract-date  /*Дата Договора*/
field SupplCrcCode           like ub.trn-doc.exch-code    /*Код валюты поставщика (только внешний приход)*/
field SupplCrcAbbr           like ub.currency.curr-abbr   /*Аббревиатура валюты поставщика (только внешний приход)*/
field SupplCrcName           like ub.currency.curr-name   /*Название валюты поставщика (только внешний приход)*/
field SupplCrcDate           like ub.trn-doc.exch-date    /*Дата курса валюты поставщика (только внешний приход)*/
field SupplCrcRate           like ub.trn-doc.exch-rate    /*Курс валюты поставщика (только внешний приход)*/
field SupplCrcScale          like ub.trn-doc.exch-scale
field BaseCrcRate            like ub.trn-doc.base-rate    /*Курс базовой валюты */
field BaseCrcScale           like ub.trn-doc.base-scale
field CliType                like ub.trn-doc.cli-type     /*Тип контрагента*/
field CliCode                like ub.trn-doc.cli-code     /*Код контрагента*/
field CliName                like ub.trn-doc.cli-name     /*Название контрагента на момент создания документа*/
field PostIndex              like ub.firm.ind             /*Индекс контрагента*/
field City                   like ub.firm.city            /*Страна, город контрагента*/
field Address                like ub.firm.addres1         /*Адрес контрагента*/
field AddressAdd             like ub.firm.addres2         /*Продолжение адреса контрагента (для контрагента-фирмы)*/
field PostAddress            like ub.firm.post-addr1      /*Почтовый адрес контрагента (для контрагента-фирмы)*/
field PostAddressAdd         like ub.firm.post-addr2      /*Продолжение почтового адресаконтрагента  (для контрагента-фирмы)*/
field EMail                  like ub.firm.e-mail          /*Адрес электронной почты контрагента*/
field Fax                    like ub.firm.fax             /*Номер факса контрагента*/
field Phone                  like ub.firm.phone           /*Телефон контрагента*/
field PhoneNote              like ub.firm.phone1-note     /*Примечание к телефону контрагента*/
field Inn                    like ub.firm.inn             /*И_Н_Н*/
field KPP                    like ub.firm.kpp             /*К_П_П*/
field OKPO                   like ub.firm.okpo            /*ОКПО*/
field OKONH                  like ub.firm.okonh           /*О_К_О_НХ*/
field ContactPerson          like ub.firm.contact-psn     /*Контактное лицо контрагента (для контрагента-фирмы)*/
field Director               like ub.firm.director        /*Руководитель фирмы контрагента (для контрагента-фирмы)*/
field EnglName               like ub.firm.engl-name       /*Англоязычное название контрагента (для контрагента-фирмы)*/
field GenAccnt               like ub.firm.gen-acct        /*Главный бухгалтер контрагента (для контрагента-фирмы)*/
field Telex                  like ub.firm.telex           /*Телекс контрагента (для контрагента-фирмы)*/
field Name                   like ub.person.name1         /*Имя котрагента (для контрагента-физического лица)*/
field Patronymic             like ub.person.name2         /*Отчество контрагента (для контрагента-физического лица)*/
field PassNum                like ub.person.passp-num     /*Номер паспорта контрагента (для контрагента-физического лица)*/
field PassSer                like ub.person.passp-ser     /*Серия паспорта контрагента (для контрагента-физического лица)*/
field GivenBy                like ub.person.given-by      /*Кем выдан паспорт (для контрагента-физического лица)*/
field Position               like ub.person.position      /*Должность (для контрагента-физического лица)*/
field PostBox                like ub.person.post-box      /*А/Я контрагента (для контрагента-физического лица)*/
field BankNameRubl           as   character               /*Название банка контрагента с р_у_блевым счетом (если имеется банк)*/
field BankCodeRubl           as   character               /*БИК банка контрагента с р_у_блевым счетом (если имеется банк)*/
field BankAccRubl            as   character               /*Р_у_блевый счет контрагента (если имеется банк)*/
field AddressBankRubl        as   character               /*Адрес банка контрагента с р_у_блевым счетом (если имеется банк)*/
field AddressAddBankRubl     as   character               /*Дополнение адреса банка контрагента с р_у_блевым счетом (если имеется банк)*/
field PBankAccRubl           as   character               /*Р_у_блевый кор. счет в РКЦ (если имеется банк)*/
field BankNameBase           as   character               /*Название банка контрагента с валютным счетом (если имеется банк)*/
field BankCodeBase           as   character               /*БИК банка контрагента с валютным счетом (если имеется банк)*/
field BankAccBase            as   character               /*Валютный счет контрагента (если имеется банк)*/
field AddressBankBase        as   character               /*Адрес банка контрагента с валютным счетом (если имеется банк)*/
field AddressAddBankBase     as   character               /*Дополнение адреса банка контрагента с валютным счетом (если имеется банк)*/
field PBankAccBase           as   character               /*Валютный кор. счет в РКЦ (если имеется банк)*/
field ObjType                like ub.trn-doc.obj-type     /*Тип объекта учета*/
field ObjCode                like ub.trn-doc.obj-code     /*Код контрагента*/
field ObjName                like ub.clients.obj-name     /*Название объекта*/
field OutCode                like ub.trn-doc.out-code     /*Корреспондирующий документ*/
field ShipNum                like ub.trn-doc.ship-num     /*Отгрузка*/
field ShipDate               like ub.trn-doc.ship-date
field OrdNum                 like ub.trn-doc.ord-num      /*Номер инвойса, выставленного поставщиком*/
field Office                 like ub.trn-doc.office       /*yes - документ с услугами, no - с товарами*/
field FactDate               like ub.trn-doc.fact-date    /*Дата фактического закрытия документа*/
field FactNum                like ub.trn-doc.fact-num     /*Фактический номер*/
field FactOrder              like ub.trn-doc.fact-order   /*Порядковый номер документа в обороте товаров*/
field FactQnty               like ub.trn-doc.fact-qnty    /*Фактическое количество товара*/
/* Кол-во по документу. Для инвентаризации - кол-во до инвентаризации. */
field DocQnty                like ub.trn-doc.doc-qnty  /*(не инвентаризация)*/
field BefQnty                like ub.trn-doc.doc-qnty  /*(только инвентаризация)*/
/* С У М М Ы */
/*tot-cli - для внешнего прихода - сумма в валюте поставщика для проверки
          - все остальное кроме инвентаризации - НЕ ИСПОЛЬЗУЕМ ЗНАЧЕНИЕ В БД НЕВЕРНОЕ, СПУТАНЫ doc И fact кол-ва!!!*/
field CalcSum                as   character             /*Дополнительные суммы рассчитаные по документу*/
field SumCheckFactSuppl      like ub.trn-doc.tot-cli    /*(только внешний приход)*/
field SumFactBaseAcc         like ub.trn-doc.fact-base  /*Фактическая сумма в учетных ценах в базовой валюте*/
field SumFactRublAcc         like ub.trn-doc.fact-rubl  /*Фактическая сумма в учетных ценах в р_у_блях*/

/*tot-calc - для внешнего прихода фактическая сумма в валюте поставщика (т.к. уже есть tot-cli, то употреблять не будем)
           - для инвентаризации - фактическая сумма до инвентаризации в учетных ценах в базовой валюте
           - все остальные - фактическая скидка в ценах документа в базовой валюте */
field SumFactSuppl           like ub.trn-doc.tot-calc  /*(только внешний приход)*/
field SumBefBaseAcc          like ub.trn-doc.tot-calc  /*(только инвентаризация)*/
field DscFactBaseDoc         like ub.trn-doc.tot-calc  /*(не внешний приход и не инвентаризация)*/
field VatType                like ub.trn-doc.vat-type    /*Тип заведения НДС (только внешний приход)*/

/*vat-base(rubl) - фактическая сумма НДС для внешнего прихода по учетным ценам,
                 - для всех остальных фактическая сумма НП по ценам документа*/
field VatFactBaseAcc         like ub.trn-doc.vat-base  /*(только внешний приход)*/
field VatFactBaseDoc         like ub.trn-doc.vat-base  /*(не внешний приход)*/
field VatFactRublAcc         like ub.trn-doc.vat-rubl  /*(только внешний приход)*/
field VatFactRublDoc         like ub.trn-doc.vat-rubl  /*(не внешний приход)*/
field SltType                like ub.trn-doc.slt-type    /*Тип заведения налога с продаж (только внешний приход)*/

/*Slt-base(rubl) - фактическая сумма НП для внешнего прихода по учетным ценам,
                 - для всех остальных фактическая сумма НП по ценам документа*/
field SltFactBaseAcc         like ub.trn-doc.slt-base  /*(только внешний приход)*/
field SltFactBaseDoc         like ub.trn-doc.slt-base  /*(не внешний приход)*/
field SltFactRublAcc         like ub.trn-doc.slt-rubl  /*(только внешний приход)*/
field SltFactRublDoc         like ub.trn-doc.slt-rubl  /*(не внешний приход)*/

/*tot-doc - для внешнего прихода - документарная сумма в учетных ценах в базовой валюте
          - для остальных - документарная сумма в ценах документа в базовой валюте без учета скидки */
field SumDocBaseAcc          like ub.trn-doc.fact-base  /*(внешний приход)*/
field SumDocBaseDoc          like ub.trn-doc.tot-doc   /*(не внешний приход)*/
/*tot-rubl - для внешнего прихода - документарная сумма в учетных ценах в р_у_блях
           - для остальных - документарная сумма в ценах документа в р_у_блях без учета скидки*/
field SumDocRublAcc          like ub.trn-doc.fact-base  /*(внешний приход)*/
field SumDocRublDoc          like ub.trn-doc.tot-rubl   /*(не внешний приход)*/
/*tot-fact - для внешнего прихода - фактическая сумма в учетных ценах в базовой валюте (уже было SumFactBaseAcc)
           - не внешний приход и инвентпризации - фактическая сумма в ценах документа в базовой валюте без учета скидки */
field SumFactBaseDoc         like ub.trn-doc.tot-fact  /*(не внешний приход и инвентаризация)*/
/*tot-sale - для внешнего прихода - фактическая сумма в учетных ценах в р_у_б (уже было SumFactBaseAcc)
           - не внешний приход и инвентпризации - фактическая сумма в ценах документа в р_у_б без учета скидки */
field SumFactRublDoc         like ub.trn-doc.tot-sale  /*(не внешний приход и инвентаризация)*/
/*discnt-rubl - внешний приход не используетс
              - инвентаризация - сумма до инвентаризации в учетных ценах в р_у_блях
              - остальные - фактическая скидка в ценах документа в р_у_блях*/
field DscFactRublDoc         like ub.trn-doc.discnt-rubl /*(не внешний приход и не инвентаризация)*/
field SumBefRublAcc          like ub.trn-doc.discnt-rubl /*(только инвентаризация)*/
/*tot-ov разница сумм между текущей продажной и учетной для внешнего прихода и текущей продажной и по документу для остальных*/
field OvervalueFactSaleacc   like ub.trn-doc.tot-ov /*(внешний приход)*/
field OvervalueFactSaledoc   like ub.trn-doc.tot-ov /*(не внешний приход)*/
field TaxThreeFactSaleAcc        like ub.trn-doc.road-tax   /*сумма налога №3 (стеклопосуда или дорожный налог) в валюте продажи в учетных ценах (только внешний приход)*/
field ExciseFactSaleAcc      like ub.trn-doc.excise         /*сумма акциза в валюте продажи в учетных ценах (только внешний приход)*/
field TransportExpSuppl      like ub.trn-doc.tot-transp     /*сумма транспортных расходов в валюте поставщика (только внешний приход)*/
field OtherExpSuppl          like ub.trn-doc.tot-other      /*сумма прочих расходов в валюте поставщика (только внешний приход)*/
field ExtraQnty              like ub.trn-doc-sum.fact-qnty  /*Количество излишки (только инвентаризация)*/
field ExtraSupplQnty         like ub.trn-doc-sum.fact-qnty  /*Количество поставщика излишки (только инвентаризация)*/
field ExtraFactBaseAcc       like ub.trn-doc-sum.cost-sum-base     /*Излишки в базовой валюте по учетным ценам (только инвентаризация)*/
field ExtraFactRublAcc       like ub.trn-doc-sum.cost-sum-rubl     /*Излишки в р_у_блях по учетным ценам (только инвентаризация)*/
field ExtraFactSale          like ub.trn-doc-sum.sale-sum-base       /*Излишки в текущих ценах продажи (только инвентаризация)*/
field MissQnty               like ub.trn-doc-sum.fact-qnty      /*Количество недостача (только инвентаризация)*/
field MissCliQnty            like ub.trn-doc-sum.fact-qnty      /*Количество поставщика недостача (только инвентаризация)*/
field MissFactBaseAcc        like ub.trn-doc-sum.cost-sum-base      /*Недостача в базовой валюте по учетным ценам (только инвентаризация)*/
field MissFactRublAcc        like ub.trn-doc-sum.cost-sum-rubl      /*Недостача в р_у_блях по учетным ценам (только инвентаризация)*/
field MissFactSale           like ub.trn-doc-sum.sale-sum-base        /*Недостача в текущих ценах продажи (только инвентаризация)*/
field WastageFactSale        like ub.trn-doc-sum.sale-sum-base  /*Естественная убыль в текущих ценах продажи (только инвентаризация)*/
field BefSupplQnty           like ub.trn-doc-sum.fact-qnty  /*Кол-во в единицах поставщика до инвентаризации (только инвентаризация)*/
field AftSupplQnty           like ub.trn-doc-sum.fact-qnty  /*Кол-во в единицах поставщика после инвентаризации (только инвентаризация)*/
field Wrkr                   as   character              /*Кладовщик*/
field Agnt                   as   character              /*Исполнитель*/
field Boss                   as   character              /*Менеджер*/
field InvNum                 like ub.trn-doc.inv-num     /*Номер счета (сопроводит. док-та)*/
field PayCode                like ub.trn-doc.pay-code    /*Код оплаты*/
field DiscntType             like ub.trn-doc.discnt-type /*Тип скидки (не инвентаризация и внешний приход)*/
field DiscntPc               like ub.trn-doc.discnt-pc   /*Процент скидки (не инвентаризация и внешний приход)*/
field Creid                  like ub.trn-doc.creid       /*Оператор*/
field PrintRubl              like ub.trn-doc.print-rubl  /*Расчет цен документа идет от р_у_блевой цены (не инвентаризация и внешний приход)*/
field PS                     like ub.trn-doc.PS          /*Коментарий*/
field Ov                     like ub.trn-doc.ov          /*цена по документу совпадает с текущей продажной ценой на момент закрытия*/
field HostCode               like ub.trn-doc.host-code   /*код фирмы*/
field HostName               like ub.clients.obj-name    /*название фирмы*/
field BgeDate                like ub.trn-doc.bge-date    /*Дата генерации проводки (при наличии бухгалтерии TradeHouse)*/
field TotLines               like ub.trn-doc.tot-lines   /*общее число строк в накладной*/
field CstCode                like ub.trn-doc.cst-code    /*Код ГТД (только для внешнего прихода при множественном заведении в партии)*/
field FactTime               like ub.trn-doc.fact-time   /*Время закрытия документа по факту*/
field ShiftName              like ub.trn-doc.shift-name  /*Номер смены, к которой относится документ*/
field ShiftNum               like ub.trn-doc.shift-num   /*Порядок смены, к которой относится документ*/
field ShiftDate              like ub.trn-doc.shift-date  /*Дата начала смены*/
field RetSupp                like ub.trn-doc.ret-supp    /*Признак возврата поставщику*/
field SupplQnty              like ub.trn-doc.cli-qnty    /*Фактическое количество товара в единицах измерения поставщика (только внешний приход)*/
field SctDate                like ub.trn-doc.scf-date    /*Дата генерации счета-фактуры (при наличии бухгалтерии TradeHouse)*/
field AccDate                like ub.trn-doc.acc-date    /*Дата генерации проводки в бухгалтерии, заполняется автоматически (при наличии бухгалтерии TradeHouse)*/
field BankRublIsHave         as   logical
field BankBaseIsHave         as   logical
field ExpenseOwn             as   decimal                /*расходы не включаемые в учетную цену*/
field RsrvDate               like ub.trn-doc.rsrv-date   /* дата снятия с резерва */
field RsrvTerm               as   integer                /* срок резервирования */
field ReasonCode             as   integer                /* код рснования (причины) создания документа */
index pi is unique primary DocCode
.
define temp-table tt-trn-doc-add no-undo
field DocCode                like ub.trn-doc.doc-code     /*Номер документа*/
field AcctObj                like ub.shop.acct            /*Бухгалтер объекта учета*/
field AddressObj             like ub.shop.addres1         /*Адрес объекта учета*/
field AddressAddObj          like ub.shop.addres2         /*Дополнение к адресу объекта учета*/
field DirectorObj            like ub.shop.director        /*Директор магазина (если объект учета - магазин)*/
field GoodsManObj            like ub.shop.goods-man       /*Товаровед объекта учета (если объект учета - магазин)*/
field PhoneObj               like ub.shop.phone           /*Телефон объекта учета*/
field StoreBossObj           like ub.shop.store-boss      /*Зав. складом объекта учета*/
field StoreManObj            like ub.shop.store-man       /*Кладовщик объекта учета*/
field PostIndexOwn           like ub.firm.ind             /*Индекс своей фирмы*/
field CityOwn                like ub.firm.city            /*Страна, город своей фирмы*/
field AddressOwn             like ub.firm.addres1         /*Адрес своей фирмы*/
field AddressAddOwn          like ub.firm.addres2         /*Продолжение адреса своей фирмы*/
field PostAddressOwn         like ub.firm.post-addr1      /*Почтовый адрес своей фирмы*/
field PostAddressAddOwn      like ub.firm.post-addr2      /*Продолжение почтового адреса своей фирмы*/
field EMailOwn               like ub.firm.e-mail          /*Адрес электронной почты своей фирмы*/
field FaxOwn                 like ub.firm.fax             /*Номер факса своей фирмы*/
field PhoneOwn               like ub.firm.phone           /*Телефон своей фирмы*/
field PhoneNoteOwn           like ub.firm.phone1-note     /*Примечание к телефону своей фирмы*/
field InnOwn                 like ub.firm.inn             /*И_Н_Н своей фирмы*/
field KPPOwn                 like ub.firm.kpp             /*К_П_П своей фирмы*/
field OKPOOwn                like ub.firm.okpo            /*ОКПО своей фирмы*/
field OKONHOwn               like ub.firm.okonh           /*О_К_О_Н_Х своей фирмы*/
field ContactPersonOwn       like ub.firm.contact-psn     /*Контактное лицо своей фирмы*/
field DirectorOwn            like ub.firm.director        /*Руководитель фирмы своей фирмы*/
field EnglNameOwn            like ub.firm.engl-name       /*Англоязычное название своей фирмы */
field GenAccntOwn            like ub.sysconf.snr-accnt    /*Главный бухгалтер своей фирмы*/
field TelexOwn               like ub.firm.telex           /*Телекс своей фирмы */
field BankNameRublOwn        as character                 /*Название банка своей фирмы с р_у_блевым счетом (если имеется банк)*/
field BankCodeRublOwn        as character                 /*БИК банка своей фирмы с р_у_блевым счетом (если имеется банк)*/
field BankAccRublOwn         as character                 /*Р_у_блевый счет своей фирмы (если имеется банк)*/
field AddressBankRublOwn     as character                 /*Адрес банка своей фирмы с р_у_блевым счетом (если имеется банк)*/
field AddressAddBankRublOwn  as character                 /*Дополнение адреса банка своей фирмы с р_у_блевым счетом (если имеется банк)*/
field PBankAccRublOwn        as character                 /*Р_у_блевый кор. счет в РКЦ своей фирмы (если имеется банк)*/
field BankNameBaseOwn        as character                 /*Название банка своей фирмы с валютным счетом (если имеется банк)*/
field BankCodeBaseOwn        as character                 /*БИК банка своей фирмы с валютным счетом (если имеется банк)*/
field BankAccBaseOwn         as character                 /*Валютный счет своей фирмы (если имеется банк)*/
field AddressBankBaseOwn     as character                 /*Адрес банка своей фирмы с валютным счетом (если имеется банк)*/
field AddressAddBankBaseOwn  as character                 /*Дополнение адреса банка своей фирмы с валютным счетом (если имеется банк)*/
field PBankAccBaseOwn        as character                 /*Валютный кор. счет в РКЦ своей фирмы (если имеется банк)*/
field KOPFOwn                like ub.sysconf.kopf         /*КОПФ своей фирмы*/
field SOEIOwn                like ub.sysconf.soei         /*СОЕИ своей фирмы*/
field BranchOwn              like ub.sysconf.branch       /*Отрасль (вид деятельности) своей фирмы */
field PropertyOwn            like ub.sysconf.property     /*Организационно-правовая деятельность своей фирмы*/
field OwnBankRublIsHave      as   logical
field OwnBankBaseIsHave      as   logical
index pi is unique primary DocCode
.


define temp-table tt-doc-line no-undo
field DocCode            like ub.doc-line.doc-code             /*Уникальный номер документа*/
field Artic              like ub.doc-line.artic                /*Артикул товара*/
field ProdType           like ub.doc-line.prod-type            /*Тип производителя*/
field ProdCode           like ub.doc-line.prod-code            /*Код производителя*/
field GdsCode            like ub.goods.gds-code                /*Уникальный код товара*/
field ProdName           like ub.clients.obj-name              /*Название производителя*/
field GdsName            like ub.goods.gds-name                /*Название товара*/
field EnglName           like ub.goods.engl-name               /*Название товара*/
field LabelName          like ub.goods.label-name               /*Название товара*/
field GrpCode            like ub.gds-grp.node-code             /*Код группы товаров*/
field GrpFullName        as   character                        /*Полное название группы товаров*/
field GrpName            like ub.gds-grp.node-name             /*Название группы товаров*/
field UnitBase           like ub.goods.unit-base               /*Основная единица измерения*/
field ObjType            like ub.doc-line.obj-type             /*Тип объекта учета*/
field ObjCode            like ub.doc-line.obj-code             /*Код объекта*/
field ObjName            like ub.clients.obj-name              /*Название объекта учета*/
field ExtDocType         like ub.doc-line.ext-doc-type         /*Расширенный тип документа*/
field FactOrder          like ub.doc-line.fact-order           /*Порядковый номер*/
field Sts                like ub.doc-line.status_              /*Статус документа*/
field SupplQnty          like ub.doc-line.cli-qnty             /*Фактическое количество товара в единицах измерения поставщика (только внешний приход)*/
field SupplRate          like ub.doc-line.cli-base-rate        /*Коэффициент единицы измерения поставщика (только внешний приход)*/
field DocQnty            like ub.doc-line.doc-qnty             /*Документарное количество товара в учетных единицах измерения (кроме инвентаризации)*/
field FactQnty           like ub.doc-line.fact-qnty            /*Фактическое количество товара в учетных единицах измерения*/
field BeforeKgQnty       like ub.inv-line.wast-cli-qnty        /*Вес в кг перед документом (для жидкого топлива)*/
field FactKgQnty         like ub.inv-line.wast-cli-qnty        /*Фактический вес в кг по документу (для жидкого доплива)*/
field AfterKgQnty        like ub.inv-line.wast-cli-qnty        /*Вес в кг перед документом (для жидкого топлива)*/
field PriceAvrgRubl      like ub.doc-line.price-rubl           /*Средняя учетная цена в р_у_блях учетной единицы товара по партиям товара из документа*/
field PriceAvrgBase      like ub.doc-line.price-base           /*Средняя учетная цена в базовой валюте учетной единицы товара по партиям товара из документа*/
field PriceAvrgSuppl     like ub.doc-line.price-cli            /*Средняя учетная цена в валюте поставщика в единицах поставщика товара по партиям товара из документа (только внешний приход)*/
field UnitSuppl          like ub.doc-line.unit-cli             /*Единица измерения поставщика (только для внешнего прихода)*/
field VatPcAcc           like ub.doc-line.vat-pc               /*НДС поставщика (только внешний приход)*/
field VatPcDoc           like ub.doc-line.vat-pc               /*НДС (не внешний приход)*/
field PrtOk              like ub.doc-line.prt-ok               /*Правильное разбиение по шкале*/
field PrtRoot            like ub.doc-line.prt-root             /*Ссылка на внутренний код корневого узла дерева признаков*/
field SltPcAcc           like ub.doc-line.slt-pc               /*НП поставщика (только внешний приход)*/
field SltPcDoc           like ub.doc-line.slt-pc               /*НП документа (не внешний приход)*/
field LineNum            like ub.doc-line.line-num             /*Порядковый номер ввода строки*/
field WtBrutto           like ub.doc-line.wt-brutto            /*Вес брутто (если включена таможня)*/
field NumPlace           like ub.doc-line.num-place            /*Количество мест (если включена таможня)*/
field TaxThreeSupplSale  like ub.doc-line.road-tax             /*Налог №3 (стеклопосуда или дорожный) поставщика в валюте продажи (только внешний приход)*/
field TaxThreeDocSale    like ub.doc-line.road-tax             /*Налог №3 (стеклопосуда или дорожный) документа в валюте продажи (не внешний приход)*/
field ExciseDocSale      like ub.doc-line.excise               /*Акциз документа в валюте продажи (не внешний приход)*/
field Density            like ub.doc-line.fact-density         /*Плотность (для жидкого топлива)*/
field Temperature        like ub.doc-line.temperature          /*Температура (для жидкого топлива)*/
field TransportBase      like ub.doc-line.transport-base       /*Транспортные расходы в базовой валюте (только внешний приход)*/
field TransportRubl      like ub.doc-line.transport-rubl       /*Транспортные расходы в р_у_блях (только внешний приход)*/
field OtherBase          like ub.doc-line.other-base           /*Прочие расходы в базовой валюте (только внешний приход)*/
field OtherRubl          like ub.doc-line.other-rubl           /*Прочие расходы в р_у_блях (только внешний приход)*/
field BeforeQnty         like ub.doc-line-sum.fact-qnty        /*Кол-во перед инвентаризацией (только инвентаризация)*/
field BeforeBaseAcc      like ub.doc-line-sum.cost-sum-base    /*Сумма в учетных ценах в базовой валюте перед инвентаризацией (только инвентаризация)*/
field BeforeRublAcc      like ub.doc-line-sum.cost-sum-rubl    /*Сумма в учетных ценах в р_у_блях перед инвентаризацией (только инвентаризация)*/
field BeforeSale         like ub.doc-line-sum.sale-sum-base    /*Сумма в продажный ценах в валюте продажи перед инвентаризацией (только инвентаризация)*/
field AfterQnty          like ub.doc-line.doc-qnty             /*Количество после инвентаризации (только инвентаризация)*/
field AfterBaseAcc       like ub.doc-line-sum.cost-sum-base    /*Сумма в учетных ценах в базовой валюте после инвентаризации (только инвентаризация)*/
field AfterRublAcc       like ub.doc-line-sum.cost-sum-rubl    /*Сумма в учетных ценах в р_у_блях плосле инвентаризации (только инвентаризация)*/
field AfterSale          like ub.doc-line-sum.sale-sum-base    /*Сумма в продажный ценах в валюте продажи после инвентаризации (только инвентаризация)*/
field ExtraQnty          like ub.doc-line-sum.fact-qnty        /*Излишки количество (только инвентаризация)*/
field ExtraBaseAcc       like ub.doc-line-sum.cost-sum-base    /*Излишки в базовой валюте по учетным ценам (только инвентаризация)*/
field ExtraRublAcc       like ub.doc-line-sum.cost-sum-rubl    /*Излишки в р_у_блях по учетным ценам (только инвентаризация)*/
field ExtraSale          like ub.doc-line-sum.sale-sum-base    /*Излишки в продажных ценах в валюте продажи (только инвентаризация)*/
field MissQnty           like ub.doc-line-sum.fact-qnty        /*Недостача количество (только инвентаризация)*/
field MissBaseAcc        like ub.doc-line-sum.cost-sum-base    /*Недостача в базовой валюте по учетным ценам (только инвентаризация)*/
field MissRublAcc        like ub.doc-line-sum.cost-sum-rubl    /*Недостача в р_у_блях по учетным ценам (только инвентаризация)*/
field MissSale           like ub.doc-line-sum.sale-sum-base    /*Недостача в продажных ценах в валюте продажи (только инвентаризация)*/
field WastageSale        like ub.doc-line-sum.sale-sum-base    /*Естественная убыль в валюте продажи (только инвентаризация)*/
field BeforeCliQnty      like ub.doc-line-sum.fact-qnty        /*Кол-во перед инвентаризацией в единицах поставщика (только инвентаризация)*/
field AfterCliQnty       like ub.doc-line-sum.fact-qnty        /*Кол-во после инвентаризации в единицах поставщика (только инвентаризация)*/
field ExtraCliQnty       like ub.doc-line-sum.fact-qnty        /*Излишки по инвентаризации в единицах поставщика (только инвентаризация)*/
field MissCliQnty        like ub.doc-line-sum.fact-qnty        /*Недостача по инвентаризации в единицах поставщика (только инвентаризация)*/
field SumSignBaseAcc               like ub.ot-line.sum-base          /*Сумма учетных цен в базовой валюте со знаком*/
field SumSignRublAcc               like ub.ot-line.sum-rubl          /*Сумма учетных цен в р_у_блях со знаком*/
field SumSignVatBaseAcc            like ub.ot-line.vat-base          /*Сумма учет. НДС в базовой валюте со знаком*/
field SumSignVatRublAcc            like ub.ot-line.vat-rubl          /*Сумма учет. НДС в р_у_блях со знаком*/
field SumSignSltBaseAcc            like ub.ot-line.slt-base          /*Сумма учет. НП в базовой валюте со знаком*/
field SumSignSltRublAcc            like ub.ot-line.slt-rubl          /*Сумма учет. НП в р_у_блях со знаком*/
field SumSignTaxThreeBaseAcc           like ub.ot-line.road-tax-base     /*Сумма учет. налог №3 (cтеклопосуда, дорожный) в базовой валюте со знаком*/
field SumSignTaxThreeRublAcc           like ub.ot-line.road-tax-rubl     /*Сумма учет. налог №3 (cтеклопосуда, дорожный) в р_у_блях со знаком*/
field SumSignTransportBaseAcc      like ub.ot-line.transport-base    /*Сумма учет. транспортных расходов в базовой валюте со знаком*/
field SumSignTransportRublAcc      like ub.ot-line.transport-rubl    /*Сумма учет. транспортных расходов в р_у_блях со знаком*/
field SumSignOtherBaseAcc          like ub.ot-line.other-base        /*Сумма учет. прочих расходов в базовой валюте со знаком*/
field SumSignOtherRublAcc          like ub.ot-line.other-rubl        /*Сумма учет. прочих расходов в р_у_блях со знаком*/
field SumSignExciseBaseAcc         like ub.ot-line.excise-base       /*Сумма учет. акциза в базовой валюте со знаком*/
field SumSignExciseRublAcc         like ub.ot-line.excise-rubl       /*Сумма учет. акциза в р_у_блях со знаком*/
field SumSignBaseDoc               like ub.ot-line.sum-base          /*Сумма цен документа в базовой валюте со знаком*/
field SumSignRublDoc               like ub.ot-line.sum-rubl          /*Сумма цен документа в р_у_блях со знаком*/
field SumSignVatBaseDoc            like ub.ot-line.vat-base          /*Сумма док. НДС в базовой валюте со знаком*/
field SumSignVatRublDoc            like ub.ot-line.vat-rubl          /*Сумма док. НДС в р_у_блях со знаком*/
field SumSignSltBaseDoc            like ub.ot-line.slt-base          /*Сумма док. НП в базовой валюте со знаком*/
field SumSignSltRublDoc            like ub.ot-line.slt-rubl          /*Сумма док. НП в р_у_блях со знаком*/
field SumSignTaxThreeBaseDoc           like ub.ot-line.road-tax-base     /*Сумма док. налог №3 (cтеклопосуда, дорожный) в базовой валюте со знаком*/
field SumSignTaxThreeRublDoc           like ub.ot-line.road-tax-rubl     /*Сумма док. налог №3 (cтеклопосуда, дорожный) в р_у_блях со знаком*/
field SumSignTransportBaseDoc      like ub.ot-line.transport-base    /*Сумма док. транспортных расходов в базовой валюте со знаком*/
field SumSignTransportRublDoc      like ub.ot-line.transport-rubl    /*Сумма док. транспортных расходов в р_у_блях со знаком*/
field SumSignOtherBaseDoc          like ub.ot-line.other-base        /*Сумма док. прочих расходов в базовой валюте со знаком*/
field SumSignOtherRublDoc          like ub.ot-line.other-rubl        /*Сумма док. прочих расходов в р_у_блях со знаком*/
field SumSignExciseBaseDoc         like ub.ot-line.excise-base       /*Сумма док. акциза в базовой валюте со знаком*/
field SumSignExciseRublDoc         like ub.ot-line.excise-rubl       /*Сумма док. акциза в р_у_блях со знаком*/
field CarNum                       like ub.doc-line-attr.attr-value  /*Гос. N автоцистерны (для внешнего прихода жидкого топлива)*/
field CarVol                       like ub.doc-line-attr.attr-value  /*Объем автоцистерны по паспорту в литрах (для внешнего прихода жидкого топлива)*/
field Tests                        like ub.doc-line-attr.attr-value  /*Проба (для внешнего прихода жидкого топлива)*/
field AutoentObjType               like ub.doc-line-attr.attr-value  /*Тип автопредприятия (для внешнего прихода жидкого топлива)*/
field AutoentObjCode               like ub.doc-line-attr.attr-value  /*Код автопредприятия (для внешнего прихода жидкого топлива)*/
field ItemPour                     like ub.doc-line-attr.attr-value  /*Место налива (для внешнего прихода жидкого топлива)*/
field TimePour                     like ub.doc-line-attr.attr-value  /*Время слива (для внешнего прихода жидкого топлива)*/
field TankVol                      like ub.doc-line-attr.attr-value  /*Объем в автоцистерне (для внешнего прихода жидкого топлива)*/
field TankTemp                     like ub.doc-line-attr.attr-value  /*Температура в автоцистерне (для внешнего прихода жидкого топлива)*/
field TankWater                    like ub.doc-line-attr.attr-value  /*Вода в автоцистерне (для внешнего прихода жидкого топлива)*/
field TankDensity                  like ub.doc-line-attr.attr-value  /*Плотность в автоцистерне (для внешнего прихода жидкого топлива)*/
field TankWeight                   like ub.doc-line-attr.attr-value  /*Вес топлива в автоцистерне (для внешнего прихода жидкого топлива)*/
field TimeIncome                   like ub.doc-line-attr.attr-value  /*Время прибытия (для внешнего прихода жидкого топлива)*/
index pi is unique primary DocCode Artic ProdType ProdCode
index LineNum LineNum
.
define temp-table tt-barcode no-undo
field DocCode as character
field GdsCode as integer
field BarCode as character
index pi
DocCode
GdsCode
BarCode
.
define temp-table tt-gds-dtl no-undo
field DocCode            like ub.gds-dtl.doc-code              /*Уникальный номер документа*/
field ExtDocType         like ub.trn-doc.ext-doc-type          /*Расширенный тип документа*/
field Artic              like ub.gds-dtl.artic                 /*Артикул товара*/
field ProdType           like ub.gds-dtl.prod-type             /*Тип производителя*/
field ProdCode           like ub.gds-dtl.prod-code             /*Код производителя*/
field GdsCode            like ub.goods.gds-code                /*Уникальный код товара*/
field BarCodeUnitBase    like ub.bar-code.b-code               /*Основной бар-код признака на базовую единицу измерения*/
field ProdName           like ub.clients.obj-name              /*Название производителя*/
field GdsName            like ub.goods.gds-name                /*Название товара*/
field PrtCode            like ub.gds-dtl.prt-code              /*Код узла дерева признаков*/
field FullPrtName        like ub.gds-prt.f-name                /*Полное название узла шкалы*/
field ObjType            like ub.gds-dtl.obj-type              /*Тип объекта учета*/
field ObjCode            like ub.gds-dtl.obj-code              /*Код объекта*/
field ObjName            like ub.clients.obj-name              /*Название объекта учета*/
field FactQnty           like ub.gds-dtl.fact-qnty             /*Фактическое количество товара в учетных единицах измерения*/
field AfterQnty          like ub.gds-dtl.fact-qnty             /*Фактическое количество после инвентаризации (только инвентаризация)*/
field DocQnty            like ub.gds-dtl.doc-qnty              /*Документарное количество*/
field PriceRublDoc       like ub.gds-dtl.price-rubl            /*Цена документа - р_у_бли*/
field PriceBaseDoc       like ub.gds-dtl.price-base            /*Цена документа - базовая валюта*/
field DiscntRublDoc      like ub.gds-dtl.discnt-rubl           /*Скидка-р_у_бли*/
field DiscntBaseDoc      like ub.gds-dtl.discnt-base           /*Скидка - базовая валюта*/
field DiscntType         like ub.gds-dtl.discnt-type           /*Логическое поле - скидка по строке процент*/
field DiscntPc           like ub.gds-dtl.discnt-pc             /*Процент скидки*/
field PriceBaseSale      like ub.gds-dtl.cur-base              /*Текущая продажная цена в момент закрытия документа*/
field Ov                 like ub.gds-dtl.ov                    /*Признак - цена документа отличается от текущей продажной цены*/
index pi is unique primary DocCode Artic ProdType ProdCode PrtCode
.
define temp-table tt-parts no-undo
field ObjType                like ub.parts.obj-type             /*Тип объекта учета*/
field ObjCode                like ub.parts.obj-code             /*Код объекта*/
field ObjName                like ub.clients.obj-name           /*Название объекта учета*/
field ContractId             like ub.trn-doc.contract-code  /*Внутренний код Договора*/
field ContractNum            like ub.contract.contract-prn-code  /*Номер Договора*/
field ContractDate           like ub.contract.contract-date  /*Дата Договора*/
field Artic                  like ub.parts.artic                /*Артикул товара*/
field ProdType               like ub.parts.prod-type            /*Тип производителя*/
field ProdCode               like ub.parts.prod-code            /*Код производителя*/
field GdsCode                like ub.goods.gds-code             /*Уникальный код товара*/
field ProdName               like ub.clients.obj-name           /*Название производителя*/
field GdsName                like ub.goods.gds-name             /*Название производителя*/
field InCode                 like ub.parts.in-code              /*Номер приходного документа*/
field OutCode                like ub.parts.out-code             /*Номер документа или зона в которой находится партия*/
field ExtDocType             like ub.trn-doc.ext-doc-type       /*Расширенный тип документа*/
field CountryAlphaOne        like ub.goods.alpha1               /*Код страны 1*/
field CountryAlphaTwo        like ub.country.alpha2             /*Код страны 2*/
field CountryNumCode         like ub.country.num-code           /*Цифр. код страны*/
field CountryLongName        like ub.country.long-name          /*Полное название страны*/
field CountryShortName       like ub.country.long-name          /*Короткое название страны*/
field PartCode               like ub.parts.part-code            /*Код партии*/
field Sign                   as   integer                       /*Знак*/
field DocQnty                like ub.parts.qnty                 /*Количество товара по док-ту в учетных единицах измерения*/
field PriceBaseAcc           like ub.parts.price-base           /*Учетная цена в базовой валюте*/
field PriceRublAcc           like ub.parts.price-rubl           /*Учетная цена в р_у_блях*/
field FactDate               like ub.parts.fact-date            /*Дата документа, породившего партию*/
field FactNum                like ub.parts.fact-num             /*Порядковый номер документа, породившего партию*/
field Sts                    like ub.parts.status_              /*статус документа*/
field VatPcAcc               like ub.parts.VAT-pc               /*Процент НДС поставщика партии*/
field Ps                     like ub.parts.PS                   /*Описание партии*/
field PayCode                like ub.parts.pay-code             /*Код оплаты*/
field FactQnty               like ub.parts.fact-qnty            /*Фактическое количество товара в учетных единицах измерения*/
field SupplType              like ub.parts.supp-type            /*Тип поставщика*/
field SupplCode              like ub.parts.supp-code            /*Код поставщика*/
field SupplName              like ub.clients.obj-name           /*Название поставщика*/
field RsrvFree               like ub.parts.rsrv-free            /*yes - резерв и свободная зона, no - резерв и расходная зона ,? - все остальное*/
field DocType                like ub.parts.doc-type             /*тип документа, на который зарезервирована или закрыта партия*/
field SupplQnty              like ub.parts.cli-qnty             /*Фактическое количество товара в единицах измерения поставщика (только внешний приход)*/
field PlCode                 like ub.parts.pl-code              /*Бар-код складского места*/
field VatType                like ub.parts.VAT-type             /*способ расчета НДС при создании партии*/
field SupplCrcCode           like ub.parts.exch-code            /*Код валюты поставщика*/
field SupplCrcAbbr           like ub.currency.curr-abbr         /*Аббревиатура валюты поставщика (только внешний приход)*/
field SupplCrcName           like ub.currency.curr-name         /*Название валюты поставщика (только внешний приход)*/
field PriceSuppl             like ub.parts.price-cli            /*Цена единицы товара в валюте поставщика в едизмах поставщика*/
field SupplRate              like ub.parts.cli-base-rate        /*Коэффициент поставщика*/
field SltPcAcc               like ub.parts.SLT-pc               /*НП учетный*/
field HostCode               like ub.parts.host-code            /*Код фирмы*/
field IsSupp                 like ub.parts.is-supp              /*yes - создана внешней ПН, no - другим документом*/
field RealQnty               like ub.parts.real-qnty            /*Реальное количество товара в учетных единицах измерения, зарезервированное из положительных партий расходной или свободной зоны (в отличие от вновь созданных партий по данному документу)*/
field SltType                like ub.parts.SLT-type             /*Cпособ расчета НП*/
field CstCode                like ub.parts.cst-code             /*Номер ГТД*/
field LastDate               like ub.parts.last-date            /*дата окончания допустимого срока реализации*/
field TaxThreeBaseAcc        like ub.parts.road-tax-base        /*Налог №3 (стеклопосуда, дорожный налог) в учетных ценах в базовой валюте*/
field TaxThreeRublAcc        like ub.parts.road-tax-rubl        /*Налог №3 (стеклопосуда, дорожный налог) в учетных ценах в р_у_блях*/
field TransportBaseAcc       like ub.parts.transport-base       /*Транспортные расходы в базовой валюте в учетных ценах*/
field TransportRublAcc       like ub.parts.transport-rubl       /*Транспортные расходы в р_у_блях в учетных ценах*/
field OtherBaseAcc           like ub.parts.other-base           /*Прочие расходы в базовой валюте в учетных ценах*/
field OtherRublAcc           like ub.parts.other-rubl           /*Прочие расходы в р_у_блях в учетных ценах*/
field VatBaseAcc             like ub.doc-line.price-base        /*Ценовая компонента НДС в базовой валюте в учетных ценах*/
field VatRublAcc             like ub.doc-line.price-rubl        /*Ценовая компонента НДС в р_у_блях в учетных ценах*/
field SltBaseAcc             like ub.doc-line.price-base        /*Ценовая компонента НП в базовой валюте в учетных ценах*/
field SltRublAcc             like ub.doc-line.price-rubl        /*Ценовая компонента НП в р_у_блях в учетных ценах*/
index pi is primary unique
ObjType
ObjCode
Artic
ProdType
ProdCode
InCode
OutCode
PartCode
.
define temp-table tt-attr no-undo
field DocCode                 like ub.trn-doc.doc-code     /*Номер документа*/
field attr-code               like ub.doc-attr.attr-code   /*Название поля*/
field attr-value              like ub.doc-attr.attr-value  /*значение*/
field attr-type               as character  /* тип параметра */
index pi is unique primary DocCode attr-code
.
define variable v-own-rubl-fmtcli-schet-exists  as logical   no-undo.
define variable v-own-rubl-fmtcli-bank-r-schet  as character no-undo.
define variable v-own-rubl-fmtcli-bank-c-schet  as character no-undo.
define variable v-own-rubl-fmtcli-bank-bik      as character no-undo.
define variable v-own-rubl-fmtcli-bank-name     as character no-undo.
define variable v-own-rubl-fmtcli-bank-addres   as character no-undo.
define variable v-own-base-fmtcli-schet-exists  as logical   no-undo.
define variable v-own-base-fmtcli-bank-r-schet  as character no-undo.
define variable v-own-base-fmtcli-bank-c-schet  as character no-undo.
define variable v-own-base-fmtcli-bank-bik      as character no-undo.
define variable v-own-base-fmtcli-bank-name     as character no-undo.
define variable v-own-base-fmtcli-bank-addres   as character no-undo.
define variable v-cli-rubl-fmtcli-schet-exists  as logical   no-undo.
define variable v-cli-rubl-fmtcli-bank-r-schet  as character no-undo.
define variable v-cli-rubl-fmtcli-bank-c-schet  as character no-undo.
define variable v-cli-rubl-fmtcli-bank-bik      as character no-undo.
define variable v-cli-rubl-fmtcli-bank-name     as character no-undo.
define variable v-cli-rubl-fmtcli-bank-addres   as character no-undo.
define variable v-cli-base-fmtcli-schet-exists  as logical   no-undo.
define variable v-cli-base-fmtcli-bank-r-schet  as character no-undo.
define variable v-cli-base-fmtcli-bank-c-schet  as character no-undo.
define variable v-cli-base-fmtcli-bank-bik      as character no-undo.
define variable v-cli-base-fmtcli-bank-name     as character no-undo.
define variable v-cli-base-fmtcli-bank-addres   as character no-undo.
define variable v-before-qnty                   as decimal   no-undo.
define variable v-fact-qnty                     as decimal   no-undo.
define variable v-abs-fact-qnty                 as decimal   no-undo.
define variable v-after-qnty                    as decimal   no-undo.
define variable v-sort as integer   no-undo .

procedure xml-doc_clear-doc :

  define buffer bf_tt-trn-doc     for tt-trn-doc .
  define buffer bf_tt-trn-doc-add for tt-trn-doc-add.
  do
  on error undo, return error return-value
  :
    for each bf_tt-trn-doc
    on error undo, return error return-value
    :
      delete bf_tt-trn-doc .
    end.
    for each bf_tt-trn-doc-add
    on error undo, return error return-value
    :
      delete bf_tt-trn-doc-add .
    end.
  end.
end procedure. /* xml-doc_clear-doc */

procedure xml-doc_clear-line :
  define buffer bf_tt-doc-line for tt-doc-line.
  define buffer bf_tt-barcode for tt-barcode.
  do
  on error undo, return error return-value
  :
    for each bf_tt-doc-line
    on error undo, return error return-value
    :
      delete bf_tt-doc-line .
    end.

    for each bf_tt-barcode
    on error undo, return error return-value
    :
      delete bf_tt-barcode .
    end.

  end.
end procedure. /* xml-doc_clear-line */

procedure xml-doc_clear-dtl :
  define buffer bf_tt-gds-dtl  for tt-gds-dtl.
  do
  on error undo, return error return-value
  :
    for each bf_tt-gds-dtl
    on error undo, return error return-value
    :
      delete bf_tt-gds-dtl .
    end.

  end.
end procedure. /* xml-doc_clear-dtl */

procedure xml-doc_clear-parts :
  define buffer bf_tt-parts    for tt-parts.
  do
  on error undo, return error return-value
  :
    for each bf_tt-parts
    on error undo, return error return-value
    :
      delete bf_tt-parts.
    end.

  end.
end procedure. /* xml-doc_clear-parts */

procedure xml-doc_clear-attr :
  define buffer bf_tt-attr    for tt-attr.
  do
  on error undo, return error return-value
  :
    for each bf_tt-attr
    on error undo, return error return-value
    :
      delete bf_tt-attr.
    end.

  end.
end procedure. /* xml-doc_clear-attr */


procedure xml-doc_create-doc :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.

define buffer bf_tt-trn-doc          for tt-trn-doc.
define buffer bf_tt-trn-doc-add      for tt-trn-doc-add.
define buffer bf_trn-doc             for ub.trn-doc.
define buffer bf-ext_trn-doc-sum     for ub.trn-doc-sum.
define buffer bf-ext-cli_trn-doc-sum for ub.trn-doc-sum.
define buffer bf-mis_trn-doc-sum     for ub.trn-doc-sum.
define buffer bf-mis-cli_trn-doc-sum for ub.trn-doc-sum.
define buffer bf-wst_trn-doc-sum     for ub.trn-doc-sum.
define buffer bf-bef-cli_trn-doc-sum for ub.trn-doc-sum.
define buffer bf-aft-cli_trn-doc-sum for ub.trn-doc-sum.

define buffer bf-host_clients        for ub.clients.
define buffer bf-obj_clients         for ub.clients.
define buffer bf_currency            for ub.currency.
define buffer bf_firm                for ub.firm.
define buffer bf_person              for ub.person.
define buffer bf_shop                for ub.shop.
define buffer bf_store               for ub.store.
define buffer bf-own_firm            for ub.firm.
define buffer bf_sysconf             for ub.sysconf.
define buffer bf-contract            for ub.contract.
define buffer bf-wrkr_clients        for ub.clients.
define buffer bf-agnt_clients        for ub.clients.
define buffer bf-boss_clients        for ub.clients.

define variable par-type as character no-undo.
define variable varvalue as character no-undo.
define variable vartype  as character no-undo.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
if error-status:error then do:
  return error substitute ("Не найден документ с номером &1.", pardoc-code).
end.
find first bf-obj_clients where bf-obj_clients.obj-type = bf_trn-doc.obj-type and
                                bf-obj_clients.obj-code = bf_trn-doc.obj-code no-lock.
find first bf-host_clients where bf-host_clients.obj-type = {&cmp}               and
                                 bf-host_clients.obj-code = bf_trn-doc.host-code no-lock.
find first bf-wrkr_clients where bf-wrkr_clients.obj-type = {&prs} and
                                 bf-wrkr_clients.obj-code = bf_trn-doc.wrkr no-lock no-error.
find first bf-agnt_clients where bf-agnt_clients.obj-type = {&prs} and
                                 bf-agnt_clients.obj-code = bf_trn-doc.agnt no-lock no-error.
find first bf-boss_clients where bf-boss_clients.obj-type = {&prs} and
                                 bf-boss_clients.obj-code = bf_trn-doc.boss no-lock no-error.
if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
  find first bf_currency where bf_currency.curr-code = bf_trn-doc.exch-code no-lock.
end.
if bf_trn-doc.obj-type = {&shop} then do:
  find first bf_shop where bf_shop.obj-code = bf_trn-doc.obj-code no-lock.
end.
else do:
  find first bf_store where bf_store.obj-code = bf_trn-doc.obj-code no-lock.
end.
find first bf-own_firm where bf-own_firm.firm-code = bf_trn-doc.host-code no-lock.
find first bf_sysconf  where bf_sysconf.host-code  = bf_trn-doc.host-code no-lock.
run fmtcli-get-bank in this-procedure
 (input bf_sysconf.host-code,
  input {&cmp},
  input bf_sysconf.host-code,
  input 0).
if v-fmtcli-schet-exists then do:
  assign
    v-own-rubl-fmtcli-schet-exists  = yes
    v-own-rubl-fmtcli-bank-r-schet  = v-fmtcli-bank-r-schet
    v-own-rubl-fmtcli-bank-c-schet  = v-fmtcli-bank-c-schet
    v-own-rubl-fmtcli-bank-bik      = v-fmtcli-bank-bik
    v-own-rubl-fmtcli-bank-name     = v-fmtcli-bank-name
    v-own-rubl-fmtcli-bank-addres   = v-fmtcli-bank-addres
  .
end.
else do:
  assign
    v-own-rubl-fmtcli-schet-exists  = no.
end.
if bf_sysconf.base-code <> 0 then do:
  run fmtcli-get-bank in this-procedure
   (input bf_sysconf.host-code,
    input {&cmp},
    input bf_sysconf.host-code,
    input bf_sysconf.base-code).
  if v-fmtcli-schet-exists then do:
    assign
      v-own-base-fmtcli-schet-exists  = yes
      v-own-base-fmtcli-bank-r-schet  = v-fmtcli-bank-r-schet
      v-own-base-fmtcli-bank-c-schet  = v-fmtcli-bank-c-schet
      v-own-base-fmtcli-bank-bik      = v-fmtcli-bank-bik
      v-own-base-fmtcli-bank-name     = v-fmtcli-bank-name
      v-own-base-fmtcli-bank-addres   = v-fmtcli-bank-addres
    .
  end.
  else do:
    assign
      v-own-base-fmtcli-schet-exists  = no.
  end.
end.
else do:
  assign
    v-own-base-fmtcli-schet-exists = no.
end.
find first bf-contract no-lock where bf-contract.contract-code = bf_trn-doc.contract-code and
                                     bf-contract.host-code     = bf_trn-doc.host-code no-error .

create bf_tt-trn-doc.
create bf_tt-trn-doc-add.
assign
  bf_tt-trn-doc.DocCode                = bf_trn-doc.doc-code
  bf_tt-trn-doc.ExtDocType             = bf_trn-doc.ext-doc-type
  bf_tt-trn-doc.ExtDocTypeName         = entry (lookup (bf_trn-doc.ext-doc-type, {&TDEDT_List}), {&TDEDT_List-Full})
  bf_tt-trn-doc.DocType                = bf_trn-doc.doc-type
  bf_tt-trn-doc.Internal               = bf_trn-doc.internal
  bf_tt-trn-doc.Sts                    = bf_trn-doc.status_
  bf_tt-trn-doc.Flag                   = bf_trn-doc.flag_
  bf_tt-trn-doc.DocDate                = bf_trn-doc.doc-date
  bf_tt-trn-doc.ContractId             = (if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or bf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price} then bf_trn-doc.contract-code else 0)
  bf_tt-trn-doc.BaseCrcRate            = bf_trn-doc.base-rate
  bf_tt-trn-doc.BaseCrcScale           = bf_trn-doc.base-scale
  bf_tt-trn-doc.CliType                = bf_trn-doc.cli-type
  bf_tt-trn-doc.CliCode                = bf_trn-doc.cli-code
  bf_tt-trn-doc.CliName                = bf_trn-doc.cli-name
  bf_tt-trn-doc.ObjType                = bf_trn-doc.obj-type
  bf_tt-trn-doc.ObjCode                = bf_trn-doc.obj-code
  bf_tt-trn-doc.ObjName                = bf-obj_clients.obj-name
  bf_tt-trn-doc.ShipNum                = bf_trn-doc.ship-num
  bf_tt-trn-doc.ShipDate               = bf_trn-doc.ship-date
  bf_tt-trn-doc.OrdNum                 = bf_trn-doc.ord-num
  bf_tt-trn-doc.Office                 = bf_trn-doc.office
  bf_tt-trn-doc.FactDate               = bf_trn-doc.fact-date
  bf_tt-trn-doc.FactNum                = bf_trn-doc.fact-num
  bf_tt-trn-doc.FactOrder              = bf_trn-doc.fact-order
  bf_tt-trn-doc.FactQnty               = bf_trn-doc.fact-qnty
  bf_tt-trn-doc.SumFactBaseAcc         = bf_trn-doc.fact-base
  bf_tt-trn-doc.SumFactRublAcc         = bf_trn-doc.fact-rubl
  bf_tt-trn-doc.VatType                = bf_trn-doc.vat-type
  bf_tt-trn-doc.SltType                = bf_trn-doc.slt-type
  bf_tt-trn-doc.Wrkr                   = (if available bf-wrkr_clients then bf-wrkr_clients.obj-name else "":u)
  bf_tt-trn-doc.Agnt                   = (if available bf-agnt_clients then bf-agnt_clients.obj-name else "":u)
  bf_tt-trn-doc.Boss                   = (if available bf-boss_clients then bf-boss_clients.obj-name else "":u)
  bf_tt-trn-doc.PayCode                = bf_trn-doc.pay-code
  bf_tt-trn-doc.Creid                  = bf_trn-doc.creid
  bf_tt-trn-doc.PrintRubl              = bf_trn-doc.print-rubl
  bf_tt-trn-doc.PS                     = bf_trn-doc.PS
  bf_tt-trn-doc.Ov                     = bf_trn-doc.ov
  bf_tt-trn-doc.HostCode               = bf_trn-doc.host-code
  bf_tt-trn-doc.HostName               = bf-host_clients.obj-name
  bf_tt-trn-doc-add.PostIndexOwn       = bf-own_firm.ind
  bf_tt-trn-doc-add.CityOwn            = bf-own_firm.city
  bf_tt-trn-doc-add.AddressOwn         = bf-own_firm.addres1
  bf_tt-trn-doc-add.AddressAddOwn      = bf-own_firm.addres2
  bf_tt-trn-doc-add.PostAddressOwn     = bf-own_firm.post-addr1
  bf_tt-trn-doc-add.PostAddressAddOwn  = bf-own_firm.post-addr2
  bf_tt-trn-doc-add.EMailOwn           = bf-own_firm.e-mail
  bf_tt-trn-doc-add.FaxOwn             = bf-own_firm.fax
  bf_tt-trn-doc-add.PhoneOwn           = bf-own_firm.phone
  bf_tt-trn-doc-add.InnOwn             = bf-own_firm.inn
  bf_tt-trn-doc-add.KPPOwn             = bf-own_firm.kpp
  bf_tt-trn-doc-add.OKPOOwn            = bf-own_firm.okpo
  bf_tt-trn-doc-add.OKONHOwn           = bf-own_firm.okonh
  bf_tt-trn-doc-add.PhoneNoteOwn       = bf-own_firm.phone1-note
  bf_tt-trn-doc-add.ContactPersonOwn   = bf-own_firm.contact-psn
  bf_tt-trn-doc-add.DirectorOwn        = bf-own_firm.director
  bf_tt-trn-doc-add.EnglNameOwn        = bf-own_firm.engl-name
  bf_tt-trn-doc-add.GenAccntOwn        = bf_sysconf.snr-accnt
  bf_tt-trn-doc-add.TelexOwn           = bf-own_firm.telex
.
if available bf-contract then do:
   assign
     bf_tt-trn-doc.ContractNum            = bf-contract.contract-prn-code
     bf_tt-trn-doc.ContractDate           = bf-contract.contract-date
   .
end.
else do:
   assign
     bf_tt-trn-doc.ContractNum            = ""
     bf_tt-trn-doc.ContractDate           = ?
   .
end.
if v-own-rubl-fmtcli-schet-exists then do:
  assign
    bf_tt-trn-doc-add.OwnBankRublIsHave      = yes
    bf_tt-trn-doc-add.BankNameRublOwn        = v-own-rubl-fmtcli-bank-name
    bf_tt-trn-doc-add.BankCodeRublOwn        = v-own-rubl-fmtcli-bank-bik
    bf_tt-trn-doc-add.BankAccRublOwn         = v-own-rubl-fmtcli-bank-r-schet
    bf_tt-trn-doc-add.AddressBankRublOwn     = v-own-rubl-fmtcli-bank-addres
    bf_tt-trn-doc-add.AddressAddBankRublOwn  = "":u
    bf_tt-trn-doc-add.PBankAccRublOwn        = v-own-rubl-fmtcli-bank-c-schet
  .
end.
else do:
  assign
    bf_tt-trn-doc-add.OwnBankRublIsHave = no.
end.
if v-own-base-fmtcli-schet-exists then do:
  assign
    bf_tt-trn-doc-add.OwnBankBaseIsHave      = yes
    bf_tt-trn-doc-add.BankNameBaseOwn        = v-own-base-fmtcli-bank-name
    bf_tt-trn-doc-add.BankCodeBaseOwn        = v-own-base-fmtcli-bank-bik
    bf_tt-trn-doc-add.BankAccBaseOwn         = v-own-base-fmtcli-bank-r-schet
    bf_tt-trn-doc-add.AddressBankBaseOwn     = v-own-base-fmtcli-bank-addres
    bf_tt-trn-doc-add.AddressAddBankBaseOwn  = "":u
    bf_tt-trn-doc-add.PBankAccBaseOwn        = v-own-base-fmtcli-bank-c-schet
  .
end.
else do:
  assign
    bf_tt-trn-doc-add.OwnBankBaseIsHave = no.
end
.
assign
  bf_tt-trn-doc-add.KOPFOwn     = bf_sysconf.kopf
  bf_tt-trn-doc-add.SOEIOwn     = bf_sysconf.soei
  bf_tt-trn-doc-add.BranchOwn   = bf_sysconf.branch
  bf_tt-trn-doc-add.PropertyOwn = bf_sysconf.property
.
assign
  bf_tt-trn-doc.TotLines               = bf_trn-doc.tot-lines
  bf_tt-trn-doc.FactTime               = bf_trn-doc.fact-time
  bf_tt-trn-doc.RetSupp                = bf_trn-doc.ret-supp
  bf_tt-trn-doc.RsrvDate               = bf_trn-doc.rsrv-date
  bf_tt-trn-doc.RsrvTerm               = bf_trn-doc.rsrv-date - bf_trn-doc.doc-date
  bf_tt-trn-doc.ReasonCode             = bf_trn-doc.reason-code
   .
if bf_trn-doc.cli-type = {&cmp} then do:
  find first bf_firm where bf_firm.firm-code = bf_trn-doc.cli-code no-lock no-error.
  if not available bf_firm then do:
    return error substitute ("Не найдена фирма-контрагент с кодом &1.", bf_trn-doc.cli-code).
  end.
end.
else do:
  if bf_trn-doc.cli-type = {&shop}  or
     bf_trn-doc.cli-type = {&stock} then do:
    find first bf_firm where bf_firm.firm-code = bf_trn-doc.host-code no-lock no-error.
    if not available bf_firm then do:
      return error substitute ("Не найдена фирма-контрагент с кодом &1.", bf_trn-doc.cli-code).
    end.
  end.
  else do:
    find first bf_person where bf_person.psn-code = bf_trn-doc.cli-code no-lock no-error.
    if not available bf_person then do:
      return error substitute ("Не найдено физ. лицо-контрагент с кодом &1.", bf_trn-doc.cli-code).
    end.
  end.
end.
run fmtcli-get-bank in this-procedure
 (input bf_sysconf.host-code,
  input bf_trn-doc.cli-type,
  input bf_trn-doc.cli-code,
  input 0).
if v-fmtcli-schet-exists then do:
  assign
    v-cli-rubl-fmtcli-schet-exists  = yes
    v-cli-rubl-fmtcli-bank-r-schet  = v-fmtcli-bank-r-schet
    v-cli-rubl-fmtcli-bank-c-schet  = v-fmtcli-bank-c-schet
    v-cli-rubl-fmtcli-bank-bik      = v-fmtcli-bank-bik
    v-cli-rubl-fmtcli-bank-name     = v-fmtcli-bank-name
    v-cli-rubl-fmtcli-bank-addres   = v-fmtcli-bank-addres
  .
end.
else do:
  assign
    v-cli-rubl-fmtcli-schet-exists  = no.
end.
if bf_sysconf.base-code <> 0 then do:
  run fmtcli-get-bank in this-procedure
   (input bf_sysconf.host-code,
    input bf_trn-doc.cli-type,
    input bf_trn-doc.cli-code,
    input bf_sysconf.base-code).
  if v-fmtcli-schet-exists then do:
    assign
      v-cli-base-fmtcli-schet-exists  = yes
      v-cli-base-fmtcli-bank-r-schet  = v-fmtcli-bank-r-schet
      v-cli-base-fmtcli-bank-c-schet  = v-fmtcli-bank-c-schet
      v-cli-base-fmtcli-bank-bik      = v-fmtcli-bank-bik
      v-cli-base-fmtcli-bank-name     = v-fmtcli-bank-name
      v-cli-base-fmtcli-bank-addres   = v-fmtcli-bank-addres
    .
  end.
  else do:
    assign
      v-cli-base-fmtcli-schet-exists  = no.
  end.
end.
else do:
  assign
    v-cli-base-fmtcli-schet-exists = no.
end.

assign
  bf_tt-trn-doc.PostIndex = (if bf_trn-doc.cli-type = {&cmp} or bf_trn-doc.cli-type = {&shop} or bf_trn-doc.cli-type = {&stock} then bf_firm.ind     else bf_person.ind)
  bf_tt-trn-doc.City      = (if bf_trn-doc.cli-type = {&cmp} or bf_trn-doc.cli-type = {&shop} or bf_trn-doc.cli-type = {&stock} then bf_firm.city    else bf_person.city)
  bf_tt-trn-doc.Address   = (if bf_trn-doc.cli-type = {&cmp} or bf_trn-doc.cli-type = {&shop} or bf_trn-doc.cli-type = {&stock} then bf_firm.addres1 else bf_person.address)
  .
if bf_trn-doc.cli-type = {&cmp} or bf_trn-doc.cli-type = {&shop} or bf_trn-doc.cli-type = {&stock} then do:
  assign
    bf_tt-trn-doc.AddressAdd     = bf_firm.addres2
    bf_tt-trn-doc.PostAddress    = bf_firm.post-addr1
    bf_tt-trn-doc.PostAddressAdd = bf_firm.post-addr2
  .
end.
assign
  bf_tt-trn-doc.EMail     = (if bf_trn-doc.cli-type = {&cmp} or bf_trn-doc.cli-type = {&shop} or bf_trn-doc.cli-type = {&stock} then bf_firm.e-mail      else bf_person.e-mail)
  bf_tt-trn-doc.Fax       = (if bf_trn-doc.cli-type = {&cmp} or bf_trn-doc.cli-type = {&shop} or bf_trn-doc.cli-type = {&stock} then bf_firm.fax         else bf_person.fax)
  bf_tt-trn-doc.Phone     = (if bf_trn-doc.cli-type = {&cmp} or bf_trn-doc.cli-type = {&shop} or bf_trn-doc.cli-type = {&stock} then bf_firm.phone       else bf_person.phone1)
  bf_tt-trn-doc.PhoneNote = (if bf_trn-doc.cli-type = {&cmp} or bf_trn-doc.cli-type = {&shop} or bf_trn-doc.cli-type = {&stock} then bf_firm.phone1-note else bf_person.phone1-note)
  bf_tt-trn-doc.Inn       = (if bf_trn-doc.cli-type = {&cmp} or bf_trn-doc.cli-type = {&shop} or bf_trn-doc.cli-type = {&stock} then bf_firm.inn         else bf_person.inn)
  bf_tt-trn-doc.KPP       = (if bf_trn-doc.cli-type = {&cmp} or bf_trn-doc.cli-type = {&shop} or bf_trn-doc.cli-type = {&stock} then bf_firm.kpp         else bf_person.kpp)
  bf_tt-trn-doc.OKPO      = (if bf_trn-doc.cli-type = {&cmp} or bf_trn-doc.cli-type = {&shop} or bf_trn-doc.cli-type = {&stock} then bf_firm.okpo        else bf_person.okpo)
  bf_tt-trn-doc.OKONH     = (if bf_trn-doc.cli-type = {&cmp} or bf_trn-doc.cli-type = {&shop} or bf_trn-doc.cli-type = {&stock} then bf_firm.okonh       else bf_person.okonh)

.
if bf_trn-doc.cli-type = {&cmp} or bf_trn-doc.cli-type = {&shop} or bf_trn-doc.cli-type = {&stock} then do:
  assign
    bf_tt-trn-doc.ContactPerson = bf_firm.contact-psn
    bf_tt-trn-doc.Director      = bf_firm.director
    bf_tt-trn-doc.EnglName      = bf_firm.engl-name
    bf_tt-trn-doc.GenAccnt      = bf_firm.gen-acct
    bf_tt-trn-doc.Telex         = bf_firm.telex
    .
end.
else do:
  assign
    bf_tt-trn-doc.Name       = bf_person.name1
    bf_tt-trn-doc.Patronymic = bf_person.name2
    bf_tt-trn-doc.PassNum    = bf_person.passp-num
    bf_tt-trn-doc.PassSer    = bf_person.passp-ser
    bf_tt-trn-doc.GivenBy    = bf_person.given-by
    bf_tt-trn-doc.Position   = bf_person.position
    bf_tt-trn-doc.PostBox    = bf_person.post-box
  .
end.
if v-cli-rubl-fmtcli-schet-exists then do:
  assign
    bf_tt-trn-doc.BankRublIsHave      = yes
    bf_tt-trn-doc.BankNameRubl        = v-cli-rubl-fmtcli-bank-name
    bf_tt-trn-doc.BankCodeRubl        = v-cli-rubl-fmtcli-bank-bik
    bf_tt-trn-doc.BankAccRubl         = v-cli-rubl-fmtcli-bank-r-schet
    bf_tt-trn-doc.AddressBankRubl     = v-cli-rubl-fmtcli-bank-addres
    bf_tt-trn-doc.AddressAddBankRubl  = "":u
    bf_tt-trn-doc.PBankAccRubl        = v-cli-rubl-fmtcli-bank-c-schet
   .
end.
else do:
  assign
    bf_tt-trn-doc.BankRublIsHave      = no.
end.
if v-cli-base-fmtcli-schet-exists then do:
  assign
    bf_tt-trn-doc.BankBaseIsHave       = yes
    bf_tt-trn-doc.BankNameBase         = v-cli-base-fmtcli-bank-name
    bf_tt-trn-doc.BankCodeBase         = v-cli-base-fmtcli-bank-bik
    bf_tt-trn-doc.BankAccBase          = v-cli-base-fmtcli-bank-r-schet
    bf_tt-trn-doc.AddressBankBase      = v-cli-base-fmtcli-bank-addres
    bf_tt-trn-doc.AddressAddBankBase   = "":u
    bf_tt-trn-doc.PBankAccBase         = v-cli-base-fmtcli-bank-c-schet
  .
end.
else do:
  assign
    bf_tt-trn-doc.BankBaseIsHave      = no.
end.
  assign
    bf_tt-trn-doc.BgeDate = bf_trn-doc.bge-date
    bf_tt-trn-doc.SctDate = bf_trn-doc.scf-date
    bf_tt-trn-doc.AccDate = bf_trn-doc.acc-date
    bf_tt-trn-doc.InvNum  = bf_trn-doc.inv-num    .
if varshift = "yes" then do:
  assign
    bf_tt-trn-doc.ShiftNum  = bf_trn-doc.shift-num
    bf_tt-trn-doc.ShiftName = bf_trn-doc.shift-name
    bf_tt-trn-doc.ShiftDate = bf_trn-doc.shift-date .
end.

if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
  assign
    bf_tt-trn-doc.SupplCrcCode         = bf_trn-doc.exch-code
    bf_tt-trn-doc.SupplCrcAbbr         = bf_currency.curr-abbr
    bf_tt-trn-doc.SupplCrcName         = bf_currency.curr-name
    bf_tt-trn-doc.SupplCrcDate         = bf_trn-doc.exch-date
    bf_tt-trn-doc.SupplCrcRate         = bf_trn-doc.exch-rate
    bf_tt-trn-doc.SupplCrcScale        = bf_trn-doc.exch-scale
    bf_tt-trn-doc.SumCheckFactSuppl    = bf_trn-doc.tot-cli
    bf_tt-trn-doc.SumFactSuppl         = bf_trn-doc.tot-calc
    bf_tt-trn-doc.VatFactBaseAcc       = bf_trn-doc.vat-base
    bf_tt-trn-doc.VatFactRublAcc       = bf_trn-doc.vat-rubl
    bf_tt-trn-doc.SltFactBaseAcc       = bf_trn-doc.slt-base
    bf_tt-trn-doc.SltFactRublAcc       = bf_trn-doc.slt-rubl
    bf_tt-trn-doc.SumDocBaseAcc        = bf_trn-doc.fact-base
    bf_tt-trn-doc.SumDocRublAcc        = bf_trn-doc.fact-base
    bf_tt-trn-doc.OvervalueFactSaleacc = bf_trn-doc.tot-ov
    bf_tt-trn-doc.TaxThreeFactSaleAcc      = bf_trn-doc.road-tax
    bf_tt-trn-doc.ExciseFactSaleAcc    = bf_trn-doc.excise
    bf_tt-trn-doc.TransportExpSuppl    = bf_trn-doc.tot-transp
    bf_tt-trn-doc.OtherExpSuppl        = bf_trn-doc.tot-other
    bf_tt-trn-doc.SupplQnty            = bf_trn-doc.cli-qnty
    bf_tt-trn-doc.CstCode              = bf_trn-doc.cst-code   .
end.
else do:
  assign
    bf_tt-trn-doc.VatFactBaseDoc        = bf_trn-doc.vat-base
    bf_tt-trn-doc.VatFactRublDoc        = bf_trn-doc.vat-rubl
    bf_tt-trn-doc.SltFactBaseDoc        = bf_trn-doc.slt-base
    bf_tt-trn-doc.SltFactRublDoc        = bf_trn-doc.slt-rubl
    bf_tt-trn-doc.SumDocBaseDoc         = bf_trn-doc.tot-doc
    bf_tt-trn-doc.SumDocRublDoc         = bf_trn-doc.tot-rubl
    bf_tt-trn-doc.OvervalueFactSaledoc  = bf_trn-doc.tot-ov    .

end.
if bf_trn-doc.out-code <> ? and
   bf_trn-doc.out-code <> "" then do:
  assign
     bf_tt-trn-doc.OutCode = bf_trn-doc.out-code.
end.
if bf_trn-doc.ext-doc-type = {&TDEDT_Inv}      or
   bf_trn-doc.ext-doc-type = {&TDEDT_Peresort}         or
   bf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}   or
   bf_trn-doc.ext-doc-type = {&TDEDT_Corr_Minus_Parts} or
   bf_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code}   then do:
  { str/tdat-val.i
      bf_trn-doc.doc-code
      {&trdcattr-addsum}
      varvalue
      vartype
      no-error
  }
  if error-status:error then do:
    return error substitute ("Ошибка при вызове процедуры tdat-val &1 &2.", return-value, error-status:get-message(1)).
  end.
  if lookup ({&sum-extra-doc}, varvalue) <> 0 then do:
    find first bf-ext_trn-doc-sum where bf-ext_trn-doc-sum.doc-code = bf_trn-doc.doc-code and
                                        bf-ext_trn-doc-sum.sum-type = {&sum-extra-doc}    no-lock.
    if not available bf-ext_trn-doc-sum then do:
      return error substitute ("Не найдена сумма с типом &1 по документу &2.", {&sum-extra-doc}, bf-ext_trn-doc-sum.doc-code).
    end.
  end.
  if lookup ({&sum-extra-cli-doc}, varvalue) <> 0 then do:
    find first bf-ext-cli_trn-doc-sum where bf-ext-cli_trn-doc-sum.doc-code = bf_trn-doc.doc-code  and
                                            bf-ext-cli_trn-doc-sum.sum-type = {&sum-extra-cli-doc} no-lock.
    if not available bf-ext-cli_trn-doc-sum then do:
      return error substitute ("Не найдена сумма с типом &1 по документу &2.", {&sum-extra-cli-doc}, bf-ext-cli_trn-doc-sum.doc-code).
    end.
  end.
  if lookup ({&sum-miss-doc}, varvalue) <> 0 then do:
    find first bf-mis_trn-doc-sum where bf-mis_trn-doc-sum.doc-code = bf_trn-doc.doc-code and
                                        bf-mis_trn-doc-sum.sum-type = {&sum-miss-doc}     no-lock.
    if not available bf-mis_trn-doc-sum then do:
      return error substitute ("Не найдена сумма с типом &1 по документу &2.", {&sum-miss-doc}, bf-mis_trn-doc-sum.doc-code).
    end.
  end.
  if lookup ({&sum-miss-cli-doc}, varvalue) <> 0 then do:
    find first bf-mis-cli_trn-doc-sum where bf-mis-cli_trn-doc-sum.doc-code = bf_trn-doc.doc-code and
                                            bf-mis-cli_trn-doc-sum.sum-type = {&sum-miss-cli-doc} no-lock.
    if not available bf-mis-cli_trn-doc-sum then do:
      return error substitute ("Не найдена сумма с типом &1 по документу &2.", {&sum-miss-cli-doc}, bf-mis-cli_trn-doc-sum.doc-code).
    end.
  end.
  if lookup ({&sum-wastage-doc}, varvalue) <> 0 then do:
    find first bf-wst_trn-doc-sum where bf-wst_trn-doc-sum.doc-code = bf_trn-doc.doc-code and
                                        bf-wst_trn-doc-sum.sum-type = {&sum-wastage-doc}  no-lock.
    if not available bf-wst_trn-doc-sum then do:
      return error substitute ("Не найдена сумма с типом &1 по документу &2.", {&sum-wastage-doc}, bf-wst_trn-doc-sum.doc-code).
    end.
  end.
  if lookup ({&sum-before-cli-doc}, varvalue) <> 0 then do:
    find first bf-bef-cli_trn-doc-sum where bf-bef-cli_trn-doc-sum.doc-code = bf_trn-doc.doc-code   and
                                            bf-bef-cli_trn-doc-sum.sum-type = {&sum-before-cli-doc} no-lock.
    if not available bf-bef-cli_trn-doc-sum then do:
      return error substitute ("Не найдена сумма с типом &1 по документу &2.", {&sum-before-cli-doc}, bf-bef-cli_trn-doc-sum.doc-code).
    end.
  end.
  if lookup ({&sum-after-cli-doc}, varvalue) <> 0 then do:
    find first bf-aft-cli_trn-doc-sum where bf-aft-cli_trn-doc-sum.doc-code = bf_trn-doc.doc-code  and
                                            bf-aft-cli_trn-doc-sum.sum-type = {&sum-after-cli-doc} no-lock.
    if not available bf-aft-cli_trn-doc-sum then do:
      return error substitute ("Не найдена сумма с типом &1 по документу &2.", {&sum-after-cli-doc}, bf-aft-cli_trn-doc-sum.doc-code).
    end.
  end.
  assign
    bf_tt-trn-doc.BefQnty                = bf_trn-doc.doc-qnty
    bf_tt-trn-doc.CalcSum                = varvalue
    bf_tt-trn-doc.SumBefBaseAcc          = bf_trn-doc.tot-calc
    bf_tt-trn-doc.SumBefRublAcc          = bf_trn-doc.discnt-rubl
    bf_tt-trn-doc.ExtraQnty              = (if available bf-ext_trn-doc-sum     then bf-ext_trn-doc-sum.fact-qnty         else ?)
    bf_tt-trn-doc.ExtraSupplQnty         = (if available bf-ext-cli_trn-doc-sum then bf-ext-cli_trn-doc-sum.fact-qnty     else ?)
    bf_tt-trn-doc.ExtraFactBaseAcc       = (if available bf-ext_trn-doc-sum     then bf-ext_trn-doc-sum.cost-sum-base     else ?)
    bf_tt-trn-doc.ExtraFactRublAcc       = (if available bf-ext_trn-doc-sum     then bf-ext_trn-doc-sum.cost-sum-rubl     else ?)
    bf_tt-trn-doc.ExtraFactSale          = (if available bf-ext_trn-doc-sum     then (if varr-b = "base" then bf-ext_trn-doc-sum.sale-sum-base else bf-ext_trn-doc-sum.sale-sum-rubl) else ?)
    bf_tt-trn-doc.MissQnty               = (if available bf-mis_trn-doc-sum     then bf-mis_trn-doc-sum.fact-qnty         else ?)
    bf_tt-trn-doc.MissCliQnty            = (if available bf-mis-cli_trn-doc-sum then bf-mis-cli_trn-doc-sum.fact-qnty     else ?)
    bf_tt-trn-doc.MissFactBaseAcc        = (if available bf-mis_trn-doc-sum     then bf-mis_trn-doc-sum.cost-sum-base     else ?)
    bf_tt-trn-doc.MissFactRublAcc        = (if available bf-mis_trn-doc-sum     then bf-mis_trn-doc-sum.cost-sum-rubl     else ?)
    bf_tt-trn-doc.MissFactSale           = (if available bf-mis_trn-doc-sum     then (if varr-b = "base" then bf-mis_trn-doc-sum.sale-sum-base else bf-mis_trn-doc-sum.sale-sum-rubl) else ?)
    bf_tt-trn-doc.WastageFactSale        = (if available bf-wst_trn-doc-sum     then (if varr-b = "base" then bf-wst_trn-doc-sum.sale-sum-base else bf-wst_trn-doc-sum.sale-sum-rubl) else ?)
    bf_tt-trn-doc.BefSupplQnty           = (if available bf-bef-cli_trn-doc-sum then bf-bef-cli_trn-doc-sum.fact-qnty     else ?)
    bf_tt-trn-doc.AftSupplQnty           = (if available bf-aft-cli_trn-doc-sum then bf-aft-cli_trn-doc-sum.fact-qnty     else ?)
    .

end.
else do:
  assign
    bf_tt-trn-doc.DocQnty = bf_trn-doc.doc-qnty.
end.
if bf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Vnesh} and
   bf_trn-doc.ext-doc-type <> {&TDEDT_Inv} and
   bf_trn-doc.ext-doc-type <> {&TDEDT_Peresort}         and
   bf_trn-doc.ext-doc-type <> {&TDEDT_Corr_Acc_Price}   and
   bf_trn-doc.ext-doc-type <> {&TDEDT_Corr_Minus_Parts} and
   bf_trn-doc.ext-doc-type <> {&TDEDT_Chg_Purch_Code}   then do:
   assign
     bf_tt-trn-doc.DscFactBaseDoc = bf_trn-doc.tot-calc
     bf_tt-trn-doc.SumFactBaseDoc = bf_trn-doc.tot-fact
     bf_tt-trn-doc.SumFactRublDoc = bf_trn-doc.tot-sale
     bf_tt-trn-doc.DscFactRublDoc = bf_trn-doc.discnt-rubl
     bf_tt-trn-doc.DiscntType     = bf_trn-doc.discnt-type
     bf_tt-trn-doc.DiscntPc       = bf_trn-doc.discnt-pc   .
end.
assign
 bf_tt-trn-doc-add.DocCode       = bf_trn-doc.doc-code
 bf_tt-trn-doc-add.AddressObj    = (if bf_trn-doc.obj-type = {&shop} then bf_shop.addres1 else bf_store.addres1)
 bf_tt-trn-doc-add.AddressAddObj = (if bf_trn-doc.obj-type = {&shop} then bf_shop.addres2 else bf_store.addres2)
.
if bf_trn-doc.obj-type = {&shop} then do:
  assign
    bf_tt-trn-doc-add.AcctObj     = entry(1,bf_shop.acct,"|")
    bf_tt-trn-doc-add.DirectorObj = bf_shop.director
    bf_tt-trn-doc-add.GoodsManObj = bf_shop.goods-man
  .
end.
assign
  bf_tt-trn-doc-add.PhoneObj     = (if bf_trn-doc.obj-type = {&shop} then bf_shop.phone      else bf_store.phone)
  bf_tt-trn-doc-add.StoreBossObj = (if bf_trn-doc.obj-type = {&shop} then bf_shop.store-boss else bf_store.store-boss)
  bf_tt-trn-doc-add.StoreManObj  = (if bf_trn-doc.obj-type = {&shop} then bf_shop.store-man  else bf_store.store-man)
.
end.
if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
  { str/tdat-val.i
      bf_trn-doc.doc-code
      {&trdcattr-expense_own}
      varvalue
      vartype
      no-error
  }
  if error-status:error then do:
    return error substitute ("Ошибка при вызове процедуры tdat-val &1 &2.", return-value, error-status:get-message(1)).
  end.
  assign
    bf_tt-trn-doc.ExpenseOwn = decimal(varvalue).
end.

end procedure. /*xml-doc_create-doc*/

procedure xml-doc_create-line :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_tt-doc-line          for tt-doc-line.
define buffer bf_doc-line             for ub.doc-line.
define buffer bf-ext_doc-line-sum     for ub.doc-line-sum.
define buffer bf-ext-cli_doc-line-sum for ub.doc-line-sum.
define buffer bf-mis_doc-line-sum     for ub.doc-line-sum.
define buffer bf-mis-cli_doc-line-sum for ub.doc-line-sum.
define buffer bf-wst_doc-line-sum     for ub.doc-line-sum.
define buffer bf-bef-cli_doc-line-sum for ub.doc-line-sum.
define buffer bf-aft-cli_doc-line-sum for ub.doc-line-sum.
define buffer bf-bef_doc-line-sum     for ub.doc-line-sum.
define buffer bf-aft_doc-line-sum     for ub.doc-line-sum.
define buffer bf_doc-line-attr        for ub.doc-line-attr.
define buffer bf_goods                for ub.goods.
define buffer bf-obj_clients          for ub.clients.
define buffer bf-prod_clients         for ub.clients.
define buffer bf_trn-doc              for ub.trn-doc.
define buffer bf_gds-grp              for ub.gds-grp.
define variable varis-petrol     as   logical               no-undo.
define variable varis-pieces     as   logical               no-undo.
define variable custvalue        as   character             no-undo.
define variable custtype         as   character             no-undo.
define variable varfact-qnty     like ub.doc-line.fact-qnty no-undo.
define variable varvat-pc        like ub.doc-line.vat-pc    no-undo.
define variable varslt-pc        like ub.doc-line.slt-pc    no-undo.
define variable varvalue         as   character             no-undo.
define variable vartype          as   character             no-undo.
define variable varfull-grp-name as   character             no-undo.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
if error-status:error then do:
  return error substitute ("Не найден документ с номером &1.", pardoc-code).
end.
run gbl/conf-rd.p ("is-custm" , "", "", 0, "", "", "", no, output custvalue, output custtype) no-error.
for each bf_doc-line where bf_doc-line.doc-code = pardoc-code no-lock on error undo, return error return-value :
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock no-error.
  if not available bf_goods then do:
    return error substitute ("Не найден товар: &1 &2 &3.", bf_doc-line.artic, bf_doc-line.prod-type, bf_doc-line.prod-code).
  end.
  find first bf_gds-grp where bf_gds-grp.node-code = bf_goods.grp-code no-lock no-error.
  if not available bf_gds-grp then do:
    return error substitute ("Не найден группа товаров с кодом &1 для товара: &2 &3 &4.", bf_goods.grp-code, bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
  end.
  run grplib-get-full-name in this-procedure (input bf_gds-grp.node-code, output varfull-grp-name).
  find first bf-prod_clients where bf-prod_clients.obj-type = bf_doc-line.prod-type and
                                   bf-prod_clients.obj-code = bf_doc-line.prod-code no-lock.
  find first bf-obj_clients  where bf-obj_clients.obj-type = bf_doc-line.obj-type and
                                   bf-obj_clients.obj-code = bf_doc-line.obj-code no-lock.
  if bf_trn-doc.ext-doc-type = {&TDEDT_Inv}              or
     bf_trn-doc.ext-doc-type = {&TDEDT_Peresort}         or
     bf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}   or
     bf_trn-doc.ext-doc-type = {&TDEDT_Corr_Minus_Parts} or
     bf_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code}
  then do:
    { str/tdat-val.i
        bf_trn-doc.doc-code
        {&trdcattr-addsum}
        varvalue
        vartype
        no-error
    }
    if error-status:error then do:
      return error substitute ("Ошибка при вызове процедуры tdat-val &1 &2.", return-value, error-status:get-message(1)).
    end.
    if lookup ({&sum-extra-doc}, varvalue) <> 0 then do:
      find first bf-ext_doc-line-sum where bf-ext_doc-line-sum.doc-code = bf_trn-doc.doc-code and
                                           bf-ext_doc-line-sum.gds-code = bf_goods.gds-code   and
                                           bf-ext_doc-line-sum.sum-type = {&sum-extra-doc}    no-lock no-error.
    end.
    if lookup ({&sum-extra-cli-doc}, varvalue) <> 0 then do:
      find first bf-ext-cli_doc-line-sum where bf-ext-cli_doc-line-sum.doc-code = bf_trn-doc.doc-code  and
                                               bf-ext-cli_doc-line-sum.gds-code = bf_goods.gds-code    and
                                               bf-ext-cli_doc-line-sum.sum-type = {&sum-extra-cli-doc} no-lock no-error.
    end.
    if lookup ({&sum-miss-doc}, varvalue) <> 0 then do:
      find first bf-mis_doc-line-sum where bf-mis_doc-line-sum.doc-code = bf_trn-doc.doc-code and
                                           bf-mis_doc-line-sum.gds-code = bf_goods.gds-code   and
                                           bf-mis_doc-line-sum.sum-type = {&sum-miss-doc}     no-lock no-error.
    end.
    if lookup ({&sum-miss-cli-doc}, varvalue) <> 0 then do:
      find first bf-mis-cli_doc-line-sum where bf-mis-cli_doc-line-sum.doc-code = bf_trn-doc.doc-code and
                                               bf-mis-cli_doc-line-sum.gds-code = bf_goods.gds-code   and
                                               bf-mis-cli_doc-line-sum.sum-type = {&sum-miss-cli-doc} no-lock no-error.
    end.
    if lookup ({&sum-wastage-doc}, varvalue) <> 0 then do:
      find first bf-wst_doc-line-sum where bf-wst_doc-line-sum.doc-code = bf_trn-doc.doc-code and
                                           bf-wst_doc-line-sum.gds-code = bf_goods.gds-code   and
                                           bf-wst_doc-line-sum.sum-type = {&sum-wastage-doc}  no-lock no-error.
      if not available bf-wst_doc-line-sum then do:
        return error substitute ("Не найдена сумма с типом &1 по документу &2 товар &3 &4 &5 &6.", {&sum-wastage-doc}, bf-wst_doc-line-sum.doc-code, bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name).
      end.
    end.
    if lookup ({&sum-before-doc}, varvalue) <> 0 then do:
      find first bf-bef_doc-line-sum where bf-bef_doc-line-sum.doc-code = bf_trn-doc.doc-code and
                                           bf-bef_doc-line-sum.gds-code = bf_goods.gds-code   and
                                           bf-bef_doc-line-sum.sum-type = {&sum-before-doc}   no-lock no-error.
      if not available bf-bef_doc-line-sum then do:
        return error substitute ("Не найдена сумма с типом &1 по документу &2 товар &3 &4 &5 &6.", {&sum-before-doc}, bf-bef_doc-line-sum.doc-code, bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name).
      end.
    end.
    if lookup ({&sum-after-doc}, varvalue) <> 0 then do:
      find first bf-aft_doc-line-sum where bf-aft_doc-line-sum.doc-code = bf_trn-doc.doc-code  and
                                           bf-aft_doc-line-sum.gds-code = bf_goods.gds-code    and
                                           bf-aft_doc-line-sum.sum-type = {&sum-after-doc} no-lock no-error.
      if not available bf-aft_doc-line-sum then do:
        return error substitute ("Не найдена сумма с типом &1 по документу &2 товар &3 &4 &5 &6.", {&sum-after-doc}, bf-aft_doc-line-sum.doc-code, bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name).
      end.
    end.
    if lookup ({&sum-before-cli-doc}, varvalue) <> 0 then do:
      find first bf-bef-cli_doc-line-sum where bf-bef-cli_doc-line-sum.doc-code = bf_trn-doc.doc-code   and
                                               bf-bef-cli_doc-line-sum.gds-code = bf_goods.gds-code     and
                                               bf-bef-cli_doc-line-sum.sum-type = {&sum-before-cli-doc} no-lock no-error.
      if not available bf-bef-cli_doc-line-sum then do:
        return error substitute ("Не найдена сумма с типом &1 по документу &2 товар &3 &4 &5 &6.", {&sum-before-cli-doc}, bf-bef-cli_doc-line-sum.doc-code, bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name).
      end.
    end.
    if lookup ({&sum-after-cli-doc}, varvalue) <> 0 then do:
      find first bf-aft-cli_doc-line-sum where bf-aft-cli_doc-line-sum.doc-code = bf_trn-doc.doc-code  and
                                               bf-aft-cli_doc-line-sum.gds-code = bf_goods.gds-code    and
                                               bf-aft-cli_doc-line-sum.sum-type = {&sum-after-cli-doc} no-lock no-error.
      if not available bf-aft-cli_doc-line-sum then do:
        return error substitute ("Не найдена сумма с типом &1 по документу &2 товар &3 &4 &5 &6.", {&sum-after-cli-doc}, bf-aft-cli_doc-line-sum.doc-code, bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_goods.gds-name).
      end.
    end.
  end.
  { str/is-petrl.i
    bf_goods.artic
    bf_goods.prod-type
    bf_goods.prod-code
    varis-petrol
    varis-pieces
    no-error
  }
  if error-status:error then do:
    return error return-value.
  end.
  create bf_tt-doc-line.
  assign
    bf_tt-doc-line.DocCode            = bf_doc-line.doc-code
    bf_tt-doc-line.Artic              = bf_doc-line.artic
    bf_tt-doc-line.ProdType           = bf_doc-line.prod-type
    bf_tt-doc-line.ProdCode           = bf_doc-line.prod-code
    bf_tt-doc-line.GdsCode            = bf_goods.gds-code
    bf_tt-doc-line.ProdName           = bf-prod_clients.obj-name
    bf_tt-doc-line.GdsName            = bf_goods.gds-name
    bf_tt-doc-line.EnglName           = trim(bf_goods.engl-name)
    bf_tt-doc-line.LabelName          = trim(bf_goods.label-name)
    bf_tt-doc-line.GrpCode            = bf_gds-grp.node-code
    bf_tt-doc-line.GrpFullName        = varfull-grp-name
    bf_tt-doc-line.GrpName            = bf_gds-grp.node-name
    bf_tt-doc-line.UnitBase           = bf_goods.unit-base
    bf_tt-doc-line.ObjType            = bf_doc-line.obj-type
    bf_tt-doc-line.ObjCode            = bf_doc-line.obj-code
    bf_tt-doc-line.ObjName            = bf-obj_clients.obj-name
    bf_tt-doc-line.ExtDocType         = bf_doc-line.ext-doc-type
    bf_tt-doc-line.FactOrder          = bf_doc-line.fact-order
    bf_tt-doc-line.Sts                = bf_doc-line.status_
    bf_tt-doc-line.FactQnty           = bf_doc-line.fact-qnty
    bf_tt-doc-line.PriceAvrgRubl      = bf_doc-line.price-rubl
    bf_tt-doc-line.PriceAvrgBase      = bf_doc-line.price-base
    bf_tt-doc-line.PrtOk              = bf_doc-line.prt-ok
    bf_tt-doc-line.PrtRoot            = bf_doc-line.prt-root             .
    run r-cost in this-procedure (input  bf_doc-line.doc-code,
                                  input  bf_doc-line.artic,
                                  input  bf_doc-line.prod-type,
                                  input  bf_doc-line.prod-code,
                                  output varfact-qnty,
                                  output varvat-pc,
                                  output varslt-pc,
                                  output bf_tt-doc-line.SumSignBaseAcc,
                                  output bf_tt-doc-line.SumSignRublAcc,
                                  output bf_tt-doc-line.SumSignVatBaseAcc,
                                  output bf_tt-doc-line.SumSignVatRublAcc,
                                  output bf_tt-doc-line.SumSignSltBaseAcc,
                                  output bf_tt-doc-line.SumSignSltRublAcc,
                                  output bf_tt-doc-line.SumSignTaxThreeBaseAcc,
                                  output bf_tt-doc-line.SumSignTaxThreeRublAcc,
                                  output bf_tt-doc-line.SumSignTransportBaseAcc,
                                  output bf_tt-doc-line.SumSignTransportRublAcc,
                                  output bf_tt-doc-line.SumSignOtherBaseAcc,
                                  output bf_tt-doc-line.SumSignOtherRublAcc,
                                  output bf_tt-doc-line.SumSignExciseBaseAcc,
                                  output bf_tt-doc-line.SumSignExciseRublAcc) no-error.
    if error-status:error then do:
      return error return-value.
    end.
    run r-sale in this-procedure (input  bf_doc-line.doc-code,
                                  input  bf_doc-line.artic,
                                  input  bf_doc-line.prod-type,
                                  input  bf_doc-line.prod-code,
                                  output varfact-qnty,
                                  output varvat-pc,
                                  output varslt-pc,
                                  output bf_tt-doc-line.SumSignBaseDoc,
                                  output bf_tt-doc-line.SumSignRublDoc,
                                  output bf_tt-doc-line.SumSignVatBaseDoc,
                                  output bf_tt-doc-line.SumSignVatRublDoc,
                                  output bf_tt-doc-line.SumSignSltBaseDoc,
                                  output bf_tt-doc-line.SumSignSltRublDoc,
                                  output bf_tt-doc-line.SumSignTaxThreeBaseDoc,
                                  output bf_tt-doc-line.SumSignTaxThreeRublDoc,
                                  output bf_tt-doc-line.SumSignTransportBaseDoc,
                                  output bf_tt-doc-line.SumSignTransportRublDoc,
                                  output bf_tt-doc-line.SumSignOtherBaseDoc,
                                  output bf_tt-doc-line.SumSignOtherRublDoc,
                                  output bf_tt-doc-line.SumSignExciseBaseDoc,
                                  output bf_tt-doc-line.SumSignExciseRublDoc)  no-error.
    if error-status:error then do:
      return error return-value.
    end.
    if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
      assign
        bf_tt-doc-line.SupplQnty          = bf_doc-line.cli-qnty
        bf_tt-doc-line.SupplRate          = bf_doc-line.cli-base-rate
        bf_tt-doc-line.PriceAvrgSuppl     = bf_doc-line.price-cli
        bf_tt-doc-line.UnitSuppl          = bf_doc-line.unit-cli
        bf_tt-doc-line.VatPcAcc           = bf_doc-line.vat-pc
        bf_tt-doc-line.SltPcAcc           = bf_doc-line.slt-pc
        bf_tt-doc-line.LineNum            = bf_doc-line.line-num
        bf_tt-doc-line.TaxThreeSupplSale  = bf_doc-line.road-tax
        bf_tt-doc-line.TransportBase      = bf_doc-line.transport-base
        bf_tt-doc-line.TransportRubl      = bf_doc-line.transport-rubl
        bf_tt-doc-line.OtherBase          = bf_doc-line.other-base
        bf_tt-doc-line.OtherRubl          = bf_doc-line.other-rubl .
    end.
    else do:
      assign
        bf_tt-doc-line.SltPcDoc           = bf_doc-line.slt-pc
        bf_tt-doc-line.VatPcDoc           = bf_doc-line.vat-pc
        bf_tt-doc-line.TaxThreeDocSale        = bf_doc-line.road-tax
        bf_tt-doc-line.ExciseDocSale      = bf_doc-line.excise .
    end.
    if bf_trn-doc.ext-doc-type <> {&TDEDT_Inv}              or
       bf_trn-doc.ext-doc-type <> {&TDEDT_Peresort}         or
       bf_trn-doc.ext-doc-type <> {&TDEDT_Corr_Acc_Price}   or
       bf_trn-doc.ext-doc-type <> {&TDEDT_Corr_Minus_Parts} or
       bf_trn-doc.ext-doc-type <> {&TDEDT_Chg_Purch_Code}   then do:
      assign
        bf_tt-doc-line.DocQnty = bf_doc-line.doc-qnty.
    end.
    if custvalue = "yes" then do:
      assign
        bf_tt-doc-line.WtBrutto = bf_doc-line.wt-brutto
        bf_tt-doc-line.NumPlace = bf_doc-line.num-place .
    end.
    if varis-petrol and
       not varis-pieces then do:
      { str/getwtqty.i
        bf_doc-line.doc-code
        bf_doc-line.artic
        bf_doc-line.prod-type
        bf_doc-line.prod-code
        v-before-qnty
        v-after-qnty
        v-fact-qnty
        v-abs-fact-qnty
        no-error
      }
      assign
        bf_tt-doc-line.Density      = bf_doc-line.fact-density
        bf_tt-doc-line.Temperature  = bf_doc-line.temperature
        bf_tt-doc-line.BeforeKgQnty = v-before-qnty
        bf_tt-doc-line.FactKgQnty   = v-fact-qnty
        bf_tt-doc-line.AfterKgQnty  = v-after-qnty
      .
    end.
    if bf_trn-doc.ext-doc-type = {&TDEDT_Inv}          or
       bf_trn-doc.ext-doc-type = {&TDEDT_Peresort}     or
       bf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}   or
       bf_trn-doc.ext-doc-type = {&TDEDT_Corr_Minus_Parts} or
       bf_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code}   then do:
      assign
        bf_tt-doc-line.BeforeQnty         = (if available bf-bef_doc-line-sum then bf-bef_doc-line-sum.fact-qnty else ?)
        bf_tt-doc-line.BeforeBaseAcc      = (if available bf-bef_doc-line-sum then bf-bef_doc-line-sum.cost-sum-base else ?)
        bf_tt-doc-line.BeforeRublAcc      = (if available bf-bef_doc-line-sum then bf-bef_doc-line-sum.cost-sum-rubl else ?)
        bf_tt-doc-line.BeforeSale         = (if available bf-bef_doc-line-sum then (if varr-b = "base" then bf-bef_doc-line-sum.sale-sum-base else bf-bef_doc-line-sum.sale-sum-rubl) else ?)
        bf_tt-doc-line.AfterQnty          = bf_doc-line.doc-qnty
        bf_tt-doc-line.AfterBaseAcc       = (if available bf-aft_doc-line-sum then bf-aft_doc-line-sum.cost-sum-base else ?)
        bf_tt-doc-line.AfterRublAcc       = (if available bf-aft_doc-line-sum then bf-aft_doc-line-sum.cost-sum-rubl else ?)
        bf_tt-doc-line.AfterSale          = (if available bf-aft_doc-line-sum then (if varr-b = "base" then bf-aft_doc-line-sum.sale-sum-base else bf-aft_doc-line-sum.sale-sum-rubl) else ?)
        bf_tt-doc-line.ExtraQnty          = (if available bf-ext_doc-line-sum     then bf-ext_doc-line-sum.fact-qnty         else ?)
        bf_tt-doc-line.ExtraCliQnty       = (if available bf-ext-cli_doc-line-sum then bf-ext-cli_doc-line-sum.fact-qnty     else ?)
        bf_tt-doc-line.ExtraBaseAcc       = (if available bf-ext_doc-line-sum     then bf-ext_doc-line-sum.cost-sum-base     else ?)
        bf_tt-doc-line.ExtraRublAcc       = (if available bf-ext_doc-line-sum     then bf-ext_doc-line-sum.cost-sum-rubl     else ?)
        bf_tt-doc-line.ExtraSale          = (if available bf-ext_doc-line-sum     then (if varr-b = "base" then bf-ext_doc-line-sum.sale-sum-base else bf-ext_doc-line-sum.sale-sum-rubl) else ?)
        bf_tt-doc-line.MissQnty           = (if available bf-mis_doc-line-sum     then bf-mis_doc-line-sum.fact-qnty         else ?)
        bf_tt-doc-line.MissCliQnty        = (if available bf-mis-cli_doc-line-sum then bf-mis-cli_doc-line-sum.fact-qnty     else ?)
        bf_tt-doc-line.MissBaseAcc        = (if available bf-mis_doc-line-sum     then bf-mis_doc-line-sum.cost-sum-base     else ?)
        bf_tt-doc-line.MissRublAcc        = (if available bf-mis_doc-line-sum     then bf-mis_doc-line-sum.cost-sum-rubl     else ?)
        bf_tt-doc-line.MissSale           = (if available bf-mis_doc-line-sum     then (if varr-b = "base" then bf-mis_doc-line-sum.sale-sum-base else bf-mis_doc-line-sum.sale-sum-rubl) else ?)
        bf_tt-doc-line.WastageSale        = (if available bf-wst_doc-line-sum     then (if varr-b = "base" then bf-wst_doc-line-sum.sale-sum-base else bf-wst_doc-line-sum.sale-sum-rubl) else ?)
        bf_tt-doc-line.BeforeCliQnty      = (if available bf-bef-cli_doc-line-sum then bf-bef-cli_doc-line-sum.fact-qnty     else ?)
        bf_tt-doc-line.AfterCliQnty       = (if available bf-aft-cli_doc-line-sum then bf-aft-cli_doc-line-sum.fact-qnty     else ?)
        .
    end.
    if varis-petrol     and
       not varis-pieces and
       bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}  then do:
      &scop find-attr find first bf_doc-line-attr where bf_doc-line-attr.doc-code  = bf_doc-line.doc-code and ~
                                                        bf_doc-line-attr.gds-code  = bf_goods.gds-code    and ~
                                                        bf_doc-line-attr.attr-code = "~{&attr-code~}"     no-lock no-error. ~
                      if available bf_doc-line-attr then do: ~
                        assign                                                      ~
                          bf_tt-doc-line.~{&attr-field~} = bf_doc-line-attr.attr-value. ~
                      end.
      &scop attr-code  car-num
      &scop attr-field CarNum
      {&find-attr}
      &scop attr-code  car-vol
      &scop attr-field CarVol
      {&find-attr}
      &scop attr-code  tests
      &scop attr-field Tests
      {&find-attr}
      &scop attr-code  autoentobj-type
      &scop attr-field AutoentObjType
      {&find-attr}
      &scop attr-code  autoentobj-code
      &scop attr-field AutoentObjCode
      {&find-attr}
      &scop attr-code  item-pour
      &scop attr-field ItemPour
      {&find-attr}
      &scop attr-code  time-pour
      &scop attr-field TimePour
      {&find-attr}
      &scop attr-code  tank-vol
      &scop attr-field TankVol
      {&find-attr}
      &scop attr-code  tank-temp
      &scop attr-field TankTemp
      {&find-attr}
      &scop attr-code  tank-water
      &scop attr-field TankWater
      {&find-attr}
      &scop attr-code  tank-density
      &scop attr-field TankDensity
      {&find-attr}
      &scop attr-code  tank-weight
      &scop attr-field TankWeight
      {&find-attr}
      &scop attr-code  time-income
      &scop attr-field TimeIncome
      {&find-attr}
    end.
end.
end.
end procedure. /*xml-doc_create-line*/


procedure xml-doc_create-barcode :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_tt-barcode for tt-barcode.
define buffer bf_doc-line   for ub.doc-line.
define buffer bf_goods      for ub.goods.
define buffer bf_trn-doc    for ub.trn-doc.
define buffer buf_bar-code  for ub.bar-code  .
define buffer buf_prod-bc   for ub.prod-bc  .

do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
if error-status:error then do:
  return error substitute ("Не найден документ с номером &1.", pardoc-code).
end.

for each bf_doc-line where bf_doc-line.doc-code = pardoc-code no-lock on error undo, return error return-value :
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock no-error.
  if not available bf_goods then do:
    return error substitute ("Не найден товар: &1 &2 &3.", bf_doc-line.artic, bf_doc-line.prod-type, bf_doc-line.prod-code).
  end.
  for each buf_bar-code no-lock where
           buf_bar-code.gds-code = bf_goods.gds-code and
           buf_bar-code.unit-cli = bf_goods.unit-base :
           /* ???
            find first bf_tt-barcode where
                    bf_tt-barcode.doccode = pardoc-code and
                    bf_tt-barcode.barcode = string(buf_bar-code.b-code) and
                    bf_tt-barcode.gdscode = bf_goods.gds-code no-error .
            if not available bf_tt-barcode then do:
                create bf_tt-barcode.
                assign
                  bf_tt-barcode.doccode = pardoc-code
                  bf_tt-barcode.barcode  = string(buf_bar-code.b-code)
                  bf_tt-barcode.gdscode = bf_goods.gds-code
                .
            end.
            */
            for each buf_prod-bc no-lock where
                     buf_prod-bc.b-code = buf_bar-code.b-code :
                      find first bf_tt-barcode where
                              bf_tt-barcode.doccode = pardoc-code and
                              bf_tt-barcode.barcode = buf_prod-bc.b-str and
                              bf_tt-barcode.gdscode = bf_goods.gds-code no-error .
                      if not available bf_tt-barcode then do:
                          create bf_tt-barcode.
                          assign
                            bf_tt-barcode.doccode = pardoc-code
                            bf_tt-barcode.barcode  = buf_prod-bc.b-str
                            bf_tt-barcode.gdscode = bf_goods.gds-code
                          .
                      end.
            end.
  end.
end.

end.
end procedure.

procedure xml-doc_create-dtl :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_tt-gds-dtl    for tt-gds-dtl.
define buffer bf_gds-dtl       for ub.gds-dtl.
define buffer bf_goods         for ub.goods.
define buffer bf-obj_clients   for ub.clients.
define buffer bf-prod_clients  for ub.clients.
define buffer bf_gds-prt       for ub.gds-prt.
define buffer bf_trn-doc       for ub.trn-doc.
define variable varb-code like ub.bar-code.b-code no-undo.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
if error-status:error then do:
  return error substitute ("Не найден документ с номером &1.", pardoc-code).
end.

for each bf_gds-dtl where bf_gds-dtl.doc-code = pardoc-code no-lock
                          on error undo, return error return-value :
  find first bf_goods where bf_goods.artic     = bf_gds-dtl.artic     and
                            bf_goods.prod-type = bf_gds-dtl.prod-type and
                            bf_goods.prod-code = bf_gds-dtl.prod-code no-lock no-error.
  if error-status:error then do:
    return error substitute ("Не найдент товар: &1 &2 &3.", bf_gds-dtl.artic, bf_gds-dtl.prod-type, bf_gds-dtl.prod-code).
  end.
  find first bf-prod_clients where bf-prod_clients.obj-type = bf_gds-dtl.prod-type and
                                   bf-prod_clients.obj-code = bf_gds-dtl.prod-code no-lock.
  find first bf-obj_clients  where bf-obj_clients.obj-type = bf_gds-dtl.obj-type and
                                   bf-obj_clients.obj-code = bf_gds-dtl.obj-code no-lock.
  find first bf_gds-prt where bf_gds-prt.node-code = bf_gds-dtl.prt-code no-lock.
  { gbl/gdsbcode.i bf_goods.gds-code bf_gds-prt.node-code varb-code no-error }
  create bf_tt-gds-dtl.
  assign
    bf_tt-gds-dtl.DocCode            = bf_gds-dtl.doc-code
    bf_tt-gds-dtl.ExtDocType         = bf_trn-doc.ext-doc-type
    bf_tt-gds-dtl.Artic              = bf_gds-dtl.artic
    bf_tt-gds-dtl.ProdType           = bf_gds-dtl.prod-type
    bf_tt-gds-dtl.ProdCode           = bf_gds-dtl.prod-code
    bf_tt-gds-dtl.GdsCode            = bf_goods.gds-code
    bf_tt-gds-dtl.ProdName           = bf-prod_clients.obj-name
    bf_tt-gds-dtl.GdsName            = bf_goods.gds-name
    bf_tt-gds-dtl.PrtCode            = bf_gds-dtl.prt-code
    bf_tt-gds-dtl.BarCodeUnitBase    = varb-code
    bf_tt-gds-dtl.FullPrtName        = bf_gds-prt.f-name
    bf_tt-gds-dtl.ObjType            = bf_gds-dtl.obj-type
    bf_tt-gds-dtl.ObjCode            = bf_gds-dtl.obj-code
    bf_tt-gds-dtl.ObjName            = bf-obj_clients.obj-name
    bf_tt-gds-dtl.FactQnty           = bf_gds-dtl.fact-qnty
    bf_tt-gds-dtl.DocQnty            = bf_gds-dtl.doc-qnty
    bf_tt-gds-dtl.PriceRublDoc       = bf_gds-dtl.price-rubl
    bf_tt-gds-dtl.PriceBaseDoc       = bf_gds-dtl.price-base
    bf_tt-gds-dtl.DiscntRublDoc      = bf_gds-dtl.discnt-rubl
    bf_tt-gds-dtl.DiscntBaseDoc      = bf_gds-dtl.discnt-base
    bf_tt-gds-dtl.DiscntType         = bf_gds-dtl.discnt-type
    bf_tt-gds-dtl.DiscntPc           = bf_gds-dtl.discnt-pc
    bf_tt-gds-dtl.PriceBaseSale      = bf_gds-dtl.cur-base
    bf_tt-gds-dtl.Ov                 = bf_gds-dtl.ov                .
  if bf_trn-doc.ext-doc-type = {&TDEDT_Inv} or
     bf_trn-doc.ext-doc-type = {&TDEDT_Peresort}         or
     bf_trn-doc.ext-doc-type = {&TDEDT_Corr_Acc_Price}   or
     bf_trn-doc.ext-doc-type = {&TDEDT_Corr_Minus_Parts} or
     bf_trn-doc.ext-doc-type = {&TDEDT_Chg_Purch_Code}   then do:
    assign
      bf_tt-gds-dtl.AfterQnty = bf_gds-dtl.fact-qnty.
  end.
end.
end.
end procedure. /*xml-doc_create-dtl*/

procedure xml-doc_create-parts :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_tt-parts      for tt-parts.
define buffer bf_parts         for ub.parts.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf-obj_clients   for ub.clients.
define buffer bf-prod_clients  for ub.clients.
define buffer bf-suppl_clients for ub.clients.
define buffer bf_goods         for ub.goods.
define buffer bf_country       for ub.country.
define buffer bf_currency      for ub.currency.
define buffer bf-contract       for ub.contract.
{ str/in-vatp.i def }
do on error undo, return error return-value :
  find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
  if error-status:error then do:
    return error substitute ("Не найден документ с номером &1.", pardoc-code).
  end.
  find first bf-obj_clients where bf-obj_clients.obj-type = bf_trn-doc.obj-type and
                                  bf-obj_clients.obj-code = bf_trn-doc.obj-code no-lock.
  for each bf_parts where bf_parts.out-code = pardoc-code no-lock on error undo, return error return-value :
    find first bf_goods where bf_goods.artic     = bf_parts.artic     and
                              bf_goods.prod-type = bf_parts.prod-type and
                              bf_goods.prod-code = bf_parts.prod-code no-lock no-error.
    if not available bf_goods then do:
      return error substitute ("Не найден товар &1 &2 &3.", bf_parts.artic, bf_parts.prod-type, bf_parts.prod-code).
    end.
    find first bf_country where bf_country.alpha1 = bf_goods.alpha1 no-lock no-error.
    find first bf-suppl_clients where bf-suppl_clients.obj-type = bf_parts.supp-type and
                                      bf-suppl_clients.obj-code = bf_parts.supp-code no-lock.
    find first bf-prod_clients where bf-prod_clients.obj-type = bf_parts.prod-type and
                                     bf-prod_clients.obj-code = bf_parts.prod-code no-lock.
    find first bf-contract no-lock where bf-contract.contract-code = bf_parts.contract-code and
                                         bf-contract.host-code     = bf_parts.host-code no-error .

    create bf_tt-parts.
    assign
      bf_tt-parts.ObjType            = bf_parts.obj-type
      bf_tt-parts.ObjCode            = bf_parts.obj-code
      bf_tt-parts.ObjName            = bf-obj_clients.obj-name
      bf_tt-parts.Artic              = bf_parts.artic
      bf_tt-parts.ProdType           = bf_parts.prod-type
      bf_tt-parts.ProdCode           = bf_parts.prod-code
      bf_tt-parts.GdsCode            = bf_goods.gds-code
      bf_tt-parts.ProdName           = bf-prod_clients.obj-name
      bf_tt-parts.GdsName            = bf_goods.gds-name
      bf_tt-parts.InCode             = bf_parts.in-code
      bf_tt-parts.OutCode            = bf_parts.out-code
      bf_tt-parts.ExtDocType         = bf_trn-doc.ext-doc-type
      bf_tt-parts.CountryAlphaOne    = (if available bf_country then bf_country.alpha1     else "":U)
      bf_tt-parts.CountryAlphaTwo    = (if available bf_country then bf_country.alpha2     else "":U)
      bf_tt-parts.CountryNumCode     = (if available bf_country then bf_country.num-code   else ?)
      bf_tt-parts.CountryLongName    = (if available bf_country then bf_country.long-name  else "XX неизвестна")
      bf_tt-parts.CountryShortName   = (if available bf_country then bf_country.short-name else "XX неизвестна")
      bf_tt-parts.PartCode           = bf_parts.part-code
      bf_tt-parts.Sign               = (if bf_parts.doc-type = {&income} or bf_parts.doc-type = {&return} or bf_parts.doc-type = {&inventory} then 1 else -1)
      bf_tt-parts.DocQnty            = bf_parts.qnty
      bf_tt-parts.PriceBaseAcc       = bf_parts.price-base
      bf_tt-parts.PriceRublAcc       = bf_parts.price-rubl
      bf_tt-parts.FactDate           = bf_parts.fact-date
      bf_tt-parts.FactNum            = bf_parts.fact-num
      bf_tt-parts.Sts                = bf_parts.status_
      bf_tt-parts.VatPcAcc           = bf_parts.VAT-pc
      bf_tt-parts.Ps                 = bf_parts.PS
      bf_tt-parts.PayCode            = bf_parts.pay-code
      bf_tt-parts.FactQnty           = bf_parts.fact-qnty
      bf_tt-parts.SupplType          = bf_parts.supp-type
      bf_tt-parts.SupplCode          = bf_parts.supp-code
      bf_tt-parts.SupplName          = bf-suppl_clients.obj-name
      bf_tt-parts.RsrvFree           = bf_parts.rsrv-free
      bf_tt-parts.DocType            = bf_parts.doc-type
      bf_tt-parts.PlCode             = bf_parts.pl-code
      bf_tt-parts.VatType            = bf_parts.VAT-type
      bf_tt-parts.SupplCrcCode       = bf_parts.exch-code
      bf_tt-parts.PriceSuppl         = bf_parts.price-cli
      bf_tt-parts.SupplRate          = bf_parts.cli-base-rate
      bf_tt-parts.SltPcAcc           = bf_parts.SLT-pc
      bf_tt-parts.HostCode           = bf_parts.host-code
      bf_tt-parts.IsSupp             = bf_parts.is-supp
      bf_tt-parts.RealQnty           = bf_parts.real-qnty
      bf_tt-parts.SltType            = bf_parts.SLT-type
      bf_tt-parts.CstCode            = bf_parts.cst-code
      bf_tt-parts.LastDate           = bf_parts.last-date
      bf_tt-parts.TaxThreeBaseAcc        = bf_parts.road-tax-base
      bf_tt-parts.TaxThreeRublAcc        = bf_parts.road-tax-rubl
      bf_tt-parts.TransportBaseAcc   = bf_parts.transport-base
      bf_tt-parts.TransportRublAcc   = bf_parts.transport-rubl
      bf_tt-parts.OtherBaseAcc       = bf_parts.other-base
      bf_tt-parts.OtherRublAcc       = bf_parts.other-rubl
      bf_tt-parts.ContractId         = bf_parts.contract-code
    .
if available bf-contract then do:
   assign
     bf_tt-parts.ContractNum            = bf-contract.contract-prn-code
     bf_tt-parts.ContractDate           = bf-contract.contract-date
   .
end.
else do:
   assign
     bf_tt-parts.ContractNum            = ""
     bf_tt-parts.ContractDate           = ?
   .
end.

    { str/in-vatp.i calc-parts bf_parts. bf_trn-doc. }
    assign
      bf_tt-parts.VatBaseAcc = vat-base-loc
      bf_tt-parts.VatRublAcc = vat-rubl-loc
      bf_tt-parts.SltBaseAcc = slt-base-loc
      bf_tt-parts.SltRublAcc = slt-rubl-loc .
    if bf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then do:
      find first bf_currency where bf_currency.curr-code = bf_parts.exch-code no-lock.
      assign
        bf_tt-parts.SupplQnty    = bf_parts.cli-qnty
        bf_tt-parts.SupplCrcAbbr = bf_currency.curr-abbr
        bf_tt-parts.SupplCrcName = bf_currency.curr-name .
    end.
  end.
end.
end procedure. /*xml-doc_create-parts*/

procedure xml-doc_create-attr :
define input parameter pardoc-code like ub.doc-attr.doc-code no-undo.
define buffer bf_tt-attr       for tt-attr.
define buffer bf_attr          for ub.doc-attr.
define buffer bf_trn-doc       for ub.trn-doc.

define variable v-type           as character no-undo . /* тип атрибута    */
define variable v-format         as character no-undo . /* формат атрибута */
define variable v-fillin_width   as integer   no-undo . /* ширина          */
define variable v-fillin_height  as integer   no-undo . /* высота          */
define variable v-label          as character no-undo . /* лабел атрибута */
define variable v-user-can-edit  as logical   no-undo . /* пользователь может изменять в броусе */
define variable v-output-display as logical   no-undo . /* виден в броусе */
define variable v-other          as character no-undo . /* еще чего - нибудь */
define variable v-proc-attr       as character no-undo .
define variable v-full-screen-val as character no-undo .

do on error undo, return error return-value :
  find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
  if error-status:error then do:
    return error substitute ("Не найден документ с номером &1.", pardoc-code).
  end.
  for each bf_attr where bf_attr.doc-code = pardoc-code no-lock on error undo, return error return-value :
    { str/tdat-cod.i
        bf_attr.attr-code
        v-type
        v-format
        v-fillin_width
        v-fillin_height
        v-label
        v-user-can-edit
        v-output-display
        v-other
        v-proc-attr
        v-full-screen-val
        v-sort
    }
    if v-output-display = false then next . /* Выгрузим только видимые в браусе документа */

    create bf_tt-attr.
    assign
      bf_tt-attr.DocCode             = bf_attr.doc-code
      bf_tt-attr.attr-code           = bf_attr.attr-code
      bf_tt-attr.attr-value          = bf_attr.attr-value
      bf_tt-attr.attr-type           = v-type
     .

  end.
end.
end procedure. /*xml-doc_create-parts*/

procedure xml-doc_export-doc :
  define input  parameter p-handle-callback as handle    no-undo .
  define input  parameter p-proc-name       as character no-undo .
  define buffer bf_tt-trn-doc     for tt-trn-doc .
  define buffer bf_tt-trn-doc-add for tt-trn-doc-add.
  define variable par-type as character no-undo.
  &scop write-xml      run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', '~{&field-name~}', xml-doc_ReplaceSpecSymbols(string(~{&table-name~}~{&field-name~}))) + v-suffix ) .
  &scop write-xml-date run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', '~{&field-name~}', xml-doc_ReplaceSpecSymbols(string(~{&table-name~}~{&field-name~}, '99.99.9999':U))) + v-suffix ) .

  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .

  do
  on error undo, return error return-value
  :

    assign
      v-prefix = "    "
      v-suffix = {&new-line}
    .

    for each bf_tt-trn-doc
    on error undo, return error return-value
    :
      find first bf_tt-trn-doc-add where bf_tt-trn-doc-add.DocCode = bf_tt-trn-doc.DocCode.
      run value(p-proc-name) in p-handle-callback
        (input '  <trn-doc>' + {&new-line}
        ) .

      &scop table-name bf_tt-trn-doc.
      &scop field-name DocCode
      {&write-xml}
      &scop field-name ExtDocType
      {&write-xml}
      &scop field-name ExtDocTypeName
      {&write-xml}
      &scop field-name DocType
      {&write-xml}
      &scop field-name Internal
      {&write-xml}
      &scop field-name Sts
      {&write-xml}
      &scop field-name Flag
      {&write-xml}
      &scop field-name DocDate
      {&write-xml-date}
      &scop field-name ContractId
      {&write-xml}
      &scop field-name ContractNum
      {&write-xml}
      &scop field-name ContractDate
      {&write-xml-date}
      &scop field-name BaseCrcRate
      {&write-xml}
      &scop field-name BaseCrcScale
      {&write-xml}
      &scop field-name CliType
      {&write-xml}
      &scop field-name CliCode
      {&write-xml}
      &scop field-name CliName
      {&write-xml}
      &scop field-name PostIndex
      {&write-xml}
      &scop field-name City
      {&write-xml}
      &scop field-name Address
      {&write-xml}
      if bf_tt-trn-doc.CliType = {&cmp} then do:
        &scop field-name AddressAdd
        {&write-xml}
        &scop field-name PostAddress
        {&write-xml}
        &scop field-name PostAddressAdd
        {&write-xml}
      end.
      &scop field-name EMail
      {&write-xml}
      &scop field-name Fax
      {&write-xml}
      &scop field-name Phone
      {&write-xml}
      &scop field-name PhoneNote
      {&write-xml}
      &scop field-name Inn
      {&write-xml}
      &scop field-name KPP
      {&write-xml}
      &scop field-name OKPO
      {&write-xml}
      &scop field-name OKONH
      {&write-xml}
      if bf_tt-trn-doc.CliType = {&cmp} then do:
        &scop field-name ContactPerson
        {&write-xml}
        &scop field-name Director
        {&write-xml}
        &scop field-name EnglName
        {&write-xml}
        &scop field-name GenAccnt
        {&write-xml}
        &scop field-name Telex
        {&write-xml}
      end.
      else do:
        &scop field-name Name
        {&write-xml}
        &scop field-name Patronymic
        {&write-xml}
        &scop field-name PassNum
        {&write-xml}
        &scop field-name PassSer
        {&write-xml}
        &scop field-name GivenBy
        {&write-xml}
        &scop field-name Position
        {&write-xml}
        &scop field-name PostBox
        {&write-xml}
      end.
      if bf_tt-trn-doc.BankRublIsHave = yes then do:
        &scop field-name BankNameRubl
        {&write-xml}
        &scop field-name BankCodeRubl
        {&write-xml}
        &scop field-name BankAccRubl
        {&write-xml}
        &scop field-name AddressBankRubl
        {&write-xml}
        &scop field-name AddressAddBankRubl
        {&write-xml}
        &scop field-name PBankAccRubl
        {&write-xml}
      end.
      if bf_tt-trn-doc.BankBaseIsHave = yes then do:
        &scop field-name BankNameBase
        {&write-xml}
        &scop field-name BankCodeBase
        {&write-xml}
        &scop field-name BankAccBase
        {&write-xml}
        &scop field-name AddressBankBase
        {&write-xml}
        &scop field-name AddressAddBankBase
        {&write-xml}
        &scop field-name PBankAccBase
        {&write-xml}
      end.
      &scop field-name ObjType
      {&write-xml}
      &scop field-name ObjCode
      {&write-xml}
      &scop field-name ObjName
      {&write-xml}
      &scop table-name bf_tt-trn-doc-add.
      &scop field-name AddressObj
      {&write-xml}
      &scop field-name AddressAddObj
      {&write-xml}
      if bf_tt-trn-doc.ObjType = {&shop} then do:
        &scop field-name AcctObj
        {&write-xml}
        &scop field-name DirectorObj
        {&write-xml}
        &scop field-name GoodsManObj
        {&write-xml}
      end.
      &scop field-name PhoneObj
      {&write-xml}
      &scop field-name StoreBossObj
      {&write-xml}
      &scop field-name StoreManObj
      {&write-xml}
      &scop table-name bf_tt-trn-doc.
      &scop field-name ShipNum
      {&write-xml}
      &scop field-name ShipDate
      {&write-xml-date}
      &scop field-name OrdNum
      {&write-xml}
      &scop field-name Office
      {&write-xml}
      &scop field-name FactDate
      {&write-xml-date}
      &scop field-name FactNum
      {&write-xml}
      &scop field-name FactOrder
      {&write-xml}
      &scop field-name FactQnty
      {&write-xml}
      &scop field-name SumFactBaseAcc
      {&write-xml}
      &scop field-name SumFactRublAcc
      {&write-xml}
      &scop field-name VatType
      {&write-xml}
      &scop field-name SltType
      {&write-xml}
      &scop field-name Wrkr
      {&write-xml}
      &scop field-name Agnt
      {&write-xml}
      &scop field-name Boss
      {&write-xml}
      &scop field-name PayCode
      {&write-xml}
      &scop field-name Creid
      {&write-xml}
      &scop field-name PrintRubl
      {&write-xml}
      &scop field-name PS
      {&write-xml}
      &scop field-name Ov
      {&write-xml}
      &scop field-name HostCode
      {&write-xml}
      &scop field-name HostName
      {&write-xml}
      &scop field-name RsrvDate
      {&write-xml-date}
      &scop field-name RsrvTerm
      {&write-xml}
      &scop table-name bf_tt-trn-doc-add.
      &scop field-name PostIndexOwn
      {&write-xml}
      &scop field-name CityOwn
      {&write-xml}
      &scop field-name AddressOwn
      {&write-xml}
      &scop field-name AddressAddOwn
      {&write-xml}
      &scop field-name PostAddressOwn
      {&write-xml}
      &scop field-name PostAddressAddOwn
      {&write-xml}
      &scop field-name EMailOwn
      {&write-xml}
      &scop field-name FaxOwn
      {&write-xml}
      &scop field-name PhoneOwn
      {&write-xml}
      &scop field-name PhoneNoteOwn
      {&write-xml}
      &scop field-name InnOwn
      {&write-xml}
      &scop field-name KPPOwn
      {&write-xml}
      &scop field-name OKPOOwn
      {&write-xml}
      &scop field-name OKONHOwn
      {&write-xml}
      &scop field-name ContactPersonOwn
      {&write-xml}
      &scop field-name DirectorOwn
      {&write-xml}
      &scop field-name EnglNameOwn
      {&write-xml}
      &scop field-name GenAccntOwn
      {&write-xml}
      &scop field-name TelexOwn
      {&write-xml}
      if bf_tt-trn-doc-add.OwnBankRublIsHave = yes then do:
        &scop field-name BankNameRublOwn
        {&write-xml}
        &scop field-name BankCodeRublOwn
        {&write-xml}
        &scop field-name BankAccRublOwn
        {&write-xml}
        &scop field-name AddressBankRublOwn
        {&write-xml}
        &scop field-name AddressAddBankRublOwn
        {&write-xml}
        &scop field-name PBankAccRublOwn
        {&write-xml}
      end.
      if bf_tt-trn-doc-add.OwnBankBaseIsHave = yes then do:
        &scop field-name BankNameBaseOwn
        {&write-xml}
        &scop field-name BankCodeBaseOwn
        {&write-xml}
        &scop field-name BankAccBaseOwn
        {&write-xml}
        &scop field-name AddressBankBaseOwn
        {&write-xml}
        &scop field-name AddressAddBankBaseOwn
        {&write-xml}
        &scop field-name PBankAccBaseOwn
        {&write-xml}
      end.
      &scop field-name KOPFOwn
      {&write-xml}
      &scop field-name SOEIOwn
      {&write-xml}
      &scop field-name BranchOwn
      {&write-xml}
      &scop field-name PropertyOwn
      {&write-xml}
      &scop table-name bf_tt-trn-doc.
      &scop field-name TotLines
      {&write-xml}
      &scop field-name FactTime
      {&write-xml}
      &scop field-name RetSupp
      {&write-xml}
      &scop field-name BgeDate
      {&write-xml-date}
      &scop field-name SctDate
      {&write-xml-date}
      &scop field-name AccDate
      {&write-xml-date}
      &scop field-name InvNum
      {&write-xml}

      if varshift = "yes" then do:
        &scop field-name ShiftNum
        {&write-xml}
        &scop field-name ShiftDate
        {&write-xml-date}
      end.
      if bf_tt-trn-doc.ExtDocType = {&TDEDT_Pri_Vnesh} then do:
        &scop field-name SupplCrcCode
        {&write-xml}
        &scop field-name SupplCrcAbbr
        {&write-xml}
        &scop field-name SupplCrcName
        {&write-xml}
        &scop field-name SupplCrcDate
        {&write-xml-date}
        &scop field-name SupplCrcRate
        {&write-xml}
        &scop field-name SupplCrcScale
        {&write-xml}
        &scop field-name SumCheckFactSuppl
        {&write-xml}
        &scop field-name SumFactSuppl
        {&write-xml}
        &scop field-name VatFactBaseAcc
        {&write-xml}
        &scop field-name VatFactRublAcc
        {&write-xml}
        &scop field-name SltFactBaseAcc
        {&write-xml}
        &scop field-name SltFactRublAcc
        {&write-xml}
        &scop field-name SumDocBaseAcc
        {&write-xml}
        &scop field-name SumDocRublAcc
        {&write-xml}
        &scop field-name OvervalueFactSaleacc
        {&write-xml}
        &scop field-name TaxThreeFactSaleAcc
        {&write-xml}
        &scop field-name ExciseFactSaleAcc
        {&write-xml}
        &scop field-name TransportExpSuppl
        {&write-xml}
        &scop field-name OtherExpSuppl
        {&write-xml}
        &scop field-name SupplQnty
        {&write-xml}
        &scop field-name CstCode
        {&write-xml}
        &scop field-name ExpenseOwn
        {&write-xml}
      end.
      else do:
        &scop field-name VatFactBaseDoc
        {&write-xml}
        &scop field-name VatFactRublDoc
        {&write-xml}
        &scop field-name SltFactBaseDoc
        {&write-xml}
        &scop field-name SltFactRublDoc
        {&write-xml}
        &scop field-name SumDocBaseDoc
        {&write-xml}
        &scop field-name SumDocRublDoc
        {&write-xml}
        &scop field-name OvervalueFactSaledoc
        {&write-xml}
      end.
      if bf_tt-trn-doc.OutCode <> ? and
         bf_tt-trn-doc.OutCode <> "" then do:
        &scop field-name OutCode
        {&write-xml}
      end.
      if bf_tt-trn-doc.ExtDocType = {&TDEDT_Inv}              OR
         bf_tt-trn-doc.extdoctype = {&TDEDT_Peresort}         or
         bf_tt-trn-doc.extdoctype = {&TDEDT_Corr_Acc_Price}   or
         bf_tt-trn-doc.extdoctype = {&TDEDT_Corr_Minus_Parts} or
         bf_tt-trn-doc.extdoctype = {&TDEDT_Chg_Purch_Code}   then do:
        &scop field-name BefQnty
        {&write-xml}
        &scop field-name SumBefBaseAcc
        {&write-xml}
        &scop field-name SumBefRublAcc
        {&write-xml}
        &scop field-name ExtraQnty
        {&write-xml}
        &scop field-name ExtraSupplQnty
        {&write-xml}
        &scop field-name ExtraFactBaseAcc
        {&write-xml}
        &scop field-name ExtraFactRublAcc
        {&write-xml}
        &scop field-name ExtraFactSale
        {&write-xml}
        &scop field-name MissQnty
        {&write-xml}
        &scop field-name MissCliQnty
        {&write-xml}
        &scop field-name MissFactBaseAcc
        {&write-xml}
        &scop field-name MissFactRublAcc
        {&write-xml}
        &scop field-name MissFactSale
        {&write-xml}
        /*
        &scop field-name WastageQnty
        {&write-xml}
        &scop field-name WastageFactBaseAcc
        {&write-xml}
        &scop field-name WastageFactRublAcc
        {&write-xml}
        */
        &scop field-name WastageFactSale
        {&write-xml}
        &scop field-name BefSupplQnty
        {&write-xml}
        &scop field-name AftSupplQnty
        {&write-xml}
      end.
      else do:
        &scop field-name DocQnty
        {&write-xml}
      end.
      if bf_tt-trn-doc.ExtDocType  <> {&TDEDT_Pri_Vnesh} and
         bf_tt-trn-doc.ExtDocType  <> {&TDEDT_Inv}       and
         bf_tt-trn-doc.extdoctype <> {&TDEDT_Peresort}         and
         bf_tt-trn-doc.extdoctype <> {&TDEDT_Corr_Acc_Price}   and
         bf_tt-trn-doc.extdoctype <> {&TDEDT_Corr_Minus_Parts} and
         bf_tt-trn-doc.extdoctype <> {&TDEDT_Chg_Purch_Code}   then do:
        &scop field-name DscFactBaseDoc
        {&write-xml}
        &scop field-name SumFactBaseDoc
        {&write-xml}
        &scop field-name SumFactRublDoc
        {&write-xml}
        &scop field-name DscFactRublDoc
        {&write-xml}
        &scop field-name DiscntType
        {&write-xml}
        &scop field-name DiscntPc
        {&write-xml}
      end.
      &scop table-name bf_tt-trn-doc.
      &scop field-name ReasonCode
      {&write-xml}
      run value(p-proc-name) in p-handle-callback
        (input '  </trn-doc>' + {&new-line}
        ) .
    end.
  end.
end procedure. /* xml-doc_export-doc */

procedure xml-doc_export-line :
  define input  parameter p-handle-callback as handle    no-undo .
  define input  parameter p-proc-name       as character no-undo .
  define buffer bf_tt-doc-line for tt-doc-line .
  define buffer bf_goods       for ub.goods.
  define variable varis-petrol as logical   no-undo.
  define variable varis-pieces as logical   no-undo.
  define variable custvalue    as character no-undo.
  define variable custtype     as character no-undo.

  &scop write-xml      run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', '~{&field-name~}', xml-doc_ReplaceSpecSymbols(string(~{&table-name~}~{&field-name~}))) + v-suffix ) .
  &scop write-xml-date run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', '~{&field-name~}', xml-doc_ReplaceSpecSymbols(string(~{&table-name~}~{&field-name~}, '99/99/9999':U))) + v-suffix ) .

  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .

  do
  on error undo, return error return-value
  :

    assign
      v-prefix = "    "
      v-suffix = {&new-line}
    .

    run gbl/conf-rd.p ("is-custm" , "", "", 0, "", "", "", no, output custvalue, output custtype) no-error.
    for each bf_tt-doc-line on error undo, return error return-value :
      find first bf_goods where bf_goods.artic     = bf_tt-doc-line.artic    and
                                bf_goods.prod-type = bf_tt-doc-line.ProdType and
                                bf_goods.prod-code = bf_tt-doc-line.ProdCode no-lock.
      { str/is-petrl.i
       bf_goods.artic
       bf_goods.prod-type
       bf_goods.prod-code
       varis-petrol
       varis-pieces
       no-error
      }
      if error-status:error then do:
        return error return-value.
      end.

      run value(p-proc-name) in p-handle-callback
        (input '  <doc-line>' + {&new-line}
        ) .
      &scop table-name bf_tt-doc-line.
      &scop field-name DocCode
      {&write-xml}
      &scop field-name Artic
      {&write-xml}
      &scop field-name ProdType
      {&write-xml}
      &scop field-name ProdCode
      {&write-xml}
      &scop field-name GdsCode
      {&write-xml}
      &scop field-name ProdName
      {&write-xml}
      &scop field-name GdsName
      {&write-xml}
      &scop field-name EnglName
      {&write-xml}
      &scop field-name LabelName
      {&write-xml}
      &scop field-name GrpCode
      {&write-xml}
      &scop field-name GrpFullName
      {&write-xml}
      &scop field-name GrpName
      {&write-xml}
      &scop field-name UnitBase
      {&write-xml}
      &scop field-name ObjType
      {&write-xml}
      &scop field-name ObjCode
      {&write-xml}
      &scop field-name ObjName
      {&write-xml}
      &scop field-name ExtDocType
      {&write-xml}
      &scop field-name FactOrder
      {&write-xml}
      &scop field-name Sts
      {&write-xml}
      &scop field-name FactQnty
      {&write-xml}
      &scop field-name PriceAvrgRubl
      {&write-xml}
      &scop field-name PriceAvrgBase
      {&write-xml}
      &scop field-name PrtOk
      {&write-xml}
      &scop field-name PrtRoot
      {&write-xml}
      &scop field-name SumSignBaseAcc
      {&write-xml}
      &scop field-name SumSignRublAcc
      {&write-xml}
      &scop field-name SumSignVatBaseAcc
      {&write-xml}
      &scop field-name SumSignVatRublAcc
      {&write-xml}
      &scop field-name SumSignSltBaseAcc
      {&write-xml}
      &scop field-name SumSignSltRublAcc
      {&write-xml}
      &scop field-name SumSignTaxThreeBaseAcc
      {&write-xml}
      &scop field-name SumSignTaxThreeRublAcc
      {&write-xml}
      &scop field-name SumSignTransportBaseAcc
      {&write-xml}
      &scop field-name SumSignTransportRublAcc
      {&write-xml}
      &scop field-name SumSignOtherBaseAcc
      {&write-xml}
      &scop field-name SumSignOtherRublAcc
      {&write-xml}
      &scop field-name SumSignExciseBaseAcc
      {&write-xml}
      &scop field-name SumSignExciseRublAcc
      {&write-xml}
      &scop field-name SumSignBaseDoc
      {&write-xml}
      &scop field-name SumSignRublDoc
      {&write-xml}
      &scop field-name SumSignVatBaseDoc
      {&write-xml}
      &scop field-name SumSignVatRublDoc
      {&write-xml}
      &scop field-name SumSignSltBaseDoc
      {&write-xml}
      &scop field-name SumSignSltRublDoc
      {&write-xml}
      &scop field-name SumSignTaxThreeBaseDoc
      {&write-xml}
      &scop field-name SumSignTaxThreeRublDoc
      {&write-xml}
      &scop field-name SumSignTransportBaseDoc
      {&write-xml}
      &scop field-name SumSignTransportRublDoc
      {&write-xml}
      &scop field-name SumSignOtherBaseDoc
      {&write-xml}
      &scop field-name SumSignOtherRublDoc
      {&write-xml}
      &scop field-name SumSignExciseBaseDoc
      {&write-xml}
      &scop field-name SumSignExciseRublDoc
      {&write-xml}
      if bf_tt-doc-line.ExtDocType = {&TDEDT_Pri_Vnesh} then do:
        &scop field-name SupplQnty
        {&write-xml}
        &scop field-name SupplRate
        {&write-xml}
        &scop field-name PriceAvrgSuppl
        {&write-xml}
        &scop field-name UnitSuppl
        {&write-xml}
        &scop field-name VatPcAcc
        {&write-xml}
        &scop field-name SltPcAcc
        {&write-xml}
        &scop field-name LineNum
        {&write-xml}
        &scop field-name TaxThreeSupplSale
        {&write-xml}
        &scop field-name TransportBase
        {&write-xml}
        &scop field-name TransportRubl
        {&write-xml}
        &scop field-name OtherBase
        {&write-xml}
        &scop field-name OtherRubl
        {&write-xml}
      end.
      else do:
        &scop field-name SltPcDoc
        {&write-xml}
        &scop field-name VatPcDoc
        {&write-xml}
        &scop field-name TaxThreeDocSale
        {&write-xml}
        &scop field-name ExciseDocSale
        {&write-xml}
      end.
      if bf_tt-doc-line.ExtDocType   <> {&TDEDT_Inv} and
         bf_tt-doc-line.extdoctype <> {&TDEDT_Peresort}         and
         bf_tt-doc-line.extdoctype <> {&TDEDT_Corr_Acc_Price}   and
         bf_tt-doc-line.extdoctype <> {&TDEDT_Corr_Minus_Parts} and
         bf_tt-doc-line.extdoctype <> {&TDEDT_Chg_Purch_Code}
      then do:
        &scop field-name DocQnty
        {&write-xml}
      end.
      if custvalue = "yes" then do:
        &scop field-name WtBrutto
        {&write-xml}
        &scop field-name NumPlace
        {&write-xml}
      end.
      if varis-petrol and
         not varis-pieces then do:
        &scop field-name Density
        {&write-xml}
        &scop field-name Temperature
        {&write-xml}
        &scop field-name BeforeKgQnty
        {&write-xml}
        &scop field-name FactKgQnty
        {&write-xml}
        &scop field-name AfterKgQnty
        {&write-xml}
      end.
      if bf_tt-doc-line.ExtDocType = {&TDEDT_Inv} or
         bf_tt-doc-line.extdoctype = {&TDEDT_Peresort}         or
         bf_tt-doc-line.extdoctype = {&TDEDT_Corr_Acc_Price}   or
         bf_tt-doc-line.extdoctype = {&TDEDT_Corr_Minus_Parts} or
         bf_tt-doc-line.extdoctype = {&TDEDT_Chg_Purch_Code}
      then do:
        &scop field-name BeforeQnty
        {&write-xml}
        &scop field-name BeforeBaseAcc
        {&write-xml}
        &scop field-name BeforeRublAcc
        {&write-xml}
        &scop field-name BeforeSale
        {&write-xml}
        &scop field-name AfterQnty
        {&write-xml}
        &scop field-name AfterBaseAcc
        {&write-xml}
        &scop field-name AfterRublAcc
        {&write-xml}
        &scop field-name AfterSale
        {&write-xml}
        &scop field-name ExtraQnty
        {&write-xml}
        &scop field-name ExtraBaseAcc
        {&write-xml}
        &scop field-name ExtraRublAcc
        {&write-xml}
        &scop field-name ExtraSale
        {&write-xml}
        &scop field-name MissQnty
        {&write-xml}
        &scop field-name MissBaseAcc
        {&write-xml}
        &scop field-name MissRublAcc
        {&write-xml}
        &scop field-name MissSale
        {&write-xml}
        &scop field-name WastageSale
        {&write-xml}
        &scop field-name BeforeCliQnty
        {&write-xml}
        &scop field-name AfterCliQnty
        {&write-xml}
        &scop field-name ExtraCliQnty
        {&write-xml}
        &scop field-name MissCliQnty
        {&write-xml}
      end.
      if varis-petrol     and
         not varis-pieces and
         bf_tt-doc-line.ExtDocType = {&TDEDT_Pri_Vnesh}  then do:
        &scop field-name CarNum
        {&write-xml}
        &scop field-name CarVol
        {&write-xml}
        &scop field-name Tests
        {&write-xml}
        &scop field-name AutoentObjType
        {&write-xml}
        &scop field-name AutoentObjCode
        {&write-xml}
        &scop field-name ItemPour
        {&write-xml}
        &scop field-name TimePour
        {&write-xml}
        &scop field-name TankVol
        {&write-xml}
        &scop field-name TankTemp
        {&write-xml}
        &scop field-name TankWater
        {&write-xml}
        &scop field-name TankDensity
        {&write-xml}
        &scop field-name TankWeight
        {&write-xml}
        &scop field-name TimeIncome
        {&write-xml}
      end.
      run value(p-proc-name) in p-handle-callback
          (input '  </doc-line>' + {&new-line}
          ) .
    end.
  end.
end procedure. /* xml-doc_export-line */

procedure xml-doc_export-barcode :
  define input  parameter p-handle-callback as handle    no-undo .
  define input  parameter p-proc-name       as character no-undo .
  define buffer bf_tt-barcode for tt-barcode .
  &scop write-xml      run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', '~{&field-name~}', xml-doc_ReplaceSpecSymbols(string(~{&table-name~}~{&field-name~}))) + v-suffix ) .
  &scop write-xml-date run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', '~{&field-name~}', xml-doc_ReplaceSpecSymbols(string(~{&table-name~}~{&field-name~}, '99/99/9999':U))) + v-suffix ) .

  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .

  do
  on error undo, return error return-value
  :

    assign
      v-prefix = "    "
      v-suffix = {&new-line}
    .

    for each bf_tt-barcode on error undo, return error return-value :
      run value(p-proc-name) in p-handle-callback
          (input '   <barcodedop>' + {&new-line}
          ) .
      &scop table-name bf_tt-barcode.
      &scop field-name DocCode
      {&write-xml}
      &scop field-name GdsCode
      {&write-xml}
      &scop field-name BarCode
      {&write-xml}
      run value(p-proc-name) in p-handle-callback
          (input '   </barcodedop>' + {&new-line}
          ) .
    end.
  end.
end procedure. /* xml-doc_export-dtl */


procedure xml-doc_export-dtl :
  define input  parameter p-handle-callback as handle    no-undo .
  define input  parameter p-proc-name       as character no-undo .
  define buffer bf_tt-gds-dtl for tt-gds-dtl .
  &scop write-xml      run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', '~{&field-name~}', xml-doc_ReplaceSpecSymbols(string(~{&table-name~}~{&field-name~}))) + v-suffix ) .
  &scop write-xml-date run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', '~{&field-name~}', xml-doc_ReplaceSpecSymbols(string(~{&table-name~}~{&field-name~}, '99/99/9999':U))) + v-suffix ) .

  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .

  do
  on error undo, return error return-value
  :

    assign
      v-prefix = "    "
      v-suffix = {&new-line}
    .

    for each bf_tt-gds-dtl on error undo, return error return-value :
      run value(p-proc-name) in p-handle-callback
          (input '  <gds-dtl>' + {&new-line}
          ) .
      &scop table-name bf_tt-gds-dtl.
      &scop field-name DocCode
      {&write-xml}
      &scop field-name ExtDocType
      {&write-xml}
      &scop field-name Artic
      {&write-xml}
      &scop field-name ProdType
      {&write-xml}
      &scop field-name ProdCode
      {&write-xml}
      &scop field-name GdsCode
      {&write-xml}
      &scop field-name ProdName
      {&write-xml}
      &scop field-name GdsName
      {&write-xml}
      &scop field-name PrtCode
      {&write-xml}
      &scop field-name BarCodeUnitBase
      {&write-xml}
      &scop field-name FullPrtName
      {&write-xml}
      &scop field-name ObjType
      {&write-xml}
      &scop field-name ObjCode
      {&write-xml}
      &scop field-name ObjName
      {&write-xml}
      &scop field-name FactQnty
      {&write-xml}
      &scop field-name DocQnty
      {&write-xml}
      &scop field-name PriceRublDoc
      {&write-xml}
      &scop field-name PriceBaseDoc
      {&write-xml}
      &scop field-name DiscntRublDoc
      {&write-xml}
      &scop field-name DiscntBaseDoc
      {&write-xml}
      &scop field-name DiscntType
      {&write-xml}
      &scop field-name DiscntPc
      {&write-xml}
      &scop field-name PriceBaseSale
      {&write-xml}
      &scop field-name Ov
      {&write-xml}
      if bf_tt-gds-dtl.ExtDocType = {&TDEDT_Inv} or
         bf_tt-gds-dtl.extdoctype = {&TDEDT_Peresort}         or
         bf_tt-gds-dtl.extdoctype = {&TDEDT_Corr_Acc_Price}   or
         bf_tt-gds-dtl.extdoctype = {&TDEDT_Corr_Minus_Parts} or
         bf_tt-gds-dtl.extdoctype = {&TDEDT_Chg_Purch_Code}
           then do:
        &scop field-name AfterQnty
        {&write-xml}
      end.
      run value(p-proc-name) in p-handle-callback
          (input '  </gds-dtl>' + {&new-line}
          ) .
    end.
  end.
end procedure. /* xml-doc_export-dtl */

procedure xml-doc_export-parts :
  define input  parameter p-handle-callback as handle    no-undo .
  define input  parameter p-proc-name       as character no-undo .
  define buffer bf_tt-parts for tt-parts .
  &scop write-xml      run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', '~{&field-name~}', xml-doc_ReplaceSpecSymbols(string(~{&table-name~}~{&field-name~}))) + v-suffix ) .
  &scop write-xml-date run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', '~{&field-name~}', xml-doc_ReplaceSpecSymbols(string(~{&table-name~}~{&field-name~}, '99/99/9999':U))) + v-suffix ) .

  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .

  do
  on error undo, return error return-value
  :

    assign
      v-prefix = "    "
      v-suffix = {&new-line}
    .

    for each bf_tt-parts on error undo, return error return-value :
      run value(p-proc-name) in p-handle-callback
          (input '  <parts>' + {&new-line}
          ) .
      &scop table-name bf_tt-parts.
      &scop field-name ObjType
      {&write-xml}
      &scop field-name ObjCode
      {&write-xml}
      &scop field-name ObjName
      {&write-xml}
      &scop field-name ContractId
      {&write-xml}
      &scop field-name ContractNum
      {&write-xml}
      &scop field-name ContractDate
      {&write-xml-date}
      &scop field-name Artic
      {&write-xml}
      &scop field-name ProdType
      {&write-xml}
      &scop field-name ProdCode
      {&write-xml}
      &scop field-name GdsCode
      {&write-xml}
      &scop field-name ProdName
      {&write-xml}
      &scop field-name GdsName
      {&write-xml}
      &scop field-name InCode
      {&write-xml}
      &scop field-name OutCode
      {&write-xml}
      &scop field-name ExtDocType
      {&write-xml}
      &scop field-name CountryAlphaOne
      {&write-xml}
      &scop field-name CountryAlphaTwo
      {&write-xml}
      &scop field-name CountryNumCode
      {&write-xml}
      &scop field-name CountryLongName
      {&write-xml}
      &scop field-name CountryShortName
      {&write-xml}
      &scop field-name PartCode
      {&write-xml}
      &scop field-name Sign
      {&write-xml}
      &scop field-name DocQnty
      {&write-xml}
      &scop field-name PriceBaseAcc
      {&write-xml}
      &scop field-name PriceRublAcc
      {&write-xml}
      &scop field-name FactDate
      {&write-xml-date}
      &scop field-name FactNum
      {&write-xml}
      &scop field-name Sts
      {&write-xml}
      &scop field-name VatPcAcc
      {&write-xml}
      &scop field-name Ps
      {&write-xml}
      &scop field-name PayCode
      {&write-xml}
      &scop field-name FactQnty
      {&write-xml}
      &scop field-name SupplType
      {&write-xml}
      &scop field-name SupplCode
      {&write-xml}
      &scop field-name SupplName
      {&write-xml}
      &scop field-name RsrvFree
      {&write-xml}
      &scop field-name DocType
      {&write-xml}
      &scop field-name PlCode
      {&write-xml}
      &scop field-name VatType
      {&write-xml}
      &scop field-name SupplCrcCode
      {&write-xml}
      &scop field-name PriceSuppl
      {&write-xml}
      &scop field-name SupplRate
      {&write-xml}
      &scop field-name SltPcAcc
      {&write-xml}
      &scop field-name HostCode
      {&write-xml}
      &scop field-name IsSupp
      {&write-xml}
      &scop field-name RealQnty
      {&write-xml}
      &scop field-name SltType
      {&write-xml}
      &scop field-name CstCode
      {&write-xml}
      &scop field-name LastDate
      {&write-xml-date}
      &scop field-name TaxThreeBaseAcc
      {&write-xml}
      &scop field-name TaxThreeRublAcc
      {&write-xml}
      &scop field-name TransportBaseAcc
      {&write-xml}
      &scop field-name TransportRublAcc
      {&write-xml}
      &scop field-name OtherBaseAcc
      {&write-xml}
      &scop field-name OtherRublAcc
      {&write-xml}
      &scop field-name VatBaseAcc
      {&write-xml}
      &scop field-name VatRublAcc
      {&write-xml}
      &scop field-name SltBaseAcc
      {&write-xml}
      &scop field-name SltRublAcc
      {&write-xml}
      if bf_tt-parts.ExtDocType = {&TDEDT_Pri_Vnesh} then do:
        &scop field-name SupplQnty
        {&write-xml}
        &scop field-name SupplCrcAbbr
        {&write-xml}
        &scop field-name SupplCrcName
        {&write-xml}
      end.
      run value(p-proc-name) in p-handle-callback
          (input '  </parts>' + {&new-line}
          ) .
    end.
  end.
end procedure. /* xml-doc_export-parts */

procedure xml-doc_export-attr :
  define input  parameter p-handle-callback as handle    no-undo .
  define input  parameter p-proc-name       as character no-undo .
  define buffer bf_tt-attr for tt-attr .
  &scop write-xml      run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', '~{&field-name~}', xml-doc_ReplaceSpecSymbols(string(~{&table-name~}~{&field-name~}))) + v-suffix ) .
  &scop write-xml-attr      run value(p-proc-name) in p-handle-callback (input v-prefix + substitute('<&1>&2</&1>', bf_tt-attr.attr-code , xml-doc_ReplaceSpecSymbols(string(~{&table-name~}~{&field-name~}))) + v-suffix ) .
  define variable v-prefix as character no-undo .
  define variable v-suffix as character no-undo .

  do
  on error undo, return error return-value
  :

    assign
      v-prefix = "    "
      v-suffix = {&new-line}
    .
    find first bf_tt-attr no-error .
      if available bf_tt-attr then do:
        run value(p-proc-name) in p-handle-callback
            (input '  <doc-attr>' + {&new-line}
            ) .
        &scop table-name bf_tt-attr.
        &scop field-name DocCode
        {&write-xml}

        for each bf_tt-attr on error undo, return error return-value :
        /* обработка для флористов */
        if lookup(substring(bf_tt-attr.attr-code,1,1) ,"0,1,2,3,4,5,6,7,8,9") > 0 then bf_tt-attr.attr-code = "F" + bf_tt-attr.attr-code.
          &scop field-name attr-value
          {&write-xml-attr}
        end.

        run value(p-proc-name) in p-handle-callback
            (input '  </doc-attr>' + {&new-line}
            ) .
    end.
  end.
end procedure. /* xml-doc_export-attr */

/* $Workfile$   E n d */