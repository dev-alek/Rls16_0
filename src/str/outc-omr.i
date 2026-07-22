/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Открытие потока - касса OMRON

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{&subject}" = "good" &then
 output to value( out + fname + '.dat' ) convert target "ibm866".
&endif


/* $Workfile$ e n d */