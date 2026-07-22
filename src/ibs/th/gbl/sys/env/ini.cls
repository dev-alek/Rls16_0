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
using ibs.th.gbl.sys.env.ini.section.val.
block-level on error undo, throw.
class ibs.th.gbl.sys.env.ini  inherits objth: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Ключи INI файла" get.
 
  define public property SystemLogFileName as val no-undo 
    get.
    private set. 

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
    
  constructor public ini (  ):
    super ().
    SystemLogFileName = getKeyValue("SystemTH", "SysLogFileName", "systh.log").
    
  end constructor.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  def var mval as class val no-undo.

  method private class val getKeyValue(inSecName as char, inKeyName as char, inValueDefault as char):
    def var value_ as character no-undo.
    def var val as class val no-undo.
    get-key-value
      section inSecName
      key inKeyName
      value value_.
    {utl\objreg.i val  val}.
    mval = val.
    assign
      val:SectionName = inSecName
      val:KeyName = inKeyName
      val:Value_ = (if value_ = ? then inValueDefault else value_)
    .
    return val.

  end method.
  
  



end class.