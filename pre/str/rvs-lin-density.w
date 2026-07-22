define shared temp-table tt-dens no-undo
  field ii as integer
  field key_ as character
  field density as decimal format "9.9999999999"
  index pi
    as primary unique
    ii
.
define input parameter p-sr-izm-type as integer no-undo .
define input parameter p-place-type as integer no-undo .
define input parameter p-diameter   as decimal no-undo .
define input parameter p-fuel-level as decimal no-undo .
define input-output parameter p-calc-type as integer no-undo .
define output parameter p-avg-density as decimal no-undo .
define output parameter p-ok as logical no-undo .
define variable v-num-izm     as integer no-undo .
define variable v-dens-sum   as decimal no-undo .
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
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON b-ok AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
define variable v-calc-type-label as character init "Способ расчета средней p:" format "X(30)"
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
define query br-dens for tt-dens .
define browse br-dens query br-dens exclusive-lock
  display
    tt-dens.key_        label "Уровень " format "X(8)"
    tt-dens.density     label "Значение,г/см3" format "9.9999"
  enable
    tt-dens.density
  with size 30 by 10 separators
.
DEFINE FRAME Dialog-Frame
     b-ok AT ROW 1.1 COL 2
     b-cancel AT ROW 1.1 COL 17
     v-calc-type-label at row 2.2 col 2 no-label
     cb-calc-type at row 3.2 col 2 no-label
     v-calc-num-izm at row 4.2 col 2
     br-dens at row 5.5 col 1
     b-fill-empty at row 16 col 2
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
  define buffer buf_tt-dens for tt-dens .
  define buffer buf1_tt-dens for tt-dens .
  define buffer buf2_tt-dens for tt-dens .
  define buffer buf3_tt-dens for tt-dens .
  for first tt-dens no-lock where tt-dens.density = 0
                               or tt-dens.density = ?
                               :
    message "Необходимо заполнить значения на всех уровнях!" view-as alert-box .
    return no-apply .
  end .
  case p-place-type :
    when 1
    then do :
      case p-sr-izm-type :
        when 0
        then do :
          v-dens-sum = 0 .
          for each buf_tt-dens :
            v-dens-sum = v-dens-sum + buf_tt-dens.density .
          end .
          if cb-calc-type = 3
          then do :
            p-avg-density = v-dens-sum / v-calc-num-izm .
          end .
          else do :
            p-avg-density = v-dens-sum / v-num-izm .
          end .
        end .
        when 1
        then do :
          find first buf1_tt-dens where buf1_tt-dens.ii = 1 .
          find first buf2_tt-dens where buf2_tt-dens.ii = 2 no-error .
          find first buf3_tt-dens where buf3_tt-dens.ii = 3 no-error .
          p-avg-density = buf1_tt-dens.density .
          if available buf2_tt-dens
          and not available buf3_tt-dens
          then
            p-avg-density = (buf1_tt-dens.density + buf2_tt-dens.density) / 2 .
          if available buf2_tt-dens
          and available buf3_tt-dens
          then
            p-avg-density = (buf1_tt-dens.density + (3 * buf2_tt-dens.density) + buf3_tt-dens.density) / 5 .
        end .
      end case .
    end .
    when 2
    then do :
      case p-sr-izm-type :
        when 0
        then do :
          v-dens-sum = 0 .
          for each buf_tt-dens :
            v-dens-sum = v-dens-sum + buf_tt-dens.density .
          end .
          p-avg-density = v-dens-sum / v-num-izm .
        end .
        when 1
        then do :
          find first buf1_tt-dens where buf1_tt-dens.ii = 1 .
          find first buf2_tt-dens where buf2_tt-dens.ii = 2 no-error .
          find first buf3_tt-dens where buf3_tt-dens.ii = 3 no-error .
          p-avg-density = buf1_tt-dens.density .
          if available buf2_tt-dens
          and not available buf3_tt-dens
          then
            p-avg-density = (buf1_tt-dens.density + (3 * buf2_tt-dens.density)) / 4 .
          if available buf2_tt-dens
          and available buf3_tt-dens
          then
            p-avg-density = (buf1_tt-dens.density + (6 * buf2_tt-dens.density) + buf3_tt-dens.density) / 8 .
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
  empty temp-table tt-dens .
  if cb-calc-type = 3
  then do :
    enable v-calc-num-izm with FRAME Dialog-Frame.
  end .
  else do :
    hide v-calc-num-izm in FRAME Dialog-Frame.
  end .
  run fill-tt .
  open query br-dens for each tt-dens .
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
    empty temp-table tt-dens .
    run fill-tt .
    open query br-dens for each tt-dens .
  end .
end .
on return of tt-dens.density in browse br-dens
do :
  apply "leave" to self .
end .
on leave of tt-dens.density in browse br-dens
do :
  define variable is-empty as logical no-undo .
  define buffer buf_tt-dens for tt-dens .
  if decimal(tt-dens.density:screen-value in browse br-dens) >= 1
  then do :
    message "Неверное значение плотности!" view-as alert-box .
    return no-apply .
  end .
  assign tt-dens.density = decimal(tt-dens.density:screen-value in browse br-dens) .
end .
on choose of b-fill-empty in frame Dialog-Frame
do :
  define buffer buf_tt-dens for tt-dens .
  if available tt-dens
  and tt-dens.density > 0
  then do :
    for each buf_tt-dens :
      if buf_tt-dens.density = ?
      or buf_tt-dens.density = 0
      then do :
        buf_tt-dens.density = tt-dens.density .
      end .
    end .
    br-dens:refresh() in frame Dialog-Frame .
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
    for each tt-dens :
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
          find first tt-dens where tt-dens.key_ = "Pн" no-error .
          if available tt-dens
          then do :
            empty temp-table tt-dens .
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
            find first tt-dens no-error .
            if not available tt-dens
            then do ii = 1 to v-num-izm :
              create tt-dens .
              assign
                tt-dens.ii = ii
                tt-dens.key_ = "P" + string(ii) + (if ii = 1 then "(низ)" else "")
              .
            end .
          end .
          if cb-calc-type = 2
          then do :
            v-num-izm = 1 .
            find first tt-dens no-error .
            if not available tt-dens
            then do :
              create tt-dens .
              assign
                tt-dens.ii = 1
                tt-dens.key_ = "P1(низ)"
              .
            end .
          end .
          if cb-calc-type = 3
          then do :
            find first tt-dens no-error .
            if not available tt-dens
            then do ii = 1 to v-calc-num-izm :
              create tt-dens .
              assign
                tt-dens.ii = ii
                tt-dens.key_ = "P" + string(ii) + (if ii = 1 then "(низ)" else "")
              .
            end .
          end .
        end .
        when 1
        then do :
          find first tt-dens where tt-dens.key_ begins "P1" no-error .
          if available tt-dens
          then do :
            empty temp-table tt-dens .
          end .
          find first tt-dens no-error .
          if not available tt-dens
          then do :
            create tt-dens .
            assign
              tt-dens.ii = 1
              tt-dens.key_ = "Pн"
            .
            if p-fuel-level > 1000
            then do :
              create tt-dens .
              assign
                tt-dens.ii = 2
                tt-dens.key_ = "Pв"
              .
            end .
            if p-fuel-level > 2000
            then do :
              tt-dens.key_ = "Pср" .
              create tt-dens .
              assign
                tt-dens.ii = 3
                tt-dens.key_ = "Pв"
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
          find first tt-dens where tt-dens.key_ = "Pн" no-error .
          if available tt-dens
          then do :
            empty temp-table tt-dens .
          end .
          find first tt-dens no-error .
          if not available tt-dens
          then do ii = 1 to v-num-izm :
            create tt-dens .
            assign
              tt-dens.ii = ii
              tt-dens.key_ = "P" + string(ii) + (if ii = 1 then "(низ)" else "")
            .
          end .
        end .
        when 1
        then do :
          find first tt-dens where tt-dens.key_ begins "P1" no-error .
          if available tt-dens
          then do :
            empty temp-table tt-dens .
          end .
          find first tt-dens no-error .
          if not available tt-dens
          then do :
            create tt-dens .
            assign
              tt-dens.ii = 1
              tt-dens.key_ = "Pн"
            .
            if (p-diameter >= 2500 and p-fuel-level >= (p-diameter / 2))
            or (p-diameter < 2500 and p-fuel-level >= 500)
            or (p-fuel-level >= 500 and p-fuel-level <= (p-diameter / 2))
            then do :
              create tt-dens .
              assign
                tt-dens.ii = 2
                tt-dens.key_ = "Pср"
              .
            end .
            if (p-diameter >= 2500 and p-fuel-level >= (p-diameter / 2))
            then do :
              create tt-dens .
              assign
                tt-dens.ii = 3
                tt-dens.key_ = "Pв"
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
  ENABLE b-ok b-cancel br-dens b-fill-empty
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
    br-dens:row = 2.4 .
    b-fill-empty:row = 12.9 .
    hide
      v-calc-type-label
      cb-calc-type
      v-calc-num-izm
    in FRAME Dialog-Frame.
  end .
  open query br-dens for each tt-dens .
END PROCEDURE.
