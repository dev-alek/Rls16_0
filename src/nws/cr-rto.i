/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание записи esys-route

Автор: Белоусов Илья Александрович
Дата создания: 06/13/06
Author: Ilia Belousov
Creation date: 06/13/06

Input:

Output:

*/

&if defined( cr-rt-log-db-name ) = 0 &then
  &scop cr-rt-log-db-name ub
&endif


&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

define variable v-msg#{&vssseq}         as character no-undo .
define variable v-lock#{&vssseq}        as logical   no-undo .
define variable v-ok#{&vssseq}          as logical   no-undo .
define variable v-cur-db-num#{&vssseq}  as integer      no-undo.

/*define buffer buf{&vssseq}_db for {&cr-rt-log-db-name}.db .*/
define buffer buf{&vssseq}_ext-system for {&cr-rt-log-db-name}.ext-system .

find first buf{&vssseq}_ext-system no-lock
  where buf{&vssseq}_ext-system.esys-id = {&esr-esys-id}
    and buf{&vssseq}_ext-system.db-num = {&esr-db-num}
  no-error
.
if not available buf{&vssseq}_ext-system then do:
  message
    vss-include-info{&vssseq} skip
    vss-workfile vss-revision vss-description skip
    substitute( "Попытка создать маршрутизацию на несуществующую внешнюю систему &1 для БД &2", {&esr-esys-id}, {&esr-db-num} ) skip
    return-value skip
    error-status :get-message ( error-status :num-messages )
    view-as alert-box error
  .
end.
if {&esr-cr-db-num} <> buf{&vssseq}_ext-system.esys-db-num-exp and buf{&vssseq}_ext-system.esys-db-num-exp <> 0 then do:
  message
    vss-include-info{&vssseq} skip
    vss-workfile vss-revision vss-description skip
    substitute( "Попытка создать маршрутизацию на ВС &1 для БД &2,&3" +
                "в БД &4,&3" +
                "как БД экспорта указана БД &5"
                , {&esr-esys-id}
                , {&esr-db-num}
                , {&new-line}
                , {&esr-cr-db-num}
                , buf{&vssseq}_ext-system.esys-db-num-exp
                ) skip
    return-value skip
    error-status :get-message ( error-status :num-messages )
    view-as alert-box error
  .

end.

  &if "{&cr-rt-log-db-name}":U <> "ub":U &then
    disable triggers for load of {&cr-rt-log-db-name}.esys-route .
  &endif
  create {&cr-rt-log-db-name}.esys-route .
  assign
    {&cr-rt-log-db-name}.esys-route.esr-name-rec     = {&esr-name-rec}
    &if "{&cr-rt-log-db-name}":U <> "ub":U &then
      {&cr-rt-log-db-name}.esys-route.esr-tbl-ord = next-value( s-news-ord, {&cr-rt-log-db-name} )
    &else
      {&cr-rt-log-db-name}.esys-route.esr-tbl-ord = next-value( s-news-ord, {&db-name_schema} )
    &endif
    {&cr-rt-log-db-name}.esys-route.esr-last-pack    = -1
    {&cr-rt-log-db-name}.esys-route.esys-id          = {&esr-esys-id}
    {&cr-rt-log-db-name}.esys-route.db-num           = {&esr-db-num}
    {&cr-rt-log-db-name}.esys-route.esr-status       = 0
    {&cr-rt-log-db-name}.esys-route.esr-cr-db-num    = {&esr-cr-db-num}
    {&cr-rt-log-db-name}.esys-route.esr-dump-ord     = {&esr-dump-ord}
    {&cr-rt-log-db-name}.esys-route.esr-uniq-key-rec = {&esr-uniq-key-rec}
    {&cr-rt-log-db-name}.esys-route.uniq-gate-rec    = {&esr-uniq-gate-rec}
    {&cr-rt-log-db-name}.esys-route.esr-num-dump     = {&esr-num-dump}
    {&cr-rt-log-db-name}.esys-route.esr-action       = {&esr-action}
    {&cr-rt-log-db-name}.esys-route.esr-oper         = {&esr-oper}
    .
  &if defined( esr-CreDate ) <> 0 &then
    assign
      {&cr-rt-log-db-name}.esys-route.esr-CreDate      = {&esr-CreDate}
    .
  &endif
  &if defined( esr-CreTimeInt ) <> 0 &then
    assign
      {&cr-rt-log-db-name}.esys-route.esr-CreTimeInt   = {&esr-CreTimeInt}
      {&cr-rt-log-db-name}.esys-route.esr-CreTime      = string({&esr-CreTimeInt},"HH:MM:SS":U)
    .
  &endif
  &if defined( esr-CreUserName ) <> 0 &then
    assign
      {&cr-rt-log-db-name}.esys-route.esr-CreUserName  = {&esr-CreUserName}
    .
  &endif

/* $Workfile$ e n d */