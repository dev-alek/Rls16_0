block-level on error undo, throw.
define input  parameter p-range-type like ub.code-range.range-type no-undo .
define output parameter p-param-code like ub.config.param-code     no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "определение конфигурационного параметра по типу диапазона".
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
      p-vss-parameters = substitute('&1':u,p-range-type)
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
do
on error undo, return error
:
  case p-range-type:
    when 'bcgb':U then do:
      assign
        p-param-code = 'cdrgbcgb':U
      .
    end.
    when 'scgb':U then do:
      assign
        p-param-code = 'cdrgscgb':U
      .
    end.
    when 'sclc':U then do:
      assign
        p-param-code = 'cdrgsclc':U
      .
    end.
    when 'ssgb':U then do:
      assign
        p-param-code = 'cdrgssgb':U
      .
    end.
    when 'sslc':U then do:
      assign
        p-param-code = 'cdrgsslc':U
      .
    end.
    when 'pglc':U then do:
      assign
        p-param-code = 'cdrgpglc':U
      .
    end.
    when 'dcgb':U then do:
      assign
        p-param-code = 'cdrgdcgb':U
      .
    end.
    when 'drgb':U then do:
      assign
        p-param-code = 'cdrgdrgb':U
      .
    end.
    when 'ctgb':U then do:
      assign
        p-param-code = 'cdrgctgb':U
      .
    end.
    when 'fmgb':U then do:
      assign
        p-param-code = 'cdrgfmgb':U
      .
    end.
    when 'pngb':U then do:
      assign
        p-param-code = 'cdrgpngb':U
      .
    end.
    when 'cagb':U then do:
      assign
        p-param-code = 'cdrgcagb':U
      .
    end.
    when 'fdgb':U then do:
      assign
        p-param-code = 'cdrgfdgb':U
      .
    end.
  end case.
end.
