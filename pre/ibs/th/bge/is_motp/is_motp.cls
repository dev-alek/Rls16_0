using Progress.Lang.*.
using ibs.th.str.gds.*.
using ibs.th.gbl.*.
using ibs.th.gbl.sys.*.
using ibs.th.gbl.storage.*.
using ibs.th.str.clients.*.
using ibs.th.str.utd.*.
using ibs.th.str.utd.sts.*.
block-level on error undo, throw.
class ibs.th.bge.is_motp.is_motp inherits objth:
    define override public property vss-revision    as character no-undo init "$Revision:$":U get .
    define override public property vss-author      as character no-undo init "$Author:$":U get.
    define override public property vss-date        as character no-undo init "$Date:$":U get.
    define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
    define override public property vss-archive     as character no-undo init "$Archive:$":U get.
    define override public property vss-description as character no-undo init "Класс для работы с МОТП" get.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
  define temp-table tt-childs no-undo
    field mark    as character case-sensitive
    field parent_ as character
    index pi as primary unique
      mark parent_
  .
  define property thumpprint as character no-undo init ?
    get.
    private set.
  define property proxy-addr as character no-undo init ?
    get.
    private set.
  define property proxy-login as character no-undo init ?
    get.
    private set.
  define property proxy-pswd as character no-undo init ?
    get.
    private set.
  define variable CmdParamProxy    as character no-undo.
  define variable CmdParamProxyLog as character no-undo.
  define property proxy-ssl as logical no-undo init ?
    get.
    private set.
  define property esysId as integer no-undo init ?
    get.
    private set.
  define property esysDbNum as integer no-undo init ?
    get.
    private set.
  define property user-id_ as character no-undo init ?
    get.
    private set.
  define property mail-list as character no-undo init ?
    get.
    private set.
  define property server_ as character no-undo init "https://int01.gismt.crpt.tech/api/v3/true-api"
    get.
    private set.
  define property applicationId as character no-undo
    get.
    protected set.
  define property Status_ as character no-undo
    get.
    protected set.
  define property HttpStatus as integer no-undo
    get.
    protected set.
  define property Msg as character no-undo
    get.
    protected set.
  define property StatusErr as logical no-undo init false
    get.
    protected set.
  define property Doc-Id as integer no-undo
    get.
    protected set.
  define property DB-num as integer no-undo
    get.
    protected set.
  define property docDB-num as integer no-undo
    get.
    protected set.
  define property INN as character no-undo
    get.
    protected set.
  define property isFirstEnter as logical no-undo init false
    get.
    set.
  define property checkINN as logical no-undo init false
    get.
    set.
  define property isDebug as logical no-undo init false
    get.
    set.
  define property INNchecked as logical no-undo init false
    get.
    protected set.
  define property BadAuth as logical no-undo init false
    get.
    protected set.
  define property Level2 as logical no-undo init false
    get.
    protected set.
  define property foundLevel2 as logical no-undo init false
    get.
    protected set.
  define property needCheckUnit as logical no-undo init false
    get.
    protected set.
  define property lastLineCisInfo as integer no-undo init 0
    get.
    set.
  define property currToken as character no-undo
    get :
      define buffer buf_ext-system-attr for ub.ext-system-attr .
      find first buf_ext-system-attr no-lock where buf_ext-system-attr.db-num   = esysDbNum
                                               and buf_ext-system-attr.esys-id  = esysId
                                               and buf_ext-system-attr.esya-attr-code = "AuthToken"
                                               no-error .
      if not available buf_ext-system-attr
      then do :
        return ? .
      end.
      return buf_ext-system-attr.esya-attr-value .
    end.
    protected set .
  define property currTokenDT as datetime-tz no-undo
    get :
      define buffer buf_ext-system-attr for ub.ext-system-attr .
      find first buf_ext-system-attr no-lock where buf_ext-system-attr.db-num   = esysDbNum
                                               and buf_ext-system-attr.esys-id  = esysId
                                               and buf_ext-system-attr.esya-attr-code = "AuthTokenDT"
                                               no-error .
      if not available buf_ext-system-attr
      or (available buf_ext-system-attr and trim(buf_ext-system-attr.esya-attr-value) = "")
      then do :
        return ? .
      end.
      return datetime-tz(buf_ext-system-attr.esya-attr-value) .
    end.
    protected set .
  define property addCurlKeys as character no-undo initial ""
    get.
    protected set.
  define variable mFileAuth      as character no-undo.
  define variable mFileCades     as character no-undo.
  define variable mFileAuthTest  as character no-undo.
  define variable mFilecisesInfo as character no-undo.
  define variable mFileLK_RECEIPT as character no-undo.
  define variable v-section   as character no-undo .
  define variable v-key       as character no-undo .
  define stream sLog .
  constructor public is_motp (  ):
    define buffer buf_ext-system for ub.ext-system .
    define buffer buf_ext-system-attr for ub.ext-system-attr .
    find first clients no-lock where clients.obj-type = 'маг':U
                                 and clients.db-num = gbl-var:g#db-num
                                 and clients.stts = 0
                                 no-error .
    if not available clients
    then do :
      assign
        MSG = "Нет активного магазина в БД" + string(gbl-var:g#db-num)
        StatusErr = true
      .
      return error .
    end .
    for each buf_ext-system-attr no-lock where buf_ext-system-attr.esya-attr-code   = 'host-code':U
                                           and buf_ext-system-attr.esya-attr-value  = string(clients.host-code)
                                           :
      find first buf_ext-system no-lock where buf_ext-system.esys-type = integer('11':U)
                                          and buf_ext-system.esys-id   = buf_ext-system-attr.esys-id
                                          no-error .
      if available buf_ext-system then leave .
    end .
    if not available buf_ext-system
    then do :
      assign
        MSG = "Нет внешней системы с типом ИС МОТП, привязанной к фирме Орг" + string(clients.host-code)
        StatusErr = true
      .
      return error .
    end .
    setProps(buf_ext-system.db-num, buf_ext-system.esys-id, gbl-var:g#db-num) .
  end constructor .
  constructor public is_motp
  (
  input pEsysDbNum as integer,
  input pEsysId as integer
  ) :
    setProps(pEsysDbNum, pEsysId, gbl-var:g#db-num) .
  end constructor .
  constructor public is_motp
  (
  input pEsysDbNum as integer,
  input pEsysId as integer,
  input pDbNum as integer
  ) :
    setProps(pEsysDbNum, pEsysId, pDbNum) .
  end constructor .
  method private void setProps
  (
  input pEsysDbNum as integer,
  input pEsysId as integer,
  input pDbNum as integer
  ) :
    define buffer buf_ext-system for ub.ext-system .
    define buffer buf_ext-system-attr for ub.ext-system-attr .
    DB-num = pDbNum .
    find first buf_ext-system no-lock where buf_ext-system.db-num = pEsysDbNum
                                        and buf_ext-system.esys-id = pEsysId
                                        .
    esysId = buf_ext-system.esys-id .
    esysDbNum = buf_ext-system.db-num .
    for each buf_ext-system-attr no-lock where buf_ext-system-attr.db-num = buf_ext-system.db-num
                                           and buf_ext-system-attr.esys-id = buf_ext-system.esys-id
                                           :
      case buf_ext-system-attr.esya-attr-code :
        when 'user-id':U then do:
          user-id_ = buf_ext-system-attr.esya-attr-value .
        end.
        when 'server-addr':U then do:
          server_ = buf_ext-system-attr.esya-attr-value.
        end.
        when 'proxy-addr':U then do:
           get-key-value section "ProxyServ" key buf_ext-system-attr.esya-attr-code value proxy-addr.
           if proxy-addr eq ?
           then
              proxy-addr = buf_ext-system-attr.esya-attr-value .
        end.
        when 'proxy-login':U then do:
           get-key-value section "ProxyServ" key buf_ext-system-attr.esya-attr-code value proxy-login.
           if proxy-login eq ?
           then
              proxy-login = buf_ext-system-attr.esya-attr-value .
        end.
        when 'proxy-pswd':U then do:
           get-key-value section "ProxyServ" key buf_ext-system-attr.esya-attr-code value proxy-pswd.
           if proxy-pswd eq ?
           then
              proxy-pswd = buf_ext-system-attr.esya-attr-value .
        end.
        when 'proxy-ssl':U then do:
           define variable vtext as character no-undo.
           get-key-value section "ProxyServ" key buf_ext-system-attr.esya-attr-code value vtext.
           if vtext eq ?
           then
              proxy-ssl = logical(buf_ext-system-attr.esya-attr-value) .
           else
              proxy-ssl = logical(vtext) .
        end.
        when 'mail-list':U then do:
          mail-list = buf_ext-system-attr.esya-attr-value .
        end.
        when 'host-code':U then do:
          find first firm no-lock where firm.firm-code = integer(buf_ext-system-attr.esya-attr-value) no-error .
          if available firm
          then do :
            INN = firm.inn .
          end .
        end.
      end case .
    end .
    if trim(proxy-addr) <> "" and proxy-addr <> ?
    then do :
      if proxy-ssl
      then do:
        assign
          CmdParamProxy    = substitute ('-k --proxy-negotiate -x &1 -U : ',proxy-addr)
          CmdParamProxyLog = CmdParamProxy
        .
      end.
      else do:
        assign
          CmdParamProxy     = substitute ('-x &1 -U &2:&3', proxy-addr, proxy-login, proxy-pswd )
          CmdParamProxyLog  = substitute ('-x &1 -U &2:',   proxy-addr, proxy-login             )
        .
      end.
    end.
    else
      assign
        CmdParamProxy    = ""
        CmdParamProxyLog = ""
      .
    mFileAuth      = "IsMotp_auth_db" + string(DB-num) + ".log".
    mFileCades     = "IsMotp_cadescom_db" + string(DB-num) + ".log".
    mFileAuthTest  = "IsMotp_authTest_db" + string(DB-num) + ".log".
    mFilecisesInfo = "IsMotp_cisesInfo_db" + string(DB-num) + ".log".
    mFileLK_RECEIPT = "IsMotp_LK_RECEIPT_db" + string(DB-num) + ".log".
    assign
      v-section = 'CURL':u
      v-key     = 'motp-keys':u
    .
    get-key-value section v-section key v-key value addCurlKeys .
    addCurlKeys = trim(addCurlKeys) .
    if addCurlKeys = ? then addCurlKeys = "" .
  end method .
  method public character SignDoc
  (
  input pKey as character,
  input pMode as character,
  input pData as longchar
  ):
    define variable oStore as component-handle no-undo .
    define variable oCerts as com-handle no-undo .
    define variable oCert as com-handle no-undo .
    define variable oSigner as com-handle no-undo .
    define variable oSignedData as com-handle no-undo .
    define variable signedDataLong as longchar no-undo .
    define variable vRetValue as character no-undo .
    define variable ii as integer no-undo .
    define variable ix as integer no-undo .
    define variable v-found as logical no-undo .
    define variable cmd as character no-undo .
    define variable vLine  as character no-undo .
    define variable vStr   as character no-undo .
    signedDataLong = ? .
    MSG = "".
    StatusErr = true.
    create "CAdESCOM.Store" oStore no-error .
    if error-status:num-messages > 0
    then do ix = 1 to  error-status:num-messages:
      putcades( error-status:get-message(ix) ) .
    end .
    oStore:Open (2, "My", 0) no-error .
    if error-status:num-messages > 0
    then do ix = 1 to  error-status:num-messages:
      putcades( error-status:get-message(ix) ) .
    end .
    create "CAPICOM.Certificates" oCerts no-error .
    if error-status:num-messages > 0
    then do ix = 1 to  error-status:num-messages:
      putcades( error-status:get-message(ix) ). .
    end .
    oCerts = oStore:Certificates .
    release object oStore .
    .
    create "CAdESCOM.Certificate" oCert  no-error.
    if error-status:num-messages > 0
    then do ix = 1 to  error-status:num-messages:
      putcades( error-status:get-message(ix) ). .
    end .
    assign v-found = false .
    do ii = 1 to oCerts:Count :
      oCert = oCerts:item(ii) .
      case pMode :
        when "ThumbPrint"
        then do :
          if oCert:Thumbprint = pKey
          then do :
            v-found = true .
            leave .
          end .
        end .
        when "SerialNumber"
        then do :
          if oCert:SerialNumber = pKey
          then do :
            v-found = true .
            leave .
          end .
        end .
      end case.
    end.
    release object oCerts .
    if not v-found
    then do :
       case pMode :
          when "ThumbPrint"
          then
             MSG = "В личном хранилище сертификатов не найден сертификат с отпечатком " + pKey .
          when "SerialNumber"
          then
             MSG = "В личном хранилище сертификатов не найден сертификат с серийным номером " + pKey .
       end case .
       putauth ( MSG ) .
    end.
    else do:
      create "CAdESCOM.CPSigner" oSigner no-error .
      if error-status:num-messages > 0
      then do ix = 1 to  error-status:num-messages:
        putcades( error-status:get-message(ix) ) .
      end .
      create "CAdESCOM.CadesSignedData" oSignedData no-error .
      if error-status:num-messages > 0
      then do ix = 1 to  error-status:num-messages:
        putcades( error-status:get-message(ix) ) .
      end .
      oSigner:Certificate = oCert .
      oSigner:TSAAddress = "http://testca2012.cryptopro.ru/tsp/tsp.srf" .
      oSignedData:ContentEncoding = 1 .
      oSignedData:Content = pData .
      signedDataLong = oSignedData:SignCades(oSigner, 1, true, 0) no-error .
      if error-status:num-messages > 0
      then do ix = 1 to  error-status:num-messages:
        putcades( error-status:get-message(ix)).
      end .
      if signedDataLong = ?
      or signedDataLong = ""
      then do :
        MSG = "Ошибка при попытке подписания документа открепленной подписью!".
        putauth ( MSG ) .
      end .
      else do:
        signedDataLong = replace(signedDataLong, chr(10), "") .
        signedDataLong = replace(signedDataLong, chr(13), "") .
      end .
    end .
    error-status:error = no .
    vRetValue = string(signedDataLong) no-error .
    if error-status:error
    then do :
      MSG = "Подпись слишком большая!".
      return ? .
    end .
    if trim(vRetValue) = "" then vRetValue = ? .
    return vRetValue .
  end method .
  method public character SendDoc_LK_RECEIPT
  (
  input pToken  as character,
  input pDB-num as integer,
  input pDoc-id as integer,
  input pKey as character,
  input pMode as character
  ):
    define buffer buf_utd for ub.utd .
    define variable cmd    as character no-undo .
    define variable cmdlog as character no-undo .
    define variable vFileToken as character no-undo.
    define variable tmpcmdfile  as character no-undo .
    define variable vBase64Doc as longchar no-undo .
    define variable vSignature as character no-undo .
    define variable vDataLong as longchar no-undo .
    define variable vFileResult as character no-undo .
    define variable vFileResultErr as character no-undo .
    define variable vfilereq as character no-undo .
    define variable vProductGroup as character no-undo .
    define variable vLine  as character no-undo .
    define variable vDocUUID as character no-undo .
    define variable vOk as logical no-undo .
    find first buf_utd no-lock where buf_utd.db-num = pDB-num
                                 and buf_utd.doc-id = pDoc-id
                                 .
    putLK_RECEIPT ( "Обработка документа " + string(buf_utd.db-num) + "_" + string(buf_utd.doc-id) ) .
    vProductGroup = getattrUtd(input buf_utd.db-num, input buf_utd.doc-id, input "LK_RECEIPT_PG") .
    if vProductGroup = ?
    or trim(vProductGroup) = ""
    then do :
      MSG = "В документе не заполнен атрибут Продуктовая Группа!".
      putLK_RECEIPT ( MSG ) .
      return ? .
    end .
    run str/makeBase64doc-LK_RECEIPT.p (input buf_utd.db-num,
                                        input buf_utd.doc-id,
                                        output vBase64Doc)
                                        no-error .
    if error-status:error
    then do :
      MSG = return-value .
      putLK_RECEIPT ( MSG ) .
      return ? .
    end .
    vSignature = getattrUtd(buf_utd.db-num, buf_utd.doc-id, "LK_RECEIPT_Signature") .
    if vSignature = ?
    or trim(vSignature) = ""
    then do :
      if pKey = ?
      or pMode = ?
      then do :
        MSG = "SendDoc_LK_RECEIPT: ошибка входных параметров сертификата".
        putLK_RECEIPT ( MSG ) .
        return ? .
      end .
      vSignature = SignDoc(pKey, pMode, vBase64Doc) .
      if vSignature = ?
      then do :
        putLK_RECEIPT ( MSG ) .
        return ? .
      end .
      setattrUtd (input buf_utd.db-num,
                  input buf_utd.doc-id,
                  input "LK_RECEIPT_Signature",
                  input vSignature)
                  .
      updateUtdStatus(input buf_utd.db-num, input buf_utd.doc-id, input ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_Signed:KeyIntDB) .
    end .
    vDataLong = "" .
    vDataLong = vDataLong + "~{" .
    vDataLong = vDataLong + quoter("document_format") + ":" + quoter("MANUAL") + "," .
    vDataLong = vDataLong + quoter("product_document") + ":" +  '"' + vBase64Doc + '"'  + "," .
    vDataLong = vDataLong + quoter("type") + ":" + quoter("LK_GTIN_RECEIPT") + "," .
    vDataLong = vDataLong + quoter("signature") + ":" + quoter(vSignature) .
    vDataLong = vDataLong + "~}" .
    vfilereq = "IsMotp_reqLK_RECEIPT_db" + string(pDB-num) + "_" + string(pDoc-id) + ".json".
    vFileResult    = "IsMotp_respLK_RECEIPT_db" + string(pDB-num) + "_" + string(pDoc-id) + ".json".
    vFileResultErr = "IsMotp_respLK_RECEIPT_db" + string(pDB-num) + "_" + string(pDoc-id) + ".err".
    vFileToken = "IsMotp_token_db" + string(pDB-num) + ".txt".
    copy-lob vDataLong to file (vfilereq) no-convert .
    putLK_RECEIPT ( "  out-data:" ) .
    if isDebug
    then
      os-append value(vfilereq) value(mFileLK_RECEIPT) .
    output stream sLog to value(vFileToken) .
      put stream sLog unformatted "Authorization: Bearer " pToken .
    output stream sLog close .
    cmd = substitute ('&1 &8 -d @&5 --stderr &7 -H "Content-Type: application/json" -H @&4 &6 &3/lk/documents/create?pg=&9 >&2',
                      search ("exe/curl.exe"),
                      vFileResult,
                      server_,
                      searchfile (vFileToken),
                      searchfile (vfilereq),
                      CmdParamProxy,
                      vFileResultErr,
                      addCurlKeys,
                      vProductGroup).
    cmdlog = substitute ('&1 &8 -d @&5 --stderr &7 -H "Content-Type: application/json" -H "Authorization: Bearer &4" &6 &3/lk/documents/create?pg=&9 >&2',
                      search ("exe/curl.exe"),
                      vFileResult,
                      server_,
                      pToken,
                      searchfile (vfilereq),
                      CmdParamProxyLOG,
                      vFileResultErr,
                      addCurlKeys,
                      vProductGroup).
    putLK_RECEIPT ( "command: " ).
    putLK_RECEIPT ( cmdLOG   ).
    os-command silent value(cmd) .
    if searchFile(vfileresult) = ?
    then do :
      MSG = "Запрос не выполнен! Нет ответа от МОТП. Не могу найти файл " + search(vfileresult) .
      return ? .
    end .
    file-info:file-name = searchFile(vfileresult) .
    if file-info:file-size = 0
    then do :
      MSG = "Запрос не выполнен! Файл-ответ из МОТП " + search(vfileresult) + " пустой (размер 0 байт)." .
      return ? .
    end .
    output stream sLog to value (searchFile(vfileresult)) append .
    put stream sLog unformatted " " skip " _ ".
    output stream sLog close .
    input from value (searchFile(vfileresult)) .
    import unformatted vLine .
    input close .
    vLine = trim(vLine) .
    vLine = trim(vLine, chr(123)) .
    vLine = trim(vLine, "}") .
    if vLine begins '"error_message"'
    then do :
      MSG = trim(trim(substring(vLine, 17)), '"').
      putLK_RECEIPT ( MSG ) .
      return ? .
    end.
    vDocUUID = trim(vLine, '"') .
    if trim(vDocUUID) = ""
    then do :
      vDocUUID = ? .
    end .
    if vDocUUID > ""
    then do :
      vOK = updateUtdStatusUUID(input buf_utd.db-num, input buf_utd.doc-id, input ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_Sent:KeyIntDB, input vDocUUID) .
      if not vOK
      then do :
        MSG  = "Ошибка при обновлении статуса и UUID документа! Документ не найден либо запись захвачена" .
        return ? .
      end .
    end .
    return vDocUUID .
  end method .
  method public character authorize
  (
  input pKey as character,
  input pMode as character
  ):
    define buffer buf_ext-system-attr for ub.ext-system-attr .
    define variable oStore as component-handle no-undo .
    define variable oCerts as com-handle no-undo .
    define variable oCert as com-handle no-undo .
    define variable oSigner as com-handle no-undo .
    define variable oSignedData as com-handle no-undo .
    define variable signedData1Long as longchar no-undo .
    define variable signedData2Long as longchar no-undo .
    define variable ii as integer no-undo .
    define variable ix as integer no-undo .
    define variable v-found as logical no-undo .
    define variable cmd as character no-undo .
    define variable cmdlog as character no-undo .
    define variable vData1 as character no-undo .
    define variable vData2 as character no-undo .
    define variable vLine  as character no-undo .
    define variable vStr   as character no-undo .
    define variable vAuthDataLong as longchar no-undo .
    define variable vToken as character no-undo .
    MSG = "".
    StatusErr = true.
    create "CAdESCOM.Store" oStore no-error .
    if error-status:num-messages > 0
    then do ix = 1 to  error-status:num-messages:
      putcades( error-status:get-message(ix) ) .
    end .
    oStore:Open (2, "My", 0) no-error .
    if error-status:num-messages > 0
    then do ix = 1 to  error-status:num-messages:
      putcades( error-status:get-message(ix) ) .
    end .
    create "CAPICOM.Certificates" oCerts no-error .
    if error-status:num-messages > 0
    then do ix = 1 to  error-status:num-messages:
      putcades( error-status:get-message(ix) ). .
    end .
    oCerts = oStore:Certificates .
    release object oStore .
    .
    create "CAdESCOM.Certificate" oCert  no-error.
    if error-status:num-messages > 0
    then do ix = 1 to  error-status:num-messages:
      putcades( error-status:get-message(ix) ). .
    end .
    assign v-found = false .
    do ii = 1 to oCerts:Count :
      oCert = oCerts:item(ii) .
      case pMode :
        when "ThumbPrint"
        then do :
          if oCert:Thumbprint = pKey
          then do :
            v-found = true .
            leave .
          end .
        end .
        when "SerialNumber"
        then do :
          if oCert:SerialNumber = pKey
          then do :
            v-found = true .
            leave .
          end .
        end .
      end case.
    end.
    release object oCerts .
    if not v-found
    then do :
       case pMode :
          when "ThumbPrint"
          then
             MSG = "В личном хранилище сертификатов не найден сертификат с отпечатком " + pKey .
          when "SerialNumber"
          then
             MSG = "В личном хранилище сертификатов не найден сертификат с серийным номером " + pKey .
       end case .
       putauth ( MSG ) .
    end.
    else do:
      define variable vFileResult as character no-undo.
      define variable vFileResultErr as character no-undo.
      assign
        vFileResult    = "IsMotp_AuthData_db" + string(DB-num) + ".json"
        vFileResultErr = "IsMotp_AuthData_db" + string(DB-num) + ".err"
        cmd    = substitute ('&1 &6 &4 --stderr &5 &3/auth/key >&2', search ("exe/curl.exe"), vFileResult, server_, CmdParamProxy, vFileResultErr, addCurlKeys)
        cmdlog = substitute ('&1 &6 &4 --stderr &5 &3/auth/key >&2', search ("exe/curl.exe"), vFileResult, server_, CmdParamProxylog, vFileResultErr, addCurlKeys)
      .
      putauth(" command   " + cmdlog ).
      os-command silent value (cmd).
      define variable VFile as character no-undo.
      vfile =  SearchFile(vFileResult).
      if vfile eq ?
      then do:
        MSG = "Нет ответа от ИС МОТП. Не найден " + vFileResult.
        putauth (MSG ).
      end.
      else do:
        file-info:file-name = vfile .
        if file-info:file-size = 0
        then do :
          MSG = "Нет ответа от ИС МОТП. Файл пустой " + vfile.
          putauth ( MSG ).
        end.
        else do:
          copy-lob from file vfile to vAuthDataLong no-convert .
          output stream sLog to value (vfile) append .
          put stream sLog unformatted " " skip " _ ".
          output stream sLog close .
          input from value (vfile) convert source "UTF-8"  .
          import unformatted vLine .
          input close .
          do ii = 1 to num-entries(vLine) :
            vStr = entry(ii, vLine) .
            vStr = trim(vStr) .
            vStr = trim(vStr, "[") .
            vStr = trim(vStr, "]") .
            vStr = trim(vStr, chr(123)) .
            vStr = trim(vStr, "}") .
            if num-entries(vStr, ":") <> 2 then next .
            if vStr begins '"data"'
            then do :
              if ii < 3
              then vData1 = trim(trim(entry(2, vStr, ":")), '"') .
              else vData2 = trim(trim(entry(2, vStr, ":")), '"') .
            end.
            else
            if vStr begins '"error_message"'
            then do :
              MSG = trim(trim(entry(2, vStr, ":")), '"') .
              putauth ( MSG ).
              StatusErr = yes .
              return error MSG .
            end .
          end .
          create "CAdESCOM.CPSigner" oSigner no-error .
          if error-status:num-messages > 0
          then do ix = 1 to  error-status:num-messages:
            putcades( error-status:get-message(ix) ) .
          end .
          create "CAdESCOM.CadesSignedData" oSignedData no-error .
          if error-status:num-messages > 0
          then do ix = 1 to  error-status:num-messages:
            putcades( error-status:get-message(ix) ) .
          end .
          oSigner:Certificate = oCert .
          oSigner:TSAAddress = "http://testca2012.cryptopro.ru/tsp/tsp.srf" .
          oSignedData:ContentEncoding = 0 .
          oSignedData:Content = vData1 .
          signedData1Long = oSignedData:SignCades(oSigner, 1, false, 0) no-error .
          if error-status:num-messages > 0
          then do ix = 1 to  error-status:num-messages:
            putcades( error-status:get-message(ix)).
          end .
          if    signedData1Long = ?
          or signedData1Long = ""
          then do :
            MSG = "Ошибка при попытке подписания строки для получения токена авторизации!".
            putauth ( MSG ) .
          end .
          else do:
            signedData1Long = replace(signedData1Long, chr(10), "") .
            signedData1Long = replace(signedData1Long, chr(13), "") .
            define variable vFlagError as logical no-undo.
            if vData2 > ""
            then do :
              oSignedData:Content = vData2 .
              signedData2Long = oSignedData:SignCades(oSigner, 1, false, 0) no-error .
              if error-status:num-messages > 0
              then do ix = 1 to  error-status:num-messages:
                putcades( error-status:get-message(ix)) .
              end .
              if    signedData2Long = ?
              or signedData1Long = ""
              then do :
                MSG = "Ошибка при попытке подписания строки (2) для получения токена авторизации!".
                putauth ( MSG ) .
                vFlagError = yes.
              end .
              else do:
                signedData2Long = replace(signedData2Long, chr(10), "") .
                signedData2Long = replace(signedData2Long, chr(13), "") .
              end.
            end.
            if not vFlagError
            then do:
              if vData1 > ""
              then
                vAuthDataLong = replace(vAuthDataLong, vData1, signedData1Long) .
              if vData2 > ""
              then
                vAuthDataLong = replace(vAuthDataLong, vData2, signedData2Long) .
              copy-lob vAuthDataLong to file ("IsMotp_AuthDataSigned_db" + string(DB-num) + ".json") no-convert .
              vFileResult = "IsMotp_AuthToken_db" + string(DB-num) + ".json".
              vFileResulterr = "IsMotp_AuthToken_db" + string(DB-num) + ".err".
              cmd = substitute ('&1 &7 -H "Content-Type: application/json" &5 -d @&4 --stderr &6 &3/auth/simpleSignIn >&2',
                                 search ("exe/curl.exe"),
                                 vFileResult,
                                 server_,
                                 searchfile ("IsMotp_AuthDataSigned_db" + string(DB-num) + ".json"),
                                 CmdParamProxy,
                                 vFileResulterr,
                                 addCurlKeys).
              cmdlog = substitute ('&1 &7 -H "Content-Type: application/json" &5 -d @&4 --stderr &6 &3/auth/simpleSignIn >&2',
                                    search ("exe/curl.exe"),
                                    vFileResult,
                                    server_,
                                    searchfile ("IsMotp_AuthDataSigned_db" + string(DB-num) + ".json"),
                                    CmdParamProxyLog,
                                    vFileResulterr,
                                    addCurlKeys).
              putauth (" command   " + cmdlog ) .
              os-command silent value (cmd).
              vfile =  SearchFile(vFileResult).
              if vfile eq ?
              then do:
                MSG = "Нет ответа от ИС МОТП. Не найден " + vFileResult.
                putauth (MSG ).
              end.
              else do:
                file-info:file-name = vfile .
                if file-info:file-size = 0
                then do :
                  MSG = "Нет ответа от ИС МОТП. Файл пустой " + vfile.
                  putauth ( MSG ).
                end.
                else do:
                  output stream sLog to value (vfile) append .
                  put stream sLog unformatted " " skip " _ ".
                  output stream sLog close .
                  input from value (vfile) convert source "UTF-8" .
                  import unformatted vLine .
                  input close .
                  do ii = 1 to num-entries(vLine) :
                    vStr = entry(ii, vLine) .
                    vStr = trim(vStr) .
                    vStr = trim(vStr, "[") .
                    vStr = trim(vStr, "]") .
                    vStr = trim(vStr, chr(123)) .
                    vStr = trim(vStr, "}") .
                    if num-entries(vStr, '":"') < 2 then next .
                    if vStr begins '"token"'
                    then do :
                      vStr = trim(trim(substring(vStr, 9)), '"') .
                      if index(vStr, '"') > 0
                      then do :
                        vToken = trim(trim(substring(vStr, 1, index(vStr, '"'))), '"') .
                      end .
                      else do :
                        vToken = vStr .
                      end .
                    end.
                    if vStr begins '"error_message"'
                    then do :
                      MSG = trim(trim(substring(vStr, 17)), '"').
                      putauth ( MSG ) .
                    end.
                    else do trans:
                      find first buf_ext-system-attr where buf_ext-system-attr.db-num   = esysDbNum
                                                       and buf_ext-system-attr.esys-id  = esysId
                                                       and buf_ext-system-attr.esya-attr-code = "AuthToken"
                                                       exclusive-lock no-error .
                      if not available buf_ext-system-attr
                      then do :
                        create buf_ext-system-attr.
                        assign
                          buf_ext-system-attr.db-num         = esysDbNum
                          buf_ext-system-attr.esys-id        = esysId
                          buf_ext-system-attr.esya-attr-code = "AuthToken"
                        .
                      end.
                      buf_ext-system-attr.esya-attr-value = vToken .
                      find first buf_ext-system-attr where buf_ext-system-attr.db-num   = esysDbNum
                                                       and buf_ext-system-attr.esys-id  = esysId
                                                       and buf_ext-system-attr.esya-attr-code = "AuthTokenDT"
                                                       exclusive-lock no-error .
                      if not available buf_ext-system-attr
                      then do :
                        create buf_ext-system-attr.
                        assign
                          buf_ext-system-attr.db-num         = esysDbNum
                          buf_ext-system-attr.esys-id        = esysId
                          buf_ext-system-attr.esya-attr-code = "AuthTokenDT"
                        .
                      end.
                      buf_ext-system-attr.esya-attr-value = string(datetime-tz(now)) .
                    end.
                  end.
                end.
              end.
            end.
          end.
          release object oSigner .
          release object oSignedData .
        end.
      end.
    end.
    release object oCert .
    if MSG <> ""
    then
       return error MSG .
    else do:
       StatusErr = no .
       return vToken .
    end.
  end method .
  method public character updateToken
  (
  input pToken as character
  ) :
    define variable cmd         as character no-undo .
    define variable cmdlog      as character no-undo .
    define variable vLine       as character no-undo .
    define variable vFileResult as character no-undo.
    define variable vFileResultErr as character no-undo.
    define variable vFileToken  as character no-undo.
    define variable VFile       as character no-undo.
    define variable vStr        as character no-undo.
    define variable tmpcmdfile  as character no-undo .
    define variable vNewToken   as character no-undo.
    define variable vPath       as character no-undo.
    define variable ii          as integer   no-undo .
    define variable vHTTPstatus as character no-undo .
    define buffer buf_ext-system-attr for ub.ext-system-attr .
    MSG = "".
    StatusErr = true.
    vPath = substring(server_, 1, (length(server_) - 8)) + "auth/login/refresh" .
    vFileResult    = "IsMotp_updateToken_db" + string(DB-num) + ".test".
    vFileResultErr = "IsMotp_updateToken_db" + string(DB-num) + ".err".
    vFileToken = "IsMotp_token_db" + string(DB-num) + ".txt".
    output stream sLog to value(vFileToken) .
      put stream sLog unformatted "Authorization: Bearer " pToken .
    output stream sLog close .
    cmd = substitute ('&1 &7 -X POST -L -i --stderr &6 -H "Content-Type: application/json;charset=UTF-8" -H @&4 &5 &3 >&2',
                      search ("exe/curl.exe"),
                      vFileResult,
                      vPath,
                      searchfile(vFileToken),
                      CmdParamProxy,
                      vFileResultErr,
                      addCurlKeys).
    cmdlog = substitute ('&1 &7 -X POST -L -i --stderr &6 -H "Content-Type: application/json;charset=UTF-8" -H "Authorization: Bearer &4" &5 &3 >&2',
                      search ("exe/curl.exe"),
                      vFileResult,
                      vPath,
                      pToken,
                      CmdParamProxyLOG,
                      vFileResultErr,
                      addCurlKeys).
    putauth (" command   " + cmdlog ) .
    os-command silent value(cmd) .
    vfile =  SearchFile(vFileResult).
    if vfile eq ?
    then do:
      MSG = "Нет ответа от ИС МОТП. Не найден " + vFileResult.
      putauth (MSG ).
    end.
    else do:
      file-info:file-name = vfile .
      if file-info:file-size = 0
      then do :
        MSG = "Нет ответа от ИС МОТП. Файл пустой " + vfile.
        putauth ( MSG ).
      end.
      else do:
        output stream sLog to value (vfile) append .
        put stream sLog unformatted " " skip " _ ".
        output stream sLog close .
        input from value (vfile) .
        import unformatted vLine .
        input close .
        HttpStatus = ? .
        assign vHTTPstatus = "unknown" .
        if vLine begins 'HTTP/2'
        then do :
          vHTTPstatus = trim(substring(vLine, 8)) .
          HttpStatus = integer(vHTTPstatus) .
        end.
        if vLine begins 'HTTP/1.1'
        then do :
          vHTTPstatus = trim(substring(vLine, 10,3)) .
          HttpStatus = integer(vHTTPstatus) .
        end.
        if HttpStatus = 502
        then do :
          MSG = "Невозможно обновить токен. Ответ от МОТП - 502 Bad Gateway. Пробуем работать с текущим" .
        end .
        else do :
          input from value (vfile) .
          read-file_ :
          repeat :
            import unformatted vStr .
            vStr = trim(vStr) .
            vStr = trim(vStr, "[") .
            vStr = trim(vStr, "]") .
            vStr = trim(vStr, chr(123)) .
            vStr = trim(vStr, "}") .
            if num-entries(vStr, '":"') < 2 then next .
            if vStr begins '"token"'
            then do :
              vStr = trim(trim(substring(vStr, 9)), '"') .
              if index(vStr, '"') > 0
              then do :
                vNewToken = trim(trim(substring(vStr, 1, index(vStr, '"'))), '"') .
              end .
              else do :
                vNewToken = vStr .
              end .
            end.
            if vStr begins '"error_message"'
            then do :
              MSG = trim(trim(substring(vStr, 17)), '"').
              putauth ( MSG ) .
            end.
            else do trans:
              find first buf_ext-system-attr where buf_ext-system-attr.db-num   = esysDbNum
                                               and buf_ext-system-attr.esys-id  = esysId
                                               and buf_ext-system-attr.esya-attr-code = "AuthToken"
              exclusive-lock no-error .
              if not available buf_ext-system-attr
              then do :
                create buf_ext-system-attr.
                assign
                  buf_ext-system-attr.db-num         = esysDbNum
                  buf_ext-system-attr.esys-id        = esysId
                  buf_ext-system-attr.esya-attr-code = "AuthToken"
                .
              end.
              buf_ext-system-attr.esya-attr-value = vNewToken .
              find first buf_ext-system-attr where buf_ext-system-attr.db-num   = esysDbNum
                                               and buf_ext-system-attr.esys-id  = esysId
                                               and buf_ext-system-attr.esya-attr-code = "AuthTokenDT"
              exclusive-lock no-error .
              if not available buf_ext-system-attr
              then do :
                create buf_ext-system-attr.
                assign
                  buf_ext-system-attr.db-num         = esysDbNum
                  buf_ext-system-attr.esys-id        = esysId
                  buf_ext-system-attr.esya-attr-code = "AuthTokenDT"
                .
              end.
              buf_ext-system-attr.esya-attr-value = string(datetime-tz(now)) .
              leave read-file_ .
            end.
          end.
          input close .
        end .
      end.
    end.
    if MSG <> ""
    then
      return error MSG .
    else do:
      StatusErr = no .
      return vNewToken .
    end.
  end method .
  method public logical needTokenUpd ()
  :
    define buffer buf_ext-system-attr for ub.ext-system-attr .
    define variable vTokenDTdiff as datetime-tz no-undo .
    find first buf_ext-system-attr where buf_ext-system-attr.db-num   = esysDbNum
                                     and buf_ext-system-attr.esys-id  = esysId
                                     and buf_ext-system-attr.esya-attr-code = "AuthTokenDT"
    no-lock no-error .
    if not available buf_ext-system-attr
    then do :
      return false .
    end .
    vTokenDTdiff = datetime-tz(buf_ext-system-attr.esya-attr-value) + 21600000 .
    if vTokenDTdiff <= datetime-tz(now)
    then do :
      return true .
    end .
    else do :
      return false .
    end .
  end method .
  method public logical authTest
  (
  input pToken as character
  ) :
    define variable cmd         as character no-undo .
    define variable cmdlog      as character no-undo .
    define variable vLine       as character no-undo .
    define variable vHTTPstatus as character no-undo .
    define variable ii          as integer   no-undo .
    define variable tmpfile     as character no-undo .
    define variable tmpcmdfile  as character no-undo .
    define variable vFileResult as character no-undo.
    define variable vFileResultErr as character no-undo.
    define variable vFileToken  as character no-undo.
    StatusErr = true.
    tmpfile = "tmpmotp_db" + string(DB-num) + ".json" .
    output stream sLog to value(tmpfile) .
      put stream sLog unformatted  '~{"gtin":"00000046210654"}' skip .
    output stream sLog close .
    putauthTest ( "  out-data:" ) .
    if isDebug
    then
      os-append value(tmpfile) value(mFileAuthTest) .
    vFileResult    = "IsMotp_AuthTest_db" + string(DB-num) + ".test".
    vFileResultErr = "IsMotp_AuthTest_db" + string(DB-num) + ".err".
    vFileToken = "IsMotp_token_db" + string(DB-num) + ".txt".
    output stream sLog to value(vFileToken) .
      put stream sLog unformatted "Authorization: Bearer " pToken .
    output stream sLog close .
    cmd = substitute ('&1 &8 -i -d @&5 --stderr &7 -H "Content-Type: application/json" -H @&4 &6 &3/cises/my >&2',
                      search ("exe/curl.exe"),
                      vFileResult,
                      server_,
                      searchfile (vFileToken),
                      searchfile (tmpfile),
                      CmdParamProxy,
                      vFileResultErr,
                      addCurlKeys).
    cmdlog = substitute ('&1 &8 -i -d @&5 --stderr &7 -H "Content-Type: application/json" -H "Authorization: Bearer &4" &6 &3/cises/my >&2',
                      search ("exe/curl.exe"),
                      vFileResult,
                      server_,
                      pToken,
                      searchfile (tmpfile),
                      CmdParamProxyLOG,
                      vFileResultErr,
                      addCurlKeys).
    putauthTest ( "command: " ).
    putauthTest ( cmdLOG   ).
    os-command silent value(cmd) .
    define variable vfile as character no-undo.
    vfile =  SearchFile(vFileResult).
    if vfile eq ?
    then do:
       MSG = "Нет ответа от ИС МОТП. Не найден " + vFileResult.
       putauth (MSG ).
    end.
    else do:
       file-info:file-name = vfile .
       if file-info:file-size = 0
       then do :
          MSG = "Нет ответа от ИС МОТП. Файл пустой " + vfile.
          putauth ( MSG ).
       end.
       else do:
          putauthTest (" in-data:" ) .
          if isDebug
          then
            os-append value(vFileResult) value(mFileAuthTest) .
          output stream sLog to value (searchfile(vFileResult)) append .
          put stream sLog unformatted " " skip " _ ".
          output stream sLog close .
          input from value (searchfile(vFileResult)) .
          import unformatted vLine .
          input close .
          HttpStatus = ? .
          assign vHTTPstatus = "unknown" .
          if vLine begins 'HTTP/2'
          then do :
            vHTTPstatus = trim(substring(vLine, 8)) .
            HttpStatus = integer(vHTTPstatus) .
          end.
          if vLine begins 'HTTP/1.1'
          then do :
            vHTTPstatus = trim(substring(vLine, 10,3)) .
            HttpStatus = integer(vHTTPstatus) .
          end.
          StatusErr = no.
          if HttpStatus = 401
          then do :
            MSG = "Токен авторизации в ИС МОТП - НЕ ДЕЙСТВИТЕЛЕН" .
            return false .
          end .
          else if HttpStatus = 502
          then do :
            MSG = "Невозможно определить валидность токена. Ответ от МОТП - 502 Bad Gateway. Пробуем работать с текущим" .
            return true .
          end .
          else do :
            MSG = "Токен авторизации в ИС МОТП - ДЕЙСТВИТЕЛЕН" .
            return true .
          end .
       end.
    end.
  end method .
  method public logical sendEMail
  (
  input pMessage as character
  ) :
    define variable email as character no-undo .
    define variable ii as integer no-undo .
    do ii = 1 to num-entries(mail-list):
      email = trim(entry(ii, mail-list)).
      if email = ? or email = "" then next.
      run gbl/sendmail.p(
          email,
          "Ошибка авторизации в ИС МОТП",
          pMessage,
          ""
      ) no-error.
      if error-status:error
      then do :
        MSG = MSG + substitute("Ошибка при отправке на почту &1 - &2", email, return-value) + chr(10) .
        StatusErr = true .
      end .
    end.
  end method .
  define variable GrayZoneQnty  as integer no-undo .
  method public void cisesInfo
  (
  input pToken as character,
  input pDB-num as integer,
  input pDoc-id as integer,
  input pLevel2 as logical,
  output v-ok as logical
  ) :
    if pToken > ""
    then .
    else do :
       v-ok = no.
       MSG = "Запрос не выполнен. Нет токена для авторизации" .
       return.
    end.
    define variable cmd    as character no-undo .
    define variable cmdlog as character no-undo .
    define variable vLine as character no-undo .
    define variable vlongJson as longchar no-undo case-sensitive .
    define variable v-num-marks as integer no-undo .
    define variable vMark as character no-undo .
    define variable vFileToken  as character no-undo.
    define variable v-value-character     as character     no-undo .
    define variable v-value-decimal       as decimal       no-undo .
    define variable v-value-integer       as integer       no-undo .
    define variable v-value-logical       as logical       no-undo .
    define variable v-value-type          as character     no-undo .
    define variable v-value-date          as date          no-undo .
    define buffer buf_utd-marking-lines for ub.utd-marking-lines .
    define buffer buf_utd-lines for ub.utd-lines .
    define buffer buf_marking for ub.marking .
    define buffer buf_marking-parent for ub.marking .
    define buffer buf_utd-err for ub.utd-err .
    define buffer buf_utd for ub.utd .
    Level2 = pLevel2 .
    foundLevel2 = no .
    if not checkINN
    and lastLineCisInfo = 0
    then do :
      ClearUtdErrTypeCode(pDB-num, pDoc-id, "CheckMOTP", "MotpMarkErr").
    end .
    GrayZoneQnty = 100 .
    find first buf_utd no-lock where buf_utd.db-num = pDB-num
                                 and buf_utd.doc-id = pDoc-id
                                 .
    run adm/shattri.p (
      input "get":U
      ,input buf_utd.obj-type
      ,input buf_utd.obj-code
      ,input 'marking':U
      ,input "gray_zone_qnty"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,input-output TABLE thbjattr_thbj-attr
      ) no-error .
    if v-value-integer <> ?
    then
      GrayZoneQnty = v-value-integer
    .
    v-ok = true .
    v-num-marks = 0 .
    define variable vfilereq as character no-undo.
    vfilereq = "IsMotp_cisesInfoReq_db" + string(DB-num) + ".json".
    os-delete value (searchFile(vfilereq)) no-error .
    if searchFile(vfilereq) = ?
    then do : end .
    else do :
      v-ok = false .
      Msg = "Запрос не выполнен! Не могу удалить файл-запрос " + vfilereq .
      return .
    end .
    output stream sLog to value(vfilereq) .
    put stream sLog unformatted "[" skip .
    lines_:
    for each buf_utd-lines no-lock where buf_utd-lines.db-num = pDB-num
                                     and buf_utd-lines.doc-id = pDoc-id
                                     and buf_utd-lines.LineNum >= lastLineCisInfo
                                     break by buf_utd-lines.LineNum
                                     :
      if CheckErrForLine(buffer buf_utd-lines:handle)
      then next lines_ .
      marks_:
      for each buf_utd-marking-lines no-lock where buf_utd-marking-lines.db-num = buf_utd-lines.db-num
                                               and buf_utd-marking-lines.doc-id = buf_utd-lines.doc-id
                                               and buf_utd-marking-lines.LineNum = buf_utd-lines.LineNum,
      first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark
                                               break by  buf_utd-marking-lines.doc-id :
        if CheckErrForMarkLine(buffer buf_utd-marking-lines:handle)
        then
          next marks_ .
        if v-num-marks = 999
        then do :
          lastLineCisInfo = buf_utd-lines.LineNum .
          leave lines_ .
        end .
        if needCheckUnit
        then do :
          if buf_marking.unit-ext = "UNIT"
          and buf_marking.sts = objSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB
          then do : end .
          else
            next marks_ .
        end .
        else do :
          if pLevel2 and buf_marking.unit-ext <> "LEVEL2" then next marks_ .
          if not pLevel2 and buf_marking.unit-ext = "LEVEL2" then next marks_ .
          if checkINN and buf_marking.sts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB then next marks_ .
          if buf_marking.unit-ext = "UNIT"
          then do :
            find first buf_marking-parent no-lock where buf_marking-parent.mark = buf_marking.mark-parent
                                                    and (buf_marking-parent.sts  = objSrv:Env:Marking:Sts:Mark:CheckContr:KeyIntDB
                                                       or buf_marking-parent.sts = objSrv:Env:Marking:Sts:Mark:DeliveryControl:KeyIntDB)
                                                    no-error .
            if available buf_marking-parent then next marks_ .
          end .
        end .
        vMark = buf_utd-marking-lines.mark .
        vMark = replace(vMark, '\', '\\') .
        vMark = replace(vMark, '/', '\/') .
        vMark = replace(vMark, '"', '\"') .
        put stream sLog unformatted '"' vMark '"' .
        v-num-marks = v-num-marks + 1 .
        put stream sLog unformatted ',' skip .
      end .
    end .
    put stream sLog unformatted '""' skip .
    put stream sLog unformatted skip "]" skip.
    output stream sLog close .
    if v-num-marks <> 999 then lastLineCisInfo = 0 .
    needCheckUnit = no .
    if v-num-marks = 0
    then do :
      return .
    end .
    putcisesInfo (vfilereq + " (out-data):" ) .
    if isDebug
    then
      os-append value(vfilereq) value(mFilecisesInfo) .
    vFileToken     = "IsMotp_token_db" + string(DB-num) + ".txt".
    output stream sLog to value(vFileToken) .
      put stream sLog unformatted "Authorization: Bearer " pToken .
    output stream sLog close .
    define variable vCmdToken as character no-undo.
    if pToken > ""
    then
       vCmdToken = substitute (' -H @&1', searchfile (vFileToken)).
    define variable vfileresult as character no-undo.
    define variable vfileresulterr as character no-undo.
    vfileresult    = "IsMotp_cisesInfoResp_db" + string(DB-num) + ".json".
    vfileresulterr = "IsMotp_cisesInfoResp_db" + string(DB-num) + ".err".
    os-delete value (searchFile(vfileresult)) no-error .
    if searchFile(vfileresult) = ?
    then do : end .
    else do :
      v-ok = false .
      Msg = "Запрос не выполнен! Не могу удалить файл-ответ " + vfileresult .
      return .
    end .
    cmd = substitute ('&1 &8 -H "Content-Type: application/json" &5 &6 -d @&4 --stderr &7 &3/cises/info >&2',
                      search ("exe/curl.exe"),
                      vfileresult,
                      server_,
                      searchfile (vfilereq),
                      vCmdToken,
                      CmdParamProxy,
                      vfileresulterr,
                      addCurlKeys).
    cmdlog = substitute ('&1 &8 -H "Content-Type: application/json" &5 &6 -d @&4 --stderr &7 &3/cises/info >&2',
                      search ("exe/curl.exe"),
                      vfileresult,
                      server_,
                      searchfile (vfilereq),
                      vCmdToken,
                      CmdParamProxylog,
                      vfileresulterr,
                      addCurlKeys).
    putcisesInfo (" command:" ).
    putcisesInfo ( cmdlog ) .
    os-command silent value (cmd) .
    if searchFile(vfileresult) = ?
    then do :
      v-ok = false .
      MSG = "Запрос не выполнен! Нет ответа от МОТП. Не могу найти файл " + search(vfileresult) .
      return .
    end .
    file-info:file-name = searchFile(vfileresult) .
    if file-info:file-size = 0
    then do :
      v-ok = false .
      MSG = "Запрос не выполнен! Файл-ответ из МОТП " + search(vfileresult) + " пустой (размер 0 байт)." .
      return .
    end .
    copy-lob from file vfileresult to vlongJson .
    vlongJson = replace(vlongJson, "&lt;", "###lo-then###") .
    vlongJson = replace(vlongJson, "&Lt;", "###LO-then###") .
    vlongJson = replace(vlongJson, "&lT;", "###lo-THEN###") .
    vlongJson = replace(vlongJson, "&LT;", "###LO-THEN###") .
    vlongJson = replace(vlongJson, "&gt;", "###gr-then###") .
    vlongJson = replace(vlongJson, "&Gt;", "###GR-then###") .
    vlongJson = replace(vlongJson, "&gT;", "###gr-THEN###") .
    vlongJson = replace(vlongJson, "&GT;", "###GR-THEN###") .
    vlongJson = replace(vlongJson, "&", "&amp;") .
    vlongJson = replace(vlongJson, "<", "&lt;") .
    vlongJson = replace(vlongJson, ">", "&gt;") .
    vlongJson = replace(vlongJson, ':null', ':""') .
    vlongJson = replace(vlongJson, (':' + CHR(91) + CHR(123) + CHR(125) + CHR(93)), ':""') .
    copy-lob from vlongJson to file vfileresult .
    putcisesInfo ( vfileresult + " (in-data):") .
    if isDebug
    then
      os-append value(vfileresult) value(mFilecisesInfo) .
    define variable vfileresultxml as character no-undo.
    vfileresultxml = "IsMotp_cisesInfoResp_db" + string(DB-num) + ".xml".
    os-delete value (searchFile(vfileresultxml)) no-error .
    if searchFile(vfileresultxml) = ?
    then do : end .
    else do :
      v-ok = false .
      Msg = "Запрос не выполнен! Не могу удалить сконвертированный в xml файл-ответ " + vfileresultxml .
      return .
    end .
    cmd = substitute ('&1 -file=&2 >&3',
                       search("exe/json2xml.exe"),
                       searchfile(vfileresult),
                       vfileresultxml
                       ) .
    os-command silent value (cmd).
    file-info:file-name = search(vfileresultxml) .
    if file-info:file-size = 0
    then do :
      v-ok = false .
      MSG = "Запрос не выполнен! Ошибка при конвертации json в XML. Файл " + search(vfileresultxml) + " пустой (размер 0 байт)." .
      return .
    end .
    empty temp-table tt-childs .
    Doc-Id = pDoc-id .
    docdb-num = pDB-num .
    ParseResponseInfoCises(searchfile(vfileresultxml)) .
    Doc-Id = ? .
    docdb-num = ? .
    if Msg = "empty_file"
    then do :
      v-ok = false .
      MSG = "Запрос не выполнен! Файл " + search(vfileresultxml) + " пустой (размер 0 байт)." .
      return .
    end .
    if BadAuth
    then do :
      v-ok = false .
      MSG = "Запрос не выполнен! Авторизация не пройдена. Попробуйте запросить новый токен." .
      return .
    end .
  end method .
  define variable v-cis as character case-sensitive no-undo .
  define variable v-cis-child as character case-sensitive no-undo .
  define variable v-unit as character no-undo .
  define variable v-unit-child as character no-undo .
  define variable v-gtin as character no-undo .
  define variable v-num-childs as integer no-undo .
  define variable v-must-be-childs as integer no-undo .
  define variable v-err-childs as logical no-undo .
  define variable v-gray-zone  as logical no-undo .
  define buffer bf_marking for ub.marking .
  define buffer bf_prod-bc for ub.prod-bc .
  define buffer bf_bar-code for ub.bar-code .
  define buffer bf2_bar-code for ub.bar-code .
  define buffer bf_goods-attr for ub.goods-attr.
  define variable cis-found-bc as logical no-undo .
  define variable cisGtin as character no-undo .
  define variable cisGdsCode as integer no-undo .
  define variable v-mark-type  as character no-undo .
  method private void ParseResponseInfoCises(inFileName as char):
    define variable hDoc  as handle no-undo .
    define variable hRoot as handle no-undo .
    create x-document hDoc.
    create x-noderef hRoot.
    hDoc:load("file", inFileName, false) no-error.
    if inFileName = ? then
    do:
      Msg = "empty_file" .
      return .
    end.
    INNchecked = false .
    BadAuth = false .
    hDoc:get-document-element(hRoot).
    GetChildrenInfoCises(hRoot, 1).
    delete object hDoc.
    delete object hRoot.
  end.
  method private void GetChildrenInfoCises(hParent as handle, level as integer):
    define variable i           as integer no-undo .
    define variable hNoderef    as handle  no-undo .
    define variable hText       as handle  no-undo .
    define variable tt          as integer no-undo .
    define variable good        as logical   no-undo .
    define variable v-item      as character no-undo .
    define variable v-err-code  as integer no-undo .
    define variable v-text      as character no-undo .
    tt = hParent:num-children no-error .
    if tt = ? then
    do:
      Msg = "Ошибка запроса. См. в файле ответа" .
      return .
    end.
    create x-noderef hNoderef.
    create x-noderef hText .
    repeat i = 1 to hParent:num-children:
      good = hParent:get-child(hNoderef,i).
      if not good
      then leave .
      if hNoderef:name = "cisinfo" then
      do:
        assign
          v-num-childs = 0
          v-err-childs = false
          v-gray-zone  = false
          v-err-code   = 0
          v-item       = ""
          v-cis        = ""
          v-gtin       = ""
          v-cis-child  = ""
          v-unit       = ""
          v-unit-child = ""
        .
      end .
      if hNoderef:subtype <> "element" then
        next.
      hNoderef:get-child(hText, 1) no-error .
      assign
        v-text = hText:node-value
      no-error .
      if v-text = ""
      or v-text = ?
      then next .
      if hNoderef:name = "child" then
      do:
        assign
          v-cis-child = hText:node-value
        no-error .
        v-cis-child = repSpecSimbforDm(v-cis-child) .
        v-cis-child = replace(v-cis-child, "###lo-then###", "&lt;") .
        v-cis-child = replace(v-cis-child, "###LO-then###", "&Lt;") .
        v-cis-child = replace(v-cis-child, "###lo-THEN###", "&lT;") .
        v-cis-child = replace(v-cis-child, "###LO-THEN###", "&LT;") .
        v-cis-child = replace(v-cis-child, "###gr-then###", "&gt;") .
        v-cis-child = replace(v-cis-child, "###GR-then###", "&Gt;") .
        v-cis-child = replace(v-cis-child, "###gr-THEN###", "&gT;") .
        v-cis-child = replace(v-cis-child, "###GR-THEN###", "&GT;") .
        v-cis-child = replace(v-cis-child, '\\', '\') .
        v-cis-child = replace(v-cis-child, '\/', '/') .
        v-cis-child = replace(v-cis-child, '\"', '"') .
        create tt-childs .
        assign tt-childs.mark    = v-cis-child .
        assign tt-childs.parent_ = "temp" .
      end .
      if hNoderef:name = "gtin" then
      do:
        v-item = "gtin" .
        v-gtin = hText:node-value no-error .
      end .
      if hNoderef:name = "cis" then
      do:
        v-item = "cis" .
        v-unit = "" .
        v-unit-child = "" .
        MSG = "" .
        assign
          v-cis = hText:node-value
        no-error .
        v-cis = repSpecSimbforDm(v-cis) .
        v-cis = replace(v-cis, "###lo-then###", "&lt;") .
        v-cis = replace(v-cis, "###LO-then###", "&Lt;") .
        v-cis = replace(v-cis, "###lo-THEN###", "&lT;") .
        v-cis = replace(v-cis, "###LO-THEN###", "&LT;") .
        v-cis = replace(v-cis, "###gr-then###", "&gt;") .
        v-cis = replace(v-cis, "###GR-then###", "&Gt;") .
        v-cis = replace(v-cis, "###gr-THEN###", "&gT;") .
        v-cis = replace(v-cis, "###GR-THEN###", "&GT;") .
        v-cis = replace(v-cis, '\\', '\') .
        v-cis = replace(v-cis, '\/', '/') .
        v-cis = replace(v-cis, '\"', '"') .
        if trim(v-cis) = "" or v-cis = ? then next .
        for each tt-childs exclusive-lock where tt-childs.parent_ = "temp" :
          assign tt-childs.parent_ = v-cis .
        end.
      end .
      if hNoderef:name = "packageType" then
      do:
        v-item = "packageType" .
        assign v-unit = hText:node-value no-error .
        case v-unit :
          when "LEVEL1" then v-unit-child = "UNIT" .
          when "LEVEL2" then v-unit-child = "LEVEL1" .
          when "LEVEL3" then v-unit-child = "LEVEL2" .
          when "LEVEL4" then v-unit-child = "LEVEL3" .
          when "LEVEL5" then v-unit-child = "LEVEL4" .
        end case .
      end .
      if hNoderef:name = "ownerinn"
      and checkINN
      and INN > ""
      then do :
        v-item = "ownerinn" .
        INNchecked = false .
        if INN = hText:node-value
        then do :
          INNchecked = true .
          updateUtdStatus(input docDB-num, input Doc-Id, input ObjSrv:Env:Utd:Sts:TH:Confirmed:KeyIntDB) .
          return .
        end .
      end .
      if hNoderef:name = "status"
      and trim(v-cis) > ""
      then do:
        for each tt-childs no-lock where tt-childs.parent_ = v-cis :
          assign v-num-childs = v-num-childs + 1 .
        end .
        find first bf_marking no-lock where bf_marking.mark begins v-cis no-error .
        if not available bf_marking
        or (available bf_marking
            and bf_marking.gds-code = ?)
        then do :
          cisGdsCode = getGdsCodeByGtin(v-gtin) .
        end .
        else do :
          cisGdsCode = bf_marking.gds-code .
        end .
        v-mark-type = "" .
        for first bf_goods-attr no-lock where bf_goods-attr.attr-code = 'mark-type':U
                                          and bf_goods-attr.gds-code = cisGdsCode
                                          :
          v-mark-type = bf_goods-attr.attr-value .
        end .
        if v-unit = "LEVEL2"
        then do :
          if cisGdsCode > 0
          then do :
            v-must-be-childs = 50 .
            find first bf_bar-code no-lock where bf_bar-code.gds-code = cisGdsCode
                                             and bf_bar-code.unit-cli = "кор"
                                             and bf_bar-code.stts_ = 0
            no-error .
            if available bf_bar-code
            then do :
              v-must-be-childs = bf_bar-code.cli-base-rate .
              find first bf2_bar-code no-lock where bf2_bar-code.gds-code = cisGdsCode
                                                and bf2_bar-code.unit-cli = "бл"
                                                and bf2_bar-code.stts_ = 0
              no-error .
              if available bf2_bar-code
              then do :
                v-must-be-childs = v-must-be-childs / bf2_bar-code.cli-base-rate .
              end .
              else do :
                MSG = "Для товара с кодом " + string(cisGdsCode) + " не найден код с ед. изм. 'бл'" .
                v-err-childs = true .
              end .
            end .
            else do :
              MSG = "Для товара с кодом " + string(cisGdsCode) + " не найден код с ед. изм. 'кор'" .
              v-err-childs = true .
            end .
            if not v-err-childs
            then do :
              if isFirstEnter
              then do :
                if v-num-childs <> v-must-be-childs then v-err-childs = true .
              end .
              else do :
                if v-mark-type = "tabak"
                or v-mark-type = "stiki"
                then do :
                  if v-num-childs <> v-must-be-childs
                  then do:
                    if GrayZoneQnty = 100
                    then do :
                      v-gray-zone = true .
                    end .
                    else do :
                      if (v-must-be-childs - v-num-childs) <= GrayZoneQnty
                      then v-gray-zone = true .
                      else v-err-childs = true .
                    end .
                  end .
                end .
                else do :
                  if v-num-childs <> v-must-be-childs then v-err-childs = true .
                end .
              end .
              if v-err-childs
              then do :
                MSG = "В коробе " + string(v-num-childs) + " блоков." .
              end .
            end .
          end .
        end .
        if v-unit = "LEVEL1"
        or v-unit = "GROUP"
        then do :
          if cisGdsCode > 0
          then do :
            if available bf_marking
            and bf_marking.gds-ext-id > ""
            then do :
              cisGtin = bf_marking.gds-ext-id .
            end .
            else do :
              cisGtin = v-gtin .
            end .
            v-must-be-childs = 10 .
            find first bf_bar-code no-lock where bf_bar-code.gds-code = cisGdsCode
                                            and bf_bar-code.unit-cli = "бл"
                                            and bf_bar-code.stts_ = 0
            no-error .
            if available bf_bar-code
            then do :
              v-must-be-childs = bf_bar-code.cli-base-rate .
            end .
            else do :
              MSG = "Для товара с кодом " + string(cisGdsCode) + " не найден код с ед. изм. 'бл'" .
              v-err-childs = true .
            end .
            if not v-err-childs
            then do :
              if isFirstEnter
              then do :
                if v-num-childs <> v-must-be-childs then v-err-childs = true .
              end .
              else do :
                if v-mark-type = "tabak"
                or v-mark-type = "stiki"
                then do :
                  if v-num-childs <> v-must-be-childs and GrayZoneQnty <> 100
                  then do:
                    if (v-must-be-childs - v-num-childs) <= GrayZoneQnty
                    then v-gray-zone = true .
                    else v-err-childs = true .
                  end .
                end .
                else do :
                  if v-num-childs <> v-must-be-childs then v-err-childs = true .
                end .
              end .
              if v-err-childs
              then do :
                MSG = "В блоке " + string(v-num-childs) + " пачек." .
              end .
            end .
          end .
        end .
        if isFirstEnter
        then do :
          if hText:node-value = "DISAGGREGATED"
          and v-unit = "LEVEL1"
          then do :
            UpdateMark(v-cis,
                       if isFirstEnter then objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB else objSrv:Env:Marking:Sts:Mark:CheckContr:KeyIntDB,
                       "",
                       v-unit,
                       v-gtin,
                       hText:node-value) .
            for each tt-childs no-lock where tt-childs.parent_ = v-cis :
              UpdateMark(tt-childs.mark,
                         if isFirstEnter then objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB else objSrv:Env:Marking:Sts:Mark:CheckContr:KeyIntDB,
                         v-cis,
                         v-unit-child,
                         v-gtin,
                         hText:node-value) .
            end .
          end .
          else do :
            if v-err-childs
            then do :
              UpdateMark(v-cis,
                         objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB,
                         "",
                         v-unit,
                         v-gtin,
                         hText:node-value) .
            end .
            else do :
              UpdateMark(v-cis,
                         objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB,
                         "",
                         v-unit,
                         v-gtin,
                         hText:node-value) .
            end .
            for each tt-childs no-lock where tt-childs.parent_ = v-cis :
              UpdateMark(tt-childs.mark,
                         objSrv:Env:Marking:Sts:Mark:Checked_:KeyIntDB,
                         v-cis,
                         v-unit-child,
                         v-gtin,
                         hText:node-value) .
            end .
          end .
        end .
        else do :
          case hText:node-value :
            when "APPLIED" or
            when "INTRODUCED" or
            when "INTRODUCED_RETURNED"
            then do :
              if v-err-childs
              then do :
                UpdateMark(v-cis,
                           objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB,
                           "",
                           v-unit,
                           v-gtin,
                           hText:node-value) .
              end .
              else
              if v-gray-zone
              then do :
                UpdateMark(v-cis,
                           objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB,
                           "",
                           v-unit,
                           v-gtin,
                           hText:node-value) .
              end .
              else do :
                UpdateMark(v-cis,
                           objSrv:Env:Marking:Sts:Mark:CheckContr:KeyIntDB,
                           "",
                           v-unit,
                           v-gtin,
                           hText:node-value) .
              end .
              if v-mark-type = "tabak"
              or v-mark-type = "stiki"
              then do :
                for each tt-childs no-lock where tt-childs.parent_ = v-cis :
                  UpdateMark(tt-childs.mark,
                             objSrv:Env:Marking:Sts:Mark:CheckContr:KeyIntDB,
                             v-cis,
                             v-unit-child,
                             v-gtin,
                             hText:node-value) .
                end .
              end .
              else do :
                for each tt-childs no-lock where tt-childs.parent_ = v-cis :
                  UpdateMark(tt-childs.mark,
                             if v-err-childs then objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB else objSrv:Env:Marking:Sts:Mark:CheckContr:KeyIntDB,
                             v-cis,
                             v-unit-child,
                             v-gtin,
                             hText:node-value) .
                end .
              end .
            end .
            when "DISAGGREGATED"
            then do :
              UpdateMark(v-cis,
                         objSrv:Env:Marking:Sts:Mark:Ungrouped:KeyIntDB,
                         "",
                         v-unit,
                         v-gtin,
                         hText:node-value) .
              for each tt-childs no-lock where tt-childs.parent_ = v-cis :
                needCheckUnit = yes .
                UpdateMark(tt-childs.mark,
                           objSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB,
                           v-cis,
                           v-unit-child,
                           v-gtin,
                           "") .
              end .
            end .
            otherwise do :
              MSG = "Статус марки в МОТП - " + hText:node-value .
              UpdateMark(v-cis, objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB, "", v-unit, v-gtin, hText:node-value) .
              for each tt-childs no-lock where tt-childs.parent_ = v-cis :
                UpdateMark(tt-childs.mark, objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB, v-cis, v-unit-child, v-gtin, hText:node-value) .
              end .
            end .
          end case .
        end .
      end .
      if hNoderef:name = "errormessage" then
      do:
        if trim(v-cis) = ""
        or v-cis = ?
        then next .
        v-item = "errormessage" .
        MSG = hText:node-value .
        if v-err-code = 404
        then do :
          UpdateMark(v-cis, objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB, "", v-unit, v-gtin, "") .
        end .
      end .
      if hNoderef:name = "errorCode" then
      do:
        BadAuth = false .
        if integer(hText:node-value) = 401
        then do :
          BadAuth = true .
          return .
        end .
        if trim(v-cis) = ""
        or v-cis = ?
        then next .
        v-item = "errorCode" .
        v-err-code = integer(hText:node-value) no-error .
      end .
      if hNoderef:name = "error_message" then
      do:
        if hText:node-value = "Для доступа к этому ресурсу требуется полная аутентификация"
        then do :
          BadAuth = true .
          return .
        end .
      end .
      if INNchecked then return .
      if BadAuth then return .
      GetChildrenInfoCises(hNoderef, (level + 1)) .
      if INNchecked then return .
      if BadAuth then return .
    end.
    delete object hNoderef.
    delete object hText.
  end method .
  method private void UpdateMark
  (
  input pMark as character,
  input pSts as integer,
  input pParent as character,
  input pUnit as character,
  input pGtin as character,
  input pMOTPsts as character
  ) :
    define buffer buf_utd for ub.utd .
    define buffer buf_marking for ub.marking .
    define buffer buf_marking-attr for ub.marking-attr .
    define buffer buf_marking-parent for ub.marking .
    define buffer buf_utd-marking-lines for ub.utd-marking-lines .
    define buffer buf_utd-marking-lines-parent for ub.utd-marking-lines .
    define buffer buf_prod-bc for ub.prod-bc .
    define buffer buf_bar-code for ub.bar-code .
    define variable v-found-bc as logical no-undo .
    define variable vGtin as character no-undo .
    define variable vMarkType as character no-undo .
    if checkINN then return .
    if pMark = ?
    or trim(pMark) = ""
    then return .
    find first buf_utd no-lock where buf_utd.db-num = docDB-num
                                 and buf_utd.doc-id = Doc-id
                                 no-error .
    find first buf_marking exclusive-lock where buf_marking.mark begins pMark no-error .
    if not available buf_marking
    then do :
      find first buf_marking-parent no-lock where buf_marking-parent.mark begins pParent and pParent <> "" no-error .
      create buf_marking .
      assign
        buf_marking.mark = pMark
        buf_marking.unit-ext = pUnit when pUnit <> ""
      .
      if available buf_utd
      then
      assign
        buf_marking.obj-type = buf_utd.obj-type
        buf_marking.obj-code = buf_utd.obj-code
      .
      buf_marking.box-qnty = ? .
      if available buf_marking-parent
      then do :
        assign
          buf_marking.mark-parent = buf_marking-parent.mark
          buf_marking.gds-code    = buf_marking-parent.gds-code
          buf_marking.gds-ext-id  = buf_marking-parent.gds-ext-id
        .
      end .
    end .
    assign
      buf_marking.sts = pSts
      buf_marking.unit-ext = pUnit when pUnit <> ""
    .
    if pUnit = "LEVEL2"
    and not Level2
    then do :
      foundLevel2 = yes .
    end .
    if (buf_marking.gds-code = 0
     or buf_marking.gds-code = ?)
    and pGtin > ""
    then do :
      buf_marking.gds-code = getGdsCodeByGtin(pGtin) .
      find first buf_utd-marking-lines where buf_utd-marking-lines.db-num eq buf_utd.db-num
                                         and buf_utd-marking-lines.doc-id eq buf_utd.doc-id
                                         and buf_utd-marking-lines.mark   eq buf_marking.mark
      exclusive-lock no-error.
      if available buf_utd-marking-lines
      then do :
        buf_utd-marking-lines.gds-code = buf_marking.gds-code .
      end .
    end .
    find first buf_marking-parent no-lock where buf_marking-parent.mark = buf_marking.mark-parent and buf_marking.mark-parent <> "" no-error .
    if available buf_marking-parent
    and (buf_marking.gds-code = 0
      or buf_marking.gds-code = ?)
    then do :
      assign
        buf_marking.gds-code    = buf_marking-parent.gds-code
      .
    end .
    if buf_marking.box-qnty <= 0
    or buf_marking.box-qnty = ?
    then do :
      case pUnit :
        when "UNIT"
        then do :
          buf_marking.box-qnty = 1 .
        end .
        when "LEVEL1"
        then do :
          for first buf_bar-code no-lock where buf_bar-code.gds-code = buf_marking.gds-code
                                           and buf_bar-code.unit-cli = "блк"
                                           and buf_bar-code.stts_ = 0
          :
            buf_marking.box-qnty = buf_bar-code.cli-base-rate .
          end .
        end .
        when "LEVEL2"
        then do :
          for first buf_bar-code no-lock where buf_bar-code.gds-code = buf_marking.gds-code
                                           and buf_bar-code.unit-cli = "кор"
                                           and buf_bar-code.stts_ = 0
          :
            buf_marking.box-qnty = buf_bar-code.cli-base-rate .
          end .
        end .
      end case .
    end .
    if pMOTPsts > ""
    then do :
      find first buf_marking-attr exclusive-lock where buf_marking-attr.mark = buf_marking.mark
                                                   and buf_marking-attr.attr-code = "MOTPsts"
                                                   no-error .
      if not available buf_marking-attr
      then do :
        create buf_marking-attr .
        assign
          buf_marking-attr.mark = buf_marking.mark
          buf_marking-attr.attr-code = "MOTPsts"
        .
      end .
      assign
        buf_marking-attr.attr-value = pMOTPsts
      .
    end .
    if trim(buf_marking.gds-ext-id) = ""
    and pGtin > ""
    then do :
      assign
        buf_marking.gds-ext-id = pGtin
      .
    end .
    if trim(pGtin) > ""
    and buf_marking.gds-code <> ?
    and buf_marking.gds-code <> 0
    then do :
      if buf_marking.unit-ext = "UNIT"
      then do :
        assign
          v-found-bc = false .
        .
        for each buf_bar-code no-lock where buf_bar-code.gds-code = buf_marking.gds-code,
        each buf_prod-bc no-lock where buf_prod-bc.b-code = buf_bar-code.b-code
                                   and buf_prod-bc.b-str  = pGtin
                                   :
          assign
            v-found-bc = true .
          .
          leave .
        end .
        if not v-found-bc
        then do :
          run utl/upd-gtin.p (input docDB-num,
                              input buf_marking.gds-code,
                              input pGtin,
                              input (docDB-num = gbl-var:g#db-num))
                              no-error .
          if error-status:error
          then do :
          end .
        end .
      end .
      if buf_marking.unit-ext = "LEVEL1"
      then do :
        assign
          v-found-bc = false .
        .
        vGtin = getGtinByDM(buf_marking.mark) .
        find first buf_bar-code no-lock where buf_bar-code.gds-code = buf_marking.gds-code
                                          and buf_bar-code.cli-base-rate = buf_marking.box-qnty
                                          no-error .
        if available buf_bar-code
        then do :
          for each buf_prod-bc no-lock where buf_prod-bc.b-code = buf_bar-code.b-code
                                         and buf_prod-bc.b-str  = vGtin :
            assign
              v-found-bc = true .
            .
            leave .
          end .
          if not v-found-bc
          then do :
            run utl/upd-gtin.p (input docDB-num,
                                input buf_bar-code.b-code,
                                input vGtin,
                                input (docDB-num = gbl-var:g#db-num))
                                no-error .
            if error-status:error
            then do :
            end .
          end .
        end .
      end .
    end .
    if pSts = objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
    then do :
      assign buf_marking.comment = MSG .
      find first buf_utd-marking-lines where buf_utd-marking-lines.db-num eq buf_utd.db-num
                                         and buf_utd-marking-lines.doc-id eq buf_utd.doc-id
                                         and buf_utd-marking-lines.mark   eq buf_marking.mark
      no-lock no-error.
      AddUtdErr(buf_utd.db-num,
                buf_utd.doc-id,
                if available buf_utd-marking-lines
                then buffer buf_utd-marking-lines:handle
                else buffer buf_marking:handle,
                "CheckMOTP",
                "MotpMarkErr",
                (buf_marking.mark + chr(4) + MSG)).
      if buf_marking.unit-ext <> "UNIT" and buf_utd.EDocType = objSrv:Env:Utd:EDocType:Introduce:KeyIntDB then
      do:
        buf_marking.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB .
        buf_marking.unit = getLevelUTDByCodId(buf_marking.mark) .
      end.
      if buf_utd.EDocType <> objSrv:Env:Utd:EDocType:Introduce:KeyIntDB
      then do :
        if buf_marking.unit-ext = "LEVEL1"
        and buf_marking.mark-parent <> ""
        then do :
          vMarkType = "" .
          for first bf_goods-attr no-lock where bf_goods-attr.attr-code = 'mark-type':U
                                            and bf_goods-attr.gds-code = cisGdsCode
                                            :
            vMarkType = bf_goods-attr.attr-value .
          end .
          if vMarkType = "tabak"
          or vMarkType = "stiki"
          then do :
          end .
          else do :
            find first buf_marking-parent exclusive-lock where buf_marking-parent.mark = buf_marking.mark-parent no-error .
            if available buf_marking-parent
            then do :
              if buf_marking-parent.unit-ext = "LEVEL2"
              and buf_marking-parent.sts <> objSrv:Env:Marking:Sts:Mark:MarkError:KeyIntDB
              then do :
                buf_marking-parent.sts = objSrv:Env:Marking:Sts:Mark:GrayZone:KeyIntDB .
              end .
              release buf_marking-parent no-error .
            end .
          end .
        end .
      end .
    end .
    if pParent <> ""
    then do :
      find first buf_utd-marking-lines exclusive-lock where buf_utd-marking-lines.mark begins pMark
                                                        and buf_utd-marking-lines.db-num = docDB-num
                                                        and buf_utd-marking-lines.doc-id = Doc-Id no-error .
      if not available buf_utd-marking-lines
      then do :
        find first buf_utd-marking-lines-parent no-lock where buf_utd-marking-lines-parent.mark begins pParent
                                                      and buf_utd-marking-lines-parent.db-num = docDB-num
                                                      and buf_utd-marking-lines-parent.doc-id = Doc-Id no-error .
        create buf_utd-marking-lines .
        if available buf_utd-marking-lines-parent
        then do :
          buffer-copy buf_utd-marking-lines-parent to buf_utd-marking-lines
          assign
            buf_utd-marking-lines.mark = pMark
            buf_utd-marking-lines.doc-level = buf_utd-marking-lines-parent.doc-level + 1
          .
        end .
        else do :
          assign
            buf_utd-marking-lines.mark = pMark
            buf_utd-marking-lines.db-num = docDB-num
            buf_utd-marking-lines.doc-id = Doc-Id
            buf_utd-marking-lines.doc-level = 1
          .
        end .
      end .
    end .
  end method .
  method public logical CheckStatus
  (
  input pDb-num as integer,
  input pDoc-id as integer
  ) :
    define buffer buf_utd for ub.utd .
    define buffer buf_marking for ub.marking .
    define buffer buf_utd-marking-lines for ub.utd-marking-lines .
    define variable v-ok      as logical no-undo .
    define variable v-not-checked as logical no-undo .
    assign v-not-checked = false .
    for each buf_utd-marking-lines no-lock where  buf_utd-marking-lines.db-num = pDb-num
                                              and buf_utd-marking-lines.doc-id = pDoc-id,
    first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark :
      if buf_marking.sts = objSrv:Env:Marking:Sts:Mark:PendingVerification:KeyIntDB
      then do :
        assign v-not-checked = true .
        leave .
      end .
    end .
    if v-not-checked then return false .
    assign v-ok = true .
    for each buf_utd-marking-lines no-lock where  buf_utd-marking-lines.db-num = pDb-num
                                              and buf_utd-marking-lines.doc-id = pDoc-id,
    first buf_marking no-lock where buf_marking.mark = buf_utd-marking-lines.mark :
      if buf_marking.sts <> objSrv:Env:Marking:Sts:Mark:CheckContr:KeyIntDB
      then do :
        assign v-ok = false .
        leave .
      end .
    end .
    if not v-ok
    then do :
      for first buf_utd exclusive-lock where buf_utd.db-num = pDb-num
                                         and buf_utd.doc-id = pDoc-id :
        assign
          buf_utd.sts = objSrv:Env:Utd:Sts:TH:LackOfMarkingCodesInCirculation:KeyIntDB
        .
      end.
    end .
    else do :
      for first buf_utd exclusive-lock where buf_utd.db-num = pDb-num
                                         and buf_utd.doc-id = pDoc-id :
        assign
          buf_utd.sts = objSrv:Env:Utd:Sts:TH:VerificationPassed:KeyIntDB
        .
      end.
    end .
    return true .
  end method .
  method public void CheckSpec
  (
  input pDb-num as integer,
  input pDoc-id as integer
  ) :
    run utl/utd-checkSpec.p (input pDb-num,
                             input pDoc-id) .
  end method .
  method public void checkUtd
  (
  input pToken  as character,
  input pDb-num as integer,
  input pDoc-id as integer
  ) :
    define buffer buf_utd for ub.utd .
    define buffer buf_utd-attr for ub.utd-attr .
    define variable v-ok            as logical no-undo .
    define variable cmd             as character no-undo .
    define variable v-out-file-name as character no-undo .
    define variable v-out-file-name-err as character no-undo .
    define variable v-doc-code      as character no-undo .
    define variable vlongJson       as longchar no-undo case-sensitive .
    define variable vFileToken  as character no-undo.
    Doc-Id = pDoc-id .
    db-num = pDB-num .
    assign v-ok = true .
    find first buf_utd no-lock where buf_utd.db-num = pDb-num
                                 and buf_utd.doc-id = pDoc-id
                                 no-error .
    if not available buf_utd
    then do :
      MSG = "Не найден УПД в БД " + string(pDb-num) + " c doc-id " + string(pDoc-id) .
      return error MSG .
    end.
    v-doc-code = buf_utd.DocumentExt .
    for first buf_utd-attr no-lock where buf_utd-attr.db-num    = buf_utd.db-num
                                     and buf_utd-attr.doc-id    = buf_utd.doc-id
                                     and buf_utd-attr.attr-code = "FileName"
                                     and buf_utd-attr.attr-value > ""
                                     :
      v-doc-code = buf_utd-attr.attr-value .
    end .
    v-out-file-name     = substitute("IsMotp_docinfo_&1.json", buf_utd.doc-id) .
    v-out-file-name-err = substitute("IsMotp_docinfo_&1.err", buf_utd.doc-id) .
    vFileToken = "IsMotp_token_db" + string(DB-num) + ".txt".
    output stream sLog to value(vFileToken) .
      put stream sLog unformatted "Authorization: Bearer " pToken .
    output stream sLog close .
    cmd = substitute ('&1 &8 -H @&5 &6 --stderr &7 &3/documents/&4/info >&2',
                      search ("exe/curl.exe"),
                      v-out-file-name,
                      server_,
                      v-doc-code,
                      searchfile(vFileToken),
                      CmdParamProxy,
                      v-out-file-name-err,
                      addCurlKeys).
    os-command silent value (cmd) .
    define variable vfile as character no-undo.
    vfile =  SearchFile(v-out-file-name).
    if vfile eq ?
    then do:
      MSG = "Нет ответа от ИС МОТП. Не найден " + v-out-file-name.
      putauth (MSG ).
    end.
    else do:
      file-info:file-name = vfile .
      if file-info:file-size = 0
      then do :
        MSG = "Нет ответа от ИС МОТП. Файл пустой " + vfile.
        putauth ( MSG ).
      end.
      else do:
        copy-lob from file vfile to vlongJson .
        vlongJson = replace(vlongJson, "&lt;", "###lo-then###") .
        vlongJson = replace(vlongJson, "&Lt;", "###LO-then###") .
        vlongJson = replace(vlongJson, "&lT;", "###lo-THEN###") .
        vlongJson = replace(vlongJson, "&LT;", "###LO-THEN###") .
        vlongJson = replace(vlongJson, "&gt;", "###gr-then###") .
        vlongJson = replace(vlongJson, "&Gt;", "###GR-then###") .
        vlongJson = replace(vlongJson, "&gT;", "###gr-THEN###") .
        vlongJson = replace(vlongJson, "&GT;", "###GR-THEN###") .
        vlongJson = replace(vlongJson, "&", "&amp;") .
        vlongJson = replace(vlongJson, "<", "&lt;") .
        vlongJson = replace(vlongJson, ">", "&gt;") .
        vlongJson = replace(vlongJson, ':null', ':""') .
        vlongJson = replace(vlongJson, (':' + CHR(91) + CHR(123) + CHR(125) + CHR(93)), ':""') .
        vlongJson = replace(vlongJson, (':' + CHR(91) + CHR(93)), ':""') .
        vlongJson = replace(vlongJson, ':""', ':" "') .
        copy-lob from vlongJson to file vfile .
        cmd = substitute ('&1 -file=&2 >&3',
                           search("exe/json2xml.exe"),
                           vfile,
                           ("IsMotp_" + string(buf_utd.doc-id) + ".xml")
                           ) .
        os-command silent value (cmd).
        ParseResponseInfoDoc(input ("IsMotp_" + string(buf_utd.doc-id) + ".xml")) .
      end.
    end.
  end method .
  method private void ParseResponseInfoDoc(inFileName as char):
    define variable hDoc  as handle no-undo .
    define variable hRoot as handle no-undo .
    create x-document hDoc.
    create x-noderef hRoot.
    hDoc:load("file", inFileName, false) no-error.
    if inFileName = ? then
    do:
      Msg = "Файл не найден" .
      return .
    end.
    hDoc:get-document-element(hRoot).
    GetChildrenInfoDoc(hRoot, 1).
    delete object hDoc.
    delete object hRoot.
  end.
  method private void GetChildrenInfoDoc(hParent as handle, level as integer):
    define variable i           as integer no-undo .
    define variable hNoderef    as handle  no-undo .
    define variable hText       as handle  no-undo .
    define variable tt          as integer no-undo .
    define variable good        as logical   no-undo .
    define variable v-error     as character no-undo .
    tt = hParent:num-children no-error .
    if tt = ? then
    do:
      Msg = "Ошибка запроса. См. в файле ответа" .
      return.
    end.
    create x-noderef hNoderef.
    create x-noderef hText .
    repeat i = 1 to hParent:num-children:
      good = hParent:get-child(hNoderef,i).
      if not good
      then leave .
      if hNoderef:subtype <> "element" then
        next.
      hNoderef:get-child(hText, 1) no-error .
      if error-status:error then
        next.
      hText:node-value no-error .
      if error-status:error then
        next.
      if hText:node-value = ? then
        next.
      if hNoderef:name = "status" then
      do:
        case hText:node-value :
          when "CHECKED_OK"
          then do :
            updateUtdStatus(input DB-num, input Doc-Id, input ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_Confirmed:KeyIntDB) .
          end .
          when "IN_PROGRESS"
          then do :
          end .
          otherwise do :
            updateUtdStatus(input DB-num, input Doc-Id, input ObjSrv:Env:Utd:Sts:TH:LK_RECEIPT_Error:KeyIntDB) .
          end .
        end case .
      end .
      if hNoderef:name = "errors" then
      do:
        v-error = hText:node-value .
        if trim(v-error) > ""
        and v-error <> "null"
        then do :
          define buffer buf_utd for ub.utd .
          find first buf_utd no-lock where buf_utd.db-num = Db-num
                                       and buf_utd.doc-id = Doc-id
                                       no-error .
          if available buf_utd
          then do :
            AddUtdErr(buf_utd.db-num,
                      buf_utd.doc-id,
                      buffer buf_utd:handle,
                      "CheckMOTP",
                      "LK_RECEIPT_Error",
                      v-error).
          end .
        end .
      end .
      GetChildrenInfoDoc(hNoderef, (level + 1)).
    end.
    delete object hNoderef.
    delete object hText.
  end method .
  method private logical updateUtdStatus
  (
  input pDb-num as integer,
  input pDoc-id as integer,
  input pSts    as integer
  ) :
    define variable p-ok as logical no-undo .
    define buffer buf_utd for ub.utd .
    assign p-ok = false .
    for first buf_utd exclusive-lock where buf_utd.db-num   = pDb-num
                                       and buf_utd.doc-id   = pDoc-id
                                       :
      assign
        buf_utd.sts = pSts
        p-ok = true
      .
    end .
    return p-ok .
  end method .
  method private logical updateUtdStatusUUID
  (
  input pDb-num as integer,
  input pDoc-id as integer,
  input pSts    as integer,
  input pUUID   as character
  ) :
    define variable p-ok as logical no-undo .
    define buffer buf_utd for ub.utd .
    assign p-ok = false .
    for first buf_utd exclusive-lock where buf_utd.db-num   = pDb-num
                                       and buf_utd.doc-id   = pDoc-id
                                       :
      assign
        buf_utd.sts = pSts
        buf_utd.DocumentExt = pUUID
        p-ok = true
      .
    end .
    return p-ok .
  end method .
  define stream cades .
  define stream auth .
  define stream authtest .
  define stream cisesInfo .
  define stream LK_RECEIPT .
  method public void putauth(input itext as character):
    if not isDebug then return .
    output stream auth to value (mFileauth) append .
    put stream auth unformatted now " " itext skip .
    output stream auth close .
  end.
  method public void putcades(input itext as character):
    if not isDebug then return .
    output stream cades to value (mFileCades) append .
    put stream cades unformatted now " " itext skip .
    output stream cades close .
  end.
  method public void putauthtest(input itext as character):
    if not isDebug then return .
    output stream authtest to value (mFileauthtest) append .
    put stream authtest unformatted now " " itext skip .
    output stream authtest close .
  end.
  method public void putcisesInfo(input itext as character):
    if not isDebug then return .
    output stream cisesInfo to value (mFilecisesInfo) append .
    put stream cisesInfo unformatted now " " itext skip .
    output stream cisesInfo close .
  end.
  method public void putLK_RECEIPT(input itext as character):
    if not isDebug then return .
    output stream LK_RECEIPT to value (mFileLK_RECEIPT) append .
    put stream LK_RECEIPT unformatted now " " itext skip .
    output stream LK_RECEIPT close .
  end.
def var vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
method public char getattrUtdEx
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-attr  then iExValue    else  utd-attr.attr-value.
end.
method public char getattrUtd
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character ):
  return getattrUtdex(idb-num,idoc-id,iattrcode,?).
end.
method public void setattrUtd
(idb-num   as integer,
 idoc-id   as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-attr for utd-attr.
   find first utd-attr where utd-attr.db-num eq idb-num
                         and utd-attr.doc-id eq idoc-id
                         and utd-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-attr
   then do:
      create utd-attr.
      assign
         utd-attr.db-num    = idb-num
         utd-attr.doc-id    = idoc-id
         utd-attr.attr-code = iattrcode
         utd-attr.attr-value = iattrval
      .
   end.
   else do:
      if utd-attr.attr-value ne iattrval
      then do:
         find current utd-attr exclusive-lock no-error.
         if available utd-attr
         then
            utd-attr.attr-value = iattrval.
      end.
   end.
   release utd-attr.
end.
method public char GetAttrUtdlinesEx
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-lines-attr  then iExValue    else  utd-lines-attr.attr-value.
end.
method public char GetAttrUtdlines
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character ):
   return GetAttrUtdlinesex (idb-num,idoc-id,ilinenum,iattrcode,?).
end.
method public void setattrUtdlines
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-lines-attr for utd-lines-attr.
   find first utd-lines-attr where utd-lines-attr.db-num    eq idb-num
                               and utd-lines-attr.doc-id    eq idoc-id
                               and utd-lines-attr.lineNum   eq ilineNum
                               and utd-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-lines-attr.
         assign
            utd-lines-attr.db-num    = idb-num
            utd-lines-attr.doc-id    = idoc-id
            utd-lines-attr.lineNum   = ilineNum
            utd-lines-attr.attr-code = iattrcode
            utd-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-lines-attr.attr-value ne iattrval
      then do:
         find current utd-lines-attr exclusive-lock no-error.
         if available utd-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-lines-attr.
            end.
            else do:
               utd-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-lines-attr.
end.
method public char GetAttrUtdMarkingLinesEx
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iExValue  as character  ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   return if not available utd-marking-lines-attr  then iExValue    else  utd-marking-lines-attr.attr-value.
end.
method public char GetAttrUtdMarkingLines
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character ):
   return GetAttrUtdMarkingLinesEx (idb-num,idoc-id,ilinenum,imark,iattrcode,?).
end.
method public void setattrUtdMarkingLines
(idb-num   as integer,
 idoc-id   as integer,
 ilinenum  as integer,
 imark     as character,
 iattrcode as character,
 iattrval  as character ):
   define buffer utd-marking-lines-attr for utd-marking-lines-attr.
   find first utd-marking-lines-attr where utd-marking-lines-attr.db-num    eq idb-num
                                       and utd-marking-lines-attr.doc-id    eq idoc-id
                                       and utd-marking-lines-attr.lineNum   eq ilineNum
                                       and utd-marking-lines-attr.mark      eq imark
                                       and utd-marking-lines-attr.attr-code eq iattrcode
   no-lock no-error.
   if not available utd-marking-lines-attr
   then do:
      if iattrval ne ?
         and iattrval ne ""
      then do:
         create utd-marking-lines-attr.
         assign
            utd-marking-lines-attr.db-num     = idb-num
            utd-marking-lines-attr.doc-id     = idoc-id
            utd-marking-lines-attr.lineNum    = ilineNum
            utd-marking-lines-attr.mark       = imark
            utd-marking-lines-attr.attr-code  = iattrcode
            utd-marking-lines-attr.attr-value = iattrval
         .
      end.
   end.
   else do:
      if utd-marking-lines-attr.attr-value ne iattrval
      then do:
         find current utd-marking-lines-attr exclusive-lock no-error.
         if available utd-marking-lines-attr
         then do:
            if    iattrval eq ?
               or iattrval eq ""
            then do:
               delete utd-marking-lines-attr.
            end.
            else do:
               utd-marking-lines-attr.attr-value = iattrval.
            end.
         end.
      end.
   end.
   release utd-marking-lines-attr.
end.
def var vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
method private void xmlchar-test (input  p-in-string          as character,
                                  output p-out-string-enc     as character,
                                  output p-out-string-dec    as character):
do
on error undo, return error
:
       xmlchar-encode
    (
          input p-in-string
        , output p-out-string-enc
    ).
       xmlchar-decode
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
method private void xmlchar-encode (input  p-in-string          as character,
                                  output p-out-string         as character):
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
method private character  xmlchar-encode-1c (input  p-in-string          as character):
define variable p-out-string as character no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
return p-out-string.
end .
method private void xmlchar-decode (input  p-in-string          as character,
                                  output p-out-string         as character):
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    xmlchar-read-integer
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
method private void xmlchar-read-integer (input  p-input-string       as character,
                                          output p-output-integer     as integer,
                                          output p-success            as logical):
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable mMRCCode  as logical    no-undo.
define variable mTypeMark as character  no-undo.
method private logical IS-NeedMark
( input ib-code as integer  ,
  input ib-str as character ):
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
   find first buf_prod-bc-attr where buf_prod-bc-attr.b-code eq ib-code
                                 and buf_prod-bc-attr.b-str  eq ib-str
                                 and buf_prod-bc-attr.attr-code eq 'mark':U
     no-lock no-error.
   return if available buf_prod-bc-attr then logical(buf_prod-bc-attr.attr-value) else no .
end.
method private character repTegforDm
(iDM as char ):
    define variable vTeglist as character no-undo init "01,02,11,13,17,21,8005,37".
    define variable vteg as character no-undo.
    define variable oDM as character no-undo.
    define variable vi as integer no-undo.
    oDM = iDm.
    do vi = 1 to num-entries(vTeglist):
       vTeg = entry(vi,vTeglist).
       oDM = replace(oDM,"(" + vTeg + ")",vTeg).
    end.
    return oDM.
end.
method private character repSpecSimbforDm
(iDM as char ):
    define variable oDM as character no-undo.
    xmlchar-decode(iDM, output oDM).
  return repTegforDm (oDM).
end.
method private logical CheckGtin
(iGtin as char):
   define variable bar_code as character no-undo.
   define variable vGtin as logical no-undo init "yes".
   if length(iGtin) eq 14
   then do:
      bar_code = substr (iGtin, 1, length (iGtin) - 1).
      run str/chk-sum.p
       (input-output bar_code ) no-error .
      if iGtin ne  bar_code
      then
         vGtin = no.
   end.
   else
      vGtin = no.
   return vgtin.
end.
method private character repSpecSimbforXlm
(iDM as char ):
    iDM = replace(iDM,chr(29),"").
    return iDM.
end.
method private character getGtinByDM
(IDM as char):
   define variable VTXT as char no-undo.
   define variable vGtin as char no-undo.
   vTXt = IdM.
   vGtin = IDM.
   if    length(vtxt) > 14
   then do:
      if   vtxt begins "(01)"
             or vtxt begins "(02)"
      then
         vGtin = substring(vtxt,5,14).
      else if   (vtxt begins "01"
             or vtxt begins "02" )
             and (   (    substring(iDm,17,2) eq "21"
                      and length(vtxt) >= 21)
                  or substring(iDm,17,2) eq "37"
                  or substring(iDm,17,4) eq "(37)" )
      then do:
         vGtin = substring(vtxt,3,14).
         if not checkGtin(vGtin)
         then
            vGtin = substring(vtxt,1,14).
      end.
      else if     length(vtxt) eq 14 + 7 + 4 + 4
          or length(vtxt) eq 14 + 7 + 4
          or length(vtxt) eq 14 + 7
      then
         vGtin = substring(vtxt,1,14).
   end.
   if not checkGtin(vGtin)
   then
      vGtin = "".
   return vgtin.
end.
method private integer getGdsCodeByGtin
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin  and prod-bc.bc-on no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.gds-code else ?.
end.
method private decimal getQntyCodeByGtin
(iGtin as char):
   define buffer prod-bc  for ub.prod-bc.
   define buffer bar-code for ub.bar-code.
   find first prod-bc where prod-bc.b-str eq iGtin no-lock no-error.
   find first bar-code where bar-code.b-code eq prod-bc.b-code no-lock no-error.
   return if avail bar-code then bar-code.cli-base-rate else ?.
end.
method private integer getGdsCodeByDM
(iDm as char):
   define variable vGtin as char no-undo.
   define buffer prod-bc for ub.prod-bc.
   vGtin  = getGtinByDM (IDM ).
   return getGdsCodeByGtin (vGtin).
end.
method private logical ChekTypeMarkByGds
(iGds-code as integer ):
   define buffer goods-attr for ub.goods-attr.
   find first goods-attr where goods-attr.gds-code   = iGds-code
                           and goods-attr.attr-code  = 'mark-type':U
   no-lock no-error.
   if available goods-attr
   then do:
      mTypeMark = goods-attr.attr-value.
      return goods-attr.attr-value = objsrv:Env:Marking:Types:tabak:NameProp
        .
   end.
   else
      return no.
end.
method private logical ChekTypeMarkByDm
(iDM as char ):
   return ChekTypeMarkByGds(getGdsCodeByDM(idm)).
end.
method private logical ChekTypeMarkByGtin
(iGtin as char ):
   return ChekTypeMarkByGds(getGdsCodeByGtin(iGtin)).
end.
method private character  GetNextElement
  (input iAllTeg        as logical
  ,output oteg          as character
  ,output otegval       as character
  ,input-output pstr    as character
   ):
     define variable vlistElem   as character no-undo init "00,01,02,21,17,11,13,(01),(02),(21),(17),(11),(13)".
     define variable vlistleng   as character no-undo init "27,14,14,13,06,06,06,0014,0014,0013,0006,0006,0006".
     define variable vlistElemDop   as character no-undo init ",37,(37),(8005),8005,93,(93)".
     define variable vlistlengDop   as character no-undo init ",08,0008,000006,0006,04,0004".
     define variable vTeg as character no-undo.
     define variable vLength as integer no-undo.
     define variable vi as integer no-undo.
     define variable vj as integer no-undo.
     define buffer code for ub.code.
     find first code where Code.parent eq "MarkType"
                       and Code.CodeValue   eq mTypeMark
                       no-lock no-error.
     if     available code
        and Code.misc1 ne ""
        and Code.misc1 ne ?
     then do:
        integer (Code.misc1) no-error.
        if not error-status:error
        then
          entry (4,vlistleng) = Code.misc1.
     end.
     if iAllTeg
     then
        assign
           vlistElem     = vlistElem    + vlistElemDop
           vlistleng     = vlistleng    + vlistlengDop
        .
     else if mMRCCode
     then
        assign
           vlistElem     = vlistElem    + ",(8005),8005"
           vlistleng     = vlistleng    + ",000006,0006"
        .
    block-elem:
    do vi = 1 to num-entries(vlistElem):
       vTeg = entry(vi,vlistElem).
       if pstr begins vTeg
       then do:
          if    vTeg eq "21"
          then
             vLength = index(pstr,chr(29)) - 2 no-error.
          if vLength  <= 0
          then
             vLength = int(entry(vi,vlistleng)).
          otegval = substring (pstr,length(vteg) + 1, vLength).
          oteg = replace(replace(vteg,")",""),"(","").
          vTeg = vteg + otegval.
          otegval = replace(otegval,chr(29),"").
          oteg = replace(replace(oteg,")",""),"(","").
          pstr = substring (pstr,length(vTeg)+ 1).
          vTeg = replace(vTeg,chr(29),"").
          leave block-elem.
       end.
       else
          vTeg = "".
    end.
    return vteg.
end.
method private character  GetCodeIdent
(iDm as char):
   define variable Velement   as character no-undo init "first".
   define variable oCodeIdent as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define variable vGtin as character no-undo.
   define buffer marking for ub.marking.
   for first marking no-lock where
             marking.mark eq iDm
         and marking.unit-ext = "LEVEL2"
   :
     return iDm.
   end.
   vGtin  = getGtinByDM (iDm ).
   ChekTypeMarkByDm(idm).
   if iDm begins 'tech_':U
   then
      oCodeIdent = iDm.
   else if length(iDm) < 21
   then do:
      find first marking where marking.mark eq idm
      no-lock no-error.
      oCodeIdent = if available marking then marking.mark else  ?.
   end.
   else if     length(iDm) eq 29
      and not iDm begins "01"
      and not iDm begins "02"
   then
      oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21 ).
   else  if     length(iDm) >= 24
            and (  iDm begins "01"
                or iDm begins "02")
            and  substring(iDm,17,2) ne "21"
   then do:
      if checkGtin(substring(iDm,1,14)) and ( (length(idm) eq 25 and substring(iDm,22,1) eq "A")
                                                or (length(idm) eq 29 and substring(iDm,22,1) eq "A"))
      then
         oCodeIdent = substring(iDm,1,if mMRCCode then 25 else 21).
      else
         oCodeIdent = iDM.
   end.
   else  if     (   length(iDm) eq 25
                 or length(iDm) eq 21)
            and (not iDm begins "01"
            and  not iDm begins "02")
   then
      oCodeIdent = substring(iDm,1,21).
   else if vGtin = substring(iDm,1,14) and checkGtin(substring(iDm,1,14)) and ( length(idm) eq 21 or (length(idm) eq 25 and substring(iDm,22,1) eq "A"))
   then
      oCodeIdent = substring(iDm,1,21).
   else do while Velement ne "" and idm ne "":
      Velement = GetNextElement(no,output vteg, output vtegval, input-output idm).
      oCodeIdent = oCodeIdent + Velement.
   end.
   return oCodeIdent.
end.
method private character  GetTegCod
(icodeIdent as char, iTeg as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo init ?.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if     ((length(icodeIdent) eq 21
      and not icodeIdent begins "01"
      and not icodeIdent begins "02")
      or
          ( length(icodeIdent) eq 25
            and not icodeIdent begins "01"
            and not icodeIdent begins "02"))
   then do:
      if iTeg eq "01" or iTeg eq "02"
      then
         oTeg = substring(icodeIdent,1,21).
      else  if  iTeg eq "21"
      then
         oTeg = substring(icodeIdent,15,7).
   end.
   else do:
      ChekTypeMarkByDm(icodeIdent).
      block-teg:
         do while Velement ne "" and icodeIdent ne "":
         Velement = GetNextElement(yes,output vteg, output vtegval, input-output icodeIdent).
         if    Velement begins iTeg
            or Velement begins "(" + iTeg + ")"
         then do:
            oTeg = vtegval.
            leave block-teg.
         end.
      end.
   end.
   return oTeg.
end.
method private logical isOAD
(icodeIdent as character):
   return length(icodeIdent) > 18 and GetTegCod(icodeIdent,"37") ne ? and GetTegCod(icodeIdent,"02") ne ?.
end.
method private logical isMark
(icodeIdent as character):
   define buffer buf_marking for ub.marking.
   return can-find(first buf_marking where buf_marking.mark begins icodeIdent) or
          (length(icodeIdent) > 20 and not isOAD(icodeIdent)).
end.
method private character  addBracketForCode
(icodeIdent as char):
   define variable Velement   as character no-undo init "first".
   define variable oTeg as character no-undo.
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   define buffer marking for ub.marking.
   find first marking no-lock where
              marking.mark begins icodeIdent no-error.
   if    not ChekTypeMarkByDm(icodeIdent)
      or length(icodeIdent) le 24
      or (avail marking and marking.unit-ext = "LEVEL2")
   then
      oTeg = icodeIdent.
   else do:
      if (  icodeIdent begins "01"
         or icodeIdent begins "02"
         ) and CheckGtin(substring (icodeIdent,3,14))
         and substring (icodeIdent,17,2) eq "21"
      then do:
         mMRCCode = yes.
         ChekTypeMarkByDm(icodeIdent).
         block-teg:
         do while Velement ne "" and icodeIdent ne "":
            Velement = GetNextElement(no,output vteg, output vtegval, input-output icodeIdent).
            if vteg ne ""
            then
               oTeg = oTeg + "(" + vteg + ")" + vtegval .
         end.
         mMRCCode = no.
      end.
      else do:
         oTeg = icodeIdent.
      end.
   end.
   return oTeg.
end.
method private integer getlevelByCodId
(iCode as char):
   define variable vLength as int no-undo.
   define variable vLevel  as int no-undo.
   if not ChekTypeMarkByDM (icode) then return ?.
   vLength = length(iCode).
   if    vLength eq 18
      or vLength eq 20
   then
      Vlevel = 4.
   else if vLength eq 21
   then
      Vlevel = 1.
   else if vLength eq 25
   then do:
      if  iCode begins "01"
      then
         Vlevel = 3.
      else
         Vlevel = 1.
   end.
   else if     vLength >= 26
           and vLength <= 46
   then do:
      if    substring(iCode,17,2) eq "11"
         or substring(iCode,17,2) eq "13"
         or (    substring(iCode,17,2) eq "21"
             and vLength >= 33
             and substring(iCode,26,4) ne "8005")
      then
         Vlevel = 4.
      else if    vLength eq 31
              or vLength eq 38
              or vLength eq 39
              or vLength eq 45
      then
         Vlevel = 1.
      else if    vLength eq 35
              or vLength eq 43
      then
         Vlevel = 3.
      else
         Vlevel = ?.
   end.
   else
      Vlevel = ?.
   return Vlevel.
end.
method private character  getLevelMotpBycodid
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 6
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
method private character    getLevelUTDByLevelMotp
(iUnit as char):
   define variable vLevel as integer no-undo.
   define variable vListMOTP    as character no-undo init "Unit,kin,Level1,Level2,Level3,Level4,Level5".
   define variable vListutd as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = lookup(iUnit,vListMOTP).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vListutd).
end.
method private character  getLevelMotpByDM
(iDm as char):
   return getLevelMotpByCodId(GetCodeIdent(iDm)).
end.
method private character  getLevelUTDByCodId
(iDm as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "КИ,КИН,КИГУ,КИТУ".
   vLevel = getlevelByCodId(iDm).
   if    vLevel eq ?
      or vLevel < 1
      or vLevel > 4
   then
      return ?.
   else
      return entry(vlevel,vList).
end.
method private character  getLevelUTDByDM
(iDm as char):
   return getLevelUTDByCodId(GetCodeIdent(iDm)).
end.
define variable mNotMarkQnty as logical no-undo.
method private decimal getQntyUTDByCodId
(iDM as char):
   define variable vLevel as integer no-undo.
   define variable vList as character no-undo init "1,5,10,500".
   define variable vGtin as character no-undo.
   define variable vqnty as decimal no-undo init ?.
   vqnty = dec(GetTegCod(iDM,"37")) no-error.
   if vqnty eq ?
   then do:
      if not mNotMarkQnty
      then do:
         define buffer marking for ub.marking.
         define variable vCodident as character no-undo.
         vCodident = GetCodeIdent(idm).
         find first marking where marking.mark begins vCodident no-lock no-error.
         if     available marking
            and marking.box-qnty ne ?
         then
            return marking.box-qnty.
      end.
      vGtin = getGtinByDm(iDM).
      if ChekTypeMarkByGtin (vGtin)
      then do:
         vLevel = getlevelByCodId(iDM).
         if     vLevel >= 1
            and vLevel <= 4
         then
            vqnty = int(entry(vlevel,vList)).
      end.
      else
         vqnty = getQntyCodeByGtin(vgtin).
   end.
   return vqnty.
end.
method private decimal getQntyUTDByDM
(iDm as char):
   define variable vDM as character no-undo.
   if     length (iDm) ne 25
      and length (iDm) ne 29
      and substring (iDm,length (iDm) - 6 + 1, 2 ) eq "93"
   then
      vDM = substring (iDm,1,length (iDm) - 6 ).
   else
      vDM = substring (iDm,1,length (iDm) - 4 ).
   return getQntyUTDByCodId(vDM).
end.
method private decimal    getMRC4
(iMRC as char):
   define variable oMrc     as decimal no-undo init ?.
   define variable vAlphabet as character no-undo init "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!~"%&'*+-./_,:;=<>?".
   define variable vi       as integer no-undo.
   define variable vfound   as integer no-undo.
   define variable vposStart   as integer no-undo.
   do:
   OMRc = 0.
   do vi = 1 to 4:
      define variable vsimb as character no-undo.
      vsimb = substring(iMRC,vi,1).
      vposStart = if keycode("Z") < keycode(vsimb) then 27 else 1.
      vfound = index(vAlphabet,vsimb,vposStart) - 1.
      if vfound > 0
      then
         OMRc = OMRc + exp (80,(4 - vi) ) * vfound  .
      end.
      OMRc = OMRc / 100.
   end.
   return OMRc.
end.
method private decimal    getMRCByDM
(iDm as char):
   define variable vMRC     as character no-undo.
   define variable oMrc     as decimal no-undo init ?.
   define variable Velement as character no-undo init "empty".
   define variable vteg as character no-undo.
   define variable vtegval as character no-undo.
   if    length(idm) eq 14 + 7 + 4 + 4
      or length(idm) eq 14 + 7 + 4
   then do:
      vMRC = substring(idm,22,4).
      omrc = getMRC4(vMRC).
   end.
   else do:
       ChekTypeMarkByDm(iDm).
       block-mrc:
       do while Velement ne "" and idm ne "":
          Velement = GetNextElement(yes,output vteg, output vtegval, input-output idm).
          if Velement begins "8005"
          then do:
             vMRC = substring(Velement,5,6).
             leave block-mrc.
          end.
          else if Velement begins "(8005)"
          then do:
             vMRC = substring(Velement,7,6).
             leave block-mrc.
          end.
       end.
       if vMRC ne ""
       then
          OMRc = dec(vmrc) / 100 no-error.
   end.
   return OMRc.
end.
method private date    MoveDate
(idate as date,
 iMonth as int64):
   define variable vMonth   as int64 no-undo.
   define variable vYear    as int64 no-undo.
   define variable vDateNew as date  no-undo.
    define variable vDay     as int64 no-undo.
    vMonth = month(iDate) + iMonth.
    vYear =  year(iDate).
    if vMonth <= 0
    then assign
       vMonth = vMonth + 12
        vYear  = vYear - 1
    .
    else if vMonth > 12
    then assign
       vMonth = vMonth - 12
        vYear  = vYear + 1
    .
    vDateNew = date(vMonth,day(iDate),vYear) no-error.
    do while error-status:error eq yes:
       VDay = vDay + 1.
       vDateNew = date(vMonth,day(iDate) - vDay,vYear) no-error.
    end.
    if VDay > 0
    then
       vDateNew + 1.
    return vDateNew.
end.
method private logical    checkEMRC
(input  iDm as char,
 output vOk as logical):
   define variable v-value-emrc as character no-undo.
   define variable v-type-emrc  as character no-undo.
   define variable vDateIso     as character no-undo.
   define variable vMRC         as decimal no-undo.
   define variable vqnty        as decimal no-undo.
   define variable vPrice       as decimal no-undo.
   define variable vparent      as character no-undo.
   define variable vgds-code    as integer no-undo.
   define buffer code for ub.code.
   vMRC = getMRCByDM(iDm).
   if vMRC > 0
   then do:
      vgds-code = getGdsCodeByDM(iDm).
      vqnty     = getQntyUTDByDM(iDm).
            if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
         (
          input   vgds-code
         ,input   'emrc-type':U
         ,output   v-value-emrc
         ,output   v-type-emrc
       ) no-error.
       if     v-value-emrc ne ""
          and v-value-emrc ne ?
       then do:
          vDateIso = iso-date(today).
          vPrice = vMRC / vqnty.
          vparent ="emc" + chr(4) + v-value-emrc.
          find last code where Code.parent      eq vparent
                           and Code.code        le vDateIso
                           and code.status_  eq 0
          no-lock no-error.
          if not available code or ( vPrice  >= dec(Code.CodeValue))
          then
             vOk = true .
          else do:
              define variable vText      as character no-undo.
              define variable vDate      as date no-undo.
              define variable vDateLast  as character no-undo.
              define variable vDateFirst as character no-undo.
              define variable vDate3     as date no-undo.
              vdate = date(code.misc1).
              vDateLast = code.misc1.
              vDate3 = MoveDate(today, - 3 ).
              vText =  substitute ("ТОВАР ИМЕЕТ ОГРАНИЧЕННЫЙ СРОК РЕАЛИЗАЦИИ. Если товар произведен после &2, то его приемка и продажа запрещена.",
                                   string(vDate3  , "99/99/9999"),
                                   string(vDate   , "99/99/9999")
                                   ).
              vdateIso = iso-date(vdate3).
              find last code  where Code.parent      eq vparent
                                and Code.code        le vDateIso
                                and code.status_  eq 0 no-lock no-error.
              if available code
              then
                 vDateIso = code.code.
              vDateFirst = vDateIso.
              vDateLast = iso-date(vdate).
              define variable vGood as logical no-undo.
              define variable vDateSale as date no-undo.
              define buffer bcode for code.
              for last code where Code.parent   eq vparent
                              and code.status_  eq 0
                              and code.code     < vDateLast
                              and code.code     >= vDateFirst
              no-lock:
                 find first bcode where bCode.parent   eq vparent
                                    and bcode.status_  eq 0
                                    and bcode.code     > code.code no-lock no-error.
                 if available bcode
                 then do:
                    if vPrice < dec(Code.CodeValue)
                    then
                       vText = vtext + substitute ("&1Если товар произведен с &2 до &3, ТО ЕГО ПРИЕМКА И ПРОДАЖА ЗАПРЕЩЕНА",
                                                  chr(10),
                                                  string(    date( code.misc1)       ,"99/99/9999"),
                                                  string(    date(bcode.misc1)       ,"99/99/9999")
                                                  ).
                    else do:
                       vGood = yes.
                       vDateSale = MoveDate(date(bcode.misc1), 3) - 1.
                       vText = vtext + substitute ("&1Если товар произведен до &3, то продажа разрешена до &4.~Осталось &5 дней.",
                                                  chr(10),
                                                  string(    date( code.misc1)         ,"99/99/9999"),
                                                  string(    date(bcode.misc1)         ,"99/99/9999"),
                                                  string(         vDateSale            ,"99/99/9999"),
                                                  string(vDateSale - today)
                                                  ).
                    end.
                 end.
              end.
              if vgood
              then do:
                 define variable choice as integer no-undo .
                 run gbl/d-askw.w (input "Уточнение"
                        ,input  vText
                        ,input "|"
                        ,input "Принять|Вернуть"
                        ,input "Принять данный товар|Вернуть товар постащику"
                        ,input 1
                        ,input 2
                        ,output choice) no-error.
                 vok = choice eq 1.
              end.
              else
                 vok =false.
          end.
       end.
   end.
end.
method private character addGs2Mark
(iMark as char):
   define variable vDM   as character no-undo.
   define variable vIdx  as integer   no-undo.
   if index(iMark,chr(29),1) > 0
   then return iMark.
   if substring(iMark,26,4) = "8005" then
   do:
     vIdx = index(iMark,"93",26 + 4 + 5).
     if vIdx > 1 then do:
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,25),
                        substring(iMark,26,vIdx - 25 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       vIdx = index(vDm,"240",vIdx + 4).
       if vIdx > 0 then
       do:
         vDM = substitute("&1&3&2",
                          substring(vDm,1,vIdx - 1),
                          substring(vDm,vIdx),
                          chr(29)) no-error.
       end.
     end.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,25),
                        substring(iMark,26),
                        chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "91" then
   do:
     vIdx = index(iMark,"92",32).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,31),
                        substring(iMark,32,vIdx - 31 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,31),
                        substring(iMark,32),
                        chr(29)) no-error.
   end.
   else if substring(iMark,39,2) = "91" then
   do:
     vIdx = index(iMark,"92",38).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,38),
                        substring(iMark,39,vIdx - 38 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vDM = substitute("&1&3&2",
                        substring(iMark,1,38),
                        substring(iMark,39),
                        chr(29)) no-error.
   end.
   else if substring(iMark,25,2) = "93" then
   do:
     vIdx = index(iMark,"92",25).
     if vIdx > 1 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
     else
       vIdx = index(iMark,"3103",25).
       if vIdx > 0 then
       vDM = substitute("&1&4&2&4&3",
                        substring(iMark,1,24),
                        substring(iMark,25,vIdx - 24 - 1),
                        substring(iMark,vIdx),
                        chr(29)) no-error.
       else
         vDM = substitute("&1&3&2",
                          substring(iMark,1,24),
                          substring(iMark,25),
                          chr(29)) no-error.
   end.
   else if substring(iMark,32,2) = "93" then
   do:
     vDM = substitute("&1&3&2",
           substring(iMark,1,31),
           substring(iMark,32),
           chr(29)) no-error.
   end.
   return if vDM <> "" then vDm else iMark.
end.
method private logical AddUtdErrForTab
(idb-num         as integer ,
 idoc-id         as integer ,
 iTab            as character,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   define buffer utd-err for utd-err.
   define buffer utd for utd.
   find first utd where utd.db-num     eq idb-num
                    and utd.doc-id     eq idoc-id
                    and utd.Direction  eq 'Outbound'
   no-lock no-error.
   if available utd
   then
      return no.
   define variable vRecKey as character no-undo.
         define variable objKeyRec as class ibs.th.gbl.keyrec no-undo.
         objKeyRec = new ibs.th.gbl.keyrec().
         objKeyRec:GenKeyRec ( input iTab
                              ,input iObj
                              ,output vRecKey).
         delete object objKeyRec.
   find first utd-err where utd-err.db-num     eq idb-num
                        and utd-err.doc-id     eq idoc-id
                        and utd-err.CheckType  eq iCheckType
                        and utd-err.CodeErr    eq iCodeErr
                        and utd-err.CheckObj   eq iCheckObj
   exclusive-lock no-error.
   if not available utd-err
   then do:
      create utd-err.
      assign
         utd-err.db-num         = idb-num
         utd-err.doc-id         = idoc-id
         utd-err.CheckType      = iCheckType
         utd-err.CodeErr        = iCodeErr
         utd-err.CheckObj       = if iCheckObj eq ? then "?" else iCheckObj
         utd-err.reckey         = vRecKey
         utd-err.qnty           = 1
      .
   end.
   else
      utd-err.qnty = utd-err.qnty + 1.
   return utd-err.qnty eq 1.
end.
method private logical AddUtdErr
(idb-num         as integer ,
 idoc-id         as integer ,
 iObj            as handle ,
 iCheckType      as character,
 iCodeErr        as character,
 iCheckObj       as character ):
   AddUtdErrForTab
      (idb-num,
       idoc-id,
       iObj:table,
       iObj,
       iCheckType,
       iCodeErr,
       iCheckObj).
end.
method private void ClearUtdErrTypeCode
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character,
 iCodeErr        as character
 ):
   define buffer utd-err for utd-err.
   if    iCheckType eq "*"
      or iCheckType eq ?
   then do:
      if     iCodeErr ne ?
         and iCodeErr ne "*"
      then
         message "Задан код ошибки " iCodeErr " для удаления, но не задан тип"
         view-as alert-box.
      else
      for each utd-err where utd-err.db-num  eq idb-num
                         and utd-err.doc-id  eq idoc-id
      exclusive-lock:
         delete utd-err.
      end.
   end.
   else do:
      if    iCodeErr eq ?
         or iCodeErr eq "*"
      then do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
         exclusive-lock:
            delete utd-err.
         end.
      end.
      else do:
         for each utd-err where utd-err.db-num     eq idb-num
                            and utd-err.doc-id     eq idoc-id
                            and utd-err.CheckType  eq iCheckType
                            and ub.utd-err.CodeErr eq iCodeErr
         exclusive-lock:
            delete utd-err.
         end.
      end.
   end.
end.
method private void ClearUtdErr
(idb-num         as integer,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   ClearUtdErrTypeCode(idb-num,idoc-id,iCheckType,?).
end.
method private character GetMesError
(itxt as character,
 iobj as character ):
 define variable vi as integer no-undo.
 do vi = num-entries(iobj ,chr(4) ) to 1 by -1 :
    itxt = replace(itxt,"&" + string(vi),entry(vi,iobj,chr(4))).
 end.
 return itxt.
end.
method private character GetTextErrorType
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 iType      as character  ):
   define buffer code    for code.
   define variable vError as character no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if available code
   then do:
      define variable vType as integer no-undo.
      if code.misc3 eq "error"
      then
         vType = 0.
      else if code.misc3 eq "warning"
      then
         vType = 1.
      else if code.misc3 eq "Hiden"
      then
         vType = 2.
      else
         vtype = int(code.misc3) no-error.
      case itype:
         when "error"
         then do:
            if vtype eq 0
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         when "warning"
         then do:
            if vtype <= 1
            then
               vError = GetMesError(Code.CodeValue,iChechObj).
         end.
         otherwise do:
            vError = GetMesError(Code.CodeValue,iChechObj).
         end.
      end.
   end.
   else
      vError =  iCodeErr + ":" + replace (iChechObj,chr(4),"|").
   return vError.
end.
method private integer  GetTypeError
(iCheckType as character,
 iCodeErr   as character):
   define buffer code    for code.
   define variable vType as integer no-undo.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     not available code
      and code.misc3 eq "error"
   then
      vType = 0.
   else if code.misc3 eq "warning"
   then
      vType = 1.
   else if code.misc3 eq "Hiden"
   then
      vType = 2.
   else
      vtype = int(code.misc3) no-error.
   return vtype.
end.
method private character GetTextError
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character ):
   return GetTextErrortype(iCheckType,iCodeErr,iChechObj,"warning").
end.
method private character GetErrForUtdstr
(idb-num     as integer ,
 idoc-id     as integer ,
 iCheckType  as character
 ):
   define buffer utd-err for utd-err.
   define buffer code    for code.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable vErrorOne as longchar  no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ""
         and vErrorOne ne ?
      then
         vError = vError + ", " + vErrorOne.
      vHQry:get-next().
   end.
   oError = substring(vError,3,4002).
   return oError.
end.
method private character GetErrJsonForUtd
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектОш":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
      vHQry:get-next().
   end.
   for first utd where utd.db-num eq idb-num
                   and utd.doc-id eq idoc-id
                   and utd.sts    eq ObjSrv:Env:Utd:Sts:th:DeliveryCodeMismatch:KeyIntDB
   no-lock,
      each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                               and utd-marking-lines.doc-id eq idoc-id
                               and utd-marking-lines.doc-level eq 1
   no-lock,
      first marking where marking.mark eq utd-marking-lines.mark
                      and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
   no-lock:
      vErrorOne = GetTextErrortype("CheckShip","NotMark",marking.mark,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vError = vError + ',"Ошибка_' + string(vi) +  '":~{"КодОш":"'    + "CheckShip" + "_" + "NotMark"
                         + '","ОбъектОш":"' + marking.mark
                         + '","ТекстОш":"' + vErrorOne + '"}'.
      end.
   end.
   if vError ne ""
   then
      oError = '"Ошибки":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
method private character GetErrJsonForUtdReturn
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable vError as longchar no-undo.
   define variable oError as character no-undo.
   define variable vi as integer no-undo.
   create query vHQry.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      define variable vErrorOne as character no-undo.
      vErrorOne = GetTextErrorType(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj,"error").
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vi = vi + 1.
         vError = vError + ',"Возврат_' + string(vi) +  '":~{"КодВозр":"'    + utd-err.CheckType + "_" + utd-err.CodeErr
                         + '","ОбъектВозр":"' + replace(utd-err.CheckObj,chr(4),"|")
                         + '","ТекстВозр":"' + GetTextError(utd-err.CheckType,utd-err.CodeErr,utd-err.CheckObj) + '"}'.
      end.
      vHQry:get-next().
   end.
   if vError ne ""
   then
      oError = '"Возвраты":~{' + substring(vError,2,31002) + "}".
   return oError.
end.
method private character GetCodeTextError
(iCheckType as character,
 iCodeErr   as character,
 iChechObj  as character,
 output oCode as character,
 output ovalue as character ):
   define buffer code    for code.
   find first code where code.parent eq "CodeError" +  chr(4)  + "UTD" +  chr(4) + iCheckType
                     and code.code   eq iCodeErr
   no-lock no-error.
   if     available code
   then do:
      define variable vi as integer no-undo init ?.
      vi = int(Code.misc3) no-error.
      if    code.misc3 ne "error"
         and vi ne 0
      then
         oCode = ?.
      else if     Code.misc1 ne ?
              and Code.misc1 ne ""
      then
         assign
            oCode  = GetMesError(Code.misc1,iChechObj)
            ovalue = GetMesError(Code.misc2,iChechObj)
         .
   end.
   return if oCode eq ""
          then ""
          else (oCode + "_" + ovalue).
end.
define temp-table TT-err no-undo
  field code_ as character
  field text_ as character
index code_ code_.
method private character GetErrTxtForUtd
(idb-num         as integer ,
 idoc-id         as integer ,
 iCheckType      as character
 ):
   define buffer utd-err for utd-err.
   define variable vHQry as handle no-undo.
   define variable oError as character no-undo.
   create query vHQry.
   define variable vi as integer no-undo.
   for each tt-err :
      delete tt-err.
   end.
   vHQry:set-buffers(buffer utd-err:handle).
   vHQry:query-prepare("for each utd-err where utd-err.db-num         eq " + QUOTER(idb-num)
                            +            " and utd-err.doc-id         eq " + QUOTER(idoc-id)
                            + if    iCheckType eq "*"
                                 or iCheckType eq ?
                              then       ""
                              else       " and utd-err.CheckType      eq " + QUOTER(iCheckType)).
   vHQry:query-open().
   vHQry:get-first().
   define variable vcode as character no-undo.
   define variable vvalue as character no-undo.
   QRY-BLOCK:
   repeat while not vHQry:query-off-end:
      vi = vi + 1.
      GetCodeTextError (utd-err.CheckType, utd-err.CodeErr, utd-err.CheckObj, output vcode, output vvalue).
      if vcode ne ?
      then do:
         find first tt-err where tt-err.code eq vcode
         no-error.
         if not available tt-err
         then do:
            create tt-err.
            assign
               tt-err.code_ = vcode
               tt-err.text_ = vvalue
            .
         end.
         else
            tt-err.text_ = tt-err.text_ + "||" + vvalue.
      end.
      vHQry:get-next().
   end.
  find first utd where utd.db-num eq idb-num
                      and utd.doc-id eq idoc-id
      no-lock.
   define buffer cancel_utd-lines for utd-lines.
   for each cancel_utd-lines where cancel_utd-lines.db-num eq idb-num
                               and cancel_utd-lines.doc-id eq idoc-id
   no-lock:
      if logical(getattrutdlinesex  (idb-num,idoc-id,cancel_utd-lines.LineNum,"MarkUtdLine"        ,"no"))
      then do:
         for   each utd-marking-lines where utd-marking-lines.db-num eq idb-num
                                     and utd-marking-lines.doc-id eq idoc-id
                                     and utd-marking-lines.LineNum eq cancel_utd-lines.LineNum
         no-lock,
            first marking where marking.mark eq utd-marking-lines.mark
                            and marking.sts  eq ObjSrv:Env:Marking:Sts:Mark:NotAvailable:KeyIntDB
         no-lock:
            GetCodeTextError ("CheckShip", "MARKDECLINED", utd-marking-lines.mark + chr(4) + string(utd-marking-lines.LineNum), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
      else do:
         define variable vqnty as decimal no-undo.
         vqnty = decimal(GetAttrUtdlines(cancel_utd-lines.db-num,cancel_utd-lines.doc-id,cancel_utd-lines.linenum,"QuantityBarCode")).
         if vqnty eq ? then vqnty = 0.
         if vqnty ne cancel_utd-lines.Quantity
         then do:
            GetCodeTextError ("CheckShip", "NotAcceptQuantity", string(cancel_utd-lines.LineNum) + chr(4) + string(cancel_utd-lines.Quantity - vqnty), output vcode, output vvalue).
            find first tt-err where tt-err.code eq vcode
            no-error.
            if not available tt-err
            then do:
               create tt-err.
               assign
                  tt-err.code_ = vcode
                  tt-err.text_ = vvalue
               .
            end.
            else
               tt-err.text_ = tt-err.text_ + "||" + vvalue.
         end.
      end.
   end.
   for each tt-err:
      oError = oError + substitute("&1|&2|",tt-err.code_ , tt-err.text_ ) + chr(13) + chr(10) .
   end.
   return oError.
end.
define variable mFormatErr as character no-undo init "text".
method private character GetErrForUtd
(idb-num         as integer ,
 idoc-id         as integer ,
 iType           as character
 ):
   if mFormatErr eq "text"
   then
      return GetErrTxtForUtd(idb-num,idoc-id,iType).
   else do:
      if itype eq "return"
      then return GetErrJsonForUtdReturn (idb-num,idoc-id,iType).
      else return GetErrJsonForUtd(idb-num,idoc-id,iType).
   end.
end.
method private longchar GetErrComText
(icomment as character,
 itext    as longchar ):
    define variable vText as longchar no-undo.
   if mFormatErr eq "text"
   then do:
      if icomment ne ""
      then
         icomment = substitute("comment:|&1|",icomment).
      vText = icomment + itext.
   end.
   else do:
      icomment = if icomment begins  '"'
                 then icomment
                 else  if icomment eq "" then "" else ( '"Коментрии":~{"Коментарий":"' + icomment  + '"}') .
      vText = icomment + "," + itext.
      vText = "~{" + trim(vText,",") + "~}".
   end.
   return vText.
end.
method private logical  CheckTypeForMarkLineType
(iObj            as handle,
 iCheckType      as character,
 iCodeErr        as character ,
 iTypeErr        as character ):
   define variable vRecKey-markLine as character no-undo.
   define variable vGoodMark        as logical no-undo.
   define variable vdb-num          as integer no-undo.
   define variable vdoc-id          as integer no-undo.
   define variable vlinenum         as integer no-undo.
   define variable vErrorOne as character no-undo.
   define buffer buf_utd-err for utd-err.
    define variable objKeyRec as class ibs.th.gbl.keyrec no-undo.
    objKeyRec = new ibs.th.gbl.keyrec().
    objKeyRec:GenKeyRec ( input "utd-marking-lines"
                         ,input iObj
                         ,output  vRecKey-markLine).
    delete object objKeyRec.
   vGoodMark = yes.
   vdb-num = iObj::db-num.
   vdoc-id = iObj::doc-id.
   vlinenum = iObj::linenum.
   block-mark-err:
   for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                            and buf_utd-err.db-num = vdb-num
                            and buf_utd-err.reckey = vRecKey-markLine
                            and if iCheckType  eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                            and if iCodeErr    eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
   no-lock:
      vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
      if     vErrorOne ne ?
         and vErrorOne ne ""
      then do:
         vGoodMark = no.
         leave block-mark-err.
      end.
   end.
   return not vGoodMark.
end.
method private logical  CheckErrForMarkLineType
(iObj            as handle,
 iType           as character  ):
   return CheckTypeForMarkLineType (iObj,iType,"*","error").
end.
method private logical  CheckErrForMarkLine
(iObj            as handle):
   return CheckErrForMarkLineType(iObj,"*").
end.
method private logical  CheckErrForLineTypeCode
(iObj                 as handle,
 iCheckType           as character,
 iCodeErr             as character,
 iTypeErr             as character,
 iOneErr              as logical):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
         define variable objKeyRec as class ibs.th.gbl.keyrec no-undo.
         objKeyRec = new ibs.th.gbl.keyrec().
         objKeyRec:GenKeyRec ( input "utd-lines"
                              ,input iObj
                              ,output vRecKey-line).
         delete object objKeyRec.
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iCheckType eq "*" or iCheckType eq ? then yes else buf_utd-err.CheckType = iCheckType
                               and if iCodeErr   eq "*" or iCodeErr   eq ? then yes else buf_utd-err.CodeErr   = iCodeErr
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,iTypeErr).
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            vUtdlineError = yes.
            leave block-err.
         end.
      end.
      if  not vUtdlineError
      then do:
         define variable vGoodMark as logical no-undo.
         vGoodMark = yes.
         block-line-err:
         for each utd-marking-lines where utd-marking-lines.db-num  eq vdb-num
                                      and utd-marking-lines.doc-id  eq vdoc-id
                                      and utd-marking-lines.LineNum eq vLineNum
         no-lock:
            vGoodMark = not CheckTypeForMarkLineType(buffer utd-marking-lines:handle,iCheckType,iCodeErr,iTypeErr).
            if     vGoodMark
               and iOneErr eq no
            then
               leave block-line-err.
            if     iOneErr = yes
               and not vGoodMark
            then
               leave block-line-err.
         end.
         vUtdlineError = not vGoodMark.
      end.
   return vUtdlineError.
end.
method private character   getErrForLineType
(iObj            as handle,
 iType           as character  ):
   define variable vRecKey-line     as character no-undo.
   define buffer buf_utd-err for utd-err.
   define variable vUtdlineError as logical no-undo.
   define variable vErrorOne as character no-undo.
   define variable oError as character no-undo.
         define variable objKeyRec as class ibs.th.gbl.keyrec no-undo.
         objKeyRec = new ibs.th.gbl.keyrec().
         objKeyRec:GenKeyRec ( input "utd-lines"
                              ,input iObj
                              ,output vRecKey-line).
         delete object objKeyRec.
      define variable vdb-num as integer no-undo.
      define variable vdoc-id as integer no-undo.
      define variable vlinenum as integer no-undo.
      vdb-num = iObj::db-num.
      vdoc-id = iObj::doc-id.
      vlinenum = iObj::linenum.
      block-err:
      for each buf_utd-err  where  buf_utd-err.doc-id = vdoc-id
                               and buf_utd-err.db-num = vdb-num
                               and buf_utd-err.reckey = vRecKey-line
                               and if iType eq "*" or iType eq ? then yes else buf_utd-err.CheckType = iType
      no-lock:
         vErrorOne = GetTextErrorType(buf_utd-err.CheckType,buf_utd-err.CodeErr,buf_utd-err.CheckObj,"error").
         if     vErrorOne ne ?
            and vErrorOne ne ""
         then do:
            oError = oError + vErrorOne + " ".
         end.
      end.
   return oError.
end.
method private logical  CheckErrForLineType
(iObj            as handle,
 iType           as character  ):
    return CheckErrForLineTypeCode (iObj,itype,"*","error",no).
end.
method private logical  CheckErrForLine
(iObj            as handle):
   return CheckErrForLineType(iobj,"*").
end.
method private logical  CheckErrForUtd
(idb-num         as integer ,
 idoc-id         as integer ):
   for each utd-lines where utd-lines.db-num eq idb-num
                        and utd-lines.doc-id eq idoc-id
   no-lock :
      if not CheckErrForLine (buffer ub.utd-lines:handle)
      then
         return no.
   end.
   return yes.
end.
method public logical CheckMarkUtd-28rel
 (input idb-num as integer,
 input idoc-id as integer):
 define buffer utd                   for utd.
 define buffer utd-lines             for utd-lines.
 define buffer utd-marking-lines     for utd-marking-lines.
 define variable v-par-type as character no-undo.
 define variable vgdsNoMark as logical no-undo.
 define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
   define variable v-par-val  as character no-undo.
   find first utd where utd.db-num eq idb-num
                    and utd.doc-id eq idoc-id
   no-lock no-error.
   if available utd
   then do:
      if     utd.obj-code ne ?
         and utd.obj-type ne ?
      then do:
         EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(utd.obj-type, utd.obj-code).
         Block-utd-lines:
         for each utd-lines where utd-lines.db-num eq idb-num
                              and utd-lines.doc-id eq idoc-id
         no-lock:
            if     utd-lines.gds-code ne ?
               and utd-lines.gds-code ne 0
            then do:
                               if (valid-handle(ibs.th.gbl.gbl-hndllib:g#attr-lib) <> true) then do:     message       "Не загружена библиотека attr-lib"       view-as alert-box error .     stop . end. run gds-attr-value in ibs.th.gbl.gbl-hndllib:g#attr-lib
                    ( utd-lines.gds-code,
                      'mark-type':U,
                       output v-par-val,
                       output v-par-type
                    ).
               if     EDOParSec:IsEdo
                  and EDOParSec:GetIsEDOForType(v-par-val)
               then do:
                  find first utd-marking-lines where utd-marking-lines.db-num  eq utd-lines.db-num
                                                 and utd-marking-lines.doc-id  eq utd-lines.doc-id
                                                 and utd-marking-lines.LineNum eq utd-lines.LineNum
                                                 and length(utd-marking-lines.mark) > 13
                  no-lock no-error.
                  if     avail utd-marking-lines
                     and not CheckErrForLine(buffer utd-lines:handle)
                  then
                     leave Block-utd-lines.
               end.
               else
                  vgdsNoMark = yes.
            end.
         end.
         setattrutd (utd.db-num,utd.doc-id,"MarkUtd",if vgdsNoMark then string(available utd-lines) else "yes").
         if vgdsNoMark then return available utd-lines . else return yes .
      end.
   end.
   return yes.
end.
  def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
method public character objExists
(input  ifolder as character,
 input  iType   as character  ):
    define variable vFileType as character no-undo init "D,F".
    define variable vi        as integer no-undo.
    define variable vtype as character no-undo.
    if iType ne ?
    then
       vFileType = iType.
    do vi = 1 to num-entries(vFileType):
       file-information:file-name = ".\" + right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index(vtype , entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
       file-information:file-name = right-trim(replace(ifolder,"/","\"),"\").
       vtype = file-information:file-type.
       if file-information:file-name <> "" and
          entry(num-entries(file-information:file-name, "\"), file-information:file-name, "\")
          = entry(num-entries(file-information:full-pathname, "\"), file-information:full-pathname ,"\") and
          index( vtype, entry(vi,vFileType )) > 0
       then return file-information:full-pathname .
    end.
    return ? .
end.
method public character SearchFile
(input  ifile as character):
   return objExists(ifile,?).
end.
method public character SearchPFile
(input inFile as char):
     define variable oFile       as character no-undo.
     define variable vFileSearch as character no-undo.
     define variable vNumEntry   as integer no-undo.
     if inFile = "" then return ?.
     vNumEntry = num-entries(inFile,".").
     vFileSearch = inFile.
     if    vNumEntry > 0
        and (   entry(vNumEntry,inFile,".") eq "p"
             or entry(vNumEntry,inFile,".") eq "w")
     then do:
        entry(vNumEntry,vFileSearch, ".") = "r".
        oFile = search(vFileSearch ).
        if oFile eq ?
        then
           oFile = search(inFile).
     end.
     else
        oFile = search(vFileSearch).
     return oFile.
  end.
end class.
