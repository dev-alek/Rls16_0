&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*          This .W file was created with the Progress UIB.             */
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экран покупател

Автор: Суслов Алексей Юрьевич
Дата создания: 03/24/06
Author: Alexey Suslov
Creation date: 03/24/06

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parobj-type like ub.clients.obj-type no-undo.
define input parameter parobj-code like ub.clients.obj-code no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экран покупателя".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ cmp/library.i  }
{ cmp/ini-lib.i  }
{ str/libbcrcn.i }
{ gbl/integerm.i }
{ ref/gds-attr.i }

define variable is-byscrvalue     as character no-undo .
define variable is-byscrtype      as character no-undo .
define variable numbyscrvalue     as character no-undo .
define variable numbyscrtype      as character no-undo .
define variable numbyscrvalue_int as integer   no-undo .
define variable varr-b            as character no-undo .
define variable vartype           as character no-undo .
define variable vargdsscrvw       as character no-undo .
define variable varcurr-code      like ub.sysconf.base-code no-undo.
define variable v-image-order     as character no-undo .
define variable v-type            as character no-undo .
define variable v-data-valid      as logical   no-undo .
define variable v-error-message   as character no-undo .
define variable v-ind             as integer   no-undo .
define VARIABLE vPar-val          as character no-undo .
define VARIABLE vPar-type         as character no-undo .
define VARIABLE v-ph-dir          as character no-undo .
define VARIABLE v-path-db-num     as character no-undo .
define VARIABLE v-from-db-num     as character no-undo .
define variable v-param-types     as character  no-undo.
define variable v-value-char      as character  no-undo.
define variable v-val-date        as date       no-undo.
define variable v-val-decimal     as decimal    no-undo.
define variable v-val-integer     as integer    no-undo.
define variable v-val-logical     as logical    no-undo.
define variable v-tthd            as handle     no-undo.
define variable v-value           as character  no-undo.

define buffer bf_shop          for ub.shop.
define buffer bf_store         for ub.store.
define buffer bf_sysconf       for ub.sysconf.
define buffer bf_currency      for ub.currency.
define buffer buf_batchprocess for ub.batchprocess .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-1 RECT-5 b-str varps
&Scoped-Define DISPLAYED-OBJECTS b-str vartoday vargds-label vargds-name ~
varfprt-name varprice-label varprice-sale varunit-name varskobka-1 ~
varcli-base-rate varunit-base varskobka-2 varunit-name-2 varartic varb-code

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE VARIABLE varps AS CHARACTER 
     VIEW-AS EDITOR
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE b-str AS CHARACTER FORMAT "X(40)" 
     LABEL "Бар-код" 
     VIEW-AS FILL-IN 
     SIZE 41 BY 1 NO-UNDO.

DEFINE VARIABLE varartic AS CHARACTER FORMAT "X(17)":U 
     LABEL "Артикул" 
      VIEW-AS TEXT 
     SIZE 34.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varb-code AS INTEGER FORMAT "999999999":U INITIAL 0 
     LABEL "Код" 
      VIEW-AS TEXT 
     SIZE 11.25 BY .67
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varcli-base-rate AS DECIMAL FORMAT ">>,>>9.<<<<":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varcountry-name AS CHARACTER FORMAT "X(40)":U 
     LABEL "Страна" 
     VIEW-AS FILL-IN 
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varcur-price AS DECIMAL FORMAT ">>,>>9.99":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 10 BY 1
     BGCOLOR 11 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE vardeadline AS INTEGER FORMAT ">>>>>9":U INITIAL 0 
     LABEL "Срок хранения" 
     VIEW-AS FILL-IN 
     SIZE 7 BY 1.08
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE vardestin AS CHARACTER FORMAT "X(40)":U 
     LABEL "Назначение" 
     VIEW-AS FILL-IN 
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varengl-name AS CHARACTER FORMAT "X(40)":U 
     LABEL "Английское название" 
     VIEW-AS FILL-IN 
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varfact-qnty AS DECIMAL FORMAT "->>,>>>,>>9.<<<":U INITIAL 0 
     LABEL "Остаток" 
     VIEW-AS FILL-IN 
     SIZE 16 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varfprt-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 93.5 BY 1
     BGCOLOR 11 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE vargds-label AS CHARACTER FORMAT "X(256)":U INITIAL "Товар:" 
     VIEW-AS FILL-IN 
     SIZE 16.75 BY 1.25
     BGCOLOR 11 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE vargds-name AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 95.5 BY 1.25
     BGCOLOR 11  NO-UNDO.

DEFINE VARIABLE vargrp-name AS CHARACTER FORMAT "X(40)":U 
     LABEL "Группа" 
     VIEW-AS FILL-IN 
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varin-date AS DATE FORMAT "99/99/99":U 
     LABEL "Дата последнего прихода" 
     VIEW-AS FILL-IN 
     SIZE 9 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varprice-label AS CHARACTER FORMAT "X(256)":U INITIAL "Цена:" 
     VIEW-AS FILL-IN 
     SIZE 6.38 BY 1
     BGCOLOR 11  NO-UNDO.

DEFINE VARIABLE varprice-sale AS CHARACTER FORMAT "X(42)":U 
     VIEW-AS FILL-IN 
     SIZE 43.75 BY 1
     BGCOLOR 11 FGCOLOR 4 FONT 9 NO-UNDO.

DEFINE VARIABLE varprod-name AS CHARACTER FORMAT "X(40)":U 
     LABEL "Производитель" 
     VIEW-AS FILL-IN 
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varprt-label AS CHARACTER FORMAT "X(256)":U INITIAL "Признак:" 
     VIEW-AS FILL-IN 
     SIZE 8.75 BY 1
     BGCOLOR 11  NO-UNDO.

DEFINE VARIABLE varps-label AS CHARACTER FORMAT "X(256)":U INITIAL "Примечание:" 
      VIEW-AS TEXT 
     SIZE 11.63 BY .67 NO-UNDO.

DEFINE VARIABLE varr-b-abbr AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1
     BGCOLOR 11 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varrate-label AS CHARACTER FORMAT "X(256)":U INITIAL "Курс:" 
     VIEW-AS FILL-IN 
     SIZE 6 BY 1
     BGCOLOR 11  NO-UNDO.

DEFINE VARIABLE varsert AS CHARACTER FORMAT "X(40)":U 
     LABEL "Сертификат" 
     VIEW-AS FILL-IN 
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varshop-rate AS DECIMAL FORMAT ">>>,>>9.9999":U INITIAL 0 
     VIEW-AS FILL-IN 
     SIZE 13 BY 1
     BGCOLOR 11 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varshop-scale AS CHARACTER FORMAT "X(8)":U 
     VIEW-AS FILL-IN 
     SIZE 9.75 BY 1
     BGCOLOR 11 FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varskobka-1 AS CHARACTER FORMAT "X(256)":U INITIAL "(" 
     VIEW-AS FILL-IN 
     SIZE 1.75 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varskobka-2 AS CHARACTER FORMAT "X(256)":U INITIAL ")" 
     VIEW-AS FILL-IN 
     SIZE 1.75 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varsyrye AS CHARACTER FORMAT "X(40)":U 
     LABEL "Состав" 
     VIEW-AS FILL-IN 
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE vartoday AS CHARACTER FORMAT "X(30)":U 
     LABEL "Сегодня" 
     VIEW-AS FILL-IN 
     SIZE 32.25 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varunit-base AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varunit-name AS CHARACTER FORMAT "X(3)":U 
     LABEL "За ед.изм." 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varunit-name-2 AS CHARACTER FORMAT "X(3)":U 
     VIEW-AS FILL-IN 
     SIZE 4 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varuser-rule AS CHARACTER FORMAT "X(40)":U 
     LABEL "Правила эксплуатации" 
     VIEW-AS FILL-IN 
     SIZE 41 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE VARIABLE varweight AS DECIMAL FORMAT "->>>,>>>,>>9.<<<<":U INITIAL 0 
     LABEL "Вес" 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1
     FGCOLOR 4  NO-UNDO.

DEFINE IMAGE varfoto
     FILENAME "adeicon/blank":U
     STRETCH-TO-FIT
     SIZE 31 BY 13.29.

DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 103.75 BY 14.21.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 103.63 BY 7.08.

DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 103.63 BY 2.96
     BGCOLOR 11 .

DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE    
     SIZE 103.63 BY 1.5
     BGCOLOR 11 .

DEFINE RECTANGLE RECT-5
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 32.25 BY 13.75.



/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-str AT ROW 1.5 COL 9.75 COLON-ALIGNED
     vartoday AT ROW 1.5 COL 71 COLON-ALIGNED
     vargds-label AT ROW 3 COL 2.5 NO-LABEL
     vargds-name AT ROW 3 COL 6.5 COLON-ALIGNED NO-LABEL
     varprt-label AT ROW 4.5 COL 2.5 NO-LABEL
     varfprt-name AT ROW 4.5 COL 8.5 COLON-ALIGNED NO-LABEL
     varprice-label AT ROW 7.08 COL 2.25 NO-LABEL
     varprice-sale AT ROW 7.08 COL 6.75 COLON-ALIGNED NO-LABEL
     varcur-price AT ROW 7.08 COL 50.75 COLON-ALIGNED NO-LABEL
     varr-b-abbr AT ROW 7.08 COL 61.25 COLON-ALIGNED NO-LABEL
     varrate-label AT ROW 7.08 COL 66.63 COLON-ALIGNED NO-LABEL
     varshop-rate AT ROW 7.08 COL 73 COLON-ALIGNED NO-LABEL
     varshop-scale AT ROW 7.08 COL 86.38 COLON-ALIGNED NO-LABEL
     varweight AT ROW 8.5 COL 67.5 COLON-ALIGNED
     varunit-name AT ROW 8.67 COL 12.38 COLON-ALIGNED
     varskobka-1 AT ROW 8.67 COL 16.38 COLON-ALIGNED NO-LABEL
     varcli-base-rate AT ROW 8.67 COL 18 COLON-ALIGNED NO-LABEL
     varunit-base AT ROW 8.67 COL 30 COLON-ALIGNED NO-LABEL
     varskobka-2 AT ROW 8.67 COL 34.25 COLON-ALIGNED NO-LABEL
     vargrp-name AT ROW 10.33 COL 22.75 COLON-ALIGNED
     varengl-name AT ROW 11.38 COL 22.75 COLON-ALIGNED
     varprod-name AT ROW 12.5 COL 22.75 COLON-ALIGNED
     varcountry-name AT ROW 13.5 COL 22.75 COLON-ALIGNED
     varsert AT ROW 14.5 COL 22.75 COLON-ALIGNED
     varsyrye AT ROW 15.5 COL 22.75 COLON-ALIGNED
     vardestin AT ROW 16.58 COL 22.75 COLON-ALIGNED
     varuser-rule AT ROW 17.63 COL 23.63 COLON-ALIGNED
     vardeadline AT ROW 18.75 COL 22.75 COLON-ALIGNED
     varin-date AT ROW 18.75 COL 54.75 COLON-ALIGNED
     varfact-qnty AT ROW 21.21 COL 22.75 COLON-ALIGNED
     varunit-name-2 AT ROW 21.21 COL 39.38 COLON-ALIGNED NO-LABEL
     varps AT ROW 22.29 COL 24.75 NO-LABEL
     varartic AT ROW 6 COL 10 COLON-ALIGNED
     varb-code AT ROW 6 COL 71.5 COLON-ALIGNED
     varps-label AT ROW 22.38 COL 10.75 COLON-ALIGNED NO-LABEL
     RECT-2 AT ROW 2.75 COL 2
     RECT-3 AT ROW 2.75 COL 2
     RECT-4 AT ROW 7 COL 2
     RECT-1 AT ROW 10.25 COL 2
     RECT-5 AT ROW 10.5 COL 72.5
     varfoto AT ROW 10.75 COL 73
     SPACE(32.99) SKIP(4.09)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER 
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE 
         TITLE "Информация о товарах".




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
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR RECTANGLE RECT-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-3 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR RECTANGLE RECT-4 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varartic IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varb-code IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varcli-base-rate IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varcountry-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varcountry-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varcur-price IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varcur-price:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN vardeadline IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       vardeadline:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN vardestin IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       vardestin:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varengl-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varengl-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varfact-qnty IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varfact-qnty:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR IMAGE varfoto IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
ASSIGN
       varfoto:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varfprt-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN vargds-label IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN vargds-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN vargrp-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       vargrp-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varin-date IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varin-date:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varprice-label IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN varprice-sale IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varprod-name IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varprod-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varprt-label IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE ALIGN-L                                         */
ASSIGN
       varprt-label:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR EDITOR varps IN FRAME Dialog-Frame
   NO-DISPLAY                                                           */
ASSIGN
       varps:HIDDEN IN FRAME Dialog-Frame           = TRUE
       varps:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN varps-label IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varps-label:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varr-b-abbr IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varr-b-abbr:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varrate-label IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varrate-label:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varsert IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varsert:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varshop-rate IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varshop-rate:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varshop-scale IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varshop-scale:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varskobka-1 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varskobka-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varsyrye IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varsyrye:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN vartoday IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varunit-base IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varunit-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varunit-name-2 IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN varuser-rule IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varuser-rule:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR FILL-IN varweight IN FRAME Dialog-Frame
   NO-DISPLAY NO-ENABLE                                                 */
ASSIGN
       varweight:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON END-ERROR anywhere /* Информация о товарах */
DO:
  return .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON ENDKEY OF FRAME Dialog-Frame /* Информация о товарах */
DO:
  return .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Информация о товарах */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-str
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-str Dialog-Frame
ON return OF b-str IN FRAME Dialog-Frame /* Бар-код */
DO:
 define buffer bf_bar-code      for ub.bar-code.
 define buffer bf_prod-bc       for ub.prod-bc.
 define buffer bf_place         for ub.place.
 define buffer bf_goods         for ub.goods.
 define buffer bf_country       for ub.country.
 define buffer bf_clients       for ub.clients.
 define buffer bf_gds-prt       for ub.gds-prt.
 define buffer bf-main_bar-code for ub.bar-code.
 define buffer bf_curr-shop     for ub.curr-shop.
 define buffer bf_gds-obj       for ub.gds-obj.
 define buffer bf_prt-obj       for ub.prt-obj.
 define variable vardoc-num     like ub.price-doc.doc-num     no-undo.
 define variable var-price-sale like ub.price-list.price-sale no-undo.
 define variable var-road-tax   like ub.price-list.road-tax   no-undo.
 define variable var-excise     like ub.price-list.excise     no-undo.
 define variable par-type as character no-undo.
 define variable store-type like clients.obj-type no-undo.
 define variable store-code like clients.obj-code no-undo.
 define variable v-b-code   like ub.bar-code.b-code no-undo .
 define variable varhexstr            as character no-undo.
 define variable Path-To-Dir-Pictures as character no-undo .
 define variable varfile-name as character no-undo.
 define variable varstring-sum as character no-undo.
 define variable parresult   as character                no-undo.
 define variable partype-bc  as character                no-undo.
 define variable parweight   as decimal                  no-undo.

 { str/sclspref.i }
 assign
   store-type = parobj-type
   store-code = parobj-code.
 run disptoday.
 { str/get-pr.i def }
  assign
    frame {&frame-name} b-str.
 apply "entry" to b-str.
 /*закроем режиме требуещие parparentproc в bc-rczn*/
 { str/bc-rcnz.i
   ?
   b-str
   ?
   parobj-type
   parobj-code
   no
   no
   varscales-pref
   varpgscales-pref
   parresult
   partype-bc
   parweight
   bf_bar-code
   bf_prod-bc
   bf_place
   no-error
 }
 if not available bf_bar-code
 then do:
   display "Бар-код не найден" @ varartic
           "" @ vargds-name
           "" @ varfprt-name
           "не определена"  @ varprice-sale
           "" @ varunit-name
           ?  @ varcli-base-rate
           "" @ varunit-base
           ?  @ varb-code
  with frame {&frame-name}.

  display  ? @ varweight with frame {&frame-name}.
  if varr-b = "base"
  then do:
    display ?  @ varcur-price
            ?  @ varshop-rate
            with frame {&frame-name}.
  end.
  if lookup ("prod-name", vargdsscrvw) > 0
  then do:
    display "" @ varprod-name with frame {&frame-name}.
  end.
  if lookup ("grp-name", vargdsscrvw) > 0
  then do:
    display "" @ vargrp-name with frame {&frame-name}.
  end.
  if lookup ("engl-name", vargdsscrvw) > 0
  then do:
    display "" @ varengl-name with frame {&frame-name}.
  end.
  if lookup ("prod-name", vargdsscrvw) > 0
  then do:
    display "" @ varprod-name with frame {&frame-name}.
  end.
  if lookup ("alpha1", vargdsscrvw) > 0
  then do:
    display "" @ varcountry-name with frame {&frame-name}.
  end.
  if lookup ("sert", vargdsscrvw) > 0
  then do:
    display "" @ varsert with frame {&frame-name}.
  end.
  if lookup ("destin", vargdsscrvw) > 0
  then do:
    display "" @ vardestin with frame {&frame-name}.
  end.
  if lookup ("ps", vargdsscrvw) > 0
  then do:
    assign varps = "".
    display varps-label varps with frame {&frame-name}.
  end.
  if lookup ("user-rule", vargdsscrvw) > 0
  then do:
    display "" @ varuser-rule with frame {&frame-name}.
  end.
  if lookup ("struct", vargdsscrvw) > 0
  then do:
    display "" @ varsyrye with frame {&frame-name}.
  end.
  if lookup ("deadline", vargdsscrvw) > 0
  then do:
    display "" @ vardeadline with frame {&frame-name}.
  end.
  if lookup ("fact-qnty", vargdsscrvw) > 0
  then do:
    display ? @ varfact-qnty
            "" @ varunit-name-2 with frame {&frame-name}.
  end.
  if lookup ("in-date", vargdsscrvw) > 0
  then do:
    display ? @ varin-date with frame {&frame-name}.
  end.
  if lookup ("foto", vargdsscrvw) > 0
  then do:
    if search ("buyerscr.bmp") <> ?
    then do:
      if varfoto:load-image( "buyerscr.bmp" ) then.
      view varfoto in frame {&frame-name}.
    end.
    else do:
      hide varfoto in frame {&frame-name}.
    end.

  end.
  return no-apply.
 end.
 display bf_bar-code.cli-base-rate @ varcli-base-rate
         bf_bar-code.unit-cli      @ varunit-name     with frame {&frame-name}.
 find first bf_goods   where bf_goods.gds-code = bf_bar-code.gds-code no-lock.
 display bf_goods.artic     @ varartic
         bf_goods.gds-name  @ vargds-name format "x(200)"
         bf_goods.unit-base @ varunit-base
         with frame {&frame-name}.
 if lookup ("engl-name", vargdsscrvw) > 0
 then do:
   display bf_goods.engl-name @ varengl-name with frame {&frame-name}.
 end.
 if lookup ("struct", vargdsscrvw) > 0
 then do:
   display bf_goods.struct @ varsyrye with frame {&frame-name}.
 end.
 if lookup ("ps", vargdsscrvw) > 0
 then do:
   assign varps = bf_goods.ps.
   display varps-label varps with frame {&frame-name}.
 end.
 if lookup ("destin", vargdsscrvw) > 0
 then do:
   display bf_goods.destin @ vardestin with frame {&frame-name}.
 end.
 if lookup ("sert", vargdsscrvw) > 0
 then do:
   display bf_goods.sert @ varsert with frame {&frame-name}.
 end.
 if lookup ("user-rule", vargdsscrvw) > 0
 then do:
   display bf_goods.user-rule @ varuser-rule with frame {&frame-name}.
 end.
 if lookup ("deadline", vargdsscrvw) > 0
 then do:
   display bf_goods.deadline @ vardeadline with frame {&frame-name}.
 end.
 if lookup ("grp-name", vargdsscrvw) > 0
 then do:
   display bf_goods.grp-name @ vargrp-name with frame {&frame-name}.
 end.
 { gbl/gdsbcode.i
   bf_goods.gds-code
   ?
   v-b-code
 }
 find first bf-main_bar-code where bf-main_bar-code.b-code = v-b-code no-lock.
 display bf-main_bar-code.b-code @ varb-code with frame {&frame-name}.
 if lookup ("prod-name", vargdsscrvw) > 0
 then do:
   find first bf_clients where bf_clients.obj-type = bf_goods.prod-type and
                               bf_clients.obj-code = bf_goods.prod-code no-lock.
   display bf_clients.obj-name @ varprod-name with frame {&frame-name}.
 end.
 if lookup ("alpha1", vargdsscrvw) > 0
 then do:
   find first bf_country where bf_country.alpha1 = bf_goods.alpha1 no-lock no-error.
   if available bf_country
   then do:
     display bf_country.long-name @ varcountry-name with frame {&frame-name}.
   end.
   else do:
     display "не определена" @ varcountry-name with frame {&frame-name}.
   end.
 end.

 { gbl/bcodeprc.i parobj-type parobj-code bf_bar-code.b-code 0 0 vardoc-num var-price-sale var-road-tax var-excise no-error }
 if error-status:error
 or var-price-sale = ?
 then do:
   display "не определена" @ varprice-sale with frame {&frame-name}.
   if varr-b = "base"
   then do:
     display ? @ varcur-price
             ? @ varshop-rate
             "" @ varshop-scale with frame {&frame-name}.
   end.
 end.
 else do:
   if varr-b = "base"
   then do:
     find last bf_curr-shop where bf_curr-shop.obj-type  = parobj-type  and
                                  bf_curr-shop.obj-code  = parobj-code  and
                                  bf_curr-shop.curr-code = varcurr-code use-index pi no-lock no-error.
     if available bf_curr-shop
     then do:
       run rep/wp-rubl.p (input var-price-sale * bf_curr-shop.exch-rate / bf_curr-shop.exch-scale,
                     output varstring-sum) no-error.
       if error-status :error
       then do:
         display string(var-price-sale * bf_curr-shop.exch-rate / bf_curr-shop.exch-scale) @ varprice-sale
         with frame {&frame-name}.
       end.
       else do:
         display varstring-sum @ varprice-sale
         with frame {&frame-name}.
       end.
       display var-price-sale @ varcur-price
               varrate-label
               bf_curr-shop.exch-rate @ varshop-rate
               with frame {&frame-name}.
       if bf_curr-shop.exch-scale <> 1
       then do:
         display
           "за " + string(bf_curr-shop.exch-scale) @ varshop-scale with frame {&frame-name}.
       end.
       else do:
         display
           "" @ varshop-scale with frame {&frame-name}.
       end.
     end.
     else do:
       display "нет курса" @ varprice-sale
               ? @ varcur-price
               varrate-label
               ? @ varshop-rate
               ? @ varshop-scale with frame {&frame-name}.
     end.
   end.
   else do:
       run rep/wp-rubl.p
         (input var-price-sale
         ,output varstring-sum
         ) no-error.
       if error-status :error
       then do:
         display string(var-price-sale) @ varprice-sale
         with frame {&frame-name}.
       end.
       else do:
         display varstring-sum @ varprice-sale
         with frame {&frame-name}.
       end.
   end.
 end.
 if parweight <> ?
 then do:
   view varweight in frame {&frame-name}.
   display parweight @ varweight with frame {&frame-name}.
 end.
 else do:
   hide varweight in frame {&frame-name}.
 end.
 find first bf_gds-prt where bf_gds-prt.node-code = bf_bar-code.node-code no-lock.
 if bf_gds-prt.node-name <> {&empty-scale}
 then do:
   view varfprt-name varprt-label in frame {&frame-name}.
   display bf_gds-prt.f-name @ varfprt-name varprt-label with frame {&frame-name}.
 end.
 else do:
   hide varfprt-name varprt-label in frame {&frame-name}.
 end.
 if lookup ("fact-qnty",vargdsscrvw) > 0
 or lookup ("in-date",vargdsscrvw) > 0
 then do:
    find first bf_gds-obj where bf_gds-obj.obj-type  = parobj-type  and
                                bf_gds-obj.obj-code  = parobj-code  and
                                bf_gds-obj.artic     = bf_goods.artic     and
                                bf_gds-obj.prod-type = bf_goods.prod-type and
                                bf_gds-obj.prod-code = bf_goods.prod-code no-lock no-error.
    if available bf_gds-obj
    then do:
      if lookup ("fact-qnty",vargdsscrvw) > 0
      then do:
        if bf_gds-prt.node-name = {&empty-scale}
        then do:
          display bf_gds-obj.fact-qnty @ varfact-qnty with frame {&frame-name}.
        end.
        else do:
          find first bf_prt-obj where bf_prt-obj.obj-type   = bf_gds-obj.obj-type  and
                                      bf_prt-obj.obj-code   = bf_gds-obj.obj-code  and
                                      bf_prt-obj.prod-type  = bf_gds-obj.prod-type and
                                      bf_prt-obj.prod-code  = bf_gds-obj.prod-code and
                                      bf_prt-obj.artic      = bf_gds-obj.artic     and
                                      bf_prt-obj.prt-code   = bf_gds-prt.node-code no-lock.
          display bf_prt-obj.fact-qnty @ varfact-qnty with frame {&frame-name}.
        end.
        display bf_goods.unit-base   @ varunit-name-2 with frame {&frame-name}.
      end.
      if lookup ("in-date",vargdsscrvw) > 0
      then do:
        display bf_gds-obj.in-date @ varin-date with frame {&frame-name}.
      end.
    end.
    else do:
      if lookup ("fact-qnty",vargdsscrvw) > 0
      then do:
        display ? @ varfact-qnty
                "" @ varunit-name-2 with frame {&frame-name}.
      end.
      if lookup ("in-date",vargdsscrvw) > 0
      then do:
        display ? @ varin-date with frame {&frame-name}.
      end.
    end.
 end.
  if lookup ("foto",vargdsscrvw) > 0
  then do:
      /* Путь к папке изображений c текущей базы*/
      {gbl/conf-rd.i "'ph-dir':u" "'':u" "'':u" 0 "'':u" "'':u" "'':u" NO vPar-val vPar-type no-error}
     
     if vPar-val = "" then vPar-Val = "C:\temp". else vPar-Val = vPar-Val.  
     
      /*смотрим схему хранения изображения (общая или по товарам)*/ 
      run adm/shattri.p (
        input "get":U
        ,input  '':U /*p-obj-type*/
        ,input  0 /*p-obj-code*/
        ,input  {&attr-gds-ref}
        ,input  {&attr-gds-ref_shema-foto} /*p-param-code*/
        ,output v-value-char
        ,output v-val-date
        ,output v-val-decimal
        ,output v-val-integer /*1 - общая директория; 2 по товарам*/
        ,output v-val-logical
        ,output v-param-types
        ,INPUT-OUTPUT table-handle v-tthd
        ) no-error.
      delete object v-tthd.

/*определяем путь где лежит картинка*/
      run gds-attr-value in this-procedure (
        input bf_goods.gds-code
        ,input "image-list"
        ,output v-value
        ,output v-type) no-error.

      if v-value <> "" then 
      do: /* есть атрибут */
        if v-val-integer = 1 then 
        do:
          Path-To-Dir-Pictures = vPar-val + "\gds\" + entry(1,v-value).
        end.
        else 
        do:
          Path-To-Dir-Pictures = vPar-val + "\gds\" + string(bf_goods.gds-code) + "\" + entry(1,v-value).
        end. 
        
        if varfoto:load-image( Path-To-Dir-Pictures ) then.
        view varfoto in frame {&frame-name}. 
      end. /*if v-value <> "" then*/
      else do:
            if search ("cmp/buyerscr.bmp") <> ?
            then do:
              if varfoto:load-image( "cmp/buyerscr.bmp" ) then.
              view varfoto in frame {&frame-name}.
            end.
            else do:
              hide varfoto in frame {&frame-name}.
            end.
          end.
       end.

return no-apply.

END.

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
  /* no_app_help.i  */
  { gbl/conf-rd.i
    "'is-byscr':U"
    0
    "'':U"
    0
    "'':U"
    "'':U"
    "'':U"
    false
    is-byscrvalue
    is-byscrtype
    no-error
  }
  if error-status :error
  or is-byscrvalue <> "yes"
  then do:
    message
      "У Вас нет лицензии на работу с Экраном покупателя" skip
      "Конфигурационный параметр" 'is-byscr':U skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error.
    undo, return error return-value .
  end.

  { gbl/conf-rd.i
    "'numbyscr':U"
    0
    "'':U"
    0
    "'':U"
    "'':U"
    "'':U"
    false
    numbyscrvalue
    numbyscrtype
    no-error
  }
  if error-status :error
  then do:
    message
      "У Вас нет лицензии на работу с Экраном покупателя" skip
      "Ошибка при чтении параметра" 'numbyscr':U skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  run integerm in this-procedure
    (input  numbyscrvalue     /* p-string      */
    ,input  false             /* p-allow-sign  */
    ,input  false             /* p-allow-comma */
    ,output numbyscrvalue_int /* p-value       */
    ,output v-data-valid      /* p-data-valid  */
    ,output v-error-message   /* p-message     */
    ) .

  if v-data-valid <> true
  then do:
    message
      "У Вас нет лицензии на работу с Экраном покупателя" skip
      "Ошибка при разборе значения параметра" 'numbyscr':U skip
      "Значение параметра" numbyscrvalue skip
      v-error-message skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  run gbl/lock-usr.p
    (input  "test"   /* код пользователя */
    ,input  "buy"    /* код ресурса */
    ,input  true     /* показывать сообщение об ошибке */
    ,input  "Достигнуто максимальное количество пользователей &1"   /* сообщение об ошибке */
    ,input  numbyscrvalue_int        /* максимальное количество пользователей */
    ,buffer buf_batchprocess
    ) no-error.
  if error-status :error
  then do:
    undo, return error return-value .
  end.

  run disptoday.

  { gbl/curr-r-b.i
    varr-b
    no-error
  }

 if parobj-type = {&stock}
 then do:
      find first bf_store where bf_store.obj-code = parobj-code no-lock.
      find first bf_sysconf where bf_sysconf.host-code = bf_store.host-code no-lock.
 end.
 else do:
   if parobj-type = {&shop}
   then do:
      find first bf_shop where bf_shop.obj-code = parobj-code no-lock.
      find first bf_sysconf where bf_sysconf.host-code = bf_shop.host-code no-lock.
   end.
   else do:
     message "Экран работает только для объектов типа склад или магазин." view-as alert-box error.
     return error.
   end.
 end.
 assign
      varcurr-code = bf_sysconf.base-code.
  find first bf_currency where bf_currency.curr-code = varcurr-code no-lock.
  assign
    varr-b-abbr = bf_currency.curr-abbr.

  define variable v-param-type as character no-undo .
  define variable v-value-date as date no-undo .
  define variable v-value-decimal as decimal no-undo .
  define variable v-value-integer as INTEGER no-undo .
  define variable v-value-logical AS LOGICAL no-undo .
  define variable v-tth as handle no-undo .

  run adm/shattri.p (
      input "get":U
      ,input  parobj-type
      ,input  parobj-code
      ,input  {&attr-gds-ref_obj}
      ,input  {&attr-gds-ref_obj_gdsscrvw} /*p-param-code*/
      ,output vargdsscrvw
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .

  delete object v-tth.

  RUN enable_UI.
  if varr-b = "base"
  then do:
    view varcur-price varr-b-abbr varshop-rate varshop-scale in frame {&frame-name}.
    display varr-b-abbr with frame {&frame-name}.
  end.
  if lookup ("goods.grp-name", vargdsscrvw) > 0
  then do:
    view vargrp-name in frame {&frame-name}.
  end.
  if lookup ("goods.engl-name", vargdsscrvw) > 0
  then do:
    view varengl-name in frame {&frame-name}.
  end.
  if lookup ("goods.#prod-name", vargdsscrvw) > 0
  then do:
    view varprod-name in frame {&frame-name}.
  end.
  if lookup ("goods.alpha1", vargdsscrvw) > 0
  then do:
    view varcountry-name in frame {&frame-name}.
  end.
  if lookup ("goods.sert", vargdsscrvw) > 0
  then do:
    view varsert in frame {&frame-name}.
  end.
  if lookup ("goods.destin", vargdsscrvw) > 0
  then do:
    view vardestin in frame {&frame-name}.
  end.
  if lookup ("goods.ps", vargdsscrvw) > 0
  then do:
    view varps varps-label in frame {&frame-name}.
  end.
  if lookup ("goods.user-rule", vargdsscrvw) > 0
  then do:
    view varuser-rule in frame {&frame-name}.
  end.
  if lookup ("goods.struct", vargdsscrvw) > 0
  then do:
    view varsyrye in frame {&frame-name}.
  end.
  if lookup ("goods.deadline", vargdsscrvw) > 0
  then do:
    view vardeadline in frame {&frame-name}.
  end.
  if lookup ("gds-obj.fact-qnty", vargdsscrvw) > 0
  then do:
    view varfact-qnty in frame {&frame-name}.
  end.
  if lookup ("gds-obj.in-date", vargdsscrvw) > 0
  then do:
    view varin-date in frame {&frame-name}.
  end.
  if search ("buyerscr.bmp") <> ?
  then do:
    if varfoto:load-image( "buyerscr.bmp" ) then.
    view varfoto in frame {&frame-name}.
  end.


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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disptoday Dialog-Frame
PROCEDURE disptoday :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
 define variable varnamemonth as character no-undo.
 run gbl/num-monr.p (input month(today), output varnamemonth).
 assign
   vartoday = string(day(today)) + " " + lc(varnamemonth) + " " +  string(year(today)) + "г.".
 display vartoday with frame {&frame-name}.
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
  DISPLAY b-str vartoday vargds-label vargds-name varfprt-name varprice-label
          varprice-sale varunit-name varskobka-1 varcli-base-rate varunit-base
          varskobka-2 varunit-name-2 varartic varb-code
      WITH FRAME Dialog-Frame.
  ENABLE RECT-1 RECT-5 b-str varps
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME