/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Жестко переопределенные названия таблиц

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/29/07
Author: Bakhtadze Natalya
Creation date: 01/29/07

*/

&glob table_goods-full                                    "Товар"
&glob table_goods-attr-full                               "Атр-т товара"
&glob table_gds-host-attr-full                            "Атр-т тов. на фирме"
&glob table_gds-obj-attr-full                             "Атр-т тов. на объекте"
&glob table_gds-obj-prop-attr-full                        "Атр-т тов. для заказов"
&glob table_gds-obj-full                                  "Товар на объекте"
&glob table_fbr-gds-obj-full                              "Атрибут РЕСТОРАНа"
&glob table_s-coeff-full                                  "Сезонный коэфф"
&glob table_bar-code-full                                 "Бар-код"
&glob table_prod-bc-full                                  "ДопБК"
&glob table_varianty-delivery-gds-obj-full                "Варианты доставки"
&glob table_gds-season-full                               "Сезон товара"
&glob table_tax-rate-gds-full                             "Ставки налогов"
&glob table_ass-matr-full                                 "А_матрица"
&glob table_gds-obj-prop-full                             "Индикаторы"
&glob table_pl-gds-full                                   "Товар на складском месте"
&glob table_pl-gds-pump-full                              "Товар на ТРК"
&glob table_sert-join-full                                "Сертификат на товар"
&glob table_pl-gds-attr-full                              "АттрТовара на скл.месте"
&glob table_dis-gds-rule-full                             "Скидка Товара на объ."
&glob table_ext-artic-full                                "Внешний артикул товара"
&glob table_clients-full                                  "Клиент"
&glob table_clients-attr-full                             "Атрибут клиента"
&glob table_sysconf-full                                  "Своя фирма"
&glob table_firm-full                                     "Организация"
&glob table_person-full                                   "Физ.лицо"
&glob table_shop-full                                     "Магазин"
&glob table_stock-full                                    "Склад"
&glob table_staff-full                                    "Персонал"
&glob table_dis-thbj-rule-full                            "Общие скидки"
&glob table_dis-card-full                                 "Диск.карта"
&glob table_dis-obj-full                                  "Итоги ДК на объ."
&glob table_dis-host-full                                 "Итоги ДК фирма/общ"
&glob table_dis-card-property-full                        "Свойства ДК"
&glob table_dis-dc-rule-full                              "Скидки для ДК"
&glob table_dis-card-type-full                            "Тип диск.карты"
&glob table_dis-card-type-attr-full                       "Аттр.типа диск.карты"
&glob table_dis-card-mask-full                            "Маска диск.карты"
&glob table_dis-grp-rule-full                             "Скидки по группе"
&glob table_rule-by-call-full                             "Вызов правила"
&glob table_dis-dct-rule-full                             "Скидки на типы ДК"
&glob table_cash-desk-full                                "Касса"
&glob table_cash-desk-attr-full                           "Аттр.кассы"
&glob table_cash-pay-full                                 "Касс.платеж"
&glob table_cash-pay-attr-full                            "Аттр.касс.пл-жа"
&glob table_dis-cp-rule-full                              "Скидки на платеж"
&glob table_tax-full                                      "Налог"
&glob table_tax-rate-full                                 "Ставка налога"
&glob table_tax-rate-value-full                           "Знач.ставки налога"
&glob table_tax-units-full                                "Налоги на тип ед.изм."
&glob table_gds-grp-full                                  "Группа товаров"
&glob table_gds-grp-attr-full                             "Атр-т группы товаров"
&glob table_gds-grp-obj-full                              "Группа товаров на объекте"
&glob table_tax-rate-gds-grp-full                         "Налоги группы товаров"
&glob table_cli-grp-full                                  "Группа клиентов"
&glob table_wealth-full                                   "МЦ"
&glob table_wth-par-full                                  "Номинал МЦ"
&glob table_place-full                                    "Складское место"
&glob table_pl-pump-full                                  "Резервуар/ТРК"
&glob table_pl-pump-nozzle-full                           "Резервуар/ТРК/Пистолет"
&glob table_place-attr-full                               "Атрибут Скл. места"
&glob table_pump-full                                     "ТРК"
&glob table_pump-attr-full                                "Атрибут ТРК"
&glob table_nozzle-full                                   "Пистолет"
&glob table_nozzle-attr-full                              "Атрибут Пистолета"
&glob table_pump-nozzle-full                              "ТРК/Пистолет"
&glob table_fbr-gds-grp-full                              "Группа блюд"
&glob table_fbr-gds-grp-attr-full                         "Атр-т группы блюд"
&glob table_shift-obj-full                                "Смена"
&glob table_shift-staff-full                              "Персонал смены"
&glob table_sert-full                                     "Сертификат"
&glob table_scales-full                                   "Весы"
&glob table_scales-grp-full                               "Группы товаров на весах"
&glob table_scales-gds-full                               "Товар на весах"
&glob table_scales-attr-full                              "Атрибут весов"
&glob table_prop-head-full                                "Объекты-операнды машины правил"
&glob table_ruleset-full                                  "Кодексы и наборы правил"
&glob table_rule-full                                     "Правила RULE-машины"
&glob table_ruledict-full                                 "Словарь RULE-машины"
&glob table_rule-profile-full                             "Профайлы правил"
&glob table_prop-script-full                              "Скрипты RULE-машины"
&glob table_ext-classif-full                              "Внешний классификатор"
&glob table_sum-grp-full                                  "Группы товаров (на кассе)"
&glob table_sum-grp-obj-full                              "Группы товаров (на кассе объекта)"
&glob table_recipe-full                                   "Рецепт"
&glob table_recipe-gds-full                               "Товар рецепта"
&glob table_contract-specif-full                          "Спецификация к дог-ру"
&glob table_rule-process-full                             "Звено процесса"



/* $Workfile$ e n d */