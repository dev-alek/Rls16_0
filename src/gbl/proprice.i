/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение сумм и цен в ценах производителя по баркоду

Автор: Чернова Светлана Александровна
Дата создания: 11/01/09
Author: Svetlana Chernova
Creation date: 11/01/09

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name proprice
{&run_proc_library}
(  input  {1}  /* p-bar-code                */
 , input  {2}  /* p-obj-type                */
 , input  {3}  /* p-obj-code                */
 , output {4}  /* p-prod-price-vat в валюте rb  */
 , output {5}  /* p-prod-price+vat в валюте rb  */
 , output {6}  /* p-prod-vat-pc */
 , output {7}  /* p-part-code */
 , output {8}  /* p-in-code */
        ) {9} .

/* $Workfile$ e n d */