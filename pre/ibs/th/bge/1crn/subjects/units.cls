using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.units inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property okei-code   as character    no-undo get. private set.
  define property del-l       as integer      no-undo get. private set.
  define property del-f       as integer      no-undo get. private set.
  define property name_       as character    no-undo get. private set.
  define property full-name   as character    no-undo get. private set.
  define property type_       as integer      no-undo get. private set.
  define override property InitTag as character no-undo init "unit"
    get.
  method OVERRIDE PROTECTED void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "okei-code" then do:
        assign okei-code = inValue .
      end.
      when "del-l" then do:
        assign del-l = integer (inValue).
      end.
      when "del-f" then do:
        assign del-f = integer (inValue).
      end.
      when "name" then do:
        assign name_ = inValue .
      end.
      when "full-name" then do:
        assign full-name = inValue .
      end.
      when "type" then do:
        assign type_ = integer(inValue) .
      end.
    end case.
  end.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = v-str + ",name" when name_ = ?
      v-str = v-str + ",type" when type_ = ?
    .
    v-str = trim (v-str, ",").
    if v-str > ''
    then
      undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
  end.
  method override protected void ClearSub():
    assign
      okei-code = ?
      del-l     = ?
      del-f     = ?
      name_     = ?
      full-name = ?
      type_     = ?
    .
  end.
end class.
