block-level on error undo, throw.
define input parameter c-p as character no-undo .
define input parameter g#report-num as integer no-undo .
define output parameter flt-rec as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: flt-put.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/flt-put.p $":U .
define variable vss-description as character no-undo init "Сохраняет условие выборки фильтра во временные файлы".
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
    assign
      p-vss-parameters = substitute('&1|&2',c-p, g#report-num)
    .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable ii as integer no-undo.
define variable jj as integer no-undo.
assign
  flt-rec = ?
.
if num-entries(c-p, chr(4)) > 1 then do:
  assign
  c-p        = entry(1, c-p, chr(4))
  .
end.
find ubflt.usr-flt no-lock
  where ubflt.usr-flt.user-name = g#userid
    and ubflt.usr-flt.call-point = c-p
  no-error .
if available ubflt.usr-flt then do:
  find ubflt.filter no-lock
    where ubflt.filter.call-point = ubflt.usr-flt.call-point
      and ubflt.filter.naim       = ubflt.usr-flt.naim
    no-error .
  if available ubflt.filter then do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-flt-put-ind1 as integer   no-undo .
define variable v-flt-put-ind-sort1 as integer   no-undo .
output to value(string(g#report-num) + ".whr").
put .
if num-entries(ubflt.filter.where-ysl) > 0 then do:
   put unformatted 'and ('.
   do v-flt-put-ind1 = 1 to num-entries(ubflt.filter.where-ysl):
     put unformatted entry(v-flt-put-ind1, ubflt.filter.where-ysl) skip.
   end.
   put unformatted ')'.
end.
output close.
output to value(string(g#report-num) + ".srt").
put .
do v-flt-put-ind1 = 1 to num-entries(ubflt.filter.fields-sort):
   if  entry(v-flt-put-ind1, ubflt.filter.fields-sort) <> "" then do:
       do v-flt-put-ind-sort1 = 1 to num-entries(entry(v-flt-put-ind1, ubflt.filter.fields-sort),'*'):
            put  unformatted " by " + entry(v-flt-put-ind-sort1,entry(v-flt-put-ind1, ubflt.filter.fields-sort),'*').
            if entry(v-flt-put-ind1, ubflt.filter.lst-cend) = '1' then put " descending".
        end.
   end.
end.
output close.
    assign
      flt-rec = recid (ubflt.filter)
    .
  end.
  else do:
    assign
      flt-rec = ?
    .
  end.
end.
else do:
  assign
    flt-rec = ?
  .
end.
if flt-rec = ? then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
output to value(string(g#report-num) + ".whr") .
put.
output close.
output to value(string(g#report-num) + ".srt"). .
put.
output close.
end.
