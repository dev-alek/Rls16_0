block-level on error undo, throw.
define input parameter p-shift-date as date no-undo.
define input parameter p-shift-num as integer no-undo.
define input parameter p-obj-type as character no-undo.
define input parameter p-obj-code as integer no-undo.
define input parameter p-start-time as integer no-undo.
define input parameter p-end-time as integer no-undo.
define input parameter p-start-date as date no-undo.
define input parameter p-end-date as date no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sht-time-check.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/sht-time-check.p $":U .
define variable vss-description as character no-undo init "Изменение времени закрытой смены".
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
define variable prev-timestamp as decimal no-undo.
define variable next-timestamp as decimal no-undo.
define variable new-start-timestamp as decimal no-undo.
define variable new-end-timestamp as decimal no-undo.
define buffer bf_curr-shift-obj for ub.shift-obj.
define buffer bf_prev-shift-obj for ub.shift-obj.
define buffer bf_next-shift-obj for ub.shift-obj.
find first bf_curr-shift-obj no-lock
    where bf_curr-shift-obj.obj-type = p-obj-type
    and bf_curr-shift-obj.obj-code = p-obj-code
    and bf_curr-shift-obj.shift-date = p-shift-date
    and bf_curr-shift-obj.shift-num = p-shift-num
    no-error.
if not available bf_curr-shift-obj then
    return error subst("Смена &1 &2 на объекте &3 &4 не найдена", p-shift-date, p-shift-num, p-obj-type, p-obj-code).
if bf_curr-shift-obj.status_ <> 'зкр':U then
    return error "Время смены можно менять только при статусе <Закрыта>".
find first bf_prev-shift-obj no-lock
    where recid(bf_prev-shift-obj) = recid(bf_curr-shift-obj).
find prev bf_prev-shift-obj no-lock
    where bf_prev-shift-obj.obj-type = p-obj-type
    and bf_prev-shift-obj.obj-code = p-obj-code
    no-error.
find first bf_next-shift-obj no-lock
    where recid(bf_next-shift-obj) = recid(bf_curr-shift-obj).
find next bf_next-shift-obj no-lock
    where bf_next-shift-obj.obj-type = p-obj-type
    and bf_next-shift-obj.obj-code = p-obj-code
    and bf_next-shift-obj.open-date <> ?
    no-error.
if p-start-date >= p-end-date AND p-start-time >= p-end-time then
    return error "Новое время открытия смены должно быть меньше закрытия".
assign
    new-start-timestamp = int(bf_curr-shift-obj.open-date) * 60 * 60 * 60 * 24 + p-start-time
    new-end-timestamp = int(if bf_curr-shift-obj.close-date <> ? then bf_curr-shift-obj.close-date else p-shift-date) * 60 * 60 * 60 * 24 + p-end-time
    prev-timestamp = int(bf_prev-shift-obj.close-date) * 60 * 60 * 60 * 24 + bf_prev-shift-obj.close-time when available bf_prev-shift-obj
    next-timestamp = int(bf_next-shift-obj.open-date) * 60 * 60 * 60 * 24 + bf_next-shift-obj.open-time when available bf_next-shift-obj
.
if available bf_next-shift-obj and new-end-timestamp >= next-timestamp then
    return error "Время открытия смены должно быть больше времени закрытия предыдущей смены".
if available bf_prev-shift-obj and new-start-timestamp <= prev-timestamp then
    return error "Время закрытия смены должно быть меньше времени открытия следующей смены".
