block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.edi-gd inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define property gds-code        as integer      no-undo get. private set.
  define property line-num        as integer      no-undo get. private set.
  define property qnty-ttn        as decimal      no-undo get. private set.
  define property sum             as decimal      no-undo get. private set.
  define property nds-code        as decimal      no-undo get. private set.
  define property price-nonds     as decimal      no-undo get. private set.
  define property stts-desc       as character    no-undo get. private set.
  define property cert-decl       as character    no-undo get. private set.
  define property sum-nds         as decimal      no-undo get. private set.
  define property Qnty-accepted   as decimal      no-undo get. private set.
  define property del-l           as integer      no-undo get. private set.
  define property del-f           as integer      no-undo get. private set.
  define property manual-selection as integer     no-undo get. private set.
  define override property InitTag as character no-undo init "gd"
    get.
  define property marks            as ibs.th.bge.1crn.subjects.subjects no-undo
    get.
    private set.
  constructor public edi-gd ():
     InitListTag = "marks".
  end constructor.
  method private date date-mth (inValue as character):
    inValue = entry (1, inValue, "T").
    return date (integer (entry (2, Invalue, "-")), integer (entry (3, Invalue, "-")), integer (entry (1, Invalue, "-")) ).
  end.
          method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "gd-code"      then gds-code         = if inValue >= "" then integer (inValue) else 0 .
      when "line-num"     then line-num         = if inValue >= "" then integer (inValue) else 0 .
      when "del-l"        then del-l            = if inValue >= "" then integer (inValue) else 0 .
      when "del-f"        then del-f            = if inValue >= "" then integer (inValue) else 0 .
      when "qnty-ttn"     then qnty-ttn         = if inValue >= "" then decimal (inValue) else 0.0 .
      when "sum"          then sum              = if inValue >= "" then decimal (inValue) else 0.0 .
      when "nds-code"     then nds-code         = if inValue >= "" then decimal (inValue) else 0.0 .
      when "price-nonds"  then price-nonds      = if inValue >= "" then decimal (inValue) else 0.0 .
      when "stts-desc"    then stts-desc        = if inValue >= "" then inValue else "" .
      when "cert-decl"    then do:
        if cert-decl = "" then cert-decl        = if inValue >= "" then inValue else "" .
        else cert-decl = cert-decl + chr(4) + if inValue >= "" then inValue else "" .
      end.
      when "sum-nds"      then sum-nds          = if inValue >= "" then decimal (inValue) else 0.0 .
      when "Qnty-accepted" then Qnty-accepted   = if inValue >= "" then decimal (inValue) else 0.0 .
      when "manual-selection" then manual-selection = if inValue >= "" then integer (inValue) else 0 .
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
  method override protected void SetPropProtected (SubsObj as ibs.th.bge.1crn.subjects.subjects):
     case SubsObj:InitTag:
       when "marks"   then marks   = SubsObj.
    end case.
   end method.
  method override protected void CheckData ():
    def var v-str as char no-undo.
    assign
      v-str =         ",line-num"           when line-num          = ?
      v-str = v-str + ",qnty-ttn"           when qnty-ttn          = ?
      v-str = v-str + ",sum"                when sum               = ?
      v-str = v-str + ",price-nonds"        when price-nonds       = ?
    .
    v-str = substring(v-str, 2).
    if v-str > "" then undo, throw new Progress.Lang.AppError(
      substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
    ) .
  end method.
  method override protected void ClearSub():
    assign
      line-num           = ?
      del-l              = ?
      del-f              = ?
      qnty-ttn           = ?
      sum                = ?
      nds-code           = ?
      price-nonds        = ?
      gds-code           = ?
      stts-desc          = ?
      sum-nds            = ?
      Qnty-accepted      = ?
      manual-selection   = ?
      cert-decl          = ""
    .
    if valid-object(marks)        then delete object marks .
  end method.
end class.
