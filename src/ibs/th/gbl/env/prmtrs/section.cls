/*
  $Revision:$
  $Author:$
  $Date:$
  $Workfile:$
  $Archive:$
  
  Автор: Рубан Дмитрий Андреевич 
  Дата создания: 9 янв. 2023 г.
  Author:  Ruban Dmitriy Andreevich
  Creation date: 9 янв. 2023 г.
  
  */

using Progress.Lang.*.
using ibs.th.gbl.env.prmtrs.edo.
using ibs.th.gbl.sys.objth.


class ibs.th.gbl.env.prmtrs.section inherits objth:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Параметры по секциям" get.
    
  
  define public variable edo as class edo no-undo.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method public class edo GetSectionEDO(pObjType as char, pObjCode as int):
    def var vMarkingType as character no-undo.
    def var vIsEDO as logical no-undo.
    def var vIsEDODiadok as logical no-undo.
    def var vIsManual as logical no-undo.
    def var vIsBanRecipes as logical no-undo.
    def var vIsBanAltr as logical no-undo.
    def var vIsBarCode as logical no-undo.
    if valid-object (edo) and edo:ObjType = pObjType and edo:ObjCode = pObjCode
    then do:
      return edo.
    end.
    delete object edo no-error.
    {utl\objreg.i edo edo pObjType pObjCode}    
    return edo.
  end method.
  
end class.