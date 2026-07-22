 
 /*------------------------------------------------------------------------
    File        : goods
    Purpose     : 
    Syntax      : 
    Description : Структура данных по товарам из 1С
    Author(s)   : SSlivenko
    Created     : Fri Oct 20 13:06:14 AST 2017
    Notes       : 
  ----------------------------------------------------------------------*/

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
  
  &scoped-define attr-str      if inValue >= "" then inValue else ""
  &scoped-define attr-integer  if inValue >= "" then integer (inValue) else 0
  &scoped-define attr-dec      if inValue >= "" then decimal (inValue) else 0.0
  &scoped-define attr-date     if inValue >= "" then date-mth (inValue) else ?
  method override protected void SetPropProtected (inTag as char, inValue as char) :
     case inTag:      
      when "code"          then code_         = {&attr-str} .
      when "del-l"         then del-l         = {&attr-integer} .
      when "del-f"         then del-f         = {&attr-integer} .
      when "grp-code"      then grp-code      = {&attr-str} .
      when "name"          then name_         = {&attr-str} .
      when "eng-name"      then eng-name      = {&attr-str} .
      when "label-name"    then label-name    = {&attr-str} .
      when "chk-name"      then chk-name      = {&attr-str} .
      when "artic"         then artic         = {&attr-str} .
      when "unit-code"     then unit-code     = {&attr-str} .
      when "prod-code"     then prod-code     = {&attr-integer} .
      when "wt"            then wt            = {&attr-dec} .
      when "ms"            then ms            = {&attr-dec} .
      when "gds-type"      then gds-type      = {&attr-str} .
      when "mark-type"     then mark-type     = {&attr-integer} .
      when "emc-type"      then emc-type      = {&attr-str} .
      when "img"           then img           = {&attr-str} .
      when "unit-spl-code" then unit-spl-code = {&attr-str} .
      when "unit-k"        then unit-k        = {&attr-dec} .
      when "nds-code"      then nds-code      = {&attr-integer} .
      when "enbl-ne"       then enbl-ne       = {&attr-integer} .
      when "enbl-zc"       then enbl-zc       = {&attr-integer} .
      when "enbl-exc"      then enbl-exc      = {&attr-integer} .
      when "srvc-type"     then srvc-type     = {&attr-integer} .
      when "fuel-type"     then fuel-type     = {&attr-integer} .
      when "oil-grp"       then oil-grp       = {&attr-str} .
      when "max-dnsty"     then max-dnsty     = {&attr-dec} .
      when "min-dnsty"     then min-dnsty     = {&attr-dec} .
      when "pay-trk"       then pay-trk       = {&attr-integer} .
      when "neu-z"         then neu-z         = {&attr-dec} .
      when "neu-l"         then neu-l         = {&attr-dec} .
      when "neu-storage-l" then neu-storage-l = {&attr-dec} .
      when "neu-storage-z" then neu-storage-z = {&attr-dec} .
      when "proteins"      then proteins      = {&attr-dec} .
      when "fats"          then fats          = {&attr-dec} .
      when "carbohydrates" then carbohydrates = {&attr-dec} .
      when "calories"      then calories      = {&attr-dec} .
      when "ISCookStumped" then ISCookStumped = {&attr-integer} .
      when "CommodityCode" then CommodityCode = {&attr-str} .
      when "code-ais"      then code-AIS      = {&attr-str} .
      when "vad-gds"       then vad-gds       = {&attr-integer} .
      when "pay-flag"      then pay-flag      = {&attr-integer} .
      when "is18plus"      then is18plus      = {&attr-integer} .
      when "loyalty-gift" then loyalty-gift  = {&attr-integer} .
      when "method-flag"   then method-flag   = {&attr-str} .
      when "production-use" then production-use = {&attr-integer} .
      when "weighed-product" then weighed-product = {&attr-integer} .
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
      when "img"           then img           = {&attr-str} .
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
/*      v-str = v-str + ",label-name" when label-name = ? */
/*      v-str = v-str + ",chk-name" when chk-name = ?     */
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