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
using ibs.th.str.utd.sts.
using ibs.th.str.utd.edoctype.
block-level on error undo, throw.

class ibs.th.gbl.env.utd inherits objth:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Электронные документы" get.
  
  define public property Sts as class sts no-undo 
    get.
    set.

  define public property EDocType as class edoctype no-undo 
    get.
    set.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
    
  constructor public utd (  ):
    super ().
    {utl\objreg.i Sts sts }
    {utl\objreg.i EDocType edoctype }
    
  end constructor.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
/*  destructor public utd ( ):*/
/*    if valid-object (EDI)    */
/*      then delete object EDI.*/
/*    if valid-object (TH)     */
/*      then delete object TH. */
/*  end destructor.*/

end class.