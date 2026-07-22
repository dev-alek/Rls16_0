block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-shft7r.p $
$Archive: rep/r-shft7r.p $

сбор данных для печати сменного отчета (лист 7)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/06/07
Author: Dmitry Ukhanov
Creation date: 08/06/07

*/

DEFINE INPUT PARAMETER pobj-type like ub.shift-obj.obj-type no-undo.
DEFINE INPUT PARAMETER pobj-code like ub.shift-obj.obj-code no-undo.
DEFINE INPUT PARAMETER pshift-date like ub.shift-obj.shift-date no-undo.
DEFINE INPUT PARAMETER pshift-num like ub.shift-obj.shift-num no-undo.
DEFINE INPUT PARAMETER pshift-date1 like ub.shift-obj.shift-date no-undo.
DEFINE INPUT PARAMETER pshift-num1 like ub.shift-obj.shift-num no-undo.
define input parameter p-previous-shift-date as date no-undo .


DEF VAR vss-revision    AS CHAR NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U.
DEF VAR vss-author      AS CHAR NO-UNDO INIT "$Author: expertek $":U.
DEF VAR vss-date        AS CHAR NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
DEF VAR vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: r-shft7r.p $":U.
DEF VAR vss-archive     AS CHAR NO-UNDO INIT "$Archive: rep/r-shft7r.p $":U.
DEF VAR vss-description AS CHAR NO-UNDO INIT "$Сбор данных для сменного отчета - лист 5 $":U.

{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ rep/icm-7df.i  SHARED}

define buffer buf_icnt-doc for ub.icnt-doc .
define buffer buf_icnt-line for ub.icnt-line .
define buffer buf_pump-nozzle for ub.pump-nozzle .
define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle .
define buffer buf_pl-gds for ub.pl-gds .
define buffer buf_goods for ub.goods .


for each t-7:
  delete t-7.
end.

{ trg/factord.i }
{ rep/r-shftfo.i attr-arh-detail-date }

for each buf_icnt-doc no-lock
  where buf_icnt-doc.obj-type     = pobj-type
    and buf_icnt-doc.obj-code     = pobj-code
    and buf_icnt-doc.doc-type     = {&icnt-err}
    and buf_icnt-doc.ext-doc-type = {&TDEICNT_Err-meas}
    and buf_icnt-doc.status_      = {&fact}
    and buf_icnt-doc.fact-order   >= prev-fo
    and buf_icnt-doc.fact-order   <= fo
on error undo, return error return-value
:
  for each buf_icnt-line no-lock
    where buf_icnt-line.doc-code = buf_icnt-doc.doc-code
      and buf_icnt-line.obj-code = buf_icnt-doc.obj-code
      and buf_icnt-line.obj-type = buf_icnt-doc.obj-type
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.gds-code = buf_icnt-line.gds-code
      no-error .
    create t-7.
    assign
      t-7.pump-code    = buf_icnt-line.pump-code
      t-7.nozzle-code  = buf_icnt-line.nozzle-code
      t-7.gds-code     = buf_icnt-line.gds-code
      t-7.gds-name     = ( if available buf_goods then buf_goods.gds-name else "Неизвестное название" )
      t-7.state-el-cnt = buf_icnt-line.state-el-cnt
      t-7.state-mh-cnt = buf_icnt-line.state-mh-cnt
      t-7.fact-order   = buf_icnt-doc.fact-order
    .
  end.
end.

/*for each buf_pump-nozzle no-lock*/
/*  where buf_pump-nozzle.obj-type = tt-icnt-doc.obj-type*/
/*    and buf_pump-nozzle.obj-code = tt-icnt-doc.obj-code*/
/*    and buf_pump-nozzle.is-meas  = yes*/
/*on error undo tr, return error return-value*/
/*:*/
/*  find first buf_pl-pump-nozzle no-lock*/
/*    where buf_pl-pump-nozzle.obj-type    = buf_pump-nozzle.obj-type*/
/*      and buf_pl-pump-nozzle.obj-code    = buf_pump-nozzle.obj-code*/
/*      and buf_pl-pump-nozzle.pump-code   = buf_pump-nozzle.pump-code*/
/*      and buf_pl-pump-nozzle.nozzle-code = buf_pump-nozzle.nozzle-code*/
/*    no-error.*/
/*  if available buf_pl-pump-nozzle then do:*/
/*    find first buf_pl-gds no-lock*/
/*      where buf_pl-gds.obj-type  = buf_pl-pump-nozzle.obj-type*/
/*        and buf_pl-gds.obj-code  = buf_pl-pump-nozzle.obj-code*/
/*        and buf_pl-gds.pl-code   = buf_pl-pump-nozzle.pl-code*/
/*      no-error.*/
/*  end.*/
/*/*           create tt-icnt-line.*/*/
/*/*           assign*/*/
/*/*           tt-icnt-line.doc-code     = tt-icnt-doc.doc-code*/*/
/*/*           tt-icnt-line.obj-type     = tt-icnt-doc.obj-type*/*/
/*/*           tt-icnt-line.obj-code     = tt-icnt-doc.obj-code*/*/
/*/*           tt-icnt-line.pump-code    = buf_pump-nozzle.pump-code*/*/
/*/*           tt-icnt-line.nozzle-code  = buf_pump-nozzle.nozzle-code*/*/
/*/*           tt-icnt-line.pl-code      = (if available buf_pl-pump-nozzle*/*/
/*/*                                           then buf_pl-pump-nozzle.pl-code*/*/
/*/*                                           else ?)*/*/
/*/*           tt-icnt-line.gds-code     = (if available buf_pl-gds*/*/
/*/*                                           then buf_pl-gds.gds-code*/*/
/*/*                                            else ?)*/*/
/*/*           tt-icnt-line.meas-el-cnt  = ?*/*/
/*/*           tt-icnt-line.state-el-cnt = ?*/*/
/*/*           tt-icnt-line.state-mh-cnt = ?*/*/
/*/*          .*/*/
/*end.*/