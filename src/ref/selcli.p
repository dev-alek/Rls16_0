block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: selcli.p $
$Archive: ref/selcli.p $

Выбрать клиента из справочника

Автор: Перваков Михаил Сергеевич
Дата создания: 01/31/03
Author: Mikhail Pervakov
Creation date: 01/31/03

Вся информация передаётся через параметры

*/

define input  parameter parparentproc  as widget-handle no-undo .
define input  parameter h-call-prog    as handle    no-undo .
define input  parameter p-client-types as character no-undo .
define input  parameter p-lock-cli-type as logical no-undo .
define output parameter p-select-ok    as logical   no-undo .
define output parameter p-cli-type     as character no-undo .
define output parameter p-cli-code     as integer   no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: selcli.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: ref/selcli.p $":U .
define variable vss-description as character no-undo initial "Выбрать клиента из справочника".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-ref-list      as character no-undo .
define variable v-clients-recid as recid     no-undo .

do
on error undo, return error return-value
:
  run ref/cli-all.w
    (input  parparentproc   /* parparentproc */
    ,input  'b-sel':U       /* bttns         */
    ,input  p-client-types  /* c-types       */
    ,input  ?               /* c-group       */
    ,input  ?               /* c-status      */
    ,input  ?               /* c-recid       */
    ,input  ?               /* c-added       */
    ,input  (if p-lock-cli-type then "lock-cli-type" else ?)               /* c-other       */
    ,output v-ref-list      /* p-rid-list    */
    ) .

  if v-ref-list <> ""
  then do:
    assign
      v-clients-recid = integer (v-ref-list)
    .
    find ub.clients no-lock
      where recid(ub.clients) = v-clients-recid
      .
    assign
      p-select-ok = true
      p-cli-type  = ub.clients.obj-type
      p-cli-code  = ub.clients.obj-code
    .
    return .
  end.
  else do:
    assign
      p-select-ok = false
      p-cli-type  = '':u
      p-cli-code  = 0
    .
  end.
end.