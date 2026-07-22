/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 16 мая 2022 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 16 мая 2022 г.

*/


using Progress.Lang.*.
using ibs.th.gbl.sys.objth.
using ibs.th.gbl.sys.objsrv.
using ibs.th.str.marking.sts.*.
block-level on error undo, throw.

class ibs.th.str.marking.handlers.treeexem inherits objth: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Бибилиотека обработки марок с обращением к БД" get.
 

  method public logical LevelDownUTD(mark as char, doc-id as integer, db-num as integer):
    define buffer buf_utd-marking-lines for ub.utd-marking-lines . 
    define buffer buf_marking           for ub.marking .
    define variable vflag as logical no-undo.
    find first buf_marking no-lock where buf_marking.mark-parent = mark no-error . 
    if available (buf_marking) then do:
      if can-find(first buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = db-num and buf_utd-marking-lines.doc-id = doc-id
        and buf_utd-marking-lines.mark = buf_marking.mark )
      then vflag = yes .
      else vflag = no .      
    end.  
    else vflag = no .
    release buf_marking.
    return vflag.
  end method. 

  method public logical LevelDownDoc(mark as char, obj-code as integer, obj-type as character, in-code as character, out-code as character):
    define buffer buf_marking-lines for ub.marking-lines .
    define buffer buf_marking           for ub.marking .

    find first buf_marking no-lock where buf_marking.mark-parent = mark no-error .
    if available (buf_marking) then do:
      for first buf_marking-lines no-lock where buf_marking-lines.obj-type = obj-type and buf_marking-lines.obj-code = obj-code
        and buf_marking-lines.mark = buf_marking.mark and buf_marking-lines.in-code = in-code and buf_marking-lines.out-code = out-code:
        return yes .
      end.
      return no .      
    end.  
    else return no .  
      
  end method. 
  
  method public logical LevelUpUTD(mark as char, doc-id as integer, db-num as integer):
    define buffer buf_utd-marking-lines for ub.utd-marking-lines .
    define buffer buf_marking           for ub.marking .

    find first buf_marking no-lock where buf_marking.mark = mark no-error .
    if available (buf_marking) then do:
      if can-find(first buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = db-num and buf_utd-marking-lines.doc-id = doc-id
        and buf_utd-marking-lines.mark = buf_marking.mark-parent)
      then return yes .
      else return no .      
    end.  
    else return no .  
      
  end method. 

  method public logical StatusDownUTD(mark as char, doc-id as integer, db-num as integer, sts as integer):
    do trans:
    define buffer buf_utd-marking-lines for ub.utd-marking-lines .
    define buffer buf_marking           for ub.marking .
    define buffer marking               for ub.marking .
    define variable vOk  as logical no-undo init yes.
    define variable vBad as logical no-undo.
    
    for each buf_marking no-lock where buf_marking.mark-parent = mark :
      for each buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.db-num = db-num and buf_utd-marking-lines.doc-id = doc-id
        and buf_utd-marking-lines.mark = buf_marking.mark:
          if LevelDownUTD(buf_utd-marking-lines.mark, buf_utd-marking-lines.doc-id, buf_utd-marking-lines.db-num) then do:
            vOk =  StatusDownUTD(buf_utd-marking-lines.mark,buf_utd-marking-lines.doc-id,buf_utd-marking-lines.db-num,sts) .
          end.
          else 
             vOk = yes.
          if vOk then do:
            if sts ne ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
               or ( sts eq ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
                    and buf_marking.sts ne ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
                    and buf_marking.sts ne ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
/*                    and buf_marking.sts ne ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB*/
                    and buf_marking.sts ne ObjSrv:Env:Marking:Sts:Mark:OutZone:KeyIntDB
                    and buf_marking.sts ne ObjSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB
                    and buf_marking.sts ne ObjSrv:Env:Marking:Sts:Mark:SaleWaitLock:KeyIntDB
                   )
            then do:
               buf_utd-marking-lines.sts = sts .
            end.
            if sts eq ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
               and (buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:SaleLock:KeyIntDB
                 or buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:SaleWaitLock:KeyIntDB
                 or buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:ReturnLock:KeyIntDB
                 or buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:ReturnWaitLock:KeyIntDB)
            then do:
              find first marking exclusive-lock where marking.mark = mark.
              assign
                buf_utd-marking-lines.sts = buf_marking.sts
                marking.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
              .
            end.
          end.
          else 
             vBad = yes.
          
      end.
      
    end.
    end.
    return not vBad .    
  end method. 

  method public logical StatusUpUTD(iMark as char, iDbNum as integer, iDocId as integer, iSts as integer):
    define buffer buf_utd-marking-lines for ub.utd-marking-lines .
    define buffer buf_marking           for ub.marking .

    if iMark = "" then
      return no.

    if checkedAllMarksOfUpakUTD(iMark, iDbNum, iDocId)
    then do:
      for first buf_utd-marking-lines exclusive-lock where 
                buf_utd-marking-lines.mark = iMark 
            and buf_utd-marking-lines.db-num = buf_utd-marking-lines.db-num 
            and buf_utd-marking-lines.doc-id = buf_utd-marking-lines.doc-id
      :
        buf_utd-marking-lines.sts   = iSts.
        for first buf_marking no-lock where
                  buf_marking.mark begins buf_utd-marking-lines.mark
        :
          StatusUpUTD(buf_marking.mark-parent, iDbNum, iDocId, iSts). 
        end.   
      end. 
      return yes. 
   end.
    
  return no.    
  end method. 


  method public integer StatusDownDoc(mark as char, obj-code as integer, obj-type as character, in-code as character, out-code as character, sts as integer):
    do trans:
    define buffer buf_marking-lines for ub.marking-lines .
    define buffer buf_marking           for ub.marking .
    define variable qnty-check  as integer no-undo .
    
    for each buf_marking no-lock where buf_marking.mark-parent = mark :
      for each buf_marking-lines exclusive-lock where buf_marking-lines.obj-code = obj-code and buf_marking-lines.obj-type = obj-type
        and buf_marking-lines.mark = buf_marking.mark and buf_marking-lines.in-code = in-code and buf_marking-lines.out-code = out-code:
          buf_marking-lines.sts = sts .
          qnty-check = qnty-check + 1 .
          if LevelDownDoc(buf_marking-lines.mark, buf_marking-lines.obj-code, buf_marking-lines.obj-type, buf_marking-lines.in-code, buf_marking-lines.out-code) then do:
            qnty-check = qnty-check + StatusDownDoc(buf_marking-lines.mark,buf_marking-lines.obj-code,buf_marking-lines.obj-type, buf_marking-lines.in-code, buf_marking-lines.out-code, buf_marking-lines.sts) .
          end.
      end.
      
    end.  
    end.
    return qnty-check .    
  end method. 
  
  method public integer DeleteDownDoc(mark as char, obj-code as integer, obj-type as character, in-code as character, out-code as character):
    do trans:
    define buffer buf_marking-lines for ub.marking-lines .
    define buffer buf_marking           for ub.marking .
    define variable qnty-check  as integer no-undo .
    
    for each buf_marking exclusive-lock where buf_marking.mark-parent = mark :
      for each buf_marking-lines exclusive-lock where buf_marking-lines.obj-code = obj-code and buf_marking-lines.obj-type = obj-type
        and buf_marking-lines.mark = buf_marking.mark and buf_marking-lines.in-code = in-code and buf_marking-lines.out-code = out-code:
          buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB.

          if LevelDownDoc(buf_marking-lines.mark, buf_marking-lines.obj-code, buf_marking-lines.obj-type, buf_marking-lines.in-code, buf_marking-lines.out-code) then do:
            DeleteDownDoc(buf_marking-lines.mark,buf_marking-lines.obj-code,buf_marking-lines.obj-type, buf_marking-lines.in-code, buf_marking-lines.out-code) .
          end.
          delete buf_marking-lines .
      end.
    end.  
    end.
    return qnty-check .    
  end method. 
  
  method public logical UnGroupUTD(mark as char, doc-id as integer, db-num as integer):
    do trans:
    define buffer buf_utd-marking-lines for ub.utd-marking-lines .
    define buffer buf_marking           for ub.marking .
    define buffer bf_marking            for ub.marking .
    define buffer marking            for ub.marking .
    define variable v-is                as logical no-undo.
    
    for first marking where marking.mark = mark no-lock:
      for first buf_marking exclusive-lock where buf_marking.mark = marking.mark-parent:
/*        for each bf_marking no-lock where bf_marking.mark-parent = buf_marking.mark:
          for first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.db-num = db-num and buf_utd-marking-lines.doc-id = doc-id
            and buf_utd-marking-lines.mark = bf_marking.mark:
            buf_utd-marking-lines.doc-level = buf_utd-marking-lines.doc-level - 1 .          
          end.
        end.   */
        buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB. .
        for first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.db-num = db-num and buf_utd-marking-lines.doc-id = doc-id
            and buf_utd-marking-lines.mark = buf_marking.mark:
              buf_utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB. .
/*              buf_utd-marking-lines.doc-level = 0 . */
        end.       
        UnGroupUTD(buf_marking.mark, doc-id, db-num).
        v-is = yes .
      end.
    end.
    
  end.
  release marking.
  release buf_utd-marking-lines.
  release bf_marking.
  release buf_marking.
  return v-is.
  end method.   

  method public logical UnGroupDoc(mark as char, in-code as character, out-code as character, obj-code as integer, obj-type as character):
    define buffer buf_marking-lines for ub.marking-lines .
    define buffer buf_marking           for ub.marking .
    define buffer bf_marking            for ub.marking .
    define buffer marking            for ub.marking .
    
    define variable v-log as logical no-undo.
    ff_:
    for first marking where marking.mark = mark  no-lock trans:
      for first buf_marking exclusive-lock where buf_marking.mark = marking.mark-parent:
        for each bf_marking no-lock where bf_marking.mark-parent = buf_marking.mark:
          for first buf_marking-lines exclusive-lock where buf_marking-lines.in-code = in-code and buf_marking-lines.out-code = out-code and 
          buf_marking-lines.obj-code = obj-code and buf_marking-lines.obj-type = obj-type and buf_marking-lines.mark = bf_marking.mark:
            buf_marking-lines.doc-level = buf_marking-lines.doc-level - 1 .          
          end.
        end.
        buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB. .
          for first buf_marking-lines exclusive-lock where buf_marking-lines.in-code = in-code and buf_marking-lines.out-code = out-code and 
          buf_marking-lines.obj-code = obj-code and buf_marking-lines.obj-type = obj-type and buf_marking-lines.mark = buf_marking.mark:
              buf_marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB. .
              buf_marking-lines.doc-level = 0 .
        end.
        v-log = true.
        leave ff_.
      end.
    end.
    release marking.
    release bf_marking.
    release buf_marking.
    release buf_marking-lines.
    return v-log .
  end method.   

  method public logical UnGroupMark(mark as char):
    define buffer buf_marking           for ub.marking .
    define buffer bf_marking            for ub.marking .
    find first bf_marking no-lock where bf_marking.mark = mark.
    for each buf_marking exclusive-lock where buf_marking.mark = bf_marking.mark-parent trans:
      buf_marking.sts =  ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB.
      UnGroupMark (buf_marking.mark).
    end.
    release buf_marking.
    release bf_marking.
    return true.
  end method.   

  method public logical LevelDown(mark as char):
    do trans:
    define buffer buf_marking           for ub.marking .

    if can-find (first buf_marking no-lock where buf_marking.mark-parent = mark)
      then return true.
      else return false.  
    end.
  end method. 
  
  method public void LockInvChildeMark (mark as char, doc-code as char):
    
    define buffer buf_utd-marking-lines for ub.utd-marking-lines .
    define buffer buf_marking           for ub.marking .
    define buffer bf_marking            for ub.marking .
    
    for each buf_marking no-lock where buf_marking.mark-parent = mark trans:
      create ub.marking-attr.
      ub.marking-attr.mark = buf_marking.mark.
      ub.marking-attr.attr-code = "inv-doc".
      ub.marking-attr.attr-value = doc-code.
      LockInvChildeMark (buf_marking.mark, doc-code).
      release ub.marking-attr.
    end.

  end method.
  
  method public void LockChkChildeMark (Imark as char ):
    
    def buffer buf_marking for ub.marking.
    def buffer buf_mark for ub.marking. 
    find first buf_mark where buf_mark.mark eq Imark
    no-lock no-error.
    if available buf_mark
    then do:
      for each buf_marking exclusive-lock where buf_marking.mark-parent = buf_mark.mark trans:
         buf_marking.loc-key = buf_mark.loc-key.
         buf_marking.sts = buf_mark.sts.
         LockChkChildeMark (buf_marking.mark).   
      end.
    end.
    release buf_mark.
    
  end method.

  method public integer  GetQntySts(mark as char, sts as integer):
     define buffer buf_marking for marking.
     define variable v-q as integer no-undo.
     find first buf_marking where buf_marking.mark = mark no-lock no-error.
     if available buf_marking
     then do:
        if     buf_marking.sts = sts
           and buf_marking.box-qnty <> ?
        then
           v-q = buf_marking.box-qnty.
        else do:
           for each buf_marking where buf_marking.mark-parent = mark no-lock:
              v-q = v-q + GetQntySts(buf_marking.mark, sts).
           end.
        end.
     end.
     return v-q.
   end method. 
 
  method public integer  GetQntyStsUnit(db-num as integer,doc-id as integer, line-num as integer , sts as integer):
     define buffer buf_utd-marking-lines for utd-marking-lines.
     define buffer buf_marking  for marking.
     define variable v-q as integer no-undo.
     for each buf_utd-marking-lines where buf_utd-marking-lines.db-num = db-num
          and buf_utd-marking-lines.doc-id = doc-id
          and buf_utd-marking-lines.LineNum = line-num
          :
          
          find first buf_marking where buf_marking.mark = buf_utd-marking-lines.mark and buf_marking.unit-ext = "UNIT"
            and buf_marking.sts = sts no-error.
          if available (buf_marking)
            then v-q = v-q + 1.
      end.
      return v-q.
  end method. 
 
 method public integer  GetQntyCheckMark(db-num as integer,doc-id as integer, line-num as integer):
     define buffer bf_utd-marking-lines for ub.utd-marking-lines.
     define buffer bf_marking  for ub.marking.
     define variable v-q as integer no-undo.
     define variable Marking as class mark no-undo .
     Marking = ObjSrv:Env:Marking:Sts:Mark.
   
     block-mark-line:
     for each bf_utd-marking-lines where bf_utd-marking-lines.db-num    = db-num   and
                                         bf_utd-marking-lines.doc-id    = doc-id   and
                                         bf_utd-marking-lines.LineNum   = Line-Num  and
                                         bf_utd-marking-lines.doc-level = 1
     no-lock:
        if not isMark(bf_utd-marking-lines.mark)
        then
           next block-mark-line.
        
        if     bf_utd-marking-lines.sts   = Marking:Checked_:KeyIntDB
        then do:
            
           find first bf_marking where bf_marking.mark eq bf_utd-marking-lines.mark no-lock no-error.
           v-q =  v-q + if available bf_marking then bf_marking.box-qnty else 1  .
        end.
        else do:
           if LevelDownUTD(bf_utd-marking-lines.mark, bf_utd-marking-lines.doc-id, bf_utd-marking-lines.db-num)
           then
              v-q =  v-q + GetQntyCheckMark(db-num, doc-id, line-num, bf_utd-marking-lines.mark).
        end.
     end.
     return v-q.
  end method. 
 
  method public integer  GetQntyCheckMark(db-num as integer,doc-id as integer, line-num as integer,  imark as character ):
     define buffer bf_utd-marking-lines for ub.utd-marking-lines.
     define buffer bf_marking  for ub.marking.
     define variable Marking as class mark no-undo .
     Marking = ObjSrv:Env:Marking:Sts:Mark.
   
     define variable v-q as integer no-undo.
     block-mark-line:
     for each bf_marking where bf_marking.mark-parent eq imark 
     no-lock,
            
        first bf_utd-marking-lines where bf_utd-marking-lines.db-num  = db-num   and
                                         bf_utd-marking-lines.doc-id  = doc-id   and
                                         bf_utd-marking-lines.LineNum = LineNum  and
                                         bf_utd-marking-lines.mark    = bf_marking.mark
     no-lock:
        if     bf_utd-marking-lines.sts   = Marking:Checked_:KeyIntDB
        then do:
           v-q =  v-q + if available bf_marking then bf_marking.box-qnty else 1  .
        end.
        else do:
           if LevelDownUTD(bf_utd-marking-lines.mark, bf_utd-marking-lines.doc-id, bf_utd-marking-lines.db-num)
           then
              v-q =  v-q + GetQntyCheckMark(db-num, doc-id, line-num, bf_utd-marking-lines.mark).
        end.
     end.
     return v-q.
  end method. 

  /* Метод проверяет все ли дочерние марки проверены в УПД */
  method public logical checkedAllMarksOfUpakUTD(iMarkUpak as character, iDbNum as integer, iDocId as integer):

     define buffer upak_marking                for ub.marking .
     define buffer upak_utd-marking-lines      for ub.utd-marking-lines .
     define variable Marking as class mark no-undo .
     Marking = ObjSrv:Env:Marking:Sts:Mark.

     for each upak_marking no-lock where
              upak_marking.mark-parent = iMarkUpak
         ,first upak_utd-marking-lines no-lock where 
                upak_utd-marking-lines.mark   = upak_marking.mark 
            and upak_utd-marking-lines.db-num = iDbNum 
            and upak_utd-marking-lines.doc-id = iDocId
            and upak_utd-marking-lines.sts   <> Marking:Checked_:KeyIntDB
     :
       return no.
     end.
     return yes.
  end method.
 
  {utl/gtin.i class }
end class.
