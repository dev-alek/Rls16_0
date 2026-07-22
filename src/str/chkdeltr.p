block-level on error undo, throw.
/*

$Revision: 120a810dadd3, 63, rls $
$Author: ASMorozov $
$Date: Thu Aug 28 16:27:54 2014 +0400 $
$Workfile: chkdeltr.p $
$Archive: str/chkdeltr.p $

Проверка возможности удаления документа, закрытого до статуса {&fact}

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 03/28/05


*/

define input  parameter p-db-num        as integer   no-undo .
define input  parameter p-user-id       as character no-undo .
define input  parameter p-doc-code      as character no-undo .
define input  parameter p-phdoc-code    as character no-undo .
define input  parameter p-file-name-err as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 120a810dadd3, 63, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Aug 28 16:27:54 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkdeltr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chkdeltr.p $":U .
define variable vss-description as character no-undo init "Проверка возможности удаления документа, закрытого до статуса {&fact}".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/waitfram.i }

define variable v-message      as character no-undo .
define variable v-flag-doc-err as logical   no-undo .
define variable v-line-count   as integer   no-undo .
define variable v-start-mjd    as decimal   no-undo .
define variable v-curr-mjd     as decimal   no-undo .
define variable v-diff-mjd     as decimal   no-undo .
define variable l-inv-on       as logical   no-undo .

define buffer del_trn-doc  for ub.trn-doc .
define buffer del_doc-line for ub.doc-line .

do
on error undo, return error return-value
:
  assign
    v-start-mjd = cur-time-mjd()
  .

  find first del_trn-doc exclusive-lock
    where del_trn-doc.doc-code = p-doc-code
    no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if del_trn-doc.status_ <> {&fact}
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Статус документа отличен от статуса" {&fact} skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  run waitfram-show in this-procedure
    (input  substitute ("Удаление документа &1. Блокирование товаров.", p-doc-code)
    ) .

  run trg/lock-gds.p
    (input  del_trn-doc.doc-code   /* p-doc-code                  */
    ,input  true                   /* p-check-inv                 */
    ,input  true                   /* p-check-inv-rasr-minus      */
    ,input (if del_trn-doc.is-back-date = yes   /* p-document-fact-order  */
            then 0
            else del_trn-doc.fact-order)
    ,input  0                      /* p-document-fact-order-price */
    ,input  true                   /* p-fact-close                */
    ,input  false                  /* p-is-news                   */
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.

  assign
    v-flag-doc-err = no
  .
  if search(p-file-name-err) <> ?
  then do:
    os-delete value(p-file-name-err).
  end.
  assign
    v-line-count = 0
  .
  /*Проверяем возможность удаления каждого товара*/
  for each del_doc-line
    where del_doc-line.doc-code = del_trn-doc.doc-code
  on error undo, return error return-value
  :
    assign
      v-line-count = v-line-count + 1
      v-curr-mjd   = cur-time-mjd()
      v-diff-mjd   = v-curr-mjd - v-start-mjd
    .
    if v-line-count modulo 10 = 0
    then do:
      run waitfram-join in this-procedure
        (input substitute ("Проверка на возможность удаления строк документа &1.", p-doc-code)
        ,input substitute ("Обработано строк: &1.", v-line-count)
             + substitute ("Артикул: &1 &2 &3. ", del_doc-line.artic, del_doc-line.prod-type, del_doc-line.prod-code)
        ,input substitute ("Время выполнения: &1.", cur-time-mjd-to-string(v-diff-mjd))
        ,output v-message
        ) .
    end.

    run waitfram-show in this-procedure
      (input v-message
      ) .

    run str/chkdelln.p
      (input  p-db-num
      ,input  p-user-id
      ,input  del_doc-line.obj-type
      ,input  del_doc-line.obj-code
      ,input  del_doc-line.artic
      ,input  del_doc-line.prod-type
      ,input  del_doc-line.prod-code
      ,input  del_doc-line.doc-code
      ,input  p-phdoc-code
      ,input  del_trn-doc.fact-order
      ,input  del_trn-doc.doc-type
      ,input  del_trn-doc.ext-doc-type
      ,input  del_trn-doc.shift-date
      ,input  del_trn-doc.shift-num
      ,input  del_doc-line.fact-qnty
      ,input  p-file-name-err
      ) no-error.
    if error-status :error
    then do:
      if return-value = "CRITICAL"
      then do:
        undo, return error return-value.
      end.

      assign
        v-flag-doc-err = yes
      .
  
    end.

    if del_trn-doc.ext-doc-type = {&TDEDt_Corr_Acc_Price}
    then do:
      { gbl/gdsobjat.i
        del_doc-line.obj-type
        del_doc-line.obj-code
        del_doc-line.artic
        del_doc-line.prod-type
        del_doc-line.prod-code
        "'inv-on=false'"
        l-inv-on
        no-error
      }
      if error-status :error
      then do:
        undo, return error substitute ("Ошибка установки атрибута товара на объекте. Документ: &1 Объект: &2 &3 Артикул: &4 &5 &6 l-inv-on: &7"
                    , del_doc-line.doc-code
                    , del_doc-line.obj-type
                    , del_doc-line.obj-code
                    , del_doc-line.artic
                    , del_doc-line.prod-type
                    , del_doc-line.prod-code
                    , l-inv-on ).
      end.
    end.
  end.

  run waitfram-hide in this-procedure .

  if v-flag-doc-err
  then do:
    undo, return error return-value .
  end.

end.