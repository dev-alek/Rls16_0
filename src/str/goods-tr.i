/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка уникальности товара в пределах документа

Автор: Чернова Светлана Александровна
Дата создания: 03/24/08
Author: Svetlana Chernova
Creation date: 03/24/08

Автор1: Суслов Алексей Юрьевич
Дата создания: 09/19/05


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name lib-trn3_goods-tr
{&run_proc_lib-trn3}
(input {1}    /*parrec-doc  */
,input {2}    /*parrec-goods*/
) {3}
.
/* $Workfile$ e n d */