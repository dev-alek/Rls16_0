/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

создание записи route

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/03
Author: Dmitry Ukhanov
Creation date: 03/23/03

*/

&if defined( cr-rt-log-db-name ) = 0 &then
  &scop cr-rt-log-db-name ub
&endif


&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define buffer buf{&vssseq}_db    for {&cr-rt-log-db-name}.db .
define buffer buf{&vssseq}_route for {&cr-rt-log-db-name}.route .
define variable v-msg#{&vssseq}    as character no-undo .
define variable v-lock#{&vssseq}   as logical   no-undo .
define variable v-ok#{&vssseq}     as logical   no-undo .

find first buf{&vssseq}_db no-lock
  where buf{&vssseq}_db.db-num = {&db-num}
  no-error
.
if not available buf{&vssseq}_db then do:
  message
    vss-include-info{&vssseq} skip
    vss-workfile vss-revision vss-description skip
    substitute( "Попытка создать маршрутизацию на несуществующую БД &1", {&db-num} ) skip
    return-value skip
    error-status :get-message ( error-status :num-messages )
    view-as alert-box error
  .
end.

if "{&cr-rt-log-db-name}":U <> "ub":U
   or ( trim( buf{&vssseq}_db.db-key ) <> "":U
        and buf{&vssseq}_db.db-key <> ?
      )
then do:
  &if "{&cr-rt-log-db-name}":U <> "ub":U &then
    disable triggers for load of {&cr-rt-log-db-name}.route .
  &endif

  create buf{&vssseq}_route .
  assign
    buf{&vssseq}_route.last-pack    = -1
    buf{&vssseq}_route.name-rec     = {&name-rec}
    buf{&vssseq}_route.db-num       = {&db-num}
    buf{&vssseq}_route.uniq-key-rec = {&uniq-key-rec}
    buf{&vssseq}_route.num-dump     = {&num-dump}
    buf{&vssseq}_route.tbl-ord      = dynamic-next-value( "s-news-ord":U, "{&cr-rt-log-db-name}":U )
    .
  &if defined( dump-ord ) <> 0 &then
    assign
      buf{&vssseq}_route.dump-ord = {&dump-ord}
    .
  &else
    assign
      buf{&vssseq}_route.dump-ord = dynamic-next-value( "s-news-dord":U, "{&cr-rt-log-db-name}":U )
    .
  &endif
  &if defined(uniq-gate-rec) <> 0 &then
    assign
    buf{&vssseq}_route.uniq-gate-rec = {&uniq-gate-rec}
    .
  &endif

  &if defined( CreDate ) <> 0 &then
    assign
      buf{&vssseq}_route.CreDate      = {&CreDate}
    .
  &endif
  &if defined( CreTimeInt ) <> 0 &then
    assign
      buf{&vssseq}_route.CreTimeInt   = {&CreTimeInt}
      buf{&vssseq}_route.CreTime      = string({&CreTimeInt},"HH:MM:SS":U)
    .
  &endif
  &if defined( CreUserName ) <> 0 &then
    assign
      buf{&vssseq}_route.CreUserName  = {&CreUserName}
    .
  &endif
  &if defined( PS ) <> 0 &then
    assign
      buf{&vssseq}_route.action       = {&PS}
    .
  &endif
  &if defined( cre-count ) <> 0 &then
    assign
      {&cre-count} = {&cre-count} + 1
    .
  &endif
end.
else do:
  { nws/lock-rt.i
    "'check'"
    {&db-num}
    0
    "''"
    v-msg#{&vssseq}
    v-lock#{&vssseq}
    v-ok#{&vssseq}
    no-error
  }
  if error-status :error
    or v-lock#{&vssseq} = true
    or v-ok#{&vssseq}   = false
  then do:
    return error substitute( "&1. Маршрутизация записи &2.&3Ключ записи: &4&3&3"
                             ,vss-include-info{&vssseq}
                             ,{&name-rec}
                             ,{&new-line}
                             ,{&uniq-key-rec}
                           )
                + substitute( "&1&2&2&3&2&2&4"
                              ,v-msg#{&vssseq}
                              ,{&new-line}
                              ,return-value
                              ,error-status :get-message( error-status :num-messages )
                            ) .
  end.
end.

/* $Workfile$ e n d */