using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
using ibs.th.bge.1crn.subjects.contr-price-docs from propath.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.contr-price-docs inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property doc-id      as character    no-undo get. private set.
  define property doc-num     as character    no-undo get. private set.
  define property doc-date    as character    no-undo get. private set.
  define property contr-code  as character    no-undo get. private set.
  define property cont-code   as character    no-undo get. private set.
  define property price-list  as subjects     no-undo get. private set.
  define override property InitTag as character no-undo init "contr-price-doc"
    get.
  constructor public contr-price-docs ():
    InitListTag = "price-list".
  end constructor.
          method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "doc-id"     then doc-id     = if inValue >= "" then inValue else "" .
      when "doc-num"    then doc-num    = if inValue >= "" then inValue else "" .
      when "doc-date"   then doc-date   = if inValue >= "" then inValue else "" .
      when "contr-code" then contr-code = if inValue >= "" then inValue else "" .
      when "cont-code"  then cont-code  = if inValue >= "" then inValue else "" .
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
  method override protected void SetPropProtected(SubsObj as subjects):
    case SubsObj:InitTag:
      when "price-list" then price-list = SubsObj.
    end case.
  end method.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = v-str + ",cont-code" when cont-code = ?
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method.
  method override protected void ClearSub():
    assign
      doc-id       = ?
      doc-num      = ?
      doc-date     = ?
      contr-code   = ?
      cont-code    = ?
    .
    if valid-object(price-list) then delete object price-list no-error .
  end.
end class.
