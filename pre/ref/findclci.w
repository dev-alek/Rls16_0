DEFINE BUFFER buf_base-currency FOR ub.currency.
DEFINE BUFFER buf_contract-currency FOR ub.currency.
DEFINE BUFFER buf_currency FOR ub.currency.
DEFINE INPUT        PARAMETER parParentProc    AS WIDGET-HANDLE               NO-UNDO.
define input        parameter p-mode           as character                   no-undo.
DEFINE INPUT        PARAMETER p-doc-date       LIKE ub.fin-doc.doc-date       NO-UNDO.
DEFINE INPUT        PARAMETER p-curr-code      LIKE ub.fin-doc.curr-code      NO-UNDO.
DEFINE INPUT        PARAMETER p-base-code      LIKE ub.sysconf.base-code      NO-UNDO.
DEFINE INPUT        PARAMETER p-contract-curr  LIKE ub.fin-doc.contract-curr  NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-sum-doc        LIKE ub.fin-doc.sum-doc        NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-exch-rate      LIKE ub.fin-doc.exch-rate      NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-exch-scale     LIKE ub.fin-doc.exch-scale     NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-sum-rubl       LIKE ub.fin-doc.sum-rubl       NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-sum-base       LIKE ub.fin-doc.sum-base       NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-base-rate      LIKE ub.fin-doc.base-rate      NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-base-scale     LIKE ub.fin-doc.base-scale     NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-sum-contr      LIKE ub.fin-doc.sum-contr      NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-contract-rate  LIKE ub.fin-doc.contract-rate  NO-UNDO.
DEFINE INPUT-OUTPUT PARAMETER p-contract-scale LIKE ub.fin-doc.contract-scale NO-UNDO.
def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "Карточка редактирования сумм и курсов платежного документа".
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
define variable v-rubf          as logical no-undo .
define variable v-exchf         as logical no-undo .
define variable v-basef         as logical no-undo .
define variable v-baseratef     as logical no-undo .
define variable v-contractf     as logical no-undo .
define variable v-contractratef as logical no-undo .
define variable v-sum-doc-m        AS INTEGER NO-UNDO.
define variable v-exch-rate-m      AS INTEGER NO-UNDO.
define variable v-sum-rubl-m       AS INTEGER NO-UNDO.
define variable v-sum-base-m       AS INTEGER NO-UNDO.
define variable v-base-rate-m      AS INTEGER NO-UNDO.
define variable v-sum-contr-m      AS INTEGER NO-UNDO.
define variable v-contract-rate-m  AS INTEGER NO-UNDO.
DEFINE VARIABLE v-rubl-calc-option AS CHARACTER NO-UNDO.
define variable v-sum-doc-c        as character no-undo init "0":U .
define variable v-exch-rate-c      as character no-undo init "0":U.
define variable v-sum-rubl-c       as character no-undo init "0":U.
define variable v-sum-base-c       as character no-undo init "0":U.
define variable v-base-rate-c      as character no-undo init "0":U.
define variable v-sum-contr-c      as character no-undo init "0":U.
define variable v-contract-rate-c  as character no-undo init "0":U.
define variable v-tab-order as character no-undo .
DEFINE MENU MENU-B-rubl-sum
       MENU-ITEM m_doc          LABEL "По сумме в вал. платежа и курсу вал. платежа"
       MENU-ITEM m_base         LABEL "По сумме в баз.вал. и курсу баз.вал."
       MENU-ITEM m_contr        LABEL "По сумме в вал. дог-ра и курсу вал. дог-ра".
DEFINE BUTTON B-base-rate
     LABEL "Расчет"
     SIZE 10 BY 1.
DEFINE BUTTON B-base-sum
     LABEL "Расчет"
     SIZE 10 BY 1.
DEFINE BUTTON B-contract-rate
     LABEL "Расчет"
     SIZE 10 BY 1.
DEFINE BUTTON B-contract-sum
     LABEL "Расчет"
     SIZE 10 BY 1.
DEFINE BUTTON B-doc-sum
     LABEL "Расчет"
     SIZE 10 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-get-base
     LABEL "<-Справ-ник"
     SIZE 8.5 BY 1 TOOLTIP "Получить курс базовой валюты из справочника на дату платежа"
     FONT 4.
DEFINE BUTTON B-get-contract
     LABEL "<-Справ-ник"
     SIZE 8.5 BY 1 TOOLTIP "Получить курс валюты договора из справочника на дату платежа"
     FONT 4.
DEFINE BUTTON B-get-rate
     LABEL "<-Справ-ник"
     SIZE 9 BY 1 TOOLTIP "Получить курс валюты платежа из справочника на дату платежа"
     FONT 4.
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-rate
     LABEL "Расчет"
     SIZE 10 BY 1.
DEFINE BUTTON B-rubl-sum
     LABEL "Расчет"
     SIZE 10 BY 1.
DEFINE BUTTON BUTTON-1
     LABEL "Отлад. кнопка!!!!"
     SIZE 19.5 BY 1.25.
DEFINE VARIABLE base-code-0 LIKE ub.fin-doc.curr-code
     LABEL "Базовая валюта"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE base-code-1 LIKE ub.fin-doc.curr-code
     LABEL "Базовая валюта"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE base-rate-0 LIKE ub.fin-doc.base-rate
     LABEL "Курс"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE base-rate-1 LIKE ub.fin-doc.base-rate
     LABEL "Курс"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE base-scale-0 LIKE ub.fin-doc.base-scale
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1 NO-UNDO.
DEFINE VARIABLE base-scale-1 LIKE ub.fin-doc.base-scale
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1 NO-UNDO.
DEFINE VARIABLE contract-curr-code-0 LIKE ub.fin-doc.curr-code
     LABEL "Валюта договора"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE contract-curr-code-1 LIKE ub.fin-doc.curr-code
     LABEL "Валюта договора"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE contract-rate-0 LIKE ub.fin-doc.contract-rate
     LABEL "Курс"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE contract-rate-1 LIKE ub.fin-doc.contract-rate
     LABEL "Курс"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE contract-scale-0 LIKE ub.fin-doc.contract-scale
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1 NO-UNDO.
DEFINE VARIABLE contract-scale-1 LIKE ub.fin-doc.contract-scale
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1 NO-UNDO.
DEFINE VARIABLE curr-code-0 LIKE ub.fin-doc.curr-code
     LABEL "Валюта платежа"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE curr-code-1 LIKE ub.fin-doc.curr-code
     LABEL "Валюта платежа"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE doc-date-0 LIKE ub.fin-doc.doc-date
     LABEL "Дата платежа"
     VIEW-AS FILL-IN
     SIZE 11 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE exch-rate-0 LIKE ub.fin-doc.exch-rate
     LABEL "Курс"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE exch-rate-1 LIKE ub.fin-doc.exch-rate
     LABEL "Курс"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE exch-scale-0 LIKE ub.fin-doc.exch-scale
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1 NO-UNDO.
DEFINE VARIABLE exch-scale-1 LIKE ub.fin-doc.exch-scale
     VIEW-AS FILL-IN
     SIZE 5.63 BY 1 NO-UNDO.
DEFINE VARIABLE F-base-abbr-0 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE F-base-abbr-1 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE F-contract-curr-abbr-0 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE F-contract-curr-abbr-1 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE F-curr-abbr-0 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE F-curr-abbr-1 AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sum-base-0 LIKE ub.fin-doc.sum-base
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE sum-base-1 LIKE ub.fin-doc.sum-base
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE sum-contr-0 LIKE ub.fin-doc.sum-contr
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE sum-contr-1 LIKE ub.fin-doc.sum-contr
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE sum-doc-0 LIKE ub.fin-doc.sum-doc
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 25 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sum-doc-1 LIKE ub.fin-doc.sum-doc
     LABEL "Сумма"
     VIEW-AS FILL-IN
     SIZE 25 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE sum-rubl-0 LIKE ub.fin-doc.sum-rubl
     LABEL "abbr_rubli_firstshift"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE VARIABLE sum-rubl-1 LIKE ub.fin-doc.sum-rubl
     LABEL "abbr_rubli_firstshift"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98.25 BY 10.54.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 98.25 BY 9.
DEFINE QUERY Dialog-Frame FOR
      ub.fin-doc SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 83
     doc-date-0 AT ROW 2.5 COL 17.5 COLON-ALIGNED
          LABEL "Дата платежа"
          FGCOLOR 4
     curr-code-0 AT ROW 2.5 COL 49.5 COLON-ALIGNED
          LABEL "Валюта платежа"
     F-curr-abbr-0 AT ROW 2.5 COL 54.5 COLON-ALIGNED NO-LABEL
     sum-doc-0 AT ROW 3.5 COL 33.5 COLON-ALIGNED
          LABEL "Сумма" FORMAT ">,>>>,>>>,>>>,>>9.99"
          FGCOLOR 4
     exch-rate-0 AT ROW 4.5 COL 33.5 COLON-ALIGNED
          LABEL "Курс"
     exch-scale-0 AT ROW 4.5 COL 43.75 COLON-ALIGNED NO-LABEL
     sum-rubl-0 AT ROW 6.5 COL 33.5 COLON-ALIGNED
          LABEL "abbr_rubli_firstshift"
     base-code-0 AT ROW 8 COL 24.5 COLON-ALIGNED
          LABEL "Базовая валюта"
     F-base-abbr-0 AT ROW 8 COL 30 COLON-ALIGNED NO-LABEL
     contract-curr-code-0 AT ROW 8 COL 75 COLON-ALIGNED
          LABEL "Валюта договора"
     F-contract-curr-abbr-0 AT ROW 8 COL 80 COLON-ALIGNED NO-LABEL
     sum-base-0 AT ROW 9 COL 9 COLON-ALIGNED
          LABEL "Сумма"
     sum-contr-0 AT ROW 9 COL 59 COLON-ALIGNED
          LABEL "Сумма"
     base-rate-0 AT ROW 10 COL 9 COLON-ALIGNED
          LABEL "Курс"
     base-scale-0 AT ROW 10 COL 19.5 COLON-ALIGNED NO-LABEL
     contract-rate-0 AT ROW 10 COL 59 COLON-ALIGNED
          LABEL "Курс"
     contract-scale-0 AT ROW 10 COL 69.5 COLON-ALIGNED NO-LABEL
     curr-code-1 AT ROW 12 COL 49.5 COLON-ALIGNED
          LABEL "Валюта платежа"
     F-curr-abbr-1 AT ROW 12 COL 54.5 COLON-ALIGNED NO-LABEL
     BUTTON-1 AT ROW 12 COL 73.5
     sum-doc-1 AT ROW 13 COL 33.5 COLON-ALIGNED
          LABEL "Сумма" FORMAT ">,>>>,>>>,>>>,>>9.99"
          FGCOLOR 4
     B-doc-sum AT ROW 13 COL 61
     exch-rate-1 AT ROW 14 COL 33.5 COLON-ALIGNED
          LABEL "Курс"
     exch-scale-1 AT ROW 14 COL 43.75 COLON-ALIGNED NO-LABEL
     B-get-rate AT ROW 14 COL 51.5
     B-rate AT ROW 14 COL 61
     sum-rubl-1 AT ROW 16 COL 33.5 COLON-ALIGNED
          LABEL "abbr_rubli_firstshift"
     B-rubl-sum AT ROW 16 COL 61
     base-code-1 AT ROW 17.5 COL 22 COLON-ALIGNED
          LABEL "Базовая валюта"
     F-base-abbr-1 AT ROW 17.5 COL 27.5 COLON-ALIGNED NO-LABEL
     contract-curr-code-1 AT ROW 17.5 COL 75 COLON-ALIGNED
          LABEL "Валюта договора"
     F-contract-curr-abbr-1 AT ROW 17.5 COL 80 COLON-ALIGNED NO-LABEL
     sum-base-1 AT ROW 18.5 COL 6.5 COLON-ALIGNED
          LABEL "Сумма"
     B-base-sum AT ROW 18.5 COL 34
     sum-contr-1 AT ROW 18.5 COL 59 COLON-ALIGNED
          LABEL "Сумма"
     B-contract-sum AT ROW 18.5 COL 86.5
     base-rate-1 AT ROW 19.5 COL 6.5 COLON-ALIGNED
          LABEL "Курс"
     base-scale-1 AT ROW 19.5 COL 17 COLON-ALIGNED NO-LABEL
     B-get-base AT ROW 19.5 COL 25
     B-base-rate AT ROW 19.5 COL 34
     contract-rate-1 AT ROW 19.5 COL 59 COLON-ALIGNED
          LABEL "Курс"
     contract-scale-1 AT ROW 19.5 COL 69.5 COLON-ALIGNED NO-LABEL
     B-get-contract AT ROW 19.5 COL 77.5
     B-contract-rate AT ROW 19.5 COL 86.5
     RECT-1 AT ROW 11.5 COL 1
     RECT-2 AT ROW 2.25 COL 1
     "Старые значения" VIEW-AS TEXT
          SIZE 21 BY 1 AT ROW 1 COL 42
          FGCOLOR 3
     SPACE(36.25) SKIP(20.04)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Расчет сумм и курсов платежа"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       B-rubl-sum:POPUP-MENU IN FRAME Dialog-Frame       = MENU MENU-B-rubl-sum:HANDLE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-base-rate IN FRAME Dialog-Frame
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
  RUN proc-calc-base-rate IN this-procedure.
END.
ON CHOOSE OF B-base-sum IN FRAME Dialog-Frame
DO:
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN proc-calc-base-sum IN this-procedure.
END.
ON CHOOSE OF B-contract-rate IN FRAME Dialog-Frame
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
  RUN proc-calc-contract-rate IN this-procedure.
END.
ON CHOOSE OF B-contract-sum IN FRAME Dialog-Frame
DO:
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN proc-calc-contract-sum IN this-procedure.
END.
ON CHOOSE OF B-doc-sum IN FRAME Dialog-Frame
DO:
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN proc-calc-doc-sum IN this-procedure.
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON CHOOSE OF B-get-base IN FRAME Dialog-Frame
DO:
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-old-base-rate-1 like ub.fin-doc.base-rate no-undo .
  define variable v-old-base-scale-1 like ub.fin-doc.base-scale no-undo .
  assign
  v-old-base-rate-1 =  base-rate-1
  v-old-base-scale-1 = base-scale-1
  .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  p-base-code
  ,input  p-doc-date
  ,output base-rate-1
  ,output base-scale-1
  ,output v-base-abbr
  )  .
  display
  base-rate-1
  base-scale-1
  with frame Dialog-Frame.
  if
  v-old-base-rate-1 <> base-rate-1
  or
  v-old-base-scale-1 <> base-scale-1
  then do:
    assign
    v-base-rate-c = "!":U
    .
  end.
END.
ON CHOOSE OF B-get-contract IN FRAME Dialog-Frame
DO:
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-contract-curr-abbr like ub.currency.curr-abbr no-undo .
  define variable v-old-contract-rate-1 like ub.fin-doc.contract-rate no-undo .
  define variable v-old-contract-scale-1 like ub.fin-doc.contract-scale no-undo .
  assign
  v-old-contract-rate-1 =  contract-rate-1
  v-old-contract-scale-1 = contract-scale-1
  .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  p-contract-curr
  ,input  p-doc-date
  ,output contract-rate-1
  ,output contract-scale-1
  ,output v-contract-curr-abbr
  )  .
   display
   contract-rate-1
   contract-scale-1
   with frame Dialog-Frame.
  if
  v-old-contract-rate-1 <> contract-rate-1
  or
  v-old-contract-scale-1 <> contract-scale-1
  then do:
    assign
    v-contract-rate-c = "!":U
    .
  end.
END.
ON CHOOSE OF B-get-rate IN FRAME Dialog-Frame
DO:
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  define variable v-curr-abbr like ub.currency.curr-abbr no-undo .
  define variable v-old-exch-rate-1 like ub.fin-doc.exch-rate no-undo .
  define variable v-old-exch-scale-1 like ub.fin-doc.exch-scale no-undo .
  assign
  v-old-exch-rate-1 =  exch-rate-1
  v-old-exch-scale-1 = exch-scale-1
  .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  p-curr-code
  ,input  p-doc-date
  ,output exch-rate-1
  ,output exch-scale-1
  ,output v-curr-abbr
  )  .
  display
  exch-rate-1
  exch-scale-1
  with frame Dialog-Frame.
  if
  v-old-exch-rate-1 <> exch-rate-1
  or
  v-old-exch-scale-1 <> exch-scale-1
  then do:
    assign
    v-exch-rate-c = "!":U
    .
  end.
END.
ON CHOOSE OF B-rate IN FRAME Dialog-Frame
DO:
  RUN proc-calc-exch-rate IN this-procedure.
END.
ON CHOOSE OF B-rubl-sum IN FRAME Dialog-Frame
DO:
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  IF b-rubl-sum:POPUP-MENU = ? THEN DO:
    RUN proc-calc-rubl-sum IN THIS-PROCEDURE ("doc":U).
  END.
  ELSE DO:
    run gbl/pop-up.p (self:handle, no) no-error.
    IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
  END.
END.
ON LEAVE OF base-rate-1 IN FRAME Dialog-Frame
DO:
   if input frame Dialog-Frame base-rate-1 <> round (base-rate-1, 4) then do:
    assign
    v-base-rate-m = 1
    v-base-rate-c = "!":U
    v-sum-base-c = "!":U
    v-sum-rubl-c = "sum-base/!":U
    frame Dialog-Frame
    base-rate-1
    base-rate-1:tooltip = string(base-rate-1)
    .
  end.
END.
ON LEAVE OF base-scale-1 IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame base-scale-1 <> base-scale-1 then do:
    assign
    v-base-rate-m = 1
    v-base-rate-c = "!":U
    v-sum-base-c = "!":U
    v-sum-rubl-c = "!":U
    frame Dialog-Frame
    base-scale-1
    base-scale-1:tooltip = string(base-scale-1)
    .
  end.
END.
ON CHOOSE OF BUTTON-1 IN FRAME Dialog-Frame
DO:
  MESSAGE
  "Вал платежа" sum-doc-1 SKIP
  "курс валюты платежа" exch-rate-1 SKIP
  "Рубли" sum-rubl-1 SKIP
  "Баз вал" sum-base-1 SKIP
   "Курс вазвал" base-rate-1 SKIP
   "Вал дог-ра" sum-contr-1 SKIP
   "Курс валю дог-ра" contract-rate-1 skip
"v-sum-doc-c"                     v-sum-doc-c        skip
"v-exch-rate-c"                   v-exch-rate-c      skip
"v-sum-rubl-c"                    v-sum-rubl-c       skip
"v-sum-base-c"                    v-sum-base-c        skip
"v-base-rate-c"                   v-base-rate-c       skip
"v-sum-contr-c"                   v-sum-contr-c       skip
"v-contract-rate-c"               v-contract-rate-c    skip
    VIEW-AS ALERT-BOX.
END.
ON LEAVE OF contract-rate-1 IN FRAME Dialog-Frame
DO:
   if input frame Dialog-Frame contract-rate-1 <> round (contract-rate-1, 4) then do:
    assign
    v-contract-rate-m = 1
    v-contract-rate-c = "!":U
    v-sum-contr-c = "!":Uc
    v-sum-rubl-c = "!":U
    frame Dialog-Frame
    contract-rate-1
    contract-rate-1:tooltip = string(contract-rate-1)
    .
  end.
END.
ON LEAVE OF contract-scale-1 IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame contract-scale-1 <> contract-scale-1 then do:
    assign
    v-contract-rate-m = 1
    v-contract-rate-c = "!":U
    v-sum-rubl-c = "!":U
    v-sum-contr-c = "!":U
    frame Dialog-Frame
    contract-scale-1
    contract-scale-1:tooltip = string(contract-scale-1)
    .
  end.
END.
ON LEAVE OF exch-rate-1 IN FRAME Dialog-Frame
DO:
    if input frame Dialog-Frame exch-rate-1 <> round (exch-rate-1, 4) then do:
    assign
    v-exch-rate-m = 1
    v-exch-rate-c = "!":U
    v-sum-rubl-c = "!":U
    v-sum-doc-c = "!":U
    frame Dialog-Frame
    exch-rate-1
    exch-rate-1:tooltip = string(exch-rate-1)
    .
  end.
END.
ON LEAVE OF exch-scale-1 IN FRAME Dialog-Frame
DO:
  if input frame Dialog-Frame exch-scale-1 <> exch-scale-1 then do:
    assign
    v-exch-rate-m = 1
    v-exch-rate-c = "!":U
    v-sum-rubl-c = "!":U
    v-sum-doc-c = "!":U
    frame Dialog-Frame
    exch-scale-1
    exch-scale-1:tooltip = string(exch-scale-1)
    .
  end.
END.
ON CHOOSE OF MENU-ITEM m_base
DO:
  RUN proc-calc-rubl-sum IN THIS-PROCEDURE ("base":U).
END.
ON CHOOSE OF MENU-ITEM m_contr
DO:
  RUN proc-calc-rubl-sum IN THIS-PROCEDURE ("contract":U).
END.
ON CHOOSE OF MENU-ITEM m_doc
DO:
  RUN proc-calc-rubl-sum IN THIS-PROCEDURE ("doc":U).
END.
ON LEAVE OF sum-base-1 IN FRAME Dialog-Frame
DO:
   if input frame Dialog-Frame sum-base-1 <> round (sum-base-1, 2) then do:
    assign
     v-sum-base-m = 1
     v-sum-base-c = "!":U
     v-sum-rubl-c = "!":U
     v-base-rate-c = "!":U
     frame Dialog-Frame
     sum-base-1
     sum-base-1:tooltip = string(sum-base-1)
     .
  end.
END.
ON LEAVE OF sum-contr-1 IN FRAME Dialog-Frame
DO:
   if input frame Dialog-Frame sum-contr-1 <> round (sum-contr-1, 2) then do:
    assign
    v-sum-contr-m = 1
    v-sum-contr-c = "!":U
    v-sum-rubl-c = "!":U
    v-contract-rate-c = "!":U
    frame Dialog-Frame
    sum-contr-1
    sum-contr-1:tooltip = string(sum-contr-1)
    .
  end.
END.
ON LEAVE OF sum-doc-1 IN FRAME Dialog-Frame
DO:
   if input frame Dialog-Frame sum-doc-1 <> round (sum-doc-1, 2) then do:
    assign
    v-sum-doc-m = 1
    v-sum-doc-c = "!":U
    v-sum-rubl-c = "!":U
    v-exch-rate-c = "!":U
    frame Dialog-Frame
    sum-doc-1
    sum-doc-1:tooltip = string(sum-doc-1)
    .
  end.
  RUN proc-not-enable-rubl IN THIS-PROCEDURE.
  RUN proc-not-enable-base IN THIS-PROCEDURE.
  RUN proc-not-enable-contr IN THIS-PROCEDURE.
END.
ON LEAVE OF sum-rubl-1 IN FRAME Dialog-Frame
DO:
   if input frame Dialog-Frame sum-rubl-1 <> round (sum-rubl-1, 2) then do:
    assign
    v-sum-rubl-m = 1
    v-sum-rubl-c = "!":U
    v-sum-base-c = "!":U
    v-sum-doc-c = "!":U
    v-sum-contr-c = "!":U
    v-exch-rate-c = "!":U
    v-base-rate-c = "!":U
    v-contract-rate-c = "!":U
    frame Dialog-Frame
    sum-rubl-1
    sum-rubl-1:tooltip = string(sum-rubl-1)
    .
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  if self:type = "TOGGLE-BOX" then
  self:BGCOLOR = ?.
  assign
  ii = lookup(self:name, v-tab-order).
  assign
  ii = ii + 1
  v-next-widget-name = entry(ii, v-tab-order)
  no-error .
  if error-status:error then do:
    assign
    ii = 1
    v-next-widget-name = entry( ii, v-tab-order)
    .
  end.
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
        APPLY "TAB" to hh.
        return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
end.
END.
ON BACK-TAB ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
if v-tab-order <> '' then do:
  assign
  ii = lookup(self:name, v-tab-order).
  .
  assign
  ii = (if ii = 1
        then  num-entries(v-tab-order)
        else ii - 1
        )
  v-next-widget-name = entry(ii, v-tab-order)
  .
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = v-next-widget-name then do:
      if hh:sensitive  = yes
      AND hh:visible = yes then do:
        if hh:type = "TOGGLE-BOX":U then do:
          assign
          hh:BGcolor = 1
          .
        end.
        APPLY "ENTRY" to hh.
        return no-apply.
      end.
      else do:
      APPLY "BACK-TAB" to hh.
      return no-apply.
      end.
    end.
    hh = hh:next-sibling.
  end.
  end.
END.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ON RETURN ANYWHERE
DO:
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
  if v-tab-order <> '' then do:
    assign
    ii = lookup(self:name, v-tab-order).
    if ii = num-entries(v-tab-order) then do:
        APPLY 'CHOOSE' TO b-exit in frame Dialog-Frame.
        return no-apply.
    end.
    if self:type <> "BUTTON" and
      self:type <> "EDITOR"  then do:
      run proc-move-forward in this-procedure .
      return no-apply.
    end.
    if self:type = "BUTTON" then do:
      APPLY "CHOOSE" to self.
    end.
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return no-apply.
        end.
        else do:
          APPLY "TAB" to hh.
          return no-apply.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
END.
procedure proc-move-forward :
define variable ii as integer no-undo .
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable v-next-widget-name as character no-undo .
do
on error undo, return error
:
  if v-tab-order <> '' then do:
    if self:type = "TOGGLE-BOX" then
    self:BGCOLOR = ?.
    assign
    ii = lookup(self:name, v-tab-order).
    assign
    ii = ii + 1
    v-next-widget-name = entry(ii, v-tab-order)
    no-error .
    if error-status:error then do:
      assign
      ii = 1
      v-next-widget-name = entry( ii, v-tab-order)
      .
    end.
    assign
    fh = frame Dialog-Frame:first-child
    hh = fh:first-child
    .
    do while valid-handle(hh):
      if hh:name = v-next-widget-name then do:
        if hh:sensitive  = yes
        AND hh:visible = yes then do:
          if hh:type = "TOGGLE-BOX":U then do:
            assign
            hh:BGcolor = 1
            .
          end.
          APPLY "ENTRY" to hh.
          return.
        end.
        else do:
          assign
          ii = ii + 1
          v-next-widget-name = entry(ii, v-tab-order)
          no-error .
          if error-status:error then do:
            assign
            ii = 1
            v-next-widget-name = entry( ii, v-tab-order)
            .
          end.
        end.
      end.
      hh = hh:next-sibling.
    end.
  end.
end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  FIND FIRST buf_currency NO-LOCK WHERE
            buf_Currency.curr-code = p-curr-code  NO-ERROR.
  IF NOT AVAILABLE buf_currency THEN DO:
      MESSAGE
    "Неверное значение параметра p-curr-code:" p-curr-code
    vss-workfile vss-revision vss-description skip
    view-as alert-box .
  END.
  FIND FIRST buf_base-currency NO-LOCK WHERE
            buf_base-currency.curr-code = p-base-code NO-ERROR.
  IF NOT available buf_base-currency THEN DO:
      MESSAGE
    "Неверное значение параметра p-base-code:" p-base-code
    vss-workfile vss-revision vss-description skip
    view-as alert-box .
    RETURN ERROR.
  END.
  FIND FIRST buf_contract-currency NO-LOCK WHERE
            buf_contract-currency.curr-code = p-contract-curr NO-ERROR.
  IF NOT AVAILABLE buf_contract-currency THEN DO:
      MESSAGE
        "Неверное значение параметра p-contract-curr:" p-contract-curr
        vss-workfile vss-revision vss-description skip
        view-as alert-box .
    RETURN ERROR.
  END.
  RUN Myenable.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY doc-date-0 curr-code-0 F-curr-abbr-0 sum-doc-0 exch-rate-0
          exch-scale-0 sum-rubl-0 base-code-0 F-base-abbr-0 contract-curr-code-0
          F-contract-curr-abbr-0 sum-base-0 sum-contr-0 base-rate-0 base-scale-0
          contract-rate-0 contract-scale-0 curr-code-1 F-curr-abbr-1 sum-doc-1
          exch-rate-1 exch-scale-1 sum-rubl-1 base-code-1 F-base-abbr-1
          contract-curr-code-1 F-contract-curr-abbr-1 sum-base-1 sum-contr-1
          base-rate-1 base-scale-1 contract-rate-1 contract-scale-1
      WITH FRAME Dialog-Frame.
  ENABLE B-exit b-quit B-Help BUTTON-1 sum-doc-1 B-doc-sum exch-rate-1
         exch-scale-1 B-get-rate B-rate sum-rubl-1 B-rubl-sum sum-base-1
         B-base-sum sum-contr-1 B-contract-sum base-rate-1 base-scale-1
         B-get-base B-base-rate contract-rate-1 contract-scale-1 B-get-contract
         B-contract-rate RECT-1 RECT-2
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
assign
b-rubl-sum:MENU-MOUSE IN FRAME Dialog-Frame = 1
curr-code-0  = p-curr-code
F-curr-abbr-0 = buf_currency.curr-abbr
curr-code-1  = p-curr-code
F-curr-abbr-1  =  buf_currency.curr-abbr
doc-date-0   =  p-doc-date
sum-doc-0  =  p-sum-doc
exch-rate-0  = p-exch-rate
exch-scale-0  =  p-exch-scale
sum-rubl-0 = p-sum-rubl
base-code-0  = p-base-code
F-base-abbr-0 =  buf_base-currency.curr-abbr
contract-curr-code-0 = p-contract-curr
F-contract-curr-abbr-0  = buf_contract-currency.curr-abbr
sum-base-0  = p-sum-base
sum-contr-0  = p-sum-contr
base-rate-0  = p-base-rate
base-scale-0 = p-base-scale
contract-rate-0  = p-contract-rate
contract-scale-0  = p-contract-scale
sum-doc-1 = p-sum-doc
exch-rate-1  = p-exch-rate
exch-scale-1  = p-exch-scale
sum-rubl-1 = p-sum-rubl
base-code-1  = p-base-code
F-base-abbr-1 = buf_base-currency.curr-abbr
contract-curr-code-1  = p-contract-curr
F-contract-curr-abbr-1 = buf_contract-currency.curr-abbr
sum-base-1 = p-sum-base
sum-contr-1 = p-sum-contr
base-rate-1  = p-base-rate
base-scale-1  = p-base-scale
contract-rate-1 = p-contract-rate
contract-scale-1 = p-contract-scale
sum-doc-1:tooltip                         =    string(p-sum-doc)
exch-rate-1:tooltip                       =    string(p-exch-rate)
exch-scale-1:tooltip                      =    string(p-exch-scale)
sum-rubl-1:tooltip                        =    string(p-sum-rubl)
base-code-1:tooltip                       =    string(p-base-code)
F-base-abbr-1:tooltip                     =    string(buf_base-currency.curr-abbr)
contract-curr-code-1:tooltip              =    string(p-contract-curr)
F-contract-curr-abbr-1:tooltip            =    string(buf_contract-currency.curr-abbr)
sum-base-1:tooltip                        =    string(p-sum-base)
sum-contr-1:tooltip                       =    string(p-sum-contr)
base-rate-1:tooltip                       =    string(p-base-rate)
base-scale-1:tooltip                      =    string(p-base-scale)
contract-rate-1:tooltip                   =    string(p-contract-rate)
contract-scale-1:tooltip                  =    string(p-contract-scale)
sum-rubl-0 :label                         =    "Рубли"
sum-rubl-1 :label                         =    "Рубли"
.
if p-curr-code <> 0
then do:
  assign
  v-rubf = yes
  v-exchf = yes
  .
end.
if
p-base-code <> 0
then do:
  assign
  v-basef = yes
  v-baseratef = yes
  v-rubf = yes
  v-exchf = yes
  .
end.
if
  (p-contract-curr <> 0
    )
  then do:
  assign
  v-contractf = yes
  v-contractratef = yes
  v-rubf = yes
  v-exchf = yes
  .
end.
ASSIGN
MENU-ITEM m_base:SENSITIVE IN MENU menu-b-rubl-sum = v-basef OR v-baseratef
MENU-ITEM m_contr:SENSITIVE IN MENU menu-b-rubl-sum = v-contractf OR v-contractratef
.
IF NOT (MENU-ITEM m_base:SENSITIVE IN MENU menu-b-rubl-sum OR MENU-ITEM m_contr:SENSITIVE IN MENU menu-b-rubl-sum)
THEN
b-rubl-sum:POPUP-MENU = ?
.
ASSIGN
v-tab-order = "sum-doc-1,B-doc-sum," +
              (IF v-exchf THEN "exch-rate-1,exch-scale-1,B-get-rate,B-rate,":U ELSE "":U) +
              (IF v-rubf THEN "sum-rubl-1,b-rubl-sum,":U ELSE "":U) +
              (IF v-basef THEN "sum-base-1,b-base-sum,":U ELSE "":U) +
              (IF v-basef THEN "base-rate-1,base-scale-1,B-get-base,B-base-rate,":U ELSE "":U) +
              (IF v-contractf THEN "sum-contr-1,b-contract-sum,":U ELSE "":U) +
              (IF v-contractratef THEN "contract-rate-1,contract-scale-1,b-get-contract,b-contract-rate,":U ELSE "":U) +
              "b-exit,b-quit,b-help":U
              .
 DISPLAY doc-date-0 curr-code-0 F-curr-abbr-0 sum-doc-0 exch-rate-0
          exch-scale-0 sum-rubl-0 base-code-0 F-base-abbr-0 contract-curr-code-0
          F-contract-curr-abbr-0 sum-base-0 sum-contr-0 base-rate-0 base-scale-0
          contract-rate-0 contract-scale-0 curr-code-1 F-curr-abbr-1 sum-doc-1
          exch-rate-1 exch-scale-1 sum-rubl-1 base-code-1 F-base-abbr-1
          contract-curr-code-1 F-contract-curr-abbr-1 sum-base-1 sum-contr-1
          base-rate-1 base-scale-1 contract-rate-1 contract-scale-1
      WITH FRAME Dialog-Frame .
ENABLE
B-exit b-quit B-Help
sum-doc-1 B-doc-sum
exch-rate-1 WHEN v-exchf
exch-scale-1 WHEN v-exchf
B-get-rate WHEN v-exchf
B-rate WHEN v-exchf
sum-rubl-1  WHEN v-rubf
B-rubl-sum WHEN v-rubf
sum-base-1 WHEN v-basef
base-rate-1 WHEN v-baseratef
base-scale-1 WHEN v-baseratef
B-base-sum WHEN v-basef
B-get-base  WHEN v-baseratef
B-base-rate WHEN v-baseratef
sum-contr-1 WHEN v-contractf
B-contract-sum WHEN v-contractf
contract-rate-1 WHEN v-contractratef = yes
contract-scale-1 WHEN v-contractratef = yes
B-get-contract WHEN v-contractratef = yes
B-contract-rate WHEN v-contractratef = yes
RECT-1 RECT-2
button-1
WITH FRAME Dialog-Frame .
VIEW FRAME Dialog-Frame .
hide
button-1 in frame Dialog-Frame .
APPLY "ENTRY" TO sum-doc-1 IN FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-calc-base-rate :
ASSIGN
v-base-rate-c = "sum-rubl/sum-base":U
v-sum-base-c = "":U
v-sum-rubl-c = "":U
base-scale-1 = 1
base-rate-1 = sum-rubl-1 / sum-base-1
base-rate-1:tooltip in frame Dialog-Frame  = string(base-rate-1)
v-sum-base-m = 0
.
DISPLAY
base-rate-1
base-scale-1
WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-calc-base-sum :
ASSIGN
v-sum-base-c = "sum-rubl/base-rate":U
v-base-rate-c = "":U
v-sum-rubl-c = "":U
sum-base-1 = sum-rubl-1 / ( base-rate-1 / base-scale-1 )
sum-base-1:tooltip in frame Dialog-Frame = string(sum-base-1)
v-base-rate-m = 0
.
DISPLAY
SUM-base-1
WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-calc-contract-rate :
ASSIGN
v-contract-rate-c = "sum-rubl/sum-contr":U
v-sum-rubl-c = "":U
v-sum-contr-c = "":U
contract-scale-1 = 1
contract-rate-1 = sum-rubl-1 / sum-contr-1
contract-rate-1:tooltip  in frame Dialog-Frame = string(contract-rate-1)
v-sum-contr-m = 0
.
DISPLAY
contract-rate-1
contract-scale-1
WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-calc-contract-sum :
ASSIGN
v-sum-contr-c = "sum-rubl/contract-rate":U
v-sum-rubl-c = "":U
v-contract-rate-c = "":U
sum-contr-1 = sum-rubl-1 / ( contract-rate-1 / contract-scale-1 )
sum-contr-1:tooltip in frame Dialog-Frame  = string(sum-contr-1)
v-contract-rate-m = 0
.
DISPLAY
SUM-contr-1
WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-calc-doc-sum :
ASSIGN
v-sum-doc-c = "sum-rubl/exch-rate":U
v-sum-rubl-c = "":U
v-exch-rate-c = "":U
sum-doc-1 = sum-rubl-1 / ( exch-rate-1 / exch-scale-1 )
sum-doc-1:tooltip in frame Dialog-Frame  = string(sum-doc-1)
v-exch-rate-m = 0
.
DISPLAY
SUM-doc-1
WITH FRAME Dialog-Frame.
RUN proc-not-enable-base IN THIS-PROCEDURE.
RUN proc-not-enable-contr IN THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE proc-calc-exch-rate :
ASSIGN
v-exch-rate-c = "sum-rubl/sum-doc":U
v-sum-rubl-c = "":U
v-sum-doc-c = "":U
exch-scale-1 = 1
exch-rate-1 = sum-rubl-1 / sum-doc-1
exch-rate-1:tooltip in frame Dialog-Frame  = string(exch-rate-1)
v-sum-doc-m = 0
.
DISPLAY
exch-rate-1
exch-scale-1
WITH FRAME Dialog-Frame.
RUN proc-not-enable-base IN THIS-PROCEDURE.
RUN proc-not-enable-contr IN THIS-PROCEDURE.
END PROCEDURE.
PROCEDURE proc-calc-rubl-sum :
DEFINE INPUT PARAMETER p-calc-option AS CHARACTER NO-UNDO.
if round(base-rate-1           , 4) <> input frame Dialog-Frame base-rate-1             then apply "leave" to base-rate-1            in frame Dialog-Frame. if       base-scale-1               <> input frame Dialog-Frame base-scale-1            then apply "leave" to base-scale-1           in frame Dialog-Frame. if round(sum-base-1          , 3) <> input frame Dialog-Frame sum-base-1            then apply "leave" to sum-base-1           in frame Dialog-Frame. if round(sum-rubl-1          , 3) <> input frame Dialog-Frame sum-rubl-1            then apply "leave" to sum-rubl-1           in frame Dialog-Frame. if round(exch-rate-1           , 4) <> input frame Dialog-Frame exch-rate-1             then apply "leave" to exch-rate-1            in frame Dialog-Frame. if       exch-scale-1               <> input frame Dialog-Frame exch-scale-1            then apply "leave" to exch-scale-1           in frame Dialog-Frame. if round(sum-doc-1          , 3) <> input frame Dialog-Frame sum-doc-1            then apply "leave" to sum-doc-1           in frame Dialog-Frame. if round(contract-rate-1           , 4) <> input frame Dialog-Frame contract-rate-1             then apply "leave" to contract-rate-1            in frame Dialog-Frame. if       contract-scale-1               <> input frame Dialog-Frame contract-scale-1            then apply "leave" to contract-scale-1           in frame Dialog-Frame. if round(sum-contr-1          , 3) <> input frame Dialog-Frame sum-contr-1            then apply "leave" to sum-contr-1           in frame Dialog-Frame.
CASE p-calc-option:
  WHEN "doc":U  THEN DO:
    ASSIGN
    v-sum-rubl-c = "sum-doc*exch-rate":U
    v-exch-rate-c = "":U
    v-sum-doc-c = "":U
    v-base-rate-c = "!":U
    v-sum-base-c = "!":U
    v-contract-rate-c = "!":U
    v-sum-contr-c = "!":U
    sum-rubl-1 = sum-doc-1 * ( exch-rate-1 / exch-scale-1 )
    v-exch-rate-m = 0
    v-sum-doc-m = 0
    .
    RUN proc-not-enable-base IN THIS-PROCEDURE.
    RUN proc-not-enable-contr IN THIS-PROCEDURE.
  END.
  WHEN "base":U  THEN DO:
    ASSIGN
    v-sum-rubl-c = "sum-base*base-rate":U
    v-base-rate-c = "":U
    v-sum-base-c = "":U
    v-exch-rate-c = "!":U
    v-sum-doc-c = "!":U
    v-contract-rate-c = "!":U
    v-sum-contr-c = "!":U
    sum-rubl-1 = sum-base-1 * ( base-rate-1 / base-scale-1 )
    v-base-rate-m = 0
    v-sum-base-m = 0
    .
     RUN proc-not-enable-contr IN THIS-PROCEDURE.
  END.
  WHEN "contract":U THEN DO:
      ASSIGN
      v-sum-rubl-c = "sum-contr*contract-rate":U
      v-contract-rate-c = "":U
      v-sum-contr-c = "":U
      v-base-rate-c = "!":U
      v-sum-base-c = "!":U
      v-exch-rate-c = "!":U
      v-sum-doc-c = "!":U
      sum-rubl-1 = sum-contr-1 * ( contract-rate-1 / contract-scale-1 )
      v-contract-rate-m = 0
      v-sum-contr-m = 0
      .
      RUN proc-not-enable-base IN THIS-PROCEDURE.
  END.
END CASE.
assign
sum-rubl-1:tooltip  in frame Dialog-Frame = string(sum-rubl-1)
.
DISPLAY
sum-rubl-1
WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-not-enable-base :
    IF NOT v-basef OR NOT v-baseratef THEN  DO:
        IF p-base-code = 0 THEN DO:
            ASSIGN
            sum-base-1 = SUM-rubl-1
            base-rate-1 = 1
            base-scale-1 = 1
            .
        END.
        ELSE IF p-base-code = p-curr-code THEN DO:
            ASSIGN
            sum-base-1 = sum-doc-1
            base-rate-1 = exch-rate-1
            base-scale-1 = exch-scale-1
            .
        END.
    END.
assign
sum-base-1:tooltip in frame Dialog-Frame = string(sum-base-1)
base-rate-1:tooltip in frame Dialog-Frame  = string(base-rate-1)
base-scale-1:tooltip in frame Dialog-Frame  = string(base-scale-1)
.
DISPLAY
sum-base-1
base-rate-1
base-scale-1
WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-not-enable-contr :
IF NOT v-contractf OR NOT v-contractratef THEN DO:
       IF p-contract-curr = 0  THEN DO:
            ASSIGN
            sum-contr-1 = SUM-rubl-1
            contract-rate-1 = 1
            contract-scale-1 = 1
            .
       END.
       ELSE DO:
           IF p-contract-curr = p-curr-code THEN DO:
                ASSIGN
                sum-contr-1 = SUM-doc-1
                contract-rate-1 = exch-rate-1
                contract-scale-1 = exch-scale-1
                .
           END.
           IF p-contract-curr = p-base-code THEN DO:
                 ASSIGN
                 sum-contr-1 = SUM-base-1
                 contract-rate-1 = base-rate-1
                 contract-scale-1 = base-scale-1
                 .
            END.
       END.
    END.
assign
sum-contr-1:tooltip in frame Dialog-Frame  = string(sum-contr-1)
contract-rate-1:tooltip in frame Dialog-Frame  = string(contract-rate-1)
contract-scale-1:tooltip in frame Dialog-Frame  = string(contract-scale-1)
.
DISPLAY
sum-contr-1
contract-rate-1
contract-scale-1
WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-not-enable-rubl :
  IF NOT v-rubf OR NOT v-exchf THEN DO:
      ASSIGN
      exch-rate-1 = 1
      exch-scale-1 = 1
      sum-rubl-1 = sum-doc-1
      .
  END.
  assign
  sum-rubl-1:tooltip in frame Dialog-Frame  = string(sum-rubl-1)
  exch-rate-1:tooltip in frame Dialog-Frame  = string(exch-rate-1)
  exch-scale-1:tooltip in frame Dialog-Frame  = string(exch-scale-1)
  .
  DISPLAY
  exch-rate-1
  exch-scale-1
  sum-rubl-1
  WITH FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save :
DEFINE VARIABLE v-rate-correct AS CHARACTER NO-UNDO.
if round(base-rate-1           , 4) <> input frame Dialog-Frame base-rate-1             then apply "leave" to base-rate-1            in frame Dialog-Frame. if       base-scale-1               <> input frame Dialog-Frame base-scale-1            then apply "leave" to base-scale-1           in frame Dialog-Frame. if round(sum-base-1          , 3) <> input frame Dialog-Frame sum-base-1            then apply "leave" to sum-base-1           in frame Dialog-Frame. if round(sum-rubl-1          , 3) <> input frame Dialog-Frame sum-rubl-1            then apply "leave" to sum-rubl-1           in frame Dialog-Frame. if round(exch-rate-1           , 4) <> input frame Dialog-Frame exch-rate-1             then apply "leave" to exch-rate-1            in frame Dialog-Frame. if       exch-scale-1               <> input frame Dialog-Frame exch-scale-1            then apply "leave" to exch-scale-1           in frame Dialog-Frame. if round(sum-doc-1          , 3) <> input frame Dialog-Frame sum-doc-1            then apply "leave" to sum-doc-1           in frame Dialog-Frame. if round(contract-rate-1           , 4) <> input frame Dialog-Frame contract-rate-1             then apply "leave" to contract-rate-1            in frame Dialog-Frame. if       contract-scale-1               <> input frame Dialog-Frame contract-scale-1            then apply "leave" to contract-scale-1           in frame Dialog-Frame. if round(sum-contr-1          , 3) <> input frame Dialog-Frame sum-contr-1            then apply "leave" to sum-contr-1           in frame Dialog-Frame.
RUN rate-correct IN THIS-PROCEDURE (OUTPUT v-rate-correct) NO-ERROR.
if error-status:error then do:
  message "Ошибка при вызове процедуры rate-correct." skip
          return-value
          error-status:get-message(1)
          error-status:get-message(2)
  view-as alert-box error.
  return no-apply.
end.
CASE v-rate-correct:
    WHEN "sum-doc":U then do:
      message
      "Неверная сумма платежа или сумма платежа не согласована с другими суммами"
      view-as alert-box .
       apply "entry" to sum-doc-1.
       return error .
    end.
    WHEN "sum-rubl":U then do:
      message
      "Неверная сумма в рублях или сумма в рублях не согласована с другими суммами"
      view-as alert-box .
       apply "entry" to sum-rubl-1.
       return error .
    end.
    when "sum-base":U then do:
      message
      "Неверная сумма в баз вал или сумма в баз. вал. не согласована с суммой в рублях и курсом баз.вал."
      view-as alert-box .
       apply "entry" to sum-base-1.
       return error .
    end.
    when "sum-contr":U then do:
      message
      "Неверная сумма в вал дог-ра или сумма в вал. дог-ра не согласована с суммой в рублях и курсом вал.дог-ра"
      view-as alert-box .
       apply "entry" to sum-contr-1.
       return error .
    end.
    WHEN "exch-rate" THEN DO:
        message
          "Курс валюты платежа не согласован с суммой платежа и суммой в национальной валюте" skip
          "Сумма в валюте платежа: " sum-doc-1 skip
          "Сумма в рублях: " sum-rubl-1 skip
          "Курс валюты платежа: " exch-rate-1 skip
          "Шкала валюты платежа: " exch-scale-1
        view-as alert-box information.
      if b-rate:sensitive IN FRAME Dialog-Frame then do:
        apply "entry" to b-rate.
      end.
      else do:
        apply "entry" to sum-doc-1.
      end.
        return ERROR.
    END.
    WHEN "base-rate":U THEN DO:
           message
          "Курс базовой валюты не согласован с суммой в базовой валюте и суммой в национальной валюте" skip
          "Сумма в базовой валюте: " sum-base-1 skip
          "Сумма в рублях: " sum-rubl-1 skip
          "Курс базовой валюты: " base-rate-1 skip
          "Шкала базовой валюты: " base-scale-1
  view-as alert-box information.
      if b-base-rate:sensitive then do:
        apply "entry" to b-base-rate.
      end.
      else do:
        apply "entry" to sum-doc-1.
      end.
        RETURN error.
    END.
    WHEN "contract-rate":U THEN DO:
        message
          "Курс валюты договора не согласован с суммой платежа и суммой в национальной валюте" skip
          "Сумма в валюте договора: " sum-contr-1 skip
          "Сумма в рублях: " sum-rubl-1 skip
          "Курс валюты договора: " contract-rate-1 skip
          "Шкала валюты договора: " contract-scale-1
  view-as alert-box information.
      if b-contract-rate:sensitive then do:
        apply "entry" to b-contract-rate.
      end.
      else do:
        apply "entry" to sum-contr-1.
      end.
        return error.
  END.
END CASE.
ASSIGN
p-sum-rubl = sum-rubl-1
p-sum-doc = sum-doc-1
p-exch-rate = exch-rate-1
p-exch-scale = exch-scale-1
p-sum-base = sum-base-1
p-base-rate = base-rate-1
p-base-scale = base-scale-1
p-sum-contr = sum-contr-1
p-contract-rate = contract-rate-1
p-contract-scale = contract-scale-1
.
END PROCEDURE.
PROCEDURE rate-correct :
DEFINE OUTPUT PARAMETER p-rate-correct AS CHARACTER NO-UNDO.
if sum-doc-0 = sum-doc-1
AND sum-rubl-0 = sum-rubl-1
and exch-rate-0 = exch-rate-1
and exch-scale-0 = exch-scale-1
AND sum-base-0 = sum-base-1
and base-rate-0 = base-rate-1
and base-scale-0 = base-scale-1
AND sum-contr-0 = sum-contr-1
and contract-rate-0 = contract-rate-1
and contract-scale-0 = contract-scale-1 then do:
  p-rate-correct = "":U.
  return .
end.
if (sum-doc-1 = 0
and not (sum-rubl-1 = 0 and sum-base-1 = 0 and sum-contr-1 = 0))
or sum-doc-1 < 0
or sum-doc-1 = ?
then do:
  p-rate-correct = "sum-doc":U.
  return.
end.
if sum-rubl-1 = ?
or sum-rubl-1 < 0
or ( sum-doc-1 <> 0  and sum-rubl-1 = 0)
then do:
   p-rate-correct = "sum-rubl":U.
   return.
end.
if sum-base-1 < 0
or ( sum-doc-1 <> 0  and sum-base-1 = 0)
or sum-base-1 = ?
then do:
   p-rate-correct = "sum-base":U.
   return.
end.
if sum-contr-1 < 0
or ( sum-doc-1 <> 0  and sum-contr-1 = 0)
or sum-contr-1 = ?
then do:
   p-rate-correct = "sum-contr":U.
   return.
end.
IF EXCH-RATE-1 = ? or exch-scale-1 = ?
or EXCH-RATE-1 = 0 or exch-scale-1 = 0
then do:
    p-rate-correct = "exch-rate":U.
    RETURN.
END.
IF v-exch-rate-c <> "":U AND v-exch-rate-c <> "0":U
AND abs((exch-rate-1 / exch-scale-1) - (sum-rubl-1 / sum-doc-1)) >  0.0001 THEN DO:
    p-rate-correct = "exch-rate":U.
    RETURN.
END.
IF v-sum-doc-c <> "":U AND v-sum-doc-c <> "0":U
AND abs(sum-doc-1 - (sum-rubl-1 / ( exch-rate-1 / exch-scale-1 ))) >  0.01 THEN DO:
    p-rate-correct = "sum-doc":U.
    RETURN.
END.
IF base-rate-1 = ? or  base-scale-1 = ?
or base-rate-1 = 0 or  base-scale-1 = 0
then do:
  p-rate-correct = "base-rate":U.
  RETURN.
end.
IF  v-baseratef
and v-base-rate-c <> "":U AND v-base-rate-c <> "0":U
AND abs((base-rate-1 / base-scale-1) - (sum-rubl-1 / sum-base-1)) > 0.0001 THEN DO:
    p-rate-correct = "base-rate":U.
    RETURN.
END.
IF v-basef
and v-sum-base-c <> "":U AND v-sum-base-c <> "0":U
AND abs(sum-base-1 - (sum-rubl-1 / ( base-rate-1 / base-scale-1 ))) >  0.0001 THEN DO:
  p-rate-correct = "sum-base":U.
  RETURN.
END.
IF contract-rate-1 = ? or  contract-scale-1 = ?
or contract-rate-1 = 0 or  contract-scale-1 = 0
then do:
    p-rate-correct = "contract-rate":U.
    RETURN.
end.
IF v-contractratef
and v-contract-rate-c <> "":U AND v-contract-rate-c <> "0":U
AND abs((contract-rate-1 / contract-scale-1) - (sum-rubl-1 / sum-contr-1)) > 0.0001 THEN DO:
    p-rate-correct = "contract-rate":U.
    RETURN.
END.
IF v-contractf
and v-sum-contr-c <> "":U AND v-sum-contr-c <> "0":U
AND abs(sum-contr-1 - (sum-rubl-1 / ( contract-rate-1 / contract-scale-1 ))) >  0.0001 THEN DO:
  p-rate-correct = "sum-contract":U.
  RETURN.
END.
if v-rubf then do:
CASE v-sum-rubl-c:
  when "sum-doc*exch-rate":U then do:
    if ABS(sum-rubl-1 - sum-doc-1 * (exch-rate-1 / exch-scale-1)) > 0.0001 then do:
      p-rate-correct = "sum-rubl":U.
      RETURN.
    end.
  end.
  when "sum-contr*contract-rate":U then do:
    if ABS(sum-rubl-1 - sum-contr-1 * (contract-rate-1 /  contract-scale-1)) > 0.0001 then do:
      p-rate-correct = "sum-rubl":U.
      RETURN.
    end.
  end.
  when "sum-base*base-rate":U then do:
    if ABS(sum-rubl-1 - sum-base-1 * (base-rate-1 /  base-scale-1)) > 0.0001 then do:
      p-rate-correct = "sum-rubl":U.
      RETURN.
    end.
  end.
  when "":U then do:
  end.
  when "!":U then do:
    p-rate-correct = "sum-rubl":U.
    RETURN.
  end.
END CASE.
end.
END PROCEDURE.
