/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

закрытие потока и сопутствующие операции для кассы XML MAGIA и IBM

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/03
Author: Bakhtadze Natalya
Creation date: 12/08/03

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{&subject}" ="file" &then
  /*- переименовать: .xm1 -> .xml -*/
  run bge/os_copy.p ("M", v-xml-file-name-path + "xm1", v-xml-file-name-path + "xml", output v-error-num ).
  if v-error-num > 0
  then do:
    return error.
  end.
&else  /*if subject file*/
output stream stmxmlout close.

run xml-cd-write-footer in this-procedure ( input {&cd-buffer}.pos-type, input v-xml-file-name-path
&if "{&subject}"="db-object" &then
    , input (if {&cd-buffer}.pos-type = {&cd-type-IBM-XML}
             then "setup"
             else "data")
&else
    , input {&xml-cd-doc-name}
&endif
).

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Данные выгружены в файл &1"
                            , replace( v-xml-file-name-path, "/", "\" ) + "xml"
                      )
                                       ).
&endif /*endif subject file*/
if (
not (g#news or g#auto or g#esys )
or
(
{&cd-buffer}.pos-type = {&cd-type-magia-xml}
or
  ({&cd-buffer}.pos-type = {&cd-type-ibm-xml}
or ({&cd-buffer}.pos-type = {&cd-type-Autotank}
  and
  {&cd-buffer}.autonomy = integer({&cd-manager}))
  /*ibm-xml тоже хочет нам слать ответы*/
  )))
then do:
  if {&cd-buffer}.pos-type = {&cd-type-magia-xml} then do:
    &if "{&called}" = "in-ov"
    or "{&called}" = "pdf"
    or "{&called}" = "send-gds"
    or "{&called}" = "s-prodbc"
    or "{&called}" = "send-bc"
    or "{&called}" = "del-gds"
    or "{&subject}" = "dis-card"
    or "{&subject}" = "staff"
    or "{&subject}" = "curr-pay"
    or "{&subject}" = "tax"
    or "{&subject}" = "depart"
    or "{&subject}" = "fbr-gds-grp"
    &then
    /*здесь идет блок ожидания файла REPLY и его обработка с кассы*/
    run str/waitpxml.w ( replace( v-xml-file-name-path, "/", "\" ) + "xml",
                (replace(in_ + spl + "/" + v-xml-file-name, "/", "\" ) + ".xml"),
                ( if action = 'U'
                  then ('Ждите - ' + {&out-title-add})
                  else ('Ждите - ' + {&out-title-del}) ) +
                  substitute("Маг&1 касса&2", {&cd-buffer}.obj-code, {&cd-buffer}.cash-num),
                  ' Подождите 15 сек ',
                  'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!',
                  'Подождите: касса обрабатывает запрос',
                  15 ) no-error.
    if error-status:error then do:
      os-delete value( replace( v-xml-file-name-path, "/", "\" ) + "xml" ) .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Прерван обмен информацией с кассой &1, на кассе осталась устаревшая информация",
                                {&cd-buffer}.cash-num
                            )
                                            ).
      assign
      v-view-log = yes
      .
      return "error":U.
    end.
    &endif
  end.
  if ({&cd-buffer}.pos-type = {&cd-type-ibm-xml}
  and {&cd-buffer}.autonomy = integer({&cd-self}))
  or ({&cd-buffer}.pos-type = {&cd-type-autotank}
  and {&cd-buffer}.autonomy = integer({&cd-manager}))
  then do:
      
    run str/post-xml.p
      (
       input parparentproc
      ,input p-parent-handle
      ,input p-log-handle
      ,input g#news or g#esys
      ,input g#auto
       &if "{&subject}" ="file" &then
      ,input 'get,instant'
       &else
      ,input 'send'
       &endif
      ,input log-file-name
      ,input (entry(1, {&cd-buffer}.addr-path, {&delim-par}) + '://' + entry(2, {&cd-buffer}.addr-path, {&delim-par}))
      ,input (replace( v-xml-file-name-path, "/", "\" ) + "xml")
      ,input (replace(in_ + spl + "/" + v-xml-file-name, "/", "\" ) + ".xml")
      ,input 30
      ,input   ( if action = 'U'
                  then ('Ждите - ' + {&out-title-add})
                  else ('Ждите - ' + {&out-title-del}) ) +
                  substitute("Маг&1 касса&2", {&cd-buffer}.obj-code, {&cd-buffer}.cash-num)
      ) no-error .
    if error-status:error
    or return-value = "error" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не удалось получить ответ с маг&1 касса &2 об успешной доставке данных:&3&4 &5"
                                ,{&cd-buffer}.obj-code
                                ,{&cd-buffer}.cash-num
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                            )
                                            ).
      assign
      v-view-log = yes
      .

/*      return "error":U.*/
    end.
  end.
  if not available ub.shop then do:
    find first ub.shop no-lock where
              ub.shop.obj-code = {&cd-buffer}.obj-code.
  end.
  
  if
  &if "{&subject}" ="file" &then
  true
  &else
  not (g#news or g#esys)
  &endif
  then do:
    run str/getxibmf.p (
                    input parparentproc
                  ,input p-log-handle
                  ,input {&shop}
                  ,input {&cd-buffer}.obj-code
                  ,input ub.shop.host-code
                  ,input in_
                  ,input spl
                  ,input (in_ + sav)
                  ,input {&cd-buffer}.pos-type
                  ,input (if ({&cd-buffer}.pos-type = {&cd-type-ibm-xml}
                          and {&cd-buffer}.autonomy = integer({&cd-self}))
                          or ({&cd-buffer}.pos-type = {&cd-type-autotank}
                          and {&cd-buffer}.autonomy = integer({&cd-manager}))
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
                                ,{&cd-buffer}.obj-code
                                ,{&cd-buffer}.cash-num
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
end.
if g#news
or g#auto
or g#esys
and {&cd-buffer}.pos-type = {&cd-type-magia-xml}
then do:
  /*для МАГИИ в режиме СПН просто пренесем файл в sav*/
   /*todo*/

end.


/* $Workfile$ e n d */