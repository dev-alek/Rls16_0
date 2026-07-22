/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание записи пакета в ВС

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/22/08
Author: Bakhtadze Natalya
Creation date: 10/22/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".



create buf_esys-pck-sent.
assign
buf_esys-pck-sent.esps-CreDate        = {&pack-date}
buf_esys-pck-sent.esps-CreTimeInt     = {&pack-time}
buf_esys-pck-sent.esps-CreTime        = string( {&pack-time}, "HH:MM:SS" )
buf_esys-pck-sent.esys-id             = {&esys-id}
buf_esys-pck-sent.db-num              = {&esys-db-num}
buf_esys-pck-sent.esps-cr-db-num      = {&cr-db-num}
buf_esys-pck-sent.esps-pack-num       = {&pack-num}
buf_esys-pck-sent.esps-rcvd           = no
buf_esys-pck-sent.esps-total-recs     = ?
buf_esys-pck-sent.esps-CreNum         = 0
buf_esys-pck-sent.esps-SendTxtDate    = ?
buf_esys-pck-sent.esps-SendTxtTimeInt = 0
buf_esys-pck-sent.esps-SendTxtTime    = "":U
buf_esys-pck-sent.esps-rcvdDate       = ?
buf_esys-pck-sent.esps-RcvdTimeInt    = 0
buf_esys-pck-sent.esps-RcvdTime       = "":U
buf_esys-pck-sent.esps-CRC-pack       = substitute( "&1 &2 &3 &4", today, time, etime, DBTASKID( "ub":U ) )
.


/* $Workfile$ e n d */