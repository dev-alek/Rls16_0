using Progress.Lang.*.
using ibs.th.bge.1crn.enum-recipe-status.
using ibs.th.bge.1crn.enum-recipe-type.
using ibs.th.bge.1crn.subjects.subjects from propath.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.recipe inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property del-l as integer no-undo
    get.
    private set.
  define property del-f as integer no-undo
    get.
    private set.
  define property status_ as enum-recipe-status no-undo
    get.
    private set.
  define property recipe-code as character no-undo
    get.
    private set.
  define property recipe-type as enum-recipe-type no-undo
    get.
    private set.
  define property recipe-name as character no-undo
    get.
    private set.
  define property recipe-num as character no-undo
    get.
    private set.
  define property gd-code as character no-undo
    get.
    private set.
  define property qnty-netto as decimal no-undo
    get.
    private set.
  define property qnty as integer no-undo
    get.
    private set.
  define property weight as decimal no-undo
    get.
    private set.
  define property main as integer no-undo
    get.
    private set.
  define property recipe-gds as subjects no-undo
    get.
    private set.
  define override property InitTag as character no-undo init "recipe"
    get.
  constructor public recipe ():
    InitListTag = "recipe-gds".
  end constructor.
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "recipe-code" then recipe-code = if inValue >= "" then inValue else "" .
      when "gd-code"     then gd-code     = if inValue >= "" then inValue else "" .
      when "del-l"       then del-l       = if inValue >= "" then integer (inValue) else 0 .
      when "del-f"       then del-f       = if inValue >= "" then integer (inValue) else 0 .
      when "status"      then do:
        if inValue >= "" then status_     = enum-recipe-status:GetEnum( integer (inValue) ) .
                         else status_     = enum-recipe-status:enopen .
      end .
      when "qnty"        then qnty        = if inValue >= "" then integer (inValue) else 0 .
      when "qnty-netto"  then qnty-netto  = if inValue >= "" then decimal (inValue) else 0.0 .
      when "recipe-name" then recipe-name = if inValue >= "" then inValue else "" .
      when "recipe-type" then do :
        if inValue >= "" then recipe-type = enum-recipe-type:GetEnum( integer (inValue) ) .
                         else recipe-type = enum-recipe-type:enmanufacturing .
      end .
      when "recipe-num"  then recipe-num  = if inValue >= "" then inValue else "" .
      when "weight"      then weight      = if inValue >= "" then decimal (inValue) else 0.0 .
      when "main"        then main        = if inValue >= "" then integer (inValue) else 0 .
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
  method override protected void SetPropProtected (SubsObj as subjects):
    case SubsObj:InitTag:
      when "recipe-gds" then recipe-gds = SubsObj.
    end case.
  end method.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = ",recipe-code" when recipe-code = ?
      v-str = v-str + ",gd-code" when gd-code = ?
      v-str = v-str + ",recipe-gds" when not valid-object(recipe-gds)
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method.
  method override protected void ClearSub():
    assign
      recipe-code = ?
      gd-code     = ?
      del-l       = ?
      del-f       = ?
      qnty        = ?
      qnty-netto  = ?
      recipe-name = ?
      recipe-type = ?
      recipe-num  = ?
      weight      = ?
      main        = ?
    .
    if valid-object(recipe-gds) then delete object recipe-gds .
  end method.
end class.
