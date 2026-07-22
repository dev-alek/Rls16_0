/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка на валидность плотности

Автор: Булгаков Андрей Николаевич
Дата создания: 05/13/05
Author: Andrew Bulgakoff
Creation date: 05/13/05

*/

&if     "{1}" = "def" &then
  function valid-density returns logical ( input p-density as decimal, input p-unit-base-cli-eq as logical ) :
    define variable v-answ as logical no-undo .
    if ( p-unit-base-cli-eq = true
         and p-density = 1.0
       )
      or ( p-unit-base-cli-eq = false
           and p-density <> ?
           and p-density > 0.0
           and p-density < 1.0
         )
    then do:
      assign
        v-answ = true
      .
    end.
    else do:
      assign
        v-answ = false
      .
    end.
    return v-answ.
  end function. /* valid-density */
&elseif "{1}" = "chk" &then
  valid-density( {2}, {3} )
&endif

/* $Workfile$   E n d */