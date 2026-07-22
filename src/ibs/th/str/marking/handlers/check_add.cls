 
/*------------------------------------------------------------------------
   File        : tree
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : eshklyar
   Created     : Tue Mar 24 17:14:12 MSK 2020
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.gbl.sys.objth.
using ibs.th.str.marking.handlers.*.
using ibs.th.str.marking.sts.*.
block-level on error undo, throw.
class ibs.th.str.marking.handlers.check_add inherits objth: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Сервис добавления и проверки марок." get.
 
  { utl/gtin.i class }


  method public character CheckMarkUTD(mark as char, doc-id as integer, db-num as integer):
    define buffer buf_utd-marking-lines for ub.utd-marking-lines .
    define buffer bf_utd-marking-lines  for ub.utd-marking-lines .
    define variable v-error as character no-undo .
    define variable Tree    as class     tree no-undo .
    define variable ungroup as logical   no-undo .
    Tree = ObjSrv:Lib:MarkingTree .
    find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark begins mark and buf_utd-marking-lines.db-num = db-num
      and buf_utd-marking-lines.doc-id = doc-id no-error .
    if available (buf_utd-marking-lines) then
    do:
      if buf_utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB then
      do:
        v-error = "            Марка уже проверена, просканируйте следующий" .
        return v-error .
      end.
      else
      do:
        if buf_utd-marking-lines.doc-level > 1 then 
        do:
          /*Если есть блок в документе*/
          if tree:LevelUpUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then 
          do:
            message "Разгруппировать упаковки?"
              view-as alert-box question buttons yes-no update ungroup.
            if ungroup then 
            do:
              /*Разгруппировка блока*/
              if tree:UnGroupUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then 
              do:
                message "Упаковка с маркой " + buf_utd-marking-lines.mark + " разгруппирована."
                  view-as alert-box.
              end.
            end.
          end.  
        end.   
        /*Проверка детей у марки*/
        if tree:LevelDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then 
        do:
          /*Проставить статус для детей*/
          tree:StatusDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num, ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB) .
        end.
        /*Проставить статус у просканированной марки*/
        for first bf_utd-marking-lines exclusive-lock where bf_utd-marking-lines.mark = buf_utd-marking-lines.mark and bf_utd-marking-lines.db-num = buf_utd-marking-lines.db-num and
          bf_utd-marking-lines.doc-id = buf_utd-marking-lines.doc-id:
          bf_utd-marking-lines.sts   = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB .  
        end.  
      end.
    end.
    else 
    do:
      /*Проверка марки в дургих УПД*/
      find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark begins mark and buf_utd-marking-lines.db-num = db-num
        and buf_utd-marking-lines.doc-id <> doc-id no-error .
      if available (buf_utd-marking-lines) then 
      do:
        v-error = "             Товар поставлен на АЗС ранее, верните его на склад" .
        return v-error .
      end. 
      else 
      do:
        v-error = "              Товар отсутствует в поставке. Верните товар поставщику" .
          return v-error .
        end.         
      end. 
 
      
end method. 

method public character AddMarkUTD(mark as char, doc-id as integer, db-num as integer):
  define buffer buf_utd-marking-lines for ub.utd-marking-lines .
  define buffer bf_utd-marking-lines  for ub.utd-marking-lines .
  define buffer buf_utd               for ub.utd .
  define buffer buf_goods             for ub.goods .
  define buffer buf_utd-lines         for ub.utd-lines .
  define buffer buf_marking           for ub.marking .
  define variable v-error    as character no-undo .
  define variable Tree       as class     tree no-undo .
  define variable Marking    as class     mark no-undo .
  define variable ungroup    as logical   no-undo .
  define variable v-GTIN     as character no-undo .
  define variable v-gds-code as integer   no-undo .
  define variable jj         as integer   no-undo .
  define variable v-qnty     as decimal   no-undo .
  Tree = ObjSrv:Lib:MarkingTree . 
  Marking = ObjSrv:Env:Marking:Sts:Mark.
  /*Добавление товаров по маркам*/
    v-GTIN = getGtinByDM(mark) .
    if v-GTIN <> "" then 
    do:
      v-gds-code = getGdsCodeByGtin(v-GTIN) .

      find first buf_goods no-lock where buf_goods.gds-code = v-gds-code no-error .

      if available (buf_goods) then 
      do:     
        find first buf_utd no-lock where buf_utd.doc-id = doc-id and buf_utd.db-num = db-num no-error .
        find first buf_utd-lines exclusive-lock where buf_utd-lines.doc-id = doc-id and buf_utd-lines.db-num = db-num
          and buf_utd-lines.gds-code = buf_goods.gds-code no-error .
        if not available (buf_utd-lines) then 
        do:

          find last ub.utd-lines where ub.utd-lines.db-num = db-num and ub.utd-lines.doc-id = doc-id no-error .
          if not available (ub.utd-lines) then jj = 0 .
          else jj = ub.utd-lines.LineNum .       
          create buf_utd-lines .
          assign
            buf_utd-lines.GdsName  = buf_goods.gds-name
            buf_utd-lines.db-num   = db-num
            buf_utd-lines.doc-id   = doc-id
            buf_utd-lines.LineNum  = jj + 1
            buf_utd-lines.gds-code = buf_goods.gds-code
            buf_utd-lines.sts      = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB
            buf_utd-lines.UnitCode = buf_goods.unit-base
            .
        end.  

        create buf_utd-marking-lines .
        assign
          buf_utd-marking-lines.db-num    = db-num
          buf_utd-marking-lines.doc-id    = doc-id
          buf_utd-marking-lines.gds-code  = buf_utd-lines.gds-code
          buf_utd-marking-lines.LineNum   = buf_utd-lines.LineNum
          buf_utd-marking-lines.mark      = mark
          buf_utd-marking-lines.sts       = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB
          buf_utd-marking-lines.doc-level = 1
          .

        find first buf_marking exclusive-lock where buf_marking.mark begins mark no-error .
        if not available (buf_marking) then 
        do:            
          create buf_marking .
          assign
            buf_marking.gds-code   = buf_utd-marking-lines.gds-code
            buf_marking.mark       = mark
            buf_marking.sts        = Marking:PendingVerification:KeyIntDB
            buf_marking.gds-ext-id = v-GTIN
            buf_marking.obj-code   = buf_utd.obj-code
            buf_marking.obj-type   = buf_utd.obj-type
            .
          buf_marking.unit-ext  = getLevelMotpByDM(mark) .
          buf_marking.box-qnty  = getQntyUTDByDM(mark) .
          buf_marking.unit = getLevelUTDByDM(mark) .
        end.
        else 
        do:
          buf_marking.sts      = Marking:PendingVerification:KeyIntDB .
        end.    
        if buf_marking.box-qnty = ? or buf_marking.box-qnty = 0 then 
        do:

          run gbl/d-prompt.w (
            'title=':u + "Ввод количества" + '\':u
            + 'text1=':u + "Введите количество:" + '\':u
            + 'format=' + ">>>>>9.99" + '\':u
            + 'type=' + 'D' + '\':u
            + 'fillin_row=3\':u
            + 'fillin_col=6\':u
            + 'fillin_width=17\':u
            + 'fillin_height=1\':u
            + 'max-chars=17\':u     /*- максимальное количество символов для редактора*/
            + 'readonly=no\':u
            , input-output v-qnty
            ).
          buf_marking.box-qnty = v-qnty .
          buf_marking.unit  = buf_goods.unit-base .
          buf_marking.unit-ext = "UNIT" .

        end.
        buf_utd-lines.Quantity  = buf_utd-lines.Quantity  + buf_marking.box-qnty . 
      end.
      else 
        do:
          return error "Товара с GTIN - " + v-GTIN + " нет".  
        end.  
      end.      
      else 
      do:
        return error "Не определился GTIN".
      end. 
  end method. 

end class.
