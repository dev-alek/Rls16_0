/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение настроек ценообразовани

Автор: Чернова Светлана Александровна
Дата создания: 03/15/07
Author: Svetlana Chernova
Creation date: 03/15/07

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name glstall
{&run_proc_library}
(  output {1}  /* p-use-grp-buy          */
 , output {2}  /* p-use-oborot-buy       */
 , output {3}  /* p-use-qnty-group       */
 , output {4}  /* p-use-sum-group        */
 , output {5}  /* p-use-add-code         */
 , output {6}  /* p-use-sys-date-time    */
 , output {7}  /* p-use-shift-date-num   */
 , output {8}  /* p-use-cassa            */
 , output {9}  /* p-use-val              */
 , output {10} /* p-use-pay-type         */
 , output {11} /* p-use-cash-pay         */
 , output {12} /* p-use-child            */
        ) {13} .

/* $Workfile$ e n d */