/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Временные таблицы для отчета по покупкам постоянных клиентов (с дисконтными картами)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/12/04
Author: Bakhtadze Natalya
Creation date: 11/12/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define {1} temp-table dcards  no-undo
field date_         like ub.chk-doc.chk-date
field d-card        like ub.dis-card.d-card
field card-num-chr  as character
field card-num      like ub.dis-card.card-num
field sourced-card  like ub.dis-card.sourced-card
field main-card     like ub.dis-card.main-card
field first-card    like ub.dis-card.first-card
field first-main-card like ub.dis-card.first-main-card
field artic         like ub.goods.artic
field b-code        like ub.bar-code.b-code
field node-code     like ub.gds-prt.node-code
field prod-type     like ub.clients.obj-type
field prod-code     like ub.clients.obj-code
field sale-price    like ub.price-list.price-sale
field qnty          like ub.chk-gds.doc-qnty
field sum           as  decimal
field discount      as  decimal
field counter       as integer
field cli-type-code as character
INDEX pi            IS PRIMARY date_ d-card b-code ASCENDING
INDEX p1                       d-card date_ ASCENDING
index p3            cli-type-code card-num-chr d-card date_ /*для показа*/
index p4            first-card
index p5            main-card
index p6            first-main-card
.
DEFINE {1} TEMP-TABLE times NO-UNDO
    FIELD time1 as integer
    FIELD time2 as integer
    FIELD times as char
    INDEX pi IS PRIMARY UNIQUE time1 time2
    INDEX ps times.
/* $Workfile$ e n d */