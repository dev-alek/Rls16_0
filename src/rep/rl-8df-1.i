/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Бахтадзе Наталья Викторовна
Дата создания: 08/02/07
Author: Bakhtadze Natalya
Creation date: 08/02/07

информация по связке ведомость-товар-клиент
ЮКОС лист 8

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DEFINE {1} TEMP-TABLE treal-8 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal  /*это всегда base*/
FIELD netto-rubl as decimal
FIELD cli-type as character
FIELD cli-code as integer
INDEX pi IS  unique  primary
gds-code
cpay-code
curr-code
cli-type
cli-code
index  ipay cpay-code curr-code
index icli cli-type cli-code
.

/* $Workfile$ e n d */