block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-imp-handle as handle    no-undo .
define input parameter p-counter  as integer   no-undo .
define input parameter p-mode as character no-undo .
define input parameter p-file-num as integer no-undo .
define input parameter p-file-name as character no-undo .
define input parameter p-path-type as integer no-undo .
define input parameter p-path as character no-undo .
define input parameter p-md5-signature as character no-undo .
define output parameter p-ok as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: 84b48ab2f3b8, 747, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Mon Aug 08 15:24:07 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bin-i.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/bin-i.p $":U .
define variable vss-description as character no-undo init "Прием бинарного файла".
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
define stream sinp .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-binfile-converter-program as character no-undo initial 'exe/base64.exe':U .
define temp-table temp-ext-file-line no-undo like ub.ext-file-line
  .
procedure binfile_clear :
  define input  parameter p-db-num      as integer   no-undo .
  define input  parameter p-from-db-num as integer   no-undo .
  define input  parameter p-file-num    as integer   no-undo .
  define buffer buf_temp-ext-file-line  for temp-ext-file-line .
  do
  on error undo, return error return-value
  :
    for each buf_temp-ext-file-line
      where buf_temp-ext-file-line.db-num   = p-db-num
        and buf_temp-ext-file-line.from-db-num = p-from-db-num
        and buf_temp-ext-file-line.file-num = p-file-num
    on error undo, return error return-value
    :
      delete buf_temp-ext-file-line .
    end.
  end.
end procedure.
procedure binfile_read :
  define input  parameter p-db-num       as integer   no-undo .
  define input  parameter p-from-db-num  as integer   no-undo .
  define input  parameter p-file-num     as integer   no-undo .
  define input  parameter p-file-name    as character no-undo .
  define variable v-temp-file-name        as character no-undo .
  define variable v-convert-full-pathname as character no-undo .
  define variable v-input-full-pathname   as character no-undo .
  define variable v-temp-full-pathname    as character no-undo .
  define variable v-read-line             as character no-undo .
  define variable v-line-num              as integer   no-undo .
  define variable v-command-line          as character no-undo .
  define buffer buf_temp-ext-file-line for temp-ext-file-line .
  do
  on error undo, return error return-value
  :
    run binfile_clear in this-procedure
      (input p-db-num
      ,input p-from-db-num
      ,input p-file-num
      ) .
    run gbl/_tmpfile.p
      (input  't':U
      ,input  '.b64':U
      ,output v-temp-file-name
      ) .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run file-wr in g#library
  (input v-temp-file-name
  ,input '':U
  )  .
    assign
      file-info :file-name    = v-binfile-converter-program
      v-convert-full-pathname = file-info :full-pathname
    .
    assign
      file-info :file-name    = p-file-name
      v-input-full-pathname   = file-info :full-pathname
    .
    assign
      file-info :file-name    = v-temp-file-name
      v-temp-full-pathname    = file-info :full-pathname
    .
    assign
      v-command-line = substitute('&1 -e "&2" &3':U
                                      ,v-convert-full-pathname
                                      ,v-input-full-pathname
                                      ,v-temp-full-pathname
                                      )
    .
    os-command silent value(v-command-line) .
    input stream sinp from value(v-temp-full-pathname) .
    assign
      v-line-num = 0
    .
    repeat
    :
      assign
        v-read-line = '':U
      .
      import stream sinp unformatted v-read-line .
      if v-read-line <> '':U
      then do:
        assign
          v-line-num  = v-line-num + 1
        .
        create buf_temp-ext-file-line .
        assign
          buf_temp-ext-file-line.db-num       = p-db-num
          buf_temp-ext-file-line.from-db-num  = p-from-db-num
          buf_temp-ext-file-line.file-num     = p-file-num
          buf_temp-ext-file-line.line-num     = v-line-num
          buf_temp-ext-file-line.sub-line-num = 0
          buf_temp-ext-file-line.line-text    = v-read-line
        .
      end.
    end.
    input stream sinp close .
    os-delete value(v-temp-full-pathname) .
  end.
end procedure.
procedure binfile_write :
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-from-db-num   as integer   no-undo .
  define input  parameter p-file-num      as integer   no-undo .
  define input  parameter p-bin-file-name as character no-undo .
  define variable v-temp-file-name        as character no-undo .
  define variable v-temp-full-pathname    as character no-undo .
  define variable v-output-full-pathname  as character no-undo .
  define variable v-convert-full-pathname as character no-undo .
  define variable v-command-line          as character no-undo .
  define buffer buf_temp-ext-file-line for temp-ext-file-line .
  do
  on error undo, return error return-value
  :
    run gbl/_tmpfile.p
      (input  't':U
      ,input  '.b64':U
      ,output v-temp-file-name
      ) .
    output stream sinp to value(v-temp-file-name) .
    for each buf_temp-ext-file-line
      where buf_temp-ext-file-line.db-num   = p-db-num
        and buf_temp-ext-file-line.from-db-num = p-from-db-num
        and buf_temp-ext-file-line.file-num = p-file-num
    by buf_temp-ext-file-line.line-num
    by buf_temp-ext-file-line.sub-line-num
    on error undo, return error return-value
    :
      put stream sinp unformatted
        buf_temp-ext-file-line.line-text + chr(10)
        .
    end.
    output stream sinp close .
    assign
      file-info :file-name    = v-binfile-converter-program
      v-convert-full-pathname = file-info :full-pathname
    .
    assign
      file-info :file-name    = v-temp-file-name
      v-temp-full-pathname    = file-info :full-pathname
    .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run file-wr in g#library
  (input p-bin-file-name
  ,input '':U
  )  .
    assign
      file-info :file-name    = p-bin-file-name
      v-output-full-pathname   = file-info :full-pathname
    .
    assign
      v-command-line =  substitute('&1 -d &2 "&3"':U
                                  ,v-convert-full-pathname
                                  ,v-temp-full-pathname
                                  ,v-output-full-pathname
                                  )
    .
    os-command silent value(v-command-line) .
    os-delete value(v-temp-full-pathname) .
  end.
end procedure.
procedure binfile_clear-from-db :
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-from-db-num   as integer   no-undo .
  define input  parameter p-file-num      as integer   no-undo .
  define buffer buf_ext-file-line for ub.ext-file-line .
  do
  on error undo, return error return-value
  :
    for each buf_ext-file-line
      where buf_ext-file-line.db-num   = p-db-num
        and buf_ext-file-line.from-db-num   = p-from-db-num
        and buf_ext-file-line.file-num = p-file-num
    on error undo, return error return-value
    :
      delete buf_ext-file-line .
    end.
  end.
end procedure.
procedure binfile_read-to-db :
  define input  parameter p-db-num         as integer   no-undo .
  define input  parameter p-from-db-num    as integer   no-undo .
  define input  parameter p-file-num       as integer   no-undo .
  define input  parameter p-file-name      as character no-undo .
  define variable v-temp-file-name        as character no-undo .
  define variable v-convert-full-pathname as character no-undo .
  define variable v-input-full-pathname   as character no-undo .
  define variable v-temp-full-pathname    as character no-undo .
  define variable v-read-line             as character no-undo .
  define variable v-line-num              as integer   no-undo .
  define variable v-command-line          as character no-undo .
  define buffer buf_ext-file-line for ub.ext-file-line .
  do
  on error undo, return error return-value
  :
    run binfile_clear-from-db in this-procedure
      (input p-db-num
      ,input p-from-db-num
      ,input p-file-num
      ) .
    run gbl/_tmpfile.p
      (input  't':U
      ,input  '.b64':U
      ,output v-temp-file-name
      ) .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run file-wr in g#library
  (input v-temp-file-name
  ,input '':U
  )  .
    assign
      file-info :file-name    = v-binfile-converter-program
      v-convert-full-pathname = file-info :full-pathname
    .
    assign
      file-info :file-name    = p-file-name
      v-input-full-pathname   = file-info :full-pathname
    .
    assign
      file-info :file-name    = v-temp-file-name
      v-temp-full-pathname    = file-info :full-pathname
    .
    assign
      v-command-line = substitute('&1 -e "&2" "&3"':U
                                      ,v-convert-full-pathname
                                      ,v-input-full-pathname
                                      ,v-temp-full-pathname
                                      )
    .
    os-command silent value(v-command-line) .
    input stream sinp from value(v-temp-full-pathname) .
    assign
      v-line-num = 0
    .
    repeat
    :
      assign
        v-read-line = '':U
      .
      import stream sinp unformatted v-read-line .
      if v-read-line <> '':U
      then do:
        assign
          v-line-num  = v-line-num + 1
        .
        create buf_ext-file-line .
        assign
          buf_ext-file-line.db-num       = p-db-num
          buf_ext-file-line.from-db-num  = p-from-db-num
          buf_ext-file-line.file-num     = p-file-num
          buf_ext-file-line.line-num     = v-line-num
          buf_ext-file-line.sub-line-num = 0
          buf_ext-file-line.line-text    = v-read-line
        .
      end.
    end.
    input stream sinp close .
    os-delete value(v-temp-full-pathname) .
  end.
end procedure.
procedure binfile_write-from-db :
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-from-db-num   as integer   no-undo .
  define input  parameter p-file-num      as integer   no-undo .
  define input  parameter p-bin-file-name as character no-undo .
  define variable v-temp-file-name        as character no-undo .
  define variable v-temp-full-pathname    as character no-undo .
  define variable v-output-full-pathname  as character no-undo .
  define variable v-convert-full-pathname as character no-undo .
  define variable v-command-line          as character no-undo .
  define buffer buf_ext-file-line for ub.ext-file-line .
  do
  on error undo, return error return-value
  :
    run gbl/_tmpfile.p
      (input  't':U
      ,input  '.b64':U
      ,output v-temp-file-name
      ) .
    output stream sinp to value(v-temp-file-name) .
    for each buf_ext-file-line
      where buf_ext-file-line.db-num   = p-db-num
        and buf_ext-file-line.from-db-num   = p-from-db-num
        and buf_ext-file-line.file-num = p-file-num
    by buf_ext-file-line.line-num
    by buf_ext-file-line.sub-line-num
    on error undo, return error return-value
    :
      put stream sinp unformatted
        buf_ext-file-line.line-text + chr(10)
        .
    end.
    output stream sinp close .
    assign
      file-info :file-name    = v-binfile-converter-program
      v-convert-full-pathname = file-info :full-pathname
    .
    assign
      file-info :file-name    = v-temp-file-name
      v-temp-full-pathname    = file-info :full-pathname
    .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run file-wr in g#library
  (input p-bin-file-name
  ,input '':U
  )  .
    assign
      file-info :file-name    = p-bin-file-name
      v-output-full-pathname   = file-info :full-pathname
    .
    assign
      v-command-line =  substitute('&1 -d &2 "&3"':U
                                  ,v-convert-full-pathname
                                  ,v-temp-full-pathname
                                  ,v-output-full-pathname
                                  )
    .
    os-command silent value(v-command-line) .
    os-delete value(v-temp-full-pathname) .
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE verify-ini-entry:
DEFINE INPUT  PARAMETER ini-key-name     as character no-undo.
DEFINE INPUT  PARAMETER ini-section-name as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text   as character no-undo.
DEFINE INPUT  PARAMETER silence          as logical no-undo.
DEFINE OUTPUT PARAMETER ini-entry-value  as character no-undo INIt ?.
define variable v-mess as character no-undo .
get-key-value section ini-section-name key ini-key-name value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "spl"
then
get-key-value section ini-section-name key "splall" value ini-entry-value.
if ini-entry-value = ? and ini-key-name begins "sav"
then
get-key-value section ini-section-name key "savall" value ini-entry-value.
if ini-entry-value = ? then do:
  assign
  v-mess = substitute("Ошибка ini - файла:&1Секция &2&1Ключ &3&1&4"
                    , chr(10)
                    , ini-section-name
                    , ini-key-name
                    , error-msg-text).
    if not silence then do:
      message
      v-mess
      view-as alert-box ERROR  .
      return error.
    end.
    else do:
      return error v-mess.
    end.
end.
END PROCEDURE.
PROCEDURE verify-file:
DEFINE INPUT  PARAMETER filename       as character no-undo.
DEFINE INPUT  PARAMETER error-msg-text as character no-undo.
DEFINE INPUT  PARAMETER silence        as logical no-undo.
DEFINE OUTPUT PARAMETER found          as logical no-undo.
file-info:file-name = filename.
found = NOT (file-info:full-pathname = ?).
if NOT found  then do:
  if not silence then do:
    message error-msg-text
    view-as alert-box ERROR.
    return error.
  end.
  else return error error-msg-text.
end.
END PROCEDURE.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function prepare-path returns character ( input p-nonprepared-path as character ):
define variable v-prepared-path as character no-undo .
assign
v-prepared-path = replace(p-nonprepared-path, chr(92), chr(47))
v-prepared-path = right-trim(v-prepared-path, chr(47))
.
return v-prepared-path.
END FUNCTION.
function prepare-path2 returns character ( input p-nonprepared-path as character ):
define variable v-prepared-path as character no-undo .
assign
v-prepared-path = replace(p-nonprepared-path, chr(47), chr(92))
v-prepared-path = right-trim(v-prepared-path, chr(92))
.
return v-prepared-path.
END FUNCTION.
function quote-spaces returns character ( input p-full-path as character):
define variable v-ii as integer no-undo .
define variable v-result as character no-undo .
do v-ii = 1 to num-entries(p-full-path, chr(92)):
  v-result = v-result + (if v-ii = 1 then '' else chr(92)) +
             (if index(entry(v-ii, p-full-path, chr(92)), chr(32)) > 0
             then  substitute("&1&2&1", chr(34), entry(v-ii, p-full-path, chr(92)))
             else entry(v-ii, p-full-path, chr(92))
             )
  .
end.
return v-result.
end function.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table tt-ext-file-par no-undo like ub.ext-file-par.
procedure ext-file-par-clear-temp :
  define buffer buf_tt-ext-file-par for tt-ext-file-par .
  do
  on error undo, return error return-value
  :
    for each buf_tt-ext-file-par
    on error undo, return error
    :
      delete buf_tt-ext-file-par .
    end.
  end.
end procedure.
procedure ext-file-par-write-temp :
  define input  parameter p-db-num      as integer no-undo .
  define input  parameter p-from-db-num      as integer no-undo .
  define input  parameter p-file-num      as integer no-undo .
  define input  parameter p-param-num      as integer no-undo .
  define input  parameter p-value-type as character no-undo .
  define input  parameter p-value-name as character no-undo .
  define input  parameter p-value-char as character no-undo .
  define input  parameter p-value-date as date      no-undo .
  define input  parameter p-value-integer as integer      no-undo .
  define input  parameter p-value-decimal as decimal      no-undo .
  define input  parameter p-value-logical as logical      no-undo .
  define buffer buf_tt-ext-file-par for tt-ext-file-par .
  do
  on error undo, return error return-value
  :
    find first buf_tt-ext-file-par
      where buf_tt-ext-file-par.db-num        = p-db-num
        and buf_tt-ext-file-par.file-num      = p-file-num
        and buf_tt-ext-file-par.from-db-num   = p-from-db-num
        and buf_tt-ext-file-par.param-type    = p-value-type
        and buf_tt-ext-file-par.param-name    = p-value-name
      no-error .
    if not available buf_tt-ext-file-par then do:
      create buf_tt-ext-file-par .
      assign
        buf_tt-ext-file-par.db-num         = p-db-num
        buf_tt-ext-file-par.from-db-num    = p-from-db-num
        buf_tt-ext-file-par.file-num       = p-file-num
        buf_tt-ext-file-par.param-num      = p-param-num
        buf_tt-ext-file-par.param-type     = p-value-type
        buf_tt-ext-file-par.user-db-num    = p-db-num
              .
    end.
    CASE p-value-type:
      when 'C':U
      or when 'uniq-key-rec':U
      then do:
        assign
        buf_tt-ext-file-par.param-name = p-value-name
        buf_tt-ext-file-par.param-value = p-value-char
        .
      end.
      when 'T':U then do:
        assign
        buf_tt-ext-file-par.param-date-name = p-value-name
        buf_tt-ext-file-par.param-date-value = p-value-date
        .
      end.
      when 'I':U then do:
        assign
        buf_tt-ext-file-par.param-int-name = p-value-name
        buf_tt-ext-file-par.param-int-value = p-value-integer
        .
      end.
      when 'L':U then do:
        assign
        buf_tt-ext-file-par.param-log-name = p-value-name
        buf_tt-ext-file-par.param-log-value = p-value-logical
        .
      end.
      when 'D':U then do:
        assign
        buf_tt-ext-file-par.param-decimal-name = p-value-name
        buf_tt-ext-file-par.param-decimal-value = p-value-decimal
        .
      end.
    END CASE.
  end.
end procedure.
procedure ext-file-par-write-and-send :
  define input  parameter p-db-num      as integer no-undo .
  define input  parameter p-from-db-num      as integer no-undo .
  define input  parameter p-file-num      as integer no-undo .
  define input  parameter p-param-num      as integer no-undo .
  define input  parameter p-value-type as character no-undo .
  define input  parameter p-value-name as character no-undo .
  define input  parameter p-value-char as character no-undo .
  define input  parameter p-value-date as date      no-undo .
  define input  parameter p-value-integer as integer      no-undo .
  define input  parameter p-value-decimal as decimal      no-undo .
  define input  parameter p-value-logical as logical      no-undo .
  define input  parameter p-send        as logical no-undo .
  define input  parameter p-list-db-num as character no-undo .
  define buffer buf_ext-file-par for ub.ext-file-par .
  do
  on error undo, return error return-value
  :
    find first buf_ext-file-par
      where buf_ext-file-par.db-num         = p-db-num
        and buf_ext-file-par.from-db-num    = p-from-db-num
        and buf_ext-file-par.file-num       = p-file-num
        and buf_ext-file-par.param-num      = p-param-num
      no-error .
    if not available buf_ext-file-par then do:
      create buf_ext-file-par .
      assign
        buf_ext-file-par.db-num    = p-db-num
        buf_ext-file-par.from-db-num    = p-from-db-num
        buf_ext-file-par.file-num    = p-file-num
        buf_ext-file-par.param-num    = p-param-num
        buf_ext-file-par.param-type   = p-value-type
        buf_ext-file-par.user-db-num    = p-db-num
      .
    end.
    CASE p-value-type:
      when 'C':U
      or when ''
      or when 'uniq-key-rec':U
      then do:
        assign
        buf_ext-file-par.param-name = p-value-name
        buf_ext-file-par.param-value = p-value-char
        .
        if p-value-type = ''
        and p-param-num = 0 then do:
          buf_ext-file-par.param-log-value = p-value-logical.
        end.
      end.
      when 'T':U then do:
        assign
        buf_ext-file-par.param-date-name = p-value-name
        buf_ext-file-par.param-date-value = p-value-date
        .
      end.
      when 'I':U then do:
        assign
        buf_ext-file-par.param-int-name = p-value-name
        buf_ext-file-par.param-int-value = p-value-integer
        .
      end.
      when 'D':U then do:
        assign
        buf_ext-file-par.param-decimal-name = p-value-name
        buf_ext-file-par.param-decimal-value = p-value-decimal
        .
      end.
      when 'L':U then do:
        assign
        buf_ext-file-par.param-log-name = p-value-name
        buf_ext-file-par.param-log-value = p-value-logical
        .
      end.
    END CASE.
    if p-send then do:
      run nws/cr-route.p (
                      input 'send-tbl':U
                    , input 'ext-file-par':U
                    , input buffer buf_ext-file-par:handle
                    , input p-list-db-num) no-error.
    end.
  end.
end procedure.
define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable v-full-path-name as character no-undo .
define variable log-file-name as character no-undo init "":U.
define variable v-path as character no-undo .
define variable v-md5-signature as character no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define variable v-can-write               as logical no-undo .
define variable v-dir-name                as character no-undo .
define variable v-ini-section as character no-undo .
define variable v-ini-key as character no-undo .
define variable v-ini-path-dir as character no-undo .
define variable v-file-num as integer no-undo .
define variable v-temp-file-name as character no-undo .
define variable v-run-name as character no-undo .
define variable v-res-message as character no-undo .
define variable v-err-num as integer no-undo .
define variable v-err-mess as character no-undo .
define buffer buf_temp-ext-file-line for temp-ext-file-line .
define buffer buf_ext-file-line for ub.ext-file-line.
define buffer buf_ext-file for ub.ext-file.
define temp-table temp-ext-file no-undo like ub.ext-file.
define buffer buf_temp-ext-file for temp-ext-file.
define temp-table temp-ext-file-par no-undo like ub.ext-file-par.
define buffer buf_ext-file-par for ub.ext-file-par .
define buffer buf_temp-ext-file-par for temp-ext-file-par .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  run write-to-log in p-log-handle (
        input substitute("Получение бинарного файла &1: режим &2"
                         , p-file-name
                         , p-mode )).
  _counter:
  do counter = 1 to p-counter
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :
    if counter modulo 10 = 0
    then do:
      run write-to-screen in p-log-handle (substitute("Получено записей &1", counter)) no-error.
    end.
    run nws-imps in p-imp-handle
      ( input-output counter
       ,output       rec-full
      ) no-error.
    if error-status :error then do:
      undo main-block, return error return-value .
    end.
    assign
      v-rec-name = entry( 1, rec-full, chr(1) )
    .
    CASE entry(1, v-rec-name, chr(4)) :
      when 'ext-file':U then do:
        create buf_temp-ext-file .
        run nws-impl in p-imp-handle
          ( input 'ext-file':U
           ,input (buffer buf_temp-ext-file:handle)
          ) no-error.
        if error-status :error then do:
          undo main-block, return error return-value .
        end.
        if v-err-num > 0 then do:
          delete buf_temp-ext-file.
          next _counter.
        end.
        if p-mode = 'save-install':U then do:
          if entry(2, buf_temp-ext-file.file-type, ".") <> "mf":U then do:
            v-err-num = 1.
            v-err-mess = substitute( "!!!Ошибки при приеме файла &1 (режим &2)&3" +
                                                "неверная ссылка на манифест пакета обновления&3" +
                                                "Файл обновления принят не будет"
                                                , p-file-name
                                                , p-mode
                                                , chr(10)).
          end.
          if buf_temp-ext-file.file-type <> buf_temp-ext-file.file-name then do:
            find first buf_ext-file no-lock where
                    buf_Ext-file.db-num = buf_temp-ext-file.db-num
                and buf_Ext-file.from-db-num = buf_temp-ext-file.from-db-num
                and  buf_Ext-file.file-name = buf_temp-ext-file.file-type no-error.
            if not available buf_Ext-file then do:
              v-err-num = 2.
              v-err-mess = substitute( "!!!Ошибки при приеме файла &1 (режим &2)&3" +
                                                  "в БД отсутствует манифест пакета обновления &4&3" +
                                                  "Файл обновления принят не будет"
                                                  , p-file-name
                                                  , p-mode
                                                  , chr(10)
                                                  , buf_temp-ext-file.file-type
                                                  ).
            end.
          end.
        end.
        if buf_temp-Ext-file.file-num <> p-file-num
        and (p-mode = 'save-db':U
            or
            p-mode = 'save-install':U
            or
            p-mode = 'save-db-and-run':U
            )
        then do:
          v-err-num = 3.
          v-err-mess = substitute("!!!Ошибки при приеме файла &1 (режим &2)&3" +
                                              "номер файла &4 в шапке файла не совпадает с номером файла в команде  - &5&3" +
                                              "Бинарный файл принят/запущен не будет"
                                                    , p-file-name
                                                    , p-mode
                                                    , chr(10)
                                                    , buf_temp-Ext-file.file-num
                                                    , p-file-num
                                                  ).
        end.
        find first buf_ext-file where
                  buf_Ext-file.db-num = buf_temp-ext-file.db-num
              and buf_Ext-file.from-db-num = buf_temp-ext-file.from-db-num
              and buf_Ext-file.file-num = buf_temp-ext-file.file-num  no-error.
        if not available buf_Ext-file then do:
          create buf_ext-file.
        end.
        buffer-copy
        buf_temp-ext-file to
        buf_ext-file .
      end.
      when 'ext-file-line':U then do:
        create buf_temp-ext-file-line .
        run nws-impl in p-imp-handle
          ( input 'ext-file-line':U
           ,input (buffer buf_temp-ext-file-line:handle)
          ) no-error.
        if error-status :error then do:
          undo main-block, return error return-value .
        end.
        if v-err-num > 0 then do:
          delete buf_temp-ext-file-line.
          next _counter.
        end.
        if buf_temp-Ext-file-line.file-num <> p-file-num then do:
           v-err-num = 4.
           v-err-mess =  substitute("!!!Ошибки при приеме файла &1 (режим &2)&3" +
                                              "номер файла &4 в строке файла не совпадает с номером файла в команде  - &5&3" +
                                              "Бинарный файл принят/запущен не будет"
                                                    , p-file-name
                                                    , p-mode
                                                    , chr(10)
                                                    , buf_temp-Ext-file-line.file-num
                                                    , p-file-num
                                                  ).
        end.
        if p-mode = 'save-db':U
        or p-mode = 'save-db-and-run':U
        then do:
          find first buf_ext-file-line where
                   buf_Ext-file-line.db-num = buf_temp-ext-file-line.db-num
               and buf_Ext-file-line.from-db-num = buf_temp-ext-file-line.from-db-num
               and buf_Ext-file-line.file-num = buf_temp-ext-file-line.file-num
               and buf_Ext-file-line.line-num = buf_temp-ext-file-line.line-num
               and buf_Ext-file-line.sub-line-num = buf_temp-ext-file-line.sub-line-num no-error.
          if not available buf_Ext-file-line then do:
            create buf_Ext-file-line.
          end.
          buffer-copy
          buf_temp-ext-file-line to
          buf_ext-file-line .
        end.
      end.
      when 'ext-file-par':U then do:
          create buf_temp-ext-file-par .
          run nws-impl in p-imp-handle
            ( input 'ext-file-par':U
             ,input (buffer buf_temp-ext-file-par:handle)
            ) no-error.
          if error-status :error then do:
            undo main-block, return error return-value .
          end.
          if v-err-num > 0 then do:
            delete buf_temp-ext-file-par.
            next _counter.
          end.
          if buf_temp-ext-file-par.file-num <> p-file-num then do:
            v-err-num = 5.
            v-err-mess = substitute("!!!Ошибки при приеме файла &1 (режим &2)&3" +
                                              "номер файла &4 в строке параметров не совпадает с номером файла в команде  - &5&3" +
                                              "Бинарный файл принят/запущен не будет"
                                                      , p-file-name
                                                      , p-mode
                                                      , chr(10)
                                                      , buf_temp-ext-file-par.file-num
                                                      , p-file-num
                                                    ).
          end.
          find first buf_ext-file-par where
                    buf_ext-file-par.db-num = buf_temp-ext-file-par.db-num
                and buf_ext-file-par.from-db-num = buf_temp-ext-file-par.from-db-num
                and buf_ext-file-par.file-num = buf_temp-ext-file-par.file-num
                and buf_ext-file-par.param-num = buf_temp-ext-file-par.param-num no-error.
          if not available buf_ext-file-par then do:
            create buf_ext-file-par.
          end.
          buffer-copy
          buf_temp-ext-file-par to
          buf_ext-file-par .
      end.
    END CASE.
  end.
  if v-err-num > 0 then do:
    run write-to-log in p-log-handle ( input v-err-mess).
    undo main-block.
  end.
    if (p-mode = 'save-install':U
  or p-mode = 'save-disk':U
  or p-mode = 'save-disk-and-run':U
  )
  and p-path-type = 1 then do:
    assign
    v-full-path-name = prepare-path(p-path) + chr(47) + p-file-name
    v-dir-name = p-path
    .
  end.
  if p-mode = 'save-db-and-run':U
  then do:
    run gbl/_tmpfile.p (
                      input  't':U
                    ,input  (if num-entries(p-file-name, ".") > 1
                             then entry(num-entries(p-file-name, "."), p-file-name, ".")
                             else  "p")
                    ,output v-temp-file-name
                    ) .
    assign
    v-full-path-name = v-temp-file-name
    .
  end.
  if (p-mode = 'save-install':U
  or p-mode = 'save-disk':U
  or p-mode = 'save-disk-and-run':U
  )
  and p-path-type = 0
  then do:
    run gbl/filename.p (
                   input replace(this-procedure:filename, ".p", ".r")
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
    if error-status:error then do:
      run gbl/filename.p (
                   input (this-procedure:filename)
                  ,output v-full-path
                  ,output v-path
                  ,output v-file-name
                  ,output v-file-name-no-ext
                  ,output v-file-name-ext
                  ) no-error .
    if error-status:error then do:
       v-err-mess =  substitute("&1 &2 &3&4Ошибка при определении имени файла &5&4" +
                                          "&6&4&7&4" +
                                          "для определения рабочей директории&4" +
                                          "Бинарный файл принят/запущен не будет"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,chr(10)
                                          ,(this-procedure:filename)
                                          ,error-status:get-message(1)
                                          ,return-value ).
     run write-to-log in p-log-handle ( input v-err-mess).
      undo main-block, return.
    end.
    end.
    assign
    v-full-path-name = v-path +  chr(47) +
                      prepare-path (p-path) +  chr(47) +
                      p-file-name
    v-dir-name =   v-path + chr(47) +
                  prepare-path (p-path)
    .
  end.
  if (p-mode = 'save-install':U
  or p-mode = 'save-disk':U
  or p-mode = 'save-disk-and-run':U
  )
  and p-path-type = 2 then do:
    assign
    v-ini-section = entry(1, p-path)
    v-ini-key = entry(2, p-path)
    .
    RUN verify-ini-entry in this-procedure (
                           input v-ini-key
                          ,input v-ini-section
                          ,input substitute("не удалось определить значение параметра ini-файла&1" +
                                            "секция &2 ключ &3"
                                          , chr(10)
                                          , v-ini-section
                                          , v-ini-key
                                          )
                          ,input yes
                          ,output v-ini-path-dir) no-error.
    if error-status:error then do:
      v-err-mess =  substitute("&2&1&3&1&4&1&5&1&6&1" +
                                         "Бинарный файл принят/запущен не будет"
                ,chr(10)
                ,vss-workfile
                ,vss-revision
                ,vss-description
                , error-status:get-message(1)
                , return-value
                ).
      run write-to-log in p-log-handle ( input v-err-mess).
      undo main-block, return ''.
    end.
    assign
    v-full-path-name =  prepare-path ( v-ini-path-dir) + chr(47) + p-file-name
    v-dir-name = v-ini-path-dir
    .
  end.
  if not (p-mode = 'save-db':U
          or
          p-mode = 'save-db-and-run':U
          )
  then do:
    FILE-INFO:FILE-NAME = v-dir-name.
    if index(FILE-INFO:file-type, 'F') > 0 then do:
      v-err-mess = substitute("&1 &2 &3&4Путь, указанный как директория для пересылаемого файла &5 - является файлом&6&4" +
                                         "Бинарный файл принят/запущен не будет"
                                          ,vss-workfile
                                          ,vss-revision
                                          ,vss-description
                                          ,chr(10)
                                          ,p-file-name
                                          ,v-dir-name).
      run write-to-log in p-log-handle ( input v-err-mess).
      undo main-block, return ''.
    end.
    if file-info:FULL-pathname = ? then do:
      run gbl/dir-cre.p ( input v-dir-name)  no-error.
      if error-status:error then do:
        v-err-mess = substitute("&1 &2 &3&4Ошибка при создании директории &5&4" +
                                            "&6&4&7&4" +
                                            "Бинарный файл принят/запущен не будет"
                                              ,vss-workfile
                                              ,vss-revision
                                              ,vss-description
                                              ,chr(10)
                                              ,v-dir-name
                                              , error-status:get-message(1)
                                              , return-value
                                              ).
        run write-to-log in p-log-handle ( input v-err-mess).
        undo main-block, return ''.
      end.
    end.
    v-can-write = index(FILE-INFO:file-type, 'W') > 0.
    if not v-can-write then do:
      v-err-mess = substitute("&1 &2 &3&4Отсутствуют права на запись в директорию &5&4" +
                                           "Бинарный файл принят/запущен не будет"
                                            ,vss-workfile
                                            ,vss-revision
                                            ,vss-description
                                            ,chr(10)
                                            ,v-dir-name).
      run write-to-log in p-log-handle ( input v-err-mess).
      undo main-block, return ''.
    end.
  end.
  if p-mode = 'save-db':U
  or p-mode = 'save-db-and-run':U
  then do:
    ASSIGN
    v-run-name = prepare-path(buf_ext-file.FILE-NAME)
    v-run-name = entry(num-entries(v-run-name, chr(47))
                            , v-run-name
                            , chr(47)
                            ).
  end.
  if p-mode = 'save-disk':U
  or p-mode = 'save-install':U
  or p-mode = 'save-disk-and-run':U
  or p-mode = 'save-db-and-run':U
  then do:
    run binfile_write in this-procedure (
       input  buf_temp-ext-file.db-num
      ,input  buf_temp-ext-file.from-db-num
      ,input  p-file-num
      ,input  v-full-path-name
      ) .
    run gbl/md5.p (
        input  v-full-path-name
      ,output v-md5-signature
      ) .
    if v-md5-signature <> p-md5-signature then do:
      os-delete value(v-full-path-name).
      run write-to-log in p-log-handle (
                                         substitute("!!!Принятый файл &1 (режим &2) имеет неверную сигнатуру md5 - удаляется"
                                                , p-file-name
                                                , p-mode
                                                )).
    end.
    assign
    buf_ext-file.file-name = buf_ext-file.file-name + ">" + prepare-path(p-path) + chr(47).
  end.
  if p-mode = 'save-db-and-run':U
  or p-mode = 'save-disk-and-run':U
  then do:
    define variable v-stop as logical no-undo init yes.
    do on stop undo, next:
      run write-to-log in p-log-handle (
                                         substitute("Запускается принятый файл &1 (режим &2)"
                                                , p-file-name
                                                , p-mode
                                                )).
      run value (v-full-path-name ) (
                                      INPUT parparentproc
                                    , INPUT p-parent-handle
                                    , INPUT p-log-handle
                                    , input (string(buf_ext-file.db-num) + chr(4) +
                                             string(buf_ext-file.from-db-num) + chr(4) +
                                             string(buf_Ext-file.file-num))
                                  )
      no-error.
      v-stop = no.
    end.
    if error-status:error
    or v-stop then do:
      assign
      v-res-message =  substitute("!!!Ошибка при запуске принятого файла &1 (режим &2)&3&4&3&5&3"
                                                                                  , p-file-name
                                                                                  , p-mode
                                                                                  , chr(10)
                                                                                  , error-status:get-message(1)
                                                                                  , return-value).
      run write-to-log in p-log-handle (
                                        substitute("!!!Ошибка при запуске принятого файла &1 (режим &2)&3&4&3&5&3"
                                                                                  , p-file-name
                                                                                  , p-mode
                                                                                  , chr(10)
                                                                                  , error-status:get-message(1)
                                                                                  , return-value)
                                         ).
    end.
    else do:
      assign
      v-res-message =  if return-value = "" then  substitute("OK запуске принятого файла &1 (режим &2)"
                                                             , p-file-name
                                                             , p-mode
                                                            )
                       else return-value.
    end.
    find first buf_ext-file-par where
              buf_ext-file-par.db-num = buf_Ext-file.db-num
          and buf_ext-file-par.from-db-num = buf_Ext-file.from-db-num
          and buf_ext-file-par.file-num = buf_Ext-file.file-num
          and buf_ext-file-par.param-num = 0  no-error.
    if not available buf_ext-file-par then do:
      create  buf_ext-file-par.
      assign
      buf_ext-file-par.db-num = buf_Ext-file.db-num
      buf_ext-file-par.from-db-num = buf_Ext-file.from-db-num
      buf_ext-file-par.file-num = buf_Ext-file.file-num
      buf_ext-file-par.param-num = 0
      buf_ext-file-par.param-type = '':U
      buf_ext-file-par.param-name = v-run-name
      buf_ext-file-par.user-db-num = g#db-num
      .
    end .
    else do:
        run clear-record in this-procedure ( buffer buf_ext-file-par).
    end.
    assign
    buf_ext-file-par.param-name  =  substitute("Результат выполнения принятого файла  &1 (режим &2)"
                                              , p-file-name
                                              , p-mode)
    buf_ext-file-par.param-value =  v-res-message
    .
    run nws/cr-route.p (
                      input 'send-tbl':U
                    , input 'ext-file-par':U
                    , input buffer buf_ext-file-par:handle
                    , input string(g#news-source-db)) no-error.
  end.
  p-ok = yes.
  return '':U.
end.
procedure write-to-log :
define input parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
     run write-to-log in p-parent-handle (input p-message) .
  end.
end procedure.
procedure clear-record :
define parameter buffer buf_ext-file-par for ub.ext-file-par.
  do
  on error undo, return error return-value
  :
     assign
     buf_ext-file-par.param-name         = '':U
     buf_ext-file-par.param-value        = '':U
     buf_ext-file-par.param-date-name    = '':U
     buf_ext-file-par.param-date-value   = ?
     buf_ext-file-par.param-int-name     = '':U
     buf_ext-file-par.param-int-value    = 0
     buf_ext-file-par.param-log-name     = '':U
     buf_ext-file-par.param-log-value    = no
     buf_ext-file-par.param-decimal-name     = '':U
     buf_ext-file-par.param-decimal-value    = 0.0
     .
  end.
end procedure.
