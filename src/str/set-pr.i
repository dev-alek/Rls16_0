/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Установка цены

Автор: Чернова Светлана Александровна
Дата создания: 12/01/06
Author: Svetlana Chernova
Creation date: 12/01/06

create: Суслов Алексей Юрьевич

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop proc-name lib-trn3_set-pr
{&run_proc_lib-trn3}
  ( input {1} /*parrec-dtl*/
  , input {2} /*paruse-discnt-qnty*/
  , input {3} /*pardiscnt-qnty ДЛЯ МПЛ это количество gds-dtl */
  ) {4}.
/* $Workfile$ e n d */