/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Пересчет инкремента в разных режимах

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
/*-------------------------------------------------------------------------------------
    Program:  mode-out.i
    Created:  Суслов Алексей Юрьевич  25 Aug 1999
Description:  Пересчет инкремента в разных режимах
              {1} - присваиваемое поле накладной
              {2} - высчитываемое из признаков
              {3} - вид accumulate
              {4} - режим пересчета
              {5} -суффикс к accumulate
Last change:  Суслов Алексей Юрьевич  25 Aug 1999    4:00 pm
-------------------------------------------------------------------------------------*/
&IF TRIM("{4}") <> ""
&THEN
(IF t-doc.{1} = ? THEN 0 ELSE t-doc.{1}) +
&ENDIF

(IF (accum {3} {2}) = ? THEN 0 ELSE (accum {3} {2}))

&IF TRIM("{4}") = "update" or TRIM("{4}") = "delete"
&THEN
-
(IF (accum {3} {2} {5}) = ? THEN 0 ELSE (accum {3} {2} {5}))
&ENDIF
