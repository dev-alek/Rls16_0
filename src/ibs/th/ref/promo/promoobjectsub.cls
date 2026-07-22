/*

$Revision: 709fd28fa30d, 1490, rls $
$Author: SMMolotkov $
$Date: Thu Aug 30 10:41:46 2018 +0300 $
$Workfile: promoobjectsub.cls $
$Archive: ibs/th/ref/promo/promoobjectsub.cls $
 
Объект объекта акции

Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: 
Creation date: 11/07/18

*/

using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
USING ibs.th.ref.promo.*.
block-level on error undo, throw.

class ibs.th.ref.promo.PromoObjectSub implements ithsub: 
define variable vss-revision    as character no-undo initial "$Revision: 709fd28fa30d, 1490, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Aug 30 10:41:46 2018 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: promoobjectsub.cls $":U .
define variable vss-archive     as character no-undo initial "$Archive: ibs/th/ref/promo/promoobjectsub.cls $":U .
define variable vss-description as character no-undo initial "Объект объекта акции.". 
  
  { cmp/str-glbl.i class}
  {cmp/library.i class}
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
    
  define property ID as int64 init ?  no-undo
    get.
    set (ID-arg as int64):
      ID = ID-arg.
/*      if ID <> ID            */
/*      then do:               */
/*        setFlagChange (true).*/
/*      end.                   */
    end.
    
    define property db-num as integer  no-undo
    get.
    set(arg as integer ):
      if arg <> db-num
      then do:
        db-num = arg.
        setFlagChange (true).
      end.
    end. 
  define buffer bf_clients for ub.clients.  
  define property obj-type as char no-undo
    get.
    SET (arg as char):
      if arg <> obj-type
      then do:
        obj-type = arg.
        release bf_clients.
        setFlagChange (true).
      end.
    END.  
  
  define property idAction as int64 no-undo
    get.
    set(arg as int64):
      if arg <> idAction
      then do:
        idAction = arg.
        setFlagChange (true).
      end.
    END. 
  
  define property obj-code as int no-undo
    get.
    set(arg as int):
      if arg <> obj-code
      then do:
        obj-code = arg.
        release bf_clients.
        setFlagChange (true).
      end.
    END.
    
  define property end-date as date no-undo
    get.
    set(arg as date):
      if arg <> end-date
      then do:
        end-date = arg.
        setFlagChange (true).
      end.
    END.
    
    define property FirmCode as integer no-undo
    get:
        define  variable v-host-code as integer   no-undo.
        define  variable v-host-name as character no-undo.
        { gbl/hostname.i
            obj-type
            obj-code
            v-host-code
            v-host-name
        }
        return  v-host-code.     
    end.
    
    define property FirmName as char no-undo
    get:
        define  variable v-host-code as integer no-undo.
        define  variable v-host-name as character no-undo.
        { gbl/hostname.i
            obj-type
            obj-code
            v-host-code
            v-host-name
        }
        return  v-host-name.     
    end.
    
    define property objName as character no-undo
    get:
      if available (bf_clients)
      then do:
        return bf_clients.obj-name.
      end.
      else do:
        find first bf_clients no-lock
             where bf_clients.obj-type = obj-type
               and bf_clients.obj-code = obj-code
        no-error.
        if available (bf_clients)
        then do:
          return bf_clients.obj-name.
        end.
        else return "".
      end.
    end.
    
    define property objDbNum as Integer no-undo
    get:
      if available (bf_clients)
      then do:
        return bf_clients.db-num.
      end.
      else do:
        find first bf_clients no-lock
             where bf_clients.obj-type = obj-type
               and bf_clients.obj-code = obj-code
        no-error.
        if available (bf_clients)
        then do:
          return bf_clients.db-num.
        end.
        else return 0.
      end.
    end.
    
    define property Mode as char no-undo init {&h-update}
    get.
    set.
    
    define property Changed as logical no-undo
    get.
    set.
    /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
    
  constructor public promoobjectsub (  ):
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
  
 /* define private property refreshObj as logical no-undo
    get.
    set.
  
  method public void Clean():
     if valid-object(THIS-OBJECT:Gifts)      then delete object THIS-OBJECT:Gifts no-error.
     
  end.  
  method public void refreshChildObj():
     Clean(). 
     this-object:refreshObj = yes.
     THIS-OBJECT:Gifts no-error.
     this-object:refreshObj = no.
     
     
  end.*/
  destructor public promoobjectsub ( ):
   //  Clean().
     
  end destructor.
  
end class.