define input        parameter h-callback    as handle    no-undo .
DEFINE INPUT        PARAMETER pParameters  AS CHARACTER NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER pValue       AS logical   NO-UNDO.
define output       parameter p-ok         as logical   no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
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
define variable sFormat          AS CHARACTER     NO-UNDO .
define variable sBoxProg         AS CHARACTER     NO-UNDO .
define variable lBlank           AS LOGICAL       NO-UNDO .
define variable v-password       as logical   no-undo .
define variable hFillIn          AS WIDGET-HANDLE NO-UNDO .
define variable sFillIn_Row      AS CHARACTER     NO-UNDO INIT ? .
define variable sFillIn_Col      AS CHARACTER     NO-UNDO INIT ? .
define variable sFillIn_Width    AS CHARACTER     NO-UNDO INIT ? .
define variable sFillIn_Height   AS CHARACTER     NO-UNDO INIT ? .
define variable sEditor_MaxChars AS CHARACTER     NO-UNDO INIT ? .
define variable sCreate_Text1    AS CHARACTER     NO-UNDO INIT ? .
define variable v-read-only      AS LOGICAL       NO-UNDO INIT False .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn-Choose
     LABEL "V"
     SIZE 2.5 BY 1.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE FILL-IN-Text-1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 41.3 BY .57
     FONT 4 NO-UNDO.
DEFINE VARIABLE FILL-IN-Text-2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 41.3 BY .57
     FONT 4 NO-UNDO.
DEFINE VARIABLE TOGGLE-1 AS LOGICAL INITIAL no
     LABEL ""
     VIEW-AS TOGGLE-BOX
     SIZE 4.6 BY .97 NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 43
     Btn-Choose AT ROW 2.97 COL 43.5
     TOGGLE-1 AT ROW 4.57 COL 40.9
     FILL-IN-Text-1 AT ROW 2.13 COL 2.5 NO-LABEL
     FILL-IN-Text-2 AT ROW 3 COL 2.5 NO-LABEL
     SPACE(2.57) SKIP(2.50)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ввод логического значения"
         CANCEL-BUTTON Btn_Cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       Btn-Choose:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       FILL-IN-Text-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       FILL-IN-Text-2:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       TOGGLE-1:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
  IF NOT v-read-only
  THEN DO:
    ASSIGN
    TOGGLE-1
    .
    if  h-callback <> ?
    and valid-handle(h-callback)
    then do:
      if h-callback :get-signature("cb-d-logical-validate") <> ""
      then do:
        define variable v-ok as logical no-undo .
        define variable v-message as character no-undo .
        run cb-d-logical-validate in h-callback
          (input  toggle-1
          ,output v-ok
          ,output v-message
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процедуры проверки допустимости logical" skip
            "Вызывающая программа" h-callback :file-name skip
            "Внутренняя процедура" "cb-d-logical-validate" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          return no-apply .
        end.
        if v-ok <> true
        then do:
          message
            v-message
            view-as alert-box information .
          return no-apply .
        end.
      end.
      else do:
        message
          vss-workfile vss-revision vss-description skip
          "Программе был передан указатель на процедуру для проверки logical" skip
          "В вызывающей программе отсутствует внутренняя процедура" "cb-d-logical-validate" skip
          "Вызывающая программа" h-callback :file-name skip
          view-as alert-box error .
        return no-apply .
      end.
    end.
    assign
    pvalue = toggle-1.
  END.
  ASSIGN
  p-ok = True
  .
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF Btn-Choose IN FRAME Dialog-Frame
DO:
  define variable var_id   as char no-undo.
  define variable var_name as char no-undo.
if session :set-wait-state( "compiler" ) then.
  do with frame Dialog-Frame
  :
    assign
      var_id = hfillin :screen-value
    .
    run value(sboxprog) (input-output var_id, input-output var_name).
    if var_id <> hfillin :screen-value
    then do:
      assign
        hfillin :screen-value = var_id
      .
    end.
  end.
if session :set-wait-state( "" ) then.
END.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable ind AS INTEGER NO-UNDO.
define variable sElement AS CHARACTER NO-UNDO.
define variable sValue AS CHARACTER NO-UNDO.
DO ind = 1 TO NUM-ENTRIES(pParameters, '\'):
  sElement = ENTRY(ind, pParameters, '\').
  IF NUM-ENTRIES(sElement, '=') = 2
  THEN DO:
    sValue   = ENTRY(2, sElement, '=').
    CASE ENTRY(1, sElement, '='):
      WHEN 'text1'         THEN do: assign FILL-IN-Text-1   = str-decode(sValue, "").             end.
      WHEN 'text2'         THEN do: assign FILL-IN-Text-2   = str-decode(sValue, "").             end.
      WHEN 'format'        THEN do: assign sFormat          = sValue.                             end.
      WHEN 'blank'         THEN do: assign lBlank           = lookup(sValue, 'true,yes':U) > 0.   end.
      WHEN 'password'      THEN do: assign v-password       = lookup(sValue, 'true,yes':U) > 0.   end.
      WHEN 'title'         THEN do: assign FRAME Dialog-Frame:TITLE = sValue.                    end.
      WHEN 'boxprog'       THEN do: assign sBoxProg         = sValue.                             end.
      WHEN 'FillIn_Row'    THEN do: assign sFillIn_Row      = sValue.                             end.
      WHEN 'FillIn_Col'    THEN do: assign sFillIn_Col      = sValue.                             end.
      WHEN 'FillIn_Height' THEN do: assign sFillIn_Height   = sValue.                             end.
      WHEN 'FillIn_Width'  THEN do: assign sFillIn_Width    = sValue.                             end.
      WHEN 'max-chars'     THEN do: assign sEditor_MaxChars = sValue.                             end.
      WHEN 'Create_Text1'  THEN do: assign sCreate_Text1    = sValue.                             end.
      WHEN 'readonly'      THEN do: assign v-read-only      = lookup(sValue, 'yes,true':U) > 0 .  end.
    END CASE.
  END.
END.
define variable hFrameHandle AS WIDGET-HANDLE NO-UNDO.
hFrameHandle = FRAME Dialog-Frame:HANDLE.
define variable hText AS WIDGET-HANDLE NO-UNDO.
DO WITH FRAME Dialog-Frame
:
  IF FILL-IN-Text-1 <> ''
  THEN DO:
    DISPLAY FILL-IN-Text-1.
  END.
  IF FILL-IN-Text-2 <> ''
  THEN DO:
    DISPLAY FILL-IN-Text-2.
  END.
END.
define variable sText1Label AS CHARACTER NO-UNDO.
IF sCreate_Text1 <> ?
AND NUM-ENTRIES(sCreate_Text1, ';') = 3
THEN DO:
  sText1Label = ENTRY(3, sCreate_Text1, ';').
  CREATE TEXT hText
  ASSIGN
    ROW          = INTEGER(ENTRY(1, sCreate_Text1, ';'))
    COLUMN       = INTEGER(ENTRY(2, sCreate_Text1, ';'))
    FORMAT       = 'X(' + STRING(LENGTH(sText1Label)) + ')'
    SCREEN-VALUE = sText1Label
    FRAME        = hFrameHandle
    SENSITIVE    = FALSE
    VISIBLE      = TRUE
  .
END.
IF num-entries(sFormat, chr(47)) <> 2
then DO:
  if Sformat <> '':u then do:
    MESSAGE
      vss-workfile vss-revision vss-description skip
      'Указан неправильный формат данный' SKIP
      'sFormat' sFormat 'для логического типа данных' SKIP
      'Формат данных принимается за yes/no' SKIP
      'Позвоните разработчикам системы' skip
      VIEW-AS ALERT-BOX WARNING.
  end.
  assign
    sFormat = 'yes/no'
  .
END.
RUN setup-toggle.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  run setup-box-button .
  run setup-cancel-button .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE Btn_OK Btn_Cancel b-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE setup-box-button :
  DO WITH FRAME Dialog-Frame
  :
    IF sBoxProg <> ''
    THEN DO:
      ASSIGN
        Btn-Choose:VISIBLE      = True AND NOT v-read-only
        Btn-Choose:SENSITIVE    = True AND NOT v-read-only
      .
    END.
    if v-read-only
    then do:
      assign
        Btn_OK :LABEL = "&Выход"
      .
    end.
  END.
END PROCEDURE.
PROCEDURE setup-cancel-button :
  do with frame Dialog-Frame
  :
    if v-read-only = false
    then do:
      assign
        Btn_Cancel :visible   = true
        Btn_Cancel :sensitive = true
      .
    end.
    else do:
      assign
        Btn_Cancel :sensitive = false
        Btn_Cancel :visible   = false
      .
    end.
  end.
END PROCEDURE.
PROCEDURE setup-toggle :
  do with frame Dialog-Frame
  :
  ASSIGN
    TOGGLE-1:VISIBLE      = True
    TOGGLE-1:SENSITIVE    = True AND NOT v-read-only
    TOGGLE-1:ROW          = 3
    TOGGLE-1:COL          = 2
    hFillIn = TOGGLE-1:HANDLE
  .
  IF FILL-IN-Text-2 = ''
  AND sFillIn_Row = ?
  THEN DO:
    sFillIn_Row = '2'.
    IF FILL-IN-Text-1 = ''
    THEN DO:
      sFillIn_Row = '1.1'.
    END.
  END.
  IF CAN-SET(hFillIn, 'SCREEN-VALUE')
  THEN DO:
      ASSIGN
        hfillin:screen-value = string(pValue, "yes/no")
      .
  END.
  IF sFillIn_Height = ? THEN
    sFillIn_Height = '10'.
  IF sFillIn_Width = ? THEN
    sFillIn_Width = '50'.
  TOGGLE-1:format = sFormat.
 end.
END PROCEDURE.
