/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедура создания записи справочника финкодов

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

{1} -  имя файла
Creation date: 10/09/03 11:07

*/
&scoped-define vssseq {&sequence}
def var vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop create-file {1}
define buffer buf_file for {&create-file} .

{ ref/ficr-db.i }

procedure fin-code :
 do
 on error undo, return error return-value
 :
  define input  parameter p-host-code as integer no-undo .
  define output parameter p-fin-code  as integer no-undo .
  p-fin-code = next-value(s-fin-code, {&db-name_schema}) .

 end. /* do */
end procedure. /* fin-code */


procedure create-ref-fin-code :
 do
 on error undo, return error return-value
 :
define input parameter p-ver as logical no-undo . /* проверять уникальность */
define input parameter p-host-code  as integer   no-undo .
define input parameter p-fin-code   as integer   no-undo .
define input parameter p-code-value as character no-undo .
define input parameter p-descr      as character no-undo .
define input parameter p-status_    as integer   no-undo .
define input parameter p-level-1    as integer   no-undo .
define input parameter p-level-2    as integer   no-undo .
define input parameter p-level-3    as integer   no-undo .

if p-ver then do:
    find first  buf_file no-lock  where buf_file.host-code = p-host-code and
                                        buf_file.fin-code  = p-fin-code no-error .
    if available buf_file then return error .
end.

define variable p-ret as logical no-undo .
run current-db in this-procedure (
    input p-host-code,
    input p-host-code,
    output p-ret ) .

 if p-ret = no then return.

 create {&create-file}.
 assign
   {&create-file}.host-code  = p-host-code
   {&create-file}.fin-code   = p-fin-code
   {&create-file}.code-value = p-code-value
   {&create-file}.descr      = p-descr
   {&create-file}.status_    = p-status_
   {&create-file}.level-1    = p-level-1
   {&create-file}.level-2    = p-level-2
   {&create-file}.level-3    = p-level-3
  no-error .
  if error-status :error then do:
      message vss-include-info{&vssseq} skip
              error-status :get-message(1)
              view-as alert-box error .
      return error .
  end.
 end. /* do */
end procedure. /* create-ref-fin-code */

procedure create-ref-corr-acc :
 do
 on error undo, return error return-value
 :
define input parameter p-ver as logical no-undo . /* проверять уникальность */
define input parameter p-host-code  as integer   no-undo .
define input parameter p-fin-code   as integer   no-undo .
define input parameter p-code-value as character no-undo .
define input parameter p-descr      as character no-undo .
define input parameter p-status_    as integer   no-undo .
define input parameter p-level-1    as integer   no-undo .
define input parameter p-level-2    as integer   no-undo .
define input parameter p-level-3    as integer   no-undo .
define input parameter p-acc-type    as integer   no-undo .
define buffer buf_file  for ub.fin-code-cor-acc .

if p-ver then do:
    find first  buf_file no-lock  where buf_file.host-code = p-host-code and
                                        buf_file.fin-code  = p-fin-code no-error .
    if available buf_file then return error .
end.

define variable p-ret as logical no-undo .
run current-db in this-procedure (
    input p-host-code,
    input p-host-code,
    output p-ret ) .

 if p-ret = no then return.

 create ub.fin-code-cor-acc.
 assign
   ub.fin-code-cor-acc.host-code  = p-host-code
   ub.fin-code-cor-acc.fin-code   = p-fin-code
   ub.fin-code-cor-acc.code-value = p-code-value
   ub.fin-code-cor-acc.descr      = p-descr
   ub.fin-code-cor-acc.status_    = p-status_
   ub.fin-code-cor-acc.level-1    = p-level-1
   ub.fin-code-cor-acc.level-2    = p-level-2
   ub.fin-code-cor-acc.level-3    = p-level-3
   ub.fin-code-cor-acc.acc-type   = p-acc-type
  no-error .
  if error-status :error then do:
      message vss-include-info{&vssseq} skip
              error-status :get-message(1)
              view-as alert-box error .
      return error .
  end.
 end. /* do */
end procedure. /* create-ref-fin-code */
/* $Workfile$ e n d */