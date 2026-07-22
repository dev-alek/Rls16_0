 
 /*------------------------------------------------------------------------
    File        : SystemAux
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Daru
    Created     : Sat Dec 30 13:01:24 MSK 2023
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.gbl.sys.objth.
using ibs.th.gbl.map.*.
using ibs.th.gbl.env.conf.markingtypegbl.
block-level on error undo, throw.

class ibs.th.gbl.sys.SystemAux inherits objth: 

  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Класс для хранения вспомогательных классов системы" get.
 
   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   define property MapStringGbl as class mapstringgbl no-undo
    get.
    private set.
    
   define property MarkingTypeGbl as class MarkingTypeGbl no-undo
    get.
    private set.    
   define property ParamColectionGbl as class ParamColectionGbl no-undo
    get.
    private set.    
   
   constructor public SystemAux (  ):
      super ().
      {utl\objreg.i MapStringGbl MapStringGbl}
      {utl\objreg.i MarkingTypeGbl MarkingTypeGbl}
      {utl\objreg.i ParamColectionGbl ParamColectionGbl}
   end constructor.

end class.