/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 9 июля 2021 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 9 июля 2021 г.

*/
&scoped-define vssseq {&sequence}
define variable vss-revision{&vssseq}    as character no-undo init "$Revision:$":U .
define variable vss-author{&vssseq}      as character no-undo init "$Author:$":U .
define variable vss-date{&vssseq}        as character no-undo init "$Date:$":U .
define variable vss-workfile{&vssseq}    as character no-undo init "$Workfile:$":U .
define variable vss-archive{&vssseq}     as character no-undo init "$Archive:$":U .
define variable vss-description{&vssseq} as character no-undo init "Работа С сокетом".
{cmp\str-glbl.i}
{ utl/proc-async.i proc_log}
&scop CRLF chr(13) + chr(10)
&scop HdEnd chr(13) + chr(10) + chr(13) + chr(10)
{ gbl/waitfram.i }
define variable mHSocket       as handle      no-undo.
define variable mWebRespHead   as longchar    no-undo.
define variable mWebResp       as longchar    no-undo.
define variable mWebRespMptr   as memptr      no-undo.
define variable OerrMsg        as character   no-undo.
define variable mFileLogSocet  as character   no-undo.
define variable mReturnHttp    as logical     no-undo.
define variable mAddTimeOut    as logical     no-undo init yes.
define variable mSocetBegTime  as datetime-tz no-undo.
define variable mSocetEndTime  as dec         no-undo.
define variable mWriteRespFile as character   no-undo.
define variable mTypeResponse  as character   no-undo init "POST".
publish "getSocetLog" (output mFileLogSocet).
if 
   (   mFileLogSocet eq ""
    or mFileLogSocet eq ?)
   and session:debug-alert
then
   mFileLogSocet = "socet.log".
/*------------------------------------------------------------------------------
  Purpose: Процедура, которая формирует и отправляет POST отправляет запрос 
  Parameters: iHost            - ДНС имя хоста
              iPort            - Порт обращения
              iUrl             - часть адреса, идентифицирующая ссылку
              iPostData        - параметры (после ? в URL)
              iPostData        - параметры (после ? в URL)
              iReturnType      - Что ожидать в ответе text или xml или http
              iTimeOut         - время ожидания ответа
              iSilent          - Молчаливый режим по умолчанию no
              iTextWait        - Текст для пользователя во время ожидания 
  Notes:
------------------------------------------------------------------------------*/
procedure ConectSocet:
   define input  parameter iHost       as character no-undo.
   define input  parameter iPort       as character no-undo.
   define input  parameter iUrl        as character no-undo.
   define input  parameter iPostData   as longchar  no-undo.
   define input  parameter iReturnType as character no-undo.
   define input  parameter iTimeOut    as decimal   no-undo.
   define input  parameter iSilent     as logical   no-undo.
   define input  parameter iTextWait   as character no-undo.
   mWaitFramTextBeg = iTextWait.
   run SendReqSocet (iHost, iPort, iUrl, iPostData, iReturnType, 'getResponse').
   if OerrMsg eq ""
   then
      run waitrespsocet (iTimeOut, iSilent, iTextWait).
   mSocetEndTime = (now - mSocetBegTime) / 1000.
end.

/*------------------------------------------------------------------------------
  Purpose: Процедура, которая формирует и отправляет POST отправляет запрос 
  Parameters: iHost            - ДНС имя хоста
              iPort            - Порт обращения
              iUrl             - часть адреса, идентифицирующая ссылку
              iPostData        - параметры (после ? в URL)
              iReturnType      - Что ожидать в ответе text или xml или http
              iProcGetResponse - процедура обработки ответа по умолчанию getResponse
  Notes:
------------------------------------------------------------------------------*/
procedure SendReqSocet:
   define input  parameter iHost            as character no-undo.
   define input  parameter iPort            as character no-undo.
   define input  parameter iUrl             as character no-undo.
   define input  parameter iPostData        as longchar  no-undo.
   define input  parameter iReturnType      as character no-undo.
   define input  parameter iProcGetResponse as character no-undo.
   mSocetBegTime = now.
   run writeLogSocet in this-procedure (substitute("Подключаемся к адресу &1 по порту &2",iHost,iPort )).
   assign
      mWebResp         = ""
      mWebResphead     = ""
      OerrMsg          = ""
      mReturnHttp      = iReturnType eq "xml" or iReturnType eq "http" or iReturnType eq "yes" 
      iProcGetResponse = "getResponse"  when iProcGetResponse eq ? or iProcGetResponse eq "" 
   .
   define variable vPostData as longchar                       no-undo.
/*   define variable vHSocket  as handle                         no-undo.*/
/*   if valid-object(mHSocket) then delete object mHSocket. */
   if    iHost eq ""
      or iHost eq ?
   then do:
      oErrMsg = substitute("Не задан host &1 или port &2.", ihost ,iport).
      run writeLogSocet in this-procedure (oErrMsg).
      return oErrMsg.
   end.
   
   run waitfram-show (substitute("Подключаемся к адресу &1 по порту &2",iHost,iPort )).
   create socket mHSocket.
   mHSocket:connect('-H ' + iHost + ' -S ' + iPort) no-error.
 /*   mHSocket:SET-SOCKET-OPTION('TCP-NODELAY', 'true').
  mHSocket:SET-SOCKET-OPTION('SO-KEEPALIVE', 'true').
  mHSocket:SET-SOCKET-OPTION('SO-REUSEADDR', 'true').
   */
   if mHSocket:connected() = false 
   then do:
      run waitfram-hide .
      oErrMsg = substitute( "Не удалось установить соединение: &1" , error-status:get-message(1)).
      run writeLogSocet in this-procedure (oErrMsg).
      delete object mHSocket.
      return oErrMsg.
   end.
   run waitfram-show ("Отправка данных").
   
   mHSocket:set-read-response-procedure(iProcGetResponse).
   run PostRequest (
    input iUrl,
    input iHost + ":" + iPort,
    input iPostData
    ).
    run waitfram-hide .
   
end.

/*------------------------------------------------------------------------------
  Purpose: Ожидание ответа от сокета 
  Parameters: iTimeOut         - время ожидания ответа
              iSilent          - Молчаливый режим по умолчанию no
  Notes:
------------------------------------------------------------------------------*/
procedure WaitRespSocet:
   define input  parameter iTimeOut   as decimal   no-undo.
   define input  parameter iSilent    as logical   no-undo.
   define input  parameter iTextWait  as character no-undo.
   
   if    not valid-handle (mHSocket )
   then do:
      run writeLogSocet in this-procedure (substitute("Потерян объект соединения")).
  
      return "End connected".
   end.
   if mHSocket:connected() = false 
   then do:
      run writeLogSocet in this-procedure (substitute("Соединение было разорвано другой стороной WaitRespSocet")).
  
      oErrMsg = "Not connected".
      return oErrMsg.
   end.
   mWaitFramView = if iSilent ne yes then yes else no.
   mWaitFramTextBeg = iTextWait.
   mWaitFramTimeOut = iTimeOut.
   mWaitFramTextEnd = "".
   mWaitFramStop = no.
   if mAddTimeOut
   then do:
      mWaitFramTimeOut = 300.
      run writeLogSocet in this-procedure (substitute ("Таймаут увеличен до &1 при уcтановке соодинения",mWaitFramTimeOut)).
   end.
   
   run writeLogSocet in this-procedure (substitute("Ожидаем ответ TimeOut &1 сек.",iTimeOut )).
   
   subscribe   to "WaitFramStop" anywhere run-procedure "WaitRespTestStop".
   run WaitFramWaitFor(1).
   unsubscribe "WaitFramStop".
   if mWaitFramStopUser
   then do:
      OerrMsg = substitute("Операция прервана пользователем." ).
      run writeLogSocet in this-procedure (OerrMsg).
   end.
   else if mWaitFramStopTimeOut
   then do:
      OerrMsg = substitute("Привышено время ожидания &1 сек. Ответ не получен.",iTimeOut ).
      run writeLogSocet in this-procedure (OerrMsg).
   end.
   run waitfram-hide .
   mHSocket:disconnect() no-error.
   delete object mHSocket.
end.

/*------------------------------------------------------------------------------
  Purpose: Процедура, проверки ответа 
  Parameters: 
  Notes:
------------------------------------------------------------------------------*/
procedure WaitRespTestStop:
   if mWaitFramStopTimeOut
   then
      return.
   if     (mWebResp ne ""
       and mWebResp ne ?)
   then do:
      mWaitFramStop = yes.
      return.
   end.
   else if mHSocket:connected() = false 
   then do:
      mWaitFramStop = yes.
      run writeLogSocet in this-procedure (substitute("Соединение было разорвано другой стороной WaitRespTestStop")).
   

      oErrMsg = "Not connected".
      return oErrMsg.
   end.
   wait-for read-response of mHSocket pause 0.001.
   
end.
/*------------------------------------------------------------------------------
  Purpose: Процедура, которая формирует и отправляет POST отправляет запрос 
  Parameters: iPostHost - ДНС имя хоста
              iPostUrl  - часть адреса, идентифицирующая ссылку
              iPostData - параметры (после ? в URL)
  Notes:
------------------------------------------------------------------------------*/
procedure PostRequest:
   define input parameter iPostUrl  as char. 
   define input parameter iPostHost as char.
   define input parameter iPostData as longchar.

   define variable vCRequest      as longchar.
   define variable vMRequest       as memptr.
   if iPostUrl ne ?
   then do:
  /* vCRequest =substitute( 
      'POST &2 HTTP/1.0&1'                                   + 
      'Accept-Encoding: gzip,deflate&1'                      +
      'Content-Type: text/xml;charset=UTF-8&1'               +
      'Content-Length:&3&1'                                  +
      'Host: &4&1'                                           +
    /*  'Connection: Keep-Alive&1'                             + */
      'User-Agent: Apache-HttpClient/4.1.1 (java 1.5)&1'    +
      'Allow: GET,HEAD&1&1&5' 
      ,
      {&carriage-return} + {&new-line}, 
      iPostUrl, 
      length(iPostData),
      iPostHost,
      iPostData).*/
      vCRequest =substitute( 
      '&5 /&2 HTTP/1.1&1'                                   +
      'Host: &4&1'                                           +
      'User-Agent: Apache-HttpClient/4.1.1 (java 1.5)&1'    +
       
      'Accept: */*&1' +
      'Content-Type: text/xml&1'               +
      'Content-Length: &3&1'                                  +
      '&1' 
      ,
      {&carriage-return} + {&new-line}, 
      iPostUrl, 
      length(iPostData),
      iPostHost,
      
      mTypeResponse) + iPostData.
   end.
   else
      vCRequest = iPostData.
   run writeLogSocet in this-procedure (substitute("Отправляем запрос &1.",{&carriage-return} + {&new-line} )).
   run writeLogSocet in this-procedure (vCRequest).
   
   SET-SIZE(vMRequest)            = 0.
   SET-SIZE(vMRequest)            = length(vCRequest) + 1.
   SET-BYTE-ORDER(vMRequest)      = big-endian.
   PUT-STRING(vMRequest,1)        = vCRequest .
   if mHSocket:connected() = false then 
   do:
      run writeLogSocet in this-procedure ("Соединение было разорвано другой стороной getResponse").
   
      oErrMsg = "Not connected".
      delete object mHSocket no-error.
      return oErrMsg.
   end.
   mHSocket:write(vMRequest, 1, length(vCRequest)).
   run writeLogSocet in this-procedure ("Запрос отправлен.").
   
end procedure.

function hex-to-int returns integer (
  input p-hex-code  as character  ).

  define variable v-int-code as integer   no-undo .
  define variable v-ind      as integer   no-undo .
  define variable v-digit    as integer   no-undo .
  define variable v-letter   as character no-undo .

  do v-ind = 1 to length(p-hex-code)
  :
    assign
      v-letter = caps(substring(p-hex-code, v-ind, 1))
    .
    assign
      v-digit = index('123456789ABCDEF':u, v-letter)
    .
    assign
      v-int-code = v-int-code * 16 + v-digit
    .
  end.

  return v-int-code .

end function . /* hex-to-int */
/*------------------------------------------------------------------------------
  Purpose: Процедура, которая вызывается когда приходит ответ от сервера
  Parameters:
  Notes:
------------------------------------------------------------------------------*/
procedure getResponse:

   define variable vFlagTag     as logical          no-undo init no.
   define variable vResponse    as memptr           no-undo.
   define variable vCnt         as int64            no-undo.
   define variable vMessage     as longchar         no-undo.
   define variable v-cont-length as int64 no-undo.
   define variable vi           as integer no-undo.
   define variable v-hd-line    as character no-undo.
   define variable level        as integer no-undo initial 2.
   
   /* EXPSD-7337 проверим, что не было вызова процедуры еще раз */
   repeat while program-name(level) <> ?:
     if program-name(level) = program-name(1) then do:
       run writeLogSocet in this-procedure (substitute("Повторный вызов getResponse.")).
       return "".
     end.
     level = level + 1.
   end. 
   
   if mHSocket:connected() = false then 
   do:
      run writeLogSocet in this-procedure (substitute("Соединение было разорвано другой стороной getResponse")).
   
      oErrMsg = "Not connected".
      return oErrMsg.
   end.
   
   if mAddTimeOut
   then do:
      mWaitFramTimeOut = 1000.
      run writeLogSocet in this-procedure (substitute ("Таймаут увеличен до &1 при получении ответа",mWaitFramTimeOut)).
   end.
   
   run writeLogSocet in this-procedure (substitute("Получаем ответ")).
   mWaitFramTextEnd = "Получаем ответ".
   define variable vWaitProcEvent as logical no-undo.
   vWaitProcEvent = mWaitProcEvent.
   mWaitProcEvent = no. /* Отключим proces event иначе бедет беда с получением данных*/
   run WaitFramRunPause (?).
   define variable vByte as int64 no-undo.
   define variable vNextMese as int64 no-undo init 100000.
   define variable VFlag as logical no-undo init ? .
   mWaitFramStop = no.
   mWaitFramStopTimeOut = no.
   block-wait:
   do while mHSocket:get-bytes-available() > 0:
      VFlag = no.
      define variable vNumByte as integer no-undo.
      vNumByte = /* if mReturnXML and not vFlagTag then 1 else */  mHSocket:get-bytes-available().
      if vNumByte > 30000 then vNumByte = 30000.
      SET-SIZE(vResponse) = vNumByte + 1.
      SET-BYTE-ORDER(vResponse) = big-endian.
      
      mHSocket:read(vResponse,1,vNumByte).
      vMessage = vMessage + GET-STRING(vResponse,1).
      if  mReturnHTTp
      then do:
         /*Отсечение HTTP HEADER*/
         vCnt = index(vMessage,{&carriage-return} + {&new-line} + {&carriage-return} + {&new-line}).
         if vCnt > 0
         then do:
            mReturnHttp = no.
            mWebResphead = substring (vMessage,1,vCnt).
            vMessage     = substring (vMessage,vCnt + 4).
            mWebResphead = replace (mWebResphead,";",{&CRLF}).
            do vi = 1 to num-entries(mWebResphead,{&CRLF}):
               v-hd-line = trim(entry(vi,mWebResphead,{&CRLF})).
/*                  v-querypar = right-trim (right-trim  (entry(n, v-header, "/"), "HTTP"), " ").*/
               if  v-hd-line  begins "Content-Length"  then  do:
                  
                  v-cont-length = INT(trim(substring(v-hd-line,16,length(v-hd-line)))).
               end.
               else if v-hd-line  begins "Transfer-Encoding"
               then do :
                  define variable vChunked as logical no-undo.
                  vchunked = index(v-hd-line,"chunked",19) > 0.
               end.
/*                  else if  v-hd-line  begins "content-type:"  then  do:             */
/*                     v-cont-type = trim(substring(v-hd-line,14,length(v-hd-line))). */
/*                  end.                                                              */
/*                  else if  v-hd-line  begins "user-agent:"  then  do:               */
/*                     v-user-agent = trim(substring(v-hd-line,13,length(v-hd-line))).*/
/*                  end.                                                              */
            end.
         end. 
      end.
      vByte = vByte + vNumByte.
      SET-SIZE(vResponse) = 0.
      if v-cont-length > 0 and length (vMessage) >= v-cont-length
      then
         leave block-wait.
      if not mHSocket:get-bytes-available() > 0
      then do:
         VFlag = yes.
         run WaitFramRunPause (?).
         
         run gbl/pause.p (1000) .      /* ответ приходит медленее чем мы читаем ответ */
      end.
      else if vByte > vNextMese
      then do:
         vNextMese = vNextMese + 100000.
         mWaitFramTextEnd = substitute ("Получаем ответ прочитано &1 байт ",vByte) .
         run WaitFramRunPause (?). 
      end.
       
      
      if mWaitFramStopTimeOut
      then do:
         mWebResp = "".
/*         mHSocket:disconnect ().*/
         leave block-wait.
      end.
   end.
   if VFlag ne false
   then
      run writeLogSocet in this-procedure (substitute ("Завершена обработка &1",If VFlag eq  yes then " 0 байт за последнию секунду" else " пустой ответ(((")).
   
   
   mWaitFramStop = yes.
   run writeLogSocet         in this-procedure ("Получен ответ").
   run writeLogSocetOnlyText in this-procedure (mWebResphead).
   run writeLogSocetOnlyText in this-procedure (substitute("&1&2&1&2",{&carriage-return} , {&new-line} )).
   run writeLogSocetOnlyText in this-procedure (vMessage).
   run writeLogSocetOnlyText in this-procedure (substitute("&1&2",{&carriage-return} , {&new-line} )).
   mHSocket:disconnect() no-error.
   
   if v-cont-length > 0
   then
      mWebResp = substring (vMessage,1,v-cont-length).
   else if vChunked
   then do:
      define variable vByteCopy as int64 no-undo init 1. 
      Block-Copy:
      do while length(vMessage) > 0:
         vByteCopy = 1.
         vCnt = index (vMessage,{&CRLF}) - 1.
         vByteCopy = vByteCopy +  vCnt + 2.
         v-cont-length = hex-to-int(string(substring (vMessage,1,vCnt))).
         if v-cont-length eq 0
         then
            leave Block-copy.
         mWebResp = mWebResp + substring (vMessage,vByteCopy,  v-cont-length).
         vByteCopy = vByteCopy + v-cont-length + 2.
         vMessage = substring  (vMessage,vByteCopy).
      end.
      run writeLogSocet         in this-procedure ("Заголовок").
      run writeLogSocetOnlyText in this-procedure (mWebResphead).
      run writeLogSocet         in this-procedure ("Тело ответа").
      run writeLogSocetOnlyText in this-procedure (mWebResp).
     run writeLogSocetOnlyText in this-procedure (substitute("&1&2",{&carriage-return} , {&new-line} )).
   
   end.
   else
      mWebResp = vMessage.
   mWaitProcEvent = vWaitProcEvent.
/*   if     vFlagTag                                                 */
/*      and R-INDEX(mWebResp,trim(">")) > 0                          */
/*   then                                                            */
/*      mWebResp = substring(mWebResp,1,r-index(mWebResp,trim(">"))).*/
   mSocetEndTime = (now - mSocetBegTime) / 1000.
   copy-lob mWebResp to mWebRespMptr.
   if     mWriteRespFile ne ""
      and mWriteRespFile ne ?
   then
        run gbl/fileapnd.p
             ( mWriteRespFile
             , mWebResp + {&carriage-return} + {&new-line}
             ,input 10 /* время ожинания освобождения файла */
             ) no-error .
                          
      
end procedure.

procedure writeLogSocet:
   define input  parameter itext as longchar no-undo.
   if mFileLogSocet eq "Async"
   then
      run PutMesAsunc(itext).
   else if     mFileLogSocet ne ?
           and mFileLogSocet ne ""
   then do:
      run gbl/fileapnd.p
          ( mFileLogSocet
          , substitute("&1 &2 ", string(today), string(time, "HH:MM:SS"))
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
      run writeLogSocetOnlyText(itext).
      run gbl/fileapnd.p
          ( mFileLogSocet
          , substitute(" &1&2", {&carriage-return} , {&new-line})
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
   end.
end.

procedure writeLogSocetOnlyText:
   define input  parameter itext as longchar no-undo.
   if mFileLogSocet eq "Async"
   then
      run PutMesAsunc(itext).
   else if     mFileLogSocet ne ?
           and mFileLogSocet ne ""
   then do:
      if length(itext) > 32000
      then
         copy-lob
   from object itext
   to file mFileLogSocet append
   no-error
   .
      else
      run gbl/fileapnd.p
          ( mFileLogSocet
          , string(itext) 
          ,input 10 /* время ожинания освобождения файла */
          ) no-error .
   end.
end.

procedure Disconect:
   mHSocket:disconnect() no-error.
   delete object mHSocket no-error.
end.

