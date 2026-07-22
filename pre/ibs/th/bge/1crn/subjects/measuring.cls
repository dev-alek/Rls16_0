using Progress.Lang.*.
using ibs.th.bge.1crn.enum-deg-auto.
using ibs.th.bge.1crn.enum-dnst-ms-type.
using ibs.th.bge.1crn.enum-level-ms-type.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.measuring inherits ibs.th.bge.1crn.subjects.asubject:
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
  define property deg-auto as enum-deg-auto no-undo
    get.
    private set.
  define property name_ as character no-undo
    get.
    private set.
  define property dimension-level as integer no-undo
    get.
    private set.
  define property dimension-temp as integer no-undo
    get.
    private set.
  define property dimension-dnst as integer no-undo
    get.
    private set.
  define property dimension-wght as integer no-undo
    get.
    private set.
  define property level-ms-type as enum-level-ms-type no-undo
    get.
    private set.
  define property level-tk as decimal no-undo
    get.
    private set.
  define property level-abs-me as decimal no-undo
    get.
    private set.
  define property level-rel-me-np as decimal no-undo
    get.
    private set.
  define property level-abs-me-wtr as decimal no-undo
    get.
    private set.
  define property level-rel-me-wtr as decimal no-undo
    get.
    private set.
  define property temp-abs-me-vlm as decimal no-undo
    get.
    private set.
  define property temp-abs-me-dnst as decimal no-undo
    get.
    private set.
  define property dnst-ms-type as enum-dnst-ms-type no-undo
    get.
    private set.
  define property dnst-abs-me-np as decimal no-undo
    get.
    private set.
  define property dnst-rel-me-np as decimal no-undo
    get.
    private set.
  define property dnst-abs-me-lpg-l as decimal no-undo
    get.
    private set.
  define property dnst-rel-me-lpg-l as decimal no-undo
    get.
    private set.
  define property dnst-abs-me-lpg-v as decimal no-undo
    get.
    private set.
  define property wght-rel-me as decimal no-undo
    get.
    private set.
  define property limit as decimal no-undo
    get.
    private set.
  define override property InitTag as character no-undo init "measuring"
    get.
  method override protected void SetPropProtected (inTag as char, inValue as char):
   case inTag:
      when "code"              then code_           = if inValue >= "" then inValue else "" .
      when "del-l"             then del-l           = if inValue >= "" then integer (inValue) else 0.
      when "del-f"             then del-f           = if inValue >= "" then integer (inValue) else 0.
      when "deg-auto"          then do:
         if inValue >= "" then deg-auto = enum-deg-auto:GetEnum(integer(inValue)) .
                          else deg-auto = enum-deg-auto:GetEnum(0) .
      end.
      when "name"              then name_           = if inValue >= "" then inValue else "" .
      when "dimension-level"   then dimension-level = if inValue >= "" then integer (inValue) else 0.
      when "dimension-temp"    then dimension-temp  = if inValue >= "" then integer (inValue) else 0.
      when "dimension-dnst"    then dimension-dnst  = if inValue >= "" then integer (inValue) else 0.
      when "dimension-wght"    then dimension-wght  = if inValue >= "" then integer (inValue) else 0.
      when "level-ms-type"     then do:
         if inValue >= "" then level-ms-type = enum-level-ms-type:GetEnum(integer(inValue)) .
                          else level-ms-type = enum-level-ms-type:GetEnum(0) .
      end.
      when "level-tk"          then level-tk         = if inValue >= "" then decimal (inValue) else 0.
      when "level-abs-me"      then level-abs-me  = if inValue >= "" then decimal (inValue) else 0.
      when "level-rel-me-np"   then level-rel-me-np  = if inValue >= "" then decimal (inValue) else 0.
      when "level-abs-me"      then level-abs-me     = if inValue >= "" then decimal (inValue) else 0.
      when "level-abs-me-wtr"  then level-abs-me-wtr = if inValue >= "" then decimal (inValue) else 0.
      when "level-rel-me-wtr"  then level-rel-me-wtr = if inValue >= "" then decimal (inValue) else 0.
      when "temp-abs-me-vlm"   then temp-abs-me-vlm  = if inValue >= "" then decimal (inValue) else 0.
      when "temp-abs-me-dnst"  then temp-abs-me-dnst = if inValue >= "" then decimal (inValue) else 0.
      when "dnst-ms-type"      then do:
         if inValue >= "" then dnst-ms-type = enum-dnst-ms-type:GetEnum(integer(inValue)) .
                          else dnst-ms-type = enum-dnst-ms-type:GetEnum(0) .
      end.
      when "dnst-abs-me-np"    then dnst-abs-me-np    = if inValue >= "" then decimal (inValue) else 0.
      when "dnst-rel-me-np"    then dnst-rel-me-np    = if inValue >= "" then decimal (inValue) else 0.
      when "dnst-abs-me-lpg-l" then dnst-abs-me-lpg-l = if inValue >= "" then decimal (inValue) else 0.
      when "dnst-rel-me-lpg-l" then dnst-rel-me-lpg-l = if inValue >= "" then decimal (inValue) else 0.
      when "dnst-abs-me-lpg-v" then dnst-abs-me-lpg-v = if inValue >= "" then decimal (inValue) else 0.
      when "wght-rel-me"       then wght-rel-me       = if inValue >= "" then decimal (inValue) else 0.
      when "limit"             then limit             = if inValue >= "" then decimal (inValue) else 0 .
    end case.
    catch exProErrors as class Progress.Lang.ProError :
      case exProErrors:GetMessageNum(1):
        when 18207 then undo, throw new Progress.Lang.AppError(
          substitute("Поле <&1> содержит ошибочное значение [&2]", inTag, inValue)
        ) .
        otherwise undo, throw new Progress.Lang.AppError(
          substitute("Ошибка значения для поля <&1>: &2", inTag, exProErrors:GetMessage(1))
        ) .
      end case .
    end catch .
  end method.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = ",code"                      when code_             = ?
      v-str = v-str + ",deg-auto"          when deg-auto          = ?
      v-str = v-str + ",name"              when name_             = ?
      v-str = v-str + ",level-ms-type"     when level-ms-type     = ? and dimension-level   = 1
      v-str = v-str + ",level-abs-me"      when level-abs-me      = ? and dimension-level = 1
             and (deg-auto = enum-deg-auto:GetEnum(0) or deg-auto = enum-deg-auto:GetEnum(2))
      v-str = v-str + ",level-abs-me-wtr"  when level-abs-me-wtr  = ? and dimension-level = 1
             and (deg-auto = enum-deg-auto:GetEnum(0) or deg-auto = enum-deg-auto:GetEnum(2))
      v-str = v-str + ",temp-abs-me-vlm"   when temp-abs-me-vlm   = ? and dimension-temp    = 1
      v-str = v-str + ",temp-abs-me-dnst"  when temp-abs-me-dnst  = ? and dimension-temp    = 1
      v-str = v-str + ",dnst-ms-type"      when dnst-ms-type      = ? and dimension-dnst    = 1
      v-str = v-str + ",wght-rel-me"       when wght-rel-me       = ? and dimension-wght    = 1
      v-str = v-str + ",limit"             when limit             = ?
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method.
  method override protected void ClearSub():
    assign
      code_             = ?
      del-l             = ?
      del-f             = ?
      deg-auto          = ?
      name_             = ?
      dimension-level   = 0
      dimension-temp    = 0
      dimension-dnst    = 0
      dimension-wght    = 0
      level-ms-type     = ?
      level-tk          = ?
      level-abs-me      = ?
      level-rel-me-np   = ?
      level-abs-me-wtr  = ?
      level-rel-me-wtr  = ?
      temp-abs-me-vlm   = ?
      temp-abs-me-dnst  = ?
      dnst-ms-type      = ?
      dnst-abs-me-np    = ?
      dnst-rel-me-np    = ?
      dnst-abs-me-lpg-l = ?
      dnst-rel-me-lpg-l = ?
      dnst-abs-me-lpg-v = ?
      wght-rel-me       = ?
      limit             = ?
    .
  end method.
end class.
