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
using ibs.th.gbl.sys.objth.
using ibs.th.str.marking.sts.
using ibs.th.str.marking.types.
block-level on error undo, throw.

class ibs.th.gbl.env.marking inherits objth:
   define override public property vss-revision    as character no-undo init "$Revision:$":U get .
   define override public property vss-author      as character no-undo init "$Author:$":U get.
   define override public property vss-date        as character no-undo init "$Date:$":U get.
   define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
   define override public property vss-archive     as character no-undo init "$Archive:$":U get.
   define override public property vss-description as character no-undo init "Маркировка товаров" get.
     
  
  define public property Sts as class sts no-undo 
    get.
    set.
  define public property Types as class Types no-undo 
    get.
    set.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
    
  constructor public marking (  ):
    super ().
    {utl\objreg.i Sts sts }
    {utl\objreg.i Types Types  }
  end constructor.

  METHOD OVERRIDE PUBLIC LOGICAL RefrashObject(  ):
      if valid-object(Types) then
        delete object Types.
      {utl\objreg.i Types Types  }
  END METHOD.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
/*  destructor public marking ( ):*/
/*    if valid-object (EDI)    */
/*      then delete object EDI.*/
/*    if valid-object (TH)     */
/*      then delete object TH. */
/*  end destructor.*/

end class.