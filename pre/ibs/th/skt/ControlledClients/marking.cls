USING Progress.Lang.*.
USING ibs.th.skt.Commands.*.
USING ibs.th.skt.ControlledClients.marking.sts.cash.
USING ibs.th.skt.Adapters.LogWrite.
USING ibs.th.gbl.propmap.
USING ibs.th.gbl.sys.objsrv.
USING ibs.th.gbl.sys.objth.
block-level on error undo, throw.
CLASS ibs.th.skt.ControlledClients.marking INHERITS ICommandProc:
  DEFINE OVERRIDE PUBLIC PROPERTY vss-revision    AS CHARACTER NO-UNDO INIT "$Revision:$":U GET .
  DEFINE OVERRIDE PUBLIC PROPERTY vss-author      AS CHARACTER NO-UNDO INIT "$Author:$":U GET.
  DEFINE OVERRIDE PUBLIC PROPERTY vss-date        AS CHARACTER NO-UNDO INIT "$Date:$":U GET.
  DEFINE OVERRIDE PUBLIC PROPERTY vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile:$":U GET.
  DEFINE OVERRIDE PUBLIC PROPERTY vss-archive     AS CHARACTER NO-UNDO INIT "$Archive:$":U GET.
  DEFINE OVERRIDE PUBLIC PROPERTY vss-description AS CHARACTER NO-UNDO INIT "Обработчик запросов по маркам с кассы" GET.
      DEFINE PRIVATE VARIABLE cashSts    AS CLASS cash     NO-UNDO.
  DEFINE PRIVATE VARIABLE answerFlag AS LOGICAL        NO-UNDO INIT FALSE.
  DEFINE PRIVATE VARIABLE thMarkSts  AS CLASS ibs.th.str.marking.sts.mark NO-UNDO.
  DEFINE PRIVATE VARIABLE EDOParSec AS CLASS ibs.th.gbl.env.prmtrs.edo .
  DEFINE VARIABLE mAsyncHelper AS CLASS ibs.th.file.AsyncHelperth  NO-UNDO.
  DEFINE PRIVATE VARIABLE cash      AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE shift_id  AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE chk_id    AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE cntx_id   AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE mark      AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE action    AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE shift_tbeg AS DATE NO-UNDO.
  DEFINE PRIVATE VARIABLE shift_num  AS INTEGER NO-UNDO.
  DEFINE PRIVATE VARIABLE statusPOS  AS INTEGER NO-UNDO.
  DEFINE PRIVATE VARIABLE isCheckedOffline  AS LOGICAL NO-UNDO.
  DEFINE PRIVATE VARIABLE mMarkOrig     AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE mCheckSts     AS INTEGER   NO-UNDO.
  DEFINE PRIVATE VARIABLE mCheckStsOff  AS INTEGER   NO-UNDO.
  DEFINE PRIVATE VARIABLE mCheckStsSave AS INTEGER   NO-UNDO.
  DEFINE PRIVATE VARIABLE mReqId        AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE mReqTimestamp AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE mInst         AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE mVersion      AS CHARACTER NO-UNDO.
  DEFINE PRIVATE VARIABLE mCheckGisMT   AS INTEGER NO-UNDO.
  DEFINE PRIVATE VARIABLE mSaveOnlineResult AS LOGICAL NO-UNDO.
  DEF STREAM out_s.
  DEF STREAM out_data.
  DEFINE TEMP-TABLE ttmark-body NO-UNDO
     XML-NODE-NAME "body"
     FIELD code            AS INT
     FIELD error-1         AS CHAR XML-NODE-NAME "error"
     FIELD requestid       AS CHAR
     FIELD status-1        AS CHAR XML-NODE-NAME "status"
     FIELD reqid           AS CHAR
     FIELD reqtimestamp    AS INT64
     FIELD timestamp       AS CHAR
     .
  DEFINE TEMP-TABLE ttmark-check NO-UNDO
     XML-NODE-NAME "codes"
     FIELD cis             AS CHAR
     FIELD printView       AS CHAR
     FIELD gtin            AS CHAR
     FIELD verified        AS LOGICAL
     FIELD found           AS LOGICAL
     FIELD realizable      AS LOGICAL
     FIELD utilised        AS LOGICAL
     FIELD isBlocked       AS LOGICAL
     FIELD productionDate  AS CHAR
     FIELD isOwner         AS LOGICAL
     FIELD errorCode       AS INT
     FIELD isTracking      AS LOGICAL
     FIELD sold            AS LOGICAL
     FIELD packageType     AS CHAR
     FIELD producerInn     AS CHAR
     FIELD grayZone        AS LOGICAL
     FIELD mrp             AS INT
     FIELD expireDate      AS DATETIME-TZ
     .
  DEFINE TEMP-TABLE tt-file-name NO-UNDO
     FIELD tmpFileName AS CHAR
     FIELD ofline AS LOG INIT NO
     INDEX tmpFileName tmpFileName
     INDEX ofline ofline.
  DEFINE TEMP-TABLE ttlocal-mark  no-undo serialize-name  "results"
   FIELD reqId        AS CHAR
   FIELD reqTimestamp AS INT64
   FIELD inst         AS CHAR
   FIELD version      AS CHAR
   FIELD description  AS CHAR
   FIELD code         AS INT64
   FIELD errorCode    AS INT64
   FIELD reason       AS CHAR
   .
  DEFINE TEMP-TABLE ttlocal-mark-code  no-undo serialize-name  "codes"
   FIELD code-reqid   AS RECID
   FIELD isBlocked    AS LOG INIT NO
   FIELD sold         AS LOG INIT NO
   FIELD gtin         AS CHAR
   FIELD cis          AS CHAR
   FIELD mrp          AS CHAR
   INDEX reqidpar code-reqid
   .
  DEFINE DATASET gismt-mark-body  XML-NODE-NAME "bodys" FOR ttmark-body.
  DEFINE DATASET gismt-mark-codes XML-NODE-NAME "body"  FOR ttmark-check.
  DEFINE DATASET gismt-local-mark SERIALIZE-HIDDEN  for ttlocal-mark, ttlocal-mark-code
     PARENT-ID-RELATION FOR ttlocal-mark, ttlocal-mark-code PARENT-ID-FIELD code-reqid .
  DEFINE PUBLIC PROPERTY SomeStr AS LONGCHAR NO-UNDO
    GET.
    SET.
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
 define variable gismt-AdressPort   as character no-undo.
 define variable gismt-DopParam     as character no-undo.
 define variable gismt-GisAdress    as character no-undo.
 define variable gismt-ProxyLogin   as character no-undo.
 define variable gismt-ProxyPswd    as character no-undo.
 define variable gismt-MaxTime      as integer   no-undo.
 define variable gismt-RegKey       as character no-undo.
 define variable gismt-TimeFalStart as integer   no-undo.
 define variable gismt-WaitTime     as decimal   no-undo.
 define variable gismt-WaitTimePlus as decimal   no-undo.
 define variable gismt-CrashSituat  as logical   no-undo.
 define variable gismt-BanDate      as integer   no-undo.
 define variable gismt-cdnTurnOn    as logical   no-undo.
 define variable gismt-cdnAdress    as character no-undo.
 define variable gismt-cdnRepeat    as logical   no-undo.
 define variable gismt-cdnChange    as logical   no-undo.
 define variable gismt-cdnTimeUpd   as integer   no-undo.
 define variable gismt-UpdateRequest as logical   no-undo.
 define variable gismt-OflineAdress  as character no-undo.
 define variable gismt-OflineAutoriz as character no-undo.
 define variable gismt-OflineLogin   as character no-undo.
 define variable gismt-OflinePswd    as character no-undo.
 define variable gismt-OflineDate    as date      no-undo.
method public character ConvBase64
(input iString as char):
  define variable vSize       as integer   no-undo.
  define variable vDataDc1    as memptr    no-undo.
  define variable vDataDc2    as memptr    no-undo.
  define variable vEnCode     as character no-undo.
  define variable vBase64Str  as character no-undo.
  do
  on error undo, return error return-value
  :
    if iString = ?
    then return "".
    vSize  = length(iString).
    SET-SIZE(vDataDc1 ) = vSize + 1.
    SET-SIZE(vDataDc2 ) = vSize.
    put-string(vDataDc1, 1, vSize) = iString.
    copy-lob from vDataDc1 starting at 1 for vSize to vDataDc2 no-convert.
    vEnCode =  base64-encode (vDataDc2).
    vBase64Str = substring(vEnCode,1).
    SET-SIZE(vDataDc1)  = 0 no-error.
    SET-SIZE(vDataDc2)  = 0 no-error.
  end.
  return vBase64Str.
end.
method public character get-thbj-attr-prop
(input p-obj-type as char,
 input p-obj-code as int,
 input p-upper-prop-code as char,
 input p-prop-code as char
 ):
    define buffer buf_thbj-attr for ub.thbj-attr.
    define variable v-reg-code as integer no-undo.
    find first buf_thbj-attr no-lock where
               buf_thbj-attr.obj-type = p-obj-type
           and buf_thbj-attr.obj-code = p-obj-code
           and buf_thbj-attr.upper-prop-code = p-upper-prop-code
           and buf_thbj-attr.prop-code = p-prop-code
    no-error.
    if not available buf_thbj-attr and p-obj-type = 'БД':U then
    do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run regcode in ibs.th.gbl.gbl-hndllib:g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-reg-code
  )  .
       if v-reg-code <> ? and v-reg-code <> 0 then do:
           find first buf_thbj-attr no-lock where
                      buf_thbj-attr.obj-type = 'регион':U
                  and buf_thbj-attr.obj-code = v-reg-code
                  and buf_thbj-attr.upper-prop-code = p-upper-prop-code
                  and buf_thbj-attr.prop-code = p-prop-code
           no-error.
       end.
    end.
    if not available buf_thbj-attr and p-obj-type <> ""
    then do:
       find first buf_thbj-attr no-lock where
                  buf_thbj-attr.obj-type = ""
              and buf_thbj-attr.obj-code = 0
              and buf_thbj-attr.upper-prop-code = p-upper-prop-code
              and buf_thbj-attr.prop-code = p-prop-code
       no-error.
    end.
    if avail buf_thbj-attr then do:
        case buf_thbj-attr.prop-value-type:
            when "character"
               then return buf_thbj-attr.property-value-character.
            when "integer"
               then return string(buf_thbj-attr.property-value-integer).
            when "decimal"
               then return string(buf_thbj-attr.property-value-decimal).
            when "logical"
               then return string(buf_thbj-attr.property-value-logical).
        end case.
    end.
    return "".
end.
method public character get-gismt-prop
(input p-obj-type as char,
 input p-obj-code as int):
    define buffer buf_code for ub.code.
    define buffer buf_thbj-attr for ub.thbj-attr.
    assign
       gismt-AdressPort = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'adressPort':U)
       gismt-DopParam   = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'dopParam':U)
       gismt-GisAdress  = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'gisAdress':U)
       gismt-ProxyLogin = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'proxyLogin':U)
       gismt-ProxyPswd  = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'proxyPswd':U)
       gismt-MaxTime    = integer(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'maxTime':U))
       gismt-RegKey     = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'regKey':U)
       gismt-TimeFalStart = integer(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'timeFalStart':U))
       gismt-WaitTime    = decimal(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'waitTime':U))
       gismt-CrashSituat = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'crashSituat':U))
       gismt-BanDate     = integer(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'banDate':U))
       gismt-cdnTurnOn   = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'cdnTurnOn':U))
       gismt-cdnAdress   = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'cdnAdress':U)
       gismt-cdnRepeat   = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'cdnRepeat':U))
       gismt-cdnChange   = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'cdnChange':U))
       gismt-cdnTimeUpd  = integer(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'cdnTimeUpdate':U))
       gismt-UpdateRequest = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'UpdateRequest':U))
       gismt-OflineAdress  = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'OflineAdress':U)
       gismt-OflineLogin   = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'OflineLogin':U)
       gismt-OflinePswd    = get-thbj-attr-prop(p-obj-type,p-obj-code,'gisMT':U,'OflinePswd':U)
       .
    if gismt-OflineLogin <> "" and gismt-OflinePswd <> ""
    then gismt-OflineAutoriz = ConvBase64(gismt-OflineLogin + ":" + gismt-OflinePswd).
    find first buf_code no-lock where
               buf_code.parent eq "GisMtOffline"
           and buf_code.code   eq string(p-obj-code)
       no-error.
    if not avail buf_code then
    find first buf_code no-lock where
               buf_code.parent eq "GisMtOffline"
           and buf_code.code   eq "0"
       no-error.
    if avail buf_code then  gismt-OflineDate = date(buf_code.CodeValue) no-error.
    else gismt-OflineDate = today.
  return "".
end.
  CONSTRUCTOR PUBLIC marking (  ):
    SUPER ().
    DEFINE BUFFER buf_sys-ctrl FOR ub.sys-ctrl .
    DEFINE VARIABLE vRetProp AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vCdnAdr AS CHARACTER NO-UNDO.
    FIND FIRST buf_sys-ctrl NO-LOCK NO-ERROR.
    IF AVAILABLE buf_sys-ctrl AND buf_sys-ctrl.db-num <> 0
    THEN DO:
       dbgPrint("marking.log", SUBSTITUTE("База &1 номер: &2", "'БД':U", buf_sys-ctrl.db-num)).
       vRetProp = get-gismt-prop ('БД':U,
                                  buf_sys-ctrl.db-num) NO-ERROR.
    END.
    ELSE DO:
       dbgPrint("marking.log", "Не определена БД").
    END.
    cashSts =  NEW cash().
  END.
  METHOD PUBLIC VOID hndler (req AS CLASS ibs.th.skt.Commands.iRequest):
    DEFINE VARIABLE vLC       AS LONGCHAR  NO-UNDO.
    DEFINE VARIABLE ii        AS INTEGER   NO-UNDO.
    DEFINE VARIABLE n         AS INTEGER   NO-UNDO.
    DEFINE VARIABLE mark-short AS CHARACTER NO-UNDO.
    DEFINE VARIABLE par       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE val       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE km        AS CHARACTER NO-UNDO.
    DEFINE BUFFER buf_marking FOR ub.marking.
    DEFINE BUFFER buf_marking-l FOR ub.marking-lines.
    DEFINE VARIABLE newSts    AS INTEGER   NO-UNDO.
    DEFINE VARIABLE obj-code  AS INTEGER NO-UNDO.
    DEFINE VARIABLE gdsCode   AS INTEGER NO-UNDO.
    DEFINE VARIABLE canSaleReturnedGoods AS LOGICAL NO-UNDO INIT FALSE.
    DEFINE VARIABLE listActions           AS CHARACTER NO-UNDO.
    DEFINE VARIABLE listActionsByMark     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE listActionsUnlock     AS CHARACTER NO-UNDO.
    DEFINE VARIABLE listStatusesForSale   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE listStatusesForSaleWithReturn AS CHARACTER NO-UNDO.
    DEFINE VARIABLE listStatusesForReturn AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vAccMarkCheck AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vAccMarkCheckOff AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vCheckLocalMark  AS LOGICAl NO-UNDO INIT FALSE.
    ASSIGN
      mCheckSts = 1
      mReqId        = ""
      mReqTimeStamp = ""
      mInst         = ""
      mVersion      = ""
      answerFlag = FALSE
      cash       = ""
      shift_id   = ""
      chk_id     = ""
      cntx_id    = ""
      mark       = ""
      action     = ""
      shift_tbeg = ?
      shift_num  = 0
      gismt-WaitTimePlus = 0
      statusPOS = ?
      mSaveOnlineResult = no
    .
    thMarkSts = ObjSrv:Env:Marking:Sts:Mark.
    fix-codepage(vLC) = "UTF-8".
    LogWrite:LogStr = SUBSTITUTE("Авторизация маркированной продукции &1",
      req:QueryPar).
    ASSIGN
      listActionsByMark = SUBSTITUTE("&1,&2",
        cashSts:SaleLock:NameProp,
        cashSts:ReturnLock:NameProp
      )
      listActionsUnlock = cashSts:Unlock:NameProp
      listActions = SUBSTITUTE("&1,&2,&3,&4",
        listActionsByMark,
        listActionsUnlock,
        cashSts:UnlockAll:NameProp,
        cashSts:Commit:NameProp
      )
    .
    n = NUM-ENTRIES (req:QueryPar, "&").
    DO ii = 1 TO n:
      ASSIGN
        par = ENTRY (1, ENTRY (ii, req:QueryPar, "&"), "=")
        val = ENTRY (2, ENTRY (ii, req:QueryPar, "&"), "=")
    no-error.
      IF ERROR-STATUS:ERROR
        THEN
      DO:
        vLC = CHR(123) + '"server_error":"Неверные параметры запроса."' + chr(125).
        sendContent(vLC).
        RETURN.
      END.
      CASE par:
        WHEN "cash" THEN
          DO:
            cash = val.
          END.
        WHEN "shift_id" THEN
          DO:
            shift_id = val.
          END.
        WHEN "check" THEN
          DO:
            chk_id = val.
          END.
        WHEN "mark" THEN
          DO:
            mMarkOrig = val.
            mark = percentDecoding (val).
          END.
        WHEN "context" THEN
          DO:
            cntx_id = val.
          END.
        WHEN "set" THEN
          DO:
            IF LOOKUP (val,listActions) = 0
              THEN
            DO:
              vLC = CHR(123) + substitute('"server_error":"Неверный тип &1 параметра set."', val) + chr(125).
              sendContent(vLC).
              RETURN.
            END.
            action = val.
          END.
        WHEN "shift_tbeg" THEN
          DO:
            shift_tbeg = DATE (INTEGER (SUBSTRING (val, 03, 2)), INTEGER (SUBSTRING (val, 01, 2)), INTEGER (SUBSTRING (val, 05, 4))) NO-ERROR.
          END.
        WHEN "shift_num" THEN
          DO:
            shift_num = int (val) NO-ERROR.
          END.
        WHEN "StatusPos" THEN
          DO:
            statusPOS = int (val) NO-ERROR.
          END.
        WHEN "isCheckedOffline" THEN
          DO:
            isCheckedOffline = logical (val) NO-ERROR.
          END.
      END CASE.
    END.
    IF cash = "" OR action = ""
      THEN
    DO:
      vLC = CHR(123) + substitute('"server_error":"Неверные параметры запроса."') + chr(125).
      sendContent(vLC).
      RETURN.
    END.
    obj-code = getObject(INTEGER(cash)).
    IF obj-code = ? THEN
    DO:
      vLC = CHR(123) + substitute('"server_error":"Не удалось определить магазин по кассе &1."', cash) + chr(125).
      sendContent(vLC).
      RETURN.
    END.
    EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO('маг':U, obj-code).
    CASE TRUE:
      WHEN CAN-DO(listActionsByMark,action) OR (CAN-DO(listActionsUnlock,action) AND mark <> "") THEN
      DO:
        IF mark = "" THEN DO:
          vLC = CHR(123) + substitute('"server_error":"Неверные параметры запроса. Не заполнен mark."') + chr(125).
          sendContent(vLC).
          RETURN.
        END.
        mark-short = GetCodeIdent(mark).
        IF mark-short = "" OR mark-short = ? THEN DO:
          vLC = CHR(123) + substitute('"server_error":"Неверные параметры запроса. Некорректный код марки."') + chr(125).
          sendContent(vLC).
          RETURN.
        END.
        FIND FIRST buf_marking EXCLUSIVE-LOCK WHERE buf_marking.mark BEGINS mark-short NO-WAIT NO-ERROR.
        IF action = cashSts:SaleLock:NameProp THEN
        DO:
           assign
              mCheckGisMT = 0
              mTypeMark = ""
              .
           ChekTypeMarkByDm(mark).
           if statusPOS <> ? then do:
               dbgPrint("marking.log", SUBSTITUTE("Проверка ГИС МТ была на кассе. Статус: &1 Проверка в ЛМЧЗ &2",
                                                  statusPOS,
                                                  isCheckedOffline
                                                  )).
               assign
                  vCheckLocalMark = isCheckedOffline
                  mCheckSts = statusPOS
                  .
               if not isCheckedOffline
               then do:
                   mCheckGisMT = 1.
                   if mCheckSts = 0 then
                      vAccMarkCheck = "Запрет онлайн".
                   mCheckStsSave = mCheckSts .
               end.
               else do:
                   if mCheckSts = 0 then do:
                      vLC = getJson(0, vAccMarkCheck, mark).
                      sendContent(vLC).
                      RETURN.
                   end.
                   IF AVAIL buf_marking AND buf_marking.online-result = 0
                   THEN DO:
                       vAccMarkCheck = "Выполнить текущую онлайн-проверку не удалось. Продажа заблокирована по результату ранее выполненной проверки.".
                       vLC = getJson(0, vAccMarkCheck, mark).
                       sendContent(vLC).
                       RETURN.
                   END.
               end.
               if mCheckSts = 1 or mCheckSts = 2
               then do:
                   vAccMarkCheckOff = ChekExpirationDate('маг':U,obj-code,buffer buf_marking).
                   vAccMarkCheck = vAccMarkCheckOff.
               end.
               dbgPrint("marking.log", SUBSTITUTE("Результат после обработки статуса с кассы: Комментарий: &1 Статус: &2 Проверка в ЛМЧЗ &3 mCheckGisMT &4 ",
                                                  vAccMarkCheck,
                                                  mCheckSts,
                                                  vCheckLocalMark,
                                                  mCheckGisMT
                                                  )).
           end.
           else do:
               vAccMarkCheck = ChekAccessMark('маг':U,obj-code,mark,mark-short).
               dbgPrint("marking.log", SUBSTITUTE("Проверка ГИС МТ: &1 Статус: &2 mReqId &3 mReqTimeStamp &4 mCheckGisMT &5",
                                                  vAccMarkCheck,
                                                  mCheckSts,
                                                  mReqId,
                                                  mReqTimeStamp,
                                                  mCheckGisMT)).
               IF mCheckSts = 0 OR
                  mCheckSts = 3
               THEN DO:
                  vAccMarkCheck = vAccMarkCheck + "Снимите с продажи и передайте товар управляющему/старшему смены".
               END.
               IF mCheckSts = 4 THEN DO:
                  vLC = getJson(0, vAccMarkCheck, mark).
                  sendContent(vLC).
                  RETURN.
               END.
               IF (mCheckSts = 2 AND mCheckGisMT <> 1) OR mCheckGisMT = 2 THEN DO:
                  dbgPrint("marking.log", SUBSTITUTE("Считываем online-result: &1.",
                                                    IF NOT AVAIL buf_marking THEN "marking не найдена"
                                                    ELSE STRING(buf_marking.online-result))).
                  IF AVAIL buf_marking AND buf_marking.online-result = 0
                  THEN DO:
                      vAccMarkCheck = "Выполнить текущую онлайн-проверку не удалось. Продажа заблокирована по результату ранее выполненной проверки. Снимите с продажи и передайте товар управляющему/старшему смены".
                      vLC = getJson(0, vAccMarkCheck, mark).
                      sendContent(vLC).
                      RETURN.
                  END.
                  ELSE DO:
                      vAccMarkCheckOff = ChekLocalMark(mark-short).
                      vCheckLocalMark = TRUE.
                      if vAccMarkCheckOff = "" and
                         mCheckSts = 2 and
                         available buf_marking
                      then
                         vAccMarkCheckOff = ChekExpirationDate('маг':U,obj-code,buffer buf_marking).
                      if vAccMarkCheckOff <> "" and vAccMarkCheck begins "Сообщите"
                      then vAccMarkCheck = vAccMarkCheckOff + " Также с" + substring(vAccMarkCheck,2).
                      else vAccMarkCheck = vAccMarkCheckOff + vAccMarkCheck.
                  END.
              END.
           END.
        END.
        IF NOT AVAILABLE (buf_marking) THEN
        DO:
          IF LOCKED buf_marking THEN DO:
             vLC = getJson(0, "С маркой " + mark-short + " уже работают. ", mark).
             sendContent(vLC).
             RETURN.
          END.
          CASE action:
            WHEN cashSts:SaleLock:NameProp THEN
            DO:
              createMark(mark-short, buffer buf_marking).
              IF NOT vCheckLocalMark
                 AND AVAILABLE buf_marking
              THEN DO:
                setOnlineResult(BUFFER buf_marking).
              END.
              IF mCheckSts = 0 OR
                 mCheckSts = 3
              THEN DO:
                 vLC = getJson(0, vAccMarkCheck, mark).
                 sendContent(vLC).
                 RETURN.
              END.
              IF AVAILABLE buf_marking THEN
                answerFlag = TRUE.
              vLC = setMarkStatus (
                thMarkSts:SaleWaitLock:KeyIntDB,
                "cash:" +  cash + ":" + "context:" + cntx_id,
                IF mCheckSts = 2 THEN vAccMarkCheck ELSE cashSts:SaleLock:Label_,
                cashSts:NotAccessible:Label_,
                buffer buf_marking).
            END.
            WHEN cashSts:ReturnLock:NameProp THEN
            DO:
              createMark(mark-short, buffer buf_marking).
              IF AVAILABLE buf_marking THEN
                answerFlag = TRUE.
              vLC = setMarkStatus (
                thMarkSts:ReturnWaitLock:KeyIntDB,
                "cash:" +  cash + ":" + "context:" + cntx_id,
                cashSts:ReturnLock:Label_,
                cashSts:NotAccessibleRet:Label_,
                buffer buf_marking).
            END.
            OTHERWISE
            DO:
              vLC = getJson(0, "Операция невозможна. Марка не найдена.", mark).
            END.
          END CASE.
        END.
        ELSE
        DO:
          IF  action = cashSts:SaleLock:NameProp
          AND NOT vCheckLocalMark THEN
            setOnlineResult(BUFFER buf_marking).
          IF action = cashSts:SaleLock:NameProp AND
             (mCheckSts = 0 OR mCheckSts = 3)
          THEN DO:
                 vLC = getJson(0, vAccMarkCheck, mark).
                 sendContent(vLC).
                 RETURN.
          END.
          IF (action = cashSts:SaleLock:NameProp OR action = cashSts:ReturnLock:NameProp)
             AND (buf_marking.sts = thMarkSts:SaleWaitLock:KeyIntDB OR buf_marking.sts = thMarkSts:ReturnWaitLock:KeyIntDB)
             AND buf_marking.loc-key BEGINS "cash"
          THEN DO:
            vLC = getJson(0, SUBSTITUTE (
              "Операция невозможна. Статус марки - &1 на кассе &2",
              thMarkSts:GetLabel(buf_marking.sts),
              TRIM(ENTRY(2, buf_marking.loc-key, ":"))),
              mark
            ).
            sendContent(vLC).
            RETURN.
          END.
          ChekTypeMarkByDm(mark).
          IF mTypeMark <> "" THEN
            canSaleReturnedGoods = EDOParSec:GetIsSaleReturnForType(mTypeMark).
          ASSIGN
            listStatusesForSale = SUBSTITUTE("&1,&2",thMarkSts:Checked_:KeyIntDB,thMarkSts:FreeZone:KeyIntDB)
            listStatusesForSaleWithReturn = SUBSTITUTE("&1,&2",listStatusesForSale,thMarkSts:ReturnLock:KeyIntDB)
            listStatusesForReturn = SUBSTITUTE("&1,&2",listStatusesForSale,thMarkSts:SaleLock:KeyIntDB)
          .
          CASE action:
            WHEN cashSts:SaleLock:NameProp THEN
            DO:
              IF CAN-DO(
                IF canSaleReturnedGoods THEN listStatusesForSaleWithReturn ELSE listStatusesForSale,
                STRING(buf_marking.sts)
              ) THEN
              DO:
                answerFlag = TRUE.
              END.
              vLC = setMarkStatus (
                thMarkSts:SaleWaitLock:KeyIntDB,
                "cash:" +  cash + ":" + "context:" + cntx_id,
                IF mCheckSts = 2 THEN vAccMarkCheck ELSE cashSts:SaleLock:Label_,
                SUBSTITUTE ("Операция невозможна. Статус марки - &1.", thMarkSts:GetProp(buf_marking.sts):Label_),
                buffer buf_marking).
            END.
            WHEN cashSts:ReturnLock:NameProp THEN
            DO:
              IF CAN-DO(listStatusesForReturn, STRING(buf_marking.sts)) THEN
              DO:
                answerFlag = TRUE.
              END.
              vLC = setMarkStatus (
                thMarkSts:ReturnWaitLock:KeyIntDB,
                "cash:" +  cash + ":" + "context:" + cntx_id,
                cashSts:ReturnLock:Label_,
                SUBSTITUTE ("Операция невозможна. Статус марки - &1.", thMarkSts:GetProp(buf_marking.sts):Label_),
                buffer buf_marking).
            END.
            WHEN cashSts:Unlock:NameProp THEN
            DO:
              IF buf_marking.loc-key = "" OR buf_marking.loc-key BEGINS "cash:" + cash
              THEN DO:
                answerFlag = TRUE.
                vLC = setMarkStatus (
                  IF buf_marking.sts = thMarkSts:SaleWaitLock:KeyIntDB THEN thMarkSts:FreeZone:KeyIntDB ELSE thMarkSts:SaleLock:KeyIntDB,
                  "",
                  cashSts:Unlock:Label_,
                  SUBSTITUTE ("Операция невозможна. Статус марки - &1.", thMarkSts:GetProp(buf_marking.sts):Label_),
                  buffer buf_marking).
              END.
              ELSE DO:
                vLC = getJson(0, SUBSTITUTE ("Операция невозможна. Статус марки - &1.", thMarkSts:GetProp(buf_marking.sts):Label_), mark).
              END.
            END.
          END CASE.
        END.
      END.
      WHEN CAN-DO(listActionsUnlock,action) AND mark = "" THEN
      DO:
        answerFlag = TRUE.
        IF cntx_id = "" THEN
          vLC = unlockMarks("cash:" +  cash).
        ELSE
          vLC = unlockMarks("cash:" +  cash + ":" + "context:" + cntx_id).
      END.
      WHEN action = cashSts:Commit:NameProp THEN
      DO:
        answerFlag = TRUE.
        vLC = commitCheck().
      END.
      WHEN action = cashSts:UnlockAll:NameProp THEN
      DO:
        answerFlag = TRUE.
        vLC = unlockMarks("cash:" +  cash).
      END.
    END CASE.
    sendContent(vLC).
    RETURN.
  END METHOD.
  METHOD PUBLIC CHARACTER percentDecoding(encode-str AS CHAR):
    DEF VAR ii         AS INT.
    DEF VAR decode-str AS CHAR.
    DEF VAR entry-str  AS CHAR.
    decode-str = ENTRY (1, encode-str, "%").
    DO ii = 2 TO NUM-ENTRIES (encode-str,"%"):
      entry-str = ENTRY (ii, encode-str, "%").
      decode-str = decode-str + (IF entry-str <> "" THEN STRING (HEX-DECODE (SUBSTRING (entry-str, 1, 2))) + substring (entry-str, 3, LENGTH (entry-str)) ELSE "%").
    END.
    RETURN decode-str.
  END METHOD.
  METHOD PRIVATE VOID sendContent(inLC AS LONGCHAR):
    DEFINE VARIABLE v-cont-length AS INTEGER NO-UNDO.
    inLC = inLC + chr(13) + chr(10).
    v-cont-length = LENGTH(inLC,"RAW":U).
    SomeStr = SUBSTITUTE("HTTP/1.1 200 OK&1Server: 4GL&1Content-Type: text/html; charset=UTF-8&1Content-Length: &3&2&4",chr(13) + chr(10),chr(13) + chr(10)  + chr(13) + chr(10),STRING(v-cont-length),inLC).
    RETURN.
  END METHOD.
  METHOD PRIVATE CHARACTER getJson(stsInt AS INT, msg AS CHAR, mark AS CHAR):
    DEF VAR json-str AS CHAR NO-UNDO.
    mark = REPLACE (mark, '\', '\\').
    mark = REPLACE (mark, '"', '\"').
    IF stsInt = 1 AND mCheckSts = 2
    THEN stsInt = 2.
    json-str = CHR(123) + substitute ('"status":&1,"comment":"&2","reqid":"&3","reqtimestamp":"&4","inst":"&5","ver":"&6"',
                                       stsInt, msg, mReqId, mReqTimestamp, mInst, mVersion)
               + CHR(125).
    RETURN json-str.
  END.
  METHOD PRIVATE CHARACTER setMarkStatus (
    state AS INTEGER,
    loc-key AS CHARACTER,
    msgOk   AS CHARACTER,
    msgError AS CHARACTER,
    buffer buf_marking FOR ub.marking
  ):
    IF answerFlag THEN
    DO:
      ASSIGN
        buf_marking.loc-key = loc-key
        buf_marking.sts = state
        buf_marking.last-change = NOW
      .
      ObjSrv:Lib:MarkingTree:UnGroupMark(buf_marking.mark).
      ObjSrv:Lib:MarkingTree:LockChkChildeMark(buf_marking.mark).
      RETURN getJson(1, msgOk , buf_marking.mark).
    END.
    RETURN getJson(0, msgError, buf_marking.mark).
  END METHOD.
  METHOD PRIVATE VOID createMark (
    mark AS CHARACTER,
    buffer buf_marking FOR ub.marking
  ):
    CREATE buf_marking.
    ASSIGN
      buf_marking.mark    = mark
      buf_marking.sts     = thMarkSts:FreeZone:KeyIntDB
    .
  END METHOD.
  METHOD PRIVATE VOID setShift (
    mark AS CHARACTER,
    shiftBeg AS DATE,
    shiftNum AS INTEGER
  ):
    DEFINE BUFFER buf_marking-attr FOR ub.marking-attr.
    IF shiftBeg NE ?
    THEN DO:
      FIND FIRST buf_marking-attr WHERE buf_marking-attr.mark = mark AND buf_marking-attr.attr-code = "shift-date" NO-ERROR.
      IF NOT AVAILABLE buf_marking-attr
      THEN DO:
        CREATE buf_marking-attr.
        buf_marking-attr.mark = mark.
        buf_marking-attr.attr-code = "shift-date".
      END.
      buf_marking-attr.attr-value = STRING (shiftBeg).
    END.
    IF shiftNum NE ?
    THEN DO:
      FIND FIRST buf_marking-attr WHERE buf_marking-attr.mark = mark AND buf_marking-attr.attr-code = "shift-num" NO-ERROR.
      IF NOT AVAILABLE buf_marking-attr
      THEN DO:
        CREATE buf_marking-attr.
        buf_marking-attr.mark = mark.
        buf_marking-attr.attr-code = "shift-num".
      END.
      buf_marking-attr.attr-value = STRING (shiftNum).
    END.
  END METHOD.
  METHOD PRIVATE INTEGER getObject (
    cash AS INTEGER
  ):
    DEFINE BUFFER buf_cash-desk FOR ub.cash-desk.
    FIND buf_cash-desk WHERE buf_cash-desk.cash-num = cash NO-LOCK NO-ERROR.
    RETURN IF AVAILABLE buf_cash-desk THEN buf_cash-desk.obj-code ELSE ?.
  END METHOD.
  METHOD OVERRIDE PUBLIC VOID Execute_(req AS CLASS IRequest, resp AS CLASS IResponse):
  END METHOD.
  METHOD PRIVATE CHARACTER unlockMarks (
    loc-key AS CHARACTER
  ):
    DEFINE VARIABLE newSts    AS INTEGER   NO-UNDO.
    DEFINE BUFFER buf_marking FOR ub.marking.
    DEFINE BUFFER buf_marking-l FOR ub.marking-lines.
    REPEAT PRESELECT EACH buf_marking EXCLUSIVE-LOCK WHERE
             buf_marking.loc-key BEGINS loc-key
             AND lookup("chk_num",buf_marking.loc-key,":") = 0
             :
      FIND NEXT buf_marking.
      IF ObjSrv:Lib:MarkingTree:LevelDown(buf_marking.mark)
      THEN DO:
          setMarkStatus (
            IF buf_marking.sts = thMarkSts:SaleWaitLock:KeyIntDB THEN thMarkSts:FreeZone:KeyIntDB ELSE thMarkSts:SaleLock:KeyIntDB,
            "",
            "",
            "",
            buffer buf_marking)
          .
          setShift(buf_marking.mark, shift_tbeg, shift_num).
      END.
    END.
    REPEAT PRESELECT EACH buf_marking EXCLUSIVE-LOCK WHERE
             buf_marking.loc-key BEGINS loc-key
             AND lookup("chk_num",buf_marking.loc-key,":") = 0
             :
      FIND NEXT buf_marking.
      setMarkStatus (
        IF buf_marking.sts = thMarkSts:SaleWaitLock:KeyIntDB THEN thMarkSts:FreeZone:KeyIntDB ELSE thMarkSts:SaleLock:KeyIntDB,
        "",
        "",
        "",
        buffer buf_marking)
      .
      setShift(buf_marking.mark, shift_tbeg, shift_num).
    END.
    RETURN getJson(1, cashSts:UnlockAll:Label_, mark).
  END METHOD.
  METHOD PRIVATE CHARACTER commitCheck ():
    DEFINE BUFFER buf_marking FOR ub.marking.
    DEFINE VARIABLE vCnt AS INT NO-UNDO.
    vCnt = 0.
    REPEAT PRESELECT EACH buf_marking EXCLUSIVE-LOCK WHERE buf_marking.loc-key = "cash:" +  cash + ":" + "context:" + cntx_id:
      FIND NEXT buf_marking.
      IF ObjSrv:Lib:MarkingTree:LevelDown(buf_marking.mark)
      THEN DO:
         setMarkStatus (
            IF buf_marking.sts = thMarkSts:SaleWaitLock:KeyIntDB THEN thMarkSts:SaleLock:KeyIntDB ELSE thMarkSts:ReturnLock:KeyIntDB,
            "cash:" +  cash + ":" + "context:" + cntx_id + ":" + "chk_num:" + chk_id,
            "",
            "",
            buffer buf_marking)
         .
         setShift(buf_marking.mark, shift_tbeg, shift_num).
         vCnt = vCnt + 1.
      END.
    END.
    REPEAT PRESELECT EACH buf_marking EXCLUSIVE-LOCK WHERE buf_marking.loc-key = "cash:" +  cash + ":" + "context:" + cntx_id:
      FIND NEXT buf_marking.
      setMarkStatus (
        IF buf_marking.sts = thMarkSts:SaleWaitLock:KeyIntDB THEN thMarkSts:SaleLock:KeyIntDB ELSE thMarkSts:ReturnLock:KeyIntDB,
        "cash:" +  cash + ":" + "context:" + cntx_id + ":" + "chk_num:" + chk_id,
        "",
        "",
        buffer buf_marking)
      .
      setShift(buf_marking.mark, shift_tbeg, shift_num).
      vCnt = vCnt + 1.
    END.
    RETURN IF vCnt = 0
      THEN getJson(0, "По данной кассе не было маркированого товара", mark)
      ELSE getJson(1, cashSts:Commit:Label_ + " Зарезервировано кол-во " + string (vCnt), mark).
  END METHOD.
  METHOD PRIVATE CHARACTER FixErrGisMT ():
    DEFINE VARIABLE vErrSts AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vTimeBegErr AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vTimeAvail  AS INTEGER     NO-UNDO.
    DEFINE BUFFER buf_code FOR ub.code.
    ASSIGN
       mCheckSts = 2
       vErrSts = ""
       .
    fixerr:
    DO TRANSACTION ON ERROR UNDO, RETRY fixerr:
       FIND FIRST buf_code WHERE buf_code.parent EQ "GisMt"
                             AND buf_code.code   EQ "GisMtErr"
          NO-LOCK NO-ERROR.
       IF NOT AVAILABLE buf_code
       THEN DO:
           dbgPrint("marking.log", "Создаем новый справочник для фиксации времени сбоя онлайн-проверки КМ").
          FIND FIRST buf_code WHERE buf_code.parent EQ ""
                           AND buf_code.code   EQ "GisMt"
          NO-LOCK NO-ERROR.
          IF NOT AVAILABLE buf_code THEN DO:
            CREATE buf_code.
            ASSIGN
               buf_code.parent = ""
               buf_code.code = "GisMt"
               buf_code.codename = "Cбой онлайн-проверки КМ"
               .
            RELEASE buf_code NO-ERROR.
          END.
          CREATE buf_code.
          ASSIGN
            buf_code.parent = "GisMt"
            buf_code.code = "GisMtErr"
            buf_code.codename = "Время сбоя онлайн-проверки КМ"
            buf_code.codevalue = STRING(NOW)
            .
          RELEASE buf_code NO-ERROR.
       END.
       ELSE DO:
          dbgPrint("marking.log", "Текущее временя сбоя ГИС МТ: " + buf_code.codevalue).
          IF buf_code.codevalue > "" THEN DO:
             vTimeBegErr = DATETIME-TZ(buf_code.codevalue) NO-ERROR.
             IF gismt-MaxTime <> ? AND
                gismt-TimeFalStart <> ? AND
                vTimeBegErr <> ?
             THEN DO:
                IF vTimeBegErr + gismt-MaxTime * 3600000 < NOW
                THEN DO:
                   ASSIGN
                      mCheckSts = 4
                      vErrSts = "С момента начала сбоя онлайн-проверки прошло более "
                                + string(gismt-MaxTime)
                                + " часов, реализация маркированных товаров невозможна. "
                      .
                END.
                ELSE IF vTimeBegErr + gismt-TimeFalStart * 3600000 <= NOW
                THEN DO:
                   ASSIGN
                      vTimeAvail = ROUND((vTimeBegErr + gismt-MaxTime * 3600000 - NOW) / 3600000,0)
                      vErrSts = "Сообщите управляющему, что до блокировки продаж маркированных товаров из-за недоступности Честного знака осталось: "
                                + string(vTimeAvail) + " ч. "
                      .
                END.
             END.
          END.
          IF (buf_code.codevalue > "" AND vTimeBegErr = ?)
           OR buf_code.codevalue = "" THEN
          DO:
              FIND FIRST buf_code WHERE buf_code.parent EQ "GisMt"
                           AND buf_code.code   EQ "GisMtErr"
              EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
              IF AVAIL buf_code THEN
              DO:
                buf_code.codevalue = STRING(NOW).
                dbgPrint("marking.log", "Фиксация времени сбоя ГИС МТ: " + buf_code.codevalue).
                RELEASE buf_code NO-ERROR.
                IF ERROR-STATUS:ERROR THEN
                   dbgPrint("marking.log", "Ошибка фиксации времени сбоя ГИС МТ: " + ERROR-STATUS:GET-MESSAGE(1)).
              END.
              ELSE IF LOCKED buf_code THEN
              DO:
                 dbgPrint("marking.log", "Ошибка фиксации времени сбоя ГИС МТ - запись заблокирована").
              END.
          END.
       END.
    END.
    IF RETRY THEN DO:
        dbgPrint("marking.log", "Ошибка фиксации времени сбоя ГИС МТ").
    END.
    RETURN vErrSts.
  END METHOD.
  METHOD PRIVATE VOID SetNoErrGisMT ():
     DEF BUFFER buf_code FOR ub.code.
      FIND FIRST buf_code WHERE
                 buf_code.parent EQ "GisMt"
             AND buf_code.code   EQ "GisMtErr"
         NO-LOCK NO-ERROR.
      if avail buf_code and buf_code.codevalue <> "" then
      do:
          setnoerr:
          DO TRANSACTION ON ERROR UNDO, RETRY setnoerr:
             FIND FIRST buf_code WHERE buf_code.parent EQ "GisMt"
                                   AND buf_code.code   EQ "GisMtErr"
                EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
             IF AVAILABLE buf_code
             THEN DO:
                buf_code.codevalue = "".
                release buf_code no-error.
             END.
             ELSE IF LOCKED buf_code THEN
                dbgPrint("marking.log", "Запись в справочнике для сброса времени сбоя ГИС МТ заблокирована").
          END.
          IF RETRY THEN DO:
             dbgPrint("marking.log", "Ошибка сброса времени сбоя ГИС МТ").
          END.
      end.
  END METHOD.
  METHOD PRIVATE LOGICAL GetMarkProp (
     p-obj-type  AS CHARACTER,
     p-obj-code  AS INTEGER,
     p-param-code AS CHARACTER,
     p-type-mark AS CHARACTER
     ):
      DEFINE VARIABLE v-value-character AS CHARACTER NO-UNDO.
      v-value-character = get-thbj-attr-prop(p-obj-type,p-obj-code,'marking':U,p-param-code).
      dbgPrint("marking.log", SUBSTITUTE("Тип маркировки: p-param-code &1 v-value-character &2 тип маркировки &3",
                                         p-param-code,
                                         v-value-character,
                                         p-type-mark)).
      IF LOOKUP (p-type-mark,v-value-character) > 0
      THEN RETURN YES.
      ELSE RETURN NO.
  END METHOD.
  METHOD PRIVATE INTEGER GetGisMTCheck (
     p-obj-type  AS CHARACTER,
     p-obj-code  AS INTEGER,
     mark AS CHARACTER,
     mark-short AS CHARACTER
  ):
    DEFINE VARIABLE vInn           AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vErrSts        AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cmd            AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cmdlog         AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE CmdParamProxy  AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vFileToken     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vFileBat       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vFileResult    AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vFileResultCnv AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vFileResultErr AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vFileresultXml AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vFileLog       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vlongJson      AS LONGCHAR    NO-UNDO CASE-SENSITIVE.
    DEFINE VARIABLE vlongJsonError AS LONGCHAR    NO-UNDO CASE-SENSITIVE.
    DEFINE VARIABLE vMark          AS CHARACTER   NO-UNDO CASE-SENSITIVE.
    DEFINE VARIABLE vDataMark      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vDataMarkLM    AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vRetProp       AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE v-value-character AS CHARACTER NO-UNDO .
    DEFINE VARIABLE v-value-date      AS DATE      NO-UNDO .
    DEFINE VARIABLE v-value-decimal   AS DECIMAL   NO-UNDO .
    DEFINE VARIABLE v-value-integer   AS INTEGER   NO-UNDO .
    DEFINE VARIABLE v-value-logical   AS LOGICAL   NO-UNDO .
    DEFINE VARIABLE v-param-type      AS CHARACTER NO-UNDO .
    DEFINE VARIABLE v-param-value     AS CHARACTER NO-UNDO .
    DEFINE VARIABLE vRetOk   AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE vRetVal  AS INTEGER     NO-UNDO.
    DEFINE VARIABLE vCh      AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vBefCurl AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vAftCurl AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vpid     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE vTimePause AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vGisAdress AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vGisAdrCDN AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vTimeStart AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vTimeNow   AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vRetCdn    AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE vNumRep AS INT64 NO-UNDO.
    DEFINE VARIABLE vNumMax AS INT64 NO-UNDO.
    DEFINE VARIABLE vVerLM  AS INT64 NO-UNDO.
    DEFINE VARIABLE vMarkShort    AS CHARACTER   NO-UNDO CASE-SENSITIVE.
    DEFINE VARIABLE vFileBatOf    AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vFileResOf    AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vFileResOfErr AS CHARACTER   NO-UNDO.
    DEFINE BUFFER buf_firm FOR ub.firm .
    DEFINE BUFFER buf_shop FOR ub.shop.
    DEFINE BUFFER buf_sys-ctrl FOR ub.sys-ctrl .
    ASSIGN
       vMark = mark
       vMark = REPLACE(vMark, '\', '\\')
       vMark = REPLACE(vMark, '/', '\/')
       vMark = REPLACE(vMark, '"', '\"')
       vMark = REPLACE(vMark,CHR(29),"\u001d")
       .
    EMPTY TEMP-TABLE ttmark-body.
    EMPTY TEMP-TABLE ttmark-check.
    EMPTY TEMP-TABLE ttlocal-mark.
    EMPTY TEMP-TABLE ttlocal-mark-code.
    dbgPrint("marking.log", SUBSTITUTE("Отправка запроса p-obj-type &1 p-obj-code &2 mark &3",
                                       p-obj-type,
                                       p-obj-code,
                                       vMark)).
    dbgPrint("marking.log", SUBSTITUTE("Заново считывать настройки подключения к ГИС МТ &1 ", gismt-UpdateRequest)).
    IF gismt-UpdateRequest THEN DO:
        FIND FIRST buf_sys-ctrl NO-LOCK NO-ERROR.
        IF AVAILABLE buf_sys-ctrl AND buf_sys-ctrl.db-num <> 0
        THEN DO:
            dbgPrint("marking.log", SUBSTITUTE("Cчитываем настройки подключения к ГИС МТ для &1 &2", "'БД':U",buf_sys-ctrl.db-num)).
            vRetProp = get-gismt-prop ('БД':U,
                                       buf_sys-ctrl.db-num) NO-ERROR.
        END.
    END.
    dbgPrint("marking.log", "gismt-info").
    vFileLog = "GisMtReq-" + replace(STRING(TODAY),"/","-") +  ".log".
    vCh = "".
    IF searchfile(vFileLog) <> ?
    THEN DO:
       FILE-INFO:FILE-NAME = searchfile(vFileLog).
       IF FILE-INFO:FILE-SIZE <> 0 THEN vCh = " ".
    END.
    OUTPUT STREAM out_data TO value(vFileLog) APPEND.
    PUT STREAM out_data UNFORMATTED
      vCh SKIP NOW CHR(9) mMarkOrig CHR(9).
    OUTPUT STREAM out_data CLOSE.
    RUN gbl/_tmpfile.p ( "LMChz_data", ".txt", OUTPUT vDataMarkLM ) .
    CREATE tt-file-name.
    ASSIGN tt-file-name.tmpFileName = vDataMarkLM.
    dbgPrint("marking.log", SUBSTITUTE("vDataMarkLM &1 ", vDataMarkLM)).
    ASSIGN
       vMarkShort = mark-short
       vMarkShort = REPLACE(vMarkShort, '\', '\\')
       vMarkShort = REPLACE(vMarkShort, '/', '\/')
       vMarkShort = REPLACE(vMarkShort, '"', '\"') .
    dbgPrint("marking.log", SUBSTITUTE("Сконвертированная КИ: &1 ", vMarkShort)).
    IF R-INDEX(gismt-OflineAdress,"/v2") > 0
    THEN vVerLM = 2.
    ELSE vVerLM = 1.
    OUTPUT STREAM out_data TO value(vDataMarkLM).
    IF vVerLM = 2 THEN
       PUT STREAM out_data UNFORMATTED
          '~{"cis_list":[~{"cis":"' vMarkShort '"~}]~}' .
    ELSE
       PUT STREAM out_data UNFORMATTED
          '~{"cis_list":["' vMarkShort '"]~}' .
    OUTPUT STREAM out_data CLOSE.
    IF gismt-CrashSituat THEN DO:
       dbgPrint("marking.log", "Установлена аварийная ситуация.").
       OUTPUT STREAM out_data TO value(vFileLog) APPEND.
       PUT STREAM out_data UNFORMATTED
          "Установлена аварийная ситуация в ГИС МТ" CHR(9).
       OUTPUT STREAM out_data CLOSE.
       vRetVal = GetResLocalMark(vDataMarkLM).
       RETURN 1.
    END.
    RUN gbl/_tmpfile.p ( "GisMT_data", ".txt", OUTPUT vDataMark ) .
    CREATE tt-file-name.
    ASSIGN tt-file-name.tmpFileName = vDataMark.
    dbgPrint("marking.log", SUBSTITUTE("vDataMark &1 ", vDataMark)).
    OUTPUT STREAM out_data TO value(vDataMark).
    PUT STREAM out_data UNFORMATTED
      '~{"codes":["' vMark '"]~}' .
    OUTPUT STREAM out_data CLOSE.
    IF gismt-AdressPort <> "" AND gismt-ProxyLogin <> "" AND gismt-ProxyPswd <> ""
    THEN CmdParamProxy = SUBSTITUTE ('-x &1 -U &2:&3',gismt-AdressPort,gismt-ProxyLogin,gismt-ProxyPswd).
    ELSE IF gismt-AdressPort <> "" THEN CmdParamProxy = SUBSTITUTE ('-x &1',gismt-AdressPort).
    ELSE CmdParamProxy = "".
    IF gismt-cdnTurnOn AND gismt-cdnRepeat
    THEN vNumMax = 2.
    ELSE vNumMax = 1.
    dbgPrint("marking.log", SUBSTITUTE(" Кол-во запросов по одной площадке &1 ", vNumMax)).
    vTimeStart = NOW.
    block_chgcdn:
    DO  WHILE TRUE:
       IF gismt-cdnTurnOn THEN DO:
           vGisAdrCDN = GetCDNAdress().
           IF vGisAdrCDN = "" THEN DO:
              dbgPrint("marking.log", "Нет доступных площадок").
              OUTPUT STREAM out_data TO value(vFileLog) APPEND.
              PUT STREAM out_data UNFORMATTED
                 CHR(9) "Нет доступных площадок для обращения в ГИС МТ" CHR(9).
              OUTPUT STREAM out_data CLOSE.
              IF vFileResult = "" THEN DO:
                 vRetVal = GetResLocalMark(vDataMarkLM).
              END.
              RETURN 2.
           END.
           vGisAdress = vGisAdrCDN + "/api/v4/true-api/codes/check".
       END.
       ELSE vGisAdress = gismt-GisAdress.
       block_repeat:
       DO vNumRep = 1 TO vNumMax:
           IF vNumRep > 1 THEN DO:
               dbgPrint("marking.log", SUBSTITUTE("Повторный запрос на площадку &1 ", vGisAdress)).
           END.
           RUN gbl/_tmpfile.p ( "ChkGisMTRes", ".txt", OUTPUT vFileResult ) .
           CREATE tt-file-name.
           ASSIGN tt-file-name.tmpFileName = vFileResult.
           RUN gbl/_tmpfile.p ( "ChkGisMTResErr", ".txt", OUTPUT vFileResultErr ) .
           CREATE tt-file-name.
           ASSIGN tt-file-name.tmpFileName = vFileResultErr.
           RUN gbl/_tmpfile.p ( "ChkGisMT", ".bat", OUTPUT vFileBat ) .
           CREATE tt-file-name.
           ASSIGN tt-file-name.tmpFileName = vFileBat.
           dbgPrint("marking.log", SUBSTITUTE("vFileResult &1 ", vFileResult)).
           dbgPrint("marking.log", SUBSTITUTE("vFileResultErr &1 ", vFileResultErr)).
           dbgPrint("marking.log", SUBSTITUTE("vFileBat &1 ", vFileBat)).
           IF vNumRep = 1 THEN DO:
               RUN gbl/_tmpfile.p ( "ChkLMRes", ".txt", OUTPUT vFileResOf ) .
               CREATE tt-file-name.
               ASSIGN tt-file-name.tmpFileName = vFileResOf
                      tt-file-name.ofline = YES.
               RUN gbl/_tmpfile.p ( "ChkLMResErr", ".txt", OUTPUT vFileResOfErr ) .
               CREATE tt-file-name.
               ASSIGN tt-file-name.tmpFileName = vFileResOfErr.
               RUN gbl/_tmpfile.p ( "ChkLM", ".bat", OUTPUT vFileBatOf ) .
               CREATE tt-file-name.
               ASSIGN tt-file-name.tmpFileName = vFileBatOf.
               dbgPrint("marking.log", SUBSTITUTE("vFileResOf &1 ", vFileResOf)).
               dbgPrint("marking.log", SUBSTITUTE("vFileResOfErr &1 ", vFileResOfErr)).
               dbgPrint("marking.log", SUBSTITUTE("vFileBatOf &1 ", vFileBatOf)).
           END.
           ELSE ASSIGN
                  vFileResOf = ""
                  vFileResOfErr = ""
                  vFileBatOf = ""
                  .
           vRetVal = RunCurlGisMT(vGisAdress,
                                  vDataMark,
                                  vDataMarkLM,
                                  CmdParamProxy,
                                  vFileResult,
                                  vFileResultErr,
                                  vFileBat,
                                  vFileResOf,
                                  vFileResOfErr,
                                  vFileBatOf).
           dbgPrint("marking.log", SUBSTITUTE("Файл ответа &1 результат &1 ", searchFile(vFileResult), vRetVal)).
           vTimeNow = NOW.
           OUTPUT STREAM out_data TO value(vFileLog) APPEND.
           PUT STREAM out_data UNFORMATTED
              vGisAdress CHR(9) vTimeNow CHR(9).
           OUTPUT STREAM out_data CLOSE.
           IF searchFile(vfileresult) = ?
           THEN DO :
               OUTPUT STREAM out_data TO value(vFileLog) APPEND.
               PUT STREAM out_data UNFORMATTED
                  "Отсутствует ответ ГИС МТ " CHR(9).
               OUTPUT STREAM out_data CLOSE.
           END .
           ELSE DO:
               FILE-INFO:FILE-NAME = searchFile(vfileresult) .
               IF FILE-INFO:FILE-SIZE = 0
               THEN DO :
                   OUTPUT STREAM out_data TO value(vFileLog) APPEND.
                   PUT STREAM out_data UNFORMATTED
                      "Отсутствует ответ ГИС МТ " CHR(9).
                   OUTPUT STREAM out_data CLOSE.
               END .
               ELSE DO:
                  dbgPrint("marking.log", SUBSTITUTE("Добавляем в лог ответ из файла &1 ", vFileResult)).
                  vlongJson = "".
                  COPY-LOB FROM FILE vFileResult TO vlongJson NO-ERROR.
                  IF vlongJson = "" OR
                     ERROR-STATUS:ERROR OR
                     ERROR-STATUS:GET-MESSAGE(1) <> "" THEN DO:
                     dbgPrint("marking.log", SUBSTITUTE("Возникла ошибка при чтении ответа для записи в лог: &1 ", ERROR-STATUS:GET-MESSAGE(1))).
                  END.
                  ELSE DO:
                      IF vRetVal = -1 THEN DO:
                         vRetVal = ChkCurlGisMT (vlongJson).
                         dbgPrint("marking.log", SUBSTITUTE("Думали, что ответа нет, а файл есть, новый результат проверки: &1 ", vRetVal)).
                      END.
                      COPY-LOB FROM vlongJson TO FILE vFileLog APPEND NO-ERROR.
                      IF ERROR-STATUS:ERROR OR
                         ERROR-STATUS:GET-MESSAGE(1) <> ""
                      THEN DO:
                          dbgPrint("marking.log", SUBSTITUTE("Возникла ошибка при добавлении ответа в лог: &1 ", ERROR-STATUS:GET-MESSAGE(1))).
                      END.
                      ELSE dbgPrint("marking.log", SUBSTITUTE("Ответ ГИС МТ успешно добавлен в файл &1 ", vFileLog)).
                  END.
               END.
           END.
           dbgPrint("marking.log", SUBSTITUTE("Ответ по запросу vRetVal &1", vRetVal)).
           IF vRetVal = 0 OR
              vRetVal = 203 OR
              vRetVal = 418
           THEN LEAVE block_chgcdn.
           IF vRetVal = 401 THEN DO:
               OUTPUT STREAM out_data TO value(vFileLog) APPEND.
               PUT STREAM out_data UNFORMATTED
                  CHR(9) "Ошибка идентификации по API Key ".
               OUTPUT STREAM out_data CLOSE.
               LEAVE block_chgcdn.
           END.
           ELSE IF vRetVal > 400 AND
              vRetVal < 500 AND
              vRetVal <> 429
           THEN DO:
              OUTPUT STREAM out_data TO value(vFileLog) APPEND.
              PUT STREAM out_data UNFORMATTED
                  CHR(9) "Ошибка: некорректный запрос ".
              OUTPUT STREAM out_data CLOSE.
              LEAVE block_chgcdn.
           END.
           IF vRetVal = 5000 AND vNumRep = vNumMax
           THEN DO:
              OUTPUT STREAM out_data TO value(vFileLog) APPEND.
              PUT STREAM out_data UNFORMATTED
                  CHR(9) "Ошибка недоступности трансграна ".
              OUTPUT STREAM out_data CLOSE.
              LEAVE block_chgcdn.
           END.
           IF vNumRep = vNumMax
               AND gismt-cdnTurnOn
           THEN DO:
              vRetCdn = SetCDNAdressErr(vGisAdrCDN).
           END.
           IF vNumRep <> vNumMax AND
              gismt-cdnTurnOn AND
              gismt-cdnRepeat
           THEN DO:
               IF vTimeStart + Int(gismt-WaitTime * 1000) < vTimeNow
               THEN DO:
                  dbgPrint("marking.log", SUBSTITUTE("Время для повторного запроса не осталось: Начало &1 Время ожидания (с) &2 Сейчас &3  ", vTimeStart, gismt-WaitTime, vTimeNow)).
                  vRetCdn = SetCDNAdressErr(vGisAdrCDN).
                  LEAVE block_chgcdn.
               END.
           END.
       END.
       IF gismt-cdnTurnOn AND gismt-cdnChange
       THEN DO:
           vTimeNow = NOW.
           IF vTimeStart + Int(gismt-WaitTime * 1000) < vTimeNow
           THEN DO:
              dbgPrint("marking.log", SUBSTITUTE("Время подбора площадки закончилось: Начало &1 Время ожидания (с) &2 Сейчас &3  ", vTimeStart, gismt-WaitTime, vTimeNow)).
              LEAVE block_chgcdn.
           END.
       END.
       ELSE LEAVE block_chgcdn.
    END.
    IF vRetVal <> 0 AND
       vRetVal <> 203 AND
       vRetVal <> 418 AND
       vRetVal <> 5000
    THEN DO:
       dbgPrint("marking.log", SUBSTITUTE("Получена ошибка с кодом &1 ", vRetVal)).
       RETURN 2.
    END.
    IF vRetVal = 203 OR
       vRetVal = 418 OR
       vRetVal = 5000
    THEN DO:
        dbgPrint("marking.log", SUBSTITUTE("Получена ошибка с кодом &1 ", vRetVal)).
       RETURN vRetVal.
    END.
    IF searchFile(vfileresult) = ?
    THEN DO :
       dbgPrint("marking.log", "Запрос не выполнен! Не могу найти файл ").
       RETURN 2.
    END .
    FILE-INFO:FILE-NAME = searchFile(vfileresult) .
    IF FILE-INFO:FILE-SIZE = 0
    THEN DO :
       dbgPrint("marking.log", "Запрос не выполнен! Файл-ответ пустой (размер 0 байт). ").
       RETURN 2.
    END.
    COPY-LOB FROM FILE vFileResult TO vlongJson NO-ERROR.
    COPY-LOB FROM FILE vFileresultErr TO vlongJsonError NO-ERROR.
    IF INDEX(vlongJsonError,"curl:") > 0 OR
       vlongJson BEGINS "<html>"
    THEN DO:
       dbgPrint("marking.log", "Ошибка ответа от сервиса ").
       OUTPUT STREAM out_data TO value(vFileLog) APPEND.
       PUT STREAM out_data UNFORMATTED
         CHR(9) "Отсутствует ответ ГИС МТ ".
       OUTPUT STREAM out_data CLOSE.
       RETURN 2.
    END.
    ASSIGN
       vlongJson = REPLACE(vlongJson, "&lt;", "###lo-then###")
       vlongJson = REPLACE(vlongJson, "&Lt;", "###LO-then###")
       vlongJson = REPLACE(vlongJson, "&lT;", "###lo-THEN###")
       vlongJson = REPLACE(vlongJson, "&LT;", "###LO-THEN###")
       vlongJson = REPLACE(vlongJson, "&gt;", "###gr-then###")
       vlongJson = REPLACE(vlongJson, "&Gt;", "###GR-then###")
       vlongJson = REPLACE(vlongJson, "&gT;", "###gr-THEN###")
       vlongJson = REPLACE(vlongJson, "&GT;", "###GR-THEN###")
       vlongJson = REPLACE(vlongJson, "&", "&amp;")
       vlongJson = REPLACE(vlongJson, "<", "&lt;")
       vlongJson = REPLACE(vlongJson, ">", "&gt;")
       vlongJson = REPLACE(vlongJson, ':null', ':""')
       vlongJson = REPLACE(vlongJson, (':' + CHR(91) + CHR(123) + CHR(125) + CHR(93)), ':""')
       vlongJson = REPLACE(vlongJson, ':~{~}', ':""')
       vlongJson = REPLACE(vlongJson, '"1":', '"n1":')
       vlongJson = REPLACE(vlongJson, '"2":', '"n2":')
       vlongJson = REPLACE(vlongJson, '"3":', '"n3":')
       vlongJson = REPLACE(vlongJson, '"4":', '"n4":')
       vlongJson = REPLACE(vlongJson, '"5":', '"n5":')
       vlongJson = REPLACE(vlongJson, '"6":', '"n6":')
       vlongJson = REPLACE(vlongJson, '"7":', '"n7":')
       vlongJson = REPLACE(vlongJson, '"8":', '"n8":')
       vlongJson = REPLACE(vlongJson, '"9":', '"n9":')
       vlongJson = REPLACE(vlongJson, '"10":', '"n10":')
       vlongJson = REPLACE(vlongJson, '"11":', '"n11":')
       vlongJson = REPLACE(vlongJson, '"12":', '"n12":')
       vlongJson = REPLACE(vlongJson, '"13":', '"n13":')
       vlongJson = REPLACE(vlongJson, '"14":', '"n14":')
       vlongJson = REPLACE(vlongJson, '"15":', '"n15":')
       vlongJson = REPLACE(vlongJson, '"16":', '"n16":')
       vlongJson = REPLACE(vlongJson, '"17":', '"n17":')
       vlongJson = REPLACE(vlongJson, '"18":', '"n18":')
       vlongJson = REPLACE(vlongJson, '"19":', '"n19":')
       vlongJson = REPLACE(vlongJson, '"20":', '"n20":')
       vlongJson = REPLACE(vlongJson, '"21":', '"n21":')
       .
    RUN gbl/_tmpfile.p ( "ChkGisMTResCnv", ".txt", OUTPUT vFileResultCnv ) .
    CREATE tt-file-name.
    ASSIGN tt-file-name.tmpFileName = vFileResultCnv.
    dbgPrint("marking.log", SUBSTITUTE("vFileResultCnv &1 ", vFileResultCnv)).
    COPY-LOB FROM vlongJson TO FILE vFileResultCnv NO-ERROR.
    IF vlongJson = "" THEN DO:
       dbgPrint("marking.log", "Не получен ответ от сервиса ").
       OUTPUT STREAM out_data TO value(vFileLog) APPEND.
       PUT STREAM out_data UNFORMATTED
         CHR(9) "Отсутствует ответ ГИС МТ ".
       OUTPUT STREAM out_data CLOSE.
       RETURN 2.
    END.
    RUN gbl/_tmpfile.p ( "ChkGisMTResXml", ".xml", OUTPUT vFileResultXml ) .
    CREATE tt-file-name.
    ASSIGN tt-file-name.tmpFileName = vFileResultXml.
    dbgPrint("marking.log", SUBSTITUTE("vFileResultXml &1 ", vFileResultXml)).
    cmd = SUBSTITUTE ('&1 -file=&2 >&3',
                      SEARCH("exe/json2xml.exe"),
                      vFileResultCnv,
                      vfileresultxml).
    OS-COMMAND SILENT VALUE (cmd).
    FILE-INFO:FILE-NAME = SEARCH(vfileresultxml) .
    IF FILE-INFO:FILE-SIZE = 0
    THEN DO :
       dbgPrint("marking.log", "Запрос не выполнен! Ошибка при чтении XML <body>. " + ERROR-STATUS:GET-MESSAGE(1)).
       OUTPUT STREAM out_data TO value(vFileLog) APPEND.
       PUT STREAM out_data UNFORMATTED
         CHR(9) "Отсутствует ответ ГИС МТ ".
       OUTPUT STREAM out_data CLOSE.
       RETURN 2.
    END .
    COPY-LOB FROM FILE vfileresultxml TO vlongJson NO-ERROR.
    vlongJson = "<bodys>" +  vlongJson + "</bodys>".
    COPY-LOB FROM vlongJson TO FILE vfileresultxml NO-ERROR.
    vRetOk = DATASET gismt-mark-body:READ-XML("FILE":U, vfileresultxml, "EMPTY":U, ?, ?) NO-ERROR.
    IF NOT vRetOk OR ERROR-STATUS:ERROR THEN DO:
       dbgPrint("marking.log", "Запрос не выполнен! Ошибка при чтении XML <body>. " + ERROR-STATUS:GET-MESSAGE(1)).
       OUTPUT STREAM out_data TO value(vFileLog) APPEND.
       PUT STREAM out_data UNFORMATTED
         CHR(9) "Отсутствует ответ ГИС МТ ".
       OUTPUT STREAM out_data CLOSE.
       RETURN 2.
    END.
    vRetOk = DATASET gismt-mark-codes:READ-XML("FILE":U, vfileresultxml, "EMPTY":U, ?, ?) NO-ERROR.
    IF NOT vRetOk OR ERROR-STATUS:ERROR THEN DO:
       dbgPrint("marking.log", "Запрос не выполнен! Ошибка при чтении XML <codes>.").
       OUTPUT STREAM out_data TO value(vFileLog) APPEND.
       PUT STREAM out_data UNFORMATTED
         CHR(9) "Отсутствует ответ ГИС МТ ".
       OUTPUT STREAM out_data CLOSE.
       RETURN 2.
    END.
    RETURN 0.
  END METHOD.
  METHOD PRIVATE CHARACTER ChekAccessMark (
    p-obj-type  AS CHARACTER,
    p-obj-code  AS INTEGER,
    mark AS CHARACTER,
    mark-short AS CHARACTER
  ):
    DEFINE VARIABLE vErrSts AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vMark AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vGetGisMt AS INT NO-UNDO.
    DEFINE VARIABLE vMarkNotNeedCheck AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE vCheckBlock    AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE vCheckDate     AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE vCheckMRC      AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE vCheckOwner    AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE vCheckStatusKM AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE vCheckTracking AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE vCheck         AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE vMRC AS DECIMAL NO-UNDO.
    DEFINE VARIABLE vMrp AS DECIMAL NO-UNDO.
    DEFINE VARIABLE vMRC_r AS DECIMAL NO-UNDO.
    DEFINE VARIABLE vMrp_r AS DECIMAL NO-UNDO.
    DEFINE VARIABLE vExpireDMY  AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vExpireTime AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE vExpireDate AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vExpireTimeMes AS CHARACTER NO-UNDO.
    DEFINE BUFFER buf_marking-attr FOR ub.marking-attr.
    DEFINE BUFFER buf_code FOR ub.code.
    DelTmpFile(YES).
    DelTmpFile(NO).
    IF mark = "" OR mark = "?"
       THEN RETURN "".
    ASSIGN
       vErrSts = ""
       mCheckSts = 1
       mTypeMark = ""
       mCheckGisMT = 0
       .
    ChekTypeMarkByDm(mark).
    IF mTypeMark = "" THEN DO:
        mCheckSts = 0.
        RETURN "Не опредлен тип маркировки товара. ".
    END.
    dbgPrint("marking.log", SUBSTITUTE("Проверка марки p-obj-type &1 p-obj-code &2 mark &3 mTypeMark &4 mark-short &5",
                                        p-obj-type,
                                        p-obj-code,
                                        mark,
                                        mTypeMark,
                                        TRIM(mark-short,CHR(29))
                                        )).
    vCheckBlock = GetMarkProp (p-obj-type,
                               p-obj-code,
                               'checkBlock':U,
                               mTypeMark).
    vCheckDate   = GetMarkProp (p-obj-type,
                               p-obj-code,
                               'checkDate':U,
                               mTypeMark).
    vCheckMRC    = GetMarkProp (p-obj-type,
                               p-obj-code,
                               'checkMRC':U,
                               mTypeMark).
    vCheckOwner  = GetMarkProp (p-obj-type,
                               p-obj-code,
                               'checkOwner':U,
                               mTypeMark).
    vCheckStatusKM = GetMarkProp (p-obj-type,
                               p-obj-code,
                               'checkStatusKM':U,
                               mTypeMark).
    vCheckTracking  = GetMarkProp (p-obj-type,
                               p-obj-code,
                               'checkTracking':U,
                               mTypeMark).
    IF  vCheckBlock OR vCheckDate OR vCheckMRC OR vCheckOwner OR vCheckStatusKM
       THEN vCheck = YES.
    ELSE vCheck = NO.
    dbgPrint("marking.log", SUBSTITUTE("vCheckBlock &1 vCheckDate &2 vCheckMRC &3 vCheckOwner &4 vCheckStatusKM &5 vCheckTracking &6",
                                       vCheckBlock,
                                       vCheckDate,
                                       vCheckMRC,
                                       vCheckOwner,
                                       vCheckStatusKM,
                                       vCheckTracking)).
    IF NOT vCheck THEN RETURN "".
    FIND FIRST buf_marking-attr NO-LOCK WHERE
                buf_marking-attr.attr-code = "notOnlineCheck"
            AND buf_marking-attr.mark BEGINS trim(mark-short,CHR(29))
        NO-ERROR.
    IF AVAILABLE buf_marking-attr
    THEN vMarkNotNeedCheck = LOGICAL(buf_marking-attr.attr-value) NO-ERROR.
    ELSE vMarkNotNeedCheck = NO.
    dbgPrint("marking.log", SUBSTITUTE("Игнорировать он-лайн проверку: &1",vMarkNotNeedCheck)).
    IF vMarkNotNeedCheck THEN DO:
       mCheckGisMT = 2.
       RETURN "".
    END.
    vGetGisMt = GetGisMTCheck(p-obj-type,p-obj-code,mark,mark-short).
    DelTmpFile(NO).
    IF vGetGisMt = 1 THEN DO:
       ASSIGN
          mCheckSts = 2
          mCheckGisMT = 2
          .
       RETURN "".
    END.
    IF vGetGisMt <> 0 THEN DO:
        IF vGetGisMt = 2 THEN
        DO:
           vErrSts = FixErrGisMT().
        END.
        ELSE IF vGetGisMt = 5000
        THEN DO:
            ASSIGN
               mCheckSts = 2
               vErrSts = ""
               .
        END.
        ELSE IF vGetGisMt = 203 OR
                vGetGisMt = 418
        THEN DO:
            SetNoErrGisMT().
            ASSIGN
                mCheckSts = 2
                vErrSts = ""
                mCheckGisMT = 2
                .
        END.
        RETURN vErrSts.
    END.
    ELSE SetNoErrGisMT().
    mCheckGisMT = 1.
    dbgPrint("marking.log", "ttmark-body").
    FIND FIRST ttmark-body NO-LOCK NO-ERROR.
    IF AVAIL ttmark-body
    THEN DO:
        ASSIGN
           mReqId        = ttmark-body.reqid
           mReqTimeStamp = STRING(ttmark-body.reqtimestamp)
           .
        IF ttmark-body.code <> 0
        THEN DO:
           ASSIGN
              mCheckSts = 0
              vErrSts = "Онлайн-проверка завершилась с ошибкой. "
              .
            RETURN vErrSts.
        END.
    END.
    ELSE DO:
        dbgPrint("marking.log", "Произошло аварийное завершение метода проверки марки в ГИС МТ - нет шапки ответа.").
        ASSIGN
           mCheckSts = 0
           vErrSts = "Онлайн-проверка завершилась с ошибкой. "
           .
        RETURN vErrSts.
    END.
    vMRC = getMRCByDM(mark) * 100 NO-ERROR.
    IF vMRC = ? THEN vMRC = 0.
    dbgPrint("marking.log", SUBSTITUTE("МРЦ по марке: &1",vMRC)).
    dbgPrint("marking.log", "ttmark-check").
    FIND FIRST ttmark-check NO-LOCK NO-ERROR.
    IF AVAIL ttmark-check
    THEN DO:
      IF ttmark-check.errorCode = 0 OR
         ttmark-check.errorCode = 10
         THEN .
      ELSE DO:
          ASSIGN
            vErrSts = "Онлайн-проверка завершилась с ошибкой. "
            mCheckSts = 0.
          RETURN vErrSts.
      END.
      vMrp = int(ttmark-check.mrp) NO-ERROR.
      IF vCheck THEN DO:
         IF ttmark-check.found = FALSE
         THEN DO:
            ASSIGN
                vErrSts = "Данная марка не зарегистрирована в Честном Знаке. "
                mCheckSts = 3.
            RETURN vErrSts.
         END.
         IF  vCheckDate = YES THEN DO:
            IF ttmark-check.expireDate <> ?
            THEN DO:
                vExpireTimeMes = ENTRY(1,STRING(ttmark-check.expireDate),"+").
                vExpireDate = DATETIME-TZ(vExpireTimeMes).
                IF vExpireDate < NOW + gismt-BanDate * 60 * 1000
                THEN DO:
                  ASSIGN
                     vErrSts = "Срок годности товара истек " + string(vExpireDate,"99/99/9999 HH:MM") + ". "
                     mCheckSts = 0.
                END.
            END.
            ELSE ASSIGN
                   vErrSts = ""
                   mCheckSts = 2.
         END.
         IF  vCheckBlock AND ttmark-check.isBlocked = TRUE
         THEN ASSIGN
                 vErrSts = vErrSts + "Реализация товара запрещена контролирующими органами. "
                 mCheckSts = 0.
         IF  vCheckStatusKM AND
                 (ttmark-check.utilised = FALSE OR
                 (ttmark-check.realizable = FALSE AND ttmark-check.grayZone = FALSE) OR
                 ttmark-check.sold = TRUE OR
                 ttmark-check.verified = FALSE)
         THEN ASSIGN
                 vErrSts = vErrSts + "Марка товара в статусе, запрещающем розничную реализацию. "
                 mCheckSts = 0.
         IF vCheckMRC AND
            vMrp <> 0 AND
            vMRC <> vMrp
         THEN
              ASSIGN
                 vMRC_r = IF vMRC <> ? THEN ROUND((vMrc / 100), 2) ELSE 0
                 vMrp_r = ROUND((vMrp / 100), 2)
                 vErrSts = vErrSts + "МРЦ на упаковке "
                           + (IF vMRC = ? THEN "не определена" ELSE TRIM(STRING(vMrc_r,">>>>>>>>>>9.99"), " ") + "р.")
                           + " не совпадает с МРЦ в Честном Знаке - "
                           + trim(STRING(vMrp_r,">>>>>>>>>>9.99"), " ") + "р. "
                 mCheckSts = 0
                 .
         IF  vCheckOwner AND
             ttmark-check.isOwner = FALSE AND
             ((vCheckTracking AND ttmark-check.isTracking = TRUE) OR
              NOT vCheckTracking) AND
             ttmark-check.grayZone = FALSE
         THEN ASSIGN
                 vErrSts = vErrSts + "Общество не является владельцем товара. "
                 mCheckSts = 0.
      END.
    END.
    ELSE DO:
        dbgPrint("marking.log", "Произошло аварийное завершение метода проверки марки в ГИС МТ - нет тела ответа.").
        ASSIGN
           mCheckSts = 0
           vErrSts = "Онлайн-проверка завершилась с ошибкой. "
           .
        RETURN vErrSts.
    END.
    dbgPrint("marking.log", SUBSTITUTE("vErrSts &1 mCheckSts &2", vErrSts, mCheckSts)).
    RETURN vErrSts.
  END METHOD.
  METHOD PRIVATE VOID dbgPrint(
     iLogName AS CHARACTER,
     iTxt AS CHARACTER
    ):
        DEF VAR vLogName AS CHAR NO-UNDO.
    IF SESSION:DEBUG-ALERT
    THEN DO:
       vLogName = ENTRY(1,iLogName,".") + "-" + replace(STRING(TODAY),"/","-") + "." + entry(2,iLogName,".").
       OUTPUT stream out_s to value(vLogName) append.
       CASE iTxt:
          WHEN "gismt-info" THEN DO:
             PUT STREAM out_s UNFORMATTED
                   " AdressPort " gismt-AdressPort SKIP
                   " DopParam " gismt-DopParam SKIP
                   " GisAdress " gismt-GisAdress SKIP
                   " ProxyLogin " gismt-ProxyLogin SKIP
                   " ProxyPswd " gismt-ProxyPswd SKIP
                   " MaxTime " gismt-MaxTime SKIP
                   " RegKey " gismt-RegKey SKIP
                   " TimeFalStart " gismt-TimeFalStart SKIP
                   " WaitTime " gismt-WaitTime SKIP
                   " CrashSituat " gismt-CrashSituat SKIP
                   " BanDate " gismt-BanDate SKIP
                   " cdnTurnOn " gismt-cdnTurnOn SKIP
                   " cdnAdress " gismt-cdnAdress SKIP
                   " cdnRepeat " gismt-cdnRepeat SKIP
                   " cdnChange " gismt-cdnChange SKIP
                   " cdnTimeUpd " gismt-cdnTimeUpd SKIP
                   " UpdateRequest " gismt-UpdateRequest
                   " OflineAdress " gismt-OflineAdress SKIP
                   " OflineAutoriz " gismt-OflineAutoriz SKIP
                   " OflineDate " gismt-OflineDate
                   SKIP.
          END.
          WHEN "ttmark-body" THEN DO:
             FOR EACH ttmark-body:
                PUT STREAM out_s UNFORMATTED
                    NOW " ttmark-body: " SKIP
                    "ttmark-body.code " ttmark-body.code SKIP
                    "ttmark-body.error " ttmark-body.error-1 SKIP
                    "ttmark-body.requestid " ttmark-body.requestid SKIP
                    "ttmark-body.status " ttmark-body.status-1 SKIP
                    "ttmark-body.timestamp " ttmark-body.timestamp SKIP
                    "ttmark-body.reqid " ttmark-body.reqid SKIP
                    "ttmark-body.reqtimestamp " ttmark-body.reqtimestamp
                    SKIP .
             END.
          END.
          WHEN "ttmark-check" THEN DO:
             FOR EACH ttmark-check:
                PUT STREAM out_s UNFORMATTED
                     NOW " ttmark-check: " SKIP
                     "ttmark-check.cis: " ttmark-check.cis SKIP
                     "tttmark-check.printView: " ttmark-check.printView SKIP
                     "ttmark-check.gtin: " ttmark-check.gtin           SKIP
                     "ttmark-check.verified: " ttmark-check.verified   SKIP
                     "ttmark-check.found: " ttmark-check.found         SKIP
                     "ttmark-check.realizable: " ttmark-check.realizable  SKIP
                     "ttmark-check.utilised: " ttmark-check.utilised   SKIP
                     "ttmark-check.isBlocked: " ttmark-check.isBlocked SKIP
                     "ttmark-check.productionDate: " ttmark-check.productionDate SKIP
                     "ttmark-check.isOwner: " ttmark-check.isOwner     SKIP
                     "ttmark-check.errorCode: " ttmark-check.errorCode SKIP
                     "ttmark-check.isTracking: " ttmark-check.isTracking   SKIP
                     "ttmark-check.sold: " ttmark-check.sold           SKIP
                     "ttmark-check.packageType: " ttmark-check.packageType SKIP
                     "ttmark-check.producerInn: " ttmark-check.producerInn SKIP
                     "ttmark-check.grayZone: " ttmark-check.grayZone       SKIP
                     "ttmark-check.mrp: " ttmark-check.mrp SKIP
                     "ttmark-check.expireDate: " ttmark-check.expireDate
                     SKIP.
             END.
          END.
          WHEN "ttlocal-mark" THEN DO:
              FOR EACH ttlocal-mark:
                  PUT STREAM out_s UNFORMATTED
                     NOW " ttlocal-mark: " SKIP
                     "ttlocal-mark.reqId: " ttlocal-mark.reqId     SKIP
                     "ttlocal-mark.reqTimestamp: " ttlocal-mark.reqTimestamp     SKIP
                     "ttlocal-mark.inst: " ttlocal-mark.inst SKIP
                     "ttlocal-mark.version: " ttlocal-mark.version SKIP
                     "ttlocal-mark.description: " ttlocal-mark.description       SKIP
                     "ttlocal-mark.code: " ttlocal-mark.code       SKIP
                     "ttlocal-mark.errorCode " ttlocal-mark.errorCode SKIP
                     .
              END.
              FOR EACH ttlocal-mark-code:
                  PUT STREAM out_s UNFORMATTED
                     NOW " ttlocal-mark-code " SKIP
                     "ttlocal-mark-code.sold: " ttlocal-mark-code.sold     SKIP
                     "ttlocal-mark-code.isBlocked: " ttlocal-mark-code.isBlocked     SKIP
                     "ttlocal-mark-code.gtin: " ttlocal-mark-code.gtin     SKIP
                     "ttlocal-mark-code.cis: " ttlocal-mark-code.cis       SKIP
                     "ttlocal-mark-code.mrp: " ttlocal-mark-code.mrp       SKIP
                     .
              END.
          END.
          OTHERWISE
             PUT STREAM out_s UNFORMATTED NOW " " iTxt SKIP.
       END CASE.
       OUTPUT stream out_s close.
    END.
    RETURN.
  END METHOD.
  METHOD PRIVATE CHARACTER GetCDNAdress ():
      DEF BUFFER buf_code FOR ub.code.
      DEF VAR vAddr AS CHAR NO-UNDO.
      DEF VAR vTimeResp AS INT NO-UNDO.
      DEF VAR vTimeNow AS DATETIME-TZ NO-UNDO.
      ASSIGN
         vTimeNow = NOW
         vTimeResp = 0
         .
      FOR EACH buf_code NO-LOCK WHERE buf_code.parent = "CDN_GisMt":
          IF buf_code.code <> "CDN_Upd" THEN DO:
              dbgPrint("marking.log", SUBSTITUTE("Площадка &1 Время отклика &2 Время блокировки &3 Текущее время &4 ",
                                                 buf_code.code,
                                                 buf_code.codeval,
                                                 buf_code.misc2,
                                                 vTimeNow)).
              IF buf_code.misc2 = ""
              THEN DO:
                  IF vTimeResp = 0 OR
                     vTimeResp = ? OR
                     vTimeResp > int(buf_code.codeval)
                  THEN
                     ASSIGN
                        vAddr = buf_code.code
                        vTimeResp = int(buf_code.codeval) no-error.
              END.
          END.
          ELSE dbgPrint("marking.log", SUBSTITUTE("Идет процесс обновления CDN площадок, время начала &1 ",buf_code.codeval)).
      END.
      IF vAddr <> "" THEN
         dbgPrint("marking.log", SUBSTITUTE("Выбрали площадку &1 время отклика &2 ",vAddr,vTimeResp)).
      ELSE dbgPrint("marking.log", "Не удалось подобрать площадку.").
      RETURN vAddr.
  END METHOD.
  METHOD PRIVATE LOGICAL SetCDNAdressErr (
      iCdnAdr AS CHARACTER):
      DEF BUFFER buf_code FOR ub.code.
      DEF VAR vTimeNow AS DATETIME NO-UNDO.
      DEF VAR vOk AS LOG NO-UNDO.
      setsdn:
      DO TRANSACTION ON ERROR UNDO, RETRY setsdn:
          vTimeNow = NOW.
          FIND FIRST buf_code WHERE
                     buf_code.parent = "CDN_GisMt"
                 AND buf_code.code = iCdnAdr
                 EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
          IF AVAIL buf_code THEN  DO:
             buf_code.misc2 = STRING(vTimeNow + 15000 * 60).
             RELEASE buf_code NO-ERROR.
             IF ERROR-STATUS:ERROR THEN vOk = NO.
             ELSE vOk = YES.
          END.
          ELSE IF LOCKED buf_code THEN
          DO:
             vOk = NO.
             dbgPrint("marking.log", SUBSTITUTE("Заблокирована запись установки блокировки площадки &1", iCdnAdr)).
          END.
          ELSE vOk = NO.
          dbgPrint("marking.log", SUBSTITUTE("Установка площадке &1 время разблокировки &2 успешно &3 &4",
                                             iCdnAdr, (vTimeNow + 15000 * 60), vOk, ERROR-STATUS:GET-MESSAGE(1))).
      END.
      IF RETRY THEN DO:
          dbgPrint("marking.log", SUBSTITUTE("Ошибка блокировки площадки &1", iCdnAdr)).
      END.
      RETURN vOk.
  END METHOD.
  METHOD PUBLIC INTEGER CheckCdnNeedUpd ():
      DEF BUFFER buf_code FOR ub.code.
      DEF VAR vAddr AS CHAR NO-UNDO.
      DEF VAR vNeedUpd AS LOG NO-UNDO.
      DEF VAR vNeedTimeUpd AS LOG NO-UNDO.
      DEF VAR vReturnValue AS INTEGER NO-UNDO.
      DEF VAR vAllBlock AS LOG NO-UNDO.
      DEF VAR vTimeNow AS DATETIME-TZ NO-UNDO.
      DEF VAR vTimeUpd AS DATETIME-TZ NO-UNDO.
      DEF VAR vTimeUnbl AS DATETIME-TZ NO-UNDO.
      ASSIGN
         vTimeNow = NOW
         vTimeUpd = ?
         .
      vAllBlock = YES.
      block_code:
      FOR EACH buf_code NO-LOCK WHERE buf_code.parent = "CDN_GisMt":
          vTimeUpd = DATETIME-TZ(buf_code.misc1) NO-ERROR.
          IF buf_code.misc2 <> "" THEN DO:
             vTimeUnbl = DATETIME-TZ(buf_code.misc2) NO-ERROR.
             IF vTimeUnbl < vTimeNow THEN vNeedTimeUpd = YES.
             dbgPrint("marking.log", SUBSTITUTE("Площадка &1 заблокирована &2, требует обновления &3",
                                                  buf_code.code,
                                                  vTimeUnbl,
                                                  vTimeUnbl < vTimeNow)
                     ).
          END.
          IF buf_code.misc2 = ""
          THEN DO:
             vAllBlock = NO.
          END.
      END.
      IF vAllBlock OR
         (vTimeUpd = ? OR
         (vTimeUpd <> ? AND
          datetime-tz(vTimeUpd) < vTimeNow AND
          (vTimeNow - datetime-tz(vTimeUpd)) >= gismt-cdnTimeUpd * 3600 * 1000))
      THEN DO:
         FIND FIRST buf_code WHERE
                  buf_code.parent = "CDN_GisMt"
              AND buf_code.code = "CDN_Upd"
           NO-LOCK NO-ERROR.
         IF NOT AVAIL buf_code
         THEN DO:
            dbgPrint("marking.log", SUBSTITUTE("Обновляем список площадок, все заблокированы &1 время посл обновления &2 Частота обновления (ч) &3 ",
                                              vAllBlock, vTimeUpd, gismt-cdnTimeUpd )).
            vNeedUpd = YES.
         END.
         ELSE IF DATETIME-TZ(buf_code.codeval) < (NOW - 20 * 60000) THEN DO:
            dbgPrint("marking.log", SUBSTITUTE("Обновляем список площадок, флаг обновления был установлен &1",
                                                buf_code.codeval )).
            vNeedUpd = YES.
         END.
         ELSE dbgPrint("marking.log", SUBSTITUTE("Площадки не обновляем, идет обновление &1 ",  buf_code.codeval)).
      END.
      ELSE IF vNeedTimeUpd THEN DO:
         FIND FIRST buf_code WHERE
                  buf_code.parent = "CDN_GisMt"
              AND buf_code.code = "CDN_Upd"
           NO-LOCK NO-ERROR.
         IF AVAIL buf_code
         THEN DO:
             vNeedTimeUpd = NO.
             dbgPrint("marking.log", SUBSTITUTE("Заблокированную площадку не обновляем, идет обновление &1 ",  buf_code.codeval)).
         END.
         ELSE dbgPrint("marking.log", SUBSTITUTE("Обновляем заблокированную площадку, 15 минут блокировки истекли в &1",
                                              vTimeUpd )).
      END.
      ELSE
         dbgPrint("marking.log", SUBSTITUTE("Площадки не обновляем. Все заблокированы? &1 Время последнего обновления &2 Частота обновления (ч) &3 Заблокированные площадки &4",
                                              vAllBlock, vTimeUpd, gismt-cdnTimeUpd, vNeedTimeUpd )).
      IF vNeedUpd THEN vReturnValue = 1.
      ELSE IF vNeedTimeUpd then vReturnValue = 2.
      ELSE vReturnValue = 0.
      dbgPrint("marking.log", SUBSTITUTE("Возвращаем значение &1 об обновлении площадок",
                                         vReturnValue )).
      RETURN vReturnValue.
  END METHOD.
  METHOD PRIVATE INTEGER RunCurlGisMT (
     vGisAdress AS CHARACTER,
     vDataMark AS CHARACTER,
     vDataMarkLM AS CHARACTER,
     CmdParamProxy AS CHARACTER,
     vFileResult AS CHARACTER,
     vFileResultErr AS CHARACTER,
     vFileBat AS CHARACTER,
     vFileResOf AS CHARACTER,
     vFileResOfErr AS CHARACTER,
     vFileBatOf AS CHARACTER
     ):
    DEFINE VARIABLE vBefCurl AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vAftCurl AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vpid     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE vTimePause AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vRetVal AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cmd AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vlongJson AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE vlongJson2 AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE vCh AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vNumCode AS INTEGER NO-UNDO.
    DEFINE VARIABLE vNumCode2 AS INTEGER NO-UNDO.
    DEFINE VARIABLE vcmdof AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vpidof AS INTEGER     NO-UNDO.
    vRetVal = -1.
    cmd = SUBSTITUTE ('&1 &8 --connect-timeout &9 --max-time &9 -X POST -H "Content-Type: application/json" -H &5 &6 --data @&4 &3 >&2 --stderr &7',
                      SEARCH ("exe/curl.exe"),
                      vFileResult,
                      QUOTER(vGisAdress),
                      searchfile(vDataMark),
                      QUOTER("X-api-Key: " + gismt-RegKey),
                      CmdParamProxy,
                      vFileResultErr,
                      gismt-DopParam,
                      TRIM(REPLACE(STRING(gismt-WaitTime + gismt-WaitTimePlus, "zzzz9.99999"),".",","),"")).
    dbgPrint("marking.log", "cmd: " + cmd).
    vBefCurl = NOW.
    vpid = runProcFile(cmd, vFileBat).
    IF vFileBatOf <> "" THEN DO:
        vcmdof = SUBSTITUTE ('&1 --connect-timeout &6 --max-time &6 -X POST -H "Accept: application/json" -H &2 --data @&7 &3 >&4 --stderr &5',
                          SEARCH ("exe/curl.exe"),
                          QUOTER("Authorization: Basic " + gismt-OflineAutoriz),
                          QUOTER(gismt-OflineAdress + "/cis/outCheck"),
                          vFileResOf,
                          vFileResOfErr,
                          TRIM(REPLACE(STRING(gismt-WaitTime, "zzzz9.99999"),".",","),""),
                          searchfile(vDataMarkLM)).
        dbgPrint("marking.log", "vcmdof: " + vcmdof).
        vpidof = runProcFile(vcmdof, vFileBatOf).
    END.
    block_wait:
    DO WHILE TRUE:
        IF searchFile(vfileresult) <> ? THEN DO:
            FILE-INFO:FILE-NAME = searchFile(vfileresult).
            IF FILE-INFO:FILE-SIZE <> 0 THEN DO:
               COPY-LOB FROM FILE vFileResult TO vlongJson NO-ERROR.
               IF (vlongJson BEGINS "<html>" AND
                   r-index(vlongJson,"</html>") > 0)
                  OR
                  (R-INDEX(vlongJson,"reqTimestamp") > 0 AND
                   r-index(SUBSTRING(vlongJson,R-INDEX(vlongJson,"reqTimestamp")),"}") > 0)
                  OR r-index(vlongJson,'"codes":[]}') > 0
               THEN DO:
                   dbgPrint("marking.log", SUBSTITUTE("Сформирован файл-ответ &1", vfileresult)).
                   LEAVE block_wait.
               END.
            END.
        END.
        IF vBefCurl + Int((gismt-WaitTime + gismt-WaitTimePlus) * 1000) < NOW THEN DO:
           dbgPrint("marking.log", "Время ожидания работы curl истекло").
           LEAVE block_wait.
        END.
        vTimePause = NOW - (vBefCurl + Int((gismt-WaitTime + gismt-WaitTimePlus) * 1000)) + 10.
        IF vTimePause < -10 THEN
           RUN gbl/pause.p(10).
        ELSE IF vTimePause < 0 AND vTimePause > -10
        THEN
           RUN gbl/pause.p(0 - vTimePause).
    END.
    vAftCurl = NOW.
    dbgPrint("marking.log", SUBSTITUTE("Время работы curl: Начало &1 Окончание &2 Всего (мс) &3  ", vBefCurl, vAftCurl, vAftCurl - vBefCurl)).
    vRetVal = ChkCurlGisMT (vlongJson).
    RETURN vRetVal.
  END METHOD.
  METHOD PRIVATE INTEGER ChkCurlGisMT (
    ilongJson AS LONGCHAR
    ):
    DEFINE VARIABLE vRetVal AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vlongJson2 AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE vCh AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vNumCode AS INTEGER NO-UNDO.
    DEFINE VARIABLE vNumCode2 AS INTEGER NO-UNDO.
    vRetVal = -1.
    IF ilongJson BEGINS "<html>" AND index(ilongJson,"<title>") > 0 THEN
       vRetVal =  int(SUBSTRING(iLongJson, INDEX(iLongJson,"<title>") + 7,3)) NO-ERROR.
    ELSE IF INDEX(ilongJson,'"code":') > 0 THEN DO:
       vNumCode = INDEX(iLongJson,'"code":') + 7.
       vlongJson2 = SUBSTRING(iLongJson, vNumCode).
       vNumCode2 = INDEX(vLongJson2,",") - 1.
       vCh = STRING(SUBSTRING(iLongJson, vNumCode, vNumCode2)).
       vRetVal  = int(vCh).
    END.
    RETURN vRetVal.
  END METHOD.
  METHOD PRIVATE CHARACTER ChekLocalMark (
    mark-short AS CHARACTER
  ):
     DEFINE VARIABLE vFileResult  AS CHARACTER   NO-UNDO.
     DEFINE VARIABLE vFileLog     AS CHARACTER   NO-UNDO.
     DEFINE VARIABLE vlongJson    AS LONGCHAR NO-UNDO.
     DEFINE VARIABLE hDS          AS HANDLE NO-UNDO.
     DEFINE VARIABLE vFileResJson AS CHARACTER   NO-UNDO.
     DEFINE VARIABLE vRetOk       AS LOGICAL NO-UNDO.
     DEFINE VARIABLE vErrSts      AS CHARACTER   NO-UNDO.
     DEFINE VARIABLE vChkNotSell  AS LOG       NO-UNDO.
     DEFINE VARIABLE vErrTxt      AS CHARACTER NO-UNDO.
     ASSIGN
        vChkNotSell = NO
        vFileLog = "GisMtReq-" + replace(STRING(TODAY),"/","-") +  ".log"
        vErrTxt = "Ошибка при проверке товара в локальном модуле Честный знак. Товар не добавлен в чек. Сообщите управляющему/старшему смены. "
        mCheckStsOff = 0
        .
     FIND FIRST tt-file-name WHERE tt-file-name.ofline = YES NO-ERROR.
     IF AVAIL tt-file-name
        AND searchFile(tt-file-name.tmpFileName) <> ?
     THEN  DO:
        dbgPrint("marking.log", SUBSTITUTE("Файл офлайн-проверки &1 ", tt-file-name.tmpFileName)).
        vFileResult = searchFile(tt-file-name.tmpFileName).
        COPY-LOB FROM FILE vFileResult TO vlongJson NO-ERROR.
        hDS = DATASET gismt-local-mark:HANDLE.
        vRetOk  = hDS:read-json("longchar":U, vlongJson) NO-ERROR.
        DATASET gismt-local-mark:WRITE-JSON("FILE":U, vFileResJson) NO-ERROR.
        dbgPrint("marking.log", "ttlocal-mark").
        FIND FIRST ttlocal-mark NO-ERROR.
        IF AVAIL ttlocal-mark THEN DO:
            FIND FIRST ttlocal-mark-code NO-ERROR.
            ASSIGN
               mReqId = STRING(ttlocal-mark.ReqId)
               mReqTimestamp = STRING(ttlocal-mark.ReqTimestamp)
               mInst = ttlocal-mark.inst
               mVersion = ttlocal-mark.version
               .
           IF ttlocal-mark.errorCode > 0 THEN DO:
              ASSIGN
                 mCheckSts = 0
                 mCheckStsOff = 3
                 vErrSts = vErrTxt.
              dbgPrint("marking.log", SUBSTITUTE("Ошибка проверки КИ в ЛМ ЧЗ. Ошибка errorCode &1 reason &2", ttlocal-mark.errorCode, ttlocal-mark.reason)).
           END.
           ELSE IF ttlocal-mark.code <> 0 THEN DO:
              ASSIGN
                 mCheckSts = 0
                 mCheckStsOff = 3
                 vErrSts = vErrTxt.
              dbgPrint("marking.log", SUBSTITUTE("Ошибка проверки КИ в ЛМ ЧЗ. Ошибка Code &1 Описание &2", ttlocal-mark.code, ttlocal-mark.description)).
           END.
           IF mReqId = "" OR
              mReqTimestamp = "" OR
              mInst = "" OR
              mVersion = ""
           THEN DO:
              ASSIGN
                 mCheckSts = 0
                 mCheckStsOff = 3
                 vErrSts = vErrTxt.
              dbgPrint("marking.log",
                       SUBSTITUTE("Ошибка проверки КИ в ЛМ ЧЗ. Не определился один из обязательных параметров: ReqId &1 ReqTimestamp &2 Inst &3 Version &4 ",
                                  mReqId, mReqTimestamp, mInst, mVersion)).
           END.
           ELSE IF NOT AVAIL ttlocal-mark-code THEN DO:
              ASSIGN
                 mCheckSts = 0
                 mCheckStsOff = 3
                 vErrSts = vErrTxt.
              dbgPrint("marking.log", "Ошибка проверки КИ в ЛМ ЧЗ. Не удалось разобрать секцию codes").
           END.
           ELSE DO:
               IF ttlocal-mark-code.isBlocked THEN
               DO:
                   ASSIGN
                      vChkNotSell = YES
                      mCheckStsOff = 0
                      mCheckSts = 0
                      .
                   dbgPrint("marking.log", "КИ в ЛМ ЧЗ помечена как запрещенная к продаже.").
                   vErrSts = "Реализация товара запрещена контролирующими органами. Снимите с продажи и передайте товар управляющему/старшему смены. ".
               END.
               ELSE DO:
                  ASSIGN
                     mCheckSts = 2
                     mCheckStsOff = 1
                     vErrSts = "".
                  dbgPrint("marking.log", "Проверка в ЛМ ЧЗ прошла успешно.").
               END.
           END.
        END.
        ELSE DO:
            ASSIGN
               mCheckSts = 0
               mCheckStsOff = 3
               vErrSts = vErrTxt.
            dbgPrint("marking.log", "Ошибка проверки КИ в ЛМ ЧЗ.").
        END.
        OUTPUT STREAM out_data TO value(vFileLog) APPEND.
        PUT STREAM out_data UNFORMATTED
             NOW CHR(9) .
        OUTPUT STREAM out_data CLOSE.
        if vlongJson <> "" then
        COPY-LOB FROM vlongJson TO FILE vFileLog APPEND NO-ERROR.
        else do:
            OUTPUT STREAM out_data TO value(vFileLog) APPEND.
            PUT STREAM out_data UNFORMATTED
                "Отсутствует ответ ЛМ ЧЗ".
            OUTPUT STREAM out_data CLOSE.
        end.
     END.
     ELSE DO:
        ASSIGN
           mCheckSts = 0
           mCheckStsOff = 3
           vErrSts = vErrTxt.
        dbgPrint("marking.log", "Отсутствует файл офлайн проверки в ЛМ ЧЗ.").
        OUTPUT STREAM out_data TO value(vFileLog) APPEND.
        PUT STREAM out_data UNFORMATTED
             NOW CHR(9) "Отсутствует ответ ЛМ ЧЗ".
        OUTPUT STREAM out_data CLOSE.
     END.
     IF mCheckSts = 0 AND NOT vChkNotSell
     AND (TODAY < gismt-OflineDate
          OR mCheckGisMT = 2)
     THEN  do:
         ASSIGN
            mCheckSts = 2
            mCheckStsOff = 2
            vErrSts = "".
         dbgPrint("marking.log", SUBSTITUTE("Разрешаем продавать при отсутствии ответа от ЛМ ЧЗ. mCheckSts &4 vChkNotSell &1 gismt-OflineDate &2 mCheckGisMT &3 mCheckStsOff &5",
                                            vChkNotSell, gismt-OflineDate, mCheckGisMT, mCheckSts, mCheckStsOff)).
     end.
     else do:
         IF mCheckSts = 0 then
            dbgPrint("marking.log", SUBSTITUTE("Не разрешаем продавать. mCheckSts &4 vChkNotSell &1 gismt-OflineDate &2 mCheckGisMT &3 mCheckStsOff &5",
                                               vChkNotSell, gismt-OflineDate, mCheckGisMT, mCheckSts, mCheckStsOff)).
         else
            dbgPrint("marking.log", SUBSTITUTE("Разрешаем продавать. mCheckSts &4 vChkNotSell &1 gismt-OflineDate &2 mCheckGisMT &3 mCheckStsOff &5",
                                               vChkNotSell, gismt-OflineDate, mCheckGisMT, mCheckSts, mCheckStsOff)).
     end.
     RETURN vErrSts.
  END.
  METHOD PRIVATE INTEGER GetResLocalMark (
    vDataMarkLM AS CHARACTER
  ):
    DEFINE VARIABLE vMarkShort AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vFileResOf AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vFileResOfErr AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vFileBatOf AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vBefCurl AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vAftCurl AS DATETIME-TZ NO-UNDO.
    DEFINE VARIABLE vpid     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE vTimePause AS INTEGER   NO-UNDO.
    DEFINE VARIABLE vRetVal AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cmd AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vlongJson AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE vlongJson2 AS LONGCHAR NO-UNDO.
    DEFINE VARIABLE vCh AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vNumCode AS INTEGER NO-UNDO.
    DEFINE VARIABLE vNumCode2 AS INTEGER NO-UNDO.
    DEFINE VARIABLE vcmdof AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vpidof AS INTEGER     NO-UNDO.
    RUN gbl/_tmpfile.p ( "ChkLMRes", ".txt", OUTPUT vFileResOf ) .
    CREATE tt-file-name.
    ASSIGN tt-file-name.tmpFileName = vFileResOf
           tt-file-name.ofline = YES.
    RUN gbl/_tmpfile.p ( "ChkLMResErr", ".txt", OUTPUT vFileResOfErr ) .
    CREATE tt-file-name.
    ASSIGN tt-file-name.tmpFileName = vFileResOfErr.
    RUN gbl/_tmpfile.p ( "ChkLM", ".bat", OUTPUT vFileBatOf ) .
    CREATE tt-file-name.
    ASSIGN tt-file-name.tmpFileName = vFileBatOf.
    dbgPrint("marking.log", SUBSTITUTE("vFileResOf &1 ", vFileResOf)).
    dbgPrint("marking.log", SUBSTITUTE("vFileResOfErr &1 ", vFileResOfErr)).
    dbgPrint("marking.log", SUBSTITUTE("vFileBatOf &1 ", vFileBatOf)).
    vcmdof = SUBSTITUTE ('&1 --connect-timeout &6 --max-time &6 -X POST -H "Accept: application/json" -H &2 --data @&7 &3 >&4 --stderr &5',
                          SEARCH ("exe/curl.exe"),
                          QUOTER("Authorization: Basic " + gismt-OflineAutoriz),
                          QUOTER(gismt-OflineAdress + "/cis/outCheck"),
                          vFileResOf,
                          vFileResOfErr,
                          TRIM(REPLACE(STRING(gismt-WaitTime, "zzzz9.99999"),".",","),""),
                          searchfile(vDataMarkLM)).
    dbgPrint("marking.log", "vcmdof: " + vcmdof).
    vBefCurl = NOW.
    vpidof = runProcFile(vcmdof, vFileBatOf).
    block_wait:
    DO WHILE TRUE:
        IF searchFile(vfileresOf) <> ? THEN DO:
            FILE-INFO:FILE-NAME = searchFile(vfileresOf).
            IF FILE-INFO:FILE-SIZE <> 0 THEN DO:
               COPY-LOB FROM FILE vFileResOf TO vlongJson NO-ERROR.
               IF (vlongJson BEGINS "<html>" AND
                   r-index(vlongJson,"</html>") > 0)
                  OR
                  (R-INDEX(vlongJson,"reqTimestamp") > 0 AND
                   r-index(SUBSTRING(vlongJson,R-INDEX(vlongJson,"reqTimestamp")),"}") > 0)
                  OR r-index(vlongJson,'"codes":[]}') > 0
               THEN DO:
                   dbgPrint("marking.log", SUBSTITUTE("Сформирован файл-ответ от ЛМ ЧЗ &1", vfileresOf)).
                   LEAVE block_wait.
               END.
            END.
        END.
        IF vBefCurl + Int(gismt-WaitTime * 1000) < NOW THEN DO:
           dbgPrint("marking.log", "Время ожидания работы curl истекло").
           LEAVE block_wait.
        END.
        vTimePause = NOW - (vBefCurl + Int(gismt-WaitTime * 1000)) + 10.
        IF vTimePause < -10 THEN
           RUN gbl/pause.p(10).
        ELSE IF vTimePause < 0 AND vTimePause > -10
        THEN
           RUN gbl/pause.p(0 - vTimePause).
    END.
    vAftCurl = NOW.
    dbgPrint("marking.log", SUBSTITUTE("Время работы curl: Начало &1 Окончание &2 Всего (мс) &3  ", vBefCurl, vAftCurl, vAftCurl - vBefCurl)).
    RETURN 1.
 END.
  METHOD PRIVATE VOID DelTmpFile(
      iOfline AS LOGICAL
      ):
      FOR EACH tt-file-name WHERE tt-file-name.ofline = iOfline:
          IF NOT SESSION:DEBUG-ALERT
          THEN DO:
             IF searchFile(tt-file-name.tmpFileName) <> ? THEN DO:
                 OS-DELETE silent value(tt-file-name.tmpFileName).
             END.
             IF searchFile(tt-file-name.tmpFileName) = ? THEN
             DELETE tt-file-name.
          END.
          ELSE DELETE tt-file-name.
      END.
  END METHOD.
  METHOD PUBLIC CHARACTER percentCoding(decode-str AS CHAR):
    DEFINE VARIABLE ii AS INTEGER NO-UNDO.
    DEFINE VARIABLE encode-str AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vsimb  AS CHARACTER NO-UNDO.
    DEFINE VARIABLE spec-str  AS CHARACTER INIT "~"!#$%&'()*+,-./:;<=>?@[\]^" NO-UNDO.
    DEFINE VARIABLE vInd AS INTEGER NO-UNDO.
    encode-str = "".
    DO ii = 1 TO LENGTH (decode-str):
      vsimb = SUBSTRING(decode-str,ii,1).
      vInd = INDEX(spec-str,vsimb).
      encode-str = encode-str + (IF vInd = 0 THEN vsimb ELSE ("%%" + hexencode(vsimb))).
    END.
    RETURN encode-str.
  END METHOD.
  METHOD PUBLIC CHARACTER hexencode(decode-chr AS CHAR):
    DEFINE VARIABLE vRaw       AS RAW NO-UNDO.
    DEFINE VARIABLE encode-chr AS CHARACTER NO-UNDO.
    LENGTH(vRaw) = 1.
    put-string(vRaw, 1, 1) = decode-chr.
    encode-chr  = HEX-ENCODE(vRaw).
    LENGTH(vRaw) = 0.
    RETURN encode-chr.
  END METHOD.
  define variable vMsg as character no-undo.
  define frame fMsg
    vMsg format "x(72)" no-label skip
    with view-as dialog-box side-labels three-d
  .
  METHOD PUBLIC INTEGER checkScanMark (
    iObjCode AS INTEGER,
    iMark AS CHARACTER,
    iMarkShort AS CHARACTER,
    iRunOffLine AS LOGICAL,
    OUTPUT oRunedOffLine AS LOGICAL
  ):
    DEFINE VARIABLE vAccMarkCheck AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vMarkGs       AS CHARACTER NO-UNDO.
    DEFINE VARIABLE vChkScanSts   AS INTEGER   NO-UNDO.
    DEFINE BUFFER buf_marking FOR ub.marking.
    dbgPrint("marking.log", SUBSTITUTE("Проверка марки для документа iObjCode &1 iMark &2 iMarkShort &3 iRunOffLine &4",
                                       iObjCode,
                                       iMark,
                                       iMarkShort,
                                       iRunOffLine)).
    gismt-WaitTimePlus = 3.
    oRunedOffLine = false.
    IF iMarkShort = ? THEN
    DO:
      iMarkShort = GetCodeIdent(iMark).
      IF iMarkShort = "" OR iMarkShort = ? THEN
        RETURN 2.
    END.
    assign
      mCheckGisMT = 0
      vMarkGs     = addGs2Mark(iMark)
      mMarkOrig   = vMarkGs
    .
    dbgPrint("marking.log", SUBSTITUTE("Отправка марки в ГИС МТ: &1 -> &2.",
                                       iMark,
                                       replace(vMarkGs,chr(29),"<gs>"))).
    vMsg = "Идет проверка марки, пожалуйста, подождите.".
    frame fMsg:visible = true.
    display vMsg with frame fMsg.
    vAccMarkCheck = ChekAccessMark('маг':U,iObjCode,vMarkGs,iMarkShort).
    hide frame fMsg.
    dbgPrint("marking.log", SUBSTITUTE("Проверка ГИС МТ: &1 Статус: &2 mReqId &3 mReqTimeStamp &4 mCheckGisMT &5",
                                       vAccMarkCheck,
                                       mCheckSts,
                                       mReqId,
                                       mReqTimeStamp,
                                       mCheckGisMT)).
    IF mCheckSts = 3 THEN vChkScanSts = 0.
    ELSE IF mCheckSts = 4 THEN vChkScanSts = 2.
    ELSE vChkScanSts = mCheckSts.
    IF NOT iRunOffLine AND vChkScanSts = 2 THEN DO:
        CASE mCheckGisMT:
           WHEN 0 THEN
           DO:
              vChkScanSts = 2.
           END.
           WHEN 1 THEN
           DO:
              vChkScanSts = 1.
           END.
           WHEN 2 THEN
           DO:
              vChkScanSts = 1.
           END.
        END CASE.
    END.
    IF iRunOffLine THEN DO:
       IF mCheckGisMT = 1 AND vChkScanSts = 2  THEN vChkScanSts = 1.
       IF (vChkScanSts = 2 AND mCheckGisMT = 0) OR mCheckGisMT = 2
       THEN DO:
           oRunedOffLine = true.
           vAccMarkCheck = ChekLocalMark(iMarkShort).
           vChkScanSts = mCheckStsOff.
       END.
    END.
    dbgPrint("marking.log", SUBSTITUTE("Результат проверки ГИС МТ и ЛМ ЧЗ: &1 Проверка офлайн &2",
                                       vChkScanSts,
                                       oRunedOffLine)).
    RETURN vChkScanSts.
  END METHOD.
  METHOD PUBLIC CHARACTER ChekExpirationDate (
      p-obj-type  AS CHARACTER,
      p-obj-code  AS INTEGER,
      buffer buf_marking for ub.marking):
      DEFINE VARIABLE vExpireDate AS DATETIME-TZ NO-UNDO.
      DEFINE VARIABLE vCheckDate  AS LOGICAL     NO-UNDO.
      DEFINE VARIABLE vRetProp    AS CHARACTER   NO-UNDO.
      DEFINE VARIABLE vErrTxt     AS CHARACTER   NO-UNDO.
      DEFINE BUFFER buf_sys-ctrl     FOR ub.sys-ctrl.
      IF AVAILABLE buf_marking THEN
      DO:
         mTypeMark = "".
         ChekTypeMarkByDm(buf_marking.mark) .
      END.
      dbgPrint("marking.log", SUBSTITUTE("Проверка срока годности для типа марки &1 марка &2",
                                         mTypeMark,
                                         (IF AVAILABLE buf_marking then buf_marking.mark else mark))).
      if mTypeMark = ""
      then do :
         ASSIGN
           vErrTxt = "Не опредлен тип маркировки товара. "
           mCheckSts = 0
           .
      end .
      IF mTypeMark > "" THEN
         vCheckDate = GetMarkProp (p-obj-type,
                                   p-obj-code,
                                   'checkDate':U,
                                   mTypeMark).
      dbgPrint("marking.log", SUBSTITUTE("Требуется ли проверять срок годности &1", vCheckDate)).
      IF vCheckDate THEN DO:
         IF AVAILABLE buf_marking
             AND buf_marking.expDate <> ?
         THEN vExpireDate = datetime-tz(ENTRY(1,buf_marking.expDate,".")) NO-ERROR.
         IF vExpireDate = ?
         THEN DO:
            IF (StatusPos = 1 OR StatusPos = 2)
               AND mCheckSts = 1
            THEN mCheckSts = 2 .
            dbgPrint("marking.log", SUBSTITUTE("Срок годности для марки &1 по данным из 1С отсутствует. Дата &2. Проверить срок годности не удалось.",
                                               (IF AVAILABLE buf_marking then buf_marking.mark ELSE "<не найдена>"),
                                               (IF AVAILABLE buf_marking then buf_marking.expDate ELSE ""))).
         END.
         ELSE IF vExpireDate < NOW + gismt-BanDate * 60 * 1000
         THEN DO:
            ASSIGN
               vErrTxt   = substitute("Срок годности товара истек &1.", substring(string(vExpireDate,"99/99/9999 HH:MM+HH:MM"), 1, 16))
               mCheckSts = 0
               .
            LogWrite:WriteFileToLog(SUBSTITUTE("Проверка срока годности не прошла: марка &1 срок годности &2",buf_marking.mark,string(vExpireDate,"99/99/9999 HH:MM"))).
            dbgPrint("marking.log", SUBSTITUTE("Срок годности по данным из 1С: &1 . Товар просрочен, заблокирован к продаже.",
                                               vExpireDate)).
         END.
         ELSE DO:
            IF (StatusPos = 1 OR StatusPos = 2)
               AND mCheckSts = 2
            THEN mCheckSts = 1 .
            LogWrite:WriteFileToLog(SUBSTITUTE("Проверка срока годности прошла успешно: марка &1 срок годности &2",buf_marking.mark,string(vExpireDate,"99/99/9999 HH:MM"))).
            dbgPrint("marking.log", SUBSTITUTE("Срок годности по данным из 1С: &1 . Проверка прошла успешно.",
                                                vExpireDate)).
         END.
      END.
      ELSE IF (StatusPos = 2 AND mCheckSts = 2)
           THEN mCheckSts = 1.
      RETURN vErrTxt.
  END METHOD.
  METHOD PRIVATE VOID setOnlineResult(buffer buf_marking for ub.marking):
    IF statusPOS <> ? AND mCheckGisMT = 1
    THEN ASSIGN
            buf_marking.online-result = mCheckStsSave
            mSaveOnlineResult = yes
            .
    ELSE DO:
       IF (mCheckSts = 0 AND mCheckGisMT = 1) OR mCheckSts = 3
       THEN
         buf_marking.online-result = 0.
       ELSE IF mCheckSts = 2 AND mCheckGisMT = 1
       THEN
         buf_marking.online-result = 2.
       ELSE IF mCheckSts = 1 AND mCheckGisMT = 1
       THEN
         buf_marking.online-result = 1.
    END.
    dbgprint("marking.log", SUBSTITUTE("Установка марке &1 результата проверки онлайн &2, mCheckSts &3 mCheckGisMT &4 ",
                                       buf_marking.mark, buf_marking.online-result, mCheckSts, mCheckGisMT )).
  END METHOD.
  METHOD PUBLIC CHARACTER GetMarkOnlineResult():
    define variable mark-short as character no-undo.
    mark-short = GetCodeIdent(mark).
    IF mSaveOnlineResult = yes THEN
       RETURN substitute("&1&2&3",mark-short,chr(9),mCheckStsSave).
    ELSE
       RETURN "".
  END METHOD.
        DESTRUCTOR PUBLIC marking ( ):
      DELETE OBJECT cashSts.
        END DESTRUCTOR.
END CLASS.
