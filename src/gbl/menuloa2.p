block-level on error undo, throw.
/*

$Revision: 89045e861607, 3582, rls $
$Author: SSlivenko $
$Date: 2023/12/14 13:36:13 $
$Workfile: menuloa2.p $
$Archive: gbl/menuloa2.p $

Пункты меню для утилит смены версии, функций администратора и заказных программ

Автор: Белоусов Илья Александрович
Дата создания: 07/16/07
Author: Ilia Belousov
Creation date: 07/16/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

Первый параметр вызова включаемого файла menuload.i задаёт окно,
в котором появится пункт меню

Пункт меню следует добавлять в соответствующую группу пунктов

Если 8-м параметром сказать yes, то в процедуру передастся parparentproc первым параметром.

*/

/* -------------------------------------------------------------------------- */
/* {&bef-menuload_adm_version}                                                    */
/* АРМ Администратор   Утилиты/Коррекция при смене версии                     */
/* -------------------------------------------------------------------------- */

define variable vss-revision    as character no-undo init "$Revision: 89045e861607, 3582, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: 2023/12/14 13:36:13 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: menuloa2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/menuloa2.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }

/* -------------------------------------------------------------------------- */
/* {&bef-menuload_service_impexp}                                                 */
/* Сервис/ Импорт/Экспорт                                                     */
/* -------------------------------------------------------------------------- */
{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Импорт доп. бар-кодов, внеш. ПН, ДНЦ'"
  "'utl/rinpall.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Импорт групп товаров'"
  "'utl/imp-ggr.p'"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Импорт (изменение) клиентов'"
  "'utl/impcli.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Импорт договоров с поставщиками'"
  "'bge/impcontract.w'"
  " "
  " "
  " "
  " "
  "yes"
  
}
{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Импорт товаров'"
  "'utl/rnpimpgds.p'"
  "no"
  "'11.1'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Экспорт в формате импорта приходной накладной (ПН)'"
  "'utl/exp-doc.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Выгрузка остатков в формате импорта ПН'"
  "'utl/exp-doc2.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Выгрузка текущих остатков в формате импорта ПН'"
  "'utl/exp-doc3.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Экспорт остатков по партиям'"
  "'utl/exp-doc4.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Загрузка GTIN и штрих-коды маркированной продукции '"
  "'bge/loadGTINMark.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Сбор данных по GTIN и штрих-кодам'"
  "'bge/impGTINbarcode.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Импорт накладных по партиям'"
  "'utl/impdoc4run.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Импорт топливных накладных по партиям'"
  "'utl/impdoc4run-ptrl.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Импорт для Фэшн групп'"
  "'cus/imp-fg1.w'"
  "no"
  " "
  " "
  "'NG'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Экспорт в формате импорта документа назначения цены(ДНЦ)'"
  "'utl/exp-pric.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Выгрузка информации в систему Малина'"
  "'bge/exp-malina-man.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
   "'Выгрузка товарного классификатора (ВБРР\Скантек) '"
    " 'bge/exp-VBRR-man.p' "
    " "
    " "
    " "
    " "
    "yes"
}

{ gbl/menuload.i
   {&bef-menuload_service_impexp}
   "'Выгрузка в систему АТД'"
    " 'bge/p-exp-ATD.p' "
    " "
    " "
    " "
    " "
    "yes"
}

{ gbl/menuload.i
   {&bef-menuload_service_impexp}
   "'Выгрузка ВБРР'"
    " 'bge/e-help-road.p' "
    " "
    " "
    " "
    " "
    "yes"
}

{ gbl/menuload.i
   {&bef-menuload_service_impexp}
   "'Экспорт данных по пополнениям и активации для сверки с ВБРР'"
    " 'bge/bge-active-vbrr-p.p' "
    " "
    " "
    " "
    "'Yukos,ibs,Rosneft-*'"
    "yes"
}


{ gbl/menuload.i
   {&bef-menuload_service_impexp}
   "'Выгрузка товарного классификатора (Лояльность\Скантек) '"
    " 'bge/exp-loyal-man.p' "
    " "
    " "
    " "
    " "
    "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Выгрузка информации в систему Carbon'"
  "'bge/exp-carbon-man.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Экспорт документов в формате импорта'"
  "'utl/exp-doc.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Импорт состава сырья'"
  "'utl/struct.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Импорт диск.карт из файла'"
  "'utl/impdcrdr.p'"
  "no"
  "'11.1'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Импорт данных для Луи Вуиттон'"
  "'cus/imp-lui.w'"
  "no"
  "'14.1'"
  "'1'"
  "'Vitton'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Импорт классификатора ЕГАИС'"
  "'utl/i-egais.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_fin_impexp}
  "'Импорт Платежных Поручений (Бизнес-Букет)'"
  "'bge/cbnkrunie.p'"
  "no"
  "'14.1'"
  "'1'"
  "all"
  "yes"
  "'clntbank'"
}

/* -------------------------------------------------------------------------- */
/* {&bef-menuload_service_fin_impexp}                                             */
/*  АРМ ВЗАИМОРАСЧЕТЫ                                                         */
/* Сервис/ Импорт/Экспорт                                                     */
/* -------------------------------------------------------------------------- */

{ gbl/menuload.i
  {&bef-menuload_service_fin_impexp}
  "'ЭКСПОРТ в систему КЛИЕНТ-БАНК'"
  "'bge/cbnkrune.p'"
  "no"
  "'14.1'"
  "'1'"
  "all"
  "yes"
  "'clntbank'"
}

{ gbl/menuload.i
  {&bef-menuload_service_fin_impexp}
  "'ИМПОРТ из системы КЛИЕНТ-БАНК'"
  "'bge/cbnkruni.p'"
  "no"
  "'14.1'"
  "'1'"
  "all"
  "yes"
  "'clntbank'"
}

{ gbl/menuload.i
  {&bef-menuload_service_fin_impexp}
  "'Импорт Платежных Поручений (Бизнес-Букет)'"
  "'bge/cbnkrunie.p'"
  "no"
  "'14.1'"
  "'1'"
  "all"
  "yes"
  "'clntbank'"
}

{ gbl/menuload.i
  {&bef-menuload_service_fin_impexp}
  "'Импорт договоров с поставщиками'"
  "'bge/impcontract.w'"
  " "
  " "
  " "
  " "
  "yes"
  
}
/* -------------------------------------------------------------------------- */
/* {&bef-menuload_service_customs}                                                */
/* Сервис/Заказные программы                                                  */
/* -------------------------------------------------------------------------- */


{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Сменный отчет (Старый формат)'"
  "'rep/g-shift.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Общая сличительная ведомость '"
  "'rep/g-sl-ved.p'"
  " "
  " "
  " "
  "'Yukos,ibs,Rosneft-*'"
  "yes"
}


{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Сверка транзакций перевода средств ОСС (Кубаньнефтепродукт)'"
  "'rep/g-rnk-oss.p'"
  " "
  " "
  " "
  "'yukos,ibs,Rosneft-*'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Понедельный отчет по товарам (реализация в магазине)'"
  "'rep/g-weekm.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Остатки на текущий момент по товарам, оприходованным до ...'"
  "'rep/g-oldrst.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет по платежным системам '"
  "'rep/g-paysys.p'"
  " "
  " "
  " "
  "'Yukos,ibs,Rosneft-*'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Сверка по оплатам QR-кодом'"
  "'rep/g-QR-rep.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Сверка по транзакциям Яндекс'"
  "'rep/g-yandex-rep.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет для контроля возвратных операций'"
  "'rep/g-vbbr_return.p'"
  " "
  " "
  " "
  "'Yukos,ibs,Rosneft-*'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Остатки на опр. дату товаров, оприход. за данный период'"
  "'rep/r-parts.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Реестр документов (Товарный отчет) по секциям'"
  "'cus/r-reestr.w'"
  " "
  " "
  " "
  " "
  "yes"

}

{gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет для сверки ВБРР-Виза'"
  "'rep/g-vbbr_viza.p'"
  " "
  " "
  " "
  "'Yukos,ibs,Rosneft-*'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Продажи топлива и сервисного элемента'"
  "'rep/g-topsrv.p'"
  "  "
  " "
  " "
  "'IBS'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Расход нефтепродуктов через ТРК'"
  "'rep/g-petsal.p'"
  "  "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Расход нефтепродуктов по документам'"
  "'rep/g-petnak.p'"
  "  "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Помесячный оборот по магазинам в ценах продаж (Excel)'"
  "'rep/g-xlben.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Помесячный оборот по производителям в ценах продаж (Excel)'"
  "'rep/g-xlprod.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Помесячный оборот по произв-лю и классификатору (Excel)'"
  "'rep/g-xlseas.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Помесячная реализация в магазине (Excel)'"
  "'rep/g-xlreal.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Товары чеков с ценой, отличной от цены прайса (Excel)'"
  "'cus/g-retprc.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Партии товаров по документам (Excel)'"
  "'rep/g-slprts.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Движение товара по месту хранения (Excel) BENETTON'"
  "'cus/g-benet1.p'"
  "no"
  "'10.3'"
  "'1'"
  "'BENETTON'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Движение товара - сводный отчет (Excel) BENETTON'"
  "'cus/g-benet2.p'"
  "no"
  "'10.3'"
  "'1'"
  "'BENETTON'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет по процентам скидки реализ. товара (Excel) BENETTON'"
  "'cus/g-benet3.p'"
  "no"
  "'10.3'"
  "'1'"
  "'BENETTON,ODIS,Vavilon'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет о реализации товара (Excel) BENETTON'"
  "'cus/g-benet4.p'"
  "no"
  "'10.3'"
  "'1'"
  "'BENETTON'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Остатки по объектам (Excel) BENETTON'"
  "'cus/g-benet5.p'"
  "no"
  "'11.1'"
  "'1'"
  "'BENETTON'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Редактирование списка количества товара на объекте'"
  "'utl/gdsobjls.p'"
  "no"
  "'11.0'"
  "'1'"
  "'ZUM'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет по продажам через кассы'"
  "'rep/g-venit.p'"
  "''"
  "''"
  "''"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Оборот в валюте поставщика'"
  "'cus/g-obval.p'"
  "no"
  "'11.0'"
  "'1'"
  "'KREST'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Остатки и оборот товаров по фирме'"
  "'utl/ut-stk.p'"
  "no"
  "'11.1'"
  "'1'"
  "'TATI'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Начисление и списание бонусов по программе БОНУС-КЛУБ'"
  "'cus/g-bonus1.p'"
  "no"
  "'14.1'"
  "'1'"
  "'Irk-Oil'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Утилита для привязывания единицы измерения к товарам'"
  "'utl/unit-goods.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Выгрузка данных по реализации в учетных ценах (.dbf)'"
  "'rep/g-seb1c.p'"
  "''"
  "''"
  "''"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Выгрузка всех цен по всем объектам'"
  "'utl/put-pr.p'"
  "no"
  "'11.1'"
  "'1'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Импорт карточек товаров из Trade'"
  "'utl/impgds.w'"
  "no"
  "'11.1'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Импорт товаров'"
  "'utl/rnp-imp-gds.p'"
  "no"
  "'11.1'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Экспорт справочных данных для АТД клиента'"
  "'utl/dict-atd-exp-run.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Пересчет учетной цены в переоценке на момент закрытия по всем объектам'"
  "'utl/pr-csac.p'"
  "no"
  "'12.3'"
  "'1'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Заполнение параметров ГРУПП товаров по ОБЪЕКТАМ'"
  "'utl/inigrpcm.w'"
  "''"
  "''"
  "''"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Пересчет архивных партий по закрытой переоценке'"
  "'utl/pr-ut10.p'"
  "no"
  "'12.3'"
  "'1'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Инициализация цены в открытом документе по справочнику товаров (если нет переоценки)'"
  "'utl/invprice.p'"
  "yes"
  "'15.0'"
  "'1'"
  " "
  "yes"
}



{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Изменение даты инкрементальной выгрузки'"
  "'bge/setincrd.w'"
  "''"
  "''"
  "''"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Изменение даты выгрузки данных в SAP (СургутНефтегаз)'"
  "'bge/setsapsngd.w'"
  "''"
  "''"
  "''"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Изменение даты выгрузки данных'"
  "'bge/setmalinad.w'"
  "''"
  "''"
  "''"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Просмотр правил работы ИЖТ'"
  "'gbl/iztrul.w'"
  "''"
  "''"
  "''"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Пересчет документов по продажным ценам по партиям'"
  "'utl/prpar-1.p'"
  "''"
  "''"
  "''"
  " "
  "yes"
}


{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет о состоянии запаса и продажах (Excel)'"
  "'rep/g-zap-pr.p'"
  "''"
  "''"
  "''"
  " "
  "yes"

}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет по поставщикам'"
  "'rep/g-sup-ia.p'"
  "no"
  "'11.1'"
  "'1'"
  "'Trg'"
  "yes"

}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Все чеки по выбранным объектам'"
  "'cus/g-zum1.p'"
  "no"
  "'11.1'"
  "'1'"
  "'ZUM'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Все строки чеков по выбранным объектам'"
  "'cus/g-zum2.p'"
  "no"
  "'11.1'"
  "'1'"
  "'ZUM'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Все строки чеков (товар и оплата) по выбранным объектам'"
  "'cus/g-zum3.p'"
  "no"
  "'11.1'"
  "'1'"
  "'ZUM'"
  "yes"
}
{ gbl/menuload.i
{&bef-menuload_service_customs}
  "'Все строки чеков (с указанием состава сырья) по выбранным объектам'"
  "'cus/g-zum4.p'"
  "no"
  "'11.1'"
  "'1'"
  "'ZUM,UKOS,raimbek'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'ОТЧЕТ ПО ДОКУМЕНТАМ (РЕАЛИЗАЦИЯ В МАГАЗИНЕ)'"
  "'cus/g-zum5.p'"
  "no"
  "'11.1'"
  "'1'"
  "'ZUM'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет объединенная счет-фактура по ответственному хранению'"
  "'cus/g-otv-xr.p'"
  "no"
  "'11.1'"
  "'1'"
  "'ZUM'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Оперативная сводная оборотная ведомость (для небольшого периода)'"
  "'cus/gzobor-s.p'"
  "no"
  "'11.1'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Печать прайс-листа (по переоценкам) с сортировкой по наименованию'"
  "'rep/g-glprcl.p'"
  "no"
  "'11.1'"
  "'1'"
  "'GreenL'"
  "yes"

}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет по движению товара - сводный (Excel) BENETTON'"
  "'rep/g-ben-dt.p'"
  "no"
  "'11.1'"
  "'1'"
  "'BENETTON'"
  "yes"

}
{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Импорт РКС'"
  "'rcs/rcsimp.w'"
  "no"
  "'12.2'"
  "'1'"
  "'rcs'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Расчет необходимого товарного запаса (Excel)'"
  "'rep/g-spd-p.p'"
  "no"
  "'12.2'"
  "'1'"
  " "
  "yes"

}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Остатки по УБД (Excel)'"
  "'cus/g-ost-bd.p'"
  "no"
  "'11.1'"
  "'1'"
  " "
  "yes"

}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Накладная по реализации в магазине'"
  "'cus/g-taxtrh.p'"
  "no"
  "'11.1'"
  "'1'"
  "'hill'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Аналитические отчеты ACTUATE'"
  "'rep/p-actua.p'"
  "no"
  "'11.1'"
  "'1'"
  "'IBS'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Экспорт результатов продаж по признакам (старая версия)'"
  "'cus/exp-kan1.w'"
  "no"
  "'11.1'"
  "'1'"
  "'Can_Ru'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Экспорт текущих товарных остатков'"
  "'cus/exp-kan3.w'"
  "no"
  "'11.1'"
  "'1'"
  "'Can_Ru'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Экспорт результатов продаж по признакам'"
  "'cus/exp-kan0.w'"
  "no"
  "'11.1'"
  "'1'"
  "'Can_Ru'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Экспорт текущих товарных остатков по признакам'"
  "'cus/exp-kan2.p'"
  "no"
  "'11.1'"
  "'1'"
  "'Can_Ru'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Конвертор данных (Can_Ru) - импорт'"
  "'cus/imp-kan1.w'"
  "false "
  "'11.1'"
  "'1'"
  "'Can_Ru'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Удаление ВСЕХ записей маршрутизации по ПОДТВЕРЖДЕННЫМ пакетам'"
  "'utl/delroute.p'"
  "no"
  "'11.1'"
  "'1'"
  "'SportC'"
}
{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Экспорт дополнительных бар-кодов по товарам'"
  "'utl/upload1.p'"
  "no"
  "'11.1'"
  "'1'"
  "'Moroz'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Экспорт результатов продаж  по поставщику'"
  "'cus/exp-meri.w'"
  "no"
  "'12.3'"
  "'1'"
  "'Mari'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет по сумме кассовых услуг, оказанных агентом'"
  "'cus/g-princp.p'"
  "no"
  "'11.1'"
  "'1'"
  "'PeacHom'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Сравнительный отчет по ценам товара на объектах (Excel)'"
  "'cus/g-z-posr.p'"
  "no"
  "'11.1'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Количественный отчет по 2х-уровневой шкале (Excel)'"
  "'rep/g-2-qnty.p'"
  "no"
  "'12.3'"
  "'1'"
  "'ZUM'"
  "yes"

}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Объединенные документы для смены типа приобретения'"
  "'rep/g-corpr.p'"
  "no"
  "'12.3'"
  "'1'"
  " "
  "yes"

}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Запрос на получение архива чеков с касс NCR'"
  "'str/getncryr.p'"
  "no"
  "'11.1'"
  "'1'"
  "'Spar,ProdS'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Продажи постоянным клиентам (Excel) LuiVuitton'"
  "'cus/g-vuidc.p'"
  "no"
  "'12.3'"
  "'1'"
  "'Vitton'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Проставить признак блюда для товаров с рецептом производства'"
  "'utl/fbrsetim.p'"
  "no"
  "'14.0'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Дни продажи товара '"
  "'cus/g-mar1.p'"
  "no"
  "'12.3'"
  "'1'"
  "'Mari'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет по контрагентам списания'"
  "'cus/g-ospis.p'"
  "no"
  "'12.3'"
  "'1'"
  "'Suzdal,ODIS,Vavilon'"
  "yes"

}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет по приходу товара в текстовый файл'"
  "'cus/xl-in.p'"
  "no"
  "'11.1'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет по расходу товара в текстовый файл'"
  "'cus/xl-out.p'"
  "no"
  "'11.1'"
  "'1'"
  " "
  "yes"

}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет по движению товаров в текстовый файл'"
  "'cus/xl-move.w'"
  "no"
  "'11.1'"
  "'1'"
  " "
  "yes"


}
{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Экспорт документов прихода и расхода (в т.ч. незакрытых)'"
  "'utl/g-expie.p'"
  "no"
  "'11.1'"
  "'1'"
  "'BDC,Suzdal,Moroz'"
}

 { gbl/menuload.i
   {&bef-menuload_service_impexp}
  "'Экспорт чеков (расширенный формат)'"
   "'bge/exp-bgecheck.p'"
   "no"
  "'12.2'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Экспорт чеков'"
  "'bge/bgecheck.p'"
  "no"
  "'12.2'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Экспорт данных для АС <Движение н/п в ТПС>'"
  "'bge/bge-ais.w'"
  "no"
  "'12.2'"
  "'1'"
  "'yukos,ibs,Rosneft-*'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Экспорт справочников товаров (расширенный)'"
  "'bge/bgeextgi.p'"
  "no"
  "'12.2'"
  "'1'"
  "'Suzdal'"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет о движении товаров через кассу'"
  "'cus/g-bb.p'"
  "no"
  "'14.0'"
  "'1'"
  "'TopAukc'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Реестр документов по объектам'"
  "'rep/g-reesto.p'"
  "no"
  "'14.0'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Выгрузка в файл данных по продажам по СКМ'"
  "'cus/g-skm.p'"
  "no"
  "'14.1'"
  "'1'"
  "'IBS'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Импорт запроса на внешний расход'"
  "'utl/im-zapvr.p'"
  "no"
  "'14.1'"
  "'1'"
  " "
  "yes"
 }


{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет - Аннуляция чеков'"
  "'cus/g-a-chkv.p'"
  "no"
  "'14.1'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет - Возврат товаров'"
  "'cus/g-v-chkv.p'"
  "no"
  "'14.1'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет - Общая (Кассовый фонд,инкассация,перевод оплаты)'"
  "'cus/g-o-chkv.p'"
  "no"
  "'14.1'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Почасовая реализация на АЗС'"
  "'rep/g-hazkrt.p'"
  "''"
  "''"
  "''"
  "'yukos,ibs,Rosneft-*'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Сводная ведомость по клиентам'"
  "'cus/g-elved1.p'"
  "no"
  "'14.1'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Ведомость клиента за период времени'"
  "'cus/g-elved2.p'"
  "no"
  "'14.1'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Представленность матрицы товаров на объекте'"
  "'rep/g-mattov.p'"
  "no"
  "'14.1'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Реализация по сменам (по группам товаров)'"
  "'rep/g-shftrl.p'"
  "no"
  "'14.1'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Журнал продаж (Excel)'"
  "'rep/g-jor-ru.p'"
  "no"
  "'11.1'"
  "'1'"
  "'IAB'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Состояние запаса (Excel)'"
  "'rep/g-zap-ru.p'"
  "no"
  "'11.1'"
  "'1'"
  "'IAB'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Реестр документов (Кедр-М)'"
  "'rep/g-reestd.p'"
  "no"
  "'15.0'"
  "'1'"
  "'Yukos,ibs,Rosneft-*'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Реализация с печатью накладной поставщика и ГТД (Excel)'"
  "'rep/g-gpcst.p'"
  "no"
  "'14.1'"
  "'1'"
  "'Sporty'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Документы возврата в разрезе накладных поставщика и ГТД (Excel)'"
  "'rep/g-cstvz.p'"
  "no"
  "'15.0'"
  "'1'"
  "'Sporty'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Продажи за неделю для Nielsen'"
  "'rep/g-exp-sl.p'"
  "no"
  "'14.1'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Реализация (Кедр-М)'"
  "'rep/g-kfsale.p'"
  " "
  " "
  " "
  "'Yukos,ibs,Rosneft-*'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Реализация и остатки (Кедр-М)'"
  "'rep/g-kfreba.p'"
  " "
  " "
  " "
  "'Yukos,ibs,Rosneft-*'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Акт переоценки ТАП-1 за период'"
  "'rep/g-tap.p'"
  "no"
  "'14.1'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет о продажах топлива по лотерейным билетам АВТОКУШ'"
  "'cus/g-autocu.p'"
  "''"
  "''"
  "''"
  "'Yukos,ibs,Rosneft-*'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Оборотная ведомость по партиям с ценами производителя (Аптека)'"
  "'rep/g-obprt3.p'"
  "''"
  "''"
  "''"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет по движению СТ. НТФ-8.9'"
  "'rep/g-torg89.p'"
  "''"
  "''"
  "''"
  "'Yukos,ibs,Rosneft-*'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Сводный отчет по движению СТ. НТФ-8.10 (Кедр-М)'"
  "'rep/g-trg810.p'"
  "''"
  "''"
  "''"
  "'Yukos,ibs,Rosneft-*'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет по продажам в разрезе платежных карт'"
  "'cus/g-cpych.p'"
  "''"
  "''"
  "''"
  "'Yukos,ibs,Rosneft-*'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Прайс-лист с фото товаров'"
  "'rep/g-prphot.p'"
  "''"
  "''"
  "''"
  "'TopAukc'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Движение денежных средств (Кедр-М)'"
  "'rep/g-ddinrn.p'"
  "''"
  "''"
  "''"
  "'Yukos,ibs,Rosneft-*'"
  "yes"
}

  { gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет по бонусам'"
  "'rep/g-bonus.p'"
  "''"
  "''"
  "''"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Расчет естественной убыли'"
  "'rep/g-calcwast.p'"
  "''"
  "''"
  "''"
  "'ODIS'"
  "yes"

}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет по списаниям'"
  "'rep/g-wr-off.p'"
  "''"
  "''"
  "''"
  "'Yukos,ibs,Rosneft-*'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Импорт глобальных атрибутов товара (Йошкар-Ола)'"
  "'rep/g-attr-imp.p'"
  "''"
  "''"
  "''"
  "'ODIS,Gurman'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Сличительная ведомость по результатам инвентаризации (Роснефть)'"
  "'rep/g-inv-RN.p'"
  "''"
  "''"
  "''"
  "'yukos,ibs,Rosneft-*'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Данные о реализации НП на АЗС за период (ТамбовНП)'"
  "'rep/g-rnpazs.p'"
  "no"
  "'15.0'"
  "'1'"
  "'yukos,ibs,Rosneft-*'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Движение одноразовой посуды по кафе (Роснефть)'"
  "'rep/g-mdtc.p'"
  "no"
  "'15.0'"
  "'1'"
  "'Yukos,ibs,Rosneft-*'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Суточные сводки (ТамбовНП)'"
  "'rep/g-tdsum.p'"
  "no"
  "'15.0'"
  "'1'"
  "'yukos,ibs,Rosneft-*'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_customs}
  "'Отчет об отчислениях в ЛПВ'"
  "'rep/g-asLPV.p'"
  "''"
  "''"
  "''"
  "'yukos,ibs,Rosneft-*'"
  "yes"
}

/* -------------------------------------------------------------------------- */
/* {&bef-menuload_service_utility}                                                */
/* Сервис/ Служебные программы                                                */
/* -------------------------------------------------------------------------- */


{gbl/menuload.i
 {&bef-menuload_service_utility}
 "'Начальное формирование справочника критериев анализа'"
 "'utl/abc-utl.p'"
 "''"
 "''"
 "''"
 " "
 "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Изменение ставки НДС на 20% в спецификациях'"
  "'utl/specifNDS.p'"
  "''"
  "''"
  "''"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Информация о складских архивах'"
  "'utl/ah-infov.w'"
  "''"
  "''"
  "''"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Редактирование сроков годности партий товара'"
  "'rep/g-parlas.p'"
  "no"
  "'14.0'"
  "'1'"
  " "
  "yes"
}


{gbl/menuload.i
{&bef-menuload_service_utility}
"'Утилита копирования состава товара'"
"'utl/coppy_tov.p'"
"''"
"''"
"''"
" "
"yes"
}


{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Коррекция партий внешнего прихода закрытого на факт'"
  "'utl/trn-vatt.p'"
  " "
  " "
  " "
  "'IBS'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Коррекция партий внешнего прихода МФ закрытого на факт'"
  "'utl/trn-vath.p'"
  " "
  " "
  " "
  "'IBS'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Привязка партий и складских документов к договору поставщика'"
  "'utl/fillcont.w'"
  "false"
  "'14.0'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Переименование артикула и(или) производителя'"
  "'utl/run-nar1.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Досылка сформированных файлов на кассу IBM-XML'"
  "'str/rsndxibr.p'"
  "no"
  "'14.1'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Обновление реквизитов клиентов в незакрытых платежах из договора'"
  "'utl/updfind.w'"
  "false"
  "'14.1'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Простановка ГТД во все партии по списку ПН (тек.БД)'"
  "'utl/trncstsl.p'"
  "false"
  "'14.1'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Пересчет баланса ФО и платежей к договору'"
  "'utl/cont-bal.p'"
  "false"
  "'15.0'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Экспорт настроек объектов TH'"
  "'utl/thbjexp.p'"
  "no"
  "'15.0'"
  "'1'"
  " "
  "yes"
}


{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Конфигурация машины правил - RuM'"
  "'rul/rulconfig.w'"
  "no"
  "'15.0'"
  "'1'"
  "'IBS'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Конфигурация правил скидок'"
  "'utl/drconfig.w'"
  "no"
  "'15.0'"
  "'1'"
  "'IBS'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Конфигурация настраиваемых полей'"
  "'utl/cus-lblr.p'"
  "no"
  "'15.0'"
  "'1'"
  "''"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Конфигурация атрибутов'"
  "'utl/attrpcfg.w'"
  "no"
  "'15.0'"
  "'1'"
  "'IBS'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Конфигурация гейтов'"
  "'utl/gates.w'"
  "no"
  "'15.0'"
  "'1'"
  "'IBS'"
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Конфигурация раскладок'"
  "'adm/lay-conf.w'"
  "no"
  "'15.0'"
  "'1'"
  "'IBS'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Удаление фильтров и пользовательских настроек'"
  "'utl/clearflt.w'"
  "no"
  "'15.0'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Конфигурация логирования кассы IBS TH POS'"
  "'adm/cdevconf.w'"
  "no"
  "'15.0'"
  "'1'"
  "'IBS'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Закрытие договоров, срок действия которых истёк'"
  "'utl/contrcls.p'"
  "no"
  "'15.0'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Генерация ПН по РН'"
  "'utl/g-florma.p'"
  "no"
  "'15.0'"
  "'1'"
  "'TopAukc'"
  "yes"
}
/* 04/III-2019 не используется. Работа с кассовыми книгами перенесена в БПА
{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Изменение текущего номера ПКО/РКО'"
  "'utl/setkonum.w'"
  "no"
  "'15.0'"
  "'1'"
  " "
  "yes"
}
*/
{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Мониторинг инкрементальной выгрузки в XML'"
  "'rep/inc-upl-mon.w'"
  "no"
  "'15.0'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Загрузка фото товаров'"
  "'utl/imgsearch.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Перенос изображений в новую структуру'"
  "'utl/image2lst.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Генерация пароля для технологического пролива'"
  "'utl/gen-pwd.p'"
  " "
  " "
  " "
  " "
  "yes"
} 

{ gbl/menuload.i
  {&bef-menuload_service_utility}
  "'Импорт GTIN из файла'"
  "'utl/imp-gtin.p'"
  " "
  " "
  " "
  " "
  "yes"
}
/* -------------------------------------------------------------------------- */
/* {&bef-menuload_service_check}                                                  */
/* Сервис/ Программы проверки                                                 */
/* -------------------------------------------------------------------------- */

{ gbl/menuload.i
  {&bef-menuload_service_check}
  "'Tест корректности отчета о продаже'"
  "'utl/test000i.w'"
  "no"
  "'11.1'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_check}
  "'Tест корректности чеков'"
  "'utl/test000.w'"
  "no"
  "'11.1'"
  "'1'"
  " "
  "yes"

}

{ gbl/menuload.i
  {&bef-menuload_service_check}
  "'Проверка партий и складских документов на соответствие договора поставщика'"
  "'utl/chk-cont.p'"
  "false"
  "'14.0'"
  "'1'"
  " "
  "yes"
}