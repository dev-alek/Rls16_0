
/* ************************  Function Implementations ***************** */

function is-mes returns logical 
        (input doc-code as character):
/*------------------------------------------------------------------------------
        Purpose: Возвращает logical, топливный товар или нет
        Notes:
------------------------------------------------------------------------------*/    

define variable result as logical no-undo init no.

find first ub.inv-doc-attr no-lock where
ub.inv-doc-attr.doc-code = doc-code and
ub.inv-doc-attr.attr-code = "notMes" and
ub.inv-doc-attr.attr-value = string(true) no-error .
if available (ub.inv-doc-attr) then result = true. 

return result.

end function.