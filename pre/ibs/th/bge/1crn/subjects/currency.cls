USING Progress.Lang.*.
block-level on error undo, throw.
CLASS ibs.th.bge.1crn.subjects.currency inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property code_       as character    no-undo get. private set.
  define property del-l       as integer      no-undo get. private set.
  define property del-f       as integer      no-undo get. private set.
  define property name_       as character    no-undo get. private set.
  define property sym-name    as character    no-undo get. private set.
  define property name-in-words-1    as character    no-undo get. private set.
  define property name-in-words-2    as character    no-undo get. private set.
  define property name-in-words-3    as character    no-undo get. private set.
  define property name-in-words-4    as character    no-undo get. private set.
  define property name-in-words-5    as character    no-undo get. private set.
  define property name-in-words-6    as character    no-undo get. private set.
  define override property InitTag as character no-undo init "currency"
    get.
  method OVERRIDE PROTECTED void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "code" then do:
        assign code_ = inValue .
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
      when "sym-name" then do:
        assign sym-name = inValue .
      end.
      when "name-in-words-1" then do:
        assign name-in-words-1 = inValue .
      end.
      when "name-in-words-2" then do:
        assign name-in-words-2 = inValue .
      end.
      when "name-in-words-3" then do:
        assign name-in-words-3 = inValue .
      end.
      when "name-in-words-4" then do:
        assign name-in-words-4 = inValue .
      end.
      when "name-in-words-5" then do:
        assign name-in-words-5 = inValue .
      end.
      when "name-in-words-6" then do:
        assign name-in-words-6 = inValue .
      end.
    end case.
  end.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = "code" when code_ = ?
      v-str = v-str + ",name" when name_ = ?
    .
    v-str = trim (v-str, ",").
    if v-str > ''
    then
      undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
  end.
  method override protected void ClearSub():
    assign
      code_     = ?
      del-l     = ?
      del-f     = ?
      name_     = ?
      sym-name  = ?
      name-in-words-1     = ?
      name-in-words-2     = ?
      name-in-words-3     = ?
      name-in-words-4     = ?
      name-in-words-5     = ?
      name-in-words-6     = ?
    .
  end.
END CLASS.
