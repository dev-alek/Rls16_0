/* Подключение по сертификату */
{&CommentStartNoClass}
method public component-handle ConectByCertif
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function ConectByCertif return component-handle 
{utl\comment.i} */
(iThumbprint as character ):
  if mDiadocApi eq ? then return ?.
  if iThumbprint eq "" 
  then do:
     release object mDiadocConnection no-error.
     return ?.
  end.
   /*Задаем параметры подлючения к серверу*/
   mDiadocApi:ApiClientId =  getextAttr({&attr-esys-diadoc-key}). /*"api-e781e743-064b-47a7-8119-f0b1264636ab".  Ключь разработчика  */
   mDiadocApi:ServerUrl   =  getextAttr({&attr-esys-server-addr}). /*"https://diadoc-api.kontur.ru:443".*/
   define variable vSSl as character no-undo.
   vSSl =  getextAttr({&attr-esys-diadoc-SSl}).
   if vSSl ne ""
      and logical(vSSl)
   then
      mDiadocApi:VerifySslCertificate = no.
   
   if mDiadocApi:ApiClientId eq ""
      or  mDiadocApi:ServerUrl eq ""
   then do:
     message "Не задан адрес сервера или ключ разработчика для внешей системы Диадок"
     view-as alert-box.
     release object mDiadocConnection no-error.
     return ?.
  end. 
  
  /* Настройки прокси*/
  define variable VProxy as character no-undo.
   vProxy =  getextAttr({&attr-esys-proxy-addr}).
   if     vProxy ne "" 
      and vProxy ne ? 
   then do:
      mDiadocApi:ProxyMode =  "UseProxy". 
      mDiadocApi:ProxySettings:Url = vProxy.
      mDiadocApi:ProxySettings:Login    = getextAttr({&attr-esys-proxy-login}).
      mDiadocApi:ProxySettings:Password = getextAttr({&attr-esys-proxy-pswd}).
   end. 
   /*Получение списка сертификатов*/
  /* 
   vCertificates = mDiadocApi:GetPersonalCertificates(true).
   vCertSham = vCertificates:GetItem(1):Thumbprint.*/
/*Создание соединения*/
   define variable vtest as component-handle no-undo.
   vtest = mDiadocApi:TestConnection2().
   if not vtest:ConnectionSuccess
   then do:
      PutMes(vtest:ErrorText).
   end.
   else
      mDiadocConnection = mDiadocApi:CreateConnectionByCertificate(iThumbprint,"") no-error.
   if mDiadocConnection eq ?
   then
      PutErr("DiadocApi:CreateConnectionByCertificate:").
   release object vtest. 
   return mDiadocConnection.
end.

/* Подключение по сертификату */
{&CommentStartNoClass}
method public component-handle ConectByLogin
{utl\comment.i} "Изврат для eclipse" */ {&CommentStartClass}
function ConectByLogin return component-handle 
{utl\comment.i} */
():
   define variable vSSl as character no-undo.
   
   if mDiadocApi eq ? then return ?.
   /*Задаем параметры подлючения к серверу*/
   mDiadocApi:ApiClientId = getextAttr({&attr-esys-diadoc-key}). /*"api-e781e743-064b-47a7-8119-f0b1264636ab".  Ключь разработчика  */
   mDiadocApi:ServerUrl   = getextAttr({&attr-esys-server-addr}).
   /*Получение списка сертификатов*/
   if mDiadocApi:ApiClientId eq ""
      or  mDiadocApi:ServerUrl eq ""
   then do:
     PutMes( "Error Не задан адрес сервера или ключ разработчика для внешей системы Диадок").
     
     release object mDiadocConnection no-error.
     return ?.
  end. 
  vSSl =  getextAttr({&attr-esys-diadoc-SSl}).
  if vSSl ne ""
     and logical(vSSl)
  then
      mDiadocApi:VerifySslCertificate = no.
   
  /* Настройки прокси*/
  define variable VProxy as character no-undo.
   vProxy =  getextAttr({&attr-esys-proxy-addr}).
   if     vProxy ne "" 
      and vProxy ne ? 
   then do:
      mDiadocApi:ProxyMode =  "UseProxy". 
      mDiadocApi:ProxySettings:Url = vProxy.
      mDiadocApi:ProxySettings:Login    = getextAttr({&attr-esys-proxy-login}).
      mDiadocApi:ProxySettings:Password = getextAttr({&attr-esys-proxy-pswd}).
   end. 
   mDiadocConnection = mDiadocAPI:CreateConnectionByLogin(getextAttr({&attr-esys-diadoc-user}),getextAttr({&attr-esys-diadoc-pwd})) no-error. /*"sibintek-pnpo@yandex.ru","987654321Aa"*/
   define variable vi as integer no-undo.
   if mDiadocConnection eq ?
   then
      PutErr("DiadocAPI:CreateConnectionByLogin").
   return mDiadocConnection.
end.    
