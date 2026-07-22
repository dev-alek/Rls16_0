using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.str.*.
using ibs.th.str.ptrl.* from propath.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.inv-gd-doc implements iexpsubject:
method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define public var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
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
  define temp-table buf_trn-doc like ub.trn-doc.
  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_doc-line-attr for ub.doc-line-attr.
  define buffer bf_doc-line-sum for ub.doc-line-sum.
  define buffer buf_doc-pl for ub.doc-pl.
  define buffer buf_gds for ub.goods.
  define buffer buf_doc-attr for ub.doc-attr.
  define buffer buf_units for ub.units.
  define buffer bf_rvs-line for ub.rvs-line.
  define buffer bf_rvs-doc for ub.rvs-doc.
  define buffer bf_gen-attr for ub.gen-attr.
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
  define property BufTableHndlNew as handle no-undo
    get.
    set.
  define property BufTableHndlOld as handle no-undo
    get.
    set.
  define public property sendTableName as character no-undo init "trn-doc"
    get.
  define public property sendOldRowid as rowid  no-undo
    get.
    set.
  define public property sendNewRowid as rowid  no-undo
    get.
    set.
  define variable rvsinvObj        as class rvsinvsub no-undo .
  define variable sw               as handle    no-undo.
  define variable v-is-petrol-trn  as logical   no-undo.
  define variable v-is-pieces      as logical   no-undo.
  define variable isDel            as logical   no-undo.
  define variable varinvclcwt      as logical   no-undo.
  define variable varinvclcas      as logical   no-undo.
  define variable varinvclcex      as logical   no-undo.
  define variable varinvclcms      as logical   no-undo.
  define variable varinvclcbef     as logical   no-undo.
  define variable prtvalue         as character no-undo.
  define variable varinvclcspvalue as character no-undo.
  define variable varr-b           as character no-undo.
  define variable is-cdinv         as character no-undo .
  define variable v-bufhnd         as handle    no-undo.
  define variable v-doc-num        as character no-undo .
  define variable dprice-sale      as decimal   no-undo .
  define variable droad-tax        as decimal   no-undo .
  define variable dexcise          as decimal   no-undo .
  define variable v-qnty-type      as character no-undo .
  define variable dcurr-price      as decimal   no-undo .
  define variable prc-density      as decimal   no-undo .
  define variable dLoss-qnty       as decimal   no-undo .
  define variable dLoss-sum        as decimal   no-undo .
  define temp-table tt-marks no-undo
    field mark as character.
  constructor public inv-gd-doc():
    if not valid-handle (ibs.th.gbl.gbl-hndllib:g#trdcalib) then
      run str/trdcalib.p persistent no-error .
  end constructor.
  method public void CrContentToSW (insw as handle):
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
    define variable p-value      as character no-undo.
    define variable p-type       as character no-undo.
    sw = insw.
    create buf_trn-doc.
    v-bufhnd = buffer buf_trn-doc:handle.
    if valid-handle (BufTableHndlNew)
    then do:
      sendNewRowid  = BufTableHndlNew:rowid.
      v-bufhnd:buffer-copy (BufTableHndlNew) no-error.
      if error-status:error
      then do:
        Msg = "Ошибка выгрузки inv-gd-doc, неверный буфер BufTableHndlNew".
        undo, return error Msg.
      end.
      isDel = false.
    end.
    else do:
      if not valid-handle (BufTableHndlOld)
      then do:
        Msg = "Ошибка выгрузки inv-gd-doc, неопеределен ни старый ни новый буфер".
        undo, return error Msg.
      end.
      sendOldRowid  = BufTableHndlOld:rowid.
      v-bufhnd:buffer-copy (BufTableHndlOld) no-error.
      if error-status:error
      then do:
        Msg = "Ошибка выгрузки inv-gd-doc, неверный буфер BufTableHndlOld".
        undo, return error Msg.
      end.
      isDel = true.
    end.
    for each buf_inv-line no-lock where buf_inv-line.doc-code = buf_trn-doc.doc-code:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in ibs.th.gbl.gbl-hndllib:g#lib-trn
  (
     input buf_inv-line.artic
  ,  input buf_inv-line.prod-type
  ,  input buf_inv-line.prod-code
  , output v-is-petrol-trn
  , output v-is-pieces
  ) .
      if v-is-petrol-trn
        then leave.
    end.
run trdcalib_tdat-val in ibs.th.gbl.gbl-hndllib:g#trdcalib (  input buf_trn-doc.doc-code ,
                        input 'addsum':U ,
                       output p-value ,
                       output p-type )  .
    assign
      varinvclcbef = no
      varinvclcas  = no
      varinvclcex  = no
      varinvclcms  = no
      varinvclcwt  = no
    .
    if lookup( 'bd':U, p-value ) <> 0 then do:
      assign
        varinvclcbef = yes
      .
    end.
    if lookup( 'gen':U, p-value ) <> 0 then do:
      assign
        varinvclcas = yes
      .
    end.
    if lookup( 'ext':U, p-value ) <> 0 then do:
      assign
        varinvclcex = yes
      .
    end.
    if lookup( 'mis':U, p-value ) <> 0 then do:
      assign
        varinvclcms = yes
      .
    end.
    if lookup( 'wst':U, p-value ) <> 0 then do:
      assign
        varinvclcwt = yes
      .
    end.
    run str/invdcfrd.p (  input buf_trn-doc.doc-code,
                     output varinvclcspvalue,
                     output prtvalue,
                     output varr-b ,
                     output is-cdinv
                     ) no-error.
    if v-is-petrol-trn
    then do:
      StartDocInvFuel().
      GdsLineFuel().
      EndDocInvFuel().
    end.
    else do:
      StartDocInv().
      GdsLine().
      EndDocInv().
    end.
  end.
  method private void GdsLine ():
    define variable vGT as integer no-undo .
    define variable vGtin as character no-undo .
    define variable vGtinQnty as integer no-undo .
    sw:start-element ("gds").
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code:
      find first buf_gds where
            buf_gds.artic = buf_doc-line.artic
        and buf_gds.prod-code = buf_doc-line.prod-code
        and buf_gds.prod-type = buf_doc-line.prod-type.
      find first buf_doc-line-attr no-lock where buf_doc-line-attr.doc-code = buf_doc-line.doc-code
                                             and buf_doc-line-attr.gds-code = buf_gds.gds-code
                                             and buf_doc-line-attr.attr-code = "GTIN-qnty"
                                             no-error .
      sw:start-element ("gd").
        write-data-element ("gd-code", string-mth (buf_gds.gds-code)).
        write-data-element ("qnty-b", string-mth (round (buf_doc-line.doc-qnty - buf_doc-line.fact-qnty, 3))).
        write-data-element ("qnty-a", string-mth (round (buf_doc-line.doc-qnty, 3))).
        write-data-element ("qnty-df", string-mth (round (buf_doc-line.fact-qnty, 3))).
        write-data-element ("qnty-izl", string-mth (round (fncextra-qnty( buffer buf_doc-line ), 3))).
        write-data-element ("qnty-ned", string-mth (round (fncmiss-qnty( buffer buf_doc-line ), 3))).
        write-data-element ("qnty-eu", string-mth (round (0.0, 3))).
        write-data-element ("sum-b", string-mth (round (fncbefore-rubl( buffer buf_doc-line, buffer buf_gds ), 2))).
        write-data-element ("sum-a", string-mth (round (fncafter-rubl( buffer buf_doc-line, buffer buf_gds ), 2))).
        write-data-element ("sum-izl", string-mth (round (fncextra-rubl( buffer buf_doc-line, buffer buf_gds ), 2))).
        write-data-element ("sum-ned", string-mth (round (fncmiss-rubl( buffer buf_doc-line, buffer buf_gds ), 2))).
        write-data-element ("sum-eu", string-mth (round ( fncwastage( buffer buf_doc-line, buffer buf_gds ), 2))).
        write-data-element ("sum-b-s", string-mth (round (fncbefore-rubl( buffer buf_doc-line, buffer buf_gds ), 2))).
        write-data-element ("sum-a-s", string-mth (round (fncafter-rubl( buffer buf_doc-line, buffer buf_gds ), 2))).
        define variable vqnty as decimal no-undo.
        run str/getost.p (buf_doc-line.obj-type,buf_doc-line.obj-code,buf_gds.gds-code, buf_doc-line.doc-code, output vqnty ).
        write-data-element ("qnty-delta",string(round (buf_doc-line.doc-qnty - buf_doc-line.fact-qnty - vqnty, 3))).
        if can-find (first bf_gen-attr no-lock where bf_gen-attr.table-name = "inv-doc-mark" and bf_gen-attr.attr-code = buf_trn-doc.doc-code
          and bf_gen-attr.attr-value = string(buf_gds.gds-code) and not bf_gen-attr.p-key begins 'tech_':U)
        then do:
          sw:start-element ("marks").
          for each bf_gen-attr no-lock where bf_gen-attr.table-name = "inv-doc-mark" and bf_gen-attr.attr-code = buf_trn-doc.doc-code
            and bf_gen-attr.attr-value = string(buf_gds.gds-code) and not bf_gen-attr.p-key begins 'tech_':U:
            sw:start-element ("mark").
            write-data-element ("mark-code", repSpecSimbforXlm( addBracketForCode(bf_gen-attr.p-key))).
            sw:end-element ("mark").
          end.
          sw:end-element ("marks").
        end.
        else
        if available buf_doc-line-attr
        and buf_doc-line-attr.attr-value > ""
        then do :
          sw:start-element ("marks").
          GT_ :
          do vGT = 1 to num-entries(buf_doc-line-attr.attr-value, ";") :
            assign
              vGtin = entry(1, entry(vGT, buf_doc-line-attr.attr-value, ";"), "=")
              vGtinQnty = integer(entry(2, entry(vGT, buf_doc-line-attr.attr-value, ";"), "="))
            no-error .
            if error-status:error
            then next GT_ .
            sw:start-element ("mark").
            write-data-element ("gtin", vGtin) .
            write-data-element ("gtin-qnt", string-mth(vGtinQnty)) .
            sw:end-element ("mark").
          end .
          sw:end-element ("marks").
        end .
      sw:end-element ("gd").
    end.
    sw:end-element ("gds").
  end.
  method private void GdsLineFuel ():
    define variable dAddCliQnty       as decimal   no-undo .
    define variable dAddQnty          as decimal   no-undo .
    define variable v-sum-b           as decimal   no-undo .
    define variable v-sum-a           as decimal   no-undo .
    define variable v-sum-b-s         as decimal   no-undo .
    define variable v-sum-a-s         as decimal   no-undo .
    define variable v-sum-df          as decimal   no-undo .
    find first bf_rvs-doc no-lock where
             bf_rvs-doc.rvs-code = buf_trn-doc.out-code no-error .
    sw:start-element ("gds").
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code:
      find first buf_gds where
            buf_gds.artic = buf_doc-line.artic
        and buf_gds.prod-code = buf_doc-line.prod-code
        and buf_gds.prod-type = buf_doc-line.prod-type.
      for each buf_doc-pl no-lock where buf_doc-pl.obj-type = buf_doc-line.obj-type and buf_doc-pl.obj-code = buf_doc-line.obj-code
        and buf_doc-pl.out-code = buf_doc-line.doc-code and buf_doc-pl.gds-code = buf_gds.gds-code:
        assign
          dAddCliQnty = 0.0
          dAddQnty = 0.0
        .
        find first bf_rvs-line no-lock where
          available (bf_rvs-doc) and
          bf_rvs-line.rvs-code = buf_trn-doc.out-code and
          bf_rvs-line.obj-type = buf_doc-line.obj-type and
          bf_rvs-line.obj-code = buf_doc-line.obj-code and
          bf_rvs-line.gds-code = buf_doc-pl.gds-code and
          bf_rvs-line.pl-code = buf_doc-pl.pl-code no-error.
        if available (bf_rvs-line)
        then
          assign
            dAddCliQnty   = bf_rvs-line.state-add-qnty * bf_rvs-line.state-density
            dAddQnty  = bf_rvs-line.state-add-qnty.
        assign
          v-sum-b-s = fncbefore-rubl( buffer buf_doc-line, buffer buf_gds)
          v-sum-a-s = fncafter-rubl( buffer buf_doc-line, buffer buf_gds)
          v-sum-b = v-sum-b-s / (buf_doc-line.doc-qnty - buf_doc-line.fact-qnty) * buf_doc-pl.rest-bf-qnty
          v-sum-a = v-sum-a-s / buf_doc-line.doc-qnty * buf_doc-pl.rest-af-qnty
          v-sum-df = v-sum-a - v-sum-b
        .
        find first buf_units where buf_units.unit-name = buf_gds.unit-base.
        sw:start-element ("gd").
          write-data-element ("tank-num", string-mth (buf_doc-pl.pl-code)).
          write-data-element ("gd-code", string-mth (buf_gds.gds-code)).
          write-data-element ("cap-b", string-mth (round (buf_doc-pl.rest-bf-qnty, 3))).
          write-data-element ("cap-a", string-mth (round (buf_doc-pl.rest-af-qnty, 3))).
          write-data-element ("cap-df", string-mth (round (buf_doc-pl.rest-af-qnty - buf_doc-pl.rest-bf-qnty, 3))).
          write-data-element ("wght-b", string-mth (round (buf_doc-pl.cli-rest-bf-qnty, 3))).
          write-data-element ("wght-a", string-mth (round ( buf_doc-pl.cli-rest-af-qnty , 3))).
          write-data-element ("wght-df", string-mth (round (buf_doc-pl.cli-fact-qnty, 3))).
          write-data-element ("sum-b", string-mth (round
                (
                  v-sum-b
                , 2))).
          write-data-element ("sum-a", string-mth (round
                (
                  v-sum-a
                , 2))).
          write-data-element ("sum-df", string-mth (round
                (
                  v-sum-df
                , 2))).
          write-data-element ("wght-izl", string-mth (round ((if buf_doc-pl.cli-fact-qnty > 0 then buf_doc-pl.cli-fact-qnty else 0.0), 3))).
          write-data-element ("wght-ned", string-mth (round ((if buf_doc-pl.cli-fact-qnty < 0 then absolute (buf_doc-pl.cli-fact-qnty) else 0.0), 3))).
          write-data-element ("sum-izl", string-mth (round ((if v-sum-df > 0 then v-sum-df else 0.0), 2))).
          write-data-element ("sum-ned", string-mth (round ((if v-sum-df < 0 then absolute (v-sum-df) else 0), 2))).
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run bcodeprc in ibs.th.gbl.gbl-hndllib:g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,input  buf_gds.gds-code
  ,input  0
  ,input  buf_trn-doc.fact-order
  ,output v-doc-num
  ,output dprice-sale
  ,output droad-tax
  ,output dexcise
  ) no-error .
          if error-status :error
          then do:
            Msg = 'Не могу определить текущие продажные цены.'.
            undo, return error Msg.
          end.
          assign
            v-qnty-type = "cli":U
          .
          assign
            dcurr-price = dprice-sale
          .
          assign
            dLoss-qnty = 0.0
          .
          find first bf_doc-line-sum no-lock
            where bf_doc-line-sum.doc-code  = buf_trn-doc.doc-code
              and bf_doc-line-sum.gds-code  = buf_gds.gds-code
              and bf_doc-line-sum.sum-type  = substitute( "&1&2&3&2&4", 'wst':U, chr(4), 'base', buf_doc-pl.pl-code )
            no-error .
          if available bf_doc-line-sum then do:
            assign
              dLoss-qnty = bf_doc-line-sum.fact-qnty
            .
          end.
          assign
            dLoss-sum  = dLoss-qnty  * dcurr-price
          .
          assign
            dLoss-qnty = 0.0
          .
          find first bf_doc-line-sum no-lock
            where bf_doc-line-sum.doc-code  = buf_trn-doc.doc-code
              and bf_doc-line-sum.gds-code  = buf_gds.gds-code
              and bf_doc-line-sum.sum-type  = substitute( "&1&2&3&2&4", 'wst':U, chr(4), 'cli', buf_doc-pl.pl-code )
            no-error .
          if available bf_doc-line-sum then do:
            assign
              dLoss-qnty = bf_doc-line-sum.fact-qnty
            .
          end.
          write-data-element ("wght-eu", string-mth (round (dLoss-qnty, 2))).
          write-data-element ("sum-eu", string-mth (round ( dLoss-sum, 2))).
          write-data-element ("pipeline-cap", string-mth (round (dAddQnty, 2))).
          write-data-element ("pipeline-wght", string-mth (round (dAddCliQnty, 2))).
          rvsinvObj = new rvsinvsub ().
          if available (bf_rvs-line)
          then do:
          assign
            rvsinvObj:RvsCode = bf_rvs-line.rvs-code
            rvsinvObj:ObjCode = buf_trn-doc.obj-code
            rvsinvObj:ObjType = buf_trn-doc.obj-type
            rvsinvObj:PlCode = bf_rvs-line.pl-code
            rvsinvObj:GdsCode =  buf_gds.gds-code
          .
          end.
          if rvsinvObj:RvsInvStrObj:FillSub(rvsinvObj)
          then do:
            write-data-element ("wght-tp-N", string-mth (round (rvsinvObj:TPNormal, 3))).
            write-data-element ("wght-tp-F", string-mth (round (rvsinvObj:TPWast, 3))).
          end.
          else do:
            write-data-element ("wght-tp-N", string-mth (round (0.0, 3))).
            write-data-element ("wght-tp-F", string-mth (round (0.0, 3))).
          end.
        sw:end-element ("gd").
      end.
    end.
    sw:end-element ("gds").
  end.
  method private void StartDocInv ():
      InitSecTag =  "inv-gd-docs".
      sw:start-element ("inv-gd-doc") .
        write-data-element ("doc-code", buf_trn-doc.doc-code).
        write-data-element ("doc-num", buf_trn-doc.doc-code).
        write-data-element ("del-f", string (isDel, "1/0") ).
        write-data-element ("doc-date", if buf_trn-doc.doc-date = ? then "" else iso-date (datetime (buf_trn-doc.doc-date, buf_trn-doc.real-time-create * 1000))).
        write-data-element ("fact-date", if buf_trn-doc.fact-date = ? then "" else iso-date (datetime (buf_trn-doc.fact-date, buf_trn-doc.fact-time * 1000))).
        write-data-element ("shift-date", if buf_trn-doc.shift-date = ? then "" else iso-date (date (buf_trn-doc.shift-date))).
        write-data-element ("shift-num", if buf_trn-doc.shift-num = ? then "0" else string-mth (buf_trn-doc.shift-num)).
    sw:start-element ("atr") .
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = "invTech" and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code no-error .
    if available (ub.inv-doc-attr) then
    do:
      if ub.inv-doc-attr.attr-value = string(true) then write-data-element ("techop", "1").
      else write-data-element ("techop", "0").
    end.
    else
    do:
      write-data-element ("techop", "0").
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-prikaz-number':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("ordernum", ub.inv-doc-attr.attr-value).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-prikaz-date':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("orderdate", iso-date (date (ub.inv-doc-attr.attr-value))).
    end.
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-inv-date':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code no-error .
    if available (ub.inv-doc-attr) then
    do:
      if ub.inv-doc-attr.attr-value <> "" then write-data-element ("invbegin", iso-date (date (ub.inv-doc-attr.attr-value))).
      else write-data-element ("invbegin", if buf_trn-doc.doc-date = ? then "" else iso-date (date (buf_trn-doc.doc-date))).
    end.
    else
    do:
      write-data-element ("invbegin", if buf_trn-doc.doc-date = ? then "" else iso-date (date (buf_trn-doc.doc-date))).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-fio-agent':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("chairmen1", ub.inv-doc-attr.attr-value).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-fio-player1':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("chairmen2", ub.inv-doc-attr.attr-value).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-fio-player2':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("chairmen3", ub.inv-doc-attr.attr-value).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-fio-player3':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("chairmen4", ub.inv-doc-attr.attr-value).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-pos-agent':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("jobtitle1", ub.inv-doc-attr.attr-value).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-pos-player1':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("jobtitle2", ub.inv-doc-attr.attr-value).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-pos-player2':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("jobtitle3", ub.inv-doc-attr.attr-value).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-pos-player3':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("jobtitle4", ub.inv-doc-attr.attr-value).
    end.
    find first ub.user-account no-lock where ub.user-account.user-id = buf_trn-doc.user-name no-error .
    if available (ub.user-account) then
      write-data-element ("invclose", string(ub.user-account.last-name + " " + ub.user-account.first-name + " " + ub.user-account.second-name) ).
    else write-data-element ("invclose", "").
    sw:end-element ("atr") .
  end.
  method private void EndDocInv ():
    sw:end-element ("inv-gd-doc") .
  end.
  method private void StartDocInvFuel ():
      define buffer buf_doc-attr for ub.doc-attr .
      InitSecTag =  "inv-fuel-docs".
      sw:start-element ("inv-fuel-doc") .
        write-data-element ("doc-code", buf_trn-doc.doc-code).
        write-data-element ("doc-num", buf_trn-doc.doc-code).
        write-data-element ("del-f", string (isDel, "1/0") ).
        write-data-element ("doc-date", if buf_trn-doc.doc-date = ? then "" else iso-date (datetime (buf_trn-doc.doc-date, buf_trn-doc.real-time-create * 1000))).
        write-data-element ("fact-date", if buf_trn-doc.fact-date = ? then "" else iso-date (datetime (buf_trn-doc.fact-date, buf_trn-doc.fact-time * 1000))).
        write-data-element ("shift-date", if buf_trn-doc.shift-date = ? then "" else iso-date (date (buf_trn-doc.shift-date))).
        write-data-element ("shift-num", if buf_trn-doc.shift-num = ? then "0" else string-mth (buf_trn-doc.shift-num)).
        if can-find(first bf_rvs-doc no-lock where
             bf_rvs-doc.rvs-code = buf_trn-doc.out-code)
          then write-data-element ("check-fuel-doc", buf_trn-doc.out-code).
        find first buf_doc-attr no-lock where buf_doc-attr.doc-code = buf_trn-doc.doc-code
                                          and buf_doc-attr.attr-code = 'othermoves':U
                                          no-error .
        if available buf_doc-attr
        and logical(buf_doc-attr.attr-value)
        then do :
          write-data-element ("othermoves", "1") .
        end .
        else do :
          write-data-element ("othermoves", "0") .
        end .
    sw:start-element ("atr") .
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = "invTech" and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code no-error .
    if available (ub.inv-doc-attr) then
    do:
      if ub.inv-doc-attr.attr-value = string(true) then write-data-element ("techop", "1").
      else write-data-element ("techop", "0").
    end.
    else
    do:
      write-data-element ("techop", "0").
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-prikaz-number':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("ordernum", ub.inv-doc-attr.attr-value).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-prikaz-date':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("orderdate", iso-date (date (ub.inv-doc-attr.attr-value))).
    end.
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-inv-date':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code no-error .
    if available (ub.inv-doc-attr) then
    do:
      if ub.inv-doc-attr.attr-value <> "" then write-data-element ("invbegin", iso-date (date (ub.inv-doc-attr.attr-value))).
      else write-data-element ("invbegin", if buf_trn-doc.doc-date = ? then "" else iso-date (date (buf_trn-doc.doc-date))).
    end.
    else
    do:
      write-data-element ("invbegin", if buf_trn-doc.doc-date = ? then "" else iso-date (date (buf_trn-doc.doc-date))).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-fio-agent':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("chairmen1", ub.inv-doc-attr.attr-value).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-fio-player1':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("chairmen2", ub.inv-doc-attr.attr-value).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-fio-player2':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("chairmen3", ub.inv-doc-attr.attr-value).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-fio-player3':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("chairmen4", ub.inv-doc-attr.attr-value).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-pos-agent':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("jobtitle1", ub.inv-doc-attr.attr-value).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-pos-player1':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("jobtitle2", ub.inv-doc-attr.attr-value).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-pos-player2':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("jobtitle3", ub.inv-doc-attr.attr-value).
    end.
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = 'trdcattr-pos-player3':U and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("jobtitle4", ub.inv-doc-attr.attr-value).
    end.
    find first ub.user-account no-lock where ub.user-account.user-id = buf_trn-doc.user-name no-error .
    if available (ub.user-account) then
      write-data-element ("invclose", string(ub.user-account.last-name + " " + ub.user-account.first-name + " " + ub.user-account.second-name) ).
    else write-data-element ("invclose", "").
    sw:end-element ("atr") .
  end.
  method private void EndDocInvFuel ():
    sw:end-element ("inv-fuel-doc") .
  end.
  method private void write-data-element (inTag as char, inValue as char):
    if inValue = ?
    then do:
      Msg = substitute ('Предупреждение отладки: тег &1 иммет неопределнное значение. Работа будет продолжена...', inTag).
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
      then sw:write-empty-element (inTag).
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
    if string (inValue) begins "."
      then v-str = "0" + string (inValue).
      else v-str = string (inValue).
    return v-str.
  end.
  method private decimal fncwastage ( buffer local-doc-line for ub.doc-line,
                                        buffer local-goods for ub.goods ) :
    define buffer bf_doc-line-sum      for ub.doc-line-sum.
    define buffer bf-wst_doc-line-sum  for ub.doc-line-sum.
    if varinvclcas = yes and
       varinvclcwt = yes then do:
      find first bf_doc-line-sum no-lock where
                 bf_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf_doc-line-sum.gds-code = local-goods.gds-code and
                 bf_doc-line-sum.sum-type = 'gen':U.
      find first bf-wst_doc-line-sum no-lock where
                 bf-wst_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf-wst_doc-line-sum.gds-code = local-goods.gds-code and
                 bf-wst_doc-line-sum.sum-type = 'wst':U.
      if bf_doc-line-sum.sale-sum-base < 0 then do:
        if varr-b = "base" then do:
          if bf-wst_doc-line-sum.sale-sum-base > - bf_doc-line-sum.sale-sum-base then do:
            return - bf_doc-line-sum.sale-sum-base.
          end.
          else do:
            return bf-wst_doc-line-sum.sale-sum-base.
          end.
        end.
        else do:
          if bf-wst_doc-line-sum.sale-sum-rubl > - bf_doc-line-sum.sale-sum-rubl then do:
            return - bf_doc-line-sum.sale-sum-rubl.
          end.
          else do:
            return bf-wst_doc-line-sum.sale-sum-rubl.
          end.
        end.
      end.
      else do:
        return 0.00.
      end.
    end.
    return 0.00.
  end.
  method private decimal fncextra-qnty ( buffer local-doc-line for ub.doc-line ) :
    if local-doc-line.fact-qnty > 0 then do:
      return local-doc-line.fact-qnty.
    end.
    else do:
      return 0.00.
    end.
  end.
  method private decimal fncmiss-qnty ( buffer local-doc-line for ub.doc-line ) :
    if local-doc-line.fact-qnty < 0 then do:
      return - local-doc-line.fact-qnty.
    end.
    else do:
      return 0.00.
    end.
  end.
  method private decimal fncextra-qntykg ( buffer local-doc-line for ub.doc-line ) :
    if fncdiffqntykg( buffer buf_doc-line ) > 0 then do:
      return local-doc-line.fact-qnty.
    end.
    else do:
      return 0.00.
    end.
  end.
  method private decimal fncmiss-qntykg ( buffer local-doc-line for ub.doc-line ) :
    if fncdiffqntykg( buffer buf_doc-line ) < 0 then do:
      return - local-doc-line.fact-qnty.
    end.
    else do:
      return 0.00.
    end.
  end.
  method private decimal fncbefore-sale-rubl ( buffer local-doc-line for ub.doc-line ,
                                          buffer local-goods for ub.goods) :
    define variable varreturn as decimal no-undo.
    define buffer bf_doc-line-sum for ub.doc-line-sum.
    if varinvclcbef = yes then do:
      find first bf_doc-line-sum no-lock where
                 bf_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf_doc-line-sum.gds-code = local-goods.gds-code and
                 bf_doc-line-sum.sum-type = 'bd':U.
      assign
        varreturn = bf_doc-line-sum.sale-sum-rubl
      .
    end.
    else do:
      assign
        varreturn = 0.00
      .
    end.
    return varreturn.
  end.
  method private decimal fncafter-sale-rubl ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
    define buffer bf_doc-line-sum for ub.doc-line-sum.
    if varinvclcas = yes then do:
      find first bf_doc-line-sum no-lock where
                 bf_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf_doc-line-sum.gds-code = local-goods.gds-code and
                 bf_doc-line-sum.sum-type = 'ad':U.
      return bf_doc-line-sum.sale-sum-rubl.
    end.
    else do:
      return 0.00.
    end.
  end.
  method private decimal fncbefore-rubl ( buffer local-doc-line for ub.doc-line ,
                                          buffer local-goods for ub.goods) :
    define variable varreturn as decimal no-undo.
    define buffer bf_doc-line-sum for ub.doc-line-sum.
    if varinvclcbef = yes then do:
      find first bf_doc-line-sum no-lock where
                 bf_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf_doc-line-sum.gds-code = local-goods.gds-code and
                 bf_doc-line-sum.sum-type = 'bd':U.
      assign
        varreturn = bf_doc-line-sum.cost-sum-rubl - bf_doc-line-sum.cost-VAT-rubl
      .
    end.
    else do:
      assign
        varreturn = 0.00
      .
    end.
    return varreturn.
  end.
  method private decimal fncafter-rubl ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
    define buffer bf_doc-line-sum for ub.doc-line-sum.
    if varinvclcas = yes then do:
      find first bf_doc-line-sum no-lock where
                 bf_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf_doc-line-sum.gds-code = local-goods.gds-code and
                 bf_doc-line-sum.sum-type = 'ad':U.
      return bf_doc-line-sum.cost-sum-rubl - bf_doc-line-sum.cost-VAT-rubl.
    end.
    else do:
      return 0.00.
    end.
  end.
  method private decimal fncextra-rubl ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
    define buffer bf_doc-line-sum for ub.doc-line-sum.
    if varinvclcas = yes then do:
      find first bf_doc-line-sum no-lock where
                 bf_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf_doc-line-sum.gds-code = local-goods.gds-code and
                 bf_doc-line-sum.sum-type = 'gen':U.
      if bf_doc-line-sum.cost-sum-rubl > 0 then do:
        return bf_doc-line-sum.sale-sum-rubl.
      end.
      else do:
        return 0.00.
      end.
    end.
    else do:
      return 0.00.
    end.
  end.
  method private decimal fncmiss-rubl ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
    define buffer bf_doc-line-sum for ub.doc-line-sum.
    if varinvclcas = yes then do:
      find first bf_doc-line-sum no-lock where
                 bf_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf_doc-line-sum.gds-code = local-goods.gds-code and
                 bf_doc-line-sum.sum-type = 'gen':U.
      if bf_doc-line-sum.cost-sum-rubl < 0 then do:
        return - bf_doc-line-sum.sale-sum-rubl.
      end.
      else do:
        return 0.00.
      end.
    end.
    else do:
      return 0.00.
    end.
  end.
  method private decimal fncdiff-rubl ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
    define buffer bf_doc-line-sum for ub.doc-line-sum.
    if varinvclcas = yes then do:
      find first bf_doc-line-sum no-lock where
                 bf_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf_doc-line-sum.gds-code = local-goods.gds-code and
                 bf_doc-line-sum.sum-type = 'gen':U.
      return bf_doc-line-sum.cost-sum-rubl.
    end.
    else do:
      return 0.00.
    end.
  end.
  method private decimal fncwasqntykg ( buffer local-doc-line for ub.doc-line ) :
    define variable d_out-qnty-kg as decimal no-undo.
    inv-line_qnty( input recid( local-doc-line ), input "was",  output d_out-qnty-kg ) no-error.
    return ( if error-status :error then 0 else d_out-qnty-kg ).
  end.
  method private decimal fncareqntykg ( buffer local-doc-line for ub.doc-line ) :
    define variable d_out-qnty-kg as decimal no-undo.
    inv-line_qnty( input recid( local-doc-line ), input "are",  output d_out-qnty-kg ) no-error.
    return ( if error-status :error then 0 else d_out-qnty-kg ).
  end.
  method private decimal fncdiffqntykg ( buffer local-doc-line for ub.doc-line ) :
  define variable d_out-qnty-kg as decimal no-undo.
  inv-line_qnty( input recid( local-doc-line ), input "diff", output d_out-qnty-kg ) no-error.
    return ( if error-status :error then 0 else d_out-qnty-kg ).
  end.
  method private void inv-line_qnty ( p-doc-line-rec as recid,
                                         p-mode as character,
                                         output p-qnty-kg as decimal ) :
    define buffer buf_doc-line for ub.doc-line.
    define buffer buf_inv-line for ub.inv-line.
    do on error undo, return error return-value :
      find first buf_doc-line no-lock where
          recid( buf_doc-line ) = p-doc-line-rec no-error.
      if not available buf_doc-line then do:
        assign
          p-qnty-kg = 0.0
        .
        return.
      end.
      find first buf_inv-line no-lock where
                 buf_inv-line.doc-code  = buf_doc-line.doc-code  and
                 buf_inv-line.artic     = buf_doc-line.artic     and
                 buf_inv-line.prod-type = buf_doc-line.prod-type and
                 buf_inv-line.prod-code = buf_doc-line.prod-code no-error.
      if not available buf_inv-line then do:
        assign
          p-qnty-kg = 0.0
        .
        return.
      end.
      case p-mode :
        when "was"  then do:
          assign
            p-qnty-kg = buf_inv-line.before-cli-qnty
          .
        end.
        when "are"  then do:
          assign
            p-qnty-kg = buf_inv-line.wast-cli-qnty
          .
        end.
        when "diff" then do:
          assign
            p-qnty-kg = buf_doc-line.cli-qnty
          .
        end.
      end case.
    end.
  end.
end class.
