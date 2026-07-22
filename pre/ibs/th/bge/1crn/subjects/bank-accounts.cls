USING Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
using ibs.th.bge.1crn.subjects.bank-accounts from propath.
using ibs.th.bge.1crn.subjects.bank-accounts_bank from propath.
using ibs.th.bge.1crn.subjects.isubject from propath.
block-level on error undo, throw.
CLASS ibs.th.bge.1crn.subjects.bank-accounts inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property r-schet     as character    no-undo get.
    private set.
  define property del-l       as integer      no-undo get.
    private set.
  define property del-f       as integer      no-undo get.
    private set.
  define property cont-code   as character    no-undo get.
    private set.
  define property bank        as bank-accounts_bank     no-undo get .
    private set .
  define override property InitTag as character no-undo init "bank-account"
    get.
  constructor public bank-accounts ():
    InitListTag = "bank".
  end constructor.
  method OVERRIDE PROTECTED void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "r-schet" then
        do:
          assign
            r-schet = inValue .
        end.
      when "del-l" then
        do:
          assign
            del-l = integer (inValue).
        end.
      when "del-f" then
        do:
          assign
            del-f = integer (inValue).
        end.
      when "cont-code" then
        do:
          assign
            cont-code = inValue .
        end.
    end case.
  end.
  method override protected void SetPropProtected(SubsObj as isubject):
    bank = cast (SubsObj, bank-accounts_bank).
  end.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = "r-schet"
      when r-schet = ?
      v-str = v-str + ",cont-code"
      when cont-code = ?
      .
    v-str = trim (v-str, ",").
    if v-str > ''
      then
      undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
  end.
  method override protected void ClearSub():
    assign
      r-schet   = ?
      del-l     = ?
      del-f     = ?
      cont-code = ?
      .
    delete object bank no-error .
  end.
END CLASS.
