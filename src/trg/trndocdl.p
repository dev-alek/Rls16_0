block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура удаления закрытого документа

Автор: Чернова Светлана Александровна
Дата создания: 05/08/07
Author: Svetlana Chernova
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 06/25/02

Должна вызываться из интерфейса и из новостей

*/
using ibs.th.str.alcohol.*.


define input  parameter p-doc-code like ub.trn-doc.doc-code   no-undo .
define input  parameter p-chip-num like ub.c-trn-doc.chip-num no-undo .

define variable chg-qnty      as   decimal no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Процедура удаления закрытого документа".
{ cmp/vssrevis.i "substitute('&1':u,p-doc-code)" }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/factord.i  }
{ trg/trndocrs.i }
{ trg/trndocgs.i }
{ trg/tdparts.i  }
{ trg/partrqst.i }
{ str/lib-trn.i  }
{ str/hvrdtax.i  }
{ gbl/key-rec.i  }
{ trg/partcopy.i }
{ trg/gdsobjcl.i }
{ str/libtfarh.i }
{ str/lib-rvs.i  }
{ str/trdcalib.i }

do
on error undo, return error return-value
:
  define buffer buf_trn-doc   for ub.trn-doc .
  define buffer buf_doc-line  for ub.doc-line .
  define buffer buf_parts     for ub.parts .
  define buffer buf_price-doc for ub.price-doc.
  define buffer buf_rvs-doc   for ub.rvs-doc .
  define buffer buf_gen-attr  for ub.gen-attr .
  define buffer buf_marking-lines for ub.marking-lines .
  define buffer free_marking-lines for ub.marking-lines .
  define buffer buf_marking   for ub.marking .
  
  define variable v-root-node         like ub.gds-prt.node-code no-undo .

  define variable v-ind-goods            as integer   no-undo .
  define variable v-start-time           as int64     no-undo .
  define variable v-current-time         as character no-undo .
  define variable v-current-action         as character no-undo .
  define variable v-description-doc-type as character no-undo .
  define variable v-doc-line-artic       like ub.doc-line.artic no-undo .
  
  define variable part-key-rec as character no-undo .
  define variable part-key-rec_free as character no-undo .
  define variable part-key-rec_out as character no-undo .

  /* для показа процесса закрытия документа */
  define frame a
    buf_trn-doc.doc-code                       label "Документ" skip
    v-description-doc-type                     label "Тип документа" skip
    v-current-action         format "x(40)"      no-label skip
    v-ind-goods            format ">>>>>>>9"   label "Обработано артикулов" skip
    v-doc-line-artic                           label "Текущий артикул" skip
    v-current-time         format "x(8)"       label "Время" skip
    with view-as dialog-box side-labels three-d
    title "Удаление документа"
    .

  find first buf_trn-doc exclusive-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc
  then do:
    undo, return error substitute( "&1. Ошибка задания входных параметров.&2"
                                    + "Не найден документ &3&2"
                                    ,vss-workfile
                                    ,{&new-line}
                                    ,p-doc-code
                                  ).
  end.

  view frame a.
  display
    buf_trn-doc.doc-code
    v-description-doc-type
    with frame a.

  assign
    v-start-time = etime
  .
  assign
    v-description-doc-type = buf_trn-doc.doc-type
                          + " " + string(buf_trn-doc.internal, "внут/внеш")
  .

  if buf_trn-doc.status_ <> {&fact}
  or buf_trn-doc.is-del  <> true
  then do:
    undo, return error substitute( "&1. Данная программа может удалить только помеченные закрытые документы.&2"
                                    + "Документ &3&2"
                                    + "Статус &4&2"
                                    + "Отметка &5&2"
                                    ,vss-workfile
                                    ,{&new-line}
                                    ,p-doc-code
                                    ,buf_trn-doc.status_
                                    ,buf_trn-doc.is-del
                                  ).
  end.

  if buf_trn-doc.status_ = {&fact}
  then do:
    run show-action in this-procedure
      (input "Блокировка товаров на объекте"
      ).

    run trg/lock-gds.p
      (input buf_trn-doc.doc-code            /* v-trn-doc-doc-code          */
      ,input true                            /* p-check-inv                 */
      ,input no                              /* p-check-inv-rasr-minus      */
      ,input (if buf_trn-doc.is-back-date = yes   /* p-document-fact-order  */
            then 0
            else buf_trn-doc.fact-order)
      ,input 0                               /* p-document-fact-order-price */
      ,input (buf_trn-doc.status_ = {&fact}) /* p-fact-close                */
      ,input g#news                          /* p-is-news                   */
      ) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Не удалось наложить блокировку на все товары принадлежащие документу.&2"
                                      + "Логический номер документа &3&2&4&2&5&2"
                                      ,vss-workfile
                                      ,{&new-line}
                                      ,buf_trn-doc.fact-order
                                      ,error-status :get-message(1)
                                      ,return-value
                                    ).
    end.

    run show-action in this-procedure
      (input "Регистрация удаления документа"
      ).

    run trg/markdoc.p
      (input buf_trn-doc.doc-code /* p-doc-code */
      ,input 'doc-delete':u       /* p-action   */
      ) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Не удалось зарегистрировать удаление документа.&2"
                                      + "Логический номер документа &3&2&4&2&5&2"
                                      ,vss-workfile
                                      ,{&new-line}
                                      ,buf_trn-doc.fact-order
                                      ,error-status :get-message(1)
                                      ,return-value
                                    ).
    end.
    if buf_trn-doc.status_ = {&fact} then do:
      { gbl/rum-runa.i
        ?
        this-procedure:handle
        ?
          {&edoc-proc_event_trn-doc}
        " buffer buf_trn-doc:handle "
        ?
        ''
        ''
        no-error
        }
      if error-status:error
      then do:
        define variable v-message as character no-undo .
        v-message = substitute("&1 &2 &3&4Ошибка при вызове процедуры rum-runa.i&4&5&4&5&6"
                                ,vss-workfile
                                ,vss-revision
                                ,vss-description
                                ,{&new-line}
                                , error-status:get-message(1)
                                , return-value ).
        if not g#news
        and not g#auto
        and not g#esys
        then do:
          message
          v-message
          view-as alert-box error .
        end.
        undo,  return error v-message.
      end.
    end.
    run show-action in this-procedure
      (input "Удаление сверок связанных с документом"
      ).
    for each buf_rvs-doc exclusive-lock
      where buf_rvs-doc.out-code = buf_trn-doc.doc-code
    on error undo, return error return-value
    :
      { str/hstc-rvs.i
        "buffer buf_rvs-doc"
        integer({&hn-delete})
        buf_trn-doc.doc-code
        p-chip-num
        no-error
      }
      if error-status :error then do:
        undo, return error return-value.
      end.
      assign
        buf_rvs-doc.is-del = yes
      .
      delete buf_rvs-doc.
    end.

    /* обновляем информацию о товаре */
    run show-action in this-procedure
      (input "Удаление финансовых архивов по документу"
      ).
    { str/datrncnt.i buf_trn-doc.doc-code }

    run show-action in this-procedure
      (input "Удаление строк документа"
      ).

    /* удаление всех строк документа */
    for each buf_doc-line
      where buf_doc-line.doc-code = buf_trn-doc.doc-code
    on error undo, return error
    :
      assign
        v-ind-goods = v-ind-goods + 1
      .
      if v-ind-goods mod 10 = 0
      then do:
        assign
          v-current-time = string(integer(truncate((etime - v-start-time) / 1000, 0)), 'HH:MM:SS':U)
        .
        assign
          v-doc-line-artic = buf_doc-line.artic
        .
        display
          v-ind-goods v-doc-line-artic v-current-time v-current-action
          with frame a.
      end.

      /* определяется корень шкалы товара */
      { gbl/rootnode.i
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        v-root-node
        no-error
      }
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при определении корневого признака товара.&2"
                                       + "Товар &3 &4 &5&2"
                                       + "Логический номер документа &6&2&7&2&8&2"
                                       ,vss-workfile
                                       ,{&new-line}
                                       ,buf_doc-line.artic
                                       ,buf_doc-line.prod-type
                                       ,buf_doc-line.prod-code
                                       ,buf_doc-line.fact-order
                                       ,error-status :get-message(1)
                                       ,return-value
                                      ).
      end.

      /* проверяем целостность товара */
      { gbl/gdscheck.i
        buf_doc-line.obj-type
        buf_doc-line.obj-code
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        v-root-node
        "''"
        no-error
      }
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при проверке целостности товара.&2"
                                       + "Товар &3 &4 &5&2"
                                       + "Логический номер документа &6&2&7&2&8&2"
                                       ,vss-workfile
                                       ,{&new-line}
                                       ,buf_doc-line.artic
                                       ,buf_doc-line.prod-type
                                       ,buf_doc-line.prod-code
                                       ,buf_doc-line.fact-order
                                       ,error-status :get-message(1)
                                       ,return-value
                                      ).
      end.

      /* обработка партий */
      run partcopy-update-parts-delete in this-procedure
        (input buf_doc-line.doc-code  /* p-doc-code  */
        ,input buf_doc-line.obj-type  /* p-obj-type  */
        ,input buf_doc-line.obj-code  /* p-obj-code  */
        ,input buf_doc-line.artic     /* p-artic     */
        ,input buf_doc-line.prod-type /* p-prod-type */
        ,input buf_doc-line.prod-code /* p-prod-code */
        ) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при обработке партий.&2"
                                       + "Товар &3 &4 &5&2"
                                       + "Логический номер документа &6&2&7&2&8&2"
                                       ,vss-workfile
                                       ,{&new-line}
                                       ,buf_doc-line.artic
                                       ,buf_doc-line.prod-type
                                       ,buf_doc-line.prod-code
                                       ,buf_doc-line.fact-order
                                       ,error-status :get-message(1)
                                       ,return-value
                                      ).
      end.

      run trndocgs in this-procedure
        (input buf_doc-line.doc-code  /* p-doc-code      */
        ,input buf_doc-line.artic     /* p-artic         */
        ,input buf_doc-line.prod-type /* p-prod-type     */
        ,input buf_doc-line.prod-code /* p-prod-code     */
        ,input v-root-node            /* p-root-node     */
        ,input false                  /* p-news          */
        ,input false                  /* p-trn-doc-close */
        ,input true                   /* p-update-host   */
        ) no-error .
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при обработке архивов по строке.&2"
                                       + "Товар &3 &4 &5&2"
                                       + "Логический номер документа &6&2&7&2&8&2"
                                       ,vss-workfile
                                       ,{&new-line}
                                       ,buf_doc-line.artic
                                       ,buf_doc-line.prod-type
                                       ,buf_doc-line.prod-code
                                       ,buf_doc-line.fact-order
                                       ,error-status :get-message(1)
                                       ,return-value
                                      ).
      end.

      /* пересчет последующих топливных документов и сверок */
      /* не топливные товары игнорирует (не тратит на них время) и пересчитывает только если статус факт */
      { str/reclcptr.i
        ?
        "(buffer buf_doc-line :handle)"
        -1.0
        buf_doc-line.ext-doc-type
        p-chip-num
        no-error
      }
      if error-status :error then do:
        undo, return error substitute( "&1. Ошибка при пересчете сверок и нарастающего итога.&2"
                                       + "Товар &3 &4 &5&2&6&2"
                                       ,vss-workfile
                                       ,{&new-line}
                                       ,buf_doc-line.artic
                                       ,buf_doc-line.prod-type
                                       ,buf_doc-line.prod-code
                                       ,return-value
                                     ).
      end.

      /* проверяем целостность товара */
      { gbl/gdscheck.i
        buf_doc-line.obj-type
        buf_doc-line.obj-code
        buf_doc-line.artic
        buf_doc-line.prod-type
        buf_doc-line.prod-code
        v-root-node
        "''"
        no-error
      }
      if error-status :error
      then do:
        undo, return error substitute( "&1. Ошибка при проверке целостности товара.&2"
                                       + "Товар &3 &4 &5&2"
                                       + "Логический номер документа &6&2&7&2&8&2"
                                       ,vss-workfile
                                       ,{&new-line}
                                       ,buf_doc-line.artic
                                       ,buf_doc-line.prod-type
                                       ,buf_doc-line.prod-code
                                       ,buf_doc-line.fact-order
                                       ,error-status :get-message(1)
                                       ,return-value
                                      ).
      end.
    end.

    run show-action in this-procedure
      (input "Обновление остатков по поставщику на фирме"
      ).
    run trg/trn-supp.p
      (input  buf_trn-doc.doc-code /* p-doc-code      */
      ,input  false                /* p-trn-doc-close */
      ,input  true                 /* p-update-supp   */
      ,input  false                /* p-update-chk-doc */
      ) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Ошибка при обновлении остатков по поставщику на фирме.&2"
                                      + "Логический номер документа &3&2"
                                      + "Расширенный тип документа &4&2&5&2&6&2"
                                      ,vss-workfile
                                      ,{&new-line}
                                      ,buf_trn-doc.fact-order
                                      ,buf_trn-doc.ext-doc-type
                                      ,error-status :get-message(1)
                                      ,return-value
                                    ).
    end.

    /* удаляем архивные партии */
    run show-action in this-procedure
      (input "Удаление архивных партий"
      ).
      
    { gbl/objsrv.i }
    for each buf_parts exclusive-lock
      where buf_parts.out-code = buf_trn-doc.doc-code
    on error undo, return error return-value
    :
      run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                        ,input (buffer buf_parts:handle)
                                        ,output part-key-rec).
      part-key-rec_free = part-key-rec .
      part-key-rec_out = part-key-rec .
      entry(8,part-key-rec_free,{&delim-key}) = {&free-code} .
      entry(8,part-key-rec_out,{&delim-key}) = {&output-code} .
      
      for each ub.gen-attr where ub.gen-attr.table-name = {&excise-mark}
                                     and ub.gen-attr.p-key =  part-key-rec
      on error undo, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
      :
          delete ub.gen-attr.
      end.   
      /*удаление прихода*/
      if buf_trn-doc.doc-type = {&income} then do:
         
      for each ub.gen-attr where ub.gen-attr.table-name = {&excise-mark}
                                     and ub.gen-attr.p-key =  part-key-rec_free
      on error undo, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
      :
          delete ub.gen-attr.
      end.   
          
      end.    
      else do:
         
      for each ub.gen-attr where ub.gen-attr.table-name = {&excise-mark}
                                     and ub.gen-attr.p-key =  part-key-rec_out
      on error undo, return error substitute( "&1&2&3", vss-workfile, {&new-line}, return-value )
      :
                find first buf_gen-attr exclusive-lock where buf_gen-attr.table-name = {&excise-mark}
                    and buf_gen-attr.attr-code = ub.gen-attr.attr-code
                    and num-entries (buf_gen-attr.p-key, {&delim-key}) >= 8
                    and entry(8, buf_gen-attr.p-key, {&delim-key}) = {&free-code}
                    no-error .
                if not available (buf_gen-attr) then do:
                   buffer-copy ub.gen-attr except ub.gen-attr.p-key to buf_gen-attr .
                    assign
                        buf_gen-attr.p-key = part-key-rec_free
                        . 
                end.
          delete ub.gen-attr.
      end.   
          
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
      define variable v-gds-code as integer   no-undo .

      { gbl/gds-code.i
        buf_parts.artic
        buf_parts.prod-type
        buf_parts.prod-code
        v-gds-code
        no-error
      }
   

      for each buf_marking-lines exclusive-lock where buf_marking-lines.gds-code = v-gds-code
                                                  and buf_marking-lines.obj-type = buf_parts.obj-type
                                                  and buf_marking-lines.obj-code = buf_parts.obj-code
                                                  and buf_marking-lines.in-code  = buf_parts.in-code
                                                  and buf_marking-lines.out-code = buf_parts.out-code
                                                  and buf_marking-lines.part-code = buf_parts.part-code
                                                  and buf_marking-lines.prt-code = buf_parts.prt-code:
        for first buf_marking exclusive-lock where buf_marking.mark = buf_marking-lines.mark :
          if buf_trn-doc.doc-type = {&income}
          or buf_trn-doc.doc-type = {&return}
          then do :
            
          end .
          else do : 
            find first free_marking-lines no-lock where free_marking-lines.mark       = buf_marking-lines.mark
                                                    and free_marking-lines.gds-code   = buf_marking-lines.gds-code
                                                    and free_marking-lines.obj-type   = buf_marking-lines.obj-type
                                                    and free_marking-lines.obj-code   = buf_marking-lines.obj-code
                                                    and free_marking-lines.in-code    = buf_marking-lines.in-code
                                                    and free_marking-lines.out-code   = {&free-code}
                                                    and free_marking-lines.part-code  = buf_marking-lines.part-code
                                                    and free_marking-lines.prt-code   = buf_marking-lines.prt-code
                                                    no-error .
            if not available free_marking-lines
            then do :
              create free_marking-lines .
              assign
                free_marking-lines.mark       = buf_marking-lines.mark
                free_marking-lines.doc-level  = buf_marking-lines.doc-level
                free_marking-lines.gds-code   = buf_marking-lines.gds-code
                free_marking-lines.obj-type   = buf_marking-lines.obj-type
                free_marking-lines.obj-code   = buf_marking-lines.obj-code
                free_marking-lines.in-code    = buf_marking-lines.in-code
                free_marking-lines.out-code   = {&free-code}
                free_marking-lines.part-code  = buf_marking-lines.part-code
                free_marking-lines.prt-code   = buf_marking-lines.prt-code
              .
            end .
            if not (buf_marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB and available (buf_trn-doc) and buf_trn-doc.ext-doc-type = {&TDEDT_inv})
              then assign buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB .
          end .
        end . 
        delete buf_marking-lines .
      end.

      delete buf_parts .
    end.

    define buffer buf_parts-root for ub.parts-root .
    for each buf_parts-root exclusive-lock
      where buf_parts-root.doc-code = buf_trn-doc.doc-code
    on error undo, return error return-value
    :
      delete buf_parts-root .
    end.

    define buffer buf_parts-attr for ub.parts-attr .
    for each buf_parts-attr exclusive-lock
      where buf_parts-attr.in-code = buf_trn-doc.doc-code
    on error undo, return error return-value
    :
      define buffer buf_goods for ub.goods .
      find first buf_goods no-lock
        where buf_goods.gds-code = buf_parts-attr.gds-code
        no-error .
      if not available buf_goods
      then do:
        undo, return error substitute( "&1. Не найден товар.&2"
                                       + "Код товара &3&2"
                                       + "Логический номер документа &4&2"
                                       + "Расширенный тип документа &5&2"
                                       ,vss-workfile
                                       ,{&new-line}
                                       ,buf_parts-attr.gds-code
                                       ,buf_doc-line.fact-order
                                       ,buf_trn-doc.ext-doc-type
                                      ).
      end.

      if not g#news then for each buf_parts no-lock
        where buf_parts.artic     = buf_goods.artic
          and buf_parts.prod-type = buf_goods.prod-type
          and buf_parts.prod-code = buf_goods.prod-code
          and buf_parts.in-code   = buf_parts-attr.in-code
          and buf_parts.part-code = buf_parts-attr.part-code
      on error undo, return error return-value
      :
        find first buf_price-doc no-lock
          where buf_price-doc.doc-num = buf_parts.out-code
          no-error .
        if available buf_price-doc
        then do:
          /* партия временно может участвовать в документах переоценки */
          /* она будет удалена при перерасчёте переоценки */
        end.
        else do:
          undo, return error substitute( "&1. Удаление невозможно.&2Найдены партии для атрибутов.&2"
                                          + "Логический номер документа &3&2"
                                          + "Расширенный тип документа &4&2"
                                          + "Объект партии &5 &6&2"
                                          ,vss-workfile
                                          ,{&new-line}
                                          ,buf_trn-doc.fact-order
                                          ,buf_trn-doc.ext-doc-type
                                          ,buf_parts.obj-type
                                          ,buf_parts.obj-code
                                        )
                           + substitute( "Товар &2&1&3&1&4&1"
                                          + "Резерв &5&2"
                                          + "Партия &6 &7&2"
                                          + "Количество &8&2"
                                          + "Фактическое количество &9&2"
                                          ,{&new-line}
                                          ,buf_parts.artic
                                          ,buf_parts.prod-type
                                          ,buf_parts.prod-code
                                          ,buf_parts.out-code
                                          ,buf_parts.in-code
                                          ,buf_parts.part-code
                                          ,buf_parts.qnty
                                          ,buf_parts.fact-qnty
                                        ).
        end.
      end.

      delete buf_parts-attr .
    end.
  end.
  if buf_trn-doc.ext-doc-type = {&TDEDT_Inv} then do:
     run str/del-invc.p
       ( input buf_trn-doc.doc-code
        ,input buf_trn-doc.obj-type
        ,input buf_trn-doc.obj-code
       ) no-error .
    if error-status :error
    then do:
      undo, return error substitute( "&1. Не удалось удалить чеки по документу инвентаризации.&2"
                                      + "Логический номер документа &3&2"
                                      + "Расширенный тип документа &4&2&5&2&6&2"
                                      ,vss-workfile
                                      ,{&new-line}
                                      ,buf_trn-doc.fact-order
                                      ,buf_trn-doc.ext-doc-type
                                      ,error-status :get-message(1)
                                      ,return-value
                                    ).
    end.
  end.
  if g#news
  and g#db-num = 0
  and (buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} OR
        buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh})
        and buf_trn-doc.d-card       <> ""
        and buf_trn-doc.d-card       <> ?
  then do:
    define variable v-deleted as logical no-undo .
    { str/tdat-del.i
        buf_trn-doc.doc-code
        ~{&trdcattr-need-saledc~}
        v-deleted
        no-error
      }
  end.
  /* Смена статуса документа Вывода из оборота ГИС МТ LK_RECEIPT */
  if g#news
  and g#db-num = 0
  and (buf_trn-doc.ext-doc-type = {&TDEDT_Inv}
    or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Prvo}
    or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh})
  then do :
    define buffer buf_utd for ub.utd .
    for each buf_utd exclusive-lock where buf_utd.doc-code = buf_trn-doc.doc-code :
      case buf_utd.sts :
        when ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_New:KeyIntDB
        or when ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_Signed:KeyIntDB
        then do :
          buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_NewDelete:KeyIntDB .
        end .
        when ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_Sent:KeyIntDB
        or when ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_Error:KeyIntDB
        or when ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_Confirmed:KeyIntDB
        then do :
          buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_SentDelete:KeyIntDB .
        end .
      end case .
    end .
  end .
  
  run show-action in this-procedure
    (input "Документ удален"
    ).
end.


procedure show-action :
  do
  on error undo, return error
  :
    define input parameter p-action as character no-undo .

    assign
      v-current-time = string(integer(truncate((etime - v-start-time) / 1000, 0)), 'HH:MM:SS':U)
      v-current-action = p-action
    .
    display
      v-current-time v-current-action
      with frame a.
  end.
end procedure. /* show-action */