using Progress.Lang.*.
using ibs.th.skt.Commands.*.
using ibs.th.skt.ControlledClients.*.
using ibs.th.skt.Adapters.*.
using ibs.th.skt.*.
block-level on error undo, throw.
class ibs.th.skt.ControlledClients.websrv :
  define temp-table TempTrnDoc no-undo
    field SuppInDocNo   as character
    field stts          as character
    field ext-doc-type  as character
    field doc-date      as date
    field cli-type      as character
    field cli-code      as integer
    field obj-type      as character
    field obj-code      as integer
    field ContractID    as integer
    field ContractNum   as character
    field vat-type      as character
    field tot-transp    as decimal
    field tot-other     as decimal
    field wrkr          as integer
    field agnt          as integer
    field boss          as integer
    field pay-code      as integer
    field discnt-type   as character
    field discnt-pc     as decimal
    field user-id       as character
    field reason-code   as integer
    field ps            as character
    field hold-obj-type as character
    field hold-obj-code as integer
    field ship-num      as character
    field ship-date     as date
    index pi SuppInDocNo .
  define temp-table TempDocLine no-undo
    field SuppInDocNo  as character
    field line-num     as integer
    field gds-code     as integer
    field doc-qnty     as decimal
    field fact-qnty    as decimal
    field price-rubl   as decimal
    field vat-pc       as decimal
    field b-code       as character
    index pi
    SuppInDocNo
    line-num
    gds-code
    .
  define temp-table TempGdsDtl no-undo
    field SuppInDocNo  as character
    field line-num     as integer
    field gds-code     as integer
    field prt-code     as integer
    field b-code       as integer
    field doc-qnty     as decimal
    field price-rubl   as decimal
    index pi
    SuppInDocNo
    line-num
    gds-code
    prt-code
    .
  define temp-table TempParts no-undo
    field SuppInDocNo  as character
    field line-num     as integer
    field gds-code     as integer
    field part-code    as character
    field out-code     as character
    index pi
    SuppInDocNo
    line-num
    gds-code
    part-code
    .
  define temp-table TempDocAttr no-undo
    field SuppInDocNo  as character
    field attr-code    as character
    field attr-value   as character
    index pi
    SuppInDocNo
    attr-code
    .
  define stream str1 .
  define stream str2 .
  define public property SomeStr as longchar no-undo
    get.
    set.
  define public property ObjCode as integer no-undo
    private get.
    set.
  define public property ObjType as character no-undo
    private get.
    set.
  define public property SN as character no-undo
    private get.
    set.
  define public property ReqType as character no-undo
    get.
    set.
  define public property CP as character no-undo
    get.
    set.
  define private buffer buf_user      for ub.user-login.
  define private buffer buf_goods     for ub.goods.
  define private buffer buf_clients   for ub.clients.
  define private buffer buf_shop      for ub.shop.
  define private buffer buf_store     for ub.store.
  define private buffer buf_bar-code  for ub.bar-code.
  define private buffer buf_gds-obj   for ub.gds-obj.
  define private buffer buf_price-all for ub.price-all.
  define private buffer buf_prod-bc   for ub.prod-bc.
  define private buffer buf_trn-doc   for ub.trn-doc.
  define private buffer buf_doc-line  for ub.doc-line.
  define private variable tthDocument as handle no-undo.
  define private stream webstream.
  define private variable logWrite as class LogWrite no-undo.
  constructor public websrv (  ):
    logWrite = new LogWrite().
  end constructor.
  method private void webstreamopen (streamFile as char):
    output stream webstream to value (streamFile).
  end method.
  method private void webstreamclose ():
    output stream webstream close.
  end method.
  method public character getStatusXml (statusOk as logical, statusMsg as char):
    define variable statusOkTag as character no-undo.
    define variable statusMsgTag as character no-undo.
    assign
      statusOkTag = substitute ('<STATUS>&1</STATUS>', if statusOk then "OK" else "ERROR")
      statusMsgTag = if statusOk then '' else substitute ('<STATUS_MESSAGE>&1</STATUS_MESSAGE>', statusMsg)
    .
    return substitute ('<?xml version="1.0" encoding="&1"?><websrv>&2&3</websrv>', CP, statusOkTag, statusMsgTag).
  end method.
  method public void ImpWB (table TempTrnDoc, table TempDocLine, table TempGdsDtl, table TempParts, table TempDocAttr, output ANS as logical):
    define variable adapter         as class AdapterWebSrv-TrnDoc.
    define variable glog            as logical         no-undo.
    define variable varzero-string  as logical no-undo.
    find first TempTrnDoc.
      adapter = new AdapterWebSrv-TrnDoc().
      adapter:SetTempTable(table TempTrnDoc, table TempDocLine, table TempGdsDtl, table TempParts, table TempDocAttr).
      adapter:WriteDB(glog) no-error.
      LogWrite:LogStr = LogWrite:LogStr + chr(10) + adapter:StrLog.
      delete object adapter.
      if glog
        then do:
          SomeStr = getStatusXml(true, "").
          ANS = true.
        end.
        else do:
          SomeStr = getStatusXml(false, LogWrite:LogStr).
          ANS = false.
        end.
  end.
  method public void CodePageConvert ():
    define variable str as char no-undo.
    if session:charset <> replace (CP, "windows-", "")
      then do:
        str = codepage-convert (SomeStr, replace (CP, "windows-", ""), session:charset) no-error.
        if str = ?
          then.
          else SomeStr = str.
      end.
  end.
  method public void WriteUnknown ():
    SomeStr = getStatusXml(false, "Неизвестный запрос.").
  end.
  method public integer GetDbNum ():
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    do
    on error undo, return error return-value
    :
      for first buf_sys-ctrl field (db-num) no-lock :
       return buf_sys-ctrl.db-num.
      end.
    end.
  end method.
end class.
