block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: os-err.p $
$Archive: adm/os-err.p $

Преобразование кодов ошибок ОС в текст

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/97
Author: Dmitry Ukhanov
Creation date: 03/22/97

*/
define output parameter errText as character no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: os-err.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/os-err.p $":U .
define variable vss-description as character no-undo init "Преобразование кодов ошибок ОС в текст".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:
  case OS-ERROR:
    when   0 then assign errText = "".
    when   1 then assign errText = "Not Owner".
    when   2 then assign errText = "No such file or directory".
    when   3 then assign errText = "Interrupted system call".
    when   4 then assign errText = "I/O error".
    when   5 then assign errText = "Bad file number".
    when   6 then assign errText = "No more processes".
    when   7 then assign errText = "Not enough core memory".
    when   8 then assign errText = "Permission denied".
    when   9 then assign errText = "Bad address".
    when  10 then assign errText = "File exists".
    when  11 then assign errText = "No such device".
    when  12 then assign errText = "Not a directory".
    when  13 then assign errText = "Is a directory".
    when  14 then assign errText = "File table overflow".
    when  15 then assign errText = "Too many open files".
    when  16 then assign errText = "File too large".
    when  17 then assign errText = "No space left on device".
    when  18 then assign errText = "Directory not empty".
    otherwise     assign errText = "Unmapped error (PROGRESS default)".
  end.

  assign
    errText = errText + " (":U + string( OS-ERROR ) + ")":U
  .

  return.
end.

/* $Workfile: os-err.p $ e n d */