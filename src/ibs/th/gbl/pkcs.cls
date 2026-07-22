 
 /*------------------------------------------------------------------------
    File        : pkcs
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : smolotkov
    Created     : Thu May 31 10:07:34 MSK 2018
    Notes       : проверка соответствия сертификата отправителю выполняется по sender-id;
                  для 1с sender-id жестко равен "00000"
    Test case   : Создание подписи, проверка подписи, проверка срока действия на сертификате
 
1. Создайте сертификат с истекающим сроком действия:
   если сегодня 17-ое число - то сертификат должен действовать до 18-ого
2. Выберите пакет для приёма из 1с
3. Создайте для него файл с электронной подписью
4. После наступления 18-ого числа проверьте электронную подпись

&scoped-define pack-path D:\wrk16_0_ub0\oxml\exch\ES00002-038
&scoped-define pack-name 00000_00002_138_01102018062359
define variable v-pack-name as character initial "{&pack-path}\{&pack-name}.xml".
define variable v-sign-name as character initial "{&pack-path}\{&pack-name}.p7s".
 
define variable v-data as memptr no-undo .
define variable v-sign as memptr no-undo .
define variable v-pkcs as class ibs.th.gbl.pkcs no-undo .

define variable v-err-msg      as character no-undo .
define variable v-cert-subject as character no-undo .
do on error undo, throw:

  COPY-LOB FROM FILE v-pack-name TO OBJECT v-data NO-CONVERT.
  v-pkcs = new ibs.th.gbl.pkcs(true).

// 3.
//  v-sign = v-pkcs:computeSign(v-data, "oldOn18Sep", "MyCA").
//  v-sign = v-pkcs:computeSign(v-data, "CN=ERP, OU=00000", "ERPRoot").
  v-sign = v-pkcs:computeSign(v-data, "00000", "ERPRoot").
  COPY-LOB FROM OBJECT v-sign TO FILE v-sign-name NO-CONVERT.

// 4.
  set-size(v-sign) = 0.
  COPY-LOB FROM FILE v-sign-name TO OBJECT v-sign NO-CONVERT .
  v-pkcs:putSign(v-sign) .
  v-cert-subject = v-pkcs:getCertSubject() .
  message "sert-subj: " "[" + v-cert-subject + "]" view-as alert-box .

  v-pkcs:verifySign(v-data) .

  v-err-msg = "" .
  catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
      v-err-msg = exAppErrors:GetMessage(1) . 
      if v-err-msg > "" then . else v-err-msg = "AppError в модуле" .
    end .
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) . 
    if v-err-msg > "" then . else v-err-msg = "ProError в модуле" .
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле  " + exAnyErrors:GetMessage(1).
  end catch .
  finally: 
    set-size(v-sign) = 0.
    set-size(v-data) = 0.
    if valid-object(v-pkcs) then delete object v-pkcs.
                   
    if v-err-msg > "" then message v-err-msg view-as alert-box.
  end finally.
end .

  ----------------------------------------------------------------------*/
block-level on error undo, throw.

class ibs.th.gbl.pkcs: 

  define private variable c-oid-data        as class System.Security.Cryptography.Oid no-undo .
  // define private variable c-oid-hashed-data as class System.Security.Cryptography.Oid no-undo .
  define private variable m-x509-store      as class System.Security.Cryptography.X509Certificates.X509Store no-undo .
  define private variable m-debug-enabled   as logical no-undo .
  define private stream f-log .

  /* поле с конверированием из memptr и Byte[] */
  define variable m-byte-content as class "System.Byte[]" no-undo . // данные 
  define variable m-hash-content as class "System.Byte[]" no-undo . // хэш от данных
  define variable m-encoded-sign as class "System.Byte[]" no-undo . // закодированная подпись от данных

  /* сертификаты, которыми был подписан входящий пакет. Достаются из подписи пакета m-encoded-sign */
  define variable m-sign-certs   as class System.Security.Cryptography.X509Certificates.X509Certificate2Collection no-undo .
    
constructor public pkcs () :
  this-object(false) .
end constructor .
constructor public pkcs (input p-debug-enabled as logical) :
  
  // https://docs.microsoft.com/ru-ru/dotnet/api/system.security.cryptography.pkcs.contentinfo.-ctor?view=netframework-4.7.2#System_Security_Cryptography_Pkcs_ContentInfo__ctor_System_Security_Cryptography_Oid_System_Byte___
  // https://msdn.microsoft.com/en-us/library/2cfes5ff(v=vs.110).aspx
  c-oid-data        = new System.Security.Cryptography.Oid ("1.2.840.113549.1.7.1") . // data
  // The digestedData and encryptedData content types, which appear in the CMS/PKCS #7 standards document,
  // are not content types that can be produced by this implementation.
  // ... и 1с-ники тоже указывают data вместо hashedData
  // c-oid-hashed-data = new System.Security.Cryptography.Oid ("1.2.840.113549.1.7.5") . // hashedData
  
  m-debug-enabled = p-debug-enabled .
  if p-debug-enabled then do :
    define variable v-log-file-name as character no-undo .
    v-log-file-name = substitute("pkcs_&1.log", now).
    v-log-file-name = replace(v-log-file-name, "/", "").
    v-log-file-name = replace(v-log-file-name, ":", "").
    v-log-file-name = replace(v-log-file-name, " ", "_").
    v-log-file-name = replace(v-log-file-name, "+", "_").
    output stream f-log to value (v-log-file-name) .
  end .
end constructor .

destructor public pkcs ( ) :
  if m-debug-enabled then output stream f-log close .
  if valid-object(m-x509-store) then do :
    m-x509-store:Dispose() . // Starting with the .NET 4.6 you should dispose of it either directly or indirectly
    delete object m-x509-store.
  end .
  if valid-object(m-sign-certs)   then delete object m-sign-certs.
  if valid-object(m-encoded-sign) then delete object m-encoded-sign.
  if valid-object(m-hash-content) then delete object m-hash-content.
  if valid-object(m-byte-content) then delete object m-byte-content.
  if valid-object(c-oid-data) then delete object c-oid-data .
end destructor .


method private System.Security.Cryptography.X509Certificates.X509Certificate2 getMyCert (
  input p-my-name as character
, input p-issuer  as character
, input p-cert-repository as integer
) :
define variable v-my-cert      as class System.Security.Cryptography.X509Certificates.X509Certificate2 no-undo .
define variable v-certificates as class System.Security.Cryptography.X509Certificates.X509Certificate2Collection no-undo .
define variable v-cucollection as class System.Security.Cryptography.X509Certificates.X509Certificate2Collection no-undo .
define variable v-mycollection as class System.Security.Cryptography.X509Certificates.X509Certificate2Collection no-undo .
define variable v-ofcollection as class System.Security.Cryptography.X509Certificates.X509Certificate2Collection no-undo .
define variable i       as integer no-undo .
define variable v-cert1 as class System.Security.Cryptography.X509Certificates.X509Certificate2 no-undo .
define variable v-subj1 as character no-undo .


  v-my-cert = ? .
  do on error undo, throw:
    
    if not valid-object(m-x509-store) then do :
      // https://docs.microsoft.com/ru-ru/dotnet/api/system.security.cryptography.x509certificates.storename?view=netframework-4.7.2    
      // StoreName:My   = 5 - The X.509 certificate store for personal certificates.
      // StoreName:Root = 6 - The X.509 certificate store for trusted root certificate authorities (CAs).
      // https://docs.microsoft.com/ru-ru/dotnet/api/system.security.cryptography.x509certificates.storelocation?view=netframework-4.7.1
      // StoreLocation:CurrentUser = 1 - The X.509 certificate store used by the current user.
      case p-cert-repository :
        when 0
        then do :
          m-x509-store   = new System.Security.Cryptography.X509Certificates.X509Store
          ( System.Security.Cryptography.X509Certificates.StoreName:My,
            System.Security.Cryptography.X509Certificates.StoreLocation:CurrentUser ) .
        end .
        when 1
        then do :
          m-x509-store   = new System.Security.Cryptography.X509Certificates.X509Store
          ( System.Security.Cryptography.X509Certificates.StoreName:My,
            System.Security.Cryptography.X509Certificates.StoreLocation:LocalMachine ) .
        end .
      end case .
    end .
        
    m-x509-store:Open
      ( System.Security.Cryptography.X509Certificates.OpenFlags:ReadOnly or
        System.Security.Cryptography.X509Certificates.OpenFlags:OpenExistingOnly ) .
    v-certificates = m-x509-store:Certificates .
    if v-certificates:Count > 0 then . else
      undo, throw new Progress.Lang.AppError("Отсутствуют сертификаты для подписи пакета") .
    
    // https://docs.microsoft.com/ru-ru/dotnet/api/system.security.cryptography.x509certificates.x509findtype?view=netframework-4.7.1
    // X509FindType:FindByTimeValid   = 6 - The findValue parameter must be a DateTime value in local time. You can use Now to find all the currently valid certificates.
    // X509FindType:FindBySubjectName = 1 - the subject name of the certificate.
    // X509FindType:FindByIssuerName  = 3 - the issuer name of the certificate.

    v-cucollection = v-certificates:Find
      ( System.Security.Cryptography.X509Certificates.X509FindType:FindByTimeValid,
        System.DateTime:Now, true ) .
    // If using a certificate with a trusted root you do not need to FindByTimeValid
    // По FindByTimeValid ищет только среди сертификатов, имеющих путь к доверенному корневому сертификату
    // validOnly (Boolean): true to allow only valid certificates to be returned from the search; otherwise, false.
    if v-cucollection:Count > 0 then do :
      if m-debug-enabled then do :
        put stream f-log unformatted
          "getMyCert:FindByTimeValid" skip
          substitute("действующих сертификатов: &1", v-cucollection:Count) skip
        .
        do i = 0 to v-cucollection:Count - 1 :
          v-cert1 = v-cucollection[i] .
          v-subj1 = v-cert1:Subject .
          put stream f-log unformatted
            substitute(  "subject[&1] = [&2] (my-subj-name = [&3], &4",
                         i, v-subj1, p-my-name, if (v-subj1 = p-my-name) then "equal" else "not equal"  ) skip
          .
        end .
        put stream f-log unformatted skip(0) .
      end .
    end . else
      undo, throw new Progress.Lang.AppError("Отсутствуют действующие сертификаты для подписи пакета") .

    v-mycollection = v-cucollection:Find
      ( System.Security.Cryptography.X509Certificates.X509FindType:FindBySubjectName,
//      ( System.Security.Cryptography.X509Certificates.X509FindType:FindBySubjectDistinguishedName, - более строгий, если потребуется CN,OU
        p-my-name, true ) .
    if v-mycollection:Count > 0 then do :
      if m-debug-enabled then do :
        put stream f-log unformatted
          "getMyCert:FindBySubjectName" skip
          substitute("действующих сертификатов субъекта[&1]: &2", p-my-name, v-mycollection:Count) skip
        .
        do i = 0 to v-mycollection:Count - 1 :
          v-cert1 = v-mycollection[i] .
          v-subj1 = v-cert1:Subject .
          put stream f-log unformatted
            substitute(  "subject[&1] = [&2] (my-subj-name = [&3], &4",
                         i, v-subj1, p-my-name, if (v-subj1 = p-my-name) then "equal" else "not equal"  ) skip
          .
        end .
        put stream f-log unformatted skip(0) .
      end .
    end . else
      undo, throw new Progress.Lang.AppError(substitute("Отсутствуют действующие сертификаты выданные субъекту [&1] для подписи пакета", p-my-name)) .

    v-ofcollection = v-mycollection:Find
      ( System.Security.Cryptography.X509Certificates.X509FindType:FindByIssuerName,
        p-issuer, true ) .
    if v-ofcollection:Count > 0 then do:
      if m-debug-enabled then do :
        put stream f-log unformatted
          "getMyCert:FindByIssuerName" skip
          substitute("действующих сертификатов субъекта[&1] издателя[&2]: &3", p-my-name, p-issuer, v-ofcollection:Count) skip
        .
      end .
      /* Ручная доводка: выбрать для субъекта "cert_azs" его сертификат
subject[0] = [CN=cert_azs_alt2, OU=6767038]
subject[1] = [CN=cert_azs, OU=6767038]
      */
      do i = 0 to v-ofcollection:Count - 1 :
        v-cert1 = v-ofcollection[i] .
        v-subj1 = v-cert1:Subject .
        v-subj1 = replace(v-subj1, "=", ",") .
        v-subj1 = replace(v-subj1, " ", ",") .
        if can-do (v-subj1, p-my-name) then do :
          v-my-cert = v-cert1 .
          leave .
        end .
      end .
      if v-my-cert = ? then v-my-cert = v-ofcollection[0] .
    end .
    else
      undo, throw new Progress.Lang.AppError(substitute("Отсутствуют действующие сертификаты выданные субъекту [&1] центром сертификации [&2] для подписи пакета", p-my-name, p-issuer)) .
      
    if m-debug-enabled then do :
      define variable v-publ-key as class System.Security.Cryptography.X509Certificates.PublicKey no-undo .
      v-publ-key = v-my-cert:PublicKey .
      put stream f-log unformatted
        substitute("my-cert Subj [&1]", v-my-cert:Subject) skip
        substitute("my-cert PulicKey &1", (if valid-object(v-publ-key) then "valid" else "empty")) skip
      .
    end .
    
    m-x509-store:Close() .
    finally:
      if valid-object(v-ofcollection) then delete object v-ofcollection.
      if valid-object(v-mycollection) then delete object v-mycollection.
      if valid-object(v-cucollection) then delete object v-cucollection.
      if valid-object(v-certificates) then delete object v-certificates.
      // ссылка на v-my-cert остаётся и передаётся в вызывающую программу
    end finally .
  end .

  return v-my-cert .  
end method . // end_of getMyCert

method private "System.Byte[]" memPtr2ByteArray (input p-memptr as memptr) :
define variable v-mptr-size  as int64 no-undo .
define variable v-int-size   as integer no-undo .
define variable v-byte-array as class "System.Byte[]" no-undo .
define variable v-n-ptr      as System.IntPtr no-undo .

  v-mptr-size = get-size(p-memptr).
  v-int-size  = integer(v-mptr-size) .
  v-byte-array = new "System.Byte[]" (v-int-size) .
  v-n-ptr      = new System.IntPtr(get-pointer-value(p-memptr)).
  System.Runtime.InteropServices.Marshal:Copy(v-n-ptr, v-byte-array, 0, v-int-size).
  
  return v-byte-array .
  
  finally:
    if valid-object(v-n-ptr) then delete object(v-n-ptr) .
  end finally .
end method . // end_of memPtr2ByteArray

method private character byteArray2Str (input p-byte-array as class "System.Byte[]") :
define variable v-str-1 as character no-undo .
define variable v-int-1 as integer no-undo .
define variable v-len-1 as integer no-undo .
  
  v-str-1 = "" .
  v-len-1 = p-byte-array:Length - 1 .
  do v-int-1 = 0 to v-len-1 :
    v-str-1 = v-str-1 + cast(p-byte-array:GetValue(v-int-1), "System.Byte"):ToString("x2") .
  end .

  return v-str-1 .  
end method . // end_of byteArray2Str

// 12/IX-2018 1совцы не смогли хэшировать функцией sha-256 и попросили её заменить на sha-1
method private "System.Byte[]" hashSHA1 (input p-byte-content as class "System.Byte[]") :
define variable v-o-sha1       as class System.Security.Cryptography.SHA1Managed no-undo .
define variable v-hash-content as class "System.Byte[]" no-undo .
  v-o-sha1 = new System.Security.Cryptography.SHA1Managed() .
  v-hash-content = v-o-sha1:ComputeHash(p-byte-content) .
  return v-hash-content .
  finally :
    if valid-object(v-o-sha1) then delete object(v-o-sha1) .
  end finally .
end method . // end_of hashSHA1

method private "System.Byte[]" hashSHA256 (input p-byte-content as class "System.Byte[]") :
define variable v-o-sha256     as class System.Security.Cryptography.SHA256Managed no-undo .
define variable v-hash-content as class "System.Byte[]" no-undo .
  v-o-sha256 = new System.Security.Cryptography.SHA256Managed() .
  v-hash-content = v-o-sha256:ComputeHash(p-byte-content) . // может получать на вход stream
  // проверка из коммандной строки: Certutil -hashfile c:file SHA256
  return v-hash-content .
  finally :
    if valid-object(v-o-sha256) then delete object(v-o-sha256) .
  end finally .
end method . // end_of hashSHA256

method private "System.Byte[]" signCms (
  input p-content-info as class System.Security.Cryptography.Pkcs.ContentInfo
, input p-cert         as class System.Security.Cryptography.X509Certificates.X509Certificate2
, input p-is-detached  as logical
) :
define variable v-signed-cms   as class System.Security.Cryptography.Pkcs.SignedCms no-undo .
define variable v-cms-signer   as class System.Security.Cryptography.Pkcs.CmsSigner no-undo .
define variable v-encoded-sign as class "System.Byte[]" no-undo .
define variable v-err-descr    as character no-undo .

  // Подписание 
  // https://docs.microsoft.com/ru-ru/dotnet/api/system.security.cryptography.pkcs.signedcms.computesignature?view=netframework-4.7.2#System_Security_Cryptography_Pkcs_SignedCms_ComputeSignature_System_Security_Cryptography_Pkcs_CmsSigner_
  // not detached signature = The original content is included in this byte array.
  // detached signature = The original content is not included in this byte array.
  v-signed-cms   = new System.Security.Cryptography.Pkcs.SignedCms (p-content-info, p-is-detached) .
  
  v-cms-signer = new System.Security.Cryptography.Pkcs.CmsSigner (p-cert).
  v-cms-signer:IncludeOption = System.Security.Cryptography.X509Certificates.X509IncludeOption:EndCertOnly.
  // X509Chain.aspx — позволяет строить и проверять цепочку сертификатов.
  
  do on error undo, throw:
    v-signed-cms:ComputeSignature(v-cms-signer) .
    v-err-descr = "" .
    catch exArgNull   as class System.ArgumentNullException :
      v-err-descr = "A null reference was passed to a method that does not accept it as a valid argument." .
      undo, throw new Progress.Lang.AppError(v-err-descr) .
    end catch .
    catch exCrypt     as class System.Security.Cryptography.CryptographicException :
      // v-err-descr = "A cryptographic operation could not be completed." .
      v-err-descr = substitute("&1|&2", exCrypt:HResult, exCrypt:Message) .
      // -2146893811 | Ключ не существует.
      undo, throw new Progress.Lang.AppError(v-err-descr) .
    end catch .
    catch exInvalidOp as  class System.InvalidOperationException :
      v-err-descr = "A method call was invalid for the object's current state." . 
      undo, throw new Progress.Lang.AppError(v-err-descr) .
    end catch .
    finally :
      if m-debug-enabled then do :
        if v-err-descr = "" then put stream f-log unformatted "signification Ok" skip(1) .
                            else put stream f-log unformatted v-err-descr skip(1) .
      end .
    end . 
  end .
  
  v-encoded-sign = v-signed-cms:Encode() .
  
  return v-encoded-sign .
  
  finally :
    if valid-object(v-cms-signer)   then delete object v-cms-signer.
    if valid-object(v-signed-cms)   then delete object v-signed-cms.
  end finally .
end method . // end_of signCms

method private void putData (input p-data as memptr) :
  if valid-object(m-hash-content) then delete object m-hash-content.
  if valid-object(m-byte-content) then delete object m-byte-content.
  
  m-byte-content = memPtr2ByteArray(p-data) .
  m-hash-content = hashSHA1(m-byte-content) .
  if m-debug-enabled then do :
    put stream f-log unformatted
      "putData" skip
      substitute("byte-content [&1]", byteArray2Str(m-byte-content)) skip
      substitute("hash-content [&1]", byteArray2Str(m-hash-content)) skip(1)
    .
  end .
end method . // end_of putData


method public memptr computeSign (
  input p-data    as memptr
, input p-my-name as character
, input p-issuer  as character
, input p-cert-repository as integer
) :
define variable v-my-sert      as class System.Security.Cryptography.X509Certificates.X509Certificate2 no-undo .
define variable v-sign         as memptr no-undo .
//define variable v-byte-content as class "System.Byte[]" no-undo .
//define variable v-hash-content as class "System.Byte[]" no-undo .
define variable v-content-info as class System.Security.Cryptography.Pkcs.ContentInfo no-undo .
define variable v-encoded-sign as class "System.Byte[]" no-undo .
define variable i              as integer no-undo .

  v-my-sert = getMyCert(p-my-name, p-issuer, p-cert-repository).
  if valid-object(v-my-sert) then do:
    if m-debug-enabled then do :
      define variable v-publ-key as class System.Security.Cryptography.X509Certificates.PublicKey no-undo .
      v-publ-key = v-my-sert:PublicKey .
      put stream f-log unformatted
        "enc1" skip
        substitute("p-data [&1]", string(p-data)) skip(1)
      .
    end .
  end .
  else do :
    if m-debug-enabled then do :
      put stream f-log unformatted
        "enc1 my-cert not-valid" skip(1)
      .
    end .
    undo, throw new Progress.Lang.AppError("Ошибка поиска сертификата для подписи пакета") .
  end .

  putData(p-data) .

  // represents the CMS/PKCS #7 ContentInfo data structure
  // 16/X-2018 - оказалось, что 1с вообще не берёт hash, а отправляет шифроваться xml как есть
  // v-content-info = new System.Security.Cryptography.Pkcs.ContentInfo (c-oid-data, m-hash-content) .
  v-content-info = new System.Security.Cryptography.Pkcs.ContentInfo (c-oid-data, m-byte-content) .
  if m-debug-enabled then do :
    put stream f-log unformatted
      "enc3" skip
      substitute("v-content-info:content [&1]", byteArray2Str(v-content-info:Content)) skip(1)
    .
  end .
  
  v-encoded-sign = signCms (v-content-info, v-my-sert, true) . // detached
  if m-debug-enabled then do :
    put stream f-log unformatted
      "enc4" skip
      substitute("detached encoded-sign [&1]", byteArray2Str(v-encoded-sign)) skip(1)
    .
  end .

  /* - мы отправляем xml + подпись.
     - принимающая сторона делает свой хэш и пытается приложить к нему декодирование нашей подписи
     таким образом, вкладывать подписанный хэш внутрь подписи не требуется
  */
  
  set-size(v-sign) = v-encoded-sign:Length .
  do i = 1 to v-encoded-sign:Length :
    put-byte(v-sign, i) = integer(v-encoded-sign:GetValue(i - 1):ToString()) .
  end .

  return v-sign .

  finally :
    if valid-object(v-encoded-sign) then delete object v-encoded-sign.
    if valid-object(v-content-info) then delete object v-content-info.
//    if valid-object(v-hash-content) then delete object v-hash-content.
//    if valid-object(v-byte-content) then delete object v-byte-content.
    if valid-object(v-my-sert) then do :
      v-my-sert:Dispose() . // Starting with the .NET Framework 4.6 you should dispose of it either directly or indirectly.
      delete object v-my-sert.
    end .
  end finally .
end method . // end_of computeSign

method public void putSign (input p-sign as memptr) :
define variable v-signed-cms as class System.Security.Cryptography.Pkcs.SignedCms no-undo .

  if valid-object(m-sign-certs)   then delete object m-sign-certs.
  if valid-object(m-encoded-sign) then delete object m-encoded-sign.
  
  m-encoded-sign = memPtr2ByteArray (p-sign) .
  if m-debug-enabled then do :
    put stream f-log unformatted
      "putSign" skip
      substitute("encoded-sign [&1]", byteArray2Str(m-encoded-sign)) skip(1)
    .
  end .

  v-signed-cms = new System.Security.Cryptography.Pkcs.SignedCms () .
  v-signed-cms:Decode(m-encoded-sign) .
  m-sign-certs = v-signed-cms:Certificates .
  
end method . // end_of putSign

method public character getCertSubject () :
define variable v-cert1      as class System.Security.Cryptography.X509Certificates.X509Certificate2 no-undo .
define variable v-cert-dname as class System.Security.Cryptography.X509Certificates.X500DistinguishedName no-undo .
define variable v-cert-subj  as character no-undo . 
define variable v-err-descr  as character no-undo .
  
  if not valid-object(m-sign-certs) then do :
    v-err-descr = "Отсутствует электронная подпись, содержащая сертификат. Используйте putSign() перед вызовом getCertSubject()." . 
    undo, throw new Progress.Lang.AppError(v-err-descr) .
  end .
  
  if m-sign-certs:Count > 0 then do :
    v-cert1 = m-sign-certs[0] .
    /*
    v-cert-subj = v-cert1:Subject . // :Subject возвращает "CN=oldOn18Sep" или побуквенно так, как ввели при создании сертификата

    15/X-2018 - т.к. 1с-овцы хотят использовать ключ OU в составе DN - переходим на v-cert1:SubjectName,
                в котором представление имени более структурировано
    https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.x509certificates.x500distinguishedname?view=netframework-4.7.2
    The following field length limits apply:
       CountryCode       2 characters
       Organization      Up to 64 characters
       OrganizationUnit  Up to 32 characters
       CommonName        Up to 64 characters
    */
    // v-cert-dname = new System.Security.Cryptography.X509Certificates.X500DistinguishedName (v-cert1:SubjectName) .
    // v-cert-subj  = v-cert-dname:Name . // Gets the comma-delimited distinguished name from an X500 certificate.
    v-cert-subj = v-cert1:SubjectName:Name .
  end .
  else do :
    v-err-descr = "В электронной подписи отсутствует сертификат подписавшей стороны." . 
    if valid-object(m-sign-certs)   then delete object m-sign-certs.
    if valid-object(m-encoded-sign) then delete object m-encoded-sign.
    undo, throw new Progress.Lang.AppError(v-err-descr) .
  end .
  
  return v-cert-subj .
  finally :
    if valid-object (v-cert-dname) then delete object v-cert-dname .
  end finally .
end method . // end_of getCertSubject

method public void verifySign (input p-data as memptr) :
// Проверка detached signature
// обратная задача: есть файл с данными и файл с подписью, содержащий сертификат.
//define variable v-encoded-sign as class "System.Byte[]" no-undo .
//define variable v-byte-content as class "System.Byte[]" no-undo .
//define variable v-hash-content as class "System.Byte[]" no-undo .
define variable v-content-info as class System.Security.Cryptography.Pkcs.ContentInfo no-undo .
define variable v-signed-cms   as class System.Security.Cryptography.Pkcs.SignedCms no-undo .
define variable v-cert1        as class System.Security.Cryptography.X509Certificates.X509Certificate2 no-undo .
define variable v-x509chain    as class System.Security.Cryptography.X509Certificates.X509Chain no-undo .
// define variable v-chain-policy as class System.Security.Cryptography.X509Certificates.X509ChainPolicy no-undo .
define variable v-element      as class System.Security.Cryptography.X509Certificates.X509ChainElement no-undo .
define variable v-status       as class "System.Security.Cryptography.X509Certificates.X509ChainStatus[]" no-undo .
define variable v-status1      as class System.Security.Cryptography.X509Certificates.X509ChainStatus no-undo .
define variable v-certs-count  as integer no-undo .
define variable v-icert        as integer no-undo .  
define variable v-int          as integer no-undo .
define variable v-jnt          as integer no-undo .
define variable v-err-descr    as character no-undo .
  
  if not valid-object(m-encoded-sign) then do :
    v-err-descr = "Отсутствует электронная подпись для проверки. Используйте putSign() перед вызовом verifySign()." . 
    undo, throw new Progress.Lang.AppError(v-err-descr) .
  end .
  if not valid-object(m-sign-certs) then do :
    v-err-descr = "В электронной подписи отсутствует сертификат подписавшей стороны." . 
    undo, throw new Progress.Lang.AppError(v-err-descr) .
  end .
  if m-sign-certs:Count > 0 then . else do :
    v-err-descr = "В электронной подписи отсутствует сертификат подписавшей стороны." . 
    undo, throw new Progress.Lang.AppError(v-err-descr) .
  end .
  
  putData(p-data) .
  v-err-descr    = "" .
  
  // Надо проверить, что данная подпись получена именно с этого файла и при помощи этого сертификата.
  // 16/X-2018 - оказалось, что 1с вообще не берёт hash, а отправляет шифроваться xml как есть
  // v-content-info = new System.Security.Cryptography.Pkcs.ContentInfo (c-oid-data, m-hash-content) .
  v-content-info = new System.Security.Cryptography.Pkcs.ContentInfo (c-oid-data, m-byte-content) .
  v-signed-cms   = new System.Security.Cryptography.Pkcs.SignedCms (v-content-info, true) .
  v-signed-cms:Decode(m-encoded-sign) .

  v-x509chain = new System.Security.Cryptography.X509Certificates.X509Chain () .
  v-x509chain:ChainPolicy:RevocationMode    = System.Security.Cryptography.X509Certificates.X509RevocationMode:NoCheck .
  v-x509chain:ChainPolicy:VerificationFlags = System.Security.Cryptography.X509Certificates.X509VerificationFlags:NoFlag .
  v-certs-count = m-sign-certs:Count .
  do v-icert = 0 to v-certs-count - 1 :  
    v-cert1 = m-sign-certs[v-icert] .
    v-x509chain:Build(v-cert1) .
  
  if m-debug-enabled then do :
    put stream f-log unformatted
    skip(1)
    substitute("Chain Information") skip
    substitute("Chain revocation flag: &1", v-x509chain:ChainPolicy:RevocationFlag) skip
    substitute("Chain revocation mode: &1", v-x509chain:ChainPolicy:RevocationMode) skip
    substitute("Chain verification flag: &1", v-x509chain:ChainPolicy:VerificationFlags) skip
    substitute("Chain verification time: &1", v-x509chain:ChainPolicy:VerificationTime) skip
    substitute("Chain status length: &1", v-x509chain:ChainStatus:Length) skip
    substitute("Chain application policy count: &1", v-x509chain:ChainPolicy:ApplicationPolicy:Count) skip
    substitute("Chain certificate policy count: &1", v-x509chain:ChainPolicy:CertificatePolicy:Count) skip
    .
  end .  

  v-status = v-x509chain:ChainStatus .
  if v-status:Length  > 0 then do :
    do v-int = 0 to v-status:Length - 1 :
      v-status1 = cast(v-status:GetValue(v-int), "System.Security.Cryptography.X509Certificates.X509ChainStatus") .
      if m-debug-enabled then do :
        put stream f-log unformatted
          substitute("  &1", v-status1:Status) skip
          substitute("  &1", v-status1:StatusInformation) skip
        .
      end .
      v-err-descr = v-err-descr + chr(10) + v-status1:StatusInformation . 
    end .
    v-err-descr = substring( v-err-descr, 2 ). 
    undo, throw new Progress.Lang.AppError(v-err-descr) .
  end .
  
  do v-int = 0 to v-x509chain:ChainElements:Count - 1 :
    v-element = v-x509chain:ChainElements[v-int] .
    if m-debug-enabled then do :
      put stream f-log unformatted
      skip(1)
      substitute("Element issuer name: &1",             v-element:Certificate:Issuer) skip
      substitute("Element certificate valid until: &1", v-element:Certificate:NotAfter) skip
      substitute("Element certificate is valid: &1",    v-element:Certificate:Verify()) skip
      substitute("Element error status length: &1",     v-element:ChainElementStatus:Length) skip
      substitute("Element information: &1",             v-element:Information) skip
      substitute("Number of element extensions: &1",    v-element:Certificate:Extensions:Count) skip
      .
    end .
    if v-element:ChainElementStatus:Length > 0 then do :
      v-status = v-element:ChainElementStatus .
      v-err-descr = "" .
      do v-jnt = 0 to v-status:Length - 1 :
        v-status1 = cast(v-status:GetValue(v-jnt), "System.Security.Cryptography.X509Certificates.X509ChainStatus") .
        if m-debug-enabled then do :
          put stream f-log unformatted
            substitute("  &1", v-status1:Status) skip
            substitute("  &1", v-status1:StatusInformation) skip
          .
        end .
        v-err-descr = v-err-descr + chr(10) + v-status1:StatusInformation . 
      end .
      v-err-descr = substring( v-err-descr, 2 ). 
      undo, throw new Progress.Lang.AppError(v-err-descr) .
    end .
  end . // end_of v-x509chain:ChainElements:Count
  end . // end_of do_v-certs-count
        
  do on error undo, throw:
    //  Проверяем подпись и корректность сертификата подписавшего.
    v-signed-cms:CheckSignature(true) . // true - только подпись, false - и сертификаты тоже
    // https://docs.microsoft.com/ru-ru/dotnet/api/system.security.cryptography.pkcs.signedcms.checksignature?view=netframework-4.7.2#System_Security_Cryptography_Pkcs_SignedCms_CheckSignature_System_Security_Cryptography_X509Certificates_X509Certificate2Collection_System_Boolean_
    // The CheckSignature(X509Certificate2Collection, Boolean) method verifies the digital signatures on the signed CMS/PKCS #7 message by using the specified collection of certificates and, optionally, validates the signers' certificates.
    v-err-descr = "" .
    catch exArgNull   as class System.ArgumentNullException :
      v-err-descr = "A null reference was passed to a method that does not accept it as a valid argument." .
      undo, throw new Progress.Lang.AppError(v-err-descr) .
    end catch .
    catch exCrypt     as class System.Security.Cryptography.CryptographicException :
      // v-err-descr = "A cryptographic operation could not be completed." .
      v-err-descr = substitute("&1|&2", exCrypt:HResult, exCrypt:Message) .
      // -2146762486 | Не удается построить цепочку сертификатов для доверенного корневого центра.      
      // -2146762495 | Истек/не наступил срок действия требуемого сертификата при проверке по системным часам или по отметке времени в подписанном файле.      
      // -2146885614 | Функция отзыва не смогла произвести проверку отзыва для сертификата.
      // -2146889714 | Не найден автор исходной подписи.
      // -2146889721 | Неправильное значение хеша.
      // -2146893818 | Неправильная подпись.      
      undo, throw new Progress.Lang.AppError(v-err-descr) .
    end catch .
    catch exInvalidOp as  class System.InvalidOperationException :
      v-err-descr = "A method call was invalid for the object's current state." . 
      undo, throw new Progress.Lang.AppError(v-err-descr) .
    end catch .
    finally :
      if m-debug-enabled then do :
        if v-err-descr = "" then put stream f-log unformatted "verification Ok" skip(1) .
                            else put stream f-log unformatted v-err-descr skip(1) .
      end .
    end . 
  end .

  finally :
    if valid-object(v-x509chain) then do :
      v-x509chain:Dispose() .
      delete object v-x509chain .
    end .
    if valid-object(v-signed-cms)   then delete object v-signed-cms.
    if valid-object(v-content-info) then delete object v-content-info.
//    if valid-object(v-hash-content) then delete object v-hash-content.
//    if valid-object(v-byte-content) then delete object v-byte-content.
//    if valid-object(v-encoded-sign) then delete object v-encoded-sign.
  end finally .
end method. // end_of verifySign


end class.