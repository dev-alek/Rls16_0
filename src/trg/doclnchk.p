block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка целостности строки документа

Автор: Чернова Светлана Александровна
Дата создания: 09/24/07
Author: Svetlana Chernova
Creation date: 09/24/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/11/06

Может вызываться из интерфейса системы для незакрытых документов

*/

define input parameter p-doc-code  like ub.doc-line.doc-code  no-undo .
define input parameter p-artic     like ub.doc-line.artic     no-undo .
define input parameter p-prod-type like ub.doc-line.prod-type no-undo .
define input parameter p-prod-code like ub.doc-line.prod-code no-undo .
define input parameter l-check-cli-qnty as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка целостности строки документа".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ trg/partrqst.i }

define variable v-total-gds-dtl-doc-qnty  like ub.gds-dtl.doc-qnty  no-undo .
define variable v-total-gds-dtl-fact-qnty like ub.gds-dtl.fact-qnty no-undo .

do
on error undo, return error
:

  find first ub.doc-line no-lock
    where ub.doc-line.doc-code  = p-doc-code
      and ub.doc-line.artic     = p-artic
      and ub.doc-line.prod-type = p-prod-type
      and ub.doc-line.prod-code = p-prod-code
    no-error .
  if not available ub.doc-line then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена строка документа" skip
      "Документ" p-doc-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      view-as alert-box error .
    undo, return error .
  end.

  find first ub.trn-doc no-lock
    where ub.trn-doc.doc-code = ub.doc-line.doc-code
    no-error .
  if not available ub.trn-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найден документ" skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error .
  end.

  define variable v-obj-type like ub.doc-line.obj-type no-undo .
  define variable v-obj-code like ub.doc-line.obj-code no-undo .

  assign
    v-obj-type = ub.doc-line.obj-type
    v-obj-code = ub.doc-line.obj-code
  .

  assign
    v-total-gds-dtl-doc-qnty  = 0
    v-total-gds-dtl-fact-qnty = 0
  .

  for each gds-dtl no-lock
    where gds-dtl.doc-code  = p-doc-code
      and gds-dtl.artic     = p-artic
      and gds-dtl.prod-type = p-prod-type
      and gds-dtl.prod-code = p-prod-code
  :
    assign
      v-total-gds-dtl-doc-qnty  = v-total-gds-dtl-doc-qnty  + ub.gds-dtl.doc-qnty
      v-total-gds-dtl-fact-qnty = v-total-gds-dtl-fact-qnty + ub.gds-dtl.fact-qnty
    .
  end.


  &scop partrqst-prefix v-total-parts-
  {&partrqst-var}

  run partrqst in this-procedure
    (input  p-doc-code               /* p-doc-code               */
    ,input  v-obj-type               /* p-obj-type               */
    ,input  v-obj-code               /* p-obj-code               */
    ,input  p-artic                  /* p-artic                  */
    ,input  p-prod-type              /* p-prod-type              */
    ,input  p-prod-code              /* p-prod-code              */
    &scop partrqst-prefix v-total-parts-
    {&partrqst-param}
    ).

  if ub.trn-doc.doc-type <> {&inventory} then do:
    if v-total-parts-qnty <> v-total-gds-dtl-doc-qnty
    then do:
      message
        "Количество по всем партиям не сооветствует количеству по всем признакам" skip
        "Документ" p-doc-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Количество по всем партиям:" v-total-parts-qnty skip
        "Количества по всем признакам:" v-total-gds-dtl-doc-qnty skip
        view-as alert-box .
      undo, return error .
    end.
  end.


  if ub.trn-doc.doc-type <> {&inventory} then do:
    if ub.trn-doc.status_ <> {&cash-desk} then do:
      /* для всех документов, кроме не закрытой продажи в магазине */
      if v-total-parts-fact-qnty <> v-total-gds-dtl-fact-qnty
      then do:
        message
          "Фактическое количество по всем партиям не сооветствует" skip
          "фактическому количеству по всем признакам" skip
          "Документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Фактическое количество по всем партиям:" v-total-parts-fact-qnty skip
          "Фактическое количества по всем признакам:" v-total-gds-dtl-fact-qnty skip
          view-as alert-box .
        undo, return error .
      end.
    end.
  end.


  if l-check-cli-qnty then do:
    /* проверяем количество по ТТН в случае завершения завершения заведения всех признаков */
    if v-total-parts-qnty = doc-line.doc-qnty then do:
      if v-total-parts-cli-qnty <> ub.doc-line.cli-qnty then do:
        message
          "Количество по ТТН по всем партиям не сооветствует" skip
          "количеству по ТТН накладной" skip
          "Документ" p-doc-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Количество по ТТН по всем партиям:" v-total-parts-cli-qnty skip
          "Количество по ТТН накладной:" ub.doc-line.cli-qnty skip
          view-as alert-box .
        undo, return error .
      end.
    end.
  end.
end.