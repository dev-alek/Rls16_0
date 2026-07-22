block-level on error undo, throw.
define input parameter p-file-name as character no-undo .
define input parameter p-old-file-name as character no-undo .
define input parameter p-mode as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exdisrul.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/exdisrul.p $":U .
define variable vss-description as character no-undo init "Экспорт конфигурации rule-машины в формате СПН".
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
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-dr-version :
define output parameter p-check as logical no-undo .
define variable v-dopi1 as integer no-undo .
define variable v-dopi2 as integer no-undo .
define variable v-dopi3 as integer no-undo .
define variable v-dopi4 as integer no-undo .
define buffer buf_dis-rule for ub.dis-rule .
  do
  on error undo, return error
  :
    find first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = 0 no-error .
    if (not available buf_dis-rule
    or buf_dis-rule.des <> "v16_0.1" )
    then do:
      assign
      v-dopi1 = integer(entry(2, buf_Dis-rule.des, "."))
      v-dopi2 = integer(entry(2, "v16_0.1", "."))
      v-dopi3 = integer(entry(2, entry(1, buf_Dis-rule.des, "."), "_"))
      v-dopi4 = integer(entry(2, entry(1, "v16_0.1", "."), "_"))
      no-error .
      if error-status:error
      or v-dopi2 > v-dopi1
      or v-dopi4 > v-dopi3
      or left-trim(entry(1, buf_Dis-rule.des, "."), "v":U) < "15"
      then do:
        assign
        p-check = yes.
      end.
    end.
  end.
end procedure.
procedure get-dr-version :
define output parameter p-dr-version as character no-undo init ?.
define buffer buf_dis-rule for ub.dis-rule .
do
on error undo, return error
:
  find first buf_dis-rule no-lock where
            buf_dis-rule.rule-num = 0 no-error .
  if available buf_dis-rule then do:
      p-dr-version = buf_dis-rule.des.
  end.
end.
end procedure.
define temp-table temp-drt-prop no-undo like ub.drt-prop.
procedure disrules-fill-properties:
define input  parameter p-templ-rl-root as integer   no-undo .
define buffer buf_drt-prop for ub.drt-prop.
define buffer buf_temp-drt-prop for temp-drt-prop.
do
on error undo, return error return-value
:
  for each buf_temp-drt-prop:
    delete buf_temp-drt-prop.
  end.
  for each buf_drt-prop where buf_drt-prop.templ-rl-root = p-templ-rl-root:
    create buf_temp-drt-prop.
    buffer-copy buf_drt-prop to buf_temp-drt-prop.
  end.
end.
end procedure.
~
define variable v-dis-exp-tables as character no-undo .
define variable v-dis-exp-table-names as character no-undo .
define variable err-count as integer no-undo .
define variable rec-count as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-prepare-phrase as character no-undo .
define variable num-rec as integer no-undo .
define variable num-err as integer no-undo .
assign
v-dis-exp-tables =  'dis-rule':U +
                    chr(44) + 'dis-cfg-rule':U +
                    chr(44) + 'dis-time-rule':U +
                    chr(44) + 'drt-prop':U
                    .
assign
v-dis-exp-table-names = 'правила скидок':U +
                        chr(44) + 'Связи dis-rule':U +
                        chr(44) + 'расписания':U +
                        chr(44) + 'Св-ва правил скижок и распис.':U
                        .
do v-ii = 1 to num-entries( v-dis-exp-tables):
  CASE entry(v-ii, v-dis-exp-tables):
    when 'dis-rule':U
    then do:
      v-prepare-phrase = substitute(" for each &1 where &1.rule-num <= &2 "
                                    , entry(v-ii, v-dis-exp-tables)
                                    , 99999
                                    ).
    end.
    when 'dis-time-rule':U then do:
      v-prepare-phrase = substitute(" for each &1 where &1.time-rule-num <= &2 "
                                    , entry(v-ii, v-dis-exp-tables)
                                    , 99999
                                    ).
    end.
    otherwise do:
      v-prepare-phrase = substitute(" for each &1 ", entry(v-ii, v-dis-exp-tables)).
    end.
  end case.
  rec-count = num-rec.
  err-count = num-err.
  run utl/upg-exp.p ( input p-file-name
                     ,input p-old-file-name
                     ,input p-mode
                     ,input (if v-ii = 1 then no else yes)
                     ,input (if v-ii = 1 then yes else no)
                     ,input ( if v-ii = num-entries(v-dis-exp-tables) then yes else no)
                     ,input entry(v-ii, v-dis-exp-tables)
                     ,input 1
                     ,input v-prepare-phrase
                     ,input-output rec-count
                     ,input-output err-count
                     ) no-error.
  if not error-status:error then do:
    num-rec = rec-count.
    num-err = err-count.
  end.
end.
