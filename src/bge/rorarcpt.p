block-level on error undo, throw.
/*

$Revision: f0ffd58b8bac, 1562, rls $
$Author: SMMolotkov $
$Date: Tue Nov 06 04:41:34 2018 +0300 $
$Workfile: rorarcpt.p $
$Archive: bge/rorarcpt.p $

Создание квитанции ORA взамен испорченной

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/31/09
Author: Bakhtadze Natalya
Creation date: 07/31/09

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-silent as logical no-undo .
define input parameter p-esys-id as integer no-undo .
define input parameter p-db-num as integer no-undo .
define input parameter p-espr-pack-num as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision: f0ffd58b8bac, 1562, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Tue Nov 06 04:41:34 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rorarcpt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/rorarcpt.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ bge/oxml-def.i }
{ gbl/orapreps.i }
{ rul/ora-rcpt.i proc }

DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-exch-file-date as character no-undo .
define variable v-rcpt-log-file as character no-undo .
define variable v-file-name as character no-undo .
define variable v-custom-pack-name as character no-undo .
define variable v-espr-pack-num as integer no-undo .
define variable v-espr-pack-name as character no-undo .
define variable v-source-dir as character no-undo .
define variable v-target-dir as character no-undo .
define variable v-temp-dir as character no-undo .
define variable v-log-file-name as character no-undo .
define variable v-list-file-name as character no-undo .
define variable v-custom-pack-flag as logical no-undo .
DEFINE VARIABLE v-full-path         as character    no-undo.
DEFINE VARIABLE v-file-name-no-ext  as character    no-undo.
DEFINE VARIABLE v-file-name-ext     as character    no-undo.
define variable v-path              as character    no-undo.
define variable v-cmd-proc-handle as handle no-undo .
define variable v-cmd-code as integer no-undo .
define variable v-labels as character no-undo .
define variable v-codes as character no-undo .
define variable v-err-type as character no-undo .



&scop display-message ~
     if p-silent then do: ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~).             ~
     end.                                          ~
     else do:                                      ~
       message ~{&my-message~} view-as alert-box. ~
     end

/*надо выбрать ошибку*/
assign
v-labels = {&ora-err-type-range} + {&delim-par} +
          {&ora-err-type-synchronization} + {&delim-par} +
          {&ora-err-type-null} + {&delim-par} +
          {&ora-err-type-processing} + {&delim-par} +
          {&ora-err-type-structure} + {&delim-par} +
          "NO-ERROR"
v-codes = {&ora-err-type-range} + {&delim-par} +
          {&ora-err-type-synchronization} + {&delim-par} +
          {&ora-err-type-null} + {&delim-par} +
          {&ora-err-type-processing} + {&delim-par} +
          {&ora-err-type-structure} + {&delim-par} +
          "NO-ERROR"
.

run gbl/d-list.w ( input "b-sel"
                  ,input "Выберите Тип ошибки или NO-ERROR (если ошибки нет) для отправки в квитанции"
                  ,input v-codes
                  ,input v-labels
                  ,input {&delim-par}
                  ,input '' /*ppresel-codes*/
                  ,output v-err-type) no-error.
if error-status:error
or v-err-type = ''
then do:
  return no-apply.
end.
if v-err-type = "NO-ERROR" then v-err-type = "".
run cur-time in this-procedure ( output v-today, output v-time).
v-exch-file-date = string(datetime(v-today, mtime), "99/99/9999 HH:MM:SS").
v-custom-pack-name = ''.
v-espr-pack-num = - abs(p-espr-pack-num).
run bge/espcknum.p ( input "get":U
              ,input p-esys-id
              ,input 0
              ,input integer({&esys-dm-oracle-retail})
              ,input oxml-exch-dir
              ,input oxml-heap-dir
              ,input ""
              ,input-output v-espr-pack-num
              ,input-output v-custom-pack-name
              ,output v-espr-pack-name
              ,output v-source-dir
              ,output v-target-dir
              ,output v-temp-dir
              ,output v-log-file-name
              ,output v-list-file-name
              ,output v-custom-pack-flag
            ) no-error.
  if error-status:error then do:
    run write-log in p-log-handle (
                                    input 2
                                  , substitute("&1 Ошибка при генерации номера пакета.&2&3&2&4"
                                                ,vss-workfile
                                                ,{&new-line}
                                              ,substitute( "&1", error-status:get-message(error-status:num-messages) )
                                              ,substitute( "&1", return-value )
                                              )
                    ) .
    undo , return.
  end.
  assign
  v-file-name = v-target-dir + {&back-slash-char} + v-espr-pack-name +
                (if v-custom-pack-flag
                then ''
                else 'xml')
  .
run gbl/filename.p (
                      input v-file-name
                      ,output v-full-path
                      ,output v-path
                      ,output v-file-name
                      ,output v-file-name-no-ext
                      ,output v-file-name-ext
                      ) no-error .
if error-status :error then do:
  /* исходный файл не найден, значит он еще не пришел */
  return.
end.
assign
v-rcpt-log-file = v-log-file-name + {&back-slash-char} + ora-rcpt_get-rcpt-name(v-file-name-no-ext) + ".LOG"
.

run rul/ora-rcpt.p (
                     input parparentproc
                    ,input this-procedure:handle
                    ,input p-log-handle
                    ,input v-cmd-proc-handle
                    ,input v-cmd-code
                    ,input p-esys-id
                    ,input p-espr-pack-num
                    ,input v-file-name
                    ,input v-exch-file-date
                    ,input v-rcpt-log-file
                    ,input v-err-type) no-error.
if error-status:error then do:
  &scop my-message  substitute("&1 Ошибка при генерации квитанции.&2&3&2&4" ~
                                ,vss-workfile ~
                                ,~{&new-line~}  ~
                              ,substitute( "&1", error-status:get-message(error-status:num-messages) ) ~
                              ,substitute( "&1", return-value ) ~
                              )
  {&display-message}.

end.
else do:
  &scop my-message  substitute("Квитанция для пакета &1 сформирована",  p-espr-pack-num)
  {&display-message}.

end.
