&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------

Диалог создания записей в справочнике товаров во внешней системе

Автор: Шаланин Сергей Владимирович
Дата создания: 07/09/2015
Author: Shalanin Sergey
Creation date: 07/09/15

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Диалог создания записей в справочнике товаров во внешней системе ".
/* Parameters Definitions ---                                           */

define input  parameter parparentproc as widget-handle no-undo.
define output parameter  v-rid as recid no-undo .
/* Local Variable Definitions ---                                       */
define variable one-goods as logical no-undo.
define variable char-gds-code as character no-undo.
    DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
   define variable ref-list as char no-undo.
    DEFINE VARIABLE v-ok AS logical NO-UNDO.
    define variable v-esys-id as integer no-undo .
    define variable v-value-character as character no-undo init "".
    define variable v-uniq-key-rec as character no-undo .
    define variable v-esys-uniq-key-rec as character no-undo .
    define variable v-tbl-row as rowid no-undo .
    define variable v-tbl-name as character no-undo .
    define buffer buf_gds-grp for ub.gds-grp.
    define buffer buf_ext-system for ub.ext-system.
    define variable cursorr  as integer no-undo init 0.
  define variable code_goods_name as character no-undo.
    define variable v-list      as character no-undo.
    define variable p-goods-gds  as integer no-undo.
    define variable p-name-goods as char no-undo.
    define variable i as integer   no-undo .
        define variable v-grp           as character    no-undo .
    define variable v-grp-recid     as recid        no-undo.
{ ref/extclass.i }
{ cmp/str-glbl.i }
{ gbl/key-rec.i }
{ gbl/getcntxt.i def }
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS btn_save btn_cancel code_system code_goods 
&Scoped-Define DISPLAYED-OBJECTS code_system code_goods 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON btn_cancel AUTO-END-KEY 
     LABEL "Отменить" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .
     
     DEFINE BUTTON b-system 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .89.
     
     DEFINE BUTTON b-goods-grp 
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "" 
     SIZE 3 BY .89.

DEFINE BUTTON btn_save AUTO-GO 
     LABEL "Добавить" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE VARIABLE code_goods as  character FORMAT "X(256)":U 
     LABEL "Код группы товаров" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.
     
DEFINE VARIABLE name_goods as  character FORMAT "X(256)":U 
    LABEL "Имя товара" 
     VIEW-AS FILL-IN 
     SIZE 25 BY 1 NO-UNDO.

DEFINE VARIABLE code_system AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код внешней системы" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.
     
     
DEFINE VARIABLE code_vnesh AS CHARACTER FORMAT "X(256)":U 
     LABEL "Код группы товаров во внешней системе" 
     VIEW-AS FILL-IN 
     SIZE 20 BY 1 NO-UNDO.
     
     
    

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
   
    code_system AT ROW 5.5 COL 45 COLON-ALIGNED WIDGET-ID 2
    code_goods AT ROW 6.75 COL 45 COLON-ALIGNED WIDGET-ID 4
    code_vnesh at row 8 col 45 COLON-ALIGNED WIDGET-ID 6
    btn_save AT ROW 2 COL 2.5
    btn_cancel AT ROW 2 COL 59
    b-system AT ROW 5.5 COL 65 COLON-ALIGNED WIDGET-ID 8
    b-goods-grp AT ROW 6.75 COL 65 COLON-ALIGNED WIDGET-ID 10     
    name_goods at row 6.75 col 70 COLON-ALIGNED no-label
    SPACE(5.12) SKIP(3.53)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
    SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
    TITLE "Добавление записи в  справочник соответствий группы товаров ТН во ВС "
    DEFAULT-BUTTON btn_save CANCEL-BUTTON btn_cancel WIDGET-ID 100.


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

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Добавление записи */
    DO:
        APPLY "END-ERROR":U TO SELF.
    END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&Scoped-define SELF-NAME b-system
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-system Dialog-Frame
ON CHOOSE OF btn_save IN FRAME Dialog-Frame
    DO:
        assign code_vnesh
            code_goods
            code_system.
        
      
        v-value-character = code_vnesh.
        
      
            
        if code_system = "" then 
        do:
            message "Не введен код ВС" view-as alert-box.
            return no-apply.
        end.
     
  
        if code_goods = ""  then 
        do:
            message "Не введен код группы товаров" view-as alert-box.
            return no-apply.
        end.
           
        if code_vnesh = "" then 
        do:
            message "Не введен код группы товаров во ВС" view-as alert-box.
            return no-apply.
        end.
       
              
            do transaction on error undo, return no-apply:
            
                for first ub.gds-grp no-lock where ub.gds-grp.node-code = integer(code_goods)
                    :
  
               

                    find first buf_gds-grp no-lock
                        where recid( buf_gds-grp ) = recid(ub.gds-grp).
            

                    run gen-key-rec IN THIS-PROCEDURE ( input {&table_gds-grp} 
                        ,input (buffer buf_gds-grp:handle)
                        ,output v-uniq-key-rec).
 

                    run ref/extclas1.p ( 
                        INPUT {&add-def}
                        ,INPUT NO /*p-silent*/
                        ,INPUT-OUTPUT v-rid
                        ,INPUT {&table_gds-grp} /*p-classif-subject*/
                        ,INPUT {&extclass_gds-grp} /*p-classif-name*/
                        ,input 0  /*p-db-num*/
                        ,input buf_gds-grp.node-code  /*p-key#_one*/
                        ,input code_system /*p-Key#_Two*/
                        ,input 0 /*p-key#_Three*/
                        ,input v-value-character  /*p-CharKey_One */
                        ,input '':U /*p-CharKey_two */
                        ,input buf_gds-grp.node-name /*p-CharKey_three */
                        ,input 0 /*p-nonunique */
                        ,input v-uniq-key-rec ) no-error.

                    if error-status:error then
                    do:
                        if error-status:get-message(1) = "" then
                            message "Ошибка добавления записи в справочник!" view-as alert-box .
                        else
                            message error-status:get-message(1) view-as alert-box .
                        undo, return no-apply .
                    end.
                /*             */
                end.
            /*        */
            end.
    
     
    end.
     /* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-system
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL name_goods Dialog-Frame
on leave of name_goods in frame dialog-frame 
    do:
        assign code_goods.
        
       
        if code_goods = "" then  return no-apply.
    
        find first gds-grp where gds-grp.node-code = integer(code_goods) no-error.
        
        if  error-status:error then
        do:    
       
            message "Неправильно введен код группы товаров" view-as alert-box.
         return no-apply.
        end.
        else 
        do:
        
            p-name-goods = gds-grp.node-name.
            name_goods:screen-value = p-name-goods.
        end.
       
       
    end.


     /* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-system
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-system Dialog-Frame
ON CHOOSE OF b-system IN FRAME Dialog-Frame
    DO:
    

        run bge/oxmlexts.p (
            input parparentproc,
            input 2,
            input substitute("esys-type > &1", {&openxml-type-ordinal}),
            input "",
            output v-rid-list,
            output v-ok).
        if v-rid-list = "" or v-ok <> true then message "Не была выбрана внешняя система." view-as alert-box.
    
        if v-ok = true then 
        do:
            run gen-row-keyr in this-procedure
                ( input v-rid-list
                ,input ?
                ,input "ub"
                ,input ?
                ,input no-lock
                ,output v-tbl-row
                ,output v-tbl-name
                ).
          
            find first buf_ext-system no-lock where
                rowid(buf_ext-system) = v-tbl-row.
        end.
        else 
        do:
            undo, return no-apply .
        end.
    
        code_system:screen-value =  entry(2,v-rid-list,{&delim-key}) no-error.

    /*        code_system = v-rid-list no-error.*/
    end.  
     /* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
  
&Scoped-define SELF-NAME b-goods-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-goods-grp Dialog-Frame
ON CHOOSE OF b-goods-grp IN FRAME Dialog-Frame
    DO:
        assign code_goods .
    
         run ref/gds-grp.w (
              input parparentproc
            , input "b-sel":U
            , input v-cntxt-obj-type
            , input v-cntxt-obj-code
            , input-output v-grp
        ).
        assign
            v-grp-recid = integer( v-grp )
        no-error.
       
            
            
        if error-status:error or v-grp = ? or v-grp = "" then 
        do:
            message "Ошибка при выборе товара для добавления в справочник." view-as alert-box.
            return no-apply.
        end.
        v-ok = false.
        
            find first buf_gds-grp no-lock
                 where recid( buf_gds-grp ) = v-grp-recid
            .
                   code_goods:screen-value = string(buf_gds-grp.node-code) no-error.
        
        apply "leave" to name_goods.
               
            
        end.
     
        
  
    /* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME b-goods-grp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL code_goods Dialog-Frame
on leave of code_goods in frame dialog-frame
    do:
 
        apply "leave" to name_goods.
     
       
         
    end.
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
  DISPLAY code_system code_goods b-system b-goods-grp code_vnesh name_goods
      WITH FRAME Dialog-Frame.
  ENABLE btn_save btn_cancel code_system code_goods b-system b-goods-grp code_vnesh 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

