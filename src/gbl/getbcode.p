block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: getbcode.p $
$Archive: gbl/getbcode.p $

Определение бар-кода по строке - интерфейсный файл для удобного вызова bc-rcnz.i

Автор: Перваков Михаил Сергеевич
Дата создания: 10/03/03
Author: Mikhail Pervakov
Creation date: 10/03/03

p-with-chs = true - в случае повторных бар-кодов - предоставлять возможность выбора

*/

define input  parameter parparentproc as widget-handle no-undo .
define input  parameter p-search-code as character no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-with-chs    as logical   no-undo .
define output parameter p-b-code      as integer   no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: getbcode.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/getbcode.p $":U .
define variable vss-description as character no-undo initial "Определение бар-кода по строке".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/libbcrcn.i }

define buffer buf_bar-code for ub.bar-code .
define buffer buf_prod-bc  for ub.prod-bc .
define buffer buf_place    for ub.place .

do
on error undo, return error return-value
:

  { str/sclspref.i }

  define variable v-result   as character no-undo .
  define variable v-type-bc  as character no-undo .
  define variable v-weight   as decimal   no-undo .

  { str/bc-rcnz.i
    parparentproc
    p-search-code
    0
    p-obj-type
    p-obj-code
    p-with-chs
    no
    varscales-pref
    varpgscales-pref
    v-result
    v-type-bc
    v-weight
    buf_bar-code
    buf_prod-bc
    buf_place
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при поиске бар-кода" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if available buf_bar-code
  then do:
    assign
      p-b-code = buf_bar-code.b-code
    .
  end.
  else do:
    assign
      p-b-code = ?
    .
  end.


end.