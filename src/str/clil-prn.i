/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт списка клиентов в формате EXCEL и обычном формате

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FOR EACH {1} No-LOCK
    BREAK
    BY {1}.obj-type
    BY {1}.obj-code:
  assign
  accum-count = accum-count + 1
  .
  for-stts = if {1}.stts > 0 then 'удален' else ''.
  FIND  ub.dis-card No-LOCK WHERE
        ub.dis-card.cli-type = {1}.obj-type AND
        ub.dis-card.cli-type = {1}.obj-type No-ERROR.
  if avail ub.dis-card then do:
    if AMBIGUOUS dis-card then  for-dis-card = "...".
    else for-dis-card = ub.dis-card.d-card .
  end.
  else for-dis-card = "".
  if {1}.obj-type = {&prs} then do:
    find first ub.person no-lock where
        ub.person.psn-code = {1}.obj-code No-ERROR.
    if avail person then do:
      assign
      for-cashier = gbclcode-is-psn-role({&role-cashier}, ub.person.psn-code, v-today)
      for-seller  = gbclcode-is-psn-role( {&role-seller}, ub.person.psn-code, v-today)
      .
    end.
    else
    assign
    for-cashier = 0
    for-seller = 0.
  end.
  else
  assign
  for-cashier = 0
  for-seller = 0.

  { rep/dincol.i di 1 for-obj-type
                {1}.obj-type }
  { rep/dincol.i di 2 for-obj-code
                 {1}.obj-code }
  { rep/dincol.i di 3 for-obj-name
                 {1}.obj-name }
  { rep/dincol.i di 4 for-grp-name
                 {1}.grp-name }
  { rep/dincol.i di 5 for-db-num
                 " if {1}.db-num <> ? then string({1}.db-num) else '' " }
  { rep/dincol.i di 6 for-stts
                 for-stts }
  { rep/dincol.i di 7 for-is-prod
                 {1}.is-prod }
  { rep/dincol.i di 8 for-sup-gds
                 {1}.sup-gds }
  { rep/dincol.i di 9 for-sup-cons
                 {1}.sup-cons }
  { rep/dincol.i di 10 for-buy-gds
                 {1}.buy-gds }
  { rep/dincol.i di 11 for-buy-cons
                 {1}.buy-cons }
  { rep/dincol.i di 12 for-buy-serv
                 {1}.buy-serv }
  { rep/dincol.i di 13 for-cashier
                  for-cashier }
  { rep/dincol.i di 14 for-seller
                  for-seller }
  { rep/dincol.i di 15 for-dis-card
                  for-dis-card }
  { rep/dincol.i di 16 for-PS
                  {1}.PS }

  {&DISPLAY-FRAME}

  {&PutExcel}
  { rep/dincol.i dix 1 for-obj-type {1}.obj-type }
  { rep/dincol.i dix 2 for-obj-code {1}.obj-code }
  { rep/dincol.i dix 3 for-obj-name {1}.obj-name }
  { rep/dincol.i dix 4 for-grp-name  {1}.grp-name }
  { rep/dincol.i dix 5 for-db-num    " if {1}.db-num <> ? then string({1}.db-num) else ''" }
  { rep/dincol.i dix 6 for-stts      for-stts  }
  { rep/dincol.i dix 7 for-is-prod   {1}.is-prod }
  { rep/dincol.i dix 8 for-sup-gds   {1}.sup-gds }
  { rep/dincol.i dix 9 for-sup-cons  {1}.sup-cons }
  { rep/dincol.i dix 10 for-buy-gds  {1}.buy-gds }
  { rep/dincol.i dix 11 for-buy-cons {1}.buy-cons }
  { rep/dincol.i dix 12 for-buy-serv {1}.buy-serv }
  { rep/dincol.i dix 13 for-cashier  for-cashier }
  { rep/dincol.i dix 14 for-seller   for-seller }
  { rep/dincol.i dix 15 for-dis-card for-dis-card }
  { rep/dincol.i dix 16 for-PS       {1}.PS }

  skip.


  IF LAST({1}.obj-code) then do:
    {&UNDERLINE-FRAME}

    { rep/dincol.i di 2 for-obj-code
                   accum-count }

    { rep/dincol.i di 3 for-obj-name
                   " 'клиентов в спискe' " }

    {&DISPLAY-FRAME}
  end.

END. /*for each {1} */




/* $Workfile$ e n d */