/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Нетрадиционное употребление поля whole-send-news

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/02/08
Author: Bakhtadze Natalya
Creation date: 12/02/08

Внимание!!! - данный файл не содержит никаких 4GL конструкций и является чисто информационным

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

в ord-doc - дорога доставки документа - 1 - edoc 2 edi-exite
ord-doc.whole-send-news

в ord-doc-rcv - дорога доставки документа - 1 - edoc 2 edi-exite
ord-doc-rcv.whole-send-news

в trn-doc - дорога доставки документа - 1 - edoc 2 edi-exite
trn-doc.whole-send-news

в chk-doc  тип POS   -int
chk-doc.whole-send-news

в chk-title  тип POS - int
chk-title.whole-send-news

/* $Workfile$ e n d */