block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История изменения статусов документа

Автор: Перваков Михаил Сергеевич
Дата создания: 04/29/03
Author: Mikhail Pervakov
Creation date: 04/29/03

Вызывается при приеме документа по новостям

*/

define input  parameter p-db-num           as integer   no-undo .
define input  parameter p-action-type      as character no-undo .
define input  parameter p-doc-code         as character no-undo .
define input  parameter p-obj-type         as character no-undo .
define input  parameter p-obj-code         as integer   no-undo .
define input  parameter p-doc-type         as character no-undo .
define input  parameter p-ext-doc-type     as character no-undo .
define input  parameter p-fact-date        as date      no-undo .
define input  parameter p-fact-qnty        as decimal   no-undo .
define input  parameter p-fact-base        as decimal   no-undo .
define input  parameter p-fact-rubl        as decimal   no-undo .
define input  parameter p-num-line         as integer   no-undo .
define input  parameter p-old-status       as character no-undo .
define input  parameter p-new-status       as character no-undo .
define input  parameter p-pck-db-num       as integer   no-undo .
define input  parameter p-pck-pack-num     as integer   no-undo .
define input  parameter p-user-db-num      as integer   no-undo .
define input  parameter p-user-name        as character no-undo .
define input  parameter p-sys-date         as date      no-undo .
define input  parameter p-sys-time         as character no-undo .
define input  parameter p-sys-time-int     as integer   no-undo .


define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "История изменения статусов документа".
{ cmp/vssrevis.i }
{ gbl/cur-time.i }
{ cmp/str-glbl.i }

do
on error undo, return error return-value
:
  create ub.nws-doc-hist .
  assign
    ub.nws-doc-hist.db-num            = p-db-num
    ub.nws-doc-hist.ord-num           = next-value(s-nws-hist, {&db-name_schema})

    ub.nws-doc-hist.action-type       = p-action-type
    ub.nws-doc-hist.doc-code          = p-doc-code
    ub.nws-doc-hist.obj-type          = p-obj-type
    ub.nws-doc-hist.obj-code          = p-obj-code
    ub.nws-doc-hist.doc-type          = p-doc-type
    ub.nws-doc-hist.ext-doc-type      = p-ext-doc-type
    ub.nws-doc-hist.fact-date         = p-fact-date
    ub.nws-doc-hist.fact-qnty         = p-fact-qnty
    ub.nws-doc-hist.fact-base         = p-fact-base
    ub.nws-doc-hist.fact-rubl         = p-fact-rubl
    ub.nws-doc-hist.num-line          = p-num-line
    ub.nws-doc-hist.old-status_       = p-old-status
    ub.nws-doc-hist.new-status_       = p-new-status

    ub.nws-doc-hist.nws-text          = ""

    ub.nws-doc-hist.pck-db-num        = p-pck-db-num
    ub.nws-doc-hist.pck-pack-num      = p-pck-pack-num

    ub.nws-doc-hist.user-db-num       = p-user-db-num
    ub.nws-doc-hist.user-name         = p-user-name
    ub.nws-doc-hist.user-sys-date     = p-sys-date
    ub.nws-doc-hist.user-sys-time     = p-sys-time
    ub.nws-doc-hist.user-sys-time-int = p-sys-time-int
  .

  run cur-time in this-procedure
    (output ub.nws-doc-hist.sys-date
    ,output ub.nws-doc-hist.sys-time-int
    ) .
  assign
    ub.nws-doc-hist.sys-time  = string(ub.nws-doc-hist.sys-time-int, 'HH:MM:SS':u)
    ub.nws-doc-hist.fact-date = ub.nws-doc-hist.sys-date
  .
end.