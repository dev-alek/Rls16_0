using Progress.Lang.*.
using ibs.th.str.cash.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.subjects.cashparam inherits ibs.th.bge.1crn.subjects.code:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
method public logical is-numeral
  (input p-string   as character ,
   input char-avail as character) :
  define variable p-replace-string as character no-undo .
  define variable log-result       as logical  no-undo .
  if p-string = ? then
    return false .
  p-replace-string = p-string.
  if lookup ("*", char-avail) > 0 then
      p-replace-string = replace (p-replace-string, '*', '9').
  if lookup ("digit", char-avail) > 0 then
    assign
      p-replace-string = replace (p-replace-string, '0', '9')
      p-replace-string = replace (p-replace-string, '1', '9')
      p-replace-string = replace (p-replace-string, '2', '9')
      p-replace-string = replace (p-replace-string, '3', '9')
      p-replace-string = replace (p-replace-string, '4', '9')
      p-replace-string = replace (p-replace-string, '5', '9')
      p-replace-string = replace (p-replace-string, '6', '9')
      p-replace-string = replace (p-replace-string, '7', '9')
      p-replace-string = replace (p-replace-string, '8', '9')
      .
  else
     p-replace-string = replace (p-replace-string, '9', chr(15))
      .
  if lookup ("letter", char-avail) > 0 then
    assign
      p-replace-string = replace (p-replace-string, 'A', '9')
      p-replace-string = replace (p-replace-string, 'B', '9')
      p-replace-string = replace (p-replace-string, 'C', '9')
      p-replace-string = replace (p-replace-string, 'D', '9')
      p-replace-string = replace (p-replace-string, 'E', '9')
      p-replace-string = replace (p-replace-string, 'F', '9')
      p-replace-string = replace (p-replace-string, 'G', '9')
      p-replace-string = replace (p-replace-string, 'H', '9')
      p-replace-string = replace (p-replace-string, 'I', '9')
      p-replace-string = replace (p-replace-string, 'J', '9')
      p-replace-string = replace (p-replace-string, 'K', '9')
      p-replace-string = replace (p-replace-string, 'L', '9')
      p-replace-string = replace (p-replace-string, 'M', '9')
      p-replace-string = replace (p-replace-string, 'N', '9')
      p-replace-string = replace (p-replace-string, 'O', '9')
      p-replace-string = replace (p-replace-string, 'P', '9')
      p-replace-string = replace (p-replace-string, 'Q', '9')
      p-replace-string = replace (p-replace-string, 'R', '9')
      p-replace-string = replace (p-replace-string, 'S', '9')
      p-replace-string = replace (p-replace-string, 'T', '9')
      p-replace-string = replace (p-replace-string, 'U', '9')
      p-replace-string = replace (p-replace-string, 'V', '9')
      p-replace-string = replace (p-replace-string, 'W', '9')
      p-replace-string = replace (p-replace-string, 'X', '9')
      p-replace-string = replace (p-replace-string, 'Y', '9')
      p-replace-string = replace (p-replace-string, 'Z', '9')
      p-replace-string = replace (p-replace-string, '_', '9')
      .
  return p-replace-string = fill ('9', length (p-string)).
end.
  define override property InitTag as character no-undo init "Etalon-param"
    get.
   define variable mCashDevice      as class CashDevice  no-undo.
   define variable mCashSection     as class CashSection no-undo.
   constructor public cashparam (  ):
      super ().
      mCashDevice  = new CashDevice().
      mCashSection = new CashSection().
   end constructor.
          define variable vSign as integer    no-undo.
  define variable vSource as integer  no-undo.
  define variable vSection as character no-undo.
  method override protected void SetPropProtected (inTag as char, inValue as char):
    super:SetPropProtected(inTag, inValue).
    case inTag:
      when "sign" then do:
         vSign = if inValue >= "" then integer (inValue) else 0.
         entry(2,parent_,chr(4)) = string(vSign).
      end.
      when "source" then do:
         vsource  = if inValue >= "" then integer (inValue) else 0.
         entry(3,parent_,chr(4)) = string(vsource).
      end.
      when "section" then do:
         vSection = if inValue >= "" then inValue else "".
        entry(4,parent_,chr(4)) = vSection.
      end.
      when "name" then do:
        code_ = if inValue >= "" then inValue else "" .
      end.
      when "value-etalon" then do:
        CodeValue = if inValue >= "" then inValue else "" .
      end.
      when "required" then do:
        status_ = (if inValue >= "" then integer (inValue) else 0) - 1 .
      end.
      when "description" then do:
        CodeName = if inValue >= "" then inValue else "" .
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
         parent_ = substitute ("cash-param&1&1&1",chr(4)).
      .
   end method.
        destructor public cashparam ( ):
          if valid-object(mCashDevice) then
        delete object mCashDevice.
      if valid-object(mCashSection) then
        delete object mCashSection.
        end destructor.
end class.
