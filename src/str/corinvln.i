/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Корректировка или (если нет) создание строки inv-line для складского документа (весовой учет топлива)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/18/07
Author: Dmitry Ukhanov
Creation date: 10/18/07

Автор1: Булгаков Андрей Николаевич
Дата создания1: 04/22/05

*/

&scop proc-name lib-trn3_corinvln
{&run_proc_lib-trn3}
( input  {1}         /* doc-code        */
 ,input  {2}         /* artic           */
 ,input  {3}         /* prod-type       */
 ,input  {4}         /* prod-code       */
 ,input  {5}         /* sale-rubl (kg)  */
 ,input  {6}         /* sale-base (kg)  */
 ,input  {7}         /* acc-rubl  (kg)  */
 ,input  {8}         /* acc-base  (kg)  */
 ,input  {9}         /* fact-qnty (kg)  */
 ,input  {10}        /* density         */
 ,output {11}        /* recid(inv-line) */
 ) {12}.

/* $Workfile$   E n d */
