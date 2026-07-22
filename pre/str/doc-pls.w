DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE SHARED TEMP-TABLE tt-doc-pl NO-UNDO
field pl-code as integer format "99999999999"
field pl-code2 as integer format "99999999999"
field whole-send-news like ub.doc-pl.whole-send-news
field obj-type like ub.doc-pl.obj-type
field obj-code like ub.doc-pl.obj-code
field out-code like ub.doc-pl.out-code
field fact-qnty like ub.doc-pl.fact-qnty
field doc-qnty like ub.doc-pl.doc-qnty
field gds-code as integer format "99999999999"
field cli-qnty like ub.doc-pl.cli-qnty
field cli-fact-qnty like ub.doc-pl.cli-fact-qnty
field cli-doc-qnty like ub.doc-pl.cli-doc-qnty
field rest-af-qnty like ub.doc-pl.rest-af-qnty
field cli-rest-af-qnty like ub.doc-pl.cli-rest-af-qnty
field rest-bf-qnty like ub.doc-pl.rest-bf-qnty
field cli-rest-bf-qnty like ub.doc-pl.cli-rest-bf-qnty
index pi obj-type obj-code pl-code out-code gds-code
index doc out-code gds-code obj-code obj-type pl-code
index gds-code gds-code
.
define input  parameter parparentproc               as handle    no-undo .
define input  parameter p-mode                      as character no-undo .
define input  parameter p-upd-field                 as character no-undo .
define input  parameter p-upd-units                 as character no-undo .
define input  parameter p-doc-code                  like ub.trn-doc.doc-code        no-undo .
define input  parameter p-gds-code                  like ub.goods.gds-code          no-undo .
define input  parameter p-doc-line-unit-cli         like ub.doc-line.unit-cli       no-undo .
define input  parameter p-doc-line-cli-base-rate    like ub.doc-line.cli-base-rate  no-undo .
define input  parameter p-doc-line-doc-density      like ub.doc-line.doc-density    no-undo .
define input  parameter p-doc-line-fact-density     like ub.doc-line.fact-density   no-undo .
define input  parameter p-doc-line-cli-qnty         like ub.doc-line.cli-qnty       no-undo .
define input  parameter p-doc-line-doc-qnty         like ub.doc-line.doc-qnty       no-undo .
define input  parameter p-doc-line-fact-qnty        like ub.doc-line.fact-qnty      no-undo .
define input  parameter p-doc-line-doc-cli-qnty     like ub.doc-line.doc-qnty       no-undo .
define input  parameter p-doc-line-fact-cli-qnty    like ub.doc-line.fact-qnty      no-undo .
define input  parameter p-doc-line-rest-density     like ub.doc-line.fact-density   no-undo .
define input  parameter p-doc-line-rest-af-qnty     like ub.doc-pl.rest-af-qnty     no-undo .
define input  parameter p-doc-line-cli-rest-af-qnty like ub.doc-pl.cli-rest-af-qnty no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Распределение по местам хранения товара в документе":U .
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable v-mode      as character no-undo .
define variable v-upd-units as character no-undo .
define variable v-is-ptrl   as character no-undo .
define variable tt-density  as decimal   no-undo .
define variable pl-j        as integer   no-undo .
define variable par-type          as character no-undo .
define variable v-value-char      as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-rvd-own-nb      as logical   no-undo .
define variable v-tth             as handle    no-undo .
define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_pl-gds for ub.pl-gds .
define buffer buf_place  for ub.place .
define temp-table tt-info no-undo
  field info-num  as integer
  field info-type as character  FORMAT "X(29)":U label "":U
  field info-stts as character  FORMAT "X(15)":U label "":U
  field qnty      as character  FORMAT "X(16)":U label "":C16
  field cli-qnty  as character  FORMAT "X(16)":U label "":C16
  field density   as character  FORMAT "X(16)":U label "":C16
  index pi is unique primary info-num
  .
define temp-table save-tt-doc-pl no-undo like tt-doc-pl .
DEFINE BUTTON b-add DEFAULT
     LABEL "&Добавить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-chg DEFAULT
     LABEL "&Изменить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-del DEFAULT
     LABEL "&Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-lkp DEFAULT
     LABEL "&Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-GO DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-doc-line-cli-doc-qnty LIKE ub.doc-line.cli-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-cli-fact-qnty LIKE ub.doc-line.cli-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-cli-qnty LIKE ub.doc-line.cli-qnty
     LABEL "по ТТН"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-cli-rest-af-qnty LIKE ub.inv-line.after-cli-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-doc-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-doc-qnty LIKE ub.doc-line.doc-qnty
     LABEL "Заявлено"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-fact-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-fact-qnty LIKE ub.doc-line.fact-qnty
     LABEL "Фактически"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-rest-af-qnty LIKE ub.doc-line.cli-qnty
     LABEL "Стало"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-doc-line-rest-density AS DECIMAL FORMAT "->>9.9999999999":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE f-label-density AS CHARACTER FORMAT "x(25)":U INITIAL "Плотность"
     VIEW-AS FILL-IN
     SIZE 10.5 BY 1 NO-UNDO.
DEFINE VARIABLE f-pl-name LIKE ub.place.pl-name FORMAT "99999999999":U
     LABEL "Место хранения"
     VIEW-AS FILL-IN
     SIZE 80 BY 1 NO-UNDO.
DEFINE VARIABLE f-tot-doc-label AS CHARACTER FORMAT "X(256)":U INITIAL "Итого по строке документа:"
      VIEW-AS TEXT
     SIZE 27.5 BY .67 NO-UNDO.
DEFINE VARIABLE f-tot-doc-pl-cli-doc-qnty LIKE ub.doc-pl.cli-doc-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-tot-doc-pl-cli-fact-qnty LIKE ub.doc-pl.cli-fact-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-tot-doc-pl-cli-qnty LIKE ub.doc-pl.cli-qnty
     LABEL "по ТТН"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-tot-doc-pl-cli-rest-af-qnty LIKE ub.doc-pl.cli-rest-af-qnty
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-tot-doc-pl-doc-qnty LIKE ub.doc-pl.doc-qnty
     LABEL "Заявлено"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-tot-doc-pl-fact-qnty LIKE ub.doc-pl.fact-qnty
     LABEL "Фактически"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-tot-doc-pl-rest-af-qnty LIKE ub.doc-pl.rest-af-qnty
     LABEL "Стало"
     VIEW-AS FILL-IN
     SIZE 16 BY 1 NO-UNDO.
DEFINE VARIABLE f-tot-doc-pl-rest-density AS DECIMAL FORMAT "->>9.9999999999" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 13 BY 1 NO-UNDO.
DEFINE VARIABLE f-units-base LIKE ub.goods.unit-base
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE VARIABLE f-units-cli LIKE ub.goods.unit-base
     VIEW-AS FILL-IN
     SIZE 6 BY 1 NO-UNDO.
DEFINE RECTANGLE rect-tot
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 97 BY 7.
DEFINE QUERY br-doc-pl FOR
      tt-doc-pl SCROLLING.
DEFINE QUERY br-info FOR
      tt-info SCROLLING.
DEFINE BROWSE br-doc-pl
  QUERY br-doc-pl NO-LOCK DISPLAY
      tt-doc-pl.pl-code COLUMN-LABEL "Место хр." FORMAT "99999999999":U
            WIDTH 10
      tt-doc-pl.cli-qnty FORMAT "->>,>>>,>>9.<<<":U WIDTH 16
      tt-doc-pl.doc-qnty FORMAT "->>,>>>,>>9.<<<":U WIDTH 16
      tt-doc-pl.cli-doc-qnty FORMAT "->>,>>>,>>9.<<<":U WIDTH 16
      tt-doc-pl.fact-qnty FORMAT "->>,>>>,>>9.<<<":U WIDTH 16
      tt-doc-pl.cli-fact-qnty FORMAT "->>,>>>,>>9.<<<":U WIDTH 18.5
      tt-doc-pl.rest-af-qnty FORMAT "->>,>>>,>>9.<<<":U WIDTH 16
      tt-doc-pl.cli-rest-af-qnty FORMAT "->>,>>>,>>9.<<<":U WIDTH 16
      tt-density COLUMN-LABEL "Плотность" FORMAT "->>9.9999999999":U
            WIDTH 14
      tt-doc-pl.gds-code FORMAT "99999999999":U
    WITH NO-ROW-MARKERS SEPARATORS DROP-TARGET SIZE 96.5 BY 5.25 FIT-LAST-COLUMN.
DEFINE BROWSE br-info
  QUERY br-info DISPLAY
      tt-info.info-type
 tt-info.info-stts
 tt-info.qnty
 tt-info.cli-qnty
 tt-info.density
    WITH NO-ASSIGN NO-AUTO-VALIDATE NO-ROW-MARKERS SEPARATORS NO-TAB-STOP SIZE 96.5 BY 5 FIT-LAST-COLUMN.
DEFINE FRAME f-tt-doc-pl
     b-quit AT ROW 1 COL 2
     b-add AT ROW 1 COL 12 WIDGET-ID 2
     b-chg AT ROW 1 COL 22 WIDGET-ID 4
     b-lkp AT ROW 1 COL 32 WIDGET-ID 6
     b-del AT ROW 1 COL 42 WIDGET-ID 8
     b-help AT ROW 1 COL 88
     br-doc-pl AT ROW 2.25 COL 2 WIDGET-ID 200
     f-pl-name AT ROW 7.75 COL 16.5 COLON-ALIGNED HELP
          "" WIDGET-ID 24
          LABEL "Место хранения" FORMAT "X(78)"
     br-info AT ROW 9 COL 2 HELP
          "" WIDGET-ID 300
     f-units-base AT ROW 14.25 COL 45 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 20 FORMAT "X(5)"
     f-units-cli AT ROW 14.25 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 40 FORMAT "X(5)"
     f-label-density AT ROW 14.25 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 172
     f-tot-doc-pl-rest-af-qnty AT ROW 15.75 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 78
          LABEL "Стало"
     f-tot-doc-pl-cli-rest-af-qnty AT ROW 15.75 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 76
     f-tot-doc-pl-rest-density AT ROW 15.75 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 212
     f-tot-doc-pl-doc-qnty AT ROW 16.75 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 44
          LABEL "Заявлено"
     f-tot-doc-pl-cli-doc-qnty AT ROW 16.75 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 56
     f-tot-doc-pl-cli-qnty AT ROW 17 COL 16 COLON-ALIGNED HELP
          "" WIDGET-ID 74
          LABEL "по ТТН" FORMAT "->>,>>>,>>9.<<<"
     f-tot-doc-pl-fact-qnty AT ROW 17.75 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 48
          LABEL "Фактически"
     f-tot-doc-pl-cli-fact-qnty AT ROW 17.75 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 54
     f-doc-line-rest-af-qnty AT ROW 19 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 82
          LABEL "Стало"
     f-doc-line-cli-rest-af-qnty AT ROW 19 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 80
     f-doc-line-rest-density AT ROW 19 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 202
     f-doc-line-cli-qnty AT ROW 20 COL 16 COLON-ALIGNED HELP
          "" WIDGET-ID 72
          LABEL "по ТТН"
     f-doc-line-doc-qnty AT ROW 20 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 60
          LABEL "Заявлено"
     f-doc-line-cli-doc-qnty AT ROW 20 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 58
     f-doc-line-doc-density AT ROW 20 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 28
     f-doc-line-fact-qnty AT ROW 21 COL 45 COLON-ALIGNED HELP
          "" WIDGET-ID 68
          LABEL "Фактически"
     f-doc-line-cli-fact-qnty AT ROW 21 COL 61.5 COLON-ALIGNED HELP
          "" NO-LABEL WIDGET-ID 66
     f-doc-line-fact-density AT ROW 21 COL 80 COLON-ALIGNED NO-LABEL WIDGET-ID 30
     f-tot-doc-label AT ROW 19 COL 3 NO-LABEL WIDGET-ID 210
     "Итого по местам хранения" VIEW-AS TEXT
          SIZE 24.5 BY .67 AT ROW 15.75 COL 3 WIDGET-ID 52
     rect-tot AT ROW 15.5 COL 2 WIDGET-ID 50
     SPACE(0.74) SKIP(0.28)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Места хранения по документу"
         DEFAULT-BUTTON b-quit WIDGET-ID 100.
ASSIGN
       FRAME f-tt-doc-pl:SCROLLABLE       = FALSE
       FRAME f-tt-doc-pl:HIDDEN           = TRUE.
ASSIGN
       br-doc-pl:ALLOW-COLUMN-SEARCHING IN FRAME f-tt-doc-pl = TRUE
       br-doc-pl:COLUMN-RESIZABLE IN FRAME f-tt-doc-pl       = TRUE
       br-doc-pl:COLUMN-MOVABLE IN FRAME f-tt-doc-pl         = TRUE.
ASSIGN
       br-info:COLUMN-RESIZABLE IN FRAME f-tt-doc-pl       = TRUE.
ASSIGN
       f-doc-line-cli-doc-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-cli-doc-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-doc-line-cli-fact-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-cli-fact-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-doc-line-cli-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-cli-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-doc-line-cli-rest-af-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-cli-rest-af-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-doc-line-doc-density:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-doc-density:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-doc-line-doc-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-doc-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-doc-line-fact-density:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-fact-density:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-doc-line-fact-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-fact-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-doc-line-rest-af-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-rest-af-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-doc-line-rest-density:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-doc-line-rest-density:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-label-density:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-label-density:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-pl-name:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-label:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-label:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-pl-cli-doc-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-pl-cli-doc-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-pl-cli-fact-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-pl-cli-fact-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-pl-cli-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-pl-cli-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-pl-cli-rest-af-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-pl-cli-rest-af-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-pl-doc-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-pl-doc-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-pl-fact-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-pl-fact-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-pl-rest-af-qnty:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-pl-rest-af-qnty:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-tot-doc-pl-rest-density:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-tot-doc-pl-rest-density:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-units-base:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ASSIGN
       f-units-cli:HIDDEN IN FRAME f-tt-doc-pl           = TRUE
       f-units-cli:READ-ONLY IN FRAME f-tt-doc-pl        = TRUE.
ON WINDOW-CLOSE OF FRAME f-tt-doc-pl
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME f-tt-doc-pl
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
  define variable v-free-pl-list as   character         no-undo .
  define variable v-pl-code      like ub.doc-pl.pl-code no-undo .
  define variable v-pl-code2      like ub.doc-pl.pl-code no-undo .
      assign
        v-pl-code = ?
        v-pl-code2 = ?
      .
    for each save-tt-doc-pl
    on error undo, return no-apply
    :
      delete save-tt-doc-pl.
    end.
    for each tt-doc-pl
    on error undo, return no-apply
    :
      create save-tt-doc-pl.
      buffer-copy tt-doc-pl to save-tt-doc-pl .
    end.
    block_create:
    do
    on error  undo, retry
    on stop   undo, retry
    on endkey undo, retry
    :
      if retry then do:
        for each tt-doc-pl
        on error undo, return no-apply
        :
          delete tt-doc-pl .
        end.
        for each save-tt-doc-pl
        on error undo, return no-apply
        :
          create tt-doc-pl.
          buffer-copy save-tt-doc-pl to tt-doc-pl .
          delete save-tt-doc-pl.
        end.
        message
          vss-workfile vss-revision vss-description skip
          substitute("Ошибка при добавлении данных на месте хранения.") skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        leave block_create .
      end.
      if not available buf_trn-doc then
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
      .
      if buf_trn-doc.ext-doc-type = 'eo':U then do :
          run str/doc-pl-int.w
            ( input parparentproc
            , input v-mode
            , input p-upd-field
            , input v-upd-units
            , input p-doc-code
            , input p-gds-code
            , input v-pl-code
            , input v-pl-code2
            , input p-doc-line-unit-cli
            , input p-doc-line-cli-base-rate
            , input p-doc-line-doc-density
            , input p-doc-line-fact-density
            , input p-doc-line-cli-qnty
            , input p-doc-line-doc-qnty
            , input p-doc-line-fact-qnty
            , input p-doc-line-doc-cli-qnty
            , input p-doc-line-fact-cli-qnty
            , input p-doc-line-rest-density
            , input p-doc-line-rest-af-qnty
            , input p-doc-line-cli-rest-af-qnty
            ) .
      end.
      else do :
          run str/doc-pl.w
            ( input parparentproc
            , input v-mode
            , input p-upd-field
            , input v-upd-units
            , input p-doc-code
            , input p-gds-code
            , input v-pl-code
            , input p-doc-line-unit-cli
            , input p-doc-line-cli-base-rate
            , input p-doc-line-doc-density
            , input p-doc-line-fact-density
            , input p-doc-line-cli-qnty
            , input p-doc-line-doc-qnty
            , input p-doc-line-fact-qnty
            , input p-doc-line-doc-cli-qnty
            , input p-doc-line-fact-cli-qnty
            , input p-doc-line-rest-density
            , input p-doc-line-rest-af-qnty
            , input p-doc-line-cli-rest-af-qnty
            ) .
      end.
      run calc-qnty in this-procedure .
    end.
    OPEN QUERY br-doc-pl FOR EACH tt-doc-pl       WHERE tt-doc-pl.gds-code = p-gds-code NO-LOCK INDEXED-REPOSITION.
    apply "value-changed" to br-doc-pl IN FRAME f-tt-doc-pl.
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
    ).
  apply "entry" to browse br-doc-pl .
END.
ON CHOOSE OF b-chg IN FRAME f-tt-doc-pl
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
  if not available tt-doc-pl then do:
    message
      "Не выбрана строка."
      view-as alert-box.
    return no-apply.
  end.
  for each save-tt-doc-pl
  on error undo, return no-apply
  :
    delete save-tt-doc-pl.
  end.
  create save-tt-doc-pl.
  buffer-copy tt-doc-pl to save-tt-doc-pl .
  block_update:
  do
  on error  undo, retry
  on stop   undo, retry
  on endkey undo, retry
  :
    if retry then do:
      buffer-copy save-tt-doc-pl to tt-doc-pl .
      delete save-tt-doc-pl.
      message
        vss-workfile vss-revision vss-description skip
        substitute("Ошибка при изменении данных на месте хранения.") skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      leave block_update .
    end.
    if buf_trn-doc.ext-doc-type = 'eo':U then do :
        run str/doc-pl-int.w
          ( input parparentproc
          , input v-mode
          , input p-upd-field
          , input v-upd-units
          , input p-doc-code
          , input p-gds-code
          , input tt-doc-pl.pl-code
          , input tt-doc-pl.pl-code2
          , input p-doc-line-unit-cli
          , input p-doc-line-cli-base-rate
          , input p-doc-line-doc-density
          , input p-doc-line-fact-density
          , input p-doc-line-cli-qnty
          , input p-doc-line-doc-qnty
          , input p-doc-line-fact-qnty
          , input p-doc-line-doc-cli-qnty
          , input p-doc-line-fact-cli-qnty
          , input p-doc-line-rest-density
          , input p-doc-line-rest-af-qnty
          , input p-doc-line-cli-rest-af-qnty
          ) .
    end.
    else do :
        run str/doc-pl.w
          ( input parparentproc
          , input (if buf_trn-doc.ext-doc-type = 'ie':U and pl-j = 1 then 'ПРОСМОТР':U else v-mode)
          , input p-upd-field
          , input v-upd-units
          , input p-doc-code
          , input p-gds-code
          , input tt-doc-pl.pl-code
          , input p-doc-line-unit-cli
          , input p-doc-line-cli-base-rate
          , input p-doc-line-doc-density
          , input p-doc-line-fact-density
          , input p-doc-line-cli-qnty
          , input p-doc-line-doc-qnty
          , input p-doc-line-fact-qnty
          , input p-doc-line-doc-cli-qnty
          , input p-doc-line-fact-cli-qnty
          , input p-doc-line-rest-density
          , input p-doc-line-rest-af-qnty
          , input p-doc-line-cli-rest-af-qnty
          ) .
    end.
    run calc-qnty in this-procedure
      .
  end.
  delete save-tt-doc-pl .
  OPEN QUERY br-doc-pl FOR EACH tt-doc-pl       WHERE tt-doc-pl.gds-code = p-gds-code NO-LOCK INDEXED-REPOSITION.
  apply "value-changed" to br-doc-pl IN FRAME f-tt-doc-pl.
def var vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
    ).
  apply "entry" to browse br-doc-pl .
END.
ON CHOOSE OF b-del IN FRAME f-tt-doc-pl
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
  define variable v-delete as logical   no-undo .
  if v-mode = 'ПРОСМОТР':U then do:
    return no-apply .
  end.
  if not available tt-doc-pl then do:
    message
      "Не выбрана строка."
      view-as alert-box.
    return no-apply.
  end.
  message
    "Вы уверены, что хотите удалить запись?" skip
    view-as alert-box question buttons yes-no update v-delete
    .
  if v-delete = true then do:
    delete tt-doc-pl .
    OPEN QUERY br-doc-pl FOR EACH tt-doc-pl       WHERE tt-doc-pl.gds-code = p-gds-code NO-LOCK INDEXED-REPOSITION.
    apply "value-changed" to br-doc-pl IN FRAME f-tt-doc-pl.
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
    ).
  end.
  else do:
    return no-apply .
  end.
  apply "entry" to browse br-doc-pl .
END.
ON CHOOSE OF b-lkp IN FRAME f-tt-doc-pl
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
  if not available tt-doc-pl then do:
    message
      "Не выбрана строка."
      view-as alert-box.
    return no-apply.
  end.
  if buf_trn-doc.ext-doc-type = 'eo':U or buf_trn-doc.ext-doc-type = 'io':U then do :
      run str/doc-pl-int.w
        ( input parparentproc
         ,input 'ПРОСМОТР':U
         ,input p-upd-field
         ,input v-upd-units
         ,input p-doc-code
         ,input p-gds-code
         ,input tt-doc-pl.pl-code
         ,input tt-doc-pl.pl-code2
         ,input p-doc-line-unit-cli
         ,input p-doc-line-cli-base-rate
         ,input p-doc-line-doc-density
         ,input p-doc-line-fact-density
         ,input p-doc-line-cli-qnty
         ,input p-doc-line-doc-qnty
         ,input p-doc-line-fact-qnty
         ,input p-doc-line-doc-cli-qnty
         ,input p-doc-line-fact-cli-qnty
         ,input p-doc-line-rest-density
         ,input p-doc-line-rest-af-qnty
         ,input p-doc-line-cli-rest-af-qnty
        ).
  end.
  else do :
      run str/doc-pl.w
        ( input parparentproc
         ,input 'ПРОСМОТР':U
         ,input p-upd-field
         ,input v-upd-units
         ,input p-doc-code
         ,input p-gds-code
         ,input tt-doc-pl.pl-code
         ,input p-doc-line-unit-cli
         ,input p-doc-line-cli-base-rate
         ,input p-doc-line-doc-density
         ,input p-doc-line-fact-density
         ,input p-doc-line-cli-qnty
         ,input p-doc-line-doc-qnty
         ,input p-doc-line-fact-qnty
         ,input p-doc-line-doc-cli-qnty
         ,input p-doc-line-fact-cli-qnty
         ,input p-doc-line-rest-density
         ,input p-doc-line-rest-af-qnty
         ,input p-doc-line-cli-rest-af-qnty
        ).
  end.
  apply "entry" to browse br-doc-pl .
END.
ON CHOOSE OF b-quit IN FRAME f-tt-doc-pl
DO:
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
END.
ON ROW-DISPLAY OF br-doc-pl IN FRAME f-tt-doc-pl
DO:
  if tt-doc-pl.rest-af-qnty <> 0.0
    and tt-doc-pl.cli-rest-af-qnty <> 0.0
  then do:
    assign
      tt-density = tt-doc-pl.cli-rest-af-qnty / tt-doc-pl.rest-af-qnty
    .
  end.
  else do:
    assign
      tt-density = p-doc-line-rest-density
    .
  end.
END.
ON VALUE-CHANGED OF br-doc-pl IN FRAME f-tt-doc-pl
DO:
  define variable v-state-measure-qnty     like ub.rvs-line.state-measure-qnty     no-undo .
  define variable v-measure-qnty           like ub.rvs-line.measure-qnty           no-undo .
  define variable v-state-measure-cli-qnty like ub.rvs-line.state-measure-cli-qnty no-undo .
  define variable v-measure-cli-qnty       like ub.rvs-line.measure-cli-qnty       no-undo .
  define variable v-rvs-state-density      like ub.rvs-line.state-density          no-undo .
  define variable v-rvs-density            like ub.rvs-line.density                no-undo .
  define variable v-label                  as   character                          no-undo .
  for each tt-info
  :
    delete tt-info .
  end.
  if available tt-doc-pl then do:
    find first buf_place no-lock
      where buf_place.obj-code = tt-doc-pl.obj-code
        and buf_place.obj-type = tt-doc-pl.obj-type
        and buf_place.pl-code  = tt-doc-pl.pl-code
      no-error
      .
    if available buf_place then do:
      display
        buf_place.pl-name @ f-pl-name
        with frame f-tt-doc-pl
        .
    end.
    find first buf_pl-gds no-lock
      where buf_pl-gds.obj-code = tt-doc-pl.obj-code
        and buf_pl-gds.obj-type = tt-doc-pl.obj-type
        and buf_pl-gds.pl-code  = tt-doc-pl.pl-code
        and buf_pl-gds.gds-code = tt-doc-pl.gds-code
      no-error .
    if available buf_pl-gds then do:
      create tt-info .
      assign
        tt-info.info-num  = 1
        tt-info.info-type = "Остаток РКн"
        tt-info.info-stts = "(свободно)"
        tt-info.qnty      = string( buf_pl-gds.free-qnty, "->>,>>>,>>9.999":U )
        tt-info.cli-qnty  = string( buf_pl-gds.cli-free-qnty, "->>,>>>,>>9.999":U )
        tt-info.density   = string( (buf_pl-gds.cli-free-qnty / buf_pl-gds.free-qnty), "->>9.9999999999":U )
      .
      create tt-info .
      assign
        tt-info.info-num  = 2
        tt-info.info-stts = "(фактически)"
        tt-info.qnty      = string( buf_pl-gds.fact-qnty, "->>,>>>,>>9.999":U )
        tt-info.cli-qnty  = string( buf_pl-gds.cli-fact-qnty, "->>,>>>,>>9.999":U )
        tt-info.density   = string( buf_pl-gds.cli-fact-qnty / buf_pl-gds.fact-qnty, "->>9.9999999999":U )
      .
    end.
    run get-from-rvs in this-procedure
      ( input  tt-doc-pl.out-code
       ,input  tt-doc-pl.gds-code
       ,input  tt-doc-pl.pl-code
       ,output v-state-measure-qnty
       ,output v-measure-qnty
       ,output v-state-measure-cli-qnty
       ,output v-measure-cli-qnty
       ,output v-rvs-state-density
       ,output v-rvs-density
       ,output v-label
      ) no-error .
    if v-label <> "":U then do:
      create tt-info .
      assign
        tt-info.info-num  = 3
        tt-info.info-type = v-label
        tt-info.info-stts = "(измерено)"
        tt-info.qnty      = string( v-measure-qnty, "->>,>>>,>>9.999":U )
        tt-info.cli-qnty  = string( v-measure-cli-qnty, "->>,>>>,>>9.999":U )
        tt-info.density   = string( v-rvs-density, "->>9.9999999999":U )
      .
      create tt-info .
      assign
        tt-info.info-num  = 4
        tt-info.info-stts = "(фактически)"
        tt-info.qnty      = string( v-state-measure-qnty, "->>,>>>,>>9.999":U )
        tt-info.cli-qnty  = string( v-state-measure-cli-qnty, "->>,>>>,>>9.999":U )
        tt-info.density   = string( v-rvs-state-density, "->>9.9999999999":U )
      .
    end.
  end.
  OPEN QUERY br-info FOR EACH tt-info .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME f-tt-doc-pl:PARENT eq ?
THEN FRAME f-tt-doc-pl:PARENT = ACTIVE-WINDOW.
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  procedure disp-total :
    define input  parameter p-add-cli-qnty         like ub.doc-pl.cli-qnty         no-undo .
    define input  parameter p-add-doc-qnty         like ub.doc-pl.doc-qnty         no-undo .
    define input  parameter p-add-cli-doc-qnty     like ub.doc-pl.cli-doc-qnty     no-undo .
    define input  parameter p-add-fact-qnty        like ub.doc-pl.fact-qnty        no-undo .
    define input  parameter p-add-cli-fact-qnty    like ub.doc-pl.cli-fact-qnty    no-undo .
    define input  parameter p-add-rest-af-qnty     like ub.doc-pl.rest-af-qnty     no-undo .
    define input  parameter p-add-cli-rest-af-qnty like ub.doc-pl.cli-rest-af-qnty no-undo .
    assign
      f-tot-doc-pl-cli-qnty         = p-add-cli-qnty
      f-tot-doc-pl-doc-qnty         = p-add-doc-qnty
      f-tot-doc-pl-cli-doc-qnty     = p-add-cli-doc-qnty
      f-tot-doc-pl-fact-qnty        = p-add-fact-qnty
      f-tot-doc-pl-cli-fact-qnty    = p-add-cli-fact-qnty
      f-tot-doc-pl-rest-af-qnty     = p-add-rest-af-qnty
      f-tot-doc-pl-cli-rest-af-qnty = p-add-cli-rest-af-qnty
    .
    for each tt-doc-pl no-lock
    :
      assign
        f-tot-doc-pl-cli-qnty         = f-tot-doc-pl-cli-qnty         + tt-doc-pl.cli-qnty
        f-tot-doc-pl-doc-qnty         = f-tot-doc-pl-doc-qnty         + tt-doc-pl.doc-qnty
        f-tot-doc-pl-cli-doc-qnty     = f-tot-doc-pl-cli-doc-qnty     + tt-doc-pl.cli-doc-qnty
        f-tot-doc-pl-fact-qnty        = f-tot-doc-pl-fact-qnty        + tt-doc-pl.fact-qnty
        f-tot-doc-pl-cli-fact-qnty    = f-tot-doc-pl-cli-fact-qnty    + tt-doc-pl.cli-fact-qnty
        f-tot-doc-pl-rest-af-qnty     = f-tot-doc-pl-rest-af-qnty     + tt-doc-pl.rest-af-qnty
        f-tot-doc-pl-cli-rest-af-qnty = f-tot-doc-pl-cli-rest-af-qnty + tt-doc-pl.cli-rest-af-qnty
      .
    end.
    if f-tot-doc-pl-rest-af-qnty <> 0.0
      and f-tot-doc-pl-cli-rest-af-qnty <> 0.0
    then do:
      assign
        f-tot-doc-pl-rest-density = f-tot-doc-pl-cli-rest-af-qnty / f-tot-doc-pl-rest-af-qnty
      .
    end.
    else do:
      assign
        f-tot-doc-pl-rest-density = p-doc-line-rest-density
      .
    end.
    display
      f-tot-doc-pl-cli-qnty         when f-tot-doc-pl-cli-qnty         :visible = true
      f-tot-doc-pl-doc-qnty         when f-tot-doc-pl-doc-qnty         :visible = true
      f-tot-doc-pl-cli-doc-qnty     when f-tot-doc-pl-cli-doc-qnty     :visible = true
      f-tot-doc-pl-fact-qnty        when f-tot-doc-pl-fact-qnty        :visible = true
      f-tot-doc-pl-cli-fact-qnty    when f-tot-doc-pl-cli-fact-qnty    :visible = true
      f-tot-doc-pl-rest-af-qnty     when f-tot-doc-pl-rest-af-qnty     :visible = true
      f-tot-doc-pl-cli-rest-af-qnty when f-tot-doc-pl-cli-rest-af-qnty :visible = true
      f-tot-doc-pl-rest-density     when f-tot-doc-pl-rest-density     :visible = true
      with frame f-tt-doc-pl
    .
    if f-tot-doc-pl-doc-qnty :visible = true
      and f-doc-line-doc-qnty :visible = true
    then do:
      if ( p-upd-units = "base":U
          and f-tot-doc-pl-doc-qnty <> f-doc-line-doc-qnty
        )
        or
        ( p-upd-units = "cli":U
          and absolute( f-tot-doc-pl-doc-qnty - f-doc-line-doc-qnty ) > 0.001
        )
      then do:
        assign
          f-tot-doc-pl-doc-qnty :fgcolor = 12
          f-doc-line-doc-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-doc-qnty :fgcolor = ?
          f-doc-line-doc-qnty   :fgcolor = ?
        .
      end.
    end.
    if f-tot-doc-pl-cli-doc-qnty :visible = true
      and f-doc-line-cli-doc-qnty :visible = true
    then do:
      if ( p-upd-units = "base":U
          and absolute( f-tot-doc-pl-cli-doc-qnty - f-doc-line-cli-doc-qnty ) > 0.001
         )
         or
         ( p-upd-units = "cli":U
           and f-tot-doc-pl-cli-doc-qnty <> f-doc-line-cli-doc-qnty
         )
      then do:
        assign
          f-tot-doc-pl-cli-doc-qnty :fgcolor = 12
          f-doc-line-cli-doc-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-cli-doc-qnty :fgcolor = ?
          f-doc-line-cli-doc-qnty   :fgcolor = ?
        .
      end.
    end.
    if f-tot-doc-pl-cli-qnty :visible = true
      and f-doc-line-cli-qnty :visible = true
    then do:
      if ( p-upd-units = "base":U
          and absolute( f-tot-doc-pl-cli-qnty - f-doc-line-cli-qnty ) > 0.001
         )
         or
         ( p-upd-units = "cli":U
           and f-tot-doc-pl-cli-qnty <> f-doc-line-cli-qnty
         )
      then do:
        assign
          f-tot-doc-pl-cli-qnty :fgcolor = 12
          f-doc-line-cli-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-cli-qnty :fgcolor = ?
          f-doc-line-cli-qnty   :fgcolor = ?
        .
      end.
    end.
    if f-tot-doc-pl-fact-qnty :visible = true
      and f-doc-line-fact-qnty :visible = true
    then do:
      if f-tot-doc-pl-fact-qnty <> f-doc-line-fact-qnty then do:
        assign
          f-tot-doc-pl-fact-qnty :fgcolor = 12
          f-doc-line-fact-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-fact-qnty :fgcolor = ?
          f-doc-line-fact-qnty   :fgcolor = ?
        .
      end.
    end.
    if f-tot-doc-pl-cli-fact-qnty :visible = true
      and f-doc-line-cli-fact-qnty :visible = true
    then do:
      if absolute( f-tot-doc-pl-cli-fact-qnty - f-doc-line-cli-fact-qnty ) > 0.001 then do:
        assign
          f-tot-doc-pl-cli-fact-qnty :fgcolor = 12
          f-doc-line-cli-fact-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-cli-fact-qnty :fgcolor = ?
          f-doc-line-cli-fact-qnty   :fgcolor = ?
        .
      end.
    end.
    if f-tot-doc-pl-rest-af-qnty :visible = true
      and f-doc-line-rest-af-qnty :visible = true
    then do:
      if f-tot-doc-pl-rest-af-qnty <> f-doc-line-rest-af-qnty then do:
        assign
          f-tot-doc-pl-rest-af-qnty :fgcolor = 12
          f-doc-line-rest-af-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-rest-af-qnty :fgcolor = ?
          f-doc-line-rest-af-qnty   :fgcolor = ?
        .
      end.
    end.
    if f-tot-doc-pl-cli-rest-af-qnty :visible = true
      and f-doc-line-cli-rest-af-qnty :visible = true
    then do:
      if absolute( f-tot-doc-pl-cli-rest-af-qnty - f-doc-line-cli-rest-af-qnty ) > 0.001 then do:
        assign
          f-tot-doc-pl-cli-rest-af-qnty :fgcolor = 12
          f-doc-line-cli-rest-af-qnty   :fgcolor = 12
        .
      end.
      else do:
        assign
          f-tot-doc-pl-cli-rest-af-qnty :fgcolor = ?
          f-doc-line-cli-rest-af-qnty   :fgcolor = ?
        .
      end.
    end.
  end procedure.
  procedure get-from-rvs :
    define input  parameter p-doc-code               like ub.trn-doc.doc-code                no-undo .
    define input  parameter p-gds-code               like ub.rvs-line.gds-code               no-undo .
    define input  parameter p-pl-code                like ub.rvs-line.pl-code                no-undo .
    define output parameter p-state-measure-qnty     like ub.rvs-line.state-measure-qnty     no-undo .
    define output parameter p-measure-qnty           like ub.rvs-line.measure-qnty           no-undo .
    define output parameter p-state-measure-cli-qnty like ub.rvs-line.state-measure-cli-qnty no-undo .
    define output parameter p-measure-cli-qnty       like ub.rvs-line.measure-cli-qnty       no-undo .
    define output parameter p-state-density          like ub.rvs-line.state-density          no-undo .
    define output parameter p-measure-density        like ub.rvs-line.density                no-undo .
    define output parameter p-label                  as   character                          no-undo .
    do
    on error  undo, return error substitute( "&1 (disp-from-rvs). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    on stop   undo, return error substitute( "&1 (disp-from-rvs). stop", vss-workfile )
    on endkey undo, return error substitute( "&1 (disp-from-rvs). endkey", vss-workfile )
    :
      define buffer rvs_trn-doc  for ub.trn-doc .
      define buffer bef_rvs-doc  for ub.rvs-doc  .
      define buffer aft_rvs-doc  for ub.rvs-doc  .
      define buffer bef_rvs-line for ub.rvs-line .
      define buffer aft_rvs-line for ub.rvs-line .
      assign
        p-state-measure-qnty     = 0
        p-measure-qnty           = 0
        p-state-measure-cli-qnty = 0
        p-measure-cli-qnty       = 0
        p-label                  = "":U
      .
      case buf_trn-doc.doc-type :
        when 'при':U then do:
          for each bef_rvs-doc no-lock
            where bef_rvs-doc.out-code  = p-doc-code
              and bef_rvs-doc.rvs-type  = 'перед_док':U
          :
            for each bef_rvs-line no-lock
              where bef_rvs-line.rvs-code = bef_rvs-doc.rvs-code
                and bef_rvs-line.obj-type = bef_rvs-doc.obj-type
                and bef_rvs-line.obj-code = bef_rvs-doc.obj-code
                and bef_rvs-line.pl-code  = p-pl-code
                and bef_rvs-line.gds-code = p-gds-code
            :
              assign
                p-state-measure-qnty     = p-state-measure-qnty     - bef_rvs-line.state-measure-qnty
                p-measure-qnty           = p-measure-qnty           - bef_rvs-line.measure-qnty
                p-state-measure-cli-qnty = p-state-measure-cli-qnty - bef_rvs-line.state-measure-cli-qnty
                p-measure-cli-qnty       = p-measure-cli-qnty       - bef_rvs-line.measure-cli-qnty
              .
            end .
          end .
          for each aft_rvs-doc no-lock
            where aft_rvs-doc.out-code  = p-doc-code
              and aft_rvs-doc.rvs-type  = 'после_док':U
          :
            for each aft_rvs-line no-lock
              where aft_rvs-line.rvs-code = aft_rvs-doc.rvs-code
                and aft_rvs-line.obj-type = aft_rvs-doc.obj-type
                and aft_rvs-line.obj-code = aft_rvs-doc.obj-code
                and aft_rvs-line.pl-code  = p-pl-code
                and aft_rvs-line.gds-code = p-gds-code
            :
              assign
                p-state-measure-qnty     = p-state-measure-qnty     + aft_rvs-line.state-measure-qnty
                p-measure-qnty           = p-measure-qnty           + aft_rvs-line.measure-qnty
                p-state-measure-cli-qnty = p-state-measure-cli-qnty + aft_rvs-line.state-measure-cli-qnty
                p-measure-cli-qnty       = p-measure-cli-qnty       + aft_rvs-line.measure-cli-qnty
              .
            end.
          end .
          assign
            p-state-density          = p-state-measure-cli-qnty / p-state-measure-qnty
            p-measure-density        = p-measure-cli-qnty / p-measure-qnty
          .
          assign
            p-label = "По сверкам":U
          .
        end.
        when 'инв':U then do:
          find first rvs_trn-doc no-lock
            where rvs_trn-doc.doc-code = p-doc-code
            .
          find first bef_rvs-doc no-lock
            where bef_rvs-doc.rvs-code = rvs_trn-doc.out-code
            no-error .
          if available bef_rvs-doc then do:
            assign
              p-label = "По сверке":U
            .
            find first bef_rvs-line no-lock
              where bef_rvs-line.rvs-code = bef_rvs-doc.rvs-code
                and bef_rvs-line.obj-type = bef_rvs-doc.obj-type
                and bef_rvs-line.obj-code = bef_rvs-doc.obj-code
                and bef_rvs-line.pl-code  = p-pl-code
                and bef_rvs-line.gds-code = p-gds-code
              no-error .
            if available bef_rvs-line then do:
              assign
                p-state-measure-qnty     = bef_rvs-line.state-measure-qnty
                p-measure-qnty           = bef_rvs-line.measure-qnty
                p-state-measure-cli-qnty = bef_rvs-line.state-measure-cli-qnty
                p-measure-cli-qnty       = bef_rvs-line.measure-cli-qnty
                p-state-density          = bef_rvs-line.state-density
                p-measure-density        = bef_rvs-line.density
              .
            end.
          end.
        end.
      end case.
    end.
  end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define variable v-add-mode1     as   character         no-undo .
  define variable v-av-place      as   logical           no-undo .
  define variable v-pl-code       like ub.doc-pl.pl-code no-undo .
  define variable v-single-place  as   logical           no-undo .
  define variable v-chk-qnty      as   decimal           no-undo .
  define variable v-new-qnty      as   decimal           no-undo .
  define variable v-column-handle as   handle            no-undo .
  define variable v-for-upd-units as   character         no-undo .
  define variable v-loc1          like ub.place.loc1     no-undo .
  define variable v-pl-fact-qnty  as   decimal           no-undo .
  define variable v-pl-cli-fact-qnty  as   decimal       no-undo .
  assign
    p-doc-line-cli-base-rate    = p-doc-line-cli-base-rate
    p-doc-line-doc-density      = p-doc-line-doc-density
    p-doc-line-fact-density     = p-doc-line-fact-density
    p-doc-line-cli-qnty         = p-doc-line-cli-qnty
    p-doc-line-doc-qnty         = p-doc-line-doc-qnty
    p-doc-line-fact-qnty        = p-doc-line-fact-qnty
    p-doc-line-doc-cli-qnty     = p-doc-line-doc-cli-qnty
    p-doc-line-fact-cli-qnty    = p-doc-line-fact-cli-qnty
    p-doc-line-rest-density     = p-doc-line-rest-density
    p-doc-line-rest-af-qnty     = p-doc-line-rest-af-qnty
    p-doc-line-cli-rest-af-qnty = p-doc-line-cli-rest-af-qnty
  .
  assign
    v-mode = entry( 1, p-mode, chr(4) )
  .
  if num-entries( p-mode, chr(4) ) >= 2
  then do:
    assign
      v-add-mode1 = entry( 2, p-mode, chr(4) )
    .
  end.
  assign
    v-upd-units     = p-upd-units
    v-for-upd-units = p-upd-units
  .
  pl-j = 0.
  for each tt-doc-pl no-lock:
    pl-j = pl-j + 1.
  end.
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    .
  if buf_trn-doc.ext-doc-type = 'io':U then do :
      br-doc-pl:handle:add-like-column ("tt-doc-pl.pl-code2", 1) .
      br-doc-pl:handle:get-browse-column (1):label = "Место хр. c" .
      br-doc-pl:handle:get-browse-column (2):label = "Место хр. на" .
      br-doc-pl:handle:get-browse-column (1):width-chars = 11 .
      br-doc-pl:handle:get-browse-column (2):width-chars = 12 .
      br-doc-pl:handle:get-browse-column (3):width-chars = 12 .
      br-doc-pl:handle:get-browse-column (4):width-chars = 13 .
      br-doc-pl:handle:get-browse-column (5):width-chars = 14 .
      br-doc-pl:handle:get-browse-column (6):width-chars = 15 .
      br-doc-pl:handle:get-browse-column (7):width-chars = 16 .
  end.
  if buf_trn-doc.ext-doc-type = 'eo':U then do :
      br-doc-pl:handle:add-like-column ("tt-doc-pl.pl-code2", 2) .
      br-doc-pl:handle:get-browse-column (1):label = "Место хр. c" .
      br-doc-pl:handle:get-browse-column (2):label = "Место хр. на" .
      br-doc-pl:handle:get-browse-column (1):width-chars = 11 .
      br-doc-pl:handle:get-browse-column (2):width-chars = 12 .
      br-doc-pl:handle:get-browse-column (3):width-chars = 12 .
      br-doc-pl:handle:get-browse-column (4):width-chars = 13 .
      br-doc-pl:handle:get-browse-column (5):width-chars = 14 .
      br-doc-pl:handle:get-browse-column (6):width-chars = 15 .
      br-doc-pl:handle:get-browse-column (7):width-chars = 16 .
  end.
  if p-upd-field = "doc":U then do:
    assign
      p-doc-line-fact-cli-qnty = p-doc-line-doc-cli-qnty
      p-doc-line-fact-qnty     = p-doc-line-doc-qnty
    .
  end.
def var vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-data-type as character no-undo .
  define variable is-petrol   as logical   no-undo .
  define variable is-pieces   as logical   no-undo .
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
  .
  assign
    f-units-base = "(" + trim( buf_goods.unit-base ) + ")"
    f-units-cli  = "(" + trim( buf_goods.unit-cli ) + ")"
    f-label-density = "Плотность"
  .
  assign
    f-doc-line-doc-density      = p-doc-line-doc-density
    f-doc-line-fact-density     = p-doc-line-fact-density
    f-doc-line-rest-density     = p-doc-line-rest-density
    f-doc-line-cli-qnty         = p-doc-line-cli-qnty
    f-doc-line-doc-qnty         = p-doc-line-doc-qnty
    f-doc-line-cli-doc-qnty     = p-doc-line-doc-cli-qnty
    f-doc-line-fact-qnty        = p-doc-line-fact-qnty
    f-doc-line-cli-fact-qnty    = p-doc-line-fact-cli-qnty
    f-doc-line-rest-af-qnty     = p-doc-line-rest-af-qnty
    f-doc-line-cli-rest-af-qnty = p-doc-line-cli-rest-af-qnty
  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-ptrl':U
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-is-ptrl
  ,output v-data-type
  ) no-error .
  if error-status :error
    or v-data-type <> "L":U
    or lookup( v-is-ptrl, "yes,no":U ) = 0
  then do:
    assign
      v-is-ptrl = "no":U
    .
  end.
  if v-is-ptrl = "yes":U then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
    if error-status :error
      or v-is-ptrl <> "yes"
      or is-petrol <>  yes
      or is-pieces <>  no
    then do:
      assign
        v-is-ptrl = "no":U
      .
    end.
    else do:
      assign
        v-is-ptrl = "yes":U
      .
    end.
  end.
  assign
    v-av-place     = false
    v-single-place = false
    v-pl-code      = ?
  .
  if num-entries( p-mode, chr(4) ) >= 3
  then do:
    if entry(3, p-mode, chr(4) ) begins "place"
    then do :
      v-loc1 = entry(2, entry(3, p-mode, chr(4)), "=") .
      for first buf_place no-lock where buf_place.obj-code = buf_trn-doc.obj-code
                                    and buf_place.obj-type = buf_trn-doc.obj-type
                                    and buf_place.loc1 = v-loc1
                                    and buf_place.status_ <> 'удал':U,
      first buf_pl-gds no-lock where buf_pl-gds.obj-code = buf_trn-doc.obj-code
                                 and buf_pl-gds.obj-type = buf_trn-doc.obj-type
                                 and buf_pl-gds.gds-code = p-gds-code
                                 and buf_pl-gds.pl-code = buf_place.pl-code
                                 :
        assign
          v-av-place     = true
          v-single-place = true
          v-pl-code      = buf_place.pl-code
        .
      end .
    end .
  end .
  if v-pl-code = ?
  then do :
    block_check-pl-gds :
    for each buf_pl-gds no-lock
      where buf_pl-gds.obj-code = buf_trn-doc.obj-code
        and buf_pl-gds.obj-type = buf_trn-doc.obj-type
        and buf_pl-gds.gds-code = p-gds-code
    on error undo, return error return-value
    :
      assign
        v-av-place = true
      .
      if v-single-place = false then do:
        assign
          v-pl-code      = buf_pl-gds.pl-code
          v-single-place = true
        .
      end.
      else do:
        assign
          v-single-place = false
        .
        leave block_check-pl-gds .
      end.
    end.
  end .
  if v-add-mode1 <> "":U then do:
    case v-add-mode1 :
      when "update-dens":U
      or when "update-dens-cli":U
      or when "update-dens-base":U
      then do:
        if v-single-place
        then do :
          find first tt-doc-pl
            where tt-doc-pl.gds-code = p-gds-code
              and tt-doc-pl.obj-code = buf_trn-doc.obj-code
              and tt-doc-pl.obj-type = buf_trn-doc.obj-type
              and tt-doc-pl.pl-code  = v-pl-code
              and tt-doc-pl.out-code = buf_trn-doc.doc-code
            no-error .
        end .
        else do :
          find first tt-doc-pl
            where tt-doc-pl.gds-code = p-gds-code
              and tt-doc-pl.obj-code = buf_trn-doc.obj-code
              and tt-doc-pl.obj-type = buf_trn-doc.obj-type
              and tt-doc-pl.out-code = buf_trn-doc.doc-code
            no-error .
        end .
        if available tt-doc-pl then do:
          case v-add-mode1 :
            when "update-dens-cli":U then do:
              assign
                v-upd-units     = "cli":U
                v-for-upd-units = "base":U
              .
            end.
            when "update-dens-base":U then do:
              assign
                v-upd-units     = "base":U
                v-for-upd-units = "cli":U
              .
            end.
          end case.
          pl-j = 0.
          for each tt-doc-pl
            where tt-doc-pl.gds-code = p-gds-code
              and tt-doc-pl.obj-code = buf_trn-doc.obj-code
              and tt-doc-pl.obj-type = buf_trn-doc.obj-type
              and tt-doc-pl.out-code = buf_trn-doc.doc-code
              and ((v-single-place and tt-doc-pl.pl-code = v-pl-code) or not v-single-place)
          on error undo, return error return-value
          :
            if p-upd-field = "rest":U
              or p-upd-field = "rest-fact":U
            then do:
              pl-j = pl-j + 1.
            end.
            else do:
              if v-for-upd-units = "base":U then do:
                if p-upd-field = "doc":U
                  or p-upd-field = "fact-doc":U
                then do:
                  assign
                    tt-doc-pl.cli-doc-qnty  = tt-doc-pl.doc-qnty * p-doc-line-doc-density
                  .
                end.
                assign
                  tt-doc-pl.cli-fact-qnty = tt-doc-pl.fact-qnty * p-doc-line-fact-density
                .
              end.
              else do:
                if p-upd-field = "doc":U
                  or p-upd-field = "fact-doc":U
                then do:
                  assign
                    tt-doc-pl.doc-qnty = tt-doc-pl.cli-doc-qnty / p-doc-line-doc-density
                  .
                end.
                assign
                  tt-doc-pl.fact-qnty = tt-doc-pl.cli-fact-qnty / p-doc-line-fact-density
                .
              end.
              if p-upd-field = "doc":U
                or p-upd-field = "fact-doc":U
              then do:
                assign
                  tt-doc-pl.cli-qnty = tt-doc-pl.doc-qnty / p-doc-line-cli-base-rate
                .
                if abs(tt-doc-pl.cli-qnty - tt-doc-pl.cli-doc-qnty) < 0.0011
                then do :
                  assign
                    tt-doc-pl.cli-qnty = tt-doc-pl.cli-doc-qnty
                  .
                end .
              end.
            end.
          end.
          if v-mode = 'АВТОИЗМЕНЕНИЕ':U
            and ( v-single-place = true
                  or ( v-single-place = false
                      and v-add-mode1 = "update-dens":U
                    )
                )
          then do:
            return .
          end.
        end.
      end.
      when "calc-qnty":U then do:
        run calc-qnty in this-procedure .
        if v-mode = 'АВТОИЗМЕНЕНИЕ':U then do:
          return .
        end.
      end.
    end case.
  end.
  if v-mode <> 'ПРОСМОТР':U
    and p-upd-field <> "rest":U
    and p-upd-field <> "rest-fact":U
    and buf_trn-doc.status_ <> 'факт':U
  then do:
    if v-av-place = true then do:
      if v-single-place = true then do:
        find first tt-doc-pl
          where tt-doc-pl.gds-code = p-gds-code
            and tt-doc-pl.obj-code = buf_trn-doc.obj-code
            and tt-doc-pl.obj-type = buf_trn-doc.obj-type
            and tt-doc-pl.out-code = buf_trn-doc.doc-code
            and tt-doc-pl.pl-code  = v-pl-code
          no-error .
        if not available tt-doc-pl then do:
          create tt-doc-pl .
          assign
            tt-doc-pl.gds-code               = p-gds-code
            tt-doc-pl.obj-code               = buf_trn-doc.obj-code
            tt-doc-pl.obj-type               = buf_trn-doc.obj-type
            tt-doc-pl.out-code               = buf_trn-doc.doc-code
            tt-doc-pl.pl-code                = v-pl-code
          .
        end.
        assign
          tt-doc-pl.cli-qnty         = p-doc-line-cli-qnty
          tt-doc-pl.cli-doc-qnty     = p-doc-line-doc-cli-qnty
          tt-doc-pl.doc-qnty         = p-doc-line-doc-qnty
          tt-doc-pl.cli-fact-qnty    = p-doc-line-fact-cli-qnty
          tt-doc-pl.fact-qnty        = p-doc-line-fact-qnty
          tt-doc-pl.rest-af-qnty     = p-doc-line-rest-af-qnty
          tt-doc-pl.cli-rest-af-qnty = p-doc-line-cli-rest-af-qnty
        .
        case p-upd-field :
          when "doc":U then do:
            assign
              v-chk-qnty = tt-doc-pl.doc-qnty
            .
          end.
          when "fact":U
          or when "fact-doc":U
          then do:
            assign
              v-chk-qnty = tt-doc-pl.fact-qnty
            .
          end.
        end case.
        if v-chk-qnty <> 0.0 then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_chkqnpl in g#lib-trn3
  (  input buf_trn-doc.doc-type
  ,  input tt-doc-pl.obj-type
  ,  input tt-doc-pl.obj-code
  ,  input tt-doc-pl.pl-code
  ,  input tt-doc-pl.gds-code
  ,  input true
  ,  input v-chk-qnty
  , output v-new-qnty
  )
  .
          if v-chk-qnty <> v-new-qnty then do:
            case p-upd-field :
              when "doc":U then do:
                assign
                  tt-doc-pl.doc-qnty      = v-new-qnty
                  tt-doc-pl.cli-qnty      = tt-doc-pl.doc-qnty / p-doc-line-cli-base-rate
                  tt-doc-pl.cli-doc-qnty  = tt-doc-pl.doc-qnty * p-doc-line-doc-density
                  tt-doc-pl.cli-fact-qnty = tt-doc-pl.cli-doc-qnty
                  tt-doc-pl.fact-qnty     = tt-doc-pl.doc-qnty
                .
              end.
              when "fact":U then do:
                assign
                  tt-doc-pl.fact-qnty     = v-new-qnty
                  tt-doc-pl.cli-fact-qnty = tt-doc-pl.fact-qnty * p-doc-line-fact-density
                .
              end.
              when "fact-doc":U  then do:
                assign
                  tt-doc-pl.fact-qnty     = v-new-qnty
                  tt-doc-pl.cli-fact-qnty = tt-doc-pl.fact-qnty * p-doc-line-fact-density
                  tt-doc-pl.doc-qnty      = tt-doc-pl.fact-qnty * p-doc-line-doc-qnty / p-doc-line-fact-qnty
                  tt-doc-pl.cli-qnty      = tt-doc-pl.doc-qnty / p-doc-line-cli-base-rate
                  tt-doc-pl.cli-doc-qnty  = tt-doc-pl.doc-qnty * p-doc-line-doc-density
                .
              end.
            end case.
          end.
        end.
        if v-mode = 'АВТОИЗМЕНЕНИЕ':U then do:
          return .
        end.
      end.
      if v-mode = 'АВТОИЗМЕНЕНИЕ':U then do:
        assign
          v-pl-fact-qnty      = 0
          v-pl-cli-fact-qnty  = 0
        .
        for each tt-doc-pl :
          assign
            v-pl-fact-qnty = v-pl-fact-qnty + tt-doc-pl.fact-qnty
            v-pl-cli-fact-qnty = v-pl-cli-fact-qnty + tt-doc-pl.cli-fact-qnty
          .
        end .
        if abs(p-doc-line-fact-qnty - v-pl-fact-qnty) <= 0.001
        and abs(p-doc-line-fact-cli-qnty - v-pl-cli-fact-qnty) <= 0.001
        then do :
          return .
        end .
      end.
    end.
    else do:
      message
        substitute( "Товара &1 не привязан к месту хранения", p-gds-code ) skip
        substitute( "на объекте &1 &2.", buf_trn-doc.obj-type, buf_trn-doc.obj-code ) skip
        view-as alert-box error.
      return error .
    end.
  end.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame f-tt-doc-pl
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
on choose of b-help in frame f-tt-doc-pl
do:
  apply "help":u to frame f-tt-doc-pl .
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame f-tt-doc-pl:width - 0.3
                fh            = frame f-tt-doc-pl:first-child
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
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame f-tt-doc-pl :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame f-tt-doc-pl :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame f-tt-doc-pl :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame f-tt-doc-pl :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame f-tt-doc-pl :height = v-frame-height
          .
          if frame f-tt-doc-pl :scrollable = true
          then do:
            assign
              frame f-tt-doc-pl :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame f-tt-doc-pl :scrollable = true
          then do:
            assign
              frame f-tt-doc-pl :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame f-tt-doc-pl :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame f-tt-doc-pl :height
      v-frame-virtual-height = frame f-tt-doc-pl :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame f-tt-doc-pl :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame f-tt-doc-pl
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame f-tt-doc-pl :scrollable = true
      then do:
        assign
          frame f-tt-doc-pl :virtual-height = frame f-tt-doc-pl :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame f-tt-doc-pl :height = frame f-tt-doc-pl :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame f-tt-doc-pl :height = frame f-tt-doc-pl :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame f-tt-doc-pl :scrollable = true
      then do:
        assign
          frame f-tt-doc-pl :virtual-height = frame f-tt-doc-pl :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame f-tt-doc-pl :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame f-tt-doc-pl :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame f-tt-doc-pl :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame f-tt-doc-pl :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame f-tt-doc-pl :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame f-tt-doc-pl :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame f-tt-doc-pl :width = v-frame-width
          .
          if frame f-tt-doc-pl :scrollable = true
          then do:
            assign
              frame f-tt-doc-pl :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame f-tt-doc-pl :scrollable = true
          then do:
            assign
              frame f-tt-doc-pl :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame f-tt-doc-pl :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame f-tt-doc-pl :width
      v-frame-virtual-width = frame f-tt-doc-pl :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame f-tt-doc-pl :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame f-tt-doc-pl
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame f-tt-doc-pl :scrollable = true
      then do:
        assign
          frame f-tt-doc-pl :virtual-width = frame f-tt-doc-pl :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame f-tt-doc-pl :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame f-tt-doc-pl :width = frame f-tt-doc-pl :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame f-tt-doc-pl :scrollable = true
      then do:
        assign
          frame f-tt-doc-pl :virtual-width = frame f-tt-doc-pl :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame f-tt-doc-pl :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame f-tt-doc-pl :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame f-tt-doc-pl
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame f-tt-doc-pl :height - v-diasize-resize-button :height
                  - 1
                  - (frame f-tt-doc-pl :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame f-tt-doc-pl :width - v-diasize-resize-button :width
                  - 1
                  - (frame f-tt-doc-pl :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame f-tt-doc-pl
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame f-tt-doc-pl :height
      v-col-delta = v-new-col - frame f-tt-doc-pl :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame f-tt-doc-pl :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame f-tt-doc-pl :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame f-tt-doc-pl :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame f-tt-doc-pl :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame f-tt-doc-pl :width
      v-diasize-current-frame-height = frame f-tt-doc-pl :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame f-tt-doc-pl
    :
      assign
        v-diasize-orig-frame-height = frame f-tt-doc-pl :height
        v-diasize-orig-frame-width  = frame f-tt-doc-pl :width
        v-diasize-browse-handle     = browse br-doc-pl :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame f-tt-doc-pl :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
  RUN enable_UI.
  assign
    frame f-tt-doc-pl :title = substitute("Распределение по местам хранения товара &1 в документе &2", p-gds-code, p-doc-code )
    tt-doc-pl.gds-code  :visible in browse br-doc-pl = false
    tt-info.qnty        :label in browse br-info = f-units-base
    tt-info.cli-qnty    :label in browse br-info = f-units-cli
    tt-info.density     :label in browse br-info = f-label-density
  .
def var vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  if buf_goods.unit-base <> buf_goods.unit-cli then do:
    display
      f-units-cli
      with frame f-tt-doc-pl.
    if v-is-ptrl = "yes":U then do:
      display
        f-label-density
        with frame f-tt-doc-pl.
    end.
  end.
  if buf_trn-doc.doc-type = 'при':U
    and buf_trn-doc.internal = false
  then do:
    assign
      f-doc-line-cli-qnty :label in frame f-tt-doc-pl = substitute( "по ТТН (&1)", p-doc-line-unit-cli )
      f-tot-doc-pl-cli-qnty :label in frame f-tt-doc-pl = substitute( "по ТТН (&1)", p-doc-line-unit-cli )
    .
    display
      f-doc-line-cli-qnty
      f-tot-doc-pl-cli-qnty
      with frame f-tt-doc-pl
    .
  end.
  case p-upd-field :
    when "rest":U
    or when "rest-fact":U
    then do:
      if p-upd-field = "rest":U then do:
        assign
          f-tot-doc-pl-rest-af-qnty     :bgcolor = 8
          f-tot-doc-pl-cli-rest-af-qnty :bgcolor = 8
          f-tot-doc-pl-rest-density     :bgcolor = 8
        .
      end.
      else do:
        assign
          f-tot-doc-pl-fact-qnty     :bgcolor = 8
          f-tot-doc-pl-cli-fact-qnty :bgcolor = 8
        .
      end.
      assign
        f-tot-doc-pl-fact-qnty        :label in frame f-tt-doc-pl = substitute( "Разница" )
        f-tot-doc-pl-rest-af-qnty     :row in frame f-tt-doc-pl   = f-tot-doc-pl-doc-qnty :row in frame f-tt-doc-pl
        f-tot-doc-pl-rest-af-qnty     :handle :side-label-handle :row in frame f-tt-doc-pl = f-tot-doc-pl-doc-qnty :row in frame f-tt-doc-pl
        f-tot-doc-pl-cli-rest-af-qnty :row in frame f-tt-doc-pl   = f-tot-doc-pl-rest-af-qnty :row in frame f-tt-doc-pl
        f-tot-doc-pl-rest-density     :row in frame f-tt-doc-pl   = f-tot-doc-pl-rest-af-qnty :row in frame f-tt-doc-pl
        rect-tot :height-chars in frame f-tt-doc-pl = 3.5
        frame f-tt-doc-pl :height-chars = frame f-tt-doc-pl :height-chars - 3.5
      .
      display
        f-tot-doc-pl-fact-qnty
        f-tot-doc-pl-cli-fact-qnty    when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-pl-rest-af-qnty
        f-tot-doc-pl-cli-rest-af-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-pl-rest-density     when buf_goods.unit-base <> buf_goods.unit-cli
        with frame f-tt-doc-pl.
        .
    end.
    when "doc":U then do:
      assign
        f-tot-doc-pl-doc-qnty     :bgcolor = 8
        f-tot-doc-pl-cli-doc-qnty :bgcolor = 8
        f-doc-line-doc-qnty       :bgcolor = 8
        f-doc-line-cli-doc-qnty   :bgcolor = 8
        f-doc-line-doc-density    :bgcolor = 8
      .
      display
        f-tot-doc-pl-doc-qnty
        f-tot-doc-pl-cli-doc-qnty  when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-label
        f-doc-line-doc-qnty
        f-doc-line-cli-doc-qnty    when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-line-doc-density     when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame f-tt-doc-pl
        .
    end.
    when "fact":U then do:
      assign
        f-tot-doc-pl-fact-qnty     :bgcolor = 8
        f-tot-doc-pl-cli-fact-qnty :bgcolor = 8
        f-doc-line-fact-qnty       :bgcolor = 8
        f-doc-line-cli-fact-qnty   :bgcolor = 8
        f-doc-line-fact-density    :bgcolor = 8
      .
      display
        f-tot-doc-pl-doc-qnty
        f-tot-doc-pl-fact-qnty
        f-tot-doc-pl-cli-doc-qnty  when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-pl-cli-fact-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-label
        f-doc-line-doc-qnty
        f-doc-line-fact-qnty
        f-doc-line-cli-doc-qnty    when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-line-cli-fact-qnty   when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-line-doc-density     when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-line-fact-density    when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame f-tt-doc-pl
        .
    end.
    when "fact-doc":U then do:
      assign
        f-tot-doc-pl-fact-qnty     :bgcolor = 8
        f-tot-doc-pl-cli-fact-qnty :bgcolor = 8
        f-doc-line-fact-qnty       :bgcolor = 8
        f-doc-line-cli-fact-qnty   :bgcolor = 8
        f-doc-line-fact-density    :bgcolor = 8
      .
      display
        f-tot-doc-pl-fact-qnty
        f-tot-doc-pl-cli-fact-qnty when buf_goods.unit-base <> buf_goods.unit-cli
        f-tot-doc-label
        f-doc-line-fact-qnty
        f-doc-line-cli-fact-qnty   when buf_goods.unit-base <> buf_goods.unit-cli
        f-doc-line-fact-density    when v-is-ptrl = "yes":U and buf_goods.unit-base <> buf_goods.unit-cli
        with frame f-tt-doc-pl
        .
    end.
  end case.
  OPEN QUERY br-doc-pl FOR EACH tt-doc-pl       WHERE tt-doc-pl.gds-code = p-gds-code NO-LOCK INDEXED-REPOSITION.
  if p-upd-field = "rest":U
    or p-upd-field = "rest-fact":U
  then do:
    assign
      tt-doc-pl.cli-qnty         :visible in browse br-doc-pl = false
      tt-doc-pl.cli-doc-qnty     :visible in browse br-doc-pl = false
      tt-doc-pl.doc-qnty         :visible in browse br-doc-pl = false
      tt-doc-pl.cli-fact-qnty    :label in browse br-doc-pl = "Разница" + chr(32) + f-units-cli
      tt-doc-pl.fact-qnty        :label in browse br-doc-pl = "Разница" + chr(32) + f-units-base
      tt-doc-pl.cli-rest-af-qnty :label in browse br-doc-pl = "Стало" + chr(32) + f-units-cli
      tt-doc-pl.rest-af-qnty     :label in browse br-doc-pl = "Стало" + chr(32) + f-units-base
    .
  end.
  else do:
    assign
      tt-doc-pl.cli-qnty         :label in browse br-doc-pl = tt-doc-pl.cli-qnty  :label in browse br-doc-pl + chr(32) + "(" + trim( p-doc-line-unit-cli ) + ")"
      tt-doc-pl.cli-doc-qnty     :label in browse br-doc-pl = tt-doc-pl.doc-qnty  :label in browse br-doc-pl + chr(32) + f-units-cli
      tt-doc-pl.doc-qnty         :label in browse br-doc-pl = tt-doc-pl.doc-qnty  :label in browse br-doc-pl + chr(32) + f-units-base
      tt-doc-pl.cli-fact-qnty    :label in browse br-doc-pl = tt-doc-pl.fact-qnty :label in browse br-doc-pl + chr(32) + f-units-cli
      tt-doc-pl.fact-qnty        :label in browse br-doc-pl = tt-doc-pl.fact-qnty :label in browse br-doc-pl + chr(32) + f-units-base
      tt-doc-pl.cli-rest-af-qnty :visible in browse br-doc-pl = false
      tt-doc-pl.rest-af-qnty     :visible in browse br-doc-pl = false
    .
  end.
  if buf_goods.unit-base = buf_goods.unit-cli then do:
    assign
      tt-doc-pl.cli-doc-qnty     :visible in browse br-doc-pl = false
      tt-doc-pl.cli-fact-qnty    :visible in browse br-doc-pl = false
      tt-doc-pl.cli-rest-af-qnty :visible in browse br-doc-pl = false
      tt-info.cli-qnty           :visible in browse br-info   = false
      tt-info.density            :visible in browse br-info   = false
    .
  end.
  if ( p-upd-field <> "rest":U
       and p-upd-field <> "rest-fact":U
     )
    or buf_goods.unit-base = buf_goods.unit-cli
  then do:
    assign
      v-column-handle = browse br-doc-pl :handle :first-column
    .
    do while v-column-handle <> ?
    :
      if v-column-handle :label = "Плотность" then do:
        assign
          v-column-handle :visible = false
        .
        leave.
      end.
      assign
        v-column-handle = v-column-handle :next-column
      .
    end.
  end.
  if v-mode <> 'ПРОСМОТР':U
    and buf_trn-doc.status_ <> 'факт':U
  then do:
    enable
      b-chg
      with frame f-tt-doc-pl .
    if p-upd-field = "doc":U
      or p-upd-field = "fact-doc":U
    then do:
      if v-mode <> 'iv':U
      then do :
        enable
          b-add
          b-del
        with frame f-tt-doc-pl .
      end .
      if v-mode = 'АВТОИЗМЕНЕНИЕ':U
        and v-single-place = true
      then do:
        apply "choose" to b-add in frame f-tt-doc-pl.
      end.
    end.
  end.
  apply "value-changed" to br-doc-pl in frame f-tt-doc-pl.
def var vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run disp-total in this-procedure
    ( input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
     ,input 0.0
    ).
  apply "entry" to br-doc-pl IN FRAME f-tt-doc-pl.
  find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
      .
  run adm/shattri.p (
             input "get":U
            ,input  buf_trn-doc.obj-type
            ,input  buf_trn-doc.obj-code
            ,input  'petrol':U
            ,input  'rvd-own-nb':U
            ,output v-value-char
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-rvd-own-nb
            ,output par-type
            ,input-output table-handle v-tth
            ) no-error .
  if error-status:error then do:
      if valid-object(v-tth) then delete object v-tth.
      v-rvd-own-nb = false .
  end.
  if v-rvd-own-nb = false
  and buf_trn-doc.cli-code > 0
  then do :
    find first ub.clients-attr no-lock where ub.clients-attr.obj-type = buf_trn-doc.cli-type
                                         and ub.clients-attr.obj-code = buf_trn-doc.cli-code
                                         and ub.clients-attr.attr-code = 'owner-code':U
                                         no-error .
    if available ub.clients-attr
    and ub.clients-attr.attr-value > ""
    then do :
      if ub.clients-attr.attr-value = "орг" + string(buf_trn-doc.host-code)
      then do :
        disable b-add b-chg b-del with frame f-tt-doc-pl.
      end .
    end .
  end .
  WAIT-FOR GO OF FRAME f-tt-doc-pl.
END.
RUN disable_UI.
PROCEDURE calc-qnty :
  do
  on error  undo, return error substitute( "&1 (calc-qnty). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (calc-qnty). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (calc-qnty). endkey", vss-workfile )
  :
    define variable v-count-doc-pl         as integer   no-undo .
    define variable v-null-fact-qnty       as logical   no-undo .
    define variable v-tot-fact-qnty        as decimal   no-undo .
    define variable v-correct-cli-qnty     as decimal   no-undo .
    define variable v-correct-doc-qnty     as decimal   no-undo .
    define variable v-correct-cli-doc-qnty as decimal   no-undo .
    if p-upd-field = "fact-doc":U then do:
      assign
        v-null-fact-qnty       = false
        v-count-doc-pl         = 0
        v-tot-fact-qnty        = 0.0
        v-correct-cli-qnty     = p-doc-line-cli-qnty
        v-correct-doc-qnty     = p-doc-line-doc-qnty
        v-correct-cli-doc-qnty = p-doc-line-doc-cli-qnty
      .
      for each tt-doc-pl
      on error  undo, return error substitute( "&1 (tt-doc-pl). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
      on stop   undo, return error substitute( "&1 (tt-doc-pl). stop", vss-workfile )
      on endkey undo, return error substitute( "&1 (tt-doc-pl). endkey", vss-workfile )
      :
        if tt-doc-pl.fact-qnty = 0.0 then do:
          assign
            v-null-fact-qnty = true
          .
        end.
        assign
          v-tot-fact-qnty        = v-tot-fact-qnty + tt-doc-pl.fact-qnty
          v-count-doc-pl         = v-count-doc-pl + 1
          tt-doc-pl.doc-qnty     = tt-doc-pl.fact-qnty * p-doc-line-doc-qnty / p-doc-line-fact-qnty
          tt-doc-pl.cli-qnty     = tt-doc-pl.doc-qnty / p-doc-line-cli-base-rate
          tt-doc-pl.cli-doc-qnty = tt-doc-pl.doc-qnty * p-doc-line-doc-density
          v-correct-cli-qnty     = v-correct-cli-qnty     - tt-doc-pl.cli-qnty
          v-correct-doc-qnty     = v-correct-doc-qnty     - tt-doc-pl.doc-qnty
          v-correct-cli-doc-qnty = v-correct-cli-doc-qnty - tt-doc-pl.cli-doc-qnty
        .
        if absolute( v-correct-cli-qnty ) <= 0.001 then do:
          assign
            tt-doc-pl.cli-qnty = tt-doc-pl.cli-qnty + v-correct-cli-qnty
          .
        end.
        if absolute( v-correct-doc-qnty ) <= 0.001 then do:
          assign
            tt-doc-pl.doc-qnty = tt-doc-pl.doc-qnty + v-correct-doc-qnty
          .
        end.
        if absolute( v-correct-cli-doc-qnty ) <= 0.001 then do:
          assign
            tt-doc-pl.cli-doc-qnty = tt-doc-pl.cli-doc-qnty + v-correct-cli-doc-qnty
          .
        end.
      end.
      if v-null-fact-qnty = true then do:
        if v-count-doc-pl = 1 then do:
          find first tt-doc-pl .
          assign
            tt-doc-pl.doc-qnty     = p-doc-line-doc-qnty
            tt-doc-pl.cli-qnty     = tt-doc-pl.doc-qnty / p-doc-line-cli-base-rate
            tt-doc-pl.cli-doc-qnty = tt-doc-pl.doc-qnty * p-doc-line-doc-density
          .
        end.
        else do:
          if v-tot-fact-qnty = 0.0 then do:
            return error substitute( "Если необходимо задавать нулевое кол-во, то это допустимо только при выборе одного места хранения!" ) .
          end.
          else do:
            return error substitute( "На одном из мест хранения задано нулевое кол-во, добавление других мест недопустимо!" ) .
          end.
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME f-tt-doc-pl.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-pl-name f-units-base
      WITH FRAME f-tt-doc-pl.
  ENABLE b-quit b-lkp b-help br-doc-pl br-info
      WITH FRAME f-tt-doc-pl.
  VIEW FRAME f-tt-doc-pl.
  OPEN QUERY br-doc-pl FOR EACH tt-doc-pl       WHERE tt-doc-pl.gds-code = p-gds-code NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
