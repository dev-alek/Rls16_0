using Progress.Lang.*.
using ibs.th.gbl.sys.objth.
using ibs.th.gbl.propmap.
using ibs.th.gbl.map.mapstring.
using ibs.th.gbl.TypeMap.
block-level on error undo, throw.
class ibs.th.str.utd.edoctype inherits TypeMap:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Типы элекронных документов" get.
  define public property  UTD  as class propmap no-undo get.  protected set.
  define public property  Introduce   as class propmap no-undo get.  protected set.
  define public property  Receipt  as class propmap no-undo get.  protected set.
  define public property  UCD  as class propmap no-undo get.  protected set.
  define public property  returns  as class propmap no-undo get.  protected set.
  define public property  AKT  as class propmap no-undo get.  protected set.
  define public property  EDoc         as class propmap no-undo get.  protected set.
  define public property  LK_RECEIPT   as class propmap no-undo get.  protected set.
  define public property  Mark_Collect as class propmap no-undo get.  protected set.
  constructor public edoctype ():
    super().
    UTD       = crProp(1, "UTD", "УПД").
    Introduce = crProp(2, "Introduce", "Первоначальный ввод КМ").
    Receipt   = crProp(3, "receipt", "Списание (выбытие из оборота)").
    UCD       = crProp(4, "UСD", "УКД").
    Returns   = crProp(5, "return", "Возврат поставщику").
    AKT       = crProp(6, "akt", "Акт приема").
    EDoc      = crProp(7, "EDoc", "еУПД").
    LK_RECEIPT = crProp(9, "LK_RECEIPT", "Вывод из оборота").
    Mark_Collect = crProp(10, "Mark_Collect", "Сбор марок").
  end.
end class.
