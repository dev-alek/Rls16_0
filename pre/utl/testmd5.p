block-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: testmd5.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/testmd5.p $":U .
define variable vss-description as character no-undo initial "Программа проверки работы модуля md5.p".
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
define stream slog .
do
on error undo, return error return-value
:
  run validate-md5 in this-procedure
    (input ''
    ,input 'D41D8CD98F00B204E9800998ECF8427E'
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  run validate-md5 in this-procedure
    (input 'a'
    ,input '0CC175B9C0F1B6A831C399E269772661'
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  run validate-md5 in this-procedure
    (input 'abc'
    ,input '900150983CD24FB0D6963F7D28E17F72'
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  run validate-md5 in this-procedure
    (input 'message digest'
    ,input 'F96B697D7CB7938D525A2F31AAF161D0'
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  run validate-md5 in this-procedure
    (input 'abcdefghijklmnopqrstuvwxyz'
    ,input 'C3FCD3D76192E4007DFB496CCA67E13B'
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  run validate-md5 in this-procedure
    (input 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    ,input 'D174AB98D277D9F5A5611C2C9F419D9F'
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
  run validate-md5 in this-procedure
    (input '12345678901234567890123456789012345678901234567890123456789012345678901234567890'
    ,input '57EDF4A22BE3C955AC49DA2E2107B67A'
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
procedure validate-md5 :
  define input parameter p-string          as character no-undo .
  define input parameter p-check-signature as character no-undo .
  do
  on error undo, return error return-value
  :
    define variable v-test-file-name as character no-undo .
    assign
      v-test-file-name = 'testmd5.txt':u
    .
    output stream slog to value(v-test-file-name) .
    put stream slog unformatted p-string .
    output stream slog close .
    define variable v-signature as character no-undo .
    run gbl/md5.p
      (input  v-test-file-name
      ,output v-signature
      ) no-error .
    if  error-status :error
    then do:
      undo, return error return-value .
    end.
    if v-signature <> p-check-signature
    then do:
      undo, return error vss-workfile + chr(10)
        + "Ошибка при определении контрольной суммы" + chr(10)
        + substitute("Строка &1", p-string) + chr(10)
        + substitute("Контрольная сумма &1", v-signature) + chr(10)
        + substitute("Должна быть сумма &1", p-check-signature) + chr(10)
        .
    end.
    os-delete value(v-test-file-name) .
  end.
end procedure .
