/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Копирование во внешнюю приходную накладную или запрос из любого источника

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&scop proc-name lib-trn4_copy-in
{&run_proc_lib-trn4}
( input {1}       /*parparentproc           */
 ,input {2}       /*parrec-doc              */
 ,input table {3} /*lib-trn_ret-doc         */
 ,input table {4} /*lib-trn_ret-line        */
 ,input table {5} /*lib-trn_ret-line-attr   */
 ,input table {6} /*lib-trn_ret-dtl         */
 ,input table {7} /*lib-trn_ret-parts       */
 ,input {8}       /*parquestions            */
 ,input {9}       /*parwait-on              */
 ,input {10}      /*parrigid-rsrv           */
 ,input {11}      /*parrsrv-fact-qnty       */
 ,input {12}      /*parhandle-waitfram*/
  ) {13} .
/* $Workfile$ e n d */