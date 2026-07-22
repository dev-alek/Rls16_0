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
block-level on error undo, throw.

class ibs.th.gbl.sys.env.ini.section.val inherits ibs.th.gbl.sys.objth:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Параметр по секциям" get.
   

  define public property SectionName as character no-undo
    get.
    set.
  
  define public property KeyName as character no-undo
    get.
    set.

  define public property Value_ as character no-undo
    get.
    set.

end class.