block-level on error undo, throw.
using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
class ibs.th.bge.1crn.subjects.promotion_promoset inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property ps-Price as decimal    no-undo get. private set.
  define property ps-sections as subjects no-undo
    get.
    private set.
  define override property InitTag as character no-undo init "promoset"
    get.
  constructor public promotion_promoset ():
    InitListTag = "ps-sections".
  end constructor.
          method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "ps-Price"   then ps-Price   = if inValue >= "" then decimal (inValue) else 0.0 .
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
      when "ps-sections" then ps-sections = SubsObj.
    end case.
  end method.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = ",ps-Price" when ps-Price = ?
      v-str = v-str + ",ps-sections" when not valid-object(ps-sections)
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method .
  method override protected void ClearSub():
    assign
      ps-Price   = ?
    .
    if valid-object(ps-sections) then delete object ps-sections .
  end method .
end class.
