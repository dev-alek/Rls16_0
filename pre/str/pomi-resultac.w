define input-output parameter p-InfoSec as class ibs.th.str.InfoSection .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "OK"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE VARIABLE e-pokmi-warnings AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 73 BY 2.62 NO-UNDO.
DEFINE VARIABLE f-deficit AS CHARACTER FORMAT "X(20)":U INITIAL "0"
     LABEL "Масса недостачи НП (кг)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-delta-1 AS CHARACTER FORMAT "X(20)":U INITIAL "0"
     LABEL "ПОкМИ (%)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-delta-2 AS CHARACTER FORMAT "X(20)":U INITIAL "0"
     LABEL "Относительная погрешность измерения массы нефтепродукта (%)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-density AS CHARACTER FORMAT "X(20)":U INITIAL "0"
     LABEL "Плотность НП (г/см3)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-density-2 AS CHARACTER FORMAT "X(20)":U INITIAL "0"
     LABEL "модуля ПОкМИ (кг/м3)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-excess AS CHARACTER FORMAT "X(20)":U INITIAL "0"
     LABEL "Масса излишка НП (кг)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-fact-kg-qnty AS CHARACTER FORMAT "X(20)":U INITIAL "0"
     LABEL "Масса НП, подлежащая оприходованию по результатам приема (кг)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-fact-qnty AS CHARACTER FORMAT "X(20)":U INITIAL "0"
     LABEL "Объем НП, подлежащий оприходованию по результатам приема (л)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-limit AS CHARACTER FORMAT "X(20)":U INITIAL "0"
     LABEL "Масса допустимого расхождения (кг)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-norm-loss AS CHARACTER FORMAT "X(20)":U INITIAL "0"
     LABEL "Масса естественной убыли НП при перевозке (кг)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-pokmi-kg-qnty AS CHARACTER FORMAT "X(20)":U INITIAL "0"
     LABEL "Масса НП, по результатам расчета модуля ПОкМИ (кг)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-pokmi-qnty AS CHARACTER FORMAT "X(20)":U INITIAL "0"
     LABEL "ПОкМИ (л)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE FRAME Dialog-Frame
     e-pokmi-warnings AT ROW 15.52 COL 2 NO-LABEL WIDGET-ID 40
     Btn_OK AT ROW 18.38 COL 61
     f-fact-kg-qnty AT ROW 1.48 COL 2 WIDGET-ID 4
     f-pokmi-kg-qnty AT ROW 2.43 COL 2 WIDGET-ID 6
     f-limit AT ROW 3.38 COL 2 WIDGET-ID 8
     f-delta-1 AT ROW 4.95 COL 2 WIDGET-ID 34
     f-delta-2 AT ROW 5.71 COL 2 WIDGET-ID 36
     f-excess AT ROW 6.52 COL 2 WIDGET-ID 10
     f-deficit AT ROW 7.48 COL 2 WIDGET-ID 12
     f-norm-loss AT ROW 8.43 COL 2 WIDGET-ID 14
     f-fact-qnty AT ROW 9.33 COL 2 WIDGET-ID 16
     f-pokmi-qnty AT ROW 11 COL 2 WIDGET-ID 18
     f-density AT ROW 11.86 COL 2 WIDGET-ID 20
     f-density-2 AT ROW 13.62 COL 2 WIDGET-ID 24
     "Объем НП при температуре его измерения по результатам расчета модуля" VIEW-AS TEXT
          SIZE 79 BY .62 AT ROW 10.19 COL 2 WIDGET-ID 26
     "Предупреждения:" VIEW-AS TEXT
          SIZE 22 BY .62 AT ROW 14.81 COL 3 WIDGET-ID 38
     "Относительная погрешность измерения массы нефтепродукта по результатам" VIEW-AS TEXT
          SIZE 82 BY .62 AT ROW 4.19 COL 2 WIDGET-ID 30
     "Плотность НП, приведенная к стандартным условиям по результатам расчета" VIEW-AS TEXT
          SIZE 83 BY .62 AT ROW 12.81 COL 2 WIDGET-ID 28
     SPACE(2.00) SKIP(1.5)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Результат расчета АЦ"
         DEFAULT-BUTTON Btn_OK WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       e-pokmi-warnings:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-deficit:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-delta-1:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-delta-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-density:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-density-2:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-excess:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-fact-kg-qnty:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-fact-qnty:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-limit:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-norm-loss:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-pokmi-kg-qnty:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-pokmi-qnty:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  if p-InfoSec:AccMeth = 0
  then do :
    assign
      frame Dialog-Frame:title = frame Dialog-Frame:title + " (Принято к учёту)"
      f-fact-kg-qnty    = trim(string(p-InfoSec:FactKgQnty, "->>,>>>,>>9.9":U))
      f-pokmi-kg-qnty   = trim(string(p-InfoSec:TankWeight, "->>,>>>,>>9.9":U))
      f-limit           = trim(string(p-InfoSec:AccAbsFact, "->>,>>>,>>9.9":U))
      f-delta-1         = trim(string(p-InfoSec:AccPomiReal, "->>,>>>,>>9.99":U))
      f-delta-2         = trim(string(p-InfoSec:AccPomi, "->>,>>>,>>9.99":U))
      f-excess          = trim(string(p-InfoSec:Excess, "->>,>>>,>>9.9":U))
      f-deficit         = trim(string(p-InfoSec:Deficit, "->>,>>>,>>9.9":U))
      f-norm-loss       = trim(string(p-InfoSec:NaturalLoss, "->>,>>>,>>9.9":U))
      f-fact-qnty       = trim(string(p-InfoSec:FactQnty, "->>,>>>,>>9":U))
      f-pokmi-qnty      = trim(string(p-InfoSec:TankVolPomiReal, "->>,>>>,>>9":U))
      f-density         = trim(string((p-InfoSec:FactKgQnty / p-InfoSec:FactQnty), "9.9999"))
      f-density-2       = trim(string((p-InfoSec:TankDensityPomi * 1000), "->>,>>>,>>9.9":U))
      e-pokmi-warnings  = p-InfoSec:PokmiWarnings
    .
  end .
  else do :
    assign
      frame Dialog-Frame:title = frame Dialog-Frame:title + " (Справка)"
      f-fact-kg-qnty    = ""
      f-pokmi-kg-qnty   = trim(string(p-InfoSec:TankWeight, "->>,>>>,>>9.9":U))
      f-limit           = trim(string(p-InfoSec:AccAbsFact, "->>,>>>,>>9.9":U))
      f-delta-1         = trim(string(p-InfoSec:AccPomiReal, "->>,>>>,>>9.99":U))
      f-delta-2         = trim(string(p-InfoSec:AccPomi, "->>,>>>,>>9.99":U))
      f-excess          = ""
      f-deficit         = ""
      f-norm-loss       = trim(string(p-InfoSec:NaturalLoss, "->>,>>>,>>9.9":U))
      f-fact-qnty       = ""
      f-pokmi-qnty      = trim(string(p-InfoSec:TankVolPomiReal, "->>,>>>,>>9":U))
      f-density         = trim(string((p-InfoSec:TankWeight / p-InfoSec:TankVolPomiReal), "9.9999"))
      f-density-2       = trim(string((p-InfoSec:TankDensityPomi * 1000), "->>,>>>,>>9.9":U))
      e-pokmi-warnings  = p-InfoSec:PokmiWarnings
    .
  end .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY e-pokmi-warnings f-fact-kg-qnty f-pokmi-kg-qnty f-limit f-delta-1
          f-delta-2 f-excess f-deficit f-norm-loss f-fact-qnty f-pokmi-qnty
          f-density f-density-2
      WITH FRAME Dialog-Frame.
  ENABLE e-pokmi-warnings Btn_OK
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
