define input  parameter iKey     as integer no-undo.
define output parameter oChekSum as character no-undo.
if userid("ub") eq ""
then do:
   oChekSum = {utl/chekproc.i iKey }.
   return.
end.
&if defined (checkdate)
&then
    if today > date("{&checkdate}")
    then do:
       message "Процедура не действитльна обратитесь в Экспертек."
       view-as alert-box.
       return.
    end.
&endif