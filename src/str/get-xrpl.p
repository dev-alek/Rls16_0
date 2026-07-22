block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: get-xrpl.p $
$Archive: str/get-xrpl.p $

Получение REPLY с касс XML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 06/22/04
Author: Bakhtadze Natalya
Creation date: 06/22/04

*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-pos-type as character no-undo .
define input parameter p-encoding as character no-undo .
DEFINE INPUT PARAMETER file_ as character no-undo.
define input parameter p-spool-or-data as character no-undo .
define input-output parameter p-view-log as logical  no-undo .
define output parameter p-need-save as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: get-xrpl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/get-xrpl.p $":U .
define variable vss-description as character no-undo init "Получение REPLY с касс XML".

{ cmp/vssrevis.i }

{ cmp/trg-def.i }

{ gbl/xmlparse.i }
{ gbl/xmlvalid.i }
define stream stmXMLOut.
{ str/cd-xml.i }
{ cmp/bitoper.i }

DEFINE VARIABLE var-file-line-num          as   integer               no-undo .
DEFINE VARIABLE v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define stream chkstream.
define variable log-file-name as character no-undo init "send-cd.txt":U.
define variable v-exit-processing as logical no-undo .
{ str/cd-xmlg.i data spool }

if p-spool-or-data = "config"
or p-spool-or-data = "control" then do:
  p-need-save = yes.
  if lookup("cb_set-log-file-name", this-procedure:instantiating-procedure:internal-entries) > 0 then do:
    run cb_set-log-file-name in  (this-procedure:instantiating-procedure) ( output log-file-name) no-error.
  end.
end.

process events.
RUN get-xml-ibm-c(input file_) no-error .
if error-status :error
then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!Ошибка при обработке файла &1: &2"
                            , file_
                            , return-value
                          )
                                         ).
  assign
  p-view-log = yes
  .
  undo, return .
end.
if v-num-errors > 0 then do:
  assign
  p-need-save = yes
  .
end.