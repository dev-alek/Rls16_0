block-level on error undo, throw.
define input parameter p-file-name as character no-undo .
define input parameter p-old-file-name as character no-undo .
define input parameter p-mode as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: export-current-gate.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/export-current-gate.p $":U .
define variable vss-description as character no-undo init "Экспорт конфигурации gate в формате СПН".
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
define variable v-gate-exp-tables as character no-undo .
define variable v-gate-exp-table-names as character no-undo .
define variable err-count as integer no-undo .
define variable rec-count as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-prepare-phrase as character no-undo .
define variable num-rec as integer no-undo .
define variable num-err as integer no-undo .
assign
v-gate-exp-tables =  'clob-bind':U +
                    ";" + ('clob-bind':U + chr(44) + 'clob-data':U) +
                    ";" + ('clob-bind':U + chr(44) + 'clob-bind':U)
                    .
assign
v-gate-exp-table-names = 'Связка clob с владельцем':U +
                        ";" + 'CLOB-data':U +
                        ";" + 'Связка clob с владельцем':U
                        .
do v-ii = 1 to num-entries( v-gate-exp-tables, ";"):
  CASE entry(v-ii, v-gate-exp-tables, ";"):
    when 'clob-bind':U then do:
      v-prepare-phrase = substitute(" for each &1 where &1.resource-type = '&2' and &1.db-num = 0 and &1.int64-id > 0 by &1.field-name_"
                                    , entry(v-ii, v-gate-exp-tables, ";")
                                    , 'gate':U).
    end.
    when ('clob-bind':U + chr(44) + 'clob-data':U) then do:
      v-prepare-phrase = substitute(" for each clob-bind where clob-bind.resource-type = '&1', first &2 where " +
                                    " &2.db-num = clob-bind.db-num   and &2.int64-id = clob-bind.int64-id  by clob-bind.uniq-key-rec"
                                    , 'gate':U
                                    ,entry(2, entry(v-ii, v-gate-exp-tables, ";"))).
    end.
    when ('clob-bind':U + chr(44) + 'clob-bind':U) then do:
      v-prepare-phrase = substitute(" for each &1 where &1.db-num = 0 and &1.int64-id = 0 ", entry(1, entry(v-ii, v-gate-exp-tables, ";"))).
      entry(v-ii, v-gate-exp-tables, ";") = entry(1, entry(v-ii, v-gate-exp-tables, ";")).
    end.
    otherwise do:
      v-prepare-phrase = substitute(" for each &1 ", entry(v-ii, v-gate-exp-tables, ";")).
    end.
 END CASE.
  rec-count = num-rec.
  err-count = num-err.
  run utl/upg-exp.p ( input p-file-name
                     ,input p-old-file-name
                     ,input p-mode
                     ,input (if v-ii = 1 then no else yes)
                     ,input (if v-ii = 1 then yes else no)
                     ,input ( if v-ii = num-entries(v-gate-exp-tables, ";") then yes else no)
                     ,input entry(v-ii, v-gate-exp-tables, ";")
                     ,input (if num-entries(entry(v-ii, v-gate-exp-tables, ";")) > 1
                             then num-entries(entry(v-ii, v-gate-exp-tables, ";"))
                             else 1)
                     ,input v-prepare-phrase
                     ,input-output rec-count
                     ,input-output err-count
                     ) no-error.
  if not error-status:error then do:
    num-rec = rec-count.
    num-err = err-count.
  end.
end.
