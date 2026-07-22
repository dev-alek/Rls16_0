/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

ВЫЗОВ ПРОЦЕДУРЫ КОТОРАЯ ВОЗВРАЩАЕТ ЗНАЧЕНИЯ ПЕРЕМЕННЫХ С ПЕРВОЙ ЗАКЛАДКИ

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Creation date: 03/11/04 11:47
сама процедура лежит в varfpage.i

*/

define variable v-radio-customer as integer no-undo . /* выбор из блока ВЫБОР КОНТРАГЕНТА       */
define variable v-radio-schet    as integer no-undo . /* выбор из блока ВЫБОР банковского СЧЕТА */
define variable v-curr-code      as integer no-undo . /* выбор валюты  из блока ВЫБОР банковского СЧЕТА */
define variable v-radio-period   as character no-undo . /* выбор относительного периода времени */
define variable v-keep-spis      as character no-undo . /* выбор относительного периода времени */
run get-var-from-1-report-page (
    output v-radio-customer ,
    output v-radio-schet,
    output v-curr-code,
    output v-radio-period ,
    output v-keep-spis ) .

/* $Workfile$ e n d */