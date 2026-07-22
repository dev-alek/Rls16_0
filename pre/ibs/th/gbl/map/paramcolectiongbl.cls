using Progress.Lang.*.
using ibs.th.gbl.sys.objth.
block-level on error undo, throw.
class ibs.th.gbl.map.ParamColectionGbl inherits objth:
   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
   define override public property vss-author      as character no-undo init "$Author:$":U get.
   define override public property vss-date        as character no-undo init "$Date:$":U get.
   define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
   define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define override public property vss-description as character no-undo init "Колекция параметров и значений" get.
    define temp-table tt-param no-undo
    field objNum  as integer
    field Code_    as character
    field value_   as character
    index objcode objNum code_
  .
  define variable vObjNum as integer no-undo.
  method public int GetNextObjNum ():
     vObjNum= vObjNum + 1.
     return vObjNum.
  end.
  method public character getValue(iNumObj as integer, iParam as char):
    define buffer tt-param for tt-param.
    find first tt-param where tt-param.objNum  eq iNumObj
                          and tt-param.Code_   eq iParam
    no-error.
    return if available tt-param then tt-param.value_ else ?.
  end method.
  method public void setParam(iNumObj as integer, iParam as char, iValue as char):
    define buffer tt-param for tt-param.
    find first tt-param where tt-param.objNum  eq iNumObj
                          and tt-param.Code_   eq iParam
    no-error.
    if not available tt-param
    then do:
       create tt-param.
       assign
          tt-param.objNum  = iNumObj
          tt-param.code_   = iParam
       .
    end.
    tt-param.value_ = iValue.
  end method.
  method public void delParam(iNumObj as integer, iParam as char):
    define buffer tt-param for tt-param.
    find first tt-param where tt-param.objNum  eq iNumObj
                          and tt-param.Code_   eq iParam
    no-error.
    if available tt-param
    then do:
       delete tt-param.
    end.
  end method.
  method public void delParams(iNumObj as integer):
    define buffer tt-param for tt-param.
    repeat preselect each tt-param where tt-param.ObjNum eq iNumObj:
       find next tt-param.
         delete tt-param.
    end.
  end method.
   constructor public ParamColectionGbl (  ):
      super ().
   end constructor.
end class.
