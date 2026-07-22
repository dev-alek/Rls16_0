/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Открытие потока - касса IBM NKT-IBM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


fname = substring( string( next-value( s-spool, {&db-name_schema} ), '99999999999999999999'), 13, 8 ).

&if "{&subject}" = "dis-card" &then
    /*готовим пустую болванку*/
   v-record = fill( {&question-mark} + {&delim-par}, 400).
&endif
&if "{&subject}" = "pay" &then
    /*готовим пустую болванку*/
    v-record = fill( {&question-mark} + {&delim-par}, 465).
&endif
&if "{&subject}" = "good" or "{&subject}" = "gds-obj-attr" &then
    /*готовим пустую болванку*/
    v-record = fill( {&question-mark} + {&delim-par}, 7).
&endif

&if "{&subject}" = "tot-discnt" &then
    /*готовим пустую болванку*/
    v-record = fill( {&question-mark} + {&delim-par}, 1).
&endif


/* $Workfile$ e n d */