&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS V-table-Win
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Формат листа

Автор: Чернова Светлана Александровна
Дата создания: 08/29/01
Author: Svetlana Chernova
Creation date: 08/29/01

no_app_help.i
*/

{ cmp/str-glbl.i }
{ cmp/trg-def.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/lkp-font.i }
{ cmp/showinf.i  }
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Формат листа".
{ cmp/vssrevis.i }

define buffer buf_usr-flt for ubflt.usr-flt  .
define variable v-h as integer   no-undo .
define variable v-w as integer   no-undo .
define variable v-h-lans as integer   no-undo .
define variable v-w-lans as integer   no-undo .
define variable gl-w as integer   no-undo . /* ширина отчета в символах */

run get-font-ini in this-procedure . /* заполнение таблицы фонтов */

CREATE WIDGET-POOL.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS r-font IMAGE-5 RECT-10 IMAGE-4 RECT-9 ~
l-height IMAGE-1 BUTTON-2 BUTTON-1 l-width IMAGE-2 l-fontnum l-fontname ~
l-fontsize l-fonttype l-name
&Scoped-Define DISPLAYED-OBJECTS l-height l-width l-fontnum l-fontname ~
l-fontsize l-fonttype l-name

/* Custom List Definitions                                              */
/* ADM-CREATE-FIELDS,ADM-ASSIGN-FIELDS,List-3,List-4,List-5,List-6      */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _XFTR "Foreign Keys" V-table-Win _INLINE
/* Actions: ? adm/support/keyedit.w ? ? ? */
/* STRUCTURED-DATA
<KEY-OBJECT>
THIS-PROCEDURE
</KEY-OBJECT>
<FOREIGN-KEYS>
</FOREIGN-KEYS>
<EXECUTING-CODE>
**************************
* Set attributes related to FOREIGN KEYS
*/
RUN set-attribute-list (
    'Keys-Accepted = "",
     Keys-Supplied = ""':U).
/**************************
</EXECUTING-CODE> */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON BUTTON-1
     LABEL "A3"
     SIZE 2.75 BY 1 TOOLTIP "Стандартный размер листа для А3-альбом"
     FONT 4.

DEFINE BUTTON BUTTON-2
     LABEL "A4"
     SIZE 2.75 BY 1 TOOLTIP "Стандартный размер листа для А4-альбом"
     FONT 4.

DEFINE BUTTON IMAGE-1
     IMAGE-UP FILE "btn-left-arrow":U
     IMAGE-DOWN FILE "btn-left-arrow":U
     IMAGE-INSENSITIVE FILE "btn-left-arrow":U NO-FOCUS
     LABEL "IMAGE-1"
     SIZE 2.5 BY 1 TOOLTIP "Ширина страницы в символах".

DEFINE BUTTON IMAGE-2
     IMAGE-UP FILE "btn-right-arrow":U
     IMAGE-DOWN FILE "btn-right-arrow":U
     IMAGE-INSENSITIVE FILE "btn-right-arrow":U NO-FOCUS
     LABEL "IMAGE-2"
     SIZE 2.5 BY 1 TOOLTIP "Ширина страницы в символах".

DEFINE BUTTON IMAGE-4
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U NO-FOCUS
     LABEL "IMAGE-4"
     SIZE 4.38 BY .83 TOOLTIP "Высота страницы в строках".

DEFINE BUTTON IMAGE-5
     IMAGE-UP FILE "btn-up-arrow":U
     IMAGE-DOWN FILE "btn-up-arrow":U
     IMAGE-INSENSITIVE FILE "btn-up-arrow":U NO-FOCUS
     LABEL "IMAGE-5"
     SIZE 4.38 BY .83 TOOLTIP "Высота страницы в строках".

DEFINE BUTTON r-font
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U NO-FOCUS
     LABEL ""
     SIZE 4.38 BY .83 TOOLTIP "Выбор фонта из секции [fonts] ini".

DEFINE VARIABLE l-fontname AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 1 FONT 4 NO-UNDO.

DEFINE VARIABLE l-fontnum AS INTEGER FORMAT ">>9":U INITIAL 7
      VIEW-AS TEXT
     SIZE 5.5 BY .67
     FGCOLOR 7  NO-UNDO.

DEFINE VARIABLE l-fontsize AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 1 FONT 4 NO-UNDO.

DEFINE VARIABLE l-fonttype AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 1 FONT 4 NO-UNDO.

DEFINE VARIABLE l-height AS INTEGER FORMAT ">>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4.38 BY 1 TOOLTIP "Высота страницы в строках" NO-UNDO.

DEFINE VARIABLE l-name AS CHARACTER FORMAT "X(256)":C8
      VIEW-AS TEXT
     SIZE 7.88 BY .67 TOOLTIP "Рекомендуемая форма вывода"
     BGCOLOR 15 FGCOLOR 9  NO-UNDO.

DEFINE VARIABLE l-width AS INTEGER FORMAT ">>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4.25 BY 1 TOOLTIP "Ширина страницы в символах" NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 16.38 BY 4.04.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 9.25 BY 2.38 TOOLTIP "Рекомендуемая форма вывода"
     BGCOLOR 15 FGCOLOR 9 .


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     r-font AT ROW 1.17 COL 13.5
     IMAGE-5 AT ROW 6.13 COL 2.88
     IMAGE-4 AT ROW 7.83 COL 2.88
     l-height AT ROW 6.96 COL 6.26 RIGHT-ALIGNED NO-LABEL AUTO-RETURN
     IMAGE-1 AT ROW 8.71 COL 8
     BUTTON-2 AT ROW 8.71 COL 2.25
     BUTTON-1 AT ROW 8.71 COL 5
     l-width AT ROW 8.71 COL 13.88 RIGHT-ALIGNED NO-LABEL AUTO-RETURN
     IMAGE-2 AT ROW 8.71 COL 14.63
     l-fontnum AT ROW 1.25 COL 6.5 NO-LABEL
     l-fontname AT ROW 2.25 COL 1 NO-LABEL
     l-fontsize AT ROW 3 COL 1 NO-LABEL
     l-fonttype AT ROW 3.75 COL 1 NO-LABEL
     l-name AT ROW 7 COL 6.5 COLON-ALIGNED NO-LABEL
     "Фонт" VIEW-AS TEXT
          SIZE 4.5 BY .67 AT ROW 1.25 COL 1.5
          FGCOLOR 4
     "Формат страницы" VIEW-AS TEXT
          SIZE 16.13 BY .67 AT ROW 5 COL 1.5
          FGCOLOR 4
     RECT-10 AT ROW 5.88 COL 1.63
     RECT-9 AT ROW 6.13 COL 8
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
  CREATE WINDOW V-table-Win ASSIGN
         HEIGHT             = 9.04
         WIDTH              = 17.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB V-table-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/viewer.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW V-table-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE Size-to-Fit                                              */
ASSIGN
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN l-fontname IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-fontnum IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-fontsize IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-fonttype IN FRAME F-Main
   ALIGN-L                                                              */
/* SETTINGS FOR FILL-IN l-height IN FRAME F-Main
   ALIGN-R                                                              */
/* SETTINGS FOR FILL-IN l-width IN FRAME F-Main
   ALIGN-R                                                              */
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

&Scoped-define SELF-NAME BUTTON-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-1 V-table-Win
ON CHOOSE OF BUTTON-1 IN FRAME F-Main /* A3 */
DO:

define variable A4port-H as integer   no-undo init 63.
define variable A4port-W as integer   no-undo init 136.
define variable A4lans-H as integer   no-undo init 43.
define variable A4lans-W as integer   no-undo init 198.

run define-a4-size (
    input ReportFontNum
    ,output A4port-H
    ,output A4port-W
    ,output A4lans-H
    ,output A4lans-W ).

  l-Height:screen-value   in frame {&frame-name} = string(A4port-H) .
  l-Width:screen-value    in frame {&frame-name} = "278".

  run how-name
  ( input integer(l-height:screen-value  in frame {&frame-name}),
    input integer(l-width:screen-value   in frame {&frame-name}),
    output (l-name )
    ).
 display l-name with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BUTTON-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BUTTON-2 V-table-Win
ON CHOOSE OF BUTTON-2 IN FRAME F-Main /* A4 */
DO:
define variable A4port-H as integer   no-undo init 63.
define variable A4port-W as integer   no-undo init 136.
define variable A4lans-H as integer   no-undo init 43.
define variable A4lans-W as integer   no-undo init 198.

run define-a4-size (
     input  ReportFontNum
    ,output A4port-H
    ,output A4port-W
    ,output A4lans-H
    ,output A4lans-W
    ).

  if gl-w > A4port-W or gl-w  = 0 or gl-w = ? then do:
    l-Height:screen-value in frame {&frame-name} = string(A4lans-H).
    l-Width:screen-value  in frame {&frame-name} = string(A4lans-W).
  end.
  else do:
    l-Height:screen-value in frame {&frame-name} = string(A4port-H).
    l-Width:screen-value  in frame {&frame-name} = string(A4port-W).
  end.

  run How-name (INPUT integer(l-Height:screen-value  in frame {&frame-name}),
                INPUT integer(l-Width:screen-value   in frame {&frame-name}),
                OUTPUT (l-name ))
                .
 display l-name with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME IMAGE-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL IMAGE-1 V-table-Win
ON CHOOSE OF IMAGE-1 IN FRAME F-Main /* IMAGE-1 */
DO:
  l-Width:screen-value   in frame {&frame-name} =
  string (integer(l-Width:screen-value   in frame {&frame-name}) - 1).

  run How-name (INPUT integer(l-Height:screen-value  in frame {&frame-name}),
              INPUT integer(l-Width:screen-value   in frame {&frame-name}),
              OUTPUT (l-name )).
              display l-name with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME IMAGE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL IMAGE-2 V-table-Win
ON CHOOSE OF IMAGE-2 IN FRAME F-Main /* IMAGE-2 */
DO:
  l-Width:screen-value in frame {&frame-name} =
  string (integer(l-Width:screen-value   in frame {&frame-name}) + 1) .

  run how-name
    ( input integer (l-height:screen-value in frame {&frame-name}) ,
      input integer (l-width:screen-value  in frame {&frame-name}) ,
      output (l-name ))
      .

  display l-name with frame {&frame-name} .

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME IMAGE-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL IMAGE-4 V-table-Win
ON CHOOSE OF IMAGE-4 IN FRAME F-Main /* IMAGE-4 */
DO:
  l-Height:screen-value   in frame {&frame-name} =
  string (integer(l-Height:screen-value   in frame {&frame-name}) - 1).

  run How-name (INPUT integer(l-Height:screen-value  in frame {&frame-name}),
              INPUT integer(l-Width:screen-value   in frame {&frame-name}),
              OUTPUT (l-name )).
 display l-name with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME IMAGE-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL IMAGE-5 V-table-Win
ON CHOOSE OF IMAGE-5 IN FRAME F-Main /* IMAGE-5 */
DO:
  l-Height:screen-value   in frame {&frame-name} =
  string (integer(l-Height:screen-value   in frame {&frame-name}) + 1).

  run How-name (INPUT integer(l-Height:screen-value  in frame {&frame-name}),
              INPUT integer(l-Width:screen-value   in frame {&frame-name}),
              OUTPUT (l-name )).
              display l-name with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-height
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-height V-table-Win
ON LEAVE OF l-height IN FRAME F-Main
DO:
  run How-name (INPUT integer(l-Height:screen-value  in frame {&frame-name}),
              INPUT integer(l-Width:screen-value   in frame {&frame-name}),
              OUTPUT (l-name )).
              display l-name with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME l-width
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL l-width V-table-Win
ON LEAVE OF l-width IN FRAME F-Main
DO:
  run How-name (INPUT integer(l-Height:screen-value  in frame {&frame-name}),
              INPUT integer(l-Width:screen-value   in frame {&frame-name}),
              OUTPUT (l-name )).
              display l-name with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME r-font
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL r-font V-table-Win
ON CHOOSE OF r-font IN FRAME F-Main
DO:
  run rep/lkp-font.w
     ( output l-fontnum  ,
       output l-fontname ,
       output l-fontsize ,
       output l-fonttype ,
       output v-h        ,
       output v-w        ,
       output v-h-lans   ,
       output v-w-lans
       ) .
  if l-fontnum = 0 or l-fontnum = ? then
      return no-apply.
  display l-fontnum
      l-fontname
      l-fontsize
      l-fonttype
      with frame {&frame-name}
      .

  assign
    ReportFontNum    = l-fontnum
    ReportPageHeight = v-h
    ReportPageWidth  = v-w
  .

  l-Height:screen-value   in frame {&frame-name} =  string(ReportPageWidth).
  l-Width:screen-value    in frame {&frame-name} =  string(ReportPageHeight).


  run how-name in this-procedure (
      input integer(l-height:screen-value  in frame {&frame-name}),
      input integer(l-width:screen-value   in frame {&frame-name}),
      output l-name
      ).

 display l-name with frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK V-table-Win


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
  &IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
    RUN dispatch IN THIS-PROCEDURE ('initialize':U).
  &ENDIF

  /************************ INTERNAL PROCEDURES ********************/

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available V-table-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI V-table-Win  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE Get-var-2 V-table-Win
PROCEDURE Get-var-2 :
define variable s-i as integer no-undo .
define variable s-t as character no-undo .
define variable A4port-H as integer   no-undo init 63.
define variable A4port-W as integer   no-undo init 136.
define variable A4lans-H as integer   no-undo init 43.
define variable A4lans-W as integer   no-undo init 198.

run define-a4-size (
     input  ReportFontNum
    ,output A4port-H
    ,output A4port-W
    ,output A4lans-H
    ,output A4lans-W
    ).

repeat  s-i = 1 to {&xlMaxCols}  :
  s-t =  s-t + string(Use-Column[s-i] , "true/false")  + ";".
End.

 ReportPageHeight = Integer(l-Height:screen-value in frame {&frame-name}) .
 ReportPageWidth  = Integer(l-Width:screen-value  in frame {&frame-name}) .

 find first buf_usr-flt exclusive-lock where
         buf_usr-flt.user-name = g#userid and
         buf_usr-flt.call-point   = ReportProc  no-error .
     if NOT available buf_usr-flt then  create buf_usr-flt.
       Assign
         buf_usr-flt.user-name = g#userid
         buf_usr-flt.call-point   = ReportProc
         buf_usr-flt.list_ = string( "ReportPageHeight=" + string(ReportPageHeight)) + ","
                           + string( "ReportPageWidth="  + string(ReportPageWidth)) + ","
                           + string( "ReportFontNum="    + string(ReportFontNum)) + ","
                           + string( "Use-Column="       + string(s-t))
         .
 find current buf_usr-flt no-lock .


if ReportPageHeight = 0 and ReportPageWidth  = 0 then DO:
          Assign l-Height:screen-value  in frame {&frame-name} = string(A4lans-H)      /*43*/
                 l-Width:screen-value   in frame {&frame-name} = string(A4lans-W)     /*198*/
               .
               run How-name (INPUT integer(l-Height:screen-value  in frame {&frame-name}),
                             INPUT integer(l-Width:screen-value   in frame {&frame-name}),
                             OUTPUT l-name).
                             display l-name  with frame {&frame-name}.
          return error "format-page".
          end.

END PROCEDURE.


PROCEDURE How-name-H :
define input  parameter  w as integer no-undo . /*  ширина отчета в символах */
define output parameter h as integer no-undo .
define output parameter n as character no-undo .

define variable Strim-W  as integer   no-undo init 278.
define variable A4port-H as integer   no-undo init 63.
define variable A4port-W as integer   no-undo init 136.
define variable A4lans-H as integer   no-undo init 43.
define variable A4lans-W as integer   no-undo init 198.

run define-a4-size (
    input ReportFontNum
    ,output A4port-H
    ,output A4port-W
    ,output A4lans-H
    ,output A4lans-W ).
gl-w  = w .


If w >= 1 and w <= A4port-W Then DO:
   h = A4port-H  .
   n = "A4-port":U.
End.

If w > A4port-W and w <= A4lans-W Then DO:
   h = A4lans-H .
   n = "A4-lans":U.
End.

If w > A4lans-W and w <= Strim-W Then DO:
  h = A4port-H .
  n = "A3-lans":U.
End.

If w > Strim-W Then DO:
   h = A4port-H .
   n = "to-file":U.
End.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize V-table-Win
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .
define variable  l-ind as integer no-undo .
define variable A4port-H as integer   no-undo init 63.
define variable A4port-W as integer   no-undo init 136.
define variable A4lans-H as integer   no-undo init 43.
define variable A4lans-W as integer   no-undo init 198.

run define-a4-size (
    input ReportFontNum
    ,output A4port-H
    ,output A4port-W
    ,output A4lans-H
    ,output A4lans-W ).

 find first buf_usr-flt no-lock  where
         buf_usr-flt.user-name  = g#userid and
         buf_usr-flt.call-point = ReportProc  no-error .
     if available buf_usr-flt then  DO:
          repeat l-ind = 1 to num-entries(buf_usr-flt.list_) :
                    if entry(1,entry(l-ind,buf_usr-flt.list_),"=")  = "ReportPageHeight":U then
                       l-Height:screen-value in frame {&frame-name} = entry(2,entry(l-ind,buf_usr-flt.list_),"=") no-error .
                       if error-status :error  then message "высота" .

                    if entry(1,entry(l-ind,buf_usr-flt.list_),"=")  = "ReportPageWidth":U then
                       l-Width:screen-value in frame {&frame-name} = entry(2,entry(l-ind,buf_usr-flt.list_),"=") no-error .
                       if error-status :error  then message "ширина" .

                    if entry(1,entry(l-ind,buf_usr-flt.list_),"=")  = "ReportFontNum":U then
                       ReportFontNum = integer (entry(2,entry(l-ind,buf_usr-flt.list_),"=")) no-error .
                    if ReportFontNum = 0 or ReportFontNum = ? or  error-status :error then ReportFontNum = 7.
                       l-FontNum:screen-value in frame {&frame-name} = string(ReportFontNum) .
                        run define-a4-size (
                            input ReportFontNum
                            ,output A4port-H
                            ,output A4port-W
                            ,output A4lans-H
                            ,output A4lans-W ).
                        run select-font ( input ReportFontNum ) .
               End.
              if ReportFontNum = 0 or ReportFontNum = ? or  error-status :error then ReportFontNum = 7.
              l-FontNum:screen-value in frame {&frame-name} = string(ReportFontNum) .
              run define-a4-size (
                  input ReportFontNum
                  ,output A4port-H
                  ,output A4port-W
                  ,output A4lans-H
                  ,output A4lans-W ).
              run select-font ( input ReportFontNum ) .

   End.
   Else do:
      run define-a4-size (
           input 7
          ,output A4port-H
          ,output A4port-W
          ,output A4lans-H
          ,output A4lans-W ).
      run select-font ( input 7 ) .

      Assign l-Height:screen-value  in frame {&frame-name} = string(A4lans-H)
             l-Width:screen-value   in frame {&frame-name} = string(A4lans-W)
                .
   end.
run How-name (INPUT integer(l-Height:screen-value  in frame {&frame-name}),
              INPUT integer(l-Width:screen-value   in frame {&frame-name}),
              OUTPUT (l-name )).
display l-name with frame {&frame-name}.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-font V-table-Win
PROCEDURE select-font :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
define input  parameter p-fontnum as integer   no-undo .
find first temp-font where temp-font.fontnum = p-FontNum no-error .
if available temp-font then do:
  l-fontnum  = temp-font.fontnum .
  l-fontname = temp-font.fontname.
  l-fontsize = temp-font.fontsize.
  l-fonttype = temp-font.fonttype.
end.
else do:
  assign
    l-fontnum  = 7
    l-fontname = "Нет настройки фонта"
    l-fontsize = ""
    l-fonttype = ""
  .
end.
 display
      l-fontnum
      l-fontname
      l-fontsize
      l-fonttype
      with frame {&frame-name}
      .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records V-table-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartObject, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed V-table-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER p-state      AS CHARACTER NO-UNDO.

  CASE p-state:
      /* Object instance CASEs can go here to replace standard behavior
         or add new cases. */
      {src/adm/template/vstates.i}
  END CASE.
END PROCEDURE.

procedure view-how-name :
define input parameter l-w like ReportPageWidth no-undo .

          Assign l-Height:screen-value  in frame {&frame-name} = string(ReportPageHeight)
                 l-Width:screen-value   in frame {&frame-name} = string(l-w)
                 .
               run How-name-h (INPUT l-w ,
                               OUTPUT ReportPageHeight,
                               OUTPUT l-name).

          Assign l-Height:screen-value  in frame {&frame-name} = string(ReportPageHeight)
                 l-Width:screen-value   in frame {&frame-name} = string(l-w)
                 .
          display l-name with frame {&frame-name}.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
