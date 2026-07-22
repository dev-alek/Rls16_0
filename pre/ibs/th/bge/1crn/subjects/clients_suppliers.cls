using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
using ibs.th.bge.1crn.subjects.clients_suppliers from propath.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.clients_suppliers inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property code_       as integer    no-undo get.
    private set.
  define override property InitTag as character no-undo init "nb-supplier"
    get.
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "code" then
        do:
          assign
            code_ = integer(inValue) .
        end.
     end case.
  end.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = v-str + ",code"
      when code_ = ?
      .
    v-str = trim (v-str, ",").
    if v-str > ''
      then
      undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
  end.
  method override protected void ClearSub():
    assign
      code_         = ?
      .
  end.
end class.
