block-level on error undo, throw.
/*
$Revision: $
$Author: $
$Date: $
$Workfile: $
$Archive: $

Получение параметров ФФД

Автор: Шкляр Елена
Дата создания: 24/05/21
Author: Shklyar Elena
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
define variable vss-workfile    as character no-undo init "$Workfile: get-ffd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/get-ffd.p $":U .
define variable vss-description as character no-undo init "Получение параметров ФФД".

{ str/get-chk.i  NEW }
{ str/get-chkf.i }
{ bge/bgelib.i }
{ str/cd-xml.i  }
/*{ gbl/getcntxt.i def }*/
/*{ gbl/getcntxt.i get }*/
{ gbl/key-rec.i }

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
define variable p-parameter          as character no-undo .
define variable p-other              as character no-undo .
define buffer buf_cash-desk for cash-desk.
define variable v-uniq-key-rec as character no-undo .
define variable v-view-log     as logical   no-undo .
define variable v-spec-command as character no-undo .
define variable vMsg           as character no-undo.
define variable Mreq           as longchar  no-undo.
define variable hSAXWriter     as handle    no-undo.

{ bge/socet.i }

{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }

_cash-desk:
FOR EACH buf_cash-desk WHERE
   buf_cash-desk.db-num   = g#db-num
   and buf_cash-desk.obj-code = p-obj-code
   and buf_cash-desk.pos-type = {&cd-type-IBM-XML}
   and buf_cash-desk.cash-on  = yes
   no-lock:

   run gen-key-rec in this-procedure ( input {&table_cash-desk}
      ,input (buffer buf_cash-desk:handle)
      ,output v-uniq-key-rec).

   p-parameter = substitute("&1=ffd,&2"
      ,buf_cash-desk.pos-type
      ,v-uniq-key-rec).         
   if num-entries(p-parameter, {&delim-par}) > 7 then 
   do:
      p-other = p-parameter.
      entry(1, p-other, {&delim-par}) = ''.
      p-other = substring(p-other, 2).
      entry(1, p-other, {&delim-par}) = ''.
      p-other = substring(p-other, 2).
      entry(1, p-other, {&delim-par}) = ''.
      p-other = substring(p-other, 2).
      entry(1, p-other, {&delim-par}) = ''.
      p-other = substring(p-other, 2).
      entry(1, p-other, {&delim-par}) = ''.
      p-other = substring(p-other, 2).
      entry(1, p-other, {&delim-par}) = ''.
      p-other = substring(p-other, 2).
      entry(1, p-other, {&delim-par}) = ''.
      p-other = substring(p-other, 2).
   end.
                                                                  
   run xml-cd-filename in this-procedure (
      input out
      ,output v-xml-file-name
      ,output v-xml-file-name-path
      ,output v-log-file-name
      ,output v-locked
      ).
   
   assign
      v-obj-list = {&shop} + string(buf_cash-desk.obj-code)
      .
   create sax-writer hSAXWriter.
   hSAXWriter:set-output-destination("longchar", Mreq) no-error.
               
   hSAXWriter:formatted = true.
   hSAXWriter:encoding = "windows-1251".
               
   hSAXWriter:start-document() no-error.
   define variable OS-time as character  no-undo.
   OS-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" ).
   hSAXWriter:start-element("config") no-error.
   hSAXWriter:insert-attribute("type",   "REQUEST")       no-error.
   hSAXWriter:insert-attribute("id",     v-xml-file-name) no-error.
   hSAXWriter:insert-attribute("from",   string(v-obj-list))      no-error.
   hSAXWriter:insert-attribute("to",     (v-obj-list + "_":U + "касса" + string(buf_cash-desk.cash-num))) no-error.
   hSAXWriter:insert-attribute("tstamp", string(OS-time))     no-error.
   
   define variable mi as integer no-undo.
   define variable vListParam as character no-undo init "~
USE_FFD_VERSION,~
KKT_FFD_VERSION,~
KKT_SCHEMA,~
GISMT_CHECK_TIMEOUT,~
GISMT_OPENCON_TIMEOUT,~
GISMT_FAST_ANSWER".
   
   do mi = 1 to num-entries(vListParam):
      hSAXWriter:START-ELEMENT("Param").
      hSAXWriter:insert-attribute("ctrl",   "READ"              )   no-error.
      hSAXWriter:insert-attribute("group",  "OFD"               )    no-error.
      hSAXWriter:insert-attribute("key",    entry(mi,vListParam))    no-error.
      hSAXWriter:END-ELEMENT("Param" ).
   end.
   hSAXWriter:end-element("config") no-error.
   hSAXWriter:end-document() no-error.
   if hSAXWriter:write-status = 7 then do:
      delete object hSAXWriter no-error.
      return error.
   end.
   delete object hSAXWriter no-error.
   log-file-name = (if p-auto = 0 then 'get-chkf.log' else 'extgetcd.log').

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
   run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute('Получаем параметры ФФД с кассы &1://&2'
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
                    substitute ("Чтение параметры ФФД с кассы &1. ",entry(2, buf_cash-desk.addr-path, {&delim-par}))
                    ).
   if mWebResp eq "" 
   then do:
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
       NEXT _cash-desk.
    end.
    else do:
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

                       
   run write-log-and-file in p-log-handle (
      input 1
      , input p-log-file-name
      , input 1
      , input "Получение параметров ФФД завершено").
   p-ok = true.
end.

