define input         parameter p-mode as character no-undo .
define input-output  parameter p-list as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Корректировка списка методов переоценки".
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
define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .
DEFINE BUTTON B-cancel AUTO-GO
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE BUTTON B-Help
     LABEL "&Help"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-ok AUTO-GO
     LABEL "В&вод"
     SIZE 10 BY 1.
DEFINE IMAGE I-pr-calc-cost
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-cost-gr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-cost-novat
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-cost-wbill
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-cost-wbill-novat
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-costobj
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-fix
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-goods
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-grp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-last
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-last-gr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-lastobj
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-level-prod
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-level-prod-VAT
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-new
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-no
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-novat-gr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-obj
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-old
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-old-novat
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-ov
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-pdf
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-prod
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-prod-vat
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-rsrv
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-rsrv-gr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-slt
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-slt-wbill
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-specif
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-wbill
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-calc-wbill-novat
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE IMAGE I-pr-common
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY 1.
DEFINE VARIABLE pr-calc-cost AS LOGICAL INITIAL no
     LABEL "Учетная"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-cost-gr AS LOGICAL INITIAL no
     LABEL "УчетнаяS"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-cost-novat AS LOGICAL INITIAL no
     LABEL "Учет-безНДС"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-cost-novat-gr AS LOGICAL INITIAL no
     LABEL "Учет-НДСS"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-cost-wbill AS LOGICAL INITIAL no
     LABEL "Учет+накл"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-cost-wbill-novat AS LOGICAL INITIAL no
     LABEL "Уч+накл-НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-costobj AS LOGICAL INITIAL no
     LABEL "Учет-объект"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-fix AS LOGICAL INITIAL no
     LABEL "Не-считать"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-goods AS LOGICAL INITIAL no
     LABEL "Товар"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-grp AS LOGICAL INITIAL no
     LABEL "Группа"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-last AS LOGICAL INITIAL no
     LABEL "Приходная"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-last-gr AS LOGICAL INITIAL no
     LABEL "ПриходнаяS"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-lastobj AS LOGICAL INITIAL no
     LABEL "Прих-объект"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-level-prod AS LOGICAL INITIAL no
     LABEL "ПорогПр-НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-level-prod-VAT AS LOGICAL INITIAL no
     LABEL "ПорогПр+НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-new AS LOGICAL INITIAL no
     LABEL "Новая"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-no AS LOGICAL INITIAL no
     LABEL "Отсутствует"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-obj AS LOGICAL INITIAL no
     LABEL "Объект"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-old AS LOGICAL INITIAL no
     LABEL "Старая"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-old-novat AS LOGICAL INITIAL no
     LABEL "Стар-безНДС"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-ov AS LOGICAL INITIAL no
     LABEL "Переоценка"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-pdf AS LOGICAL INITIAL no
     LABEL "ДокФормЦены"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-prod AS LOGICAL INITIAL no
     LABEL "Производитель"
     VIEW-AS TOGGLE-BOX
     SIZE 15.5 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-prod-vat AS LOGICAL INITIAL no
     LABEL "Произв-НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-rsrv AS LOGICAL INITIAL no
     LABEL "Учет-резерв"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-rsrv-gr AS LOGICAL INITIAL no
     LABEL "Учет-рзрвS"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-slt AS LOGICAL INITIAL no
     LABEL "НсП"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-slt-wbill AS LOGICAL INITIAL no
     LABEL "НсП+накл"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-specif AS LOGICAL INITIAL no
     LABEL "Спецификация"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-wbill AS LOGICAL INITIAL no
     LABEL "Накладная"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-calc-wbill-novat AS LOGICAL INITIAL no
     LABEL "Накл-безНДС"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE pr-common AS LOGICAL INITIAL no
     LABEL "Единая"
     VIEW-AS TOGGLE-BOX
     SIZE 15 BY 1 NO-UNDO.
DEFINE FRAME Dialog-Frame
     B-ok AT ROW 1 COL 1 WIDGET-ID 4
     B-cancel AT ROW 1 COL 11 WIDGET-ID 6
     B-Help AT ROW 1 COL 50
     pr-calc-goods AT ROW 2 COL 5 WIDGET-ID 12
     pr-calc-slt AT ROW 2 COL 31 WIDGET-ID 48
     pr-calc-grp AT ROW 3 COL 5 WIDGET-ID 14
     pr-calc-slt-wbill AT ROW 3 COL 31 WIDGET-ID 50
     pr-calc-cost AT ROW 4 COL 5 WIDGET-ID 16
     pr-calc-cost-gr AT ROW 4 COL 31 WIDGET-ID 52
     pr-calc-costobj AT ROW 5 COL 5 WIDGET-ID 18
     pr-calc-rsrv-gr AT ROW 5 COL 31 WIDGET-ID 54
     pr-calc-rsrv AT ROW 6 COL 5 WIDGET-ID 20
     pr-calc-last-gr AT ROW 6 COL 31 WIDGET-ID 56
     pr-calc-last AT ROW 7 COL 5 WIDGET-ID 22
     pr-calc-cost-novat-gr AT ROW 7 COL 31 WIDGET-ID 58
     pr-calc-lastobj AT ROW 8 COL 5 WIDGET-ID 24
     pr-common AT ROW 8 COL 31 WIDGET-ID 60
     pr-calc-old AT ROW 9 COL 5 WIDGET-ID 26
     pr-calc-prod AT ROW 9 COL 31 WIDGET-ID 120
     pr-calc-new AT ROW 10 COL 5 WIDGET-ID 28
     pr-calc-prod-vat AT ROW 10 COL 31 WIDGET-ID 126
     pr-calc-obj AT ROW 11 COL 5 WIDGET-ID 30
     pr-calc-no AT ROW 11 COL 31 WIDGET-ID 62
     pr-calc-wbill AT ROW 12 COL 5 WIDGET-ID 32
     pr-calc-fix AT ROW 12 COL 31 WIDGET-ID 64
     pr-calc-wbill-novat AT ROW 13 COL 5 WIDGET-ID 34
     pr-calc-level-prod AT ROW 13 COL 31 WIDGET-ID 130
     pr-calc-cost-novat AT ROW 14 COL 5 WIDGET-ID 36
     pr-calc-level-prod-VAT AT ROW 14 COL 31 WIDGET-ID 134
     pr-calc-old-novat AT ROW 15 COL 5 WIDGET-ID 38
     pr-calc-specif AT ROW 15 COL 31 WIDGET-ID 138
     pr-calc-ov AT ROW 16 COL 5 WIDGET-ID 40
     pr-calc-pdf AT ROW 17 COL 5 WIDGET-ID 42
     pr-calc-cost-wbill AT ROW 18 COL 5 WIDGET-ID 44
     pr-calc-cost-wbill-novat AT ROW 19 COL 5 WIDGET-ID 46
     I-pr-calc-goods AT ROW 2 COL 1.13 WIDGET-ID 66
     I-pr-calc-grp AT ROW 3 COL 1.13 WIDGET-ID 68
     I-pr-calc-cost AT ROW 4 COL 1.13 WIDGET-ID 70
     I-pr-calc-costobj AT ROW 5 COL 1.13 WIDGET-ID 72
     I-pr-calc-rsrv AT ROW 6 COL 1.13 WIDGET-ID 74
     I-pr-calc-last AT ROW 7 COL 1.13 WIDGET-ID 76
     I-pr-calc-lastobj AT ROW 8 COL 1.13 WIDGET-ID 78
     I-pr-calc-old AT ROW 9 COL 1.13 WIDGET-ID 80
     I-pr-calc-new AT ROW 10 COL 1.13 WIDGET-ID 82
     I-pr-calc-obj AT ROW 11 COL 1.13 WIDGET-ID 84
     I-pr-calc-wbill AT ROW 12 COL 1.13 WIDGET-ID 86
     I-pr-calc-wbill-novat AT ROW 13 COL 1.13 WIDGET-ID 88
     I-pr-calc-cost-novat AT ROW 14 COL 1.13 WIDGET-ID 90
     I-pr-calc-old-novat AT ROW 15 COL 1.13 WIDGET-ID 92
     I-pr-calc-ov AT ROW 16 COL 1.13 WIDGET-ID 94
     I-pr-calc-pdf AT ROW 17 COL 1.13 WIDGET-ID 96
     I-pr-calc-cost-wbill AT ROW 18 COL 1.13 WIDGET-ID 98
     I-pr-calc-cost-wbill-novat AT ROW 19 COL 1.13 WIDGET-ID 100
     I-pr-calc-slt AT ROW 2 COL 27.5 WIDGET-ID 102
     I-pr-calc-slt-wbill AT ROW 3 COL 27.5 WIDGET-ID 104
     I-pr-calc-cost-gr AT ROW 4 COL 27.5 WIDGET-ID 106
     I-pr-calc-rsrv-gr AT ROW 5 COL 27.5 WIDGET-ID 108
     I-pr-calc-last-gr AT ROW 6 COL 27.5 WIDGET-ID 110
     I-pr-calc-novat-gr AT ROW 7 COL 27.5 WIDGET-ID 112
     I-pr-common AT ROW 8 COL 27.5 WIDGET-ID 114
     I-pr-calc-no AT ROW 11 COL 27.5 WIDGET-ID 116
     I-pr-calc-fix AT ROW 12 COL 27.5 WIDGET-ID 118
     I-pr-calc-prod AT ROW 9 COL 27.5 WIDGET-ID 122
     I-pr-calc-prod-vat AT ROW 10 COL 27.5 WIDGET-ID 124
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         CANCEL-BUTTON B-cancel WIDGET-ID 100.
DEFINE FRAME Dialog-Frame
     I-pr-calc-level-prod AT ROW 13 COL 27.5 WIDGET-ID 128
     I-pr-calc-level-prod-VAT AT ROW 14 COL 27.5 WIDGET-ID 132
     I-pr-calc-specif AT ROW 15 COL 27.5 WIDGET-ID 136
     SPACE(23.49) SKIP(4.70)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Методы расчета цены используемые в системе"
         CANCEL-BUTTON B-cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF B-Help IN FRAME Dialog-Frame
OR HELP OF FRAME Dialog-Frame
DO:
END.
ON CHOOSE OF B-ok IN FRAME Dialog-Frame
DO:
IF p-mode = 'ПРОСМОТР':U THEN RETURN .
  ASSIGN
      pr-calc-cost
      pr-calc-cost-gr
      pr-calc-cost-novat
      pr-calc-cost-novat-gr
      pr-calc-costobj
      pr-calc-cost-wbill
      pr-calc-cost-wbill-novat
      pr-calc-fix
      pr-calc-goods
      pr-calc-grp
      pr-calc-last
      pr-calc-last-gr
      pr-calc-lastobj
      pr-calc-new
      pr-calc-no
      pr-calc-obj
      pr-calc-old
      pr-calc-old-novat
      pr-calc-ov
      pr-calc-pdf
      pr-calc-rsrv
      pr-calc-rsrv-gr
      pr-calc-slt
      pr-calc-slt-wbill
      pr-calc-wbill
      pr-calc-wbill-novat
      pr-common
      pr-calc-prod
      pr-calc-prod-vat
      pr-calc-level-prod
      pr-calc-level-prod-vat
      pr-calc-specif
      .
p-list = "".
if pr-calc-cost               = true  then p-list = p-list + 'Учетная':U             + ","  .
if pr-calc-cost-gr            = true  then p-list = p-list + 'УчетнаяS':U          + ","  .
if pr-calc-cost-novat         = true  then p-list = p-list + 'Учет-безНДС':U       + ","  .
if pr-calc-cost-novat-gr      = true  then p-list = p-list + 'Учет-НДСS':U    + ","  .
if pr-calc-costobj            = true  then p-list = p-list + 'Учет-объект':U          + ","  .
if pr-calc-cost-wbill         = true  then p-list = p-list + 'Учет+накл':U       + ","  .
if pr-calc-cost-wbill-novat   = true  then p-list = p-list + 'Уч+накл-НДС':U + ","  .
if pr-calc-fix                = true  then p-list = p-list + 'Не-считать':U              + ","  .
if pr-calc-goods              = true  then p-list = p-list + 'Товар':U            + ","  .
if pr-calc-grp                = true  then p-list = p-list + 'Группа':U              + ","  .
if pr-calc-last               = true  then p-list = p-list + 'Приходная':U             + ","  .
if pr-calc-last-gr            = true  then p-list = p-list + 'ПриходнаяS':U          + ","  .
if pr-calc-lastobj            = true  then p-list = p-list + 'Прих-объект':U          + ","  .
if pr-calc-new                = true  then p-list = p-list + 'Новая':U              + ","  .
if pr-calc-no                 = true  then p-list = p-list + 'Отсутствует':U               + ","  .
if pr-calc-obj                = true  then p-list = p-list + 'Объект':U              + ","  .
if pr-calc-old                = true  then p-list = p-list + 'Старая':U              + ","  .
if pr-calc-old-novat          = true  then p-list = p-list + 'Стар-безНДС':U        + ","  .
if pr-calc-ov                 = true  then p-list = p-list + 'Переоценка':U               + ","  .
if pr-calc-pdf                = true  then p-list = p-list + 'ДокФормЦены':U              + ","  .
if pr-calc-rsrv               = true  then p-list = p-list + 'Учет-резерв':U             + ","  .
if pr-calc-rsrv-gr            = true  then p-list = p-list + 'Учет-рзрвS':U          + ","  .
if pr-calc-slt                = true  then p-list = p-list + 'НсП':U              + ","  .
if pr-calc-slt-wbill          = true  then p-list = p-list + 'НсП+накл':U        + ","  .
if pr-calc-wbill              = true  then p-list = p-list + 'Накладная':U            + ","  .
if pr-calc-wbill-novat        = true  then p-list = p-list + 'Накл-безНДС':U      + ","  .
if pr-common                  = true  then p-list = p-list + 'Единая':U                + ","  .
if pr-calc-prod               = true  then p-list = p-list + 'Производит':U             + ","  .
if pr-calc-prod-vat           = true  then p-list = p-list + 'Произв-НДС':U         + ","  .
if pr-calc-level-prod         = true  then p-list = p-list + 'ПорогПр-НДС':U       + ","  .
if pr-calc-level-prod-vat     = true  then p-list = p-list + 'ПорогПр+НДС':U   + ","  .
if pr-calc-specif             = true  then p-list = p-list + 'Спецификация':U           + ","  .
p-list = trim (p-list ,",") .
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-cost IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-cost:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-cost-gr IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-cost-gr:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-cost-novat IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-cost-novat:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-cost-wbill IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-cost-wbill:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-cost-wbill-novat IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-cost-wbill-novat:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-costobj IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-costobj:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-fix IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-fix:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-goods IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-goods:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-grp IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-grp:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-last IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-last:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-last-gr IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-last-gr:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-lastobj IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-lastobj:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-level-prod IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-level-prod:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-level-prod-VAT IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-level-prod-VAT:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-new IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-new:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-no IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-no:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-novat-gr IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-novat-gr:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-obj IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-obj:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-old IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-old:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-old-novat IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-old-novat:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-ov IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-ov:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-pdf IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-pdf:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-prod IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-prod:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-prod-vat IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-prod-vat:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-rsrv IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-rsrv:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-rsrv-gr IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-rsrv-gr:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-slt IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-slt:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-slt-wbill IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-slt-wbill:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-specif IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-specif:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-wbill IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-wbill:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-calc-wbill-novat IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-calc-wbill-novat:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
ON MOUSE-SELECT-CLICK OF I-pr-common IN FRAME Dialog-Frame
DO:
  MESSAGE I-pr-common:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run init-tt in this-procedure .
  run enable_ui in this-procedure .
  if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
     disable
     pr-calc-cost
     pr-calc-cost-gr
     pr-calc-cost-novat
     pr-calc-cost-novat-gr
     pr-calc-costobj
     pr-calc-cost-wbill
     pr-calc-cost-wbill-novat
     pr-calc-fix
     pr-calc-goods
     pr-calc-grp
     pr-calc-last
     pr-calc-last-gr
     pr-calc-lastobj
     pr-calc-new
     pr-calc-no
     pr-calc-obj
     pr-calc-old
     pr-calc-old-novat
     pr-calc-ov
     pr-calc-pdf
     pr-calc-rsrv
     pr-calc-rsrv-gr
     pr-calc-slt
     pr-calc-slt-wbill
     pr-calc-wbill
     pr-calc-wbill-novat
     pr-common
     pr-calc-prod
     pr-calc-prod-vat
     pr-calc-level-prod
     pr-calc-level-prod-vat
     pr-calc-specif
     with frame Dialog-Frame.
     B-ok:label = "Вы&ход"  .
     hide B-cancel in frame Dialog-Frame .
  end.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY pr-calc-goods pr-calc-slt pr-calc-grp pr-calc-slt-wbill pr-calc-cost
          pr-calc-cost-gr pr-calc-costobj pr-calc-rsrv-gr pr-calc-rsrv
          pr-calc-last-gr pr-calc-last pr-calc-cost-novat-gr pr-calc-lastobj
          pr-common pr-calc-old pr-calc-prod pr-calc-new pr-calc-prod-vat
          pr-calc-obj pr-calc-no pr-calc-wbill pr-calc-fix pr-calc-wbill-novat
          pr-calc-level-prod pr-calc-cost-novat pr-calc-level-prod-VAT
          pr-calc-old-novat pr-calc-specif pr-calc-ov pr-calc-pdf
          pr-calc-cost-wbill pr-calc-cost-wbill-novat
      WITH FRAME Dialog-Frame.
  ENABLE B-ok B-cancel B-Help I-pr-calc-goods I-pr-calc-grp I-pr-calc-cost
         I-pr-calc-costobj I-pr-calc-rsrv I-pr-calc-last I-pr-calc-lastobj
         I-pr-calc-old I-pr-calc-new I-pr-calc-obj I-pr-calc-wbill
         I-pr-calc-wbill-novat I-pr-calc-cost-novat I-pr-calc-old-novat
         I-pr-calc-ov I-pr-calc-pdf I-pr-calc-cost-wbill
         I-pr-calc-cost-wbill-novat I-pr-calc-slt I-pr-calc-slt-wbill
         I-pr-calc-cost-gr I-pr-calc-rsrv-gr I-pr-calc-last-gr
         I-pr-calc-novat-gr I-pr-common I-pr-calc-no I-pr-calc-fix
         I-pr-calc-prod I-pr-calc-prod-vat I-pr-calc-level-prod
         I-pr-calc-level-prod-VAT I-pr-calc-specif pr-calc-goods pr-calc-slt
         pr-calc-grp pr-calc-slt-wbill pr-calc-cost pr-calc-cost-gr
         pr-calc-costobj pr-calc-rsrv-gr pr-calc-rsrv pr-calc-last-gr
         pr-calc-last pr-calc-cost-novat-gr pr-calc-lastobj pr-common
         pr-calc-old pr-calc-prod pr-calc-new pr-calc-prod-vat pr-calc-obj
         pr-calc-no pr-calc-wbill pr-calc-fix pr-calc-wbill-novat
         pr-calc-level-prod pr-calc-cost-novat pr-calc-level-prod-VAT
         pr-calc-old-novat pr-calc-specif pr-calc-ov pr-calc-pdf
         pr-calc-cost-wbill pr-calc-cost-wbill-novat
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init-tt :
if lookup ('Учетная':U,p-list ) > 0 then             pr-calc-cost               = true .
if lookup ('УчетнаяS':U,p-list ) > 0 then          pr-calc-cost-gr            = true .
if lookup ('Учет-безНДС':U,p-list ) > 0 then       pr-calc-cost-novat         = true .
if lookup ('Учет-НДСS':U,p-list ) > 0 then    pr-calc-cost-novat-gr      = true .
if lookup ('Учет-объект':U,p-list ) > 0 then          pr-calc-costobj            = true .
if lookup ('Учет+накл':U,p-list ) > 0 then       pr-calc-cost-wbill         = true .
if lookup ('Уч+накл-НДС':U,p-list ) > 0 then pr-calc-cost-wbill-novat   = true .
if lookup ('Не-считать':U,p-list ) > 0 then              pr-calc-fix                = true .
if lookup ('Товар':U,p-list ) > 0 then            pr-calc-goods              = true .
if lookup ('Группа':U,p-list ) > 0 then              pr-calc-grp                = true .
if lookup ('Приходная':U,p-list ) > 0 then             pr-calc-last               = true .
if lookup ('ПриходнаяS':U,p-list ) > 0 then          pr-calc-last-gr            = true .
if lookup ('Прих-объект':U,p-list ) > 0 then          pr-calc-lastobj            = true .
if lookup ('Новая':U,p-list ) > 0 then              pr-calc-new                = true .
if lookup ('Отсутствует':U,p-list ) > 0 then               pr-calc-no                 = true .
if lookup ('Объект':U,p-list ) > 0 then              pr-calc-obj                = true .
if lookup ('Старая':U,p-list ) > 0 then              pr-calc-old                = true .
if lookup ('Стар-безНДС':U,p-list ) > 0 then        pr-calc-old-novat          = true .
if lookup ('Переоценка':U,p-list ) > 0 then               pr-calc-ov                 = true .
if lookup ('ДокФормЦены':U,p-list ) > 0 then              pr-calc-pdf                = true .
if lookup ('Учет-резерв':U,p-list ) > 0 then             pr-calc-rsrv               = true .
if lookup ('Учет-рзрвS':U,p-list ) > 0 then          pr-calc-rsrv-gr            = true .
if lookup ('НсП':U,p-list ) > 0 then              pr-calc-slt                = true .
if lookup ('НсП+накл':U,p-list ) > 0 then        pr-calc-slt-wbill          = true .
if lookup ('Накладная':U,p-list ) > 0 then            pr-calc-wbill              = true .
if lookup ('Накл-безНДС':U,p-list ) > 0 then      pr-calc-wbill-novat        = true .
if lookup ('Единая':U,p-list ) > 0 then                pr-common                  = true .
if lookup ('Производит':U,p-list ) > 0 then             pr-calc-prod               = true .
if lookup ('Произв-НДС':U,p-list ) > 0 THEN         pr-calc-prod-vat           = true .
if lookup ('ПорогПр-НДС':U,p-list ) > 0 THEN       pr-calc-level-prod         = true .
if lookup ('ПорогПр+НДС':U,p-list ) > 0 THEN   pr-calc-level-prod-vat     = true .
if lookup ('Спецификация':U,p-list ) > 0 THEN           pr-calc-specif             = true .
END PROCEDURE.
