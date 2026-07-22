CREATE WIDGET-POOL.
define temp-table temp-dates no-undo
field dates as date
index pi is unique primary   dates .
define input        parameter p-buttons  as character no-undo .
define input        parameter p-title    as character no-undo .
define input        parameter h-callback as handle    no-undo .
define input-output parameter p-date     as date      no-undo .
define output       parameter p-ok       as logical   no-undo .
define input-output parameter table for  temp-dates append   .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "выбор несколько дат".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
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
define variable v-date         as date no-undo .
define variable v-curr-day     as integer no-undo .
define variable v-month-begin as date no-undo .
define variable v-curr-month  as integer no-undo .
define variable v-curr-year   as integer no-undo .
define variable v-last-day    as integer no-undo .
define variable v-month-offset as integer no-undo .
define variable v-day-handle   as handle no-undo extent 42 .
define variable v-rect-handle  as handle no-undo extent 42 .
define variable v-old-mode as logical no-undo .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-next-month
     LABEL "&>>"
     SIZE 4 BY 1.
DEFINE BUTTON b-next-year
     LABEL "&>>"
     SIZE 4 BY 1.
DEFINE BUTTON b-prev-month
     LABEL "&<<"
     SIZE 4 BY 1.
DEFINE BUTTON b-prev-year
     LABEL "&<<"
     SIZE 4 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE CB-Month AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Месяц"
     VIEW-AS COMBO-BOX INNER-LINES 12
     LIST-ITEMS "         1","         2","         3","         4","         5","         6","         7","         8","         9","        10","        11","        12"
     DROP-DOWN-LIST
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE FI-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
      VIEW-AS TEXT
     SIZE 14 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-10 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-11 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-12 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-13 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-14 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-15 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-16 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-17 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-18 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-19 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-20 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-21 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-22 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-23 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-24 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-25 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-26 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-27 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-28 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-29 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-3 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-30 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-31 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-32 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-33 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-34 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-35 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-36 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-37 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-38 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-39 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-4 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-40 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-41 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-42 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-5 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-6 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-7 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-8 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-day-9 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-header-1 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-header-2 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-header-3 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-header-4 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-header-5 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-header-6 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE FI-header-7 AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 3.25 BY .67 NO-UNDO.
DEFINE VARIABLE fi-month-name AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 28.5 BY .67 NO-UNDO.
DEFINE VARIABLE FI-Year AS INTEGER FORMAT "9999":U INITIAL 0
     LABEL "Год"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-11
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-12
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-14
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-15
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-16
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-17
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-18
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-19
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-20
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-21
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-22
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-23
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-24
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-25
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-26
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-27
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-28
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-29
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-30
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-31
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-32
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-33
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-34
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-35
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-36
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-37
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-38
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-39
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-40
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-41
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-42
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-6
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 6 BY 1.67.
DEFINE FRAME D-Dialog
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 50.5
     CB-Month AT ROW 3.58 COL 10.5 COLON-ALIGNED
     b-prev-month AT ROW 3.58 COL 20.75
     b-next-month AT ROW 3.58 COL 24.75
     FI-Year AT ROW 4.83 COL 10.5 COLON-ALIGNED
     b-prev-year AT ROW 4.92 COL 20.75
     b-next-year AT ROW 4.92 COL 24.75
     FI-date AT ROW 2.5 COL 10.5 COLON-ALIGNED
     fi-month-name AT ROW 3.75 COL 28 COLON-ALIGNED NO-LABEL
     FI-header-1 AT ROW 6.33 COL 5.25 COLON-ALIGNED NO-LABEL
     FI-header-2 AT ROW 6.33 COL 12.25 COLON-ALIGNED NO-LABEL
     FI-header-3 AT ROW 6.33 COL 19 COLON-ALIGNED NO-LABEL
     FI-header-4 AT ROW 6.33 COL 25.75 COLON-ALIGNED NO-LABEL
     FI-header-5 AT ROW 6.33 COL 32.75 COLON-ALIGNED NO-LABEL
     FI-header-6 AT ROW 6.33 COL 39.5 COLON-ALIGNED NO-LABEL
     FI-header-7 AT ROW 6.33 COL 46.25 COLON-ALIGNED NO-LABEL
     FI-day-1 AT ROW 8.08 COL 5.5 COLON-ALIGNED NO-LABEL
     FI-day-2 AT ROW 8.08 COL 12.5 COLON-ALIGNED NO-LABEL
     FI-day-3 AT ROW 8.08 COL 19.25 COLON-ALIGNED NO-LABEL
     FI-day-4 AT ROW 8.08 COL 26.25 COLON-ALIGNED NO-LABEL
     FI-day-5 AT ROW 8.08 COL 33 COLON-ALIGNED NO-LABEL
     FI-day-6 AT ROW 8.08 COL 39.75 COLON-ALIGNED NO-LABEL
     FI-day-7 AT ROW 8.08 COL 46.75 COLON-ALIGNED NO-LABEL
     FI-day-8 AT ROW 10 COL 5.5 COLON-ALIGNED NO-LABEL
     FI-day-9 AT ROW 10 COL 12.5 COLON-ALIGNED NO-LABEL
     FI-day-10 AT ROW 10 COL 19.25 COLON-ALIGNED NO-LABEL
     FI-day-11 AT ROW 10 COL 26.25 COLON-ALIGNED NO-LABEL
     FI-day-12 AT ROW 10 COL 33 COLON-ALIGNED NO-LABEL
     FI-day-13 AT ROW 10 COL 39.75 COLON-ALIGNED NO-LABEL
     FI-day-14 AT ROW 10 COL 46.75 COLON-ALIGNED NO-LABEL
     FI-day-15 AT ROW 12 COL 5.5 COLON-ALIGNED NO-LABEL
     FI-day-16 AT ROW 12 COL 12.5 COLON-ALIGNED NO-LABEL
     FI-day-17 AT ROW 12 COL 19.25 COLON-ALIGNED NO-LABEL
     FI-day-18 AT ROW 12 COL 26.25 COLON-ALIGNED NO-LABEL
     FI-day-19 AT ROW 12 COL 33 COLON-ALIGNED NO-LABEL
     FI-day-20 AT ROW 12 COL 39.75 COLON-ALIGNED NO-LABEL
     FI-day-21 AT ROW 12 COL 46.75 COLON-ALIGNED NO-LABEL
     FI-day-22 AT ROW 13.92 COL 5.5 COLON-ALIGNED NO-LABEL
     FI-day-23 AT ROW 13.92 COL 12.5 COLON-ALIGNED NO-LABEL
     FI-day-24 AT ROW 13.92 COL 19.25 COLON-ALIGNED NO-LABEL
     FI-day-25 AT ROW 13.92 COL 26.25 COLON-ALIGNED NO-LABEL
     FI-day-26 AT ROW 13.92 COL 33 COLON-ALIGNED NO-LABEL
     FI-day-27 AT ROW 13.92 COL 39.75 COLON-ALIGNED NO-LABEL
     FI-day-28 AT ROW 13.92 COL 46.75 COLON-ALIGNED NO-LABEL
     FI-day-29 AT ROW 15.83 COL 5.5 COLON-ALIGNED NO-LABEL
     FI-day-30 AT ROW 15.83 COL 12.5 COLON-ALIGNED NO-LABEL
     FI-day-31 AT ROW 15.83 COL 19.25 COLON-ALIGNED NO-LABEL
     FI-day-32 AT ROW 15.83 COL 26.25 COLON-ALIGNED NO-LABEL
     FI-day-33 AT ROW 15.83 COL 33 COLON-ALIGNED NO-LABEL
     FI-day-34 AT ROW 15.83 COL 39.75 COLON-ALIGNED NO-LABEL
     FI-day-35 AT ROW 15.83 COL 46.75 COLON-ALIGNED NO-LABEL
     FI-day-36 AT ROW 17.83 COL 5.5 COLON-ALIGNED NO-LABEL
     FI-day-37 AT ROW 17.83 COL 12.5 COLON-ALIGNED NO-LABEL
     FI-day-38 AT ROW 17.83 COL 19.25 COLON-ALIGNED NO-LABEL
     FI-day-39 AT ROW 17.83 COL 26.25 COLON-ALIGNED NO-LABEL
     FI-day-40 AT ROW 17.83 COL 33 COLON-ALIGNED NO-LABEL
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
DEFINE FRAME D-Dialog
     FI-day-41 AT ROW 17.83 COL 39.75 COLON-ALIGNED NO-LABEL
     FI-day-42 AT ROW 17.83 COL 46.75 COLON-ALIGNED NO-LABEL
     RECT-1 AT ROW 7.58 COL 6
     RECT-42 AT ROW 17.33 COL 47.25
     RECT-41 AT ROW 17.33 COL 40.25
     RECT-40 AT ROW 17.33 COL 33.5
     RECT-39 AT ROW 17.33 COL 26.75
     RECT-38 AT ROW 17.33 COL 19.75
     RECT-37 AT ROW 17.33 COL 13
     RECT-36 AT ROW 17.33 COL 6
     RECT-35 AT ROW 15.33 COL 47.25
     RECT-11 AT ROW 9.5 COL 26.75
     RECT-34 AT ROW 15.33 COL 40.25
     RECT-33 AT ROW 15.33 COL 33.5
     RECT-32 AT ROW 15.33 COL 26.75
     RECT-31 AT ROW 15.33 COL 19.75
     RECT-30 AT ROW 15.33 COL 13
     RECT-29 AT ROW 15.33 COL 6
     RECT-28 AT ROW 13.42 COL 47.25
     RECT-27 AT ROW 13.42 COL 40.25
     RECT-26 AT ROW 13.42 COL 33.5
     RECT-25 AT ROW 13.42 COL 26.75
     RECT-24 AT ROW 13.42 COL 19.75
     RECT-23 AT ROW 13.42 COL 13
     RECT-22 AT ROW 13.42 COL 6
     RECT-21 AT ROW 11.5 COL 47.25
     RECT-20 AT ROW 11.5 COL 40.25
     RECT-19 AT ROW 11.5 COL 33.5
     RECT-18 AT ROW 11.5 COL 26.75
     RECT-17 AT ROW 11.5 COL 19.75
     RECT-16 AT ROW 11.5 COL 13
     RECT-15 AT ROW 11.5 COL 6
     RECT-14 AT ROW 9.5 COL 47.25
     RECT-13 AT ROW 9.5 COL 40.25
     RECT-12 AT ROW 9.5 COL 33.5
     RECT-10 AT ROW 9.5 COL 19.75
     RECT-9 AT ROW 9.5 COL 13
     RECT-8 AT ROW 9.5 COL 6
     RECT-7 AT ROW 7.58 COL 47.25
     RECT-6 AT ROW 7.58 COL 40.25
     RECT-5 AT ROW 7.58 COL 33.5
     RECT-4 AT ROW 7.58 COL 26.75
     RECT-3 AT ROW 7.58 COL 19.75
     RECT-2 AT ROW 7.58 COL 13
     SPACE(41.87) SKIP(11.78)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Введите месяц и год"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
DEFINE VAR adm-object-hdl       AS HANDLE NO-UNDO.
DEFINE VAR adm-query-opened        AS LOGICAL NO-UNDO INIT NO.
DEFINE VAR adm-row-avail-state     AS LOGICAL NO-UNDO INIT ?.
DEFINE VAR adm-initial-lock        AS CHARACTER NO-UNDO INIT "NO-LOCK":U.
DEFINE VAR adm-new-record          AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-updating-record     AS LOGICAL NO-UNDO INIT no.
DEFINE VAR adm-check-modified-all  AS LOGICAL NO-UNDO INIT no.
DEFINE NEW GLOBAL SHARED VAR adm-broker-hdl    AS HANDLE  NO-UNDO.
    ASSIGN adm-object-hdl = FRAME D-Dialog:HANDLE.
RUN ensure-broker.
THIS-PROCEDURE:ADM-DATA =
     'ADM1.1~`':U +
     'SmartDialog~`':U +
     'DIALOG-BOX~`':U +
     'NO ~`':U +
     '~`':U +
     '~`':U +
     '~`':U +
     (IF adm-object-hdl = ? THEN "":U ELSE STRING(adm-object-hdl))
        + "~`":U +
     'Layout,Hide-on-Init~`':U +
     '~`':U +
     '~`':U +
     '~`~`~`~`~`~`~`~`~`~`~`':U +
     IF THIS-PROCEDURE:ADM-DATA = "":U OR THIS-PROCEDURE:ADM-DATA = ?
         THEN "^^":U
     ELSE "^":U + ENTRY(2, THIS-PROCEDURE:ADM-DATA, "^":U) +
          "^":U + ENTRY(3, THIS-PROCEDURE:ADM-DATA, "^":U).
PROCEDURE adm-apply-entry :
  RUN broker-apply-entry IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-destroy :
 RUN broker-destroy IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-disable :
    DISABLE b-exit b-quit b-help CB-Month b-prev-month b-next-month FI-Year b-prev-year b-next-year fi-month-name WITH FRAME D-Dialog.
    RUN dispatch ('disable-fields':U).
    RUN set-attribute-list ('ENABLED=no':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-edit-attribute-list :
      RUN adm/support/contnrd.w (INPUT THIS-PROCEDURE).
      RETURN.
END PROCEDURE.
PROCEDURE adm-enable :
    ENABLE UNLESS-HIDDEN b-exit b-quit b-help CB-Month b-prev-month b-next-month FI-Year b-prev-year b-next-year fi-month-name WITH FRAME D-Dialog.
    RUN enable_UI IN THIS-PROCEDURE NO-ERROR.
    RUN set-attribute-list ('ENABLED=yes':U).
    RETURN.
END PROCEDURE.
PROCEDURE adm-exit :
     RUN notify ('exit':U).
  RETURN.
END PROCEDURE.
PROCEDURE adm-hide :
  RUN broker-hide IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-initialize :
  RUN broker-initialize IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-show-errors :
    DEFINE VARIABLE        cntr                  AS INTEGER   NO-UNDO.
    DO cntr = 1 TO ERROR-STATUS:NUM-MESSAGES:
        MESSAGE ERROR-STATUS:GET-MESSAGE(cntr).
    END.
    RETURN.
END PROCEDURE.
PROCEDURE adm-UIB-mode :
  RUN broker-UIB-mode IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE adm-view :
  RUN broker-view IN adm-broker-hdl (THIS-PROCEDURE) NO-ERROR.
END PROCEDURE.
PROCEDURE dispatch :
    DEFINE INPUT PARAMETER p-method-name    AS CHARACTER NO-UNDO.
    RUN broker-dispatch IN adm-broker-hdl
        (THIS-PROCEDURE, p-method-name) NO-ERROR.
    IF RETURN-VALUE = "ADM-ERROR":U THEN RETURN "ADM-ERROR":U.
END PROCEDURE.
PROCEDURE ensure-broker :
RUN get-attribute IN adm-broker-hdl ('TYPE':U) NO-ERROR.
IF RETURN-VALUE NE "ADM-Broker":U THEN
DO:
    RUN adm/objects/broker.p PERSISTENT set adm-broker-hdl.
    RUN set-broker-owner IN adm-broker-hdl (THIS-PROCEDURE).
END.
END PROCEDURE.
PROCEDURE get-attribute :
  DEFINE INPUT PARAMETER p-attr-name    AS CHARACTER NO-UNDO.
  RUN broker-get-attribute IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-name) NO-ERROR.
  RETURN RETURN-VALUE.
END PROCEDURE.
PROCEDURE get-attribute-list :
  DEFINE OUTPUT PARAMETER p-attr-list AS CHARACTER NO-UNDO.
  RUN broker-get-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE,
       INPUT ?,
       OUTPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE new-state :
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
  RUN broker-new-state IN adm-broker-hdl (THIS-PROCEDURE, p-state) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE notify :
  DEFINE INPUT PARAMETER p-method AS CHARACTER NO-UNDO.
  RUN broker-notify IN adm-broker-hdl (THIS-PROCEDURE, p-method) NO-ERROR.
  IF RETURN-VALUE = "ADM-ERROR":U THEN
      RETURN "ADM-ERROR":U.
  RETURN.
END PROCEDURE.
PROCEDURE set-attribute-list :
  DEFINE INPUT PARAMETER p-attr-list    AS CHARACTER NO-UNDO.
  RUN ensure-broker.
  RUN broker-set-attribute-list IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-attr-list) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE set-position :
    DEFINE INPUT PARAMETER p-row    AS DECIMAL NO-UNDO.
    DEFINE INPUT PARAMETER p-col    AS DECIMAL NO-UNDO.
    IF VALID-HANDLE(adm-object-hdl) THEN
    DO:
        DEFINE VARIABLE parent-hdl AS HANDLE NO-UNDO.
        IF adm-object-hdl:TYPE = "WINDOW":U THEN
        DO:
          IF p-row = 0 THEN p-row =
            (SESSION:HEIGHT-CHARS - adm-object-hdl:HEIGHT-CHARS) / 2.
          IF p-col = 0 THEN p-col =
            (SESSION:WIDTH-CHARS - adm-object-hdl:WIDTH-CHARS) / 2.
        END.
        ELSE IF adm-object-hdl:TYPE = "DIALOG-BOX":U THEN
        DO:
          parent-hdl = adm-object-hdl:PARENT.
          IF p-row = 0 THEN p-row =
            ((SESSION:HEIGHT-CHARS - adm-object-hdl:HEIGHT-CHARS) / 2) -
              parent-hdl:ROW.
          IF p-col = 0 THEN p-col =
            ((SESSION:WIDTH-CHARS - adm-object-hdl:WIDTH-CHARS) / 2) -
              parent-hdl:COL.
        END.
        IF p-row GE 0 AND p-row < 1 THEN p-row = 1.
        IF p-col GE 0 AND p-col < 1 THEN p-col = 1.
      ASSIGN adm-object-hdl:ROW    =   p-row
             adm-object-hdl:COLUMN =   p-col.
    END.
    RETURN.
END PROCEDURE.
RUN set-attribute-list ("CURRENT-PAGE=0,ADM-OBJECT-HANDLE=":U +
    STRING(adm-object-hdl)).
PAUSE 0 BEFORE-HIDE.
PROCEDURE adm-change-page :
  RUN broker-change-page IN adm-broker-hdl (INPUT THIS-PROCEDURE) NO-ERROR.
  END PROCEDURE.
PROCEDURE delete-page :
  DEFINE INPUT PARAMETER p-page# AS INTEGER NO-UNDO.
  RUN broker-delete-page IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-page#).
  END PROCEDURE.
PROCEDURE init-object :
  DEFINE INPUT PARAMETER  p-proc-name   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER  p-parent-hdl  AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER  p-attr-list   AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-proc-hdl    AS HANDLE    NO-UNDO.
  RUN broker-init-object IN adm-broker-hdl
      (INPUT THIS-PROCEDURE, INPUT p-proc-name, INPUT p-parent-hdl,
       INPUT p-attr-list, OUTPUT p-proc-hdl) NO-ERROR.
  RETURN.
END PROCEDURE.
PROCEDURE init-pages :
  DEFINE INPUT PARAMETER p-page-list      AS CHARACTER NO-UNDO.
  RUN broker-init-pages IN adm-broker-hdl (INPUT THIS-PROCEDURE,
      INPUT p-page-list) NO-ERROR.
  END PROCEDURE.
PROCEDURE select-page :
  DEFINE INPUT PARAMETER p-page#     AS INTEGER   NO-UNDO.
  RUN broker-select-page IN adm-broker-hdl (INPUT THIS-PROCEDURE,
      INPUT p-page#) NO-ERROR.
  END PROCEDURE.
PROCEDURE view-page :
  DEFINE INPUT PARAMETER p-page#      AS INTEGER   NO-UNDO.
  RUN broker-view-page IN adm-broker-hdl (INPUT THIS-PROCEDURE,
      INPUT p-page#).
  END PROCEDURE.
ASSIGN
       FRAME D-Dialog:SCROLLABLE       = FALSE
       FRAME D-Dialog:HIDDEN           = TRUE.
ASSIGN
       FI-day-1:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-10:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-11:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-12:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-13:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-14:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-15:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-16:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-17:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-18:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-19:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-2:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-20:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-21:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-22:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-23:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-24:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-25:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-26:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-27:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-28:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-29:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-3:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-30:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-31:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-32:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-33:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-34:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-35:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-36:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-37:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-38:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-39:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-4:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-40:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-41:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-42:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-5:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-6:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-7:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-8:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       FI-day-9:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-1:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-10:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-11:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-12:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-13:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-14:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-15:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-16:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-17:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-18:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-19:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-2:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-20:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-21:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-22:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-23:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-24:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-25:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-26:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-27:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-28:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-29:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-3:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-30:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-31:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-32:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-33:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-34:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-35:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-36:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-37:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-38:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-39:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-4:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-40:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-41:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-42:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-5:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-6:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-7:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-8:HIDDEN IN FRAME D-Dialog           = TRUE.
ASSIGN
       RECT-9:HIDDEN IN FRAME D-Dialog           = TRUE.
ON GO OF FRAME D-Dialog
DO:
  define variable v-new-month as integer no-undo .
  define variable v-new-day   as integer no-undo .
  define variable v-new-year  as integer no-undo .
  assign
    v-new-month = integer (cb-month :screen-value)
    v-new-year  = integer (fi-year  :screen-value)
    v-new-day   = v-curr-day
  .
  assign
    v-date = date(v-new-month, v-new-day, v-new-year)
  .
  if v-date = ? then do:
    message
      "Недопустимая дата" skip
      "месяц" v-new-month skip
      "день"  v-new-day   skip
      "год"   v-new-year  skip
      view-as alert-box error .
    return no-apply .
  end.
  if  h-callback <> ?
  and valid-handle(h-callback)
  then do:
    if h-callback :get-signature("validate-month-year") <> ""
    then do:
      define variable lok as logical no-undo .
      run validate-month-year in h-callback
        (input v-date
        ,output lok
        ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры проверки допустимости месяца и года" skip
          "файл" h-callback :file-name skip
          "процедура" "validate-month-year" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        return no-apply .
      end.
      if lok <> true then do:
        return no-apply .
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Программе был передан указатель на процедуру для проверки диапазона дат" skip
        "В указанной процедуре отсутствует внутренняя процедура validate-month-year " skip
        "файл" h-callback :file-name skip
        view-as alert-box error .
      return no-apply .
    end.
  end.
  assign
    p-date  = v-date
    p-ok = true
  .
END.
ON WINDOW-CLOSE OF FRAME D-Dialog
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME D-Dialog
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
END.
ON CHOOSE OF b-next-month IN FRAME D-Dialog
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
  run select-month in this-procedure
    (input 1
    ).
END.
ON CHOOSE OF b-next-year IN FRAME D-Dialog
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
  run select-year in this-procedure
    (input 1
    ).
END.
ON CHOOSE OF b-prev-month IN FRAME D-Dialog
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
  run select-month in this-procedure
    (input -1
    ).
END.
ON CHOOSE OF b-prev-year IN FRAME D-Dialog
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
  run select-year in this-procedure
    (input -1
    ).
END.
ON CHOOSE OF b-quit IN FRAME D-Dialog
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
END.
ON VALUE-CHANGED OF CB-Month IN FRAME D-Dialog
DO:
  run display-month-name in this-procedure .
END.
ON LEAVE OF FI-Year IN FRAME D-Dialog
DO:
  run display-month-name in this-procedure .
END.
if p-title <> "" then do:
  assign
    frame D-Dialog :title = p-title
  .
end.
if p-buttons = ""
   then v-old-mode = true  .
   else v-old-mode = false .
on mouse-select-click of
rect-1,  rect-2,  rect-3,  rect-4,  rect-5,  rect-6,  rect-7,  rect-8,  rect-9,  rect-10,
rect-11, rect-12, rect-13, rect-14, rect-15, rect-16, rect-17, rect-18, rect-19, rect-20,
rect-21, rect-22, rect-23, rect-24, rect-25, rect-26, rect-27, rect-28, rect-29, rect-30,
rect-31, rect-32, rect-33, rect-34, rect-35, rect-36, rect-37, rect-38, rect-39, rect-40,
rect-41, rect-42 do:
  run set-curr-day
    (input self :name
    ).
end.
on mouse-select-dblclick of
rect-1,  rect-2,  rect-3,  rect-4,  rect-5,  rect-6,  rect-7,  rect-8,  rect-9,  rect-10,
rect-11, rect-12, rect-13, rect-14, rect-15, rect-16, rect-17, rect-18, rect-19, rect-20,
rect-21, rect-22, rect-23, rect-24, rect-25, rect-26, rect-27, rect-28, rect-29, rect-30,
rect-31, rect-32, rect-33, rect-34, rect-35, rect-36, rect-37, rect-38, rect-39, rect-40,
rect-41, rect-42 do:
  run set-curr-day
    (input self :name
    ).
  apply 'choose':u to b-exit .
end.
assign
  FI-header-1 :screen-value  = "Пнд"
  FI-header-2 :screen-value  = "Втр"
  FI-header-3 :screen-value  = "Срд"
  FI-header-4 :screen-value  = "Чтв"
  FI-header-5 :screen-value  = "Птн"
  FI-header-6 :screen-value  = "Сбт"
  FI-header-7 :screen-value  = "Вск"
.
assign
  v-day-handle  [1]  = FI-day-1  :handle
  v-rect-handle [1]  = RECT-1    :handle
  v-day-handle  [2]  = FI-day-2  :handle
  v-rect-handle [2]  = RECT-2    :handle
  v-day-handle  [3]  = FI-day-3  :handle
  v-rect-handle [3]  = RECT-3    :handle
  v-day-handle  [4]  = FI-day-4  :handle
  v-rect-handle [4]  = RECT-4    :handle
  v-day-handle  [5]  = FI-day-5  :handle
  v-rect-handle [5]  = RECT-5    :handle
  v-day-handle  [6]  = FI-day-6  :handle
  v-rect-handle [6]  = RECT-6    :handle
  v-day-handle  [7]  = FI-day-7  :handle
  v-rect-handle [7]  = RECT-7    :handle
  v-day-handle  [8]  = FI-day-8  :handle
  v-rect-handle [8]  = RECT-8    :handle
  v-day-handle  [9]  = FI-day-9  :handle
  v-rect-handle [9]  = RECT-9    :handle
  v-day-handle  [10] = FI-day-10 :handle
  v-rect-handle [10] = RECT-10   :handle
  v-day-handle  [11] = FI-day-11 :handle
  v-rect-handle [11] = RECT-11   :handle
  v-day-handle  [12] = FI-day-12 :handle
  v-rect-handle [12] = RECT-12   :handle
  v-day-handle  [13] = FI-day-13 :handle
  v-rect-handle [13] = RECT-13   :handle
  v-day-handle  [14] = FI-day-14 :handle
  v-rect-handle [14] = RECT-14   :handle
  v-day-handle  [15] = FI-day-15 :handle
  v-rect-handle [15] = RECT-15   :handle
  v-day-handle  [16] = FI-day-16 :handle
  v-rect-handle [16] = RECT-16   :handle
  v-day-handle  [17] = FI-day-17 :handle
  v-rect-handle [17] = RECT-17   :handle
  v-day-handle  [18] = FI-day-18 :handle
  v-rect-handle [18] = RECT-18   :handle
  v-day-handle  [19] = FI-day-19 :handle
  v-rect-handle [19] = RECT-19   :handle
  v-day-handle  [20] = FI-day-20 :handle
  v-rect-handle [20] = RECT-20   :handle
  v-day-handle  [21] = FI-day-21 :handle
  v-rect-handle [21] = RECT-21   :handle
  v-day-handle  [22] = FI-day-22 :handle
  v-rect-handle [22] = RECT-22   :handle
  v-day-handle  [23] = FI-day-23 :handle
  v-rect-handle [23] = RECT-23   :handle
  v-day-handle  [24] = FI-day-24 :handle
  v-rect-handle [24] = RECT-24   :handle
  v-day-handle  [25] = FI-day-25 :handle
  v-rect-handle [25] = RECT-25   :handle
  v-day-handle  [26] = FI-day-26 :handle
  v-rect-handle [26] = RECT-26   :handle
  v-day-handle  [27] = FI-day-27 :handle
  v-rect-handle [27] = RECT-27   :handle
  v-day-handle  [28] = FI-day-28 :handle
  v-rect-handle [28] = RECT-28   :handle
  v-day-handle  [29] = FI-day-29 :handle
  v-rect-handle [29] = RECT-29   :handle
  v-day-handle  [30] = FI-day-30 :handle
  v-rect-handle [30] = RECT-30   :handle
  v-day-handle  [31] = FI-day-31 :handle
  v-rect-handle [31] = RECT-31   :handle
  v-day-handle  [32] = FI-day-32 :handle
  v-rect-handle [32] = RECT-32   :handle
  v-day-handle  [33] = FI-day-33 :handle
  v-rect-handle [33] = RECT-33   :handle
  v-day-handle  [34] = FI-day-34 :handle
  v-rect-handle [34] = RECT-34   :handle
  v-day-handle  [35] = FI-day-35 :handle
  v-rect-handle [35] = RECT-35   :handle
  v-day-handle  [36] = FI-day-36 :handle
  v-rect-handle [36] = RECT-36   :handle
  v-day-handle  [37] = FI-day-37 :handle
  v-rect-handle [37] = RECT-37   :handle
  v-day-handle  [38] = FI-day-38 :handle
  v-rect-handle [38] = RECT-38   :handle
  v-day-handle  [39] = FI-day-39 :handle
  v-rect-handle [39] = RECT-39   :handle
  v-day-handle  [40] = FI-day-40 :handle
  v-rect-handle [40] = RECT-40   :handle
  v-day-handle  [41] = FI-day-41 :handle
  v-rect-handle [41] = RECT-41   :handle
  v-day-handle  [42] = FI-day-42 :handle
  v-rect-handle [42] = RECT-42   :handle
.
assign
  v-date = p-date
.
if v-date = ? then do:
  assign
    v-date = today
  .
end.
assign
  CB-Month                = month(v-date)
  CB-Month :screen-value  = string(month(v-date))
  FI-Year                 = year(v-date)
  FI-Year  :screen-value  = string(year(v-date))
  v-curr-day              = day(v-date)
.
assign
  p-ok = false
.
run display-month-name in this-procedure .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame D-Dialog
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
on choose of b-help in frame D-Dialog
do:
  apply "help":u to frame D-Dialog .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame D-Dialog:width - 0.3
                fh            = frame D-Dialog:first-child
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
IF THIS-PROCEDURE:PERSISTENT THEN DO:
    MESSAGE "A SmartDialog is not intended ":U SKIP
            "to be run Persistent or to be placed ":U SKIP
            "in another SmartObject at UIB design time.":U
            VIEW-AS ALERT-BOX ERROR.
    RUN disable_UI.
    DELETE PROCEDURE THIS-PROCEDURE.
    RETURN.
END.
RUN dispatch ('create-objects':U).
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME D-Dialog:PARENT eq ?
THEN FRAME D-Dialog:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
  WAIT-FOR GO OF FRAME D-Dialog.
END.
RUN dispatch IN THIS-PROCEDURE ('destroy':U).
PROCEDURE adm-create-objects :
END PROCEDURE.
PROCEDURE adm-row-available :
  DEFINE VARIABLE tbl-list           AS CHARACTER INIT "":U NO-UNDO.
  DEFINE VARIABLE rowid-list         AS CHARACTER NO-UNDO.
  DEFINE VARIABLE row-avail-cntr     AS INTEGER INIT 0 NO-UNDO.
  DEFINE VARIABLE row-avail-rowid    AS ROWID NO-UNDO.
  DEFINE VARIABLE row-avail-enabled  AS LOGICAL NO-UNDO.
  DEFINE VARIABLE link-handle        AS CHARACTER NO-UNDO.
  DEFINE VARIABLE record-source-hdl  AS HANDLE NO-UNDO.
  DEFINE VARIABLE different-row      AS LOGICAL NO-UNDO INIT no.
  DEFINE VARIABLE key-name           AS CHARACTER INIT ? NO-UNDO.
  DEFINE VARIABLE key-value          AS CHARACTER INIT ? NO-UNDO.
  RUN check-modified IN THIS-PROCEDURE ('check':U) NO-ERROR.
  IF adm-updating-record THEN RETURN.
  RUN get-attribute ('FIELDS-ENABLED':U).
  row-avail-enabled = IF RETURN-VALUE = "YES":U THEN yes ELSE no.
  RUN get-link-handle IN adm-broker-hdl (THIS-PROCEDURE, 'RECORD-SOURCE':U,
      OUTPUT link-handle) NO-ERROR.
  IF link-handle = "":U THEN
      RETURN.
  ASSIGN record-source-hdl = WIDGET-HANDLE(ENTRY(1,link-handle)).
  IF NUM-ENTRIES(link-handle) > 1 THEN
      MESSAGE "row-available in ":U THIS-PROCEDURE:FILE-NAME
          "encountered more than one RECORD-SOURCE.":U SKIP
          "The first - ":U record-source-hdl:file-name " - will be used.":U
             VIEW-AS ALERT-BOX ERROR.
  RUN get-attribute ('Key-Name':U).
  key-name = RETURN-VALUE.
  IF key-name = "":U THEN key-name = ?.
  IF key-name NE ? THEN DO:
    RUN send-key IN record-source-hdl (INPUT key-name, OUTPUT key-value)
      NO-ERROR.
    IF key-value NE ? THEN
      RUN set-attribute-list (SUBSTITUTE ('Key-Value="&1"':U, key-value)).
  END.
IF VALID-HANDLE (adm-object-hdl) THEN
    RUN dispatch IN THIS-PROCEDURE ('display-fields':U).
RUN notify IN THIS-PROCEDURE ('row-available':U).
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME D-Dialog.
END PROCEDURE.
PROCEDURE display-calendar :
  assign
    v-curr-month   = integer(cb-month :screen-value in frame D-Dialog)
    v-curr-year    = integer(fi-year :screen-value  in frame D-Dialog)
    v-month-begin  = date(v-curr-month
                         ,1
                         ,v-curr-year
                         )
    v-month-offset = (weekday(v-month-begin) + 5) mod 7
  .
  run gbl/lastday.p
    (input  v-month-begin
    ,output v-last-day
    ).
  if v-curr-day > v-last-day then do:
    assign
      v-curr-day = v-last-day
    .
  end.
  if v-curr-day = ?
  or v-curr-day <= 0 then do:
    assign
      v-curr-day = 1
    .
  end.
  do with frame D-Dialog:
    assign
      FI-date :screen-value = string( date (v-curr-month, v-curr-day, v-curr-year) )
    .
  end.
  define variable ind as integer no-undo .
  define variable l-immediate-display as logical no-undo .
  assign
    l-immediate-display        = session :immediate-display
    session :immediate-display = false
  .
  v-curr-day = ? .
  do ind = 1 to 42 :
    run set-box-state in this-procedure
      (input ind
      ,input  (if ind  >= v-month-offset + 1
              and ind <= v-month-offset + v-last-day
              then ind - v-month-offset
              else 0
             )
      ).
  end.
  assign
    session :immediate-display = l-immediate-display
  .
END PROCEDURE.
PROCEDURE display-month-name :
  define variable v-month-name as character no-undo .
  do with frame D-Dialog:
    run gbl/monthnam.p
      (input integer(cb-month :screen-value)
      ,output v-month-name
      ).
    assign
      fi-month-name :screen-value = v-month-name
    .
  end.
  run display-calendar .
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY CB-Month FI-Year
      WITH FRAME D-Dialog.
  ENABLE b-exit b-quit b-help CB-Month b-prev-month b-next-month FI-Year
         b-prev-year b-next-year fi-month-name
      WITH FRAME D-Dialog.
  VIEW FRAME D-Dialog.
END PROCEDURE.
PROCEDURE select-month :
  define input parameter p-shift-value as integer no-undo .
  define variable v-current-month as integer no-undo .
  do with frame D-Dialog:
    assign
      v-current-month = integer (cb-month :screen-value)
    .
    assign
      v-current-month = v-current-month + p-shift-value
    .
    if v-current-month < 1 then do:
      assign
        v-current-month = 1
      .
    end.
    if v-current-month > 12 then do:
      assign
        v-current-month = 12
      .
    end.
    assign
      cb-month :screen-value = string(v-current-month)
    .
  end.
  run display-month-name .
END PROCEDURE.
PROCEDURE select-year :
  define input parameter p-shift-value as integer no-undo .
  define variable v-current-year as integer no-undo .
  do with frame D-Dialog:
    assign
      v-current-year = integer (fi-year :screen-value)
    .
    assign
      v-current-year = v-current-year + p-shift-value
    .
    if v-current-year < 0 then do:
      assign
        v-current-year = 0
      .
    end.
    if v-current-year > 9999 then do:
      assign
        v-current-year = 9999
      .
    end.
    assign
      fi-year :screen-value = string(v-current-year)
    .
  end.
  run display-month-name .
END PROCEDURE.
PROCEDURE send-records :
END PROCEDURE.
PROCEDURE set-box-state :
  define input parameter v-box-number as integer no-undo .
  define input parameter v-display-day as integer no-undo .
  if v-display-day = 0
  or v-display-day = ? then do:
    if v-day-handle  [v-box-number] :visible <> false then do:
      assign
        v-day-handle  [v-box-number] :visible = false
      .
    end.
    if v-day-handle  [v-box-number] :screen-value <> "" then do:
      assign
        v-day-handle  [v-box-number] :screen-value = ""
      .
    end.
    if v-rect-handle  [v-box-number] :sensitive <> false then do:
      assign
        v-rect-handle  [v-box-number] :sensitive = false
      .
    end.
    if v-rect-handle [v-box-number] :visible <> false then do:
      assign
        v-rect-handle [v-box-number] :visible = false
      .
    end.
  end.
  else do:
    if v-day-handle  [v-box-number] :visible <> true then do:
      assign
        v-day-handle  [v-box-number] :visible = true
      .
    end.
    if v-day-handle  [v-box-number] :screen-value <> string(v-display-day) then do:
      assign
        v-day-handle  [v-box-number] :screen-value = string(v-display-day)
      .
    end.
    if v-display-day = v-curr-day then do:
        if v-old-mode then do:
           v-rect-handle [v-box-number] :bgcolor = RED_COLOR .
        end.
        else do:
           v-rect-handle [v-box-number] :bgcolor =  BLUE_COLOR .
        end.
    end.
    else do:
      assign
        v-rect-handle [v-box-number] :bgcolor = GREY_COLOR
      .
    end.
    if v-rect-handle [v-box-number] :visible <> true then do:
      assign
        v-rect-handle [v-box-number] :visible = true
      .
    end.
    if v-rect-handle  [v-box-number] :sensitive <> true then do:
      assign
        v-rect-handle  [v-box-number] :sensitive = true
      .
    end.
  end.
END PROCEDURE.
PROCEDURE del-box-state :
  define input parameter v-box-number as integer no-undo .
  define input parameter v-display-day as integer no-undo .
  if v-display-day = 0
  or v-display-day = ? then do:
    if v-day-handle  [v-box-number] :visible <> false then do:
      assign
        v-day-handle  [v-box-number] :visible = false
      .
    end.
    if v-day-handle  [v-box-number] :screen-value <> "" then do:
      assign
        v-day-handle  [v-box-number] :screen-value = ""
      .
    end.
    if v-rect-handle  [v-box-number] :sensitive <> false then do:
      assign
        v-rect-handle  [v-box-number] :sensitive = false
      .
    end.
    if v-rect-handle [v-box-number] :visible <> false then do:
      assign
        v-rect-handle [v-box-number] :visible = false
      .
    end.
  end.
  else do:
    if v-day-handle  [v-box-number] :visible <> true then do:
      assign
        v-day-handle  [v-box-number] :visible = true
      .
    end.
    if v-day-handle  [v-box-number] :screen-value <> string(v-display-day) then do:
      assign
        v-day-handle  [v-box-number] :screen-value = string(v-display-day)
      .
    end.
    if v-display-day = v-curr-day then do:
      assign
        v-rect-handle [v-box-number] :bgcolor = Grey_COLOR
      .
    end.
    else do:
      assign
        v-rect-handle [v-box-number] :bgcolor = GREY_COLOR
      .
    end.
    if v-rect-handle [v-box-number] :visible <> true then do:
      assign
        v-rect-handle [v-box-number] :visible = true
      .
    end.
    if v-rect-handle  [v-box-number] :sensitive <> true then do:
      assign
        v-rect-handle  [v-box-number] :sensitive = true
      .
    end.
  end.
END PROCEDURE.
PROCEDURE set-curr-day :
  define input parameter p-rect-name as character no-undo .
  define variable v-box-ind as integer no-undo .
  assign
    v-box-ind = integer (substring (p-rect-name, 6))
  .
  define variable v-new-day as integer no-undo .
  define variable v-old-day as integer no-undo .
  assign
    v-new-day = if  v-box-ind >= v-month-offset + 1
                and v-box-ind <= v-month-offset + v-last-day
                then v-box-ind - v-month-offset
                else 0
  .
  if  v-new-day <> 0
  and v-new-day <> v-curr-day then do:
    assign
      v-old-day = v-curr-day
      v-curr-day = v-new-day
    .
    if v-old-mode = true then do:
        run set-box-state
          (input v-old-day + v-month-offset
          ,input v-old-day
          ).
    end.
   run set-box-state
      (input v-new-day + v-month-offset
      ,input v-new-day
      ).
    if v-old-mode = false  then do:
     if not can-find (first temp-dates where temp-dates.dates = date(v-curr-month, v-curr-day, v-curr-year) ) then do:
          create temp-dates no-error .
          assign temp-dates.dates = date(v-curr-month, v-curr-day, v-curr-year) no-error .
        end.
        Else do:
            run del-box-state
              (input v-new-day + v-month-offset
              ,input v-new-day  ).
             find first temp-dates where temp-dates.dates = date(v-curr-month, v-curr-day, v-curr-year) no-error .
             delete temp-dates no-error .
             v-rect-handle [v-curr-day] :bgcolor = GREY_COLOR.
        end.
    end.
            do with frame D-Dialog:
              assign
                FI-date :screen-value = string( date (v-curr-month, v-curr-day, v-curr-year) )
              .
            end.
  end.
END PROCEDURE.
PROCEDURE state-changed :
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.
