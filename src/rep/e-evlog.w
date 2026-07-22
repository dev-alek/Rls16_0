&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Отчет по логированию каccы TcasH (закладка № 2)

Автор: Комаров Иван Сергеевич
Дата создания: 11/13/09
Author: Ivan Komarov
Creation date: 11/13/09

*/

def var vss-revision    as character no-undo init "$Revision$":U .
def var vss-author      as character no-undo init "$Author$":U .
def var vss-date        as character no-undo init "$Date$":U .
def var vss-workfile    as character no-undo init "$Workfile$":U .
def var vss-archive     as character no-undo init "$Archive$":U .
def var vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i }
{ cmp/showinf.i  }
{ cmp/operlist.i  }
{ gbl/onewin.i   }
{ gbl/getcntxt.i  def }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */

def var State-source as  WIDGET-HANDLE.
def buffer cli-post for ub.clients .
/*
def New SHARED temp-table g#post NO-UNDO
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    INDEX pi IS UNIQUE PRIMARY obj-type obj-code.
*/
define variable events_recids  as character     no-undo .
define variable cd_recids      as character     no-undo .
define variable v-time-start   as integer       no-undo .
define variable v-time-end     as integer       no-undo .
define variable v-user-id      as character     no-undo .
define variable parparentproc  as widget-handle no-undo .
define variable v-supmode-id   as character     no-undo .
define variable v-b-codes      as character     no-undo .

define variable ii             as integer       no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS ed-EventsName event-type rb-events ~
b-user-sellect rb-cd ed-cd-names b-doc-select b-cd-mode-select b-dc-sellect ~
rb-b-codes ed-b-codes v-bc-num v-h-start v-m-start v-h-end v-m-end ~
v-summ-min v-summ-max v-qnty-min v-qnty-max v-disc-min v-disc-max ~
v-disc-type
&Scoped-Define DISPLAYED-OBJECTS ed-EventsName event-type rb-events ~
v-user-name rb-cd ed-cd-names v-doc-num v-cd-supmode v-dc-num rb-b-codes ~
ed-b-codes v-bc-num v-h-start v-m-start v-h-end v-m-end v-summ-min ~
v-summ-max v-qnty-min v-qnty-max v-disc-min v-disc-max v-disc-type

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cd-mode-select
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "v doc 2"
     SIZE 3 BY 1.

DEFINE BUTTON b-dc-sellect
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "user sellect 2"
     SIZE 3 BY 1.

DEFINE BUTTON b-doc-select
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button 2"
     SIZE 3 BY 1.

DEFINE BUTTON b-user-sellect
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "Button 1"
     SIZE 3 BY 1.

DEFINE VARIABLE event-type AS CHARACTER FORMAT "X(256)":U INITIAL "All"
     LABEL "Тип"
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEM-PAIRS "Все","All",
                     "Запрос пользователя","U",
                     "Реакция системы","S",
                     "Ошибка","E"
     DROP-DOWN-LIST
     SIZE 16.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-disc-type AS INTEGER FORMAT ">9":U INITIAL 1
     VIEW-AS COMBO-BOX INNER-LINES 2
     LIST-ITEM-PAIRS "Любая",1,
                     "Процентная",2,
                     "Абсолютная",3
     DROP-DOWN-LIST
     SIZE 19.5 BY 1 NO-UNDO.

DEFINE VARIABLE ed-b-codes AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 31 BY 1.75 TOOLTIP "Список выбранных Поставщиков"
     FONT 4 NO-UNDO.

DEFINE VARIABLE ed-cd-names AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 31 BY 1.75 TOOLTIP "Список выбранных Поставщиков"
     FONT 4 NO-UNDO.

DEFINE VARIABLE ed-EventsName AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 31 BY 1.75 TOOLTIP "Список выбранных Поставщиков"
     FONT 4 NO-UNDO.

DEFINE VARIABLE v-bc-num AS CHARACTER FORMAT "X(16)":U
     VIEW-AS FILL-IN
     SIZE 21.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-cd-supmode AS CHARACTER FORMAT "X(256)":U
     LABEL "Режим кассы"
     VIEW-AS FILL-IN
     SIZE 27.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-dc-num AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 18.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-disc-max AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11.88 BY 1 NO-UNDO.

DEFINE VARIABLE v-disc-min AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Диапазон скидок с"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 NO-UNDO.

DEFINE VARIABLE v-doc-num AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 18.5 BY 1 NO-UNDO.

DEFINE VARIABLE v-h-end AS INTEGER FORMAT "99":U INITIAL 23
     LABEL "мин.  по"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE v-h-start AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время с"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE v-m-end AS INTEGER FORMAT "99":U INITIAL 59
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE v-m-start AS INTEGER FORMAT "99":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 3 BY 1 NO-UNDO.

DEFINE VARIABLE v-qnty-max AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11.88 BY 1 NO-UNDO.

DEFINE VARIABLE v-qnty-min AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Диапазон кол-ва с"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 NO-UNDO.

DEFINE VARIABLE v-summ-max AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11.88 BY 1 NO-UNDO.

DEFINE VARIABLE v-summ-min AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Диапазон сумм с"
     VIEW-AS FILL-IN
     SIZE 11.63 BY 1 NO-UNDO.

DEFINE VARIABLE v-user-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 18.5 BY 1 NO-UNDO.

DEFINE VARIABLE rb-b-codes AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 12 BY 1.75 NO-UNDO.

DEFINE VARIABLE rb-cd AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 12 BY 1.75 NO-UNDO.

DEFINE VARIABLE rb-events AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 12 BY 1.5 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     ed-EventsName AT ROW 2 COL 15.5 NO-LABEL
     event-type AT ROW 2.08 COL 52 COLON-ALIGNED WIDGET-ID 20
     rb-events AT ROW 2.13 COL 3 NO-LABEL
     b-user-sellect AT ROW 4.13 COL 67.5 WIDGET-ID 24
     v-user-name AT ROW 4.17 COL 47 COLON-ALIGNED NO-LABEL WIDGET-ID 90
     rb-cd AT ROW 4.63 COL 3 NO-LABEL WIDGET-ID 2
     ed-cd-names AT ROW 4.63 COL 15.5 NO-LABEL WIDGET-ID 12
     v-doc-num AT ROW 6.13 COL 47 COLON-ALIGNED NO-LABEL WIDGET-ID 92
     b-doc-select AT ROW 6.13 COL 67.5 WIDGET-ID 46
     v-cd-supmode AT ROW 6.75 COL 13.5 COLON-ALIGNED WIDGET-ID 100
     b-cd-mode-select AT ROW 6.75 COL 43 WIDGET-ID 84
     b-dc-sellect AT ROW 8.04 COL 67.5 WIDGET-ID 80
     v-dc-num AT ROW 8.13 COL 47 COLON-ALIGNED NO-LABEL WIDGET-ID 94
     rb-b-codes AT ROW 8.75 COL 3 NO-LABEL WIDGET-ID 16
     ed-b-codes AT ROW 8.75 COL 15.5 NO-LABEL WIDGET-ID 14
     v-bc-num AT ROW 9.88 COL 47 COLON-ALIGNED NO-LABEL WIDGET-ID 96
     v-h-start AT ROW 11.33 COL 10.38 COLON-ALIGNED WIDGET-ID 28
     v-m-start AT ROW 11.33 COL 16.25 COLON-ALIGNED WIDGET-ID 30
     v-h-end AT ROW 11.33 COL 30.25 COLON-ALIGNED WIDGET-ID 32
     v-m-end AT ROW 11.33 COL 36 COLON-ALIGNED WIDGET-ID 34
     v-summ-min AT ROW 12.83 COL 18.38 COLON-ALIGNED WIDGET-ID 38
     v-summ-max AT ROW 12.83 COL 35.13 COLON-ALIGNED WIDGET-ID 40
     v-qnty-min AT ROW 14.29 COL 18.38 COLON-ALIGNED WIDGET-ID 44
     v-qnty-max AT ROW 14.29 COL 35.13 COLON-ALIGNED WIDGET-ID 42
     v-disc-min AT ROW 15.75 COL 18.38 COLON-ALIGNED WIDGET-ID 72
     v-disc-max AT ROW 15.75 COL 35.13 COLON-ALIGNED WIDGET-ID 70
     v-disc-type AT ROW 15.79 COL 49 COLON-ALIGNED NO-LABEL WIDGET-ID 102
     "мин." VIEW-AS TEXT
          SIZE 4.38 BY .67 AT ROW 11.54 COL 42.13 WIDGET-ID 36
     "Список событий:" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 1.25 COL 7.13
          FGCOLOR 4
     "Список касс:" VIEW-AS TEXT
          SIZE 13.5 BY .67 AT ROW 3.88 COL 6.5 WIDGET-ID 8
          FGCOLOR 4
     "Список штрихкодов:" VIEW-AS TEXT
          SIZE 19.38 BY .67 AT ROW 8 COL 6.5 WIDGET-ID 10
          FGCOLOR 4
     "Пользователь:" VIEW-AS TEXT
          SIZE 13.5 BY .67 AT ROW 3.42 COL 49.38 WIDGET-ID 22
          FGCOLOR 4
     "Дисконтная карта:" VIEW-AS TEXT
          SIZE 21.5 BY .67 AT ROW 7.38 COL 49 WIDGET-ID 76
          FGCOLOR 4
     "Тип скидки:" VIEW-AS TEXT
          SIZE 13.5 BY .67 AT ROW 15.13 COL 51 WIDGET-ID 74
          FGCOLOR 4
     "Тип и номер документа:" VIEW-AS TEXT
          SIZE 21.5 BY .75 AT ROW 5.38 COL 49 WIDGET-ID 48
          FGCOLOR 4
     "Банковская карта:" VIEW-AS TEXT
          SIZE 18 BY .75 AT ROW 9.13 COL 49.5 WIDGET-ID 78
          FGCOLOR 4
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: External-Tables
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 16.75
         WIDTH              = 70.38.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB s-object
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW s-object
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME Size-to-Fit                                   */
ASSIGN
       FRAME F-Main:SCROLLABLE                      = FALSE
       FRAME F-Main:HIDDEN                          = TRUE.

ASSIGN
       ed-b-codes:READ-ONLY IN FRAME F-Main         = TRUE.

ASSIGN
       ed-cd-names:READ-ONLY IN FRAME F-Main        = TRUE.

ASSIGN
       ed-EventsName:READ-ONLY IN FRAME F-Main      = TRUE.

/* SETTINGS FOR FILL-IN v-cd-supmode IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN
       v-cd-supmode:READ-ONLY IN FRAME F-Main       = TRUE.

/* SETTINGS FOR FILL-IN v-dc-num IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN
       v-dc-num:READ-ONLY IN FRAME F-Main           = TRUE.

/* SETTINGS FOR FILL-IN v-doc-num IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN
       v-doc-num:READ-ONLY IN FRAME F-Main          = TRUE.

/* SETTINGS FOR FILL-IN v-user-name IN FRAME F-Main
   NO-ENABLE                                                            */
ASSIGN
       v-user-name:READ-ONLY IN FRAME F-Main        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = "NO-LOCK"
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME b-cd-mode-select
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cd-mode-select s-object
ON CHOOSE OF b-cd-mode-select IN FRAME F-Main /* v doc 2 */
DO:
   define variable v-rid    as character    no-undo.
   define buffer buf_wi-mode     for ub.wi-mode .
   run adm/wi-modes.w   ( INPUT parparentproc
                        , INPUT 'b-sel':U
                        , input {&all}
                        , input ""
                        , INPUT-OUTPUT v-rid
                        ) NO-ERROR.
   if v-rid = ""
   then do:
      RETURN.
   end.

   find first buf_wi-mode
      where recid( buf_wi-mode ) = INTEGER(ENTRY(1, v-rid))
      NO-LOCK
      no-error.
   IF AVAILABLE buf_wi-mode THEN DO:
      ASSIGN
         v-supmode-id =  buf_wi-mode.mode-id
         v-cd-supmode =  buf_wi-mode.mode-name
      .
   END.
   Display
      v-cd-supmode
   with frame {&FRAME-NAME}
   .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-dc-sellect
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-dc-sellect s-object
ON CHOOSE OF b-dc-sellect IN FRAME F-Main /* user sellect 2 */
DO:
   define variable v-rid    as character    no-undo.
   define buffer buf_dis-card    for ub.dis-card .
   run ref/discards.w
      ( parParentProc
      , "b-sel"
      , {&all}
      , v-cntxt-host-code-obj
      , v-cntxt-obj-type
      , v-cntxt-obj-code
      , ?
      , ?
      , output v-rid
      ) .


   if v-rid = ""
   then do:
      RETURN.
   end.

   find first buf_dis-card
      where recid( buf_dis-card ) = INTEGER(ENTRY(1, v-rid))
      NO-LOCK
      no-error.
   IF AVAILABLE buf_dis-card THEN DO:
      ASSIGN
         v-dc-num = STRING(buf_dis-card.d-card)
      .
   END.
   Display
      v-dc-num
   with frame {&FRAME-NAME}
   .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-doc-select
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-doc-select s-object
ON CHOOSE OF b-doc-select IN FRAME F-Main /* Button 2 */
DO:
   define variable v-rid    as character    no-undo.
   define buffer buf_chk-doc     for ub.chk-doc .
   run str/chk-docs.w   ( input parparentproc
                        , input "b-sel,b-mark"
                        , input {&g___object}
                        , input ?
                        , input v-cntxt-obj-type
                        , input v-cntxt-obj-code
                        , input '':U
                        , input '':U
                        , input 0
                        , input ?
                        , input ?
                        , input 0
                        , output v-rid
                        ) NO-ERROR.
   IF v-rid = "":U
   THEN DO:
      RETURN.
   END.

   FIND FIRST buf_chk-doc
      where RECID(buf_chk-doc) = INTEGER(ENTRY(1, v-rid))
      no-lock
      NO-ERROR
      .
   IF AVAILABLE buf_chk-doc
   THEN DO:
      ASSIGN
         v-doc-num = buf_chk-doc.doc-code
      .
   END.
   Display
      v-doc-num
   with frame {&FRAME-NAME}
   .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-user-sellect
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-user-sellect s-object
ON CHOOSE OF b-user-sellect IN FRAME F-Main /* Button 1 */
DO:
   define buffer buf_user-account      for ub.user-account .

   define variable v-accepted      as logical      no-undo.

   run onewin_clear in this-procedure.

   for each buf_user-account
   :
      run onewin_add-item in this-procedure ( input buf_user-account.user-id
                                            , input substitute ( "&1 &2 &3 (&4)"
                                                               , buf_user-account.last-Name
                                                               , buf_user-account.first-Name
                                                               , buf_user-account.second-Name
                                                               , buf_user-account.user-id
                                                               )
                                            , input substitute ( "&1 &2 &3 (&4)"
                                                               , buf_user-account.last-Name
                                                               , buf_user-account.first-Name
                                                               , buf_user-account.second-Name
                                                               , buf_user-account.user-id
                                                               )
                                            , input no
                                          ).
   end.        /* for each buf_user-account */

   run gbl/onewin.w  ( input my-handle
                     , input  0
                     , input  "Список пользователей"
                     , input  "":U
                     , input  "&Тест"
                     , input  table temp_onewin_items
                     , output table temp_onewin_itemsSelected
                     , output v-user-id
                     , output v-accepted
                     ) .

    if v-accepted then do:
        find first buf_user-account where buf_user-account.user-id = v-user-id
                                    no-error.
            assign v-user-name = buf_user-account.last-Name
            .
        display v-user-name with frame {&FRAME-NAME}.
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rb-b-codes
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rb-b-codes s-object
ON VALUE-CHANGED OF rb-b-codes IN FRAME F-Main
DO:
   ASSIGN
      rb-b-codes
   .
   CASE rb-b-codes :
      when 1
      then DO:
          Assign
            ed-b-codes
            v-b-codes   = ed-b-codes
            ed-b-codes  = {&all}
            ed-b-codes:READ-ONLY = TRUE
          .
      END.
      when 2
      then DO:
         Assign
            ed-b-codes     = v-b-codes
            ed-b-codes:READ-ONLY = FALSE
         .
      END.
      OTHERWISE DO:
      END.
   END CASE.
   Display
      ed-b-codes
   with frame {&FRAME-NAME}
   .
   APPLY "ENTRY" TO ed-b-codes.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rb-cd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rb-cd s-object
ON VALUE-CHANGED OF rb-cd IN FRAME F-Main
DO:
   define buffer buf_cash-desk      for ub.cash-desk .
   ASSIGN
      rb-cd
   .
   CASE rb-cd :
      when 1
      then DO:
          Assign
            ed-cd-names = {&all}
            cd_recids = "":U
          .
          Display
            ed-cd-names
          with frame {&FRAME-NAME}
          .
          FOR EACH  buf_cash-desk
              NO-LOCK
              :
                  ASSIGN
                     cd_recids = IF cd_recids = "":U THEN STRING(RECID(buf_cash-desk))
                                                     ELSE cd_recids + "," + STRING(RECID(buf_cash-desk))
                  .
          END.
       END.
      when 2
      then DO:

         define variable v-rec    as recid        no-undo.
         IF x-SelectObject = STRING({&o-currency})
         THEN DO:
            run ref/cashlist.w   ( INPUT my-handle
                                 , INPUT "b-sel,b-mark":U
                                 , INPUT {&g___object}
                                 , INPUT 0
                                 , INPUT 0
                                 , INPUT v-cntxt-obj-type
                                 , INPUT v-cntxt-obj-code
                                 , INPUT v-rec
                                 , output cd_recids
                                 ) .
         END.
         ELSE DO:
            run ref/cashlist.w   ( INPUT my-handle
                                 , INPUT "b-sel,b-mark":U
                                 , INPUT {&all}
                                 , INPUT 0
                                 , INPUT 0
                                 , INPUT v-cntxt-obj-type
                                 , INPUT v-cntxt-obj-code
                                 , INPUT v-rec
                                 , output cd_recids
                                 ) .
         END.
         if cd_recids = ""
         then do:
            Assign
               ed-cd-names = {&all}
               rb-cd = 1
            .
            Display
               ed-cd-names
               rb-cd
            with frame {&FRAME-NAME}
            .
            end.
            else do:
            Assign
               ed-cd-names = "":U
            .
            DO ii = 1 TO num-entries( cd_recids ) :
               FIND FIRST buf_cash-desk
                    WHERE recid( buf_cash-desk ) = int(entry( ii, cd_recids ))
                    NO-LOCK
                    .
               ASSIGN
                  ed-cd-names = ed-cd-names
                              + SUBSTITUTE ( "Маг. &1 &2 &3"
                                           , buf_cash-desk.obj-code
                                           , buf_cash-desk.pos-type
                                           , buf_cash-desk.cash-num
                                           )
                              + chr(10)
               .
               END.
            Display
               ed-cd-names
            with frame {&FRAME-NAME}
            .
            end.
      END.
      OTHERWISE DO:
      END.
   END CASE.
  END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rb-events
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rb-events s-object
ON VALUE-CHANGED OF rb-events IN FRAME F-Main
DO:
   define buffer buf_cd-events      for ub.cd-events .
   define variable v-ok    as logical      no-undo.
   ASSIGN
      rb-events
   .
   CASE rb-events :
      when 1
      then DO:
          Assign
            ed-EventsName = {&all}
            events_recids = "":U
          .
          Display
            ed-EventsName
          with frame {&FRAME-NAME}
          .
          FOR EACH  buf_cd-events
              NO-LOCK
              :
                  ASSIGN
                     events_recids = IF events_recids = "":U THEN STRING(recid(buf_cd-events))
                                                             ELSE events_recids + "," + STRING(recid(buf_cd-events))
                  .
          END.
      END.
      when 2
      then DO:
         run ref/cd-event.w  ( INPUT my-handle
                             , INPUT "b-mark"
                             , input-output events_recids
                             , OUTPUT v-ok
                              ) .
         if events_recids = ""
         OR NOT v-ok
         then do:
            Assign
               ed-EventsName = {&all}
               rb-events = 1
            .
            Display
               ed-EventsName
               rb-events
            with frame {&FRAME-NAME}
            .
         end.
         else do:
            Assign
               ed-EventsName = "":U
            .
            DO ii = 1 TO num-entries( events_recids ) :
               FIND FIRST buf_cd-events
                    WHERE recid( buf_cd-events ) = int(entry( ii, events_recids ))
                    NO-LOCK
                    .
            ASSIGN
                  ed-EventsName = ed-EventsName + buf_cd-events.event-name + chr(10)
               .
            END.
            Display
               ed-EventsName
            with frame {&FRAME-NAME}
   .
         end.
      END.
      OTHERWISE DO:
      END.
   END CASE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-bc-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-bc-num s-object
ON LEAVE OF v-bc-num IN FRAME F-Main
DO:
  ASSIGN
    v-bc-num
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-disc-max
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-disc-max s-object
ON LEAVE OF v-disc-max IN FRAME F-Main /* по */
DO:
    ASSIGN
    v-disc-max
    v-disc-min
  .
  IF v-disc-max < v-disc-min
  THEN DO:
      message
         "Неправильно указаны границы диапазона"
         skip
      view-as alert-box error.
      RETURN NO-APPLY.
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-disc-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-disc-type s-object
ON VALUE-CHANGED OF v-disc-type IN FRAME F-Main
DO:
  ASSIGN
    v-disc-type
  .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-h-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-h-end s-object
ON LEAVE OF v-h-end IN FRAME F-Main /* мин.  по */
DO:
      ASSIGN
     v-h-end
   .
   RUN mandatory-24 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-h-end ) .
   ASSIGN
      v-time-end = v-h-end * 60 * 60 + v-m-end * 60
   .
   display v-h-end  with frame {&FRAME-NAME} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-h-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-h-start s-object
ON LEAVE OF v-h-start IN FRAME F-Main /* Время с */
DO:
    ASSIGN
     v-h-start
   .
   RUN mandatory-24 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-h-start ) .
   ASSIGN
      v-time-start = v-h-start * 60 * 60 + v-m-start * 60
   .
   display v-h-start  with frame {&FRAME-NAME} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-m-end
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-m-end s-object
ON LEAVE OF v-m-end IN FRAME F-Main
DO:
       ASSIGN
     v-m-end
   .
   RUN mandatory-60 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-m-end ) .
   ASSIGN
        v-time-end = v-h-end * 60 * 60 + v-m-end * 60
   .
   display v-m-end  with frame {&FRAME-NAME} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-m-start
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-m-start s-object
ON LEAVE OF v-m-start IN FRAME F-Main
DO:
     ASSIGN
     v-m-start
   .
   RUN mandatory-60 IN THIS-PROCEDURE
      (INPUT-OUTPUT v-m-start ) .
   ASSIGN
        v-time-start = v-h-start * 60 * 60 + v-m-start * 60
   .
   display v-m-start  with frame {&FRAME-NAME} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-qnty-max
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-qnty-max s-object
ON LEAVE OF v-qnty-max IN FRAME F-Main /* по */
DO:
   ASSIGN
    v-qnty-max
    v-qnty-min
  .
  IF v-qnty-max < v-qnty-min
  THEN DO:
      message
         "Неправильно указаны границы диапазона"
         skip
      view-as alert-box error.
      RETURN NO-APPLY .
  END.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-summ-max
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-summ-max s-object
ON LEAVE OF v-summ-max IN FRAME F-Main /* по */
DO:
  ASSIGN
    v-summ-max
    v-summ-min
  .
  IF v-summ-max < v-summ-min
  THEN DO:
      message
         "Неправильно указаны границы диапазона"
         skip
      view-as alert-box error.
      RETURN NO-APPLY .
  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
/* If testing in the UIB, initialize the SmartObject. */
    /*
   Assign  Postname = {&all}.
   Display PostName with frame {&FRAME-NAME} .
   assign
      post-grp_recids = "":U
   .
   FOR EACH  cli-post
      WHERE cli-post.sup-gds = yes
      NO-LOCK
      :
            post-grp_recids = IF post-grp_recids = "":U THEN STRING(RECID(cli-post))
                ELSE post-grp_recids + "," + STRING(RECID(cli-post)).

   END.
   */
   assign
      parparentproc = my-handle
   .
   DISPLAY
      event-type
      v-disc-type
      v-h-start v-m-start v-h-end v-m-end
   with frame {&FRAME-NAME}.


   { gbl/getcntxt.i  get }

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
  RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI s-object  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mandatory-24 s-object
PROCEDURE mandatory-24 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT-OUTPUT PARAMETER p-time AS INTEGER NO-UNDO .
DO
ON error undo, RETURN:
   IF p-time > 23 THEN DO:
       ASSIGN
           p-time = 23
       .
       RETURN .
   END.
   IF p-time < 0 THEN DO:
       ASSIGN
           p-time = 0
       .
       RETURN .
   END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE mandatory-60 s-object
PROCEDURE mandatory-60 :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
DEFINE INPUT-OUTPUT PARAMETER p-time AS INTEGER NO-UNDO .
DO
ON error undo, RETURN:
   IF p-time > 59 THEN DO:
       ASSIGN
           p-time = 59
       .
       RETURN .
   END.
   IF p-time < 0 THEN DO:
       ASSIGN
           p-time = 0
       .
       RETURN .
   END.
END.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
FIND FIRST tmp#grp NO-ERROR.
 /* даты
 IF NOT CAN-FIND(tmp#grp)
 THEN DO:
    message
      "Не выбраны группы товаров."
      skip "Необходимо вернуться на закладку <Параметры>."
    view-as alert-box information.
   return  no-apply .
 END.
 */

 DO WITH frame {&FRAME-NAME}:
   ASSIGN
      event-type
      rb-events
      rb-cd
      rb-b-codes
      ed-b-codes
      v-bc-num v-h-start v-m-start v-h-end v-m-end
      v-summ-min v-summ-max
      v-qnty-min v-qnty-max
      v-disc-min v-disc-max
      v-disc-type
   .
 END.

/* !!! Проверка соответствия касс объекту */
IF x-SelectObject = {&obj-currency}
THEN DO:
   define variable v-new-rec     as character    no-undo .
   define variable v-new-name    as character    no-undo .
   define variable v-err         as logical      no-undo .

   define buffer buf_cash-desk      for ub.cash-desk .
   FIND FIRST obj-list .

   DO ii = 1 TO num-entries( cd_recids ) :
      FIND FIRST buf_cash-desk
            WHERE recid( buf_cash-desk ) = int(entry( ii, cd_recids ))
            NO-LOCK
            .
      IF buf_cash-desk.obj-code = obj-list.obj-code
      THEN DO:
         ASSIGN
            v-new-rec  = IF v-new-rec = "":U THEN STRING(RECID(buf_cash-desk))
                                             ELSE v-new-rec + "," + STRING(RECID(buf_cash-desk))
            v-new-name = v-new-name
                        + SUBSTITUTE ( "Маг. &1 &2 &3"
                                       , buf_cash-desk.obj-code
                                       , buf_cash-desk.pos-type
                                       , buf_cash-desk.cash-num
                                       )
                        + chr(10)
         .
      END.
      ELSE DO:
         ASSIGN
            v-err = TRUE
         .
      END.
   END.
   IF v-err
   THEN DO:
      ASSIGN
         cd_recids   = v-new-rec
         ed-cd-names = v-new-name
      .
      Display
         ed-cd-names
      with frame {&FRAME-NAME}.

      message
         "Выбранные кассы не принадлежат текущему объекту"
         skip "Список был ограничен."
      view-as alert-box information.

      RETURN.
   END.

end.

 IF rb-b-codes = 1
 THEN DO:
   ASSIGN
      v-b-codes = "":U
   .
 END.
 else do:
   ASSIGN
      v-b-codes = ed-b-codes
   .
 end.
ASSIGN
      v-time-start = v-h-start * 60 * 60 + v-m-start * 60
.
ASSIGN
      v-time-end = v-h-end * 60 * 60 + v-m-end * 60
.

 run rep/r-evlog.p ( INPUT my-handle
                   , INPUT events_recids
                   , INPUT cd_recids
                   , INPUT v-user-id
                   , INPUT v-time-start
                   , INPUT v-time-end
                   , INPUT event-type
                   , INPUT v-supmode-id
                   , INPUT v-doc-num
                   , INPUT v-b-codes
                   , INPUT v-summ-min
                   , INPUT v-summ-max
                   , INPUT v-qnty-min
                   , INPUT v-qnty-max
                   , INPUT v-dc-num
                   , INPUT v-bc-num
                   , INPUT v-disc-type
                   , INPUT v-disc-min
                   , INPUT v-disc-max
                   ) .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???
------------------------------------------------------------------------------*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed s-object
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:     Receive and process 'state-changed' methods
               (issued by 'new-state' event).
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.


  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      /* link-changed */
  END CASE.
  END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME