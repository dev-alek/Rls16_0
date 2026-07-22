&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
/* Connected Databases
          ub               PROGRESS
*/
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame


/* Temp-Table and Buffer definitions                                    */
define buffer buf_goods for ub.goods .
define buffer buf_trn-doc for ub.trn-doc .
define buffer buf_doc-line for ub.doc-line .

define temp-table tt-gds no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field price-rubl as decimal
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Товары из накладной

Автор: Хныкин Павел Андреевич
Дата создания: 01/16/07
Author: Pavel Khnykin
Creation date: 01/16/07

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input  parameter p-doc-code    as character                        no-undo .
define input  parameter p-is-edo      as logical                          no-undo .
define output parameter p-rid-list    as character                        no-undo .

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i    }
{ cmp/trg-def.i     }
{ cmp/showinf.i     }
{ gbl/waitfram.i    }
{ rep/p-fmt.i       }
{ rep/r-sym.i       }
{ cmp/r-pril.i new  }
{ gbl/prn-lib.i     }
{ ref/gds-attr.i    }

define variable v-gds-list as character no-undo.
define variable objSrv          as class     ibs.th.gbl.sys.objsrv no-undo.
define variable EDOParSec       as class     ibs.th.gbl.env.prmtrs.edo no-undo .
define variable varvalue        as character no-undo .
define variable vartype         as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame
&Scoped-define BROWSE-NAME br-gds

/* Internal Tables (found by Frame, Query & Browse Queries)             */
&Scoped-define INTERNAL-TABLES tt-gds

/* Definitions for BROWSE br-gds                                     */
&Scoped-define FIELDS-IN-QUERY-br-gds ~
mark-str-regions(buffer tt-gds, v-gds-list) ~
tt-gds.gds-code tt-gds.gds-name tt-gds.qnty
&Scoped-define ENABLED-FIELDS-IN-QUERY-br-gds
&Scoped-define QUERY-STRING-br-gds FOR EACH tt-gds NO-LOCK INDEXED-REPOSITION
&Scoped-define OPEN-QUERY-br-gds OPEN QUERY br-gds FOR EACH tt-gds NO-LOCK INDEXED-REPOSITION.
&Scoped-define TABLES-IN-QUERY-br-gds tt-gds
&Scoped-define FIRST-TABLE-IN-QUERY-br-gds tt-gds


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-br-gds}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-sel b-mark br-gds ~
&Scoped-Define DISPLAYED-OBJECTS 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD mark-str-regions Dialog-Frame
FUNCTION mark-str RETURNS CHARACTER
  ( buffer buf_gds for tt-gds, input v-gds-list as character)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-exit AUTO-END-KEY
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.
     
define button b-sel-all 
  label "&+":L 
  size 3 by 1 tooltip "Отметить все объекты".
  
define button b-unmark 
  label "&-":L 
  size 3 by 1 tooltip "Снять все отметки".

DEFINE BUTTON B-sel AUTO-GO
     LABEL "Вы&бор"
     SIZE 10 BY 1
     BGCOLOR 8 .


/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY br-gds FOR
      tt-gds SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE br-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-gds Dialog-Frame _STRUCTURED
  QUERY br-gds NO-LOCK DISPLAY
      mark-str(buffer tt-gds, v-gds-list) COLUMN-LABEL "*"
            WIDTH 1
      tt-gds.gds-code COLUMN-LABEL "Код товара" FORMAT ">>>>>>>>>9":U
      tt-gds.gds-name COLUMN-LABEL "Наименование" FORMAT "X(100)":U width 60
      tt-gds.qnty     COLUMN-LABEL "Кол-во по накладной"
      tt-gds.price-rubl COLUMN-LABEL "Цена в ПН"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS NO-COLUMN-SCROLLING SEPARATORS SIZE 107 BY 22 FIT-LAST-COLUMN.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1 WIDGET-ID 2
     B-sel AT ROW 1 COL 11 WIDGET-ID 6
     b-mark AT ROW 1 COL 26 WIDGET-ID 8
     b-sel-all at row 1 col 29 widget-id 28
     b-unmark at row 1 col 32 widget-id 30
     br-gds AT ROW 3 COL 1 WIDGET-ID 200
     SPACE(0.1) SKIP(0.2)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Выберите товар(ы)" WIDGET-ID 100.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
   Temp-Tables and Buffers:
      TABLE: buf_regions B "?" ? ub regions
   END-TABLES.
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
/* BROWSE-TAB br-gds B-Help Dialog-Frame */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN mark-num IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE br-gds
/* Query rebuild information for BROWSE br-gds
     _TblList          = "buf_regions"
     _Options          = "NO-LOCK INDEXED-REPOSITION"
     _FldNameList[1]   > "_<CALC>"
"mark-str-regions(buffer buf_regions, v-regions-mark-list)" "*" ? ? ? ? ? ? ? ? no ? no no "1" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[2]   > Temp-Tables.buf_regions.reg-code
"buf_regions.reg-code" "Код" ? "integer" ? ? ? ? ? ? no ? no no ? yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _FldNameList[3]   > Temp-Tables.buf_regions.reg-name
"buf_regions.reg-name" "Регион" ? "character" ? ? ? ? ? ? no ? no no "54" yes no no "U" "" "" "" "" "" "" 0 no 0 no no
     _Query            is OPENED
*/  /* BROWSE br-gds */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Справочник регионов РФ */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-exit Dialog-Frame
ON CHOOSE OF B-exit IN FRAME Dialog-Frame /* Выход */
DO:
  { gbl/stdbtn.i }
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-sel-all
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-sel-all Dialog-Frame
on choose of b-sel-all in frame Dialog-Frame /* + */
  do:
    assign 
      v-gds-list = "".
    if not available tt-gds then return.
    for each tt-gds no-lock :
      { gbl/markstrn.i tt-gds v-gds-list }
    end.
    {&browse-name}:refresh() in frame {&frame-name} .
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME b-unmark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-unmark Dialog-Frame
on choose of b-unmark in frame Dialog-Frame /* - */
  do:
    if not available tt-gds then return.
    v-gds-list  = "".
    {&browse-name}:refresh() in frame {&frame-name} .
  end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&Scoped-define SELF-NAME b-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-mark Dialog-Frame
ON CHOOSE OF b-mark IN FRAME Dialog-Frame /* * */
DO:
define variable v-log as logical no-undo.

    if available tt-gds then do:
      { gbl/markstrn.i tt-gds v-gds-list }
      v-log = br-gds:refresh() .
      if last-event:function <> "MOUSE-SELECT-DBLCLICK" then  do:
        v-log = br-gds:select-next-row ().
        apply "iteration-changed" to br-gds in frame {&frame-name}.
      end.
    end.
    apply "entry" to br-gds in frame {&frame-name}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




&Scoped-define SELF-NAME B-sel
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-sel Dialog-Frame
ON CHOOSE OF B-sel IN FRAME Dialog-Frame /* Выбор */
DO:
  define variable ii as integer no-undo .
  if trim (v-gds-list, ",") > ""
  then do :
    p-rid-list = "" .
    do ii = 1 to num-entries (v-gds-list) :
      find first tt-gds no-lock where recid(tt-gds) = integer(entry(ii, v-gds-list)) .
      find first buf_goods no-lock where buf_goods.gds-code = tt-gds.gds-code .
      p-rid-list = p-rid-list + string(recid(buf_goods)) + "," .
    end.
    p-rid-list = trim(p-rid-list, ",") .
  end.
  else do :
    if available tt-gds
    then do:
      find first buf_goods no-lock where buf_goods.gds-code = tt-gds.gds-code .
      assign
        p-rid-list = string(recid(buf_goods))
      .
    end.
    else return no-apply .
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define BROWSE-NAME br-gds
&Scoped-define SELF-NAME br-gds
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL br-gds Dialog-Frame
ON MOUSE-SELECT-DBLCLICK OF br-gds IN FRAME Dialog-Frame
DO:
  apply "choose" to b-sel.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.
{ gbl/hot-key.i b-exit }
{ gbl/hot-key.i b-mark }
{ gbl/hot-key.i b-sel }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code .
  run fill-tt .   
  RUN my-enable in this-procedure .
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN my-disable.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

procedure fill-tt :
  empty temp-table tt-gds .
  if p-is-edo = ?
  then do :
    for each buf_doc-line no-lock where buf_doc-line.doc-code = p-doc-code,
    first buf_goods no-lock where buf_goods.artic     = buf_doc-line.artic
                             and buf_goods.prod-type = buf_doc-line.prod-type
                             and buf_goods.prod-code = buf_doc-line.prod-code :
      create tt-gds .
      buffer-copy buf_goods to tt-gds
      assign
        tt-gds.qnty = buf_doc-line.fact-qnty
        tt-gds.price-rubl = buf_doc-line.price-rubl
      .
    end .
  end .
  else do :
    run gbl/getobjsrvhndl.p (input-output ObjSrv).
    EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code).
    
    for each buf_doc-line no-lock where buf_doc-line.doc-code = p-doc-code
                                   and buf_doc-line.fact-qnty > 0 ,
    first buf_goods no-lock where buf_goods.artic     = buf_doc-line.artic
                             and buf_goods.prod-type = buf_doc-line.prod-type
                             and buf_goods.prod-code = buf_doc-line.prod-code :
      if p-is-edo
      then do :
        create tt-gds .
        buffer-copy buf_goods to tt-gds
        assign
          tt-gds.qnty = buf_doc-line.fact-qnty
          tt-gds.price-rubl = buf_doc-line.price-rubl
        .
      end .
      if not p-is-edo
      then do :
        RUN gds-attr-value (
          INPUT buf_goods.gds-code,
          INPUT {&attr-mark-type},
          OUTPUT varvalue,
          OUTPUT vartype
          ).
        if EDOParSec:GetIsEDOForType(varvalue)
        or EDOParSec:GetIsArticForType(varvalue)
        or EDOParSec:GetIsMarkingForType(varvalue)
        then do :
          
        end .
        else do :
          create tt-gds .
          buffer-copy buf_goods to tt-gds
          assign
            tt-gds.qnty = buf_doc-line.fact-qnty
            tt-gds.price-rubl = buf_doc-line.price-rubl
          .
        end .
      end .
    end .  
  end .
end procedure .

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
  ENABLE B-exit B-sel b-mark br-gds b-sel-all b-unmark 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-disable Dialog-Frame
PROCEDURE my-disable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  run disable_UI in this-procedure .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-enable Dialog-Frame
PROCEDURE my-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  enable
    b-exit
    b-sel 
    b-mark
    br-gds
    b-sel-all
    b-unmark 
  with frame {&frame-name}.
  view frame {&frame-name}.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Implementations ***************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION mark-str-regions Dialog-Frame
FUNCTION mark-str RETURNS CHARACTER
  ( buffer buf_gds for tt-gds, input v-gds-list as character) :
/*------------------------------------------------------------------------------
  Purpose:
    Notes:
------------------------------------------------------------------------------*/

  RETURN (if ( lookup( string( recid( buf_gds ) ) , v-gds-list ) ) > 0 then "*":u else '':u ).   /* Function return value. */

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME