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
        buf_marking.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB. .
        for first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.db-num = db-num and buf_utd-marking-lines.doc-id = doc-id
            and buf_utd-marking-lines.mark = buf_marking.mark:
              buf_utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB. .
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
method private void xmlchar-test (input  p-in-string          as character,
                                  output p-out-string-enc     as character,
                                  output p-out-string-dec    as character):
do
on error undo, return error
:
       xmlchar-encode
    (
          input p-in-string
        , output p-out-string-enc
    ).
       xmlchar-decode
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
method private void xmlchar-encode (input  p-in-string          as character,
                                  output p-out-string         as character):
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
method private character  xmlchar-encode-1c (input  p-in-string          as character):
define variable p-out-string as character no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
return p-out-string.
end .
method private void xmlchar-decode (input  p-in-string          as character,
                                  output p-out-string         as character):
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    xmlchar-read-integer
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
method private void xmlchar-read-integer (input  p-input-string       as character,
                                          output p-output-integer     as integer,
                                          output p-success            as logical):
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
method private logical IS-NeedMark
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
method private character repTegforDm
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo.
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
method private character repSpecSimbforDm
(iDM as char ):
    define variable oDM as character no-undo.
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
method private logical CheckGtin
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else
      vGtin = no.
   return vgtin.
end.
method private character repSpecSimbforXlm
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
method private character getGtinByDM
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7
      then
         vGtin = substring(vtxt,1,14).
   end.
   if not checkGtin(vGtin)
   then
      vGtin = "".
   return vgtin.
end.
method private integer getGdsCodeByGtin
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
method private decimal getQntyCodeByGtin
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
method private integer getGdsCodeByDM
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
method private logical ChekTypeMarkByGds
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code
                           and goods-attr.attr-code  = 'mark-type':U
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp
        .
   end.
   else
      return no.
end.
method private logical ChekTypeMarkByDm
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
method private logical ChekTypeMarkByGtin
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
method private character  GetNextElement
  (input iAllTeg        as logical
  ,output oteg          as character
  ,output otegval       as character
  ,input-output pstr    as character
   ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)".
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006".
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)".
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code.
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
     if iAllTeg
     then
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.
method private character  GetCodeIdent
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   for first marking no-lock where
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     return iDm.
   end.
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins 'tech_':U
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else
         oCodeIdent = iDM.
   end.
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.
end.
method private character  GetTegCod
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21"
      then
         oTeg = substring(icodeIdent,15,7).
   end.
   else do:
      ChekTypeMarkByDm(icodeIdent).
      block-teg:
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")"
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.
end.
method private logical isOAD
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
method private logical isMark
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
method private character  addBracketForCode
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define buffer marking for ub.marking.
   find first marking no-lock where
              marking.mark begins icodeIdent no-error.
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.
   else do:
      if (  icodeIdent begins "01"
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14))
         and substring (icodeIdent,17,2) eq "21"
      then do:
         mMRCCode = yes.
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.
   return oTeg.
end.
method private integer getlevelByCodId
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then
      Vlevel = 4.
   else if vLength eq 21
   then
      Vlevel = 1.
   else if vLength eq 25
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11"
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.
   else
      Vlevel = ?.
   return Vlevel.
end.
method private character  getLevelMotpBycodid
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
method private character    getLevelUTDByLevelMotp
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.
method private character  getLevelMotpByDM
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
method private character  getLevelUTDByCodId
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
method private character  getLevelUTDByDM
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
method private decimal getQntyUTDByCodId
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.
method private decimal getQntyUTDByDM
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25
      and length (iDm) ne 29
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.
method private decimal    getMRC4
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.
method private decimal    getMRCByDM
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.
method private date    MoveDate
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.
end.
method private logical    checkEMRC
(input  iDm as char,
 output vOk as logical):
   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code.
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).
            if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
         (
          input   vgds-code
         ,input   'emrc-type':U
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + chr(4) + v-value-emrc.
          find last code where Code.parent      eq vparent
                           and Code.code        le vDateIso
                           and code.status_  eq 0
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq 0 no-lock no-error.
              if available code
              then
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq 0
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq 0
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  chr(10),
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  chr(10),
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
          end.
       end.
   end.
end.
method private character addGs2Mark
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
   if index(iMark,chr(29),1) > 0
   then return iMark.
   if substring(iMark,26,4) = "8005" then
   do:
     vIdx = index(iMark,"93",26 + 4 + 5).
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.
     end.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "91" then
   do:
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
   return if vDM <> "" then vDm else iMark.
end.
end class.
