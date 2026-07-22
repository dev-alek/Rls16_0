block-level on error undo, throw.
define input  parameter p-directory-out    as character no-undo .
define input  parameter p-file-name        as character no-undo .
define input  parameter p-current-user-num as integer   no-undo .
define input  parameter p-max-user-num     as integer   no-undo .
define input  parameter p-user-login       as character no-undo .
define input  parameter p-function         as character no-undo .
define input  parameter p-random-number    as character no-undo .
define input  parameter p-password         as character no-undo .
define input  parameter p-session-id       as character no-undo .
define output parameter p-password-valid   as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rt-req12.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/rt-req12.p $":U .
define variable vss-description as character no-undo init "Обработка запроса радиотерминала 12. Ввод пароля.".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function rtencode returns character
  ( p-init-string as character
  ) :
  define variable v-encode-string as character no-undo .
  if p-init-string = ?
  then do:
    assign
      v-encode-string = '?':u
    .
    return v-encode-string .
  end.
  if p-init-string = '?':u
  then do:
    assign
      v-encode-string = '~~077':u
    .
    return v-encode-string .
  end.
  assign
    v-encode-string = replace(p-init-string,   '~~':u,      '~~176':u)
    v-encode-string = replace(v-encode-string, ':':u,       '~~072':u)
    v-encode-string = replace(v-encode-string, chr(10), '~~015':u)
  .
  return v-encode-string .
end function .
define variable v-hex-digit as character no-undo initial '0123456789ABCDEF' .
define stream sout .
function hex-value returns integer
  ( p-digit as character )
:
  define variable v-index-value as integer   no-undo .
  assign
    v-index-value = index(v-hex-digit, caps(p-digit))
  .
  if v-index-value > 0
  then do:
    return v-index-value - 1 .
  end.
  else do:
    return ? .
  end.
end.
define variable v-des-dll-path    as character no-undo .
define variable v-memptr-filename as memptr    no-undo .
define variable v-library-handle  as integer   no-undo .
define variable v-ret-value       as integer   no-undo .
assign
  v-library-handle = ?
.
do
on stop undo  , retry
on error undo , retry
:
  if retry
  then do:
    if v-library-handle <> ?
    then do:
      run FreeLibrary (input v-library-handle , output v-ret-value ) .
    end.
    assign
      set-size(v-memptr-filename) = 0
    .
    undo, return error return-value .
  end.
  assign
    v-des-dll-path = search("exe/des.dll")
  .
  if v-des-dll-path = ?
  then do:
    undo, return error "Не найдена библиотека des.dll" .
  end.
  assign
    set-size(v-memptr-filename) = length(v-des-dll-path) + 1
  .
  if get-size(v-memptr-filename) = 0
  then do:
    assign
      set-size(v-memptr-filename) = 0
    .
    undo, return error "Error allocating memory for loadining des.dll".
  end.
  assign
    put-string(v-memptr-filename, 1) = v-des-dll-path
  .
  run LoadLibraryA ( input get-pointer-value(v-memptr-filename) , output v-library-handle ) .
  if v-library-handle = 0
  then do:
    undo, return error substitute("Error loading library &1" , v-des-dll-path ).
  end.
  define variable v-status        as character no-undo .
  define variable v-error-message as character no-undo .
  define variable v-session-id    as character no-undo .
  run check-data in this-procedure ( output v-status
                                   , output v-error-message
                                   , output v-session-id
                                   ) .
  run FreeLibrary ( input v-library-handle , output v-ret-value ) .
  assign
    set-size(v-memptr-filename) = 0
  .
  assign
    v-library-handle = ?
  .
  define variable v-temp-file-name as character no-undo .
  assign
    v-temp-file-name = entry(1, p-file-name, '.':u) + '.tmp':u
  .
  output stream sout to value(p-directory-out + '/':u + v-temp-file-name) .
  put stream sout unformatted substitute('status:&1',       rtencode(v-status))
                              + chr(10) .
  put stream sout unformatted substitute('message:&1',      rtencode(v-error-message))
                              + chr(10) .
  put stream sout unformatted substitute('session_id:&1',   rtencode(v-session-id))
                              + chr(10) .
  output stream sout close .
  os-delete value(p-directory-out + '/':u + p-file-name) .
  os-rename value(p-directory-out + '/':u + v-temp-file-name)
            value(p-directory-out + '/':u + p-file-name)
            .
end.
procedure check-data :
  define output parameter p-status        as character no-undo .
  define output parameter p-error-message as character no-undo .
  define output parameter p-ses-id        as character no-undo .
do
on error undo, return error return-value
:
  assign
    p-password = caps(p-password)
  .
  if length(p-password) <> 16
  then do:
    undo, return error "Длина пароля отлична от 16" .
  end.
  define variable v-des-context as memptr no-undo .
  define variable v-key         as memptr no-undo .
  define variable v-input       as memptr no-undo .
  define variable v-output      as memptr no-undo .
  define variable v-sub-code    as memptr no-undo .
  assign
    set-size(v-des-context) = 256
    set-size(v-key)         = 8
    set-size(v-input)       = 8
    set-size(v-output)      = 9
    set-size(v-sub-code)    = 4
  .
  define variable v-password-index  as integer   no-undo .
  define variable v-decode-password as character no-undo .
  define variable v-password-valid  as logical   no-undo .
  define variable v-error-message   as character no-undo .
  do v-password-index = 1 to 8
  :
    assign
      put-byte(v-input, v-password-index) = hex-value(substring(p-password,v-password-index * 2 - 1 ,1)) * 16
                                          + hex-value(substring(p-password,v-password-index * 2     ,1))
    .
  end.
  assign
    put-byte(v-key, 1) = 233
    put-byte(v-key, 2) = 164
    put-byte(v-key, 3) = 39
    put-byte(v-key, 4) = 230
    put-byte(v-key, 5) = 118
    put-byte(v-key, 6) = 25
    put-byte(v-key, 7) = 111
    put-byte(v-key, 8) = 26
  .
  assign
    put-long(v-sub-code, 1) = integer(p-random-number)
  .
  run util_xor
    (input get-pointer-value(v-key)
    ,input get-pointer-value(v-sub-code)
    ) .
  run util_xor
    (input get-pointer-value(v-key) + 4
    ,input get-pointer-value(v-sub-code)
    ) .
  run des_set_key
    (input get-pointer-value(v-des-context)
    ,input get-pointer-value(v-key)
    ) .
  run des_decrypt
    (input get-pointer-value(v-des-context)
    ,input get-pointer-value(v-input)
    ,input get-pointer-value(v-output)
    ) .
  assign
    put-byte(v-output, 9) = 0
  .
  assign
    v-decode-password = get-string(v-output, 1)
  .
  assign
    set-size(v-des-context) = 0
    set-size(v-key)         = 0
    set-size(v-input)       = 0
    set-size(v-output)      = 0
    set-size(v-sub-code)    = 0
  .
  run check-user-password in this-procedure
    (input  p-user-login
    ,input  v-decode-password
    ,input  p-function
    ,output v-password-valid
    ,output v-error-message
    ) .
  assign
    p-password-valid = v-password-valid
  .
  if v-password-valid <> true
  then do:
    define buffer buf_sys-ctrl for ub.sys-ctrl .
    define buffer buf_db       for ub.db .
    define variable v-sys-key   as character no-undo .
    find first buf_sys-ctrl no-lock .
    find first buf_db no-lock
      where buf_db.db-num = buf_sys-ctrl.db-num
      .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile:currsysk.i $ $Revision: $".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currsysk in g#library
  (output v-sys-key
  ) no-error .
    assign
      v-error-message = v-error-message
                      + substitute("БД: &1 &2. Системный ключ &3"
                                  ,buf_db.db-num
                                  ,buf_db.db-name
                                  ,v-sys-key
                                  )
    .
  end.
  if p-current-user-num >= p-max-user-num
  then do:
    assign
      p-status        = '1'
      p-error-message = "Превышено максимально возможное количество работающих пользователей":u
      p-ses-id        = ''
    .
  end.
  else do:
    if v-password-valid = true
    then do:
      assign
        p-status        = '0'
        p-error-message = ''
        p-ses-id        = p-session-id
      .
    end.
    else do:
      assign
        p-status        = '1'
        p-error-message = v-error-message
        p-ses-id        = ''
      .
    end.
  end.
end.
end.
procedure check-user-password :
  define input  parameter p-user-login     as character no-undo .
  define input  parameter p-password       as character no-undo .
  define input  parameter p-function       as character no-undo .
  define output parameter p-password-valid as logical   no-undo .
  define output parameter p-error-message  as character no-undo .
  define variable v-check-password as character no-undo .
  define buffer buf_user for ub._user.
  do
  on error undo, return error return-value
  :
    run adm/pswd-enc.p
      (input encode(p-password)
      ,output v-check-password
      ).
    assign
      v-check-password = encode(v-check-password)
    .
    find first buf_user no-lock
      where buf_user._userid = p-user-login
      no-error .
    if not available buf_user
    then do:
      assign
        p-password-valid = false
        p-error-message  = "Неизвестный пользователь. "
      .
      return .
    end.
    if buf_user._Password <> v-check-password
    then do:
      assign
        p-password-valid = false
        p-error-message  = "Неправильный пароль. "
      .
      return .
    end.
    assign
      p-password-valid = true
    .
  end.
end procedure.
procedure LoadLibraryA external "kernel32.dll"
:
  define input parameter lpFileName as long .
  define return parameter hModule as long .
end.
procedure FreeLibrary external "kernel32.dll"
:
  define input parameter hModule as long .
  define return parameter ret as long .
end.
PROCEDURE des_set_key EXTERNAL "des.dll"
:
    DEFINE INPUT        PARAMETER p_ctx     AS LONG .
    DEFINE INPUT        PARAMETER p_key     AS LONG .
END PROCEDURE.
PROCEDURE des_encrypt EXTERNAL "des.dll"
:
    DEFINE INPUT        PARAMETER p_ctx     AS LONG .
    DEFINE INPUT        PARAMETER p_input   AS LONG .
    DEFINE INPUT        PARAMETER p_output  AS LONG .
END PROCEDURE.
PROCEDURE des_decrypt EXTERNAL "des.dll"
:
    DEFINE INPUT        PARAMETER p_ctx     AS LONG .
    DEFINE INPUT        PARAMETER p_input   AS LONG .
    DEFINE INPUT        PARAMETER p_output  AS LONG .
END PROCEDURE.
PROCEDURE util_xor EXTERNAL "des.dll"
:
    DEFINE INPUT        PARAMETER p_data     AS LONG .
    DEFINE INPUT        PARAMETER p_xor_data AS LONG .
END PROCEDURE.
