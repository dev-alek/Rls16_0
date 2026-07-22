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

Реестр документов движения серийных МЦ (вторая закладка)

Автор: Кочетков Михаил Юрьевич
Дата создания: 06/19/08
Author: Michael Kochetkov
Creation date: 06/19/08

*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Реестр документов движения серийных МЦ (ЗАКЛАДКА №2)".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
/*{ gbl/onewin.i   }*/
{ gbl/thbjattr.i }
{ gbl/twowin.i   }
{ gbl/usr-flt.i }
CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
/*
DEFINE TEMP-TABLE tt-grp NO-UNDO
      FIELD grp-name    as character
      FIELD grp-code    as integer

      INDEX pi IS PRIMARY UNIQUE
            grp-code
.
*/

define variable v-wth-pl-list     as character    no-undo.
define variable v-doc-type-list   as character    no-undo.
define variable v-list-wdedt      as character    no-undo.
    assign
        v-list-wdedt  = {&WDEDT_Inc_Ext}
            + ",":U + {&WDEDT_Exp_Ext}
            + ",":U + {&WDEDT_Inc_Int_Put}
            + ",":U + {&WDEDT_Exp_Int_Put}
            + ",":U + {&WDEDT_Ret_Int_Put}
            + ",":U + {&WDEDT_Inc_Int_Free}
            + ",":U + {&WDEDT_Exp_Int_Free}
            + ",":U + {&WDEDT_Ret_Int_Free}
            + ",":U + {&WDEDT_Put_Cash}
            + ",":U + {&WDEDT_Put_Sale}
            + ",":U + {&WDEDT_Put_Cli}
            + ",":U + {&WDEDT_Dst_free}
            + ",":U + {&WDEDT_Dst_Put}
            + ",":U + {&WDEDT_exch}
            + ",":U + {&WDEDT_Inc_Obj_Free}
            + ",":U + {&WDEDT_Exp_Obj_Free}
            + ",":U + {&WDEDT_Inc_Obj_Put}
            + ",":U + {&WDEDT_Exp_Obj_Put}
            + ",":U + {&WDEDT_Dst_Cli}
    .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-7 RECT-8 RECT-9 RECT-10 is-detal ~
rs-date is-range bt-doc-type sl-doc-type rs-wth-pl bt-wth-pl ed-wth-pl
&Scoped-Define DISPLAYED-OBJECTS is-detal rs-date is-range f-dtFrom f-dtEnd ~
sl-doc-type rs-wth-pl ed-wth-pl

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON bt-doc-type
     LABEL "&Изменить"
     SIZE 10 BY 1.

DEFINE BUTTON bt-wth-pl
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "&Изменить"
     SIZE 3 BY 1.

DEFINE VARIABLE ed-wth-pl AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
     SIZE 36.5 BY 8.88
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE f-dtEnd AS DATE FORMAT "99/99/9999":U
     LABEL "по"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.

DEFINE VARIABLE f-dtFrom AS DATE FORMAT "99/99/9999":U
     LABEL "C"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.

DEFINE VARIABLE rs-date AS INTEGER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "фактической дате", 1,
"дате счета-фактуры", 2
     SIZE 42 BY 1 NO-UNDO.

DEFINE VARIABLE rs-wth-pl AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", 1,
"Выборочно", 2
     SIZE 12 BY 1.46 NO-UNDO.

DEFINE RECTANGLE RECT-10
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 38.5 BY 3.75.

DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 43.5 BY 13.5.

DEFINE RECTANGLE RECT-8
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 38.5 BY 11.88.

DEFINE RECTANGLE RECT-9
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 43.5 BY 2.25.

DEFINE VARIABLE sl-doc-type AS CHARACTER
     VIEW-AS SELECTION-LIST SINGLE NO-DRAG SCROLLBAR-VERTICAL
     LIST-ITEM-PAIRS "< Все >","''"
     SIZE 41.63 BY 10.96 NO-UNDO.

DEFINE VARIABLE is-detal AS LOGICAL INITIAL no
     LABEL "Детализация по МЦ"
     VIEW-AS TOGGLE-BOX
     SIZE 25.5 BY .83 NO-UNDO.

DEFINE VARIABLE is-range AS LOGICAL INITIAL no
     LABEL "Учитывать срок годности партии"
     VIEW-AS TOGGLE-BOX
     SIZE 35.5 BY .83 TOOLTIP "Учитывать период возможного начала срока годности партии" NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     is-detal AT ROW 1.5 COL 47.5 WIDGET-ID 52
     rs-date AT ROW 2.29 COL 3 NO-LABEL WIDGET-ID 48
     is-range AT ROW 2.75 COL 47.5 WIDGET-ID 56
     f-dtFrom AT ROW 3.75 COL 48 COLON-ALIGNED WIDGET-ID 58
     f-dtEnd AT ROW 3.75 COL 66 COLON-ALIGNED WIDGET-ID 60
     bt-doc-type AT ROW 4.63 COL 3.5 WIDGET-ID 38
     sl-doc-type AT ROW 5.83 COL 2.88 NO-LABEL WIDGET-ID 16
     rs-wth-pl AT ROW 6.21 COL 48.63 NO-LABEL WIDGET-ID 34
     bt-wth-pl AT ROW 6.67 COL 60.63 WIDGET-ID 18
     ed-wth-pl AT ROW 8 COL 47 NO-LABEL WIDGET-ID 28
     "Места хранения:" VIEW-AS TEXT
          SIZE 22.5 BY .67 AT ROW 5.5 COL 48.5
          FGCOLOR 4
     "Отбор документов по:" VIEW-AS TEXT
          SIZE 22.5 BY .67 AT ROW 1.5 COL 2.5 WIDGET-ID 46
          FGCOLOR 4
     "Учитывать только виды документов:" VIEW-AS TEXT
          SIZE 34.5 BY .67 AT ROW 3.88 COL 3.5 WIDGET-ID 40
          FGCOLOR 4
     RECT-7 AT ROW 3.63 COL 2
     RECT-8 AT ROW 5.25 COL 46 WIDGET-ID 42
     RECT-9 AT ROW 1.25 COL 2 WIDGET-ID 44
     RECT-10 AT ROW 1.25 COL 46 WIDGET-ID 54
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1 SCROLLABLE
         BGCOLOR 8 .


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartViewer
   Allow: Basic,DB-Fields
   Frames: 1
   Add Fields to: EXTERNAL-TABLES
   Other Settings: PERSISTENT-ONLY
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN DO:
  MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
          VIEW-AS ALERT-BOX ERROR BUTTONS OK.
  RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 16.25
         WIDTH              = 84.25.
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
       FRAME F-Main:SCROLLABLE       = FALSE
       FRAME F-Main:HIDDEN           = TRUE.

ASSIGN
       ed-wth-pl:READ-ONLY IN FRAME F-Main        = TRUE.

/* SETTINGS FOR FILL-IN f-dtEnd IN FRAME F-Main
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN f-dtFrom IN FRAME F-Main
   NO-ENABLE                                                            */
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

&Scoped-define SELF-NAME bt-doc-type
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-doc-type s-object
ON CHOOSE OF bt-doc-type IN FRAME F-Main /* Изменить */
DO:
    run select-doc-type in this-procedure.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-wth-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-wth-pl s-object
ON CHOOSE OF bt-wth-pl IN FRAME F-Main /* Изменить */
DO:
  assign rs-wth-pl = 2 .
  run select-wth-pl in this-procedure.
  display  rs-wth-pl  ed-wth-pl with frame {&frame-name}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME f-dtFrom
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL f-dtFrom s-object
ON RETURN OF f-dtFrom IN FRAME F-Main /* C */
DO:
  APPLY 'entry':U TO f-dtEnd.
  RETURN NO-APPLY.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME is-range
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL is-range s-object
ON VALUE-CHANGED OF is-range IN FRAME F-Main /* Учитывать срок годности партии */
DO:
  IF SELF:CHECKED THEN DO:
      ENABLE f-dtFrom f-dtEnd with FRAME {&FRAME-NAME}.
      f-dtFrom:BGCOLOR = 15.
      f-dtEnd:BGCOLOR = 15.
      apply "entry":u to f-dtFrom.
      return no-apply.
  END.
  ELSE DO:
      DISABLE f-dtFrom f-dtEnd with FRAME {&FRAME-NAME}.
      f-dtFrom:BGCOLOR = ?.
      f-dtEnd:BGCOLOR = ?.

  END.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME rs-wth-pl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL rs-wth-pl s-object
ON VALUE-CHANGED OF rs-wth-pl IN FRAME F-Main
DO:
  assign  rs-wth-pl .
  case rs-wth-pl:
    when 1 then do:
      assign  ed-wth-pl = "Все" .
      display ed-wth-pl with frame {&frame-name}.
      v-wth-pl-list = ''.
    end.
    when 2 then do:
      apply "choose" to bt-wth-pl.
    end.
    otherwise do:
      return no-apply.
    end.
  end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object


/* ***************************  Main Block  *************************** */

/* If testing in the UIB, initialize the SmartObject. */

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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-apply-layout s-object
PROCEDURE local-apply-layout :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */

  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'apply-layout':U ) .

  /* Code placed here will execute AFTER standard behavior.    */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE local-initialize :
define buffer buf_wth-place for ub.wth-place .

  define variable v-rs-wth-pl      as logical   no-undo.
  define variable v-rs-doc-type    as logical   no-undo.
  define variable v-factdate       as logical      no-undo.
  define variable v-detal          as logical      no-undo.
  define variable v-found          as logical      no-undo.
  define variable v-i              as integer   no-undo .
  define variable v-wth-pl-lst     as character    no-undo.
  define variable v-doc-type-lst   as character    no-undo.

  do on error undo, return error :
    RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

    run uf-get (
          input {&uf-wthrd}
        , input v-cntxt-userid
        , output v-doc-type-lst
        , output v-wth-pl-lst
        , output v-rs-wth-pl
        , output v-rs-doc-type
        , output v-factdate
        , output v-detal
    ) no-error.
    if error-status :error = false then do:  /* есть значения */
      if v-factdate = yes then  assign rs-date = 1 .
      else                      assign rs-date = 2 .
      assign is-detal = v-detal .
      if v-rs-wth-pl = no then do:
        assign
          rs-wth-pl  = 1
          ed-wth-pl  = "Все":u
        .
      end.
      else do:
        assign
          rs-wth-pl = 2
          v-wth-pl-list = "":U
        .
        _flt-grp-load:
        do v-i = 1 to num-entries(v-wth-pl-lst) :
          find first buf_wth-place where RECID(buf_wth-place) = integer( entry( v-i, v-wth-pl-lst, {&comma-char} ) ) no-lock no-error .
          if available buf_wth-place then do:
            assign
              ed-wth-pl = ed-wth-pl + buf_wth-place.w-p-name + {&new-line}
              v-wth-pl-list = IF v-wth-pl-list = "":U THEN entry( v-i, v-wth-pl-lst, {&comma-char} ) ELSE v-wth-pl-list + {&comma-char} + entry( v-i, v-wth-pl-lst, {&comma-char} )
            .
          end.
        end.
      end.
      assign v-doc-type-list = v-doc-type-lst .
      define variable v-counter as integer   no-undo .
      define variable ii as integer   no-undo .
      if v-rs-doc-type = no then
      assign
        sl-doc-type :list-item-pairs in frame F-Main   = "< Все >":U
      .
      else do:
        assign
          v-counter = 0
        .
        do ii = 1 to num-entries( v-doc-type-lst ) :
          assign  v-counter = v-counter + 1  .
          if v-counter = 1 then do:
            assign sl-doc-type :list-item-pairs = substitute( "&1,&2", entry( lookup(  entry( ii, v-doc-type-lst ), {&WDEDT_List} ), {&WDEDT_List-full} ), entry( ii, v-doc-type-lst ) ) .
          end.
          else do:
            sl-doc-type :add-last (entry( lookup( entry( ii, v-doc-type-lst ), {&WDEDT_List} ), {&WDEDT_List-full} ), entry( ii, v-doc-type-lst ) ) .
          end.
        end.
      end.
    end.
    else do:
      assign
        rs-date = 1
        is-detal = no
        rs-wth-pl  = 1
        ed-wth-pl  = "Все":u
      .
      assign v-doc-type-list = v-list-wdedt .
    end.
    display is-detal rs-date rs-wth-pl ed-wth-pl with frame {&frame-name}.
  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
    define variable v-counter               as integer      no-undo.
    define variable v-ext-doc-type-list     as character    no-undo.
assign frame {&Frame-name} is-range .
f-dtFrom = date(f-dtFrom:screen-value in frame {&Frame-name} ) no-error.
f-dtEnd = date(f-dtEnd:screen-value) no-error.
do on error undo, return error :
   IF rs-wth-pl = 2 and v-wth-pl-list = "":U THEN DO:
     message "Не выбран список мест хранения"  view-as alert-box information.
     return no-apply.
   END.
   IF v-doc-type-list = "":U THEN DO:
     message "Не выбран список типов документов"  view-as alert-box information.
     return no-apply.
   END.
   if is-range and (f-dtFrom = ? or f-dtEnd = ?) then do:
    message "Не верно задан возможный период начала срока годности партий"  view-as alert-box error.
    return no-apply.
   end.
   run uf-set (
        input {&uf-wthrd}
      , input v-cntxt-userid
      , input v-doc-type-list
      , input v-wth-pl-list
      , input ( if rs-wth-pl = 1 then no else yes )
      , input yes
      , input ( if rs-date = 2 then no else yes )
      , input is-detal
   ) .

   run rep/r-wthrd.p  (  input rs-wth-pl
                       , input v-wth-pl-list
                       , input v-doc-type-list
                       , input rs-date
                       , input is-detal
                       , INPUT is-range
                       , INPUT f-dtFrom
                       , INPUT f-DtEnd
                       ) .
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета, может быть еще пример шапки???

------------------------------------------------------------------------------*/
 assign frame {&frame-name}  rs-wth-pl rs-date is-detal is-range .

/*    PUT STREAM PrnLibstream UNFORMATTED*/
/*      "СМЕНЫ С: " + string (temp-shift-obj.shift-name) + " ОТ " + String( temp-shift-obj.open-date , "99/99/9999") + ' ' + String ( temp-shift-obj.open-time,"hh:mm")  at 85  skip*/
/*    .*/
/*    find first temp-shift-obj where temp-shift-obj.num = v-count .*/
/*    PUT STREAM PrnLibstream UNFORMATTED*/
/*      "ПО: " + string (temp-shift-obj.shift-name) + " ОТ " + String( temp-shift-obj.open-date , "99/99/9999") + ' ' + String ( temp-shift-obj.open-time,"hh:mm") +*/
/*      " ЗАКРЫТА " + string( temp-shift-obj.close-date,"99/99/9999") + " " +  string(temp-shift-obj.close-time,"hh:mm")     at 90      skip*/
/*    .*/

def var v-sl-doc-type as char  no-undo.
define variable ii as integer   no-undo .

do ii = 1 to num-entries(sl-doc-type:list-item-pairs):
  if ii modulo 2  = 1 then do:
    v-sl-doc-type = v-sl-doc-type + entry(ii,sl-doc-type:list-item-pairs)  + {&new-line}.
  end.
end.

  assign  ReportHeader =   {&new-line} + "Отбор документов по:" + {&new-line} + entry(rs-date,"Фактической дате,Дате счета-фактуры") + {&new-line}
                           + {&new-line} + "Виды документов:" + {&new-line} + v-sl-doc-type + {&new-line}
                           + {&new-line}+ "Места хранения:" + {&new-line} + ed-wth-pl + {&new-line}
                           + {&new-line} + "Детализация по МЦ:" + {&new-line} + string(is-detal,"Да/Нет") + {&new-line}
                           + {&new-line} + "Учитывать срок годности:" + {&new-line} + string(is-range,"Да/Нет") + {&new-line}
                           + {&new-line} + (if is-range then substitute("Период возможного начала срока годности: &1 - &2",f-dtFrom:screen-value,f-dtEnd:screen-value) else '')
                           .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-doc-type s-object
PROCEDURE select-doc-type :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

    define variable v-counter       as integer      no-undo.
    define variable v-label         as character    no-undo.
    define variable v-value         as character    no-undo.
    define variable v-list          as character    no-undo.
    define variable v-changed       as logical    no-undo.
    define variable v-accepted      as logical    no-undo.
    define variable v-list-edt-full   as character    no-undo.
    define variable v-list-edt      as character    no-undo.
    define variable ii as integer   no-undo .
  do with frame {&frame-name} on error undo, return error :

    assign v-list-edt  = v-list-wdedt.
    do ii = 1 to num-entries( v-list-wdedt ) :
      if ii > 1 then assign v-list-edt-full = v-list-edt-full + ",":U .
      assign v-list-edt-full = v-list-edt-full + entry( lookup ( entry( ii, v-list-wdedt ), {&WDEDT_List} ), {&WDEDT_List-full} ) .
    end.

    run twowin_clear in this-procedure.
    do v-counter = 1 to num-entries( v-list-edt-full ) on error undo, return error :
      assign
        v-label = entry( v-counter, v-list-edt-full )
        v-value = entry( v-counter, v-list-edt )
      .
      run twowin_add-item in this-procedure (
              input v-value
            , input v-label
            , input substitute( "Код вида документа: &1", v-value )
            , input ( sl-doc-type :lookup( v-value ) <> 0 or sl-doc-type :list-item-pairs = "< Все >,''":U  )
      ).
    end.        /* do */
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор видов документов":U
        , input "":U
        , input "&Тест"
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected
        , output v-changed
        , output v-accepted
    ).
    if v-accepted = yes and v-changed = yes then do:
      assign
        sl-doc-type :list-item-pairs    = "< Все >,''":U
        v-list                          = "":U
        v-counter = 0
      .
      for each temp_twowin_itemsSelected by temp_twowin_itemsSelected.itm-key :
        assign
          v-counter = v-counter + 1
          v-list = substitute( "&1&2&3", v-list, ( if v-list = "":U then "":U else ",":U ), temp_twowin_itemsSelected.itmExtKey )
        .
        if v-counter = 1 then do:
          assign sl-doc-type :list-item-pairs = substitute( "&1,&2", entry( lookup( temp_twowin_itemsSelected.itmExtKey, v-list-edt ), v-list-edt-full ), temp_twowin_itemsSelected.itmExtKey ) .
        end.
        else do:
          sl-doc-type :add-last (entry( lookup( temp_twowin_itemsSelected.itmExtKey, v-list-edt ), v-list-edt-full ), temp_twowin_itemsSelected.itmExtKey ) .
        end.
      end.
      assign v-doc-type-list = v-list .
      if v-list = v-list-edt then assign sl-doc-type :list-item-pairs = "< Все >,''":U .
    end.
  end.
END PROCEDURE. /* select-doc-type */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-wth-pl s-object
PROCEDURE select-wth-pl :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define buffer buf_wth-place     for ub.wth-place .
  define variable v-count    as integer      no-undo.

  define variable v-wth-pl-lst    as character    no-undo.
  define variable v-i    as integer      no-undo.
  do on error undo, return error :
  assign ed-wth-pl = ''
  v-wth-pl-lst = v-wth-pl-list
  v-wth-pl-list = ''.
    run ref/wthplref.w
        (input my-handle
        ,input 'b-sel,b-mark':u
        ,input v-cntxt-host-code-obj
        ,input v-cntxt-obj-type
        ,input v-cntxt-obj-code
        ,input if v-cntxt-db-num = 0 then {&company} else {&g___object}
        ,input-output v-wth-pl-lst
    ).
    do v-i = 1 to num-entries(v-wth-pl-lst) :
      find first buf_wth-place where RECID(buf_wth-place) = integer( entry( v-i, v-wth-pl-lst, {&comma-char} ) ) no-lock no-error .
      if available buf_wth-place then do:
        assign
          ed-wth-pl = ed-wth-pl + buf_wth-place.w-p-name + {&new-line}
          v-wth-pl-list = IF v-wth-pl-list = "":U THEN entry( v-i, v-wth-pl-lst, {&comma-char} ) ELSE v-wth-pl-list + {&comma-char} + entry( v-i, v-wth-pl-lst, {&comma-char} )
        .
      end.
    end.
  end.  /* do on error */
END PROCEDURE. /* select-wth-pl */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME