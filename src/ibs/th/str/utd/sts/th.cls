 
/*------------------------------------------------------------------------
  File    : th
  Purpose   : 
  Syntax   : 
  Description : 
  Author(s)  : asmorozov
  Created   : Wed Feb 19 17:57:46 MSK 2020
  Notes    : 
 ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.gbl.propmap.
using ibs.th.gbl.map.mapstring.
using ibs.th.gbl.sys.objth.
using ibs.th.gbl.sys.objsrv.
using ibs.th.gbl.TypeMap.
block-level on error undo, throw.

class ibs.th.str.utd.sts.th inherits TypeMap:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Статусы ЭДО в TH" get.
  
  define public property  NewStatus  as class propmap no-undo get.  protected set.
  define public property  ReceivedFromSupplier  as class propmap no-undo get.  protected set.
  define public property  VerificationPassed  as class propmap no-undo get.  protected set.
  define public property  RequiresAdjustment  as class propmap no-undo get.  protected set.
  define public property  AwaitingDelivery  as class propmap no-undo get.  protected set.
  define public property  SignatureRequired as class propmap no-undo get.  protected set.
  define public property  AwaitingConfirmation  as class propmap no-undo get.  protected set.
  define public property  CorrectionRequested as class propmap no-undo get.  protected set.
  define public property  Confirmed as class propmap no-undo get.  protected set.
  define public property  CancellationRequest as class propmap no-undo get.  protected set.
  define public property  Canceled as class propmap no-undo get.  protected set.

  define public property  LackOfMarkingCodesInCirculation as class propmap no-undo get.  protected set.
  define public property  DeliveryCodeMismatch as class propmap no-undo get.  protected set.
  define public property  InconsistencyWithSupplyContract as class propmap no-undo get.  protected set.
  define public property  LoadError as class propmap no-undo get.  protected set.
  define public property  edocError as class propmap no-undo get.  protected set.
  define public property  RejectionUtd as class propmap no-undo get.  protected set.
  define public property  ConfirmedUcd as class propmap no-undo get.  protected set.
  define public property  LinesInError as class propmap no-undo get.  protected set.
  define public property  Rejection as class propmap no-undo get.  protected set.    
  
  /* Статусы для Вывода из Оборота */
  define public property  LK_RECEIPT_New as class propmap no-undo get.  protected set.
  define public property  LK_RECEIPT_Signed as class propmap no-undo get.  protected set.
  define public property  LK_RECEIPT_Sent as class propmap no-undo get.  protected set.
  define public property  LK_RECEIPT_Confirmed as class propmap no-undo get.  protected set.
  define public property  LK_RECEIPT_Error as class propmap no-undo get.  protected set.    
  define public property  LK_RECEIPT_NewDelete as class propmap no-undo get.  protected set.
  define public property  LK_RECEIPT_SentDelete as class propmap no-undo get.  protected set.
  define public property  LK_RECEIPT_DeleteHand as class propmap no-undo get.  protected set.   
  define public property  LK_RECEIPT_ConfirmedHand as class propmap no-undo get.  protected set.   

  define public property  RequireFilling as class propmap no-undo get.  protected set.   

  constructor public th ():
    super().
    NewStatus            = crProp(0, "NewStatus", "Новый").
    ReceivedFromSupplier = crProp(1, "ReceivedFromSupplier", "Получен от поставщика").
    VerificationPassed   = crProp(2, "VerificationPassed", "Пройдена проверка МОТП").
    RequiresAdjustment   = crProp(3, "RequiresAdjustment", "Требует корректировки").  /* Это групповой статус для ошибок. в УПД ставить детализированный. см. ниже */
    AwaitingDelivery     = crProp(4, "AwaitingDelivery", "Ожидает поставку").
    SignatureRequired    = crProp(5, "SignatureRequired", "Требует подписания").
    AwaitingConfirmation = crProp(6, "AwaitingConfirmation", "Ожидает подтверждения МОТП").
    CorrectionRequested  = crProp(7, "CorrectionRequested", "Запрошена корректировка").
    Confirmed            = crProp(8, "Confirmed", "Подтвержден").
    CancellationRequest  = crProp(9, "CancellationRequest", "Запрос аннуляции").
    Canceled             = crProp(10, "Canceled", "Аннулирован").
    Rejection            = crProp(11, "Rejection", "Отказ").
    LackOfMarkingCodesInCirculation = crProp(31, "LackOfMarkingCodesInCirculation", "Отсутствие КМ в обороте").
    DeliveryCodeMismatch = crProp(32, "DeliveryCodeMismatch", "Частичная приемка").
    InconsistencyWithSupplyContract = crProp(33, "InconsistencyWithTheSupplyContract", "Несоответсвие договору поставки ").
    LinesInError         = crProp(38, "LinesInError", "Нет строк для приема").
    LoadError            = crProp(34, "LoadError", "Ошибка загрузки ").
    edocError            = crProp(35, "edocError", "Ошибка").
    RejectionUtd         = crProp(36, "RejectionUtd", "Отказать").
    ConfirmedUcd         = crProp(37, "ConfirmedUcd", "Подтвердить").
    
    /* Статусы для Вывода из Оборота */
    LK_RECEIPT_New       = crProp(50, "LK_RECEIPT_New", "Требует подписания").
    LK_RECEIPT_Signed    = crProp(51, "LK_RECEIPT_Signed", "Подписан и ожидает отправки в ГИС МТ").
    LK_RECEIPT_Sent      = crProp(52, "LK_RECEIPT_Sent", "Отправлен и ожидает обработки ГИС МТ").
    LK_RECEIPT_Confirmed = crProp(53, "LK_RECEIPT_Confirmed", "Успешно обработан ГИС МТ").
    LK_RECEIPT_Error     = crProp(54, "LK_RECEIPT_Error", "Обработан ГИС МТ с ошибкой").
    LK_RECEIPT_NewDelete = crProp(55, "LK_RECEIPT_NewDelete", "Удален до отправки в ГИС МТ").
    LK_RECEIPT_SentDelete = crProp(56, "LK_RECEIPT_SentDelete", "Удален после отправки в ГИС МТ").
    LK_RECEIPT_DeleteHand = crProp(57, "LK_RECEIPT_DeleteHand", "Удален в ГИС МТ вручную").
    LK_RECEIPT_ConfirmedHand = crProp(58, "LK_RECEIPT_ConfirmedHand", "Обработан в ГИС МТ вручную").
    
    RequireFilling        = crProp(60, "RequireFilling","Требует заполнения").
    
  end.

  
  method public logical CheckStsErr(inKey as int):
    
    if RequiresAdjustment:KeyIntDB = inKey 
      or LackOfMarkingCodesInCirculation:KeyIntDB = inKey 
      or DeliveryCodeMismatch:KeyIntDB = inKey 
      or InconsistencyWithSupplyContract:KeyIntDB = inKey
      or LoadError:KeyIntDB = inKey
      then return true.
      else return false.

  end method.

end class.
