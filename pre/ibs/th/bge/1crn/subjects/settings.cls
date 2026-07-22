using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.settings inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property org-code as character no-undo
    get.
    private set.
  define property MaxApiToken as character no-undo
    get.
    private set.
  define override property InitTag as character no-undo init "setting"
    get.
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "org-code"    then org-code    = if inValue >= "" then inValue else "" .
      when "MaxApiToken" then MaxApiToken = if inValue >= "" then inValue else "" .
    end case.
  end method.
  method override protected void CheckData ():
  end method.
  method override protected void ClearSub():
    assign
      org-code    = ?
      MaxApiToken = ?
    .
  end method.
end class.
