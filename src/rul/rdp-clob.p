block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Привязка и отвязка clob от ruledict-param

Автор: Бахтадзе Наталья Викторовна
Дата создания: 01/11/08
Author: Bakhtadze Natalya
Creation date: 01/11/08

*/

define parameter buffer buf_ruledict-param for ub.ruledict-param.
define input parameter p-mode as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Привязка и отвязка clob от ruledict-param".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-clob-uniq-key-rec as character no-undo .
define variable v-clob-db-num as integer   no-undo init ?.
define variable v-int64-id as integer   no-undo init 0.
define variable v-part-num as integer   no-undo init 1.
define variable v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-md5-signature           as character no-undo .
define variable v-mode as character no-undo .
define buffer buf_clob-data for ub.clob-data.
define buffer buf_clob-bind for ub.clob-bind.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  assign
  v-clob-uniq-key-rec = buf_ruledict-param.init-value-character
  .
  case p-mode:
    when {&add-def}
    or
    when {&update} then do:
      if new(buf_ruledict-param) then v-mode = {&add-def}.
      else v-mode = {&update}.
      if v-mode = {&add-def} then do:
        find first buf_clob-bind no-lock where
                  buf_clob-bind.resource-type = {&lob-res-gate}
             and  buf_clob-bind.uniq-key-rec = v-clob-uniq-key-rec
             and buf_clob-bind.field-name = '':U
             and buf_clob-bind.part-num = 1 no-error.
        if available buf_clob-bind then do:
          v-mode = {&update}.
        end.
      end.
      run gbl/file2clb.p ( input v-mode
                          ,input "override" /*p-clob-mode*/
                          ,input ? /*p-bh*/
                          ,input v-clob-uniq-key-rec
                          ,input '':U /*p-field-*/
                          ,input (buf_ruledict-param.param-label + {&space-char} + buf_ruledict-param.documentation)
                          ,input-output v-part-num
                          ,input {&lob-res-gate} /*p-resource-type*/
                          ,input-output v-clob-db-num
                          ,input-output v-int64-id
                          ,input buf_ruledict-param.init-value-character
                          ,input ? /*p-src-encoding*/
                          ) no-error .
      if error-status :error then do:
        if not new(buf_ruledict-param)
        and p-mode = {&update}
        then do:
          run gbl/filename.p (
                          input buf_ruledict-param.init-value-character
                        ,output v-full-path
                        ,output v-path
                        ,output v-file-name
                        ,output v-file-name-no-ext
                        ,output v-file-name-ext
                        ) no-error .
          if error-status:error then do:
            undo main-block, return error substitute("Не удается найти файл &1",buf_ruledict-param.init-value-character).
          end.
          run gbl/md5.p (
                                  input  v-full-path    /* p-file-name     */
                                  ,output v-md5-signature /* p-md5-signature */
                                  ) no-error .
          if error-status:error then do:
            undo, return error substitute("&1 &2 &3&4&5&4&6"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,{&new-line}
                                          , error-status:get-message(1)
                                          , return-value ).

          end.
          find first buf_clob-data no-lock where
                     buf_clob-data.file-name_ = buf_ruledict-param.init-value-character
                 and buf_clob-data.crc-field > '':U
                     no-error.
          if not available buf_clob-data
          or buf_clob-data.crc-field <> v-md5-signature
          then do:
            run gbl/file2clb.p ( input {&add-def}
                                ,input "add-new" /*p-clob-mode*/
                                ,input ? /*p-bh*/
                                ,input v-clob-uniq-key-rec
                                ,input '':U /*p-field-*/
                                ,input (buf_ruledict-param.param-label + {&space-char} + buf_ruledict-param.documentation)
                                ,input-output v-part-num
                                ,input {&lob-res-gate} /*p-resource-type*/
                                ,input-output v-clob-db-num
                                ,input-output v-int64-id
                                ,input buf_ruledict-param.init-value-character
                                ,input ? /*p-src-encoding*/
                                ) no-error .
            if error-status:error then do:
              undo main-block, return error return-value .
            end.
          end.
        end.
        else do:
          undo main-block, return error return-value .
        end.
      end.
    end.
    when {&deletion} then do:
      run gbl/file2clb.p ( input {&deletion}
                          ,input "leave" /*p-clob-mode*/
                          ,input ? /*p-bh*/
                          ,input v-clob-uniq-key-rec
                          ,input '':U /*p-field-*/
                          ,input '':U
                          ,input-output v-part-num
                          ,input {&lob-res-gate} /*p-resource-type*/
                          ,input-output v-clob-db-num
                          ,input-output v-int64-id
                          ,input buf_ruledict-param.init-value-character
                          ,input ? /*p-src-encoding*/
                          ) no-error .
      if error-status :error then do:
        return error return-value .
      end.
    end.
  end case.
end.