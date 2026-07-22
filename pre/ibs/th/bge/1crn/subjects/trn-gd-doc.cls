using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.str.*.
using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.trn-gd-doc inherits ibs.th.gbl.sys.objth implements iexpsubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Выгрузка документов в 1С" get.
  def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info2 as character format "X(65)" no-undo
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
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define temp-table buf_trn-doc like ub.trn-doc.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_doc-line-attr for ub.doc-line-attr.
  define buffer buf_parts for ub.parts.
  define buffer buf_gds-dtl for ub.gds-dtl.
  define buffer buf_doc-pl for ub.doc-pl.
  define buffer buf_doc-pl-attr for ub.doc-pl-attr.
  define buffer buf_gds for ub.goods.
  define buffer buf_doc-attr for ub.doc-attr.
  define buffer buf_utd for ub.utd .
  define buffer buf_marking-lines for ub.marking-lines .
  define buffer buf_goods for ub.goods .
  define buffer sep_auto-tank-attr  for ub.auto-tank-attr.
  define buffer buf_rvs-doc for ub.rvs-doc .
  define buffer buf_contract-specif for ub.contract-specif .
  define property Msg as character no-undo
    get:
      return trim (Msg, chr(10)).
    end.
    private set (inArg as char):
      Msg = Msg + chr(10) + inArg.
    end.
  define property InitSecTag as character no-undo
    get.
    private set.
  define property DocCode as character no-undo
    get.
    set.
  define property BufTableHndlNew as handle no-undo
    get.
    set.
  define property BufTableHndlOld as handle no-undo
    get.
    set.
  define public property sendTableName as character no-undo init "trn-doc"
    get.
    set.
  define public property sendOldRowid as rowid  no-undo
    get.
    set.
  define public property sendNewRowid as rowid  no-undo
    get.
    set.
  define variable sw               as handle    no-undo.
  define variable v-doc-type-ERPRN as character no-undo.
  define variable v-is-petrol-trn  as logical   no-undo.
  define variable v-is-pieces      as logical   no-undo.
  define variable isDel            as logical   no-undo.
  define variable v-bufhnd         as handle    no-undo.
  define variable v-user-name      as character no-undo.
  define variable v-value             as character no-undo.
  define variable v-type              as character no-undo.
  define variable v-is-lgas-trn       as logical   no-undo.
  define variable v-is-lgas-corr-trn  as logical   no-undo.
  define variable edoc-id             as character no-undo .
  define variable v-is-edo-return     as logical   no-undo.
  define variable v-is-return         as logical   no-undo.
  method public void CrContentToSW (insw as handle):
    sw = insw.
    create buf_trn-doc.
    v-bufhnd = buffer buf_trn-doc:handle.
    if valid-handle (BufTableHndlNew)
    then do:
      sendNewRowid  = BufTableHndlNew:rowid.
      v-bufhnd:buffer-copy (BufTableHndlNew) no-error.
      if error-status:error
      then do:
        Msg = "Ошибка выгрузки trn-gd-code, неверный буфер BufTableHndlNew".
        undo, return error Msg.
      end.
      isDel = false.
    end.
    else do:
      if not valid-handle (BufTableHndlOld)
      then do:
        Msg = "Ошибка выгрузки trn-gd-code, неопеределен ни старый ни новый буфер".
        undo, return error Msg.
      end.
      sendOldRowid  = BufTableHndlOld:rowid.
      v-bufhnd:buffer-copy (BufTableHndlOld) no-error.
      if error-status:error
      then do:
        Msg = "Ошибка выгрузки trn-gd-code, неверный буфер BufTableHndlOld".
        undo, return error Msg.
      end.
      isDel = true.
    end.
    DocCode = buf_trn-doc.doc-code.
run trdcalib_tdat-val in ibs.th.gbl.gbl-hndllib:g#trdcalib (  input DocCode ,
                        input 'edo-return':U ,
                       output v-value ,
                       output v-type ) no-error .
    if v-value = "yes" then
    do:
      assign
        v-is-edo-return = true.
    end.
run trdcalib_tdat-val in ibs.th.gbl.gbl-hndllib:g#trdcalib (  input DocCode ,
                        input 'is-return':U ,
                       output v-value ,
                       output v-type ) no-error .
    if v-value = "yes" then
    do:
      assign
        v-is-return = true.
    end.
    edoc-id = "" .
    if buf_trn-doc.ext-doc-type = 'ie':U
    then do :
      for first buf_utd no-lock where buf_utd.doc-code = DocCode:
        edoc-id = string(buf_utd.DocumentExt) .
      end.
    end .
    if v-is-return
    and buf_trn-doc.reason-code = 25
    then do :
      for first buf_utd no-lock where buf_utd.doc-code = buf_trn-doc.out-code:
        edoc-id = string(buf_utd.DocumentExt) .
      end.
    end .
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in ibs.th.gbl.gbl-hndllib:g#lib-trn
  (
     input buf_doc-line.artic
  ,  input buf_doc-line.prod-type
  ,  input buf_doc-line.prod-code
  , output v-is-petrol-trn
  , output v-is-pieces
  ) .
      if v-is-petrol-trn and not v-is-pieces
        then leave.
    end.
run trdcalib_tdat-val in ibs.th.gbl.gbl-hndllib:g#trdcalib (  input DocCode ,
                        input 'is-lgas':U ,
                       output v-value ,
                       output v-type ) no-error .
    if v-value = "yes" then
    do:
      assign
        v-is-lgas-trn = true.
    end.
run trdcalib_tdat-val in ibs.th.gbl.gbl-hndllib:g#trdcalib (  input DocCode ,
                        input 'is-lgas-corr':U ,
                       output v-value ,
                       output v-type ) no-error .
    if v-value = "yes" then
    do:
      assign
        v-is-lgas-corr-trn = true.
    end.
    if valid-handle (BufTableHndlOld) and BufTableHndlOld:buffer-field("ext-doc-type"):buffer-value = 'iv':U
      then buf_trn-doc.ext-doc-type = BufTableHndlOld:buffer-field("ext-doc-type"):buffer-value.
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run usrfulnm in ibs.th.gbl.gbl-hndllib:g#library
  (input  buf_trn-doc.creid
  ,output v-user-name
  )  .
    if (buf_trn-doc.reason-code = 23 and buf_trn-doc.ext-doc-type = 'ee':U)
    or v-is-return
    then do:
      v-doc-type-ERPRN = "2".
      if v-is-petrol-trn
        then StartDocTrnFuel().
        else StartDocTrn().
      SpiVnesh().
      if v-is-petrol-trn
        then EndDocTrnFuel().
        else EndDocTrn().
    end.
    else do:
      define variable vdoc-type as character no-undo.
      vdoc-type = buf_trn-doc.ext-doc-type.
      case vdoc-type:
         when 'ie':U then do:
            if buf_trn-doc.cli-type = 'маг'
            then
               vdoc-type = 'iv':U.
         end.
         when 're':U then do:
            if buf_trn-doc.cli-type = 'маг'
            then
               vdoc-type = 'rv':U.
         end.
      end case.
      case vdoc-type:
        when 'ie':U then do:
          v-doc-type-ERPRN = "1".
          if v-is-petrol-trn
            then StartDocTrnFuel().
            else StartDocTrn().
          PriVnesh().
          if v-is-petrol-trn
            then EndDocTrnFuel().
            else EndDocTrn().
        end.
        when 'ep':U then do:
          v-doc-type-ERPRN = "2".
          if v-is-petrol-trn
            then StartDocTrnFuel().
            else StartDocTrn().
          SpiVnesh().
          if v-is-petrol-trn
            then EndDocTrnFuel().
            else EndDocTrn().
        end.
        when 'ev':U then do:
          v-doc-type-ERPRN = "3".
          if v-is-petrol-trn
            then StartDocTrnFuel().
            else StartDocTrn().
          RasPerem().
          if v-is-petrol-trn
            then EndDocTrnFuel().
            else do:
              EndDocTrn().
            end.
        end.
        when 'iv':U then do:
          v-doc-type-ERPRN = "4".
          if v-is-petrol-trn
            then StartDocTrnFuel().
            else StartDocTrn().
          PriPerem().
          if v-is-petrol-trn
            then EndDocTrnFuel().
            else EndDocTrn().
        end.
        when 'we':U then do:
          v-doc-type-ERPRN = "5".
          if v-is-petrol-trn
            then StartDocTrnFuel().
            else StartDocTrn().
          SpiVnesh().
          if v-is-petrol-trn
            then EndDocTrnFuel().
            else EndDocTrn().
        end.
        when 'ee':U then do:
          v-doc-type-ERPRN = "7".
          if v-is-petrol-trn
            then StartDocTrnFuel().
            else StartDocTrn().
          SpiVnesh().
          if v-is-petrol-trn
            then EndDocTrnFuel().
            else EndDocTrn().
        end.
        when 'rv':U or when 're':U then do:
          v-doc-type-ERPRN = "8".
          StartDocTrn().
          PriPerem().
          EndDocTrn().
        end.
        otherwise do:
          return.
        end.
      end.
    end.
  end.
  method private void PriVnesh ():
    TrdcAattrPri().
    if v-is-petrol-trn
      then PriVneshLineFuel().
      else PriVneshLine().
  end.
  method private void PriPerem ():
    if v-doc-type-ERPRN = "4"
      then write-data-element ("fuel-st-code", string-mth (buf_trn-doc.cli-code)).
    if v-doc-type-ERPRN = "8"
      then write-data-element ("fuel-st-code", string-mth (buf_trn-doc.cli-code)).
    find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'nids':U no-error. ~
    if available (buf_doc-attr)
    then do:
      write-data-element ('doc-id', buf_doc-attr.attr-value) no-error.
    end.
    if v-is-petrol-trn
      then PriVneshLineFuel().
      else do:
        PriVneshLine().
      end.
  end.
  method private void SpiVnesh ():
    if v-doc-type-ERPRN = "3"
      then write-data-element ("fuel-st-code", string-mth (buf_trn-doc.cli-code)).
    TrdcAattrRas().
    if v-is-petrol-trn
      then RasFuel().
      else Ras().
  end.
  method private void RasPerem ():
    if v-doc-type-ERPRN = "3"
      then write-data-element ("fuel-st-code", string-mth (buf_trn-doc.cli-code)).
    if v-is-petrol-trn
      then RasFuel().
      else Ras().
  end.
  method private void PriVneshLine ():
   define variable vat-pc as character no-undo .
    sw:start-element ("gds").
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code by buf_doc-line.line-num:
      find first buf_gds no-lock where
            buf_gds.artic = buf_doc-line.artic
        and buf_gds.prod-code = buf_doc-line.prod-code
        and buf_gds.prod-type = buf_doc-line.prod-type.
      if buf_trn-doc.contract-code <> 0 then do:
        for first buf_contract-specif no-lock where buf_contract-specif.contract-num = buf_trn-doc.contract-code and
        buf_contract-specif.artic = buf_doc-line.artic and
        buf_contract-specif.prod-code = buf_doc-line.prod-code and
        buf_contract-specif.prod-type = buf_doc-line.prod-type :
          if buf_contract-specif.VAT-type = 'без':U then vat-pc = "-1".
        end.
      end.
      sw:start-element ("gd").
        write-data-element ("line-num", string-mth (buf_doc-line.line-num)).
        write-data-element ("gd-code", string-mth (buf_gds.gds-code)).
        write-data-element ("unit-code", string (buf_doc-line.unit-cli)).
        write-data-element ("koef", string (buf_doc-line.cli-base-rate)).
        write-data-element ("qnty-ttn", string-mth (buf_doc-line.cli-qnty)).
        write-data-element ("qnty-fact", string-mth (buf_doc-line.fact-qnty / buf_doc-line.cli-base-rate)).
        if v-doc-type-ERPRN = "8"
        then do:
          find first buf_gds-dtl where buf_gds-dtl.doc-code = buf_trn-doc.doc-code
            and buf_gds-dtl.artic = buf_gds-dtl.artic
            and buf_gds-dtl.prod-code = buf_gds-dtl.prod-code
            and buf_gds-dtl.prod-type = buf_gds-dtl.prod-type.
          write-data-element ("sum", string-mth (round (buf_gds-dtl.price-rubl * buf_gds-dtl.fact-qnty, 2))).
          write-data-element ("nds-code", if vat-pc <> "" then vat-pc else string-mth ( round (buf_doc-line.VAT-pc , 0))).
          write-data-element ("sum-nds", string-mth ( round ((buf_gds-dtl.price-rubl * buf_gds-dtl.fact-qnty * buf_doc-line.VAT-pc) / (100 + buf_doc-line.VAT-pc) , 2))).
          write-data-element ("sum-s", string-mth ( round (buf_doc-line.price-rubl * buf_doc-line.fact-qnty / (1 + (buf_doc-line.VAT-pc / 100)), 2))).
        end.
        else do:
          def var sum-nds as decimal no-undo.
          def var sum_ as decimal no-undo.
          sum_ = round (buf_doc-line.price-rubl * buf_doc-line.fact-qnty, 2).
          sum-nds = round ((buf_doc-line.price-rubl * buf_doc-line.fact-qnty * buf_doc-line.VAT-pc) / (100 + buf_doc-line.VAT-pc) , 2).
          write-data-element ("sum", string-mth (sum_)).
          write-data-element ("nds-code", if vat-pc <> "" then vat-pc else string-mth ( round (buf_doc-line.VAT-pc , 0))).
          write-data-element ("sum-nds", string-mth (sum-nds)).
          write-data-element ("sum-s", string-mth (sum_ - sum-nds)).
        end.
        writeprts(buf_doc-line.line-num).
        Marks(buf_doc-line.line-num) .
      sw:end-element ("gd").
    end.
    sw:end-element ("gds").
  end.
  method private void PriVneshLineFuel ():
    define variable infoSecsObj     as class InfoSectionsTotal no-undo.
    define variable infoSecObj      as class InfoSection       no-undo.
    define variable ii as integer no-undo.
    define variable is-exist-sec as logical no-undo.
    define variable v-date as date no-undo.
    define variable v-int  as integer no-undo.
    define variable vIsSGDKK as logical no-undo init no .
    define buffer buf_clients-attr for ub.clients-attr .
    infoSecsObj = new InfoSectionsTotal().
    release buf_doc-attr no-error.
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'ptbobj':U no-error.   if available (buf_doc-attr) then write-data-element ('nb', (if buf_doc-attr.attr-value = ""  or buf_doc-attr.attr-value = ? then "" else ((if num-entries (buf_doc-attr.attr-value, ";") = 2 then (entry (2, buf_doc-attr.attr-value, ";" )) else substring (buf_doc-attr.attr-value, 4, length ( buf_doc-attr.attr-value)))))).
    if available buf_doc-attr
    and buf_doc-attr.attr-value > ""
    then do :
      find first buf_clients-attr no-lock where buf_clients-attr.obj-type  = entry(1, buf_doc-attr.attr-value, ";")
                                            and buf_clients-attr.obj-code  = integer(entry(2, buf_doc-attr.attr-value, ";"))
                                            and buf_clients-attr.attr-code = 'owner-code':U
                                            no-error .
      if available buf_clients-attr
      and buf_clients-attr.attr-value > ""
      then do :
        write-data-element ('org-code', substring(buf_clients-attr.attr-value, 4)) no-error.
      end .
      else do :
        write-data-element ('org-code', "") no-error.
      end .
    end .
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'ptb-item-pour':U no-error.   if available (buf_doc-attr) then write-data-element ('ptb-item-pour', (buf_doc-attr.attr-value)).
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'autoent':U no-error.   if available (buf_doc-attr) then write-data-element ('przk', (if buf_doc-attr.attr-value = ""  or buf_doc-attr.attr-value = ? then "" else ((if num-entries (buf_doc-attr.attr-value, ";") = 2 then (entry (2, buf_doc-attr.attr-value, ";" )) else substring (buf_doc-attr.attr-value, 4, length ( buf_doc-attr.attr-value)))))).
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'car-num':U no-error.   if available (buf_doc-attr) then write-data-element ('tanker', (buf_doc-attr.attr-value)).
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'fio-driver':U no-error.   if available (buf_doc-attr) then write-data-element ('driver', (buf_doc-attr.attr-value)).
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'time-income':U no-error.   if available (buf_doc-attr) then write-data-element ('time-income', (buf_doc-attr.attr-value)).
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'inspection-cert':U no-error.   if available (buf_doc-attr) then write-data-element ('inspection-cert', (buf_doc-attr.attr-value)).
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'date-cert':U no-error.   if available (buf_doc-attr) then write-data-element ('date-cert', iso-date (date (buf_doc-attr.attr-value))).
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'condition':U no-error.   if available (buf_doc-attr) then write-data-element ('condition', (buf_doc-attr.attr-value)).
    find first buf_doc-attr no-lock where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'seals-condition':U no-error. ~
    if available (buf_doc-attr)
    then do:
      write-data-element ('seales', entry (1, buf_doc-attr.attr-value, chr(4))) no-error.
      write-data-element ('seales-condition', entry (2, buf_doc-attr.attr-value, chr(4))) no-error.
    end.
    find first buf_doc-attr no-lock where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'car-num':U no-error .
    if available buf_doc-attr
    then do :
      find first sep_auto-tank-attr no-lock where sep_auto-tank-attr.auto-num = buf_doc-attr.attr-value
                                              and sep_auto-tank-attr.attr-code = "auto-sep"
                                              no-error.
      if available sep_auto-tank-attr
      and logical(sep_auto-tank-attr.attr-value)
      then do :
        vIsSGDKK = yes .
      end .
    end .
    if vIsSGDKK = yes
    then do :
      write-data-element ('ess', string(1)) no-error.
    end .
    else do :
      write-data-element ('ess', string(0)) no-error.
    end .
    find first buf_doc-line-attr no-lock where buf_doc-line-attr.doc-code = DocCode and buf_doc-line-attr.attr-code begins "shape" no-error.
    if available (buf_doc-line-attr)
    then do:
      write-data-element ('neck-type', string(lookup(buf_doc-line-attr.attr-value, "Без горловины,Квадратная/прямоугольная,Эллиптическая,Круглая") - 1)) no-error .
    end .
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'date-pour':U no-error.   if available (buf_doc-attr) then write-data-element ('date-pour', iso-date (date (buf_doc-attr.attr-value))).
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'time-pour':U no-error.   if available (buf_doc-attr) then write-data-element ('time-pour', (buf_doc-attr.attr-value)).
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'doc-not':U no-error.   if available (buf_doc-attr) then write-data-element ('doc-not', (buf_doc-attr.attr-value)).
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'spisok-not-doc':U no-error.   if available (buf_doc-attr) then write-data-element ('spisok-not-doc', (buf_doc-attr.attr-value)).
    sw:start-element ("gds").
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code by buf_doc-line.line-num:
      find first buf_gds where
            buf_gds.artic = buf_doc-line.artic
        and buf_gds.prod-code = buf_doc-line.prod-code
        and buf_gds.prod-type = buf_doc-line.prod-type.
      infoSecsObj:Initialization(buf_doc-line.doc-code, buf_gds.gds-code).
      infoSecsObj:GetDBAllAttr ().
      infoSecsObj:CalculateTotal().
      sw:start-element ("gd").
        write-data-element ("line-num", string-mth (buf_doc-line.line-num)).
        write-data-element ("gd-code", string-mth (buf_gds.gds-code)).
        write-data-element ("cap-ttn", string-mth (buf_doc-line.doc-qnty)).
        write-data-element ("wght-ttn", string-mth (buf_doc-line.cli-qnty)).
        write-data-element ("dnsty-ttn", string-mth (buf_doc-line.doc-density)).
        write-data-element ("cap-fact", string-mth (buf_doc-line.fact-qnty)).
        if not infoSecsObj:FactKgQntyTotal = 0
        then do:
          is-exist-sec = true.
          write-data-element ("wght-fact", string-mth (round (infoSecsObj:FactKgQntyTotal, 3))).
        end.
        else do:
          write-data-element ("wght-fact", string-mth (round (buf_doc-line.fact-density * buf_doc-line.fact-qnty, 3))).
        end.
        write-data-element ("dnsty-fact", string-mth (buf_doc-line.fact-density)).
        write-data-element ("sum", string-mth (round (buf_doc-line.price-cli * buf_doc-line.cli-qnty, 2))).
        find first buf_doc-line-attr no-lock where buf_doc-line-attr.doc-code = DocCode
                                               and buf_doc-line-attr.gds-code = buf_gds.gds-code
                                               and buf_doc-line-attr.attr-code = "propan-perc"
                                               no-error .
        if available buf_doc-line-attr
        and buf_doc-line-attr.attr-value > ""
        and decimal(buf_doc-line-attr.attr-value) >= 0
        then do :
          write-data-element ('C3H8', string-mth (decimal(buf_doc-line-attr.attr-value))) .
        end .
      sw:end-element ("gd").
    end.
    sw:end-element ("gds").
    if not buf_trn-doc.cli-code = 800000002 and is-exist-sec and not v-is-lgas-trn and not v-is-lgas-corr-trn
    then do:
      sw:start-element ("scs").
      for each buf_doc-line no-lock where not v-doc-type-ERPRN = '4' and buf_doc-line.doc-code = buf_trn-doc.doc-code:
        find first buf_gds where
              buf_gds.artic = buf_doc-line.artic
          and buf_gds.prod-code = buf_doc-line.prod-code
          and buf_gds.prod-type = buf_doc-line.prod-type.
        infoSecsObj:Initialization(buf_doc-line.doc-code, buf_gds.gds-code).
        infoSecsObj:GetDBAllAttr ().
        do ii = 1 to infoSecsObj:SectionNum:
          infoSecObj = infoSecsObj:GetInfoSectionProp(ii).
          if infoSecObj:FactQnty = 0  or infoSecObj:FactQnty = ?
            then next.
          sw:start-element ("sc").
          write-data-element ("sc-num", string (infoSecObj:SectionName)).
          write-data-element ("gd-line-num", string-mth (buf_doc-line.line-num)).
          write-data-element ("cap-doc", string-mth (if infoSecObj:DocVolume > 0 then infoSecObj:DocVolume else infoSecObj:DocQnty)).
          write-data-element ("dnsty-doc", string-mth (infoSecObj:DocDensity)).
          write-data-element ("standard-dnst", string-mth (infoSecObj:DocDensST)).
          write-data-element ("wght-doc", string-mth (infoSecObj:CliQnty)).
          write-data-element ("acc-ship", string-mth (infoSecObj:AccShip)).
          write-data-element ("cap-psprt", string-mth (infoSecObj:CarVol)).
          write-data-element ("sz-nck", replace(infoSecObj:Diameter, chr(6), " ")).
          if not vIsSGDKK
          then do :
            write-data-element ("filling-method", (if infoSecObj:Pour = "Верхний налив" then '0' else '1')).
            if infoSecObj:DopVolume = ?
            or infoSecObj:DopVolume = 0
            then do :
              infoSecObj:DopVolume = decimal (entry(1, replace(infoSecObj:Diameter, chr(6), " "), "/")) no-error .
              if error-status:error
                then infoSecObj:DopVolume = 0.
            end .
            write-data-element ("pipe-vlm", string (infoSecObj:DopVolume)).
          end .
          write-data-element ("lvl", string-mth (infoSecObj:ABTarir)).
          write-data-element ("cap-nck", string-mth (infoSecObj:Mouth)).
          write-data-element ("cap", string-mth (infoSecObj:TankVol)).
          write-data-element ("dnsty-f", string-mth (infoSecObj:TankDensity)).
          write-data-element ("cap-wtr", string-mth (infoSecObj:TankWater)).
          write-data-element ("t-cap", string-mth (infoSecObj:TankTemp)).
          write-data-element ("t-dnsty", string-mth (infoSecObj:DensTemp)).
          write-data-element ("msd-code", string-mth (infoSecObj:PlaceSi)).
          write-data-element ("mst-code", string-mth (infoSecObj:PlaceSiTemp)).
          write-data-element ("pv-date", string (iso-date (infoSecObj:DatePovPlotn))).
          write-data-element ("dnsty-pr", string-mth (infoSecObj:TankDensityPomi)).
          write-data-element ("cap-pr", string-mth (infoSecObj:TankVolPomi)).
          write-data-element ("wght-pr", string-mth (infoSecObj:TankWeight)).
          write-data-element ("wght-eu", string-mth (infoSecObj:NaturalLoss)).
          write-data-element ("tp-norm", string (infoSecObj:TPNorm)).
          write-data-element ("tp-tank-norm", string-mth (infoSecObj:TPNormPL)).
          write-data-element ("tp-nsn-norm", string-mth (infoSecObj:TPNormAuto)).
          write-data-element ("wght-vpr", string-mth (infoSecObj:AccAbsFact)).
          write-data-element ("ned", string-mth (infoSecObj:Deficit)).
          write-data-element ("izl", string-mth (infoSecObj:Excess)).
          write-data-element ("dnsty-uch", string-mth (infoSecObj:FactDensity)).
          write-data-element ("cap-uch", string-mth (infoSecObj:FactQnty)).
          write-data-element ("wght-uch", string-mth (infoSecObj:FactKgQnty)).
          write-data-element ("sl-date-s", string (iso-date (infoSecObj:DateStart))).
          write-data-element ("sl-time-s", string (infoSecObj:TimeStart, "HH:MM")).
          write-data-element ("sl-date-e", string (iso-date (infoSecObj:DateEnd))).
          write-data-element ("sl-time-e", string (infoSecObj:TimeEnd, "HH:MM")).
          write-data-element ("cmm", string (if infoSecObj:IsKP then "1" else "0")).
          if infoSecObj:IsKP
          then do :
            write-data-element ("acc-meth", string (infoSecObj:AccMeth)).
          end .
          write-data-element ("er-ms", string-mth (infoSecObj:AccPomi)).
          write-data-element ("norm-doc", string (infoSecObj:NormDoc)).
          write-data-element ("passport-num", string (infoSecObj:NumPassport)).
          write-data-element ("passport-dnst", string-mth (infoSecObj:PaspDens)).
          write-data-element ("t-ttn", string-mth (infoSecObj:TTNTemp)).
          case infoSecObj:GroupNP :
            when "I"
            then do :
              write-data-element ("fuel-group", string (1)).
            end .
            when "II"
            then do :
              write-data-element ("fuel-group", string (2)).
            end .
            when "III"
            then do :
              write-data-element ("fuel-group", string (3)).
            end .
            when "IV"
            then do :
              write-data-element ("fuel-group", string (4)).
            end .
          end case .
          if infoSecObj:Pressure > 0
          then
            write-data-element ("dnp", string-mth (infoSecObj:Pressure)).
          if vIsSGDKK
          then do :
            write-data-element ("alrm", (if infoSecObj:alarm-SGDKK then string(1) else string(0))).
            if infoSecObj:aukKey > ""
            then do :
              write-data-element ("auk", string(infoSecObj:aukKey)).
            end .
          end .
          else do :
            write-data-element ("trans-comm", (if infoSecObj:KPnoMeas then string(1) else string(0))).
          end .
          write-data-element ("tank-num", string (infoSecObj:ListTank)).
          write-data-element ("certif-fuel", string (infoSecObj:CertifFuel)).
          write-data-element ("validity-certif", string (infoSecObj:ValidityCertif)).
          write-data-element ("tests", if string (infoSecObj:Tests) = "" then "0" else string (infoSecObj:Tests)).
          write-data-element ("num-print-prob", string (infoSecObj:NumPrintProb)).
          write-data-element ("prob-kol", string-mth (infoSecObj:KolProb)).
          write-data-element ("prob-date", iso-date (infoSecObj:DateProb)).
          write-data-element ("prob-time", string (infoSecObj:HourProb, "99") + ":" + string (infoSecObj:MinProb, "99")).
          find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = 'перед_док':U
                                           and buf_rvs-doc.out-code = buf_trn-doc.doc-code
                                           and num-entries(buf_rvs-doc.rvs-code, "-") = 3
                                           and entry(2, buf_rvs-doc.rvs-code, "-") = infoSecObj:SectionName
                                           no-error .
          if not available buf_rvs-doc
          then do :
            find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = 'перед_док':U
                                             and buf_rvs-doc.out-code = buf_trn-doc.doc-code
                                             no-error .
          end .
          if available buf_rvs-doc
          then do :
            write-data-element ("rvs-before", string (buf_rvs-doc.rvs-code)).
          end .
          find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = 'после_док':U
                                           and buf_rvs-doc.out-code = buf_trn-doc.doc-code
                                           and num-entries(buf_rvs-doc.rvs-code, "-") = 3
                                           and entry(2, buf_rvs-doc.rvs-code, "-") = infoSecObj:SectionName
                                           no-error .
          if not available buf_rvs-doc
          then do :
            find first buf_rvs-doc no-lock where buf_rvs-doc.rvs-type = 'после_док':U
                                             and buf_rvs-doc.out-code = buf_trn-doc.doc-code
                                             no-error .
          end .
          if available buf_rvs-doc
          then do :
            write-data-element ("rvs-after", string (buf_rvs-doc.rvs-code)).
          end .
          sw:end-element ("sc").
        end.
      end.
      sw:end-element ("scs").
    end.
    sw:start-element ("tanks").
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code by buf_doc-line.line-num:
      find first buf_gds where
            buf_gds.artic = buf_doc-line.artic
        and buf_gds.prod-code = buf_doc-line.prod-code
        and buf_gds.prod-type = buf_doc-line.prod-type.
      for each buf_doc-pl where buf_doc-pl.obj-type = buf_doc-line.obj-type and buf_doc-pl.obj-code = buf_doc-line.obj-code
        and buf_doc-pl.out-code = buf_doc-line.doc-code and buf_doc-pl.gds-code = buf_gds.gds-code
        :
        sw:start-element ("tank").
          write-data-element ("gd-line", string-mth (buf_doc-line.line-num)).
          write-data-element ("tank", string-mth (buf_doc-pl.pl-code)).
          write-data-element ("cap-doc", string-mth (buf_doc-pl.doc-qnty)).
          write-data-element ("dnsty-doc", string-mth (buf_doc-line.doc-density)).
          write-data-element ("wght-doc", string-mth (buf_doc-pl.cli-doc-qnty)).
          write-data-element ("dnsty", string-mth ( buf_doc-pl.cli-fact-qnty / buf_doc-pl.fact-qnty)).
          write-data-element ("cap", string-mth (buf_doc-pl.fact-qnty)).
          write-data-element ("wght", string-mth (buf_doc-pl.cli-fact-qnty)).
          find first buf_doc-pl-attr no-lock where buf_doc-pl-attr.obj-code  = buf_doc-pl.obj-code
                                               and buf_doc-pl-attr.obj-type  = buf_doc-pl.obj-type
                                               and buf_doc-pl-attr.gds-code  = buf_doc-pl.gds-code
                                               and buf_doc-pl-attr.pl-code   = buf_doc-pl.pl-code
                                               and buf_doc-pl-attr.out-code  = buf_doc-pl.out-code
                                               and buf_doc-pl-attr.attr-code = "free-vol-exceed"
                                               no-error.
          if available buf_doc-pl-attr
          then do :
            write-data-element ("excess-free", (if logical(buf_doc-pl-attr.attr-value) then "1" else "0")).
          end .
        sw:end-element ("tank").
      end.
    end.
    sw:end-element ("tanks").
  end.
  method private void Ras ():
    sw:start-element ("gds").
  for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code by buf_doc-line.line-num:
      find first buf_gds-dtl where buf_gds-dtl.doc-code = buf_doc-line.doc-code
        and buf_doc-line.artic = buf_gds-dtl.artic
        and buf_doc-line.prod-code = buf_gds-dtl.prod-code
        and buf_doc-line.prod-type = buf_gds-dtl.prod-type.
      find first buf_gds where
            buf_gds.artic = buf_doc-line.artic
        and buf_gds.prod-code = buf_doc-line.prod-code
        and buf_gds.prod-type = buf_doc-line.prod-type.
      sw:start-element ("gd").
        write-data-element ("line-num", string-mth (buf_doc-line.line-num)).
        write-data-element ("gd-code", string-mth (buf_gds.gds-code)).
        write-data-element ("unit-code", string (buf_gds.unit-base)).
        write-data-element ("koef", string (1)).
        write-data-element ("qnty-ttn", string-mth (buf_gds-dtl.doc-qnty)).
        write-data-element ("qnty-fact", string-mth (buf_gds-dtl.fact-qnty)).
        write-data-element ("sum", string-mth (round (buf_gds-dtl.price-rubl * buf_gds-dtl.fact-qnty, 2))).
        write-data-element ("nds-code", string-mth ( round (buf_doc-line.VAT-pc , 0))).
        write-data-element ("sum-nds", string-mth ( round ((buf_gds-dtl.price-rubl * buf_gds-dtl.fact-qnty * buf_doc-line.VAT-pc) / (100 + buf_doc-line.VAT-pc) , 2))).
        write-data-element ("sum-s", string-mth (round (buf_doc-line.price-rubl * buf_gds-dtl.fact-qnty / (1 + (buf_doc-line.VAT-pc / 100)), 2))).
        writeprts(buf_doc-line.line-num).
        Marks(buf_doc-line.line-num) .
      sw:end-element ("gd").
    end.
    sw:end-element ("gds").
  end.
  method private void RasFuel ():
    sw:start-element ("gds").
    for each buf_gds-dtl no-lock where buf_gds-dtl.doc-code = buf_trn-doc.doc-code:
      find first buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code
        and buf_doc-line.artic = buf_gds-dtl.artic
        and buf_doc-line.prod-code = buf_gds-dtl.prod-code
        and buf_doc-line.prod-type = buf_gds-dtl.prod-type.
      find first buf_gds where
            buf_gds.artic = buf_doc-line.artic
        and buf_gds.prod-code = buf_doc-line.prod-code
        and buf_gds.prod-type = buf_doc-line.prod-type.
      sw:start-element ("gd").
        write-data-element ("line-num", string-mth (buf_doc-line.line-num)).
        write-data-element ("gd-code", string-mth (buf_gds.gds-code)).
        write-data-element ("cap-ttn", string-mth (buf_gds-dtl.doc-qnty)).
        write-data-element ("wght-ttn", string-mth (buf_doc-line.cli-qnty)).
        write-data-element ("dnsty-ttn", string-mth (buf_doc-line.doc-density)).
        write-data-element ("cap-fact", string-mth (buf_gds-dtl.fact-qnty)).
        write-data-element ("wght-fact", string-mth (round (buf_doc-line.fact-density * buf_gds-dtl.fact-qnty, 3))).
        write-data-element ("dnsty-fact", string-mth (buf_doc-line.fact-density)).
        write-data-element ("sum", string-mth (round (buf_gds-dtl.price-rubl * buf_gds-dtl.fact-qnty, 2))).
        if v-doc-type-ERPRN = "3" or v-doc-type-ERPRN = "5" or v-doc-type-ERPRN = "7"
          then write-data-element ("t", string-mth (round (buf_doc-line.temperature, 2))).
      sw:end-element ("gd").
    end.
    sw:end-element ("gds").
    sw:start-element ("tanks").
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code by buf_doc-line.line-num:
      find first buf_gds where
            buf_gds.artic = buf_doc-line.artic
        and buf_gds.prod-code = buf_doc-line.prod-code
        and buf_gds.prod-type = buf_doc-line.prod-type.
      for each buf_doc-pl where buf_doc-pl.obj-type = buf_doc-line.obj-type and buf_doc-pl.obj-code = buf_doc-line.obj-code
        and buf_doc-pl.out-code = buf_doc-line.doc-code and buf_doc-pl.gds-code = buf_gds.gds-code
        :
        sw:start-element ("tank").
          write-data-element ("gd-line", string-mth (buf_doc-line.line-num)).
          write-data-element ("tank", string-mth (buf_doc-pl.pl-code)).
          write-data-element ("cap-doc", string-mth (buf_doc-pl.doc-qnty)).
          write-data-element ("dnsty-doc", string-mth (buf_doc-line.doc-density)).
          write-data-element ("wght-doc", string-mth (buf_doc-pl.cli-doc-qnty)).
          write-data-element ("dnsty", string-mth ( buf_doc-pl.cli-fact-qnty / buf_doc-pl.fact-qnty)).
          write-data-element ("cap", string-mth (buf_doc-pl.fact-qnty)).
          write-data-element ("wght", string-mth (buf_doc-pl.cli-fact-qnty)).
        sw:end-element ("tank").
      end.
    end.
    sw:end-element ("tanks").
  end.
  method private void StartDocTrn ():
      InitSecTag =  "trn-gd-docs".
      sw:start-element ("trn-gd-doc") .
        write-data-element ("doc-code", buf_trn-doc.doc-code).
        write-data-element ("doc-num", buf_trn-doc.doc-code).
        write-data-element ("del-f", string (isDel, "1/0") ).
        write-data-element ("doc-date", if buf_trn-doc.doc-date = ? then "" else iso-date (datetime (buf_trn-doc.doc-date, buf_trn-doc.real-time-create * 1000))).
        write-data-element ("fact-date", if buf_trn-doc.fact-date = ? then "" else iso-date (datetime (buf_trn-doc.fact-date, buf_trn-doc.fact-time * 1000))).
        write-data-element ("doc-type", v-doc-type-ERPRN).
        if v-is-edo-return
        then do :
          write-data-element ("edi-return", "1").
        end.
        write-data-element ("doc-rsn-code", (if buf_trn-doc.reason-code = ? then "0" else string-mth (buf_trn-doc.reason-code))).
        write-data-element ("edoc-id", edoc-id).
        write-data-element ("shift-date", if buf_trn-doc.shift-date = ? then "" else iso-date (date (buf_trn-doc.shift-date))).
        write-data-element ("shift-num", if buf_trn-doc.shift-num = ? then "0" else string-mth (buf_trn-doc.shift-num)).
        write-data-element ("contr-code", string-mth (buf_trn-doc.cli-code)).
        write-data-element ("dog-code", string-mth (buf_trn-doc.contract-code)).
        write-data-element ("operator", v-user-name ).
        write-data-element ("psn-wrkr", string-mth (buf_trn-doc.wrkr)).
        write-data-element ("psn-agnt", string-mth (buf_trn-doc.agnt)).
        write-data-element ("psn-boss", string-mth (buf_trn-doc.boss)).
  end.
  method private void EndDocTrn ():
    sw:end-element ("trn-gd-doc") .
  end.
  method private void StartDocTrnFuel ():
      InitSecTag =  "trn-fuel-docs".
      sw:start-element ("trn-fuel-doc") .
        write-data-element ("doc-code", buf_trn-doc.doc-code).
        write-data-element ("doc-num", buf_trn-doc.doc-code).
        write-data-element ("del-f", string (isDel, "1/0") ).
        write-data-element ("doc-date", if buf_trn-doc.doc-date = ? then "" else iso-date (datetime (buf_trn-doc.doc-date, buf_trn-doc.real-time-create * 1000))).
        write-data-element ("fact-date", if buf_trn-doc.fact-date = ? then "" else iso-date (datetime (buf_trn-doc.fact-date, buf_trn-doc.fact-time * 1000))).
        write-data-element ("doc-type", (if v-is-lgas-corr-trn then "9" else v-doc-type-ERPRN)).
        write-data-element ("doc-rsn-code", string-mth (buf_trn-doc.reason-code)).
        write-data-element ("shift-date", if buf_trn-doc.shift-date = ? then "" else iso-date (date (buf_trn-doc.shift-date))).
        write-data-element ("shift-num", if buf_trn-doc.shift-num = ? then "0" else string-mth (buf_trn-doc.shift-num)).
        write-data-element ("contr-code", string-mth (buf_trn-doc.cli-code)).
        write-data-element ("dog-code", string-mth (buf_trn-doc.contract-code)).
        write-data-element ("operator", v-user-name ).
        write-data-element ("psn-wrkr", string-mth (buf_trn-doc.wrkr)).
        write-data-element ("psn-agnt", string-mth (buf_trn-doc.agnt)).
        write-data-element ("psn-boss", string-mth (buf_trn-doc.boss)).
  end.
  method private void EndDocTrnFuel ():
    sw:end-element ("trn-fuel-doc") .
  end.
  method private void Marks (p-line-num as integer):
    define variable v-gds-attr-value-old as character no-undo .
    define variable v-gds-attr-type      as character no-undo .
    define variable vGT as integer no-undo .
    define variable vGtin as character no-undo .
    define variable vQnty as integer no-undo .
    define variable vDocQnty as integer no-undo .
    define variable isVarWeight as logical no-undo init no .
    for first buf_doc-line no-lock where buf_doc-line.doc-code = DocCode
                                    and buf_doc-line.line-num = p-line-num,
      first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and
      buf_goods.prod-code = buf_doc-line.prod-code and
      buf_goods.prod-type = buf_doc-line.prod-type  :
      isVarWeight = WghProdVariable(buf_doc-line.obj-type, buf_doc-line.obj-code, buf_goods.gds-code).
      find first buf_doc-line-attr no-lock where buf_doc-line-attr.doc-code = buf_doc-line.doc-code
                                             and buf_doc-line-attr.gds-code = buf_goods.gds-code
                                             and buf_doc-line-attr.attr-code = "GTIN-qnty"
                                             no-error .
      if available buf_doc-line-attr
      and buf_doc-line-attr.attr-value > ""
      and not isVarWeight
      then do :
        sw:start-element ("marks").
        GT_ :
        do vGT = 1 to num-entries(buf_doc-line-attr.attr-value, ";") :
          assign
            vGtin = entry(1, entry(vGT, buf_doc-line-attr.attr-value, ";"), "=")
            vQnty = integer(entry(2, entry(vGT, buf_doc-line-attr.attr-value, ";"), "="))
          no-error .
          if error-status:error
          then next GT_ .
          sw:start-element ("mark").
          write-data-element ("gtin", vGtin) .
          write-data-element ("gtin-qnt", string-mth(vQnty)) .
          sw:end-element ("mark").
        end .
        sw:end-element ("marks").
      end .
      else do :
                if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
          ( input buf_goods.gds-code
           ,input 'mark-type':U
           ,output v-gds-attr-value-old
           ,output v-gds-attr-type
          )        no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.
        define variable vAvailMarks as logical no-undo.
        for each buf_parts no-lock where buf_parts.out-code  = buf_doc-line.doc-code
                                     and buf_parts.artic     = buf_doc-line.artic
                                     and buf_parts.prod-type = buf_doc-line.prod-type
                                     and buf_parts.prod-code = buf_doc-line.prod-code:
          if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_parts.obj-type, buf_parts.obj-code):GetIsMarkingForType(v-gds-attr-value-old)
          or ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_parts.obj-type, buf_parts.obj-code):GetIsEDOForType(v-gds-attr-value-old)
          or isVarWeight
          then do:
            for each buf_marking-lines no-lock where buf_marking-lines.doc-level = 1 and
              buf_marking-lines.gds-code = buf_goods.gds-code and
              buf_marking-lines.in-code = buf_parts.in-code and
              buf_marking-lines.obj-code = buf_parts.obj-code and
              buf_marking-lines.obj-type = buf_parts.obj-type and
              buf_marking-lines.out-code = buf_parts.out-code and
              buf_marking-lines.part-code = buf_parts.part-code and
              buf_marking-lines.prt-code = buf_parts.prt-code  :
              if buf_marking-lines.mark begins 'tech_':U
              and buf_trn-doc.ext-doc-type <> 'ev':U and buf_trn-doc.ext-doc-type <> 'iv':U
              then next .
              if buf_marking-lines.sts <> ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
              and buf_marking-lines.sts <> ObjSrv:Env:Marking:Sts:Mark:FreeZone:KeyIntDB
              and buf_trn-doc.ext-doc-type = 'iv':U
              then next .
              if not vAvailMarks
              then do:
                 sw:start-element ("marks").
                 vAvailMarks = yes.
              end.
              sw:start-element ("mark").
              if buf_parts.part-code > ""
              then
              write-data-element ("prt-id", buf_parts.part-code).
              write-data-element ("in-doc-id", buf_parts.in-code).
              write-data-element ("mark-code", repTegforDm( addBracketForCode(buf_marking-lines.mark))).
              sw:end-element ("mark").
            end.
          end.
          else
          if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_parts.obj-type, buf_parts.obj-code):GetIsArticForType(v-gds-attr-value-old)
          then do :
            if buf_trn-doc.ext-doc-type = 'ev':U
            or buf_trn-doc.ext-doc-type = 'iv':U
            then do:
              if num-entries(buf_parts.part-code, "_") = 2
              then do :
                vGtin = entry(1, buf_parts.part-code, "_") .
                if length(vGtin) = 8
                or length(vGtin) = 12
                or length(vGtin) = 13
                or length(vGtin) = 14
                then do :
                  vQnty = integer(abs(buf_parts.fact-qnty)) .
                  vDocQnty = integer(abs(buf_parts.qnty)) .
                  if not vAvailMarks
                  then do:
                    sw:start-element ("marks").
                    vAvailMarks = yes.
                  end.
                  sw:start-element ("mark").
                  if buf_parts.part-code > ""
                  then
                  write-data-element ("prt-id", buf_parts.part-code).
                  write-data-element ("in-doc-id", buf_parts.in-code).
                  write-data-element ("gtin", vGtin) .
                  if buf_trn-doc.ext-doc-type = 'iv':U
                  then
                    write-data-element ("gtin-qnt-ttn", string-mth(vDocQnty)) .
                  write-data-element ("gtin-qnt", string-mth(vQnty)) .
                  write-data-element ("upd-id", buf_parts.PS) .
                  sw:end-element ("mark").
                end .
              end .
            end .
            if v-is-return
            then do :
              for each buf_marking-lines no-lock where buf_marking-lines.doc-level = 1 and
                buf_marking-lines.gds-code = buf_goods.gds-code and
                buf_marking-lines.in-code = buf_parts.in-code and
                buf_marking-lines.obj-code = buf_parts.obj-code and
                buf_marking-lines.obj-type = buf_parts.obj-type and
                buf_marking-lines.out-code = buf_parts.out-code and
                buf_marking-lines.part-code = buf_parts.part-code and
                buf_marking-lines.prt-code = buf_parts.prt-code  :
                if buf_marking-lines.mark begins 'tech_':U
                and buf_trn-doc.ext-doc-type <> 'ev':U and buf_trn-doc.ext-doc-type <> 'iv':U
                then next .
                if buf_marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
                and buf_trn-doc.ext-doc-type = 'iv':U
                then next .
                if not vAvailMarks
                then do:
                   sw:start-element ("marks").
                   vAvailMarks = yes.
                end.
                sw:start-element ("mark").
                write-data-element ("in-doc-id", buf_parts.in-code).
                if buf_parts.part-code > ""
                then
                write-data-element ("prt-id", buf_parts.part-code).
                write-data-element ("mark-code", repTegforDm( addBracketForCode(buf_marking-lines.mark))).
                sw:end-element ("mark").
              end.
            end .
          end .
        end.
        if vAvailMarks
        then
          sw:end-element ("marks").
      end .
    end .
  end.
  method private void write-data-element (inTag as char, inValue as char):
    if inValue = ?
    then do:
      Msg = substitute ('Предупреждение отладки: тег &1 иммет не определнное значение. Работа будет продолжена...', inTag).
    end.
    if inTag = ?
    then do:
      Msg = substitute ('Предупреждение отладки: Имя тега не может быть пустым...').
      return.
    end.
    if inTag = "acc-ship"
    then do:
      if string (inValue) begins "."
        then inValue = "0" + inValue.
    end.
    inTag = lc (InTag).
    if inValue = ?
      then
      .
      else sw:write-data-element (inTag, inValue).
  end.
  method private character string-mth (inValue as integer):
    def var v-str as character no-undo.
    if inValue = ?
      then v-str = "0".
      else v-str = string (inValue).
    return v-str.
  end.
  method private character string-mth (inValue as decimal):
    def var v-str as character no-undo.
    if inValue = ?
      then v-str = "0".
    else
      if string (inValue) begins "."
        then v-str = "0" + string (inValue).
        else v-str = string (inValue).
    return v-str.
  end.
  method private void TrdcAattrPri ():
    define buffer bf_doc-line-attr for ub.doc-line-attr .
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'dids':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, iso-date (date (buf_doc-attr.attr-value))).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'nsf':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'dsf':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, iso-date (date (buf_doc-attr.attr-value))).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'ndog':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'ddog':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, iso-date (date (buf_doc-attr.attr-value))).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'nids':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'ndov':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'ddov':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, iso-date (date (buf_doc-attr.attr-value))).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'print-num':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'idCountryContr':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'car-time':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 't_pass-fname':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 't_pass-position':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 't_accept-fname':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 't_accept-position':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'ndovwho':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'nosn':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'Shipper':U no-error.   if available (buf_doc-attr) then write-data-element ('shipper', (if buf_doc-attr.attr-value = ""  or buf_doc-attr.attr-value = ? then "" else ((if num-entries (buf_doc-attr.attr-value, ";") = 2 then (entry (2, buf_doc-attr.attr-value, ";" )) else substring (buf_doc-attr.attr-value, 4, length ( buf_doc-attr.attr-value)))))).
  if v-is-petrol-trn
  then do :
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'othermoves':U no-error.   write-data-element ('othermoves', (if available (buf_doc-attr) and buf_doc-attr.attr-value > "" and logical(buf_doc-attr.attr-value) then "1" else "0" )).
  end .
  if v-is-lgas-trn
  or v-is-lgas-corr-trn
  then do :
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'clear-ac':U no-error.   write-data-element ('cleared', (if available (buf_doc-attr) and buf_doc-attr.attr-value > "" and logical(buf_doc-attr.attr-value) then "1" else "0" )).
    for first bf_doc-line-attr no-lock where bf_doc-line-attr.doc-code = DocCode
                                         and bf_doc-line-attr.attr-code = "connect-hoses"
    :
      if bf_doc-line-attr.attr-value > ""
      and bf_doc-line-attr.attr-value <> ?
      then do :
        write-data-element ("connect-hoses", if logical(bf_doc-line-attr.attr-value) then "1" else "0") .
      end .
    end .
  end .
  end.
  method private void TrdcAattrRas ():
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'ddov':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, iso-date (date (buf_doc-attr.attr-value))).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'ndov':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'nids':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'Recipient':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'Auto':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'Driver':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'print-num':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'idCountryContr':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'nsf':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'dsf':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, iso-date (date (buf_doc-attr.attr-value))).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 't_pass-fname':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 't_pass-position':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 't_accept-fname':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 't_accept-position':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'ndovwho':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
        find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'nosn':U no-error.   if available (buf_doc-attr) then write-data-element (buf_doc-attr.attr-code, buf_doc-attr.attr-value).
  if v-is-petrol-trn
  then do :
            find first buf_doc-attr where buf_doc-attr.doc-code = DocCode and buf_doc-attr.attr-code = 'othermoves':U no-error.   write-data-element ('othermoves', (if available (buf_doc-attr) and buf_doc-attr.attr-value > "" and logical(buf_doc-attr.attr-value) then "1" else "0" )).
  end .
  end.
  method private void writeprts (p-line-num as integer):
    def var vsds as class vsdsubs no-undo.
    def var vsdstr as class vsdtostorage no-undo.
    def var vsdsts as class vsdstatustype no-undo.
    def var ii as integer no-undo.
    define variable v-mercury-value as character no-undo .
    define variable v-mercury-type  as character no-undo .
    define variable v-mercury-prod as logical init false.
    vsdstr = new vsdtostorage ().
    vsdsts = new vsdstatustype ().
    block-doc-line:
    for first buf_doc-line no-lock where buf_doc-line.doc-code = DocCode
                                     and buf_doc-line.line-num = p-line-num:
      find first buf_gds no-lock where
            buf_gds.artic = buf_doc-line.artic
        and buf_gds.prod-code = buf_doc-line.prod-code
        and buf_gds.prod-type = buf_doc-line.prod-type.
run gdscdat in ibs.th.gbl.gbl-hndllib:g#library
  (input  buf_gds.gds-code
  ,input  'mercur_FGIS=request':u
  ,output v-mercury-prod
  ) no-error .
      sw:start-element ("prts").
      for each buf_parts where buf_parts.out-code = buf_doc-line.doc-code
          and buf_parts.artic = buf_doc-line.artic
          and buf_parts.prod-type = buf_doc-line.prod-type
          and buf_parts.prod-code = buf_doc-line.prod-code
      no-lock:
        sw:start-element ("prt").
          if v-is-edo-return
          then do :
            if buf_parts.ps > ""
            and length(buf_parts.ps) = 36
            then do :
              write-data-element ("edoc-id", buf_parts.ps).
            end .
            else do :
              for first buf_utd no-lock where buf_utd.doc-code = buf_parts.in-code :
                write-data-element ("edoc-id", buf_utd.DocumentExt).
              end.
            end .
          end .
          write-data-element ("in-doc-id", buf_parts.in-code).
          if buf_parts.part-code > ""
          then
          write-data-element ("prt-id", buf_parts.part-code).
          if v-mercury-prod
          then do :
            vsds = vsdstr:getVSDsubs(buffer buf_parts).
            if vsds:iCounter > 0
            then do:
              block-vsd:
              do ii = 1 to vsds:GetItem(ii):
                if     vsds:VsdObjCurr:UUID ne ""
                   and vsds:VsdObjCurr:UUID ne ?
                   and (   vsds:VsdObjCurr:VSDType = vsdsts:VSDTrans
                        or vsds:VsdObjCurr:VSDType = vsdsts:VSDIn)
                then do:
                  write-data-element ("vad-guid", vsds:VsdObjCurr:UUID).
                  leave block-vsd.
                end.
              end.
            end.
            delete object vsds no-error.
          end .
          write-data-element ("qnty-ttn", string-mth (buf_parts.qnty)).
          write-data-element ("qnty-fact", string-mth (buf_parts.fact-qnty)).
          write-data-element ("sum", string-mth (round (buf_parts.price-rubl * buf_parts.fact-qnty, 2))).
          write-data-element ("nds-code", if buf_parts.VAT-type = 'без':U then "-1" else string-mth ( round (buf_parts.VAT-pc , 0))).
          write-data-element ("sum-nds", string-mth ( round ((buf_parts.price-rubl * buf_parts.fact-qnty * buf_parts.VAT-pc) / (100 + buf_parts.VAT-pc) , 2))).
          write-data-element ("sum-s", string-mth (round (buf_parts.price-rubl * buf_parts.fact-qnty / (1 + (buf_parts.VAT-pc / 100)), 2))).
        sw:end-element ("prt").
      end.
      sw:end-element ("prts").
    end.
    delete object vsdsts no-error.
    delete object vsdstr no-error.
  end.
end class.
