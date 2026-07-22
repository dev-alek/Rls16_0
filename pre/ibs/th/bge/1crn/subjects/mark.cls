block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.mark inherits ibs.th.bge.1crn.subjects.asubject:
    define override public property vss-revision    as character no-undo init "$Revision:$":U get .
    define override public property vss-author      as character no-undo init "$Author:$":U get.
    define override public property vss-date        as character no-undo init "$Date:$":U get.
    define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
    define override public property vss-archive     as character no-undo init "$Archive:$":U get.
    define property mark-code       as character    no-undo get.
        private set.
    define property unit-ext        as character    no-undo get.
        private set.
    define property qnty-box        as decimal      no-undo get.
        private set.
    define property stts            as character    no-undo get.
        private set.
    define property mark-parent     as character    no-undo get.
        private set.
    define property GTIN            as character    no-undo get.
        private set.
    define property expDate         as character  no-undo get.
        private set.
    define property expDateOther    as character    no-undo get.
        private set.
    define property gds-code        as integer      no-undo get.
        private set.
    define property mrc             as decimal      no-undo get.
        private set.
    define property weight          as decimal      no-undo get.
        private set.
    define property stts-desc             as character    no-undo get.
        private set.
    define property del-l         as integer      no-undo get.
        private set.
    define property del-f         as integer      no-undo get.
        private set.
    define property obj-load        as character       no-undo get.  set.
    define override property InitTag as character no-undo init "mark"
        get.
    constructor public mark ():
    end constructor.
    method private date date-mth (inValue as character):
        inValue = entry (1, inValue, "T").
        return date (integer (entry (2, Invalue, "-")), integer (entry (3, Invalue, "-")), integer (entry (1, Invalue, "-")) ).
    end.
            method override protected void SetPropProtected (inTag as char, inValue as char):
        define variable ii              as integer   no-undo .
        define variable expDateMes      as character no-undo .
        define variable expDateOtherMes as character no-undo .
        case inTag:
            when "del-l"        then
                del-l            = if inValue >= "" then integer (inValue) else 0 .
            when "del-f"        then
                del-f            = if inValue >= "" then integer (inValue) else 0 .
            when "mark-code"    then
                mark-code        = if inValue >= "" then inValue else "" .
            when "unit-ext"     then
                unit-ext         = if inValue >= "" then inValue else "" .
            when "qnty-box"     then
                qnty-box         = if inValue >= "" then decimal (inValue) else 0.0 .
            when "stts"         then
                stts             = if inValue >= "" then inValue else "" .
            when "mark_parent"  then
                mark-parent      = if inValue >= "" then inValue else "" .
            when "mark-parent"  then
                mark-parent      = if inValue >= "" then inValue else "" .
            when "stts-desc"    then
                stts-desc        = if inValue >= "" then inValue else "" .
            when "GTIN"         then
                GTIN             = if inValue >= "" then inValue else "" .
            when "expirationDate" then
                expDate        = ENTRY(1,STRING(formatDateTime(inValue)),"+") .
            when "expirationsDates" then
                do:
                    do ii = 1 to num-entries(inValue):
                        if ii = 12 then leave .
                        expDateOtherMes = ENTRY(1,STRING(formatDateTime(entry(ii,inValue))),",") .
                        if expDateOther = ? then expDateOther = string(datetime-tz(expDateOtherMes)) .
                        else expDateOther = expDateOther + ", " + string(datetime-tz(expDateOtherMes)) .
                    end.
                end.
            when "gds-code"     then
                gds-code         = if inValue >= "" then integer (inValue) else 0 .
            when "mrc"          then
                mrc              = if inValue >= "" then decimal (inValue) else 0.0 .
            when "weight"       then
                weight           = if inValue >= "" then decimal (inValue) else 0.0 .
        end case.
        catch exProErrors as class Progress.Lang.ProError :
            case exProErrors:GetMessageNum(1):
                when 18207 then
                    undo, throw new Progress.Lang.AppError(
                        substitute("Поле <&1> содержит ошибочное значение [&2]", inTag, inValue)
                        ) .
                otherwise
                undo, throw new Progress.Lang.AppError(
                    substitute("Ошибка значения для поля <&1>: &2", inTag, exProErrors:GetMessage(1))
                    ) .
            end case .
        end catch .
    end method.
    method override protected void SetPropProtected (SubsObj as ibs.th.bge.1crn.subjects.subjects):
    end method.
    method override protected void CheckData ():
        def var v-str as char no-undo.
        assign
            v-str = v-str + ",mark-code"
            when mark-code         = ?
            v-str = v-str + ",qnty-box"
            when qnty-box          = ? and obj-load eq "mark"
            .
        v-str = substring(v-str, 2).
        if v-str > "" then undo, throw new Progress.Lang.AppError(
                substitute("Теги [&1] отсутствуют в сообщении [&2]", v-str, InitTag)
                ) .
    end method.
    method override protected void ClearSub():
        assign
            mark-code    = ?
            del-l        = ?
            del-f        = ?
            unit-ext     = ?
            qnty-box     = ?
            stts         = ?
            mark-parent  = ?
            GTIN         = ?
            gds-code     = ?
            mrc          = ?
            stts-desc    = ?
            weight       = ?
            expDate      = ?
            expDateOther = ?
            .
    end method.
    method private date formatDate (pDate as character) :
        define variable iDate as character no-undo .
        iDate = entry(1,pDate,"T") .
        return if (iDate = "" or iDate = "")
           then ?
           else date(int(substring(iDate,6,2)),int(substring(iDate,9,2)),int(substring(iDate,1,4))) .
    end method .
    method private character formatDateTime (pDate as character) :
        define variable iDate as character no-undo .
        define variable vDate as date      no-undo .
        define variable kDate as datetime  no-undo.
        iDate = entry(1,pDate,"T") .
        if (iDate = "" or iDate = "")
            then return ? .
        else vDate = date(int(substring(iDate,6,2)),int(substring(iDate,9,2)),int(substring(iDate,1,4))) .
        return string(vDate,"99/99/9999") + " " + entry(2,pDate,"T") .
    end method .
end class.
