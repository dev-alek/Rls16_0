block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление документа

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/

TRIGGER PROCEDURE FOR DELETE OF ub.trn-doc .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Триггер на удаление документа".

{ cmp/vssrevis.i "substitute('&1|&2', ub.trn-doc.doc-code, ub.trn-doc.status_) " }
{ cmp/trg-def.i }

{ gbl/objsrv.i }
   
define variable v-message as character no-undo .
define buffer bufz_trn-doc for ub.trn-doc.

main-block :
do transaction
on error  undo main-block, return error substitute("&1. error main-block. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on endkey undo main-block, return error substitute("&1. endkey main-block")
on stop   undo main-block, return error substitute("&1. stop main-block")
:
  /* Переведем запросы в статусе ГОТОВ в статус ОТКАЗ */
  for each bufz_trn-doc exclusive-lock where
           bufz_trn-doc.doc-code = ub.trn-doc.out-code and
           bufz_trn-doc.status_  = {&ready}            :
      assign
        bufz_trn-doc.status_ = {&rejected}
      .
  end.

  /* документ, закрытый до статуса факт, можно удалить только в том случае, если он был предварительно помечен */
  /* это дополнительная страховка от ошибочного удаления документа */
  if ub.trn-doc.status_ =  {&fact} and
     ub.trn-doc.is-del  <> yes     then do:
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Нельзя удалять документ, закрытый до статуса" {&fact} skip
            "Документ" ub.trn-doc.doc-code skip
            "Статус документа" ub.trn-doc.status_ skip
    view-as alert-box error .
    undo main-block, return error "Нельзя удалять документ, закрытый до статуса" + {&fact}.
  end.

  /* удаляем строки документа */
  /* при этом в триггере на удаление строки документа удаляется ряд подчиненных таблиц */
  for each ub.doc-line where
           ub.doc-line.doc-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    delete ub.doc-line .
  end.
  for each ub.inv-line where
           ub.inv-line.doc-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    message
      vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
      "Найдены записи о нарастающем итоге без основной записи о товаре." skip
      "Документ" ub.trn-doc.doc-code skip
      substitute( "Товар &1 &2 &3", ub.inv-line.artic, ub.inv-line.prod-type, ub.inv-line.prod-code ) skip
      "Удаление невозможно." skip
      view-as alert-box error buttons ok .
    undo main-block, return error "Найдены записи о распределении товара по местам хранени . Удаление невозможно.".
  end.
  for each ub.doc-pl
    where ub.doc-pl.out-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    message
      vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
      "Найдены записи о распределении товара по местам хранения без основной записи о товаре.." skip
      "Документ" ub.trn-doc.doc-code skip
      "Код товара" ub.doc-pl.gds-code skip
      "Удаление невозможно." skip
      view-as alert-box error buttons ok .
    undo main-block, return error "Найдены записи о распределении товара по местам хранени . Удаление невозможно.".
  end.

  /* проверим, что не осталось "зависших" резервов */
  /* все партии должны были удалиться в триггере на удаление строки документа */
  for each ub.parts no-lock where
           ub.parts.out-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Найдены не снятые резервы по документу." skip
            "Документ" ub.trn-doc.doc-code skip
            "Артикул" ub.parts.artic ub.parts.prod-type ub.parts.prod-code skip
            "Удаление невозможно." skip
    view-as alert-box error buttons ok .
    undo main-block, return error "Найдены не снятые резервы по документу. Удаление невозможно.".
  end.

  for each ub.parts-root no-lock where
           ub.parts-root.doc-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Найдены не снятые резервы по документу." skip
            "Документ" ub.trn-doc.doc-code skip
            "Код товара" ub.parts-root.gds-code skip
            "Удаление невозможно." skip
    view-as alert-box error buttons ok .
    undo main-block, return error "Найдены не снятые резервы по документу. Удаление невозможно.".
  end.

  for each ub.parts-attr no-lock where
           ub.parts-attr.in-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    message vss-workfile skip vss-date skip vss-revision skip( 1 ) vss-description skip( 1 )
            "Найдены атрибуты партии." skip
            "Документ" ub.trn-doc.doc-code skip
            "Код товара" ub.parts-attr.gds-code skip
            "Код партии" ub.parts-attr.part-code skip
            "Удаление невозможно." skip
    view-as alert-box error buttons ok .
    undo main-block, return error "Найдены атрибуты партии. Удаление невозможно.".
  end.

  /* удаляем дополнительную информацию по инвентаризации */
  for each ub.inv-doc exclusive-lock where
           ub.inv-doc.doc-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    delete ub.inv-doc.
  end.

  for each ub.marking-attr exclusive-lock where (ub.marking-attr.attr-code = "inv-doc" or ub.marking-attr.attr-code = "inv-doc-scan") and ub.marking-attr.attr-value = ub.trn-doc.doc-code:
    delete ub.marking-attr. 
  end.
  if ub.trn-doc.ext-doc-type = {&TDEDT_Inv}
  then do: 
    find first ub.utd exclusive-lock where ub.utd.doc-code = ub.trn-doc.doc-code no-error.
    if available (ub.utd)
      then delete ub.utd.
  end.
  else do:
    find first ub.utd exclusive-lock where ub.utd.doc-code = ub.trn-doc.doc-code no-error.
    if available (ub.utd)
    then do:
      for each ub.utd-marking-lines where ub.utd-marking-lines.doc-id =  ub.utd.doc-id and ub.utd-marking-lines.db-num = ub.utd.db-num:
        find first ub.marking where ub.marking.mark = ub.utd-marking-lines.mark no-error.
        if not available (ub.marking) or not ub.marking.sts = objSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
          then next.
        ub.marking.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB.
      end.
    end.
  end.
  /* удаляем суммы по документу */
  for each ub.trn-doc-sum exclusive-lock where
           ub.trn-doc-sum.doc-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    delete ub.trn-doc-sum.
  end.

  /* удаляем документы сверки по накладной */
  for each ub.rvs-doc exclusive-lock where
           ub.rvs-doc.out-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    delete ub.rvs-doc .
  end.

  /* удаляем атрибуты документа */
  for each ub.doc-attr exclusive-lock where
           ub.doc-attr.doc-code = ub.trn-doc.doc-code
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    delete ub.doc-attr.
  end.

  /* при удалении док-та инвентаризации, удаляем дату и время инвентаризации на док-те сверки*/
  if ub.trn-doc.doc-type = {&inventory} then
  do:
    for first ub.inv-doc-attr where
              ub.inv-doc-attr.doc-code = ub.trn-doc.out-code
          and ub.inv-doc-attr.attr-code = "create_date"
    on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
    :
      delete ub.inv-doc-attr.
    end.
    for first ub.inv-doc-attr where
              ub.inv-doc-attr.doc-code = ub.trn-doc.out-code
          and ub.inv-doc-attr.attr-code = "create_time"
    on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value ) 
    :
      delete ub.inv-doc-attr.
    end.
  end.

/* Удаление связок от с накладными */
/*
  for each ub.ord-chain
    where ub.ord-chain.doc-code = ub.trn-doc.doc-code and
          ub.ord-chain.doc-type = 'trn'
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    delete ub.ord-chain .
  end.

  for each ub.ord-chain
    where ub.ord-chain.rel-doc-code = ub.trn-doc.doc-code and
          ub.ord-chain.rel-doc-type = 'trn'
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    delete ub.ord-chain.
  end.
 */

  /* помечаем связи с финобязательствами и предфинобязательствами как удаленные.
     делаем это в триггере. так как должно срабатывать в офисе по приходу новостей на удаление документа из удаленок. */
  for each ub.fin-ob where ub.fin-ob.host-code    = ub.trn-doc.host-code and
                           ub.fin-ob.trn-doc-code = ub.trn-doc.doc-code  exclusive-lock
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    assign
      ub.fin-ob.is-doc-del = yes.
  end.
  for each ub.fin-ob-trn where ub.fin-ob-trn.trn-doc-code = ub.trn-doc.doc-code  and
                               ub.fin-ob-trn.host-code    = ub.trn-doc.host-code exclusive-lock
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    find first ub.fin-ob where ub.fin-ob.host-code = ub.fin-ob-trn.host-code and
                               ub.fin-ob.doc-code  = ub.fin-ob-trn.doc-code  exclusive-lock no-error.
    if available ub.fin-ob then do:
      assign
        ub.fin-ob.is-doc-del = yes.
    end.
    assign
      ub.fin-ob-trn.is-doc-del = yes.
  end.
  for each ub.fin-gds-part where ub.fin-gds-part.obj-type = ub.trn-doc.obj-type and
                                 ub.fin-gds-part.obj-code = ub.trn-doc.obj-code and
                                 ub.fin-gds-part.out-code = ub.trn-doc.doc-code exclusive-lock
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    find first ub.fin-ob where ub.fin-ob.host-code = ub.fin-gds-part.host-code   and
                               ub.fin-ob.doc-code  = ub.fin-gds-part.fin-ob-code exclusive-lock no-error.
    if available ub.fin-ob then do:
      assign
        ub.fin-ob.is-doc-del = yes.
    end.
    assign
      ub.fin-gds-part.is-doc-del = yes.
  end.
  for each ub.fin-ob-before where ub.fin-ob-before.host-code         = ub.trn-doc.host-code and
                                  ub.fin-ob-before.trn-doc-code-orig = ub.trn-doc.doc-code  exclusive-lock
  on error undo main-block, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
  :
    find first ub.fin-ob where ub.fin-ob.host-code = ub.fin-ob-before.host-code and
                               ub.fin-ob.doc-code  = ub.fin-ob-before.doc-code  exclusive-lock no-error.
    if available ub.fin-ob then do:
      assign
        ub.fin-ob.is-doc-del = yes.
    end.
    assign
      ub.fin-ob-before.is-doc-del = yes.
  end.
  /* Если мы работаем в главной БД, то:
    1) мы приняли по новостям команду на удаление.
    2) это документ нашей БД и его нет в других БД.
    3) это документ для удаленки, но в начальном статусе и его нет в удаленке.
    Исключение - запрос на внутренний приход. */
  /* отправляем команду по новостям */
  if g#db-num <> 0
     or ( ub.trn-doc.status_ = {&inquiry}
          and ub.trn-doc.ext-doc-type = {&TDEDT_Pri_Perem}
        )
  then do:
    run nws/cmd-del.p
      ( input "trn-doc":U
      , input ( buffer ub.trn-doc :handle )
      , input "":U
      ) no-error .
    if error-status :error then do:
      return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.
  if g#oxml = yes
  then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_trn-doc}
        , input ( buffer ub.trn-doc:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
  end.
end.