using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
USING ibs.th.gbl.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impfuelcodeinfo implements ibs.th.bge.1crn.import.iimpsubject:
   define buffer buf_code       for ub.code .
   define property Msg as character no-undo
      get.
      set.
   method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
      define variable ri              as recid no-undo .
      define variable objfuelcodeinfo as class fuelcodeinfo no-undo.
      objFuelCodeInfo = cast (subjectObj, fuelcodeinfo).
      find first buf_code exclusive-lock where
                 buf_code.parent = "FuelCodeInfo"
             and buf_code.code = string(integer(objfuelcodeinfo:IntCode))
           no-error .
      if    objfuelcodeinfo:del-f = 0
         or objfuelcodeinfo:del-f = ? then
      do:
          if not avail buf_code then
          do:
              create buf_code.
              assign
                buf_code.parent  = "FuelCodeInfo"
                buf_code.code    = string(integer(objfuelcodeinfo:IntCode))
                buf_code.status_ = 0
              .
          end.
          buf_code.CodeValue  = string(integer(objfuelcodeinfo:ExtCode)).
      end.
      else
      do:
        if avail buf_code then
            delete buf_code.
      end.
   end method.
end class.
