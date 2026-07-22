/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт списка дисконтных карт в формате EXCEL и обычном формате

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

{ cmp/getdpcnt.i {1} }

FOR EACH {1} No-LOCK
    BREAK
    BY {1}.d-card:
  assign
  accum-count = accum-count + 1
  .
  for-status_ = {1}.status_.
  FIND FIRST  ub.clients No-LOCK WHERE
        ub.clients.obj-type = {1}.cli-type AND
        ub.clients.obj-code = {1}.cli-code No-ERROR.
  if avail ub.clients then do:
    for-cli-name = ub.clients.obj-name.
  end.
  else do:
    for-cli-name = "":U .
  end.

  for-obj-d-pcnt = get-d-pcnt (
                                buffer {1}
                               ,input parhost-code
                               ,input parobj-type
                               ,input parobj-code
                               ,input {&ddctr-def-pcnt}
                               ,output for-obj-d-pcntd).

  { rep/dincol.i di 1 for-d-card
                {1}.d-card }
  { rep/dincol.i di 2 for-cli-type
                 {1}.cli-type }
  { rep/dincol.i di 3 for-cli-code
                 {1}.cli-code }
  { rep/dincol.i di 4 for-cli-name
                  for-cli-name }
  { rep/dincol.i di 5 for-issue-code
                 {1}.issue-code }
  { rep/dincol.i di 6 for-issue-date
                 {1}.issue-date }
  { rep/dincol.i di 7 for-d-pcnt
                 {1}.d-pcnt }
  { rep/dincol.i di 8 for-status_
                 for-status_ }
  { rep/dincol.i di 9 for-emitent-host-code
                 {1}.emitent-host-code }
  { rep/dincol.i di 10 for-sourced-card
                 {1}.sourced-card }
  { rep/dincol.i di 11 for-obj-d-pcnt
                  for-obj-d-pcnt }
  { rep/dincol.i di 12 for-valid-date
                 {1}.valid-date }
  { rep/dincol.i di 13 for-type
                 {1}.type }
  { rep/dincol.i di 14 for-credit-card
                 {1}.credit-card }
  { rep/dincol.i di 15 for-lim-kr
                  {1}.lim-kr }
  { rep/dincol.i di 16 for-cash-d-pcnt
                  {1}.cash-d-pcnt }



  {&DISPLAY-FRAME}

  {&PutExcel}

  { rep/dincol.i dix 1 for-d-card
                {1}.d-card }
  { rep/dincol.i dix 2 for-cli-type
                 {1}.cli-type }
  { rep/dincol.i dix 3 for-cli-code
                 {1}.cli-code }
  { rep/dincol.i dix 4 for-cli-name
                  for-cli-name }
  { rep/dincol.i dix 5 for-issue-code
                 {1}.issue-code }
  { rep/dincol.i dix 6 for-issue-date
                 {1}.issue-date }
  { rep/dincol.i dix 7 for-d-pcnt
                 {1}.d-pcnt }
  { rep/dincol.i dix 8 for-status_
                 for-status_ }
  { rep/dincol.i dix 9 for-emitent-host-code
                 {1}.emitent-host-code }
  { rep/dincol.i dix 10 for-sourced-card
                 {1}.sourced-card }
  { rep/dincol.i dix 11 for-obj-d-pcnt
                 for-obj-d-pcnt }
  { rep/dincol.i dix 12 for-valid-date
                 {1}.valid-date }
  { rep/dincol.i dix 13 for-type
                 {1}.type }
  { rep/dincol.i dix 14 for-credit-card
                 {1}.credit-card }
  { rep/dincol.i dix 15 for-lim-kr
                  {1}.lim-kr }
  { rep/dincol.i dix 16 for-cash-d-pcnt
                  {1}.cash-d-pcnt }

  skip.


  IF LAST({1}.d-card) then do:
    {&UNDERLINE-FRAME}

    { rep/dincol.i di 1 for-d-card
                   " string(accum-count) + {&space-char} + 'карт в спискe'"  }

    {&DISPLAY-FRAME}
  end.

END. /*for each {1} */




/* $Workfile$ e n d */