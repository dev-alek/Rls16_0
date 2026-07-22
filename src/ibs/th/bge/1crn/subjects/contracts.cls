
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Структура данных contracts в 1С

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
block-level on error undo, throw.


class ibs.th.bge.1crn.subjects.contracts inherits ibs.th.bge.1crn.subjects.asubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  
  define property code_       as character    no-undo get. 
    private set.
  define property del-l       as integer      no-undo get. 
    private set.
  define property del-f       as integer      no-undo get. 
    private set.
  define property status_     as integer    no-undo get. 
    private set.
  define property org-code    as character    no-undo get. 
    private set.
  define property contr-code  as character    no-undo get. 
    private set.
  define property date-srt    as character    no-undo get. 
    private set.
  define property date-end    as character    no-undo get. 
    private set.
  define property number      as character    no-undo get. 
    private set.
  define property date_       as character    no-undo get. 
    private set.    
  define property code-SCVD   as character    no-undo get. 
    private set.    
  define property edi_        as integer      no-undo get. 
    private set. 
  define property edi-orders   as integer    no-undo
    get. 
    private set.  
  define property return-code as integer      no-undo get. 
    private set.   
    
  define override property InitTag as character no-undo init "contract"
    get. 
    
  method OVERRIDE PROTECTED void SetPropProtected (inTag as char, inValue as char):
    case inTag:
      when "code" then 
        do:
          assign 
            code_ = inValue .
        end.
      when "del-l" then 
        do:
          assign 
            del-l = integer (inValue).
        end.
      when "del-f" then 
        do:
          assign 
            del-f = integer (inValue).
        end.
      when "status" then 
        do:
          assign 
            status_ = integer (inValue) .
        end.
      when "org-code" then 
        do:
          assign 
            org-code = inValue .
        end.
      when "contr-code" then 
        do:
          assign 
            contr-code = inValue .
        end.
      when "date-srt" then 
        do:
          assign 
            date-srt = inValue .
        end.
      when "date-end" then 
        do:
          assign 
            date-end = inValue .
        end.
      when "number" then 
        do:
          assign 
            number = inValue .
        end.
      when "date" then 
        do:
          assign 
            date_ = inValue .
        end.
      when "code-SCVD" then 
        do:
          assign 
            code-SCVD = inValue .
        end.
      when "edi" then 
        do:
          assign 
            edi_ = integer(inValue) .
        end.
      when "edi-orders"  then 
        edi-orders    = if inValue >= "" then int(inValue) else 0 .
      when "return-code" then 
        do:
          assign 
            return-code = integer(inValue) .
        end.
    end case.
  end.

  method override protected void CheckData ():

    def var v-str as char no-undo.
    
    assign
      v-str = "code" 
      when code_ = ?
      /*v-str = v-str + ",status" 
      when status_ = ?*/
      v-str = v-str + ",org-code" 
      when org-code = ?
      v-str = v-str + ",contr-code" 
      when contr-code = ?
      /*v-str = v-str + ",date-srt" 
      when date-srt = ?
      v-str = v-str + ",date-end" 
      when date-end = ?
      v-str = v-str + ",number" 
      when number = ?*/
      v-str = v-str + ",date" 
      when date_ = ?
      /* v-str = v-str + ",code-SCVD" 
      when code-SCVD = ?  */
      /*v-str = v-str + ",edi" 
      when edi_ = ?*/
      .
    v-str = trim (v-str, ",").
    if v-str > ''
      then 
      undo, throw new Progress.Lang.AppError( substitute ("Теги &1 не могут иметь неопределное значение", v-str)).

  end.

  method override protected void ClearSub():
    assign 
      code_      = ?
      del-l      = ?
      del-f      = ?
      status_    = ?
      org-code   = ?
      contr-code = ?
      date-srt   = ?
      date-end   = ?
      number     = ?
      date_      = ?
      code-SCVD  = ?
      edi_       = ?
      edi-orders = ?      
      return-code = ?
      .
  end.
  
end class.