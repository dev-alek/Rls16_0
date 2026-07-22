using Progress.Lang.*.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.
class ibs.th.skt.Adapters.AdapterWebSrv-TrnDoc implements IAdapter:
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
  define property StrLog as character no-undo
    get.
    set.
  define property UserId_ as character no-undo
    get.
    set.
  method public void WriteDB (output glog as log):
    define variable ERR as logical no-undo init no .
    run ibs/th/skt/Adapters/AdapteeWebSrv-TrnDoc.p
      (
      input table TempTrnDoc,
      input table TempDocLine,
      input table TempDocAttr,
      input table TempGdsDtl,
      input table TempParts,
      output ERR
      ) no-error.
    if ERR then
    do:
      assign
        StrLog = return-value
        .
      glog = false.
    end.
    else
      glog = true.
  end method.
  method public void SetTempTable (input table TempTrnDoc,
                                   input table TempDocLine,
                                   input table TempGdsDtl,
                                   input table TempParts,
                                   input table TempDocAttr):
  end method.
end class.
