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
using ibs.th.gbl.sys.objsrv.
block-level on error undo, throw.


class ibs.th.gbl.sys.objth abstract: 
  
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  
  { gbl/objsrv.i def}
  define abstract property vss-revision    as character no-undo get.
  define abstract property vss-author      as character no-undo get.
  define abstract property vss-date        as character no-undo get.
  define abstract property vss-workfile    as character no-undo get.
  define abstract property vss-archive     as character no-undo get.
  define abstract property vss-description as character no-undo get.
  
  
  method final void vss-get-info (
     output o-vss-revision    as character,
     output o-vss-author      as character,
     output o-vss-date        as character,
     output o-vss-workfile    as character,
     output o-vss-archive     as character,
     output o-vss-description as character
):     
     assign
       o-vss-revision    = vss-revision
       o-vss-author      = vss-author
       o-vss-date        = vss-date
       o-vss-workfile    = vss-workfile
       o-vss-archive     = vss-archive
       o-vss-description = vss-description
     .
   end. /* vss-get-info */
   
   method public char getLable():
      return vss-description.
   end.
   
  
  constructor protected objth ():
    getobjserv().
    if valid-object (ObjSrv)
      then ObjSrv:Regobj(this-object).
  end constructor.

  destructor public objth (  ):
    getobjserv().
    if valid-object (ObjSrv)
      then ObjSrv:Delobj(this-object).
  end destructor.

  method public void getobjserv():
    { gbl/objsrv.i get}
  end method.
  
  method public logical RefrashObject():
  end method.

end class.