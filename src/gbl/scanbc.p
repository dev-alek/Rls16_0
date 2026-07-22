block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: scanbc.p $
$Archive: gbl/scanbc.p $

Распознавание бар-кода

Автор: Перваков Михаил Сергеевич
Дата создания: 10/25/02
Author: Mikhail Pervakov
Creation date: 10/25/02

*/
define input  parameter parparentproc   as handle    no-undo.
define input  parameter p-b-c           as character no-undo .
define output parameter p-bar-code      as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: scanbc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/scanbc.p $":U .
define variable vss-description as character no-undo init "Распознавание бар-кода".
{ cmp/vssrevis.i "substitute('&1':u,p-b-c)" }

define variable is-err as logical   no-undo .

{ str/anlz-bc.i new }

do
on error undo, return error return-value
:
  for each un-bc
  on error undo, return error return-value
  :
    delete un-bc.
  end.

  run str/bc-anlz.p
    (input parparentproc
    ,input  'code-add':u
    ,input  p-b-c
    ,input  yes
    ,output is-err
    ,output table in-bc
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при анализе бар-кода" skip
      "Бар-код" p-b-c skip
      view-as alert-box error.
    undo, return error.
  end.
  find last un-bc no-error.
  if  available un-bc
  and un-bc.rez <> "ERR"
  then do:
     assign
       p-bar-code = un-bc.b-c
     .
  end.
  else do:
    undo, return error.
  end.
end.