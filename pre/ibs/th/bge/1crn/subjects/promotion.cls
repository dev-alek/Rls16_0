using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.isubject .
using ibs.th.bge.1crn.subjects.subjects from propath.
using ibs.th.ref.promo.enum-type-discount .
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.promotion inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property code_         as character    no-undo get. private set.
  define property del-l         as integer      no-undo get. private set.
  define property del-f         as integer      no-undo get. private set.
  define property name_         as character    no-undo get. private set.
  define property priority      as integer      no-undo get. private set.
  define property strt-date     as date         no-undo get. private set.
  define property end-date      as date         no-undo get. private set.
  define property earlyend-day  as date         no-undo get. private set.
  define property description_  as character    no-undo get. private set.
  define property comment       as character    no-undo get. private set.
  define property dscnt-type    as enum-type-discount no-undo get. private set.
  define property dscnt-value-type as integer   no-undo get. private set.
  define property threshold-type as integer     no-undo get. private set.
  define property pmnt-types    as character    no-undo get. private set.
  define property prohibition-charge-BL as integer no-undo get. private set.
  define property status_       as integer      no-undo get. private set.
  define property schedule     as ibs.th.bge.1crn.subjects.promotion_schedule no-undo
    get.
    private set.
  define property thresholds   as subjects no-undo
    get.
    private set.
  define property gds          as subjects no-undo
    get.
    private set.
  define property gds-addcond  as subjects no-undo
    get.
    private set.
  define property promoset     as ibs.th.bge.1crn.subjects.promotion_promoset no-undo
    get.
    private set.
  define property gifts        as subjects no-undo
    get.
    private set.
  define property payment-systems        as subjects no-undo
    get.
    private set.
  define override property InitTag as character no-undo init "promotion"
    get.
  constructor public promotion ():
    InitListTag = "shedule,thresholds,gds,gds-addcond,promoset,gifts,payment-systems".
  end constructor.
          method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "code"         then code_        = if inValue >= "" then inValue else "" .
      when "del-l"        then del-l        = if inValue >= "" then integer (inValue) else 0 .
      when "del-f"        then del-f        = if inValue >= "" then integer (inValue) else 0 .
      when "name"         then name_        = if inValue >= "" then inValue else "" .
      when "priority"     then priority     = if inValue >= "" then integer (inValue) else 0 .
      when "strt-date"    then strt-date    = if inValue >= "" then date-mth (inValue) else ? .
      when "end-date"     then end-date     = if inValue >= "" then date-mth (inValue) else ? .
      when "earlyend-day" then earlyend-day = if inValue >= "" then date-mth (inValue) else ? .
      when "description"  then description_ = if inValue >= "" then inValue else "" .
      when "comment"      then comment      = if inValue >= "" then inValue else "" .
      when "dscnt-type"   then do:
        if inValue >= "" then dscnt-type = enum-type-discount:GetEnum( integer (inValue) ) .
                         else dscnt-type = enum-type-discount:ensolo .
      end .
      when "dscnt-value-type" then dscnt-value-type = if inValue >= "" then integer (inValue) else 0 .
      when "threshold-type"   then threshold-type   = if inValue >= "" then integer (inValue) else 0 .
      when "pmnt-types"       then pmnt-types       = if inValue >= "" then inValue else "" .
      when "prohibition-charge-BL" then prohibition-charge-BL = if inValue >= "" then integer (inValue) else 0 .
      // !! перечень статусов акции в 1с отличается от перечня статусов акции в TH !!
      when "status"           then status_          = if inValue >= "" then integer (inValue) else 0 .
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
  method override protected void SetPropProtected (SubObj as isubject):
    case SubObj:InitTag:
      when "schedule" then
        schedule = cast (SubObj, ibs.th.bge.1crn.subjects.promotion_schedule) .
      when "promoset" then
        promoset = cast (SubObj, ibs.th.bge.1crn.subjects.promotion_promoset) .
    end case .
  end method.
  method override protected void SetPropProtected (SubsObj as subjects):
    case SubsObj:InitTag:
      when "thresholds"      then thresholds      = SubsObj.
      when "gds"             then gds             = SubsObj.
      when "gds-addcond"     then gds-addcond     = SubsObj.
      when "gifts"           then gifts           = SubsObj.
      when "payment-systems" then payment-systems = SubsObj.
    end case.
  end method.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str = ",code" when code_ = ?
      v-str = v-str + ",name" when name_ = ?
      v-str = v-str + ",priority" when priority = ?
      v-str = v-str + ",strt-date" when strt-date = ?
      v-str = v-str + ",end-date" when end-date = ?
      v-str = v-str + ",dscnt-type" when dscnt-type = ?
      v-str = v-str + ",dscnt-value-type" when dscnt-value-type = ?
      v-str = v-str + ",status" when status_ = ?
      // 13/VII-2018 - расписание в составе промо-акции сделано обязательным
      // 09/VIII-2018 - расписание в составе промо-акции сделано необязательным. Акция без расписания действует все дни всё время.
      // v-str = v-str + ",schedule" when not valid-object(schedule)
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method.
  method override protected void ClearSub():
    assign
      code_        = ?
      del-l        = ?
      del-f        = ?
      name_        = ?
      priority     = ?
      strt-date    = ?
      end-date     = ?
      earlyend-day = ?
      description_ = ?
      comment      = ?
      dscnt-type   = ?
      dscnt-value-type = ?
      threshold-type = ?
      pmnt-types   = ?
      prohibition-charge-BL = ?
      status_      = ?
    .
    if valid-object(schedule)        then delete object schedule .
    if valid-object(thresholds)      then delete object thresholds .
    if valid-object(gds)             then delete object gds .
    if valid-object(gds-addcond)     then delete object gds-addcond .
    if valid-object(promoset)        then delete object promoset .
    if valid-object(gifts)           then delete object gifts .
    if valid-object(payment-systems) then delete object payment-systems .
  end method.
  method private date date-mth (inValue as character) : // возвращает дату из строки iso-date
    define variable v-date as date no-undo .
    assign
      inValue = entry (1, inValue, "T")
      v-date  = date (
        integer (entry (2, Invalue, "-")),
        integer (entry (3, Invalue, "-")),
        integer (entry (1, Invalue, "-"))
                     )
    .
    return v-date.
  end method.
end class.
