block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : video-action.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SSlivenko
    Created     : Wed May 10 13:20:24 MSK 2017
    Notes       :
  ----------------------------------------------------------------------
p-action :  
1   •   Закрытие документа внешнего прихода
2   •   Закрытие документа списания
3   •   Закрытие документа инвентаризации
4   •   Закрытие\отмена смены
5   •   Ошибка подключения (один из вариантов - не правильный пароль)
6   •   Сверка до\после
  
  
  */

/* ***************************  Definitions  ************************** */

define input parameter p-action as integer no-undo .
define input parameter p-param  as longchar no-undo .
define output parameter p-ok    as logical no-undo .
define output parameter p-mes   as character no-undo .

{ cmp/str-glbl.i }
{ gbl/sys-time.i }

define temp-table tt-params
    field p-code    as character
    field p-value   as character
    index pi as primary unique
        p-code
.

define variable v-action-name   as character no-undo .
define variable v-numpar        as integer no-undo .
define variable v-par as character no-undo .
define variable ii as integer no-undo .
define variable sw as handle no-undo .
define variable cmd as character no-undo .

define variable v-section   as character no-undo .
define variable v-key       as character no-undo .
define variable v-path      as character no-undo .
define variable v-id        as character no-undo .
define variable v-trans-file as character no-undo .
define variable v-resp-file as character no-undo .
define variable v-resp-line as character no-undo .
define variable v-resp-line-ent1 as character no-undo .
define variable v-resp-line-ent2 as character no-undo .
define variable dt          as datetime no-undo .

define variable v-computer-name        as character no-undo .
define variable v-computer-tcp-name    as character no-undo .
define variable v-computer-ip-addr     as character no-undo .
define variable v-computer-login-name  as character no-undo .
define variable v-computer-process-pid as integer   no-undo .

define variable hRoot as handle  no-undo.
define variable hDoc  as handle  no-undo.
define variable hRow  as handle  no-undo.
define variable hText as handle  no-undo.

    
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

v-numpar = num-entries(p-param, {&delim-par}) .

case p-action :
    when 50
    then do :
        v-action-name = "Авторизация пользователя" .
    end.
    when 51
    then do :
        v-action-name = "Открытие смены" .
    end.
    when 52
    then do :
        v-action-name = "Изменение персонала смены" .
    end.
    when 53
    then do :
        v-action-name = "Отмена смены" .
    end.
    when 54
    then do :
        v-action-name = "Удаление смены" .
    end.
    when 55
    then do :
        v-action-name = "Создание документа пользователем" .
    end.
    when 56
    then do :
        v-action-name = "Регистрация показаний АСИ" .
    end.
    when 57
    then do :
        v-action-name = "Изменение статуса документа" .
    end.
    when 58
    then do :
        v-action-name = "Изменение статуса документа сверки" .
    end.
    when 59
    then do :
        v-action-name = "Удаление документа" .
    end.
    when 60
    then do :
        v-action-name = "Удаление документа сверки" .
    end.
    when 61
    then do :
        v-action-name = "Изменение статуса резервуара" .
    end.
    when 62
    then do :
        v-action-name = "Закрытие смены" .
    end.
    when 63
    then do :
        v-action-name = "Закрытие приложения" .
    end.
    when 65
    then do :
        v-action-name = "Изменение уровня остатков сверх допустимого значения в отсутствие отпуска и штатной приемки" .
    end.
    when 66
    then do :
        v-action-name = "Изменение параметров допустимого отклонения" .
    end.
    otherwise
    do :
        
    end.
end case .   

empty temp-table tt-params .

do ii = 1 to v-numpar :
    v-par = entry(ii, p-param, {&delim-par}) .
    create tt-params.
    assign
        tt-params.p-code    = entry(1, v-par, "=")
        tt-params.p-value   = entry(2, v-par, "=")
    .
    tt-params.p-value = replace(tt-params.p-value,'"','').
end.

assign
    v-section = 'CCTV':u
    v-key     = 'path':u
.

get-key-value section v-section key v-key value v-path .
if v-path = ? or trim(v-path) = ""
then do :
    p-ok = false.
    p-mes = "В .ini файле не указан путь к серверу видеонаблюдения".
    return.
end.

assign
    v-key     = 'id':u
.

get-key-value section v-section key v-key value v-id .  
if v-id = ? or trim(v-id) = ""
then do :
    p-ok = false.
    p-mes = "В .ini файле не указан терминал для сервера видеонаблюдения".
    return.
end.

run sys-time_get-comp-user-name in this-procedure
    (output v-computer-name
    ,output v-computer-login-name
    ,output v-computer-process-pid
    ) .

run gbl/tcp-info.p
      (output v-computer-tcp-name
      ,output v-computer-ip-addr
      ) .    

/*os-delete "TransBlock.xml".        */
/*os-delete "RespTrans.xml".         */
/*assign                             */
/*    v-trans-file = "TransBlock.xml"*/
/*    v-resp-file = "RespTrans.xml"  */
/*.                                  */

os-delete "TransBlock.json".
os-delete "RespTrans.json".
assign
    v-trans-file = "TransBlock.json"
    v-resp-file = "RespTrans.json"
.

dt = now - (timezone * 60000) .

output to value(v-trans-file) convert target "UTF-8".

put unformatted
/*    'POST /PosEvent?content=json HTTP/1.1' skip*/
/*    'Host: localhost:8000' skip                */
/*    'Cache-Control: no-cache' skip             */
/*    skip                                       */
    CHR(123) skip
    '"FunctionNumber":"' string(p-action) '",' skip 
    '"FunctionName":"' v-action-name '",' skip 
    '"TransactionTimestamp":"' iso-date(dt) '",' skip
    '"Terminal":"' v-id '",' skip
    '"Ip":"' v-computer-ip-addr '",' skip
    '"HostName":"' v-computer-tcp-name '",' skip
    '"UserName":"' v-computer-login-name '"'
.

for each tt-params no-lock  :
    put unformatted
        ',' skip '"' tt-params.p-code '":"' tt-params.p-value '"'    
    .
end.

put unformatted
    skip '}' skip .
.

output close .    

/*create sax-writer sw .                                                   */
/*sw:formatted = true.                                                     */
/*sw:set-output-destination ("file", v-trans-file).                        */
/*sw:encoding = "UTF-8".                                                   */
/*sw:start-document () .                                                   */
/*    sw:start-element ("TransactionBlock") .                              */
/*        sw:write-data-element ("FunctionNumber", string(p-action)) .     */
/*        sw:write-data-element ("TransactionTimestamp", iso-date(dt)) .   */
/*        sw:write-data-element ("Terminal", v-id) .                       */
/*        sw:write-data-element ("IpAdress", v-computer-ip-addr) .         */
/*        sw:write-data-element ("TCPname", v-computer-tcp-name) .         */
/*        sw:write-data-element ("UserName", v-computer-login-name) .      */
/*        for each tt-params no-lock :                                     */
/*            sw:write-data-element (tt-params.p-code, tt-params.p-value) .*/
/*        end.                                                             */
/*    sw:end-element ("TransactionBlock") .                                */
/*sw:end-document () .                                                     */

/*cmd = substitute ('&1 --connect-timeout 5 curl -X POST -d @&2 &3/PosEvent?content=xml --header "Content-Type:text/xml" >&4',search ("exe/curl.exe"), v-trans-file, v-path, v-resp-file).*/
cmd = substitute ('&1 --connect-timeout 5 curl -X POST -d @&2 &3/PosEvent?content=json --header "Content-Type:application/json" >&4',search ("exe/curl.exe"), v-trans-file, v-path, v-resp-file).
os-command silent value (cmd).

file-info:file-name = search (v-resp-file).
if search (v-resp-file) = ? or file-info:file-size = 0 
then do:
  assign
    p-ok = false
    p-mes = "Не удалось получить ответ от системы видеонаблюдения"
  .
  output to value (ibs.th.gbl.gbl-inipar:logDir + "svn-err.log") append .
  put unformatted string(today, "99/99/9999") "    " string(time, "hh:mm:ss")
                  "    нет ответа от СВН IP " v-path skip.
  output close .
  return.
end.

output to value (v-resp-file) append .
put unformatted " " skip " _ ".
output close .

input from value (v-resp-file) .
import unformatted v-resp-line .
output close .

v-resp-line = trim(v-resp-line, chr(123)) .
v-resp-line = trim(v-resp-line, "} ") .
v-resp-line-ent1 = entry(1,v-resp-line) .
v-resp-line-ent2 = entry(2,v-resp-line) .

if v-resp-line-ent1 begins '"Description"'
then
p-mes = trim(entry(2, v-resp-line-ent1, ':'), '"') .
else
p-ok = trim(entry(2, v-resp-line-ent1, ':'), '"') = "ok" .

if v-resp-line-ent2 begins '"Description"'
then
p-mes = trim(entry(2, v-resp-line-ent2, ':'), '"') .
else
p-ok = trim(entry(2, v-resp-line-ent2, ':'), '"') = "ok" . 

/*create x-document hDoc.                  */
/*create x-noderef  hRoot.                 */
/*create x-noderef  hRow.                  */
/*create x-noderef  hText.                 */
/*                                         */
/*hDoc:load ("file", v-resp-file, false).  */
/*hDoc:get-document-element(hRoot) .       */
/*                                         */
/*do ii = 1 to hRoot:num-children:         */
/*  hRoot:get-child(hRow,ii) no-error.     */
/*  case hRow:name:                        */
/*    when "Status" then                   */
/*    do:                                  */
/*      hRow:get-child (hText, 1) no-error.*/
/*      if hText:node-value = "ok" then    */
/*      assign                             */
/*        p-ok = true                      */
/*        p-mes = ""                       */
/*      .                                  */
/*    end.                                 */
/*    when "Description" then              */
/*    do:                                  */
/*      hRow:get-child (hText, 1) no-error.*/
/*      p-mes = hText:node-value no-error. */
/*    end.                                 */
/*  end case.                              */
/*end.                                     */
