&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сравнение результатов сканерных файлов

Автор: Суслов Алексей Юрьевич
Дата создания: 09/08/05
Author: Alexey Suslov
Creation date: 09/08/05

*/

{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ str/anlz-bc.i NEW }
{ str/libbcrcn.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/gds-list.i gds-list def "new shared" }
{ cmp/bb-list.i  bb-list  def "new shared" }
{ gbl/getsect.i def }
define variable lns-cnt as integer no-undo.
define variable line-rec as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сравнение результатов сканерных файлов".
{ cmp/vssrevis.i }

define input parameter parparentproc    as   handle              no-undo.
define input parameter parcurr-obj-type like ub.clients.obj-type no-undo.
define input parameter parcurr-obj-code like ub.clients.obj-code no-undo.
define stream cur.
define stream log.                                             /* журнал сообщений */
define stream ler.                                             /* журнал ошибок из журнала сообщений*/
define stream err.                                             /* журнал ошибок */
DEFINE BUFFER bf_gds-prt  FOR ub.gds-prt.
DEFINE BUFFER bf_goods    FOR ub.goods.
DEFINE BUFFER bf_bar-code FOR ub.bar-code.
DEFINE TEMP-TABLE tt-result NO-UNDO
FIELD artic LIKE ub.goods.artic
FIELD prod-type LIKE ub.goods.prod-type
FIELD prod-code LIKE ub.goods.prod-code
FIELD node-code  LIKE ub.gds-prt.node-code
FIELD gds-name  LIKE ub.goods.gds-name
FIELD b-code    LIKE ub.bar-code.b-code
FIELD scan-1 AS DECIMAL INITIAL ?
FIELD scan-2 AS DECIMAL INITIAL ?
FIELD diff-1-2 AS DECIMAL INITIAL 0
FIELD scan-3 AS CHARACTER INITIAL "":u
FIELD itog AS DECIMAL INITIAL ?
INDEX pi IS UNIQUE PRIMARY artic prod-type prod-code node-code
INDEX artic artic
INDEX itog itog.
DEFINE VARIABLE varrowid AS ROWID.
DEFINE VARIABLE varsave-result AS LOGICAL INITIAL YES NO-UNDO.
DEFINE VARIABLE varscan-1      AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE varscan-2      AS LOGICAL INITIAL NO NO-UNDO.
DEFINE VARIABLE varscan-3      AS LOGICAL INITIAL NO NO-UNDO.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME b-result

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-result

/* Definitions for BROWSE b-result                                      */
&Scoped-define FIELDS-IN-QUERY-b-result tt-result.artic tt-result.gds-name tt-result.scan-1 tt-result.scan-2 tt-result.diff-1-2 fill(" ", 11 - length(tt-result.scan-3)) + tt-result.scan-3 tt-result.itog tt-result.b-code
&Scoped-define ENABLED-FIELDS-IN-QUERY-b-result tt-result.itog
&Scoped-define ENABLED-TABLES-IN-QUERY-b-result tt-result
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-b-result tt-result
&Scoped-define SELF-NAME b-result
&Scoped-define QUERY-STRING-b-result FOR EACH tt-result NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-b-result OPEN QUERY {&SELF-NAME} FOR EACH tt-result NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-b-result tt-result
&Scoped-define FIRST-TABLE-IN-QUERY-b-result tt-result


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-b-result}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-save b-scan-1 b-clear-scan-1 ~
b-scan-2 b-clear-scan-2 b-scan-3 b-clear-scan-3 b-help b-print b-export ~
b-result

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-clear-scan-1
     LABEL "Аннул. 1"
     SIZE 10 BY 1.

DEFINE BUTTON b-clear-scan-2
     LABEL "Аннул. 2"
     SIZE 10 BY 1.

DEFINE BUTTON b-clear-scan-3
     LABEL "Аннул. 3"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-export
     LABEL "Выгрузка списка"
     SIZE 16 BY 1.

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-print
     LABEL "Печать разницы"
     SIZE 15 BY 1.

DEFINE BUTTON b-save
     LABEL "Сохранить"
     SIZE 11 BY 1.

DEFINE BUTTON b-scan-1
     LABEL "1-е скан."
     SIZE 10 BY 1.

DEFINE BUTTON b-scan-2
     LABEL "2-е скан."
     SIZE 10 BY 1.

DEFINE BUTTON b-scan-3
     LABEL "3-е скан."
     SIZE 10 BY 1.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY b-result FOR
      tt-result SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE b-result
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS b-result Dialog-Frame _FREEFORM
  QUERY b-result NO-LOCK DISPLAY
      tt-result.artic FORMAT "X(16)":U
      tt-result.gds-name COLUMN-LABEL "Наимен.!товара":C FORMAT "x(48)"
      tt-result.scan-1 COLUMN-LABEL "Рез-т!1-ого!сканир.":C FORMAT ">>>,>>9.999":U
      tt-result.scan-2 COLUMN-LABEL "Рез-т!2-ого!сканир.":C FORMAT ">>>,>>9.999":U
      tt-result.diff-1-2 COLUMN-LABEL "Разница!между!1 и 2!сканир.":C FORMAT ">>>,>>9.999":U
      fill(" ", 11 - length(tt-result.scan-3)) + tt-result.scan-3 COLUMN-LABEL "Рез-т!3-его!сканир.":C FORMAT "x(11)":U
      tt-result.itog COLUMN-LABEL "Итоги!по!инвентар.":C FORMAT ">>>,>>9.999":U
      tt-result.b-code COLUMN-LABEL "Бар-!код!товара":C FORMAT "999999999":U
      ENABLE tt-result.itog
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 20.63 EXPANDABLE.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-save AT ROW 1 COL 11
     b-scan-1 AT ROW 1 COL 22
     b-clear-scan-1 AT ROW 1 COL 32
     b-scan-2 AT ROW 1 COL 42
     b-clear-scan-2 AT ROW 1 COL 52
     b-scan-3 AT ROW 1 COL 62
     b-clear-scan-3 AT ROW 1 COL 72
     b-help AT ROW 1 COL 82
     b-print AT ROW 2 COL 1
     b-export AT ROW 2 COL 16
     b-result AT ROW 3 COL 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Экран инвентаризации".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
/* BROWSE-TAB b-result b-export Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE b-result
/* Query rebuild information for BROWSE b-result
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH tt-result NO-LOCK INDEXED-REPOSITION.
     _END_FREEFORM
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _Query            is OPENED
*/  /* BROWSE b-result */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR OF FRAME Dialog-Frame /* Экран инвентаризации */
DO:
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ENDKEY OF FRAME Dialog-Frame /* Экран инвентаризации */
DO:
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON return OF FRAME Dialog-Frame /* Экран инвентаризации */
DO:
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Экран инвентаризации */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-clear-scan-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-clear-scan-1 Dialog-Frame
ON CHOOSE OF b-clear-scan-1 IN FRAME Dialog-Frame /* Аннул. 1 */
DO:
    IF varscan-1 <> YES THEN DO:
      MESSAGE "Первое сканирование еще не было сделано." VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
    END.
    IF varscan-3 = YES THEN DO:
      MESSAGE "Есть третье сканирование. Нельзя аннулировать второе." VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
    END.
    FOR EACH tt-result:
       ASSIGN
         tt-result.scan-1 = ?
         tt-result.diff-1-2 = 0
         tt-result.itog = ?.
    END.
    ASSIGN
      varscan-1 = NO.
    RUN open-query IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-clear-scan-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-clear-scan-2 Dialog-Frame
ON CHOOSE OF b-clear-scan-2 IN FRAME Dialog-Frame /* Аннул. 2 */
DO:
  IF varscan-2 <> YES THEN DO:
    MESSAGE "Второе сканирование еще не было сделано." VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  IF varscan-3 = YES THEN DO:
    MESSAGE "Есть третье сканирование. Нельзя аннулировать второе." VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  FOR EACH tt-result:
     ASSIGN
       tt-result.scan-2 = ?
       tt-result.diff-1-2 = 0
       tt-result.itog = ?.
  END.
  ASSIGN
    varscan-2 = NO.
  RUN open-query IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-clear-scan-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-clear-scan-3 Dialog-Frame
ON CHOOSE OF b-clear-scan-3 IN FRAME Dialog-Frame /* Аннул. 3 */
DO:
  IF varscan-3 = NO THEN DO:
    MESSAGE "Третье сканирование еще не было сделано." VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  IF varscan-1 <> YES THEN DO:
    MESSAGE "Критическая ошибка. Не было сделано первое сканирование." VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  IF varscan-2 <> YES THEN DO:
    MESSAGE "Критическая ошибка. Не было сделано второе сканирование." VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  FOR EACH tt-result :
    ASSIGN
      tt-result.scan-3 = "":u.
    IF tt-result.scan-1 = tt-result.scan-2 THEN DO:
      ASSIGN
        tt-result.itog = tt-result.scan-1.
    END.
    ELSE DO:
      ASSIGN
        tt-result.itog = ?.
    END.
  END.
  ASSIGN
    varscan-3 = NO.
  RUN open-query IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
  DEFINE VARIABLE varlog AS LOGICAL INITIAL YES.
  message "Вы действительно хотите выйти из интерфейса сравнения результатов?"
  view-as alert-box QUESTION BUTTONS YES-NO UPDATE varlog.
  if varlog <> yes then do:
    return no-apply.
  end.
  IF varsave-result = NO THEN DO:
    MESSAGE "Вы не сохранили в файл результаты. Хотите сохранить информацию?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE varlog.
    IF varlog = YES THEN DO:
      RUN save-itog IN THIS-PROCEDURE NO-ERROR.
      IF ERROR-STATUS:ERROR THEN DO:
        RETURN NO-APPLY.
      END.
    END.
  END.
  APPLY "go" TO FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-export Dialog-Frame
ON CHOOSE OF b-export IN FRAME Dialog-Frame /* Выгрузка списка */
DO:
  RUN save-diff IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-help Dialog-Frame
ON CHOOSE OF b-help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
  MESSAGE "Help for File: {&FILE-NAME}" VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать разницы */
DO:
  run rep/invlui2p.p (parparentproc  , INPUT TABLE tt-result).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME b-result
&Scoped-define SELF-NAME b-result
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-result Dialog-Frame
ON END-ERROR OF b-result IN FRAME Dialog-Frame
DO:
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-result Dialog-Frame
ON ENDKEY OF b-result IN FRAME Dialog-Frame
DO:
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-result Dialog-Frame
ON GO OF b-result IN FRAME Dialog-Frame
DO:
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-result Dialog-Frame
ON ROW-LEAVE OF b-result IN FRAME Dialog-Frame
DO:
  ASSIGN BROWSE {&browse-NAME}
      tt-result.itog.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Сохранить */
DO:
  RUN save-itog IN THIS-PROCEDURE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-scan-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-scan-1 Dialog-Frame
ON CHOOSE OF b-scan-1 IN FRAME Dialog-Frame /* 1-е скан. */
DO:
  IF varscan-3 = YES THEN DO:
    MESSAGE "Третье сканирование должно быть аннулировано, если производиться первое или второе."
    VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  IF varscan-1 THEN DO:
    MESSAGE "Первое сканирование уже было сделано." VIEW-AS ALERT-BOX.
    RETURN NO-APPLY.
  END.
  RUN scan-file (INPUT 1).
  ASSIGN
    varscan-1      = YES.
  IF varscan-2 = YES THEN DO:
    ASSIGN
      varsave-result = NO.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-scan-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-scan-2 Dialog-Frame
ON CHOOSE OF b-scan-2 IN FRAME Dialog-Frame /* 2-е скан. */
DO:
    IF varscan-3 = YES THEN DO:
      MESSAGE "Третье сканирование должно быть аннулировано, если производиться первое или второе."
      VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
    END.
    IF varscan-2 THEN DO:
      MESSAGE "Второе сканирование уже было сделано." VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
    END.
    RUN scan-file (INPUT 2).
    ASSIGN
      varscan-2      = YES.
    IF varscan-1 = YES THEN DO:
      ASSIGN
        varsave-result = NO.
    END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-scan-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-scan-3 Dialog-Frame
ON CHOOSE OF b-scan-3 IN FRAME Dialog-Frame /* 3-е скан. */
DO:
   IF varscan-1 <> YES OR varscan-2 <> YES THEN DO:
      MESSAGE "Третье сканирование может быть сделано только после первого и второго."
      VIEW-AS ALERT-BOX.
      RETURN NO-APPLY.
    END.
    RUN scan-file (INPUT 3).
    ASSIGN
        varscan-3 = YES
        varsave-result = NO.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
{ gbl/app_help.i }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

{ gbl/srt-clmn.i
&browse-name = {&browse-name}
&frame-name  = {&frame-name}
&table-name = "tt-result"
&ext-col = 8
&start-column  = 1
&label-clmn_1  = "'Артикул'"
&sort-clmn_1   = tt-result.artic
&label-clmn_2  = "'Наимен.!товара'"
&sort-clmn_2   = tt-result.gds-name
&label-clmn_3  = "'Рез-т!1-ого!сканир.'"
&sort-clmn_3   = tt-result.scan-1
&label-clmn_4  = "'Рез-т!2-ого!сканир.'"
&sort-clmn_4   = tt-result.scan-2
&label-clmn_5  = "'Разница!между!1 и 2!сканир.'"
&sort-clmn_5   = tt-result.diff-1-2
&label-clmn_6  = "'Рез-т!3-его!сканир.'"
&sort-clmn_6   = tt-result.scan-3
&label-clmn_7  = "'Итоги!по!инвентар.'"
&sort-clmn_7   = tt-result.itog
&label-clmn_8  = "'Бар-!код!товара'"
&sort-clmn_8   = tt-result.b-code
&open-query = "OPEN QUERY {&browse-name} FOR EACH tt-result NO-LOCK by ~{&sort-clmn_~{&clmn_num~}~} INDEXED-REPOSITION "
&open-query-otherwise = "OPEN QUERY {&browse-name} FOR EACH tt-result NO-LOCK INDEXED-REPOSITION. "
&re-move-clmn = "no"
&mv-brw-default = "no" }
  RUN enable_UI.
  ASSIGN
      tt-result.gds-name:resizable in browse {&browse-name} = true
      tt-result.gds-name:WIDTH = 10.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
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
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
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
  ENABLE b-exit b-save b-scan-1 b-clear-scan-1 b-scan-2 b-clear-scan-2 b-scan-3
         b-clear-scan-3 b-help b-print b-export b-result
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE open-query Dialog-Frame
PROCEDURE open-query :
IF AVAILABLE tt-result THEN DO:
  ASSIGN
    varrowid = ROWID(tt-result).
END.
ELSE DO:
  ASSIGN
    varrowid = ?.
END.
OPEN QUERY {&browse-NAME} FOR EACH tt-result NO-LOCK INDEXED-REPOSITION.
IF VARrowid <> ? THEN DO:
  REPOSITION {&browse-name} TO ROWID varrowid.
END.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-diff Dialog-Frame
PROCEDURE save-diff :
DEFINE BUFFER bf-diff_goods    FOR ub.goods.
define buffer bf-diff_bar-code for ub.bar-code.
define buffer bf-diff_prod-bc  for ub.prod-bc.
FOR EACH gds-list :
  DELETE gds-list.
END.
for each bb-list :
  delete bb-list.
end.
FOR EACH tt-result WHERE tt-result.diff-1-2 <> 0 BREAK BY tt-result.artic BY tt-result.prod-type BY tt-result.prod-code:
  FIND FIRST bf-diff_goods WHERE bf-diff_goods.artic     = tt-result.artic     AND
                                 bf-diff_goods.prod-type = tt-result.prod-type AND
                                 bf-diff_goods.prod-code = tt-result.prod-code NO-LOCK.
  find first bf-diff_bar-code where bf-diff_bar-code.b-code = tt-result.b-code no-lock.
  find first bf-diff_prod-bc where bf-diff_prod-bc.b-code = bf-diff_bar-code.b-code NO-LOCK NO-ERROR.
  IF FIRST-OF(tt-result.prod-code) THEN DO:
    { cmp/gds-list.i gds-list assign "''" bf-diff_goods }
  END.
  { cmp/bb-list.i bb-list assign bf-diff_goods bf-diff_bar-code bf-diff_prod-bc "'':u" "'':u" ? }
END.
run str/diallog.w (parparentproc
            , this-procedure
            , 'str/send-tsd.p':U
            , (parcurr-obj-type + {&delim-par} + string(parcurr-obj-code) + {&delim-par} + "bar-code")
            , no /*p-auto-go*/
            , '':U
            , 'Пересылка товаров на ТСД') no-error .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-itog Dialog-Frame
PROCEDURE save-itog :
DEFINE VARIABLE varlog AS LOGICAL   NO-UNDO.
DEFINE VARIABLE fname  AS character NO-UNDO.

FIND FIRST tt-result WHERE tt-result.itog = ? NO-ERROR.
IF AVAILABLE tt-result THEN DO:
  MESSAGE "Не определен итог у товара." tt-result.artic tt-result.gds-name tt-result.b-code VIEW-AS ALERT-BOX.
  RETURN ERROR.
END.
SYSTEM-DIALOG GET-FILE Fname
FILTERS "Все файлы"  "*.*"
TITLE "Выберите файл для хранения результата"
USE-FILENAME
UPDATE varlog.
if varlog then do:
  OUTPUT STREAM cur TO VALUE(Fname).
  FOR EACH tt-result:
    PUT STREAM cur UNFORMATTED tt-result.b-c "," tt-result.itog SKIP.
  END.
  assign
    varsave-result = yes.
  OUTPUT STREAM cur CLOSE.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE scan-file Dialog-Frame
PROCEDURE scan-file :
DEFINE INPUT PARAMETER parscan AS INTEGER NO-UNDO.
DEFINE VARIABLE scan-txt  AS CHARACTER NO-UNDO.
DEFINE VARIABLE scan-name AS CHARACTER NO-UNDO.
DEFINE VARIABLE varlog    AS LOGICAL   NO-UNDO.
DEFINE VARIABLE varview   AS INTEGER   NO-UNDO.
DEFINE VARIABLE varwork        AS INTEGER   NO-UNDO.
define variable varnoapnd      as logical   no-undo .
define variable vartype        as character no-undo.
define variable varerr         as logical   no-undo.
define variable is-err         as logical   no-undo initial no .
define variable vari           as integer   no-undo.
define variable vartime        as integer   no-undo.
define variable varuser-action as character no-undo.
define variable varprinted     as logical   no-undo.
define buffer bf_bar-code for ub.bar-code.
define buffer bf_goods    for ub.goods.
define buffer bf_gds-prt  for ub.gds-prt.
define frame a
    varview format ">>>>9" label "Просмотрено" space (20) skip
    varwork format ">>>>9" label "Обработано"
    with view-as dialog-box side-labels three-d title "".

system-dialog get-file scan-txt
  title "Выберите файл со сканера"
       filters "WorkAbout MS15"         "*.dbs",
               "WorkAbout"              "*.imp",
               "Инвентаризация с кассы" "*.inv",
               "Все файлы"               "*.*"
       update varlog.
if not varlog then return error.
if entry (2, scan-txt, ".") = "log" then do:
  message "Файл с расширением '.log' не может быть обработан. Переименуйте его.".
  return error.
end.
if entry (2, scan-txt, ".") = "err" then do:
  message "Файл с расширением '.err' не может быть обработан. Переименуйте его.".
  return error.
end.
if entry (2, scan-txt, ".") = "ler" then do:
  message "Файл с расширением '.ler' не может быть обработан. Переименуйте его.".
  return error.
end.

assign
  scan-name = entry (1, scan-txt, ".").
ASSIGN
  frame a:title = "Разбор файла : " + scan-txt.

{ gbl/getsect.i run "''" 0 {&attr-nakl-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'noapndsc' then varnoapnd = thbjattr_thbj-attr.property-value-logical  .
end.

if varnoapnd  then do:
  output stream log to value (scan-name + ".log").
  output stream err to value (scan-name + ".err").
  output stream ler to value (scan-name + ".ler").
end.
else do:
  output stream log to value (scan-name + ".log") append.
  output stream err to value (scan-name + ".err") append.
  output stream ler to value (scan-name + ".ler") append.
end.
put stream log unformatted "  " skip.
put stream log unformatted cur-time-string-sec() skip.
put stream ler unformatted "  " skip.
put stream ler unformatted cur-time-string-sec() skip.
view frame a.
input stream cur from value (scan-txt).
/*удалим контейнер для объединяющих бар-кодов*/
for each un-bc on error undo, return error return-value :
    delete un-bc.
end.
for each in-bc on error undo, return error return-value :
    delete in-bc.
end.
for each anlz-bc on error undo, return error return-value :
    delete anlz-bc.
end.
for each main-bc on error undo, return error return-value :
    delete main-bc.
end.



run str/bc-anlz.p (parparentproc, "file", scan-txt, yes, output varerr, output table in-bc) no-error.
if error-status:error then do:
  message "Ошибка при обработке файла сканера." skip
  view-as alert-box error buttons ok.
  return error.
end.
if varerr = yes then is-err = yes.
assign
  vari    = 0.
  vartime = time.
for each in-bc on error undo, return error return-value :
  assign
    vari = vari + 1.
  if in-bc.rez = "err" then do:
    put stream log unformatted in-bc.err-msg skip.
    put stream ler unformatted in-bc.err-msg skip.
    put stream err unformatted in-bc.bar-str skip.
    assign is-err = yes.
  end.
  if in-bc.des <> "" and in-bc.des <> ? then put stream log unformatted in-bc.des.
end.
for each un-bc on error undo, return error return-value :
  assign
    vari = vari + 1.
  if un-bc.rez = "err" then do:
    put stream log unformatted un-bc.err-msg skip.
    put stream ler unformatted un-bc.err-msg skip.
    put stream err unformatted un-bc.bar-code ", " un-bc.file-qnty skip.
    assign
      is-err = yes.
  end.
end.
assign
  varview = 0
  varwork = 0
  .
for each main-bc on error undo, return error return-value :
  varview = varview + 1.
  display varview with frame a.
  find first bf_bar-code where bf_bar-code.b-code   = main-bc.b-c           no-lock.
  find first bf_goods    where bf_goods.gds-code    = bf_bar-code.gds-code  no-lock.
  find first bf_gds-prt  where bf_gds-prt.node-code = bf_bar-code.node-code no-lock.
  if bf_gds-prt.is-term <> yes then do:
    put stream log unformatted "Бар-код " bf_bar-code.b-code " не является кодом терминального признака." skip.
    put stream ler unformatted "Бар-код " bf_bar-code.b-code " не является кодом терминального признака." skip.
    put stream err unformatted main-bc.b-c ", " main-bc.scn-qnty skip.
    assign is-err = yes.
    next.
  end.
  CASE parscan:
    WHEN 1 THEN DO:
      IF varscan-3 = YES THEN DO:
        RETURN ERROR "Третье сканирование должно быть аннулировано, когда производиться первое".
      END.
      FIND FIRST tt-result WHERE tt-result.artic     = bf_goods.artic       and
                                 tt-result.prod-type = bf_goods.prod-type   and
                                 tt-result.prod-code = bf_goods.prod-code   and
                                 tt-result.node-code = bf_gds-prt.node-code NO-ERROR.
      IF NOT AVAILABLE tt-result THEN DO:
        CREATE tt-result.
        ASSIGN
          tt-result.artic     = bf_goods.artic
          tt-result.prod-type = bf_goods.prod-type
          tt-result.prod-code = bf_goods.prod-code
          tt-result.node-code = bf_gds-prt.node-code
          tt-result.b-code    = main-bc.b-c
          tt-result.gds-name  = (if bf_gds-prt.node-name <> {&empty-scale} and bf_gds-prt.upper-code <> bf_goods.prt-root then bf_goods.gds-name + ' - ' + bf_gds-prt.f-name else bf_goods.gds-name)
         .
        IF varscan-2 = YES THEN DO:
          ASSIGN
            tt-result.scan-2 = 0.
        END.
      END.
      ASSIGN
        tt-result.scan-1 = main-bc.scn-qnty.
      IF varscan-2 = YES THEN DO:
        IF tt-result.scan-1 = tt-result.scan-2 THEN DO:
          ASSIGN
           tt-result.diff-1-2 = 0
           tt-result.itog     = tt-result.scan-1.
        END.
        ELSE DO:
          ASSIGN
            tt-result.diff-1-2 = ABS(tt-result.scan-1 - tt-result.scan-2)
            tt-result.itog     = ?.
        END.
      END.
      ELSE DO:
        ASSIGN
          tt-result.diff-1-2 = 0
          tt-result.itog     = ?.
      END.
    END.
    WHEN 2 THEN DO:
      IF varscan-3 = YES THEN DO:
        RETURN ERROR "Третье сканирование должно быть аннулировано, когда производиться первое".
      END.
      FIND FIRST tt-result WHERE tt-result.artic     = bf_goods.artic       and
                                 tt-result.prod-type = bf_goods.prod-type   and
                                 tt-result.prod-code = bf_goods.prod-code   and
                                 tt-result.node-code = bf_gds-prt.node-code NO-ERROR.
      IF NOT AVAILABLE tt-result THEN DO:
        CREATE tt-result.
        ASSIGN
          tt-result.artic     = bf_goods.artic
          tt-result.prod-type = bf_goods.prod-type
          tt-result.prod-code = bf_goods.prod-code
          tt-result.node-code = bf_gds-prt.node-code
          tt-result.b-code    = main-bc.b-c
          tt-result.gds-name  = (if bf_gds-prt.node-name <> {&empty-scale} and bf_gds-prt.upper-code <> bf_goods.prt-root then bf_goods.gds-name + ' - ' + bf_gds-prt.f-name else bf_goods.gds-name)
        .
        IF varscan-1 = YES THEN DO:
          ASSIGN
            tt-result.scan-1 = 0.
        END.

      END.
      ASSIGN
        tt-result.scan-2 = main-bc.scn-qnty.
      IF varscan-1 = YES THEN DO:
        IF tt-result.scan-1 = tt-result.scan-2 THEN DO:
          ASSIGN
           tt-result.diff-1-2 = 0
           tt-result.itog     = tt-result.scan-1.
        END.
        ELSE DO:
          ASSIGN
            tt-result.diff-1-2 = ABS(tt-result.scan-1 - tt-result.scan-2)
            tt-result.itog     = ?.
        END.
      END.
      ELSE DO:
        ASSIGN
          tt-result.diff-1-2 = 0
          tt-result.itog     = ?.
      END.
    END.
    WHEN 3 THEN DO:
      IF varscan-1 <> YES THEN DO:
        RETURN ERROR "Не было произведено первое сканирование.".
      END.
      IF varscan-2 <> YES THEN DO:
        RETURN ERROR "Не было произведено второе сканирование.".
      END.
      FIND FIRST tt-result WHERE tt-result.artic     = bf_goods.artic       and
                                 tt-result.prod-type = bf_goods.prod-type   and
                                 tt-result.prod-code = bf_goods.prod-code   and
                                 tt-result.node-code = bf_gds-prt.node-code NO-ERROR.
      IF NOT AVAILABLE tt-result THEN DO:
        put stream log unformatted "Бар-код " bf_bar-code.b-code " учавствовал в третьем сканировании. Но товара " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " по этому бар-коду не было в первых двух сканированиях." skip.
        put stream ler unformatted "Бар-код " bf_bar-code.b-code " учавствовал в третьем сканировании. Но товара " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " по этому бар-коду не было в первых двух сканированиях." skip.
        put stream err unformatted main-bc.b-c ", " main-bc.scn-qnty skip.
      END.
      ELSE DO:
        IF tt-result.scan-1 = tt-result.scan-2 THEN DO:
          put stream log unformatted "Бар-код " bf_bar-code.b-code " учавствовал в третьем сканировании. Но по этому товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " не было различия в первых двух сканированиях." skip.
          put stream ler unformatted "Бар-код " bf_bar-code.b-code " учавствовал в третьем сканировании. Но по этому товару " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " не было различия в первых двух сканированиях." skip.
          put stream err unformatted main-bc.b-c ", " main-bc.scn-qnty skip.
        END.
        ELSE DO:
          ASSIGN
            tt-result.scan-3 = string(main-bc.scn-qnty)
            tt-result.itog   = main-bc.scn-qnty.
        END.
      END.
    END.
    OTHERWISE DO:
      MESSAGE "Неизвестный номер сканирования: " parscan VIEW-AS ALERT-BOX ERROR.
      RETURN ERROR.
    END.
  END CASE.
  assign
    varwork = varwork + 1.
    display varwork with frame a.
end.
IF parscan = 1 OR parscan = 2 THEN DO:
  FOR EACH tt-result :
    FIND FIRST main-bc WHERE main-bc.b-c = tt-result.b-c NO-ERROR.
    IF NOT AVAILABLE main-bc THEN DO:
      IF parscan = 1 THEN DO:
        ASSIGN
          tt-result.scan-1 = 0.
      END.
      ELSE DO:
         ASSIGN
           tt-result.scan-2 = 0.
      END.
      IF tt-result.scan-1 = tt-result.scan-2 THEN DO:
        ASSIGN
         tt-result.diff-1-2 = 0
         tt-result.itog     = tt-result.scan-1.
      END.
      ELSE DO:
        ASSIGN
          tt-result.diff-1-2 = ABS(tt-result.scan-1 - tt-result.scan-2)
          tt-result.itog     = ?.
      END.
    END.
  END.
END.
if is-err then do:
  message "Во время загрузки файла:" scan-txt "обнаружены ошибки." skip
          "Смотрите ler файл."
  view-as alert-box error buttons ok.
  if search (scan-name + ".ler") <> ? then do:
    run gbl/prnfilen.w
      (input  substitute("Ошибки, обнаруженные во время загрузки файла &1", scan-txt)
      ,input  0
      ,input  scan-name + ".ler"
      ,input  7
      ,output varuser-action
      ,output varprinted
      ).
  end.
end.
output stream cur CLOSE.
output stream log CLOSE.
output stream err CLOSE.
output stream ler CLOSE.
RUN open-query IN THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME