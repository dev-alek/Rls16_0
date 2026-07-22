DEFINE BUFFER locked_sysconf FOR ub.sysconf.
DEFINE TEMP-TABLE tt-sysconf NO-UNDO LIKE ub.sysconf.
define input  parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
define input  parameter p-mode      as character no-undo .
define input  parameter p-host-code    as integer   no-undo .
define input  parameter is-fin   as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Настройки записей финблока по умолчанию" .
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable p-code-an-uchet as integer   no-undo .
define variable p-code-cel-nazn as integer   no-undo .
define variable p-code-cor-acc  as integer   no-undo .
define variable p-code-cor-acc-2  as integer   no-undo .
define variable a-code-an-uchet as integer extent 6  no-undo .
define variable a-code-cel-nazn as integer extent 6  no-undo .
define variable a-code-cor-acc  as integer extent 6  no-undo .
define variable a-code-cor-acc-2  as integer extent 6  no-undo .
define variable p-bank          as integer   no-undo .
define variable p-schet         as integer   no-undo .
define variable p-bank1         as integer   no-undo .
define variable p-schet1        as integer   no-undo .
DEFINE BUTTON b-an-uchet
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 3.3 BY 1.13.
DEFINE BUTTON b-bank-rub
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 3.3 BY 1.
DEFINE BUTTON b-cel-nazn
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 3.3 BY 1.13.
DEFINE BUTTON b-cor-acc
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 3.3 BY 1.13.
DEFINE BUTTON b-cor-acc-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "2"
     SIZE 3.3 BY 1.13.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE COMBO-auto-pay AS CHARACTER FORMAT "X(256)":U
     LABEL "стат."
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 16.3 BY 1 NO-UNDO.
DEFINE VARIABLE COMBO-auto-pay-2 AS CHARACTER FORMAT "X(256)":U
     LABEL "стат."
     VIEW-AS COMBO-BOX INNER-LINES 5
     DROP-DOWN-LIST
     SIZE 16.3 BY 1 NO-UNDO.
DEFINE VARIABLE COMBO-fin-firm AS CHARACTER FORMAT "X(256)":U
     VIEW-AS COMBO-BOX INNER-LINES 10
     LIST-ITEMS "Item 1"
     DROP-DOWN-LIST
     SIZE 31.8 BY 1 NO-UNDO.
DEFINE VARIABLE an-uchet-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Код аналитического учета"
      VIEW-AS TEXT
     SIZE 38 BY .93 NO-UNDO.
DEFINE VARIABLE bank-bik AS CHARACTER FORMAT "X(256)":U
     LABEL "БИК"
      VIEW-AS TEXT
     SIZE 26.9 BY .93 NO-UNDO.
DEFINE VARIABLE bank-rub AS CHARACTER FORMAT "X(256)":U
     LABEL "Банк"
      VIEW-AS TEXT
     SIZE 60.5 BY .93 NO-UNDO.
DEFINE VARIABLE bank-schet AS CHARACTER FORMAT "X(256)":U
     LABEL "Р/С"
      VIEW-AS TEXT
     SIZE 35.5 BY .93 NO-UNDO.
DEFINE VARIABLE cel-nazn-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Код целевого назначения"
      VIEW-AS TEXT
     SIZE 38 BY .93 NO-UNDO.
DEFINE VARIABLE cor-acc-2-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Корресп. счет (касса)"
      VIEW-AS TEXT
     SIZE 38 BY .93 NO-UNDO.
DEFINE VARIABLE cor-acc-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Корреспондирующий счет"
      VIEW-AS TEXT
     SIZE 38 BY .93 NO-UNDO.
DEFINE VARIABLE RADIO-SET-1 AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "РПП", 1,
"ППП", 2,
"РКО", 3,
"ПКО", 4,
"Рс.АПЗ", 5,
"Пр.АПЗ", 6
     SIZE 12 BY 4.2 NO-UNDO.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 93.5 BY 11.47.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 68 BY 5.07.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 29.9 BY 9.1.
DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 60 BY 1.37.
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 67.5 BY 1.37.
DEFINE VARIABLE Is-fin-copy AS LOGICAL INITIAL no
     LABEL "Копировать настройки из фирмы:"
     VIEW-AS TOGGLE-BOX
     SIZE 33.8 BY .83 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-sysconf SCROLLING.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 95
     tt-sysconf.contract-type AT ROW 2 COL 6 COLON-ALIGNED
          LABEL "Тип" FORMAT "X(256)"
          VIEW-AS COMBO-BOX INNER-LINES 6
          DROP-DOWN-LIST
          SIZE 22.8 BY 1
     tt-sysconf.contract-city AT ROW 2 COL 36.6 COLON-ALIGNED
          LABEL "Город"
          VIEW-AS FILL-IN
          SIZE 44.4 BY 1
     tt-sysconf.usl-opl AT ROW 3 COL 18.1 COLON-ALIGNED
          LABEL "Услов.генер. ФО" FORMAT "X(256)"
          VIEW-AS COMBO-BOX INNER-LINES 7
          DROP-DOWN-LIST
          SIZE 27.9 BY 1
     tt-sysconf.srok-opl AT ROW 3 COL 53 COLON-ALIGNED
          LABEL "Срок" FORMAT ">>9"
          VIEW-AS FILL-IN
          SIZE 4.4 BY 1
     COMBO-auto-pay AT ROW 3 COL 65 COLON-ALIGNED
     tt-sysconf.usl-opl-sf AT ROW 4 COL 18.1 COLON-ALIGNED WIDGET-ID 4
          LABEL "Услов. генер. СФ" FORMAT "X(256)"
          VIEW-AS COMBO-BOX INNER-LINES 7
          DROP-DOWN-LIST
          SIZE 27.9 BY 1
     tt-sysconf.srok-opl-sf AT ROW 4 COL 53 COLON-ALIGNED WIDGET-ID 6
          LABEL "Срок" FORMAT ">>9"
          VIEW-AS FILL-IN
          SIZE 4.4 BY 1
     COMBO-auto-pay-2 AT ROW 4 COL 65 COLON-ALIGNED WIDGET-ID 2
     tt-sysconf.pay-sign-post AT ROW 6 COL 11.8 COLON-ALIGNED
          LABEL "Должность" FORMAT "X(20)"
          VIEW-AS FILL-IN
          SIZE 21.3 BY 1
     tt-sysconf.pay-sign AT ROW 6 COL 39.1 COLON-ALIGNED
          LABEL "ФИО" FORMAT "X(20)"
          VIEW-AS FILL-IN
          SIZE 21.3 BY 1
     RADIO-SET-1 AT ROW 8 COL 4.5 NO-LABEL
     b-cor-acc AT ROW 8 COL 80.6
     b-an-uchet AT ROW 9 COL 80.6
     b-cel-nazn AT ROW 10 COL 80.6
     b-cor-acc-2 AT ROW 11 COL 80.6
     tt-sysconf.is-an-uchet AT ROW 14 COL 69.9 WIDGET-ID 12
          LABEL "Заполняется код ан. учета"
          VIEW-AS TOGGLE-BOX
          SIZE 28 BY 1
     b-bank-rub AT ROW 14.7 COL 3.5
     tt-sysconf.is-code-cel-nazn AT ROW 15 COL 69.9 WIDGET-ID 16
          VIEW-AS TOGGLE-BOX
          SIZE 28 BY 1
     tt-sysconf.is-corr-acc AT ROW 16 COL 69.9 WIDGET-ID 18
          VIEW-AS TOGGLE-BOX
          SIZE 28 BY 1
     tt-sysconf.is-cassa-acc AT ROW 17 COL 69.9 WIDGET-ID 14
          VIEW-AS TOGGLE-BOX
          SIZE 28 BY 1
     tt-sysconf.fin-VAT-pc AT ROW 17.73 COL 16.7 COLON-ALIGNED
          LABEL "НДС" FORMAT ">9.99%"
          VIEW-AS FILL-IN
          SIZE 7.8 BY 1
     tt-sysconf.fin-calc AT ROW 19 COL 69.9 NO-LABEL WIDGET-ID 8
          VIEW-AS RADIO-SET VERTICAL
          RADIO-BUTTONS
                    "Учет документов по фирме", 0,
"Учет документов по объекту", 1
          SIZE 28.9 BY 1.5
     Is-fin-copy AT ROW 20.5 COL 1.5 WIDGET-ID 26
     COMBO-fin-firm AT ROW 20.5 COL 34.5 COLON-ALIGNED NO-LABEL WIDGET-ID 24
     cor-acc-name AT ROW 8 COL 41 COLON-ALIGNED
     an-uchet-name AT ROW 9 COL 41 COLON-ALIGNED
     cel-nazn-name AT ROW 10 COL 41 COLON-ALIGNED
     cor-acc-2-name AT ROW 11 COL 41 COLON-ALIGNED
     bank-schet AT ROW 13.67 COL 7 COLON-ALIGNED
     bank-bik AT ROW 14.6 COL 10.5 COLON-ALIGNED
     bank-rub AT ROW 15.7 COL 6 COLON-ALIGNED
     "Договоры" VIEW-AS TEXT
          SIZE 14.6 BY .67 AT ROW 1.27 COL 42
          FGCOLOR 4
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON b-exit CANCEL-BUTTON B-quit.
DEFINE FRAME Dialog-Frame
     "Представитель фирмы (для подписания) :" VIEW-AS TEXT
          SIZE 41.4 BY .87 AT ROW 5 COL 3.1
     "Коды для док-ов" VIEW-AS TEXT
          SIZE 16.8 BY 1 AT ROW 7 COL 24.9
          FGCOLOR 4
     "Банковские счета" VIEW-AS TEXT
          SIZE 25.9 BY 1 AT ROW 12.57 COL 23.3
          FGCOLOR 4
     "Налоги:" VIEW-AS TEXT
          SIZE 8.4 BY 1 AT ROW 17.53 COL 2.5
          FGCOLOR 4
     RECT-2 AT ROW 1 COL 1
     RECT-4 AT ROW 12.47 COL 1
     RECT-6 AT ROW 17.53 COL 1
     RECT-5 AT ROW 12.47 COL 69.1 WIDGET-ID 20
     RECT-7 AT ROW 20.2 COL 1 WIDGET-ID 28
     SPACE(30.79) SKIP(0.06)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Значения по умолчанию в блоке 'Взаиморасчеты' и для Финансовых документов"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON B-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-an-uchet IN FRAME Dialog-Frame
DO:
  define variable rid-list as  char no-undo .
  define variable p-rec    as recid no-undo.
  define buffer buf_fin-code-an-uchet for ub.fin-code-An-uchet.
  assign p-rec = ? .
  if p-code-an-uchet <> ? then do:
    find first buf_fin-code-an-uchet no-lock where
              buf_fin-code-an-uchet.fin-code = p-code-an-uchet
          and buf_fin-code-an-uchet.host-code = p-host-code no-error .
    if available buf_fin-code-an-uchet then assign p-rec = recid (buf_fin-code-an-uchet) .
  end.
  run ref/fwcode-3.w  ( input parParentProc
                      , input "b-sel,no-b-firm" + (if not is-fin then ",b-add,b-chg,b-del" else "")
                      , input 'фирма':U
                      , input p-rec
                      , input p-host-code
                      , output rid-list )  .
  if rid-list <> "" then do:
    find first buf_fin-code-an-uchet no-lock where
           RECID(buf_fin-code-an-uchet) = int (rid-list) no-error .
    if available buf_fin-code-an-uchet then do:
      assign
        an-uchet-name = buf_fin-code-an-uchet.code-value + "  " + buf_fin-code-an-uchet.descr
        p-code-an-uchet = buf_fin-code-an-uchet.fin-code
      .
      if buf_fin-code-an-uchet.status_ <> integer('0':U) then do:
        message
        "Вы выбрали удаленный код!"  view-as alert-box.
      end.
    end.
    else assign p-code-an-uchet = 0  an-uchet-name = "" .
  end.
  else assign p-code-an-uchet = 0  an-uchet-name = "" .
  display
  an-uchet-name
  with frame Dialog-Frame.
END.
ON CHOOSE OF b-bank-rub IN FRAME Dialog-Frame
DO:
  define variable rid-list as  char no-undo .
  define variable v-status_ like ub.fin-schet.status_ no-undo init 'тек':U.
  define buffer buf_fin-schet for ub.fin-schet.
  define buffer buf_fin-bank for ub.fin-bank.
  if p-schet <> ? then do:
    find first buf_fin-schet no-lock where buf_fin-schet.code-schet = p-schet
           and buf_fin-schet.host-code = p-host-code no-error .
    if available buf_fin-schet then
    assign
    rid-list = string( recid (buf_fin-schet))
    v-status_ = buf_fin-schet.status_
    .
  end.
  run ref/finschts.w ( input parParentProc
                     , input p-host-code
                     , input "b-sel"
                     , input "cmp-host"
                     , input 'орг':U
                     , input p-host-code
                     , input 0
                     , input p-host-code
                     , input p-bank
                     , input-output v-status_
                     , input-output rid-list).
  if rid-list <> "" then do:
    find first buf_fin-schet no-lock where RECID(buf_fin-schet) = int (rid-list) no-error .
    if available buf_fin-schet then do:
      if buf_fin-schet.status_ = 'удал':U then do:
        message "Вы выбрали удаленный счет!"  view-as alert-box.
      end.
      assign
      bank-schet = buf_fin-schet.r-schet
      p-schet    = buf_fin-schet.code-schet
      p-bank     = buf_fin-schet.code-bank
      .
      find first buf_fin-bank no-lock where
                buf_fin-bank.code-bank = p-bank
            and buf_fin-bank.host-code = p-host-code  no-error .
        assign
        bank-bik = buf_fin-bank.bik
        bank-rub = buf_fin-bank.short-name
        .
    end.
  end.
  else assign  p-bank = ?    p-schet = ? .
  display
  bank-rub
  bank-bik
  bank-schet
  with frame Dialog-Frame.
END.
ON CHOOSE OF b-cel-nazn IN FRAME Dialog-Frame
DO:
  define variable rid-list as  char no-undo .
  define variable p-rec    as recid no-undo.
  define buffer buf_fin-code-cel-nazn for ub.fin-code-cel-nazn.
  assign p-rec = ? .
  if p-code-cel-nazn <> ? then do:
    find first buf_fin-code-cel-nazn no-lock where
              buf_fin-code-cel-nazn.fin-code = p-code-cel-nazn
         and buf_fin-code-cel-nazn.host-code = p-host-code no-error .
    if available buf_fin-code-cel-nazn then assign p-rec = recid (buf_fin-code-cel-nazn) .
  end.
  run ref/fwcode-2.w  ( input parParentProc
                      , input "b-sel,no-b-firm" + (if not is-fin then ",b-add,b-chg,b-del" else "")
                      , input 'фирма':U
                      , input p-rec
                      , input p-host-code
                      , output rid-list )  .
  if rid-list <> "" then do:
    find first buf_fin-code-cel-nazn no-lock where
              RECID(buf_fin-code-cel-nazn) = int (rid-list) no-error .
    if available buf_fin-code-cel-nazn then do:
      if buf_fin-code-cel-nazn.status_ <> integer('0':U) then DO:
        message
        "Вы выбрали удаленный код!"
        view-as alert-box.
      END.
      assign
      cel-nazn-name = buf_fin-code-cel-nazn.code-value + "  " + buf_fin-code-cel-nazn.descr
      p-code-cel-nazn = buf_fin-code-cel-nazn.fin-code
      .
    end.
    else assign p-code-cel-nazn = 0  cel-nazn-name = "" .
  end.
  else assign p-code-cel-nazn = 0  cel-nazn-name = "" .
  display
  cel-nazn-name
  with frame Dialog-Frame.
END.
ON CHOOSE OF b-cor-acc IN FRAME Dialog-Frame
DO:
  define variable rid-list as  char no-undo .
  define variable p-rec    as recid no-undo.
  define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc.
  assign p-rec = ? .
  if p-code-cor-acc <> ? then do:
    find first buf_fin-code-cor-acc no-lock where
              buf_fin-code-cor-acc.fin-code = p-code-cor-acc
          and buf_fin-code-cor-acc.host-code = p-host-code no-error .
    if available buf_fin-code-cor-acc then assign p-rec = recid (buf_fin-code-cor-acc) .
  end.
  run ref/fwcode-1.w  ( input parParentProc
                      , input "b-sel,no-b-firm" + (if not is-fin then ",b-add,b-chg,b-del" else "")
                      , input 'фирма':U
                      , input p-rec
                      , input p-host-code
                      , output rid-list )  .
  if rid-list <> "" then do:
    find first buf_fin-code-cor-acc no-lock where
         RECID(buf_fin-code-cor-acc) = int (rid-list) no-error .
    if available buf_fin-code-cor-acc then do:
      if buf_fin-code-cor-acc.status_ <> integer('0':U) then do:
        message
        "Вы выбрали удаленный код!"
        view-as alert-box.
      end.
      assign
      cor-acc-name = buf_fin-code-cor-acc.code-value + "  " + buf_fin-code-cor-acc.descr
      p-code-cor-acc = buf_fin-code-cor-acc.fin-code
      .
    end.
    else assign p-code-cor-acc = 0  cor-acc-name = "" .
  end.
  else assign p-code-cor-acc = 0  cor-acc-name = "" .
  display
  cor-acc-name
  with frame Dialog-Frame.
END.
ON CHOOSE OF b-cor-acc-2 IN FRAME Dialog-Frame
DO:
  define variable rid-list as  char no-undo .
  define variable p-rec    as recid no-undo.
  define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc.
  assign p-rec = ? .
  if p-code-cor-acc-2 <> ? then do:
    find first buf_fin-code-cor-acc no-lock where
              buf_fin-code-cor-acc.fin-code = p-code-cor-acc-2
          and buf_fin-code-cor-acc.host-code = p-host-code no-error .
    if available buf_fin-code-cor-acc then assign p-rec = recid (buf_fin-code-cor-acc) .
  end.
  run ref/fwcode-1.w  ( input parParentProc
                      , input "b-sel,no-b-firm" + (if not is-fin then ",b-add,b-chg,b-del" else "")
                      , input 'фирма':U
                      , input p-rec
                      , input p-host-code
                      , output rid-list )  .
  if rid-list <> "" then do:
    find first buf_fin-code-cor-acc no-lock where
             RECID(buf_fin-code-cor-acc) = int (rid-list) no-error .
    if available buf_fin-code-cor-acc then do:
      if buf_fin-code-cor-acc.status_ <> integer('0':U) then do:
        message
        "Вы выбрали удаленный код!"
        view-as alert-box.
      end.
      assign
      cor-acc-2-name = buf_fin-code-cor-acc.code-value + "  " + buf_fin-code-cor-acc.descr
      p-code-cor-acc-2 = buf_fin-code-cor-acc.fin-code
      .
    end.
    else assign p-code-cor-acc-2 = 0  cor-acc-2-name = "" .
  end.
  else assign p-code-cor-acc-2 = 0  cor-acc-2-name = "" .
  display
  cor-acc-2-name
  with frame Dialog-Frame.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  IF p-mode <> 'ИЗМЕНЕНИЕ':U THEN RETURN NO-APPLY.
  RUN proc-save IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN NO-APPLY.
END.
ON VALUE-CHANGED OF RADIO-SET-1 IN FRAME Dialog-Frame
DO:
define buffer buf_fin-code-an-uchet for ub.fin-code-an-uchet.
define buffer buf_fin-code-cel-nazn for ub.fin-code-cel-nazn.
define buffer buf_fin-code-cor-acc for ub.fin-code-cor-acc.
  assign
    a-code-an-uchet  [RADIO-SET-1] = p-code-an-uchet
    a-code-cel-nazn  [RADIO-SET-1] = p-code-cel-nazn
    a-code-cor-acc   [RADIO-SET-1] = p-code-cor-acc
    a-code-cor-acc-2 [RADIO-SET-1] = p-code-cor-acc-2
  .
  assign RADIO-SET-1 .
  assign
    p-code-an-uchet  = a-code-an-uchet  [RADIO-SET-1]
    p-code-cel-nazn  = a-code-cel-nazn  [RADIO-SET-1]
    p-code-cor-acc   = a-code-cor-acc   [RADIO-SET-1]
    p-code-cor-acc-2 = a-code-cor-acc-2 [RADIO-SET-1]
  .
  find first buf_fin-code-an-uchet no-lock where
          buf_fin-code-an-uchet.fin-code = p-code-an-uchet
      and buf_fin-code-an-uchet.host-code = p-host-code no-error .
  if available buf_fin-code-an-uchet then   do:
    assign
    an-uchet-name = buf_fin-code-an-uchet.code-value + "  " + buf_fin-code-an-uchet.descr  .
  end.
  else do:
    assign
    an-uchet-name = "" .
  end.
  find first buf_fin-code-cel-nazn no-lock where
            buf_fin-code-cel-nazn.fin-code  = p-code-cel-nazn
        and buf_fin-code-cel-nazn.host-code = p-host-code no-error .
  if available buf_fin-code-cel-nazn then do:
    assign
    cel-nazn-name = buf_fin-code-cel-nazn.code-value + "  " + buf_fin-code-cel-nazn.descr .
  end.
  else do:
    assign
    cel-nazn-name = "" .
  end.
  find first buf_fin-code-cor-acc no-lock where
           buf_fin-code-cor-acc.fin-code  = p-code-cor-acc
       and buf_fin-code-cor-acc.host-code = p-host-code no-error .
  if available buf_fin-code-cor-acc  then do:
    assign
    cor-acc-name = buf_fin-code-cor-acc.code-value + "  " + buf_fin-code-cor-acc.descr .
  end.
  else do:
    assign
    cor-acc-name = "" .
  end.
  find first buf_fin-code-cor-acc no-lock where
            buf_fin-code-cor-acc.fin-code  = p-code-cor-acc-2
        and buf_fin-code-cor-acc.host-code = p-host-code no-error .
  if available buf_fin-code-cor-acc  then do:
    assign
    cor-acc-2-name = buf_fin-code-cor-acc.code-value + "  " + buf_fin-code-cor-acc.descr .
  end.
  else do:
    assign
    cor-acc-2-name = "" .
  end.
  display
  cor-acc-2-name
  cor-acc-name
  cel-nazn-name
  an-uchet-name
  with frame Dialog-Frame.
  if RADIO-SET-1 > 2 then do:
    ENABLE
    b-cor-acc-2
    WITH FRAME Dialog-Frame .
   end.
  else do:
    DISABLE
    b-cor-acc-2
    WITH FRAME Dialog-Frame .
  end.
END.
ON VALUE-CHANGED OF tt-sysconf.usl-opl IN FRAME Dialog-Frame
DO:
  assign tt-sysconf.usl-opl .
  if tt-sysconf.usl-opl = 'Отсрочка платежа (по реализации)':U
  or tt-sysconf.usl-opl = 'Отсрочка платежа (по поставке)':U
  or tt-sysconf.usl-opl = 'По реализации части приход. накладной':U
  or tt-sysconf.usl-opl = 'Предоплата(%)':U then enable tt-sysconf.srok-opl with frame Dialog-Frame.
  else do:
    assign tt-sysconf.srok-opl = 0 .
    disable tt-sysconf.srok-opl with frame Dialog-Frame.
  end.
  if tt-sysconf.usl-opl = 'По реализации части приход. накладной':U
  or tt-sysconf.usl-opl = 'Предоплата(%)':U then assign tt-sysconf.srok-opl:label = "> %" .
  else assign tt-sysconf.srok-opl:label = "Срок" .
  display
  tt-sysconf.srok-opl
  with frame Dialog-Frame.
END.
ON VALUE-CHANGED OF tt-sysconf.usl-opl-sf IN FRAME Dialog-Frame
DO:
  assign
  tt-sysconf.usl-opl-sf
  tt-sysconf.srok-opl-sf = 0
  .
  disable
  tt-sysconf.srok-opl-sf
  with frame Dialog-Frame.
  display
  tt-sysconf.srok-opl-sf
  with frame Dialog-Frame.
END.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   :
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
  if  p-mode <> 'ИЗМЕНЕНИЕ':U
  and p-mode <> 'ПРОСМОТР':U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode"  p-mode
      view-as alert-box error .
    undo, return error.
  end.
  if p-mode <> 'ПРОСМОТР':U
  then do:
    if v-cntxt-db-num <> 0
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Неверное значение параметров вызова p-mode - нельзя изменять записи ФИРМЫ в УБД"
      view-as alert-box ERROR.
      undo, return error.
    end.
  end.
  for each tt-sysconf
  :
    delete tt-sysconf.
  end.
if p-mode = 'ИЗМЕНЕНИЕ':U
then do:
  do transaction:
  find first locked_sysconf exclusive-lock
    where locked_sysconf.host-code = p-host-code
    no-wait
    no-error .
  if not available locked_sysconf
  then do:
    if locked locked_sysconf
    then do:
      find first locked_sysconf exclusive-lock
        where locked_sysconf.host-code = p-host-code
        no-error .
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при поиске фирмы" skip
        "Код фирмы" p-host-code skip
        view-as alert-box error .
    end.
    undo, return error.
  end.
  end.
  end.
  else do:
    find first locked_sysconf no-lock
      where locked_sysconf.host-code = p-host-code .
  end.
  create tt-sysconf.
  buffer-copy Locked_sysconf to tt-sysconf.
  RUN fill-widgets IN THIS-PROCEDURE .
  RUN MyEnable IN this-procedure.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-sysconf SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY COMBO-auto-pay COMBO-auto-pay-2 RADIO-SET-1 Is-fin-copy COMBO-fin-firm
          cor-acc-name an-uchet-name cel-nazn-name cor-acc-2-name bank-schet
          bank-bik bank-rub
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-sysconf THEN
    DISPLAY tt-sysconf.contract-type tt-sysconf.contract-city tt-sysconf.usl-opl
          tt-sysconf.srok-opl tt-sysconf.usl-opl-sf tt-sysconf.srok-opl-sf
          tt-sysconf.pay-sign-post tt-sysconf.pay-sign tt-sysconf.is-an-uchet
          tt-sysconf.is-code-cel-nazn tt-sysconf.is-corr-acc
          tt-sysconf.is-cassa-acc tt-sysconf.fin-VAT-pc tt-sysconf.fin-calc
      WITH FRAME Dialog-Frame.
  ENABLE b-exit B-quit b-help RECT-2 RECT-4 RECT-6 RECT-5 RECT-7
         tt-sysconf.contract-type tt-sysconf.contract-city tt-sysconf.usl-opl
         tt-sysconf.srok-opl COMBO-auto-pay tt-sysconf.usl-opl-sf
         tt-sysconf.srok-opl-sf COMBO-auto-pay-2 tt-sysconf.pay-sign-post
         tt-sysconf.pay-sign RADIO-SET-1 b-cor-acc b-an-uchet b-cel-nazn
         b-cor-acc-2 tt-sysconf.is-an-uchet b-bank-rub
         tt-sysconf.is-code-cel-nazn tt-sysconf.is-corr-acc
         tt-sysconf.is-cassa-acc tt-sysconf.fin-VAT-pc tt-sysconf.fin-calc
         Is-fin-copy COMBO-fin-firm
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE fill-widgets :
DEFINE BUFFER buf_fin-code-an-uchet FOR ub.fin-code-an-uchet.
DEFINE BUFFER buf_fin-code-cel-nazn FOR ub.fin-code-cel-nazn.
DEFINE BUFFER buf_fin-code-cor-acc FOR ub.fin-code-cor-acc.
DEFINE BUFFER buf_fin-schet FOR ub.fin-schet.
DEFINE BUFFER buf_fin-bank FOR ub.fin-bank.
assign
a-code-an-uchet  [2] = tt-sysconf.an-uchet-code-in
a-code-cel-nazn  [2] = tt-sysconf.cel-nazn-code-in
a-code-cor-acc   [2] = tt-sysconf.cor-acc-in
a-code-cor-acc-2 [2] = tt-sysconf.cor-acc1-in
a-code-an-uchet  [3] = tt-sysconf.an-uchet-code-out-cash
a-code-cel-nazn  [3] = tt-sysconf.cel-nazn-code-out-cash
a-code-cor-acc   [3] = tt-sysconf.cor-acc-out-cash
a-code-cor-acc-2 [3] = tt-sysconf.cor-acc1-out-cash
a-code-an-uchet  [4] = tt-sysconf.an-uchet-code-in-cash
a-code-cel-nazn  [4] = tt-sysconf.cel-nazn-code-in-cash
a-code-cor-acc   [4] = tt-sysconf.cor-acc-in-cash
a-code-cor-acc-2 [4] = tt-sysconf.cor-acc1-in-cash
a-code-an-uchet  [5] = tt-sysconf.an-uchet-code-out-payoff
a-code-cel-nazn  [5] = tt-sysconf.cel-nazn-code-out-payoff
a-code-cor-acc   [5] = tt-sysconf.cor-acc-out-payoff
a-code-cor-acc-2 [5] = tt-sysconf.cor-acc1-out-payoff
a-code-an-uchet  [6] = tt-sysconf.an-uchet-code-in-payoff
a-code-cel-nazn  [6] = tt-sysconf.cel-nazn-code-in-payoff
a-code-cor-acc   [6] = tt-sysconf.cor-acc-in-payoff
a-code-cor-acc-2 [6] = tt-sysconf.cor-acc1-in-payoff
.
find first buf_fin-code-an-uchet no-lock where
         buf_fin-code-an-uchet.fin-code = tt-sysconf.an-uchet-code-out
     and buf_fin-code-an-uchet.host-code = tt-sysconf.host-code no-error .
if available buf_fin-code-an-uchet then
  assign
  an-uchet-name = buf_fin-code-an-uchet.code-value + "  " + buf_fin-code-an-uchet.descr
  p-code-an-uchet = tt-sysconf.an-uchet-code-out
  .
else do:
  assign p-code-an-uchet = 0 .
end.
assign
a-code-an-uchet [1] = p-code-an-uchet .
find first buf_fin-code-cel-nazn no-lock where
         buf_fin-code-cel-nazn.fin-code  = tt-sysconf.cel-nazn-code-out
     and buf_fin-code-cel-nazn.host-code = tt-sysconf.host-code no-error .
if available buf_fin-code-cel-nazn then
  assign
  cel-nazn-name = buf_fin-code-cel-nazn.code-value + "  " + buf_fin-code-cel-nazn.descr
  p-code-cel-nazn = tt-sysconf.cel-nazn-code-out
  .
else do:
  assign p-code-cel-nazn = ? .
end.
assign
a-code-cel-nazn [1] = p-code-cel-nazn .
find first buf_fin-code-cor-acc no-lock where
          buf_fin-code-cor-acc.fin-code  = tt-sysconf.cor-acc-out
      and buf_fin-code-cor-acc.host-code = tt-sysconf.host-code no-error .
if available buf_fin-code-cor-acc then
  assign
    cor-acc-name = buf_fin-code-cor-acc.code-value + "  " + buf_fin-code-cor-acc.descr
    p-code-cor-acc = tt-sysconf.cor-acc-out
  .
else do:
  assign
  p-code-cor-acc = ? .
end.
assign
a-code-cor-acc [1] = p-code-cor-acc .
find first buf_fin-code-cor-acc no-lock where
          buf_fin-code-cor-acc.fin-code  = tt-sysconf.cor-acc1-out
      and buf_fin-code-cor-acc.host-code = tt-sysconf.host-code no-error .
if available buf_fin-code-cor-acc then
  assign
    cor-acc-2-name = buf_fin-code-cor-acc.code-value + "  " + buf_fin-code-cor-acc.descr
    p-code-cor-acc-2 = tt-sysconf.cor-acc1-out
  .
else do:
  assign p-code-cor-acc-2 = ? .
end.
assign
a-code-cor-acc-2 [1] = p-code-cor-acc-2 .
  find first buf_fin-schet no-lock where
            buf_fin-schet.code-schet = tt-sysconf.pay-code-schet-rubl
        and buf_fin-schet.host-code = tt-sysconf.host-code no-error .
  if available buf_fin-schet then do:
    assign
    bank-schet = buf_fin-schet.r-schet
    p-schet    = buf_fin-schet.code-schet
    p-bank     = buf_fin-schet.code-bank  .
    find first buf_fin-bank no-lock where
              buf_fin-bank.code-bank = p-bank
         and buf_fin-bank.host-code = tt-sysconf.host-code no-error .
    assign
    bank-bik = buf_fin-bank.bik
    bank-rub = buf_fin-bank.short-name  .
  end.
  else assign  p-bank = ?    p-schet = ? .
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE temp-string AS CHARACTER NO-UNDO.
DEFINE BUFFER buf_sysconf FOR ub.sysconf.
DEFINE BUFFER buf_clients FOR ub.clients.
  assign
    temp-string = ""
  .
  for each buf_sysconf no-lock :
    find first buf_clients NO-LOCK where
              buf_clients.obj-code = buf_sysconf.host-code
          and buf_clients.obj-type = 'орг':U no-error .
    if temp-string = ""
    then do:
      assign
      temp-string = string(buf_sysconf.host-code,">>>>>>>>>9") + " " + buf_clients.obj-name  .
    end.
    else do:
      assign
      temp-string = temp-string + "," + string(buf_sysconf.host-code,">>>>>>>>>9") + " " + buf_clients.obj-name
      .
    end.
  end.
  ASSIGN
  COMBO-fin-firm:LIST-ITEMS IN FRAME Dialog-Frame = temp-string.
tt-sysconf.contract-type:list-items IN FRAME Dialog-Frame = "Не задан" + "," + 'Купли-продажи,Консигнации,Ответственного хранения,Агентский договор,Давальческого сырья,Продажи через ТПСИ,о Дополнительных расходах':U .
if tt-sysconf.contract-type <> "" and tt-sysconf.contract-type <> ?
then tt-sysconf.contract-type:screen-value = tt-sysconf.contract-type .
else tt-sysconf.contract-type:screen-value = "Не задан" .
tt-sysconf.usl-opl:list-items   =  'Не определено,По заказу,По поставке заказа,Отсрочка платежа по заказу,Отсрочка платежа по поставке заказа,По факту поставки,По факту реализации,Отсрочка платежа (по поставке),Отсрочка платежа (по реализации),По реализации части приход. накладной,По спецификации,Отсрочка платежа по спецификации,Предоплата,Предоплата(%),По факту поставки покупателю,Отсрочка платежа по поставке':U .
if tt-sysconf.usl-opl <> "" and tt-sysconf.usl-opl <> ? then tt-sysconf.usl-opl:screen-value = tt-sysconf.usl-opl .
else tt-sysconf.usl-opl:screen-value = 'Не определено':U .
tt-sysconf.usl-opl-sf:list-items   = 'Не определено':U + chr(44)  +
                                     'По приходной накладной':U + chr(44)  +
                                     'По фин. обязательству':U + chr(44)  +
                                     'По платежу':U + chr(44) +
                                     'По накл. смены типа преобр.':U.
if tt-sysconf.usl-opl-sf <> "" and tt-sysconf.usl-opl-sf <> ?
then tt-sysconf.usl-opl-sf:screen-value = tt-sysconf.usl-opl-sf .
COMBO-auto-pay:list-items = "фин.об. авто" + "," + "фин.об. факт" + "," + "платеж новый"  .
COMBO-auto-pay-2:list-items = "новый" + "," + "факт" .
case tt-sysconf.auto-pay :
when 0 then COMBO-auto-pay:screen-value = "фин.об. авто" .
when 1 then COMBO-auto-pay:screen-value = "фин.об. факт" .
when 2 then COMBO-auto-pay:screen-value = "платеж новый" .
when 3 then COMBO-auto-pay:screen-value = "платеж разр" .
when 4 then COMBO-auto-pay:screen-value = "платеж факт" .
end.
case tt-sysconf.auto-pay-sf :
when 0 then COMBO-auto-pay-2:screen-value = "новый" .
when 1 then COMBO-auto-pay-2:screen-value = "факт" .
end.
if   tt-sysconf.usl-opl = 'Отсрочка платежа (по реализации)':U
or tt-sysconf.usl-opl = 'Отсрочка платежа (по поставке)':U
or tt-sysconf.usl-opl = 'Предоплата(%)':U
or tt-sysconf.usl-opl = 'По реализации части приход. накладной':U  then do:
  assign
  tt-sysconf.srok-opl = tt-sysconf.srok-opl .
  if tt-sysconf.usl-opl = 'По реализации части приход. накладной':U or tt-sysconf.usl-opl = 'Предоплата(%)':U
  then assign tt-sysconf.srok-opl:label = "> %" .
end.
IF NOT is-fin THEN DO:
  ASSIGN
  radio-set-1:RADIO-BUTTONS IN FRAME Dialog-Frame =
  'рко':U + chr(44) + "3" + chr(44) +
  'пко':U + chr(44) +  "4"
  .
  radio-set-1 = 3.
END.
else do:
  radio-set-1 = 1.
end.
DISPLAY
COMBO-auto-pay
COMBO-auto-pay-2
RADIO-SET-1
cor-acc-name
an-uchet-name
cel-nazn-name
cor-acc-2-name
bank-schet
bank-bik
bank-rub
WITH FRAME Dialog-Frame.
IF AVAILABLE tt-sysconf THEN
DISPLAY
tt-sysconf.contract-type
tt-sysconf.contract-city
tt-sysconf.usl-opl
tt-sysconf.srok-opl
tt-sysconf.usl-opl-sf
tt-sysconf.srok-opl-sf
tt-sysconf.pay-sign-post
tt-sysconf.pay-sign
tt-sysconf.is-an-uchet
tt-sysconf.is-code-cel-nazn
tt-sysconf.fin-VAT-pc
tt-sysconf.is-corr-acc
tt-sysconf.is-cassa-acc
tt-sysconf.fin-calc
WITH FRAME Dialog-Frame.
ENABLE
b-exit WHEN p-mode <> 'ПРОСМОТР':U
RECT-2 RECT-4 RECT-6 RECT-5
B-quit
b-help
tt-sysconf.contract-type WHEN p-mode <> 'ПРОСМОТР':U AND is-fin
tt-sysconf.contract-city WHEN p-mode <> 'ПРОСМОТР':U AND is-fin
tt-sysconf.usl-opl  WHEN p-mode <> 'ПРОСМОТР':U AND is-fin
tt-sysconf.srok-opl WHEN p-mode <> 'ПРОСМОТР':U AND is-fin
COMBO-auto-pay WHEN p-mode <> 'ПРОСМОТР':U AND is-fin
tt-sysconf.usl-opl-sf WHEN p-mode <> 'ПРОСМОТР':U AND is-fin
tt-sysconf.srok-opl-sf WHEN p-mode <> 'ПРОСМОТР':U AND is-fin
COMBO-auto-pay-2 WHEN p-mode <> 'ПРОСМОТР':U AND is-fin
tt-sysconf.pay-sign-post WHEN p-mode <> 'ПРОСМОТР':U AND is-fin
tt-sysconf.pay-sign WHEN p-mode <> 'ПРОСМОТР':U AND is-fin
RADIO-SET-1
b-cor-acc   WHEN p-mode <> 'ПРОСМОТР':U AND VALID-HANDLE (parparentproc)
b-an-uchet WHEN p-mode <> 'ПРОСМОТР':U AND VALID-HANDLE (parparentproc)
b-cel-nazn WHEN p-mode <> 'ПРОСМОТР':U AND VALID-HANDLE (parparentproc)
b-cor-acc-2 WHEN p-mode <> 'ПРОСМОТР':U AND VALID-HANDLE (parparentproc)
b-bank-rub WHEN p-mode <> 'ПРОСМОТР':U AND VALID-HANDLE (parparentproc) AND is-fin
tt-sysconf.is-an-uchet WHEN p-mode <> 'ПРОСМОТР':U
tt-sysconf.is-code-cel-nazn WHEN p-mode <> 'ПРОСМОТР':U
tt-sysconf.fin-VAT-pc WHEN p-mode <> 'ПРОСМОТР':U AND is-fin
tt-sysconf.is-corr-acc WHEN p-mode <> 'ПРОСМОТР':U
tt-sysconf.is-cassa-acc WHEN p-mode <> 'ПРОСМОТР':U
tt-sysconf.fin-calc WHEN p-mode <> 'ПРОСМОТР':U   AND is-fin
Is-fin-copy WHEN p-mode <> 'ПРОСМОТР':U AND is-fin
COMBO-fin-firm WHEN p-mode <> 'ПРОСМОТР':U AND is-fin
WITH FRAME Dialog-Frame.
VIEW FRAME Dialog-Frame.
if p-mode = 'ПРОСМОТР':U then do:
    ASSIGN
    b-quit:LABEL = "&Выход"
    b-quit:COLUMN = 1
    .
    HIDE
    b-exit
    Is-fin-copy
    COMBO-fin-firm
    IN FRAME Dialog-Frame.
end.
else do:
    if   tt-sysconf.usl-opl = 'Не определено':U
      or tt-sysconf.usl-opl = 'По факту поставки':U
      or tt-sysconf.usl-opl = 'По факту реализации':U
    then  do:
      disable
      tt-sysconf.srok-opl
      with frame Dialog-Frame.
    end.
    disable
    tt-sysconf.srok-opl-sf
    with frame Dialog-Frame.
end.
apply "VALUE-CHANGED" to RADIO-SET-1 in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-save :
define variable v-rid as recid no-undo .
define variable v-fin-host-copy like ub.sysconf.host-code no-undo .
assign
FRAME Dialog-Frame
RADIO-SET-1
COMBO-auto-pay
COMBO-auto-pay-2
is-fin-copy
COMBO-fin-firm
.
assign
v-fin-host-copy = int(substr(COMBO-fin-firm,1,6))
no-error
.
assign
a-code-an-uchet  [RADIO-SET-1] = p-code-an-uchet
a-code-cel-nazn  [RADIO-SET-1] = p-code-cel-nazn
a-code-cor-acc   [RADIO-SET-1] = p-code-cor-acc
a-code-cor-acc-2 [RADIO-SET-1] = p-code-cor-acc-2
.
case COMBO-auto-pay:screen-value IN FRAME Dialog-Frame:
  when "фин.об. авто" then tt-sysconf.auto-pay = 0 .
  when "фин.об. факт" then tt-sysconf.auto-pay = 1 .
  when "платеж новый" then tt-sysconf.auto-pay = 2 .
  when "платеж разр"  then tt-sysconf.auto-pay = 3 .
  when "платеж факт"  then tt-sysconf.auto-pay = 4 .
end.
case COMBO-auto-pay-2:screen-value :
  when "новый" then tt-sysconf.auto-pay-sf = 0 .
  when "факт" then tt-sysconf.auto-pay-sf = 1 .
end.
ASSIGN
tt-sysconf.contract-city
tt-sysconf.contract-type
tt-sysconf.pay-sign-post
tt-sysconf.pay-sign
tt-sysconf.fin-VAT-pc
tt-sysconf.srok-opl
tt-sysconf.srok-opl-sf
tt-sysconf.usl-opl
tt-sysconf.usl-opl-sf
tt-sysconf.is-an-uchet
tt-sysconf.is-code-cel-nazn
tt-sysconf.is-corr-acc
tt-sysconf.is-cassa-acc
tt-sysconf.fin-calc
tt-sysconf.pay-code-schet-rubl = p-schet
tt-sysconf.pay-code-schet-base = p-schet1
tt-sysconf.an-uchet-code-out        = a-code-an-uchet  [1]
tt-sysconf.cel-nazn-code-out        = a-code-cel-nazn  [1]
tt-sysconf.cor-acc-out              = a-code-cor-acc   [1]
tt-sysconf.cor-acc1-out             = a-code-cor-acc-2 [1]
tt-sysconf.an-uchet-code-in         = a-code-an-uchet  [2]
tt-sysconf.cel-nazn-code-in         = a-code-cel-nazn  [2]
tt-sysconf.cor-acc-in               = a-code-cor-acc   [2]
tt-sysconf.cor-acc1-in              = a-code-cor-acc-2 [2]
tt-sysconf.an-uchet-code-out-cash   = a-code-an-uchet  [3]
tt-sysconf.cel-nazn-code-out-cash   = a-code-cel-nazn  [3]
tt-sysconf.cor-acc-out-cash         = a-code-cor-acc   [3]
tt-sysconf.cor-acc1-out-cash        = a-code-cor-acc-2 [3]
tt-sysconf.an-uchet-code-in-cash    = a-code-an-uchet  [4]
tt-sysconf.cel-nazn-code-in-cash    = a-code-cel-nazn  [4]
tt-sysconf.cor-acc-in-cash          = a-code-cor-acc   [4]
tt-sysconf.cor-acc1-in-cash         = a-code-cor-acc-2 [4]
tt-sysconf.an-uchet-code-out-payoff = a-code-an-uchet  [5]
tt-sysconf.cel-nazn-code-out-payoff = a-code-cel-nazn  [5]
tt-sysconf.cor-acc-out-payoff       = a-code-cor-acc   [5]
tt-sysconf.cor-acc1-out-payoff      = a-code-cor-acc-2 [5]
tt-sysconf.an-uchet-code-in-payoff  = a-code-an-uchet  [6]
tt-sysconf.cel-nazn-code-in-payoff  = a-code-cel-nazn  [6]
tt-sysconf.cor-acc-in-payoff        = a-code-cor-acc   [6]
tt-sysconf.cor-acc1-in-payoff       = a-code-cor-acc-2 [6]
.
if ( tt-sysconf.usl-opl = 'По реализации части приход. накладной':U
    or tt-sysconf.usl-opl = 'Предоплата(%)':U) and tt-sysconf.srok-opl = 0 then do:
  message
  "Процент реализации не может быть 0 !"
  view-as alert-box ERROR.
  undo, return ERROR.
end.
v-rid = recid(locked_sysconf).
run adm/fin-def1.p (
   input-output v-rid
  ,input p-mode
  ,input no
  ,input  tt-sysconf.host-code
  ,input  is-fin-copy
  ,input  v-fin-host-copy
  ,input  tt-sysconf.contract-city
  ,input  tt-sysconf.contract-type
  ,input  tt-sysconf.pay-sign-post
  ,input  tt-sysconf.pay-sign
  ,input  tt-sysconf.fin-VAT-pc
  ,input  tt-sysconf.srok-opl
  ,input  tt-sysconf.srok-opl-sf
  ,input  tt-sysconf.usl-opl
  ,input  tt-sysconf.usl-opl-sf
  ,input  tt-sysconf.is-an-uchet
  ,input  tt-sysconf.is-code-cel-nazn
  ,input  tt-sysconf.is-corr-acc
  ,input  tt-sysconf.is-cassa-acc
  ,input  tt-sysconf.fin-calc
  ,input  tt-sysconf.pay-code-schet-rubl
  ,input  tt-sysconf.pay-code-schet-base
  ,input  tt-sysconf.an-uchet-code-out
  ,input  tt-sysconf.cel-nazn-code-out
  ,input  tt-sysconf.cor-acc-out
  ,input  tt-sysconf.cor-acc1-out
  ,input  tt-sysconf.an-uchet-code-in
  ,input  tt-sysconf.cel-nazn-code-in
  ,input  tt-sysconf.cor-acc-in
  ,input  tt-sysconf.cor-acc1-in
  ,input  tt-sysconf.an-uchet-code-out-cash
  ,input  tt-sysconf.cel-nazn-code-out-cash
  ,input  tt-sysconf.cor-acc-out-cash
  ,input  tt-sysconf.cor-acc1-out-cash
  ,input  tt-sysconf.an-uchet-code-in-cash
  ,input  tt-sysconf.cel-nazn-code-in-cash
  ,input  tt-sysconf.cor-acc-in-cash
  ,input  tt-sysconf.cor-acc1-in-cash
  ,input  tt-sysconf.an-uchet-code-out-payoff
  ,input  tt-sysconf.cel-nazn-code-out-payoff
  ,input  tt-sysconf.cor-acc-out-payoff
  ,input  tt-sysconf.cor-acc1-out-payoff
  ,input  tt-sysconf.an-uchet-code-in-payoff
  ,input  tt-sysconf.cel-nazn-code-in-payoff
  ,input  tt-sysconf.cor-acc-in-payoff
  ,input  tt-sysconf.cor-acc1-in-payoff
    ) NO-ERROR.
IF ERROR-STATUS:ERROR  THEN DO:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable fh as widget-handle no-undo .
define variable hh as widget-handle no-undo .
define variable rv as character no-undo .
assign
rv = entry(1, return-value , chr(4)).
if rv <> "":U then do:
  assign
  fh = frame Dialog-Frame:first-child
  hh = fh:first-child
  .
  do while valid-handle(hh):
    if hh:name = rv then do:
      APPLY "ENTRY" to hh.
      undo ,
      return error.
    end.
    hh = hh:next-sibling.
  end.
end.
  undo, return error.
END.
END PROCEDURE.
