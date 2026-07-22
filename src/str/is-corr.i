
/*------------------------------------------------------------------------
    File        : is-corr.i
    
    Purpose     : 
                  Для работы требуются инклудники:
                      {cmp/str-glbl.i}
                      {ref/gds-attr.i}
                  
                  Они должны быть выше { str/in-ptrl.i def one-line }, если такой имеется.

    Author(s)   : 
    Created     : Mon Jan 21 11:59:23 MSK 2013
    Notes       : 
  ----------------------------------------------------------------------*/

/* ************************  Function Implementations ***************** */

function ChkType returns character 
        (input p-chk-type as integer):
/*------------------------------------------------------------------------------
        Purpose: Возвращает logical, топливный товар или нет
        Notes:
------------------------------------------------------------------------------*/    

define variable result as character no-undo.
result = entry(lookup(string(p-chk-type),{&receipt-codes}), {&receipt-codes-full} ) no-error . 

return result.

end function.

function PayType returns character 
        (input p-pay-code as integer):
/*------------------------------------------------------------------------------
        Purpose: Возвращает logical, топливный товар или нет
        Notes:
------------------------------------------------------------------------------*/    

define variable result as character no-undo.

find first ub.pay-type where ub.pay-type.obj-code = p-pay-code no-error .

if available (ub.pay-type) then result = ub.pay-type.obj-name .
else result = "" .
return result.

end function.

function OsnovCorr returns character 
        (input p-corr-osnov as integer):
/*------------------------------------------------------------------------------
        Purpose: Возвращает logical, топливный товар или нет
        Notes:
------------------------------------------------------------------------------*/    

define variable result as character no-undo.
find first ub.Code no-lock where ub.Code.code = string(p-corr-osnov) and ub.Code.parent = "OsnovCorr" no-error .
if available (ub.Code) then result = ub.Code.CodeName .
else result = "" .
return result.

end function.