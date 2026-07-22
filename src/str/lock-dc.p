block-level on error undo, throw.
/*

$Revision: 5c3607367a23, 584, rls $
$Author: SShalanin $
$Date: Mon Apr 11 17:28:29 2016 +0400 $
$Workfile: lock-dc.p $
$Archive: str/lock-dc.p $

Блокировка ДК участвующих в продаже или накладной

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/17/06
Author: Bakhtadze Natalya
Creation date: 07/17/06

Блокируются все ДК
выполняется перед началом saledc

*/

define input parameter p-log-handle  as handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-doc-type as character no-undo .
define input parameter p-doc-code like ub.trn-doc.doc-code no-undo .
define input parameter p-d-card like ub.dis-card.d-card no-undo .
define input parameter p-step             as integer no-undo .
define input parameter p-is-news          as logical no-undo .
define input parameter log-file-name      as character no-undo .
define output parameter p-num-dc          as integer no-undo .



define variable vss-revision    as character no-undo initial "$Revision: 5c3607367a23, 584, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SShalanin $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Apr 11 17:28:29 2016 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: lock-dc.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/lock-dc.p $":U .
define variable vss-description as character no-undo initial "Блокировка товаров по документу":U .

{ cmp/vssrevis.i "substitute('&1|&2',p-doc-code,p-is-news)" }
{ cmp/trg-def.i }
{ cmp/library.i  }
{ gbl/key-rec.i }


define variable v-count   as integer   no-undo initial 0 .
define variable v-tbl-row as rowid no-undo .
define variable v-tbl-name as character no-undo .
define variable v-lock-chr as character no-undo .
define variable v-first-main-card as character no-undo .
define variable v-d-card as character no-undo .

define buffer buf_trn-doc  for ub.trn-doc .
define buffer buf_dis-card for ub.dis-card  .
define buffer buf2_dis-card for ub.dis-card  .
define buffer buf3_dis-card for ub.dis-card  .
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_fin-doc for ub.fin-doc.
define buffer buf_payment for ub.payment.


main-block :
do transaction
on error undo main-block, return error return-value
:

  if valid-handle(p-log-handle) then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Блокировка ДК..." )).
  end.

  CASE p-doc-type:
    when {&table_inkas} then do:
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
        no-error .
      if not available buf_trn-doc then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найден документ" skip
          "Документ" p-doc-code skip
          view-as alert-box error .
        undo main-block, return error .
      end.

      for each buf_chk-doc no-lock where
              buf_chk-doc.obj-type = buf_trn-doc.obj-type
          and buf_chk-doc.obj-code = buf_trn-doc.obj-code
          and buf_chk-doc.d-card > '':U
      on error undo main-block, return error
      :
        if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then NEXT .
        find first buf_dis-card no-lock
          where buf_dis-card.d-card = buf_chk-doc.d-card
          no-error .
        if not available buf_Dis-card then do:
          undo main-block, return error substitute ("&1 &2 &3&4Не найдена ДК&4Документ &5&4Чек &6"
                                                    ,vss-workfile
                                                    ,vss-revision
                                                    ,vss-description
                                                    ,{&new-line}
                                                    ,buf_trn-doc.doc-code
                                                    ,buf_chk-doc.doc-code).
        end.
        /* обновить информацию о текущей ДК строке */
        assign
        v-count  = v-count + 1
        .
        if v-count mod 10 = 0 then do:
          if log-file-name <> '':U
          and valid-handle (p-log-handle) then do:
            run show-counter in p-log-handle .
            run write-counter in p-log-handle (substitute("Обработано: &1. Подготовка данных - карта &2"
                                              , v-count
                                              , buf_dis-card.d-card
                                              )) no-error.

          end.
        end.
        find current buf_dis-card exclusive-lock .
        assign
        v-first-main-card = buf_dis-card.first-main-card.
        release buf_dis-card .

        for each buf2_dis-card where
                buf2_dis-card.first-main-card =  v-first-main-card
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :

          find buf_dis-card exclusive-lock where buf_dis-card.d-card = buf2_dis-card.d-card.
          release buf_dis-card .
        end.
        /* проверяем целостность ДК?
            сумма по dis-obj совпадает с dis-host
        */

        /* проверяем целостность ДК?
            сумма по dis-host совпадает с dis-host где host-code = 0
        */

      end. /* for each buf_doc-line */
    end. /*when TDEDT_Ras_Vnesh_Kass*/
    when {&table_trn-doc} then do:
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
        no-error .
      if not available buf_trn-doc then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найден документ" skip
          "Документ" p-doc-code skip
          view-as alert-box error .
        undo main-block, return error .
      end.
      for each buf2_dis-card no-lock where
              buf2_dis-card.d-card = buf_trn-doc.d-card
      on error undo main-block, return error :
        find first buf_dis-card no-lock where buf_Dis-card.d-card = buf2_dis-card.d-card no-error.
        if not available buf_Dis-card then do:
          undo main-block, return error substitute ("&1 &2 &3&4Не найдена ДК из шапки документа&4Документ &5&4"
                                                    ,vss-workfile
                                                    ,vss-revision
                                                    ,vss-description
                                                    ,{&new-line}
                                                    ,buf_trn-doc.doc-code
                                                    ).
        end.
        v-first-main-card = buf_dis-card.first-main-card.
        for each buf3_dis-card where
                buf3_dis-card.first-main-card =  v-first-main-card
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
          find buf_dis-card exclusive-lock where buf_dis-card.d-card = buf3_dis-card.d-card.
          release buf_dis-card .
        end.
      end.
    end.
    when {&table_dis-card-type} then do:
      run gen-row-keyr in this-procedure
        ( input p-doc-code
         ,input ?
         ,input "ub"
         ,input ?
         ,input NO-LOCK
         ,output v-tbl-row
         ,output v-tbl-name
        ) no-error.
      find first buf_Dis-card-type no-lock where
                rowid(buf_dis-card-type) = v-tbl-row no-error.
      if not available buf_dis-card-type then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найден ТИП ДК" p-doc-code skip
          view-as alert-box error .
        undo main-block, return error .
      end. /*if not available buf_dis-card-type then do:*/
      _dis-card:
      for each buf2_dis-card no-lock where
              buf2_dis-card.type              = buf_dis-card-type.type
          and buf2_dis-card.emitent-host-code = buf_dis-card-type.emitent-host-code
          and buf2_dis-card.d-card            > p-d-card
      on error undo main-block, return error
      :
        v-first-main-card = buf2_dis-card.first-main-card.
        find first buf_dis-card no-lock
          where buf_dis-card.d-card = buf2_dis-card.d-card
          no-error .
        if not available buf_Dis-card then do:
          undo main-block, return error substitute ("&1 &2 &3&4Не найдена ДК &5&4Тип &5"
                                                    ,vss-workfile
                                                    ,vss-revision
                                                    ,vss-description
                                                    ,{&new-line}
                                                    ,buf2_Dis-card.d-card
                                                    ,p-doc-code
                                                    ).
        end. /*if not available buf_Dis-card then do:*/
        if v-lock-chr <> '*':U then do:
          run is-to-lock-d-card in p-parent-handle ( input buf_dis-card.d-card, output v-lock-chr ) no-error.
          if v-lock-chr = "*"  then do:
          end.
          else if v-lock-chr = 'no' then do:
            v-lock-chr = '':U.
            next _dis-card.
          end.
        end.
        /* обновить информацию о текущей ДК строке */
        assign
        v-count  = v-count + 1
        .
        if v-count mod 10 = 0 then do:
          if log-file-name <> '':U
          and valid-handle (p-log-handle) then do:
            run show-counter in p-log-handle .
            run write-counter in p-log-handle (substitute("Обработано: &1. Подготовка данных - карта &2"
                                              , v-count
                                              , buf_dis-card.d-card
                                              )) no-error.

          end.
        end. /*if v-count mod 10 = 0 then do:*/
        for each buf3_dis-card no-lock where
                buf3_dis-card.first-main-card = v-first-main-card
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
          find buf_dis-card exclusive-lock where buf_dis-card.d-card = buf3_dis-card.d-card.
          release buf_dis-card .
        end.
        /* проверяем целостность ДК?
            сумма по dis-obj совпадает с dis-host
        */

        /* проверяем целостность ДК?
            сумма по dis-host совпадает с dis-host где host-code = 0
        */
        if v-count = 100 then do:
          p-num-dc = v-count.
          return.
        end.
      end. /* for each buf2_dis-card no-lock where*/
      p-num-dc = v-count.
    end. /*when {&tabel_dis-card-type}*/
    when {&table_dis-card} then do:
      find first buf_Dis-card no-lock where
               buf_dis-card.d-card = p-doc-code no-error.
      if not available buf_dis-card then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найдена ДК" p-doc-code skip
          view-as alert-box error .
        undo main-block, return error .
      end. /*if not available buf_dis-card-type then do:*/
      v-first-main-card = buf_dis-card.first-main-card.
      _dis-card:
      for each buf2_dis-card no-lock where
            buf2_dis-card.first-main-card      = v-first-main-card
      on error undo main-block, return error
      :
        find first buf_dis-card exclusive-lock where buf_dis-card.d-card = buf2_dis-card.d-card.
        release buf_dis-card .

        /* проверяем целостность ДК?
            сумма по dis-obj совпадает с dis-host
        */

        /* проверяем целостность ДК?
            сумма по dis-host совпадает с dis-host где host-code = 0
        */

      end. /* for each buf2_dis-card no-lock where*/
    end. /*when {&tabel_dis-card-type}*/
    when {&table_payment} then do:
      find first buf_payment no-lock
        where buf_payment.pmnt-code = p-doc-code
        no-error .
      if not available buf_payment then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найден платеж по ДК" skip
          "Документ" p-doc-code skip
          view-as alert-box error .
        undo main-block, return error .
      end.
      for each buf2_dis-card no-lock where
              buf2_dis-card.d-card = buf_payment.d-card
      on error undo main-block, return error :
        find first buf_dis-card no-lock where buf_Dis-card.d-card = buf2_dis-card.d-card no-error.
        if not available buf_Dis-card then do:
          undo main-block, return error substitute ("&1 &2 &3&4Не найдена ДК из шапки платежа&4Документ &5&4"
                                                    ,vss-workfile
                                                    ,vss-revision
                                                    ,vss-description
                                                    ,{&new-line}
                                                    ,buf_payment.pmnt-code
                                                    ).
        end.
        v-first-main-card = buf_dis-card.first-main-card.
        for each buf3_dis-card where
                buf3_dis-card.first-main-card =  v-first-main-card
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
          find buf_dis-card exclusive-lock where buf_dis-card.d-card = buf3_dis-card.d-card.
          release buf_dis-card .
        end.
      end.
    end.
    when {&table_fin-doc} then do:
      find first buf_fin-doc no-lock
        where buf_fin-doc.fin-doc-code = integer(p-doc-code)
        no-error .
      if not available buf_fin-doc then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найден платеж"  p-doc-code skip
          view-as alert-box error .
        undo main-block, return error .
      end.

      for each buf_payment no-lock where
              buf_payment.source-type = {&pmnt-fin-doc}
          and buf_payment.source-ref = string(buf_fin-doc.fin-doc-code)
          and buf_payment.d-card > '':U
      on error undo main-block, return error
      :
        find first buf_dis-card no-lock
          where buf_dis-card.d-card = buf_payment.d-card
          no-error .
        if not available buf_Dis-card then do:
          undo main-block, return error substitute ("&1 &2 &3&4Не найдена ДК&4Платеж &5&4Платеж на ДК &6"
                                                    ,vss-workfile
                                                    ,vss-revision
                                                    ,vss-description
                                                    ,{&new-line}
                                                    ,buf_fin-doc.fin-doc-code
                                                    ,buf_payment.pmnt-code).
        end.
        /* обновить информацию о текущей ДК строке */
        assign
        v-count  = v-count + 1
        .
        if v-count mod 10 = 0 then do:
          if log-file-name <> '':U
          and valid-handle (p-log-handle) then do:
            run show-counter in p-log-handle .
            run write-counter in p-log-handle (substitute("Обработано: &1. Подготовка данных - карта &2"
                                              , v-count
                                              , buf_dis-card.d-card
                                              )) no-error.

          end.
        end.
        find current buf_dis-card exclusive-lock .
        assign
        v-first-main-card = buf_dis-card.first-main-card
        v-d-card = buf_dis-card.d-card
        .
        release buf_dis-card .

        for each buf2_dis-card where
                buf2_dis-card.first-main-card =  v-first-main-card
        on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
        on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
        :
          if buf2_dis-card.d-card <> v-d-card then do:
            v-count = v-count + 1.
          end.
          find buf_dis-card exclusive-lock where buf_dis-card.d-card = buf2_dis-card.d-card.
          release buf_dis-card .
        end.
        /* проверяем целостность ДК?
            сумма по dis-obj совпадает с dis-host
        */

        /* проверяем целостность ДК?
            сумма по dis-host совпадает с dis-host где host-code = 0
        */

      end. /* for each buf_payment */
      p-num-dc = v-count.
    end. /*when {&table_fin-doc}*/
  END CASE.
end. /* transaction */