DEFINE INPUT        PARAMETER pParameters  AS CHARACTER NO-UNDO.
define input        parameter pTech        as logical no-undo .
DEFINE INPUT-OUTPUT PARAMETER pValue       AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER pSecondValue AS CHARACTER NO-UNDO.
define variable vss-revision    as character no-undo init "$Revision: 3d3ba7fff1ab, 2269, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:24:02 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: d-invAttr.w $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/d-invAttr.w $":U .
define variable vss-description as character no-undo init "Универсальный диалог для ввода данных".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure sel-date :
  define input  parameter p-date-handle as handle    no-undo .
  define input  parameter p-description as character no-undo .
  do
  on error undo, return error return-value
  :
    if (can-query (p-date-handle, "sensitive")
      and
      p-date-handle :sensitive = true
      )
    or (can-query (p-date-handle, "read-only")
      and
      p-date-handle :read-only = false
      )
    then do:
      if p-date-handle :handle <> focus :handle
      then do:
        apply "entry":u to p-date-handle .
      end.
      define variable v-ok            as logical no-undo .
      define variable v-curr-sv-date as date no-undo .
      assign
        v-curr-sv-date = date(p-date-handle :screen-value) no-error
      .
      if v-curr-sv-date = ?
      then do:
        run gbl/getcurdt.p
          (output v-curr-sv-date
          ) .
      end.
      if v-curr-sv-date <> ?
      then do:
        run gbl/d-inpday.w
          (input ?
          ,input "Выбор даты"
          ,input p-description
          ,input ""
          ,input-output v-curr-sv-date
          ,output v-ok
          ).
        if v-ok = true
        then do:
          assign
            p-date-handle :screen-value = string(v-curr-sv-date) .
          .
        end.
      end.
    end.
  end.
end procedure.
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable v-read-only     AS LOGICAL   NO-UNDO INIT False .
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
  LABEL "&Отмена"
  SIZE 10 BY 1
  BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
  LABEL "&Ввод "
  SIZE 10 BY 1
  BGCOLOR 8 .
DEFINE VARIABLE FILL-IN-Character   AS CHARACTER FORMAT "X(256)":U
  VIEW-AS FILL-IN
  SIZE 88 BY 1.04
  BGCOLOR 15 NO-UNDO.
DEFINE VARIABLE FILL-IN-Character-2 AS CHARACTER FORMAT "X(256)":U
  VIEW-AS FILL-IN
  SIZE 88 BY 1
  BGCOLOR 15 NO-UNDO.
DEFINE VARIABLE FILL-IN-Text-1      AS CHARACTER FORMAT "X(256)":U
  VIEW-AS TEXT
  SIZE 41.25 BY .58
  FONT 4 NO-UNDO.
DEFINE VARIABLE FILL-IN-Text-2      AS CHARACTER FORMAT "X(256)":U
  VIEW-AS TEXT
  SIZE 41.25 BY .58
  FONT 4 NO-UNDO.
DEFINE VARIABLE FILL-IN-Text-3      AS CHARACTER FORMAT "X(256)":U
  VIEW-AS TEXT
  SIZE 41.25 BY .58
  FONT 4 NO-UNDO.
DEFINE FRAME Dialog-Frame
  FILL-IN-Character AT ROW 2.96 COL 2 NO-LABEL
  FILL-IN-Character-2 AT ROW 5 COL 2 NO-LABEL WIDGET-ID 2
  Btn_OK AT ROW 7 COL 2.5
  Btn_Cancel AT ROW 7 COL 12.5
  FILL-IN-Text-1 AT ROW 1.13 COL 2.5 NO-LABEL
  FILL-IN-Text-2 AT ROW 2.04 COL 2.5 NO-LABEL
  FILL-IN-Text-3 AT ROW 4.21 COL 2.5 NO-LABEL WIDGET-ID 4
  SPACE(50.12) SKIP(3.58)
  WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
  SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
  TITLE "Атрибуты инвентаризации"
  CANCEL-BUTTON Btn_Cancel.
ASSIGN
  FRAME Dialog-Frame:SCROLLABLE = FALSE
  FRAME Dialog-Frame:HIDDEN     = TRUE.
ASSIGN
  FILL-IN-Text-1:HIDDEN IN FRAME Dialog-Frame = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
  DO:
    APPLY "END-ERROR":U TO SELF.
  END.
ON choose OF Btn_OK IN FRAME Dialog-Frame
  DO:
    if not pTech then
    do:
      if (FiLL-IN-Character = "" and FiLL-IN-Character-2 <> "") or
      (FILL-IN-Character-2 = "" and FiLL-IN-Character <> "") then
      do:
        message "Не все поля заполнены."
          view-as alert-box.
        return no-apply .
      end.
    end.
      pValue = FILL-IN-Character .
      pSecondValue = FILL-IN-Character-2 .
  END.
ON RETURN OF FILL-IN-Character IN FRAME Dialog-Frame
  DO:
    assign
      FILL-IN-Character .
    APPLY "value-changed":U TO FILL-IN-Character-2.
  END.
ON RETURN OF FILL-IN-Character-2 IN FRAME Dialog-Frame
  DO:
    assign
      FILL-IN-Character-2 .
    APPLY "CHOOSE":U TO Btn_OK.
  END.
ON value-changed OF FILL-IN-Character IN FRAME Dialog-Frame
  DO:
    assign
      FILL-IN-Character .
  END.
ON value-changed OF FILL-IN-Character-2 IN FRAME Dialog-Frame
  DO:
    assign
      FILL-IN-Character-2 .
  END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
  THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable ind      AS INTEGER   NO-UNDO.
define variable sElement AS CHARACTER NO-UNDO.
define variable sValue   AS CHARACTER NO-UNDO.
DO ind = 1 TO NUM-ENTRIES(pParameters, '\'):
  sElement = ENTRY(ind, pParameters, '\').
  IF NUM-ENTRIES(sElement, '=') = 2
    THEN
  DO:
    sValue   = ENTRY(2, sElement, '=').
    CASE ENTRY(1, sElement, '='):
      WHEN 'text1'         THEN
        do:
          assign
            FILL-IN-Text-2 = str-decode(sValue, "").
        end.
      WHEN 'text2'         THEN
        do:
          assign
            FILL-IN-Text-3 = str-decode(sValue, "").
        end.
      WHEN 'readonly'      THEN
        do:
          assign
            v-read-only = lookup(sValue, 'yes,true':U) > 0 .
        end.
    END CASE.
  END.
END.
assign
  FILL-IN-Character   = pValue
  FILL-IN-Character-2 = pSecondValue
  .
define variable hFrameHandle AS WIDGET-HANDLE NO-UNDO.
hFrameHandle = FRAME Dialog-Frame:HANDLE.
define variable hText AS WIDGET-HANDLE NO-UNDO.
DO WITH FRAME Dialog-Frame
  :
  IF FILL-IN-Text-1 <> ''
    THEN
  DO:
    DISPLAY FILL-IN-Text-1.
  END.
  IF FILL-IN-Text-2 <> ''
    THEN
  DO:
    DISPLAY FILL-IN-Text-2.
  END.
END.
define variable sText1Label AS CHARACTER NO-UNDO.
define variable sTypeOk     as logical   no-undo .
assign
  sTypeOk = false
  .
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  run setup-cancel-button .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY FILL-IN-Character FILL-IN-Character-2 FILL-IN-Text-2 FILL-IN-Text-3
    WITH FRAME Dialog-Frame.
  ENABLE FILL-IN-Character FILL-IN-Character-2 Btn_OK Btn_Cancel
    WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE setup-cancel-button :
  do with frame Dialog-Frame
    :
    if v-read-only
      then
    do:
      assign
        Btn_OK :LABEL = "&Выход"
        .
    end.
    if v-read-only = false
      then
    do:
      assign
        Btn_Cancel :visible   = true
        Btn_Cancel :sensitive = true
        .
    end.
    else
    do:
      assign
        Btn_Cancel :sensitive = false
        Btn_Cancel :visible   = false
        .
    end.
    FILL-IN-Character :SENSITIVE    = True AND NOT v-read-only .
    FILL-IN-Character-2 :SENSITIVE    = True AND NOT v-read-only .
  end.
END PROCEDURE.
