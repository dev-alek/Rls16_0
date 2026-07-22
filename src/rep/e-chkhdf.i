/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Почасовой отчет по величинам сумм продаж - определение temp-table

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*кол-во покупок - строк чеков*/
DEFINE {1} temp-table chk-h no-undo
   field grp-code like ub.goods.grp-code
    field obj-code like ub.clients.obj-code
    field hour  as integer extent 24
    field qnty  as integer
    INDEX pi IS PRIMARY obj-code grp-code ASCENDING .

/*кол-во чеков*/
DEFINE {1} temp-table num-h no-undo
    field obj-code like ub.clients.obj-code
    field hour  as integer extent 24
    field qnty  as integer
    INDEX pi IS PRIMARY obj-code  ASCENDING .


/* $Workfile$ e n d */