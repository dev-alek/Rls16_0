/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Кусок печати  отчета по покупателям товаров (выкуп)

Автор: Демин Алексей Сергеевич
Дата создания: 03/24/06
Author: Alexey Demin
Creation date: 03/24/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".

  for each buf_trn-doc no-lock
    where buf_trn-doc.host-code = p-curr-host-code
      and buf_trn-doc.cli-type  = cli-buy.obj-type
      and buf_trn-doc.cli-code  = cli-buy.obj-code
      and buf_trn-doc.fact-date >= StartPoint
      and buf_trn-doc.fact-date <= EndPoint
    :
    if    buf_trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh}
      and buf_trn-doc.ext-doc-type <> {&TDEDT_Ras_Vnesh_Kass}
      and buf_trn-doc.ext-doc-type <> {&TDEDT_Vozvrat_Vnesh}
      and buf_trn-doc.ext-doc-type <> {&TDEDT_Vozvrat_Vnesh_Kass} then next .
    if    buf_trn-doc.status_ <> {&fact} then next .

    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }

    find first buy-data
      where buy-data.obj-type  = cli-buy.obj-type
        and buy-data.obj-code  = cli-buy.obj-code
      no-error .
    if not available buy-data then do:
      create buy-data .
      assign
        buy-data.obj-type = cli-buy.obj-type
        buy-data.obj-code = cli-buy.obj-code
        buy-data.Name     = cli-buy.obj-name
        buy-data.Sum-zak  = 0
        buy-data.Sum-prod = 0
        buy-data.Sum-skid = 0
        buy-data.EffValue = 0
      .
    end.

    find first buy-data-dt
      where buy-data-dt.obj-type  = cli-buy.obj-type
        and buy-data-dt.obj-code  = cli-buy.obj-code
        and buy-data-dt.cur-date1 <= buf_trn-doc.fact-date
        and buy-data-dt.cur-date2  > buf_trn-doc.fact-date
      no-error .
    if not available buy-data-dt then do:
      create buy-data-dt .
      assign
        buy-data-dt.obj-type = cli-buy.obj-type
        buy-data-dt.obj-code = cli-buy.obj-code
        buy-data-dt.Sum-zak  = 0
        buy-data-dt.Sum-prod = 0
        buy-data-dt.Sum-skid = 0
        buy-data-dt.EffValue = 0
        mon = month( buf_trn-doc.fact-date )
        yer = year ( buf_trn-doc.fact-date )
        buy-data-dt.cur-date1 = date(mon,1,yer)
      .
      if mon < 12 then assign buy-data-dt.cur-date2 = date(mon + 1,1,yer) .
      else             assign buy-data-dt.cur-date2 = date(1,1,yer + 1) .
    end.

    if buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} or
       buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} then do:
      if v-rb-is-base = yes then
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  - buf_trn-doc.fact-base
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid - buf_trn-doc.tot-calc
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod - buf_trn-doc.tot-doc + buf_trn-doc.tot-calc
          buy-data.Sum-zak     = buy-data.Sum-zak     - buf_trn-doc.fact-base
          buy-data.Sum-skid    = buy-data.Sum-skid    - buf_trn-doc.tot-calc
          buy-data.Sum-prod    = buy-data.Sum-prod    - buf_trn-doc.tot-doc
        .
      else
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  - buf_trn-doc.fact-rubl
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid - buf_trn-doc.discnt-rubl
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod - buf_trn-doc.tot-rubl + buf_trn-doc.discnt-rubl
          buy-data.Sum-zak     = buy-data.Sum-zak     - buf_trn-doc.fact-rubl
          buy-data.Sum-skid    = buy-data.Sum-skid    - buf_trn-doc.discnt-rubl
          buy-data.Sum-prod    = buy-data.Sum-prod    - buf_trn-doc.tot-rubl
        .
    end.
    else do:
      if v-rb-is-base = yes then
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  + buf_trn-doc.fact-base
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid + buf_trn-doc.tot-calc
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod + buf_trn-doc.tot-doc - buf_trn-doc.tot-calc
          buy-data.Sum-zak     = buy-data.Sum-zak     + buf_trn-doc.fact-base
          buy-data.Sum-skid    = buy-data.Sum-skid    + buf_trn-doc.tot-calc
          buy-data.Sum-prod    = buy-data.Sum-prod    + buf_trn-doc.tot-doc
        .
      else
        assign
          buy-data-dt.Sum-zak  = buy-data-dt.Sum-zak  + buf_trn-doc.fact-rubl
          buy-data-dt.Sum-skid = buy-data-dt.Sum-skid + buf_trn-doc.discnt-rubl
          buy-data-dt.Sum-prod = buy-data-dt.Sum-prod + buf_trn-doc.tot-rubl - buf_trn-doc.discnt-rubl
          buy-data.Sum-zak     = buy-data.Sum-zak     + buf_trn-doc.fact-rubl
          buy-data.Sum-skid    = buy-data.Sum-skid    + buf_trn-doc.discnt-rubl
          buy-data.Sum-prod    = buy-data.Sum-prod    + buf_trn-doc.tot-rubl
        .
    end.
  end.

/* $Workfile$ e n d */