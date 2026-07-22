/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временные таблицы для отчета по Картам клиентов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/12/04
Author: Bakhtadze Natalya
Creation date: 11/12/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table dcards  no-undo
/*field cur-rowid     as rowid                                /* Уникальный ID Записи в таблице */*/
field obj-type      as character                            /* Объект. Тип */
field obj-code      as integer                              /* Объект. Код */
field obj-name      as character                            /* Объект. Имя */
field chk-doc-code  like ub.chk-doc.doc-code                /* Моё служебное проверочное поле "Чек№" */
field chk-date      like ub.chk-doc.chk-date                /*  */
field shift-date    like ub.chk-doc.shift-date              /* Моё служебное проверочное поле "Дата_Смены" */
field d-card        like ub.dis-card.d-card                 /*  */
field card-num-chr  as character
field card-num      like ub.dis-card.card-num
field sourced-card  like ub.dis-card.sourced-card
field main-card     like ub.dis-card.main-card
field first-card    like ub.dis-card.first-card
field first-main-card like ub.dis-card.first-main-card
field cli-type-code as character                            /* Держатель ДК */
field artic         like ub.goods.artic
field b-code        like ub.bar-code.b-code
field node-code     like ub.gds-prt.node-code
field prod-type     like ub.clients.obj-type
field prod-code     like ub.clients.obj-code
field sale-price    like ub.price-list.price-sale
field doc-qnty      like ub.chk-gds.doc-qnty
field grp-goods     as character                            /* ТН-3320. 01.12.2014г. Арн. */
field grp-lvl       as integer                              /* Уровень группы относительный. */
field upper-code    like gds-grp.upper-code                 /* Группа родительская(применительно к Группе товаров) */
field gds-name      like ub.goods.gds-name
field gds-code      like ub.goods.gds-code
field sum           as decimal
field discount      as decimal
field counter       as integer
field grp-code like ub.goods.grp-code                       /* Группа родителя (применительно к Группе товаров) */
field sum-withdisc  as decimal                              /* Сумма со скидкой */
field qnty-bonus as decimal

INDEX pi            IS PRIMARY obj-type obj-code d-card 
index p4            first-card
index p5            main-card
index p6            first-main-card
index html_1        grp-lvl artic
index upper_code    d-card upper-code
index dcard         d-card 
.

do:  /* Отключение кода использовавшего ранее смарт-объект times */
/*
DEFINE {1} TEMP-TABLE times NO-UNDO
    FIELD time1 as integer
    FIELD time2 as integer
    FIELD times as char
    INDEX pi IS PRIMARY UNIQUE time1 time2
    INDEX ps times.
*/
end. /* Отключение кода использовавшего ранее смарт-объект times */

/* $Workfile$ e n d */