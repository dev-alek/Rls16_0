block-level on error undo, throw.
define input  parameter iUtil as class ibs.th.utl.method-for-draw-utility no-undo.
define input  parameter iCode as integer no-undo.
define input  parameter ireclist as char no-undo.
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

16 ЕМС удалены с касс
17 ЕМС переданы на кассы


*/
define variable mAnswer as character  no-undo.
{cmp/str-glbl.i}


subscribe   to "ResponseToQuestion" anywhere run-procedure "SendAnswer".
if iCode eq 1
then do:
  mAnswer = "4".
  run str/sendcash.p(iUtil:parparentproc,this-procedure,this-procedure,string(iUtil:Obj-code) + {&delim-par} + "D").
end.
 else if iCode eq 2
then do:
  mAnswer = "1".
  run str/sendcash.p(iUtil:parparentproc,this-procedure,this-procedure,string(iUtil:obj-code) + {&delim-par} + "U").
end.
else if iCode eq 3
then do:
  mAnswer = "4".
  run str/send-tax.p (iUtil:parparentproc, {&cd-type-ibm}, iUtil:obj-type, iUtil:obj-code, 'D') .
end.
else if iCode eq 4
then do:
  mAnswer = "5".
  run str/send-tax.p (iUtil:parparentproc, {&cd-type-ibm}, iUtil:obj-type, iUtil:obj-code, 'U') .
end.
else if iCode eq 5
then do:
  mAnswer = "4".
  run str/2cashpay.p(iUtil:parparentproc,this-procedure,this-procedure,{&cd-type-ibm} + {&delim-par} + iUtil:obj-type + {&delim-par} + string(iUtil:obj-code) + {&delim-par} + "D").
end.
else if iCode eq 6
then do:
  mAnswer = "1".
  run str/2cashpay.p(iUtil:parparentproc,this-procedure,this-procedure,{&cd-type-ibm} + {&delim-par} + iUtil:obj-type + {&delim-par} + string(iUtil:obj-code) + {&delim-par} + "U").
end.

else if iCode eq 7
then do:
  mAnswer = "7".
  run str/cash-cli.p(iUtil:parparentproc,this-procedure,this-procedure,string(ibs.th.gbl.gbl-var:g#db-num) + {&delim-par} + iUtil:obj-type + {&delim-par} + string(iUtil:obj-code) + {&delim-par} + "D").
  
end.
else if iCode eq 8
then do:
  mAnswer = "5".
  run str/cash-cli.p(iUtil:parparentproc,this-procedure,this-procedure,string(ibs.th.gbl.gbl-var:g#db-num)  + {&delim-par} + iUtil:obj-type + {&delim-par} + string(iUtil:obj-code) + {&delim-par} + "U").
  mAnswer = "6".
  run str/cash-cli.p(iUtil:parparentproc,this-procedure,this-procedure,string(ibs.th.gbl.gbl-var:g#db-num)  + {&delim-par} + iUtil:obj-type + {&delim-par} + string(iUtil:obj-code) + {&delim-par} + "U").
end.
else if iCode eq 9
then do:
  mAnswer = "4".
  run str/senddcty.p (iUtil:parparentproc,this-procedure,this-procedure,iUtil:obj-type + {&delim-par} + string(iUtil:obj-code) + {&delim-par} + "D").
end.
else if iCode eq 10
then do:
  mAnswer = "1".
  run str/senddcty.p (iUtil:parparentproc,this-procedure,this-procedure,iUtil:obj-type + {&delim-par} + string(iUtil:obj-code) + {&delim-par} + "U").
end. 

else  if iCode eq 11
then do:
  mAnswer = "1".
  run str/bpasend.p (iUtil:parparentproc,this-procedure,this-procedure,{&cd-type-IBM-XML} + {&delim-par} + iUtil:obj-type + {&delim-par} + string(iUtil:obj-code) + {&delim-par} + "DD").
end.
else  if iCode eq 12
then do:
  mAnswer = "1".
  run str/bpasend.p (iUtil:parparentproc,this-procedure,this-procedure,{&cd-type-IBM-XML} + {&delim-par} + iUtil:obj-type + {&delim-par} + string(iUtil:obj-code) + {&delim-par} + "UU").
end.
else if iCode eq 13
then do:
  mAnswer = "4".
  run str/del-gds.p (iUtil:parparentproc,this-procedure,this-procedure,string(iUtil:obj-code) + {&delim-par} + "no").
end.
else if iCode eq 14
then do:
  mAnswer = "1".
  run str/send-gds-draw.p (iUtil:parparentproc).
end.  
else if iCode eq 15
then do:
  run str/sendcashcomm.p (iUtil:parparentproc,this-procedure,this-procedure,iUtil:obj-type + {&delim-par} + string(iUtil:obj-code) + {&delim-par} + "U","execute","dbClear",ireclist).
end.

else if iCode eq 16
then do:
run str/send-all.p ( iUtil:parparentproc
                    ,this-procedure
                    ,this-procedure
                    ,iUtil:obj-type + {&delim-par} + string(iUtil:obj-code) + {&delim-par} + 'D':U + {&delim-par} + 'emrc':U + {&delim-par} + 'Удаление справочника ЕМЦ':U 
                     ) no-error.
end.

else if iCode eq 17
then do:
run str/send-all.p ( iUtil:parparentproc
                    ,this-procedure
                    ,this-procedure
                    ,iUtil:obj-type + {&delim-par} + string(iUtil:obj-code) + {&delim-par} + 'U':U + {&delim-par} + 'emrc':U + {&delim-par} + 'Передача справочника ЕМЦ':U 
                     ) no-error.
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

