 
 /*------------------------------------------------------------------------
    File        : cashparam
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Daru
    Created     : Sun Mar 12 17:34:20 MSK 2023
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using ibs.th.str.cash.*.
block-level on error undo, throw.

class ibs.th.bge.1crn.subjects.cashparam inherits ibs.th.bge.1crn.subjects.code: 
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get. 
  { cmp/str-glbl.i class } 
  { gbl/is-num.i }
    
  define override property InitTag as character no-undo init "Etalon-param"
    get. 

   /*------------------------------------------------------------------------------
    Purpose:
    Notes:
   ------------------------------------------------------------------------------*/
   define variable mCashDevice      as class CashDevice  no-undo.
   define variable mCashSection     as class CashSection no-undo.
   
   constructor public cashparam (  ):
      super ().
      mCashDevice  = new CashDevice().
      mCashSection = new CashSection().
   end constructor.
  
  &scoped-define attr-str      if inValue >= "" then inValue else ""
  &scoped-define attr-integer  if inValue >= "" then integer (inValue) else 0
  &scoped-define attr-dec      if inValue >= "" then decimal (inValue) else 0.0
  &scoped-define attr-date     if inValue >= "" then date-mth (inValue) else ? 
  define variable vSign as integer    no-undo. 
  define variable vSource as integer  no-undo.
  define variable vSection as character no-undo.

  method override protected void SetPropProtected (inTag as char, inValue as char):
    super:SetPropProtected(inTag, inValue).
    case inTag:
      when "sign" then do:
         vSign = {&attr-integer}.
         entry(2,parent_,{&delim-par}) = string(vSign).
      end.
      when "source" then do:
         vsource  = {&attr-integer}.
         entry(3,parent_,{&delim-par}) = string(vsource).
      end.
      when "section" then do:
         vSection = {&attr-str}.
        entry(4,parent_,{&delim-par}) = vSection.
      end.
      when "name" then do:
        code_ = {&attr-str} .
      end.
      when "value-etalon" then do:
        CodeValue = {&attr-str} .
      end.
      when "required" then do:
        status_ = ({&attr-integer}) - 1 .
      end.
      when "description" then do:
        CodeName = {&attr-str} .
      end.

    end case.
  end.

  method override protected void CheckData ():
    def var v-str as char no-undo.
    define buffer code for ub.Code.
    assign
      v-str =         "sign"          when vSign = ?
      v-str = v-str + ",source"       when vsource = ?
      v-str = v-str + ",Section"      when vSection = ?
      v-str = v-str + ",name"         when code_ = ? and vsource ne 2
    .
    if code_ eq ?
    then 
       code_ = "". 
    v-str = trim (v-str, ",").
    if v-str > ''
    then 
      undo, throw new Progress.Lang.AppError( substitute ("Теги &1 не могут иметь неопределное значение", v-str)).
    
    
    if mCashDevice:GetProp(vSign) eq mCashDevice:Unknow
    then
       undo, throw new Progress.Lang.AppError( substitute ('Тег "&1" имеет не допустимое значение "&2"', "sign", vsign + 1)).
    
   if mCashSection:GetProp(vsource) eq mCashSection:Unknow
   then
       undo, throw new Progress.Lang.AppError( substitute ('Тег "&1" имеет не допустимое значение "&2"', "source",vsource)).
    
   if     status_ ne 0 
      and status_ ne 1   
   then do:
      undo, throw new Progress.Lang.AppError(substitute ("Недопустимое значение &1 поля required Допустимы 1 - обязательный и 2 - Необязательный",
                               status_ + 1)).
   end.
   
   if not is-numeral (vsection,
                      if vsource eq 1
                      then "letter,digit"
                      else "digit")
   then do:
      undo, throw new Progress.Lang.AppError(substitute ("Недопустимое значение '&1' поля section Допустимы только &2",
                               vsection, 
                               if vsource eq 1 then "Латинские буквы, цифры, подчеркивание и * " else "Цифры" )).
   end.
   if vsource eq 1
   then do:
      if not is-numeral (code_,
                         "letter,digit,*"
                         )
      then do:
         undo, throw new Progress.Lang.AppError(substitute ("Недопустимое значение '&1' поля name Допустимы только &2",
                                  code_, 
                                  if vsource eq 1 then "Латинские буквы, цифры, подчеркивание и * " else "Цифры")).
      end.
   end.
   else do:
      if     codevalue ne "MGR"
         and codevalue ne "REG"   
      then do:
         undo, throw new Progress.Lang.AppError(substitute ("Недопустимое значение &1 поля value-etalon Допустимы MGR - менаджер и REG - кассир",
                                  codevalue)).
      end.
   end.
   
    
    old_code_ = code_.
    old_parent_ = parent_.
  end.

  method override protected void ClearSub(  ):
      
      super:ClearSub().
      assign
         vSign = ?
         vsource = ?
         vSection = ?
         old_code_ = ?
         old_parent_ = ?
         code_  = ?
         CodeValue = ""
         parent_ = substitute ("cash-param&1&1&1",{&delim-par}).
       
      .
   end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	destructor public cashparam ( ):
	  if valid-object(mCashDevice) then
        delete object mCashDevice.
      if valid-object(mCashSection) then
        delete object mCashSection.
	end destructor.

  

end class.