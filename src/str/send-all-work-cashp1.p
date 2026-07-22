block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 29 янв. 2023 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 29 янв. 2023 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
&Scoped-define source "1"
define variable mdb-num   as integer   no-undo.
define variable mObjType  as character no-undo.
define variable mObjCode  as integer   no-undo.
define variable mPostType as character no-undo.
define variable mCashNum  as integer   no-undo.

{ gbl/cd-attr.i}
define variable Mfirst as logical no-undo.
function getValueConvert returns character  (igroup as char,
                                             iparam as char,
                                             ivalue as char):
   define variable v-param-empty as character no-undo.
   v-param-empty = "MACC_IP,MaxApiToken,Proxy_*,LmCHzLogin,LmCHzPass,TspiotHostAddr".

   if igroup eq "FUCO"
   then do:
      if iparam eq "TrkDispAdr"
      then 
         ivalue = "".
   end.
   else if igroup eq "GS1"
   then do:
      if can-do(v-param-empty, iparam)
      then 
         ivalue = "".
   end.
   else if igroup eq "INTFACE"
   then do:
      if    iparam eq "DOMS_IP"
         or iparam eq "DOMSPASSWORD"
         or iparam eq "IFSFIP"
         or iparam eq "LOGURL"
         or iparam eq "MW20ADDRESS"
         or iparam eq "ONLINEADDR"
         or iparam eq "PRCATCHHOST"
         or iparam begins "MSG_Cas_"
      then 
         ivalue = "".
   end.
   else if igroup eq "TABLEMENU"
   then do:
      if iparam eq "URL"
      then 
         ivalue = "".
   end.
   else if igroup eq "UFO2"
   then do:
      if iparam eq "VPNtestIP"
      then 
         ivalue = "".
   end.
   
   return ivalue.
end.

function getDevice returns integer ():
   define variable v-attr-value as character no-undo .
   define variable v-attr-type  as character no-undo .
   define variable v-device-kind as integer no-undo.
   define variable v-date as date no-undo.
   define variable v-decimal as decimal no-undo.
   define variable v-logical as logical no-undo.
   define variable v-dop as character no-undo.
   run cd-attr-value in this-procedure
      ( input mdb-num
         ,input mObjCode
         ,input mPostType
         ,input mCashNum
         ,input  (if mPostType = {&cd-type-ibm-xml}
                                                           then {&cda-IBM-XML_operative}
                                                           else {&cda-AUTOTANK_operative})
         ,input  (if mPostType = {&cd-type-ibm-xml}
                                                           then {&cda-IBM-XML_operative_device-kind}
                                                           else {&cda-AUTOTANK_operative_device-kind})
         ,output v-attr-value
         ,output v-date
         ,output v-decimal
         ,output v-device-kind
         ,output v-logical
         ,output v-dop
         ) no-error.
   if v-device-kind = ?
   then v-device-kind = 0.
   
   return v-device-kind.
end.
define variable mParent as character no-undo.
define variable mDevice as integer   no-undo.
   
procedure putc :
   define input parameter iSAXWriter as handle no-undo .
   define input parameter i-action   as character  no-undo .
   define input parameter p-value    as character  no-undo .
   define output parameter oSend      as logical    no-undo.
   
   define buffer code-group for ub.code.
   define buffer code-param for ub.code.
   mDevice = getDevice().

   mParent = "cash-param" + {&delim-par} + string(mDevice).
   for each code-group where code-group.parent     eq mParent
                         and code-group.code       eq {&source} 
   no-lock:
      iSAXWriter:start-element("Param").
      do:
         iSAXWriter:insert-attribute("ctrl",   "READ"              )   no-error.
         iSAXWriter:insert-attribute("group",  "*"                 )   no-error.
         iSAXWriter:insert-attribute("key",    "*"                 )   no-error.
      end.
      iSAXWriter:end-element("Param" ).
      oSend = yes.
      leave.
      
   end.

    mParent = mParent + {&delim-par} + string({&source} ).
end procedure.

procedure get-cash-types:
   define output parameter otypes as character no-undo init "{&bef-cd-type-autotank},{&bef-cd-type-IBM-XML}".
end.

procedure get-root-teg:
   define output parameter otypes as character no-undo init "config".
end.
define variable parparentproc as handle no-undo.
define variable mLogHandle    as handle no-undo.
define variable mLogFile      as character no-undo.
procedure set-context:
   define input         parameter iparparentproc as handle      no-undo.
   define input         parameter i-log-handle   as handle      no-undo.
   define input         parameter iLogFile       as character   no-undo.
   define output        parameter oProcIndo      as character   no-undo init "Настроек параметров".
   assign
      parparentproc = iparparentproc
      mLogHandle    = i-log-handle
      mLogFile      = iLogFile
      
   .
end.

procedure set-cash-info:
   define input         parameter iDB-num        as integer     no-undo.
   define input         parameter iObjType       as character   no-undo.
   define input         parameter iObjCode       as integer     no-undo.
   define input         parameter iPostType      as character   no-undo.
   define input         parameter iCashNum       as integer     no-undo.
   assign
      mDB-num       = iDB-num
      mObjType      = iObjType
      mObjCode      = iObjCode
      mPostType     = iPostType
      mCashNum      = iCashNum
      Mfirst        = yes
   .
end.

define variable mOk      as logical   no-undo init ?.
procedure parse-result:
   define input         parameter iWebRespMptr  as memptr      no-undo.
   define input-output  parameter pViewLog      as logical     no-undo.   
   
   mOk = ?.
   
   define variable hParser as handle no-undo.
  
   create sax-reader hParser.
   
   hParser:set-input-source("memptr", iWebRespMptr).
   hParser:sax-parse () no-error.
   if error-status:error 
   then do:
      if error-status:num-messages > 0 then
          /* unable to begin the parse */
         return error error-status:get-message(1).
      else
         /* error detected in a callback */
         return error return-value.
   end.
   delete object hParser.
   if not mOk
   then
      pViewLog = yes.
end.

/* SAXCallbacks */

/* Invoked when the XML parser detects the start of an XML document. */
procedure StartDocument:

end procedure.
define temp-table tt-cash-param-hist no-undo like ub.cash-param-hist .
define variable mElement as character no-undo.
define variable mtstamp as decimal no-undo.

/* Invoked when the XML parser detects the beginning of an element. */
procedure StartElement:
  define input parameter namespaceURI as character.
  define input parameter localName as character.
  define input parameter qname as character.
  define input parameter attributes as handle.
  
  mElement = qname.
  if mElement = "Param" then do:
    empty temp-table tt-cash-param-hist.
    create tt-cash-param-hist.
    assign
      tt-cash-param-hist.obj-type    = mObjType
      tt-cash-param-hist.obj-code    = mObjCode
      tt-cash-param-hist.device      = mDevice
      tt-cash-param-hist.cash-num    = mCashNum
      tt-cash-param-hist.param_section      = {&source}
      
      tt-cash-param-hist.param_group = attributes:get-value-by-qname("group")
      tt-cash-param-hist.param_name  = attributes:get-value-by-qname("key")
      tt-cash-param-hist.tstamp      = mtstamp + timezone(now) * 60
    .
  end.
  else if mElement = "config"
  then do:
     mtstamp = dec(attributes:get-value-by-qname("tstamp")).
  end.
  

end procedure.

/* Invoked when the XML parser detects character data. */
procedure Characters:
  define input parameter charData as memptr.
  define input parameter numChars as integer.
  
  define variable vCurrContent as longchar no-undo.
  define variable vLengthMemptr as int64 no-undo.
  define variable vReadByte as int64 no-undo.
  define variable vRead     as integer no-undo.
  
  vLengthMemptr = numChars.
  do while vLengthMemptr - vReadByte > 0 :
     vRead = min(vLengthMemptr - vReadByte,30000).
     vCurrContent = vCurrContent + GET-STRING(charData,vReadByte + 1,vRead).
     vReadByte = vReadByte + vRead.
  end. 
  if trim(vCurrContent) = "" then return.

  case mElement:
    when "ParamValue" then
      tt-cash-param-hist.param_value = vCurrContent .
    when "ParamDesc" then
      tt-cash-param-hist.description = vCurrContent .
    when "ErrorMessage" then do:
      run write-log-and-file in mLogHandle (
                               input 1
                             , input mLogFile
                             , input 1
                             , input (if available tt-cash-param-hist 
                                      then substitute ('Group = "&1" key="&2":&3',
                                      tt-cash-param-hist.param_group,
                                      tt-cash-param-hist.param_name,
                                      {&new-line})
                                      else "") + vCurrContent ).
                                      end.
  end case.

end procedure.

/* Invoked when the XML parser detects the end of an element. */
procedure EndElement:
  define input parameter name_ as character.
  define input parameter localName as character.
  define input parameter qName as character.
  define buffer Cash-param-hist for Cash-param-hist.
  define buffer code for code.
  define variable ii as integer no-undo .
    
  if qname = "ErrorMessage" then do:
/*      ErrorMessage = mcurrentContent.*/
/*     self:stop-parsing ().*/
     mOk = false.
  end.
  else if qname = "Param" then do:
    do:
    tt-cash-param-hist.param_value = getValueConvert(tt-cash-param-hist.param_group, tt-cash-param-hist.param_name, tt-cash-param-hist.param_value).
    
    define variable vParantNotCaseSens as character no-undo.
    define variable vCodeNotCaseSens as character no-undo.
    vParantNotCaseSens = mParent +  {&delim-par} + tt-cash-param-hist.param_group.
    vCodeNotCaseSens   = tt-cash-param-hist.param_name.
    find first code where code.parent eq vParantNotCaseSens
                      and code.code   eq vCodeNotCaseSens
    no-lock no-error.
    if not available code
    then
       find first code where code.parent eq vParantNotCaseSens 
                         and can-do(code.code, tt-cash-param-hist.param_name) no-lock no-error.
    
&if defined(SaveCode) eq 0
&then
       if Mfirst 
       then do:
          for each cash-param-hist where cash-param-hist.obj-type      = tt-cash-param-hist.obj-type
                                     and cash-param-hist.obj-code      = tt-cash-param-hist.obj-code
                                     and cash-param-hist.cash-num      = tt-cash-param-hist.cash-num
                                     and cash-param-hist.param_section = tt-cash-param-hist.param_section
          exclusive-lock:
             delete Cash-param-hist.
          end.
          Mfirst = false.
       end.
       find first cash-param-hist where cash-param-hist.obj-type      = tt-cash-param-hist.obj-type
                                    and cash-param-hist.obj-code      = tt-cash-param-hist.obj-code
                                    and cash-param-hist.cash-num      = tt-cash-param-hist.cash-num
                                    and cash-param-hist.param_section = tt-cash-param-hist.param_section
                                    and cash-param-hist.param_group   = tt-cash-param-hist.param_group
                                    and cash-param-hist.param_name    = if available code then code.code else tt-cash-param-hist.param_name
                                     no-error .
       buffer-copy tt-cash-param-hist except param_name to cash-param-hist
       assign
          cash-param-hist.param_name    = if available code then code.code else tt-cash-param-hist.param_name
        .
&else
       
       if not available code
       then do:
          create code.
          assign 
             code.parent    = vParantNotCaseSens
             code.code      = tt-cash-param-hist.param_name
             code.codename  = tt-cash-param-hist.description
             code.codevalue = tt-cash-param-hist.param_value
             code.status_   = {&bef-deleted-status-int}
          .
       end.
&endif
     end.
  end.
  

end procedure.

/* Invoked when the XML parser detects the end of an XML document. */
procedure EndDocument:
  if mOk eq ?
  then 
     mOk = true.

end procedure.

/* Invoked to report a warning. */
procedure Warning:
  define input parameter ErrMessage as character no-undo.
  message "The following WARNING was generated:~n" + ErrMessage
       view-as alert-box info buttons ok.
end procedure.
    
/* Invoked to report an error encountered by the parser while parsing the XML document. */
procedure Error:
  define input parameter ErrMessage as character no-undo.
  message "The following NONFATAL ERROR was generated:~n" + ErrMessage
       view-as alert-box info buttons ok.
end procedure.

/* Invoked to report a fatal error. */
procedure FatalError:
  define input parameter ErrMessage as character no-undo.
  return error "The following FATAL ERROR was generated:~n" + ErrMessage.
end procedure.

 