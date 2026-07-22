/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение строкового выражения для области действи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/25/05
Author: Bakhtadze Natalya
Creation date: 05/25/05

*/

&if defined(get-regf_i) = 0 &then

&glob get-regf_i


&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

FUNCTION get-region RETURNS CHARACTER
  ( input parhost-code as integer, input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if parhost-code = 0 and
       parobj-type = "":U and
       parobj-code = 0 then do:
       par-region = "Глобально".
       return par-region.
    end.
    if parobj-type = {&cmp} then do:
       par-region = fill({&space-char}, 2) + "Фирма" + {&space-char} + string(parhost-code).
       return par-region.
    end.
    if parobj-type = {&region} 
    then do:
       par-region = fill({&space-char}, 2) + "Регион" + {&space-char} + string(parobj-code).
       return par-region.  
    end.
    par-region = fill({&space-char}, 4) + parobj-type + {&space-char} + string(parobj-code).
    return par-region.
END FUNCTION.


FUNCTION get-objregion RETURNS CHARACTER
  (  input parobj-type as character, input parobj-code as integer ) :
  define variable par-region as character no-undo.
  if  parobj-type = "":U and
      parobj-code = 0 
  then do:
     par-region = "Глобально".  
  end.
  else if parobj-type = {&cmp} 
  then do:
     par-region = fill({&space-char}, 2) + "Фирма" + {&space-char} + string(parobj-code).  
  end.
  else if parobj-type = {&region} 
  then do:
     par-region = fill({&space-char}, 2) + "Регион" + {&space-char} + string(parobj-code).  
  end.
  else 
     par-region = fill({&space-char}, 4) + parobj-type + {&space-char} + string(parobj-code).
  return par-region.
END FUNCTION.

&endif

/* $Workfile$ e n d */