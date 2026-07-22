block-level on error undo, throw.
/*
$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Обмен данными с кассой по топливным транзакциям

Автор: Рукавишников Вадим
Дата создания: 24/05/21
Author: Rukavishnikov Vadim
Creation date: 24/05/21
*/

define input  parameter parparentproc   as widget-handle         no-undo.
define input  parameter p-parent-handle as widget-handle         no-undo.
define input  parameter p-log-handle    as handle                no-undo.
define input  parameter p-log-file-name as character             no-undo.
define input  parameter p-obj-type      like ub.clients.obj-type no-undo.
define input  parameter p-obj-code      like ub.clients.obj-code no-undo.
define output parameter p-ok            as logical               no-undo.

define variable vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: Пт авг 05 19:16:25 2022 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: get-tran-fuel.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/get-tran-fuel.p $":U .
define variable vss-description as character no-undo init "Обмен данными с кассой по топливным транзакциям".

{ cmp/str-glbl.i }
{ cmp/ini-lib.i  }
{ str/get-chk.i }
{ bge/socet.i }
define variable Mreq as longchar no-undo.
/*{ gbl/getcntxt.i def }*/
/*{ gbl/getcntxt.i get }*/

function fConvetDateTime returns datetime
    (input iTStamp as character):
   
   define variable vDateTime as datetime no-undo.
   define variable vDate     as date     no-undo.
   define variable vDays     as int64    no-undo.
   define variable vSec      as integer  no-undo.

   vDays = truncate(int64(iTStamp) / 3600 / 24, 0).
   vDate = date("01/01/1970") + vDays.
   vSec = (int64(iTStamp) - vDays * 3600 * 24).
   vDateTime = datetime(string(vDate) + " " + string(vSec, "HH:MM:SS")).
   
   return vDateTime.
end function.

define temp-table tt-tranfuel no-undo like tran-fuel.
define temp-table tt-one-tranfuel no-undo like tran-fuel.

define variable v-tth             as handle     no-undo.
define variable v-Param-Type      as character  no-undo.
define variable out               as character  no-undo.
define variable in_               as character  no-undo.
define variable glog              as logical    no-undo.
define variable v-value-character as character  no-undo.
define variable v-value-date      as date       no-undo.
define variable v-value-decimal   as decimal    no-undo.
define variable v-value-integer   as integer    no-undo.
define variable v-value-logical   as logical    no-undo.
define variable v-no-get-chk      as logical    no-undo.

define variable m-obj-code           as integer   no-undo.
define variable m-cash-num           as integer   no-undo.
define variable m-pos-type           as character no-undo.
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


run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  {&attr-get-chk}
    ,input  {&attr-get-chk_no-get-chk} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .

v-no-get-chk = v-value-logical.
if v-no-get-chk then do:
   m-err-msg = substitute( "Согласно настроечным параметрам НЕТ приема чеков в &1&2!!!&3"
                          ,p-obj-type
                          ,p-obj-code
                          ,{&new-line}
                         ).
   return error m-err-msg.
end.

run verify-ini-entry("in":U,
                      substitute("kassa-&1":U, {&cd-type-IBM-XML}),
                      substitute ("отсутствует путь к подкаталогу out" + {&new-line} + "для отсылки информации на POS &1", {&cd-type-IBM-XML}),
                      yes,
                      output in_) no-error.
if error-status:error or in_ = ? then return error return-value .
RUN verify-file in this-procedure
                                  ( in_
                                  , substitute("Не найден каталог &1 параметр in, секция [kassa-&2] ini-файла", in_, {&cd-type-IBM-XML})
                                  ,yes
                                  ,output glog) no-error.
if error-status:error or not glog then return error return-value .

run verify-ini-entry("out":U,
                      substitute("kassa-&1":U, {&cd-type-IBM-XML}),
                      substitute ("отсутствует путь к подкаталогу out" + {&new-line} + "для отсылки информации на POS &1", {&cd-type-IBM-XML}),
                      yes,
                      output out) no-error.
if error-status:error or out = ? then return error return-value .
run verify-file in this-procedure
                                  ( out
                                  , substitute("Не найден каталог &1 параметр out, секция [kassa-&2] ini-файла", out, {&cd-type-IBM-XML})
                                  , yes
                                  ,output glog) no-error.
if error-status:error or not glog then return error return-value .

run gbl/dir-cre.p ( input in_ + 'tranfuel\') no-error .
if error-status:error then do:
  return error substitute(
                        "!!!Каталог &1 не найден&2" +
                        "и/или попытка его создания не удалась:&2&3 &4"
                        , in_ + 'tranfuel\'
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value
                        ).
end.

run gbl/dir-cre.p ( input out + 'tranfuel\') no-error .
if error-status:error then do:
  return error substitute(
                        "!!!Каталог &1 не найден&2" +
                        "и/или попытка его создания не удалась:&2&3 &4"
                        , out + 'tranfuel\'
                        , {&new-line}
                        , error-status:get-message(1)
                        , return-value
                        ).
end.

run MainProc no-error.
if error-status:error then do:
   return error return-value.
end.

procedure MainProc:
   define buffer cash-desk for cash-desk.
   
   define variable vMsg as character no-undo.
   
   _cash-desk:
   FOR EACH cash-desk WHERE
            cash-desk.db-num   = g#db-num
        and cash-desk.obj-code = p-obj-code
        and cash-desk.pos-type = {&cd-type-IBM-XML}
        and cash-desk.cash-on  = yes
   no-lock:
      empty temp-table tt-tranfuel.
      assign
         m-xml-file-name      = substring(string( next-value( s-spool, {&db-name_schema}), '99999999999999999999'), 13, 8 )
         m-obj-list           = {&shop} + "_" + string(cash-desk.obj-code)
         m-correspondent      = ("касса_" + string(cash-desk.cash-num) + "_" + m-obj-list)
         m-post-file-name     = replace(out + "tranfuel/" + m-xml-file-name, "/", "\" ) + ".xml":U
         m-response-file-name = replace(in_ + "tranfuel/" + m-xml-file-name, "/", "\" ) + ".xml":U
         m-obj-code           = cash-desk.obj-code
         m-pos-type           = cash-desk.pos-type
         m-cash-num           = cash-desk.cash-num
         mCount               = 0
         .

      run pGetLastTStamp(m-obj-code,
                         m-pos-type,
                         m-cash-num,
                         output m-timestamp).
       run write-log-and-file in p-log-handle (
                      input 1
                    , input p-log-file-name
                    , input 1
                    , input substitute('Получаем данных по топливным транзакциям с кассы &1://&2'
                                  ,entry(1, cash-desk.addr-path, {&delim-par})
                                  ,entry(2, cash-desk.addr-path, {&delim-par})
                                )
                                                      ).
   
      run SaxWriter no-error.
      if error-status:error then do:
         return error return-value.
      end.
      mWriteRespFile = m-response-file-name + "sckt".
      run ConectSocet (entry(1,entry(2, cash-desk.addr-path, {&delim-par}),":"),
                       entry(2,entry(2, cash-desk.addr-path, {&delim-par}),":"),
                       "",
                       Mreq,
                       "xml",
                       300,
                       no,
                       substitute ("Чтение данных по топливным транзакциям с кассы &1. ",entry(2, cash-desk.addr-path, {&delim-par}))
                       ).
      if    mWebResp eq ""
         or OerrMsg  ne ""
      then do:
         run write-log-and-file in p-log-handle (
             input 1
           , input p-log-file-name
           , input 1
           , input substitute( "!!!Касса &1 маг&2 не ответила:&3&4 &5"
                                 ,cash-desk.cash-num
                                 ,cash-desk.obj-code
                                 , {&new-line}
                                 , OerrMsg
/*                                , return-value*/
                             )
                                             ).
          nEXT _cash-desk.
       end.
       else do:
          run write-log-and-file in p-log-handle (
             input 1
           , input p-log-file-name
           , input 1
           , input substitute('Время ожидания выполнения задания на кассе - &1 c',
                         mSocetEndTime
                       )
                                             ).
      end.
      run SaxReader no-error.
      if ErrorMessage <> "" or error-status:error then do:
         return error ErrorMessage + " " + return-value.
      end.

      do transaction:
         for each tt-tranfuel where
                  tt-tranfuel.cash-num = m-cash-num: /* Чеки с других касс пропускаем */
            find first tran-fuel where
                       tran-fuel.db-num    = tt-tranfuel.db-num
                   and tran-fuel.uuid      = tt-tranfuel.uuid
                   and tran-fuel.uuid-cheq = tt-tranfuel.uuid-cheq
            no-lock no-error.
            if not avail tran-fuel then do:
               create tran-fuel.
               buffer-copy tt-tranfuel to tran-fuel.
               mCount = mCount + 1.
            end.
         end.
      end.
      vMsg = "Загружено топливных транзакций: " + string(mCount).
      run write-log-and-file in p-log-handle (
            input 1
          , input p-log-file-name
          , input 1
          , input vMsg).
      p-ok = true.
   end.
end procedure.

procedure pGetLastTStamp:
   define input  parameter p-obj-code as integer   no-undo.
   define input  parameter p-pos-type as character no-undo.
   define input  parameter p-cash-num as integer   no-undo.
   define output parameter oTStamp    as character no-undo.
   
   define buffer tran-fuel for tran-fuel.
   
   define variable v-last-date      as date     no-undo .
   define variable v-last-time      as integer  no-undo .
   define variable v-last-shift-num as integer  no-undo .
   define variable v-last-z-count   as integer  no-undo .
   define variable v-last-chk-num   as integer  no-undo .
   
   run get-last-check-params in this-procedure ( input g#db-num
                                                ,input p-obj-code
                                                ,input p-pos-type
                                                ,input p-cash-num
                                                ,output v-last-date
                                                ,output v-last-time
                                                ,output v-last-shift-num
                                                ,output v-last-z-count
                                                ,output v-last-chk-num
                                                ) no-error.
   if v-last-date <> ? and v-last-time <> ? then
      oTStamp = string( ( v-last-date - date( "01/01/1970" ) ) * 24 * 3600 + v-last-time - Timezone * 60 - 1 * 60 * 60, ">>>>>>>>>9" ). /* Дополнительно сдвинем на 1 час назад */
   else
      oTStamp = "0".

end procedure.

procedure SaxWriter:
  define variable hSAXWriter as handle no-undo.
  create sax-writer hSAXWriter.
  hSAXWriter:set-output-destination("longchar", Mreq) no-error.
  hSAXWriter:formatted = true.
  hSAXWriter:encoding = "windows-1251".

  hSAXWriter:start-document() no-error.

  hSAXWriter:start-element("fuels") no-error.
    hSAXWriter:insert-attribute("type",   "REQUEST")       no-error.
    hSAXWriter:insert-attribute("id",     m-xml-file-name) no-error.
    hSAXWriter:insert-attribute("from",   m-obj-list)      no-error.
    hSAXWriter:insert-attribute("to",     m-correspondent) no-error.
    hSAXWriter:insert-attribute("tstamp", m-timestamp)     no-error.
  hSAXWriter:end-element("fuels") no-error.

  hSAXWriter:end-document() no-error.
  if hSAXWriter:write-status = 7 then do:
    delete object hSAXWriter no-error.
    return error.
  end.
  delete object hSAXWriter no-error.
end.

procedure SaxReader:
  define variable hParser as handle no-undo.
  
  create sax-reader hParser.
  hParser:set-input-source("longchar", mWebResp).
  hParser:sax-parse () no-error.
  if error-status:error then do:
      if error-status:num-messages > 0 then
          /* unable to begin the parse */
          return error error-status:get-message(1).
      else
          /* error detected in a callback */
           return error return-value.
  end.
  delete object hParser.
end.

/* SAXCallbacks */

/* Invoked when the XML parser detects the start of an XML document. */
PROCEDURE StartDocument:

END PROCEDURE.

/* Invoked when the XML parser detects the beginning of an element. */
PROCEDURE StartElement:
   DEFINE INPUT PARAMETER namespaceURI AS CHARACTER.
   DEFINE INPUT PARAMETER localName AS CHARACTER.
   DEFINE INPUT PARAMETER qname AS CHARACTER.
   DEFINE INPUT PARAMETER attributes AS HANDLE.
   
   mElement = qname.
   if mElement = "TranFuel" then do:
      empty temp-table tt-one-tranfuel.
      create tt-one-tranfuel.
      assign
         tt-one-tranfuel.db-num   = g#db-num
         tt-one-tranfuel.obj-code = m-obj-code
         .
   end.

END PROCEDURE.

/* Invoked when the XML parser detects character data. */
PROCEDURE Characters:
   DEFINE INPUT PARAMETER charData AS MEMPTR.
   DEFINE INPUT PARAMETER numChars AS INTEGER.
   
   define variable vCurrContent as character no-undo.
   vCurrContent = GET-STRING(charData, 1, GET-SIZE(charData)).
   
   if trim(vCurrContent) = "" then return.

   case mElement:
      when "TFId" then 
         tt-one-tranfuel.id            = integer(vCurrContent) no-error.
      when "TFTrkNum" then
         tt-one-tranfuel.trk-num       = integer(vCurrContent) no-error.
      when "TFTranNum" then
         tt-one-tranfuel.tran-num      = integer(vCurrContent) no-error.
      when "TFVolume" then
         tt-one-tranfuel.volume        = decimal(vCurrContent) / 100 no-error.
      when "TFMoney" then
         tt-one-tranfuel.money         = decimal(vCurrContent) / 100 no-error.
      when "TFReqVolume" then
         tt-one-tranfuel.req-volume    = decimal(vCurrContent) / 100 no-error.
      when "TFReqMoney" then
         tt-one-tranfuel.req-money     = decimal(vCurrContent) / 100 no-error.
      when "TFPaymode" then
         tt-one-tranfuel.pay-mode      = integer(vCurrContent) no-error.
      when "TFNozzleNum" then
         tt-one-tranfuel.nozzle-num    = integer(vCurrContent) no-error.
      when "TFFuelCode" then
         tt-one-tranfuel.fuel-code     = integer(vCurrContent) no-error.
      when "TFPrice" then
         tt-one-tranfuel.price         = decimal(vCurrContent) / 100 no-error.
      when "TFPaycode" then
         tt-one-tranfuel.pay-code      = integer(vCurrContent) no-error.
      when "TFDateBeg" then
         tt-one-tranfuel.date-beg      = fConvetDateTime(vCurrContent) no-error.
      when "TFDateEnd" then
         tt-one-tranfuel.date-end      = fConvetDateTime(vCurrContent) no-error.
      when "TFNumCheq" then
         tt-one-tranfuel.num-cheq      = integer(vCurrContent) no-error.
      when "TFUuid" then
         tt-one-tranfuel.uuid          = vCurrContent.
      when "TFClientMoney" then
         tt-one-tranfuel.client-money  = decimal(vCurrContent) / 100 no-error.
      when "KassaNumber" then
         tt-one-tranfuel.cash-num      = integer(vCurrContent) no-error.
      when "TFTransferFrom" then
         tt-one-tranfuel.transfer-from = integer(vCurrContent) no-error.
      when "TFUuidCheq" then
         tt-one-tranfuel.uuid-cheq     = vCurrContent.
      when "ErrorMessage" then
         ErrorMessage = vCurrContent.
         
   end case.

END PROCEDURE.

/* Invoked when the XML parser detects the end of an element. */
PROCEDURE EndElement:
   DEFINE INPUT PARAMETER name_ AS CHARACTER.
   DEFINE INPUT PARAMETER localName AS CHARACTER.
   DEFINE INPUT PARAMETER qName AS CHARACTER.
   
   define buffer prod-bc for prod-bc.
   define buffer chk-gds for chk-gds.
   define buffer goods   for goods.

   define variable v-gds-code as integer no-undo.
   if qname = "ErrorMessage" then do:
/*      ErrorMessage = mcurrentContent.*/
      self:stop-parsing ().
   end.
   else if qName = "TranFuel" then do:
      find first tt-tranfuel where
                 tt-tranfuel.db-num    = tt-one-tranfuel.db-num
             and tt-tranfuel.uuid      = tt-one-tranfuel.uuid
             and tt-tranfuel.uuid-cheq = tt-one-tranfuel.uuid-cheq
      no-lock no-error.
      if not avail tt-tranfuel then do:
         v-gds-code = tt-one-tranfuel.fuel-code.
         find first prod-bc where
                    prod-bc.b-str = string(v-gds-code)
         no-lock no-error.
         if avail prod-bc then do:
            find first goods where
                       goods.gds-code = prod-bc.b-code
            no-lock no-error.
            if avail goods then
               v-gds-code = goods.gds-code.
         end.

         create tt-tranfuel.
         buffer-copy tt-one-tranfuel to tt-tranfuel
            assign
               tt-tranfuel.fuel-code = v-gds-code
               .
      end.
   end.

END PROCEDURE.

/* Invoked when the XML parser detects the end of an XML document. */
PROCEDURE EndDocument:
   p-ok = true.

END PROCEDURE.

/* Invoked to report a warning. */
PROCEDURE Warning:
   DEFINE INPUT PARAMETER ErrMessage AS CHARACTER NO-UNDO.
   MESSAGE "The following WARNING was generated:~n" + ErrMessage
       VIEW-AS ALERT-BOX INFO BUTTONS OK.
END PROCEDURE.
    
/* Invoked to report an error encountered by the parser while parsing the XML document. */
PROCEDURE Error:
   DEFINE INPUT PARAMETER ErrMessage AS CHARACTER NO-UNDO.
   p-ok = false.
   MESSAGE "The following NONFATAL ERROR was generated:~n" + ErrMessage
       VIEW-AS ALERT-BOX INFO BUTTONS OK.
END PROCEDURE.

/* Invoked to report a fatal error. */
PROCEDURE FatalError:
    DEFINE INPUT PARAMETER ErrMessage AS CHARACTER NO-UNDO.
    p-ok = false.
    RETURN ERROR "The following FATAL ERROR was generated:~n" + ErrMessage.
END PROCEDURE.

