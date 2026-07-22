block-level on error undo, throw.
define input parameter p-phrase as character no-undo .
define output parameter p-ok as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка правильности выражения путем подстановки его в prepare-phrase запроса".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
define variable v-phrase as character no-undo .
define variable v-phrase2 as character no-undo .
define variable v-ii as integer no-undo .
define variable v-entry as character no-undo .
define variable v-temp-file as character no-undo .
define buffer buf_file for dictdb._file.
DEFINE QUERY q-file FOR buf_file SCROLLING.
define stream outstream.
do
on error undo, return error
:
  v-phrase = str-encode ( input p-phrase
                         ,input '':U
                         ,input '"').
  v-phrase = replace(p-phrase, chr(34), chr(39)).
  do v-ii = 1 to num-entries(v-phrase, chr(32) ) :
    assign
    v-entry = entry(v-ii, v-phrase, chr(32)).
    if v-entry begins (chr(123) + chr(38))
    and substring(v-entry, length(v-entry), 1) = chr(125) then do:
      run gbl/_tmpfile.p ( input "":U  , input ".p":U, output v-temp-file ).
      output stream outstream to value( v-temp-file ).
      output stream outstream close.
      output stream outstream to value( v-temp-file ) append.
      put stream outstream unformatted "~{ cmp/str-glbl.i ~}" skip.
      put stream outstream unformatted "define output parameter p-string as character no-undo ." skip.
      put stream outstream unformatted "define variable v-date as date no-undo ." skip.
      put stream outstream unformatted "define variable v-decimal as decimal no-undo ." skip.
      put stream outstream unformatted "define variable v-integer as integer no-undo ." skip.
      put stream outstream unformatted "define variable v-logical as logical no-undo ." skip.
      put stream outstream unformatted "assign" skip.
      put stream outstream unformatted "v-date = date(~{1~}) no-error ." skip.
      put stream outstream unformatted "if not error-status:error then do:" skip.
      put stream outstream unformatted  "p-string = ." skip.
      put stream outstream unformatted "  return." skip.
      put stream outstream unformatted "end." skip.
      put stream outstream unformatted "assign" skip.
      put stream outstream unformatted "v-decimal = decimal(~{1~}) no-error ." skip.
      put stream outstream unformatted "if not error-status:error then do:" skip.
      put stream outstream unformatted "  p-string = ." skip.
      put stream outstream unformatted "  return." skip.
      put stream outstream unformatted "end." skip.
      put stream outstream unformatted "assign" skip.
      put stream outstream unformatted "v-integer = integer() no-error ." skip.
      put stream outstream unformatted "if not error-status:error then do:" skip.
      put stream outstream unformatted "  p-string = ." skip.
      put stream outstream unformatted "  return." skip.
      put stream outstream unformatted "end." skip.
      put stream outstream unformatted "p-string = substitute("'&1'", ~{1~})." skip.
      output stream outstream close.
      run value(v-temp-file) ( output v-entry)  v-entry.
    end.
    assign
    v-phrase2 = v-phrase2 + (if v-phrase2 = '':u then '':u else chr(32)) + v-entry.
  end.
  assign
  p-ok = query q-file:query-prepare( substitute(" for each buf_file where &1", v-phrase2))
  no-error.
end.
