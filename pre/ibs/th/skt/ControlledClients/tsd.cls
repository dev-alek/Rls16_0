using ibs.th.gbl.*.
using ibs.th.skt.Adapters.*.
using ibs.th.str.alcohol.*.
using ibs.th.skt.ControlledClients.*.
using ibs.th.gbl.sys.objth.
using ibs.th.str.utd.handlers.introduce.
using ibs.th.gbl.env.prmtrs.edo.
using ibs.th.gbl.sys.objsrv.
using ibs.th.str.marking.sts.*.
block-level on error undo, throw.
class ibs.th.skt.ControlledClients.TSD inherits objth:
     define override public property vss-revision    as character no-undo init "$Revision:$":U get .
     define override public property vss-author      as character no-undo init "$Author:$":U get.
     define override public property vss-date        as character no-undo init "$Date:$":U get.
     define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
     define override public property vss-archive     as character no-undo init "$Archive:$":U get.
     define override public property vss-description as character no-undo init "клас для подготовки даныных для ТСД и загрузки из него" get.
method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.
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
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info4 as character format "X(65)" no-undo
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
  def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table TempTrnDoc no-undo
  field line-num     as integer
  field ext-doc-code as character
  field doc-date     as date
  field ext-doc-type as character
  field cli-type     as character
  field cli-code     as integer
  field obj-type     as character
  field obj-code     as integer
  field ps           as character
  field Status_      as character
  field Flags_       as integer
  index pi line-num ext-doc-code .
define temp-table TempDocLine no-undo
  field line-num     as integer
  field gds-code     as integer
  field doc-qnty     as decimal
  field fact-qnty    as decimal
  field price-rubl   as decimal
  field RowSum       as decimal
  field vat-pc       as decimal
  field b-code       as character
  field is-tsd-qnty  as logical   init no
  field aclMarksList as character
  field PartIDTH     as character
  field Flags_       as integer
  field NotDict      as logical
  index pi
  line-num
  gds-code
  .
define temp-table TempDocLineIsTSD like TempDocLine.
define temp-table TempDocLineTSD no-undo
  field gds-code     as integer
  field doc-qnty     as decimal
  field fact-qnty    as decimal
  field artic        as character
  field prod-code    as integer
  field prod-type    as character
  field Flags_error  as logical
  field mark-type    as character
  field mark         as character
  field mark-parent  as character
  index pi
  artic
  prod-code
  prod-type
  mark
  .
define temp-table TempMarkLine no-undo
  field DocName    as character
  field MarkCode   as character
  field PartIDTH   as character
  field Sts        as character
  field MarkParent as character
  field QntyBox    as character
  index pi
  DocName
  MarkCode
  .
  define temp-table TempTSDSetting no-undo
  field sn   as character
  field obj-code  as integer
  field obj-type as character
  field version_ as character
  field lastDate as datetime
  index pi
  sn
  .
  define temp-table TempTrnDocMT no-undo serialize-name "MT_document"
    field DocName as character serialize-name "DocName"
    field DocType as character serialize-name "DocType"
    field Complete_ as logical serialize-name "Complete"
    field Status_ as character serialize-name "Status"
    field ClientID as integer serialize-name "ClientID"
    field ClientType as character serialize-name "ClientType"
    field ObjectID as integer serialize-name "ObjectID"
    field ObjectType as character serialize-name "ObjectType"
    field UserID_ as character serialize-name "UserID"
    field UserName as character serialize-name "UserName"
    field FactSum as decimal serialize-name "FactSum"
    field StartDate as datetime-tz serialize-name "StartDate"
    field Flags_ as integer serialize-name "Flags"
    index DocName DocName.
  define temp-table TempTrnLineMTs no-undo serialize-name "MT_lines"
    field DocName as character serialize-hidden
    index DocName DocName.
  define temp-table TempTrnLineMT no-undo serialize-name "MT_line"
     field lineid as integer serialize-name "LineID"
     field docname as character serialize-hidden
     field pos as integer serialize-name "Pos"
     field goodsid as integer serialize-name "GoodsID"
     field goodsname as character serialize-name "GoodsName"
     field UnitBC as character serialize-name "UnitBC"
     field BC as character serialize-name "BC"
     field Price_ as decimal serialize-name "Price"
     field DocQnty as decimal serialize-name "DocQnty"
     field FactQnty as  decimal serialize-name "FactQnty"
     field Error as character serialize-name "AlcCode"
     field PartIDTH as character serialize-name "PartIDTH"
     field Flags_ as integer serialize-name "Flags"
  index num docname pos.
  define temp-table TempMarkLineMT no-undo serialize-name "MT_MarkLines"
     field LineId as integer serialize-name "LineId"
     field DocName as character serialize-hidden
     field MarkCode as character  serialize-name "MarkCode"
     field PartIDTH as character  serialize-name "PartIDTH"
     field Status_ as character  serialize-name "Sts"
     field MarkParent as character  serialize-name "MarkParent"
     field BoxQnty as integer  serialize-name "BoxQnty"
     field Pos as integer  serialize-name "Pos"
     field UnitBox as character  serialize-name "UnitBox"
  index mark DocName MarkCode.
  define dataset ds-doc serialize-name "MT_documents"
      for TempTrnDocMT
    , TempTrnLineMTs
    , TempTrnLineMT
    , TempMarkLineMT
    data-relation docLines     for TempTrnDocMT, TempTrnLineMTs    relation-fields (DocName, DocName) nested
    data-relation docLine      for TempTrnLineMTs, TempTrnLineMT     relation-fields (DocName, docname) nested
    data-relation docLineMark  for TempTrnLineMT, TempMarkLineMT    relation-fields (PartIDTH, PartIDTH) nested
  .
  define temp-table tt-user no-undo serialize-name "TH_users"
     field user-id    as character serialize-name "userID"
     field user-login as character serialize-name "userName"
  index user-id as unique user-id.
  define dataset ds-user serialize-name "Users"
  for tt-user.
  define temp-table  tt-Objects no-undo serialize-name "TH_objects"
     field obj-type as character serialize-name "obj_type"
     field obj-code as integer serialize-name "obj_code"
     field obj-name as character serialize-name "Name"
  index pi as unique obj-type obj-code.
  define dataset ds-Objects serialize-name "Objects"
  for tt-Objects.
  define temp-table  tt-Clients no-undo serialize-name "TH_clients"
     field obj-type as character serialize-name "cli_type"
     field obj-code as integer serialize-name "cli_code"
     field obj-name as character serialize-name "Name"
  index pi as unique obj-type obj-code.
  define dataset ds-Clients serialize-name "Clients"
  for tt-Clients.
  define temp-table  tt-Goods no-undo serialize-name "TH_Goods"
      field gds-code as integer serialize-name "GoodsID"
      field gds-name as character  serialize-name "Name"
      field unit-base as character serialize-name "UnitBase"
      field countryName  as character serialize-name "Country"
      field factQnty as decimal serialize-name "FactQnty"
      field freeQnty as decimal serialize-name "FreeQnty"
  index pi as unique gds-code.
  define temp-table tt-barcodes no-undo serialize-name "Barcodes"
     field gds-code as integer  serialize-hidden
     index gds-code gds-code.
  define temp-table TempBCode no-undo serialize-name "TH_barcodes"
    field gds-code as integer serialize-name "GoodsID"
    field b-str as character serialize-name "BC"
    field priceSale as decimal serialize-name "PriceBC"
    field unit-cli  as character serialize-name "UnitBC"
    field cliBaseRate as decimal serialize-name "UnitRate"
    field flags as integer serialize-name "Flags"
    index pi is unique primary b-str.
  method public handle CreateDsGoods ():
     define variable hDset as handle no-undo.
     create dataset hDset.
     hDset:set-buffers(buffer tt-goods:handle).
     hDset:serialize-name = "Goods".
     return hDset.
  end.
  method public handle CreateDsBarcodes ():
     define variable hDset as handle no-undo.
     buffer TempBCode:handle:BUFFER-FIELD("gds-code"):serialize-hidden = no .
     create dataset hDset.
     hDset:set-buffers(buffer TempBCode:handle).
     hDset:serialize-name = "Barcodes".
     return hDset.
  end.
  method public handle CreateDsGoodsAndBarcodes ():
     define variable hDset as handle no-undo.
     buffer TempBCode:handle:BUFFER-FIELD("gds-code"):serialize-hidden = yes .
     create dataset hDset.
     hDset:set-buffers(buffer tt-goods:handle,
                       buffer tt-barcodes:handle,
                       buffer TempBCode:handle).
     hDset:serialize-name = "Goods".
     hDset:add-relation(buffer tt-goods:handle,
                        buffer tt-barcodes:handle,
                        "gds-code,gds-code",
                        false,
                        true).
     hDset:add-relation(buffer tt-barcodes:handle,
                        buffer TempBCode:handle,
                        "gds-code,gds-code",
                        false,
                        true).
     return hDset.
  end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile: doc-code.i $ $Revision: f7f4e950f623, 0, rls $".
method public character docCode (parmode as character, parobj-type as character, parobj-code as integer, parroot-doc-code as character):
define variable pardoc-code as character no-undo .
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, 1, 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
  else return pardoc-code .
end method.
method public integer baseCode (p-host-code  as integer) :
  define variable p-ok        as logical no-undo.
  define variable p-base-code as integer no-undo .
  do
    on error undo, return error return-value
    :
    define buffer buf_sysconf for ub.sysconf .
    for first buf_sysconf field (base-code) no-lock
      where buf_sysconf.host-code = p-host-code :
    assign
      p-base-code = buf_sysconf.base-code
      p-ok        = yes
      .
  end.
  if not p-ok
    then
  do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена фирма" skip
      "host-code" p-host-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  else return p-base-code .
end.
end method.
method public character hostName (p-obj-type as character, p-obj-code as integer):
  do
    on error undo, return error return-value
    :
    define variable p-host-code               like ub.price-doc.host-code no-undo .
    define variable p-host-name               like ub.clients.obj-name no-undo .
    define variable l-last-hostname-exist     as logical no-undo initial false .
    define variable v-last-hostname-obj-type  like ub.price-doc.obj-type no-undo .
    define variable v-last-hostname-obj-code  like ub.price-doc.obj-code no-undo .
    define variable v-last-hostname-host-name like ub.clients.obj-name no-undo .
    define variable l-last-hostcode-exist     as logical no-undo initial false .
    define variable v-last-hostcode-obj-type  like ub.price-doc.obj-type no-undo .
    define variable v-last-hostcode-obj-code  like ub.price-doc.obj-code no-undo .
    define variable v-last-hostcode-host-code like ub.price-doc.host-code no-undo .
    if  l-last-hostname-exist = true
      and p-obj-type            = v-last-hostname-obj-type
      and p-obj-code            = v-last-hostname-obj-code
      then
    do:
      assign
        p-host-code = v-last-hostcode-host-code
        p-host-name = v-last-hostname-host-name
        .
      return p-host-name.
    end.
    if  l-last-hostname-exist = true
      and p-obj-type = 'орг':U
      and v-last-hostcode-host-code = p-obj-code then
    do:
      assign
        p-host-code = v-last-hostcode-host-code
        p-host-name = v-last-hostname-host-name
        .
      return p-host-name.
    end.
    define buffer buf_store   for ub.store .
    define buffer buf_shop    for ub.shop .
    define buffer buf_clients for ub.clients.
    define buffer buf_sysconf for ub.sysconf .
    case p-obj-type :
      when 'скл':U
      then
        do:
          find first buf_store no-lock
            where buf_store.obj-code = p-obj-code
            no-error .
          if not available buf_store
            then
          do:
            message
              vss-workfile vss-revision vss-description skip
              "Не найден склад" skip
              "p-obj-type" p-obj-type skip
              "p-obj-code" p-obj-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            p-host-code = buf_store.host-code
            .
        end.
      when 'маг':U
      then
        do:
          find first buf_shop no-lock
            where buf_shop.obj-code = p-obj-code
            no-error .
          if not available buf_shop
            then
          do:
            message
              vss-workfile vss-revision vss-description skip
              "Не найден магазин" skip
              "p-obj-type" p-obj-type skip
              "p-obj-code" p-obj-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            p-host-code = buf_shop.host-code
            .
        end.
      when 'орг':U
      then
        do:
          find first buf_sysconf no-lock
            where buf_sysconf.host-code = p-host-code
            no-error.
          if not available buf_sysconf
            then
          do:
            message
              vss-workfile vss-revision vss-description skip
              "Не найдена СВОЯ фирма" skip
              "p-obj-type" p-obj-type skip
              "p-obj-code" p-obj-code skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          assign
            p-host-code = buf_sysconf.host-code
            .
        end.
      otherwise
      do:
        message
          vss-workfile vss-revision vss-description skip
          "Неизвестный тип объекта" skip
          "p-obj-type" p-obj-type skip
          "p-obj-code" p-obj-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    if p-obj-type <> 'орг':U then
    do:
      assign
        l-last-hostcode-exist     = true
        v-last-hostcode-obj-type  = p-obj-type
        v-last-hostcode-obj-code  = p-obj-code
        v-last-hostcode-host-code = p-host-code
        .
    end.
    find first buf_clients no-lock
      where buf_clients.obj-type = 'орг':U
      and buf_clients.obj-code = p-host-code
      no-error.
    if not available buf_clients
      then
    do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена фирма" skip
        "p-host-code" p-host-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-host-name = buf_clients.obj-name
      .
    if p-obj-type <> 'орг':U then
    do:
      assign
        l-last-hostname-exist     = true
        v-last-hostname-obj-type  = p-obj-type
        v-last-hostname-obj-code  = p-obj-code
        v-last-hostname-host-name = p-host-name
        .
    end.
  end.
  return p-host-name .
end method.
method public integer objdnpay (p-obj-type as character, p-obj-code as integer):
  define variable p-down-pay like ub.store.down-pay no-undo .
  define buffer buf_store for ub.store .
  define buffer buf_shop  for ub.shop  .
  if p-obj-type = 'скл':U
    then
  do:
    for buf_store field (down-pay) no-lock
        where buf_store.obj-code = p-obj-code
      .
      assign
        p-down-pay = buf_store.down-pay
        .
    end.
  end.
  else
  do:
    for buf_shop field (down-pay) no-lock
        where buf_shop.obj-code = p-obj-code
      .
      assign
        p-down-pay = buf_shop.down-pay
        .
    end.
  end.
  return p-down-pay .
end method.
method public character  setCurrentUser():
  define variable vSystemUser as ibs.th.file.asyncparam no-undo.
  define variable vSystemPass as ibs.th.file.asyncparam no-undo.
  define variable mAsyncProc  as class                  ibs.th.file.asyncproc no-undo.
  define variable myUser      as character              initial ? no-undo .
  mAsyncProc = new ibs.th.file.asyncproc().
  vSystemUser = mAsyncProc:getParamObj("SystemUser").
  vSystemPass = mAsyncProc:getParamObj("SystemPass").
  run utl/syspwd.p(input vSystemUser, input vSystemPass)no-error.
  myUser = vSystemUser:valueParam.
  delete object mAsyncProc.
  return myUser .
end.
method public integer gen-b-code(type-code as character):
  define variable p-b-code like ub.bar-code.b-code no-undo .
  define buffer buf_config     for ub.config .
  define buffer buf_sys-ctrl   for ub.sys-ctrl .
  define buffer buf_code-range for ub.code-range .
  define variable l-code         as integer no-undo .
  define variable v-db-num       like ub.db.db-num no-undo .
  define variable cfg-param-code like ub.config.param-code no-undo .
  if type-code = 'sslc':U
    or type-code = 'ssgb':U
    then
  do:
    message
      "Нельзя генерировать локальный или глобальный взвешиваемый код." skip
      "Обратитесь к администратору системы."
      view-as alert-box error .
    undo, return error (if type-code = 'sslc':U then "loc-ss-code":U else "gbl-ss-code" ) .
  end.
  run trg/getpcode.p ( input  type-code
    ,output cfg-param-code
    ).
  l-code = get-next-seq( type-code ).
  find first buf_sys-ctrl no-lock.
  if type-code = 'sclc':U
    or type-code = 'pglc':U
    then
  do:
    assign
      v-db-num = 0
      .
  end.
  else
  do:
    assign
      v-db-num = buf_sys-ctrl.db-num
      .
  end.
  find first buf_code-range no-lock
    where buf_code-range.db-num     = v-db-num
    and buf_code-range.range-type = type-code
    and buf_code-range.stts       = "a"
    use-index stts
    no-error .
  if available buf_code-range
    and l-code <= buf_code-range.last-code
    and l-code >= buf_code-range.first-code then
  do:
    assign
      p-b-code = l-code
      .
  end.
  else
  do:
    if available buf_code-range
      and l-code < buf_code-range.last-code then
    do:
      message
        substitute( "Последовательность для создания кодов с типом &1 имеет неверное значение.", type-code ) skip
        "Обратитесь к администратору системы."
        view-as alert-box error .
      undo, return error "sequence":U .
    end.
    do transaction
      on error  undo, return error substitute( "&1 (gen-b-code). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
      on stop   undo, return error substitute( "&1 (gen-b-code). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (gen-b-code). endkey", vss-workfile )
      :
      find first buf_config exclusive-lock
        where buf_config.param-code = cfg-param-code
        and buf_config.host-code  = 0
        and buf_config.obj-type   = ""
        and buf_config.obj-code   = 0
        and buf_config.beg-date   = 01/01/1900
        and buf_config.end-date   = 01/01/9999
        and buf_config.db-num     = buf_sys-ctrl.db-num
        no-error .
      if not available buf_config then
      do:
        if not locked buf_config then
        do:
          message
            substitute( "Отсутствует конфигурационный параметр 'длина диапазона кодов' (&1) для БД &2.", cfg-param-code, buf_sys-ctrl.db-num ) skip
            "Он должен быть без привязки и с неограниченным сроком действия лицензии."
            "Обратитесь к администратору системы."
            view-as alert-box error .
        end.
        undo, return error "config":U .
      end.
      l-code = get-next-seq( type-code ).
      find first buf_code-range
        where buf_code-range.db-num     = v-db-num
        and buf_code-range.range-type = type-code
        and buf_code-range.stts       = "a"
        use-index stts
        no-error .
      if available buf_code-range
        and l-code <= buf_code-range.last-code
        and l-code >= buf_code-range.first-code
        then
      do:
        assign
          p-b-code = l-code
          .
      end.
      else
      do:
        if available buf_code-range then
        do:
          assign
            buf_code-range.stts = "u"
            .
        end.
        find first buf_code-range
          where buf_code-range.db-num     = v-db-num
          and buf_code-range.range-type = type-code
          and buf_code-range.stts       = "f"
          use-index stts
          no-error .
        if not available buf_code-range then
        do:
          message
            substitute( "Отсутствует свободный диапазон для кодов с типом &1.", type-code ) skip
            "Обратитесь к администратору системы"
            view-as alert-box error .
          undo, return error "code-range":U .
        end.
        assign
          buf_code-range.stts = "a"
          .
        if buf_code-range.first-code = 1 then
        do:
          set-seq-cr( type-code, buf_code-range.first-code ).
          assign
            p-b-code = 1
            .
        end.
        else
        do:
          set-seq-cr( type-code, ( buf_code-range.first-code - 1 )).
          p-b-code = get-next-seq( type-code ).
        end.
      end.
    end.
  end.
end method.
method public integer get-next-seq (type-code as character):
  define variable next-seq as integer no-undo .
    case type-code:
      when 'bcgb':U then do:
        assign
          next-seq = next-value(s-bcgb-code, ub)
        .
      end.
      when 'scgb':U then do:
        assign
          next-seq = next-value(s-scgb-code, ub)
        .
      end.
      when 'sclc':U then do:
        assign
          next-seq = next-value(s-sclc-code, ub)
        .
      end.
      when 'pglc':U then do:
        assign
          next-seq = next-value(s-pglc-code, ub)
        .
      end.
      when 'dcgb':U then do:
        assign
          next-seq = next-value(s-dcgb-code, ub)
        .
      end.
      when 'ctgb':U then do:
        assign
          next-seq = next-value(s-ctgb-code, ub)
        .
      end.
      when 'drgb':U then do:
        assign
          next-seq = next-value(s-drgb-code, ub)
        .
      end.
      when 'fmgb':U then do:
        assign
          next-seq = next-value(s-fmgb-code, ub)
        .
      end.
      when 'pngb':U then do:
        assign
          next-seq = next-value(s-pngb-code, ub)
        .
      end.
      when 'cagb':U then do:
        assign
          next-seq = next-value(s-cagb-code, ub)
        .
      end.
      when 'fdgb':U then do:
        assign
          next-seq = next-value(s-fin-doc, ub)
        .
      end.
    end case.
  return next-seq .
end method.
method public void set-seq-cr (type-code as character, set-val as integer) :
    case type-code:
      when 'bcgb':U then do:
        assign
          current-value(s-bcgb-code, ub) = set-val
        .
      end.
      when 'scgb':U then do:
        assign
          current-value(s-scgb-code, ub) = set-val
        .
      end.
      when 'sclc':U then do:
        assign
          current-value(s-sclc-code, ub) = set-val
        .
      end.
      when 'pglc':U then do:
        assign
          current-value(s-pglc-code, ub) = set-val
        .
      end.
      when 'dcgb':U then do:
        assign
          current-value(s-dcgb-code, ub) = set-val
        .
      end.
      when 'ctgb':U then do:
        assign
          current-value(s-ctgb-code, ub) = set-val
        .
      end.
      when 'drgb':U then do:
        assign
          current-value(s-drgb-code, ub) = set-val
        .
      end.
      when 'fmgb':U then do:
        assign
          current-value(s-fmgb-code, ub) = set-val
        .
      end.
      when 'pngb':U then do:
        assign
          current-value(s-pngb-code, ub) = set-val
        .
      end.
      when 'cagb':U then do:
        assign
          current-value(s-cagb-code, ub) = set-val
        .
      end.
      when 'fdgb':U then do:
        assign
          current-value(s-fin-doc, ub) = set-val
        .
      end.
    end case.
end method.
method public decimal pftxvalg (pargds-code as integer,
  partax-code as integer, par-date as date, parhost-code as integer,
  parobj-type as character, parobj-code as integer):
  define variable partax-value    as decimal   no-undo .
  DEFINE VARIABLE v-fact-order    as decimal   no-undo .
  define buffer buf_tax-rate-gds for ub.tax-rate-gds.
  define buffer buf_goods        for ub.goods.
    assign
      partax-value = ?
      .
    if not can-find (first buf_goods no-lock
      where buf_goods.gds-code = pargds-code)
      then
    do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Код товара" pargds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if par-date = ?
      then
    do:
      assign
        par-date = today
        .
    end.
     v-fact-order = factord-end-day (par-date).
    find last buf_tax-rate-gds no-lock
      where buf_tax-rate-gds.gds-code   = pargds-code
      and buf_tax-rate-gds.tax-code   = partax-code
      and buf_tax-rate-gds.host-code  = 0
      and buf_tax-rate-gds.obj-type   = ""
      and buf_tax-rate-gds.obj-code   = 0
      and buf_tax-rate-gds.fact-order <= v-fact-order
      no-error .
    IF AVAIL buf_tax-rate-gds
      then
    do:
      partax-value = pftxvalo(?, buf_tax-rate-gds.tax-code, buf_tax-rate-gds.rate-code,
        v-fact-order, parhost-code, parobj-type, parobj-code) .
      return partax-value.
    end.
  end method.
method public decimal pftxvalo (par-rc as recid, partax-code as integer, parrate-code  as integer,
  parfact-order as decimal, parhost-code as integer, parobj-type as character, parobj-code   as integer):
  define variable partax-value    as decimal   no-undo .
  define buffer buf_tax-rate       for ub.tax-rate.
  define buffer buf_tax-rate-value for ub.tax-rate-value.
    assign
      partax-value = ?
      .
    if partax-code  = 0
      or parrate-code = 0
      then
    do:
      if par-rc = ?
        then
      do:
        undo, return error "Неверный параметр - recid tax-rate" .
      end.
      find first buf_tax-rate no-lock
        where recid(buf_tax-rate) = par-rc
        no-error .
      if not available buf_tax-rate
        then
      do:
        undo, return error "Не найдена ставка налога " + "recid " + string(par-rc) .
      end.
      if buf_tax-rate.status_ = 'удал':U
        then
      do:
        undo, return error "Ставка налога недействительна "
          + "налог: " + string(buf_tax-rate.tax-code) + " ставка: " + string(buf_tax-rate.rate-code) .
      end.
      assign
        partax-code  = buf_tax-rate.tax-code
        parrate-code = buf_tax-rate.rate-code
        .
    end.
    find last buf_tax-rate-value no-lock
      where buf_tax-rate-value.tax-code   = partax-code
      and buf_tax-rate-value.rate-code  = parrate-code
      and buf_tax-rate-value.host-code  = parhost-code
      and buf_tax-rate-value.obj-type   = parobj-type
      and buf_tax-rate-value.obj-code   = parobj-code
      and buf_tax-rate-value.fact-order <= parfact-order
      and buf_tax-rate-value.status_    = 'тек':U
      no-error .
    if available buf_tax-rate-value
      then
    do:
      assign
        partax-value = buf_tax-rate-value.rate-value
        .
      return partax-value.
    end.
    find last buf_tax-rate-value no-lock
      where buf_tax-rate-value.tax-code   = partax-code
      and buf_tax-rate-value.rate-code  = parrate-code
      and buf_tax-rate-value.host-code  = parhost-code
      and buf_tax-rate-value.obj-type   = ""
      and buf_tax-rate-value.obj-code   = 0
      and buf_tax-rate-value.fact-order <= parfact-order
      and buf_tax-rate-value.status_    = 'тек':U
      no-error .
    if available buf_tax-rate-value
      then
    do:
      assign
        partax-value = buf_tax-rate-value.rate-value
        .
      return partax-value.
    end.
    find last buf_tax-rate-value no-lock
      where buf_tax-rate-value.tax-code   = partax-code
      and buf_tax-rate-value.rate-code  = parrate-code
      and buf_tax-rate-value.host-code  = 0
      and buf_tax-rate-value.obj-type   = ""
      and buf_tax-rate-value.obj-code   = 0
      and buf_tax-rate-value.fact-order <= parfact-order
      and buf_tax-rate-value.status_    = 'тек':U
      no-error .
    if available buf_tax-rate-value
      then
    do:
      assign
        partax-value = buf_tax-rate-value.rate-value
        .
      return partax-value.
    end.
end method.
method public decimal st-sltpc (p-goods-recid    as recid, p-trn-doc-recid  as recid, p-cash-pay as integer):
  define variable p-st-sltpc-slt like ub.doc-line.SLT-pc no-undo.
  def    var      v-host-code    like ub.sysconf.host-code no-undo.
  define variable varslt-yes     as logical no-undo.
  def buffer buf_st-sltpc_goods   for ub.goods.
  def buffer buf_st-sltpc_trn-doc for ub.trn-doc.
  find first buf_st-sltpc_goods   where recid(buf_st-sltpc_goods)     = p-goods-recid.
  find first buf_st-sltpc_trn-doc where recid(buf_st-sltpc_trn-doc)   = p-trn-doc-recid.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_chpsltpc in ibs.th.gbl.gbl-hndllib:g#lib-trn
(
 input  buf_st-sltpc_trn-doc.internal
,input  buf_st-sltpc_trn-doc.doc-type
,input  buf_st-sltpc_trn-doc.pay-code
,input  p-cash-pay
,input  buf_st-sltpc_trn-doc.slt-type
,input  buf_st-sltpc_trn-doc.ext-doc-type
,output varslt-yes
)
no-error.
  if error-status :error then
  do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке установки налога с продаж " skip
      " для товара " buf_st-sltpc_goods.artic buf_st-sltpc_goods.prod-type buf_st-sltpc_goods.prod-code skip
      " в документе " buf_st-sltpc_trn-doc.doc-code skip
      return-value skip
      trim(error-status :get-message(1))
      trim(error-status :get-message(2))
      trim(error-status :get-message(3))
      trim(error-status :get-message(4))
      trim(error-status :get-message(5)) skip
      view-as alert-box error.
    undo, return error .
  end.
  if varslt-yes
    then
  do:
    v-host-code = hostcode(buf_st-sltpc_trn-doc.obj-type, buf_st-sltpc_trn-doc.obj-code) .
    p-st-sltpc-slt = pftxvalg(buf_st-sltpc_goods.gds-code, 2, ?, v-host-code,
      buf_st-sltpc_trn-doc.obj-type, buf_st-sltpc_trn-doc.obj-code) .
  end.
  else
  do:
    assign
      p-st-sltpc-slt = 0
      .
  end.
end method.
method public integer hostcode (p-obj-type  as character, p-obj-code  as integer):
  define variable p-host-code     as integer   no-undo .
  define variable p-ok            as logical   no-undo .
    define variable l-last-hostcode-exist     as logical no-undo initial false .
    define variable v-last-hostcode-obj-type  like ub.price-doc.obj-type no-undo .
    define variable v-last-hostcode-obj-code  like ub.price-doc.obj-code no-undo .
    define variable v-last-hostcode-host-code like ub.price-doc.host-code no-undo .
  if  l-last-hostcode-exist = true
    and p-obj-type            = v-last-hostcode-obj-type
    and p-obj-code            = v-last-hostcode-obj-code
    then
  do:
    assign
      p-host-code = v-last-hostcode-host-code
      .
    return p-host-code.
  end.
  define buffer buf_store for ub.store .
  define buffer buf_shop  for ub.shop .
  case p-obj-type :
    when 'скл':U
    then
      do:
        for first buf_store field (host-code) no-lock
        where buf_store.obj-code = p-obj-code :
        assign
          p-host-code = buf_store.host-code
          p-ok        = yes
          .
      end.
    if not p-ok
      then
    do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найден склад" skip
        "p-obj-type" p-obj-type skip
        "p-obj-code" p-obj-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
    when 'маг':U
    then do:
for first buf_shop field (host-code) no-lock
        where buf_shop.obj-code = p-obj-code :
assign
  p-host-code = buf_shop.host-code
  p-ok        = yes
  .
end.
if not p-ok
  then
do:
  message
    vss-workfile vss-revision vss-description skip
    "Не найден магазин" skip
    "p-obj-type" p-obj-type skip
    "p-obj-code" p-obj-code skip
    view-as alert-box error .
  undo, return error return-value .
end.
end.
    otherwise do:
message
  vss-workfile vss-revision vss-description skip
  "Неизвестный тип объекта" skip
  "p-obj-type" p-obj-type skip
  "p-obj-code" p-obj-code skip
  view-as alert-box error .
undo, return error return-value .
end.
end.
assign
  l-last-hostcode-exist     = true
  v-last-hostcode-obj-type  = p-obj-type
  v-last-hostcode-obj-code  = p-obj-code
  v-last-hostcode-host-code = p-host-code
  .
end method.
method public decimal factord-end-day(p-fact-date            as date) :
  define variable  p-day-end-fact-order   as decimal no-undo .
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
end method.
method public character objExists
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index( vtype, entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
    end.
    return ? .
end.
method public character SearchFile
(input  ifile as character):
   return objExists(ifile,?).
end.
method public character SearchPFile
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r".
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
  end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
method public void gdsoattr-name (
  input p-code            as character,
  output p-type           as character,
  output p-format         as character,
  output p-label          as character,
  output p-user-can-edit  as logical,
  output p-output-display as logical,
  output p-other          as character
  ):
  do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gdsoattr-name in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
method public void gdsoattr-tooltip (
  input  p-code    as character,
  output p-tooltip as character,
  output p-label   as character
  ):
  do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gdsoattr-tooltip in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
method public character gdsoattr-value (
  input  p-code     like ub.gds-obj-attr.attr-code,
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  output p-type     as   character
  ):
  define variable p-value like ub.gds-obj-attr.attr-value no-undo .
  do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gdsoattr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-value.
end.
method public integer gdsoattr-gds-code (
  input p-code     like ub.gds-obj-attr.attr-code,
  input p-value    like ub.gds-obj-attr.attr-value,
  input p-obj-type like ub.gds-obj-attr.obj-type,
  input p-obj-code like ub.gds-obj-attr.obj-code
  ):
  do:
  define variable p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gdsoattr-gds-code in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-gds-code.
end.
method public void gdsoattr-write (
  input p-gds-code like ub.gds-obj-attr.gds-code,
  input p-obj-type like ub.gds-obj-attr.obj-type,
  input p-obj-code like ub.gds-obj-attr.obj-code,
  input p-code     like ub.gds-obj-attr.attr-code,
  input p-value    like ub.gds-obj-attr.attr-value
  ):
  do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gdsoattr-write in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
method public logical gdsoattr-exist (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input  p-code     like ub.gds-obj-attr.attr-code
  ):
  do:
  define variable p-exist    as logical no-undo .
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gdsoattr-exist in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-exist.
end.
method public logical gdsoattr-delete (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input  p-code     like ub.gds-obj-attr.attr-code
  ):
  do:
  define variable p-deleted    as logical no-undo .
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gdsoattr-delete in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-deleted.
end.
method public logical gds-obj-doc-tickets (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input-output p-value as character
  ):
  do:
  define variable p-setted    as logical no-undo .
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-obj-doc-tickets in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-setted.
end.
method public logical gds-obj-dop-alt-name (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input-output p-value as character
  ):
  do:
  define variable p-setted    as logical no-undo .
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-obj-dop-alt-name in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-setted.
end.
method public logical gds-obj-gds-margins (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input-output p-value as character
  ):
  do:
  define variable p-setted    as logical no-undo .
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-obj-gds-margins in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-setted.
end.
method public logical gds-obj-normal-wastage (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  input-output p-value as character
  ):
  do:
  define variable p-setted    as logical no-undo .
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-obj-normal-wastage in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-setted.
end.
method public void gds-attr-margin-value (
  input  p-gds-code like ub.gds-obj-attr.gds-code,
  input  p-obj-type like ub.gds-obj-attr.obj-type,
  input  p-obj-code like ub.gds-obj-attr.obj-code,
  output p-min-value        as decimal,
  output p-max-value        as decimal,
  output p-increase-pc      as decimal,
  output p-rmethod          as character,
  output p-base             as decimal,
  output p-range-margin     as integer,
  output p-exists-margin    as logical,
  output p-range-increase   as integer,
  output p-exists-increase  as logical,
  output p-range-rmethod    as integer,
  output p-exists-rmethod   as logical
  ):
  do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-margin-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
method public class ibs.th.ref.normwastsub gds-o-normal-wastage-value (
  input objNormWast as class ibs.th.ref.normwastsub
  ):
  do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-o-normal-wastage-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return objNormWast.
end.
method public logical gdsoattr-copy (
  input p-code as character
  ):
  define variable p-copy as logical no-undo .
  do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gdsoattr-copy in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-copy.
end.
method public integer gds-attr_check-code-dt-seasons (
  input  p-code     like ub.goods.gds-code,
  input  p-obj-type like ub.clients.obj-type,
  input  p-obj-code like ub.clients.obj-code,
  output p-gds-code like ub.goods.gds-code
  ):
  define variable p-dt-code as integer no-undo .
  do:
        if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr_check-code-dt-seasons in ibs.th.gbl.gbl-hndllib:g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  return p-dt-code.
end.
method public char CrCheckMarkDoc
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
    if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
  ( buf_goods.gds-code,
   'weighed-gds':U,
   output v-par-val,
   output v-par-type
  ).
  v-isweighed = logical(v-par-val) .
  if v-GTIN-qnty = ?
  or v-GTIN-qnty <= 0.0
  then do :
    return substitute ("Не установлен коэффициент для упаковки для марки &1.",imark).
  end .
    if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
  ( buf_goods.gds-code,
   'mark-type':U,
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
v-attr-value = gdsoattr-value (input   'mark-collect-type':U,
                                        input   buf_goods.gds-code,
                                        input   v-cntxt-obj-type,
                                        input   v-cntxt-obj-code,
                                        output  v-attr-type
                                        ) no-error.
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
            return substitute("Для товара &1 ранее был выполнен первоначальный сбор марок.", buf_goods.gds-name).
      end .
    end .
    else do :
      if v-attr-value = ""
      or v-attr-value = "0"
      then do :
           return substitute("Для товара &1 не выполнен первоначальный сбор марок, товар не может быть добавлен в документ без признака «Первоначальный сбор марок». Создайте для товара отдельный документ", buf_goods.gds-name).
      end .
    end .
    define buffer bf_utd-lines for ub.utd-lines.
    find last bf_utd-lines no-lock where bf_utd-lines.db-num    = idb-num
                                     and bf_utd-lines.doc-id    = idoc-id
    no-error .
    define variable vLineNum as integer no-undo.
    vLineNum = if available bf_utd-lines then (bf_utd-lines.linenum + 1) else 1.
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
  define stream str1 .
  define stream str2 .
  define stream logTSD .
  define public property SomeStr as longchar no-undo
    get.
    set.
  define public property ObjCode as integer no-undo
    private get.
    set.
  define public property ObjType as character no-undo
    private get.
    set (arg as char):
       ObjType = if arg eq "sho"
                 then
                    "маг"
                 else
                    arg.
    end.
  define public property SN as character no-undo
    private get.
    set.
  define public property ReqType as character no-undo
    get.
    set.
  define public property ResType as character no-undo
    get.
    set.
  define public property CurrDecSeparator as character no-undo init ","
      get.
      set.
  define public property CurrDecSeparatorTH as character no-undo
      get:
        return session:numeric-decimal-point.
      end.
  define public property IsMarkOn as logical no-undo init false
      get.
      set.
  define public property CP as character no-undo init "UTF-8"
    get.
    set.
  define private stream tsdstream.
  define private variable logWrite     as class     LogWrite     no-undo.
  define private variable keyrec       as class     keyrec       no-undo.
  define private variable v-keyrec     as character no-undo.
  define         variable v-today  as date      no-undo .
  define variable bc-frmt         as character no-undo .
  define variable bc-pfx          as character no-undo .
  define variable dbNum as integer no-undo.
  define variable myflagsDoc         as class flagsdoc         no-undo.
  define variable myflagsBarcode     as class flagsbarcode     no-undo.
  constructor public TSD (  ):
    super().
    dbNum = GetDbNumLocal().
    myflagsDoc     = new flagsdoc ().
    myflagsbarcode = new flagsbarcode ().
    define variable v-par-type as character no-undo.
    keyrec = new keyrec ().
    logWrite = new LogWrite().
    if not valid-handle (ibs.th.gbl.gbl-hndllib:g#trdcalib)
    then do:
      run str/trdcalib.p persistent no-error.
    end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    run gbl/conf-rd.p ("bc-pfx", "", "", 0, "", "", "", yes, output bc-pfx, output v-par-type) no-error.
    run gbl/conf-rd.p ("bc-frmt", "", "", 0, "", "", "", yes, output bc-frmt, output v-par-type) no-error.
    os-delete value (search ("MT_documents.txt")) no-error.
    os-delete value (search ("MT_lines.txt")) no-error.
    os-delete value (search ("MT_MarkLines.txt")) no-error.
  end constructor.
  method public void clear():
     os-delete value (search ("MT_documents.txt")) no-error.
    os-delete value (search ("MT_lines.txt")) no-error.
    os-delete value (search ("MT_MarkLines.txt")) no-error.
    docClear().
  end.
  method private void tsdstreamopen (streamFile as char):
    output stream tsdstream to value (streamFile).
  end method.
  method private void tsdstreamopenapp (streamFile as char):
    output stream tsdstream to value (streamFile) append.
  end method.
  method private void tsdstreamclose ():
    output stream tsdstream close.
  end method.
  method public longchar getStatusXml (statusOk as logical, statusMsg as longchar):
     return getStatusXml(statusOk,statusMsg,"").
  end.
  method public longchar getStatusXml (statusOk as logical, statusMsg as longchar, iDopTag as longchar):
    define variable statusOkTag as character no-undo.
    define variable statusMsgTag as character no-undo.
    assign
      statusOkTag = substitute ('<STATUS>&1</STATUS>', if statusOk then "OK" else "ERROR")
      statusMsgTag = if statusOk then '' else substitute ('<STATUS_MESSAGE>&1</STATUS_MESSAGE>', statusMsg)
    .
    return substitute ('<?xml version="1.0" encoding="&1"?><TSD>&2&3&4</TSD>', CP, statusOkTag, statusMsgTag,iDopTag).
  end method.
  method public void getWB ():
    define variable dFactSum   as decimal   no-undo.
    define variable priceSale  as dec no-undo.
    define variable docType    as character no-undo.
    define variable hour     as integer no-undo.
    define variable minute   as integer no-undo.
    define variable sec      as integer no-undo.
    define variable timeleft as integer no-undo.
    define variable decDocQnty as decimal no-undo.
    define variable decFactQnty as decimal no-undo.
    define variable jj as integer no-undo.
    define variable jjm as integer no-undo.
    define variable iim as integer no-undo.
    define buffer buf_trn-doc    for ub.trn-doc.
    define buffer buf_doc-line   for ub.doc-line.
    define buffer buf_goods      for ub.goods.
    define buffer buf_bar-code   for ub.bar-code.
    define buffer buf_parts      for ub.parts.
    define buffer buf_gen-attr   for ub.gen-attr.
    define buffer buf_user-login for ub.user-login.
    define buffer inv-doc-attr for ub.inv-doc-attr.
    define buffer goods-attr for ub.goods-attr.
    def    var      internal-b-code like ub.bar-code.b-code no-undo .
    def    var      full-b-code     as character init "" no-undo .
    define variable myflagsDoc     as class flagsdoc     no-undo.
    define variable myflagsDocLine as class flagsdocline no-undo.
    myflagsDoc = new flagsdoc ().
    myflagsDocLine = new flagsdocline ().
    block-trn:
    for each buf_trn-doc where
            buf_trn-doc.obj-type = ObjType
        and buf_trn-doc.obj-code = ObjCode
        and ( ((buf_trn-doc.ext-doc-type = 'ee':U
              or buf_trn-doc.ext-doc-type = 'ev':U
              or buf_trn-doc.ext-doc-type = 'vt':U)
              and buf_trn-doc.flag_ = true
              and buf_trn-doc.status_ = 'разрешен':U)
            or
              ((buf_trn-doc.ext-doc-type = 'ie':U
              or buf_trn-doc.ext-doc-type = 'iv':U)
              and buf_trn-doc.flag_ = true
              and buf_trn-doc.status_ = 'накл':U)
            )
      no-lock:
    for each inv-doc-attr no-lock where (inv-doc-attr.doc-code = buf_trn-doc.doc-code
                                and inv-doc-attr.attr-code = "ItogInv") or ( inv-doc-attr.doc-code = buf_trn-doc.doc-code
                                  and inv-doc-attr.attr-code = "ItogInvManual" ):
       next block-trn.
    end.
    find first inv-doc-attr no-lock where inv-doc-attr.doc-code = buf_trn-doc.doc-code and inv-doc-attr.attr-code = "invMultDevice" and inv-doc-attr.attr-value = string(true) no-error .
    if not available (inv-doc-attr) and buf_trn-doc.ext-doc-type = 'vt':U then next .
    logWrite:WriteDebugLog( "Выгружаем документ " + buf_trn-doc.doc-code).
      myflagsDoc:unSetAllFlags().
      case buf_trn-doc.ext-doc-type:
        when 'ee':U then do:
          docType = "ExtSalesWB".
        end.
        when 'ev':U then do:
          docType = "IntSalesWB".
        end.
        when 'ie':U then do:
          docType = "ExtPurchWB".
        end.
        when 'iv':U then do:
          docType = "IntPurchWB".
        end.
        when 'vt':U then do:
          docType = "Inv".
        end.
      end case.
      if IsMarkOn and not docType = 'Inv'
      then do:
        for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code no-lock:
          find first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and buf_goods.prod-code = buf_doc-line.prod-code
            and buf_goods.prod-type = buf_doc-line.prod-type.
          find first goods-attr where goods-attr.gds-code = buf_goods.gds-code
            and goods-attr.attr-code = 'mark':U and goods-attr.attr-value = "yes" no-lock no-error.
          if available (goods-attr)
          then do:
            myflagsDoc:isDocMarkOn = true.
            leave.
          end.
        end.
      end.
      def var pos as int no-undo.
      if not myflagsDoc:isDocMarkOn
      then do:
        pos = 0.
        for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code no-lock:
          find first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and buf_goods.prod-code = buf_doc-line.prod-code and buf_goods.prod-type = buf_doc-line.prod-type.
          find first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code
            and buf_bar-code.unit-cli = buf_goods.unit-base.
          myflagsDocLine:unSetAllFlags().
          internal-b-code = buf_bar-code.b-code.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str9  as character no-undo.
  define variable tmp-num9  as character no-undo.
  define variable i9        as integer   no-undo.
  define variable sum9      as integer   no-undo.
  define variable len-code9 as integer   no-undo.
  define variable varcont9  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str9 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str9 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont9 = yes then do:
    if integer( substring( tmp-str9, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str9, length( bc-pfx ) + 1, length( tmp-str9 ) - length( bc-pfx ) )
        len-code9    = length( full-b-code )
      .
      define variable v-sum-char9 as character no-undo .
      assign
        sum9 = 0
      .
      do i9 = 1 to len-code9 by 2
      :
        assign
          v-sum-char9 = substr(full-b-code, len-code9 - i9 + 1, 1)
        .
        if v-sum-char9 < "0"
        or v-sum-char9 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum9 = sum9 + integer(v-sum-char9)
        .
      end.
      if varcont9 = yes then do:
        assign
          sum9 = sum9 * 3
        .
        do i9 = 2 to len-code9 by 2
        :
          assign
            v-sum-char9 = substr(full-b-code, len-code9 - i9 + 1, 1)
          .
          if v-sum-char9 < "0"
          or v-sum-char9 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum9 = sum9 + integer(v-sum-char9)
          .
        end.
        if varcont9 = yes then do:
           if sum9 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum9 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
          pos = pos + 1.
          decDocQnty = if docType = 'inv' then buf_doc-line.doc-qnty - buf_doc-line.fact-qnty else buf_doc-line.doc-qnty.
          decFactQnty = if docType = 'inv' then buf_doc-line.doc-qnty else buf_doc-line.fact-qnty.
          assign
            priceSale   = if buf_doc-line.price-rubl <> ? then buf_doc-line.price-rubl else 0
            .
         jjm = jjm + 1.
         addDocLine(jjm,
                      buf_trn-doc.doc-code,
                       if docType = 'inv' then pos else buf_doc-line.line-num,
                      buf_goods.gds-code,
                       buf_goods.gds-name ,
                      buf_goods.unit-base,
                      full-b-code,
                       priceSale,
                       decDocQnty,
                       0,
                      "",
                      "",
                       myflagsDocLine:FlagsToInt  ).
        end.
      end.
      else do:
        def var v-alc-code as char no-undo.
        pos = 0.
        for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code no-lock:
          find first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and buf_goods.prod-code = buf_doc-line.prod-code and buf_goods.prod-type = buf_doc-line.prod-type.
          find first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code.
          for each buf_parts no-lock where
            buf_parts.obj-type = buf_trn-doc.obj-type and
            buf_parts.obj-code = buf_trn-doc.obj-code and
            buf_parts.artic = buf_doc-line.artic and
            buf_parts.prod-type = buf_doc-line.prod-type and
            buf_parts.prod-code = buf_doc-line.prod-code and
            buf_parts.out-code = buf_trn-doc.doc-code:
            internal-b-code = buf_bar-code.b-code.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str10  as character no-undo.
  define variable tmp-num10  as character no-undo.
  define variable i10        as integer   no-undo.
  define variable sum10      as integer   no-undo.
  define variable len-code10 as integer   no-undo.
  define variable varcont10  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str10 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str10 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont10 = yes then do:
    if integer( substring( tmp-str10, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str10, length( bc-pfx ) + 1, length( tmp-str10 ) - length( bc-pfx ) )
        len-code10    = length( full-b-code )
      .
      define variable v-sum-char10 as character no-undo .
      assign
        sum10 = 0
      .
      do i10 = 1 to len-code10 by 2
      :
        assign
          v-sum-char10 = substr(full-b-code, len-code10 - i10 + 1, 1)
        .
        if v-sum-char10 < "0"
        or v-sum-char10 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum10 = sum10 + integer(v-sum-char10)
        .
      end.
      if varcont10 = yes then do:
        assign
          sum10 = sum10 * 3
        .
        do i10 = 2 to len-code10 by 2
        :
          assign
            v-sum-char10 = substr(full-b-code, len-code10 - i10 + 1, 1)
          .
          if v-sum-char10 < "0"
          or v-sum-char10 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum10 = sum10 + integer(v-sum-char10)
          .
        end.
        if varcont10 = yes then do:
           if sum10 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum10 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
            myflagsDocLine:unSetAllFlags().
            decDocQnty = buf_parts.qnty.
            decFactQnty = buf_parts.fact-qnty.
            assign
              priceSale   = if buf_parts.price-rubl <> ? then buf_parts.price-rubl else 0
              .
            assign
              .
            keyrec:GenKeyRec('parts':U, buffer buf_parts:handle, output v-keyrec).
            v-alc-code = if num-entries  (buf_parts.alc-ref-ab-path, ",") < 3 then "" else entry (3, buf_parts.alc-ref-ab-path, ",").
            pos = pos + 1.
            iim = 0.
            for each buf_gen-attr no-lock where buf_gen-attr.p-key = v-keyrec and buf_gen-attr.table-name = 'excise-mark':U:
              iim = iim + 1.
              jj = jj + 1.
              addDocLineMark(
                    jj,
                      buf_trn-doc.doc-code,
                    pos,
                      buf_gen-attr.attr-code,
                      v-keyrec,
                    "TH",
                    ?,
                    ?,
                    "").
            end.
              jjm = jjm + 1.
              if decimal (iim) = buf_parts.qnty
                then myflagsDocLine:isEditManualFullQnty = true.
                else myflagsDocLine:isNotEditManualQnty = true.
             addDocLine(jjm,
                      buf_trn-doc.doc-code,
                       pos,
                       buf_goods.gds-code,
                       buf_goods.gds-name ,
                      buf_goods.unit-base,
                      full-b-code,
                       priceSale,
                       decDocQnty,
                       0,
                      "",
                      v-keyrec,
                       myflagsDocLine:FlagsToInt  ).
          end.
        end.
      end.
      if buf_trn-doc.ext-doc-type = 'vt':U then myflagsDoc:isDocMarkOn = yes.
      find first buf_user-login where buf_user-login.user-id = buf_trn-doc.user-name  no-lock no-error.
      addDoc(
           buf_trn-doc.doc-code,
           docType,
           false,
           buf_trn-doc.status_ + string (buf_trn-doc.flag, "+/-"),
           buf_trn-doc.cli-code,
           buf_trn-doc.cli-type,
           buf_trn-doc.obj-code,
           buf_trn-doc.obj-type,
           buf_trn-doc.user-name,
           if available (buf_user-login) then buf_user-login.user-login else "",
           dFactSum,
           datetime-tz (buf_trn-doc.doc-date, buf_trn-doc.real-time-create * 1000),
           myflagsDoc:FlagsToInt
      ).
        logWrite:WriteDebugLog( "Выгружен документ " + buf_trn-doc.doc-code).
    end.
  end method.
  method public void Check_ ():
    define variable confPar   as character no-undo.
    define variable parType   as character no-undo.
    define variable statusOK  as logical   no-undo init false.
    define buffer buf_clients   for ub.clients.
    run gbl/conf-rd.p ("tsd-list", "", "", 0, "", "", "", no, output confPar, output parType) no-error.
    if lookup (SN, confPar, ";") > 0
      then statusOK = true.
    find first buf_clients no-lock
      where buf_clients.obj-type = ObjType and buf_clients.obj-code = ObjCode no-error.
    if available (buf_clients)
      then statusOK = true.
          else statusOK = false.
    if true // Зачем неписать сообщение об ошибке если в ответ всеравно отправляется ошибка
    then do:
       importVersion().
       SomeStr = getStatusXml(statusOK, "",getVersion()).
    end.
    else SomeStr = if lookup (SN, confPar) = 0 then getStatusXml(statusOK, "LIC") else getStatusXml(statusOK, "OBJ").
  end method.
  method public character createTegLogical (iTeg as char,
                                     iValue as logical):
      if ivalue eq ? then return createTeg(iteg,?).
      return createTeg(iteg,trim(string(ivalue,"true/false"))).
  end.
  method public character createTeg (iTeg as char,
                                     iValue as char):
      if ivalue eq "" or ivalue eq ? then return "".
      return substitute ("<&1>&2</&1>",iteg,ivalue).
  end.
  method public void getSettings ():
    define variable confPar   as character no-undo.
    define variable parType   as character no-undo.
    define variable validSN   as logical   no-undo init ?.
    define variable validObj  as logical   no-undo init ?.
    define buffer buf_clients   for ub.clients.
    run gbl/conf-rd.p ("tsd-list", "", "", 0, "", "", "", no, output confPar, output parType) no-error.
    if SN ne ? and SN ne ""
    then
       validSN = lookup (SN, confPar, ";") > 0.
    ObjectsClear().
    getCurrentObjects().
    ObjectsPrint("xml").
    SomeStr = substring (SomeStr,index(SomeStr,">") + 1).
    if ObjType ne ? and ObjType ne ""
    then do:
      find first buf_clients no-lock
         where buf_clients.obj-type = ObjType and buf_clients.obj-code = ObjCode no-error.
      validObj = available (buf_clients).
    end.
    importVersion().
    SomeStr = getStatusXml(true, "",
    substitute ("&1&2&3&4",
    getVersion(),
    SomeStr,
    createTegLogical("validSN",validSN),
    createTegLogical("validObj",validObj))).
  end method.
  method public void setResult (iFile as char):
      copy-lob
          from  file search(iFile)
          to object SomeStr
          no-convert
       no-error .
  end.
  method public void writeResult (iFile as char):
      writeResult(iFile,?).
  end.
  method public void writeResult (iFile as char, iencode as char):
      if(iencode eq ?)
      then do:
         copy-lob
            from object SomeStr
            to file iFile
            no-convert
         .
       end.
       else do:
          copy-lob
            from object SomeStr
            to  file iFile
            convert  TARGET CODEPAGE iencode
          .
       end.
  end.
  method public void WriteUsers (idir as char):
     GetUsers ().
     UsersPrint(ResType, idir + "\TH_users." + if ResType eq ? or ResType eq "" then "txt" else "json" ).
  end.
  method public void usersClear ():
     empty temp-table tt-user.
  end.
  method public void GetUsers ():
    define buffer buf_user-login for ub.user-login.
    for each buf_user-login where buf_user-login.status_ = 0 and buf_user-login.db-num = dbNum no-lock:
      create tt-user.
      assign
         tt-user.user-id = buf_user-login.user-id
         tt-user.user-login = buf_user-login.user-login
         .
    end.
  end.
  method public void UsersPrint (type as character):
     UsersPrint(type,?).
  end.
  method public void UsersPrint (type as char, file as char):
    if    type eq "xml"
       or type eq "json"
    then do:
       ttprint(type, dataset ds-user :handle).
       if (file ne "" and file ne ?)
       then
          writeResult(file,"utf-8").
    end.
    else do:
       if file eq ?
       then
          file = "temp_tsd.txt".
       tsdstreamopen(file).
       for each tt-user no-lock:
         put stream tsdstream unformatted tt-user.user-id + chr(30) + tt-user.user-login + chr(31).
    end.
    tsdstreamclose().
       if file = "temp_tsd.txt"
       then
          setResult(file).
  end.
  end.
  method public void WriteObjects (idir as char):
     getObjects().
     ObjectsPrint(ResType, idir + "\TH_objects." + if ResType eq ? or ResType eq "" then "txt" else "json" ).
  end.
  method public void ObjectsClear ():
     empty temp-table tt-Objects.
  end.
  method public void getObjects ():
    define buffer buf_clients   for ub.clients.
    for each buf_clients where buf_clients.stts = 0 and (buf_clients.obj-type = "маг" or buf_clients.obj-type = "скл") no-lock:
       create tt-Objects.
       assign
          tt-Objects.obj-type = buf_clients.obj-type
          tt-Objects.obj-code = buf_clients.obj-code
          tt-Objects.obj-name = buf_clients.obj-name
       .
    end.
  end.
  method public void getCurrentObjects ():
  define buffer buf_clients for ub.clients .
  for each buf_clients where buf_clients.stts = 0
                         and buf_clients.db-num eq dbnum no-lock:
       create tt-Objects.
       assign
          tt-Objects.obj-type = buf_clients.obj-type
          tt-Objects.obj-code = buf_clients.obj-code
          tt-Objects.obj-name = buf_clients.obj-name
       .
    end.
  end.
  method public void ObjectsPrint (type as char):
     ObjectsPrint(type, ?).
  end.
  method public void ObjectsPrint (type as char,file as char):
    define buffer buf_clients   for ub.clients.
    if    type eq "xml"
       or type eq "json"
    then do:
       ttprint(type, dataset ds-Objects :handle).
       if (file ne "" and file ne ?)
       then
          writeResult(file,"utf-8").
    end.
    else do:
       if file eq ""
       then
          file = "temp_tsd.txt".
       tsdstreamopen(file).
       for each tt-Objects no-lock:
     put stream tsdstream unformatted
         string (tt-Objects.obj-code) + chr(30) +
         tt-Objects.obj-type + chr(30) +
         tt-Objects.obj-name +
      chr(31).
    end.
    end.
    tsdstreamclose().
       if file = "temp_tsd.txt"
       then
          setResult(file).
  end.
  method public void WriteClients (idir as character):
     ClientsClear().
     getClients().
     ClientsPrint(resType, idir + "\TH_clients."  + if ResType eq ? or ResType eq "" then "txt" else "json" ).
  end.
  method public void ClientsClear ():
     empty temp-table tt-Clients.
  end.
  method public void getClients ():
    define buffer buf_clients   for ub.clients.
    for each buf_clients where buf_clients.stts = 0 and (buf_clients.obj-type = "орг"
      or buf_clients.obj-type = "чел" or buf_clients.obj-type = 'маг':U or buf_clients.obj-type = 'скл':U)
      and not (buf_clients.obj-type = ObjType and buf_clients.obj-code = ObjCode) no-lock:
      create tt-Clients.
       assign
          tt-Clients.obj-type = buf_clients.obj-type
          tt-Clients.obj-code = buf_clients.obj-code
          tt-Clients.obj-name = buf_clients.obj-name
       .
    end.
  end.
  method public void ClientsPrint (type as char):
     ClientsPrint(type,?).
  end.
  method public void ClientsPrint (type as char,file as char):
    if    type eq "xml"
       or type eq "json"
    then do:
       ttprint(type, dataset ds-Clients :handle).
       if (file ne "" and file ne ?)
       then
          writeResult(file,"utf-8").
    end.
    else do:
       if file eq ""
       then
          file = "temp_tsd.txt".
       tsdstreamopen(file).
       for each tt-Clients no-lock:
         put stream tsdstream unformatted string (tt-Clients.obj-code) + chr(30) + tt-Clients.obj-type + chr(30) + tt-Clients.obj-name + chr(31).
    end.
    tsdstreamclose().
       if file = "temp_tsd.txt"
       then
          setResult(file).
     end.
  end.
  method public void GoodsClear ():
     empty temp-table tt-Goods.
  end.
  method public void getGoods ():
     getGoodsAndBarcodes(yes,no,?).
  end.
  method public void getGoodsAndBarcodes (iGoods as logical ,ibarcode as logical, input iprotocol as char):
     define variable factQnty    as dec no-undo.
     define variable freeQnty    as dec no-undo.
     define variable countryName as character no-undo.
     define variable dPriceSale  as decimal   no-undo.
     define variable dVatPc      as decimal   no-undo.
     define variable is-petrol   as logical no-undo.
     define variable is-pieces   as logical no-undo.
     define variable priceSale   as decimal no-undo.
     define variable cliBaseRate as decimal no-undo.
     define buffer buf_goods     for ub.goods.
     define buffer buf_gds-obj   for ub.gds-obj.
     define buffer buf_bar-code  for ub.bar-code.
     define buffer buf_price-all for ub.price-all.
     define buffer buf_prod-bc   for ub.prod-bc.
     define buffer utd-lines for ub.utd-lines.
     define buffer country for ub.country .
     define variable vMarkingType   as integer no-undo init 0.
     define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
     if ibarcode
     then
        EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(ObjType, ObjCode).
     cicle:
     for each buf_goods where buf_goods.stts = 0
                          and buf_goods.gds-type = 'т'
     no-lock :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in ibs.th.gbl.gbl-hndllib:g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
       if is-petrol = yes and is-pieces = no then do:
          next cicle.
       end.
       find first buf_gds-obj where buf_gds-obj.gds-code = buf_goods.gds-code no-lock no-error.
       if not available (buf_gds-obj)
       then do:
          find first utd-lines where utd-lines.gds-code = buf_goods.gds-code no-lock no-error.
          if not available (utd-lines)
          then next cicle.
       end.
       if(igoods)
       then do:
          find first country where country.alpha1 = buf_goods.alpha1 no-lock no-error.
          assign
             factQnty    = if available buf_gds-obj then buf_gds-obj.fact-qnty else 0
             freeQnty    = if available buf_gds-obj then buf_gds-obj.free-qnty else 0
             countryName = if available ub.country then ub.country.long-name else ""
          .
          create tt-goods.
          assign
             tt-goods.gds-code  = buf_goods.gds-code
             tt-goods.gds-name  = buf_goods.gds-name
             tt-goods.unit-base = buf_goods.unit-base
             tt-goods.countryName = countryName
             tt-goods.factQnty  = factQnty
             tt-goods.freeQnty  = freeQnty
          .
       end.
       if ibarcode
       then do:
          if iprotocol > ""
          then do:
             define variable v-value as character no-undo.
             define variable v-type  as character no-undo.
                          if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
               (input  buf_goods.gds-code
               ,input  'mark-type':U
               ,output v-value
               ,output v-type
               ) no-error .
             if error-status :error
             then do:
                undo, return error return-value .
             end.
             myflagsbarcode:unSetAllFlags().
             myflagsbarcode:isEDO = EDOParSec:GetIsEDOForType(v-value) .
             myflagsbarcode:isArtic = EDOParSec:GetIsArticForType(v-value) .
             myflagsBarcode:IsTransitional = EDOParSec:GetIsTransitionalForType(v-value) .
          end.
          for each buf_bar-code where buf_bar-code.in-code = ""
                                  and buf_bar-code.gds-code = buf_goods.gds-code
                                  and buf_bar-code.stts_ = 0
          no-lock use-index prt-parts:
             find last buf_price-all where
                buf_price-all.b-code          = buf_bar-code.b-code and
                buf_price-all.gds-code        = buf_goods.gds-code  and
                buf_price-all.obj-code        = ObjCode and
                buf_price-all.obj-type        = ObjType and
                buf_price-all.plt-priority    = 0                   and
                buf_price-all.last-pr         = true
             no-lock no-error.
             find first ub.gds-obj no-lock where
                        ub.gds-obj.artic = buf_goods.artic
                    and ub.gds-obj.prod-type = buf_goods.prod-type
                    and ub.gds-obj.prod-code = buf_goods.prod-code no-error.
             if available buf_price-all and not buf_price-all.price-sale = ?
             then priceSale = buf_price-all.price-sale.
             else if available (ub.gds-obj) and not ub.gds-obj.price-sale = ?
             then priceSale = ub.gds-obj.price-sale.
             else priceSale = 0.
             if iprotocol eq "1.0" then do:
                if priceSale = 0
                then
                   priceSale =  1 / 100000.
             end.
             assign
                cliBaseRate = buf_bar-code.cli-base-rate
             .
             for each buf_prod-bc where buf_prod-bc.b-code = buf_bar-code.b-code
                                    and buf_prod-bc.bc-on = yes
             no-lock:
                if iprotocol > ""
                then do:
                   myflagsbarcode:isMark = false .
                   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
                   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq buf_prod-bc.b-code
                                                 and buf_prod-bc-attr.b-str eq buf_prod-bc.b-str
                                                 and buf_prod-bc-attr.attr-code eq 'mark':U
                   no-lock no-error.
                end.
                create TempBCode.
                assign
                   TempBCode.gds-code = buf_goods.gds-code
                   TempBCode.b-str = buf_prod-bc.b-str
                   TempBCode.unit-cli = buf_bar-code.unit-cli
                   TempBCode.cliBaseRate = cliBaseRate
                no-error.
                if error-status:error
                then do:
                   delete TempBCode.
                   logWrite:WriteFileToLog(substitute ( "Ошибка передачи бар-кода &1 в ТСД.", buf_prod-bc.b-str)).
                end.
                if available buf_prod-bc-attr and logical(buf_prod-bc-attr.attr-value) then myflagsbarcode:isMark = true .
                if iprotocol eq "1.0"
                then
                   TempBCode.priceSale = if (myflagsbarcode:isMark) then (-1 * priceSale ) else priceSale .
                else
                   TempBCode.priceSale = priceSale .
                   TempBCode.flags = myflagsbarcode:FlagsToInt .
             end.
          end.
       end.
    end.
  end.
  method public void GoodsPrint (type as char):
    if    type eq "xml"
       or type eq "json"
    then do on error undo, leave:
       define variable hDset as handle no-undo.
       hDset = CreateDsGoods().
       ttprint(type, hDset).
       finally:
           delete object hDset no-error.
        end.
    end.
    else do:
       if type eq ""
       then
          type = "temp_tsd.txt".
    tsdstreamopen( type).
    cicle:
    for each tt-goods:
            put stream tsdstream unformatted
        string (tt-goods.gds-code) + chr(30) +
        trim (tt-goods.gds-name, chr (9)) + chr(30) +
        tt-goods.unit-base + chr(30) +
        decToString( 0 ) + chr(30) +
        decToString(0 ) + chr(30) +
        tt-goods.countryName  + chr(30) +
                "Состав"  + chr(30) +
        decToString(tt-goods.factQnty) + chr(30) +
        decToString(tt-goods.freeQnty) + chr(31).
    end.
    tsdstreamclose().
     if type = "temp_tsd.txt"
       then
          setResult(type).
     end.
  end.
  method public void BarcodesClear ():
     empty temp-table TempBCode.
  end.
  method public void GoodsAndBarcodesClear ():
     GoodsClear().
     BarcodesClear().
     empty temp-table tt-barcodes.
  end.
  method public void getGoodsAndBarcodes (input iprotocol as char, idir as char):
     GoodsAndBarcodesClear().
     getGoodsAndBarcodes (yes, yes, iprotocol).
     GoodsAndBarcodesPrint(resType,idir,iprotocol).
  end.
  method public void GoodsAndBarcodesPrint (input type as char, idir as character, iprotocol as character):
     if    type eq "xml"
        or type eq "json"
     then do on error undo, leave:
        define variable hDset as handle no-undo.
        hDset = CreateDsGoodsAndBarcodes().
        for each tt-Goods no-lock:
           create tt-barcodes.
           tt-barcodes.gds-code = tt-Goods.gds-code.
        end.
        ttprint(type, hDset).
        if (idir ne "" and idir ne ?)
        then
           writeResult(idir + "\TH_goods." + resType,"utf-8").
        finally:
           delete object hDset no-error.
        end.
     end.
     else do:
        GoodsPrint(idir + "\TH_goods.txt").
        BarcodesPrint(idir + "\TH_barcodes.txt", iprotocol).
     end.
  end.
  method public void getBarcodes (input iprotocol as char):
    getGoodsAndBarcodes(no,yes,iprotocol).
  end.
  method public void BarcodesPrint (type as char, iprotocol as character):
     if    type eq "xml"
       or type eq "json"
    then do on error undo, leave:
       define variable hDset as handle no-undo.
       hdset = CreateDsBarcodes ().
       ttprint(type,hDset).
       finally:
           delete object hDset no-error.
        end.
    end.
    else do:
       if type eq ""
       then
          type = "temp_tsd.txt".
       tsdstreamopen(type).
    if iprotocol = "1.0" or iprotocol = ""  then do:
        for each TempBCode:
            put stream tsdstream unformatted
            string (TempBCode.gds-code) + chr(30) +
            TempBCode.b-str + chr(30) +
            decToString( TempBCode.priceSale) + chr(30) +
            TempBCode.unit-cli + chr(30) +
            decToString(TempBCode.cliBaseRate) + chr(31) .
        end .
        end.
     else do:
        for each TempBCode:
            put stream tsdstream unformatted
            string (TempBCode.gds-code) + chr(30) +
            TempBCode.b-str + chr(30) +
            decToString( TempBCode.priceSale) + chr(30) +
            TempBCode.unit-cli + chr(30) +
            decToString(TempBCode.cliBaseRate) + chr(30) +
            string(TempBCode.flags) + chr(31) .
        end.
    end.
    tsdstreamclose().
       if type = "temp_tsd.txt"
       then
          setResult(type).
     end.
    BarcodesClear().
  end.
  method public logical ImpWB (table TempTrnDoc, table TempDocLine, table TempMarkLine, userId_ as char):
    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_doc-line-attr for ub.doc-line-attr.
    define buffer gen-attr for ub.gen-attr.
    define buffer goods for ub.goods.
    define variable adapterOra-i516 as class   AdapterOra-i516.
    define variable glog           as logical   no-undo.
    define variable mes            as character no-undo.
    define variable hLibMarks      as handle    no-undo.
    define variable ii             as integer   no-undo.
    define variable varzero-string as logical   no-undo.
    define variable myflagsDoc     as class flagsdoc     no-undo.
    find first TempTrnDoc.
    if TempTrnDoc.ext-doc-code = 'vt':U then TempTrnDoc.Flags_ = 1 .
    myflagsDoc = new flagsdoc ().
    myflagsDoc:setFlagsToInt(TempTrnDoc.Flags_).
    find first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = TempTrnDoc.ext-doc-code
            and
            (
              ((buf_trn-doc.ext-doc-type = 'ee':U
              or buf_trn-doc.ext-doc-type = 'ev':U
              or buf_trn-doc.ext-doc-type = 'vt':U)
              and buf_trn-doc.flag_ = true
              and buf_trn-doc.status_ = 'разрешен':U)
            or
              ((buf_trn-doc.ext-doc-type = 'ie':U
              or buf_trn-doc.ext-doc-type = 'iv':U)
              and buf_trn-doc.flag_ = true
              and buf_trn-doc.status_ = 'накл':U)
            )  no-error.
    if available buf_trn-doc then
    do:
      if myflagsDoc:isDocMarkOn
      then do:
        for each TempDocLine no-lock where not TempDocLine.fact-qnty = 0 break by TempDocLine.gds-code:
          for each TempMarkLine where lookup (TempMarkLine.PartIDTH, TempDocLine.PartIDTH, chr(4)) > 0 and TempMarkLine.Sts = "TH" no-lock:
            for each gen-attr where gen-attr.p-key = TempMarkLine.PartIDTH and gen-attr.attr-code = TempMarkLine.MarkCode and gen-attr.table-name = 'excise-mark':U:
              delete gen-attr.
            end.
          end.
        end.
        for each TempMarkLine where TempMarkLine.Sts = "crTSD" no-lock:
          create gen-attr.
          gen-attr.p-key = TempMarkLine.PartIDTH.
          gen-attr.attr-code = TempMarkLine.MarkCode.
          gen-attr.table-name = 'excise-mark':U.
          gen-attr.whole-send-news = 0.
        end.
      end.
      for each TempDocLine no-lock break by TempDocLine.gds-code:
        find first goods where goods.gds-code  = TempDocLine.gds-code
          no-lock no-error .
        find first buf_doc-line exclusive-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code
          and buf_doc-line.artic = goods.artic
          and buf_doc-line.prod-type = goods.prod-type
          and buf_doc-line.prod-code = goods.prod-code
          no-error  .
        if available buf_doc-line then do:
        end.
        else do:
          logWrite:WriteFileToLog( substitute ( "В накладной &1 отсутсвует товар с кодом &2.", TempTrnDoc.ext-doc-code, TempDocLine.gds-code )).
          buf_trn-doc.ps = if buf_trn-doc.ps begins "@" then substitute ( "пропущен товар с кодом (штрих-код &3) &1&2.", TempDocLine.gds-code, chr(10), TempDocLine.b-code ) else substitute ( "&1&3 пропущен товар с кодом &2.",buf_trn-doc.ps, TempDocLine.gds-code, chr(10) ).
          delete TempDocLine.
          next.
        end.
      end.
      os-delete value (search ("doctsd.txt")) no-error.
      os-delete value (search ("newdoctsd.txt")) no-error.
      output stream str1 to value ("doctsd.txt").
      output stream str2 to value ("newdoctsd.txt").
      for each TempDocLine where TempDocLine.is-tsd-qnty = true:
        put stream str1 unformatted TempDocLine.b-code "," TempDocLine.fact-qnty skip.
      end.
      for each TempDocLine where TempDocLine.is-tsd-qnty = false:
        put stream str2 unformatted TempDocLine.b-code "," TempDocLine.fact-qnty skip.
      end.
      output stream str1 close.
      output stream str2 close.
      if can-find (first TempDocLine)
      then do:
        run gbl/filnline.p (input ("doctsd.txt"), output varzero-string).
        if varzero-string
        then do:
          run str/scantsd.p ( 2, input no , input recid(buf_trn-doc) ,input "doctsd.txt", if myflagsDoc:isDocMarkOn then "rsvmarks" else "" ) no-error.
          if error-status:error then do:
            LogWrite:LogStr = LogWrite:LogStr + chr(10) + return-value.
            logWrite:WriteFileToLog(LogWrite:LogStr).
            SomeStr = getStatusXml(false, LogWrite:LogStr).
            os-delete value (search ("doctsd.txt")) no-error.
            os-delete value (search ("newdoctsd.txt")) no-error.
            return false.
          end.
        end.
        run gbl/filnline.p (input ("newdoctsd.txt"), output varzero-string).
        if varzero-string
        then do:
          run str/scantsd.p ( 1, input no , input recid(buf_trn-doc) ,input "newdoctsd.txt", if myflagsDoc:isDocMarkOn then "rsvmarks" else "" ) no-error.
          if error-status:error then do:
            LogWrite:LogStr = LogWrite:LogStr + chr(10) + return-value.
            logWrite:WriteFileToLog(LogWrite:LogStr).
            SomeStr = getStatusXml(false, LogWrite:LogStr).
            os-delete value (search ("doctsd.txt")) no-error.
            os-delete value (search ("newdoctsd.txt")) no-error.
            return false.
          end.
        end.
      end.
      os-delete value (search ("doctsd.txt")) no-error.
      os-delete value (search ("newdoctsd.txt")) no-error.
      run gbl/calc-trn.p (?, recid(buf_trn-doc)) no-error .
      SomeStr = getStatusXml(true, "").
      return true.
    end.
    else
    do:
      adapterOra-i516 = new AdapterOra-i516().
      adapterOra-i516:SetTempTable(table TempTrnDoc, table TempDocLine, userId_).
      adapterOra-i516:WriteDB(output glog).
      logWrite:WriteFileToLog(adapterOra-i516:StrLog).
      delete object AdapterOra-i516.
      if glog
        then do:
          SomeStr = getStatusXml(true, "").
          return true.
        end.
        else do:
          SomeStr = getStatusXml(false, LogWrite:LogStr).
          return false.
        end.
    end.
  end.
    method public logical ImpMarksInv (table TempTrnDoc, table TempDocLine, table TempMarkLine):
        def    var      v-utd-db-num   as integer   no-undo.
        def    var      v-utd-doc-id   as integer   no-undo.
        def    var      v-ext-doc-code as character no-undo.
        define variable vLineNumWith   as integer   no-undo .
        define variable vLineNum       as integer   no-undo .
        define variable vError         as logical   no-undo .
        define buffer buf_utd-marking-lines for ub.utd-marking-lines.
        define buffer buf_utd               for ub.utd .
        define buffer bf_utd                for ub.utd .
        define buffer buf_utd-attr          for ub.utd-attr .
        define buffer bf_utd-attr           for ub.utd-attr .
        define buffer buf_utd-lines         for ub.utd-lines .
        define buffer bf_utd-lines          for ub.utd-lines .
        define buffer bf_utd-marking-lines  for ub.utd-marking-lines .
        for each TempTrnDoc :
            find first ub.clients no-lock where ub.clients.obj-code = TempTrnDoc.obj-code and
                ub.clients.obj-type = TempTrnDoc.obj-type no-error .
            if error-status:error
                then next.
            create buf_utd .
            assign
                buf_utd.DocumentDate = today
                buf_utd.sts          = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB
                buf_utd.obj-code     = ub.clients.obj-code
                buf_utd.obj-type     = ub.clients.obj-type
                buf_utd.host-code    = ub.clients.host-code
                buf_utd.EDocType     = objSrv:Env:Utd:EDocType:Mark_Collect:KeyIntDB
                .
            validate buf_utd .
            assign
                buf_utd.DocumentNumber = string(buf_utd.doc-id) + "-" + string(ub.clients.obj-code) + substring(ub.clients.obj-type,1,1) .
            create buf_utd-attr .
            assign
                buf_utd-attr.db-num     = buf_utd.db-num
                buf_utd-attr.doc-id     = buf_utd.doc-id
                buf_utd-attr.attr-code  = "is-initial-set"
                buf_utd-attr.attr-value = string(true) .
            .
            release buf_utd-attr .
            create bf_utd .
            assign
                bf_utd.DocumentDate = today
                bf_utd.sts          = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB
                bf_utd.obj-code     = ub.clients.obj-code
                bf_utd.obj-type     = ub.clients.obj-type
                bf_utd.host-code    = ub.clients.host-code
                bf_utd.EDocType     = objSrv:Env:Utd:EDocType:Mark_Collect:KeyIntDB
                .
            validate bf_utd .
            assign
                bf_utd.DocumentNumber = string(bf_utd.doc-id) + "-" + string(ub.clients.obj-code) + substring(ub.clients.obj-type,1,1) .
            create bf_utd-attr .
            assign
                bf_utd-attr.db-num     = bf_utd.db-num
                bf_utd-attr.doc-id     = bf_utd.doc-id
                bf_utd-attr.attr-code  = "is-initial-set"
                bf_utd-attr.attr-value = string(false) .
            .
            release bf_utd-attr .
            vLineNum = 0 .
            vLineNumWith = 0 .
            for each TempDocLine:
                find first ub.goods no-lock where ub.goods.gds-code = TempDocLine.gds-code no-error .
                if error-status:error
                    then
                do:
                    logWrite:WriteFileToLog(substitute ("Товар не найден &1", TempDocLine.gds-code)).
                    vError = true .
                    next .
                end.
                find first ub.gds-obj-attr where ub.gds-obj-attr.gds-code = ub.goods.gds-code and
                    ub.gds-obj-attr.obj-code = ub.clients.obj-code and ub.gds-obj-attr.obj-type = ub.clients.obj-type
                    and ub.gds-obj-attr.attr-code = 'mark-collect-type':U no-lock no-error.
                        tml_:
                        for each TempMarkLine where TempMarkLine.PartIDTH = TempDocLine.PartIDTH and TempMarkLine.MarkCode <> "" :
                               define variable vmes as character no-undo.
                              if not (available ub.gds-obj-attr and (gds-obj-attr.attr-value eq "1" or gds-obj-attr.attr-value eq "2"))
                              then
                              vmes = CrCheckMarkDoc(buf_utd.obj-type, buf_utd.obj-code,
                                          buf_utd.db-num, buf_utd.doc-id,
                                          TempMarkLine.MarkCode,
                                      true).
                              else
                              vmes = CrCheckMarkDoc(bf_utd.obj-type, bf_utd.obj-code,
                                          bf_utd.db-num, bf_utd.doc-id,
                                          TempMarkLine.MarkCode,
                                       false).
                               if vmes ne ? and vmes ne ""
                               then
                                  logWrite:WriteFileToLog(vmes).
                        end.
            end.
            find first bf_utd-lines no-lock where bf_utd-lines.doc-id = bf_utd.doc-id and
            bf_utd-lines.db-num = bf_utd.db-num no-error .
            if not available (bf_utd-lines) then delete bf_utd .
            find first buf_utd-lines no-lock where buf_utd-lines.doc-id = buf_utd.doc-id and
            buf_utd-lines.db-num = buf_utd.db-num no-error .
            if not available (buf_utd-lines) then delete buf_utd .
            if vError = true then  undo, return false.
        end.
    end.
  method public logical ImpInventory (table TempTrnDoc, table TempDocLine, userId_ as char):
    define buffer buf_trn-doc       for ub.trn-doc.
    define buffer buf_doc-line      for ub.doc-line.
    define buffer buf_doc-line-attr for ub.doc-line-attr.
    define buffer bfTempDocLine for TempDocLine.
    define buffer bfTempDocLineTSD  for TempDocLineTSD .
    define buffer bf_inv-doc-attr   for ub.inv-doc-attr .
    define buffer inv-doc-attr for ub.inv-doc-attr.
    define buffer trn-doc for ub.trn-doc.
    define buffer goods for ub.goods.
    define buffer doc-line for ub.doc-line.
    define buffer prod-bc for ub.prod-bc.
    define buffer clients for ub.clients.
    define buffer bar-code for ub.bar-code.
    define buffer marking for ub.marking.
    define variable adapterOra-i506 as class   AdapterOra-i506.
    define variable varzero-string  as logical no-undo.
    define variable myflagsDoc     as class flagsdoc     no-undo.
    define variable myflagsDocLine as class flagsdocline no-undo.
    define variable invMulti as logical no-undo .
    define variable ii              as integer   no-undo init 0 .
    define variable vardoc-code     like ub.trn-doc.doc-code no-undo.
    define variable v-marking-type  as character no-undo .
    define variable v-type          as character no-undo .
    define variable isManual        as logical   no-undo .
    def    var      Marking         as class     mark            no-undo .
    find first TempTrnDoc.
    myflagsDoc = new flagsdoc ().
    myflagsDocLine = new flagsdocline ().
    myflagsDoc:setFlagsToInt(TempTrnDoc.Flags_).
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = TempTrnDoc.ext-doc-code
      and buf_trn-doc.status_ = 'разрешен':U no-error.
    if available buf_trn-doc then
    do:
      invMulti = false .
      ii = 0 .
      find first inv-doc-attr no-lock where inv-doc-attr.doc-code = TempTrnDoc.ext-doc-code and
        inv-doc-attr.attr-code = 'invMultDevice' and inv-doc-attr.attr-value = string(true) no-error .
      if available (inv-doc-attr) then invMulti = true .
      if invMulti = false then next .
      if invMulti then
      do:
        block-trn:
        for each trn-doc no-lock where
                                      (trn-doc.doc-code eq TempTrnDoc.ext-doc-code
                                      and trn-doc.status_ = 'запрос':U)
                                   or (trn-doc.doc-code begins TempTrnDoc.ext-doc-code + "/"
                                   and trn-doc.status_ = 'запрос':U) by trn-doc.doc-code desc:
          leave block-trn.
        end.
        if available (trn-doc) then
        do:
          ii = integer(entry(2,trn-doc.doc-code,"/")) .
          TempTrnDoc.ext-doc-code = entry(1,trn-doc.doc-code,"/") + "/" + string(ii + 1) .
        end.
        else TempTrnDoc.ext-doc-code = TempTrnDoc.ext-doc-code + "/" + string(ii + 1) .
        TempTrnDoc.Status_= 'запрос':U .
      end.
      if invMulti then
      do:
        create trn-doc .
        trn-doc.doc-code = TempTrnDoc.ext-doc-code .
        trn-doc.status_ = 'запрос':U .
        trn-doc.flag_ = no .
        buffer-copy buf_trn-doc except doc-code status_ flag_ to trn-doc .
        find first inv-doc-attr exclusive-lock where inv-doc-attr.doc-code = trn-doc.doc-code
        and inv-doc-attr.attr-code = 'invMultDevice' no-error .
        if not available (inv-doc-attr) then do:
        create inv-doc-attr .
        assign
        inv-doc-attr.doc-code = trn-doc.doc-code
        inv-doc-attr.attr-code = 'invMultDevice' .
        end.
        inv-doc-attr.attr-value = string(true) .
      end.
      for each TempDocLine no-lock break by TempDocLine.gds-code:
        find first goods where goods.gds-code  = TempDocLine.gds-code
          no-lock no-error .
        find first buf_doc-line exclusive-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code
          and buf_doc-line.artic = goods.artic
          and buf_doc-line.prod-type = goods.prod-type
          and buf_doc-line.prod-code = goods.prod-code
          no-error  .
        if available buf_doc-line then do:
          if invMulti then do:
          create doc-line .
          doc-line.doc-code = TempTrnDoc.ext-doc-code .
          buffer-copy buf_doc-line except doc-code to doc-line .
          assign
          doc-line.doc-qnty = TempDocLine.fact-qnty .
          doc-line.fact-qnty = TempDocLine.fact-qnty - TempDocLine.doc-qnty .
          end.
          find first buf_doc-line-attr where buf_doc-line-attr.doc-code = buf_doc-line.doc-code and buf_doc-line-attr.gds-code = goods.gds-code and buf_doc-line-attr.attr-code = "tsd-qnty" no-lock no-error.
          if not available buf_doc-line-attr and first-of (TempDocLine.gds-code)
            then do:
              create buf_doc-line-attr.
              assign
                buf_doc-line-attr.attr-code = "tsd-qnty"
                buf_doc-line-attr.gds-code = goods.gds-code
                buf_doc-line-attr.doc-code = buf_doc-line.doc-code
              .
            end.
            else do:
              TempDocLine.is-tsd-qnty = true.
            end.
            release doc-line .
        end.
        else do:
          logWrite:WriteFileToLog(substitute ( "В инвентаризации &1 отсутсвует товар с кодом &2.", TempTrnDoc.ext-doc-code, TempDocLine.gds-code )).
          buf_trn-doc.ps = if buf_trn-doc.ps begins "@" then substitute ( "пропущен товар с кодом (штрих-код &3) &1&2.", TempDocLine.gds-code, chr(10), TempDocLine.b-code ) else substitute ( "&1&3 пропущен товар с кодом &2.",buf_trn-doc.ps, TempDocLine.gds-code, chr(10) ).
          delete TempDocLine.
          next.
        end.
      end.
    end.
    else
    do:
      if not (TempTrnDoc.ext-doc-code begins "TSD-") then do:
      return true.
      end.
    find first bf_inv-doc-attr no-lock where bf_inv-doc-attr.attr-code = "ItogInv" and bf_inv-doc-attr.attr-value = TempTrnDoc.ext-doc-code no-error .
    if available (bf_inv-doc-attr) then leave .
    empty temp-table TempDocLineTSD .
    find first clients no-lock where clients.obj-code = TempTrnDoc.obj-code and
      clients.obj-type = TempTrnDoc.obj-type no-error .
    if available (clients) then
    do:
      isManual = true .
      for each TempDocLine:
        find first goods no-lock where string(goods.gds-code) = TempDocLine.b-code no-error .
        if available (goods) then
        do:
          createTempGoods(buffer goods,1, false) .
        end.
        else
        do:
          find first prod-bc no-lock where (string(prod-bc.b-code) = TempDocLine.b-code or prod-bc.b-str = TempDocLine.b-code) no-error .
          if available (prod-bc) then
          do:
            find first bar-code no-lock where bar-code.b-code = prod-bc.b-code .
            find first goods no-lock where goods.gds-code = bar-code.gds-code .
            createTempGoods(buffer goods,bar-code.cli-base-rate,false) .
          end.
          else
          do:
            find first marking no-lock where marking.mark = TempDocLine.b-code no-error .
            if available (marking) then
            do:
              find first goods no-lock where goods.gds-code = marking.gds-code .
              createTempGoods(buffer goods,marking.box-qnty,true) .
            end.
            else
            do:
              createTempGoodsError() .
            end.
          end.
        end.
      end.
      for each TempDocLineTSD where not TempDocLineTSD.Flags_error:
                if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
          (input  TempDocLineTSD.gds-code
          ,input  'mark-type':U
          ,output v-marking-type
          ,output v-type
          ) no-error .
        if error-status :error
          then
        do:
          undo, return error return-value .
        end.
        if ObjSrv:Env:ParametrsOfSection:GetSectionEDO(clients.obj-type, clients.obj-code):GetIsMarkingForType(v-marking-type)
          then
        do:
          TempDocLineTSD.mark-type = v-marking-type .
          find first marking no-lock where marking.mark = TempDocLineTSD.mark and marking.sts = Marking:FreeZone:KeyIntDB no-error .
          if not available (marking) then
          do:
            TempDocLineTSD.Flags_error = true.
          end.
        end.
      end.
      if can-find(TempDocLineTSD where TempDocLineTSD.mark-type <> "") then
      do:
        if can-find(TempDocLineTSD where TempDocLineTSD.mark-type = "") then
        do:
          for each TempDocLineTSD where not TempDocLineTSD.Flags_error and TempDocLineTSD.mark-type <> "":
            TempDocLineTSD.Flags_error = true .
          end.
        end.
      end.
      find first TempDocLineTSD no-error .
      if available (TempDocLineTSD) then
      do:
        vardoc-code = docCode("main", clients.obj-type, clients.obj-code, ?) no-error .
        if error-status:error then
        do:
          logWrite:WriteFileToLog("Ошибка при генерации номера документа.") .
          SomeStr = getStatusXml(false, "Ошибка при генерации номера документа.").
          return false.
        end.
      end.
      find first TempDocLineTSD where not TempDocLineTSD.Flags_error no-error .
      if available (TempDocLineTSD) then
      do:
        createTrn( buffer clients ,vardoc-code,userId_).
        createAttrInv(vardoc-code,"isManual",string(true)).
        for each bfTempDocLineTSD where not bfTempDocLineTSD.Flags_:
          createDocLine(vardoc-code, bfTempDocLineTSD.gds-code, bfTempDocLineTSD.fact-qnty).
        end.
      end.
      find first TempDocLineTSD where TempDocLineTSD.Flags_error no-error .
      if available (TempDocLineTSD) then
      do:
        createTrn(buffer clients, vardoc-code + "-M",userId_).
        createAttrInv(vardoc-code + "-M","isManualError",string(true)).
        for each bfTempDocLineTSD where bfTempDocLineTSD.Flags_:
          find first goods where goods.gds-code = bfTempDocLineTSD.gds-code no-error .
          if available (goods) then do:
            createDocLine(vardoc-code + "-M", bfTempDocLineTSD.gds-code, bfTempDocLineTSD.fact-qnty).
          end.
          else do:
            createDocLineError(vardoc-code + "-M", bfTempDocLineTSD.artic, bfTempDocLineTSD.prod-code, bfTempDocLineTSD.prod-type, bfTempDocLineTSD.fact-qnty).
          end.
        end.
      end.
    end.
    end.
    if can-find (first TempDocLine where TempDocLine.is-tsd-qnty = true) and
       not invMulti then
    do:
      empty temp-table TempDocLineIsTSD.
    for each TempDocLine where TempDocLine.is-tsd-qnty = true:
        create TempDocLineIsTSD.
        buffer-copy TempDocLine to TempDocLineIsTSD no-error.
        if error-status:error then do:
          logWrite:WriteFileToLog(error-status:get-message(1)).
          SomeStr = getStatusXml(false, LogWrite:LogStr).
          return false.
    end.
    end.
      run str/scantsd.p ( 2, input no , input recid(buf_trn-doc) ,input table TempDocLineIsTSD, if myflagsDoc:isDocMarkOn then "rsvmarks" else "" ) no-error.
        if error-status:error then do:
        logWrite:WriteFileToLog(return-value).
          SomeStr = getStatusXml(false, LogWrite:LogStr).
          return false.
        end.
      end.
    if can-find (first TempDocLine where TempDocLine.is-tsd-qnty = false) and
       not isManual and
       not invMulti then
    do:
      empty temp-table TempDocLineIsTSD.
      for each TempDocLine where TempDocLine.is-tsd-qnty = false:
        create TempDocLineIsTSD.
        buffer-copy TempDocLine to TempDocLineIsTSD no-error.
        if error-status:error then do:
           logWrite:WriteFileToLog(error-status:get-message(1)).
          SomeStr = getStatusXml(false, LogWrite:LogStr).
          return false.
        end.
        end.
      run str/scantsd.p ( 1, input no , input recid(buf_trn-doc) ,input table TempDocLineIsTSD, if myflagsDoc:isDocMarkOn then "rsvmarks" else "" ) no-error.
      if error-status:error then do:
        logWrite:WriteFileToLog(return-value).
        SomeStr = getStatusXml(false, LogWrite:LogStr).
        return false.
      end.
      end.
    SomeStr = getStatusXml(true, "").
    return true.
  end method.
  method public logical updatedocument (
      docType as char,
      table TempTrnDoc   ,
      table TempDocLine ,
      table TempMarkLine ,
      userid_ as char
      ):
     define variable ErrStatus as logical no-undo.
    define buffer bfTempDocLine for TempDocLine.
    define buffer buf_bar-code  for ub.bar-code.
    define buffer buf_prod-bc   for ub.prod-bc.
    define buffer buf_place     for ub.place.
     case docType:
        when 'vt':U then
          do:
            if ImpInventory (table TempTrnDoc, table TempDocLine, userId_)
            then ErrStatus = false.
            else ErrStatus = true.
          end.
        when "UTD_DOC" then
          do:
            if ImpUTDDOC (table TempTrnDoc, table TempDocLine, table TempMarkLine)
            then ErrStatus = false.
            else ErrStatus = true.
          end.
        when "InvIntroduce" then
          do:
            if ImpUTDIntroduce(table TempTrnDoc, table TempDocLine, table TempMarkLine)
            then ErrStatus = false.
            else ErrStatus = true.
          end.
        when "invmark" then
          do:
            if ImpInvMarksDOC (table TempTrnDoc, table TempDocLine, table TempMarkLine)
            then ErrStatus = false.
            else ErrStatus = true.
          end.
        when "UTD_Introduce" then
          do:
            if ImpUTDIntroduce(table TempTrnDoc, table TempDocLine, table TempMarkLine)
            then ErrStatus = false.
            else ErrStatus = true.
          end.
         when "MarksInv" then
          do:
            if ImpMarksInv (table TempTrnDoc, table TempDocLine, table TempMarkLine)
            then ErrStatus = false.
            else ErrStatus = true.
          end.
        otherwise
        do:
          for each TempDocLine no-lock where not TempDocLine.b-code matches ("*" + string (TempDocLine.gds-code) + "*"):
            find first bfTempDocLine where bfTempDocLine.gds-code = TempDocLine.gds-code and bfTempDocLine.b-code matches ( "*" + string (bfTempDocLine.gds-code) + "*")  no-error.
            find buf_bar-code no-lock where
              buf_bar-code.gds-code = TempDocLine.gds-code and TempDocLine.b-code matches ("*" + string(buf_bar-code.b-code)+ "*") no-error.
            if not available buf_bar-code then
            do:
              find first buf_prod-bc no-lock where buf_prod-bc.b-str = TempDocLine.b-code no-error.
              if available buf_prod-bc
                then
              do:
                find first buf_bar-code no-lock where buf_bar-code.b-code = buf_prod-bc.b-code and buf_bar-code.gds-code = TempDocLine.gds-code no-error.
              end.
              if not available buf_bar-code then
              do:
                LogWrite:LogStr =  LogWrite:LogStr + chr(10) + 'Отправлен ответ на запрос типа "WAYBILL".' + chr(10) + "Не известный штрих-код:" + TempDocLine.b-code.
                logWrite:WriteFileToLog( "Не известный штрих-код:" + TempDocLine.b-code).
                SomeStr = "Не известный штрих-код:" + TempDocLine.b-code.
                ErrStatus = true.
                return false.
              end.
            end.
            if not available bfTempDocLine
              then
            do:
              create bfTempDocLine.
              assign
                bfTempDocLine.gds-code = TempDocLine.gds-code
                bfTempDocLine.b-code   = string (TempDocLine.gds-code)
                .
            end.
            assign
              bfTempDocLine.doc-qnty  = bfTempDocLine.doc-qnty + TempDocLine.doc-qnty * buf_bar-code.cli-base-rate
              bfTempDocLine.fact-qnty = bfTempDocLine.fact-qnty + TempDocLine.fact-qnty * buf_bar-code.cli-base-rate
              bfTempDocLine.RowSum    = bfTempDocLine.RowSum + TempDocLine.RowSum
              .
            delete TempDocLine.
          end.
          for each TempDocLine no-lock:
            assign
              TempDocLine.price-rubl = TempDocLine.RowSum / TempDocLine.fact-qnty.
            .
          end.
          if ImpWB(table TempTrnDoc, table TempDocLine, table TempMarkLine, userId_)
          then ErrStatus = false.
          else ErrStatus = true.
        end.
      end.
      return ErrStatus.
   end.
method public void createTempGoods(buffer goods for goods, icli-base-rate as decimal , mark_ as logical):
  define buffer del_TempDocLineTSD for TempDocLineTSD .
  define buffer marking for ub.marking.
  if not mark_ then do:
  find first TempDocLineTSD where TempDocLineTSD.artic = goods.artic and
    TempDocLineTSD.prod-code = goods.prod-code and
    TempDocLineTSD.prod-type = goods.prod-type no-error .
  if not available (TempDocLineTSD) then
  do:
    create TempDocLineTSD .
    assign
      TempDocLineTSD.gds-code  = goods.gds-code
      TempDocLineTSD.artic     = goods.artic
      TempDocLineTSD.prod-code = goods.prod-code
      TempDocLineTSD.prod-type = goods.prod-type
      .
  end.
  if TempDocLine.NotDict then
  TempDocLineTSD.fact-qnty = TempDocLineTSD.fact-qnty + TempDocLine.fact-qnty * icli-base-rate .
  else TempDocLineTSD.fact-qnty = TempDocLineTSD.fact-qnty + TempDocLine.fact-qnty .
  end.
  else
  do:
    find first marking no-lock where marking.mark = TempDocLine.b-code no-error .
    if available (marking) then do:
          find first TempDocLineTSD where TempDocLineTSD.artic = goods.artic and
    TempDocLineTSD.prod-code = goods.prod-code and
    TempDocLineTSD.prod-type = goods.prod-type no-error .
      if not available (TempDocLineTSD) then
  do:
    create TempDocLineTSD .
    assign
      TempDocLineTSD.gds-code  = goods.gds-code
      TempDocLineTSD.artic     = goods.artic
      TempDocLineTSD.prod-code = goods.prod-code
      TempDocLineTSD.prod-type = goods.prod-type
      TempDocLineTSD.mark = marking.mark
      TempDocLineTSD.mark-parent = marking.mark-parent
      .
      if marking.mark-parent = "" then do:
        for each del_TempDocLineTSD where del_TempDocLineTSD.mark-parent = marking.mark:
          delete del_TempDocLineTSD .
        end.
      end.
            TempDocLineTSD.fact-qnty   = TempDocLineTSD.fact-qnty + TempDocLine.fact-qnty * marking.box-qnty.
      end.
      else do:
        if not TempDocLineTSD.mark = marking.mark-parent then do:
    create TempDocLineTSD .
    assign
      TempDocLineTSD.gds-code  = goods.gds-code
      TempDocLineTSD.artic     = goods.artic
      TempDocLineTSD.prod-code = goods.prod-code
      TempDocLineTSD.prod-type = goods.prod-type
      TempDocLineTSD.mark = marking.mark
      TempDocLineTSD.mark-parent = marking.mark-parent
      .
      if marking.mark-parent = "" then do:
        for each del_TempDocLineTSD where del_TempDocLineTSD.mark-parent = marking.mark:
          delete del_TempDocLineTSD .
        end.
      end.
            TempDocLineTSD.fact-qnty   = TempDocLineTSD.fact-qnty + TempDocLine.fact-qnty * marking.box-qnty.
        end.
      end.
  end.
end.
end.
method public void createTempGoodsError():
  find first TempDocLineTSD where TempDocLineTSD.artic = TempDocLine.b-code and
    TempDocLineTSD.prod-code = 999999 and
    TempDocLineTSD.prod-type = "орг" no-error .
  if not available (TempDocLineTSD) then
  do:
    create TempDocLineTSD .
    assign
      TempDocLineTSD.artic       = TempDocLine.b-code
      TempDocLineTSD.prod-code   = 999999
      TempDocLineTSD.prod-type   = "орг"
      TempDocLineTSD.Flags_error = true
      .
  end.
    .
  TempDocLineTSD.fact-qnty = TempDocLineTSD.fact-qnty + TempDocLine.fact-qnty .
end.
method public void createTrn(buffer clients for clients, docCode as character, parUserId as character):
  define buffer bf_trn-doc    for ub.trn-doc .
  define buffer bf_curr-accnt for ub.curr-accnt .
  define buffer bf_sysconf    for ub.sysconf .
  define buffer shop       for ub.shop .
  if not available clients
  then
     return error "createTrn не передан клиент".
  find first shop no-lock where shop.obj-code = clients.obj-code no-error .
  if not available shop
  then
     return error "Не найден Магазин с кодом " + string(clients.obj-code).
  find first bf_sysconf no-lock where bf_sysconf.host-code = clients.host-code .
  if not available shop
  then
     return error "Не найден Фирма с кодом " + string(clients.host-code).
  v-today = today .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crtrndoc in ibs.th.gbl.gbl-hndllib:g#lib-trn
(input ?
,input ?
,input 1
,input 1
,input clients.host-code
,input 'орг':U
,input clients.obj-name
,input clients.db-num
,input parUserId
,input ' '
,input docCode
,input v-today
,input 'инв':U
,input no
,input clients.host-code
,input no
,input clients.obj-code
,input clients.obj-type
,input no
,input shop.inv-pay
,input '@  '
,input no
,input ?
,input 'накл':U
,input ?
,input 'vt':U
,input ?
) no-error
.
  if error-status:error then
  do:
    return error return-value.
  end.
  find bf_trn-doc where bf_trn-doc.doc-code = docCode.
  assign
    bf_trn-doc.tot-calc = ?.
  assign
    bf_trn-doc.status_ = 'запрос':U
    bf_trn-doc.flag_   = no
    bf_trn-doc.PS      = TempTrnDoc.ext-doc-code + ", " + string(TempTrnDoc.doc-date)
    .
  find last bf_curr-accnt where bf_curr-accnt.curr-code = bf_sysconf.base-code
    and bf_curr-accnt.exch-date <= v-today use-index pi no-lock no-error.
  if not available bf_curr-accnt then
  do:
    message "На дату" v-today "неизвестен курс базовой валюты." SKIP
      "Сумма по документу в валюте будет рассчитана при закрытии на факт".
  end.
  else
  do:
    assign
      bf_trn-doc.base-rate  = bf_curr-accnt.exch-rate
      bf_trn-doc.base-scale = bf_curr-accnt.exch-scale.
  END.
  ASSIGN
    bf_trn-doc.exch-code  = 0
    bf_trn-doc.exch-rate  = 1
    bf_trn-doc.exch-scale = 1.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end.  run lib-trn2_crinvdoc in ibs.th.gbl.gbl-hndllib:g#lib-trn2
(input bf_trn-doc.doc-code
) no-error
.
  if error-status:error then return error return-value.
end.
method public void createAttrInv(docCode as character, attrCode as character, attrValue as character):
  define buffer inv-doc-attr for ub.inv-doc-attr.
  create inv-doc-attr .
  assign
    inv-doc-attr.doc-code   = docCode
    inv-doc-attr.attr-code  = attrCode
    inv-doc-attr.attr-value = attrValue
    .
end.
method public void createDocLine(pardoc-code as character,
  pargds-code as integer, factQnty as decimal):
  define variable varis-petrolium as logical no-undo.
  define variable varis-pieces    as logical no-undo.
  define buffer cr_doc-line   for ub.doc-line.
  define buffer last_doc-line for ub.doc-line.
  define buffer new_trn-doc   for ub.trn-doc .
  define buffer new_goods     for ub.goods .
  define variable varline-num  as integer no-undo.
  define variable rec-inv-line as recid   no-undo.
  define variable v-vat-pc     as decimal no-undo .
  define variable v-slt-pc     as decimal no-undo .
  define buffer bf_sysconf for ub.sysconf .
  define buffer prt-obj for ub.prt-obj .
  find first new_trn-doc no-lock where new_trn-doc.doc-code = pardoc-code no-error .
  find first new_goods no-lock where new_goods.gds-code = pargds-code no-error .
  find first bf_sysconf where bf_sysconf.host-code = new_trn-doc.host-code no-lock no-error .
  find last last_doc-line where last_doc-line.doc-code = pardoc-code use-index line-num no-lock no-error.
  if not available last_doc-line then
  do:
    assign
      varline-num = 1.
  end.
  else
  do:
    assign
      varline-num = last_doc-line.line-num + 1.
  end.
  find first cr_doc-line where cr_doc-line.doc-code  = pardoc-code  and
    cr_doc-line.artic     = new_goods.artic     and
    cr_doc-line.prod-type = new_goods.prod-type and
    cr_doc-line.prod-code = new_goods.prod-code no-error.
  if not available cr_doc-line then
  do:
    v-vat-pc = pftxvalg(new_goods.gds-code, 1, ?, new_trn-doc.host-code, new_trn-doc.obj-type, new_trn-doc.obj-code) .
    v-slt-pc = st-sltpc(recid(new_goods), recid(new_trn-doc), if available(bf_sysconf) then bf_sysconf.cash-pay else 0) .
    create cr_doc-line.
    assign
      cr_doc-line.doc-code     = pardoc-code
      cr_doc-line.artic        = new_goods.artic
      cr_doc-line.prod-type    = new_goods.prod-type
      cr_doc-line.prod-code    = new_goods.prod-code
      cr_doc-line.obj-type     = new_trn-doc.obj-type
      cr_doc-line.obj-code     = new_trn-doc.obj-code
      cr_doc-line.status_      = new_trn-doc.status_
      cr_doc-line.ext-doc-type = new_trn-doc.ext-doc-type
      cr_doc-line.prt-root     = new_goods.prt-root
      cr_doc-line.vat-pc       = v-vat-pc
      cr_doc-line.slt-pc       = v-slt-pc
      cr_doc-line.cons-vat-pc  = bf_sysconf.cons-vat-pc
      cr_doc-line.line-num     = varline-num
      .
    if ( cr_doc-line.cli-base-rate = 0 or cr_doc-line.cli-base-rate = ? )
      then
      cr_doc-line.cli-base-rate = 1 .
  end.
  find first prt-obj no-lock where prt-obj.artic = cr_doc-line.artic and
    prt-obj.prod-code = cr_doc-line.prod-code and
    prt-obj.prod-type = cr_doc-line.prod-type and
    prt-obj.obj-code = cr_doc-line.obj-code and
    prt-obj.obj-type = cr_doc-line.obj-type no-error .
  if available (prt-obj) then cr_doc-line.fact-qnty = factQnty - prt-obj.fact-qnty .
  cr_doc-line.doc-qnty = factQnty .
end.
method public void createDocLineError(pardoc-code as character,
  parartic as character, parprod-code as integer, parprod-type as character, factQnty as decimal):
  define variable varis-petrolium as logical no-undo.
  define variable varis-pieces    as logical no-undo.
  define buffer cr_doc-line   for ub.doc-line.
  define buffer last_doc-line for ub.doc-line.
  define buffer new_trn-doc   for ub.trn-doc .
  define buffer new_goods     for ub.goods .
  define variable varline-num  as integer no-undo.
  define variable rec-inv-line as recid   no-undo.
  define variable v-vat-pc     as decimal no-undo .
  define variable v-slt-pc     as decimal no-undo .
  define buffer bf_sysconf for ub.sysconf .
  find first new_trn-doc no-lock where new_trn-doc.doc-code = pardoc-code no-error .
  find first bf_sysconf where bf_sysconf.host-code = new_trn-doc.host-code no-lock.
  find last last_doc-line where last_doc-line.doc-code = pardoc-code use-index line-num no-lock no-error.
  if not available last_doc-line then
  do:
    assign
      varline-num = 1.
  end.
  else
  do:
    assign
      varline-num = last_doc-line.line-num + 1.
  end.
    create cr_doc-line.
    assign
      cr_doc-line.doc-code     = pardoc-code
      cr_doc-line.artic        = parartic
      cr_doc-line.prod-type    = parprod-type
      cr_doc-line.prod-code    = parprod-code
      cr_doc-line.obj-type     = new_trn-doc.obj-type
      cr_doc-line.obj-code     = new_trn-doc.obj-code
      cr_doc-line.status_      = new_trn-doc.status_
      cr_doc-line.ext-doc-type = new_trn-doc.ext-doc-type
      cr_doc-line.line-num     = varline-num
      .
  cr_doc-line.doc-qnty = factQnty .
  cr_doc-line.fact-qnty = factQnty .
end.
  method public logical ImpUTDDOC (table TempTrnDoc, table TempDocLine, table TempMarkLine):
    def var v-utd-db-num as integer no-undo.
    def var v-utd-doc-id as integer no-undo.
    def var v-ext-doc-code as character no-undo.
    define buffer buf_utd-marking-lines for ub.utd-marking-lines.
    define buffer utd-marking-lines for ub.utd-marking-lines.
    define buffer utd-lines for ub.utd-lines.
    define buffer marking for ub.marking.
    for each TempTrnDoc :
      v-ext-doc-code = replace (entry (2, TempTrnDoc.ext-doc-code, "("),")","").
      assign
        v-utd-db-num = integer (entry (1, v-ext-doc-code, "_"))
        v-utd-doc-id = integer (entry (2, v-ext-doc-code, "_"))
      no-error.
      if error-status:error
        then next.
      tml_:
      for each TempMarkLine where TempMarkLine.Sts = "Check" or TempMarkLine.Sts = "CheckScan" or TempMarkLine.Sts = "CrTsd" or TempMarkLine.Sts = "Ungrouped" :
        find first utd-marking-lines where utd-marking-lines.db-num = v-utd-db-num and utd-marking-lines.doc-id = v-utd-doc-id
          and utd-marking-lines.mark = TempMarkLine.MarkCode
          exclusive-lock no-error.
        if available (utd-marking-lines)
        then do:
          utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB.
          find first marking where marking.mark = TempMarkLine.MarkCode no-lock no-error.
          if available  marking and TempMarkLine.Sts = "CheckScan"
            then ungrg(marking.mark-parent).
        end.
        else do:
          def var v-GTIN as char no-undo.
          def var v-mark-ident as char no-undo.
          v-GTIN = getGtinByDM(TempMarkLine.MarkCode) .
          v-mark-ident = GetCodeIdent(TempMarkLine.MarkCode).
          if v-GTIN <> "" then
          do:
            find first buf_utd-marking-lines where
                  buf_utd-marking-lines.db-num = v-utd-db-num and buf_utd-marking-lines.doc-id = v-utd-doc-id
              and buf_utd-marking-lines.mark begins TempMarkLine.MarkParent exclusive-lock no-error.
            if not available (buf_utd-marking-lines)
            then do:
              logWrite:WriteFileToLog(substitute ("Нарушена целостности либо изменен документ &1 на стороне TH", v-utd-doc-id)).
              undo, return false.
            end.
            buf_utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB.
            ungrg(buf_utd-marking-lines.mark).
            create utd-marking-lines .
            assign
              utd-marking-lines.db-num    = buf_utd-marking-lines.db-num
              utd-marking-lines.doc-id    = buf_utd-marking-lines.doc-id
              utd-marking-lines.gds-code  = buf_utd-marking-lines.gds-code
              utd-marking-lines.LineNum   = buf_utd-marking-lines.LineNum
              utd-marking-lines.doc-level = buf_utd-marking-lines.doc-level + 1
              utd-marking-lines.mark      = v-mark-ident
             .
            if ismark(v-mark-ident)
            then do:
               find first marking where marking.mark = v-mark-ident exclusive-lock no-error.
               if not available (marking)
                 then create marking .
               assign
                 marking.gds-code    = utd-marking-lines.gds-code
                 marking.mark        = v-mark-ident
                 marking.mark-parent = buf_utd-marking-lines.mark
                 marking.sts         = ObjSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB
                 marking.gds-ext-id  = v-GTIN
                 marking.obj-code    = TempTrnDoc.obj-code
                 marking.obj-type    = TempTrnDoc.obj-type
                 .
               marking.unit-ext = getLevelMotpByDM(v-mark-ident) .
               marking.box-qnty = getQntyUTDByDM(v-mark-ident) .
               marking.unit = getLevelUTDByDM(v-mark-ident) .
            end.
            utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB.
            if available marking
            THEN
               utd-marking-lines.mark = marking.mark.
         end.
        end.
      end.
      for each TempDocLine:
         find first utd-lines no-lock where utd-lines.doc-id = v-utd-doc-id
                                           and utd-lines.db-num = v-utd-db-num
                                           and utd-lines.LineNum eq TempDocLine.line-num no-error.
         if available ( utd-lines)
         then
            SetAttrUtdlines(utd-lines.db-num,utd-lines.doc-id,utd-lines.linenum,"QuantityBarCode",string(TempDocLine.fact-qnty)).
      end.
      for each TempMarkLine where TempMarkLine.Sts = "Ungrouped" :
        find first utd-marking-lines where utd-marking-lines.mark = TempMarkLine.MarkCode no-error.
        if available (utd-marking-lines)
        then do:
          find first marking where marking.mark = TempMarkLine.MarkCode no-error.
          marking.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB.
        end.
      end.
    end.
  end.
  method private void ungrg (mark-parent as char):
    define buffer buf_m for ub.marking.
    for each buf_m where buf_m.mark = mark-parent exclusive-lock :
      buf_m.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB.
      ungrg(buf_m.mark-parent).
    end.
  end.
  method public logical ImpUTDIntroduce (table TempTrnDoc, table TempDocLine, table TempMarkLine):
    def var chAddIntoduce as class introduce no-undo.
    def var v-utd-db-num as integer no-undo.
    def var v-utd-doc-id as integer no-undo.
    def var v-ext-doc-code as character no-undo.
    define buffer utd-marking-lines for ub.utd-marking-lines.
    define buffer utd for ub.utd.
    define buffer marking for marking.
    chAddIntoduce = new introduce ().
    for each TempTrnDoc :
      if TempTrnDoc.ext-doc-type = "InvIntroduce"
      then do:
        find first utd where utd.doc-code = TempTrnDoc.ext-doc-code no-lock no-error.
        if not available (utd)
          then next.
        v-utd-db-num = utd.db-num.
        v-utd-doc-id = utd.doc-id.
      end.
      else do:
        v-ext-doc-code = replace (entry (2, TempTrnDoc.ext-doc-code, "("),")","").
        assign
          v-utd-db-num = integer (entry (1, v-ext-doc-code, "_"))
          v-utd-doc-id = integer (entry (2, v-ext-doc-code, "_"))
        no-error.
      end.
      if error-status:error
        then next.
      for each TempMarkLine where TempMarkLine.Sts = "CrTsd" :
        find first utd-marking-lines no-lock where utd-marking-lines.mark = TempMarkLine.MarkCode and utd-marking-lines.doc-id = v-utd-doc-id and utd-marking-lines.db-num = v-utd-db-num no-error.
        if available ( utd-marking-lines)
          then next.
        find first marking where marking.mark = utd-marking-lines.mark exclusive-lock no-error.
        if available (marking)
        then do:
          marking.sts = ObjSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB.
        end.
        chAddIntoduce:AddMarkUTD(TempMarkLine.MarkCode, v-utd-doc-id, v-utd-db-num, "CrTsd") no-error.
        if error-status:error
        then do:
          dispmessage (return-value, false).
          delete object chAddIntoduce no-error.
          return false.
        end.
      end.
    end.
    delete object chAddIntoduce no-error.
  end.
  method public logical ImpInvMarksDOC (table TempTrnDoc, table TempDocLine, table TempMarkLine):
    def buffer buf_marking for ub.marking.
    def buffer buf_marking-lines for ub.marking-lines.
    def buffer bf_doc-line for ub.doc-line.
    define buffer marking-attr for ub.marking-attr.
    define buffer goods for ub.goods.
    def var v-inv-doc as character no-undo.
    for each TempTrnDoc :
      assign
        v-inv-doc = TempTrnDoc.ext-doc-code
      no-error.
      if error-status:error
        then next.
      for each TempMarkLine where TempMarkLine.Sts = "CheckScan" :
        find first marking-attr no-lock where (    marking-attr.attr-code = "inv-doc"
                                               and marking-attr.mark = TempMarkLine.MarkCode)
                                            or (marking-attr.attr-code = "inv-doc-scan"
                                               and marking-attr.mark = TempMarkLine.MarkCode)
          no-error.
        if available (marking-attr) and not marking-attr.attr-value = v-inv-doc
        then do:
          dispmessage ("Марка находится в инвентаризации - " + marking-attr.attr-value, false).
          return false.
        end.
        else do:
          if available (marking-attr)
            then next.
       end.
        find first buf_marking where (buf_marking.mark = TempMarkLine.MarkCode) no-lock no-error.
        if not available (buf_marking)
        then do:
          dispmessage ("Марка не найдена в системе.", false).
          return false.
        end.
        find first buf_marking-lines where (buf_marking-lines.mark = TempMarkLine.MarkCode)
          and buf_marking-lines.out-code = 'free-zone':U no-error.
        find first goods no-lock where goods.gds-code = buf_marking-lines.gds-code no-error.
        find first bf_doc-line where bf_doc-line.doc-code = v-inv-doc
          and bf_doc-line.artic = goods.artic
          and bf_doc-line.prod-type = goods.prod-type
          and bf_doc-line.prod-code = goods.prod-code no-lock no-error.
        if not available (bf_doc-line)
        then do:
          dispmessage (substitute ("В накладной к линии с товаром &1 &2 к марке &3.", string (goods.gds-code), goods.gds-name, buf_marking-lines.mark), false).
          return false.
        end.
        if available (buf_marking) and available (buf_marking-lines)
        then do:
          create marking-attr.
          marking-attr.mark = TempMarkLine.MarkCode.
          marking-attr.attr-code = "inv-doc-scan".
          marking-attr.attr-value = v-inv-doc.
          ObjSrv:Lib:MarkingTree:UnGroupMark(buf_marking.mark).
          if ObjSrv:Lib:MarkingTree:LevelDown(buf_marking.mark  )
          then do:
            ObjSrv:Lib:MarkingTree:LockInvChildeMark(buf_marking.mark, v-inv-doc).
          end.
        end.
      end.
    end.
    return true.
  end.
  method public void WriteUnknown ():
    SomeStr = getStatusXml(false, "Неизвестный запрос.").
  end.
  method public integer GetDbNum ():
    return dbNum.
  end method.
  method private integer GetDbNumLocal ():
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    do
    on error undo, return error return-value
    :
      for first buf_sys-ctrl field (db-num) no-lock :
       return buf_sys-ctrl.db-num.
      end.
    end.
  end method.
  method public character gds-attr-mark-type (
  p-gds-code as integer
  ):
  define buffer goods-attr for goods-attr.
  do
  on error undo, return error
  :
    find first goods-attr where goods-attr.gds-code = p-gds-code and goods-attr.attr-code = 'mark-type':U no-lock no-error.
    if available goods-attr
      then return goods-attr.attr-value.
    return "".
  end.
  end method.
  destructor public TSD ( ):
    delete object keyrec no-error.
  end destructor.
  method public void dispmessage (p-str as char, p-sts as logical):
    LogWrite:LogStr = p-str.
    SomeStr = getStatusXml(p-sts, p-str).
  end.
  method public void getUTDDoc (iProtocol as char):
    define buffer buf_utd         for ub.utd.
    define buffer buf_utd-err     for ub.utd-err.
    define buffer buf_utd-m-l     for ub.utd-marking-lines.
    define buffer buf_utd-m-l-par for ub.utd-marking-lines.
    define buffer buf_m-l         for ub.marking-lines.
    define buffer buf_m-chi       for ub.marking.
    define buffer buf_m-par       for ub.marking.
    define buffer buf_utd-l       for ub.utd-lines.
    define buffer buf_m           for ub.marking.
    define buffer buf_goods     for ub.goods.
    define buffer buf_bar-code  for ub.bar-code.
    define buffer buf_trn-doc   for ub.trn-doc.
    define buffer buf_doc-line  for ub.doc-line.
    define buffer utd-marking-lines-attr for ub.utd-marking-lines-attr.
    define buffer buf_utd-marking-lines for ub.utd-marking-lines.
    define buffer marking-attr for ub.marking-attr.
    define buffer marking for ub.marking.
    define buffer utd-marking-lines for ub.utd-marking-lines.
    define buffer utd for ub.utd.
    define variable dFactSum   as decimal   no-undo.
    define variable priceSale  as dec no-undo.
    define variable docType    as character no-undo.
    define variable decDocQnty as decimal no-undo.
    define variable jj as integer no-undo.
    define variable jjm as integer no-undo.
    define variable iim as integer no-undo.
    define variable myflagsDoc     as class flagsdoc     no-undo.
    define variable myflagsDocLine as class flagsdocline no-undo.
    define variable pos as integer no-undo.
    def    var      internal-b-code like ub.bar-code.b-code no-undo .
    def    var      full-b-code     as character init "" no-undo .
    def    var      v-doc-num       as character no-undo .
    def var v-sts as character no-undo.
    def var vRecKey-line as character no-undo.
    myflagsDoc = new flagsdoc ().
    myflagsDocLine = new flagsdocline ().
    l_utd:
    for each buf_utd where buf_utd.obj-type = ObjType and buf_utd.obj-code = ObjCode and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:AwaitingDelivery:KeyIntDB
      and buf_utd.EDocType = ObjSrv:Env:Utd:EDocType:UTD:KeyIntDB:
      v-doc-num = buf_utd.DocumentNumber + "(" + string(buf_utd.db-num) + "_" + string(buf_utd.doc-id) + ")".
      logWrite:WriteDebugLog( "Выгружаем документ УПД " + v-doc-num).
      myflagsDoc:unSetAllFlags().
      myflagsDoc:isDocMarkOn = false.
      for each buf_utd-l where buf_utd-l.db-num = buf_utd.db-num and buf_utd-l.doc-id = buf_utd.doc-id no-lock:
         if WeighedProd(buf_utd-l.gds-code)
         then do:
            logWrite:WriteDebugLog( substitute ("Документ &1 содержит весовой товар &2. Документ пропущен.", v-doc-num, buf_utd-l.gds-code)).
            next l_utd.
         end.
      end.
      block-u-l:
      for each buf_utd-l where buf_utd-l.db-num = buf_utd.db-num and buf_utd-l.doc-id = buf_utd.doc-id no-lock:
         block-mark:
         for each buf_utd-m-l where buf_utd-m-l.db-num = buf_utd-l.db-num
                             and buf_utd-m-l.doc-id    = buf_utd-l.doc-id
                             and buf_utd-m-l.LineNum   = buf_utd-l.LineNum
         no-lock:
            if    ismark(buf_utd-m-l.mark)
               or isOAD (buf_utd-m-l.mark)
            then do:
               ObjSrv:Lib:KeyRec:GenKeyRec ( input "utd-lines",
                  input  buffer buf_utd-l:handle,
                  output vRecKey-line).
               find first buf_utd-err no-lock where buf_utd-err.doc-id = buf_utd-l.doc-id and buf_utd-err.db-num = buf_utd-l.db-num and buf_utd-err.reckey = vRecKey-line no-error .
               if not available buf_utd-err
               then do:
                  myflagsDoc:isDocMarkOn = true.
                  leave block-u-l.
               end.
               else
                  leave block-mark.
            end.
         end.
      end.
      if buf_utd.cli-code = ? or buf_utd.obj-code = ? or buf_utd.cli-type = ? or buf_utd.obj-type = ?
      then do:
        logWrite:WriteFileToLog( substitute ( "Не указан контрагент/объект TH в документе УТД &1.", v-doc-num)).
        next l_utd.
      end.
      pos = 0.
      for each buf_utd-l where buf_utd-l.db-num = buf_utd.db-num and buf_utd-l.doc-id = buf_utd.doc-id no-lock:
        myflagsDocLine:unSetAllFlags().
        myflagsDocLine:isMarkOn            = logical(GetAttrUtdlinesEx (buf_utd-l.db-num,buf_utd-l.doc-id,buf_utd-l.lineNum,"MarkUtdLine","no")).
        myflagsDocLine:isVarietalVolumeOn  = logical(GetAttrUtdlinesEx (buf_utd-l.db-num,buf_utd-l.doc-id,buf_utd-l.lineNum,"ArticUtdLine","no")).
        myflagsDocLine:isNotEditManualQnty = not (myflagsDocLine:isMarkOn).
        find first buf_goods no-lock where buf_goods.gds-code = buf_utd-l.gds-code no-error.
        if not available (buf_goods)
        then do:
          logWrite:WriteFileToLog( substitute ( "Не указан товар TH в документе УТД &1.", v-doc-num)).
          next l_utd.
        end.
        find first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code.
       internal-b-code = buf_bar-code.b-code.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str11  as character no-undo.
  define variable tmp-num11  as character no-undo.
  define variable i11        as integer   no-undo.
  define variable sum11      as integer   no-undo.
  define variable len-code11 as integer   no-undo.
  define variable varcont11  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str11 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str11 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont11 = yes then do:
    if integer( substring( tmp-str11, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str11, length( bc-pfx ) + 1, length( tmp-str11 ) - length( bc-pfx ) )
        len-code11    = length( full-b-code )
      .
      define variable v-sum-char11 as character no-undo .
      assign
        sum11 = 0
      .
      do i11 = 1 to len-code11 by 2
      :
        assign
          v-sum-char11 = substr(full-b-code, len-code11 - i11 + 1, 1)
        .
        if v-sum-char11 < "0"
        or v-sum-char11 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum11 = sum11 + integer(v-sum-char11)
        .
      end.
      if varcont11 = yes then do:
        assign
          sum11 = sum11 * 3
        .
        do i11 = 2 to len-code11 by 2
        :
          assign
            v-sum-char11 = substr(full-b-code, len-code11 - i11 + 1, 1)
          .
          if v-sum-char11 < "0"
          or v-sum-char11 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum11 = sum11 + integer(v-sum-char11)
          .
        end.
        if varcont11 = yes then do:
           if sum11 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum11 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
        pos = pos + 1.
        PriceSale = buf_utd-l.Total / buf_utd-l.Quantity.
        decDocQnty = buf_utd-l.Quantity.
        define variable vErrorLine as logical no-undo.
        ObjSrv:Lib:KeyRec:GenKeyRec ( input "utd-lines",
            input  buffer buf_utd-l:handle,
            output vRecKey-line).
        find first buf_utd-err no-lock where buf_utd-err.doc-id = buf_utd-l.doc-id and buf_utd-err.db-num = buf_utd-l.db-num and buf_utd-err.reckey = vRecKey-line no-error .
        vErrorLine = available buf_utd-err.
        for each buf_utd-m-l where buf_utd-m-l.db-num = buf_utd.db-num and buf_utd-m-l.doc-id = buf_utd.doc-id and buf_utd-m-l.LineNum = buf_utd-l.LineNum no-lock
          :
          define variable vMark as logical no-undo.
          vMark = isMark(buf_utd-m-l.mark).
          if vMark
          then do:
             find first buf_m no-lock where buf_m.mark = buf_utd-m-l.mark no-error.
          end.
          if vErrorLine and false then
          do:
            v-sts = "NotCorrect".
          end.
          else do:
             if not vMark
             then
                v-sts = "UTD".
             else if not buf_utd-m-l.sts = ObjSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB
                 and not buf_utd-m-l.sts = ObjSrv:Env:Marking:Sts:Mark:DeliveryControl:KeyIntDB
             then do:
                  if available buf_m and buf_m.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
                      or buf_utd-m-l.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB
                  then v-sts = "Check".
                  else v-sts = "NotCorrect".
              end.
              else if available buf_m and buf_m.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
              then
                 v-sts = "Ungrouped".
              else if available buf_m and buf_m.sts = ObjSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
              then
                 v-sts = "NotCorrect".
              else do:
                if available buf_m and buf_m.sts = ObjSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB
                  then v-sts = "GrayZone".
                  else do:
                    if can-find (first buf_m-par no-lock where buf_m-par.mark = buf_m.mark-parent and buf_m-par.sts = ObjSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB)
                      then v-sts = "GrayZone".
                      else v-sts = "UTD".
                  end.
              end.
          end.
          jj = jj + 1.
          define variable vqnty as integer no-undo.
          if vmark
             and available buf_m
          then do:
             vqnty = buf_m.box-qnty.
             if vqnty = ? then vqnty = integer (GetAttrUtdlinesEx (buf_utd-m-l.db-num,buf_utd-m-l.doc-id,buf_utd-m-l.lineNum,"box-qnty","0")) no-error.
          end.
          else vqnty = integer(GetAttrUtdlinesEx (buf_utd-m-l.db-num,buf_utd-m-l.doc-id,buf_utd-m-l.lineNum,"box-qnty","0")) no-error.
          if vqnty = ? then vqnty = 0.
          addDocLineMark(
                    jj,
                      v-doc-num,
                    buf_utd-l.linenum,
                      buf_utd-m-l.mark,
                      v-doc-num + "_" + string (buf_goods.gds-code) + "_" + string(pos),
                      v-sts,
                      (if available buf_m then  buf_m.mark-parent else ""),
                    vqnty,
                    if available buf_m then  buf_m.unit-ext else "").
        end.
        define variable decFactQnty as decimal no-undo.
        decFactQnty  = dec (GetAttrUtdlinesEx(buf_utd-l.db-num,buf_utd-l.doc-id,buf_utd-l.linenum,"QuantityBarCode","0")).
          jjm = jjm + 1.
         addDocLine(jjm,
                       v-doc-num,
                       pos,
                       buf_goods.gds-code,
                       buf_goods.gds-name ,
                      buf_goods.unit-base,
                      full-b-code,
                       priceSale,
                       decDocQnty,
                       decFactQnty,
                      getErrForLineType(buffer buf_utd-l:handle, "*"),
                      v-doc-num + "_" + string (buf_goods.gds-code) + "_" + string(pos),
                       myflagsDocLine:FlagsToInt  ).
      end.
      docType = "UTD".
      addDoc(
           v-doc-num,
           docType,
           false,
           "накл+",
           buf_utd.cli-code,
           buf_utd.cli-type,
           buf_utd.obj-code,
           buf_utd.obj-type,
           "",
            "",
           dFactSum,
           datetime-tz (if buf_utd.DocumentDate = ? then now else buf_utd.DocumentDate),
           myflagsDoc:FlagsToInt
      ).
      logWrite:WriteDebugLog( "Выгружен документ УПД " + v-doc-num).
    end.
    l_utd_Introduce:
    for each buf_utd where buf_utd.obj-type = ObjType and buf_utd.obj-code = ObjCode and buf_utd.sts = ObjSrv:Env:Utd:Sts:TH:NewStatus:KeyIntDB
      and buf_utd.EDocType = ObjSrv:Env:Utd:EDocType:Introduce:KeyIntDB
        and buf_utd.doc-code = ""
        and not can-find (first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_utd.doc-code):
      v-doc-num = buf_utd.DocumentNumber + "(" + string(buf_utd.db-num) + "_" + string(buf_utd.doc-id) + ")".
      logWrite:WriteDebugLog( "Выгружаем документ Первоначальный ввод КМ " + v-doc-num).
      pos = 0.
      l_utd1:
      for each buf_utd-l where buf_utd-l.db-num = buf_utd.db-num and buf_utd-l.doc-id = buf_utd.doc-id no-lock:
        myflagsDocLine:unSetAllFlags().
        myflagsDocLine:isMarkOn            = logical(GetAttrUtdlinesEx (buf_utd-l.db-num,buf_utd-l.doc-id,buf_utd-l.lineNum,"MarkUtdLine","yes")).
        myflagsDocLine:isVarietalVolumeOn  = logical(GetAttrUtdlinesEx (buf_utd-l.db-num,buf_utd-l.doc-id,buf_utd-l.lineNum,"ArticUtdLine","no")).
        myflagsDocLine:isNotEditManualQnty = not (myflagsDocLine:isMarkOn).
        find first buf_goods no-lock where buf_goods.gds-code = buf_utd-l.gds-code no-error.
        if not available (buf_goods)
        then do:
          LogWrite:LogStr = LogWrite:LogStr + chr(10) + substitute ( "Не указан товар TH в документе УТД &1.", v-doc-num).
          next l_utd1.
        end.
        find first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code.
        internal-b-code = buf_bar-code.b-code.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str12  as character no-undo.
  define variable tmp-num12  as character no-undo.
  define variable i12        as integer   no-undo.
  define variable sum12      as integer   no-undo.
  define variable len-code12 as integer   no-undo.
  define variable varcont12  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str12 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str12 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont12 = yes then do:
    if integer( substring( tmp-str12, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str12, length( bc-pfx ) + 1, length( tmp-str12 ) - length( bc-pfx ) )
        len-code12    = length( full-b-code )
      .
      define variable v-sum-char12 as character no-undo .
      assign
        sum12 = 0
      .
      do i12 = 1 to len-code12 by 2
      :
        assign
          v-sum-char12 = substr(full-b-code, len-code12 - i12 + 1, 1)
        .
        if v-sum-char12 < "0"
        or v-sum-char12 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum12 = sum12 + integer(v-sum-char12)
        .
      end.
      if varcont12 = yes then do:
        assign
          sum12 = sum12 * 3
        .
        do i12 = 2 to len-code12 by 2
        :
          assign
            v-sum-char12 = substr(full-b-code, len-code12 - i12 + 1, 1)
          .
          if v-sum-char12 < "0"
          or v-sum-char12 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum12 = sum12 + integer(v-sum-char12)
          .
        end.
        if varcont12 = yes then do:
           if sum12 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum12 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
        PriceSale = buf_utd-l.Total / buf_utd-l.Quantity.
        decDocQnty = buf_utd-l.Quantity.
        pos = pos + 1.
        addDocLine(jjm,
                       v-doc-num,
                       pos,
                       buf_goods.gds-code,
                       buf_goods.gds-name ,
                      buf_goods.unit-base,
                      full-b-code,
                       priceSale,
                       decDocQnty,
                       decDocQnty,
                       "",
                      v-doc-num + "_" + string (buf_goods.gds-code),
                       myflagsDocLine:FlagsToInt  ).
        for each buf_utd-m-l where buf_utd-m-l.db-num = buf_utd.db-num and buf_utd-m-l.doc-id = buf_utd.doc-id and buf_utd-m-l.LineNum = buf_utd-l.LineNum no-lock
          :
          vmark =isMark(buf_utd-m-l.mark).
          if vmark
          then do:
          find first buf_m no-lock where buf_m.mark = buf_utd-m-l.mark no-error.
             if not available (buf_m)
             then do:
               logWrite:WriteFileToLog(substitute ("Некорректная марка &1.", buf_utd-m-l.mark)).
               next.
             end.
          end.
          find first utd-marking-lines-attr where
                utd-marking-lines-attr.db-num    = buf_utd-m-l.db-num
            and utd-marking-lines-attr.doc-id    = buf_utd-m-l.doc-id
            and utd-marking-lines-attr.LineNum   = buf_utd-m-l.LineNum
            and utd-marking-lines-attr.mark      = buf_utd-m-l.mark
            and utd-marking-lines-attr.attr-code = "CrTsd" no-lock no-error
          .
          def var v-mark as char no-undo.
          if available (utd-marking-lines-attr)
            then v-mark = utd-marking-lines-attr.attr-value.
            else v-mark = buf_utd-m-l.mark.
          jj = jj + 1.
          if vmark and
             available buf_m
          then do:
             vqnty = buf_m.box-qnty.
             if vqnty = ? then vqnty = decimal(GetAttrUtdlinesEx (buf_utd-m-l.db-num,buf_utd-m-l.doc-id,buf_utd-m-l.lineNum,"box-qnty","0")) no-error.
          end.
          else vqnty = decimal(GetAttrUtdlinesEx (buf_utd-m-l.db-num,buf_utd-m-l.doc-id,buf_utd-m-l.lineNum,"box-qnty","0")) no-error.
          if vqnty = ? then vqnty = 0.
          addDocLineMark(
                    jj,
                      v-doc-num,
                    buf_utd-l.linenum,
                      v-mark,
                      v-doc-num + "_" + string (buf_goods.gds-code),
                      "CrTSD",
                      (if available buf_m then  buf_m.mark-parent else ""),
                    vqnty,
                    if available buf_m then  buf_m.unit-ext else ""
                    ).
        end.
      end.
      if buf_utd.cli-code = ? or buf_utd.obj-code = ? or buf_utd.cli-type = ? or buf_utd.obj-type = ?
      then do:
        logWrite:WriteFileToLog(substitute ( "Не указан контрагент/объект TH в документе УТД &1.", v-doc-num)).
        next l_utd_Introduce.
      end.
      docType = "Introduce".
      addDoc(
           v-doc-num,
           docType,
           false,
           "накл+",
           buf_utd.cli-code,
           buf_utd.cli-type,
           buf_utd.obj-code,
           buf_utd.obj-type,
           "",
            "",
           0,
           datetime-tz (if buf_utd.DocumentDate = ? then now else buf_utd.DocumentDate),
           myflagsDoc:FlagsToInt
      ).
      logWrite:WriteDebugLog( "Выгружен документ Первоначальный ввод КМ " + v-doc-num).
    end.
    def var v-attr-value   as character no-undo.
    def var v-attr-type    as character no-undo.
    def var v-is-introduce as logical   no-undo.
    invd_:
    for each buf_trn-doc where buf_trn-doc.ext-doc-type = 'vt':U and buf_trn-doc.status_ = 'накл':U and not buf_trn-doc.flag:
      v-is-introduce = false.
run trdcalib_tdat-val in ibs.th.gbl.gbl-hndllib:g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'trdcattr-inv-introduce':U ,
                       output v-attr-value ,
                       output v-attr-type ) no-error .
      if not error-status:error and v-attr-value = "yes" then do:
        v-is-introduce = true.
        find first buf_utd no-lock where buf_utd.doc-code = buf_trn-doc.doc-code no-error.
        if not available (buf_utd)
        then do:
          logWrite:WriteFileToLog(substitute ( "Ошибочный документ &1 TH первоначального ввода, нет привязанного документа УТД.", v-doc-num)).
          next invd_.
        end.
      end.
      logWrite:WriteDebugLog( "Выгружаем документ " + buf_trn-doc.doc-code).
      v-doc-num = buf_trn-doc.doc-code.
      pos = 0.
      for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code no-lock:
        find first buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and buf_goods.prod-code = buf_doc-line.prod-code and buf_goods.prod-type = buf_doc-line.prod-type.
        find first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code.
        if not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code):GetIsMarkingForType(gds-attr-mark-type(buf_goods.gds-code))
        then do:
        logWrite:WriteDebugLog( "Не выгружаем документ " + buf_trn-doc.doc-code + ". В нем содержится не маркированный товар.").
        next invd_.
        end.
        internal-b-code = buf_bar-code.b-code.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str13  as character no-undo.
  define variable tmp-num13  as character no-undo.
  define variable i13        as integer   no-undo.
  define variable sum13      as integer   no-undo.
  define variable len-code13 as integer   no-undo.
  define variable varcont13  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str13 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str13 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont13 = yes then do:
    if integer( substring( tmp-str13, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str13, length( bc-pfx ) + 1, length( tmp-str13 ) - length( bc-pfx ) )
        len-code13    = length( full-b-code )
      .
      define variable v-sum-char13 as character no-undo .
      assign
        sum13 = 0
      .
      do i13 = 1 to len-code13 by 2
      :
        assign
          v-sum-char13 = substr(full-b-code, len-code13 - i13 + 1, 1)
        .
        if v-sum-char13 < "0"
        or v-sum-char13 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum13 = sum13 + integer(v-sum-char13)
        .
      end.
      if varcont13 = yes then do:
        assign
          sum13 = sum13 * 3
        .
        do i13 = 2 to len-code13 by 2
        :
          assign
            v-sum-char13 = substr(full-b-code, len-code13 - i13 + 1, 1)
          .
          if v-sum-char13 < "0"
          or v-sum-char13 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum13 = sum13 + integer(v-sum-char13)
          .
        end.
        if varcont13 = yes then do:
           if sum13 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum13 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
        pos = pos + 1.
        def var v-qnty as integer no-undo.
        v-qnty = 0.
        if v-is-introduce
        then do:
           for each marking-attr no-lock where (marking-attr.attr-code = "inv-doc"
                                               and marking-attr.attr-value = buf_doc-line.doc-code)
                                            or (marking-attr.attr-code = "inv-doc-scan"
                                            and marking-attr.attr-value = buf_doc-line.doc-code)  :
            if not can-find (first marking no-lock where marking.mark = marking-attr.mark and marking.unit-ext = "UNIT" and marking.gds-code = buf_goods.gds-code)
              then next.
            v-qnty = v-qnty + 1.
          end.
          for each utd no-lock where utd.doc-code = buf_doc-line.doc-code:
            for each utd-marking-lines no-lock where utd-marking-lines.doc-id = utd.doc-id and utd-marking-lines.db-num = utd.db-num and utd-marking-lines.gds-code = buf_goods.gds-code
              and (utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB or utd-marking-lines.sts = ObjSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB):
              for each marking no-lock where marking.mark = utd-marking-lines.mark.
                if can-find (buf_utd-marking-lines where
                      buf_utd-marking-lines.doc-id = utd.doc-id and buf_utd-marking-lines.db-num = utd.db-num and buf_utd-marking-lines.mark = marking.mark-parent
                    )
                  then next.
                v-qnty = v-qnty + marking.box-qnty.
              end.
            end.
            decDocQnty = buf_doc-line.doc-qnty - buf_doc-line.fact-qnty.
            decFactQnty = v-qnty.
          end.
        end.
        else do:
          for each marking-attr no-lock where (    marking-attr.attr-code = "inv-doc"
                                               and marking-attr.attr-value = buf_doc-line.doc-code)
                                            or (marking-attr.attr-code = "inv-doc-scan"
                                                and marking-attr.attr-value = buf_doc-line.doc-code)  :
            if not can-find (first marking no-lock where marking.mark = marking-attr.mark and marking.unit-ext = "UNIT" and marking.gds-code = buf_goods.gds-code)
              then next.
            v-qnty = v-qnty + 1.
          end.
          decDocQnty = buf_doc-line.doc-qnty - buf_doc-line.fact-qnty.
          decFactQnty = v-qnty.
        end.
        assign
          priceSale   = if buf_doc-line.price-rubl <> ? then buf_doc-line.price-rubl else 0
          .
        jjm = jjm + 1.
        addDocLine(jjm,
                       v-doc-num,
                       pos,
                       buf_goods.gds-code,
                       buf_goods.gds-name ,
                      buf_goods.unit-base,
                      full-b-code,
                       priceSale,
                       decDocQnty,
                       decFactQnty,
                       "",
                      v-doc-num + "_" + string (buf_goods.gds-code),
                       myflagsDocLine:FlagsToInt  ).
        if not v-is-introduce
        then do:
          for each buf_m-l no-lock where buf_m-l.obj-type = buf_doc-line.obj-type
              and buf_m-l.obj-code = buf_doc-line.obj-code
              and buf_m-l.out-code = 'free-zone':U
              and buf_m-l.gds-code = buf_goods.gds-code
            :
               vmark = isMark(buf_m-l.mark).
            if vmark
            then do:
               find first buf_m no-lock where buf_m.mark = buf_m-l.mark no-error.
               if available (buf_m)
               then do:
                  if buf_m.sts = ObjSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB
                    then next.
                  if not buf_m.unit-ext = "UNIT"
                  then do:
                    find first buf_m-chi no-lock where buf_m-chi.mark-parent = buf_m.mark
                      and buf_m-chi.unit-ext = "UNIT" no-error.
                    if not available (buf_m-chi)
                      then next.
                  end.
                  block-attr:
                  for each marking-attr where (marking-attr.attr-code = "inv-doc"
                                                         and marking-attr.mark = buf_m.mark)
                                                      or (marking-attr.attr-code = "inv-doc-scan"
                                                          and marking-attr.mark = buf_m.mark)
                  no-lock:
                  leave block-attr.
                  end.
                 if available marking-attr
                 then v-sts = "Check".
                 else v-sts = "UTD".
               end.
               else next.
            end.
            else v-sts = "Check".
            jj = jj + 1.
            if vmark
              and available buf_m
            then vqnty = buf_m.box-qnty.
            if vqnty = ? then vqnty = 0.
            addDocLineMark(
                    jj,
                      v-doc-num,
                    pos,
                      buf_m-l.mark,
                      v-doc-num + "_" + string (buf_goods.gds-code),
                      "Check",
                      (if available buf_m then buf_m.mark-parent else ""),
                    vqnty,
                    if available buf_m then  buf_m.unit-ext else ""
                    ).
          end.
        end.
        else do:
          find first buf_utd no-lock where buf_utd.doc-code = buf_trn-doc.doc-code.
          l_utdf:
          for each buf_utd-l where buf_utd-l.db-num = buf_utd.db-num and buf_utd-l.doc-id = buf_utd.doc-id
            and buf_utd-l.gds-code = buf_goods.gds-code no-lock:
            find first buf_goods no-lock where buf_goods.gds-code = buf_utd-l.gds-code no-error.
            if not available (buf_goods)
            then do:
              logWrite:WriteFileToLog( substitute ( "Не указан товар TH в документе УТД &1.", v-doc-num)).
              next l_utdf.
            end.
            find first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code.
            internal-b-code = buf_bar-code.b-code.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable tmp-str14  as character no-undo.
  define variable tmp-num14  as character no-undo.
  define variable i14        as integer   no-undo.
  define variable sum14      as integer   no-undo.
  define variable len-code14 as integer   no-undo.
  define variable varcont14  as logical   initial yes no-undo.
  CASE bc-frmt :
    WHEN "EAN13" THEN do:
      assign
        tmp-str14 = string( internal-b-code, "999999999999" )
      .
    end.
    WHEN "EAN8" THEN do:
      assign
        tmp-str14 = string( internal-b-code, "9999999" )
      .
    end.
    OTHERWISE DO:
        message "Неизвестный тип генерации бар-кода процедурой bc-gnrti.i: " bc-frmt " ."
        view-as alert-box error.
        return error.
    END.
  END CASE.
  if varcont14 = yes then do:
    if integer( substring( tmp-str14, 1, length( bc-pfx ) ) ) <> 0
    then do:
      message
        "Невозможно сформировать бар-код" SKIP
        "для товара с кодом: " internal-b-code
        view-as alert-box error title "подрезание кода".
      return error.
    end.
    else do:
      assign
        full-b-code = bc-pfx + substring( tmp-str14, length( bc-pfx ) + 1, length( tmp-str14 ) - length( bc-pfx ) )
        len-code14    = length( full-b-code )
      .
      define variable v-sum-char14 as character no-undo .
      assign
        sum14 = 0
      .
      do i14 = 1 to len-code14 by 2
      :
        assign
          v-sum-char14 = substr(full-b-code, len-code14 - i14 + 1, 1)
        .
        if v-sum-char14 < "0"
        or v-sum-char14 > "9"
        then do:
          message
            "Невозможно сформировать бар-код" skip
            "для товара с кодом: " internal-b-code skip
            view-as alert-box error title "подсчет контрольной суммы".
          return error.
        end.
        assign
          sum14 = sum14 + integer(v-sum-char14)
        .
      end.
      if varcont14 = yes then do:
        assign
          sum14 = sum14 * 3
        .
        do i14 = 2 to len-code14 by 2
        :
          assign
            v-sum-char14 = substr(full-b-code, len-code14 - i14 + 1, 1)
          .
          if v-sum-char14 < "0"
          or v-sum-char14 > "9"
          then do:
            message
              "Невозможно сформировать бар-код" skip
              "для товара с кодом: " internal-b-code skip
              view-as alert-box error title "подсчет контрольной суммы".
            return error.
          end.
          assign
            sum14 = sum14 + integer(v-sum-char14)
          .
        end.
        if varcont14 = yes then do:
           if sum14 mod 10 = 0 then do:
             assign
               full-b-code = full-b-code + '0'
             .
           end.
           else do:
             assign
               full-b-code = full-b-code + string(10 - sum14 mod 10)
             .
           end.
        end.
      end.
    end.
  end.
            PriceSale = buf_utd-l.Total / buf_utd-l.Quantity.
            decDocQnty = buf_utd-l.Quantity.
            for each buf_utd-m-l where buf_utd-m-l.db-num = buf_utd.db-num and buf_utd-m-l.doc-id = buf_utd.doc-id and buf_utd-m-l.LineNum = buf_utd-l.LineNum
              no-lock
              :
              vmark = ismark(buf_utd-m-l.mark).
              if vmark
              then do:
                 find first buf_m no-lock where buf_m.mark = buf_utd-m-l.mark no-error.
                 if not available (buf_m)
                 then do:
                   logWrite:WriteFileToLog(substitute ("Некорректная марка &1.", buf_utd-m-l.mark)).
                   next.
                 end.
              end.
              jj = jj + 1.
              if vmark
                 and available buf_m
              then do:
                 vqnty = buf_m.box-qnty.
                 if vqnty = ? then vqnty = decimal(GetAttrUtdlinesEx (buf_utd-m-l.db-num,buf_utd-m-l.doc-id,buf_utd-m-l.lineNum,"box-qnty","0")) no-error.
              end.
              else vqnty = decimal(GetAttrUtdlinesEx (buf_utd-m-l.db-num,buf_utd-m-l.doc-id,buf_utd-m-l.lineNum,"box-qnty","0")) no-error.
              if vqnty = ? then vqnty = 0.
              addDocLineMark(
                    jj,
                      v-doc-num,
                    buf_utd-l.linenum,
                    buf_m-l.mark,
                      v-doc-num + "_" + string (buf_goods.gds-code),
                      "CrTSD",
                      (if available buf_m then buf_m.mark-parent else ""),
                    vqnty,
                    if available buf_m then  buf_m.unit-ext else ""
                    ).
            end.
          end.
        end.
      end.
      if v-is-introduce
        then doctype = "InvIntroduce".
        else docType = "InvMarks".
      addDoc(
           v-doc-num,
           docType,
           false,
           buf_trn-doc.status_ + string (buf_trn-doc.flag, "+/-"),
           buf_trn-doc.cli-code,
           buf_trn-doc.cli-type,
           buf_trn-doc.obj-code,
           buf_trn-doc.obj-type,
           "",
            "",
           0,
           now,
           myflagsDoc:FlagsToInt
      ).
      logWrite:WriteDebugLog( "Выгружен документ " + buf_trn-doc.doc-code).
    end.
  end.
  method private character decToString (iValue as decimal ):
     return replace(trim(string(iValue, "->>>>>>>>>>>>9.9<<<<<")),".",",").
  end.
  method private void addDoc(
     idoc-num as char,
     idocType as char,
     icomplite as logical,
     istatus as char,
     icli-code as int,
     icli-type as char,
     iobj-code as int,
     iobj-type as char,
     iuser-id as character,
     iuser-login as char,
     iFactSum as dec,
     idoc-date as datetime-tz,
     iflags as int
  ):
     find first TempTrnDocMT where TempTrnDocMT.DocName eq idoc-num no-lock no-error.
     if not available TempTrnDocMT
     then do:
        create TempTrnDocMT.
        TempTrnDocMT.DocName = idoc-num.
     end.
     assign
        TempTrnDocMT.DocType     = idocType
        TempTrnDocMT.Complete_   = icomplite
        TempTrnDocMT.Status_     = istatus
        TempTrnDocMT.ClientID    = icli-code
        TempTrnDocMT.ClientType  = icli-type
        TempTrnDocMT.ObjectID    = iobj-code
        TempTrnDocMT.ObjectType  = iobj-type
        TempTrnDocMT.UserID_     = iuser-id
        TempTrnDocMT.UserName    = iuser-login
        TempTrnDocMT.FactSum     = iFactSum
        TempTrnDocMT.StartDate   = idoc-date
        TempTrnDocMT.Flags_      = iflags
      .
  end.
  method public void docPrint(idir as char):
     tsdstreamopenapp(idir + "\MT_documents.txt").
     for each TempTrnDocMT no-lock:
        put stream tsdstream unformatted
        TempTrnDocMT.DocName + chr(30) +
        TempTrnDocMT.DocType + chr(30) +
        string(TempTrnDocMT.Complete_,"true/false") + chr(30) +
        TempTrnDocMT.Status_ + chr(30) +
        string (TempTrnDocMT.ClientID) + chr(30) +
        TempTrnDocMT.ObjectType + chr(30) +
        string (TempTrnDocMT.ObjectID) + chr(30) +
        TempTrnDocMT.ObjectType + chr(30) +
        TempTrnDocMT.UserID_ + chr(30) +
        TempTrnDocMT.UserName + chr(30) +
        decToString(TempTrnDocMT.FactSum) + chr(30) +
        iso-date (TempTrnDocMT.StartDate) + chr(30)
        + string(TempTrnDocMT.Flags_) + chr(31).
     end.
     tsdstreamclose().
  end.
  method private void addDocLine(pos as integer,
                       idoc-num as char,
                       iline-num as int,
                       igds-code as int,
                       igds-name as character ,
                       iunit-base as character ,
                       ifull-b-code as char,
                       ipriceSale as dec,
                       idocQnty as dec,
                       ifactQnty as  dec,
                       iError as char,
                       iRecKey as char,
                       iflags as int
  ):
     find first TempTrnLineMT where TempTrnLineMT.docname eq idoc-num
                              and TempTrnLineMT.pos eq pos
     no-lock no-error.
     if not available TempTrnLineMT
     then do:
        create TempTrnLineMT.
        assign
           TempTrnLineMT.docname = idoc-num
           TempTrnLineMT.pos = pos
        .
     end.
     assign
        TempTrnLineMT.goodsid     = igds-code
        TempTrnLineMT.goodsname   = igds-name
        TempTrnLineMT.UnitBC      = iunit-base
        TempTrnLineMT.BC          = ifull-b-code
        TempTrnLineMT.Price_      = ipriceSale
        TempTrnLineMT.DocQnty     = idocQnty
        TempTrnLineMT.FactQnty    = ifactQnty
        TempTrnLineMT.Error       = iError
        TempTrnLineMT.PartIDTH    = iRecKey
        TempTrnLineMT.Flags_      = iflags
        TempTrnLineMT.lineId      = iline-num
     .
  end.
  method public void docLinePrint(idir as char):
      tsdstreamopenapp(idir + "\MT_lines.txt").
      for each TempTrnLineMT no-lock:
        put stream tsdstream unformatted
          substitute ("&2&1&3&1&4&1&5&1&6&1&7&1&8&1&9&1",
                      chr(30),
                      TempTrnLineMT.pos,
                      TempTrnLineMT.docname ,
                      TempTrnLineMT.lineid,
                      TempTrnLineMT.goodsid,
                      TempTrnLineMT.goodsname,
                      TempTrnLineMT.UnitBC,
                      TempTrnLineMT.BC,
                      decToString(TempTrnLineMT.Price_)
                     )
        +
         substitute ("&3&1&4&1&5&1&6&1&7&2",
                      chr(30),
                      chr(31),
                      decToString(TempTrnLineMT.DocQnty),
                      decToString(TempTrnLineMT.FactQnty),
                      TempTrnLineMT.Error,
                      TempTrnLineMT.PartIDTH,
                      TempTrnLineMT.Flags_
                      )
                     .
      end.
      tsdstreamclose().
  end.
  method private void addDocLineMark(
     iline-num as integer,
     idoc-num as char,
     pos as int,
     imark as char,
     iRecKey as char,
     iStatus as char,
     iMarkParent as char,
     iMarkQnty as int,
     iUnitBox as char
  ):
     find first TempMarkLineMT where TempMarkLineMT.DocName  eq idoc-num
                                  and TempMarkLineMT.MarkCode     eq imark
     no-error.
     if not available TempMarkLineMT
     then do:
        create TempMarkLineMT.
        assign
           TempMarkLineMT.DocName = idoc-num
           TempMarkLineMT.MarkCode     = imark
        .
     end.
     assign
        TempMarkLineMT.pos         = pos
        TempMarkLineMT.lineID      = iline-num
        TempMarkLineMT.PartIDTH      = iRecKey
        TempMarkLineMT.Status_     = iStatus
        TempMarkLineMT.MarkParent  = iMarkParent
        TempMarkLineMT.BoxQnty    = iMarkQnty
        TempMarkLineMT.UnitBox    = iUnitBox
     .
  end.
  method public void docLineMarkPrint(idir as char):
     tsdstreamopenapp(idir + "\MT_MarkLines.txt").
     for each TempMarkLineMT no-lock:
     put stream tsdstream unformatted
         substitute ("&3&1&4&1&5&1&6&1&7&8&2",
                chr(30),
                chr(31),
                TempMarkLineMT.lineId,
                TempMarkLineMT.DocName,
                TempMarkLineMT.MarkCode,
                TempMarkLineMT.PartIDTH,
                TempMarkLineMT.Status_,
                if     TempMarkLineMT.MarkParent ne ?
                   and TempMarkLineMT.BoxQnty   ne ?
                then
                   substitute ("&1&2&1&3",chr(30),
                                        TempMarkLineMT.MarkParent,
                                        TempMarkLineMT.BoxQnty)
                else ""
               )
      .
      end.
      tsdstreamclose().
    end.
  method public void docWrite():
     docPrint(resType,cp).
  end.
  method public void docPrint(type as char,encoding as char):
     for each TempTrnDocMT no-lock:
        create TempTrnLineMTs.
        TempTrnLineMTs.DocName = TempTrnDocMT.DocName.
     end.
     ttPrint(type,
        DATASET  ds-doc:handle,encoding).
     empty temp-table TempTrnLineMTs .
  end.
  method public logical parseCSV( idir as char ):
    define variable lResult    as logical   no-undo.
    define variable cFactQnty  as decimal  no-undo.
    define variable cDocQnty   as decimal  no-undo.
    define variable cPriceRubl as decimal  no-undo.
    define variable RowSum     as decimal   no-undo.
    define variable iDbNum     as integer   no-undo.
    define variable docType    as character no-undo.
    define variable vFilename  as character no-undo.
    myflagsDoc:unSetAllFlags().
    iDbNum = GetDbNum().
    empty temp-table TempTrnDocMT.
    empty temp-table TempTrnLineMT.
    empty temp-table TempMarkLineMT.
    vFilename = idir + "\MT_documentsSend.json".
    if SearchFile(vFilename) ne ?
    then do:
       dataset ds-doc:read-json ("file",SearchFile(vFilename),"EMPTY").
    end.
    for each TempTrnDocMT where TempTrnDocMT.Complete_ = true:
      logWrite:WriteDebugLog("Загружаем документ " + TempTrnDocMT.DocName).
      empty temp-table TempTrnDoc.
      empty temp-table TempDocLine.
      empty temp-table TempMarkLine.
      case TempTrnDocMT.DocType:
        when "ExtSalesWB" then do:
          docType = 'ee':U.
        end.
        when "IntSalesWB" then do:
          docType = 'ev':U.
        end.
        when "ExtPurchWB" then do:
          docType = 'ie':U.
        end.
        when "IntPurchWB" then do:
          docType = 'iv':U.
        end.
        when "Inv" then do:
          docType = 'vt':U.
        end.
        when "Introduce" then do:
          docType = "UTD_Introduce".
        end.
        when "UTD" then do:
          docType = "UTD_DOC".
        end.
        when "InvMarks" then do:
          docType = "invmark".
        end.
        when "MarksInv" then do:
          docType = "MarksInv".
        end.
        when "InvIntroduce" then do:
          docType = "InvIntroduce".
        end.
      end case.
      userId_ = TempTrnDocMT.UserID_.
      find first ub.user-login where ub.user-login.db-num = iDbNum and ub.user-login.user-id = userId_ no-lock no-error.
      create TempTrnDoc.
      assign
        TempTrnDoc.line-num     = 1
        TempTrnDoc.doc-date     = today
        TempTrnDoc.ext-doc-code = TempTrnDocMT.DocName
        TempTrnDoc.ext-doc-type = docType
        TempTrnDoc.cli-type     = TempTrnDocMT.ClientType
        TempTrnDoc.cli-code     = integer(TempTrnDocMT.ClientID)
        TempTrnDoc.obj-type     = TempTrnDocMT.ObjectType
        TempTrnDoc.obj-code     = TempTrnDocMT.ObjectID
        TempTrnDoc.ps           = if available (ub.user-login) then "" else " Пользователь: " + TempTrnDocMT.UserName
        TempTrnDoc.Status_      = TempTrnDocMT.Status_
        TempTrnDoc.Flags_       = TempTrnDocMT.Flags_
        .
      myflagsDoc:setFlagsToInt(TempTrnDocMT.Flags_).
      define variable cFactQntyDec as decimal no-undo .
      define variable cPriceRublDec as decimal no-undo .
      for each TempTrnLineMT where TempTrnLineMT.docname = TempTrnDocMT.DocName:
          cDocQnty   = TempTrnLineMT.DocQnty .
          cFactQnty  = TempTrnLineMT.FactQnty .
          cPriceRubl = TempTrnLineMT.Price_ .
          RowSum    = cFactQnty * cPriceRubl .
        if myflagsDoc:isDocMarkOn and (docType = 'ie':U or docType = 'iv':U)
        then do:
          find first TempDocLine no-lock
            where TempDocLine.gds-code = integer (TempTrnLineMT.goodsid)
              and TempDocLine.b-code = (TempTrnLineMT.BC) no-error.
          if not available (TempDocLine)
          then do:
            create TempDocLine.
            assign
              TempDocLine.line-num     = integer (TempTrnLineMT.pos)
              TempDocLine.gds-code     = integer (TempTrnLineMT.goodsid)
              TempDocLine.b-code       = string (TempTrnLineMT.BC)
              TempDocLine.fact-qnty    = decimal(cFactQnty)
              TempDocLine.doc-qnty     = decimal(cDocQnty)
              TempDocLine.price-rubl   = ?
              TempDocLine.RowSum       = ?
              TempDocLine.PartIDTH     = TempTrnLineMT.PartIDTH
              TempDocLine.NotDict      = TempTrnLineMT.goodsid eq 0
              .
          end.
          else do:
            assign
              TempDocLine.fact-qnty    = TempDocLine.fact-qnty + cFactQnty
              TempDocLine.PartIDTH     = TempDocLine.PartIDTH + chr(4) + TempTrnLineMT.PartIDTH
            .
          end.
        end.
        else do:
          create TempDocLine.
          assign
            TempDocLine.line-num     = TempTrnLineMT.pos
            TempDocLine.gds-code     = TempTrnLineMT.goodsid
            TempDocLine.b-code       = TempTrnLineMT.BC
            TempDocLine.fact-qnty    = cFactQnty
            TempDocLine.doc-qnty     = cDocQnty
            TempDocLine.price-rubl   = cPriceRubl
            TempDocLine.RowSum       = RowSum
            TempDocLine.PartIDTH = TempTrnLineMT.PartIDTH
            TempDocLine.NotDict      = TempTrnLineMT.goodsid eq 0
            .
        end.
      end.
      for each TempMarkLineMT
          :
        create TempMarkLine.
        assign
          TempMarkLine.DocName     =  TempMarkLineMT.DocName
          TempMarkLine.PartIDTH    =  TempMarkLineMT.PartIDTH
          TempMarkLine.MarkCode    =  TempMarkLineMT.MarkCode
          TempMarkLine.Sts         =  TempMarkLineMT.Status_
          TempMarkLine.MarkParent  =  TempMarkLineMT.MarkParent
          .
      end.
      updatedocument(doctype, table TempTrnDoc, table TempDocLine, table TempMarkLine, userId_).
      logWrite:WriteDebugLog("Загружен документ " + TempTrnDocMT.DocName).
    end.
    return true.
  end.
  method public void ttPrint(type as char,htable as handle):
     ttPrint(type, htable, cp).
  end.
  method public void ttPrint(type as char, htable as handle, encoding as char):
     if type eq "xml"
     then
        htable:WRITE-XML("longchar",SomeStr, true, encoding, ?, false, true ,false,true).
     else if type eq "json"
     then do:
        htable:WRITE-json("longchar",SomeStr,TRUE,?,true,true,false).
     end.
     else
        SomeStr = getStatusXml(false,"Тип ответа не подерживается responseType должно быть xml или json") .
  end.
  method public void docClear():
     empty temp-table TempTrnDocMT.
     empty temp-table TempTrnLineMTs.
     empty temp-table TempTrnLineMT.
     empty temp-table TempTrnLineMTs.
     empty temp-table TempTrnLineMT.
  end.
  define STREAM sReadDir.
  define temp-table tt-version no-undo
     field fnAME    as character
     field FullPath as character
     field device   as character
     field version  as character
  index version device version
  index fnAME FullPath fnAME.
  method private void importVersion():
     define variable vPureName as character no-undo.
     define variable vFullPath as character no-undo.
     define variable vFileType as character no-undo.
     define variable mpos as integer no-undo.
     define buffer ttfile for tt-version.
     empty temp-table tt-version.
     define variable vDir as character no-undo.
     vdir = replace(search("exe/7z.exe"),"7z.exe","tsd").
     if objExists(vdir,"d") ne ?
     then do:
        input STREAM sReadDir FROM os-dir(vdir).
        repeat:
           import stream sReadDir vPureName vFullPath vFileType.
           if vPureName begins "." then next.
           if vFileType =  "f" then
           do:
              find first ttfile where ttfile.FullPath = vFullPath
                                  and ttfile.fnAME     = vPureName
              no-error.
              if not available ttfile
              then do:
                 create ttfile.
                 assign
                    ttfile.fnAME         = vPureName
                    ttfile.FullPath      = vFullPath
                 no-error.
                 mpos = r-index (vPureName,".").
                 if mpos > 0
                 then
                    vPureName = substring (vPureName,1,mpos - 1).
                 mpos = index (vPureName,"_").
                 if mpos = 0
                 then
                    ttfile.device = vPureName.
                 else assign
                    ttfile.device  = CAPS(substring (vPureName,1,mpos - 1))
                    ttfile.version = substring (vPureName,  mpos + 1)
                 .
              end.
           end.
         end.
      end.
   end.
   method public void getListVersions():
       importVersion().
       SomeStr = getStatusXml(true,"",getVersion()).
   end.
   method private longchar getVersion():
      define variable vVertion as longchar no-undo.
      for each tt-version break by tt-version.device:
         if first-of (tt-version.device)
         then do:
             vVertion = vVertion + substitute ("<&1><VERSIONS>",tt-version.device).
         end.
         vVertion = vVertion + substitute ("<VERSION>&1</VERSION>",tt-version.version).
         if last-of (tt-version.device)
         then do:
            vVertion = vVertion + substitute ("</VERSIONS><LASTVERSION>&2</LASTVERSION></&1>",tt-version.device,tt-version.version).
         end.
      end.
      return vVertion.
   end.
   method public char getFileVersion(iDevice as char,iversion as char):
      importVersion().
      if iversion = "" or iversion = ?
      then
         find last tt-version where tt-version.device = iDevice no-lock no-error.
      else
         find first tt-version where tt-version.device = iDevice
                                 and tt-version.version = iversion
         no-lock no-error.
      return if available tt-version then tt-version.FullPath else ?.
   end.
   method public character addPrintBc(igds-code as integer, iqnty as decimal):
      define buffer code for code.
      define buffer goods for goods.
      define buffer bar-code for bar-code.
      find first goods where goods.gds-code =  igds-code no-lock no-error.
      if not available goods
      then
         return substitute ("Не известный код товара &1", igds-code).
      find first code  where code.parent eq "TiketPrint"
                         and code.code   eq string(igds-code)
      exclusive-lock no-error.
      if not available code
      then do:
         create code.
         assign
            code.parent = "TiketPrint"
            code.code = string(igds-code)
            Code.CodeValue = string(iqnty)
         .
      end.
      assign
         Code.CodeName = goods.gds-name
         code.status_ = 0
      .
  end.
end class.
