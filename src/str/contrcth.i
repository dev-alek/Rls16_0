/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запись истории по договору

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/15/10
Author: Bakhtadze Natalya
Creation date: 07/15/10

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure contrcth_write-hist :
define input parameter p-host-code as integer no-undo .
define input parameter p-contract-code as integer no-undo .

define variable p-sys-time   as character no-undo .
define buffer buf_contract for ub.contract.
define buffer buf_c-contract for c-contract.

do
on error undo, return error
:
  find first buf_contract exclusive-lock where
              buf_contract.host-code = p-host-code
          and buf_contract.contract-code = p-contract-code .


  create buf_c-contract .
  BUFFER-COPY buf_contract TO buf_c-contract .

  { gbl/curdburt.i
    buf_contract.user-db-num
    buf_contract.user-name
    buf_contract.spec-date
    p-sys-time
    buf_contract.spec-time
  }
  assign
  buf_c-contract.chip-num         = next-value (s-corr-chip, {&db-name_schema})
  buf_c-contract.corr-user-db-num = buf_contract.user-db-num
  buf_c-contract.corr-user-name   = buf_contract.user-name
  buf_c-contract.corr-date        = buf_contract.spec-date
  buf_c-contract.corr-time        = buf_contract.spec-time
  .

end.
end procedure. /* contrcth_write-hist */


/* $Workfile$ e n d */