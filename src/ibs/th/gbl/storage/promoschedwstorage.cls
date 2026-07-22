/*

$Revision: 8aa5522306d2, 3076, rls $
$Author: DRuban $
$Date: Пт авг 05 19:16:16 2022 +0300 $
$Workfile: promoschedwstorage.cls $
$Archive: ibs/th/gbl/storage/promoschedwstorage.cls $
 
Storage Schedw Action

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

class ibs.th.gbl.storage.promoSchedwstorage: 
  define variable vss-revision    as character no-undo initial "$Revision: 8aa5522306d2, 3076, rls $":U .
  define variable vss-author      as character no-undo initial "$Author: DRuban $":U .
  define variable vss-date        as character no-undo initial "$Date: Пт авг 05 19:16:16 2022 +0300 $":U .
  define variable vss-workfile    as character no-undo initial "$Workfile: promoschedwstorage.cls $":U .
  define variable vss-archive     as character no-undo initial "$Archive: ibs/th/gbl/storage/promoschedwstorage.cls $":U . 
  define variable vss-description as character no-undo initial "Storage SchedW Action". 
  
  { cmp/str-glbl.i class }
  
  define property Msg as character
    get.
    private set.
  
  &scoped-define buf_db buf_promo-schedule-week
  
  
  &scoped-define class_sub  promoSchedwsub
  &scoped-define class_subs promoSchedwsubs
  
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

  
  method public void updateDBAll( input inObjList as {&class_subs}  ):
      // 01/VIII-2018 пока ни от куда не вызывался
      updateDBAll (inObjList,?,?).
  end.
  method public void updateDBAll( input inObjList as {&class_subs}
                                , input idb-num   as integer
                                , input ishced-id as integer ):
    /* вызывается только из promoactionstorage:updatedbchiled();
       p-sched-id читается из класса PromoAction после формы редактирования до записи в БД */
      define variable vi as int no-undo.
      define variable v-sub as {&class_sub} no-undo .
      define variable v-sched-id as integer no-undo .
      
      v-sched-id = ishced-id .
      do vi = 1 to inObjList:GetItem(vi):
         v-sub = inObjList:promoSchedwObjCurr .
         case v-sub:Mode :
           when {&h-create} then do:
             assign
               v-sub:db-num  = idb-num    when (v-sub:db-num  = 0) and (idb-num    > 0)
               v-sub:schedId = v-sched-id when (v-sub:schedId = 0) and (v-sched-id > 0)
             .
             insertDB(v-sub).
             assign
               v-sched-id = v-sub:schedId when v-sched-id = 0
             .
           end .
           when {&h-update} then     
             updateDB(v-sub).
           when {&h-delete} then     
             deleteDB(v-sub).
           otherwise .
         end case .
      end. // end_of do_in_objList
          
  end. // end_of_updateDBAll        
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public void insertDB( input inObj as {&class_sub} ):
    if inObj:db-num eq ? then
       undo, throw new Progress.Lang.AppError(
         substitute("отсутствует db-num в классе расписаний &1 &2 & 3", inObj:wdaylist,inObj:timebeg,inObj:timeend)
       ) .
    define buffer {&buf_db} for ub.promo-schedule-week .
    
    inObj:ID = next-value (s-promosched-id, ub) .
    if inObj:schedId > 0 then . else inObj:schedId = inObj:ID .

    create {&buf_db}.
    assign
      {&buf_db}.id     = inObj:ID
      {&buf_db}.db-num = inObj:db-num
      {&buf_db}.promosched-id = inObj:schedId
    no-error.
    if error-status:error
    then do:
      exception(error-status, inObj, buffer {&buf_db}:handle).
      return.
    end.
    
    setDataStorage(input inObj, buffer {&buf_db}).
  end method.
  
  method public void updateDB( input inObj as {&class_sub} ):
    define buffer {&buf_db} for ub.promo-schedule-week .
    find first {&buf_db} where {&buf_db}.id = inObj:ID no-error.

    if not available ({&buf_db})
    then do:
      exception(error-status, inObj, buffer {&buf_db}:handle).
      return.
    end.
    setDataStorage(input inObj, buffer {&buf_db}).
    return.
  end method.
  
  method public void deleteDB( input inObj as {&class_sub} ):
    if not valid-object (inObj)
    then
       return.
    define buffer {&buf_db} for ub.promo-schedule-week . 
    find first {&buf_db} where {&buf_db}.id = inObj:ID no-error.

    if not available ({&buf_db})
    then do:
      exception(error-status, inObj, buffer {&buf_db}:handle).
      return.
    end.
    
    delete {&buf_db}.
    return.
  end method.
  
  method public class {&class_subs} getpromoSchedwsubs (input idPromoSched as integer):
    define buffer {&buf_db} for ub.promo-schedule-week .  
    define variable listObj as class {&class_subs}.
    listObj = new {&class_subs} ().
     
    for each {&buf_db} where {&buf_db}.promosched-id eq idPromoSched
    no-lock:
        listObj:AddItem(getDataStorage (buffer {&buf_db})).
    end.      
    return listObj.
  end method.
  
  method private void setDataStorage (input inObj as class {&class_sub}, buffer inbf for ub.promo-schedule-week ):
    assign
      inbf.timebeg       = inObj:timebeg
      inbf.timeend       = inObj:timeend
      inbf.wdaylist      = inObj:wdaylist
    .
    validate inbf.
  end method.
  
  method private class {&class_sub} getDataStorage ( buffer inbf for ub.promo-schedule-week ):
    define variable subObj  as class {&class_sub}.
    subObj = new {&class_sub} ().
    
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
  
  method public void refreshObj (inSubObj as class {&class_sub}):
    define buffer {&buf_db} for ub.promo-schedule-week .
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
