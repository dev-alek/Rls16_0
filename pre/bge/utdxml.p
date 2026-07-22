block-level on error undo, throw.
define variable vss-revision as character no-undo init "$Revision: ef92e69868bb, 3214, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:29 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: UTDxml.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/UTDxml.p $":U .
define variable vss-description as character no-undo init "Выгрузка УПД в XML".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define input  parameter parparentproc as handle no-undo.
define input parameter iDiadocConnection as component-handle no-undo.
define input  parameter iORGGuid as character no-undo.
define input  parameter iContGuid as character no-undo.
define input  parameter iTypeUTD as character no-undo.
define input parameter i-db-num as integer no-undo.
define input parameter i-doc-id as integer no-undo.
function  getdesc returns logical
  (input iObj as component-handle) in source-procedure.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
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
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
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
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
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
                    run xmlchar-read-integer in this-procedure
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
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
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
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
function IS-NeedMark returns logical
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
function repTegforDm return char
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
function repSpecSimbforDm return char
(iDM as char ):
    define variable oDM as character no-undo.
  run
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
function CheckGtin return logical
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
function repSpecSimbforXlm return char
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
function getGtinByDM return char
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
function getGdsCodeByGtin return int
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
function getQntyCodeByGtin return decimal
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
function getGdsCodeByDM return int
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
function ChekTypeMarkByGds return logical
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
function ChekTypeMarkByDm return logical
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
function ChekTypeMarkByGtin return logical
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
function GetNextElement return character
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
function GetCodeIdent return character
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
function GetTegCod return character
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
function isOAD return logical
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
function isMark return logical
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
function addBracketForCode return character
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
function getlevelByCodId return int
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
function getLevelMotpBycodid return character
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
function getLevelUTDByLevelMotp return character
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
function getLevelMotpByDM return character
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
function getLevelUTDByCodId return character
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
function getLevelUTDByDM return character
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
function getQntyUTDByCodId return decimal
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
function getQntyUTDByDM return decimal
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
function getMRC4 return decimal
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
function getMRCByDM return decimal
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
function MoveDate return Date
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
procedure checkEMRC:
define input  parameter iDm as character no-undo.
define output parameter vok as logical   no-undo init yes.
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
            if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
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
function addGs2Mark return character
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
define variable mPublishHand as handle           no-undo.
define variable mDiadocApi   as component-handle no-undo.
define stream File-stream.
define variable mdebug as logical no-undo.
mdebug = session:debug-alert.
function PutMes returns character
(idext as character ):
   if valid-handle(mPublishHand)
   then
      publish "WriteLogAsunc" from mPublishHand (idext,yes).
   else do:
      if idext begins "error"
      then do:
         message substring (idext,6)
            view-as alert-box.
         if mDiadocApi ne ?
         then
            idext = substitute ("&1 (&2)",idext , mDiadocApi:GetFullVersion())no-error.
      end.
      output stream File-stream to "diadoc_user.log" append.
      put stream File-stream unformatted now " " idext skip.
      output stream File-stream close.
   end.
end.
function PutErr returns character
(idext as character ):
   define variable vi as integer no-undo.
   define variable vnumerr as integer no-undo.
   define variable vtext as character extent 25 no-undo .
   if error-status:num-messages > 0 then do:
      vnumerr = error-status:num-messages.
      vnumerr = min(vnumerr,extent(vtext)).
      do vi = 1 to vnumerr:
         vtext[vi] = error-status:get-message(vi).
      end.
      idext = idext + chr(10) + "Ошибка: [":U.
      do vi = 1 to vnumerr:
         idext = idext + chr(10) + vtext[vi] no-error.
      end.
      idext = idext +  chr(10) +  " ]" no-error.
      if not  idext begins "Error"
      then
         idext = "Error " + idext.
      PutMes(idext).
   end.
end.
function PutStat returns character
(itext as character,
 iflag as logical):
   if valid-handle(mPublishHand)
   then
      publish "PutStatAsunc" from mPublishHand (itext,iflag).
   PutMes(itext).
end.
function chekStop returns logical
( ):
   define variable oStop as logical no-undo.
   if valid-handle(mPublishHand)
   then
      publish "StopProc" from mPublishHand (output oStop).
   return oStop.
end.
function  putloggetdesc returns logical
(is1 as character ,is2 as character ,
is3 as character ):
end.
function  getdesc returns logical
(input iObj as component-handle):
   if iObj eq ? then return false.
   if mdebug
   then do:
   output stream File-stream to "diadoc_load.txt" append.
   define variable vReflector as component-handle no-undo.
   define variable vDescobj  as component-handle no-undo.
   define variable vPropertyNames  as component-handle no-undo.
   define variable vMethodsNames as component-handle no-undo.
   define variable vMethodDesc as component-handle no-undo.
   define variable vMethodsName as character  no-undo.
   define variable vPropertyValue as char no-undo.
   create "Diadoc.Reflector" vReflector.
   vDescobj = vReflector:Describe(iObj).
  put   stream File-stream  unformatted skip (1)
   "------------------------------------------" skip
   vDescobj:GetInterfaceName() skip.
   define variable vPropertyName as character no-undo.
   define variable vPropertyType as character no-undo.
   .
   putloggetdesc(vDescobj:GetInterfaceName(),"","").
   putloggetdesc("property","","").
   define variable vi as integer no-undo.
   define variable vii as integer no-undo.
  put stream File-stream  unformatted skip "property" skip.
  vPropertyNames = vDescobj:GetPropertiesNames().
   vi= vPropertyNames:count.
   do vi= 1 to vPropertyNames:count :
      vPropertyName = "".
      vPropertyType = "".
      vPropertyValue = "".
      vPropertyName  = vPropertyNames:GetItem(vi - 1) no-error.
      vPropertyType  = vDescobj:GetPropertyType(vPropertyName) no-error .
      vPropertyValue = substring((vDescobj:GetProperty(vPropertyName)),1,4000) no-error.
      putloggetdesc(vPropertyName,vPropertyType,vPropertyValue).
     put stream File-stream  unformatted vPropertyName " " vPropertyType  " " vPropertyValue skip.
   end.
   release object vPropertyNames.
   put stream File-stream  unformatted skip "method" skip.
   vMethodsNames = vDescobj:GetMethodsNames().
   vi = vMethodsNames:count.
   do vi = 1 to vMethodsNames:count :
      vMethodsName = "".
      vMethodsName = vMethodsNames:GetItem(vi - 1)no-error.
      vMethodDesc  = vDescobj:GetMethodDesc(vMethodsName)no-error.
      putloggetdesc("method",vMethodsName, vMethodDesc:RetVal).
      put stream File-stream  unformatted vMethodsName  " retval " vMethodDesc:RetVal skip.
      do vii  = 1 to vMethodDesc:args:count:
         define variable varg as character no-undo.
         varg = "".
         varg = vMethodDesc:args:GetItem(vii - 1) no-error.
         put stream File-stream  unformatted " args " varg  skip .
         putloggetdesc(" args ",varg, "").
      end.
      release object vMethodDesc.
   end.
   release object vMethodsNames.
   put stream File-stream  unformatted "end---------------------------------------" skip.
   output stream File-stream close.
   release object vDescobj.
   release object vReflector.
   end.
   return true.
end.
function getxsddocum returns logical
(iOrganization as component-handle):
   if iOrganization eq ? then return false.
   define variable vDocumentTypes as component-handle no-undo.
   define variable vDocumentType as component-handle no-undo.
   define variable vFunctions as component-handle no-undo.
   define variable vFunction as component-handle no-undo.
   define variable vVersions as component-handle no-undo.
   define variable vVersion as component-handle no-undo.
   define variable vTitles as component-handle no-undo.
   define variable vTitle as component-handle no-undo.
   define variable vi as integer no-undo.
   define variable vii as integer no-undo.
   define variable viii as integer no-undo.
   define variable viiii as integer no-undo.
   if mdebug
   then do:
   output stream File-stream to "diadoc_doc.txt" append.
   vDocumentTypes = iOrganization:GetDocumentTypes().
   do vi =1 to vDocumentTypes:count:
      vDocumentType = vDocumentTypes:GetItem(vi - 1).
      put stream File-stream  unformatted "DocumentType -> NAme " vDocumentType:name skip.
      put stream File-stream  unformatted "DocumentType -> Title " vDocumentType:Title skip.
      vFunctions = vDocumentType:Functions.
      do vii =1 to vFunctions:count:
         vFunction = vFunctions:GetItem(vii - 1 ).
         put stream File-stream  unformatted "DocumentType -> Function -> NAme " vFunction:name skip.
         vVersions = vFunction:Versions.
         do viii =1 to vVersions:count:
            vVersion = vVersions:GetItem(viii - 1 ).
            put stream File-stream  unformatted "DocumentType -> Function -> Version -> version " vVersion:version skip.
            put stream File-stream  unformatted "DocumentType -> Function -> Version -> IsActual " vVersion:IsActual skip.
            vTitles  = vVersion:Titles.
            do viiii =1 to vTitles:count:
               vTitle = vTitles:GetItem(viiii - 1 ).
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> IsFormal " vTitle:IsFormal skip.
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> XsdUrl " vTitle:XsdUrl skip.
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> HaveUserDataXSD " vTitle:HaveUserDataXSD skip.
               put stream File-stream  unformatted "DocumentType -> Function -> Version -> Title -> type " vTitle:type skip.
               release object vTitle.
            end.
           release object vTitles.
            release object vVersion.
         end.
         release object vVersions.
         release object vFunction.
      end.
      release object vFunctions.
      release object vDocumentType.
   end.
   release object vDocumentTypes.
   put stream File-stream  unformatted "--------------------------------------------------- " skip.
  output stream File-stream close.
  end.
   return true.
end.
define buffer buf_utd               for ub.utd .
define buffer buf_utd-file          for ub.utd-attr .
define buffer buf_utd-lines         for ub.utd-lines .
define buffer buf_utd-lines-attr    for ub.utd-lines-attr .
define buffer buf_utd-marking-lines for ub.utd-marking-lines .
define buffer buf_code              for ub.Code .
define buffer buf_marking           for ub.marking .
define buffer buf_marking-lines     for ub.marking-lines .
define buffer buf_firm              for ub.firm .
define buffer buf_shop              for ub.shop .
define buffer buf_clients           for ub.clients .
define buffer buf_goods             for ub.goods .
define variable filename_        as character        no-undo .
define variable logname          as character        no-undo .
define variable v-nds            as decimal          no-undo .
define variable v-qnty-scan      as decimal          no-undo .
define variable hSAXWriter       as handle           no-undo.
define variable v-doc-level      as integer          no-undo .
define variable v-total-min      as decimal          no-undo .
define variable v-vat-min        as decimal          no-undo .
define variable v-sum-after      as decimal          no-undo .
define variable v-total-max      as decimal          no-undo .
define variable v-vat-max        as decimal          no-undo .
define variable vOrganization    as component-handle no-undo.
define variable vUserperm        as component-handle no-undo.
define variable vUser            as component-handle no-undo.
define variable vCounteragent    as component-handle no-undo.
define variable vCounteragentOrg as component-handle no-undo.
logname = session:temp-directory + "UPD_" + string(i-doc-id) + "_log.txt".
filename_ = "UPD_" + string (i-db-num) + "_" + string (i-doc-id) + ".xml".
find first buf_utd no-lock where buf_utd.db-num eq i-db-num and buf_utd.doc-id = i-doc-id no-error .
if not available (buf_utd) then return error .
vOrganization = iDiadocConnection:GetOrganizationById(iORGGuid) no-error.
if vOrganization eq ?
  then
do:
  PutErr(substitute ("Нет доступа к организации &1",iORGGuid) ).
  return.
end.
vCounteragent = vOrganization:GetCounteragentById(iContGuid).
find first buf_clients no-lock where buf_clients.obj-code = v-cntxt-obj-code and
  buf_clients.obj-type = v-cntxt-obj-type no-error .
create sax-writer hSAXWriter.
hSAXWriter:set-output-destination("file":U, filename_ ).
hSAXWriter:formatted = true.
hSAXWriter:encoding = "windows-1251".
hSAXWriter:start-document().
hSAXWriter:start-element ("Файл":U).
define variable mFileName as character no-undo.
block-mark:
for each buf_utd-marking-lines  where
  buf_utd-marking-lines.db-num = buf_utd.db-num and
  buf_utd-marking-lines.doc-id = buf_utd.doc-id
  no-lock:
  if ismark(buf_utd-marking-lines.mark)
    then
    leave block-mark.
end.
mFileName = substitute ("ON_NSCHFDOPPR&1_&2_&3_&4&5&6_3440B5E2-B3EA-1EEA-9EE0-52DE60B58235"
  , if available buf_utd-marking-lines then  "MARK" else ""
  , vCounteragent:FnsParticipantId
  , vOrganization:FnsParticipantId
  ,STRING(YEAR(TODAY),"9999")
  ,STRING(monTH(TODAY),"99")
  ,STRING(DAY(TODAY),"99")
  ).
hSAXWriter:insert-attribute ("ИдФайл", mFileName) no-error.
hSAXWriter:insert-attribute ("ВерсФорм", "5.01") no-error.
hSAXWriter:insert-attribute ("ВерсПрог", "Diadoc 1.0") no-error.
do:
  hSAXWriter:start-element("СвУчДокОбор":U) no-error.
  hSAXWriter:insert-attribute ("ИдОтпр":U, string(vOrganization:FnsParticipantId)) no-error.
  hSAXWriter:insert-attribute ("ИдПол":U, string(vCounteragent:FnsParticipantId)) no-error.
  do:
    hSAXWriter:write-empty-element("СвОЭДОтпр":U) no-error.
    hSAXWriter:insert-attribute("ИННЮЛ":U, "6663003127") no-error.
    hSAXWriter:insert-attribute("ИдЭДО":U, "2BM") no-error.
    hSAXWriter:insert-attribute("НаимОрг":U, "АО ПФ СКБ Контур") no-error.
  end.
  hSAXWriter:end-element("СвУчДокОбор":U) no-error.
  hSAXWriter:start-element("Документ":U) no-error.
  hSAXWriter:insert-attribute ("КНД":U, "1115131") no-error.
  hSAXWriter:insert-attribute ("Функция":U, iTypeUTD) no-error.
  hSAXWriter:insert-attribute ("ПоФактХЖ":U, "Документ об отгрузке товаров (выполнении работ), передаче имущественных прав (документ об оказании услуг)") no-error.
  hSAXWriter:insert-attribute ("НаимДокОпр":U, "Счет-фактура и документ об отгрузке товаров (выполнении работ), передаче имущественных прав (документ об оказании услуг)") no-error.
  hSAXWriter:insert-attribute ("ДатаИнфПр":U, string(today,"99.99.9999")) no-error.
  hSAXWriter:insert-attribute ("ВремИнфПр":U, replace(string(time,"HH:MM:SS"),":",".")) no-error.
  hSAXWriter:insert-attribute ("НаимЭконСубСост":U, buf_clients.obj-name) no-error.
  do:
    hSAXWriter:start-element("СвСчФакт":U) no-error.
    hSAXWriter:insert-attribute ("НомерСчФ":U, buf_utd.DocumentNumber) no-error.
    hSAXWriter:insert-attribute ("ДатаСчФ":U, string(buf_utd.DocumentDate,"99.99.9999")) no-error.
    hSAXWriter:insert-attribute ("КодОКВ":U, "643") no-error.
    do:
      hSAXWriter:write-empty-element("ИспрСчФ":U) no-error.
      hSAXWriter:insert-attribute("ДефНомИспрСчФ":U, "-") no-error.
      hSAXWriter:insert-attribute("ДефДатаИспрСчФ":U, "-") no-error.
      hSAXWriter:start-element("СвПрод":U) no-error.
      do:
        run proc-init(1, vOrganization) no-error .
        if error-status:error
        then
           return error .
      end.
      hSAXWriter:end-element("СвПрод":U) no-error.
      hSAXWriter:start-element("СвПокуп":U) no-error.
      do:
        run proc-init(2, vCounteragent) no-error .
        if error-status:error
        then
           return error.
      end.
      hSAXWriter:end-element("СвПокуп":U) no-error.
      hSAXWriter:start-element("ИнфПолФХЖ1":U) no-error.
      do:
        if buf_utd.PackageId ne ""
          then
        do:
          hSAXWriter:write-empty-element("ТекстИнф":U) no-error.
          hSAXWriter:insert-attribute("Идентиф":U, "id_pack_th") no-error.
          hSAXWriter:insert-attribute("Значен":U, buf_utd.PackageId) no-error.
        end.
        hSAXWriter:write-empty-element("ТекстИнф":U) no-error.
        hSAXWriter:insert-attribute("Идентиф":U, "id_doc_th") no-error.
        hSAXWriter:insert-attribute("Значен":U, substitute ("&1_&2",buf_utd.db-num,buf_utd.doc-id)) no-error.
      end.
      hSAXWriter:end-element("ИнфПолФХЖ1":U) no-error.
    end.
    hSAXWriter:end-element("СвСчФакт":U) no-error.
    hSAXWriter:start-element("ТаблСчФакт":U) no-error.
    do:
      for each buf_utd-lines no-lock where buf_utd-lines.db-num = buf_utd.db-num and
        buf_utd-lines.doc-id = buf_utd.doc-id:
        hSAXWriter:start-element("СведТов":U) no-error.
        hSAXWriter:insert-attribute ("НомСтр":U, string(buf_utd-lines.LineNum)) no-error.
        hSAXWriter:insert-attribute ("НаимТов":U, string(buf_utd-lines.ProductCode)) no-error.
        find first units no-lock where units.unit-name = buf_utd-lines.UnitCode no-error .
        if available (units)
          and  units.OKEI ne 0
          then
          hSAXWriter:insert-attribute ("ОКЕИ_Тов":U, string(units.OKEI,"999")) no-error.
        else
          hSAXWriter:insert-attribute ("ДефОКЕИ_Тов":U,  "-") no-error.
        hSAXWriter:insert-attribute ("КолТов":U, string (buf_utd-lines.Quantity)) no-error.
        hSAXWriter:insert-attribute ("ЦенаТов":U, trim(string(buf_utd-lines.Price,">>>>>>>>>>>>9.99"))) no-error.
        hSAXWriter:insert-attribute ("СтТовБезНДС":U, trim(string(buf_utd-lines.TotalWithVatExcluded,">>>>>>>>>>>>9.99"))) no-error.
        hSAXWriter:insert-attribute ("НалСт":U, TRIM(string(buf_utd-lines.TaxRate, ">9")) + "%") no-error.
        hSAXWriter:insert-attribute ("СтТовУчНал":U, trim(string(buf_utd-lines.Total,">>>>>>>>>>>>9.99"))) no-error.
        do:
          hSAXWriter:start-element("Акциз":U) no-error.
          do:
            hSAXWriter:start-element("БезАкциз") no-error.
            hsaxwriter:write-characters("без акциза") no-error.
            hSAXWriter:end-element("БезАкциз":U) no-error.
          end.
          hSAXWriter:end-element("Акциз":U) no-error.
          hSAXWriter:start-element("СумНал":U) no-error.
          do:
            hSAXWriter:start-element("СумНал":U) no-error.
            hSAXWriter:write-characters (trim(string(buf_utd-lines.Vat,">>>>>>>>>>>>9.99"))) no-error .
            hSAXWriter:end-element("СумНал":U) no-error.
          end.
          hSAXWriter:end-element("СумНал":U) no-error.
          hSAXWriter:start-element("ДопСведТов":U) no-error.
          do:
            find first buf_goods where buf_goods.gds-code eq buf_utd-lines.gds-code no-lock no-error.
            if available buf_goods or buf_utd-lines.Articl ne ""
              then
              hSAXWriter:insert-attribute("АртикулТов":U, string(if available (buf_goods) then buf_goods.artic else buf_utd-lines.Article)) no-error.
            if available buf_goods or buf_utd-lines.UnitCode ne ""
              then
              hSAXWriter:insert-attribute("НаимЕдИзм":U, string(if available (buf_goods) then buf_goods.unit-base else buf_utd-lines.UnitCode)) no-error.
            hSAXWriter:insert-attribute("ПрТовРаб":U, "1") no-error.
            define variable Vfrist as logical no-undo.
            Vfrist = yes.
            for each buf_utd-marking-lines no-lock where
              buf_utd-marking-lines.db-num = buf_utd-lines.db-num and
              buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id and
              buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum and
              buf_utd-marking-lines.doc-level eq 1:
              define variable vTeg as character no-undo.
              if isMark(buf_utd-marking-lines.mark)
                then
              do:
                find first marking where marking.mark eq buf_utd-marking-lines.mark no-lock no-error.
                if available marking
                  and marking.box-qnty > 1
                  then
                do:
                  vTeg = "НомУпак".
                end.
                else
                  vTeg = "НомУпак".
              end.
              else if ISOAD(buf_utd-marking-lines.mark)
                  then
                  vTeg = "НомУпак".
                else
                  vTeg = "".
              if vTeg ne ""
                then
              do:
                if vfrist
                  then
                do:
                  vfrist = no.
                  hSAXWriter:start-element("НомСредИдентТов":U) no-error.
                end.
                hSAXWriter:start-element(vTeg) no-error.
                hSAXWriter:write-characters(buf_utd-marking-lines.mark) no-error.
                hSAXWriter:end-element(vTeg) no-error.
              end.
            end.
            if not vfrist
              then
              hSAXWriter:end-element("НомСредИдентТов":U).
          end.
          hSAXWriter:end-element("ДопСведТов":U).
          for each bar-code where bar-code.gds-code eq buf_utd-lines.gds-code no-lock:
            for each prod-bc where prod-bc.b-code eq bar-code.b-code
              and prod-bc.bc-on
              no-lock:
              if    length(prod-bc.b-str) eq 13
                or length(prod-bc.b-str) eq 8
                then
              do:
                define variable bar_code as character no-undo.
                bar_code = substr (prod-bc.b-str, 1, length (prod-bc.b-str) - 1).
                run str/chk-sum.p
                  (input-output bar_code ) no-error .
                if prod-bc.b-str ne  bar_code
                  then
                do:
                  hSAXWriter:write-empty-element("ИнфПолФХЖ2":U) no-error.
                  hSAXWriter:insert-attribute("Идентиф":U, "штрихкод") no-error.
                  hSAXWriter:insert-attribute("Значен":U, prod-bc.b-str) no-error.
                  hSAXWriter:write-empty-element("ИнфПолФХЖ2":U) no-error.
                  hSAXWriter:insert-attribute("Идентиф":U, "EAN") no-error.
                  hSAXWriter:insert-attribute("Значен":U, prod-bc.b-str) no-error.
                end.
              end.
            end.
          end.
        end.
        hSAXWriter:end-element("СведТов":U).
      end.
      hSAXWriter:start-element("ВсегоОпл":U) no-error.
      hSAXWriter:insert-attribute ("СтТовБезНДСВсего":U, string (buf_utd.Total - buf_utd.Vat)) no-error.
      hSAXWriter:insert-attribute ("СтТовУчНалВсего":U, string (buf_utd.Total)) no-error.
      do:
        hSAXWriter:start-element("СумНалВсего":U) no-error.
        do:
          hSAXWriter:start-element("СумНал":U) no-error.
          hSAXWriter:write-characters(trim(string (buf_utd.Vat,">>>>>>>>>>>>9.99"))) no-error.
          hSAXWriter:end-element("СумНал":U) no-error.
        end.
        hSAXWriter:end-element("СумНалВсего":U) no-error.
      end.
      hSAXWriter:end-element("ВсегоОпл":U) no-error.
    end.
    hSAXWriter:end-element("ТаблСчФакт":U) no-error.
    hSAXWriter:start-element("СвПродПер":U) no-error.
    do:
      hSAXWriter:start-element("СвПер":U) no-error.
      hSAXWriter:insert-attribute("СодОпер":U, "Товары переданы") no-error.
      hSAXWriter:insert-attribute("ДатаПер":U, string(today,"99.99.9999")) no-error.
      do:
        hSAXWriter:write-empty-element("ОснПер":U) no-error.
        hSAXWriter:insert-attribute("НаимОсн":U, "договор") no-error.
        find first contract where contract.contract-code eq buf_utd.contract-code no-lock no-error.
        if available contract
          then
        do:
          hSAXWriter:insert-attribute("НомОсн":U, contract.contract-prn-code) no-error.
          hSAXWriter:insert-attribute("ДатаОсн":U, string(contract.contract-date,"99.99.9999")) no-error.
        end.
      end.
      hSAXWriter:end-element ("СвПер":U) no-error.
    end.
    hSAXWriter:end-element("СвПродПер":U) no-error.
    hSAXWriter:start-element("Подписант":U) no-error.
    hSAXWriter:insert-attribute ("ОснПолн":U, "Должностные обязанности") no-error.
    hSAXWriter:insert-attribute ("ОблПолн":U, "0") no-error.
    hSAXWriter:insert-attribute ("Статус":U, "1") no-error.
    do:
      hSAXWriter:start-element("ЮЛ":U) no-error.
      do:
        vUserperm = vOrganization:GetUserPermissions().
        define variable vJobTitle as character no-undo.
        vJobTitle = vUserperm:JobTitle.
        if    vJobTitle eq ?
          or vJobTitle eq ""
          then
          vJobTitle = iDiadocConnection:Certificate:JobTitle.
        release object vUserperm.
        hSAXWriter:insert-attribute ("ИННЮЛ":U, string(vOrganization:Inn)) no-error.
        hSAXWriter:insert-attribute ("Должн":U, vJobTitle) no-error.
        hSAXWriter:insert-attribute ("НаимОрг":U, string(vOrganization:Name)) no-error.
        vUser = iDiadocConnection:GetMyUser().
        hSAXWriter:write-empty-element("ФИО":U) no-error.
        hSAXWriter:insert-attribute("Фамилия":U, string(vUser:LastName)) no-error.
        hSAXWriter:insert-attribute("Имя":U, string(vUser:FirstName)) no-error.
        hSAXWriter:insert-attribute("Отчество":U, string(vUser:MiddleName)) no-error.
        release object vUser.
      end.
      hSAXWriter:end-element("ЮЛ":U) no-error.
    end.
    hSAXWriter:end-element("Подписант":U) no-error.
  end.
  hSAXWriter:end-element("Документ":U) no-error.
end.
hSAXWriter:end-element("Файл":U) no-error.
hSAXWriter:end-document().
release object vOrganization.
release object vCounteragent.
delete object hSAXWriter no-error.
procedure proc-init:
  define input parameter v-client as integer no-undo .
  define input parameter vOrg as component-handle no-undo .
  define variable v-TH as logical no-undo .
  case v-client:
    when 1 then
      do:
        find first ub.sysconf no-lock no-error .
        find first buf_clients no-lock where buf_clients.obj-code = ub.sysconf.host-code no-error .
        find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error .
        if available (buf_clients) and available (buf_firm) then
        do:
          if buf_firm.inn <> "" and buf_firm.kpp <> "" and
            buf_clients.obj-name <> "" and buf_clients.reg-code <> 0 then
          do:
            v-TH = true .
          end.
        end.
      end.
    when 2 then
      do:
        find first buf_clients no-lock where buf_clients.obj-code = buf_utd.cli-code and
          buf_clients.obj-type = buf_utd.cli-type no-error .
        find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code no-error .
        if available (buf_clients) and available (buf_firm) then
        do:
          if buf_firm.inn <> "" and buf_firm.kpp <> "" and
            buf_clients.obj-name <> "" and buf_clients.reg-code <> 0 then
          do:
            v-TH = true .
          end.
        end.
      end.
  end case .
  if v-TH and buf_firm.okpo <> "" then
    hSAXWriter:insert-attribute ("ОКПО":U, buf_firm.okpo) no-error.
  hSAXWriter:start-element("ИдСв":U) no-error.
  hSAXWriter:write-empty-element("СвЮЛУч":U) no-error.
  if v-TH then
  do:
    hSAXWriter:insert-attribute("НаимОрг":U, string(buf_clients.obj-name)) no-error.
    hSAXWriter:insert-attribute("ИННЮЛ":U, string(buf_firm.inn)) no-error.
    hSAXWriter:insert-attribute("КПП":U, string(buf_firm.kpp)) no-error.
  end.
  else
  do:
    hSAXWriter:insert-attribute("НаимОрг":U, string(vOrg:name)) no-error.
    hSAXWriter:insert-attribute("ИННЮЛ":U, string(vOrg:inn)) no-error.
    hSAXWriter:insert-attribute("КПП":U, string(vOrg:kpp)) no-error.
  end.
  hSAXWriter:end-element("ИдСв":U) no-error.
  hSAXWriter:start-element("Адрес":U) no-error.
  do:
    vCounteragentOrg = vOrg:GetCounteragentById(iContGuid) no-error.
    if vCounteragentOrg eq ?
    then do:
       PutErr(substitute ("Нет доступа к организации &1",iORGGuid) ).
       return error.
    end.
    getdesc(vCounteragentOrg).
    getdesc(vCounteragentOrg:Address).
    hSAXWriter:write-empty-element("АдрРФ":U) no-error.
    if v-TH then hSAXWriter:insert-attribute("КодРегион":U, string(buf_clients.reg-code)) no-error.
    else
      hSAXWriter:insert-attribute("КодРегион":U, string(vCounteragentOrg:Address:RegionCode)) no-error.
    if vCounteragentOrg:Address:Territory ne ""
      then
      hSAXWriter:insert-attribute("Район":U,     string(vCounteragentOrg:Address:Territory )) no-error.
    if vCounteragentOrg:Address:City ne ""
      then
      hSAXWriter:insert-attribute("Город":U,     string(vCounteragentOrg:Address:City      )) no-error.
    if vCounteragentOrg:Address:Street ne ""
      then
      hSAXWriter:insert-attribute("Улица":U,     string(vCounteragentOrg:Address:Street    )) no-error.
    if vCounteragentOrg:Address:Building ne ""
      then
      hSAXWriter:insert-attribute("Дом":U,       string(vCounteragentOrg:Address:Building )) no-error.
    if vCounteragentOrg:Address:Block ne ""
      then
      hSAXWriter:insert-attribute("Корпус":U,    string(vCounteragentOrg:Address:Block     )) no-error.
    release object vCounteragentorg.
  end.
  hSAXWriter:end-element("Адрес":U) no-error.
end procedure .
