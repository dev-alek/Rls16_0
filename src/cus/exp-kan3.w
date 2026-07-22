&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
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

Экспорт результатов продаж    Заказчика "Кан-Ру"

Автор: Житкевич Александр Николаевич
Дата создания: 04/12/06
Author: Zhitkevich
Creation date: 04/12/06


*/


/*------------------------------------------------------------------------

  File:

  Description:

  Input Parameters:
      <none>

  Output Parameters:
      <none>

  Author:

  Created:
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


 /* define input parameter parparentproc as widget-handle no-undo .

  define input parameter p-task-type      as character    no-undo.
  define input parameter p-task-num       as integer      no-undo.
  define input parameter p-db-num-char    as character    no-undo.
  define output parameter p-params        as character    no-undo.
   */

   define input parameter parparentproc as widget-handle no-undo .
   define variable vss-revision    as character no-undo init "$Revision$":U .
   define variable vss-author      as character no-undo init "$Author$":U .
   define variable vss-date        as character no-undo init "$Date$":U .
   define variable vss-workfile    as character no-undo init "$Workfile$":U .
   define variable vss-archive     as character no-undo init "$Archive$":U .
   define variable vss-description as character no-undo init "Экспорт текущих остатков, товарных накладных, внешних расходных накладных ".

   DEFINE variable loghandle AS HANDLE no-undo.
   DEFINE VARIABLE logstring AS CHARACTER no-undo.
   define variable par1 as widget-handle  no-undo.
   define variable par2 as widget-handle  no-undo.
   define variable file-name as char no-undo.
   define variable v-paramdop as char no-undo.  /* переменная хранит в себе путь для выгрузки кассиров и пересорт */






   DEFINE VARIABLE v-param-list AS CHARACTER NO-UNDO.
   define variable st as char no-undo. /*Статус R or W */

 { cmp/showinf.i }
 { gbl/waitfram.i }
 { cmp/str-glbl.i }
 { bge/doctype.i}
 { cmp/vssrevis.i }
 { ref/shd-attr.i }
 { gbl/cur-time.i }
 { cmp/ini-lib.i  }

  DEFINE STREAM v-s1.

  define buffer buf_schedule for ub.schedule.
  define buffer buf_schedule-attr for ub.schedule-attr.
  define buffer buf_trn-doc for ub.trn-doc.
  define buffer buf_c-trn-doc for ub.c-trn-doc.
  define buffer buf_gds-dtl for gds-dtl.
  define buffer buf_gds-prt for gds-prt.

  /* буфер для временной таблицы   outs внешн систем  test1 - тоесть если склад то W если магазин то R */
  DEFINE TEMP-TABLE imptable
     FIELD obj-type LIKE trn-doc.obj-type
     FIELD obj-code LIKE trn-doc.obj-code
     FIELD st AS CHARACTER FORMAT "x(76)".    /* параметр который будет подставляться */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS dateb dateend staff peresort rasvn udal ~
prihod rasvne fnsoot B-file-4 e-mail Btn_OK Btn_Cancel 
&Scoped-Define DISPLAYED-OBJECTS dateb dateend staff fnkassir peresort ~
fnperesort rasvn fnrasvn udal fnudal prihod fnprih rasvne fnrasvne fnsoot ~
e-mail 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.5 BY 1.

DEFINE BUTTON B-file-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.5 BY 1.

DEFINE BUTTON B-file-3
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.5 BY 1.

DEFINE BUTTON B-file-4
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.5 BY 1.

DEFINE BUTTON B-file-5 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 2.5 BY 1.

DEFINE BUTTON B-file-6
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.5 BY 1.

DEFINE BUTTON B-file-9
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.5 BY 1.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "Выход"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "Ввод"
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE VARIABLE dateb AS DATE FORMAT "99/99/9999":U
     LABEL "Выгрузить С"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE dateend AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE e-mail AS CHARACTER FORMAT "X(256)":U
     LABEL "e-mail"
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.

DEFINE VARIABLE fnkassir AS CHARACTER FORMAT "X(256)":U
     LABEL "Выгрузка кассиров"
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.

DEFINE VARIABLE fnperesort AS CHARACTER FORMAT "X(256)":U
     LABEL "Выгрузка док. пересортицы"
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.

DEFINE VARIABLE fnprih AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл приход внешний"
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.

DEFINE VARIABLE fnrasvn AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл расход внутренний"
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.

DEFINE VARIABLE fnrasvne AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл расход внешний"
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.

DEFINE VARIABLE fnsoot AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл соответствий"
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.






DEFINE VARIABLE fnudal AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл удал. накл. рас. вн."
     VIEW-AS FILL-IN
     SIZE 32.5 BY 1 NO-UNDO.

DEFINE VARIABLE peresort AS LOGICAL INITIAL no
     LABEL "Выгрузка док. пересортицы"
     VIEW-AS TOGGLE-BOX
     SIZE 28.5 BY .83 NO-UNDO.

DEFINE VARIABLE prihod AS LOGICAL INITIAL no
     LABEL "Выгрузка для прихода внешнего"
     VIEW-AS TOGGLE-BOX
     SIZE 34 BY .83 NO-UNDO.

DEFINE VARIABLE rasvn AS LOGICAL INITIAL no
     LABEL "Выгрузка для расхода внутреннего"
     VIEW-AS TOGGLE-BOX
     SIZE 34 BY .83 NO-UNDO.

DEFINE VARIABLE rasvne AS LOGICAL INITIAL no 
     LABEL "Выгрузка для расхода внешнего"
     VIEW-AS TOGGLE-BOX
     SIZE 34 BY .83 NO-UNDO.

DEFINE VARIABLE staff AS LOGICAL INITIAL no
     LABEL "Выгрузка кассиров"
     VIEW-AS TOGGLE-BOX
     SIZE 20 BY .83 NO-UNDO.

DEFINE VARIABLE udal AS LOGICAL INITIAL no
     LABEL "Выгрузка для удаленных накладных"
     VIEW-AS TOGGLE-BOX
     SIZE 34 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     dateb AT ROW 2 COL 27.5 COLON-ALIGNED WIDGET-ID 42
     dateend AT ROW 2 COL 46 COLON-ALIGNED WIDGET-ID 44
     staff AT ROW 3.75 COL 29.5 WIDGET-ID 50
     fnkassir AT ROW 5 COL 10.5 WIDGET-ID 72
     B-file-6 AT ROW 5 COL 62.5 WIDGET-ID 58
     peresort AT ROW 6.5 COL 29.5 WIDGET-ID 52
     fnperesort AT ROW 7.75 COL 2.5 WIDGET-ID 70
     B-file-9 AT ROW 7.75 COL 62.5 WIDGET-ID 66
     rasvn AT ROW 9.5 COL 29.5 WIDGET-ID 74
     fnrasvn AT ROW 10.75 COL 5.5 WIDGET-ID 40
     B-file AT ROW 10.75 COL 62.5 WIDGET-ID 20
     udal AT ROW 12.5 COL 29.5 WIDGET-ID 76
     fnudal AT ROW 13.75 COL 2.5 WIDGET-ID 34
     B-file-2 AT ROW 13.75 COL 62.5 WIDGET-ID 32
     prihod AT ROW 15.5 COL 29.5 WIDGET-ID 78
     fnprih AT ROW 16.75 COL 8.5 WIDGET-ID 38
     B-file-3 AT ROW 16.75 COL 62.5 WIDGET-ID 36
     rasvne AT ROW 18.5 COL 29.5 WIDGET-ID 86
     fnrasvne AT ROW 19.75 COL 8.5 WIDGET-ID 84
     B-file-5 AT ROW 19.75 COL 62.5 WIDGET-ID 82
     fnsoot AT ROW 22 COL 27.5 COLON-ALIGNED WIDGET-ID 46
     B-file-4 AT ROW 22 COL 62.5 WIDGET-ID 48
     e-mail AT ROW 24.29 COL 27.5 COLON-ALIGNED WIDGET-ID 80
     Btn_OK AT ROW 26.5 COL 10
     Btn_Cancel AT ROW 26.5 COL 48
     SPACE(8.19) SKIP(0.98)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Экспорт текущих товарных остатков"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Other Settings: COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-file IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-file-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-file-3 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-file-5 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-file-6 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR BUTTON B-file-9 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN fnkassir IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fnperesort IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fnprih IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fnrasvn IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fnrasvne IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fnudal IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Экспорт текущих товарных остатков */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file Dialog-Frame
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:

    DEF VAR ll_commit1 AS LOG    NO-UNDO INIT NO.
    define variable v_os-file1 as char no-undo.

    SYSTEM-DIALOG GET-FILE v_os-file1
        TITLE "Выберите файл для экспорта"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        /*ask-overwrite*/
        save-as
        use-filename
        update ll_commit1
        default-extension "txt"
        .
    IF ll_commit1 <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file1 = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN fnrasvn = ( IF SEARCH( v_os-file1 ) = ? THEN   v_os-file1  ELSE SEARCH( v_os-file1 ) ).


    DISP fnrasvn WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file-2 Dialog-Frame
ON CHOOSE OF B-file-2 IN FRAME Dialog-Frame
DO:

    DEF VAR ll_commit2 AS LOG    NO-UNDO INIT NO.
    define variable v_os-file2 as char no-undo.

    SYSTEM-DIALOG GET-FILE v_os-file2
        TITLE "Выберите файл для экспорта"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
       /* ask-overwrite */
        save-as
        use-filename
        update ll_commit2
        default-extension "txt"
        .
    IF ll_commit2 <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file2 = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN fnudal = ( IF SEARCH( v_os-file2 ) = ? THEN  v_os-file2 ELSE SEARCH( v_os-file2 ) ).
       DISP fnudal WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file-3 Dialog-Frame
ON CHOOSE OF B-file-3 IN FRAME Dialog-Frame
DO:




    DEF VAR ll_commit3 AS LOG    NO-UNDO INIT NO.
    define variable v_os-file3 as char no-undo.

    SYSTEM-DIALOG GET-FILE v_os-file3
        TITLE "Выберите файл для экспорта"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
       /* ask-overwrite */
        save-as
        use-filename
        update ll_commit3
        default-extension "txt"
        .
    IF ll_commit3 <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file3 = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN fnprih = ( IF SEARCH( v_os-file3 ) = ? THEN  v_os-file3  ELSE SEARCH( v_os-file3 ) ).
      DISP fnprih WITH FRAME {&FRAME-NAME}.






END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file-4 Dialog-Frame
ON CHOOSE OF B-file-4 IN FRAME Dialog-Frame
DO:

    DEF VAR ll_commit4 AS LOG    NO-UNDO INIT NO.
    define variable v_os-file4 as char no-undo.



    SYSTEM-DIALOG GET-FILE v_os-file4
        TITLE "Выберите файл соответствий"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        ask-overwrite

        use-filename
        update ll_commit4
        default-extension "txt"
        .
    IF ll_commit4 <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file4 = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN fnsoot = ( IF SEARCH( v_os-file4 ) = ? THEN  v_os-file4  ELSE SEARCH( v_os-file4 ) ).
      DISP fnsoot WITH FRAME {&FRAME-NAME}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file-5 Dialog-Frame
ON CHOOSE OF B-file-5 IN FRAME Dialog-Frame
DO:

    DEF VAR ll_commit5 AS LOG    NO-UNDO INIT NO.
    define variable v_os-file5 as char no-undo.

    SYSTEM-DIALOG GET-FILE v_os-file5
        TITLE "Выберите файл для экспорта"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
       /* ask-overwrite */
        save-as
        use-filename
        update ll_commit5
        default-extension "txt"
        .
    IF ll_commit5 <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file5 = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN fnrasvne = ( IF SEARCH( v_os-file5 ) = ? THEN  v_os-file5  ELSE SEARCH( v_os-file5 ) ).
      DISP fnrasvne WITH FRAME {&FRAME-NAME}.


END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file-6 Dialog-Frame
ON CHOOSE OF B-file-6 IN FRAME Dialog-Frame
DO:

    DEF VAR ll_commit6 AS LOG    NO-UNDO INIT NO.
    define variable v_os-file6 as char no-undo.

    SYSTEM-DIALOG GET-FILE v_os-file6
        TITLE "Выберите файл для экспорта"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        /*ask-overwrite*/
        save-as
        use-filename
        update ll_commit6
        default-extension "txt"
        .
    IF ll_commit6 <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file6 = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN fnkassir = ( IF SEARCH( v_os-file6 ) = ? THEN   v_os-file6  ELSE SEARCH( v_os-file6 ) ).


    DISP fnkassir WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file-9
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file-9 Dialog-Frame
ON CHOOSE OF B-file-9 IN FRAME Dialog-Frame
DO:

    DEF VAR ll_commit9 AS LOG    NO-UNDO INIT NO.
    define variable v_os-file9 as char no-undo.

    SYSTEM-DIALOG GET-FILE v_os-file9
        TITLE "Выберите файл для экспорта"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        /*ask-overwrite*/
        save-as
        use-filename
        update ll_commit9
        default-extension "txt"
        .
    IF ll_commit9 <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF v_os-file9 = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN fnperesort = ( IF SEARCH( v_os-file9 ) = ? THEN   v_os-file9  ELSE SEARCH( v_os-file9 ) ).


    DISP fnperesort WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
    ASSIGN
    staff
    peresort
    prihod
    rasvn
    rasvne
    udal
    fnsoot
    fnkassir
    fnperesort
    fnprih
    fnrasvn
    fnudal
    fnrasvne
    dateb
    dateend
    e-mail.


    if (staff = true and fnkassir = "") or (peresort = true and fnperesort = "")
    or (prihod = true and fnprih = "") or (rasvn = true and fnrasvn = "")  or (udal = true and fnudal = "")
    or (rasvne = true and fnrasvne = "")
    then
    do:
        message "Необходимо ввести путь для выгрузок по флагам".
        return no-apply.
    end.


    if (staff    = false and trim(fnkassir)   <> "")  then assign fnkassir   = "".
    if (peresort = false and trim(fnperesort) <> "")  then assign fnperesort = "".
    if (prihod   = false and trim(fnprih)     <> "")  then assign fnprih     = "".
    if (rasvn    = false and trim(fnrasvn)    <> "")  then assign fnrasvn    = "".
    if (udal     = false and trim(fnudal)     <> "")  then assign fnudal     = "".
    if (rasvne   = false and trim (fnrasvne)  <> "")  then assign fnrasvne   = "".



    IF trim(fnsoot) = "" THEN
    DO:
        MESSAGE "Необходимо ввести путь для файла соответствий".
        return no-apply.
    END.
    
    if not peresort and not prihod and not rasvn and not rasvne and not staff and not udal then
        do:
            message "Вы не отметили ни одну из выгрузок отчётов!" skip
                    "Необходимо отметить галочкой хотя бы один отчёт." view-as alert-box.
            return no-apply.
        end.

    if dateb = ? or dateend = ? then
        do:
            message "Не введены даты периода, повторите попытку." view-as alert-box.
            return no-apply.
        end.

    if dateb>dateend then
    do:
    message "Период начала не может быть больше периода конца".
    return no-apply.
    end.
    else
    do:
    MESSAGE "Произвести выгрузку?"
    VIEW-AS ALERT-BOX QUESTION
    BUTTONS yes-no UPDATE continue-ok AS LOGICAL.
    IF continue-ok THEN DO:
    /*Настройки для обычного запуска "noauto" 0  т.к. я должен передавать в испольняемый файл дату, а новые настройки собьют авт выгрузку*/
    run waitfram-show in this-procedure ("Ждите... Вывод информации...").
    RUN cus\exp-kanp.p(par1, par2 , loghandle, 0, "noauto;" + string(dateb) + ";" + string(dateend) + ";" + fnrasvn + ";" + fnudal + ";" + fnprih + ";" + fnsoot + ";" + fnkassir + ";" + fnperesort + ";" + fnrasvne + ";" + "; !" + e-mail , 0 , 0).
    run waitfram-hide in this-procedure .
    END.
    else
    return no-apply.
    END.



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fnkassir
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fnkassir Dialog-Frame
ON LEAVE OF fnkassir IN FRAME Dialog-Frame /* Выгрузка кассиров */
DO:
    ASSIGN fnkassir.
    IF SEARCH( fnkassir ) <> ? AND SEARCH( fnkassir ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN fnkassir = FILE-INFO:FULL-PATHNAME.

        DISP fnkassir WITH FRAME {&FRAME-NAME}.
    END.
    APPLY "TAB":U TO fnkassir IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fnperesort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fnperesort Dialog-Frame
ON LEAVE OF fnperesort IN FRAME Dialog-Frame /* Выгрузка док. пересортицы */
DO:
    ASSIGN fnperesort.
    IF SEARCH( fnperesort ) <> ? AND SEARCH( fnperesort ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = fnperesort.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN fnperesort = FILE-INFO:FULL-PATHNAME.

        DISP fnperesort WITH FRAME {&FRAME-NAME}.
    END.
    APPLY "TAB":U TO fnperesort IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fnprih
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fnprih Dialog-Frame
ON LEAVE OF fnprih IN FRAME Dialog-Frame /* Файл приход внешний */
DO:
    ASSIGN fnprih.
    IF SEARCH( fnprih ) <> ? AND SEARCH( fnprih ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME =fnprih.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN fnprih = FILE-INFO:FULL-PATHNAME.

        DISP fnprih WITH FRAME {&FRAME-NAME}.
    END.
    APPLY "TAB":U TO fnprih IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fnrasvn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fnrasvn Dialog-Frame
ON LEAVE OF fnrasvn IN FRAME Dialog-Frame /* Файл расход внутренний */
DO:
    ASSIGN fnrasvn.
    IF SEARCH( fnrasvn ) <> ? AND SEARCH( fnrasvn ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = fnrasvn.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN fnrasvn = FILE-INFO:FULL-PATHNAME.

        DISP fnrasvn WITH FRAME {&FRAME-NAME}.
    END.
    APPLY "TAB":U TO fnrasvn IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fnrasvne
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fnrasvne Dialog-Frame
ON LEAVE OF fnrasvne IN FRAME Dialog-Frame /* Файл расход внешний */
DO:
    ASSIGN fnrasvne.
    IF SEARCH( fnrasvne ) <> ? AND SEARCH( fnrasvne ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = fnrasvne.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN fnrasvne = FILE-INFO:FULL-PATHNAME.

        DISP fnrasvne WITH FRAME {&FRAME-NAME}.
    END.
    APPLY "TAB":U TO fnrasvne IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME fnudal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL fnudal Dialog-Frame
ON LEAVE OF fnudal IN FRAME Dialog-Frame /* Файл удал. накл. рас. вн. */
DO:
    ASSIGN fnudal.
    IF SEARCH( fnudal ) <> ? AND SEARCH( fnudal ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = fnudal.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN fnudal = FILE-INFO:FULL-PATHNAME.

        DISP fnudal WITH FRAME {&FRAME-NAME}.
    END.
    APPLY "TAB":U TO fnudal IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME peresort
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL peresort Dialog-Frame
ON VALUE-CHANGED OF peresort IN FRAME Dialog-Frame /* Выгрузка док. пересортицы */
DO:
   assign peresort.
   disable fnperesort b-file-9 WITH FRAME {&FRAME-NAME}.
   enable fnperesort   when peresort = true
          b-file-9     when peresort = true
   WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME prihod
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL prihod Dialog-Frame
ON VALUE-CHANGED OF prihod IN FRAME Dialog-Frame /* Выгрузка для прихода внешнего */
DO:
    assign prihod.
    disable fnprih b-file-3 WITH FRAME {&FRAME-NAME}.
    enable fnprih   when prihod = true
           b-file-3 when prihod = true
    WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rasvn
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rasvn Dialog-Frame
ON VALUE-CHANGED OF rasvn IN FRAME Dialog-Frame /* Выгрузка для расхода внутреннего */
DO:
    assign rasvn.
    disable fnrasvn b-file WITH FRAME {&FRAME-NAME}.
    enable fnrasvn   when rasvn = true
          b-file when rasvn = true
    WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rasvne
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rasvne Dialog-Frame
ON VALUE-CHANGED OF rasvne IN FRAME Dialog-Frame /* Выгрузка для расхода внешнего */
DO:
    assign rasvne.
    disable fnrasvne B-file-5 WITH FRAME {&FRAME-NAME}.
    enable fnrasvne when rasvne = true
           B-file-5 when rasvne = true
    WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME staff
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL staff Dialog-Frame
ON VALUE-CHANGED OF staff IN FRAME Dialog-Frame /* Выгрузка кассиров */
DO:
   assign staff.
  /* if staff = false then assign fnkassir = "".
   display fnkassir WITH FRAME {&FRAME-NAME}.      */
   disable fnkassir b-file-6 WITH FRAME {&FRAME-NAME}.
   enable fnkassir   when staff = true
          b-file-6 when staff = true
   WITH FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME udal
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL udal Dialog-Frame
ON VALUE-CHANGED OF udal IN FRAME Dialog-Frame /* Выгрузка для удаленных накладных */
DO:
   assign udal.
   disable fnudal b-file-2 WITH FRAME {&FRAME-NAME}.
   enable fnudal   when udal = true
          b-file-2 when udal = true
   WITH FRAME {&FRAME-NAME}.
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

  RUN enable_UI.
  run my-enable .

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
  DISPLAY dateb dateend staff fnkassir peresort fnperesort rasvn fnrasvn udal
          fnudal prihod fnprih rasvne fnrasvne fnsoot e-mail
      WITH FRAME Dialog-Frame.
  ENABLE dateb dateend staff peresort rasvn udal prihod rasvne fnsoot B-file-4 
         e-mail Btn_OK Btn_Cancel 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame
PROCEDURE my-enable :
/*DISPLAY dateb dateend staff fnkassir peresort fnperesort rasvn fnrasvn udal
          fnudal prihod fnprih
      WITH FRAME Dialog-Frame.  */
      
  disable fnkassir
         B-file-6
         fnperesort
         B-file-9
         fnrasvn
         B-file
         fnudal
         B-file-2
         fnprih
         B-file-3
         fnrasvne
         B-file-5

     WITH FRAME Dialog-Frame.


  ENABLE fnkassir when staff = true
         B-file-6 when staff = true
         fnperesort when peresort = true
         B-file-9 when peresort = true
         fnrasvn when rasvn = true
         B-file when rasvn = true
         fnudal when udal = true
         B-file-2 when udal = true
         fnprih when prihod = true
         B-file-3 when prihod =true
         fnrasvne when rasvne = true
         B-file-5 when rasvne = true

        WITH FRAME Dialog-Frame.
         /*
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}  */

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-save Dialog-Frame
PROCEDURE proc-save :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
