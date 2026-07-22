block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trnsupds.p $
$Archive: str/trnsupds.p $

Расчет cli-gds по ДК при закрытии накладной

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/31/04
Author: Bakhtadze Natalya
Creation date: 05/31/04

*/

define input  parameter p-chk-doc-code  as character no-undo .
define input  parameter p-trn-doc-close as logical   no-undo .
/*
p-doc-code - код документа
p-trn-doc-close = true - документ закрывается до статуса факт
p-trn-doc-close = false - документ удаляется.

*/



def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: trnsupds.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/trnsupds.p $":U .
def var vss-description as character no-undo init "Расчет cli-gds по ДК".
{ cmp/vssrevis.i "substitute('&1|&2', p-chk-doc-code, p-trn-doc-close)" }

{ cmp/trg-def.i }
{ cmp/library.i }
{ rep/r-sale.i }


define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-sign as integer no-undo .
define variable v-fact-qnty         like ub.ot-line.fact-qnty       no-undo .
define variable v-vat-pc            like ub.doc-line.vat-pc         no-undo .
define variable v-slt-pc            like ub.doc-line.slt-pc         no-undo .
define variable v-sum-base          like ub.ot-line.sum-base        no-undo .
define variable v-sum-rubl          like ub.ot-line.sum-rubl        no-undo .
define variable v-vat-base          like ub.ot-line.vat-base        no-undo .
define variable v-vat-rubl          like ub.ot-line.vat-rubl        no-undo .
define variable v-slt-base          like ub.ot-line.slt-base        no-undo .
define variable v-slt-rubl          like ub.ot-line.slt-rubl        no-undo .
define variable v-road-tax-base     like ub.ot-line.road-tax-base   no-undo .
define variable v-road-tax-rubl     like ub.ot-line.road-tax-rubl   no-undo .
define variable v-transport-base    like ub.ot-line.transport-base  no-undo .
define variable v-transport-rubl    like ub.ot-line.transport-rubl  no-undo .
define variable v-other-base        like ub.ot-line.other-base      no-undo .
define variable v-other-rubl        like ub.ot-line.other-rubl      no-undo .
define variable v-excise-base       like ub.ot-line.excise-base     no-undo .
define variable v-excise-rubl       like ub.ot-line.excise-rubl     no-undo .
define variable v-curr-r-b          as character                    no-undo .

DEFINE VARIABLE  pay-sum-base as decimal no-undo.
DEFINE VARIABLE  pay-sum-rubl as decimal no-undo.
DEFINE VARIABLE  discnt-sum-base as decimal no-undo .
DEFINE VARIABLE  discnt-sum-rubl as decimal no-undo .
define variable v-doc-code like ub.trn-doc.doc-code no-undo .
define variable ret-doc-code like ub.trn-doc.doc-code no-undo .


define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_cli-gds for ub.cli-gds.
define buffer buf_clients for ub.clients.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_ret-doc for ub.trn-doc.
define buffer buf_dis-card for ub.dis-card.

&scop sign v-sign *


_main:
do
on error undo, return error
:

  find first buf_chk-doc no-lock where
            buf_Chk-doc.doc-code = p-chk-doc-code no-error .
  if not available buf_chk-doc then do:
     undo _main, return error substitute("Не найден чек с номером &1", p-chk-doc-code).
  end.
  find first buf_dis-card no-lock where
            buf_dis-card.d-card = buf_chk-doc.d-card no-error .
  if not available buf_dis-card then do:
      undo _main, return error substitute("Не найдена дисконтная карта с номером &1 по чеку &2 в продаже &3"
                                        , buf_chk-doc.d-card
                                        , buf_chk-doc.doc-code
                                        , buf_chk-doc.out-code).
  end.

  find first buf_trn-doc no-lock where
            buf_trn-doc.doc-code = buf_chk-doc.out-code no-error .
  if not available buf_trn-doc then do:
     undo _main, return error substitute("Не найден документ с номером &1", buf_chk-doc.out-code).
  end.
  if buf_chk-doc.netto < 0 then do:
    find first buf_ret-doc no-lock where
              buf_ret-doc.doc-code = buf_trn-doc.out-code no-error .
    if available buf_ret-doc then do:
      ret-doc-code = buf_ret-doc.doc-code.
    end.
    else do:
      ret-doc-code = '':U.
    end.
  end.
  assign
  v-host-code = buf_trn-doc.host-code
  v-sign = (if p-trn-doc-close then 1 else - 1)
  v-doc-code = (if buf_chk-doc.netto >= 0 then buf_trn-doc.doc-code else ret-doc-code)
  .
  { gbl/curr-r-b.i
    v-curr-r-b
  }

  _chk-gds:
  for  EACH buf_chk-gds WHERE
              buf_chk-gds.doc-code = buf_chk-doc.doc-code AND
              buf_chk-gds.b-code <> 0 NO-LOCK ,
        FIRST buf_bar-code where
              buf_bar-code.b-code = buf_chk-gds.b-code No-LOCK,
        FIRST buf_goods where
              buf_goods.gds-code = buf_bar-code.gds-code No-LOCK,
        FIRST buf_doc-line WHERE
              buf_doc-line.doc-code = v-doc-code AND
              buf_doc-line.prod-code = buf_goods.prod-code AND
              buf_doc-line.prod-type = buf_goods.prod-type AND
              buf_doc-line.artic     = buf_goods.artic NO-LOCK
              On error undo _main, return error
              :
      if buf_chk-gds.write-off-code <> ?
      and buf_chk-gds.write-off-code > 0 then NEXT _chk-gds.
      FIND FIRST buf_cli-gds WHERE
                  buf_cli-gds.cli-type  = buf_dis-card.cli-type AND
                  buf_cli-gds.cli-code  = buf_dis-card.cli-code AND
                  buf_cli-gds.artic     = buf_goods.artic AND
                  buf_cli-gds.prod-type = buf_goods.prod-type AND
                  buf_cli-gds.prod-code = buf_goods.prod-code AND
                  buf_cli-gds.host-code = v-host-code NO-ERROR .
      if NOT available buf_cli-gds then do:
        CREATE buf_cli-gds.
        assign
        buf_cli-gds.artic      = buf_goods.artic
        buf_cli-gds.prod-code  = buf_goods.prod-code
        buf_cli-gds.prod-type  = buf_goods.prod-type
        buf_cli-gds.host-code  = v-host-code
        buf_cli-gds.cli-type   = buf_dis-card.cli-type
        buf_cli-gds.cli-code   = buf_dis-card.cli-code
        buf_cli-gds.out-qnty   = 0
        buf_cli-gds.out-sum    = 0
        buf_cli-gds.ret-qnty   = 0
        buf_cli-gds.ret-sum    = 0
        buf_cli-gds.out-discnt = 0
        buf_cli-gds.ret-discnt = 0
        .
      end.
      if buf_chk-gds.doc-qnty > 0 then
      assign
      buf_cli-gds.out-qnty = buf_cli-gds.out-qnty + {&sign} buf_chk-gds.doc-qnty
      buf_cli-gds.out-sum = buf_cli-gds.out-sum +
                          {&sign} ( buf_chk-gds.price-base - buf_chk-gds.discnt ) * buf_chk-gds.doc-qnty
      buf_cli-gds.out-discnt = buf_cli-gds.out-discnt +
                              {&sign} buf_chk-gds.discnt * buf_chk-gds.doc-qnty
      .
      else
      assign
      buf_cli-gds.ret-qnty = buf_cli-gds.ret-qnty - {&sign} buf_chk-gds.doc-qnty
      buf_cli-gds.ret-sum = buf_cli-gds.ret-sum -
                          {&sign} ( buf_chk-gds.price-base - buf_chk-gds.discnt ) * buf_chk-gds.doc-qnty
      buf_cli-gds.ret-discnt = buf_cli-gds.ret-discnt -
                              {&sign} buf_chk-gds.discnt * buf_chk-gds.doc-qnty
      .
  END. /* FOR EACH buf_chk-doc ... */
end. /*doe*/