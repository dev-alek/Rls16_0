define shared temp-table tt-dens-temp no-undo
  field ii as integer
  field key_ as character
  field density as decimal format "9.9999999999"
  field temperature as decimal format "->>>9.<<"
  index pi
    as primary unique
    ii
.
define input parameter parparentproc as handle no-undo .
define input parameter p-sr-izm-type as integer no-undo .
define input parameter p-place-type as integer no-undo .
define input parameter p-diameter   as decimal no-undo .
define input parameter p-fuel-level as decimal no-undo .
define input-output parameter p-mi-tmp-dnst as integer no-undo .
define output parameter p-avg-density as decimal no-undo .
define output parameter p-avg-temperature as decimal no-undo .
define output parameter p-ok as logical no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
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
define buffer tmp-dnst_sr-izmerenia for sr-izmerenia .
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-ok AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-mi-tmp-dnst
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     label ""
     tooltip ""
     SIZE 3 BY .87.
DEFINE VARIABLE v-mi-tmp-dnst AS integer FORMAT ">>>>>9":U
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE v-mi-tmp-dnst-name AS character FORMAT "X(10)":U
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
define button b-fill-empty
    label "Заполнить пустые"
    size 18 by 1 .
define query br-dens-temp for tt-dens-temp .
define browse br-dens-temp query br-dens-temp exclusive-lock
  display
    tt-dens-temp.key_        label "Уровень " format "X(8)"
    tt-dens-temp.density     label "Значение,г/см3" format "9.9999"
    tt-dens-temp.temperature label "t измер. р,°C" format "->>9.9"
  enable
    tt-dens-temp.density
    tt-dens-temp.temperature
  with size 41 by 10 separators
.
DEFINE FRAME Dialog-Frame
     b-ok AT ROW 1.24 COL 2
     b-cancel AT ROW 1.24 COL 17
     "СИ температуры изм. плотности:" view-as text at row 2.4 col 2
     v-mi-tmp-dnst at row 3.45 col 2 no-label
     v-mi-tmp-dnst-name at row 3.45 col 2 no-label
     b-mi-tmp-dnst at row 3.5 col 14
     br-dens-temp at row 4.5 col 1
     b-fill-empty at row 15 col 2
     SPACE(1) SKIP(1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Таблица измерений плотности"
         DEFAULT-BUTTON b-ok CANCEL-BUTTON b-cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
on choose of b-ok in frame Dialog-Frame
do :
  define buffer buf1_tt-dens-temp for tt-dens-temp .
  define buffer buf2_tt-dens-temp for tt-dens-temp .
  define buffer buf3_tt-dens-temp for tt-dens-temp .
  for first tt-dens-temp no-lock where tt-dens-temp.density = 0
                                    or tt-dens-temp.density = ?
                                    or tt-dens-temp.temperature = ?
                                    :
    message "Необходимо заполнить значения на всех уровнях!" view-as alert-box .
    return no-apply .
  end .
  case p-sr-izm-type :
    when 1
    then do :
      case p-place-type :
        when 1
        then do :
          find first buf1_tt-dens-temp where buf1_tt-dens-temp.ii = 1 .
          find first buf2_tt-dens-temp where buf2_tt-dens-temp.ii = 2 no-error .
          find first buf3_tt-dens-temp where buf3_tt-dens-temp.ii = 3 no-error .
          p-avg-density = buf1_tt-dens-temp.density .
          p-avg-temperature = buf1_tt-dens-temp.temperature .
          if available buf2_tt-dens-temp
          and not available buf3_tt-dens-temp
          then do :
            p-avg-density = (buf1_tt-dens-temp.density + buf2_tt-dens-temp.density) / 2 .
            p-avg-temperature = (buf1_tt-dens-temp.temperature + buf2_tt-dens-temp.temperature) / 2 .
          end .
          if available buf2_tt-dens-temp
          and available buf3_tt-dens-temp
          then do :
            p-avg-density = (buf1_tt-dens-temp.density + (3 * buf2_tt-dens-temp.density) + buf3_tt-dens-temp.density) / 5 .
            p-avg-temperature = (buf1_tt-dens-temp.temperature + (3 * buf2_tt-dens-temp.temperature) + buf3_tt-dens-temp.temperature) / 5 .
          end .
        end .
        when 2
        then do :
          find first buf1_tt-dens-temp where buf1_tt-dens-temp.ii = 1 .
          find first buf2_tt-dens-temp where buf2_tt-dens-temp.ii = 2 no-error .
          find first buf3_tt-dens-temp where buf3_tt-dens-temp.ii = 3 no-error .
          p-avg-density = buf1_tt-dens-temp.density .
          p-avg-temperature = buf1_tt-dens-temp.temperature .
          if available buf2_tt-dens-temp
          and not available buf3_tt-dens-temp
          then do :
            p-avg-density = (buf1_tt-dens-temp.density + (3 * buf2_tt-dens-temp.density)) / 4 .
            p-avg-temperature = (buf1_tt-dens-temp.temperature + (3 * buf2_tt-dens-temp.temperature)) / 4 .
          end .
          if available buf2_tt-dens-temp
          and available buf3_tt-dens-temp
          then do :
            p-avg-density = (buf1_tt-dens-temp.density + (6 * buf2_tt-dens-temp.density) + buf3_tt-dens-temp.density) / 8 .
            p-avg-temperature = (buf1_tt-dens-temp.temperature + (6 * buf2_tt-dens-temp.temperature) + buf3_tt-dens-temp.temperature) / 8 .
          end .
        end .
      end case .
    end .
  end case .
  p-mi-tmp-dnst = v-mi-tmp-dnst .
  p-ok = true .
end .
on return of tt-dens-temp.density in browse br-dens-temp
do :
  apply "leave" to self .
end .
on leave of tt-dens-temp.density in browse br-dens-temp
do :
  define variable is-empty as logical no-undo .
  define buffer buf_tt-dens-temp for tt-dens-temp .
  if decimal(tt-dens-temp.density:screen-value in browse br-dens-temp) >= 1
  then do :
    message "Неверное значение плотности!" view-as alert-box .
    return no-apply .
  end .
  assign tt-dens-temp.density = decimal(tt-dens-temp.density:screen-value in browse br-dens-temp) .
end .
on return of tt-dens-temp.temperature in browse br-dens-temp
do :
  apply "leave" to self .
end .
on leave of tt-dens-temp.temperature in browse br-dens-temp
do :
  define variable is-empty as logical no-undo .
  define buffer buf_tt-dens-temp for tt-dens-temp .
  assign tt-dens-temp.temperature = decimal(tt-dens-temp.temperature:screen-value in browse br-dens-temp) .
end .
on choose of b-fill-empty in frame Dialog-Frame
do :
  define buffer buf_tt-dens-temp for tt-dens-temp .
  if available tt-dens-temp
  and (tt-dens-temp.density > 0 or tt-dens-temp.temperature <> ?)
  then do :
    for each buf_tt-dens-temp :
      if (buf_tt-dens-temp.density = ?
      or buf_tt-dens-temp.density = 0)
      and tt-dens-temp.density > 0
      then do :
        buf_tt-dens-temp.density = tt-dens-temp.density .
      end .
      if buf_tt-dens-temp.temperature = ?
      and tt-dens-temp.temperature <> ?
      then do :
        buf_tt-dens-temp.temperature = tt-dens-temp.temperature .
      end .
    end .
    br-dens-temp:refresh() in frame Dialog-Frame .
  end .
end .
on entry of tt-dens-temp.temperature IN browse br-dens-temp
DO:
  define variable vlog as logical no-undo .
  if v-mi-tmp-dnst = 0
  or v-mi-tmp-dnst = ?
  then do :
    message "Для заполнения температуры измерения плотности необходимо выбрать соответствующее СИ. Выполнить выбор сейчас?"
    view-as alert-box question buttons yes-no update vlog .
    if vlog
    then do :
      apply "choose" to b-mi-tmp-dnst in FRAME Dialog-Frame .
      if v-mi-tmp-dnst = 0
      or v-mi-tmp-dnst = ?
      then do :
        return no-apply .
      end .
    end .
    else do :
      apply "entry" to tt-dens-temp.density IN browse br-dens-temp.
      return no-apply .
    end .
  end .
end .
ON CHOOSE OF b-mi-tmp-dnst IN FRAME Dialog-Frame
DO:
  define variable v-node-code as integer no-undo.
  define variable v-sr-type-id as character no-undo.
  v-node-code = 0 .
  run ref/sr-izm.w (input parparentproc ,
                    input "b-sel"       ,
                    input 'ПРОСМОТР':U     ,
                    input "1"           ,
                    input "tmp"         ,
                    input-output v-node-code,
                    output v-sr-type-id) no-error.
  if v-node-code <> 0 and v-node-code <> ? then do :
    v-mi-tmp-dnst = v-node-code.
    v-mi-tmp-dnst:screen-value = string(v-node-code).
    find first tmp-dnst_sr-izmerenia no-lock where tmp-dnst_sr-izmerenia.node-code = v-mi-tmp-dnst .
    apply "leave" to v-mi-tmp-dnst in frame Dialog-Frame .
  end.
  else do :
    apply "entry" to tt-dens-temp.density IN browse br-dens-temp.
  end .
END.
on entry of v-mi-tmp-dnst-name IN FRAME Dialog-Frame
do:
  apply "entry" to v-mi-tmp-dnst in frame Dialog-Frame.
end .
on entry of v-mi-tmp-dnst IN FRAME Dialog-Frame
do:
  hide v-mi-tmp-dnst-name in frame Dialog-Frame.
end .
on return of v-mi-tmp-dnst IN FRAME Dialog-Frame
do:
  apply "leave" to v-mi-tmp-dnst IN FRAME Dialog-Frame .
end .
on del of v-mi-tmp-dnst in frame Dialog-Frame
do :
  v-mi-tmp-dnst = ? .
  v-mi-tmp-dnst:screen-value = "?" .
end .
on leave of v-mi-tmp-dnst IN FRAME Dialog-Frame
do:
  define variable vlog as logical no-undo .
  define variable v-old-val as character no-undo .
  v-old-val = string(v-mi-tmp-dnst) .
  find first tmp-dnst_sr-izmerenia no-lock where tmp-dnst_sr-izmerenia.node-code = integer(v-mi-tmp-dnst:screen-value) no-error .
  if not available tmp-dnst_sr-izmerenia
  then do :
    if v-mi-tmp-dnst:screen-value <> "?"
    and v-mi-tmp-dnst:screen-value <> "0"
    then do :
      message ("Не найдено средтсво измерения с кодом " + v-mi-tmp-dnst:screen-value) view-as alert-box .
      v-mi-tmp-dnst:screen-value = v-old-val .
    end .
    return .
  end .
  else do :
    if tmp-dnst_sr-izmerenia.sr-type-izm = 2
    then do :
      message "Средство измерения является Измерительной Системой!" view-as alert-box .
      v-mi-tmp-dnst:screen-value = v-old-val .
      return .
    end .
    if tmp-dnst_sr-izmerenia.sr-type-izm = 0
    then do :
      message "Средство измерения является Автоматизированным!" view-as alert-box .
      v-mi-tmp-dnst:screen-value = v-old-val .
      return .
    end .
    if not tmp-dnst_sr-izmerenia.sr-temperature
    then do :
      message "Средство измерения НЕ измеряет температуру!" view-as alert-box .
      v-mi-tmp-dnst:screen-value = v-old-val .
      return .
    end .
  end .
  v-mi-tmp-dnst-name = tmp-dnst_sr-izmerenia.sr-model .
  display v-mi-tmp-dnst-name with frame Dialog-Frame.
  enable v-mi-tmp-dnst-name with frame Dialog-Frame.
  assign v-mi-tmp-dnst .
end .
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  p-ok = false .
  run fill-tt .
  for first sr-izmerenia no-lock where sr-izmerenia.node-code = p-mi-tmp-dnst :
    assign
      v-mi-tmp-dnst = sr-izmerenia.node-code
      v-mi-tmp-dnst-name = sr-izmerenia.sr-model
    .
    display v-mi-tmp-dnst-name with frame Dialog-Frame.
    enable v-mi-tmp-dnst-name with frame Dialog-Frame.
  end .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
procedure fill-tt :
  define variable ii as integer no-undo .
  case p-sr-izm-type :
    when 1
    then do :
      case p-place-type :
        when 1
        then do :
          find first tt-dens-temp where tt-dens-temp.key_ begins "P1" no-error .
          if available tt-dens-temp
          then do :
            empty temp-table tt-dens-temp .
          end .
          find first tt-dens-temp no-error .
          if not available tt-dens-temp
          then do :
            create tt-dens-temp .
            assign
              tt-dens-temp.ii = 1
              tt-dens-temp.key_ = "Pн"
              tt-dens-temp.temperature = ?
            .
            if p-fuel-level > 1000
            then do :
              create tt-dens-temp .
              assign
                tt-dens-temp.ii = 2
                tt-dens-temp.key_ = "Pв"
                tt-dens-temp.temperature = ?
              .
            end .
            if p-fuel-level > 2000
            then do :
              tt-dens-temp.key_ = "Pср" .
              create tt-dens-temp .
              assign
                tt-dens-temp.ii = 3
                tt-dens-temp.key_ = "Pв"
                tt-dens-temp.temperature = ?
              .
            end .
          end .
        end .
        when 2
        then do :
          find first tt-dens-temp where tt-dens-temp.key_ begins "P1" no-error .
          if available tt-dens-temp
          then do :
            empty temp-table tt-dens-temp .
          end .
          find first tt-dens-temp no-error .
          if not available tt-dens-temp
          then do :
            create tt-dens-temp .
            assign
              tt-dens-temp.ii = 1
              tt-dens-temp.key_ = "Pн"
              tt-dens-temp.temperature = ?
            .
            if (p-diameter >= 2500 and p-fuel-level >= (p-diameter / 2))
            or (p-diameter < 2500 and p-fuel-level >= 500)
            or (p-fuel-level >= 500 and p-fuel-level <= (p-diameter / 2))
            then do :
              create tt-dens-temp .
              assign
                tt-dens-temp.ii = 2
                tt-dens-temp.key_ = "Pср"
                tt-dens-temp.temperature = ?
              .
            end .
            if (p-diameter >= 2500 and p-fuel-level >= (p-diameter / 2))
            then do :
              create tt-dens-temp .
              assign
                tt-dens-temp.ii = 3
                tt-dens-temp.key_ = "Pв"
                tt-dens-temp.temperature = ?
              .
            end .
          end .
        end .
      end case .
    end .
  end case .
end procedure .
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  ENABLE b-ok b-cancel br-dens-temp b-fill-empty b-mi-tmp-dnst v-mi-tmp-dnst v-mi-tmp-dnst-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  open query br-dens-temp for each tt-dens-temp .
END PROCEDURE.
