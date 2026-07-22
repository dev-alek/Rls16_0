/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получить всю секцию с настройками подключения к ГИС МТ

Автор: Белова Марина Михайловна
Дата создания: 25/10/2023
Author: Marina Belova
Creation date: 25/10/2023

*/

 define variable gismt-AdressPort   as character no-undo.
 define variable gismt-DopParam     as character no-undo.
 define variable gismt-GisAdress    as character no-undo.
 define variable gismt-ProxyLogin   as character no-undo.
 define variable gismt-ProxyPswd    as character no-undo.
 define variable gismt-MaxTime      as integer   no-undo.
 define variable gismt-RegKey       as character no-undo.
 define variable gismt-TimeFalStart as integer   no-undo.
 define variable gismt-WaitTime     as decimal   no-undo. 
 define variable gismt-WaitTimePlus as decimal   no-undo.   
 define variable gismt-CrashSituat  as logical   no-undo.
 define variable gismt-BanDate      as integer   no-undo.
 define variable gismt-cdnTurnOn    as logical   no-undo.
 define variable gismt-cdnAdress    as character no-undo.
 define variable gismt-cdnRepeat    as logical   no-undo.
 define variable gismt-cdnChange    as logical   no-undo.
 define variable gismt-cdnTimeUpd   as integer   no-undo.
 define variable gismt-UpdateRequest as logical   no-undo.
 define variable gismt-OflineAdress  as character no-undo.
 define variable gismt-OflineAutoriz as character no-undo.
 define variable gismt-OflineLogin   as character no-undo.
 define variable gismt-OflinePswd    as character no-undo.
 define variable gismt-OflineDate    as date      no-undo.
 
{ def/funcmet.i ConvBase64 character }
(input iString as char): 
             
  define variable vSize       as integer   no-undo.
  define variable vDataDc1    as memptr    no-undo.
  define variable vDataDc2    as memptr    no-undo.
  define variable vEnCode     as character no-undo. 
  define variable vBase64Str  as character no-undo.    
  do
  on error undo, return error return-value
  :    
    if iString = ?
    then return "".
        
    vSize  = length(iString).
    SET-SIZE(vDataDc1 ) = vSize + 1.
    SET-SIZE(vDataDc2 ) = vSize.
    
    put-string(vDataDc1, 1, vSize) = iString.
    copy-lob from vDataDc1 starting at 1 for vSize to vDataDc2 no-convert.
    
    vEnCode =  base64-encode (vDataDc2).
    
    vBase64Str = substring(vEnCode,1).

    SET-SIZE(vDataDc1)  = 0 no-error.
    SET-SIZE(vDataDc2)  = 0 no-error.
  end.
  return vBase64Str. 
end. 

{ def/funcmet.i get-thbj-attr-prop character }
(input p-obj-type as char,
 input p-obj-code as int,
 input p-upper-prop-code as char,
 input p-prop-code as char
 ):       
 
    define buffer buf_thbj-attr for ub.thbj-attr.
    define variable v-reg-code as integer no-undo. 
            
    find first buf_thbj-attr no-lock where  
               buf_thbj-attr.obj-type = p-obj-type
           and buf_thbj-attr.obj-code = p-obj-code
           and buf_thbj-attr.upper-prop-code = p-upper-prop-code
           and buf_thbj-attr.prop-code = p-prop-code
    no-error.
    if not available buf_thbj-attr and p-obj-type = {&db} then 
    do:
       /* ищем в регионе, если у БД задан регион */
       { gbl/regcode.i p-obj-type p-obj-code v-reg-code }
       if v-reg-code <> ? and v-reg-code <> 0 then do:
           find first buf_thbj-attr no-lock where  
                      buf_thbj-attr.obj-type = {&region}
                  and buf_thbj-attr.obj-code = v-reg-code
                  and buf_thbj-attr.upper-prop-code = p-upper-prop-code
                  and buf_thbj-attr.prop-code = p-prop-code
           no-error.
       end.
    end.
         
    if not available buf_thbj-attr and p-obj-type <> "" 
    then do:
       find first buf_thbj-attr no-lock where  
                  buf_thbj-attr.obj-type = ""
              and buf_thbj-attr.obj-code = 0
              and buf_thbj-attr.upper-prop-code = p-upper-prop-code
              and buf_thbj-attr.prop-code = p-prop-code
       no-error.
    end.        
             
    if avail buf_thbj-attr then do:
        case buf_thbj-attr.prop-value-type: 
            when "character"
               then return buf_thbj-attr.property-value-character.
            when "integer"
               then return string(buf_thbj-attr.property-value-integer).
            when "decimal"
               then return string(buf_thbj-attr.property-value-decimal).
            when "logical"
               then return string(buf_thbj-attr.property-value-logical).         
        end case.     
    end. 
    return "".      
end.

{ def/funcmet.i get-gismt-prop character }
(input p-obj-type as char,
 input p-obj-code as int):           
    define buffer buf_code for ub.code. 
    define buffer buf_thbj-attr for ub.thbj-attr.

    assign             
       gismt-AdressPort = get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_AdressPort})
       gismt-DopParam   = get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_dopParam})
       gismt-GisAdress  = get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_gisAdress})         
       gismt-ProxyLogin = get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_proxyLogin})        
       gismt-ProxyPswd  = get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_proxyPswd})
       gismt-MaxTime    = integer(get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_maxTime}))        
       gismt-RegKey     = get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_regKey})        
       gismt-TimeFalStart = integer(get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_timeFalStart}))        
       gismt-WaitTime    = decimal(get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_waitTime}))        
       gismt-CrashSituat = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_crashSituat}))        
       gismt-BanDate     = integer(get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_banDate}))        
       gismt-cdnTurnOn   = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_cdnTurnOn}))                   
       gismt-cdnAdress   = get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_cdnAdress})                   
       gismt-cdnRepeat   = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_cdnRepeat}))                   
       gismt-cdnChange   = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_cdnChange}))                   
       gismt-cdnTimeUpd  = integer(get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_cdnTimeUpdate}))                   
       gismt-UpdateRequest = logical(get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_UpdateRequest}))                   
       gismt-OflineAdress  = get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_OflineAdress})                   
       gismt-OflineLogin   = get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_OflineLogin})                   
       gismt-OflinePswd    = get-thbj-attr-prop(p-obj-type,p-obj-code,{&attr-gisMT},{&attr-gisMT_OflinePswd})           
       .
                     
    if gismt-OflineLogin <> "" and gismt-OflinePswd <> "" 
    then gismt-OflineAutoriz = ConvBase64(gismt-OflineLogin + ":" + gismt-OflinePswd).
    
    find first buf_code no-lock where 
               buf_code.parent eq "GisMtOffline"
           and buf_code.code   eq string(p-obj-code)
       no-error.
    if not avail buf_code then    
    find first buf_code no-lock where 
               buf_code.parent eq "GisMtOffline"
           and buf_code.code   eq "0"
       no-error.
    if avail buf_code then  gismt-OflineDate = date(buf_code.CodeValue) no-error.
    else gismt-OflineDate = today. 
  return "".
end. /* get-gismt-prop */
             



/* $Workfile$ e n d */