/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Открытие потока - касса R-KEEPER

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


assign
fname = substring( string( next-value( s-spool, {&db-name_schema}), '99999999999999999999'), 13, 8 )
.
output stream IBMStream
to value( out + fname + '.txt' ) convert target "1251".


/* $Workfile$ e n d */