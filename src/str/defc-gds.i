/*

$Revision: 47e5c2a27e63, 2885, rls $
$Author: VRukavishnikov $
$Date: Пн ноя 22 19:49:11 2021 +0300 $
$Workfile: defc-gds.i $
$Archive: str/defc-gds.i $

определение временной таблицы  с информацией по товару

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/13/06
Author: Bakhtadze Natalya
Creation date: 04/13/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: defc-gds.i $ $Revision: 47e5c2a27e63, 2885, rls $".

DEFINE {1} TEMP-TABLE cash-gds no-undo
FIELD gds-code          like ub.goods.gds-code
FIELD artic             like ub.goods.artic
FIELD producer-int      as integer
FIELD b-code            like ub.bar-code.b-code
FIELD b-str             like ub.prod-bc.b-str
FIELD bc-on              like ub.prod-bc.bc-on
FIELD gds-name          like ub.goods.gds-name
FIELD gds-namelong      like ub.goods.gds-name
FIELD gds-name1         like ub.goods.gds-name
FIELD f-name            like ub.gds-prt.f-name
FIELD unit-base         like ub.goods.unit-base
FIELD unit-cli          like ub.bar-code.unit-cli
FIELD cli-base-rate     like ub.bar-code.cli-base-rate

/*НЕ МЕНЯТЬ НАЗВАНИЕ ПОЛЯ - ОНО СВЯЗАНО С НАСТРОЙАМИ ДЛЯ МАРИИ*/
FIELD std-discnt-rule   as integer     /*правило стандартной скидки*/


FIELD temp-discnt-rule  as integer     /*правило временной скидки*/
FIELD temp-discnt-method as character   /*метод временной скидки - товар или ДНЦ*/

FIELD VAT-pc            like ub.doc-line.VAT-pc
FIELD vat-code          like ub.tax-rate-gds.rate-code
FIELD SLT-pc            like ub.doc-line.SLT-pc
FIELD grp-code          like ub.goods.grp-code
FIELD gds-stat          as integer FORMAT "999"
FIELD wd-rule          as integer /*не подлежит скидке на итог - номер правила*/
FIELD wgd-rule         as integer /*не подлежит товарной скидке - номер правила*/
FIELD fp               as logical /*свободная цена на кассе*/
FIELD zp               as integer /*нулевая цена на кассе модификатор*/
FIELD pp               as integer /*товар топливного кошелька*/
FIELD need-auth        as integer /*товар требует авторизации на кассе*/
FIELD is-menu          as integer /*1 или 0 блюдо меню*/
FIELD is-semi-finished as integer /*1 или 0 полуфабрикат*/
FIELD is-modificator   as integer /*1 или 0 модификатор*/
FIELD DepartId         as integer /*1код подразделения где готовится*/
FIELD fbr-grp-code-0   as integer /*код группы ресторана */
FIELD fbr-grp-code     as integer /*код группы прайс-листа ресторана*/
FIELD office           as integer /*услуга*/
field office-type      as character /*тип услуги*/
FIELD CalculationMethod      as integer  /* признак способа расчета */
FIELD CalculationMethodRestr as integer  /* ограничение на признак способа расчета */
FIELD price-sale       like ub.price-list.price-sale
FIELD unit-type        like ub.units.type
FIELD unit-cli-type    like ub.units.type
FIELD tax-string       as char FORMAT "X(255)"

/*НЕ МЕНЯТЬ НАЗВАНИЕ ПОЛЯ - ОНО СВЯЗАНО С НАСТРОЙАМИ ДЛЯ МАРИИ*/
FIELD qnty-discnt-rule as integer
/*строка категорийных скидок или скидок на количество*/
FIELD kat-discnt-rule  as integer
FIELD kat-discnt-method as character   /*метод категорийной скидки - товар или ДНЦ*/
FIELD date-discnt-rule as integer

/*НЕ МЕНЯТЬ НАЗВАНИЕ ПОЛЯ - ОНО СВЯЗАНО С НАСТРОЙАМИ ДЛЯ МАРИИ*/
FIELD abs-discnt-rule  as integer

/*НЕ МЕНЯТЬ НАЗВАНИЕ ПОЛЯ - ОНО СВЯЗАНО С НАСТРОЙАМИ ДЛЯ МАРИИ*/
FIELD tot-discnt-rule  as integer


FIELD fact-qnty        like ub.gds-obj.fact-qnty
FIELD free-qnty        like ub.gds-obj.free-qnty
FIELD producer         as character format "X(40)"
FIELD ingredient       as character format "X(40)"
FIELD GTD              as character format "X(31)"
FIELD alpha1           like ub.goods.alpha
FIELD node-code        like ub.bar-code.node-code
FIELD okei             like ub.units.okei
FIELD kkt              as integer
FIELD is-gas           as logical
FIELD ptrl-as-good     as logical
FIELD taracode         as character
FIELD crf              as integer
FIELD new-good         as logical
FIELD rc               as recid
FIELD obj-type         as character
FIELD obj-code         as integer
field is-main-code     as logical
field bc-on-type       as character
field main-prt-b-code  as integer /*НЕПАРТИОННЫЙ ОСНОВНОЙ КОД для этого признака  - будет отличаться от b-code если b-code партионный*/
field ean-lz as character
field ean-rz as character
field code-short as  character
/*ресид записи от товаре или элементе спика товаров
для задания связи с таблицей налогов на товар*/
index pi is unique primary crf
index bc b-code
index pbc b-str
index igds gds-code
index mbc obj-type obj-code main-prt-b-code
.


define temp-table temp-dis-gds-rule no-undo
like ub.dis-gds-rule.

define temp-table cash-gds-discnt
FIELD crf              as integer
FIELD b-code            like ub.bar-code.b-code
field discnt-value as decimal
FIELD rule-num     as integer
field obj-type     as character
field obj-code     as integer
index pi is unique primary crf
index bc
b-code
obj-type
obj-code
rule-num
.


/* $Workfile: defc-gds.i $ e n d */