/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Разнообразное копирование в приходный документ

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


*/
&scop proc-name lib-trn_copy-inh
{&run_proc_lib-trn}
( input {1}        /*parparentproc           */
 ,input {2}        /*parrec-doc              */
 ,input {3}        /*parmode                 */
 ,input {4}        /*parrecalc               */
 ,input {5}        /*parrsrv-fact-qnty       */
 ,input table {6}  /*lib-trn_ret-doc         */
 ,input table {7}  /*lib-trn_ret-line        */
 ,input table {8}  /*lib-trn_ret-line-attr   */
 ,input table {9}  /*lib-trn_ret-dtl         */
 ,input table {10} /*lib-trn_ret-parts       */
  ) {11} .
/* $Workfile$ e n d */