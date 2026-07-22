/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Структура данных countries из 1С ERPRN

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
block-level on error undo, throw.

class ibs.th.bge.1crn.subjects.emc inherits ibs.th.bge.1crn.subjects.code:
    define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get. 
  { cmp/str-glbl.i class } 
  
  
    
  define override property InitTag as character no-undo init "EMC"
    get. 
  method private date date-mth (inValue as character):
    
    inValue = entry (1, inValue, "T").
    return date (integer (entry (2, Invalue, "-")), integer (entry (3, Invalue, "-")), integer (entry (1, Invalue, "-")) ). 
    
  end.
  
  &scoped-define attr-str      if inValue >= "" then inValue else ""
  &scoped-define attr-integer  if inValue >= "" then integer (inValue) else 0
  &scoped-define attr-dec      if inValue >= "" then decimal (inValue) else 0.0
  &scoped-define attr-date     if inValue >= "" then date-mth (inValue) else ?
  define var emctype-code as integer no-undo.  
  method override protected void SetPropProtected (inTag as char, inValue as char):
    super:SetPropProtected(inTag, inValue).
    case inTag:
      when "emc-start-date" then do:
          assign code_ = {&attr-str}
                 misc1 = string({&attr-date},"99/99/9999")
                 old_code_ = code_
          .
      end.
      when "del-l" then do:
         assign del-f = {&attr-integer}. /* Будем удалять записи всегда таккак 1с мудаки переносят дату при деактивации на какуюто одну и туже дату */
      end.
      when "emc-name" then do:
        assign CodeName = {&attr-str} .
      end.
      when "emc-value" then do:
        assign CodeValue = {&attr-str} .
      end.
      when "emctype-code" then do:
        assign emctype-code = {&attr-integer}
               parent_      = "emc" + {&delim-par} + string(emctype-code,"999")
               old_parent_  = parent_
         .
      end.

    end case.
  end.

  method override protected void CheckData ():

    def var v-str as char no-undo.
    define buffer code for ub.Code.
    assign
      v-str = "emc-start-date" when code_ = ?
      v-str = v-str + ",emc-value" when CodeValue = ?
      v-str = v-str + ",emctype-code" when parent_ = ?
    . 
    v-str = trim (v-str, ",").
    if v-str > ''
    then 
      undo, throw new Progress.Lang.AppError( substitute ("Теги &1 не могут иметь неопределное значение", v-str)).
    block-code:      
    for each code where Code.parent    begins "emc" 
                    and Code.CodeName  eq CodeName
    no-lock:
       assign
          old_parent_ = Code.parent
          old_code_   = Code.code
       .
       leave block-code.
    end.
    if    code_   ne old_code_
       or parent_ ne old_parent_
    then do:
       find first code where Code.parent eq parent_
                         and Code.code   eq code_
       no-lock no-error.
       if available code
       then
          undo, throw new Progress.Lang.AppError( substitute("Уже есть запись emctype-code = &1 на дату &2",emctype-code, code_)).
    
    end.
  end.

 

  
end class.