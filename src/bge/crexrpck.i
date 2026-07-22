/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

СОзадние записи о принятом пакете

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/22/08
Author: Bakhtadze Natalya
Creation date: 10/22/08

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

find buf_esys-pck-rcvd exclusive-lock
  where buf_esys-pck-rcvd.esys-id  = {&esys-id}
    and buf_esys-pck-rcvd.db-num   = {&esys-db-num}
    and buf_esys-pck-rcvd.espr-cr-db-num   = {&cr-db-num}
    and buf_esys-pck-rcvd.espr-pack-num = {&pack-num}
  no-error.
if not available buf_esys-pck-rcvd then do:
  create buf_esys-pck-rcvd.
  assign
  buf_esys-pck-rcvd.esys-id    = {&esys-id}
  buf_esys-pck-rcvd.db-num     = {&esys-db-num}
  buf_esys-pck-rcvd.espr-cr-db-num     = {&cr-db-num}
  buf_esys-pck-rcvd.espr-pack-num   = {&pack-num}
  .
end.

/* $Workfile$ e n d */