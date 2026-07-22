using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.shops inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property code_ as character no-undo
    get.
    private set.
  define property del-l as integer no-undo
    get.
    private set.
  define property del-f as integer no-undo
    get.
    private set.
  define property name_ as character no-undo
    get.
    private set.
define property hist-code as character no-undo
    get.
    private set.
define property hist-name as character no-undo
    get.
    private set.
  define property frm-code as character no-undo
    get.
    private set.
  define property grp-code as character no-undo
    get.
    private set.
  define property address as character no-undo
    get.
    private set.
  define property tel as character no-undo
    get.
    private set.
  define property director as character no-undo
    get.
    private set.
  define property accr as character no-undo
    get.
    private set.
  define property cafe_exist as integer no-undo
    get.
    private set.
  define property clim-grp as character no-undo
    get.
    private set.
  define property begin-summer as character no-undo
    get.
    private set.
  define property begin-winter as character no-undo
    get.
    private set.
  define property decommissioned as integer no-undo
    get.
    private set.
  define property kpp as character no-undo
    get.
    private set.
  define property edi as integer no-undo
    get.
    private set.
  define override property InitTag as character no-undo init "azk"
    get.
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "code"           then code_          = if inValue >= "" then inValue else "" .
      when "del-l"          then del-l          = if inValue >= "" then integer (inValue) else 0 .
      when "del-f"          then del-f          = if inValue >= "" then integer (inValue) else 0 .
      when "name"           then name_          = if inValue >= "" then inValue else "" .
      when "hist-code"      then Hist-code      = if inValue >= "" then inValue else "" .
      when "hist-name"      then hist-name      = if inValue >= "" then inValue else "" .
      when "frm-code"       then frm-code       = if inValue >= "" then inValue else "" .
      when "grp-code"       then grp-code       = if inValue >= "" then inValue else "" .
      when "address"        then address        = if inValue >= "" then inValue else "" .
      when "tel"            then tel            = if inValue >= "" then inValue else "" .
      when "director"       then director       = if inValue >= "" then inValue else "" .
      when "accr"           then accr           = if inValue >= "" then inValue else "" .
      when "cafe_exist"     then cafe_exist     = if inValue >= "" then integer (inValue) else 0 .
      when "clim-grp"       then clim-grp       = if inValue >= "" then inValue else "" .
      when "begin-summer"   then begin-summer   = if inValue >= "" then inValue else "" .
      when "begin-winter"   then begin-winter   = if inValue >= "" then inValue else "" .
      when "decommissioned" then decommissioned = if inValue >= "" then integer (inValue) else 0 .
      when "kpp"            then kpp            = if inValue >= "" then inValue else "" .
      when "edi"            then edi            = if inValue >= "" then integer (inValue) else 0 .
    end case.
  end method.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = ",code" when code_ = ?
      v-str = v-str + ",name" when name_ = ?
      v-str = v-str + ",frm-code" when frm-code = ?
      v-str = v-str + ",clim-grp" when clim-grp = ?
      v-str = v-str + ",begin-summer" when begin-summer = ?
      v-str = v-str + ",begin-winter" when begin-winter = ?
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method.
  method override protected void ClearSub():
    assign
      code_      = ?
      del-l      = ?
      del-f      = ?
      name_      = ?
      frm-code   = ?
      hist-name  = ?
      hist-code  = ?
      grp-code   = ?
      address    = ?
      tel        = ?
      director   = ?
      accr       = ?
      cafe_exist = ?
      clim-grp       = ?
      begin-summer   = ?
      begin-winter   = ?
      decommissioned = ?
      kpp        = ?
      edi        = ?
    .
  end method.
end class.
