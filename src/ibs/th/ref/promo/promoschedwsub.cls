/*

$Revision: 709fd28fa30d, 1490, rls $
$Author: SMMolotkov $
$Date: Thu Aug 30 10:41:46 2018 +0300 $
$Workfile: promoschedwsub.cls $
$Archive: ibs/th/ref/promo/promoschedwsub.cls $

Сущность Дни расписания промоакций

Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: 
Creation date: 11/07/18

*/

using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
block-level on error undo, throw.



class ibs.th.ref.promo.PromoSchedwSub implements ithsub: 
define variable vss-revision    as character no-undo initial "$Revision: 709fd28fa30d, 1490, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Aug 30 10:41:46 2018 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: promoschedwsub.cls $":U .
define variable vss-archive     as character no-undo initial "$Archive: ibs/th/ref/promo/promoschedwsub.cls $":U .
define variable vss-description as character no-undo initial "Сущность Дни расписания промоакций". 
  
  { cmp/str-glbl.i class}
  
  define property Msg as character no-undo
    get.
    set.
    
    define property StatusErr as logical no-undo
    get:
      def var err as log no-undo.
      err = StatusErr.
      StatusErr = false.
      return err.
    end.
    private set.
    
  define property ID as integer no-undo
    get.
    set.
    
  define property timebeg as integer no-undo
    get.
    set(arg as integer):
      if arg <> timebeg
      then do:
        timebeg = arg.
        setFlagChange (true).
      end.
    END.
    
  define property timeend as integer no-undo
    get.
    set(arg as integer):
      if arg <> timeend
      then do:
        timeend = arg.
        setFlagChange (true).
      end.
    END.

  define property schedId as integer no-undo
    get.
    set(arg as integer):
      if arg <> schedId
      then do:
        schedId = arg.
        setFlagChange (true).
      end.
    END.
    
  define property wdaylist as char no-undo
    get.
    set(arg as char):
      if arg <> wdaylist
      then do:
        wdaylist = arg.
        setFlagChange (true).
      end.
    END.
    
  define property db-num as integer no-undo
    get.
    set(arg as integer):
      if arg <> db-num
      then do:
        db-num = arg.
        setFlagChange (true).
      end.
    END.

    define property Mode as char init {&h-update} no-undo
    get.
    set.
    
    define property Changed as logical no-undo
    get.
    set.
    /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
    
  constructor public promoschedwsub (  ):
  end constructor.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public void setMsg( arg as character ):
    
    Msg = arg.
    
  end.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method public void setStatusErr( arg as logical ):
    
    StatusErr = arg.
    
  end.
  method public void setFlagChange( arg as logical ):
    
    Changed = arg.
    
  end.
  
end class.