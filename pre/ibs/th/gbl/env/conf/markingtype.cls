using Progress.Lang.*.
using ibs.th.gbl.sys.objth.
using ibs.th.gbl.env.conf.markingtypegbl.
class ibs.th.gbl.env.conf.markingtype inherits objth.
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Настрока для типов маркировки" get.
  define variable MarkingTypeGbl as MarkingTypeGbl no-undo.
  define variable vObjNum as integer no-undo.
  constructor public markingtype ( conf_val as char ):
    super().
    MarkingTypeGbl = objsrv:SystemAux:MarkingTypeGbl.
    vObjNum = MarkingTypeGbl:GetNextObjNum().
    reLoadItems(conf_val).
  end constructor.
  method public logical AvialItem(arg as char):
    return MarkingTypeGbl:AvialItem(vObjNum, arg).
  end method.
  method public void AddItem( arg as char):
     MarkingTypeGbl:AddItem(vObjNum, arg).
  end method.
  method public void delItem(arg as char):
     MarkingTypeGbl:delItem(vObjNum, arg).
  end method.
  method public void delItems():
     MarkingTypeGbl:delItems(vObjNum).
  end method.
  method public void reLoadItems(arg as char):
     define variable vi as integer no-undo.
     delItems().
     do vi = 1 to num-entries (arg):
       AddItem( entry (vi,arg)).
    end.
  end method.
  method public logical GetValForType(arg as char):
    return AvialItem(arg).
  end method.
        destructor public markingtype ( ):
      delItems().
        end destructor.
end class.
