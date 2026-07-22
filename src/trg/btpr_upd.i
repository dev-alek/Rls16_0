/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка записей отложенных заданий BatchProcess

Автор: Перваков Михаил Сергеевич
Дата создания: 06/21/00
Author: Mikhail Pervakov
Creation date: 06/21/00

создание, изменение статуса, проверка необходимости обработки

*/

&if defined( btpr_user_id ) = 0 or '{&btpr_user_id}' = '' &then
  &scop btpr_user_id  g#userid
&endif

&if "{&btpr-status}" <> "executing"
and "{&btpr-status}" <> "deleted"
and "{&btpr-status}" <> "find"
and "{&btpr-status}" <> "create"
and "{&btpr-status}" <> "executing_deleted"
&then
  &message bpr_upd.i: btpr-status parameter must be specified
&endif

&if "{&btpr-status}" = "find" &then
  find first {&btpr-table} {&btpr-lock-option}
    where {&btpr-table}.bp_type   = {&btpr-type}
      and {&btpr-table}.bp_status = {&btpr-normal}
    &if defined(key#_one) > 0 &then
      and  {&btpr-table}.key#_one  = {&key#_one}
    &endif
    &if defined(key#_two) > 0 &then
      and {&btpr-table}.key#_two = {&key#_two}
    &endif
    &if defined(key#_three) > 0 &then
      and {&btpr-table}.key#_three = {&key#_three}
    &endif
    &if defined(charkey_one) > 0 &then
      and {&btpr-table}.charkey_one = {&charkey_one}
    &endif
    &if defined(charkey_two) > 0 &then
      and {&btpr-table}.charkey_two = {&charkey_two}
    &endif
    &if defined(charkey_three) > 0 &then
      and {&btpr-table}.charkey_three = {&charkey_three}
    &endif

  no-error .
&endif

&if "{&btpr-status}" = "create" &then
  find first ub.batchprocess no-lock
    where ub.batchprocess.bp_type   = {&btpr-type}
      and ub.batchprocess.bp_status = {&btpr-normal}
    &if defined(key#_one) > 0 &then
      and  ub.batchprocess.key#_one  = {&key#_one}
    &endif
    &if defined(key#_two) > 0 &then
      and ub.batchprocess.key#_two = {&key#_two}
    &endif
    &if defined(key#_three) > 0 &then
      and ub.batchprocess.key#_three = {&key#_three}
    &endif
    &if defined(charkey_one) > 0 &then
      and ub.batchprocess.charkey_one = {&charkey_one}
    &endif
    &if defined(charkey_two) > 0 &then
      and ub.batchprocess.charkey_two = {&charkey_two}
    &endif
    &if defined(charkey_three) > 0 &then
      and ub.batchprocess.charkey_three = {&charkey_three}
    &endif

  no-error .

  if not available ub.BatchProcess then do:
    create ub.BatchProcess .

    &scop seq {&sequence}
    define variable v-btpr_upd-today-{&seq} as date      no-undo.
    define variable v-btpr_upd-time-{&seq}  as integer   no-undo.
    run cur-time in this-procedure ( output v-btpr_upd-today-{&seq}
                                   , output v-btpr_upd-time-{&seq}
                                   ).
    assign
      ub.BatchProcess.BP_Type       = {&btpr-type}
      ub.BatchProcess.BP_Status     = {&btpr-normal}
      ub.BatchProcess.BatchProcess# = next-value( s-btpr, {&db-name_schema} )
      ub.BatchProcess.User_ID       = {&btpr_user_id}
      ub.BatchProcess.BP_SysDate    = v-btpr_upd-today-{&seq}
      ub.BatchProcess.BP_SysTime    = string( v-btpr_upd-time-{&seq}, 'HH:MM' )
      ub.BatchProcess.BP_SysTimeInt = v-btpr_upd-time-{&seq}
    .

    assign
    &if defined(Key#_One)      > 0 &then
      ub.BatchProcess.Key#_One      = {&Key#_One}
    &endif
    &if defined(Key#_Two)      > 0 &then
      ub.BatchProcess.Key#_Two      = {&Key#_Two}
    &endif
    &if defined(Key#_Three)    > 0 &then
      ub.BatchProcess.Key#_Three    = {&Key#_Three}
    &endif
    &if defined(CharKey_One)   > 0 &then
      ub.BatchProcess.CharKey_One   = {&CharKey_One}
    &endif
    &if defined(CharKey_Two)   > 0 &then
      ub.BatchProcess.CharKey_Two   = {&CharKey_Two}
    &endif
    &if defined(CharKey_Three) > 0 &then
      ub.BatchProcess.CharKey_Three = {&CharKey_Three}
    &endif
    .
  end.
&endif


&if "{&btpr-status}" = "executing" &then
  define variable bpr_lprocessedok as logical /* undo */ init false .

  /* запись обработки помечается как исполняемая */
  big_loop:
  do transaction
  on error undo big_loop, return error
  :
    find first {&btpr-table} exclusive-lock
      where rowid( {&btpr-table}) = {&btpr-rowid}
      no-error
      no-wait
      .
    if not available {&btpr-table} then do:
      undo big_loop, return error .
    end.
    if {&btpr-table}.bp_status <> {&btpr-normal} then do:
      find current {&btpr-table} no-lock .
      undo big_loop, return error .
    end.
    &scop seq {&sequence}
    define variable v-btpr_upd-today-{&seq} as date      no-undo.
    define variable v-btpr_upd-time-{&seq}  as integer   no-undo.
    run cur-time in this-procedure ( output v-btpr_upd-today-{&seq}
                                   , output v-btpr_upd-time-{&seq}
                                   ).
    assign
      {&btpr-table}.bp_status         = {&btpr-executing}
      {&btpr-table}.bp_execcounttries = {&btpr-table}.bp_execcounttries + 1
      {&btpr-table}.bp_execuser_id    = {&btpr_user_id}
      {&btpr-table}.bp_execsysdate    = v-btpr_upd-today-{&seq}
      {&btpr-table}.bp_execsystime    = string(v-btpr_upd-time-{&seq}, 'hh:mm')
      {&btpr-table}.bp_execsystimeint = v-btpr_upd-time-{&seq}
    .
    find current {&btpr-table} no-lock .
  end. /* do transaction */
&endif


&if "{&btpr-status}" = "deleted" &then
  /* Запись обработки помечается как удаленная */
  if bpr_lprocessedok = yes then
  do transaction
  :
    find current {&btpr-table} exclusive-lock
      no-error .
    if available {&btpr-table} then do:
      assign
        {&btpr-table}.bp_status = {&btpr-deleted}
      .
    end.
    find current {&btpr-table} no-lock no-error .
  end.
&endif


&if "{&btpr-status}" = "executing_deleted" &then
  find first {&btpr-table} exclusive-lock
    where rowid({&btpr-table}) = {&btpr-rowid}
    no-error .
  if not available {&btpr-table} then do:
    message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись пересчета архива" skip
      view-as alert-box error .
    undo, return error .
  end.
  if {&btpr-table}.bp_status <> {&btpr-normal} then do:
    message
      vss-workfile vss-revision vss-description skip
      "Запись пересчета архива имеет статус, отличный от" {&btpr-normal} skip
      "BP_Type"       {&btpr-table}.BP_Type       skip
      "BP_Status"     {&btpr-table}.BP_Status     skip
      "Key#_One"      {&btpr-table}.Key#_One      skip
      "Key#_Two"      {&btpr-table}.Key#_Two      skip
      "Key#_Three"    {&btpr-table}.Key#_Three    skip
      "CharKey_One"   {&btpr-table}.CharKey_One   skip
      "CharKey_Two"   {&btpr-table}.CharKey_Two   skip
      "CharKey_Three" {&btpr-table}.CharKey_Three skip
      view-as alert-box error .
    undo, return error .
  end.
  &scop seq {&sequence}
  define variable v-btpr_upd-today-{&seq} as date      no-undo.
  define variable v-btpr_upd-time-{&seq}  as integer   no-undo.
  run cur-time in this-procedure ( output v-btpr_upd-today-{&seq}
                                 , output v-btpr_upd-time-{&seq}
                                 ).
  assign
    {&btpr-table}.bp_status         = {&btpr-deleted}
    {&btpr-table}.bp_execcounttries = {&btpr-table}.bp_execcounttries + 1
    {&btpr-table}.bp_execuser_id    = {&btpr_user_id}
    {&btpr-table}.bp_execsysdate    = v-btpr_upd-today-{&seq}
    {&btpr-table}.bp_execsystime    = string(v-btpr_upd-time-{&seq}, 'hh:mm')
    {&btpr-table}.bp_execsystimeint = v-btpr_upd-time-{&seq}
  .

&endif

/* $Workfile$   E n d */
