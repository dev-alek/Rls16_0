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
using ibs.th.bge.egais.*.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Работа с акцизными марками".
{ cmp/vssrevis.i }

/* ***************************  Definitions  ************************** */

{ bge/egais-mark.i }
{ str/marks.i }
{ cmp/str-glbl.i              }
{ str/lib-trn.i  }
{ cmp/library.i               }
{ cmp/showinf.i               }
/*{ str/libbcrcn.i              }      */
/*{ str/plgdsfnd.i              }      */
/*{ cmp/r-pril.i  new           }      */
/*{ rep/v-suppl.i new new       }      */
/*{ gbl/tax-name.i              }      */
/*{ cmp/croslist.i              }      */
/*{ str/lib-trn.i               }      */
/*{ gbl/cur-time.i              }      */
/*{ str/tax-val.i               }      */
/*{ str/lib-def.i               }      */
/*{ str/doc-code.i              }      */
/*{ str/lib-calc.i              }      */
/*{ str/prescan.i               }      */
 { str/cpprclig.i              }
/*{ str/renum.i                 }      */
/*{ gbl/waitfram.i              }      */
/*{ str/trdcalib.i              }      */
/*{ str/scr-neb.i               }      */
/*{ gbl/clntattr.i              }      */
/*{ str/attrlist.i              }      */
/*{ gbl/getcntxt.i def          }      */
/*{ gbl/getcntxt.i get          }      */
/*{ str/getctxtp.i def          }      */
/*{ str/getctxtp.i get          }      */
/*{ str/lib-rvs.i               }      */
/*{ trg/factord.i               }      */
/*{ str/in-ptrl.i  def all-line }      */

/*{ gbl/getsect.i def           }      */
{ gbl/lineattr.i              }
{ ref/gds-attr.i }
{ gbl/key-rec.i  }
{ str/lib-def.i  }
{ gbl/alc-lib.i                }

/* Parameters Definitions ---                                           */

define input parameter parparentproc     as handle       no-undo .
define input parameter p-doc-code   like ub.trn-doc.doc-code no-undo .
define input parameter p-mode       as character no-undo .

{ str/prslnew.i "proc"        }
/* Local Variable Definitions ---                                       */

/*define new shared temp-table tt-exts*/
/*    field ext-rec as recid          */
/*    field gds-code as integer       */
/*    index pi as primary unique      */
/*        ext-rec gds-code            */
/*.                                   */

define temp-table tt-line
    field gds-code  as integer
    field alc-code  as character        label "Алк. код"       FORMAT "X(20)"  
    field artic     as character        label "Артикул"        FORMAT "X(15)"  
    field gds-name  as character        label "Наименование"   FORMAT "X(35)"
    field fact-qnty as integer          label "Кол-во факт"   
    field mark-qnty as integer          label "Кол-во марок"
    index pi as primary unique
        gds-code alc-code
.

define temp-table tt-marks
    field mark         as character            label "Марка"          format "X(100)"
    field gds-code     as integer
    field alc-code     as character            LABEL "Алк. код"       FORMAT "X(20)"  
    index pi as primary unique
        mark
.

define temp-table tt-fr-doc-line no-undo like ub.doc-line
  field price-prod              like ub.doc-line.price-cli
  field price-prod-vat          like ub.doc-line.price-cli
  field price-sale              like ub.doc-line.price-cli
  field curr-abbr               like ub.currency.curr-abbr
  field unit-type               like ub.units.type
  field unit-base               like ub.units.unit-name
  field cli-art                 as character
  field gds-name                like ub.goods.gds-name
  field pl-code                 like ub.pl-gds.pl-code
  field state-measure-qnty      like ub.doc-line.doc-qnty
  field measure-qnty            like ub.doc-line.doc-qnty
  field state-measure-cli-qnty  like ub.doc-line.doc-qnty
  field measure-cli-qnty        like ub.doc-line.doc-qnty
  field obj-name                like ub.clients.obj-name
  field cst-code                like ub.parts.cst-code
  field last-num-day            as   integer
  field last-date               like ub.parts.last-date
  field contract-code           like ub.contract.contract-code
  field contract-prn-code       like ub.contract.contract-prn-code
  field type-inp-vat            as   logical
  field wt-place                as   decimal
  field froze-fact-qnty         as   logical                        initial no
  field type-inp-sum            as   logical
  field tot-cli                 like ub.doc-line.price-cli
  field country-code            like ub.parts-attr.country-code
  field alpha1                  like ub.country.alpha1
  field short-name              like ub.country.short-name
  field fact-qnty-kg            like ub.doc-line.fact-qnty
  field alc-prod                as   logical
  field alc-part-code           as   character
  field alc-multi-parts         as   logical
  field alc-update              as   logical
  field alc-mark-db-num         as   integer
  field alc-mark-code           as   integer
  field alc-bottling-date       as   date
  field alc-ref-ab-path         as   character
  field alc-quality-certif-path as   character
  field alc-certif-path         as   character
  field alc-imp-type            as   character
  field alc-imp-code            as   integer
.

define buffer buf_trn-doc for ub.trn-doc  .
define buffer t-doc for ub.trn-doc  .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_parts for ub.parts .
define buffer buf2_parts for ub.parts .
define buffer buf_gds-dtl for ub.gds-dtl .
define buffer buf_prod-bc for ub.prod-bc .
define buffer buf_bar-code for ub.bar-code .
define buffer buf_goods for ub.goods .
define buffer buf_gen-attr for ub.gen-attr .
define buffer x_ext-classif     for ub.ext-classif .
define buffer bf_sysconf        for ub.sysconf.

define variable hndl-proc-egais-marks-lib as handle.
def    var      extGdsObj       as class     extgds.

define variable v-parts-key-rec as character no-undo .
define variable v-rezerv as integer no-undo .
define variable v-prod-bc   as character no-undo .
define variable v-ext-rec           as recid no-undo .
define variable v-alc-code    as character    no-undo .
define variable v-gds-code    as integer    no-undo .
define variable v-error-lang  as logical      no-undo .
define variable l-error         as logical   no-undo.
define variable ii       as integer no-undo .
define variable v-clcdoc-vat-pc             like ub.doc-line.vat-pc          no-undo.
define variable v-clcdoc-slt-pc             like ub.doc-line.slt-pc          no-undo.
define variable v-clcdoc-have-slt-pc        like ub.doc-line.slt-pc          no-undo.
define variable v-clcdoc-host-code          like ub.sysconf.host-code        no-undo.
define variable v-goods-ms-base             as decimal format ">>,>>9.999"   no-undo .
define variable v-type as character no-undo .
define variable v-part-code as character no-undo.

define variable part-key-rec as character no-undo .

define variable line-rec        as   recid                   no-undo.

define variable par-alcohol as character no-undo .
define variable par-mark as character no-undo .
define variable par-type as character no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel v-mark 
&Scoped-Define DISPLAYED-OBJECTS v-mark 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON Btn_Cancel AUTO-END-KEY 
     LABEL "Отмена" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO 
     LABEL "Ввод" 
     SIZE 15 BY 1.14
     BGCOLOR 8 .

DEFINE VARIABLE v-mark AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 68 BY 1 NO-UNDO.
     
/* Query definitions                                                    */
&ANALYZE-SUSPEND
  DEFINE QUERY br-lines FOR 
    tt-line SCROLLING.
    
  DEFINE QUERY br-marks FOR 
    tt-marks SCROLLING.
&ANALYZE-RESUME

  /* Browse definitions                                                   */
  DEFINE BROWSE br-lines
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-marks Dialog-Frame _FREEFORM
    QUERY br-lines  DISPLAY
    tt-line.artic WIDTH 15
    tt-line.gds-name WIDTH 37
    tt-line.alc-code width 20
    tt-line.fact-qnty width 11
    tt-line.mark-qnty width 12
    ENABLE
    tt-line.fact-qnty
    
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 100 BY 13.2 FIT-LAST-COLUMN.
    
      /* Browse definitions                                                   */
  DEFINE BROWSE br-marks
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS br-marks Dialog-Frame _FREEFORM
    QUERY br-marks  DISPLAY
    tt-marks.mark label "Акцизная марка" format "X(256)" width 98
    
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 100 BY 7.2 FIT-LAST-COLUMN.

/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1.24 COL 2
     Btn_Cancel AT ROW 1.24 COL 17
     v-mark AT ROW 2.67 COL 3 NO-LABEL WIDGET-ID 2
     br-lines at row 4 col 2
     br-marks at row  18 col 2
     SPACE(1) SKIP(1)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Работа с акцизными марками"
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

/* SETTINGS FOR FILL-IN v-mark IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Работа с акцизными марками */
DO:
  delete object extGdsObj no-error.
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME btn_ok
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL btn_ok Dialog-Frame
ON CHOOSE OF btn_ok in FRAME Dialog-Frame /* Работа с акцизными марками */
DO:
/*    run gbl/inidebug.p .*/
  delete object extGdsObj no-error.
  do transaction :
      tt-line_ :
      for each tt-line no-lock break by tt-line.gds-code :
          find first buf_goods no-lock where buf_goods.gds-code = tt-line.gds-code .
          find first buf_doc-line exclusive-lock where buf_doc-line.doc-code = p-doc-code
                                                   and buf_doc-line.artic = buf_goods.artic
                                                   and buf_doc-line.prod-type = buf_goods.prod-type
                                                   and buf_doc-line.prod-code = buf_goods.prod-code
                                                   no-error .
          if available buf_doc-line
          then do :
              if first-of(tt-line.gds-code)
              then do :
                assign
                    buf_doc-line.fact-qnty = 0
                    buf_doc-line.doc-qnty = 0
                    buf_doc-line.cli-qnty = 0
                .
              end.
              
              assign
                buf_doc-line.fact-qnty = buf_doc-line.fact-qnty + tt-line.fact-qnty
                buf_doc-line.doc-qnty = buf_doc-line.fact-qnty
                buf_doc-line.cli-qnty = buf_doc-line.fact-qnty
              .
              
              find first buf_parts exclusive-lock where buf_parts.obj-type = buf_doc-line.obj-type
                                                     and buf_parts.obj-code = buf_doc-line.obj-code
                                                     and buf_parts.artic    = buf_doc-line.artic
                                                     and buf_parts.prod-type = buf_doc-line.prod-type
                                                     and buf_parts.prod-code = buf_doc-line.prod-code
                                                     and buf_parts.in-code  = p-doc-code
                                                     and buf_parts.out-code = p-doc-code
                                                     and num-entries(buf_parts.alc-ref-ab-path) = 4
                                                     and entry(3, buf_parts.alc-ref-ab-path) = tt-line.alc-code
                                                     no-error .
              if not available buf_parts
              then do :
                  next tt-line_ .
              end.
              find first buf2_parts exclusive-lock where buf2_parts.obj-type = buf_doc-line.obj-type
                                                     and buf2_parts.obj-code = buf_doc-line.obj-code
                                                     and buf2_parts.artic    = buf_doc-line.artic
                                                     and buf2_parts.prod-type = buf_doc-line.prod-type
                                                     and buf2_parts.prod-code = buf_doc-line.prod-code
                                                     and buf2_parts.in-code  = p-doc-code
                                                     and buf2_parts.out-code = p-doc-code
                                                     and num-entries(buf2_parts.alc-ref-ab-path) = 4
                                                     and entry(3, buf2_parts.alc-ref-ab-path) = tt-line.alc-code
                                                     and recid(buf2_parts) <> recid(buf_parts)
                                                     no-error .
              if available buf2_parts
              then do :
                  next tt-line_ .
              end.
              assign
                buf_parts.fact-qnty = buf_doc-line.fact-qnty  
                buf_parts.cli-qnty  = buf_parts.fact-qnty
                buf_parts.qnty      = buf_parts.fact-qnty
              .  
              
              find first buf_gds-dtl exclusive-lock where buf_gds-dtl.doc-code  = p-doc-code
                                                      and buf_gds-dtl.artic     = buf_doc-line.artic
                                                      and buf_gds-dtl.prod-type = buf_doc-line.prod-type
                                                      and buf_gds-dtl.prod-code = buf_doc-line.prod-code
                                                      no-error .
              if not available buf_gds-dtl
              then do :
                  
              end .
              assign
                buf_gds-dtl.fact-qnty = buf_doc-line.fact-qnty
                buf_gds-dtl.doc-qnty  = buf_gds-dtl.fact-qnty
              . 
          end.
          else do :
              run cr-line .   
              find first buf_doc-line no-lock where buf_doc-line.doc-code = p-doc-code
                                               and buf_doc-line.artic = buf_goods.artic
                                               and buf_doc-line.prod-type = buf_goods.prod-type
                                               and buf_doc-line.prod-code = buf_goods.prod-code
                                               no-error .
              if not available buf_doc-line
              then do :
                  
              end.                                 
              find first buf_parts exclusive-lock where buf_parts.obj-type = buf_doc-line.obj-type
                                                     and buf_parts.obj-code = buf_doc-line.obj-code
                                                     and buf_parts.artic    = buf_doc-line.artic
                                                     and buf_parts.prod-type = buf_doc-line.prod-type
                                                     and buf_parts.prod-code = buf_doc-line.prod-code
                                                     and buf_parts.in-code  = p-doc-code
                                                     and buf_parts.out-code = p-doc-code
                                                     no-error .
              if not available buf_parts
              then do :
                  
              end.
              if num-entries(buf_parts.alc-ref-ab-path) = 4
              then entry(3, buf_parts.alc-ref-ab-path) = tt-line.alc-code .
              else buf_parts.alc-ref-ab-path = ",," + tt-line.alc-code + "," .                               
              
          end.
          
          find first buf_parts no-lock where buf_parts.obj-type = buf_doc-line.obj-type
                                             and buf_parts.obj-code = buf_doc-line.obj-code
                                             and buf_parts.artic    = buf_doc-line.artic
                                             and buf_parts.prod-type = buf_doc-line.prod-type
                                             and buf_parts.prod-code = buf_doc-line.prod-code
                                             and buf_parts.in-code  = p-doc-code
                                             and buf_parts.out-code = p-doc-code
                                             and num-entries(buf_parts.alc-ref-ab-path) = 4
                                             and entry(3, buf_parts.alc-ref-ab-path) = tt-line.alc-code
                                             no-error .
          if not available buf_parts
          then do :
              
          end.
          run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                              ,input (buffer buf_parts:handle)
                                              ,output part-key-rec). 
          for each tt-marks no-lock where tt-marks.gds-code = tt-line.gds-code
                                      and tt-marks.alc-code = tt-line.alc-code :
              find first buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                                                and buf_gen-attr.p-key      = part-key-rec
                                                and buf_gen-attr.attr-code  = tt-marks.mark
                                                no-error .
              if not available buf_gen-attr
              then do :
                  create buf_gen-attr .
                  assign
                    buf_gen-attr.table-name = {&excise-mark}
                    buf_gen-attr.p-key      = part-key-rec
                    buf_gen-attr.attr-code  = tt-marks.mark
                  .
              end.                            
          end.
      end.
  end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME v-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON return OF v-mark in FRAME Dialog-Frame /* Ввод марок */
DO:
/*    run gbl/inidebug.p .*/
    assign v-mark .
    v-mark = trim(v-mark) .
    if length(v-mark) = 13 then do :
        v-prod-bc = v-mark .
        find first buf_prod-bc no-lock where buf_prod-bc.b-str = v-prod-bc no-error.
        if not available buf_prod-bc
        then do :
            message "Не найден доп. бар-код EAN13 " v-prod-bc view-as alert-box .
            return no-apply .
        end.
        find first buf_bar-code no-lock where buf_bar-code.b-code = buf_prod-bc.b-code no-error.
        if not available buf_bar-code
        then do :
            message "Не найден бар-код для кода EAN13 " v-prod-bc view-as alert-box .
            return no-apply .
        end.
        find first buf_goods no-lock where buf_goods.gds-code = buf_bar-code.gds-code no-error.
        if not available buf_goods
        then do :
            message "Не найден товар для кода EAN13 " v-prod-bc view-as alert-box .
            return no-apply .
        end.
        extGdsObj:OpenQueryExtGds(buf_goods.gds-code, "").
        if extGdsObj:NumBundles = 0
        then do :
            message "Товар " buf_goods.artic "  " buf_goods.gds-name " не синхронизирован с ЕГАИС. Код EAN13 " v-prod-bc view-as alert-box .
            return no-apply .
        end.
        else if extGdsObj:NumBundles > 1
        then do :
/*            run bge/egais-select-alc-code.w (input buf_goods.gds-code, output v-ext-rec) .      */
/*            find first X_ext-classif no-lock where recid(X_ext-classif) = v-ext-rec no-error .  */
/*            if not available X_ext-classif then return no-apply.                                */
/*            find first tt-line exclusive-lock where tt-line.gds-code = buf_goods.gds-code       */
/*                                                and tt-line.alc-code = X_ext-classif.charkey_one*/
/*                                                no-error .                                      */
/*            if available tt-line                                                                */
/*            then reposition br-lines to recid recid(tt-line) .                                  */
/*            else do :                                                                           */
/*                create tt-line .                                                                */
/*                assign                                                                          */
/*                    tt-line.gds-code    = buf_goods.gds-code                                    */
/*                    tt-line.alc-code    = X_ext-classif.charkey_one                             */
/*                    tt-line.artic       = buf_goods.artic                                       */
/*                    tt-line.gds-name    = buf_goods.gds-name                                    */
/*                    tt-line.fact-qnty   = 0                                                     */
/*                    tt-line.mark-qnty   = 0                                                     */
/*                .                                                                               */
/*                open query br-lines for each tt-line exclusive-lock .                           */
/*            end.                                                                                */
        end.
        else do :
            find first tt-line exclusive-lock where tt-line.gds-code = buf_goods.gds-code
                                                and tt-line.alc-code = extGdsObj:GetExtGdsValue(1):AlcCode
                                                no-error .
            if available tt-line
            then reposition br-lines to recid recid(tt-line) .
            else do :
                create tt-line .
                assign
                    tt-line.gds-code    = buf_goods.gds-code
                    tt-line.alc-code    = extGdsObj:GetExtGdsValue(1):AlcCode
                    tt-line.artic       = buf_goods.artic
                    tt-line.gds-name    = buf_goods.gds-name
                    tt-line.fact-qnty   = 0
                    tt-line.mark-qnty   = 0
                .
                open query br-lines for each tt-line exclusive-lock .
            end.
        end.
    end.
    else do :
        run find-mark in hndl-proc-egais-marks-lib (input v-mark,
                                                    output v-parts-key-rec,
                                                    output v-rezerv).
        if v-parts-key-rec <> ?
        then do :
            message "Данная марка уже учтена в системе. Партия " v-parts-key-rec view-as alert-box.
            return no-apply .
        end. 
        find first tt-marks no-lock where tt-marks.mark = v-mark no-error .
        if available tt-marks
        then do :
            message "Вы уже сканировали эту марку" view-as alert-box .
            return no-apply .
        end.  
        run ProcAlcCode  IN THIS-PROCEDURE (input v-mark, output v-alc-code, output l-error, output v-error-lang ) no-error.
        if v-error-lang
        then do:
            message "Не корректно считана акцизная марка, акцизная марка содержит не допустимые символы или русские буквы."
                view-as alert-box .
            return no-apply .
        end.
        extGdsObj:OpenQueryExtGds(0, v-alc-code) .
        if extGdsObj:NumBundles = 0
        then do :
            message substitute ("Для алког. кода &1 не найден товар (не установлено соответствие)", v-alc-code) view-as alert-box .
            return no-apply.
        end.
        else if extGdsObj:NumBundles > 1
        then do :
/*            find first tt-line exclusive-lock where tt-line.gds-code = extGdsObj:GetExtGdsValue(ii):GdsCode*/
/*                                                and tt-line.alc-code = v-alc-code                          */
/*                                                no-error .                                                 */
/*            if available tt-line then leave .                                                              */
        end.
        else do :
            v-gds-code = extGdsObj:GetExtGdsValue(1):GdsCode .
            find first tt-line exclusive-lock where tt-line.gds-code = v-gds-code
                                                and tt-line.alc-code = v-alc-code
                                                no-error .
            find first buf_goods no-lock where buf_goods.gds-code = v-gds-code .                             
            if not available tt-line
            then do :                                    
                create tt-line .
                assign
                    tt-line.gds-code    = buf_goods.gds-code
                    tt-line.alc-code    = v-alc-code
                    tt-line.artic       = buf_goods.artic
                    tt-line.gds-name    = buf_goods.gds-name
                    tt-line.fact-qnty   = 0
                    tt-line.mark-qnty   = 0
                .
                open query br-lines for each tt-line exclusive-lock .
            end. 
            tt-line.mark-qnty = tt-line.mark-qnty + 1 .  
            br-lines:refresh () . 
        end.
        create tt-marks.
        assign
            tt-marks.mark = v-mark
            tt-marks.gds-code = tt-line.gds-code
            tt-marks.alc-code = tt-line.alc-code
        .
        reposition br-lines to recid recid(tt-line) .
        apply "value-changed" to br-lines IN FRAME Dialog-Frame .
    end.                                             
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

on value-changed of br-lines IN FRAME Dialog-Frame
do :
    open query br-marks for each tt-marks no-lock where tt-marks.gds-code = tt-line.gds-code
                                                    and tt-marks.alc-code = tt-line.alc-code .
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
  run bge/egais-marks-find.p persistent (output hndl-proc-egais-marks-lib) no-error .
  extGdsObj = new ExtGds (true).     
  
  find first t-doc no-lock where t-doc.doc-code = p-doc-code .
  find first bf_sysconf no-lock
     where bf_sysconf.host-code = t-doc.host-code
   .
  run fill-tt .
  RUN enable_UI.
  
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

procedure fill-tt :
    
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code .
    for each buf_doc-line no-lock where buf_doc-line.doc-code = p-doc-code :
        find first buf_goods no-lock where buf_goods.artic     = buf_doc-line.artic
                                  and buf_goods.prod-type = buf_doc-line.prod-type
                                  and buf_goods.prod-code = buf_doc-line.prod-code
                                  no-error .
                                      
        run gds-attr-value(
          buf_goods.gds-code,
          {&attr-alcohol-prod},
          output par-alcohol,
          output par-type
        ).
        if par-alcohol = "" or par-alcohol = "no" then next .
        run gds-attr-value(
          buf_goods.gds-code,
          {&attr-mark},
          output par-mark,
          output par-type
        ).
        if par-mark = "" or par-mark = "no" then next .
        
        for each buf_parts no-lock where buf_parts.obj-type = buf_doc-line.obj-type
                                     and buf_parts.obj-code = buf_doc-line.obj-code
                                     and buf_parts.artic    = buf_doc-line.artic
                                     and buf_parts.prod-type = buf_doc-line.prod-type
                                     and buf_parts.prod-code = buf_doc-line.prod-code
                                     and buf_parts.in-code  = p-doc-code
                                     and buf_parts.out-code = p-doc-code :
            run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                                ,input (buffer buf_parts:handle)
                                                ,output part-key-rec). 
            find first tt-line exclusive-lock where tt-line.gds-code = buf_goods.gds-code
                                                and tt-line.alc-code = if num-entries(buf_parts.alc-ref-ab-path) = 4 then entry(3, buf_parts.alc-ref-ab-path)   else ?
                                                no-error .
            if not available tt-line
            then do :                                    
                create tt-line.
                assign
                    tt-line.gds-code    = buf_goods.gds-code     
                    tt-line.alc-code    = if num-entries(buf_parts.alc-ref-ab-path) = 4 then entry(3, buf_parts.alc-ref-ab-path)   else ?
                    tt-line.artic       = buf_parts.artic
                    tt-line.gds-name    = buf_goods.gds-name
                    tt-line.fact-qnty   = buf_parts.fact-qnty
                .
            end .
            else do :
                tt-line.fact-qnty   = tt-line.fact-qnty + buf_parts.fact-qnty .
            end.
            for each buf_gen-attr no-lock where buf_gen-attr.table-name = {&excise-mark}
                                            and buf_gen-attr.p-key = part-key-rec :
                create tt-marks.
                assign
                    tt-marks.mark   = buf_gen-attr.attr-code
                    tt-marks.gds-code = tt-line.gds-code
                    tt-marks.alc-code = tt-line.alc-code
                .
                tt-line.mark-qnty = tt-line.mark-qnty + 1 .                              
            end.                                                     
        end.
        
    end.
    open query br-lines for each tt-line exclusive-lock .
    apply "value-changed" to br-lines IN FRAME Dialog-Frame .
end procedure .

procedure cr-line :
  find ub.units where ub.units.unit-name  = buf_goods.unit-base no-lock.
  create tt-fr-doc-line.
  { str/st-sltpc.i  recid(buf_goods)  recid(t-doc)  bf_sysconf.cash-pay  v-clcdoc-slt-pc }
  { gbl/hostcode.i t-doc.obj-type t-doc.obj-code v-clcdoc-host-code }
  { gbl/pftxvalg.i buf_goods.gds-code {&vat-tax-code} ? v-clcdoc-host-code t-doc.obj-type t-doc.obj-code v-clcdoc-vat-pc no-error }
  
  assign
    tt-fr-doc-line.doc-code      = t-doc.doc-code
    tt-fr-doc-line.obj-type      = t-doc.obj-type
    tt-fr-doc-line.obj-code      = t-doc.obj-code
    tt-fr-doc-line.artic         = buf_goods.artic
    tt-fr-doc-line.prod-type     = buf_goods.prod-type
    tt-fr-doc-line.prod-code     = buf_goods.prod-code
    tt-fr-doc-line.gds-name      = buf_goods.gds-name
    v-goods-ms-base              = buf_goods.ms-base
    tt-fr-doc-line.unit-base     = buf_goods.unit-base
    tt-fr-doc-line.unit-type     = ub.units.type
    tt-fr-doc-line.prt-root      = buf_goods.prt-root
    tt-fr-doc-line.type-inp-sum  = no
    tt-fr-doc-line.unit-cli      = buf_goods.unit-cli
    tt-fr-doc-line.cli-base-rate = buf_goods.cli-base-rate
    tt-fr-doc-line.doc-density   = ?
    tt-fr-doc-line.fact-density  = ?
    tt-fr-doc-line.temperature   = ?
    tt-fr-doc-line.alc-prod      = yes
    tt-fr-doc-line.type-inp-vat  = yes
    tt-fr-doc-line.doc-qnty      = tt-line.fact-qnty
    tt-fr-doc-line.cli-qnty      = tt-line.fact-qnty
  .
  assign
    tt-fr-doc-line.vat-pc = (if t-doc.vat-type = {&without-vat} then 0 else v-clcdoc-vat-pc )
    tt-fr-doc-line.slt-pc = (if t-doc.slt-type = {&without-slt} then 0 else v-clcdoc-slt-pc )
  .
  run cpprclig in this-procedure   (
       input        t-doc.doc-code                      ,
       input        t-doc.cli-code                      ,
       input        t-doc.cli-type                      ,
       input        t-doc.host-code                     ,
       input        t-doc.base-rate                     ,
       input        t-doc.base-scale                    ,
       input        t-doc.exch-rate                     ,
       input        t-doc.exch-scale                    ,
       input        t-doc.vat-type                      ,
       input        t-doc.slt-type                      ,
       input        tt-fr-doc-line.artic                ,
       input        tt-fr-doc-line.prod-type            ,
       input        tt-fr-doc-line.prod-code            ,
       input        yes                                 ,
       input        tt-fr-doc-line.cli-base-rate        ,
       input        tt-fr-doc-line.transport-rubl       ,
       input        tt-fr-doc-line.other-rubl           ,
       output       tt-fr-doc-line.price-cli            ,
       output       tt-fr-doc-line.price-base           ,
       output       tt-fr-doc-line.price-rubl           ,
       input-output tt-fr-doc-line.vat-pc               ,
       input-output tt-fr-doc-line.slt-pc               ,
       input-output tt-fr-doc-line.road-tax             ,
       input-output tt-fr-doc-line.excise               ) no-error.
  
  run lineattr-value in this-procedure (
      input   t-doc.doc-code  ,
      input   buf_goods.gds-code  ,
      input   {&lineattr-price-prod} ,
      output  tt-fr-doc-line.price-prod ,
      output  v-type       )
      no-error .
  run lineattr-value in this-procedure (
      input   t-doc.doc-code  ,
      input   buf_goods.gds-code  ,
      input   {&lineattr-price-prod-vat} ,
      output  tt-fr-doc-line.price-prod-vat ,
      output  v-type       )
      no-error .
      
  find first  ub.ext-artic where  ub.ext-artic.cli-type   = t-doc.cli-type
            and  ub.ext-artic.cli-code   = t-doc.cli-code
            and  ub.ext-artic.gds-code   = buf_goods.gds-code
            and  ub.ext-artic.status_    <> {&deleted-status}
            no-lock no-error.
  assign tt-fr-doc-line.cli-art = (if available  ub.ext-artic then  ub.ext-artic.ext-artic else ?).
  
  run alc-lib_get-new-part-code in this-procedure
      (input  t-doc.obj-type
      ,input  t-doc.obj-code
      ,input  tt-fr-doc-line.prod-type
      ,input  tt-fr-doc-line.prod-code
      ,input  tt-fr-doc-line.artic
      ,input  t-doc.doc-code
      ,output v-part-code
      ) no-error .
  if error-status :error
  then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры alc-lib_get-new-part-code" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return no-apply.
  end.
  assign
      tt-fr-doc-line.alc-part-code = v-part-code
  .       
/*  run gbl/inidebug.p .*/
  { str/cor-line.i "realy" }
  if error-status :error then do:
     message "Ошибка при вызове процедуры сохранения линии."
             return-value
             view-as alert-box.
     return error.
  end.
/*  run str/chk-prt.p ( input line-rec, input  yes, buffer t-doc ) no-error.*/
/*  if error-status :error then do:                                         */
/*    message                                                               */
/*      vss-workfile vss-revision vss-description skip                      */
/*      "Ошибка про проверке разнесения строки по признакам" skip           */
/*      return-value skip                                                   */
/*      view-as alert-box error .                                           */
/*      return error.                                                       */
/*  end.                                                                    */
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
  DISPLAY v-mark 
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel v-mark br-lines br-marks 
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

