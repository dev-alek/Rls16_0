using Progress.Lang.*.
using ibs.th.gbl.propmap.
using ibs.th.gbl.TypeMap.
block-level on error undo, throw.
class ibs.th.str.cash.CashDevice inherits TypeMap:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Справлочник типов касс" get.
   define public property Standard          as class propmap no-undo get. protected set.
   define public property TCOAGC            as class propmap no-undo get. protected set.
   define public property Mobile            as class propmap no-undo get. protected set.
   define public property GrafCash          as class propmap no-undo get. protected set.
   define public property Tanker            as class propmap no-undo get. protected set.
   define public property TankerIntegr      as class propmap no-undo get. protected set.
   constructor public CashDevice ():
      super().
      Standard     = crProp(0,  "Standard",             "Стандартная касса").
      Tanker       = crProp(1,  "Tanker",               "Autotank стандартный").
      TCOAGC       = crProp(2,  "TCOAGC",               "ТСО Auto GC").
      Mobile       = crProp(3,  "Mobile",               "Мобильное приложение").
      GrafCash     = crProp(4,  "GrafCash",             "Графическая касса").
      TankerIntegr = crProp(5,  "TankerIntegr",         "Autotank интегрированный").
   end.
end class.
