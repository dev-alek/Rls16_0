block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Марина Белова
Дата создания: 18.12.2025
Author:  Marina Belova
Creation date: 18.12.2025

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "Передача настроек для проверки КМ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
&Scoped-define source "1"
define variable mdb-num     as integer   no-undo.
define variable mObjType    as character no-undo.
define variable mObjCode    as integer   no-undo.
define variable mPostType   as character no-undo.
define variable mCashNum    as integer   no-undo.
define variable mDeviceKind as integer   no-undo. /* код типа кассы */
define variable mSend       as logical   no-undo. /* есть ли что посылать */

{ gbl/cd-attr.i}
{ str/def-thbjattr-list.i "shared" }  
{ cmp/library.i class}
{ ibs/th/skt/controlledclients/gismtprop.i def}

function get-code-typemark return character
    (p-typemark as character):
        def buffer buf_code for ub.code.
   find first buf_code where 
            buf_code.parent = "MarkType"
        and buf_code.CodeValue = p-typemark
       no-lock no-error.
   if avail buf_code then return buf_code.code.
   else return "".    
end.

function get-list-code-typemark return character
    (p-list-typemark as character):
   def var vCount as int no-undo.
   def var vListCode as char no-undo.
   def var vCode as char no-undo.
   do vCount = 1 to num-entries(p-list-typemark):
      vCode = get-code-typemark(entry(vCount,p-list-typemark)).      
      if vCode <> "" then vListCode = substitute("&1,&2",vListCode,int(vCode)).
   end.
   vListCode = substring(vListCode,2). 
   return vListCode.
end.

procedure putc :
   define input parameter iSAXWriter as handle no-undo .
   define input parameter i-action   as character  no-undo .
   define input parameter p-value    as character  no-undo .
   define output parameter oSend      as logical    no-undo.
   
   define variable vTypesForKass as character no-undo.
   define variable vTimeDate as character no-undo.
   
   define buffer buf_code for ub.code.
   define buffer buf_thbj-attr for ub.thbj-attr.
   DEFINE BUFFER buf_sys-ctrl FOR ub.sys-ctrl .
   
   DEFINE VARIABLE vRetProp AS CHARACTER NO-UNDO.
   DEFINE VARIABLE vCdnAdr AS CHARACTER NO-UNDO.
   define variable vCount        as integer   no-undo.   
   define variable vAll as logical no-undo. /* признак, выгружать ли все настройки */
   
   define variable vCheckBlock    as character no-undo.        
   define variable vCheckDate     as character no-undo.                                                
   define variable vCheckMRC      as character no-undo.       
   define variable vCheckOwner    as character no-undo. 
   define variable vCheckStatusKM as character no-undo. 
   define variable vCheckTracking as character no-undo.
   define variable vMACC_Timeout  as decimal   no-undo.
   define variable vResp_TH_requiredr as integer no-undo.
   define variable vMACC_IP        as character no-undo.
   define variable vLmCHzPort      as character no-undo.
   define variable vTH_IP          as character no-undo.
   define variable vTH_Port        as character no-undo.  
   define variable vAddTimeoutPIoT as decimal   no-undo.  
   define variable vMaxApiToken    as character no-undo.
   define variable vAgeConfirm     as integer   no-undo.
   define variable v-reg-code      as integer   no-undo.
   
   assign
      vAll = yes   
      vMACC_IP = ""
      vTH_IP = ""
      vTH_Port = ""
      vLmCHzPort = ""
      vMaxApiToken = ""
      mSend = no.
   .    
   { gbl/regcode.i {&db} mdb-num v-reg-code }
   
   thlist: 
   for each thbjattr-list :
       /* есть список для выгрузки, выгружаем не все настройки, а только которые есть в списке */
     if vAll = yes then vAll = no.
       /* пропускаем региональную настройку, если есть настройка по БД */ 
       if    thbjattr-list.obj-type = {&region}
         and (thbjattr-list.obj-code <> v-reg-code 
              or can-find(first buf_thbj-attr no-lock where 
                                buf_thbj-attr.obj-type = {&db}
                            and buf_thbj-attr.obj-code = mdb-num 
                            and buf_thbj-attr.upper-prop-code = thbjattr-list.upper-prop-code
                            and buf_thbj-attr.prop-code = thbjattr-list.prop-code)  )
          then next thlist.
       /* пропускаем глобальную настройку, если есть региональная настройка (то, что нет по БД, уже проверили раньше) */
       if thbjattr-list.upper-prop-code = {&attr-gisMT} 
          and thbjattr-list.obj-type = ""
          and can-find(first buf_thbj-attr no-lock where 
                             buf_thbj-attr.obj-type = {&region}
                         and buf_thbj-attr.obj-code = v-reg-code
                         and buf_thbj-attr.upper-prop-code = thbjattr-list.upper-prop-code
                         and buf_thbj-attr.prop-code = thbjattr-list.prop-code)  
          then next thlist.  
     find first buf_thbj-attr no-lock where  
               buf_thbj-attr.obj-type = thbjattr-list.obj-type
           and buf_thbj-attr.obj-code = thbjattr-list.obj-code
           and buf_thbj-attr.upper-prop-code = thbjattr-list.upper-prop-code
           and buf_thbj-attr.prop-code = thbjattr-list.prop-code
           no-error.
     if not avail buf_thbj-attr then next thlist.

     case buf_thbj-attr.prop-code:              
        when {&attr-marking_checkBlock} then do:        
           run put-xml-data(iSAXWriter,"GS1","checkBlock",get-list-code-typemark(buf_thbj-attr.property-value-character),"Типы маркированной продукции для проверки блокировок контролирующих органов").      
        end.
        when {&attr-marking_checkDate} then do:                                                  
           run put-xml-data(iSAXWriter,"GS1","checkDate",get-list-code-typemark(buf_thbj-attr.property-value-character),"Типы маркированной продукции для проверки срока годности").      
        end.
        when {&attr-marking_checkMRC} then do:           
           run put-xml-data(iSAXWriter,"GS1","checkMRC",get-list-code-typemark(buf_thbj-attr.property-value-character),"Типы маркированной продукции для проверки МРЦ").      
        end.
        when {&attr-marking_checkOwner} then do:      
           run put-xml-data(iSAXWriter,"GS1","checkOwner",get-list-code-typemark(buf_thbj-attr.property-value-character),"Типы маркированной продукции для проверки владельца").
        end.
        when {&attr-marking_checkStatusKM} then do:      
           run put-xml-data(iSAXWriter,"GS1","checkStatusKM",get-list-code-typemark(buf_thbj-attr.property-value-character),"Типы маркированной продукции для проверки статуса КМ").        
        end.
        when {&attr-marking_checkTracking} then do:       
           run put-xml-data(iSAXWriter,"GS1","checkTracking",get-list-code-typemark(buf_thbj-attr.property-value-character),"Типы маркированной продукции для проверки флага прослеживаемости").  
        end.
        when {&attr-gisMT_maxTime} then do:           
           run put-xml-data(iSAXWriter,"GS1","Max_allowed_time",string(buf_thbj-attr.property-value-integer),"Макс. допустимое время разрешения продажи при сбое онлайн проверки (часы)"). 
        end.
        when {&attr-gisMT_timeFalStart} then do:           
           run put-xml-data(iSAXWriter,"GS1","Failure_time",string(buf_thbj-attr.property-value-integer),"Время с момента сбоя до начала уведомления персонала (часы)"). 
        end.
        when {&attr-gisMT_crashSituat} then do:           
           run put-xml-data(iSAXWriter,"GS1","emergencyMode",(if buf_thbj-attr.property-value-logical then "1" else "0"),"Признак аварийной ситуации в ГИС МТ").     
        end.
        when {&attr-gisMT_banDate} then do:           
           run put-xml-data(iSAXWriter,"GS1","Before_Expiration",string(buf_thbj-attr.property-value-integer),"Опережение срабатывания запрета по сроку годности в минутах"). 
        end.             
        when {&attr-gisMT_adressPort} then do:            
            run put-xml-data(iSAXWriter,"GS1","Proxy_IP",buf_thbj-attr.property-value-character,"Адрес и порт прокси"). 
        end.
        when {&attr-gisMT_proxyLogin} then do:            
           run put-xml-data(iSAXWriter,"GS1","Proxy_Login",buf_thbj-attr.property-value-character,"Логин для подключения к прокси-серверу"). 
        end.
        when {&attr-gisMT_proxyPswd} then do:            
            run put-xml-data(iSAXWriter,"GS1","Proxy_Pass",buf_thbj-attr.property-value-character,"Пароль для подключения к прокси-серверу"). 
        end.                                 
        when {&attr-gisMT_waitTime} then do:            
            run put-xml-data(iSAXWriter,"GS1","MACC_TimeoutGISMT",string(buf_thbj-attr.property-value-decimal),"Длительность ожидания ответа ТС ПИоТ"). 
        end.
        when {&attr-gisMT_MACC_Timeout} then do:                                     
           if buf_thbj-attr.property-value-decimal <> 0 then 
              run put-xml-data(iSAXWriter,"GS1","MACC_Timeout",string(buf_thbj-attr.property-value-decimal),"Длительность ожидания ответа ТН"). 
        end.
        when {&attr-gisMT_OflineLogin} then do:            
            run put-xml-data(iSAXWriter,"GS1","LmCHzLogin",buf_thbj-attr.property-value-character,"Логин для доступа ЛМ ЧЗ"). 
         END.
        when {&attr-gisMT_OflinePswd} then do:            
            run put-xml-data(iSAXWriter,"GS1","LmCHzPass",buf_thbj-attr.property-value-character,"Пароль для доступа ЛМ ЧЗ"). 
        end.        
        when {&attr-gisMT_Resp_TH_required} then do:            
            run put-xml-data(iSAXWriter,"GS1","Resp_TH_required",string(buf_thbj-attr.property-value-integer),"Обязательность получения результатов проверки КМ в ТН"). 
        end.
        when {&attr-gisMT_TH_IP} then vTH_IP = buf_thbj-attr.property-value-character.                
        when {&attr-gisMT_TH_Port} then vTH_Port = buf_thbj-attr.property-value-character.
        when {&attr-gisMT_LmCHzPort} then vLmCHzPort = buf_thbj-attr.property-value-character.
        when {&attr-gisMT_AddTimeoutPIoT} then do:
             run put-xml-data(iSAXWriter,"GS1","MACC_additionalTimeoutPIoT",string(buf_thbj-attr.property-value-decimal),"Длительность обработки ответа ГИС МТ в ТС ПИоТ").
        end.    
        when {&attr-gisMT_MaxApiToken} then do:                     
           run put-xml-data(iSAXWriter,"GS1","MaxApiToken",buf_thbj-attr.property-value-character,"Токен авторизации MAX").                      
        end.
        when {&attr-gisMT_AgeConfirm} then do:            
            run put-xml-data(iSAXWriter,"UiSettings","NeedUserSimpleAgeConfirm",buf_thbj-attr.property-value-integer,"Проверка возраста при продаже НП").            
        end.    
     end case. 
         
   end.   
   if not vAll then do:
       if vTH_IP = ? then vTH_IP = "".
       if vTH_Port = ? then vTH_Port = "".
       /* возможно изменили только одно из двух полей, надо тогда вычислить MACC_IP */
       if vTH_IP = "" and vTH_Port <> "" then vTH_IP = get-thbj-attr-prop({&db},mdb-num,{&attr-gisMT},{&attr-gisMT_TH_IP}).
       if vTH_IP <> "" and vTH_Port = "" then vTH_Port = get-thbj-attr-prop({&db},mdb-num,{&attr-gisMT},{&attr-gisMT_TH_Port}).
       if vTH_IP <> "" and vTH_Port <> "" then vMACC_IP = substitute("&1:&2",vTH_IP,vTH_Port).       
       if vMACC_IP <> "" then
         run put-xml-data(iSAXWriter,"GS1","MACC_IP",vMACC_IP,"Адрес и порт для отправки запроса проверки марки в ТН").
       /* если MACC_IP не меняли, но поменяли ЛМЧЗ порт, то что бы понять, надо ли его посылать на кассу, вычисляем MACC_IP */  
       IF vTH_IP = "" and vTH_Port = "" and vLmCHzPort <> "" 
       then do:
           vTH_IP = get-thbj-attr-prop({&db},mdb-num,{&attr-gisMT},{&attr-gisMT_TH_IP}).
           vTH_Port = get-thbj-attr-prop({&db},mdb-num,{&attr-gisMT},{&attr-gisMT_TH_Port}).
           if vTH_IP <> "" and vTH_Port <> "" then vMACC_IP = substitute("&1:&2",vTH_IP,vTH_Port).                                    
       end.       
       if vMACC_IP <> "" and vLmCHzPort <> "" then
         run put-xml-data(iSAXWriter,"GS1","LmCHzPort",vLmCHzPort,"Порт для отправки запроса проверки марки в ЛМ ЧЗ ").  
   end.    
   /* временной таблице со списком нет - выгружаем все */
   else do:           
      assign
        vCheckBlock     = get-list-code-typemark(get-thbj-attr-prop(mObjType,mObjCode,{&attr-marking},{&attr-marking_checkBlock}))        
        vCheckDate      = get-list-code-typemark(get-thbj-attr-prop(mObjType,mObjCode,{&attr-marking},{&attr-marking_checkDate}))                                            
        vCheckMRC       = get-list-code-typemark(get-thbj-attr-prop(mObjType,mObjCode,{&attr-marking},{&attr-marking_checkMRC}))   
        vCheckOwner     = get-list-code-typemark(get-thbj-attr-prop(mObjType,mObjCode,{&attr-marking},{&attr-marking_checkOwner}))
        vCheckStatusKM  = get-list-code-typemark(get-thbj-attr-prop(mObjType,mObjCode,{&attr-marking},{&attr-marking_checkStatusKM}))
        vCheckTracking  = get-list-code-typemark(get-thbj-attr-prop(mObjType,mObjCode,{&attr-marking},{&attr-marking_checkTracking}))                               
        .                                            
      vRetProp = get-gismt-prop ({&db}, mdb-num) NO-ERROR.
      assign
        vMACC_TimeOut   = DEC(get-thbj-attr-prop({&db},mdb-num,{&attr-gisMT},{&attr-gisMT_MACC_Timeout}))
        vResp_TH_requiredr = INT(get-thbj-attr-prop({&db},mdb-num,{&attr-gisMT},{&attr-gisMT_Resp_TH_required}))
        vTH_IP = get-thbj-attr-prop({&db},mdb-num,{&attr-gisMT},{&attr-gisMT_TH_IP})
        vTH_Port = get-thbj-attr-prop({&db},mdb-num,{&attr-gisMT},{&attr-gisMT_TH_Port})
        vLmCHzPort = get-thbj-attr-prop({&db},mdb-num,{&attr-gisMT},{&attr-gisMT_LmCHzPort})        
        vAddTimeoutPIoT = DEC(get-thbj-attr-prop({&db},mdb-num,{&attr-gisMT},{&attr-gisMT_AddTimeoutPIoT}))    
        vMaxApiToken = get-thbj-attr-prop({&db},mdb-num,{&attr-gisMT},{&attr-gisMT_MaxApiToken})
        vAgeConfirm = INT(get-thbj-attr-prop({&db},mdb-num,{&attr-gisMT},{&attr-gisMT_AgeConfirm}))
        no-error.  
      if vTH_IP = ? then vTH_IP = "".
      if vTH_Port = ? then vTH_Port = "".
      if vLmCHzPort = ? then vLmCHzPort = "".
      if vMaxApiToken = ? then vMaxApiToken = "".
             
      if vTH_IP <> "" and vTH_Port <> "" then vMACC_IP = substitute("&1:&2",vTH_IP,vTH_Port).
      if vCheckBlock <> ? then
      run put-xml-data(iSAXWriter,"GS1","checkBlock",vCheckBlock,"Типы маркированной продукции для проверки блокировок контролирующих органов").
      if vCheckDate <> ? then
      run put-xml-data(iSAXWriter,"GS1","checkDate",vCheckDate,"Типы маркированной продукции для проверки срока годности").
      if vCheckMRC <> ? then
      run put-xml-data(iSAXWriter,"GS1","checkMRC",vCheckMRC,"Типы маркированной продукции для проверки МРЦ").
      if vCheckOwner <> ? then
      run put-xml-data(iSAXWriter,"GS1","checkOwner",vCheckOwner,"Типы маркированной продукции для проверки владельца").
      if vCheckStatusKM <> ? then
      run put-xml-data(iSAXWriter,"GS1","checkStatusKM",vCheckStatusKM,"Типы маркированной продукции для проверки статуса КМ").
      if vCheckTracking <> ? then 
      run put-xml-data(iSAXWriter,"GS1","checkTracking",vCheckTracking,"Типы маркированной продукции для проверки флага прослеживаемости").
      if vMACC_IP <> "" and vMACC_IP <> ? then
         run put-xml-data(iSAXWriter,"GS1","MACC_IP",vMACC_IP,"Адрес и порт для отправки запроса проверки марки в ТН").
      if gismt-OflineLogin <> ? then   
      run put-xml-data(iSAXWriter,"GS1","LmCHzLogin",gismt-OflineLogin,"Логин для доступа ЛМ ЧЗ").
      if gismt-OflinePswd <> ? then 
      run put-xml-data(iSAXWriter,"GS1","LmCHzPass",gismt-OflinePswd,"Пароль для доступа ЛМ ЧЗ").
      if gismt-AdressPort <> ? then 
      run put-xml-data(iSAXWriter,"GS1","Proxy_IP",gismt-AdressPort,"Адрес и порт прокси").
      if gismt-ProxyLogin <> ? then
      run put-xml-data(iSAXWriter,"GS1","Proxy_Login",gismt-ProxyLogin,"Логин для подключения к прокси-серверу").
      if gismt-ProxyPswd <> ? then 
      run put-xml-data(iSAXWriter,"GS1","Proxy_Pass",gismt-ProxyPswd,"Пароль для подключения к прокси-серверу").  
      if vMACC_IP <> "" and vLmCHzPort <> "" 
         and vMACC_IP <> ? and vLmCHzPort <> ? then
         run put-xml-data(iSAXWriter,"GS1","LmCHzPort",vLmCHzPort,"Порт для отправки запроса проверки марки в ЛМ ЧЗ ").
      if gismt-WaitTime <> ? then  
      run put-xml-data(iSAXWriter,"GS1","MACC_TimeoutGISMT",string(gismt-WaitTime),"Длительность ожидания на стороне ТС ПИоТ ответа от ГИС МТ").
      if vAddTimeoutPIoT <> ? then
      run put-xml-data(iSAXWriter,"GS1","MACC_additionalTimeoutPIoT",string(vAddTimeoutPIoT),"Длительность обработки ответа ГИС МТ в ТС ПИоТ").
      if gismt-BanDate <> ? then      
      run put-xml-data(iSAXWriter,"GS1","Before_Expiration",string(gismt-BanDate),"Опережение срабатывания запрета по сроку годности в минутах").
      if gismt-MaxTime <> ? then  
      run put-xml-data(iSAXWriter,"GS1","Max_allowed_time",string(gismt-MaxTime),"Макс. допустимое время разрешения продажи при сбое онлайн проверки (часы)").
      if gismt-TimeFalStart <> ? then 
      run put-xml-data(iSAXWriter,"GS1","Failure_time",string(gismt-TimeFalStart),"Время с момента сбоя до начала уведомления персонала (часы)").
      if gismt-CrashSituat <> ? then       
      run put-xml-data(iSAXWriter,"GS1","emergencyMode",(if gismt-CrashSituat then "1" else "0"),"Признак аварийной ситуации в ГИС МТ").                    
      if vMACC_Timeout <> 0 and vMACC_Timeout <> ? then 
         run put-xml-data(iSAXWriter,"GS1","MACC_Timeout",string(vMACC_Timeout),"Длительность ожидания ответа ТН").
      if vResp_TH_requiredr <> ? then   
      run put-xml-data(iSAXWriter,"GS1","Resp_TH_required",string(vResp_TH_requiredr),"Обязательность получения результатов проверки КМ в ТН").      
      run put-xml-data(iSAXWriter,"GS1","MaxApiToken",vMaxApiToken,"Токен авторизации MAX").   
      if vAgeConfirm <> ? then                   
      run put-xml-data(iSAXWriter,"UiSettings","NeedUserSimpleAgeConfirm",string(vAgeConfirm),"Проверка возраста при продаже НП").   
   end.                                   
   
   for each thbjattr-list:
       delete thbjattr-list.
   end.    
   oSend = mSend.
end procedure.

procedure put-xml-data:
    define input parameter iSAXWriter  as handle    no-undo .
    define input parameter p-group     as character no-undo.
    define input parameter p-prop-code as character no-undo.
    define input parameter p-value     as character no-undo.
    define input parameter p-discr     as character no-undo.    
       
    define buffer buf_code for ub.code.
    
    find first buf_code no-lock where
               buf_code.parent = substitute("cash-param&1&2&1&3&1&4",{&delim-par},mDeviceKind,{&source},p-group)
           and buf_code.code  = p-prop-code
      no-error.              
    if available buf_code       
    then do:        
        iSAXWriter:start-element("Param") .
        iSAXWriter:insert-attribute("ctrl", "ADD").
        iSAXWriter:insert-attribute("group", p-group).
        iSAXWriter:insert-attribute("key", p-prop-code).
        iSAXWriter:write-data-element("ParamValue" , p-value ) .
        iSAXWriter:write-data-element("ParamDesc" , p-discr).
        iSAXWriter:end-element("Param" ). 
        mSend = yes.
    end.
end procedure.       


procedure set-cash-info:
   define input         parameter iDB-num        as integer     no-undo.
   define input         parameter iObjType       as character   no-undo.
   define input         parameter iObjCode       as integer     no-undo.
   define input         parameter iPostType      as character   no-undo.
   define input         parameter iCashNum       as integer     no-undo.
   
   define buffer buf_cash-desk-attr for ub.cash-desk-attr .
   
   assign
      mDB-num       = iDB-num
      mObjType      = iObjType
      mObjCode      = iObjCode
      mPostType     = iPostType
      mCashNum      = iCashNum
   .
   
   /* определяем тип кассы */   
   find first buf_cash-desk-attr no-lock
       where buf_cash-desk-attr.db-num   = mDB-num 
         and buf_cash-desk-attr.obj-code = mObjCode         
         and buf_cash-desk-attr.pos-type = mPostType
         and buf_cash-desk-attr.cash-num = mCashNum
         and buf_cash-desk-attr.upper-attr-code = mPostType + "_operative":U
         and buf_cash-desk-attr.attr-code       = "device-kind":U no-error .
   if available buf_cash-desk-attr then
       mDeviceKind = buf_cash-desk-attr.attr-value-integer .
   else 
      mDeviceKind = 0 .              
end.

procedure get-cash-types:
   define output parameter otypes as character no-undo init "{&bef-cd-type-IBM-XML}".
end.

procedure get-root-teg:
   define output parameter otypes as character no-undo init "config".
end.

procedure get-xml-encoding:
   define output parameter oEncoding as character no-undo init "UTF-8".
end.

procedure get-tag-from:
   define output parameter oValue as character no-undo init "empty".
end.

procedure get-tag-to:
   define output parameter oValue as character no-undo init "*".
end.

/* Invoked to report a warning. */
procedure Warning:
  define input parameter ErrMessage as character no-undo.
  message "The following WARNING was generated:~n" + ErrMessage
       view-as alert-box info buttons ok.
end procedure.
    
/* Invoked to report an error encountered by the parser while parsing the XML document. */
procedure Error:
  define input parameter ErrMessage as character no-undo.
  message "The following NONFATAL ERROR was generated:~n" + ErrMessage
       view-as alert-box info buttons ok.
end procedure.

/* Invoked to report a fatal error. */
procedure FatalError:
  define input parameter ErrMessage as character no-undo.
  return error "The following FATAL ERROR was generated:~n" + ErrMessage.
end procedure.

 