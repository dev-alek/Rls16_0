/*

$Revision: 8aa5522306d2, 3076, rls $
$Author: DRuban $
$Date: Пт авг 05 19:16:16 2022 +0300 $
$Workfile: promoschedstorage.cls $
$Archive: ibs/th/gbl/storage/promoschedstorage.cls $
 
Storage Sched Action

Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: Ruban Dmitriy
Creation date: 11/07/18

*/
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
  
  { cmp/str-glbl.i class }
  
  define property Msg as character
    get.
    private set.
  
  &scoped-define buf_db buf_promo-schedule
  
  &scoped-define class_sub  promoSchedsub

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method private void exception( arg as handle, inObj as class {&class_sub}, t-h as handle ):
    
    inObj:setMsg(arg:get-message (1)).
    inObj:setStatusErr(arg:error).
    t-h:buffer-delete () no-error.
    return.

  end method.

  method private void exception( arg as char ):
    
    Msg = arg.
    return.

  end method.
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public void insertDB( input inObj as {&class_sub} ):
    define buffer {&buf_db} for ub.promo-schedule .
    if inObj:db-num eq ? then
       undo, throw new Progress.Lang.AppError(
         substitute("отсутствует db-num в классе заголовков расписаний &1", inObj:dispname)
       ) .  
    create {&buf_db}.
    assign
      {&buf_db}.id     = inObj:ID
      {&buf_db}.db-num = inObj:db-num
    no-error.
    if error-status:error
    then do:
      exception(error-status, inObj, buffer {&buf_db}:handle).
      return.
    end.
    
    setDataStorage(input inObj, buffer {&buf_db}).
  end method.
  
  method public void updateDB( input inObj as {&class_sub}  ):
    define buffer {&buf_db} for ub.promo-schedule .  
    
    find first {&buf_db} where {&buf_db}.id = inObj:ID no-error.

    if not available ({&buf_db})
    then do:
      exception(error-status, inObj, buffer {&buf_db}:handle).
      return.
    end.
    setDataStorage(input inObj, buffer {&buf_db}).
    return.
  end method.
  
  method public void deleteDB( input inObj as {&class_sub}  ):
    if not valid-object(inObj)
    then 
       return.
    define buffer {&buf_db} for ub.promo-schedule . 
    find first {&buf_db} where {&buf_db}.id = inObj:ID no-error.

    if not available ({&buf_db})
    then do:
      exception(error-status, inObj, buffer {&buf_db}:handle).
      return.
    end.
    
    delete {&buf_db}.
    return.
  end method.
  
  method public class promoSchedsub getpromoSchedsub (input idPromoSched as integer):
    define buffer {&buf_db} for ub.promo-schedule .  
    define variable v-sub as class {&class_sub} no-undo .
    
    for first {&buf_db} where {&buf_db}.id eq idPromoSched
    no-lock:
        v-sub = getDataStorage (buffer {&buf_db}).
    end.      
    return v-sub.
  end method.
  
  method private void setDataStorage (input inObj as class {&class_sub}, buffer inbf for ub.promo-schedule ):
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
    define variable subObj  as class {&class_sub}.
    subObj = new {&class_sub} ().
    
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
  
  method public void refreshObj (inSubObj as class {&class_sub}):
    define buffer {&buf_db} for ub.promo-schedule .  
    
    if not valid-object (inSubObj)
    then do:
      Msg = "Объект типа promoSchedtsub не существует".
      return.
    end.
    
    find first {&buf_db} no-lock where {&buf_db}.ID = inSubObj:ID no-error.
    if not available ({&buf_db})
    then do:
      Msg = "Не найдено расписание - " + string (inSubObj:ID).
      return.
    end.
    getDataStorage (buffer {&buf_db}).
    
    
  end.

end class.
