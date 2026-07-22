using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impcurrency implements ibs.th.bge.1crn.import.iimpsubject:
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    def    var      v-rec       as recid   no-undo .
    def    var      v-curr-code as integer no-undo .
    define variable objCurrency as class   currency no-undo.
    objCurrency = cast (subjectObj, currency).
    if objCurrency:del-f = 1 then
    do:
      find first ub.currency where ub.currency.okv-code = integer(objCurrency:code_) no-error .
      if AVAILABLE ub.currency then
      do:
        delete ub.currency .
      end.
    end.
    else
    do:
      find first ub.currency where ub.currency.okv-code = integer(objCurrency:code_) no-error .
      if AVAILABLE ub.currency then
      do:
        v-rec = recid(ub.currency) .
        run ref/currenc1.p (
          input-output v-rec
          ,input 'хглемемхе':U
          ,input true
          ,input ub.currency.curr-code
          ,input ub.currency.curr-abbr
          ,input ub.currency.part-abbr
          ,input objCurrency:name_
          ,input objCurrency:name-in-words-1
          ,input objCurrency:name-in-words-2
          ,input objCurrency:name-in-words-3
          ,input ub.currency.curr-eng-name
          ,input ub.currency.curr-eng-name-one
          ,input ub.currency.curr-eng-name-three
          ,input ub.currency.curr-eng-name-five
          ,input ub.currency.part-name
          ,input objCurrency:name-in-words-4
          ,input objCurrency:name-in-words-5
          ,input objCurrency:name-in-words-6
          ,input objCurrency:code_
          ,input ""
          ) no-error .
        if error-status:error then
        do:
          Msg = return-value.
          return false.
        end.
      end.
      else
      do:
        find last ub.currency no-error .
        if AVAILABLE ub.currency then
        do:
          v-curr-code = ub.currency.curr-code + 1 .
        end.
        else
        do:
          v-curr-code = 0 .
        end.
          v-rec = ?.
        run ref/currenc1.p (
          input-output v-rec
          ,input 'днаюбкемхе':U
          ,input true
          ,input v-curr-code
          ,input objCurrency:sym-name
          ,input ""
          ,input objCurrency:name_
          ,input objCurrency:name-in-words-1
          ,input objCurrency:name-in-words-2
          ,input objCurrency:name-in-words-3
          ,input ""
          ,input ""
          ,input ""
          ,input ""
          ,input ""
          ,input objCurrency:name-in-words-4
          ,input objCurrency:name-in-words-5
          ,input objCurrency:name-in-words-6
          ,input objCurrency:code_
          ,input ""
          ) no-error .
        if error-status:error then
        do:
          Msg = return-value.
          return false.
        end.
      end.
      return true.
    end.
  end method.
end class.
