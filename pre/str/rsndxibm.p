block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rsndxibm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rsndxibm.p $":U .
define variable vss-description as character no-undo init "Утилита досылки файлов на кассу IBm-XML".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fname                        as character      no-undo .
define variable out                          as character      no-undo .
define variable out2                          as character      no-undo .
DEFINE VARIABLE in_                          as character      no-undo .
DEFINE VARIABLE spl                          as character      no-undo .
DEFINE VARIABLE sav                          as character      no-undo .
DEFINE VARIABLE v-remote                     as character      no-undo .
DEFINE VARIABLE start-paket                  as logical init yes no-undo .
define variable cr as integer no-undo.
define variable Cash-OS2                    as logical        no-undo .
define variable Cash-DOS                     as logical        no-undo .
define variable BadFlag                      as logical        no-undo .
define variable os-er                        as integer        no-undo .
DEFINE VARIABLE OS2-time                     as character      no-undo .
define variable glog as logical no-undo .
define variable log-file-name                as character      no-undo init "send-cd.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable v-md5-signature              as character      no-undo .
define variable v-cd-list-update             as character no-undo .
define variable v-cd-list-delete             as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define stream   IBMStream .
define temp-table temp-cd no-undo like ub.cash-desk .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure alienini-getkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define output parameter o-value as char.
define variable EntryPointer as integer no-undo.
define variable mem1 as memptr no-undo.
define variable mem2 as memptr no-undo.
define variable mem1size as integer no-undo.
define variable mem2size as integer no-undo.
define variable ii       as integer    no-undo.
define variable cbReturnSize  as integer    no-undo.
assign
set-size(mem1)  = 4000
mem1size = 4000.
if i-key = "" then EntryPointer = 0.
else do:
  assign
  set-size(mem2) = 128
  mem2size = 128
  EntryPointer = get-pointer-value(mem2)
  put-string(mem2, 1) = i-key.
end.
run getprivateprofilestringA
                              (i-section,
                               EntryPointer,
                               "",
                               get-pointer-value(mem1),
                               input mem1size,
                               i-filename,
                               output cbReturnSize).
do ii = 1 to cbReturnSize:
  o-value = if (get-byte(mem1, ii) = 0 and ii ne cbReturnSize)
               then o-value + ","
               else o-value + chr(get-byte(mem1, ii)).
end.
  set-size(mem1) = 0.
  set-size(mem2) = 0.
end procedure.
procedure alienini-putkey :
define input parameter i-filename as char.
define input parameter i-section as char.
define input parameter i-key as char.
define input parameter i-value as char.
define variable cbReturnSize as integer.
run writeprivateprofilestringA
                               (i-section,
                                i-key,
                                i-value,
                                i-filename,
                                output cbReturnSize ).
end procedure.
PROCEDURE GetPrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection     AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry       AS LONG.
  DEFINE INPUT  PARAMETER lpszDefault     AS CHAR.
  DEFINE INPUT  PARAMETER memBuffer       AS LONG.
  DEFINE INPUT  PARAMETER cbReturnBuffer  AS LONG.
  DEFINE INPUT  PARAMETER lpszFilename    AS CHAR.
  DEFINE RETURN PARAMETER cbReturnedChars AS LONG.
END PROCEDURE.
PROCEDURE WritePrivateProfileStringA EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER lpszSection  AS CHAR.
  DEFINE INPUT  PARAMETER lpszEntry    AS CHAR.
  DEFINE INPUT  PARAMETER lpszString   AS CHAR.
  DEFINE INPUT  PARAMETER lpszFilename AS CHAR.
  DEFINE RETURN PARAMETER lpszValue    AS LONG.
END PROCEDURE.
define   temp-table temp-tekka-tsk no-undo
field filename      as character
field obj-num       as integer
field obj-name      as character
field num-records   as integer
field max-records   as integer
field min-plu       as integer
field max-plu       as integer
field num-fields    as integer
field task-num      as character
field by-record     as logical
field send-get      as character
field cash-num      as integer
field cash-num-char as character
field port-num      as character
field way           as character
field is-script     as logical
field pswd          as character
field waiting-sek   as integer
field other-info    as character
field order-num     as integer
field secondary     as integer
field shift-fields  as integer
field binary        as logical
field range         as integer
index pi is unique primary
filename
range
index lpi
filename
min-plu
index gpi
filename
max-plu
index iorder
order-num
.
define   temp-table temp-tekka-schema no-undo
field obj-num as integer
field obj-name as character
field field-num as integer
field field-name as character
field num-records as integer
field size_ as integer
field host as character
field progress-type as character
field custom-type as character
field start-pos as integer
field end-pos as integer
field bin-group as character
index pi is unique primary
host obj-num field-num
.
define temp-table temp-tekka-record no-undo
field obj-num as integer
field plu as integer
field body as character
field shift as integer
index pi is unique primary obj-num plu.
FUNCTION tekka-is-closed-shift-journal returns integer ( input p-journal-num as integer ):
define variable v-is-closed-shift-journal as integer no-undo .
assign
v-is-closed-shift-journal = (if lookup( string( p-journal-num), '30,31,32,33':U) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  '43':U) > 0 then 1 else 0)
                            +
                            (if lookup( string( p-journal-num),  '17':U) > 0 then 1 else 0)
.
return v-is-closed-shift-journal.
END FUNCTION.
FUNCTION tekka-is-first-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-first-journal as logical no-undo .
assign
v-is-first-journal = (p-journal-num =  integer(entry(1, '30,31,32,33':U)))
                  or (p-journal-num = integer(entry(1, '26,27,28,29':U)))
                  or (p-journal-num =  integer(entry(1, '17':U)))
                  or (p-journal-num = integer(entry(1, '16':U)))
.
return v-is-first-journal.
END FUNCTION.
FUNCTION tekka-is-petrol-journal returns logical ( input p-journal-num as integer ) :
define variable v-is-petrol-journal as logical no-undo .
assign
v-is-petrol-journal = lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0.
return v-is-petrol-journal.
END FUNCTION.
FUNCTION tekka-get-max-journal-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0
                    then 1489
                    else 2340).
return v-max-record-num.
END FUNCTION.
FUNCTION tekka-get-max-record-num returns integer ( input p-journal-num as integer ) :
define variable v-max-record-num as integer no-undo .
assign
v-max-record-num = (if lookup(string(p-journal-num), '26,27,28,29,30,31,32,33':U) > 0
                    then 1489 * num-entries('30,31,32,33':U)
                    else 2340 * num-entries('17':U)).
return v-max-record-num.
END FUNCTION.
FUNCTION tekka-num-recs returns integer( input p-journal-num as integer
                                        ,input p-rec-no as integer):
define variable v-num-recs as integer no-undo .
if tekka-is-petrol-journal (p-journal-num) then do:
  if tekka-is-closed-shift-journal(p-journal-num) = 1 then do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, '30,31,32,33':U))) * 1489 + p-rec-no
    .
  end.
  else do:
    assign
    v-num-recs = (p-journal-num - integer(entry(1, '26,27,28,29':U)) ) * 1489 + p-rec-no
    .
  end.
end.
else do:
  if lookup(string(p-journal-num), '16,17':U) > 0 then do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '17':U))) * 2340 + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '16':U)) ) * 2340 + p-rec-no
      .
    end.
  end.
  else do:
    if tekka-is-closed-shift-journal(p-journal-num) > 0 then do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '43':U))) * 2978 + p-rec-no
      .
    end.
    else do:
      assign
      v-num-recs = (p-journal-num - integer(entry(1, '42':U)) ) * 2978 + p-rec-no
      .
    end.
  end.
end.
return v-num-recs.
END FUNCTION.
FUNCTION tekka-get-obj-num returns integer( input p-num-recs as decimal
                                           ,input p-is-petrol as logical
                                           ,input p-is-current as logical
                                           ,output p-rec-no as decimal
                                           ):
define variable v-obj-num0 as integer no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-num2 as integer no-undo .
define variable p-num-recs2 as integer no-undo .
define variable p-rec-no2 as integer no-undo .
if p-is-petrol then do:
  assign
  v-obj-num0 = trunc(p-num-recs / 1489, 0)
  .
  if p-is-current and num-entries('26,27,28,29':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '26,27,28,29':U))
  p-rec-no = p-num-recs modulo 1489
  .
  if not p-is-current and num-entries('30,31,32,33':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '30,31,32,33':U))
  p-rec-no = p-num-recs modulo 1489
  .
end.
else do:
  assign
  p-num-recs2 = (p-num-recs - trunc(p-num-recs, 0)) * 10000
  p-num-recs = trunc(p-num-recs, 0)
  v-obj-num0 = trunc(p-num-recs / 2340, 0)
  v-obj-num2 = trunc(p-num-recs2 / 2978, 0)
  .
  if p-is-current and num-entries('16':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '16':U))
  p-rec-no = p-num-recs modulo 2340
  .
  if not p-is-current and num-entries('17':U) >= v-obj-num0 + 1
  then
  assign
  v-obj-num = integer(entry(v-obj-num0 + 1, '17':U))
  p-rec-no = p-num-recs modulo 2340
  .
  if p-is-current and num-entries('42':U) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, '42':U))
  p-rec-no2 = p-num-recs2 modulo 2978
  .
  if not p-is-current and num-entries('43':U) >= v-obj-num2 + 1
  then
  assign
  v-obj-num2 = integer(entry(v-obj-num2 + 1, '43':U))
  p-rec-no2 = p-num-recs2 modulo 2978
  .
  assign
  p-rec-no = p-rec-no + p-rec-no2 / 10000
  .
end.
if v-obj-num = 0 then v-obj-num = 100.
return v-obj-num.
END FUNCTION.
FUNCTION tekka-get-next-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical):
if lookup (string(p-obj-num), '30,31,32,33':U) > 0 then return integer(entry(1, '17':U)).
if lookup (string(p-obj-num), '17':U) > 0 then do:
   if p-is-ptrl then
   return integer(entry(1, '26,27,28,29':U)).
   if not p-is-ptrl then
   return integer(entry(1, '16':U)).
end.
if lookup (string(p-obj-num), '26,27,28,29':U) > 0 then return integer(entry(1, '16':U)).
if lookup (string(p-obj-num), '16':U) > 0 then return 100.
return 0.
END FUNCTION.
FUNCTION tekka-get-next-current-obj-num returns integer ( input p-obj-num as integer, input p-is-ptrl as logical ):
if lookup (string(p-obj-num), '30,31,32,33':U) > 0 then return integer(entry(1, '26,27,28,29':U)).
if lookup (string(p-obj-num), '17':U) > 0 then do:
  if p-is-ptrl then
  return integer(entry(1, '26,27,28,29':U)).
  if not p-is-ptrl then
  return integer(entry(1, '16':U)).
end.
if lookup (string(p-obj-num), '26,27,28,29':U) > 0 then return integer(entry(1, '16':U)).
if lookup (string(p-obj-num), '16':U) > 0 then return 100.
return 0.
END FUNCTION.
PROCEDURE maria-put:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-out    as character no-undo .
define input parameter p-fname as character no-undo .
define input parameter p-by-record as logical no-undo .
define input parameter p-shift-fields as integer no-undo .
define input parameter p-binary as logical no-undo .
define input parameter p-obj-num as integer no-undo .
define input parameter p-max-records as integer no-undo .
define input parameter p-plu as integer no-undo .
define input parameter p-value as character no-undo .
define variable v-file-name as character no-undo .
define variable v-create as logical no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
v-file-name =  p-out + p-fname + '.' + string(p-obj-num,  '999') .
output stream IBMSTREAM
to value(v-file-name) append .
Put  stream IBMSTREAM unformatted
p-plu
chr(3)
p-value
skip.
output stream IBMSTREAM
close.
if not p-by-record then do:
  find first buf_temp-tekka-tsk where
            buf_temp-tekka-tsk.filename  = v-file-name no-error .
  if not available buf_temp-tekka-tsk then do:
    v-create = yes.
  end.
end.
else do:
  find first buf_temp-tekka-tsk where
            buf_temp-tekka-tsk.filename  = v-file-name
        and buf_temp-tekka-tsk.max-plu = (p-plu - 1) use-index gpi no-error .
  if not available buf_temp-tekka-tsk
  then do:
    find first buf_temp-tekka-tsk where
              buf_temp-tekka-tsk.filename  = v-file-name
          and buf_temp-tekka-tsk.min-plu = (p-plu + 1) use-index lpi no-error .
    if not available buf_temp-tekka-tsk
    then do:
      v-create = yes.
    end.
  end.
end.
if v-create then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = v-file-name
  buf_temp-tekka-tsk.range    = p-plu
  buf_temp-tekka-tsk.obj-num = p-obj-num
  buf_temp-tekka-tsk.obj-name = '':U
  buf_temp-tekka-tsk.num-records = 0
  buf_temp-tekka-tsk.max-records = p-max-records
  buf_temp-tekka-tsk.num-fields = num-entries(p-value, chr(4) )
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = p-by-record
  buf_temp-tekka-tsk.shift-fields = p-shift-fields
  buf_temp-tekka-tsk.binary = p-binary
  buf_temp-tekka-tsk.send-get = 'send'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                        then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                        else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                              then 'local'
                              else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.min-plu     = p-plu
  buf_temp-tekka-tsk.max-plu     = p-plu
  .
end.
assign
buf_temp-tekka-tsk.num-records = buf_temp-tekka-tsk.num-records + 1
buf_temp-tekka-tsk.min-plu     = minimum(buf_temp-tekka-tsk.min-plu, p-plu)
buf_temp-tekka-tsk.max-plu     = maximum(buf_temp-tekka-tsk.max-plu, p-plu)
.
END PROCEDURE.
PROCEDURE maria-get:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-out    as character no-undo .
define input parameter p-fname as character no-undo .
define input parameter p-by-record as logical no-undo .
define input parameter p-obj-num as integer no-undo .
define input parameter p-num-fields as integer no-undo .
define input parameter p-max-records as integer no-undo .
define input parameter p-min-plu as integer no-undo .
define input parameter p-max-plu as integer no-undo .
define input parameter p-other as character no-undo .
define input parameter p-order-num as integer no-undo .
define variable v-file-name as character no-undo .
define variable v-secondary-obj-num as character no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
if p-by-record then do:
  v-file-name =  p-out + p-fname + '-' + string(buf_cash-desk.cash-num) + '.' + string(p-obj-num,  '999') .
end.
else do:
  v-file-name =  p-out + p-fname + '-' + string(buf_cash-desk.cash-num) + '_html.' + string(p-obj-num,  '999').
end.
find first buf_temp-tekka-tsk where
          buf_temp-tekka-tsk.filename  = v-file-name no-error .
if not available buf_temp-tekka-tsk then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = v-file-name
  buf_temp-tekka-tsk.obj-num = p-obj-num
  buf_temp-tekka-tsk.obj-name = '':U
  buf_temp-tekka-tsk.max-records = p-max-records
  buf_temp-tekka-tsk.num-fields = p-num-fields
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = p-by-record
  buf_temp-tekka-tsk.send-get = 'get'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                          then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                          else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                                then 'local'
                                else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.min-plu     = p-min-plu
  buf_temp-tekka-tsk.max-plu     = p-max-plu
  buf_temp-tekka-tsk.num-records = (if p-min-plu <> ?
                                    and p-max-plu <> ?
                                    then p-max-plu - p-min-plu + 1
                                    else 0)
  buf_temp-tekka-tsk.other-info = p-other
  buf_temp-tekka-tsk.order-num = p-order-num
  .
  if index('16-42,17-43,':U, string(buf_temp-tekka-tsk.obj-num) + '-') > 0 then do:
    assign
    v-secondary-obj-num =  substring('16-42,17-43,':U, index('16-42,17-43,':U, string(buf_temp-tekka-tsk.obj-num) + '-'))
    v-secondary-obj-num = entry(2, v-secondary-obj-num, '-':U)
    v-secondary-obj-num = entry(1, v-secondary-obj-num)
    no-error
    .
    buf_temp-tekka-tsk.secondary = integer(v-secondary-obj-num).
  end.
end.
END PROCEDURE.
PROCEDURE maria-task:
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-fname as character no-undo .
define input parameter p-obj-num-list as character no-undo .
define input parameter p-parameters as character no-undo .
define buffer buf_temp-tekka-tsk for temp-tekka-tsk.
find first buf_temp-tekka-tsk where
          buf_temp-tekka-tsk.task-num  = p-fname no-error .
if not available buf_temp-tekka-tsk then do:
  create buf_temp-tekka-tsk.
  assign
  buf_temp-tekka-tsk.filename = ''
  buf_temp-tekka-tsk.range = 1
  buf_temp-tekka-tsk.obj-num = 0
  buf_temp-tekka-tsk.obj-name = p-obj-num-list
  buf_temp-tekka-tsk.task-num = p-fname
  buf_temp-tekka-tsk.by-record = no
  buf_temp-tekka-tsk.send-get = 'task'
  buf_temp-tekka-tsk.cash-num = BUF_CASH-DESK.cash-num
  buf_temp-tekka-tsk.cash-num-char = entry(3, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.port-num = entry(2, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.way = if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'remote'
                          then entry(2, entry(2, BUF_CASH-DESK.addr-path, chr(4)), '+')
                          else (if entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared'
                                then 'local'
                                else entry(1, BUF_CASH-DESK.addr-path, chr(4)))
  buf_temp-tekka-tsk.is-script = (entry(1, BUF_CASH-DESK.addr-path, chr(4)) = 'shared')
  buf_temp-tekka-tsk.pswd = entry(4, BUF_CASH-DESK.addr-path, chr(4))
  buf_temp-tekka-tsk.waiting-sek = 30
  buf_temp-tekka-tsk.other-info = p-parameters
  buf_temp-tekka-tsk.order-num = 0
  .
end.
END PROCEDURE.
procedure tekkatsk-verify-schema :
define input parameter p-obj-list as character no-undo .
define input parameter p-dir-path as character no-undo .
define variable v-obj-num as integer no-undo .
define variable v-obj-name as character no-undo .
define variable v-num-records as integer no-undo .
define variable v-size_ as integer no-undo .
define variable v-value as character no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable ii-ibs as integer no-undo .
define variable ii-tekka as integer no-undo .
define variable v-result as character no-undo .
define buffer buf_temp-tekka-schema for temp-tekka-schema.
define buffer buf2_temp-tekka-schema for temp-tekka-schema.
  do
  on error undo, return error
  :
     for each buf_temp-tekka-schema:
       delete buf_temp-tekka-schema.
     end.
     input from value('tekkasch.d').
     repeat :
       create buf_temp-tekka-schema.
       import buf_temp-tekka-schema.
       assign
       buf_temp-tekka-schema.host = 'IBS'
       ii = ii + 1.
       .
     end.
     input close.
     ii-ibs = ii.
      _ii:
      do ii = 1 to 256:
        if p-obj-list = "ALL"
        or lookup(string(ii), p-obj-list) > 0 then do:
          assign
          v-obj-num = 0
          v-obj-name = ''
          v-num-records = 0
          v-size_ = 0
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'oname'
                                                  ,output v-value) no-error .
          if v-value = ? then next _ii.
          assign
          v-obj-num = ii
          v-obj-name = v-value
          .
          run alienini-getkey in this-procedure (
                                                   input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input ('obj' + string(ii, '999'))
                                                  ,input 'size'
                                                  ,output v-value) no-error .
          assign
          v-num-records = integer(v-value) no-error  .
          if error-status:error
          or v-num-records = 0 then next _ii.
          run alienini-getkey in this-procedure (
                                                   input  (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                  ,input 'obj' + string(ii, '999')
                                                  ,input 'f000'
                                                  ,output v-value) no-error .
          assign
          v-size_ = integer(v-value) no-error  .
          if error-status:error
          or v-size_ = 0 then next _ii.
          _jj:
          do jj = 1 to 256:
            run alienini-getkey in this-procedure (
                                                     input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999')
                                                    ,input 'f' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value = ? then next _ii.
            create buf_temp-tekka-schema.
            assign
            buf_temp-tekka-schema.host = 'tekka'
            buf_temp-tekka-schema.obj-num = v-obj-num
            buf_temp-tekka-schema.obj-name = v-obj-name
            buf_temp-tekka-schema.num-records = v-num-records
            buf_temp-tekka-schema.size_ = v-size_
            buf_temp-tekka-schema.field-num = jj
            buf_temp-tekka-schema.custom-type = entry(1, entry(2, v-value, '#'), ':')
            buf_temp-tekka-schema.bin-group = (if num-entries(entry(2, v-value, '#'), ':') > 1
                                               then entry(2, entry(2, v-value, '#'), ':')
                                               else '':U)
            buf_temp-tekka-schema.start-pos = integer(entry(1, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.end-pos = integer(entry(2, entry(1, v-value, '#'), '-'))
            buf_temp-tekka-schema.progress-type = entry( LOOKUP(buf_temp-tekka-schema.custom-type, 'Sx,B,BF,BN,UI,UL,FL,SL,VL':U)
                                                        , 'C,I,I,I,D,D,D,D,D':U)
            no-error
            .
            if error-status:error then do:
              delete buf_temp-tekka-schema.
              next _jj.
            end.
            run alienini-getkey in this-procedure (
                                                    input (trim(p-dir-path, chr(92)) + chr(92) + 'datastru.ini')
                                                    ,input 'obj' + string(ii, '999') + 'name'
                                                    ,input 'n' + string(jj, '999')
                                                    ,output v-value) no-error .
            if v-value <> ? then
            buf_temp-tekka-schema.field-name = v-value.
          end.
        end.
      end.
      ii-tekka = ii - 1.
     if p-obj-list <> 'ALL' then do:
      if ii-tekka <> ii-ibs then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS &1 объектов&1по даным OLE-сервера &2"
                                , ii-ibs
                                , ii-tekka).
      end.
     end.
     for each buf_temp-tekka-schema where
            buf_temp-tekka-schema.host = 'tekka':
       find first buf2_temp-tekka-schema where
                 buf2_temp-tekka-schema.obj-num = buf_temp-tekka-schema.obj-num
             AND buf2_temp-tekka-schema.host = 'ibs'
             AND buf2_temp-tekka-schema.field-num = buf_temp-tekka-schema.field-num no-error .
       if not available buf2_temp-tekka-schema then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS нет поля &1 для объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
       buffer-compare buf_temp-tekka-schema
       to buf2_temp-tekka-schema
       save result in v-result.
       if v-result <> '':U then do:
        return error substitute("Несовпадание структур данных для ТЭККА:&1по данным IBS для поля &1 объекта &2"
                                , buf_temp-tekka-schema.field-num
                                , buf_temp-tekka-schema.obj-num).
       end.
     end.
  end.
end procedure.
FUNCTION set-Sx returns character (input p-string as character):
return p-string.
END FUNCTION.
FUNCTION get-Sx returns character (input p-string  as character):
return p-string.
END FUNCTION.
FUNCTION set-B returns character (input p-string  as character):
return chr(integer(p-string)).
END FUNCTION.
FUNCTION get-B returns character (input p-string  as character):
return string(asc(p-string)).
END FUNCTION.
FUNCTION set-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
do ii = 1 to 8:
  put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
end.
return chr(v-dopi).
END FUNCTION.
FUNCTION get-BF returns character (input p-string  as character):
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable ii as integer no-undo .
v-dopi = asc(p-string).
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
return v-dops.
END FUNCTION.
FUNCTION set-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
define variable v-dopi as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable v-grp-nums as integer no-undo .
define variable v-dopi2 as integer no-undo .
v-grp-nums = num-entries(p-bin-group).
do jj = 0 to v-grp-nums - 1:
  v-dopi2 = integer(substring(p-string, jj + 1, 3)).
  do ii = 1 to 8:
    put-bits(v-dopi, ii, 1) = integer(substring(p-string, 8 - ii + 1, 1)).
  end.
end.
return chr(v-dopi).
END FUNCTION.
FUNCTION get-BN returns character (input p-string  as character
                                  ,input p-bin-group as character):
define variable v-dopi as integer no-undo .
define variable v-dops as character no-undo .
define variable v-grp-nums as integer no-undo .
define variable ii as integer no-undo .
define variable jj as integer no-undo .
v-dopi = asc(p-string).
v-grp-nums = num-entries(p-bin-group).
do jj = 1 to v-grp-nums:
do ii = 8 to 1 BY -1:
  v-dops = v-dops + string(get-bits(v-dopi, ii, 1) ).
end.
end.
return v-dops.
END FUNCTION.
procedure fill-temp-cd :
define input parameter p-db-num   like ub.cash-desk.db-num no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-clear-table as logical no-undo .
define buffer buf_temp-cd for temp-cd.
define buffer buf_cash-desk for ub.cash-desk.
  do
  on error undo, return error
  :
     if p-clear-table  then do:
       for each buf_temp-cd:
         delete buf_temp-cd.
       end.
     end.
     for each buf_cash-desk no-lock where
            buf_cash-desk.db-num = p-db-num
        AND buf_cash-desk.obj-code = p-obj-code
        and buf_cash-desk.cash-on  = yes
     BREAK by buf_cash-desk.pos-type:
       if first-of(buf_cash-desk.pos-type) then do:
         create buf_temp-cd.
         buffer-copy buf_cash-desk to buf_temp-cd.
       end.
     end.
  end.
end procedure.
define variable p-dir as character no-undo .
define variable p-resend as logical no-undo .
define variable file_ as character no-undo .
define variable path as character no-undo .
define variable atr as character no-undo .
define variable v-entry as character no-undo .
define variable ii as integer no-undo .
define variable v-cd-num as character no-undo .
define variable v-shop-code as character no-undo .
define variable ss as character no-undo .
define variable p-encoding as character no-undo init "windows-1251":U.
define variable vss-include-info4 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure xmlchar-test :
define input parameter p-in-string          as character        no-undo.
define output parameter p-out-string-enc    as character        no-undo.
define output parameter p-out-string-dec    as character        no-undo.
do
on error undo, return error
:
       run xmlchar-encode in this-procedure
    (
          input p-in-string
        , output p-out-string-enc
    ).
       run xmlchar-decode in this-procedure
    (
          input p-out-string-enc
        , output p-out-string-dec
    ).
end.
end .
procedure xmlchar-encode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        when "?":U
        then do:
            assign
                p-out-string = "&#63;":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when "&":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&amp;":U
                        .
                    end.
                    when ">":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&gt;":U
                        .
                    end.
                    when "<":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&lt;":U
                        .
                    end.
                    when "'":U
                    then do:
                        assign
                            p-out-string = p-out-string + "&apos;":U
                        .
                    end.
                    when '"':U
                    then do:
                        assign
                            p-out-string = p-out-string + "&quot;":U
                        .
                    end.
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + "":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#10;":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + "&#13;":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-encode-1c :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-current-char  as character    no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
    .
    case p-in-string
    :
        when ?
        then do:
            assign
                p-out-string = "?":U
            .
        end.
        otherwise do:
            do v-position = 1 to length( p-in-string )
            :
                assign
                    v-current-char = substring( p-in-string, v-position, 1 )
                .
                case v-current-char
                :
                    when chr(1)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(2)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(3)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(4)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(5)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(6)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(7)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(8)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(9)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(29)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(10)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    when chr(13)
                    then do:
                        assign
                            p-out-string = p-out-string + " ":U
                        .
                    end.
                    otherwise do:
                        assign
                            p-out-string = p-out-string + v-current-char
                        .
                    end.
                end case.
            end.
        end.
    end case.
end.
end .
procedure xmlchar-decode :
define input parameter p-in-string      as character        no-undo.
define output parameter p-out-string    as character        no-undo.
    define variable v-position      as integer      no-undo.
    define variable v-last-position as integer      no-undo.
    define variable v-temp-integer  as integer      no-undo.
    define variable v-current-char  as character    no-undo.
    define variable v-next-char     as character    no-undo.
    define variable v-success       as logical      no-undo.
do
on error undo, return error
:
    assign
        p-out-string = "":U
        v-position   = 0
    .
    replace-cycle:
    do while yes
    on error undo, return error
    :
        assign
            v-last-position = index( p-in-string, "&":U, v-position + 1 )
        .
        if v-last-position <= v-position
        then do:
            if v-position = 0
            then do:
                assign
                    p-out-string = p-in-string
                .
            end.
            else do:
                assign
                    p-out-string = p-out-string + substring( p-in-string, v-position + 1 )
                .
            end.
            leave replace-cycle.
        end.
        else do:
            assign
                p-out-string    = p-out-string + substring( p-in-string, v-position + 1, v-last-position - v-position - 1 )
                v-position      = v-last-position
                v-current-char  = substring( p-in-string, v-position + 1, 1 )
            .
            if v-current-char = "#":U
            then do:
                assign
                    v-last-position = index( p-in-string, ";":U, v-position + 2 )
                .
                if v-last-position > 0
                then do:
                    run xmlchar-read-integer in this-procedure
                     (
                          input substring( p-in-string, v-position + 2, v-last-position - v-position - 2 )
                        , output v-temp-integer
                        , output v-success
                    ).
                    if v-success = yes
                    and v-temp-integer >= 1
                    and v-temp-integer <= 255
                    then do:
                        assign
                            p-out-string = p-out-string + chr( v-temp-integer )
                            v-position   = v-last-position + 1
                        .
                    end.
                    else do:
                        assign
                            p-out-string = p-out-string + "&":U
                            v-position   = v-position   + 1
                        .
                    end.
                end.
                else do:
                    assign
                        p-out-string = p-out-string + "&":U
                        v-position   = v-position   + 1
                    .
                end.
            end.
            else do:
                case substring( p-in-string, v-position + 1, 3 )
                :
                    when "lt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + "<":U
                            v-position   = v-position   + 3
                        .
                    end.
                    when "gt;":U
                    then do:
                        assign
                            p-out-string = p-out-string + ">":U
                            v-position   = v-position   + 3
                        .
                    end.
                    otherwise do:
                        if substring( p-in-string, v-position + 1, 4 ) = "amp;":U
                        then do:
                            assign
                                p-out-string = p-out-string + "&":U
                                v-position   = v-position   + 4
                            .
                        end.
                        else do:
                            case substring( p-in-string, v-position + 1, 5 )
                            :
                                when "quot;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + '"':U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                when "apos;":U
                                then do:
                                    assign
                                        p-out-string = p-out-string + "'":U
                                        v-position   = v-position   + 5
                                    .
                                end.
                                otherwise do:
                                    assign
                                        p-out-string = p-out-string + "&":U
                                    .
                                end.
                            end case.
                        end.
                    end.
                end case.
            end.
        end.
    end.
end.
end .
procedure xmlchar-read-integer :
define input parameter p-input-string      as character        no-undo.
define output parameter p-output-integer   as integer          no-undo.
define output parameter p-success       as logical          no-undo.
do
on error undo, return error
:
    assign
        p-output-integer = integer( p-input-string )
    no-error.
    if error-status :error
    then do:
        assign
            p-success           = no
            p-output-integer    = 0
        .
    end.
    else do:
        assign
            p-success           = yes
        .
    end.
end.
end.
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define temp-table temp_xmlparse-attrs no-undo
field field-name as character
field attr-code as character
field attr-value as character
index pi is unique primary
field-name attr-code
.
procedure xmlparse :
define input parameter p-handle         as handle           no-undo.
define input parameter p-XML-buffer     as character        no-undo.
define input parameter p-call-mode      as character        no-undo.
    define variable v-procedure-type        as character    no-undo.
    define variable v-procedure-name        as character    no-undo.
    define variable v-temp-string           as character    no-undo.
    define variable v-current-position      as integer      no-undo.
    define variable v-end-position          as integer      no-undo.
    define variable v-text-position         as integer      no-undo.
    define variable v-input-buffer-length   as integer      no-undo.
    define variable v-handle                as handle       no-undo.
    define variable v-call-mode             as character    no-undo.
    define variable v-proc-type             as character    no-undo.
    define variable v-proc-name             as character    no-undo.
    define variable v-decode-string         as character    no-undo.
do
on error undo, return error
:
    if not valid-handle( p-handle )
    then do:
        return.
    end.
    assign
        v-end-position          = 1
        v-current-position      = 1
        v-input-buffer-length   = length( p-XML-buffer )
    .
    do
    while v-end-position < v-input-buffer-length
    :
        assign
            v-current-position = index( p-XML-buffer, "<":U, v-end-position )
        .
        if v-current-position = 0
        then do:
            assign
                v-decode-string = substring( p-XML-buffer, v-end-position )
            .
            run xmlchar-decode in this-procedure (
                  input v-decode-string
                , output v-temp-string
            ).
            assign
                v-handle     = p-handle
                v-call-mode  = p-call-mode
                v-proc-type  = 'text':U
                v-proc-name  = '':U
            .
            run run-callback-procedure in this-procedure (
                  input v-handle
                , input v-call-mode
                , input v-proc-type
                , input v-proc-name
                , input v-temp-string
            ).
            assign
                v-end-position = v-input-buffer-length
            .
        end.
        else do:
            if v-current-position > v-end-position
            then do:
                assign
                    v-decode-string = substring( p-XML-buffer, v-end-position, v-current-position - v-end-position )
                .
                run xmlchar-decode in this-procedure (
                      input v-decode-string
                    , output v-temp-string
                ).
                assign
                    v-end-position = v-current-position
                .
                assign
                    v-handle     = p-handle
                    v-call-mode  = p-call-mode
                    v-proc-type  = 'text':U
                    v-proc-name  = '':U
                .
                run run-callback-procedure in this-procedure (
                      input v-handle
                    , input v-call-mode
                    , input v-proc-type
                    , input v-proc-name
                    , input v-temp-string
                ).
            end.
            assign
                v-decode-string = substring( p-XML-buffer, v-end-position + 1, 1 )
            .
            if v-decode-string = "/":U
            then do:
                assign
                    v-procedure-type    = "tag-end":U
                    v-end-position      = v-current-position + 1
                .
            end.
            else do:
                assign
                    v-procedure-type    = "tag-start":U
                    v-end-position      = v-current-position
                .
            end.
            assign
                v-current-position  = index(p-XML-buffer, "/>":U, v-end-position)
            .
            if v-current-position <= v-end-position
            then do:
                assign
                    v-current-position  = index(p-XML-buffer, ">":U, v-end-position)
                .
            end.
            assign
                v-end-position      = v-end-position + 1
            .
            if v-current-position <= v-end-position
            then do:
                run run-cb-xmlparse-error in this-procedure
                                        (   input p-handle
                                        ,   input 'Ошибка: знак < без завершающего > на той же строке'
                                        ).
                assign
                    v-temp-string   = "<":U + substring(p-XML-buffer, v-end-position)
                    v-end-position  = v-input-buffer-length
                .
                assign
                    v-handle     = p-handle
                    v-call-mode  = p-call-mode
                    v-proc-type  = 'text':U
                    v-proc-name  = '':U
                .
                run run-callback-procedure in this-procedure (
                      input v-handle
                    , input v-call-mode
                    , input v-proc-type
                    , input v-proc-name
                    , input v-temp-string
                ).
            end.
            else do:
                assign
                    v-temp-string   = trim( substring(      p-XML-buffer
                                                        ,   v-end-position
                                                        ,   v-current-position - v-end-position
                                          )          )
                    v-text-position = index( v-temp-string, " ":U )
                .
                if v-text-position <> 0
                then do:
                    assign
                        v-procedure-name    =   trim( substring(      v-temp-string
                                                                    ,   1
                                                                    ,   v-text-position
                                                      )          )
                        v-temp-string       =   trim( substring(    v-temp-string
                                                                ,   v-text-position + 1
                                                    )          )
                    .
                end.
                else do:
                    assign
                        v-procedure-name    =   v-temp-string
                        v-temp-string       =   "":U
                    .
                end.
                assign
                    v-end-position      = v-current-position + 1
                .
                assign
                    v-handle          = p-handle
                    v-call-mode       = p-call-mode
                .
                run run-callback-procedure in this-procedure (
                      input v-handle
                    , input v-call-mode
                    , input v-procedure-type
                    , input v-procedure-name
                    , input v-temp-string
                ).
            end.
        end.
    end.
end.
end procedure.
procedure run-callback-procedure :
define input parameter p-handle             as handle           no-undo.
define input parameter p-call-mode          as character        no-undo.
define input parameter p-procedure-type     as character        no-undo.
define input parameter p-procedure-name     as character        no-undo.
define input parameter p-param-value        as character        no-undo.
    define variable v-data-type         as character            no-undo.
    define variable v-data-value        as character            no-undo.
    define variable v-procedure-name    as character            no-undo.
    define variable v-procedure-exists  as logical      no-undo.
do
on error undo, return error
:
    if p-call-mode = "call-all":U
    or p-call-mode = "call-named":U
    then do:
        case p-procedure-type :
            when "text":U
            then do:
                assign
                    v-procedure-name = "cb-xmlparse-text":U
                .
            end.
            when "tag-end":U
            then do:
                assign
                    v-procedure-name = "cb-xmlparse-tag-end-":U + p-procedure-name
                .
            end.
            when "tag-start":U
            then do:
                assign
                    v-procedure-name = "cb-xmlparse-tag-start-":U + p-procedure-name
                .
            end.
            otherwise do:
                assign
                    v-procedure-name = p-procedure-name
                .
            end.
        end case.
        if p-handle :get-signature( v-procedure-name ) = "":U
        then do:
            assign
                v-procedure-exists = no
            .
        end.
        else do:
            assign
                v-procedure-exists = yes
            .
        end.
        if v-procedure-exists = yes
        then do:
            run value(v-procedure-name) in p-handle (input p-param-value) no-error.
            if error-status :error
            then do:
                run run-cb-xmlparse-error in this-procedure (
                    input p-handle
                    , input "Ошибка при вызове программы " + v-procedure-name
                ).
            end.
        end.
    end.
    if ( p-call-mode = "call-all":U
        and v-procedure-exists <> yes )
    or p-call-mode = "call-unnamed":U
    then do:
        case p-procedure-type :
            when 'text':U
            then do:
                assign
                    v-data-type     = 'text':U
                    v-data-value    = p-param-value
                .
            end.
            when 'tag-end':U
            then do:
                assign
                    v-data-type     = 'tag-end':U
                    v-data-value    = p-procedure-name
                .
            end.
            when 'tag-start':U
            then do:
                assign
                    v-data-type     = 'tag-start':U
                    v-data-value    = p-procedure-name
                .
            end.
            otherwise do:
                assign
                    v-data-type     = 'text':U
                    v-data-value    = p-procedure-name
                .
            end.
        end case.
        run run-cb-xmlparse-procedure-not-found in this-procedure (
              input p-handle
            , input v-data-type
            , input v-data-value
            , input p-param-value
        ).
    end.
end.
end procedure.
procedure run-cb-xmlparse-error :
do
on error undo, return error
:
    def input parameter p-handle            as handle no-undo.
    def input parameter p-error-message as char no-undo.
    if lookup("cb-xmlparse-error", p-handle :internal-entries) > 0
    then do:
        run cb-xmlparse-error in p-handle  (input p-error-message).
    end.
end.
end procedure.
procedure run-cb-xmlparse-procedure-not-found :
do
on error undo, return error
:
    def input parameter p-handle            as handle no-undo.
    def input parameter p-data-type         as char no-undo.
    def input parameter p-data-value        as char no-undo.
    def input parameter p-param-value       as char no-undo.
    if lookup("cb-xmlparse-procedure-not-found", p-handle :internal-entries) > 0
    then do:
        run cb-xmlparse-procedure-not-found in p-handle    (   input p-data-type
                                                          , input p-data-value
                                                          , input p-param-value
                                                        ) no-error.
        if error-status :error
        then do:
            run run-cb-xmlparse-error in this-procedure
                                    (   input p-handle
                                    ,   input "Ошибка при вызове программы cb-xmlparse-procedure-not-found"
                                    ).
        end.
    end.
    else do:
        run run-cb-xmlparse-error in this-procedure
                                (   input p-handle
                                ,   input "Ошибка: Не определена программа cb-xmlparse-procedure-not-found"
                                ).
    end.
end.
end procedure.
procedure cb-xmlparse-attributes :
define input  parameter p-handle            as handle no-undo.
define input  parameter p-field-name        as character no-undo .
define input  parameter p-field-value       as character no-undo .
define variable ii as integer no-undo init 1.
define variable v-input-buffer-length   as integer no-undo.
define variable v-dc as logical no-undo .
define variable v-sc as logical no-undo .
define variable v-eq as logical no-undo .
define variable v-char as character no-undo .
define variable v-code as character no-undo .
define variable v-value as character no-undo .
define buffer buf_temp_xmlparse-attrs for temp_xmlparse-attrs.
  do
  on error undo, return error
  :
    if index(p-field-value, '>':U) > 0 then do:
      run run-cb-xmlparse-error in this-procedure
                              (   input p-handle
                              ,   input substitute("Ошибка: тэг &1 содержит другие тэги", p-field-name)
                              ).
    end.
    assign
    p-field-value = trim(p-field-value)
    .
    for each buf_temp_xmlparse-attrs where
            buf_temp_xmlparse-attrs.field-name = p-field-name:
      delete buf_temp_xmlparse-attrs.
    end.
    assign
    v-input-buffer-length = length( p-field-value )
    .
    do while ii <= v-input-buffer-length:
      assign
      v-char = substr(p-field-value, ii, 1)
      ii = ii + 1
      .
      CASE v-char:
        when "=":U then do:
          if v-eq
          and not v-dc
          and not v-sc then do:
            return error.
          end.
          assign
          v-eq = yes
          .
        end.
        when chr(34) then do:
        if v-eq then
        assign
        v-dc = not(v-dc)
        .
        else return error.
        end.
        when chr(39) then do:
        if v-eq then
        assign
        v-sc = not(v-sc)
        .
        else return error.
        end.
        when chr(32) then do:
          if not v-dc
          and not v-sc
          then do:
            assign
            v-sc = no
            v-dc = no
            v-eq = no
            .
            create buf_temp_xmlparse-attrs.
            assign
            buf_temp_xmlparse-attrs.field-name = p-field-name
            buf_temp_xmlparse-attrs.attr-code  = v-code
            buf_temp_xmlparse-attrs.attr-value = trim(v-value, (if v-value begins chr(34) then chr(34) else chr(39)))
            v-code = "":U
            v-value = "":U
            .
          end.
        end.
      END CASE.
      if not v-eq
      then do:
        if not v-char = chr(32) then
        assign
        v-code = v-code + v-char
        .
      end.
      else do:
        if v-char <> "=":U
        then
        assign
        v-value = v-value + v-char
        .
      end.
    end.
    if v-code <> "":U then do:
      create buf_temp_xmlparse-attrs.
      assign
      buf_temp_xmlparse-attrs.field-name = p-field-name
      buf_temp_xmlparse-attrs.attr-code  = v-code
      buf_temp_xmlparse-attrs.attr-value = trim(v-value, (if v-value begins chr(34) then chr(34) else chr(39)))
      .
    end.
  end.
end procedure.
FUNCTION cb-xmlparse-get-attr returns character (
      input p-handle        as handle
    , input p-field-name    as character
    , input p-field-value   as character
    , input p-attr-code     as character
    , input p-reparse       as logical
) :
define buffer buf_temp_xmlparse-attrs for temp_xmlparse-attrs.
  do
  on error undo, return error
  :
    if p-reparse then do:
      run cb-xmlparse-attributes in this-procedure (
                                                    input p-handle
                                                  , input p-field-name
                                                  , input p-field-value) no-error .
      if error-status:error then return ? .
    end.
    find first buf_temp_xmlparse-attrs no-lock where
              buf_temp_xmlparse-attrs.field-name = p-field-name
          AND buf_temp_xmlparse-attrs.attr-code   = p-attr-code no-error .
    if not avail buf_temp_xmlparse-attrs then return ?.
    return buf_temp_xmlparse-attrs.attr-value.
  end.
end FUNCTION.
FUNCTION cb-xmlparse-get-date returns date (
                                            input p-string as character):
define variable v-date as date.
if index(p-string, "-":U) = 0
or NOT (length(p-string) = 10
        or
        length(p-string) = 19)
then return error.
assign
v-date =  date(
          int( substr( p-string, 6, 2 ) ) ,
          int( substr( p-string, 9, 2 ) ),
          int( substr( p-string, 1, 4 ) )
            )
no-error .
if error-status:error then return error.
return v-date.
END FUNCTION.
FUNCTION cb-xmlparse-get-time returns integer (input p-string as character):
define variable v-time as integer no-undo .
define variable v-shift as integer no-undo .
if index(p-string, ":":U) = 0
or not (
        length(p-string) = 19
        or
        length(p-string) = 8
        )
then return error.
if length(p-string) = 19 then v-shift = 11.
assign
v-time =  int( substr( p-string, v-shift + 1, 2 ) ) * 3600 +
          int( substr( p-string, v-shift + 4, 2 ) ) * 60  +
          int( substr( p-string, v-shift + 7, 2) )
no-error .
if error-status:error then return error.
return v-time.
END FUNCTION.
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-xmlvalid-error-mode       as character    no-undo.
define variable v-xmlvalid-tag-value        as character    no-undo.
define variable v-xmlvalid-current-level    as integer      no-undo.
define variable v-xmlvalid-in-tag           as logical      no-undo.
define variable v-xmlvalid-read-vartype     as logical      no-undo.
define temp-table temp_xmlvalid-taglist no-undo
    field level-num as integer
    field tag-name  as character
    index lv  is primary unique level-num
.
define temp-table temp_xmlvalid-field-types no-undo
    field field-name as character
    field field-type as character
    index fn is primary unique field-name
.
procedure xmlvalid :
  do
  on error undo, return error
  :
    def input parameter p-handle                as handle   no-undo.
    def input parameter p-buffer-string         as char     no-undo.
    def input parameter p-xmlvalid-error-mode   as char     no-undo.
    assign
        v-xmlvalid-error-mode   = p-xmlvalid-error-mode
    .
    run xmlparse in this-procedure (
              input p-handle
            , input p-buffer-string
            , input "call-all":U
    ).
  end.
end procedure.
procedure cb-xmlparse-tag-start-varType :
do
on error undo, return error
:
define input parameter p-param as character    no-undo.
    assign
        v-xmlvalid-read-vartype = yes
    .
    run cb-xmlparse-procedure-not-found in this-procedure (
          input "tag-start":U
        , input "varType":U
        , input p-param
    ).
end.
end procedure.
procedure cb-xmlparse-tag-end-varType :
do
on error undo, return error
:
define input parameter p-param as character    no-undo.
    assign
        v-xmlvalid-read-vartype = no
    .
    define variable v-vartype-list     as character         no-undo.
    for each temp_xmlvalid-field-types
    :
        if index( "character,integer,decimal,date,logical", temp_xmlvalid-field-types.field-type ) = 0
        then do:
            run run-cb-xmlvalid-error  in this-procedure
                                        (     input this-procedure :handle
                                            , input "Замечание: Тип переменной в секции varType определен неверно. "
                                                    + "Тэг " + temp_xmlvalid-field-types.field-name
                                                    + " не будет проверен на соответствие типу данных"
                                        ).
            delete temp_xmlvalid-field-types.
        end.
        else do:
                                        assign
                                            v-vartype-list = v-vartype-list + temp_xmlvalid-field-types.field-name
                                            + temp_xmlvalid-field-types.field-type + chr(10)
                                        .
        end.
    end.
    run cb-xmlparse-procedure-not-found in this-procedure (
                                        input "tag-end":U
                                        , input "varType":U
                                        , input p-param
                                                        ).
end.
end procedure.
procedure cb-xmlparse-procedure-not-found :
do
on error undo, return error
:
def input parameter p-tag-type      as char no-undo.
def input parameter p-tag-value     as char no-undo.
def input parameter p-param-value   as char no-undo.
def buffer buf_temp_xmlvalid-taglist for temp_xmlvalid-taglist.
def var v-found    as logical  no-undo.
if p-tag-type = "tag-start"
then do:
    assign
        v-xmlvalid-current-level = v-xmlvalid-current-level + 1
        v-xmlvalid-in-tag        = yes
    .
    find first temp_xmlvalid-taglist
         where temp_xmlvalid-taglist.level-num = v-xmlvalid-current-level
    no-error.
    if not available temp_xmlvalid-taglist
    then do:
        create temp_xmlvalid-taglist.
        assign
            temp_xmlvalid-taglist.level-num = v-xmlvalid-current-level
        .
    end.
    assign
        temp_xmlvalid-taglist.tag-name = p-tag-value
        v-xmlvalid-tag-value = ""
    .
    if v-xmlvalid-read-vartype = yes and p-tag-value <> "varType":U
    then do:
        find first temp_xmlvalid-field-types
             where temp_xmlvalid-field-types.field-name = p-tag-value
        no-error.
        if available temp_xmlvalid-field-types
        then do:
            run run-cb-xmlvalid-error  in this-procedure
                                        (     input this-procedure :handle
                                            , input "Замечание: Тип переменной в секции varType определен повторно"
                                        ).
        end.
        else do:
            create temp_xmlvalid-field-types.
            assign
                temp_xmlvalid-field-types.field-name = p-tag-value
            .
        end.
    end.
end.
if p-tag-type = "tag-end"
then do:
    find first temp_xmlvalid-taglist
         where temp_xmlvalid-taglist.level-num = v-xmlvalid-current-level
           and temp_xmlvalid-taglist.tag-name  = p-tag-value
    no-error.
    if available temp_xmlvalid-taglist
    then do:
        assign
            v-xmlvalid-current-level = v-xmlvalid-current-level - 1
            v-xmlvalid-in-tag        = no
        .
    end.
    else do:
        if v-xmlvalid-error-mode = 'fatal'
        then do:
            run run-cb-xmlvalid-error  in this-procedure
                                        (     input this-procedure :handle
                                            , input "Ошибка: Попытка закрыть не открытый тэг"
                                        ).
        end.
        else do:
            find first temp_xmlvalid-taglist
                 where temp_xmlvalid-taglist.tag-name = p-tag-value
            no-error.
            if not available temp_xmlvalid-taglist
            then do:
                assign
                    v-xmlvalid-tag-value = v-xmlvalid-tag-value + "</" + p-tag-value + ">" + chr(10)
                .
            end.
            else do:
                for each buf_temp_xmlvalid-taglist
                   where buf_temp_xmlvalid-taglist.level-num > temp_xmlvalid-taglist.level-num
                :
                    assign
                        v-xmlvalid-tag-value = "<" + buf_temp_xmlvalid-taglist.tag-name + ">" + chr(10) + v-xmlvalid-tag-value
                        v-xmlvalid-current-level = temp_xmlvalid-taglist.level-num - 1
                    .
                end.
            end.
        end.
    end.
end.
if p-tag-type = "text"
then do:
    if v-xmlvalid-read-vartype = yes
    then do:
        if available temp_xmlvalid-field-types
        then do:
            assign
                temp_xmlvalid-field-types.field-type = v-xmlvalid-tag-value
            .
        end.
    end.
    else do:
        find first temp_xmlvalid-field-types
            where temp_xmlvalid-field-types.field-name = temp_xmlvalid-taglist.tag-name
        no-error.
        if available temp_xmlvalid-field-types
        then do:
        end.
        else do:
        end.
    end.
    assign
        v-xmlvalid-tag-value = v-xmlvalid-tag-value + p-tag-value
    .
end.
run run-cb-xmlvalid-procedure-not-found in this-procedure
                                        (     input this-procedure :handle
                                            , input p-tag-type
                                            , input p-tag-value
                                            , input p-param-value
                                        ).
end.
end procedure.
procedure run-cb-xmlvalid-procedure-not-found :
do
on error undo, return error
:
    def input parameter p-handle            as handle   no-undo.
    def input parameter p-data-type         as char     no-undo.
    def input parameter p-data-value        as char     no-undo.
    def input parameter p-param-value       as char     no-undo.
    if lookup("cb-xmlvalid-procedure-not-found", p-handle :internal-entries) > 0
    then do:
        run cb-xmlvalid-procedure-not-found in p-handle (   input p-data-type
                                                          , input p-data-value
                                                          , input p-param-value
                                                        ) no-error.
        if error-status :error
        then do:
            run run-cb-xmlvalid-error in this-procedure
                                    (   input p-handle
                                    ,   input "Ошибка при вызове программы cb-xmlvalid-procedure-not-found"
                                    ).
        end.
    end.
    else do:
        run run-cb-xmlvalid-error in this-procedure
                                (   input p-handle
                                ,   input "Ошибка: Не определена программа cb-xmlvalid-procedure-not-found"
                                ).
    end.
end.
end procedure.
procedure run-cb-xmlvalid-error :
do
on error undo, return error
:
    def input parameter p-handle            as handle no-undo.
    def input parameter p-error-message as char no-undo.
    if lookup("cb-xmlvalid-error", p-handle :internal-entries) > 0
    then do:
        run cb-xmlvalid-error in p-handle  (input p-error-message).
    end.
end.
end procedure.
procedure run-cb-xmlvalid-procedure :
do
on error undo, return error
:
def input parameter p-handle            as handle no-undo.
def input parameter p-procedure-name    as char no-undo.
def var v-data-type     as char no-undo.
def var v-data-value    as char no-undo.
def var v-param-value   as char no-undo.
    if lookup( p-procedure-name, p-handle :internal-entries) > 0
    then do:
        run value(p-procedure-name) in p-handle no-error.
        if error-status :error
        then do:
            run run-cb-xmlvalid-error in this-procedure
                                    (   input p-handle
                                    ,   input "Ошибка при вызове программы " + p-procedure-name
                                    ).
        end.
    end.
    else do:
        if substring(p-procedure-name, 1, 20) = "cb-xmlvalid-tag-end-"
        then do:
            assign
                v-data-type     = "tag-end"
                v-data-value    = substring(p-procedure-name, 21)
            .
        end.
        else do:
            if substring(p-procedure-name, 1, 22) = "cb-xmlvalid-tag-start-"
            then do:
                assign
                    v-data-type     = "tag-start"
                    v-data-value    = substring(p-procedure-name, 23)
                .
            end.
            else do:
                assign
                    v-data-type     = "text"
                    v-data-value    = p-procedure-name
                .
            end.
        end.
        run run-cb-xmlvalid-procedure-not-found in this-procedure
                                               (   input p-handle
                                                  , input v-data-type
                                                  , input v-data-value
                                                  , input v-param-value
                                                ).
    end.
end.
end procedure.
define stream stmXMLOut.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-xml-file-name     as character            no-undo.
define variable v-xml-file-name-path as character            no-undo.
define variable v-log-file-name     as character            no-undo.
define variable v-locked            as logical              no-undo.
define variable v-log-string        as character            no-undo.
define variable v-oper-num          as integer              no-undo.
define variable v-obj-list          as character            no-undo.
DEF VAR strDummy    AS CHAR view-as editor size 50 by 4 NO-UNDO.
DEF VAR intRep      AS INT NO-UNDO.
define variable hEDT             AS HANDLE NO-UNDO.
define variable hCNT             AS HANDLE NO-UNDO.
procedure xml-cd-write-header:
do
on error undo, return error
:
define input parameter p-xml-file-name       as character    no-undo.
define input parameter p-xml-file-name-path  as character    no-undo.
define input parameter p-doc-name            as character    no-undo.
define input parameter p-version             as character    no-undo.
define input parameter p-obj-list            as character    no-undo.
define input parameter p-correspondent       as character    no-undo .
define input parameter p-write-header        as logical      no-undo .
define variable OS-time as character no-undo .
define variable id as character no-undo .
define buffer buf_db for ub.db.
output stream stmXMLOut to value( p-xml-file-name-path + "xm1":U ) convert target "1251" append.
put stream stmXMLOut unformatted "<?xml version='1.0' encoding='windows-1251'?>".
assign
OS-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" )
.
run bgelib-tag-open in this-procedure (
                                     1
                                    ,p-doc-name
                                    ,substitute("type='REQUEST' id='&1' from='&2' to='&3' tstamp='&4'", p-xml-file-name, p-obj-list, p-correspondent, OS-time )
                                      ).
if p-write-header then do:
  run bgelib-tag-open(2, "Header","").
  run bgelib-tag-put( 3, "DocumentName", p-doc-name, 1).
  run bgelib-tag-put( 3, "DateFormat", "DD.MM.YYYY":U, 1).
  run bgelib-tag-put( 3, "DocumentVersion", "1.02":U, 1).
  run bgelib-tag-put( 3, "DocumentVersionDate", "09.09.2004":U, 1).
  run bgelib-tag-put( 3, "ExportDate", string(today, "99.99.9999":U), 1).
  run bgelib-tag-put( 3, "ExportTime", string(time, "hh:mm:ss":U), 1).
  run bgelib-tag-put( 3, "objList",             p-obj-list                    , 1).
  find first buf_db where buf_db.db-num = g#db-num no-lock.
  run bgelib-tag-put( 3, "dbEncKey",            buf_db.db-key-enc, 1).
  run bgelib-tag-close( 2, "Header" ).
end.
output stream stmXMLOut close.
end.
end procedure.
procedure xml-cd-write-footer:
do
on error undo, return error
:
define input parameter p-pos-type      like ub.cash-desk.pos-type no-undo .
define input parameter p-xml-file-name as character    no-undo.
define input parameter p-doc-name      as character    no-undo .
define variable v-error-num     as integer           no-undo.
define variable v-md5-signature as character no-undo .
output stream stmXMLOut to value( p-xml-file-name + "xm1" ) convert target "1251" append.
run bgelib-tag-close( 0, p-doc-name ).
put stream stmXMLOut unformatted skip.
output stream stmXMLOut close.
run bge/os_copy.p ("M", p-xml-file-name + "xm1", p-xml-file-name + "xml", output v-error-num ).
if v-error-num > 0
then do:
   return error.
end.
if opsys = "unix"
then do:
    os-command silent chmod 666 value (p-xml-file-name + "xml") 2>/dev/null.
end.
end.
end procedure.
procedure xml-cd-filename :
do
on error undo, return error
:
define input parameter  p-out               as character no-undo .
define output parameter p-xml-file-name     as character    no-undo.
define output parameter p-xml-file-name-path   as character    no-undo.
define output parameter p-log-file-name     as character    no-undo.
define output parameter p-locked            as logical      no-undo.
define variable v-out as character     no-undo.
define variable loc#log as logical no-undo .
define variable BadFlag as logical no-undo .
define variable fq as integer no-undo .
define variable v-remote as character no-undo .
assign
p-xml-file-name = substring( string( next-value( s-spool, ub), '99999999999999999999'), 13, 8 )
p-xml-file-name-path = p-out + p-xml-file-name + ".":U
p-log-file-name = p-out + "actions.log"
p-locked = ( search ( p-xml-file-name-path + "lk" ) <> ? )
.
end.
end procedure.
FUNCTION Xml-CD-DatetoString returns character(input  p-date as date):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + "-":U +
             string(Month(p-date), "99":U) + "-":U +
             string(DAY(p-date), "99":U).
return v-date-str.
END FUNCTION.
FUNCTION Xml-CD-DateTimetoString returns character (input  p-date as date, p-time as integer):
define variable v-date-str as character no-undo .
assign
v-date-str = string(YEAR(p-date), "9999":U) + "-":U +
             string(Month(p-date), "99":U) + "-":U +
             string(DAY(p-date), "99":U) + chr(32) +
             string(p-time, "HH:MM:SS").
return v-date-str.
END FUNCTION.
function string-to-date returns date ( input p-string  as character):
  define variable v-date as date no-undo .
  assign
  v-date = date(integer(substring(p-string, 4, 2))
                ,integer(substring(p-string, 1, 2))
                ,integer(substring(p-string, 7, 4))
               ) no-error .
  if error-status:error then return ?.
  return v-date.
END FUNCTION.
FUNCTION string-IS0-8601-to-sec returns integer (input p-string-iso-8601 as character ):
define variable v-time as integer no-undo init ?.
define variable v-dop1 as character no-undo .
define variable v-dop2 as character no-undo .
assign
v-dop1 = entry(1, p-string-iso-8601, chr(32) )
v-dop2 = entry(2, p-string-iso-8601, chr(32) )
no-error .
if error-status:error then return ?.
assign
v-time =  integer(entry(1, v-dop2, ";":U)) * 3600 +
          integer(entry(2, v-dop2, ";":U)) * 60 +
          integer(entry(3, v-dop2, ";":U)) no-error .
return v-time.
END FUNCTION.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION CIntBinS RETURNS CHARACTER(input vl_int as integer):
def var vl_bin as char no-undo init "".
if vl_int < 0 OR vl_int = ? then return ?.
do while vl_int > 0:
  assign
  vl_bin = (if vl_int modulo 2 = 0
              then "0":U
              else "1":U) + vl_bin
  vl_int = truncate(vl_int / 2,0).
end.
return fill( "0":U, 32 - length(vl_bin)) + vl_bin .
END FUNCTION.
FUNCTION BinMask RETURNS LOGICAL(input vl_int as integer,
                                 input vl_binm as character):
DEFINE VARIABLE vl_bin as character no-undo.
DEFINE VARIABLE ii as integer no-undo.
DEFINE VARIABLE ii-len as integer no-undo.
DEFINE VARIABLE ii-lenm as integer no-undo.
DEFINE VARIABLE mchar as character no-undo.
DEFINE VARIABLE ichar as character no-undo.
if vl_binm = ? then return ?.
vl_bin = CIntBinS(vl_int).
if vl_bin = ? then return ?.
assign
vl_binm = LEFT-TRIM(vl_binm, "X":U)
ii-lenm = LENGTH(vl_binm)
ii-len = LENGTH(vl_bin) - ii-lenm
.
if II-LENM > 32 THEN RETURN ?.
DO II = 1 to II-LENm:
  assign
  mchar = SUBSTR(vl_binm, ii, 1)
  ichar = SUBSTR(vl_bin, ii + ii-len, 1)
  .
  IF not (MCHAR = "0":u or MCHAR = "1":u or MCHAR = "X":u) then return ?.
  IF ichar <> mchar AND mchar <> "X":U then return no.
END.
return yes.
END FUNCTION.
DEFINE VARIABLE var-file-line-num          as   integer               no-undo .
DEFINE VARIABLE v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define stream chkstream.
define variable v-exit-processing as logical no-undo .
define variable v-first as logical no-undo init yes.
define variable p-view-log as logical   no-undo .
define variable p-spool-or-data as character no-undo .
define variable p-obj-code as integer   no-undo .
define variable v-adresat as character no-undo .
define variable p-pos-type as character no-undo init 'IBM-XML':U.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile: cd-xmlg.i $ $Revision: de2ec29bf3dd, 3632, test $".
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure cd-attr-code :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  define output parameter p-prop-list      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-code in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ,output p-prop-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-tooltip :
  define input  parameter p-ucode   as character no-undo .
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-tooltip in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-value :
  define input  parameter p-db-num    like ub.cash-desk-attr.db-num        no-undo .
  define input  parameter p-obj-code  like ub.cash-desk-attr.obj-code      no-undo .
  define input  parameter p-pos-type  like ub.cash-desk-attr.pos-type      no-undo .
  define input  parameter p-cash-num  like ub.cash-desk-attr.cash-num      no-undo .
  define input  parameter p-ucode     like ub.cash-desk-attr.upper-attr-code      no-undo .
  define input  parameter p-code      like ub.cash-desk-attr.attr-code      no-undo .
  define output parameter p-character like ub.cash-desk-attr.attr-value-character    no-undo .
  define output parameter p-date      like ub.cash-desk-attr.attr-value-date         no-undo .
  define output parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal      no-undo .
  define output parameter p-integer   like ub.cash-desk-attr.attr-value-integer      no-undo .
  define output parameter p-logical   like ub.cash-desk-attr.attr-value-logical      no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-character
      ,output p-date
      ,output p-decimal
      ,output p-integer
      ,output p-logical
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-write :
  define input parameter p-db-num    like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code  like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type  like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num  like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code      like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-character like ub.cash-desk-attr.attr-value-character no-undo .
  define input parameter p-date      like ub.cash-desk-attr.attr-value-date      no-undo .
  define input parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal   no-undo .
  define input parameter p-integer   like ub.cash-desk-attr.attr-value-integer   no-undo .
  define input parameter p-logical   like ub.cash-desk-attr.attr-value-logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-write in g#attr-lib
      (input p-db-num
      ,input p-obj-code
      ,input p-pos-type
      ,input p-cash-num
      ,input p-ucode
      ,input p-code
      ,input p-character
      ,input p-date
      ,input p-decimal
      ,input p-integer
      ,input p-logical
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-exist :
  define input  parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input  parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input  parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-delete :
  define input parameter  p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter  p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter  p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter  p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter  p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter  p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-news :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  define output parameter p-from-gbd       as logical   no-undo .
  define output parameter p-from-ubd       as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-news in g#attr-lib
      (
       input  p-ucode
      ,input  p-code
      ,output p-news
      ,output p-from-gbd
      ,output p-from-ubd
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-hist :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-hist           as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-hist in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-hist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-parse-date-time returns date
(input  p-string as character
,output p-time   as integer
):
  define variable v-return-value as date      no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-parse-date-time-proc in g#attr-lib
    (input  p-string
    ,output p-time
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run last-check-date-time in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-cd-datetostring returns character
(input  p-date as date
):
  define variable v-return-value as character no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-cd-datetostring-proc in g#attr-lib
    (input  p-date
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr-last-report-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-report-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-maria in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-periodic-tasks :
define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-periodic-tasks in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr_get-attr-int returns integer
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as integer   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-int-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-int-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
function cd-attr_get-attr-log returns logical
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as logical   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-log-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-log-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr_check-marketer :
  define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-value as character no-undo .
  define input parameter p-mode  as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_check-marketer in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-manual-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-manual-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-batch-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-batch-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-send-param :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-send-param     as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-send-param in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-send-param
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define temp-table temp-temp no-undo
field id as character
field ctime as integer
field cr as integer
field record-name as character
field field-name as character
field field-value as character
index iid id ctime
index ifile record-name field-name
index icr is unique primary cr
.
define temp-table temp-temp-attr no-undo
field id as character
field cr  as integer
field cra as integer
field record-name as character
field field-name as character
field attr-name as character
field attr-value as character
index iid id
index icr is unique primary cr cra
.
define temp-table temp-param no-undo
field desk as integer
field cr as integer
field group-name as character
field record-name as character
field key-name as character
field attr-value as character
field field-name as character
field field-value as character
index ifile record-name field-name key-name group-name
index icr is unique primary cr
.
define variable v-mail-parameters-start     as logical        no-undo.
define variable v-date-format as character no-undo .
define variable v-version as character no-undo .
define variable v-pos-version as character no-undo .
define variable v-from as character no-undo .
define variable v-is-spool-file as logical no-undo .
define variable v-start-err as integer no-undo .
define variable v-num-errors as integer no-undo .
define variable v-dec-sep as character no-undo init ".":U.
define variable v-encoding as character no-undo .
define variable v-db-key-enc as character no-undo .
define variable cri as integer no-undo .
define variable crai as integer no-undo .
define variable v-id as character no-undo .
define variable m-head-db-num   as integer no-undo.
define variable m-head-obj-code as integer no-undo.
define variable m-head-pos-type as character no-undo.
define variable m-head-cash-num as integer no-undo.
define variable v-ctrl as character no-undo .
define variable v-time as integer no-undo .
define variable v-time-char as character no-undo .
define variable v-cd-fatal-error as logical no-undo .
define variable v-cd-fatal-message as character no-undo .
define variable v-errorSeverity as integer no-undo .
define variable v-errormessage as character no-undo .
define variable v-errornum as character no-undo .
define variable v-group as character no-undo .
define variable v-key as character no-undo .
define variable ErrorMessage as character no-undo.
define variable mOk as logical no-undo.
define variable mtagbeg as int64  no-undo.
define variable mtagend as int64 no-undo.
procedure get-xml-ibm-c-buff-or-file.
   define input parameter p-Type as character  no-undo.
   define input parameter p-str  as longchar   no-undo.
   define variable hParser as handle no-undo.
   mtagbeg = 0.
   mtagend = 0.
   create sax-reader hParser.
   if p-Type eq "file"
   then
      hParser:set-input-source(p-Type, string(p-str)).
   else do:
      if p-Type = "longchar"
      then do:
         define variable vmemptr as memptr no-undo.
         copy-lob p-str to vmemptr.
         hParser:set-input-source("memptr", vmemptr).
      end.
      else
         hParser:set-input-source(p-Type, p-str).
   end.
   hParser:sax-parse () no-error.
   if error-status:error then do:
      delete object hParser.
      if error-status:num-messages > 0
      then do:
          run write-log-and-file in p-log-handle (
           input 1
         , input log-file-name
         , input 1
         , input substitute( "!!!При  произошла ошибка при получении полного пути файлу: &1 &2"
                             , ErrorMessage
                             , return-value
                           )
                                     ).
          return error error-status:get-message(1).
      end.
      else do:
           return error return-value.
      end.
   end.
   delete object hParser.
   if ErrorMessage <> ""
   then do:
      run write-log-and-file in p-log-handle (
           input 1
         , input log-file-name
         , input 1
         , input substitute( "!!!При  произошла ошибка при получении полного пути файлу: &1 "
                             , ErrorMessage
                           )
                                     ).
      return error ErrorMessage .
   end.
end.
procedure StartDocument:
end procedure.
procedure StartElement:
   define input parameter namespaceURI as character.
   define input parameter localName    as character.
   define input parameter qname        as character.
   define input parameter ihAttributes as handle.
   define variable v-attr-num    as integer   no-undo.
   define variable v-temp-string as character no-undo.
   do v-attr-num = 1 to ihAttributes:num-items:
      v-temp-string = substitute ('&1 &2="&3"',
                                  v-temp-string,
                                  ihAttributes:get-qname-by-index(v-attr-num),
                                  ihAttributes:get-value-by-index(v-attr-num)).
   end.
   v-temp-string = trim(v-temp-string).
     mtagbeg =  mtagbeg + 1.
    run run-callback-procedure in this-procedure (
                      input this-procedure:handle
                    , input "call-all":U
                    , input "tag-start"
                    , input qname
                    , input v-temp-string
                ).
end procedure.
define variable mcurrentContent as character no-undo.
procedure Characters:
    define input parameter charData as memptr.
    define input parameter numChars as integer.
    define variable mcurrentContent as character no-undo.
    mcurrentContent = get-string(charData, 1, get-size(charData)).
    run run-callback-procedure in this-procedure (
                      input this-procedure:handle
                    , input "call-all":U
                    , input "text"
                    , input ""
                    , input mcurrentContent
                ).
end procedure.
procedure EndElement:
define input parameter name_     as character.
define input parameter localName as character.
define input parameter qName     as character.
    if qname = "ErrorMessage" then do:
      ErrorMessage = mcurrentContent.
      self:stop-parsing ().
    end.
    mtagend = mtagend + 1.
    if mtagend mod 100 = 0 or qName eq "check"
    then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Прочитано открытых тегов &1 из них закрытых &2", mtagbeg, mtagend)).
    end.
    run run-callback-procedure in this-procedure (
                      input this-procedure:handle
                    , input "call-all":U
                    , input "tag-end"
                    , input qname
                    , input ""
                ).
end procedure.
procedure EndDocument:
    run hide-counter in p-log-handle .
    mOk = true.
end procedure.
procedure Warning:
    define input parameter ErrMessage as character no-undo.
    message "The following WARNING was generated:~n" + ErrMessage
        view-as alert-box information buttons ok.
end procedure.
procedure Error:
    define input parameter ErrMessage as character no-undo.
    mOk = false.
    message "The following NONFATAL ERROR was generated:~n" + ErrMessage
        view-as alert-box information buttons ok.
end procedure.
procedure FatalError:
    define input parameter ErrMessage as character no-undo.
    mOk = false.
    return error "The following FATAL ERROR was generated:~n" + ErrMessage.
end procedure.
PROCEDURE get-xml-ibm-c.
define input parameter p-filename as char no-undo.
define variable v-new-filename-full     as character         no-undo.
define variable v-xml-buffer as character no-undo.
define variable v-my-string as character no-undo .
define variable v-read-char as character no-undo .
define buffer buf_cash-desk for ub.cash-desk.
error-status:error = FALSE.
run gbl/fileapnd.p
  ( input p-filename
   ,input ""
   ,input 5
  ) no-error .
if error-status:error then do:
   run write-log-and-file in p-log-handle (
       input 1
     , input log-file-name
     , input 1
     , input return-value
     ).
   assign
      p-view-log = yes
      .
   undo, return.
end.
if p-encoding = "utf-8":U  then  do:
  input stream ChkStream from value( p-filename ) convert source "utf-8".
end.
else do:
  input stream ChkStream from value( p-filename ) .
end.
_repeat:
REPEAT :
  if v-exit-processing then leave _repeat.
  _line:
  DO TRANSACTION:
    import stream Chkstream unformatted  v-xml-buffer  .
    if v-xml-buffer = "":U then do:
      NEXT _repeat.
    end.
    assign
    var-file-line-num = var-file-line-num + 1
    .
    if left-trim(v-xml-buffer)  begins "<?xml":U then do:
      assign
      v-encoding = cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input "xml":U
                             ,input trim(v-xml-buffer, "?>")
                             ,input "encoding":U
                             ,input yes)
     .
     if v-encoding <> p-encoding
     then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Ошибка чтения файла &1: кодировка НЕ &2"
                                , p-filename
                                , p-encoding
                              )
                                            ).
      assign
      p-view-log = yes
      .
      undo, return .
     end.
    end.
    run xmlvalid in this-procedure (
          input this-procedure:handle
        , input v-xml-buffer
        , input 'fatal':u
    ) no-error .
    if error-status:error  then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Ошибка импорта файла &1: &2"
                                , p-filename
                                , return-value
                              )
                                            ).
      assign
      p-view-log = yes
      .
      undo, return .
    end.
    if v-cd-fatal-error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Файл &1 строка &2 фатальные ошибки: &3 - импорт прекращен"
                              , p-filename
                              , var-file-line-num
                              , v-cd-fatal-message
                            )
                                          ).
      assign
      p-view-log = yes
      .
      undo, return.
    end.
    if var-file-line-num modulo 100 = 0 then do:
      run show-counter in p-log-handle .
      run write-counter in p-log-handle (substitute("Файл &1: прочитано строк &2", p-filename, var-file-line-num)).
    end.
  END .
end.
input stream ChkStream close.
END PROCEDURE.
procedure cb-xmlparse-tag-start-Header :
do
on error undo, return error
:
  assign
      v-mail-parameters-start = yes
  .
end.
end procedure.
procedure cb-xmlparse-tag-end-Header :
do
on error undo, return error
:
  assign
      v-mail-parameters-start = no
  .
end.
end procedure.
procedure cb-xmlparse-tag-start-ignoriruem :
define input parameter p-parameter as character no-undo .
define variable v-file-type as character no-undo .
define variable v-adresat as character no-undo .
define variable v-FO-version as character no-undo .
define variable v-OptVersion as character no-undo .
define variable v-OptVersion1 as character no-undo .
define variable v-OptVersion2 as character no-undo .
define variable v-OptVersion3 as character no-undo .
define variable v-OptVersion4 as character no-undo .
define variable v-OptVer      as character no-undo .
define variable v-old-fo-version as character no-undo .
define variable v-pay-desk as integer no-undo .
define variable v-dop as character no-undo .
define buffer cash-desk for ub.cash-desk.
define variable v-date as date no-undo .
define variable v-decimal as decimal no-undo .
define variable v-integer as integer no-undo .
define variable v-logical as logical no-undo .
define variable v-err-message as character no-undo .
do
on error undo, return error
:
  if v-is-spool-file = no then do:
    IF INDEX(p-parameter,"OptVersion") > 0 THEN v-OptVer = 'OptVer'.
    assign
    v-file-type = cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "type":U
                             ,input yes)
    v-adresat =  cb-xmlparse-get-attr(
                              input this-procedure:handle
                             ,input p-spool-or-data
                             ,input p-parameter
                             ,input "to":U
                             ,input no)
    .
    if v-file-type = "REPLY":U AND
    (v-adresat begins ('маг':U + string(p-obj-code))
    )
    then do:
      assign
      v-is-spool-file = yes
      .
      if v-from begins ('маг':U + string(p-obj-code) + "_" + "касса") then do:
        v-pay-desk = ?.
        v-pay-desk = integer(replace(v-from, ('маг':U + string(p-obj-code) + "_" + "касса"), "")) no-error.
        assign
           m-head-db-num    = ?
           m-head-obj-code  = ?
           m-head-pos-type  = ?
           m-head-cash-num  = ?
        .
        find first cash-desk where
                         cash-desk.db-num = g#db-num
                     and cash-desk.obj-code = p-obj-code
                     and cash-desk.cash-num = v-pay-desk
        no-lock no-error.
        if available cash-desk
        then do transaction :
           assign
              m-head-db-num    = cash-desk.db-num
              m-head-obj-code  = cash-desk.obj-code
              m-head-pos-type  = cash-desk.pos-type
              m-head-cash-num  = cash-desk.cash-num
           .
          if p-pos-type = 'IBM-XML':U then
          do:
            run cd-attr-write in this-procedure (
              input cash-desk.db-num
              ,input cash-desk.obj-code
              ,input cash-desk.pos-type
              ,input cash-desk.cash-num
              ,input  (if p-pos-type = 'IBM-XML':U
              then 'IBM-XML_operative':U
              else 'AUTOTANK_operative':U)
              ,input 'last-date-polls':U
              ,input string (today,"99.99.9999")
              ,input ?
              ,input 0
              ,input 0
              ,input no
              ) .
            run cd-attr-write in this-procedure (
              input cash-desk.db-num
              ,input cash-desk.obj-code
              ,input cash-desk.pos-type
              ,input cash-desk.cash-num
              ,input  (if p-pos-type = 'IBM-XML':U
              then 'IBM-XML_operative':U
              else 'AUTOTANK_operative':U)
              ,input 'last-time-polls':U
              ,input string (time,"HH:MM:SS")
              ,input ?
              ,input 0
              ,input 0
              ,input no
              ) .
          end.
          IF v-OptVer = 'OptVer' THEN DO:
            v-OptVer = "".
            IF v-OptVersion  <> ? THEN v-OptVer = TRIM(v-OptVersion," ").
            IF v-OptVersion1 <> ? THEN v-OptVer = substitute("&1,&2",v-OptVer,TRIM(v-OptVersion1," ")) .
            IF v-OptVersion2 <> ? THEN v-OptVer = substitute("&1,&2",v-OptVer,TRIM(v-OptVersion2," ")) .
            IF v-OptVersion3 <> ? THEN v-OptVer = substitute("&1,&2",v-OptVer,TRIM(v-OptVersion3," ")) .
            IF v-OptVersion4 <> ? THEN v-OptVer = substitute("&1,&2",v-OptVer,TRIM(v-OptVersion4," ")) .
            v-OptVer = TRIM(v-OptVer,",").
                IF v-OptVer = "" THEN v-OptVer = "?" .
                    run cd-attr-write in this-procedure (
                                                   input cash-desk.db-num
                                                  ,input cash-desk.obj-code
                                                  ,input cash-desk.pos-type
                                                  ,input cash-desk.cash-num
                                                  ,input  (if cash-desk.pos-type = 'IBM-XML':U
                                                           then 'IBM-XML_operative':U
                                                           else 'AUTOTANK_operative':U)
                                                  ,input  (if cash-desk.pos-type = 'IBM-XML':U
                                                       then 'OptVer':U
                                                       else 'OptVer':U)
                                                  ,input v-OptVer
                                                  ,input no
                                                  ,input no
                                                  ,input no
                                                  ,input no
                                                  ) no-error.
               v-OptVer = '' .
           END.
          if error-status:error then do :
              v-err-message = return-value .
              run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input v-err-message
                                          ).
              p-view-log = yes .
            end .
           run cd-attr-value in this-procedure (
                                               input cash-desk.db-num
                                              ,input cash-desk.obj-code
                                              ,input cash-desk.pos-type
                                              ,input cash-desk.cash-num
                                              ,input  (if cash-desk.pos-type = 'IBM-XML':U
                                                      then 'IBM-XML_operative':U
                                                      else 'AUTOTANK_operative':U)
                                              ,input  (if cash-desk.pos-type = 'IBM-XML':U
                                                       then 'fo-version':U
                                                       else 'fo-version':U)
                                              ,output v-old-fo-version
                                              ,output v-date
                                              ,output v-decimal
                                              ,output v-integer
                                              ,output v-logical
                                              ,output v-dop) no-error.
           if     v-old-fo-version <> v-fo-version
              and v-FO-version <> ?
           then do:
              run cd-attr-write in this-procedure (
                                                   input cash-desk.db-num
                                                  ,input cash-desk.obj-code
                                                  ,input cash-desk.pos-type
                                                  ,input cash-desk.cash-num
                                                  ,input  (if cash-desk.pos-type = 'IBM-XML':U
                                                           then 'IBM-XML_operative':U
                                                           else 'AUTOTANK_operative':U)
                                                  ,input (if cash-desk.pos-type = 'IBM-XML':U
                                                          then 'fo-version':U
                                                          else 'fo-version':U)
                                                  ,input v-fo-version
                                                  ,input ?
                                                  ,input 0
                                                  ,input 0
                                                  ,input no
                                                  ) no-error.
            if error-status:error then do :
              v-err-message = return-value .
              run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input v-err-message
                                          ).
              p-view-log = yes .
            end .
          end.
        end.
      end.
    end.
    else do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!В директории приема файлов обнаружен файл с неизвестным адресатом: &1 и/или неизвестного типа: &2"
                              , v-adresat
                              , v-file-type
                            )
                                          ).
      assign
      p-view-log = yes
      v-exit-processing = yes
      .
    end.
  end.
  else do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Нарушение протокола обмена : тэг <&1>", p-spool-or-data
                            )
                                          ).
      assign
      p-view-log = yes
      .
  end.
end.
end procedure.
procedure cb-xmlparse-tag-start-config :
define input parameter p-parameter as character no-undo .
  run cb-xmlparse-tag-start-ignoriruem in this-procedure ( input p-parameter) no-error.
  if error-status:error then return error return-value .
end procedure.
procedure cb-xmlparse-tag-start-control :
define input parameter p-parameter as character no-undo .
  run cb-xmlparse-tag-start-ignoriruem in this-procedure ( input p-parameter) no-error.
  if error-status:error then return error return-value .
end procedure.
procedure cb-xmlparse-tag-end-ignoriruem :
define input parameter p-parameter as character no-undo .
do
on error undo, return error
:
  assign
  v-is-spool-file = no
  .
  end.
end procedure.
procedure cb-xmlparse-tag-end-config :
define input parameter p-parameter as character no-undo .
run cb-xmlparse-tag-end-ignoriruem  in this-procedure ( input p-parameter) no-error.
if error-status:error then return error return-value .
end procedure.
procedure cb-xmlparse-tag-end-control :
define input parameter p-parameter as character no-undo .
run cb-xmlparse-tag-end-ignoriruem  in this-procedure ( input p-parameter) no-error.
if error-status:error then return error return-value .
end procedure.
procedure cb-xmlparse-tag-start-spool :
define input parameter p-parameter as character no-undo .
do
on error undo, return error
:
  if v-is-spool-file = yes then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Нарушение протокола обмена : тэг <&1>",
 "spool":U
                           )
                                          ).
      assign
      p-view-log = yes
      .
  end.
  else do:
    assign
    v-exit-processing = yes
    .
  end.
end.
end procedure.
procedure cb-xmlparse-tag-end-spool :
define input parameter p-parameter as character no-undo .
do
on error undo, return error
:
end.
end procedure.
procedure cb-xmlparse-tag-start-error:
define input parameter p-parameter as character no-undo .
run cb-xmlparse-tag-start-err in this-procedure ( input p-parameter)  .
end procedure .
procedure cb-xmlparse-tag-end-error :
define input parameter p-parameter as character no-undo .
run cb-xmlparse-tag-end-err in this-procedure ( input p-parameter)  .
end procedure .
procedure cb-xmlparse-tag-end-ErrorMessage :
define input parameter p-parameter as character no-undo .
assign
v-ErrorMessage = v-xmlvalid-tag-value
.
if p-pos-type = 'IBM-XML':U
or p-pos-type = 'Autotank':U
then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!&1"
                            ,v-ErrorMessage
                          )
                                        ).
    assign
    p-view-log = yes
    .
end.
end procedure .
procedure cb-xmlparse-tag-end-ErrorSeverity :
define input parameter p-parameter as character no-undo .
assign
v-Errorseverity = integer(v-xmlvalid-tag-value)
no-error
.
if p-pos-type = 'IBM-XML':U
or p-pos-type = 'Autotank':U
then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!&1"
                          , (if v-errorseverity = 0
                              then "Информация"
                              else (if v-Errorseverity = 1
                                    then "Предупреждение"
                                    else "Ошибка"
                                    )
                              ))
                              ).
    assign
    p-view-log = yes
    .
end.
end procedure .
procedure cb-xmlparse-tag-start-err:
define input parameter p-parameter as character no-undo .
do
on error undo, return error
:
  if v-is-spool-file
  then do:
    assign
    v-start-err = v-start-err + 1
    v-num-errors = v-num-errors + 1
    v-errormessage = '':U
    v-errorseverity = 0
    v-errornum = '':U
    .
    if p-pos-type = 'MAGIA-XML':U then do:
      assign
      v-ErrorMessage = cb-xmlparse-get-attr(
                                input this-procedure:handle
                              ,input p-spool-or-data
                              ,input p-parameter
                              ,input "ErrorMessage":U
                              ,input yes)
      v-ErrorNum =  cb-xmlparse-get-attr(
                                input this-procedure:handle
                              ,input p-spool-or-data
                              ,input p-parameter
                              ,input "Error":U
                              ,input no)
      v-ErrorSeverity =  integer(cb-xmlparse-get-attr(
                                input this-procedure:handle
                              ,input p-spool-or-data
                              ,input p-parameter
                              ,input "ErrorSeverity":U
                              ,input no))
      no-error
      .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!&1: &2 &3                   Код &4"
                              , (if v-errorseverity = 0
                                then "Информация"
                                else (if v-Errorseverity = 1
                                      then "Предупреждение"
                                      else "Ошибка"
                                      )
                                )
                              , v-ErrorMessage
                              , chr(10)
                              , v-ErrorNum
                            )
                                          ).
      assign
      p-view-log = yes
      .
    end.
  end.
  else do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Нарушение протокола обмена : тэг Err", p-spool-or-data
                            )
                                          ).
      assign
      p-view-log = yes
      .
  end.
end.
end procedure.
procedure cb-xmlparse-tag-end-err :
define input parameter p-parameter as character no-undo .
do
on error undo, return error
:
  if p-pos-type = 'MAGIA-XML':U then do:
    if v-start-err =  1 then do:
      assign
      v-start-err = 0
      .
    end.
    else do:
      assign
      v-start-err = v-start-err - 1
      .
    end.
  end.
  if p-pos-type = 'IBM-XML':U
  or p-pos-type = 'Autotank':U
  then do:
    assign
    v-errornum = v-xmlvalid-tag-value
    no-error .
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "!!!           Код &1"
                            , v-ErrorNum  )
                                        ).
    assign
    p-view-log = yes
    .
  end.
end.
end procedure.
PROCEDURE fill-doc-property :
do
on error undo, return error
:
define input parameter p-tag-name   as character    no-undo.
define input parameter p-tag-value  as character    no-undo.
define buffer buf_db for ub.db.
if v-mail-parameters-start = yes
then do:
  CASE p-tag-name:
    when "DocumentName":U
    then do:
      if p-tag-value = p-spool-or-data then do:
      end.
      else do:
      end.
    end.
    when "DateFormat":U
    then do:
      assign
      v-date-format = p-tag-value
      .
    end.
    when "DocumentVersion":U
    then do:
      assign
      v-version = p-tag-value
      .
    end.
    when "DecimalSeparator":U
    then do:
      assign
      v-dec-sep = p-tag-value
      .
    end.
    when "objList":U then do:
    end.
    when "dbEncKey":U then do:
      assign
      v-db-key-enc = p-tag-value
      .
      find first buf_db where buf_db.db-num = g#db-num no-lock.
      if buf_db.db-key-enc = v-db-key-enc then do:
        return error
        substitute("Кодир. значение ключа БД-приемника &1 совпадает с кодир. значением ключа БД-источника &2&3- импорт данных со своей БД на свою БД невозможен"
                   , buf_Db.db-key-enc
                   , v-db-key-enc
                   , chr(10)).
      end.
    end.
  end case.
end.
end.
end PROCEDURE.
procedure create-temp-table-record :
define input parameter p-record-name as character no-undo .
define input parameter p-field-name as character no-undo .
define input parameter p-field-value as character no-undo .
  do
  on error undo, return error
  :
    if p-record-name = "Param" or p-record-name = "FuelPump" then do:
    find first temp-param where
               temp-param.cr = cri + 1 no-error .
    if not avail temp-param then do:
      create
      temp-param.
      assign
      temp-param.cr = cri + 1
      .
    end.
    assign
    temp-param.record-name = p-record-name
    temp-param.field-name  = p-field-name
    temp-param.field-value = p-field-value
    temp-param.desk        = m-head-cash-num
    temp-param.key-name    = v-key
    temp-param.group-name  = v-group
    cri                   = cri + 1
    .
    end.
    else do:
    find first temp-temp where
               temp-temp.cr = cri + 1 no-error .
    if not avail temp-temp then do:
      create
      temp-temp.
      assign
      temp-temp.cr = cri + 1
      .
    end.
    assign
    temp-temp.record-name = p-record-name
    temp-temp.field-name  = p-field-name
    temp-temp.field-value = p-field-value
    temp-temp.id          = v-id
    temp-temp.ctime       = v-time
    cri                   = cri + 1
    .
    end.
  end.
end procedure.
define stream dirstream.
define stream PrnLibStream.
define buffer buf_cash-desk for ub.cash-desk.
assign
p-dir = entry(1, p-parameter, chr(4) )
p-resend = (if num-entries(p-parameter, chr(4) ) > 1
            then logical(entry(2, p-parameter, chr(4) ))
            else no).
input stream DirStream from os-dir(p-dir) .
_file:
REPEAT :
  import stream DirStream file_ path atr.
  if length(file_) > 3
  AND substring( file_, length(file_) - 2, 3 ) = "xml":u
  AND can-do( "f", atr )  then do:
    if v-first then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!В директории &1 обнаружены файлы, недошедшие до кассы:&2            посылаются заново......."
                              , p-dir
                              , chr(10))
                                          ).
      v-first = no.
    end.
    process events.
    assign
    v-adresat = '':U
    v-shop-code = '':U
    v-cd-num = '':U
    v-exit-processing = no
    .
    RUN get-xml-ibm-c(input path ) no-error .
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
      v-view-log = yes
      .
      next _file .
    end.
    if v-adresat <> '':U  then do:
       assign
       v-entry = trim(substring(v-adresat, 4)
                   , chr(39)).
       v-shop-code = entry(1, v-entry, "_").
       v-cd-num    = entry(2, v-entry, "_").
      .
      find first buf_cash-desk where
                buf_cash-desk.pos-type = 'IBM-XML':U
            and buf_cash-desk.db-num = g#db-num
            and buf_cash-desk.obj-code = integer(trim(v-shop-code, 'маг':U))
            and buf_cash-desk.cash-num = integer(trim(v-cd-num, 'касса'))           no-error .
      if available buf_cash-desk then do:
          run str/get-inis.p (
                          input 'маг':U
                        , input buf_cash-desk.obj-code
                        , input buf_cash-desk.pos-type
                        , input buf_cash-desk.remote
                        , input "get":U
                        , output out
                        , output out2
                        , output in_
                        , output spl
                        , output sav
                        , output v-remote
                        )  no-error .
          if error-status:error then do:
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute(
                                  "!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                                  , buf_cash-desk.pos-type
                                  , buf_cash-desk.obj-code
                                  , chr(10)
                                  , error-status:get-message(1)
                                  , return-value
                                  )).
            assign
            v-view-log = yes.
            next _file.
          end.
          run str/post-xml.p
            (
            input parparentproc
            ,input parparentproc
            ,input p-log-handle
            ,input (if p-resend then ? else g#news)
            ,input (if p-resend then ? else g#auto)
            ,input 'send'
            ,input log-file-name
            ,input (entry(1, buf_cash-desk.addr-path, chr(4)) + '://' + entry(2, buf_cash-desk.addr-path, chr(4)))
            ,input replace( path, "/", "\" )
            ,input (replace(in_  + spl  + "/" + file_, "/", "\" ))
            ,input 30
            ,input substitute("Маг&1 касса&2 &3", buf_cash-desk.obj-code, buf_cash-desk.cash-num, file_)
            ) no-error .
        end.
        else do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute(
                                "!!!Неизвестная касса-адресат в файле &1: &2&3 касса &4"
                                , path
                                , 'маг':U
                                , v-shop-code
                                , v-cd-num
                                )).
          assign
          v-view-log = yes.
          next _file.
        end.
    end.
  end.
end.
input stream Dirstream close.
procedure cb-xmlparse-tag-start-Data :
define input parameter p-parameter as character no-undo .
do
on error undo, return error
:
  assign
  v-adresat = cb-xmlparse-get-attr(
                          input this-procedure:handle
                          ,input "data":U
                          ,input p-parameter
                          ,input "to":U
                          ,input yes)
  .
  assign
  v-exit-processing = yes
  .
end.
END PROCEDURE.
     .
