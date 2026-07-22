block-level on error undo, throw.
/*
$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Обмен данными с кассой по блокировке пистолетов

Автор: Шкляр Елена
Дата создания: 24/05/21
Author: Shklyar Elena
Creation date: 24/05/21
*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обмен данными с кассой по блокировке пистолетов".

define temp-table tt_place no-undo
   field pl-code   as integer 
   field gds-code  as integer
   field pump-code as integer
   index pi as UNIQUE pl-code gds-code pump-code .
   
define temp-table tt_nozzle no-undo
   field pump-code   as integer
   field nozzle-code as integer
   index pi as UNIQUE pump-code nozzle-code.

define temp-table tt_answer no-undo
   field FuelPump      as integer
   field FPFNzl        as integer
   field FPFActive     as integer
   field FPFBlockStaff as integer
   field ctrl          as character
   .    
{ str/get-chk.i  NEW }
{ str/get-chkf.i }
{ bge/bgelib.i }
{ str/cd-xml.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/key-rec.i }
{ str/nzpl-spl.i }
{ trg/cplgdspm.i }

define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle .
define variable v-tth                as handle    no-undo.
define variable v-Param-Type         as character no-undo.
define variable glog                 as logical   no-undo.
define variable v-value-character    as character no-undo.
define variable v-value-date         as date      no-undo.
define variable v-value-decimal      as decimal   no-undo.
define variable v-value-integer      as integer   no-undo.
define variable v-value-logical      as logical   no-undo.
define variable v-no-get-chk         as logical   no-undo.
define variable log-file-name        as character no-undo .
define variable p-auto               as integer   no-undo .
define variable m-obj-code           as integer   no-undo.
define variable m-cash-num           as integer   no-undo.
define variable m-post-file-name     as character no-undo.
define variable m-response-file-name as character no-undo.
define variable m-xml-file-name      as character no-undo.
define variable m-obj-list           as character no-undo.
define variable m-correspondent      as character no-undo.
define variable m-timestamp          as character no-undo.
define variable Check-ctrl           as character no-undo.
define variable ErrorMessage         as character no-undo.
define variable mElement             as character no-undo.
define variable mCount               as int64     no-undo.
define variable m-err-msg            as character no-undo.
define variable v-host-code          like ub.sysconf.host-code no-undo .
define variable p-other              as character no-undo .
define variable p-ok                 as logical   no-undo .
define variable v-FuelPump           as integer   no-undo .
define variable v-ctrl               as character no-undo .
define variable existPlCode          as logical   no-undo .

define buffer buf_cash-desk   for cash-desk.
define buffer bf_cash-desk    for cash-desk.
define buffer cash-place      for ub.place .
define buffer buf_pl-gds-pump for ub.pl-gds-pump .
define buffer buf_tt-place    for tt_place .

define variable v-uniq-key-rec  as character no-undo .
define variable v-view-log      as logical   no-undo .
define variable v-spec-command  as character no-undo .
define variable vMsg            as character no-undo.
define variable Mreq            as longchar  no-undo.
define variable hSAXWriter      as handle    no-undo.
define variable p-obj-code      as integer   no-undo .
define variable p-obj-type      as character no-undo .
define variable p-log-file-name as character no-undo .
define variable p-pl-code       as character no-undo .
define variable p-pl            as character no-undo .
define variable ii              as integer   no-undo .
define variable kk              as integer   no-undo .
define variable p-comand        as character no-undo .
define variable p-pl-list       as character no-undo .
define variable v-teg           as character no-undo .
define variable v-teg-value     as character no-undo .
define variable v-string        as character no-undo .
define variable errorUnblock    as character no-undo .

{ bge/socet.i }

p-obj-code = v-cntxt-obj-code .
p-obj-type = v-cntxt-obj-type .
{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }

p-pl-list = entry(8, p-parameter, {&delim-par}).
p-comand = entry(1, p-pl-list, ",").
p-pl-code = entry(2, p-pl-list, ",").

/* получаем связку выбранных пистолетов*/  
do kk = 1 to num-entries (p-pl-code,";"):
   p-pl = entry (kk, p-pl-code,";" ) .   
   find first tt_place where tt_place.pump-code = integer(entry(2,p-pl,":"))
                         and (if num-entries(p-pl,":") > 2 
                              then tt_place.pl-code = integer(entry(3,p-pl,":")) 
                              else true) no-error .
   if not available (tt_place) then 
   do: 
      create  tt_place .
      assign
         tt_place.pump-code = integer(entry(2,p-pl,":"))
         .
      if num-entries(p-pl,":") > 2 then
        assign 
          tt_place.pl-code = integer(entry(3,p-pl,":"))
          existPlCode = true
        .
   end.
   find first tt_nozzle where tt_nozzle.pump-code = integer(entry(2,p-pl,":")) and tt_nozzle.nozzle-code = integer(entry(1,p-pl,":")) no-error .
   if not available (tt_nozzle) then 
   do:
      create  tt_nozzle .
      assign
         tt_nozzle.nozzle-code = integer(entry(1,p-pl,":"))
         tt_nozzle.pump-code   = integer(entry(2,p-pl,":"))
         .
   end.   
end.   
run xml-cd-filename in this-procedure (
   input out
   ,output v-xml-file-name
   ,output v-xml-file-name-path
   ,output v-log-file-name
   ,output v-locked
   ).
case p-comand:
   when "block" then 
      do:
         v-teg = "FPFBlockStaff".
         v-teg-value = "1".
      end.
   when "unblock" then 
      do:
         v-teg = "FPFBlockStaff".
         v-teg-value = "0".
      end.
   when "ACTIVE" then 
      do:
         v-teg = "FPFActive".
         v-teg-value = "0".
      end.
   when "NOACTIVE" then 
      do:
         v-teg = "FPFActive".
         v-teg-value = "1".
      end.            
end case .   

run adm/shattri.p (
   input "get":U
   ,input  v-cntxt-obj-type
   ,input  v-cntxt-obj-code
   ,input  {&attr-petrol}
   ,input  {&attr-petrol_timeout-block-nozzle} /*p-param-code*/
   ,output v-value-character
   ,output v-value-date
   ,output v-value-decimal
   ,output v-value-integer
   ,output v-value-logical
   ,output v-param-type
   ,INPUT-OUTPUT table-handle v-tth
   ) no-error .

if v-value-integer > 0 then 
do:
   mWaitFramTimeOut = v-value-integer.

   mWaitFramView = yes.
   mWaitFramTextBeg = "Timeout ожидания.".
   subscribe   to "WaitFramStop" anywhere.
   run WaitFramWaitFor(1).
   unsubscribe   to "WaitFramStop".
end.      
   
_cash-desk:
FOR EACH buf_cash-desk WHERE
   buf_cash-desk.db-num   = g#db-num
   and buf_cash-desk.obj-code = p-obj-code
   and buf_cash-desk.pos-type = {&cd-type-Autotank}
   and buf_cash-desk.autonomy = INTEGER({&cd-manager})
   no-lock:

   run gen-key-rec in this-procedure ( input {&table_cash-desk}
      ,input (buffer buf_cash-desk:handle)
      ,output v-uniq-key-rec).
      
   case p-comand:
      when "block" then 
         do:
            p-other = substitute("&1=blocknzl,&2"
               ,buf_cash-desk.pos-type
               ,v-uniq-key-rec).  
         end.
      when "unblock" then 
         do:
            p-other = substitute("&1=unblocknzl,&2"
               ,buf_cash-desk.pos-type
               ,v-uniq-key-rec).  
         end.          
   end case .   
         
   create sax-writer hSAXWriter.
   hSAXWriter:set-output-destination("longchar", Mreq) no-error.
               
   hSAXWriter:formatted = true.
   hSAXWriter:encoding = "windows-1251".
               
   hSAXWriter:start-document() no-error.
   define variable OS-time as character no-undo.
   OS-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" ).
   hSAXWriter:start-element("data") no-error.
   hSAXWriter:insert-attribute("type",   "REQUEST")       no-error.
   hSAXWriter:insert-attribute("id",     v-xml-file-name) no-error.
   
   for each tt_place:
      hSAXWriter:START-ELEMENT("FuelPump").
      hSAXWriter:insert-attribute("code",  string(tt_place.pump-code)             )    no-error.         
      hSAXWriter:insert-attribute("ctrl",   "ADD"              )   no-error.
      
      for each tt_nozzle where tt_nozzle.pump-code = tt_place.pump-code:
         hSAXWriter:START-ELEMENT( "FPFuel").
         hSAXWriter:write-data-element("FPFNzl"        , string(tt_nozzle.nozzle-code)).
         hSAXWriter:write-data-element(v-teg     , v-teg-value).
         hSAXWriter:END-ELEMENT("FPFuel").
      end.
      hSAXWriter:END-ELEMENT("FuelPump" ).
      hSAXWriter:START-ELEMENT("FuelPump").
      hSAXWriter:insert-attribute("code",  string(tt_place.pump-code)             )    no-error.         
      hSAXWriter:insert-attribute("ctrl",   "READ"              )   no-error.
      hSAXWriter:END-ELEMENT("FuelPump" ).
   end.
   hSAXWriter:end-element("data") no-error.
   hSAXWriter:end-document() no-error.
   if hSAXWriter:write-status = 7 then 
   do:
      delete object hSAXWriter no-error.
      return error.
   end.
   delete object hSAXWriter no-error.
   log-file-name = (if p-auto = 0 then 'get-block-nozzle.log' else 'extgetcd.log').

   run str/get-inis.p (
      input p-obj-type
      , input p-obj-code
      , input buf_cash-desk.pos-type
      , input buf_cash-desk.remote
      , input "get":U /*некий параметр который говорит для чего нам настройки*/
      , output out
      , output out2
      , output in_
      , output spl
      , output sav
      , output v-remote
      )  no-error .
   if error-status:error then 
   do:
      run write-log-and-file in p-log-handle (
         input 1
         , input log-file-name
         , input 1
         , input substitute(
         "!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
         , buf_cash-desk.pos-type
         , p-obj-code
         , {&new-line}
         , error-status:get-message(1)
         , return-value
         )).
      assign
         v-view-log = yes.
   end.
 
   if p-comand = "active" or p-comand = "block" then 
   do:
      run write-log-and-file in p-log-handle (
         input 1
         , input log-file-name
         , input 1
         , input substitute('Блокирование выбранных пистолетов с кассы &1://&2'
         ,entry(1, buf_cash-desk.addr-path, {&delim-par})
         ,entry(2, buf_cash-desk.addr-path, {&delim-par})
         )
         ).
      mWriteRespFile = replace(in_ + sav + "/" + v-xml-file-name, "/", "\" ) + ".xml_sckt".
      run ConectSocet (entry(1,entry(2, buf_cash-desk.addr-path, {&delim-par}),":"),
         entry(2,entry(2, buf_cash-desk.addr-path, {&delim-par}),":"),
         "",
         Mreq,
         "xml",
         30,
         no,
         substitute ("Блокирование выбранных пистолетов с кассы &1. ",entry(2, buf_cash-desk.addr-path, {&delim-par}))
         ).
   end.
   else 
   do:
      run write-log-and-file in p-log-handle (
         input 1
         , input log-file-name
         , input 1
         , input substitute('Разблокирование пистолетов с кассы &1://&2'
         ,entry(1, buf_cash-desk.addr-path, {&delim-par})
         ,entry(2, buf_cash-desk.addr-path, {&delim-par})
         )
         ).
      mWriteRespFile = replace(in_ + sav + "/" + v-xml-file-name, "/", "\" ) + ".xml_sckt".
      run ConectSocet (entry(1,entry(2, buf_cash-desk.addr-path, {&delim-par}),":"),
         entry(2,entry(2, buf_cash-desk.addr-path, {&delim-par}),":"),
         "",
         Mreq,
         "xml",
         30,
         no,
         substitute ("Разблокирование пистолетов с кассы &1. ",entry(2, buf_cash-desk.addr-path, {&delim-par}))
         ).
   end.
   if mWebResp eq "" 
      then 
   do:
      run write-log-and-file in p-log-handle (
         input 1
         , input log-file-name
         , input 1
         , input substitute( "!!!Касса &1 маг&2 не ответила:&3&4 &5"
         ,buf_cash-desk.cash-num
         ,buf_cash-desk.obj-code
         , {&new-line}
         , OerrMsg
         , return-value
         )
         ).
      case p-comand:
         when "block" then 
            do:
               for each tt_place,
                  each tt_nozzle where tt_nozzle.pump-code = tt_place.pump-code:
                  v-string = v-string + {&new-line} + "ТРК № " + string(tt_nozzle.pump-code) + " Пистолет № " + string (tt_nozzle.nozzle-code) .
               end.
               if v-string <> "" then 
               do:
                  return "Для кассы: " + string (buf_cash-desk.cash-num) + {&new-line} +
                     v-string + "," + {&new-line} +
                     "для которых не прошла блокировка" + {&new-line} + {&new-line} +
                     "ПОВТОРИТЬ?" .
               /*                  view-as alert-box question buttons yes-no update v-block-ok-error as logical  .*/
               /*               if v-block-ok-error then next _cash-desk-update .                                 */
               end.
            end.
         when "unblock" then 
            do:
               for each tt_place,
                  each tt_nozzle where tt_nozzle.pump-code = tt_place.pump-code:
                  v-string = v-string + {&new-line} + "ТРК № " + string(tt_nozzle.pump-code) + " Пистолет № " + string (tt_nozzle.nozzle-code) .
               end.
               if v-string <> "" then 
               do:
                  return "Для кассы: " + string (buf_cash-desk.cash-num) + {&new-line} +
                     v-string + "," + {&new-line} +
                     "для которых не прошла разблокировка" + {&new-line} + {&new-line} +
                     "ПОВТОРИТЬ?" .
               /*                  view-as alert-box question buttons yes-no update v-unblock-ok-error as logical  .*/
               /*               if v-unblock-ok-error then next _cash-desk-update .                                 */
               end. 
            end.          
      end case .         
   end.
   else 
   do:
      run write-log-and-file in p-log-handle (
         input 1
         , input log-file-name
         , input 1
         , input substitute('Время ожидания выполнения задания на кассе - &1 c',
         mSocetEndTime
         )
         ).
   end.

   assign
      v-index = index(p-other, buf_cash-desk.pos-type + '=').
   if v-index > 0 then 
   do:
      /*извлечем спец команду*/

      assign
         v-spec-command = substring(p-other, v-index)
         v-index        = index(v-spec-command , {&delim-par})
         v-spec-command = if v-index > 0
                        then substring(v-spec-command , 1, v-index - 1)
                        else v-spec-command
         v-spec-command = replace(v-spec-command, buf_cash-desk.pos-type + '=', '':U)
         .
   end.
        
   run str/getxibmf.p (
      input parparentproc
      ,input p-log-handle
      ,input p-obj-type
      ,input p-obj-code
      ,input v-host-code
      ,input in_
      ,input spl
      ,input (in_ + sav)
      ,input buf_cash-desk.pos-type
      ,input "utf-8":U
      ,input log-file-name
      ,input "readbuffer_config":U + {&delim-par} + v-spec-command
      ,input mWebResp
      ,input-output v-view-log
      ) no-error .
   v-string = "" .

   empty temp-table tt_answer .
   case p-comand:
      when "block" then 
         do:
            run SaxReader no-error.
            for each tt_answer where tt_answer.ctrl = "READ" and (tt_answer.FPFBlockStaff = 1 or tt_answer.FPFBlockStaff = 3):
               for each buf_pl-pump-nozzle where               
                  buf_pl-pump-nozzle.obj-type = p-obj-type            
                  AND buf_pl-pump-nozzle.obj-code = p-obj-code        
                  and buf_pl-pump-nozzle.pump-code = tt_answer.FuelPump
                  and buf_pl-pump-nozzle.nozzle-code = tt_answer.FPFNzl 
                  and (if existPlCode then 
                      can-find(first tt_place where tt_place.pump-code = buf_pl-pump-nozzle.pump-code 
                                                and tt_place.pl-code = buf_pl-pump-nozzle.pl-code)
                      else true) no-lock,
                  each buf_pl-gds-pump exclusive-lock where buf_pl-gds-pump.obj-code = buf_pl-pump-nozzle.obj-code and
                  buf_pl-gds-pump.obj-type = buf_pl-pump-nozzle.obj-type and
                  buf_pl-gds-pump.pump-code = buf_pl-pump-nozzle.pump-code and
                  buf_pl-gds-pump.pl-code = buf_pl-pump-nozzle.pl-code
                  :
                  buf_pl-gds-pump.status_ = {&blocked-status} .
               end.
            end.
            for each tt_place,
               each tt_nozzle where tt_nozzle.pump-code = tt_place.pump-code:
               for each buf_pl-pump-nozzle where               
                  buf_pl-pump-nozzle.obj-type = p-obj-type            
                  AND buf_pl-pump-nozzle.obj-code = p-obj-code        
                  and buf_pl-pump-nozzle.pump-code = tt_nozzle.pump-code
                  and buf_pl-pump-nozzle.nozzle-code = tt_nozzle.nozzle-code
                  and (if existPlCode then buf_pl-pump-nozzle.pl-code = tt_place.pl-code else true) no-lock,
                  each buf_pl-gds-pump exclusive-lock where buf_pl-gds-pump.obj-code = buf_pl-pump-nozzle.obj-code and
                  buf_pl-gds-pump.obj-type = buf_pl-pump-nozzle.obj-type and
                  buf_pl-gds-pump.pump-code = buf_pl-pump-nozzle.pump-code and
                  buf_pl-gds-pump.pl-code = buf_pl-pump-nozzle.pl-code
                  :
                  if buf_pl-gds-pump.status_ <> {&blocked-status} then 
                  do:
                     v-string = v-string + {&new-line} + "ТРК № " + string(tt_nozzle.pump-code) + " Пистолет № " + string (tt_nozzle.nozzle-code) .
                  end.
               end.
            end.
            if v-string <> "" then 
            do:
               return "Для кассы: " + string (buf_cash-desk.cash-num) + {&new-line} +
                  v-string + "," + {&new-line} +
                  "для которых не прошла блокировка" + {&new-line} + {&new-line} +
                  "ПОВТОРИТЬ?" .
            end.
         end.
      when "unblock" then 
         do:
            run SaxReader no-error.

            for each tt_place,
               each tt_nozzle where tt_nozzle.pump-code = tt_place.pump-code:
               if not can-find (tt_answer where (tt_answer.FPFBlockStaff = 1 or tt_answer.FPFBlockStaff = 3) and tt_answer.ctrl = "READ") then 
               do:
                  for each buf_pl-pump-nozzle where               
                     buf_pl-pump-nozzle.obj-type = p-obj-type            
                     AND buf_pl-pump-nozzle.obj-code = p-obj-code        
                     and buf_pl-pump-nozzle.pump-code = tt_nozzle.pump-code
                     and buf_pl-pump-nozzle.nozzle-code = tt_nozzle.nozzle-code
                     and (if existPlCode then buf_pl-pump-nozzle.pl-code = tt_place.pl-code else true) no-lock,
                     each buf_pl-gds-pump exclusive-lock where buf_pl-gds-pump.obj-code = buf_pl-pump-nozzle.obj-code and
                     buf_pl-gds-pump.obj-type = buf_pl-pump-nozzle.obj-type and
                     buf_pl-gds-pump.pump-code = buf_pl-pump-nozzle.pump-code and
                     buf_pl-gds-pump.pl-code = buf_pl-pump-nozzle.pl-code and 
                     buf_pl-gds-pump.status_ <> {&current-status}
                     :
                     run cplgdspm in this-procedure
                      ( input buf_pl-gds-pump.obj-type
                       ,input buf_pl-gds-pump.obj-code
                       ,input buf_pl-gds-pump.pl-code
                       ,input buf_pl-gds-pump.gds-code
                       ,input buf_pl-gds-pump.pump-code
                       ,input {&current-status}
                      ) no-error.
                     if error-status:error then 
                     do:
                        errorUnblock = errorUnblock + {&new-line} + {&new-line} + return-value.
                     end.
                     else
                     do:
                        buf_pl-gds-pump.status_ = {&current-status} .
                     end.
                  end.
               end.
               else 
               do:
                  v-string = v-string + {&new-line} + "ТРК № " + string(tt_nozzle.pump-code) + " Пистолет № " + string (tt_nozzle.nozzle-code) .
               end.
            end.
            if v-string <> "" then 
            do:
               return "Для кассы: " + string (buf_cash-desk.cash-num) + {&new-line} +
                  v-string + "," + {&new-line} +
                  "для которых не прошла разблокировка" + {&new-line} + {&new-line} +
                  "ПОВТОРИТЬ?".
            end. 
            else 
            do:
               return if errorUnblock = "" then "Разблокировка пистолетов прошла успешно" 
                                            else "Ошибка при разблокировке:" + errorUnblock.
            end.
         end.          
   end case .
end.  


procedure SaxReader:
   define variable hParser as handle no-undo.
  
   create sax-reader hParser.
   hParser:set-input-source("longchar", mWebResp).
   hParser:sax-parse () no-error.
   if error-status:error then 
   do:
      if error-status:num-messages > 0 then
         /* unable to begin the parse */
         return error error-status:get-message(1).
      else
         /* error detected in a callback */
         return error return-value.
   end.
   delete object hParser.
end.

PROCEDURE StartDocument:

END PROCEDURE.

/* Invoked when the XML parser detects the beginning of an element. */
PROCEDURE StartElement:
   DEFINE INPUT PARAMETER namespaceURI AS CHARACTER.
   DEFINE INPUT PARAMETER localName AS CHARACTER.
   DEFINE INPUT PARAMETER qname AS CHARACTER.
   DEFINE INPUT PARAMETER attributes AS HANDLE.
   mElement = qname.
   if mElement = "FuelPump" then 
   do:
      assign
         v-FuelPump = integer(attributes:GET-VALUE-BY-QNAME("code"))
         v-ctrl     = attributes:GET-VALUE-BY-QNAME("ctrl")
         .
   end.    
   if mElement = "FPFuel" then 
   do:
      create tt_answer .
      tt_answer.ctrl = v-ctrl .
      tt_answer.FuelPump = v-FuelPump .
   end.

END PROCEDURE.

PROCEDURE Characters:
   DEFINE INPUT PARAMETER charData AS MEMPTR.
   DEFINE INPUT PARAMETER numChars AS INTEGER.
   
   define variable vCurrContent as character no-undo.
   vCurrContent = GET-STRING(charData, 1, GET-SIZE(charData)).
   
   if trim(vCurrContent) = "" then return.

   case mElement:
      when "FPFNzl" then
         tt_answer.FPFNzl      = integer(vCurrContent) no-error.
      when "FPFActive" then
         tt_answer.FPFActive      = integer(vCurrContent) no-error.
      when "FPFBlockStaff" then
         tt_answer.FPFBlockStaff      = integer(vCurrContent) no-error.
                  
   end case.

END PROCEDURE.

PROCEDURE EndElement:
   DEFINE INPUT PARAMETER name_ AS CHARACTER.
   DEFINE INPUT PARAMETER localName AS CHARACTER.
   DEFINE INPUT PARAMETER qName AS CHARACTER.
   
   define buffer prod-bc for prod-bc.
   define buffer chk-gds for chk-gds.
   define buffer goods   for goods.

   define variable v-gds-code as integer no-undo.

   if qName = "FuelPump" then 
   do:

   end.
   if qName = "FPFuel" then 
   do:

   end.
END PROCEDURE.

/* Invoked when the XML parser detects the end of an XML document. */
PROCEDURE EndDocument:
   p-ok = true.

END PROCEDURE.

/*/* Invoked to report a warning. */                                                        */
/*PROCEDURE Warning:                                                                        */
/*   DEFINE INPUT PARAMETER ErrMessage AS CHARACTER NO-UNDO.                                */
/*   MESSAGE "The following WARNING was generated:~n" + ErrMessage                          */
/*      VIEW-AS ALERT-BOX INFO BUTTONS OK.                                                  */
/*END PROCEDURE.                                                                            */
/*                                                                                          */
/*/* Invoked to report an error encountered by the parser while parsing the XML document. */*/
/*PROCEDURE Error:                                                                          */
/*   DEFINE INPUT PARAMETER ErrMessage AS CHARACTER NO-UNDO.                                */
/*   p-ok = false.                                                                          */
/*   MESSAGE "The following NONFATAL ERROR was generated:~n" + ErrMessage                   */
/*      VIEW-AS ALERT-BOX INFO BUTTONS OK.                                                  */
/*END PROCEDURE.                                                                            */
/*                                                                                          */
/*/* Invoked to report a fatal error. */                                                    */
/*PROCEDURE FatalError:                                                                     */
/*   DEFINE INPUT PARAMETER ErrMessage AS CHARACTER NO-UNDO.                                */
/*   p-ok = false.                                                                          */
/*   RETURN ERROR "The following FATAL ERROR was generated:~n" + ErrMessage.                */
/*END PROCEDURE.                                                                            */
