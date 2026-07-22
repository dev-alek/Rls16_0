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

class ibs.th.bge.1crn.subjects.dt-season inherits ibs.th.bge.1crn.subjects.code:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get. 
  { cmp/str-glbl.i class } 
  { cmp/library.i class}

  define override property InitTag as character no-undo init "DT-season"
    get. 

  &scoped-define attr-str      if inValue >= "" then inValue else ?
  &scoped-define attr-integer  if inValue >= "" then integer (inValue) else 0
  &scoped-define attr-dec      if inValue >= "" then decimal (inValue) else 0.0
  
  constructor public dt-season():
    if not valid-handle (ibs.th.gbl.gbl-hndllib:g#library)
      then run str/library.p persistent no-error .
  end constructor.
  
  method override protected void SetPropProtected (inTag as char, inValue as char):
    super:SetPropProtected(inTag, inValue).
    case inTag:
      when "code" then do:
          assign 
            code_ = {&attr-str}
            parent_ = "DTSeasons"
            old_code_ = {&attr-str}
            old_parent_ = "DTSeasons"          .
      end.
      when "del-l" then do:
         assign status_ = {&attr-integer}.
      end.
      when "del-f" then do:
         assign del-f = {&attr-integer}.
      end.
      when "chk-name" then do:
        assign CodeName = {&attr-str} .
      end.
      when "alt-name" then do:
        assign misc1 = {&attr-str} .
      end.
      when "nds-code" then do:
        assign misc2 = {&attr-str} .
      end.
      when "unit-code" then do:
        assign misc3 = {&attr-str} .
      end.
      when "parent-code" then do:
        assign CodeValue = {&attr-str} .
      end.

    end case.
  end.

  method override protected void CheckData ():

    define variable v-str        as character no-undo.
    define variable v-list-rates as character no-undo.
    define variable strErr       as character no-undo.
    define variable rate         as character no-undo.
    define buffer buf_units for ub.units.
    assign
      v-str = "code" when code_ = ? 
      v-str = v-str + ",chk-name" when CodeName = ?
      v-str = v-str + ",parent-code" when CodeValue = ?
    . 
    v-str = trim (v-str, ",").
    if v-str > ''
    then 
      undo, throw new Progress.Lang.AppError( substitute ("Теги &1 не могут иметь неопределное значение", v-str)).

    if misc2 <> "" then do:
      run getListTaxRateValue in ibs.th.gbl.gbl-hndllib:g#library
        ("НДС", ?, 0, "", 0, output v-list-rates).
      rate = string(decimal(misc2)) no-error.
      if error-status:error or 
         not can-do(v-list-rates, rate) then
        strErr = strErr + substitute("~nЗначение ~"&1~" тега <nds-code> не найден в справочнике ~"Налоги~"", misc2)
      .
    end.
    else misc2 = "20".
    
    if misc3 <> "" and misc3 <> ? then do:
      if not can-find(first buf_units where buf_units.unit-name = misc3 no-lock) then
        strErr = strErr + substitute("~nЗначение ~"&1~" тега <unit-code> не найден в справочнике ~"Единицы измерения~"", misc3)
      .
    end.
    else misc3 = "лт".
    if strErr <> "" then
      undo, throw new Progress.Lang.AppError(strErr).
  end.
end class.