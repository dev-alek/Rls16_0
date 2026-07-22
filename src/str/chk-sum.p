block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chk-sum.p $
$Archive: str/chk-sum.p $

Рассчет контрольной суммы бар-кода

Автор: Перваков Михаил Сергеевич
Дата создания: 04/11/06
Author: Mikhail Pervakov
Creation date: 04/11/06

*/

def input-output param code as char no-undo.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: chk-sum.p $":U .
def var vss-archive     as character no-undo init "$Archive: str/chk-sum.p $":U .
def var vss-description as character no-undo init "Рассчет контрольной суммы бар-кода".
{ cmp/vssrevis.i }

def var i as int no-undo.
def var sum as int no-undo.

assign
  sum = 0
.
do i = 1 to length(code) by 2
:
  if substring(code,length(code) - i + 1,1) < "0"
  or substring(code,length(code) - i + 1,1) > "9"
  then do:
    return error.
  end.

  assign
    sum = sum + int(substr(code,length(code) - i + 1,1))
  .
end.

assign
  sum = sum * 3
.
do i = 2 to length(code) by 2
:
  if substr(code,length(code) - i + 1,1) < "0"
  or substr(code,length(code) - i + 1,1) > "9"
  then do:
    return error.
  end.
  assign
    sum = sum + int(substr(code,length(code) - i + 1,1))
  .
end.
if sum mod 10 = 0 then do:
  assign
    code = code + '0'
  .
end.
else do:
  assign
    code = code + string(10 - sum mod 10)
  .
end.