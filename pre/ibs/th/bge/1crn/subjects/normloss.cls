using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.normloss inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property type_ as integer no-undo
    get.
    private set.
  define property clim-grp as character no-undo
    get.
    private set.
  define property position_ as integer no-undo
    get.
    private set.
  define property sec-vol1 as decimal no-undo
    get.
    private set.
  define property sec-vol2 as decimal no-undo
    get.
    private set.
  define property oil-grp as character no-undo
    get.
    private set.
  define property season_ as integer no-undo
    get.
    private set.
  define property value_ as decimal no-undo
    get.
    private set.
  define override property InitTag as character no-undo init "norm-loss"
    get.
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "type" then
        do:
          assign
            type_ = integer(inValue).
        end.
      when "clim-grp" then
        do:
          assign
            clim-grp = inValue.
        end.
      when "position" then
        do:
          assign
            position_ = integer (inValue).
        end.
      when "sec-vol" then
        do:
          if num-entries(inValue,"-") > 1 then do:
          assign
            sec-vol1 = decimal(entry(1,inValue,"-"))
            sec-vol2 = decimal(entry(2,inValue,"-"))
            .
           end.
           else do:
          assign
            sec-vol1 = decimal(inValue)
            sec-vol2 = 0
            .
           end.
        end.
      when "oil-grp" then
        do:
          assign
            oil-grp = inValue .
        end.
      when "season" then
        do:
          assign
            season_ = integer(inValue) .
        end.
      when "value" then
        do:
          assign
            value_ = decimal(inValue) .
        end.
    end case.
  end.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = "type"
      when type_ = ?
      v-str = v-str + ",clim-grp"
      when clim-grp = ?
      v-str = v-str + ",oil-grp"
      when oil-grp = ?
      v-str = v-str + ",season"
      when season_ = ?
      .
    v-str = trim (v-str, ",").
    if v-str > ''
      then
      undo, throw new Progress.Lang.AppError( substitute ("“еги &1 не могут иметь неопределное значение", v-str)).
  end.
  method override protected void ClearSub():
    assign
      type_     = ?
      clim-grp  = ?
      position_ = ?
      sec-vol1  = ?
      sec-vol2  = ?
      oil-grp   = ?
      season_   = ?
      value_    = ?
      .
  end.
end class.
