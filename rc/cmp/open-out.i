/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Универсальный инклюд для вывода отчетов в временный файл

Автор: Чернова Светлана Александровна
Дата создания: 03/23/06
Author: Svetlana Chernova
Creation date: 03/23/06

*/
output {1} {2} to value( string( session:temp-directory +
                                     {&DF_Name} + string( g#report-num ) ) )
                                     page-size &if "{4}" = "" &then {&CS_PS} &else value({4}) &endif {3} .
/* $Workfile$ e n d */