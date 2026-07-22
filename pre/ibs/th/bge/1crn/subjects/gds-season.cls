using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.gds-season inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property Tbg-code    as character    no-undo get. private set.
  define property del-l       as integer      no-undo get. private set.
  define property del-f       as integer      no-undo get. private set.
  define property gds-code    as character    no-undo get. private set.
  define override property InitTag as character no-undo init "Tb-gd"
    get.
  method OVERRIDE PROTECTED void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "Tbg-code" then do:
        assign Tbg-code = inValue .
      end.
      when "del-l" then do:
        assign del-l = integer (inValue).
      end.
      when "del-f" then do:
        assign del-f = integer (inValue).
      end.
      when "gds-code" then do:
        assign gds-code = inValue .
      end.
    end case.
  end.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = "Tbg-code" when Tbg-code = ?
      v-str = v-str + ",gds-code" when gds-code = ?
    .
    v-str = trim (v-str, ",").
    if v-str > ''
    then
      undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
  end.
  method override protected void ClearSub():
    assign
      Tbg-code  = ?
      del-l     = ?
      del-f     = ?
      gds-code  = ?
    .
  end.
end class.
