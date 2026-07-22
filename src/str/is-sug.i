
/*------------------------------------------------------------------------
    File        : is-gas.i
    
    Purpose     : Функция для определения природного газа по коду товара.
                  Для работы требуются инклудники:
                      {cmp/str-glbl.i}
                      {ref/gds-attr.i}
                  
                  Они должны быть выше { str/in-ptrl.i def one-line }, если такой имеется.

    Author(s)   : SKiryxin
    Created     : Mon Jan 21 11:59:23 MSK 2013
    Notes       : 
  ----------------------------------------------------------------------*/

/* ************************  Function Implementations ***************** */

function is-sug returns logical 
        (input p-gds-code as integer):
/*------------------------------------------------------------------------------
        Purpose: Возвращает logical, топливный товар или нет
        Notes:
------------------------------------------------------------------------------*/    

define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.

/* Стандартное нахождение атрибута */
do on error undo, return error:
    &scop proc-name gds-attr-value
    {&run_proc_attr-lib}
      (input  p-gds-code
      ,input  {&attr-fuel-type}
      ,output c-value
      ,output c-type) no-error.
end.

result = logical(c-value = 'lgas':U) no-error. /* При ошибке останется initial no */

return result.

end function.