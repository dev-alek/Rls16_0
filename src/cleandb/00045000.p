block-level on error undo, throw.
/*

Чистка УБД. Переоценка с историей

Автор: Ростовцев Александр
Дата создания: 12/09/2025
Author: Aleksandr Rostovtsev
Creation date: 09/12/25
*/

&scop Tables Переоценка с историей
/*&scop Tables c-price-doc ~*/
/*c-price-list ~            */
/*c-price-list-attr         */

define variable vss-revision    as character no-undo init "$Revision: 36493b7e3299, 155, rls $":U .
define variable vss-author      as character no-undo init "$Author: sibintek-soft $":U .
define variable vss-date        as character no-undo init "$Date: Sep 15 2025 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00045000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cleandb/00045000.p $".
define variable vss-description as character no-undo init "Чистка УБД.".
{ cmp/str-glbl.i }
{ cleandb/defs.i }

define variable v-temp-date     as date no-undo. 
define variable v-doc-num       as character no-undo .
define variable v-fact-order    as decimal no-undo .
define variable find-fact-order as decimal no-undo .
define variable v-qnty        like ub.parts.qnty no-undo .
define variable v-sale-base     as decimal   no-undo .

define buffer price-doc      for ub.price-doc.
define buffer buf_price-doc  for ub.price-doc.
define buffer buf_price-list for ub.price-list.

define temp-table tt-price-list like ub.price-list.

on delete of ub.price-doc  override do: end.
on write  of ub.price-doc  override do: end.
on write  of ub.price-list override do: end.

assign
  v-temp-date     = vardate-actual-docs - 1
  v-fact-order    =  integer(v-temp-date) + 0.97 + 2 * 0.0000000001
  find-fact-order =  integer(v-temp-date) + 0.99
.

for each buf_clients no-lock where
         buf_clients.db-num <> ?
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
  v-doc-num = "2-" + buf_clients.obj-type  
            + string( buf_clients.obj-code) 
            + "_" + string(v-temp-date).  
  if buf_clients.obj-type  = {&shop} OR buf_clients.obj-type  = {&stock} then DO:
     for each price-doc no-lock where
              price-doc.obj-type   = buf_clients.obj-type  and
              price-doc.obj-code   = buf_clients.obj-code  and
              price-doc.status_    = {&act-overvalue}      and
              price-doc.fact-date  < vardate-actual-docs 
     :
       RUN cleanTable no-error .
       if error-status:error then 
         undo, return error return-value.  
       
       { cleandb/delmainrec.i price-doc}
     end.
     
     if can-find(first buf_price-list where
                       buf_price-list.doc-num = v-doc-num) then
     do:
      create buf_price-doc .
      assign
          buf_price-doc.PS         = "Переоценка создана в процессе обрезания базы (по товарам на объекте) "
          buf_price-doc.creid      =  USERID("адм")
          buf_price-doc.doc-date   =  v-temp-date
          buf_price-doc.doc-num    =  v-doc-num
          buf_price-doc.fact-date  =  v-temp-date
          buf_price-doc.fact-num   =  2
          buf_price-doc.fact-order =  v-fact-order
          buf_price-doc.fact-time  =  time
          buf_price-doc.host-code  =  buf_clients.host-code
          buf_price-doc.obj-type   =  buf_clients.obj-type
          buf_price-doc.obj-code   =  buf_clients.obj-code
          buf_price-doc.sale-base  =  v-sale-base
          buf_price-doc.rest-qnty  =  v-qnty
          buf_price-doc.shift-date =  ?
          buf_price-doc.shift-num  =  ?
          buf_price-doc.status_    = {&act-overvalue}
          buf_price-doc.cr-db-num  =  0
      .
     end. 
  end.
end.

{cleandb/setresval.i}
return vResult.

procedure cleanTable :
  define buffer price-list     for ub.price-list.
  on delete of ub.price-list  override do: end.

  for each price-list exclusive-lock where 
           price-list.doc-num = price-doc.doc-num 
  :
    run saveLastPriceList in this-procedure (buffer price-list) no-error.
    if error-status:error then return error return-value.  
    if price-list.main-price = yes then do:
      {cleandb/dellinkrec.i 
        parts  
        " where parts.out-code  = price-doc.doc-num      
            and parts.obj-code  = price-doc.obj-code
            and parts.obj-type  = price-doc.obj-type
            and parts.artic     = price-list.artic
            and parts.prod-code = price-list.prod-code
            and parts.prod-type = price-list.prod-type"
      }
    end.
    delete price-list.
    vDeleted = vDeleted + 1.
  end.
  
  {cleandb/dellinkrec.i 
    price-list-attr  
    " where price-list-attr.doc-num = price-doc.doc-num"
  }
  {cleandb/dellinkrec.i 
    doc-attr  
    " where doc-attr.doc-code = price-doc.doc-num"
  }

  {cleandb/dellinkrec.i 
    c-doc-attr  
    " where c-doc-attr.doc-code = price-doc.doc-num"
  }
  {cleandb/dellinkrec.i 
    c-price-doc  
    " where c-price-doc.doc-num = price-doc.doc-num"
  }
  {cleandb/dellinkrec.i 
    c-price-list  
    " where c-price-list.doc-num = price-doc.doc-num"
  }
  {cleandb/dellinkrec.i 
    c-price-list-attr  
    " where c-price-list-attr.doc-num = price-doc.doc-num"
  }
end procedure.

procedure saveLastPriceList:
/* ищем последнюю цену по бар-коду до даты чистки и сохраняем в temp-table */  
  define parameter buffer in-price-list for ub.price-list.
  
  define buffer buf_price-list for ub.price-list.
  
  find first buf_price-list no-lock where
             buf_price-list.obj-type   = in-price-list.obj-type
         and buf_price-list.obj-code   = in-price-list.obj-code
         and buf_price-list.b-code     = in-price-list.b-code
         and buf_price-list.price-type = in-price-list.price-type
         and buf_price-list.fact-order > in-price-list.fact-order
         and buf_price-list.fact-order < find-fact-order
  no-error.
  if not avail buf_price-list and 
     /* проверим, что такая запись уже не создавалась */
     not can-find(first buf_price-list no-lock where
                        buf_price-list.doc-num     = v-doc-num
                    and buf_price-list.price-type = in-price-list.price-type
                    and buf_price-list.b-code     = in-price-list.b-code) 
  then do:
    create buf_price-list.
    buffer-copy in-price-list to buf_price-list assign
      buf_price-list.doc-num     = v-doc-num
      buf_price-list.fact-order  = v-fact-order
      buf_price-list.calc-method = {&pr-calc-fix}
      buf_price-list.price-prev  = 0
/*      buf_price-list.doc-qnty    = (if new-gds-obj.fact-qnty <> ? then new-gds-obj.fact-qnty else 0 )  - p-nakat*/
    .
    assign
      v-sale-base = v-sale-base + buf_price-list.price-sale * buf_price-list.doc-qnty .
      v-qnty      = v-qnty + buf_price-list.doc-qnty .
    .
    run copy-parts in this-procedure (
       input  buf_price-list.doc-num
      ,input  buf_price-list.obj-type
      ,input  buf_price-list.obj-code
      ,input  buf_price-list.artic
      ,input  buf_price-list.prod-type
      ,input  buf_price-list.prod-code
    ) no-error .
    if error-status:error then return error return-value.  
  end.
end procedure.

procedure copy-parts :
  define input parameter  p-out-code         like ub.parts.out-code  no-undo .
  define input parameter  p-obj-type         like ub.parts.obj-type  no-undo .
  define input parameter  p-obj-code         like ub.parts.obj-code  no-undo .
  define input parameter  p-artic            like ub.parts.artic     no-undo .
  define input parameter  p-prod-type        like ub.parts.prod-type no-undo .
  define input parameter  p-prod-code        like ub.parts.prod-code no-undo .

  def buffer parts     for ub.parts .
  def buffer buf_parts for ub.parts .

  do
  on error undo, return error
  :
    /* привязка партий к переоценке */
    /* идем по всем партиям, но пропуская порожденные партии, */
    /* зарезервированные за документами */
    for each parts
      where parts.obj-type  = p-obj-type
        and parts.obj-code  = p-obj-code
        and parts.artic     = p-artic
        and parts.prod-type = p-prod-type
        and parts.prod-code = p-prod-code
        and parts.rsrv-free = yes
        and parts.status_   = no
        and parts.in-code   <> parts.out-code
        and parts.fact-date >= vardate-actual-docs
    on error undo, return error
    :
      run partcopy_pr-docw in this-procedure
        (input  p-out-code /* p-out-code         */
        ,buffer parts      /* buf_orig_parts     */
        ,buffer buf_parts  /* buf_parts          */
        ) no-error .
      if error-status :error then 
        return error 
          "Ошибка при создании партии~n" +
          substitute("Объект: &1 &2~n", parts.obj-type, parts.obj-code) +
          substitute("Артикул: &1 &2 &3~n", parts.artic, parts.prod-type, parts.prod-code) +
          substitute("Партия: &1 &2 ~n", parts.in-code, parts.part-code) +
          substitute("Резерв: &1~n", p-out-code).

      define variable v-parts-qnty     like ub.parts.qnty no-undo .
      define variable v-parts-cli-qnty like ub.parts.cli-qnty no-undo .

      if parts.out-code = {&free-code} then do:
        assign
          v-parts-qnty     = parts.qnty
          v-parts-cli-qnty = parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty     = abs(parts.qnty)
          v-parts-cli-qnty = abs(parts.cli-qnty)
        .
      end.

      assign
        buf_parts.qnty      = buf_parts.qnty     + v-parts-qnty
        buf_parts.fact-qnty = buf_parts.qnty
        buf_parts.real-qnty = buf_parts.qnty
        buf_parts.cli-qnty  = buf_parts.cli-qnty + v-parts-cli-qnty
      .
    end.
  end.
end procedure. /* copy-parts */

procedure partcopy_pr-docw :
  /* привязывание архивных партий к переоценке */
  /* см. partcopy.i                            */
  define variable vMsg as character no-undo.

  define input parameter  p-out-code         like ub.parts.out-code no-undo .
  define parameter buffer buf_orig_parts     for ub.parts .
  define parameter buffer buf_parts          for ub.parts .

  do transaction
  on error undo, return error
  :
    /* ищем партию и создаем партию, если ее нет */
    find first buf_parts exclusive-lock
      where buf_parts.obj-type  = buf_orig_parts.obj-type
        and buf_parts.obj-code  = buf_orig_parts.obj-code
        and buf_parts.artic     = buf_orig_parts.artic
        and buf_parts.prod-type = buf_orig_parts.prod-type
        and buf_parts.prod-code = buf_orig_parts.prod-code
        and buf_parts.in-code   = buf_orig_parts.in-code
        and buf_parts.out-code  = p-out-code
        and buf_parts.part-code = buf_orig_parts.part-code
      no-error.
    if not available buf_parts then do:
      create buf_parts .
      buffer-copy buf_orig_parts to buf_parts
      assign
        buf_parts.out-code  = p-out-code

        buf_parts.status_   = yes
        buf_parts.rsrv-free = ?
        buf_parts.doc-type  = {&act-overvalue}
        buf_parts.PS        = 'архив переоценки ' + p-out-code

        buf_parts.qnty      = 0
        buf_parts.fact-qnty = 0
        buf_parts.real-qnty = 0
        buf_parts.cli-qnty  = 0
      .

      /* сделаем партию доступной для поиска через первичный индекс */
      /* todo - возможно это не нужно, так как блок выделен в отдельную процедуру */
      validate buf_parts .
    end.
    else do:
      if buf_parts.status_   <> yes
      or buf_parts.rsrv-free <> ?
      or buf_parts.doc-type  <> {&act-overvalue}
      or buf_parts.PS        <> 'архив переоценки ' + p-out-code then 
      do:
        vMsg = 
          "Ошибка при поиске архивной партии, привязанной к переоценке~n" +
          substitute("Переоценка: &1~n", p-out-code) +
          substitute("Артикул: &1 &2 &3~n", buf_parts.artic, buf_parts.prod-type, buf_parts.prod-code) +
          substitute("status_: &1~n", buf_parts.status_) +
          substitute("rsrv-free: &1~n", buf_parts.rsrv-free) +
          substitute("doc-type: &1~n", buf_parts.doc-type) +
          substitute("PS: &1~n", buf_parts.PS)
        .
        if valid-handle(varcall-back) then
          run callback-write-to-log in varcall-back (
            input vMsg
          ) no-error .
        put unformatted
          "Ошибка при поиске архивной партии, привязанной к переоценке" skip
          "Переоценка: " p-out-code skip
          "Артикул: "    buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "status_: "    buf_parts.status_   skip
          "rsrv-free: "  buf_parts.rsrv-free skip
          "doc-type: "   buf_parts.doc-type  skip
          "PS: "         buf_parts.PS skip
        .
        undo, return error .
      end.
    end.
  end.
end procedure. /* partcopy */


