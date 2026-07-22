using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.subjects from propath.
using ibs.th.bge.1crn.subjects.goods_barcode from propath.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.goods inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property code_         as character    no-undo get. private set.
  define property del-l         as integer      no-undo get. private set.
  define property del-f         as integer      no-undo get. private set.
  define property grp-code      as character    no-undo get. private set.
  define property name_         as character    no-undo get. private set.
  define property eng-name      as character    no-undo get. private set.
  define property label-name    as character    no-undo get. private set.
  define property chk-name      as character    no-undo get. private set.
  define property artic         as character    no-undo get. private set.
  define property unit-code     as character    no-undo get. private set.
  define property prod-code     as integer      no-undo get. private set.
  define property wt            as decimal      no-undo get. private set.
  define property ms            as decimal      no-undo get. private set.
  define property gds-type      as character    no-undo get. private set.
  define property mark-type     as integer      no-undo get. private set.
  define property emc-type      as character    no-undo get. private set.
  define property ISCookStumped as integer      no-undo get. private set.
  define property CommodityCode as character    no-undo get. private set.
  define property img           as longchar     no-undo get. private set.
  define property unit-spl-code as character    no-undo get. private set.
  define property unit-k        as decimal      no-undo get. private set.
  define property nds-code      as integer      no-undo get. private set.
  define property enbl-ne       as integer      no-undo get. private set.
  define property enbl-zc       as integer      no-undo get. private set.
  define property enbl-exc      as integer      no-undo get. private set.
  define property srvc-type     as integer      no-undo get. private set.
  define property fuel-type     as integer      no-undo get. private set.
  define property oil-grp       as character    no-undo get. private set.
  define property max-dnsty     as decimal      no-undo get. private set.
  define property min-dnsty     as decimal      no-undo get. private set.
  define property pay-trk       as integer      no-undo get. private set.
  define property neu-z         as decimal      no-undo get. private set.
  define property neu-l         as decimal      no-undo get. private set.
  define property neu-storage-l as decimal      no-undo get. private set.
  define property neu-storage-z as decimal      no-undo get. private set.
  define property proteins      as decimal      no-undo get. private set.
  define property fats          as decimal      no-undo get. private set.
  define property carbohydrates as decimal      no-undo get. private set.
  define property calories      as decimal      no-undo get. private set.
  define property vad-gds       as integer      no-undo get. private set.
  define property pay-flag      as integer      no-undo get. private set.
  define property is18plus      as integer      no-undo get. private set.
  define property loyalty-gift  as integer  no-undo get. private set.
  define property method-flag   as character    no-undo get. private set.
  define property code-AIS      as character    no-undo get. private set.
  define property production-use as integer      no-undo get. private set.
  define property barcode        as subjects     no-undo get. private set.
  define property unit-add-codes as subjects     no-undo get. private set.
  define property weighed-product as integer     no-undo get. private set.
  define override property InitTag as character no-undo init "good"
    get.
  constructor public goods ():
    InitListTag = "barcode,unit-add-codes".
  end constructor.
          method override protected void SetPropProtected (inTag as char, inValue as char) :
     case inTag:
      when "code"          then code_         = if inValue >= "" then inValue else "" .
      when "del-l"         then del-l         = if inValue >= "" then integer (inValue) else 0 .
      when "del-f"         then del-f         = if inValue >= "" then integer (inValue) else 0 .
      when "grp-code"      then grp-code      = if inValue >= "" then inValue else "" .
      when "name"          then name_         = if inValue >= "" then inValue else "" .
      when "eng-name"      then eng-name      = if inValue >= "" then inValue else "" .
      when "label-name"    then label-name    = if inValue >= "" then inValue else "" .
      when "chk-name"      then chk-name      = if inValue >= "" then inValue else "" .
      when "artic"         then artic         = if inValue >= "" then inValue else "" .
      when "unit-code"     then unit-code     = if inValue >= "" then inValue else "" .
      when "prod-code"     then prod-code     = if inValue >= "" then integer (inValue) else 0 .
      when "wt"            then wt            = if inValue >= "" then decimal (inValue) else 0.0 .
      when "ms"            then ms            = if inValue >= "" then decimal (inValue) else 0.0 .
      when "gds-type"      then gds-type      = if inValue >= "" then inValue else "" .
      when "mark-type"     then mark-type     = if inValue >= "" then integer (inValue) else 0 .
      when "emc-type"      then emc-type      = if inValue >= "" then inValue else "" .
      when "img"           then img           = if inValue >= "" then inValue else "" .
      when "unit-spl-code" then unit-spl-code = if inValue >= "" then inValue else "" .
      when "unit-k"        then unit-k        = if inValue >= "" then decimal (inValue) else 0.0 .
      when "nds-code"      then nds-code      = if inValue >= "" then integer (inValue) else 0 .
      when "enbl-ne"       then enbl-ne       = if inValue >= "" then integer (inValue) else 0 .
      when "enbl-zc"       then enbl-zc       = if inValue >= "" then integer (inValue) else 0 .
      when "enbl-exc"      then enbl-exc      = if inValue >= "" then integer (inValue) else 0 .
      when "srvc-type"     then srvc-type     = if inValue >= "" then integer (inValue) else 0 .
      when "fuel-type"     then fuel-type     = if inValue >= "" then integer (inValue) else 0 .
      when "oil-grp"       then oil-grp       = if inValue >= "" then inValue else "" .
      when "max-dnsty"     then max-dnsty     = if inValue >= "" then decimal (inValue) else 0.0 .
      when "min-dnsty"     then min-dnsty     = if inValue >= "" then decimal (inValue) else 0.0 .
      when "pay-trk"       then pay-trk       = if inValue >= "" then integer (inValue) else 0 .
      when "neu-z"         then neu-z         = if inValue >= "" then decimal (inValue) else 0.0 .
      when "neu-l"         then neu-l         = if inValue >= "" then decimal (inValue) else 0.0 .
      when "neu-storage-l" then neu-storage-l = if inValue >= "" then decimal (inValue) else 0.0 .
      when "neu-storage-z" then neu-storage-z = if inValue >= "" then decimal (inValue) else 0.0 .
      when "proteins"      then proteins      = if inValue >= "" then decimal (inValue) else 0.0 .
      when "fats"          then fats          = if inValue >= "" then decimal (inValue) else 0.0 .
      when "carbohydrates" then carbohydrates = if inValue >= "" then decimal (inValue) else 0.0 .
      when "calories"      then calories      = if inValue >= "" then decimal (inValue) else 0.0 .
      when "ISCookStumped" then ISCookStumped = if inValue >= "" then integer (inValue) else 0 .
      when "CommodityCode" then CommodityCode = if inValue >= "" then inValue else "" .
      when "code-ais"      then code-AIS      = if inValue >= "" then inValue else "" .
      when "vad-gds"       then vad-gds       = if inValue >= "" then integer (inValue) else 0 .
      when "pay-flag"      then pay-flag      = if inValue >= "" then integer (inValue) else 0 .
      when "is18plus"      then is18plus      = if inValue >= "" then integer (inValue) else 0 .
      when "loyalty-gift" then loyalty-gift  = if inValue >= "" then integer (inValue) else 0 .
      when "method-flag"   then method-flag   = if inValue >= "" then inValue else "" .
      when "production-use" then production-use = if inValue >= "" then integer (inValue) else 0 .
      when "weighed-product" then weighed-product = if inValue >= "" then integer (inValue) else 0 .
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
  method override protected void SetPropProtected (inTag as char, inValue as longchar) :
     case inTag:
      when "img"           then img           = if inValue >= "" then inValue else "" .
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
      when "barcode"        then barcode        = SubsObj.
      when "unit-add-codes" then unit-add-codes = SubsObj.
    end case.
  end.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = ",code" when code_ = ?
      v-str = v-str + ",grp-code" when grp-code = ?
      v-str = v-str + ",name" when name_ = ?
      v-str = v-str + ",unit-k" when unit-k = ?
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method .
  method override protected void ClearSub():
    assign
        code_         = ?
        del-l         = ?
        del-f         = ?
        grp-code      = ?
        name_         = ?
        eng-name      = ?
        label-name    = ?
        chk-name      = ?
        artic         = ?
        unit-code     = ?
        prod-code     = ?
        wt            = ?
        ms            = ?
        gds-type      = ?
        mark-type     = ?
        emc-type      = ?
        img           = ?
        unit-spl-code = ?
        unit-k        = ?
        nds-code      = ?
        enbl-ne       = ?
        enbl-zc       = ?
        enbl-exc      = ?
        srvc-type     = ?
        fuel-type     = ?
        oil-grp       = ?
        max-dnsty     = ?
        min-dnsty     = ?
        pay-trk       = ?
        neu-z         = ?
        neu-l         = ?
        neu-storage-l = ?
        neu-storage-z = ?
        proteins      = ?
        fats          = ?
        carbohydrates = ?
        calories      = ?
        ISCookStumped = ?
        CommodityCode = ?
        vad-gds       = ?
        pay-flag      = ?
        is18plus      = ?
        loyalty-gift = ?
        method-flag   = ?
        code-AIS      = ?
        production-use = ?
        weighed-product = ?
    .
    if valid-object(barcode) then delete object barcode .
    if valid-object(unit-add-codes) then delete object unit-add-codes .
  end method .
end class.
