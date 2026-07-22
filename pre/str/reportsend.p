block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-userId as character no-undo .
define input parameter p-shift-date  as date no-undo .
define input parameter p-shift-num  as integer no-undo .
define input parameter p-shift-name  as character no-undo .
define input parameter p-obj-code   as integer no-undo .
define input parameter p-obj-type as character no-undo .
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
define buffer buf_reportShift  for ub.reportShift .
define buffer buf_shift-attr   for ub.shift-obj-attr .
define buffer buf_user-account for ub.user-account .
define variable user-id as character no-undo .
define variable fio     as character no-undo .
find first buf_user-account no-lock where buf_user-account.user-id = p-userId no-error .
if available (buf_user-account) then
do:
    assign
        user-id = buf_user-account.user-id
        fio     = buf_user-account.last-name + " " + buf_user-account.first-name + " " + buf_user-account.second-name .
end.
find first buf_reportShift exclusive-lock where buf_reportShift.shift-date = p-shift-date and
    buf_reportShift.shift-num = p-shift-num and buf_reportShift.obj-code = p-obj-code and
    buf_reportShift.obj-type = p-obj-type and buf_reportShift.report-type = 1 no-error .
if not available (buf_reportShift) then
do:
    find first buf_shift-attr exclusive-lock where buf_shift-attr.attr-code = "reportShift" and
        buf_shift-attr.obj-code = p-obj-code and
        buf_shift-attr.obj-type = p-obj-type and
        buf_shift-attr.shift-date = 01/01/1970 and
        buf_shift-attr.shift-num = 1 no-error .
    if available (buf_shift-attr) then
    do:
        buf_shift-attr.attr-value = string(integer(buf_shift-attr.attr-value) + 1) .
    end.
    else
    do:
        create buf_shift-attr .
        assign
            buf_shift-attr.attr-code  = "reportShift"
            buf_shift-attr.obj-code   = p-obj-code
            buf_shift-attr.obj-type   = p-obj-type
            buf_shift-attr.shift-date = 01/01/1970
            buf_shift-attr.shift-num  = 1
            buf_shift-attr.attr-value = string(next-value(s-reportShift, ub)).
    end.
    create buf_reportShift.
    assign
        buf_reportShift.id          = integer(buf_shift-attr.attr-value)
        buf_reportShift.obj-code    = p-obj-code
        buf_reportShift.obj-type    = p-obj-type
        buf_reportShift.report-type = 1
        buf_reportShift.shift-date  = p-shift-date
        buf_reportShift.shift-num   = p-shift-num
        .
end.
assign
    buf_reportShift.date       = today
    buf_reportShift.user-id    = user-id
    buf_reportShift.fio        = fio
    buf_reportShift.time_      = time
    buf_reportShift.shift-name = p-shift-name
    .
run bge\send1cerp.p (parparentproc,
    this-procedure,
    this-procedure,
    "reportShift",
    (buffer buf_reportShift:handle),
    ?,
    ?) no-error.
if  error-status:error then
do:
    message return-value
        view-as alert-box.
    return .
end.
