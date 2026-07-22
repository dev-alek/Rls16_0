using Progress.Lang.*.
using ibs.th.gbl.gbl-var.
using ibs.th.bge.1crn.enum-assortment-stg.
using ibs.th.bge.1crn.subjects.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impassortment-matrix implements ibs.th.bge.1crn.import.iimpsubject:
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable objImp       as class assortment-matrix no-undo.
    define variable v-retfl      as logical no-undo .
    define variable v-gds-code   as integer no-undo .
    define variable v-obj-type   as character no-undo .
    define variable v-obj-code   as integer no-undo .
    define buffer buf_gds-obj-prop for ub.gds-obj-prop .
    objImp = cast (subjectObj, assortment-matrix).
    assign
      v-gds-code = integer(objImp:gds-code)
      v-obj-type = 'маг':U
    .
    if v-gds-code > 0 then . else undo, throw new Progress.Lang.AppError("Не задан код товара") .
    v-obj-code = currObjCode (v-obj-type, gbl-var:g#db-num) .
    find first buf_gds-obj-prop exclusive-lock
         where buf_gds-obj-prop.gds-code = v-gds-code
           and buf_gds-obj-prop.obj-type = v-obj-type
           and buf_gds-obj-prop.obj-code = v-obj-code no-error .
    if locked(buf_gds-obj-prop) then do:
      undo, throw new Progress.Lang.AppError(
          substitute("Запись о признаках товара [&1] на объекте [&2&3] занята другим пользователем",
                     v-gds-code, v-obj-type, v-obj-code)
      ) .
    end .
    if not available buf_gds-obj-prop then do:
      define variable v-date1 as date      no-undo .
      define variable v-date2 as date      no-undo .
      define variable v-time  as integer   no-undo .
      assign
        v-date1 = today
        v-time  = time
        v-date2 = today
      .
      if v-date1 <> v-date2 then assign
        v-date1 = today
        v-time  = time
      .
      create buf_gds-obj-prop .
      assign
        buf_gds-obj-prop.gds-code           = v-gds-code
        buf_gds-obj-prop.grop-date-update   = v-date1
        buf_gds-obj-prop.grop-time-update   = v-time
        buf_gds-obj-prop.grop-db-num-update = gbl-var:g#db-num
        buf_gds-obj-prop.grop-who-update    = gbl-var:g#userid
        buf_gds-obj-prop.obj-type           = v-obj-type
        buf_gds-obj-prop.obj-code           = v-obj-code
        buf_gds-obj-prop.gdop-assort-min    = false
      .
    end .
    assign
      buf_gds-obj-prop.gdop-igt = mapAssortStage (objImp:stg)
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
  method private integer currObjCode (input p-obj-type as character,
                                      input p-db-num   as integer) :
    define buffer buf_clients for ub.clients .
    find first buf_clients no-lock
         where buf_clients.db-num   = p-db-num
           and buf_clients.obj-type = p-obj-type
           and buf_clients.stts     = 0 no-error .
    return if available buf_clients then buf_clients.obj-code else 0 .
  end method .
  method private character mapAssortStage (p-stg as enum-assortment-stg) :
    define variable v-th-igt as character no-undo .
    case p-stg :
      when enum-assortment-stg:enactive     then v-th-igt = 'Основная группа':U .
      when enum-assortment-stg:endelay      then v-th-igt = 'Новинка':U .
      when enum-assortment-stg:enchange     then v-th-igt = 'Основная группа':U .
      when enum-assortment-stg:enwithdrawal then v-th-igt = 'На вывод из ассортимента':U .
      when enum-assortment-stg:enarchive    then v-th-igt = 'Пусто':U .
      otherwise v-th-igt = 'Пусто':U .
    end case .
    return v-th-igt .
  end method .
end class.
