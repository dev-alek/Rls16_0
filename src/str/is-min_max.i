
/*------------------------------------------------------------------------
    File        : is-min_max.i
    
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

function MinInt returns integer 
  (input p-code as integer):
  /*------------------------------------------------------------------------------
          Purpose: Возвращает logical, топливный товар или нет
          Notes:
  ------------------------------------------------------------------------------*/    

  define variable result as integer no-undo.
  define variable kk     as integer no-undo .
  if length (string(p-code)) < 6 then 
  do:
    do kk = length(string(p-code)) to 6:
      result = integer (string (p-code) + "0") .            
    end .  
  end.  
  else 
    result = p-code .
 

  return result.

end function.

function MaxInt returns integer 
  (input p-code as integer):
  /*------------------------------------------------------------------------------
          Purpose: Возвращает logical, топливный товар или нет
          Notes:
  ------------------------------------------------------------------------------*/    

  define variable result as integer no-undo.
  define variable kk     as integer no-undo .
  if length (string(p-code)) < 6 then 
  do:
    do kk = length(string(p-code)) to 6:
      result = integer (string (p-code) + "9") .            
    end .  
  end.  
  else 
    result = p-code .
 

  return result.

end function.