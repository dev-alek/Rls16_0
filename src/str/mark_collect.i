{cmp/str-glbl.i}
{utl/gtin.i}
{def/funcmet.i CrCheckMarkDoc char} 
   (v-cntxt-obj-type as char,
   v-cntxt-obj-code as int,
   idb-num as int,
    idoc-id as int,
   imark as char,
    is-initial-set-p as logical
   )
      :
       
  define buffer buf_marking-child for ub.marking .
  define buffer buf_marking for ub.marking.
  define buffer buf_marking-attr for  ub.marking-attr.
  define buffer buf_marking-parent for ub.marking .
  define buffer buf_utd-marking-lines for ub.utd-marking-lines.
  define buffer buf_utd-marking-lines-child for ub.utd-marking-lines .
  define buffer buf_utd-lines for ub.utd-lines.
  define buffer buf_goods for ub.goods.
  define buffer buf_gds-obj for ub.gds-obj.
  
  define variable v-par-type as character no-undo.
  define variable v-par-val  as character no-undo.
  define variable v-gds-code as integer no-undo .
  define variable v-num-recipes as integer no-undo .
  define variable v-GTIN as character no-undo .
  define variable v-GTIN-qnty as decimal no-undo .
  define variable v-GTIN-child as character no-undo .
  define variable v-GTIN-qnty-child as decimal no-undo .
  define variable v-free-qnty as decimal no-undo .
  define variable v-old-sts as integer no-undo .
  define variable v-mark-short as character no-undo.
  define variable v-GisMTcheckStatus as integer no-undo .
  define variable v-is-off-line as logical no-undo .
  define variable v-mark-weight as decimal no-undo .
  define variable v-isweighed as logical no-undo .
  
  define variable v-ok        as logical no-undo .

  if imark = ""
    then return "".

  v-mark-short = GetCodeIdent(imark).
  
  if v-mark-short = "" or v-mark-short = ?
  then do:
    return "Неизвестный формат марки.".
  end.
  
  find first buf_marking where (buf_marking.mark begins v-mark-short) no-error.
  
  if available buf_marking
  then do :
    if buf_marking.unit-ext = "LEVEL2" then
      return "Неизвестный формат марки.".
    v-GTIN = getGtinByDM(buf_marking.mark) .
  end .
  else do :
    v-GTIN = getGtinByDM(imark) .
  end .
  v-gds-code = getGdsCodeByGtin(v-GTIN) .
  v-GTIN-qnty = getQntyCodeByGtin(v-GTIN) .
  
  if v-gds-code = ?
  then do :
    return substitute ("Не удалось найти товар по gtin &1",v-GTIN).
  end .
  
  find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .
  if not available buf_goods
  then do :
    return substitute ( "Не найден товар по коду &1.",v-gds-code ).
  end .
  
  &scop proc-name gds-attr-value
  {&run_proc_attr-lib}
  ( buf_goods.gds-code,
   {&attr-weighed-gds},
   output v-par-val,
   output v-par-type
  ).
  v-isweighed = logical(v-par-val) .
  
  if v-GTIN-qnty = ?
  or v-GTIN-qnty <= 0.0
  then do :
    return substitute ("Не установлен коэффициент для упаковки для марки &1.",imark).
  end .
  
  &scop proc-name gds-attr-value
  {&run_proc_attr-lib}
  ( buf_goods.gds-code,
   {&attr-mark-type},
   output v-par-val,
   output v-par-type
  ).
  
  if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):GetIsArticForType(v-par-val)
  or (not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):GetIsArticForType(v-par-val)
    and not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):GetIsEDOForType(v-par-val)
    and not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):GetIsMarkingForType(v-par-val)
      )
  then do :
    return substitute ("Сверка марок товара &1 '&2' не требуется", buf_goods.gds-code,buf_goods.gds-name).
  end .
  
  if v-isweighed
  and v-par-val > ""
  and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(v-cntxt-obj-type, v-cntxt-obj-code):GetIsEDOForType(v-par-val)
  and not available buf_marking
  then do :
    return "Марка не найдена в БД" .
  end .
  
  define variable v-attr-value as character no-undo.
  define variable v-attr-type as character no-undo.
  {&CommentStartNoClass}
v-attr-value = gdsoattr-value (input   {&attr-mark-collect-type},
                                        input   buf_goods.gds-code,
                                        input   v-cntxt-obj-type,
                                        input   v-cntxt-obj-code,
                                        output  v-attr-type
                                        ) no-error.
{utl\comment.i} */ {&CommentStartClass}
 run gdsoattr-value in this-procedure (input   {&attr-mark-collect-type},
                                        input   buf_goods.gds-code,
                                        input   v-cntxt-obj-type,
                                        input   v-cntxt-obj-code,
                                        output  v-attr-value,
                                        output  v-attr-type
                                        ) no-error.
{utl\comment.i} */
   
  
  find first buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = idb-num
                                             and buf_utd-marking-lines.doc-id = idoc-id
                                             and buf_utd-marking-lines.mark begins v-mark-short
                                             no-error.
  if available buf_utd-marking-lines
  then do :
     return substitute ("Марка &1 добавлена в документ ранее.",imark).
  end .
  
  find first buf_utd-lines exclusive-lock where buf_utd-lines.db-num    = idb-num
                                            and buf_utd-lines.doc-id    = idoc-id
                                            and buf_utd-lines.gds-code  = buf_goods.gds-code
                                            no-error .
  if not available buf_utd-lines
  then do :
    if is-initial-set-p
    then do :
      if v-attr-value = "1"
      or v-attr-value = "2"
      then do :
        &if "{1}" eq "no"
        &then
        message substitute("Для товара &1 ранее был выполнен первоначальный сбор марок, хотите произвести его повторно?", buf_goods.gds-name)
        view-as alert-box question buttons yes-no update v-ok .
        if not v-ok
        then do :
          return "" .
        end .
        &else
            return substitute("Для товара &1 ранее был выполнен первоначальный сбор марок.", buf_goods.gds-name).        
        &endif
      end .
      &if "{1}" eq "no"
        &then
        else do :
        disable is-initial-set with frame {&frame-name} .
      end .
      &endif
    end .
    else do :
      if v-attr-value = ""
      or v-attr-value = "0"
      then do :
        &if "{1}" eq "no"
        &then
        if vLineNum = 0
        then do :
          assign is-initial-set = yes .
          display is-initial-set with frame {&frame-name} .
        end .
        else do :
          message substitute("Для товара &1 не выполнен первоначальный сбор марок, товар не может быть добавлен в документ без признака «Первоначальный сбор марок». Создайте для товара отдельный документ", buf_goods.gds-name)
          view-as alert-box .
          return "".
        end .
        &else
           return substitute("Для товара &1 не выполнен первоначальный сбор марок, товар не может быть добавлен в документ без признака «Первоначальный сбор марок». Создайте для товара отдельный документ", buf_goods.gds-name).
        &endif 
      end .
    end .
    &if "{1}" ne "no"
    &then
    define buffer bf_utd-lines for ub.utd-lines.
        
    find last bf_utd-lines no-lock where bf_utd-lines.db-num    = idb-num
                                     and bf_utd-lines.doc-id    = idoc-id
    no-error .
    define variable vLineNum as integer no-undo.
    vLineNum = if available bf_utd-lines then (bf_utd-lines.linenum + 1) else 1.
    &else
    vLineNum = vLineNum + 1.
    &endif
    create buf_utd-lines .
    assign
      buf_utd-lines.db-num    = idb-num
      buf_utd-lines.doc-id    = idoc-id
      buf_utd-lines.gds-code  = buf_goods.gds-code
      buf_utd-lines.UnitCode  = buf_goods.unit-base
      buf_utd-lines.LineNum   = vLineNum 
    .  
    assign v-free-qnty = 0 .
    find first buf_gds-obj no-lock where buf_gds-obj.obj-type  = v-cntxt-obj-type
                                     and buf_gds-obj.obj-code  = v-cntxt-obj-code
                                     and buf_gds-obj.artic     = buf_goods.artic
                                     and buf_gds-obj.prod-type = buf_goods.prod-type
                                     and buf_gds-obj.prod-code = buf_goods.prod-code
                                     no-error .
    if available buf_gds-obj
    then do :
      assign v-free-qnty = buf_gds-obj.free-qnty .
    end .
    &if "{1}" eq "no"
    &then
    create tt-utd-lines .
    buffer-copy buf_utd-lines to tt-utd-lines
    assign
      tt-utd-lines.free-qnty = v-free-qnty
      tt-utd-lines.GdsName = buf_goods.gds-name
    .
    &endif
  end .
  if v-isweighed
  then do :
    find first buf_marking-attr where buf_marking-attr.mark      eq buf_marking.mark
                                  and buf_marking-attr.attr-code eq "weight"
    no-lock no-error.
    if avail buf_marking-attr
    then
      v-mark-weight = dec(buf_marking-attr.attr-value) .
    .
    assign
      buf_utd-lines.Quantity = buf_utd-lines.Quantity + v-mark-weight
    .
  end .
  else do :
    assign
      buf_utd-lines.Quantity = buf_utd-lines.Quantity + v-GTIN-qnty
  /*    buf_utd-lines.qnty-mark = buf_utd-lines.qnty-mark + 1*/
    .
  end .
  for each buf_marking-child no-lock where buf_marking-child.mark-parent begins v-mark-short,
  first buf_utd-marking-lines-child no-lock where buf_utd-marking-lines-child.mark = buf_marking-child.mark
                                              and buf_utd-marking-lines-child.db-num  = buf_utd-lines.db-num
                                              and buf_utd-marking-lines-child.doc-id  = buf_utd-lines.doc-id
                                              and buf_utd-marking-lines-child.LineNum = buf_utd-lines.LineNum
  :
    assign
      v-GTIN-child = getGtinByDM(buf_marking-child.mark)
      v-GTIN-qnty-child = getQntyCodeByGtin(v-GTIN-child)
      buf_utd-lines.Quantity = buf_utd-lines.Quantity - v-GTIN-qnty-child
    .
  end .
  &if "{1}" eq "no"
  &then
    
  find first tt-utd-lines exclusive-lock where tt-utd-lines.db-num    = buf_utd.db-num
                                           and tt-utd-lines.doc-id    = buf_utd.doc-id
                                           and tt-utd-lines.gds-code  = buf_goods.gds-code
                                           no-error .
  assign
    tt-utd-lines.Quantity  = buf_utd-lines.Quantity
    tt-utd-lines.qnty-mark = tt-utd-lines.qnty-mark + 1
  .
  &endif
  if available buf_marking
  then do :
    create buf_utd-marking-lines .
    assign
      buf_utd-marking-lines.mark      = buf_marking.mark
      buf_utd-marking-lines.gds-code  = buf_goods.gds-code
      buf_utd-marking-lines.sts       = buf_marking.sts
      buf_utd-marking-lines.LineNum   = buf_utd-lines.LineNum
      buf_utd-marking-lines.doc-id    = idoc-id
      buf_utd-marking-lines.db-num    = idb-num
      buf_utd-marking-lines.doc-level = 1
    .
  end .
  else do :
    create buf_marking .
    assign
      buf_marking.mark = v-mark-short
      buf_marking.sts = objSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
      buf_marking.box-qnty = v-GTIN-qnty
      buf_marking.obj-type = v-cntxt-obj-type
      buf_marking.obj-code = v-cntxt-obj-code
      buf_marking.gds-code = buf_goods.gds-code
/*      buf_marking.unit     = buf_goods.unit-base*/
      buf_marking.gds-ext-id = v-GTIN
      buf_marking.unit-ext = (if v-GTIN-qnty = 1 then "UNIT" else if v-GTIN-qnty > 1 then "LEVEL1" else "")
    .
    create buf_utd-marking-lines .
    assign
      buf_utd-marking-lines.mark      = buf_marking.mark
      buf_utd-marking-lines.gds-code  = buf_goods.gds-code
      buf_utd-marking-lines.sts       = 0
      buf_utd-marking-lines.LineNum   = buf_utd-lines.LineNum
      buf_utd-marking-lines.doc-id    = idoc-id
      buf_utd-marking-lines.db-num    = idb-num
      buf_utd-marking-lines.doc-level = 1
    .
  end .
  validate buf_utd-marking-lines .
  return "" .
end.
