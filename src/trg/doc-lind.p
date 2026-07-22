block-level on error undo, throw.
/*

$Revision: 117599f024fc, 1538, rls $
$Author: SSlivenko $
$Date: 2018/10/08 16:19:53 $
$Workfile: doc-lind.p $
$Archive: trg/doc-lind.p $

Триггер на удаление строки документа

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/

TRIGGER PROCEDURE FOR DELETE OF ub.doc-line.

define variable vss-revision    as character no-undo initial "$Revision: 117599f024fc, 1538, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2018/10/08 16:19:53 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: doc-lind.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: trg/doc-lind.p $":U .
define variable vss-description as character no-undo initial "Триггер на удаление строки документа".

{ cmp/vssrevis.i "substitute('&1|&2|&3|&4', ub.doc-line.doc-code, ub.doc-line.artic, ub.doc-line.prod-type, ub.doc-line.prod-code) " }
{ cmp/trg-def.i  }
{ str/lib-trn.i  }
{ gbl/key-rec.i  }
{ str/marks.i  }

main-block:
do transaction
on error  undo main-block, return error substitute("&1. error main-block. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on endkey undo main-block, return error substitute("&1. endkey main-block")
on stop   undo main-block, return error substitute("&1. stop main-block")
:
  define variable j-chip-num       as integer no-undo .
  define variable r-doc-line       as recid   no-undo .
  define variable v-after-cli-qnty as decimal   no-undo .
  define variable is-petrol        as logical   no-undo.
  define variable is-pieces        as logical   no-undo.
  define variable part-key-rec     as character no-undo .

  define buffer next_doc-line for ub.doc-line .
  define buffer next_inv-line for ub.inv-line .
  define buffer prev_doc-line for ub.doc-line .
  define buffer prev_inv-line for ub.inv-line .
  find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = ub.doc-line.doc-code and
  ub.inv-doc-attr.attr-code = "isManualError" and
  ub.inv-doc-attr.attr-value = string(true) no-error .
  if not available (ub.inv-doc-attr) then do:
  find ub.goods no-lock
    where ub.goods.artic     = ub.doc-line.artic
      and ub.goods.prod-type = ub.doc-line.prod-type
      and ub.goods.prod-code = ub.doc-line.prod-code
    no-error .
  if not available ub.goods then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при удалении строки накладной" skip
      "Не найден товар" skip
      "Документ" ub.doc-line.doc-code skip
      "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  { str/is-petrl.i
    ub.doc-line.artic
    ub.doc-line.prod-type
    ub.doc-line.prod-code
    is-petrol
    is-pieces
  }
end.
  /* Пытаемся найти документ */
  /* Он уже может быть удален */
  find ub.trn-doc exclusive-lock
    where ub.trn-doc.doc-code = ub.doc-line.doc-code
    no-error.
  if available ub.trn-doc
     and ub.trn-doc.status_ = {&fact}
     and ub.trn-doc.is-del  <> yes
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Нельзя удалять строку документа, закрытую до статуса" {&fact} skip
      "Документ" ub.doc-line.doc-code skip
      "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
      "Статус" ub.doc-line.status_ skip
      view-as alert-box error .
    undo main-block, return error "Нельзя удалять строку документа, закрытую до статуса" + {&fact} .
  end.

  /* партии и бар-коды на них уничтожаются только для внешней ПН,
  для остальных должно быть снятие резервов перед удалением */
  if available ub.trn-doc
  and ub.trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
  then do:
    for each ub.parts exclusive-lock
       where ub.parts.out-code  = ub.doc-line.doc-code
         and ub.parts.obj-type  = ub.doc-line.obj-type
         and ub.parts.obj-code  = ub.doc-line.obj-code
         and ub.parts.artic     = ub.doc-line.artic
         and ub.parts.prod-type = ub.doc-line.prod-type
         and ub.parts.prod-code = ub.doc-line.prod-code
    on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
    :
      for each ub.parts-root where ub.parts-root.doc-code       = ub.parts.out-code
                               and ub.parts-root.orig-in-code   = ub.parts.in-code
                               and ub.parts-root.orig-gds-code  = ub.goods.gds-code
                               and ub.parts-root.orig-part-code = ub.parts.part-code
      on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
      :
         delete ub.parts-root.
      end.
      
      run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                        ,input (buffer ub.parts:handle)
                                        ,output part-key-rec).
      for each ub.gen-attr where ub.gen-attr.table-name = {&excise-mark}
                             and ub.gen-attr.p-key =  part-key-rec
      on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
      :
         delete ub.gen-attr.
      end.
      define variable vsds as class ibs.th.str.mercury.vsdsubs no-undo.
      define variable vsdstr as class ibs.th.gbl.storage.vsdtostorage no-undo.
      define variable ii as integer no-undo.
      vsds = new ibs.th.str.mercury.vsdsubs ().
      vsdstr = new ibs.th.gbl.storage.vsdtostorage ().
      vsds = vsdstr:getVSDsubs(input "part-key", input part-key-rec).
      do ii = 1 to vsds:GetItem(ii):
        vsdstr:deleteDB(vsds:VsdObjCurr).
      end.
      delete object vsds no-error.
      delete object vsdstr no-error.
      delete ub.parts .
    end.
  end.
  else do:
    /* В случае остальных накладных проверим, что не осталось зависших партий по данной линии */
    if can-find (first ub.parts no-lock
      where ub.parts.out-code  = ub.doc-line.doc-code
        and ub.parts.obj-type  = ub.doc-line.obj-type
        and ub.parts.obj-code  = ub.doc-line.obj-code
        and ub.parts.artic     = ub.doc-line.artic
        and ub.parts.prod-type = ub.doc-line.prod-type
        and ub.parts.prod-code = ub.doc-line.prod-code
    )
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Найдены не снятые резервы по линии." skip
        "Удаление невозможно." skip
        "Документ" ub.doc-line.doc-code skip
        "Артикул" ub.doc-line.artic ub.doc-line.prod-type ub.doc-line.prod-code skip
        view-as alert-box error .
      undo main-block, return error "Найдены не снятые резервы по линии. Удаление невозможно." .
    end.
  end.

  /* проверка пересчитан ли нарастающий итог */
  if is-petrol = true
    and is-pieces = false
    and ub.doc-line.status_ = {&fact}
  then do:
    assign
      v-after-cli-qnty = 0.0
    .
    find last prev_doc-line share-lock
      where prev_doc-line.obj-type   = ub.doc-line.obj-type
        and prev_doc-line.obj-code   = ub.doc-line.obj-code
        and prev_doc-line.artic      = ub.doc-line.artic
        and prev_doc-line.prod-code  = ub.doc-line.prod-code
        and prev_doc-line.prod-type  = ub.doc-line.prod-type
        and prev_doc-line.status_    = {&fact}
        and prev_doc-line.fact-order < ub.doc-line.fact-order
      use-index fact-order
      no-error .
    if available prev_doc-line then do:
      find first prev_inv-line share-lock
        where prev_inv-line.doc-code  = prev_doc-line.doc-code
          and prev_inv-line.artic     = prev_doc-line.artic
          and prev_inv-line.prod-code = prev_doc-line.prod-code
          and prev_inv-line.prod-type = prev_doc-line.prod-type
        no-error.
      if available prev_inv-line then do:
        assign
          v-after-cli-qnty = prev_inv-line.after-cli-qnty
        .
      end. /* if available prev_inv-line */
    end.

    find first next_doc-line share-lock
      where next_doc-line.obj-type    = ub.doc-line.obj-type
        and next_doc-line.obj-code    = ub.doc-line.obj-code
        and next_doc-line.artic       = ub.doc-line.artic
        and next_doc-line.prod-code   = ub.doc-line.prod-code
        and next_doc-line.prod-type   = ub.doc-line.prod-type
        and next_doc-line.status_     = {&fact}
        and next_doc-line.fact-order  > ub.doc-line.fact-order
      use-index fact-order
      no-error .
    if available next_doc-line then do:
      find first next_inv-line share-lock
        where next_inv-line.doc-code  = next_doc-line.doc-code
          and next_inv-line.artic     = next_doc-line.artic
          and next_inv-line.prod-code = next_doc-line.prod-code
          and next_inv-line.prod-type = next_doc-line.prod-type
        no-error.
      if available next_inv-line then do:
        if next_inv-line.before-cli-qnty <> v-after-cli-qnty then do:
          undo main-block, return error substitute( "&1. Нарастающий итог по товару &2 не пересчитан при удалении документа &3!"
                                                    ,vss-workfile
                                                    ,ub.goods.gds-code
                                                    ,ub.doc-line.doc-code
                                                  ).
        end.
      end. /* if available next_inv-line */
    end.
  end.

  /* удаляем все признаки по строке */
  for each ub.gds-dtl exclusive-lock
     where ub.gds-dtl.doc-code  = ub.doc-line.doc-code
       and ub.gds-dtl.artic     = ub.doc-line.artic
       and ub.gds-dtl.prod-type = ub.doc-line.prod-type
       and ub.gds-dtl.prod-code = ub.doc-line.prod-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    delete ub.gds-dtl .
  end.

  /* удаляем информацию о резервировании партий по строке */
  for each ub.doc-prts exclusive-lock
     where ub.doc-prts.out-code = ub.trn-doc.doc-code
       and ub.doc-prts.gds-code = ub.goods.gds-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    delete ub.doc-prts .
  end.

  /* удаляем строки, хранящие информацию по инвентаризации */
  for each ub.inv-line exclusive-lock
    where ub.inv-line.doc-code  = ub.doc-line.doc-code
      and ub.inv-line.artic     = ub.doc-line.artic
      and ub.inv-line.prod-type = ub.doc-line.prod-type
      and ub.inv-line.prod-code = ub.doc-line.prod-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    delete ub.inv-line.
  end.

  /* удаляем информацию о резервировании товара по складским местам */
  for each ub.doc-pl exclusive-lock
     where ub.doc-pl.out-code = ub.doc-line.doc-code
       and ub.doc-pl.gds-code = ub.goods.gds-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    delete ub.doc-pl.
  end.

  for each ub.doc-pl-pump exclusive-lock
    where ub.doc-pl-pump.out-code  = ub.doc-line.doc-code
      and ub.doc-pl-pump.gds-code  = ub.goods.gds-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    delete ub.doc-pl-pump.
  end.

  /* удаляем атрибуты строки документа */
  for each ub.doc-line-attr exclusive-lock
     where ub.doc-line-attr.doc-code = ub.doc-line.doc-code
       and ub.doc-line-attr.gds-code = ub.goods.gds-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    delete ub.doc-line-attr .
  end.

  /* Удаляем суммы по строке */
  for each ub.doc-line-sum exclusive-lock
     where ub.doc-line-sum.doc-code = ub.doc-line.doc-code and
           ub.doc-line-sum.gds-code = ub.goods.gds-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    delete ub.doc-line-sum .
  end.

  /* Удаляем оставшиеся связки между партиями */
  for each ub.parts-root exclusive-lock
     where ub.parts-root.doc-code  = ub.doc-line.doc-code
       and ub.parts-root.gds-code  = ub.goods.gds-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    delete ub.parts-root.
  end.

  /* удаляем информацию по произведенным товарам */
  for each ub.doc-fbr-gds exclusive-lock
     where ub.doc-fbr-gds.out-code = ub.doc-line.doc-code
       and ub.doc-fbr-gds.gds-code = ub.goods.gds-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    delete ub.doc-fbr-gds.
  end.

    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_doc-line}
        , input ( buffer ub.doc-line:handle )
    ) no-error.
    if error-status :error
    then do:
        undo main-block, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                                                  , {&new-line}
                                                  , vss-workfile
                                                  , return-value
                                                  , error-status :get-message ( 1 ) ).
    end.
    end.
end. /* main-block */