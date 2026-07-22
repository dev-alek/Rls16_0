define shared temp-table tt-temps-tab no-undo
  field ii as integer
  field key_ as character
  field temperature as decimal format "->>>9.<<"
  index pi
    as primary unique
    ii
.
define input parameter p-sr-izm-type as integer no-undo .
define input parameter p-place-type as integer no-undo .
define input parameter p-diameter   as decimal no-undo .
define input parameter p-fuel-level as decimal no-undo .
define input-output parameter p-calc-type as integer no-undo .
define output parameter p-avg-temperature as decimal no-undo .
define output parameter p-ok as logical no-undo .
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
define variable v-num-izm     as integer no-undo .
define variable v-temps-sum   as decimal no-undo .
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-ok AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
define variable v-calc-type-label as character init "Способ расчета средней Т:" format "X(30)"
  view-as text
  size 25 by 1 no-undo .
DEFINE VARIABLE cb-calc-type AS integer init 1
     LABEL ""
     VIEW-AS COMBO-BOX INNER-LINES 3
     LIST-ITEM-PAIRS "Расчет",1,
                     "Ввод среднего значения",2,
                     "Расчет по алгоритму СИ",3
     DROP-DOWN-LIST
     SIZE 27 BY 1 NO-UNDO.
define variable v-calc-num-izm as integer
  label "Число точечных проб"
  view-as fill-in
  size 7 by 1 no-undo .
define button b-fill-empty
    label "Заполнить пустые"
    size 18 by 1 .
define query br-temp for tt-temps-tab .
define browse br-temp query br-temp exclusive-lock
  display
    tt-temps-tab.key_         label "Уровень " format "X(8)"
    tt-temps-tab.temperature  label "Значение,°C" format "->>9.9"
  enable
    tt-temps-tab.temperature
  with size 30 by 10 separators
.
DEFINE FRAME Dialog-Frame
     b-ok AT ROW 1.1 COL 2
     b-cancel AT ROW 1.1 COL 17
     v-calc-type-label at row 2.2 col 2 no-label
     cb-calc-type at row 3.2 col 2 no-label
     v-calc-num-izm at row 4.2 col 2
     br-temp at row 5.5 col 1
     b-fill-empty at row 16 col 2
     SPACE(1) SKIP(1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Таблица измерений температуры"
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
  define buffer buf_tt-temps for tt-temps-tab .
  define buffer buf1_tt-temps for tt-temps-tab .
  define buffer buf2_tt-temps for tt-temps-tab .
  define buffer buf3_tt-temps for tt-temps-tab .
  for first tt-temps-tab no-lock where tt-temps-tab.temperature = ? :
    message "Необходимо заполнить значения на всех уровнях!" view-as alert-box .
    return no-apply .
  end .
  case p-place-type :
    when 1
    then do :
      case p-sr-izm-type :
        when 0
        then do :
          v-temps-sum = 0 .
          for each buf_tt-temps :
            v-temps-sum = v-temps-sum + buf_tt-temps.temperature .
          end .
          if cb-calc-type = 3
          then do :
            p-avg-temperature = v-temps-sum / v-calc-num-izm .
          end .
          else do :
            p-avg-temperature = v-temps-sum / v-num-izm .
          end .
        end .
        when 1
        then do :
          find first buf1_tt-temps where buf1_tt-temps.ii = 1 .
          find first buf2_tt-temps where buf2_tt-temps.ii = 2 no-error .
          find first buf3_tt-temps where buf3_tt-temps.ii = 3 no-error .
          p-avg-temperature = buf1_tt-temps.temperature .
          if available buf2_tt-temps
          and not available buf3_tt-temps
          then
            p-avg-temperature = (buf1_tt-temps.temperature + buf2_tt-temps.temperature) / 2 .
          if available buf2_tt-temps
          and available buf3_tt-temps
          then
            p-avg-temperature = (buf1_tt-temps.temperature + (3 * buf2_tt-temps.temperature) + buf3_tt-temps.temperature) / 5 .
        end .
      end case .
    end .
    when 2
    then do :
      case p-sr-izm-type :
        when 0
        then do :
          v-temps-sum = 0 .
          for each buf_tt-temps :
            v-temps-sum = v-temps-sum + buf_tt-temps.temperature .
          end .
          p-avg-temperature = v-temps-sum / v-num-izm .
        end .
        when 1
        then do :
          find first buf1_tt-temps where buf1_tt-temps.ii = 1 .
          find first buf2_tt-temps where buf2_tt-temps.ii = 2 no-error .
          find first buf3_tt-temps where buf3_tt-temps.ii = 3 no-error .
          p-avg-temperature = buf1_tt-temps.temperature .
          if available buf2_tt-temps
          and not available buf3_tt-temps
          then
            p-avg-temperature = (buf1_tt-temps.temperature + (3 * buf2_tt-temps.temperature)) / 4 .
          if available buf2_tt-temps
          and available buf3_tt-temps
          then
            p-avg-temperature = (buf1_tt-temps.temperature + (6 * buf2_tt-temps.temperature) + buf3_tt-temps.temperature) / 8 .
        end .
      end case .
    end .
  end case .
  p-calc-type = cb-calc-type .
  p-ok = true .
end .
on value-changed of cb-calc-type in frame Dialog-Frame
do :
  assign cb-calc-type .
  empty temp-table tt-temps-tab .
  if cb-calc-type = 3
  then do :
    enable v-calc-num-izm with FRAME Dialog-Frame.
  end .
  else do :
    hide v-calc-num-izm in FRAME Dialog-Frame.
  end .
  run fill-tt .
  open query br-temp for each tt-temps-tab .
end .
on return of v-calc-num-izm in frame Dialog-Frame
do :
  apply "leave" to self .
end .
on leave of v-calc-num-izm in frame Dialog-Frame
do :
  if input frame Dialog-Frame v-calc-num-izm <> v-calc-num-izm
  then do :
    assign v-calc-num-izm .
    empty temp-table tt-temps-tab .
    run fill-tt .
    open query br-temp for each tt-temps-tab .
  end .
end .
on return of tt-temps-tab.temperature in browse br-temp
do :
  apply "leave" to self .
end .
on leave of tt-temps-tab.temperature in browse br-temp
do :
  define variable is-empty as logical no-undo .
  define buffer buf_tt-temps for tt-temps-tab .
  assign tt-temps-tab.temperature = decimal(tt-temps-tab.temperature:screen-value in browse br-temp) .
end .
on choose of b-fill-empty in frame Dialog-Frame
do :
  define buffer buf_tt-temps for tt-temps-tab .
  if available tt-temps-tab
  and tt-temps-tab.temperature <> ?
  then do :
    for each buf_tt-temps :
      if buf_tt-temps.temperature = ?
      then do :
        buf_tt-temps.temperature = tt-temps-tab.temperature .
      end .
    end .
    br-temp:refresh() in frame Dialog-Frame .
  end .
end .
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define variable jj as integer no-undo .
  p-ok = false .
  cb-calc-type = p-calc-type .
  if cb-calc-type = 3
  and p-place-type = 1
  then do :
    jj = 0 .
    for each tt-temps-tab :
      jj = jj + 1 .
    end .
    v-calc-num-izm = jj .
  end .
  run fill-tt .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
procedure fill-tt :
  define variable ii as integer no-undo .
  case p-place-type :
    when 1
    then do :
      case p-sr-izm-type :
        when 0
        then do :
          find first tt-temps-tab where tt-temps-tab.key_ = "tн" no-error .
          if available tt-temps-tab
          then do :
            empty temp-table tt-temps-tab .
          end .
          if cb-calc-type = 1
          then do :
            if p-fuel-level > 5000
            then do :
              v-num-izm = integer(truncate((p-fuel-level / 1000), 0)) .
            end .
            else do :
              v-num-izm = integer(truncate((p-fuel-level / 500), 0)) .
            end .
            if v-num-izm = 0 then v-num-izm = 1 .
            find first tt-temps-tab no-error .
            if not available tt-temps-tab
            then do ii = 1 to v-num-izm :
              create tt-temps-tab .
              assign
                tt-temps-tab.ii = ii
                tt-temps-tab.key_ = "t" + string(ii)
                tt-temps-tab.temperature = ?
              .
            end .
          end .
          if cb-calc-type = 2
          then do :
            v-num-izm = 1 .
            find first tt-temps-tab no-error .
            if not available tt-temps-tab
            then do :
              create tt-temps-tab .
              assign
                tt-temps-tab.ii = 1
                tt-temps-tab.key_ = "t1"
                tt-temps-tab.temperature = ?
              .
            end .
          end .
          if cb-calc-type = 3
          then do :
            find first tt-temps-tab no-error .
            if not available tt-temps-tab
            then do ii = 1 to v-calc-num-izm :
              create tt-temps-tab .
              assign
                tt-temps-tab.ii = ii
                tt-temps-tab.key_ = "t" + string(ii)
                tt-temps-tab.temperature = ?
              .
            end .
          end .
        end .
        when 1
        then do :
          find first tt-temps-tab where tt-temps-tab.key_ = "t1" no-error .
          if available tt-temps-tab
          then do :
            empty temp-table tt-temps-tab .
          end .
          find first tt-temps-tab no-error .
          if not available tt-temps-tab
          then do :
            create tt-temps-tab .
            assign
              tt-temps-tab.ii = 1
              tt-temps-tab.key_ = "tн"
              tt-temps-tab.temperature = ?
            .
            if p-fuel-level > 1000
            then do :
              create tt-temps-tab .
              assign
                tt-temps-tab.ii = 2
                tt-temps-tab.key_ = "tв"
                tt-temps-tab.temperature = ?
              .
            end .
            if p-fuel-level > 2000
            then do :
              tt-temps-tab.key_ = "tср" .
              create tt-temps-tab .
              assign
                tt-temps-tab.ii = 3
                tt-temps-tab.key_ = "tв"
                tt-temps-tab.temperature = ?
              .
            end .
          end .
        end .
      end case .
    end .
    when 2
    then do :
      case p-sr-izm-type :
        when 0
        then do :
          v-num-izm = integer(truncate((p-fuel-level / 500), 0)) .
          if v-num-izm = 0 then v-num-izm = 1 .
          find first tt-temps-tab where tt-temps-tab.key_ = "tн" no-error .
          if available tt-temps-tab
          then do :
            empty temp-table tt-temps-tab .
          end .
          find first tt-temps-tab no-error .
          if not available tt-temps-tab
          then do ii = 1 to v-num-izm :
            create tt-temps-tab .
            assign
              tt-temps-tab.ii = ii
              tt-temps-tab.key_ = "t" + string(ii)
              tt-temps-tab.temperature = ?
            .
          end .
        end .
        when 1
        then do :
          find first tt-temps-tab where tt-temps-tab.key_ = "t1" no-error .
          if available tt-temps-tab
          then do :
            empty temp-table tt-temps-tab .
          end .
          find first tt-temps-tab no-error .
          if not available tt-temps-tab
          then do :
            create tt-temps-tab .
            assign
              tt-temps-tab.ii = 1
              tt-temps-tab.key_ = "tн"
              tt-temps-tab.temperature = ?
            .
            if (p-diameter >= 2500 and p-fuel-level >= (p-diameter / 2))
            or (p-diameter < 2500 and p-fuel-level >= 500)
            or (p-fuel-level >= 500 and p-fuel-level <= (p-diameter / 2))
            then do :
              create tt-temps-tab .
              assign
                tt-temps-tab.ii = 2
                tt-temps-tab.key_ = "tср"
                tt-temps-tab.temperature = ?
              .
            end .
            if (p-diameter >= 2500 and p-fuel-level >= (p-diameter / 2))
            then do :
              create tt-temps-tab .
              assign
                tt-temps-tab.ii = 3
                tt-temps-tab.key_ = "tв"
                tt-temps-tab.temperature = ?
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
  ENABLE b-ok b-cancel br-temp b-fill-empty
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  if p-place-type = 1
  and p-sr-izm-type = 0
  then do :
    display v-calc-type-label cb-calc-type with FRAME Dialog-Frame.
    enable cb-calc-type with FRAME Dialog-Frame.
    if cb-calc-type = 3
    then do :
      display v-calc-num-izm with FRAME Dialog-Frame.
      enable v-calc-num-izm with FRAME Dialog-Frame.
    end .
    else do :
      hide v-calc-num-izm in FRAME Dialog-Frame.
    end .
  end .
  else do :
    br-temp:row = 2.4 .
    b-fill-empty:row = 12.9 .
    hide
      v-calc-type-label
      cb-calc-type
      v-calc-num-izm
    in FRAME Dialog-Frame.
  end .
  open query br-temp for each tt-temps-tab .
END PROCEDURE.
