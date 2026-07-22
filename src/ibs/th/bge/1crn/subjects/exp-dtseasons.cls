 
 /*------------------------------------------------------------------------
    File        : techlosses
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Ленкин
    Created     : Wed Jul 24 19:29:55 MSK 2024
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.bge.1crn.export.send1cerpsub.

block-level on error undo, throw.

class ibs.th.bge.1crn.subjects.exp-DTSeasons inherits send1cerpsub: 

  define override public property InitSecTag as character no-undo init "DT-Seasons"
  get.
   

  define override public property vss-archive as character no-undo 
  get.
   

  define override public property vss-author as character no-undo 
  get.
   

  define override public property vss-date as character no-undo 
  get.
   

  define override public property vss-description as character no-undo 
  get.
   

  define override public property vss-revision as character no-undo 
  get.
   

  define override public property vss-workfile as character no-undo 
  get.
  
  define override public property sendTableName as character no-undo init "gds-obj-attr"
  get.
   
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
    
  constructor public exp-DTSeasons (  ):
    super ().

  end constructor.

  method override public void CheckParam(  ):
/*      if not valid-handle (oldbh)                               */
/*      then                                                      */
/*         return error "Не передан старый буфер".                */
/*      if oldbh:table ne "trn-doc"                               */
/*      then                                                      */
/*         return error "Старый буфер не trn-doc: " + oldbh:table.*/
/*      return.                                                   */

  end method.

  method override public void CrContentToSW( input hSaxWriter as handle ):
    define variable gdsCode like ub.gds-obj-attr.gds-code no-undo.
    define buffer buf_code         for ub.code .
    define buffer buf_goods-attr   for ub.goods-attr .
    define buffer buf_gds-obj-attr for ub.gds-obj-attr .
    define buffer time_gds-obj-attr for ub.gds-obj-attr .
  
    /* проверка на глобальный атрибут у товара */
    find first buf_gds-obj-attr no-lock where buf_gds-obj-attr.gds-code = integer(oldbh:buffer-field( "gds-code":U  ):buffer-value) and
      buf_gds-obj-attr.attr-code = "dt-seasons" and buf_gds-obj-attr.obj-code = integer(oldbh:buffer-field( "obj-code":U  ):buffer-value) and
      buf_gds-obj-attr.obj-type = oldbh:buffer-field( "obj-type":U  ):buffer-value no-error .
    if available (buf_gds-obj-attr) then 
    do:
      sendOldRowid = rowid(buf_gds-obj-attr).
      find first buf_goods-attr no-lock where buf_goods-attr.gds-code = buf_gds-obj-attr.gds-code and
        buf_goods-attr.attr-code = "fuel-type" no-error .
      find first buf_code no-lock where buf_code.parent = "DTseasons" and buf_code.code = buf_gds-obj-attr.attr-value no-error .
      if available (buf_goods-attr) and available (buf_code) then 
      do:
    find first time_gds-obj-attr exclusive-lock where time_gds-obj-attr.attr-code = "change-dt-seasons" and 
    time_gds-obj-attr.gds-code = buf_gds-obj-attr.gds-code and 
    time_gds-obj-attr.obj-code = buf_gds-obj-attr.obj-code and 
    time_gds-obj-attr.obj-type = buf_gds-obj-attr.obj-type no-error .
    define variable time-change as character no-undo .
    if available (time_gds-obj-attr) then
    time-change = time_gds-obj-attr.attr-value.
    else time-change = entry(1,iso-date(now),"+") .

        hSaxWriter:start-element ("DT-Season") .
        hSaxWriter:write-data-element (  "code":U,     string(buf_goods-attr.gds-code)   ).
/*        hSaxWriter:write-data-element (  "chk-name":U, string(buf_code.CodeName)  ).                                 */
/*        hSaxWriter:write-data-element (  "alt-name":U, if buf_code.misc1 = ? then "" else string(buf_code.misc1)   ).*/
/*        hSaxWriter:write-data-element (  "nds-code":U,       string(buf_code.misc2)).                                */
/*        hSaxWriter:write-data-element (  "unit-code":U,       string(buf_code.misc3)   ).                            */
        hSaxWriter:write-data-element (  "seasons":U,       string(buf_code.code)   ).
        hSaxWriter:write-data-element (  "time-change":U,       time-change   ).
        hSaxWriter:end-element ("DT-Season") .       
        
      end.             
    end.
  end method.

  destructor public exp-DTSeasons ( ):

  end destructor.

end class.