block-level on error undo, throw.
&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
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



/*                                                     */
/* Parameters Definitions ---                                           */
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO.
{ cmp/gds-list.i gds-list def "new shared" }
{ gbl/getcntxt.i def }
{ cmp/obj-list.i new }
{ gbl/getcntxt.i get }
{ ref/gds-attr.i "interface" parparentproc }
{cmp/ththgdst.i}
{ cmp/str-glbl.i }
{rep/frmlib.i}

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: ":U .
define variable vss-author      as character no-undo init "$Author: SShalanin $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/coppy_tov.p $":U .
define variable vss-description as character no-undo init "Утилита".

{ cmp/vssrevis.i }

define variable   k-attr-15x80-value as char.
        define variable  k-attr-6x50-value as char.
     define variable   k-attr-8x50-value as char.
   define variable   k-sost-attr-value as char.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_quite BTN_tov Btn_cancel cb-cop cb-naz ~
tgl-ignr 
&Scoped-Define DISPLAYED-OBJECTS cb-cop cb-naz tgl-ignr 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_cancel AUTO-GO 
     LABEL "Отмена" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON Btn_quite AUTO-END-KEY 
     LABEL "Ввод" 
     SIZE 15 BY 1.13
     BGCOLOR 8 .

DEFINE BUTTON BTN_tov 
     LABEL "Список товаров" 
     SIZE 15 BY 1.13.

DEFINE VARIABLE cb-cop AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Состав (из доп. инфо)",         1,
                     "Текст поля СОСТАВ 8x50 (CAS_LP-16x)",         2,
                     "Текст поля СОСТАВ 15x80 (DIGI-SM)",         3,
                     "Текст поля СОСТАВ 6x50 (CAS_CL5000 CAS_CL5000J)",         4
     DROP-DOWN-LIST
     SIZE 35 BY 1
     FONT 0 NO-UNDO.

DEFINE VARIABLE cb-naz AS INTEGER FORMAT "->,>>>,>>9":U INITIAL 0 
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Состав (из доп. инфо)",         1,
                     "Текст поля СОСТАВ 8x50 (CAS_LP-16x",         2,
                     "Текст поля СОСТАВ 15x80 (DIGI-SM)",         3,
                     "Текст поля СОСТАВ 6x50 (CAS_CL5000 CAS_CL5000J)",        4
     DROP-DOWN-LIST
     SIZE 35 BY 1 NO-UNDO.

DEFINE VARIABLE tgl-ignr AS LOGICAL INITIAL no 
     LABEL "Игнорировать пустые записи в источнике" 
     VIEW-AS TOGGLE-BOX
     SIZE 47 BY .83 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_quite AT ROW 3.75 COL 5.5
     BTN_tov AT ROW 3.75 COL 30.5 WIDGET-ID 14
     Btn_cancel AT ROW 3.75 COL 55.5
     cb-cop AT ROW 8 COL 2 NO-LABEL WIDGET-ID 6
     cb-naz AT ROW 8 COL 36.5 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     tgl-ignr AT ROW 10 COL 8.5 WIDGET-ID 16
     "Источник копирования" VIEW-AS TEXT
          SIZE 21 BY 1.42 AT ROW 6.5 COL 3 WIDGET-ID 10
     "Назначение" VIEW-AS TEXT
          SIZE 21 BY 1.42 AT ROW 6.5 COL 39 WIDGET-ID 12
          FONT 0
     SPACE(21.24) SKIP(5.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Копирование состава товара"
         DEFAULT-BUTTON Btn_cancel CANCEL-BUTTON Btn_quite WIDGET-ID 100.


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

/* SETTINGS FOR COMBO-BOX cb-cop IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Копирование состава товара */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_cancel
&Scoped-define SELF-NAME Btn_quite
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_quite Dialog-Frame
ON choose OF Btn_quite IN FRAME Dialog-Frame /* Ввод */
do:
/*                    ------------*/
assign
tgl-ignr.

  run gds-cb-naz.

run gds-cb-attr. 
                 

 

                                  
                              
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BTN_tov
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BTN_tov Dialog-Frame
ON CHOOSE OF BTN_tov IN FRAME Dialog-Frame /* Список товаров */
DO:

  run str/gds-list.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code) .



END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-cop
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-cop Dialog-Frame
ON value-changed OF cb-cop IN FRAME Dialog-Frame
do:
                 
assign cb-cop.

    end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cb-naz
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cb-naz Dialog-Frame
ON value-changed OF cb-naz IN FRAME Dialog-Frame
do:
    
    assign cb-naz. 
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
  DISPLAY cb-cop cb-naz tgl-ignr 
      WITH FRAME Dialog-Frame.
  ENABLE Btn_quite BTN_tov Btn_cancel cb-cop cb-naz tgl-ignr 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

PROCEDURE gds-cb-attr :


     define variable v-value as char.
    
         define variable p-gds-code as integer.
define variable v-attr-code as character .
define variable v-attr-value as char.
define buffer buf_goods for goods.
      
 define variable  attr-15x80-value as char.
        define variable attr-6x50-value as char.
     define variable attr-8x50-value as char.
     define variable sost-attr-value as char.
/* define input parameter f-attr as logical.*/

     

 
 
 for each gds-list:
     p-gds-code = gds-list.gds-code.
     
  
  if cb-cop = 2 then do:
      
  run gds-attr-value in this-procedure (
          INPUT p-gds-code,
          INPUT {&attr-8x50},
          OUTPUT v-attr-value,
          OUTPUT v-value
          ).
 attr-8x50-value = replace(v-attr-value,  {&delim-par}, " " ).
/*     attr-8x50-value  = v-attr-value.*/
            end. 
      
     
      
      
         
     if cb-cop = 3 then do:

  run gds-attr-value in this-procedure (
          INPUT p-gds-code,
          INPUT {&attr-15x80},
          OUTPUT v-attr-value,
          OUTPUT v-value
          ).
          attr-15x80-value = replace(v-attr-value,   {&delim-par}, " "  ).

    
          end.
          
          if cb-cop = 4 then do:
              
 run gds-attr-value in this-procedure (
          INPUT p-gds-code,
          INPUT {&attr-6x50},
          OUTPUT v-attr-value,
          OUTPUT v-value
          ).
          attr-6x50-value = replace(v-attr-value,   {&delim-par}, " ").
    
end.


if cb-cop = 1 then do:
   
    find first buf_goods where buf_goods.gds-code = p-gds-code.
      sost-attr-value =   replace(buf_goods.struct, {&delim-par}, " ").


   end.


if  tgl-ignr = yes and cb-cop = 4 then do:
    if attr-6x50-value = " " then do:
        ''.
        end.

    else do:
run tgl-coppy  ( input p-gds-code,
                                    input attr-15x80-value,
                                    input attr-6x50-value ,
                                 input  attr-8x50-value ,
                                  input  sost-attr-value).
                                  end.
                                  
                                  end.
                                  
        if  tgl-ignr = yes and cb-cop = 2 then do:
    if attr-8x50-value = " " then do:
        ''.
        end.

    else do:
run tgl-coppy  ( input p-gds-code,
                                    input attr-15x80-value,
                                    input attr-6x50-value ,
                                 input  attr-8x50-value ,
                                  input  sost-attr-value).
            end.                         

        end.       
                                  
        if  tgl-ignr = yes and cb-cop = 3 then 
        do:
            if attr-15x80-value = " " then 
            do:
                ''.
            end.

            else 
            do:
                run tgl-coppy  ( input p-gds-code,
                    input attr-15x80-value,
                    input attr-6x50-value ,
                    input  attr-8x50-value ,
                    input  sost-attr-value).
            end.
             
        end.  
                                  
        if tgl-ignr = yes and cb-cop = 1 then 
        do:
            if sost-attr-value = " " then 
            do:
                ''.
            end.
            else 
            do:
                run tgl-coppy  ( input p-gds-code,
                    input attr-15x80-value,
                    input attr-6x50-value ,
                    input  attr-8x50-value ,
                    input  sost-attr-value).
            end. 
   
        end.
           
                                  
        if tgl-ignr = no then 
        do:
            run tgl-coppy  ( input p-gds-code,
                input attr-15x80-value,
                input attr-6x50-value ,
                input  attr-8x50-value ,
                input  sost-attr-value).
        end.
                                                            
                      
    end.
    
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE gds-cb-naz Dialog-Frame  _DEFAULT-ENABLE

procedure gds-cb-naz:

    define variable p-value      as char.

    define variable p-gds-code   as integer.

    define variable p-attr-value as char.
    define buffer buf_goods for goods.



    define variable v-attr-15x80-value as char.
    define variable v-attr-6x50-value  as char.
    define variable v-attr-8x50-value  as char.
    define variable v-sost-attr-value  as char.




    for each gds-list:
        p-gds-code = gds-list.gds-code.

        if cb-naz = 2 then 
        do:

            run gds-attr-value in this-procedure (
                INPUT p-gds-code,
                INPUT {&attr-8x50},
                OUTPUT p-attr-value,
                OUTPUT p-value
                ).


        end.

        if cb-naz = 3 then 
        do:

            run gds-attr-value in this-procedure (
                INPUT p-gds-code,
                INPUT {&attr-15x80},
                OUTPUT p-attr-value,
                OUTPUT p-value
                ).



        end.

        if cb-naz = 4 then 
        do:

            run gds-attr-value in this-procedure (
                INPUT p-gds-code,
                INPUT {&attr-6x50},
                OUTPUT p-attr-value,
                OUTPUT p-value
                ).
        end.

        if cb-naz = 1 then 
        do:

            find first buf_goods where buf_goods.gds-code = p-gds-code.
            v-sost-attr-value = buf_goods.struct.
        end.

    end.
end procedure.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE tgl-coppy Dialog-Frame  _DEFAULT-ENABLE
procedure tgl-coppy:
    DEFINE variable output-num-lines   AS integer NO-UNDO.
    define variable p-attr-15x80-value as char.
    define variable p-attr-6x50-value  as char.
    define variable p-attr-8x50-value  as char.
    define variable p-sost-attr-value  as char.
    
    
    
    define input parameter p-gds-code as integer.
    define input parameter attr-15x80-value as char.
    define input parameter attr-6x50-value as char.
    define input parameter attr-8x50-value as char.
    define input parameter sost-attr-value as char.
     
   
    define buffer buf_goods for goods.
    
 


    
    if cb-cop = 2 and cb-naz = 3 then 
    do:
        p-attr-8x50-value = Break-n-line
            ( INPUT attr-8x50-value
            ,INPUT right-trim(fill(string(80) + {&comma-char}, 15), {&comma-char})
            ,OUTPUT output-num-lines).
              
        run gds-attr-write in this-procedure (input p-gds-code,
            input {&attr-15x80},
            input p-attr-8x50-value ).
    end.

    if cb-cop = 2 and cb-naz = 4 then 
    do:
        p-attr-8x50-value = Break-n-line
            ( INPUT attr-8x50-value
            ,INPUT right-trim(fill(string(50) + {&comma-char}, 6), {&comma-char})
            ,OUTPUT output-num-lines).
        
        
        run gds-attr-write in this-procedure (input p-gds-code,
            input {&attr-6x50},
            input p-attr-8x50-value ).
    end.

    if cb-cop = 2 and cb-naz = 1 then 
    do:
        
        
        find first buf_goods where buf_goods.gds-code = p-gds-code.
        buf_goods.struct =  attr-8x50-value.
    end.
 


    if cb-cop = 3 and cb-naz = 4 then 
    do:
        p-attr-15x80-value = Break-n-line
            ( INPUT attr-15x80-value
            ,INPUT right-trim(fill(string(50) + {&comma-char}, 6), {&comma-char})
            ,OUTPUT output-num-lines).
       
        run gds-attr-write in this-procedure (input p-gds-code,
            input {&attr-6x50},
            input p-attr-15x80-value ).
    end.

 
    if cb-cop = 3 and cb-naz = 2 then 
    do:
        p-attr-15x80-value = Break-n-line
            ( INPUT attr-15x80-value
            ,INPUT right-trim(fill(string(50) + {&comma-char}, 8), {&comma-char})
            ,OUTPUT output-num-lines).
        
        
        run gds-attr-write in this-procedure (input p-gds-code,
            input {&attr-8x50},
            input  p-attr-15x80-value ).
    end.
     
     
    if cb-cop = 3 and cb-naz = 1 then 
    do:
        find first buf_goods where buf_goods.gds-code = p-gds-code.
        buf_goods.struct =  attr-15x80-value.
    end.





    if cb-cop = 4 and cb-naz = 2 then 
    do:
       
        p-attr-6x50-value = Break-n-line
            ( INPUT attr-6x50-value
            ,INPUT right-trim(fill(string(50) + {&comma-char}, 8), {&comma-char})
            ,OUTPUT output-num-lines).
              
        run gds-attr-write in this-procedure (input p-gds-code,
            input {&attr-8x50},
            input p-attr-6x50-value ).
    end.
   
    if cb-cop = 4 and cb-naz = 3 then 
    do:
        p-attr-6x50-value = Break-n-line
            ( INPUT attr-6x50-value
            ,INPUT right-trim(fill(string(80) + {&comma-char}, 15), {&comma-char})
            ,OUTPUT output-num-lines).
       
        run gds-attr-write in this-procedure (input p-gds-code,
            input {&attr-15x80},
            input p-attr-6x50-value ).
    end.
        
    if cb-cop = 4 and cb-naz = 1 then 
    do:
        find first buf_goods where buf_goods.gds-code = p-gds-code.
        buf_goods.struct =  attr-6x50-value.
    end.
        
        
   
   
   

    if cb-cop = 1 and cb-naz = 3 then 
    do:
        
        p-sost-attr-value = Break-n-line
            ( INPUT sost-attr-value
            ,INPUT right-trim(fill(string(80) + {&comma-char}, 15), {&comma-char})
            ,OUTPUT output-num-lines).

        run gds-attr-write in this-procedure (input p-gds-code,
            input {&attr-15x80},
            input p-sost-attr-value ).
    end.
          
          
    if cb-cop = 1 and cb-naz = 2 then 
    do: 
        p-sost-attr-value = Break-n-line
            ( INPUT sost-attr-value
            ,INPUT right-trim(fill(string(50) + {&comma-char}, 8), {&comma-char})
            ,OUTPUT output-num-lines).

        run gds-attr-write in this-procedure (input p-gds-code,
            input {&attr-8x50},
            input p-sost-attr-value ).
    end.
          
          
    if cb-cop = 1 and cb-naz = 4 then 
    do:

        p-sost-attr-value = Break-n-line
            ( INPUT sost-attr-value
            ,INPUT right-trim(fill(string(50) + {&comma-char}, 6), {&comma-char})
            ,OUTPUT output-num-lines).
              
        run gds-attr-write in this-procedure (input p-gds-code,
            input {&attr-6x50},
            input p-sost-attr-value ).
    end.
          
          


end procedure.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




