using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.bge.1crn.import.*.
using ibs.th.skt.Adapters.AdapterOra-i516-1c from propath.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.imptrn-fuel-doc implements ibs.th.bge.1crn.import.iimpsubject:
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
  define buffer buf_clients for ub.clients.
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable v-doc-rec as recid     no-undo.
    define variable result    as logical   no-undo.
    define variable glog      as logical   no-undo.
    define variable mode      as character no-undo.
    define variable ii        as integer   no-undo.
    define variable objTrnDoc  as class     trn-fuel-doc-in no-undo.
    define variable objGd      as class     trn-gd-fuel     no-undo.
    define variable adapObj    as class     AdapterOra-i516-1c no-undo.
    define variable objGds     as class     subjects        no-undo.
    objTrnDoc = cast (subjectObj, trn-fuel-doc-in).
    adapObj = new AdapterOra-i516-1c ().
    find first ub.sys-ctrl.
    empty temp-table TempTrnDoc.
    empty temp-table TempDocLine.
    empty temp-table TempDocMark.
    find first buf_clients where buf_clients.db-num = ub.sys-ctrl.db-num.
    create TempTrnDoc.
    assign
      TempTrnDoc.obj-type = buf_clients.obj-type
      TempTrnDoc.obj-code = buf_clients.obj-code
      TempTrnDoc.cli-code = integer (objTrnDoc:fuel-st-code)
      TempTrnDoc.cli-type = "маг"
      TempTrnDoc.doc-date = objTrnDoc:doc-date
      TempTrnDoc.ext-doc-code = replace (objTrnDoc:doc-code, "-", "=").
      TempTrnDoc.doc-id = objTrnDoc:doc-id
    .
    case trim (objTrnDoc:doc-type, '0'):
      when '4' then do:
        TempTrnDoc.ext-doc-type = 'ie':U .
      end.
      otherwise do:
        Msg = "Не поддерживаемый тип документа на загрузку: " + objTrnDoc:doc-type.
        return false.
      end.
    end case.
    objGds = objTrnDoc:GDS.
    do ii = 1 to objGds:Get(ii):
      objGd = cast (objGds:SubjectObjCurr, trn-gd-fuel).
      create TempDocLine.
      assign
        TempDocLine.gds-code = objGd:gd-code
        TempDocLine.fact-qnty = objGd:cap-fact
        TempDocLine.doc-qnty = objGd:cap-fact
        TempDocLine.price-rubl = round (objGd:sum / objGd:cap-fact, 2)
        TempDocLine.fact-dnsty = objGd:dnsty-fact
        TempDocLine.cli-qnty = objGd:wght-fact
      .
    end.
    adapObj:SetTempTable(table TempTrnDoc, table TempDocLine, table TempDocPart, table TempDocMark, "").
    adapObj:WriteDB(output glog).
    if error-status:error then
    do:
      Msg = return-value.
      result = false.
    end.
    else do:
      result = true.
    end.
    return result.
  end method.
end class.
