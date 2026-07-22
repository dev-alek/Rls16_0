/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Описание вызова внешних процедур

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:
    1. Место вызова в интерфейсе - уникально
    2. Название кнопки
    3. Имя процедуры
    4. sys-key белый список (ни у кого, кроме перечисленных, кнопка видна не будет)
    5. sys-key черный список (у перечисленных кнопка видна не будет)
Примечания:
    sys-key='IBS' дает доступ ко всем кнопкам
    в вызываемую процедуру всегда передаются текущий документ и список выбранных документов (два параметра)
*/

&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

{ str/ext-fill.i "{&documents}"   "'Ана&лиз'"   "'run-zapr.p'" "'BDC'"  "''" }
{ str/ext-fill.i "{&goods}"       "'Печ &Ценн'" "'run-zenn.p'" "'BDC'"  "''" }
{ str/ext-fill.i "{&print}"       "'&Экспорт'"  "'run-doc.p'"  "'BDC'"  "''" }
{ str/ext-fill.i "{&alt-barcode}" "'&Экспорт'"  "'run-bcod.p'" "'BDC'"  "''" }

/* $Workfile$ e n d */