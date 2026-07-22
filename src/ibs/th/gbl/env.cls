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
using ibs.th.gbl.env.utd.
using ibs.th.gbl.env.marking.
using ibs.th.gbl.sys.env.ini.
using ibs.th.gbl.env.conf.
using ibs.th.gbl.env.prmtrs.section.
block-level on error undo, throw.


class ibs.th.gbl.env inherits objth: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Сущности системы" get.
   
  define property Utd as class utd no-undo
    get.
    private set. 
    
  define property Marking as class marking no-undo
    get.
    private set.

  /* define property Conf as class conf no-undo
    get.
    private set.
из-за говно реализации клас оказался пустой 
*/
  define property ParametrsOfSection as class section no-undo
    get.
    private set.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  constructor public env (  ):
    super ().
    {utl\objreg.i Utd utd}.
    {utl\objreg.i Marking marking}
/*    {utl\objreg.i Conf conf }*/
    {utl\objreg.i ParametrsOfSection section }.
  end constructor.

end class.