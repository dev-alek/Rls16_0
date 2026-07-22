define output parameter odate as date no-undo.
define output parameter oDocumentCreator as character no-undo.
define output parameter oDocumentCreatorBase as character no-undo.
define output parameter oOperationCode as character no-undo.
define output parameter oOperationContent as character no-undo.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Отмена"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.13
     BGCOLOR 8 .
DEFINE VARIABLE mDocCerator AS CHARACTER FORMAT "X(1000)":U
     LABEL "Наим. субъекта составителя"
     VIEW-AS FILL-IN
     SIZE 55 BY 1 TOOLTIP "НаимЭконСубСост" NO-UNDO.
DEFINE VARIABLE mDocCrBase AS CHARACTER FORMAT "X(256)":U
     LABEL "Доверенность"
     VIEW-AS FILL-IN
     SIZE 55 BY 1 TOOLTIP "ОснДоверОргСост" NO-UNDO.
DEFINE VARIABLE mDate AS DATE FORMAT "99/99/9999":U
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE mOperationCode AS CHARACTER FORMAT "X(256)":U
     LABEL "Вид операции"
     VIEW-AS FILL-IN
     SIZE 55 BY 1 TOOLTIP "ВидОперации" NO-UNDO.
DEFINE VARIABLE mOperationContent AS CHARACTER FORMAT "X(256)":U INITIAL "1"
     LABEL "Содержание операции"
     VIEW-AS  COMBO-BOX INNER-LINES 7
     LIST-ITEM-PAIRS "Принято без разногласий","1",
                     "Принято с разногласиями","2"
     SIZE 55 BY 1 TOOLTIP "СодОпер" NO-UNDO.
DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.25 COL 2
     Btn_Cancel AT ROW 1.25 COL 19
     mDate AT ROW 3 COL 35 COLON-ALIGNED WIDGET-ID 10
     mDocCerator AT ROW 4.5 COL 35 COLON-ALIGNED WIDGET-ID 2
     mDocCrBase AT ROW 6 COL 35 COLON-ALIGNED WIDGET-ID 4
     mOperationCode AT ROW 7.5 COL 35 COLON-ALIGNED WIDGET-ID 6
     mOperationContent AT ROW 9 COL 35 COLON-ALIGNED WIDGET-ID 8
     SPACE(2.74) SKIP(0.74)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Подпись документа"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
   assign
      mDate
      mDocCerator
      mDocCrBase
      mOperationCode
      mOperationContent
   .
   if    mDocCerator eq ""
      or mDocCerator eq ?
   then do:
      message "Наименование субъекта обязательно для заполнения" view-as alert-box.
      return no-apply.
   end.
   assign
      odate                 = mDate
      oDocumentCreator      = mDocCerator
      oDocumentCreatorBase  = mDocCrBase
      oOperationCode        = mOperationCode
      oOperationContent     = mOperationContent
   .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
      mDate = today.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY mDate mDocCerator mDocCrBase mOperationCode mOperationContent
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel mDate mDocCerator mDocCrBase mOperationCode
         mOperationContent
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
