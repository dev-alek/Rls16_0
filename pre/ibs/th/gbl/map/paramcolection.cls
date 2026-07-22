using Progress.Lang.*.
using ibs.th.gbl.sys.objth.
using ibs.th.gbl.map.*.
block-level on error undo, throw.
class ibs.th.gbl.map.ParamColection inherits objth:
   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
   define override public property vss-author      as character no-undo init "$Author:$":U get.
   define override public property vss-date        as character no-undo init "$Date:$":U get.
   define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
   define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define override public property vss-description as character no-undo init "Колекция параметров и значений" get.
   define variable vObjNum as integer no-undo.
   define variable ParamColectionGbl as ParamColectionGbl no-undo.
   constructor public ParamColection (  ):
      super ().
      ParamColectionGbl = objSrv:SystemAux:ParamColectionGbl.
      vObjNum = ParamColectionGbl:GetNextObjNum().
   end constructor.
   destructor public ParamColection ( ):
      delParams().
   end destructor.
   method public character getValue(iParam as char):
      return ParamColectionGbl:getValue(vObjNum, iParam).
   end method.
   method public void setParam(iParam as char, iValue as char):
      ParamColectionGbl:setParam(vObjNum, iParam, iValue).
   end method.
   method public void delParam(iParam as char):
      ParamColectionGbl:delParam(vObjNum, iParam).
   end method.
   method public void delParams():
      ParamColectionGbl:delParams(vObjNum).
   end method.
end class.
