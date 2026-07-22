/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

дополнительне переменные для работы


Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 04/12/02 4:19

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if "{1}"  = "" &Then
define variable to-day       as date no-undo .
&endif
&if "{1}"  = "pr" &Then
 { gbl/curobjdt.i store-type store-code to-day }
&endif
/* $Workfile$ e n d */