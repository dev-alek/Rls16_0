/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
&if '{2}' = '1' &then
Num#str# = Num#str# + 1. &endif
&if '{2}' = 'C-i' &then   if c-i = 1 THEN  Num#str# = Num#str# + 1. &endif
&If "{2}" = "2"  or  "{2}" = "1"
&then
run macr_excel_char ( string({1})  , num#str# , {2} ) .
&else
run macr_excel_dec ( {1}  , num#str# , {2} ) .
&endif
/* $Workfile$ e n d */