&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS s-object 
&Scoped-define doc-types ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Кирюхин Сергей
Дата создания: 03/09/12
Author: SKiryxin
Creation date: 03/09/12

*/

using Progress.Lang.*.
using Ibs.Th.Gbl.Rep-Out.
using ibs.th.bge.egais.extgds.
using ibs.th.bge.egais.extFormF1.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i  }
{ cmp/str-glbl.i  }
{ cmp/r-page1.i   }
{ rep/rep-bt.i    }
{ trg/factord.i   } /* Узнать по дате начала и конца периода соответствующий fact-order */
{ gbl/waitfram.i  } 
{ str/trdcalib.i  } /* Атрибуты */
{ trg/partslib.i  } /* Для остатков */
{ rep/fmtcli.i    } /* Для инн, кпп, адреса и т.п. */
{ gbl/clntattr.i }
{ gbl/thbjattr.i }
{ ref/extclass.i }

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable g#log as logical   no-undo .
define variable alc-producers_recids as character no-undo.
define variable alc-suppliers_recids as character no-undo.
define variable alc-types_recids as character no-undo.
define variable ii as integer no-undo.
define variable l-ok as logical no-undo.
define variable quarter              as integer   no-undo. /* 3, 6, 9, 0 (как я понимаю в соотв. с посл. месяцем) (так в XSD схеме) */

/* Для первой страницы */

define variable firm-post-code    as character no-undo.
define variable firm-reg-code     as character no-undo.
define variable firm-district     as character no-undo.
define variable firm-city         as character no-undo.
define variable firm-settlement       as character no-undo.
define variable firm-street       as character no-undo.
define variable firm-house-number as character no-undo.
define variable firm-house-litera     as character no-undo.
define variable firm-house-case       as character no-undo.
define variable firm-house-apartment  as character no-undo.
define variable firm-director-f       as character no-undo.
define variable firm-director-i       as character no-undo.
define variable firm-director-o       as character no-undo.
define variable firm-accountant-f     as character no-undo.
define variable firm-accountant-i     as character no-undo.
define variable firm-accountant-o     as character no-undo.
define variable firm-e-mail      as character no-undo.
define variable firm-country-code     as character no-undo.

define variable v-value-character   as character no-undo .
define variable v-value-decimal     as decimal   no-undo .
define variable v-value-integer     as integer   no-undo .
define variable v-value-logical     as logical   no-undo .
define variable v-value-type        as character no-undo .
define variable v-value-date        as date      no-undo .
define variable v-ext-sys           as integer   no-undo .

define variable v-kpp               as character no-undo .
define variable v-inner-code        as integer   no-undo .

define variable ext-cl              as class extgds no-undo .
define variable ext-FormF1          as class extFormF1 no-undo .

/* (остальное определено в rep/fmtcli.i) */

/* Table Definitions ---                                                */
define temp-table alc-producers      /* Для выбранных производителей */
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.

define temp-table alc-suppliers      /* Для выбранных поставщиков */
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.

define temp-table alc-types      /* Для выбранных типов */
    field type-code     like ub.alc-type.alc-type-inner-code
    field alc-type-name like ub.alc-type.alc-type-name
    field alc-type-code like ub.alc-type.alc-type-code
    index pi is unique primary type-code.

define temp-table alc-goods      /* Для товаров */
    field gds-code  like ub.alc-type-gds.gds-code
    field artic     like ub.goods.artic
    field prod-type like ub.goods.prod-type
    field prod-code like ub.goods.prod-code
    field alpha1    like ub.goods.alpha1
    field type-code like ub.alc-type-gds.alc-type-inner-code
    field vol       like ub.goods.ms-base
    index pi is unique primary gds-code.

define temp-table page-2    /* Страница 2 */
    field obj-type          like ub.clients.obj-type
    field obj-code          like ub.clients.obj-code
    field obj-name          like ub.clients.obj-name
    field country-code      as   character 
    field kpp               like ub.firm.kpp
    field post-code         as   character
    field reg-code          as   character
    field district          as   character
    field city              as   character
    field settlement        as   character
    field street            as   character
    field house-number      as   character    
    field house-litera      as   character
    field house-case        as   character
    field apartment         as   character
    index pi is unique primary obj-type obj-code.

define temp-table part-1    /* Раздел I */
    field prod-code         like ub.goods.prod-code               /* Производитель/импортер  pi */
    field prod-type         like ub.goods.prod-type               /* Производитель/импортер  pi */
    field type-code         like ub.alc-type.alc-type-inner-code  /* Внутренний код алкоголя pi */
    field foreign           as logical                            /* Импортный производитель    */
    field obj-type          like ub.clients.obj-type              /* Объект pi */
    field obj-code          like ub.clients.obj-code              /* Объект pi */
    field obj-kpp           like ub.firm.kpp                      /* КПП объекта */
    field alc-type-name     like ub.alc-type.alc-type-name /* 1 */
    field alc-type-code     like ub.alc-type.alc-type-code /* 2 */
    field producer-obj-name like ub.clients.obj-name       /* 3 */
    field producer-inn      like ub.firm.inn               /* 4 */
    field producer-kpp      like ub.firm.kpp               /* 5 */
    field remain-6          as decimal decimals 5          /* 6 */
    field inc-7             as decimal decimals 5          /* 7 */
    field inc-8             as decimal decimals 5          /* 8 */
    field inc-9             as decimal decimals 5          /* 9 */
    field inc-10            as decimal decimals 5          /* 10 */
    field inc-11            as decimal decimals 5          /* 11 */
    field inc-12            as decimal decimals 5          /* 12 */
    field inc-13            as decimal decimals 5          /* 13 */
    field inc-14            as decimal decimals 5          /* 14 */
    field exp-15            as decimal decimals 5          /* 15 */
    field exp-16            as decimal decimals 5          /* 16 */
    field exp-17            as decimal decimals 5          /* 17 */
    field exp-18            as decimal decimals 5          /* 18 */
    field exp-19            as decimal decimals 5          /* 19 */
    field remain-20         as decimal decimals 5          /* 20 */
    index pi is unique primary type-code prod-code prod-type obj-type obj-code
    index producer-obj-name producer-obj-name.

define temp-table part-2    /* Раздел II */
    field obj-type                   like ub.clients.obj-type         /* Объект pi */
    field obj-code                   like ub.clients.obj-code         /* Объект pi */
    field obj-kpp                    like ub.firm.kpp                 /* КПП объекта */
    field prod-code                  like ub.goods.prod-code          /* Производитель/импортер */
    field prod-type                  like ub.goods.prod-type          /* Производитель/импортер */
    field supplier-code              like ub.goods.prod-code          /* Поставщик */
    field supplier-type              like ub.goods.prod-type          /* Поставщик */    
    field alc-type-name              like ub.alc-type.alc-type-name   /* 1 */
    field alc-type-code              like ub.alc-type.alc-type-code   /* 2 */
    field producer-obj-name          like ub.clients.obj-name         /* 3 */
    field producer-inn               like ub.firm.inn                 /* 4 */
    field producer-kpp               like ub.firm.kpp                 /* 5 */
    field supplier-obj-name          like ub.clients.obj-name         /* 6 */
    field supplier-inn               like ub.firm.inn                 /* 7 */
    field supplier-kpp               like ub.firm.kpp                 /* 8 */
    field supplier-serial-number     as character                     /* 9 */
    field supplier-date-get          as character                     /* 10 */
    field supplier-date-to           as character                     /* 11 */
    field supplier-get-from          like ub.alc-sale-lic.who-are-got /* 12 */
    field purchase-date              as date                          /* 13 */
    field GTD                        like ub.parts.cst-code           /* 14 */
    field TTN                        as character                     /* 15 */
    field total                      as decimal                       /* 16 */
    index obj-date-sort obj-type obj-code purchase-date
    index alc-sort alc-type-code
    index licenses supplier-serial-number.


define temp-table tt-parts-info
    field obj-type          like ub.clients.obj-type         /* Объект pi */
    field obj-code          like ub.clients.obj-code 
    field part-code         like ub.parts.part-code
    field out-code          like ub.parts.out-code
    field in-code           like ub.parts.in-code
    field artic             like ub.goods.artic
    field alc-code          as character
    field prod-type         like ub.goods.prod-type 
    field prod-code         like ub.goods.prod-code
    field alc-type-code     like ub.alc-type.alc-type-code
    field producer-obj-name like ub.clients.obj-name       /* 3 */
    field producer-inn      like ub.firm.inn               /* 4 */
    field producer-kpp      like ub.firm.kpp               /* 5 */
    field remain-6          as   decimal decimals 5        /* 6 */
    field inc-7             as   decimal decimals 5        /* 7 */
    field inc-8             as   decimal decimals 5        /* 8 */
    field inc-9             as   decimal decimals 5        /* 9 */
    field inc-10            as   decimal decimals 5        /* 10 */
    field inc-11            as   decimal decimals 5        /* 11 */
    field inc-12            as   decimal decimals 5        /* 12 */
    field inc-13            as   decimal decimals 5        /* 13 */
    field inc-14            as   decimal decimals 5        /* 14 */
    field exp-15            as   decimal decimals 5        /* 15 */
    field exp-16            as   decimal decimals 5        /* 16 */
    field exp-17            as   decimal decimals 5        /* 17 */
    field exp-18            as   decimal decimals 5        /* 18 */
    field exp-19            as   decimal decimals 5        /* 19 */
    field remain-20         as   decimal decimals 5        /* 20 */
    field importer          as   character
    index pi as primary unique
        obj-type obj-code artic prod-type prod-code in-code out-code part-code
.

define stream OutStr-html.
{ gbl/prn-lib.i  }

define stream logStr.
define variable v-inn-err as logical no-undo .
     
/* Buffer Definitions   ---                                               */

define buffer buf_clients           for ub.clients.
define buffer buf_alc-type          for ub.alc-type.
define buffer buf_alc-type-attr     for ub.alc-type-attr.
define buffer buf_clients-attr      for ub.clients-attr.
define buffer buf_alc-type-gds      for ub.alc-type-gds.
define buffer buf_goods             for ub.goods.
define buffer buf_trn-doc           for ub.trn-doc.
define buffer buf_doc-line          for ub.doc-line.
define buffer buf_parts             for ub.parts.
define buffer buf_firm              for ub.firm.
define buffer buf_alc-supp-lic      for ub.alc-supp-lic.
define buffer buf_person            for ub.person.
define buffer buf_alc-sale-lic      for ub.alc-sale-lic.
define buffer buf_sysconf           for ub.sysconf.
define buffer buf_part-2            for part-2.
define buffer x_ext-classif         for ub.ext-classif.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-13 RADIO-SET-ver FILL-IN-kor ~
RADIO-SET-form RADIO-ALC-PRODUCER EDITOR-ALC-PRODUCER RADIO-SUPPLIER ~
EDITOR-SUPPLIER RADIO-ALC-TYPE EDITOR-ALC-TYPE TOGGLE-Excel TOGGLE-XML TOGGLE-KPP 
&Scoped-Define DISPLAYED-OBJECTS RADIO-SET-ver FILL-IN-kor RADIO-SET-form ~
RADIO-ALC-PRODUCER EDITOR-ALC-PRODUCER RADIO-SUPPLIER EDITOR-SUPPLIER ~
RADIO-ALC-TYPE EDITOR-ALC-TYPE TOGGLE-Excel TOGGLE-XML TOGGLE-KPP 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE EDITOR-ALC-PRODUCER AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 50 BY 2.62 NO-UNDO.

DEFINE VARIABLE EDITOR-ALC-TYPE AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 50 BY 2.62 NO-UNDO.

DEFINE VARIABLE EDITOR-SUPPLIER AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 50 BY 2.62 NO-UNDO.

DEFINE VARIABLE FILL-IN-kor AS INTEGER FORMAT ">>9":U 
     LABEL "№ кор" 
     VIEW-AS FILL-IN 
     SIZE 5 BY 1 NO-UNDO.

DEFINE VARIABLE RADIO-ALC-PRODUCER AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", 1,
"Выборочно", 2
     SIZE 16 BY 2.38 NO-UNDO.

DEFINE VARIABLE RADIO-ALC-TYPE AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", 1,
"Выборочно", 2
     SIZE 16 BY 2.38 NO-UNDO.

DEFINE VARIABLE RADIO-SET-form AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Первичная", 1,
"Корректирующая", 2
     SIZE 41 BY .95 NO-UNDO.

DEFINE VARIABLE RADIO-SET-ver AS INTEGER 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "4.31", 1,
          "4.30", 3,
"4.20", 2
     SIZE 20 BY .95 NO-UNDO.

DEFINE VARIABLE RADIO-SUPPLIER AS INTEGER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Все", 1,
"Выборочно", 2
     SIZE 16 BY 2.38 NO-UNDO.

DEFINE RECTANGLE RECT-13
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL   
     SIZE 72 BY 18.

DEFINE VARIABLE TOGGLE-Excel AS LOGICAL INITIAL yes 
     LABEL "Excel" 
     VIEW-AS TOGGLE-BOX
     SIZE 10 BY .81 NO-UNDO.

DEFINE VARIABLE TOGGLE-XML AS LOGICAL INITIAL yes 
     LABEL "XML" 
     VIEW-AS TOGGLE-BOX
     SIZE 9 BY .81 NO-UNDO.
     
DEFINE VARIABLE TOGGLE-KPP AS LOGICAL INITIAL no 
     LABEL "Объединять данные по объектам с одинаковым КПП" 
     VIEW-AS TOGGLE-BOX
     SIZE 50 BY .81 NO-UNDO.     


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     RADIO-SET-ver AT ROW 1.62 COL 13 NO-LABEL WIDGET-ID 58
     FILL-IN-kor AT ROW 2.43 COL 65 COLON-ALIGNED WIDGET-ID 70
     RADIO-SET-form AT ROW 2.5 COL 13 NO-LABEL WIDGET-ID 66
     RADIO-ALC-PRODUCER AT ROW 4.81 COL 4 NO-LABEL WIDGET-ID 26
     EDITOR-ALC-PRODUCER AT ROW 4.81 COL 22 NO-LABEL WIDGET-ID 32
     RADIO-SUPPLIER AT ROW 8.86 COL 4 NO-LABEL WIDGET-ID 50
     EDITOR-SUPPLIER AT ROW 8.86 COL 22 NO-LABEL WIDGET-ID 40
     RADIO-ALC-TYPE AT ROW 12.67 COL 4 NO-LABEL WIDGET-ID 44
     EDITOR-ALC-TYPE AT ROW 12.67 COL 22 NO-LABEL WIDGET-ID 42
     TOGGLE-Excel AT ROW 15.76 COL 33 WIDGET-ID 52
     TOGGLE-XML AT ROW 15.76 COL 44 WIDGET-ID 54
     TOGGLE-KPP AT ROW 17 COL 4 WIDGET-ID 80
     "Выбор поставщика" VIEW-AS TEXT
          SIZE 23 BY .62 AT ROW 8.14 COL 4 WIDGET-ID 34
          FGCOLOR 4 
     "Форма" VIEW-AS TEXT
          SIZE 9 BY .62 AT ROW 2.67 COL 4 WIDGET-ID 64
          FGCOLOR 4 
     "Версия" VIEW-AS TEXT
          SIZE 9 BY .62 AT ROW 1.71 COL 4 WIDGET-ID 62
          FGCOLOR 4 
     "Выбор вида алкогольной продукции" VIEW-AS TEXT
          SIZE 38 BY .62 AT ROW 11.95 COL 4 WIDGET-ID 48
          FGCOLOR 4 
     "Выбор производителя" VIEW-AS TEXT
          SIZE 23 BY .62 AT ROW 3.86 COL 4 WIDGET-ID 30
          FGCOLOR 4 
     "Вывести отчет в формате:" VIEW-AS TEXT
          SIZE 28 BY .71 AT ROW 15.86 COL 4 WIDGET-ID 56
     RECT-13 AT ROW 1.29 COL 2 WIDGET-ID 18
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY 
         SIDE-LABELS NO-UNDERLINE THREE-D 
         AT COL 1 ROW 1 SCROLLABLE 
         BGCOLOR 8 .


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
  CREATE WINDOW s-object ASSIGN
         HEIGHT             = 16.76
         WIDTH              = 75.
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
       FRAME F-Main:HIDDEN           = TRUE
       FRAME F-Main:PRIVATE-DATA     = 
                "DLGCLOSE".

ASSIGN 
       EDITOR-ALC-PRODUCER:READ-ONLY IN FRAME F-Main        = TRUE.

ASSIGN 
       EDITOR-ALC-TYPE:READ-ONLY IN FRAME F-Main        = TRUE.

ASSIGN 
       EDITOR-SUPPLIER:READ-ONLY IN FRAME F-Main        = TRUE.

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

&Scoped-define SELF-NAME RADIO-ALC-PRODUCER
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-ALC-PRODUCER s-object
ON VALUE-CHANGED OF RADIO-ALC-PRODUCER IN FRAME F-Main
DO:
    assign RADIO-ALC-PRODUCER.                          /* Получим текущее значение */
    
    for each alc-producers: 
        delete alc-producers. 
    end. /* Очистим таблицу выбранных производителей */
    
    case RADIO-ALC-PRODUCER:

       when 1 then do:
           assign  EDITOR-ALC-PRODUCER = "По всем производителям".
           display EDITOR-ALC-PRODUCER with frame {&FRAME-NAME}.
       end. /* when 1 */

       when 2 then do:
           run ref/cli-all.w ( my-handle
                        , "b-sel,b-mark"
                        , {&cmp}
                        , {&all}
                        , ?
                        , ?
                        , ",,,,,,NO,,"
                        , ?
                        , output alc-producers_recids).
           
           if alc-producers_recids = "" then do:
                assign  EDITOR-ALC-PRODUCER = "По всем производителям" RADIO-ALC-PRODUCER = 1.
                display EDITOR-ALC-PRODUCER RADIO-ALC-PRODUCER with frame {&FRAME-NAME}.
           end.
           
           else do:
               assign  EDITOR-ALC-PRODUCER = ''.
               do ii = 1 to num-entries( alc-producers_recids ):
                   find first buf_clients where recid( buf_clients ) = int(entry( ii, alc-producers_recids )) no-lock no-error.
                     if available buf_clients then do:
                         create alc-producers.
                         assign
                           alc-producers.obj-type = buf_clients.obj-type
                           alc-producers.obj-code = buf_clients.obj-code
                           alc-producers.obj-name = buf_clients.obj-name.
                           EDITOR-ALC-PRODUCER = EDITOR-ALC-PRODUCER + alc-producers.obj-name + chr(10).
                     end. /* if available buf_clients */
               end. /* do ii = 1 to num-entries */
                display EDITOR-ALC-PRODUCER with frame {&FRAME-NAME} .
           end. /* else do */
       end. /* when 2 */
    end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-ALC-TYPE
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-ALC-TYPE s-object
ON VALUE-CHANGED OF RADIO-ALC-TYPE IN FRAME F-Main
DO:
    assign RADIO-ALC-TYPE.                          /* Получим текущее значение */
    for each alc-types : delete alc-types. end.     /* Очистим таблицу выбранных типов */
    case RADIO-ALC-TYPE:

       when 1 then do:
           assign  EDITOR-ALC-TYPE = "По всем типам продукции".
           display EDITOR-ALC-TYPE with frame {&FRAME-NAME}.
       end. /* when 1 */
       
       when 2 then do:
           run ref/alc-type.w ( my-handle
                              , "b-sel,b-mark,alc-p"
                              , input-output alc-types_recids
                              , output l-ok).
           if alc-types_recids = "" then do:
                assign  EDITOR-ALC-TYPE = "По всем типам продукции" RADIO-ALC-TYPE = 1.
                display EDITOR-ALC-TYPE RADIO-ALC-TYPE with frame {&FRAME-NAME}.
           end.
           else do:
               /* Сначала очистим */
               for each alc-types exclusive-lock:
                   delete alc-types.
               end.
               
               assign  EDITOR-ALC-TYPE = ''.
               do ii = 1 to num-entries(alc-types_recids):
                   find first buf_alc-type where recid( buf_alc-type ) = int(entry( ii, alc-types_recids)) no-lock no-error.
                     if available buf_alc-type then do:
                         create alc-types.
                         assign
                           alc-types.type-code     = buf_alc-type.alc-type-inner-code
                           alc-types.alc-type-name = buf_alc-type.alc-type-name
                           alc-types.alc-type-code = buf_alc-type.alc-type-code
                           EDITOR-ALC-TYPE = EDITOR-ALC-TYPE + alc-types.alc-type-name + chr(10).
                     end. /* if available buf_alc-type */
               end. /* do ii = 1 to num-entries */
                display EDITOR-ALC-TYPE with frame {&FRAME-NAME} .
           end. /* else do */
       end. /* when 2 */
    end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME RADIO-SUPPLIER
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SUPPLIER s-object
ON VALUE-CHANGED OF RADIO-SUPPLIER IN FRAME F-Main
DO:
    assign RADIO-SUPPLIER.                          /* Получим текущее значение */
    
    for each alc-suppliers: 
        delete alc-suppliers. 
    end. /* Очистим таблицу выбранных поставщиков */
    
    case RADIO-SUPPLIER:

       when 1 then do:
           assign  EDITOR-SUPPLIER = "По всем поставщикам".
           display EDITOR-SUPPLIER with frame {&FRAME-NAME}.
       end. /* when 1 */

       when 2 then do:
           run ref/cli-all.w ( my-handle
                        , "b-sel,b-mark"
                        , {&cmp}
                        , {&all}
                        , ?
                        , ?
                        , ",,,,,,NO,,"
                        , ?
                        , output alc-suppliers_recids).
           
           if alc-suppliers_recids = "" then do:
                assign  EDITOR-SUPPLIER = "По всем поставщикам" RADIO-SUPPLIER = 1.
                display EDITOR-SUPPLIER RADIO-SUPPLIER with frame {&FRAME-NAME}.
           end.
            
           else do:
               assign  EDITOR-SUPPLIER = ''.
               do ii = 1 to num-entries( alc-suppliers_recids ):
                   find first buf_clients where recid( buf_clients ) = int(entry( ii, alc-suppliers_recids )) no-lock no-error.
                     if available buf_clients then do:
                         create alc-suppliers.
                         assign
                           alc-suppliers.obj-type = buf_clients.obj-type
                           alc-suppliers.obj-code = buf_clients.obj-code
                           alc-suppliers.obj-name = buf_clients.obj-name
                           EDITOR-SUPPLIER = EDITOR-SUPPLIER + alc-suppliers.obj-name + chr(10).
                end. /* if available buf_clients */
            end. /* do ii = 1 to num-entries */
                display EDITOR-SUPPLIER with frame {&FRAME-NAME} .
            end. /* else do */
       end. /* when 2 */
    end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME RADIO-SET-form
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL RADIO-SET-form s-object
ON VALUE-CHANGED OF RADIO-SET-form IN FRAME F-Main
DO:
    assign RADIO-SET-form.  /* Получим текущее значение */
    case RADIO-SET-form:
        when 1 then
            assign FILL-IN-kor:hidden in frame {&FRAME-NAME} = true.
        when 2 then
            assign FILL-IN-kor:hidden in frame {&FRAME-NAME} = false.
    end case.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK s-object 


/* ***************************  Main Block  *************************** */
{ gbl/personly.i }
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-report s-object 
PROCEDURE my-report :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  процедуры отчета с любыми параметрами
------------------------------------------------------------------------------*/
define variable fact-order-start as decimal   no-undo.
define variable fact-order-end   as decimal   no-undo.
define variable wait-message     as character no-undo.
define variable imp-or-prod-type as character no-undo. /* Тот, кто в третьей колонке */
define variable imp-or-prod-code as integer   no-undo. /* Тот, кто в третьей колонке */
define variable v-attr-val       as character no-undo.
define variable v-attr-type      as character no-undo.

/* Сначала обработаем кнопки */

assign frame {&FRAME-NAME} RADIO-ALC-PRODUCER RADIO-ALC-TYPE RADIO-SUPPLIER TOGGLE-Excel
    TOGGLE-XML TOGGLE-KPP RADIO-SET-ver RADIO-SET-form FILL-IN-kor.

for each part-1 exclusive-lock:
    delete part-1.
end.

for each part-1 exclusive-lock:
    delete part-2.
end.

/* Даты в fact-order (проверим, квартал ли, если нет, то покажем сообщение.) */

quarter = 1.
l-ok = yes.

if day(x-date-start) = 1 and month(x-date-end + 1) <> month(x-date-end) then do:

    if month(x-date-start) = 1  and month(x-date-end) = 3  then quarter = 3.
    if month(x-date-start) = 4  and month(x-date-end) = 6  then quarter = 6.
    if month(x-date-start) = 7  and month(x-date-end) = 9  then quarter = 9.
    if month(x-date-start) = 10 and month(x-date-end) = 12 then quarter = 0.
end.

if quarter = 1 then message "Даты не совпадают с кварталом" skip "Продолжить?" view-as alert-box buttons yes-no update l-OK.
if l-ok = no then return.

run day-begin-fact-order(input x-date-start, output fact-order-start).
run factord-end-day(input x-date-end, output fact-order-end).

/* Производитель */

if RADIO-ALC-PRODUCER = 2 then do:
    /* Уберем из выбранных не производителей алкоголя */
    for each alc-producers exclusive-lock :
        find first buf_clients-attr no-lock where buf_clients-attr.obj-code = alc-producers.obj-code
                                              and buf_clients-attr.obj-type = alc-producers.obj-type
                                              and buf_clients-attr.attr-code = {&attr-cli-alc-producer} no-error.
        if not available (buf_clients-attr) then delete alc-producers.
    end.
    end.

/*/* Поставщик */                        */
/*                                       */
/*case RADIO-SUPPLIER:                   */
/*                                       */
/*    when 1 then do:                    */
/*                                       */
/*    end.                               */
/*                                       */
/*    when 2 then do:                    */
/*                                       */
/*    end.                               */
/*end case.                              */
/*                                       */

/* Формат вывода */

if TOGGLE-Excel = no and TOGGLE-XML = no then do:
    message "Выберите формат вывода" view-as alert-box warning buttons ok.
    return.
end.

/* Типы продукции */

case RADIO-ALC-TYPE:

    when 1 then do: /* Убрать бы пивные */

/*        message "Выберите нужные виды продукции" view-as alert-box warning buttons ok.*/
/*        return.                                                                       */

/*        /* Сначала очистим */                                         */
        for each alc-types exclusive-lock:
            delete alc-types.
        end.

        for each buf_alc-type,
            first buf_alc-type-attr where buf_alc-type-attr.attr-code = "alc-type"
                                     and buf_alc-type-attr.attr-value = "2"
                                     and buf_alc-type-attr.alc-type-inner-code = buf_alc-type.alc-type-inner-code
                                     :
            create alc-types.
            assign
            alc-types.type-code     = buf_alc-type.alc-type-inner-code
            alc-types.alc-type-name = buf_alc-type.alc-type-name
            alc-types.alc-type-code = buf_alc-type.alc-type-code.
        end.
    
    end.

/*    when 2 then do: /* Уберем пивные */*/
/*                                       */
/*    end.                               */
end case.
/*                                       */
/*/* Объекты */                          */
/*                                       */
/*for each obj-list exclusive-lock:      */
/*                                       */
/*end.                                   */

/* Товары */

case x-SelectGood:
    when {&g-all} then do:
        
        for each alc-goods exclusive-lock:
            delete alc-goods.
        end.
        
      for each alc-types no-lock:
        
        for each buf_alc-type-gds no-lock   /* Только по нужному типу алкоголя */
                                  where buf_alc-type-gds.alc-type-inner-code = alc-types.type-code: 
            for first buf_goods no-lock where buf_goods.gds-code = buf_alc-type-gds.gds-code 
                                        and buf_goods.stts = 0: /* Смотрим, что не удаленный */
                
                /* Если только по выбранному производителю */
                if RADIO-ALC-PRODUCER = 2 and
                not can-find(first alc-producers where alc-producers.obj-type = buf_goods.prod-type
                                                   and alc-producers.obj-code = buf_goods.prod-code)
                then next.
                
                create alc-goods.
                assign
                alc-goods.gds-code  = buf_alc-type-gds.gds-code
                alc-goods.type-code = buf_alc-type-gds.alc-type-inner-code
                alc-goods.artic     = buf_goods.artic
                alc-goods.prod-type = buf_goods.prod-type
                alc-goods.prod-code = buf_goods.prod-code
                alc-goods.alpha1    = buf_goods.alpha1
                alc-goods.vol       = buf_goods.ms-base.
            end.  /* for first buf_goods */
        end. /* for each buf_alc-type-gds */
      end. /* for each alc-types */
    end. /* when {&g-all} */
end case.

/* Заполним первую страницу */

for first buf_clients no-lock where buf_clients.obj-code = v-cntxt-host-code-obj
                              and   buf_clients.obj-type = {&cmp}:
  run fmtcli-get-client in this-procedure ( input buf_clients.obj-type, input  buf_clients.obj-code ). /* Получим информацию по организации */
end. /* for first buf_clients */

for first buf_clients-attr no-lock where buf_clients-attr.obj-type = {&cmp} 
                                   and   buf_clients-attr.obj-code = v-cntxt-host-code-obj
                                   and   buf_clients-attr.attr-code = {&attr-requisite-alc-decl}:
    assign
        v-fmtcli-name         = entry( 1, buf_clients-attr.attr-value, "|")
        firm-country-code     = entry( 3, buf_clients-attr.attr-value, "|")
    	firm-post-code    = entry( 4, buf_clients-attr.attr-value, "|")
    	firm-reg-code     = entry( 5, buf_clients-attr.attr-value, "|")
    	firm-district     = entry( 6, buf_clients-attr.attr-value, "|")
        firm-city             = entry( 7, buf_clients-attr.attr-value, "|") 
        firm-settlement       = entry( 8, buf_clients-attr.attr-value, "|")
    	firm-street       = entry( 9, buf_clients-attr.attr-value, "|")
        firm-house-number     = entry (10,buf_clients-attr.attr-value,"|")
        firm-house-case       = entry (11,buf_clients-attr.attr-value,"|")
        firm-house-apartment = entry (12,buf_clients-attr.attr-value,"|")
        firm-house-litera     = entry (13,buf_clients-attr.attr-value,"|")
        firm-director-f       = entry (14,buf_clients-attr.attr-value,"|")
        firm-director-i       = entry (15,buf_clients-attr.attr-value,"|")
        firm-director-o       = entry (16,buf_clients-attr.attr-value,"|")
        firm-accountant-f     = entry (17,buf_clients-attr.attr-value,"|")
        firm-accountant-i     = entry (18,buf_clients-attr.attr-value,"|")
        firm-accountant-o     = entry (19,buf_clients-attr.attr-value,"|") no-error.

end. /* for first buf_clients-attr */

for first buf_firm no-lock where buf_firm.firm-code = v-cntxt-host-code-obj:

        firm-e-mail     = buf_firm.e-mail.
        
end. /* for first buf_firm */

/* Заполним вторую страницу */

/* Объекты */

for each obj-list no-lock break by obj-list.obj-type :  /* По всем объектам */
    
    v-kpp = "" . 
        
    for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = obj-list.obj-code /* КПП */
                                       and   buf_clients-attr.obj-type  = obj-list.obj-type
                                       and   buf_clients-attr.attr-code = {&attr-kpp}:
        v-kpp = buf_clients-attr.attr-value.
    end. /* for first buf_clients-attr */
    
    if v-kpp = "" then  v-kpp = v-fmtcli-kpp.
    
    if TOGGLE-KPP then do :
        find first page-2 exclusive-lock where page-2.kpp = v-kpp no-error.
        if available page-2 then do :
            release page-2 .
            next .
        end.    
    end.
    
    if not available page-2 then do :
        create page-2.
        
        page-2.obj-type = obj-list.obj-type.
        page-2.obj-code = obj-list.obj-code.
        page-2.kpp      = v-kpp .   
    end.
    
    for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = obj-list.obj-code /* КПП */
                                       and   buf_clients-attr.obj-type  = obj-list.obj-type
                                       and   buf_clients-attr.attr-code = {&attr-requisite-alc-decl}:
        assign
        page-2.obj-name     = entry( 1, buf_clients-attr.attr-value, "|")
        page-2.country-code = entry( 3, buf_clients-attr.attr-value, "|")
        page-2.post-code   = entry( 4, buf_clients-attr.attr-value, "|")
        page-2.reg-code     = entry( 5, buf_clients-attr.attr-value, "|")
        page-2.district     = entry( 6, buf_clients-attr.attr-value, "|")
        page-2.city         = entry( 7, buf_clients-attr.attr-value, "|")
        page-2.settlement   = entry( 8, buf_clients-attr.attr-value, "|")
        page-2.street       = entry( 9, buf_clients-attr.attr-value, "|")
        page-2.house-number = entry( 10, buf_clients-attr.attr-value, "|")
        page-2.house-case   = entry (11,buf_clients-attr.attr-value,"|")
        page-2.apartment    = entry (12,buf_clients-attr.attr-value,"|")
        page-2.house-litera = entry (13,buf_clients-attr.attr-value,"|") no-error.
    end. /* for first buf_clients-attr */
    
    release page-2 .
    
end. /* for each obj-list */

/* Данные для отчета */

ext-cl = new extgds(yes) .
ext-FormF1 = new extFormF1(yes) .

output stream logStr to value("alc-dec-p_errors.txt") .
v-inn-err = false.

/* Получим остатки на конец периода */

for each obj-list no-lock:  /* По всем объектам */
    
    wait-message = string("Идёт расчет остатков на конец периода по объекту " + obj-list.obj-name).
    run waitfram-show in this-procedure (input wait-message).
    
    for each alc-goods no-lock by alc-goods.type-code : /* По всему алкоголю */
        
        run partslib-clear-temp-parts in this-procedure.
        if TOGGLE-KPP then do :
            run my-init-temp-parts-by-factord in this-procedure  (input obj-list.obj-type
                                                                       ,input obj-list.obj-code
                                                                       ,input alc-goods.artic
                                                                       ,input alc-goods.prod-type
                                                                       ,input alc-goods.prod-code
                                                                       ,input fact-order-end).
        end.
        else do :
            run partslib-init-temp-parts-by-factord in this-procedure  (input obj-list.obj-type
                                                                       ,input obj-list.obj-code
                                                                       ,input alc-goods.artic
                                                                       ,input alc-goods.prod-type
                                                                       ,input alc-goods.prod-code
                                                                       ,input fact-order-end
                                                                       ,input true).
       end.
       for each temp-parts no-lock where temp-parts.fact-qnty <> 0:
           
          /* Если выборочно по поставщикам */
          if RADIO-SUPPLIER = 2 and
          not can-find(first alc-suppliers where alc-suppliers.obj-type = temp-parts.supp-type
                                             and alc-suppliers.obj-code = temp-parts.supp-code)
          then next.
          
          v-inner-code = ? .  
          if num-entries(temp-parts.alc-ref-ab-path) = 4 and entry(4, temp-parts.alc-ref-ab-path) <> "" then do :
            find first alc-types no-lock where trim(alc-types.alc-type-code) = trim(entry(4, temp-parts.alc-ref-ab-path)) no-error .
            if available alc-types then v-inner-code = alc-types.type-code .
            else next .
          end.  
          if v-inner-code = ? then v-inner-code = alc-goods.type-code .
          
           /* для информации по партиям */
           find first tt-parts-info exclusive-lock where tt-parts-info.obj-type         = obj-list.obj-type
                                                     and tt-parts-info.obj-code         = obj-list.obj-code
                                                     and tt-parts-info.artic            = alc-goods.artic
                                                     and tt-parts-info.prod-type        = alc-goods.prod-type
                                                     and tt-parts-info.prod-code        = alc-goods.prod-code
                                                     and tt-parts-info.in-code          = temp-parts.in-code
                                                     and tt-parts-info.out-code         = temp-parts.out-code
                                                     and tt-parts-info.part-code        = temp-parts.part-code no-error .
           if not available tt-parts-info then do :
               create tt-parts-info .
               assign
                tt-parts-info.obj-type         = obj-list.obj-type
                tt-parts-info.obj-code         = obj-list.obj-code
                tt-parts-info.artic            = alc-goods.artic
                tt-parts-info.prod-type        = alc-goods.prod-type
                tt-parts-info.prod-code        = alc-goods.prod-code
                tt-parts-info.in-code          = temp-parts.in-code
                tt-parts-info.out-code         = temp-parts.out-code
                tt-parts-info.part-code        = temp-parts.part-code
               .
           end.
          
            v-kpp = "" . 
        
            for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = obj-list.obj-code /* КПП */
                                               and   buf_clients-attr.obj-type  = obj-list.obj-type
                                               and   buf_clients-attr.attr-code = {&attr-kpp}:
                v-kpp = buf_clients-attr.attr-value.
            end. /* for first buf_clients-attr */
            
            if v-kpp = "" then  v-kpp = v-fmtcli-kpp.
            
          /* Получим производителя/импортера */
            ext-FormF1:Release_() .
            if num-entries(temp-parts.alc-ref-ab-path) = 4 and entry(1, temp-parts.alc-ref-ab-path) <> "" then do :
                ext-FormF1:OpenQueryExtFormF1(entry(1, temp-parts.alc-ref-ab-path)) . 
            end.
          
            ext-cl:Release_() .
            if num-entries(temp-parts.alc-ref-ab-path) = 4 and entry(3, temp-parts.alc-ref-ab-path) <> "" then do :
                ext-cl:OpenQueryExtGds(alc-goods.gds-code, entry(3, temp-parts.alc-ref-ab-path)) . 
                tt-parts-info.alc-code =  entry(3, temp-parts.alc-ref-ab-path) .                  
            end.
            
            if temp-parts.alc-imp-code <> 0 then assign      /* Если есть - берем импортера */
                    imp-or-prod-type = temp-parts.alc-imp-type
                    imp-or-prod-code = temp-parts.alc-imp-code
                    tt-parts-info.importer = 'Импортер из алк.атр. партии' .
            else
            if ext-FormF1:NumBundles > 0
            and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ""
            and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ?
            then do :
                imp-or-prod-type = ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli .
                imp-or-prod-code = 0 .
                tt-parts-info.importer = 'ЕГАИС. Оригинальный клиент из Справки А (Справки 1)' .
            end.
            else
            if ext-cl:NumBundles > 0
            and ext-cl:GetExtGdsValue(1):CliRegIdProd <> ""
            and ext-cl:GetExtGdsValue(1):CliRegIdProd <> ?
            then do :
                if ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ""
                and ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ?
                then do :
                        if trim(ext-cl:GetExtGdsValue(1):CountryProd) = "643" /* Россия */
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "051" /* Армения */
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "398" /* Казахстан */
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "417" /* Киргизия */
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "112" /* Беларусь */
                        then
                        assign
                            imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdProd
                            imp-or-prod-code = 0
                            tt-parts-info.importer = 'ЕГАИС. Производитель из Таможенного Союза'
                        .
                        else
                        assign
                            imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdImpor
                            imp-or-prod-code = 0
                            tt-parts-info.importer = 'ЕГАИС. Импортер'
                        .
                end.
                else
                assign
                    imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdProd
                    imp-or-prod-code = 0
                    tt-parts-info.importer = 'ЕГАИС. Производитель'
                .
            end.
            else assign                                     /* Если нет - производителя */
                    imp-or-prod-type = temp-parts.prod-type
                    imp-or-prod-code = temp-parts.prod-code
                    tt-parts-info.importer = 'Производитель из карточки товара' .

          release part-1 no-error.
          if TOGGLE-KPP then do :
              find first part-1 where part-1.type-code = v-inner-code
                                and   part-1.prod-code = imp-or-prod-code
                                and   part-1.prod-type = imp-or-prod-type
                                and   part-1.obj-kpp   = v-kpp no-error.
          end.
          else do :
              find first part-1 where part-1.type-code = v-inner-code
                                and   part-1.prod-code = imp-or-prod-code
                                and   part-1.prod-type = imp-or-prod-type
                                and   part-1.obj-code  = obj-list.obj-code
                                and   part-1.obj-type  = obj-list.obj-type no-error.
          end.
          if not available (part-1) then do:
              create part-1.
              assign
              part-1.type-code = v-inner-code
              part-1.prod-code = imp-or-prod-code
              part-1.prod-type = imp-or-prod-type
              part-1.obj-code  = obj-list.obj-code
              part-1.obj-type  = obj-list.obj-type
              part-1.obj-kpp   = v-kpp .

              /* Проверим, импортный ли производитель */
          for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = temp-parts.prod-type
                                             and   buf_clients-attr.obj-code  = temp-parts.prod-code
                                             and   buf_clients-attr.attr-code = {&attr-foreign-producer}
                                             and   buf_clients-attr.attr-value = "yes":
              part-1.foreign = yes.
          end. /* for first buf_clients-attr */
          
          /* Заполним Раздел 1 Колонки 1 и 2 */
          
          if num-entries(temp-parts.alc-ref-ab-path) = 4 and entry(4, temp-parts.alc-ref-ab-path) <> "" then do :
              part-1.alc-type-code = trim(entry(4, temp-parts.alc-ref-ab-path)) .
              for first alc-types no-lock where trim(alc-types.alc-type-code) = trim(entry(4, temp-parts.alc-ref-ab-path)) :
                  part-1.alc-type-name = alc-types.alc-type-name .
              end. 
          end.
          else
          for first alc-types no-lock where alc-types.type-code = alc-goods.type-code:
              assign
              part-1.alc-type-code = alc-types.alc-type-code
              part-1.alc-type-name = alc-types.alc-type-name.
          end.
          
          /* Заполним Раздел 1 Колонки 3 4 5 */
          
          case imp-or-prod-type:
              
              when {&cmp} then do:
                  find first buf_firm no-lock where buf_firm.firm-code = imp-or-prod-code.
                  find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                                 and   buf_clients.obj-type = imp-or-prod-type.
                  assign
                  part-1.producer-obj-name = buf_clients.obj-name
                  part-1.producer-inn = buf_firm.inn
                  part-1.producer-kpp = buf_firm.kpp.
              end. /* when {&cmp} */
              
              when {&shop} or when {&stock} then do:
              find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                             and   buf_clients.obj-type = imp-or-prod-type. /* для host-code и obj-name */
              
              find first buf_firm no-lock where buf_firm.firm-code = buf_clients.host-code. /* Для ИНН */
              
              release buf_clients-attr.
              find first buf_clients-attr no-lock where buf_clients-attr.obj-code  = imp-or-prod-code /* КПП */
                                                  and   buf_clients-attr.obj-type  = imp-or-prod-type
                                                  and   buf_clients-attr.attr-code = {&attr-kpp} no-error.
              
              assign
                  part-1.producer-obj-name = buf_clients.obj-name
                  part-1.producer-inn = buf_firm.inn
                  part-1.producer-kpp = (if buf_clients-attr.attr-value <> "" 
                                        and buf_clients-attr.attr-value <> ? 
                                        then buf_clients-attr.attr-value else buf_firm.kpp).
              end. /* when {&shop} or when {&stock} */
              
              when {&prs} then do:
                  find first buf_person no-lock where buf_person.psn-code = imp-or-prod-code.
                  find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                                 and   buf_clients.obj-type = imp-or-prod-type.
                  assign
                  part-1.producer-obj-name = buf_clients.obj-name
                  part-1.producer-inn = buf_person.inn
                  part-1.producer-kpp = buf_person.kpp.    
          
              end. /* when {&prs} */
              
              otherwise do : /* egais */
                    if ext-FormF1:NumBundles > 0
                    and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ""
                    and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ?
                    then do :
                        part-1.producer-obj-name = ext-FormF1:GetExtFormF1Value():FullNameOrigCli .
                        part-1.producer-inn = ext-FormF1:GetExtFormF1Value():INNOrigCli .
                        part-1.producer-kpp = ext-FormF1:GetExtFormF1Value():KPPOrigCli .
                    end.
                    else
                    if ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ""
                    and ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ?
                    then do :
                        if trim(ext-cl:GetExtGdsValue(1):CountryProd) = "643" /* Россия */
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "051" /* Армения */
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "398" /* Казахстан */
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "417" /* Киргизия */
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "112" /* Беларусь */
                        then
                        assign
                            part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameProd
                            part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNProd
                            part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPProd
                        .
                        else
                        assign
                            part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameImpor
                            part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNImpor
                            part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPImpor
                        . 
                    end.
                    else do :
                        assign
                            part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameProd
                            part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNProd
                            part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPProd
                        .
                    end.
              end. /* when 'egais' */

          end case. /* case imp-or-prod-type */
          
          if part-1.producer-inn = "" or part-1.producer-inn = ?
          or part-1.producer-kpp = "" or part-1.producer-kpp = ?
          then do :
              if part-1.producer-inn <> "" and part-1.producer-inn <> ?
              and (part-1.producer-kpp = "" or part-1.producer-kpp = ?)
              and tt-parts-info.importer = 'ЕГАИС. Производитель из Таможенного Союза'
              then do :
              end.    
              else do :
                  put stream logStr unformatted 'Производитель/импортер "'  part-1.producer-obj-name
                   '" - не заполнен ИНН и/или КПП (' tt-parts-info.importer '). Артикул: ' tt-parts-info.artic ' ; партия по ПН № ' temp-parts.in-code skip .
                  v-inn-err = true .
              end.
          end.

          end. /* if not available (part-1) */

          part-1.remain-20 = part-1.remain-20 + temp-parts.fact-qnty * alc-goods.vol / 10.
          
          assign
            tt-parts-info.alc-type-code     = part-1.alc-type-code
            tt-parts-info.producer-obj-name = part-1.producer-obj-name
            tt-parts-info.producer-inn      = part-1.producer-inn
            tt-parts-info.producer-kpp      = part-1.producer-kpp
          no-error . 
          tt-parts-info.remain-20 = temp-parts.fact-qnty * alc-goods.vol / 10 no-error.

       end. /* for each temp-parts */
       
    end. /* each alc-goods */
    
end. /* each obj-list */

/* Получим остатки на начало периода */

for each obj-list no-lock:  /* По всем объектам */
    
    wait-message = string("Идёт расчет остатков на начало периода по объекту " + obj-list.obj-name).
    run waitfram-show in this-procedure (input wait-message).
    
    for each alc-goods no-lock by alc-goods.type-code : /* По всему алкоголю */
        
        run partslib-clear-temp-parts in this-procedure.
        if TOGGLE-KPP then do :
            run my-init-temp-parts-by-factord in this-procedure  (input obj-list.obj-type
                                                                       ,input obj-list.obj-code
                                                                       ,input alc-goods.artic
                                                                       ,input alc-goods.prod-type
                                                                       ,input alc-goods.prod-code
                                                                       ,input fact-order-start).
        end.
        else do :
            run partslib-init-temp-parts-by-factord in this-procedure  (input obj-list.obj-type
                                                                       ,input obj-list.obj-code
                                                                       ,input alc-goods.artic
                                                                       ,input alc-goods.prod-type
                                                                       ,input alc-goods.prod-code
                                                                       ,input fact-order-start
                                                                       ,input true).
       end.
       for each temp-parts no-lock where temp-parts.fact-qnty <> 0:
           
          /* Если выборочно по поставщикам */
          if RADIO-SUPPLIER = 2 and
          not can-find(first alc-suppliers where alc-suppliers.obj-type = temp-parts.supp-type
                                             and alc-suppliers.obj-code = temp-parts.supp-code)
          then next.
          
          v-inner-code = ? .  
          if num-entries(temp-parts.alc-ref-ab-path) = 4 and entry(4, temp-parts.alc-ref-ab-path) <> "" then do :
            find first alc-types no-lock where trim(alc-types.alc-type-code) = trim(entry(4, temp-parts.alc-ref-ab-path)) no-error .
            if available alc-types then v-inner-code = alc-types.type-code .
            else next .
          end.  
          if v-inner-code = ? then v-inner-code = alc-goods.type-code .
          
           find first tt-parts-info exclusive-lock where tt-parts-info.obj-type         = obj-list.obj-type
                                                     and tt-parts-info.obj-code         = obj-list.obj-code
                                                     and tt-parts-info.artic            = alc-goods.artic
                                                     and tt-parts-info.prod-type        = alc-goods.prod-type
                                                     and tt-parts-info.prod-code        = alc-goods.prod-code
                                                     and tt-parts-info.in-code          = temp-parts.in-code
                                                     and tt-parts-info.out-code         = temp-parts.out-code
                                                     and tt-parts-info.part-code        = temp-parts.part-code no-error .
           if not available tt-parts-info then do :
               create tt-parts-info .
               assign
                tt-parts-info.obj-type         = obj-list.obj-type
                tt-parts-info.obj-code         = obj-list.obj-code
                tt-parts-info.artic            = alc-goods.artic
                tt-parts-info.prod-type        = alc-goods.prod-type
                tt-parts-info.prod-code        = alc-goods.prod-code
                tt-parts-info.in-code          = temp-parts.in-code
                tt-parts-info.out-code         = temp-parts.out-code
                tt-parts-info.part-code        = temp-parts.part-code
               .
           end.
          
            v-kpp = "" . 
        
            for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = obj-list.obj-code /* КПП */
                                               and   buf_clients-attr.obj-type  = obj-list.obj-type
                                               and   buf_clients-attr.attr-code = {&attr-kpp}:
                v-kpp = buf_clients-attr.attr-value.
            end. /* for first buf_clients-attr */
            
            if v-kpp = "" then  v-kpp = v-fmtcli-kpp.
          
          /* Получим производителя/импортера */
            ext-FormF1:Release_() .
            if num-entries(temp-parts.alc-ref-ab-path) = 4 and entry(1, temp-parts.alc-ref-ab-path) <> "" then do :
                ext-FormF1:OpenQueryExtFormF1(entry(1, temp-parts.alc-ref-ab-path)) . 
            end.
          
            ext-cl:Release_() .
            if num-entries(temp-parts.alc-ref-ab-path) = 4 and entry(3, temp-parts.alc-ref-ab-path) <> "" then do :
                ext-cl:OpenQueryExtGds(alc-goods.gds-code, entry(3, temp-parts.alc-ref-ab-path)) . 
                tt-parts-info.alc-code =  entry(3, temp-parts.alc-ref-ab-path) .                   
            end.
            
            if temp-parts.alc-imp-code <> 0 then assign      /* Если есть - берем импортера */
                    imp-or-prod-type = temp-parts.alc-imp-type
                    imp-or-prod-code = temp-parts.alc-imp-code
                    tt-parts-info.importer = 'Импортер из алк.атр. партии' .
            else
            if ext-FormF1:NumBundles > 0
            and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ""
            and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ?
            then do :
                imp-or-prod-type = ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli .
                imp-or-prod-code = 0 .
                tt-parts-info.importer = 'ЕГАИС. Оригинальный клиент из Справки А (Справки 1)' .
            end.
            else
            if ext-cl:NumBundles > 0
            and ext-cl:GetExtGdsValue(1):CliRegIdProd <> ""
            and ext-cl:GetExtGdsValue(1):CliRegIdProd <> ?
            then do :
                if ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ""
                and ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ?
                then do :
                        if trim(ext-cl:GetExtGdsValue(1):CountryProd) = "643" /* Россия */
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "051" /* Армения */
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "398" /* Казахстан */
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "417" /* Киргизия */
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "112" /* Беларусь */
                        then
                        assign
                            imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdProd
                            imp-or-prod-code = 0
                            tt-parts-info.importer = 'ЕГАИС. Производитель из Таможенного Союза'
                        .
                        else
                        assign
                            imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdImpor
                            imp-or-prod-code = 0
                            tt-parts-info.importer = 'ЕГАИС. Импортер'
                        .
                end.
                else
                assign
                    imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdProd
                    imp-or-prod-code = 0
                    tt-parts-info.importer = 'ЕГАИС. Производитель'
                .
            end.
            else assign                                     /* Если нет - производителя */
                    imp-or-prod-type = temp-parts.prod-type
                    imp-or-prod-code = temp-parts.prod-code
                    tt-parts-info.importer = 'Производитель из карточки товара' .

          release part-1 no-error.
          if TOGGLE-KPP then do :
              find first part-1 where part-1.type-code = v-inner-code
                                and   part-1.prod-code = imp-or-prod-code
                                and   part-1.prod-type = imp-or-prod-type
                                and   part-1.obj-kpp   = v-kpp no-error.
          end.
          else do :
              find first part-1 where part-1.type-code = v-inner-code
                                and   part-1.prod-code = imp-or-prod-code
                                and   part-1.prod-type = imp-or-prod-type
                                and   part-1.obj-code  = obj-list.obj-code
                                and   part-1.obj-type  = obj-list.obj-type no-error.
          end.
          if not available (part-1) then do:
              create part-1.
              assign
              part-1.type-code = v-inner-code
              part-1.prod-code = imp-or-prod-code
              part-1.prod-type = imp-or-prod-type
              part-1.obj-code  = obj-list.obj-code
              part-1.obj-type  = obj-list.obj-type
              part-1.obj-kpp   = v-kpp .

              /* Проверим, импортный ли производитель */
          for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = temp-parts.prod-type
                                             and   buf_clients-attr.obj-code  = temp-parts.prod-code
                                             and   buf_clients-attr.attr-code = {&attr-foreign-producer}
                                             and   buf_clients-attr.attr-value = "yes":
              part-1.foreign = yes.
          end. /* for first buf_clients-attr */
          
          /* Заполним Раздел 1 Колонки 1 и 2 */
 
          if num-entries(temp-parts.alc-ref-ab-path) = 4 and entry(4, temp-parts.alc-ref-ab-path) <> "" then do :
              part-1.alc-type-code = trim(entry(4, temp-parts.alc-ref-ab-path)) .
              for first alc-types no-lock where trim(alc-types.alc-type-code) = trim(entry(4, temp-parts.alc-ref-ab-path)) :
                  part-1.alc-type-name = alc-types.alc-type-name .
              end. 
          end.
          else
          for first alc-types no-lock where alc-types.type-code = alc-goods.type-code:
              assign
              part-1.alc-type-code = alc-types.alc-type-code
              part-1.alc-type-name = alc-types.alc-type-name.
          end.
          
          /* Заполним Раздел 1 Колонки 3 4 5 */
          
          case imp-or-prod-type:
              
              when {&cmp} then do:
                  find first buf_firm no-lock where buf_firm.firm-code = imp-or-prod-code.
                  find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                                 and   buf_clients.obj-type = imp-or-prod-type.
                  assign
                  part-1.producer-obj-name = buf_clients.obj-name
                  part-1.producer-inn = buf_firm.inn
                  part-1.producer-kpp = buf_firm.kpp.
              end. /* when {&cmp} */
              
              when {&shop} or when {&stock} then do:
              find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                             and   buf_clients.obj-type = imp-or-prod-type. /* для host-code и obj-name */
              
              find first buf_firm no-lock where buf_firm.firm-code = buf_clients.host-code. /* Для ИНН */
              
              release buf_clients-attr.
              find first buf_clients-attr no-lock where buf_clients-attr.obj-code  = imp-or-prod-code /* КПП */
                                                  and   buf_clients-attr.obj-type  = imp-or-prod-type
                                                  and   buf_clients-attr.attr-code = {&attr-kpp} no-error.
              
              assign
                  part-1.producer-obj-name = buf_clients.obj-name
                  part-1.producer-inn = buf_firm.inn
                  part-1.producer-kpp = (if buf_clients-attr.attr-value <> "" 
                                        and buf_clients-attr.attr-value <> ? 
                                        then buf_clients-attr.attr-value else buf_firm.kpp).
              end. /* when {&shop} or when {&stock} */
              
              when {&prs} then do:
                  find first buf_person no-lock where buf_person.psn-code = imp-or-prod-code.
                  find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                                 and   buf_clients.obj-type = imp-or-prod-type.
                  assign
                  part-1.producer-obj-name = buf_clients.obj-name
                  part-1.producer-inn = buf_person.inn
                  part-1.producer-kpp = buf_person.kpp.    
          
              end. /* when {&prs} */
              
              otherwise do : /* egais */
                    if ext-FormF1:NumBundles > 0
                    and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ""
                    and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ?
                    then do :
                        part-1.producer-obj-name = ext-FormF1:GetExtFormF1Value():FullNameOrigCli .
                        part-1.producer-inn = ext-FormF1:GetExtFormF1Value():INNOrigCli .
                        part-1.producer-kpp = ext-FormF1:GetExtFormF1Value():KPPOrigCli .
                    end.
                    else
                    if ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ""
                    and ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ?
                    then do :
                        if trim(ext-cl:GetExtGdsValue(1):CountryProd) = "643" /* Россия */
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "051" /* Армения */
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "398" /* Казахстан */
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "417" /* Киргизия */
                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "112" /* Беларусь */
                        then
                        assign
                            part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameProd
                            part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNProd
                            part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPProd
                        .
                        else
                        assign
                            part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameImpor
                            part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNImpor
                            part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPImpor
                        . 
                    end.
                    else do :
                        assign
                            part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameProd
                            part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNProd
                            part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPProd
                        .
                    end.
              end. /* when 'egais' */

          end case. /* case imp-or-prod-type */
          
          if part-1.producer-inn = "" or part-1.producer-inn = ?
          or part-1.producer-kpp = "" or part-1.producer-kpp = ?
          then do :
              if part-1.producer-inn <> "" and part-1.producer-inn <> ?
              and (part-1.producer-kpp = "" or part-1.producer-kpp = ?)
              and tt-parts-info.importer = 'ЕГАИС. Производитель из Таможенного Союза'
              then do :
              end.    
              else do :
                  put stream logStr unformatted 'Производитель/импортер "'  part-1.producer-obj-name
                   '" - не заполнен ИНН и/или КПП (' tt-parts-info.importer '). Артикул: ' tt-parts-info.artic ' ; партия по ПН № ' temp-parts.in-code skip .
                  v-inn-err = true .
              end.
          end.

          end. /* if not available (part-1) */

          part-1.remain-6 = part-1.remain-6 + temp-parts.fact-qnty * alc-goods.vol / 10.
          
          assign
            tt-parts-info.alc-type-code     = part-1.alc-type-code
            tt-parts-info.producer-obj-name = part-1.producer-obj-name
            tt-parts-info.producer-inn      = part-1.producer-inn
            tt-parts-info.producer-kpp      = part-1.producer-kpp
          no-error . 
          tt-parts-info.remain-6 = temp-parts.fact-qnty * alc-goods.vol / 10.

       end. /* for each temp-parts */
       
    end. /* each alc-goods */
    
end. /* each obj-list */

/* Заполнение временной таблицы */

for each obj-list no-lock:  /* По всем объектам */
    
    wait-message = string("Идёт сбор данных по объекту " + obj-list.obj-name).
    run waitfram-show in this-procedure (input wait-message).
    
    for each alc-goods no-lock: /* По всему алкоголю */
    
        for each buf_doc-line no-lock where buf_doc-line.obj-type     = obj-list.obj-type             /* По объекту */
                                      and   buf_doc-line.obj-code     = obj-list.obj-code             /* По объекту */
                                      and   buf_doc-line.fact-order   >= fact-order-start             /* По дате начала */
                                      and   buf_doc-line.fact-order   <= fact-order-end               /* По дате конца */
                                      and   buf_doc-line.status_      = {&fact}                       /* По закрытым */
                                      and   buf_doc-line.artic        = alc-goods.artic               /* По артикулу */
                                      and   buf_doc-line.prod-code    = alc-goods.prod-code           /* По производителю */
                                      and   buf_doc-line.prod-type    = alc-goods.prod-type           /* По производителю */
                                      and   lookup(buf_doc-line.ext-doc-type, "{&doc-types}") <> ? :  /* По типам документов*/ 
             
             for each buf_parts no-lock where   buf_parts.prod-type = alc-goods.prod-type /* По индексу pi, не используя 2 поля  */
                                          and   buf_parts.prod-code = alc-goods.prod-code
                                          and   buf_parts.artic     = alc-goods.artic
                                          and   buf_parts.out-code  = buf_doc-line.doc-code:
                    
                    if buf_parts.fact-qnty = 0
                    then next .
                                          
                    /* Если выборочно по поставщикам */
                    if RADIO-SUPPLIER = 2 and
                    not can-find(first alc-suppliers where alc-suppliers.obj-type = buf_parts.supp-type
                                                       and alc-suppliers.obj-code = buf_parts.supp-code)
                    then next.
                    
                    v-inner-code = ? .  
                    if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(4, buf_parts.alc-ref-ab-path) <> "" then do :
                      find first alc-types no-lock where trim(alc-types.alc-type-code) = trim(entry(4, buf_parts.alc-ref-ab-path)) no-error .
                      if available alc-types then v-inner-code = alc-types.type-code .
                      else next .
                    end.  
                    if v-inner-code = ? then v-inner-code = alc-goods.type-code .
                    
                    /* для информации по партиям */
                   find first tt-parts-info exclusive-lock where tt-parts-info.obj-type         = obj-list.obj-type
                                                             and tt-parts-info.obj-code         = obj-list.obj-code
                                                             and tt-parts-info.artic            = alc-goods.artic
                                                             and tt-parts-info.prod-type        = alc-goods.prod-type
                                                             and tt-parts-info.prod-code        = alc-goods.prod-code
                                                             and tt-parts-info.in-code          = buf_parts.in-code
                                                             and tt-parts-info.out-code         = buf_parts.out-code
                                                             and tt-parts-info.part-code        = buf_parts.part-code no-error .
                   if not available tt-parts-info then do :
                       create tt-parts-info .
                       assign
                        tt-parts-info.obj-type         = obj-list.obj-type
                        tt-parts-info.obj-code         = obj-list.obj-code
                        tt-parts-info.artic            = alc-goods.artic
                        tt-parts-info.prod-type        = alc-goods.prod-type
                        tt-parts-info.prod-code        = alc-goods.prod-code
                        tt-parts-info.in-code          = buf_parts.in-code
                        tt-parts-info.out-code         = buf_parts.out-code
                        tt-parts-info.part-code        = buf_parts.part-code
                       .
                   end.
                    
                    v-kpp = "" . 
        
                    for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = obj-list.obj-code /* КПП */
                                                       and   buf_clients-attr.obj-type  = obj-list.obj-type
                                                       and   buf_clients-attr.attr-code = {&attr-kpp}:
                        v-kpp = buf_clients-attr.attr-value.
                    end. /* for first buf_clients-attr */
                    
                    if v-kpp = "" then  v-kpp = v-fmtcli-kpp.
                    
                    /* Получим производителя/импортера */
                    ext-FormF1:Release_() .
                    if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(1, buf_parts.alc-ref-ab-path) <> "" then do :
                        ext-FormF1:OpenQueryExtFormF1(entry(1, buf_parts.alc-ref-ab-path)) . 
                    end.
                    
                    ext-cl:Release_() .
                    if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(3, buf_parts.alc-ref-ab-path) <> "" then do :
                        ext-cl:OpenQueryExtGds(alc-goods.gds-code, entry(3, buf_parts.alc-ref-ab-path)) . 
                        tt-parts-info.alc-code =  entry(3, buf_parts.alc-ref-ab-path) .                   
                    end.
                    
                    if buf_parts.alc-imp-code <> 0 then assign      /* Если есть - берем импортера */
                            imp-or-prod-type = buf_parts.alc-imp-type
                            imp-or-prod-code = buf_parts.alc-imp-code
                            tt-parts-info.importer = 'Импортер из алк.атр. партии' .
                    else
                    if ext-FormF1:NumBundles > 0
                    and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ""
                    and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ?
                    then do :
                        imp-or-prod-type = ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli .
                        imp-or-prod-code = 0 .
                        tt-parts-info.importer = 'ЕГАИС. Оригинальный клиент из Справки А (Справки 1)' .
                    end.
                    else
                    if ext-cl:NumBundles > 0
                    and ext-cl:GetExtGdsValue(1):CliRegIdProd <> ""
                    and ext-cl:GetExtGdsValue(1):CliRegIdProd <> ?
                    then do :
                        if ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ""
                        and ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ?
                        then do :
                                if trim(ext-cl:GetExtGdsValue(1):CountryProd) = "643" /* Россия */
                                or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "051" /* Армения */
                                or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "398" /* Казахстан */
                                or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "417" /* Киргизия */
                                or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "112" /* Беларусь */
                                then
                                assign
                                    imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdProd
                                    imp-or-prod-code = 0
                                    tt-parts-info.importer = 'ЕГАИС. Производитель из Таможенного Союза'
                                .
                                else
                                assign
                                    imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdImpor
                                    imp-or-prod-code = 0
                                    tt-parts-info.importer = 'ЕГАИС. Импортер'
                                .
                        end.
                        else
                        assign
                            imp-or-prod-type = ext-cl:GetExtGdsValue(1):CliRegIdProd
                            imp-or-prod-code = 0
                            tt-parts-info.importer = 'ЕГАИС. Производитель'
                        .
                    end.
                    else assign                                     /* Если нет - производителя */
                        imp-or-prod-type = buf_parts.prod-type
                        imp-or-prod-code = buf_parts.prod-code
                        tt-parts-info.importer = 'Производитель из карточки товара' .

                /* Первый раздел */
                
                release part-1 no-error.
                if TOGGLE-KPP then do :
                      find first part-1 where part-1.type-code = v-inner-code
                                        and   part-1.prod-code = imp-or-prod-code
                                        and   part-1.prod-type = imp-or-prod-type
                                        and   part-1.obj-kpp   = v-kpp no-error.
                end.
                else do :
                      find first part-1 where part-1.type-code = v-inner-code
                                        and   part-1.prod-code = imp-or-prod-code
                                        and   part-1.prod-type = imp-or-prod-type
                                        and   part-1.obj-code  = obj-list.obj-code
                                        and   part-1.obj-type  = obj-list.obj-type no-error.
                end.
                if not available (part-1) then do:
                    create part-1.
                    assign
                    part-1.type-code = v-inner-code
                    part-1.prod-code = imp-or-prod-code
                    part-1.prod-type = imp-or-prod-type
                    part-1.obj-code  = obj-list.obj-code
                    part-1.obj-type  = obj-list.obj-type
                    part-1.obj-kpp   = v-kpp.

                    /* Проверим, импортный ли производитель */
                    for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_parts.prod-type
                                                       and   buf_clients-attr.obj-code  = buf_parts.prod-code
                                                       and   buf_clients-attr.attr-code = {&attr-foreign-producer}
                                                       and   buf_clients-attr.attr-value = "yes":
                        part-1.foreign = yes.
                    end. /* for first buf_clients-attr */
                    
                    /* Заполним Раздел 1 Колонки 1 и 2 */

                    if num-entries(buf_parts.alc-ref-ab-path) = 4 and entry(4, buf_parts.alc-ref-ab-path) <> "" then do :
                        part-1.alc-type-code = trim(entry(4, buf_parts.alc-ref-ab-path)) .
                        for first alc-types no-lock where trim(alc-types.alc-type-code) = trim(entry(4, buf_parts.alc-ref-ab-path)) :
                            part-1.alc-type-name = alc-types.alc-type-name .
                        end. 
                    end.
                    else
                    for first alc-types no-lock where alc-types.type-code = alc-goods.type-code:
                        assign
                        part-1.alc-type-code = alc-types.alc-type-code
                        part-1.alc-type-name = alc-types.alc-type-name.
                    end.
                    
                    /* Заполним Раздел 1 Колонки 3 4 5 */
                    
                    case imp-or-prod-type:
                        
                        when {&cmp} then do:
                            find first buf_firm no-lock where buf_firm.firm-code = imp-or-prod-code.
                            find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                                           and   buf_clients.obj-type = imp-or-prod-type.
                            assign
                            part-1.producer-obj-name = buf_clients.obj-name
                            part-1.producer-inn = buf_firm.inn
                            part-1.producer-kpp = buf_firm.kpp.
                        end. /* when {&cmp} */
                        
                        when {&shop} or when {&stock} then do:
                        find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                                       and   buf_clients.obj-type = imp-or-prod-type. /* для host-code и obj-name */
                        
                        find first buf_firm no-lock where buf_firm.firm-code = buf_clients.host-code. /* Для ИНН */
                        
                        release buf_clients-attr.
                        find first buf_clients-attr no-lock where buf_clients-attr.obj-code  = imp-or-prod-code /* КПП */
                                                            and   buf_clients-attr.obj-type  = imp-or-prod-type
                                                            and   buf_clients-attr.attr-code = {&attr-kpp} no-error.
                        
                        assign
                            part-1.producer-obj-name = buf_clients.obj-name
                            part-1.producer-inn = buf_firm.inn
                            part-1.producer-kpp = (if buf_clients-attr.attr-value <> "" 
                                                  and buf_clients-attr.attr-value <> ? 
                                                  then buf_clients-attr.attr-value else buf_firm.kpp).
                        end. /* when {&shop} or when {&stock} */
                        
                        when {&prs} then do:
                            find first buf_person no-lock where buf_person.psn-code = imp-or-prod-code.
                            find first buf_clients no-lock where buf_clients.obj-code = imp-or-prod-code
                                                           and   buf_clients.obj-type = imp-or-prod-type.
                            assign
                            part-1.producer-obj-name = buf_clients.obj-name
                            part-1.producer-inn = buf_person.inn
                            part-1.producer-kpp = buf_person.kpp.    

                        end. /* when {&prs} */
                        
                        otherwise do : /* egais */
                            if ext-FormF1:NumBundles > 0
                            and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ""
                            and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ?
                            then do :
                                part-1.producer-obj-name = ext-FormF1:GetExtFormF1Value():FullNameOrigCli .
                                part-1.producer-inn = ext-FormF1:GetExtFormF1Value():INNOrigCli .
                                part-1.producer-kpp = ext-FormF1:GetExtFormF1Value():KPPOrigCli .
                            end.
                            else
                            if ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ""
                            and ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ?
                            then do :
                                if trim(ext-cl:GetExtGdsValue(1):CountryProd) = "643" /* Россия */
                                or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "051" /* Армения */
                                or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "398" /* Казахстан */
                                or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "417" /* Киргизия */
                                or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "112" /* Беларусь */
                                then
                                assign
                                    part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameProd
                                    part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNProd
                                    part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPProd
                                .
                                else
                                assign
                                    part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameImpor
                                    part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNImpor
                                    part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPImpor
                                . 
                            end.
                            else do :
                                assign
                                    part-1.producer-obj-name = ext-cl:GetExtGdsValue(1):FullNameProd
                                    part-1.producer-inn = ext-cl:GetExtGdsValue(1):INNProd
                                    part-1.producer-kpp = ext-cl:GetExtGdsValue(1):KPPProd
                                .
                            end.
                        end. /* when 'egais' */

                    end case. /* case imp-or-prod-type */
                    
                    if part-1.producer-inn = "" or part-1.producer-inn = ?
                    or part-1.producer-kpp = "" or part-1.producer-kpp = ?
                    then do :
                        if part-1.producer-inn <> "" and part-1.producer-inn <> ?
                        and (part-1.producer-kpp = "" or part-1.producer-kpp = ?)
                        and tt-parts-info.importer = 'ЕГАИС. Производитель из Таможенного Союза'
                        then do :
                        end.    
                        else do :
                            put stream logStr unformatted 'Производитель/импортер "'  part-1.producer-obj-name
                             '" - не заполнен ИНН и/или КПП (' tt-parts-info.importer '). Артикул: ' tt-parts-info.artic ' ; партия по ПН № ' buf_parts.in-code skip .
                            v-inn-err = true .
                        end.
                    end.

                end. /* if not available (part-1) */
                
                assign
                    tt-parts-info.alc-type-code     = part-1.alc-type-code
                    tt-parts-info.producer-obj-name = part-1.producer-obj-name
                    tt-parts-info.producer-inn      = part-1.producer-inn
                    tt-parts-info.producer-kpp      = part-1.producer-kpp
                no-error .

                /* Подсчеты количеств */
                
                case buf_doc-line.ext-doc-type: /* ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,*/
                    
                    when "ie" then do: /* приход внешний */
                        if alc-goods.alpha1 <> "RU" and
                           alc-goods.alpha1 <> "AM" and
                           alc-goods.alpha1 <> "KZ" and
                           alc-goods.alpha1 <> "KG" and
                           alc-goods.alpha1 <> "BY"
                         then do: /* Импортный товар */

                            if buf_parts.alc-imp-code <> 0 then assign /* Однозначно по импорту */
                                    part-1.inc-9 = part-1.inc-9 + buf_parts.fact-qnty * alc-goods.vol / 10 
                                    tt-parts-info.inc-9 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                            else
                            if ext-FormF1:NumBundles > 0
                            and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ""
                            and ext-FormF1:GetExtFormF1Value():CliRegIdOrigCli <> ?
                            then do :
                                if ext-FormF1:GetExtFormF1Value():CliEgaisTypeOrigCli = 'FO'
                                then
                                assign
                                    part-1.inc-9 = part-1.inc-9 + buf_parts.fact-qnty * alc-goods.vol / 10
                                    tt-parts-info.inc-9 = buf_parts.fact-qnty * alc-goods.vol / 10
                                .
                                else
                                assign
                                    part-1.inc-8 = part-1.inc-8 + buf_parts.fact-qnty * alc-goods.vol / 10
                                    tt-parts-info.inc-8 = buf_parts.fact-qnty * alc-goods.vol / 10
                                .
                            end.
                            else
                            if ext-cl:NumBundles > 0
                            and ext-cl:GetExtGdsValue(1):CliRegIdProd <> ""
                            and ext-cl:GetExtGdsValue(1):CliRegIdProd <> ?
                            then do :
                                if ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ""
                                and ext-cl:GetExtGdsValue(1):CliRegIdImpor <> ?
                                then do :
                                        if trim(ext-cl:GetExtGdsValue(1):CountryProd) = "643" /* Россия */
                                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "051" /* Армения */
                                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "398" /* Казахстан */
                                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "417" /* Киргизия */
                                        or trim(ext-cl:GetExtGdsValue(1):CountryProd) = "112" /* Беларусь */
                                        then
                                        assign
                                            part-1.inc-8 = part-1.inc-8 + buf_parts.fact-qnty * alc-goods.vol / 10
                                            tt-parts-info.inc-8 = buf_parts.fact-qnty * alc-goods.vol / 10
                                        .
                                        else
                                        assign
                                            part-1.inc-9 = part-1.inc-9 + buf_parts.fact-qnty * alc-goods.vol / 10
                                            tt-parts-info.inc-9 = buf_parts.fact-qnty * alc-goods.vol / 10
                                        .
                                end.
                                else
                                assign
                                    part-1.inc-8 = part-1.inc-8 + buf_parts.fact-qnty * alc-goods.vol / 10
                                    tt-parts-info.inc-8 = buf_parts.fact-qnty * alc-goods.vol / 10
                                .
                            end.
                            else do:
                                if part-1.foreign = yes /* Проверим на импортного производителя */
                                    then assign
                                        part-1.inc-9 = part-1.inc-9 + buf_parts.fact-qnty * alc-goods.vol / 10
                                        tt-parts-info.inc-9 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                                    else assign
                                        part-1.inc-8 = part-1.inc-8 + buf_parts.fact-qnty * alc-goods.vol / 10
                                        tt-parts-info.inc-8 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                            end. /* else do */

                        end. /* if alc-goods.alpha1 <> "RU" */
                        
                        else do: /* Не импортный */
                            
                            for first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_parts.out-code:
                                
                                if  buf_trn-doc.cli-code = alc-goods.prod-code /* Если поставил производитель */
                                and buf_trn-doc.cli-type = alc-goods.prod-type
                                    then assign part-1.inc-7 = part-1.inc-7 + buf_parts.fact-qnty * alc-goods.vol / 10
                                                tt-parts-info.inc-8 = buf_parts.fact-qnty * alc-goods.vol / 10 .

                                else do:
                                    release buf_clients-attr no-error. /* Если поставщик является производителем вообще */
                                    find first buf_clients-attr no-lock where buf_clients-attr.obj-code = buf_trn-doc.cli-code
                                                                        and   buf_clients-attr.obj-type = buf_trn-doc.cli-type
                                                                        and   buf_clients-attr.attr-code = {&attr-cli-alc-producer}
                                                                        and   buf_clients-attr.attr-value = "yes" no-error.

                                    if available (buf_clients-attr)
                                                  then assign
                                                    part-1.inc-7 = part-1.inc-7 + buf_parts.fact-qnty * alc-goods.vol / 10
                                                    tt-parts-info.inc-7 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                                                  else assign
                                                    part-1.inc-8 = part-1.inc-8 + buf_parts.fact-qnty * alc-goods.vol / 10
                                                    tt-parts-info.inc-8 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                                end. /* else do */
                            end. /* for first buf_trn-doc */
                            
                        end. /* else do */
                    end. /* when "ie" */
                    
                    when "ee" then do: /* расход внешний */
/*                        message "кол.16 расход внешний " buf_parts.out-code + " " + string(buf_parts.fact-qnty * alc-goods.vol / 10 , "->>,>>9.999")  view-as alert-box.*/
                        part-1.exp-16 = part-1.exp-16 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.exp-16 = buf_parts.fact-qnty * alc-goods.vol / 10.
                    end.
                    
                    when "ep" then do: /* возврат пост. */
/*                        message "кол.17 возврат пост. " buf_parts.out-code + " " + string(buf_parts.fact-qnty * alc-goods.vol / 10 , "->>,>>9.999") view-as alert-box.*/
                        part-1.exp-17 = part-1.exp-17 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.exp-17 = buf_parts.fact-qnty * alc-goods.vol / 10.
                    end.
                    
                    when "es" then do: /* касса продажа */
/*                        message "кол.15 касса продажа " buf_parts.out-code + " " + string(buf_parts.fact-qnty * alc-goods.vol / 10 , "->>,>>9.999") view-as alert-box.*/
                        part-1.exp-15 = part-1.exp-15 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.exp-15 = buf_parts.fact-qnty * alc-goods.vol / 10.
                    end.
                    
                    when "re" then do: /* возврат внешний */
/*                        message "кол.11 возврат внешний " buf_parts.out-code + " " + string(buf_parts.fact-qnty * alc-goods.vol / 10 , "->>,>>9.999") view-as alert-box.*/
                        part-1.inc-11 = part-1.inc-11 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.inc-11 = buf_parts.fact-qnty * alc-goods.vol / 10.
                    end.
                    
                    when "rs" then do: /* касса возврат */
/*                        message "кол.11 касса возврат " buf_parts.out-code + " " + string(buf_parts.fact-qnty * alc-goods.vol / 10 , "->>,>>9.999") view-as alert-box.*/
                        part-1.inc-11 = part-1.inc-11 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.inc-11 = buf_parts.fact-qnty * alc-goods.vol / 10.
                    end.
                    
                    when "we" then do: /* списание */
/*                        message "кол.16 списание " buf_parts.out-code + " " + string(buf_parts.fact-qnty * alc-goods.vol / 10 , "->>,>>9.999") view-as alert-box.*/
                        part-1.exp-16 = part-1.exp-16 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.exp-16 = buf_parts.fact-qnty * alc-goods.vol / 10.
                    end.
                    
                    when "vt" then do: /* инвентаризация */
                    
                        if buf_parts.fact-qnty > 0 
                        
                            then do: 
/*                                message "кол.12 инвентаризация " buf_parts.out-code + " " + string(buf_parts.fact-qnty * alc-goods.vol / 10 , "->>,>>9.999") view-as alert-box.*/
                                part-1.inc-12 = part-1.inc-12 + buf_parts.fact-qnty * alc-goods.vol / 10.
                                tt-parts-info.inc-12 = buf_parts.fact-qnty * alc-goods.vol / 10.
                            end.
                            
                            else do: 
/*                                message "кол.16 инвентаризация " buf_parts.out-code + " " + string(buf_parts.fact-qnty * alc-goods.vol / 10 , "->>,>>9.999") view-as alert-box.*/
                                part-1.exp-16 = part-1.exp-16 + absolute(buf_parts.fact-qnty) * alc-goods.vol / 10.
                                tt-parts-info.exp-16 = absolute(buf_parts.fact-qnty) * alc-goods.vol / 10.
                            end.
                    end.
                    
                    when "vp" then do: /* пересортица */
                        if buf_parts.fact-qnty > 0 
                        then do: 
/*                            message "кол.12 пересортица " buf_parts.out-code + " " + string(buf_parts.fact-qnty * alc-goods.vol / 10, "->>,>>9.99") view-as alert-box.*/
                            part-1.inc-12 = part-1.inc-12 + buf_parts.fact-qnty * alc-goods.vol / 10.
                            tt-parts-info.inc-12 = buf_parts.fact-qnty * alc-goods.vol / 10.
                        end.
                        else do: 
/*                            message "кол.16 пересортица " buf_parts.out-code + " " + string(buf_parts.fact-qnty * alc-goods.vol / 10 , "->>,>>9.999") view-as alert-box.*/
                            part-1.exp-16 = part-1.exp-16 + absolute(buf_parts.fact-qnty) * alc-goods.vol / 10.
                            tt-parts-info.exp-16 = absolute(buf_parts.fact-qnty) * alc-goods.vol / 10.
                        end.
                    end.
                    
                    when "iv" then do: /* приход внутренний */
/*                        message "кол.16 пересортица " buf_parts.out-code + " " + string(buf_parts.fact-qnty * alc-goods.vol / 10 , "->>,>>9.999") view-as alert-box.*/
                        if TOGGLE-KPP then do :
                            for first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code :
                                v-kpp = "" . 
        
                                for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = buf_trn-doc.cli-code /* КПП */
                                                                   and   buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                                                   and   buf_clients-attr.attr-code = {&attr-kpp}:
                                    v-kpp = buf_clients-attr.attr-value.
                                end. /* for first buf_clients-attr */
                                
                                if v-kpp = "" then  v-kpp = v-fmtcli-kpp.
                                
                                if v-kpp <> part-1.obj-kpp then do :
                                    part-1.inc-13 = part-1.inc-13 + buf_parts.fact-qnty * alc-goods.vol / 10. 
                                    tt-parts-info.inc-13 = buf_parts.fact-qnty * alc-goods.vol / 10.   
                                end.
                            end.
                        end.
                        else assign
                        part-1.inc-13 = part-1.inc-13 + buf_parts.fact-qnty * alc-goods.vol / 10
                        tt-parts-info.inc-13 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                    end.
               
                    when "im" then do: /* Приход производства */
/*                        message "кол.12 Приход производства " buf_parts.out-code + " " + string(buf_parts.fact-qnty * alc-goods.vol / 10 , "->>,>>9.999") view-as alert-box.*/
                        part-1.inc-12 = part-1.inc-12 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.inc-12 = buf_parts.fact-qnty * alc-goods.vol / 10.
                    end.  
 
                    when "ev" then do: /* расход внутренний */
/*                        message "кол.18 расход внутренний " buf_parts.out-code + " " + string(buf_parts.fact-qnty * alc-goods.vol / 10 , "->>,>>9.999") view-as alert-box.*/
                        if TOGGLE-KPP then do :
                            for first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code :
                                v-kpp = "" . 
        
                                for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = buf_trn-doc.cli-code /* КПП */
                                                                   and   buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                                                   and   buf_clients-attr.attr-code = {&attr-kpp}:
                                    v-kpp = buf_clients-attr.attr-value.
                                end. /* for first buf_clients-attr */
                                
                                if v-kpp = "" then  v-kpp = v-fmtcli-kpp.
                                
                                if v-kpp <> part-1.obj-kpp then do :
                                    part-1.exp-18 = part-1.exp-18 + buf_parts.fact-qnty * alc-goods.vol / 10.
                                    tt-parts-info.exp-18 = buf_parts.fact-qnty * alc-goods.vol / 10.    
                                end.
                            end.
                        end.
                        else assign
                        part-1.exp-18 = part-1.exp-18 + buf_parts.fact-qnty * alc-goods.vol / 10
                        tt-parts-info.exp-18 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                    end.
                    
                    when "rv" then do: /* возврат внутренний */
/*                        message "кол.13 возврат внутренний " buf_parts.out-code + " " + string(buf_parts.fact-qnty * alc-goods.vol / 10 , "->>,>>9.999") view-as alert-box.*/
                        if TOGGLE-KPP then do :
                            for first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code :
                                v-kpp = "" . 
        
                                for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = buf_trn-doc.cli-code /* КПП */
                                                                   and   buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                                                   and   buf_clients-attr.attr-code = {&attr-kpp}:
                                    v-kpp = buf_clients-attr.attr-value.
                                end. /* for first buf_clients-attr */
                                
                                if v-kpp = "" then  v-kpp = v-fmtcli-kpp.
                                
                                if v-kpp <> part-1.obj-kpp then do :
                                    part-1.inc-13 = part-1.inc-13 + buf_parts.fact-qnty * alc-goods.vol / 10.
                                    tt-parts-info.inc-13 = buf_parts.fact-qnty * alc-goods.vol / 10 .    
                                end.
                            end.
                        end.
                        else assign
                        part-1.inc-13 = part-1.inc-13 + buf_parts.fact-qnty * alc-goods.vol / 10
                        tt-parts-info.inc-13 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                    end.

                    when "em" then do: /* расход  произв. */
/*                        message "кол.16 расход  произв. " buf_parts.out-code + " " + string(buf_parts.fact-qnty * alc-goods.vol / 10) view-as alert-box.*/
                        part-1.exp-16 = part-1.exp-16 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.exp-16 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                    end.
                    
                    when "wm" then do: /* списание произв. */
/*                        message "кол.16 списание произв. документ" buf_parts.out-code + " " + string(buf_parts.fact-qnty * alc-goods.vol / 10) + "дл" view-as alert-box.*/
                        part-1.exp-16 = part-1.exp-16 + buf_parts.fact-qnty * alc-goods.vol / 10.
                        tt-parts-info.exp-16 = buf_parts.fact-qnty * alc-goods.vol / 10 .
                    end.                    
                    
                end case. /* case buf_doc-line.ext-doc-type */
                
                /* Заполним суммы в колонках */
                
                part-1.inc-10 = part-1.inc-7  + part-1.inc-8  + part-1.inc-9.
                part-1.inc-14 = part-1.inc-10 + part-1.inc-11 + part-1.inc-12 + part-1.inc-13.
                part-1.exp-19 = part-1.exp-15 + part-1.exp-16 + part-1.exp-17 + part-1.exp-18.
                
                tt-parts-info.inc-10 = tt-parts-info.inc-7 + tt-parts-info.inc-8 + tt-parts-info.inc-9 .
                tt-parts-info.inc-14 = tt-parts-info.inc-10 + tt-parts-info.inc-11 + tt-parts-info.inc-12 + tt-parts-info.inc-13 .
                tt-parts-info.exp-19 = tt-parts-info.exp-15 + tt-parts-info.exp-16 + tt-parts-info.exp-17 + tt-parts-info.exp-18 .

                /* Второй раздел (Запись делается для каждой партии и только для закупок)*/
                
                if buf_doc-line.ext-doc-type = "ie" then do: /* Только для закупок */
                        
                        create part-2.
                        assign
                        part-2.obj-type = part-1.obj-type                        /*  */
                        part-2.obj-code = part-1.obj-code                        /*  */
                        part-2.obj-kpp  = part-1.obj-kpp                        /*  */
                        part-2.prod-code = part-1.prod-code                      /*  */
                        part-2.prod-type = part-1.prod-type                      /*  */
                        part-2.alc-type-name = part-1.alc-type-name              /* 1 */
                        part-2.alc-type-code = part-1.alc-type-code              /* 2 */
                        part-2.producer-obj-name = part-1.producer-obj-name      /* 3 */
                        part-2.producer-inn = part-1.producer-inn                /* 4 */
                        part-2.producer-kpp = part-1.producer-kpp                /* 5 */
                        part-2.GTD = buf_parts.cst-code                          /* 15 */
                        part-2.total = buf_parts.fact-qnty * alc-goods.vol / 10.  /* 16 */
                        
                    for first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code:
                        
                        /* Сначала смотрим в грузоотправителя */
                        run gbl/trdcat-v.p (input buf_trn-doc.doc-code
                                           ,input {&trdcattr-shipper}
                                           ,output v-attr-val
                                           ,output v-attr-type
                                           ) no-error.
                        
                        if v-attr-val <> "" then do:
                            part-2.supplier-code = integer(substring(v-attr-val, 4)).
                            part-2.supplier-type = substring(v-attr-val, 1, 3).
                            
                            for first buf_clients where buf_clients.obj-type = part-2.supplier-type
                                                    and buf_clients.obj-code = part-2.supplier-code no-lock:
                                part-2.supplier-obj-name = buf_clients.obj-name. /* 6 */
                            end.
                        end.
                        else do:
                            assign
                            part-2.supplier-code = buf_trn-doc.cli-code               /*  */
                            part-2.supplier-type = buf_trn-doc.cli-type               /*  */      
                            part-2.supplier-obj-name = buf_trn-doc.cli-name.          /* 6 */
                        end.
                        
                        /* Для ИНН и КПП Поставщика */
                        
                            case buf_trn-doc.cli-type:
                            
                            when {&cmp} then do:
                                find first buf_firm no-lock where buf_firm.firm-code = part-2.supplier-code.

                                assign
                                part-2.supplier-inn = buf_firm.inn  /* 7 */
                                part-2.supplier-kpp = buf_firm.kpp. /* 8 */
                            end. /* when {&cmp} */
                            
                            when {&shop} or when {&stock} then do:
                            find first buf_clients no-lock where buf_clients.obj-code = part-2.supplier-code
                                                           and   buf_clients.obj-type = part-2.supplier-type. /* для host-code и obj-name */
                            
                            find first buf_firm no-lock where buf_firm.firm-code = buf_clients.host-code. /* Для ИНН */
                            
                            release buf_clients-attr.
                            find first buf_clients-attr no-lock where buf_clients-attr.obj-code  = part-2.supplier-code /* КПП */
                                                                and   buf_clients-attr.obj-type  = part-2.supplier-type
                                                                and   buf_clients-attr.attr-code = {&attr-kpp} no-error.
                            
                            assign
                                part-2.supplier-inn = buf_firm.inn /* 7 */
                                part-2.supplier-kpp = (if buf_clients-attr.attr-value <> "" 
                                                      and buf_clients-attr.attr-value <> ? 
                                                      then buf_clients-attr.attr-value else buf_firm.kpp). /* 8 */
                            end. /* when {&shop} or when {&stock} */
                        
                            when {&prs} then do:
                                find first buf_person  no-lock where buf_person.psn-code = part-2.supplier-code.
                                find first buf_clients no-lock where buf_clients.obj-code = part-2.supplier-code
                                                               and   buf_clients.obj-type = part-2.supplier-type.
                                assign
                                part-2.supplier-obj-name = buf_clients.obj-name
                                part-2.supplier-inn = buf_person.inn
                                part-2.supplier-kpp = buf_person.kpp.
                            end. /* when {&prs} */
                            
                        end case. /* case buf_trn-doc.cli-type */
                        
                        /* Лицензии */
                        
                        for first buf_alc-supp-lic no-lock where buf_alc-supp-lic.cli-type = part-2.supplier-type
                                                           and   buf_alc-supp-lic.cli-code = part-2.supplier-code
                                                           and   buf_alc-supp-lic.date-from <= buf_trn-doc.fact-date
                                                           and   buf_alc-supp-lic.date-to   >= buf_trn-doc.fact-date:
                            assign
                            part-2.supplier-serial-number = buf_alc-supp-lic.seria + " " +  buf_alc-supp-lic.number /* 9  */
                            part-2.supplier-date-get = string(buf_alc-supp-lic.date-get, "99.99.9999")              /* 10 */
                            part-2.supplier-date-to = string(buf_alc-supp-lic.date-to, "99.99.9999")                /* 11 */
                            part-2.supplier-get-from = buf_alc-supp-lic.who-are-got.                                /* 12 */
                        
                        end. /* for first buf_alc-supp-lic */
                    
                        run gbl/trdcat-v.p   ( input buf_trn-doc.doc-code
                           , input {&trdcattr-dids} /* номер приходной накладной поставщика */
                           , output v-attr-val
                           , output v-attr-type
                           ) no-error.
                        
                           part-2.purchase-date = (if v-attr-val <> "" then date(v-attr-val) else buf_trn-doc.fact-date). /* 13 */
                            
                        run gbl/trdcat-v.p   ( input buf_trn-doc.doc-code
                           , input {&trdcattr-nids} /* номер приходной накладной поставщика */
                           , output v-attr-val
                           , output v-attr-type
                           ) no-error.                            
                            
                           part-2.TTN = (if v-attr-val <> "" then v-attr-val else "Не определено"). /* 14 */
                    
                    end. /* for first buf_trn-doc */
                    
                end. /* if buf_doc-line.ext-doc-type = "ie" */

            end. /* for each buf_parts */

        end. /* for each buf_doc-line */
        
    end. /* for each alc-goods */

end. /* for each obj-list */

delete object ext-cl no-error .
delete object ext-FormF1 no-error .

output stream logStr close .

/* Теперь надо объединить строки, у которых код АП, КПП и ИНН производителя одинаковые */
define buffer buf_part-1 for part-1 .
for each part-1 exclusive-lock where part-1.producer-inn <> "" :
    if TOGGLE-KPP then do :
        find first buf_part-1 exclusive-lock where buf_part-1.alc-type-code = part-1.alc-type-code
                                               and buf_part-1.producer-inn  = part-1.producer-inn
                                               and buf_part-1.producer-kpp  = part-1.producer-kpp
                                               and buf_part-1.obj-kpp       = part-1.obj-kpp
                                               and rowid(buf_part-1) <> rowid(part-1) no-error.
    end.
    else do :    
        find first buf_part-1 exclusive-lock where buf_part-1.alc-type-code = part-1.alc-type-code
                                               and buf_part-1.producer-inn  = part-1.producer-inn
                                               and buf_part-1.producer-kpp  = part-1.producer-kpp
                                               and buf_part-1.obj-type      = part-1.obj-type
                                               and buf_part-1.obj-code      = part-1.obj-code
                                               and rowid(buf_part-1) <> rowid(part-1) no-error.
    end.                                       
    if available buf_part-1 then do :
        if part-1.prod-code = 0 then do :
            assign
                buf_part-1.inc-7  = buf_part-1.inc-7  + part-1.inc-7
                buf_part-1.inc-8  = buf_part-1.inc-8  + part-1.inc-8
                buf_part-1.inc-9  = buf_part-1.inc-9  + part-1.inc-9
                buf_part-1.inc-10 = buf_part-1.inc-10 + part-1.inc-10
                buf_part-1.inc-11 = buf_part-1.inc-11 + part-1.inc-11
                buf_part-1.inc-12 = buf_part-1.inc-12 + part-1.inc-12
                buf_part-1.inc-13 = buf_part-1.inc-13 + part-1.inc-13
                buf_part-1.inc-14 = buf_part-1.inc-14 + part-1.inc-14
                buf_part-1.exp-15 = buf_part-1.exp-15 + part-1.exp-15
                buf_part-1.exp-16 = buf_part-1.exp-16 + part-1.exp-16
                buf_part-1.exp-17 = buf_part-1.exp-17 + part-1.exp-17
                buf_part-1.exp-18 = buf_part-1.exp-18 + part-1.exp-18
                buf_part-1.exp-19 = buf_part-1.exp-19 + part-1.exp-19
                buf_part-1.remain-6 = buf_part-1.remain-6 + part-1.remain-6
                buf_part-1.remain-20 = buf_part-1.remain-20 + part-1.remain-20
            .
            delete part-1.
            next.
        end.
        if buf_part-1.prod-code = 0 then do :
            assign
                part-1.inc-7  = part-1.inc-7  + buf_part-1.inc-7
                part-1.inc-8  = part-1.inc-8  + buf_part-1.inc-8
                part-1.inc-9  = part-1.inc-9  + buf_part-1.inc-9
                part-1.inc-10 = part-1.inc-10 + buf_part-1.inc-10
                part-1.inc-11 = part-1.inc-11 + buf_part-1.inc-11
                part-1.inc-12 = part-1.inc-12 + buf_part-1.inc-12
                part-1.inc-13 = part-1.inc-13 + buf_part-1.inc-13
                part-1.inc-14 = part-1.inc-14 + buf_part-1.inc-14
                part-1.exp-15 = part-1.exp-15 + buf_part-1.exp-15
                part-1.exp-16 = part-1.exp-16 + buf_part-1.exp-16
                part-1.exp-17 = part-1.exp-17 + buf_part-1.exp-17
                part-1.exp-18 = part-1.exp-18 + buf_part-1.exp-18
                part-1.exp-19 = part-1.exp-19 + buf_part-1.exp-19
                part-1.remain-6 = part-1.remain-6 + buf_part-1.remain-6
                part-1.remain-20 = part-1.remain-20 + buf_part-1.remain-20
            .
            delete buf_part-1.
            next.
        end.    
    end.                                       
end.

/*define buffer buf_part-2 for part-2 .*/
for each part-2 exclusive-lock :
    if TOGGLE-KPP then do :
        find first buf_part-2 exclusive-lock where buf_part-2.alc-type-code = part-2.alc-type-code
                                               and buf_part-2.producer-inn  = part-2.producer-inn
                                               and buf_part-2.producer-kpp  = part-2.producer-kpp
                                               and buf_part-2.obj-kpp       = part-2.obj-kpp
                                               and buf_part-2.TTN           = part-2.TTN
                                               and buf_part-2.supplier-type = part-2.supplier-type
                                               and buf_part-2.supplier-code = part-2.supplier-code
                                               and rowid(buf_part-2) <> rowid(part-2) no-error.        
    end.
    else do :
        find first buf_part-2 exclusive-lock where buf_part-2.alc-type-code = part-2.alc-type-code
                                               and buf_part-2.producer-inn  = part-2.producer-inn
                                               and buf_part-2.producer-kpp  = part-2.producer-kpp
                                               and buf_part-2.obj-type      = part-2.obj-type
                                               and buf_part-2.obj-code      = part-2.obj-code
                                               and buf_part-2.TTN           = part-2.TTN
                                               and buf_part-2.supplier-type = part-2.supplier-type
                                               and buf_part-2.supplier-code = part-2.supplier-code
                                               and rowid(buf_part-2) <> rowid(part-2) no-error.
    end.                                           
    if available buf_part-2 then do :
        if part-2.prod-code = 0 then do :
            assign
                buf_part-2.total = buf_part-2.total + part-2.total
            .
            delete part-2.
            next.
        end.
        if buf_part-2.prod-code = 0 then do :
            assign
                part-2.total = part-2.total + buf_part-2.total
            .
            delete buf_part-2.
            next.
        end.    
    end.                                       
end.

/*А теперь сделаем так, чтобы не было строк, в которых prod-code = 0*/
define variable new-prod-code as integer no-undo .
assign new-prod-code = 1 .
for each part-1 exclusive-lock where part-1.prod-code = 0 break by part-1.prod-type :
    for each part-2 exclusive-lock where part-2.alc-type-code = part-1.alc-type-code 
                                     and part-2.prod-code = part-1.prod-code
                                     and part-2.prod-type = part-1.prod-type
                                     and part-2.obj-code  = part-1.obj-code
                                     and part-2.obj-type  = part-1.obj-type :
        assign part-2.prod-code = 10000 + new-prod-code .
    end.
    assign part-1.prod-code = 10000 + new-prod-code .            
    if last-of(part-1.prod-type) then assign new-prod-code = new-prod-code + 1 .                     
end.

wait-message = string("Идёт формирование отчета").
run waitfram-show in this-procedure (input wait-message).

/* Вывод */
run print-info .

if TOGGLE-Excel = yes then run excel-output.
if TOGGLE-XML = yes then run xml-output.

run waitfram-hide.

if v-inn-err
then do :
    define variable v-user-action    as character no-undo.
    define variable v-printed        as logical   no-undo.
    message "Есть замечания по формированию декларации" view-as alert-box.
    run gbl/prnfilen.w
       (input  "Ошибки алкогольной декларации"
       ,input  0
       ,input  "alc-dec-p_errors.txt"
       ,input  7
       ,output v-user-action
       ,output v-printed
       ).
end.

apply "go".

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-info s-object
procedure print-info :
    define var v-act-file as char no-undo.
    v-act-file  = session:temp-directory + {&DF_Name} +  "alc-dec_parts-info_beer.html".
    
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
                        <td style="width:40px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:120px"></td>
                        <td style="width:180px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:120px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                  </tr>
                  <tr>
                        <td colspan="25" style="front-weight: bold; text-align: center;">Информация по партиям для алкогольной декларации</td>
                  </tr>
        </thead>
            <tbody>
                <tr>
                <th>Код объекта</th>
                <th>Тип объекта</th>
                <th>Код АП</th>
                <th>Номер приходного документа (in-code)</th>
                <th>Номер документа (out-code)</th>
                <th>Номер партии (part-code)</th>
                <th>Артикул</th>
                <th>Алк. Код</th>
                <th>Имя произв.</th>
                <th>ИНН произв.</th>
                <th>КПП произв.</th>
                <th>Откуда</th>
                <th>6</th>
                <th>7</th>
                <th>8</th>
                <th>9</th>
                <th>10</th>
                <th>11</th>
                <th>12</th>
                <th>13</th>
                <th>14</th>
                <th>15</th>
                <th>16</th>
                <th>17</th>
                <th>18</th>
                </tr>').

    for each tt-parts-info break by tt-parts-info.obj-type by tt-parts-info.obj-code by tt-parts-info.alc-type-code :
        put stream OutStr-html unformatted
            
            '<tr style="height: 50px;">' skip
             '<td text_wrap="true">' + string(tt-parts-info.obj-type) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.obj-code) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.alc-type-code) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.in-code) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.out-code) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.part-code) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.artic) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.alc-code) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.producer-obj-name) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.producer-inn) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.producer-kpp) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.importer) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.remain-6) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.inc-7) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.inc-8) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.inc-9) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.inc-10) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.inc-11) + '</td>' skip
             '<td text_wrap="true">' + string(decimal(tt-parts-info.inc-12) + decimal(tt-parts-info.inc-13)) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.inc-14) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.exp-15) + '</td>' skip
             '<td text_wrap="true">' + string(decimal(tt-parts-info.exp-16) + decimal(tt-parts-info.exp-18)) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.exp-17) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.exp-19) + '</td>' skip
             '<td text_wrap="true">' + string(tt-parts-info.remain-20) + '</td>' skip
             '</tr>' skip
             '</tbody>' skip
          .
            
    end.
    
    output stream OutStr-html close.
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE excel-output s-object 
PROCEDURE excel-output :
/*------------------------------------------------------------------------------
            Purpose: Вывод в excel                                                                    
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
define variable hSAXWriter as handle no-undo.   /* для создания excel */
define variable xml_tmp as character no-undo.   /* Путь к временному xml файлу */
define variable xslt as character no-undo.      /* Путь к xsl файлу */
define variable nn as integer no-undo.     /* Номер строки */
define variable Report-out as class Rep-Out no-undo. /* Переменная под класс */

xml_tmp = session:temp-directory + "alc-decl-tmp.xml".

create sax-writer hSAXWriter.

hSAXWriter:formatted = true.
hSAXWriter:encoding = "utf-8":U.

hSAXWriter:set-output-destination("file":U, xml_tmp).
hSAXWriter:start-document().

hSAXWriter:start-element ("report").

hSAXWriter:start-element ("page-1").
    
    hSAXWriter:write-data-element ("inn",v-fmtcli-inn).
    hSAXWriter:write-data-element ("kpp",v-fmtcli-kpp).
    hSAXWriter:write-data-element ("quarter",string(quarter)).
    if quarter <> 1 then hSAXWriter:write-data-element ("year",string(year(x-date-start))).
    hSAXWriter:write-data-element ("name",v-fmtcli-name).
    hSAXWriter:write-data-element ("post-code",firm-post-code).
    hSAXWriter:write-data-element ("region",firm-reg-code).
    hSAXWriter:write-data-element ("district",firm-district).
    hSAXWriter:write-data-element ("city", if firm-city <> "" then firm-city else firm-settlement).
    hSAXWriter:write-data-element ("street",firm-street).
    hSAXWriter:write-data-element ("house",if firm-house-number <> "" then "д. " + firm-house-number + firm-house-litera else ""
                                          + if firm-house-case <> "" then " кор. " + firm-house-case  else ""
                                          + if firm-house-apartment <> "" then " кв. " + firm-house-apartment else "").
    hSAXWriter:write-data-element ("phone",v-fmtcli-phone).
    hSAXWriter:write-data-element ("e-mail",firm-e-mail).
    hSAXWriter:write-data-element ("director",firm-director-f + " " + firm-director-i + " " + firm-director-o).
    hSAXWriter:write-data-element ("accountant",firm-accountant-f + " " + firm-accountant-i + " " + firm-accountant-o).
    hSAXWriter:write-data-element ("date",string(day(today), "99") + string(month(today), "99") + string(year(today), "9999")).

hSAXWriter:end-element ("page-1").

hSAXWriter:start-element ("page-2").
    
    hSAXWriter:insert-attribute ("inn",v-fmtcli-inn).
    hSAXWriter:insert-attribute ("kpp",v-fmtcli-kpp).

    for each page-2 no-lock:
        
        hSAXWriter:start-element ("objects").
    
            hSAXWriter:write-data-element("o1", page-2.kpp).
            hSAXWriter:write-data-element("o2", page-2.post-code).
            hSAXWriter:write-data-element("o3", page-2.reg-code).
            hSAXWriter:write-data-element("o4", page-2.district).
            hSAXWriter:write-data-element("o5", if page-2.city <> "" then page-2.city else page-2.settlement ).
            hSAXWriter:write-data-element("o6", page-2.street).
            hSAXWriter:write-data-element("o7", if page-2.house-number <> "" then "д. " + page-2.house-number + page-2.house-litera else ""
                                                + if page-2.house-case <> "" then " кор. " + page-2.house-case  else ""
                                                + if page-2.apartment <> "" then " кв. " + page-2.apartment else "").
    
        hSAXWriter:end-element ("objects").
            
    end. /* for each page-2 */

hSAXWriter:end-element ("page-2").

hSAXWriter:start-element ("part-1").

hSAXWriter:start-element ("firm"). /* Общее по фирме */
    nn = 1.
    hSAXWriter:write-data-element("header", v-fmtcli-name).

for each part-1 no-lock break by part-1.alc-type-code:
    
    accumulate part-1.remain-6  (total).
    accumulate part-1.inc-7     (total).
    accumulate part-1.inc-8     (total).
    accumulate part-1.inc-9     (total).
    accumulate part-1.inc-10    (total).
    accumulate part-1.inc-11    (total).
    accumulate part-1.inc-12    (total).
    accumulate part-1.inc-13    (total).
    accumulate part-1.inc-14    (total).
    accumulate part-1.exp-15    (total).
    accumulate part-1.exp-16    (total).
    accumulate part-1.exp-17    (total).
    accumulate part-1.exp-18    (total).
    accumulate part-1.exp-19    (total).
    accumulate part-1.remain-20 (total).
    
    accumulate part-1.remain-6  (total by part-1.alc-type-code).
    accumulate part-1.inc-7     (total by part-1.alc-type-code).
    accumulate part-1.inc-8     (total by part-1.alc-type-code).
    accumulate part-1.inc-9     (total by part-1.alc-type-code).
    accumulate part-1.inc-10    (total by part-1.alc-type-code).
    accumulate part-1.inc-11    (total by part-1.alc-type-code).
    accumulate part-1.inc-12    (total by part-1.alc-type-code).
    accumulate part-1.inc-13    (total by part-1.alc-type-code).
    accumulate part-1.inc-14    (total by part-1.alc-type-code).
    accumulate part-1.exp-15    (total by part-1.alc-type-code).
    accumulate part-1.exp-16    (total by part-1.alc-type-code).
    accumulate part-1.exp-17    (total by part-1.alc-type-code).
    accumulate part-1.exp-18    (total by part-1.alc-type-code).
    accumulate part-1.exp-19    (total by part-1.alc-type-code).
    accumulate part-1.remain-20 (total by part-1.alc-type-code).
    
    if last-of (part-1.alc-type-code) then do:
        
      hSAXWriter:start-element ("row").
        nn = nn + 1.
        hSAXWriter:write-data-element("n", string(nn)).
        hSAXWriter:write-data-element("c01" ,part-1.alc-type-name).
        hSAXWriter:write-data-element("c02" ,part-1.alc-type-code).
        hSAXWriter:write-data-element("c03" ,"").
        hSAXWriter:write-data-element("c04" ,"").
        hSAXWriter:write-data-element("c05" ,"").
        hSAXWriter:write-data-element("c06" ,string(accum total by part-1.alc-type-code part-1.remain-6 )).
        hSAXWriter:write-data-element("c07" ,string(accum total by part-1.alc-type-code part-1.inc-7    )).
        hSAXWriter:write-data-element("c08" ,string(accum total by part-1.alc-type-code part-1.inc-8    )).
        hSAXWriter:write-data-element("c09" ,string(accum total by part-1.alc-type-code part-1.inc-9    )).
        hSAXWriter:write-data-element("c10" ,string(accum total by part-1.alc-type-code part-1.inc-10   )).
        hSAXWriter:write-data-element("c11" ,string(accum total by part-1.alc-type-code part-1.inc-11   )).
        hSAXWriter:write-data-element("c12" ,string( decimal(accum total by part-1.alc-type-code part-1.inc-12) 
                                                   + decimal(accum total by part-1.alc-type-code part-1.inc-13) )).
/*        hSAXWriter:write-data-element("c13" ,string(accum total by part-1.alc-type-code part-1.inc-13   )).*/
        hSAXWriter:write-data-element("c13" ,string(accum total by part-1.alc-type-code part-1.inc-14   )).
        hSAXWriter:write-data-element("c14" ,string(accum total by part-1.alc-type-code part-1.exp-15   )).
        hSAXWriter:write-data-element("c15" ,string(decimal(accum total by part-1.alc-type-code part-1.exp-16) 
                                                  + decimal(accum total by part-1.alc-type-code part-1.exp-18) )).
        hSAXWriter:write-data-element("c16" ,string(accum total by part-1.alc-type-code part-1.exp-17   )).
/*        hSAXWriter:write-data-element("c18" ,string(accum total by part-1.alc-type-code part-1.exp-18   )).*/
        hSAXWriter:write-data-element("c17" ,string(accum total by part-1.alc-type-code part-1.exp-19   )).
        hSAXWriter:write-data-element("c18" ,string(accum total by part-1.alc-type-code part-1.remain-20)).
      hSAXWriter:end-element ("row").  
    end.

end. /* for each part-1 */

      hSAXWriter:start-element ("row").
        nn = nn + 1.
        hSAXWriter:write-data-element("n", string(nn)).
        hSAXWriter:write-data-element("c01" ,"ИТОГО").
        hSAXWriter:write-data-element("c02" ,"").
        hSAXWriter:write-data-element("c03" ,"").
        hSAXWriter:write-data-element("c04" ,"").
        hSAXWriter:write-data-element("c05" ,"").
        hSAXWriter:write-data-element("c06" ,string(accum total part-1.remain-6 )).
        hSAXWriter:write-data-element("c07" ,string(accum total part-1.inc-7    )).
        hSAXWriter:write-data-element("c08" ,string(accum total part-1.inc-8    )).
        hSAXWriter:write-data-element("c09" ,string(accum total part-1.inc-9    )).
        hSAXWriter:write-data-element("c10" ,string(accum total part-1.inc-10   )).
        hSAXWriter:write-data-element("c11" ,string(accum total part-1.inc-11   )).
        hSAXWriter:write-data-element("c12" ,string(decimal(accum total part-1.inc-12) 
                                                  + decimal(accum total part-1.inc-13) )).
/*        hSAXWriter:write-data-element("c13" ,string(accum total part-1.inc-13   )).*/
        hSAXWriter:write-data-element("c13" ,string(accum total part-1.inc-14   )).
        hSAXWriter:write-data-element("c14" ,string(decimal(accum total part-1.exp-16) 
                                                  + decimal(accum total part-1.exp-18) )).
        hSAXWriter:write-data-element("c15" ,string(accum total part-1.exp-16   )).
        hSAXWriter:write-data-element("c16" ,string(accum total part-1.exp-17   )).
/*        hSAXWriter:write-data-element("c18" ,string(accum total part-1.exp-18   )).*/
        hSAXWriter:write-data-element("c17" ,string(accum total part-1.exp-19   )).
        hSAXWriter:write-data-element("c18" ,string(accum total part-1.remain-20)).
      hSAXWriter:end-element ("row").  

hSAXWriter:end-element ("firm").

for each part-1 no-lock break by part-1.obj-type by part-1.obj-code by part-1.alc-type-code: /* Записи по объектам */

    if first-of (part-1.obj-code) then do:
        hSAXWriter:start-element ("object").
        
        find first buf_clients where buf_clients.obj-code = part-1.obj-code
                                and buf_clients.obj-type = part-1.obj-type.
        nn = nn + 1.
        hSAXWriter:write-data-element("n", string(nn)).                    
        hSAXWriter:write-data-element("header", buf_clients.obj-name).
        
    end. /* if first-of (part-1.obj-code) */
    
    accumulate part-1.remain-6  (total by part-1.obj-code).
    accumulate part-1.inc-7     (total by part-1.obj-code).
    accumulate part-1.inc-8     (total by part-1.obj-code).
    accumulate part-1.inc-9     (total by part-1.obj-code).
    accumulate part-1.inc-10    (total by part-1.obj-code).
    accumulate part-1.inc-11    (total by part-1.obj-code).
    accumulate part-1.inc-12    (total by part-1.obj-code).
    accumulate part-1.inc-13    (total by part-1.obj-code).
    accumulate part-1.inc-14    (total by part-1.obj-code).
    accumulate part-1.exp-15    (total by part-1.obj-code).
    accumulate part-1.exp-16    (total by part-1.obj-code).
    accumulate part-1.exp-17    (total by part-1.obj-code).
    accumulate part-1.exp-18    (total by part-1.obj-code).
    accumulate part-1.exp-19    (total by part-1.obj-code).
    accumulate part-1.remain-20 (total by part-1.obj-code).
    
    hSAXWriter:start-element ("row").
        nn = nn + 1.
        hSAXWriter:write-data-element("n", string(nn)).    
        hSAXWriter:write-data-element("c01" , part-1.alc-type-name).
        hSAXWriter:write-data-element("c02" ,string(part-1.alc-type-code)).
        hSAXWriter:write-data-element("c03" ,part-1.producer-obj-name).
        hSAXWriter:write-data-element("c04" ,part-1.producer-inn).
        hSAXWriter:write-data-element("c05" ,part-1.producer-kpp).
        hSAXWriter:write-data-element("c06" ,string(part-1.remain-6)).
        hSAXWriter:write-data-element("c07" ,string(part-1.inc-7)).
        hSAXWriter:write-data-element("c08" ,string(part-1.inc-8)).
        hSAXWriter:write-data-element("c09" ,string(part-1.inc-9)).
        hSAXWriter:write-data-element("c10" ,string(part-1.inc-10)).
        hSAXWriter:write-data-element("c11" ,string(part-1.inc-11)).
        hSAXWriter:write-data-element("c12" ,string(decimal(part-1.inc-12) + decimal(part-1.inc-13) )).
/*        hSAXWriter:write-data-element("c13" ,string(part-1.inc-13)).*/
        hSAXWriter:write-data-element("c13" ,string(part-1.inc-14)).
        hSAXWriter:write-data-element("c14" ,string(part-1.exp-15)).
        hSAXWriter:write-data-element("c15" ,string(decimal(part-1.exp-16) + decimal(part-1.exp-18) )).
        hSAXWriter:write-data-element("c16" ,string(part-1.exp-17)).
/*        hSAXWriter:write-data-element("c18" ,string(part-1.exp-18)).*/
        hSAXWriter:write-data-element("c17" ,string(part-1.exp-19)).
        hSAXWriter:write-data-element("c18" ,string(part-1.remain-20)).
    hSAXWriter:end-element ("row").
    
    if last-of (part-1.obj-code) then do:
        
        hSAXWriter:start-element ("row").
            nn = nn + 1.
            hSAXWriter:write-data-element("n", string(nn)).        
            hSAXWriter:write-data-element("c01" ,"ИТОГО").
            hSAXWriter:write-data-element("c02" ,"").
            hSAXWriter:write-data-element("c03" ,"").
            hSAXWriter:write-data-element("c04" ,"").
            hSAXWriter:write-data-element("c05" ,"").
            hSAXWriter:write-data-element("c06" ,string(accum total by part-1.obj-code part-1.remain-6 )).
            hSAXWriter:write-data-element("c07" ,string(accum total by part-1.obj-code part-1.inc-7    )).
            hSAXWriter:write-data-element("c08" ,string(accum total by part-1.obj-code part-1.inc-8    )).
            hSAXWriter:write-data-element("c09" ,string(accum total by part-1.obj-code part-1.inc-9    )).
            hSAXWriter:write-data-element("c10" ,string(accum total by part-1.obj-code part-1.inc-10   )).
            hSAXWriter:write-data-element("c11" ,string(accum total by part-1.obj-code part-1.inc-11   )).
            hSAXWriter:write-data-element("c12" ,string(decimal (accum total by part-1.obj-code part-1.inc-12)
                                                      + decimal (accum total by part-1.obj-code part-1.inc-13) )).
/*            hSAXWriter:write-data-element("c13" ,string(accum total by part-1.obj-code part-1.inc-13   )).*/
            hSAXWriter:write-data-element("c13" ,string(accum total by part-1.obj-code part-1.inc-14   )).
            hSAXWriter:write-data-element("c14" ,string(accum total by part-1.obj-code part-1.exp-15   )).
            hSAXWriter:write-data-element("c15" ,string(decimal (accum total by part-1.obj-code part-1.exp-16)
                                                      + decimal (accum total by part-1.obj-code part-1.exp-18) )).
            hSAXWriter:write-data-element("c16" ,string(accum total by part-1.obj-code part-1.exp-17   )).
/*            hSAXWriter:write-data-element("c18" ,string(accum total by part-1.obj-code part-1.exp-18   )).*/
            hSAXWriter:write-data-element("c17" ,string(accum total by part-1.obj-code part-1.exp-19   )).
            hSAXWriter:write-data-element("c18" ,string(accum total by part-1.obj-code part-1.remain-20)).
        hSAXWriter:end-element ("row").
        
       hSAXWriter:end-element ("object").
    end. /* if last-of (part-1.obj-code) */

end. /* for each part-1 */

hSAXWriter:end-element ("part-1").

hSAXWriter:start-element ("part-2").

hSAXWriter:start-element ("firm"). /* Общее по фирме */
    nn = 1.
    hSAXWriter:write-data-element ("header", v-fmtcli-name ).

for each part-2 no-lock break by part-2.alc-type-code:
    

    accumulate part-2.total (total).
    accumulate part-2.total (total by part-2.alc-type-code).
    
    if last-of (part-2.alc-type-code) then do:
      hSAXWriter:start-element ("row").
        nn = nn + 1.
        hSAXWriter:write-data-element ("n", string(nn)).      
        hSAXWriter:write-data-element("c01" ,part-2.alc-type-name).
        hSAXWriter:write-data-element("c02" ,part-2.alc-type-code).
        hSAXWriter:write-data-element("c03" ,"").
        hSAXWriter:write-data-element("c04" ,"").
        hSAXWriter:write-data-element("c05" ,"").
        hSAXWriter:write-data-element("c06" ,"").
        hSAXWriter:write-data-element("c07" ,"").
        hSAXWriter:write-data-element("c08" ,"").
/*        hSAXWriter:write-data-element("c09" ,"").*/
/*        hSAXWriter:write-data-element("c10" ,"").*/
/*        hSAXWriter:write-data-element("c11" ,"").*/
/*        hSAXWriter:write-data-element("c12" ,"").*/
        hSAXWriter:write-data-element("c09" ,"").
        hSAXWriter:write-data-element("c10" ,"").
        hSAXWriter:write-data-element("c11" ,"").
        hSAXWriter:write-data-element("c12" ,string(accum total by part-2.alc-type-code part-2.total)).
      hSAXWriter:end-element ("row").  
    end.
    
end. /* for each part-1 */

      hSAXWriter:start-element ("row").
        nn = nn + 1.
        hSAXWriter:write-data-element ("n", string(nn)).  
        hSAXWriter:write-data-element("c01" ,"Итого").
        hSAXWriter:write-data-element("c02" ,"").
        hSAXWriter:write-data-element("c03" ,"").
        hSAXWriter:write-data-element("c04" ,"").
        hSAXWriter:write-data-element("c05" ,"").
        hSAXWriter:write-data-element("c06" ,"").
        hSAXWriter:write-data-element("c07" ,"").
        hSAXWriter:write-data-element("c08" ,"").
/*        hSAXWriter:write-data-element("c09" ,"").*/
/*        hSAXWriter:write-data-element("c10" ,"").*/
/*        hSAXWriter:write-data-element("c11" ,"").*/
/*        hSAXWriter:write-data-element("c12" ,"").*/
        hSAXWriter:write-data-element("c09" ,"").
        hSAXWriter:write-data-element("c10" ,"").
        hSAXWriter:write-data-element("c11" ,"").
        hSAXWriter:write-data-element("c12" ,string(accum total part-2.total)).
      hSAXWriter:end-element ("row").  

hSAXWriter:end-element ("firm").

for each part-2 no-lock break by part-2.obj-type by part-2.obj-code by part-2.purchase-date:
    
    if first-of(part-2.obj-code) then do:
        hSAXWriter:start-element ("object").
        
        find first buf_clients where buf_clients.obj-code = part-2.obj-code
                                and buf_clients.obj-type = part-2.obj-type.
                                
        nn = nn + 1.
        hSAXWriter:write-data-element ("n", string(nn)).     
        hSAXWriter:write-data-element ("header", buf_clients.obj-name).        
    end. /* if first-of(part-2.obj-code) */
    
    accumulate part-2.total (total by part-2.obj-code).
    
    hSAXWriter:start-element ("row").
        nn = nn + 1.
        hSAXWriter:write-data-element ("n", string(nn)).   
        hSAXWriter:write-data-element("c01", part-2.alc-type-name).
        hSAXWriter:write-data-element("c02", part-2.alc-type-code).
        hSAXWriter:write-data-element("c03", part-2.producer-obj-name).
        hSAXWriter:write-data-element("c04", part-2.producer-inn).
        hSAXWriter:write-data-element("c05", part-2.producer-kpp).
        hSAXWriter:write-data-element("c06", part-2.supplier-obj-name).
        hSAXWriter:write-data-element("c07", part-2.supplier-inn).
        hSAXWriter:write-data-element("c08", part-2.supplier-kpp).
/*        hSAXWriter:write-data-element("c09", part-2.supplier-serial-number).*/
/*        hSAXWriter:write-data-element("c10", part-2.supplier-date-get).     */
/*        hSAXWriter:write-data-element("c11", part-2.supplier-date-to).      */
/*        hSAXWriter:write-data-element("c12", part-2.supplier-get-from).     */
        hSAXWriter:write-data-element("c09", string(part-2.purchase-date)).
        hSAXWriter:write-data-element("c10", part-2.TTN).
        hSAXWriter:write-data-element("c11", part-2.GTD).
        hSAXWriter:write-data-element("c12", string(part-2.total)).
    hSAXWriter:end-element ("row").
    
    if last-of (part-2.obj-code) then do:
        
        hSAXWriter:start-element ("row").
            nn = nn + 1.
            hSAXWriter:write-data-element ("n", string(nn)).
            hSAXWriter:write-data-element("c01", "ИТОГО").
            hSAXWriter:write-data-element("c02", "").
            hSAXWriter:write-data-element("c03", "").
            hSAXWriter:write-data-element("c04", "").
            hSAXWriter:write-data-element("c05", "").
            hSAXWriter:write-data-element("c06", "").
            hSAXWriter:write-data-element("c07", "").
            hSAXWriter:write-data-element("c08", "").
/*            hSAXWriter:write-data-element("c09", "").*/
/*            hSAXWriter:write-data-element("c10", "").*/
/*            hSAXWriter:write-data-element("c11", "").*/
/*            hSAXWriter:write-data-element("c12", "").*/
            hSAXWriter:write-data-element("c09", "").
            hSAXWriter:write-data-element("c10", "").
            hSAXWriter:write-data-element("c11", "").
            hSAXWriter:write-data-element("c12", string(accum total by part-2.obj-code part-2.total)).
        hSAXWriter:end-element ("row").
        
       hSAXWriter:end-element ("object").
    end. /* if last-of (part-2.obj-code) */
    
end.

hSAXWriter:end-element ("part-2").

hSAXWriter:end-element ("report").

hSAXWriter:end-document().

delete object hSAXWriter no-error.

/* Обработаем XML, чтобы получился готовый отчет */

xslt = search("exe\alcdc-pril12.xsl").

Report-out = new Rep-Out().

/*message "До трансформа" view-as alert-box.*/

Report-out:office(xml_tmp, xslt).
    
delete object Report-out.    

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE xml-output s-object 
PROCEDURE xml-output :
/*------------------------------------------------------------------------------
            Purpose: Вывод в XML                                                                    
            Notes:   Вывод должен идти в соответствии с XSD схемой.                                                                     
    ------------------------------------------------------------------------------*/
define variable hSAXWriter as handle no-undo.        /* для создания XML */
define variable xml        as character no-undo.     /* Путь к XML файлу */

/* счетчики */

define variable ii-ob   as integer no-undo.   /* Для оборота */
define variable ii-impr as integer no-undo.   /* Для импортера или производителя */
define variable ii-pos  as integer no-undo.   /* Для поставщика */
define variable ii-dv   as integer no-undo.   /* Для движение */
define variable MyUUID as raw       no-undo.  /* Для id */
define variable vGUID  as character no-undo.  /* Для id */

assign 
  MyUUID = generate-uuid 
  vGUID  = guid(MyUUID). 

  ii = 0.                                      /* Для ПN */

/* Для xml отчета нужно производителям/импортерам, поставщикам и лицензиям поставщиков выдать id 
   ID для поставщиков и производителей будут obj-code, но для физ лиц obj-code + 1000*/

/* раздача id для лицензий поставщиков */

xml = session:temp-directory + "R2_" + v-fmtcli-inn + "_" + string(quarter, "99") + substring(string(year(today)), 4, 1) + "_" +
      string(day(today), "99") + string(month(today), "99") + string(year(today), "9999") + "_" + vGUID + ".xml".

create sax-writer hSAXWriter.

hSAXWriter:formatted = true.
hSAXWriter:encoding = "windows-1251":U.

hSAXWriter:set-output-destination("file":U, xml).
hSAXWriter:start-document().

/* Начнём документ */
hSAXWriter:start-element ("Файл").

    /* Атрибуты */
    hSAXWriter:insert-attribute ("ДатаДок", string(day(today), "99") + "." + string(month(today), "99")  + "." + string(year(today), "9999")).
    
    case RADIO-SET-ver:
        when 1 then hSAXWriter:insert-attribute ("ВерсФорм", "4.31").
        when 3 then hSAXWriter:insert-attribute ("ВерсФорм", "4.30").
        when 2 then hSAXWriter:insert-attribute ("ВерсФорм", "4.20").
    end case.
    
    hSAXWriter:insert-attribute ("НаимПрог", "Trade House").

    /* Тэги в "Файл"-е */
    
    hSAXWriter:start-element ("ФормаОтч").
        
        /* Атрибуты */
        case RADIO-SET-ver:
            when 1 then do:
                hSAXWriter:insert-attribute ("НомФорм", "12").
                hSAXWriter:insert-attribute ("ПризПериодОтч", string(quarter)).
                hSAXWriter:insert-attribute ("ГодПериодОтч", string(year(x-date-start))).
            end.
            when 3 then do:
                hSAXWriter:insert-attribute ("НомФорм", "12").
                hSAXWriter:insert-attribute ("ПризПериодОтч", string(quarter)).
                hSAXWriter:insert-attribute ("ГодПериодОтч", string(year(x-date-start))).
            end.
            when 2 then do:
                hSAXWriter:insert-attribute ("ГодПериодОтч", string(year(x-date-start))).
                hSAXWriter:insert-attribute ("НомФорм", "12-о").
                hSAXWriter:insert-attribute ("ПризПериодОтч", string(quarter)).
                hSAXWriter:insert-attribute ("ПризФОтч", "4").
            end.
        end case.
        
        case RADIO-SET-form:
            when 1 then do:
        hSAXWriter:write-empty-element("Первичная").
            end.
            when 2 then do:
                hSAXWriter:write-empty-element("Корректирующая").
                    hSAXWriter:insert-attribute ("НомерКорр", string(FILL-IN-kor)).
            end.
        end case.
    hSAXWriter:end-element ("ФормаОтч").
    
    hSAXWriter:start-element ("Справочники").
    
        /* Сначала заполним ПроизводителиИмпортеры */
        
        ii = 0.
        
        for each part-1 no-lock break by part-1.prod-type by part-1.prod-code:
            
            if last-of(part-1.prod-code) then do:
            
            ii = ii + 1.
                        
            hSAXWriter:start-element ("ПроизводителиИмпортеры").
                
                /* Атрибуты */
                hSAXWriter:insert-attribute ("ИДПроизвИмп", if part-1.prod-type = {&prs} then string(part-1.prod-code + 1000) else string(part-1.prod-code)).
                hSAXWriter:insert-attribute ("П000000000004", part-1.producer-obj-name).
                
                hSAXWriter:write-empty-element ("ЮЛ").
                
                    hSAXWriter:insert-attribute ("П000000000005", part-1.producer-inn).
                    hSAXWriter:insert-attribute ("П000000000006", part-1.producer-kpp).
            
            hSAXWriter:end-element ("ПроизводителиИмпортеры").
            
            end. /* if last-of(part-1.prod-code) */ 
                        
        end. /* for each part-1 */
        
        for each part-2 no-lock break by part-2.supplier-type by part-2.supplier-code:
            
            if first-of(part-2.supplier-code) then do:
                
                ii = ii + 1.
                
                hSAXWriter:start-element ("Поставщики").
                
                    /* Атрибуты */
                    hSAXWriter:insert-attribute ("ИдПостав", if part-2.supplier-type = {&prs} then string(part-2.supplier-code + 1000) else string(part-2.supplier-code)).
                    hSAXWriter:insert-attribute ("П000000000007", part-2.supplier-obj-name).
                                    
                        hSAXWriter:write-empty-element ("ЮЛ").
                    
                            /* Атрибуты */
                            hSAXWriter:insert-attribute ("П000000000009", part-2.supplier-inn).
                            hSAXWriter:insert-attribute ("П000000000010", part-2.supplier-kpp).
                
                hSAXWriter:end-element ("Поставщики").
                
            end. /* if first-of(part-2.supplier-code) */

        end. /* for each part-2 */
        
    hSAXWriter:end-element ("Справочники").
    
    hSAXWriter:start-element ("Документ").
    
        hSAXWriter:start-element ("Организация").
        
            hSAXWriter:start-element ("Реквизиты").
                
                /* Атрибуты */
                case RADIO-SET-ver:
                    when 1 then hSAXWriter:insert-attribute ("Наим", v-fmtcli-name).
                    when 3 then hSAXWriter:insert-attribute ("НаимОрг", v-fmtcli-name).
                    when 2 then hSAXWriter:insert-attribute ("НаимОрг", v-fmtcli-name).
                end case.
                
/*                hSAXWriter:insert-attribute ("ИННЮЛ", v-fmtcli-inn).*/
/*                hSAXWriter:insert-attribute ("КППЮЛ", v-fmtcli-kpp).*/
                hSAXWriter:insert-attribute ("ТелОрг", v-fmtcli-phone).
                hSAXWriter:insert-attribute ("EmailОтпр", firm-e-mail).
                
                hSAXWriter:start-element ("АдрОрг").
                
                    hSAXWriter:write-data-element ("КодСтраны", firm-country-code).
                    hSAXWriter:write-data-element ("Индекс", firm-post-code).
                    hSAXWriter:write-data-element ("КодРегион", string(integer(firm-reg-code), "99")).
                    hSAXWriter:write-data-element ("Район", firm-district).
                    hSAXWriter:write-data-element ("Город", firm-city).
                    hSAXWriter:write-data-element ("НаселПункт", firm-settlement).
                    hSAXWriter:write-data-element ("Улица", firm-street).
                    hSAXWriter:write-data-element ("Дом", firm-house-number).
                    hSAXWriter:write-data-element ("Корпус", firm-house-case).
                    hSAXWriter:write-data-element ("Литера", firm-house-litera).
                    hSAXWriter:write-data-element ("Кварт", firm-house-apartment).
                
                hSAXWriter:end-element ("АдрОрг").
                
                hSAXWriter:write-empty-element ("ЮЛ").
                
                    hSAXWriter:insert-attribute ("ИННЮЛ", v-fmtcli-inn).
                    hSAXWriter:insert-attribute ("КППЮЛ", v-fmtcli-kpp).

            hSAXWriter:end-element ("Реквизиты").
            
            hSAXWriter:start-element ("ОтветЛицо").
            
                hSAXWriter:start-element ("Руководитель").
            
                    hSAXWriter:write-data-element ("Фамилия", firm-director-f).
                    hSAXWriter:write-data-element ("Имя", firm-director-i).
                    hSAXWriter:write-data-element ("Отчество", firm-director-o).
                
                hSAXWriter:end-element ("Руководитель").

                hSAXWriter:start-element ("Главбух").
            
                    hSAXWriter:write-data-element ("Фамилия", firm-accountant-f).
                    hSAXWriter:write-data-element ("Имя", firm-accountant-i).
                    hSAXWriter:write-data-element ("Отчество", firm-accountant-o).
                
                hSAXWriter:end-element ("Главбух").
            
            hSAXWriter:end-element ("ОтветЛицо").
                    
        hSAXWriter:end-element ("Организация").
        
        for each page-2 no-lock:    /* Идём по объектам */

            hSAXWriter:start-element ("ОбъемОборота").
            
                /* Атрибуты */
                hSAXWriter:insert-attribute ("КППЮЛ", page-2.kpp).
                case RADIO-SET-ver:
                    when 1 then hSAXWriter:insert-attribute ("Наим", page-2.obj-name).
                    when 3 then hSAXWriter:insert-attribute ("НаимЮЛ", page-2.obj-name).
                    when 2 then hSAXWriter:insert-attribute ("НаимЮЛ", page-2.obj-name).
                end case.
                               
                /* Проверим оборот */
                
                if can-find (first part-1 where part-1.obj-type = page-2.obj-type
                                          and   part-1.obj-code = page-2.obj-code
                                          and   (part-1.inc-14 <> 0 or part-1.exp-19 <> 0 )) 
                then do:
                    hSAXWriter:insert-attribute ("НаличиеОборота", "true").
                end.
                else do:
                    hSAXWriter:insert-attribute ("НаличиеОборота", "false").
                end.
            
                hSAXWriter:start-element ("АдрОрг").
                
                    hSAXWriter:write-data-element ("КодСтраны", page-2.country-code).
                    hSAXWriter:write-data-element ("Индекс", page-2.post-code).
                    hSAXWriter:write-data-element ("КодРегион", string(integer(page-2.reg-code), "99")).
                    hSAXWriter:write-data-element ("Район", page-2.district).
                    hSAXWriter:write-data-element ("Город", page-2.city).
                    hSAXWriter:write-data-element ("НаселПункт", page-2.settlement).
                    hSAXWriter:write-data-element ("Улица", page-2.street).
                    hSAXWriter:write-data-element ("Дом", page-2.house-number).
                    hSAXWriter:write-data-element ("Корпус", page-2.house-case).
                    hSAXWriter:write-data-element ("Литера", page-2.house-litera).
                    hSAXWriter:write-data-element ("Кварт", page-2.apartment).

                hSAXWriter:end-element ("АдрОрг").
                
                ii-ob = 0.
                
                               
                for each part-1 no-lock where part-1.obj-code = page-2.obj-code /* Пройдём по всем объектам */
                                        and   part-1.obj-type = page-2.obj-type
                                        break by part-1.alc-type-code:          /* Разбивая на типы алкогольной продукции */
                                            
                    if first-of(part-1.alc-type-code) then do:
                        
                        ii-impr = 0. /* Заново считаем имортеров и производителей */
                        
                        ii-ob = ii-ob + 1. /* Следующий тип алкогольной продукции */
                        
                        hSAXWriter:start-element ("Оборот").
                        
                            /* Атрибуты */
                            hSAXWriter:insert-attribute ("ПN", string(ii-ob)).
                            hSAXWriter:insert-attribute ("П000000000003", part-1.alc-type-code).                            
                    end.   /*  if first-of(part-1.alc-type-code) */ 
                       
                    hSAXWriter:start-element ("СведПроизвИмпорт").
                        
                        ii-impr = ii-impr + 1. /* Следующий импортер производитель */
                        
                        /* Атрибуты */
                        hSAXWriter:insert-attribute ("ПN", string(ii-impr)).
                        hSAXWriter:insert-attribute ("ИдПроизвИмп", if part-1.prod-type = {&prs} then string(part-1.prod-code + 1000) else string(part-1.prod-code)).   
                        
                        ii-pos = 0.
                        
                        for each part-2 where part-2.alc-type-code = part-1.alc-type-code /* Здесь мы в импортерах и производителях нужного типа продукции, пройдём до поставщиков */
                                        and  (
                                              (part-2.prod-code = part-1.prod-code and part-2.prod-type = part-1.prod-type)
                                           or (part-2.producer-inn = part-1.producer-inn and part-2.producer-kpp = part-1.producer-kpp)
                                                )
                                        and   part-2.obj-code  = part-1.obj-code
                                        and   part-2.obj-type  = part-1.obj-type
                                        break by part-2.supplier-code:                    /* Разбивая по поставщикам */
                            
                            if first-of(part-2.supplier-code) then do:
                            
                                ii-pos = ii-pos + 1.
                                
                                hSAXWriter:start-element ("Поставщик").
                                    
                                    /* Атрибуты */
                                    hSAXWriter:insert-attribute ("ПN", string(ii-impr)).
                                    hSAXWriter:insert-attribute ("ИдПоставщика", if part-2.supplier-type = {&prs} then string(part-2.supplier-code + 1000) else string(part-2.supplier-code)).
                            
                            end. /* if first-of(part-2.supplier-code) */
                            
                            hSAXWriter:write-empty-element ("Продукция").
                            
                                /* Атрибуты */
                                hSAXWriter:insert-attribute ("П200000000013", string(part-2.purchase-date, "99.99.9999")).
                                hSAXWriter:insert-attribute ("П200000000014", part-2.TTN).
                                hSAXWriter:insert-attribute ("П200000000015", part-2.GTD).
                                hSAXWriter:insert-attribute ("П200000000016", string(part-2.total)).
                            
                            if last-of(part-2.supplier-code) then do:
                            
                                hSAXWriter:end-element ("Поставщик").
                                
                            end. /* if last-of(part-2.supplier-code) */
        
                        end. /* for each part-2 */
                    
                        hSAXWriter:write-empty-element ("Движение").
                            
                            /* Атрибуты */
                            hSAXWriter:insert-attribute ("ПN", "1").
                            hSAXWriter:insert-attribute ("П100000000006", string(part-1.remain-6)).
                            hSAXWriter:insert-attribute ("П100000000007", string(part-1.inc-7)).
                            hSAXWriter:insert-attribute ("П100000000008", string(part-1.inc-8)).
                            hSAXWriter:insert-attribute ("П100000000009", string(part-1.inc-9)).
                            hSAXWriter:insert-attribute ("П100000000010", string(part-1.inc-10)).
                            hSAXWriter:insert-attribute ("П100000000011", string(part-1.inc-11)).
                            hSAXWriter:insert-attribute ("П100000000012", string(decimal(part-1.inc-12) + decimal(part-1.inc-13))).
                            hSAXWriter:insert-attribute ("П100000000013", string(part-1.inc-14)).
                            hSAXWriter:insert-attribute ("П100000000014", string(part-1.exp-15)).
                            hSAXWriter:insert-attribute ("П100000000015", string(decimal(part-1.exp-16) + decimal(part-1.exp-18))).
                            hSAXWriter:insert-attribute ("П100000000016", string(part-1.exp-17)).
                            hSAXWriter:insert-attribute ("П100000000017", string(part-1.exp-19)).
                            hSAXWriter:insert-attribute ("П100000000018", string(part-1.remain-20)).
                    
                        hSAXWriter:end-element ("СведПроизвИмпорт").
 
                    if last-of(part-1.alc-type-code) then do:
                       
                        hSAXWriter:end-element ("Оборот").
                    
                    end. /* if last-of(part-1.alc-type-code) */
                                     
                end. /* for each part-1 */
            
            hSAXWriter:end-element ("ОбъемОборота").
        
        end. /* for each page-2 */
    
    hSAXWriter:end-element ("Документ").
    
hSAXWriter:end-element ("Файл").
hSAXWriter:end-document().
delete object hSAXWriter no-error.

message "Вывод в XML завершен." skip
        "Путь к сформированному файлу: " skip
        xml
view-as alert-box information.

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME    

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE local-initialize s-object 
PROCEDURE local-initialize :
/*------------------------------------------------------------------------------
  Purpose:     Override standard ADM method
  Notes:
------------------------------------------------------------------------------*/

  /* Code placed here will execute PRIOR to standard behavior. */



  /* Dispatch standard ADM method.                             */
  RUN dispatch IN THIS-PROCEDURE ( INPUT 'initialize':U ) .

  /* Code placed here will execute AFTER standard behavior.    */

/* Пусть здесь будет управление элементами интерфейсса */
    assign
    EDITOR-ALC-PRODUCER = "По всем производителям"
    EDITOR-SUPPLIER = "По всем поставщикам"
    EDITOR-ALC-TYPE = "По всем типам продукции"
    TOGGLE-Excel    = yes
    TOGGLE-XML      = yes.
    
    display EDITOR-ALC-PRODUCER EDITOR-SUPPLIER EDITOR-ALC-TYPE TOGGLE-Excel TOGGLE-XML with frame {&FRAME-NAME}.
    
    assign FILL-IN-kor:hidden in frame {&FRAME-NAME} = true.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-params s-object 
PROCEDURE my-params :
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE my-var s-object 
PROCEDURE my-var :
/*------------------------------------------------------------------------------
  Purpose:     здесь происходит вызов  значений переменных
  например  Название отчета
------------------------------------------------------------------------------*/
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-to-log s-object 
PROCEDURE write-to-log :
define input param p-str as char no-undo.

do
on error undo, return error
:
   message
      p-str
      skip
   view-as alert-box error.

end. /* do on error */
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

procedure my-init-temp-parts-by-factord :

  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .

  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".

  define buffer buf_gds-obj  for ub.gds-obj .

  do
  on error undo, return error
  :

    /* блокируется товар на объекте в соответствии с общими правилами */
    /* 1. открывается транзакция */
    /* 2. накладывается exclusive блокировка на товар */
    /* 3. затем блокировка по выходу из блока автоматически снижается */
    /*    до уровня share-lock */
    do transaction
    on error undo, return error
    :
      { gbl/gdsobjcr.i
        p-obj-type
        p-obj-code
        p-artic
        p-prod-type
        p-prod-code
        buf_gds-obj
        no-error
      }
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно найти товар на объекте" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.

      find current buf_gds-obj exclusive-lock .
    end.

    /* инициализация текущего остатка по партиям свободной зоны */
    run partslib-init-temp-parts in this-procedure
      (input p-obj-type  /* p-obj-type  */
      ,input p-obj-code  /* p-obj-code  */
      ,input p-artic     /* p-artic     */
      ,input p-prod-type /* p-prod-type */
      ,input p-prod-code /* p-prod-code */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.

    /* требуется получить информацию о состоянии */
    /* непосредственно перед закрытием документа */
    assign
      p-fact-order = p-fact-order - {&arh-delta}
    .

    define variable v-max-fact-order as character no-undo .

    run factord-max-fact-order in this-procedure
      (output v-max-fact-order /* p-max-fact-order */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.

    /* просматриваем все операции, прошедшие с товаром с указанного момента p-fact-order */
    /* до текущего момента */
    /* новые документы во время нашего прохода появится не могут, так как товар мы заблокировали */
    run my-update-by-factord in this-procedure
      (input p-obj-type       /* p-obj-type         */
      ,input p-obj-code       /* p-obj-code         */
      ,input p-artic          /* p-artic            */
      ,input p-prod-type      /* p-prod-type        */
      ,input p-prod-code      /* p-prod-code        */
      ,input p-fact-order     /* p-start-fact-order */
      ,input v-max-fact-order /* p-end-fact-order   */
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры partslib-update-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        "v-max-fact-order" v-max-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.

end procedure. /* my-init-temp-parts-by-factord */

procedure my-update-by-factord :

  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-start-fact-order   as decimal   no-undo .
  define input parameter p-end-fact-order     as decimal   no-undo .

  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".

  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .

  define variable v-total-parts-qnty as decimal   no-undo .
  define variable v-goods-gds-goods  as logical   no-undo .
  define variable v-goods-twounit    as logical   no-undo .
  
  define variable v-kpp2            as character no-undo .

  do
  on error undo, return error
  :
    if p-start-fact-order > p-end-fact-order
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Начало интервала превышает конец интервала" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-start-fact-order" p-start-fact-order skip
        "p-end-fact-order"   p-end-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.

    { gbl/gdsat.i
      p-artic
      p-prod-type
      p-prod-code
      "'gds-goods=request':u"
      v-goods-gds-goods
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-goods=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    { gbl/gdsat.i
      p-artic
      p-prod-type
      p-prod-code
      "'twounit=request':u"
      v-goods-twounit
      no-error
    }
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    /* просматриваем все операции, прошедшие с товаром с указанного момента p-fact-order */
    /* до текущего момента */
    /* новые документы во время нашего прохода появится не могут, так как товар мы заблокировали */
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = {&fact}
        and buf_doc-line.fact-order > p-start-fact-order
        and buf_doc-line.fact-order <= p-end-fact-order
    on error undo, return error
    :

      if (buf_doc-line.ext-doc-type = 'iv' or buf_doc-line.ext-doc-type = 'ev' or buf_doc-line.ext-doc-type = 'rv')
      then do :
        for first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code :
            v-kpp = "" . 
            for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = buf_trn-doc.cli-code /* КПП */
                                               and   buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                               and   buf_clients-attr.attr-code = {&attr-kpp}:
                v-kpp = buf_clients-attr.attr-value.
            end. /* for first buf_clients-attr */
            if v-kpp = "" then  v-kpp = v-fmtcli-kpp.
            
            v-kpp2 = "" . 
            for first buf_clients-attr no-lock where buf_clients-attr.obj-code  = buf_trn-doc.obj-code /* КПП */
                                               and   buf_clients-attr.obj-type  = buf_trn-doc.obj-type
                                               and   buf_clients-attr.attr-code = {&attr-kpp}:
                v-kpp2 = buf_clients-attr.attr-value.
            end. /* for first buf_clients-attr */
            if v-kpp2 = "" then  v-kpp2 = v-fmtcli-kpp.
            
            if v-kpp = v-kpp2 then next .
        end.
      end.
      
      run partslib-process-document in this-procedure
        (input  buf_doc-line.doc-code /* p-doc-code         */
        ,input  p-obj-type            /* p-obj-type         */
        ,input  p-obj-code            /* p-obj-code         */
        ,input  p-artic               /* p-artic            */
        ,input  p-prod-type           /* p-prod-type        */
        ,input  p-prod-code           /* p-prod-code        */
        ,input  v-goods-gds-goods     /* p-goods-gds-goods  */
        ,input  v-goods-twounit       /* p-goods-twounit    */
        ,output v-total-parts-qnty    /* p-total-parts-qnty */
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры partslib-process-document" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-start-fact-order" p-start-fact-order skip
          "p-end-fact-order" p-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.

end procedure. /* my-update-by-factord */
