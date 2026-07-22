/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Чернова Светлана Александровна
Дата создания: 03/24/06
Author: Svetlana Chernova
Creation date: 03/24/06

*/
If Make-Excel-com THEN DO:
&if '{2}' = '1' &then   Num#str# = Num#str# + 1. &endif  &if '{2}' = 'C-i' &then   if c-i = 1 THEN  Num#str# = Num#str# + 1. &endif    ch#workSheet:Range(COL-name[{2}] + string(Num#str#)):Value = {1} .
&if '{3}' = 'bold' &then    ch#workSheet:Range(COL-name[{2}] + string(Num#str#)):Font:Bold = TRUE . &endif
&if '{3}' = 'italic' &then    ch#workSheet:Range(COL-name[{2}] + string(Num#str#)):Font:italic = TRUE . &endif
&if '{3}' = 'bold+italic' &then    ch#workSheet:Range(COL-name[{2}] + string(Num#str#)):Font:bold = TRUE . ch#workSheet:Range(COL-name[{2}] + string(Num#str#)):Font:italic = TRUE . &endif
&if '{3}' = 'regular' &then    ch#workSheet:Range(COL-name[{2}] + string(Num#str#)):Font:bold = false  .    ch#workSheet:Range(COL-name[{2}] + string(Num#str#)):Font:italic = false  . &endif
&if '{4}' <> '' &then    ch#workSheet:Range(COL-name[{2}] + string(Num#str#)):{4} . &endif
End.