&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Параметры файла альтернативного импорта товаров

Автор: Румянцев Юрий Александрович
Дата создания: 07/26/05
Author: Yuri Rumyantsev
Creation date: 07/26/05

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER vattaxcd as integer no-undo.
DEFINE INPUT PARAMETER slttaxcd as integer no-undo.
DEFINE OUTPUT PARAMETER v_os-file   AS CHAR NO-UNDO INIT "".
DEFINE OUTPUT PARAMETER choice      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-artic     AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-name      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-engl-name AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-unit-base AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-VAT-code  AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-SLT-code  AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-struct      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-11      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-22      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-33      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-44      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-city      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-grp      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-gds-prt      AS integer NO-UNDO.
DEFINE OUTPUT PARAMETER p-client      AS integer NO-UNDO.

DEFINE OUTPUT PARAMETER  line     AS integer NO-UNDO.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Параметры файла альтернативного импорта товаров" .

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i }

DEFINE stream gds-file.

&SCOPED-DEFINE p-artic 1
&SCOPED-DEFINE p-name 2
&SCOPED-DEFINE p-engl-name 3
&SCOPED-DEFINE p-unit-base 4
&SCOPED-DEFINE p-VAT-code 5
&SCOPED-DEFINE p-SLT-code 6
&SCOPED-DEFINE p-struct 7
&SCOPED-DEFINE p-11 8
&SCOPED-DEFINE p-22 9
&SCOPED-DEFINE p-33 10
&SCOPED-DEFINE p-44 11
&SCOPED-DEFINE p-city 12
&SCOPED-DEFINE p-grp 13
&SCOPED-DEFINE p-gds-prt 14
&SCOPED-DEFINE p-client 15

define temp-table temp_grplib_found-grp no-undo
    field full-name  as character
    field node-code  as integer
    field level      as integer
    index pi is primary unique full-name
    index lv level
.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-atribut B-exit b-quit B-file file-name ~
RS-codir T-engl-name T-unit-base T-VAT-code T-SLT-code T-struct T-11 T-22 ~
T-33 T-44 T-city T-grp T-gds-prt T-client
&Scoped-Define DISPLAYED-OBJECTS file-name T-artic RS-codir T-name ~
T-engl-name T-unit-base T-VAT-code T-SLT-code T-struct T-11 T-22 T-33 T-44 ~
T-city T-grp T-gds-prt T-client

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл импорта"
     VIEW-AS FILL-IN
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE RS-codir AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "1251", 1,
"KOI8-R", 2
     SIZE 15.25 BY 2.63 NO-UNDO.

DEFINE RECTANGLE RECT-atribut
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 30.63 BY 12.83.

DEFINE VARIABLE T-11 AS LOGICAL INITIAL no
     LABEL "Назначение товара"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-22 AS LOGICAL INITIAL no
     LABEL "Характеристики товара"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-33 AS LOGICAL INITIAL no
     LABEL "Правила эксплуатации"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-44 AS LOGICAL INITIAL no
     LABEL "Сертификат товара"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-artic AS LOGICAL INITIAL yes
     LABEL "Артикул"
     VIEW-AS TOGGLE-BOX
     SIZE 17 BY 1 NO-UNDO.

DEFINE VARIABLE T-city AS LOGICAL INITIAL no
     LABEL "Страна"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-client AS LOGICAL INITIAL no
     LABEL "Производитель"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-engl-name AS LOGICAL INITIAL no
     LABEL "Англ. название"
     VIEW-AS TOGGLE-BOX
     SIZE 17.63 BY 1 NO-UNDO.

DEFINE VARIABLE T-gds-prt AS LOGICAL INITIAL no
     LABEL "Шкала"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-grp AS LOGICAL INITIAL no
     LABEL "Группа товара"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-name AS LOGICAL INITIAL yes
     LABEL "Название"
     VIEW-AS TOGGLE-BOX
     SIZE 17.75 BY 1 NO-UNDO.

DEFINE VARIABLE T-SLT-code AS LOGICAL INITIAL no
     LABEL "Код НП"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-struct AS LOGICAL INITIAL no
     LABEL "Состав сырья"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.

DEFINE VARIABLE T-unit-base AS LOGICAL INITIAL no
     LABEL "Основная единица измерения"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.

DEFINE VARIABLE T-VAT-code AS LOGICAL INITIAL no
     LABEL "Код НДС"
     VIEW-AS TOGGLE-BOX
     SIZE 20.5 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1.13
     b-quit AT ROW 1 COL 11.13
     B-file AT ROW 2.88 COL 43.13
     file-name AT ROW 2.92 COL 3.38
     T-artic AT ROW 5 COL 24.5
     RS-codir AT ROW 5.38 COL 3.38 NO-LABEL
     T-name AT ROW 5.79 COL 24.5
     T-engl-name AT ROW 6.58 COL 24.5
     T-unit-base AT ROW 7.42 COL 24.5
     T-VAT-code AT ROW 8.21 COL 24.5
     T-SLT-code AT ROW 9 COL 24.5
     T-struct AT ROW 9.79 COL 24.5
     T-11 AT ROW 10.58 COL 24.5
     T-22 AT ROW 11.42 COL 24.5
     T-33 AT ROW 12.21 COL 24.5
     T-44 AT ROW 13 COL 24.5
     T-city AT ROW 13.79 COL 24.5
     T-grp AT ROW 14.58 COL 24.5
     T-gds-prt AT ROW 15.42 COL 24.5
     T-client AT ROW 16.21 COL 24.5
     RECT-atribut AT ROW 4.42 COL 24
     "Кодировка" VIEW-AS TEXT
          SIZE 15.75 BY .92 AT ROW 4.21 COL 3.38
     "Импортируемые поля" VIEW-AS TEXT
          SIZE 19.25 BY .88 AT ROW 4 COL 26.25
          FGCOLOR 3
     SPACE(10.37) SKIP(12.69)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Параметры файла импорта"
         DEFAULT-BUTTON B-exit CANCEL-BUTTON b-quit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN file-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* SETTINGS FOR TOGGLE-BOX T-artic IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR TOGGLE-BOX T-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Параметры файла импорта */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Ввод */
DO:
  define variable NEN as integer No-UNDO.
  define variable vars as integer no-undo EXTENT 15.

  assign
  file-name
  v_os-file = file-name
  RS-codir
  choice = RS-codir
  T-artic
  T-name
  T-engl-name
  T-unit-base
  T-VAT-code
  T-SLT-code
  T-struct
  T-11
  T-22
  T-33
  T-44
  T-city
  T-grp
  T-gds-prt
  T-client



  NEN = NEN + integer(T-artic)
  vars[{&p-artic}] = NEN
  p-artic = vars[{&p-artic}]
  NEN = NEN + integer(T-name)
  vars[{&p-name}] = if T-name then NEN else 0
  p-name = vars[{&p-name}]
  NEN = NEN + integer(T-engl-name)
  vars[{&p-engl-name}] = if T-engl-name then NEN else 0
  p-engl-name = vars[{&p-engl-name}]
  NEN = NEN + integer(T-unit-base)
  vars[{&p-unit-base}] = if T-unit-base then NEN else 0
  p-unit-base = vars[{&p-unit-base}]
  NEN = NEN + integer(T-VAT-code)
  vars[{&p-VAT-code}] = if T-VAT-code then NEN else 0
  p-VAT-code = vars[{&p-VAT-code}]
  NEN = NEN + integer(T-SLT-code)
  vars[{&p-SLT-code}] = if T-SLT-code then NEN else 0
  p-SLT-code = vars[{&p-SLT-code}]
  NEN = NEN + integer(T-Struct)
  vars[{&p-Struct}] = if T-Struct then NEN else 0
  p-Struct = vars[{&p-Struct}]

  NEN = NEN + integer(T-11)
  vars[{&p-11}] = if T-11 then NEN else 0
  p-grp = vars[{&p-11}]
  NEN = NEN + integer(T-22)
  vars[{&p-22}] = if T-22 then NEN else 0
  p-grp = vars[{&p-22}]
  NEN = NEN + integer(T-33)
  vars[{&p-33}] = if T-33 then NEN else 0
  p-grp = vars[{&p-33}]
  NEN = NEN + integer(T-44)
  vars[{&p-44}] = if T-44 then NEN else 0
  p-grp = vars[{&p-44}]

  NEN = NEN + integer(T-city)
  vars[{&p-city}] = if T-city then NEN else 0
  p-city = vars[{&p-city}]
  NEN = NEN + integer(T-grp)
  vars[{&p-grp}] = if T-grp then NEN else 0
  p-grp = vars[{&p-grp}]
  NEN = NEN + integer(T-gds-prt)
  vars[{&p-gds-prt}] = if T-gds-prt then NEN else 0
  p-gds-prt = vars[{&p-gds-prt}]
  NEN = NEN + integer(T-client)
  vars[{&p-client}] = if T-client then NEN else 0
  p-client = vars[{&p-client}]
  .

/*disp nem T-Struct p-struct T-grp p-grp. pause.*/

  IF v_os-file = "" or v_os-file = ? then do:
    message "Не определен файл импорта!" view-as alert-box ERROR.
    return no-apply.
  END.

  IF (T-SLT-code OR T-VAt-code) AND NOT T-unit-base then do:
    message "Невозможно импортировать код НДС и/или код НП" SKIP
            "без импорта основной единицы измерения" view-as alert-box ERROR.
    return no-apply.
  end.

  line = NEN.


  CASE choice:
        WHEN 1 then do:
            input stream gds-file from value (v_os-file) convert source "1251".
        END.
        WHEN 2 then do:
            input stream gds-file from value (v_os-file) convert source "KOI8-R".
        END.
  END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file Dialog-Frame
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:

    define variable ll_commit AS LOG    NO-UNDO INIT NO.

    SYSTEM-DIALOG GET-FILE v_os-file
        TITLE "Выберите файл для импорта"
        FILTERS
          " Текстовые файлы (*.gim) " "*.gim",
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        return-to-start-dir
        must-exist
        update ll_commit
        default-extension "gim"
        .
    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN file-name = ( IF SEARCH( v_os-file ) = ? THEN v_os-file ELSE SEARCH( v_os-file ) ).
    DISP file-name WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-quit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-quit Dialog-Frame
ON CHOOSE OF b-quit IN FRAME Dialog-Frame /* Отказ */
DO:
    assign v_os-file = "".
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME file-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL file-name Dialog-Frame
ON LEAVE OF file-name IN FRAME Dialog-Frame /* Файл импорта */
DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.
        DISP file-name WITH FRAME {&FRAME-NAME}.
    END.
    APPLY "TAB":U TO file-name IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
/*{ gbl/app_help.i }*/

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
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


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
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
  DISPLAY file-name T-artic RS-codir T-name T-engl-name T-unit-base T-VAT-code
          T-SLT-code T-struct T-11 T-22 T-33 T-44 T-city T-grp T-gds-prt
          T-client
      WITH FRAME Dialog-Frame.
  ENABLE RECT-atribut B-exit b-quit B-file file-name RS-codir T-engl-name
         T-unit-base T-VAT-code T-SLT-code T-struct T-11 T-22 T-33 T-44 T-city
         T-grp T-gds-prt T-client
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-node-code Dialog-Frame
PROCEDURE get-node-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
/*  По полному пути группы выдает КОД последнего гзла  */

define input parameter p-search-name  as character    no-undo.
define output parameter cod-grp  like gds-grp.node-code no-undo.

define var p-fill-path    as logical      no-undo.
define variable v-upper-code    as integer          no-undo.
define variable v-not-found     as logical init yes no-undo.
define variable v-counter       as integer           no-undo.
define variable v-level         as integer           no-undo.
define variable v-full-name     as character         no-undo.

define buffer buf_gds-grp       for gds-grp.


run grplib-get-root-code ( output v-upper-code ) no-error .

if error-status :error
    then do:
        undo, return error "grplib-expand-name: Ошибка при поиске корневого узла".
end.
assign
    v-full-name  = ""
    v-level      = num-entries( p-search-name, {&slash-char} ) .


for each temp_grplib_found-grp    :
    delete temp_grplib_found-grp.
end.

start-name-analyze:
do v-counter = 1 to v-level :
    if v-counter < v-level  then do:        /* Для всех групп кроме последней ищем точное совпадение */
            find first buf_gds-grp no-lock
                 where buf_gds-grp.upper-code = v-upper-code
                   and buf_gds-grp.node-name  = entry( v-counter, p-search-name, {&slash-char} )
            no-error .
            if not available buf_gds-grp
            then do: /* Не обнаружена группа с таким названием */
                assign
                    v-full-name  = p-search-name
                .
                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, {&slash-char} ).
            end.
            else do:        /*  Есть такая группа. Идем дальше. */
                assign
                    v-full-name = v-full-name + (if v-full-name = "" then "" else {&slash-char}) + buf_gds-grp.node-name
                    v-upper-code = buf_gds-grp.node-code
                .
                if p-fill-path = yes
                then do:
                    create temp_grplib_found-grp.
                    assign
                        temp_grplib_found-grp.full-name = v-full-name
                        temp_grplib_found-grp.node-code = v-upper-code
                        temp_grplib_found-grp.level     = v-counter
                    .
                end.
            end.
    end.
    else do:        /* Для последней группы ищем совпадение по начальным символам и составляем список таких групп */
            for each buf_gds-grp no-lock
               where buf_gds-grp.upper-code = v-upper-code
                 and buf_gds-grp.node-name begins entry( v-counter, p-search-name, {&slash-char} )
            :
                assign
                    v-not-found = no
                .
                create temp_grplib_found-grp.
                assign
                    temp_grplib_found-grp.full-name = v-full-name
                                                        + (if v-full-name = "" then "" else {&slash-char})
                                                        + buf_gds-grp.node-name
                    temp_grplib_found-grp.node-code = buf_gds-grp.node-code
                    temp_grplib_found-grp.level     = v-level
                .
            end.
            if v-not-found = yes
            then do: /* Нет ни одной группы с таким названием */
                assign
                    v-full-name  = p-search-name
                .
                for each temp_grplib_found-grp
                :
                    delete temp_grplib_found-grp.
                end.
                return error "grplib-expand-name: не найдена группа " + entry( v-level, p-search-name, {&slash-char} ).
            end.
    end.
end.

for each temp_grplib_found-grp no-lock:
  cod-grp =  temp_grplib_found-grp.node-code.
end.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE grplib-get-root-code Dialog-Frame
PROCEDURE grplib-get-root-code :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define output parameter p-root-code as integer      no-undo.

define buffer buf_gds-grp       for gds-grp.

    find first buf_gds-grp no-lock
        where buf_gds-grp.upper-code = 0
    no-error .
    if not available buf_gds-grp
    then do:
        undo, return error .
    end.
    else do:
        assign
            p-root-code = buf_gds-grp.node-code
        .
    end.
end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
