/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Глобальные определения имен таблиц

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/29/07
Author: Bakhtadze Natalya
Creation date: 01/29/07

Файл автоматически создается процедурой utl/gen-tbln.p

*/

&glob bef-table_abc-analysis-full ABC анализ
&glob table_abc-analysis-full '{&bef-table_abc-analysis-full}':U
&glob bef-table_abc-analysis-attr-full Атрибуты шапки ABC анализа
&glob table_abc-analysis-attr-full '{&bef-table_abc-analysis-attr-full}':U
&glob bef-table_abc-analysis-cli-full ABC по Контрагентам
&glob table_abc-analysis-cli-full '{&bef-table_abc-analysis-cli-full}':U
&glob bef-table_abc-analysis-cli-attr-full abc-analysis-cli-attr
&glob table_abc-analysis-cli-attr-full '{&bef-table_abc-analysis-cli-attr-full}':U
&glob bef-table_abc-analysis-doc-full Список расш типов докум в ABC
&glob table_abc-analysis-doc-full '{&bef-table_abc-analysis-doc-full}':U
&glob bef-table_abc-analysis-doc-attr-full Атрибуты для abc-analysis-doc
&glob table_abc-analysis-doc-attr-full '{&bef-table_abc-analysis-doc-attr-full}':U
&glob bef-table_abc-analysis-gds-obj-full Товары по объектам в ABC анал
&glob table_abc-analysis-gds-obj-full '{&bef-table_abc-analysis-gds-obj-full}':U
&glob bef-table_abc-analysis-gds-obj-attr-full Атр товаров по объектам в ABC
&glob table_abc-analysis-gds-obj-attr-full '{&bef-table_abc-analysis-gds-obj-attr-full}':U
&glob bef-table_abc-analysis-goods-full Товары в ABC анализе
&glob table_abc-analysis-goods-full '{&bef-table_abc-analysis-goods-full}':U
&glob bef-table_abc-analysis-goods-attr-full Атрибуты товара в ABC анализе
&glob table_abc-analysis-goods-attr-full '{&bef-table_abc-analysis-goods-attr-full}':U
&glob bef-table_abc-analysis-grp-full ABC по группам
&glob table_abc-analysis-grp-full '{&bef-table_abc-analysis-grp-full}':U
&glob bef-table_abc-analysis-grp-attr-full Атрибуты для abc-analysis-grp
&glob table_abc-analysis-grp-attr-full '{&bef-table_abc-analysis-grp-attr-full}':U
&glob bef-table_abc-analysis-obj-full Объекты для шапки ABC анализа
&glob table_abc-analysis-obj-full '{&bef-table_abc-analysis-obj-full}':U
&glob bef-table_abc-analysis-obj-attr-full Атрибуты для abc-analysis-obj
&glob table_abc-analysis-obj-attr-full '{&bef-table_abc-analysis-obj-attr-full}':U
&glob bef-table_abc-analysis-period-full Периоды для шапки ABC анализа
&glob table_abc-analysis-period-full '{&bef-table_abc-analysis-period-full}':U
&glob bef-table_abc-analysis-period-attr-full Атрибуты для abc-analysis-period
&glob table_abc-analysis-period-attr-full '{&bef-table_abc-analysis-period-attr-full}':U
&glob bef-table_abc-analysis-prod-full ABC по производителям
&glob table_abc-analysis-prod-full '{&bef-table_abc-analysis-prod-full}':U
&glob bef-table_abc-analysis-prod-attr-full Атрибуты для abc-analysis-prod
&glob table_abc-analysis-prod-attr-full '{&bef-table_abc-analysis-prod-attr-full}':U
&glob bef-table_abcxyz-analysis-full Сопоставление ABC и XYZ анализ
&glob table_abcxyz-analysis-full '{&bef-table_abcxyz-analysis-full}':U
&glob bef-table_abcxyz-analysis-attr-full Атрибуты ABC/XYZ сопоставления
&glob table_abcxyz-analysis-attr-full '{&bef-table_abcxyz-analysis-attr-full}':U
&glob bef-table_abcxyz-analysis-goods-full Товары в ABC/XYZ сопост
&glob table_abcxyz-analysis-goods-full '{&bef-table_abcxyz-analysis-goods-full}':U
&glob bef-table_abcxyz-analysis-goods-attr-full Атрибуты товара в ABC/XYZ сопо
&glob table_abcxyz-analysis-goods-attr-full '{&bef-table_abcxyz-analysis-goods-attr-full}':U
&glob bef-table_action-group-full action-group
&glob table_action-group-full '{&bef-table_action-group-full}':U
&glob bef-table_action-group-attr-full Атрибуты для action-group
&glob table_action-group-attr-full '{&bef-table_action-group-attr-full}':U
&glob bef-table_action-head-full action-head
&glob table_action-head-full '{&bef-table_action-head-full}':U
&glob bef-table_action-head-attr-full Атрибуты для action-head
&glob table_action-head-attr-full '{&bef-table_action-head-attr-full}':U
&glob bef-table_action-item-full action-item
&glob table_action-item-full '{&bef-table_action-item-full}':U
&glob bef-table_action-item-attr-full Атрибуты для action-item
&glob table_action-item-attr-full '{&bef-table_action-item-attr-full}':U
&glob bef-table_action-post-full action-post
&glob table_action-post-full '{&bef-table_action-post-full}':U
&glob bef-table_action-post-attr-full Атрибуты для action-post
&glob table_action-post-attr-full '{&bef-table_action-post-attr-full}':U
&glob bef-table_action-post-host-full action-post-host
&glob table_action-post-host-full '{&bef-table_action-post-host-full}':U
&glob bef-table_action-post-host-attr-full Атрибуты для action-post-host
&glob table_action-post-host-attr-full '{&bef-table_action-post-host-attr-full}':U
&glob bef-table_action-post-menu-group-full action-post-menu-group
&glob table_action-post-menu-group-full '{&bef-table_action-post-menu-group-full}':U
&glob bef-table_action-post-menu-group-attr-full Атрибуты для action-post-menu-group
&glob table_action-post-menu-group-attr-full '{&bef-table_action-post-menu-group-attr-full}':U
&glob bef-table_action-post-obj-full action-post-obj
&glob table_action-post-obj-full '{&bef-table_action-post-obj-full}':U
&glob bef-table_action-post-obj-attr-full Атрибуты для action-post-obj
&glob table_action-post-obj-attr-full '{&bef-table_action-post-obj-attr-full}':U
&glob bef-table_action-post-role-full action-post-role
&glob table_action-post-role-full '{&bef-table_action-post-role-full}':U
&glob bef-table_action-post-role-attr-full Атрибуты для action-post-role
&glob table_action-post-role-attr-full '{&bef-table_action-post-role-attr-full}':U
&glob bef-table_action-post-user-login-full action-post-user-login
&glob table_action-post-user-login-full '{&bef-table_action-post-user-login-full}':U
&glob bef-table_action-post-user-login-attr-full Атрибуты для action-post-user-login
&glob table_action-post-user-login-attr-full '{&bef-table_action-post-user-login-attr-full}':U
&glob bef-table_action-role-full action-role
&glob table_action-role-full '{&bef-table_action-role-full}':U
&glob bef-table_action-role-attr-full Атрибуты для action-role
&glob table_action-role-attr-full '{&bef-table_action-role-attr-full}':U
&glob bef-table_action-role-item-full action-role-item
&glob table_action-role-item-full '{&bef-table_action-role-item-full}':U
&glob bef-table_action-role-item-attr-full Атрибуты для action-role-item
&glob table_action-role-item-attr-full '{&bef-table_action-role-item-attr-full}':U
&glob bef-table_action-role-item-gds-full Привязка товаров к правам
&glob table_action-role-item-gds-full '{&bef-table_action-role-item-gds-full}':U
&glob bef-table_action-role-item-gds-grp-full Привязка прав к группе товаров
&glob table_action-role-item-gds-grp-full '{&bef-table_action-role-item-gds-grp-full}':U
&glob bef-table_add-doc-full Документы доп.расходов
&glob table_add-doc-full '{&bef-table_add-doc-full}':U
&glob bef-table_add-line-full Строки документа доп.расходы
&glob table_add-line-full '{&bef-table_add-line-full}':U
&glob bef-table_add-trn-full Связь доп.расх и ПН
&glob table_add-trn-full '{&bef-table_add-trn-full}':U
&glob bef-table_add-trn-attr-full Атрибуты связи доп.расх и ПН
&glob table_add-trn-attr-full '{&bef-table_add-trn-attr-full}':U
&glob bef-table_aht-doc-full aht-doc
&glob table_aht-doc-full '{&bef-table_aht-doc-full}':U
&glob bef-table_aht-doc-attr-full Атрибуты для aht-doc
&glob table_aht-doc-attr-full '{&bef-table_aht-doc-attr-full}':U
&glob bef-table_aht-gds-full aht-gds
&glob table_aht-gds-full '{&bef-table_aht-gds-full}':U
&glob bef-table_aht-gds-attr-full Атрибуты для aht-gds
&glob table_aht-gds-attr-full '{&bef-table_aht-gds-attr-full}':U
&glob bef-table_aht-ot-line-full aht-ot-line
&glob table_aht-ot-line-full '{&bef-table_aht-ot-line-full}':U
&glob bef-table_aht-ot-line-attr-full Атрибуты для aht-ot-line
&glob table_aht-ot-line-attr-full '{&bef-table_aht-ot-line-attr-full}':U
&glob bef-table_aht-ot-tot-full aht-ot-tot
&glob table_aht-ot-tot-full '{&bef-table_aht-ot-tot-full}':U
&glob bef-table_aht-ot-tot-attr-full Атрибуты для aht-ot-tot
&glob table_aht-ot-tot-attr-full '{&bef-table_aht-ot-tot-attr-full}':U
&glob bef-table_aht-stk-full aht-stk
&glob table_aht-stk-full '{&bef-table_aht-stk-full}':U
&glob bef-table_aht-stk-attr-full Атрибуты для aht-stk
&glob table_aht-stk-attr-full '{&bef-table_aht-stk-attr-full}':U
&glob bef-table_aht-stk-line-full aht-stk-line
&glob table_aht-stk-line-full '{&bef-table_aht-stk-line-full}':U
&glob bef-table_aht-stk-line-attr-full Атрибуты для aht-stk-line
&glob table_aht-stk-line-attr-full '{&bef-table_aht-stk-line-attr-full}':U
&glob bef-table_aht-stk-tot-full aht-stk-tot
&glob table_aht-stk-tot-full '{&bef-table_aht-stk-tot-full}':U
&glob bef-table_aht-stk-tot-attr-full Атрибуты для aht-stk-tot
&glob table_aht-stk-tot-attr-full '{&bef-table_aht-stk-tot-attr-full}':U
&glob bef-table_aht-time-full aht-time
&glob table_aht-time-full '{&bef-table_aht-time-full}':U
&glob bef-table_aht-time-attr-full Атрибуты для aht-time
&glob table_aht-time-attr-full '{&bef-table_aht-time-attr-full}':U
&glob bef-table_alc-sale-lic-full Лицензии на поставку алкоголя
&glob table_alc-sale-lic-full '{&bef-table_alc-sale-lic-full}':U
&glob bef-table_alc-sale-lic-attr-full alc-sale-lic-attr
&glob table_alc-sale-lic-attr-full '{&bef-table_alc-sale-lic-attr-full}':U
&glob bef-table_alc-sale-lic-type-full Связь лицензий с типами алкоголя
&glob table_alc-sale-lic-type-full '{&bef-table_alc-sale-lic-type-full}':U
&glob bef-table_alc-sale-lic-type-attr-full Атрибуты для alc-sale-lic-type
&glob table_alc-sale-lic-type-attr-full '{&bef-table_alc-sale-lic-type-attr-full}':U
&glob bef-table_alc-supp-lic-full Лицензии на поставку алкоголя
&glob table_alc-supp-lic-full '{&bef-table_alc-supp-lic-full}':U
&glob bef-table_alc-supp-lic-attr-full alc-supp-lic-attr
&glob table_alc-supp-lic-attr-full '{&bef-table_alc-supp-lic-attr-full}':U
&glob bef-table_alc-supp-lic-type-full Связь лицензий с типами алкоголя
&glob table_alc-supp-lic-type-full '{&bef-table_alc-supp-lic-type-full}':U
&glob bef-table_alc-supp-lic-type-attr-full Атрибуты для alc-supp-lic-type
&glob table_alc-supp-lic-type-attr-full '{&bef-table_alc-supp-lic-type-attr-full}':U
&glob bef-table_alc-type-full Виды алкогольной продукции
&glob table_alc-type-full '{&bef-table_alc-type-full}':U
&glob bef-table_alc-type-attr-full Атрибуты видов алкоголя
&glob table_alc-type-attr-full '{&bef-table_alc-type-attr-full}':U
&glob bef-table_alc-type-gds-full Связь товара с видом алкоголя
&glob table_alc-type-gds-full '{&bef-table_alc-type-gds-full}':U
&glob bef-table_alc-type-gds-attr-full Атрибуты для alc-type-gds
&glob table_alc-type-gds-attr-full '{&bef-table_alc-type-gds-attr-full}':U
&glob bef-table_archive-history-full archive-history
&glob table_archive-history-full '{&bef-table_archive-history-full}':U
&glob bef-table_archive-history-attr-full Атрибуты для archive-history
&glob table_archive-history-attr-full '{&bef-table_archive-history-attr-full}':U
&glob bef-table_arh-fin-doc-an-full Архив по счету по кодам
&glob table_arh-fin-doc-an-full '{&bef-table_arh-fin-doc-an-full}':U
&glob bef-table_arh-fin-doc-an-attr-full Атрибуты для arh-fin-doc-an
&glob table_arh-fin-doc-an-attr-full '{&bef-table_arh-fin-doc-an-attr-full}':U
&glob bef-table_arh-fin-doc-an-nal-full Архив по налсчету по кодам
&glob table_arh-fin-doc-an-nal-full '{&bef-table_arh-fin-doc-an-nal-full}':U
&glob bef-table_arh-fin-doc-an-nal-attr-full Атрибуты для arh-fin-doc-an-nal
&glob table_arh-fin-doc-an-nal-attr-full '{&bef-table_arh-fin-doc-an-nal-attr-full}':U
&glob bef-table_arh-fin-doc-an-nal-obj-full Архив по налсчету по кодам по объектам
&glob table_arh-fin-doc-an-nal-obj-full '{&bef-table_arh-fin-doc-an-nal-obj-full}':U
&glob bef-table_arh-fin-doc-an-nal-obj-attr-full Атрибуты для arh-fin-doc-an-nal-obj
&glob table_arh-fin-doc-an-nal-obj-attr-full '{&bef-table_arh-fin-doc-an-nal-obj-attr-full}':U
&glob bef-table_arh-fin-doc-an-obj-full Архив по счету по кодам по объекту
&glob table_arh-fin-doc-an-obj-full '{&bef-table_arh-fin-doc-an-obj-full}':U
&glob bef-table_arh-fin-doc-an-obj-attr-full Атрибуты для arh-fin-doc-an-obj
&glob table_arh-fin-doc-an-obj-attr-full '{&bef-table_arh-fin-doc-an-obj-attr-full}':U
&glob bef-table_arh-fin-doc-c-s-tax-nal-obj-full Архив по нал.плат.догов.налоги по объектам
&glob table_arh-fin-doc-c-s-tax-nal-obj-full '{&bef-table_arh-fin-doc-c-s-tax-nal-obj-full}':U
&glob bef-table_arh-fin-doc-c-schet-tax-nal-full Архив по нал.плат.догов.налоги
&glob table_arh-fin-doc-c-schet-tax-nal-full '{&bef-table_arh-fin-doc-c-schet-tax-nal-full}':U
&glob bef-table_arh-fin-doc-contr-s-nal-obj-full Архивы по плат. налсч. по дог.
&glob table_arh-fin-doc-contr-s-nal-obj-full '{&bef-table_arh-fin-doc-contr-s-nal-obj-full}':U
&glob bef-table_arh-fin-doc-contr-s-tax-obj-full Архив по платеж. догов.налоги
&glob table_arh-fin-doc-contr-s-tax-obj-full '{&bef-table_arh-fin-doc-contr-s-tax-obj-full}':U
&glob bef-table_arh-fin-doc-contr-schet-full Архивы по плат. счета по дог.
&glob table_arh-fin-doc-contr-schet-full '{&bef-table_arh-fin-doc-contr-schet-full}':U
&glob bef-table_arh-fin-doc-contr-schet-attr-full Атрибуты для arh-fin-doc-contr-schet
&glob table_arh-fin-doc-contr-schet-attr-full '{&bef-table_arh-fin-doc-contr-schet-attr-full}':U
&glob bef-table_arh-fin-doc-contr-schet-nal-full Архивы по плат. налсч. по дог.
&glob table_arh-fin-doc-contr-schet-nal-full '{&bef-table_arh-fin-doc-contr-schet-nal-full}':U
&glob bef-table_arh-fin-doc-contr-schet-obj-full Архивы по плат. счета по дог. по объекту
&glob table_arh-fin-doc-contr-schet-obj-full '{&bef-table_arh-fin-doc-contr-schet-obj-full}':U
&glob bef-table_arh-fin-doc-contr-schet-tax-full Архив по платеж. догов.налоги
&glob table_arh-fin-doc-contr-schet-tax-full '{&bef-table_arh-fin-doc-contr-schet-tax-full}':U
&glob bef-table_arh-fin-doc-s-tax-nal-obj-full Архив по платеж. налсчета нало
&glob table_arh-fin-doc-s-tax-nal-obj-full '{&bef-table_arh-fin-doc-s-tax-nal-obj-full}':U
&glob bef-table_arh-fin-doc-schet-full Архив по платежам по счету
&glob table_arh-fin-doc-schet-full '{&bef-table_arh-fin-doc-schet-full}':U
&glob bef-table_arh-fin-doc-schet-attr-full Атрибуты для arh-fin-doc-schet
&glob table_arh-fin-doc-schet-attr-full '{&bef-table_arh-fin-doc-schet-attr-full}':U
&glob bef-table_arh-fin-doc-schet-nal-full Архив по платежам по налсчету
&glob table_arh-fin-doc-schet-nal-full '{&bef-table_arh-fin-doc-schet-nal-full}':U
&glob bef-table_arh-fin-doc-schet-nal-attr-full Атрибуты для arh-fin-doc-schet-nal
&glob table_arh-fin-doc-schet-nal-attr-full '{&bef-table_arh-fin-doc-schet-nal-attr-full}':U
&glob bef-table_arh-fin-doc-schet-nal-obj-full Архив по платежам по налсчету
&glob table_arh-fin-doc-schet-nal-obj-full '{&bef-table_arh-fin-doc-schet-nal-obj-full}':U
&glob bef-table_arh-fin-doc-schet-obj-full Архив по платежам по счету по объекту
&glob table_arh-fin-doc-schet-obj-full '{&bef-table_arh-fin-doc-schet-obj-full}':U
&glob bef-table_arh-fin-doc-schet-obj-attr-full Атрибуты для arh-fin-doc-schet-obj
&glob table_arh-fin-doc-schet-obj-attr-full '{&bef-table_arh-fin-doc-schet-obj-attr-full}':U
&glob bef-table_arh-fin-doc-schet-tax-full Архив по платеж. счета налоги
&glob table_arh-fin-doc-schet-tax-full '{&bef-table_arh-fin-doc-schet-tax-full}':U
&glob bef-table_arh-fin-doc-schet-tax-attr-full Атрибуты для arh-fin-doc-schet-tax
&glob table_arh-fin-doc-schet-tax-attr-full '{&bef-table_arh-fin-doc-schet-tax-attr-full}':U
&glob bef-table_arh-fin-doc-schet-tax-nal-full Архив по платеж. налсчета нало
&glob table_arh-fin-doc-schet-tax-nal-full '{&bef-table_arh-fin-doc-schet-tax-nal-full}':U
&glob bef-table_arh-fin-doc-schet-tax-obj-full Архив по платеж. счета налоги по объектам
&glob table_arh-fin-doc-schet-tax-obj-full '{&bef-table_arh-fin-doc-schet-tax-obj-full}':U
&glob bef-table_arh-fin-ob-contr-full Архив фин.обяз по договору
&glob table_arh-fin-ob-contr-full '{&bef-table_arh-fin-ob-contr-full}':U
&glob bef-table_arh-fin-ob-contr-attr-full Атрибуты для arh-fin-ob-contr
&glob table_arh-fin-ob-contr-attr-full '{&bef-table_arh-fin-ob-contr-attr-full}':U
&glob bef-table_arh-fin-ob-contr-obj-full Архив фин.обяз по договору по объекту
&glob table_arh-fin-ob-contr-obj-full '{&bef-table_arh-fin-ob-contr-obj-full}':U
&glob bef-table_arh-fin-ob-contr-obj-attr-full Атрибуты для arh-fin-ob-contr-obj
&glob table_arh-fin-ob-contr-obj-attr-full '{&bef-table_arh-fin-ob-contr-obj-attr-full}':U
&glob bef-table_arh-trn-doc-contract-full Архив скл. док. по контрактам
&glob table_arh-trn-doc-contract-full '{&bef-table_arh-trn-doc-contract-full}':U
&glob bef-table_arh-trn-doc-contract-attr-full Атрибуты для arh-trn-doc-contract
&glob table_arh-trn-doc-contract-attr-full '{&bef-table_arh-trn-doc-contract-attr-full}':U
&glob bef-table_arh-wth-cli-full Архив покупатель-номинал МЦ
&glob table_arh-wth-cli-full '{&bef-table_arh-wth-cli-full}':U
&glob bef-table_arh-wth-cli-attr-full Атрибуты для arh-wth-cli
&glob table_arh-wth-cli-attr-full '{&bef-table_arh-wth-cli-attr-full}':U
&glob bef-table_arh-wth-cli-doc-full arh-wth-cli-doc
&glob table_arh-wth-cli-doc-full '{&bef-table_arh-wth-cli-doc-full}':U
&glob bef-table_arh-wth-cli-doc-attr-full Атрибуты для arh-wth-cli-doc
&glob table_arh-wth-cli-doc-attr-full '{&bef-table_arh-wth-cli-doc-attr-full}':U
&glob bef-table_arh-wth-cli-tot-full Итоговый баланс по покупателю
&glob table_arh-wth-cli-tot-full '{&bef-table_arh-wth-cli-tot-full}':U
&glob bef-table_arh-wth-cli-tot-attr-full Атрибуты для arh-wth-cli-tot
&glob table_arh-wth-cli-tot-attr-full '{&bef-table_arh-wth-cli-tot-attr-full}':U
&glob bef-table_arh-wth-tot-full arh-wth-tot
&glob table_arh-wth-tot-full '{&bef-table_arh-wth-tot-full}':U
&glob bef-table_arh-wth-tot-attr-full Атрибуты для arh-wth-tot
&glob table_arh-wth-tot-attr-full '{&bef-table_arh-wth-tot-attr-full}':U
&glob bef-table_arh-wth-w-p-full arh-wth-w-p
&glob table_arh-wth-w-p-full '{&bef-table_arh-wth-w-p-full}':U
&glob bef-table_arh-wth-w-p-attr-full Атрибуты для arh-wth-w-p
&glob table_arh-wth-w-p-attr-full '{&bef-table_arh-wth-w-p-attr-full}':U
&glob bef-table_assortment-matrix-full Ассортиментная матрица
&glob table_assortment-matrix-full '{&bef-table_assortment-matrix-full}':U
&glob bef-table_assortment-matrix-attr-full Атрибуты для assortment-matrix
&glob table_assortment-matrix-attr-full '{&bef-table_assortment-matrix-attr-full}':U
&glob bef-table_assortment-matrix-goods-full Содержимое ассортиментных матр
&glob table_assortment-matrix-goods-full '{&bef-table_assortment-matrix-goods-full}':U
&glob bef-table_assortment-matrix-goods-attr-full Атрибуты для assortment-matrix-goods
&glob table_assortment-matrix-goods-attr-full '{&bef-table_assortment-matrix-goods-attr-full}':U
&glob bef-table_attr-prop-full Свойства атрибутов
&glob table_attr-prop-full '{&bef-table_attr-prop-full}':U
&glob bef-table_auto-section-full Секция автотранспорта
&glob table_auto-section-full '{&bef-table_auto-section-full}':U
&glob bef-table_auto-section-attr-full Атрибуты для auto-section
&glob table_auto-section-attr-full '{&bef-table_auto-section-attr-full}':U
&glob bef-table_auto-section-table-full auto-section-table
&glob table_auto-section-table-full '{&bef-table_auto-section-table-full}':U
&glob bef-table_auto-tank-full Автотранспорт
&glob table_auto-tank-full '{&bef-table_auto-tank-full}':U
&glob bef-table_auto-tank-attr-full Атрибуты для auto-tank
&glob table_auto-tank-attr-full '{&bef-table_auto-tank-attr-full}':U
&glob bef-table_auto-tank-meas-full auto-tank-meas
&glob table_auto-tank-meas-full '{&bef-table_auto-tank-meas-full}':U
&glob bef-table_auto-tank-meas-attr-full Атрибуты для auto-tank-meas
&glob table_auto-tank-meas-attr-full '{&bef-table_auto-tank-meas-attr-full}':U
&glob bef-table_bar-code-full Бар-код
&glob table_bar-code-full '{&bef-table_bar-code-full}':U
&glob bef-table_bar-code-attr-full Атрибуты бар-кодов
&glob table_bar-code-attr-full '{&bef-table_bar-code-attr-full}':U
&glob bef-table_bar-code-obj-attr-full Атрибуты бар-кода на объекте
&glob table_bar-code-obj-attr-full '{&bef-table_bar-code-obj-attr-full}':U
&glob bef-table_BatchProcess-full Batch Process
&glob table_BatchProcess-full '{&bef-table_BatchProcess-full}':U
&glob bef-table_blob-bind-full Связка blob с владельцем
&glob table_blob-bind-full '{&bef-table_blob-bind-full}':U
&glob bef-table_blob-data-full Данные BLOB
&glob table_blob-data-full '{&bef-table_blob-data-full}':U
&glob bef-table_buyer-group-full Группа покупателей
&glob table_buyer-group-full '{&bef-table_buyer-group-full}':U
&glob bef-table_buyer-group-attr-full Атрибуты для buyer-group
&glob table_buyer-group-attr-full '{&bef-table_buyer-group-attr-full}':U
&glob bef-table_buyer-in-buyer-group-full Покупатель в группе покуп.
&glob table_buyer-in-buyer-group-full '{&bef-table_buyer-in-buyer-group-full}':U
&glob bef-table_buyer-in-buyer-group-attr-full Атрибуты для buyer-in-buyer-group
&glob table_buyer-in-buyer-group-attr-full '{&bef-table_buyer-in-buyer-group-attr-full}':U
&glob bef-table_c-action-role-full c-action-role
&glob table_c-action-role-full '{&bef-table_c-action-role-full}':U
&glob bef-table_c-action-role-item-full c-action-role-item
&glob table_c-action-role-item-full '{&bef-table_c-action-role-item-full}':U
&glob bef-table_c-add-doc-full История документа доп.расходы
&glob table_c-add-doc-full '{&bef-table_c-add-doc-full}':U
&glob bef-table_c-add-line-full История строк доп.расхода
&glob table_c-add-line-full '{&bef-table_c-add-line-full}':U
&glob bef-table_c-alc-sale-lic-full История лицензий на продажу
&glob table_c-alc-sale-lic-full '{&bef-table_c-alc-sale-lic-full}':U
&glob bef-table_c-alc-sale-lic-attr-full c-alc-sale-lic-attr
&glob table_c-alc-sale-lic-attr-full '{&bef-table_c-alc-sale-lic-attr-full}':U
&glob bef-table_c-alc-sale-lic-type-full история связи лицензий с товар
&glob table_c-alc-sale-lic-type-full '{&bef-table_c-alc-sale-lic-type-full}':U
&glob bef-table_c-alc-supp-lic-full История лицензий поставщиков
&glob table_c-alc-supp-lic-full '{&bef-table_c-alc-supp-lic-full}':U
&glob bef-table_c-alc-supp-lic-attr-full c-alc-supp-lic-attr
&glob table_c-alc-supp-lic-attr-full '{&bef-table_c-alc-supp-lic-attr-full}':U
&glob bef-table_c-alc-supp-lic-type-full история связи лицензий с типом
&glob table_c-alc-supp-lic-type-full '{&bef-table_c-alc-supp-lic-type-full}':U
&glob bef-table_c-alc-type-full история типов алкоголя
&glob table_c-alc-type-full '{&bef-table_c-alc-type-full}':U
&glob bef-table_c-alc-type-attr-full c-alc-type-attr
&glob table_c-alc-type-attr-full '{&bef-table_c-alc-type-attr-full}':U
&glob bef-table_c-alc-type-gds-full История связи товара с алк. кл
&glob table_c-alc-type-gds-full '{&bef-table_c-alc-type-gds-full}':U
&glob bef-table_c-assortment-matrix-full c-assortment-matrix
&glob table_c-assortment-matrix-full '{&bef-table_c-assortment-matrix-full}':U
&glob bef-table_c-assortment-matrix-goods-full c-assortment-matrix-goods
&glob table_c-assortment-matrix-goods-full '{&bef-table_c-assortment-matrix-goods-full}':U
&glob bef-table_c-auto-section-full Секция автотранспорта
&glob table_c-auto-section-full '{&bef-table_c-auto-section-full}':U
&glob bef-table_c-auto-section-attr-full Атрибуты для auto-section
&glob table_c-auto-section-attr-full '{&bef-table_c-auto-section-attr-full}':U
&glob bef-table_c-auto-section-table-full c-auto-section-table
&glob table_c-auto-section-table-full '{&bef-table_c-auto-section-table-full}':U
&glob bef-table_c-auto-tank-full c-auto-tank
&glob table_c-auto-tank-full '{&bef-table_c-auto-tank-full}':U
&glob bef-table_c-auto-tank-attr-full Иcтория для auto-tank-attr
&glob table_c-auto-tank-attr-full '{&bef-table_c-auto-tank-attr-full}':U
&glob bef-table_c-auto-tank-meas-attr-full Иcтория для auto-tank-meas-attr
&glob table_c-auto-tank-meas-attr-full '{&bef-table_c-auto-tank-meas-attr-full}':U
&glob bef-table_c-bar-code-full c-bar-code
&glob table_c-bar-code-full '{&bef-table_c-bar-code-full}':U
&glob bef-table_c-bar-code-attr-full История атрибутов бар-кодов
&glob table_c-bar-code-attr-full '{&bef-table_c-bar-code-attr-full}':U
&glob bef-table_c-bar-code-obj-attr-full История атрибутов бар-кода на о
&glob table_c-bar-code-obj-attr-full '{&bef-table_c-bar-code-obj-attr-full}':U
&glob bef-table_c-buyer-group-full История группа покупателей
&glob table_c-buyer-group-full '{&bef-table_c-buyer-group-full}':U
&glob bef-table_c-buyer-in-buyer-group-full История покупателя в группе покуп.
&glob table_c-buyer-in-buyer-group-full '{&bef-table_c-buyer-in-buyer-group-full}':U
&glob bef-table_c-cash-desk-full История изменений касс
&glob table_c-cash-desk-full '{&bef-table_c-cash-desk-full}':U
&glob bef-table_c-cash-desk-attr-full Атрибуты кассы
&glob table_c-cash-desk-attr-full '{&bef-table_c-cash-desk-attr-full}':U
&glob bef-table_c-cash-pay-full c-cash-pay
&glob table_c-cash-pay-full '{&bef-table_c-cash-pay-full}':U
&glob bef-table_c-cash-pay-attr-full Атрибуты типа касс. платежа
&glob table_c-cash-pay-attr-full '{&bef-table_c-cash-pay-attr-full}':U
&glob bef-table_c-CashBook-full Кассовые книги
&glob table_c-CashBook-full '{&bef-table_c-CashBook-full}':U
&glob bef-table_c-cashbook-head-full c-cashbook-head
&glob table_c-cashbook-head-full '{&bef-table_c-cashbook-head-full}':U
&glob bef-table_c-CashBookAttr-full атрибуты кассовой книги
&glob table_c-CashBookAttr-full '{&bef-table_c-CashBookAttr-full}':U
&glob bef-table_c-CashBookRule-full c-CashBookRule
&glob table_c-CashBookRule-full '{&bef-table_c-CashBookRule-full}':U
&glob bef-table_c-CashBookRuleAttr-full атрибуты кассовой книги
&glob table_c-CashBookRuleAttr-full '{&bef-table_c-CashBookRuleAttr-full}':U
&glob bef-table_c-cbr-bank-full Банки из списков ЦБ РФ
&glob table_c-cbr-bank-full '{&bef-table_c-cbr-bank-full}':U
&glob bef-table_c-cbr-bank-attr-full Иcтория для cbr-bank-attr
&glob table_c-cbr-bank-attr-full '{&bef-table_c-cbr-bank-attr-full}':U
&glob bef-table_c-cd-clu-full Клиенты на кассе
&glob table_c-cd-clu-full '{&bef-table_c-cd-clu-full}':U
&glob bef-table_c-cd-dlu-full История ДК на кассе
&glob table_c-cd-dlu-full '{&bef-table_c-cd-dlu-full}':U
&glob bef-table_c-cd-doc-full история док-тов на кассе
&glob table_c-cd-doc-full '{&bef-table_c-cd-doc-full}':U
&glob bef-table_c-cd-doc-line-full История строчек док-тов на кас
&glob table_c-cd-doc-line-full '{&bef-table_c-cd-doc-line-full}':U
&glob bef-table_c-cd-grp-full Группы на кассах
&glob table_c-cd-grp-full '{&bef-table_c-cd-grp-full}':U
&glob bef-table_c-cd-plu-full История товаров на кассе
&glob table_c-cd-plu-full '{&bef-table_c-cd-plu-full}':U
&glob bef-table_c-chk-discnt-full Скидки чека
&glob table_c-chk-discnt-full '{&bef-table_c-chk-discnt-full}':U
&glob bef-table_c-chk-doc-full c-chk-doc
&glob table_c-chk-doc-full '{&bef-table_c-chk-doc-full}':U
&glob bef-table_c-chk-doc-attr-full Атрибуты чека отвязанного от удаленной продажи
&glob table_c-chk-doc-attr-full '{&bef-table_c-chk-doc-attr-full}':U
&glob bef-table_c-chk-gds-full c-chk-gds
&glob table_c-chk-gds-full '{&bef-table_c-chk-gds-full}':U
&glob bef-table_c-chk-pay-full c-chk-pay
&glob table_c-chk-pay-full '{&bef-table_c-chk-pay-full}':U
&glob bef-table_c-cli-grp-full История групп клиеентов
&glob table_c-cli-grp-full '{&bef-table_c-cli-grp-full}':U
&glob bef-table_c-cli-grp-attr-full Иcтория для cli-grp-attr
&glob table_c-cli-grp-attr-full '{&bef-table_c-cli-grp-attr-full}':U
&glob bef-table_c-cli-hist-full c-cli-hist
&glob table_c-cli-hist-full '{&bef-table_c-cli-hist-full}':U
&glob bef-table_c-clients-full c-clients
&glob table_c-clients-full '{&bef-table_c-clients-full}':U
&glob bef-table_c-clients-attr-full Атрибуты товара на объекте
&glob table_c-clients-attr-full '{&bef-table_c-clients-attr-full}':U
&glob bef-table_c-Code-full Справочники
&glob table_c-Code-full '{&bef-table_c-Code-full}':U
&glob bef-table_c-condition-keeping-full История условий хранения
&glob table_c-condition-keeping-full '{&bef-table_c-condition-keeping-full}':U
&glob bef-table_c-condition-keeping-attr-full Иcтория для condition-keeping-attr
&glob table_c-condition-keeping-attr-full '{&bef-table_c-condition-keeping-attr-full}':U
&glob bef-table_c-config-full c-config
&glob table_c-config-full '{&bef-table_c-config-full}':U
&glob bef-table_c-contract-full c-contract
&glob table_c-contract-full '{&bef-table_c-contract-full}':U
&glob bef-table_c-contract-line-full c-contract-line
&glob table_c-contract-line-full '{&bef-table_c-contract-line-full}':U
&glob bef-table_c-contract-specif-full c-contract-specif
&glob table_c-contract-specif-full '{&bef-table_c-contract-specif-full}':U
&glob bef-table_c-contract-specif-attr-full Атрибуты для contract-specif
&glob table_c-contract-specif-attr-full '{&bef-table_c-contract-specif-attr-full}':U
&glob bef-table_c-counter-full c-counter
&glob table_c-counter-full '{&bef-table_c-counter-full}':U
&glob bef-table_c-country-full история стран
&glob table_c-country-full '{&bef-table_c-country-full}':U
&glob bef-table_c-country-attr-full Иcтория для country-attr
&glob table_c-country-attr-full '{&bef-table_c-country-attr-full}':U
&glob bef-table_c-curr-accnt-full c-curr-accnt
&glob table_c-curr-accnt-full '{&bef-table_c-curr-accnt-full}':U
&glob bef-table_c-curr-bank-full c-curr-bank
&glob table_c-curr-bank-full '{&bef-table_c-curr-bank-full}':U
&glob bef-table_c-currency-full c-currency
&glob table_c-currency-full '{&bef-table_c-currency-full}':U
&glob bef-table_c-currency-attr-full Иcтория для currency-attr
&glob table_c-currency-attr-full '{&bef-table_c-currency-attr-full}':U
&glob bef-table_c-db-full История изменения БД
&glob table_c-db-full '{&bef-table_c-db-full}':U
&glob bef-table_c-db-grp-obj-price-full История БД в группе объектов ценообр
&glob table_c-db-grp-obj-price-full '{&bef-table_c-db-grp-obj-price-full}':U
&glob bef-table_c-dc-hist-full c-dc-hist
&glob table_c-dc-hist-full '{&bef-table_c-dc-hist-full}':U
&glob bef-table_c-deliv-type-cond-keep-full История типов доставки по условиям хран
&glob table_c-deliv-type-cond-keep-full '{&bef-table_c-deliv-type-cond-keep-full}':U
&glob bef-table_c-deliv-type-cond-keep-attr-full Иcтория для deliv-type-cond-keep-attr
&glob table_c-deliv-type-cond-keep-attr-full '{&bef-table_c-deliv-type-cond-keep-attr-full}':U
&glob bef-table_c-delivery-subject-full История субъектов доставки
&glob table_c-delivery-subject-full '{&bef-table_c-delivery-subject-full}':U
&glob bef-table_c-delivery-subject-attr-full Иcтория для delivery-subject-attr
&glob table_c-delivery-subject-attr-full '{&bef-table_c-delivery-subject-attr-full}':U
&glob bef-table_c-delivery-type-full История типов доставки
&glob table_c-delivery-type-full '{&bef-table_c-delivery-type-full}':U
&glob bef-table_c-delivery-type-attr-full Иcтория для delivery-type-attr
&glob table_c-delivery-type-attr-full '{&bef-table_c-delivery-type-attr-full}':U
&glob bef-table_c-delivery-type-subject-full История типов доставки от субъектов
&glob table_c-delivery-type-subject-full '{&bef-table_c-delivery-type-subject-full}':U
&glob bef-table_c-delivery-type-subject-attr-full Иcтория для delivery-type-subject-attr
&glob table_c-delivery-type-subject-attr-full '{&bef-table_c-delivery-type-subject-attr-full}':U
&glob bef-table_c-dis-card-full c-dis-card
&glob table_c-dis-card-full '{&bef-table_c-dis-card-full}':U
&glob bef-table_c-dis-card-long-full ИСТОРИЯ -Реальных номеров карт
&glob table_c-dis-card-long-full '{&bef-table_c-dis-card-long-full}':U
&glob bef-table_c-dis-card-long-attr-full Иcтория для dis-card-long-attr
&glob table_c-dis-card-long-attr-full '{&bef-table_c-dis-card-long-attr-full}':U
&glob bef-table_c-dis-card-mask-full c-dis-card-mask
&glob table_c-dis-card-mask-full '{&bef-table_c-dis-card-mask-full}':U
&glob bef-table_c-dis-card-mask-attr-full Иcтория для dis-card-mask-attr
&glob table_c-dis-card-mask-attr-full '{&bef-table_c-dis-card-mask-attr-full}':U
&glob bef-table_c-dis-card-property-full История свойств ДК
&glob table_c-dis-card-property-full '{&bef-table_c-dis-card-property-full}':U
&glob bef-table_c-dis-card-type-full c-dis-card-type
&glob table_c-dis-card-type-full '{&bef-table_c-dis-card-type-full}':U
&glob bef-table_c-dis-card-type-attr-full История атрибутов типа дисконтных карт
&glob table_c-dis-card-type-attr-full '{&bef-table_c-dis-card-type-attr-full}':U
&glob bef-table_c-dis-cfg-rule-full История связки скидок
&glob table_c-dis-cfg-rule-full '{&bef-table_c-dis-cfg-rule-full}':U
&glob bef-table_c-dis-cp-rule-full История скидокт на платеж
&glob table_c-dis-cp-rule-full '{&bef-table_c-dis-cp-rule-full}':U
&glob bef-table_c-dis-dc-rule-full Историс скидок по отд. ДК
&glob table_c-dis-dc-rule-full '{&bef-table_c-dis-dc-rule-full}':U
&glob bef-table_c-dis-dct-rule-full История скидок на ТИП ДК
&glob table_c-dis-dct-rule-full '{&bef-table_c-dis-dct-rule-full}':U
&glob bef-table_c-dis-gds-rule-full История правил скидок на товар
&glob table_c-dis-gds-rule-full '{&bef-table_c-dis-gds-rule-full}':U
&glob bef-table_c-dis-grp-rule-full История правил скидок по гр
&glob table_c-dis-grp-rule-full '{&bef-table_c-dis-grp-rule-full}':U
&glob bef-table_c-dis-host-full c-dis-host
&glob table_c-dis-host-full '{&bef-table_c-dis-host-full}':U
&glob bef-table_c-dis-obj-full c-dis-obj
&glob table_c-dis-obj-full '{&bef-table_c-dis-obj-full}':U
&glob bef-table_c-dis-rule-full правила скидок
&glob table_c-dis-rule-full '{&bef-table_c-dis-rule-full}':U
&glob bef-table_c-dis-rule-attr-full Иcтория для dis-rule-attr
&glob table_c-dis-rule-attr-full '{&bef-table_c-dis-rule-attr-full}':U
&glob bef-table_c-dis-some-rule-full Истори привязок правил скид
&glob table_c-dis-some-rule-full '{&bef-table_c-dis-some-rule-full}':U
&glob bef-table_c-dis-thbj-rule-full История нетоварных ск. по объ/
&glob table_c-dis-thbj-rule-full '{&bef-table_c-dis-thbj-rule-full}':U
&glob bef-table_c-dis-time-rule-full расписания
&glob table_c-dis-time-rule-full '{&bef-table_c-dis-time-rule-full}':U
&glob bef-table_c-doc-attr-full c-doc-attr
&glob table_c-doc-attr-full '{&bef-table_c-doc-attr-full}':U
&glob bef-table_c-doc-fbr-gds-full c-doc-fbr-gds
&glob table_c-doc-fbr-gds-full '{&bef-table_c-doc-fbr-gds-full}':U
&glob bef-table_c-doc-line-full Удаленные строки документа
&glob table_c-doc-line-full '{&bef-table_c-doc-line-full}':U
&glob bef-table_c-doc-line-attr-full Атрибуты удаленных линий
&glob table_c-doc-line-attr-full '{&bef-table_c-doc-line-attr-full}':U
&glob bef-table_c-doc-line-sum-full c-doc-line-sum
&glob table_c-doc-line-sum-full '{&bef-table_c-doc-line-sum-full}':U
&glob bef-table_c-doc-pl-full Удаленные строки товара по скл
&glob table_c-doc-pl-full '{&bef-table_c-doc-pl-full}':U
&glob bef-table_c-doc-pl-pump-full c-doc-pl-pump
&glob table_c-doc-pl-pump-full '{&bef-table_c-doc-pl-pump-full}':U
&glob bef-table_c-doc-prts-full c-doc-prts
&glob table_c-doc-prts-full '{&bef-table_c-doc-prts-full}':U
&glob bef-table_c-drt-prop-full История св-в ш-нов правил скид
&glob table_c-drt-prop-full '{&bef-table_c-drt-prop-full}':U
&glob bef-table_c-egais-clients-full c-egais-clients
&glob table_c-egais-clients-full '{&bef-table_c-egais-clients-full}':U
&glob bef-table_c-egais-gds-full c-egais-gds
&glob table_c-egais-gds-full '{&bef-table_c-egais-gds-full}':U
&glob bef-table_c-esys-datatype-exp-full Истори типов данных дл импор
&glob table_c-esys-datatype-exp-full '{&bef-table_c-esys-datatype-exp-full}':U
&glob bef-table_c-esys-datatype-imp-full Истори типов данных дл импор
&glob table_c-esys-datatype-imp-full '{&bef-table_c-esys-datatype-imp-full}':U
&glob bef-table_c-ex-mark-full История акцизных и спец марок
&glob table_c-ex-mark-full '{&bef-table_c-ex-mark-full}':U
&glob bef-table_c-ext-artic-full История внешних артикулов
&glob table_c-ext-artic-full '{&bef-table_c-ext-artic-full}':U
&glob bef-table_c-ext-artic-attr-full История атрибутов внешних арти
&glob table_c-ext-artic-attr-full '{&bef-table_c-ext-artic-attr-full}':U
&glob bef-table_c-ext-classif-full История внешнего классификатор
&glob table_c-ext-classif-full '{&bef-table_c-ext-classif-full}':U
&glob bef-table_c-ext-system-full c-ext-system
&glob table_c-ext-system-full '{&bef-table_c-ext-system-full}':U
&glob bef-table_c-fbr-doc-full c-fbr-doc
&glob table_c-fbr-doc-full '{&bef-table_c-fbr-doc-full}':U
&glob bef-table_c-fbr-gds-grp-full история групп блюд
&glob table_c-fbr-gds-grp-full '{&bef-table_c-fbr-gds-grp-full}':U
&glob bef-table_c-fbr-gds-grp-attr-full история атрибутов групп блюд
&glob table_c-fbr-gds-grp-attr-full '{&bef-table_c-fbr-gds-grp-attr-full}':U
&glob bef-table_c-fbr-gds-grp-hist-full шапка истории групп блюд
&glob table_c-fbr-gds-grp-hist-full '{&bef-table_c-fbr-gds-grp-hist-full}':U
&glob bef-table_c-fbr-gds-obj-full c-fbr-gds-obj
&glob table_c-fbr-gds-obj-full '{&bef-table_c-fbr-gds-obj-full}':U
&glob bef-table_c-fbr-gds-obj-attr-full Иcтория для fbr-gds-obj-attr
&glob table_c-fbr-gds-obj-attr-full '{&bef-table_c-fbr-gds-obj-attr-full}':U
&glob bef-table_c-fbr-line-full Удаленные линии док. производс
&glob table_c-fbr-line-full '{&bef-table_c-fbr-line-full}':U
&glob bef-table_c-fbr-pln-full Документы план-меню
&glob table_c-fbr-pln-full '{&bef-table_c-fbr-pln-full}':U
&glob bef-table_c-fbr-pln-line-full Строки план-меню
&glob table_c-fbr-pln-line-full '{&bef-table_c-fbr-pln-line-full}':U
&glob bef-table_c-fbr-prn-full история принтеров кухни
&glob table_c-fbr-prn-full '{&bef-table_c-fbr-prn-full}':U
&glob bef-table_c-fbr-prn-gds-full история товара на принетре кух
&glob table_c-fbr-prn-gds-full '{&bef-table_c-fbr-prn-gds-full}':U
&glob bef-table_c-fbr-prn-grp-full история групп для принтере кух
&glob table_c-fbr-prn-grp-full '{&bef-table_c-fbr-prn-grp-full}':U
&glob bef-table_c-fin-bank-full Реквизиты банка - история
&glob table_c-fin-bank-full '{&bef-table_c-fin-bank-full}':U
&glob bef-table_c-fin-bank-attr-full Иcтория для fin-bank-attr
&glob table_c-fin-bank-attr-full '{&bef-table_c-fin-bank-attr-full}':U
&glob bef-table_c-fin-code-an-uchet-full c-fin-code-an-uchet
&glob table_c-fin-code-an-uchet-full '{&bef-table_c-fin-code-an-uchet-full}':U
&glob bef-table_c-fin-code-cel-nazn-full c-fin-code-cel-nazn
&glob table_c-fin-code-cel-nazn-full '{&bef-table_c-fin-code-cel-nazn-full}':U
&glob bef-table_c-fin-code-cor-acc-full c-fin-code-cor-acc
&glob table_c-fin-code-cor-acc-full '{&bef-table_c-fin-code-cor-acc-full}':U
&glob bef-table_c-fin-connect-full История связей
&glob table_c-fin-connect-full '{&bef-table_c-fin-connect-full}':U
&glob bef-table_c-fin-doc-full Финансовые документы - история
&glob table_c-fin-doc-full '{&bef-table_c-fin-doc-full}':U
&glob bef-table_c-fin-doc-attr-full Доп. атрибуты фин. документа -
&glob table_c-fin-doc-attr-full '{&bef-table_c-fin-doc-attr-full}':U
&glob bef-table_c-fin-doc-tax-full Скор. налоги по платежам
&glob table_c-fin-doc-tax-full '{&bef-table_c-fin-doc-tax-full}':U
&glob bef-table_c-fin-gds-part-full товарный отчет в фин. блоке -
&glob table_c-fin-gds-part-full '{&bef-table_c-fin-gds-part-full}':U
&glob bef-table_c-fin-ob-full Финансовые обязательства - ист
&glob table_c-fin-ob-full '{&bef-table_c-fin-ob-full}':U
&glob bef-table_c-fin-ob-attr-full c-fin-ob-attr
&glob table_c-fin-ob-attr-full '{&bef-table_c-fin-ob-attr-full}':U
&glob bef-table_c-fin-ob-tax-full Скор. налоги по фин. обяз.
&glob table_c-fin-ob-tax-full '{&bef-table_c-fin-ob-tax-full}':U
&glob bef-table_c-fin-schet-full Фин. реквизиты история
&glob table_c-fin-schet-full '{&bef-table_c-fin-schet-full}':U
&glob bef-table_c-fin-schet-attr-full Иcтория для fin-schet-attr
&glob table_c-fin-schet-attr-full '{&bef-table_c-fin-schet-attr-full}':U
&glob bef-table_c-fin-statement-full История выписок
&glob table_c-fin-statement-full '{&bef-table_c-fin-statement-full}':U
&glob bef-table_c-fin-statement-attr-full история атрибутов выписки
&glob table_c-fin-statement-attr-full '{&bef-table_c-fin-statement-attr-full}':U
&glob bef-table_c-fin-statement-line-full история строк выписки
&glob table_c-fin-statement-line-full '{&bef-table_c-fin-statement-line-full}':U
&glob bef-table_c-firm-full c-firm
&glob table_c-firm-full '{&bef-table_c-firm-full}':U
&glob bef-table_c-gds-add-charges-full История видов доп.расходов
&glob table_c-gds-add-charges-full '{&bef-table_c-gds-add-charges-full}':U
&glob bef-table_c-gds-add-charges-attr-full История атрибутов доп.расходов
&glob table_c-gds-add-charges-attr-full '{&bef-table_c-gds-add-charges-attr-full}':U
&glob bef-table_c-gds-dtl-full Удаленные признаки
&glob table_c-gds-dtl-full '{&bef-table_c-gds-dtl-full}':U
&glob bef-table_c-gds-dtl-attr-full Иcтория для gds-dtl-attr
&glob table_c-gds-dtl-attr-full '{&bef-table_c-gds-dtl-attr-full}':U
&glob bef-table_c-gds-grp-full c-gds-grp
&glob table_c-gds-grp-full '{&bef-table_c-gds-grp-full}':U
&glob bef-table_c-gds-grp-attr-full История атрибутов групп товаро
&glob table_c-gds-grp-attr-full '{&bef-table_c-gds-grp-attr-full}':U
&glob bef-table_c-gds-grp-hist-full c-gds-grp-hist
&glob table_c-gds-grp-hist-full '{&bef-table_c-gds-grp-hist-full}':U
&glob bef-table_c-gds-grp-obj-full История параметров групп товаров
&glob table_c-gds-grp-obj-full '{&bef-table_c-gds-grp-obj-full}':U
&glob bef-table_c-gds-hist-full c-gds-hist
&glob table_c-gds-hist-full '{&bef-table_c-gds-hist-full}':U
&glob bef-table_c-gds-host-attr-full ИСТОРИЯ атрибутов товара на фирме
&glob table_c-gds-host-attr-full '{&bef-table_c-gds-host-attr-full}':U
&glob bef-table_c-gds-mercury-full c-gds-mercury
&glob table_c-gds-mercury-full '{&bef-table_c-gds-mercury-full}':U
&glob bef-table_c-gds-obj-full c-gds-obj
&glob table_c-gds-obj-full '{&bef-table_c-gds-obj-full}':U
&glob bef-table_c-gds-obj-attr-full История атрибутов товара на объекте
&glob table_c-gds-obj-attr-full '{&bef-table_c-gds-obj-attr-full}':U
&glob bef-table_c-gds-obj-prop-full История свойств товара на объе
&glob table_c-gds-obj-prop-full '{&bef-table_c-gds-obj-prop-full}':U
&glob bef-table_c-gds-obj-ref-full Ист.справ.частиgds-obj
&glob table_c-gds-obj-ref-full '{&bef-table_c-gds-obj-ref-full}':U
&glob bef-table_c-gds-prt-full история шкал
&glob table_c-gds-prt-full '{&bef-table_c-gds-prt-full}':U
&glob bef-table_c-gds-prt-attr-full Иcтория для gds-prt-attr
&glob table_c-gds-prt-attr-full '{&bef-table_c-gds-prt-attr-full}':U
&glob bef-table_c-gds-season-full История сезонных характеристик товара
&glob table_c-gds-season-full '{&bef-table_c-gds-season-full}':U
&glob bef-table_c-global-state-full История глобальных настроек
&glob table_c-global-state-full '{&bef-table_c-global-state-full}':U
&glob bef-table_c-global-state-attr-full История атрибутов глобальных настроек
&glob table_c-global-state-attr-full '{&bef-table_c-global-state-attr-full}':U
&glob bef-table_c-goods-full c-goods
&glob table_c-goods-full '{&bef-table_c-goods-full}':U
&glob bef-table_c-goods-attr-full ИСТОРИЯ атрибутов товара
&glob table_c-goods-attr-full '{&bef-table_c-goods-attr-full}':U
&glob bef-table_c-goods-attr-any-full ИСТОРИЯ атрибутов товара
&glob table_c-goods-attr-any-full '{&bef-table_c-goods-attr-any-full}':U
&glob bef-table_c-group-period-validity-full История групп сроков хранения
&glob table_c-group-period-validity-full '{&bef-table_c-group-period-validity-full}':U
&glob bef-table_c-group-period-validity-attr-full Иcтория для group-period-validity-attr
&glob table_c-group-period-validity-attr-full '{&bef-table_c-group-period-validity-attr-full}':U
&glob bef-table_c-grp-obj-price-full История группы объектов для ценообр.
&glob table_c-grp-obj-price-full '{&bef-table_c-grp-obj-price-full}':U
&glob bef-table_c-hist-nws-option-full История настроек ист и маршрут
&glob table_c-hist-nws-option-full '{&bef-table_c-hist-nws-option-full}':U
&glob bef-table_c-hist-nws-option-attr-full Иcтория для hist-nws-option-attr
&glob table_c-hist-nws-option-attr-full '{&bef-table_c-hist-nws-option-attr-full}':U
&glob bef-table_c-host-grp-obj-price-full История фирмы в группе объектов для це
&glob table_c-host-grp-obj-price-full '{&bef-table_c-host-grp-obj-price-full}':U
&glob bef-table_c-inkas-full Удаленные продажи
&glob table_c-inkas-full '{&bef-table_c-inkas-full}':U
&glob bef-table_c-inkas-pay-full c-inkas-pay
&glob table_c-inkas-pay-full '{&bef-table_c-inkas-pay-full}':U
&glob bef-table_c-inkas-pay-desk-full c-inkas-pay-desk
&glob table_c-inkas-pay-desk-full '{&bef-table_c-inkas-pay-desk-full}':U
&glob bef-table_c-inkas-pay-wth-full c-inkas-pay-wth
&glob table_c-inkas-pay-wth-full '{&bef-table_c-inkas-pay-wth-full}':U
&glob bef-table_c-inv-line-full c-inv-line
&glob table_c-inv-line-full '{&bef-table_c-inv-line-full}':U
&glob bef-table_c-layout-full История раскладки
&glob table_c-layout-full '{&bef-table_c-layout-full}':U
&glob bef-table_c-layout-attr-full История атр.раскладок
&glob table_c-layout-attr-full '{&bef-table_c-layout-attr-full}':U
&glob bef-table_c-layout-elem-full История элементов интерфейса
&glob table_c-layout-elem-full '{&bef-table_c-layout-elem-full}':U
&glob bef-table_c-layout-elem-attr-full c-layout-elem-attr
&glob table_c-layout-elem-attr-full '{&bef-table_c-layout-elem-attr-full}':U
&glob bef-table_c-layout-elem-rule-full История привз элем.раскладки
&glob table_c-layout-elem-rule-full '{&bef-table_c-layout-elem-rule-full}':U
&glob bef-table_c-layout-elem-rule-attr-full Ист атр линий раскладок
&glob table_c-layout-elem-rule-attr-full '{&bef-table_c-layout-elem-rule-attr-full}':U
&glob bef-table_c-marking-full c-marking
&glob table_c-marking-full '{&bef-table_c-marking-full}':U
&glob bef-table_c-marking-attr-full История изменений по marking-attr
&glob table_c-marking-attr-full '{&bef-table_c-marking-attr-full}':U
&glob bef-table_c-norm-loss-full c-norm-loss
&glob table_c-norm-loss-full '{&bef-table_c-norm-loss-full}':U
&glob bef-table_c-nozzle-full Пистолеты ТРК
&glob table_c-nozzle-full '{&bef-table_c-nozzle-full}':U
&glob bef-table_c-nozzle-attr-full История атрибутов пистолета
&glob table_c-nozzle-attr-full '{&bef-table_c-nozzle-attr-full}':U
&glob bef-table_c-nzl-hist-full шапка истории пистолета
&glob table_c-nzl-hist-full '{&bef-table_c-nzl-hist-full}':U
&glob bef-table_c-obj-grp-obj-price-full Объект в группе об. для ценооб
&glob table_c-obj-grp-obj-price-full '{&bef-table_c-obj-grp-obj-price-full}':U
&glob bef-table_c-OperServ-full Операторы
&glob table_c-OperServ-full '{&bef-table_c-OperServ-full}':U
&glob bef-table_c-OperServAttr-full атрибуты кассовой книги
&glob table_c-OperServAttr-full '{&bef-table_c-OperServAttr-full}':U
&glob bef-table_c-ord-doc-full История заказа
&glob table_c-ord-doc-full '{&bef-table_c-ord-doc-full}':U
&glob bef-table_c-ord-doc-attr-full История атрибутов заказа
&glob table_c-ord-doc-attr-full '{&bef-table_c-ord-doc-attr-full}':U
&glob bef-table_c-ord-dtl-full История признаков взаказе
&glob table_c-ord-dtl-full '{&bef-table_c-ord-dtl-full}':U
&glob bef-table_c-ord-line-full c-ord-line
&glob table_c-ord-line-full '{&bef-table_c-ord-line-full}':U
&glob bef-table_c-ord-line-attr-full История атрибутов строки
&glob table_c-ord-line-attr-full '{&bef-table_c-ord-line-attr-full}':U
&glob bef-table_c-parts-full Удаленные партии
&glob table_c-parts-full '{&bef-table_c-parts-full}':U
&glob bef-table_c-parts-add-full История Сумм д.р. в учет.цене
&glob table_c-parts-add-full '{&bef-table_c-parts-add-full}':U
&glob bef-table_c-parts-attr-full Атрибуты партии
&glob table_c-parts-attr-full '{&bef-table_c-parts-attr-full}':U
&glob bef-table_c-parts-obj-attr-full История атриб партий
&glob table_c-parts-obj-attr-full '{&bef-table_c-parts-obj-attr-full}':U
&glob bef-table_c-parts-root-full История ссылок по партиям
&glob table_c-parts-root-full '{&bef-table_c-parts-root-full}':U
&glob bef-table_c-pay-type-full c-pay-type
&glob table_c-pay-type-full '{&bef-table_c-pay-type-full}':U
&glob bef-table_c-pay-type-attr-full Иcтория для pay-type-attr
&glob table_c-pay-type-attr-full '{&bef-table_c-pay-type-attr-full}':U
&glob bef-table_c-payment-attr-full Иcтория для payment-attr
&glob table_c-payment-attr-full '{&bef-table_c-payment-attr-full}':U
&glob bef-table_c-person-full c-person
&glob table_c-person-full '{&bef-table_c-person-full}':U
&glob bef-table_c-pl-gds-full c-pl-gds
&glob table_c-pl-gds-full '{&bef-table_c-pl-gds-full}':U
&glob bef-table_c-pl-gds-attr-full Ист атрв товара на скл.месте
&glob table_c-pl-gds-attr-full '{&bef-table_c-pl-gds-attr-full}':U
&glob bef-table_c-pl-gds-obj-full история расчетных полей pl-gds
&glob table_c-pl-gds-obj-full '{&bef-table_c-pl-gds-obj-full}':U
&glob bef-table_c-pl-gds-pump-full c-pl-gds-pump
&glob table_c-pl-gds-pump-full '{&bef-table_c-pl-gds-pump-full}':U
&glob bef-table_c-pl-gds-pump-attr-full Иcтория для pl-gds-pump-attr
&glob table_c-pl-gds-pump-attr-full '{&bef-table_c-pl-gds-pump-attr-full}':U
&glob bef-table_c-pl-level-full История градуировочной таблицы
&glob table_c-pl-level-full '{&bef-table_c-pl-level-full}':U
&glob bef-table_c-pl-level-attr-full Иcтория для pl-level-attr
&glob table_c-pl-level-attr-full '{&bef-table_c-pl-level-attr-full}':U
&glob bef-table_c-pl-pump-full c-pl-pump
&glob table_c-pl-pump-full '{&bef-table_c-pl-pump-full}':U
&glob bef-table_c-pl-pump-attr-full Иcтория для pl-pump-attr
&glob table_c-pl-pump-attr-full '{&bef-table_c-pl-pump-attr-full}':U
&glob bef-table_c-pl-pump-nozzle-full c-pl-pump-nozzle
&glob table_c-pl-pump-nozzle-full '{&bef-table_c-pl-pump-nozzle-full}':U
&glob bef-table_c-pl-pump-nozzle-attr-full Иcтория для pl-pump-nozzle-attr
&glob table_c-pl-pump-nozzle-attr-full '{&bef-table_c-pl-pump-nozzle-attr-full}':U
&glob bef-table_c-place-full c-place
&glob table_c-place-full '{&bef-table_c-place-full}':U
&glob bef-table_c-place-attr-full Истор атриб складского места
&glob table_c-place-attr-full '{&bef-table_c-place-attr-full}':U
&glob bef-table_c-place-io-full c-place-io
&glob table_c-place-io-full '{&bef-table_c-place-io-full}':U
&glob bef-table_c-plc-hist-full История МХ в целом по справоч
&glob table_c-plc-hist-full '{&bef-table_c-plc-hist-full}':U
&glob bef-table_c-pmp-hist-full шапка истории по ТРК
&glob table_c-pmp-hist-full '{&bef-table_c-pmp-hist-full}':U
&glob bef-table_c-point-io-full c-point-io
&glob table_c-point-io-full '{&bef-table_c-point-io-full}':U
&glob bef-table_c-point-place-rel-full История транспортных связей
&glob table_c-point-place-rel-full '{&bef-table_c-point-place-rel-full}':U
&glob bef-table_c-point-point-rel-full История пункт-пункт
&glob table_c-point-point-rel-full '{&bef-table_c-point-point-rel-full}':U
&glob bef-table_c-price-doc-full c-price-doc
&glob table_c-price-doc-full '{&bef-table_c-price-doc-full}':U
&glob bef-table_c-price-doc-forming-full История документа формирования цены
&glob table_c-price-doc-forming-full '{&bef-table_c-price-doc-forming-full}':U
&glob bef-table_c-price-doc-forming-attr-full История атрибутов док. форм. цены
&glob table_c-price-doc-forming-attr-full '{&bef-table_c-price-doc-forming-attr-full}':U
&glob bef-table_c-price-doc-forming-gds-full История товара в док-те форм-ия цены
&glob table_c-price-doc-forming-gds-full '{&bef-table_c-price-doc-forming-gds-full}':U
&glob bef-table_c-price-doc-forming-gds-qnty-full Товар в док форм цены по кол
&glob table_c-price-doc-forming-gds-qnty-full '{&bef-table_c-price-doc-forming-gds-qnty-full}':U
&glob bef-table_c-price-doc-forming-gds-sum-full Товар в док форм цены по сумме
&glob table_c-price-doc-forming-gds-sum-full '{&bef-table_c-price-doc-forming-gds-sum-full}':U
&glob bef-table_c-price-doc-forming-gds-tnv-full Товар в док форм цены по обор
&glob table_c-price-doc-forming-gds-tnv-full '{&bef-table_c-price-doc-forming-gds-tnv-full}':U
&glob bef-table_c-price-doc-forming-gdsattr-full История атрибутов строки ДНЦ
&glob table_c-price-doc-forming-gdsattr-full '{&bef-table_c-price-doc-forming-gdsattr-full}':U
&glob bef-table_c-price-list-full c-price-list
&glob table_c-price-list-full '{&bef-table_c-price-list-full}':U
&glob bef-table_c-price-list-attr-full История атрибутов строки
&glob table_c-price-list-attr-full '{&bef-table_c-price-list-attr-full}':U
&glob bef-table_c-price-list-type-full c-price-list-type
&glob table_c-price-list-type-full '{&bef-table_c-price-list-type-full}':U
&glob bef-table_c-price-list-type-attr-full Атрибуты типа прайс-листа
&glob table_c-price-list-type-attr-full '{&bef-table_c-price-list-type-attr-full}':U
&glob bef-table_c-price-list-type-cash-pay-full Ист.огр.т.п.-л. по т. кас. пл.
&glob table_c-price-list-type-cash-pay-full '{&bef-table_c-price-list-type-cash-pay-full}':U
&glob bef-table_c-price-list-type-cassa-full Связь типа прайс-листа с касса
&glob table_c-price-list-type-cassa-full '{&bef-table_c-price-list-type-cassa-full}':U
&glob bef-table_c-price-list-type-gds-grp-full Огранич. типа пл по груп тов.
&glob table_c-price-list-type-gds-grp-full '{&bef-table_c-price-list-type-gds-grp-full}':U
&glob bef-table_c-price-list-type-pay-type-full Ист.огр.т.п-л по типам опл
&glob table_c-price-list-type-pay-type-full '{&bef-table_c-price-list-type-pay-type-full}':U
&glob bef-table_c-prod-bc-full c-prod-bc
&glob table_c-prod-bc-full '{&bef-table_c-prod-bc-full}':U
&glob bef-table_c-prod-bc-attr-full История атрибутов ДопБК
&glob table_c-prod-bc-attr-full '{&bef-table_c-prod-bc-attr-full}':U
&glob bef-table_c-prod-bc-db-attr-full Иcтория для prod-bc-db-attr
&glob table_c-prod-bc-db-attr-full '{&bef-table_c-prod-bc-db-attr-full}':U
&glob bef-table_c-profile-by-profile-full Ист привязки проф к проф
&glob table_c-profile-by-profile-full '{&bef-table_c-profile-by-profile-full}':U
&glob bef-table_c-promo-head-full c-promo-head
&glob table_c-promo-head-full '{&bef-table_c-promo-head-full}':U
&glob bef-table_c-promo-schedule-full История заголовков расписаний акций
&glob table_c-promo-schedule-full '{&bef-table_c-promo-schedule-full}':U
&glob bef-table_c-promo-schedule-week-full История расписаний акций
&glob table_c-promo-schedule-week-full '{&bef-table_c-promo-schedule-week-full}':U
&glob bef-table_c-PromoAction-full История акций
&glob table_c-PromoAction-full '{&bef-table_c-PromoAction-full}':U
&glob bef-table_c-PromoAttr-full атрибуты акций
&glob table_c-PromoAttr-full '{&bef-table_c-PromoAttr-full}':U
&glob bef-table_c-PromoCriterion-full История критериев акций
&glob table_c-PromoCriterion-full '{&bef-table_c-PromoCriterion-full}':U
&glob bef-table_c-PromoGift-full История подарков акций
&glob table_c-PromoGift-full '{&bef-table_c-PromoGift-full}':U
&glob bef-table_c-PromoGoods-full История товаров акций
&glob table_c-PromoGoods-full '{&bef-table_c-PromoGoods-full}':U
&glob bef-table_c-PromoObject-full История объектов акций
&glob table_c-PromoObject-full '{&bef-table_c-PromoObject-full}':U
&glob bef-table_c-prop-head-full История ОПИСАНИЯ СВОЙСТВ
&glob table_c-prop-head-full '{&bef-table_c-prop-head-full}':U
&glob bef-table_c-prop-ref-full История типов срезов хранилища
&glob table_c-prop-ref-full '{&bef-table_c-prop-ref-full}':U
&glob bef-table_c-prop-ruleset-full История привязки объекты-своды
&glob table_c-prop-ruleset-full '{&bef-table_c-prop-ruleset-full}':U
&glob bef-table_c-prop-script-full История скриптов
&glob table_c-prop-script-full '{&bef-table_c-prop-script-full}':U
&glob bef-table_c-pscript-ruleset-full История связки СПРИПТ-набор пр
&glob table_c-pscript-ruleset-full '{&bef-table_c-pscript-ruleset-full}':U
&glob bef-table_c-pump-full c-pump
&glob table_c-pump-full '{&bef-table_c-pump-full}':U
&glob bef-table_c-pump-attr-full История атрибутов ТРК
&glob table_c-pump-attr-full '{&bef-table_c-pump-attr-full}':U
&glob bef-table_c-pump-nozzle-full ТРК-пистолеты ТРК
&glob table_c-pump-nozzle-full '{&bef-table_c-pump-nozzle-full}':U
&glob bef-table_c-pump-nozzle-attr-full Иcтория для pump-nozzle-attr
&glob table_c-pump-nozzle-attr-full '{&bef-table_c-pump-nozzle-attr-full}':U
&glob bef-table_c-qnty-group-full Количественная группа
&glob table_c-qnty-group-full '{&bef-table_c-qnty-group-full}':U
&glob bef-table_c-qnty-in-qnty-group-full Количества в кол-ой группе
&glob table_c-qnty-in-qnty-group-full '{&bef-table_c-qnty-in-qnty-group-full}':U
&glob bef-table_c-recipe-full c-recipe
&glob table_c-recipe-full '{&bef-table_c-recipe-full}':U
&glob bef-table_c-recipe-develop-full c-recipe-develop
&glob table_c-recipe-develop-full '{&bef-table_c-recipe-develop-full}':U
&glob bef-table_c-recipe-gds-full c-recipe-gds
&glob table_c-recipe-gds-full '{&bef-table_c-recipe-gds-full}':U
&glob bef-table_c-recipe-hist-full История рецепта
&glob table_c-recipe-hist-full '{&bef-table_c-recipe-hist-full}':U
&glob bef-table_c-regions-full c-regions
&glob table_c-regions-full '{&bef-table_c-regions-full}':U
&glob bef-table_c-rp-by-call-full История привязки проф к вызову
&glob table_c-rp-by-call-full '{&bef-table_c-rp-by-call-full}':U
&glob bef-table_c-rp-rule-param-full Истори пар проф и прав
&glob table_c-rp-rule-param-full '{&bef-table_c-rp-rule-param-full}':U
&glob bef-table_c-rule-full История правил
&glob table_c-rule-full '{&bef-table_c-rule-full}':U
&glob bef-table_c-rule-by-call-full История rule-by-call
&glob table_c-rule-by-call-full '{&bef-table_c-rule-by-call-full}':U
&glob bef-table_c-rule-by-profile-full Ист привязки правил к проф
&glob table_c-rule-by-profile-full '{&bef-table_c-rule-by-profile-full}':U
&glob bef-table_c-rule-by-set-full История привязки правил к свод
&glob table_c-rule-by-set-full '{&bef-table_c-rule-by-set-full}':U
&glob bef-table_c-rule-call-param-full История параметров вызова прав
&glob table_c-rule-call-param-full '{&bef-table_c-rule-call-param-full}':U
&glob bef-table_c-rule-process-full История процессов
&glob table_c-rule-process-full '{&bef-table_c-rule-process-full}':U
&glob bef-table_c-rule-profile-full История профайла правил
&glob table_c-rule-profile-full '{&bef-table_c-rule-profile-full}':U
&glob bef-table_c-ruledict-full История словаря
&glob table_c-ruledict-full '{&bef-table_c-ruledict-full}':U
&glob bef-table_c-ruledict-param-full История пар-ов словаря правил
&glob table_c-ruledict-param-full '{&bef-table_c-ruledict-param-full}':U
&glob bef-table_c-ruleset-full История сводов правил
&glob table_c-ruleset-full '{&bef-table_c-ruleset-full}':U
&glob bef-table_c-rvs-doc-full c-rvs-doc
&glob table_c-rvs-doc-full '{&bef-table_c-rvs-doc-full}':U
&glob bef-table_c-rvs-line-full c-rvs-line
&glob table_c-rvs-line-full '{&bef-table_c-rvs-line-full}':U
&glob bef-table_c-rvs-line-pump-full c-rvs-line-pump
&glob table_c-rvs-line-pump-full '{&bef-table_c-rvs-line-pump-full}':U
&glob bef-table_c-s-coeff-full Сезонные коэффициенты
&glob table_c-s-coeff-full '{&bef-table_c-s-coeff-full}':U
&glob bef-table_c-sale-doc-full История подчин док-тов продажи
&glob table_c-sale-doc-full '{&bef-table_c-sale-doc-full}':U
&glob bef-table_c-scales-full c-scales
&glob table_c-scales-full '{&bef-table_c-scales-full}':U
&glob bef-table_c-scales-attr-full c-scales-attr
&glob table_c-scales-attr-full '{&bef-table_c-scales-attr-full}':U
&glob bef-table_c-scales-gds-full c-scales-gds
&glob table_c-scales-gds-full '{&bef-table_c-scales-gds-full}':U
&glob bef-table_c-scales-grp-full c-scales-grp
&glob table_c-scales-grp-full '{&bef-table_c-scales-grp-full}':U
&glob bef-table_c-schet-fact-doc-full c-schet-fact-doc
&glob table_c-schet-fact-doc-full '{&bef-table_c-schet-fact-doc-full}':U
&glob bef-table_c-schet-fact-line-full c-schet-fact-line
&glob table_c-schet-fact-line-full '{&bef-table_c-schet-fact-line-full}':U
&glob bef-table_c-season-full История сезонов
&glob table_c-season-full '{&bef-table_c-season-full}':U
&glob bef-table_c-sert-full история сертификатов
&glob table_c-sert-full '{&bef-table_c-sert-full}':U
&glob bef-table_c-shift-attr-full История по атр. смен
&glob table_c-shift-attr-full '{&bef-table_c-shift-attr-full}':U
&glob bef-table_c-shift-obj-full история смены на объекте
&glob table_c-shift-obj-full '{&bef-table_c-shift-obj-full}':U
&glob bef-table_c-shift-staff-full история персонала смены на объ
&glob table_c-shift-staff-full '{&bef-table_c-shift-staff-full}':U
&glob bef-table_c-shop-full c-shop
&glob table_c-shop-full '{&bef-table_c-shop-full}':U
&glob bef-table_c-sht-hist-full шапка истории смен
&glob table_c-sht-hist-full '{&bef-table_c-sht-hist-full}':U
&glob bef-table_c-sr-izmerenia-full c-sr-izmerenia
&glob table_c-sr-izmerenia-full '{&bef-table_c-sr-izmerenia-full}':U
&glob bef-table_c-sr-izmerenia-attr-full c-sr-izmerenia-attr
&glob table_c-sr-izmerenia-attr-full '{&bef-table_c-sr-izmerenia-attr-full}':U
&glob bef-table_c-staff-full c-staff
&glob table_c-staff-full '{&bef-table_c-staff-full}':U
&glob bef-table_c-stop-list-full История стоплистов
&glob table_c-stop-list-full '{&bef-table_c-stop-list-full}':U
&glob bef-table_c-stop-list-line-full Истори строк стоплиста
&glob table_c-stop-list-line-full '{&bef-table_c-stop-list-line-full}':U
&glob bef-table_c-store-full c-store
&glob table_c-store-full '{&bef-table_c-store-full}':U
&glob bef-table_c-sum-group-full Суммовая группа
&glob table_c-sum-group-full '{&bef-table_c-sum-group-full}':U
&glob bef-table_c-sum-grp-full история sum-grp
&glob table_c-sum-grp-full '{&bef-table_c-sum-grp-full}':U
&glob bef-table_c-sum-grp-obj-full история sum-grp-obj
&glob table_c-sum-grp-obj-full '{&bef-table_c-sum-grp-obj-full}':U
&glob bef-table_c-sum-in-sum-group-full Сумма в суммовой группе
&glob table_c-sum-in-sum-group-full '{&bef-table_c-sum-in-sum-group-full}':U
&glob bef-table_c-sysconf-full c-sysconf
&glob table_c-sysconf-full '{&bef-table_c-sysconf-full}':U
&glob bef-table_c-table-bind-full c-table-bind
&glob table_c-table-bind-full '{&bef-table_c-table-bind-full}':U
&glob bef-table_c-tare-full История тары
&glob table_c-tare-full '{&bef-table_c-tare-full}':U
&glob bef-table_c-tax-full История налога
&glob table_c-tax-full '{&bef-table_c-tax-full}':U
&glob bef-table_c-tax-hist-full История налогов
&glob table_c-tax-hist-full '{&bef-table_c-tax-hist-full}':U
&glob bef-table_c-tax-rate-full c-tax-rate
&glob table_c-tax-rate-full '{&bef-table_c-tax-rate-full}':U
&glob bef-table_c-tax-rate-gds-grp-full c-tax-rate-gds-grp
&glob table_c-tax-rate-gds-grp-full '{&bef-table_c-tax-rate-gds-grp-full}':U
&glob bef-table_c-tax-units-full c-tax-units
&glob table_c-tax-units-full '{&bef-table_c-tax-units-full}':U
&glob bef-table_c-tech-prol-pwd-full c-tech-prol-pwd
&glob table_c-tech-prol-pwd-full '{&bef-table_c-tech-prol-pwd-full}':U
&glob bef-table_c-thbj-attr-full История пар-ров объекта TH
&glob table_c-thbj-attr-full '{&bef-table_c-thbj-attr-full}':U
&glob bef-table_c-tnv-in-turnover-group-full Сумма в суммовой группе
&glob table_c-tnv-in-turnover-group-full '{&bef-table_c-tnv-in-turnover-group-full}':U
&glob bef-table_c-trn-doc-full Удаленные складские документы
&glob table_c-trn-doc-full '{&bef-table_c-trn-doc-full}':U
&glob bef-table_c-trn-doc-sum-full c-trn-doc-sum
&glob table_c-trn-doc-sum-full '{&bef-table_c-trn-doc-sum-full}':U
&glob bef-table_c-trn-reason-full История оснований (причин)
&glob table_c-trn-reason-full '{&bef-table_c-trn-reason-full}':U
&glob bef-table_c-trn-reason-host-full История причин на фирме
&glob table_c-trn-reason-host-full '{&bef-table_c-trn-reason-host-full}':U
&glob bef-table_c-trn-reason-obj-full Код причин на объекте
&glob table_c-trn-reason-obj-full '{&bef-table_c-trn-reason-obj-full}':U
&glob bef-table_c-trn-rsn-attr-full История атрибутов причин
&glob table_c-trn-rsn-attr-full '{&bef-table_c-trn-rsn-attr-full}':U
&glob bef-table_c-turnover-group-full Группа оборотов
&glob table_c-turnover-group-full '{&bef-table_c-turnover-group-full}':U
&glob bef-table_c-units-full история ед изм
&glob table_c-units-full '{&bef-table_c-units-full}':U
&glob bef-table_c-user-account-full c-user-account
&glob table_c-user-account-full '{&bef-table_c-user-account-full}':U
&glob bef-table_c-user-log-full История действий пользователя
&glob table_c-user-log-full '{&bef-table_c-user-log-full}':U
&glob bef-table_c-user-login-full c-user-login
&glob table_c-user-login-full '{&bef-table_c-user-login-full}':U
&glob bef-table_c-usr-hist-full c-usr-hist
&glob table_c-usr-hist-full '{&bef-table_c-usr-hist-full}':U
&glob bef-table_c-utd-full c-utd
&glob table_c-utd-full '{&bef-table_c-utd-full}':U
&glob bef-table_c-utd-attr-full c-utd-attr
&glob table_c-utd-attr-full '{&bef-table_c-utd-attr-full}':U
&glob bef-table_c-utd-err-full Ошибки УПД
&glob table_c-utd-err-full '{&bef-table_c-utd-err-full}':U
&glob bef-table_c-utd-err-attr-full c-utd-err-attr
&glob table_c-utd-err-attr-full '{&bef-table_c-utd-err-attr-full}':U
&glob bef-table_c-utd-head-full c-utd-head
&glob table_c-utd-head-full '{&bef-table_c-utd-head-full}':U
&glob bef-table_c-utd-lines-full c-utd-lines
&glob table_c-utd-lines-full '{&bef-table_c-utd-lines-full}':U
&glob bef-table_c-utd-lines-attr-full c-utd-lines-attr
&glob table_c-utd-lines-attr-full '{&bef-table_c-utd-lines-attr-full}':U
&glob bef-table_c-utd-marking-lines-full c-utd-marking-lines
&glob table_c-utd-marking-lines-full '{&bef-table_c-utd-marking-lines-full}':U
&glob bef-table_c-utd-marking-lines-attr-full c-utd-marking-lines-attr
&glob table_c-utd-marking-lines-attr-full '{&bef-table_c-utd-marking-lines-attr-full}':U
&glob bef-table_c-var-deliv-gr-per-val-full История вариантов доставки по срокам го
&glob table_c-var-deliv-gr-per-val-full '{&bef-table_c-var-deliv-gr-per-val-full}':U
&glob bef-table_c-variant-delivery-full История вариантов доставки
&glob table_c-variant-delivery-full '{&bef-table_c-variant-delivery-full}':U
&glob bef-table_c-varianty-delivery-gds-obj-full История вариантов доставки тов. на об
&glob table_c-varianty-delivery-gds-obj-full '{&bef-table_c-varianty-delivery-gds-obj-full}':U
&glob bef-table_c-vsd-full c-vsd
&glob table_c-vsd-full '{&bef-table_c-vsd-full}':U
&glob bef-table_c-wealth-full c-wealth
&glob table_c-wealth-full '{&bef-table_c-wealth-full}':U
&glob bef-table_c-wi-mode-full История режимов
&glob table_c-wi-mode-full '{&bef-table_c-wi-mode-full}':U
&glob bef-table_c-wi-mode-attr-full История атрибутов режимов
&glob table_c-wi-mode-attr-full '{&bef-table_c-wi-mode-attr-full}':U
&glob bef-table_c-wth-doc-full c-wth-doc
&glob table_c-wth-doc-full '{&bef-table_c-wth-doc-full}':U
&glob bef-table_c-wth-dtl-full c-wth-dtl
&glob table_c-wth-dtl-full '{&bef-table_c-wth-dtl-full}':U
&glob bef-table_c-wth-gds-full c-wth-gds
&glob table_c-wth-gds-full '{&bef-table_c-wth-gds-full}':U
&glob bef-table_c-wth-gds-attr-full c-wth-gds-attr
&glob table_c-wth-gds-attr-full '{&bef-table_c-wth-gds-attr-full}':U
&glob bef-table_c-wth-hist-full c-wth-hist
&glob table_c-wth-hist-full '{&bef-table_c-wth-hist-full}':U
&glob bef-table_c-wth-line-full c-wth-line
&glob table_c-wth-line-full '{&bef-table_c-wth-line-full}':U
&glob bef-table_c-wth-obj-full история остатков по МЦ
&glob table_c-wth-obj-full '{&bef-table_c-wth-obj-full}':U
&glob bef-table_c-wth-par-full c-wth-par
&glob table_c-wth-par-full '{&bef-table_c-wth-par-full}':U
&glob bef-table_c-wth-parts-full История партий МЦ
&glob table_c-wth-parts-full '{&bef-table_c-wth-parts-full}':U
&glob bef-table_c-wth-place-full история МХ МЦ
&glob table_c-wth-place-full '{&bef-table_c-wth-place-full}':U
&glob bef-table_c-wth-pobj-full история остатков МЦ по МХ
&glob table_c-wth-pobj-full '{&bef-table_c-wth-pobj-full}':U
&glob bef-table_c-wth-ser-full c-wth-ser
&glob table_c-wth-ser-full '{&bef-table_c-wth-ser-full}':U
&glob bef-table_c-wth-ser-attr-full c-wth-ser-attr
&glob table_c-wth-ser-attr-full '{&bef-table_c-wth-ser-attr-full}':U
&glob bef-table_cash-desk-full Касса
&glob table_cash-desk-full '{&bef-table_cash-desk-full}':U
&glob bef-table_cash-desk-attr-full Аттр.кассы
&glob table_cash-desk-attr-full '{&bef-table_cash-desk-attr-full}':U
&glob bef-table_Cash-param-hist-full Параметры на кассе
&glob table_Cash-param-hist-full '{&bef-table_Cash-param-hist-full}':U
&glob bef-table_cash-pay-full Касс.платеж
&glob table_cash-pay-full '{&bef-table_cash-pay-full}':U
&glob bef-table_cash-pay-attr-full Аттр.касс.пл-жа
&glob table_cash-pay-attr-full '{&bef-table_cash-pay-attr-full}':U
&glob bef-table_CashBook-full Кассовые книги
&glob table_CashBook-full '{&bef-table_CashBook-full}':U
&glob bef-table_CashBookAttr-full атрибуты кассовой книги
&glob table_CashBookAttr-full '{&bef-table_CashBookAttr-full}':U
&glob bef-table_CashBookRule-full CashBookRule
&glob table_CashBookRule-full '{&bef-table_CashBookRule-full}':U
&glob bef-table_CashBookRuleAttr-full атрибуты кассовой книги
&glob table_CashBookRuleAttr-full '{&bef-table_CashBookRuleAttr-full}':U
&glob bef-table_cbr-bank-full Банки из списков ЦБ РФ
&glob table_cbr-bank-full '{&bef-table_cbr-bank-full}':U
&glob bef-table_cbr-bank-attr-full Атрибуты для cbr-bank
&glob table_cbr-bank-attr-full '{&bef-table_cbr-bank-attr-full}':U
&glob bef-table_cd-clu-full cd-clu
&glob table_cd-clu-full '{&bef-table_cd-clu-full}':U
&glob bef-table_cd-clu-attr-full Атрибуты для cd-clu
&glob table_cd-clu-attr-full '{&bef-table_cd-clu-attr-full}':U
&glob bef-table_cd-dlu-full ДК на кассе
&glob table_cd-dlu-full '{&bef-table_cd-dlu-full}':U
&glob bef-table_cd-dlu-attr-full Атрибуты для cd-dlu
&glob table_cd-dlu-attr-full '{&bef-table_cd-dlu-attr-full}':U
&glob bef-table_cd-doc-full Документы на кассе
&glob table_cd-doc-full '{&bef-table_cd-doc-full}':U
&glob bef-table_cd-doc-attr-full Атрибуты для cd-doc
&glob table_cd-doc-attr-full '{&bef-table_cd-doc-attr-full}':U
&glob bef-table_cd-doc-line-full Строка документа на кассе
&glob table_cd-doc-line-full '{&bef-table_cd-doc-line-full}':U
&glob bef-table_cd-doc-line-attr-full Атрибуты для cd-doc-line
&glob table_cd-doc-line-attr-full '{&bef-table_cd-doc-line-attr-full}':U
&glob bef-table_cd-event-log-full cd-event-log
&glob table_cd-event-log-full '{&bef-table_cd-event-log-full}':U
&glob bef-table_cd-event-log-attr-full cd-event-log-attr
&glob table_cd-event-log-attr-full '{&bef-table_cd-event-log-attr-full}':U
&glob bef-table_cd-events-full cd-events
&glob table_cd-events-full '{&bef-table_cd-events-full}':U
&glob bef-table_cd-events-attr-full cd-events-attr
&glob table_cd-events-attr-full '{&bef-table_cd-events-attr-full}':U
&glob bef-table_cd-grp-full Группы на кассах
&glob table_cd-grp-full '{&bef-table_cd-grp-full}':U
&glob bef-table_cd-grp-attr-full Атрибуты для cd-grp
&glob table_cd-grp-attr-full '{&bef-table_cd-grp-attr-full}':U
&glob bef-table_cd-plu-full Товары на кассе-Товары
&glob table_cd-plu-full '{&bef-table_cd-plu-full}':U
&glob bef-table_cd-plu-attr-full Атрибуты для cd-plu
&glob table_cd-plu-attr-full '{&bef-table_cd-plu-attr-full}':U
&glob bef-table_cd-trans-full cd-trans
&glob table_cd-trans-full '{&bef-table_cd-trans-full}':U
&glob bef-table_cd-trans-attr-full Атрибуты для cd-trans
&glob table_cd-trans-attr-full '{&bef-table_cd-trans-attr-full}':U
&glob bef-table_cd-video-link-full cd-video-link
&glob table_cd-video-link-full '{&bef-table_cd-video-link-full}':U
&glob bef-table_cd-video-link-attr-full cd-video-link-attr
&glob table_cd-video-link-attr-full '{&bef-table_cd-video-link-attr-full}':U
&glob bef-table_chk-discnt-full Скидки чека
&glob table_chk-discnt-full '{&bef-table_chk-discnt-full}':U
&glob bef-table_chk-discnt-attr-full Атрибуты для chk-discnt
&glob table_chk-discnt-attr-full '{&bef-table_chk-discnt-attr-full}':U
&glob bef-table_chk-doc-full chk-doc
&glob table_chk-doc-full '{&bef-table_chk-doc-full}':U
&glob bef-table_chk-doc-attr-full Атрибуты чека
&glob table_chk-doc-attr-full '{&bef-table_chk-doc-attr-full}':U
&glob bef-table_chk-gds-full chk-gds
&glob table_chk-gds-full '{&bef-table_chk-gds-full}':U
&glob bef-table_chk-gds-attr-full Атрибуты для chk-gds
&glob table_chk-gds-attr-full '{&bef-table_chk-gds-attr-full}':U
&glob bef-table_chk-gds-pay-full chk-gds-pay
&glob table_chk-gds-pay-full '{&bef-table_chk-gds-pay-full}':U
&glob bef-table_chk-pay-full chk-pay
&glob table_chk-pay-full '{&bef-table_chk-pay-full}':U
&glob bef-table_chk-pay-attr-full Атрибуты для chk-pay
&glob table_chk-pay-attr-full '{&bef-table_chk-pay-attr-full}':U
&glob bef-table_chk-slip-head-full chk-slip-head
&glob table_chk-slip-head-full '{&bef-table_chk-slip-head-full}':U
&glob bef-table_chk-slip-string-full chk-slip-string
&glob table_chk-slip-string-full '{&bef-table_chk-slip-string-full}':U
&glob bef-table_cli-art-full cli-art
&glob table_cli-art-full '{&bef-table_cli-art-full}':U
&glob bef-table_cli-art-attr-full Атрибуты для cli-art
&glob table_cli-art-attr-full '{&bef-table_cli-art-attr-full}':U
&glob bef-table_cli-gds-full cli-gds
&glob table_cli-gds-full '{&bef-table_cli-gds-full}':U
&glob bef-table_cli-gds-attr-full Атрибуты для cli-gds
&glob table_cli-gds-attr-full '{&bef-table_cli-gds-attr-full}':U
&glob bef-table_cli-grp-full Группа клиентов
&glob table_cli-grp-full '{&bef-table_cli-grp-full}':U
&glob bef-table_cli-grp-attr-full Атрибуты для cli-grp
&glob table_cli-grp-attr-full '{&bef-table_cli-grp-attr-full}':U
&glob bef-table_clients-full Клиент
&glob table_clients-full '{&bef-table_clients-full}':U
&glob bef-table_clients-attr-full Атрибут клиента
&glob table_clients-attr-full '{&bef-table_clients-attr-full}':U
&glob bef-table_clob-bind-full Связка clob с владельцем
&glob table_clob-bind-full '{&bef-table_clob-bind-full}':U
&glob bef-table_clob-data-full CLOB-data
&glob table_clob-data-full '{&bef-table_clob-data-full}':U
&glob bef-table_Code-full Справочники
&glob table_Code-full '{&bef-table_Code-full}':U
&glob bef-table_code-range-full code-range
&glob table_code-range-full '{&bef-table_code-range-full}':U
&glob bef-table_condition-keeping-full Условия хранения
&glob table_condition-keeping-full '{&bef-table_condition-keeping-full}':U
&glob bef-table_condition-keeping-attr-full Атрибуты для condition-keeping
&glob table_condition-keeping-attr-full '{&bef-table_condition-keeping-attr-full}':U
&glob bef-table_config-full config
&glob table_config-full '{&bef-table_config-full}':U
&glob bef-table_contract-full contract
&glob table_contract-full '{&bef-table_contract-full}':U
&glob bef-table_contract-attr-full Атрибуты для contract
&glob table_contract-attr-full '{&bef-table_contract-attr-full}':U
&glob bef-table_contract-line-full contract-line
&glob table_contract-line-full '{&bef-table_contract-line-full}':U
&glob bef-table_contract-line-attr-full Атрибуты для contract-line
&glob table_contract-line-attr-full '{&bef-table_contract-line-attr-full}':U
&glob bef-table_contract-specif-full Спецификация к дог-ру
&glob table_contract-specif-full '{&bef-table_contract-specif-full}':U
&glob bef-table_contract-specif-attr-full Атрибуты для contract-specif
&glob table_contract-specif-attr-full '{&bef-table_contract-specif-attr-full}':U
&glob bef-table_counter-full counter
&glob table_counter-full '{&bef-table_counter-full}':U
&glob bef-table_country-full country
&glob table_country-full '{&bef-table_country-full}':U
&glob bef-table_country-attr-full Атрибуты для country
&glob table_country-attr-full '{&bef-table_country-attr-full}':U
&glob bef-table_criterion-analysis-full Справочник критериев анализа
&glob table_criterion-analysis-full '{&bef-table_criterion-analysis-full}':U
&glob bef-table_criterion-analysis-attr-full Атрибуты для criterion-analysis
&glob table_criterion-analysis-attr-full '{&bef-table_criterion-analysis-attr-full}':U
&glob bef-table_cshr-month-full cshr-month
&glob table_cshr-month-full '{&bef-table_cshr-month-full}':U
&glob bef-table_cshr-month-attr-full Атрибуты для cshr-month
&glob table_cshr-month-attr-full '{&bef-table_cshr-month-attr-full}':U
&glob bef-table_curr-accnt-full curr-accnt
&glob table_curr-accnt-full '{&bef-table_curr-accnt-full}':U
&glob bef-table_curr-accnt-attr-full Атрибуты для curr-accnt
&glob table_curr-accnt-attr-full '{&bef-table_curr-accnt-attr-full}':U
&glob bef-table_curr-bank-full curr-bank
&glob table_curr-bank-full '{&bef-table_curr-bank-full}':U
&glob bef-table_curr-bank-attr-full Атрибуты для curr-bank
&glob table_curr-bank-attr-full '{&bef-table_curr-bank-attr-full}':U
&glob bef-table_curr-shop-full curr-shop
&glob table_curr-shop-full '{&bef-table_curr-shop-full}':U
&glob bef-table_curr-shop-attr-full Атрибуты для curr-shop
&glob table_curr-shop-attr-full '{&bef-table_curr-shop-attr-full}':U
&glob bef-table_currency-full currency
&glob table_currency-full '{&bef-table_currency-full}':U
&glob bef-table_currency-attr-full Атрибуты для currency
&glob table_currency-attr-full '{&bef-table_currency-attr-full}':U
&glob bef-table_custom-labels-full Настройки лейблов
&glob table_custom-labels-full '{&bef-table_custom-labels-full}':U
&glob bef-table_datatype-exp-full Типы данных дл экс во внеш си
&glob table_datatype-exp-full '{&bef-table_datatype-exp-full}':U
&glob bef-table_datatype-exp-attr-full Атр типа данных дл экспорта
&glob table_datatype-exp-attr-full '{&bef-table_datatype-exp-attr-full}':U
&glob bef-table_datatype-imp-full Типы данных дл имп во внеш си
&glob table_datatype-imp-full '{&bef-table_datatype-imp-full}':U
&glob bef-table_datatype-imp-attr-full Атр типа данных дл импорта
&glob table_datatype-imp-attr-full '{&bef-table_datatype-imp-attr-full}':U
&glob bef-table_datatype-table-full Описание таблиц дл внешних си
&glob table_datatype-table-full '{&bef-table_datatype-table-full}':U
&glob bef-table_datatype-table-exp-full datatype-table-exp
&glob table_datatype-table-exp-full '{&bef-table_datatype-table-exp-full}':U
&glob bef-table_datatype-table-field-full Пол таблиц дл внешней систем
&glob table_datatype-table-field-full '{&bef-table_datatype-table-field-full}':U
&glob bef-table_datatype-table-field-exp-full Пол таблиц дл экспорта по ти
&glob table_datatype-table-field-exp-full '{&bef-table_datatype-table-field-exp-full}':U
&glob bef-table_datatype-table-field-imp-full datatype-table-field-imp
&glob table_datatype-table-field-imp-full '{&bef-table_datatype-table-field-imp-full}':U
&glob bef-table_datatype-table-imp-full datatype-table-imp
&glob table_datatype-table-imp-full '{&bef-table_datatype-table-imp-full}':U
&glob bef-table_db-full db
&glob table_db-full '{&bef-table_db-full}':U
&glob bef-table_db-attr-full Атрибуты БД
&glob table_db-attr-full '{&bef-table_db-attr-full}':U
&glob bef-table_db-filter-full db-filter
&glob table_db-filter-full '{&bef-table_db-filter-full}':U
&glob bef-table_db-filter-attr-full Атрибуты для db-filter
&glob table_db-filter-attr-full '{&bef-table_db-filter-attr-full}':U
&glob bef-table_db-grp-obj-price-full БД в группе объектов ценообр
&glob table_db-grp-obj-price-full '{&bef-table_db-grp-obj-price-full}':U
&glob bef-table_db-grp-obj-price-attr-full Атрибуты для db-grp-obj-price
&glob table_db-grp-obj-price-attr-full '{&bef-table_db-grp-obj-price-attr-full}':U
&glob bef-table_db-info-full db-info
&glob table_db-info-full '{&bef-table_db-info-full}':U
&glob bef-table_db-rec-attr-full db-rec-attr
&glob table_db-rec-attr-full '{&bef-table_db-rec-attr-full}':U
&glob bef-table_db-status-full db-status
&glob table_db-status-full '{&bef-table_db-status-full}':U
&glob bef-table_db-status-attr-full Атрибуты для db-status
&glob table_db-status-attr-full '{&bef-table_db-status-attr-full}':U
&glob bef-table_db-usr-flt-full db-usr-flt
&glob table_db-usr-flt-full '{&bef-table_db-usr-flt-full}':U
&glob bef-table_db-usr-flt-attr-full Атрибуты для db-usr-flt
&glob table_db-usr-flt-attr-full '{&bef-table_db-usr-flt-attr-full}':U
&glob bef-table_deliv-type-cond-keep-full Типы доставки по условиям хран
&glob table_deliv-type-cond-keep-full '{&bef-table_deliv-type-cond-keep-full}':U
&glob bef-table_deliv-type-cond-keep-attr-full Атрибуты для deliv-type-cond-keep
&glob table_deliv-type-cond-keep-attr-full '{&bef-table_deliv-type-cond-keep-attr-full}':U
&glob bef-table_delivery-subject-full Субъект доставки
&glob table_delivery-subject-full '{&bef-table_delivery-subject-full}':U
&glob bef-table_delivery-subject-attr-full Атрибуты для delivery-subject
&glob table_delivery-subject-attr-full '{&bef-table_delivery-subject-attr-full}':U
&glob bef-table_delivery-type-full Типы доставки
&glob table_delivery-type-full '{&bef-table_delivery-type-full}':U
&glob bef-table_delivery-type-attr-full Атрибуты для delivery-type
&glob table_delivery-type-attr-full '{&bef-table_delivery-type-attr-full}':U
&glob bef-table_delivery-type-subject-full Типы доставки от субъектов
&glob table_delivery-type-subject-full '{&bef-table_delivery-type-subject-full}':U
&glob bef-table_delivery-type-subject-attr-full Атрибуты для delivery-type-subject
&glob table_delivery-type-subject-attr-full '{&bef-table_delivery-type-subject-attr-full}':U
&glob bef-table_devisPC-full Устройства
&glob table_devisPC-full '{&bef-table_devisPC-full}':U
&glob bef-table_devisPC-attr-full devisPC-attr
&glob table_devisPC-attr-full '{&bef-table_devisPC-attr-full}':U
&glob bef-table_dis-card-full Диск.карта
&glob table_dis-card-full '{&bef-table_dis-card-full}':U
&glob bef-table_dis-card-long-full Реальные (длинные) номера карт
&glob table_dis-card-long-full '{&bef-table_dis-card-long-full}':U
&glob bef-table_dis-card-long-attr-full Атрибуты для dis-card-long
&glob table_dis-card-long-attr-full '{&bef-table_dis-card-long-attr-full}':U
&glob bef-table_dis-card-mask-full Маска диск.карты
&glob table_dis-card-mask-full '{&bef-table_dis-card-mask-full}':U
&glob bef-table_dis-card-mask-attr-full Атрибуты для dis-card-mask
&glob table_dis-card-mask-attr-full '{&bef-table_dis-card-mask-attr-full}':U
&glob bef-table_dis-card-property-full Свойства ДК
&glob table_dis-card-property-full '{&bef-table_dis-card-property-full}':U
&glob bef-table_dis-card-type-full Тип диск.карты
&glob table_dis-card-type-full '{&bef-table_dis-card-type-full}':U
&glob bef-table_dis-card-type-attr-full Аттр.типа диск.карты
&glob table_dis-card-type-attr-full '{&bef-table_dis-card-type-attr-full}':U
&glob bef-table_dis-cfg-rule-full Связи dis-rule
&glob table_dis-cfg-rule-full '{&bef-table_dis-cfg-rule-full}':U
&glob bef-table_dis-cfg-rule-attr-full Атрибуты для dis-cfg-rule
&glob table_dis-cfg-rule-attr-full '{&bef-table_dis-cfg-rule-attr-full}':U
&glob bef-table_dis-cp-rule-full Скидки на платеж
&glob table_dis-cp-rule-full '{&bef-table_dis-cp-rule-full}':U
&glob bef-table_dis-cp-rule-attr-full Атрибуты для dis-cp-rule
&glob table_dis-cp-rule-attr-full '{&bef-table_dis-cp-rule-attr-full}':U
&glob bef-table_dis-dc-rule-full Скидки для ДК
&glob table_dis-dc-rule-full '{&bef-table_dis-dc-rule-full}':U
&glob bef-table_dis-dc-rule-attr-full Атрибуты для dis-dc-rule
&glob table_dis-dc-rule-attr-full '{&bef-table_dis-dc-rule-attr-full}':U
&glob bef-table_dis-dct-rule-full Скидки на типы ДК
&glob table_dis-dct-rule-full '{&bef-table_dis-dct-rule-full}':U
&glob bef-table_dis-dct-rule-attr-full Атрибуты для dis-dct-rule
&glob table_dis-dct-rule-attr-full '{&bef-table_dis-dct-rule-attr-full}':U
&glob bef-table_dis-gds-rule-full Скидка Товара на объ.
&glob table_dis-gds-rule-full '{&bef-table_dis-gds-rule-full}':U
&glob bef-table_dis-gds-rule-attr-full Атрибуты для dis-gds-rule
&glob table_dis-gds-rule-attr-full '{&bef-table_dis-gds-rule-attr-full}':U
&glob bef-table_dis-grp-rule-full Скидки по группе
&glob table_dis-grp-rule-full '{&bef-table_dis-grp-rule-full}':U
&glob bef-table_dis-grp-rule-attr-full Атрибуты для dis-grp-rule
&glob table_dis-grp-rule-attr-full '{&bef-table_dis-grp-rule-attr-full}':U
&glob bef-table_dis-host-full Итоги ДК фирма/общ
&glob table_dis-host-full '{&bef-table_dis-host-full}':U
&glob bef-table_dis-obj-full Итоги ДК на объ.
&glob table_dis-obj-full '{&bef-table_dis-obj-full}':U
&glob bef-table_dis-rule-full правила скидок
&glob table_dis-rule-full '{&bef-table_dis-rule-full}':U
&glob bef-table_dis-rule-attr-full Атрибуты для dis-rule
&glob table_dis-rule-attr-full '{&bef-table_dis-rule-attr-full}':U
&glob bef-table_dis-some-rule-full Привязка прв скид
&glob table_dis-some-rule-full '{&bef-table_dis-some-rule-full}':U
&glob bef-table_dis-some-rule-attr-full Атрибуты для dis-some-rule
&glob table_dis-some-rule-attr-full '{&bef-table_dis-some-rule-attr-full}':U
&glob bef-table_dis-thbj-rule-full Общие скидки
&glob table_dis-thbj-rule-full '{&bef-table_dis-thbj-rule-full}':U
&glob bef-table_dis-thbj-rule-attr-full Атрибуты для dis-thbj-rule
&glob table_dis-thbj-rule-attr-full '{&bef-table_dis-thbj-rule-attr-full}':U
&glob bef-table_dis-time-rule-full расписания
&glob table_dis-time-rule-full '{&bef-table_dis-time-rule-full}':U
&glob bef-table_dis-time-rule-attr-full Атрибуты для dis-time-rule
&glob table_dis-time-rule-attr-full '{&bef-table_dis-time-rule-attr-full}':U
&glob bef-table_dish-grp-full dish-grp
&glob table_dish-grp-full '{&bef-table_dish-grp-full}':U
&glob bef-table_dish-grp-attr-full Атрибуты для dish-grp
&glob table_dish-grp-attr-full '{&bef-table_dish-grp-attr-full}':U
&glob bef-table_doc-abc-def-full Спис.расш.типов док.вABC по ум
&glob table_doc-abc-def-full '{&bef-table_doc-abc-def-full}':U
&glob bef-table_doc-abc-def-attr-full Атрибуты для doc-abc-def
&glob table_doc-abc-def-attr-full '{&bef-table_doc-abc-def-attr-full}':U
&glob bef-table_doc-abc-def-doc-full Ртд в списке ртд в ABC анал ум
&glob table_doc-abc-def-doc-full '{&bef-table_doc-abc-def-doc-full}':U
&glob bef-table_doc-abc-def-doc-attr-full Атрибуты для doc-abc-def-doc
&glob table_doc-abc-def-doc-attr-full '{&bef-table_doc-abc-def-doc-attr-full}':U
&glob bef-table_doc-abc-def-obj-full Об. в списке ртд в ABCанал умо
&glob table_doc-abc-def-obj-full '{&bef-table_doc-abc-def-obj-full}':U
&glob bef-table_doc-abc-def-obj-attr-full Атрибуты для doc-abc-def-obj
&glob table_doc-abc-def-obj-attr-full '{&bef-table_doc-abc-def-obj-attr-full}':U
&glob bef-table_doc-attr-full Атрибуты всех документов
&glob table_doc-attr-full '{&bef-table_doc-attr-full}':U
&glob bef-table_doc-fact-num-full Список операций по документам
&glob table_doc-fact-num-full '{&bef-table_doc-fact-num-full}':U
&glob bef-table_doc-fact-num-attr-full Атрибуты для doc-fact-num
&glob table_doc-fact-num-attr-full '{&bef-table_doc-fact-num-attr-full}':U
&glob bef-table_doc-fbr-gds-full doc-fbr-gds
&glob table_doc-fbr-gds-full '{&bef-table_doc-fbr-gds-full}':U
&glob bef-table_doc-fbr-gds-attr-full Атрибуты для doc-fbr-gds
&glob table_doc-fbr-gds-attr-full '{&bef-table_doc-fbr-gds-attr-full}':U
&glob bef-table_doc-filter-full Фильтр документов
&glob table_doc-filter-full '{&bef-table_doc-filter-full}':U
&glob bef-table_doc-filter-attr-full Атрибуты для doc-filter
&glob table_doc-filter-attr-full '{&bef-table_doc-filter-attr-full}':U
&glob bef-table_doc-filter-head-full Заголовок фильтра документов
&glob table_doc-filter-head-full '{&bef-table_doc-filter-head-full}':U
&glob bef-table_doc-filter-head-attr-full Атрибуты для doc-filter-head
&glob table_doc-filter-head-attr-full '{&bef-table_doc-filter-head-attr-full}':U
&glob bef-table_doc-line-full doc-line
&glob table_doc-line-full '{&bef-table_doc-line-full}':U
&glob bef-table_doc-line-attr-full doc-line-attr
&glob table_doc-line-attr-full '{&bef-table_doc-line-attr-full}':U
&glob bef-table_doc-line-sum-full doc-line-sum
&glob table_doc-line-sum-full '{&bef-table_doc-line-sum-full}':U
&glob bef-table_doc-pl-full doc-pl
&glob table_doc-pl-full '{&bef-table_doc-pl-full}':U
&glob bef-table_doc-pl-attr-full Атрибуты для doc-pl
&glob table_doc-pl-attr-full '{&bef-table_doc-pl-attr-full}':U
&glob bef-table_doc-pl-pump-full doc-pl-pump
&glob table_doc-pl-pump-full '{&bef-table_doc-pl-pump-full}':U
&glob bef-table_doc-pl-pump-attr-full Атрибуты для doc-pl-pump
&glob table_doc-pl-pump-attr-full '{&bef-table_doc-pl-pump-attr-full}':U
&glob bef-table_doc-prts-full doc-prts
&glob table_doc-prts-full '{&bef-table_doc-prts-full}':U
&glob bef-table_doc-prts-attr-full Атрибуты для doc-prts
&glob table_doc-prts-attr-full '{&bef-table_doc-prts-attr-full}':U
&glob bef-table_doc-xyz-def-full Список ртд в XYZ по умолчанию
&glob table_doc-xyz-def-full '{&bef-table_doc-xyz-def-full}':U
&glob bef-table_doc-xyz-def-attr-full Атрибуты для doc-xyz-def
&glob table_doc-xyz-def-attr-full '{&bef-table_doc-xyz-def-attr-full}':U
&glob bef-table_doc-xyz-def-doc-full Ртд в списке ртд в XYZ по умол
&glob table_doc-xyz-def-doc-full '{&bef-table_doc-xyz-def-doc-full}':U
&glob bef-table_doc-xyz-def-doc-attr-full Атрибуты для doc-xyz-def-doc
&glob table_doc-xyz-def-doc-attr-full '{&bef-table_doc-xyz-def-doc-attr-full}':U
&glob bef-table_doc-xyz-def-obj-full Объекты в сп.ртд в XYZ по умол
&glob table_doc-xyz-def-obj-full '{&bef-table_doc-xyz-def-obj-full}':U
&glob bef-table_doc-xyz-def-obj-attr-full Атрибуты для doc-xyz-def-obj
&glob table_doc-xyz-def-obj-attr-full '{&bef-table_doc-xyz-def-obj-attr-full}':U
&glob bef-table_drt-prop-full Св-ва правил скижок и распис.
&glob table_drt-prop-full '{&bef-table_drt-prop-full}':U
&glob bef-table_edi-status-full Статусы для EDI
&glob table_edi-status-full '{&bef-table_edi-status-full}':U
&glob bef-table_egais-clients-full egais-clients
&glob table_egais-clients-full '{&bef-table_egais-clients-full}':U
&glob bef-table_egais-gds-full egais-gds
&glob table_egais-gds-full '{&bef-table_egais-gds-full}':U
&glob bef-table_esys-all-attr-full атрибуты
&glob table_esys-all-attr-full '{&bef-table_esys-all-attr-full}':U
&glob bef-table_esys-datatype-exp-full Типы данных дл экспорт во вн с
&glob table_esys-datatype-exp-full '{&bef-table_esys-datatype-exp-full}':U
&glob bef-table_esys-datatype-imp-full Типы данных дл импорт во вн с
&glob table_esys-datatype-imp-full '{&bef-table_esys-datatype-imp-full}':U
&glob bef-table_esys-pck-keys-full Ключи
&glob table_esys-pck-keys-full '{&bef-table_esys-pck-keys-full}':U
&glob bef-table_esys-pck-rcvd-full esys-pck-rcvd
&glob table_esys-pck-rcvd-full '{&bef-table_esys-pck-rcvd-full}':U
&glob bef-table_esys-pck-sent-full esys-pck-sent
&glob table_esys-pck-sent-full '{&bef-table_esys-pck-sent-full}':U
&glob bef-table_esys-route-full esys-route
&glob table_esys-route-full '{&bef-table_esys-route-full}':U
&glob bef-table_esys-route-dump-full esys-route-dump
&glob table_esys-route-dump-full '{&bef-table_esys-route-dump-full}':U
&glob bef-table_ex-mark-full Акцизные и специальные марки
&glob table_ex-mark-full '{&bef-table_ex-mark-full}':U
&glob bef-table_ex-mark-attr-full Атрибуты для ex-mark
&glob table_ex-mark-attr-full '{&bef-table_ex-mark-attr-full}':U
&glob bef-table_ext-artic-full Внешний артикул товара
&glob table_ext-artic-full '{&bef-table_ext-artic-full}':U
&glob bef-table_ext-artic-attr-full Атрибуты внешнего артикула
&glob table_ext-artic-attr-full '{&bef-table_ext-artic-attr-full}':U
&glob bef-table_ext-artic-db-full Ограничение внешнего артикула
&glob table_ext-artic-db-full '{&bef-table_ext-artic-db-full}':U
&glob bef-table_ext-artic-db-attr-full Атрибуты для ext-artic-db
&glob table_ext-artic-db-attr-full '{&bef-table_ext-artic-db-attr-full}':U
&glob bef-table_ext-artic-host-full Ограничение внешнего артикула
&glob table_ext-artic-host-full '{&bef-table_ext-artic-host-full}':U
&glob bef-table_ext-artic-host-attr-full Атрибуты для ext-artic-host
&glob table_ext-artic-host-attr-full '{&bef-table_ext-artic-host-attr-full}':U
&glob bef-table_ext-artic-obj-full Ограничение внешнего артикула
&glob table_ext-artic-obj-full '{&bef-table_ext-artic-obj-full}':U
&glob bef-table_ext-artic-obj-attr-full Атрибуты для ext-artic-obj
&glob table_ext-artic-obj-attr-full '{&bef-table_ext-artic-obj-attr-full}':U
&glob bef-table_ext-classif-full Внешний классификатор
&glob table_ext-classif-full '{&bef-table_ext-classif-full}':U
&glob bef-table_ext-classif-attr-full Атрибуты для ext-classif
&glob table_ext-classif-attr-full '{&bef-table_ext-classif-attr-full}':U
&glob bef-table_ext-file-full ext-file
&glob table_ext-file-full '{&bef-table_ext-file-full}':U
&glob bef-table_ext-file-attr-full Атрибуты для ext-file
&glob table_ext-file-attr-full '{&bef-table_ext-file-attr-full}':U
&glob bef-table_ext-file-line-full ext-file-line
&glob table_ext-file-line-full '{&bef-table_ext-file-line-full}':U
&glob bef-table_ext-file-line-attr-full Атрибуты для ext-file-line
&glob table_ext-file-line-attr-full '{&bef-table_ext-file-line-attr-full}':U
&glob bef-table_ext-file-par-full ext-file-par
&glob table_ext-file-par-full '{&bef-table_ext-file-par-full}':U
&glob bef-table_ext-file-par-attr-full Атрибуты для ext-file-par
&glob table_ext-file-par-attr-full '{&bef-table_ext-file-par-attr-full}':U
&glob bef-table_ext-system-full Внешние системы
&glob table_ext-system-full '{&bef-table_ext-system-full}':U
&glob bef-table_ext-system-attr-full Атрибуты внешней системы
&glob table_ext-system-attr-full '{&bef-table_ext-system-attr-full}':U
&glob bef-table_factur-connect-full Связка
&glob table_factur-connect-full '{&bef-table_factur-connect-full}':U
&glob bef-table_factur-connect-attr-full Атрибуты для factur-connect
&glob table_factur-connect-attr-full '{&bef-table_factur-connect-attr-full}':U
&glob bef-table_factur-connect-line-full Связка счета-фактуры с док-ми
&glob table_factur-connect-line-full '{&bef-table_factur-connect-line-full}':U
&glob bef-table_factur-connect-line-attr-full Атрибуты для factur-connect-line
&glob table_factur-connect-line-attr-full '{&bef-table_factur-connect-line-attr-full}':U
&glob bef-table_fbr-doc-full fbr-doc
&glob table_fbr-doc-full '{&bef-table_fbr-doc-full}':U
&glob bef-table_fbr-gds-grp-full Группа блюд
&glob table_fbr-gds-grp-full '{&bef-table_fbr-gds-grp-full}':U
&glob bef-table_fbr-gds-grp-attr-full Атр-т группы блюд
&glob table_fbr-gds-grp-attr-full '{&bef-table_fbr-gds-grp-attr-full}':U
&glob bef-table_fbr-gds-obj-full Атрибут РЕСТОРАНа
&glob table_fbr-gds-obj-full '{&bef-table_fbr-gds-obj-full}':U
&glob bef-table_fbr-gds-obj-attr-full Атрибуты для fbr-gds-obj
&glob table_fbr-gds-obj-attr-full '{&bef-table_fbr-gds-obj-attr-full}':U
&glob bef-table_fbr-history-full fbr-history
&glob table_fbr-history-full '{&bef-table_fbr-history-full}':U
&glob bef-table_fbr-line-full fbr-line
&glob table_fbr-line-full '{&bef-table_fbr-line-full}':U
&glob bef-table_fbr-pln-full Документы план-меню
&glob table_fbr-pln-full '{&bef-table_fbr-pln-full}':U
&glob bef-table_fbr-pln-line-full Строки план-меню
&glob table_fbr-pln-line-full '{&bef-table_fbr-pln-line-full}':U
&glob bef-table_fbr-prn-full Принтера производства
&glob table_fbr-prn-full '{&bef-table_fbr-prn-full}':U
&glob bef-table_fbr-prn-attr-full Атрибуты для fbr-prn
&glob table_fbr-prn-attr-full '{&bef-table_fbr-prn-attr-full}':U
&glob bef-table_fbr-prn-gds-full Принтера пр-ва-товары
&glob table_fbr-prn-gds-full '{&bef-table_fbr-prn-gds-full}':U
&glob bef-table_fbr-prn-gds-attr-full Атрибуты для fbr-prn-gds
&glob table_fbr-prn-gds-attr-full '{&bef-table_fbr-prn-gds-attr-full}':U
&glob bef-table_fbr-prn-grp-full Груп тов-принтера пр-ва
&glob table_fbr-prn-grp-full '{&bef-table_fbr-prn-grp-full}':U
&glob bef-table_fbr-prn-grp-attr-full Атрибуты для fbr-prn-grp
&glob table_fbr-prn-grp-attr-full '{&bef-table_fbr-prn-grp-attr-full}':U
&glob bef-table_fbr-recipe-full fbr-recipe
&glob table_fbr-recipe-full '{&bef-table_fbr-recipe-full}':U
&glob bef-table_fbr-recipe-gds-full fbr-recipe-gds
&glob table_fbr-recipe-gds-full '{&bef-table_fbr-recipe-gds-full}':U
&glob bef-table_feature-full feature
&glob table_feature-full '{&bef-table_feature-full}':U
&glob bef-table_feature-attr-full Атрибуты для feature
&glob table_feature-attr-full '{&bef-table_feature-attr-full}':U
&glob bef-table_feature-scale-full feature-scale
&glob table_feature-scale-full '{&bef-table_feature-scale-full}':U
&glob bef-table_feature-scale-attr-full Атрибуты для feature-scale
&glob table_feature-scale-attr-full '{&bef-table_feature-scale-attr-full}':U
&glob bef-table_Filter-full Filter
&glob table_Filter-full '{&bef-table_Filter-full}':U
&glob bef-table_Filter-attr-full Атрибуты для Filter
&glob table_Filter-attr-full '{&bef-table_Filter-attr-full}':U
&glob bef-table_fin-bank-full Реквизиты банка
&glob table_fin-bank-full '{&bef-table_fin-bank-full}':U
&glob bef-table_fin-bank-attr-full Атрибуты для fin-bank
&glob table_fin-bank-attr-full '{&bef-table_fin-bank-attr-full}':U
&glob bef-table_fin-code-an-uchet-full Коды аналитического учета
&glob table_fin-code-an-uchet-full '{&bef-table_fin-code-an-uchet-full}':U
&glob bef-table_fin-code-an-uchet-attr-full Атрибуты для fin-code-an-uchet
&glob table_fin-code-an-uchet-attr-full '{&bef-table_fin-code-an-uchet-attr-full}':U
&glob bef-table_fin-code-cel-nazn-full Коды целевого назначения
&glob table_fin-code-cel-nazn-full '{&bef-table_fin-code-cel-nazn-full}':U
&glob bef-table_fin-code-cel-nazn-attr-full Атрибуты для fin-code-cel-nazn
&glob table_fin-code-cel-nazn-attr-full '{&bef-table_fin-code-cel-nazn-attr-full}':U
&glob bef-table_fin-code-cor-acc-full Корреспондируюшие счета
&glob table_fin-code-cor-acc-full '{&bef-table_fin-code-cor-acc-full}':U
&glob bef-table_fin-code-cor-acc-attr-full Атрибуты для fin-code-cor-acc
&glob table_fin-code-cor-acc-attr-full '{&bef-table_fin-code-cor-acc-attr-full}':U
&glob bef-table_fin-connect-full Связи фин. док-ов и фин. обяз.
&glob table_fin-connect-full '{&bef-table_fin-connect-full}':U
&glob bef-table_fin-connect-attr-full Атрибуты для fin-connect
&glob table_fin-connect-attr-full '{&bef-table_fin-connect-attr-full}':U
&glob bef-table_fin-doc-full Финансовые документы
&glob table_fin-doc-full '{&bef-table_fin-doc-full}':U
&glob bef-table_fin-doc-attr-full Доп. атрибуты фин. документа
&glob table_fin-doc-attr-full '{&bef-table_fin-doc-attr-full}':U
&glob bef-table_fin-doc-cor-acc-lk-full Локир. корсчета по фин.док-ту
&glob table_fin-doc-cor-acc-lk-full '{&bef-table_fin-doc-cor-acc-lk-full}':U
&glob bef-table_fin-doc-cor-acc-lk-attr-full Атрибуты для fin-doc-cor-acc-lk
&glob table_fin-doc-cor-acc-lk-attr-full '{&bef-table_fin-doc-cor-acc-lk-attr-full}':U
&glob bef-table_fin-doc-obj-full Разбивка финансового документа по объектам
&glob table_fin-doc-obj-full '{&bef-table_fin-doc-obj-full}':U
&glob bef-table_fin-doc-obj-attr-full Атрибуты для fin-doc-obj
&glob table_fin-doc-obj-attr-full '{&bef-table_fin-doc-obj-attr-full}':U
&glob bef-table_fin-doc-schet-lk-full Таблица локировки счета фин. д
&glob table_fin-doc-schet-lk-full '{&bef-table_fin-doc-schet-lk-full}':U
&glob bef-table_fin-doc-schet-lk-attr-full Атрибуты для fin-doc-schet-lk
&glob table_fin-doc-schet-lk-attr-full '{&bef-table_fin-doc-schet-lk-attr-full}':U
&glob bef-table_fin-doc-tax-full Налоги в финанс. док-тах
&glob table_fin-doc-tax-full '{&bef-table_fin-doc-tax-full}':U
&glob bef-table_fin-doc-tax-attr-full Атрибуты для fin-doc-tax
&glob table_fin-doc-tax-attr-full '{&bef-table_fin-doc-tax-attr-full}':U
&glob bef-table_fin-gds-part-full партии финансовых обязательств
&glob table_fin-gds-part-full '{&bef-table_fin-gds-part-full}':U
&glob bef-table_fin-gds-part-attr-full Атрибуты для fin-gds-part
&glob table_fin-gds-part-attr-full '{&bef-table_fin-gds-part-attr-full}':U
&glob bef-table_fin-ob-full Финансовые обязательства
&glob table_fin-ob-full '{&bef-table_fin-ob-full}':U
&glob bef-table_fin-ob-attr-full атрибуты финобязательств
&glob table_fin-ob-attr-full '{&bef-table_fin-ob-attr-full}':U
&glob bef-table_fin-ob-before-full Предфин.обязательства
&glob table_fin-ob-before-full '{&bef-table_fin-ob-before-full}':U
&glob bef-table_fin-ob-cor-acc-lk-full Локир. корсчетов фин. обяз.
&glob table_fin-ob-cor-acc-lk-full '{&bef-table_fin-ob-cor-acc-lk-full}':U
&glob bef-table_fin-ob-cor-acc-lk-attr-full Атрибуты для fin-ob-cor-acc-lk
&glob table_fin-ob-cor-acc-lk-attr-full '{&bef-table_fin-ob-cor-acc-lk-attr-full}':U
&glob bef-table_fin-ob-schet-lk-full Локирование счета фин. обяз.
&glob table_fin-ob-schet-lk-full '{&bef-table_fin-ob-schet-lk-full}':U
&glob bef-table_fin-ob-schet-lk-attr-full Атрибуты для fin-ob-schet-lk
&glob table_fin-ob-schet-lk-attr-full '{&bef-table_fin-ob-schet-lk-attr-full}':U
&glob bef-table_fin-ob-tax-full Налоги по фин. обяз
&glob table_fin-ob-tax-full '{&bef-table_fin-ob-tax-full}':U
&glob bef-table_fin-ob-tax-attr-full Атрибуты для fin-ob-tax
&glob table_fin-ob-tax-attr-full '{&bef-table_fin-ob-tax-attr-full}':U
&glob bef-table_fin-ob-tax-before-full налоги предфинобязательств
&glob table_fin-ob-tax-before-full '{&bef-table_fin-ob-tax-before-full}':U
&glob bef-table_fin-ob-trn-full Фин.обязательства - Накладные
&glob table_fin-ob-trn-full '{&bef-table_fin-ob-trn-full}':U
&glob bef-table_fin-ob-trn-attr-full Атрибуты для fin-ob-trn
&glob table_fin-ob-trn-attr-full '{&bef-table_fin-ob-trn-attr-full}':U
&glob bef-table_fin-schet-full Фин. реквизиты
&glob table_fin-schet-full '{&bef-table_fin-schet-full}':U
&glob bef-table_fin-schet-attr-full Атрибуты для fin-schet
&glob table_fin-schet-attr-full '{&bef-table_fin-schet-attr-full}':U
&glob bef-table_fin-statement-full Банковские выписки
&glob table_fin-statement-full '{&bef-table_fin-statement-full}':U
&glob bef-table_fin-statement-attr-full Атрибуты выписки
&glob table_fin-statement-attr-full '{&bef-table_fin-statement-attr-full}':U
&glob bef-table_fin-statement-line-full Строка выписки
&glob table_fin-statement-line-full '{&bef-table_fin-statement-line-full}':U
&glob bef-table_fin-statement-line-attr-full Атрибуты для fin-statement-line
&glob table_fin-statement-line-attr-full '{&bef-table_fin-statement-line-attr-full}':U
&glob bef-table_firm-full Организация
&glob table_firm-full '{&bef-table_firm-full}':U
&glob bef-table_gds-add-charges-full Дополнительные расходы тов
&glob table_gds-add-charges-full '{&bef-table_gds-add-charges-full}':U
&glob bef-table_gds-add-charges-attr-full Атрибуты доп.расходов
&glob table_gds-add-charges-attr-full '{&bef-table_gds-add-charges-attr-full}':U
&glob bef-table_gds-dtl-full gds-dtl
&glob table_gds-dtl-full '{&bef-table_gds-dtl-full}':U
&glob bef-table_gds-dtl-attr-full Атрибуты для gds-dtl
&glob table_gds-dtl-attr-full '{&bef-table_gds-dtl-attr-full}':U
&glob bef-table_gds-grp-full Группа товаров
&glob table_gds-grp-full '{&bef-table_gds-grp-full}':U
&glob bef-table_gds-grp-attr-full Атр-т группы товаров
&glob table_gds-grp-attr-full '{&bef-table_gds-grp-attr-full}':U
&glob bef-table_gds-grp-obj-full Группа товаров на объекте
&glob table_gds-grp-obj-full '{&bef-table_gds-grp-obj-full}':U
&glob bef-table_gds-grp-obj-attr-full Атрибуты для gds-grp-obj
&glob table_gds-grp-obj-attr-full '{&bef-table_gds-grp-obj-attr-full}':U
&glob bef-table_gds-host-attr-full Атр-т тов. на фирме
&glob table_gds-host-attr-full '{&bef-table_gds-host-attr-full}':U
&glob bef-table_gds-mercury-full gds-mercury
&glob table_gds-mercury-full '{&bef-table_gds-mercury-full}':U
&glob bef-table_gds-mercury-attr-full Аттр. справ. соот. TH-Mercury
&glob table_gds-mercury-attr-full '{&bef-table_gds-mercury-attr-full}':U
&glob bef-table_gds-obj-full Товар на объекте
&glob table_gds-obj-full '{&bef-table_gds-obj-full}':U
&glob bef-table_gds-obj-attr-full Атр-т тов. на объекте
&glob table_gds-obj-attr-full '{&bef-table_gds-obj-attr-full}':U
&glob bef-table_gds-obj-flag-full gds-obj-flag
&glob table_gds-obj-flag-full '{&bef-table_gds-obj-flag-full}':U
&glob bef-table_gds-obj-flag-attr-full Атрибуты для gds-obj-flag
&glob table_gds-obj-flag-attr-full '{&bef-table_gds-obj-flag-attr-full}':U
&glob bef-table_gds-obj-prop-full Индикаторы
&glob table_gds-obj-prop-full '{&bef-table_gds-obj-prop-full}':U
&glob bef-table_gds-obj-prop-attr-full Атр-т тов. для заказов
&glob table_gds-obj-prop-attr-full '{&bef-table_gds-obj-prop-attr-full}':U
&glob bef-table_gds-prt-full gds-prt
&glob table_gds-prt-full '{&bef-table_gds-prt-full}':U
&glob bef-table_gds-prt-attr-full Атрибуты для gds-prt
&glob table_gds-prt-attr-full '{&bef-table_gds-prt-attr-full}':U
&glob bef-table_gds-season-full Сезон товара
&glob table_gds-season-full '{&bef-table_gds-season-full}':U
&glob bef-table_gds-season-attr-full Атрибуты для gds-season
&glob table_gds-season-attr-full '{&bef-table_gds-season-attr-full}':U
&glob bef-table_gen-attr-full Атрибуты любой таблицы
&glob table_gen-attr-full '{&bef-table_gen-attr-full}':U
&glob bef-table_global-state-full Глобальные настройки
&glob table_global-state-full '{&bef-table_global-state-full}':U
&glob bef-table_global-state-attr-full Атрибуты глобальных настроек
&glob table_global-state-attr-full '{&bef-table_global-state-attr-full}':U
&glob bef-table_goods-full Товар
&glob table_goods-full '{&bef-table_goods-full}':U
&glob bef-table_goods-attr-full Атр-т товара
&glob table_goods-attr-full '{&bef-table_goods-attr-full}':U
&glob bef-table_group-period-validity-full Группы сроков хранения
&glob table_group-period-validity-full '{&bef-table_group-period-validity-full}':U
&glob bef-table_group-period-validity-attr-full Атрибуты для group-period-validity
&glob table_group-period-validity-attr-full '{&bef-table_group-period-validity-attr-full}':U
&glob bef-table_grp-obj-price-full Группа объектов для ценообр.
&glob table_grp-obj-price-full '{&bef-table_grp-obj-price-full}':U
&glob bef-table_grp-obj-price-attr-full Атрибуты для grp-obj-price
&glob table_grp-obj-price-attr-full '{&bef-table_grp-obj-price-attr-full}':U
&glob bef-table_h-route-full h-route
&glob table_h-route-full '{&bef-table_h-route-full}':U
&glob bef-table_h-route-dump-full h-route-dump
&glob table_h-route-dump-full '{&bef-table_h-route-dump-full}':U
&glob bef-table_hist-nws-option-full Опции созд. ист. и маршрут.
&glob table_hist-nws-option-full '{&bef-table_hist-nws-option-full}':U
&glob bef-table_hist-nws-option-attr-full Атрибуты для hist-nws-option
&glob table_hist-nws-option-attr-full '{&bef-table_hist-nws-option-attr-full}':U
&glob bef-table_hold-attr-full Атрибуты холдинга
&glob table_hold-attr-full '{&bef-table_hold-attr-full}':U
&glob bef-table_hold-gds-grp-full hold-gds-grp
&glob table_hold-gds-grp-full '{&bef-table_hold-gds-grp-full}':U
&glob bef-table_hold-gds-grp-attr-full Атрибуты для hold-gds-grp
&glob table_hold-gds-grp-attr-full '{&bef-table_hold-gds-grp-attr-full}':U
&glob bef-table_hold-goods-full hold-goods
&glob table_hold-goods-full '{&bef-table_hold-goods-full}':U
&glob bef-table_hold-goods-attr-full Атрибуты для hold-goods
&glob table_hold-goods-attr-full '{&bef-table_hold-goods-attr-full}':U
&glob bef-table_hold-purch-full hold-purch
&glob table_hold-purch-full '{&bef-table_hold-purch-full}':U
&glob bef-table_hold-purch-attr-full Атрибуты для hold-purch
&glob table_hold-purch-attr-full '{&bef-table_hold-purch-attr-full}':U
&glob bef-table_hold-purch-grp-full hold-purch-grp
&glob table_hold-purch-grp-full '{&bef-table_hold-purch-grp-full}':U
&glob bef-table_hold-purch-grp-attr-full Атрибуты для hold-purch-grp
&glob table_hold-purch-grp-attr-full '{&bef-table_hold-purch-grp-attr-full}':U
&glob bef-table_hold-purch-supp-full hold-purch-supp
&glob table_hold-purch-supp-full '{&bef-table_hold-purch-supp-full}':U
&glob bef-table_hold-purch-supp-attr-full Атрибуты для hold-purch-supp
&glob table_hold-purch-supp-attr-full '{&bef-table_hold-purch-supp-attr-full}':U
&glob bef-table_hold-purch-supp-gds-full hold-purch-supp-gds
&glob table_hold-purch-supp-gds-full '{&bef-table_hold-purch-supp-gds-full}':U
&glob bef-table_hold-purch-supp-gds-attr-full Атрибуты для hold-purch-supp-gds
&glob table_hold-purch-supp-gds-attr-full '{&bef-table_hold-purch-supp-gds-attr-full}':U
&glob bef-table_hold-sale-full hold-sale
&glob table_hold-sale-full '{&bef-table_hold-sale-full}':U
&glob bef-table_hold-sale-attr-full Атрибуты для hold-sale
&glob table_hold-sale-attr-full '{&bef-table_hold-sale-attr-full}':U
&glob bef-table_hold-sale-grp-full hold-sale-grp
&glob table_hold-sale-grp-full '{&bef-table_hold-sale-grp-full}':U
&glob bef-table_hold-sale-grp-attr-full Атрибуты для hold-sale-grp
&glob table_hold-sale-grp-attr-full '{&bef-table_hold-sale-grp-attr-full}':U
&glob bef-table_hold-time-full hold-time
&glob table_hold-time-full '{&bef-table_hold-time-full}':U
&glob bef-table_hold-time-attr-full hold-time-attr
&glob table_hold-time-attr-full '{&bef-table_hold-time-attr-full}':U
&glob bef-table_hold-trn-full hold-trn
&glob table_hold-trn-full '{&bef-table_hold-trn-full}':U
&glob bef-table_hold-trn-attr-full Атрибуты для hold-trn
&glob table_hold-trn-attr-full '{&bef-table_hold-trn-attr-full}':U
&glob bef-table_host-grp-obj-price-full Фирмы в группе объектов для це
&glob table_host-grp-obj-price-full '{&bef-table_host-grp-obj-price-full}':U
&glob bef-table_host-grp-obj-price-attr-full Атрибуты для host-grp-obj-price
&glob table_host-grp-obj-price-attr-full '{&bef-table_host-grp-obj-price-attr-full}':U
&glob bef-table_host-lk-full Локировка фирмы
&glob table_host-lk-full '{&bef-table_host-lk-full}':U
&glob bef-table_host-lk-attr-full Атрибуты для host-lk
&glob table_host-lk-attr-full '{&bef-table_host-lk-attr-full}':U
&glob bef-table_icnt-doc-full Документы  инв. счетчиков ТРК
&glob table_icnt-doc-full '{&bef-table_icnt-doc-full}':U
&glob bef-table_icnt-line-full Строки док. инв. счетчиков ТРК
&glob table_icnt-line-full '{&bef-table_icnt-line-full}':U
&glob bef-table_inkas-full Кассовый отчет(шапка); Выручка
&glob table_inkas-full '{&bef-table_inkas-full}':U
&glob bef-table_inkas-pay-full inkas по видам оплаты
&glob table_inkas-pay-full '{&bef-table_inkas-pay-full}':U
&glob bef-table_inkas-pay-attr-full Атрибуты для inkas-pay
&glob table_inkas-pay-attr-full '{&bef-table_inkas-pay-attr-full}':U
&glob bef-table_inkas-pay-desk-full Выручки по кассам
&glob table_inkas-pay-desk-full '{&bef-table_inkas-pay-desk-full}':U
&glob bef-table_inkas-pay-desk-attr-full Атрибуты для inkas-pay-desk
&glob table_inkas-pay-desk-attr-full '{&bef-table_inkas-pay-desk-attr-full}':U
&glob bef-table_inkas-pay-wth-full ink-pwth
&glob table_inkas-pay-wth-full '{&bef-table_inkas-pay-wth-full}':U
&glob bef-table_inv-doc-full inv-doc
&glob table_inv-doc-full '{&bef-table_inv-doc-full}':U
&glob bef-table_inv-doc-attr-full Атрибуты для inv-doc
&glob table_inv-doc-attr-full '{&bef-table_inv-doc-attr-full}':U
&glob bef-table_inv-line-full inv-line
&glob table_inv-line-full '{&bef-table_inv-line-full}':U
&glob bef-table_inv-line-attr-full Атрибуты для inv-line
&glob table_inv-line-attr-full '{&bef-table_inv-line-attr-full}':U
&glob bef-table_lang-full lang
&glob table_lang-full '{&bef-table_lang-full}':U
&glob bef-table_lang-attr-full Атрибуты для lang
&glob table_lang-attr-full '{&bef-table_lang-attr-full}':U
&glob bef-table_layout-full Раскладка интерфе/клавиатуры
&glob table_layout-full '{&bef-table_layout-full}':U
&glob bef-table_layout-attr-full Атрибуты раскладок
&glob table_layout-attr-full '{&bef-table_layout-attr-full}':U
&glob bef-table_layout-elem-full Элементы раскладки
&glob table_layout-elem-full '{&bef-table_layout-elem-full}':U
&glob bef-table_layout-elem-attr-full layout-elem-attr
&glob table_layout-elem-attr-full '{&bef-table_layout-elem-attr-full}':U
&glob bef-table_layout-elem-rule-full layout-elem-rule
&glob table_layout-elem-rule-full '{&bef-table_layout-elem-rule-full}':U
&glob bef-table_layout-elem-rule-attr-full Атрибуты линий раскладок
&glob table_layout-elem-rule-attr-full '{&bef-table_layout-elem-rule-attr-full}':U
&glob bef-table_lvl-name-full lvl-name
&glob table_lvl-name-full '{&bef-table_lvl-name-full}':U
&glob bef-table_lvl-name-attr-full Атрибуты для lvl-name
&glob table_lvl-name-attr-full '{&bef-table_lvl-name-attr-full}':U
&glob bef-table_marking-full marking
&glob table_marking-full '{&bef-table_marking-full}':U
&glob bef-table_marking-attr-full marking-attr
&glob table_marking-attr-full '{&bef-table_marking-attr-full}':U
&glob bef-table_marking-chk-full marking-chk
&glob table_marking-chk-full '{&bef-table_marking-chk-full}':U
&glob bef-table_marking-lines-full marking-lines
&glob table_marking-lines-full '{&bef-table_marking-lines-full}':U
&glob bef-table_menu-group-full menu-group
&glob table_menu-group-full '{&bef-table_menu-group-full}':U
&glob bef-table_menu-group-attr-full Атрибуты для menu-group
&glob table_menu-group-attr-full '{&bef-table_menu-group-attr-full}':U
&glob bef-table_menu-head-full menu-head
&glob table_menu-head-full '{&bef-table_menu-head-full}':U
&glob bef-table_menu-head-attr-full Атрибуты для menu-head
&glob table_menu-head-attr-full '{&bef-table_menu-head-attr-full}':U
&glob bef-table_menu-item-full menu-item
&glob table_menu-item-full '{&bef-table_menu-item-full}':U
&glob bef-table_menu-item-attr-full Атрибуты для menu-item
&glob table_menu-item-attr-full '{&bef-table_menu-item-attr-full}':U
&glob bef-table_menu-item-group-full menu-item-group
&glob table_menu-item-group-full '{&bef-table_menu-item-group-full}':U
&glob bef-table_menu-item-group-attr-full Атрибуты для menu-item-group
&glob table_menu-item-group-attr-full '{&bef-table_menu-item-group-attr-full}':U
&glob bef-table_menu-user-full menu-user
&glob table_menu-user-full '{&bef-table_menu-user-full}':U
&glob bef-table_menu-user-attr-full Атрибуты для menu-user
&glob table_menu-user-attr-full '{&bef-table_menu-user-attr-full}':U
&glob bef-table_menu-user-call-full menu-user-call
&glob table_menu-user-call-full '{&bef-table_menu-user-call-full}':U
&glob bef-table_menu-user-call-attr-full Атрибуты для menu-user-call
&glob table_menu-user-call-attr-full '{&bef-table_menu-user-call-attr-full}':U
&glob bef-table_norm-loss-full Норма технологических потерь
&glob table_norm-loss-full '{&bef-table_norm-loss-full}':U
&glob bef-table_nozzle-full Пистолет
&glob table_nozzle-full '{&bef-table_nozzle-full}':U
&glob bef-table_nozzle-attr-full Атрибут Пистолета
&glob table_nozzle-attr-full '{&bef-table_nozzle-attr-full}':U
&glob bef-table_nws-doc-hist-full nws-doc-hist
&glob table_nws-doc-hist-full '{&bef-table_nws-doc-hist-full}':U
&glob bef-table_nws-doc-hist-attr-full Атрибуты для nws-doc-hist
&glob table_nws-doc-hist-attr-full '{&bef-table_nws-doc-hist-attr-full}':U
&glob bef-table_nws-last-rec-full nws-last-rec
&glob table_nws-last-rec-full '{&bef-table_nws-last-rec-full}':U
&glob bef-table_nws-last-rec-attr-full Атрибуты для nws-last-rec
&glob table_nws-last-rec-attr-full '{&bef-table_nws-last-rec-attr-full}':U
&glob bef-table_nws-outline-full Разметка пакета СПН
&glob table_nws-outline-full '{&bef-table_nws-outline-full}':U
&glob bef-table_obj-date-full obj-date
&glob table_obj-date-full '{&bef-table_obj-date-full}':U
&glob bef-table_obj-grp-obj-price-full Объект в группе об. для ценооб
&glob table_obj-grp-obj-price-full '{&bef-table_obj-grp-obj-price-full}':U
&glob bef-table_obj-grp-obj-price-attr-full Атрибуты для obj-grp-obj-price
&glob table_obj-grp-obj-price-attr-full '{&bef-table_obj-grp-obj-price-attr-full}':U
&glob bef-table_OperServ-full Операторы
&glob table_OperServ-full '{&bef-table_OperServ-full}':U
&glob bef-table_OperServAttr-full атрибуты кассовой книги
&glob table_OperServAttr-full '{&bef-table_OperServAttr-full}':U
&glob bef-table_ord-blank-full Бланки заказов
&glob table_ord-blank-full '{&bef-table_ord-blank-full}':U
&glob bef-table_ord-blank-attr-full Атрибуты для ord-blank
&glob table_ord-blank-attr-full '{&bef-table_ord-blank-attr-full}':U
&glob bef-table_ord-chain-full Цепочки в заказах
&glob table_ord-chain-full '{&bef-table_ord-chain-full}':U
&glob bef-table_ord-chain-attr-full Атрибуты для ord-chain
&glob table_ord-chain-attr-full '{&bef-table_ord-chain-attr-full}':U
&glob bef-table_ord-cons-full Совокупный заказ
&glob table_ord-cons-full '{&bef-table_ord-cons-full}':U
&glob bef-table_ord-cons-attr-full Атрибуты СЗФП
&glob table_ord-cons-attr-full '{&bef-table_ord-cons-attr-full}':U
&glob bef-table_ord-cons-line-attr-full Атрибуты строки СЗФП
&glob table_ord-cons-line-attr-full '{&bef-table_ord-cons-line-attr-full}':U
&glob bef-table_ord-doc-full Заказы  поставщикам
&glob table_ord-doc-full '{&bef-table_ord-doc-full}':U
&glob bef-table_ord-doc-attr-full Атрибуты заказа
&glob table_ord-doc-attr-full '{&bef-table_ord-doc-attr-full}':U
&glob bef-table_ord-doc-rcv-full Поставки по заказам
&glob table_ord-doc-rcv-full '{&bef-table_ord-doc-rcv-full}':U
&glob bef-table_ord-dtl-full Признаки по товарам в заказах
&glob table_ord-dtl-full '{&bef-table_ord-dtl-full}':U
&glob bef-table_ord-dtl-attr-full Атрибуты для ord-dtl
&glob table_ord-dtl-attr-full '{&bef-table_ord-dtl-attr-full}':U
&glob bef-table_ord-dtl-cons-full Признаки совокупного заказа
&glob table_ord-dtl-cons-full '{&bef-table_ord-dtl-cons-full}':U
&glob bef-table_ord-dtl-rcv-full Поставки по признакам
&glob table_ord-dtl-rcv-full '{&bef-table_ord-dtl-rcv-full}':U
&glob bef-table_ord-gds-cons-full Товары совокупного заказа
&glob table_ord-gds-cons-full '{&bef-table_ord-gds-cons-full}':U
&glob bef-table_ord-line-full строка заказа
&glob table_ord-line-full '{&bef-table_ord-line-full}':U
&glob bef-table_ord-line-attr-full Атрибуты строки заказа
&glob table_ord-line-attr-full '{&bef-table_ord-line-attr-full}':U
&glob bef-table_ord-line-rcv-full Поставка по товарам
&glob table_ord-line-rcv-full '{&bef-table_ord-line-rcv-full}':U
&glob bef-table_ord-rcv-attr-full Атрибуты поставки
&glob table_ord-rcv-attr-full '{&bef-table_ord-rcv-attr-full}':U
&glob bef-table_ord-rcv-line-attr-full Атрибуты строки поставки
&glob table_ord-rcv-line-attr-full '{&bef-table_ord-rcv-line-attr-full}':U
&glob bef-table_ot-line-full ot-line
&glob table_ot-line-full '{&bef-table_ot-line-full}':U
&glob bef-table_ot-line-attr-full Атрибуты для ot-line
&glob table_ot-line-attr-full '{&bef-table_ot-line-attr-full}':U
&glob bef-table_ot-supp-line-full ot-supp-line
&glob table_ot-supp-line-full '{&bef-table_ot-supp-line-full}':U
&glob bef-table_ot-supp-line-attr-full Атрибуты для ot-supp-line
&glob table_ot-supp-line-attr-full '{&bef-table_ot-supp-line-attr-full}':U
&glob bef-table_ot-supp-tot-full ot-supp-tot
&glob table_ot-supp-tot-full '{&bef-table_ot-supp-tot-full}':U
&glob bef-table_ot-supp-tot-attr-full Атрибуты для ot-supp-tot
&glob table_ot-supp-tot-attr-full '{&bef-table_ot-supp-tot-attr-full}':U
&glob bef-table_ot-tot-full ot-tot
&glob table_ot-tot-full '{&bef-table_ot-tot-full}':U
&glob bef-table_ot-tot-attr-full Атрибуты для ot-tot
&glob table_ot-tot-attr-full '{&bef-table_ot-tot-attr-full}':U
&glob bef-table_parts-full parts
&glob table_parts-full '{&bef-table_parts-full}':U
&glob bef-table_parts-add-full Сумма доп.расхода в учет.цене
&glob table_parts-add-full '{&bef-table_parts-add-full}':U
&glob bef-table_parts-add-attr-full Атрибуты для parts-add
&glob table_parts-add-attr-full '{&bef-table_parts-add-attr-full}':U
&glob bef-table_parts-attr-full Атрибуты партии
&glob table_parts-attr-full '{&bef-table_parts-attr-full}':U
&glob bef-table_parts-obj-attr-full Атрибуты партий
&glob table_parts-obj-attr-full '{&bef-table_parts-obj-attr-full}':U
&glob bef-table_parts-root-full Порождающие партии
&glob table_parts-root-full '{&bef-table_parts-root-full}':U
&glob bef-table_parts-root-attr-full Атрибуты для parts-root
&glob table_parts-root-attr-full '{&bef-table_parts-root-attr-full}':U
&glob bef-table_parts-supp-full parts-supp
&glob table_parts-supp-full '{&bef-table_parts-supp-full}':U
&glob bef-table_parts-supp-attr-full Атрибуты для parts-supp
&glob table_parts-supp-attr-full '{&bef-table_parts-supp-attr-full}':U
&glob bef-table_pay-type-full pay-type
&glob table_pay-type-full '{&bef-table_pay-type-full}':U
&glob bef-table_pay-type-attr-full Атрибуты для pay-type
&glob table_pay-type-attr-full '{&bef-table_pay-type-attr-full}':U
&glob bef-table_payment-full payment
&glob table_payment-full '{&bef-table_payment-full}':U
&glob bef-table_payment-attr-full Атрибуты для payment
&glob table_payment-attr-full '{&bef-table_payment-attr-full}':U
&glob bef-table_pck-keys-full Ключи
&glob table_pck-keys-full '{&bef-table_pck-keys-full}':U
&glob bef-table_pck-rcvd-full pck-rcvd
&glob table_pck-rcvd-full '{&bef-table_pck-rcvd-full}':U
&glob bef-table_pck-rcvd-attr-full Атрибуты для pck-rcvd
&glob table_pck-rcvd-attr-full '{&bef-table_pck-rcvd-attr-full}':U
&glob bef-table_pck-sent-full pck-sent
&glob table_pck-sent-full '{&bef-table_pck-sent-full}':U
&glob bef-table_pck-sent-attr-full Атрибуты для pck-sent
&glob table_pck-sent-attr-full '{&bef-table_pck-sent-attr-full}':U
&glob bef-table_person-full Физ.лицо
&glob table_person-full '{&bef-table_person-full}':U
&glob bef-table_pl-gds-full Товар на складском месте
&glob table_pl-gds-full '{&bef-table_pl-gds-full}':U
&glob bef-table_pl-gds-attr-full АттрТовара на скл.месте
&glob table_pl-gds-attr-full '{&bef-table_pl-gds-attr-full}':U
&glob bef-table_pl-gds-pump-full Товар на ТРК
&glob table_pl-gds-pump-full '{&bef-table_pl-gds-pump-full}':U
&glob bef-table_pl-gds-pump-attr-full Атрибуты для pl-gds-pump
&glob table_pl-gds-pump-attr-full '{&bef-table_pl-gds-pump-attr-full}':U
&glob bef-table_pl-level-full Градуировочная табл. резервуар
&glob table_pl-level-full '{&bef-table_pl-level-full}':U
&glob bef-table_pl-level-attr-full Атрибуты для pl-level
&glob table_pl-level-attr-full '{&bef-table_pl-level-attr-full}':U
&glob bef-table_pl-pump-full Резервуар/ТРК
&glob table_pl-pump-full '{&bef-table_pl-pump-full}':U
&glob bef-table_pl-pump-attr-full Атрибуты для pl-pump
&glob table_pl-pump-attr-full '{&bef-table_pl-pump-attr-full}':U
&glob bef-table_pl-pump-nozzle-full Резервуар/ТРК/Пистолет
&glob table_pl-pump-nozzle-full '{&bef-table_pl-pump-nozzle-full}':U
&glob bef-table_pl-pump-nozzle-attr-full Атрибуты для pl-pump-nozzle
&glob table_pl-pump-nozzle-attr-full '{&bef-table_pl-pump-nozzle-attr-full}':U
&glob bef-table_place-full Складское место
&glob table_place-full '{&bef-table_place-full}':U
&glob bef-table_place-attr-full Атрибут Скл. места
&glob table_place-attr-full '{&bef-table_place-attr-full}':U
&glob bef-table_place-io-full place-io
&glob table_place-io-full '{&bef-table_place-io-full}':U
&glob bef-table_place-io-attr-full Атрибуты для place-io
&glob table_place-io-attr-full '{&bef-table_place-io-attr-full}':U
&glob bef-table_point-io-full point-io
&glob table_point-io-full '{&bef-table_point-io-full}':U
&glob bef-table_point-io-attr-full Атрибуты для point-io
&glob table_point-io-attr-full '{&bef-table_point-io-attr-full}':U
&glob bef-table_point-place-rel-full Транс.связи Объект. и Контраг.
&glob table_point-place-rel-full '{&bef-table_point-place-rel-full}':U
&glob bef-table_point-point-rel-full Пункт-Пункт
&glob table_point-point-rel-full '{&bef-table_point-point-rel-full}':U
&glob bef-table_price-all-full Денорм. таб. для счит. цен
&glob table_price-all-full '{&bef-table_price-all-full}':U
&glob bef-table_price-all-attr-full Атрибуты для price-all
&glob table_price-all-attr-full '{&bef-table_price-all-attr-full}':U
&glob bef-table_price-doc-full price-doc
&glob table_price-doc-full '{&bef-table_price-doc-full}':U
&glob bef-table_price-doc-forming-full Документ формирования цены
&glob table_price-doc-forming-full '{&bef-table_price-doc-forming-full}':U
&glob bef-table_price-doc-forming-attr-full Атрибуты док. форм. цены
&glob table_price-doc-forming-attr-full '{&bef-table_price-doc-forming-attr-full}':U
&glob bef-table_price-doc-forming-gds-full Товар в док-те форм-ия цены
&glob table_price-doc-forming-gds-full '{&bef-table_price-doc-forming-gds-full}':U
&glob bef-table_price-doc-forming-gds-qnty-full Товар в док форм цены по кол
&glob table_price-doc-forming-gds-qnty-full '{&bef-table_price-doc-forming-gds-qnty-full}':U
&glob bef-table_price-doc-forming-gds-sum-full Товар в док форм цены по сумме
&glob table_price-doc-forming-gds-sum-full '{&bef-table_price-doc-forming-gds-sum-full}':U
&glob bef-table_price-doc-forming-gds-tnv-full Товар в док форм цены по обор
&glob table_price-doc-forming-gds-tnv-full '{&bef-table_price-doc-forming-gds-tnv-full}':U
&glob bef-table_price-doc-forming-gdsattr-full Атрибуты строки ДНЦ
&glob table_price-doc-forming-gdsattr-full '{&bef-table_price-doc-forming-gdsattr-full}':U
&glob bef-table_price-list-full price-list
&glob table_price-list-full '{&bef-table_price-list-full}':U
&glob bef-table_price-list-attr-full Атрибуты переоценки
&glob table_price-list-attr-full '{&bef-table_price-list-attr-full}':U
&glob bef-table_price-list-type-full price-list-type
&glob table_price-list-type-full '{&bef-table_price-list-type-full}':U
&glob bef-table_price-list-type-attr-full Атрибуты типа прайс-листа
&glob table_price-list-type-attr-full '{&bef-table_price-list-type-attr-full}':U
&glob bef-table_price-list-type-cash-pay-full Огран.тип.пр.-л.по тип.кас.пл
&glob table_price-list-type-cash-pay-full '{&bef-table_price-list-type-cash-pay-full}':U
&glob bef-table_price-list-type-cassa-full Связь типа прайс-листа с касса
&glob table_price-list-type-cassa-full '{&bef-table_price-list-type-cassa-full}':U
&glob bef-table_price-list-type-cassa-attr-full Атрибуты для price-list-type-cassa
&glob table_price-list-type-cassa-attr-full '{&bef-table_price-list-type-cassa-attr-full}':U
&glob bef-table_price-list-type-gds-grp-full Огранич. типа пл по груп тов.
&glob table_price-list-type-gds-grp-full '{&bef-table_price-list-type-gds-grp-full}':U
&glob bef-table_price-list-type-gds-grp-attr-full Атрибуты для price-list-type-gds-grp
&glob table_price-list-type-gds-grp-attr-full '{&bef-table_price-list-type-gds-grp-attr-full}':U
&glob bef-table_price-list-type-pay-type-full Огран. т. пр-л. по типам плат.
&glob table_price-list-type-pay-type-full '{&bef-table_price-list-type-pay-type-full}':U
&glob bef-table_prod-bc-full ДопБК
&glob table_prod-bc-full '{&bef-table_prod-bc-full}':U
&glob bef-table_prod-bc-attr-full Атрибуты ДопБК
&glob table_prod-bc-attr-full '{&bef-table_prod-bc-attr-full}':U
&glob bef-table_prod-bc-db-full Бар-коды по базе данных
&glob table_prod-bc-db-full '{&bef-table_prod-bc-db-full}':U
&glob bef-table_prod-bc-db-attr-full Атрибуты для prod-bc-db
&glob table_prod-bc-db-attr-full '{&bef-table_prod-bc-db-attr-full}':U
&glob bef-table_profile-by-profile-full Привязка профайлов к профайлу
&glob table_profile-by-profile-full '{&bef-table_profile-by-profile-full}':U
&glob bef-table_prog-message-full prog-message
&glob table_prog-message-full '{&bef-table_prog-message-full}':U
&glob bef-table_prog-message-attr-full Атрибуты для prog-message
&glob table_prog-message-attr-full '{&bef-table_prog-message-attr-full}':U
&glob bef-table_prog-message-lang-full prog-message-lang
&glob table_prog-message-lang-full '{&bef-table_prog-message-lang-full}':U
&glob bef-table_prog-message-lang-attr-full Атрибуты для prog-message-lang
&glob table_prog-message-lang-attr-full '{&bef-table_prog-message-lang-attr-full}':U
&glob bef-table_promo-schedule-full promosche
&glob table_promo-schedule-full '{&bef-table_promo-schedule-full}':U
&glob bef-table_promo-schedule-week-full promo-schedule-week
&glob table_promo-schedule-week-full '{&bef-table_promo-schedule-week-full}':U
&glob bef-table_PromoAction-full Акции
&glob table_PromoAction-full '{&bef-table_PromoAction-full}':U
&glob bef-table_PromoAttr-full атрибуты акций
&glob table_PromoAttr-full '{&bef-table_PromoAttr-full}':U
&glob bef-table_PromoCriterion-full Критерии
&glob table_PromoCriterion-full '{&bef-table_PromoCriterion-full}':U
&glob bef-table_PromoGift-full PromoGift
&glob table_PromoGift-full '{&bef-table_PromoGift-full}':U
&glob bef-table_PromoGoods-full товары критерия акции
&glob table_PromoGoods-full '{&bef-table_PromoGoods-full}':U
&glob bef-table_PromoObject-full объекты акции
&glob table_PromoObject-full '{&bef-table_PromoObject-full}':U
&glob bef-table_prop-head-full Объекты-операнды машины правил
&glob table_prop-head-full '{&bef-table_prop-head-full}':U
&glob bef-table_prop-head-attr-full Атрибуты для prop-head
&glob table_prop-head-attr-full '{&bef-table_prop-head-attr-full}':U
&glob bef-table_prop-map-full Структура свойств данных
&glob table_prop-map-full '{&bef-table_prop-map-full}':U
&glob bef-table_prop-map-attr-full Атрибуты для prop-map
&glob table_prop-map-attr-full '{&bef-table_prop-map-attr-full}':U
&glob bef-table_prop-ref-full Типы срезов хранилища
&glob table_prop-ref-full '{&bef-table_prop-ref-full}':U
&glob bef-table_prop-ref-attr-full Атрибуты для prop-ref
&glob table_prop-ref-attr-full '{&bef-table_prop-ref-attr-full}':U
&glob bef-table_prop-ref-call-full Привязка срезу к точке вызова
&glob table_prop-ref-call-full '{&bef-table_prop-ref-call-full}':U
&glob bef-table_prop-ref-call-attr-full Атрибуты для prop-ref-call
&glob table_prop-ref-call-attr-full '{&bef-table_prop-ref-call-attr-full}':U
&glob bef-table_prop-ruleset-full Объекты - наборы правил
&glob table_prop-ruleset-full '{&bef-table_prop-ruleset-full}':U
&glob bef-table_prop-ruleset-attr-full Атрибуты для prop-ruleset
&glob table_prop-ruleset-attr-full '{&bef-table_prop-ruleset-attr-full}':U
&glob bef-table_prop-script-full Скрипты RULE-машины
&glob table_prop-script-full '{&bef-table_prop-script-full}':U
&glob bef-table_prop-script-attr-full Атрибуты для prop-script
&glob table_prop-script-attr-full '{&bef-table_prop-script-attr-full}':U
&glob bef-table_prt-obj-full prt-obj
&glob table_prt-obj-full '{&bef-table_prt-obj-full}':U
&glob bef-table_prt-obj-attr-full Атрибуты для prt-obj
&glob table_prt-obj-attr-full '{&bef-table_prt-obj-attr-full}':U
&glob bef-table_pscript-ruleset-full Свойства объ.<->набор правил
&glob table_pscript-ruleset-full '{&bef-table_pscript-ruleset-full}':U
&glob bef-table_pscript-ruleset-attr-full Атрибуты для pscript-ruleset
&glob table_pscript-ruleset-attr-full '{&bef-table_pscript-ruleset-attr-full}':U
&glob bef-table_pump-full ТРК
&glob table_pump-full '{&bef-table_pump-full}':U
&glob bef-table_pump-attr-full Атрибут ТРК
&glob table_pump-attr-full '{&bef-table_pump-attr-full}':U
&glob bef-table_pump-nozzle-full ТРК/Пистолет
&glob table_pump-nozzle-full '{&bef-table_pump-nozzle-full}':U
&glob bef-table_pump-nozzle-attr-full Атрибуты для pump-nozzle
&glob table_pump-nozzle-attr-full '{&bef-table_pump-nozzle-attr-full}':U
&glob bef-table_qnty-group-full Количественная группа
&glob table_qnty-group-full '{&bef-table_qnty-group-full}':U
&glob bef-table_qnty-group-attr-full Атрибуты для qnty-group
&glob table_qnty-group-attr-full '{&bef-table_qnty-group-attr-full}':U
&glob bef-table_qnty-in-qnty-group-full Количества в кол-ой группе
&glob table_qnty-in-qnty-group-full '{&bef-table_qnty-in-qnty-group-full}':U
&glob bef-table_qnty-in-qnty-group-attr-full Атрибуты для qnty-in-qnty-group
&glob table_qnty-in-qnty-group-attr-full '{&bef-table_qnty-in-qnty-group-attr-full}':U
&glob bef-table_rang-abc-def-full Ранжирование ABC анализа по ум
&glob table_rang-abc-def-full '{&bef-table_rang-abc-def-full}':U
&glob bef-table_rang-abc-def-attr-full Атрибуты для rang-abc-def
&glob table_rang-abc-def-attr-full '{&bef-table_rang-abc-def-attr-full}':U
&glob bef-table_rang-abc-def-obj-full Об.для записи ранж.ABC анал.ум
&glob table_rang-abc-def-obj-full '{&bef-table_rang-abc-def-obj-full}':U
&glob bef-table_rang-abc-def-obj-attr-full Атрибуты для rang-abc-def-obj
&glob table_rang-abc-def-obj-attr-full '{&bef-table_rang-abc-def-obj-attr-full}':U
&glob bef-table_rang-xyz-def-full Спр. ранж. XYZ по умолчанию
&glob table_rang-xyz-def-full '{&bef-table_rang-xyz-def-full}':U
&glob bef-table_rang-xyz-def-attr-full Атрибуты для rang-xyz-def
&glob table_rang-xyz-def-attr-full '{&bef-table_rang-xyz-def-attr-full}':U
&glob bef-table_rang-xyz-def-obj-full Об. для зап. ранжир. XYZ анали
&glob table_rang-xyz-def-obj-full '{&bef-table_rang-xyz-def-obj-full}':U
&glob bef-table_rang-xyz-def-obj-attr-full Атрибуты для rang-xyz-def-obj
&glob table_rang-xyz-def-obj-attr-full '{&bef-table_rang-xyz-def-obj-attr-full}':U
&glob bef-table_rcs-attr-full Тип атрибута retail1_attr
&glob table_rcs-attr-full '{&bef-table_rcs-attr-full}':U
&glob bef-table_rcs-chkbody-full Строки чеков
&glob table_rcs-chkbody-full '{&bef-table_rcs-chkbody-full}':U
&glob bef-table_rcs-chkhead-full Чеки
&glob table_rcs-chkhead-full '{&bef-table_rcs-chkhead-full}':U
&glob bef-table_rcs-city-full Справочник городов
&glob table_rcs-city-full '{&bef-table_rcs-city-full}':U
&glob bef-table_rcs-clients-full Производитель
&glob table_rcs-clients-full '{&bef-table_rcs-clients-full}':U
&glob bef-table_rcs-country-full Справочник стран
&glob table_rcs-country-full '{&bef-table_rcs-country-full}':U
&glob bef-table_rcs-destn-full Объекты (сущности)
&glob table_rcs-destn-full '{&bef-table_rcs-destn-full}':U
&glob bef-table_rcs-docbody-full Строки розничных документов
&glob table_rcs-docbody-full '{&bef-table_rcs-docbody-full}':U
&glob bef-table_rcs-dochead-full Розничные документы
&glob table_rcs-dochead-full '{&bef-table_rcs-dochead-full}':U
&glob bef-table_rcs-mark-full Справочник маркировок
&glob table_rcs-mark-full '{&bef-table_rcs-mark-full}':U
&glob bef-table_rcs-pack-full Справочник упаковок
&glob table_rcs-pack-full '{&bef-table_rcs-pack-full}':U
&glob bef-table_rcs-place-full Справочник мест хранения
&glob table_rcs-place-full '{&bef-table_rcs-place-full}':U
&glob bef-table_rcs-retail1action-full Розничные акции
&glob table_rcs-retail1action-full '{&bef-table_rcs-retail1action-full}':U
&glob bef-table_rcs-retail1attr-full Розничные справочники
&glob table_rcs-retail1attr-full '{&bef-table_rcs-retail1attr-full}':U
&glob bef-table_rcs-retail1bank-full Банки
&glob table_rcs-retail1bank-full '{&bef-table_rcs-retail1bank-full}':U
&glob bef-table_rcs-retail1barcode-full Штрих коды
&glob table_rcs-retail1barcode-full '{&bef-table_rcs-retail1barcode-full}':U
&glob bef-table_rcs-retail1bill-full Документ отгрузки в магазин
&glob table_rcs-retail1bill-full '{&bef-table_rcs-retail1bill-full}':U
&glob bef-table_rcs-retail1billitem-full Атрибуты отгрузки в магазины
&glob table_rcs-retail1billitem-full '{&bef-table_rcs-retail1billitem-full}':U
&glob bef-table_rcs-retail1convolution-full Свертка
&glob table_rcs-retail1convolution-full '{&bef-table_rcs-retail1convolution-full}':U
&glob bef-table_rcs-retail1delete-full Удаление
&glob table_rcs-retail1delete-full '{&bef-table_rcs-retail1delete-full}':U
&glob bef-table_rcs-retail1fortuneproduct-full Товары для розничных акций
&glob table_rcs-retail1fortuneproduct-full '{&bef-table_rcs-retail1fortuneproduct-full}':U
&glob bef-table_rcs-retail1price-full Розничный прайс
&glob table_rcs-retail1price-full '{&bef-table_rcs-retail1price-full}':U
&glob bef-table_rcs-retail1priceitem-full Строки розничного прайса
&glob table_rcs-retail1priceitem-full '{&bef-table_rcs-retail1priceitem-full}':U
&glob bef-table_rcs-retail1product-full Розничные товары
&glob table_rcs-retail1product-full '{&bef-table_rcs-retail1product-full}':U
&glob bef-table_rcs-retail1subject-full Контрагенты
&glob table_rcs-retail1subject-full '{&bef-table_rcs-retail1subject-full}':U
&glob bef-table_rcs-shops-full Магазины
&glob table_rcs-shops-full '{&bef-table_rcs-shops-full}':U
&glob bef-table_recipe-full Рецепт
&glob table_recipe-full '{&bef-table_recipe-full}':U
&glob bef-table_recipe-develop-full recipe-develop
&glob table_recipe-develop-full '{&bef-table_recipe-develop-full}':U
&glob bef-table_recipe-gds-full Товар рецепта
&glob table_recipe-gds-full '{&bef-table_recipe-gds-full}':U
&glob bef-table_regions-full regions
&glob table_regions-full '{&bef-table_regions-full}':U
&glob bef-table_regions-attr-full Атрибуты для regions
&glob table_regions-attr-full '{&bef-table_regions-attr-full}':U
&glob bef-table_rename-fld-full переименование полей
&glob table_rename-fld-full '{&bef-table_rename-fld-full}':U
&glob bef-table_rename-fld-attr-full Атрибуты для rename-fld
&glob table_rename-fld-attr-full '{&bef-table_rename-fld-attr-full}':U
&glob bef-table_rep-full rep
&glob table_rep-full '{&bef-table_rep-full}':U
&glob bef-table_rep-line-full rep-line
&glob table_rep-line-full '{&bef-table_rep-line-full}':U
&glob bef-table_res-lang-full res-lang
&glob table_res-lang-full '{&bef-table_res-lang-full}':U
&glob bef-table_res-lang-attr-full Атрибуты для res-lang
&glob table_res-lang-attr-full '{&bef-table_res-lang-attr-full}':U
&glob bef-table_resource-full resource
&glob table_resource-full '{&bef-table_resource-full}':U
&glob bef-table_resource-attr-full Атрибуты для resource
&glob table_resource-attr-full '{&bef-table_resource-attr-full}':U
&glob bef-table_route-full route
&glob table_route-full '{&bef-table_route-full}':U
&glob bef-table_route-attr-full Атрибуты для route
&glob table_route-attr-full '{&bef-table_route-attr-full}':U
&glob bef-table_route-dump-full route-dump
&glob table_route-dump-full '{&bef-table_route-dump-full}':U
&glob bef-table_route-dump-attr-full Атрибуты для route-dump
&glob table_route-dump-attr-full '{&bef-table_route-dump-attr-full}':U
&glob bef-table_route-dump-link-full route-dump-link
&glob table_route-dump-link-full '{&bef-table_route-dump-link-full}':U
&glob bef-table_rp-by-call-full Привязка профайла к месту
&glob table_rp-by-call-full '{&bef-table_rp-by-call-full}':U
&glob bef-table_rp-by-call-attr-full Атрибуты для rp-by-call
&glob table_rp-by-call-attr-full '{&bef-table_rp-by-call-attr-full}':U
&glob bef-table_rp-rule-param-full Параметры профайла-правила
&glob table_rp-rule-param-full '{&bef-table_rp-rule-param-full}':U
&glob bef-table_rp-rule-param-attr-full Атрибуты для rp-rule-param
&glob table_rp-rule-param-attr-full '{&bef-table_rp-rule-param-attr-full}':U
&glob bef-table_rpt-option-full rpt-option
&glob table_rpt-option-full '{&bef-table_rpt-option-full}':U
&glob bef-table_rpt-option-attr-full Атрибуты для rpt-option
&glob table_rpt-option-attr-full '{&bef-table_rpt-option-attr-full}':U
&glob bef-table_rule-full Правила RULE-машины
&glob table_rule-full '{&bef-table_rule-full}':U
&glob bef-table_rule-attr-full Атрибуты для rule
&glob table_rule-attr-full '{&bef-table_rule-attr-full}':U
&glob bef-table_rule-by-call-full Вызов правила
&glob table_rule-by-call-full '{&bef-table_rule-by-call-full}':U
&glob bef-table_rule-by-call-attr-full Атрибуты для rule-by-call
&glob table_rule-by-call-attr-full '{&bef-table_rule-by-call-attr-full}':U
&glob bef-table_rule-by-profile-full Привязка правил к профайлу
&glob table_rule-by-profile-full '{&bef-table_rule-by-profile-full}':U
&glob bef-table_rule-by-profile-attr-full Атрибуты для rule-by-profile
&glob table_rule-by-profile-attr-full '{&bef-table_rule-by-profile-attr-full}':U
&glob bef-table_rule-by-set-full Привязка правил к наборам
&glob table_rule-by-set-full '{&bef-table_rule-by-set-full}':U
&glob bef-table_rule-by-set-attr-full Атрибуты для rule-by-set
&glob table_rule-by-set-attr-full '{&bef-table_rule-by-set-attr-full}':U
&glob bef-table_rule-call-param-full Параметры вызова правил
&glob table_rule-call-param-full '{&bef-table_rule-call-param-full}':U
&glob bef-table_rule-call-param-attr-full Атрибуты для rule-call-param
&glob table_rule-call-param-attr-full '{&bef-table_rule-call-param-attr-full}':U
&glob bef-table_rule-i-script-full Скрипт объекта-правило
&glob table_rule-i-script-full '{&bef-table_rule-i-script-full}':U
&glob bef-table_rule-i-script-attr-full Атрибуты для rule-i-script
&glob table_rule-i-script-attr-full '{&bef-table_rule-i-script-attr-full}':U
&glob bef-table_rule-process-full Звено процесса
&glob table_rule-process-full '{&bef-table_rule-process-full}':U
&glob bef-table_rule-profile-full Профайлы правил
&glob table_rule-profile-full '{&bef-table_rule-profile-full}':U
&glob bef-table_rule-profile-attr-full Атрибуты для rule-profile
&glob table_rule-profile-attr-full '{&bef-table_rule-profile-attr-full}':U
&glob bef-table_rule-script-full Текст правил
&glob table_rule-script-full '{&bef-table_rule-script-full}':U
&glob bef-table_rule-script-attr-full Атрибуты для rule-script
&glob table_rule-script-attr-full '{&bef-table_rule-script-attr-full}':U
&glob bef-table_rule-trans-memo-full Протокол работы правила
&glob table_rule-trans-memo-full '{&bef-table_rule-trans-memo-full}':U
&glob bef-table_rule-trans-memo-attr-full Атрибуты для rule-trans-memo
&glob table_rule-trans-memo-attr-full '{&bef-table_rule-trans-memo-attr-full}':U
&glob bef-table_ruledict-full Словарь RULE-машины
&glob table_ruledict-full '{&bef-table_ruledict-full}':U
&glob bef-table_ruledict-attr-full Атрибуты для ruledict
&glob table_ruledict-attr-full '{&bef-table_ruledict-attr-full}':U
&glob bef-table_ruledict-param-full Параметры статей словаря правил
&glob table_ruledict-param-full '{&bef-table_ruledict-param-full}':U
&glob bef-table_ruledict-param-attr-full Атрибуты для ruledict-param
&glob table_ruledict-param-attr-full '{&bef-table_ruledict-param-attr-full}':U
&glob bef-table_ruleset-full Кодексы и наборы правил
&glob table_ruleset-full '{&bef-table_ruleset-full}':U
&glob bef-table_ruleset-attr-full Атрибуты для ruleset
&glob table_ruleset-attr-full '{&bef-table_ruleset-attr-full}':U
&glob bef-table_rvs-doc-full rvs-doc
&glob table_rvs-doc-full '{&bef-table_rvs-doc-full}':U
&glob bef-table_rvs-doc-attr-full Атрибуты для rvs-doc
&glob table_rvs-doc-attr-full '{&bef-table_rvs-doc-attr-full}':U
&glob bef-table_rvs-line-full rvs-line
&glob table_rvs-line-full '{&bef-table_rvs-line-full}':U
&glob bef-table_rvs-line-attr-full Атрибуты для rvs-line
&glob table_rvs-line-attr-full '{&bef-table_rvs-line-attr-full}':U
&glob bef-table_rvs-line-pump-full Информация с ТРК
&glob table_rvs-line-pump-full '{&bef-table_rvs-line-pump-full}':U
&glob bef-table_rvs-line-pump-attr-full Атрибуты для rvs-line-pump
&glob table_rvs-line-pump-attr-full '{&bef-table_rvs-line-pump-attr-full}':U
&glob bef-table_rvs-pump-full Информация с ТРК
&glob table_rvs-pump-full '{&bef-table_rvs-pump-full}':U
&glob bef-table_rvs-pump-attr-full Атрибуты для rvs-pump
&glob table_rvs-pump-attr-full '{&bef-table_rvs-pump-attr-full}':U
&glob bef-table_s-coeff-full Сезонный коэфф
&glob table_s-coeff-full '{&bef-table_s-coeff-full}':U
&glob bef-table_s-coeff-attr-full Атрибуты для s-coeff
&glob table_s-coeff-attr-full '{&bef-table_s-coeff-attr-full}':U
&glob bef-table_sale-doc-full Документы продажи
&glob table_sale-doc-full '{&bef-table_sale-doc-full}':U
&glob bef-table_sale-doc-attr-full Атрибуты для sale-doc
&glob table_sale-doc-attr-full '{&bef-table_sale-doc-attr-full}':U
&glob bef-table_scales-full Весы
&glob table_scales-full '{&bef-table_scales-full}':U
&glob bef-table_scales-attr-full Атрибут весов
&glob table_scales-attr-full '{&bef-table_scales-attr-full}':U
&glob bef-table_scales-gds-full Товар на весах
&glob table_scales-gds-full '{&bef-table_scales-gds-full}':U
&glob bef-table_scales-gds-attr-full Атрибуты для scales-gds
&glob table_scales-gds-attr-full '{&bef-table_scales-gds-attr-full}':U
&glob bef-table_scales-grp-full Группы товаров на весах
&glob table_scales-grp-full '{&bef-table_scales-grp-full}':U
&glob bef-table_scales-grp-attr-full Атрибуты для scales-grp
&glob table_scales-grp-attr-full '{&bef-table_scales-grp-attr-full}':U
&glob bef-table_schedule-full schedule
&glob table_schedule-full '{&bef-table_schedule-full}':U
&glob bef-table_schedule-attr-full schedule-attr
&glob table_schedule-attr-full '{&bef-table_schedule-attr-full}':U
&glob bef-table_schet-fact-doc-full schet-fact-doc
&glob table_schet-fact-doc-full '{&bef-table_schet-fact-doc-full}':U
&glob bef-table_schet-fact-doc-attr-full Атрибуты для schet-fact-doc
&glob table_schet-fact-doc-attr-full '{&bef-table_schet-fact-doc-attr-full}':U
&glob bef-table_schet-fact-line-full schet-fact-line
&glob table_schet-fact-line-full '{&bef-table_schet-fact-line-full}':U
&glob bef-table_schet-fact-line-attr-full Атрибуты для schet-fact-line
&glob table_schet-fact-line-attr-full '{&bef-table_schet-fact-line-attr-full}':U
&glob bef-table_season-full Сезоны
&glob table_season-full '{&bef-table_season-full}':U
&glob bef-table_season-attr-full Атрибуты для season
&glob table_season-attr-full '{&bef-table_season-attr-full}':U
&glob bef-table_sert-full Сертификат
&glob table_sert-full '{&bef-table_sert-full}':U
&glob bef-table_sert-attr-full Атрибуты для sert
&glob table_sert-attr-full '{&bef-table_sert-attr-full}':U
&glob bef-table_sert-join-full Сертификат на товар
&glob table_sert-join-full '{&bef-table_sert-join-full}':U
&glob bef-table_sert-join-attr-full Атрибуты для sert-join
&glob table_sert-join-attr-full '{&bef-table_sert-join-attr-full}':U
&glob bef-table_shift-attr-full Атрибуты смены
&glob table_shift-attr-full '{&bef-table_shift-attr-full}':U
&glob bef-table_shift-cash-full shift-cash
&glob table_shift-cash-full '{&bef-table_shift-cash-full}':U
&glob bef-table_shift-cash-attr-full Атрибуты для shift-cash
&glob table_shift-cash-attr-full '{&bef-table_shift-cash-attr-full}':U
&glob bef-table_shift-obj-full Смена
&glob table_shift-obj-full '{&bef-table_shift-obj-full}':U
&glob bef-table_shift-obj-attr-full Атрибуты для shift-obj
&glob table_shift-obj-attr-full '{&bef-table_shift-obj-attr-full}':U
&glob bef-table_shift-staff-full Персонал смены
&glob table_shift-staff-full '{&bef-table_shift-staff-full}':U
&glob bef-table_shift-staff-attr-full Атрибуты для shift-staff
&glob table_shift-staff-attr-full '{&bef-table_shift-staff-attr-full}':U
&glob bef-table_shop-full Магазин
&glob table_shop-full '{&bef-table_shop-full}':U
&glob bef-table_some-lk-full Долговремен.блокировка
&glob table_some-lk-full '{&bef-table_some-lk-full}':U
&glob bef-table_some-lk-attr-full Атрибуты для some-lk
&glob table_some-lk-attr-full '{&bef-table_some-lk-attr-full}':U
&glob bef-table_sr-izmerenia-full sr-izmerenia
&glob table_sr-izmerenia-full '{&bef-table_sr-izmerenia-full}':U
&glob bef-table_sr-izmerenia-attr-full sr-izmerenia-attr
&glob table_sr-izmerenia-attr-full '{&bef-table_sr-izmerenia-attr-full}':U
&glob bef-table_staff-full Персонал
&glob table_staff-full '{&bef-table_staff-full}':U
&glob bef-table_staff-attr-full Атрибуты для staff
&glob table_staff-attr-full '{&bef-table_staff-attr-full}':U
&glob bef-table_stk-line-full stk-line
&glob table_stk-line-full '{&bef-table_stk-line-full}':U
&glob bef-table_stk-line-attr-full Атрибуты для stk-line
&glob table_stk-line-attr-full '{&bef-table_stk-line-attr-full}':U
&glob bef-table_stk-supp-line-full stk-supp-line
&glob table_stk-supp-line-full '{&bef-table_stk-supp-line-full}':U
&glob bef-table_stk-supp-line-attr-full Атрибуты для stk-supp-line
&glob table_stk-supp-line-attr-full '{&bef-table_stk-supp-line-attr-full}':U
&glob bef-table_stk-supp-tot-full stk-supp-tot
&glob table_stk-supp-tot-full '{&bef-table_stk-supp-tot-full}':U
&glob bef-table_stk-supp-tot-attr-full Атрибуты для stk-supp-tot
&glob table_stk-supp-tot-attr-full '{&bef-table_stk-supp-tot-attr-full}':U
&glob bef-table_stk-tot-full stk-tot
&glob table_stk-tot-full '{&bef-table_stk-tot-full}':U
&glob bef-table_stk-tot-attr-full Атрибуты для stk-tot
&glob table_stk-tot-attr-full '{&bef-table_stk-tot-attr-full}':U
&glob bef-table_stop-list-full Стоплист - шапка
&glob table_stop-list-full '{&bef-table_stop-list-full}':U
&glob bef-table_stop-list-attr-full Атрибуты для stop-list
&glob table_stop-list-attr-full '{&bef-table_stop-list-attr-full}':U
&glob bef-table_stop-list-line-full Строки стоплиста
&glob table_stop-list-line-full '{&bef-table_stop-list-line-full}':U
&glob bef-table_stop-list-line-attr-full Атрибуты для stop-list-line
&glob table_stop-list-line-attr-full '{&bef-table_stop-list-line-attr-full}':U
&glob bef-table_store-full store
&glob table_store-full '{&bef-table_store-full}':U
&glob bef-table_sum-group-full Суммовая группа
&glob table_sum-group-full '{&bef-table_sum-group-full}':U
&glob bef-table_sum-group-attr-full Атрибуты для sum-group
&glob table_sum-group-attr-full '{&bef-table_sum-group-attr-full}':U
&glob bef-table_sum-grp-full Группы товаров (на кассе)
&glob table_sum-grp-full '{&bef-table_sum-grp-full}':U
&glob bef-table_sum-grp-attr-full Атрибуты для sum-grp
&glob table_sum-grp-attr-full '{&bef-table_sum-grp-attr-full}':U
&glob bef-table_sum-grp-obj-full Группы товаров (на кассе объекта)
&glob table_sum-grp-obj-full '{&bef-table_sum-grp-obj-full}':U
&glob bef-table_sum-grp-obj-attr-full Атрибуты для sum-grp-obj
&glob table_sum-grp-obj-attr-full '{&bef-table_sum-grp-obj-attr-full}':U
&glob bef-table_sum-in-sum-group-full Сумма в суммовой группе
&glob table_sum-in-sum-group-full '{&bef-table_sum-in-sum-group-full}':U
&glob bef-table_sum-in-sum-group-attr-full Атрибуты для sum-in-sum-group
&glob table_sum-in-sum-group-attr-full '{&bef-table_sum-in-sum-group-attr-full}':U
&glob bef-table_sys-ctrl-full sys-ctrl
&glob table_sys-ctrl-full '{&bef-table_sys-ctrl-full}':U
&glob bef-table_sys-ctrl-attr-full Атрибуты для sys-ctrl
&glob table_sys-ctrl-attr-full '{&bef-table_sys-ctrl-attr-full}':U
&glob bef-table_sysconf-full Своя фирма
&glob table_sysconf-full '{&bef-table_sysconf-full}':U
&glob bef-table_sysconf-attr-full Атрибуты для sysconf
&glob table_sysconf-attr-full '{&bef-table_sysconf-attr-full}':U
&glob bef-table_tare-full Тара
&glob table_tare-full '{&bef-table_tare-full}':U
&glob bef-table_tax-full Налог
&glob table_tax-full '{&bef-table_tax-full}':U
&glob bef-table_tax-attr-full Атрибуты для tax
&glob table_tax-attr-full '{&bef-table_tax-attr-full}':U
&glob bef-table_tax-rate-full Ставка налога
&glob table_tax-rate-full '{&bef-table_tax-rate-full}':U
&glob bef-table_tax-rate-attr-full Атрибуты для tax-rate
&glob table_tax-rate-attr-full '{&bef-table_tax-rate-attr-full}':U
&glob bef-table_tax-rate-gds-full Ставки налогов
&glob table_tax-rate-gds-full '{&bef-table_tax-rate-gds-full}':U
&glob bef-table_tax-rate-gds-attr-full Атрибуты для tax-rate-gds
&glob table_tax-rate-gds-attr-full '{&bef-table_tax-rate-gds-attr-full}':U
&glob bef-table_tax-rate-gds-grp-full Налоги группы товаров
&glob table_tax-rate-gds-grp-full '{&bef-table_tax-rate-gds-grp-full}':U
&glob bef-table_tax-rate-gds-grp-attr-full Атрибуты для tax-rate-gds-grp
&glob table_tax-rate-gds-grp-attr-full '{&bef-table_tax-rate-gds-grp-attr-full}':U
&glob bef-table_tax-rate-value-full Знач.ставки налога
&glob table_tax-rate-value-full '{&bef-table_tax-rate-value-full}':U
&glob bef-table_tax-rate-value-attr-full Атрибуты для tax-rate-value
&glob table_tax-rate-value-attr-full '{&bef-table_tax-rate-value-attr-full}':U
&glob bef-table_tax-units-full Налоги на тип ед.изм.
&glob table_tax-units-full '{&bef-table_tax-units-full}':U
&glob bef-table_tax-units-attr-full Атрибуты для tax-units
&glob table_tax-units-attr-full '{&bef-table_tax-units-attr-full}':U
&glob bef-table_tech-prol-pwd-full tech-prol-pwd
&glob table_tech-prol-pwd-full '{&bef-table_tech-prol-pwd-full}':U
&glob bef-table_thbj-attr-full Параметры объекта TH
&glob table_thbj-attr-full '{&bef-table_thbj-attr-full}':U
&glob bef-table_tmp-sale-full Типы темпов продаж
&glob table_tmp-sale-full '{&bef-table_tmp-sale-full}':U
&glob bef-table_tmp-sale-attr-full Атрибуты для tmp-sale
&glob table_tmp-sale-attr-full '{&bef-table_tmp-sale-attr-full}':U
&glob bef-table_tmp-sale-dtl-full Темпы продаж по признакам
&glob table_tmp-sale-dtl-full '{&bef-table_tmp-sale-dtl-full}':U
&glob bef-table_tmp-sale-dtl-attr-full Атрибуты для tmp-sale-dtl
&glob table_tmp-sale-dtl-attr-full '{&bef-table_tmp-sale-dtl-attr-full}':U
&glob bef-table_tmp-sale-gds-full Темпы продаж по товарам
&glob table_tmp-sale-gds-full '{&bef-table_tmp-sale-gds-full}':U
&glob bef-table_tmp-sale-gds-attr-full Атрибуты для tmp-sale-gds
&glob table_tmp-sale-gds-attr-full '{&bef-table_tmp-sale-gds-attr-full}':U
&glob bef-table_tnv-in-turnover-group-full Сумма в суммовой группе
&glob table_tnv-in-turnover-group-full '{&bef-table_tnv-in-turnover-group-full}':U
&glob bef-table_tnv-in-turnover-group-attr-full Атрибуты для tnv-in-turnover-group
&glob table_tnv-in-turnover-group-attr-full '{&bef-table_tnv-in-turnover-group-attr-full}':U
&glob bef-table_tnved-head-full tnved-head
&glob table_tnved-head-full '{&bef-table_tnved-head-full}':U
&glob bef-table_tnved-head-attr-full Атрибуты для tnved-head
&glob table_tnved-head-attr-full '{&bef-table_tnved-head-attr-full}':U
&glob bef-table_tnved-item-full Справочник ТНВЕД
&glob table_tnved-item-full '{&bef-table_tnved-item-full}':U
&glob bef-table_tnved-item-attr-full Атрибуты для tnved-item
&glob table_tnved-item-attr-full '{&bef-table_tnved-item-attr-full}':U
&glob bef-table_tran-fuel-full Топливные транзакции
&glob table_tran-fuel-full '{&bef-table_tran-fuel-full}':U
&glob bef-table_trn-doc-full trn-doc
&glob table_trn-doc-full '{&bef-table_trn-doc-full}':U
&glob bef-table_trn-doc-sum-full trn-doc-sum
&glob table_trn-doc-sum-full '{&bef-table_trn-doc-sum-full}':U
&glob bef-table_trn-reason-full Основание создания документа
&glob table_trn-reason-full '{&bef-table_trn-reason-full}':U
&glob bef-table_trn-reason-host-full Коды причин на фирме
&glob table_trn-reason-host-full '{&bef-table_trn-reason-host-full}':U
&glob bef-table_trn-reason-obj-full Код причины по объекту
&glob table_trn-reason-obj-full '{&bef-table_trn-reason-obj-full}':U
&glob bef-table_trn-rsn-attr-full Атрибуты справочника причин
&glob table_trn-rsn-attr-full '{&bef-table_trn-rsn-attr-full}':U
&glob bef-table_turnover-buyer-full Обороты по покупателю
&glob table_turnover-buyer-full '{&bef-table_turnover-buyer-full}':U
&glob bef-table_turnover-buyer-attr-full Атрибут оборота покупателя
&glob table_turnover-buyer-attr-full '{&bef-table_turnover-buyer-attr-full}':U
&glob bef-table_turnover-buyer-gds-full Обороты по покуп. в разрезе то
&glob table_turnover-buyer-gds-full '{&bef-table_turnover-buyer-gds-full}':U
&glob bef-table_turnover-buyer-gds-attr-full Атрибуты обор пок в раз тов
&glob table_turnover-buyer-gds-attr-full '{&bef-table_turnover-buyer-gds-attr-full}':U
&glob bef-table_turnover-buyer-main-full Обороты по покупателю
&glob table_turnover-buyer-main-full '{&bef-table_turnover-buyer-main-full}':U
&glob bef-table_turnover-buyer-main-attr-full Атрибуты для turnover-buyer-main
&glob table_turnover-buyer-main-attr-full '{&bef-table_turnover-buyer-main-attr-full}':U
&glob bef-table_turnover-group-full Группа оборотов
&glob table_turnover-group-full '{&bef-table_turnover-group-full}':U
&glob bef-table_turnover-group-attr-full Атрибуты для turnover-group
&glob table_turnover-group-attr-full '{&bef-table_turnover-group-attr-full}':U
&glob bef-table_units-full units
&glob table_units-full '{&bef-table_units-full}':U
&glob bef-table_units-attr-full Атрибуты для units
&glob table_units-attr-full '{&bef-table_units-attr-full}':U
&glob bef-table_upgrade-full upgrade DB
&glob table_upgrade-full '{&bef-table_upgrade-full}':U
&glob bef-table_upgrade-attr-full Атрибуты для upgrade
&glob table_upgrade-attr-full '{&bef-table_upgrade-attr-full}':U
&glob bef-table_user-account-full user-account
&glob table_user-account-full '{&bef-table_user-account-full}':U
&glob bef-table_user-account-attr-full Атрибуты для user-account
&glob table_user-account-attr-full '{&bef-table_user-account-attr-full}':U
&glob bef-table_user-conn-full user-conn
&glob table_user-conn-full '{&bef-table_user-conn-full}':U
&glob bef-table_user-conn-attr-full Атрибуты для user-conn
&glob table_user-conn-attr-full '{&bef-table_user-conn-attr-full}':U
&glob bef-table_user-context-history-full user-context-history
&glob table_user-context-history-full '{&bef-table_user-context-history-full}':U
&glob bef-table_user-context-history-attr-full Атрибуты для user-context-history
&glob table_user-context-history-attr-full '{&bef-table_user-context-history-attr-full}':U
&glob bef-table_user-host-full user-host
&glob table_user-host-full '{&bef-table_user-host-full}':U
&glob bef-table_user-host-attr-full Атрибуты для user-host
&glob table_user-host-attr-full '{&bef-table_user-host-attr-full}':U
&glob bef-table_user-login-full user-login
&glob table_user-login-full '{&bef-table_user-login-full}':U
&glob bef-table_user-login-action-item-full user-login-action-item
&glob table_user-login-action-item-full '{&bef-table_user-login-action-item-full}':U
&glob bef-table_user-login-action-item-attr-full Атрибуты для user-login-action-item
&glob table_user-login-action-item-attr-full '{&bef-table_user-login-action-item-attr-full}':U
&glob bef-table_user-login-action-role-full user-login-action-role
&glob table_user-login-action-role-full '{&bef-table_user-login-action-role-full}':U
&glob bef-table_user-login-action-role-attr-full Атрибуты для user-login-action-role
&glob table_user-login-action-role-attr-full '{&bef-table_user-login-action-role-attr-full}':U
&glob bef-table_user-login-attr-full user-login-attr
&glob table_user-login-attr-full '{&bef-table_user-login-attr-full}':U
&glob bef-table_user-menu-group-full user-menu-group
&glob table_user-menu-group-full '{&bef-table_user-menu-group-full}':U
&glob bef-table_user-menu-group-attr-full Атрибуты для user-menu-group
&glob table_user-menu-group-attr-full '{&bef-table_user-menu-group-attr-full}':U
&glob bef-table_user-obj-full user-obj
&glob table_user-obj-full '{&bef-table_user-obj-full}':U
&glob bef-table_user-obj-attr-full Атрибуты для user-obj
&glob table_user-obj-attr-full '{&bef-table_user-obj-attr-full}':U
&glob bef-table_user-window-attr-full user-window-attr
&glob table_user-window-attr-full '{&bef-table_user-window-attr-full}':U
&glob bef-table_usr-flt-full usr-flt
&glob table_usr-flt-full '{&bef-table_usr-flt-full}':U
&glob bef-table_usr-flt-attr-full Атрибуты для usr-flt
&glob table_usr-flt-attr-full '{&bef-table_usr-flt-attr-full}':U
&glob bef-table_usr-stko-full Объекты для просмотра остатков
&glob table_usr-stko-full '{&bef-table_usr-stko-full}':U
&glob bef-table_usr-stko-attr-full Атрибуты для usr-stko
&glob table_usr-stko-attr-full '{&bef-table_usr-stko-attr-full}':U
&glob bef-table_utd-full utd
&glob table_utd-full '{&bef-table_utd-full}':U
&glob bef-table_utd-attr-full utd-attr
&glob table_utd-attr-full '{&bef-table_utd-attr-full}':U
&glob bef-table_utd-err-full Ошибки УПД
&glob table_utd-err-full '{&bef-table_utd-err-full}':U
&glob bef-table_utd-err-attr-full utd-err-attr
&glob table_utd-err-attr-full '{&bef-table_utd-err-attr-full}':U
&glob bef-table_utd-lines-full utd-lines
&glob table_utd-lines-full '{&bef-table_utd-lines-full}':U
&glob bef-table_utd-lines-attr-full utd-lines-attr
&glob table_utd-lines-attr-full '{&bef-table_utd-lines-attr-full}':U
&glob bef-table_utd-marking-lines-full utd-marking-lines
&glob table_utd-marking-lines-full '{&bef-table_utd-marking-lines-full}':U
&glob bef-table_utd-marking-lines-attr-full utd-marking-lines-attr
&glob table_utd-marking-lines-attr-full '{&bef-table_utd-marking-lines-attr-full}':U
&glob bef-table_var-deliv-gr-per-val-full Варианты доставки по срокам го
&glob table_var-deliv-gr-per-val-full '{&bef-table_var-deliv-gr-per-val-full}':U
&glob bef-table_var-deliv-gr-per-val-attr-full Атрибуты для var-deliv-gr-per-val
&glob table_var-deliv-gr-per-val-attr-full '{&bef-table_var-deliv-gr-per-val-attr-full}':U
&glob bef-table_variant-delivery-full Варианты доставки
&glob table_variant-delivery-full '{&bef-table_variant-delivery-full}':U
&glob bef-table_variant-delivery-attr-full Атрибуты для variant-delivery
&glob table_variant-delivery-attr-full '{&bef-table_variant-delivery-attr-full}':U
&glob bef-table_varianty-delivery-gds-obj-full Варианты доставки
&glob table_varianty-delivery-gds-obj-full '{&bef-table_varianty-delivery-gds-obj-full}':U
&glob bef-table_vsd-full vsd
&glob table_vsd-full '{&bef-table_vsd-full}':U
&glob bef-table_vsd-attr-full Аттрибуты ВСД
&glob table_vsd-attr-full '{&bef-table_vsd-attr-full}':U
&glob bef-table_wealth-full МЦ
&glob table_wealth-full '{&bef-table_wealth-full}':U
&glob bef-table_wealth-attr-full Атрибуты для wealth
&glob table_wealth-attr-full '{&bef-table_wealth-attr-full}':U
&glob bef-table_who-lk-full Причина блокировки
&glob table_who-lk-full '{&bef-table_who-lk-full}':U
&glob bef-table_who-lk-attr-full Атрибуты для who-lk
&glob table_who-lk-attr-full '{&bef-table_who-lk-attr-full}':U
&glob bef-table_whole-send-news-full В какие БД отправлена запись
&glob table_whole-send-news-full '{&bef-table_whole-send-news-full}':U
&glob bef-table_wi-mode-full Режимы работы
&glob table_wi-mode-full '{&bef-table_wi-mode-full}':U
&glob bef-table_wi-mode-attr-full Атрибуты режимов работы
&glob table_wi-mode-attr-full '{&bef-table_wi-mode-attr-full}':U
&glob bef-table_wth-doc-full Документ перем-я матценностей
&glob table_wth-doc-full '{&bef-table_wth-doc-full}':U
&glob bef-table_wth-doc-attr-full Атрибуты для wth-doc
&glob table_wth-doc-attr-full '{&bef-table_wth-doc-attr-full}':U
&glob bef-table_wth-dtl-full Разбивка матценностей
&glob table_wth-dtl-full '{&bef-table_wth-dtl-full}':U
&glob bef-table_wth-dtl-attr-full Атрибуты для wth-dtl
&glob table_wth-dtl-attr-full '{&bef-table_wth-dtl-attr-full}':U
&glob bef-table_wth-gds-full Связь МЦ с товарами
&glob table_wth-gds-full '{&bef-table_wth-gds-full}':U
&glob bef-table_wth-gds-attr-full wth-gds-attr
&glob table_wth-gds-attr-full '{&bef-table_wth-gds-attr-full}':U
&glob bef-table_wth-line-full Матценности из док-та
&glob table_wth-line-full '{&bef-table_wth-line-full}':U
&glob bef-table_wth-line-attr-full Атрибуты для wth-line
&glob table_wth-line-attr-full '{&bef-table_wth-line-attr-full}':U
&glob bef-table_wth-obj-full Мат. ценность на объекте
&glob table_wth-obj-full '{&bef-table_wth-obj-full}':U
&glob bef-table_wth-obj-attr-full Атрибуты для wth-obj
&glob table_wth-obj-attr-full '{&bef-table_wth-obj-attr-full}':U
&glob bef-table_wth-par-full Номинал МЦ
&glob table_wth-par-full '{&bef-table_wth-par-full}':U
&glob bef-table_wth-par-attr-full Атрибуты для wth-par
&glob table_wth-par-attr-full '{&bef-table_wth-par-attr-full}':U
&glob bef-table_wth-parts-full Партии МЦ
&glob table_wth-parts-full '{&bef-table_wth-parts-full}':U
&glob bef-table_wth-parts-attr-full Атрибуты для wth-parts
&glob table_wth-parts-attr-full '{&bef-table_wth-parts-attr-full}':U
&glob bef-table_wth-place-full Место хранения
&glob table_wth-place-full '{&bef-table_wth-place-full}':U
&glob bef-table_wth-place-attr-full Атрибуты для wth-place
&glob table_wth-place-attr-full '{&bef-table_wth-place-attr-full}':U
&glob bef-table_wth-pobj-full Ост. мат.цен. на месте хр. объ
&glob table_wth-pobj-full '{&bef-table_wth-pobj-full}':U
&glob bef-table_wth-pobj-attr-full Атрибуты для wth-pobj
&glob table_wth-pobj-attr-full '{&bef-table_wth-pobj-attr-full}':U
&glob bef-table_wth-ser-full Серии
&glob table_wth-ser-full '{&bef-table_wth-ser-full}':U
&glob bef-table_wth-ser-attr-full wth-ser-attr
&glob table_wth-ser-attr-full '{&bef-table_wth-ser-attr-full}':U
&glob bef-table_Xattr-full Словарь реквизитов
&glob table_Xattr-full '{&bef-table_Xattr-full}':U
&glob bef-table_xGroupObj-full Словарь групп объектов
&glob table_xGroupObj-full '{&bef-table_xGroupObj-full}':U
&glob bef-table_xstatus-full Статусы класса
&glob table_xstatus-full '{&bef-table_xstatus-full}':U
&glob bef-table_xyz-analysis-full XYZ анализ
&glob table_xyz-analysis-full '{&bef-table_xyz-analysis-full}':U
&glob bef-table_xyz-analysis-attr-full Атрибуты шапки XYZ анализа
&glob table_xyz-analysis-attr-full '{&bef-table_xyz-analysis-attr-full}':U
&glob bef-table_xyz-analysis-cli-full xyz по контрагентам
&glob table_xyz-analysis-cli-full '{&bef-table_xyz-analysis-cli-full}':U
&glob bef-table_xyz-analysis-cli-attr-full xyz-analysis-cli-attr
&glob table_xyz-analysis-cli-attr-full '{&bef-table_xyz-analysis-cli-attr-full}':U
&glob bef-table_xyz-analysis-doc-full Список расш типов докум в XYZ
&glob table_xyz-analysis-doc-full '{&bef-table_xyz-analysis-doc-full}':U
&glob bef-table_xyz-analysis-doc-attr-full Атрибуты для xyz-analysis-doc
&glob table_xyz-analysis-doc-attr-full '{&bef-table_xyz-analysis-doc-attr-full}':U
&glob bef-table_xyz-analysis-gds-obj-full Товары по объектам в XYZ анал
&glob table_xyz-analysis-gds-obj-full '{&bef-table_xyz-analysis-gds-obj-full}':U
&glob bef-table_xyz-analysis-gds-obj-attr-full Атр товаров по объектам в XYZ
&glob table_xyz-analysis-gds-obj-attr-full '{&bef-table_xyz-analysis-gds-obj-attr-full}':U
&glob bef-table_xyz-analysis-goods-full Товары в XYZ анализе
&glob table_xyz-analysis-goods-full '{&bef-table_xyz-analysis-goods-full}':U
&glob bef-table_xyz-analysis-goods-attr-full Атрибуты товара в XYZ анализе
&glob table_xyz-analysis-goods-attr-full '{&bef-table_xyz-analysis-goods-attr-full}':U
&glob bef-table_xyz-analysis-grp-full xyz по группам
&glob table_xyz-analysis-grp-full '{&bef-table_xyz-analysis-grp-full}':U
&glob bef-table_xyz-analysis-grp-attr-full Атрибуты xyz по группам
&glob table_xyz-analysis-grp-attr-full '{&bef-table_xyz-analysis-grp-attr-full}':U
&glob bef-table_xyz-analysis-obj-full Объекты для шапки XYZ анализа
&glob table_xyz-analysis-obj-full '{&bef-table_xyz-analysis-obj-full}':U
&glob bef-table_xyz-analysis-obj-attr-full Атрибуты для xyz-analysis-obj
&glob table_xyz-analysis-obj-attr-full '{&bef-table_xyz-analysis-obj-attr-full}':U
&glob bef-table_xyz-analysis-period-full Периоды для шапки XYZ анализа
&glob table_xyz-analysis-period-full '{&bef-table_xyz-analysis-period-full}':U
&glob bef-table_xyz-analysis-period-attr-full Атрибуты для xyz-analysis-period
&glob table_xyz-analysis-period-attr-full '{&bef-table_xyz-analysis-period-attr-full}':U
&glob bef-table_xyz-analysis-prod-full xyz по производителю
&glob table_xyz-analysis-prod-full '{&bef-table_xyz-analysis-prod-full}':U
&glob bef-table_xyz-analysis-prod-attr-full xyz-analysis-prod-attr
&glob table_xyz-analysis-prod-attr-full '{&bef-table_xyz-analysis-prod-attr-full}':U
/* $Workfile: $ e n d */

