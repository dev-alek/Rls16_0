DEFINE TEMP-TABLE t-obj-list NO-UNDO
    FIELD obj-type  AS CHARACTER
    FIELD obj-code  AS INTEGER
    FIELD host-code AS INTEGER
    INDEX pi IS UNIQUE PRIMARY obj-type  obj-code
    INDEX firm                 host-code.

{ cmp/gds-list.i tt-gds-list def  } 

DEFINE TEMP-TABLE tt-vsd-filt NO-UNDO
FIELD date-end AS DATE
FIELD date-start AS DATE
FIELD fTime  AS INTEGER  
FIELD FalExting AS LOGICAL
FIELD FalVerif  AS LOGICAL
FIELD Rep       AS LOGICAL
FIELD ReqVerif  AS LOGICAL
FIELD ToExtin   AS LOGICAL
FIELD Sent      AS LOGICAL
FIELD doc-code  AS CHARACTER 
.

DEFINE DATASET ds-vsd-set
FOR tt-vsd-filt, t-obj-list,  tt-gds-list . 
 
DEFINE TEMP-TABLE ttvsd NO-UNDO LIKE ub.vsd
        FIELD dateTTH     AS DATE  /*  "Номер ТТН"              "X(20)" */
        FIELD NomTTH      AS CHAR  /*  "Номер ТТН"              "X(20)" */
        FIELD NomTTHpost  AS CHAR  /*  "Номер ТТН поставщика"   "X(20)" */
        FIELD NomAZS      AS CHAR  /*  "№ АЗС"                  ?  */
        FIELD Post        AS CHAR  /*  "Поставщик"              "X(20)" */
        FIELD artic       AS CHAR  /*  "Артикул товара"         "X(20)" */
        FIELD gdsname     AS CHAR  /*  "Наименование товара"    "X(30)" */
        FIELD prod-code   AS CHAR  /*  "Производитель"          "X(20)" */
        FIELD COLobj      AS DEC   /*  "Кол-во ВСД"            "X(15)" */
        FIELD unit-cli    AS CHAR  /*  "Ед.изм."                "X(6)" */
        FIELD unit-base   AS CHAR  /*  "Ед.изм."                "X(6)" */
        /*FIELD UUID         AS CHAR    "Номер ВСД"              "X(40)" */
        FIELD statusvsd   AS CHAR  /*  "Статус ВСД"             "X(20)" */
        FIELD ojd         AS DEC   /*  "Ожидает гашения"        "X(20)" */
        FIELD gdsmercguid AS CHAR  /*  Guid merc                "X(40)" */
        FIELD vsdtypelbl  AS CHAR  /*  Guid merc                "X(40)" */
        FIELD vsdsubs     AS CLASS Progress.Lang.Object.