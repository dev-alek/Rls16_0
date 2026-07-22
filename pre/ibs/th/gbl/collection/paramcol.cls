using Progress.Lang.*.
using Ibs.Th.Gbl.TypeMap.
using ibs.th.gbl.propmap.
block-level on error undo, throw.
class ibs.th.gbl.collection.paramCol inherits TypeMap:
     define override public property vss-revision    as character no-undo init "$Revision:$":U get .
     define override public property vss-author      as character no-undo init "$Author:$":U get.
     define override public property vss-date        as character no-undo init "$Date:$":U get.
     define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
     define override public property vss-archive     as character no-undo init "$Archive:$":U get.
     define override public property vss-description as character no-undo init "Коллекция параметров" get.
   constructor public paramCol (  ):
      super ().
      Unknow:Label_ = ?.
   end constructor.
   destructor public paramCol ( ):
   end destructor.
   define variable countParam as integer no-undo.
   method public void setParam(iName as character, iValue as char):
      define variable vParam as class propmap no-undo.
      vparam = GetProp(iName).
      if vParam eq Unknow
      then do:
         countParam = countParam + 1.
         crProp(countParam, iName, iValue).
      end.
      else
         vParam:Label_ = iValue.
   end.
   method public character getParamValue (iName as char):
      return GetLabel(iName).
   end.
   method public character getParams(  ):
      define variable VStr as character no-undo.
      define variable vI as integer no-undo.
      do vi = 1 to mapType:GetItemByLab(vi):
         VStr = VStr + ', ' + CurrProp:NameProp + ': "' + CurrProp:Label_ + '"' .
      end.
      return substitute ("Params : ~{&1}",substring (vstr,3)).
   end.
end class.
