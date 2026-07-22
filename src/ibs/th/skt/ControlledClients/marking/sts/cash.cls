/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 16 мая 2022 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 16 мая 2022 г.

*/

using Progress.Lang.*.
using ibs.th.gbl.sys.objth.
using ibs.th.gbl.propmap.
using ibs.th.gbl.map.mapstring.
using ibs.th.gbl.TypeMap.
block-level on error undo, throw.
class ibs.th.skt.ControlledClients.marking.sts.cash inherits TypeMap: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Статус марки по запросам с кассы" get.
 
  define public property  NotAccessible as class propmap no-undo get.  
    protected set.
  define public property  NotAccessibleRet as class propmap no-undo get.  
    protected set.
  define public property  NotReadyForSale as class propmap no-undo get.  
    protected set.
  define public property  OutZone as class propmap no-undo get.  
    protected set.
  define public property  Received as class propmap no-undo get.  
    protected set.
  define public property  Return_ as class propmap no-undo get.  
    protected set.


  define public property  SaleLock as class propmap no-undo get.  
    protected set.

  define public property  ReturnLock as class propmap no-undo get.  
    protected set.
  
  define public property  Unlock as class propmap no-undo get.  
    protected set.

  define public property  UnlockAll as class propmap no-undo get.  
    protected set.
  
  define public property  Commit as class propmap no-undo get.  
    protected set.

  define public property  LockOtherCash as class propmap no-undo get.  
    protected set.

  define public property  NotSaleSts as class propmap no-undo get.  
    protected set.
  
  define public property CashMap as class mapstring no-undo get. 
    protected set.
  constructor public cash ():
    
    CashMap = new mapstring(true).
    NotAccessible  = crProp(1,"NotAccessible","Маркированный товар еще не поступил в продажу на АЗК. Его реализация невозможна").
    NotAccessibleRet = crProp(9,"NotAccessibleRet","Маркированный товар еще не поступил в продажу на АЗК. Его оборот невозможен").
/*    NotReadyForSale = crProp(2,"CheckContr","Ожидает проверку по договору").*/
/*    Received   = crProp(7,"Received","Получен").                            */
/*    Return_ = crProp(8,"Return","Возврат").                                 */
/*    OutZone  = crProp(9,"OutZone","Выбыл").                                 */
    
    SaleLock  = crProp(2,"sale_lock","Маркированный товар заблокирован для продажи.").
    ReturnLock  = crProp(3,"return_lock","Маркированный товар заблокирован для возврата.").
    Unlock  = crProp(4,"unlock","Блокировка по кассе сброшена.").
    UnlockAll  = crProp(5,"unlock_all","Блокировки по кассе сброшены.").
    Commit  = crProp(6,"commit","Чек завершен.").
    
    LockOtherCash  = crProp(7,"LockOtherCash","Маркированный товар заблокирован другой кассой.").
    
    NotSaleSts  = crProp(8,"NotSaleSts","Товар не был продан.").

  end.

end class.
