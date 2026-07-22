&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object
/*

 
 
------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.      */
/*----------------------------------------------------------------------*/

CREATE WIDGET-POOL.


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Реестр документов ЕГАИС (ЗАКЛАДКА №2)".

{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/r-page1.i   }
{ rep/rep-bt.i    }
{ gbl/twowin.i    }
define variable parparentproc as widget-handle no-undo .

{ gbl/usr-flt.i }


define variable v-column-list as character no-undo.
run proc-get .

/* ***************************  Definitions  ************************** */
/*        run flt-load.*/

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartViewer
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target
/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME fMain

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS list-column p-izm-column 
&Scoped-Define DISPLAYED-OBJECTS list-column 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE BUTTON p-izm-column 
    LABEL "Изменить" 
    SIZE 15 BY 1.13.

DEFINE VARIABLE list-column AS CHARACTER 
    VIEW-AS SELECTION-LIST SINGLE SCROLLBAR-VERTICAL 
    SIZE 40.5 BY 12 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME fMain
    list-column AT ROW 2.75 COL 6 NO-LABEL WIDGET-ID 2
    p-izm-column AT ROW 3 COL 48 WIDGET-ID 6
    "Колонки:" VIEW-AS TEXT
    SIZE 12.5 BY 1 AT ROW 1.5 COL 6 WIDGET-ID 4
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
    SIDE-LABELS NO-UNDERLINE THREE-D 
    AT COL 1 ROW 1
    SIZE 71.5 BY 14.88 WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartFrame
   Allow: Basic,Browse,DB-Fields,Query,Smart
   Container Links: Data-Target,Data-Source,Page-Target,Update-Source,Update-Target
   Other Settings: PERSISTENT-ONLY APPSERVER
 */

/* This procedure should always be RUN PERSISTENT.  Report the error,  */
/* then cleanup and return.                                            */
IF NOT THIS-PROCEDURE:PERSISTENT THEN 
DO:
    MESSAGE "{&FILE-NAME} should only be RUN PERSISTENT.":U
        VIEW-AS ALERT-BOX ERROR BUTTONS OK.
    RETURN.
END.

&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 16.75
         WIDTH              = 73.
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
    FRAME fMain:HIDDEN = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME fMain
/* Query rebuild information for FRAME fMain
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME fMain */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME p-izm-column
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL p-izm-column s-object
ON CHOOSE OF p-izm-column IN FRAME fMain /* Изменить */
    DO:
        run izm-col in this-procedure.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK fFrameWin 


/* ***************************  Main Block  *************************** */


/*{ gbl/personly.i }*/
/* If testing in the UIB, initialize the SmartObject. */
/*/*                                                   */*/
/*&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN                 */
/* RUN dispatch IN THIS-PROCEDURE ('initialize':U).      */
/*&ENDIF                                                 */
{ gbl/personly.i }

assign
    parparentproc = my-handle
    .
{ gbl/getcntxt.i get }

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN 
RUN patch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */


/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

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
    HIDE FRAME fMain.
    IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI s-object  _DEFAULT-ENABLE
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
    DISPLAY list-column 
        WITH FRAME fMain.
    ENABLE list-column p-izm-column 
        WITH FRAME fMain.
    {&OPEN-BROWSERS-IN-QUERY-fMain}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE izm-col s-object
PROCEDURE izm-col :
    /*------------------------------------------------------------------------------
      Purpose:     
      Parameters:  <none>
      Notes:       
    ------------------------------------------------------------------------------*/
    define variable v-counter       as integer   no-undo.
    define variable v-label         as character no-undo.
    define variable v-value         as character no-undo.
    define variable v-list          as character no-undo.
    define variable v-changed       as logical   no-undo.
    define variable v-accepted      as logical   no-undo.
    define variable v-list-edt      as character no-undo.
    define variable v-list-edt-full as character no-undo.
    
    do
        with frame {&frame-name}
        on error undo, return error
        :
            
            
        v-uf-Naim = "".
            
        assign
            v-list-edt = "Поставщик ЕГАИС" + 
        "," + "ID Поставщика" + 
        "," + "ИНН/КПП" + 
        "," + "Дата документа из ЕГАИС" + 
        "," + "№ документа поставщика" + 
        "," + "№ накладной в ЕГИС" + 
        "," + "дата TH" +
        "," + "№ документа TH" + 
        "," + "Сумма документа TH" + 
        "," + "Сумма документа ЕГАИС" + 
        "," + "Cтатус" + 
        "," + "Расхождение(да/нет)".
        
        assign
            v-list-edt-full = "Поставщик ЕГАИС" + 
        "," + "ID Поставщика" + 
        "," + "ИНН/КПП" + 
        "," + "Дата документа из ЕГАИС" + 
        "," + "№ документа поставщика" + 
        "," + "№ накладной в ЕГИС" + 
        "," + "дата TH" +
        "," + "№ документа TH" + 
        "," + "Сумма документа TH" + 
        "," + "Сумма документа ЕГАИС" + 
        "," + "Cтатус" + 
        "," + "Расхождение(да/нет)".
        
        run twowin_clear in this-procedure.
        do v-counter = 1 to num-entries( v-list-edt-full )
            on error undo, return error
            :
            assign
                v-label = entry( v-counter, v-list-edt-full )
                v-value = entry( v-counter, v-list-edt )
                .
            run twowin_add-item in this-procedure (
                input v-value
                , input v-label
                , input substitute( "Название колонки: &1", v-value )
                , input ( list-column :lookup( v-value ) <> 0  )
                ).
        end. 
        run gbl/twowin.w (
            input ?
            , input 1
            , input "Выбор колонок":U
            , input "":U
            , input "&Тест"
            , input table temp_twowin_items
            , output table temp_twowin_itemsSelected
            , output v-changed
            , output v-accepted
            ).
        
        if

            v-changed = yes
            then 
        do:
            assign
                list-column :list-items = "":U
                v-list                  = "":U
                v-counter               = 0
                .

            for each temp_twowin_itemsSelected
                by temp_twowin_itemsSelected.itm-key
                :
                assign
                    v-counter = v-counter + 1
                    v-list    = substitute( "&1&2&3"
                                , v-list
                                , ( if v-list = "":U then "":U else ",":U )
                                , temp_twowin_itemsSelected.itmExtKey
                                )
                    .

                list-column :add-last (
                    entry( lookup( temp_twowin_itemsSelected.itmExtKey, v-list-edt ), v-list-edt-full )
                    , temp_twowin_itemsSelected.itmExtKey
                    ) no-error.
            end.
   
        end.   
    end.
    v-column-list = "".
    do v-counter = 1 to list-column :num-items in frame {&frame-name}
        on error undo, return error
        :
        assign
            v-column-list = substitute( "&1&2&3"
                                        , v-column-list
                                        , ( if v-column-list = "":U then "":U else ",":U )
                                        , entry( v-counter , list-column :list-items ) 
                                        ) 
            .
    end.        /* do */
    v-uf-Naim = v-column-list.
    
    run uf-set in this-procedure
        ( input {&uf-alc-rees}
        ,input v-cntxt-userid
        ,input v-uf-List_
        ,input v-uf-Naim
        ,input v-uf-print-graft
        ,input v-uf-sort-gr
        ,input v-uf-type-price
        ,input v-uf-type-val
        ) no-error .


END PROCEDURE.

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



PROCEDURE my-report :
    /*------------------------------------------------------------------------------
      Purpose:     здесь происходит вызов  процедуры отчета с любыми пареметрами
    ------------------------------------------------------------------------------*/
    define variable v-begin-date  as date    no-undo.
    define variable v-end-date    as date    no-undo.
    define variable v-begin-shift as integer no-undo.
    define variable v-end-shift   as integer no-undo.
   
    do
        on error undo, return error
        :

               

        run rep/r-alc-rees.p (
            input v-uf-Naim
            ).
    end.
END PROCEDURE.





PROCEDURE my-var :
    /*------------------------------------------------------------------------------
      Purpose:     здесь происходит вызов  значений переменных
      например  Название отчета, может быть еще пример шапки???
    
    ------------------------------------------------------------------------------*/
    assign frame {&frame-name}
        list-column 
        . 
        
END PROCEDURE.

    /* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE flt-save s-object


    /* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object
PROCEDURE proc-get :
    /*------------------------------------------------------------------------------
      Purpose:     Override standard ADM method
      Notes:
    ------------------------------------------------------------------------------*/

    /*   Code placed here will execute PRIOR to standard behavior.*/
    /*   Dispatch standard ADM method.                            */

    assign frame {&frame-name}
        list-column
        .

    define variable p-naim     as character no-undo .
    define variable v-list     as character no-undo .
    define variable v-type-val as logical   no-undo .

    run uf-get in this-procedure
        ( input  {&uf-alc-rees}
        , input  v-cntxt-userid
        , output v-uf-List_
        , output v-uf-Naim
        , output v-uf-print-graft
        , output v-uf-sort-gr
        , output v-uf-type-price
        , output v-uf-type-val
        ) no-error.


    if not error-status:error then 
    do:


        if v-uf-Naim <> "" then 
        do:
            assign        
                list-column :list-items in frame {&frame-name} = v-uf-Naim.
        end.

    end.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

