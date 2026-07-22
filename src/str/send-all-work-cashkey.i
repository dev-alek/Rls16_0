/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 31 янв. 2023 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 31 янв. 2023 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
define variable mdb-num   as integer   no-undo.
define variable mObjType  as character no-undo.
define variable mObjCode  as integer   no-undo.
define variable mPostType as character no-undo.
define variable mCashNum  as integer   no-undo.
define variable Mfirst    as logical no-undo.

{ gbl/cd-attr.i}
function getDevice returns integer ():
   define variable v-device-kind as integer no-undo.
   define buffer buf_cash-desk for ub.cash-desk .
   
   find first buf_cash-desk no-lock where buf_cash-desk.db-num = mdb-num and
   buf_cash-desk.obj-code = mObjCode and
   buf_cash-desk.pos-type = mPostType and
   buf_cash-desk.cash-num = mCashNum no-error .
   if available (buf_cash-desk) then do:
       v-device-kind = buf_cash-desk.device-kind .
   end. 

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
   mParent = substitute ("&2&1&3",{&delim-par},  "Cash-param",  mDevice ).
  for each code-group where code-group.parent     eq mParent no-lock:
      iSAXWriter:start-element("KeyMap").
      do:
         iSAXWriter:insert-attribute("ctrl",   "READ"              )   no-error.
         iSAXWriter:insert-attribute("map",    "R"            )   no-error.
         iSAXWriter:start-element("PosKey").
         do:
            iSAXWriter:insert-attribute("scan", "*" /* code-param.code*/     )   no-error.
         end.
         iSAXWriter:end-element("PosKey" ).
      end.
      iSAXWriter:end-element("KeyMap" ).
      iSAXWriter:start-element("KeyMap").
      do:
         iSAXWriter:insert-attribute("ctrl",   "READ"              )   no-error.
         iSAXWriter:insert-attribute("map",    "F"            )   no-error.
         iSAXWriter:start-element("PosKey").
         do:
            iSAXWriter:insert-attribute("scan", "*" /* code-param.code*/     )  .
         end.
         iSAXWriter:end-element("PosKey" ).
      end.
      iSAXWriter:end-element("KeyMap" ).
      oSend = yes.
      leave.
   end.
   mParent = substitute ("&2&1&3",{&delim-par},  mParent,  {&source} ).
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
   define output        parameter oProcIndo      as character   no-undo init "Настроек клавиатуры".
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
      Mfirst        = true
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
define variable mMode as character no-undo.

define variable mtstamp as decimal no-undo.
/* Invoked when the XML parser detects the beginning of an element. */
procedure StartElement:
  define input parameter namespaceURI as character.
  define input parameter localName as character.
  define input parameter qname as character.
  define input parameter attributes as handle.
  
  mElement = qname.
  if mElement = "PosKey" then do:
    empty temp-table tt-cash-param-hist.
    create tt-cash-param-hist.
    assign
      tt-cash-param-hist.obj-type    = mObjType
      tt-cash-param-hist.obj-code    = mObjCode
      tt-cash-param-hist.device      = mDevice
      tt-cash-param-hist.cash-num    = mCashNum
      tt-cash-param-hist.param_section      = "{&source}"
      tt-cash-param-hist.param_value_dop    = mMode
      
/*      tt-cash-param-hist.param_group = attributes:get-value-by-qname("scan")*/
      tt-cash-param-hist.tstamp      = mtstamp
    .
  end.
  else if mElement = "KeyMap" then do:
     mMode = attributes:get-value-by-qname("mode").
  end.
  else if mElement = "config"
  then do:
     mtstamp = dec(attributes:get-value-by-qname("tstamp"))  + timezone(now) * 60.
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
    when "PKMgr" then
      tt-cash-param-hist.param_value = if int(vCurrContent) > 0 then "MGR" else "REG" .
    when "PKFun" then
      tt-cash-param-hist.param_group = vCurrContent .
    when "PKValue" then
      tt-cash-param-hist.param_name = vCurrContent .
      
    when "ErrorMessage" then
      run write-log-and-file in mLogHandle (
                               input 1
                             , input mLogFile
                             , input 1
                             , input vCurrContent ).
  end case.

end procedure.

/* Invoked when the XML parser detects the end of an element. */
procedure EndElement:
   define input parameter name_ as character.
   define input parameter localName as character.
   define input parameter qName as character.
   
   if qname = "ErrorMessage" then do:
      mOk = false.
   end.
   else if qname = "PosKey" then do:
      if     tt-cash-param-hist.param_value ne ""
         and tt-cash-param-hist.param_value ne ?
      then do:
&if defined (SaveCode) eq 0
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
         define buffer code-param for ub.Code.
/*         find first code-param where code-param.parent  eq mParent  + {&delim-par} + tt-cash-param-hist.param_group*/
/*                                 and code-param.code    eq tt-cash-param-hist.param_name                           */
/*                                 and code-param.status_ eq {&bef-current-status-int}                               */
/*                                 and lookup(mPostType,code-param.misc5) > 0                                        */
/*         no-lock no-error.                                                                                         */
/*         if available code-param                                                                                   */
/*         then                                                                                                      */
         do: 
            find first cash-param-hist where cash-param-hist.obj-type      = tt-cash-param-hist.obj-type
                                         and cash-param-hist.obj-code      = tt-cash-param-hist.obj-code
                                         and cash-param-hist.cash-num      = tt-cash-param-hist.cash-num
                                         and Cash-param-hist.device        = tt-cash-param-hist.device
                                         and cash-param-hist.param_section = tt-cash-param-hist.param_section
                                         and cash-param-hist.param_group   = tt-cash-param-hist.param_group
                                         and cash-param-hist.param_name    = tt-cash-param-hist.param_name
                                       no-error.
            if available cash-param-hist and lookup(tt-cash-param-hist.param_value,cash-param-hist.param_value) eq 0
            then
               tt-cash-param-hist.param_value = cash-param-hist.param_value + "," + tt-cash-param-hist.param_value.
            buffer-copy tt-cash-param-hist to cash-param-hist .
         end.
&else
         define variable vParantNotCaseSens as character no-undo.
          define variable vCodeNotCaseSens as character no-undo.
          vParantNotCaseSens = mParent +  {&delim-par} + tt-cash-param-hist.param_group.
          vCodeNotCaseSens   = tt-cash-param-hist.param_name.
         find first code where code.parent eq vParantNotCaseSens 
                           and code.code   eq vCodeNotCaseSens
         no-lock no-error.
         if not available code
         then do:
            create code.
            assign 
               code.parent    = mParent  + {&delim-par} + tt-cash-param-hist.param_group 
               code.code      = tt-cash-param-hist.param_name
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

 