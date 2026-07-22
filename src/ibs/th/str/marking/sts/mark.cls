/*
  $Revision:$
  $Author:$
  $Date:$
  $Workfile:$
  $Archive:$
  
  Автор: Рубан Дмитрий Андреевич 
  Дата создания: 9 янв. 2023 г.
  Author:  Ruban Dmitriy Andreevich
  Creation date: 9 янв. 2023 г.
  
  */

using Progress.Lang.*.
using ibs.th.gbl.propmap.
using ibs.th.gbl.TypeMap.
block-level on error undo, throw.

class ibs.th.str.marking.sts.mark inherits TypeMap:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Статусы марок" get.
   
  define public property  PendingVerification as class propmap no-undo get.  protected set.
  define public property  CheckContr  as class propmap no-undo get.  protected set.
  define public property  DeliveryControl  as class propmap no-undo get.  protected set.
  define public property  DemandInfo as class propmap no-undo get.  protected set.
  define public property  MarkError as class propmap no-undo get.  protected set.
  define public property  NotAvailable as class propmap no-undo get.  protected set.
  define public property  Checked_  as class propmap no-undo get.  protected set.
  define public property  Received as class propmap no-undo get.  protected set.
  define public property  OutZone as class propmap no-undo get.  protected set.
  define public property  FreeZone as class propmap no-undo get.  protected set.
  define public property  Reserved as class propmap no-undo get.  protected set.
  define public property  SaleLock  as class propmap no-undo get.  protected set.
  define public property  ReturnLock  as class propmap no-undo get.  protected set.
  define public property  SaleWaitLock  as class propmap no-undo get.  protected set.
  define public property  ReturnWaitLock  as class propmap no-undo get.  protected set.
  define public property  Ungrouped as class propmap no-undo get.  protected set.
  define public property  GrayZone as class propmap no-undo get.  protected set.
  
  define public property  UsedInProduction as class propmap no-undo get.  protected set.
  define public property  ReservedFromProduction as class propmap no-undo get.  protected set.
  define public property  WrittenOff  as class propmap no-undo get.  protected set.
  define public property  Moved  as class propmap no-undo get.  protected set.
  define public property  OutOfInventory  as class propmap no-undo get.  protected set.
  define public property  Returned  as class propmap no-undo get.  protected set.
  
  define public property  UnknowSts as class propmap no-undo get.  protected set.
  
  define public property  EqualChecked as character  no-undo get.  protected set.
  define public property  AllChecked   as character  no-undo get.  protected set.
  define public property  Sale_Return_Wait as character  no-undo get.  protected set.
  define public property  Doc_Status       as character  no-undo get.  protected set.
  define public property  FreeStatuses     as character  no-undo get.  protected set.
  /*
  define public property  ErrorSubordinateCodes as class propmap no-undo get.  protected set.
  define public property  ErrorOver as class propmap no-undo get.  protected set.
  define public property  Moved as class propmap no-undo get.  protected set.
  define public property  Implemented as class propmap no-undo get.  protected set.
  define public property  Sale  as class propmap no-undo get.  protected set.
  define public property  Return_  as class propmap no-undo get.  protected set.
*/
 
  constructor public mark ():
     
    super().
    PendingVerification  = crProp(1,"PendingVerification","Ожидает проверку").
    CheckContr   = crProp(2,"CheckContr","Ожидает проверку по договору").
    DeliveryControl = crProp(3,"DeliveryControl","Ожидает приемку").
    DemandInfo = crProp(4,"DemandInfo","Запрос инфо").
    MarkError = crProp(5,"MarkError","Ошибка").
    NotAvailable   = crProp(6,"NotAvailable","Отсутствует в поставке").
    Checked_   = crProp(7,"Checked_","Проверен").
    Received   = crProp(8,"Received","Получен").
    OutZone  = crProp(9,"OutZone","Выбыл").
    FreeZone  = crProp(10,"FreeZone","Свободная зона").
    SaleLock   = crProp(11,"SaleLock","Продан на кассе").
    ReturnLock   = crProp(12,"ReturnLock","Возвращен на кассе").
    Reserved   = crProp(13,"Reserved","Зарезервирован").
    SaleWaitLock   = crProp(14,"SaleWaitLock","Идет продажа").
    ReturnWaitLock   = crProp(15,"ReturnWaitLock","Блокировка идет возврат").

    WrittenOff   = crProp(16,"WrittenOff","Списан").
    UsedInProduction = crProp(17,"ProductionUse","Использован в производство").
    ReservedFromProduction = crProp(18,"ReservedFromProduction","Зарезервирован для возврата в оборот").
    Moved = crProp(19,"Moved","Перемещен").
   
    Ungrouped  = crProp(20,"Ungrouped","Разгруппирован").
    
    GrayZone  = crProp(21,"GrayZone","Серая зона").
    OutOfInventory  = crProp(22,"Retired","Выбыл при инвентаризации марок").
    Returned   = crProp(23,"Returned","Возвращен поставщику").
    
    
    UnknowSts  = crProp(0,"UnknowSts","Неизвестный статус маркированного товара.").
    
    EqualChecked = "7,11,12".            /* Cтатусы равносильные статусу Проверен */
    Sale_Return_Wait  = "11,12,14,15".   /* Статусы, что марка добавлена  чек  */
    Doc_Status = "13,16,17,18,19,22,23". /* Статусы, что марка добавлена в какой-либо расходный док-т */
    FreeStatuses = "1,3,5,6,7,10".       /* Статусы, что марка не добавена в чек или в какой-либо расходный док-т */
    AllChecked   = substitute("7,&1,&2",Sale_Return_Wait,Doc_Status). /* Cтатусы равносильные статусу Проверен - полный список*/
    
    
   /* 
    ErrorSubordinateCodes  = crProp(6,"ErrorSubordinateCodes","Ошибка подчиненных кодов").
    ErrorOver  = crProp(7,"ErrorOver","Ошибка излишек").
    Moved  = crProp(8,"Moved","Перемещен").
    
    WrittenOff   = crProp(10,"WrittenOff ","Списан").
    Sale   = crProp(11,"Sale","Продажа").
    Return_   = crProp(12,"Return","Возврат").
    SaleLock   = crProp(13,"SaleLock","Блокировка продажа").
    ReturnLock   = crProp(14,"ReturnLock","Блокировка возврат").
   */
  end.



end class.