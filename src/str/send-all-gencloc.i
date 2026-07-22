/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

*/

/*  {1} - предполагается cash-desk*/
/*  вставляется в цикл по кассам */

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

hSAXWriter:end-element(V-root-teg) no-error.
if error-status:num-messages > 0
then do:
   define variable vnummes as integer no-undo.
   do vnummes = 1 to error-status:num-messages: 
      run write-log-and-file in p-log-handle (
                                  input 1
                                , input log-file-name
                                , input 1
                                , input substitute('Ошибка формироваания запроса &1:'
                                              ,error-status:get-message (vnummes)
                                            )).
   end.
end.
hSAXWriter:end-document() no-error.
if hSAXWriter:write-status = 7 
then do:
   delete object hSAXWriter no-error.
   return error.
end.
delete object hSAXWriter no-error.
if v-xml-encoding = "Windows-1251" then
   copy-lob from mData to mReq.
else
   copy-lob from mData to mReq convert target codepage v-xml-encoding.
if session:debug-alert then
    copy-lob from mReq to file i-Type + "2kassa.xml".

if     
/*       not (g#news or g#auto or g#esys )*/
/*   and  Это должны решать сами процедуры запроссов в каком режиме им работать */
   
   vOk
then do:
  if (for-cash-desk.pos-type = {&cd-type-ibm-xml}
  and for-cash-desk.autonomy = integer({&cd-self}))
  or (for-cash-desk.pos-type = {&cd-type-autotank}
  and for-cash-desk.autonomy = integer({&cd-manager}))
  then do:
      
     run write-log-and-file in p-log-handle (
                               input 1
                             , input log-file-name
                             , input 1
                             , input substitute('Отправка данных на кассы &1 &2'
                                           ,for-cash-desk.cash-num /* entry(1, for-cash-desk.addr-path, {&delim-par}) */
                                           ,for-cash-desk.obj-code /* entry(2, for-cash-desk.addr-path, {&delim-par}) */
                                         )). 



     run ConectSocet (entry(1,entry(2, for-cash-desk.addr-path, {&delim-par}),":"),
                      entry(2,entry(2, for-cash-desk.addr-path, {&delim-par}),":"),
                      "",
                      Mreq,
                      "xml",
                      30,
                      no,
                      substitute ("Отправка данных на кассы &1. ",entry(2, for-cash-desk.addr-path, {&delim-par}))
                                         ).
     if mWebResp eq "" 
     then do:
        run write-log-and-file in p-log-handle (
             input 1
           , input log-file-name
           , input 1
           , input substitute( "!!!Касса &1 маг&2 не ответила:&3&4 &5"
                                 ,for-cash-desk.cash-num
                                 ,for-cash-desk.obj-code
                                 , {&new-line}
                                 , OerrMsg
                                 , return-value
                             )
                                             ).
        v-view-log = yes.
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
        if lookup("parse-result", v-work-handle:internal-entries) >  0
        then do:
           run parse-result in v-work-handle(
                          input mWebRespMptr
                         ,input-output v-view-log
                         ) no-error .
           if error-status:error then do:
              run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных"
                                      ,for-cash-desk.obj-code
                                      ,for-cash-desk.cash-num
                                  )
                                                  ).
              v-view-log = yes.
           end.
        end.
     end.        
  end.
  
end.


/* $Workfile$ e n d */
