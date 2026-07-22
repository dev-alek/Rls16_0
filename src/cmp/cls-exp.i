/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет выведен в файл

Автор: Чернова Светлана Александровна
Дата создания: 04/12/06
Author: Svetlana Chernova
Creation date: 04/12/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output {1} {2} CLOSE.
message "Отчет выведен в файл:" SKIP
                ReportFileName
                view-as alert-box INFORMATION buttons OK TITLE " ".
/* $Workfile$ e n d */