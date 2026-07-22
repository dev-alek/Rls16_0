block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: thbjexp.p $
$Archive: utl/thbjexp.p $

Экспорт настроек объектов TH, лежащих в THBJ-ATTR

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/08/08
Author: Bakhtadze Natalya
Creation date: 12/08/08

*/

define input parameter parparentproc as widget-handle no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: thbjexp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/thbjexp.p $":U .
define variable vss-description as character no-undo init "Экспорт настроек объектов TH, лежащих в THBJ-ATTR".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/tblfname.i }

define variable v-file-name as character no-undo .
define variable v-old-file-name as character no-undo .
define variable v-dir-name as character no-undo .
define variable v-yesno as logical no-undo .
define variable v-mode-log as logical no-undo .
define variable v-mode as character no-undo .
message
"Хотите экспортировать уникальное имя каждой записи (uniq-key-rec)?"
view-as alert-box question buttons yes-no-cancel update v-mode-log.
if v-mode-log = ? then return no-apply.
if v-mode-log then do:
  v-mode = "full".
end.
v-yesno = no.
  run gbl/d-file.p (
        input-output v-file-name       /* p-file-id           */
      , input-output v-dir-name        /* p-file-directory    */
      , input  (" Все файлы txt (*.txt) ") /* p-filter-names      */
      , input  ("*.txt":U)                   /* p-filter-values     */
      , input  {&comma-char}                 /* p-filter-delimiter  */
      , input  (".txt":U)                    /* p-default-extension */
      , input  no                            /* p-must-exist        */
      , input  yes                           /* p-save-as           */
      , input  yes                           /* p-use-filename      */
      , input  "Введите имя файла для экспорта"           /* p-title             */
      , output v-yesno                       /* p-choose            */
  ) no-error.
  if error-status:error
  or v-yesno = no then return no-apply.

  run export-thbj in this-procedure  (
                                 input v-file-name
                                ,input v-mode
                               ) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN DO:
     MESSAGE
     ERROR-STATUS:GET-MESSAGE(1) SKIP
     RETURN-VALUE
     VIEW-AS ALERT-BOX.
     RETURN NO-APPLY.
  END.
  define variable v-md5-signature as character no-undo .
  define variable v-full-file-name          as character                no-undo .
  define variable v-path                    as character                no-undo .
  DEFINE VARIABLE v-full-path               as character                no-undo .
  DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
  DEFINE VARIABLE v-file-name-ext           as character                no-undo .

  run gbl/md5.p ( input v-file-name
                 ,output v-md5-signature ) .
  run gbl/filename.p (
                 input v-file-name
                ,output v-full-path
                ,output v-path
                ,output v-full-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .
  if error-status:error then do:
    message
    return-value
    view-as alert-box ERROR.
    return.
  end.
  output to value(v-path + {&slash-char} + v-file-name-no-ext + ".md5").
  put unformatted v-md5-signature skip.
  output close.

procedure export-thbj :
define input parameter p-file-name as character no-undo .
define input parameter p-mode as character no-undo .


do
on error undo, return error
:


define variable v-thbj-exp-tables as character no-undo .
define variable v-thbj-exp-table-names as character no-undo .
define variable err-count as integer no-undo .
define variable rec-count as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-prepare-phrase as character no-undo .
define variable num-rec as integer no-undo .
define variable num-err as integer no-undo .

assign
v-thbj-exp-tables =  {&table_thbj-attr}
                    .
assign
v-thbj-exp-table-names = {&table_thbj-attr-full}
                        .

 /*пока не будем проверять на dynamic и тд.*/
do v-ii = 1 to num-entries( v-thbj-exp-tables, ";"):
  CASE entry(v-ii, v-thbj-exp-tables, ";"):
    otherwise do:
      v-prepare-phrase = substitute(" for each &1 ", entry(v-ii, v-thbj-exp-tables, ";")).
    end.
 END CASE.
  rec-count = num-rec.
  err-count = num-err.
  run utl/upg-exp.p ( input p-file-name
                     ,input ''
                     ,input p-mode
                     ,input (if v-ii = 1 then no else yes) /*p-append*/
                     ,input (if v-ii = 1 then yes else no) /*p-first*/
                     ,input ( if v-ii = num-entries(v-thbj-exp-tables, ";") then yes else no)
                     ,input entry(v-ii, v-thbj-exp-tables, ";")
                     ,input (if num-entries(entry(v-ii, v-thbj-exp-tables, ";")) > 1
                             then num-entries(entry(v-ii, v-thbj-exp-tables, ";"))
                             else 1)
                     ,input v-prepare-phrase /*p-prepare-phrase*/
                     ,input-output rec-count
                     ,input-output err-count

                     ) no-error.
  if not error-status:error then do:
    num-rec = rec-count.
    num-err = err-count.
  end.
end.


end.

end procedure. /* export-thbj */