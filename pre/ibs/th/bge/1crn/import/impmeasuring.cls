using Progress.Lang.*.
using ibs.th.bge.1crn.enum-deg-auto.
using ibs.th.bge.1crn.enum-dnst-ms-type.
using ibs.th.bge.1crn.enum-level-ms-type.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impmeasuring implements ibs.th.bge.1crn.import.iimpsubject:
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable objImp       as class measuring no-undo.
    define variable v-retfl      as logical no-undo .
    define variable v-ms-code    as integer no-undo .
    define buffer buf_sr-izmerenia for ub.sr-izmerenia .
    objImp = cast (subjectObj, measuring).
    assign
      v-ms-code = integer(objImp:code_)
    .
    if v-ms-code > 0 then . else undo, throw new Progress.Lang.AppError("Не задан код средства измерения") .
    if objImp:del-f > 0 then do:
      run ref/sr-izm03.p ( input v-ms-code ) .
    end .
    else do:
      run ref/sr-izm01.p
      (input v-ms-code
      ,input mapDegAuto (objImp:deg-auto)
      ,input objImp:name_
      ,input objImp:dimension-level
      ,input objImp:dimension-temp
      ,input objImp:dimension-dnst
      ,input objImp:dimension-wght
      ,input mapLevelMsType (objImp:level-ms-type)
      ,input mapDnstMsType (objImp:dnst-ms-type)
      ,input objImp:level-abs-me
      ,input objImp:level-rel-me-np
      ,input objImp:level-abs-me-wtr
      ,input objImp:level-rel-me-wtr
      ,input objImp:dnst-abs-me-np
      ,input objImp:temp-abs-me-vlm
      ,input objImp:temp-abs-me-dnst
      ,input objImp:dnst-rel-me-np
      ,input objImp:dnst-abs-me-lpg-l
      ,input objImp:dnst-rel-me-lpg-l
      ,input objImp:dnst-abs-me-lpg-v
      ,input objImp:wght-rel-me
      ,input objImp:level-tk
      ,input objImp:del-l
      ) .
    end .
    assign
      Msg = "":U
      v-retfl = true
    .
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg = "" then Msg = exAppErrors:GetMessage(1) .
      v-retfl = false.
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) .
      v-retfl = false.
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error occurred..." .
      v-retfl = false.
      undo, throw exAnyErrors .
    end catch .
    finally :
      return v-retfl.
    end finally .
  end method.
  method private integer mapDnstMsType (p-ms-type as enum-dnst-ms-type) :
    define variable v-ms-type as integer no-undo .
    case p-ms-type :
      when enum-dnst-ms-type:enare15     then v-ms-type = 1 .
      when enum-dnst-ms-type:enare20     then v-ms-type = 2 .
      when enum-dnst-ms-type:endensflow  then v-ms-type = 3 .
      when enum-dnst-ms-type:endenssubm  then v-ms-type = 4 .
      when enum-dnst-ms-type:enchannelfl then v-ms-type = 5 .
      when enum-dnst-ms-type:enchannelno then v-ms-type = 6 .
      otherwise v-ms-type = 1 .
    end case .
    return v-ms-type .
  end method .
  method private integer mapDegAuto (p-deg-auto as enum-deg-auto) :
    define variable v-deg-auto as integer no-undo .
    case p-deg-auto :
      when enum-deg-auto:enautoms         then v-deg-auto = 0 .
      when enum-deg-auto:ennonautomatedms then v-deg-auto = 1 .
      when enum-deg-auto:enmssys          then v-deg-auto = 2 .
      otherwise v-deg-auto = 0 .
    end case .
    return v-deg-auto .
  end method .
  method private integer mapLevelMsType (p-level-ms-type as enum-level-ms-type) :
    define variable v-level-ms-type as integer no-undo .
    case p-level-ms-type :
      when enum-level-ms-type:enstatic            then v-level-ms-type = 0 .
      when enum-level-ms-type:enroulette2class    then v-level-ms-type = 1 .
      when enum-level-ms-type:endensitylevelmeter then v-level-ms-type = 2 .
      otherwise v-level-ms-type = 0 .
    end case .
    return v-level-ms-type .
  end method .
end class.
