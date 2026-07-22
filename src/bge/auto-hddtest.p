block-level on error undo, throw.
/*

$Revision: 5c1b000f89f8, 2349, rls $
$Author: SSlivenko $
$Date: Ср июн 10 21:13:33 2020 +0300 $
$Workfile: auto-hddtest.p $
$Archive: bge/auto-hddtest.p $

Мониторинг HDD

Автор: Сливенко Сергей
Дата создания: 05/28/18
Author: Slivenko Sergey
Creation date: 05/28/18

*/

using Progress.Lang.*.



define input  parameter p-user-login    as character no-undo .
define input  parameter p-user-password as character no-undo .
define input  parameter p-db-num        as integer no-undo .

def var vss-revision    as character no-undo init "$Revision: 5c1b000f89f8, 2349, rls $":U .
def var vss-author      as character no-undo init "$Author: SSlivenko $":U .
def var vss-date        as character no-undo init "$Date: Ср июн 10 21:13:33 2020 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: auto-hddtest.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/auto-hddtest.p $":U .
def var vss-description as character no-undo init "Работа с ФГИС меркурий".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ adm/auto-def.i }
{ gbl/getsect.i def }

&scop xml-req "<?xml version='1.0' encoding='windows-1251'?>~
<data type='dsw'>~
<HddTest ctrl='READ' tms = '&1'></HddTest>~
<Count>500</Count>~
</data>"

define temp-table HddTest no-undo
  field db-num      as integer
  field id          as int64
  field namepc      as character
  field hddModule   as character
  field testStatus  as character
  field hddFilling  as character
  field hddSysFilling  as character
  field hddName     as character
  field hddSerial   as character
  field sysInfo     as character
  field dt          as datetime-tz
  index i1 as unique
    hddSerial hddModule dt
.

define temp-table hddAttributes no-undo
  field name_       as character
  field value_      as integer
  field thresh      as integer
  field type_       as character
  field raw_value   as character
  field hddModule   as character
  field hddSerial   as character
  field dt          as datetime-tz
  index i1 as unique
    hddSerial hddModule name_ dt
.

function my-date returns datetime-tz (input v-str as character) forward .

define buffer buf_hddAttributes for hddAttributes .

define variable v-ind                    as integer   no-undo .
define variable v-err-gen-pack           as integer   no-undo .
define variable v-err-code               as integer   no-undo .
define variable v-step-num               as integer   no-undo .
define variable v-action                 as character no-undo .
define variable v-message                as character no-undo .
define variable v-proc-handle            as handle    no-undo .
define variable v-main-proc-name         as character no-undo .

define variable log-exit          as logical    no-undo .
define variable curl-path         as character  no-undo .
define variable v-post-file-name  as character  no-undo .
define variable v-response-file-name  as character  no-undo .
define variable v-cmd-file-name   as character  no-undo .
define variable v-command         as character  no-undo .
define variable v-out-str         as character  no-undo .
define variable v-pid-list        as character  no-undo .
define variable v-time-str        as character  no-undo .
define variable v-del-file        as character  no-undo .

define variable v-count-main-prc         as integer   no-undo .
define variable v-pers-proc-name         as character no-undo .

define variable v-part-rowid as rowid no-undo .
define variable v-tbl-name as character no-undo .

define buffer buf_code for ub.Code .
define buffer buf_devisPC for ub.devisPC .
define buffer buf_devisPC-attr for ub.devisPC-attr .

define variable v-start-DT as datetime no-undo initial 1/1/1970 .
define variable v-test-DT as datetime no-undo .
define variable v-epoch-time as integer no-undo .
define variable v-str-dt as character no-undo .
define variable v-tms as integer no-undo .

define variable hDoc              as handle     no-undo .
define variable hRoot             as handle     no-undo .
define variable good              as logical    no-undo .

define variable ii as integer no-undo.

do
on error undo, return error
:
  if transaction then do:
    message
      substitute( "&1. Вызов данной процедуры невозможен при наличии транзакции", vss-workfile )
      view-as alert-box error .
    return error .
  end.
  if valid-handle( session :first-procedure ) then do:
    assign
      v-main-proc-name = "gbl/mainproc.p":U
      v-proc-handle    = session :first-procedure
      v-count-main-prc = 0
      v-pers-proc-name = "":U
    .
    do while valid-handle( v-proc-handle )
    :
      if v-proc-handle :file-name = v-main-proc-name then do:
        assign
          v-count-main-prc = v-count-main-prc + 1
        .
      end.
      else do:
        assign
          v-pers-proc-name = v-pers-proc-name + {&comma-char} + v-proc-handle :file-name
        .
      end.
      assign
        v-proc-handle = v-proc-handle:next-sibling no-error
      .
    end.
    if v-count-main-prc > 1
      or v-pers-proc-name <> "":U
    then do:
      message
        substitute( "&1. Вызов данной процедуры невозможен при наличии определений persistent prosedures &2"
                    + "Список недопустимых процедур: &3&2"
                    + "Исключение - единственная процедура &4&2"
                    + "Определений данной процедуры &5&2"
                    , vss-workfile
                    , {&new-line}
                    , v-pers-proc-name
                    , v-main-proc-name
                    , v-count-main-prc
                   )
        view-as alert-box error .
      return error .
    end.
  end.

  assign
    g#auto                = true
  .
  run gbl/set-gbl.p
    (input true
    ,input p-user-login
    ,input p-user-password
    ) no-error.
  if error-status :error
  then do:
    run write-to-log( substitute("&1. Ошибка при инициализации переменных g#... &2&3&4"
                                  ,vss-workfile
                                  ,error-status:get-message(error-status:num-messages)
                                  ,{&new-line}
                                  ,return-value
                                )
                    ) .
    return error.
  end.
  assign
    g#auto = true
  .
  
  assign
  curl-path = search("exe/curl.exe")
  .
  
  v-response-file-name = "hdd-test-result.xml" .
/*  run write-to-log( "Получение данных " ) .*/
  
   
  run write-to-log( "Работа с БД " + string(p-db-num) ) .

  for each buf_code no-lock where buf_code.parent = "SpravDevice"
                              and buf_code.status_ = 0 :
    if trim(buf_code.misc1) = ""
    then do :
      run write-to-log( "Для устройства " + string(buf_code.code) + " " + string(buf_code.CodeName) + " не указан IP" ) .
      next.
    end.    
    
/*    v-tms = 1546300800. /* 1 января 2019 */*/
    v-tms = interval( now, v-start-DT , "seconds" ) .
    v-tms = v-tms - 604800 - (timezone * 60) . /* За неделю до сегодня */
    find last buf_devisPC no-lock where buf_devisPC.db-num = p-db-num
                                    and buf_devisPC.namepc = buf_code.CodeName
                                    no-error.
    if available buf_devisPC
    then do :
      find last buf_devisPC-attr exclusive-lock where buf_devisPC-attr.db-num = buf_devisPC.DB-num
                                                  and buf_devisPC-attr.id = buf_devisPC.id
                                                  no-error.
      if available buf_devisPC-attr
      then do :
        v-test-DT = dateTime(buf_devisPC-attr.date, (buf_devisPC-attr.time_ * 1000)) .
        v-tms = interval( v-test-DT, v-start-DT , "seconds" ) .
        v-tms = v-tms - 10000 - (timezone * 60) . /* На всякий случай возьмём пораньше */
      end.
    end.
    
    v-post-file-name = "hdd-test-req.xml" .
    v-out-str = substitute ({&xml-req}, string(v-tms)) .
    output to value (v-post-file-name) .
    put unformatted v-out-str skip .
    output close .
    
    v-command = substitute('&1 -0 --connect-timeout 5 -X POST -H "Content-Type: text/xml" -d @"&2" &3 >&4'
                            , curl-path
                            , v-post-file-name
                            , buf_code.misc1
                            , v-response-file-name) .
    os-command silent value (v-command) .  
    
    file-info:file-name = v-response-file-name .
    if file-info:file-size = 0
    then do :
      run write-to-log( "Пустой ответ от устройства " + string(buf_code.CodeName) + ". IP: " +  trim(buf_code.misc1)) .
      next.
    end.
    
    empty temp-table HddTest .
    empty temp-table hddAttributes .
    
    run parse-xml (input v-response-file-name) no-error.
    if error-status:error
    then do :
      run write-to-log( "Не могу разобрать ответ от устройства " + string(buf_code.CodeName) + ". IP: " +  trim(buf_code.misc1)) .
      next.
    end.
    
    for each HddTest no-lock break by HddTest.dt :
      find first buf_devisPC no-lock where buf_devisPC.modeldevice = trim(HddTest.hddModule)
                                       and buf_devisPC.SerialNumber = trim(HddTest.hddSerial)
                                       and buf_devisPC.ModelPC = trim(HddTest.sysInfo)
                                       and buf_devisPC.DB-num = p-db-num
                                       no-error .
      if not available buf_devisPC
      then do :
        create buf_devisPC .
        assign
          buf_devisPC.id = next-value(s-devisPC-id)
          buf_devisPC.DB-num = p-db-num
          buf_devisPC.ModelPC = trim(HddTest.sysInfo)
          buf_devisPC.namepc = buf_code.CodeName
          buf_devisPC.modeldevice = trim(HddTest.hddModule)
          buf_devisPC.SerialNumber = trim(HddTest.hddSerial)
        .
      end. 
      find last buf_devisPC-attr exclusive-lock where buf_devisPC-attr.db-num = buf_devisPC.DB-num
                                                  and buf_devisPC-attr.id = buf_devisPC.id
                                                  and buf_devisPC-attr.attr-code = "ProcDisk"
                                                  and buf_devisPC-attr.date = date(HddTest.dt)
                                                  and buf_devisPC-attr.time_ = integer( truncate( MTIME( HddTest.dt ) / 1000, 0 ) )
                                                  no-error.
      if not available buf_devisPC-attr
      then do :                                           
        create buf_devisPC-attr .
        assign
          buf_devisPC-attr.db-num = buf_devisPC.DB-num
          buf_devisPC-attr.id = buf_devisPC.id
          buf_devisPC-attr.attr-code = "ProcDisk"
          buf_devisPC-attr.date = date(HddTest.dt)
          buf_devisPC-attr.time_ = integer( truncate( MTIME( HddTest.dt ) / 1000, 0 ) )
        .
      end.
      assign buf_devisPC-attr.attr-value = string(HddTest.hddFilling) .
      
      find last buf_devisPC-attr exclusive-lock where buf_devisPC-attr.db-num = buf_devisPC.DB-num
                                                  and buf_devisPC-attr.id = buf_devisPC.id
                                                  and buf_devisPC-attr.attr-code = "UserProc"
                                                  and buf_devisPC-attr.date = date(HddTest.dt)
                                                  and buf_devisPC-attr.time_ = integer( truncate( MTIME( HddTest.dt ) / 1000, 0 ) )
                                                  no-error.
      if not available buf_devisPC-attr
      then do :                                           
        create buf_devisPC-attr .
        assign
          buf_devisPC-attr.db-num = buf_devisPC.DB-num
          buf_devisPC-attr.id = buf_devisPC.id
          buf_devisPC-attr.attr-code = "UserProc"
          buf_devisPC-attr.date = date(HddTest.dt)
          buf_devisPC-attr.time_ = integer( truncate( MTIME( HddTest.dt ) / 1000, 0 ) )
        .
      end.
      assign buf_devisPC-attr.attr-value = string(HddTest.hddSysFilling) .
      
      find last buf_devisPC-attr exclusive-lock where buf_devisPC-attr.db-num = buf_devisPC.DB-num
                                                  and buf_devisPC-attr.id = buf_devisPC.id
                                                  and buf_devisPC-attr.attr-code = "testStatus"
                                                  and buf_devisPC-attr.date = date(HddTest.dt)
                                                  and buf_devisPC-attr.time_ = integer( truncate( MTIME( HddTest.dt ) / 1000, 0 ) )
                                                  no-error.
      if not available buf_devisPC-attr
      then do :
        create buf_devisPC-attr .
        assign
          buf_devisPC-attr.db-num = buf_devisPC.DB-num
          buf_devisPC-attr.id = buf_devisPC.id
          buf_devisPC-attr.attr-code = "testStatus"
          buf_devisPC-attr.date = date(HddTest.dt)
          buf_devisPC-attr.time_ = integer( truncate( MTIME( HddTest.dt ) / 1000, 0 ) )
        .
      end.
      assign buf_devisPC-attr.attr-value = HddTest.testStatus .
              
      for each hddAttributes no-lock where hddAttributes.hddModule   = HddTest.hddModule
                                       and hddAttributes.hddSerial   = HddTest.hddSerial
                                       and hddAttributes.dt          = HddTest.dt :
        find last buf_devisPC-attr exclusive-lock where buf_devisPC-attr.db-num = buf_devisPC.DB-num
                                                    and buf_devisPC-attr.id = buf_devisPC.id
                                                    and buf_devisPC-attr.attr-code = hddAttributes.name_
                                                    and buf_devisPC-attr.date = date(hddAttributes.dt)
                                                    and buf_devisPC-attr.time_ = integer( truncate( MTIME( hddAttributes.dt ) / 1000, 0 ) )
                                                    no-error.
        if not available buf_devisPC-attr     
        then do :                                      
          create buf_devisPC-attr .
          assign
            buf_devisPC-attr.db-num = buf_devisPC.DB-num
            buf_devisPC-attr.id = buf_devisPC.id
            buf_devisPC-attr.attr-code = hddAttributes.name_
            buf_devisPC-attr.date = date(hddAttributes.dt)
            buf_devisPC-attr.time_ = integer( truncate( MTIME( hddAttributes.dt ) / 1000, 0 ) )
          .   
        end.
        assign
          buf_devisPC-attr.attr-value = string(hddAttributes.value_)
          buf_devisPC-attr.attr-Raw-value = string(hddAttributes.raw_value)
          buf_devisPC-attr.tresh = string(hddAttributes.thresh)
          buf_devisPC-attr.type = hddAttributes.type_
        .                            
      end.                                   
    end.                      
  end.

  run write-to-log( "Закончена работа с БД " + string(p-db-num) ) .
  
end.

procedure parse-xml :
  define input parameter p-file as character .
 
  CREATE X-DOCUMENT hDoc.
  CREATE X-NODEREF hRoot.
     
  hDoc:LOAD("file",p-file,FALSE) no-error.
  if error-status:error
  then do :
    DELETE OBJECT hDoc no-error.
    DELETE OBJECT hRoot no-error.
    return error .
  end .
     
  hDoc:GET-DOCUMENT-ELEMENT(hRoot) no-error.
  if error-status:error
  then do :
    DELETE OBJECT hDoc no-error.
    DELETE OBJECT hRoot no-error.
    return error .
  end .
      
  RUN GetChildren(hRoot, 1) no-error.
  if error-status:error
  then do :
    DELETE OBJECT hDoc no-error.
    DELETE OBJECT hRoot no-error.
    return error .
  end .
  
  DELETE OBJECT hDoc.
  DELETE OBJECT hRoot.
  
end procedure .

PROCEDURE GetChildren:
DEFINE INPUT PARAMETER hParent AS HANDLE NO-UNDO.
DEFINE INPUT PARAMETER level AS INTEGER NO-UNDO.

DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE hNoderef AS HANDLE NO-UNDO.
DEFINE VARIABLE hText AS HANDLE NO-UNDO.
define variable client as character no-undo.

CREATE X-NODEREF hNoderef.
CREATE X-NODEREF hText .

i = hParent:num-children no-error .
if error-status:error
or i = ?
then do :
  DELETE OBJECT hNoderef no-error .
  DELETE OBJECT hText no-error .
  return error .
end .

REPEAT i = 1 TO hParent:NUM-CHILDREN:
    good = hParent:GET-CHILD(hNoderef,i).
    IF NOT good THEN 
        LEAVE.
    IF hNoderef:SUBTYPE <> "element" THEN
        NEXT.
    
    hNoderef:GET-CHILD(hText, 1) no-error .    
    
        
    IF hNoderef:NAME = "HddTest"
    then do :
      create HddTest .
      assign v-str-dt = hNoderef:get-attribute("tstamp") .
      integer(v-str-dt) no-error .
      if error-status:error
      then do :
        assign HddTest.dt = my-date(v-str-dt).
      end.
      else do :
        assign v-epoch-time = integer(v-str-dt) .
        assign HddTest.dt = ADD-INTERVAL(v-start-DT, v-epoch-time, "SECONDS").
      end.
    end.
    
    IF hNoderef:NAME = "hddModule" then assign HddTest.hddModule = hText:node-value no-error .
    
    IF hNoderef:NAME = "testStatus"then assign HddTest.testStatus = hText:node-value no-error .
    
    IF hNoderef:NAME = "hddFilling" then assign HddTest.hddFilling = hText:node-value no-error .
    
    IF hNoderef:NAME = "hddSysFilling" then assign HddTest.hddSysFilling = hText:node-value no-error .
    
    IF hNoderef:NAME = "systemInfo" then assign HddTest.sysInfo = hText:node-value no-error .
    
    IF hNoderef:NAME = "hddName" then assign HddTest.hddName = hText:node-value no-error .
    
    IF hNoderef:NAME = "hddSerial"
    then do :
      assign HddTest.hddSerial = hText:node-value no-error .
    end.
    
    IF hNoderef:NAME = "hddAttributes"
    then do :
      create hddAttributes .
      assign
        hddAttributes.hddModule   = HddTest.hddModule
        hddAttributes.hddSerial   = HddTest.hddSerial
        hddAttributes.dt          = HddTest.dt
      .
    end.
    
    IF hNoderef:NAME = "name"
    then do :
      find first buf_hddAttributes where buf_hddAttributes.hddModule = hddAttributes.hddModule
                                     and buf_hddAttributes.hddSerial = hddAttributes.hddSerial
                                     and buf_hddAttributes.dt        = hddAttributes.dt
                                     and buf_hddAttributes.name_     = hText:node-value
                                     no-error .
      if available buf_hddAttributes
      then do :
        delete buf_hddAttributes .
      end. 
      assign hddAttributes.name_ = hText:node-value no-error .
    end.

    
    IF hNoderef:NAME = "value" then assign hddAttributes.value_ = integer(hText:node-value) no-error .
    
    IF hNoderef:NAME = "thresh" then assign hddAttributes.thresh = integer(hText:node-value) no-error .
    
    IF hNoderef:NAME = "type" then assign hddAttributes.type_ = hText:node-value no-error .
    
    IF hNoderef:NAME = "raw_value" then assign hddAttributes.raw_value = hText:node-value no-error .
           
    RUN GetChildren(hNoderef, (level + 1)).
END.

DELETE OBJECT hNoderef.
DELETE OBJECT hText.
END PROCEDURE.

function my-date returns datetime-tz (input v-str as character) :
  define variable v-year    as integer no-undo .
  define variable v-month   as integer no-undo .
  define variable v-day     as integer no-undo .
  define variable v-hour    as integer no-undo .
  define variable v-min     as integer no-undo .
  define variable v-sec     as integer no-undo .
  define variable v-tz-hour as integer no-undo .
  define variable v-tz-min  as integer no-undo .
  define variable v-sign    as character no-undo .
  define variable v-time-delta as integer no-undo .
  define variable v-dttz    as datetime-tz no-undo .
  
  assign
    v-year    = integer(substring(v-str, 1, 4))
    v-month   = integer(substring(v-str, 6, 2))
    v-day     = integer(substring(v-str, 9, 2))
    v-hour    = integer(substring(v-str, 12, 2))
    v-min     = integer(substring(v-str, 15, 2))
    v-sec     = integer(substring(v-str, 18, 2))
    v-tz-hour = integer(substring(v-str, 21, 2))
    v-tz-min  = integer(substring(v-str, 23, 2))
    v-sign    = substring(v-str, 20, 1)
    v-time-delta = (v-tz-hour) * 60 + v-tz-min
  .
  if v-sign = "-" then v-time-delta = v-time-delta * -1 .
  
  v-dttz = datetime-tz(v-month, v-day, v-year, v-hour, v-min, v-sec, 0, v-time-delta) .
  
  return v-dttz .
  
end function.

/* $Workfile: auto-hddtest.p $ end */