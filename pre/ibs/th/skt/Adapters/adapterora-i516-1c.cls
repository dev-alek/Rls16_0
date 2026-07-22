using Progress.Lang.*.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.
class ibs.th.skt.Adapters.AdapterOra-i516-1c implements IAdapter:
  define temp-table TempTrnDoc no-undo
    field line-num      as integer
    field ext-doc-code  as character
    field doc-date      as date
    field ext-doc-type  as character
    field cli-type      as character
    field cli-code      as integer
    field obj-type      as character
    field obj-code      as integer
    field ps            as character
    field doc-id        as character
    field dog-code      as character
    field source-doc    as character
    field out-code      as character
    index pi line-num ext-doc-code
  .
  define temp-table TempDocLine no-undo
    field line-num     as integer
    field gds-code     as integer
    field doc-qnty     as decimal
    field fact-qnty    as decimal
    field price-rubl   as decimal
    field RowSum       as decimal
    field vat-pc       as decimal
    field fact-dnsty   as decimal
    field cli-qnty     as decimal
    field koef         as decimal
    field unit-code    as character
    field b-code       as character
    field is-tsd-qnty  as logical init no
    field vsd-uuid     as character
    field part-id      as character
    field aclMarksList as character
    field PartIDTH     as character
    index pi
    line-num
    gds-code
  .
  define temp-table TempDocPart no-undo
    field gds-code     as integer
    field doc-qnty     as decimal
    field fact-qnty    as decimal
    field price-rubl   as decimal
    field vat-pc       as decimal
    field fact-dnsty   as decimal
    field vsd-uuid     as character
    field part-id      as character
    field in-doc-id    as character
    field edoc-id      as character
    index pi
    in-doc-id
    part-id
    gds-code
  .
  define temp-table TempDocMark no-undo
    field gtin as character
    field gtin_qnt as integer
    field upd_id as character
    field prt-id as character
    field in-doc-id as character
    field mark as character
    field gds-code as integer
    index pi mark
  .
  define property StrLog as character no-undo
    get.
    set.
  define property UserId_ as character no-undo
    get.
    set.
  method public void WriteDB (output glog as log):
    run ibs/th/skt/Adapters/AdapteeProcOra-i516-1c.p
      (
      input table TempTrnDoc,
      input table TempDocLine,
      input table TempDocPart,
      input table TempDocMark,
      input UserId_
      ) no-error.
    if error-status:error then
    do:
      assign
        StrLog = return-value
        .
      glog = false.
    end.
    else
      glog = true.
  end method.
  method public void SetTempTable (input table TempTrnDoc, input table TempDocLine, input table TempDocPart, input table TempDocMark, userId_ as char):
    UserId_ = userId_.
  end method.
end class.
