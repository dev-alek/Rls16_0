block-level on error undo, throw.
/*

$Revision: 784232a2254b, 2720, rls $
$Author: SSlivenko $
$Date: Пн янв 18 10:14:30 2021 +0300 $
$Workfile: 00049000.p $
$Archive: cut/00049000.p $

Файл пирога обрезания. Относится к категории 49.

Автор: Хныкин Павел Андреевич
Дата создания: 08/05/09
Author: Pavel Khnykin
Creation date: 08/05/09

Обработка таблиц:
BatchProcess
Filter
db-filter
db-filter-attr
filter-attr

*/

define variable vss-revision    as character no-undo init "$Revision: 784232a2254b, 2720, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн янв 18 10:14:30 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00049000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00049000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 9.".
{ cmp/str-glbl.i }

define buffer old-BatchProcess for src.BatchProcess.
define buffer new-BatchProcess for dst.BatchProcess.
define buffer old-Filter       for ubfltsrc.Filter.
define buffer new-Filter       for ubfltdst.Filter.
define buffer new-goods        for dst.goods.

define buffer old-db-filter      for src.db-filter     .
define buffer old-db-filter-attr for src.db-filter-attr.
define buffer old-filter-attr    for ubfltsrc.filter-attr   .


define buffer new-db-filter      for dst.db-filter     .
define buffer new-db-filter-attr for dst.db-filter-attr.
define buffer new-filter-attr    for ubfltdst.filter-attr   .



define variable v-need-copy-batchprocess as logical   no-undo .

do
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  { utl/00000001.i }
  on write  of dst.batchprocess     override do: end.
  on write  of ubfltdst.filter      override do: end.
  on create of ubfltdst.filter      override do: end.
  on WRITE  of dst.db-filter        override do: end.
  on WRITE  of dst.db-filter-attr   override do: end.
  on WRITE  of ubfltdst.filter-attr override do: end.

  { utl/00000002.i Filter }

  for each old-BatchProcess no-lock
    where old-BatchProcess.bp_type = {&btpr-type-prc}
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  :
    /* задания на перерасчёт переоценок после закрытия документов задним числом */
    run check-exist in this-procedure
      (input  'price-doc':u                /* p-table-name */
      ,input  old-batchprocess.charkey_one /* p-doc-code   */
      ,output v-need-copy-batchprocess     /* p-need-copy  */
      ) .

    if v-need-copy-batchprocess = true
    then do:
      create new-batchprocess.
      buffer-copy old-batchprocess to new-batchprocess.
    end.
  end.

  for each old-BatchProcess no-lock
    where old-BatchProcess.bp_type = {&btpr-type-trnhd}
  on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
  :
    /* задания на перерасчёт заголовков складских документов */
    run check-exist in this-procedure
      (input  'trn-doc':u                  /* p-table-name */
      ,input  old-batchprocess.charkey_one /* p-doc-code   */
      ,output v-need-copy-batchprocess     /* p-need-copy  */
      ) .

    if v-need-copy-batchprocess = true
    then do:
      create new-batchprocess.
      buffer-copy old-batchprocess to new-batchprocess.
    end.
  end.

  if vartype-cut = 1
  then do:
    /* производится обрезание документов в ГБД */
    /* выгружаем задания на расчёт складских архивов для */
    for each old-BatchProcess no-lock
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    :
      case old-BatchProcess.BP_type
      :
        when {&btpr-type-autonws} or
        when {&btpr-type-autoarh} or
        when {&btpr-type-autoexp} or
        when {&btpr-type-autosuz} or
        when {&btpr-type-autogetcd} or
        when {&btpr-type-autosale} or
        when {&btpr-type-autocbnk} or
        when {&btpr-type-autofree} or
        when {&btpr-type-mercury} or
        when {&btpr-type-hddtest} or
        when {&btpr-type-is_motp} or
        when {&btpr-type-is_diadoc} or
        when {&btpr-type-is_PM}
        then do:
        end.
        when {&btpr-type-cutdbs}
        then do:
        end.
        when {&btpr-type-autoupg}
        then do:
        end.
        when {&btpr-type-prc} or
        when {&btpr-type-trnhd}
        then do:
          /* здесь ничего не делаем */
          /* так как эти задания уже были обработаны ранее в этой же программе */
        end.
        when {&btpr-type-rt-doc} or
        when {&btpr-type-rt-line} or
        when {&btpr-type-rt-bcprint}
        then do:
          /* Записи игнорируются. Вся работа с радиотерминалом при обрезании будет потеряна */
        end.
        when {&btpr-type-arh}
        then do:
          /* задания на расчёт складского архива по товарам */
          run check-exist in this-procedure
            (input  old-batchprocess.charkey_two /* p-table-name */
            ,input  old-batchprocess.charkey_one /* p-doc-code   */
            ,output v-need-copy-batchprocess     /* p-need-copy  */
            ) .

          if v-need-copy-batchprocess = true
          then do:
            create new-batchprocess.
            buffer-copy old-batchprocess to new-batchprocess.
          end.
        end.
        when {&btpr-type-ahsp}
        then do:
          /* задания на расчёт складского архива по поставщикам */
          run check-exist in this-procedure
            (input  old-batchprocess.charkey_two /* p-table-name */
            ,input  old-batchprocess.charkey_one /* p-doc-code   */
            ,output v-need-copy-batchprocess     /* p-need-copy  */
            ) .

          if v-need-copy-batchprocess = true
          then do:
            create new-batchprocess.
            buffer-copy old-batchprocess to new-batchprocess.
          end.
        end.
        when {&btpr-type-aht}
        then do:
          /* задания на расчёт складского архива по типам приобретения */
          run check-exist in this-procedure
            (input  old-batchprocess.charkey_two /* p-table-name */
            ,input  old-batchprocess.charkey_one /* p-doc-code   */
            ,output v-need-copy-batchprocess     /* p-need-copy  */
            ) .

          if v-need-copy-batchprocess = true
          then do:
            create new-batchprocess.
            buffer-copy old-batchprocess to new-batchprocess.
          end.
        end.
        when {&btpr-type-hold}
        then do:
          /* задания на расчёт межфирменного архива по приходам и расходам */
          run check-exist in this-procedure
            (input  'trn-doc':u                  /* p-table-name */
            ,input  old-batchprocess.charkey_one /* p-doc-code   */
            ,output v-need-copy-batchprocess     /* p-need-copy  */
            ) .

          if v-need-copy-batchprocess = true
          then do:
            create new-batchprocess.
            buffer-copy old-batchprocess to new-batchprocess.
          end.
        end.
        when {&btpr-type-hinv}
        then do:
          /* задания на расчёт межфирменного архива по инвентаризациям */
          run check-exist in this-procedure
            (input  'trn-doc':u                  /* p-table-name */
            ,input  old-batchprocess.charkey_one /* p-doc-code   */
            ,output v-need-copy-batchprocess     /* p-need-copy  */
            ) .

          if v-need-copy-batchprocess = true
          then do:
            create new-batchprocess.
            buffer-copy old-batchprocess to new-batchprocess.
          end.
        end.
        when {&btpr-type-hspi}
        then do:
          /* задания на расчёт межфирменного архива по документам списания */
          run check-exist in this-procedure
            (input  'trn-doc':u                  /* p-table-name */
            ,input  old-batchprocess.charkey_one /* p-doc-code   */
            ,output v-need-copy-batchprocess     /* p-need-copy  */
            ) .

          if v-need-copy-batchprocess = true
          then do:
            create new-batchprocess.
            buffer-copy old-batchprocess to new-batchprocess.
          end.
        end.
        when {&btpr-type-gds}
        then do:
          /*задание на отправку товара на кассу*/
           find first new-goods no-lock where
                  new-goods.gds-code   = old-BatchProcess.key#_one no-error.
           if available new-goods then do:
              create new-batchprocess.
              buffer-copy old-batchprocess to new-batchprocess.
           end.
        end.
        when {&btpr-type-dcard}
        then do:
          /* задание на отправку ДК на кассу*/
          create new-batchprocess.
          buffer-copy old-batchprocess to new-batchprocess.
        end.
        when {&btpr-type-goa}
        then do:
           /*задание на отправку скидок на кассу*/
           find first new-goods no-lock where
                  new-goods.gds-code   = old-BatchProcess.key#_one no-error.
           if available new-goods then do:
              create new-batchprocess.
              buffer-copy old-batchprocess to new-batchprocess.
           end.
        end.
        when {&btpr-type-seller}
        then do:
          /* задание на отправку продавца на кассу*/
          create new-batchprocess.
          buffer-copy old-batchprocess to new-batchprocess.
        end.
        when {&btpr-type-cashier}
        then do:
          /* задание на отправку кассира на кассу*/
          create new-batchprocess.
          buffer-copy old-batchprocess to new-batchprocess.
        end.
        when {&btpr-type-move-object}
        then do:
          /*его не может быть - если он есть обрезание не запуститься - см chk-btpr.p*/
        end.
        when {&btpr-type-bcode}
        then do:
            /*ничего не надо делать - пока не используется*/
        end.
        when {&btpr-type-fgrp}
        then do:
         /*задание на отправку групп меню*/
          create new-batchprocess.
          buffer-copy old-batchprocess to new-batchprocess.
        end.
        when {&btpr-type-ren-art}
        then do:
          /*его не может быть - если он есть обрезание не запуститься - см chk-btpr.p*/
        end.
        when {&btpr-type-autooxml} then do:
          create new-batchprocess.
          buffer-copy old-batchprocess to new-batchprocess.
        end.
        otherwise do:
          if old-BatchProcess.BP_type begins {&btpr-type-lock}
          or old-BatchProcess.BP_type begins 'lusr':U
          then do:
            /* записи блокировки ресурсов */
            /* переносить их не надо */
          end.
          else do:
            return error substitute("Неизвестный тип BatchProcess &1", old-BatchProcess.BP_type ) .
          end.
        end.
      end case.
    end.
  end.

  { utl/00000002.i db-filter      }
  { utl/00000002.i db-filter-attr }
  { utl/00000002.i filter-attr    }

  output stream str-gen close.
  return "Произведен экспорт таблиц: BatchProcess Filter db-filter db-filter-attr filter-attr .".
end.


procedure check-exist :

  define input  parameter p-table-name as character no-undo .
  define input  parameter p-doc-code   as character no-undo .
  define output parameter p-need-copy  as logical   no-undo .

  define buffer new-trn-doc      for dst.trn-doc .
  define buffer new-price-doc    for dst.price-doc .

  do
  on error undo, return error return-value
  :
    assign
      p-need-copy = false
    .

    case p-table-name
    :
      when 'trn-doc':u
      then do:
        find first new-trn-doc no-lock
          where new-trn-doc.doc-code = p-doc-code
          no-error .
        if available new-trn-doc
        then do:
          assign
            p-need-copy = true
          .
        end.
      end.
      when 'price-doc':u
      then do:
        find first new-price-doc no-lock
          where new-price-doc.doc-num = p-doc-code
          no-error .
        if available new-price-doc
        then do:
          assign
            p-need-copy = true
          .
        end.
      end.
      otherwise do:
        undo, return error substitute("Неизвестный тип задания &1", p-table-name) .
      end.
    end case .
  end.

end procedure. /* check-exist */