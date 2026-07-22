
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание кваитанции для ВС типа Oracle Retail

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/29/09
Author: Bakhtadze Natalya
Creation date: 01/29/09

*/

using Ibs.Th.Rul.Route-data_.
block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cmd-proc-handle as handle no-undo .
define input parameter p-cmd-code  as integer no-undo .

define input parameter p-esys-id as integer no-undo .
define input parameter p-pack-num as integer no-undo .
define input parameter p-file-name as character no-undo .
define input parameter p-file-date-time as character no-undo .
define input parameter p-log-file-name as character no-undo .
define input parameter p-error-type as character no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Создание кваитанции для ВС типа Oracle Retail".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ rul/garbcoll.i }
{ gbl/cur-time.i }
{ nws/lib-nws.i }

{ rul/cl-hist.i "new shared" }
{ gbl/gate-clb.i }
{ gbl/key-rec.i }
{ bge/esysattr.i }
define variable log-file-name                as character      no-undo init "".
{ str/dia2auto.i }

{ rul/context_f.i  begin-esys-command }
{ rul/context_f.i  send-esys-command }
{ rul/context_f.i  set-custom-esys-pck-name }
{ rul/context_f.i  delete-command }

{ rul/ora-rcpt.i tt }
{ rul/ora-rcpt.i proc }

define variable p-xsd-file as character no-undo .
define variable v-last-error-message as character no-undo .
define variable v-es as logical no-undo .
define variable v-esm as character no-undo .
define variable v-rv as character no-undo .
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .

{ rul/seterror.i }


&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)





define variable ExpData1 as class Route-data_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle)
ExpData1 = new Route-data_{&constructor_1} .

run proc-main in this-procedure no-error .
if error-status:error then do:
  v-esm = error-status :get-message (1).
  v-es = error-status:error .
  v-rv = return-value .
end.
run garbcoll_clear in this-procedure .


procedure proc-main :

define variable v-custom-pack-name as character no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-log-file-name as character no-undo .

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  run cur-time in this-procedure ( output v-today, output v-time).
  v-custom-pack-name = ora-rcpt_get-rcpt-name(entry((num-entries(p-file-name, ".") - 1), p-file-name, ".")).
  if p-error-type = '' then do:
    p-xsd-file = "exe/ornercpt.xsd".
    create ne-receipt.
    assign
    ne-receipt.exch_file_name = p-file-name
    ne-receipt.exch_file_date = p-file-date-time
    ne-receipt.file_proc_date = string(datetime(v-today, mtime), "99/99/9999 HH:MM:SS")
    .
  end.
  else do:
    assign
    v-log-file-name = replace(p-log-file-name, {&slash-char}, {&back-slash-char})
    p-xsd-file = "exe/ora-rcpt.xsd"
    no-error.
    if error-status:error then do:
      undo main-block, return error substitute("Не удалось преобразовать имена файлов:&1&2"
                                               , {&new-line}
                                               , error-status:get-message(1) ) .
    end.
    create receipt.
    assign
    receipt.exch_file_name = p-file-name
    receipt.exch_file_date = p-file-date-time
    receipt.file_proc_date = string(datetime(v-today, mtime), "99/99/9999 HH:MM:SS")
    receipt.error  = p-error-type
    v-ii = num-entries(v-log-file-name, {&back-slash-char})
    receipt.prot_file_name = entry(v-ii, v-log-file-name, {&back-slash-char})
    .
  end.
  IF  ExpData1:route-data_read-xmlschema( INPUT p-xsd-file) = false  THEN do:
    undo main-block, return error v-last-error-message .
  end.
  IF  context_begin-esys-command( input string(p-esys-id), input-output v-esys-cmd-proc-handle, output v-esys-cmd-code) = false  THEN do:
    undo main-block, return error v-last-error-message .
  end.
  ExpData1:route-data_create-record( INPUT "receipt") .
  if p-error-type = '' then do:
    ExpData1:route-data_copy-record( INPUT "receipt", INPUT  (buffer ne-receipt:handle) ) .
  end.
  else do:
    ExpData1:route-data_copy-record( INPUT "receipt", INPUT  (buffer receipt:handle) ) .
  end.
  IF ExpData1:esys-add-dump( INPUT "receipt", INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
    undo main-block, return error v-last-error-message .
  end.
  &scop release_1 clear-data ( )
  ExpData1:Route-data_{&release_1} .
  IF  context_set-custom-esys-pck-name(  input v-esys-cmd-proc-handle, input v-esys-cmd-code, input v-custom-pack-name + '.ACK') = false  THEN do:
    undo main-block, return error v-last-error-message .
  end.
  IF  context_send-esys-command( input string(p-esys-id), input v-esys-cmd-proc-handle, input v-esys-cmd-code, input g#userid) = false  THEN do:
    undo main-block, return error v-last-error-message .
  end.
end.

end procedure. /* proc-main */