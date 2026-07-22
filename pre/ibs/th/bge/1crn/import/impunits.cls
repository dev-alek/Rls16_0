using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impunits implements ibs.th.bge.1crn.import.iimpsubject:
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable v-rec    as recid     no-undo .
    define variable v-mode   as character no-undo .
    define variable objUnits as class     units no-undo.
    define variable v-type   as character no-undo.
    objUnits = cast (subjectObj, units).
    case objUnits:type_:
      when 1 then
        do:
          v-type = "øòó".
      end.
      when 2 then
        do:
          v-type = "âåñ".
        end.
      when 3 then
        do:
          v-type = "äğî".
        end.
      when 4 then
        do:
          v-type = "òîï" + chr(44) + 'äğî':U.
        end.
    end case.
      find first ub.units where ub.units.unit-name = objUnits:name_ no-error .
      if AVAILABLE ub.units then
      do:
        assign
          v-rec  = recid(ub.units)
          v-mode = 'ÈÇÌÅÍÅÍÈÅ':U
          .
      end.
      else
      do:
        assign
          v-rec  = ?
          v-mode = 'ÄÎÁÀÂËÅÍÈÅ':U
          .
      end.
      run ref/units01.p (
        input-output v-rec
        ,input v-mode
        ,input integer(objUnits:okei-code)
        ,input objUnits:full-name
        ,input v-type
        ,input objUnits:name_
        ) no-error.
      if error-status:error then
      do:
        Msg = return-value.
        return false.
      end.
      find first ub.units where ub.units.unit-name = objUnits:name_ no-error .
      if AVAILABLE ub.units then
      do:
      ub.units.stts = objUnits:del-l .
      end.
      return true.
  end method.
end class.
