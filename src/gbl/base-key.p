block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: base-key.p $
$Archive: gbl/base-key.p $

Код для запуска Actuate

Автор: Перваков Михаил Сергеевич
Дата создания: 05/20/03
Author: Mikhail Pervakov
Creation date: 05/20/03

*/

define output parameter p-base-key as character no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: base-key.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/base-key.p $":U .
define variable vss-description as character no-undo initial "Код для запуска Actuate".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ gbl/base64.i   }

define variable v-db-num   as integer   no-undo .
define variable v-today    as date      no-undo .
define variable v-time     as integer   no-undo .
define variable v-year     as integer   no-undo .
define variable v-month    as integer   no-undo .
define variable v-day      as integer   no-undo .
define variable v-hour     as integer   no-undo .
define variable v-min      as integer   no-undo .
define variable v-sec      as integer   no-undo .
define variable v-base-key as character no-undo .

do
on error undo, return error return-value
:

  { gbl/curdbnum.i
    v-db-num
  }

  run cur-time in this-procedure
    (output v-today
    ,output v-time
    ) .


  assign
    v-year  = year(v-today)
    v-month = month(v-today)
    v-day   = day(v-today)
  .
  assign
    v-sec = v-time modulo 60
  .
  assign
    v-time = integer(truncate((v-time) / 60, 0))
  .
  assign
    v-min  = v-time modulo 60
  .
  assign
    v-hour = integer(truncate((v-time) / 60, 0))
  .

  define buffer buf_db for ub.db .
  find first buf_db no-lock
    where buf_db.db-num = v-db-num
    no-error .
  if available buf_db
  then do:
    assign
      v-base-key = string(v-year  , '9999':u)
                 + string(v-month , '99':u)
                 + string(v-day   , '99':u)
                 + string(v-hour  , '99':u)
                 + string(v-min   , '99':u)
                 + string(v-sec   , '99':u)
                 + buf_db.db-key
    .
  end.


  define variable v-encode-key as character no-undo .
  define variable v-ind        as integer   no-undo .

  assign
    v-encode-key = ""
  .
  do v-ind = 1 to length(v-base-key)
  :
    assign
      v-encode-key = v-encode-key
                   + string(asc(substring(v-base-key, v-ind, 1)) + v-ind, '999':u)
    .
  end.


  run base64-encode in this-procedure
    (input  v-encode-key
    ,output p-base-key
    ) .
end.