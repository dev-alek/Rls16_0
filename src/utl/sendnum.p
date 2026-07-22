block-level on error undo, throw.

define input  parameter iUtil as class ibs.th.utl.method-for-draw-utility no-undo.
define input  parameter itext as character no-undo.
define input  parameter iobjcode as char no-undo.
/*
1  Кассиры удалены с касс
2  Кассиры переданы на кассы
3  Налоги удалены с касс
4  Налоги переданы на кассы
5  Типы платежей удалены с касс
6  Типы платежей переданы на кассы
7  Клиенты удалены с касс
8  Клиенты переданы на кассы
9  Маски карт удалены с касс
10 Маски карт переданы на кассы
11 Справочник ОСС удалены с касс
12 Справочник ОСС переданы на кассы
*/
define variable mAnswer as character  no-undo.
{cmp/str-glbl.i}
subscribe   to "ResponseToQuestion" anywhere run-procedure "SendAnswer".
if itext <> ""
then do:
  mAnswer = "4".
  run str/sendcash_num.p(iUtil:parparentproc,this-procedure,this-procedure,string(iobjcode) + {&delim-par} + itext).
end.

unsubscribe to "ResponseToQuestion".

procedure SendAnswer:
   define output parameter oAnswer as character  no-undo.
   oAnswer = mAnswer.
end procedure. 

procedure write-log-and-file :
define input parameter p-tabs as integer no-undo .
define input parameter p-log-file as character no-undo .
define input parameter p-int2 as integer no-undo .
define input parameter p-mess as character no-undo .
iUtil:put-log(p-mess).
end procedure. /* write-log-and-file */

procedure show-counter :

end procedure. /* show-counter */

