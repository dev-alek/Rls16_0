define input        parameter parparentproc as handle    no-undo .
define variable v-pl-code as integer no-undo .
define variable pl-recid-list as character no-undo .
define buffer buf_user-login        for ub.user-login .
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE BUTTON b-place
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "b-place"
     SIZE 3 BY .86.
DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE BUTTON Btn_OK
     LABEL "Применить"
     SIZE 15 BY 1.14
     BGCOLOR 8 .
DEFINE VARIABLE f-pl-num AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE QUERY br-place-imp FOR
      place-imp SCROLLING.
DEFINE BROWSE br-place-imp
  QUERY br-place-imp NO-LOCK DISPLAY
      place-imp.table-version column-label "Номер версии" FORMAT ">>>>>>>>>9":U
      place-imp.corr-date column-label 'Дата получения статуса!"Ожидает применения"' FORMAT "99/99/9999":U
      string(place-imp.corr-time, "hh:mm:ss") column-label 'Время получения статуса!"Ожидает применения"' FORMAT "X(8)":U
    WITH NO-ROW-MARKERS SEPARATORS SIZE 75 BY 6.19 FIT-LAST-COLUMN.
DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1.24 COL 2
     Btn_OK AT ROW 1.24 COL 17
     f-pl-num AT ROW 3.3 COL 1 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     b-place AT ROW 3.3 COL 18.4 WIDGET-ID 38
     br-place-imp AT ROW 4.9 COL 3 WIDGET-ID 200
     "Выбор резервуара:" VIEW-AS TEXT
          SIZE 20 BY .86 AT ROW 2.38 COL 2 WIDGET-ID 2
     SPACE(56.99) SKIP(7.99)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Утилита применения новых градуировочных таблиц"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       f-pl-num:READ-ONLY IN FRAME Dialog-Frame        = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-place IN FRAME Dialog-Frame
DO:
  define buffer buf_place for ub.place .
  run ref/pl-list.w (
     input parparentproc
    ,input "b-sel"
    ,input v-cntxt-obj-type
    ,input v-cntxt-obj-code
    ,input 'объект':U
    ,input-output pl-recid-list).
  if pl-recid-list = "cancel"
  then do :
    return no-apply .
  end .
  find first buf_place no-lock where recid(buf_place) = integer(pl-recid-list) no-error .
  if available buf_place
  then do :
    assign
      v-pl-code = buf_place.pl-code
      f-pl-num = buf_place.loc1
    .
    display f-pl-num with frame Dialog-Frame .
  end .
  else do :
    assign
      v-pl-code = ?
      f-pl-num = "?"
    .
    display f-pl-num with frame Dialog-Frame .
  end .
  OPEN QUERY br-place-imp FOR EACH place-imp       WHERE place-imp.status_ = 0 and place-imp.obj-type = v-cntxt-obj-type and place-imp.obj-code = v-cntxt-obj-code and place-imp.pl-code = v-pl-code NO-LOCK INDEXED-REPOSITION.
END.
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame
DO:
  define buffer buf_place-imp for ub.place-imp .
  define buffer buf_place-attr for ub.place-attr .
  if available place-imp
  then do :
    for each buf_place-imp no-lock where buf_place-imp.obj-type = v-cntxt-obj-type
                                     and buf_place-imp.obj-code = v-cntxt-obj-code
                                     and buf_place-imp.pl-code  = v-pl-code
                                     and buf_place-imp.status_  = 0
                                     by buf_place-imp.table-version
    :
      run str/apply_place-imp.p (input buf_place-imp.obj-type,
                                 input buf_place-imp.obj-code,
                                 input buf_place-imp.pl-code,
                                 input buf_place-imp.table-version)
                                 no-error .
    end .
    find first buf_place-attr exclusive-lock where buf_place-attr.obj-type = v-cntxt-obj-type
                                               and buf_place-attr.obj-code = v-cntxt-obj-code
                                               and buf_place-attr.pl-code  = v-pl-code
                                               and buf_place-attr.attr-code = "pending-table-version"
                                               no-error .
    if available buf_place-attr
    then do :
      delete buf_place-attr .
    end .
    message "Новые данные успешно применены!" view-as alert-box .
    OPEN QUERY br-place-imp FOR EACH place-imp       WHERE place-imp.status_ = 0 and place-imp.obj-type = v-cntxt-obj-type and place-imp.obj-code = v-cntxt-obj-code and place-imp.pl-code = v-pl-code NO-LOCK INDEXED-REPOSITION.
  end .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find first buf_user-login no-lock
      where buf_user-login.db-num  = g#db-num
        and buf_user-login.user-id = g#userid
      no-error .
  if not available buf_user-login
  then do :
    message "Неизвестный пользователь!" view-as alert-box error .
    return .
  end .
  if not buf_user-login.user-administrator
  then do :
    message "Данный функционал доступен только для администратора!" view-as alert-box .
    return .
  end .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f-pl-num
      WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel Btn_OK f-pl-num b-place br-place-imp
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY br-place-imp FOR EACH place-imp       WHERE place-imp.status_ = 0 and place-imp.obj-type = v-cntxt-obj-type and place-imp.obj-code = v-cntxt-obj-code and place-imp.pl-code = v-pl-code NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
