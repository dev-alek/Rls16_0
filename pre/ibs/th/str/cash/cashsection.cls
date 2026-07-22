using Progress.Lang.*.
using ibs.th.gbl.propmap.
using ibs.th.gbl.TypeMap.
block-level on error undo, throw.
class ibs.th.str.cash.CashSection inherits TypeMap:
   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Справочник типов параметров" get.
  define public property Param_          as class propmap no-undo get.
    protected set.
  define public property KeyBoard            as class propmap no-undo get.
    protected set.
  constructor public CashSection ():
    super().
    crProp(1,  "Param_",               "Параметры").
    crProp(2,  "KeyBoard",               "Клавиатура").
  end.
end class.
