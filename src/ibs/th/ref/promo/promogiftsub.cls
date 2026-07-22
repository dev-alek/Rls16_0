/*

$Revision: e455fc319afd, 3602, rls $
$Author: ARostovtsev $
$Date: 2023/12/28 12:56:37 $
$Workfile: promogiftsub.cls $
$Archive: ibs/th/ref/promo/promogiftsub.cls $
 
Объект подаркок акции

Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: 
Creation date: 11/07/18

*/
 
using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
block-level on error undo, throw.


class ibs.th.ref.promo.PromoGiftSub implements ithsub: 
define variable vss-revision    as character no-undo initial "$Revision: e455fc319afd, 3602, rls $":U .
define variable vss-author      as character no-undo initial "$Author: ARostovtsev $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/12/28 12:56:37 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: promogiftsub.cls $":U .
define variable vss-archive     as character no-undo initial "$Archive: ibs/th/ref/promo/promogiftsub.cls $":U .
define variable vss-description as character no-undo initial "Объект подаркок акции.". 
  
  { cmp/str-glbl.i class}
  { ref/gdsoattr.i '' class}
  
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
    
  define property ID as int64  no-undo
    get.
    set (ID-arg as int64):
      ID = ID-arg.
/*      if ID <> ID            */
/*      then do:               */
/*        setFlagChange (true).*/
/*      end.                   */
    end.
    
  define property idCrit as int64 no-undo
    get.
    SET (arg as int64):
      if arg <> idCrit
      then do:
        idCrit = arg.
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
  
  define property db-num as integer  no-undo
    get.
    set(arg as integer ):
      if arg <> db-num
      then do:
        db-num = arg.
        setFlagChange (true).
      end.
    end. 
  define property GdsCode as integer no-undo
    get.
    set(arg as integer):
      if arg <> GdsCode
      then do:
        GdsCode = arg.
        setFlagChange (true).
      end.
    END.
  
  define property objCode as integer no-undo
    get.
    set.

    define buffer bf_gds for ub.goods.
    define property GdsName as character no-undo
    get:
      if available (bf_gds)
      then do:
        return bf_gds.gds-name.
      end.
      else do:
        find first bf_gds no-lock 
          where bf_gds.gds-code = GdsCode no-error.
        if available (bf_gds)
        then do:
          return bf_gds.gds-name.
        end.
        else return "".
      end.
    end.
    
    define property dtSeason as character no-undo
    get:
      define variable typeAttr as character no-undo.
      if not available (bf_gds) then 
      do:
        find first bf_gds no-lock 
          where bf_gds.gds-code = GdsCode no-error.
      end.
      if available (bf_gds) then 
      do:
          return 
            gdsoattr-value(
              {&attr-dt-seasons},
              gdsCode,
              {&shop},
              objCode,
              output typeAttr
            ).
      end.
      else return "".
    end.

    define property qnty as dec no-undo
    get.
    set(arg as dec):
      if arg <> qnty
      then do:
        qnty = arg.
        setFlagChange (true).
      end.
    END.
    
    define property mess as char no-undo
    get.
    set(arg as char):
      if arg <> mess
      then do:
        mess = arg.
        setFlagChange (true).
      end.
    END.

    define property mess-gks as char no-undo
    get.
    set(arg as char):
      if arg <> mess-gks
      then do:
        mess-gks = arg.
        setFlagChange (true).
      end.
    END.
        
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
    
  constructor public promogiftsub (  ):
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