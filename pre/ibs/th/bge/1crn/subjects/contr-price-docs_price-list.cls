using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.contr-price-docs_price-list inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property gds-code      as character    no-undo get. private set.
  define property unit-spl-code as character    no-undo get. private set.
  define property unit-k        as decimal      no-undo get. private set.
  define property price-sale  as decimal      no-undo get. private set.
  define property nds-code    as decimal      no-undo get. private set.
  define property min-otkl    as decimal      no-undo get. private set.
  define property max-otkl    as decimal      no-undo get. private set.
  define override property InitTag as character no-undo init "gds-sale"
    get.
          method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "gds-code"      then gds-code      = if inValue >= "" then inValue else "" .
      when "unit-spl-code" then unit-spl-code = if inValue >= "" then inValue else "" .
      when "unit-k"        then unit-k        = if inValue >= "" then decimal (inValue) else 0.0 .
      when "price-sale" then price-sale = if inValue >= "" then decimal (inValue) else 0.0 .
      when "nds-code"   then nds-code   = if inValue >= "" then decimal (inValue) else 0.0 .
      when "min-otkl"   then min-otkl   = if inValue >= "" then decimal (inValue) else 0.0 .
      when "max-otkl"   then max-otkl   = if inValue >= "" then decimal (inValue) else 0.0 .
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
  end.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = ",gds-code" when gds-code = ?
      v-str = v-str + ",price-sale" when price-sale = ?
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end.
  method override protected void ClearSub():
    assign
      gds-code      = ?
      unit-spl-code = ?
      unit-k        = ?
      price-sale   = ?
      nds-code     = ?
      min-otkl     = ?
      max-otkl     = ?
    .
  end.
end class.
