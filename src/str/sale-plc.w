&ANALYZE-SUSPEND _VERSION-NUMBER AB_v9r12 GUI
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

/* Parameters Definitions ---                                           */

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-gds-code like ub.goods.gds-code .
define input parameter p-b-code   like ub.bar-code.b-code .
define parameter buffer p-ink-doc for ub.inkas.
define output parameter p-to-reserv as logical no-undo .

/* Local Variable Definitions ---                                       */

define variable v-sum-chk-gds-doc-qnty as decimal no-undo.
define variable v-TOTAL-pl-gds-fact-qnty as decimal no-undo.
define variable v-TOTAL-rvs-stt-msr-qnty as decimal no-undo.
define variable v-TOTAL-chk-gds-doc-qnty as decimal no-undo.
define variable v-TOTAL-distrib-selling   as decimal no-undo. /* для сравнения с общим количеством по чекам при нажатии "ввод" */
define variable v-TOTAL-realize as decimal no-undo.
define variable v-tmp-dec as decimal no-undo .
define variable v-order   as integer no-undo.
define variable v-cur-row as rowid no-undo.
define variable v-rvs-rec as recid no-undo.


/* Temp-Table and Buffer definitions                                    */

define temp-table tt-places
    field pump-code         like ub.pl-pump.pump-code
    field pl-code           like ub.place.pl-code
    field pl-name           like ub.place.pl-name
    field loc1              like ub.place.loc1
    field pl-gds-fact-qnty  like ub.pl-gds.fact-qnty
    field chk-gds-doc-qnty  like ub.chk-gds.doc-qnty
    field rvs-stt-msr-qnty  like ub.rvs-line.state-measure-qnty  
    field distrib-selling   as   decimal
    field order             as   integer
    index pi as primary unique
        pl-code
    index order
        order    
.

define temp-table tt-pl-pump
    field pump-code          like ub.pl-pump.pump-code 
    field pl-gds-fact-qnty   as decimal 
    field rvs-stt-msr-qnty   as decimal 
    field chk-gds-doc-qnty   as decimal 
    index pi as primary unique
        pump-code
. 

define temp-table tt-chk-to-reload
    field doc-code like ub.chk-doc.doc-code  
    index pi as primary unique
        doc-code
. 

define temp-table tt-chk-gds-change-pl
    field doc-code      like ub.chk-gds.doc-code 
    field line-num      like ub.chk-gds.line-num  
    field new-pl-code   like ub.chk-gds.pl-code
    field new-loc1      like ub.chk-gds.loc1
    field new-loc2      like ub.chk-gds.loc2
    field new-loc3      like ub.chk-gds.loc3
    field new-loc4      like ub.chk-gds.loc4
    field order         as integer
    index pi as primary unique
        doc-code line-num
    index order
        order    
.                    

define buffer buf_rvs-doc for ub.rvs-doc .
define buffer buf_rvs-line for ub.rvs-line .
define buffer buf_place for ub.place .
define buffer buf_pl-gds for ub.pl-gds .
define buffer buf_pl-gds-pump for ub.pl-gds-pump .
define buffer buf_chk-gds for ub.chk-gds .
define buffer buf_chk-doc for ub.chk-doc .

DEFINE NEW SHARED BUFFER X_chk-doc FOR chk-doc.
DEFINE NEW SHARED QUERY QUERY-chk-doc FOR X_chk-doc SCROLLING.

define stream OutStr-html.

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ gbl/prn-lib.i  }
{ str/inkas-ps.i }
{ gbl/thbj-def.i }
{ gbl/waitfram.i }

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-save b-cancel b-print br-places b-sel-rvs

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-cancel AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-print
     IMAGE-UP FILE "cmp/b-print.bmp":U
     IMAGE-DOWN FILE "cmp/b-print.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/b-print.bmp":U 
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON b-save AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1.
     
DEFINE BUTTON b-rvs 
     LABEL "&Сверка :" 
     SIZE 10 BY 1.  
     
define variable txt-rvs as character format "X(18)"
     view-as text
     size 18 by 1
     fgcolor 4 no-undo.        

DEFINE BUTTON b-sel-rvs
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 2.88 BY 1.
/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-places FOR
      tt-places   SCROLLING.
&ANALYZE-RESUME

/* Browser Definitions ---                                           */
define browse br-places
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-places Dialog-Frame _FREEFORM
query br-places no-lock display
    tt-places.pl-code          COLUMN-LABEL "Скл.место" FORMAT "999999999":U
    tt-places.pl-name          COLUMN-LABEL "Наименование резервуара" FORMAT "X(25)"
    tt-places.loc1             COLUMN-LABEL "Номер!резервуара"  FORMAT "X(8)"
    tt-places.pl-gds-fact-qnty COLUMN-LABEL "Расчетно-книжный!остаток" FORMAT "->>,>>>,>>9.<<<":U
    tt-places.chk-gds-doc-qnty COLUMN-LABEL "Текущее распреде-!ление продажи" FORMAT "->>,>>>,>>9.<<<":U
    tt-places.rvs-stt-msr-qnty COLUMN-LABEL "Фактический остаток" FORMAT "->>,>>>,>>9.<<<":U
    tt-places.distrib-selling  COLUMN-LABEL " Распределение !реализации" FORMAT "->>,>>>,>>9.<<<":U
enable
    tt-places.distrib-selling
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 117 BY 8.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-save AT ROW 1 COL 1 WIDGET-ID 2
     b-cancel AT ROW 1 COL 11 WIDGET-ID 4
     b-print AT ROW 1 COL 114 WIDGET-ID 6
     b-rvs at row 2 col 1 widget-id 10
     txt-rvs at row 2 col 11 no-label  widget-id 12
     b-sel-rvs at row 2 col 29 widget-id 14
     br-places at row 3 col 1 widget-id 8
     SPACE(0.00) SKIP(0.1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Распределение продажи по местам хранения"
         CANCEL-BUTTON b-cancel WIDGET-ID 100.


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
                                                                        */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Распределение продажи по местам хранения */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-cancel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-cancel Dialog-Frame
ON CHOOSE OF b-cancel IN FRAME Dialog-Frame /* Отмена */
DO:
  
  return "cancell":U .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-print
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-print Dialog-Frame
ON CHOOSE OF b-print IN FRAME Dialog-Frame /* Печать */
DO:
    run PrintProc.  
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-save
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-save Dialog-Frame
ON CHOOSE OF b-save IN FRAME Dialog-Frame /* Печать */
DO:
    browse br-places:refresh ().
    for each tt-pl-pump no-lock :
        assign v-TOTAL-distrib-selling = 0.0 .
        for each tt-places  no-lock
           where tt-places.pump-code = tt-pl-pump.pump-code 
        :
            if tt-places.distrib-selling = ? then assign tt-places.distrib-selling = 0.0 .
            assign 
                v-TOTAL-distrib-selling = v-TOTAL-distrib-selling + tt-places.distrib-selling
            .
        end.
        if tt-pl-pump.chk-gds-doc-qnty <> v-TOTAL-distrib-selling then do :
            message "Распределение реализации не соответствует сумме по чекам (в разрезе ТРК)"  
                    view-as alert-box
            .
            return no-apply.
        end.                         
    end. 
    
    define variable v-CUR-chk-gds-qnty as decimal no-undo.
    define variable v-CUR-distrib as decimal no-undo.
    define variable v-CUR-tt-chk as integer no-undo init 0.
    
/* Определение чеков для перезакачки и строк чеков для смены резервуара */
    for each tt-pl-pump no-lock :
        assign
            v-CUR-distrib = 0.0
            v-CUR-chk-gds-qnty = 0.0
        .
        places :        
        for each tt-places  no-lock
           where tt-places.pump-code = tt-pl-pump.pump-code
           use-index order
           by order
            :      
                if tt-places.distrib-selling = 0 then next places . 
                assign v-CUR-distrib = v-CUR-distrib + tt-places.distrib-selling .
                for each tt-chk-gds-change-pl where tt-chk-gds-change-pl.order > v-CUR-tt-chk 
                    use-index order
                    by order
                :
                    find first buf_chk-gds no-lock
                         where buf_chk-gds.doc-code = tt-chk-gds-change-pl.doc-code
                           and buf_chk-gds.line-num = tt-chk-gds-change-pl.line-num .                                       
                    
                    if (v-CUR-chk-gds-qnty + buf_chk-gds.doc-qnty) >= v-CUR-distrib then do :
                        if ABS(v-CUR-distrib - v-CUR-chk-gds-qnty) <= 
                           ABS(v-CUR-distrib - v-CUR-chk-gds-qnty - buf_chk-gds.doc-qnty) then do :
                               assign v-CUR-tt-chk = tt-chk-gds-change-pl.order - 1 .
                               next places .
                        end.       
                        assign
                            v-CUR-tt-chk = tt-chk-gds-change-pl.order 
                            v-CUR-chk-gds-qnty = v-CUR-chk-gds-qnty + buf_chk-gds.doc-qnty
                        .
                        if buf_chk-gds.pl-code = tt-places.pl-code then do :
                            delete tt-chk-gds-change-pl .
                        end.
                        else do :
                            find first buf_place no-lock
                                 where buf_place.obj-type = p-ink-doc.obj-type
                                   and buf_place.obj-code = p-ink-doc.obj-code
                                   and buf_place.pl-code  = tt-places.pl-code .
                            assign
                                tt-chk-gds-change-pl.new-pl-code = buf_place.pl-code
                                tt-chk-gds-change-pl.new-loc1    = buf_place.loc1
                                tt-chk-gds-change-pl.new-loc2    = buf_place.loc2
                                tt-chk-gds-change-pl.new-loc3    = buf_place.loc3
                                tt-chk-gds-change-pl.new-loc4    = buf_place.loc4
                            .
                            find first tt-chk-to-reload where tt-chk-to-reload.doc-code = buf_chk-gds.doc-code no-error.
                            if not available tt-chk-to-reload then do:
                                create tt-chk-to-reload . 
                                assign tt-chk-to-reload.doc-code = buf_chk-gds.doc-code .
                            end.                         
                        end.
                        next places .
                    end. /*  if (v-CUR-chk-gds-qnty + buf_chk-gds.doc-qnty) >= v-CUR-distrib */
                    else do :
                        assign v-CUR-chk-gds-qnty = v-CUR-chk-gds-qnty + buf_chk-gds.doc-qnty .
                        if buf_chk-gds.pl-code = tt-places.pl-code then do :
                            delete tt-chk-gds-change-pl .
                        end.
                        else do :
                            find first buf_place no-lock
                                 where buf_place.obj-type = p-ink-doc.obj-type
                                   and buf_place.obj-code = p-ink-doc.obj-code
                                   and buf_place.pl-code  = tt-places.pl-code .
                            assign
                                tt-chk-gds-change-pl.new-pl-code = buf_place.pl-code
                                tt-chk-gds-change-pl.new-loc1    = buf_place.loc1
                                tt-chk-gds-change-pl.new-loc2    = buf_place.loc2
                                tt-chk-gds-change-pl.new-loc3    = buf_place.loc3
                                tt-chk-gds-change-pl.new-loc4    = buf_place.loc4
                            . 
                            find first tt-chk-to-reload where tt-chk-to-reload.doc-code = buf_chk-gds.doc-code no-error.
                            if not available tt-chk-to-reload then do:
                                create tt-chk-to-reload . 
                                assign tt-chk-to-reload.doc-code = buf_chk-gds.doc-code .
                            end.                         
                        end.  
                    end.     
                end.    /* for each tt-chk-gds-change-pl where tt-chk-gds-change-pl.order > v-CUR-tt-chk */
                 
        end.      /* places */           
    end.  /*  for each tt-pl-pump no-lock   */
 /* КОНЕЦ Определение чеков для перезакачки и строк чеков для смены резервуара */   
    
    if can-find(first tt-chk-gds-change-pl) and can-find(first tt-chk-to-reload)
    then do :
        run waitfram-show in this-procedure ( input "Ждите... " ) .        
        run MainProc .        
        run waitfram-hide in this-procedure .
    end.    
    else do :
        message "Нет строк чеков для смены в них резервуара!" view-as alert-box . 
        return "cancell":U .  
    end.            
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-rvs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-rvs Dialog-Frame
ON CHOOSE OF b-rvs IN FRAME Dialog-Frame /* Сверка */
DO:
    assign v-rvs-rec = recid( buf_rvs-doc ).
    run str/rvs-doc.w
      ( input        parparentproc 
       ,input        {&lookup}
       ,input        buf_rvs-doc.rvs-type
       ,input        no
       ,input-output v-rvs-rec
      ) no-error.
    if error-status :error then do:
      return no-apply.
    end. 
       
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-sel-rvs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-rvs Dialog-Frame
ON CHOOSE OF b-sel-rvs IN FRAME Dialog-Frame /* выбор сверки */
DO:
    run str/all-rvs.w (input parparentproc, input "choose-control", input ?, output v-rvs-rec). 
    find first buf_rvs-doc no-lock where recid(buf_rvs-doc) = v-rvs-rec no-error.
    if available buf_rvs-doc then do :
        run upd-rvs-stt-msr-qnty.
        run calc-distrib-selling. 
        run disp-rvs. 
        open query br-places for each tt-places.
        APPLY "ENTRY" to br-places.    
    end.             
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

on value-changed of br-places in frame Dialog-Frame
do:
    assign
        v-cur-row = rowid(tt-places)              
    .
    for first tt-pl-pump no-lock where tt-pl-pump.pump-code = tt-places.pump-code :
        assign
            v-TOTAL-realize = tt-pl-pump.chk-gds-doc-qnty
            v-tmp-dec = 0.0
        . 
        for each tt-places no-lock where tt-places.pump-code = tt-pl-pump.pump-code :
            if rowid(tt-places) <> v-cur-row then 
                assign v-TOTAL-realize = v-Total-realize - (if tt-places.distrib-selling <> ? then tt-places.distrib-selling else 0) .
        end.
        find first tt-places exclusive-lock where rowid(tt-places) = v-cur-row.
        assign tt-places.distrib-selling = v-TOTAL-realize.
    end.
    
    browse br-places:refresh ().
    open query br-places for each tt-places.
    reposition br-places to rowid v-cur-row.
    APPLY "ENTRY" to br-places.       
end.

on leave of tt-places.distrib-selling in browse br-places
do:
    for first tt-pl-pump no-lock where tt-pl-pump.pump-code = tt-places.pump-code :
        assign tt-places.distrib-selling = if decimal(tt-places.distrib-selling:screen-value in browse br-places) = ?
                                           then tt-places.chk-gds-doc-qnty
                                           else if decimal(tt-places.distrib-selling:screen-value in browse br-places) <= tt-pl-pump.chk-gds-doc-qnty
                                           then decimal(tt-places.distrib-selling:screen-value in browse br-places)
                                           else tt-pl-pump.chk-gds-doc-qnty .
    end.                                       
    browse br-places:refresh ().
end.


   
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
  { gbl/hot-key.i b-print }
  run find-rvs.
  run fill-tt.
  run upd-rvs-stt-msr-qnty.
  run calc-distrib-selling. 
  run disp-rvs.

  RUN enable_UI.
  
  open query br-places for each tt-places.
  
  APPLY "ENTRY" to br-places.
  
    
          
  WAIT-FOR GO OF FRAME {&FRAME-NAME} .
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

Procedure find-rvs:
    for each buf_rvs-doc no-lock
       where buf_rvs-doc.obj-type   = p-ink-doc.obj-type
         and buf_rvs-doc.obj-code   = p-ink-doc.obj-code
         and buf_rvs-doc.shift-date = p-ink-doc.shift-date
         and buf_rvs-doc.shift-num  = p-ink-doc.shift-num
         and buf_rvs-doc.status_    = {&fact}
         and buf_rvs-doc.rvs-type   = {&rvs-control}          
         use-index shift-type 
         by buf_rvs-doc.fact-order descending
         :
             find first buf_rvs-line no-lock
                  where buf_rvs-line.gds-code = p-gds-code
                    and buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                    and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                    and buf_rvs-line.obj-code = buf_rvs-doc.obj-code no-error. 
             if not available buf_rvs-line then next.
             else leave.                         
    end. 
    if not available buf_rvs-line then do :
        message "      Для данного топлива не было контрольной сверки в этой смене.
                 Выберите другую сверку или заполните данные по распределению вручную." 
                 view-as alert-box.  
    end.                  
    
end procedure. /* find-rvs */

Procedure disp-rvs :
    if available buf_rvs-doc then do : 
        display (" № " + buf_rvs-doc.rvs-code) @ txt-rvs with frame {&frame-name}.
        enable b-rvs with frame {&frame-name}.  
    end.     
end procedure.  /* disp-rvs */       

Procedure fill-tt:
                
    assign
        v-TOTAL-pl-gds-fact-qnty = 0.0        
        v-TOTAL-chk-gds-doc-qnty = 0.0 
        v-order = 0   
    .
    
    for each buf_pl-gds no-lock
       where buf_pl-gds.gds-code = p-gds-code
         and buf_pl-gds.obj-type = p-ink-doc.obj-type
         and buf_pl-gds.obj-code = p-ink-doc.obj-code         
        ,
       first buf_place no-lock
       where buf_place.obj-type = buf_pl-gds.obj-type
         and buf_place.obj-code = buf_pl-gds.obj-code
         and buf_place.pl-code  = buf_pl-gds.pl-code
        ,
       first buf_pl-gds-pump no-lock
       where buf_pl-gds-pump.obj-type = buf_pl-gds.obj-type
         and buf_pl-gds-pump.obj-code = buf_pl-gds.obj-code
         and buf_pl-gds-pump.pl-code  = buf_pl-gds.pl-code 
         and buf_pl-gds-pump.gds-code = buf_pl-gds.gds-code
         :    
             find first tt-pl-pump where tt-pl-pump.pump-code = buf_pl-gds-pump.pump-code no-error.
             if not available tt-pl-pump then do :
                 create tt-pl-pump no-error.
                 assign tt-pl-pump.pump-code = buf_pl-gds-pump.pump-code.
             end.    
                                                 
             assign v-sum-chk-gds-doc-qnty = 0.0 .
                                      
             for each buf_chk-gds no-lock
                where buf_chk-gds.b-code   = p-b-code
                  and buf_chk-gds.pl-code  = buf_pl-gds.pl-code 
                  and buf_chk-gds.out-code = p-ink-doc.inkas-code
                  :
                      assign 
                        v-sum-chk-gds-doc-qnty = v-sum-chk-gds-doc-qnty + buf_chk-gds.doc-qnty
                        v-TOTAL-chk-gds-doc-qnty = v-TOTAL-chk-gds-doc-qnty + buf_chk-gds.doc-qnty
                        tt-pl-pump.chk-gds-doc-qnty = tt-pl-pump.chk-gds-doc-qnty + buf_chk-gds.doc-qnty
                      .
                      assign v-order = v-order + 1 .
                      create tt-chk-gds-change-pl .
                      assign tt-chk-gds-change-pl.doc-code    = buf_chk-gds.doc-code
                             tt-chk-gds-change-pl.line-num    = buf_chk-gds.line-num
                             tt-chk-gds-change-pl.order       = v-order
                      .                       
             end.  /* for each buf_chk-gds */
             
             create tt-places no-error.
             assign tt-places.pump-code = buf_pl-gds-pump.pump-code
                    tt-places.pl-code   = buf_place.pl-code
                    tt-places.pl-name   = buf_place.pl-name
                    tt-places.loc1      = buf_place.loc1
                    tt-places.pl-gds-fact-qnty = buf_pl-gds.fact-qnty
                    tt-places.chk-gds-doc-qnty = v-sum-chk-gds-doc-qnty 
                    tt-places.order     = if buf_pl-gds-pump.status_ = {&current-status} then 1 else 2                                       
             .             
             assign
                v-TOTAL-pl-gds-fact-qnty = v-TOTAL-pl-gds-fact-qnty + tt-places.pl-gds-fact-qnty
                tt-pl-pump.pl-gds-fact-qnty = tt-pl-pump.pl-gds-fact-qnty + tt-places.pl-gds-fact-qnty
             .  
             release tt-places no-error.         
    end. /* for each buf_pl-gds, first buf_place */
    
End procedure. /* fill-tt */ 

Procedure upd-rvs-stt-msr-qnty :
    if available buf_rvs-doc then do :
        assign 
            v-TOTAL-rvs-stt-msr-qnty = 0.0              
        .
        for each tt-pl-pump exclusive-lock :
            assign tt-pl-pump.rvs-stt-msr-qnty = 0.0 .  
            for each tt-places exclusive-lock where tt-places.pump-code = tt-pl-pump.pump-code  :
               assign tt-places.rvs-stt-msr-qnty = 0.0 .
               find first buf_rvs-line no-lock
                    where buf_rvs-line.gds-code = p-gds-code
                      and buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                      and buf_rvs-line.obj-type = buf_rvs-doc.obj-type
                      and buf_rvs-line.obj-code = buf_rvs-doc.obj-code         
                      and buf_rvs-line.pl-code  = tt-places.pl-code no-error.
               if available buf_rvs-line then
                   assign 
                       tt-places.rvs-stt-msr-qnty = buf_rvs-line.state-measure-qnty
                       v-TOTAL-rvs-stt-msr-qnty = v-TOTAL-rvs-stt-msr-qnty + buf_rvs-line.state-measure-qnty 
                       tt-pl-pump.rvs-stt-msr-qnty = tt-pl-pump.rvs-stt-msr-qnty + buf_rvs-line.state-measure-qnty
                   .
            end.
        end.            
    end.      
end procedure.   /* upd-rvs-stt-msr-qnty  */  

Procedure calc-distrib-selling :
    for each tt-pl-pump no-lock :
        v-tmp-dec = 0.0 .
        for each tt-places exclusive-lock where tt-places.pump-code = tt-pl-pump.pump-code :
            assign
                tt-places.distrib-selling = tt-places.pl-gds-fact-qnty - ((tt-places.rvs-stt-msr-qnty / tt-pl-pump.rvs-stt-msr-qnty) *
                                                                          (tt-pl-pump.pl-gds-fact-qnty - tt-pl-pump.chk-gds-doc-qnty))
                tt-places.distrib-selling = if tt-places.distrib-selling <> ?
                                            /*and abs(tt-places.distrib-selling) <= tt-places.chk-gds-doc-qnty*/ then tt-places.distrib-selling else tt-places.chk-gds-doc-qnty                                                          
            .   
            if tt-places.distrib-selling < 0 then v-tmp-dec = tt-places.distrib-selling .   
        end.  /*  for each tt-places */
        if v-tmp-dec <> 0.0 then
        for each tt-places exclusive-lock where tt-places.pump-code = tt-pl-pump.pump-code :
            assign
                tt-places.distrib-selling = abs(tt-places.distrib-selling) - v-tmp-dec
            .   
        end.  /*  for each tt-places */    
    end.     
end procedure. /* calc-distrib-selling */ 

PROCEDURE PrintProc :

    define var v-act-file as char no-undo.
    v-act-file  = session:temp-directory + {&DF_Name} +  "sale-plc1.html".

    run waitfram-show in this-procedure ( input "Ждите...").
    output stream OutStr-html to value(v-act-file) convert target 'UTF-8'/*no-convert*/.
    put stream OutStr-html unformatted
        substitute(

        '<!doctype html>
                 <html>
              <head>
              <meta charset="UTF-8">
                 <!-- Стили документа -->
              <style>
                table ~{border-collapse: collapse; ~}
                tbody td, th ~{border: 1px solid black;~}
                #myid ~{font-weight: bold;~}
                .class1 ~{font-style: italic;~}
                .class2 ~{font-family: Arial;~}
              </style>
              </head>
                  <body>
                  <table orientation="landscape" name="лист1" repeat_rows="1:1" hide_zero="True">
                  <thead>
                  <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                  <tr class="set_columns">
                        <td style="width:70px"></td>
                        <td style="width:210px"></td>
                        <td style="width:70px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                        <td style="width:110px"></td>
                  </tr>
                  <tr>
                        <td colspan="7" style="front-weight: bold; text-align: center;">Распределение топлива по местам хранения</td>
                  </tr>
        </thead>
            <tbody>
                <tr>
                <th>Складское место</th>
                <th>Наименование резервуара</th>
                <th>Номер резервуара</th>
                <th>Расчетно-книжный остаток</th>
                <th>Текущее распределение продажи</th>
                <th>Фактический остаток</th>
                <th>Распределение реализации</th>
                </tr>').

    get first br-places.
    do while available  tt-places:

        put stream OutStr-html unformatted
            substitute(
            '<tr style="height: 50px;">
             <td text_wrap="true"> &1 </td>
             <td text_wrap="true"> &2 </td>
             <td text_wrap="true"> &3 </td>
             <td text_wrap="true"> &4 </td>
             <td text_wrap="true"> &5 </td>
             <td text_wrap="true"> &6 </td>
             <td text_wrap="true"> &7 </td>
             </tr>
             </tbody>',

            tt-places.pl-code,
            tt-places.pl-name,
            tt-places.loc1,
            tt-places.pl-gds-fact-qnty,
            tt-places.chk-gds-doc-qnty,
            tt-places.rvs-stt-msr-qnty,
            tt-places.distrib-selling
            ).
        get next br-places.


    end.



    run waitfram-hide in this-procedure.

    output stream OutStr-html close.
    run prn-lib-reportviewer-report-name in this-procedure (
        input parParentProc
        ,input v-act-file
        ).



END PROCEDURE. 

Procedure MainProc :
    
    define  variable old-netto as decimal no-undo.
    define  variable old-tot-doc as decimal no-undo.
    define  variable old-discnt as decimal no-undo.
    define variable v-curr-r-b as character no-undo .    
    define buffer buf_sysconf for ub.sysconf.
    DEFINE                BUFFER ret-doc    FOR trn-doc.
    DEFINE                BUFFER r-doc      FOR chk-doc.
    DEFINE                BUFFER r-gds      FOR chk-gds.
    define variable v-ref-rec  as recid no-undo .
    define variable v-base-code  like ub.sysconf.base-code no-undo .
    define variable v-cash-pay   like ub.sysconf.cash-pay  no-undo .
    define variable temp-qnty like gds-dtl.fact-qnty no-undo .
    define variable temp-qnty-prts like gds-dtl.fact-qnty no-undo .
    define variable prev-code like chk-gds.doc-code no-undo .
    define variable for-shift-name AS character.
    define variable for-shift-num like chk-doc.shift-num.
    define variable for-shift-date like chk-doc.shift-date.
    /*использовать сервисные элементы для данного объекта*/
    define variable serv-elm as logical no-undo init no.
    /*использовать смены на кассе для данного объекта*/
    define variable cas-shft as logical no-undo init no.
    define variable one-sale-per-day as logical no-undo .
    /*использовать смены для данного объекта*/
    define variable l-shift-on as logical no-undo init no.
    /*в продажу закачивать чеки только по одному выбранному курсу*/
    define variable one-curs as logical no-undo init no.
    /*откуда были взяты курсы валют из спула или BO*/
    define variable cas-curs as logical no-undo init no.
    /*откуда брать цены в накладную - из чека или из прайс-листа*/
    define variable prcl-spl as logical no-undo init no.
    /*тип алгоритма для размаза*/
    define variable pay-gds-algo as character no-undo .
    /*код дорожного налога*/
    define variable rdtaxcd  as INTEGER                  no-undo.
    /*код акциза*/
    define variable exctaxcd  as INTEGER                  no-undo.
    /*фактор дор налога*/
    define variable factorrt as decimal no-undo.
    /*типы ед изм для дор нал*/
    /*код стеклопосуды*/
    define variable btltaxcd  as INTEGER                  no-undo.
    define variable conf-attr as char no-undo.                  /* для чтения параметра конфигурации */
    define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
    define variable par-type as char no-undo.
    define variable cursh like curr-shop.exch-rate init 0.
    define variable cursh-scale like curr-shop.exch-rate.
     
    define variable v-rid-list as character no-undo init "".
    define buffer buf_inkas for ub.inkas .
    
    define variable ps-where-rus as character no-undo .
    define variable v-param-type as character no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date as date no-undo .
    define variable v-value-decimal as decimal no-undo .
    define variable v-value-integer as INTEGER no-undo .
    define variable v-value-logical AS LOGICAL no-undo .
    define variable v-tth as handle no-undo .
    assign v-tth = buffer thbjattr_thbj-attr:table-handle .
    
    DEFINE VARIABLE gds-amount AS INTEGER INITIAL 0 NO-UNDO.
    DEFINE VARIABLE chk-amount AS INTEGER INITIAL 0 NO-UNDO.
    DEFINE VARIABLE dtl-out AS INTEGER INITIAL 0 NO-UNDO.    
    DEFINE VARIABLE dtl-ret AS INTEGER INITIAL 0 NO-UNDO.    
    DEFINE VARIABLE line-out AS INTEGER INITIAL 0 NO-UNDO.    
    DEFINE VARIABLE line-ret AS INTEGER INITIAL 0 NO-UNDO.    
    DEFINE VARIABLE nf-chk-amount AS INTEGER INITIAL 0 NO-UNDO.    
    DEFINE VARIABLE nf-gds-amount AS INTEGER INITIAL 0 NO-UNDO.
    
    define variable v-ii     as integer no-undo .
    define variable v-ii-ok  as integer no-undo .
    define variable v-rc-ii as integer no-undo .
    define variable v-rc-max as integer no-undo .
    define variable v-error-status as logical no-undo .
    define variable v-error-status-message as character no-undo .
    
    /* Собираем все параметры для перезакачки чеков */
    assign
        rdtaxcd  = integer({&road-tax-code})
        exctaxcd = integer({&excise-tax-code})
        btltaxcd = integer({&road-tax-code})
    .

    { gbl/curr-r-b.i
        v-curr-r-b
    }

    { gbl/conf-rd.i
    "'factorrt'"
    "''"
    "''"
    0
    "''"
    "''"
    "''"
    no
    conf-par
    par-type
    no-error
    }
    if NOT error-status:error then
    factorrt = decimal(conf-par).

    if rdtaxcd > 0 then do:
      FIND FIRST tax No-LOCK WHERE tax.tax-code = rdtaxcd No-ERROR.
      if not avail tax then do:
          message "Не найден дорожный налог!" view-as alert-box ERROR.
          return error.
      end.
    end.

    if exctaxcd > 0 then do:
      FIND FIRST tax No-LOCK WHERE tax.tax-code = exctaxcd No-ERROR.
      if not avail tax then do:
          message "Не найден акциз!" view-as alert-box ERROR.
          return error.
      end.
    end.

    if btltaxcd > 0 then do:
      FIND FIRST tax No-LOCK WHERE tax.tax-code = btltaxcd No-ERROR.
      if not avail tax then do:
          message "Не найден налог (доп.компонента для цены) стеклопосуды!" view-as alert-box ERROR.
          return error.
      end.
    end.

  /*найдем параметр - использовать цены сервисного элемента*/
    { gbl/conf-rd.i
    "'serv-elm'"
    p-ink-doc.host-code
    p-ink-doc.obj-type
    p-ink-doc.obj-code
    "''"
    "''"
    "''"
    no
    conf-par
    par-type
    no-error
    }
    IF not error-status:error then
    assign
    serv-elm = (conf-par = "yes").


    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.

    run adm/shattri.p (
      input "get":U
     ,input  p-ink-doc.obj-type
     ,input  p-ink-doc.obj-code
     ,input  {&attr-get-chk}
     ,input  "":U /*p-param-code*/
     , output v-value-character
     , output v-value-date
     , output v-value-decimal
     , output v-value-integer
     , output v-value-logical
     , output v-param-type
     , INPUT-OUTPUT table-handle v-tth
    ) no-error .

    IF error-status:error then do:
       message
       substitute("Ошибка при получении опций закачки чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
       , p-ink-doc.obj-type
       , p-ink-doc.obj-code
       , {&new-line}
       , error-status:get-message(1)
       , return-value )
       view-as alert-box error .
       undo, return error .
    end.
    
    find first thbjattr_thbj-attr where
               thbjattr_thbj-attr.obj-type = p-ink-doc.obj-type
           and thbjattr_thbj-attr.obj-code = p-ink-doc.obj-code
           and thbjattr_thbj-attr.upper-prop-code = {&attr-get-chk}
           and thbjattr_thbj-attr.prop-code = {&attr-get-chk_cas-shft} no-error.
    if available thbjattr_thbj-attr then do:
        /*найдем параметр - использовать смены на кассе или нет*/
        cas-shft = thbjattr_thbj-attr.property-value-logical.
    end.
    find first thbjattr_thbj-attr where
               thbjattr_thbj-attr.obj-type = p-ink-doc.obj-type
           and thbjattr_thbj-attr.obj-code = p-ink-doc.obj-code
           and thbjattr_thbj-attr.upper-prop-code = {&attr-get-chk}
           and thbjattr_thbj-attr.prop-code = {&attr-get-chk_cas-curs} no-error.
    if available thbjattr_thbj-attr then do:
        /*курс брать из чеков?*/
        cas-curs = thbjattr_thbj-attr.property-value-logical.
    end.
    { gbl/objat.i
      p-ink-doc.obj-type
      p-ink-doc.obj-code
      "'shift-on=request'"
      l-shift-on
    }

    if l-shift-on and not cas-shft then do:
            message "Внимание! На текущем объекте требуется использование смен" skip
         "а настройка СМЕНЫ НА КАССЕ ( cas-shft ) выключена - это недопустимо." skip (2)
              view-as alert-box ERROR.
      return ERROR.
    end.

  /*найдем параметр - чеки по одному выбранному курсу или нет*/
  /*найдем параметр - откуда брать цены на товар в накладную - из чека или из прайс-листа*/
  /*по умолчанию из чека*/
    run adm/shattri.p (
      input "get":U
      ,input  p-ink-doc.obj-type
      ,input  p-ink-doc.obj-code
      ,input  {&attr-autosale}
      ,input  "":U /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
    IF error-status:error then do:
       message
       substitute("Ошибка при получении опций работы с продажей НА ОБЪЕКТЕ &1&2:&3&4 &5"
       , p-ink-doc.obj-type
       , p-ink-doc.obj-code
       , {&new-line}
       , error-status:get-message(1)
       , return-value )
       view-as alert-box error .
       undo, return error .
    end.
    
    find first thbjattr_thbj-attr where
               thbjattr_thbj-attr.obj-type = p-ink-doc.obj-type
           and thbjattr_thbj-attr.obj-code = p-ink-doc.obj-code
           and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
           and thbjattr_thbj-attr.prop-code = {&attr-autosale_prcl-spl} no-error.
    if available thbjattr_thbj-attr then do:
        prcl-spl = thbjattr_thbj-attr.property-value-logical.
    end.
    find first thbjattr_thbj-attr where
               thbjattr_thbj-attr.obj-type = p-ink-doc.obj-type
           and thbjattr_thbj-attr.obj-code = p-ink-doc.obj-code
           and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
           and thbjattr_thbj-attr.prop-code = {&attr-autosale_one-curs} no-error.
    if available thbjattr_thbj-attr then do:
      /*курс брать из чеков?*/
      one-curs = thbjattr_thbj-attr.property-value-logical.
    end.
    find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-ink-doc.obj-type
        and thbjattr_thbj-attr.obj-code = p-ink-doc.obj-code
        and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
        and thbjattr_thbj-attr.prop-code = {&attr-autosale_one-sale-per-day} no-error.
    if available thbjattr_thbj-attr then do:
        assign
          one-sale-per-day = thbjattr_thbj-attr.property-value-logical
        .
    end.
    find first thbjattr_thbj-attr where
               thbjattr_thbj-attr.obj-type = p-ink-doc.obj-type
           and thbjattr_thbj-attr.obj-code = p-ink-doc.obj-code
           and thbjattr_thbj-attr.upper-prop-code = {&attr-autosale}
           and thbjattr_thbj-attr.prop-code = {&attr-autosale_pay-gds-algo} no-error.
    if available thbjattr_thbj-attr then do:
        assign
          pay-gds-algo = thbjattr_thbj-attr.property-value-character
        .
    end.
    
    find first buf_sysconf no-lock where buf_sysconf.host-code = p-ink-doc.host-code.
    { gbl/basecode.i p-ink-doc.host-code v-base-code }
    FIND FIRST shop WHERE shop.obj-code = p-ink-doc.obj-code NO-LOCK .
    FIND FIRST trn-doc no-lock WHERE trn-doc.doc-code = p-ink-doc.inkas-code.
    FIND FIRST ret-doc no-lock WHERE ret-doc.doc-code = trn-doc.out-code no-error .
    
    assign
        cursh = trn-doc.exch-rate
        cursh-scale = trn-doc.exch-scale
    .    
    run get-inkas-ps in this-procedure (
                                        buffer p-ink-doc
                                      , output chk-amount
                                      , output gds-amount
                                      , output line-out
                                      , output dtl-out
                                      , output line-ret
                                      , output dtl-ret
                                      , output nf-chk-amount
                                      , output nf-gds-amount
                                      , output ps-where-rus
                                      ).
    /* КОНЕЦ Собираем все параметры для перезакачки чеков */                                  
    
    
    
    /* ИСКЛЮЧЕНИЕ ЧЕКОВ ИЗ ПРОДАЖИ */    
    for each tt-chk-to-reload no-lock :
        find first buf_chk-doc where buf_chk-doc.doc-code = tt-chk-to-reload.doc-code .
        assign
           v-rid-list = v-rid-list + ( if v-rid-list = "":U then "":U else {&comma-char} ) + string(recid(buf_chk-doc))
        .
        FIND FIRST buf_inkas No-LOCK WHERE
                          buf_inkas.inkas-code = buf_chk-doc.out-code No-ERROR.
        assign
            old-netto = buf_inkas.netto
            old-tot-doc = buf_inkas.tot-doc
            old-discnt = buf_inkas.discnt
        .
        run str/excl-chk.p (
                             input parparentproc
                           , input v-curr-r-b
                           , buffer buf_chk-doc) no-error.
        if error-status:error OR
          buf_inkas.netto <> old-netto  - buf_chk-doc.netto OR
          buf_inkas.tot-doc <> old-tot-doc  - buf_chk-doc.tot-doc OR
          buf_inkas.discnt <> old-discnt - buf_chk-doc.discnt then do:
            message
            substitute("Исключение чека &1 из продажи &2 не удалось:&3&4 &5"
                     ,buf_chk-doc.doc-code
                     ,p-ink-doc.inkas-code
                     , {&new-line}
                     ,error-status:get-message(1)
                     ,return-value
                     )
            view-as alert-box ERROR.
            undo, NEXT.
        end.
    end.
    /* КОНЕЦ ИСКЛЮЧЕНИЕ ЧЕКОВ ИЗ ПРОДАЖИ */
    
     
    /* Замена резервуаров в строках чеков */
    for each tt-chk-gds-change-pl no-lock :
        find first buf_chk-gds exclusive-lock 
             where buf_chk-gds.doc-code = tt-chk-gds-change-pl.doc-code 
               and buf_chk-gds.line-num = tt-chk-gds-change-pl.line-num .
        assign
            buf_chk-gds.pl-code = tt-chk-gds-change-pl.new-pl-code
            buf_chk-gds.loc1    = tt-chk-gds-change-pl.new-loc1
            buf_chk-gds.loc2    = tt-chk-gds-change-pl.new-loc2
            buf_chk-gds.loc3    = tt-chk-gds-change-pl.new-loc3
            buf_chk-gds.loc4    = tt-chk-gds-change-pl.new-loc4
        . 
        release buf_chk-gds .      
    end.
    /* КОНЕЦ Замена резервуаров в строках чеков */ 
    
    
    /* Закачка чеков обратно в продажу */
    assign
        v-rc-max = num-entries(v-rid-list)
    .
    _v-rc:
    do while v-rc-ii < v-rc-max:
        assign
        v-rc-ii = v-rc-ii + 1
        .
        find first X_chk-doc exclusive-lock where
                  recid(X_chk-doc) = integer(entry(v-rc-ii, v-rid-list))  no-wait no-error.
        if locked X_chk-doc or not available X_chk-doc then do:
           next _v-rc.
        end.
        else leave _v-rc.
    end.
    if not available X_chk-doc
    or locked(X_chk-doc) then do:
        message
        "Ни один из чеков не может быть сейчас перезакачан в продажу" skip
        "Возможно они заняты другим пользователем"
        view-as alert-box Warning.
        return.
    end.
    run str/inc-salr.p (
                 input  parparentproc
                ,input  this-procedure
                ,input-output v-ii
                ,input-output v-ii-ok
                ,input  no
                ,input  ""
                ,INPUT  v-rid-list
                ,input  p-ink-doc.obj-type
                ,input  p-ink-doc.obj-code
                ,input  v-curr-r-b
                ,input  no
                ,input  cas-shft
                ,input  one-curs
                ,input  cas-curs
                ,input  cursh
                ,input  cursh-scale
                ,input  prcl-spl
                ,input  pay-gds-algo
                ,input  rdtaxcd
                ,input  exctaxcd
                ,input  factorrt
                ,input  btltaxcd
                ,input  gds-amount
                ,input  chk-amount
                ,input  line-out
                ,input  line-ret
                ,input  dtl-out
                ,input  dtl-ret
                ,input  nf-chk-amount
                ,input  nf-gds-amount
                ,input  shop.day-only
                ,input  p-ink-doc.doc-date
                ,input  p-ink-doc.shift-date
                ,input  p-ink-doc.shift-num
                ,input  p-ink-doc.doc-date
                ,input  p-ink-doc.shift-date
                ,input  p-ink-doc.shift-num
                ,buffer p-ink-doc
                ,buffer trn-doc
                ,buffer ret-doc
                ,buffer buf_sysconf
    ) NO-ERROR.
    assign
        v-error-status = error-status:error
        v-error-status-message = error-status:get-message(1)
    .

    if v-ii = 0 then do:
        if v-error-status then
        message
        "Произошла ошибка при перезакачке чеков в продажу" skip
        v-error-status-message skip
        return-value
        view-as alert-box .
        else
        message
        "Нет чеков, удовлетворяющих условиям перезакачки в продажу" skip
        view-as alert-box WARNING .
        assign p-to-reserv = no .
    end.
    else do:
        message
        substitute("Просмотрено &1 чеков, успешно перезакачано в продажу &2", v-ii, v-ii-ok)
        view-as alert-box WARNING .
        assign p-to-reserv = yes .
    end.

    /* КОНЕЦ Закачка чеков обратно в продажу */
end procedure.


/* Данные процедуры нужны для корректной работы программы закачки чеков inc-salr.p */
procedure display-chk :
DEFINE INPUT PARAMETER p-chk-amount AS INTEGER NO-UNDO.
define input parameter p-nf-chk-amount as integer no-undo .

end procedure. /* display-chk */


PROCEDURE display-ink-doc :
define input parameter p-gds-amount  as integer no-undo .
define input parameter p-nf-gds-amount  as integer no-undo .
define input parameter p-line-out    as integer no-undo .
define input parameter p-line-ret    as integer no-undo .
define input parameter p-dtl-out     as integer no-undo .
define input parameter p-dtl-ret     as integer no-undo .

END PROCEDURE. /* display-ink-doc */        

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
  ENABLE b-save b-cancel b-print br-places b-sel-rvs
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

