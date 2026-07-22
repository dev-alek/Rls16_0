&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
/* Connected Databases
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME d-scn-inv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS d-scn-inv
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Объединение сканерных файлов в инвентаризационный

Автор: Чернова Светлана Александровна
Дата создания: 10/31/06
Author: Svetlana Chernova
Creation date: 10/31/06

Author2: Суслов Алексей Юрьевич
Created: 09/07/05

Author1: Андрей Исаков
Created: 9.7.99


*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as handle no-undo.
define input parameter p-recid       as recid  no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Объединение сканерных файлов в инвентаризационный".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ str/anlz-bc.i new }
{ gbl/waitfram.i }

define temp-table loc-in-bc no-undo like in-bc.
define work-table file-inv
field file-name as character format "x(256)".
define variable scan-txt as character no-undo.
define variable scan-name as character no-undo.
define variable is-err as logical no-undo.
define stream inv.
define stream log.
define stream err.
define variable i as integer no-undo.
define variable rec-file as recid.
define variable last-file as character no-undo.
define variable flag-save as logical initial yes no-undo.
define variable b-c     as character        no-undo. /* обрабатываемый бар-код                    */
define variable rate     like ub.doc-line.cli-base-rate no-undo. /* коэффициент для единиц из бар-кода        */
define variable ret-mode as character no-undo. /*режим обработки бар-кода*/
define variable add-scan as logical initial no no-undo.
define variable bar-str  like ub.prod-bc.b-str  no-undo. /* строка для чтения бар-кода из файла       */
define variable varlog  as logical no-undo.
define variable line-rec as recid no-undo .

define buffer t-doc for ub.trn-doc  .
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME d-scn-inv
&Scoped-define BROWSE-NAME b-anlz-bc

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES anlz-bc main-bc file-inv in-bc un-bc

/* Definitions for BROWSE b-anlz-bc                                     */
&Scoped-define FIELDS-IN-QUERY-b-anlz-bc main-bc.b-c anlz-bc.scn-qnty anlz-bc.scn-pl anlz-bc.rez
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-anlz-bc anlz-bc.scn-qnty anlz-bc.scn-pl
&Scoped-define ENABLED-TABLES-IN-QUERY-b-anlz-bc anlz-bc
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-b-anlz-bc anlz-bc
&Scoped-define SELF-NAME b-anlz-bc
&Scoped-define QUERY-STRING-b-anlz-bc FOR EACH anlz-bc , ~
            first main-bc where anlz-bc.nm = main-bc.nm INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-b-anlz-bc OPEN QUERY {&SELF-NAME} FOR EACH anlz-bc , ~
            first main-bc where anlz-bc.nm = main-bc.nm INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-b-anlz-bc anlz-bc main-bc
&Scoped-define FIRST-TABLE-IN-QUERY-b-anlz-bc anlz-bc
&Scoped-define SECOND-TABLE-IN-QUERY-b-anlz-bc main-bc


/* Definitions for BROWSE b-file                                        */
&Scoped-define FIELDS-IN-QUERY-b-file file-inv.file-name
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-file
&Scoped-define SELF-NAME b-file
&Scoped-define QUERY-STRING-b-file FOR EACH file-inv
&Scoped-define OPEN-QUERY-b-file OPEN QUERY {&SELF-NAME} FOR EACH file-inv.
&Scoped-define TABLES-IN-QUERY-b-file file-inv
&Scoped-define FIRST-TABLE-IN-QUERY-b-file file-inv


/* Definitions for BROWSE b-in-bc                                       */
&Scoped-define FIELDS-IN-QUERY-b-in-bc in-bc.bar-str in-bc.bar-code in-bc.rez
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-in-bc
&Scoped-define SELF-NAME b-in-bc
&Scoped-define QUERY-STRING-b-in-bc FOR EACH in-bc INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-b-in-bc OPEN QUERY {&SELF-NAME} FOR EACH in-bc INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-b-in-bc in-bc
&Scoped-define FIRST-TABLE-IN-QUERY-b-in-bc in-bc


/* Definitions for BROWSE b-un-bc                                       */
&Scoped-define FIELDS-IN-QUERY-b-un-bc un-bc.bar-code un-bc.b-c un-bc.scn-qnty un-bc.file-qnty un-bc.rez un-bc.scn-pl
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-un-bc
&Scoped-define SELF-NAME b-un-bc
&Scoped-define QUERY-STRING-b-un-bc FOR EACH un-bc INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-b-un-bc OPEN QUERY {&SELF-NAME} FOR EACH un-bc INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-b-un-bc un-bc
&Scoped-define FIRST-TABLE-IN-QUERY-b-un-bc un-bc


/* Definitions for DIALOG-BOX d-scn-inv                                 */
&Scoped-define OPEN-BROWSERS-IN-QUERY-d-scn-inv ~
    ~{&OPEN-QUERY-b-anlz-bc}~
    ~{&OPEN-QUERY-b-file}~
    ~{&OPEN-QUERY-b-in-bc}~
    ~{&OPEN-QUERY-b-un-bc}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-save b-add b-undo b-bc b-help ~
b-in-bc b-file varerr-msg-in vardes-in b-un-bc b-inf varerr-msg-un ~
vardes-un b-anlz-bc varerr-msg-anlz vardes-anlz
&Scoped-Define DISPLAYED-OBJECTS varerr-msg-in vardes-in varerr-msg-un ~
vardes-un varerr-msg-anlz vardes-anlz

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-bc
     LABEL "Бар-Код"
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход "
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-inf
     LABEL "&Информация"
     SIZE 10.88 BY .96
     BGCOLOR 8 .

DEFINE BUTTON b-save
     LABEL "Сох&ранить"
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON b-undo
     LABEL "В&ернуть"
     SIZE 10 BY 1.13
     BGCOLOR 8 .

DEFINE VARIABLE vardes-anlz AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 32.63 BY 3.63 NO-UNDO.

DEFINE VARIABLE vardes-in AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 33 BY 3.63 NO-UNDO.

DEFINE VARIABLE vardes-un AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 32.88 BY 3.63 NO-UNDO.

DEFINE VARIABLE varerr-msg-anlz AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 32.75 BY 1.29 NO-UNDO.

DEFINE VARIABLE varerr-msg-in AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 33 BY 1.29 NO-UNDO.

DEFINE VARIABLE varerr-msg-un AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 32.88 BY 1.29 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-anlz-bc FOR
      anlz-bc,
      main-bc SCROLLING.

DEFINE QUERY b-file FOR
      file-inv SCROLLING.

DEFINE QUERY b-in-bc FOR
      in-bc SCROLLING.

DEFINE QUERY b-un-bc FOR
      un-bc SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-anlz-bc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-anlz-bc d-scn-inv _FREEFORM
  QUERY b-anlz-bc DISPLAY
      main-bc.b-c column-label "Основной бар-код"  format ">>>>>>>>>>>>9"
anlz-bc.scn-qnty column-label "Количество" format ">>,>>>,>>9.999"
anlz-bc.scn-pl column-label "Место"  format "x(14)"
anlz-bc.rez column-label "Рез" format "x(3)"
enable anlz-bc.scn-qnty anlz-bc.scn-pl
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 64 BY 6.96.

DEFINE BROWSE b-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-file d-scn-inv _FREEFORM
  QUERY b-file DISPLAY
      file-inv.file-name column-label "Файлы"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SIZE 18.75 BY 6.54.

DEFINE BROWSE b-in-bc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-in-bc d-scn-inv _FREEFORM
  QUERY b-in-bc DISPLAY
      in-bc.bar-str  column-label "Строка" format "x(25)"
in-bc.bar-code column-label "Бар-код" format "x(13)"
in-bc.rez      column-label "Рез" format "x(3)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 45.5 BY 6.67.

DEFINE BROWSE b-un-bc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-un-bc d-scn-inv _FREEFORM
  QUERY b-un-bc DISPLAY
      un-bc.bar-code column-label "Бар-код" format "x(13)"
un-bc.b-c column-label "Собств.бар-код" format ">>>>>>>>>>>>9"
un-bc.scn-qnty column-label "Всего" format ">>,>>>,>>9.999"
un-bc.file-qnty column-label "Файл" format ">>,>>>,>>9.999"
un-bc.rez column-label "Рез" format "x(3)"
un-bc.scn-pl column-label "Место" format "x(13)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 64 BY 7.04.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME d-scn-inv
     b-exit AT ROW 1.38 COL 1.5
     b-save AT ROW 1.38 COL 11.63
     b-add AT ROW 1.38 COL 21.75
     b-undo AT ROW 1.38 COL 31.88
     b-bc AT ROW 1.38 COL 42.13
     b-help AT ROW 1.38 COL 52.5
     b-in-bc AT ROW 2.58 COL 19.75
     b-file AT ROW 2.71 COL 1.25
     varerr-msg-in AT ROW 2.96 COL 65.38 NO-LABEL
     vardes-in AT ROW 5.13 COL 65.38 NO-LABEL
     b-un-bc AT ROW 9.33 COL 1.25
     b-inf AT ROW 9.33 COL 65.63
     varerr-msg-un AT ROW 10.42 COL 65.5 NO-LABEL
     vardes-un AT ROW 12.54 COL 65.5 NO-LABEL
     b-anlz-bc AT ROW 16.42 COL 1.25
     varerr-msg-anlz AT ROW 17.29 COL 65.63 NO-LABEL
     vardes-anlz AT ROW 19.63 COL 65.75 NO-LABEL
     "Описание" VIEW-AS TEXT
          SIZE 8.88 BY .75 AT ROW 4.38 COL 75.63
     "Ошибки" VIEW-AS TEXT
          SIZE 6.88 BY .79 AT ROW 16.38 COL 76.75
     "Ошибки" VIEW-AS TEXT
          SIZE 6.88 BY .79 AT ROW 9.46 COL 77
     "Описание" VIEW-AS TEXT
          SIZE 8.88 BY .75 AT ROW 11.75 COL 76.38
     "Описание" VIEW-AS TEXT
          SIZE 8.88 BY .75 AT ROW 18.75 COL 76.5
     "Ошибки" VIEW-AS TEXT
          SIZE 6.88 BY .79 AT ROW 2.08 COL 75.63
     SPACE(16.11) SKIP(20.58)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Файл сканера -> Файл инвентаризации".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX d-scn-inv
   FRAME-NAME                                                           */
/* BROWSE-TAB b-in-bc b-help d-scn-inv */
/* BROWSE-TAB b-file b-in-bc d-scn-inv */
/* BROWSE-TAB b-un-bc vardes-in d-scn-inv */
/* BROWSE-TAB b-anlz-bc vardes-un d-scn-inv */
ASSIGN
       FRAME d-scn-inv:SCROLLABLE       = FALSE
       FRAME d-scn-inv:HIDDEN           = TRUE.

ASSIGN
       vardes-anlz:READ-ONLY IN FRAME d-scn-inv        = TRUE.

ASSIGN
       vardes-in:READ-ONLY IN FRAME d-scn-inv        = TRUE.

ASSIGN
       vardes-un:READ-ONLY IN FRAME d-scn-inv        = TRUE.

ASSIGN
       varerr-msg-anlz:READ-ONLY IN FRAME d-scn-inv        = TRUE.

ASSIGN
       varerr-msg-in:READ-ONLY IN FRAME d-scn-inv        = TRUE.

ASSIGN
       varerr-msg-un:READ-ONLY IN FRAME d-scn-inv        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-anlz-bc
/* Query rebuild information for BROWSE b-anlz-bc
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH anlz-bc ,
     first main-bc where anlz-bc.nm = main-bc.nm
INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-anlz-bc */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-file
/* Query rebuild information for BROWSE b-file
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH file-inv.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-file */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-in-bc
/* Query rebuild information for BROWSE b-in-bc
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH in-bc INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-in-bc */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-un-bc
/* Query rebuild information for BROWSE b-un-bc
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH un-bc INDEXED-REPOSITION.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE b-un-bc */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME d-scn-inv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL d-scn-inv d-scn-inv
ON WINDOW-CLOSE OF FRAME d-scn-inv /* Файл сканера -> Файл инвентаризации */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add d-scn-inv
ON CHOOSE OF b-add IN FRAME d-scn-inv /* Добавить */
DO:
/* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   чтение файла сканера
   -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- */
system-dialog get-file scan-txt
  title "Выберите файл со сканера"
       filters "WorkAbout MS15" "*.dbs",
                 "WorkAbout" "*.imp",
                 "Инвентр" "*.inv",
                 "Все файлы" "*.*"
       update varlog.
if not varlog then return.
if entry (2, scan-txt, ".") = "err" then do:
  message "Файл с расширением '.err' не может быть обработан. Переименуйте его.".
  return no-apply.
end.
scan-name = entry (1, scan-txt, ".").
output stream log to value(scan-name + ".log").
output stream err to value(scan-name + ".err").

run waitfram-show in this-procedure
  (input "Разбор файла: " + scan-txt + "     ЖДИТЕ..."
  ).
create file-inv.
assign file-inv.file-name = scan-txt.
last-file = scan-txt.
flag-save = no.
rec-file = recid(file-inv).
for each in-bc :
  delete in-bc.
end.
/*
*/

run str/bc-anlz.p (parparentproc, "file", scan-txt, yes, output is-err, output table in-bc) no-error.




FOR EACH in-bc:
 /*
 message
 'nm        '  in-bc.nm           skip
 'bar-str   '  in-bc.bar-str      skip
 'bar-code  '  in-bc.bar-code     skip
 'rez       '  in-bc.rez          skip
 'err-msg   '  in-bc.err-msg      skip
 'des       '  in-bc.des          skip .
  */

    if in-bc.rez = "ERR" then DO:
       put stream log unformatted in-bc.err-msg skip.
       put stream err unformatted in-bc.bar-str skip.
       ASSIGN is-err = YES.
    END.
    put stream log unformatted in-bc.des.
END.


/*
for each  anlz-bc :

message
  anlz-bc.nm        '/*строка по порядку                               */ ' skip
  anlz-bc.b-c       '/*бар-код                                         */ ' skip
  anlz-bc.scn-qnty  '/*кол-во                                          */ ' skip
  anlz-bc.scn-pl    '/*складское место                                 */ ' skip
  anlz-bc.rez       '/*результат анализа                               */ ' skip
  anlz-bc.err-msg   '/*сообщения об ошибках и предупреждениях          */ ' skip
  anlz-bc.des       '/*описание данного бар-кода                       */ ' skip
  anlz-bc.upd-line  '/*если линия редактировалась руками*/                '
  .

end.

for each main-bc :
message
  main-bc.nm        '/*строка по порядку                               */' skip
  main-bc.b-c       '/*бар-код                                         */' skip
  main-bc.scn-qnty  '/*кол-во                                          */' skip
  main-bc.scn-pl    '/*складское место                                 */' skip
  main-bc.rez       '/*результат анализа                               */' skip
  main-bc.des       '/*описание данного бар-кода                       */' skip
  .
end.
*/

FOR EACH un-bc:
    if un-bc.rez = "ERR" THEN DO:
       put stream log unformatted un-bc.err-msg skip.
       put stream err unformatted un-bc.bar-code ", " un-bc.file-qnty skip.
       ASSIGN is-err = YES.
    END.
    put stream log unformatted un-bc.des skip.
END.
run waitfram-hide in this-procedure .
run enable_UI in this-procedure .
reposition b-file to recid rec-file.
run loc-val-chg in this-procedure .
output stream log close.
output stream err close.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-anlz-bc
&Scoped-define SELF-NAME b-anlz-bc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-anlz-bc d-scn-inv
ON ROW-DISPLAY OF b-anlz-bc IN FRAME d-scn-inv
DO:
  if available anlz-bc then do:
     IF anlz-bc.upd-line THEN
        ASSIGN anlz-bc.scn-qnty:BGCOLOR IN BROWSE b-anlz-bc = 3.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-anlz-bc d-scn-inv
ON ROW-LEAVE OF b-anlz-bc IN FRAME d-scn-inv
DO:
if available anlz-bc and anlz-bc.upd-line = no then do:
  if input browse b-anlz-bc anlz-bc.scn-qnty <> ""
  then do:
     assign anlz-bc.upd-line = yes.
     if b-anlz-bc:refresh() then.
  end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-anlz-bc d-scn-inv
ON VALUE-CHANGED OF b-anlz-bc IN FRAME d-scn-inv
DO:
if available anlz-bc then
  ASSIGN vardes-anlz = anlz-bc.des
         varerr-msg-anlz = anlz-bc.err-msg.
else
  ASSIGN vardes-anlz = ""
         varerr-msg-anlz = "".

display vardes-anlz varerr-msg-anlz with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-bc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-bc d-scn-inv
ON CHOOSE OF b-bc IN FRAME d-scn-inv /* Бар-Код */
DO:
 REPEAT:
   run str/chs-bc.w (
   input parparentproc,
   input "",
   input ?,
   input ?,
   input  YES,
   output       b-c,
   output       rate,
   output       ret-mode,
   input-output add-scan,
   input-output bar-str) no-error.
   if error-status:error or b-c = ? THEN LEAVE.
   run str/bc-anlz.p (parparentproc, if add-scan then "code-add" else "code-update", string(b-c), yes, output is-err, output table in-bc) no-error.
   if error-status:error then do:
      message "Неверный анализ бар-кода."
      view-as alert-box.
      return no-apply.
   end.

   find first in-bc.
   create file-inv.
   assign file-inv.file-name = in-bc.bar-str
          last-file = in-bc.bar-str
          flag-save = no
          rec-file = recid(file-inv).
   run enable_ui in this-procedure .

   find first un-bc where un-bc.bar-code = in-bc.bar-code no-error.
   if available un-bc then do:
      REPOSITION b-un-bc TO RECID RECID(un-bc).
      find first anlz-bc where anlz-bc.b-c = un-bc.b-c no-error.
      if available anlz-bc then do:
         REPOSITION b-anlz-bc TO RECID RECID(anlz-bc).
         if not add-scan then do:
            apply "entry" to browse b-anlz-bc.
            apply "entry" to anlz-bc.scn-qnty in browse b-anlz-bc.
         end.
      end.
   end.
   run loc-val-chg in this-procedure .
   reposition b-file to recid rec-file.
   if not add-scan then leave.
 END. /*repeat*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit d-scn-inv
ON CHOOSE OF b-exit IN FRAME d-scn-inv /* Выход  */
DO:
  varlog = no.
  if flag-save = no and can-find (first anlz-bc) then
     message "Вы хотите выйти ничего не сохранив?"
     view-as alert-box question button yes-no update varlog.
  else
     message "Выход?"
     view-as alert-box question button yes-no update varlog.
  if varlog <> yes then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-in-bc
&Scoped-define SELF-NAME b-in-bc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-in-bc d-scn-inv
ON VALUE-CHANGED OF b-in-bc IN FRAME d-scn-inv
DO:
if available in-bc then
  ASSIGN vardes-in = in-bc.des
         varerr-msg-in = in-bc.err-msg.
else
  ASSIGN vardes-in = ""
         varerr-msg-in = "".
  display vardes-in varerr-msg-in with frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-inf
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-inf d-scn-inv
ON CHOOSE OF b-inf IN FRAME d-scn-inv /* Информация */
DO:
  if available un-bc then do:
    run str/bc-inf.w (
                   input parparentproc
                  ,input v-cntxt-obj-type
                  ,input v-cntxt-obj-code
                  ,input RECID(un-bc)
                  ,output table loc-in-bc).
  end.
  else do:
      message "Неправильно выбран бар-код" view-as alert-box.
      return no-apply.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save d-scn-inv
ON CHOOSE OF b-save IN FRAME d-scn-inv /* Сохранить */
DO:
scan-txt = scan-name + ".inv".
system-dialog get-file scan-txt
  filters "Файл инвентаризации *.inv" "*.inv"
  ask-overwrite
  save-as
  use-filename
  update varlog
  default-extension "inv".
scan-name = entry (1, scan-txt, ".").
if not varlog then return no-apply.
run waitfram-show in this-procedure
  (input "Запись файла: " + scan-txt + "     ЖДИТЕ..."
  ).
output stream inv to value (scan-txt).
output stream log to value (scan-name + ".log") append.
output stream err to value (scan-name + ".err") append.
put stream log unformatted "  " skip.
put stream log unformatted cur-time-string-sec() skip.
put stream log unformatted " " skip skip "!!! -> Файл Инвентаризации: " + scan-txt skip skip.
for each anlz-bc ,
    first main-bc where anlz-bc.nm = main-bc.nm
    :
  i = i + 1.
  if i modulo 25 = 0 then
    run waitfram-show in this-procedure
      (input "Запись файла: " + scan-txt + "     Записано: " + string (i)
      ).
    put stream inv unformatted
          string(main-bc.b-c) + minimum (", ", string (anlz-bc.scn-qnty)) + string (anlz-bc.scn-qnty) + minimum (", ", string(anlz-bc.scn-pl)) + string(anlz-bc.scn-pl) skip.
    put stream log unformatted
          "Код: " main-bc.b-c " Количество: " anlz-bc.scn-qnty skip.
end.
flag-save = yes.
output stream inv close.
output stream log close.
output stream err close.
run waitfram-hide in this-procedure .
if p-recid <> ? then do:
   find first t-doc no-lock where recid(t-doc) = p-recid  .
   message substitute("Закачать информацию по кодам в документ инвентаризации &1 ?" , t-doc.doc-code)
           view-as alert-box question
           buttons yes-no
           update v-log as logical
           .
   if v-log = true then do:
      if t-doc.status_ =  {&wayb} and
         t-doc.flag_   <> yes     then do:
         run str/use-list.p (input parparentproc, input-output line-rec, input p-recid , input NO , input  (buffer anlz-bc:handle) ).  /*main-bc ??? */
      end.
      else do:
         run str/scan.p ( input parparentproc, input no , input p-recid , input scan-txt ).
      end.
   end.
end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-un-bc
&Scoped-define SELF-NAME b-un-bc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-un-bc d-scn-inv
ON VALUE-CHANGED OF b-un-bc IN FRAME d-scn-inv
DO:
if available un-bc then
   ASSIGN vardes-un = un-bc.des
         varerr-msg-un = un-bc.err-msg.
else
   ASSIGN vardes-un = ""
         varerr-msg-un = "".

display vardes-un varerr-msg-un with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-undo
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-undo d-scn-inv
ON CHOOSE OF b-undo IN FRAME d-scn-inv /* Вернуть */
DO:
if last-file <> "" then do:
   varlog = no.
   message "Отменить добавление последнего файла и вернуть предыдущее состояние?"
           view-as alert-box question buttons OK-Cancel update varlog.
   if not varlog then return no-apply.
   run str/bc-anlz.p (parparentproc, "undo", ?, yes, output is-err, output table in-bc).
   find last file-inv where file-inv.file-name = last-file.
   delete file-inv.
   run enable_UI in this-procedure .
   run loc-val-chg in this-procedure .
   last-file = "".
   flag-save = no.
end.
else do:
  message "Возможен откат лишь одного файла." skip
          "После последней очистки не был загружен ни один файл."
  view-as alert-box error.
  return no-apply.
end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-anlz-bc
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK d-scn-inv


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  for each anlz-bc :
    delete anlz-bc.
  end.

  run enable_ui in this-procedure .
  run loc-val-chg in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_ui in this-procedure .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI d-scn-inv  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME d-scn-inv.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI d-scn-inv  _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY varerr-msg-in vardes-in varerr-msg-un vardes-un varerr-msg-anlz
          vardes-anlz
      WITH FRAME d-scn-inv.
  ENABLE b-exit b-save b-add b-undo b-bc b-help b-in-bc b-file varerr-msg-in
         vardes-in b-un-bc b-inf varerr-msg-un vardes-un b-anlz-bc
         varerr-msg-anlz vardes-anlz
      WITH FRAME d-scn-inv.
  VIEW FRAME d-scn-inv.
  {&OPEN-BROWSERS-IN-QUERY-d-scn-inv}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE loc-val-chg d-scn-inv
PROCEDURE loc-val-chg :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  apply "value-changed" to browse b-in-bc.
  apply "value-changed" to browse b-un-bc.
  apply "value-changed" to browse b-anlz-bc.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME