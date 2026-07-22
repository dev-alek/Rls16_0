define input-output parameter p-InfoSec as class ibs.th.str.InfoSection .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "OK"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE VARIABLE e-pokmi-warnings AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 73 BY 2.62 NO-UNDO.
DEFINE VARIABLE v-legend AS CHARACTER
     VIEW-AS EDITOR
     SIZE 69 BY 3.6 NO-UNDO.
DEFINE VARIABLE f-deficit AS CHARACTER format "X(20)":U INITIAL 0
     LABEL "Масса недостачи (кг)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-density AS CHARACTER format "X(20)":U INITIAL 0
     LABEL "Плотность НП (г/см3)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-excess AS CHARACTER format "X(20)":U INITIAL 0
     LABEL "Масса излишка (кг)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-fact-kg-qnty AS CHARACTER format "X(20)":U INITIAL 0
     LABEL "Масса НП, подлежащая оприходованию по результатам приема (кг)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-fact-qnty AS CHARACTER format "X(20)":U INITIAL 0
     LABEL "Объем НП, подлежащий оприходованию по результатам приема (л)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-limit AS CHARACTER format "X(20)":U INITIAL 0
     LABEL "Масса допустимого расхождения (кг)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-norm-loss AS CHARACTER format "X(20)":U INITIAL 0
     LABEL "Масса ЕУ при перевозке (кг)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-pokmi-kg-qnty AS CHARACTER format "X(20)":U INITIAL 0
     LABEL "Масса НП, по результатам расчета модуля ПОкМИ (кг)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-pokmi-qnty AS CHARACTER format "X(20)":U INITIAL 0
     LABEL "Объем НП, по результатам расчета модуля ПОкМИ (л)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE VARIABLE f-temperature AS CHARACTER format "X(20)":U INITIAL 0
     LABEL "Температура (С)"
      VIEW-AS TEXT
     SIZE 14 BY .62 NO-UNDO.
DEFINE FRAME Dialog-Frame
     e-pokmi-warnings AT ROW 12.02 COL 2 NO-LABEL WIDGET-ID 40
     v-legend AT ROW 14.84 COL 2 NO-LABEL WIDGET-ID 2
     Btn_OK AT ROW 16.74 COL 72
     f-fact-kg-qnty AT ROW 1.48 COL 2 WIDGET-ID 4
     f-pokmi-kg-qnty AT ROW 2.52 COL 2 WIDGET-ID 6
     f-limit AT ROW 3.52 COL 2 WIDGET-ID 8
     f-excess AT ROW 4.48 COL 2 WIDGET-ID 10
     f-deficit AT ROW 5.48 COL 2 WIDGET-ID 12
     f-norm-loss AT ROW 6.43 COL 2 WIDGET-ID 14
     f-fact-qnty AT ROW 7.43 COL 2 WIDGET-ID 16
     f-pokmi-qnty AT ROW 8.38 COL 2 WIDGET-ID 18
     f-density AT ROW 9.33 COL 2 WIDGET-ID 20
     f-temperature AT ROW 10.24 COL 2 WIDGET-ID 22
     "Предупреждения:" VIEW-AS TEXT
          SIZE 22 BY .62 AT ROW 11.25 COL 3 WIDGET-ID 38
     SPACE(2.00) SKIP(1.5)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Результат расчета"
         DEFAULT-BUTTON Btn_OK WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       e-pokmi-warnings:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-deficit:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       f-density:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
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
ASSIGN
       f-temperature:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ASSIGN
       v-legend:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  assign
    v-legend = "Для посекционных сверок выводится результат расчета по секциям отдельно."
             + " Для общих сверок выводится результат расчета, суммированный по всем секциям."
             + " Для сообщающихся резервуаров выводится результат расчета, суммированный по всем сообщающимся резервуарам."
  .
  if p-InfoSec:AccMeth = 1
  then do :
    assign
      frame Dialog-Frame:title = frame Dialog-Frame:title + " (Принято к учёту)"
      f-fact-kg-qnty    = trim(string(p-InfoSec:FactKgQnty, "->>,>>>,>>9.9":U))
      f-pokmi-kg-qnty   = trim(string(p-InfoSec:TankWeightRvs, "->>,>>>,>>9.9":U))
      f-limit           = trim(string(p-InfoSec:AccAbsFact, "->>,>>>,>>9.9":U))
      f-excess          = trim(string(p-InfoSec:Excess, "->>,>>>,>>9.9":U))
      f-deficit         = trim(string(p-InfoSec:Deficit, "->>,>>>,>>9.9":U))
      f-norm-loss       = trim(string(p-InfoSec:NaturalLoss, "->>,>>>,>>9.9":U))
      f-fact-qnty       = trim(string(p-InfoSec:FactQnty, "->>,>>>,>>9":U))
      f-pokmi-qnty      = trim(string(p-InfoSec:TankVolPomiRvs, "->>,>>>,>>9":U))
      f-density         = trim(string((p-InfoSec:FactKgQnty / p-InfoSec:FactQnty), "9.9999"))
      f-temperature     = trim(string(p-InfoSec:AvgTempRvs, "->>9.9"))
      e-pokmi-warnings  = p-InfoSec:PokmiWarningsRVS
    .
  end .
  else do :
    assign
      frame Dialog-Frame:title = frame Dialog-Frame:title + " (Справка)"
      f-fact-kg-qnty    = ""
      f-pokmi-kg-qnty   = trim(string(p-InfoSec:TankWeightRvs, "->>,>>>,>>9.9":U))
      f-limit           = trim(string(p-InfoSec:AccAbsFact, "->>,>>>,>>9.9":U))
      f-excess          = ""
      f-deficit         = ""
      f-norm-loss       = trim(string(p-InfoSec:NaturalLoss, "->>,>>>,>>9.9":U))
      f-fact-qnty       = ""
      f-pokmi-qnty      = trim(string(p-InfoSec:TankVolPomiRvs, "->>,>>>,>>9":U))
      f-density         = trim(string((p-InfoSec:TankWeightRvs / p-InfoSec:TankVolPomiRvs), "9.9999"))
      f-temperature     = trim(string(p-InfoSec:AvgTempRvs, "->>9.9"))
      e-pokmi-warnings  = p-InfoSec:PokmiWarningsRVS
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
  DISPLAY v-legend f-fact-kg-qnty f-pokmi-kg-qnty f-limit f-excess f-deficit
          f-norm-loss f-fact-qnty f-pokmi-qnty f-density f-temperature
      WITH FRAME Dialog-Frame.
  ENABLE e-pokmi-warnings Btn_OK
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
