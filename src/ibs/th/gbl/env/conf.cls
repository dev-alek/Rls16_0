/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 16 мая 2022 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 16 мая 2022 г.

*/

using Progress.Lang.*.
using ibs.th.gbl.env.conf.markingtype.
using ibs.th.gbl.sys.objth.
block-level on error undo, throw.

class ibs.th.gbl.env.conf inherits objth:
    define override public property vss-revision    as character no-undo init "$Revision:$":U get .
    define override public property vss-author      as character no-undo init "$Author:$":U get.
    define override public property vss-date        as character no-undo init "$Date:$":U get.
    define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
    define override public property vss-archive     as character no-undo init "$Archive:$":U get.
    define override public property vss-description as character no-undo init "Вроде клас конфигво, а вроде он пустой " get.
   
 /* define public property IsMarking as class markingtype no-undo 
    get.
    private set.
*/
  /*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
    
  constructor public conf (  ):
    
    /* Идея хорошая, а реализация говно
    define variable v-par-val  as character no-undo .
    define variable v-par-type as character no-undo .
    
    run gbl/conf-rd.p ("is-mark":U, "":U, "":U, 0, "":U, "":U, "":U, no, output v-par-val, output v-par-type) no-error.
    {utl\objreg.i IsMarking markingtype v-par-val}    
    */
  end constructor.

end class.