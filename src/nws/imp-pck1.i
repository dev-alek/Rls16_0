/*

$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

ФАЙЛ ГЕНЕРИРУЕТСЯ ПРОЦЕДУРОЙ utl/gen-imp.p


Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/27/03
Author: Dmitry Ukhanov
Creation date: 01/27/03

*/


&scoped-define vssseq {&sequence}             
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-proc-name  as character no-undo .
define variable v-proc-avail as logical   no-undo .

define new global shared variable g#load-rec  as handle no-undo .

