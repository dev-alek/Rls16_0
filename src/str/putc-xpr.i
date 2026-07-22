/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура отсылки файла параметров на IBM-XML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/25/09
Author: Bakhtadze Natalya
Creation date: 06/25/09

*/


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".


procedure putc-xpr :
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input parameter p-version like ub.cash-desk.version no-undo .
define input parameter p-cash-os like ub.cash-desk.cash-os no-undo .
define input parameter p-cash-num like ub.cash-desk.cash-num  no-undo .
define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-what-send as character no-undo .
define variable v-cash-num as integer no-undo init -1.
define variable v-ii as integer no-undo .
define variable v-jj as integer no-undo .
define variable v-override as integer no-undo .

define buffer buf_cash-desk-attr for ub.cash-desk-attr.
define buffer buf2_cash-desk-attr for ub.cash-desk-attr.

  do
  on error undo, return error return-value
  :
    v-what-send = buf_ext-file.file-name.
    run adm/extfsavd.p (
                  INPUT buf_ext-file.db-num
                  ,INPUT buf_ext-file.from-db-num
                  ,INPUT buf_ext-file.file-num
                  ,INPUT v-xml-file-name-path  +  "xm1"
                  ,INPUT-OUTPUT v-override) NO-ERROR.

  end.

end procedure. /* putc-xpr */

/* $Workfile$ e n d */