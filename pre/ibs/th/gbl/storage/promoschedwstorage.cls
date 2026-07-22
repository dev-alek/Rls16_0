using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
using ibs.th.ref.promo.*.
block-level on error undo, throw.
class ibs.th.gbl.storage.promoSchedwstorage:
  define variable vss-revision    as character no-undo initial "$Revision: 8aa5522306d2, 3076, rls $":U .
  define variable vss-author      as character no-undo initial "$Author: DRuban $":U .
  define variable vss-date        as character no-undo initial "$Date: Пт авг 05 19:16:16 2022 +0300 $":U .
  define variable vss-workfile    as character no-undo initial "$Workfile: promoschedwstorage.cls $":U .
  define variable vss-archive     as character no-undo initial "$Archive: ibs/th/gbl/storage/promoschedwstorage.cls $":U .
  define variable vss-description as character no-undo initial "Storage SchedW Action".
  define property Msg as character
    get.
    private set.
  method private void exception( arg as handle, inObj as class promoSchedwsub, t-h as handle ):
    inObj:setMsg(arg:get-message (1)).
    inObj:setStatusErr(arg:error).
    t-h:buffer-delete () no-error.
    return.
  end method.
  method private void exception( arg as char ):
    Msg = arg.
    return.
  end method.
  method public void updateDBAll( input inObjList as promoSchedwsubs  ):
      // 01/VIII-2018 пока ни от куда не вызывался
      updateDBAll (inObjList,?,?).
  end.
  method public void updateDBAll( input inObjList as promoSchedwsubs
                                , input idb-num   as integer
                                , input ishced-id as integer ):
      define variable vi as int no-undo.
      define variable v-sub as promoSchedwsub no-undo .
      define variable v-sched-id as integer no-undo .
      v-sched-id = ishced-id .
      do vi = 1 to inObjList:GetItem(vi):
         v-sub = inObjList:promoSchedwObjCurr .
         case v-sub:Mode :
           when 'с':U then do:
             assign
               v-sub:db-num  = idb-num    when (v-sub:db-num  = 0) and (idb-num    > 0)
               v-sub:schedId = v-sched-id when (v-sub:schedId = 0) and (v-sched-id > 0)
             .
             insertDB(v-sub).
             assign
               v-sched-id = v-sub:schedId when v-sched-id = 0
             .
           end .
           when 'и':U then
             updateDB(v-sub).
           when 'у':U then
             deleteDB(v-sub).
           otherwise .
         end case .
      end. // end_of do_in_objList
  end. // end_of_updateDBAll
  method public void insertDB( input inObj as promoSchedwsub ):
    if inObj:db-num eq ? then
       undo, throw new Progress.Lang.AppError(
         substitute("отсутствует db-num в классе расписаний &1 &2 & 3", inObj:wdaylist,inObj:timebeg,inObj:timeend)
       ) .
    define buffer buf_promo-schedule-week for ub.promo-schedule-week .
    inObj:ID = next-value (s-promosched-id, ub) .
    if inObj:schedId > 0 then . else inObj:schedId = inObj:ID .
    create buf_promo-schedule-week.
    assign
      buf_promo-schedule-week.id     = inObj:ID
      buf_promo-schedule-week.db-num = inObj:db-num
      buf_promo-schedule-week.promosched-id = inObj:schedId
    no-error.
    if error-status:error
    then do:
      exception(error-status, inObj, buffer buf_promo-schedule-week:handle).
      return.
    end.
    setDataStorage(input inObj, buffer buf_promo-schedule-week).
  end method.
  method public void updateDB( input inObj as promoSchedwsub ):
    define buffer buf_promo-schedule-week for ub.promo-schedule-week .
    find first buf_promo-schedule-week where buf_promo-schedule-week.id = inObj:ID no-error.
    if not available (buf_promo-schedule-week)
    then do:
      exception(error-status, inObj, buffer buf_promo-schedule-week:handle).
      return.
    end.
    setDataStorage(input inObj, buffer buf_promo-schedule-week).
    return.
  end method.
  method public void deleteDB( input inObj as promoSchedwsub ):
    if not valid-object (inObj)
    then
       return.
    define buffer buf_promo-schedule-week for ub.promo-schedule-week .
    find first buf_promo-schedule-week where buf_promo-schedule-week.id = inObj:ID no-error.
    if not available (buf_promo-schedule-week)
    then do:
      exception(error-status, inObj, buffer buf_promo-schedule-week:handle).
      return.
    end.
    delete buf_promo-schedule-week.
    return.
  end method.
  method public class promoSchedwsubs getpromoSchedwsubs (input idPromoSched as integer):
    define buffer buf_promo-schedule-week for ub.promo-schedule-week .
    define variable listObj as class promoSchedwsubs.
    listObj = new promoSchedwsubs ().
    for each buf_promo-schedule-week where buf_promo-schedule-week.promosched-id eq idPromoSched
    no-lock:
        listObj:AddItem(getDataStorage (buffer buf_promo-schedule-week)).
    end.
    return listObj.
  end method.
  method private void setDataStorage (input inObj as class promoSchedwsub, buffer inbf for ub.promo-schedule-week ):
    assign
      inbf.timebeg       = inObj:timebeg
      inbf.timeend       = inObj:timeend
      inbf.wdaylist      = inObj:wdaylist
    .
    validate inbf.
  end method.
  method private class promoSchedwsub getDataStorage ( buffer inbf for ub.promo-schedule-week ):
    define variable subObj  as class promoSchedwsub.
    subObj = new promoSchedwsub ().
    assign
      subObj:ID       = inbf.id
      subObj:schedId  = inbf.promosched-id
      subObj:timebeg  = inbf.timebeg
      subObj:timeend  = inbf.timeend
      subObj:wdaylist = inbf.wdaylist
      subObj:db-num   = inbf.db-num
    .
    return subObj.
  end.
  method public void refreshObj (inSubObj as class promoSchedwsub):
    define buffer buf_promo-schedule-week for ub.promo-schedule-week .
    if not valid-object (inSubObj)
    then do:
      Msg = "Объект типа promoSchedtsub не существует".
      return.
    end.
    find first buf_promo-schedule-week no-lock where buf_promo-schedule-week.ID = inSubObj:ID no-error.
    if not available (buf_promo-schedule-week)
    then do:
      Msg = "Не найдено расписание - " + string (inSubObj:ID).
      return.
    end.
    getDataStorage (buffer buf_promo-schedule-week).
  end.
end class.
