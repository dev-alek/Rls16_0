block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : sendtest1c.p
    Purpose     : Тестовая процедура для отправки в 1С

    Syntax      :

    Description : 

    Author(s)   : Ростовцев Александр
    Created     : 03.07.2025
    Notes       :
  ----------------------------------------------------------------------*/
{ utl/runpro.i }
define input parameter parparentproc    as widget-handle no-undo .

{ cmp/trg-def.i  }
/*{ cmp/library.i  }*/
/*{ str/trdcalib.i }*/
{ utl/tt-test-1c.i new}
{ gbl/getcntxt.i def }

if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn)
  then run str/lib-trn.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn2)
  then run str/lib-trn2.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn3)
  then run str/lib-trn3.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn4)
  then run str/lib-trn4.p persistent no-error .
if not valid-handle (ibs.th.gbl.gbl-hndllib:g#trdcalib)
  then run str/trdcalib.p persistent no-error .

{ gbl/getcntxt.i get }

output stream vProtTest to "sendtest1c.log". 

define buffer buf_trn-doc   for ub.trn-doc.
define buffer buf_doc-attr  for ub.doc-attr.
define buffer buf_shift-obj for ub.shift-obj.
define buffer buf_rvs-doc   for ub.rvs-doc.
define buffer buf_price-doc for ub.price-doc.
define buffer buf_fin-doc   for ub.fin-doc.
define buffer buf_fbr-doc   for ub.fbr-doc.
define buffer buf_utd       for ub.utd.
define buffer buf_place       for ub.place.

/* Документа (накл., инв., перес.) */
/* trn-gd-docs */
find last buf_trn-doc where
          buf_trn-doc.obj-type = v-cntxt-obj-type
      and buf_trn-doc.obj-code = v-cntxt-obj-code
      and buf_trn-doc.status_ = "факт"
      and buf_trn-doc.flag_
      and (buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or
           buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or
           buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or
           buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh} or
           buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or
           buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} or
           buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Perem} or
           buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}) no-lock no-error.
if avail buf_trn-doc then
do:
  testId = rowid(buf_trn-doc).
  run utl/send1c.p.
  testId = ?.
end.

/* inv-gd-docs */
find last buf_trn-doc where
          buf_trn-doc.obj-type = v-cntxt-obj-type
      and buf_trn-doc.obj-code = v-cntxt-obj-code
      and buf_trn-doc.status_ = "факт"
      and buf_trn-doc.flag_
      and buf_trn-doc.ext-doc-type = {&TDEDT_Inv} no-lock no-error.
if avail buf_trn-doc then
do:
  testId = rowid(buf_trn-doc).
  run utl/send1c.p.
  testId = ?.
end.

/* peres-gd-docs */
find last buf_trn-doc where
          buf_trn-doc.obj-type = v-cntxt-obj-type
      and buf_trn-doc.obj-code = v-cntxt-obj-code
      and buf_trn-doc.status_ = "факт"
      and buf_trn-doc.flag_
      and buf_trn-doc.ext-doc-type = {&TDEDT_Peresort} no-lock no-error.
if avail buf_trn-doc then
do:
  testId = rowid(buf_trn-doc).
  run utl/send1c.p.
  testId = ?.
end.

/* Смена shifts и sales-p-shifts*/
find last buf_shift-obj where
          buf_shift-obj.obj-type = v-cntxt-obj-type
      and buf_shift-obj.obj-code = v-cntxt-obj-code
      and buf_shift-obj.status_  = "зкр" no-lock no-error.
if avail buf_shift-obj then
do:
  testid = rowid(buf_shift-obj).
  run utl/send2c.p.
  testId = ?.
end.

/* Сверки check-fuel-docs */
find last buf_rvs-doc where
          buf_rvs-doc.obj-type = v-cntxt-obj-type
      and buf_rvs-doc.obj-code = v-cntxt-obj-code
      and buf_rvs-doc.status_ = "факт"
     no-lock no-error.
if avail buf_rvs-doc then
do:
  testid = rowid(buf_rvs-doc).
  run utl/send3c.p.
  testId = ?.
end.

/* Переоценка price-docs*/
find last buf_price-doc where
          buf_price-doc.obj-type = v-cntxt-obj-type
      and buf_price-doc.obj-code = v-cntxt-obj-code
      and buf_price-doc.status_ = "акт"
     no-lock no-error.
if avail buf_price-doc then
do:
  testId = rowid(buf_price-doc).
  run utl/send4c.p.
  testId = ?.
end.

/* Фин. документ cash */
find last buf_fin-doc where
          buf_fin-doc.obj-type = v-cntxt-obj-type
      and buf_fin-doc.obj-code = v-cntxt-obj-code
      and buf_fin-doc.status_ = "факт"
     no-lock no-error.
if avail buf_fin-doc then
do:
  testId = rowid(buf_fin-doc).
  run utl/send5c.p.
  testId = ?.
end.

/* Документ производства trn-gd-docs (для fbr-doc)*/
find last buf_fbr-doc where
          buf_fbr-doc.obj-type = v-cntxt-obj-type
      and buf_fbr-doc.obj-code = v-cntxt-obj-code
      and buf_fbr-doc.status_ = "факт"
     no-lock no-error.
if avail buf_fbr-doc then
do:
  testId = rowid(buf_fbr-doc).
  run utl/send6c.p.
  testId = ?.
end.

/* Документ электронного документооборота edi-docs */
find last buf_utd where
          buf_utd.obj-type = v-cntxt-obj-type
      and buf_utd.obj-code = v-cntxt-obj-code
      and buf_utd.sts = 8 /* подтвержден */
     no-lock no-error.
if avail buf_utd then
do:
  testId = rowid(buf_utd).
  run utl/send7c.p.
  testId = ?.
end.

/* Текущая топология tanks*/
for each buf_place no-lock where buf_place.status_ <> {&deleted-status}:
  testId = rowid(buf_place).
  run utl/send9c.p.
end.
testId = ?.

/* Контрольная плотность НП shift-periods */
find last buf_shift-obj where
          buf_shift-obj.obj-type = v-cntxt-obj-type
      and buf_shift-obj.obj-code = v-cntxt-obj-code
      and buf_shift-obj.status_  = {&sht-closed} no-lock no-error.
if avail buf_shift-obj then
do:
  testid = rowid(buf_shift-obj).
  run utl/send10c.p.
  testId = ?.
end.

/*/* ??? не знаю что это выгружает */                                       */
/*for last buf_trn-doc where                                                */
/*         buf_trn-doc.obj-type = v-cntxt-obj-type                          */
/*     and buf_trn-doc.obj-code = v-cntxt-obj-code                          */
/*     and buf_trn-doc.status_ = "факт"                                     */
/*     and buf_trn-doc.flag_                                                */
/*     and can-find(first buf_doc-attr no-lock where                        */
/*                         buf_doc-attr.doc-code  = buf_trn-doc.doc-code and*/
/*                         buf_doc-attr.attr-code = {&trdcattr-is-lgas} and */
/*                         buf_doc-attr.attr-value = "yes")                 */
/*     no-lock:                                                             */
/*  testId = rowid(buf_trn-doc).                                            */
/*    run bge\send1cerp.p (?,                                               */
/*      this-procedure,                                                     */
/*      this-procedure,                                                     */
/*      "techlosses",                                                       */
/*      (buffer ub.trn-doc:handle),                                         */
/*      ?,                                                                  */
/*      ?) no-error.                                                        */
/*  testId = ?.                                                             */
/*end.                                                                      */


output stream vProtTest close.
message "Лог - " search("sendtest1c.log") view-as alert-box.
