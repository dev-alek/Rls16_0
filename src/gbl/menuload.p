block-level on error undo, throw.
/*

$Revision: 03b1296bf1bc, 3388, rls $
$Author: DRuban $
$Date: 2023/06/07 13:19:21 $
$Workfile: menuload.p $
$Archive: gbl/menuload.p $

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
продолжение в menuloa2.p

Если 8-м параметром сказать yes, то в процедуру передастся parparentproc первым параметром.

*/

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: 03b1296bf1bc, 3388, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/06/07 13:19:21 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: menuload.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/menuload.p $":U .
define variable vss-description as character no-undo init "Информация об объекте интерфейса".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }

/* -------------------------------------------------------------------------- */
/* {&menuload_adm_version}                                                    */
/* АРМ Администратор   Утилиты/Коррекция при смене версии                     */
/* -------------------------------------------------------------------------- */
{ gbl/menuload.i
  {&bef-menuload_adm_version}
 "'Перенос данных из старой БД в 16.0 (РАСТЯНУТЫЙ UPGRADE)'"
  "'utl/thth-all.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Приходы,расходы,возвраты по контрагентам(пересчет итогов)'"
  "'utl/incligds.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Исправление названий групп товаров'"
  "'utl/inigrpu.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Исправление названий групп клиентов'"
  "'utl/inicliu.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Партии товаров'"
  "'utl/ini-part.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Фирма в складских документах и товарах'"
  "'utl/ini-host.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Нац.вал., основные единицы и пр.'"
  "'utl/kick-db.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Установка метода расчета учетных цен FIFO для всех товаров'"
  "'utl/ini-cost.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Проверка ссылок на товар для товаров на объекте'"
  "'utl/chk-gdsd.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Инициализация остатков по поставщикам'"
  "'utl/ini-supp.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Дата создания партий (в свободной и расходной зоне)'"
  "'utl/ini-pfdt.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Название на этикетке по русскому названию товара'"
  "'utl/ini-labl.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Составные товары / ингредиенты в производстве'"
  "'utl/ini-comp.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Пересчет расходных накладных(НДС)'"
  "'utl/recl-vat.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Поиск и удаление неправильных записей prt-obj'"
  "'utl/chkprtob.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Инициализация атрибутов товара на объекте'"
  "'utl/allgdsat.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Инициализация атрибута: резервирование товара по складским местам'"
  "'utl/plcrsrv.p'"
  "yes"
  "'10.3'"
  "'1'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Проставить фактические номера документов'"
  "'utl/factofil.p'"
  "yes"
  "'10.3'"
  "'4'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Создание бар-кодов партий для товаров, которые продаются по партиям'"
  "'utl/allbccr.p'"
  "yes"
  "'10.3'"
  "'6'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Поиск и исправление приходов с автоматическими переоценками с неправильным fact-num'"
  "'utl/chk-trn.p'"
  "yes"
  "'10.4'"
  "'2'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Установка признаков клиентов'"
  "'utl/chng-cli.p'"
  "yes"
  "'11.0'"
  "'2'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Инициализация неопределенных учетных цен в партиях'"
  "'utl/docpartn.p'"
  "yes"
  "'12.3'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Создание атрибутов партий'"
  "'utl/objprtat.p'"
  "yes"
  "'12.3'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Выравнивание остатков по партиям свободной зоны'"
  "'utl/vpargds.p'"
  "yes"
  "'14.2'"
  "'1'"
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Проталкивание параметров Накладных и Переоценок из ГБД в УБД'"
  "'utl/movnwsgp.p'"
  "yes"
  "'15.0'"
  "'1'"
  " "
  "yes"
}


{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Инициализация дат начала и конца движения товара на объекте'"
  "'utl/gdsolasd.p'"
  "yes"
  "'11.0'"
  "'4'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Проверка налогов в переоценке'"
  "'utl/g-pr-u8.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Создание ассортиментной матрицы на основе таблицы gds-obj за вычетом атрибута attr-no-income-goods'"
  "'utl/crassmxa.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_version}
  "'Отправить настройки пользователей - права, меню по новостям'"
  "'utl/sndusrnw.p'"
  " "
  " "
  " "
  " "
  "yes"
}


/* -------------------------------------------------------------------------- */
/* {&bef-menuload_adm_function}                                                   */
/* АРМ Администратор   Утилиты/Функции администратора                         */
/* -------------------------------------------------------------------------- */

{gbl/menuload.i
{&bef-menuload_adm_function}
"'Корекция даты на объекте'"
"'utl/cor-date.w'"
" "
" "
" "
" "
"yes"
}

{gbl/menuload.i
{&bef-menuload_adm_function}
"'Изменение статуса сверки'"
"'utl/cor-rvs_status.w'"
" "
" "
" "
" "
"yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Единицы измерения по списку товаров'"
  "'utl/ini-unit.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Восстановление статуса БД'"
  "'utl/fix-db-stts.w'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Включение выключенных доп. БК'"
  "'utl/bc-on.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Имена контрагентов в накладных'"
  "'utl/ini-name.p'"
  "yes"
  "'11.0'"
  "'1'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Изменение артикула товара'"
  "'utl/run-nart.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Изменение производителя товара по списку товаров'"
  "'utl/pren-art.w'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Смена группы по списку товаров'"
  "'utl/mov-grp.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Контекстная замена в названиях товаров'"
  "'adm/rplc-gds.w'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Утилита проверки целостности свободной зоны марок'"
  "'rep/g-alcmarks.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Утилита отката помарочного учета'"
  "'utl/rollback-mark.p'"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Выравнивание статусов марок в свободной зоне'"
  "'utl/free-mark.p'"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Создание статусов марок в серой зоне'"
  "'utl/gray-zone.p'"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Изменение товаров по списку'"
  "'utl/gdsuform.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Изменение дисконтных карт по списку'"
  "'utl/discarui.w'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Изменить propath'"
  "'utl/ppath.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Архивация чеков'"
  "'utl/chk-arh.w'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Разархивация чеков'"
  "'utl/undo-chk.w'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
 {&bef-menuload_adm_function}
  "'Снятие отметки <Требует переоценки> с товаров'"
  "'utl/in-ov1.p'"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Снять отметки <Требует переоценки> для удаленных товаров'"
  "'utl/inov-del.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Изменить названия контрагентов в документах матценностей'"
  "'utl/w-chclin.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Сортировка одного уровня шкалы'"
  "'utl/sort-grp.w'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Переименование признаков шкалы'"
  "'utl/rengrpsl.w'"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Установка атрибутов товара РЕСТОРАН'"
  "'utl/fbrgdsag.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Выполнить процедуру'"
  "'gbl/d-runpro.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Простановка налогов по группам товаров'"
  "'utl/inigrptx.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Раскрутка системы'"
  "'utl/s-deploy.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Утилита проверки фото товаров'"
  "'utl/img-check.p'"
  " "
  " "
  " "
  " "
  "yes"
}


{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Асинхронные процессы'"
  "'ref/procbrow.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Утилита работы с УТМ'"
  "'bge/egais-utm.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Загрузка данных из ТН v15.0'"
  "'utl/load-from-15_0.w'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Тиражная утилита'"
  "'utl/draw-util.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Просмотр и изменение диапазонов кодов'"
  "'utl/fixbcode.w'"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Процедура проверки, восстановления Sequences'"
  "'utl/rest_seq.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Экспорт/импорт прав и пользователей'"
  "'utl/exp-imp.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Выравнивание остатков по массе'"
  "'utl/reclck_go.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Корректировка даты на объекте'"
  "'utl/cor-date.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Корректировка закрытых сверок'"
  "'utl/updclrvs.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Удаление неиспользуемых дополнительных бар-кодов'"
  "'utl/deleted_pbc.p'"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Повторная выгрузка данных для 1С ERP'"
  "'utl/send-1C.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Перевыгрузка не подтвержденных сообщений 1С ERP'"
  "'utl/reload-1C.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Выгрузка данных в Президентский Мониторинг  '"
  "'utl/run-exp-is_PM.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Синхронизация счетчиков документов'"
  "'utl/seq-sync.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Повторная инициализация расчета контрольных значений НП по периодам'"
  "'utl/init-shift-period_utl.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Утилита применения новых градуировочных таблиц'"
  "'utl/apply_place-imp_utl.w'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_function}
  "'Загрузка перечня IP TH'"
  "'utl/thipimp.p'"
}

/* -------------------------------------------------------------------------- */
/* {&bef-menuload_adm_check}                                                      */
/* АРМ Администратор   Утилиты/Проверки                                       */
/* -------------------------------------------------------------------------- */
{ gbl/menuload.i
  {&bef-menuload_adm_check}
  "'Поиск выключенных весовых доп. БК'"
  "'utl/udvespbc.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_check}
  "'Получить список неактивных индексов'"
  "'utl/idxinact.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_check}
  "'Проверка целостности товара'"
  "'utl/allcheck.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_check}
  "'Проверка названий групп товаров'"
  "'utl/inigrps.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_check}
  "'Проверка названий групп клиентов'"
  "'utl/iniclis.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_check}
  "'Проверка строк переоценок'"
  "'utl/fixprcls.p'"
  "yes"
  "'10.3'"
  "'2'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_check}
  "'Уникальность в группах клиентов'"
  "'utl/cli-grpu.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_check}
  "'Уникальность в группах товаров'"
  "'utl/gds-grpu.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_check}
  "'Совпадения основных и доп. БК'"
  "'utl/bc-str.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_check}
  "'Совпадения весовых кодов без ведущих нулей и доп. БК'"
  "'utl/bc-scals.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_check}
  "'Cовпадения доп. БК с вес. префиксом (EAN13) и весовых кодов'"
  "'utl/fo-scals.p'"
}

{ gbl/menuload.i
  {&bef-menuload_adm_check}
  "'Проверка наличия переоценок у товаров с ценой в справочнике'"
  "'utl/pr-u11.p'"
}



/* -------------------------------------------------------------------------- */
/* {&bef-menuload_adm_archive}                                                    */
/* АРМ Администратор   Утилиты/Работа с архивами                              */
/* -------------------------------------------------------------------------- */
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Информация о складских архивах'"
  "'utl/ah-infov.w'"
  "''"
  "''"
  "''"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Утилита пересчета финансовых архивов'"
  "'utl/rclcfarh1.w'"
  "''"
  "''"
  "''"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Выполнить отложенные задания (BatchProcess)'"
  "'utl/run-btpr.p'"
  "yes"
  "'14.0'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Запретить/разрешить расчет архивов'"
  "'utl/ah-disab.p'"
  "yes"
  "'14.0'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Установить признак отсутствия складских архивов'"
  "'utl/ah-clin.p'"
  "yes"
  "'11.0'"
  "'5'"
  " "
  "yes"

}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Переименование атрибутов складских архивов'"
  "'utl/renattr.p'"
  "false"
  "'12.3'"
  "'1'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Расчёт складского архива по товарам'"
  "'utl/objarh.p'"
  "yes"
  "'10.3'"
  "'5'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Расчёт складского архива по поставщикам'"
  "'utl/objahsp.p'"
  "yes"
  "'11.0'"
  "'3'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Расчёт складского архива по типам приобретения'"
  "'utl/objaht.p'"
  "yes"
  "'12.3'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Расчёт межфирменного архива по приходам и расходам'"
  "'utl/harhclst.p'"
  "yes"
  "'12.2'"
  "'1'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Расчёт межфирменного архива по инвентаризациям'"
  "'utl/harh-inv.p'"
  "yes"
  "'12.3'"
  "'1'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Расчёт межфирменного архива по документам списания'"
  "'utl/harh-spi.p'"
  "yes"
  "'12.3'"
  "'1'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Частичный расчет межфирменного архива по приходам и продажам'"
  "'utl/hoca-sta.p'"
  "yes"
  "'12.3'"
  "'1'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Частичный расчет межфирменного архива по документам инвентаризации'"
  "'utl/hoca-inv.p'"
  "yes"
  "'12.3'"
  "'1'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Частичный расчет межфирменного архива по документам списания'"
  "'utl/hoca-spi.p'"
  "yes"
  "'12.3'"
  "'1'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Инициализация складского архива по товарам'"
  "'utl/arh-init.p'"
  "false"
  "'12.3'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Инициализация складского архива по поставщикам'"
  "'utl/ahspinit.p'"
  "false"
  "'12.3'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Инициализация складского архива по типам приобретения'"
  "'utl/aht-init.p'"
  "false"
  "'12.3'"
  "'1'"
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Проверка целостности документов переоценок'"
  "'utl/chkprdoc.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Сжатие/удаление складского архива по товарам'"
  "'utl/del-arh.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Восстановление складского архива по товарам'"
  "'utl/rst-arh.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Проверка целостности складского архива по товарам'"
  "'utl/cas-arh.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Проверка оборота переоценки архива по товарам'"
  "'utl/prover-prc.p'"
  " "
  " "
  " "
  " "
  "no"
}

{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Сжатие/удаление складского архива по поставщикам'"
  "'utl/del-ahsp.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Восстановление складского архива по поставщикам'"
  "'utl/rst-ahsp.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Проверка целостности складского архива по поставщикам'"
  "'utl/cas-ahsp.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Сжатие/удаление складского архива по типам приобретения'"
  "'utl/del-aht.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Восстановление складского архива по типам приобретения'"
  "'utl/rst-aht.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Проверка целостности складского архива по типам приобретения'"
  "'utl/cas-aht.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Инициализация фин. архива arh-trn-doc-contract'"
  "'utl/g-initcn.p'"
  " "
  " "
  " "
  " "
  "yes"
}
/*Утилита нужна только в экстренных случаях, когда нет ни одного правильного остатка в архивах
{ gbl/menuload.i
  {&bef-menuload_adm_archive}
  "'Создание записи остатков финансового архива arh-trn-doc-contract на дату обрезания'"
  "'utl/ost-cont.p'"
  " "
  " "
  " "
  " "
  "yes"
}
*/


/* -------------------------------------------------------------------------- */
/* {&bef-menuload_adm_impexp}                                                 */
/* АРМ Администратор   Утилиты/Импорт/Экспорт                                 */
/* -------------------------------------------------------------------------- */
{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Импорт доп. бар-кодов, внеш. ПН, ДНЦ'"
  "'utl/rinpall.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Экспорт в формате импорта приходной накладной(ПН)'"
  "'utl/exp-doc.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Экспорт в формате импорта документа назначения цены(ДНЦ)'"
  "'utl/exp-pric.p'"
  " "
  " "
  " "
  " "
  "yes"
}


{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Импорт групп товаров'"
  "'utl/impggr.w'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
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
  "'Импорт ТНВЕД в карточку товара'"
  "'utl/imp-tnvd.p'"
  "no"
  "'12.3'"
  "'1'"
  "'BDC,PortAl'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_service_impexp}
  "'Импорт страны происхождения в карточку товара'"
  "'utl/impalpha.p'"
  "no"
  "'14.1'"
  "'1'"
  "'BDC'"
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Импорт кассиров'"
  "'utl/imp-cashier.w'"
  " "
  " "
  " "
  " "
  "yes"
}


{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Импорт (изменение) клиентов'"
  "'utl/impclir.p'"
  " "
  " "
  " "
  " "
  "yes"
}

{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Импорт товаров'"
  "'utl/impgdsr.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Импорт рецептов'"
  "'utl/imprecipe.p'"
  " "
  " "
  " "
  " "
  "yes"
}


{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Экспорт справочника товаров'"
  "'utl/exp-gds.p'"
  " "
  " "
  " "
  " "
  "yes"
}
{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Экспорт значений параметров'"
  "'bge/cashparexp.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Импорт значений параметров'"
  "'bge/cashparimp.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Экспорт групп товаров'"
  "'utl/expggr.w'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Экспорт справочника клиенты'"
  "'utl/exp-cli.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Экспорт справочника валюты и курсы'"
  "'utl/exp-curr.p'"
}
{ gbl/menuload.i
  {&bef-menuload_adm_impexp}
  "'Экспорт справочника виды оплат'"
  "'utl/exp-payt.p'"
}
{ gbl/menuload.i
{&bef-menuload_adm_impexp}
  "'Импорт/Экспорт артикулов поставщиков'"
  "'utl/iecliart.w'"
  " "
  " "
  " "
  " "
  "yes"
}