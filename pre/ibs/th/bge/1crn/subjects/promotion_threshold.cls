block-level on error undo, throw.
using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
class ibs.th.bge.1crn.subjects.promotion_threshold inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property value_      as decimal    no-undo get. private set.
  define property valueupto   as decimal    no-undo get. private set.
  define property dscnt       as decimal    no-undo get. private set.
  define property message_    as character  no-undo get. private set.
  define property message-gks as character  no-undo get. private set.
  define property Gifts as subjects no-undo
    get.
    private set.
  define override property InitTag as character no-undo init "threshold"
    get.
  constructor public promotion_threshold ():
    InitListTag = "Gifts".
  end constructor.
          method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "value"   then value_   = if inValue >= "" then decimal (inValue) else 0.0 .
      when "valueupto"   then valueupto   = if inValue >= "" then decimal (inValue) else 0.0 .
      when "dscnt"   then dscnt    = if inValue >= "" then decimal (inValue) else 0.0 .
      when "message" then message_ = if inValue >= "" then inValue else "" .
      when "message-gks" then message-gks = if inValue >= "" then inValue else "" .
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
      when "Gifts" then Gifts = SubsObj.
    end case.
  end method.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = ",value" when value_ = ?
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method .
  method override protected void ClearSub():
    assign
      value_   = ?
      dscnt    = ?
      message_ = ?
      message-gks = ?
    .
    if valid-object(Gifts) then delete object Gifts .
  end method .
end class.
