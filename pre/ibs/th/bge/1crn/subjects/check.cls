using Progress.Lang.*.
using ibs.th.bge.1crn.enum-chk-type.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.check implements iexpsubject:
define public var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define private temp-table tt-rep no-undo
   field obj-type          as character
   field obj-code          as integer
   field obj-name          as character
   field chk-date          as date
   field chk-time          as integer
   field sort-date         as date
   field sort-time         as integer
   field shift-date        as date
   field shift-name        as character
   field doc-code          as character
   field chk-num           as integer
   field line-num          as integer
   field doc-num2          as character
   field z-number          as integer
   field tran-num          as integer
   field chk-type-desc     as character
   field pay-desk          as character
   field cash-num          as integer
   field cashier           as character
   field trk-num           as integer
   field nozzle-num        as integer
   field fuel-code         as integer
   field gds-name          as character
   field volume            as decimal
   field price             as decimal
   field money             as decimal
   field cash-pay-code     as integer
   field cash-pay-name     as character
   field pay-card          as character
   field datetime-beg      as datetime
   field date-beg          as date
   field time-beg          as integer
   field datetime-end      as datetime
   field date-end          as date
   field time-end          as integer
   field time-length       as integer
   field all-time-length   as integer
   field all-time-length-2 as integer
   field multi-pay         as logical
   field resume-tran       as logical
   field uuid              as character
   field uuid-cheq         as character
   field grp-num           as integer
   field db-num            as integer
index pi obj-code shift-date shift-name sort-date sort-time pay-desk fuel-code trk-num nozzle-num
index si1 obj-code grp-num datetime-beg
index CashPayNname cash-pay-name
index GrpNum grp-num
index ChkTypeDesc chk-type-desc
index iuuid db-num uuid-cheq uuid
index UuidCheq db-num uuid uuid-cheq
index UuidCHKType db-num uuid chk-type-desc
index DateTimeBeg datetime-beg
index AllTimeLength2 all-time-length-2
index sort obj-code sort-date sort-time
.
define private temp-table tt-all-total-rep no-undo
   field obj-type           as character
   field obj-code           as integer
   field qty-chk            as integer
   field qty-tran           as integer
   field qty-chk-fuel       as integer
   field full-time-tran     as integer
   field avg-time-tran      as integer
   field avg-time-tran-fuel as integer
index obj obj-type obj-code
.
define private temp-table tt-total-rep no-undo like tt-all-total-rep
   field obj-name           as character
index ObjName obj-type obj-code obj-name
.
define private temp-table tt-grp no-undo
   field obj-type           as character
   field obj-code           as integer
   field obj-name           as character
   field grp-num            as integer
   field all-time-length    as integer
   field all-time-length-2  as integer
   field cash-pay-code      as integer
   field cash-pay-name      as character
   field resume-tran        as logical
index ObjName obj-type obj-code obj-name
index ResumeTran  resume-tran
index GrpNum grp-num
.
define private temp-table tt-grp-uuid no-undo
   field grp-num            as integer
   field uuid               as character
 index uid uuid grp-num.
.
define private temp-table tt-grp-cheq-uuid no-undo
   field grp-num            as integer
   field uuid               as character
 index uid uuid grp-num.
.
define private temp-table tt-pay no-undo
   field seq             as integer
   field volume          as decimal
   field money           as decimal
   field cash-pay-code   as integer
   field cash-pay-name   as character
   field pay-card        as character
   field multi-pay       as logical
  index pi seq
  .
method private void CreateOneRec
      (buffer chk-doc   for chk-doc,
       buffer tran-fuel for tran-fuel,
       buffer chk-gds   for chk-gds,
       buffer goods     for goods):
   define buffer cash-pay    for cash-pay.
   define buffer b-chk-gds   for chk-gds.
   define buffer b-tran-fuel for tran-fuel.
   define variable v-chk-type-desc as character no-undo.
   define variable v-cash-pay-code as integer   no-undo.
   define variable v-cash-pay-name as character no-undo.
   define variable v-pay-card      as character no-undo.
   define variable v-psn-code      as integer   no-undo.
   define variable v-db-num        as integer   no-undo.
   define variable vDateBeg        as datetime  no-undo.
   define variable vDateEnd        as datetime  no-undo.
   define variable vSeq            as integer   no-undo.
   define variable vMoney          as decimal   no-undo.
   define variable vVolume         as decimal   no-undo.
   define variable vTotSum         as decimal   no-undo.
   do:
      vVolume = if can-do("6,14,16", string(chk-doc.chk-type)) then chk-gds.doc-qnty else tran-fuel.volume.
      empty temp-table tt-pay.
      v-chk-type-desc = entry(lookup(string(chk-doc.chk-type), "1,6,8,11,12,13,40,69,96,14,15,16,17,36,101,106,108,111,112,113,169,196,114,115,116,117,136,201,206,208,301,306,2,3,4,5,7,43,44"), "Продажа,Возврат,Аннуляция,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,ТехПролив,РазблТрнзкц,_Продажа,_Возврат,_Аннуляция,_Инвентаризация,_Z-отчет,_Закрытие_смены,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_РазблТрнзкц,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр").
      for each chk-pay where
               chk-pay.doc-code = chk-gds.doc-code
      no-lock
      break
         by chk-pay.doc-code
         by chk-pay.tot-sum:
         if first-of(chk-pay.doc-code) and last-of(chk-pay.doc-code) then
            leave.
         vSeq = vSeq + 1.
         v-pay-card = if chk-pay.pay-card = "0" then "" else chk-pay.pay-card.
         find first cash-pay where
                    cash-pay.cdpay-code = chk-pay.pay-code
         no-lock no-error.
         if avail cash-pay then
            assign
               v-cash-pay-code = chk-pay.pay-code
               v-cash-pay-name = cash-pay.obj-name
               .
         else
            assign
               v-cash-pay-code = 0
               v-cash-pay-name = ""
               .
         vTotSum = chk-pay.tot-sum - (if last-of(chk-pay.doc-code) then
                                         (chk-doc.tot-doc - chk-gds.sum-base)
                                      else 0).
         create tt-pay.
         assign
            tt-pay.seq           = vSeq
            tt-pay.volume        = round(vVolume * vTotSum / chk-gds.sum-base, 2)
            tt-pay.money         = vTotSum
            tt-pay.cash-pay-code = v-cash-pay-code
            tt-pay.cash-pay-name = v-cash-pay-name
            tt-pay.pay-card      = v-pay-card
            tt-pay.multi-pay     = yes
            .
            if tt-pay.volume = ? then
               tt-pay.volume = 0.0.
      end.
      find first tt-pay no-error.
      if not avail tt-pay then do:
         find first chk-pay where
                    chk-pay.doc-code = chk-gds.doc-code
         no-lock no-error.
         if avail chk-pay then
            assign
               v-pay-card      = if chk-pay.pay-card = "0" then "" else chk-pay.pay-card
               vMoney          = chk-gds.sum-base
               v-cash-pay-code = chk-pay.pay-code
               .
         else
            assign
               v-pay-card       = ""
               vMoney           = tran-fuel.money
               v-cash-pay-code  = (if chk-doc.chk-type = 8 then 0 else tran-fuel.pay-code)
               .
         find first cash-pay where
                    cash-pay.cdpay-code = v-cash-pay-code
         no-lock no-error.
         v-cash-pay-name = if avail cash-pay then cash-pay.obj-name else "".
         create tt-pay.
         assign
            tt-pay.seq           = 1
            tt-pay.volume        = vVolume
            tt-pay.money         = if chk-doc.chk-type = 1 then vVolume * tran-fuel.price else vMoney
            tt-pay.cash-pay-code = v-cash-pay-code
            tt-pay.cash-pay-name = v-cash-pay-name
            tt-pay.pay-card      = v-pay-card
            .
      end.
      find first b-tran-fuel where
                 b-tran-fuel.db-num    = tran-fuel.db-num
             and b-tran-fuel.uuid      = tran-fuel.uuid
             and b-tran-fuel.uuid-cheq = ""
      no-lock no-error.
      if avail b-tran-fuel and b-tran-fuel.date-beg < tran-fuel.date-beg then
         vDateBeg = b-tran-fuel.date-beg.
      else
         vDateBeg = tran-fuel.date-beg.
      assign
         vDateBeg = vDateBeg           + timezone * 60000
         vDateEnd = tran-fuel.date-end + timezone * 60000.
         .
      for each tt-pay:
         create tt-rep.
         assign
            tt-rep.chk-date        = chk-doc.chk-date
            tt-rep.chk-time        = chk-doc.chk-time
            tt-rep.sort-date       = chk-doc.chk-date
            tt-rep.sort-time       = chk-doc.chk-time
            tt-rep.shift-date      = chk-doc.shift-date
            tt-rep.shift-name      = chk-doc.shift-name + "(" + string(chk-doc.shift-num) + ")"
            tt-rep.doc-code        = chk-doc.doc-code
            tt-rep.chk-num         = chk-doc.chk-num
            tt-rep.line-num        = chk-gds.line-num
            tt-rep.doc-num2        = (if num-entries(chk-doc.doc-num2, ":") > 1 then entry(1, chk-doc.doc-num2, ":") else "")
            tt-rep.z-number        = chk-doc.z-number
            tt-rep.tran-num        = tran-fuel.tran-num
            tt-rep.chk-type-desc   = v-chk-type-desc
            tt-rep.cash-num        = tran-fuel.cash-num
            tt-rep.trk-num         = tran-fuel.trk-num + 1
            tt-rep.nozzle-num      = tran-fuel.nozzle-num + 1
            tt-rep.fuel-code       = chk-gds.b-code
            tt-rep.gds-name        = goods.gds-name
            tt-rep.volume          = tt-pay.volume
            tt-rep.price           = tran-fuel.price
            tt-rep.money           = if tt-pay.multi-pay then tt-pay.money else tt-pay.volume * tran-fuel.price
            tt-rep.cash-pay-code   = tt-pay.cash-pay-code
            tt-rep.cash-pay-name   = tt-pay.cash-pay-name
            tt-rep.pay-card        = tt-pay.pay-card
            tt-rep.datetime-beg    = vDateBeg
            tt-rep.date-beg        = date(vDateBeg)
            tt-rep.time-beg        = mtime(vDateBeg) / 1000
            tt-rep.datetime-end    = vDateEnd
            tt-rep.date-end        = date(vDateEnd)
            tt-rep.time-end        = mtime(vDateEnd) / 1000
            tt-rep.time-length     = (vDateEnd - vDateBeg) / 1000
            tt-rep.all-time-length = tt-rep.time-length
            tt-rep.multi-pay       = tt-pay.multi-pay
            tt-rep.resume-tran     = no
            tt-rep.uuid            = tran-fuel.uuid
            tt-rep.uuid-cheq       = tran-fuel.uuid-cheq
            tt-rep.db-num          = tran-fuel.db-num
            .
         if chk-doc.chk-type = 16 and chk-gds.src-qnty <= 0 then do:
            find first b-chk-gds where
                       b-chk-gds.doc-code = chk-gds.doc-code
                   and b-chk-gds.b-code   = chk-gds.b-code
                   and b-chk-gds.line-num > chk-gds.line-num
            no-lock no-error.
            if avail b-chk-gds then
               assign
                  tt-rep.volume     = b-chk-gds.doc-qnty
                  .
         end.
      end.
   end.
end.
method private void InitTT
         (i-tog-shift       as logical,
          i-date-start      as date,
          i-date-end        as date,
          i-Shift-Start     as integer,
          i-Shift-End       as integer,
          iChkTypeCodeList  as character,
          iGdsCodeList      as character,
          iTRKList          as character):
   define buffer chk-doc      for chk-doc.
   define buffer chk-doc-attr for chk-doc-attr.
   define buffer chk-gds      for chk-gds.
   define buffer goods        for goods.
   define buffer cash-pay     for cash-pay.
   define buffer prod-bc      for prod-bc.
   define buffer b-tran-fuel  for tran-fuel.
   define variable v-gds-code as integer  no-undo.
   define variable vDateBeg   as datetime no-undo.
   define variable vDateEnd   as datetime no-undo.
   define variable vCount     as integer  no-undo.
   if i-tog-shift then do:
      for
          each chk-doc where
               chk-doc.shift-date >= i-date-start
           and chk-doc.shift-date <= i-date-end
           and can-do(iChkTypeCodeList, string(chk-doc.chk-type))
      no-lock,
         first chk-doc-attr where
               chk-doc-attr.doc-code  = chk-doc.doc-code
           and chk-doc-attr.attr-code = "CheckId"
      no-lock,
         each tran-fuel where
              tran-fuel.uuid-cheq = chk-doc-attr.attr-value
          and can-do(iTRKList, string(tran-fuel.trk-num + 1))
      no-lock:
         v-gds-code = tran-fuel.fuel-code.
         if v-gds-code < 100 then do:
            find first prod-bc where
                       prod-bc.b-str = string(v-gds-code)
            no-lock no-error.
            if avail prod-bc then do:
               find first chk-gds where
                          chk-gds.doc-code = chk-doc.doc-code
                      and chk-gds.b-code   = prod-bc.b-code
               no-lock no-error.
               find first goods where
                          goods.gds-code = prod-bc.b-code
               no-lock no-error.
               if not avail chk-gds or not avail goods
               then
                  next.
               v-gds-code = goods.gds-code.
            end.
            else next.
         end.
         else do:
            find first chk-gds where
                       chk-gds.doc-code = chk-doc.doc-code
                   and chk-gds.b-code   = v-gds-code
            no-lock no-error.
            find first goods where
                       goods.gds-code = v-gds-code
            no-lock no-error.
            if not avail chk-gds or not avail goods
            then
               next.
         end.
         if not can-do(iGdsCodeList, string(v-gds-code)) then next.
         if (chk-doc.shift-date = i-date-start and chk-doc.shift-num < i-Shift-Start) or
            (chk-doc.shift-date = i-date-end   and chk-doc.shift-num > i-Shift-End)
         then
            next.
         CreateOneRec(buffer chk-doc,
                      buffer tran-fuel,
                      buffer chk-gds,
                      buffer goods
                      ).
      end.
   end.
   else do:
     TRAN-FUEL:
     for each tran-fuel where
              tran-fuel.date-beg >= datetime(string(i-date-start) + " 00:00:00") - timezone * 60000
          and tran-fuel.date-beg <= datetime(string(i-date-end + 2) + " 23:59:59") - timezone * 60000
          and can-do(iTRKList, string(tran-fuel.trk-num + 1))
     no-lock:
       release chk-doc-attr.
       if tran-fuel.num-cheq > 0 then do:
for first chk-doc-attr where
          chk-doc-attr.attr-code  = "CheckId"
      and chk-doc-attr.attr-value = tran-fuel.uuid-cheq
no-lock,
    first chk-doc where
          chk-doc.doc-code = chk-doc-attr.doc-code
      and can-do(iChkTypeCodeList, string(chk-doc.chk-type))
no-lock
:
  v-gds-code = tran-fuel.fuel-code.
  if v-gds-code < 100 then do:
    find first prod-bc where
               prod-bc.b-str = string(v-gds-code)
    no-lock no-error.
    if avail prod-bc then do:
       find first chk-gds where
                  chk-gds.doc-code = chk-doc.doc-code
              and chk-gds.b-code   = prod-bc.b-code
       no-lock no-error.
       find first goods where
                  goods.gds-code = prod-bc.b-code
       no-lock no-error.
       if not avail chk-gds or not avail goods
       then
          next TRAN-FUEL.
       v-gds-code = goods.gds-code.
    end.
    else next TRAN-FUEL.
  end.
  else do:
     find first chk-gds where
                chk-gds.doc-code = chk-doc.doc-code
            and chk-gds.b-code   = v-gds-code
     no-lock no-error.
     find first goods where
                goods.gds-code = v-gds-code
     no-lock no-error.
     if not avail chk-gds or not avail goods
     then
        next TRAN-FUEL.
  end.
  if not can-do(iGdsCodeList, string(v-gds-code)) then next TRAN-FUEL.
    CreateOneRec(buffer chk-doc,
                 buffer tran-fuel,
                 buffer chk-gds,
                 buffer goods
                 ).
end.
       end.
       if not available chk-doc-attr then do:
       end.
     end.
   end.
   release tt-rep.
end.
method private void AfterCalc(i-tog-shift  as logical,
                              i-date-end   as date,
                              iTRKList     as character,
                              iCashPayList as character,
                              iTranTimeMax as integer):
   define buffer b-chk-gds    for chk-gds.
   define buffer b-tt-rep     for tt-rep.
   define buffer b2-tt-rep    for tt-rep.
   define variable vI                   as integer   no-undo.
   define variable vCheck               as logical   no-undo.
   define variable vCheckResumeTran     as logical   no-undo.
   define variable v-all-time-length    as integer   no-undo.
   define variable v-count-grp-num      as integer   no-undo.
   define variable v-prev-datetime-end  as datetime  no-undo.
   define variable v-first-datetime-beg as datetime  no-undo.
   define variable vResumeTran          as logical   no-undo.
   define variable vUuidCheq            as character no-undo.
   define variable vFirstRecId          as recid     no-undo.
   define variable vConfirmResumeTran   as logical   no-undo.
   define variable vRecId               as recid     no-undo.
   define variable vRowId               as rowid     no-undo.
   define variable vRowIdList           as character no-undo.
   define variable v-gds-code           as integer   no-undo.
   define variable vTrkNum              as integer   no-undo.
   for each  tt-grp:
      delete tt-grp.
   end.
   for each  tt-grp-uuid:
      delete tt-grp-uuid.
   end.
   for each  tt-grp-cheq-uuid:
      delete tt-grp-cheq-uuid.
   end.
   for each tt-rep where
            not can-do(iTRKList, string(tt-rep.trk-num)):
      delete tt-rep.
   end.
   for each tt-rep where
            tt-rep.cash-pay-name = "":
      find first tran-fuel where
                 tran-fuel.db-num   = tt-rep.db-num
             and tran-fuel.tran-num = tt-rep.tran-num
             and tran-fuel.num-cheq = integer(tt-rep.doc-num2)
      no-lock no-error.
      if avail tran-fuel then do:
         for first chk-doc-attr where
                   chk-doc-attr.attr-code  = "CheckId"
               and chk-doc-attr.attr-value = tran-fuel.uuid-cheq
         no-lock,
             first chk-doc where
                   chk-doc.doc-code = chk-doc-attr.doc-code
         no-lock
               :
            v-gds-code = tran-fuel.fuel-code.
            if v-gds-code < 100 then do:
               find first prod-bc where
                          prod-bc.b-str = string(tran-fuel.fuel-code)
               no-lock no-error.
               if avail prod-bc then do:
                  find first chk-gds where
                             chk-gds.doc-code = chk-doc.doc-code
                         and chk-gds.b-code   = prod-bc.b-code
                  no-lock no-error.
                  find first goods where
                             goods.gds-code = prod-bc.b-code
                  no-lock no-error.
                  if not avail chk-gds or not avail goods
                  then
                     next.
                  v-gds-code = goods.gds-code.
               end.
            end.
            else do:
               find first chk-gds where
                          chk-gds.doc-code = chk-doc.doc-code
                      and chk-gds.b-code   = v-gds-code
               no-lock no-error.
               find first goods where
                          goods.gds-code = v-gds-code
               no-lock no-error.
               if not avail chk-gds or not avail goods
               then
                  next.
            end.
            find first chk-pay where
                       chk-pay.doc-code = chk-gds.doc-code
            no-lock no-error.
            if avail chk-pay then do:
               find first cash-pay where
                          cash-pay.cdpay-code = chk-pay.pay-code
               no-lock no-error.
               if avail cash-pay then
                  assign
                     tt-rep.cash-pay-code = chk-pay.pay-code
                     tt-rep.cash-pay-name = cash-pay.obj-name.
            end.
         end.
      end.
   end.
   v-count-grp-num = 0.
   for each tt-rep
      by tt-rep.obj-code
      by tt-rep.sort-date
      by tt-rep.sort-time:
      block-grp-uuid:
      for each tt-grp-uuid where  tt-grp-uuid.uuid     = tt-rep.uuid
      no-lock:
         for each tt-grp where
                    tt-grp.obj-type = tt-rep.obj-type
                and tt-grp.obj-code = tt-rep.obj-code
                and tt-grp.obj-name = tt-rep.obj-name
                and tt-grp.grp-num  = tt-grp-uuid.grp-num
                :
                find first tt-grp-cheq-uuid where tt-grp-cheq-uuid.grp-num = tt-grp.grp-num
                                              and tt-grp-cheq-uuid.uuid     = tt-rep.uuid-cheq
                no-error.
                leave block-grp-uuid.
             end.
      end.
      if not available tt-grp
      then do:
         block-grp-cheq:
         for each tt-grp-cheq-uuid where  tt-grp-cheq-uuid.uuid     = tt-rep.uuid-cheq
         no-lock:
            for each tt-grp where
                       tt-grp.obj-type = tt-rep.obj-type
                   and tt-grp.obj-code = tt-rep.obj-code
                   and tt-grp.obj-name = tt-rep.obj-name
                   and tt-grp.grp-num  = tt-grp-cheq-uuid.grp-num
                   :
                   find first tt-grp-uuid where tt-grp-uuid.grp-num = tt-grp.grp-num
                                            and tt-grp-uuid.uuid     = tt-rep.uuid
                   no-error.
                   leave block-grp-cheq.
            end.
         end.
      end.
      if     not avail tt-grp
      then do:
         v-count-grp-num = v-count-grp-num + 1.
         create tt-grp.
         assign
            tt-grp.obj-type = tt-rep.obj-type
            tt-grp.obj-code = tt-rep.obj-code
            tt-grp.obj-name = tt-rep.obj-name
            tt-grp.grp-num  = v-count-grp-num
            .
      end.
      if not available tt-grp-cheq-uuid
      then do:
         create tt-grp-cheq-uuid.
         assign
            tt-grp-cheq-uuid.grp-num  = tt-grp.grp-num
            tt-grp-cheq-uuid.uuid     = tt-rep.uuid-cheq
         .
      end.
      if not available tt-grp-uuid
      then do:
         create tt-grp-uuid.
         assign
            tt-grp-uuid.grp-num = tt-grp.grp-num
            tt-grp-uuid.uuid     = tt-rep.uuid
         .
      end.
      tt-rep.grp-num = tt-grp.grp-num.
      if tt-grp.cash-pay-name = "" then
         assign
            tt-grp.cash-pay-code = tt-rep.cash-pay-code
            tt-grp.cash-pay-name = tt-rep.cash-pay-name
            .
      release tt-grp.
   end.
   for each tt-rep
   break
      by tt-rep.obj-code
      by tt-rep.grp-num
      by tt-rep.sort-date
      by tt-rep.sort-time
      by tt-rep.datetime-beg:
      if first-of(tt-rep.grp-num) then do:
         assign
            vUuidCheq          = ""
            vResumeTran        = no
            vConfirmResumeTran = no
            .
         if tt-rep.chk-type-desc = "Продажа" then
            assign
               vUuidCheq   = tt-rep.uuid-cheq
               vResumeTran = yes
               vTrkNum     = tt-rep.trk-num
               .
         find first b-tt-rep where recid(b-tt-rep) = vFirstRecId no-error.
      end.
      else do:
         if tt-rep.chk-type-desc = "Продажа" and
            tt-rep.uuid-cheq     = vUuidCheq and
            tt-rep.multi-pay     = no        and
            vResumeTran          = yes
         then
            assign
               tt-rep.resume-tran = yes
               vConfirmResumeTran = yes
               .
         else
            if tt-rep.chk-type-desc = "Продажа" and
               tt-rep.uuid-cheq     = vUuidCheq and
               tt-rep.multi-pay     = no
            then
               assign
                  vResumeTran = yes
                  vTrkNum     = tt-rep.trk-num
               .
            else
               vResumeTran = no.
         for first b-tt-rep where
                   b-tt-rep.db-num   = tt-rep.db-num
               and b-tt-rep.uuid     = tt-rep.uuid
               and b-tt-rep.chk-num = 0:
           assign
             tt-rep.resume-tran = yes
             vConfirmResumeTran = yes
           .
           for first tt-grp-uuid where
                     tt-grp-uuid.uuid = b-tt-rep.uuid:
              delete tt-grp-uuid.
           end.
           delete b-tt-rep.
         end.
      end.
      if last-of(tt-rep.grp-num) and not first-of(tt-rep.grp-num) and vConfirmResumeTran then do:
         for first tt-grp where tt-grp.grp-num = tt-rep.grp-num:
            tt-grp.resume-tran = yes.
         end.
      end.
   end.
   for each tt-grp where
            tt-grp.resume-tran = yes:
      for each tt-rep where
               tt-rep.grp-num = tt-grp.grp-num
      break
         by tt-rep.obj-code
         by tt-rep.grp-num
         by tt-rep.datetime-beg
         by tt-rep.sort-date
         by tt-rep.sort-time:
         if not first-of(tt-rep.grp-num) and tt-rep.chk-type-desc = "Продажа" then do:
            find first b-tt-rep where
                       recid(b-tt-rep)        = vRecId
                   and b-tt-rep.chk-type-desc = "Продажа"
            no-error.
            if avail b-tt-rep then do:
               assign
                  b-tt-rep.datetime-end    = tt-rep.datetime-beg
                  b-tt-rep.date-end        = tt-rep.date-beg
                  b-tt-rep.time-end        = tt-rep.time-beg
                  b-tt-rep.time-length     = (b-tt-rep.datetime-end - b-tt-rep.datetime-beg) / 1000
                  .
            end.
         end.
         vRecId = recid(tt-rep).
      end.
   end.
   repeat preselect each tt-rep where
                         tt-rep.chk-type-desc = "ПеревТрнзкц":
      find next tt-rep.
      find first b-chk-gds where
                 b-chk-gds.doc-code =  tt-rep.doc-code
             and b-chk-gds.line-num <> chk-gds.line-num
      no-lock no-error.
      if avail b-chk-gds then do:
         find first b-tt-rep where
                    b-tt-rep.db-num    =  tt-rep.db-num
                and b-tt-rep.uuid      =  tt-rep.uuid
                and b-tt-rep.uuid-cheq <> tt-rep.uuid-cheq
         no-error.
         if avail b-tt-rep then do:
            find first b2-tt-rep where
                       b2-tt-rep.db-num    =  B-tt-rep.db-num
                   and b2-tt-rep.uuid-cheq =  b-tt-rep.uuid-cheq
                   and b2-tt-rep.uuid      <> b-tt-rep.uuid
            no-lock no-error.
            if avail b2-tt-rep then do:
               create b-tt-rep.
               buffer-copy b2-tt-rep to b-tt-rep
                  assign
                     b-tt-rep.chk-date        = tt-rep.chk-date
                     b-tt-rep.chk-time        = tt-rep.chk-time
                     b-tt-rep.sort-date       = tt-rep.sort-date
                     b-tt-rep.sort-time       = tt-rep.sort-time
                     b-tt-rep.doc-code        = tt-rep.doc-code
                     b-tt-rep.chk-num         = tt-rep.chk-num
                     b-tt-rep.line-num        = b-chk-gds.line-num
                     b-tt-rep.doc-num2        = tt-rep.doc-num2
                     b-tt-rep.z-number        = tt-rep.z-number
                     b-tt-rep.chk-type-desc   = tt-rep.chk-type-desc
                     b-tt-rep.resume-tran     = no
                     b-tt-rep.uuid-cheq       = tt-rep.uuid-cheq
                     .
            end.
         end.
      end.
   end.
   for each tt-grp:
      for each tt-rep where
               tt-rep.grp-num = tt-grp.grp-num
      break
         by tt-rep.obj-code
         by tt-rep.grp-num
         by tt-rep.datetime-beg
         by tt-rep.sort-date
         by tt-rep.sort-time:
         if not first-of(tt-rep.grp-num) and tt-rep.chk-type-desc = "ПеревТрнзкц" then do:
            find first b-tt-rep where
                       recid(b-tt-rep)        = vRecId
                   and b-tt-rep.chk-type-desc = "Продажа"
            no-error.
            if avail b-tt-rep then do:
               assign
                  b-tt-rep.datetime-end    = tt-rep.datetime-end
                  b-tt-rep.date-end        = tt-rep.date-end
                  b-tt-rep.time-end        = tt-rep.time-end
                  b-tt-rep.time-length     = (b-tt-rep.datetime-end - b-tt-rep.datetime-beg) / 1000
                  .
            end.
         end.
         vRecId = recid(tt-rep).
      end.
   end.
   for each tt-rep where
            tt-rep.chk-type-desc = "Возврат":
      find last b-tt-rep where
                b-tt-rep.DB-NUM        = tt-rep.db-num
            and b-tt-rep.uuid          = tt-rep.uuid
            and b-tt-rep.chk-type-desc = "Продажа"
      no-error.
      if avail b-tt-rep then do:
         assign
            tt-rep.datetime-beg = b-tt-rep.datetime-beg
            tt-rep.date-beg     = b-tt-rep.date-beg
            tt-rep.time-beg     = b-tt-rep.time-beg
            tt-rep.time-length  = (tt-rep.datetime-end - tt-rep.datetime-beg) / 1000
            .
      end.
   end.
   for each tt-rep where
            tt-rep.chk-type-desc = "СбросТрнзкц":
      find last b-tt-rep where
                b-tt-rep.DB-NUM        = tt-rep.db-num
            and b-tt-rep.uuid          = tt-rep.uuid
            and b-tt-rep.chk-type-desc = "Продажа"
      no-error.
      if avail b-tt-rep then do:
         assign
            tt-rep.datetime-beg = b-tt-rep.datetime-beg
            tt-rep.date-beg     = b-tt-rep.date-beg
            tt-rep.time-beg     = b-tt-rep.time-beg
            tt-rep.time-length  = (tt-rep.datetime-end - tt-rep.datetime-beg) / 1000
            .
      end.
   end.
   for each tt-rep where
            tt-rep.chk-type-desc = "ПеревТрнзкц":
      find first b-tt-rep where
                 b-tt-rep.DB-NUM        = tt-rep.db-num
             and b-tt-rep.uuid          = tt-rep.uuid
             and b-tt-rep.chk-type-desc = "Продажа"
      no-error.
      if avail b-tt-rep then do:
         assign
            tt-rep.datetime-beg = b-tt-rep.datetime-beg
            tt-rep.date-beg     = b-tt-rep.date-beg
            tt-rep.time-beg     = b-tt-rep.time-beg
            tt-rep.time-length  = (tt-rep.datetime-end - tt-rep.datetime-beg) / 1000
            .
      end.
   end.
   for each tt-rep where
            tt-rep.chk-type-desc = "ТехПролив":
      find first tran-fuel where
                 tran-fuel.db-num    =  tt-rep.db-num
             and tran-fuel.uuid      =  tt-rep.uuid
             and tran-fuel.uuid-cheq <> tt-rep.uuid-cheq
      no-lock no-error.
      if avail tran-fuel then do:
         assign
            tt-rep.datetime-beg = tran-fuel.date-beg + timezone * 60000
            tt-rep.date-beg     = date(tt-rep.datetime-beg)
            tt-rep.time-beg     = mtime(tt-rep.datetime-beg) / 1000
            tt-rep.time-length  = (tt-rep.datetime-end - tt-rep.datetime-beg) / 1000
            .
      end.
   end.
   for each tt-rep
   break
      by tt-rep.obj-code
      by tt-rep.grp-num
      by tt-rep.datetime-beg
      by tt-rep.sort-date
      by tt-rep.sort-time:
      if first-of(tt-rep.grp-num) then do:
         vRowId = ?.
      end.
      if can-do("Возврат,СбросТрнзкц", tt-rep.chk-type-desc) and vRowId <> ? then do:
         for first b-tt-rep where rowid(b-tt-rep) = vRowId:
            assign
               b-tt-rep.datetime-end    = tt-rep.datetime-end
               b-tt-rep.date-end        = tt-rep.date-end
               b-tt-rep.time-end        = tt-rep.time-end
               b-tt-rep.time-length     = (b-tt-rep.datetime-end - b-tt-rep.datetime-beg) / 1000
               .
         end.
      end.
      vRowId = rowid(tt-rep).
   end.
   for each tt-rep
   break
      by tt-rep.obj-code
      by tt-rep.grp-num
      by tt-rep.datetime-beg
      by tt-rep.sort-date
      by tt-rep.sort-time:
      if first-of(tt-rep.grp-num) then do:
         vRowIdList = "".
      end.
      if tt-rep.chk-type-desc = "Аннуляция" then
         vRowIdList = vRowIdList + (if vRowIdList > "" then "," else "") + string(rowid(tt-rep)).
      else if tt-rep.chk-type-desc = "Продажа" then do:
         do vI = 1 to num-entries(vRowIdList):
            vRowId = to-rowid(entry(vI, vRowIdList)).
            for first b-tt-rep where rowid(b-tt-rep) = vRowId:
               assign
                  b-tt-rep.datetime-end    = tt-rep.datetime-end
                  b-tt-rep.date-end        = tt-rep.date-end
                  b-tt-rep.time-end        = tt-rep.time-end
                  b-tt-rep.time-length     = (b-tt-rep.datetime-end - b-tt-rep.datetime-beg) / 1000
                  .
            end.
         end.
         vRowIdList = "".
      end.
   end.
   for each tt-rep
   break
      by tt-rep.obj-code
      by tt-rep.grp-num
      by tt-rep.sort-date
      by tt-rep.sort-time
      by tt-rep.datetime-beg:
      if first-of(tt-rep.grp-num) then do:
         vI = 0.
         find first b-tt-rep where
                    rowid(b-tt-rep) = rowid(tt-rep).
      end.
      vI = vI + 1.
      if last-of(tt-rep.grp-num) and vI = 2 then do:
         if b-tt-rep.chk-type-desc  = "Продажа"           and
            b-tt-rep.uuid           = tt-rep.uuid         and
            tt-rep.uuid-cheq        begins "empty-"       and
            b-tt-rep.trk-num        = tt-rep.trk-num      and
            b-tt-rep.nozzle-num     = tt-rep.nozzle-num   and
            b-tt-rep.fuel-code      = tt-rep.fuel-code    and
            b-tt-rep.volume         = tt-rep.volume       and
            b-tt-rep.datetime-beg  <= tt-rep.datetime-beg
         then
            tt-rep.chk-type-desc = "Перелив".
      end.
   end.
   for each tt-rep where
            not can-do(iCashPayList, string(tt-rep.cash-pay-code)):
      delete tt-rep.
   end.
   if i-tog-shift = no then do:
      for each tt-rep where
               tt-rep.datetime-beg > datetime(string(i-date-end) + " 23:59:59"):
         delete tt-rep.
      end.
   end.
   for each tt-rep
   break
      by tt-rep.obj-code
      by tt-rep.grp-num
      by tt-rep.datetime-beg
      by tt-rep.sort-date
      by tt-rep.sort-time:
      if first-of(tt-rep.grp-num) then do:
         assign
            v-all-time-length    = 0
            v-prev-datetime-end  = datetime("01/01/1990 00:00:00")
            v-first-datetime-beg = tt-rep.datetime-beg
            .
      end.
      if tt-rep.datetime-end > v-prev-datetime-end then
         v-all-time-length = v-all-time-length + (tt-rep.datetime-end - max(tt-rep.datetime-beg, v-prev-datetime-end)) / 1000.
      v-prev-datetime-end = max(tt-rep.datetime-end, v-prev-datetime-end).
      if last-of(tt-rep.grp-num) then do:
         find first tt-grp where
                    tt-grp.grp-num = tt-rep.grp-num
         no-error.
         if avail tt-grp then
            assign
               tt-grp.all-time-length   = v-all-time-length
               tt-grp.all-time-length-2 = (tt-rep.datetime-end - v-first-datetime-beg) / 1000
               .
      end.
   end.
   for each tt-rep:
      find first tt-grp where
                 tt-grp.grp-num = tt-rep.grp-num
      no-error.
      if avail tt-grp then do:
         assign
            tt-rep.all-time-length   = tt-grp.all-time-length
            tt-rep.all-time-length-2 = tt-grp.all-time-length-2
            .
      end.
   end.
   for each tt-rep where
            tt-rep.all-time-length-2 < iTranTimeMax * 60:
      delete tt-rep.
   end.
   for each tt-grp-uuid:
      delete tt-grp-uuid.
   end.
   for each tt-rep
   break
      by tt-rep.obj-type
      by tt-rep.obj-code
      by tt-rep.sort-date
      by tt-rep.sort-time
      by tt-rep.uuid-cheq
      by tt-rep.datetime-beg:
      if first-of(tt-rep.obj-code) then do:
         create tt-total-rep.
         assign
            tt-total-rep.obj-type = tt-rep.obj-type
            tt-total-rep.obj-code = tt-rep.obj-code
            tt-total-rep.obj-name = tt-rep.obj-name
            .
      end.
      if first-of(tt-rep.uuid-cheq) then do:
         vCheck = no.
         tt-total-rep.qty-chk = tt-total-rep.qty-chk + 1.
      end.
      find first tt-grp-uuid where tt-grp-uuid.grp-num = 0
                               and tt-grp-uuid.uuid     = tt-rep.uuid
      no-error.
      if not available tt-grp-uuid
      then do:
         vCheck = yes.
         create tt-grp-uuid.
         assign
            tt-grp-uuid.grp-num = 0
            tt-grp-uuid.uuid     = tt-rep.uuid
         .
      end.
      if last-of(tt-rep.uuid-cheq) then do:
         if vCheck then
            tt-total-rep.qty-chk-fuel = tt-total-rep.qty-chk-fuel + 1.
      end.
   end.
   release tt-total-rep.
   for each tt-rep,
      first tt-total-rep where
            tt-total-rep.obj-type = tt-rep.obj-type
        and tt-total-rep.obj-code = tt-rep.obj-code
        and tt-total-rep.obj-name = tt-rep.obj-name
   break
      by tt-rep.obj-type
      by tt-rep.obj-code
      by tt-rep.obj-name
      by tt-rep.tran-num:
      if first-of(tt-rep.tran-num) then do:
         tt-total-rep.qty-tran       = tt-total-rep.qty-tran + 1.
         tt-total-rep.full-time-tran = tt-total-rep.full-time-tran + tt-rep.time-length.
      end.
   end.
   for each tt-total-rep:
      tt-total-rep.avg-time-tran      = tt-total-rep.full-time-tran / tt-total-rep.qty-tran.
      tt-total-rep.avg-time-tran-fuel = tt-total-rep.full-time-tran / tt-total-rep.qty-chk-fuel.
   end.
   for each tt-grp-uuid:
      delete tt-grp-uuid.
   end.
   for each tt-rep
   break
      by tt-rep.obj-type
      by tt-rep.obj-code
      by tt-rep.sort-date
      by tt-rep.sort-time
      by tt-rep.uuid-cheq
      by tt-rep.datetime-beg:
      if first-of(tt-rep.obj-code) then do:
         create tt-all-total-rep.
         assign
            tt-all-total-rep.obj-type = tt-rep.obj-type
            tt-all-total-rep.obj-code = tt-rep.obj-code
            .
      end.
      if first-of(tt-rep.uuid-cheq) then do:
         vCheck = no.
         tt-all-total-rep.qty-chk = tt-all-total-rep.qty-chk + 1.
      end.
      find first tt-grp-uuid where tt-grp-uuid.grp-num = 0
                               and tt-grp-uuid.uuid     = tt-rep.uuid
      no-error.
      if not available tt-grp-uuid
      then do:
         vCheck = yes.
         create tt-grp-uuid.
         assign
            tt-grp-uuid.grp-num = 0
            tt-grp-uuid.uuid     = tt-rep.uuid
         .
      end.
      if last-of(tt-rep.uuid-cheq) then do:
         if vCheck then
            tt-all-total-rep.qty-chk-fuel = tt-all-total-rep.qty-chk-fuel + 1.
      end.
   end.
   release tt-all-total-rep.
   for each tt-rep,
      first tt-all-total-rep where
            tt-all-total-rep.obj-type = tt-rep.obj-type
        and tt-all-total-rep.obj-code = tt-rep.obj-code
   break
      by tt-rep.obj-type
      by tt-rep.obj-code
      by tt-rep.tran-num:
      if first-of(tt-rep.tran-num) then do:
         tt-all-total-rep.qty-tran       = tt-all-total-rep.qty-tran + 1.
         tt-all-total-rep.full-time-tran = tt-all-total-rep.full-time-tran + tt-rep.time-length.
      end.
   end.
   for each tt-all-total-rep:
      tt-all-total-rep.avg-time-tran      = tt-all-total-rep.full-time-tran / tt-all-total-rep.qty-tran.
      tt-all-total-rep.avg-time-tran-fuel = tt-all-total-rep.full-time-tran / tt-all-total-rep.qty-chk-fuel.
   end.
end.
define private temp-table ttTranFuel no-undo
   field line-num     as integer
   field trn-num      as integer
   field db-num       as integer
   field uuid         as character
   field uuid-cheq    as character
   field chk-type     as integer
   field chk-date     as date
   field chk-time     as integer
   field trk-num      as integer
   field trn-start    as datetime
   field trn-end      as datetime
   field trn-prnt     as integer
   field trn-prnt-trk as integer
   field trn-chld     as integer
   field trn-chld-trk as integer
index pi db-num uuid uuid-cheq
index si trn-start trn-end chk-date chk-time
.
define private temp-table tt-recid-TranFuel no-undo
   field rec-id as recid
.
  define property Msg as character no-undo
    get:
      return trim (Msg, chr(10)).
    end.
    private set (inArg as char):
      Msg = Msg + chr(10) + inArg.
    end.
    define property InitSecTag as character no-undo init 'sales-p-shifts':U
    get.
  define public property sendTableName  as character  no-undo
    get.
    private set.
  define public property sendOldRowid as rowid  no-undo
    get.
    set.
  define public property sendNewRowid as rowid  no-undo
    get.
    set.
  define property BufHandle as handle no-undo
    get.
    set.
  define private variable libFindtank as class ibs.th.str.findtank no-undo .
  define private variable mRepShiftNum  as integer no-undo.
  define private variable mRepShiftDate as date    no-undo.
                                    constructor public check ():
     super().
     libFindtank = new ibs.th.str.findtank ().
  end constructor.
  method public void CrContentToSW (insw as handle):
run gbl/getobjsrvhndl.p (input-output ObjSrv).
    define variable v-fld-host-code  as handle no-undo .
    define variable v-fld-obj-type   as handle no-undo .
    define variable v-fld-obj-code   as handle no-undo .
    define variable v-fld-shift-date as handle no-undo .
    define variable v-fld-shift-num  as handle no-undo .
    define variable v-host-code      as integer no-undo .
    define variable v-obj-type       as character no-undo .
    define variable v-obj-code       as integer no-undo .
    define variable v-shift-date     as date no-undo .
    define variable v-shift-num      as integer no-undo .
    define variable v-user-name      as character no-undo .
    define variable v-inkas-dtime    as datetime no-undo .
    define variable v-en-chktype     as enum-chk-type no-undo .
    define buffer chk-doc-attr for ub.chk-doc-attr.
    define buffer buf_inkas          for ub.inkas .
    define buffer over_buf_chk-doc   for ub.chk-doc .
    Msg = "" .
    if not valid-handle(BufHandle) then undo, throw new Progress.Lang.AppError("Отсутствует запись СМЕНЫ shift_obj с документами продажи") .
    sendTableName = BufHandle:table.
    sendOldRowid  = BufHandle:rowid.
  if BufHandle:table <> "chk-doc" then do:
    assign
      v-fld-host-code  = BufHandle:buffer-field( "host-code":U  )
      v-fld-obj-type   = BufHandle:buffer-field( "obj-type":U  )
      v-fld-obj-code   = BufHandle:buffer-field( "obj-code":U  )
      v-fld-shift-date = BufHandle:buffer-field( "shift-date":U  )
      v-fld-shift-num  = BufHandle:buffer-field( "shift-num":U  )
    .
    assign
      v-host-code  = v-fld-host-code:buffer-value
      v-obj-type   = v-fld-obj-type:buffer-value
      v-obj-code   = v-fld-obj-code:buffer-value
      v-shift-date = v-fld-shift-date:buffer-value
      v-shift-num  = v-fld-shift-num:buffer-value
    .
    insw:start-element ('shift':U) .
    if v-shift-date = ? then insw:write-empty-element ( "shift-date":U ) .
                        else insw:write-data-element (  "shift-date":U,  iso-date(v-shift-date)  ).
    if v-shift-num  = ? then insw:write-empty-element ( "shift-num":U  ) .
                        else insw:write-data-element (  "shift-num":U,   string(v-shift-num)     ).
    insw:start-element ('checks':U) .
    for each buf_inkas no-lock
       where buf_inkas.host-code  = v-host-code
         and buf_inkas.obj-type   = v-obj-type
         and buf_inkas.obj-code   = v-obj-code
         and buf_inkas.shift-date = v-shift-date
         and buf_inkas.shift-num  = v-shift-num
         and buf_inkas.status_    = 'факт':U
    :
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run usrfulnm in ibs.th.gbl.gbl-hndllib:g#library
  (input  buf_inkas.user-name
  ,output v-user-name
  )  .
    run rep/rpychk0.p ( input "bgepych2"
                      , input v-obj-type
                      , input v-obj-code
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      , input buf_inkas.inkas-code
                      ) .
    v-inkas-dtime = datetime(buf_inkas.fact-date, buf_inkas.sys-time-int * 1000) .
    for each over_buf_chk-doc no-lock
       where over_buf_chk-doc.out-code = buf_inkas.inkas-code:
      v-en-chktype = enum-chk-type:GetEnum(over_buf_chk-doc.chk-type) no-error .
      if not error-status:error then
        CrContentInterfaceToSW (insw, buffer over_buf_chk-doc, v-inkas-dtime, v-user-name,
          v-host-code, v-obj-type, v-obj-code) .
    end .
    for each chk-doc-attr where attr-code = 'CHFlag1S' and attr-value = 'no' exclusive-lock:
       for each over_buf_chk-doc  no-lock  where over_buf_chk-doc.doc-code = chk-doc-attr.doc-code:
          v-en-chktype = enum-chk-type:GetEnum(over_buf_chk-doc.chk-type) no-error .
          if not error-status:error
          then
             CrContentInterfaceToSW (insw,
                                     buffer over_buf_chk-doc,
                                     v-inkas-dtime,
                                     v-user-name,
                                     v-host-code,
                                     v-obj-type,
                                     v-obj-code) .
       end.
       delete chk-doc-attr.
    end.
  end.
  insw:end-element ('checks':U) .
  insw:end-element ('shift':U) .
 END.
if BufHandle:table = "chk-doc" then do:
      define variable v-curr-sv-date as date no-undo .
      run gbl/getcurdt.p  (output v-curr-sv-date ) .
    assign
      v-fld-obj-type   = BufHandle:buffer-field( "obj-type":U  )
      v-fld-obj-code   = BufHandle:buffer-field( "obj-code":U  )
      v-fld-shift-num  = BufHandle:buffer-field( "shift-num":U  )
    .
    assign
      v-obj-type   = v-fld-obj-type:buffer-value
      v-obj-code   = v-fld-obj-code:buffer-value
      v-shift-date = v-curr-sv-date
      v-shift-num  = v-fld-shift-num:buffer-value
    .
    find first shift-obj where shift-obj.status_ = "ТЕК" and shift-obj.obj-code = v-obj-code no-error.
    IF AVAILABLE shift-obj THEN v-shift-num = shift-obj.shift-num.
    else v-shift-num = 0.
    insw:start-element ('shift':U) .
    insw:write-data-element (  "shift-date":U,  iso-date(v-shift-date) ).
    insw:write-data-element (  "shift-num":U,   string(v-shift-num)    ).
    insw:start-element ('checks':U) .
    for each chk-doc-attr where chk-doc-attr.attr-code = 'CHFlag1S' and chk-doc-attr.attr-value = 'no' exclusive-lock:
       for each over_buf_chk-doc  no-lock  where
                over_buf_chk-doc.doc-code = chk-doc-attr.doc-code:
          if over_buf_chk-doc.chk-type eq 40 or over_buf_chk-doc.chk-type eq 13 then
          do:
             v-en-chktype = enum-chk-type:GetEnum(over_buf_chk-doc.chk-type) no-error .
             if not error-status:error then
             CrContentInterfaceToSW (insw, buffer over_buf_chk-doc, v-inkas-dtime, v-user-name,
             v-host-code, v-obj-type, v-obj-code) .
             delete chk-doc-attr.
          end.
       end.
    end .
insw:end-element ('checks':U) .
insw:end-element ('shift':U) .
END.
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg = "" then Msg = exAppErrors:GetMessage(1) .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) .
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error occurred..." .
      undo, throw exAnyErrors .
    end catch .
  end method .
  method private void CrTTFuelTran (buffer p-buf_chk-doc for ub.chk-doc):
   define buffer chk-doc-attr  for chk-doc-attr.
   define buffer chk-gds       for chk-gds.
   define buffer b-chk-gds     for chk-gds.
   define buffer bar-code      for bar-code.
   define buffer goods         for goods.
   define buffer prod-bc       for prod-bc.
   define buffer tran-fuel     for tran-fuel.
   define buffer b-tran-fuel   for tran-fuel.
   define buffer b2-tran-fuel  for tran-fuel.
   define buffer b-ttTranFuel  for ttTranFuel.
   define variable vRecId as recid   no-undo.
   empty temp-table ttTranFuel.
   for each chk-doc-attr where
            chk-doc-attr.doc-code  = p-buf_chk-doc.doc-code
        and chk-doc-attr.attr-code = "CheckId"
   no-lock,
       each chk-gds where
            chk-gds.doc-code = p-buf_chk-doc.doc-code
   no-lock:
      if can-find(first ttTranFuel where ttTranFuel.uuid-cheq = chk-doc-attr.attr-value) then
         next.
      empty temp-table tt-recid-TranFuel.
      for first bar-code where
                bar-code.b-code = chk-gds.b-code
      no-lock,
          first goods where
                goods.gds-code = bar-code.gds-code
      no-lock:
         for first prod-bc where
                   prod-bc.b-code = chk-gds.b-code
         no-lock,
             each tran-fuel where
                  tran-fuel.uuid-cheq = chk-doc-attr.attr-value
              and tran-fuel.fuel-code = integer(prod-bc.b-str)
         no-lock:
            create tt-recid-TranFuel.
            tt-recid-TranFuel.rec-id = recid(tran-fuel).
         end.
         for each tran-fuel where
                  tran-fuel.uuid-cheq = chk-doc-attr.attr-value
              and tran-fuel.fuel-code = goods.gds-code
         no-lock:
            create tt-recid-TranFuel.
            tt-recid-TranFuel.rec-id = recid(tran-fuel).
         end.
      end.
      for each tt-recid-TranFuel,
         first tran-fuel where
               recid(tran-fuel) = tt-recid-TranFuel.rec-id
      no-lock:
         find first tt-rep where
                    tt-rep.uuid      = tran-fuel.uuid
                and tt-rep.uuid-cheq = tran-fuel.uuid-cheq
         no-error.
         create ttTranFuel.
         assign
            ttTranFuel.line-num     = chk-gds.line-num
            ttTranFuel.trn-num      = tran-fuel.tran-num
            ttTranFuel.trn-start    = if avail tt-rep then
                                         tt-rep.datetime-beg
                                      else
                                         tran-fuel.date-beg + timezone * 60000
            ttTranFuel.trn-end      = if avail tt-rep then
                                         tt-rep.datetime-end
                                      else
                                         tran-fuel.date-end + timezone * 60000
            ttTranFuel.trk-num      = tran-fuel.trk-num + 1
            ttTranFuel.db-num       = tran-fuel.db-num
            ttTranFuel.uuid         = tran-fuel.uuid
            ttTranFuel.uuid-cheq    = tran-fuel.uuid-cheq
            ttTranFuel.chk-type     = p-buf_chk-doc.chk-type
            ttTranFuel.chk-date     = p-buf_chk-doc.chk-date
            ttTranFuel.chk-time     = p-buf_chk-doc.chk-time
            .
         if p-buf_chk-doc.chk-type = 16 then do:
            find first b-chk-gds where
                       b-chk-gds.doc-code =  p-buf_chk-doc.doc-code
                   and b-chk-gds.line-num <> chk-gds.line-num
            no-lock no-error.
            if avail b-chk-gds then do:
               find first b-tran-fuel where
                          b-tran-fuel.db-num    =  tran-fuel.db-num
                      and b-tran-fuel.uuid      =  tran-fuel.uuid
                      and b-tran-fuel.uuid-cheq <> tran-fuel.uuid-cheq
               no-lock no-error.
               if avail b-tran-fuel then do:
                  find first b2-tran-fuel where
                             b2-tran-fuel.db-num    =  b-tran-fuel.db-num
                         and b2-tran-fuel.uuid-cheq =  b-tran-fuel.uuid-cheq
                         and b2-tran-fuel.uuid      <> b-tran-fuel.uuid
                  no-lock no-error.
                  if avail b2-tran-fuel then do:
                     find first tt-rep where
                                tt-rep.uuid      = b2-tran-fuel.uuid
                            and tt-rep.uuid-cheq = b2-tran-fuel.uuid-cheq
                     no-error.
                     create ttTranFuel.
                     assign
                        ttTranFuel.line-num     = b-chk-gds.line-num
                        ttTranFuel.trn-num      = b2-tran-fuel.tran-num
                        ttTranFuel.trn-start    = if avail tt-rep then
                                                     tt-rep.datetime-beg
                                                  else
                                                     b2-tran-fuel.date-beg + timezone * 60000
                        ttTranFuel.trn-end      = if avail tt-rep then
                                                     tt-rep.datetime-end
                                                  else
                                                     b2-tran-fuel.date-end + timezone * 60000
                        ttTranFuel.trk-num      = b2-tran-fuel.trk-num + 1
                        ttTranFuel.db-num       = b2-tran-fuel.db-num
                        ttTranFuel.uuid         = b2-tran-fuel.uuid
                        ttTranFuel.uuid-cheq    = tran-fuel.uuid-cheq
                        ttTranFuel.chk-type     = p-buf_chk-doc.chk-type
                        ttTranFuel.chk-date     = p-buf_chk-doc.chk-date
                        ttTranFuel.chk-time     = p-buf_chk-doc.chk-time
                        .
                  end.
               end.
            end.
         end.
      end.
   end.
   for each ttTranFuel:
      find first tt-rep where
                 tt-rep.uuid      = ttTranFuel.uuid
             and tt-rep.uuid-cheq = ttTranFuel.uuid-cheq
      no-error.
      if avail tt-rep then
         assign
            ttTranFuel.trn-start = tt-rep.datetime-beg
            ttTranFuel.trn-end   = tt-rep.datetime-end
            .
   end.
   vRecId = ?.
   for each ttTranFuel
   break
      by ttTranFuel.trn-start
      by ttTranFuel.trn-end
      by ttTranFuel.chk-date
      by ttTranFuel.chk-time:
      if vRecId <> ? then do:
         find first b-ttTranFuel where
                    recid(b-ttTranFuel) = vRecId
         no-error.
         if avail b-ttTranFuel then do:
            assign
               b-ttTranFuel.trn-chld     = ttTranFuel.trn-num
               b-ttTranFuel.trn-chld-trk = ttTranFuel.trk-num
               ttTranFuel.trn-prnt       = b-ttTranFuel.trn-num
               ttTranFuel.trn-prnt-trk   = b-ttTranFuel.trk-num
               .
         end.
      end.
      vRecId = recid(ttTranFuel).
   end.
  end method.
        destructor public check ( ):
       if valid-object(libFindtank) then delete object libFindtank .
        end destructor.
  method private void CrContentInterfaceToSW (insw as handle
                                          , buffer p-buf_chk-doc for ub.chk-doc
                                          , input p-inkas-dtime    as datetime
                                          , input p-inkas-operator as character
                                          , input p-host-code      as integer
                                          , input p-obj-type       as character
                                          , input p-obj-code       as integer
                                          ) :
    define buffer buf_dis-card     for ub.dis-card .
    define buffer buf_chk-doc-attr for ub.chk-doc-attr .
    define buffer chk-doc-attr for ub.chk-doc-attr .
    define buffer buf_chk-gds      for ub.chk-gds .
    define buffer buf_bar-code     for ub.bar-code .
    define buffer buf_goods        for ub.goods .
    define buffer buf_chk-gds-attr for ub.chk-gds-attr .
    define buffer buf_chk-pay      for ub.chk-pay .
    define buffer buf_chk-pay-attr for ub.chk-pay-attr .
    define buffer buf_cash-pay-attr for ub.cash-pay-attr .
    define buffer buf_chk-discnt   for ub.chk-discnt .
    define buffer bf_chk-discnt    for ub.chk-discnt .
    define buffer buf_chk-gds-pay  for ub.chk-gds-pay .
    define buffer buf_OperServ     for ub.OperServ .
    define buffer buf_cash-desk-attr for ub.cash-desk-attr .
    define buffer buf_clients      for ub.clients .
    define buffer buf_cash-desk    for ub.cash-desk .
    define buffer buf_doc-line     for ub.doc-line .
    define buffer buf_parts        for ub.parts .
    define buffer buf_marking-chk  for ub.marking-chk .
    define variable v-is-petrolium as logical no-undo .
    define variable v-price-azs    as decimal no-undo .
    define variable v-is-pieces    as logical no-undo .
    define variable v-loc1         as character no-undo .
    define variable v-spump        as character no-undo .
    define variable v-snozzle-code as character no-undo .
    define variable v-key-one      as integer no-undo .
    define variable v-is-nds       as integer no-undo .
    define variable v-ex-Nds       as logical no-undo.
    define variable v-chk-pay-is-nds as logical no-undo .
    define variable v-sum-s        as decimal no-undo .
    define variable v-parts-qnty   as decimal no-undo .
    define variable v-marking      as character no-undo .
    define variable v-sum-promo    as decimal no-undo .
    define variable v-pcnt-promo   as decimal no-undo .
    define variable v-b-code       as integer no-undo.
    define variable v-gds-qnty     as decimal no-undo.
    define variable v-disc-promo-id as integer no-undo.
    define variable v-disc-promo-count as int no-undo.
    define variable v-line-num-promo as int no-undo.
    insw:start-element ('check':U) .
    if p-buf_chk-doc.shift-date = ? then insw:write-empty-element ( "shift-date":U ) .
    else insw:write-data-element (  "shift-date":U,  iso-date(p-buf_chk-doc.shift-date)  ).
    insw:write-data-element (  "shift-num":U,       string(if p-buf_chk-doc.shift-num = 0 then p-buf_chk-doc.shift-name else string(p-buf_chk-doc.shift-num))   ).
    insw:write-data-element (  "chk-num":U,         string(p-buf_chk-doc.chk-num)     ).
    insw:write-data-element (  "cb-num":U,          string(p-buf_chk-doc.pay-desk)    ).
    insw:write-data-element (  "chk-id":U,                 p-buf_chk-doc.doc-code     ).
    define variable v-c-type as integer no-undo .
    v-c-type = 0 .
    find first buf_clients no-lock
         where buf_clients.obj-code = p-obj-code
           and buf_clients.obj-type = p-obj-type no-error .
    if available buf_clients then do :
      find first buf_cash-desk no-lock
           where buf_cash-desk.db-num   = buf_clients.db-num
             and buf_cash-desk.obj-code = p-obj-code
             and buf_cash-desk.cash-num = p-buf_chk-doc.pay-desk no-error .
      if available buf_cash-desk then do :
        v-c-type = buf_cash-desk.device-kind .
      end .
    end .
    insw:write-data-element (  "c-type":U,  string(v-c-type)  ).
    if p-buf_chk-doc.doc-num > "" then
    insw:write-data-element (  "ext-num":U,         p-buf_chk-doc.doc-num   ).
    if p-buf_chk-doc.doc-num2 > "" then
    insw:write-data-element (  "direct-chk-num":U,  p-buf_chk-doc.doc-num2  ).
    if p-buf_chk-doc.chk-date = ? then insw:write-empty-element( "chk-date":U ).
    else insw:write-data-element (  "chk-date":U,  iso-date(p-buf_chk-doc.chk-date)  ).
    insw:write-data-element (  "chk-time",     timeFormat(p-buf_chk-doc.chk-time)    ).
    insw:write-data-element (  "cashier",          string(p-buf_chk-doc.cashier)     ).
    insw:write-data-element (  "z-num",            string(p-buf_chk-doc.z-number)    ).
    insw:write-data-element (  "chk-type", left-trim(string(p-buf_chk-doc.chk-type, ">9"))    ).
    insw:write-data-element (  "netto",   left-trim(string(p-buf_chk-doc.netto,   "->>>>>>>>9.9<"))  ).
    insw:write-data-element (  "tot-doc", left-trim(string(p-buf_chk-doc.tot-doc, "->>>>>>>>9.9<"))  ).
    if p-buf_chk-doc.chk-type <> 13 and p-buf_chk-doc.chk-type <> 40     then
     do:
        find first buf_chk-doc-attr where buf_chk-doc-attr.doc-code  eq p-buf_chk-doc.doc-code
                                  and buf_chk-doc-attr.attr-code eq "CHMgrKey"
             no-lock no-error.
       if avail buf_chk-doc-attr
       then
       insw:write-data-element( "CHMgrKey",  buf_chk-doc-attr.attr-value).
    end.
    if p-buf_chk-doc.chk-type <> 13 and p-buf_chk-doc.chk-type <> 40     then
     do:
          find first chk-doc-attr where chk-doc-attr.doc-code = p-buf_chk-doc.doc-code
            and chk-doc-attr.attr-code = 'CHFlag1' no-lock no-error.
            if available chk-doc-attr then
            do:
              insw:write-data-element (  "CHFlag1",  string(chk-doc-attr.attr-value)  ) .
              if chk-doc-attr.attr-value = "0" then
                insw:write-data-element (  "Dry-chk-th",  string(chk-doc-attr.attr-value)  ) .
            end.
    end.
    find first buf_chk-doc-attr where buf_chk-doc-attr.doc-code  eq p-buf_chk-doc.doc-code
                                  and buf_chk-doc-attr.attr-code eq "CHNumberKKT"
             no-lock no-error.
    if avail buf_chk-doc-attr
    then
       insw:write-data-element( "CHNumberKKT",  buf_chk-doc-attr.attr-value).
    find first buf_chk-doc-attr where buf_chk-doc-attr.doc-code  eq p-buf_chk-doc.doc-code
                                  and buf_chk-doc-attr.attr-code eq "CHNumberFN"
             no-lock no-error.
    if avail buf_chk-doc-attr
    then
       insw:write-data-element( "CHNumberFN",  buf_chk-doc-attr.attr-value).
    if "" > "" then insw:write-data-element ( "term-num", "" ).
    if p-buf_chk-doc.d-card > "" then do:
      insw:write-data-element (  "dc-num":U,     p-buf_chk-doc.src-d-card     ).
      find first buf_dis-card no-lock
           where buf_dis-card.d-card = p-buf_chk-doc.d-card no-error .
      if available buf_dis-card then do:
        if buf_dis-card.card-num > 0 then
      insw:write-data-element (  "dc-name":U,    string(buf_dis-card.type)  ).
      end.
    end.
    if p-inkas-operator > "" then
      insw:write-data-element (  "operator":U,   p-inkas-operator           ).
    if p-buf_chk-doc.out-code > "" then // chk-doc.out-code хранит значение из inkas.inkas-code
      insw:write-data-element (  "prdoc-num":U,  p-buf_chk-doc.out-code     ).
    if p-inkas-dtime = ? then insw:write-data-element ("prdoc-date":U, SUBSTITUTE("&1T&2", iso-date(p-buf_chk-doc.chk-date), timeFormat(p-buf_chk-doc.chk-time) )).
    else  insw:write-data-element (  "prdoc-date":U, iso-date(p-inkas-dtime)    ).
        v-chk-pay-is-nds = false .
    for each buf_cash-pay-attr no-lock
       where buf_cash-pay-attr.attr-code  = "cash-prop"
         and can-do ("1,2,3,6,7", buf_cash-pay-attr.attr-value) :
      if can-find (first buf_chk-pay
                   where buf_chk-pay.doc-code  = p-buf_chk-doc.doc-code
                     and buf_chk-pay.pay-code  = buf_cash-pay-attr.cdpay-code
                     and buf_chk-pay.curr-code = buf_cash-pay-attr.curr-code) then do :
        v-chk-pay-is-nds = true .
        leave .
      end .
    end .
    find first buf_chk-doc-attr no-lock
         where buf_chk-doc-attr.doc-code  eq p-buf_chk-doc.doc-code
           and buf_chk-doc-attr.attr-code eq "CHFiscalDocSign" no-error .
    if available buf_chk-doc-attr then
      insw:write-data-element (  "fpd":U,  buf_chk-doc-attr.attr-value     ).
    assign
       v-ex-Nds = no
       v-b-code = 0
       v-gds-qnty = 0
       .
    if can-find (first buf_chk-gds where buf_chk-gds.doc-code = p-buf_chk-doc.doc-code) then do:
    insw:start-element ('chk-gds':U) .
      for each buf_chk-gds no-lock
         where buf_chk-gds.doc-code = p-buf_chk-doc.doc-code :
        v-ex-Nds = v-ex-Nds or buf_chk-gds.VAT-pc eq ? or buf_chk-gds.VAT-sum-rubl eq ? .
        insw:start-element ('chk-gd':U) .
        insw:write-data-element (  "line-num",  string(buf_chk-gds.line-num)  ) .
        find first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code no-error.
        if available buf_bar-code then do:
          find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
          if available buf_goods then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in ibs.th.gbl.gbl-hndllib:g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-is-petrolium
  , output v-is-pieces
  ) .
            if v-is-petrolium then
            assign
               v-b-code = buf_chk-gds.b-code
               v-gds-qnty = buf_chk-gds.src-qnty
               .
          end .
          else v-is-petrolium = false .
        end .
        else v-is-petrolium = false .
        if v-is-petrolium then do :
          if buf_chk-gds.pl-code > 0 then v-loc1 = string (buf_chk-gds.pl-code).
          else if available buf_bar-code then do:
            v-loc1 = getTankNum
              (input p-buf_chk-doc.obj-type
              ,input p-buf_chk-doc.obj-code
              ,input buf_chk-gds.pump
              ,input buf_chk-gds.nozzle-code
              ,input buf_chk-gds.src-pl-code
              ,input buf_chk-gds.pl-code
              ,input buf_bar-code.gds-code
              ) .
          end.
          else v-loc1 = "" .
          assign
            v-spump        = string(buf_chk-gds.pump)
            v-snozzle-code = string(buf_chk-gds.nozzle-code)
          .
        end .
        else assign
          v-loc1  = ""
          v-spump = ""
          v-snozzle-code = ""
        .
        insw:write-data-element (  "trk-num",  if v-spump        > "" then v-spump        else "0"  ) .
        insw:write-data-element (  "tank-num", if v-loc1         > "" then v-loc1         else "0"  ) .
        insw:write-data-element (  "trk-pnum", if v-snozzle-code > "" then v-snozzle-code else "0"  ) .
        if available buf_bar-code then insw:write-data-element (  "gd-code",  string(buf_bar-code.gds-code)  ) .
                                  else insw:write-empty-element ( "gd-code" ) .
        insw:write-data-element (  "qnty",  left-trim(string(buf_chk-gds.doc-qnty, "->>>>>>>9.999"))  ) .
        if v-is-petrolium and (buf_chk-gds.density > 0) then do :
          insw:write-data-element (  "wght",
            left-trim( string(buf_chk-gds.doc-qnty * buf_chk-gds.density, "->>>>>>>>9.999") )
          ) .
        end.
        find first buf_chk-gds-attr no-lock where
                   buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code
               and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
               and buf_chk-gds-attr.attr-code = "CSPromoSum"
            no-error.
        if avail buf_chk-gds-attr then v-sum-promo = dec(buf_chk-gds-attr.attr-value) no-error.
        else v-sum-promo = 0.
        insw:write-data-element (  "sum",
          if buf_chk-gds.sum-base = ?
          then  "0"
          else  left-trim( string(buf_chk-gds.sum-base + v-sum-promo, "->>>>>>>>9.99") )
        ) .
        if available buf_goods
        then do :
          assign
            v-sum-s = 0
            v-parts-qnty = 0
          .
          for each buf_parts no-lock where buf_parts.out-code   = p-buf_chk-doc.out-code
                                         and buf_parts.artic      = buf_goods.artic
                                         and buf_parts.prod-code  = buf_goods.prod-code
                                         and buf_parts.prod-type  = buf_goods.prod-type :
            assign
              v-parts-qnty = v-parts-qnty + buf_parts.fact-qnty
              v-sum-s = v-sum-s + (buf_parts.fact-qnty * buf_parts.price-rubl / (1 + (buf_parts.VAT-pc / 100)))
            .
          end.
          if v-parts-qnty > 0 then v-sum-s = v-sum-s / v-parts-qnty * buf_chk-gds.doc-qnty .
          if v-sum-s <> 0
          then do :
            insw:write-data-element (  "sum-s",
              left-trim( string(v-sum-s, "->>>>>>>>9.99") )
            ) .
          end.
          else do :
            insw:write-data-element (  "sum-s", "0" ) .
          end.
        end.
        if (buf_chk-gds.discnt <> 0) or (v-sum-promo <> 0) then
        insw:write-data-element (  "sum-discnt",
          left-trim( string(buf_chk-gds.doc-qnty * buf_chk-gds.discnt + v-sum-promo, "->>>>>>>>>9.9<<<<<<<<<") )
        ) .
        if v-is-petrolium and (buf_chk-gds.density > 0) then
        insw:write-data-element (  "dnsty",  string(buf_chk-gds.density, "9.9999999999")  ) .
        if buf_chk-gds.pass-gds > 0 then
        insw:write-data-element (  "dry-chk",  string(buf_chk-gds.pass-gds)  ) .
        if v-chk-pay-is-nds then do :
          if buf_chk-gds.VAT-pc ne ? then
            insw:write-data-element (  "vat-rate",  string(buf_chk-gds.VAT-pc)        ) .
          if buf_chk-gds.VAT-sum-rubl ne ? then
            insw:write-data-element (  "vat",       string(buf_chk-gds.VAT-sum-rubl)  ) .
        end .
        find first buf_chk-gds-attr no-lock
             where buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
               and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
               and buf_chk-gds-attr.attr-code = 'oss-code':U no-error .
        if available buf_chk-gds-attr then do:
          v-key-one = integer (buf_chk-gds-attr.attr-value) no-error .
          find first buf_OperServ no-lock where buf_OperServ.id = v-key-one no-error .
          if available buf_OperServ then do :
            insw:write-data-element (  "operator-code",  buf_OperServ.ext-code  ) .
            insw:write-data-element (  "operator-name",  buf_OperServ.OSname    ) .
          end .
        end .
        find first buf_chk-gds-attr no-lock
             where buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
               and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
               and buf_chk-gds-attr.attr-code = "agent-gd-code":U no-error .
        if available buf_chk-gds-attr then do:
          insw:write-data-element (  "srt-BC",  buf_chk-gds-attr.attr-value  ) .
        end .
        insw:write-data-element (  "price",  left-trim(string(buf_chk-gds.src-price, "->>>>>>>>9.99"))  ) .
        if enum-chk-type:GetEnum(p-buf_chk-doc.chk-type) = enum-chk-type:entranscancell then do:
          if buf_chk-gds.write-off-code >= 0 then
            insw:write-data-element (  "prolito",  string(buf_chk-gds.write-off-code)  ).
        end .
        insw:write-data-element (  "src-code",  string(buf_chk-gds.src-code)  ) .
        find first buf_chk-gds-attr no-lock
             where buf_chk-gds-attr.doc-code  = buf_chk-gds.doc-code
               and buf_chk-gds-attr.line-num  = buf_chk-gds.line-num
               and buf_chk-gds-attr.attr-code = "CSPriceOrig":U no-error .
        if available buf_chk-gds-attr then do:
          v-price-azs = decimal(buf_chk-gds-attr.attr-value) .
          insw:write-data-element (  "price-azs",  left-trim(string(v-price-azs, "->>>>>>>>9.99"))  ) .
        end .
        for each buf_marking-chk no-lock where buf_marking-chk.doc-code =  buf_chk-gds.doc-code and buf_marking-chk.line-num = buf_chk-gds.line-num:
          v-marking = repSpecSimbforXlm(GetCodeIdent(buf_marking-chk.mark)).
          if v-marking = "" then do:
          message "Ошибка. В чеке " buf_chk-gds.doc-code  " отсутствует марка." view-as alert-box.
          end.
          if v-marking <> "" then do:
          insw:write-data-element (  "dm",  v-marking ) .
          end.
        end.
        insw:end-element ('chk-gd':U) .
      end .
    insw:end-element ('chk-gds':U) .
    end .
    if mRepShiftDate = ? or
       (mRepShiftDate <> p-buf_chk-doc.shift-date and mRepShiftNum <> p-buf_chk-doc.shift-num) then do:
       empty temp-table tt-rep.
       empty temp-table tt-all-total-rep.
       empty temp-table tt-total-rep.
       empty temp-table tt-grp.
       empty temp-table tt-pay.
       assign
          mRepShiftNum  = p-buf_chk-doc.shift-num
          mRepShiftDate = p-buf_chk-doc.shift-date
          .
       initTT(yes,
              mRepShiftDate,
              mRepShiftDate,
              mRepShiftNum,
              mRepShiftNum,
              "*",
              "*",
              "*").
       AfterCalc(yes,
                 mRepShiftDate,
                 "*",
                 "*",
                 0).
    end.
    CrTTFuelTran(buffer p-buf_chk-doc).
    for each ttTranFuel
    break
      by ttTranFuel.trn-start
      by ttTranFuel.trn-end
      by ttTranFuel.chk-date
      by ttTranFuel.chk-time:
      if first(ttTranFuel.trn-start) then
         insw:start-element ('chk-trns':U) .
      insw:start-element ('chk-trn':U) .
      insw:write-data-element ("line-num",     string(ttTranFuel.line-num)).
      insw:write-data-element ("trn-num",      string(ttTranFuel.trn-num)).
      insw:write-data-element ("trn-start",    iso-date(ttTranFuel.trn-start)).
      insw:write-data-element ("trn-end",      iso-date(ttTranFuel.trn-end)).
      insw:write-data-element ("trn-prnt",     string(ttTranFuel.trn-prnt)).
      insw:write-data-element ("trn-prnt-trk", string(ttTranFuel.trn-prnt-trk)).
      insw:write-data-element ("trn-chld",     string(ttTranFuel.trn-chld)).
      insw:write-data-element ("trn-chld-trk", string(ttTranFuel.trn-chld-trk)).
      insw:end-element ('chk-trn':U) .
      if last(ttTranFuel.trn-start) then
         insw:end-element ('chk-trns':U) .
    end.
    for each buf_chk-pay no-lock
       where buf_chk-pay.doc-code = p-buf_chk-doc.doc-code
    break by buf_chk-pay.doc-code :
      if first-of(buf_chk-pay.doc-code) then insw:start-element ('chk-pays':U) .
      insw:start-element ('chk-pay':U) .
      insw:write-data-element (  "pay-num",  string(buf_chk-pay.line-num)  ) .
      insw:write-data-element (  "pay-code",  string(buf_chk-pay.pay-code)  ) .
      if buf_chk-pay.pay-card > "" then
      insw:write-data-element (  "pay-card",  string(buf_chk-pay.pay-card)  ) .
      for first buf_chk-pay-attr no-lock
           where buf_chk-pay-attr.doc-code  = buf_chk-pay.doc-code
             and buf_chk-pay-attr.attr-code = "cpdoc":U
             and buf_chk-pay-attr.line-num  = buf_chk-pay.line-num :
        insw:write-data-element (  "rrn",  buf_chk-pay-attr.attr-value  ) .
      end.
      for first buf_chk-pay-attr no-lock
           where buf_chk-pay-attr.doc-code  = buf_chk-pay.doc-code
             and buf_chk-pay-attr.attr-code = "RRN":U
             and buf_chk-pay-attr.line-num  = buf_chk-pay.line-num :
        insw:write-data-element (  "rrn",  buf_chk-pay-attr.attr-value  ) .
      end.
      for first buf_chk-pay-attr no-lock
           where buf_chk-pay-attr.doc-code  = buf_chk-pay.doc-code
             and buf_chk-pay-attr.attr-code = "RRN-VBRR":U
             and buf_chk-pay-attr.line-num  = buf_chk-pay.line-num :
        insw:write-data-element (  "rrn",  buf_chk-pay-attr.attr-value  ) .
      end.
      for first buf_chk-pay-attr no-lock
           where buf_chk-pay-attr.doc-code  = buf_chk-pay.doc-code
             and buf_chk-pay-attr.attr-code = "QRPay":U
             and buf_chk-pay-attr.line-num  = buf_chk-pay.line-num :
        insw:write-data-element (  "qrpay",  buf_chk-pay-attr.attr-value  ) .
      end.
      find first buf_chk-pay-attr no-lock
           where buf_chk-pay-attr.doc-code  = buf_chk-pay.doc-code
             and buf_chk-pay-attr.attr-code = "CPWithdrawal":U
             and buf_chk-pay-attr.line-num  = buf_chk-pay.line-num no-error.
      if available buf_chk-pay-attr then
      insw:write-data-element (  "cap-sum",  left-trim(string (dec(buf_chk-pay-attr.attr-value),">>>>>>>>>>>9.99") ) ) .
      find first buf_chk-pay-attr no-lock
           where buf_chk-pay-attr.doc-code  = buf_chk-pay.doc-code
             and buf_chk-pay-attr.attr-code = "CPAgreement":U
             and buf_chk-pay-attr.line-num  = buf_chk-pay.line-num no-error.
      if available buf_chk-pay-attr then
      insw:write-data-element (  "CPAgreement",  buf_chk-pay-attr.attr-value  ) .
      insw:write-data-element (  "sum",  left-trim(string(buf_chk-pay.tot-rubl, "->>>>>>>>>9.9<<<<<<<<<"))  ) .
      if not v-ex-Nds then do:
         find first buf_cash-pay-attr no-lock
              where buf_cash-pay-attr.cdpay-code = buf_chk-pay.pay-code
                and buf_cash-pay-attr.curr-code  = buf_chk-pay.curr-code
                and buf_cash-pay-attr.attr-code  = "cash-prop" no-error .
         if available buf_cash-pay-attr then do :
           v-is-nds = if can-do ("1,2,3,6,7", buf_cash-pay-attr.attr-value) then 1 else 0 .
         end .
         else v-is-nds = 0 .
         insw:write-data-element (  "is-nds",    string(v-is-nds)              ) .
      end.
      for first buf_chk-pay-attr no-lock
           where buf_chk-pay-attr.doc-code  = buf_chk-pay.doc-code
             and buf_chk-pay-attr.attr-code = "sbprrn":U
             and buf_chk-pay-attr.line-num  = buf_chk-pay.line-num :
         insw:write-data-element (  "sbprrn",    string(buf_chk-pay-attr.attr-value)              ) .
         end .
      for first buf_chk-pay-attr no-lock
           where buf_chk-pay-attr.doc-code  = buf_chk-pay.doc-code
             and buf_chk-pay-attr.attr-code = "sbpstat":U
             and buf_chk-pay-attr.line-num  = buf_chk-pay.line-num :
         insw:write-data-element (  "sbpstat",    string(buf_chk-pay-attr.attr-value)              ) .
         end .
      insw:end-element ('chk-pay':U) .
      if last-of(buf_chk-pay.doc-code) then insw:end-element ('chk-pays':U) .
    end .
    define variable vflg as logical no-undo.
    define variable vflg0 as logical no-undo.
    define variable v-discnt-value-abs as decimal no-undo.
    define variable v-promocode-list as character no-undo.
    define variable vflg-disc as logical no-undo.
    assign
       vflg  = no
       vflg0 = no
       v-discnt-value-abs = 0
       v-promocode-list = ""
       v-disc-promo-id = 0
       vflg-disc = no
       .
    if p-buf_chk-doc.chk-type = integer('6':U)
      and v-b-code <> 0
      and not can-find(first buf_chk-discnt no-lock
                       where buf_chk-discnt.doc-code    = p-buf_chk-doc.doc-code
                         and buf_chk-discnt.record-type    = 5
                         and buf_chk-discnt.promo-id <> "" )
    then do:
       v-disc-promo-id = get-chk-promo-id(p-buf_chk-doc.obj-code,
                                          p-buf_chk-doc.obj-type,
                                          p-buf_chk-doc.pay-desk,
                                          p-buf_chk-doc.doc-num2,
                                          v-b-code,
                                          v-gds-qnty,
                                          output v-line-num-promo,
                                          output v-disc-promo-count).
    end.
    if not can-find (first chk-discnt where chk-discnt.doc-code = p-buf_chk-doc.doc-code
                                        and chk-discnt.discnt-type       = 23
                                        and chk-discnt.discnt-value-pcnt = 0) then do :
    for each buf_chk-discnt no-lock
       where buf_chk-discnt.doc-code = p-buf_chk-doc.doc-code
         and ( buf_chk-discnt.record-type = 1 or
               buf_chk-discnt.record-type = 2
               or buf_chk-discnt.value-type = 14)
    break by buf_chk-discnt.doc-code :
      if first-of(buf_chk-discnt.doc-code) then do:
         vflg-disc = yes.
         insw:start-element ('chk-discnts':U) .
      end.
      if buf_chk-discnt.promo-id > "" and
         not can-do(v-promocode-list,buf_chk-discnt.promo-id) then
            v-promocode-list = if v-promocode-list = ""
                                  then buf_chk-discnt.promo-id
                                  else v-promocode-list + "," + buf_chk-discnt.promo-id.
      if   buf_chk-discnt.line-type = integer('2':U)
      and buf_chk-discnt.record-type = 1
      and can-find(first  bf_chk-discnt no-lock
          where bf_chk-discnt.doc-code = buf_chk-discnt.doc-code and  bf_chk-discnt.record-type = 1 and bf_chk-discnt.discnt-id = buf_chk-discnt.discnt-id ) then
      do:
         if not vflg
         then
         for each bf_chk-discnt no-lock
          where bf_chk-discnt.doc-code = buf_chk-discnt.doc-code and bf_chk-discnt.record-type = 1  and bf_chk-discnt.discnt-id = buf_chk-discnt.discnt-id  break by bf_chk-discnt.object-line-num:
          vflg = yes.
          insw:start-element ('chk-discnt':U) .
          insw:write-data-element (  "discnt-num",       string(bf_chk-discnt.discnt-id)          ) .
          insw:write-data-element (  "line-num",         string(bf_chk-discnt.object-line-num)           ) .
          insw:write-data-element (  "discnt-type",      string(bf_chk-discnt.value-type)        ) .
          insw:write-data-element (  "discntValueAbs",   left-trim(string(bf_chk-discnt.discnt-value-abs,  "->>>>>>>>>9.9<<<<<<<<<"))  ) .
          insw:write-data-element (  "discntValuePcnt",  left-trim(string(bf_chk-discnt.discnt-value-pcnt, "->>>9.9<"))                 ) .
          if bf_chk-discnt.promo-id > "" then
          do:
            find first PromoAction where PromoAction.id =  int(bf_chk-discnt.promo-id) no-lock no-error.
            insw:write-data-element (  "promotion-code", if available PromoAction and PromoAction.ext-code > '' then PromoAction.ext-code else  bf_chk-discnt.promo-id  ) .
          end.
          if bf_chk-discnt.templ-rl-root > 0 then  insw:write-data-element (  "discntGdsReason",       string(bf_chk-discnt.templ-rl-root)          ) .
          insw:end-element ('chk-discnt':U) .
        end.
      end.
      else
      do:
        assign
          v-sum-promo = 0
          v-pcnt-promo = 0
          .
        if buf_chk-discnt.record-type = 1 and
           buf_chk-discnt.promo-id > "" then
        do:
            find first buf_chk-gds-attr no-lock
                 where buf_chk-gds-attr.doc-code =  buf_chk-discnt.doc-code
                   and buf_chk-gds-attr.line-num  =  buf_chk-discnt.line-num
                   and buf_chk-gds-attr.attr-code = "CSPromoSum"
               no-error.
            if avail buf_chk-gds-attr then do:
                v-sum-promo = dec(buf_chk-gds-attr.attr-value).
                find first  buf_chk-gds no-lock
                      where buf_chk-gds.doc-code = buf_chk-discnt.doc-code
                        and buf_chk-gds.line-num = buf_chk-discnt.line-num
                   no-error.
                if avail buf_chk-gds then
                   v-pcnt-promo = 100 * ( 1 - (buf_chk-gds.sum-base / (buf_chk-gds.sum-base + v-sum-promo))).
            end.
        end.
        if buf_chk-discnt.discnt-type = 999 and
           buf_chk-discnt.record-type = 2 and
           buf_chk-discnt.value-type = 2 and
           buf_chk-discnt.line-num = 0 and
           buf_chk-discnt.promo-id = ""
           then do:
           if not vflg0
           then do:
             v-discnt-value-abs = 0.
             for each bf_chk-discnt no-lock
                where bf_chk-discnt.doc-code = buf_chk-discnt.doc-code
                  and bf_chk-discnt.record-type = buf_chk-discnt.record-type
                  and bf_chk-discnt.discnt-type = buf_chk-discnt.discnt-type
                  and bf_chk-discnt.value-type = buf_chk-discnt.value-type
                  and bf_chk-discnt.line-num = buf_chk-discnt.line-num
                  :
                  vflg0 = yes.
                  v-discnt-value-abs = v-discnt-value-abs + bf_chk-discnt.discnt-value-abs.
             end.
             insw:start-element ('chk-discnt':U) .
             insw:write-data-element (  "discnt-num",       string(buf_chk-discnt.discnt-id)          ) .
             insw:write-data-element (  "line-num",         string(buf_chk-discnt.line-num)           ) .
             insw:write-data-element (  "discnt-type",      string(buf_chk-discnt.value-type)        ) .
             insw:write-data-element (  "discntValueAbs",   left-trim(string(v-discnt-value-abs,  "->>>>>>>>>9.9<<<<<<<<<"))  ) .
             insw:write-data-element (  "discntValuePcnt",  left-trim(string(0, "->>>>9.9<"))                 ) .
             if buf_chk-discnt.promo-id > "" then
             do:
               find first PromoAction where PromoAction.id =  int(buf_chk-discnt.promo-id) no-lock no-error.
               insw:write-data-element (  "promotion-code", if available PromoAction and PromoAction.ext-code > '' then PromoAction.ext-code else  buf_chk-discnt.promo-id  ) .
             end.
             if buf_chk-discnt.templ-rl-root > 0 then  insw:write-data-element (  "discntGdsReason",       string(buf_chk-discnt.templ-rl-root)          ) .
             insw:end-element ('chk-discnt':U) .
           end.
        end.
        else do:
            insw:start-element ('chk-discnt':U) .
            insw:write-data-element (  "discnt-num",       string(buf_chk-discnt.discnt-id)          ) .
            insw:write-data-element (  "line-num",         string(buf_chk-discnt.line-num)           ) .
            insw:write-data-element (  "discnt-type",      string(buf_chk-discnt.value-type)        ) .
            insw:write-data-element (  "discntValueAbs",   left-trim(string(buf_chk-discnt.discnt-value-abs + v-sum-promo,  "->>>>>>>>>9.9<<<<<<<<<"))  ) .
            insw:write-data-element (  "discntValuePcnt",  left-trim(string(buf_chk-discnt.discnt-value-pcnt + v-pcnt-promo, "->>>>9.9<"))                 ) .
            if buf_chk-discnt.promo-id > "" then
            do:
              find first PromoAction where PromoAction.id =  int(buf_chk-discnt.promo-id) no-lock no-error.
              insw:write-data-element (  "promotion-code", if available PromoAction and PromoAction.ext-code > '' then PromoAction.ext-code else  buf_chk-discnt.promo-id  ) .
            end.
            if buf_chk-discnt.templ-rl-root > 0 then  insw:write-data-element (  "discntGdsReason",       string(buf_chk-discnt.templ-rl-root)          ) .
            insw:end-element ('chk-discnt':U) .
        end.
      end.
      if last-of(buf_chk-discnt.doc-code) then insw:end-element ('chk-discnts':U) .
    end .
    end .
    if v-disc-promo-id <> 0 and
       vflg-disc = no
    then do:
        insw:start-element ('chk-discnts':U) .
        insw:start-element ('chk-discnt':U) .
        insw:write-data-element (  "discnt-num",       "1"    ) .
        insw:write-data-element (  "line-num",         string(v-line-num-promo)  ) .
        insw:write-data-element (  "discnt-type",      "0"    ) .
        insw:write-data-element (  "discntValueAbs",   "0.0"  ) .
        insw:write-data-element (  "discntValuePcnt",  "0.0"  ) .
        find first PromoAction where PromoAction.id =  v-disc-promo-id no-lock no-error.
        insw:write-data-element (  "promotion-code", if available PromoAction and PromoAction.ext-code > '' then PromoAction.ext-code else string(v-disc-promo-id)  ) .
        insw:end-element ('chk-discnt':U) .
        insw:end-element ('chk-discnts':U) .
    end.
    for each buf_chk-discnt no-lock
       where buf_chk-discnt.doc-code    = p-buf_chk-doc.doc-code
         and buf_chk-discnt.record-type = 4
         and buf_chk-discnt.discnt-value-abs <> 0
    break by buf_chk-discnt.doc-code :
      if first-of(buf_chk-discnt.doc-code) then insw:start-element ('chk-bonus-ps':U) .
      insw:start-element ('chk-bonus-p':U) .
      insw:write-data-element (  "chk-line-num",  string(buf_chk-discnt.line-num)  ) .
      insw:write-data-element (  "sum-bonus",     left-trim(string(buf_chk-discnt.discnt-value-abs, "->>>>>>>>9.99"))   ) .
      if buf_chk-discnt.d-card > "" then
      insw:write-data-element (  "dc-num",  buf_chk-discnt.d-card  ) .
      insw:end-element ('chk-bonus-p':U) .
      if last-of(buf_chk-discnt.doc-code) then insw:end-element ('chk-bonus-ps':U) .
    end .
        for each buf_chk-discnt no-lock
       where buf_chk-discnt.doc-code    = p-buf_chk-doc.doc-code
         and buf_chk-discnt.record-type = 5
         and can-do(v-promocode-list, buf_chk-discnt.promo-id)
    break by buf_chk-discnt.doc-code by buf_chk-discnt.promo-id :
      if first-of(buf_chk-discnt.doc-code) then insw:start-element ('chk-promos':U) .
        insw:start-element ('chk-promo':U) .
        find first PromoAction where PromoAction.id =  int(buf_chk-discnt.promo-id) no-lock no-error.
            insw:write-data-element (  "promotion-code", if available PromoAction and PromoAction.ext-code > '' then PromoAction.ext-code else  buf_chk-discnt.promo-id  ) .
            insw:write-data-element (  "promotion-count",     left-trim(string(buf_chk-discnt.object-sum, "->>>>>>>>9.99"))   ) .
       insw:end-element ('chk-promo':U) .
      if last-of(buf_chk-discnt.doc-code) then insw:end-element ('chk-promos':U) .
    end .
   if v-disc-promo-id <> 0
   then do:
      insw:start-element ('chk-promos':U) .
      insw:start-element ('chk-promo':U) .
      find first PromoAction where PromoAction.id =  v-disc-promo-id no-lock no-error.
      insw:write-data-element (  "promotion-code", if available PromoAction and PromoAction.ext-code > '' then PromoAction.ext-code else  string(v-disc-promo-id)  ) .
      insw:write-data-element (  "promotion-count",     left-trim(string(v-disc-promo-count, "->>>>>>>>9.99"))   ) .
      insw:end-element ('chk-promo':U) .
      insw:end-element ('chk-promos':U) .
   end.
    for each buf_chk-gds-pay no-lock
       where buf_chk-gds-pay.doc-code = p-buf_chk-doc.doc-code
    break by buf_chk-gds-pay.doc-code :
      if first-of(buf_chk-gds-pay.doc-code) then insw:start-element ('chk-pays-r':U) .
      insw:start-element ('chk-pay-r':U) .
      insw:write-data-element (  "pay-code",  string(buf_chk-gds-pay.pay-code)    ) .
      insw:write-data-element (  "line-num",  string(buf_chk-gds-pay.line-num)    ) .
      insw:write-data-element (  "pay-num",   string(buf_chk-gds-pay.cpline-num)  ) .
      insw:write-data-element (  "sum",       left-trim(string(buf_chk-gds-pay.tot-r-b,      "->>>>>>>>9.99"))  ) .
      insw:write-data-element (  "qnty",      left-trim(string(buf_chk-gds-pay.eff-doc-qnty, "->>>>>>>>>9.9<<<<<<<<<"))  ) .
      if buf_chk-gds-pay.price-base > 0 then
      insw:write-data-element ( "price-base", left-trim(string(buf_chk-gds-pay.price-base, "->>>>>>>>9.99"))  ) .
      else insw:write-data-element ( "price-base", left-trim(string(0.0, "->>>>>>>>9.99"))  ) .
      if buf_chk-gds-pay.pay-card > "" then
      insw:write-data-element (  "pay-card",               buf_chk-gds-pay.pay-card  ) .
      find first buf_chk-gds-attr no-lock where
                   buf_chk-gds-attr.doc-code = buf_chk-gds-pay.doc-code
               and buf_chk-gds-attr.line-num  = buf_chk-gds-pay.line-num
               and buf_chk-gds-attr.attr-code = "CSPromoSum"
            no-error.
      v-sum-promo = if avail buf_chk-gds-attr then dec(buf_chk-gds-attr.attr-value) else 0 no-error.
      if  v-sum-promo <> 0 and buf_chk-gds-pay.eff-doc-qnty <> 0 then
         insw:write-data-element (  "discntValueAbs",  left-trim(string((buf_chk-gds-pay.discnt + (v-sum-promo / buf_chk-gds-pay.eff-doc-qnty)), "->>>>>>>>>9.9<<<<<<<<<"))  ) .
      else
         insw:write-data-element (  "discntValueAbs",  left-trim(string((buf_chk-gds-pay.discnt), "->>>>>>>>>9.9<<<<<<<<<"))  ) .
      insw:end-element ('chk-pay-r':U) .
      if last-of(buf_chk-gds-pay.doc-code) then insw:end-element ('chk-pays-r':U) .
    end .
    insw:end-element ('check':U) .
  end method .
  method private character timeFormat (p-time as integer) :
    define variable v-tm-format as character initial "hh:mm:ss" no-undo .
    return if (p-time >= 0) then string(p-time, v-tm-format) else "" .
  end method .
  method private character dateFormat (p-date as date) :
    define variable v-dt-format as character initial "99.99.9999" no-undo .
    return if (p-date = ?) then "" else string(p-date, v-dt-format) .
  end method .
  method private character getTankNum (p-obj-type    as character,
                                       p-obj-code    as integer,
                                       p-pump        as integer,
                                       p-nozzle-code as integer,
                                       p-src-pl-code as integer,
                                       p-pl-code     as integer,
                                       p-gds-code    as integer) :
    define buffer buf_place for ub.place .
    define variable v-pl-code as integer no-undo .
    define variable v-loc1    as character no-undo .
         if p-src-pl-code > 0 then v-pl-code = p-src-pl-code.
    else if p-pl-code     > 0 then v-pl-code = p-pl-code.
    else do:
      libFindtank:findtank_
      (input p-obj-type
      ,input p-obj-code
      ,input p-pump
      ,input p-nozzle-code
      ,input p-pl-code
      ,input p-gds-code
      ,output v-pl-code
      ) .
    end .
    if v-pl-code > 0 then do:
      find first buf_place no-lock where buf_place.pl-code = v-pl-code no-error .
      v-loc1 = if available buf_place then string(buf_place.pl-code) else "0" .
    end.
    else v-loc1 = "0" .
    return v-loc1 .
  end method .
  method private character base64-enc ( input v-string as character ) :
    define variable v-base64-encode as character no-undo .
    do
    on error undo, return error return-value
    :
      define variable v-raw     as raw       no-undo .
      define variable v-raw-str as character no-undo .
      if v-string = ?
      then do:
        undo, return error "base64-encode: строка имеет неопределенное значение" .
        end.
        assign
          length(v-raw) = length(v-string) + 1
        .
        assign
          put-string(v-raw, 1) = v-string
        .
        assign
          v-raw-str = string(v-raw)
        .
        assign
          length(v-raw) = 0
        .
        assign
          v-base64-encode = substring(v-raw-str, 7)
        .
    end.
    return v-base64-encode .
  end.
  method private integer get-chk-promo-id (
     input p-obj-code as integer,
     input p-obj-type as character,
     input p-pay-desk as integer,
     input p-doc-num2 as character,
     input p-b-code as integer,
     input p-gds-qnty as decimal,
     output o-disc-promo-line as integer,
     output o-disc-promo-count as integer ) :
    define buffer buf2_chk-doc for ub.chk-doc.
    define buffer buf2_chk-gds for ub.chk-gds.
    define buffer buf2_chk-discnt for ub.chk-discnt.
    define variable v-promo-id as character no-undo .
    v-promo-id = "".
    for first buf2_chk-doc no-lock where
             buf2_chk-doc.obj-code = p-obj-code
         and buf2_chk-doc.obj-type = p-obj-type
         and buf2_chk-doc.pay-desk = p-pay-desk
         and buf2_chk-doc.chk-type = int('1':U)
         and buf2_chk-doc.chk-num  = int(entry(1,p-doc-num2,":"))
         and buf2_chk-doc.z-number = int(entry(2,p-doc-num2,":"))
       :
       find first buf2_chk-gds no-lock where
                  buf2_chk-gds.doc-code = buf2_chk-doc.doc-code
             and  buf2_chk-gds.b-code   = p-b-code
       no-error.
       if avail buf2_chk-gds then do:
           find first buf2_chk-discnt no-lock where
                      buf2_chk-discnt.doc-code =  buf2_chk-doc.doc-code and
                      buf2_chk-discnt.record-type = 1 and
                      buf2_chk-discnt.object-line-num = buf2_chk-gds.line-num and
                      buf2_chk-discnt.promo-id > ""
           no-error .
           if avail buf2_chk-discnt
           then do:
               assign
                 v-promo-id = buf2_chk-discnt.promo-id
                 o-disc-promo-line = buf2_chk-gds.line-num
                 o-disc-promo-count = if buf2_chk-gds.src-qnty <> -1 * p-gds-qnty then 1 else 0
                 .
           end.
       end.
    end.
    return int(v-promo-id) .
  end.
end class.
