/*

$Revision: cb9d18173618, 2031, rls $
$Author: druban $
$Date: Fri Oct 18 10:56:48 2019 +0300 $
$Workfile: r-statusvsd.p $
$Archive: rep/r-statusvsd.p $

Отчет ВСД

Автор: Рубан Дмитрий Андреевич
Дата создания: 31/05/2018
Author: Ruban Dmitriy
Creation date: 31/05/18

Ruban 

*/
&if DEFINED (only_print) EQ 0
&Then 
USING ibs.th.str.gds.*.
USING ibs.th.str.mercury.*.
USING ibs.th.gbl.storage.*.
block-level on error undo, throw.
&scop date-start x-date-start
&scop date-end x-date-end
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
DEFINE INPUT PARAMETER pTime         AS INTEGER       NO-UNDO .
DEFINE INPUT PARAMETER pStatus       AS CHARACTER     NO-UNDO .
DEFINE VARIABLE vss-revision AS CHARACTER NO-UNDO INIT "$Revision: cb9d18173618, 2031, rls $":U .
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INIT "$Author: druban $":U .
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INIT "$Date: Fri Oct 18 10:56:48 2019 +0300 $":U .
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INIT "$Workfile: r-statusvsd.p $":U .
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INIT "$Archive: rep/r-statusvsd.p $":U .
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INIT "Отчет ВСД".
&ELSE 
 
{ bge/ds-vsd-set.i } 
DEFINE INPUT PARAMETER parparentproc AS WIDGET-HANDLE NO-UNDO .
DEFINE INPUT PARAMETER p-date-start         AS DATE       NO-UNDO .
DEFINE INPUT PARAMETER p-date-end           AS DATE       NO-UNDO .
DEFINE INPUT PARAMETER  TABLE FOR  ttvsd. 
&scop date-start p-date-start
&scop date-end p-date-end

&Endif


{ cmp/vssrevis.i  }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ gbl/prn-lib.i   }
{ rep/html-conv.i }



DEFINE VARIABLE v-report-name       AS CHARACTER NO-UNDO .
DEFINE VARIABLE v-file-name-rep-htm AS CHARACTER NO-UNDO .
DEFINE STREAM OutStr-html.
&if DEFINED (only_print) EQ 0
&Then 
{ cmp/r-page1.i }
DEFINE STREAM OutStr-html.
DEFINE TEMP-TABLE ttVSD  NO-UNDO 
 FIELD id           as INTEGER
 FIELD db-num       AS INTEGER    
 FIELD dateTTH      AS DATE  /*  "Номер ТТН"              "X(20)" */
 FIELD NomTTH       AS CHAR  /*  "Номер ТТН"              "X(20)" */
 FIELD NomTTHpost   AS CHAR  /*  "Номер ТТН поставщика"   "X(20)" */
 FIELD NomAZS       AS CHAR  /*  "№ АЗС"                  ?  */
 FIELD Post         AS CHAR  /*  "Поставщик"              "X(20)" */
 FIELD artic        AS CHAR  /*  "Артикул товара"         "X(20)" */ 
 FIELD gdsname      AS CHAR  /*  "Наименование товара"    "X(30)" */
 FIELD prod-code    AS CHAR  /*  "Производитель"          "X(20)" */
 FIELD COLobj       AS DEC   /*  "Кол-во факт"            "X(15)" */
 FIELD unit-cli     AS CHAR  /*  "Ед.изм."                "X(6)" */
 FIELD UUID         AS CHAR  /*  "Номер ВСД"              "X(40)" */
 FIELD statusvsd    AS CHAR  /*  "Статус ВСД"             "X(20)" */
 FIELD ojd          AS char   /*  "Ожидает гашения"        "X(20)" */
 FIELD msg-err         AS char   /*  "Ошибка"        "X(20)" */
 FIELD vsdtypelbl   AS CHARACTER 
.

DEFINE BUFFER bclients FOR clients.   
DEFINE VARIABLE v-attr-type AS CHARACTER NO-UNDO.
DEFINE VARIABLE vOjd AS INTEGER   NO-UNDO.
DEFINE VARIABLE vsdsTHObj  AS CLASS vsdsubs.
DEFINE VARIABLE vsdStorage AS CLASS vsdtostorage.
DEFINE VARIABLE vI AS INTEGER NO-UNDO.
vsdsTHObj = NEW vsdsubs ().
vsdStorage = NEW vsdtostorage ().

FOR EACH obj-list:
   
   
    vsdsTHObj = vsdStorage:getVSDsubs(obj-list.obj-type,obj-list.obj-code,pstatus).
    Block-vsd:
    DO vi = 1 TO vsdsTHObj:GetItem (vi):
        FIND FIRST ttvsd WHERE ttVSD.ID         = vsdsTHObj:VsdObjCurr:ID
                         AND ttvsd.db-num       = vsdsTHObj:VsdObjCurr:DBNum
            NO-ERROR.
        IF AVAIL ttvsd 
            THEN 
            NEXT Block-vsd.
        FIND FIRST trn-doc WHERE trn-doc.doc-code EQ ENTRY (8,vsdsTHObj:VsdObjCurr:PartKey,{&delim-key}) NO-LOCK NO-ERROR.
    IF NOT AVAIL trn-doc 
    THEN 
        NEXT Block-vsd.
    IF    trn-doc.doc-date < {&date-start} 
       OR trn-doc.doc-date > {&date-end} 
    THEN 
        NEXT Block-vsd.
        FIND FIRST goods WHERE goods.gds-code EQ vsdsTHObj:VsdObjCurr:GdsCode NO-LOCK NO-ERROR.
    IF NOT AVAIL goods THEN NEXT Block-vsd.
    CASE  x-SelectGood: 
        WHEN {&g-choice} OR
        WHEN {&g-spis} OR
        WHEN {&g-one} THEN 
            DO:
                FIND FIRST gds-list
                    WHERE gds-list.artic     = goods.artic
                      AND gds-list.prod-type = goods.prod-type
                      AND gds-list.prod-code = goods.prod-code NO-ERROR .
                IF NOT AVAILABLE gds-list THEN NEXT Block-vsd.
            END.
        WHEN {&g-all} THEN . /* все товары */
     END.   
     FIND FIRST  clients WHERE clients.obj-type EQ goods.prod-type
                  AND clients.obj-code EQ goods.prod-code
                  NO-LOCK NO-ERROR.
    FIND FIRST  bclients WHERE bclients.obj-type EQ  trn-doc.cli-type
        AND bclients.obj-code EQ trn-doc.cli-code
        NO-LOCK NO-ERROR.               
        vOjd =  IF vsdsTHObj:VsdObjCurr:PendingRepayment THEN 0 ELSE TRUNC ((NOW - vsdsTHObj:VsdObjCurr:FactDatetime)/ (1000 * 60 * 60),0).
    IF    vOjd >= pTime
            OR vsdsTHObj:VsdObjCurr:PendingRepayment
    THEN  
    DO: 
        CREATE ttvsd.  
            ttVSD.ID            = vsdsTHObj:VsdObjCurr:ID.                
            ttvsd.db-num        = vsdsTHObj:VsdObjCurr:DBNum.
            ttVSD.UUID       = vsdsTHObj:VsdObjCurr:UUID                     /*  "Номер ВСД"              "X(40)" */.
            ttVSD.msg-err       = vsdsTHObj:VsdObjCurr:MsgErr.
            ttVSD.statusvsd  = vsdsTHObj:VsdObjCurr:StatusLbl .         /*  "Статус ВСД"             "X(20)" */  
            ttvsd.vsdtypelbl    = vsdsTHObj:VsdObjCurr:VSDTypeLbl.
            ttVSD.COLobj      = vsdsTHObj:VsdObjCurr:Qnty            /*  "Кол-во факт"            "X(15)" */.
        ASSIGN
         
            ttVSD.dateTTH     = trn-doc.doc-date            /*  "Номер ТТН"              "X(20)" */
            ttVSD.NomTTH      = trn-doc.doc-code            /*  "Номер ТТН"              "X(20)" */
            ttVSD.NomTTHpost  = trn-doc.rcv-code            /*  "Номер ТТН поставщика"   "X(20)" */
            ttVSD.NomAZS      = STRING(obj-list.obj-code)   /*  "№ АЗС"                  ?  */
            ttVSD.Post        = IF AVAIL bclients 
                                THEN bclients.obj-name
                                ELSE ""                     /*  "Поставщик"              "X(20)" */
            ttVSD.artic       = goods.artic                 /*  "Артикул товара"         "X(20)" */ 
            ttVSD.gdsname     = goods.gds-name              /*  "Наименование товара"    "X(30)" */
            ttVSD.prod-code   = IF AVAIL clients 
                                THEN clients.obj-name
                                ELSE ""                     /*  "Производитель"          "X(20)" */
                
            
            ttVSD.unit-cli    = goods.unit-cli              /*  "Ед.изм."                "X(6)" */
                
            ttVSD.ojd        = string (vOjd )                            /*  "Ожидает гашения"        "X(20)" */
            .
            
            RUN gbl/trdcat-v.p
               ( INPUT trn-doc.doc-code
                ,INPUT {&trdcattr-nids }
                ,OUTPUT ttVSD.NomTTHpost
                ,OUTPUT v-attr-type
               ).
     END.        
    end. 
END.
FIND FIRST ttvsd NO-ERROR.
IF NOT AVAIL ttvsd
THEN 
   MESSAGE "Отчет пуст."
   VIEW-AS ALERT-BOX. 
ELSE    
&endif 
DO:
    RUN prn-lib-get-report-name  IN this-procedure 
    
    (INPUT parParentProc, OUTPUT v-report-name).
    v-file-name-rep-htm = v-report-name + ".html".
    
    OUTPUT stream OutStr-html to value(v-file-name-rep-htm) convert target 'UTF-8' .
    PUT STREAM OutStr-html UNFORMATTED
        "<!DOCTYPE HTML>"                                               SKIP
        '<html>'                                                        SKIP
        '<head>'                                                        SKIP
        '  <meta charset="utf-8">'                                      SKIP
        '  <style>'                                                     SKIP 
        '      table ~{ '                                               SKIP 
        '             border-collapse: collapse;'                       SKIP 
        '             ~}'                                               SKIP
        '       tbody td, th ~{'                                        SKIP 
        '                 border: 1px solid black;'                     SKIP 
        '                    ~}'                                        SKIP
        '   </style>'                                                   SKIP
        '</head>'                                                       SKIP
        '<body>'                                                        SKIP
        '<TABLE name="1" fit_to_page="true" orientation="landscape">'   SKIP
        '<thead>'                                                       SKIP
        
        /* Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px */
        '  <tr>'                                SKIP
        '    <td style="width:  53px;"></td>'   SKIP /*  "Дата ТТН"               "99/99/99" */
        '    <td style="width: 106px;"></td>'   SKIP /*  "Номер ТТН"              "X(20)" */
        '    <td style="width: 106px;"></td>'   SKIP /*  "Номер ТТН поставщика"   "X(20)" */
        '    <td style="width: 53px;"></td>'    SKIP /*  "№ АЗС"                  ?  */
        '    <td style="width: 200px;"></td>'    SKIP /*  "Поставщик"              "X(20)" */
        '    <td style="width: 60px;"></td>'    SKIP /*  "Артикул товара"         "X(20)" */
        '    <td style="width: 200px;"></td>'    SKIP /*  "Наименование товара"    "X(30)" */
        '    <td style="width: 200px;"></td>'    SKIP /*  "Производитель"          "X(20)" */
        '    <td style="width: 53px;"></td>'    SKIP /*  "Кол-во по ВСД"            "X(15)" */
        '    <td style="width: 53px;"></td>'    SKIP /*  "Ед.изм."                "X(6)" */
        '    <td style="width: 100px;"></td>'    SKIP /*  "Тип"             "X(20)" */
        '    <td style="width: 300px;"></td>'    SKIP /*  "Номер ВСД"              "X(40)" */
        '    <td style="width: 170px;"></td>'    SKIP /*  "Статус ВСД"             "X(20)" */
        '    <td style="width: 80px;"></td>'    SKIP /*  "Ожидает гашения"        "X(20)" */
        '    <td style="width: 200px;"></td>'    SKIP /*  "Ожидает гашения"        "X(20)" */
        '  </tr>'                               SKIP
        
        /* Теперь шапка таблицы */
        '  <tr>'                                                            SKIP
        '     <td colspan="13">Отчет с детализацией по накладным c ' + STRING ({&date-start}, "99/99/9999")
        + " по " +  String({&date-end},"99/99/9999") + 
        '</td>'    SKIP
        '  </tr>'                                                           SKIP
        '</thead>'                                                          SKIP
        
        /* Здесь начинается таблица отчета */
        '<tbody>'                               SKIP
        
        /* Первые строки – шапка табоицы с тэгами th */
        '  <tr>'                                SKIP
        '    <th>Дата ТТН</th>'                 SKIP
        '    <th>Номер ТТН</th>'                SKIP
        '    <th>Номер ТТН поставщика</th>'     SKIP
        '    <th>№ АЗС</th>'                    SKIP
        '    <th>Поставщик</th>'                SKIP
        '    <th>Артикул товара</th>'           SKIP
        '    <th>Наименование товара</th>'      SKIP
        '    <th>Производитель</th>'            SKIP
        '    <th>Кол-во по ВСД</th>'            SKIP
        '    <th>Ед.изм.</th>'                  SKIP
        '    <th>Тип</th>'                      SKIP
        '    <th>Номер ВСД</th>'                SKIP
        '    <th>Статус ВСД</th>'               SKIP
        '    <th>Ожидает гашения (ч.)</th>'          SKIP
    '    <th>Описание ошибки</th>'          SKIP
        '  </tr>'                               SKIP     
        .
        
    /*----------------------------------------------------------*/
        FOR EACH ttvsd:  
            PUT STREAM OutStr-html UNFORMATTED
                '  <tr>' SKIP 
                SUBSTITUTE('      <td>&1</td>',          STRING(ttvsd.dateTTH))              SKIP /*Дата ТТН*/
                SUBSTITUTE('      <td>&1</td>',                 ttvsd.NomTTH)                SKIP /*Номер ТТН*/
                SUBSTITUTE('      <td>&1</td>',                 ttvsd.NomTTHpost)            SKIP /*Номер ТТН поставщика*/
                SUBSTITUTE('      <td>&1</td>',                 ttvsd.NomAZS)                SKIP /*№ АЗС*/
                SUBSTITUTE('      <td text_wrap="true">&1</td>',ttvsd.Post)                  SKIP /*Поставщик*/
                SUBSTITUTE('      <td>&1</td>',                 ttvsd.artic)                 SKIP /*Артикул товара*/
                SUBSTITUTE('      <td text_wrap="true">&1</td>',ttvsd.gdsname)               SKIP /*Наименование товара*/
                SUBSTITUTE('      <td text_wrap="true">&1</td>',ttvsd.prod-code)             SKIP /*Производитель*/
                SUBSTITUTE('      <td>&1</td>',       trim( STRING(ttvsd.COLobj,">>>>>>9.999")))               SKIP /*Кол-во факт*/
                SUBSTITUTE('      <td num="0" val="&1">&1</td>',ttvsd.unit-cli)              SKIP /*Ед.изм.*/
                SUBSTITUTE('      <td text_wrap="true">&1</td>',ttvsd.vsdtypelbl )           SKIP /*Тип*/
                SUBSTITUTE('      <td>&1</td>',                 ttvsd.UUID)                  SKIP /*Номер ВСД*/
                SUBSTITUTE('      <td>&1</td>',                 ttvsd.statusvsd)             SKIP /*Статус ВСД*/
                SUBSTITUTE('      <td>&1</td>',                 ttvsd.ojd )                  SKIP /*Ожидает гашения*/
                SUBSTITUTE('      <td text_wrap="true">&1</td>',ttvsd.msg-err )                 SKIP /*Ожидает гашения*/
            '</tr>' SKIP
            .
        END.
           
        PUT STREAM OutStr-html UNFORMATTED
        '</tbody>'              SKIP
        '<tfoot>' '</tfoot>'    SKIP
        '</table>'              SKIP
        '</body>'               SKIP
        '</html>'               SKIP
        .
    OUTPUT stream OutStr-html close.     
    RUN prn-lib-reportviewer-report-name IN this-procedure 
    
     (
        INPUT this-procedure
        ,INPUT v-file-name-rep-htm
        ).
END. 
&if DEFINED (only_print) EQ 0
&Then 
      FINALLY :
    
         DELETE OBJECT vsdStorage NO-ERROR .
         DELETE OBJECT vsdsTHObj  NO-ERROR.
    END FINALLY. 
&endif