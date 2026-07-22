block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: 36493b7e3299, 155, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Sep 15 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00043000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00043000.p $".
define variable vss-description as character no-undo init "Чистка УБД.".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define input parameter vardate-actual-docs    as date      no-undo.
define input parameter varcall-back           as handle no-undo.
define variable vDeleted as int64     no-undo.
define variable vResult  as character no-undo.
define buffer buf_clients for ub.clients.
find ub.sys-ctrl no-lock.
if not available ub.sys-ctrl then do:
   return error "Не найдена уникальная запись sys-ctrl.".
end.
define buffer trn-doc     for ub.trn-doc .
define buffer buf_trn-doc for ub.trn-doc .
on delete of ub.trn-doc         override do: end.
for each buf_clients no-lock
   where buf_clients.db-num <> ?
:
  for each trn-doc no-lock where
           trn-doc.obj-type   = buf_clients.obj-type
       and trn-doc.obj-code   = buf_clients.obj-code
       and trn-doc.doc-date  < vardate-actual-docs
  on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    run cleanTable in this-procedure.
    find first buf_trn-doc exclusive-lock where
           recid(buf_trn-doc) = recid(trn-doc) no-error no-wait.
if not avail buf_trn-doc then
do:
  undo, return error "Ошибка удаления trn-doc. Запись занята другим пользователем.".
end.
delete buf_trn-doc.
vDeleted = vDeleted + 1.
  end.
end.
vResult = substitute("Произведена чистка таблиц: &1~nУдалено записей - &2.", "Накладные, История по накладным, Кассовый отчет с историей, Документы инвентаризации с историей, Кассовые чеки с историей, Архив скл. док. по контрактам", vDeleted).
return vResult.
procedure cleanTable:
  define buffer doc-attr for ub.doc-attr.
on delete of ub.doc-attr override do: end.
for each doc-attr exclusive-lock
    where doc-attr.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete doc-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-doc-attr for ub.c-doc-attr.
on delete of ub.c-doc-attr override do: end.
for each c-doc-attr exclusive-lock
    where c-doc-attr.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete c-doc-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer doc-line for ub.doc-line.
on delete of ub.doc-line override do: end.
for each doc-line exclusive-lock
    where doc-line.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete doc-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer doc-line-attr for ub.doc-line-attr.
on delete of ub.doc-line-attr override do: end.
for each doc-line-attr exclusive-lock
    where doc-line-attr.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete doc-line-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-doc-line-attr for ub.c-doc-line-attr.
on delete of ub.c-doc-line-attr override do: end.
for each c-doc-line-attr exclusive-lock
     where c-doc-line-attr.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete c-doc-line-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-doc-line for ub.c-doc-line.
on delete of ub.c-doc-line override do: end.
for each c-doc-line exclusive-lock
     where c-doc-line.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete c-doc-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-trn-doc for ub.c-trn-doc.
on delete of ub.c-trn-doc override do: end.
for each c-trn-doc exclusive-lock
     where c-trn-doc.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete c-trn-doc no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer gds-dtl for ub.gds-dtl.
on delete of ub.gds-dtl override do: end.
for each gds-dtl exclusive-lock
    where gds-dtl.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete gds-dtl no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer gds-dtl-attr for ub.gds-dtl-attr.
on delete of ub.gds-dtl-attr override do: end.
for each gds-dtl-attr exclusive-lock
    where gds-dtl-attr.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete gds-dtl-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-gds-dtl for ub.c-gds-dtl.
on delete of ub.c-gds-dtl override do: end.
for each c-gds-dtl exclusive-lock
    where c-gds-dtl.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete c-gds-dtl no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-gds-dtl-attr for ub.c-gds-dtl-attr.
on delete of ub.c-gds-dtl-attr override do: end.
for each c-gds-dtl-attr exclusive-lock
    where c-gds-dtl-attr.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete c-gds-dtl-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer doc-pl     for ub.doc-pl.
  on delete of ub.doc-pl  override do: end.
  for each doc-pl exclusive-lock where
           doc-pl.out-code = trn-doc.doc-code
  :
    define buffer c-doc-pl for ub.c-doc-pl.
on delete of ub.c-doc-pl override do: end.
for each c-doc-pl exclusive-lock
    where c-doc-pl.obj-type = doc-pl.obj-type
          and c-doc-pl.obj-code = doc-pl.obj-code
          and c-doc-pl.pl-code  = doc-pl.pl-code
          and c-doc-pl.out-code = doc-pl.out-code
          and c-doc-pl.gds-code = doc-pl.gds-code
on error undo, return error
:
      delete c-doc-pl no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer doc-pl-attr for ub.doc-pl-attr.
on delete of ub.doc-pl-attr override do: end.
for each doc-pl-attr exclusive-lock
    where doc-pl-attr.obj-type = doc-pl.obj-type
          and doc-pl-attr.obj-code = doc-pl.obj-code
          and doc-pl-attr.pl-code  = doc-pl.pl-code
          and doc-pl-attr.out-code = doc-pl.out-code
          and doc-pl-attr.gds-code = doc-pl.gds-code
on error undo, return error
:
      delete doc-pl-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    delete doc-pl.
    vDeleted = vDeleted + 1.
  end.
  define buffer doc-pl-pump     for ub.doc-pl-pump.
  on delete of ub.doc-pl-pump  override do: end.
  for each doc-pl-pump exclusive-lock where
           doc-pl-pump.out-code = trn-doc.doc-code
  :
    define buffer c-doc-pl-pump for ub.c-doc-pl-pump.
on delete of ub.c-doc-pl-pump override do: end.
for each c-doc-pl-pump exclusive-lock
    where c-doc-pl-pump.obj-type  = doc-pl-pump.obj-type
          and c-doc-pl-pump.obj-code  = doc-pl-pump.obj-code
          and c-doc-pl-pump.pl-code   = doc-pl-pump.pl-code
          and c-doc-pl-pump.pump-code = doc-pl-pump.pump-code
          and c-doc-pl-pump.out-code  = doc-pl-pump.out-code
          and c-doc-pl-pump.gds-code  = doc-pl-pump.gds-code
on error undo, return error
:
      delete c-doc-pl-pump no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer doc-pl-pump-attr for ub.doc-pl-pump-attr.
on delete of ub.doc-pl-pump-attr override do: end.
for each doc-pl-pump-attr exclusive-lock
    where doc-pl-pump-attr.obj-type  = doc-pl-pump.obj-type
          and doc-pl-pump-attr.obj-code  = doc-pl-pump.obj-code
          and doc-pl-pump-attr.pl-code   = doc-pl-pump.pl-code
          and doc-pl-pump-attr.pump-code = doc-pl-pump.pump-code
          and doc-pl-pump-attr.out-code  = doc-pl-pump.out-code
          and doc-pl-pump-attr.gds-code  = doc-pl-pump.gds-code
on error undo, return error
:
      delete doc-pl-pump-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    delete doc-pl-pump.
    vDeleted = vDeleted + 1.
  end.
  define buffer inv-doc for ub.inv-doc.
on delete of ub.inv-doc override do: end.
for each inv-doc exclusive-lock
    where inv-doc.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete inv-doc no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer inv-line for ub.inv-line.
on delete of ub.inv-line override do: end.
for each inv-line exclusive-lock
    where inv-line.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete inv-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-inv-line for ub.c-inv-line.
on delete of ub.c-inv-line override do: end.
for each c-inv-line exclusive-lock
    where c-inv-line.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete c-inv-line no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer inv-line-attr for ub.inv-line-attr.
on delete of ub.inv-line-attr override do: end.
for each inv-line-attr exclusive-lock
    where inv-line-attr.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete inv-line-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer inv-doc-attr for ub.inv-doc-attr.
on delete of ub.inv-doc-attr override do: end.
for each inv-doc-attr exclusive-lock
    where inv-doc-attr.doc-code = trn-doc.doc-cod
on error undo, return error
:
      delete inv-doc-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer doc-prts for ub.doc-prts.
on delete of ub.doc-prts override do: end.
for each doc-prts exclusive-lock
    where doc-prts.out-code = trn-doc.doc-code
on error undo, return error
:
      delete doc-prts no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer doc-prts-attr for ub.doc-prts-attr.
on delete of ub.doc-prts-attr override do: end.
for each doc-prts-attr exclusive-lock
    where doc-prts-attr.out-code = trn-doc.doc-code
on error undo, return error
:
      delete doc-prts-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-doc-prts for ub.c-doc-prts.
on delete of ub.c-doc-prts override do: end.
for each c-doc-prts exclusive-lock
    where c-doc-prts.out-code = trn-doc.doc-code
on error undo, return error
:
      delete c-doc-prts no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer parts for ub.parts.
  define buffer goods for ub.goods.
  on delete of ub.parts  override do: end.
  for each parts exclusive-lock where
           parts.out-code = trn-doc.doc-code,
      first goods no-lock where
            goods.artic     =  parts.artic
        and goods.prod-type =  parts.prod-type
        and goods.prod-code =  parts.prod-code
  :
    define buffer parts-attr for ub.parts-attr.
on delete of ub.parts-attr override do: end.
for each parts-attr exclusive-lock
    where parts-attr.in-code   = parts.in-code
         and parts-attr.gds-code  = goods.gds-code
         and parts-attr.part-code = parts.part-code
on error undo, return error
:
      delete parts-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-parts-attr for ub.c-parts-attr.
on delete of ub.c-parts-attr override do: end.
for each c-parts-attr exclusive-lock
    where c-parts-attr.in-code   = parts.in-code
          and c-parts-attr.gds-code  = goods.gds-code
          and c-parts-attr.part-code = parts.part-code
on error undo, return error
:
      delete c-parts-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    delete parts.
    vDeleted = vDeleted + 1.
  end.
  define buffer c-parts for ub.c-parts.
on delete of ub.c-parts override do: end.
for each c-parts exclusive-lock
    where c-parts.out-code = trn-doc.doc-code
on error undo, return error
:
      delete c-parts no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  if trn-doc.ext-doc-type = 'es':U
  or trn-doc.ext-doc-type = 'rs':U
  then do:
    define buffer doc-fbr-gds for ub.doc-fbr-gds.
on delete of ub.doc-fbr-gds override do: end.
for each doc-fbr-gds exclusive-lock
    where doc-fbr-gds.out-code  = trn-doc.doc-code
on error undo, return error
:
      delete doc-fbr-gds no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  end.
  if trn-doc.ext-doc-type = 'es':U then do:
    define buffer inkas for ub.inkas.
on delete of ub.inkas override do: end.
for each inkas exclusive-lock
    where inkas.inkas-code = trn-doc.doc-cod
on error undo, return error
:
      delete inkas no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer inkas-pay for ub.inkas-pay.
on delete of ub.inkas-pay override do: end.
for each inkas-pay exclusive-lock
    where inkas-pay.inkas-code = trn-doc.doc-code
on error undo, return error
:
      delete inkas-pay no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer inkas-pay-attr for ub.inkas-pay-attr.
on delete of ub.inkas-pay-attr override do: end.
for each inkas-pay-attr exclusive-lock
    where inkas-pay-attr.inkas-code = trn-doc.doc-code
on error undo, return error
:
      delete inkas-pay-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer inkas-pay-desk for ub.inkas-pay-desk.
on delete of ub.inkas-pay-desk override do: end.
for each inkas-pay-desk exclusive-lock
    where inkas-pay-desk.inkas-code = trn-doc.doc-code
on error undo, return error
:
      delete inkas-pay-desk no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer inkas-pay-desk-attr for ub.inkas-pay-desk-attr.
on delete of ub.inkas-pay-desk-attr override do: end.
for each inkas-pay-desk-attr exclusive-lock
    where inkas-pay-desk-attr.inkas-code = trn-doc.doc-code
on error undo, return error
:
      delete inkas-pay-desk-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer inkas-pay-wth for ub.inkas-pay-wth.
on delete of ub.inkas-pay-wth override do: end.
for each inkas-pay-wth exclusive-lock
    where inkas-pay-wth.inkas-code = trn-doc.doc-code
on error undo, return error
:
      delete inkas-pay-wth no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-inkas for ub.c-inkas.
on delete of ub.c-inkas override do: end.
for each c-inkas exclusive-lock
    where c-inkas.inkas-code = trn-doc.doc-code
on error undo, return error
:
      delete c-inkas no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-inkas-pay for ub.c-inkas-pay.
on delete of ub.c-inkas-pay override do: end.
for each c-inkas-pay exclusive-lock
    where c-inkas-pay.inkas-code = trn-doc.doc-code
on error undo, return error
:
      delete c-inkas-pay no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-inkas-pay-desk for ub.c-inkas-pay-desk.
on delete of ub.c-inkas-pay-desk override do: end.
for each c-inkas-pay-desk exclusive-lock
    where c-inkas-pay-desk.inkas-code = trn-doc.doc-code
on error undo, return error
:
      delete c-inkas-pay-desk no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-inkas-pay-wth for ub.c-inkas-pay-wth.
on delete of ub.c-inkas-pay-wth override do: end.
for each c-inkas-pay-wth exclusive-lock
    where c-inkas-pay-wth.inkas-code = trn-doc.doc-code
on error undo, return error
:
      delete c-inkas-pay-wth no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer sale-doc for ub.sale-doc.
on delete of ub.sale-doc override do: end.
for each sale-doc exclusive-lock
    where sale-doc.inkas-code = trn-doc.doc-code
on error undo, return error
:
      delete sale-doc no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer sale-doc-attr for ub.sale-doc-attr.
on delete of ub.sale-doc-attr override do: end.
for each sale-doc-attr exclusive-lock
    where sale-doc-attr.inkas-code = trn-doc.doc-code
on error undo, return error
:
      delete sale-doc-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-sale-doc for ub.c-sale-doc.
on delete of ub.c-sale-doc override do: end.
for each c-sale-doc exclusive-lock
    where c-sale-doc.inkas-code = trn-doc.doc-cod
on error undo, return error
:
      delete c-sale-doc no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer chk-doc         for ub.chk-doc .
    define buffer chk-doc-attr    for ub.chk-doc-attr .
    define buffer chk-slip-head   for ub.chk-slip-head .
    on delete of ub.chk-doc      override do: end.
    on delete of ub.chk-doc-attr override do: end.
    on delete of ub.chk-slip-head override do: end.
    for each chk-doc exclusive-lock
       where chk-doc.out-code = trn-doc.doc-code
    :
      for each chk-doc-attr exclusive-lock
         where chk-doc-attr.doc-code = chk-doc.doc-code
      :
        if chk-doc-attr.attr-code = "CheckId" and
           chk-doc-attr.attr-value <> "" then
        do:
          for each chk-slip-head exclusive-lock
             where chk-slip-head.db-num  = buf_clients.db-num
               and chk-slip-head.CheckId = chk-doc-attr.attr-value
          :
            define buffer chk-slip-string for ub.chk-slip-string.
on delete of ub.chk-slip-string override do: end.
for each chk-slip-string exclusive-lock
    where chk-slip-string.db-num  = chk-slip-head.db-num
                 and chk-slip-string.Id      = chk-slip-head.Id
                 and chk-slip-string.CheckId = chk-slip-head.CheckId
on error undo, return error
:
      delete chk-slip-string no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
            delete chk-slip-head.
            vDeleted = vDeleted + 1.
          end.
        end.
        delete chk-doc-attr.
        vDeleted = vDeleted + 1.
      end.
      delete chk-doc.
      vDeleted = vDeleted + 1.
    end.
    define buffer chk-gds         for ub.chk-gds .
    on delete of ub.chk-gds      override do: end.
    for each chk-gds exclusive-lock
       where chk-gds.out-code = trn-doc.doc-code
    :
      define buffer chk-gds-attr for ub.chk-gds-attr.
on delete of ub.chk-gds-attr override do: end.
for each chk-gds-attr exclusive-lock
    where chk-gds-attr.doc-code = chk-gds.doc-code
on error undo, return error
:
      delete chk-gds-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
      delete chk-gds.
      vDeleted = vDeleted + 1.
    end.
    define buffer chk-pay         for ub.chk-pay .
    on delete of ub.chk-pay      override do: end.
    for each chk-pay exclusive-lock
       where chk-pay.out-code = trn-doc.doc-code
    :
      define buffer chk-pay-attr for ub.chk-pay-attr.
on delete of ub.chk-pay-attr override do: end.
for each chk-pay-attr exclusive-lock
    where chk-pay-attr.doc-code = chk-pay.doc-code
on error undo, return error
:
      delete chk-pay-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
      delete chk-pay.
      vDeleted = vDeleted + 1.
    end.
    define buffer chk-discnt         for ub.chk-discnt .
    on delete of ub.chk-discnt      override do: end.
    for each chk-discnt exclusive-lock
       where chk-discnt.out-code = trn-doc.doc-code
    :
      define buffer chk-discnt-attr for ub.chk-discnt-attr.
on delete of ub.chk-discnt-attr override do: end.
for each chk-discnt-attr exclusive-lock
    where chk-discnt-attr.doc-code = chk-discnt.doc-code
on error undo, return error
:
      delete chk-discnt-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
      delete chk-discnt.
      vDeleted = vDeleted + 1.
    end.
    define buffer chk-gds-pay for ub.chk-gds-pay.
on delete of ub.chk-gds-pay override do: end.
for each chk-gds-pay exclusive-lock
    where chk-gds-pay.out-code = trn-doc.doc-code
on error undo, return error
:
      delete chk-gds-pay no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-chk-doc for ub.c-chk-doc.
on delete of ub.c-chk-doc override do: end.
for each c-chk-doc exclusive-lock
    where c-chk-doc.out-code = trn-doc.doc-code
on error undo, return error
:
      delete c-chk-doc no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-chk-gds for ub.c-chk-gds.
on delete of ub.c-chk-gds override do: end.
for each c-chk-gds exclusive-lock
    where c-chk-gds.out-code = trn-doc.doc-code
on error undo, return error
:
      delete c-chk-gds no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-chk-pay for ub.c-chk-pay.
on delete of ub.c-chk-pay override do: end.
for each c-chk-pay exclusive-lock
    where c-chk-pay.out-code = trn-doc.doc-code
on error undo, return error
:
      delete c-chk-pay no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-chk-discnt for ub.c-chk-discnt.
on delete of ub.c-chk-discnt override do: end.
for each c-chk-discnt exclusive-lock
    where c-chk-discnt.out-code = trn-doc.doc-code
on error undo, return error
:
      delete c-chk-discnt no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    define buffer c-chk-doc-attr for ub.c-chk-doc-attr.
on delete of ub.c-chk-doc-attr override do: end.
for each c-chk-doc-attr exclusive-lock
    where c-chk-doc-attr.out-code = trn-doc.doc-code
on error undo, return error
:
      delete c-chk-doc-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  end.
  define buffer trn-doc-sum for ub.trn-doc-sum.
on delete of ub.trn-doc-sum override do: end.
for each trn-doc-sum exclusive-lock
    where trn-doc-sum.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete trn-doc-sum no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-trn-doc-sum for ub.c-trn-doc-sum.
on delete of ub.c-trn-doc-sum override do: end.
for each c-trn-doc-sum exclusive-lock
    where c-trn-doc-sum.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete c-trn-doc-sum no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer doc-line-sum for ub.doc-line-sum.
on delete of ub.doc-line-sum override do: end.
for each doc-line-sum exclusive-lock
    where doc-line-sum.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete doc-line-sum no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-doc-line-sum for ub.c-doc-line-sum.
on delete of ub.c-doc-line-sum override do: end.
for each c-doc-line-sum exclusive-lock
    where c-doc-line-sum.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete c-doc-line-sum no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer parts-root for ub.parts-root.
on delete of ub.parts-root override do: end.
for each parts-root exclusive-lock
    where parts-root.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete parts-root no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer parts-root-attr for ub.parts-root-attr.
on delete of ub.parts-root-attr override do: end.
for each parts-root-attr exclusive-lock
    where parts-root-attr.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete parts-root-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer c-parts-root for ub.c-parts-root.
on delete of ub.c-parts-root override do: end.
for each c-parts-root exclusive-lock
    where c-parts-root.doc-code = trn-doc.doc-code
on error undo, return error
:
      delete c-parts-root no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
  define buffer arh-trn-doc-contract for ub.arh-trn-doc-contract .
  on delete of ub.arh-trn-doc-contract         override do: end.
  for each arh-trn-doc-contract exclusive-lock where
           arh-trn-doc-contract.doc-code = trn-doc.doc-code
       and arh-trn-doc-contract.obj-type = buf_clients.obj-type
       and arh-trn-doc-contract.obj-code = buf_clients.obj-code
  :
    define buffer arh-trn-doc-contract-attr for ub.arh-trn-doc-contract-attr.
on delete of ub.arh-trn-doc-contract-attr override do: end.
for each arh-trn-doc-contract-attr exclusive-lock
    where arh-trn-doc-contract-attr.host-code     = arh-trn-doc-contract.host-code     and             arh-trn-doc-contract-attr.contract-code = arh-trn-doc-contract.contract-code and             arh-trn-doc-contract-attr.cli-type      = arh-trn-doc-contract.cli-type      and             arh-trn-doc-contract-attr.cli-code      = arh-trn-doc-contract.cli-code      and             arh-trn-doc-contract-attr.obj-type      = arh-trn-doc-contract.obj-type      and             arh-trn-doc-contract-attr.obj-code      = arh-trn-doc-contract.obj-code      and             arh-trn-doc-contract-attr.ext-doc-type  = arh-trn-doc-contract.ext-doc-type  and             arh-trn-doc-contract-attr.sum-type      = arh-trn-doc-contract.sum-type      and             arh-trn-doc-contract-attr.fact-order    = arh-trn-doc-contract.fact-order
on error undo, return error
:
      delete arh-trn-doc-contract-attr no-error.
      if error-status:error then
        undo, return error error-status:get-message(1).
      vDeleted = vDeleted + 1.
end.
    delete arh-trn-doc-contract.
    vDeleted = vDeleted + 1.
  end.
end procedure.
