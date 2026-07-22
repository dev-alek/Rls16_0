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

Информация по секциям автоцистерн


Автор: Кривошеин Александр
Дата создания: 14/07/10
Author: Mikhail Pervakov
Creation date: 14/07/10

Автор2: Морозова Александр
Дата создания: 09/11/20
Author: Alexandr Morozov
Creation date: 09/11/20

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input parameter parmode as character no-undo.
define input-output parameter parnum-tank as CHARACTER no-undo.
define input parameter partype-AC  as integer   no-undo .
define input parameter parsec-qnty  as decimal   no-undo .
define input parameter par-neck  as integer   no-undo .
define input parameter parsec-num as integer no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Измерение по резервуару".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }

define buffer buf_auto-tank for auto-tank.
define variable jj        as integer   no-undo .
define variable v-section as character no-undo  .


define temp-table tt-section no-undo 
    field dif     as integer
    field volume1 as decimal
    index pi dif
    .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME BROWSE-2

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-section

/* Definitions for BROWSE BROWSE-2                                      */
&Scoped-define FIELDS-IN-QUERY-BROWSE-2 tt-section.dif ~
tt-section.volume1 tt-section.volume2 
&Scoped-define ENABLED-FIELDS-IN-QUERY-BROWSE-2 tt-section.volume1 ~
tt-section.volume2 
&Scoped-define ENABLED-TABLES-IN-QUERY-BROWSE-2 tt-section
&Scoped-define FIRST-ENABLED-TABLE-IN-QUERY-BROWSE-2 tt-section
&Scoped-define QUERY-STRING-BROWSE-2 FOR EACH tt-section INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-BROWSE-2 OPEN QUERY BROWSE-2 FOR EACH tt-section INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-BROWSE-2 tt-section
&Scoped-define FIRST-TABLE-IN-QUERY-BROWSE-2 tt-section


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BROWSE-2}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-cancel b-help F-dop-volume BROWSE-2 
&Scoped-Define DISPLAYED-OBJECTS varsec-num varsec-qnty F-dop-volume 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
define button b-cancel auto-end-key 
    label "&Отмена" 
    size 10 by 1
    bgcolor 8 .

define button b-help 
     label "Помо&щь" 
     size 10 by 1
     bgcolor 8 .

define button b-save auto-go 
    label "&Ввод" 
    size 10 by 1
    bgcolor 8 .

define variable ellipse-depth      as decimal format ">>,>>9.999" 
    label "Толщина стенки горловины, мм" 
    view-as fill-in 
    size 15 by 1 no-undo.

define variable ellipse-max        as decimal format ">>,>>9.999" 
    label "Диаметр горловины большой оси эллипса, мм" 
    view-as fill-in 
    size 15 by 1 no-undo.

define variable ellipse-min        as decimal format ">>,>>9.999" 
    label "Диаметр горловины малой оси эллипса, мм" 
    view-as fill-in 
    size 15 by 1 no-undo.

define variable F-dop-volume       as decimal   format ">>,>>9.999":U initial 0 
    label "Доп.объем трубопровода нижнего налива,л" 
    view-as fill-in 
    size 15 by 1 no-undo.

define variable square-depth       as decimal format ">>,>>9.999" 
    label "Толщина стенки горловины, мм" 
    view-as fill-in 
    size 15 by 1 no-undo.

define variable square-lenght      as decimal format ">>,>>9.999" 
    label "Длина горловины, мм" 
    view-as fill-in 
    size 15 by 1 no-undo.

define variable square-width       as decimal format ">>,>>9.999" 
    label "Ширина горловины, мм" 
    view-as fill-in 
    size 15 by 1 no-undo.

define variable varsec-diam-in     as decimal format ">>,>>9.999" 
    label "Внутренний диаметр горловины, мм" 
    view-as fill-in 
    size 15 by 1 no-undo.

define variable varsec-diam-out    as decimal format ">>,>>9.999" 
    label "Внешний диаметр горловины, мм" 
    view-as fill-in 
    size 15 by 1 no-undo.

define variable varsec-diam-depth  as decimal format ">>,>>9.999" 
    label "Толщина стенки горловины, мм" 
    view-as fill-in 
    size 15 by 1 no-undo.

define variable varsec-diam-lenght as decimal format ">>,>>9.999" 
    label "Длина внешней окружности горловины, мм" 
    view-as fill-in 
    size 15 by 1 no-undo.

define variable varsec-num         as integer   format ">,>>>,>>9" initial 0 
    label "Номер секции" 
    view-as fill-in 
    size 15 by 1 no-undo.

define variable varsec-qnty        as decimal   format ">>>,>>>,>>9.999" initial 0 
    label "Вместимость, л" 
    view-as fill-in 
    size 15 by 1 no-undo.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
define query BROWSE-2 for 
    tt-section scrolling.
&ANALYZE-RESUME

/* Browse definitions                                                   */
define browse BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BROWSE-2 Dialog-Frame _STRUCTURED
    query BROWSE-2 display
    tt-section.dif column-label "Отклонение,см" format "->9.9":U width 15
    tt-section.volume1 column-label "Объем!для указанного!отклонения от планки,л" format "->>,>>9.99":U
  ENABLE
      tt-section.volume1
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 58 BY 7.75 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

define frame Dialog-Frame
    b-save at row 1 col 1 widget-id 2
    b-cancel at row 1 col 11 widget-id 4
    b-help at row 1 col 21 widget-id 6
    varsec-num at row 2.25 col 42.5 colon-aligned widget-id 8
    varsec-qnty at row 3.5 col 42.5 colon-aligned widget-id 10
    F-dop-volume at row 4.75 col 42.5 colon-aligned widget-id 18
    BROWSE-2 at row 6 col 1.5 widget-id 100
    varsec-diam-in at row 6 col 42.5 colon-aligned widget-id 16
    varsec-diam-out at row 7.25 col 42.5 colon-aligned widget-id 38
    varsec-diam-depth at row 8.5 col 42.5 colon-aligned widget-id 40
    varsec-diam-lenght at row 9.75 col 42.5 colon-aligned widget-id 42
    square-lenght at row 6 col 42.5 colon-aligned widget-id 26
    ellipse-max at row 6 col 42.5 colon-aligned widget-id 32
    square-width at row 7.25 col 42.5 colon-aligned widget-id 28
    ellipse-min at row 7.25 col 42.5 colon-aligned widget-id 34
    square-depth at row 8.5 col 42.5 colon-aligned widget-id 30
    ellipse-depth at row 8.5 col 42.5 colon-aligned widget-id 36
    space(1.12) skip(4.87)
    with view-as dialog-box keep-tab-order 
         side-labels no-underline three-d  scrollable 
         title "Данные по секции"
         default-button b-save cancel-button b-cancel.


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
/* BROWSE-TAB BROWSE-2 F-dop-volume Dialog-Frame */
assign 
       frame Dialog-Frame:SCROLLABLE       = false
       frame Dialog-Frame:HIDDEN           = true.

/* SETTINGS FOR BUTTON b-save IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN ellipse-depth IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN ellipse-max IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN ellipse-min IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN square-depth IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN square-lenght IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN square-width IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
/* SETTINGS FOR FILL-IN varsec-num IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varsec-qnty IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
on window-close of frame Dialog-Frame /* Данные по секции */
do:
        apply "END-ERROR":U to self.
    end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
on choose of b-save in frame Dialog-Frame /* Ввод */
do:
        define variable ii as integer no-undo .
        define buffer tt-section for tt-section.  
        if input frame {&frame-name} varsec-num <= 0 then 
        do:
            message "Номер секции указан неверно." view-as alert-box error.
            return no-apply.
        end.
        
   if ((par-neck = 0 and partype-AC = 1) or
       
      (par-neck = 0 and partype-AC = 2) or
        
      (par-neck = 1 and 
      input frame {&frame-name} square-depth <> '' and 
      input frame {&frame-name} square-lenght <> '' and 
      input frame {&frame-name} square-width <> '') or
        
      (par-neck = 2 and 
      input frame {&frame-name} ellipse-min <> '' and 
      input frame {&frame-name} ellipse-max <> '' and 
      input frame {&frame-name} ellipse-depth <> '') or
        
      (par-neck = 3 and 
      input frame {&frame-name} varsec-diam-depth <> '' and 
      input frame {&frame-name} varsec-diam-in <> '' and 
      input frame {&frame-name} varsec-diam-lenght <> '' and
      input frame {&frame-name} varsec-diam-out <> '')) and 
      (parmode = {&add-def} or parmode = {&update}) then 
   do:

      if par-neck = 2 then 
      do:
        parnum-tank = string(input frame {&frame-name} F-dop-volume) + {&delim-par} +
          STRING(input frame {&frame-name} ellipse-depth) + {&delim-par} +
          STRING(input frame {&frame-name} ellipse-min) + {&delim-par} +
          STRING(input frame {&frame-name} ellipse-max).
      end.      
      if par-neck = 1 then 
      do:
        parnum-tank = string(input frame {&frame-name} F-dop-volume) + {&delim-par} +
          STRING(input frame {&frame-name} square-depth) + {&delim-par} +
          STRING(input frame {&frame-name} square-lenght) + {&delim-par} +
          STRING(input frame {&frame-name} square-width).
      end.                       
      if par-neck = 3 then 
      do:
        parnum-tank = string(input frame {&frame-name} F-dop-volume) + {&delim-par} +
          STRING(input frame {&frame-name} varsec-diam-in) + {&delim-par} +
          STRING(input frame {&frame-name} varsec-diam-out) + {&delim-par} +
          STRING(input frame {&frame-name} varsec-diam-lenght) + {&delim-par} +
          STRING(input frame {&frame-name} varsec-diam-depth) .
      end.
      if par-neck = 0 then 
      do:
        parnum-tank = string(input frame {&frame-name} F-dop-volume).
        if partype-AC = 1 then 
        do:
          do ii = -10 to 10:
            for each tt-section where tt-section.dif = ii:    
              parnum-tank = parnum-tank + {&delim-par} + 
                string(ii) + {&delim-cmd} + string(tt-section.volume1) .
            end.
          end.
        end.
      end.   
    end.
    else 
    do :
      message "Введите данные!" view-as alert-box.
      return no-apply.
    end.    
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 Dialog-Frame
on value-changed of BROWSE-2 in frame Dialog-Frame
do:
   if available (tt-section) then do:
   end.   
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME BROWSE-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL BROWSE-2 Dialog-Frame
on ENTER of BROWSE-2 in frame Dialog-Frame
anywhere
do:

end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME ellipse-depth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ellipse-depth Dialog-Frame
on leave of ellipse-depth in frame Dialog-Frame /* Толщина стенки горловины, мм */
do:
  assign ellipse-depth .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ellipse-max
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ellipse-max Dialog-Frame
on leave of ellipse-max in frame Dialog-Frame /* Диаметр горловины большой оси эллипса, мм */
do:
  assign ellipse-max .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME ellipse-min
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL ellipse-min Dialog-Frame
on leave of ellipse-min in frame Dialog-Frame /* Диаметр горловины малой оси эллипса, мм */
do:
  assign ellipse-min .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME F-dop-volume
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL F-dop-volume Dialog-Frame
on leave of F-dop-volume in frame Dialog-Frame /* Доп.объем трубопровода нижнего налива,л */
do:
  assign f-dop-volume .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME square-depth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL square-depth Dialog-Frame
on leave of square-depth in frame Dialog-Frame /* Толщина стенки горловины, мм */
do:
 assign square-depth .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME square-lenght
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL square-lenght Dialog-Frame
on leave of square-lenght in frame Dialog-Frame /* Длина горловины, мм */
do:
  assign square-lenght .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME square-width
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL square-width Dialog-Frame
on leave of square-width in frame Dialog-Frame /* Ширина горловины, мм */
do:
  assign square-width .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsec-diam-in
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsec-diam-in Dialog-Frame
on leave of varsec-diam-in in frame Dialog-Frame /* Диаметр горловины, мм */
do:
           if string(varsec-diam-in) <> varsec-diam-in:screen-value then 
        do:
            assign varsec-diam-out .
        end.
        if varsec-diam-in > varsec-diam-out then 
        do:
            message "Внутренний диаметр грловины должен быть меньше внешнего"
                view-as alert-box.
            return no-apply .       
        end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME varsec-diam-out
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsec-diam-out Dialog-Frame
on leave of varsec-diam-out in frame Dialog-Frame /* Диаметр горловины, мм */
do:
           if string(varsec-diam-out) <> varsec-diam-out:screen-value then 
        do:
            assign varsec-diam-out .
        end.
        if varsec-diam-in > varsec-diam-out then 
        do:
            message "Внутренний диаметр грловины должен быть меньше внешнего"
                view-as alert-box.
            return no-apply .       
        end.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME varsec-diam-depth
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsec-diam-depth Dialog-Frame
on leave of varsec-diam-depth in frame Dialog-Frame /* Диаметр горловины, мм */
do:
  assign varsec-diam-depth .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME varsec-diam-lenght
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsec-diam-lenght Dialog-Frame
on leave of varsec-diam-lenght in frame Dialog-Frame /* Диаметр горловины, мм */
do:
  assign varsec-diam-lenght .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsec-num
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsec-num Dialog-Frame
on leave of varsec-num in frame Dialog-Frame /* Номер секции */
do:
  assign varsec-num .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME varsec-qnty
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL varsec-qnty Dialog-Frame
on leave of varsec-qnty in frame Dialog-Frame /* Вместимость, л */
do:
  assign varsec-qnty .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
&Scoped-define BROWSE-NAME BROWSE-2
&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
    then frame {&FRAME-NAME}:PARENT = active-window.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
    on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
    define variable ii as integer no-undo .
  varsec-qnty = parsec-qnty.
  varsec-num = parsec-num.
  if par-neck = 2 then 
  do:
      F-dop-volume = decimal(entry(1, parnum-tank, {&delim-par}) ) no-error.
      ellipse-depth = decimal (entry(2, parnum-tank, {&delim-par})) no-error.
      ellipse-max = decimal (entry(3, parnum-tank, {&delim-par})) no-error.
      ellipse-min = decimal (entry(4, parnum-tank, {&delim-par})) no-error.
  end.      
  if par-neck = 1 then 
  do:
      F-dop-volume = decimal(entry(1, parnum-tank, {&delim-par}) ) no-error.
      square-depth = decimal (entry(2, parnum-tank, {&delim-par})) no-error.
      square-lenght = decimal (entry(3, parnum-tank, {&delim-par})) no-error.
      square-width = decimal (entry(4, parnum-tank, {&delim-par})) no-error.
  end.                       
  if par-neck = 3 then 
  do:
      F-dop-volume = decimal(entry(1, parnum-tank, {&delim-par}) ) no-error.
      varsec-diam-in = decimal (entry(2, parnum-tank, {&delim-par})) no-error.
      varsec-diam-out = decimal (entry(3, parnum-tank, {&delim-par})) no-error.
      varsec-diam-lenght = decimal (entry(4, parnum-tank, {&delim-par})) no-error.
      varsec-diam-depth = decimal (entry(5, parnum-tank, {&delim-par})) no-error.
  end.    
  if par-neck = 0 then 
  do:
      empty temp-table tt-section.
      F-dop-volume = decimal(entry(1, parnum-tank, {&delim-par}) ) no-error.
      if partype-AC = 1 then do:
      do ii = 2 to num-entries (parnum-tank,{&delim-par}):
          v-section = entry(ii, parnum-tank, {&delim-par}) .
          create tt-section .
          assign
              tt-section.dif     = integer(entry (1,v-section,{&delim-cmd})) no-error .  
              tt-section.volume1 = decimal(entry (2,v-section,{&delim-cmd})) no-error . 
              .
      end.
      if v-section = "" then do:
         do ii = -10 to 10: 
            if ii = 0 then next .
            create tt-section .
            assign
               tt-section.dif = ii
               .
      end.               
      end.   
      end. 
  end.                  


  run local-enable_UI.
  wait-for go of frame {&FRAME-NAME}.
end.
run disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
procedure disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  hide frame Dialog-Frame.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
procedure enable_UI :
    /*------------------------------------------------------------------------------
      Purpose:     ENABLE the User Interface
      Parameters:  <none>
      Notes:       Here we display/view/enable the widgets in the
                   user-interface.  In addition, OPEN all queries
                   associated with each FRAME and BROWSE.
                   These statements here are based on the "Other 
                   Settings" section of the widget Property Sheets.
    ------------------------------------------------------------------------------*/
    display varsec-num varsec-qnty F-dop-volume 
        with frame Dialog-Frame.
    enable b-cancel b-help F-dop-volume BROWSE-2 
        with frame Dialog-Frame.
    view frame Dialog-Frame.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-enable_UI Dialog-Frame 
procedure local-enable_UI :
/*------------------------------------------------------------------------------
      Purpose:     Override standard ADM method
      Notes:
    ------------------------------------------------------------------------------*/

    /* Code placed here will execute PRIOR to standard behavior. */

    /* Dispatch standard ADM method.                             */
    run enable_ui.
  
  if parmode = {&add-def} or
     parmode = {&update} then do:
     case par-neck:
         when 2 then do: /*Элиптическая*/
            enable
            ellipse-depth
            ellipse-max
            ellipse-min
            with frame {&frame-name} .
            display
            ellipse-depth
            ellipse-max
            ellipse-min
            with frame {&frame-name} .
            hide
            square-depth
            square-lenght
            square-width
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            BROWSE-2
            in frame {&frame-name} .
         end.    
         when 1 then do: /*Квадратная*/
            enable
            square-depth
            square-lenght
            square-width
            with frame {&frame-name} .
            display
            square-depth
            square-lenght
            square-width
            with frame {&frame-name} .            
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            BROWSE-2
            in frame {&frame-name} .         
         end.    
         when 3 then do: /*Круглая*/
            enable
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            with frame {&frame-name} .
            display
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            with frame {&frame-name} .            
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            square-depth
            square-lenght
            square-width
            BROWSE-2
            in frame {&frame-name} .           
         end.    
         when 0 then do: /*Без горловины*/
         if partype-AC = 1 then do:
            enable
            BROWSE-2
            with frame {&frame-name} .
            {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
         end.
         else do:
            hide
            BROWSE-2
            in frame {&frame-name} .            
         end.      
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            square-depth
            square-lenght
            square-width
            in frame {&frame-name} .    
         end.             
     end case .
     enable b-save with frame {&frame-name}.
     if partype-AC = 2 then do:
         hide 
             F-dop-volume
             ellipse-depth
             ellipse-max
             ellipse-min
             varsec-diam-in
             varsec-diam-out
             varsec-diam-depth
             varsec-diam-lenght
             square-depth
             square-lenght
             square-width
             BROWSE-2
             in frame {&frame-name} .
end.       
     else enable F-dop-volume with frame {&frame-name} .
  end.
  else do:
     case par-neck:
         when 2 then do: /*Элиптическая*/
            disable
            ellipse-depth
            ellipse-max
            ellipse-min
            with frame {&frame-name} .
            display
            ellipse-depth
            ellipse-max
            ellipse-min
            with frame {&frame-name} .
            hide
            square-depth
            square-lenght
            square-width
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            BROWSE-2
            in frame {&frame-name} .
         end.    
         when 1 then do: /*Квадратная*/
            disable
            square-depth
            square-lenght
            square-width
            with frame {&frame-name} .
            display
            square-depth
            square-lenght
            square-width
            with frame {&frame-name} .
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            BROWSE-2
            in frame {&frame-name} .         
         end.    
         when 3 then do: /*Круглая*/
            disable
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            with frame {&frame-name} .
            display
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            with frame {&frame-name} .            
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            square-depth
            square-lenght
            square-width
            BROWSE-2
            in frame {&frame-name} .           
         end.    
         when 0 then do: /*Без горловины*/
         if partype-AC = 1 then do:
            display
            BROWSE-2
            with frame {&frame-name} .
            {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}       
         end.
         else do:
            hide
            BROWSE-2
            in frame {&frame-name} .            
         end.      
            hide
            ellipse-depth
            ellipse-max
            ellipse-min
            varsec-diam-in
            varsec-diam-out
            varsec-diam-depth
            varsec-diam-lenght
            square-depth
            square-lenght
            square-width
            in frame {&frame-name} .    
         end.             
     end case .
     if partype-AC = 2 then hide F-dop-volume in frame {&frame-name} .
     else disable F-dop-volume with frame {&frame-name} .      
  end .
  disable varsec-num varsec-qnty with frame {&frame-name}.      
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

