block-level on error undo, throw.
define input parameter vartype-cut            as integer   no-undo.
define input parameter varlist-db             as character no-undo.
define input parameter vardate-actual-goods   as date      no-undo.
define input parameter vardate-actual-docs    as date      no-undo.
define input parameter vardate-actual-findoc  as date      no-undo.
define input parameter vardate-output-zone    as date      no-undo.
define input parameter varstay-recipe-goods   as logical   no-undo.
define input parameter varstay-weight-goods   as logical   no-undo.
define input parameter varnot-copy-del-goods  as logical   no-undo.
define input parameter varstay-history        as logical   no-undo.
define input parameter vargen-file            as character no-undo.
define stream str-gen.
output stream str-gen to vargen-file append.
if not connected("src") then do:
   return error "Нет коннекта с базой 'src'.".
end.
if not connected("dst") then do:
   return error "Нет коннекта с базой 'dst'.".
end.
find src.sys-ctrl no-lock.
if not available src.sys-ctrl then do:
   return error "В базе данных src не найдена уникальная запись sys-ctrl.".
end.
if src.sys-ctrl.db-num <> 0 then do:
   return error "Пакет обрезания работает только в главной базе данных. В данной версии удаленные БД создаются выгрузкой из главных.".
end.
if vardate-actual-docs <> ? and
   (vardate-actual-goods   > vardate-actual-docs or
    vardate-actual-goods   = ? )   then do:
      return error SUBSTITUTE("Ошибка при задании дат актуальности." +
                              "Дата актуальности товаров &1."        +
                              "Дата актуальности документов &2."     +
                              "Дата актуальности документов должна быть больше или равна дат актуальностей товаров.",
                              vardate-actual-goods,
                              vardate-actual-docs).
end.
define variable vss-revision    as character no-undo init "$Revision: e9c7fc100672, 222, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Jul 14 11:27:05 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00044001.p $":U .
define variable vss-archive     as character no-undo init "$Archive  /cut/pie/00031001.p $":U .
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 31." .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define  shared temp-table tt-objs no-undo
  field obj-type as character
  field obj-code as integer
  index pi is unique primary obj-type obj-code
  .
define buffer buf_clients for src.clients .
define buffer old-price-doc     for src.price-doc.
define buffer old-price-list    for src.price-list.
define buffer old-n-price-list  for src.price-list.
define buffer old-doc-line      for src.doc-line.
define variable v-total-parts-qnty like dst.parts.qnty no-undo .
define variable v-qnty        like dst.parts.qnty no-undo .
define variable p-nakat       like dst.parts.qnty no-undo .
define buffer new-price-doc   for dst.price-doc.
define buffer new-price-list  for dst.price-list.
define buffer new-trn-doc     for dst.trn-doc.
define buffer new-gds-obj     for dst.gds-obj.
define buffer new-gds-prt     for dst.gds-prt.
define buffer new-goods       for dst.goods.
define buffer new-bar-code    for dst.bar-code.
define buffer new-shop        for dst.shop.
define buffer new-store       for dst.store.
define buffer new-prt-obj     for dst.prt-obj.
define buffer new-n-bar-code  for dst.bar-code.
define variable v-exist     as logical   no-undo .
define variable v-doc-num   as character no-undo .
define variable v-sale-base as decimal   no-undo .
define variable v-i         as integer   no-undo .
define variable v-temp-date as date      no-undo .
define variable  v-fact-order as decimal no-undo .
define variable  find-fact-order as decimal no-undo .
define variable p-bar-code           as integer   no-undo .
define variable p-root-node  as integer no-undo .
procedure moved :
  do
  on error undo, return error return-value
  :
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define input  parameter p-host-code as integer   no-undo .
  v-exist = false .
  V-DOC-NUM = "2-" + p-obj-type  + string( p-obj-code) + "_" + string(v-temp-date).
  v-sale-base = 0 .
  v-qnty      = 0 .
  for each new-gds-obj no-lock where
           new-gds-obj.obj-type   = p-obj-type                and
           new-gds-obj.obj-code   = p-obj-code
           on error undo, return error SubSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)) :
    find first new-goods where
               new-goods.artic     = new-gds-obj.artic and
               new-goods.prod-code = new-gds-obj.prod-code and
               new-goods.prod-type = new-gds-obj.prod-type
               no-lock no-error .
     if error-status:error then next .
     if not can-find (first old-doc-line no-lock
                      where old-doc-line.obj-type  = new-gds-obj.obj-type
                        and old-doc-line.obj-code  = new-gds-obj.obj-code
                        and old-doc-line.prod-type = new-gds-obj.prod-type
                        and old-doc-line.prod-code = new-gds-obj.prod-code
                        and old-doc-line.artic     = new-gds-obj.artic
                        and old-doc-line.status_   = 'факт':U
                        and old-doc-line.fact-order > v-fact-order)
        and
        new-goods.stts        = 1  and
        new-gds-obj.fact-qnty = 0 and
        new-gds-obj.free-qnty = 0 then next .
    find new-gds-prt no-lock where
         new-gds-prt.upper-code = new-goods.prt-root
         no-error .
    if available new-gds-prt then do:
       assign
         p-root-node = new-gds-prt.node-code
         .
     end.
     find first  new-bar-code no-lock
      where new-bar-code.gds-code  = new-goods.gds-code
        and new-bar-code.node-code = p-root-node
        and new-bar-code.part-code = ""
        and new-bar-code.in-code   = ""
        and new-bar-code.unit-cli  = new-goods.unit-base
      no-error .
          if (avail new-bar-code and error-status:error  = false ) then p-bar-code = new-bar-code.b-code .
                                                                   else p-bar-code = 0 .
    run c-nakat( input new-gds-obj.obj-code , input  new-gds-obj.obj-type ,
                 input  new-goods.artic, input new-goods.prod-code,
                 input new-goods.prod-type, output p-nakat) .
    run ff.
   end.
  if v-exist then do :
      v-i = v-i + 1 .
      create new-price-doc .
      assign
          new-price-doc.PS         = "Переоценка создана в процессе обрезания базы (по товарам на объекте) "
          new-price-doc.creid      =  USERID("dst")
          new-price-doc.doc-date   =  v-temp-date
          new-price-doc.doc-num    =  V-DOC-NUM
          new-price-doc.fact-date  =  v-temp-date
          new-price-doc.fact-num   =  2
          new-price-doc.fact-order =  v-fact-order
          new-price-doc.fact-time  =  time
          new-price-doc.host-code  =  p-host-code
          new-price-doc.obj-type   =  p-obj-type
          new-price-doc.obj-code   =  p-obj-code
          new-price-doc.sale-base  =  v-sale-base
          new-price-doc.rest-qnty  =  v-qnty
          new-price-doc.shift-date =  ?
          new-price-doc.shift-num  =  ?
          new-price-doc.status_    = 'акт':U
          new-price-doc.cr-db-num  =  0
      .
 end.
  end.
end procedure.
do
on error undo, return error SubSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
on WRITE of dst.price-doc  override do: end.
on WRITE of dst.price-list override do: end.
if vardate-actual-docs <> ? then  v-temp-date = vardate-actual-docs  - 1 .
                            else  v-temp-date = today .
          v-fact-order =  integer(v-temp-date) + 0.97 + 2 * 0.0000000001  .
          find-fact-order =  integer(v-temp-date) + 0.99 .
    for each buf_clients no-lock  where
            buf_clients.db-num <> ?
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
      :
      if vartype-cut = 1 then do:
          find first tt-objs where tt-objs.obj-type = buf_clients.obj-type and
                                   tt-objs.obj-code = buf_clients.obj-code no-error.
      end.
    if vartype-cut = 0      or
          (vartype-cut = 1 and available tt-objs) then do:
            if buf_clients.obj-type = 'маг':U then do:
                for each new-shop no-lock where new-shop.obj-code = buf_clients.obj-code
                    on error undo, return error SubSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                    run moved ( buf_clients.obj-type ,buf_clients.obj-code, new-shop.host-code ) .
                end.
            end.
            if buf_clients.obj-type = 'скл':U then do:
                for each new-store no-lock  where new-store.obj-code = buf_clients.obj-code
                    on error undo, return error SubSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                    run moved ( buf_clients.obj-type ,buf_clients.obj-code, new-store.host-code ) .
                end.
            end.
    end.
    else do:
            if buf_clients.obj-type = 'маг':U then do:
                for each new-shop no-lock where new-shop.obj-code = buf_clients.obj-code
                    on error undo, return error SubSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                    run moved ( buf_clients.obj-type ,buf_clients.obj-code, new-shop.host-code ) .
                end.
            end.
            if buf_clients.obj-type = 'скл':U then do:
                for each new-store no-lock  where new-store.obj-code = buf_clients.obj-code
                    on error undo, return error SubSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2)):
                    run moved ( buf_clients.obj-type ,buf_clients.obj-code, new-store.host-code ) .
                end.
            end.
    end.
 end.
If v-i > 0 Then
  return "Произведено добавление переоценок по товарам. Довавлено " + string(v-i) + " закрытых переоценок.".
Else
  return "Проверка на наличие переоценок по товару закончена. Добавлений переоценок не было.".
output stream str-gen close.
end.
procedure copy-parts :
  define input parameter  p-out-code         like dst.parts.out-code  no-undo .
  define input parameter  p-obj-type         like dst.parts.obj-type  no-undo .
  define input parameter  p-obj-code         like dst.parts.obj-code  no-undo .
  define input parameter  p-artic            like dst.parts.artic     no-undo .
  define input parameter  p-prod-type        like dst.parts.prod-type no-undo .
  define input parameter  p-prod-code        like dst.parts.prod-code no-undo .
  define output parameter p-total-parts-qnty like dst.parts.qnty      no-undo .
  def buffer buf_parts for dst.parts .
  do
  on error undo, return error
  :
    assign
      p-total-parts-qnty = 0
    .
    for each dst.parts
      where dst.parts.obj-type  = p-obj-type
        and dst.parts.obj-code  = p-obj-code
        and dst.parts.artic     = p-artic
        and dst.parts.prod-type = p-prod-type
        and dst.parts.prod-code = p-prod-code
        and dst.parts.rsrv-free = yes
        and dst.parts.status_   = no
        and dst.parts.in-code   <> dst.parts.out-code
    on error undo, return error
    :
      run partcopy_pr-docw in this-procedure
        (input  p-out-code
        ,buffer dst.parts
        ,buffer buf_parts
        ) no-error .
      if error-status :error then do:
        message
          "Ошибка при создании партии" skip
          "Объект" dst.parts.obj-type dst.parts.obj-code skip
          "Артикул" dst.parts.artic dst.parts.prod-type dst.parts.prod-code skip
          "Партия" dst.parts.in-code dst.parts.part-code skip
          "Резерв" p-out-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      define variable v-parts-qnty     like dst.parts.qnty no-undo .
      define variable v-parts-cli-qnty like dst.parts.cli-qnty no-undo .
      if dst.parts.out-code = 'free-zone':U then do:
        assign
          v-parts-qnty     = dst.parts.qnty
          v-parts-cli-qnty = dst.parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty     = abs(dst.parts.qnty)
          v-parts-cli-qnty = abs(dst.parts.cli-qnty)
        .
      end.
      assign
        buf_parts.qnty      = buf_parts.qnty     + v-parts-qnty
        buf_parts.fact-qnty = buf_parts.qnty
        buf_parts.real-qnty = buf_parts.qnty
        buf_parts.cli-qnty  = buf_parts.cli-qnty + v-parts-cli-qnty
      .
      assign
        p-total-parts-qnty  = p-total-parts-qnty + v-parts-qnty
      .
    end.
  end.
end procedure.
procedure partcopy_pr-docw :
  define input parameter  p-out-code         like dst.parts.out-code no-undo .
  define parameter buffer buf_orig_parts     for dst.parts .
  define parameter buffer buf_parts          for dst.parts .
  do transaction
  on error undo, return error
  :
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
        buf_parts.doc-type  = 'акт':U
        buf_parts.PS        = 'архив переоценки ' + p-out-code
        buf_parts.qnty      = 0
        buf_parts.fact-qnty = 0
        buf_parts.real-qnty = 0
        buf_parts.cli-qnty  = 0
      .
      validate buf_parts .
    end.
    else do:
      if buf_parts.status_   <> yes
      or buf_parts.rsrv-free <> ?
      or buf_parts.doc-type  <> 'акт':U
      or buf_parts.PS        <> 'архив переоценки ' + p-out-code then do:
        message
          "Ошибка при поиске архивной партии, привязанной к переоценке" skip
          "Переоценка" p-out-code skip
          "Артикул"    buf_parts.artic buf_parts.prod-type buf_parts.prod-code skip
          "status_"    buf_parts.status_   skip
          "rsrv-free"  buf_parts.rsrv-free skip
          "doc-type"   buf_parts.doc-type  skip
          "PS"         buf_parts.PS skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure c-nakat :
define input parameter   l-obj-code  like dst.goods.prod-code no-undo .
define input parameter   l-obj-type  like dst.goods.prod-type no-undo .
define input parameter   l-artic     like dst.goods.artic     no-undo .
define input parameter   l-prod-code like dst.goods.prod-code no-undo .
define input parameter   l-prod-type like dst.goods.prod-type no-undo .
define output parameter  l-nakat     like dst.obj-gds.fact-qnty   no-undo .
define buffer new-trn-doc     for dst.trn-doc.
define buffer new-doc-line    for dst.doc-line.
 l-nakat = 0 .
for each new-doc-line where
          new-doc-line.obj-type  = l-obj-type  and
          new-doc-line.obj-code  = l-obj-code  and
          new-doc-line.artic     = l-artic     and
          new-doc-line.prod-code = l-prod-code and
          new-doc-line.prod-type = l-prod-type no-lock ,
          first new-trn-doc where
                new-doc-line.doc-code = new-trn-doc.doc-code  and
              ( new-trn-doc.doc-type  = 'при':U OR
                new-trn-doc.doc-type  = 'рас':U or
                new-trn-doc.doc-type  = 'возврат':U or
                new-trn-doc.doc-type  = 'спи':U )  no-lock :
                if new-doc-line.fact-qnty <> ? then do:
                if new-trn-doc.doc-type  = 'при':U or
                   new-trn-doc.doc-type  = 'возврат':U
                then
                   l-nakat =  l-nakat + new-doc-line.fact-qnty .
                else
                   l-nakat =  l-nakat - new-doc-line.fact-qnty .
                end.
end.
end procedure.
PROCEDURE  FF :
define variable p-nakat2 as decimal no-undo .
        find last  old-price-list  no-lock where
          old-price-list.b-code     = p-bar-code    and
          old-price-list.main-price = true         and
          old-price-list.fact-order < find-fact-order and
          old-price-list.fact-order <> 0           and
          old-price-list.fact-order <> ?           and
          old-price-list.price-type = ""            and
          old-price-list.obj-type   = new-gds-obj.obj-type   and
          old-price-list.obj-code   = new-gds-obj.obj-code
          use-index fact-close no-error .
          if avail old-price-list then do :
             v-exist = true .
             create new-price-list.
             buffer-copy old-price-list to new-price-list
             assign
               new-price-list.doc-num     = V-DOC-NUM
               new-price-list.fact-order  = v-fact-order
               new-price-list.b-code      = p-bar-code
               new-price-list.calc-method = 'Не-считать':U
               new-price-list.price-prev  = 0
               new-price-list.doc-qnty    = (if new-gds-obj.fact-qnty <> ? then new-gds-obj.fact-qnty else 0 )  - p-nakat
               .
                for each  old-n-price-list  no-lock where
                  old-n-price-list.doc-num    = old-price-list.doc-num     and
                  old-n-price-list.main-price = false  and
                  old-n-price-list.price-type = ""                      and
                  old-n-price-list.artic     = old-price-list.artic     and
                  old-n-price-list.prod-code = old-price-list.prod-code and
                  old-n-price-list.prod-type = old-price-list.prod-type ,
                  first new-n-bar-code no-lock where  new-n-bar-code.b-code = old-n-price-list.b-code ,
                  each new-prt-obj no-lock where
                      new-prt-obj.artic     = old-price-list.artic     and
                      new-prt-obj.prod-code = old-price-list.prod-code and
                      new-prt-obj.prod-type = old-price-list.prod-type and
                      new-prt-obj.obj-type  = new-gds-obj.obj-type     and
                      new-prt-obj.obj-code  = new-gds-obj.obj-code     and
                      new-prt-obj.prt-code  = new-n-bar-code.node-code   :
                      run c-nakat2( input new-gds-obj.obj-code , input  new-gds-obj.obj-type ,
                          input new-goods.artic ,
                          input new-prt-obj.prt-code ,
                          input new-goods.prod-code, input new-goods.prod-type,
                          output p-nakat2) .
                      create new-price-list.
                      buffer-copy old-n-price-list to new-price-list
                      assign
                        new-price-list.doc-num     = V-DOC-NUM
                        new-price-list.fact-order  = v-fact-order
                        new-price-list.calc-method = 'Не-считать':U
                        new-price-list.price-prev  = 0
                        new-price-list.doc-qnty    = (if new-prt-obj.fact-qnty <> ? then new-prt-obj.fact-qnty else 0 )  - p-nakat2
                        .
                  end.
          end.
          Else do:
          end.
        if available new-price-list then do:
            v-sale-base = v-sale-base  + new-price-list.price-sale * new-price-list.doc-qnty .
            v-qnty      = v-qnty       + new-price-list.doc-qnty .
            run copy-parts
              (input   new-price-list.doc-num
              , input  new-price-list.obj-type
              , input  new-price-list.obj-code
              , input  new-price-list.artic
              , input  new-price-list.prod-type
              , input  new-price-list.prod-code
              , output v-total-parts-qnty
              )  no-error .
            if error-status :error then message error-status :get-message(1)
                view-as alert-box .
         end.
end procedure.
procedure c-nakat2 :
define input parameter   l-obj-code  like dst.goods.prod-code no-undo .
define input parameter   l-obj-type  like dst.goods.prod-type no-undo .
define input parameter   l-artic     like dst.goods.artic     no-undo .
define input parameter   l-prt-code  as integer no-undo .
define input parameter   l-prod-code like dst.goods.prod-code no-undo .
define input parameter   l-prod-type like dst.goods.prod-type no-undo .
define output parameter  l-nakat     like dst.obj-gds.fact-qnty   no-undo .
define buffer new-trn-doc     for dst.trn-doc.
define buffer new-doc-line    for dst.doc-line.
define buffer new-gds-dtl for dst.gds-dtl.
 l-nakat = 0 .
for each new-gds-dtl where
          new-gds-dtl.obj-type  = l-obj-type  and
          new-gds-dtl.obj-code  = l-obj-code  and
          new-gds-dtl.artic     = l-artic     and
          new-gds-dtl.prt-code  = l-prt-code  and
          new-gds-dtl.prod-code = l-prod-code and
          new-gds-dtl.prod-type = l-prod-type no-lock ,
          first new-trn-doc where
                new-gds-dtl.doc-code = new-trn-doc.doc-code  and
              ( new-trn-doc.doc-type  = 'при':U OR
                new-trn-doc.doc-type  = 'рас':U or
                new-trn-doc.doc-type  = 'возврат':U or
                new-trn-doc.doc-type  = 'спи':U )  no-lock :
                if new-gds-dtl.fact-qnty <> ? then do:
                if new-trn-doc.doc-type  = 'при':U or
                   new-trn-doc.doc-type  = 'возврат':U
                then
                   l-nakat =  l-nakat + new-gds-dtl.fact-qnty .
                else
                   l-nakat =  l-nakat - new-gds-dtl.fact-qnty .
                end.
end.
end procedure.
