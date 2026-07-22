/*

$Revision: e455fc319afd, 3602, rls $
$Author: ARostovtsev $
$Date: 2023/12/28 12:56:37 $
$Workfile: promogoodssub.cls $
$Archive: ibs/th/ref/promo/promogoodssub.cls $
 
Объект товар акции

Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: 
Creation date: 11/07/18

*/
 
using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
using ibs.th.ref.promo.promoGoodsSubs.
block-level on error undo, throw.
 
class ibs.th.ref.promo.PromoGoodsSub implements ithsub: 
  define variable vss-revision    as character no-undo initial "$Revision: e455fc319afd, 3602, rls $":U .
  define variable vss-author      as character no-undo initial "$Author: ARostovtsev $":U .
  define variable vss-date        as character no-undo initial "$Date: 2023/12/28 12:56:37 $":U .
  define variable vss-workfile    as character no-undo initial "$Workfile: promogoodssub.cls $":U .
  define variable vss-archive     as character no-undo initial "$Archive: ibs/th/ref/promo/promogoodssub.cls $":U .
  define variable vss-description as character no-undo initial "Объект товар акции.". 
  
  { cmp/str-glbl.i class}
  { ref/gdsoattr.i '' class}
  
  define property Msg as character no-undo
    get.
    set.
    
  define property Mode as char no-undo init {&h-update}
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
    
  define property db-num as integer init ?  no-undo
    get.
    set(arg as int):
      if arg <> db-num
        then 
      do:
        db-num = arg.
        setFlagChange (true).
      end.
    end.
    
  define property idSet as int64 no-undo
    get.
    set(arg as int64):
      if arg <> idSet
        then 
      do:
        idSet = arg.
        setFlagChange (true).
      end.
    end.
    
  define property qnty as decimal  no-undo
    get.
    set(arg as decimal ):
      if arg <> qnty
        then 
      do:
        qnty = arg.
        setFlagChange (true).
      end.
    end.
    
  define property NameSet as character  no-undo
    get.
    set(arg as character  ):
      if arg <> NameSet
        then 
      do:
        NameSet = arg.
        setFlagChange (true).
      end.
    end.
    
  define property price as decimal  init ?  no-undo
    get.
    set(arg as decimal ):
      if arg <> price
        then 
      do:
        price = arg.
        setFlagChange (true).
      end.  
    end.
    
  define buffer buf_PromoAttr for ub.PromoAttr .
  define property promotion-code as character  init ""  no-undo
    get.
    set(arg as character ):
      if arg <> promotion-code
        then 
      do:
        promotion-code = arg.
        setFlagChange (true).
      end.  
    end.

  define property type as int no-undo
    get.
    SET (arg as int):
      if arg <> type
        then 
      do:
        type = arg.
        setFlagChange (true).
      end.
    END.  
  
  define property idAction as int64 no-undo
    get.
    set(arg as int64):
      if arg <> idAction
        then 
      do:
        idAction = arg.
        setFlagChange (true).
      end.
    END. 

  define property objCode as integer no-undo
    get.
    set(arg as integer):
      if arg <> objCode
        then 
      do:
        objCode = arg.
        setFlagChange (true).
      end.
    end.

  define buffer bf_gds for ub.goods.
  define property GdsCode as integer no-undo
    get.
    set(arg as integer):
      if arg <> GdsCode
        then 
      do:
        GdsCode = arg.
        release bf_gds.
        setFlagChange (true).
      end.
    END.
    
  define property GdsName as character no-undo
    get:
      if available (bf_gds)
        then 
      do:
        return bf_gds.gds-name.
      end.
      else 
      do:
        find first bf_gds no-lock 
          where bf_gds.gds-code = GdsCode no-error.
        if available (bf_gds)
          then 
        do:
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

  define property promo-code as character no-undo
    get:
      if available (buf_PromoAttr)
        then 
      do:
        return buf_PromoAttr.attr-value.
      end.
      else 
      do:
        find first buf_PromoAttr no-lock where buf_promoAttr.attr-code = "bc-code" and
          buf_promoAttr.tablename = "PromoGoods" and
          idAction = int64(entry(1,buf_PromoAttr.p-key,{&delim-key})) and 
          db-num = integer(entry(2,buf_PromoAttr.p-key,{&delim-key})) and
          GdsCode = integer(entry(3,buf_PromoAttr.p-key,{&delim-key})) no-error .
        if available (buf_PromoAttr) then 
        do:
          return buf_PromoAttr.attr-value .
        end.
        else return "".
      end.    

    end.     
  {ibs/th/ref/promo/propertyclass.i
     &Obj       = promoSetGoods
     &ObjClass  = promoGoodssubs
     &StorClass = promoGoodsStorage
     &storColec = getpromoGoodssubs(idAction,id,ibs.th.ref.promo.enum-promo-goods-type:promoSetGoods,db-num,objCode) } 
    
  define property Changed as logical no-undo
    get.
    set.
  /*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    
  constructor public promogoodssub (  ):
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
  
  define private property refreshObj as logical no-undo
    get.
    set.
    
  method public void Clean():
    if valid-object(THIS-OBJECT:PromoSetGoods) then delete object THIS-OBJECT:PromoSetGoods no-error.
  end.
  method public void refreshChildObj():
    Clean(). 
    this-object:refreshObj = yes.
    THIS-OBJECT:PromoSetGoods no-error.
    this-object:refreshObj = no.
  end.
  destructor public promogoodssub ( ):
    Clean().
  end destructor.

end class.