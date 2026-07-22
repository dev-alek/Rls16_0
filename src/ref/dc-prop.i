/*

$Revision$
$Author$
$Date$
$Workfile: $
$Archive: $

ФАЙЛ ГЕНЕРИРУЕТСЯ ПРОЦЕДУРОЙ gen-file utl\gendcpmp.p

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/31/07
Author: Bakhtadze Natalya
Creation date: 07/31/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*Свойства дисконтных карт*/
&global-define dc-prop_dis-card-property 6

/*Скидки и категория в следующем накопительном периоде*/
&global-define dc-prop_next-discount 7
/*Скидка на товар*/
&global-define dc_prop_next-discount_d-pcnt 1
/*Скидка на итог*/
&global-define dc_prop_next-discount_cash-d-pcnt 2
/*Категория скидки*/
&global-define dc_prop_next-discount_category 3

/*Скидки и категория по выборке товаров*/
&global-define dc-prop_sel-goods-discount 17
/*Скидка на товар*/
&global-define dc_prop_sel-goods-discount_d-pcnt 1
/*Скидка на итог*/
&global-define dc_prop_sel-goods-discount_cash-d-pcnt 2
/*Категория скидки*/
&global-define dc_prop_sel-goods-discount_category 3

/*Топливо*/
&global-define dc-prop_dc-petrol 18
/*№ автомобиля*/
&global-define dc_prop_dc-petrol_car-reg-number 1
/*Марка транспортного средства*/
&global-define dc_prop_dc-petrol_car-brand 2
/*Тип лимита по топливу*/
&global-define dc_prop_dc-petrol_limit-type 3
/*Лимит по сумме*/
&global-define dc_prop_dc-petrol_sum-limit 4
/*Лимит по количеству*/
&global-define dc_prop_dc-petrol_qnty-limit 5
/*Период квоты*/
&global-define dc_prop_dc-petrol_quota-period 6
/*Квота*/
&global-define dc_prop_dc-petrol_quota 7
/*Тип счета*/
&global-define dc_prop_dc-petrol_account-type 8
/*Тип касс.платежа*/
&global-define dc_prop_dc-petrol_cdpay-code 9

/*Классы ограничений*/
&global-define dc-prop_dc-limit 27
/*Минимальный диапазон*/
&global-define dc_prop_dc-limit_minnum 1
/*Максимальный диапазон*/
&global-define dc_prop_dc-limit_maxnum 2


/*Дата-время обновления*/
&global-define dc-prop_upd-date-time 19
/*Дата-время*/
&global-define dc_prop_upd-date-time_date-time 1
/*Дата-время*/
&global-define dc_prop_upd-date-time_self-date-time 2

/*Лимиты EasyFuel*/
&global-define dc-prop_easyfuel-limits 24
/*Месячный лимит*/
&global-define dc_prop_easyfuel-limits_month-limit 1
/*Дневной лимит*/
&global-define dc_prop_easyfuel-limits_day-limit 2
/*Стандартная доза*/
&global-define dc_prop_easyfuel-limits_standard-dose 3
/*Общий лимит*/
&global-define dc_prop_easyfuel-limits_common-limit 4

/*EasyFuel*/
&global-define dc-prop_easyfuel 25
/*№ автомобиля*/
&global-define dc_prop_easyfuel_car-reg-number 1
/*Марка транспортного средства*/
&global-define dc_prop_easyfuel_car-brand 2
/*Формат данных на МБ EasyFuel*/
&global-define dc_prop_easyfuel_ef-format 3
/*Ключ доступа*/
&global-define dc_prop_easyfuel_access-key 4
/*Топливо1*/
&global-define dc_prop_easyfuel_petrol-code-1 5
/*Топливо2*/
&global-define dc_prop_easyfuel_petrol-code-2 6
/*Топливо3*/
&global-define dc_prop_easyfuel_petrol-code-3 7
/*Топливо4*/
&global-define dc_prop_easyfuel_petrol-code-4 8
/*Список топлив1*/
&global-define dc_prop_easyfuel_petrol-list-1 9
/*Список топлив2*/
&global-define dc_prop_easyfuel_petrol-list-2 10
/*Дата-время инициализации*/
&global-define dc_prop_easyfuel_init-date-time 11
/*Инициализировал*/
&global-define dc_prop_easyfuel_init-operator 12
/*Выдал*/
&global-define dc_prop_easyfuel_issued-by 13

/*Скидка-категория*/
&global-define dc-prop_Discount 26
/*Скидка на товар*/
&global-define dc_prop_Discount_d-pcnt 1
/*Скидка на итог*/
&global-define dc_prop_Discount_cash-d-pcnt 2
/*Категория скидки*/
&global-define dc_prop_Discount_category 3

/*EasyFuel2*/
&global-define dc-prop_easyfuel2 33
/*№ автомобиля*/
&global-define dc_prop_easyfuel2_car-reg-number 1
/*Марка транспортного средства*/
&global-define dc_prop_easyfuel2_car-brand 2


/* $Workfile$ e n d */
