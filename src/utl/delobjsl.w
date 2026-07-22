&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
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

Запуск процедуры удаления объекта

Автор: Перваков Михаил Сергеевич
Дата создания: 04/05/06
Author: Mikhail Pervakov
Creation date: 04/05/06

Удаление объекта по новостям не передается запускается где угодно!!!!!!
  вообщем очень опасная вещь
  режим - без проверок в самом деле все удаляет без проверок!!!!!!!!!!!

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запуск процедуры удаления объекта".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/mrk-strf.i }
{ cmp/showinf.i  }

define stream slog .
define variable v-rid-list as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-cli

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES ub.clients

/* Definitions for BROWSE br-cli                                        */
&Scoped-define FIELDS-IN-QUERY-br-cli ~
mark-string( input recid(ub.clients), input v-rid-list) ub.clients.obj-type ~
ub.clients.obj-code ub.clients.obj-name ub.clients.db-num
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-cli
&Scoped-define QUERY-STRING-br-cli FOR EACH ub.clients ~
      WHERE ( ( clients.obj-type = {&shop} ~
    and clients.obj-code > 0 ~
   ) ~
  OR ~
  ( clients.obj-type = {&stock} ~
    and clients.obj-code > 0 ~
   ) ~
) NO-LOCK
&Scoped-define OPEN-QUERY-br-cli OPEN QUERY br-cli FOR EACH ub.clients ~
      WHERE ( ( clients.obj-type = {&shop} ~
    and clients.obj-code > 0 ~
   ) ~
  OR ~
  ( clients.obj-type = {&stock} ~
    and clients.obj-code > 0 ~
   ) ~
) NO-LOCK.
&Scoped-define TABLES-IN-QUERY-br-cli ub.clients
&Scoped-define FIRST-TABLE-IN-QUERY-br-cli ub.clients


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-cli}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_Cancel b-mark b-inq b-del b-help br-cli
&Scoped-Define DISPLAYED-OBJECTS mark-num

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-del AUTO-GO
     LABEL "&Удалить"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-inq AUTO-GO
     LABEL "&Запрос"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE mark-num AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0
     LABEL "Отмечено строк"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-cli FOR
      ub.clients SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-cli Dialog-Frame _STRUCTURED
  QUERY br-cli NO-LOCK DISPLAY
      mark-string( input recid(ub.clients), input v-rid-list) COLUMN-LABEL "*" FORMAT "X(1)":U
      ub.clients.obj-type FORMAT "X(3)":U
      ub.clients.obj-code FORMAT ">>>>>>>>9":U
      ub.clients.obj-name FORMAT "X(40)":U
      ub.clients.db-num FORMAT ">>>>9":U
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH SEPARATORS SIZE 64.5 BY 10 ROW-HEIGHT-CHARS .67.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_Cancel AT ROW 1 COL 2
     b-mark AT ROW 1 COL 12 WIDGET-ID 2
     b-inq AT ROW 1 COL 15
     b-del AT ROW 1 COL 25 WIDGET-ID 4
     b-help AT ROW 1 COL 57
     mark-num AT ROW 2.25 COL 16.5 COLON-ALIGNED
     br-cli AT ROW 3.5 COL 2.5
     SPACE(1.24) SKIP(0.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Удаление объекта"
         DEFAULT-BUTTON b-inq CANCEL-BUTTON Btn_Cancel.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-cli mark-num Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-cli
/* Query rebuild information for BROWSE br-cli
     _TblList          = "ub.clients"
     _Options          = "NO-LOCK"
     _Where[1]         = "( ( clients.obj-type = {&shop}
    and clients.obj-code > 0
   )
  OR
  ( clients.obj-type = {&stock}
    and clients.obj-code > 0
   )
)"
     _FldNameList[1]   > "_<CALC>"
"mark-string( input recid(ub.clients), input v-rid-list)" "*" "X(1)" ? ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   = ub.clients.obj-type
     _FldNameList[3]   = ub.clients.obj-code
     _FldNameList[4]   = ub.clients.obj-name
     _FldNameList[5]   = ub.clients.db-num
     _Query            is OPENED
*/  /* BROWSE br-cli */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Удаление объекта */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-del Dialog-Frame
ON CHOOSE OF b-del IN FRAME Dialog-Frame /* Удалить */
DO:

  run delete-object in this-procedure
    (input "":U
    ,input "delete":U
    ) no-error .
  if error-status :error then do:
    undo, return no-apply .
  end.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-inq
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-inq Dialog-Frame
ON CHOOSE OF b-inq IN FRAME Dialog-Frame /* Запрос */
DO:

  define buffer buf_clients for ub.clients .
  define variable v-ind   as integer   no-undo .
  define variable v-recid as integer   no-undo .
  define variable v-obj-list as character no-undo .

  if v-rid-list = "":U then do:
    if available ub.clients then do:
      { gbl/markstrn.i ub.clients v-rid-list }
    end.
    else do:
      message
        "Не выбран клиент"
        view-as alert-box error .
      return no-apply.
    end.
  end.

  do v-ind = 1 to num-entries( v-rid-list )
  :
    assign
      v-recid = integer( entry( v-ind, v-rid-list, {&comma-char} ) )
      no-error
    .
    find first buf_clients no-lock
      where recid( buf_clients ) = v-recid
      no-error .
    if not available buf_clients then do:
      message
        substitute("Объект (recid &1) не найден", v-recid ) skip
        substitute("Полный список &1", v-rid-list ) skip
        view-as alert-box error .
      return no-apply .
    end.
    else do:
      assign
        v-obj-list = v-obj-list + {&comma-char} + substitute( "&1&2&3", buf_clients.obj-type, {&comma-char}, buf_clients.obj-code )
      .
    end.
  end.
  assign
    v-obj-list = left-trim( v-obj-list, {&comma-char} )
  .

  run delete-object in this-procedure
    (input v-obj-list
    ,input "inquiry":U
    ) no-error .
  if error-status :error then do:
    undo, return no-apply .
  end.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:

  define variable loc#log as logical no-undo .

  if available ub.clients then do:
    { gbl/markstrn.i ub.clients v-rid-list }
    loc#log = {&browse-name}:refresh() .

    if last-event:function <> "MOUSE-SELECT-DBLCLICK" then do:
        loc#log = {&browse-name}:select-next-row ().
        apply "VALUE-CHANGED" to {&browse-name} in frame {&frame-name}.
    end.
    if num-entries( v-rid-list ) = 0 then do:
      hide mark-num in frame {&frame-name}.
    end.
    else do:
      display
        num-entries( v-rid-list ) @ mark-num
        with frame {&frame-name}.
    end.
  end.
  apply "entry" to {&browse-name} in frame {&frame-name}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-cli
&Scoped-define SELF-NAME br-cli
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-cli Dialog-Frame
ON VALUE-CHANGED OF br-cli IN FRAME Dialog-Frame
DO:
/*  mark-num = br-cli:num-selected-rows.*/
/*  disp mark-num with frame {&frame-name}.*/
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


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

  define buffer buf_sys-ctrl for ub.sys-ctrl .

  find first buf_sys-ctrl no-lock .

  if buf_sys-ctrl.db-num <> 0 then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Данная утилита предназначена для работы только в ГБД" ) skip
      view-as alert-box error
    .
    return error .
  end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-qnty Dialog-Frame
PROCEDURE check-qnty :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-object Dialog-Frame
PROCEDURE delete-object :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define input  parameter p-obj-list          as character no-undo .
  define input  parameter p-action            as character no-undo .

  do
  on error undo, return error return-value
  :
    define variable v-ok           as logical   no-undo .
    define variable v-num          as integer   no-undo .
    define variable v-check-string as character no-undo .
    define variable v-passwd       as character no-undo .
    define variable v-pswd-list    as character no-undo .

    if p-action = "inquiry":U
      and p-obj-list = "":U
    then do:
      message
        substitute("Для запроса необходим список объектов") skip
        view-as alert-box error .
      return error .
    end.
    if p-action = "delete":U
      and p-obj-list <> "":U
    then do:
      message
        substitute("При удалении список объектов должен быть пустым. Он будет взят из файла.") skip
        view-as alert-box error .
      return error .
    end.
    assign
      v-pswd-list = "":U
    .
    run gbl/d-askw.w
      (input "Удаление объекта(ов)" /* Заголовок окна */
      ,input "Вы хотите удалить объект(ы)." + {&new-line} /* Общее сообщение */
        + substitute("&1", p-obj-list) + {&new-line}
        + "Вы действительно хотите сделать это?" + {&new-line}
      ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                  /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                  /* второй символ - разделитель атрибутов в описании кнопок */
      ,input "С проверкой остатков^confirm|Без проверки остатков^confirm|Отказ" /* список названий кнопок  */
                                      /* каждая кнопка может иметь необязательный */
                                      /* список атрибутов, влияющих на поведение кнопки */
      ,input "|" /* список описаний кнопок */
          + "|"
          + ""
      ,input 1 /* значение возвращаемое при нажатии enter */
      ,input 3 /* значение возвращаемое при нажатии escape */
      ,output v-num /* выбор пользователя */
      ).

    define variable v-check-rest as logical   no-undo .

    case v-num :
      when 1 then do:
        assign
          v-check-rest = true
        .
      end.
      when 2 then do:
        assign
          v-check-rest = false
        .
      end.
      when 3 then do:
        undo, return error return-value .
      end.
      otherwise do:
        message
          "" skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.

    define variable v-file-name as character no-undo .
    assign
      v-file-name = substitute('del-obj-&1.txt':u
                               , string( today, "99999999" )
                              )
    .

    run gbl/d-prompt.w (
        'title=':u + "Введите имя файла с паролем " + '\':u
      + 'text1=':u + "Введите имя файла с паролем на право удаления объекта" + '\':u
      + 'format=X(256)\':u
      + 'type=char\':u
      + 'boxprog=gbl/getfile.p\':u
      ,input-output v-file-name
      ).
    if return-value = 'false':u then do:
      return .
    end.

    case p-action :
      when "delete":U then do:
        if  search(v-file-name) <> ""
        and search(v-file-name) <> ?
        then do:
          assign
            v-pswd-list = "":U
            p-obj-list  = "":U
          .

          input stream slog from value(v-file-name) .

          block_read:
          repeat
          on error undo block_read, leave block_read
          on end-key undo block_read, leave block_read
          :
            import stream slog unformatted v-check-string .
            import stream slog unformatted v-passwd .
            if num-entries( v-check-string, {&comma-char} ) > 3
              and num-entries( v-passwd, {&comma-char} ) = 1
              and v-passwd <> "":U
            then do:
              assign
                p-obj-list  = p-obj-list + {&comma-char} + entry( 2, v-check-string, {&comma-char} ) + {&comma-char} + entry( 3, v-check-string, {&comma-char} )
                v-pswd-list = v-pswd-list + {&comma-char} + v-passwd
              .
            end.
          end.
          input stream slog close .

          assign
            p-obj-list  = substring( p-obj-list, 2, length( p-obj-list ) - 1 )
            v-pswd-list = substring( v-pswd-list, 2, length( v-pswd-list ) - 1 )
          .

          if v-passwd = "" then do:
            message
              "В файле не указан пароль для удаления объекта" skip
              "Отправте файл в службу поддержки пользователей" skip
              "Файл параметров" v-file-name skip
              view-as alert-box error .
          end.
        end.
        else do:
          message
            substitute("Файл &1 не найден", v-file-name) skip
            view-as alert-box error .
          return .
        end.
      end.
    end case.

    /* создание файла пароля - удаление объекта */
    run utl/del-obj.p
      (input p-obj-list
      ,input v-check-rest
      ,input v-pswd-list
      ,input v-file-name
      ) .

    case p-action :
      when "inquiry":U then do:
        message
          "Создан файл для получения пароля удаления объекта" skip
          "Отправьте файл" v-file-name skip
          view-as alert-box information .
      end.
      when "delete":U then do:
        message
          substitute("Объект(ы) удалены") skip
          view-as alert-box information .
      end.
    end case.

    run reopen-query in this-procedure .
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
  DISPLAY mark-num
      WITH FRAME Dialog-Frame.
  ENABLE Btn_Cancel b-mark b-inq b-del b-help br-cli
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE reopen-query Dialog-Frame
PROCEDURE reopen-query :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/

  define variable v-recid as recid     no-undo .

  do
  on error undo, return error return-value
  :
    do with frame {&frame-name}:
      get prev br-cli .
      if available ub.clients then do:
        assign
          v-recid = recid(ub.clients)
        .
      end.
      else do:
        get first br-cli.
        assign
          v-recid = recid(ub.clients)
        .
      end.
      {&open-query-{&browse-name}}
      reposition br-cli to recid v-recid no-error.
      apply "entry":u to br-cli.
      apply "value-changed":u to br-cli.
    end. /* do with frame */
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME