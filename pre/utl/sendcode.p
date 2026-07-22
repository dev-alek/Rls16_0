block-level on error undo, throw.
define input  parameter iUtil as class ibs.th.utl.method-for-draw-utility no-undo.
define input  parameter iCode as integer no-undo.
define input  parameter ireclist as char no-undo.
define variable mAnswer as character  no-undo.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
subscribe   to "ResponseToQuestion" anywhere run-procedure "SendAnswer".
if iCode eq 1
then do:
  mAnswer = "4".
  run str/sendcash.p(iUtil:parparentproc,this-procedure,this-procedure,string(iUtil:Obj-code) + chr(4) + "D").
end.
 else if iCode eq 2
then do:
  mAnswer = "1".
  run str/sendcash.p(iUtil:parparentproc,this-procedure,this-procedure,string(iUtil:obj-code) + chr(4) + "U").
end.
else if iCode eq 3
then do:
  mAnswer = "4".
  run str/send-tax.p (iUtil:parparentproc, 'IBM':U, iUtil:obj-type, iUtil:obj-code, 'D') .
end.
else if iCode eq 4
then do:
  mAnswer = "5".
  run str/send-tax.p (iUtil:parparentproc, 'IBM':U, iUtil:obj-type, iUtil:obj-code, 'U') .
end.
else if iCode eq 5
then do:
  mAnswer = "4".
  run str/2cashpay.p(iUtil:parparentproc,this-procedure,this-procedure,'IBM':U + chr(4) + iUtil:obj-type + chr(4) + string(iUtil:obj-code) + chr(4) + "D").
end.
else if iCode eq 6
then do:
  mAnswer = "1".
  run str/2cashpay.p(iUtil:parparentproc,this-procedure,this-procedure,'IBM':U + chr(4) + iUtil:obj-type + chr(4) + string(iUtil:obj-code) + chr(4) + "U").
end.
else if iCode eq 7
then do:
  mAnswer = "7".
  run str/cash-cli.p(iUtil:parparentproc,this-procedure,this-procedure,string(ibs.th.gbl.gbl-var:g#db-num) + chr(4) + iUtil:obj-type + chr(4) + string(iUtil:obj-code) + chr(4) + "D").
end.
else if iCode eq 8
then do:
  mAnswer = "5".
  run str/cash-cli.p(iUtil:parparentproc,this-procedure,this-procedure,string(ibs.th.gbl.gbl-var:g#db-num)  + chr(4) + iUtil:obj-type + chr(4) + string(iUtil:obj-code) + chr(4) + "U").
  mAnswer = "6".
  run str/cash-cli.p(iUtil:parparentproc,this-procedure,this-procedure,string(ibs.th.gbl.gbl-var:g#db-num)  + chr(4) + iUtil:obj-type + chr(4) + string(iUtil:obj-code) + chr(4) + "U").
end.
else if iCode eq 9
then do:
  mAnswer = "4".
  run str/senddcty.p (iUtil:parparentproc,this-procedure,this-procedure,iUtil:obj-type + chr(4) + string(iUtil:obj-code) + chr(4) + "D").
end.
else if iCode eq 10
then do:
  mAnswer = "1".
  run str/senddcty.p (iUtil:parparentproc,this-procedure,this-procedure,iUtil:obj-type + chr(4) + string(iUtil:obj-code) + chr(4) + "U").
end.
else  if iCode eq 11
then do:
  mAnswer = "1".
  run str/bpasend.p (iUtil:parparentproc,this-procedure,this-procedure,'IBM-XML':U + chr(4) + iUtil:obj-type + chr(4) + string(iUtil:obj-code) + chr(4) + "DD").
end.
else  if iCode eq 12
then do:
  mAnswer = "1".
  run str/bpasend.p (iUtil:parparentproc,this-procedure,this-procedure,'IBM-XML':U + chr(4) + iUtil:obj-type + chr(4) + string(iUtil:obj-code) + chr(4) + "UU").
end.
else if iCode eq 13
then do:
  mAnswer = "4".
  run str/del-gds.p (iUtil:parparentproc,this-procedure,this-procedure,string(iUtil:obj-code) + chr(4) + "no").
end.
else if iCode eq 14
then do:
  mAnswer = "1".
  run str/send-gds-draw.p (iUtil:parparentproc).
end.
else if iCode eq 15
then do:
  run str/sendcashcomm.p (iUtil:parparentproc,this-procedure,this-procedure,iUtil:obj-type + chr(4) + string(iUtil:obj-code) + chr(4) + "U","execute","dbClear",ireclist).
end.
else if iCode eq 16
then do:
run str/send-all.p ( iUtil:parparentproc
                    ,this-procedure
                    ,this-procedure
                    ,iUtil:obj-type + chr(4) + string(iUtil:obj-code) + chr(4) + 'D':U + chr(4) + 'emrc':U + chr(4) + 'Удаление справочника ЕМЦ':U
                     ) no-error.
end.
else if iCode eq 17
then do:
run str/send-all.p ( iUtil:parparentproc
                    ,this-procedure
                    ,this-procedure
                    ,iUtil:obj-type + chr(4) + string(iUtil:obj-code) + chr(4) + 'U':U + chr(4) + 'emrc':U + chr(4) + 'Передача справочника ЕМЦ':U
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
end procedure.
procedure show-counter :
end procedure.
