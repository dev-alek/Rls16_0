using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.recipe-gd inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property gd-code as character no-undo
    get.
    private set.
  define property unit-code as character no-undo
    get.
    private set.
  define property qnty-net as decimal no-undo
    get.
    private set.
  define property qnty-gross as decimal no-undo
    get.
    private set.
  define property lf as decimal no-undo
    get.
    private set.
  define property gds-recipe-code as character no-undo
    get.
    private set.
  define property seasonal-losses as decimal no-undo
    get.
    private set.
  define property weight-gross    as decimal no-undo
    get.
    private set.
  define property wst as integer no-undo
    get.
    private set.
  define override property InitTag as character no-undo init "recipe-gd"
    get.
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "gd-code"    then gd-code    = if inValue >= "" then inValue else "" .
      when "unit-code"  then unit-code  = if inValue >= "" then inValue else "" .
      when "qnty-net"   then qnty-net   = if inValue >= "" then decimal(inValue) else 0.0 .
      when "qnty-gross" then qnty-gross = if inValue >= "" then decimal(inValue) else 0.0 .
      when "lf"         then lf         = if inValue >= "" then decimal(inValue) else 0.0 .
      when "seasonal-losses" then seasonal-losses = if inValue >= "" then decimal(inValue) else 0.0 .
      when "weight-gross"    then weight-gross    = if inValue >= "" then decimal(inValue) else 0.0 .
      when "recipe-code" then gds-recipe-code = if inValue >= "" then inValue else "" .
      when "wst"        then wst        = if inValue >= "" then integer (inValue) else 0 .
    end case.
  end method.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = ",gd-code" when gd-code = ?
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method.
  method override protected void ClearSub():
    assign
      gd-code         = ?
      unit-code       = ?
      qnty-net        = ?
      qnty-gross      = ?
      lf              = ?
      gds-recipe-code = ?
      seasonal-losses = ?
      weight-gross    = ?
      wst             = ?
    .
  end method.
end class.
