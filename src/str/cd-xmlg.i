/*

$Revision: de2ec29bf3dd, 3632, test $
$Author: EShklyar $
$Date: 2024/01/12 09:48:15 $
$Workfile: cd-xmlg.i $
$Archive: str/cd-xmlg.i $

Специфические процедуры обработки ПРИЕМА xml почты с касс

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/22/04
Author: Bakhtadze Natalya
Creation date: 06/22/04

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: cd-xmlg.i $ $Revision: de2ec29bf3dd, 3632, test $".

{ gbl/cd-attr.i }

define temp-table temp-temp no-undo
field id as character
field ctime as integer
field cr as integer
field record-name as character
field field-name as character
field field-value as character
index iid id ctime
index ifile record-name field-name
index icr is unique primary cr
.
define temp-table temp-temp-attr no-undo
field id as character
field cr  as integer
field cra as integer
field record-name as character
field field-name as character
field attr-name as character
field attr-value as character
index iid id
index icr is unique primary cr cra
.
define temp-table temp-param no-undo
field desk as integer 
field cr as integer
field group-name as character
field record-name as character
field key-name as character
field attr-value as character
field field-name as character
field field-value as character
index ifile record-name field-name key-name group-name
index icr is unique primary cr
.

define variable v-mail-parameters-start     as logical        no-undo.
define variable v-date-format as character no-undo .
define variable v-version as character no-undo .
define variable v-pos-version as character no-undo .
define variable v-from as character no-undo .
define variable v-is-spool-file as logical no-undo .
define variable v-start-err as integer no-undo .
define variable v-num-errors as integer no-undo .
define variable v-dec-sep as character no-undo init ".":U.
define variable v-encoding as character no-undo .
define variable v-db-key-enc as character no-undo .
define variable cri as integer no-undo .
define variable crai as integer no-undo .
define variable v-id as character no-undo .
define variable m-head-db-num   as integer no-undo.
define variable m-head-obj-code as integer no-undo.
define variable m-head-pos-type as character no-undo.
define variable m-head-cash-num as integer no-undo.
define variable v-ctrl as character no-undo .
define variable v-time as integer no-undo .
define variable v-time-char as character no-undo .
define variable v-cd-fatal-error as logical no-undo .
define variable v-cd-fatal-message as character no-undo .
define variable v-errorSeverity as integer no-undo .
define variable v-errormessage as character no-undo .
define variable v-errornum as character no-undo .
define variable v-group as character no-undo .
define variable v-key as character no-undo .

define variable ErrorMessage as character no-undo.
define variable mOk as logical no-undo.
define variable mtagbeg as int64  no-undo.
define variable mtagend as int64 no-undo.

procedure get-xml-ibm-c-buff-or-file.
   define input parameter p-Type as character  no-undo.
   define input parameter p-str  as longchar   no-undo.
   define variable hParser as handle no-undo.
   mtagbeg = 0.
   mtagend = 0.
&if "{1}" = "spool" &then
run get-ibm-parameters in this-procedure no-error.
if error-status:error then do:
  assign
  p-view-log = yes
  .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке данных от кассы произошла ошибка при получении значений настроечных параметров: &1"
                          , return-value
                        )
                                        ).
  undo, return .
end.
&endif
  
   create sax-reader hParser.
   if p-Type eq "file"
   then
      hParser:set-input-source(p-Type, string(p-str)).
   else do:
      if p-Type = "longchar"
      then do:
         define variable vmemptr as memptr no-undo.
         copy-lob p-str to vmemptr.
         hParser:set-input-source("memptr", vmemptr).
      end.
      else
         hParser:set-input-source(p-Type, p-str).
   end.
   hParser:sax-parse () no-error.
   if error-status:error then do:
      delete object hParser.
      if error-status:num-messages > 0 
      then do:
          /* unable to begin the parse */
          run write-log-and-file in p-log-handle (
           input 1
         , input log-file-name
         , input 1
         , input substitute( "!!!При  произошла ошибка при получении полного пути файлу: &1 &2"
                             , ErrorMessage
                             , return-value
                           )
                                     ).
          return error error-status:get-message(1).
      end.
      else do:
          /* error detected in a callback */
           return error return-value.
      end.
   end.
   delete object hParser.
   if ErrorMessage <> "" 
   then do:
      run write-log-and-file in p-log-handle (
           input 1
         , input log-file-name
         , input 1
         , input substitute( "!!!При  произошла ошибка при получении полного пути файлу: &1 "
                             , ErrorMessage
                           )
                                     ).
       
      return error ErrorMessage .
   end.
&if "{1}" = "spool" &then
DO TRANSACTION:
  run proc-end in this-procedure no-error .
END.
assign
error-status:error = false.
define buffer buf_cash-desk for ub.cash-desk.
for each temp-cash-desk:
  find first buf_cash-desk no-lock where
            buf_cash-desk.db-num = g#db-num
        AND buf_cash-desk.obj-code = p-obj-code
        AND buf_cash-desk.pos-type = p-pos-type
        AND buf_cash-desk.cash-num = temp-cash-desk.cash-num no-error .
  if available buf_cash-desk then do:
    run cd-attr-write in this-procedure (
                                          input g#db-num
                                         ,input p-obj-code
                                        ,input p-pos-type
                                        ,input temp-cash-desk.cash-num
                                        ,input (if buf_cash-desk.pos-type = {&cd-type-ibm-xml}
                                                then {&cda-ibm-xml_operative}
                                                else if  buf_cash-desk.pos-type = {&cd-type-autotank}
                                                then {&cda-autotank_operative}
                                                else {&cda-magia-xml_operative})
                                        ,input (if buf_cash-desk.pos-type = {&cd-type-ibm-xml}
                                                then {&cda-ibm-xml_operative_last-check-params}
                                                else if  buf_cash-desk.pos-type = {&cd-type-autotank}
                                                then {&cda-autotank_operative_last-check-params}
                                                else {&cda-magia-xml_operative_last-check-date-time}
                                               )
                                        ,input (cd-attr-CD-DatetoString (temp-cash-desk.last-date) + {&space-char}  +  string(temp-cash-desk.last-time, "HH:MM:SS":U)
                                             +  (if buf_cash-desk.pos-type = {&cd-type-ibm-xml}
                                                 or buf_cash-desk.pos-type = {&cd-type-autotank}
                                               then ({&space-char} + string(temp-cash-desk.last-shift-num) +
                                                      {&space-char} + string(temp-cash-desk.last-z-count) +
                                                      {&space-char} + string(temp-cash-desk.last-chk-num))
                                               else  "":U)
                                               )
                                        ,input ?
                                        ,input 0.0
                                        ,input 0
                                        ,input no
                                        ) no-error.
  end. /*if available buf_cash-desk then do:*/
end.
&endif
   
end.

/* SAXCallbacks */

/* Invoked when the XML parser detects the start of an XML document. */
procedure StartDocument:
   /* assign
      refund-type = ""
      Check-ctrl = ""
      CSGCode = ""
      CSPrice = ""
      ErrorMessage = ""
    . */
end procedure.

/* Invoked when the XML parser detects the beginning of an element. */
procedure StartElement:
   define input parameter namespaceURI as character.
   define input parameter localName    as character.
   define input parameter qname        as character.
   define input parameter ihAttributes as handle.

   define variable v-attr-num    as integer   no-undo.
   define variable v-temp-string as character no-undo.
   
   do v-attr-num = 1 to ihAttributes:num-items:
      v-temp-string = substitute ('&1 &2="&3"',
                                  v-temp-string,
                                  ihAttributes:get-qname-by-index(v-attr-num),
                                  ihAttributes:get-value-by-index(v-attr-num)).
   end.
   v-temp-string = trim(v-temp-string).
     mtagbeg =  mtagbeg + 1.
    run run-callback-procedure in this-procedure (
                      input this-procedure:handle
                    , input {&xmlparse-call-all}
                    , input "tag-start"
                    , input qname
                    , input v-temp-string
                ).
end procedure.
define variable mcurrentContent as character no-undo.
/* Invoked when the XML parser detects character data. */
procedure Characters:
    define input parameter charData as memptr.
    define input parameter numChars as integer.
    
    define variable mcurrentContent as character no-undo.
    mcurrentContent = get-string(charData, 1, get-size(charData)).
    
    run run-callback-procedure in this-procedure (
                      input this-procedure:handle
                    , input {&xmlparse-call-all}
                    , input "text"
                    , input ""
                    , input mcurrentContent
                ).
                
end procedure.

/* Invoked when the XML parser detects the end of an element. */
procedure EndElement:
define input parameter name_     as character.
define input parameter localName as character.
define input parameter qName     as character.

    if qname = "ErrorMessage" then do:
      ErrorMessage = mcurrentContent.
      self:stop-parsing ().
    end.
    mtagend = mtagend + 1. 
    if mtagend mod 100 = 0 or qName eq "check" 
    then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Прочитано открытых тегов &1 из них закрытых &2", mtagbeg, mtagend)).
    end.
    run run-callback-procedure in this-procedure (
                      input this-procedure:handle
                    , input {&xmlparse-call-all}
                    , input "tag-end"
                    , input qname
                    , input ""
                ).
end procedure.

/* Invoked when the XML parser detects the end of an XML document. */
procedure EndDocument:
    run hide-counter in p-log-handle .
    mOk = true.
end procedure.

/* Invoked to report a warning. */
procedure Warning:
    define input parameter ErrMessage as character no-undo.
    message "The following WARNING was generated:~n" + ErrMessage
        view-as alert-box information buttons ok.
end procedure.
    
/* Invoked to report an error encountered by the parser while parsing the XML document. */
procedure Error:
    define input parameter ErrMessage as character no-undo.
    mOk = false.
    message "The following NONFATAL ERROR was generated:~n" + ErrMessage
        view-as alert-box information buttons ok.
end procedure.

/* Invoked to report a fatal error. */
procedure FatalError:
    define input parameter ErrMessage as character no-undo.
    mOk = false.
    return error "The following FATAL ERROR was generated:~n" + ErrMessage.
end procedure.



PROCEDURE get-xml-ibm-c.
define input parameter p-filename as char no-undo.

define variable v-new-filename-full     as character         no-undo.
define variable v-xml-buffer as character no-undo.
define variable v-my-string as character no-undo .
define variable v-read-char as character no-undo .
define buffer buf_cash-desk for ub.cash-desk.

&if "{1}" = "spool" &then
run get-ibm-parameters in this-procedure no-error.
if error-status:error then do:
  assign
  p-view-log = yes
  .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке файла &1 произошла ошибка при получении значений настроечных параметров: &2"
                          , p-filename
                          , return-value
                        )
                                        ).
  undo, return .
end.
&endif
/* 23/XI-2018 - знчение p-filename во всех случаях поступает сюда
                (вызывается из get-xibm.p, get-xrpl.p - оба идут из getxibmf.p - и из rsndxibm.p)
                из перечня input from os-dir value(...).
                Повторная проверка наличия в каталоге файла, прочитанного из каталога, избыточна.
run gbl/filename.p (
              input p-filename
              ,output v-full-path
              ,output v-path
              ,output v-file-name
              ,output v-file-name-no-ext
              ,output v-file-name-ext
              ) no-error .
if error-status:error then do:
  assign
  p-view-log = yes
  .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!При обработке файла &1 произошла ошибка при получении полного пути файлу: &2"
                          , p-filename
                          , return-value
                        )
                                  ).
  return.
end.
*/
error-status:error = FALSE.
   
run gbl/fileapnd.p
  ( input p-filename
   ,input ""
   ,input 5 /* время ожинания освобождения файла */
  ) no-error .
if error-status:error then do:
   run write-log-and-file in p-log-handle (
       input 1
     , input log-file-name
     , input 1
     , input return-value
     ).
   assign
      p-view-log = yes
      .
   undo, return.
end.

if p-encoding = "utf-8":U  then  do:
  input stream ChkStream from value( p-filename ) convert source "utf-8".
end.
else do:
  input stream ChkStream from value( p-filename ) /*convert target "utf-8"*/.
end.
_repeat:
REPEAT :
  if v-exit-processing then leave _repeat.
  _line:
  DO TRANSACTION:
    import stream Chkstream unformatted  v-xml-buffer  .
    if v-xml-buffer = "":U then do:
      NEXT _repeat.
    end.
    /*
    _readkey:
    repeat:
      readkey stream ChkStream.
      if lastkey = - 2 then leave _repeat.
      v-read-char = chr(lastkey).

      if v-read-char = ">" then do:
        assign
        v-my-string = v-my-string + v-read-char
        v-xml-buffer = v-my-string
        v-my-string = "":U
        .
        LEAVE _readkey.
      end.
      else do:
        assign
        v-my-string = v-my-string + v-read-char
        .
      end.
    end. /*_readkey:*/
    */
    assign
    var-file-line-num = var-file-line-num + 1
    .
    if left-trim(v-xml-buffer)  begins "<?xml":U then do:
      assign
      v-encoding = cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input "xml":U
                             ,input trim(v-xml-buffer, "?>")
                             ,input "encoding":U
                             ,input yes)
     .
     if v-encoding <> p-encoding
     then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Ошибка чтения файла &1: кодировка НЕ &2"
                                , p-filename
                                , p-encoding
                              )
                                            ).
      assign
      p-view-log = yes
      .
      undo, return .
     end.
    end.
    run xmlvalid in this-procedure (
          input this-procedure:handle
        , input v-xml-buffer
        , input 'fatal':u
    ) no-error .
    if error-status:error  then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Ошибка импорта файла &1: &2"
                                , p-filename
                                , return-value
                              )
                                            ).
      assign
      p-view-log = yes
      .
      undo, return .
    end.
    if v-cd-fatal-error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Файл &1 строка &2 фатальные ошибки: &3 - импорт прекращен"
                              , p-filename
                              , var-file-line-num
                              , v-cd-fatal-message
                            )
                                          ).
      assign
      p-view-log = yes
      .
      undo, return.
    end.
    if var-file-line-num modulo 100 = 0 then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Файл &1: прочитано строк &2", p-filename, var-file-line-num)).
    end.
  END .
end.
&if "{1}" = "spool" &then
DO TRANSACTION:
  run proc-end in this-procedure no-error .
END.
assign
error-status:error = false.
input stream ChkStream close.
for each temp-cash-desk:
  find first buf_cash-desk no-lock where
            buf_cash-desk.db-num = g#db-num
        AND buf_cash-desk.obj-code = p-obj-code
        AND buf_cash-desk.pos-type = p-pos-type
        AND buf_cash-desk.cash-num = temp-cash-desk.cash-num no-error .
  if available buf_cash-desk then do:
  run cd-attr-write in this-procedure (
                                          input g#db-num
                                         ,input p-obj-code
                                        ,input p-pos-type
                                        ,input temp-cash-desk.cash-num
                                        ,input (if buf_cash-desk.pos-type = {&cd-type-ibm-xml}
                                                then {&cda-ibm-xml_operative}
                                                else if  buf_cash-desk.pos-type = {&cd-type-autotank}
                                                then {&cda-autotank_operative}
                                                else {&cda-magia-xml_operative})
                                        ,input (if buf_cash-desk.pos-type = {&cd-type-ibm-xml}
                                                then {&cda-ibm-xml_operative_last-check-params}
                                                else if  buf_cash-desk.pos-type = {&cd-type-autotank}
                                                then {&cda-autotank_operative_last-check-params}
                                                else {&cda-magia-xml_operative_last-check-date-time}
                                               )
                                        ,input (cd-attr-CD-DatetoString (temp-cash-desk.last-date) + {&space-char}  +  string(temp-cash-desk.last-time, "HH:MM:SS":U)
                                             +  (if buf_cash-desk.pos-type = {&cd-type-ibm-xml}
                                                 or buf_cash-desk.pos-type = {&cd-type-autotank}
                                               then ({&space-char} + string(temp-cash-desk.last-shift-num) +
                                                      {&space-char} + string(temp-cash-desk.last-z-count) +
                                                      {&space-char} + string(temp-cash-desk.last-chk-num))
                                               else  "":U)
                                               )
                                        ,input ?
                                        ,input 0.0
                                        ,input 0
                                        ,input no
                                        ) no-error.
end.
end.
&else
input stream ChkStream close.
&endif
END PROCEDURE.

procedure cb-xmlparse-tag-start-Header :
/* обработка события "начало Header"*/

do
on error undo, return error
:
  assign
      v-mail-parameters-start = yes
  .

end.

end procedure. /* cb-xmlparse-tag-start-Header */

procedure cb-xmlparse-tag-end-Header :
/* обработка события "конец Header"*/

do
on error undo, return error
:
  assign
      v-mail-parameters-start = no
  .

end.

end procedure. /* cb-xmlparse-tag-start-Header */


procedure cb-xmlparse-tag-start-{1} :
define input parameter p-parameter as character no-undo .
define variable v-file-type as character no-undo .
define variable v-adresat as character no-undo .
define variable v-FO-version as character no-undo .
define variable v-OptVersion as character no-undo .
define variable v-OptVersion1 as character no-undo .
define variable v-OptVersion2 as character no-undo .
define variable v-OptVersion3 as character no-undo .
define variable v-OptVersion4 as character no-undo .
define variable v-OptVer      as character no-undo .
define variable v-old-fo-version as character no-undo .
define variable v-pay-desk as integer no-undo .
define variable v-dop as character no-undo .
define buffer cash-desk for ub.cash-desk.
define variable v-date as date no-undo .
define variable v-decimal as decimal no-undo .
define variable v-integer as integer no-undo .
define variable v-logical as logical no-undo .
define variable v-err-message as character no-undo .

do
on error undo, return error
:

  if v-is-spool-file = no then do:
  
    IF INDEX(p-parameter,"OptVersion") > 0 THEN v-OptVer = 'OptVer'.

    assign
    v-file-type = cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "type":U
                             ,input yes)
    v-adresat =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "to":U
                             ,input no)
    &if "{1}" = "spool" &then
    v-pos-version =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "version":U
                             ,input no)
    v-FO-version =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "release":U
                             ,input no)
    v-from =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "from":U
                             ,input no) 
    v-OptVersion =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "OptVersion":U
                             ,input no)                             
    v-OptVersion1 =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "OptVersion1":U
                             ,input no)                                                          
    v-OptVersion2 =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "OptVersion2":U
                             ,input no)                                                                                       
    v-OptVersion3 =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "OptVersion3":U
                             ,input no)                                                                                                                    
    v-OptVersion4 =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "OptVersion4":U
                             ,input no)                                                                                                                    
    &endif
    .
    if v-file-type = "REPLY":U AND
    (v-adresat begins ({&shop} + string(p-obj-code))
&if "{1}" = "data" &then
     or v-adresat begins ("БД" + string(g#db-num))
     or p-spool-or-data = "config"
     or p-spool-or-data = "control"
&endif
    )
    then do:
      assign
      v-is-spool-file = yes
      .
      if v-from begins ({&shop} + string(p-obj-code) + "_" + "касса") then do:
        v-pay-desk = ?.
        v-pay-desk = integer(replace(v-from, ({&shop} + string(p-obj-code) + "_" + "касса"), "")) no-error.
        assign
           m-head-db-num    = ?
           m-head-obj-code  = ?
           m-head-pos-type  = ?
           m-head-cash-num  = ?
        .
        find first cash-desk where
                         cash-desk.db-num = g#db-num
                     and cash-desk.obj-code = p-obj-code
/*                     and cash-desk.pos-type = p-pos-type*/
                     and cash-desk.cash-num = v-pay-desk
        no-lock no-error.
        if available cash-desk
        then do transaction :
           assign
              m-head-db-num    = cash-desk.db-num
              m-head-obj-code  = cash-desk.obj-code
              m-head-pos-type  = cash-desk.pos-type
              m-head-cash-num  = cash-desk.cash-num
           .
          /*Дата последнего опроса касс*/
          if p-pos-type = {&cd-type-ibm-xml} then 
          do:
            run cd-attr-write in this-procedure (
              input cash-desk.db-num
              ,input cash-desk.obj-code
              ,input cash-desk.pos-type
              ,input cash-desk.cash-num
              ,input  (if p-pos-type = {&cd-type-ibm-xml}
              then {&cda-IBM-XML_operative}
              else {&cda-AUTOTANK_operative})
              ,input {&cda-IBM-XML_operative_last-date-polls}
              ,input string (today,"99.99.9999")
              ,input ? /*p-date*/
              ,input 0 /*p-decimal*/
              ,input 0 /*p-integer*/
              ,input no /*p-logical*/
              ) .

            /*Время последнего опроса касс*/
            run cd-attr-write in this-procedure (
              input cash-desk.db-num
              ,input cash-desk.obj-code
              ,input cash-desk.pos-type
              ,input cash-desk.cash-num
              ,input  (if p-pos-type = {&cd-type-ibm-xml}
              then {&cda-IBM-XML_operative}
              else {&cda-AUTOTANK_operative})
              ,input {&cda-IBM-XML_operative_last-time-polls}
              ,input string (time,"HH:MM:SS") 
              ,input ? /*p-date*/
              ,input 0 /*p-decimal*/
              ,input 0 /*p-integer*/
              ,input no /*p-logical*/
              ) .
          end.    

          IF v-OptVer = 'OptVer' THEN DO:
            v-OptVer = "".
            IF v-OptVersion  <> ? THEN v-OptVer = TRIM(v-OptVersion," "). 
            IF v-OptVersion1 <> ? THEN v-OptVer = substitute("&1,&2",v-OptVer,TRIM(v-OptVersion1," ")) .
            IF v-OptVersion2 <> ? THEN v-OptVer = substitute("&1,&2",v-OptVer,TRIM(v-OptVersion2," ")) .
            IF v-OptVersion3 <> ? THEN v-OptVer = substitute("&1,&2",v-OptVer,TRIM(v-OptVersion3," ")) .
            IF v-OptVersion4 <> ? THEN v-OptVer = substitute("&1,&2",v-OptVer,TRIM(v-OptVersion4," ")) .
            v-OptVer = TRIM(v-OptVer,",").
                IF v-OptVer = "" THEN v-OptVer = "?" . 
                    run cd-attr-write in this-procedure (
                                                   input cash-desk.db-num
                                                  ,input cash-desk.obj-code
                                                  ,input cash-desk.pos-type
                                                  ,input cash-desk.cash-num
                                                  ,input  (if cash-desk.pos-type = {&cd-type-ibm-xml}
                                                           then {&cda-IBM-XML_operative}
                                                           else {&cda-AUTOTANK_operative})
                                                  ,input  (if cash-desk.pos-type = {&cd-type-IBM-XML}
                                                       then {&cda-IBM-XML_operative_OptVer}
                                                       else {&cda-AUTOTANK_operative_OptVer})
                                                  ,input v-OptVer
                                                  ,input no /*p-date*/
                                                  ,input no /*p-decimal*/
                                                  ,input no /*p-integer*/
                                                  ,input no /*p-logical*/
                                                  ) no-error.
               v-OptVer = '' . 
           END.

          if error-status:error then do :
              v-err-message = return-value . /* чтобы видеть текст сообщения в деббагере*/
              run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input v-err-message
                                          ).
              p-view-log = yes .
            end .                                      

           run cd-attr-value in this-procedure (
                                               input cash-desk.db-num
                                              ,input cash-desk.obj-code
                                              ,input cash-desk.pos-type
                                              ,input cash-desk.cash-num
                                              ,input  (if cash-desk.pos-type = {&cd-type-IBM-XML}
                                                      then {&cda-IBM-XML_operative}
                                                      else {&cda-AUTOTANK_operative})
                                              ,input  (if cash-desk.pos-type = {&cd-type-IBM-XML}
                                                       then {&cda-IBM-XML_operative_fo-version}
                                                       else {&cda-AUTOTANK_operative_fo-version})
                                              ,output v-old-fo-version
                                              ,output v-date
                                              ,output v-decimal
                                              ,output v-integer
                                              ,output v-logical
                                              ,output v-dop) no-error.
           if     v-old-fo-version <> v-fo-version 
              and v-FO-version <> ?
           then do:
              run cd-attr-write in this-procedure (
                                                   input cash-desk.db-num
                                                  ,input cash-desk.obj-code
                                                  ,input cash-desk.pos-type
                                                  ,input cash-desk.cash-num
                                                  ,input  (if cash-desk.pos-type = {&cd-type-ibm-xml}
                                                           then {&cda-IBM-XML_operative}
                                                           else {&cda-AUTOTANK_operative})
                                                  ,input (if cash-desk.pos-type = {&cd-type-IBM-XML}
                                                          then {&cda-IBM-XML_operative_fo-version}
                                                          else {&cda-AUTOTANK_operative_fo-version})
                                                  ,input v-fo-version
                                                  ,input ? /*p-date*/
                                                  ,input 0 /*p-decimal*/
                                                  ,input 0 /*p-integer*/
                                                  ,input no /*p-logical*/
                                                  ) no-error.
            if error-status:error then do :
              v-err-message = return-value . /* чтобы видеть текст сообщения в деббагере*/
              run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input v-err-message
                                          ).
              p-view-log = yes .
            end .                                      
          end. /*  do transaction :*/
        end. /*if v-old-fo-version <> v-fo-version then do:*/
      end. /*if v-from begins ({&shop} + string(p-obj-code) + "_" + "касса") then do:*/
    end.
    else do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!В директории приема файлов обнаружен файл с неизвестным адресатом: &1 и/или неизвестного типа: &2"
                              , v-adresat
                              , v-file-type
                            )
                                          ).
      assign
      p-view-log = yes
      v-exit-processing = yes
      .
    end.
  end.
  else do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Нарушение протокола обмена : тэг <&1>", p-spool-or-data
                            )
                                          ).
      assign
      p-view-log = yes
      .
  end.
end.

end procedure. /* cb-xmlparse-tag-start-spool */


procedure cb-xmlparse-tag-start-config :
define input parameter p-parameter as character no-undo .
  run cb-xmlparse-tag-start-{1} in this-procedure ( input p-parameter) no-error.
  if error-status:error then return error return-value .
end procedure.

procedure cb-xmlparse-tag-start-control :
define input parameter p-parameter as character no-undo .
  run cb-xmlparse-tag-start-{1} in this-procedure ( input p-parameter) no-error.
  if error-status:error then return error return-value .
end procedure.


procedure cb-xmlparse-tag-end-{1} :
define input parameter p-parameter as character no-undo .

do
on error undo, return error
:
  assign
  v-is-spool-file = no
  .
  end.

end procedure. /* cb-xmlparse-tag-end-{1} */


procedure cb-xmlparse-tag-end-config :
define input parameter p-parameter as character no-undo .
run cb-xmlparse-tag-end-{1}  in this-procedure ( input p-parameter) no-error.
if error-status:error then return error return-value .

end procedure. /* cb-xmlparse-tag-end-config */

procedure cb-xmlparse-tag-end-control :
define input parameter p-parameter as character no-undo .
run cb-xmlparse-tag-end-{1}  in this-procedure ( input p-parameter) no-error.
if error-status:error then return error return-value .

end procedure. /* cb-xmlparse-tag-end-control */



procedure cb-xmlparse-tag-start-{2} :
define input parameter p-parameter as character no-undo .
do
on error undo, return error
:
  if v-is-spool-file = yes then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Нарушение протокола обмена : тэг <&1>",
&if "{2}" = "data" &then
 "data":U
&else
 "spool":U
&endif
                           )
                                          ).
      assign
      p-view-log = yes
      .
  end.
  else do:
    assign
    v-exit-processing = yes
    .
    /*это файл не того типа, что мы ищем*/
  end.
end.

end procedure. /* cb-xmlparse-tag-start-{2} */

procedure cb-xmlparse-tag-end-{2} :
define input parameter p-parameter as character no-undo .

do
on error undo, return error
:
end.

end procedure. /* cb-xmlparse-tag-end-{2} */


procedure cb-xmlparse-tag-start-error:
define input parameter p-parameter as character no-undo .
run cb-xmlparse-tag-start-err in this-procedure ( input p-parameter)  .
end procedure .


procedure cb-xmlparse-tag-end-error :
define input parameter p-parameter as character no-undo .
run cb-xmlparse-tag-end-err in this-procedure ( input p-parameter)  .
end procedure .


procedure cb-xmlparse-tag-end-ErrorMessage :
define input parameter p-parameter as character no-undo .
assign
v-ErrorMessage = v-xmlvalid-tag-value
.
if p-pos-type = {&cd-type-IBM-XML}
or p-pos-type = {&cd-type-autotank}
then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!&1"
                            ,v-ErrorMessage
                          )
                                        ).
    assign
    p-view-log = yes
    .
end.
end procedure .

procedure cb-xmlparse-tag-end-ErrorSeverity :
define input parameter p-parameter as character no-undo .
assign
v-Errorseverity = integer(v-xmlvalid-tag-value)
no-error
.
if p-pos-type = {&cd-type-IBM-XML}
or p-pos-type = {&cd-type-autotank}
then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!&1"
                          , (if v-errorseverity = 0
                              then "Информация"
                              else (if v-Errorseverity = 1
                                    then "Предупреждение"
                                    else "Ошибка"
                                    )
                              ))
                              ).
    assign
    p-view-log = yes
    .
end.

end procedure .



procedure cb-xmlparse-tag-start-err:
define input parameter p-parameter as character no-undo .
/* обработка события "начало Err"*/

do
on error undo, return error
:
  if v-is-spool-file
  then do:
    assign
    v-start-err = v-start-err + 1
    v-num-errors = v-num-errors + 1
    v-errormessage = '':U
    v-errorseverity = 0
    v-errornum = '':U
    .
    if p-pos-type = {&cd-type-MAGIA-XML} then do:
      assign
      v-ErrorMessage = cb-xmlparse-get-attr(
                                input this-procedure:handle
                              ,input p-spool-or-data
                              ,input p-parameter
                              ,input "ErrorMessage":U
                              ,input yes)
      v-ErrorNum =  cb-xmlparse-get-attr(
                                input this-procedure:handle
                              ,input p-spool-or-data
                              ,input p-parameter
                              ,input "Error":U
                              ,input no)
      v-ErrorSeverity =  integer(cb-xmlparse-get-attr(
                                input this-procedure:handle
                              ,input p-spool-or-data
                              ,input p-parameter
                              ,input "ErrorSeverity":U
                              ,input no))
      no-error
      .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!&1: &2 &3                   Код &4"
                              , (if v-errorseverity = 0
                                then "Информация"
                                else (if v-Errorseverity = 1
                                      then "Предупреждение"
                                      else "Ошибка"
                                      )
                                )
                              , v-ErrorMessage
                              , {&new-line}
                              , v-ErrorNum
                            )
                                          ).
      assign
      p-view-log = yes
      .
    end.
  end.
  else do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Нарушение протокола обмена : тэг Err", p-spool-or-data
                            )
                                          ).
      assign
      p-view-log = yes
      .
    /*todo ошибка*/
  end.
end.

end procedure. /* cb-xmlparse-tag-start-err */

procedure cb-xmlparse-tag-end-err :
define input parameter p-parameter as character no-undo .
/* обработка события "конец err"*/

do
on error undo, return error
:
  if p-pos-type = {&cd-type-magia-xml} then do:
    /*если мы здесь то кончился err !!!*/
    if v-start-err =  1 then do:
      assign
      v-start-err = 0
      .
      /*разберем на атрибуты*/

    end.
    else do:
      assign
      v-start-err = v-start-err - 1
      .
      /*todo ошибка*/
    end.
  end.
  if p-pos-type = {&cd-type-ibm-xml}
  or p-pos-type = {&cd-type-autotank}
  then do:
    assign
    v-errornum = v-xmlvalid-tag-value
    no-error .
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!           Код &1"
                            , v-ErrorNum  )
                                        ).

    assign
    p-view-log = yes
    .
  end.
end.

end procedure. /* cb-xmlparse-tag-end-err */




PROCEDURE fill-doc-property :
/*------------------------------------------------------------------------------
Purpose:
Parameters:  <none>
Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-tag-name   as character    no-undo.
define input parameter p-tag-value  as character    no-undo.
define buffer buf_db for ub.db.

if v-mail-parameters-start = yes
then do:
  CASE p-tag-name:
    when "DocumentName":U
    then do:
      if p-tag-value = p-spool-or-data then do:
      end.
      else do:
        /*нечто нам не нужное уходим совсем*/
      end.
    end.
    when "DateFormat":U
    then do:
      assign
      v-date-format = p-tag-value
      .
    end.
    when "DocumentVersion":U
    then do:
      assign
      v-version = p-tag-value
      .
    end.
    when "DecimalSeparator":U
    then do:
      assign
      v-dec-sep = p-tag-value
      .
    end.
    when "objList":U then do:

    end.
    when "dbEncKey":U then do:
      assign
      v-db-key-enc = p-tag-value
      .
      find first buf_db where buf_db.db-num = g#db-num no-lock.
      if buf_db.db-key-enc = v-db-key-enc then do:
        return error
        substitute("Кодир. значение ключа БД-приемника &1 совпадает с кодир. значением ключа БД-источника &2&3- импорт данных со своей БД на свою БД невозможен"
                   , buf_Db.db-key-enc
                   , v-db-key-enc
                   , {&new-line}).
      end.
    end.
  end case.
end.        /* v-mail-parameters-start = yes */
end.
end PROCEDURE.

procedure create-temp-table-record :
define input parameter p-record-name as character no-undo .
define input parameter p-field-name as character no-undo .
define input parameter p-field-value as character no-undo .

  do
  on error undo, return error
  :
    if p-record-name = "Param" or p-record-name = "FuelPump" then do:
    find first temp-param where
               temp-param.cr = cri + 1 no-error .
    if not avail temp-param then do:
      create
      temp-param.
      assign
      temp-param.cr = cri + 1
      .
    end.
    assign
    temp-param.record-name = p-record-name
    temp-param.field-name  = p-field-name
    temp-param.field-value = p-field-value
    temp-param.desk        = m-head-cash-num
    temp-param.key-name    = v-key
    temp-param.group-name  = v-group
    cri                   = cri + 1
    .       
    end.
    else do:    
    find first temp-temp where
               temp-temp.cr = cri + 1 no-error .
    if not avail temp-temp then do:
      create
      temp-temp.
      assign
      temp-temp.cr = cri + 1
      .
    end.
    assign
    temp-temp.record-name = p-record-name
    temp-temp.field-name  = p-field-name
    temp-temp.field-value = p-field-value
    temp-temp.id          = v-id
    temp-temp.ctime       = v-time
    cri                   = cri + 1
    .
    end.

  end.

end procedure. /* create-temp-table-record */



/* $Workfile: cd-xmlg.i $ e n d */