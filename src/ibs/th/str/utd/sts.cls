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
using ibs.th.str.utd.sts.*.
using ibs.th.str.marking.sts.*.
using ibs.th.gbl.sys.objth.
block-level on error undo, throw.

class ibs.th.str.utd.sts inherits objth:
    define override public property vss-revision    as character no-undo init "$Revision:$":U get .
    define override public property vss-author      as character no-undo init "$Author:$":U get.
    define override public property vss-date        as character no-undo init "$Date:$":U get.
    define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
    define override public property vss-archive     as character no-undo init "$Archive:$":U get.
    define override public property vss-description as character no-undo init "Статусы электронных документов" get.
  
  define public property EDI as class edi no-undo 
    get.
    protected set. 

  define public property TH as class th no-undo 
    get.
    protected set.

  define public property Receipt as class receipt no-undo 
    get.
    protected set.
    
  define public property Direction as class direction no-undo 
    get.
    protected set.
    
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
    
  constructor public sts (  ):
    super ().
    {utl\objreg.i EDI edi}
    {utl\objreg.i TH th}
    {utl\objreg.i Receipt receipt}
    {utl\objreg.i Direction direction}
  end constructor.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
/*  destructor public sts ( ):*/
/*    if valid-object (EDI)    */
/*      then delete object EDI.*/
/*    if valid-object (TH)     */
/*      then delete object TH. */
/*  end destructor.*/

end class.