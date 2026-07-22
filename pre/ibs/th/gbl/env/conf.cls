using Progress.Lang.*.
using ibs.th.gbl.env.conf.markingtype.
using ibs.th.gbl.sys.objth.
block-level on error undo, throw.
class ibs.th.gbl.env.conf inherits objth:
    define override public property vss-revision    as character no-undo init "$Revision:$":U get .
    define override public property vss-author      as character no-undo init "$Author:$":U get.
    define override public property vss-date        as character no-undo init "$Date:$":U get.
    define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
    define override public property vss-archive     as character no-undo init "$Archive:$":U get.
    define override public property vss-description as character no-undo init "Вроде клас конфигво, а вроде он пустой " get.
  constructor public conf (  ):
  end constructor.
end class.
