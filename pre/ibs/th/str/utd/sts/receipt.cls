using Progress.Lang.*.
using ibs.th.gbl.propmap.
using ibs.th.gbl.map.mapstring.
using ibs.th.gbl.sys.objth.
using ibs.th.gbl.TypeMap.
block-level on error undo, throw.
class ibs.th.str.utd.sts.receipt inherits TypeMap:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Статусы документов выбытия" get.
  define public property GeneralReceiptStsNotAcceptable as class propmap no-undo get.
    protected set.
  define public property HaveToCreateReceipt as class propmap no-undo get.
    protected set.
  define public property WaitingForReceipt  as class propmap no-undo get.
    protected set.
  define public property Finished  as class propmap no-undo get.
    protected set.
  constructor public receipt ():
    super().
    GeneralReceiptStsNotAcceptable  = crProp("GeneralReceiptStsNotAcceptable", "ИОП на документ не запрошен").
    HaveToCreateReceipt  = crProp("HaveToCreateReceipt", "нужно подписать ИОП на документ").
    WaitingForReceipt  = crProp("WaitingForReceipt", "ожидание подписания ИОПа на документ").
    Finished  = crProp("Finished", "ИОП подписано. Действий не требуется").
  end.
end class.
