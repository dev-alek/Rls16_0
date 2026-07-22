define input parameter parParentProc   AS WIDGET-HANDLE NO-UNDO.
define input parameter par-host-code   as integer no-undo .
define input-output parameter   p-sum-rubl      as decimal no-undo .
define input-output parameter   p-sum-base      as decimal no-undo .
define input-output parameter   p-sum-contr     as decimal no-undo .
define  input         parameter p-basecode      as integer no-undo .
define  input-output  parameter p-base-rate     as decimal no-undo .
define  input-output  parameter p-base-scale    as integer no-undo .
define  input         parameter p-contract-curr as integer no-undo .
define  input-output  parameter p-contract-rate as decimal no-undo .
define  input-output  parameter p-contract-scale as integer no-undo .
define input parameter          p-val-pay as integer no-undo .
define input parameter p-hide-rubl  as logical no-undo .
define input parameter p-hide-base  as logical no-undo .
define input parameter p-hide-contr as logical no-undo .
define output parameter p-res as logical no-undo .
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Форма ввода и корректировки курсов ФО".
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
FUNCTION sel-abbr RETURNS CHARACTER
( p-curr-code as int )  FORWARD.
DEFINE MENU POPUP-MENU-B-r-1
       MENU-ITEM m_rubl-base    LABEL "Пересчитать РУБ по курсу и сумме в &баз.вал."
       MENU-ITEM m_rubl-contr   LABEL "Пересчитать РУБ по курсу и сумме в вал.&договора".
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-r-1
     LABEL "Расчет"
     SIZE 10 BY 1 TOOLTIP "Пересчитать национальную валюту"
     BGCOLOR 8 .
DEFINE BUTTON B-r-2
     LABEL "Расчет"
     SIZE 10 BY 1 TOOLTIP "Пересчитать сумму в Б.В. по курсу Б.В. и сумме в рублях"
     BGCOLOR 8 .
DEFINE BUTTON B-r-3
     LABEL "Расчет"
     SIZE 10 BY 1 TOOLTIP "Пересчитать курс Б.В. по сумме Б.В. и сумме в рублях"
     BGCOLOR 8 .
DEFINE BUTTON B-r-4
     LABEL "Расчет"
     SIZE 10 BY 1 TOOLTIP "Пересчитать сумму в вал.договора по курсу вал.договора и сумме в рублях"
     BGCOLOR 8 .
DEFINE BUTTON B-r-5
     LABEL "Расчет"
     SIZE 10 BY 1 TOOLTIP "Пересчитать курс вал.договора по сумме в вал.договора и сумме в рублях"
     BGCOLOR 8 .
DEFINE BUTTON r-curr-base
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Выбор из справочника валют".
DEFINE BUTTON r-curr-contr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY .88 TOOLTIP "Выбор из справочника валют".
DEFINE VARIABLE FILL-IN-8 AS CHARACTER FORMAT "X(256)":U INITIAL "Старые значения"
      VIEW-AS TEXT
     SIZE 16 BY .67
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE loc_abbr-base AS CHARACTER FORMAT "X(12)":U
     LABEL "Баз.вал."
      VIEW-AS TEXT
     SIZE 5.38 BY .67 TOOLTIP "Базовая валюта"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc_abbr-base-2 AS CHARACTER FORMAT "X(12)":U
      VIEW-AS TEXT
     SIZE 5.38 BY 1 TOOLTIP "Базовая валюта"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc_abbr-contr AS CHARACTER FORMAT "X(12)":U
     LABEL "Валюта договора"
      VIEW-AS TEXT
     SIZE 5.13 BY .67 TOOLTIP "Валюта договора"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc_abbr-contr-2 AS CHARACTER FORMAT "X(12)":U
      VIEW-AS TEXT
     SIZE 5.13 BY 1 TOOLTIP "Валюта договора"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc_abbr-rubl AS CHARACTER FORMAT "X(12)":U INITIAL "РУБ"
      VIEW-AS TEXT
     SIZE 4.5 BY 1 TOOLTIP "Национальная валюта"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc_abbr-rubl-2 AS CHARACTER FORMAT "X(20)":U INITIAL "Национальная валюта:"
      VIEW-AS TEXT
     SIZE 21.5 BY 1 TOOLTIP "Национальная валюта" NO-UNDO.
DEFINE VARIABLE loc_abbr-rubl-5 AS CHARACTER FORMAT "X(20)":U INITIAL "Национальная валюта:"
      VIEW-AS TEXT
     SIZE 21.5 BY 1 TOOLTIP "Национальная валюта" NO-UNDO.
DEFINE VARIABLE loc_abbr-rubl-6 AS CHARACTER FORMAT "X(12)":U INITIAL "РУБ"
      VIEW-AS TEXT
     SIZE 4.5 BY 1 TOOLTIP "Национальная валюта"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE loc_abbr-rubl-7 AS CHARACTER FORMAT "X(12)":U INITIAL "Баз.вал.:"
      VIEW-AS TEXT
     SIZE 9.5 BY 1 NO-UNDO.
DEFINE VARIABLE loc_abbr-rubl-8 AS CHARACTER FORMAT "X(12)":U INITIAL "Договор :"
      VIEW-AS TEXT
     SIZE 9.5 BY 1 NO-UNDO.
DEFINE VARIABLE loc_base-rate AS DECIMAL FORMAT ">>,>>9.9999" INITIAL 0
     LABEL "Курс"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1.
DEFINE VARIABLE loc_base-rate-2 AS DECIMAL FORMAT ">>,>>9.9999" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1.
DEFINE VARIABLE loc_base-scale AS INTEGER FORMAT ">,>>>,>>9" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1.
DEFINE VARIABLE loc_base-scale-2 AS INTEGER FORMAT ">,>>>,>>9" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1.
DEFINE VARIABLE loc_contract-rate AS DECIMAL FORMAT ">>,>>9.9999" INITIAL 0
     LABEL "Курс"
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1.
DEFINE VARIABLE loc_contract-rate-2 AS DECIMAL FORMAT ">>,>>9.9999" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 12 BY 1.
DEFINE VARIABLE loc_contract-scale AS INTEGER FORMAT ">,>>>,>>9" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1.
DEFINE VARIABLE loc_contract-scale-2 AS INTEGER FORMAT ">,>>>,>>9" INITIAL 0
     VIEW-AS FILL-IN NATIVE
     SIZE 5 BY 1.
DEFINE VARIABLE loc_sum-base LIKE fin-ob.sum-base
     LABEL "Сумма"
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 NO-UNDO.
DEFINE VARIABLE loc_sum-base-2 LIKE fin-ob.sum-base
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 TOOLTIP "<<F5>> - пересчет курса баз.вал." NO-UNDO.
DEFINE VARIABLE loc_sum-contract LIKE fin-ob.sum-contract
     LABEL "Сумма"
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 NO-UNDO.
DEFINE VARIABLE loc_sum-contract-2 LIKE fin-ob.sum-contract
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 TOOLTIP "<<F5>> - пересчет курса валюты договора" NO-UNDO.
DEFINE VARIABLE loc_sum-rubl LIKE fin-ob.sum-rubl
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 NO-UNDO.
DEFINE VARIABLE loc_sum-rubl-2 LIKE fin-ob.sum-rubl
     VIEW-AS FILL-IN NATIVE
     SIZE 22 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98.5 BY 9.
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98.5 BY 9.25.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 89.5
     loc_sum-rubl-2 AT ROW 4 COL 40.5 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
     loc_base-rate-2 AT ROW 6 COL 22 COLON-ALIGNED NO-LABEL
     loc_base-scale-2 AT ROW 6 COL 34.5 COLON-ALIGNED NO-LABEL
     loc_sum-base-2 AT ROW 6 COL 40.5 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
     loc_contract-rate-2 AT ROW 8 COL 22 COLON-ALIGNED NO-LABEL
     loc_contract-scale-2 AT ROW 8 COL 34.5 COLON-ALIGNED NO-LABEL
     loc_sum-contract-2 AT ROW 8 COL 40.5 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
     loc_sum-rubl AT ROW 12.5 COL 38.5 COLON-ALIGNED NO-LABEL FORMAT "->,>>>,>>>,>>>,>>9.99"
     B-r-1 AT ROW 12.5 COL 63
     loc_sum-base AT ROW 17.25 COL 10 COLON-ALIGNED
          LABEL "Сумма" FORMAT "->,>>>,>>>,>>>,>>9.99"
     B-r-2 AT ROW 17.25 COL 34.5
     loc_sum-contract AT ROW 17.25 COL 64 COLON-ALIGNED
          LABEL "Сумма" FORMAT "->,>>>,>>>,>>>,>>9.99"
     B-r-4 AT ROW 17.25 COL 88.5
     loc_base-rate AT ROW 18.25 COL 10 COLON-ALIGNED
     loc_base-scale AT ROW 18.25 COL 22.5 COLON-ALIGNED NO-LABEL
     r-curr-base AT ROW 18.25 COL 30.5
     B-r-3 AT ROW 18.25 COL 34.5
     loc_contract-rate AT ROW 18.25 COL 64 COLON-ALIGNED
     loc_contract-scale AT ROW 18.25 COL 76.5 COLON-ALIGNED NO-LABEL
     r-curr-contr AT ROW 18.25 COL 84.5
     B-r-5 AT ROW 18.25 COL 88.5
     FILL-IN-8 AT ROW 1.25 COL 36 COLON-ALIGNED NO-LABEL
     loc_abbr-rubl-5 AT ROW 4 COL 15.5 NO-LABEL
     loc_abbr-rubl-6 AT ROW 4 COL 37.5 NO-LABEL
     loc_abbr-rubl-7 AT ROW 6 COL 4 NO-LABEL
     loc_abbr-base-2 AT ROW 6 COL 17.5 NO-LABEL AUTO-RETURN
     loc_abbr-rubl-8 AT ROW 8 COL 4 NO-LABEL
     loc_abbr-contr-2 AT ROW 8.13 COL 17.5 NO-LABEL AUTO-RETURN
     loc_abbr-rubl-2 AT ROW 12.5 COL 13.5 NO-LABEL
     loc_abbr-rubl AT ROW 12.5 COL 35.5 NO-LABEL
     loc_abbr-base AT ROW 16.5 COL 2 AUTO-RETURN
     loc_abbr-contr AT ROW 16.5 COL 49 AUTO-RETURN
     RECT-6 AT ROW 2.25 COL 1
     RECT-7 AT ROW 11.25 COL 1
     SPACE(0.00) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Расчет сумм и курсов ФО"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-r-1:POPUP-MENU IN FRAME Dialog-Frame       = MENU POPUP-MENU-B-r-1:HANDLE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
DEFINE VARIABLE v-rate-correct AS CHARACTER NO-UNDO.
p-res = YES.
run ver-summ in this-procedure (output v-rate-correct) no-error.
if error-status:error then do:
  message "Ошибка при вызове процедуры rate-correct." skip
          return-value
          error-status:get-message(1)
          error-status:get-message(2)
  view-as alert-box error.
  return no-apply.
end.
CASE v-rate-correct:
    WHEN "base-rate":U THEN DO:
           message
          "Курс базовой валюты не согласован с суммой в базовой валюте и суммой в национальной валюте" skip
          "Сумма в базовой валюте: " loc_sum-base skip
          "Сумма в рублях: " loc_sum-rubl skip
          "Курс базовой валюты: " loc_base-rate skip
          "Шкала базовой валюты: " loc_base-scale
  view-as alert-box information.
        RETURN NO-apply.
    END.
    WHEN "contract-rate":U THEN DO:
        message
          "Курс валюты договора не согласован c суммой договора и суммой в национальной валюте" skip
          "Сумма в валюте договора: " loc_sum-contract skip
          "Сумма в рублях: " loc_sum-rubl skip
          "Курс валюты договора: " loc_contract-rate skip
          "Шкала валюты договора: " loc_contract-scale
view-as alert-box information.
        return NO-apply.
  END.
END CASE.
if loc_sum-rubl = 0 or loc_sum-rubl = ? or
    loc_sum-base       = 0 or   loc_sum-base      = ? or
    loc_sum-contract   = 0 or   loc_sum-contract   = ? or
    loc_base-rate      = 0 or   loc_base-rate      = ? or
    loc_base-scale     = 0 or   loc_base-scale     = ? or
    loc_contract-rate  = 0 or   loc_contract-rate   = ? or
    loc_contract-scale = 0 or   loc_contract-scale  = ?
 then do:
    message "Ошибка при вводе сумм или курсов! "
    "Значение не должно равнятся 0 или ?"  view-as alert-box error .
            return NO-apply.
end.
if
    loc_base-rate      < 0   or
    loc_base-scale     < 0   or
    loc_contract-rate  < 0   or
    loc_contract-scale < 0
 then do:
    message "Ошибка при вводе курсов! "
    "Значение не должно быть меньше 0 "
    view-as alert-box error .
            return NO-apply.
end.
assign
   p-sum-rubl        =  loc_sum-rubl
   p-sum-base        =  loc_sum-base
   p-sum-contr       =  loc_sum-contract
   p-base-rate       =  loc_base-rate
   p-base-scale      =  loc_base-scale
   p-contract-rate   =  loc_contract-rate
   p-contract-scale  =  loc_contract-scale
.
END.
ON CHOOSE OF B-quit IN FRAME Dialog-Frame
DO:
  p-res = NO.
END.
ON CHOOSE OF B-r-1 IN FRAME Dialog-Frame
DO:
    run gbl/pop-up.p (self:handle, no) no-error.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-r-2 IN FRAME Dialog-Frame
DO:
    assign loc_sum-rubl
           loc_base-rate
           loc_base-scale
           .
   loc_sum-base  = (  loc_base-scale   / loc_base-rate) * loc_sum-rubl  .
   display
      loc_sum-base         when loc_sum-base         :visible
      with frame Dialog-Frame  .
END.
ON CHOOSE OF B-r-3 IN FRAME Dialog-Frame
DO:
   ASSIGN loc_sum-rubl
          loc_base-scale
          loc_sum-base
        .
    loc_base-rate = loc_sum-rubl / (loc_base-scale * loc_sum-base) .
    DISPLAY loc_base-rate  WITH FRAME Dialog-Frame  .
END.
ON CHOOSE OF B-r-4 IN FRAME Dialog-Frame
DO:
    assign loc_sum-rubl
         loc_contract-rate
         loc_contract-scale
  .
 loc_sum-contract   = (  loc_contract-scale   / loc_contract-rate) * loc_sum-rubl .
   display
    loc_sum-contract         when loc_sum-contract         :visible
    with frame Dialog-Frame.
END.
ON CHOOSE OF B-r-5 IN FRAME Dialog-Frame
DO:
  ASSIGN
      loc_sum-rubl
      loc_contract-scale
      loc_sum-contract
      .
  loc_contract-rate = loc_sum-rubl / (loc_contract-scale * loc_sum-contract) .
  DISPLAY loc_contract-rate  WITH FRAME Dialog-Frame.
END.
ON LEAVE OF loc_base-rate IN FRAME Dialog-Frame
DO:
  APPLY "LEAVE":U TO loc_sum-base .
END.
ON return OF loc_base-rate IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_base-rate:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_base-rate-2 IN FRAME Dialog-Frame
OR "LEAVE" Of loc_base-scale
OR "LEAVE" Of loc_contract-rate
OR "LEAVE" Of loc_contract-scale
DO:
  assign loc_base-rate loc_base-scale
  loc_contract-rate
  loc_contract-scale
  .
END.
ON return OF loc_base-rate-2 IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_base-rate-2:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_base-scale IN FRAME Dialog-Frame
DO:
  APPLY "LEAVE":U TO loc_sum-base .
END.
ON return OF loc_base-scale IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  loc_base-scale:handle ) .
  return no-apply .
END.
ON return OF loc_base-scale-2 IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_base-scale-2:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_contract-rate IN FRAME Dialog-Frame
DO:
  APPLY "LEAVE":U TO loc_sum-contract .
END.
ON return OF loc_contract-rate IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_contract-rate:handle ) .
  return no-apply .
END.
ON return OF loc_contract-rate-2 IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_contract-rate-2:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_contract-scale IN FRAME Dialog-Frame
DO:
  APPLY "LEAVE":U TO loc_sum-contract .
END.
ON return OF loc_contract-scale IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_contract-scale:handle ) .
  return no-apply .
END.
ON return OF loc_contract-scale-2 IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_contract-scale-2:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_sum-base IN FRAME Dialog-Frame
DO:
    IF loc_sum-base:MODIFIED THEN ASSIGN loc_sum-base.
    IF loc_base-scale:MODIFIED THEN ASSIGN loc_base-scale.
    IF loc_base-rate:MODIFIED THEN ASSIGN loc_base-rate.
    IF p-contract-curr = p-basecode AND p-hide-contr = YES THEN DO:
  loc_sum-contract   = loc_sum-base.
  loc_contract-rate  = loc_base-rate.
  loc_contract-scale = loc_base-scale .
      DISPLAY
            loc_sum-contract
            loc_contract-rate
            loc_contract-scale
        with frame Dialog-Frame.
    END.
END.
ON return OF loc_sum-base IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_sum-base:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_sum-base-2 IN FRAME Dialog-Frame
DO:
assign loc_sum-base
 loc_base-rate loc_base-scale
 loc_contract-rate loc_contract-scale
 .
  loc_sum-rubl    = ( loc_base-rate  / loc_base-scale) * loc_sum-base .
  loc_sum-contract   = (  loc_contract-scale   / loc_contract-rate) * loc_sum-rubl .
   display
    loc_sum-base         when loc_sum-base         :visible
    loc_sum-rubl         when loc_sum-rubl         :visible
    loc_sum-contract     when loc_sum-contract     :visible
    with frame Dialog-Frame.
END.
ON return OF loc_sum-base-2 IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_sum-base-2:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_sum-contract IN FRAME Dialog-Frame
DO:
    IF loc_sum-contract:MODIFIED   THEN ASSIGN loc_sum-contract.
    IF loc_contract-rate:MODIFIED  THEN ASSIGN loc_contract-rate.
    IF loc_contract-scale:MODIFIED THEN ASSIGN loc_contract-scale.
END.
ON return OF loc_sum-contract IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_sum-contract:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_sum-contract-2 IN FRAME Dialog-Frame
DO:
 assign loc_sum-contract
 loc_base-rate loc_base-scale
 loc_contract-rate loc_contract-scale
 .
  loc_sum-rubl  =  ( loc_contract-rate  / loc_contract-scale) * loc_sum-contract .
  loc_sum-base   = (  loc_base-scale   / loc_base-rate) * loc_sum-rubl .
  display
  loc_sum-base           when loc_sum-base         :visible
  loc_sum-rubl           when loc_sum-rubl         :visible
  loc_sum-contract       when loc_sum-contract     :visible
  with frame Dialog-Frame.
 END.
ON return OF loc_sum-contract-2 IN FRAME Dialog-Frame
DO:
      run next-focus in this-procedure  (input  loc_sum-contract-2:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_sum-rubl IN FRAME Dialog-Frame
DO:
IF loc_sum-rubl:MODIFIED THEN ASSIGN loc_sum-rubl.
IF p-basecode = 0 THEN DO:
loc_sum-base   = loc_sum-rubl.
loc_base-rate  = 1           .
loc_base-scale = 1           .
    DISPLAY
          loc_sum-base
          loc_base-rate
          loc_base-scale
      with frame Dialog-Frame.
  END.
  IF p-contract-curr = 0 THEN DO:
  loc_sum-contract   = loc_sum-rubl.
  loc_contract-rate  = 1           .
  loc_contract-scale = 1           .
      DISPLAY
            loc_sum-contract
            loc_contract-rate
            loc_contract-scale
        with frame Dialog-Frame.
    END.
END.
ON return OF loc_sum-rubl IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_sum-rubl:handle ) .
  return no-apply .
END.
ON LEAVE OF loc_sum-rubl-2 IN FRAME Dialog-Frame
DO:
assign loc_sum-rubl
 loc_base-rate loc_base-scale
 loc_contract-rate loc_contract-scale
 .
  loc_sum-base    = ( loc_base-scale  / loc_base-rate) * loc_sum-rubl .
  loc_sum-contract      = (  loc_contract-scale    / loc_contract-rate) * loc_sum-rubl .
  display
  loc_sum-base            when loc_sum-base         :visible
  loc_sum-contract        when loc_sum-contract     :visible
  with frame Dialog-Frame.
END.
ON return OF loc_sum-rubl-2 IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  loc_sum-rubl-2:handle ) .
  return no-apply .
END.
ON CHOOSE OF MENU-ITEM m_rubl-base
DO:
    assign  FRAME Dialog-Frame
           loc_sum-base
           loc_base-rate
           loc_base-scale
           .
  loc_sum-rubl    = ( loc_base-rate  / loc_base-scale) * loc_sum-base .
   display
    loc_sum-rubl         when loc_sum-rubl         :visible
   with frame Dialog-Frame.
  APPLY "LEAVE":U TO loc_sum-rubl .
END.
ON CHOOSE OF MENU-ITEM m_rubl-contr
DO:
  assign FRAME Dialog-Frame  loc_sum-contract
           loc_contract-rate
           loc_contract-scale
           .
  loc_sum-rubl    = ( loc_contract-rate  / loc_contract-scale) * loc_sum-contract .
   display
    loc_sum-rubl         when loc_sum-rubl         :visible
   with frame Dialog-Frame.
   APPLY "LEAVE":U TO loc_sum-rubl .
END.
ON CHOOSE OF r-curr-base IN FRAME Dialog-Frame
DO:
define variable vss-include-info0 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
define variable v-base-abbr like ub.currency.curr-abbr no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  p-basecode
  ,input  today
  ,output loc_base-rate
  ,output loc_base-scale
  ,output v-base-abbr
  )  .
   display
   loc_base-rate
   loc_base-scale
   with frame Dialog-Frame.
END.
ON CHOOSE OF r-curr-contr IN FRAME Dialog-Frame
DO:
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable v-contract-abbr like ub.currency.curr-abbr no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  p-contract-curr
  ,input  today
  ,output loc_contract-rate
  ,output loc_contract-scale
  ,output v-contract-abbr
  )  .
     display
     loc_contract-rate
     loc_contract-scale
     with frame Dialog-Frame.
END.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
ASSIGN B-r-1 :POPUP-MENU IN FRAME Dialog-Frame = MENU POPUP-MENU-B-r-1 :HANDLE.
ASSIGN B-r-1 :MENU-MOUSE = 1.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run enable_my.
  wait-for go of frame Dialog-Frame focus loc_sum-rubl .
END.
run disable_ui.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_my :
assign
  loc_sum-rubl       = p-sum-rubl
  loc_sum-base       = p-sum-base
  loc_sum-contract      = p-sum-contr
  loc_sum-rubl-2        = p-sum-rubl
  loc_sum-base-2        = p-sum-base
  loc_sum-contract-2    = p-sum-contr
  loc_base-rate      = p-base-rate
  loc_base-scale     = p-base-scale
  loc_contract-rate  = p-contract-rate
  loc_contract-scale = p-contract-scale
  loc_base-rate-2      = p-base-rate
  loc_base-scale-2     = p-base-scale
  loc_contract-rate-2  = p-contract-rate
  loc_contract-scale-2 = p-contract-scale
  loc_abbr-base         = sel-abbr(p-basecode)
  loc_abbr-base-2       = sel-abbr(p-basecode)
  loc_abbr-contr        = sel-abbr(p-contract-curr)
  loc_abbr-contr-2      = sel-abbr(p-contract-curr)
.
MENU-ITEM m_rubl-base:sensitive IN MENU POPUP-MENU-B-r-1  = NOT p-hide-base .
MENU-ITEM m_rubl-contr:sensitive IN MENU POPUP-MENU-B-r-1 = NOT p-hide-contr .
DISPLAY loc_sum-rubl-2 loc_base-rate-2 loc_base-scale-2 loc_sum-base-2
          loc_contract-rate-2 loc_contract-scale-2 loc_sum-contract-2
          loc_sum-rubl loc_sum-base loc_sum-contract loc_base-rate
          loc_base-scale loc_contract-rate loc_contract-scale FILL-IN-8
          loc_abbr-rubl-5 loc_abbr-rubl-6 loc_abbr-rubl-7 loc_abbr-base-2
          loc_abbr-rubl-8 loc_abbr-contr-2 loc_abbr-rubl-2 loc_abbr-rubl
          loc_abbr-base
          loc_abbr-contr
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help
          B-r-1         when p-hide-rubl = false
          loc_sum-rubl  when p-hide-rubl = false
          B-r-2          when p-hide-base = false
          B-r-3          when p-hide-base = false
          loc_sum-base   when p-hide-base = false
          loc_base-rate  when p-hide-base = false
          loc_base-scale when p-hide-base = false
          r-curr-base    when p-hide-base = false
          B-r-4              when p-hide-contr = false
          B-r-5              when p-hide-contr = false
          loc_sum-contract   when p-hide-contr = false
          loc_contract-rate  when p-hide-contr = false
          loc_contract-scale when p-hide-contr = false
          r-curr-contr       when p-hide-contr = false
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY loc_sum-rubl-2 loc_base-rate-2 loc_base-scale-2 loc_sum-base-2
          loc_contract-rate-2 loc_contract-scale-2 loc_sum-contract-2
          loc_sum-rubl loc_sum-base loc_sum-contract loc_base-rate
          loc_base-scale loc_contract-rate loc_contract-scale FILL-IN-8
          loc_abbr-rubl-5 loc_abbr-rubl-6 loc_abbr-rubl-7 loc_abbr-base-2
          loc_abbr-rubl-8 loc_abbr-contr-2 loc_abbr-rubl-2 loc_abbr-rubl
          loc_abbr-base loc_abbr-contr
      WITH FRAME Dialog-Frame.
  ENABLE B-exit B-quit B-Help loc_sum-contract-2 B-r-1 B-r-2 loc_sum-contract
         B-r-4 r-curr-base B-r-3 r-curr-contr B-r-5 FILL-IN-8 loc_abbr-rubl-5
         loc_abbr-rubl-6 loc_abbr-rubl-7 loc_abbr-base-2 loc_abbr-rubl-8
         loc_abbr-contr-2 loc_abbr-rubl-2 loc_abbr-rubl loc_abbr-base
         loc_abbr-contr RECT-6 RECT-7
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE next-focus :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
  define input parameter p-widget-handle as handle no-undo .
  define variable l-apply-entry as logical no-undo .
  assign
    l-apply-entry =   true
  .
  do with frame Dialog-Frame :
    if  loc_sum-rubl       :handle = p-widget-handle then do:
                                                         if loc_sum-base :sensitive then do:       apply "entry":u to loc_sum-base    .        return . end.
                                                         if loc_sum-contract :sensitive then do:       apply "entry":u to loc_sum-contract    .        return . end.
                                                         if B-exit     :sensitive then do:       apply "entry":u to B-exit     .        return . end.
                                                     end.
    if  loc_sum-base       :handle = p-widget-handle then do:
                                                            if loc_base-rate :sensitive then do:       apply "entry":u to loc_base-rate   .        return . end.
                                                            if loc_sum-contract :sensitive then do:       apply "entry":u to loc_sum-contract    .        return . end.
                                                            if B-exit     :sensitive then do:       apply "entry":u to B-exit     .        return . end.
                                                          end.
    if  loc_sum-contract   :handle = p-widget-handle then do:
                                                          if loc_contract-rate :sensitive then do:       apply "entry":u to loc_contract-rate   .        return . end.
                                                          if B-exit     :sensitive then do:       apply "entry":u to B-exit     .        return . end.
                                                          end.
    if  loc_base-rate    :handle = p-widget-handle then do:
        if loc_base-scale :sensitive then do:       apply "entry":u to loc_base-scale.  return . end.
    END.
    if loc_base-scale    :handle = p-widget-handle then do:
       if loc_sum-contract :sensitive then do:       apply "entry":u to loc_sum-contract.  return . end.
       if B-exit     :sensitive then do:       apply "entry":u to B-exit     .        return . end.
    END.
    if loc_contract-rate    :handle = p-widget-handle then do:
       if loc_contract-scale :sensitive then do:       apply "entry":u to loc_contract-scale.  return . end.
    END.
    if loc_contract-scale    :handle = p-widget-handle then do:
       if B-exit     :sensitive then do:       apply "entry":u to B-exit     .        return . end.
    END.
    end.
  end.
END PROCEDURE.
PROCEDURE ver-summ :
DEFINE OUTPUT PARAMETER p-rate-correct AS CHARACTER NO-UNDO.
IF abs( (loc_sum-rubl / loc_sum-base)  - (loc_base-rate / loc_base-scale)) > 0.0001  THEN DO:
    p-rate-correct = "base-rate":U.
    RETURN.
END.
IF abs( (loc_sum-rubl / loc_sum-contract) - (loc_contract-rate / loc_contract-scale )) > 0.0001 THEN DO:
    p-rate-correct = "contract-rate":U.
    RETURN.
END.
END PROCEDURE.
FUNCTION sel-abbr RETURNS CHARACTER
( p-curr-code as int ) :
  define variable rr as character no-undo .
  find first currency no-lock where  currency.curr-code  = p-curr-code no-error.
  rr = currency.curr-abbr .
  RETURN rr.
END FUNCTION.
