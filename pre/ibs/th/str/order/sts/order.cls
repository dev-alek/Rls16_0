using Progress.Lang.*.
using ibs.th.gbl.propmap.
using ibs.th.gbl.map.mapstring.
using ibs.th.gbl.sys.objth.
using ibs.th.gbl.sys.objsrv.
using ibs.th.gbl.TypeMap.
block-level on error undo, throw.
class ibs.th.str.order.sts.order inherits TypeMap:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Статусы ЭДО в TH" get.
  define public property  NewStatus         as class propmap no-undo get.  protected set.
  define public property  Sended            as class propmap no-undo get.  protected set.
  define public property  ReceivedProvider  as class propmap no-undo get.  protected set.
  define public property  Shipment          as class propmap no-undo get.  protected set.
  define public property  Corrected         as class propmap no-undo get.  protected set.
  define public property  Cancelled         as class propmap no-undo get.  protected set.
  define public property  DeliveryWaiting   as class propmap no-undo get.  protected set.
  define public property  DeliveryCompleted as class propmap no-undo get.  protected set.
  constructor public order ():
    super().
    NewStatus  = crProp(1, "NewStatus", "Новый").
    Sended     = crProp(2, "Sended", "Отправлен").
    Shipment   = crProp(3, "Shipment", "Подтвержден").
    Corrected  = crProp(4, "Corrected", "Изменен").
    Cancelled  = crProp(5, "Cancelled", "Отклонен").
    DeliveryWaiting   = crProp(6,"DeliveryWaiting","Ожидает поставку").
    DeliveryCompleted = crProp(7,"DeliveryCompleted","Завершен").
    ReceivedProvider  = crProp(8, "ReceivedProvider", "Получен поставщиком").
  end.
  method public logical CheckStsErr(inKey as int):
    if NewStatus:KeyIntDB           = inKey
      or Sended:KeyIntDB            = inKey
      or ReceivedProvider:KeyIntDB  = inKey
      or Shipment:KeyIntDB          = inKey
      or Corrected:KeyIntDB         = inKey
      or Cancelled:KeyIntDB         = inKey
      or DeliveryWaiting:KeyIntDB   = inKey
      or DeliveryCompleted:KeyIntDB = inKey
      then return true.
      else return false.
  end method.
end class.
