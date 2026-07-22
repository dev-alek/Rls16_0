block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: clbxmlvw.p $
$Archive: gbl/clbxmlvw.p $

Просмотр clob-data типа XML просмотровщиком системы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/16/09
Author: Bakhtadze Natalya
Creation date: 07/16/09

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-descr as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: clbxmlvw.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/clbxmlvw.p $":U .
define variable vss-description as character no-undo init "Просмотр clob-data типа XML просмотровщиком системы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-report-num       as integer no-undo .
define buffer buf_clob-data for ub.clob-data.

find first buf_clob-data where
        rowid(buf_clob-data) = p-rowid.
run get-report-num in parparentproc ( output v-report-num).
v-file-name = substitute("tmp_&1.xml", v-report-num).
copy-lob object buf_clob-data.cdata
to file v-file-name no-error.
if error-status:error then do:
  message
  error-status:get-message(1)  skip
  return-value
  view-as alert-box .
  undo, return error.
end.

run gbl/filename.p (
                input v-file-name
              ,output v-full-path
              ,output v-path
              ,output v-file-name
              ,output v-file-name-no-ext
              ,output v-file-name-ext
              ) no-error .
if error-status:error then do:
  message
  error-status:get-message(1)  skip
  return-value
  view-as alert-box .
  undo, return error.
end.
run gbl/open_url.p ( input v-full-path) no-error .