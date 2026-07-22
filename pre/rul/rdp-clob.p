block-level on error undo, throw.
define parameter buffer buf_ruledict-param for ub.ruledict-param.
define input parameter p-mode as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Ïğèâÿçêà è îòâÿçêà clob îò ruledict-param".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  assign
  v-clob-uniq-key-rec = buf_ruledict-param.init-value-character
  .
  case p-mode:
    when 'ÄÎÁÀÂËÅÍÈÅ':U
    or
    when 'ÈÇÌÅÍÅÍÈÅ':U then do:
      if new(buf_ruledict-param) then v-mode = 'ÄÎÁÀÂËÅÍÈÅ':U.
      else v-mode = 'ÈÇÌÅÍÅÍÈÅ':U.
      if v-mode = 'ÄÎÁÀÂËÅÍÈÅ':U then do:
        find first buf_clob-bind no-lock where
                  buf_clob-bind.resource-type = 'gate':U
             and  buf_clob-bind.uniq-key-rec = v-clob-uniq-key-rec
             and buf_clob-bind.field-name = '':U
             and buf_clob-bind.part-num = 1 no-error.
        if available buf_clob-bind then do:
          v-mode = 'ÈÇÌÅÍÅÍÈÅ':U.
        end.
      end.
      run gbl/file2clb.p ( input v-mode
                          ,input "override"
                          ,input ?
                          ,input v-clob-uniq-key-rec
                          ,input '':U
                          ,input (buf_ruledict-param.param-label + chr(32) + buf_ruledict-param.documentation)
                          ,input-output v-part-num
                          ,input 'gate':U
                          ,input-output v-clob-db-num
                          ,input-output v-int64-id
                          ,input buf_ruledict-param.init-value-character
                          ,input ?
                          ) no-error .
      if error-status :error then do:
        if not new(buf_ruledict-param)
        and p-mode = 'ÈÇÌÅÍÅÍÈÅ':U
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
            undo main-block, return error substitute("Íå óäàåòñÿ íàéòè ôàéë &1",buf_ruledict-param.init-value-character).
          end.
          run gbl/md5.p (
                                  input  v-full-path
                                  ,output v-md5-signature
                                  ) no-error .
          if error-status:error then do:
            undo, return error substitute("&1 &2 &3&4&5&4&6"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,chr(10)
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
            run gbl/file2clb.p ( input 'ÄÎÁÀÂËÅÍÈÅ':U
                                ,input "add-new"
                                ,input ?
                                ,input v-clob-uniq-key-rec
                                ,input '':U
                                ,input (buf_ruledict-param.param-label + chr(32) + buf_ruledict-param.documentation)
                                ,input-output v-part-num
                                ,input 'gate':U
                                ,input-output v-clob-db-num
                                ,input-output v-int64-id
                                ,input buf_ruledict-param.init-value-character
                                ,input ?
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
    when 'óäàëåíèå':U then do:
      run gbl/file2clb.p ( input 'óäàëåíèå':U
                          ,input "leave"
                          ,input ?
                          ,input v-clob-uniq-key-rec
                          ,input '':U
                          ,input '':U
                          ,input-output v-part-num
                          ,input 'gate':U
                          ,input-output v-clob-db-num
                          ,input-output v-int64-id
                          ,input buf_ruledict-param.init-value-character
                          ,input ?
                          ) no-error .
      if error-status :error then do:
        return error return-value .
      end.
    end.
  end case.
end.
