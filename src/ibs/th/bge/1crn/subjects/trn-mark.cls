/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Структура данных prts накладной из 1С ERPRN

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
block-level on error undo, throw.


class ibs.th.bge.1crn.subjects.trn-mark inherits ibs.th.bge.1crn.subjects.asubject: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  
  define property prt-id as character no-undo 
    get. 
    private set.
  define property in-doc-id as character no-undo 
    get. 
    private set.
  define property mark-code as character no-undo 
    get. 
    private set.
  define property gtin as character no-undo 
    get. 
    private set.
  define property gtin_qnt as integer no-undo 
    get. 
    private set.
  define property upd_id as character no-undo 
    get. 
    private set.
  define property gds-code as integer no-undo 
    get. 
    private set.
    
  define override property InitTag as character no-undo init "mark"
    get. 
    
  method override protected void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "prt-id" then do:
        assign prt-id = inValue.
      end.
      when "in-doc-id" then do:
        assign in-doc-id = inValue.
      end.
      when "mark-code" then do:
        assign mark-code = inValue.
      end.
      when "gtin" then do:
        assign gtin = inValue.
      end.
      when "gtin-qnt" then do:
        assign gtin_qnt = integer(inValue) no-error .
      end.
      when "upd-id" then do:
        assign upd_id = inValue.
      end.
      when "gds-code" then do:
        assign gds-code = integer(inValue) no-error .
      end.
    end case.
  end.

  method override protected void CheckData ():

    def var v-str as char no-undo.
    
/*    assign                                           */
/*      v-str = "prt-id" when prt-id = ?               */
/*      v-str = v-str + ",mark-code" when mark-code = ?*/
/*    .                                                */
    v-str = trim (v-str, ",").
    if v-str > ''
    then 
      undo, throw new Progress.Lang.AppError( substitute ("Теги &1 не могут иметь неопределное значение", v-str)).

  end.
  
  method override protected void ClearSub():
    assign 
      prt-id   = ?
      mark-code = ?
      gtin = ?
      gtin_qnt = ?
      upd_id = ?
      in-doc-id = ?
      gds-code = ?
    .
  end.

  
end class.