block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: d-file.p $
$Archive: gbl/d-file.p $

Диалог выбора файла ввода и вывода

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

define input-output parameter p-file-id           as character no-undo .
define input-output parameter p-file-directory    as character no-undo .
define input        parameter p-filter-names      as character no-undo .
define input        parameter p-filter-values     as character no-undo .
define input        parameter p-filter-delimiter  as character no-undo .
define input        parameter p-default-extension as character no-undo .
define input        parameter p-must-exist        as logical   no-undo .
define input        parameter p-save-as           as logical   no-undo .
define input        parameter p-use-filename      as logical   no-undo .
define input        parameter p-title             as character no-undo .
define output       parameter p-choose            as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: d-file.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/d-file.p $":U .
define variable vss-description as character no-undo init "Диалог выбора файла ввода и вывода   ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-filter-name as character no-undo extent 10 .
define variable v-filter-value as character no-undo extent 10 .

DEFINE VARIABLE ii as integer no-undo .

&scop filters     filters v-filter-name[1] v-filter-value[1] , ~
                  v-filter-name[2] v-filter-value[2] , ~
                  v-filter-name[3] v-filter-value[3] , ~
                  v-filter-name[4] v-filter-value[4] , ~
                  v-filter-name[5] v-filter-value[5] , ~
                  v-filter-name[6] v-filter-value[6] , ~
                  v-filter-name[7] v-filter-value[7] , ~
                  v-filter-name[8] v-filter-value[8] , ~
                  v-filter-name[9] v-filter-value[9] , ~
                  v-filter-name[10] v-filter-value[10]

do ii = 1 to num-entries(p-filter-names, p-filter-delimiter):
  assign
  v-filter-name[ii] = entry(ii, p-filter-names, p-filter-delimiter)
  v-filter-value[ii] = entry(ii, p-filter-values, p-filter-delimiter)
  no-error.
end.


if p-must-exist then do:
  if p-save-as then do:
    if p-use-filename then do:
      SYSTEM-DIALOG GET-FILE p-file-id
      {&filters}
      INITIAL-FILTER 1
      ASK-OVERWRITE
      DEFAULT-EXTENSION p-default-extension
      INITIAL-DIR p-file-directory
      MUST-EXIST
      SAVE-AS
      TITLE p-title
      USE-FILENAME
      UPDATE p-choose .
    end.
    else do:
      SYSTEM-DIALOG GET-FILE p-file-id
      {&filters}
      INITIAL-FILTER 1
      ASK-OVERWRITE
      DEFAULT-EXTENSION p-default-extension
      INITIAL-DIR p-file-directory
      MUST-EXIST
      SAVE-AS
      TITLE p-title
      UPDATE p-choose .
    end.
  end.
  else do:
    if p-use-filename then do:
      SYSTEM-DIALOG GET-FILE p-file-id
      {&filters}
      INITIAL-FILTER 1
      ASK-OVERWRITE
      DEFAULT-EXTENSION p-default-extension
      INITIAL-DIR p-file-directory
      MUST-EXIST
      TITLE p-title
      USE-FILENAME
      UPDATE p-choose .
    end.
    else do:
      SYSTEM-DIALOG GET-FILE p-file-id
      {&filters}
      INITIAL-FILTER 1
      ASK-OVERWRITE
      DEFAULT-EXTENSION p-default-extension
      INITIAL-DIR p-file-directory
      MUST-EXIST
      TITLE p-title
      UPDATE p-choose .
    end.
  end.
end.
else do:
  if p-save-as then do:
    if p-use-filename then do:
      SYSTEM-DIALOG GET-FILE p-file-id
      {&filters}
      INITIAL-FILTER 1
      ASK-OVERWRITE
      DEFAULT-EXTENSION p-default-extension
      INITIAL-DIR p-file-directory
      SAVE-AS
      TITLE p-title
      USE-FILENAME
      UPDATE p-choose .
    end.
    else do:
      SYSTEM-DIALOG GET-FILE p-file-id
      {&filters}
      INITIAL-FILTER 1
      ASK-OVERWRITE
      DEFAULT-EXTENSION p-default-extension
      INITIAL-DIR p-file-directory
      SAVE-AS
      TITLE p-title
      UPDATE p-choose .
    end.
  end.
  else do:
    if p-use-filename then do:
      SYSTEM-DIALOG GET-FILE p-file-id
      {&filters}
      INITIAL-FILTER 1
      ASK-OVERWRITE
      DEFAULT-EXTENSION p-default-extension
      INITIAL-DIR p-file-directory
      TITLE p-title
      USE-FILENAME
      UPDATE p-choose .
    end.
    else do:
      SYSTEM-DIALOG GET-FILE p-file-id
      {&filters}
      INITIAL-FILTER 1
      ASK-OVERWRITE
      DEFAULT-EXTENSION p-default-extension
      INITIAL-DIR p-file-directory
      TITLE p-title
      UPDATE p-choose .
    end.
  end.
end.


if not p-choose then do:
  assign
    p-file-id = ''
  .
end.