/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Файл глобальных определений

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/06/08
Author: Bakhtadze Natalya
Creation date: 06/06/08

Этот файл сгенерирован автоматически
Все изменения необходимо вносить в файл dr-flddf.p

*/
&if defined(dr-flddf_i) = 0 &then
&glob dr-flddf_i
&global-define language rus
&if "{1}" = "class" &then
&else
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2dr-flddf: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
&endif
&global-define dr-flddf_dr-fields
&global-define bef-dr-flddf_cntxt_chk-discnt-table cntxt_chk-discnt-table
&global-define dr-flddf_cntxt_chk-discnt-table '{&bef-dr-flddf_cntxt_chk-discnt-table}':U
&global-define bef-dr-flddf_cntxt_chk-discnt-table-full Ссылка на Массив Скидок
&global-define dr-flddf_cntxt_chk-discnt-table-full '{&bef-dr-flddf_cntxt_chk-discnt-table-full}':U
&global-define bef-dr-flddf_cntxt_chk-gds-table cntxt_chk-gds-table
&global-define dr-flddf_cntxt_chk-gds-table '{&bef-dr-flddf_cntxt_chk-gds-table}':U
&global-define bef-dr-flddf_cntxt_chk-gds-table-full Ссылка на Массив Строк товаров
&global-define dr-flddf_cntxt_chk-gds-table-full '{&bef-dr-flddf_cntxt_chk-gds-table-full}':U
&global-define bef-dr-flddf_cntxt_chk-pay-table cntxt_chk-pay-table
&global-define dr-flddf_cntxt_chk-pay-table '{&bef-dr-flddf_cntxt_chk-pay-table}':U
&global-define bef-dr-flddf_cntxt_chk-pay-table-full Ссылка на Массив Строк Оплат
&global-define dr-flddf_cntxt_chk-pay-table-full '{&bef-dr-flddf_cntxt_chk-pay-table-full}':U
&global-define dr-flddf_cntxt-fields 'cntxt_chk-discnt-table,cntxt_chk-gds-table,cntxt_chk-pay-table':U
&global-define bef-dr-flddf_gline_line-num gline_line-num
&global-define dr-flddf_gline_line-num '{&bef-dr-flddf_gline_line-num}':U
&global-define bef-dr-flddf_gline_line-num-full Номер строки товара
&global-define dr-flddf_gline_line-num-full '{&bef-dr-flddf_gline_line-num-full}':U
&global-define bef-dr-flddf_gline_src-discnt gline_src-discnt
&global-define dr-flddf_gline_src-discnt '{&bef-dr-flddf_gline_src-discnt}':U
&global-define bef-dr-flddf_gline_src-discnt-full Текущая скидка на ед.товара
&global-define dr-flddf_gline_src-discnt-full '{&bef-dr-flddf_gline_src-discnt-full}':U
&global-define bef-dr-flddf_gline_src-code gline_src-code
&global-define dr-flddf_gline_src-code '{&bef-dr-flddf_gline_src-code}':U
&global-define bef-dr-flddf_gline_src-code-full Код товара в чеке
&global-define dr-flddf_gline_src-code-full '{&bef-dr-flddf_gline_src-code-full}':U
&global-define bef-dr-flddf_gline_src-price gline_src-price
&global-define dr-flddf_gline_src-price '{&bef-dr-flddf_gline_src-price}':U
&global-define bef-dr-flddf_gline_src-price-full Текущая цена
&global-define dr-flddf_gline_src-price-full '{&bef-dr-flddf_gline_src-price-full}':U
&global-define bef-dr-flddf_gline_start-src-price gline_start-src-price
&global-define dr-flddf_gline_start-src-price '{&bef-dr-flddf_gline_start-src-price}':U
&global-define bef-dr-flddf_gline_start-src-price-full Цена по прайс-листу
&global-define dr-flddf_gline_start-src-price-full '{&bef-dr-flddf_gline_start-src-price-full}':U
&global-define bef-dr-flddf_gline_price-base gline_price-base
&global-define dr-flddf_gline_price-base '{&bef-dr-flddf_gline_price-base}':U
&global-define bef-dr-flddf_gline_price-base-full Текущая цена в основных ед.изм.
&global-define dr-flddf_gline_price-base-full '{&bef-dr-flddf_gline_price-base-full}':U
&global-define bef-dr-flddf_gline_src-qnty gline_src-qnty
&global-define dr-flddf_gline_src-qnty '{&bef-dr-flddf_gline_src-qnty}':U
&global-define bef-dr-flddf_gline_src-qnty-full Текущее кол-во
&global-define dr-flddf_gline_src-qnty-full '{&bef-dr-flddf_gline_src-qnty-full}':U
&global-define bef-dr-flddf_gline_doc-qnty gline_doc-qnty
&global-define dr-flddf_gline_doc-qnty '{&bef-dr-flddf_gline_doc-qnty}':U
&global-define bef-dr-flddf_gline_doc-qnty-full Кол-во в основных ед.изм
&global-define dr-flddf_gline_doc-qnty-full '{&bef-dr-flddf_gline_doc-qnty-full}':U
&global-define bef-dr-flddf_gline_b-code gline_b-code
&global-define dr-flddf_gline_b-code '{&bef-dr-flddf_gline_b-code}':U
&global-define bef-dr-flddf_gline_b-code-full Основной бар-код
&global-define dr-flddf_gline_b-code-full '{&bef-dr-flddf_gline_b-code-full}':U
&global-define bef-dr-flddf_gline_gds-code gline_gds-code
&global-define dr-flddf_gline_gds-code '{&bef-dr-flddf_gline_gds-code}':U
&global-define bef-dr-flddf_gline_gds-code-full Код товара
&global-define dr-flddf_gline_gds-code-full '{&bef-dr-flddf_gline_gds-code-full}':U
&global-define bef-dr-flddf_gline_sum-grp-code gline_sum-grp-code
&global-define dr-flddf_gline_sum-grp-code '{&bef-dr-flddf_gline_sum-grp-code}':U
&global-define bef-dr-flddf_gline_sum-grp-code-full Код группы
&global-define dr-flddf_gline_sum-grp-code-full '{&bef-dr-flddf_gline_sum-grp-code-full}':U
&global-define bef-dr-flddf_gline_src-base gline_src-base
&global-define dr-flddf_gline_src-base '{&bef-dr-flddf_gline_src-base}':U
&global-define bef-dr-flddf_gline_src-base-full Сумма брутто
&global-define dr-flddf_gline_src-base-full '{&bef-dr-flddf_gline_src-base-full}':U
&global-define bef-dr-flddf_gline_src-price-netto gline_src-price-netto
&global-define dr-flddf_gline_src-price-netto '{&bef-dr-flddf_gline_src-price-netto}':U
&global-define bef-dr-flddf_gline_src-price-netto-full Эффективная цена(нетто)
&global-define dr-flddf_gline_src-price-netto-full '{&bef-dr-flddf_gline_src-price-netto-full}':U
&global-define bef-dr-flddf_gline_price-base-netto gline_price-base-netto
&global-define dr-flddf_gline_price-base-netto '{&bef-dr-flddf_gline_price-base-netto}':U
&global-define bef-dr-flddf_gline_price-base-netto-full Эффективная цена(нетто) для осн.ед.изм
&global-define dr-flddf_gline_price-base-netto-full '{&bef-dr-flddf_gline_price-base-netto-full}':U
&global-define bef-dr-flddf_gline_without-gds-discnt gline_without-gds-discnt
&global-define dr-flddf_gline_without-gds-discnt '{&bef-dr-flddf_gline_without-gds-discnt}':U
&global-define bef-dr-flddf_gline_without-gds-discnt-full Нет товарн. скидки на товар
&global-define dr-flddf_gline_without-gds-discnt-full '{&bef-dr-flddf_gline_without-gds-discnt-full}':U
&global-define bef-dr-flddf_gline_without-subtotal-discnt gline_without-subtotal-discnt
&global-define dr-flddf_gline_without-subtotal-discnt '{&bef-dr-flddf_gline_without-subtotal-discnt}':U
&global-define bef-dr-flddf_gline_without-subtotal-discnt-full Не участвует в скидке на итог
&global-define dr-flddf_gline_without-subtotal-discnt-full '{&bef-dr-flddf_gline_without-subtotal-discnt-full}':U
&global-define bef-dr-flddf_gline_cli-base-rate gline_cli-base-rate
&global-define dr-flddf_gline_cli-base-rate '{&bef-dr-flddf_gline_cli-base-rate}':U
&global-define bef-dr-flddf_gline_cli-base-rate-full Коэфф для упаковки
&global-define dr-flddf_gline_cli-base-rate-full '{&bef-dr-flddf_gline_cli-base-rate-full}':U
&global-define bef-dr-flddf_gline_recalc-line-num gline_recalc-line-num
&global-define dr-flddf_gline_recalc-line-num '{&bef-dr-flddf_gline_recalc-line-num}':U
&global-define bef-dr-flddf_gline_recalc-line-num-full Строка начала пересчета скидок
&global-define dr-flddf_gline_recalc-line-num-full '{&bef-dr-flddf_gline_recalc-line-num-full}':U
&global-define dr-flddf_gline-fields 'gline_line-num,gline_src-discnt,gline_src-code,gline_src-price,gline_start-src-price,gline_price-base,gline_src-qnty,gline_doc-qnty,gline_b-code,gline_gds-code,gline_sum-grp-code,gline_src-price-netto,gline_price-base-netto,gline_without-gds-discnt,gline_without-subtotal-discnt,gline_cli-base-rate,gline_recalc-line-num':U
&global-define bef-dr-flddf_pline_line-num pline_line-num
&global-define dr-flddf_pline_line-num '{&bef-dr-flddf_pline_line-num}':U
&global-define bef-dr-flddf_pline_line-num-full Номер строки оплат
&global-define dr-flddf_pline_line-num-full '{&bef-dr-flddf_pline_line-num-full}':U
&global-define bef-dr-flddf_pline_exch-rate pline_exch-rate
&global-define dr-flddf_pline_exch-rate '{&bef-dr-flddf_pline_exch-rate}':U
&global-define bef-dr-flddf_pline_exch-rate-full Курс валюты оплат к нац.вал.
&global-define dr-flddf_pline_exch-rate-full '{&bef-dr-flddf_pline_exch-rate-full}':U
&global-define bef-dr-flddf_pline_exch-scale pline_exch-scale
&global-define dr-flddf_pline_exch-scale '{&bef-dr-flddf_pline_exch-scale}':U
&global-define bef-dr-flddf_pline_exch-scale-full Масштаб курса валюты оплат к нац.вал.
&global-define dr-flddf_pline_exch-scale-full '{&bef-dr-flddf_pline_exch-scale-full}':U
&global-define bef-dr-flddf_pline_tot-sum pline_tot-sum
&global-define dr-flddf_pline_tot-sum '{&bef-dr-flddf_pline_tot-sum}':U
&global-define bef-dr-flddf_pline_tot-sum-full Текущая сумма опат в вал.платежа
&global-define dr-flddf_pline_tot-sum-full '{&bef-dr-flddf_pline_tot-sum-full}':U
&global-define bef-dr-flddf_pline_recalc-line-num pline_recalc-line-num
&global-define dr-flddf_pline_recalc-line-num '{&bef-dr-flddf_pline_recalc-line-num}':U
&global-define bef-dr-flddf_pline_recalc-line-num-full Строка начала пересчета скидок
&global-define dr-flddf_pline_recalc-line-num-full '{&bef-dr-flddf_pline_recalc-line-num-full}':U
&global-define dr-flddf_pline-fields 'pline_line-num,pline_exch-rate,pline_exch-scale,pline_tot-sum,pline_recalc-line-num':U
&global-define bef-dr-flddf_doc_chk-date doc_chk-date
&global-define dr-flddf_doc_chk-date '{&bef-dr-flddf_doc_chk-date}':U
&global-define bef-dr-flddf_doc_chk-date-full Дата чека
&global-define dr-flddf_doc_chk-date-full '{&bef-dr-flddf_doc_chk-date-full}':U
&global-define bef-dr-flddf_doc_chk-time doc_chk-time
&global-define dr-flddf_doc_chk-time '{&bef-dr-flddf_doc_chk-time}':U
&global-define bef-dr-flddf_doc_chk-time-full Время чека
&global-define dr-flddf_doc_chk-time-full '{&bef-dr-flddf_doc_chk-time-full}':U
&global-define bef-dr-flddf_doc_dc-category doc_dc-category
&global-define dr-flddf_doc_dc-category '{&bef-dr-flddf_doc_dc-category}':U
&global-define bef-dr-flddf_doc_dc-category-full Категория ДК
&global-define dr-flddf_doc_dc-category-full '{&bef-dr-flddf_doc_dc-category-full}':U
&global-define bef-dr-flddf_doc_dc-d-pcnt doc_dc-d-pcnt
&global-define dr-flddf_doc_dc-d-pcnt '{&bef-dr-flddf_doc_dc-d-pcnt}':U
&global-define bef-dr-flddf_doc_dc-d-pcnt-full %
&global-define dr-flddf_doc_dc-d-pcnt-full '{&bef-dr-flddf_doc_dc-d-pcnt-full}':U
&global-define bef-dr-flddf_doc_dc-cash-d-pcnt doc_dc-cash-d-pcnt
&global-define dr-flddf_doc_dc-cash-d-pcnt '{&bef-dr-flddf_doc_dc-cash-d-pcnt}':U
&global-define bef-dr-flddf_doc_dc-cash-d-pcnt-full %
&global-define dr-flddf_doc_dc-cash-d-pcnt-full '{&bef-dr-flddf_doc_dc-cash-d-pcnt-full}':U
&global-define bef-dr-flddf_doc_recalc-gline-num doc_recalc-gline-num
&global-define dr-flddf_doc_recalc-gline-num '{&bef-dr-flddf_doc_recalc-gline-num}':U
&global-define bef-dr-flddf_doc_recalc-gline-num-full Товарная Строка начала пересчета скидок
&global-define dr-flddf_doc_recalc-gline-num-full '{&bef-dr-flddf_doc_recalc-gline-num-full}':U
&global-define bef-dr-flddf_doc_recalc-pline-num doc_recalc-pline-num
&global-define dr-flddf_doc_recalc-pline-num '{&bef-dr-flddf_doc_recalc-pline-num}':U
&global-define bef-dr-flddf_doc_recalc-pline-num-full Оплатная Строка начала пересчета скидок
&global-define dr-flddf_doc_recalc-pline-num-full '{&bef-dr-flddf_doc_recalc-pline-num-full}':U
&global-define bef-dr-flddf_doc_st-for-discnt-r-b doc_st-for-discnt-r-b
&global-define dr-flddf_doc_st-for-discnt-r-b '{&bef-dr-flddf_doc_st-for-discnt-r-b}':U
&global-define bef-dr-flddf_doc_st-for-discnt-r-b-full Сумма для начисления скидки на итог в вал.продаж
&global-define dr-flddf_doc_st-for-discnt-r-b-full '{&bef-dr-flddf_doc_st-for-discnt-r-b-full}':U
&global-define bef-dr-flddf_doc_to-pay-r-b doc_to-pay-r-b
&global-define dr-flddf_doc_to-pay-r-b '{&bef-dr-flddf_doc_to-pay-r-b}':U
&global-define bef-dr-flddf_doc_to-pay-r-b-full Текущая сумма подлежащая оплате
&global-define dr-flddf_doc_to-pay-r-b-full '{&bef-dr-flddf_doc_to-pay-r-b-full}':U
&global-define bef-dr-flddf_doc_base-rate doc_base-rate
&global-define dr-flddf_doc_base-rate '{&bef-dr-flddf_doc_base-rate}':U
&global-define bef-dr-flddf_doc_base-rate-full Курс баз.вал. в чеке
&global-define dr-flddf_doc_base-rate-full '{&bef-dr-flddf_doc_base-rate-full}':U
&global-define bef-dr-flddf_doc_obj-code doc_obj-code
&global-define dr-flddf_doc_obj-code '{&bef-dr-flddf_doc_obj-code}':U
&global-define bef-dr-flddf_doc_obj-code-full № маг-на
&global-define dr-flddf_doc_obj-code-full '{&bef-dr-flddf_doc_obj-code-full}':U
&global-define dr-flddf_doc-fields 'doc_chk-date,doc_chk-time,doc_dc-category,doc_dc-d-pcnt,doc_dc-cash-d-pcnt,doc_recalc-gline-num,doc_recalc-pline-num,doc_st-for-discnt-r-b,doc_to-pay-r-b,doc_base-rate,doc_obj-code':U
&global-define bef-dr-flddf_dline_discnt-value-abs dline_discnt-value-abs
&global-define dr-flddf_dline_discnt-value-abs '{&bef-dr-flddf_dline_discnt-value-abs}':U
&global-define bef-dr-flddf_dline_discnt-value-abs-full Абс. сумма текущей линии скидки
&global-define dr-flddf_dline_discnt-value-abs-full '{&bef-dr-flddf_dline_discnt-value-abs-full}':U
&global-define bef-dr-flddf_dline_discnt-value-pcnt dline_discnt-value-pcnt
&global-define dr-flddf_dline_discnt-value-pcnt '{&bef-dr-flddf_dline_discnt-value-pcnt}':U
&global-define bef-dr-flddf_dline_discnt-value-pcnt-full Эфф. % текущей линии
&global-define dr-flddf_dline_discnt-value-pcnt-full '{&bef-dr-flddf_dline_discnt-value-pcnt-full}':U
&global-define bef-dr-flddf_dline_rule-num dline_rule-num
&global-define dr-flddf_dline_rule-num '{&bef-dr-flddf_dline_rule-num}':U
&global-define bef-dr-flddf_dline_rule-num-full № применяемого правила
&global-define dr-flddf_dline_rule-num-full '{&bef-dr-flddf_dline_rule-num-full}':U
&global-define bef-dr-flddf_dline_nonunique dline_nonunique
&global-define dr-flddf_dline_nonunique '{&bef-dr-flddf_dline_nonunique}':U
&global-define bef-dr-flddf_dline_nonunique-full Детализаци
&global-define dr-flddf_dline_nonunique-full '{&bef-dr-flddf_dline_nonunique-full}':U
&global-define bef-dr-flddf_dline_templ-rl-root dline_templ-rl-root
&global-define dr-flddf_dline_templ-rl-root '{&bef-dr-flddf_dline_templ-rl-root}':U
&global-define bef-dr-flddf_dline_templ-rl-root-full Шаблон применяемого правила
&global-define dr-flddf_dline_templ-rl-root-full '{&bef-dr-flddf_dline_templ-rl-root-full}':U
&global-define bef-dr-flddf_dline_value-type dline_value-type
&global-define dr-flddf_dline_value-type '{&bef-dr-flddf_dline_value-type}':U
&global-define bef-dr-flddf_dline_value-type-full Тип значения применной скидки
&global-define dr-flddf_dline_value-type-full '{&bef-dr-flddf_dline_value-type-full}':U
&global-define bef-dr-flddf_dline_delta-discnt dline_delta-discnt
&global-define dr-flddf_dline_delta-discnt '{&bef-dr-flddf_dline_delta-discnt}':U
&global-define bef-dr-flddf_dline_delta-discnt-full Эфф. дельта скидки на ед.товара
&global-define dr-flddf_dline_delta-discnt-full '{&bef-dr-flddf_dline_delta-discnt-full}':U
&global-define bef-dr-flddf_dline_discnt-role dline_discnt-role
&global-define dr-flddf_dline_discnt-role '{&bef-dr-flddf_dline_discnt-role}':U
&global-define bef-dr-flddf_dline_discnt-role-full Роль скидки
&global-define dr-flddf_dline_discnt-role-full '{&bef-dr-flddf_dline_discnt-role-full}':U
&global-define bef-dr-flddf_dline_charkey dline_charkey
&global-define dr-flddf_dline_charkey '{&bef-dr-flddf_dline_charkey}':U
&global-define bef-dr-flddf_dline_charkey-full Метка связанной скидки
&global-define dr-flddf_dline_charkey-full '{&bef-dr-flddf_dline_charkey-full}':U
&global-define bef-dr-flddf_dline_intended dline_intended
&global-define dr-flddf_dline_intended '{&bef-dr-flddf_dline_intended}':U
&global-define bef-dr-flddf_dline_intended-full Еще Может выполнитьс
&global-define dr-flddf_dline_intended-full '{&bef-dr-flddf_dline_intended-full}':U
&global-define bef-dr-flddf_dline_object-sum dline_object-sum
&global-define dr-flddf_dline_object-sum '{&bef-dr-flddf_dline_object-sum}':U
&global-define bef-dr-flddf_dline_object-sum-full Сумма обложени
&global-define dr-flddf_dline_object-sum-full '{&bef-dr-flddf_dline_object-sum-full}':U
&global-define bef-dr-flddf_dline_not-found dline_not-found
&global-define dr-flddf_dline_not-found '{&bef-dr-flddf_dline_not-found}':U
&global-define bef-dr-flddf_dline_not-found-full Не проходит
&global-define dr-flddf_dline_not-found-full '{&bef-dr-flddf_dline_not-found-full}':U
&global-define dr-flddf_dline-fields 'dline_discnt-value-abs,dline_discnt-value-pcnt,dline_rule-num,dline_nonunique,dline_templ-rl-root,dline_value-type,dline_delta-discnt,dline_discnt-role,dline_charkey,dline_intended,dline_object-sum,dline_not-found':U
&global-define dr-flddf_vss-revision 'Revision: 1980 ':U
&endif