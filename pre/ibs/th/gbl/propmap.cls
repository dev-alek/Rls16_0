using Progress.Lang.*.
using ibs.th.gbl.propmap.
using ibs.th.gbl.sys.objth.
using ibs.th.gbl.map.mapstring.
block-level on error undo, throw.
class ibs.th.gbl.propmap inherits objth:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Описание элементов справочника" get.
  define public property Label_ as character no-undo
    get.
    set.
  define public property NameProp as character no-undo
    get.
    set.
  define public property KeyIntDB as integer no-undo
    get.
    private set.
  define public property KeyInt as integer no-undo
    get.
    set(arg as integer ):
       KeyInt   = arg.
       KeyIntDB = arg.
    end.
  constructor public propmap (inNameProp as char, inLabel as char):
    super ().
    assign
      Label_   = inLabel
      NameProp = inNameProp
      .
  end constructor.
  constructor public propmap (iKeyInt as integer, inNameProp as char, inLabel as char):
    super ().
    assign
      Label_   = inLabel
      NameProp = inNameProp
      KeyInt   = iKeyInt
      .
  end constructor.
  destructor public propmap ( ):
  end destructor.
end class.
