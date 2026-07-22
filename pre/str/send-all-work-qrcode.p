block-level on error undo, throw.
define variable vss-revision as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "Отправка на кассу QR-код кассира".
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
define variable mdb-num   as integer   no-undo.
define variable mObjType  as character no-undo.
define variable mObjCode  as integer   no-undo.
define variable mPostType as character no-undo.
define variable mCashNum  as integer   no-undo.
define stream finp.
procedure putc :
  define input  parameter iSAXWriter as handle no-undo .
  define input  parameter i-action   as character  no-undo .
  define input  parameter i-value    as character  no-undo .
  define output parameter oOK       as logical no-undo.
  define variable ii             as integer   no-undo .
  define VARIABLE name-cash      as character no-undo.
  define VARIABLE name-cash1     as character no-undo.
  define VARIABLE name-cash2     as character no-undo.
  define variable enc-passwd     as character no-undo.
  define variable ufo-passwd as character no-undo.
  define variable ufo-enc20  as character format "x(20)" no-undo.
  define variable v-shadow-fname as character no-undo .
  define buffer buf_clients for ub.clients .
  do ii = 0 to num-entries(i-value,chr(44)):
    FIND FIRST ub.staff-attr No-LOCK WHERE
      recid(ub.staff-attr) = integer(entry(ii,i-value,chr(44))) No-ERROR.
    IF avail ub.staff-attr then
    do:
      v-shadow-fname = substitute( "pass&1.dat" , string(random(1, 80000), "99999") ) .
      find first ub.staff no-lock where ub.staff.staff-code = ub.staff-attr.staff-code and
        ub.staff.role-level = ub.staff-attr.role-level and
        ub.staff.role = ub.staff-attr.role no-error .
      find first ub.person where ub.person.psn-code = ub.staff.psn-code no-error.
      iSAXWriter:start-element ("Cashier").
      iSAXWriter:insert-attribute("ctrl",  "ADD") .
      iSAXWriter:insert-attribute("tms", string(time)) .
      iSAXWriter:insert-attribute("code", string (ub.staff.psn-code)) .
      if available ub.person
        then
      do:
        find FIRST buf_clients no-lock WHERE
          buf_clients.obj-type = 'чел':U
          AND buf_clients.obj-code = ub.person.psn-code no-error .
        name-cash1 = if ub.person.name1 <> "" then (substring(ub.person.name1,1,1) + '.') else ''.
        name-cash2 = if ub.person.name2 <> "" then (substring(ub.person.name2,1,1) + '.') else ''.
        name-cash = buf_clients.obj-name + ' ' + name-cash1 + ' ' + name-cash2 .
      end.
      enc-passwd = "".
      ufo-passwd = search('exe/ufo_passwd.exe':u).
      if ufo-passwd > "" then
      do:
        os-command silent value(ufo-passwd) value(ub.staff.password) > value(v-shadow-fname) .
        input stream finp from value(v-shadow-fname) .
        repeat:
          import stream finp unformatted ufo-enc20 no-error.
          enc-passwd = enc-passwd + ufo-enc20.
        end.
        input stream finp close.
        os-delete value(v-shadow-fname).
      end.
      iSAXWriter:write-data-element ( "CashierName", name-cash ).
      iSAXWriter:write-data-element ( "CashierParol", ub.staff.password ).
      iSAXWriter:write-data-element ( "CashierLock",  if staff.date-end < today then "1" else "0").
      iSAXWriter:write-data-element ( "CashierINN", if available person then string(person.inn) else "").
      iSAXWriter:write-data-element ( "CashierShadow", enc-passwd).
      iSAXWriter:write-data-element ( "CashierQRCode", ub.staff-attr.attr-value).
      iSAXWriter:end-element ( "Cashier").
    END.
  END.
  oOk = true .
end procedure .
