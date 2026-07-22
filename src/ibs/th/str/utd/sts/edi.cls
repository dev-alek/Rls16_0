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

class ibs.th.str.utd.sts.edi inherits TypeMap:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Статусы ЭДО на основе статусов Диадок" get.
     
    define public property HaveToCreateReceipt as class propmap no-undo get. 
    protected set.
  
  
    define public property RevocationIsRequestedByMe as class propmap no-undo get. 
    protected set.
    define public property RequestsMyRevocation  as class propmap no-undo get. 
    protected set.
    define public property RevocationAccepted  as class propmap no-undo get. 
    protected set.
    define public property UnknownRevocationStatus  as class propmap no-undo get. 
    protected set.
    
    define public property RecipientResponseStatusUnknown  as class propmap no-undo get. 
    protected set.
    define public property RecipientResponseStatusNotAccep  as class propmap no-undo get. 
    protected set.
    define public property WaitingForRecipientSignature  as class propmap no-undo get. 
    protected set.
    define public property WithRecipientSignature  as class propmap no-undo get. 
    protected set.
    define public property WithRecipientPartiallySignature  as class propmap no-undo get. 
    protected set.
    define public property RecipientSignatureRequestReject  as class propmap no-undo get. 
    protected set.
    define public property InvalidRecipientSignature as class propmap no-undo get. 
    protected set.
   
    define public property AutoRejected as class propmap no-undo get. 
    protected set.
    define public property SignatureAdjustment as class propmap no-undo get. 
    protected set.
    
    define public property Verification as class propmap no-undo get. 
    protected set.
    define public property Changed as class propmap no-undo get. 
    protected set.
    
    define public property sendRejected as class propmap no-undo get. 
    protected set.
    
    define public property sendRecipient  as class propmap no-undo get. 
    protected set.
    
    define public property sendRevocation as class propmap no-undo get. 
    protected set.
    
    define public property sendAdjustment as class propmap no-undo get. 
    protected set.
    
    define public property StatFinesh as integer init 300 
    get. 
    set.
     
    define public property StatChangLoanOnlyBeg as integer init 200 
    get. 
    set.
    
    define public property StatChangLoanOnlyEnd as integer init 299 
    get. 
    set.
    define public property AvailAdjustment as class propmap no-undo get. 
    protected set.
    define public property SignatureNotAccepted as class propmap no-undo get. 
    protected set.
    
    define public property SendAutoRejected as class propmap no-undo get. 
    protected set.
    
    define public property SignatureAutoRejected as class propmap no-undo get. 
    protected set.
    
    
                        
   constructor public edi ():
     super().
    HaveToCreateReceipt = crProp(11,"HaveToCreateReceipt","Подписать ИОП").

    RequestsMyRevocation      = crProp(32,"RequestsMyRevocation","Подписать аннуляцию").
    RevocationIsRequestedByMe = crProp(131,"RevocationIsRequestedByMe","Запрошена аннуляция").
    UnknownRevocationStatus   = crProp(134,"UnknownRevocationStatus","Неизвестный анул.").
    RevocationAccepted	      = crProp(333,"RevocationAccepted","Аннулирован").
    
    WaitingForRecipientSignature         = crProp(53,"WaitingForRecipientSignature","Подписать").
    RecipientResponseStatusUnknown       = crProp(151,"RecipientResponseStatusUnknown","Неизвестный").
    InvalidRecipientSignature            = crProp(156,"InvalidRecipientSignature","Ош. подписи").
    RecipientResponseStatusNotAccep      = crProp(352,"RecipientResponseStatusNotAcceptable","Не требуется").
    WithRecipientSignature               = crProp(354,"WithRecipientSignature","Подписан").
    WithRecipientPartiallySignature      = crProp(356,"WithRecipientPartiallySignature","Принято с разногласиями").
    RecipientSignatureRequestReject      = crProp(355,"RecipientSignatureRequestRejected","Отказ").
    
    
    
    AutoRejected                         = crProp(71,"AutoRejected","Подписать отказ").
    SignatureAdjustment                  = crProp(72,"SignatureAdjustment","Подписать корректировку").
    SignatureNotAccepted                 = crProp(73,"SignatureNotAccepted","Подписать с отказом").
    
    Verification                         = crProp(173,"Verification","Проверка").    
    sendRejected                         = crProp(274,"sendRejected","Отправлен отказ").
    sendRecipient                        = crProp(275,"sendRecipient","Отправлена подпись").
    sendRevocation                       = crProp(276,"sendRevocation","Отправлена ответ на аннуляцию").
    sendAdjustment                       = crProp(277,"sendAdjustment","Отправлена корректировка").
    sendAutoRejected                     = crProp(278,"sendAutoRejected","Отправлен отказ авт.").
    
    SignatureAutoRejected                = crProp(379,"SignatureAutoRejected","Отказ авт.").
    Changed                              = crProp(374,"Changed","Изменен").
    AvailAdjustment                      = crProp(378,"AvailAdjustment","По документу нельзя запросить корректировку").
  end.



end class.
