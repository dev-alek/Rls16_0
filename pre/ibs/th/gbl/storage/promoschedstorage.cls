using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
using ibs.th.ref.promo.*.
block-level on error undo, throw.
class ibs.th.gbl.storage.promoSchedstorage:
  define variable vss-revision    as character no-undo initial "$Revision: 8aa5522306d2, 3076, rls $":U .
  define variable vss-author      as character no-undo initial "$Author: DRuban $":U .
  define variable vss-date        as character no-undo initial "$Date: Пт авг 05 19:16:16 2022 +0300 $":U .
  define variable vss-workfile    as character no-undo initial "$Workfile: promoschedstorage.cls $":U .
  define variable vss-archive     as character no-undo initial "$Archive: ibs/th/gbl/storage/promoschedstorage.cls $":U .
  define variable vss-description as character no-undo initial "Storage Sched Action".
  define property Msg as character
    get.
    private set.
  method private void exception( arg as handle, inObj as class promoSchedsub, t-h as handle ):
    inObj:setMsg(arg:get-message (1)).
    inObj:setStatusErr(arg:error).
    t-h:buffer-delete () no-error.
    return.
  end method.
  method private void exception( arg as char ):
    Msg = arg.
    return.
  end method.
  method public void insertDB( input inObj as promoSchedsub ):
    define buffer buf_promo-schedule for ub.promo-schedule .
    if inObj:db-num eq ? then
       undo, throw new Progress.Lang.AppError(
         substitute("отсутствует db-num в классе заголовков расписаний &1", inObj:dispname)
       ) .
    create buf_promo-schedule.
    assign
      buf_promo-schedule.id     = inObj:ID
      buf_promo-schedule.db-num = inObj:db-num
    no-error.
    if error-status:error
    then do:
      exception(error-status, inObj, buffer buf_promo-schedule:handle).
      return.
    end.
    setDataStorage(input inObj, buffer buf_promo-schedule).
  end method.
  method public void updateDB( input inObj as promoSchedsub  ):
    define buffer buf_promo-schedule for ub.promo-schedule .
    find first buf_promo-schedule where buf_promo-schedule.id = inObj:ID no-error.
    if not available (buf_promo-schedule)
    then do:
      exception(error-status, inObj, buffer buf_promo-schedule:handle).
      return.
    end.
    setDataStorage(input inObj, buffer buf_promo-schedule).
    return.
  end method.
  method public void deleteDB( input inObj as promoSchedsub  ):
    if not valid-object(inObj)
    then
       return.
    define buffer buf_promo-schedule for ub.promo-schedule .
    find first buf_promo-schedule where buf_promo-schedule.id = inObj:ID no-error.
    if not available (buf_promo-schedule)
    then do:
      exception(error-status, inObj, buffer buf_promo-schedule:handle).
      return.
    end.
    delete buf_promo-schedule.
    return.
  end method.
  method public class promoSchedsub getpromoSchedsub (input idPromoSched as integer):
    define buffer buf_promo-schedule for ub.promo-schedule .
    define variable v-sub as class promoSchedsub no-undo .
    for first buf_promo-schedule where buf_promo-schedule.id eq idPromoSched
    no-lock:
        v-sub = getDataStorage (buffer buf_promo-schedule).
    end.
    return v-sub.
  end method.
  method private void setDataStorage (input inObj as class promoSchedsub, buffer inbf for ub.promo-schedule ):
    define variable v-status as ibs.th.ref.promo.enum-sched-status no-undo .
    v-status = inObj:status_ .
    assign
      inbf.dispname       = inObj:dispname
      inbf.sched-type     = inObj:schedType
      inbf.status_        = v-status:getvalue() when valid-object(v-status)
      inbf.ext-code-sched = inObj:extCodeSched
    .
    validate  inbf.
  end method.
  method private class promoSchedsub getDataStorage ( buffer inbf for ub.promo-schedule ):
    define variable subObj  as class promoSchedsub.
    subObj = new promoSchedsub ().
    assign
      subObj:ID        = inbf.id
      subObj:dispname  = inbf.dispname
      subObj:schedType = inbf.sched-type
      subObj:status_   = ibs.th.ref.promo.enum-sched-status:GetEnum(inbf.status_)
      subObj:extCodeSched = inbf.ext-code-sched
      subObj:db-num    = inbf.db-num
    .
    return subObj.
  end.
  method public void refreshObj (inSubObj as class promoSchedsub):
    define buffer buf_promo-schedule for ub.promo-schedule .
    if not valid-object (inSubObj)
    then do:
      Msg = "Объект типа promoSchedtsub не существует".
      return.
    end.
    find first buf_promo-schedule no-lock where buf_promo-schedule.ID = inSubObj:ID no-error.
    if not available (buf_promo-schedule)
    then do:
      Msg = "Не найдено расписание - " + string (inSubObj:ID).
      return.
    end.
    getDataStorage (buffer buf_promo-schedule).
  end.
end class.
