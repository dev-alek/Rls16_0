/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение сумм в ценах производителя по партии

Автор: Чернова Светлана Александровна
Дата создания: 02/16/10
Author: Svetlana Chernova
Creation date: 02/16/10

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name partppric
{&run_proc_library}
(  buffer {1}  /* parts */
 , output {2}  /* p-prod-price-vat в валюте rb  */
 , output {3}  /* p-prod-price+vat в валюте rb  */
 , output {4}  /* p-prod-vat-pc */
        ) {5} .
/* $Workfile$ e n d */