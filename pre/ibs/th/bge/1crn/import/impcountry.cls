using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.bge.1crn.import.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impcountry implements ibs.th.bge.1crn.import.iimpsubject:
  define buffer buf_cnt for ub.country.
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable v-doc-rec  as recid     no-undo.
    define variable result     as logical   no-undo.
    define variable mode       as character no-undo.
    define variable objCountry as class     country no-undo.
    objCountry = cast (subjectObj, country).
    find first buf_cnt where buf_cnt.num-code = integer (objCountry:code_) no-error.
    if available (buf_cnt)
    then do:
      if objCountry:del-f = integer (true)
      then do:
        delete buf_cnt.
        result = true.
        return result.
      end.
      assign
        mode = 'хглемемхе':U
        v-doc-rec = recid (buf_cnt).
    end.
      else mode = 'днаюбкемхе':U.
    run ref/country1.p (
      input-output v-doc-rec
      ,input mode
      ,input objCountry:alfa2
      ,input objCountry:alfa3
      ,input integer (objCountry:code_)
      ,input objCountry:name_
      ,input objCountry:full-name
      ) no-error.
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
