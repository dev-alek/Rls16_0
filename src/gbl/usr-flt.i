/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Работа с настройками пользователя в ubflt.usr-flt

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/22/03
Author: Bakhtadze Natalya
Creation date: 10/22/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-uf-List_        like ubflt.usr-flt.List_        no-undo .
define variable v-uf-Naim         like ubflt.usr-flt.Naim         no-undo .
define variable v-uf-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
define variable v-uf-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
define variable v-uf-type-price   like ubflt.usr-flt.type-price   no-undo .
define variable v-uf-type-val     like ubflt.usr-flt.type-val     no-undo .
define temp-table usr-flt_custom-labels no-undo like ub.custom-labels.

&scop bef-uf-cli-all-p               cli-all-p
&glob uf-cli-all-p                   '{&bef-uf-cli-all-p}':U
&glob label-uf-cli-all-p             "Параметры вызова справочника клиентов"
&glob tooltip-uf-cli-all-p           "Параметры по умолчанию, используемые для вызова справочника клиентов"
&glob List_-use-uf-cli-all-p        yes
&glob List_-type-uf-cli-all-p        {&type-char}
&glob List_-format-uf-cli-all-p      "X(256)"
/*шесть элементов списка с разделителем {&delim-par}*/
&glob Naim-use-uf-cli-all-p         yes
&glob Naim-type-uf-cli-all-p         {&type-char}
&glob Naim-format-uf-cli-all-p       "X(256)"
&glob print-graft-use-uf-cli-all-p  no
&glob sort-gr-use-uf-cli-all-p      no
&glob type-price-use-uf-cli-all-p   no
&glob type-val-use-uf-cli-all-p     no
&glob user-can-edit-uf-cli-all-p     no
&glob output-display-uf-cli-all-p    no
&glob other-uf-cli-all-p             ""


&scop bef-uf-oldscode                oldscode
&glob uf-oldscode                   '{&bef-uf-oldscode}':U
&glob label-uf-oldscode             "Настройки справочника неиспользуемых весовых кодов"
&glob tooltip-uf-oldscode           "Настройки справочника неиспользуемых весовых кодов"
&glob List_-use-uf-oldscode        yes
&glob List_-type-uf-oldscode        {&type-char}
&glob List_-format-uf-oldscode      "X(256)"
/*"in-date=":U +  string(v-in-date , "99/99/9999") +   ";" +  "fact-qnty=":U + string(v-fact-qnty)*/
&glob Naim-use-uf-oldscode         no
&glob Naim-type-uf-oldscode         {&type-char}
&glob Naim-format-uf-oldscode       "X(1)"
&glob print-graft-use-uf-oldscode  no
&glob sort-gr-use-uf-oldscode      no
&glob type-price-use-uf-oldscode   no
&glob type-val-use-uf-oldscode     no
&glob user-can-edit-uf-oldscode     no
&glob output-display-uf-oldscode    no
&glob other-uf-oldscode             ""

&scop bef-uf-gds-ref-p               gds-ref-p
&glob uf-gds-ref-p                   '{&bef-uf-gds-ref-p}':U
&glob label-uf-gds-ref-p             "Параметры вызова справочника товаров"
&glob tooltip-uf-gds-ref-p           "Параметры по умолчанию, используемые для вызова справочника товаров"
&glob List_-use-uf-gds-ref-p        yes
&glob List_-type-uf-gds-ref-p        {&type-char}
&glob List_-format-uf-gds-ref-p      "X(256)"
/*восемь элементов списка с разделителем {&delim-par}*/
/*
p-stat
p-list
p-cond
p-rec
p-grp
/*замена g-producer*/
p-cli-type
p-cli-code
p-other
*/
&glob Naim-use-uf-gds-ref-p         yes
&glob Naim-type-uf-gds-ref-p         {&type-char}
&glob Naim-format-uf-gds-ref-p       "X(8)"
/*два элемента списка с разделителем {&delim-par}*/
/*p-obj-type
p-obj-code
*/

&glob print-graft-use-uf-gds-ref-p  no
&glob sort-gr-use-uf-gds-ref-p      no
&glob type-price-use-uf-gds-ref-p   no
/*с объектами или без*/
&glob type-val-use-uf-gds-ref-p     yes
&glob user-can-edit-uf-gds-ref-p     no
&glob output-display-uf-gds-ref-p    no
&glob other-uf-gds-ref-p             ""


&scop bef-uf-gds-grp-p               gds-grp-p
&glob uf-gds-grp-p                   '{&bef-uf-gds-grp-p}':U
&glob label-uf-gds-grp-p             "Параметры вызова справочника групп товаров"
&glob tooltip-uf-gds-grp-p           "Параметры по умолчанию, используемые для вызова справочника групп товаров"
&glob List_-use-uf-gds-grp-p        yes
&glob List_-type-uf-gds-grp-p        {&type-char}
&glob List_-format-uf-gds-grp-p      "X(256)"
/*два элемента списка с разделителем {&delim-par}*/
/*gds-grp-row - recid на котором стоял*/
&glob Naim-use-uf-gds-grp-p         no
&glob Naim-type-uf-gds-grp-p         {&type-char}
&glob Naim-format-uf-gds-grp-p       "X(1)"
&glob print-graft-use-uf-gds-grp-p  no
&glob sort-gr-use-uf-gds-grp-p      no
&glob type-price-use-uf-gds-grp-p   no
&glob type-val-use-uf-gds-grp-p     no
&glob user-can-edit-uf-gds-grp-p     no
&glob output-display-uf-gds-grp-p    no
&glob other-uf-gds-grp-p             ""


&scop bef-uf-fbr-gds-grp-p               fbr-gds-grp-p
&glob uf-fbr-gds-grp-p                   '{&bef-uf-fbr-gds-grp-p}':U
&glob label-uf-fbr-gds-grp-p             "Параметры вызова справочника групп блюд"
&glob tooltip-uf-fbr-gds-grp-p           "Параметры по умолчанию, используемые для вызова справочника групп блюд"
&glob List_-use-uf-fbr-gds-grp-p         yes
&glob List_-type-uf-fbr-gds-grp-p        {&type-char}
&glob List_-format-uf-fbr-gds-grp-p      "X(256)"
&glob Naim-use-uf-fbr-gds-grp-p          no
&glob Naim-type-uf-fbr-gds-grp-p         {&type-char}
&glob Naim-format-uf-fbr-gds-grp-p       "X(1)"
&glob print-graft-use-uf-fbr-gds-grp-p   no
&glob sort-gr-use-uf-fbr-gds-grp-p       no
&glob type-price-use-uf-fbr-gds-grp-p    no
&glob type-val-use-uf-fbr-gds-grp-p      no
&glob user-can-edit-uf-fbr-gds-grp-p     no
&glob output-display-uf-fbr-gds-grp-p    no
&glob other-uf-fbr-gds-grp-p             ""


&scop bef-uf-cli-grp-p               cli-grp-p
&glob uf-cli-grp-p                   '{&bef-uf-cli-grp-p}':U
&glob label-uf-cli-grp-p             "Параметры вызова справочника групп клиентов"
&glob tooltip-uf-cli-grp-p           "Параметры по умолчанию, используемые для вызова справочника групп клиентов"
&glob List_-use-uf-cli-grp-p        yes
&glob List_-type-uf-cli-grp-p        {&type-char}
&glob List_-format-uf-cli-grp-p      "X(256)"
/*один элемент списка с разделителем {&delim-par}*/
/*cli-grp-row - recid на котором стоял*/
&glob Naim-use-uf-cli-grp-p         no
&glob Naim-type-uf-cli-grp-p         {&type-char}
&glob Naim-format-uf-cli-grp-p       "X(1)"
&glob print-graft-use-uf-cli-grp-p  no
&glob sort-gr-use-uf-cli-grp-p      no
&glob type-price-use-uf-cli-grp-p   no
&glob type-val-use-uf-cli-grp-p     no
&glob user-can-edit-uf-cli-grp-p     no
&glob output-display-uf-cli-grp-p    no
&glob other-uf-cli-grp-p             ""

&scop bef-uf-findoci-p               findoci-p
&glob uf-findoci-p                   '{&bef-uf-findoci-p}':U
&glob label-uf-findoci-p             "Параметры вызова карточки платежа"
&glob tooltip-uf-findoci-p           "Параметры по умолчанию, используемые для вызова карточки платежа"
&glob List_-use-uf-findoci-p        yes
&glob List_-type-uf-findoci-p        {&type-char}
&glob List_-format-uf-findoci-p      "X(256)"
/*один элемент списка с разделителем {&delim-par}*/
/*findoci-row - view может быть full brief или contract*/
&glob Naim-use-uf-findoci-p         no
&glob Naim-type-uf-findoci-p         {&type-char}
&glob Naim-format-uf-findoci-p       "X(1)"
&glob print-graft-use-uf-findoci-p  no
&glob sort-gr-use-uf-findoci-p      no
&glob type-price-use-uf-findoci-p   no
&glob type-val-use-uf-findoci-p     no
&glob user-can-edit-uf-findoci-p     no
&glob output-display-uf-findoci-p    no
&glob other-uf-findoci-p             ""

&scop bef-uf-findocs-p               findocs-p
&glob uf-findocs-p                   '{&bef-uf-findocs-p}':U
&glob label-uf-findocs-p             "Параметры вызова справочника платежей"
&glob tooltip-uf-findocs-p           "Параметры по умолчанию, используемые для вызова справочника платежей"
&glob List_-use-uf-findocs-p        yes
&glob List_-type-uf-findocs-p        {&type-char}
&glob List_-format-uf-findocs-p      "X(256)"
/*один элемент списка с разделителем {&delim-par}*/
/*findocs-row - view может быть full brief или contract*/
&glob Naim-use-uf-findocs-p         no
&glob Naim-type-uf-findocs-p         {&type-char}
&glob Naim-format-uf-findocs-p       "X(1)"
&glob print-graft-use-uf-findocs-p  no
&glob sort-gr-use-uf-findocs-p      no
&glob type-price-use-uf-findocs-p   no
&glob type-val-use-uf-findocs-p     no
&glob user-can-edit-uf-findocs-p     no
&glob output-display-uf-findocs-p    no
&glob other-uf-findocs-p             ""

&scop bef-uf-fin-obi               fin-obi
&glob uf-fin-obi                   '{&bef-uf-fin-obi}':U
&glob label-uf-fin-obi             "Параметры вызова карточки платежа"
&glob tooltip-uf-fin-obi           "Параметры по умолчанию, используемые для вызова карточки платежа"
&glob List_-use-uf-fin-obi          yes
&glob List_-type-uf-fin-obi        {&type-char}
&glob List_-format-uf-fin-obi      "X(256)"
/*один элемент списка с разделителем {&delim-par}*/
/*findoci-row - view может быть 1 2 */
&glob Naim-use-uf-fin-obi          no
&glob Naim-type-uf-fin-obi         {&type-char}
&glob Naim-format-uf-fin-obi       "X(1)"
&glob print-graft-use-uf-fin-obi   no
&glob sort-gr-use-uf-fin-obi       no
&glob type-price-use-uf-fin-obi    no
&glob type-val-use-uf-fin-obi      no
&glob user-can-edit-uf-fin-obi     no
&glob output-display-uf-fin-obi    no
&glob other-uf-fin-obi             ""


&scop bef-uf-skm-rep               skm-rep
&glob uf-skm-rep                   '{&bef-uf-skm-rep}':U
&glob label-uf-skm-rep             "Параметры вызова выгрузки файла данных по продажам по СКМ"
&glob tooltip-uf-skm-rep           "Параметры по умолчанию, используемые для вызова выгрузки файла данных по продажам по СКМ"
&glob List_-use-uf-skm-rep        yes
&glob List_-type-uf-skm-rep        {&type-char}
&glob List_-format-uf-skm-rep      "X(256)"
/*4 элемента списка с разделителем {&delim-par}*/
/* тип карты, соответсвующей СКМ  "X(8)"
код регина "99"
код Организации "9999"
код торгового предприятия "9999"*/
&glob Naim-use-uf-skm-rep         no
&glob Naim-type-uf-skm-rep         {&type-char}
&glob Naim-format-uf-skm-rep       "X(1)"
&glob print-graft-use-uf-skm-rep  no
&glob sort-gr-use-uf-skm-rep      no
&glob type-price-use-uf-skm-rep   no
&glob type-val-use-uf-skm-rep     no
&glob user-can-edit-uf-skm-rep     no
&glob output-display-uf-skm-rep    no
&glob other-uf-skm-rep             ""

&scop bef-uf-pychk-rep               pychk-rep
&glob uf-pychk-rep                   '{&bef-uf-pychk-rep}':U
&glob label-uf-pychk-rep             "Отчет разброски чеков по типам касс платежа и НДС"
&glob tooltip-uf-pychk-rep           "Параметры вызова отчета разброски чеков по типам касс платежа и НДС-введенные пользователем группы типов кассовыъх платежей"
&glob List_-use-uf-pychk-rep        yes
&glob List_-type-uf-pychk-rep        {&type-char}
&glob List_-format-uf-pychk-rep      "X(256)"
/* список с разделителем {&delim-par}*/
/* номер группы типов касс платежей1=название группы1{&delim-par}номер группы типов касс платежей2=название группы2...*/
&glob Naim-use-uf-pychk-rep         yes
&glob Naim-type-uf-pychk-rep         {&type-char}
&glob Naim-format-uf-pychk-rep       "X(256)"
/* список с разделителем {&delim-par}*/
/* код платежа11-код валюты1;1код платежа12-код валюты12;код платежа13-код валюты13{&delim-par}код платежа21-код валюты21;код платежа22-код валюты22;код платежа32-код валюты32   */
&glob print-graft-use-uf-pychk-rep  no
&glob sort-gr-use-uf-pychk-rep      no
&glob type-price-use-uf-pychk-rep   no
&glob type-val-use-uf-pychk-rep     no
&glob user-can-edit-uf-pychk-rep     no
&glob output-display-uf-pychk-rep    no
&glob other-uf-pychk-rep             ""


&scop bef-uf-imp-goods               imp-goods
&glob uf-imp-goods                   '{&bef-uf-imp-goods}':U
&glob label-uf-imp-goods             "Импорт в карточке товара"
&glob tooltip-uf-imp-goods           "Заполнение по умолчанию параметров импорта товаров из карточки товара"
&glob List_-use-uf-imp-goods        yes
&glob List_-type-uf-imp-goods        {&type-char}
&glob List_-format-uf-imp-goods      "X(256)"
/* список с разделителем {&delim-par} логических флагов ИМПОРТИРОВАТЬ ИЛИ НЕТ*/
/*artic,name,engl-name,unit-base,VAT-code,SLT-code,struct,tnved,attrib,destin,sert,user-rule*/
&glob Naim-use-uf-imp-goods         yes
&glob Naim-type-uf-imp-goods         {&type-char}
&glob Naim-format-uf-imp-goods       "X(256)"
/*имя стартовой директории импорта */
&glob print-graft-use-uf-imp-goods  no
&glob sort-gr-use-uf-imp-goods      no
&glob type-price-use-uf-imp-goods   no
&glob type-val-use-uf-imp-goods     no
&glob user-can-edit-uf-imp-goods     no
&glob output-display-uf-imp-goods    no
&glob other-uf-imp-goods             ""


&scop bef-uf-discards-p             discards-p
&glob uf-discards-p                 '{&bef-uf-discards-p}':U
&glob label-uf-discards-p           "Справочник ДК"
&glob tooltip-uf-discards-p         "Справочник дисконтных карт"
&glob List_-use-uf-discards-p       yes
&glob List_-type-uf-discards-p      {&type-char}
&glob List_-format-uf-discards-p    "X(256)"
/* список с разделителем {&delim-par}
recid записи для позиционировани
номер карты длина поля в броузе -
имя клиента длина поля в броузе -
№ карты к которой перевыпущена текущая карта длина поля в броузе -
тип+код клиента  длина поля в броузе -
*/
&glob Naim-use-uf-discards-p       no
&glob Naim-type-uf-discards-p       {&type-char}
&glob Naim-format-uf-discards-p     "X(256)"
/*имя стартовой директории импорта */
&glob print-graft-use-uf-discards-p  no
&glob sort-gr-use-uf-discards-p      no
&glob type-price-use-uf-discards-p   no
&glob type-val-use-uf-discards-p     no
&glob user-can-edit-uf-discards-p     no
&glob output-display-uf-discards-p    no
&glob other-uf-discards-p             ""

&scop bef-uf-finsttms-p               finsttms-p
&glob uf-finsttms-p                   '{&bef-uf-finsttms-p}':U
&glob label-uf-finsttms-p             "Параметры вызова справочника банковских выписок"
&glob tooltip-uf-finsttms-p           "Параметры по умолчанию, используемые для вызова справочника банковских выписок"
&glob List_-use-uf-finsttms-p        yes
&glob List_-type-uf-finsttms-p        {&type-char}
&glob List_-format-uf-finsttms-p      "X(256)"
/*один элемент списка с разделителем {&delim-par}*/
&glob Naim-use-uf-finsttms-p         no
&glob Naim-type-uf-finsttms-p         {&type-char}
&glob Naim-format-uf-finsttms-p       "X(1)"
&glob print-graft-use-uf-finsttms-p  no
&glob sort-gr-use-uf-finsttms-p      no
&glob type-price-use-uf-finsttms-p   no
&glob type-val-use-uf-finsttms-p     no
&glob user-can-edit-uf-finsttms-p     no
&glob output-display-uf-finsttms-p    no
&glob other-uf-finsttms-p             ""

&scop bef-uf-fin-ob             fin-ob-p
&glob uf-fin-ob                 '{&bef-uf-fin-ob}':U
&glob label-uf-fin-ob           "Список фин.обязательств"
&glob tooltip-uf-fin-ob         "Список фин.обязательств"
&glob List_-use-uf-fin-ob       yes
&glob List_-type-uf-fin-ob      {&type-char}
&glob List_-format-uf-fin-ob    "X(256)"
/*
список с порядком полей в броузе {&delim-par}
ширина поля Наименование {&delim-par}
ширина поля условие генерации {&delim-par}
*/
&glob Naim-use-uf-fin-ob       no
&glob Naim-type-uf-fin-ob       {&type-char}
&glob Naim-format-uf-fin-ob     "X(256)"
&glob print-graft-use-uf-fin-ob  no
&glob sort-gr-use-uf-fin-ob      no
&glob type-price-use-uf-fin-ob   no
&glob type-val-use-uf-fin-ob     no
&glob user-can-edit-uf-fin-ob     no
&glob output-display-uf-fin-ob    no
&glob other-uf-fin-ob             ""


&scop bef-uf-planplat             planplat-p
&glob uf-planplat                 '{&bef-uf-planplat}':U
&glob label-uf-planplat           "Планирование платежей"
&glob tooltip-uf-planplat         "Планирование платежей"
&glob List_-use-uf-planplat       yes
&glob List_-type-uf-planplat      {&type-char}
&glob List_-format-uf-planplat    "X(256)"
/*
список с порядком полей в броузе ф-о {&delim-par}
список с порядком полей в броузе плат. {&delim-par}
ширина поля Наименование 1 в броузе ф-о  {&delim-par}
ширина поля Наименование 2 в броузе ф-о  {&delim-par}
ширина поля условие генерации {&delim-par}
ширина поля Наименование 1 в броузе плат. {&delim-par}
ширина поля Наименование 2 в броузе плат. {&delim-par}
*/
&glob Naim-use-uf-planplat       no
&glob Naim-type-uf-planplat       {&type-char}
&glob Naim-format-uf-planplat     "X(256)"
&glob print-graft-use-uf-planplat  no
&glob sort-gr-use-uf-planplat      no
&glob type-price-use-uf-planplat   no
&glob type-val-use-uf-planplat     no
&glob user-can-edit-uf-planplat     no
&glob output-display-uf-planplat    no
&glob other-uf-planplat             ""

&scop bef-uf-cli-zakz              cli-zakz-p
&glob uf-cli-zakz                 '{&bef-uf-cli-zakz}':U
&glob label-uf-cli-zakz           "Форма ввода заказа"
&glob tooltip-uf-cli-zakz         "Форма ввода заказа"
&glob List_-use-uf-cli-zakz       yes
&glob List_-type-uf-cli-zakz      {&type-char}
&glob List_-format-uf-cli-zakz    "X(256)"
/*
ширина поля Artic {&delim-par}
ширина поля Наименование {&delim-par}
*/
&glob Naim-use-uf-cli-zakz       no
&glob Naim-type-uf-cli-zakz       {&type-char}
&glob Naim-format-uf-cli-zakz     "X(256)"
&glob print-graft-use-uf-cli-zakz  no
&glob sort-gr-use-uf-cli-zakz      no
&glob type-price-use-uf-cli-zakz   no
&glob type-val-use-uf-cli-zakz     no
&glob user-can-edit-uf-cli-zakz     no
&glob output-display-uf-cli-zakz    no
&glob other-uf-cli-zakz             ""

&scop bef-uf-cli-zakzOP              cli-zakz-p{&bef-O-P}
&glob uf-cli-zakzOP                 '{&bef-uf-cli-zakzOP}':U
&glob label-uf-cli-zakzOP           "Форма ввода заказа ОП"
&glob tooltip-uf-cli-zakzOP         "Форма ввода заказа ОП"
&glob List_-use-uf-cli-zakzOP       yes
&glob List_-type-uf-cli-zakzOP      {&type-char}
&glob List_-format-uf-cli-zakzOP    "X(256)"
&glob Naim-use-uf-cli-zakzOP       no
&glob Naim-type-uf-cli-zakzOP       {&type-char}
&glob Naim-format-uf-cli-zakzOP     "X(256)"
&glob print-graft-use-uf-cli-zakzOP  no
&glob sort-gr-use-uf-cli-zakzOP      no
&glob type-price-use-uf-cli-zakzOP   no
&glob type-val-use-uf-cli-zakzOP     no
&glob user-can-edit-uf-cli-zakzOP     no
&glob output-display-uf-cli-zakzOP    no
&glob other-uf-cli-zakzOP             ""

&scop bef-uf-cli-zakzFP              cli-zakz-p{&bef-F-P}
&glob uf-cli-zakzFP                 '{&bef-uf-cli-zakzFP}':U
&glob label-uf-cli-zakzFP           "Форма ввода заказа ФП"
&glob tooltip-uf-cli-zakzFP         "Форма ввода заказа ФП"
&glob List_-use-uf-cli-zakzFP       yes
&glob List_-type-uf-cli-zakzFP      {&type-char}
&glob List_-format-uf-cli-zakzFP    "X(256)"
&glob Naim-use-uf-cli-zakzFP       no
&glob Naim-type-uf-cli-zakzFP       {&type-char}
&glob Naim-format-uf-cli-zakzFP     "X(256)"
&glob print-graft-use-uf-cli-zakzFP  no
&glob sort-gr-use-uf-cli-zakzFP      no
&glob type-price-use-uf-cli-zakzFP   no
&glob type-val-use-uf-cli-zakzFP     no
&glob user-can-edit-uf-cli-zakzFP     no
&glob output-display-uf-cli-zakzFP    no
&glob other-uf-cli-zakzFP             ""

&scop bef-uf-cli-zakzOf              cli-zakz-p{&bef-O-F}
&glob uf-cli-zakzOf                 '{&bef-uf-cli-zakzOF}':U
&glob label-uf-cli-zakzOf           "Форма ввода заказа ОФ"
&glob tooltip-uf-cli-zakzOf         "Форма ввода заказа ОФ"
&glob List_-use-uf-cli-zakzOf       yes
&glob List_-type-uf-cli-zakzOf      {&type-char}
&glob List_-format-uf-cli-zakzOf    "X(256)"
&glob Naim-use-uf-cli-zakzOf       no
&glob Naim-type-uf-cli-zakzOf       {&type-char}
&glob Naim-format-uf-cli-zakzOf     "X(256)"
&glob print-graft-use-uf-cli-zakzOf  no
&glob sort-gr-use-uf-cli-zakzOf      no
&glob type-price-use-uf-cli-zakzOf   no
&glob type-val-use-uf-cli-zakzOf     no
&glob user-can-edit-uf-cli-zakzOf     no
&glob output-display-uf-cli-zakzOf    no
&glob other-uf-cli-zakzOf             ""



&scop bef-uf-list-abc            list-abc-p
&glob uf-list-abc                 '{&bef-uf-list-abc}':U
&glob label-uf-list-abc           "Список заголовков ABC-анализа"
&glob tooltip-uf-list-abc         "Список заголовков ABC-анализа"
&glob List_-use-uf-list-abc       yes
&glob List_-type-uf-list-abc      {&type-char}
&glob List_-format-uf-list-abc    "X(256)"
/*
список с порядком полей в броузе {&delim-par}
ширина поля Наименование {&delim-par}
ширина поля Критерий {&delim-par}
*/
&glob Naim-use-uf-list-abc          no
&glob Naim-type-uf-list-abc         {&type-char}
&glob Naim-format-uf-list-abc       "X(256)"
&glob print-graft-use-uf-list-abc   no
&glob sort-gr-use-uf-list-abc       no
&glob type-price-use-uf-list-abc    no
&glob type-val-use-uf-list-abc      no
&glob user-can-edit-uf-list-abc     no
&glob output-display-uf-list-abc    no
&glob other-uf-list-abc             ""

&scop bef-uf-abc             abc-p
&glob uf-abc                 '{&bef-uf-abc}':U
&glob label-uf-abc           "ABC-анализ"
&glob tooltip-uf-abc         "ABC-анализ"
&glob List_-use-uf-abc       yes
&glob List_-type-uf-abc      {&type-char}
&glob List_-format-uf-abc    "X(256)"
/*
список с порядком полей в броузе {&delim-par}
ширина поля artic {&delim-par}
ширина поля название {&delim-par}
*/
&glob Naim-use-uf-abc          no
&glob Naim-type-uf-abc         {&type-char}
&glob Naim-format-uf-abc       "X(256)"
&glob print-graft-use-uf-abc   no
&glob sort-gr-use-uf-abc       no
&glob type-price-use-uf-abc    no
&glob type-val-use-uf-abc      no
&glob user-can-edit-uf-abc     no
&glob output-display-uf-abc    no
&glob other-uf-abc             ""

&scop bef-uf-ord-rc             ord-rc-p
&glob uf-ord-rc                 '{&bef-uf-ord-rc}':U
&glob label-uf-ord-rc           "Заказ О-РЦ"
&glob tooltip-uf-ord-rc         "Заказ О-РЦ"
&glob List_-use-uf-ord-rc       yes
&glob List_-type-uf-ord-rc      {&type-char}
&glob List_-format-uf-ord-rc    "X(256)"
/*
список с порядком полей в броузе {&delim-par}
ширина поля  {&delim-par}
*/
&glob Naim-use-uf-ord-rc       no
&glob Naim-type-uf-ord-rc       {&type-char}
&glob Naim-format-uf-ord-rc     "X(256)"
&glob print-graft-use-uf-ord-rc  no
&glob sort-gr-use-uf-ord-rc      no
&glob type-price-use-uf-ord-rc   no
&glob type-val-use-uf-ord-rc     no
&glob user-can-edit-uf-ord-rc     no
&glob output-display-uf-ord-rc    no
&glob other-uf-ord-rc             ""

&scop bef-uf-cfin-ob             cfin-ob-p
&glob uf-cfin-ob                 '{&bef-uf-cfin-ob}':U
&glob label-uf-cfin-ob           "Список удаленных фин.обязательств"
&glob tooltip-uf-cfin-ob         "Список удаленных фин.обязательств"
&glob List_-use-uf-cfin-ob       yes
&glob List_-type-uf-cfin-ob      {&type-char}
&glob List_-format-uf-cfin-ob    "X(256)"
/*
список с порядком полей в броузе {&delim-par}
ширина поля Наименование {&delim-par}
ширина поля условие генерации {&delim-par}
*/
&glob Naim-use-uf-cfin-ob       no
&glob Naim-type-uf-cfin-ob       {&type-char}
&glob Naim-format-uf-cfin-ob     "X(256)"
&glob print-graft-use-uf-cfin-ob  no
&glob sort-gr-use-uf-cfin-ob      no
&glob type-price-use-uf-cfin-ob   no
&glob type-val-use-uf-cfin-ob     no
&glob user-can-edit-uf-cfin-ob     no
&glob output-display-uf-cfin-ob    no
&glob other-uf-cfin-ob             ""

&scop bef-uf-color             color-p
&glob uf-color                 '{&bef-uf-color}':U
&glob label-uf-color           "Раскрасить экран"
&glob tooltip-uf-color         "Изменение цветовой палитры брауза"
&glob List_-use-uf-color       yes
&glob List_-type-uf-color      {&type-char}
&glob List_-format-uf-color    "X(256)"
/* yes,no */
&glob Naim-use-uf-color         no
&glob Naim-type-uf-color        {&type-char}
&glob Naim-format-uf-color      "X(256)"
&glob print-graft-use-uf-color  no
&glob sort-gr-use-uf-color      yes
&glob type-price-use-uf-color   no
&glob type-val-use-uf-color     no
&glob user-can-edit-uf-color     no
&glob output-display-uf-color    no
&glob other-uf-color             ""

&scop bef-uf-bon1-rep               bon1-rep
&glob uf-bon1-rep                   '{&bef-uf-bon1-rep}':U
&glob label-uf-bon1-rep             "НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"
&glob tooltip-uf-bon1-rep           "Параметры вызова отчета НАЧИСЛЕНИЕ И СПИСАНИЕ БОНУСОВ по программе БОНУС-КЛУБ"
&glob List_-use-uf-bon1-rep        yes
&glob List_-type-uf-bon1-rep        {&type-char}
&glob List_-format-uf-bon1-rep      "X(256)"
/*1 элемент списка с разделителем {&delim-par}*/
/*
код бонусной схемы "999999999"
*/
&glob Naim-use-uf-bon1-rep         no
&glob Naim-type-uf-bon1-rep         {&type-char}
&glob Naim-format-uf-bon1-rep       "X(1)"
&glob print-graft-use-uf-bon1-rep  no
&glob sort-gr-use-uf-bon1-rep      no
&glob type-price-use-uf-bon1-rep   no
&glob type-val-use-uf-bon1-rep     no
&glob user-can-edit-uf-bon1-rep     no
&glob output-display-uf-bon1-rep    no
&glob other-uf-bon1-rep             ""

&scop bef-uf-ord-sost             ord-sost-p
&glob uf-ord-sost                 '{&bef-uf-ord-sost}':U
&glob label-uf-ord-sost           "Состояние заказа"
&glob tooltip-uf-ord-sost         "Просмотр несоответствий поставок и накладных по заказам ОП ФП и ПО"
&glob List_-use-uf-ord-sost       yes
&glob List_-type-uf-ord-sost      {&type-char}
&glob List_-format-uf-ord-sost    "X(256)"
/*
ширина поля Артикул {&delim-par}
ширина поля Наименование товара {&delim-par}
ширина поля Количество по поставкам {&delim-par}
*/
&glob Naim-use-uf-ord-sost       no
&glob Naim-type-uf-ord-sost       {&type-char}
&glob Naim-format-uf-ord-sost     "X(256)"
&glob print-graft-use-uf-ord-sost  no
&glob sort-gr-use-uf-ord-sost      no
&glob type-price-use-uf-ord-sost   no
&glob type-val-use-uf-ord-sost     no
&glob user-can-edit-uf-ord-sost     no
&glob output-display-uf-ord-sost    no
&glob other-uf-ord-sost             ""

&scop bef-uf-e-shift             e-shift
&glob uf-e-shift                 '{&bef-uf-e-shift}':U
&glob label-uf-e-shift           "Сменный отчет"
&glob tooltip-uf-e-shift         "Сменный отчет"
&glob List_-use-uf-e-shift       yes
&glob List_-type-uf-e-shift      {&type-char}
&glob List_-format-uf-e-shift    "X(256)"
/*
список с порядком полей в броузе {&delim-par}
*/
&glob Naim-use-uf-e-shift          no
&glob Naim-type-uf-e-shift         {&type-char}
&glob Naim-format-uf-e-shift       "X(256)"
&glob print-graft-use-uf-e-shift   no
&glob sort-gr-use-uf-e-shift       no
&glob type-price-use-uf-e-shift    no
&glob type-val-use-uf-e-shift      no
&glob user-can-edit-uf-e-shift     no
&glob output-display-uf-e-shift    no
&glob other-uf-e-shift             ""

&scop bef-uf-all-docs             all-docs-p
&glob uf-all-docs                 '{&bef-uf-all-docs}':U
&glob label-uf-all-docs           "Список накладных"
&glob tooltip-uf-all-docs         "Список накладных"
&glob List_-use-uf-all-docs       yes
&glob List_-type-uf-all-docs      {&type-char}
&glob List_-format-uf-all-docs    "X(256)"
/*
Список очередностей колонок {&delim-par}
Список ширин колонок {&delim-par}
Список видимости колонок {&delim-par}
*/
&glob Naim-use-uf-all-docs       no
&glob Naim-type-uf-all-docs       {&type-char}
&glob Naim-format-uf-all-docs     "X(256)"
&glob print-graft-use-uf-all-docs  no
&glob sort-gr-use-uf-all-docs      no
&glob type-price-use-uf-all-docs   no
&glob type-val-use-uf-all-docs     no
&glob user-can-edit-uf-all-docs     no
&glob output-display-uf-all-docs    no
&glob other-uf-all-docs             ""


&scop bef-uf-gdsreffi             gdsreffi
&glob uf-gdsreffi                 '{&bef-uf-gdsreffi}':U
&glob label-uf-gdsreffi           "Справочник товаров - доп поля"
&glob tooltip-uf-gdsreffi         "Справочник товаров - доп поля"
&glob List_-use-uf-gdsreffi       yes
&glob List_-type-uf-gdsreffi      {&type-char}
&glob List_-format-uf-gdsreffi    "X(256)"
/*
Список очередностей колонок {&delim-par}
Список ширин колонок {&delim-par}
Список видимости колонок {&delim-par}
*/
&glob Naim-use-uf-gdsreffi       no
&glob Naim-type-uf-gdsreffi       {&type-char}
&glob Naim-format-uf-gdsreffi     "X(256)"
&glob print-graft-use-uf-gdsreffi  no
&glob sort-gr-use-uf-gdsreffi      no
&glob type-price-use-uf-gdsreffi   no
&glob type-val-use-uf-gdsreffi     no
&glob user-can-edit-uf-gdsreffi     no
&glob output-display-uf-gdsreffi    no
&glob other-uf-gdsreffi             ""
&glob gdsreffi-ord 'goods.gds-name,goods.#prod-name,goods.#prt-root-name,goods.negative-rest,gds-obj.#VAT-PC,goods.ALPHA1,gds-obj.in-date':U
&glob gdsreffi-siz '?,?,?,?,?,?,?,?':U


&scop bef-uf-gdsfrmfi             gdsfrmfi
&glob uf-gdsfrmfi                 '{&bef-uf-gdsfrmfi}':U
&glob label-uf-gdsfrmfi           "Карточка товара - доп поля"
&glob tooltip-uf-gdsfrmfi         "Карточка товара - доп поля"
&glob List_-use-uf-gdsfrmfi       yes
&glob List_-type-uf-gdsfrmfi      {&type-char}
&glob List_-format-uf-gdsfrmfi    "X(256)"
/*
Список очередностей колонок {&delim-par}
Список ширин колонок {&delim-par}
Список видимости колонок {&delim-par}
*/
&glob Naim-use-uf-gdsfrmfi       no
&glob Naim-type-uf-gdsfrmfi       {&type-char}
&glob Naim-format-uf-gdsfrmfi     "X(256)"
&glob print-graft-use-uf-gdsfrmfi  no
&glob sort-gr-use-uf-gdsfrmfi      no
&glob type-price-use-uf-gdsfrmfi   no
&glob type-val-use-uf-gdsfrmfi     no
&glob user-can-edit-uf-gdsfrmfi     no
&glob output-display-uf-gdsfrmfi    no
&glob other-uf-gdsfrmfi             ""
&glob gdsfrmfi-ord '':U
&glob gdsfrmfi-siz '?,?,?,?':U

&scop bef-uf-seqeallo               seqeallo
&glob uf-seqeallo                   '{&bef-uf-seqeallo}':U
&glob label-uf-seqeallo             "Порядок колонок в АВТО-ЗАКАЗЕ"
&glob tooltip-uf-seqeallo           "Порядок колонок в РАСЧЕТЕ потребности заказа и его импорте"
&glob List_-use-uf-seqeallo          yes
&glob List_-type-uf-seqeallo        {&type-char}
&glob List_-format-uf-seqeallo      "X(256)"
/*один элемент списка с разделителем {&delim-par}*/
&glob Naim-use-uf-seqeallo          no
&glob Naim-type-uf-seqeallo         {&type-char}
&glob Naim-format-uf-seqeallo       "X(1)"
&glob print-graft-use-uf-seqeallo   no
&glob sort-gr-use-uf-seqeallo       no
&glob type-price-use-uf-seqeallo    no
&glob type-val-use-uf-seqeallo      no
&glob user-can-edit-uf-seqeallo     no
&glob output-display-uf-seqeallo    no
&glob other-uf-seqeallo             ""


&scop bef-uf-contspec              contspec-p
&glob uf-contspec                 '{&bef-uf-contspec}':U
&glob label-uf-contspec           "Спецификация"
&glob tooltip-uf-contspec         "Спецификаци "
&glob List_-use-uf-contspec       yes
&glob List_-type-uf-contspec      {&type-char}
&glob List_-format-uf-contspec    "X(256)"
/*
ширина поля gds-name {&delim-par}
ширина поля Наименование {&delim-par}
*/
&glob Naim-use-uf-contspec       no
&glob Naim-type-uf-contspec       {&type-char}
&glob Naim-format-uf-contspec     "X(256)"
&glob print-graft-use-uf-contspec  no
&glob sort-gr-use-uf-contspec      no
&glob type-price-use-uf-contspec  no
&glob type-val-use-uf-contspec    no
&glob user-can-edit-uf-contspec     no
&glob output-display-uf-contspec    no
&glob other-uf-contspec             ""

&scop bef-uf-mpl-gds             mpl-gds-p
&glob uf-mpl-gds                 '{&bef-uf-mpl-gds}':U
&glob label-uf-mpl-gds           "Список цен по товару"
&glob tooltip-uf-mpl-gds         "Список цен по товару"
&glob List_-use-uf-mpl-gds       yes
&glob List_-type-uf-mpl-gds      {&type-char}
&glob List_-format-uf-mpl-gds    "X(256)"
/*
список с порядком полей в броузе {&delim-par}
ширина поля1  {&delim-par}
5 штук
*/
&glob Naim-use-uf-mpl-gds       no
&glob Naim-type-uf-mpl-gds       {&type-char}
&glob Naim-format-uf-mpl-gds     "X(256)"
&glob print-graft-use-uf-mpl-gds  no
&glob sort-gr-use-uf-mpl-gds      no
&glob type-price-use-uf-mpl-gds   no
&glob type-val-use-uf-mpl-gds     no
&glob user-can-edit-uf-mpl-gds     no
&glob output-display-uf-mpl-gds    no
&glob other-uf-mpl-gds             ""

&scop bef-uf-tpl-mode             tpl-mode-p
&glob uf-tpl-mode                 '{&bef-uf-tpl-mode}':U
&glob label-uf-tpl-mode           "Список мод"
&glob tooltip-uf-tpl-mode         "Список мод"
&glob List_-use-uf-tpl-mode       yes
&glob List_-type-uf-tpl-mode      {&type-char}
&glob List_-format-uf-tpl-mode    "X(256)"
/*
список мод вызова жестких фильтров и сортировок в справочнике ТПЛ {&delim-par}
main
obj
avtop
*/
&glob Naim-use-uf-tpl-mode       no
&glob Naim-type-uf-tpl-mode       {&type-char}
&glob Naim-format-uf-tpl-mode     "X(256)"
&glob print-graft-use-uf-tpl-mode  no
&glob sort-gr-use-uf-tpl-mode      no
&glob type-price-use-uf-tpl-mode   no
&glob type-val-use-uf-tpl-mode     no
&glob user-can-edit-uf-tpl-mode     no
&glob output-display-uf-tpl-mode    no
&glob other-uf-tpl-mode             ""


&scop bef-uf-wthrst              wthrst
&glob uf-wthrst                  '{&bef-uf-wthrst}':U
&glob label-uf-wthrst            "Остатки МЦ"
&glob tooltip-uf-wthrst          "Остатки МЦ"
&glob List_-use-uf-wthrst        yes
&glob List_-type-uf-wthrst       {&type-char}
&glob List_-format-uf-wthrst     "X(256)"
&glob Naim-use-uf-wthrst         yes
&glob Naim-type-uf-wthrst        {&type-char}
&glob Naim-format-uf-wthrst      "X(256)"
&glob print-graft-use-uf-wthrst  YES
&glob sort-gr-use-uf-wthrst      YES
&glob type-price-use-uf-wthrst   YES
&glob user-can-edit-uf-wthrst     no
&glob output-display-uf-wthrst    no
&glob other-uf-wthrst             ""

&scop bef-uf-wthcom              wthcom
&glob uf-wthcom                  '{&bef-uf-wthcom}':U
&glob label-uf-wthcom            "Сводный отчет о реализованных талонах"
&glob tooltip-uf-wthcom          "Сводный отчет о реализованных талонах"
&glob List_-use-uf-wthcom        yes
&glob List_-type-uf-wthcom       {&type-char}
&glob List_-format-uf-wthcom     "X(256)"
&glob Naim-use-uf-wthcom         yes
&glob Naim-type-uf-wthcom        {&type-char}
&glob Naim-format-uf-wthcom      "X(256)"
&glob print-graft-use-uf-wthcom  YES
&glob sort-gr-use-uf-wthcom      YES
&glob type-price-use-uf-wthcom    no
&glob user-can-edit-uf-wthcom     no
&glob output-display-uf-wthcom    no
&glob other-uf-wthcom             ""

&scop bef-uf-users-1              users-1
&glob uf-users-1                  '{&bef-uf-users-1}':U
&glob label-uf-users-1            "Пользователи"
&glob tooltip-uf-users-1          "Список пользователей системы 1"
&glob List_-use-uf-users-1        yes
&glob List_-type-uf-users-1       {&type-char}
&glob List_-format-uf-users-1     "X(256)"
&glob Naim-use-uf-users-1         yes
&glob Naim-type-uf-users-1        {&type-char}
&glob Naim-format-uf-users-1      "X(256)"
&glob print-graft-use-uf-users-1  no
&glob sort-gr-use-uf-users-1      no
&glob type-price-use-uf-users-1   no
&glob user-can-edit-uf-users-1    no
&glob output-display-uf-users-1   no
&glob other-uf-users-1            ""

&scop bef-uf-users-2              users-2
&glob uf-users-2                  '{&bef-uf-users-2}':U
&glob label-uf-users-2            "Пользователи"
&glob tooltip-uf-users-2          "Список пользователей системы 2"
&glob List_-use-uf-users-2        yes
&glob List_-type-uf-users-2       {&type-char}
&glob List_-format-uf-users-2     "X(256)"
&glob Naim-use-uf-users-2         yes
&glob Naim-type-uf-users-2        {&type-char}
&glob Naim-format-uf-users-2      "X(256)"
&glob print-graft-use-uf-users-2  no
&glob sort-gr-use-uf-users-2      no
&glob type-price-use-uf-users-2   no
&glob user-can-edit-uf-users-2    no
&glob output-display-uf-users-2   no
&glob other-uf-users-2            ""

&scop bef-uf-bge-dper             bge-dper.w
&glob uf-bge-dper                 '{&bef-uf-bge-dper}':U
&glob label-uf-bge-dper           "Параметры для выгрузки документов"
&glob tooltip-uf-bge-dper         "Параметры для выгрузки документов"
&glob List_-use-uf-bge-dper       yes
&glob List_-type-uf-bge-dper      {&type-char}
&glob List_-format-uf-bge-dper    "X(256)"
&glob Naim-use-uf-bge-dper        yes
&glob Naim-type-uf-bge-dper       {&type-char}
&glob Naim-format-uf-bge-dper     "X(256)"
&glob print-graft-use-uf-bge-dper no
&glob sort-gr-use-uf-bge-dper     no
&glob type-price-use-uf-bge-dper  no
&glob user-can-edit-uf-bge-dper   no
&glob output-display-uf-bge-dper  no
&glob other-uf-bge-dper           ""

&scop bef-uf-bge-active-vbrr              bge-active-vbrr
&glob uf-bge-active-vbrr                  '{&bef-uf-bge-active-vbrr}':U
&glob label-uf-bge-active-vbrr            "Параметры для выгрузки документов"
&glob tooltip-uf-bge-active-vbrr          "Параметры для выгрузки документов"
&glob List_-use-uf-bge-active-vbrr        yes
&glob List_-type-uf-bge-active-vbrr       {&type-char}
&glob List_-format-uf-bge-active-vbrr     "X(256)"
&glob Naim-use-uf-bge-active-vbrr         yes
&glob Naim-type-uf-bge-active-vbrr        {&type-char}
&glob Naim-format-uf-bge-active-vbrr      "X(256)"
&glob print-graft-use-uf-bge-active-vbrrr no
&glob sort-gr-use-uf-bge-active-vbrr      no
&glob type-price-use-uf-bge-active-vbrr   no
&glob user-can-edit-uf-bge-active-vbrr    no
&glob output-display-uf-bge-active-vbrr   no
&glob other-uf-bge-active-vbrr            ""

&scop bef-uf-bge-dper-new             bge-dper-new
&glob uf-bge-dper-new                 '{&bef-uf-bge-dper-new}':U
&glob label-uf-bge-dper-new           "Параметры для выгрузки документов(расширенный)"
&glob tooltip-uf-bge-dper-new         "Параметры для выгрузки документов(расширенный)"
&glob List_-use-uf-bge-dper-new       yes
&glob List_-type-uf-bge-dper-new      {&type-char}
&glob List_-format-uf-bge-dper-new    "X(256)"
&glob Naim-use-uf-bge-dper-new        yes
&glob Naim-type-uf-bge-dper-new       {&type-char}
&glob Naim-format-uf-bge-dper-new     "X(256)"
&glob print-graft-use-uf-bge-dper-new no
&glob sort-gr-use-uf-bge-dper-new     no
&glob type-price-use-uf-bge-dper-new  no
&glob user-can-edit-uf-bge-dper-new   no
&glob output-display-uf-bge-dper-new  no
&glob other-uf-bge-dper-new           ""

&scop bef-uf-i-egais             cus/i-egais.w
&glob uf-i-egais                 '{&bef-uf-i-egais}':U
&glob label-uf-i-egais           "Интерфейс импорта классификатора ЕГАИС"
&glob tooltip-uf-i-egais         "Интерфейс импорта классификатора ЕГАИС"
&glob List_-use-uf-i-egais       yes
&glob List_-type-uf-i-egais      {&type-char}
&glob List_-format-uf-i-egais    "X(256)"
&glob Naim-use-uf-i-egais        no
&glob Naim-type-uf-i-egais       {&type-char}
&glob Naim-format-uf-i-egais     "X(256)"
&glob print-graft-use-uf-i-egais no
&glob sort-gr-use-uf-i-egais     no
&glob type-price-use-uf-i-egais  no
&glob user-can-edit-uf-i-egais   no
&glob output-display-uf-i-egais  no
&glob other-uf-i-egais           ""

&scop bef-uf-alc-rees             alc-rees
&glob uf-alc-rees                 '{&bef-uf-alc-rees}':U
&glob label-uf-alc-rees           "Реестр документов ЕГАИС"
&glob tooltip-uf-alc-rees         "Реестр документов ЕГАИС"
&glob List_-use-uf-alc-rees        yes
&glob List_-type-uf-alc-rees      {&type-char}
&glob List_-format-uf-alc-rees    "X(256)"
&glob Naim-use-uf-alc-rees        yes
&glob Naim-type-uf-alc-rees       {&type-char}
&glob Naim-format-uf-alc-rees     "X(256)"
&glob print-graft-use-uf-alc-rees no
&glob sort-gr-use-uf-alc-rees     no
&glob type-price-use-uf-alc-rees  no
&glob user-can-edit-uf-alc-rees   no
&glob output-display-uf-alc-rees  no
&glob other-uf-alc-rees           ""

&scop bef-uf-e-optprc             e-optprc.w
&glob uf-e-optprc                 '{&bef-uf-e-optprc}':U
&glob label-uf-e-optprc           "Оптовый прайс-лист"
&glob tooltip-uf-e-optprc         "Оптовый прайс-лист"
&glob List_-use-uf-e-optprc       no
&glob List_-type-uf-e-optprc      {&type-char}
&glob List_-format-uf-e-optprc    "X(256)"
&glob Naim-use-uf-e-optprc        no
&glob Naim-type-uf-e-optprc       {&type-char}
&glob Naim-format-uf-e-optprc     "X(256)"
&glob print-graft-use-uf-e-optprc yes
&glob sort-gr-use-uf-e-optprc     no
&glob type-price-use-uf-e-optprc  no
&glob user-can-edit-uf-e-optprc   no
&glob output-display-uf-e-optprc  no
&glob other-uf-e-optprc           ""

&scop bef-uf-iecliart             cus/iecliart.w
&glob uf-iecliart                 '{&bef-uf-iecliart}':U
&glob label-uf-iecliart           "Процедуры импорта экспорта артикулов поставщиков"
&glob tooltip-uf-iecliart         "Процедуры импорта экспорта артикулов поставщиков"
&glob List_-use-uf-iecliart       yes
&glob List_-type-uf-iecliart      {&type-char}
&glob List_-format-uf-iecliart    "X(256)"
&glob Naim-use-uf-iecliart        no
&glob Naim-type-uf-iecliart       {&type-char}
&glob Naim-format-uf-iecliart     "X(256)"
&glob print-graft-use-uf-iecliart no
&glob sort-gr-use-uf-iecliart     no
&glob type-price-use-uf-iecliart  no
&glob user-can-edit-uf-iecliart   no
&glob output-display-uf-iecliart  no
&glob other-uf-iecliart           ""

&scop bef-uf-exp-sl-1              e-exp-sl-1
&glob uf-exp-sl-1                  '{&bef-uf-exp-sl-1}':U
&glob label-uf-exp-sl-1            "Выгрузка для Nielsen 1"
&glob tooltip-uf-exp-sl-1          "Выгрузка для Nielsen 1"
&glob List_-use-uf-exp-sl-1        yes
&glob List_-type-uf-exp-sl-1       {&type-char}
&glob List_-format-uf-exp-sl-1     "X(256)"
&glob Naim-use-uf-exp-sl-1         yes
&glob Naim-type-uf-exp-sl-1        {&type-char}
&glob Naim-format-uf-exp-sl-1      "X(256)"
&glob print-graft-use-uf-exp-sl-1  YES
&glob sort-gr-use-uf-exp-sl-1      no
&glob type-price-use-uf-exp-sl-1   no
&glob user-can-edit-uf-exp-sl-1    no
&glob output-display-uf-exp-sl-1   no
&glob other-uf-exp-sl-1            ""

&scop bef-uf-exp-sl-2              e-exp-sl-2
&glob uf-exp-sl-2                  '{&bef-uf-exp-sl-2}':U
&glob label-uf-exp-sl-2            "Выгрузка для Nielsen 1"
&glob tooltip-uf-exp-sl-2          "Выгрузка для Nielsen 2"
&glob List_-use-uf-exp-sl-2        yes
&glob List_-type-uf-exp-sl-2       {&type-char}
&glob List_-format-uf-exp-sl-2     "X(256)"
&glob Naim-use-uf-exp-sl-2         yes
&glob Naim-type-uf-exp-sl-2        {&type-char}
&glob Naim-format-uf-exp-sl-2      "X(256)"
&glob print-graft-use-uf-exp-sl-2  no
&glob sort-gr-use-uf-exp-sl-2      no
&glob type-price-use-uf-exp-sl-2   no
&glob user-can-edit-uf-exp-sl-2    no
&glob output-display-uf-exp-sl-2   no
&glob other-uf-exp-sl-2            ""

&scop bef-uf-regdoc               e-regdoc.w2
&glob uf-regdoc                  '{&bef-uf-regdoc.w2}':U
&glob label-uf-regdoc            "Выгрузка для Nielsen 1"
&glob tooltip-uf-regdoc          "Выгрузка для Nielsen 2"
&glob List_-use-uf-regdoc        yes
&glob List_-type-uf-regdoc       {&type-char}
&glob List_-format-uf-regdoc     "X(256)"
&glob Naim-use-uf-regdoc         yes
&glob Naim-type-uf-regdoc        {&type-char}
&glob Naim-format-uf-regdoc      "X(256)"
&glob print-graft-use-uf-regdoc  no
&glob sort-gr-use-uf-regdoc      no
&glob type-price-use-uf-regdoc   no
&glob user-can-edit-uf-regdoc    no
&glob output-display-uf-regdoc   no
&glob other-uf-regdoc            ""

&scop bef-current-position-zone wthps-zone
&GLOB current-position-zone '{&bef-current-position-zone}':U
&glob label-current-position-zone            " "
&glob tooltip-current-position-zone          " "
&glob List_-use-current-position-zone        yes
&glob List_-type-current-position-zone       {&type-char}
&glob List_-format-current-position-zone     "X(256)"
&glob Naim-use-current-position-zone         yes
&glob Naim-type-current-position-zone        {&type-char}
&glob Naim-format-current-position-zone      "X(256)"
&glob print-graft-current-position-zone      no
&glob sort-gr-use-current-position-zone      no
&glob type-price-use-current-position-zone   no
&glob user-can-edit-current-position-zone    no
&glob output-display-current-position-zone   no
&glob other-current-position-zone            ""


&scop bef-current-position-obj  wthparts-obj
&GLOB current-position-obj  '{&bef-current-position-obj}':U
&glob label-current-position-obj            " "
&glob tooltip-current-position-obj          " "
&glob List_-use-current-position-obj        yes
&glob List_-type-current-position-obj       {&type-char}
&glob List_-format-current-position-obj     "X(256)"
&glob Naim-use-current-position-obj         yes
&glob Naim-type-current-position-obj        {&type-char}
&glob Naim-format-current-position-obj      "X(256)"
&glob print-graft-current-position-obj      no
&glob sort-gr-use-current-position-obj      no
&glob type-price-use-current-position-obj   no
&glob user-can-edit-current-position-obj    no
&glob output-display-current-position-obj   no
&glob other-current-position-obj            ""


&scop bef-current-position-stts wthsref-stts
&glob current-position-stts '&bef-wthsref-stts}':U
&glob label-current-position-stts            " "
&glob tooltip-current-position-stts          " "
&glob List_-use-current-position-stts        yes
&glob List_-type-current-position-stts       {&type-char}
&glob List_-format-current-position-stts     "X(256)"
&glob Naim-use-current-position-stts         yes
&glob Naim-type-current-position-stts        {&type-char}
&glob Naim-format-current-position-stts      "X(256)"
&glob print-graft-current-position-stts      no
&glob sort-gr-use-current-position-stts      no
&glob type-price-use-current-position-stts   no
&glob user-can-edit-current-position-stts    no
&glob output-display-current-position-stts   no
&glob other-current-position-stts            ""


&scop bef-uf-wthrd             wthrd
&glob uf-wthrd                 '{&bef-uf-wthrd}':U
&glob label-uf-wthrd           " "
&glob tooltip-uf-wthrd         " "
&glob List_-use-uf-wthrd       yes
&glob List_-type-uf-wthrd      {&type-char}
&glob List_-format-uf-wthrd    "X(256)"
&glob Naim-use-uf-wthrd        yes
&glob Naim-type-uf-wthrd       {&type-char}
&glob Naim-format-uf-wthrd     "X(256)"
&glob print-graft-use-uf-wthrd no
&glob sort-gr-use-uf-wthrd     no
&glob type-price-use-uf-wthrd  no
&glob user-can-edit-uf-wthrd   no
&glob output-display-uf-wthrd  no
&glob other-uf-wthrd           ""

&scop bef-uf-wthob             wthob
&glob uf-wthob                 '{&bef-uf-wthob}':U
&glob label-uf-wthob           " "
&glob tooltip-uf-wthob         " "
&glob List_-use-uf-wthob       yes
&glob List_-type-uf-wthob      {&type-char}
&glob List_-format-uf-wthob    "X(256)"
&glob Naim-use-uf-wthob        yes
&glob Naim-type-uf-wthob       {&type-char}
&glob Naim-format-uf-wthob     "X(256)"
&glob print-graft-use-uf-wthob no
&glob sort-gr-use-uf-wthob     no
&glob type-price-use-uf-wthob  no
&glob user-can-edit-uf-wthob   no
&glob output-display-uf-wthob  no
&glob other-uf-wthob           ""

&scop bef-uf-wthref-type             wthref-type
&glob uf-wthref-type                 '{&bef-uf-wthref-type}':U
&glob label-uf-wthref-type           " "
&glob tooltip-uf-wthref-type         " "
&glob List_-use-uf-wthref-type       yes
&glob List_-type-uf-wthref-type      {&type-char}
&glob List_-format-uf-wthref-type    "X(256)"
&glob Naim-use-uf-wthref-type        yes
&glob Naim-type-uf-wthref-type       {&type-char}
&glob Naim-format-uf-wthref-type     "X(256)"
&glob print-graft-use-uf-wthref-type no
&glob sort-gr-use-uf-wthref-type     no
&glob type-price-use-uf-wthref-type  no
&glob user-can-edit-uf-wthref-type   no
&glob output-display-uf-wthref-type  no
&glob other-uf-wthref-type           ""

&scop bef-uf-wthref-stts             wthref-stts
&glob uf-wthref-stts                 '{&bef-uf-wthref-stts}':U
&glob label-uf-wthref-stts           " "
&glob tooltip-uf-wthref-stts         " "
&glob List_-use-uf-wthref-stts       yes
&glob List_-type-uf-wthref-stts      {&type-char}
&glob List_-format-uf-wthref-stts    "X(256)"
&glob Naim-use-uf-wthref-stts        yes
&glob Naim-type-uf-wthref-stts       {&type-char}
&glob Naim-format-uf-wthref-stts     "X(256)"
&glob print-graft-use-uf-wthref-stts no
&glob sort-gr-use-uf-wthref-stts     no
&glob type-price-use-uf-wthref-stts  no
&glob user-can-edit-uf-wthref-stts   no
&glob output-display-uf-wthref-stts  no
&glob other-uf-wthref-stts           ""

&scop bef-uf-wrsttl1             wrsttl1
&glob uf-wrsttl1                 '{&bef-uf-wrsttl1}':U
&glob label-uf-wrsttl1           "Реестр отоваренных талонов"
&glob tooltip-uf-wrsttl1         "Реестр отоваренных талонов"
&glob List_-use-uf-wrsttl1       yes
&glob List_-type-uf-wrsttl1      {&type-char}
&glob List_-format-uf-wrsttl1    "X(256)"
&glob Naim-use-uf-wrsttl1        yes
&glob Naim-type-uf-wrsttl1       {&type-char}
&glob Naim-format-uf-wrsttl1     "X(256)"
&glob print-graft-use-uf-wrsttl1 yes
&glob sort-gr-use-uf-wrsttl1     yes
&glob type-price-use-uf-wrsttl1  yes
&glob user-can-edit-uf-wrsttl1   no
&glob output-display-uf-wrsttl1  no
&glob other-uf-wrsttl1           ""

&scop bef-uf-wrsttl2             wrsttl2
&glob uf-wrsttl2                 '{&bef-uf-wrsttl2}':U
&glob label-uf-wrsttl2           "Реестр отоваренных талонов"
&glob tooltip-uf-wrsttl2         "Реестр отоваренных талонов"
&glob List_-use-uf-wrsttl2       yes
&glob List_-type-uf-wrsttl2      {&type-char}
&glob List_-format-uf-wrsttl2    "X(256)"
&glob Naim-use-uf-wrsttl2        yes
&glob Naim-type-uf-wrsttl2       {&type-char}
&glob Naim-format-uf-wrsttl2     "X(256)"
&glob print-graft-use-uf-wrsttl2 no
&glob sort-gr-use-uf-wrsttl2     no
&glob type-price-use-uf-wrsttl2  no
&glob user-can-edit-uf-wrsttl2   no
&glob output-display-uf-wrsttl2  no
&glob other-uf-wrsttl2           ""

&scop bef-uf-wthobr-sup             wthobr-sup
&glob uf-wthobr-sup                 '{&bef-uf-wthobr-sup}':U
&glob label-uf-wthobr-sup           "Оборотная ведомость серийных МЦ по контрагентам"
&glob tooltip-uf-wthobr-sup         "Оборотная ведомость серийных МЦ по контрагентам"
&glob List_-use-uf-wthobr-sup       yes
&glob List_-type-uf-wthobr-sup      {&type-char}
&glob List_-format-uf-wthobr-sup    "X(256)"
&glob Naim-use-uf-wthobr-sup        yes
&glob Naim-type-uf-wthobr-sup       {&type-char}
&glob Naim-format-uf-wthobr-sup     "X(256)"
&glob print-graft-use-uf-wthobr-sup no
&glob sort-gr-use-uf-wthobr-sup     no
&glob type-price-use-uf-wthobr-sup  no
&glob user-can-edit-uf-wthobr-sup   no
&glob output-display-uf-wthobr-sup  no
&glob other-uf-wthobr-sup           ""

&scop bef-uf-wthobr-wth             wthobr-wth
&glob uf-wthobr-wth                 '{&bef-uf-wthobr-wth}':U
&glob label-uf-wthobr-wth           "Оборотная ведомость серийных МЦ по контрагентам"
&glob tooltip-uf-wthobr-wth         "Оборотная ведомость серийных МЦ по контрагентам"
&glob List_-use-uf-wthobr-wth       yes
&glob List_-type-uf-wthobr-wth      {&type-char}
&glob List_-format-uf-wthobr-wth    "X(256)"
&glob Naim-use-uf-wthobr-wth        yes
&glob Naim-type-uf-wthobr-wth       {&type-char}
&glob Naim-format-uf-wthobr-wth     "X(256)"
&glob print-graft-use-uf-wthobr-wth no
&glob sort-gr-use-uf-wthobr-wth     no
&glob type-price-use-uf-wthobr-wth  no
&glob user-can-edit-uf-wthobr-wth   no
&glob output-display-uf-wthobr-wth  no
&glob other-uf-wthobr-wth           ""


&scop bef-uf-contspec-gds              contspec-g
&glob uf-contspec-gds                 '{&bef-uf-contspec-gds}':U
&glob label-uf-contspec-gds           "Спецификация"
&glob tooltip-uf-contspec-gds         "Спецификаци "
&glob List_-use-uf-contspec-gds       yes
&glob List_-type-uf-contspec-gds      {&type-char}
&glob List_-format-uf-contspec-gds    "X(256)"
&glob Naim-use-uf-contspec-gds       no
&glob Naim-type-uf-contspec-gds       {&type-char}
&glob Naim-format-uf-contspec-gds     "X(256)"
&glob print-graft-use-uf-contspec-gds  no
&glob sort-gr-use-uf-contspec-gds      no
&glob type-price-use-uf-contspec-gds  no
&glob type-val-use-uf-contspec-gds    no
&glob user-can-edit-uf-contspec-gds     no
&glob output-display-uf-contspec-gds    no
&glob other-uf-contspec-gds             ""

&scop bef-uf-e-ptlbal             e-ptlbal
&glob uf-e-ptlbal                 '{&bef-uf-e-ptlbal}':U
&glob label-uf-e-ptlbal           "Оперативный балансовый отчет движения нефтепродуктов"
&glob tooltip-uf-e-ptlbal         "Оперативный балансовый отчет движения нефтепродуктов"
&glob List_-use-uf-e-ptlbal       yes
&glob List_-type-uf-e-ptlbal      {&type-char}
&glob List_-format-uf-e-ptlbal    "X(256)"
/*
список с порядком полей в броузе {&delim-par}
*/
&glob Naim-use-uf-e-ptlbal          no
&glob Naim-type-uf-e-ptlbal         {&type-char}
&glob Naim-format-uf-e-ptlbal       "X(256)"
&glob print-graft-use-uf-e-ptlbal   no
&glob sort-gr-use-uf-e-ptlbal       no
&glob type-price-use-uf-e-ptlbal    no
&glob type-val-use-uf-e-ptlbal      no
&glob user-can-edit-uf-e-ptlbal     no
&glob output-display-uf-e-ptlbal    no
&glob other-uf-e-ptlbal             ""


&scop bef-uf-ctrasm             ctrasm
&glob uf-ctrasm                 '{&bef-uf-ctrasm}':U
&glob label-uf-ctrasm           "Контроль ассортиментной матрицы"
&glob tooltip-uf-ctrasm         "Контроль ассортиментной матрицы"
&glob List_-use-uf-ctrasm       yes
&glob List_-type-uf-ctrasm      {&type-char}
&glob List_-format-uf-ctrasm    "X(256)"
/*
список {&delim-par}
gds-by-am
group-by-post
detailed
gds-ctritical-qnty
days-wt-goods
gds-qnty
*/
&glob Naim-use-uf-ctrasm        no
&glob Naim-type-uf-ctrasm       {&type-char}
&glob Naim-format-uf-ctrasm     "X(256)"
&glob print-graft-use-uf-ctrasm no
&glob sort-gr-use-uf-ctrasm     no
&glob type-price-use-uf-ctrasm  no
&glob user-can-edit-uf-ctrasm   no
&glob output-display-uf-ctrasm  no
&glob other-uf-ctrasm           ""


&scop bef-uf-e-eslg-e             e-eslg-e
&glob uf-e-eslg-e                 '{&bef-uf-e-eslg-e}':U
&glob label-uf-e-eslg-e           "Оперативный балансовый отчет движения нефтепродуктов"
&glob tooltip-uf-e-eslg-e         "Оперативный балансовый отчет движения нефтепродуктов"
&glob List_-use-uf-e-eslg-e       yes
&glob List_-type-uf-e-eslg-e      {&type-char}
&glob List_-format-uf-e-eslg-e    "X(256)"
/*
список параметров отчета через {&delim-par}
  NullStr                 - Показать непроходившие товары
  fi-days-absence         - Кол-во дней отсутствия товара
  fi-critical-balance     - Критическое кол-во
  tg-absence-period       - Отсуствуют продажи за период
  fi-absence-period-from  - Начало периода
  fi-absence-period-to    - Конец периода
*/
&glob Naim-use-uf-e-eslg-e          no
&glob Naim-type-uf-e-eslg-e         {&type-char}
&glob Naim-format-uf-e-eslg-e       "X(256)"
&glob print-graft-use-uf-e-eslg-e   no
&glob sort-gr-use-uf-e-eslg-e       no
&glob type-price-use-uf-e-eslg-e    no
&glob type-val-use-uf-e-eslg-e      no
&glob user-can-edit-uf-e-eslg-e     no
&glob output-display-uf-e-eslg-e    no
&glob other-uf-e-eslg-e             ""

&scop bef-uf-prphoto             prphoto
&glob uf-prphoto                 '{&bef-uf-prphoto}':U
&glob label-uf-prphoto           "Прайс-лист с фото товаров"
&glob tooltip-uf-prphoto         "Прайс-лист с фото товаров"
&glob List_-use-uf-prphoto       yes
&glob List_-type-uf-prphoto      {&type-char}
&glob List_-format-uf-prphoto    "X(2256)"
/*
список параметров отчета через {&delim-par}
name
dostavka
telefon-1
telefon-2
info
*/
&glob Naim-use-uf-prphoto          no
&glob Naim-type-uf-prphoto         {&type-char}
&glob Naim-format-uf-prphoto       "X(2256)"
&glob print-graft-use-uf-prphoto   no
&glob sort-gr-use-uf-prphoto       no
&glob type-price-use-uf-prphoto    no
&glob type-val-use-uf-prphoto      no
&glob user-can-edit-uf-prphoto     no
&glob output-display-uf-prphoto    no
&glob other-uf-prphoto             ""



&scop bef-uf-chkgdsfi             chkgdsfi
&glob uf-chkgdsfi                 '{&bef-uf-chkgdsfi}':U
&glob label-uf-chkgdsfi           "Товарная строка чека - доп поля"
&glob tooltip-uf-chkgdsfi         "Товарная строка чека - доп поля "
&glob List_-use-uf-chkgdsfi       yes
&glob List_-type-uf-chkgdsfi      {&type-char}
&glob List_-format-uf-chkgdsfi    "X(256)"
/*
Список очередностей колонок {&delim-par}
Список ширин колонок {&delim-par}
Список видимости колонок {&delim-par}
*/
&glob Naim-use-uf-chkgdsfi       no
&glob Naim-type-uf-chkgdsfi       {&type-char}
&glob Naim-format-uf-chkgdsfi     "X(256)"
&glob print-graft-use-uf-chkgdsfi  no
&glob sort-gr-use-uf-chkgdsfi      no
&glob type-price-use-uf-chkgdsfi   no
&glob type-val-use-uf-chkgdsfi     no
&glob user-can-edit-uf-chkgdsfi     no
&glob output-display-uf-chkgdsfi    no
&glob other-uf-chkgdsfi             ""
&glob chkgdsfi-ord 'chk-gds.doc-code,chk-gds.line-num,chk-gds.b-code,chk-gds.src-code,chk-gds.price-base,chk-gds.doc-qnty,chk-gds.discnt':U
&glob chkgdsfi-siz '?,?,?,?,?,?,?':U


&scop bef-uf-chkdocfi             chkdocfi
&glob uf-chkdocfi                 '{&bef-uf-chkdocfi}':U
&glob label-uf-chkdocfi           "Чек - доп поля"
&glob tooltip-uf-chkdocfi         "Чек - доп поля"
&glob List_-use-uf-chkdocfi       yes
&glob List_-type-uf-chkdocfi      {&type-char}
&glob List_-format-uf-chkdocfi    "X(256)"
/*
Список очередностей колонок {&delim-par}
Список ширин колонок {&delim-par}
Список видимости колонок {&delim-par}
*/

&glob Naim-use-uf-chkdocfi       no
&glob Naim-type-uf-chkdocfi       {&type-char}
&glob Naim-format-uf-chkdocfi     "X(256)"
&glob print-graft-use-uf-chkdocfi  no
&glob sort-gr-use-uf-chkdocfi      no
&glob type-price-use-uf-chkdocfi   no
&glob type-val-use-uf-chkdocfi     no
&glob user-can-edit-uf-chkdocfi     no
&glob output-display-uf-chkdocfi    no
&glob other-uf-chkdocfi             ""
&glob chkdocfi-ord 'chk-doc.doc-code,chk-doc.obj-code,chk-doc.#chk-type-name,chk-doc.tot-doc,chk-doc.netto,chk-doc.chk-date,chk-doc.#chk-time-chr':U
&glob chkdocfi-siz '?,?,?,?,?,?,?':U

&scop bef-uf-UPD                UPD
&glob uf-UPD                   '{&bef-uf-UPD}':U
&glob label-uf-UPD             "Настройки справочника Электронного документоборота"
&glob tooltip-uf-UPD           "Настройки справочника Электронного документоборота"
&glob List_-use-uf-UPD        yes
&glob List_-type-uf-UPD        {&type-char}
&glob List_-format-uf-UPD      "X(256)"
/*"in-date=":U +  string(v-in-date , "99/99/9999") +   ";" +  "fact-qnty=":U + string(v-fact-qnty)*/
&glob Naim-use-uf-UPD         no
&glob Naim-type-uf-UPD         {&type-char}
&glob Naim-format-uf-UPD       "X(256)"
&glob print-graft-use-uf-UPD  no
&glob sort-gr-use-uf-UPD      no
&glob type-price-use-uf-UPD   no
&glob type-val-use-uf-UPD     no
&glob user-can-edit-uf-UPD     no
&glob output-display-uf-UPD    no
&glob other-uf-UPD             ""

&scop bef-uf-LK_RECEIPT             LK_RECEIPT
&glob uf-LK_RECEIPT                 '{&bef-uf-LK_RECEIPT}':U
&glob label-uf-LK_RECEIPT           "Настройки справочника документов Вывода из оборота (ОСУ)"
&glob tooltip-uf-LK_RECEIPT         "Настройки справочника документов Вывода из оборота (ОСУ)"
&glob List_-use-uf-LK_RECEIPT       yes
&glob List_-type-uf-LK_RECEIPT      {&type-char}
&glob List_-format-uf-LK_RECEIPT    "X(256)"
/*"in-date=":U +  string(v-in-date , "99/99/9999") +   ";" +  "fact-qnty=":U + string(v-fact-qnty)*/
&glob Naim-use-uf-LK_RECEIPT        no
&glob Naim-type-uf-LK_RECEIPT       {&type-char}
&glob Naim-format-uf-LK_RECEIPT     "X(256)"
&glob print-graft-use-uf-LK_RECEIPT no
&glob sort-gr-use-uf-LK_RECEIPT     no
&glob type-price-use-uf-LK_RECEIPT  no
&glob type-val-use-uf-LK_RECEIPT    no
&glob user-can-edit-uf-LK_RECEIPT   no
&glob output-display-uf-LK_RECEIPT  no
&glob other-uf-LK_RECEIPT           ""

&scop bef-uf-barcodfi             barcodfi
&glob uf-barcodfi                 '{&bef-uf-barcodfi}':U
&glob label-uf-barcodfi           "Бар-код - доп поля"
&glob tooltip-uf-barcodfi         "Бар-код - доп поля"
&glob List_-use-uf-barcodfi       yes
&glob List_-type-uf-barcodfi      {&type-char}
&glob List_-format-uf-barcodfi    "X(256)"
/*
Список очередностей колонок {&delim-par}
Список ширин колонок {&delim-par}
Список видимости колонок {&delim-par}
*/

&glob Naim-use-uf-barcodfi       no
&glob Naim-type-uf-barcodfi       {&type-char}
&glob Naim-format-uf-barcodfi     "X(256)"
&glob print-graft-use-uf-barcodfi  no
&glob sort-gr-use-uf-barcodfi      no
&glob type-price-use-uf-barcodfi   no
&glob type-val-use-uf-barcodfi     no
&glob user-can-edit-uf-barcodfi     no
&glob output-display-uf-barcodfi    no
&glob other-uf-barcodfi             ""
&scop bef-uf-barcodfi             barcodfi
&glob uf-barcodfi                 '{&bef-uf-barcodfi}':U
&glob label-uf-barcodfi           "Бар-код - доп поля"
&glob tooltip-uf-barcodfi         "Бар-код - доп поля"
&glob List_-use-uf-barcodfi       yes
&glob List_-type-uf-barcodfi      {&type-char}
&glob List_-format-uf-barcodfi    "X(256)"
/*
Список очередностей колонок {&delim-par}
Список ширин колонок {&delim-par}
Список видимости колонок {&delim-par}
*/

&glob Naim-use-uf-barcodfi       no
&glob Naim-type-uf-barcodfi       {&type-char}
&glob Naim-format-uf-barcodfi     "X(256)"
&glob print-graft-use-uf-barcodfi  no
&glob sort-gr-use-uf-barcodfi      no
&glob type-price-use-uf-barcodfi   no
&glob type-val-use-uf-barcodfi     no
&glob user-can-edit-uf-barcodfi     no
&glob output-display-uf-barcodfi    no
&glob other-uf-barcodfi             ""
&glob barcodfi-ord 'bar-code.b-code,bar-code.unit-cli,bar-code.cli-base-rate,bar-code.gds-code,bar-code.#node-code-name,bar-code.in-code,bar-code.part-code,bar-code.cr-db-num':U
&glob barcodfi-siz '?,?,?,?,?,?,?,?':U





/*новые описания добавлять сюда!!!*/


&glob uf-list '{&bef-uf-cli-all-p}~
,{&bef-uf-oldscode}~
,{&bef-uf-gds-ref-p}~
,{&bef-uf-gds-grp-p}~
,{&bef-uf-fbr-gds-grp-p}~
,{&bef-uf-cli-grp-p}~
,{&bef-findoci-p}~
,{&bef-uf-findocs-p}~
,{&bef-uf-fin-obi}~
,{&bef-uf-seqeallo}~
,{&bef-uf-skm-rep}~
,{&bef-uf-pychk-rep}~
,{&bef-uf-imp-goods}~
,{&bef-uf-discards-p}~
,{&bef-finsttms-p}~
,{&bef-uf-fin-ob}~
,{&bef-uf-mpl-gds}~
,{&bef-uf-ord-sost}~
,{&bef-uf-all-docs}~
,{&bef-uf-planplat}~
,{&bef-uf-cli-zakz}~
,{&bef-uf-cli-zakzFP}~
,{&bef-uf-cli-zakzOP}~
,{&bef-uf-cli-zakzOF}~
,{&bef-uf-list-abc}~
,{&bef-uf-abc}~
,{&bef-uf-ord-rc}~
,{&bef-uf-cfin-ob}~
,{&bef-uf-color}~
,{&bef-uf-bon1-rep}~
,{&bef-uf-e-shift}~
,{&bef-uf-all-docs}~
,{&bef-uf-gdsreffi}~
,{&bef-uf-gdsfrmfi}~
,{&bef-uf-contspec}~
,{&bef-uf-contspec-gds}~
,{&bef-uf-tpl-mode}~
,{&bef-uf-wthrst}~
,{&bef-uf-wthcom}~
,{&bef-uf-users-1}~
,{&bef-uf-users-2}~
,{&bef-uf-bge-dper}~
,{&bef-uf-bge-active-vbrr}~
,{&bef-uf-bge-dper-new}~
,{&bef-uf-i-egais}~
,{&bef-uf-alc-rees}~
,{&bef-uf-e-optprc}~
,{&bef-uf-iecliart}~
,{&bef-uf-exp-sl-1}~
,{&bef-uf-exp-sl-2}~
,{&bef-uf-regdoc}~
,{&bef-current-position-zone}~
,{&bef-current-position-obj}~
,{&bef-current-position-stts}~
,{&bef-uf-wthrd}~
,{&bef-uf-wthob}~
,{&bef-uf-wthref-type}~
,{&bef-uf-wthref-stts}~
,{&bef-uf-wrsttl1}~
,{&bef-uf-wrsttl2}~
,{&bef-uf-wthobr-sup}~
,{&bef-uf-wthobr-wth}~
,{&bef-uf-e-ptlbal}~
,{&bef-uf-ctrasm}~
,{&bef-uf-e-eslg-e}~
,{&bef-uf-prphoto}~
,{&bef-uf-chkgdsfi}~
,{&bef-uf-chkdocfi}~
,{&bef-uf-barcodfi}~
,{&bef-uf-UPD}~
,{&bef-uf-LK_RECEIPT}~
':u


&scop uf-temp-full-code ~
  when ~{&~{&uf-code~}~} then do: ~
    assign ~
    p-use-List_ = ~{&List_-use-~{&uf-code~}~}  ~
    p-type-List_ = ~{&List_-type-~{&uf-code~}~}  ~
    p-format-List_ = ~{&List_-format-~{&uf-code~}~} ~
    p-use-Naim = ~{&Naim-use-~{&uf-code~}~}  ~
    p-type-Naim = ~{&Naim-type-~{&uf-code~}~}  ~
    p-format-Naim = ~{&Naim-format-~{&uf-code~}~} ~
    p-use-print-graft = ~{&print-graft-use-~{&uf-code~}~}  ~
    p-use-sort-gr = ~{&sort-gr-use-~{&uf-code~}~}  ~
    p-use-type-price = ~{&type-price-use-~{&uf-code~}~}  ~
    p-use-type-val = ~{&type-val-use-~{&uf-code~}~}  ~
    p-label = ~{&label-~{&uf-code~}~} ~
    p-tooltip = ~{&tooltip-~{&uf-code~}~} ~
    p-user-can-edit  = ~{&user-can-edit-~{&uf-code~}~} ~
    p-output-display = ~{&output-display-~{&uf-code~}~} ~
    p-other = ~{&other-~{&uf-code~}~} ~
    . ~
  end.


procedure uf-name :

  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .

  define output parameter p-use-List_     as logical   no-undo .
  define output parameter p-type-List_     as character no-undo .
  define output parameter p-format-List_   as character no-undo .

  define output parameter p-use-Naim      as logical   no-undo .
  define output parameter p-type-Naim      as character no-undo .
  define output parameter p-format-Naim    as character no-undo .

  define output parameter p-use-print-graft as logical   no-undo .
  define output parameter p-use-sort-gr   as logical   no-undo .
  define output parameter p-use-type-price as logical   no-undo .
  define output parameter p-use-type-val  as logical   no-undo .

  define output parameter p-label          as character no-undo .
  define output parameter p-tooltip        as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .

  do
  on error undo, return error
  :

    case p-code :
      &scop uf-code uf-cli-all-p
      {&uf-temp-full-code}
      &scop uf-code uf-oldscode
      {&uf-temp-full-code}
      &scop uf-code uf-gds-ref-p
      {&uf-temp-full-code}
      &scop uf-code uf-gds-grp-p
      {&uf-temp-full-code}
      &scop uf-code uf-fbr-gds-grp-p
      {&uf-temp-full-code}
      &scop uf-code uf-cli-grp-p
      {&uf-temp-full-code}
      &scop uf-code uf-findoci-p
      {&uf-temp-full-code}
      &scop uf-code uf-findocs-p
      {&uf-temp-full-code}
      &scop uf-code uf-fin-obi
      {&uf-temp-full-code}
      &scop uf-code uf-seqeallo
      {&uf-temp-full-code}
      &scop uf-code uf-skm-rep
      {&uf-temp-full-code}
      &scop uf-code uf-imp-goods
      {&uf-temp-full-code}
      &scop uf-code uf-discards-p
      {&uf-temp-full-code}
      &scop uf-code uf-finsttms-p
      {&uf-temp-full-code}
      &scop uf-code uf-fin-ob
      {&uf-temp-full-code}
      &scop uf-code uf-mpl-gds
      {&uf-temp-full-code}
      &scop uf-code uf-tpl-mode
      {&uf-temp-full-code}
      &scop uf-code uf-ord-sost
      {&uf-temp-full-code}
      &scop uf-code uf-all-docs
      {&uf-temp-full-code}
      &scop uf-code uf-planplat
      {&uf-temp-full-code}
      &scop uf-code uf-cli-zakz
      {&uf-temp-full-code}
      &scop uf-code uf-cli-zakzOP
      {&uf-temp-full-code}
      &scop uf-code uf-cli-zakzFP
      {&uf-temp-full-code}
      &scop uf-code uf-cli-zakzOF
      {&uf-temp-full-code}
      &scop uf-code uf-list-abc
      {&uf-temp-full-code}
      &scop uf-code uf-abc
      {&uf-temp-full-code}
      &scop uf-code uf-ord-rc
      {&uf-temp-full-code}
      &scop uf-code uf-cfin-ob
      {&uf-temp-full-code}
      &scop uf-code uf-color
      {&uf-temp-full-code}
      &scop uf-code uf-bon1-rep
      {&uf-temp-full-code}
      &scop uf-code uf-e-shift
      {&uf-temp-full-code}
      &scop uf-code uf-all-docs
      {&uf-temp-full-code}
      &scop uf-code uf-gdsreffi
      {&uf-temp-full-code}
      &scop uf-code uf-gdsfrmfi
      {&uf-temp-full-code}
      &scop uf-code uf-contspec
      {&uf-temp-full-code}
      &scop uf-code uf-contspec-gds
      {&uf-temp-full-code}
      &scop uf-code uf-wthrst
      {&uf-temp-full-code}
      &scop uf-code uf-wthcom
      {&uf-temp-full-code}
      &scop uf-code uf-users-1
      {&uf-temp-full-code}
      &scop uf-code uf-users-2
      {&uf-temp-full-code}
      &scop uf-code uf-bge-dper
      {&uf-temp-full-code}
       &scop uf-code uf-bge-active-vbrr
      {&uf-temp-full-code}
      &scop uf-code uf-bge-dper-new
      {&uf-temp-full-code}
      &scop uf-code uf-i-egais
      {&uf-temp-full-code}
      &scop uf-code uf-alc-rees
      {&uf-temp-full-code}
      &scop uf-code uf-e-optprc
      {&uf-temp-full-code}
      &scop uf-code uf-iecliart
      {&uf-temp-full-code}
      &scop uf-code uf-exp-sl-1
      {&uf-temp-full-code}
      &scop uf-code uf-exp-sl-2
      {&uf-temp-full-code}
      &scop uf-code uf-regdoc
      {&uf-temp-full-code}
      &scop uf-code current-position-zone
      {&uf-temp-full-code}
      &scop uf-code current-position-obj
      {&uf-temp-full-code}
      &scop uf-code current-position-stts
      {&uf-temp-full-code}
      &scop uf-code uf-wthrd
      {&uf-temp-full-code}
      &scop uf-code uf-wthob
      {&uf-temp-full-code}
      &scop uf-code uf-wthref-type
      {&uf-temp-full-code}
      &scop uf-code uf-wthref-stts
      {&uf-temp-full-code}
      &scop uf-code uf-wrsttl1
      {&uf-temp-full-code}
      &scop uf-code uf-wrsttl2
      {&uf-temp-full-code}
      &scop uf-code uf-wthobr-sup
      {&uf-temp-full-code}
      &scop uf-code uf-wthobr-wth
      {&uf-temp-full-code}
      &scop uf-code uf-e-ptlbal
      {&uf-temp-full-code}
      &scop uf-code uf-ctrasm
      {&uf-temp-full-code}
      &scop uf-code uf-e-eslg-e
      {&uf-temp-full-code}
      &scop uf-code uf-prphoto
      {&uf-temp-full-code}
      &scop uf-code uf-chkgdsfi
      {&uf-temp-full-code}
      &scop uf-code uf-chkdocfi
      {&uf-temp-full-code}
      &scop uf-code uf-barcodfi
      {&uf-temp-full-code}
       &scop uf-code uf-UPD
      {&uf-temp-full-code}
      &scop uf-code uf-LK_RECEIPT
      {&uf-temp-full-code}

       /* сюда добавлять новые параметры */
      otherwise do:
        undo, return error "неизвестная настройка пользователя usr-flt" + " " + p-code .
      end.
    end CASE.
  end. /*doe*/
end procedure. /* uf-name */


procedure uf-get :

  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define output parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define output parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define output parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define output parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define output parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define output parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .

  do
  on error undo, return error
  :

    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .

    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .

    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr     as logical   no-undo .
    define variable v-use-type-price  as logical   no-undo .
    define variable v-use-type-val    as logical   no-undo .

    define variable v-label          as character no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run uf-name in this-procedure
       (input  entry(1, p-code, {&delim-par})           /* p-code           */
      ,output v-use-List_
      ,output v-type-List_     /* p-type           */
      ,output v-format-List_   /* p-format         */

      ,output v-use-Naim
      ,output v-type-Naim      /* p-type           */
      ,output v-format-Naim    /* p-format         */

      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val

      ,output v-label          /* p-label          */
      ,output v-tooltip
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt no-lock where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if avail buf_usr-flt then do:
      assign
      p-List_        = (if v-use-List_       then buf_usr-flt.List_       else ?)
      p-Naim         = (if v-use-Naim        then buf_usr-flt.Naim        else ?)
      p-print-graft  = (if v-use-print-graft then buf_usr-flt.print-graft else ?)
      p-sort-gr      = (if v-use-sort-gr     then buf_usr-flt.sort-gr     else ?)
      p-type-price   = (if v-use-type-price  then buf_usr-flt.type-price  else ?)
      p-type-val     = (if v-use-List_       then buf_usr-flt.type-val    else ?)
      .
    end.
    else do:
      assign
      p-List_        = (if v-use-List_       then "":U                    else ?)
      p-Naim         = (if v-use-Naim        then "":U                    else ?)
      p-print-graft  = (if v-use-print-graft then no                      else ?)
      p-sort-gr      = (if v-use-sort-gr     then no                      else ?)
      p-type-price   = (if v-use-type-price  then no                      else ?)
      p-type-val     = (if v-use-List_       then no                      else ?)
      .
    end.
  end.

end procedure. /* uf-get */


procedure uf-set :

  define input  parameter p-code         like ubflt.usr-flt.call-point   no-undo .
  define input  parameter p-user-name    like ubflt.usr-flt.user-name    no-undo .
  define input  parameter p-List_        like ubflt.usr-flt.List_        no-undo .
  define input  parameter p-Naim         like ubflt.usr-flt.Naim         no-undo .
  define input  parameter p-print-graft  like ubflt.usr-flt.print-Graft  no-undo .
  define input  parameter p-sort-gr      like ubflt.usr-flt.sort-gr      no-undo .
  define input  parameter p-type-price   like ubflt.usr-flt.type-price   no-undo .
  define input  parameter p-type-val     like ubflt.usr-flt.type-val     no-undo .

  do
  on error undo, return error
  :

    define buffer buf_usr-flt for ubflt.usr-flt .
    define variable v-use-List_     as logical   no-undo .
    define variable v-type-List_     as character no-undo .
    define variable v-format-List_   as character no-undo .

    define variable v-use-Naim      as logical   no-undo .
    define variable v-type-Naim      as character no-undo .
    define variable v-format-Naim    as character no-undo .

    define variable v-use-print-graft as logical   no-undo .
    define variable v-use-sort-gr   as logical   no-undo .
    define variable v-use-type-price as logical   no-undo .
    define variable v-use-type-val  as logical   no-undo .
    define variable v-tooltip        as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .

    run uf-name in this-procedure
      (input  entry(1, p-code, {&delim-par})           /* p-code           */
      ,output v-use-List_
      ,output v-type-List_     /* p-type           */
      ,output v-format-List_   /* p-format         */

      ,output v-use-Naim
      ,output v-type-Naim      /* p-type           */
      ,output v-format-Naim    /* p-format         */

      ,output v-use-print-graft
      ,output v-use-sort-gr
      ,output v-use-type-price
      ,output v-use-type-val

      ,output v-label          /* p-label          */
      ,output v-tooltip
      ,output v-user-can-edit  /* p-user-can-edit  */
      ,output v-output-display /* p-output-display */
      ,output v-other          /* p-other          */
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_usr-flt where
               buf_usr-flt.Call-point     = p-code AND
               buf_usr-flt.user-name       = p-user-name
      no-error .
    if not avail buf_usr-flt then do:
        create buf_usr-flt .
        assign
        buf_usr-flt.call-point = p-code
        buf_usr-flt.user-name  = p-user-name
        .
    end.
    if avail buf_usr-flt then do:
     assign
     buf_usr-flt.List_       =  (if v-use-List_       then  p-List_        else ?)
     buf_usr-flt.Naim        =  (if v-use-Naim        then  p-Naim         else ?)
     buf_usr-flt.print-graft =  (if v-use-print-graft then  p-print-graft  else ?)
     buf_usr-flt.sort-gr     =  (if v-use-sort-gr     then  p-sort-gr      else ?)
     buf_usr-flt.type-price  =  (if v-use-type-price  then  p-type-price   else ?)
     buf_usr-flt.type-val    =  (if v-use-List_       then  p-type-val     else ?)
    .
    release buf_usr-flt.
    end.
    else undo, return error ("Ошибка при записи usr-flt" + substitute(" call-point=&1, user-name=&2", p-code, p-user-name)).
  end.

end procedure. /* uf-set */

/* $Workfile$ e n d */