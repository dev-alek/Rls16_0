/*

$Revision: c16e05d4b612, 2089, rls $
$Author: EShklyar $
$Date: Wed Dec 25 15:23:51 2019 +0300 $
$Workfile: BpaActionSub.cls $
$Archive: ibs/th/ref/bpa/BpaActionSub.cls $
 
"Объект акция."

Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: 
Creation date: 11/07/18

*/

using Progress.Lang.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
USING ibs.th.ref.bpa.*.
block-level on error undo, throw.
 
class ibs.th.ref.bpa.BpaActionSub implements ithsub: 

define variable vss-revision    as character no-undo initial "$Revision: c16e05d4b612, 2089, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Wed Dec 25 15:23:51 2019 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: BpaActionSub.cls $":U .
define variable vss-archive     as character no-undo initial "$Archive: ibs/th/ref/bpa/BpaActionSub.cls $":U .
define variable vss-description as character no-undo initial "Объект акция.". 
  
  { cmp/str-glbl.i class}
   
/*    define variable vpromotype as class promotype no-undo.                                            */
/*    define property Msg as character no-undo                                                          */
/*    get.                                                                                              */
/*    set.                                                                                              */
/*                                                                                                      */
/*    define property StatusErr as logical no-undo                                                      */
/*    get:                                                                                              */
/*      def var err as log no-undo.                                                                     */
/*      err = StatusErr.                                                                                */
/*      StatusErr = false.                                                                              */
/*      return err.                                                                                     */
/*    end.                                                                                              */
/*    private set.                                                                                      */
/*                                                                                                      */
/*  define property ID as int64  no-undo                                                                */
/*    get.                                                                                              */
/*    set (ID-arg as int64):                                                                            */
/*      ID = ID-arg.                                                                                    */
/*/*      if ID <> ID            */                                                                     */
/*/*      then do:               */                                                                     */
/*/*        setFlagChange (true).*/                                                                     */
/*/*      end.                   */                                                                     */
/*    end.                                                                                              */
/*                                                                                                      */
/*    define property db-num as integer no-undo                                                         */
/*    get.                                                                                              */
/*    set(arg as integer):                                                                              */
/*      if arg <> db-num                                                                                */
/*      then do:                                                                                        */
/*        db-num = arg.                                                                                 */
/*        setFlagChange (true).                                                                         */
/*      end.                                                                                            */
/*    END.                                                                                              */
/*                                                                                                      */
/*                                                                                                      */
/*  define property beg-date as Date no-undo                                                            */
/*    get():                                                                                            */
/*       return if beg-date eq ? then today else beg-date.                                              */
/*    end.                                                                                              */
/*    SET (arg as Date):                                                                                */
/*      if arg <> beg-date                                                                              */
/*      then do:                                                                                        */
/*        beg-date = arg.                                                                               */
/*        setFlagChange (true).                                                                         */
/*      end.                                                                                            */
/*    END.                                                                                              */
/*                                                                                                      */
/*  define property end-date as Date no-undo                                                            */
/*    get():                                                                                            */
/*       return if end-date eq ? then today else end-date.                                              */
/*    end.                                                                                              */
/*    set(arg as Date):                                                                                 */
/*      if arg <> end-date                                                                              */
/*      then do:                                                                                        */
/*        end-date = arg.                                                                               */
/*        setFlagChange (true).                                                                         */
/*      end.                                                                                            */
/*    END.                                                                                              */
/*                                                                                                      */
/*  define property NameAction as char no-undo                                                          */
/*    get.                                                                                              */
/*    set(arg as char):                                                                                 */
/*      if arg <> NameAction                                                                            */
/*      then do:                                                                                        */
/*        NameAction = arg.                                                                             */
/*        setFlagChange (true).                                                                         */
/*      end.                                                                                            */
/*    END.                                                                                              */
/*                                                                                                      */
/*  define property promosched-id as integer no-undo                                                    */
/*    get.                                                                                              */
/*    set.                                                                                              */
/*                                                                                                      */
/*  {ibs/th/ref/promo/propertytype.i                                                                    */
/*    &PropertyName = TypeDiscont                                                                       */
/*    &ObjType      = vpromotype                                                                        */
/*    &PropertyType = ibs.th.ref.promo.enum-type-discount                                               */
/*    }                                                                                                 */
/*                                                                                                      */
/*  {ibs/th/ref/promo/propertytype.i                                                                    */
/*    &PropertyName = methodCalc                                                                        */
/*    &ObjType      = vpromotype                                                                        */
/*    }                                                                                                 */
/*                                                                                                      */
/*  {ibs/th/ref/promo/propertytype.i                                                                    */
/*    &PropertyName = typecond                                                                          */
/*    &ObjType      = vpromotype                                                                        */
/*    }                                                                                                 */
/*                                                                                                      */
/*  {ibs/th/ref/promo/propertytype.i                                                                    */
/*    &PropertyType = ibs.th.ref.promo.enum-promo-status                                                */
/*    &PropertyName = status_                                                                           */
/*    &ObjType      = vpromotype                                                                        */
/*    }                                                                                                 */
/*                                                                                                      */
/*    define property priority as int no-undo                                                           */
/*    get.                                                                                              */
/*    SET (arg as int):                                                                                 */
/*      if arg <> priority                                                                              */
/*      then do:                                                                                        */
/*        priority = arg.                                                                               */
/*        setFlagChange (true).                                                                         */
/*      end.                                                                                            */
/*    END.                                                                                              */
/*                                                                                                      */
/*    define property comment as char no-undo                                                           */
/*    get.                                                                                              */
/*    SET (arg as char):                                                                                */
/*      if arg <> comment                                                                               */
/*      then do:                                                                                        */
/*        comment = arg.                                                                                */
/*        setFlagChange (true).                                                                         */
/*      end.                                                                                            */
/*    END.                                                                                              */
/*                                                                                                      */
/*    define property description as char no-undo                                                       */
/*    get.                                                                                              */
/*    set (arg as char):                                                                                */
/*      if arg <> description                                                                           */
/*      then do:                                                                                        */
/*        description = arg.                                                                            */
/*        setFlagChange (true).                                                                         */
/*      end.                                                                                            */
/*    end.                                                                                              */
/*                                                                                                      */
/*    define property paymenttype as char no-undo                                                       */
/*    get.                                                                                              */
/*    set (arg as char):                                                                                */
/*      if arg <> paymenttype                                                                           */
/*      then do:                                                                                        */
/*        paymenttype = arg.                                                                            */
/*        setFlagChange (true).                                                                         */
/*      end.                                                                                            */
/*    end.                                                                                              */
/*                                                                                                      */
/*    define property ext-code as char no-undo                                                          */
/*    get.                                                                                              */
/*    set (arg as char):                                                                                */
/*      if arg <> ext-code                                                                              */
/*      then do:                                                                                        */
/*        ext-code = arg.                                                                               */
/*        setFlagChange (true).                                                                         */
/*      end.                                                                                            */
/*    end.                                                                                              */
/*                                                                                                      */
/*     define property changeDate as date no-undo                                                       */
/*    get.                                                                                              */
/*    set (arg as date):                                                                                */
/*      if arg <> changeDate                                                                            */
/*      then do:                                                                                        */
/*        changeDate = arg.                                                                             */
/*        setFlagChange (true).                                                                         */
/*      end.                                                                                            */
/*    end.                                                                                              */
/*                                                                                                      */
/*    define property Mode as char no-undo init {&h-update}                                             */
/*    get.                                                                                              */
/*    set.                                                                                              */
/*                                                                                                      */
/*    {ibs/th/ref/promo/propertyclass.i                                                                 */
/*     &Obj       = GoodsCrits                                                                          */
/*     &ObjClass  = promogoodssubs                                                                      */
/*     &StorClass = promoGoodsStorage                                                                   */
/*     &storColec = getpromoGoodssubs(id,ibs.th.ref.promo.enum-promo-goods-type:criterion,db-num) }     */
/*                                                                                                      */
/*    define property CritgoodsFl as logical no-undo init ?                                             */
/*    get():                                                                                            */
/*      return if CritgoodsFl eq ?                                                                      */
/*             then if valid-object (this-object:GoodsCrits)                                            */
/*                  then GoodsCrits:iCounter ne 0                                                       */
/*                  else no                                                                             */
/*             else no.                                                                                 */
/*    end.                                                                                              */
/*    set.                                                                                              */
/*                                                                                                      */
/*    {ibs/th/ref/promo/propertyclass.i                                                                 */
/*     &Obj       = GoodsAppl                                                                           */
/*     &ObjClass  = promogoodssubs                                                                      */
/*     &StorClass = promoGoodsStorage                                                                   */
/*     &storColec = getpromoGoodssubs(id,ibs.th.ref.promo.enum-promo-goods-type:appl,db-num) }          */
/*                                                                                                      */
/*     {ibs/th/ref/promo/propertyclass.i                                                                */
/*     &Obj       = PromoSet                                                                            */
/*     &ObjClass  = promogoodssubs                                                                      */
/*     &StorClass = promoGoodsStorage                                                                   */
/*     &storColec = getpromoGoodssubs(id,ibs.th.ref.promo.enum-promo-goods-type:promoSet,db-num) }      */
/*                                                                                                      */
/*    {ibs/th/ref/promo/propertyclass.i                                                                 */
/*     &Obj       = Criterion                                                                           */
/*     &ObjClass  = promoCriterionsubs                                                                  */
/*     &StorClass = promoCriterionStorage                                                               */
/*     &storColec = getpromoCriterionSubs(id,db-num) }                                                  */
/*                                                                                                      */
/*    {ibs/th/ref/promo/propertyclass.i                                                                 */
/*     &Obj       = Gifts                                                                               */
/*     &ObjClass  = promoGiftsubs                                                                       */
/*     &StorClass = promoGiftStorage                                                                    */
/*     &storColec = getpromoGiftSubs(id,0,db-num) }                                                     */
/*                                                                                                      */
/*     {ibs/th/ref/promo/propertyclass.i                                                                */
/*     &Obj       = Objects                                                                             */
/*     &ObjClass  = promoObjectSubs                                                                     */
/*     &StorClass = promoObjectStorage                                                                  */
/*     &storColec = getpromoObjectSubs(id,db-num) }                                                     */
/*                                                                                                      */
/*    {ibs/th/ref/promo/propertyclass.i                                                                 */
/*     &Obj       = Schedule                                                                            */
/*     &ObjClass  = promoSchedsub                                                                       */
/*     &StorClass = promoSchedStorage                                                                   */
/*     &storColec = getpromoSchedSub(promosched-id) }                                                   */
/*                                                                                                      */
/*    {ibs/th/ref/promo/propertyclass.i                                                                 */
/*     &Obj       = ScheduleWeek                                                                        */
/*     &ObjClass  = promoSchedwsubs                                                                     */
/*     &StorClass = promoSchedwStorage                                                                  */
/*     &storColec = getpromoSchedwSubs(promosched-id) }                                                 */
/*                                                                                                      */
/*    define property Changed as logical no-undo                                                        */
/*    get.                                                                                              */
/*    set.                                                                                              */
/*                                                                                                      */
/*      /*------------------------------------------------------------------------------                */
/*   Purpose:                                                                                           */
/*   Notes:                                                                                             */
/*  ------------------------------------------------------------------------------*/                    */
/*                                                                                                      */
/*  constructor public promoactionsub (  ):                                                             */
/*      vpromotype = new promotype().                                                                   */
/*  end constructor.                                                                                    */
/*                                                                                                      */
/*  /*------------------------------------------------------------------------------                    */
/*   Purpose:                                                                                           */
/*   Notes:                                                                                             */
/*  ------------------------------------------------------------------------------*/                    */
/*                                                                                                      */
/*  method public void setMsg( arg as character ):                                                      */
/*                                                                                                      */
/*    Msg = arg.                                                                                        */
/*                                                                                                      */
/*  end.                                                                                                */
/*                                                                                                      */
/*  /*------------------------------------------------------------------------------                    */
/*   Purpose:                                                                                           */
/*   Notes:                                                                                             */
/*  ------------------------------------------------------------------------------*/                    */
/*  method public void setStatusErr( arg as logical ):                                                  */
/*                                                                                                      */
/*    StatusErr = arg.                                                                                  */
/*                                                                                                      */
/*  end.                                                                                                */
/*  method public void setFlagChange( arg as logical ):                                                 */
/*                                                                                                      */
/*    Changed = arg.                                                                                    */
/*                                                                                                      */
/*  end.                                                                                                */
/*                                                                                                      */
/*  define private property refreshObj as logical no-undo                                               */
/*    get.                                                                                              */
/*    set.                                                                                              */
/*                                                                                                      */
/*  method public void Clean():                                                                         */
/*     if valid-object(THIS-OBJECT:Criterion)  then delete object THIS-OBJECT:Criterion no-error.       */
/*     if valid-object(THIS-OBJECT:Gifts)      then delete object THIS-OBJECT:Gifts no-error.           */
/*     if valid-object(THIS-OBJECT:GoodsAppl)  then delete object THIS-OBJECT:GoodsAppl no-error.       */
/*     if valid-object(THIS-OBJECT:GoodsCrits) then delete object THIS-OBJECT:GoodsCrits no-error.      */
/*     if valid-object(this-object:Objects   ) then delete object this-object:Objects no-error.         */
/*     if valid-object(THIS-OBJECT:Schedule)     then delete object THIS-OBJECT:Schedule no-error.      */
/*     if valid-object(THIS-OBJECT:ScheduleWeek) then delete object THIS-OBJECT:ScheduleWeek no-error.  */
/*                                                                                                      */
/*  end.                                                                                                */
/*  method public void refreshChildObj():                                                               */
/*     Clean().                                                                                         */
/*     this-object:refreshObj = yes.                                                                    */
/*     /* блок от start до end в версии OpenEdge Release 11.7.1 as of Wed Jun 14 19:02:16 EDT 2017      */
/*        выполняет чтение всех свойств экземпляра класса при КАЖДОМ обращении к ЛЮБОМУ свойству класса.*/
/*     */                                                                                               */
/*     // --- start ---                                                                                 */
/*     THIS-OBJECT:Criterion no-error.                                                                  */
/*     THIS-OBJECT:Gifts no-error.                                                                      */
/*     THIS-OBJECT:GoodsAppl no-error.                                                                  */
/*     THIS-OBJECT:Promoset no-error.                                                                   */
/*     THIS-OBJECT:GoodsCrits no-error.                                                                 */
/*     this-object:Objects no-error.                                                                    */
/*     THIS-OBJECT:Schedule no-error.                                                                   */
/*     THIS-OBJECT:ScheduleWeek no-error.                                                               */
/*     // --- end ---                                                                                   */
/*     this-object:refreshObj = no.                                                                     */
/*  end method.                                                                                         */
/*  destructor public promoactionsub ( ):                                                               */
/*     Clean().                                                                                         */
/*     delete object vpromotype no-error.                                                               */
/*  end destructor.                                                                                     */
/*                                                                                                      */
end class.