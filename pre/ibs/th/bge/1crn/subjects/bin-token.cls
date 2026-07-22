block-level on error undo, throw.
using Progress.Lang.*.
class ibs.th.bge.1crn.subjects.bin-token inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property code_  as character  no-undo get. private set. // 1-1 Объект акции  Код товара
  define override property InitTag as character no-undo init "bin-token"
    get.
          method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "code"  then code_  = if inValue >= "" then inValue else "" .
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
      v-str = ",code" when code_ = ?
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method .
  method override protected void ClearSub():
    assign
      code_  = ?
    .
  end method .
end class.
