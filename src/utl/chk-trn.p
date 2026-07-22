block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chk-trn.p $
$Archive: utl/chk-trn.p $

Поиск приходов, по которым были сформированы автоматические переоценки с неправильным fact-num

Автор: Чернова Светлана Александровна
Дата создания: 05/08/07
Author: Svetlana Chernova
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 03/21/01


*/

define input parameter p-install as logical no-undo init no .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chk-trn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/chk-trn.p $":U .
define variable vss-description as character no-undo init "Поиск приходов, по которым были сформированы автоматические переоценки с неправильным fact-num".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }

define variable l-fix-documents         as logical          no-undo .
define variable l-log-fact-num-change   as logical          no-undo .

define variable i-err-count             as integer  init 0  no-undo .

define variable v-today                 as date             no-undo.
define variable v-time                  as integer          no-undo.


if p-install = false then do:
  assign
    l-fix-documents       = no
    l-log-fact-num-change = true
  .
  message
    vss-description skip
    "Вся информация об ошибках записывается в файл chk-trn.txt." skip
    "Информация о переименованных документах записывается в файл chk-trn.fix." skip
    "да - исправлять найденные документы" skip
    "нет - не исправлять найденные документы" skip
    "отмена - отказаться от поиска" skip
    view-as alert-box buttons yes-no-cancel update l-fix-documents .
  if l-fix-documents = ? then do:
    return . /* --->>>--- */
  end.

  if l-fix-documents = true then do:
    message
      vss-description skip
      "Найденные документы будут изменяться" skip
      "Информация о переименованных документах записывается в файл chk-trn.fix" skip
      "да - информация будет записана в дополнительный файл fctnumch.txt" skip
      "нет - информация не будет записана в дополнительный файл" skip
      "отмена - отказаться от изменения" skip
      view-as alert-box buttons yes-no-cancel update l-log-fact-num-change .
    if l-log-fact-num-change = ? then do:
      return . /* --->>>--- */
    end.
  end.
end.
else do:
  assign
    l-fix-documents       = true
    l-log-fact-num-change = false
  .
end.

for each trn-doc no-lock
  where trn-doc.doc-type = {&income}
    and trn-doc.status_  = {&fact}
    and trn-doc.internal = true
    and trn-doc.discnt-type = {&manufactured}
:
  find first price-doc no-lock
    where ub.price-doc.doc-num = ub.trn-doc.doc-code
    no-error .
  if not available price-doc then do:
    find first ub.price-doc no-lock
      where ub.price-doc.obj-type = ub.trn-doc.obj-type
        and ub.price-doc.obj-code = ub.trn-doc.obj-code
        and ub.price-doc.fact-num = ub.trn-doc.fact-num + 1
      no-error .
  end.

  if available price-doc
  and price-doc.PS   = "@  Переоценка по приходу. Продажные цены устанавливаются = приходным."
  and price-doc.status_ = {&act-overvalue}
  and price-doc.fact-num > trn-doc.fact-num
  then do:
    define variable l-find-goods as logical no-undo .

    assign
      l-find-goods = false
    .

    for each ub.price-list no-lock
      where ub.price-list.doc-num = ub.price-doc.doc-num
    :
      find first ub.doc-line no-lock
        where ub.doc-line.doc-code  = ub.trn-doc.doc-code
          and ub.doc-line.artic     = ub.price-list.artic
          and ub.doc-line.prod-type = ub.price-list.prod-type
          and ub.doc-line.prod-code = ub.price-list.prod-code
        no-error .
      if available ub.doc-line then do:
        assign
          l-find-goods = true
        .
        leave .
      end.
    end.

    if available price-doc
    and l-find-goods then do:
      assign
        i-err-count = i-err-count + 1
      .

      output to chk-trn.txt append .
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      export
        string(v-today) string(v-time, "hh:mm") trn-doc.doc-code trn-doc.fact-num
        price-doc.doc-num price-doc.fact-num
        .
      output close .

      if l-fix-documents = true then do:
        do transaction
        on error undo, next
        on stop  undo, return
        :
          define variable v-new-trn-doc-fact-num   like ub.trn-doc.fact-num no-undo .
          define variable v-new-price-doc-fact-num like ub.price-doc.fact-num no-undo .

          assign
            v-new-trn-doc-fact-num   = ub.price-doc.fact-num
            v-new-price-doc-fact-num = ub.trn-doc.fact-num
          .

          output to chk-trn.fix append .
          run cur-time in this-procedure ( output v-today
                                         , output v-time
                                         ).
          export
            string(v-today) string(v-time, "hh:mm") "trn-doc_old-fact-num_new-fact-num":u
            ub.trn-doc.doc-code ub.trn-doc.fact-num v-new-trn-doc-fact-num
            .
          export
            string(v-today) string(v-time, "hh:mm") "price-doc_old-fact-num_new-fact-num":u
            ub.price-doc.doc-num ub.price-doc.fact-num v-new-price-doc-fact-num
            .
          output close .

          run utl/fctnumch.p
            (input ub.trn-doc.doc-code    /* p-doc-code     */
            ,input {&table_trn-doc}       /* p-doc-type     */
            ,input v-new-trn-doc-fact-num /* p-new-fact-num */
            ,input l-log-fact-num-change  /* p-log-change   */
            ).

          run utl/fctnumch.p
            (input ub.price-doc.doc-num     /* p-doc-code     */
            ,input {&table_price-doc}       /* p-doc-type     */
            ,input v-new-price-doc-fact-num /* p-new-fact-num */
            ,input l-log-fact-num-change    /* p-log-change   */
            ).
        end.
      end.
    end.
  end.
end.

if p-install = false then do:
  if i-err-count <> 0 then do:
    message
      "Просмотр документов и переоценок закончен" skip
      "Найдено" i-err-count "ошибок" skip
      ""
      ( if l-fix-documents
        then "Документы были исправлены"
        else "Документы не были исправлены"
      ) skip
      view-as alert-box error  .

  end.
  else do:
    message
      "Просмотр документов и переоценок закончен" skip
      "Ошибок не найдено" skip
      view-as alert-box information .
  end.
end.