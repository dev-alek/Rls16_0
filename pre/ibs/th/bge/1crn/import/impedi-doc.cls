using ibs.th.bge.1crn.subjects.subjects.
using ibs.th.bge.1crn.subjects.edi-doc.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impedi-doc inherits ibs.th.gbl.sys.objth implements ibs.th.bge.1crn.import.iimpsubject :
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Импорт edi-doc" get.
method public integer AddOADLine
(iDb-num  as integer ,
 iDoc-id  as integer ,
 ilinenum as integer ,
 iGtin    as char,
 iQnty    as int,
 isite    as character ):
    define buffer utd-marking-lines      for ub.utd-marking-lines.
    define variable vnewMark as character no-undo.
    define variable vQnty    as integer   no-undo.
    vnewMark = "02" + iGtin + "37" + string(iQnty).
    find first utd-marking-lines where utd-marking-lines.mark       = vnewMark
                                   and utd-marking-lines.db-num     = idb-num
                                   and utd-marking-lines.doc-id     = idoc-id
                                   and utd-marking-lines.Linenum    = iLinenum
    exclusive-lock no-error.
    if available utd-marking-lines
    then do:
       delete utd-marking-lines.
       vQnty = AddOADLine(idb-num, idoc-id, iLinenum, iGtin, iQnty * 2 ,isite ).
    end.
    else do:
       create utd-marking-lines.
       assign
          utd-marking-lines.mark      = vnewMark
          utd-marking-lines.db-num    = idb-num
          utd-marking-lines.doc-id    = idoc-id
          utd-marking-lines.Linenum   = iLinenum
          utd-marking-lines.site      = isite
          utd-marking-lines.doc-level = 1
          utd-marking-lines.gds-code  = ?
       .
       vQnty = iQnty.
    end.
    return vQnty.
 end.
method public recid addMarkforUtd
(iDb-num  as integer ,
 iDoc-id  as integer ,
 ilinenum as integer ,
 iMark as character  ,
 isite   as character,
 iUtdType as character    ):
    define buffer     marking            for ub.marking.
    define buffer     marking-attr       for ub.marking-attr.
    define buffer utd-marking-lines      for ub.utd-marking-lines.
    define buffer utd-marking-lines-attr for ub.utd-marking-lines-attr.
    define variable vMRC  as decimal no-undo.
    define variable vQnty as decimal no-undo.
   define variable vRec as recid no-undo.
   if     imark ne "-"
      and imark ne ""
      and imark ne ?
   then do:
      imark = repTegforDm(imark).
      vQnty = getQntyUTDByCodId(imark) .
      find first utd-marking-lines where utd-marking-lines.mark       = imark
                                     and utd-marking-lines.db-num     = idb-num
                                     and utd-marking-lines.doc-id     = idoc-id
                                     and utd-marking-lines.Linenum    = iLinenum
      exclusive-lock no-error.
      if not available utd-marking-lines
      then do:
         create utd-marking-lines.
         assign
            utd-marking-lines.mark      = imark
            utd-marking-lines.db-num    = idb-num
            utd-marking-lines.doc-id    = idoc-id
            utd-marking-lines.Linenum   = iLinenum
            utd-marking-lines.site      = isite
            utd-marking-lines.doc-level = 1
            utd-marking-lines.gds-code  = ?
         .
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.mark      = imark
            utd-marking-lines-attr.db-num    = idb-num
            utd-marking-lines-attr.doc-id    = idoc-id
            utd-marking-lines-attr.Linenum   = iLinenum
            utd-marking-lines-attr.attr-code = "box-qnty"
            utd-marking-lines-attr.attr-value = string(vQnty)
         .
         vRec = recid(utd-marking-lines).
         release utd-marking-lines-attr.
         release utd-marking-lines.
      end.
      else do:
         if    (    isite eq "-"
            and utd-marking-lines.site eq "+")
         or (    isite eq "+"
            and utd-marking-lines.site eq "-")
         then
            delete utd-marking-lines.
         else if isOAD (imark)
         then do:
            vQnty = AddOADLine(idb-num, idoc-id, iLinenum, GetTegCod(imark,"02"), int(vQnty) ,isite ).
            create utd-marking-lines-attr.
            assign
               utd-marking-lines-attr.mark      = imark
               utd-marking-lines-attr.db-num    = idb-num
               utd-marking-lines-attr.doc-id    = idoc-id
               utd-marking-lines-attr.Linenum   = iLinenum
               utd-marking-lines-attr.attr-code = "box-qnty"
               utd-marking-lines-attr.attr-value = string(vQnty)
            .
         end.
         vRec = recid(utd-marking-lines).
         release utd-marking-lines.
      end.
      if isMark (imark)
      then do:
         find first marking where marking.mark eq iMark exclusive-lock no-error.
         if not available marking
         then do:
            create marking.
            marking.mark = iMark.
            marking.gds-code = ?.
            marking.unit     = getLevelUTDByCodId(marking.mark) .
         end.
         assign
           marking.unit-ext   = if marking.unit-ext = "" or marking.unit-ext = ? then
                                   getLevelMotpByCodId(marking.mark)
                                else marking.unit-ext
           marking.box-qnty   = vQnty
           marking.unit       = if marking.unit-ext = "LEVEL2" then "КИТУ" else getLevelUTDByCodId(marking.mark)
         .
         if        (     iUtdType eq "UniversalTransferDocument"
                  and marking.sts = objSrv:Env:marking:Sts:Mark:NotAvailable:KeyIntDB)
         then
            marking.sts = ?.
      end.
   end.
   return vRec.
end.
method public logical isSaleMarkInUpak
(iMark    as char ):
   define buffer buf_marking       for ub.marking.
   for each buf_marking no-lock where
            buf_marking.mark-parent = iMark
   :
     if can-do(objSrv:Env:marking:Sts:Mark:Sale_Return_Wait,string(buf_marking.sts)) or
        can-do(objSrv:Env:marking:Sts:Mark:Doc_Status,string(buf_marking.sts)) then
       return true.
     if isSaleMarkInUpak(buf_marking.mark) then
       return true.
   end.
   return false.
 end.
method public logical setStatusUpak
(iDbNum   as integer ,
 iDocId   as integer ,
 iLineNum as integer ,
 iMark    as char ,
 iSts     as integer):
   define buffer buf_utd-marking-lines for ub.utd-marking-lines.
   define buffer buf_marking           for ub.marking.
   for each buf_marking exclusive-lock where
            buf_marking.mark-parent = iMark,
      first buf_utd-marking-lines exclusive-lock where
            buf_utd-marking-lines.doc-id  = iDocId
        and buf_utd-marking-lines.db-num  = iDbNum
        and buf_utd-marking-lines.lineNum = iLineNum
        and buf_utd-marking-lines.mark = buf_marking.mark
   :
     setStatusUpak(iDbNum, iDocId, iLineNum, buf_marking.mark, iSts).
   end.
   for first buf_utd-marking-lines exclusive-lock where
             buf_utd-marking-lines.doc-id  = iDocId
         and buf_utd-marking-lines.db-num  = iDbNum
         and buf_utd-marking-lines.lineNum = iLineNum
         and buf_utd-marking-lines.mark = iMark,
       first buf_marking exclusive-lock where
             buf_marking.mark = buf_utd-marking-lines.mark
   :
     if  buf_marking.sts <> objSrv:Env:marking:Sts:Mark:MarkError:KeyIntDB
     then do:
       assign
         buf_utd-marking-lines.sts = iSts
         buf_marking.sts           = iSts
       .
     end.
   end.
   return true.
end.
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
method public char getattrUtdEx
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-attr  then iExValue    else  utd-attr.attr-value.
end.
method public char getattrUtd
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character ):
  return getattrUtdex(idb-num,idoc-id,iattrcode,?).
end.
method public void setattrUtd
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-attr
   then do:
      create utd-attr.
      assign
         utd-attr.db-num    = idb-num
         utd-attr.doc-id    = idoc-id
         utd-attr.attr-code = iattrcode
         utd-attr.attr-value = iattrval
      .
   end.
   else do:
      if utd-attr.attr-value ne iattrval
      then do:
         find current utd-attr exclusive-lock no-error.
         if available utd-attr
         then
            utd-attr.attr-value = iattrval.
      end.
   end.
   release utd-attr.
end.
method public char GetAttrUtdlinesEx
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-lines-attr  then iExValue    else  utd-lines-attr.attr-value.
end.
method public char GetAttrUtdlines
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character ):
   return GetAttrUtdlinesex (idb-num,idoc-id,ilinenum,iattrcode,?).
end.
method public void setattrUtdlines
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-lines-attr.
         assign
            utd-lines-attr.db-num    = idb-num
            utd-lines-attr.doc-id    = idoc-id
            utd-lines-attr.lineNum   = ilineNum
            utd-lines-attr.attr-code = iattrcode
            utd-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-lines-attr.attr-value ne iattrval
      then do:
         find current utd-lines-attr exclusive-lock no-error.
         if available utd-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-lines-attr.
            end.
            else do:
               utd-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-lines-attr.
end.
method public char GetAttrUtdMarkingLinesEx
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-marking-lines-attr  then iExValue    else  utd-marking-lines-attr.attr-value.
end.
method public char GetAttrUtdMarkingLines
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character ):
   return GetAttrUtdMarkingLinesEx (idb-num,idoc-id,ilinenum,imark,iattrcode,?).
end.
method public void setattrUtdMarkingLines
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-marking-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.db-num     = idb-num
            utd-marking-lines-attr.doc-id     = idoc-id
            utd-marking-lines-attr.lineNum    = ilineNum
            utd-marking-lines-attr.mark       = imark
            utd-marking-lines-attr.attr-code  = iattrcode
            utd-marking-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-marking-lines-attr.attr-value ne iattrval
      then do:
         find current utd-marking-lines-attr exclusive-lock no-error.
         if available utd-marking-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-marking-lines-attr.
            end.
            else do:
               utd-marking-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-marking-lines-attr.
end.
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "X(65)" no-undo
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
method private logical AddUtdErrForTab
(idb-num         as integer ,
 idoc-id         as integer ,
 iTab            as character,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   define buffer utd-err for utd-err.
   define buffer utd for utd.
   find first utd where utd.db-num     eq idb-num
                    and utd.doc-id     eq idoc-id
                    and utd.Direction  eq 'Outbound'
   no-lock no-error.
   if available utd
   then
      return no.
   define variable vRecKey as character no-undo.
         define variable objKeyRec as class ibs.th.gbl.keyrec no-undo.
         objKeyRec = new ibs.th.gbl.keyrec().
         objKeyRec:GenKeyRec ( input iTab
                              ,input iObj
                              ,output vRecKey).
         delete object objKeyRec.
   find first utd-err where utd-err.db-num     eq idb-num
                        and utd-err.doc-id     eq idoc-id
                        and utd-err.CheckType  eq iCheckType
                        and utd-err.CodeErr    eq iCodeErr
                        and utd-err.CheckObj   eq iCheckObj
   exclusive-lock no-error.
   if not available utd-err
   then do:
      create utd-err.
      assign
         utd-err.db-num         = idb-num
         utd-err.doc-id         = idoc-id
         utd-err.CheckType      = iCheckType
         utd-err.CodeErr        = iCodeErr
         utd-err.CheckObj       = if iCheckObj eq ? then "?" else iCheckObj
         utd-err.reckey         = vRecKey
         utd-err.qnty           = 1
      .
   end.
   else
      utd-err.qnty = utd-err.qnty + 1.
   return utd-err.qnty eq 1.
end.
method private logical AddUtdErr
(idb-num         as integer ,
 idoc-id         as integer ,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   AddUtdErrForTab
      (idb-num,
       idoc-id,
       iObj:table,
       iObj,
       iCheckType,
       iCodeErr,
       iCheckObj).
end.
method private void ClearUtdErrTypeCode
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character,
 iCodeErr        as character
 ):
   define buffer utd-err for utd-err.
   if    iCheckType eq "*"
      or iCheckType eq ?
   then do:
      if     iCodeErr ne ?
         and iCodeErr ne "*"
      then
         message "Задан код ошибки " iCodeErr " для удаления, но не задан тип"
         view-as alert-box.
      else
      for each utd-err where utd-err.db-num  eq idb-num
                         and utd-err.doc-id  eq idoc-id
      exclusive-lock:
         delete utd-err.
      end.
   end.
   else do:
      if    iCodeErr eq ?
         or iCodeErr eq "*"
      then do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
         exclusive-lock:
            delete utd-err.
         end.
      end.
      else do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
                            and ub.utd-err.CodeErr eq iCodeErr
         exclusive-lock:
            delete utd-err.
         end.
      end.
   end.
end.
method private void ClearUtdErr
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   ClearUtdErrTypeCode(idb-num,idoc-id,iCheckType,?).
end.
method private character GetMesError
(itxt as character,
 iobj as character ):
 define variable vi as integer no-undo.
 do vi = num-entries(iobj ,chr(4) ) to 1 by -1 :
    itxt = replace(itxt,"&" + string(vi),entry(vi,iobj,chr(4))).
 end.
 return itxt.
end.
method private character GetTextErrorType
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 iType      as character  ):
   define buffer code    for code.
   define variable vError as character no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if available code
   then do:
      define variable vType as integer no-undo.
      if code.misc3 eq "error"
      then
         vType = 0.
      else if code.misc3 eq "warning"
      then
         vType = 1.
      else if code.misc3 eq "Hiden"
      then
         vType = 2.
      else
         vtype = int(code.misc3) no-error.
      case itype:
         when "error"
         then do:
            if vtype eq 0
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         when "warning"
         then do:
            if vtype <= 1
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         otherwise do:
            vError = GetMesError(Code.CodeValue,iChechObj).
         end.
      end.
   end.
   else
      vError =  iCodeErr + ":" + replace (iChechObj,chr(4),"|").
   return vError.
end.
method private integer  GetTypeError
(iCheckType as character,
 iCodeErr   as character):
   define buffer code    for code.
   define variable vType as integer no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     not available code
      and code.misc3 eq "error"
   then
      vType = 0.
   else if code.misc3 eq "warning"
   then
      vType = 1.
   else if code.misc3 eq "Hiden"
   then
      vType = 2.
   else
      vtype = int(code.misc3) no-error.
   return vtype.
end.
method private character GetTextError
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character ):
   return GetTextErrortype(iCheckType,iCodeErr,iChechObj,"warning").
end.
method private character GetErrForUtdstr
(idb-num     as integer ,
 idoc-id     as integer ,
 iCheckType  as character
 ):
   define buffer utd-err for utd-err.
   define buffer code    for code.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable vErrorOne as longchar  no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ""
         and vErrorOne ne ?
      then
         vError = vError + ", " + vErrorOne.
      vHQry:get-next().
   end.
   oError = substring(vError,3,4002).
   return oError.
end.
method private character GetErrJsonForUtd
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектОш":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
      vHQry:get-next().
   end.
   for first utd where utd.db-num eq idb-num
                   and utd.doc-id eq idoc-id
                   and utd.sts    eq ObjSrv:Env:Utd:Sts:th:DeliveryCodeMismatch:KeyIntDB
   no-lock,
      each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                               and utd-marking-lines.doc-id eq idoc-id
                               and utd-marking-lines.doc-level eq 1
   no-lock,
      first marking where marking.mark eq utd-marking-lines.mark
                      and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
   no-lock:
      vErrorOne = GetTextErrortype("CheckShip","NotMark",marking.mark,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + "CheckShip" + "_" + "NotMark"
                         + '","ОбъектОш":"' + marking.mark
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
   end.
   if vError ne ""
   then
      oError = '"Ошибки":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
method private character GetErrJsonForUtdReturn
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   define variable vi as integer no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Возврат_' + string(vi) +  '":~{"КодВозр":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектВозр":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстВозр":"' + GetTextError(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj) + '"}'.
      end.
      vHQry:get-next().
   end.
   if vError ne ""
   then
      oError = '"Возвраты":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
method private character GetCodeTextError
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 output oCode as character,
 output ovalue as character ):
   define buffer code    for code.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     available code
   then do:
      define variable vi as integer no-undo init ?.
      vi = int(Code.misc3) no-error.
      if    code.misc3 ne "error"
         and vi ne 0
      then
         oCode = ?.
      else if     Code.misc1 ne ?
              and Code.misc1 ne ""
      then
         assign
            oCode  = GetMesError(Code.misc1,iChechObj)
            ovalue = GetMesError(Code.misc2,iChechObj)
         .
   end.
   return if oCode eq ""
          then ""
          else (oCode + "_" + ovalue).
end.
define temp-table TT-err no-undo
  field code_ as character
  field text_ as character
index code_ code_.
method private character GetErrTxtForUtd
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   for each tt-err :
      delete tt-err.
   end.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   define variable vcode as character no-undo.
   define variable vvalue as character no-undo.
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vi = vi + 1.
      GetCodeTextError (utd-err.CheckType, utd-err.CodeErr, utd-err.CheckObj, output vcode, output vvalue).
      if vcode ne ?
      then do:
         find first tt-err where tt-err.code eq vcode
         no-error.
         if not available tt-err
         then do:
            create tt-err.
            assign
               tt-err.code_ = vcode
               tt-err.text_ = vvalue
            .
         end.
         else
            tt-err.text_ = tt-err.text_ + "||" + vvalue.
      end.
      vHQry:get-next().
   end.
  find first utd where utd.db-num eq idb-num
                      and utd.doc-id eq idoc-id
      no-lock.
   define buffer cancel_utd-lines for utd-lines.
   for each cancel_utd-lines where cancel_utd-lines.db-num eq idb-num
                               and cancel_utd-lines.doc-id eq idoc-id
   no-lock:
      if logical(getattrutdlinesex  (idb-num,idoc-id,cancel_utd-lines.LineNum,"MarkUtdLine"        ,"no"))
      then do:
         for   each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                                     and utd-marking-lines.doc-id eq idoc-id
                                     and utd-marking-lines.LineNum eq cancel_utd-lines.LineNum
         no-lock,
            first marking where marking.mark eq utd-marking-lines.mark
                            and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
         no-lock:
            GetCodeTextError ("CheckShip", "MARKDECLINED", utd-marking-lines.mark + chr(4) + string(utd-marking-lines.LineNum), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
      else do:
         define variable vqnty as decimal no-undo.
         vqnty = decimal(GetAttrUtdlines(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode")).
         if vqnty eq ? then vqnty = 0.
         if vqnty ne cancel_utd-lines.Quantity
         then do:
            GetCodeTextError ("CheckShip", "NotAcceptQuantity", string(cancel_utd-lines.LineNum) + chr(4) + string(cancel_utd-lines.Quantity - vqnty), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
   end.
   for each tt-err:
      oError = oError + substitute("&1|&2|",tt-err.code_ , tt-err.text_ ) + chr(13) + chr(10) .
   end.
   return oError.
end.
define variable mFormatErr as character no-undo init "text".
method private character GetErrForUtd
(idb-num         as integer ,
 idoc-id         as integer ,
 iType           as character
 ):
   if mFormatErr eq "text"
   then
      return GetErrTxtForUtd(idb-num,idoc-id,iType).
   else do:
      if itype eq "return"
      then return GetErrJsonForUtdReturn (idb-num,idoc-id,iType).
      else return GetErrJsonForUtd(idb-num,idoc-id,iType).
   end.
end.
method private longchar GetErrComText
(icomment as character,
 itext    as longchar ):
    define variable vText as longchar no-undo.
   if mFormatErr eq "text"
   then do:
      if icomment ne ""
      then
         icomment = substitute("comment:|&1|",icomment).
      vText = icomment + itext.
   end.
   else do:
      icomment = if icomment begins  '"'
                 then icomment
                 else  if icomment eq "" then "" else ( '"Коментрии":~{"Коментарий":"' + icomment  + '"}') .
      vText = icomment + "," + itext.
      vText = "~{" + trim(vText,",") + "~}".
   end.
   return vText.
end.
method private logical  CheckTypeForMarkLineType
(iObj            as handle,
 iCheckType      as character,
 iCodeErr        as character ,
 iTypeErr        as character ):
   define variable vRecKey-markLine as character no-undo.
   define variable vGoodMark        as logical no-undo.
   define variable vdb-num          as integer no-undo.
   define variable vdoc-id          as integer no-undo.
   define variable vlinenum         as integer no-undo.
   define variable vErrorOne as character no-undo.
   define buffer buf_utd-err for utd-err.
    define variable objKeyRec as class ibs.th.gbl.keyrec no-undo.
    objKeyRec = new ibs.th.gbl.keyrec().
    objKeyRec:GenKeyRec ( input "utd-marking-lines"
                         ,input iObj
                         ,output  vRecKey-markLine).
    delete object objKeyRec.
   vGoodMark = yes.
   vdb-num = iObj::db-num.
   vdoc-id = iObj::doc-id.
   vlinenum = iObj::linenum.
   block-mark-err:
   for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                            and buf_utd-err.db-num = vdb-num
                            and buf_utd-err.reckey = vRecKey-markLine
                            and if iCheckType  eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                            and if iCodeErr    eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
   no-lock:
      vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vGoodMark = no.
         leave block-mark-err.
      end.
   end.
   return not vGoodMark.
end.
method private logical  CheckErrForMarkLineType
(iObj            as handle,
 iType           as character  ):
   return CheckTypeForMarkLineType (iObj,iType,"*","error").
end.
method private logical  CheckErrForMarkLine
(iObj            as handle):
   return CheckErrForMarkLineType(iObj,"*").
end.
method private logical  CheckErrForLineTypeCode
(iObj                 as handle,
 iCheckType           as character,
 iCodeErr             as character,
 iTypeErr             as character,
 iOneErr              as logical):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
         define variable objKeyRec as class ibs.th.gbl.keyrec no-undo.
         objKeyRec = new ibs.th.gbl.keyrec().
         objKeyRec:GenKeyRec ( input "utd-lines"
                              ,input iObj
                              ,output vRecKey-line).
         delete object objKeyRec.
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iCheckType eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                               and if iCodeErr   eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            vUtdlineError = yes.
            leave block-err.
         end.
      end.
      if  not vUtdlineError
      then do:
         define variable vGoodMark as logical no-undo.
         vGoodMark = yes.
         block-line-err:
         for each utd-marking-lines where utd-marking-lines.db-num  eq vdb-num
                                      and utd-marking-lines.doc-id  eq vdoc-id
                                      and utd-marking-lines.LineNum eq vLineNum
         no-lock:
            vGoodMark = not CheckTypeForMarkLineType(buffer utd-marking-lines:handle,iCheckType,iCodeErr,iTypeErr).
            if     vGoodMark
               and iOneErr eq no
            then
               leave block-line-err.
            if     iOneErr = yes
               and not vGoodMark
            then
               leave block-line-err.
         end.
         vUtdlineError = not vGoodMark.
      end.
   return vUtdlineError.
end.
method private character   getErrForLineType
(iObj            as handle,
 iType           as character  ):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
   define variable oError as character no-undo.
         define variable objKeyRec as class ibs.th.gbl.keyrec no-undo.
         objKeyRec = new ibs.th.gbl.keyrec().
         objKeyRec:GenKeyRec ( input "utd-lines"
                              ,input iObj
                              ,output vRecKey-line).
         delete object objKeyRec.
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iType eq "*" or iType eq ? then yes else buf_utd-err.CheckType = iType
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,"error").
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            oError = oError + vErrorOne + " ".
         end.
      end.
   return oError.
end.
method private logical  CheckErrForLineType
(iObj            as handle,
 iType           as character  ):
    return CheckErrForLineTypeCode (iObj,itype,"*","error",no).
end.
method private logical  CheckErrForLine
(iObj            as handle):
   return CheckErrForLineType(iobj,"*").
end.
method private logical  CheckErrForUtd
(idb-num         as integer ,
 idoc-id         as integer ):
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock :
      if not CheckErrForLine (buffer ub.utd-lines:handle)
      then
         return no.
   end.
   return yes.
end.
method public logical CheckMarkUtd-28rel
 (input idb-num as integer,
 input idoc-id as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vgdsNoMark as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num eq idb-num
                              and utd-lines.doc-id eq idoc-id
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               if     EDOParSec:IsEdo
                  and EDOParSec:GetIsEDOForType(v-par-val)
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                                 and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                                 and utd-marking-lines.LineNum eq utd-lines.LineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if     avail utd-marking-lines
                     and not CheckErrForLine(buffer utd-lines:handle)
                  then
                     leave Block-utd-lines.
               end.
               else
                  vgdsNoMark = yes.
            end.
         end.
         setattrutd (utd.db-num,utd.doc-id,"MarkUtd",if vgdsNoMark then string(available utd-lines) else "yes").
         if vgdsNoMark then return available utd-lines . else return yes .
      end.
   end.
   return yes.
end.
  def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-utd-mark no-undo like utd-marking-lines
  field side as character.
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
method public logical CheckMarkUtd
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  block-line:
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","yes"))
     then
        leave block-line.
  end.
  setattrutd (idb-num, idoc-id,"MarkUtd",string(available utd-lines)).
  return available utd-lines.
end.
method public logical CheckNotMarkUtd
 (input idb-num  as integer,
  input idoc-id  as integer):
  define buffer utd-lines             for ub.utd-lines.
  for each utd-lines where utd-lines.db-num eq idb-num
                       and utd-lines.doc-id eq idoc-id
  no-lock:
     if not logical(getAttrUtdLinesEx (utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
     then
        return yes.
  end.
  return no.
end.
method public logical CheckMarkUtdLine
 (input idb-num  as integer,
  input idoc-id  as integer,
  input iLineNum as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vMarking        as logical no-undo.
 define variable vArtic          as logical no-undo.
 define variable vTransitional   as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num   eq idb-num
                              and utd-lines.doc-id   eq idoc-id
                              and utd-lines.LineNum  eq iLineNum
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               vMarking = EDOParSec:GetIsEDOForType(v-par-val).
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val).
               if vMarking
               then do:
                  block-marking:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isOAD(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = yes
                           vMarking = no
                        .
                        leave block-marking.
                     end.
                  end.
               end.
               if vArtic
               then do:
                  block-artic:
                  for each   utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock:
                     if isMark(utd-marking-lines.mark)
                     then do:
                        assign
                           vArtic   = no
                           vMarking = yes
                        .
                        leave block-artic.
                     end.
                  end.
               end.
               vTransitional = (vMarking or vArtic) and EDOParSec:GetIsTransitionalForType(v-par-val).
               if vTransitional
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num   eq idb-num
                                                 and utd-marking-lines.doc-id   eq idoc-id
                                                 and utd-marking-lines.LineNum  eq iLineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if not available utd-marking-lines
                  then assign
                     vMarking = no
                     vArtic   = no
                  .
               end.
            end.
            else
               assign
                  vMarking      = yes
                  vArtic        = no
                  vTransitional = no
               .
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"MarkUtdLine"         ,if vMarking      then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"ArticUtdLine"        ,if vArtic        then "yes" else "").
            setattrutdlines  (utd.db-num,utd.doc-id,iLineNum,"TransitionalUtdLine" ,if vTransitional then "yes" else "").
         end.
      end.
   end.
   return vMarking or vArtic.
end.
method public logical getMarkUtdLine
 (input  idb-num  as integer,
  input  idoc-id  as integer,
  input  iLineNum as integer,
  output oMarking        as logical,
  output oArtic          as logical,
  output oTransitional   as logical):
  oMarking = logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"MarkUtdLine"        ,"no")).
  oArtic        = not oMarking
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"ArticUtdLine"       ,"no")).
  oTransitional = (oMarking or oArtic)
         and logical(getattrutdlinesex  (idb-num,idoc-id,iLineNum,"TransitionalUtdLine","no")).
end.
method public logical CheckMarking
 (input idb-num as integer,
 input idoc-id as integer,
 input iTypeErr as character ):
  define variable vMarkutd as logical no-undo.
  define variable vCrErr   as logical no-undo.
  define buffer utd-lines         for utd-lines.
  define buffer utd-marking-lines for utd-marking-lines.
  define buffer marking           for marking.
  ClearUtdErrTypeCode(idb-num,idoc-id,iTypeErr,"NotMark").
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      if logical (getAttrUtdLinesEx(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"MarkUtdLine","no"))
      then do:
         for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
         no-lock:
            if isMark(utd-marking-lines.mark)
            then do:
               find first marking where marking.mark eq utd-marking-lines.mark
               no-lock no-error.
               if not available marking
               then do:
                  AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iTypeErr,"NotMark",string(utd-lines.LineNum)).
                  vCrErr = yes.
                  next block-line.
               end.
            end.
         end.
      end.
   end.
   return vCrErr.
end.
method public logical CheckMarkForType
 (input idb-num   as integer,
  input idoc-id   as integer):
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define buffer utd-lines         for utd-lines.
   define buffer utd-marking-lines for utd-marking-lines.
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      getMarkUtdLine  (input  utd-lines.db-num , input  utd-lines.doc-id, input  utd-lines.LineNum,
                       output vMarking         , output vArtic          , output vTransitional).
      for each utd-marking-lines
                  where utd-marking-lines.db-num  = utd-lines.db-num
                    and utd-marking-lines.doc-id  = utd-lines.doc-id
                    and utd-marking-lines.LineNum = utd-lines.LineNum
      no-lock:
         if length(utd-marking-lines.mark) < 14
         then do:
            if (vMarking or vArtic) and not vTransitional
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else if not isMark(utd-marking-lines.mark)
         then do:
            if vMarking
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"loadUtd","NotMark",utd-marking-lines.mark).
         end.
         else do:
         end.
      end.
   end.
end.
method public logical WeighedProd
   ( input p-gds-code as integer) :
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
           if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
            ( p-gds-code,
              'weighed-gds':U,
               output v-par-val,
               output v-par-type
            ).
   return logical(v-par-val).
end.
method public logical WghProdVariable
    (input p-obj-type as char,
     input p-obj-code as integer,
     input p-gds-code as integer) :
   define variable v-wgh-val  as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable v-par-type as character no-undo.
   define variable vMarking        as logical no-undo.
   define variable vArtic          as logical no-undo.
   define variable vTransitional   as logical no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
      if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
        ( p-gds-code,
          'weighed-gds':U,
           output v-wgh-val,
           output v-par-type
        ).
    if logical(v-wgh-val) = yes then do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
            ( p-gds-code,
              'mark-type':U,
               output v-par-val,
               output v-par-type
            ).
        if v-par-val <> "" then do:
            EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(p-obj-type, p-obj-code).
            assign
               vMarking = EDOParSec:GetIsEDOForType(v-par-val)
               vArtic = not vMarking and EDOParSec:GetIsArticForType(v-par-val)
               .
        end.
   end.
   if v-wgh-val > "" and (vMarking or vArtic)
   then return yes.
   else return no.
end.
method public decimal MarkWeight
   ( input p-mark as character) :
   define buffer  buf_marking-attr for  ub.marking-attr.
   define variable vMarkWeight as decimal no-undo.
   vMarkWeight = 0.
   if p-mark <> "" and p-mark <> ?
   then do:
       find first buf_marking-attr where buf_marking-attr.mark      eq p-mark
                                     and buf_marking-attr.attr-code eq "weight"
          no-lock no-error.
       if not available buf_marking-attr
       then do :
         find first buf_marking-attr where buf_marking-attr.mark  begins p-mark
                                       and buf_marking-attr.attr-code eq "weight"
            no-lock no-error.
       end .
       if avail buf_marking-attr
       then vMarkWeight = dec(buf_marking-attr.attr-value).
   end.
   return vMarkWeight.
end.
method public void CheckQnty
(  input idb-num  as integer,
   input idoc-id  as integer,
   input iErrType as character
):
   if iErrType ne "loadUTD"
   then do:
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","MarkNotFormatqnty").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","QntyMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","Qnty").
   end.
   if iErrType ne "CheckQnty"
   then do:
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckQnty","MarkNotFormatqnty").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckQnty","QntyMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckQnty","Qnty").
   end.
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"QntyMark").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"MarkNotFormatqnty").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"Qnty").
   define buffer marking               for marking.
   define buffer utd-lines             for utd-lines.
   define buffer utd-marking-lines     for utd-marking-lines.
   define buffer Buf_utd-marking-lines for utd-marking-lines.
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      define variable Vflagmark as logical no-undo.
      find first buf_utd-marking-lines
                    where buf_utd-marking-lines.db-num   = utd-lines.db-num
                      and buf_utd-marking-lines.doc-id   = utd-lines.doc-id
                      and buf_utd-marking-lines.LineNum  = utd-lines.LineNum
                      and length(buf_utd-marking-lines.mark) > 13
      no-lock no-error.
      if not available buf_utd-marking-lines
      then
         next block-line.
      define variable vqntyMark as integer no-undo.
      define variable vqntyOAD  as integer no-undo.
      vqntyMark = 0.
      vqntyOAD  = 0.
      block-mark:
      for each utd-marking-lines
           where utd-marking-lines.db-num  = utd-lines.db-num
             and utd-marking-lines.doc-id  = utd-lines.doc-id
             and utd-marking-lines.LineNum = utd-lines.LineNum
             and length(utd-marking-lines.mark) > 13
             and utd-marking-lines.doc-level  = 1
      no-lock:
         if isMark(utd-marking-lines.mark)
         then do:
            find first marking where marking.mark eq utd-marking-lines.mark
            no-lock no-error.
            if available marking
            then do:
               if marking.box-qnty ne ?
               then
                  vqntyMark = vqntyMark + marking.box-qnty.
            end.
         end.
         else do:
            find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq utd-marking-lines.db-num
                                                and utd-marking-lines-attr.doc-id    eq utd-marking-lines.doc-id
                                                and utd-marking-lines-attr.LineNum   eq utd-marking-lines.LineNum
                                                and utd-marking-lines-attr.mark      eq utd-marking-lines.mark
                                                and utd-marking-lines-attr.attr-code eq "box-qnty"
            no-lock no-error.
            if available utd-marking-lines-attr
            then
               vqntyOAD = vqntyOAD + dec(utd-marking-lines-attr.attr-value).
         end.
      end.
      if     utd-lines.gds-code   gt 0
         and utd-lines.gds-code   ne ?
         and vqntyMark            ne 0
      then do:
         if utd-lines.Quantity  < vqntyMark
         then
            AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"Qnty",string(utd-lines.LineNum ) + chr(4) + string(utd-lines.Quantity ) + chr(4) + string(vqntyMark)).
         else if utd-lines.Quantity  <> vqntyMark
         then
            AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"QntyMark",string(utd-lines.LineNum ) + chr(4) + string(utd-lines.Quantity ) + chr(4) + string(vqntyMark)).
      end.
      else if     utd-lines.gds-code   gt 0
         and utd-lines.gds-code   ne ?
         and vqntyOAD ne 0
         and utd-lines.Quantity  ne vqntyOAD
      then
         AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"Qnty",string(utd-lines.LineNum ) + chr(4) + string(utd-lines.Quantity ) + chr(4) + string(vqntyOAD)).
   end.
end.
method public void CheckGds
(  input idb-num   as integer,
   input idoc-id   as integer,
   input iobj-type as character,
   input iobj-code as integer,
   input iErrType as character
):
   if iErrType ne "loadUTD"
   then do:
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","InLineNotMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NoGtinForMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NoBarcodForGtin").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","MarkNotFormatqnty").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","MarkingForTypeEDO").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NotMarkForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","MultGtinForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NoBarCodeForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NotFindGdsForBarCode").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","NotEqGgsForLineAndMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"loadUTD","GtinQntyNotOne").
   end.
   if iErrType ne "CheckGds"
   then do:
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","InLineNotMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NoGtinForMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NoBarcodForGtin").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","MarkNotFormatqnty").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","MarkingForTypeEDO").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NotMarkForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","MultGtinForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NoBarCodeForLine").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NotFindGdsForBarCode").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","NotEqGgsForLineAndMark").
      ClearUtdErrTypeCode(idb-num,idoc-id,"CheckGds","GtinQntyNotOne").
   end.
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"InLineNotMark").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NoGtinForMark").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NoBarcodForGtin").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"MarkNotFormatqnty").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"MarkingForTypeEDO").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NotMarkForLine").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"MultGtinForLine").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NoBarCodeForLine").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NotFindGdsForBarCode").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"NotEqGgsForLineAndMark").
   ClearUtdErrTypeCode(idb-num,idoc-id,iErrType,"GtinQntyNotOne").
   define variable v-par-type as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define buffer marking               for marking.
   define buffer utd-lines             for utd-lines.
   define buffer buf_utd-lines         for utd-lines.
   define buffer utd-marking-lines     for utd-marking-lines.
   define buffer Buf_utd-marking-lines for utd-marking-lines.
   define variable vGdsCode as integer no-undo.
   EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(iobj-type, iobj-code).
   block-line:
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock:
      vGdsCode = ?.
      define variable Vflagmark as logical no-undo.
      define variable VflagOAD  as logical no-undo.
      assign
         Vflagmark = no
         VflagOAD = no
      .
      block-mark:
      for each utd-marking-lines
               where utd-marking-lines.db-num  = utd-lines.db-num
                 and utd-marking-lines.doc-id  = utd-lines.doc-id
                 and utd-marking-lines.LineNum = utd-lines.LineNum
      no-lock:
         if    isMark(utd-marking-lines.mark)
            or isOAD (utd-marking-lines.mark)
         then do:
            define variable vnewGdsCode as integer no-undo.
            vnewGdsCode = getGdsCodeByDM(utd-marking-lines.mark).
            if isMark(utd-marking-lines.mark)
            then do:
               Vflagmark = yes.
               find first marking where marking.mark eq utd-marking-lines.mark
               no-lock no-error.
               if not available marking
               then do:
                  AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"InLineNotMark",utd-marking-lines.mark).
                  next block-mark.
               end.
               if vnewGdsCode eq ?
               then
                  vnewGdsCode = GetGdsCodeByGtin(marking.gds-ext-id).
               if    marking.gds-code eq 0
                  or marking.gds-code eq ?
                  or marking.sts eq 0
                  or marking.sts eq ?
                  or marking.box-qnty eq ?
                  or (marking.gds-code ne vnewGdsCode
                      and vnewGdsCode ne ?
                      and vnewGdsCode ne 0)
               then do:
                  find first marking where marking.mark eq utd-marking-lines.mark
                  exclusive-lock no-error.
                  if marking.box-qnty = ? then marking.box-qnty = getQntyUTDByDM(marking.mark).
                  if marking.gds-ext-id = "" then marking.gds-ext-id = getGtinByDM(marking.mark).
                  if marking.gds-code = ? or marking.gds-code ne vnewGdsCode then marking.gds-code = vnewGdsCode.
                  if    marking.gds-ext-id eq ""
                     or marking.gds-ext-id eq ?
                  then do:
                     AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"NoGtinForMark",string(utd-lines.LineNum ) + chr(4) + marking.mark).
                  end.
                  else if    marking.gds-code eq 0
                          or marking.gds-code eq ?
                  then
                     AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"NoBarcodForGtin",string(utd-lines.LineNum ) + chr(4) + marking.gds-ext-id).
                  else if     marking.sts eq 0
                          or  marking.sts eq ?
                  then
                     marking.sts = objSrv:Env:marking:Sts:Mark:PendingVerification:KeyIntDB.
               end.
               if utd-marking-lines.doc-level eq 1
               then do:
                  if marking.box-qnty eq ?
                  then
                     AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"MarkNotFormatqnty",string(utd-lines.LineNum ) + chr(4) + utd-marking-lines.mark).
               end.
            end.
            else do:
               VflagOAD = yes.
               define variable vQnty as decimal no-undo.
               vQnty = getQntyUTDByCodId(utd-marking-lines.mark) .
               setAttrUtdMarkingLines (utd-marking-lines.db-num,
                                       utd-marking-lines.doc-id,
                                       utd-marking-lines.LineNum,
                                       utd-marking-lines.mark,
                                       "box-qnty",
                                        string(vQnty)).
               define variable vgtin as character no-undo.
               vgtin = getGtinByDM(utd-marking-lines.mark).
               if getQntyCodeByGtin(vgtin) ne 1
               then
                  AddUtdErr(utd-marking-lines.db-num,utd-marking-lines.doc-id,buffer utd-marking-lines:handle,iErrType,"GtinQntyNotOne",string(utd-lines.LineNum ) + chr(4) + vgtin).
            end.
            if utd-marking-lines.gds-code ne vnewGdsCode
            and vnewGdsCode ne ?
            and vnewGdsCode ne 0
            then do:
               find first buf_utd-marking-lines
                        where buf_utd-marking-lines.db-num   = utd-marking-lines.db-num
                          and buf_utd-marking-lines.doc-id   = utd-marking-lines.doc-id
                          and buf_utd-marking-lines.LineNum  = utd-marking-lines.LineNum
                          and buf_utd-marking-lines.mark     = utd-marking-lines.mark
               exclusive-lock no-error.
               if available buf_utd-marking-lines
               then do:
                  buf_utd-marking-lines.gds-code = vnewGdsCode.
               end.
            end.
         end.
         else  do:
            define variable vgdsbar as integer no-undo.
            vgdsbar = GetGdsCodeByGtin(utd-marking-lines.mark).
            if    utd-marking-lines.gds-code ne vgdsbar
            then do:
               find first buf_utd-marking-lines
                          where buf_utd-marking-lines.db-num   = utd-marking-lines.db-num
                            and buf_utd-marking-lines.doc-id   = utd-marking-lines.doc-id
                            and buf_utd-marking-lines.LineNum  = utd-marking-lines.LineNum
                            and buf_utd-marking-lines.mark     = utd-marking-lines.mark
               exclusive-lock no-error.
               if available buf_utd-marking-lines
               then do:
                  buf_utd-marking-lines.gds-code = vgdsbar.
               end.
            end.
            if vgdsbar ne ?
            then do:
                              if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
                         ( vgdsbar,
                           'mark-type':U,
                           output v-par-val,
                           output v-par-type
                          ).
               if      (EDOParSec:GetIsEDOForType(v-par-val)
                    or  EDOParSec:GetIsArticForType(v-par-val))
                and not EDOParSec:GetIsTransitionalForType(v-par-val)
                and     EDOParSec:IsEdo
               then do:
                  AddUtdErr(utd-marking-lines.db-num,
                            utd-marking-lines.doc-id,
                            buffer utd-marking-lines:handle,
                            iErrType,
                            "MarkingForTypeEDO",
                            string(utd-lines.LineNum ) + chr(4) + utd-marking-lines.mark).
               end.
            end.
         end.
         if vGdsCode eq ?
         then
            vGdsCode = utd-marking-lines.gds-code.
         if vGdsCode ne utd-marking-lines.gds-code
         and utd-marking-lines.gds-code > 0
         then do:
            vGdsCode = -1.
         end.
      end.
      if  vGdsCode = -1
      then do:
         vGdsCode = ?.
         AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"MultGtinForLine",string(utd-lines.LineNum )).
         next block-line.
      end.
      if vGdsCode ne ?
      then do:
                  if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
                   ( vGdsCode,
                     'mark-type':U,
                     output v-par-val,
                     output v-par-type
                    ).
         if   not EDOParSec:GetIsTransitionalForType(v-par-val)
             and(
              (    EDOParSec:GetIsEDOForType(v-par-val)
                  and not Vflagmark)
              or  (EDOParSec:GetIsArticForType(v-par-val)
                  and not VflagOAD
                  and not Vflagmark))
         then do:
            AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"NotMarkForLine",string(utd-lines.LineNum)).
         end.
      end.
      if utd-lines.gds-code ne vGdsCode
      then do:
         find first  buf_utd-lines where buf_utd-lines.db-num  eq utd-lines.db-num
                                     and buf_utd-lines.doc-id  eq utd-lines.doc-id
                                     and buf_utd-lines.LineNum eq utd-lines.LineNum
         exclusive-lock no-error.
         if available buf_utd-lines
         then
            buf_utd-lines.gds-code = vGdsCode.
         release buf_utd-lines.
      end.
      define variable VBarCode as character no-undo.
      VBarCode = getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"BarCode").
      if VBarCode ne ?
      then do:
         if num-entries(VBarCode," ") > 0
         then
            VBarCode = entry(num-entries(VBarCode," "),VBarCode," ").
         vgdsbar = GetGdsCodeByGtin(VBarCode).
         if vgdsbar eq ? or vgdsbar eq 0
         then do:
            AddUtdErr(utd-lines.db-num,
                      utd-lines.doc-id,
                      buffer utd-lines:handle,
                      iErrType,
                      "NotFindGdsForBarCode",
                      string(utd-lines.LineNum ) + chr(4) + VBarCode).
         end.
         else do:
            if    utd-lines.gds-code eq ?
               or utd-lines.gds-code eq 0
            then do:
               find first  buf_utd-lines where buf_utd-lines.db-num  eq utd-lines.db-num
                                           and buf_utd-lines.doc-id  eq utd-lines.doc-id
                                           and buf_utd-lines.LineNum eq utd-lines.LineNum
               exclusive-lock no-error.
               if available buf_utd-lines
               then
                  buf_utd-lines.gds-code = vgdsbar.
               release buf_utd-lines.
            end.
            else if utd-lines.gds-code ne vgdsbar
            then do:
               AddUtdErr(utd-lines.db-num,
                      utd-lines.doc-id,
                      buffer utd-lines:handle,
                      iErrType,
                      "NotEqGgsForLineAndMark",
                      string(utd-lines.LineNum ) + chr(4) + String(vgdsbar) + chr(4) + String(utd-lines.gds-code)).
            end.
         end.
      end.
      if vGdsCode eq ? and utd-lines.gds-code eq ?
      then
         AddUtdErr(utd-lines.db-num,utd-lines.doc-id,buffer utd-lines:handle,iErrType,"NoBarCodeForLine",string(utd-lines.LineNum )).
   end.
end.
method public logical GetUtdLineForOrig
(input idb-num as integer,
 input idoc-id as integer,
 input ilineNum as integer,
 input idb-numOrig as integer,
 input idoc-idOrig as integer,
 buffer edoc-lines for utd-lines):
   define buffer edoc-marking-lines for ub.utd-marking-lines.
   block-mark:
   for each utd-marking-lines where utd-marking-lines.db-num  eq idb-num
                                and utd-marking-lines.doc-id  eq idoc-id
                                and utd-marking-lines.LineNum eq iLineNum
                                and utd-marking-lines.site eq "-"
   no-lock:
      find first edoc-marking-lines where edoc-marking-lines.db-num eq idb-numOrig
                                      and edoc-marking-lines.doc-id eq idoc-idOrig
                                      and edoc-marking-lines.mark   eq utd-marking-lines.mark
                  no-lock no-error.
      if available edoc-marking-lines
      then do:
         find first edoc-lines where edoc-lines.db-num      = edoc-marking-lines.db-num
                                 and edoc-lines.doc-id            = edoc-marking-lines.doc-id
                                 and edoc-lines.LineNum           = edoc-marking-lines.LineNum
         no-lock no-error.
            leave block-mark.
       end.
   end.
    if not available edoc-lines
    then do:
       find  first  utd-lines where utd-lines.db-num      = idb-num
                                and utd-lines.doc-id      = idoc-id
                                and utd-lines.LineNum     = ilinenum
          no-lock no-error.
       find  edoc-lines where edoc-lines.db-num      = idb-numOrig
                               and edoc-lines.doc-id      = idoc-idOrig
                               and edoc-lines.ProductCode = utd-lines.ProductCode
       no-lock no-error.
    end.
    if not available edoc-lines
    then
       find  edoc-lines where edoc-lines.db-num      = idb-numOrig
                               and edoc-lines.doc-id      = idoc-idOrig
                               and edoc-lines.gds-code    = utd-lines.gds-code
       no-lock no-error.
end.
method public logical getObgFns
(input iDocumentNumber   as character ,
 input iFnsParticipantId as character ,
 input ikpp              as character ,
 output ohost-code       as integer,
 output oobj-type        as character ,
 output oobj-code        as integer ,
 output otext            as character  ):
    define buffer ext-classif   for ext-classif.
    define buffer clients       for clients.
    define buffer buf_clients   for clients.
    define buffer clients-attr  for clients-attr.
    find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                             and ext-classif.charkey_three eq iFnsParticipantId
    no-lock no-error.
    if available ext-classif
    then do:
       if ext-classif.CharKey_One eq 'маг':U
       then do:
          assign
             oobj-type = ext-classif.CharKey_One
             oobj-code = ext-classif.Key#_One
          .
          find first clients
               where clients.obj-type   = ext-classif.CharKey_One
                 and clients.obj-code   = ext-classif.Key#_One
          no-lock no-error .
          if available clients
          then
             ohost-code =  clients.host-code.
       end.
       else do:
          find first clients
               where clients.obj-type   = ext-classif.CharKey_One
                 and clients.obj-code   = ext-classif.Key#_One
                 and can-find(first ub.sysconf where ub.sysconf.host-code = clients.obj-code)
          no-lock no-error .
          if not available clients
          then do:
             otext = substitute("По &1 получатель  &2 не наша фирма." ,iDocumentNumber, iFnsParticipantId) .
             return no.
          end.
          ohost-code = ext-classif.Key#_One.
          block-cl:
          for each clients-attr
             where clients-attr.attr-code  = 'kpp':U
               and clients-attr.obj-type   = 'маг':U
               and clients-attr.attr-value = ikpp
               and can-find(buf_clients where buf_clients.obj-type   = clients-attr.obj-type
                                          and buf_clients.obj-code   = clients-attr.obj-code
                                          and buf_clients.host-code  = ohost-code)
          no-lock :
             leave block-cl.
          end.
          if     available clients
             and clients.obj-type eq 'маг':U
          then do:
             assign
                oobj-type = clients.obj-type
                oobj-code = clients.obj-code
             .
          end.
          else if available clients-attr
          then do:
             assign
                oobj-type = clients-attr.obj-type
                oobj-code = clients-attr.obj-code
             .
          end.
          else do:
             otext = substitute("По &1 не найден объект по КПП &2." ,iDocumentNumber, ikpp ).
             return yes.
          end.
       end.
    end.
    else do:
       otext = substitute("По &1 не найден получатель  &2." ,iDocumentNumber, iFnsParticipantId) .
       return no.
    end.
    return ?.
end.
method public logical CheckUcdForReturn
(input idb-numUcd as integer,
 input idoc-idUcd as integer,
 input idb-numRet as integer,
 input idoc-idRet as integer  ):
    for each utd-marking-lines where utd-marking-lines.db-num eq idb-numUcd
                                 and utd-marking-lines.doc-id eq idoc-idUcd
                                 and utd-marking-lines.doc-level eq 1
    no-lock:
       create tt-utd-mark.
       buffer-copy utd-marking-lines to tt-utd-mark
       assign
          tt-utd-mark.side = "+"
       .
    end.
    for each utd-marking-lines where utd-marking-lines.db-num eq idb-numRet
                                 and utd-marking-lines.doc-id eq idoc-idRet
                                 and utd-marking-lines.doc-level eq 1
    no-lock:
       find first tt-utd-mark where tt-utd-mark.mark eq utd-marking-lines.mark
       no-lock no-error.
       if available tt-utd-mark
       then
          tt-utd-mark.side = "".
       else do:
          create tt-utd-mark.
          buffer-copy utd-marking-lines to tt-utd-mark
          assign
             tt-utd-mark.side = "-"
          .
       end.
    end.
    for each tt-utd-mark where  tt-utd-mark.side ne ""
    no-lock:
       AddUtdErrForTab(utd.db-num, utd.doc-id, "utd-marking-lines", buffer tt-utd-mark:handle, "UCDСompar", "NotMark" + tt-utd-mark.side, tt-utd-mark.mark).
    end.
    for each tt-utd-mark:
       delete tt-utd-mark.
    end.
end.
method public character  SaturateAndCheckUTD
(input idb-num as integer,
 input idoc-id as integer  ):
   define buffer clients-attr          for clients-attr.
   define buffer clients               for clients.
   define buffer Utd                   for Utd.
   define buffer utd_ret               for ub.utd.
   define buffer utd-lines             for utd-lines.
   define buffer buf_utd-lines         for utd-lines.
   define buffer buf_utddoc-lines      for utd-lines.
   define buffer marking               for marking.
   define buffer marking-lines         for marking-lines.
   define buffer utd-marking-lines     for utd-marking-lines.
   define buffer Buf_utd-marking-lines for utd-marking-lines.
   define buffer contract              for contract.
   define buffer old_utd               for Utd.
   define variable vError as character no-undo.
   define variable vGdsCode as integer no-undo.
   define variable vcli-type as character no-undo.
   define variable vcli-code as integer no-undo.
   define variable vhost-code as integer no-undo init ?.
   define variable vcontract-code as integer no-undo.
   define variable vobj-type as character no-undo init ?.
   define variable vobj-code as integer no-undo init ?.
   define variable volddb-num as integer no-undo.
   define variable volddoc-id as integer no-undo.
   define variable vMark as logical no-undo.
   define variable VUcd as logical no-undo.
   define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-type as character no-undo.
   define variable v-par-val  as character no-undo.
   define variable VFileMark as logical no-undo.
   define variable vunit     as int no-undo.
   define variable vunitCode as character no-undo.
   define variable vMarkingUtd as logical no-undo.
   find first Utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available Utd
   then do:
      VUcd = utd.EDocType eq objSrv:Env:Utd:EDocType:UCD:KeyIntDB.
      VFileMark = getattrutd (utd.db-num,utd.doc-id,"FileName") begins "ON_NSCHFDOPPRMARK_".
      ClearUtdErr(utd.db-num,utd.doc-id,"loadUtd").
      assign
            vobj-type  = utd.obj-type
            vobj-code  = utd.obj-code
            vhost-code = utd.host-code
      .
      do:
         define variable vtext       as character no-undo.
         define variable vhost-code1 as integer   no-undo.
         define variable vobj-type1  as character no-undo.
         define variable vobj-code1  as integer   no-undo.
          getObgFns
                    (input utd.DocumentNumber ,
                     input utd.obj-FnsParticipantId ,
                     input utd.obj-kpp,
                     output vhost-code1,
                     output vobj-type1,
                     output vobj-code1,
                     output vtext ).
         assign
            vobj-type  = vobj-type1   when vobj-type  eq ? or vobj-type  eq ""
            vobj-code  = vobj-code1   when vobj-code  eq ? or vobj-code  eq 0
            vhost-code = vhost-code1  when vhost-code eq ? or vhost-code eq 0
         .
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(vobj-type, vobj-code).
         CheckGds (utd.db-num,utd.doc-id,vobj-type,vobj-code,"loadUTD").
         block-line:
         for each utd-lines where utd-lines.db-num eq utd.db-num
                              and utd-lines.doc-id eq utd.doc-id
         no-lock:
            vGdsCode =?.
            define variable vNotMarkForLine as logical no-undo.
            vNotMarkForLine = no.
            if not VUcd
            then do:
               find first utd-marking-lines
                    where utd-marking-lines.db-num  = utd-lines.db-num
                      and utd-marking-lines.doc-id  = utd-lines.doc-id
                      and utd-marking-lines.LineNum = utd-lines.LineNum
               no-lock no-error.
               if not available utd-marking-lines
               then do:
                  AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,"loadUtd","NotMarkForLine",string(utd-lines.LineNum)).
                  vNotMarkForLine = yes.
               end.
            end.
            block-mark:
            for each utd-marking-lines
               where utd-marking-lines.db-num  = utd-lines.db-num
                 and utd-marking-lines.doc-id  = utd-lines.doc-id
                 and utd-marking-lines.LineNum = utd-lines.LineNum
            no-lock:
               vMark = yes.
               if     isMark(utd-marking-lines.mark)
                  and utd-marking-lines.gds-code  ne 0
                  and utd-marking-lines.gds-code ne ?
               then do:
                                    if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
                        ( utd-marking-lines.gds-code,
                         'mark-type':U,
                         output v-par-val,
                         output v-par-type
                         ).
                   if     not VFileMark
                      and not VUcd
                      and EDOParSec:GetIsEDOForType(v-par-val) and EDOParSec:IsEdo
                   then do:
                       AddUtdErr(utd.db-num,
                                  utd.doc-id,
                                  buffer utd-marking-lines:handle,
                                  "loadUtd",
                                  "NotON_NSCHFDOPPRMARK",
                                  string(utd-lines.LineNum ) + chr(4) + utd-marking-lines.mark).
                  end.
               end.
            end.
            if utd-lines.gds-code eq 0 or utd-lines.gds-code eq ?
            then do :
               if     VUcd
               then do:
                  GetLastUTDinPack (utd.db-num,utd.doc-id,volddb-num,volddoc-id).
                  GetUtdLineForOrig(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,volddb-num,volddoc-id, buffer buf_utddoc-lines).
                  if available buf_utddoc-lines
                  then do:
                     vGdsCode = buf_utddoc-lines.gds-code.
                     vunitCode = buf_utddoc-lines.UnitCode.
                     if     getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old") ne ?
                        and buf_utddoc-lines.UnitCode ne getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old")
                     then
                        AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,
                            "loadUtd",
                            "UcdUnitChangForUtd",
                            string(utd-lines.LineNum )                  + chr(4) +
                            buf_utddoc-lines.UnitCode                   + chr(4) +
                            getattrutdlinesex(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old","?")).
                  end.
                  if     utd-lines.UnitCode ne ?
                     and utd-lines.UnitCode ne ""
                     and utd-lines.UnitCode ne getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old")
                  then
                     AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,
                            "loadUtd",
                            "UcdUnitChang",
                            string(utd-lines.LineNum )                  + chr(4) +
                            utd-lines.UnitCode                          + chr(4) +
                            getattrutdlinesex(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unitcode_old","?")).
               end.
            end.
            else
               vGdsCode = utd-lines.gds-code.
            define variable vValText as character no-undo.
            define variable vValDec  as decimal no-undo.
            VValText = GetAttrUtdlines (utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity").
            if VValText = ?
            then do:
               vValDec = utd-lines.Quantity.
               setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity",string(utd-lines.Quantity)).
            end.
            else
               vValDec = dec(VValText).
            release bar-code .
            if     vGdsCode > 0 and vGdsCode ne ?
            then do:
               assign
                  vunitCode = utd-lines.UnitCode when utd-lines.UnitCode ne ? and utd-lines.UnitCode ne ""
                  vunit = ?
                  vunit = integer (getattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"unit"))
               no-error.
               if vunit ne 0 and vunit ne ?
               then do:
                  find units where units.OKEI eq vunit no-lock no-error.
                  if available units
                  then
                     vunitCode = units.unit-name.
               end.
               find first bar-code where bar-code.gds-code eq vGdsCode
                                     and bar-code.unit-cli eq vUnitCode
               no-lock no-error.
               if not available bar-code
               then
                  AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,
                            "loadUtd",
                            "Unit",
                            string(utd-lines.LineNum )                  + chr(4) +
                            string(vGdsCode)                            + chr(4) +
                            (if vunit ne ? then string(vunit ) else "") + chr(4) +
                            vunitCode).
            end.
            if utd-lines.Quantity ne vValDec * (if avail bar-code then bar-code.cli-base-rate else 1)
            then do:
               find first  buf_utd-lines where buf_utd-lines.db-num  eq utd-lines.db-num
                                           and buf_utd-lines.doc-id  eq utd-lines.doc-id
                                           and buf_utd-lines.LineNum eq utd-lines.LineNum
               exclusive-lock no-error.
               if available buf_utd-lines
               then do:
                  buf_utd-lines.Quantity = vValDec * (if avail bar-code then bar-code.cli-base-rate else 1).
                  release buf_utd-lines.
               end.
            end.
            vValDec  = decimal(getAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity_old")) no-error.
            setAttrUtdLines(utd-lines.db-num,utd-lines.doc-id,utd-lines.Linenum,"Quantity_old_new",string(vValDec * (if avail bar-code then bar-code.cli-base-rate else 1))).
            if     not VUcd
               and CheckMarkUtdLine(utd.db-num,utd.doc-id,utd-lines.LineNum)
            then
               vMarkingUtd = yes .
         end.
         if not VUcd
         then
            CheckQnty(utd.db-num, utd.doc-id, "loadUtd").
         find first ext-classif where ext-classif.classif-name  eq 'id_diadok_client':U
                                  and ext-classif.charkey_three eq utd.cli-FnsParticipantId
         no-lock no-error.
         if available ext-classif
         then
            assign
               vcli-type = ext-classif.CharKey_One
               vcli-code = ext-classif.Key#_One
            .
         else do:
            assign
              vcli-type = ?
              vcli-code = ?
            .
            AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoSuppForId",utd.cli-FnsParticipantId ).
         end.
         find first contract  where contract.host-code eq vhost-code
                                and contract.cli-type  eq vcli-type
                                and contract.cli-code  eq vcli-code
                                and contract.contract-prn-code eq Utd.BaseDocumentNumber
         no-lock no-error.
         define variable VContractEdo as logical no-undo init yes.
         if available contract
         then do:
            assign
               VContractEdo = contract.whole-send-news > 0
               vcontract-code = contract.contract-code
            .
            if not VContractEdo
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoEdoDoc", Utd.BaseDocumentNumber).
         end.
         else do:
            vcontract-code = ?.
         end.
      end.
      if not GetLastUTDinPackAft (utd.db-num, utd.doc-id, volddb-num, volddoc-id)
      then do:
         AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoLastDoc",string(utd.PackageId) + chr(4) + string(volddb-num) + chr(4) + string(volddoc-id)).
      end.
      define variable vdoc-code as character no-undo init ?.
      if utd.EDocType              eq objSrv:Env:Utd:EDocType:Ucd:KeyIntDB
      then do:
         find first utd_ret where utd_ret.parentDocumentExt     eq utd.parentDocumentExt
                              and utd_ret.parentOrganizationExt eq utd.parentOrganizationExt
                              and utd_ret.Timestamp             le utd.Timestamp
                              and utd_ret.EDocType              eq objSrv:Env:Utd:EDocType:returns:KeyIntDB
         no-lock no-error.
         if available utd_ret
         then do:
            vdoc-code = utd_ret.doc-code.
            CheckUcdForReturn(utd.db-num,utd.doc-id,utd_ret.db-num,utd_ret.doc-id).
         end.
      end.
   end.
   find current utd exclusive-lock no-error.
   if available utd
   then do:
      assign
         utd.cli-type      = vcli-type      when vcli-type      ne ?
         utd.cli-code      = vcli-code      when vcli-type      ne ?
         utd.host-code     = vhost-code     when vhost-code     ne ? and vhost-code     ne 0
         utd.contract-code = vcontract-code when vcontract-code ne ?
         utd.obj-type      = vobj-type      when vobj-type      ne ? and vobj-type      ne ""
         utd.obj-code      = vobj-code      when vobj-code      ne ? and vobj-code      ne 0
         utd.doc-code      = vdoc-code      when vdoc-code      ne ?
      .
      if   ( utd.contract-code eq ?
         or utd.contract-code eq 0)
         and not vucd
      then
         AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoContForFirmId",(if utd.host-code eq ? then "?" else string (utd.host-code)) + chr(4) +  utd.BaseDocumentNumber).
      if utd.host-code eq ?
         or utd.host-code eq 0
      then
         AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoFirmForId",if utd.obj-FnsParticipantId eq ? then "?" else utd.obj-FnsParticipantId ).
      if utd.obj-code eq ?
         or utd.obj-code eq 0
      then
         AddUtdErr(utd.db-num,utd.doc-id,buffer utd:handle,"loadUtd","NoShopForKpp",utd.obj-kpp).
   end.
   vError = GetErrForUtdstr(utd.db-num,utd.doc-id,"loadUtd").
   if vError eq ""
   then do:
      if utd.sts eq 0 or utd.sts eq ?
      then
         utd.sts = if VUcd
                   then ObjSrv:Env:Utd:Sts:th:ConfirmedUcd:KeyIntDB
                   else ObjSrv:Env:Utd:Sts:th:ReceivedFromSupplier:KeyIntDB.
      if utd.sts = ObjSrv:Env:Utd:Sts:th:LoadError:KeyIntDB
      then do:
         utd.sts = ObjSrv:Env:Utd:Sts:th:ReceivedFromSupplier:KeyIntDB.
      end.
      if     not VUcd
         and utd.sts = ObjSrv:Env:Utd:Sts:th:ReceivedFromSupplier:KeyIntDB
      then do:
         if not vMarkingUtd
         then
            utd.sts = objSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB.
      end.
   end.
   else do:
      if utd.sts ne ObjSrv:Env:Utd:Sts:th:CorrectionRequested:KeyIntDB
      then
         utd.sts = ObjSrv:Env:Utd:Sts:th:LoadError:KeyIntDB.
   end.
   if     utd.sts-edi  >= ObjSrv:Env:Utd:Sts:edi:StatChangLoanOnlyBeg
      and utd.sts-edi  <= ObjSrv:Env:Utd:Sts:edi:StatChangLoanOnlyEnd
   then
      utd.sts-edi = ?.
   else if     (not vMark and  not vucd) or not VContractEdo
           and utd.sts-edi < ObjSrv:Env:Utd:Sts:edi:StatChangLoanOnlyBeg
   then
      utd.sts-edi = ObjSrv:Env:Utd:Sts:edi:AutoRejected:KeyIntDB.
   release utd no-error.
   if error-status:error
   then
      return error return-value.
   return vError.
end.
method public logical ReCheckload
(idb-num as integer,
 idoc-id as integer,
 iload   as logical ):
   define buffer buf_c-utd for ub.c-utd .
   define buffer buf_utd   for ub.utd .
   find first buf_utd where buf_utd.db-num eq idb-num
                        and buf_utd.doc-id eq idoc-id
   exclusive-lock no-error.
   if available buf_utd
   then do:
      if    iload
         or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:loaderror:KeyIntDB
      then do:
         SaturateAndCheckUTD(buf_utd.db-num, buf_utd.doc-id) no-error .
         if  error-status:error then
         do:
            message return-value view-as alert-box.
         end.
      end.
      if    buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB
         or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB
         or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:DeliveryCodeMismatch:KeyIntDB
         or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LackOfMarkingCodesInCirculation:KeyIntDB
      then do:
         find last buf_c-utd no-lock where buf_c-utd.db-num eq buf_utd.db-num and
                                           buf_c-utd.doc-id eq buf_utd.doc-id and
                                           buf_c-utd.sts    eq buf_utd.sts and
                                           buf_c-utd.sts    eq ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB
         no-error .
         if available (buf_c-utd)
         then do:
            buf_utd.sts = buf_c-utd.sts .
            buf_utd.sts-edi = buf_c-utd.sts-edi .
         end.
         else do:
            if    buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:InconsistencyWithSupplyContract:KeyIntDB
               or buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:LinesInError:KeyIntDB
            then
               buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB .
            else
               buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:ReceivedFromSupplier:KeyIntDB .
            buf_utd.sts-edi = ObjSrv:Env:Utd:Sts:EDI:Verification:KeyIntDB .
         end.
      end.
      if buf_utd.sts = objSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB
      then do:
         run utl/utd-checkSpec.p (input buf_utd.db-num,
                                  input buf_utd.doc-id) .
      end.
   end.
   release buf_utd.
end.
method public logical ReCheck
(idb-num as integer,
 idoc-id as integer ):
   ReCheckload(idb-num,idoc-id,no).
end.
method public logical GetLastUTDForPac
(iPackegeId as character ,
 iTimestamp as datetime,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   find last buf_utd where Buf_utd.PackageId eq iPackegeId
                             and Buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                             and Buf_utd.Timestamp gt iTimestamp
   no-lock no-error.
   if available  buf_utd
   then
      assign
         odb-num = buf_utd.db-num
         odoc-id = buf_utd.doc-id
      no-error.
   else
      assign
         odb-num = ?
         odoc-id = ?
      no-error.
end.
method public logical GetprevUTDForPac
(iPackegeId as character ,
 iTimestamp as datetime,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   find last buf_utd where Buf_utd.PackageId eq iPackegeId
                             and Buf_utd.EDocType  eq objSrv:Env:Utd:EDocType:UTD:KeyIntDB
                             and Buf_utd.Timestamp < iTimestamp
   no-lock no-error.
   if available  buf_utd
   then
      assign
         odb-num = buf_utd.db-num
         odoc-id = buf_utd.doc-id
      no-error.
   else
      assign
         odb-num = ?
         odoc-id = ?
      no-error.
end.
method public logical GetLastUTDinPackAft
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   define buffer     utd for utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if utd.PackageId eq ""
      then do:
         assign
            odb-num = utd.db-num
            odoc-id = utd.doc-id
         .
         return yes.
      end.
      else do:
         GetLastUTDForPac(utd.PackageId,utd.Timestamp,output odb-num,output odoc-id ).
         if    odb-num eq ?
            or odoc-id eq ?
         then do:
            assign
               odb-num = utd.db-num
               odoc-id = utd.doc-id
            .
            return yes.
         end.
         else
            return odoc-id = utd.doc-id.
      end.
   end.
   return ?.
end.
method public logical GetLastUTDinPackbef
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   define buffer     utd for utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if utd.PackageId eq ""
      then do:
         assign
            odb-num = utd.db-num
            odoc-id = utd.doc-id
         .
         return yes.
      end.
      else do:
         GetprevUTDForPac(utd.PackageId,utd.Timestamp,output odb-num,output odoc-id ).
         if    odb-num eq ?
            or odoc-id eq ?
         then do:
            assign
               odb-num = utd.db-num
               odoc-id = utd.doc-id
            .
            return yes.
         end.
         else
            return odoc-id = utd.doc-id.
      end.
   end.
   return ?.
end.
method public logical GetLastUTDinPack
(input idb-num as integer,
 input idoc-id as integer,
 output odb-num as integer,
 output odoc-id as integer ):
   define buffer buf_utd for utd.
   define buffer     utd for utd.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if utd.PackageId eq ""
      then do:
         assign
            odb-num = utd.db-num
            odoc-id = utd.doc-id
         .
         return yes.
      end.
      else do:
         GetLastUTDForPac(utd.PackageId,datetime("01/01/1900"),output odb-num,output odoc-id ).
         if    odb-num eq ?
            or odoc-id eq ?
         then do:
            assign
               odb-num = utd.db-num
               odoc-id = utd.doc-id
            .
            return yes.
         end.
         else
            return odoc-id = utd.doc-id.
      end.
   end.
   return ?.
end.
method public void delMark
( buffer utd-marking-lines for utd-marking-lines ):
   define buffer buf_utd-marking-line for utd-marking-lines.
   for each marking where marking.mark-parent eq utd-marking-lines.mark no-lock:
      find first buf_utd-marking-line where buf_utd-marking-line.db-num    eq utd-marking-lines.db-num
                                        and buf_utd-marking-line.doc-id    eq utd-marking-lines.doc-id
                                        and buf_utd-marking-line.mark      eq marking.mark
      no-lock no-error.
      if available  buf_utd-marking-line
      then do:
         delMark(buffer buf_utd-marking-line).
         delete buf_utd-marking-line.
      end.
   end.
end.
method public void addMark
( buffer utd-marking-lines for utd-marking-lines ):
   define buffer buf_utd-marking-line for utd-marking-lines.
   define buffer par_utd-marking-line for utd-marking-lines.
   define buffer buf_utd for ub.utd .
   for each marking where marking.mark-parent eq utd-marking-lines.mark no-lock:
      find first buf_utd-marking-line where buf_utd-marking-line.db-num    eq utd-marking-lines.db-num
                                        and buf_utd-marking-line.doc-id    eq utd-marking-lines.doc-id
                                        and buf_utd-marking-line.mark      eq marking.mark
      no-lock no-error.
      if available  buf_utd-marking-line
      then do:
         if buf_utd-marking-line.doc-level ne utd-marking-lines.doc-level + 1
         then do:
            find current  buf_utd-marking-line exclusive-lock no-error.
            if available buf_utd-marking-line
            then
               buf_utd-marking-line.doc-level = utd-marking-lines.doc-level + 1.
         end.
      end.
      else do:
         find first buf_utd no-lock where buf_utd.db-num    eq utd-marking-lines.db-num
                                      and buf_utd.doc-id    eq utd-marking-lines.doc-id
                                      no-error .
         create buf_utd-marking-line.
         buffer-copy utd-marking-lines except doc-level mark sts gds-code to buf_utd-marking-line
         assign
            buf_utd-marking-line.doc-level = utd-marking-lines.doc-level + 1
            buf_utd-marking-line.mark      = marking.mark
            buf_utd-marking-line.gds-code  = marking.Gds-code
            buf_utd-marking-line.sts      = if (available buf_utd and buf_utd.EDocType = objSrv:Env:Utd:EDocType:Mark_Collect:KeyIntDB)
                                            then marking.sts
                                            else
                                            if can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(marking.sts)) or
                                               can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(marking.sts)) or
                                               marking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB or
                                               marking.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB
                                             then objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
                                             else marking.sts
         .
         if  buf_utd-marking-line.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB then
         do:
           for first par_utd-marking-line no-lock where
                     par_utd-marking-line.db-num  = buf_utd-marking-line.db-num
                 and par_utd-marking-line.doc-id  = buf_utd-marking-line.doc-id
                 and par_utd-marking-line.LineNum = buf_utd-marking-line.LineNum
                 and par_utd-marking-line.mark    = marking.mark-parent
                 and par_utd-marking-line.sts     = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
           :
             buf_utd-marking-line.sts = objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB.
           end.
         end.
      end.
      addMark(buffer buf_utd-marking-line).
   end.
end.
method public void unLockUTDMarkbuf
(buffer old_utd for utd,
 iAll as logical ):
   define variable voldkey    as character no-undo.
      define variable objKeyRec as class ibs.th.gbl.keyrec no-undo.
      objKeyRec = new ibs.th.gbl.keyrec().
      objKeyRec:GenKeyRec ( input 'utd':U
                           ,input buffer old_utd:handle
                           ,output voldkey).
      delete object objKeyRec.
   for each marking where marking.loc-key eq voldkey
   exclusive-lock:
      if    iAll
         or (    marking.sts eq  ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
             and marking.sts eq  ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB )
      then do:
         marking.loc-key = "".
         marking.sts =  ObjSrv:Env:Marking:Sts:Mark:UnknowSts:KeyIntDB.
      end.
   end.
end.
method public void unLockUTDMark
(idb-num as integer ,idoc-id as integer ,iall as logical):
   define buffer old_utd for utd.
   find first old_utd where old_utd.db-num eq idb-num
                        and old_utd.db-num eq idoc-id
   no-lock no-error.
   if available old_utd
   then do:
      UnLockUTDMarkbuf(buffer old_utd,iall).
   end.
end.
method public void changSts
(idb-num as integer ,
 idoc-id as integer ,
 old_sts_edo as character ,
 new_sts_edo as character  ):
   if     old_sts_edo ne new_sts_edo
      and ( new_sts_edo eq "RevocationAccepted"
           or  new_sts_edo eq "RecipientSignatureRequestRejected"
           )
   then
      UnLockUTDMark(idb-num,idoc-id,yes).
   if     old_sts_edo ne new_sts_edo
      and ( new_sts_edo eq "WithRecipientSignature"
        or  new_sts_edo eq "WithRecipientPartiallySignature"
           )
   then
      UnLockUTDMark(idb-num,idoc-id,no).
end.
method public void SetLockUTDMark
(idb-num as integer ,idoc-id as integer ):
   define buffer new_utd for utd.
   define buffer old_utd for utd.
   define variable volddb-num as integer no-undo.
   define variable volddoc-id as integer no-undo.
   define variable voldkey    as character no-undo.
   define variable vnewkey    as character no-undo.
   find first new_utd where new_utd.db-num eq idb-num
                        and new_utd.doc-id eq idoc-id
   no-lock no-error.
   if not GetLastUTDinPack (new_utd.db-num,new_utd.doc-id,volddb-num,volddoc-id)
   then do trans:
      find first old_utd where old_utd.db-num eq volddb-num
                           and old_utd.doc-id eq volddoc-id
      no-lock no-error.
         define variable objKeyRec as class ibs.th.gbl.keyrec no-undo.
         objKeyRec = new ibs.th.gbl.keyrec().
         objKeyRec:GenKeyRec ( input 'utd':U
                              ,input buffer new_utd:handle
                              ,output vnewkey).
         objKeyRec:GenKeyRec ( input 'utd':U
                              ,input buffer old_utd:handle
                              ,output voldkey).
         delete object objKeyRec.
      for each utd-marking-lines where utd-marking-lines.db-num eq new_utd.db-num
                                   and utd-marking-lines.doc-id eq new_utd.doc-id
      no-lock:
         find first marking where marking.mark eq utd-marking-lines.mark no-lock no-error.
         if available  marking
         then do:
            if    marking.loc-key eq ""
               or marking.loc-key eq ?
               or marking.loc-key eq voldkey
            then do:
               find current marking exclusive-lock no-error.
               if available marking
               then do:
                  marking.loc-key = vnewkey.
                  release marking.
               end.
            end.
            else if marking.loc-key ne vnewkey
            then do:
               addutderr(new_utd.db-num,new_utd.doc-id,buffer new_utd:handle,"LoadUtd","MarkLock",marking.mark + chr(4) + marking.loc-key).
            end.
         end.
      end.
      UnLockUTDMark(old_utd.db-num,old_utd.doc-id,yes).
   end.
end.
  define private temp-table tt-mark no-undo
     field mark as character case-sensitive
  .
  define stream myProt.
  define variable isOpenProt as logical no-undo init no.
  define property Msg as character no-undo
    get.
    set.
  define variable GrayZoneQnty  as integer no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable objImp    as class ibs.th.bge.1crn.subjects.edi-doc no-undo.
    define variable v-retfl   as logical no-undo .
    define variable v-mode    as character no-undo.
    define variable v-objlist   as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:kb-gds[]
    define variable v-gds-gd    as class ibs.th.bge.1crn.subjects.edi-gd no-undo .
    define variable v-objlistmark   as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:kb-gds[]
    define variable v-marks-mark    as class ibs.th.bge.1crn.subjects.mark no-undo .
    define variable v-i-counter as integer no-undo .
    define variable v-i-num     as integer no-undo .
    define variable v-i-counter2 as integer no-undo .
    define variable v-i-num2     as integer no-undo .
    define variable v-stub      as integer no-undo .
    define variable v-value-character     as character     no-undo .
    define variable v-value-decimal       as decimal       no-undo .
    define variable v-value-integer       as integer       no-undo .
    define variable v-value-logical       as logical       no-undo .
    define variable v-value-type          as character     no-undo .
    define variable v-value-date          as date          no-undo .
    define variable v-host-code  as integer no-undo .
    define buffer buf_clients    for ub.clients .
    define buffer buf_goods      for ub.goods .
    define buffer buf_goods-attr for ub.goods-attr .
    define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc .
    define buffer utd for ub.utd .
    define buffer utd-attr for ub.utd-attr .
   define buffer utd-lines              for ub.utd-lines .
   define buffer utd-lines-attr         for ub.utd-lines-attr .
   define buffer utd-marking-lines      for ub.utd-marking-lines .
   define buffer utd-marking-lines-attr for ub.utd-marking-lines-attr .
   define buffer marking                for ub.marking .
   define buffer marking-attr           for ub.marking-attr .
   define buffer contract               for ub.contract .
   define buffer order-doc              for ub.order-doc .
    objImp = cast (subjectObj, edi-doc).
    if objImp:del-f > 0 then
      undo, throw new Progress.Lang.AppError("физичесткое удаление edi-doc не предусмотрено") .
   find first utd where utd.OrganizationExt eq ""
                    and utd.DocumentExt     eq objImp:edoc-id
   exclusive-lock no-error.
   if not available utd
   then do:
      if objImp:obj-load ne "edi-doc"
      then
         undo, throw new Progress.Lang.AppError(substitute("Создание &1 не предусмотрено",objImp:obj-load)) .
      create utd.
      utd.DocumentExt     = objImp:edoc-id.
      validate utd no-error.
      if error-status:error
      then
         undo, throw new Progress.Lang.AppError(substitute("&1 &2",return-value,error-status:get-message (1))) .
   end.
   if objImp:obj-load eq "edi-doc-stts"
   then do:
      utd.sts  = ObjSrv:Env:Utd:Sts:th:GetKeyIntDB(objImp:edoc-stts).
      for each utd-marking-lines where utd-marking-lines.db-num    eq utd.db-num
                                   and utd-marking-lines.doc-id    eq utd.doc-id
                                   and utd-marking-lines.doc-level eq 1
      exclusive-lock:
         addMark(buffer utd-marking-lines ).
                     find first marking exclusive-lock where marking.mark = utd-marking-lines.mark no-error .
                       if available (marking) then do:
                       if marking.unit-ext <> "UNIT" and utd.EDocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB
                       and marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB then
                       marking.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB.
                       end.
      end.
   end.
   else do:
      assign
         utd.comment  = objImp:comment
         utd.CounteragentId  = objImp:contr-code                  when objImp:contr-code ne ?
         utd.contract-code  = objImp:dog-code                     when objImp:dog-code ne ?
         utd.DocumentDate  = objImp:edoc-date
         utd.DocumentNumber  = objImp:edoc-num
         utd.sts  = ObjSrv:Env:Utd:Sts:th:GetKeyIntDB(objImp:edoc-stts)
         utd.sts-edi  = ObjSrv:Env:Utd:Sts:EDI:Verification:KeyIntDB
         utd.EDocType  = ObjSrv:Env:Utd:edoctype:GetKeyIntDB(objImp:edoc-type)
         utd.parentDocumentExt  = objImp:orig-edoc-id             when objImp:orig-edoc-id ne ?
         utd.PackageId          = objImp:orig-edoc-id             when objImp:orig-edoc-id ne ?
         utd.total  = objImp:sum                                  when objImp:sum ne ?
         utd.vat  = utd.total - objImp:sum-nonds                  when objImp:sum ne ? and objImp:sum-nonds ne ?
      .
      define variable vflag as logical no-undo.
      for first buf_clients no-lock
            where buf_clients.obj-type = 'орг':U
              and buf_clients.obj-code = int(objImp:contr-code) :
         assign
            utd.cli-type   = buf_clients.obj-type
            utd.cli-code   = buf_clients.obj-code
           vflag = yes
         .
      end.
      if  not vflag
      then
         undo, throw new Progress.Lang.AppError(substitute("Не найдена организация с кодом &1 в БД &2",int(objImp:contr-code),ibs.th.gbl.gbl-var:g#db-num)) .
      for first buf_clients no-lock
            where buf_clients.db-num   = ibs.th.gbl.gbl-var:g#db-num
              and buf_clients.obj-type = 'маг':U
              and buf_clients.stts     = 0 :
         assign
            utd.obj-type   = buf_clients.obj-type
            utd.obj-code   = buf_clients.obj-code
            utd.host-code  = buf_clients.host-code
         .
          run adm/shattri.p (
               input "get":U
               ,input utd.obj-type
               ,input utd.obj-code
               ,input 'marking':U
               ,input "gray_zone_qnty"
               ,output v-value-character
               ,output v-value-date
               ,output v-value-decimal
               ,output v-value-integer
               ,output v-value-logical
               ,output v-value-type
               ,input-output TABLE thbjattr_thbj-attr
               ) no-error .
           if v-value-integer <> ?
           then
              GrayZoneQnty = 100
           .
         find first shop where shop.obj-code eq buf_clients.obj-code
         no-lock no-error.
         if available shop
         then
            utd.obj-info = shop.addres1.
      end.
      find first contract  where contract.host-code     eq utd.host-code
                             and contract.contract-code eq utd.contract-code
      no-lock no-error.
      if  not available contract
      then
         undo, throw new Progress.Lang.AppError(substitute("В &1, указанный в УПД, не найден в системе.",utd.contract-code)) .
      if     contract.cli-type  ne utd.cli-type
         or  contract.cli-code  ne utd.cli-code
      then
         undo, throw new Progress.Lang.AppError(substitute("В договоре &1 и в УПД разные контр агенты",utd.contract-code)) .
      Utd.BaseDocumentNumber = contract.contract-prn-code.
      utd.BaseDocumentDate       = contract-date.
      if objImp:order-item ne ? and
         can-find(first order-doc where order-doc.order-item = objImp:order-item)
      then
        setattrutd(utd.db-num, utd.doc-id, "order-item", objImp:order-item).
      v-objlist = objImp:gds .
      if valid-object(v-objlist)
      then do :
         v-i-counter = v-objlist:iCounter .
         do v-i-num = 1 to v-i-counter :
            v-stub = v-objlist:Get(v-i-num) . // возвращает кол-во элементов и переключает currItem
            v-gds-gd = cast(v-objlist:SubjectObjCurr, ibs.th.bge.1crn.subjects.edi-gd) .
            find first utd-lines where utd-lines.db-num  eq utd.db-num
                                   and utd-lines.doc-id  eq utd.doc-id
                                   and utd-lines.LineNum eq v-gds-gd:line-num
            exclusive-lock no-error.
            if not available utd-lines
            then do:
               create utd-lines.
               assign
                  utd-lines.db-num   = utd.db-num
                  utd-lines.doc-id   = utd.doc-id
                  utd-lines.LineNum  = v-gds-gd:line-num
               .
            end.
            utd-lines.TaxRate = v-gds-gd:nds-code.
            if v-gds-gd:gds-code ne ?
            then do:
               find first goods where goods.gds-code eq v-gds-gd:gds-code
               no-lock no-error.
               if not available goods
               then
                  undo, throw new Progress.Lang.AppError(substitute("Нет товара с кодом &1",v-gds-gd:gds-code)).
            end.
            assign
               utd-lines.Price     = v-gds-gd:price-nonds
               utd-lines.Quantity  = v-gds-gd:qnty-ttn
               utd-lines.Total     = v-gds-gd:sum
               utd-lines.gds-code  = v-gds-gd:gds-code
            .
            if available  goods
            then
               assign
                  utd-lines.UnitCode  = goods.unit-base
                  utd-lines.GdsName   = goods.gds-name
               .
            release goods.
            if v-gds-gd:sum-nds eq ?
            then
               assign
                  utd-lines.TotalWithVatExcluded  = utd-lines.Price * utd-lines.Quantity
               .
            else
               assign
                  utd-lines.Vat                   = v-gds-gd:sum-nds
                  utd-lines.TotalWithVatExcluded  = utd-lines.Total - utd-lines.Vat
               .
            if v-gds-gd:stts-desc ne ?
            then
               AddUtdErr(utd.db-num,utd.doc-id,buffer utd-lines:handle,"Load1C","stts-desc-line",v-gds-gd:stts-desc + chr(4) + string( utd-lines.LineNum)).
            if v-gds-gd:cert-decl ne ""
            then
               setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"doc_sertif",v-gds-gd:cert-decl).
            if v-gds-gd:Qnty-accepted ne ?
            then
               setattrutdlines(utd-lines.db-num, utd-lines.doc-id, utd-lines.lineNum,"QuantityBarCode",string(v-gds-gd:Qnty-accepted)).
            if v-gds-gd:manual-selection eq 1
            then
               setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"manual-selection","yes").
            else
               setattrutdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.LineNum,"manual-selection","").
            define variable vqnty as integer no-undo.
            vqnty = 0.
            define variable vGdsCode as integer no-undo.
            v-objlistmark = v-gds-gd:marks .
            if valid-object(v-objlistmark)
            then do :
               vGdsCode = 0.
               v-i-counter2 = v-objlistmark:iCounter .
               for each tt-mark:
                  delete tt-mark.
               end.
               for each utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                            and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                            and utd-marking-lines.LineNum eq utd-lines.LineNum
               exclusive-lock:
                  delete utd-marking-lines.
               end.
               do v-i-num2 = 1 to v-i-counter2 :
                  v-objlistmark:Get(v-i-num2) .
                  v-marks-mark = cast(v-objlistmark:SubjectObjCurr, ibs.th.bge.1crn.subjects.mark) .
                  define variable vmark as character no-undo.
                  vmark = repTegforDm(v-marks-mark:mark-code).
                  release marking.
                  if ismark(vmark)
                  then do:
                     find first marking where marking.mark eq vmark
                        no-lock no-error.
                     if not available marking
                     then
                        undo, throw new Progress.Lang.AppError(substitute("Нет марки &1 .",v-marks-mark:mark-code)) .
                  end.
                  define variable vrec as recid no-undo.
                  vrec = addMarkforUtd (utd-lines.db-num ,
                                 utd-lines.doc-id,
                                 utd-lines.Linenum,
                                 vmark,
                                 "1c",
                                 objImp:edoc-type).
                  find first utd-marking-lines where recid(utd-marking-lines)   eq vrec
                  exclusive-lock no-error.
                  if available marking
                  then
                     utd-marking-lines.gds-code = marking.gds-code.
                  else
                     utd-marking-lines.gds-code = v-gds-gd:gds-code.
                  if     vGdsCode eq 0
                     and utd-marking-lines.gds-code ne ?
                  then
                     vGdsCode = utd-marking-lines.gds-code.
                  else if      utd-marking-lines.gds-code ne ?
                      and vGdsCode ne utd-marking-lines.gds-code
                  then
                     vGdsCode = ?.
                  if not ismark(vmark)
                  then do:
                     define variable vQntyMark as decimal no-undo.
                     vQntyMark = getQntyUTDByCodId(vmark) .
                     setattrUtdMarkingLines(utd-lines.db-num, utd-lines.doc-id, utd-lines.Linenum, vmark,"box-qnty",string(vQntyMark)).
                  end.
                  else
                     vQntyMark = marking.box-qnty.
                  if utd-marking-lines.doc-level eq 1
                  then
                     vqnty = vqnty + vQntyMark.
                  utd-marking-lines.sts = if not avail ub.marking then ObjSrv:Env:marking:Sts:mark:GetKeyIntDB(v-marks-mark:stts)
                                          else
                                 if can-do(objSrv:Env:Marking:Sts:Mark:Sale_Return_Wait,string(ub.marking.sts)) or
                                    can-do(objSrv:Env:Marking:Sts:Mark:Doc_Status,string(ub.marking.sts)) or
                                    ub.marking.sts = objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB or
                                    ub.marking.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB
                                 then objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
                                 else ub.marking.sts.
                  if     v-marks-mark:stts-desc ne ?
                     and available marking
                  then
                     AddUtdErr(utd.db-num,utd.doc-id,buffer utd-marking-lines:handle,"Load1C","stts-desc-mark",v-marks-mark:stts-desc + chr(4) + string( utd-lines.LineNum) + chr(4) +  vmark).
                  release utd-marking-lines.
               end.
run gbl/inidebug.p.
               for each utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                            and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                            and utd-marking-lines.LineNum eq utd-lines.LineNum
                                            and utd-marking-lines.doc-level = 1
               exclusive-lock:
                  do:
                     MarkGray(utd-marking-lines.mark, utd.db-num, utd.doc-id).
                     addMark( buffer utd-marking-lines).
                       find first marking exclusive-lock where marking.mark = utd-marking-lines.mark no-error .
                       if available (marking) then do:
                          if marking.unit-ext <> "UNIT" and utd.EDocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB
                          and marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB then
                          marking.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB.
                       end.
                  end.
               end.
               if     vGdsCode     eq ?
                  and v-i-counter2 > 0
               then
                  utd-lines.gds-code = ?.
            end. //
            release utd-lines.
         end.
      end.
   end.
   for each utd-lines where utd-lines.db-num eq utd.db-num
                        and utd-lines.doc-id eq utd.doc-id
   no-lock:
      CheckMarkUtdLine(utd-lines.db-num,
                       utd-lines.doc-id,
                       utd-lines.LineNum).
   end.
   CheckMarkUtd(utd.db-num,utd.doc-id).
   CheckMarking(utd.db-num,utd.doc-id,"CheckСontract").
   CheckMarkUtd(utd.db-num,utd.doc-id).
   if ibs.th.gbl.gbl-var:g#db-num ne 0 and utd.sts = objSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB
      and (utd.EDocType = objSrv:Env:Utd:EDocType:UTD:KeyIntDB )
     then
   do:
     def var v-file-name as character no-undo.
     def var v-msg       as character no-undo.
     run ibs\th\str\utd\adaputd.p
       (utd.db-num,
       utd.doc-id,
       ibs.th.gbl.gbl-var:g#userid
       ) no-error.
     if not error-status:error
     then do:
        v-msg = "".
        if return-value matches "*ошибка*"
        or return-value begins "need-user-action"
        then v-msg = substitute ('Документ № &1 от &2. Сформирована ПН: &3. &4', utd.DocumentNumber, string (utd.DocumentDate) , utd.doc-code, trim(return-value, "need-user-action")).
        else do:
           if     utd.sts ne objSrv:Env:Utd:Sts:TH:Confirmed           :KeyIntDB
           then    v-msg = substitute ('Получен УПД. Документ № &1 от &2. Сформирована ПН: &3. &5 &6 &4',
                                       utd.DocumentNumber,
                                       string (utd.DocumentDate) ,
                                       utd.doc-code,
                                       return-value,
                                       if ChecknotMarkUtd(utd.db-num,utd.doc-id) then "Немаркированные товары можно продавать на кассе." else "",
                                       if CheckMarkUtd(utd.db-num,utd.doc-id) then "Продажа маркированных товаров из данной поставки запрещена до получения дополнительного уведомления." else "").
           else if     utd.sts eq objSrv:Env:Utd:Sts:TH:Confirmed           :KeyIntDB
                   and CheckMarkUtd(utd.db-num,utd.doc-id)
           then    v-msg = substitute ('Получен УПД. Документ № &1 от &2. Сформирована ПН: &3. &5 &4', utd.DocumentNumber, string (utd.DocumentDate) , utd.doc-code, return-value, "Маркированные товары данной поставки можно продавать на кассе").
        end.
     end.
     else v-msg = substitute ('Документ: &1 от &2. Ошибка при формировании ПН. &3. &4', utd.DocumentNumber, string (utd.DocumentDate), trim(return-value, ".")).
     if v-msg ne ""
     then
        run utl\proc-msg.p (v-msg) no-error.
   end.
   if ibs.th.gbl.gbl-var:g#db-num ne 0 and utd.sts = objSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB and utd.EDocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB
   then do:
       v-msg = substitute ('MsgBox "Докумет № &1 от &2. ", ,"Получен документ первоначального ввода"', utd.DocumentNumber, string (utd.DocumentDate)).
       v-file-name = string (guid(generate-uuid)) + ".vbs".
       output to value (v-file-name).
       put unformatted v-msg.
       output close.
       file-info:file-name = (v-file-name).
       os-command no-wait value (file-info:full-pathname).
   end.
   release utd.
   v-retfl = true .
    define variable i as integer no-undo .
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        do i = 1 to exAppErrors:NumMessages :
          Msg = Msg + chr(10) + exAppErrors:GetMessage(i) .
        end .
        if Msg > "" then . else Msg = "AppError в edi-doc" .
      end .
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      do i = 1 to exProErrors:NumMessages :
        Msg = Msg + chr(10) + exProErrors:GetMessage(i) .
      end .
      if Msg > "" then . else Msg = "ProError в edi-doc" .
      v-retfl = false.
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error в edi-doc" .
      v-retfl = false .
      undo, throw exAnyErrors .
    end catch .
    finally :
      return v-retfl .
    end finally .
  end method.
  method public void MarkGray(imark as char, idb-num as int, idoc-id as int):
     define buffer marking for marking.
     define buffer BuF_marking for marking.
     define buffer bf_bar-code for ub.bar-code .
     define buffer bf2_bar-code for ub.bar-code .
     define buffer bf_goods-attr for ub.goods-attr .
     define buffer bf_utd-marking-lines for utd-marking-lines .
     define variable vAllQnty as integer no-undo init ?.
     define variable vQnty as integer no-undo.
     define variable v-must-be-childs as integer no-undo .
     define variable cisGdsCode as integer no-undo .
     define variable v-mark-type  as character no-undo .
     define variable v-err-childs as logical no-undo .
     define variable v-gray-zone  as logical no-undo .
     define variable errMsg as character no-undo .
     v-err-childs = false .
     v-gray-zone = false .
     find first marking where marking.mark eq imark
     no-lock no-error.
     if available marking
        and marking.box-qnty ne 1
     then do:
        find first bf_utd-marking-lines where bf_utd-marking-lines.db-num eq idb-num
                                          and bf_utd-marking-lines.doc-id eq idoc-id
                                          and bf_utd-marking-lines.mark   eq marking.mark
        no-lock no-error.
        if marking.gds-code > 0
        then do :
           cisGdsCode = marking.gds-code .
        end .
        else do :
           cisGdsCode = getGdsCodeByGtin(marking.gds-ext-id) .
        end .
        v-mark-type = "" .
        for first bf_goods-attr no-lock where bf_goods-attr.attr-code = 'mark-type':U
                                          and bf_goods-attr.gds-code = cisGdsCode
                                          :
           v-mark-type = bf_goods-attr.attr-value .
        end .
        for each buf_marking where buf_marking.mark-parent eq marking.mark
        no-lock:
           if vAllQnty eq ?
           then
              vAllQnty = marking.box-qnty / buf_marking.box-qnty.
           vQnty = vQnty + 1.
        end.
        if marking.unit-ext = "LEVEL1"
        or marking.unit-ext = "GROUP"
        then do :
           if cisGdsCode > 0
           then do :
              v-must-be-childs = 10 .
              if v-mark-type = "tabak"
              then do:
                find first bf_bar-code no-lock where bf_bar-code.gds-code = cisGdsCode
                                                 and bf_bar-code.unit-cli = "бл"
                                                 and bf_bar-code.stts_ = 0
                no-error .
                if available bf_bar-code
                then do :
                  v-must-be-childs = bf_bar-code.cli-base-rate .
                end .
                else do :
                  errMSG = "Для товара с кодом " + string(cisGdsCode) + " не найден код с ед. изм. 'бл'" .
                  v-err-childs = true .
                end .
              end.
              else do:
                  v-must-be-childs = getQntyCodeByGtin(marking.gds-ext-id).
                  if v-must-be-childs = ?
                  then do:
                    errMSG = "Для товара с кодом " + string(cisGdsCode) + " не найден коэф. ед. изм. по GTIN" .
                    v-err-childs = true .
                  end.
              end.
              if not v-err-childs
              then do :
                if v-mark-type = "tabak"
                or v-mark-type = "stiki"
                then do :
                  if vQnty <> v-must-be-childs and GrayZoneQnty <> 100
                  then do:
                    if (v-must-be-childs - vQnty) <= GrayZoneQnty
                    then v-gray-zone = true .
                    else v-err-childs = true .
                  end .
                  if v-gray-zone
                  then do :
                     MarkChangeSts(marking.mark,
                                   objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB,
                                   "",
                                   no).
                  end .
                end .
                else do :
                  if vQnty <> v-must-be-childs then v-err-childs = true .
                end .
                if v-err-childs
                then do :
                  errMSG = "В блоке " + string(vQnty) + " пачек." .
                end .
              end .
              if v-err-childs
              then do :
                 MarkChangeSts(marking.mark,
                               objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB,
                               errMSG,
                               yes).
                 if marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
                 then
                 AddUtdErr(idb-num,
                           idoc-id,
                           if available bf_utd-marking-lines
                           then buffer bf_utd-marking-lines:handle
                           else buffer marking:handle,
                           "CheckMOTP",
                           "MotpMarkErr",
                           (marking.mark + chr(4) + errMSG)).
              end .
           end .
        end .
        else do :
           if vAllQnty <> vQnty and GrayZoneQnty <> 100
           then do:
              if vAllQnty - vQnty <= GrayZoneQnty
              then do :
                 MarkChangeSts(marking.mark,
                               objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB,
                               "",
                               no).
              end .
              else do :
                errMSG = "В блоке " + string(vQnty) + " пачек." .
                MarkChangeSts(marking.mark,
                               objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB,
                               errMSG,
                               yes).
                if marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
                then
                AddUtdErr(idb-num,
                          idoc-id,
                          if available bf_utd-marking-lines
                          then buffer bf_utd-marking-lines:handle
                          else buffer marking:handle,
                          "CheckMOTP",
                          "MotpMarkErr",
                          (marking.mark + chr(4) + errMSG)).
              end .
           end.
        end.
     end.
     else if available marking
     then do:
        if marking.gds-code > 0
        then do :
           cisGdsCode = marking.gds-code .
        end .
        else do :
           cisGdsCode = getGdsCodeByGtin(marking.gds-ext-id) .
        end .
        if cisGdsCode > 0 and
           WeighedProd(cisGdsCode) and
           MarkWeight(marking.mark) = 0 then do:
            find first bf_utd-marking-lines where bf_utd-marking-lines.db-num eq idb-num
                                              and bf_utd-marking-lines.doc-id eq idoc-id
                                              and bf_utd-marking-lines.mark   eq marking.mark
            no-lock no-error.
            errMSG = "Марка не содержит информации о весе товара." .
            MarkChangeSts(marking.mark,
                           objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB,
                           errMSG,
                           yes).
            if marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
               and available bf_utd-marking-lines
            then
                AddUtdErr(idb-num,
                          idoc-id,
                          if available bf_utd-marking-lines
                          then buffer bf_utd-marking-lines:handle
                          else buffer marking:handle,
                          "LoadUtd",
                          "NoWeightMark",
                          (marking.mark + chr(4) + errMSG)).
        end.
     end.
  end.
  method public void MarkChangeSts(imark as char, ists as int, ierrMSG as char, ichld as log):
     define buffer buf_marking for ub.marking.
     define buffer chld_marking for ub.marking.
     do transaction
     on error undo, return:
         find first buf_marking where buf_marking.mark eq imark
         exclusive-lock no-error no-wait.
         if available buf_marking and
            buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
         then do:
            buf_marking.sts = ists.
            if ierrMSG > "" then
               buf_marking.comment = ierrMSG.
            if ichld then
            for each chld_marking exclusive-lock where
                     chld_marking.mark-parent = buf_marking.mark:
                chld_marking.sts = ists.
            end.
         end.
     end.
  end method.
  method private void out2log (iDbNum as integer, iDocId as integer, imark as char, iLevel as int):
    define buffer bf_utd-marking-lines for ub.utd-marking-lines.
    define buffer bf_marking for ub.marking.
    if not isOpenProt then
    do:
      output stream myProt to c:\wrk\impedi-doc.log.
      isOpenProt = yes.
    end.
    else
      output stream myProt to c:\wrk\impedi-doc.log append.
    for first bf_utd-marking-lines no-lock where
              bf_utd-marking-lines.db-num = iDbNum
          and bf_utd-marking-lines.doc-id = iDocId
          and bf_utd-marking-lines.mark   = imark,
        first bf_marking no-lock where
              bf_marking.mark = imark
    :
      put stream myProt unformatted
        fill("  ", iLevel)
        bf_utd-marking-lines.gds-code " "
        bf_utd-marking-lines.doc-level " "
        bf_marking.mark " "
        objSrv:Env:Marking:Sts:Mark:GetLabel(bf_marking.sts) " "
        objSrv:Env:Marking:Sts:Mark:GetLabel(bf_utd-marking-lines.sts)
        skip
      .
    end.
    output stream myProt close.
    for each bf_marking no-lock where
             bf_marking.mark-parent eq iMark,
        first bf_utd-marking-lines no-lock where
              bf_utd-marking-lines.db-num = iDbNum
          and bf_utd-marking-lines.doc-id = iDocId
          and bf_utd-marking-lines.mark = bf_marking.mark
    :
      out2log(iDbNum, iDocId, bf_marking.mark, iLevel + 1).
    end.
  end method.
end class.
