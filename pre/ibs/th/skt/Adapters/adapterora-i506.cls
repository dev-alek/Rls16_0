using Progress.Lang.*.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.
class ibs.th.skt.Adapters.AdapterOra-i506 implements IAdapter:
define temp-table TempTrnDoc no-undo
  field line-num     as integer
  field ext-doc-code as character
  field doc-date     as date
  field ext-doc-type as character
  field cli-type     as character
  field cli-code     as integer
  field obj-type     as character
  field obj-code     as integer
  field ps           as character
  field Status_      as character
  field Flags_       as integer
  index pi line-num ext-doc-code .
define temp-table TempDocLine no-undo
  field line-num     as integer
  field gds-code     as integer
  field doc-qnty     as decimal
  field fact-qnty    as decimal
  field price-rubl   as decimal
  field RowSum       as decimal
  field vat-pc       as decimal
  field b-code       as character
  field is-tsd-qnty  as logical   init no
  field aclMarksList as character
  field PartIDTH     as character
  field Flags_       as integer
  field NotDict      as logical
  index pi
  line-num
  gds-code
  .
define temp-table TempDocLineIsTSD like TempDocLine.
define temp-table TempDocLineTSD no-undo
  field gds-code     as integer
  field doc-qnty     as decimal
  field fact-qnty    as decimal
  field artic        as character
  field prod-code    as integer
  field prod-type    as character
  field Flags_error  as logical
  field mark-type    as character
  field mark         as character
  field mark-parent  as character
  index pi
  artic
  prod-code
  prod-type
  mark
  .
define temp-table TempMarkLine no-undo
  field DocName    as character
  field MarkCode   as character
  field PartIDTH   as character
  field Sts        as character
  field MarkParent as character
  field QntyBox    as character
  index pi
  DocName
  MarkCode
  .
  define temp-table TempTSDSetting no-undo
  field sn   as character
  field obj-code  as integer
  field obj-type as character
  field version_ as character
  field lastDate as datetime
  index pi
  sn
  .
  define property StrLog as character no-undo
    get.
    set.
  define property UserId_ as character no-undo
    get.
    set.
  method public void WriteDB (output glog as log):
    run ibs/th/skt/Adapters/AdapteeProcOra-i506.p
      (
      input table TempTrnDoc,
      input table TempDocLine,
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
  method public void SetTempTable (input table TempTrnDoc, input table TempDocLine, input userId_ as char):
    UserId_ = userId_.
  end method.
end class.
