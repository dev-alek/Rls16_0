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

hSAXWriter:end-element("data") no-error.
hSAXWriter:end-document() no-error.
if hSAXWriter:write-status = 7 
then do:
   delete object hSAXWriter no-error.
   return error.
end.
delete object hSAXWriter no-error.
/*run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файл &1"
                            , replace( v-xml-file-name-path, "/", "\" ) + "xml"
                      )
                                       ).
*/
if (
not (g#news or g#auto or g#esys )
or
(
  (for-cash-desk.pos-type = {&cd-type-ibm-xml}
or (for-cash-desk.pos-type = {&cd-type-Autotank}
  and
  for-cash-desk.autonomy = integer({&cd-manager}))
  /*ibm-xml тоже хочет нам слать ответы*/
  )))
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
                             , input substitute('Отправка данных на кассы &1://&2'
                                           ,entry(1, for-cash-desk.addr-path, {&delim-par})
                                           ,entry(2, for-cash-desk.addr-path, {&delim-par})
                                         )).
     define variable mWriteRespFile as character no-undo.                                                          
     mWriteRespFile = replace(in_ + sav + "/" + v-xml-file-name, "/", "\" ) + ".xml_sckt".
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
        next _for.
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
  end.
  if not available ub.shop then do:
    find first ub.shop no-lock where
              ub.shop.obj-code = for-cash-desk.obj-code.
  end.
  
    run str/getxibmf.p (
                    input parparentproc
                  ,input p-log-handle
                  ,input {&shop}
                  ,input for-cash-desk.obj-code
                  ,input ub.shop.host-code
                  ,input in_
                  ,input spl
                  ,input (in_ + sav)
                  ,input for-cash-desk.pos-type
                  ,input (if (for-cash-desk.pos-type = {&cd-type-ibm-xml}
                          and for-cash-desk.autonomy = integer({&cd-self}))
                          or (for-cash-desk.pos-type = {&cd-type-autotank}
                          and for-cash-desk.autonomy = integer({&cd-manager}))
                          then "utf-8":U
                          else "windows-1251")
                  ,input log-file-name
              &if "{&subject}" ="file" &then
                  ,input action
              &else
                  ,input "data":U
              &endif
                  ,input v-xml-file-name
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
      assign
      v-view-log = yes
      .
      &if "{&subject}" ="file" &then
        v-reply-file-name = return-value .
      &endif
      
/*      return "error":U.*/
    end.
    &if "{&subject}" ="file" &then
      v-reply-file-name = return-value .
    &endif
end.


/* $Workfile$ e n d */
