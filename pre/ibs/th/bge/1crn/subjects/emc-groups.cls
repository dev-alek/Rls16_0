using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.emc-groups inherits ibs.th.bge.1crn.subjects.code:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override property InitTag as character no-undo init "emc-group"
  get.
          define var emctype-code as integer no-undo.
  define var emctype-name as char    no-undo.
  method override protected void SetPropProtected (inTag as char, inValue as char):
    super:SetPropProtected(inTag, inValue).
    case inTag:
      when "emctype-code" then do:
        assign emctype-code = if inValue >= "" then integer (inValue) else 0
               code_   = string(emctype-code,"999")
               old_code_ = code_
               parent_ = "EMC"
               old_parent_  = parent_
               CodeValue = string(emctype-code,"999")
               .
      end.
      when "emctype-name" then do:
        assign
        emctype-name = if inValue >= "" then inValue else ""
        codeName = emctype-name
        .
      end.
      when "del-l" then do:
         assign del-l = if inValue >= "" then integer (inValue) else 0
         .
         if del-l = 1 then  codeName = emctype-name + " (удален)" .
      end.
    end case.
  end method.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    define buffer code for ub.Code.
    assign
      v-str = "emctype-code" when emctype-code = ?
      v-str = v-str + ", emctype-name" when emctype-name = ""
    .
    v-str = trim (v-str, ",").
    if v-str > ''
    then
      undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
  end method.
end class.
