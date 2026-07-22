/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт списка чеков в формате EXCEL и обычном формате

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FOR EACH {1} No-LOCK
    BREAK
    BY {1}.doc-code :
    for-chk-type = get-chk-type({1}.doc-code, {1}.chk-type, {1}.is-wth).
  assign
  accum-count = accum-count + 1
  .
  { rep/dincol.i di 1 for-doc-code
                {1}.doc-code }

  { rep/dincol.i di 2 for-chk-type
                 "get-chk-type({1}.doc-code, {1}.chk-type, {1}.is-wth )" }

  { rep/dincol.i di 3 for-obj-code
                 {1}.obj-code }

  { rep/dincol.i di 4 for-obj-type
                 {1}.obj-type }

  { rep/dincol.i di 5 for-chk-date
                 "string({1}.chk-date, '99/99/9999')" }

  { rep/dincol.i di 6 for-chk-time
                 "string({1}.chk-time, 'hh:mm:ss')" }

  { rep/dincol.i di 7 for-chk-num
                 {1}.chk-num }

  { rep/dincol.i di 8 for-pay-desk
                 {1}.pay-desk }

  { rep/dincol.i di 9 for-cashier
                 {1}.cashier }

  { rep/dincol.i di 10 for-out-code
                 {1}.out-code }

  { rep/dincol.i di 11 for-d-card
                 {1}.d-card }

  { rep/dincol.i di 12 for-doc-num
                 {1}.doc-num }

  { rep/dincol.i di 13 for-netto
                 {1}.netto }

  { rep/dincol.i di 14 for-discnt
                 {1}.discnt }

  { rep/dincol.i di 15 for-tot-doc
                 {1}.tot-doc }



  {&DISPLAY-FRAME}

  {&PutExcel}
  { rep/dincol.i dix 1 for-doc-code {1}.doc-code }
  { rep/dincol.i dix 2 for-chk-type  "get-chk-type({1}.doc-code, {1}.chk-type, {1}.is-wth )" }
  { rep/dincol.i dix 3 for-obj-type {1}.obj-type }
  { rep/dincol.i dix 4 for-obj-code {1}.obj-code }
  { rep/dincol.i dix 5 for-chk-date  "string({1}.chk-date, '99/99/9999')" }
  { rep/dincol.i dix 6 for-chk-time  "string({1}.chk-time, 'hh:mm:ss')" }
  { rep/dincol.i dix 7 for-chk-num  {1}.chk-num }
  { rep/dincol.i dix 8 for-pay-desk {1}.pay-desk }
  { rep/dincol.i dix 9 for-cashier  {1}.cashier }
  { rep/dincol.i dix 10 for-out-code {1}.out-code }
  { rep/dincol.i dix 11 for-d-card   {1}.d-card }
  { rep/dincol.i dix 12 for-doc-num  {1}.doc-num }
  { rep/dincol.i dix 13 for-netto    {1}.netto }
  { rep/dincol.i dix 14 for-discnt   {1}.discnt }
  { rep/dincol.i dix 15 for-tot-doc  {1}.tot-doc }
  skip.


  IF LAST({1}.doc-code) then do:

    {&UNDERLINE-FRAME}

    { rep/dincol.i di 1 for-doc-code
                   string(accum-count) }

    { rep/dincol.i di 2 for-chk-type
                   " 'чеков' " }

    {&DISPLAY-FRAME}

  end.

END. /*for each {1} */




/* $Workfile$ e n d */